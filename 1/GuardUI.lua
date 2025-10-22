-- 侍从界面
GuardUI = {}

-- 是否开启侍从命魂功能  服务器端来控制
local is_open_soul_of_guard = (UIDefine.FunctionSwitch["GuardMingHun"] and UIDefine.FunctionSwitch["GuardMingHun"] == 'on') and true or nil

--侍从配置的最高等级
local GUARD_MAX_LEVEL = 200
--侍从配置的最大星级
local GUARD_MAX_STAR = 6

local tabList = {
    { "属性", "attrTabBtn", "OnAttrTabBtnClick", "guardArr_Right", "GuardUI/panelBg/attrPage" }, -- attrPage
    { "升星", "trainTabBtn", "OnTrainTabBtnClick", "guardUpdateStar_Bg" },
    { "情缘", "loveGuardTabBtn", "OnLoveTabBtnClick", "guardLove_Bg" },
    { "加成", "addAttrTabBtn", "OnAddAttrTabBtnClick", "AddAttrPage" },
    { "阵容", "teamTabBtn", "OnTeamTabBtnClick", "TeamTab_Main" }
}
GuardUI.tab_list = tabList
--侍从类型
local guardType = {
    { "物攻", "1800707170" },
    { "法攻", "1800707180" },
    { "治疗", "1800707190" },
    { "控制", "1800707210" },
    { "辅助", "1800707200" },
    { "全部", "" },
}

local quality = {
    { "1801205100", "1800400330" },
    { "1801205110", "1800400100" },
    { "1801205120", "1800400110" },
    { "1801205130", "1800400120" },
    { "1801205130", "1800400320" },
}

local attrLst = {
    { RoleAttr.RoleAttrPhyAtk, System.Enum.ToInt(RoleAttr.RoleAttrPhyAtk) },
    { RoleAttr.RoleAttrMagAtk, System.Enum.ToInt(RoleAttr.RoleAttrMagAtk) },
    { RoleAttr.RoleAttrPhyDef, System.Enum.ToInt(RoleAttr.RoleAttrPhyDef) },
    { RoleAttr.RoleAttrMagDef, System.Enum.ToInt(RoleAttr.RoleAttrMagDef) },
    { RoleAttr.RoleAttrPhyBurstRate, System.Enum.ToInt(RoleAttr.RoleAttrPhyBurstRate) },
    { RoleAttr.RoleAttrMagBurstRate, System.Enum.ToInt(RoleAttr.RoleAttrMagBurstRate) },
    { RoleAttr.RoleAttrSealRate, System.Enum.ToInt(RoleAttr.RoleAttrSealRate) },
    { RoleAttr.RoleAttrSealResistRate, System.Enum.ToInt(RoleAttr.RoleAttrSealResistRate) },
    { RoleAttr.RoleAttrMissRate, System.Enum.ToInt(RoleAttr.RoleAttrMissRate) },
    { RoleAttr.RoleAttrFightSpeed, System.Enum.ToInt(RoleAttr.RoleAttrFightSpeed) } }

--三级页签专用
GuardUI.SelectGuardID = 0
GuardUI.PreSelectGuardBtn = nil
GuardUI.PreSelectGuardID = 0
GuardUI.SortedGuardIDLst = nil
GuardUI.FirstSelectFlag = true
GuardUI.SelectType = 0 --手动选择的分类
GuardUI.TabIndex = 1
GuardUI.SelectGuardActived = false
local _gt = UILayout.NewGUIDUtilTable()

function GuardUI.Main(parameter)
    GuardUI.OnlineGuardLists = {} -- 上阵侍从的列表

    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = MainUI.MainUISwitchConfig["侍从"].OpenLevel
    if CurLevel < Level then
        CL.SendNotify(NOTIFY.ShowBBMsg, tostring(Level) .. "级开启" .. '侍从' .. "功能")
        return
    end

    _gt = UILayout.NewGUIDUtilTable()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "GetBattleArray")

    local panel = GUI.WndCreateWnd("GuardUI", "GuardUI", 0, 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "侍    从", "GuardUI", "OnExit", _gt)
    _gt.BindName(panelBg, "panelBg")
    UILayout.CreateRightTab(tabList, "GuardUI")

    local guard_Bg = GUI.ImageCreate(panelBg, "guard_Bg", "1800400220", 0, 0, false, 1197, 639)
    _gt.BindName(guard_Bg, "guard_Bg")
    GUI.SetColor(guard_Bg, Color.New(1, 1, 1, 0))

    --侍从稀有度
    local middle_GuardRarity_Sprite = GUI.ImageCreate(guard_Bg, "middle_GuardRarity_Sprite", "1800714050", 135, 65)
    _gt.BindName(middle_GuardRarity_Sprite, "middle_GuardRarity_Sprite")
    UILayout.SetSameAnchorAndPivot(middle_GuardRarity_Sprite, UILayout.Top)

    --侍从伤害类型
    local middle_GuardType_Sprite = GUI.ImageCreate(guard_Bg, "middle_GuardType_Sprite", "1800707170", 135, 95)
    _gt.BindName(middle_GuardType_Sprite, "middle_GuardType_Sprite")
    UILayout.SetSameAnchorAndPivot(middle_GuardType_Sprite, UILayout.Top)

    local bottomShadow = GUI.ImageCreate(guard_Bg, "bottomShadow", "1800400240", 0, 45)
    _gt.BindName(bottomShadow, "bottomShadow")
    UILayout.SetSameAnchorAndPivot(bottomShadow, UILayout.BottomLeft)

    --显示升星上限
    for i = 1, GUARD_MAX_STAR do
        local star = GUI.ImageCreate(guard_Bg, "starPic" .. tostring(i), "1801202192", 494 + 35 * (i - 1), 426, false, 31, 31)
        UILayout.SetSameAnchorAndPivot(star, UILayout.TopLeft)
        _gt.BindName(star, "starPic" .. tostring(i))
    end

    --侍从名字
    local guardName = GUI.CreateStatic(guard_Bg, "guardName", "名        称", 425, -134, 300, 30)
    UILayout.SetSameAnchorAndPivot(guardName, UILayout.BottomLeft)
    UILayout.StaticSetFontSizeColorAlignment(guardName, UIDefine.FontSizeM, UIDefine.BrownColor)
    local bg = GUI.ImageCreate(guardName, "bg", "1800700010", 103, 0, false, 235, 33)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Left)
    local txt = GUI.CreateStatic(bg, "txt", "名字", 0, 0, 330, 30, "system", true)
    _gt.BindName(txt, "guardName")
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    --侍从等级
    local guardLevel = GUI.CreateStatic(guard_Bg, "guardLevel", "等        级", 425, -94, 100, 30)
    UILayout.SetSameAnchorAndPivot(guardLevel, UILayout.BottomLeft)
    UILayout.StaticSetFontSizeColorAlignment(guardLevel, UIDefine.FontSizeM, UIDefine.BrownColor)
    local bg = GUI.ImageCreate(guardLevel, "bg", "1800700010", 103, 0, false, 235, 33)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Left)
    local txt = GUI.CreateStatic(bg, "txt", "1", 0, 0, 330, 30, "system", true)
    _gt.BindName(txt, "guardLevel")
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    --侍从战力
    local guardPower = GUI.CreateStatic(guard_Bg, "guardPower", "战        力", 425, -54, 200, 30)
    UILayout.SetSameAnchorAndPivot(guardPower, UILayout.BottomLeft)

    UILayout.StaticSetFontSizeColorAlignment(guardPower, UIDefine.FontSizeM, UIDefine.BrownColor)
    local bg = GUI.ImageCreate(guardPower, "bg", "1800700010", 103, 0, false, 235, 33)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Left)
    local txt = GUI.CreateStatic(bg, "txt", "46880", 0, 0, 330, 30, "system", true)
    _gt.BindName(txt, "guardFightValue")
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)

    local model_Bg = GUI.ImageCreate(guard_Bg, "model_Bg", "1800400230", 0, 125)
    _gt.BindName(model_Bg, "model_Bg")
    UILayout.SetSameAnchorAndPivot(model_Bg, UILayout.Top)

    -- CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "GetUseBattleArray") -- 请求服务器端绑定侍从上阵数据 GuardUI.BattleArrayList

    --创建左侧侍从列表
    GuardUI.CreateLeftScr()

    CL.RegisterMessage(GM.GuardUpdate, "GuardUI", "OnGuardUpdate")

end

-- 属性页签按钮点击事件
function GuardUI.OnAttrTabBtnClick()
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[1][1])
    local Level = MainUI.MainUISwitchConfig["侍从"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        UILayout.OnTabClick(1, tabList) -- 切换到属性标签页时，高亮按钮，其他页签变暗

        GuardUI.Right_RefreshMethod(1)
        --GuardUI.TabIndex = 1
        -- 刷新下属性和技能上面的按钮小红点
        GuardUI.OnSelectGuardAttr()
        GuardUI.OnGuardAttr_BtnClick()
        -- GuardUI.ShowGuardDetailInfo()
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, tostring(Level) .. "级开启" .. Key .. "功能")
        UILayout.OnTabClick(GuardUI.TabIndex, tabList)
        return
    end
    GuardUI.TeamReset()
end

-- 小红点数据
GuardUI.red_point_data = nil
-- 打开页面时，请求小红点数据
function GuardUI._request_red_point()
    GlobalProcessing.get_guard_red_point_data(GuardUI._red_point_callback, 'GuardUI')
end

-- 请求小红点数据后回调函数
function GuardUI._red_point_callback(data)
    GuardUI.red_point_data = data
    --local inspect = require('inspect')
    --CDebug.LogError(inspect(GuardUI.red_point_data))
    -- 如果未打开界面，不要执行刷新
    local wnd = GUI.GetWnd('GuardUI')
    if not GUI.GetVisible(wnd) then
        return
    end

    -- 如果是打开页面时
    if GuardUI.FirstSelectFlag then
        GuardUI.UpdateGuardLst()

        --默认显示属性
        GuardUI.TabIndex = 1
        UILayout.OnTabClick(GuardUI.TabIndex, tabList)

        -- 防止打开侍从加成页面后关闭，再次打开时还是显示侍从加成页面
        GuardUI.Right_RefreshMethod(GuardUI.TabIndex)

        -- 侍从种类小红点
        local rightTitle_Bg = _gt.GetUI('rightTitle_Bg')
        --local scr_GuardType_Bg = _gt.GetUI('scr_GuardType_Bg')
        --local scr_GuardType = GUI.GetChild(scr_GuardType_Bg,'scr_GuardType')
        if GuardUI.red_point_data and GuardUI.red_point_data.kind_red_point then
            -- "全部" 是否显示小红点
            local is_show = false
            for k, v in ipairs(GuardUI.red_point_data.kind_red_point) do
                -- 下拉列表中的全部 下标是0，所以从1开始可以略过全部
                --local guard_type = GUI.GetChild(scr_GuardType,tostring(k))
                --GlobalProcessing.SetRetPoint(guard_type, v,UIDefine.red_type.common)
                --is_show = is_show or v
                if v == true then
                    is_show = v
                    break
                end
            end
            -- 设置 '全部' 是否显示小红点
            GlobalProcessing.SetRetPoint(rightTitle_Bg, is_show, UIDefine.red_type.common)
            -- 下拉列表中的'全部'选项添加小红点
            --local guard_type = GUI.GetChild(scr_GuardType,tostring(0))
            --GlobalProcessing.SetRetPoint(guard_type, is_show,UIDefine.red_type.common)
            --GUI.SetRedPointVisable(rightTitle_Bg, false)
        end

        -- 右边页签小红点 x,得放到其他地方

    else
        -- 刷新整个页面

        -- 侍从种类小红点
        local rightTitle_Bg = _gt.GetUI('rightTitle_Bg')
        --local scr_GuardType_Bg = _gt.GetUI('scr_GuardType_Bg')
        --local scr_GuardType = GUI.GetChild(scr_GuardType_Bg,'scr_GuardType')
        if GuardUI.red_point_data and GuardUI.red_point_data.kind_red_point then
            -- "全部" 是否显示小红点
            local is_show = false
            for k, v in ipairs(GuardUI.red_point_data.kind_red_point) do
                --local guard_type = GUI.GetChild(scr_GuardType,tostring(k))
                --GlobalProcessing.SetRetPoint(guard_type, v,UIDefine.red_type.common)
                --is_show = is_show or v
                if v == true then
                    is_show = v
                    break
                end
            end
            -- 设置 '全部' 是否显示小红点
            GlobalProcessing.SetRetPoint(rightTitle_Bg, is_show, UIDefine.red_type.common)
            -- 下拉列表中的'全部'选项添加小红点
            --local guard_type = GUI.GetChild(scr_GuardType,tostring(0))
            --GlobalProcessing.SetRetPoint(guard_type, is_show,UIDefine.red_type.common)
            --GUI.SetRedPointVisable(rightTitle_Bg, is_show)
        end

        -- 刷新右边页签
        if GuardUI.SelectGuardID and GuardUI.SelectGuardID ~= 0 then
            GuardUI._refresh_bookmark_red(GuardUI.SelectGuardID)
        end

        -- 刷新左边侍从列表
        local scr_Guard = _gt.GetUI("scr_Guard")
        GUI.LoopScrollRectRefreshCells(scr_Guard)

        -- 刷新属性页签中的部分内容
        GuardUI.OnSelectGuardAttr()
        -- 上面方法会显示侍从属性技能界面，需要判断下并隐藏界面
        if GuardUI.TabIndex ~= 1 then
            local guardArr_Right = _gt.GetUI("guardArr_Right")    --属性页
            GUI.SetVisible(guardArr_Right, false)
        end

    end

end

-- 打开窗口传入的参数
GuardUI.open_parameter = nil
function GuardUI.OnShow(parameter)
    GuardUI.SelectGuardID = 0
    GuardUI.PreSelectGuardBtn = nil
    GuardUI.PreSelectGuardID = 0
    GuardUI.FirstSelectFlag = true
    GuardUI.SelectType = 0 --手动选择的分类
    GuardUI._DestroyRoleEffectTable = {}

    GuardUI.open_parameter = parameter

    local wnd = GUI.GetWnd('GuardUI')
    if wnd then
        GUI.SetVisible(wnd, true)
    end

    -- 请求小红点数据
    GuardUI._request_red_point()
end

-- 根据传入的参数 跳转到对应页签
function GuardUI._open_tab_index(parameter)
    if parameter then
        local index_1 = UIDefine.GetParameter1(parameter)
        if index_1 == 1 then
            local index_2 = UIDefine.GetParameter2(parameter)
            -- 跳转到侍从属性界面
            if index_2 == 1 then
                --GuardUI.OnGuardAttr_BtnClick()
                -- 跳转到侍从技能页面
            elseif index_2 == 2 then
                GuardUI.OnGuardSkill_BtnClick()
            end

            -- 跳转到升星页面
        elseif index_1 == 2 then
            GuardUI.OnTrainTabBtnClick()
            -- 跳转到情缘页面
        elseif index_1 == 3 then
            GuardUI.OnLoveTabBtnClick()
            -- 跳转到加成页面
        elseif index_1 == 4 then
            GuardUI.OnAddAttrTabBtnClick()
            -- 跳转到阵法界面
        elseif index_1 == 5 then
            GuardUI.OnTeamTabBtnClick()
        end
    end

end

function GuardUI.OnDestroy()
    CL.UnRegisterMessage(GM.GuardUpdate, "GuardUI", "OnGuardUpdate")
end
-- 发送客户端请求后，执行的回调函数
function GuardUI.OnGuardUpdate(type, id, p0, p1)
    test("GuardUI.OnGuardUpdate type is " .. tostring(type))

    --增加了侍从
    if type == 1 then
        GuardUI.PreSelectGuardID = 0
        GuardUI.UpdateGuardLst()
        --GuardUI.ShowHaveGuardInfo() -- 上一个方法内已经执行了
        if GuardUI.PreSelectGuardBtn then
            GuardUI.OnLeftGuardBtnClick(GUI.GetGuid(GuardUI.PreSelectGuardBtn))
        end
    elseif type == 4 then
        --用4号综合的消息替代2号每次更新的消息，以减少每个都需要刷新的情况

        --id 是侍从ID, p0是属性ID, p1是属性值（字符串）
        --GuardUI.SortedGuardIDLst = LD.GetGuardList_Have_Sorted()
        --GuardUI.UpdateGuardScrollListData()
        GuardUI.UpdateGuardLst()

        -- 将上阵的侍从id转换为guid然后发送给服务器
        local LineUp_guard = {} -- 上阵侍从的guid表
        for i = 0, GuardUI.SortedGuardIDLst.Count - 1 do
            if tostring(LD.GetGuardAttr(GuardUI.SortedGuardIDLst[i], RoleAttr.GuardAttrIsLinup)) == "1" then
                -- 判断是否已经上阵
                -- 将上阵的侍从ID存储下来
                local guard_guid = LD.GetGuardGUIDByID(GuardUI.SortedGuardIDLst[i])
                table.insert(LineUp_guard, guard_guid or 0)
            end
        end
        GuardUI.OnlineGuardLists = LineUp_guard

        -- 将上阵数据发送给服务器端
        --CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "SetUseBattleArray",tostring(LineUp_guard[1] or 0),tostring(LineUp_guard[2] or 0),tostring(LineUp_guard[3] or 0),tostring(LineUp_guard[4] or 0))

    elseif type == 3 then
        if p0 == "Guard_Star" then
            -- 参数分别为 3，侍从id，自定义变量key，自定义变量value
            GuardUI.GetGuardUpStartData()
            GuardUI.RefreshSkillPage()
            --GuardUI.UpdateGuardScrollListData()
            GuardUI.UpdateGuardLst()
            GuardUI.ShowGuardDetailInfo()

            -- 执行GuardUI.ShowGuardDetailInfo()后会显示休息和出战按钮，虽然被挡住但是可以点击，得隐藏掉
            -- 属性界面也会显示出来,全都隐藏掉
            if GuardUI.TabIndex ~= 1 then
                -- local guardAttr_Bg= _gt.GetUI("guardAttr_Bg")
                -- local restBtn = GUI.GetChild(guardAttr_Bg,"restBtn")
                -- local fightBtn = GUI.GetChild(guardAttr_Bg,"fightBtn")
                -- GUI.SetVisible(restBtn,false)
                -- GUI.SetVisible(fightBtn,false)
                local guardArr_Right = _gt.GetUI("guardArr_Right")    --属性页
                GUI.SetVisible(guardArr_Right, false)
            end

        end
    end
end

-- 未使用
function GuardUI.UpdateGuardScrollListData()
    if GuardUI.SortedGuardIDLst then
        local Count = GuardUI.SortedGuardIDLst.Count
        local scr_Guard = _gt.GetUI("scr_Guard")
        GUI.LoopScrollRectSetTotalCount(scr_Guard, Count)
        GUI.LoopScrollRectRefreshCells(scr_Guard)
    end
end

-- 显示侍从拥有数量/总数量
function GuardUI.ShowHaveGuardInfo()
    local haveLst = LD.GetActivedGuard()
    local haveCount = haveLst and haveLst.Count or 0

    local allCount = nil
    -- 如果侍从种类不是全部
    if GuardUI.SortedGuardIDLst and GuardUI.SortedGuardIDLst.Count ~= 0 and GuardUI.SelectType ~= 0 then
        allCount = GuardUI.SortedGuardIDLst.Count

        -- 计算此种类侍从拥有的数量
        local count = 0
        for i = 0, haveCount - 1 do
            local guard = DB.GetOnceGuardByKey1(haveLst[i])
            if guard.Id ~= 0 and guard.Type and guard.Type == GuardUI.SelectType then
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

--创建左侧侍从滑动列表
function GuardUI.CreateLeftScr(...)
    local guard_Bg = _gt.GetUI("guard_Bg")
    local scr_Bg = GUI.ImageCreate(guard_Bg, "scr_Bg", "1800400010", 63, 40, false, 345, 575)
    UILayout.SetSameAnchorAndPivot(scr_Bg, UILayout.TopLeft)

    local model_Bg = _gt.GetUI("model_Bg")
    local childCount = GUI.GetChildCount(guard_Bg)

    local leftTitle_Bg = GUI.ImageCreate(scr_Bg, "leftTitle_Bg", "1800700250", 4, 4)
    UILayout.SetSameAnchorAndPivot(leftTitle_Bg, UILayout.TopLeft)
    local scr_Name = GUI.CreateStatic(leftTitle_Bg, "scr_Name", "我的侍从", 20, 0, 200, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(scr_Name, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_Name, UIDefine.FontSizeS, UIDefine.BrownColor)
    local scr_GuardCount = GUI.CreateStatic(leftTitle_Bg, "haveGuardCount", "0/99", 140, 1, 200, 30)
    _gt.BindName(scr_GuardCount, "haveGuardCount")
    UILayout.SetSameAnchorAndPivot(scr_GuardCount, UILayout.Right)
    UILayout.StaticSetFontSizeColorAlignment(scr_GuardCount, UIDefine.FontSizeS, UIDefine.BrownColor)
    GuardUI.ShowHaveGuardInfo()

    --创建侍从列表
    local scr_Guard = GUI.LoopScrollRectCreate(scr_Bg, "scr_Guard", 0, 41, 330, 525,
            "GuardUI", "CreatGuardItemPool", "GuardUI", "RefreshGuardScroll", 0, false, Vector2.New(330, 100), 1, UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(scr_Guard, Vector2.New(6, 6))
    _gt.BindName(scr_Guard, "scr_Guard")
    UILayout.SetSameAnchorAndPivot(scr_Guard, UILayout.Top)

    local rightTitle_Bg = GUI.ButtonCreate(scr_Bg, "rightTitle_Bg", "1800700260", -4, 4, Transition.None)
    UILayout.SetSameAnchorAndPivot(rightTitle_Bg, UILayout.TopRight)
    GUI.RegisterUIEvent(rightTitle_Bg, UCE.PointerClick, "GuardUI", "OnPullListBtnClick")
    -- 添加小红点
    --GUI.AddRedPoint(rightTitle_Bg,UIAnchor.TopLeft,10,10)
    --GUI.SetRedPointVisable(rightTitle_Bg,false)
    _gt.BindName(rightTitle_Bg, 'rightTitle_Bg')

    local pullListBtn = GUI.ImageCreate(rightTitle_Bg, "pullListBtn", "1800707070", 12, 0)
    UILayout.SetSameAnchorAndPivot(pullListBtn, UILayout.Right)
    GUI.SetIsRaycastTarget(pullListBtn, false)

    local scr_GuardType_Txt = GUI.CreateStatic(rightTitle_Bg, "scr_GuardType_Txt", "全部", -15, 0, 200, 30)
    _gt.BindName(scr_GuardType_Txt, "scr_GuardType_Txt")
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Txt, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_GuardType_Txt, UIDefine.FontSizeS, UIDefine.BrownColor)

    --创建侍从类型按钮选择列表
    local scr_GuardType_Bg = GUI.ImageCreate(rightTitle_Bg, "scr_GuardType_Bg", "1800400290", 0, 36, false, 115, 215)
    _gt.BindName(scr_GuardType_Bg, "scr_GuardType_Bg")
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Bg, UILayout.Top)
    GUI.SetVisible(scr_GuardType_Bg, false)
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
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardUI", "OnGuardTypeBtnClick")
        GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeS)
        --GUI.SetData(btn, "index", index)
        if not GuardUI.kind_select_data then
            GuardUI.kind_select_data = {}
        end
        GuardUI.kind_select_data[GUI.GetGuid(btn)] = index
    end

    -- 侍从种类小红点
    local rightTitle_Bg = _gt.GetUI('rightTitle_Bg')
    local scr_GuardType_Bg = _gt.GetUI('scr_GuardType_Bg')
    local scr_GuardType = GUI.GetChild(scr_GuardType_Bg, 'scr_GuardType')
    if GuardUI.red_point_data and GuardUI.red_point_data.kind_red_point then
        -- "全部" 是否显示小红点
        local is_show = false
        for k, v in ipairs(GuardUI.red_point_data.kind_red_point) do
            -- 下拉列表中的全部 下标是0，所以从1开始可以略过全部
            local guard_type = GUI.GetChild(scr_GuardType, tostring(k))
            --GUI.SetRedPointVisable(guard_type,v)
            GlobalProcessing.SetRetPoint(guard_type, v, UIDefine.red_type.common)
            is_show = is_show or v
        end
        -- 设置 '全部' 是否显示小红点
        GlobalProcessing.SetRetPoint(rightTitle_Bg, is_show, UIDefine.red_type.common)
        -- 下拉列表中的'全部'选项添加小红点
        local guard_type = GUI.GetChild(scr_GuardType, tostring(0))
        GlobalProcessing.SetRetPoint(guard_type, is_show, UIDefine.red_type.common)
        --GUI.SetRedPointVisable(rightTitle_Bg, false)
    end

end

function GuardUI.OnPullListBtnClick()
    local scr_GuardType_Bg = _gt.GetUI("scr_GuardType_Bg")
    if scr_GuardType_Bg then
        GUI.SetVisible(scr_GuardType_Bg, not GUI.GetVisible(scr_GuardType_Bg))
    else
        local rightTitle_Bg = _gt.GetUI('rightTitle_Bg')
        --创建侍从类型按钮选择列表
        local scr_GuardType_Bg = GUI.ImageCreate(rightTitle_Bg, "scr_GuardType_Bg", "1800400290", 0, 36, false, 115, 215)
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
            GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardUI", "OnGuardTypeBtnClick")
            GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeS)
            if not GuardUI.kind_select_data then
                GuardUI.kind_select_data = {}
            end
            GuardUI.kind_select_data[GUI.GetGuid(btn)] = index
        end

        -- 侍从种类小红点
        local rightTitle_Bg = _gt.GetUI('rightTitle_Bg')
        local scr_GuardType_Bg = _gt.GetUI('scr_GuardType_Bg')
        local scr_GuardType = GUI.GetChild(scr_GuardType_Bg, 'scr_GuardType')
        if GuardUI.red_point_data and GuardUI.red_point_data.kind_red_point then
            -- "全部" 是否显示小红点
            local is_show = false
            for k, v in ipairs(GuardUI.red_point_data.kind_red_point) do
                -- 下拉列表中的全部 下标是0，所以从1开始可以略过全部
                local guard_type = GUI.GetChild(scr_GuardType, tostring(k))
                --GUI.SetRedPointVisable(guard_type,v)
                GlobalProcessing.SetRetPoint(guard_type, v, UIDefine.red_type.common)
                is_show = is_show or v
            end
            -- 设置 '全部' 是否显示小红点
            GlobalProcessing.SetRetPoint(rightTitle_Bg, is_show, UIDefine.red_type.common)
            -- 下拉列表中的'全部'选项添加小红点
            local guard_type = GUI.GetChild(scr_GuardType, tostring(0))
            GlobalProcessing.SetRetPoint(guard_type, is_show, UIDefine.red_type.common)
            --GUI.SetRedPointVisable(rightTitle_Bg, false)
        end

    end
end

-- 侍从种类按钮点击事件
function GuardUI.OnGuardTypeBtnClick(guid)
    if next(GuardUI.kind_select_data) == nil then
        test('GuardUI侍从界面 GuardUI.OnGuardTypeBtnClick(guid)方法 缺少GuardUI.kind_select_data参数')
        return ''
    end
    local index = GuardUI.kind_select_data[guid]
    if index == nil then
        test('GuardUI侍从界面 GuardUI.OnGuardTypeBtnClick(guid)方法 缺少GuardUI.kind_select_data[guid]参数')
        return ''
    end
    GuardUI.FirstSelectFlag = true
    --local btn = GUI.GetByGuid(guid)
    --local index = GUI.GetData(btn, "index")
    GuardUI.SelectType = tonumber(index)
    GuardUI.TeamMember_Add_Icon_Click = 0               --取消阵容选择状态
    GuardUI.TeamMember_Choosing = 0                        --取消阵容选择状态
    GuardUI.UpdateGuardLst()
    --关闭选择面板显示
    --GuardUI.OnPullListBtnClick()
    local scr_GuardType_Txt = _gt.GetUI("scr_GuardType_Txt")
    if scr_GuardType_Txt then
        GUI.StaticSetText(scr_GuardType_Txt, GuardUI.SelectType == 0 and guardType[#guardType][1] or guardType[GuardUI.SelectType][1])
        -- 切换按钮后，判断是否显示小红点
        local rightTitle_Bg = _gt.GetUI('rightTitle_Bg') -- 全部位置的按钮
        if GuardUI.red_point_data and GuardUI.red_point_data.kind_red_point then
            if GuardUI.SelectType == 0 then
                local is_show = false
                for k, v in ipairs(GuardUI.red_point_data.kind_red_point) do
                    is_show = is_show or v
                end
                --GUI.SetRedPointVisable(rightTitle_Bg, is_show)
                GlobalProcessing.SetRetPoint(rightTitle_Bg, is_show, UIDefine.red_type.common)
            else
                --GUI.SetRedPointVisable(rightTitle_Bg, GuardUI.red_point_data.kind_red_point[GuardUI.SelectType])
                GlobalProcessing.SetRetPoint(rightTitle_Bg, GuardUI.red_point_data.kind_red_point[GuardUI.SelectType], UIDefine.red_type.common)
            end
        end
    end

end
-- 刷新左侧侍从列表
function GuardUI.UpdateGuardLst()
    GuardUI.SortedGuardIDLst = LD.GetGuardList_Have_Sorted()
    --过滤手动筛选
    if GuardUI.SelectType ~= 0 then
        local SelectGuardIDs = {}
        local Count0 = GuardUI.SortedGuardIDLst.Count
        local index = 0
        for i = 0, Count0 - 1 do
            local config = DB.GetOnceGuardByKey1(GuardUI.SortedGuardIDLst[i])
            if config and config.Type == GuardUI.SelectType then
                SelectGuardIDs[index] = GuardUI.SortedGuardIDLst[i]
                index = index + 1
            end
        end
        SelectGuardIDs.Count = index
        GuardUI.SortedGuardIDLst = {}
        GuardUI.SortedGuardIDLst = SelectGuardIDs
    else
        local txt = _gt.GetUI('scr_GuardType_Txt')
        GUI.StaticSetText(txt, '全部')
    end



    -- 在首次打开页面时 刷新右边页签小红点
    if GuardUI.FirstSelectFlag then
        GuardUI._refresh_bookmark_red(GuardUI.SortedGuardIDLst[0])
    end

    local Count = GuardUI.SortedGuardIDLst.Count
    local scr_Guard = _gt.GetUI("scr_Guard")
    GUI.LoopScrollRectSetTotalCount(scr_Guard, Count)
    GUI.LoopScrollRectRefreshCells(scr_Guard)

    -- 更新显示的数量
    GuardUI.ShowHaveGuardInfo()
end

--创建左侧侍从滑动列表Btn
function GuardUI.CreatGuardItemPool()
    local scr_Guard = _gt.GetUI("scr_Guard")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scr_Guard)
    local btn = GUI.ButtonCreate(scr_Guard, "item" .. tostring(curCount), "1800700030", 0, 0, Transition.ColorTint, "", 330, 100, false)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardUI", "OnLeftGuardBtnClick")

    local btnSelectImage = GUI.ImageCreate(btn, "btnSelectImage", "1800700040", 0, 0, false, 330, 100)
    GUI.SetVisible(btnSelectImage, false)
    local icon_Bg = GUI.ImageCreate(btn, "icon_Bg", "1800201110", 10, 0)
    UILayout.SetSameAnchorAndPivot(icon_Bg, UILayout.Left)

    local icon = GUI.ImageCreate(icon_Bg, "icon", "", 0, -1, false, 71, 71)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Center)
    -- 添加小红点
    --GUI.AddRedPoint(icon,UIAnchor.TopLeft,-4,-5)
    --GUI.SetRedPointVisable(icon,false)

    local fightIcon = GUI.ImageCreate(btn, "fightIcon", "1800707010", 0, 0)
    UILayout.SetSameAnchorAndPivot(fightIcon, UILayout.TopLeft)
    GUI.SetVisible(fightIcon, false)

    local Up_Arrow = GUI.ImageCreate(icon, "Up_Arrow", "1800707350", 0, 0, false, 50, 50)        --4.15新加
    GUI.SetVisible(Up_Arrow, true)

    --显示升星上限
    for i = 1, GUARD_MAX_STAR do
        local star = GUI.ImageCreate(btn, "star" .. tostring(i), "1801202192", 104 + 26 * (i - 1), 60, false, 22, 22)
        UILayout.SetSameAnchorAndPivot(star, UILayout.TopLeft)
    end

    --侍从名字
    local guardName = GUI.CreateStatic(btn, "guardName", "", 105, 20, 220, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(guardName, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(guardName, UIDefine.FontSizeL, UIDefine.BrownColor)

    --侍从类型图
    local guardType_Sprite = GUI.ImageCreate(btn, "guardType_Sprite", "", -8, 5)
    UILayout.SetSameAnchorAndPivot(guardType_Sprite, UILayout.TopRight)

    --侍从稀有度
    local guardQuality_Sprite = GUI.ImageCreate(btn, "guardQuality_Sprite", "", 238, 10)
    UILayout.SetSameAnchorAndPivot(guardQuality_Sprite, UILayout.TopLeft)

    return btn
end
-- 刷新左边侍从列表
function GuardUI.RefreshGuardScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])

    -- 防止越界错误
    if index > GuardUI.SortedGuardIDLst.Count or GuardUI.SortedGuardIDLst.Count == 0 then
        GuardUI.SortedGuardIDLst = LD.GetGuardList_Have_Sorted()

        --过滤手动筛选
        if GuardUI.SelectType ~= 0 then
            local SelectGuardIDs = {}
            local Count0 = GuardUI.SortedGuardIDLst.Count
            local index = 0
            for i = 0, Count0 - 1 do
                local config = DB.GetOnceGuardByKey1(GuardUI.SortedGuardIDLst[i])
                if config and config.Type == GuardUI.SelectType then
                    SelectGuardIDs[index] = GuardUI.SortedGuardIDLst[i]
                    index = index + 1
                end
            end
            SelectGuardIDs.Count = index
            GuardUI.SortedGuardIDLst = {}
            GuardUI.SortedGuardIDLst = SelectGuardIDs
        else
            local txt = _gt.GetUI('scr_GuardType_Txt')
            GUI.StaticSetText(txt, '全部')
        end
    end

    local config = DB.GetOnceGuardByKey1(GuardUI.SortedGuardIDLst[index])
    local btn = GUI.GetByGuid(guid)
    if GuardUI.PreSelectGuardBtn == btn then
        GuardUI.PreSelectGuardBtn = nil
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
        -- 判断是否显示小红点
        if GuardUI.red_point_data and GuardUI.red_point_data.guard_reds and GuardUI.red_point_data.guard_reds[tostring(config.Id)] then
            local red_data = GuardUI.red_point_data.guard_reds[tostring(config.Id)]
            -- 如果拥有此侍从
            if red_data.is_activation then

                local is_show = red_data.can_up_attr_level or
                        red_data.can_up_love_skill or
                        red_data.can_up_skill or
                        red_data.can_up_star

                --GUI.SetRedPointVisable(icon, is_show)
                GlobalProcessing.SetRetPoint(icon, is_show, UIDefine.red_type.icon)
            else
                --GUI.SetRedPointVisable(icon,red_data.can_activation)
                GlobalProcessing.SetRetPoint(icon, red_data.can_activation, UIDefine.red_type.icon)
            end
        end
    end
    local guardName = GUI.GetChildByPath(btn, "guardName")
    if guardName then
        GUI.StaticSetText(guardName, config.Name)
    end
    local fightIcon = GUI.GetChildByPath(btn, "fightIcon")
    local Up_Arrow = GUI.GetChildByPath(icon, "Up_Arrow")
    if fightIcon then
        GUI.SetVisible(fightIcon, tostring(LD.GetGuardAttr(config.Id, RoleAttr.GuardAttrIsLinup)) == "1")
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
    if GuardUI.SelectGuardID == config.Id then
        GuardUI.PreSelectGuardBtn = btn
        GUI.ButtonSetImageID(btn, "1800700040")
    else
        GUI.ButtonSetImageID(btn, not isHave and "1800700180" or "1800700030")
    end

    local TeamTab_Main = _gt.GetUI("TeamTab_Main")
    local Check_Whether_Guard_IsOn = GUI.GetData(TeamTab_Main, "Check_Whether_Guard_IsOn" .. tostring(config.Id))
    --test("=================Check_Whether_Guard_IsOn = "..Check_Whether_Guard_IsOn)
    if isHave == true and GuardUI.TeamMember_Choosing == 1 and Check_Whether_Guard_IsOn == "0" then
        --4.20
        GUI.SetVisible(Up_Arrow, true)
    else
        GUI.SetVisible(Up_Arrow, false)
    end

    local curStar = isHave and CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardUI.SortedGuardIDLst[index]))) or 0
    for i = 1, GUARD_MAX_STAR do
        local star = GUI.GetChildByPath(btn, "star" .. tostring(i))
        GUI.ImageSetImageID(star, curStar >= i and "1801202190" or "1801202192")
    end

    if GuardUI.FirstSelectFlag then
        --   删除判断条件  index == 0 and  理由：当我开始就选中第一个时，滚动，刷新到了第0个，就执行这段代码，导致不合我的逻辑
        GuardUI.FirstSelectFlag = false
        GuardUI.OnLeftGuardBtnClick(guid)
    end

    -- 当前刷新整个页面完成时，跳转到对应的页签
    if index == 4 and GuardUI.open_parameter then
        GuardUI._open_tab_index(GuardUI.open_parameter)
        GuardUI.open_parameter = nil
    end

end
-- 点击左边侍从列表事件
function GuardUI.OnLeftGuardBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    GuardUI.SelectGuardID = tonumber(GUI.GetData(btn, "guardID"))

    if GuardUI.PreSelectGuardID ~= GuardUI.SelectGuardID then
        -- 如果前一次选中侍从ID不等于当前选中的侍从ID
        --当前选中对象
        if GuardUI.PreSelectGuardBtn then
            local id = tonumber(GUI.GetData(GuardUI.PreSelectGuardBtn, "guardID")) -- 获取当前按钮存储侍从的ID
            if LD.IsHaveGuard(id) then
                GUI.ButtonSetImageID(GuardUI.PreSelectGuardBtn, "1800700030") --如果拥有此侍从，修改按钮的颜色
            else
                GUI.ButtonSetImageID(GuardUI.PreSelectGuardBtn, "1800700180")
            end
        end
        if btn then
            GUI.ButtonSetImageID(btn, "1800700040")
            GuardUI.PreSelectGuardBtn = btn
        end

        -- 联动部分
        -- 侍从属性页面
        if GuardUI.TabIndex == 1 then
            -- 如果当前页面是侍从属性页面
            GuardUI.OnSelectGuardAttr()
            GuardUI.ShowGuardDetailInfo()
            GuardUI.RefreshSkillPage()  -- 刷机技能页面
        end
        -- 升星页面
        if GuardUI.TabIndex == 2 then
            GuardUI.ShowGuardDetailInfo()
            GuardUI.OnTrainTabBtnClick()
        end
        -- 阵容页面
        if GuardUI.TabIndex == 5 then
            GuardUI.ShowGuardDetailInfo()
        end
        -- 情缘页面
        if GuardUI.TabIndex == 3 then
            GuardUI.ShowGuardDetailInfo()
            GuardUI.OnLoveTabBtnClick()
        end

    end

    local Guard_Guid = LD.GetGuardGUIDByID(GuardUI.SelectGuardID)
    for i = 1, 3 do
        --4.16
        for j = 1, 4 do
            --4.16
            local TeamMember_Add_Icon_Choice = _gt.GetUI("TeamMember_Add_Icon_Choice" .. i .. j)                --4.16
            local TeamMember_Add_Icon_Choice_Cancel = _gt.GetUI("TeamMember_Add_Icon_Choice_Cancel" .. i .. j)    --4.16
            local Change_Arrow = _gt.GetUI("Change_Arrow" .. i .. j)                                            --4.16
            GUI.SetVisible(TeamMember_Add_Icon_Choice, false)                                                --4.16
            GUI.SetVisible(TeamMember_Add_Icon_Choice_Cancel, false)                                        --4.16
            GUI.SetVisible(Change_Arrow, false)                                                                --4.16
        end                                                                                                    --4.16
    end                                                                                                        --4.16
    if GuardUI.TeamMember_Choosing == 1 then
        --如果处于选择中，那么点击左侧侍从会记录Guid         --4.16
        GuardUI.Left_Chose_Guard_Guid = Guard_Guid
        GuardUI.Loop_Item_Refresh_Lite()        --4.16
        GuardUI.TeamTab_Bar_AddTeamGuard_Finish()                                                           --4.16
    else
        --4.16
        GuardUI.Left_Chose_Guard_Guid = nil                                                                 --4.16
    end                                                                                                     --4.16

    GuardUI.TeamMember_Add_Icon_Click = 0                                                                   --4.16

    if GuardUI.TeamMember_Choosing == 1 then
        --4.16
        GuardUI.TeamMember_Choosing = 0                                                                    --4.16
    end                                                                 --4.16

    -- 刷新右边页签的小红点
    GuardUI._refresh_bookmark_red(GuardUI.SelectGuardID)

end
-- 显示侍从中间形象和右边属性
function GuardUI.ShowGuardDetailInfo()
    local _RoleLstNodeModel = _gt.GetUI("RoleLstNodeModel")
    if _RoleLstNodeModel == nil then
        local model_Bg = _gt.GetUI("model_Bg")
        _RoleLstNodeModel = GUI.RawImageCreate(model_Bg, false, "RoleLstNodeModel", "", 0, -71, 2, false, 392, 392)
        _gt.BindName(_RoleLstNodeModel, "RoleLstNodeModel")
        _RoleLstNodeModel:RegisterEvent(UCE.Drag)
        _RoleLstNodeModel:RegisterEvent(UCE.PointerClick)
        GUI.AddToCamera(_RoleLstNodeModel)
        GUI.RawImageSetCameraConfig(_RoleLstNodeModel, "(0,1.41,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,10,0.01,1.2,0")
    end

    --模型
    local guardDB = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)
    local _RoleModel = _gt.GetUI("GuardModel")
    if _RoleModel == nil then
        _RoleModel = GUI.RawImageChildCreate(_RoleLstNodeModel, false, "GuardModel" .. tostring(GuardUI.SelectGuardID), "", 0, 666)
        _gt.BindName(_RoleModel, "GuardModel")
        UILayout.SetSameAnchorAndPivot(_RoleModel, UILayout.Center)
        ModelItem.Bind(_RoleModel, guardDB.Model, guardDB.ColorID1, guardDB.ColorID2, eRoleMovement.ATTSTAND_W1)
        _gt.BindName(_RoleModel, "GuardModel" .. tostring(GuardUI.SelectGuardID))
        GUI.BindPrefabWithChild(_RoleLstNodeModel, GUI.GetGuid(_RoleModel))
        GUI.RawImageChildSetModleRotation(_RoleModel, Vector3.New(0, -45, 0))
        GUI.RegisterUIEvent(_RoleModel, ULE.AnimationCallBack, "GuardUI", "OnAnimationCallBack")
    else
        ModelItem.Bind(_RoleModel, guardDB.Model, guardDB.ColorID1, guardDB.ColorID2, eRoleMovement.ATTSTAND_W1)
        GUI.RawImageChildSetModleRotation(_RoleModel, Vector3.New(0, -45, 0))
    end
    -- 添加人物特效
    GuardUI.addRoleEffect()
    GuardUI.PreSelectGuardID = GuardUI.SelectGuardID

    local _ModelClickPic = _gt.GetUI("ModelClickPic")
    if _ModelClickPic == nil then
        _ModelClickPic = GUI.ImageCreate(_RoleLstNodeModel, "ModelClickPic", "1800499999", 0, 0, false, 392, 392)
        _gt.BindName(_ModelClickPic, "ModelClickPic")
        UILayout.SetSameAnchorAndPivot(_ModelClickPic, UILayout.Center)
        GUI.SetIsRaycastTarget(_ModelClickPic, true)
        _ModelClickPic:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(_ModelClickPic, UCE.PointerClick, "GuardUI", "OnClickGuardModel")
    end

    local isHaveGuard = LD.IsHaveGuard(guardDB.Id)
    local curLevel = isHaveGuard and CL.GetIntAttr(RoleAttr.RoleAttrLevel) or 1
    local curStar = isHaveGuard and CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardUI.SelectGuardID))) or 0
    for i = 1, GUARD_MAX_STAR do
        local star = _gt.GetUI("starPic" .. tostring(i))
        GUI.ImageSetImageID(star, curStar >= i and "1801202190" or "1801202192")
    end
    local txt = _gt.GetUI("guardName")
    if txt then
        GUI.StaticSetText(txt, guardDB.Name)
    end
    local txt = _gt.GetUI("guardLevel")
    if txt then
        GUI.StaticSetText(txt, tostring(curLevel) .. "级")
    end
    local txt = _gt.GetUI("guardFightValue")
    if txt then
        GUI.StaticSetText(txt, isHaveGuard and tostring(LD.GetGuardAttr(guardDB.Id, RoleAttr.RoleAttrFightValue)) or "待激活")
    end
    local pic = _gt.GetUI("middle_GuardRarity_Sprite")
    if pic then
        GUI.ImageSetImageID(pic, quality[guardDB.Quality][1])
    end
    local pic = _gt.GetUI("middle_GuardType_Sprite")
    if pic then
        GUI.ImageSetImageID(pic, guardType[guardDB.Type][2])
    end
    local itemConfig = DB.GetOnceItemByKey1(guardDB.CallItemIcon)
    local pic = _gt.GetUI("guardIcon")
    if pic and itemConfig then
        if itemConfig.Icon ~= 0 then
            GUI.ImageSetImageID(pic, tostring(itemConfig.Icon))
        end
    end
    local haveCount = LD.GetItemCountById(guardDB.CallItemIcon, item_container_type.item_container_guard_bag)
    local txt = _gt.GetUI("guardTokenCount")
    if txt then
        GUI.StaticSetText(txt, tostring(haveCount) .. "/" .. tostring(guardDB.ItemNumber))
    end
    --显示属性
    local guardExtraConfig1 = DB.GetGuard_Extra(GuardUI.SelectGuardID, 1)
    local guardExtraConfigMax = DB.GetGuard_Extra(GuardUI.SelectGuardID, GUARD_MAX_LEVEL)
    if guardExtraConfig1 and guardExtraConfigMax then
        local GUARD_MAX_LEVEL_BASE = GUARD_MAX_LEVEL - 1
        if GUARD_MAX_LEVEL == 1 then
            GUARD_MAX_LEVEL_BASE = 1
        end
        local GuardAttrTbValue = {}
        local attrCount = #attrLst
        if not isHaveGuard then
            GuardAttrTbValue = { math.floor(guardExtraConfig1.PhyAtk + (guardExtraConfigMax.PhyAtk - guardExtraConfig1.PhyAtk) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
                                 math.floor(guardExtraConfig1.MagAtk + (guardExtraConfigMax.MagAtk - guardExtraConfig1.MagAtk) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
                                 math.floor(guardExtraConfig1.PhyDef + (guardExtraConfigMax.PhyDef - guardExtraConfig1.PhyDef) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
                                 math.floor(guardExtraConfig1.MagDef + (guardExtraConfigMax.MagDef - guardExtraConfig1.MagDef) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
                                 math.floor(guardExtraConfig1.PhyBurstLv + (guardExtraConfigMax.PhyBurstLv - guardExtraConfig1.PhyBurstLv) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
                                 math.floor(guardExtraConfig1.MagBurstLv + (guardExtraConfigMax.MagBurstLv - guardExtraConfig1.MagBurstLv) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
                                 math.floor(guardExtraConfig1.ResistanceLv + (guardExtraConfigMax.ResistanceLv - guardExtraConfig1.ResistanceLv) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
                                 math.floor(guardExtraConfig1.Resistance + (guardExtraConfigMax.Resistance - guardExtraConfig1.Resistance) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
                                 math.floor(guardExtraConfig1.Miss + (guardExtraConfigMax.Miss - guardExtraConfig1.Miss) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
                                 math.floor(guardExtraConfig1.Speed + (guardExtraConfigMax.Speed - guardExtraConfig1.Speed) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE),
            }
        else
            for i = 1, attrCount do
                table.insert(GuardAttrTbValue, tonumber(tostring(LD.GetGuardAttr(guardDB.Id, attrLst[i][1]))))
            end
        end
        for i = 1, attrCount do
            local sttrConfig = DB.GetOnceAttrByKey1(attrLst[i][2])
            if sttrConfig and sttrConfig.IsPct == 1 then
                GuardAttrTbValue[i] = tostring(math.floor(GuardAttrTbValue[i] / 100)) .. "%"
            end
        end

        for i = 1, attrCount do
            local attr_value = _gt.GetUI("attr_value" .. tostring(i))
            GUI.StaticSetText(attr_value, tostring(GuardAttrTbValue[i]))
        end
        --红蓝量
        local txt = _gt.GetUI("HPTxt")
        if txt then
            local num = 0
            if not isHaveGuard then
                num = math.floor(guardExtraConfig1.HP + (guardExtraConfigMax.HP - guardExtraConfig1.HP) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE)
            else
                num = LD.GetGuardAttr(guardDB.Id, RoleAttr.RoleAttrHpLimit)
            end
            GUI.StaticSetText(txt, tostring(num) .. "/" .. tostring(num))
        end
        local txt = _gt.GetUI("MPTxt")
        if txt then
            local num = 0
            if not isHaveGuard then
                num = math.floor(guardExtraConfig1.MP + (guardExtraConfigMax.MP - guardExtraConfig1.MP) * (curLevel - 1) / GUARD_MAX_LEVEL_BASE)
            else
                num = LD.GetGuardAttr(guardDB.Id, RoleAttr.RoleAttrMpLimit)
            end
            GUI.StaticSetText(txt, tostring(num) .. "/" .. tostring(num))
        end
    end
    --是否可邀请
    local inviteBtn = _gt.GetUI("inviteBtn")
    if inviteBtn then
        --GUI.ButtonSetShowDisable(inviteBtn,haveCount>=guardDB.ItemNumber)
        GuardUI.SelectGuardActived = haveCount >= guardDB.ItemNumber
        -- 是否显示小红点
        --GUI.SetRedPointVisable(inviteBtn,GuardUI.SelectGuardActived)
        GlobalProcessing.SetRetPoint(inviteBtn, GuardUI.SelectGuardActived, UIDefine.red_type.common)
    end

    --显示描述
    local guardSubTitle = _gt.GetUI("guardSubTitle")
    if guardSubTitle then
        GUI.StaticSetText(guardSubTitle, isHaveGuard and "侍从简介" or "收集信物")
    end

    local guardDesc = _gt.GetUI("guardDesc")
    if guardDesc then
        GUI.SetVisible(guardDesc, isHaveGuard)
        if isHaveGuard then
            GUI.StaticSetText(guardDesc, guardDB.Tips)
        end
    end

    local guardBottomBg = _gt.GetUI("guardBottomBg")
    if guardBottomBg then
        GUI.SetVisible(guardBottomBg, not isHaveGuard)
    end

    -- 侍从出战/休息按钮显示部分
    local guardAttr_Bg = _gt.GetUI("guardAttr_Bg")
    GUI.SetHeight(guardAttr_Bg, 540)
    local restBtn = GUI.GetChild(guardAttr_Bg, "restBtn")
    local fightBtn = GUI.GetChild(guardAttr_Bg, "fightBtn")
    -- 判断此时选中的侍从是否拥有
    if LD.IsHaveGuard(GuardUI.SelectGuardID) then
        GUI.SetHeight(guardAttr_Bg, 480)
        -- 判断是否已经上阵
        if tostring(LD.GetGuardAttr(GuardUI.SelectGuardID, RoleAttr.GuardAttrIsLinup)) == "1" then
            GUI.SetVisible(fightBtn, false)
            GUI.SetVisible(restBtn, true)
        else
            GUI.SetVisible(restBtn, false)
            GUI.SetVisible(fightBtn, true)
        end
    else
        GUI.SetVisible(restBtn, false)
        GUI.SetVisible(fightBtn, false)
    end

    -- 侍从命魂
    if is_open_soul_of_guard then
        local guard_soul_img = _gt.GetUI('guard_soul_img')
        if guard_soul_img == nil then
            local guard_Bg = _gt.GetUI("guard_Bg")
            guard_soul_img = GUI.ImageCreate(guard_Bg, "guard_soul_img", "1801719190", 145, 108)--,false,90,90)
            _gt.BindName(guard_soul_img, 'guard_soul_img')
            guard_soul_img:RegisterEvent(UCE.PointerClick)
            GUI.SetIsRaycastTarget(guard_soul_img, true)
            GUI.RegisterUIEvent(guard_soul_img, UCE.PointerClick, 'GuardUI', 'guard_soul_image_click')
        end
        GlobalProcessing.SetRetPoint(guard_soul_img, GlobalProcessing.have_guard_soul_been_to_be_seen == true and true or false, UIDefine.red_type.common)
    end

end

function GuardUI.OnAnimationCallBack(guid, action)
    if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
        return
    end
    local model = _gt.GetUI("GuardModel")
    if model then
        GUI.ReplaceWeapon(model, 0, eRoleMovement.ATTSTAND_W1, 0)
    end
end

function GuardUI.OnClickGuardModel()
    local model = _gt.GetUI("GuardModel")
    if model then
        GUI.ReplaceWeapon(model, 0, eRoleMovement.PHYATT_W1, 0)
    end
end

--创建侍从右侧属性页签
function GuardUI.OnSelectGuardAttr()
    local guardArr_Right = _gt.GetUI("guardArr_Right")
    if guardArr_Right == nil then
        --属性页签(一级页面)
        local guard_Bg = _gt.GetUI("guard_Bg")
        guardArr_Right = GUI.GroupCreate(guard_Bg, "guardArr_Right", -75, 75, 340, 545) -- 原 x356  y34
        _gt.BindName(guardArr_Right, "guardArr_Right")
        UILayout.SetSameAnchorAndPivot(guardArr_Right, UILayout.TopRight) -- TopRight 原 Center

        local model_Bg = _gt.GetUI("model_Bg")
        local childCount = GUI.GetChildCount(guard_Bg)

        --侍从属性按钮
        local guardAttr_Btn = GUI.ButtonCreate(guardArr_Right, "guardAttr_Btn", "1800402030", 2, -35, Transition.None, "侍从属性", 170, 43, false) -- 原x0
        UILayout.SetSameAnchorAndPivot(guardAttr_Btn, UILayout.TopLeft)
        GUI.ButtonSetTextColor(guardAttr_Btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(guardAttr_Btn, UIDefine.FontSizeS)
        _gt.BindName(guardAttr_Btn, "guardAttr_Btn")
        -- 添加小红点
        --GUI.AddRedPoint(guardAttr_Btn,UIAnchor.TopLeft,8,8)
        --GUI.SetRedPointVisable(guardAttr_Btn,false)
        local btnSelectImage = GUI.ImageCreate(guardAttr_Btn, "btnSelectImage", "1800402032", 0, 0, false, 170, 43)
        UILayout.SetSameAnchorAndPivot(btnSelectImage, UILayout.Center)
        GUI.SetVisible(btnSelectImage, false)
        --侍从技能按钮
        local guardSkill_Btn = GUI.ButtonCreate(guardArr_Right, "guardSkill_Btn", "1800402030", -5, -35, Transition.None, "侍从技能", 170, 43, false) -- 原x0
        UILayout.SetSameAnchorAndPivot(guardSkill_Btn, UILayout.TopRight)
        GUI.ButtonSetTextColor(guardSkill_Btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(guardSkill_Btn, UIDefine.FontSizeS)
        _gt.BindName(guardSkill_Btn, "guardSkill_Btn")
        -- 添加小红点
        --GUI.AddRedPoint(guardSkill_Btn,UIAnchor.TopLeft,8,8)
        --GUI.SetRedPointVisable(guardSkill_Btn,false)
        local btnSelectImage = GUI.ImageCreate(guardSkill_Btn, "btnSelectImage", "1800402032", 0, 0, false, 170, 43)
        UILayout.SetSameAnchorAndPivot(btnSelectImage, UILayout.Center)
        GUI.SetVisible(btnSelectImage, false)
        --侍从装备按钮
        UILayout.SetSameAnchorAndPivot(btnSelectImage, UILayout.Center)

        GUI.RegisterUIEvent(guardAttr_Btn, UCE.PointerClick, "GuardUI", "OnGuardAttr_BtnClick")
        GUI.RegisterUIEvent(guardSkill_Btn, UCE.PointerClick, "GuardUI", "OnGuardSkill_BtnClick")

        -- 判断侍从属性按钮是否显示小红点,及侍从技能按钮
        --GUI.SetRedPointVisable(guardSkill_Btn,false)
        GlobalProcessing.SetRetPoint(guardSkill_Btn, false, UIDefine.red_type.common)
        --GUI.SetRedPointVisable(guardAttr_Btn,false)
        GlobalProcessing.SetRetPoint(guardAttr_Btn, false, UIDefine.red_type.common)
        if GuardUI.SelectGuardID and GuardUI.SelectGuardID ~= 0 and
                GuardUI.red_point_data and GuardUI.red_point_data.guard_reds and GuardUI.red_point_data.guard_reds[tostring(GuardUI.SelectGuardID)] then
            local data = GuardUI.red_point_data.guard_reds[tostring(GuardUI.SelectGuardID)]
            -- 侍从属性
            -- 如果未激活
            if not data.is_activation then
                --GUI.SetRedPointVisable(guardAttr_Btn, data.can_activation)
                GlobalProcessing.SetRetPoint(guardAttr_Btn, data.can_activation, UIDefine.red_type.common)
            else
                -- 侍从技能
                --GUI.SetRedPointVisable(guardSkill_Btn,data.can_up_skill or data.can_up_star)
                GlobalProcessing.SetRetPoint(guardSkill_Btn, data.can_up_skill or data.can_up_star, UIDefine.red_type.common)
            end
        end

        GuardUI.OnGuardAttr_BtnClick("guardAttr_Btn")
    else
        GUI.SetVisible(guardArr_Right, true)

        -- 判断侍从属性按钮是否显示小红点,及侍从技能按钮
        local guardAttr_Btn = _gt.GetUI("guardAttr_Btn")
        local guardSkill_Btn = _gt.GetUI("guardSkill_Btn")
        --GUI.SetRedPointVisable(guardSkill_Btn,false)
        GlobalProcessing.SetRetPoint(guardSkill_Btn, false, UIDefine.red_type.common)
        --GUI.SetRedPointVisable(guardAttr_Btn,false)
        GlobalProcessing.SetRetPoint(guardAttr_Btn, false, UIDefine.red_type.common)
        if GuardUI.SelectGuardID and GuardUI.SelectGuardID ~= 0 and
                GuardUI.red_point_data and GuardUI.red_point_data.guard_reds and GuardUI.red_point_data.guard_reds[tostring(GuardUI.SelectGuardID)] then
            local data = GuardUI.red_point_data.guard_reds[tostring(GuardUI.SelectGuardID)]
            -- 侍从属性
            -- 如果未激活
            if not data.is_activation then
                --GUI.SetRedPointVisable(guardAttr_Btn, data.can_activation)
                GlobalProcessing.SetRetPoint(guardAttr_Btn, data.can_activation, UIDefine.red_type.common)
            else
                -- 侍从技能
                --GUI.SetRedPointVisable(guardSkill_Btn,data.can_up_skill or data.can_up_star)
                GlobalProcessing.SetRetPoint(guardSkill_Btn, data.can_up_skill or data.can_up_star, UIDefine.red_type.common)
            end
        end

    end
end

--属性页签 侍从属性按钮点击事件
function GuardUI.OnGuardAttr_BtnClick(key)

    GUI.ButtonSetImageID(_gt.GetUI("guardAttr_Btn"), "1800402032")  -- 侍从属性按钮高亮
    -- 如果侍从技能不为空，就不显示它
    local skillBg = _gt.GetUI("guardSkill_Bg")
    local guardSkill_Btn = _gt.GetUI("guardSkill_Btn")
    if skillBg ~= nil then
        GUI.SetVisible(skillBg, false); -- 关闭侍从技能界面
        GUI.ButtonSetImageID(guardSkill_Btn, "1800402030") -- 关闭侍从技能按钮高亮
    end

    local panelBg = GUI.Get("GuardUI/panelBg")
    local guardAttr_Bg = _gt.GetUI("guardAttr_Bg")
    if guardAttr_Bg == nil then
        local guardArr_Right = _gt.GetUI("guardArr_Right")
        --侍从属性（二级页面）
        local guardAttr_Bg = GUI.ImageCreate(guardArr_Right, "guardAttr_Bg", "1800400010", -2, 0, false, 344, 540) -- 缩小 h 477.9    原 w340 h  x0
        _gt.BindName(guardAttr_Bg, "guardAttr_Bg")
        UILayout.SetSameAnchorAndPivot(guardAttr_Bg, UILayout.Top)

        local hpAttrConfig = DB.GetOnceAttrByKey1(35)
        local HPName = "红量"
        if hpAttrConfig then
            HPName = hpAttrConfig.ChinaName
        end
        local mpAttrConfig = DB.GetOnceAttrByKey1(37)
        local MPName = "蓝量"
        if mpAttrConfig then
            MPName = mpAttrConfig.ChinaName
        end
        local hpTxt = GUI.CreateStatic(guardAttr_Bg, "hpTxt", HPName, 12, 25, 110, 30, "system", true)
        UILayout.SetSameAnchorAndPivot(hpTxt, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(hpTxt, UIDefine.FontSizeS, UIDefine.BrownColor)
        local mpTxt = GUI.CreateStatic(guardAttr_Bg, "mpTxt", MPName, 12, 65, 110, 30, "system", true)
        UILayout.SetSameAnchorAndPivot(mpTxt, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(mpTxt, UIDefine.FontSizeS, UIDefine.BrownColor)

        local hpSlider = GUI.ScrollBarCreate(hpTxt, "hpSlider", "", "1800408120", "1800408110", 55, 0, 260, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
        GUI.ScrollBarSetFillSize(hpSlider, Vector2.New(260, 24))
        GUI.ScrollBarSetBgSize(hpSlider, Vector2.New(260, 24))
        UILayout.SetSameAnchorAndPivot(hpSlider, UILayout.Left)

        local txt = GUI.CreateStatic(hpSlider, "txt", "3200/3200", -20, 0, 300, 30, "system", true)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeSS)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        _gt.BindName(txt, "HPTxt")

        local mpSlider = GUI.ScrollBarCreate(mpTxt, "mpSlider", "", "1800408130", "1800408110", 55, 0, 260, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
        GUI.ScrollBarSetFillSize(mpSlider, Vector2.New(260, 24))
        GUI.ScrollBarSetBgSize(mpSlider, Vector2.New(260, 24))
        UILayout.SetSameAnchorAndPivot(mpSlider, UILayout.Left)
        local txt = GUI.CreateStatic(mpSlider, "txt", "3200/3200", -20, 0, 300, 30, "system", true)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeSS)
        _gt.BindName(txt, "MPTxt")

        local attrCount = #attrLst
        for i = 1, attrCount do
            local attrConfig = DB.GetOnceAttrByKey1(attrLst[i][2])
            if attrConfig then
                local attr_name = GUI.CreateStatic(guardAttr_Bg, "attr_name" .. tostring(i), attrConfig.ChinaName, 12 + 178 * ((i + 1) % 2), 105 + 30 * (math.floor((i - 1) / 2)), 110, 30)
                UILayout.SetSameAnchorAndPivot(attr_name, UILayout.TopLeft)
                UILayout.StaticSetFontSizeColorAlignment(attr_name, UIDefine.FontSizeS, UIDefine.BrownColor)
                local txt = GUI.CreateStatic(attr_name, "txt", "9999999", 55, 0, 330, 30)
                _gt.BindName(txt, "attr_value" .. tostring(i))
                UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.Yellow2Color)
            end
        end

        local cutLine = GUI.ImageCreate(guardAttr_Bg, "cutLine", "1800700190", 0, 265)
        UILayout.SetSameAnchorAndPivot(cutLine, UILayout.Top)
        local txt = GUI.CreateStatic(cutLine, "txt", "收集信物", 27, 0, 150, 30)
        _gt.BindName(txt, "guardSubTitle")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)

        local guardDesc = GUI.CreateStatic(guardAttr_Bg, "guardDesc", "侍从简介侍从简介侍从简介侍从简介侍从简介侍从简介侍从简介", 0, 309, 310, 210)
        _gt.BindName(guardDesc, "guardDesc")
        UILayout.SetSameAnchorAndPivot(guardDesc, UILayout.Top)
        UILayout.StaticSetFontSizeColorAlignment(guardDesc, UIDefine.FontSizeS, UIDefine.BrownColor, TextAnchor.UpperLeft)

        local bottomBg = GUI.ImageCreate(guardAttr_Bg, "bottomBg", "1800700200", 0, -50)
        _gt.BindName(bottomBg, "guardBottomBg")
        UILayout.SetSameAnchorAndPivot(bottomBg, UILayout.Bottom)
        --local guardIcon_Bg=GUI.ImageCreate(bottomBg,"guardIcon_Bg","1800400050",0,3)
        local guardIcon_Bg = GUI.ButtonCreate(bottomBg, "guardIcon_Bg", "1800400050", 0, 3, Transition.None)
        UILayout.SetSameAnchorAndPivot(guardIcon_Bg, UILayout.Center)
        GUI.RegisterUIEvent(guardIcon_Bg, UCE.PointerClick, "GuardUI", "OnRightGuardHeadClick")
        local guardIcon = GUI.ImageCreate(guardIcon_Bg, "guardIcon", "1900000000", 0, -1, false, 70, 70)
        _gt.BindName(guardIcon, "guardIcon")

        local guardTokenCount = GUI.CreateStatic(guardIcon_Bg, "guardTokenCount", "0/99", 0, 57, 330, 30)
        _gt.BindName(guardTokenCount, "guardTokenCount")
        UILayout.SetSameAnchorAndPivot(guardTokenCount, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(guardTokenCount, UIDefine.FontSizeS, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local inviteBtn = GUI.ButtonCreate(guardIcon_Bg, "inviteBtn", "1800402030", 0, 113, Transition.SpriteSwap, "邀请", 100, 43, false)
        _gt.BindName(inviteBtn, "inviteBtn")
        --GUI.ButtonSetShowDisable(inviteBtn,false)
        GUI.ButtonSetTextFontSize(inviteBtn, UIDefine.FontSizeS)
        GUI.ButtonSetTextColor(inviteBtn, UIDefine.BrownColor)
        GUI.RegisterUIEvent(inviteBtn, UCE.PointerClick, "GuardUI", "OnInviteBtnClick")
        -- 添加小红点
        --GUI.AddRedPoint(inviteBtn,UIAnchor.TopLeft,8,8)
        --GUI.SetRedPointVisable(inviteBtn,false)

        --遣散按钮
        --local goBtn=GUI.ButtonCreate(guardAttr_Bg,"goBtn","1800402080",5,3,Transition.ColorTint,"<color=#ffffff><size="..UIDefine.FontSizeL..">遣散</size></color>",160,47,false)
        --UILayout.SetSameAnchorAndPivot(goBtn, UILayout.BottomLeft)
        --GUI.SetIsOutLine(goBtn, true)
        --GUI.SetOutLine_Color(goBtn, UIDefine.Yellow2Color)
        --GUI.SetOutLine_Distance(goBtn, 1)
        --GUI.SetVisible(goBtn,false)
        --休息按钮
        local restBtn = GUI.ButtonCreate(guardAttr_Bg, "restBtn", "1800402080", -1.5, 55, Transition.ColorTint, "<color=#ffffff><size=" .. UIDefine.FontSizeL .. ">休息</size></color>", 160, 47, false) -- x0 y50
        UILayout.SetSameAnchorAndPivot(restBtn, UILayout.Bottom)
        GUI.SetIsOutLine(restBtn, true)
        GUI.SetOutLine_Color(restBtn, UIDefine.Yellow2Color)
        GUI.SetOutLine_Distance(restBtn, 1)
        GUI.SetVisible(restBtn, true)
        GUI.RegisterUIEvent(restBtn, UCE.PointerClick, "GuardUI", "OnGuardRestBtnClick")
        -- 设置按钮点击间隔
        GUI.SetEventCD(restBtn, UCE.PointerClick, 1)

        --出站按钮
        local fightBtn = GUI.ButtonCreate(guardAttr_Bg, "fightBtn", "1800402080", -1.5, 55, Transition.ColorTint, "<color=#ffffff><size=" .. UIDefine.FontSizeL .. ">出战</size></color>", 160, 47, false)
        UILayout.SetSameAnchorAndPivot(fightBtn, UILayout.Bottom)
        GUI.SetIsOutLine(fightBtn, true)
        GUI.SetOutLine_Color(fightBtn, UIDefine.Yellow2Color)
        GUI.SetOutLine_Distance(fightBtn, 1)
        GUI.SetVisible(fightBtn, false)
        --GUI.RegisterUIEvent(goBtn,UCE.PointerClick,"GuardUI","OnGuardGoBtnClick") -- 遣散事件
        GUI.RegisterUIEvent(fightBtn, UCE.PointerClick, "GuardUI", "OnGuardFightBtnClick")
        -- 设置按钮点击间隔
        GUI.SetEventCD(fightBtn, UCE.PointerClick, 1)
    else
        GUI.SetVisible(guardAttr_Bg, true)
    end
end

function GuardUI.OnRightGuardHeadClick()
    local guardDB = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)
    if guardDB then
        -- local guardAttr_Bg= _gt.GetUI("guardAttr_Bg")
        local panelBg = _gt.GetUI('panelBg')
        local tip = Tips.CreateByItemId(guardDB.CallItemIcon, panelBg, "GuardTokenTips", 7, -60)
        GUI.SetData(tip, "ItemId", tostring(guardDB.CallItemIcon))
        GUI.SetHeight(tip, GUI.GetHeight(tip) + 40)
        _gt.BindName(tip, "GuardTokenTips")
        local wayBtn = GUI.ButtonCreate(tip, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
        UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(wayBtn, UCE.PointerClick, "GuardUI", "OnClickGuardWayBtn")
        GUI.AddWhiteName(tip, GUI.GetGuid(wayBtn))
    end
end

function GuardUI.OnClickGuardWayBtn()
    local tip = _gt.GetUI("GuardTokenTips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end
-- 邀请点击事件
function GuardUI.OnInviteBtnClick()
    if GuardUI.SelectGuardActived then
        local guardDB = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)
        if guardDB then
            GlobalUtils.ShowBoxMsg2Btn("提示", "您是否要消耗<color=red>50</color>个信物来激活侍从<color=red>" .. guardDB.Name .. "</color>", "GuardUI", "是", "OnInviteMessageBoxYes", "否")
        end
    else
        --显示Tips
        GuardUI.OnRightGuardHeadClick()
    end
end

-- 邀请侍从
function GuardUI.OnInviteMessageBoxYes()
    -- 通过协议获取侍从
    CL.SendNotify(NOTIFY.GuardOpeUpdate, 1, GuardUI.SelectGuardID)
    -- 向服务器请求小红点数据，刷新小红点
    --GuardUI._request_red_point()
end

--退出界面
function GuardUI.OnExit()
    --GUI.DestroyWnd("GuardUI")
    -- 用于再次打开界面时,左边侍从列表滚动到顶部
    local scr_Guard = _gt.GetUI("scr_Guard")
    GUI.ScrollRectSetNormalizedPosition(scr_Guard, Vector2.New(0, 0))

    --关闭选择面板显示
    local scr_GuardType_Bg = _gt.GetUI("scr_GuardType_Bg")
    if scr_GuardType_Bg then
        GUI.SetVisible(scr_GuardType_Bg, false)
    end

    GlobalProcessing.guard_soul_red_point()
    GUI.CloseWnd('GuardUI')
end

---------------------------侍从出战按钮部分开始---------------------------
-- 获取当前上阵的侍从
-- 判断是否是已上阵侍从
-- 如果是，则按钮显示休息
-- 如果不是，则按钮显示上阵
-- 点击事件触发
-- 创建静态页面
-- 判断上阵侍从是否有四个
-- 如果没有四个，就直接上阵
-- 如果有四个，就显示四个侍从，选择其中一个进行替换
-- 发送上阵角色id给服务器端
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local fontSize = 22;
local colorTypeTwo = Color.New(162 / 255, 75 / 255, 21 / 255);
local fontSize_BigTwo = 26;

local LineUp_guard = {} -- 已上阵的侍从
-- 侍从上阵点击事件
function GuardUI.OnGuardFightBtnClick(guid)

    -- 防止点击过于频繁
    local btn = GUI.GetByGuid(guid)
    GUI.SetEventCD(btn, UCE.PointerClick, 0.5)


    -- 计算当前已上阵的人数
    local count = 0;
    local allList = LD.GetGuardList_Have_Sorted() -- 获取所有的侍从
    for i = 0, allList.Count - 1 do
        if tostring(LD.GetGuardAttr(allList[i], RoleAttr.GuardAttrIsLinup)) == "1" then
            -- 判断是否已经上阵
            -- 将上阵的侍从ID存储下来
            table.insert(LineUp_guard, allList[i])
            count = count + 1; -- 计算上阵的次数
        end
    end

    -- 当人数小于四时，传入上阵侍从的id给客户端，设为上阵
    if count < 4 then
        if GuardUI.SelectGuardID ~= nil then
            CL.SendNotify(NOTIFY.GuardOpeUpdate, 2, GuardUI.SelectGuardID, "1") -- 将选中的侍从上阵
            -- 按钮切换
            local guardAttr_Bg = _gt.GetUI("guardAttr_Bg")
            local restBtn = GUI.GetChild(guardAttr_Bg, "restBtn")
            local fightBtn = GUI.GetChild(guardAttr_Bg, "fightBtn")
            GUI.SetVisible(fightBtn, false)
            GUI.SetVisible(restBtn, true)
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "请先选择1个需要上阵的侍从！")
        end
        LineUp_guard = {} -- 清空上阵数据
    else
        -- 当上阵人数大于四，创建窗口，替换上阵的角色
        GuardUI.CreateFightChangeUI()
    end
end
--创建出战侍从替换界面
function GuardUI.CreateFightChangeUI()
    local panel = GUI.GetWnd("GuardUI");
    local fightChangeUI_BottomBg = GUI.Get("GuardUI/panelBg/fightChangeUI_BottomBg")
    if fightChangeUI_BottomBg == nil then
        local panelBg = GUI.Get("GuardUI/panelBg");
        fightChangeUI_BottomBg = GUI.ImageCreate(panelBg, "fightChangeUI_BottomBg", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel));
        GUI.SetIsRaycastTarget(fightChangeUI_BottomBg, true); -- 是否响应交互事件
        local fightChangeUI_Bg = GUI.ImageCreate(fightChangeUI_BottomBg, "fightChangeUI_Bg", "1800001120", 0, 0, false, 465, 280);

        local leftFlower = GUI.ImageCreate(fightChangeUI_Bg, "leftFlower", "1800007060", -20, -20);
        SetAnchorAndPivot(leftFlower, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local closeBtn = GUI.ButtonCreate(fightChangeUI_Bg, "closeBtn", "1800002050", -10, 10, Transition.ColorTint);
        SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "GuardUI", "OnFightChange_CloseBtnClick")

        local txt = GUI.CreateStatic(fightChangeUI_Bg, "txt", "当前阵容只能出战4个侍从，请从当前阵容中选择需要替代的侍从", 0, 35, 380, 52, "system", false, false);
        GUI.StaticSetFontSize(txt, fontSize);
        GUI.SetColor(txt, colorTypeTwo)
        SetAnchorAndPivot(txt, UIAnchor.Top, UIAroundPivot.Top)

        local itemIconBg = GUI.ImageCreate(fightChangeUI_Bg, "itemIconBg", "1800400200", 0, 100, false, 410, 105)
        SetAnchorAndPivot(itemIconBg, UIAnchor.Top, UIAroundPivot.Top)
        _gt.BindName(itemIconBg, "GuardLineUp_ItemIconBg")

        for i = 0, 3 do
            -- 创建已上阵侍从头像列表
            local itemBtn = GUI.ItemCtrlCreate(itemIconBg, i, "1800400050", 30 + i * 80 + i * 10, 0)
            SetAnchorAndPivot(itemBtn, UIAnchor.Left, UIAroundPivot.Left)
            GUI.RegisterUIEvent(itemBtn, UCE.PointerClick, "GuardUI", "OnFightChangeUI_ItemClick");
        end

        local confirmBtn = GUI.ButtonCreate(fightChangeUI_Bg, "confirmBtn", "1800002010", -30, -25, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_BigTwo .. ">确认</size></color>", 160, 45, false)
        SetAnchorAndPivot(confirmBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
        GUI.SetOutLine_Color(confirmBtn, colorTypeTwo)
        GUI.SetOutLine_Distance(confirmBtn, 1);
        GUI.SetIsOutLine(confirmBtn, true);
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "GuardUI", "OnFightChange_ConfirmBtnClick")

        local concelBtn = GUI.ButtonCreate(fightChangeUI_Bg, "concelBtn", "1800002010", 30, -25, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_BigTwo .. ">关闭</size></color>", 160, 45, false)
        SetAnchorAndPivot(concelBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.SetOutLine_Color(concelBtn, colorTypeTwo)
        GUI.SetOutLine_Distance(concelBtn, 1);
        GUI.SetIsOutLine(concelBtn, true);
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "GuardUI", "OnFightChange_CloseBtnClick")

    else
        GUI.SetData(fightChangeUI_BottomBg, "selectGuardGuid", nil)
        GUI.SetVisible(fightChangeUI_BottomBg, true);
    end
    --刷新item信息
    GuardUI.RefreshFightChangeUI_ItemInfo()
end
-- 关闭点击事件
function GuardUI.OnFightChange_CloseBtnClick(key, guid)

    local fightChangeUI_BottomBg = GUI.Get("GuardUI/panelBg/fightChangeUI_BottomBg")
    GUI.SetVisible(fightChangeUI_BottomBg, false);
    LineUp_guard = {} -- 清空上阵数据
end
-- 确认点击事件
function GuardUI.OnFightChange_ConfirmBtnClick(key, guid)
    local fightChangeUI_BottomBg = GUI.Get("GuardUI/panelBg/fightChangeUI_BottomBg")
    local selectGuardGuid = GUI.GetData(fightChangeUI_BottomBg, "selectGuardGuid");

    if selectGuardGuid == nil or string.len(selectGuardGuid) == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选择1个需要替换的侍从！")
        return ;
    end

    -- 将上阵队伍中需要替换的侍从下阵
    CL.SendNotify(NOTIFY.GuardOpeUpdate, 2, tonumber(selectGuardGuid), "0")
    -- 将需要上阵的侍从上阵
    CL.SendNotify(NOTIFY.GuardOpeUpdate, 2, GuardUI.SelectGuardID, "1")

    local guardAttr_Bg = _gt.GetUI("guardAttr_Bg")
    local restBtn = GUI.GetChild(guardAttr_Bg, "restBtn")
    local fightBtn = GUI.GetChild(guardAttr_Bg, "fightBtn")
    GUI.SetVisible(fightBtn, false)
    GUI.SetVisible(restBtn, true)

    GUI.SetVisible(fightChangeUI_BottomBg, false);
    LineUp_guard = {}
end
-- 选中四个侍从中上阵角色触发的事件
function GuardUI.OnFightChangeUI_ItemClick(guid)
    local fightChangeUI_BottomBg = GUI.Get("GuardUI/panelBg/fightChangeUI_BottomBg")
    local lastSelectGuid = GUI.GetData(fightChangeUI_BottomBg, "lastSelectGuid")
    if lastSelectGuid ~= nil and string.len(lastSelectGuid) > 0 then
        local lastItemIcon = GUI.GetByGuid(lastSelectGuid);
        local itemSelect = GUI.ItemCtrlGetElement(lastItemIcon, eItemIconElement.Selected);
        if itemSelect ~= nil then
            GUI.SetVisible(itemSelect, false);
        end
    end

    local btn = GUI.GetByGuid(guid);
    local itemSelect = GUI.ItemCtrlGetElement(btn, eItemIconElement.Selected);
    if itemSelect == nil then
        GUI.ItemCtrlSetElementValue(btn, eItemIconElement.Selected, "1800600160")
        itemSelect = GUI.ItemCtrlGetElement(btn, eItemIconElement.Selected);
        GUI.SetHeight(itemSelect, 80);
        GUI.SetWidth(itemSelect, 81);
        GUI.SetVisible(itemSelect, true);
    else
        GUI.SetHeight(itemSelect, 80);
        GUI.SetWidth(itemSelect, 81);
        GUI.SetVisible(itemSelect, true);
    end

    local itemGuid = GUI.GetData(btn, "itemGuid");

    GUI.SetData(fightChangeUI_BottomBg, "lastSelectGuid", tostring(guid));
    GUI.SetData(fightChangeUI_BottomBg, "selectGuardGuid", itemGuid)

end
--刷新item信息
function GuardUI.RefreshFightChangeUI_ItemInfo()
    -- 刷新侍从上阵确认页面数据
    if #LineUp_guard ~= 4 then
        test("侍从上阵时数据错误，侍从个数不是4个");
        return ;
    end

    local itemIconBg = GUI.Get("GuardUI/panelBg/fightChangeUI_BottomBg/fightChangeUI_Bg/itemIconBg")

    for i = 0, #LineUp_guard - 1 do
        if LineUp_guard[i + 1] == 0 then
            test("侍从上阵时数据错误，侍从id为0");
            return
        end

        local itemBtn = GUI.GetChild(itemIconBg, i);

        local guard = DB.GetOnceGuardByKey1(tostring(LineUp_guard[i + 1]))
        if guard ~= nil then
            GUI.ItemCtrlSetElementValue(itemBtn, eItemIconElement.Icon, tostring(guard.Head)) -- 将已经上阵的侍从头像填入头像框中
        end

        local icon = GUI.ItemCtrlGetElement(itemBtn, eItemIconElement.Icon)
        GUI.SetPositionY(icon, -1);
        GUI.SetHeight(icon, 70);
        GUI.SetWidth(icon, 70);

        local itemSelect = GUI.ItemCtrlGetElement(itemBtn, eItemIconElement.Selected);
        if itemSelect ~= nil then
            GUI.SetVisible(itemSelect, false);
        end
        GUI.SetData(itemBtn, "itemGuid", tostring(LineUp_guard[i + 1]))
    end

end

---------------------------侍从出战按钮部分结束---------------------------

---------------------------侍从休息按钮部分开始---------------------------
function GuardUI.OnGuardRestBtnClick()
    -- 将选中的侍从下阵
    CL.SendNotify(NOTIFY.GuardOpeUpdate, 2, GuardUI.SelectGuardID, "0")

    local guardAttr_Bg = _gt.GetUI("guardAttr_Bg")
    local restBtn = GUI.GetChild(guardAttr_Bg, "restBtn")
    local fightBtn = GUI.GetChild(guardAttr_Bg, "fightBtn")
    GUI.SetVisible(fightBtn, true)
    GUI.SetVisible(restBtn, false)
end
---------------------------侍从休息按钮部分开始---------------------------

---------------------------阵容刷新部分开始---------------------------
-- 每次打开页面后执行，给服务器端调用
function GuardUI.RefreshTeamTable()
    -- 每次打开页面执行
    -- 判断当前页面阵容和服务器阵容是否相同
    --如果不相同，下阵所有侍从然后再上阵服务器阵容

    if not (GuardUI.UseBattleArrayList) then
        -- 如果侍从上阵数据不存在
        return
    end

    -- 对比传来的侍从和上阵的侍从
    if GuardUI.OnlineGuardLists == GuardUI.UseBattleArrayList then
        -- 未设置 metatable中的__eq方法，所以无效  -- 待修改
        return
    end
    -- 下阵所有上阵的侍从
    local allList = LD.GetGuardList_Have_Sorted()
    for i = 0, allList.Count - 1 do
        if tostring(LD.GetGuardAttr(allList[i], RoleAttr.GuardAttrIsLinup)) == "1" then
            CL.SendNotify(NOTIFY.GuardOpeUpdate, 2, allList[i], "0")
        end
    end

    -- 将传来的侍从上阵
    for k, v in pairs(GuardUI.UseBattleArrayList) do

        v = LD.GetGuardIDByGUID(v) -- 将guid转换为id
        if v > 0 then
            CL.SendNotify(NOTIFY.GuardOpeUpdate, 2, v, "1")
        end
    end

    --同步完成
    GuardUI.OnlineGuardLists = GuardUI.UseBattleArrayList
    ---- 刷新上阵页面
    --if GuardUI.TabIndex == 5 then
    --    GuardUI.Team_Member_Refresh_Method()
    --end
end
---------------------------阵容刷新部分结束---------------------------

---------------------------#侍从技能部分开始---------------------------
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local fontSize = 22
local fontSize_Little = 18
local colorTypeOne = Color.New(102 / 255, 47 / 255, 22 / 255)
local colorType_RedColor2 = Color.New(224 / 255, 53 / 255, 24 / 255)
local colorType_BrownColor = Color.New(104 / 255, 70 / 255, 38 / 255);
local colorType_LightDark = Color.New(128 / 255, 128 / 255, 128 / 255);
-- 一行主动技能数量
local lineActiveSkillCount = 4;
-- 一列被动技能数量
local passiveSkillCount = 1;
local activeSkillItemSize = Vector2.New(80, 81);
local passiveSkillItemSize = Vector2.New(320, 85);
-- 侍从技能品质等级右下图片
local _IconRightCornerRes = {
    "1801407010",
    "1801407020",
    "1801407030",
    "1801407040",
    "1801407050"
}

local _SkillQualityBackGround = {
    "1800400330",
    "1800400100",
    "1800400110",
    "1800400120",
    "1800400320"
}

--侍从技能按钮点击（侍从属性页签）
function GuardUI.OnGuardSkill_BtnClick()

    --侍从技能按钮高亮
    GUI.ButtonSetImageID(_gt.GetUI("guardSkill_Btn"), "1800402032")
    -- 关闭侍从属性界面
    local arrBg = _gt.GetUI("guardAttr_Bg")
    local btnArrSelectImage = _gt.GetUI("guardAttr_Btn")
    if arrBg ~= nil then
        GUI.SetVisible(arrBg, false); -- 关闭侍从属性页面
        GUI.ButtonSetImageID(btnArrSelectImage, "1800402030") -- 关闭侍从属性按钮高亮
    end
    GuardUI.Create_Skill_Page()
end

-- 创建技能页面
function GuardUI.Create_Skill_Page()
    local guardSkill_Bg = _gt.GetUI("guardSkill_Bg")

    if guardSkill_Bg == nil then
        local parent = _gt.GetUI("guardArr_Right")

        local guardSkill_Bg = GUI.ImageCreate(parent, "guardSkill_Bg", "1800400010", -2, 0, false, 344, 540)
        SetAnchorAndPivot(guardSkill_Bg, UIAnchor.Top, UIAroundPivot.Top)
        _gt.BindName(guardSkill_Bg, "guardSkill_Bg")

        local cutLine1 = GUI.ImageCreate(guardSkill_Bg, "cutLine1", "1801401060", 12, 15);
        SetAnchorAndPivot(cutLine1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        local txt = GUI.CreateStatic(cutLine1, "txt", "主动技能", 7, 0, 88, 26, "system", true);
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)
        GUI.StaticSetFontSize(txt, fontSize);

        local btn = GUI.ButtonCreate(cutLine1, "btn", "1800402110", 125, 0, Transition.ColorTint, "", 82, 38, false);
        SetAnchorAndPivot(btn, UIAnchor.Right, UIAroundPivot.Right)
        GUI.ButtonSetText(btn, "升级")
        GUI.ButtonSetTextColor(btn, colorTypeOne)
        GUI.ButtonSetTextFontSize(btn, fontSize);
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardUI", "OnLearnActiveSkillBtnClick") -- 升级事件 待修改

        -- 添加小红点
        --GUI.AddRedPoint(btn,UIAnchor.TopLeft)
        --GUI.SetRedPointVisable(btn,false)

        local scr = GUI.ScrollRectCreate(guardSkill_Bg, "scr1", 0, 58, 320, 90, 0, false, activeSkillItemSize, UIAroundPivot.Top, UIAnchor.Top, lineActiveSkillCount); -- h 81
        SetAnchorAndPivot(scr, UIAnchor.Top, UIAroundPivot.Top)

        local cutLine2 = GUI.ImageCreate(guardSkill_Bg, "cutLine2", "1801401060", 12, 150); -- y 150
        SetAnchorAndPivot(cutLine2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        local txt = GUI.CreateStatic(cutLine2, "txt", "被动技能", 7, 0, 88, 26, "system", true);
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)
        GUI.StaticSetFontSize(txt, fontSize);

        local scr = GUI.LoopScrollRectCreate(guardSkill_Bg, "scr2", 0, 185, 320, 350, "GuardUI", "CreatPassiveSkillPool", "GuardUI", "OnRefreshGuardPassiveSkill", 0, false, passiveSkillItemSize, passiveSkillCount, UIAroundPivot.Top, UIAnchor.Top);
        SetAnchorAndPivot(scr, UIAnchor.Top, UIAroundPivot.Top)
        _gt.BindName(scr, "scr2")
        GUI.ScrollRectSetChildSpacing(scr, Vector2.New(0, 4));

    else
        GUI.SetVisible(guardSkill_Bg, true);
    end

    GuardUI.RefreshSkillPage()

end

-- 侍从主动技能升级事件
function GuardUI.OnLearnActiveSkillBtnClick()
    local selected_guard = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)
    -- 判断是否拥有当前选择的侍从
    if LD.IsHaveGuard(GuardUI.SelectGuardID) then
        --如果拥有
        -- 跳转到升星页面
        GuardUI.OnTrainTabBtnClick()
    else
        --如果不拥有
        -- 提示： 提示你还未拥有 侍从名称
        CL.SendNotify(NOTIFY.ShowBBMsg, "你还未拥有" .. selected_guard.Name);
        -- 并跳转到属性页面
        GuardUI.OnAttrTabBtnClick()
    end
end

-- 侍从被动技能静态页面
function GuardUI.CreatPassiveSkillPool()
    local scr = _gt.GetUI("scr2")
    local count = GUI.LoopScrollRectGetTotalCount(scr) -- 获取当前执行的次数

    local item = GUI.ItemCtrlCreate(scr, "item_" .. count, "1800400330", 0, 0, passiveSkillItemSize.x, passiveSkillItemSize.y, false); -- 技能背景
    SetAnchorAndPivot(item, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetColor(item, Color.New(1, 1, 1, 0))

    local itemIcon = GUI.ItemCtrlCreate(item, "icon", "1800400330", 5, 0)
    SetAnchorAndPivot(itemIcon, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1900000000") -- 问号技能前景
    GUI.ItemCtrlSetIconGray(itemIcon, true) -- 设置技能前景图片变灰
    GUI.SetWidth(itemIcon, 80);
    GUI.SetHeight(itemIcon, 81);
    --GUI.SetScale(itemIcon,Vector3.New(1.1,1.1,1.1))

    local icon = GUI.ItemCtrlGetElement(itemIcon, eItemIconElement.Icon)
    GUI.SetPositionY(icon, -1);
    GUI.SetVisible(icon, false);
    GUI.SetWidth(icon, 71);
    GUI.SetHeight(icon, 70);
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "GuardUI", "OnGuardSkillBtnClick") -- 点击技能图片弹出tips的事件

    local levelBg = GUI.ImageCreate(itemIcon, "levelBg", "1801407010", -2, -3) -- 技能等级图片
    SetAnchorAndPivot(levelBg, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    local txt = GUI.CreateStatic(levelBg, "txt", "", -5, -2, 24, 26); -- 技能等级文本
    SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter) -- 设置文本居中
    GUI.SetOutLine_Color(txt, colorType_LightDark) -- 描边颜色
    GUI.SetOutLine_Distance(txt, 1) -- 描边宽度
    GUI.SetIsOutLine(txt, true); -- 是否描边
    GUI.StaticSetFontSize(txt, fontSize);
    GUI.SetVisible(levelBg, false);

    local name = GUI.CreateStatic(item, "name", "", 87, 0, 300, 30, "system", false, false) -- 技能名称
    SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetColor(name, colorType_BrownColor)
    GUI.StaticSetFontSize(name, fontSize)

    local info = GUI.CreateStatic(item, "info", "", 87, 30, 220, 44, "system", false, false) -- 技能升级信息
    SetAnchorAndPivot(info, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetColor(info, colorType_RedColor2)
    GUI.StaticSetFontSize(info, fontSize_Little)

    local btn = GUI.ButtonCreate(item, "btn", "1800402110", -5, 0, Transition.ColorTint, "", 82, 38, false); -- 技能升级按钮
    SetAnchorAndPivot(btn, UIAnchor.Right, UIAroundPivot.Right)
    GUI.ButtonSetText(btn, "升级")
    GUI.ButtonSetTextColor(btn, colorTypeOne)
    GUI.ButtonSetTextFontSize(btn, fontSize);
    --GUI.SetVisible(btn,false);
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardUI", "OnLearnQualitySkillBtnClick") -- 升级事件 待修改

    local cutline = GUI.ImageCreate(item, "cutline", "1801401070", 0, 0) -- 下划线图片
    SetAnchorAndPivot(cutline, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.SetPositionY(cutline, -4)

    -- 添加小红点
    --GUI.AddRedPoint(btn,UIAnchor.TopLeft)
    --GUI.SetRedPointVisable(btn,false)

    return item;
end

-- 侍从被动技能升级点击事件
function GuardUI.OnLearnQualitySkillBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    -- 获取此技能对应的侍从
    local selected_guard = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)
    -- 获取并判断此技能对应的情缘侍从是否拥有
    if LD.IsHaveGuard(GuardUI.SelectGuardID) then
        local loveGuardID = tonumber(GUI.GetData(btn, "PassiveSkill_loveGuardID"))
        local is_last_skill = tostring(GUI.GetData(btn, "is_last_skill"))

        -- 如果是最终技能
        if is_last_skill == "true" then
            GuardUI.OnLoveTabBtnClick() -- 跳转到当前侍从的情缘页面

        elseif loveGuardID and LD.IsHaveGuard(loveGuardID) then
            -- 如果拥有该情缘侍从
            -- 判断该技能是否可以升级
            local PassiveSkill_CanUp = GUI.GetData(btn, "PassiveSkill_CanUp")
            if PassiveSkill_CanUp ~= nil and PassiveSkill_CanUp == "true" then
                -- 跳转到情缘界面
                GuardUI.OnLoveTabBtnClick()
            else
                -- 如果不能升级
                GuardUI.SelectGuardID = loveGuardID
                GuardUI.SelectType = 0  -- 将侍从种类列表改为全部
                -- 左边列表和侍从形象也要切换
                GuardUI.UpdateGuardLst()
                GuardUI.autoScrollPosition(GuardUI.SelectGuardID) -- 自动跳转到左边列表中选中侍从的位置
                GuardUI.ShowGuardDetailInfo()
                -- 跳转到对应情缘侍从的升星界面
                GuardUI.OnTrainTabBtnClick()
                -- 刷新页签小红点
                GuardUI._refresh_bookmark_red(GuardUI.SelectGuardID)
            end
        else
            --如果不存在，跳转到对应情缘侍从的属性界面
            if loveGuardID then
                GuardUI.SelectGuardID = loveGuardID
                GuardUI.SelectType = 0  -- 将侍从种类列表改为全部
                -- 刷新左边列表和中间形象以及右边属性页面
                GuardUI.UpdateGuardLst()
                GuardUI.autoScrollPosition(GuardUI.SelectGuardID) -- 自动跳转到左边列表中选中侍从的位置
                GuardUI.ShowGuardDetailInfo()

                GuardUI.OnAttrTabBtnClick() -- 跳转到属性页面
                -- 刷新页签小红点
                GuardUI._refresh_bookmark_red(GuardUI.SelectGuardID)
                -- 刷新侍从属性和侍从技能上的小红点
                GuardUI.OnSelectGuardAttr()
            end

        end

    else
        -- 如果没拥有侍从
        -- 提示：  你还未拥有 侍从名称
        CL.SendNotify(NOTIFY.ShowBBMsg, "你还未拥有" .. selected_guard.Name);
        -- 切换到侍从属性页面
        GuardUI.OnAttrTabBtnClick()
    end

end

--  刷新侍从被动技能
function GuardUI.OnRefreshGuardPassiveSkill(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1

    -- 获取当前选中的侍从对象
    local selected_guard = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)

    -- 获取所需要填入的Element元素
    local item = GUI.GetByGuid(guid)

    local itemIcon = GUI.GetChild(item, "icon") -- 技能图标
    local levelBg = GUI.GetChild(item, "levelBg") -- 技能等级图片
    local skill_level_txt = GUI.GetChild(levelBg, "txt") --技能等级文本
    local name = GUI.GetChild(item, "name") -- 技能名称
    local info = GUI.GetChild(item, "info") -- 技能信息
    local btn = GUI.GetChild(item, "btn") -- 技能按钮
    local cutline = GUI.GetChild(item, "cutline") -- 下划线


    -- 创建一个侍从情缘对象缓存
    local loveSkills_Guard = {}
    table.insert(loveSkills_Guard, { selected_guard.Love1Id })
    table.insert(loveSkills_Guard, { selected_guard.Love2Id })
    table.insert(loveSkills_Guard, { selected_guard.Love3Id })

    -- 如果玩家拥有此侍从
    if LD.IsHaveGuard(GuardUI.SelectGuardID) and GuardUI.SkillList then
        -- 获取被动技能对应其他侍从的星级
        for i = 1, 3 do
            table.insert(loveSkills_Guard[i], GuardUI.SkillList["Love" .. i .. "Skill"][2]) -- 情缘技能等级
        end
        -- 将各种数据填入

        -- 获取被动技能对象
        local skill
        local last_skill_level = GuardUI.SkillList.AllLoveAddSkill[2] -- 第四个技能的等级
        if index then
            if index == 4 then
                -- 如果是第四个技能，则技能是最终技能
                skill = DB.GetOnceSkillByKey1(GuardUI.SkillList.AllLoveAddSkill[1])
            else
                skill = DB.GetOnceSkillByKey1(GuardUI.SkillList["Love" .. index .. "Skill"][1])
            end
        end

        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, tostring(skill.Icon)) -- 设置技能的图片
        GUI.SetData(itemIcon, "skill_id", skill.Id) -- 放入技能的id，用于显示tips
        -- 设置技能的名称
        GUI.StaticSetText(name, skill.Name)
        -- 技能品质颜色
        GUI.ImageSetImageID(levelBg, _IconRightCornerRes[skill.SkillQuality])
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, _SkillQualityBackGround[skill.SkillQuality])

        if index < 4 then
            -- 如果下标没轮到最终技能

            GUI.SetData(btn, "PassiveSkill_loveGuardID", loveSkills_Guard[index][1]) -- 将情缘侍从数据插入，用于被动技能按钮的点击事件
            local PassiveSkill_CanUp = tostring(GuardUI.SkillList["Love" .. index .. "Skill"][5])
            if PassiveSkill_CanUp ~= nil then
                GUI.SetData(btn, "PassiveSkill_CanUp", PassiveSkill_CanUp) -- 判断此技能是否可以升级

                -- 设置小红点
                --GUI.SetRedPointVisable(btn,GuardUI.SkillList["Love"..index.."Skill"][5])
                GlobalProcessing.SetRetPoint(btn, GuardUI.SkillList["Love" .. index .. "Skill"][5], UIDefine.red_type.common)
            end

            if loveSkills_Guard[index][2] > 0 then
                -- 情缘侍从技能大于0

                GUI.ItemCtrlSetIconGray(itemIcon, false)-- 对应技能图片取消灰色
                -- 调整技能等级图片
                GUI.StaticSetText(skill_level_txt, tostring(loveSkills_Guard[index][2])) -- 技能等级文本
                -- 技能等级图标显示
                GUI.SetVisible(levelBg, true)
                -- 插入技能等级，用于显示tips
                GUI.SetData(itemIcon, 'skill_level', loveSkills_Guard[index][2])

                if loveSkills_Guard[index][2] == GuardUI.SkillList["Love" .. index .. "Skill"][4] then
                    -- 达到技能等级的最高级
                    GUI.StaticSetText(info, "技能等级" .. "\n已达最高级") -- 调整技能信息显示
                    GUI.SetVisible(btn, false)
                else
                    local curStar = GuardUI.SkillList["Love" .. index .. "Skill"][3]
                    GUI.StaticSetText(info, "侍从" .. (DB.GetOnceGuardByKey1(loveSkills_Guard[index][1])).Name .. "\n达到" .. curStar + 1 .. "星可升级") -- 调整技能信息显示
                    GUI.ButtonSetText(btn, "升级") -- 调整右边升级按钮
                    -- 如果没到达最顶级，则显示升级按钮
                    GUI.SetVisible(btn, true)
                end

            else
                GUI.ItemCtrlSetIconGray(itemIcon, true) -- 设置技能前景图片变灰
                GUI.SetVisible(levelBg, false) -- 技能等级图标不显示
                GUI.StaticSetText(info, "侍从" .. (DB.GetOnceGuardByKey1(loveSkills_Guard[index][1])).Name .. "\n达到1星可激活")
                GUI.ButtonSetText(btn, "激活")
                GUI.SetVisible(btn, true)
                -- 插入技能等级，用于显示tips
                GUI.SetData(itemIcon, 'skill_level', 1)
            end


        elseif index == 4 then

            -- 设置小红点
            --GUI.SetRedPointVisable(btn,GuardUI.SkillList.AllLoveAddSkill[5])
            GlobalProcessing.SetRetPoint(btn, GuardUI.SkillList.AllLoveAddSkill[5], UIDefine.red_type.common)

            if last_skill_level > 0 then
                GUI.ItemCtrlSetIconGray(itemIcon, false) -- 对应技能图片取消灰色
                GUI.StaticSetText(skill_level_txt, tostring(last_skill_level)) -- 技能等级文本
                GUI.SetVisible(levelBg, true) -- 技能等级图标显示
                -- 插入技能等级，用于显示tips
                GUI.SetData(itemIcon, 'skill_level', last_skill_level)
                GUI.SetData(btn, "is_last_skill", "true") -- 用于按钮点击事件，判断是否是最后的技能
                if last_skill_level == GuardUI.SkillList.AllLoveAddSkill[4] then
                    GUI.StaticSetText(info, "技能等级" .. "\n已达最高级") -- 调整技能信息显示
                    GUI.SetVisible(btn, false)
                else
                    GUI.StaticSetText(info, "以上所有侍从\n达到" .. GuardUI.SkillList.AllLoveAddSkill[3] + 1 .. "星可升级") -- 调整技能信息显示
                    GUI.ButtonSetText(btn, "升级") -- 调整右边升级按钮
                    GUI.SetVisible(btn, true)
                end
            else
                GUI.ItemCtrlSetIconGray(itemIcon, true) -- 设置技能前景图片变灰
                GUI.SetVisible(levelBg, false) -- 技能等级图标不显示
                GUI.StaticSetText(info, "以上所有侍从\n达到1星可激活")
                GUI.ButtonSetText(btn, "激活")
                GUI.SetData(btn, "is_last_skill", "true") -- 用于按钮点击事件，判断是否是最后的技能
                -- 插入技能等级，用于显示tips
                GUI.SetData(itemIcon, 'skill_level', 1)
            end

        end
    else
        -- 如果未拥有此侍从
        -- 获取被动技能对象
        local skill
        if index then
            if index == 4 then
                -- 如果是第四个技能，则技能是最终技能
                skill = DB.GetOnceSkillByKey1(selected_guard.AllLoveAddSkill1)
            else
                skill = DB.GetOnceSkillByKey1(selected_guard["Love" .. index .. "Skill"])
            end
        end
        -- 设置技能的图片
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, tostring(skill.Icon))
        GUI.ItemCtrlSetIconGray(itemIcon, true) -- 设置技能前景图片变灰
        GUI.SetData(itemIcon, "skill_id", skill.Id) -- 放入技能的id，用于显示tips
        -- 插入技能等级，用于显示tips
        GUI.SetData(itemIcon, 'skill_level', 1)
        -- 技能品质颜色背景
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, _SkillQualityBackGround[skill.SkillQuality])
        -- 技能等级图标不显示
        GUI.SetVisible(levelBg, false)
        -- 技能等级文本不显示
        GUI.StaticSetText(skill_level_txt, "")
        -- 设置技能的名称
        GUI.StaticSetText(name, skill.Name)
        -- 设置技能的信息,对应是谁的情缘，"达到1星可激活","达到x星可升级"
        if index == 4 then
            GUI.StaticSetText(info, "以上所有侍从\n达到1星可激活")
        else
            GUI.StaticSetText(info, "侍从" .. (DB.GetOnceGuardByKey1(loveSkills_Guard[index][1])).Name .. "\n达到1星可激活")
        end
        -- 设置点击按钮
        GUI.ButtonSetText(btn, "激活")
        GUI.SetVisible(btn, true)
        -- 关闭小红点
        --GUI.SetRedPointVisable(btn,false)
        GlobalProcessing.SetRetPoint(btn, false, UIDefine.red_type.common)
        -- 开启下划线
        GUI.SetVisible(cutline, true)

    end

end

-- 刷新侍从主动技能
function GuardUI.RefreshGuardSkillBg_Attr()

    if not (GuardUI.SelectGuardID) then
        return
    end

    -- 刷新主动技能
    local guardSkill_Bg = _gt.GetUI("guardSkill_Bg")
    if guardSkill_Bg then
        -- 获取需要插入数据的变量
        local scr = GUI.GetChild(guardSkill_Bg, "scr1")
        -- 获取侍从对象
        local selected_guard = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)

        -- 插入主动技能图片
        local create_skill_window_N = 0 -- 创建技能窗口的数量
        local skills_N -- 技能的总数量
        -- 当侍从无技能时显示一行4个
        if (selected_guard["Skill" .. 1] == 0) then
            create_skill_window_N = 4
        else
            -- 算出技能的数量
            skills_N = 1 -- 初始值为1（方便获取侍从表中的技能）

            for i = 1, 9 do
                if selected_guard["Skill" .. skills_N] ~= nil and selected_guard["Skill" .. skills_N] ~= 0 then
                    skills_N = skills_N + 1
                end
            end
            skills_N = skills_N - 1 -- 因为最后多加1为空才跳出循环，所以得减1
            -- 算出需要创建的窗口数量
            -- 当技能总数量不等于4时，除四向上取整,得出行数，再乘4
            if (skills_N % 4 ~= 0) then
                create_skill_window_N = math.ceil(skills_N / 4) * 4
            else
                create_skill_window_N = skills_N
            end

        end

        for i = 1, create_skill_window_N do

            local name = "active_skills_icon_bg" .. i -- 防止重复
            local active_skills_icon_bg = GUI.GetChild(scr, name)

            -- 将技能等级图标和文字提升作用范围
            local levelBg
            local txt

            if not active_skills_icon_bg then
                active_skills_icon_bg = GUI.ItemCtrlCreate(scr, name, "1800400330", 0, 0) -- 主动技能背景
                -- 注册事件，tips标签
                GUI.RegisterUIEvent(active_skills_icon_bg, UCE.PointerClick, "GuardUI", "OnGuardSkillBtnClick")

                -- 主动技能等级
                levelBg = GUI.ImageCreate(active_skills_icon_bg, "levelBg", _IconRightCornerRes[1], -2, -3) -- 技能等级图片
                SetAnchorAndPivot(levelBg, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
                txt = GUI.CreateStatic(levelBg, "txt", "1", -5, -2, 24, 26); -- 技能等级文本
                SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
                GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter) -- 设置文本居中
                GUI.SetOutLine_Color(txt, colorType_LightDark)
                GUI.SetOutLine_Distance(txt, 1)
                GUI.SetIsOutLine(txt, true); -- 是否描边
                GUI.StaticSetFontSize(txt, fontSize);
                GUI.SetVisible(levelBg, false)

                GUI.ItemCtrlSetElementValue(active_skills_icon_bg, eItemIconElement.Icon, "1900000000") -- 默认显示的技能前景
                SetAnchorAndPivot(active_skills_icon_bg, UIAnchor.Left, UIAroundPivot.Left)
                -- 调整 技能前景 的大小和位置
                local icon = GUI.ItemCtrlGetElement(active_skills_icon_bg, eItemIconElement.Icon)
                GUI.SetPositionY(icon, -1);
                GUI.SetWidth(icon, 71);
                GUI.SetHeight(icon, 70);
            else
                levelBg = GUI.GetChild(active_skills_icon_bg, "levelBg") -- 技能等级图片框
                txt = GUI.GetChild(levelBg, "txt")  -- 等级文本
            end

            -- 如果当前i小于等于技能数量，才能获取到技能
            if i <= skills_N then

                -- 设置技能等级
                -- 获取当前侍从的星级
                local current_guard_level = 0
                local isHaveCurrentGuard = LD.IsHaveGuard(GuardUI.SelectGuardID)

                if isHaveCurrentGuard and GuardUI.SkillList then
                    current_guard_level = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardUI.SelectGuardID)))
                end

                -- 如果侍从的星级大于一
                if current_guard_level >= 1 and isHaveCurrentGuard then
                    local skill = DB.GetOnceSkillByKey1(GuardUI.SkillList["skill" .. i][1])
                    GUI.ItemCtrlSetElementValue(active_skills_icon_bg, eItemIconElement.Icon, tostring(skill.Icon)) -- 插入此技能图片
                    GUI.ItemCtrlSetElementValue(active_skills_icon_bg, eItemIconElement.Border, _SkillQualityBackGround[skill.SkillQuality]) -- 插入品质背景图片
                    -- 修改技能品质标签和等级文本
                    GUI.SetVisible(levelBg, true)
                    GUI.ImageSetImageID(levelBg, _IconRightCornerRes[skill.SkillQuality])
                    GUI.StaticSetText(txt, GuardUI.SkillList["skill" .. i][2])

                    GUI.SetData(active_skills_icon_bg, "skill_id", skill.Id) -- 将技能id插入缓存，用于显示tips
                    -- 插入数据技能等级
                    GUI.SetData(active_skills_icon_bg, 'skill_level', GuardUI.SkillList["skill" .. i][2])

                else
                    -- 如果未拥有此侍从
                    local active_skill = DB.GetOnceSkillByKey1(selected_guard["Skill" .. i]) -- 获取此技能对象
                    GUI.ItemCtrlSetElementValue(active_skills_icon_bg, eItemIconElement.Icon, tostring(active_skill.Icon)) -- 插入此技能图片
                    GUI.ItemCtrlSetElementValue(active_skills_icon_bg, eItemIconElement.Border, _SkillQualityBackGround[active_skill.SkillQuality]) -- 插入品质背景图片

                    -- 修改技能品质标签和等级文本

                    GUI.SetVisible(levelBg, true)
                    GUI.ImageSetImageID(levelBg, _IconRightCornerRes[active_skill.SkillQuality])
                    GUI.StaticSetText(txt, 1)

                    GUI.SetData(active_skills_icon_bg, "skill_id", active_skill.Id) -- 将技能id插入缓存，用于显示tips
                    GUI.SetData(active_skills_icon_bg, 'skill_level', 1)
                end

            else
                -- 如果是空技能位
                local levelBg = GUI.GetChild(active_skills_icon_bg, "levelBg")
                GUI.SetVisible(levelBg, false)
                GUI.ItemCtrlSetElementValue(active_skills_icon_bg, eItemIconElement.Border, "1800400330") -- 插入默认背景图片
                GUI.ItemCtrlSetElementValue(active_skills_icon_bg, eItemIconElement.Icon, "") -- 前景清空
            end

            -- 显示 优先 字
            if (i == selected_guard.First) then
                GUI.ItemCtrlSetElementValue(active_skills_icon_bg, eItemIconElement.LeftTopSp, "1800707100")
            else
                GUI.ItemCtrlSetElementValue(active_skills_icon_bg, eItemIconElement.LeftTopSp, "")
            end

        end

        -- 获取按钮
        local btn = GUI.GetChild(GUI.GetChild(guardSkill_Bg, 'cutLine1'), 'btn')
        -- 满级隐藏升级按钮
        local cur_Star = LD.IsHaveGuard(GuardUI.SelectGuardID) and CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardUI.SelectGuardID))) or 0
        if cur_Star >= GUARD_MAX_STAR then
            GUI.SetVisible(btn, false)
        else
            GUI.SetVisible(btn, true)
            -- 设置小红点
            if GuardUI.red_point_data and GuardUI.red_point_data.guard_reds and GuardUI.red_point_data.guard_reds[tostring(GuardUI.SelectGuardID)] then
                local data = GuardUI.red_point_data.guard_reds[tostring(GuardUI.SelectGuardID)]
                if data.is_activation then
                    -- 根据是否能够升星来判断是否能够 升级主动技能
                    --GUI.SetRedPointVisable(btn,data.can_up_star)
                    GlobalProcessing.SetRetPoint(btn, data.can_up_star, UIDefine.red_type.common)
                else
                    -- 如果没有此侍从,不显示主动技能小红点
                    --GUI.SetRedPointVisable(btn,false)
                    GlobalProcessing.SetRetPoint(btn, false, UIDefine.red_type.common)
                end
            end
        end

    end

    -- 刷新被动技能
    local scr = _gt.GetUI("scr2")
    GUI.LoopScrollRectSetTotalCount(scr, 4)
    GUI.LoopScrollRectRefreshCells(scr)

end

-- 创建技能tips事件
function GuardUI.OnGuardSkillBtnClick(guid)
    -- 获取   技能的id  父类
    local skill_bg = GUI.GetByGuid(guid)
    local skill_id = GUI.GetData(skill_bg, "skill_id") -- 技能id
    local skill_level = tonumber(GUI.GetData(skill_bg, 'skill_level'))
    local panelBg = _gt.GetUI("panelBg") -- 父类
    local icon = GUI.ItemCtrlGetElement(skill_bg, eItemIconElement.Icon)
    -- 如果技能为空，则不需要注册事件，须处理
    if icon == nil or GUI.GetVisible(icon) == false then
    else
        local skillDB = DB.GetOnceSkillByKey1(skill_id)
        Tips.CreateSkillId(tonumber(skill_id), panelBg, "activeSkill_Tips", 0, 0, 0, 0, skill_level)
    end

end

-- 请求服务端获取数据
function GuardUI.RefreshSkillPage()

    -- 获取数据准备刷新页面
    if LD.IsHaveGuard(GuardUI.SelectGuardID) then
        -- 判断是否拥有侍从
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuardSkill", "GetSkillData", GuardUI.SelectGuardID) -- 向服务器发送请求
    else
        GuardUI.RefreshGuardSkillBg_Attr()
    end

end

---------------------------侍从技能部分结束---------------------------


---------------------------阵容部分开始-------------------------------
function GuardUI.OnTeamTabBtnClick()
    --阵容部分的Main
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[5][1])
    local Level = MainUI.MainUISwitchConfig["侍从"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then

    else
        CL.SendNotify(NOTIFY.ShowBBMsg, tostring(Level) .. "级开启" .. Key .. "功能")
        UILayout.OnTabClick(GuardUI.TabIndex, tabList)
        return
    end

    UILayout.OnTabClick(5, tabList)
    GuardUI.Right_RefreshMethod(5)
    GuardUI.TabIndex = 5
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "RefreshLineupPanel")

    GuardUI.TeamMember_Add_Icon_Click = 0
    GuardUI.TeamMember_Choosing = 0
    local TeamTab_Main = _gt.GetUI("TeamTab_Main")
    local guard_Bg = _gt.GetUI("guard_Bg")
    if TeamTab_Main == nil then
        local TeamTab_Main = GUI.ImageCreate(guard_Bg, "TeamTab_Main", "1800400010", 356, -12, false, 342, 530)
        SetAnchorAndPivot(TeamTab_Main, UIAnchor.Center, UIAroundPivot.Center)
        _gt.BindName(TeamTab_Main, "TeamTab_Main")
        --上侧
        local Top_Bar = GUI.ImageCreate(TeamTab_Main, "Top_Bar", "1800700070", 0, -245, false, 332, 32)
        SetAnchorAndPivot(Top_Bar, UIAnchor.Center, UIAroundPivot.Center)
        local Txt_1 = GUI.CreateStatic(Top_Bar, "Txt_1", "阵容配置", 0, 0, 200, 40)
        GUI.SetColor(Txt_1, UIDefine.BrownColor)
        GUI.StaticSetFontSize(Txt_1, UIDefine.FontSizeM)
        GUI.StaticSetAlignment(Txt_1, TextAnchor.MiddleCenter)

        --阵容配置
        local vec = Vector2.New(326, 181);
        local TB_1 = { "一", "二", "三" }
        local Scroll_Bg = GUI.ScrollRectCreate(TeamTab_Main, "Scroll_Bg", 0, 15, 326, 482, 1, false, vec, UIAroundPivot.Center, UIAnchor.Center, 1)
        _gt.BindName(Scroll_Bg, "Scroll_Bg")
        for i = 1, 3 do
            local TeamTab_Bar = GUI.ImageCreate(Scroll_Bg, "TeamTab_Bar" .. i, "1800201130", 0, 0, false, 326, 181)
            local TeamTab_CheckBox = GUI.CheckBoxCreate(TeamTab_Bar, "TeamTab_CheckBox" .. i, "1800607150", "1800607151", -134, -61, Transition.None, false, 40, 40)
            _gt.BindName(TeamTab_CheckBox, "TeamTab_CheckBox" .. i)
            GUI.SetData(TeamTab_CheckBox, "Index", i)
            GUI.RegisterUIEvent(TeamTab_CheckBox, UCE.PointerClick, "GuardUI", "TeamTab_CheckBox_Click")
            local TeamTab_Bar_NameBar = GUI.ImageCreate(TeamTab_Bar, "TeamTab_Bar_NameBar" .. i, "1800800010", -16, -62, false, 190, 32)
            local TeamTab_Bar_Tactical = GUI.ImageCreate(TeamTab_Bar, "TeamTab_Bar_Tactical" .. i, "1800800010", -16, 67, false, 190, 32)
            local TeamTab_Bar_Tactical_Name = GUI.CreateStatic(TeamTab_Bar_Tactical, "TeamTab_Bar_Tactical_Name" .. i, "普通阵", -40, 0, 90, 30)
            SetAnchorAndPivot(TeamTab_Bar_Tactical_Name, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetColor(TeamTab_Bar_Tactical_Name, UIDefine.BrownColor)
            GUI.StaticSetFontSize(TeamTab_Bar_Tactical_Name, UIDefine.FontSizeM)
            GUI.StaticSetAlignment(TeamTab_Bar_Tactical_Name, TextAnchor.MiddleLeft)
            _gt.BindName(TeamTab_Bar_Tactical_Name, "TeamTab_Bar_Tactical_Name" .. i)
            local TeamTab_Bar_Tactical_Level = GUI.CreateStatic(TeamTab_Bar_Tactical, "TeamTab_Bar_Tactical_Level" .. i, "1级", 40, 0, 90, 30)
            SetAnchorAndPivot(TeamTab_Bar_Tactical_Level, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetColor(TeamTab_Bar_Tactical_Level, UIDefine.BrownColor)
            GUI.StaticSetFontSize(TeamTab_Bar_Tactical_Level, UIDefine.FontSizeM)
            GUI.StaticSetAlignment(TeamTab_Bar_Tactical_Level, TextAnchor.MiddleRight)
            _gt.BindName(TeamTab_Bar_Tactical_Level, "TeamTab_Bar_Tactical_Level" .. i)
            local TeamTab_Bar_ChangeTactical = GUI.ButtonCreate(TeamTab_Bar, "TeamTab_Bar_ChangeTactical" .. i, "1800802040", 120, 67, Transition.ColorTint, "配置", 72, 32, false)
            GUI.ButtonSetTextColor(TeamTab_Bar_ChangeTactical, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(TeamTab_Bar_ChangeTactical, 19)
            GUI.RegisterUIEvent(TeamTab_Bar_ChangeTactical, UCE.PointerClick, "GuardUI", "TeamTab_Bar_ChangeTactical_Click")
            GUI.SetData(TeamTab_Bar_ChangeTactical, "Index", i)
            local TeamTab_Bar_ChangeName = GUI.ButtonCreate(TeamTab_Bar, "TeamTab_Bar_ChangeName" .. i, "1800402120", 134, -60, Transition.ColorTint, "", 45, 45, false)
            GUI.SetData(TeamTab_Bar_ChangeName, "Index", i)
            GUI.RegisterUIEvent(TeamTab_Bar_ChangeName, UCE.PointerClick, "GuardUI", "TeamTab_Bar_ChangeName_Click")
            for j = 1, 4 do
                local TeamMember = GUI.ImageCreate(TeamTab_Bar, "TeamMember" .. i .. j, "1800400050", -118 + 79 * (j - 1), 8, false, 78, 78)
                --GUI.SetIsRaycastTarget(TeamMember, true)
                _gt.BindName(TeamMember, "TeamMember" .. i .. j)
                local TeamMember_Add_Icon_Bg = GUI.ButtonCreate(TeamMember, "TeamMember_Add_Icon_Bg" .. i .. j, "1800001060", 0, -2, Transition.None, "", 66, 66, false)    --白框
                _gt.BindName(TeamMember_Add_Icon_Bg, "TeamMember_Add_Icon_Bg" .. i .. j)
                GUI.RegisterUIEvent(TeamMember_Add_Icon_Bg, UCE.PointerClick, "GuardUI", "TeamTab_Bar_AddTeamGuard_Click")    --阵容头像点击事件
                GUI.SetVisible(TeamMember_Add_Icon_Bg, false)
                local TeamMember_Add_Icon = GUI.ImageCreate(TeamMember_Add_Icon_Bg, "TeamMember_Add_Icon" .. i .. j, "1800707060", 0, 0, false, 50, 50)
                GUI.SetData(TeamMember_Add_Icon_Bg, "i", i)
                GUI.SetData(TeamMember_Add_Icon_Bg, "j", j)
                _gt.BindName(TeamMember_Add_Icon, "TeamMember_Add_Icon" .. i .. j)        --加号图标
                --GUI.SetVisible(TeamMember_Add_Icon, true)
                local TeamMember_Add_Icon_Choice = GUI.ImageCreate(TeamMember_Add_Icon_Bg, "TeamMember_Add_Icon_Choice", "1800600160", 0, 0, false, 78, 78)
                _gt.BindName(TeamMember_Add_Icon_Choice, "TeamMember_Add_Icon_Choice" .. i .. j)
                GUI.SetVisible(TeamMember_Add_Icon_Choice, false)        --黄框不显示
                local Change_Arrow = GUI.ImageCreate(TeamMember, "Change_Arrow" .. i .. j, "1800707340", 0, -2, false, 65, 65)
                _gt.BindName(Change_Arrow, "Change_Arrow" .. i .. j)
                GUI.SetData(Change_Arrow, "i", i)
                GUI.SetData(Change_Arrow, "j", j)
                GUI.SetIsRaycastTarget(Change_Arrow, true)
                Change_Arrow:RegisterEvent(UCE.PointerClick)
                GUI.SetVisible(Change_Arrow, false)
                GUI.RegisterUIEvent(Change_Arrow, UCE.PointerClick, "GuardUI", "Change_Arrow_Click")
                local TeamMember_Add_Icon_Choice_Cancel = GUI.ButtonCreate(TeamMember_Add_Icon_Bg, "TeamMember_Add_Icon_Choice_Cancel", "1800702100", 26, -26, Transition.ColorTint, "", 23, 23, false)
                GUI.SetData(TeamMember_Add_Icon_Choice_Cancel, "i", i)
                GUI.SetData(TeamMember_Add_Icon_Choice_Cancel, "j", j)
                _gt.BindName(TeamMember_Add_Icon_Choice_Cancel, "TeamMember_Add_Icon_Choice_Cancel" .. i .. j)
                GUI.RegisterUIEvent(TeamMember_Add_Icon_Choice_Cancel, UCE.PointerClick, "GuardUI", "Clear_OneMember_Button_Click")
                GUI.SetVisible(TeamMember_Add_Icon_Choice_Cancel, false)
            end
            local Team_Name = GUI.CreateStatic(TeamTab_Bar_NameBar, "Team_Name" .. i, "", 0, 2, 150, 30)
            _gt.BindName(Team_Name, "Team_Name" .. i)
            if GuardUI.GuardArrayName and GuardUI.GuardArrayName[i] and GuardUI.GuardArrayName[i] ~= "" then
                GUI.StaticSetText(Team_Name, GuardUI.GuardArrayName[i])
            else
                GUI.StaticSetText(Team_Name, "阵容" .. TB_1[i])
            end
            GUI.StaticSetAlignment(Team_Name, TextAnchor.UpperLeft)
            GUI.StaticSetFontSize(Team_Name, 22)
            GUI.SetColor(Team_Name, UIDefine.BrownColor)
        end

        --下方两个清空配置按钮
        local Clear_All_Button = GUI.ButtonCreate(TeamTab_Main, "Clear_All_Button", "1800802040", -91, 287, Transition.ColorTint, "清空所有配置", 155, 43, false)
        GUI.ButtonSetTextFontSize(Clear_All_Button, 19)
        GUI.ButtonSetTextColor(Clear_All_Button, UIDefine.BrownColor)
        GUI.RegisterUIEvent(Clear_All_Button, UCE.PointerClick, "GuardUI", "Clear_All_Button_Click")
        local Clear_One_Button = GUI.ButtonCreate(TeamTab_Main, "Clear_One_Button", "1800802040", 91, 287, Transition.ColorTint, "清空当前配置", 155, 43, false)
        GUI.ButtonSetTextFontSize(Clear_One_Button, 19)
        GUI.ButtonSetTextColor(Clear_One_Button, UIDefine.BrownColor)
        GUI.RegisterUIEvent(Clear_One_Button, UCE.PointerClick, "GuardUI", "Clear_One_Button_Click")
    else
        GUI.SetVisible(TeamTab_Main, true)
    end
    --GuardUI.Team_Member_Refresh_Method()
    local Scroll_Bg = _gt.GetUI("Scroll_Bg")
    GUI.ScrollRectSetNormalizedPosition(Scroll_Bg, Vector2.New(0, 1))
end

function GuardUI.TeamTab_CheckBox_Click(Guid)
    --选择第几号阵容功能第一步
    local True_Or_False = GUI.CheckBoxGetCheck(GUI.GetByGuid(Guid))
    if GuardUI.TeamMember_Add_Icon_Click == 1 then
        GUI.CheckBoxSetCheck(GUI.GetByGuid(Guid), not True_Or_False)
        return
    end

    local TeamTab_CheckBox = GUI.GetByGuid(Guid)
    local Index = GUI.GetData(TeamTab_CheckBox, "Index")

    if tostring(GuardUI.UseGuardArray) == tostring(Index) then
        CL.SendNotify(NOTIFY.ShowBBMsg, "已经设置为出战阵容")
    end
    for i = 1, 3 do
        local TeamTab_CheckBox = _gt.GetUI("TeamTab_CheckBox" .. i)
        GUI.CheckBoxSetCheck(TeamTab_CheckBox, false)
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "ChangeUseArray", Index)

end

function GuardUI.TeamTab_CheckBox_Click_Finish(Index)
    --选择第几号阵容功能第二步(等服务器调用)
    local TeamTab_CheckBox = _gt.GetUI("TeamTab_CheckBox" .. Index)
    GUI.CheckBoxSetCheck(TeamTab_CheckBox, true)
end

function GuardUI.TeamTab_Bar_ChangeTactical_Click(Guid)
    --修改阵容设置阵法功能
    local TeamTab_Bar_ChangeTactical = GUI.GetByGuid(Guid)
    local index = GUI.GetData(TeamTab_Bar_ChangeTactical, "Index")
    local _BattleSeatUI = GUI.GetWnd("BattleSeatUI")
    local Tactical_Name = "普通阵"
    if GuardUI.LineupSeatList then
        Tactical_Name = GuardUI.LineupSeatList[tonumber(index)]['name']
    end
    GUI.OpenWnd("BattleSeatUI", index .. "-" .. Tactical_Name)
end

function GuardUI.TeamTab_Bar_AddTeamGuard_Click(Guid)
    --点击方块往阵容中添加侍从
    --test("TeamTab_Bar_AddTeamGuard_Click   Guid = "..tostring(Guid))

    local TeamMember_Add_Icon_Bg = GUI.GetByGuid(Guid)
    local i = GUI.GetData(TeamMember_Add_Icon_Bg, "i")
    local j = GUI.GetData(TeamMember_Add_Icon_Bg, "j")

    if GuardUI.TeamMember_Add_Icon_Click == 1 then
        if GuardUI.TeamMember_Add_i_temp ~= i or GuardUI.TeamMember_Add_j_temp ~= j then
            return
        end
    end
    GuardUI.TeamMember_Add_i_temp = i
    GuardUI.TeamMember_Add_j_temp = j
    local TeamMember_Add_Icon_Choice = _gt.GetUI("TeamMember_Add_Icon_Choice" .. i .. j)
    local TeamMember_Add_Icon_Choice_Cancel = _gt.GetUI("TeamMember_Add_Icon_Choice_Cancel" .. i .. j)

    GUI.SetVisible(TeamMember_Add_Icon_Choice, GuardUI.TeamMember_Add_Icon_Click == 0)

    for k = 1, 4 do
        local Change_Arrow = _gt.GetUI("Change_Arrow" .. i .. k)
        if GUI.ButtonGetImageID(TeamMember_Add_Icon_Bg) == "1800001060" then
            --如果该格子没有侍从则不显示右上角红叉
            GUI.SetVisible(TeamMember_Add_Icon_Choice_Cancel, false)
            if Change_Arrow ~= nil then
                GUI.SetVisible(Change_Arrow, false)
            end
        else
            GUI.SetVisible(TeamMember_Add_Icon_Choice_Cancel, GuardUI.TeamMember_Add_Icon_Click == 0)
            if Change_Arrow ~= nil then
                GUI.SetVisible(Change_Arrow, GuardUI.TeamMember_Add_Icon_Click == 0)
            end
            local TeamMember_Blank_Add_Icon = _gt.GetUI("TeamMember_Add_Icon_Bg" .. i .. k)
            if GUI.ButtonGetImageID(TeamMember_Blank_Add_Icon) == "1800001060" then
                GUI.SetVisible(Change_Arrow, false)
            end
            if k == tonumber(j) then
                GUI.SetVisible(Change_Arrow, false)
            end
        end

    end
    if not GuardUI.TeamTab_Bar_AddTeamGuard_Click_J then
        GuardUI.TeamTab_Bar_AddTeamGuard_Click_J = 1
    end
    GuardUI.TeamTab_Bar_AddTeamGuard_Click_J = j
    if GuardUI.TeamMember_Add_Icon_Click == 0 then
        GuardUI.TeamMember_Add_Icon_Click = 1                                        --用于避免同时点开复数黄框   "0"表示没点开，"1"表示已有点开黄框
    elseif GuardUI.TeamMember_Add_Icon_Click == 1 then
        GuardUI.TeamMember_Add_Icon_Click = 0
    end
    local TeamMember_Blank_Add_Icon = _gt.GetUI("TeamMember_Add_Icon_Bg" .. i .. j)

    if GuardUI.TeamMember_Choosing == 0 then
        GuardUI.TeamMember_Choosing = 1                                --"选择中"     "1"代表选择中，"0"代表非选择中
    elseif GuardUI.TeamMember_Choosing == 1 then
        GuardUI.TeamMember_Choosing = 0
    end
    GuardUI.TeamTab_Bar_AddTeamGuard_Click_Guid = Guid            --储存按钮Guid，用于判断后续点击是不是点击自己
    GuardUI.Check_Whether_Up_Arrow_Is_Show(Guid)

    GuardUI.Loop_Item_Refresh_Lite()
end

function GuardUI.TeamTab_Bar_AddTeamGuard_Finish()
    print("TeamTab_Bar_AddTeamGuard_Finish")
    local TB = {}
    local i = GuardUI.TeamMember_Add_i_temp
    local j = GuardUI.TeamMember_Add_j_temp
    TB['guard_Guid_1'] = GuardUI.BattleArrayList["guard_array_" .. i][1]
    TB['guard_Guid_2'] = GuardUI.BattleArrayList["guard_array_" .. i][2]
    TB['guard_Guid_3'] = GuardUI.BattleArrayList["guard_array_" .. i][3]
    TB['guard_Guid_4'] = GuardUI.BattleArrayList["guard_array_" .. i][4]
    --GuardUI.Left_Chose_Guard_Guid								--左侧点击的侍从Guid

    for k, v in pairs(TB) do
        if GuardUI.Left_Chose_Guard_Guid == v then
            return
        end
    end

    if TB['guard_Guid_' .. j] == "0" then
        TB['guard_Guid_' .. j] = GuardUI.Left_Chose_Guard_Guid
        --CL.SendNotify(NOTIFY.GuardOpeUpdate, 2, GuardUI.SelectGuardID, "1")
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "LineupUp", i, GuardUI.Left_Chose_Guard_Guid)
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "LineupUpAndExchange", i, TB['guard_Guid_' .. j], GuardUI.Left_Chose_Guard_Guid)
    end
    GuardUI.Loop_Item_Refresh_Lite()
end

function GuardUI.Change_Arrow_Click(Guid)
    --CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "GetBattleArray")
    local Change_Arrow = GUI.GetByGuid(Guid)
    local i = GUI.GetData(Change_Arrow, "i")
    local j = GUI.GetData(Change_Arrow, "j")
    --local Chose_guard_Guid = GuardUI.BattleArrayList["guard_array_"..i][j]		--想要换的侍从
    local TeamMember_Add_Icon_Bg = _gt.GetUI("TeamMember_Add_Icon_Bg" .. i .. GuardUI.TeamTab_Bar_AddTeamGuard_Click_J)    --原位置按钮

    local TB = {}
    TB['guard_Guid_1'] = GuardUI.BattleArrayList["guard_array_" .. i][1]
    TB['guard_Guid_2'] = GuardUI.BattleArrayList["guard_array_" .. i][2]
    TB['guard_Guid_3'] = GuardUI.BattleArrayList["guard_array_" .. i][3]
    TB['guard_Guid_4'] = GuardUI.BattleArrayList["guard_array_" .. i][4]

    local guard_Site_Index_Temp = 1
    for k = 1, 4 do
        if k == tonumber(GuardUI.TeamTab_Bar_AddTeamGuard_Click_J) then
            guard_Guid_Temp_1 = GuardUI.BattleArrayList["guard_array_" .. i][k]
            --test("=====================guard_Guid_Temp_1 = "..guard_Guid_Temp_1)
        end
        if k == tonumber(j) then
            guard_Guid_Temp_2 = GuardUI.BattleArrayList["guard_array_" .. i][k]
            --test("=====================guard_Guid_Temp_2 = "..guard_Guid_Temp_2)
            guard_Site_Index_Temp = k
            --test("=====================guard_Site_Index_Temp = "..guard_Site_Index_Temp)
        end
    end

    TB['guard_Guid_' .. GuardUI.TeamTab_Bar_AddTeamGuard_Click_J] = guard_Guid_Temp_2
    TB['guard_Guid_' .. guard_Site_Index_Temp] = guard_Guid_Temp_1

    for k = 1, 4 do
        local Change_Arrow = _gt.GetUI("Change_Arrow" .. i .. k)
        local TeamMember_Add_Icon_Choice = _gt.GetUI("TeamMember_Add_Icon_Choice" .. i .. k)
        local TeamMember_Add_Icon_Choice_Cancel = _gt.GetUI("TeamMember_Add_Icon_Choice_Cancel" .. i .. k)
        GUI.SetVisible(Change_Arrow, false)
        GUI.SetVisible(TeamMember_Add_Icon_Choice, false)
        GUI.SetVisible(TeamMember_Add_Icon_Choice_Cancel, false)
    end
    GuardUI.TeamMember_Add_Icon_Click = 0
    GuardUI.TeamMember_Choosing = 0
    GuardUI.Loop_Item_Refresh_Lite()

    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "LineupExchange", i, GuardUI.TeamTab_Bar_AddTeamGuard_Click_J - 1, guard_Site_Index_Temp - 1)
end

function GuardUI.Check_Whether_Up_Arrow_Is_Show(Guid)
    local TeamMember_Add_Icon_Bg = GUI.GetByGuid(Guid)
    local i = GUI.GetData(TeamMember_Add_Icon_Bg, "i")
    local j = GUI.GetData(TeamMember_Add_Icon_Bg, "j")
    local TB = {}
    TB['guard_Guid_1'] = GuardUI.BattleArrayList["guard_array_" .. i][1]
    TB['guard_Guid_2'] = GuardUI.BattleArrayList["guard_array_" .. i][2]
    TB['guard_Guid_3'] = GuardUI.BattleArrayList["guard_array_" .. i][3]
    TB['guard_Guid_4'] = GuardUI.BattleArrayList["guard_array_" .. i][4]
    local TB_1 = LD.GetGuardIDByGUID(TB['guard_Guid_1'])
    local TB_2 = LD.GetGuardIDByGUID(TB['guard_Guid_2'])
    local TB_3 = LD.GetGuardIDByGUID(TB['guard_Guid_3'])
    local TB_4 = LD.GetGuardIDByGUID(TB['guard_Guid_4'])

    local allList = LD.GetGuardList_Have_Sorted()                    --所有的侍从id
    local TB_IsHave = {}
    --test("=================allList.Count = "..allList.Count)
    for i = 0, allList.Count - 1 do
        --test("====================allList.Id = "..allList[i])
        local isHave = LD.IsHaveGuard(allList[i])                    --已拥有侍从id
        if isHave == true then
            table.insert(TB_IsHave, allList[i])
        end
    end
    local TeamTab_Main = _gt.GetUI("TeamTab_Main")
    for k, v in pairs(TB_IsHave) do
        if v == TB_1 or v == TB_2 or v == TB_3 or v == TB_4 then
            GUI.SetData(TeamTab_Main, "Check_Whether_Guard_IsOn" .. v, "1")        --1表示有重复
        else
            GUI.SetData(TeamTab_Main, "Check_Whether_Guard_IsOn" .. v, "0")        --0表示没重复
        end
    end
end

--更改阵容名字
function GuardUI.TeamTab_Bar_ChangeName_Click(Guid)

    GUI.OpenWnd('RoleRenameUI')
    RoleRenameUI.set_team_index(Guid)
    if true then return end

    local TeamTab_Bar_ChangeName = GUI.GetByGuid(Guid)
    local TeamTab_Bar_ChangeName_Index = GUI.GetData(TeamTab_Bar_ChangeName, "Index")

    local guard_Bg = _gt.GetUI("guard_Bg")
    UILayout.SetSameAnchorAndPivot(guard_Bg, UILayout.Center)
    local TeamTab_Bar_ChangeName_Click_panelCover = GUI.ImageCreate(guard_Bg, "TeamTab_Bar_ChangeName_Click_panelCover", "1800200040", 0, 0, false, 2000, 2000)
    UILayout.SetSameAnchorAndPivot(TeamTab_Bar_ChangeName_Click_panelCover, UILayout.Center)
    GUI.SetIsRaycastTarget(TeamTab_Bar_ChangeName_Click_panelCover, true)
    GuardUI.Change_Name_Click_Icon_Index = GUI.GetData(GUI.GetByGuid(Guid), "Index")
    local ChangeName_111 = GUI.ImageCreate(TeamTab_Bar_ChangeName_Click_panelCover, "ChangeName_111", "1800400460", 0, -34, false, 460, 287)
    UILayout.SetSameAnchorAndPivot(ChangeName_111, UILayout.Center)
    local Team_ChangeName = GUI.ImageCreate(TeamTab_Bar_ChangeName_Click_panelCover, "Team_ChangeName", "1800001140", 0, -143, false, 190, 35)
    UILayout.SetSameAnchorAndPivot(Team_ChangeName, UILayout.Center)
    local Team_ChangeName_Txt = GUI.CreateStatic(Team_ChangeName, "Team_ChangeName_Txt", "阵容改名", 0, 0, 150, 35)
    GUI.StaticSetAlignment(Team_ChangeName_Txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(Team_ChangeName_Txt, 25)
    local Input_Bg = GUI.ImageCreate(TeamTab_Bar_ChangeName_Click_panelCover, "Input_Bg", "1800400010", 0, -38, false, 415, 148)
    UILayout.SetSameAnchorAndPivot(Input_Bg, UILayout.Center)
    local Input = GUI.EditCreate(Input_Bg, "Input", "1800001040", "请输入新的阵容名称", 0, 0, Transition.ColorTint, "system", 372, 50)
    GUI.EditSetFontSize(Input, 24)
    GUI.EditSetTextColor(Input, UIDefine.BrownColor)
    local Comfirm_Button = GUI.ButtonCreate(Input, "Comfirm_Button", "1800002010", 124, 103, Transition.ColorTint, "确认", 160, 45, false)
    GUI.ButtonSetTextFontSize(Comfirm_Button, 24)
    GUI.ButtonSetTextColor(Comfirm_Button, Color.New(1, 1, 1, 1))
    GUI.SetIsOutLine(Comfirm_Button, true)
    GUI.RegisterUIEvent(Comfirm_Button, UCE.PointerClick, "GuardUI", "TeamTab_Bar_ChangeName_Click_Comfirm")
    GUI.SetData(Comfirm_Button, "Index", TeamTab_Bar_ChangeName_Index)
    local Cancel_Button = GUI.ButtonCreate(Input, "Cancel_Button", "1800002010", -124, 103, Transition.ColorTint, "取消", 160, 45, false)
    GUI.ButtonSetTextFontSize(Cancel_Button, 24)
    GUI.ButtonSetTextColor(Cancel_Button, Color.New(1, 1, 1, 1))
    GUI.SetIsOutLine(Cancel_Button, true)
    GUI.RegisterUIEvent(Cancel_Button, UCE.PointerClick, "GuardUI", "TeamTab_Bar_ChangeName_Click_OnExit")
    local ChangeName_Exit_Icon = GUI.ButtonCreate(ChangeName_111, "ChangeName_Exit_Icon", "1800002050", 207, -120, Transition.ColorTint, "", 25, 25, false)
    GUI.RegisterUIEvent(ChangeName_Exit_Icon, UCE.PointerClick, "GuardUI", "TeamTab_Bar_ChangeName_Click_OnExit")
    _gt.BindName(TeamTab_Bar_ChangeName_Click_panelCover, "TeamTab_Bar_ChangeName_Click_panelCover")
end

function GuardUI.TeamTab_Bar_ChangeName_Click_OnExit()
    GUI.Destroy(_gt.GetUI("TeamTab_Bar_ChangeName_Click_panelCover"))
end

function GuardUI.Clear_OneMember_Button_Click(Guid)
    --清除单个侍从按钮
    test("清除单个侍从按钮")
    local TeamMember_Add_Icon_Choice_Cancel = GUI.GetByGuid(Guid)
    local i = GUI.GetData(TeamMember_Add_Icon_Choice_Cancel, "i")
    local j = GUI.GetData(TeamMember_Add_Icon_Choice_Cancel, "j")
    local TeamMember_Add_Icon_Choice = _gt.GetUI("TeamMember_Add_Icon_Choice" .. i .. j)
    local TeamMember_Add_Icon_Choice_Cancel = _gt.GetUI("TeamMember_Add_Icon_Choice_Cancel" .. i .. j)
    GUI.SetVisible(TeamMember_Add_Icon_Choice, false)
    for k = 1, 4 do
        local Change_Arrow = _gt.GetUI("Change_Arrow" .. i .. k)
        GUI.SetVisible(Change_Arrow, false)
    end
    GUI.SetVisible(TeamMember_Add_Icon_Choice_Cancel, false)
    GuardUI.TeamMember_Add_Icon_Click = 0
    local TB = {}
    TB['guard_Guid_1'] = GuardUI.BattleArrayList["guard_array_" .. i][1]
    TB['guard_Guid_2'] = GuardUI.BattleArrayList["guard_array_" .. i][2]
    TB['guard_Guid_3'] = GuardUI.BattleArrayList["guard_array_" .. i][3]
    TB['guard_Guid_4'] = GuardUI.BattleArrayList["guard_array_" .. i][4]
    local Wait_For_Clearing = TB['guard_Guid_' .. j]
    local WFC_ID = LD.GetGuardIDByGUID(Wait_For_Clearing)
    TB['guard_Guid_' .. j] = 0
    local j_Temp = tonumber(j)
    --for k = 1, 4 do
    --	if k > j_Temp then
    --		TB['guard_Guid_'..j_Temp] = TB['guard_Guid_'..k]
    --		TB['guard_Guid_'..k] = 0
    --		j_Temp = j_Temp + 1
    --	end
    --end
    GuardUI.TeamMember_Choosing = 0
    GuardUI.Loop_Item_Refresh_Lite()

    test("================i = " .. i)
    test("================Wait_For_Clearing = " .. Wait_For_Clearing)
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "LineupDown", i, Wait_For_Clearing)
end

function GuardUI.Clear_All_Button_Click()
    --清除所有阵容按钮
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "ClearAllLineup")
    GuardUI.TeamReset()
end

function GuardUI.Clear_One_Button_Click()
    --清除单个阵容按钮
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "ClearLineup", GuardUI.UseGuardArray)
    GuardUI.TeamReset()
end

function GuardUI.TeamReset()
    GuardUI.TeamMember_Add_Icon_Click = 0
    GuardUI.TeamMember_Choosing = 0
    for i = 1, 3 do
        for j = 1, 4 do
            local Change_Arrow = _gt.GetUI("Change_Arrow" .. i .. j)
            if Change_Arrow then
                GUI.SetVisible(Change_Arrow, false)
            end
            local TeamMember_Add_Icon_Choice = _gt.GetUI("TeamMember_Add_Icon_Choice" .. i .. j)
            if TeamMember_Add_Icon_Choice then
                GUI.SetVisible(TeamMember_Add_Icon_Choice, false)
            end
            local TeamMember_Add_Icon_Choice_Cancel = _gt.GetUI("TeamMember_Add_Icon_Choice_Cancel" .. i .. j)
            if TeamMember_Add_Icon_Choice_Cancel then
                GUI.SetVisible(TeamMember_Add_Icon_Choice_Cancel, false)
            end
        end
    end
    GuardUI.Loop_Item_Refresh_Lite()
end

function GuardUI.TeamTab_Bar_ChangeName_Click_Comfirm(Guid,input_name)
    --local Comfirm_Button = GUI.GetByGuid(Guid)
    --local TeamTab_Bar_ChangeName_Index = GUI.GetData(Comfirm_Button, "Index")
    --local Team_Name = _gt.GetUI("Team_Name" .. TeamTab_Bar_ChangeName_Index)
    --local Change_Team_Name_Input_Txt = GUI.EditGetTextM(GUI.GetParentElement(GUI.GetByGuid(Guid)))
    --CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "ChangeArrayName", TeamTab_Bar_ChangeName_Index, Change_Team_Name_Input_Txt)
    ----FormGuard.ChangeArrayName(player,index,name)
    --GUI.Destroy(_gt.GetUI("TeamTab_Bar_ChangeName_Click_panelCover"))
    --GUI.StaticSetText(Team_Name, Change_Team_Name_Input_Txt)

    local btn = GUI.GetByGuid(Guid)
    local TeamTab_Bar_ChangeName_Index = GUI.GetData(btn,'Index')
    local Change_Team_Name_Input_Txt = input_name
    local Team_Name = _gt.GetUI("Team_Name" .. TeamTab_Bar_ChangeName_Index)
    GUI.StaticSetText(Team_Name, Change_Team_Name_Input_Txt)
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "ChangeArrayName", TeamTab_Bar_ChangeName_Index, Change_Team_Name_Input_Txt)

end

--阵容界面使用的刷新方法
function GuardUI.Team_Member_Refresh_Method()
    for i = 1, 3 do
        local Icon_Visible = true
        for j = 1, 4 do
            local TeamMember_Add_Icon_Bg = _gt.GetUI("TeamMember_Add_Icon_Bg" .. i .. j)
            local Guard_Guid = GuardUI.BattleArrayList["guard_array_" .. i][j]
            if Guard_Guid ~= nil then
                if Icon_Visible == true and Guard_Guid == "0" then
                    GUI.SetVisible(TeamMember_Add_Icon_Bg, true)
                    Icon_Visible = false
                end
                local TeamMember_Add_Icon = _gt.GetUI("TeamMember_Add_Icon" .. i .. j)
                if Guard_Guid ~= "0" then
                    local GuardId = LD.GetGuardIDByGUID(Guard_Guid)
                    local Guard_Image = DB.GetOnceGuardByKey1(GuardId)['Head']
                    GUI.SetVisible(TeamMember_Add_Icon_Bg, true)
                    GUI.SetVisible(TeamMember_Add_Icon, false)
                    GUI.ButtonSetImageID(TeamMember_Add_Icon_Bg, Guard_Image)
                else
                    GUI.SetVisible(TeamMember_Add_Icon, true)
                    GUI.ButtonSetImageID(TeamMember_Add_Icon_Bg, "1800001060")
                    if j + 1 <= 4 then
                        local j = j + 1
                        local TeamMember_Add_Icon_Bg = _gt.GetUI("TeamMember_Add_Icon_Bg" .. i .. j)
                        GUI.SetVisible(TeamMember_Add_Icon_Bg, false)
                    end
                end
            end
        end
        local TeamTab_Bar_Tactical_Name = _gt.GetUI("TeamTab_Bar_Tactical_Name" .. i)
        local TeamTab_Bar_Tactical_Level = _gt.GetUI("TeamTab_Bar_Tactical_Level" .. i)
        if GuardUI.LineupSeatList then
            GUI.StaticSetText(TeamTab_Bar_Tactical_Name, GuardUI.LineupSeatList[i]['name'])
            GUI.StaticSetText(TeamTab_Bar_Tactical_Level, GuardUI.LineupSeatList[i]['level'] .. "级")
        else
            GUI.StaticSetText(TeamTab_Bar_Tactical_Name, "普通阵")
            GUI.StaticSetText(TeamTab_Bar_Tactical_Level, "1级")
        end
    end

    for k = 1, 3 do
        local TeamTab_CheckBox = _gt.GetUI("TeamTab_CheckBox" .. k)
        GUI.CheckBoxSetCheck(TeamTab_CheckBox, false)
    end

    if GuardUI.UseGuardArray ~= 0 then
        --第几个阵容处于使用状态
        local TeamTab_CheckBox = _gt.GetUI("TeamTab_CheckBox" .. GuardUI.UseGuardArray)
        GUI.CheckBoxSetCheck(TeamTab_CheckBox, true)
    end
    for i = 1, 3 do
        if GuardUI.GuardArrayName and GuardUI.GuardArrayName[i] and GuardUI.GuardArrayName[i] ~= "" then
            local Team_Name = _gt.GetUI("Team_Name" .. i)
            GUI.StaticSetText(Team_Name, GuardUI.GuardArrayName[i])
        end
    end
end

function GuardUI.Loop_Item_Refresh_Lite()
    --封装的轻量版刷新
    if GuardUI.SelectType and GuardUI.SelectType ~= 0 then
        GuardUI.UpdateGuardLst()
    else
        GuardUI.SortedGuardIDLst = LD.GetGuardList_Have_Sorted()
        if GuardUI.SortedGuardIDLst then
            local Count = GuardUI.SortedGuardIDLst.Count
            local scr_Guard = _gt.GetUI("scr_Guard")
            GUI.LoopScrollRectSetTotalCount(scr_Guard, Count)
            GUI.LoopScrollRectRefreshCells(scr_Guard)
        end
    end
end
---------------------------阵容部分结束-------------------------------

---------------------------刷新部分开始-------------------------------
function GuardUI.Right_RefreshMethod(page_id)
    local guardArr_Right = _gt.GetUI("guardArr_Right")    --属性页
    local TeamTab_Main = _gt.GetUI("TeamTab_Main")    --阵容页
    local guardUpdateStar_Bg = _gt.GetUI("guardUpdateStar_Bg") -- 升星页
    local guardLove_Bg = _gt.GetUI("guardLove_Bg") -- 情缘页

    local AddAttrPage = _gt.GetUI("AddAttrPage") -- 侍从加成页面

    local current_open_page = _gt.GetUI(tabList[GuardUI.TabIndex][4])

    GUI.SetVisible(current_open_page, false)

    if guardArr_Right then

        GUI.SetVisible(guardArr_Right, page_id == 1)

        -- 用于升星后，上阵休息按钮被隐藏后，切换页签要显示出来
        -- if page_id == 1 then
        --     -- 侍从出战/休息按钮显示部分
        --     local guardAttr_Bg= _gt.GetUI("guardAttr_Bg")
        --     local restBtn = GUI.GetChild(guardAttr_Bg,"restBtn")
        --     local fightBtn = GUI.GetChild(guardAttr_Bg,"fightBtn")
        --     -- 判断此时选中的侍从是否拥有
        --     if LD.IsHaveGuard(GuardUI.SelectGuardID) then
        --         -- 判断是否已经上阵
        --         if tostring(LD.GetGuardAttr(GuardUI.SelectGuardID, RoleAttr.GuardAttrIsLinup)) =="1" then
        --             GUI.SetVisible(fightBtn,false)
        --             GUI.SetVisible(restBtn,true)
        --         else
        --             GUI.SetVisible(restBtn,false)
        --             GUI.SetVisible(fightBtn,true)
        --         end
        --     else
        --         GUI.SetVisible(restBtn,false)
        --         GUI.SetVisible(fightBtn,false)
        --     end
        -- end

    end

    if TeamTab_Main then
        GUI.SetVisible(TeamTab_Main, page_id == 5)
    end

    if guardUpdateStar_Bg then
        GUI.SetVisible(guardUpdateStar_Bg, page_id == 2)
    end

    if guardLove_Bg then
        GUI.SetVisible(guardLove_Bg, page_id == 3)
    end

    if AddAttrPage then
        GUI.SetVisible(AddAttrPage, page_id == 4) -- 显示侍从加成页面
    end

    if page_id ~= 4 then
        -- 显示页面,如果切换到侍从加成页面后，会关闭，需要显示
        local panelBg = _gt.GetUI("panelBg")
        local guard_Bg = GUI.GetChild(panelBg, "guard_Bg")
        GUI.SetVisible(guard_Bg, true)

        -- 在侍从加成页面 因为左边侍从列表被隐藏 无法刷新,所以在不是侍从加成页面去刷新
        if GuardUI._is_refresh_left_loop_scroll then
            GuardUI.UpdateGuardLst()
        end
    end

    GuardUI.TabIndex = page_id

end
---------------------------刷新部分结束-------------------------------



---------------------------#升星部分开始-------------------------------
local starCount = GUARD_MAX_STAR;
local fontSize_BigOne = 24;
local fontColor2 = "662F16";
local colorType_UpdateStarBrown1 = Color.New(151 / 255, 92 / 255, 34 / 255);
local colorType_UpdateStarBrown2 = Color.New(83 / 255, 54 / 255, 32 / 255);
local colorType_UpdateStarGreen = Color.New(8 / 255, 175 / 255, 0 / 255);
local colorblack = Color.New(0, 0, 0, 1);
local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)
local upStarGuardArr = {
    { "HP", "血量", "role_max_hp" },
    { "MP", "魔法", "role_max_mp" },

    { "PhyAtk", "物攻", "role_phy_atk" },
    { "MagAtk", "法攻", "role_mag_atk" },

    { "PhyDef", "物防", "role_phy_def" },
    { "MagDef", "法防", "role_mag_def" },

    { "PhyBurst", "物暴", "role_phy_burst_rate" },
    { "MagBurst", "法暴", "role_mag_burst_rate" },

    { "ResistanceLv", "封印", "role_resistance_lv" },
    { "Resistance", "封抗", "role_resistance" },

    { "Miss", "闪避", "role_miss" },
    { "Speed", "速度", "role_speed" },

}

--local _QualityRes = { -- 技能品质 已使用 quality
--    "1800400330", "1800400100", "1800400110", "1800400120", "1800400320", "1801300190", "1801300200", "1801300210", "1801300220"
--}

--右下角数字图片背景
local _IconRightCornerRes = {
    "1801407010",
    "1801407020",
    "1801407030",
    "1801407040",
    "1801407050"
}

-- 获取服务器端侍从升星的数据
function GuardUI.GetGuardUpStartData()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "GetUpStarData", LD.GetGuardGUIDByID(GuardUI.SelectGuardID))
end

-- 升星页签点击事件
function GuardUI.OnTrainTabBtnClick()
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[2][1])
    local Level = MainUI.MainUISwitchConfig["侍从"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        -- 判断是否拥有选中的侍从
        if LD.IsHaveGuard(GuardUI.SelectGuardID) then
            -- 切换页面
            UILayout.OnTabClick(2, tabList)
            GuardUI.Right_RefreshMethod(2)
        else
            -- 如果未拥有侍从，提示信息，跳转到属性界面
            CL.SendNotify(NOTIFY.ShowBBMsg, "你还未拥有" .. DB.GetOnceGuardByKey1(GuardUI.SelectGuardID).Name)
            GuardUI.OnAttrTabBtnClick()
            return
        end


        -- 获取此页面
        local guardTrain_Right = _gt.GetUI("guardTrain_Right")
        if not guardTrain_Right then
            local guard_Bg = _gt.GetUI("guard_Bg")
            local guardTrain_Right = GUI.GroupCreate(guard_Bg, "guardTrain_Right", 358, 8, 345, 575)
            UILayout.SetSameAnchorAndPivot(guardTrain_Right, UILayout.Center)
            _gt.BindName(guardTrain_Right, "guardTrain_Right")
        end

        GuardUI.Create_UpdateStarPage() -- 创建静态页面
        GuardUI.GetGuardUpStartData()
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, tostring(Level) .. "级开启" .. Key .. "功能")
        UILayout.OnTabClick(GuardUI.TabIndex, tabList)
        return
    end
    GuardUI.TeamReset()
end

-- 创建升星静态页面
function GuardUI.Create_UpdateStarPage()

    if _gt.GetUI("guardUpdateStar_Bg") == nil then
        local parent = GUI.Get("GuardUI/panelBg/guard_Bg/guardTrain_Right")
        local guardUpdateStar_Bg = GUI.ImageCreate(parent, "guardUpdateStar_Bg", "1800400010", -2, 0, false, 345, 575)
        SetAnchorAndPivot(guardUpdateStar_Bg, UIAnchor.Top, UIAroundPivot.Top)
        _gt.BindName(guardUpdateStar_Bg, "guardUpdateStar_Bg")

        local starBg = GUI.ImageCreate(guardUpdateStar_Bg, "starBg", "1801200040", 0, 27, false, GUI.GetWidth(guardUpdateStar_Bg) - 8, 40) -- 星星背景
        SetAnchorAndPivot(starBg, UIAnchor.Top, UIAroundPivot.Top)

        for i = 0, starCount - 1 do
            -- 星星
            local star = GUI.ImageCreate(starBg, i, "1801202192", 25 + i * 44 + i * 5, 0) -- 空星星
            SetAnchorAndPivot(star, UIAnchor.Left, UIAroundPivot.Left)

            --local unActive=GUI.ImageCreate(star, "unActive","1801202191",0,0) -- 亮边框
            --SetAnchorAndPivot(unActive, UIAnchor.Center, UIAroundPivot.Center)
            --GUI.SetVisible(unActive,false)
            --
            --local active=GUI.ImageCreate(star, "active","1801202190",0,0) -- 亮星
            --SetAnchorAndPivot(active, UIAnchor.Center, UIAroundPivot.Center)
            --GUI.SetVisible(active,false)
        end

        local itemBg = GUI.ImageCreate(guardUpdateStar_Bg, "itemBg", "1800700220", 0, 70) -- 碎片背景
        SetAnchorAndPivot(itemBg, UIAnchor.Top, UIAroundPivot.Top)

        local unMax = GUI.GroupCreate(itemBg, "unMax", 0, 0, GUI.GetWidth(itemBg), GUI.GetHeight(itemBg));
        _gt.BindName(unMax, "unMax_UpStar")
        SetAnchorAndPivot(unMax, UIAnchor.Center, UIAroundPivot.Center)

        local bg = GUI.ImageCreate(unMax, "bg", "1800700020", 0, 0, false, 78, 78) -- 空正方形框
        SetAnchorAndPivot(bg, UIAnchor.Center, UIAroundPivot.Center)
        local itemIcon = GUI.ItemCtrlCreate(unMax, "itemIcon", "1800700020", 0, 0, 76, 76, false) -- 空正方形框
        SetAnchorAndPivot(itemIcon, UIAnchor.Center, UIAroundPivot.Center)
        _gt.BindName(itemIcon, "headItemIcon_UpStar")
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1900000000") -- 问号正方形框
        --GUI.SetScale(itemIcon,Vector3.New(0.95,0.95,0.95))
        local icon = GUI.ItemCtrlGetElement(itemIcon, eItemIconElement.Icon)
        GUI.SetVisible(icon, false);
        GUI.SetWidth(icon, 71)
        GUI.SetHeight(icon, 70)
        local sp = GUI.ImageCreate(icon, "sp", "1801208250", 2, -2) -- 右上碎片图标
        SetAnchorAndPivot(sp, UIAnchor.TopRight, UIAroundPivot.TopRight)

        local sliderBg = GUI.ImageCreate(unMax, "sliderBg", "1801201090", 0, 0) -- 空心圈
        SetAnchorAndPivot(sliderBg, UIAnchor.Center, UIAroundPivot.Center)
        _gt.BindName(sliderBg, "sliderBg_UpStar")
        local slider = GUI.ImageCreate(sliderBg, "slider", "1801201100", 0, 0) -- 实心圈
        SetAnchorAndPivot(slider, UIAnchor.Center, UIAroundPivot.Center)
        GUI.ImageSetType(slider, SpriteType.Filled)
        GUI.SetImageFillMethod(slider, SpriteFillMethod.Radial360_Bottom)

        GUI.SetImageFillAmount(slider, 0);
        local sliderValue = GUI.CreateStatic(sliderBg, "sliderValue", "", 0, 0, 172, 30)
        SetAnchorAndPivot(sliderValue, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.StaticSetAlignment(sliderValue, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(sliderValue, fontSize)

        local max = GUI.ImageCreate(itemBg, "max", "1800700300", 0, 0) -- 已达最高品质字样
        SetAnchorAndPivot(max, UIAnchor.Center, UIAroundPivot.Center)
        _gt.BindName(max, "max_UpStar")
        GUI.SetVisible(max, false);

        local index = 1;
        local posX = 0;
        local posY = 0;
        for k, v in pairs(upStarGuardArr) do
            posX = index % 2 == 1 and 8 or 170;
            posY = math.floor((index + 1) / 2 - 1) * 25 + 265

            local name = GUI.CreateStatic(guardUpdateStar_Bg, v[1], v[2] .. ":", posX, posY, 163, 23)
            SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetColor(name, colorType_UpdateStarBrown1);
            GUI.StaticSetFontSize(name, fontSize_Little)

            local oldValue = GUI.CreateStatic(name, "oldValue", "", 45, 0, 60, 23)
            SetAnchorAndPivot(oldValue, UIAnchor.Left, UIAroundPivot.Left)
            GUI.StaticSetAlignment(oldValue, TextAnchor.LowerLeft)
            GUI.SetColor(oldValue, colorType_UpdateStarBrown2);
            GUI.StaticSetFontSize(oldValue, fontSize_Little)

            local newValue = GUI.CreateStatic(name, "newValue", "", 107, 0, 53, 23)
            SetAnchorAndPivot(newValue, UIAnchor.Left, UIAroundPivot.Left)
            GUI.StaticSetAlignment(newValue, TextAnchor.LowerLeft)
            GUI.SetColor(newValue, colorType_UpdateStarGreen);
            GUI.StaticSetFontSize(newValue, fontSize_Little)
            index = index + 1
        end

        local oldSkill = GUI.ItemCtrlCreate(guardUpdateStar_Bg, "oldSkill", quality[1][2], -83, -67) -- 旧技能
        SetAnchorAndPivot(oldSkill, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.ItemCtrlSetElementValue(oldSkill, eItemIconElement.Icon, "1900000000") -- 问号正方形框
        --GUI.SetScale(oldSkill,Vector3.New(0.9,0.9,0.9))
        GUI.SetWidth(oldSkill, 80)
        GUI.SetHeight(oldSkill, 81)
        local icon = GUI.ItemCtrlGetElement(oldSkill, eItemIconElement.Icon)
        GUI.SetPositionY(icon, -1)
        GUI.SetVisible(icon, false);
        GUI.SetWidth(icon, 71)
        GUI.SetHeight(icon, 70)
        local levelBg = GuardUI.AddBtn_LevelSp(oldSkill)
        GUI.SetPositionY(levelBg, 2);
        GUI.RegisterUIEvent(oldSkill, UCE.PointerClick, "GuardUI", "OnGuardSkillBtnClick") -- 绑定事件，待注册  技能tips

        local tmpSp = GUI.ImageCreate(guardUpdateStar_Bg, "tmpSp", "1800707050", 0, -84) -- 指向右的箭头
        SetAnchorAndPivot(tmpSp, UIAnchor.Bottom, UIAroundPivot.Bottom)

        local skill = GUI.ItemCtrlCreate(guardUpdateStar_Bg, "skill", quality[1][2], 83, -67) -- 新技能
        SetAnchorAndPivot(skill, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.ItemCtrlSetElementValue(skill, eItemIconElement.Icon, "1900000000") -- 问号正方形框
        --GUI.SetScale(skill,Vector3.New(0.9,0.9,0.9))
        GUI.SetWidth(skill, 80)
        GUI.SetHeight(skill, 81)
        local icon = GUI.ItemCtrlGetElement(skill, eItemIconElement.Icon)
        GUI.SetPositionY(icon, -1)
        GUI.SetVisible(icon, false);
        GUI.SetWidth(icon, 71)
        GUI.SetHeight(icon, 70)
        local levelBg = GuardUI.AddBtn_LevelSp(skill)
        GUI.SetPositionY(levelBg, 2);
        GUI.RegisterUIEvent(skill, UCE.PointerClick, "GuardUI", "OnGuardSkillBtnClick") -- 技能tips

        local updateBtn = GUI.ButtonCreate(guardUpdateStar_Bg, "updateBtn", "1800402080", 0, -10, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_BigOne .. ">升星</size></color>", 133, 47, false);
        SetAnchorAndPivot(updateBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.SetIsOutLine(updateBtn, true)
        GUI.SetOutLine_Color(updateBtn, colorOutline)
        GUI.SetOutLine_Distance(updateBtn, 1)
        GUI.RegisterUIEvent(updateBtn, UCE.PointerClick, "GuardUI", "OnUpdateStarBtnClick") -- 升星执行的方法
        -- 点击再次点击间隔时间
        GUI.SetEventCD(updateBtn, UCE.PointerClick, 1)
        -- 添加小红点
        --GUI.AddRedPoint(updateBtn,UIAnchor.TopLeft,10,10)
        --GUI.SetRedPointVisable(updateBtn,false)

    else
        GUI.SetVisible(_gt.GetUI("guardUpdateStar_Bg"), true);
    end

    --GuardUI.RefreshGuardUpdateStarPage()()
end

-- 创建升星静态页面依赖的函数  添加技能品质背景和等级文本
function GuardUI.AddBtn_LevelSp(btn)
    -- 创建升星静态页面时所需要的方法
    if btn == nil then
        return
    end

    local levelBg = GUI.ImageCreate(btn, "levelBg", _IconRightCornerRes[1], 0, -2) -- 品质图标
    SetAnchorAndPivot(levelBg, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    local level = GUI.CreateStatic(levelBg, "txt", "", -5, -2, 24, 26) -- 技能等级文本 待改大小
    SetAnchorAndPivot(level, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(level, TextAnchor.MiddleCenter) -- 设置居中
    GUI.StaticSetFontSize(level, fontSize)
    GUI.SetOutLine_Color(level, colorblack)
    GUI.SetOutLine_Distance(level, 1)
    GUI.SetIsOutLine(level, true);
    return levelBg;
end

-- 刷新侍从升星界面数据
function GuardUI.RefreshGuardUpdateStarPage()
    -- 获取侍从升星静态页面
    local guardUpdateStar_Bg = _gt.GetUI("guardUpdateStar_Bg")
    if guardUpdateStar_Bg then
        if GuardUI.UpStarDataList and GuardUI.SelectGuardID then
            -- 如果请求服务器数据存在且已选择侍从
            local currentGuard = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)

            -- 显示星星图标
            local currentSelectedGuardStar = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardUI.SelectGuardID)))  -- 当前选中侍从的星级 GuardUI.UpStarDataList.guardStar
            local starBg = GUI.GetChild(guardUpdateStar_Bg, "starBg")

            for i = starCount - 1, currentSelectedGuardStar, -1 do
                -- 把后面的星星变暗，防止覆盖
                local star = GUI.GetChild(starBg, i)
                GUI.ImageSetImageID(star, "1801202192")
            end

            for i = 0, currentSelectedGuardStar - 1 do
                -- 显示亮星星
                local star = GUI.GetChild(starBg, i)
                GUI.ImageSetImageID(star, "1801202190")
                -- 当循环到最后时，显示下一颗星星的亮边框
                if i == currentSelectedGuardStar - 1 and currentSelectedGuardStar < starCount then
                    local star = GUI.GetChild(starBg, currentSelectedGuardStar)
                    GUI.ImageSetImageID(star, "1801202191")
                end
            end

            if currentSelectedGuardStar < starCount then
                -- 如果星级未满

                -- 防止满星后被覆盖
                local unMax = _gt.GetUI("unMax_UpStar") -- 技能框等图片
                GUI.SetVisible(unMax, true)
                local max = _gt.GetUI("max_UpStar") -- 已达最高星级图片
                GUI.SetVisible(max, false)
                -- 开启技能图标和箭头
                local oldSkill = GUI.GetChild(guardUpdateStar_Bg, "oldSkill")
                GUI.SetVisible(oldSkill, true)

                local tmpSp = GUI.GetChild(guardUpdateStar_Bg, "tmpSp")
                GUI.SetVisible(tmpSp, true)

                local skill = GUI.GetChild(guardUpdateStar_Bg, "skill")
                GUI.SetVisible(skill, true)

                -- 开启升星按钮
                local updateBtn = GUI.GetChild(guardUpdateStar_Bg, "updateBtn")
                GUI.SetVisible(updateBtn, true)
                -- 升星按钮小红点
                if GuardUI.SelectGuardID and GuardUI.red_point_data and GuardUI.red_point_data.guard_reds and GuardUI.red_point_data.guard_reds[tostring(GuardUI.SelectGuardID)] then
                    local data = GuardUI.red_point_data.guard_reds[tostring(GuardUI.SelectGuardID)]
                    -- 如果拥有侍从
                    if data.is_activation then
                        --GUI.SetRedPointVisable(updateBtn,data.can_up_star)
                        GlobalProcessing.SetRetPoint(updateBtn, data.can_up_star, UIDefine.red_type.common)
                    else
                        --GUI.SetRedPointVisable(updateBtn,false)
                        GlobalProcessing.SetRetPoint(updateBtn, false, UIDefine.red_type.common)
                    end
                end

                ----------防止覆盖结束


                -- 显示头像和碎片
                local headItemIcon = _gt.GetUI("headItemIcon_UpStar")

                GUI.ItemCtrlSetElementValue(headItemIcon, eItemIconElement.Icon, tostring(currentGuard.Head)) -- 插入侍从头像图片

                -- 显示碎片数量
                local guardUpStarNeedFragmentCount = GuardUI.UpStarDataList.NeedTokenNum -- 升星所需要的碎片
                local guardCurrentHaveFragmentCount = GuardUI.UpStarDataList.HaveTokenNum -- 当前所拥用的碎片数量

                local sliderBg = _gt.GetUI("sliderBg_UpStar")
                -- 显示文本
                local sliderValue = GUI.GetChild(sliderBg, "sliderValue")
                GUI.StaticSetText(sliderValue, guardCurrentHaveFragmentCount .. "/" .. guardUpStarNeedFragmentCount)
                -- 显示圈百分比
                local slider = GUI.GetChild(sliderBg, "slider")
                GUI.SetImageFillAmount(slider, guardCurrentHaveFragmentCount / guardUpStarNeedFragmentCount)

                -- 获取当前属性，升星后的属性
                for k, v in pairs(upStarGuardArr) do
                    local name = GUI.GetChild(guardUpdateStar_Bg, v[1])
                    local oldValue = GUI.GetChild(name, "oldValue")
                    local newValue = GUI.GetChild(name, "newValue")

                    GUI.StaticSetText(oldValue, GuardUI.UpStarDataList.Attr[k][1])
                    GUI.StaticSetText(newValue, "+" .. GuardUI.UpStarDataList.Attr[k][2])
                end

                -- 显示技能图标和等级
                local skill1 = DB.GetOnceSkillByKey1(GuardUI.UpStarDataList.Skill1[1]) -- 旧技能
                local oldSkill = GUI.GetChild(guardUpdateStar_Bg, "oldSkill")

                GUI.ItemCtrlSetElementValue(oldSkill, eItemIconElement.Icon, tostring(skill1.Icon))
                GUI.ItemCtrlSetElementValue(oldSkill, eItemIconElement.Border, quality[skill1.SkillQuality][2]) -- 品质背景
                local levelBg1 = GUI.GetChild(oldSkill, "levelBg")
                GUI.ImageSetImageID(levelBg1, _IconRightCornerRes[skill1.SkillQuality]) -- 品质图标
                local txt1 = GUI.GetChild(oldSkill, "txt")
                GUI.StaticSetText(txt1, GuardUI.UpStarDataList.Skill1[2]) -- 技能等级
                GUI.SetData(oldSkill, "skill_id", skill1.Id)
                -- 插入技能等级，用于显示tips
                GUI.SetData(oldSkill, 'skill_level', GuardUI.UpStarDataList.Skill1[2])

                local skill2 = DB.GetOnceSkillByKey1(GuardUI.UpStarDataList.Skill2[1])  -- 新技能
                local skill = GUI.GetChild(guardUpdateStar_Bg, "skill")

                GUI.ItemCtrlSetElementValue(skill, eItemIconElement.Icon, tostring(skill2.Icon))
                GUI.ItemCtrlSetElementValue(skill, eItemIconElement.Border, quality[skill2.SkillQuality][2]) -- 品质背景
                local levelBg2 = GUI.GetChild(skill, "levelBg")
                GUI.ImageSetImageID(levelBg2, _IconRightCornerRes[skill2.SkillQuality]) -- 品质图标
                local txt2 = GUI.GetChild(skill, "txt")
                GUI.StaticSetText(txt2, GuardUI.UpStarDataList.Skill2[2]) -- 技能等级
                GUI.SetData(skill, "skill_id", skill2.Id)
                -- 插入技能等级，用于显示tips
                GUI.SetData(skill, 'skill_level', GuardUI.UpStarDataList.Skill2[2])

            else
                -- 当星级已满
                local unMax = _gt.GetUI("unMax_UpStar") -- 技能框等图片
                GUI.SetVisible(unMax, false)
                local max = _gt.GetUI("max_UpStar") -- 已达最高星级图片
                GUI.SetVisible(max, true)

                -- 获取当前属性，升星后的属性
                for k, v in pairs(upStarGuardArr) do
                    local name = GUI.GetChild(guardUpdateStar_Bg, v[1])
                    local oldValue = GUI.GetChild(name, "oldValue")
                    local newValue = GUI.GetChild(name, "newValue")

                    GUI.StaticSetText(oldValue, GuardUI.UpStarDataList.Attr[k][1])
                    GUI.StaticSetText(newValue, "+" .. GuardUI.UpStarDataList.Attr[k][2])
                end

                -- 关闭技能图标和箭头
                local oldSkill = GUI.GetChild(guardUpdateStar_Bg, "oldSkill")
                GUI.SetVisible(oldSkill, false)

                local tmpSp = GUI.GetChild(guardUpdateStar_Bg, "tmpSp")
                GUI.SetVisible(tmpSp, false)

                local skill = GUI.GetChild(guardUpdateStar_Bg, "skill")
                GUI.SetVisible(skill, false)

                -- 关闭升星按钮
                local updateBtn = GUI.GetChild(guardUpdateStar_Bg, "updateBtn")
                GUI.SetVisible(updateBtn, false)

            end

        end

    end

end

-- 升星点击事件
function GuardUI.OnUpdateStarBtnClick(guid)
    if _gt.GetUI("guardUpdateStar_Bg") == nil and GuardUI.SelectGuardID and GuardUI.UpStarDataList then
        return ;
    end

    local currentGuard = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)

    if not LD.IsHaveGuard(GuardUI.SelectGuardID) then
        CL.SendNotify(NOTIFY.ShowBBMsg, "你还未拥有" .. currentGuard.Name .. "，无法升星")
        return
    end

    if (CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardUI.SelectGuardID)))) == starCount then
        CL.SendNotify(NOTIFY.ShowBBMsg, "该侍从已达到最高星，无法升星")
    else

        if GuardUI.UpStarDataList.HaveTokenNum >= GuardUI.UpStarDataList.NeedTokenNum then
            --发送升星协议
            local guardGuid = LD.GetGuardGUIDByID(currentGuard.Id) -- 通过侍从id获取其guid
            -- 返回值
            --GuardUI.UpStarDataList.Attr[13][1]
            --GuardUI.UpStarDataList.Attr[13][2]
            -- 回调方法
            --GuardUI.OnUpStarSuccess()
            --GuardUI.RefreshUpStarSuccessPage()
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "StartUpStar", guardGuid) -- 发送升星请求给服务器端

        else
            --弹出侍从信物获取途径tips
            GuardUI.CreateGetItemWayTips(GUI.GetByGuid(guid))
        end
    end
end

-- 侍从信物获取途径tips
function GuardUI.CreateGetItemWayTips(parent)
    local itemId = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID).CallItemIcon
    if itemId ~= nil then
        local panelBg = _gt.GetUI("panelBg")
        local tips = Tips.CreateByItemId(tostring(itemId), panelBg, "UpStarTips", 0, 0)
        _gt.BindName(tips, "UpStarGetTips")
        GUI.SetWidth(tips, 400)
        GUI.SetHeight(tips, 438)
        local btn = GUI.ButtonCreate(tips, "getWayBtn_" .. itemId, "1800402110", 0, -7, Transition.ColorTint, "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">获取途径</size></color>", 150, 50, false)
        SetAnchorAndPivot(btn, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.SetData(tips, "ItemId", itemId)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardUI", "OnUpStarGetBtnClick")
        GUI.AddWhiteName(tips, GUI.GetGuid(btn)) -- 添加到对应的点击销毁白名单
    end
end

-- 获取途径事件
function GuardUI.OnUpStarGetBtnClick()
    local tip = _gt.GetUI("UpStarGetTips")
    if tip then
        Tips.ShowItemGetWay(tip) -- 显示获取途径页面
    end
end

local colorWhite = Color.New(1, 1, 1, 1); -- 颜色未使用
-- 升星成功页面模拟属性
local upStarSuccessTxt = {
    { "hpMax", "血量上限", 305, 230, colorWhite, "role_max_hp" },
    { "mpMax", "魔法上限", 670, 230, colorWhite, "role_max_mp" },

    { "phyAtk", "物攻", 305, 265, colorWhite, "role_phy_atk" },
    { "magAtk", "法攻", 670, 265, colorWhite, "role_mag_atk" },

    { "phyDef", "物防", 305, 300, colorWhite, "role_phy_def" },
    { "magDef", "法防", 670, 300, colorWhite, "role_mag_def" },

    { "phyCrit", "物暴", 305, 335, colorWhite, "role_phy_burst_rate" },
    { "magCrit", "法暴", 670, 335, colorWhite, "role_mag_burst_rate" },

    { "res", "封印", 305, 370, colorWhite, "role_resistance_lv" },
    { "disRes", "封抗", 670, 370, colorWhite, "role_resistance" },

    { "shield", "闪避", 305, 405, colorWhite, "role_miss" },
    { "speed", "速度", 670, 405, colorWhite, "role_speed" },

    { "fightValue", "战力", 305, 440, colorWhite, "role_fight_value" },
}
local colorType_Green2 = Color.New(12 / 255, 255 / 255, 0 / 255);

-- 升星成功静态页面
function GuardUI.OnUpStarSuccess()

    if _gt.GetUI("upStarSuccessBg") == nil then
        local panel = GUI.GetWnd("GuardUI")
        local parent = GUI.Get("GuardUI/panelBg")
        local upStarSuccessBg = GUI.ButtonCreate(parent, "upStarSuccessBg", "1800400220", -GUI.GetPositionX(parent), GUI.GetPositionY(parent), Transition.None, "", GUI.GetWidth(panel), GUI.GetHeight(panel), false)
        SetAnchorAndPivot(upStarSuccessBg, UIAnchor.Center, UIAroundPivot.Center)
        _gt.BindName(upStarSuccessBg, "upStarSuccessBg")

        local centerBg = GUI.ImageCreate(upStarSuccessBg, "centerBg", "1801200060", 0, 0, false, GUI.GetWidth(upStarSuccessBg), 482) -- 黑色背景
        SetAnchorAndPivot(centerBg, UIAnchor.Center, UIAroundPivot.Center)

        local titleBg1 = GUI.ImageCreate(upStarSuccessBg, "titleBg1", "1801200050", -211, -50) -- 升星成功左边翅膀
        SetAnchorAndPivot(titleBg1, UIAnchor.Top, UIAroundPivot.Top)

        local titleBg2 = GUI.ImageCreate(upStarSuccessBg, "titleBg2", "1801200050", 211, -50) -- 升星成功右边翅膀
        SetAnchorAndPivot(titleBg2, UIAnchor.Top, UIAroundPivot.Top)
        GUI.SetScale(titleBg2, Vector3.New(-1, 1, 1));
        local titleBg3 = GUI.ImageCreate(upStarSuccessBg, "titleBg3", "1801204050", 0, 25) -- 升星成功字样
        SetAnchorAndPivot(titleBg3, UIAnchor.Top, UIAroundPivot.Top)

        local centerGroup = GUI.GroupCreate(centerBg, "centerGroup", 0, 0, 1280, 482) -- 技能图标 属性等组
        SetAnchorAndPivot(centerGroup, UIAnchor.Center, UIAroundPivot.Center)
        _gt.BindName(centerGroup, "centerGroup_UpStar")

        for i = 1, 2 do
            -- 人物星级提升
            local iconBg = GUI.ImageCreate(centerGroup, "icon_" .. i, "18012011" .. (i + 1) * 10, (i - 1.5) * 204, 30) -- 头像+星级框
            SetAnchorAndPivot(iconBg, UIAnchor.Top, UIAroundPivot.Top)

            local icon = GUI.ImageCreate(iconBg, "icon", "1900000000", 0, 6, false, 72, 72) -- 问号图标
            SetAnchorAndPivot(icon, UIAnchor.Top, UIAroundPivot.Top)

            for j = 0, starCount - 1 do
                -- 星星
                local star = GUI.ImageCreate(iconBg, "star_" .. j, "1801208420", -30 + j * 12, -4) -- 星背景
                SetAnchorAndPivot(star, UIAnchor.Bottom, UIAroundPivot.Bottom)

                --local sp=GUI.ImageCreate(star, "sp","1801208360",0,0) -- 亮星
                --SetAnchorAndPivot(sp, UIAnchor.Center, UIAroundPivot.Center)
                --GUI.SetVisible(sp,false);
            end
        end

        local tipTop = GUI.ImageCreate(centerGroup, "tipTop", "1800707050", 0, 50) -- 向右箭头
        SetAnchorAndPivot(tipTop, UIAnchor.Top, UIAroundPivot.Top)

        for i = 1, #upStarSuccessTxt do
            -- 属性
            local name = GUI.CreateStatic(centerGroup, upStarSuccessTxt[i][1], upStarSuccessTxt[i][2], upStarSuccessTxt[i][3], upStarSuccessTxt[i][4] - 90, 100, 26)
            SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(name, fontSize)

            local oldValue = GUI.CreateStatic(name, "oldValue", "1000", 130, 0, 100, 26) -- x140
            SetAnchorAndPivot(oldValue, UIAnchor.Left, UIAroundPivot.Left)
            GUI.StaticSetAlignment(oldValue, TextAnchor.LowerLeft)
            GUI.StaticSetFontSize(oldValue, fontSize)

            local narrow = GUI.ImageCreate(name, "narrow", "1801208370", 205, 0) -- 向右小箭头
            SetAnchorAndPivot(narrow, UIAnchor.Left, UIAroundPivot.Left)

            local newValue = GUI.CreateStatic(name, "newValue", "1600", 240, 0, 100, 26)
            SetAnchorAndPivot(newValue, UIAnchor.Left, UIAroundPivot.Left)
            GUI.StaticSetAlignment(newValue, TextAnchor.LowerLeft)
            GUI.SetColor(newValue, colorType_Green2);
            GUI.StaticSetFontSize(newValue, fontSize)
        end

        for i = 1, 2 do
            -- 技能提升
            local skillIcon = GUI.ItemCtrlCreate(centerGroup, "skillIcon" .. i, quality[1][2], (i - 1.5) * 200, -10)
            SetAnchorAndPivot(skillIcon, UIAnchor.Bottom, UIAroundPivot.Bottom)
            GUI.ItemCtrlSetElementValue(skillIcon, eItemIconElement.Icon, "1900000000")
            GUI.SetWidth(skillIcon, 80)
            GUI.SetHeight(skillIcon, 81)
            local Icon = GUI.ItemCtrlGetElement(skillIcon, eItemIconElement.Icon)
            GUI.SetWidth(Icon, 71)
            GUI.SetHeight(Icon, 70)

            GuardUI.AddBtn_LevelSp(skillIcon)
            local levelBg = GUI.GetChild(skillIcon, "levelBg")
            GUI.SetPositionY(levelBg, 2)
            GUI.RegisterUIEvent(skillIcon, UCE.PointerClick, "GuardUI", "OnGuardSkillBtnClick")
        end
        local tipBottom = GUI.ImageCreate(centerGroup, "tipBottom", "1800707050", 0, -28) -- 向右星星
        SetAnchorAndPivot(tipBottom, UIAnchor.Bottom, UIAroundPivot.Bottom)

        local tip = GUI.CreateStatic(upStarSuccessBg, "tip", "点击任意位置继续游戏", 0, -60, 250, 50)
        SetAnchorAndPivot(tip, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.StaticSetFontSize(tip, fontSize)

        GUI.RegisterUIEvent(upStarSuccessBg, UCE.PointerClick, "GuardUI", "OnUpStarBgClick") -- 关闭事件
    else
        GUI.SetVisible(_gt.GetUI("upStarSuccessBg"), true);
    end

end

-- 关闭升星成功时弹出页面的事件
function GuardUI.OnUpStarBgClick()
    GUI.Destroy("GuardUI/panelBg/upStarSuccessBg") -- 这里销毁，防止同一窗口覆盖问题
end

local _guardHeadGrade = {
    "1801401290",
    "1801201110",
    "1801201120",
    "1801201130",
    "1801201140",
}

-- 刷新升星成功页面
function GuardUI.RefreshUpStarSuccessPage()

    local upStarSuccessBg = _gt.GetUI("upStarSuccessBg")
    if upStarSuccessBg then
        if GuardUI.UpStarDataList and GuardUI.SelectGuardID then
            local guard = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)
            local centerGroup_UpStar = _gt.GetUI("centerGroup_UpStar")
            -- 修改侍从头像和星级
            local currentSelectedGuardStar = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardUI.SelectGuardID)))
            --currentSelectedGuardStar = 4
            currentSelectedGuardStar = currentSelectedGuardStar - 1  -- 由于获取的是升星后的星级，所有得减1，到六星时无法升星。

            -- 头像1
            local iconBg_1 = GUI.GetChild(centerGroup_UpStar, "icon_1")
            GUI.ImageSetImageID(iconBg_1, _guardHeadGrade[guard.Grade]) -- 品质背景
            local icon_1_icon = GUI.GetChild(iconBg_1, "icon")
            GUI.ImageSetImageID(icon_1_icon, tostring(guard.Head)) -- 头像

            for j = 0, currentSelectedGuardStar - 1 do
                -- 显示星星
                local star_1_j = GUI.GetChild(iconBg_1, "star_" .. j)
                --local sp = GUI.GetChild(star_1_j,"sp")
                --GUI.SetVisible(sp,true)
                GUI.ImageSetImageID(star_1_j, "1801208360")
            end

            -- 头像2
            local iconBg_2 = GUI.GetChild(centerGroup_UpStar, "icon_2")
            GUI.ImageSetImageID(iconBg_2, _guardHeadGrade[guard.Grade]) -- 品质背景
            local icon_2_icon = GUI.GetChild(iconBg_2, "icon")
            GUI.ImageSetImageID(icon_2_icon, tostring(guard.Head)) -- 头像

            -- 显示星星
            for j = 0, currentSelectedGuardStar - 1 do
                local star_2_j = GUI.GetChild(iconBg_2, "star_" .. j)
                --local sp = GUI.GetChild(star_2_j,"sp")
                --GUI.SetVisible(sp,true)
                GUI.ImageSetImageID(star_2_j, "1801208360")
                if j == currentSelectedGuardStar - 1 then
                    -- 多一颗星
                    local star_2_jAdd = GUI.GetChild(iconBg_2, "star_" .. j + 1)
                    --local sp = GUI.GetChild(star_2_jAdd,"sp")
                    --GUI.SetVisible(sp,true)
                    GUI.ImageSetImageID(star_2_jAdd, "1801208360")
                end
            end

            -- 属性显示
            for i = 1, #upStarSuccessTxt do
                local name_i = GUI.GetChild(centerGroup_UpStar, upStarSuccessTxt[i][1])

                local oldValue = GUI.GetChild(name_i, "oldValue")
                GUI.StaticSetText(oldValue, GuardUI.UpStarDataList.Attr[i][1])

                local newValue = GUI.GetChild(name_i, "newValue")
                GUI.StaticSetText(newValue, GuardUI.UpStarDataList.Attr[i][1] + GuardUI.UpStarDataList.Attr[i][2])
            end

            -- 技能显示
            -- 技能1
            local skill1 = DB.GetOnceSkillByKey1(GuardUI.UpStarDataList.Skill1[1])
            local skillIcon1 = GUI.GetChild(centerGroup_UpStar, "skillIcon1")
            GUI.ItemCtrlSetElementValue(skillIcon1, eItemIconElement.Border, quality[skill1.SkillQuality][2]) -- 技能品质
            GUI.ItemCtrlSetElementValue(skillIcon1, eItemIconElement.Icon, tostring(skill1.Icon)) -- 技能图片
            local levelBg1 = GUI.GetChild(skillIcon1, "levelBg")
            GUI.ImageSetImageID(levelBg1, _IconRightCornerRes[skill1.SkillQuality]) -- 技能等级图标
            local txt1 = GUI.GetChild(levelBg1, "txt")
            GUI.StaticSetText(txt1, GuardUI.UpStarDataList.Skill1[2]) -- 技能等级文本
            GUI.SetData(skillIcon1, "skill_id", skill1.Id) -- 技能tips所需属性
            -- 插入技能等级，用于显示tips
            GUI.SetData(skillIcon1, 'skill_level', GuardUI.UpStarDataList.Skill1[2])
            -- 技能2
            local skill2 = DB.GetOnceSkillByKey1(GuardUI.UpStarDataList.Skill2[1])
            local skillIcon2 = GUI.GetChild(centerGroup_UpStar, "skillIcon2")
            GUI.ItemCtrlSetElementValue(skillIcon2, eItemIconElement.Border, quality[skill2.SkillQuality][2]) -- 技能品质
            GUI.ItemCtrlSetElementValue(skillIcon2, eItemIconElement.Icon, tostring(skill2.Icon)) -- 技能图片
            local levelBg2 = GUI.GetChild(skillIcon2, "levelBg")
            GUI.ImageSetImageID(levelBg2, _IconRightCornerRes[skill2.SkillQuality]) -- 技能等级图标
            local txt2 = GUI.GetChild(levelBg2, "txt")
            GUI.StaticSetText(txt2, GuardUI.UpStarDataList.Skill2[2]) -- 技能等级文本
            GUI.SetData(skillIcon2, "skill_id", skill2.Id) -- 技能tips所需属性
            -- 插入技能等级，用于显示tips
            GUI.SetData(skillIcon2, 'skill_level', GuardUI.UpStarDataList.Skill2[2])

            -- 更新人物特效
            GuardUI.addRoleEffect()

        end
    end
end

---------------------------升星部分结束-------------------------------

---------------------------#情缘部分开始-------------------------------
local _loveGuardQualityBg = {
    "1801401290", "1801401010", "1801401020", "1801401030", "1801401040"
}

-- 发送请求到服务器，获取数据
function GuardUI.guardLovePageGetData()
    local lovePageGuard = LD.GetGuardGUIDByID(GuardUI.SelectGuardID)
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "GetLoveSkillData", tostring(lovePageGuard))
end
-- 情缘页签点击事件
function GuardUI.OnLoveTabBtnClick()
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[3][1])
    local Level = MainUI.MainUISwitchConfig["侍从"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        -- 判断是否拥有选中的侍从
        if LD.IsHaveGuard(GuardUI.SelectGuardID) then
            -- 切换页面
            UILayout.OnTabClick(3, tabList)
            GuardUI.Right_RefreshMethod(3)
        else
            -- 如果未拥有侍从，提示信息，跳转到属性界面
            CL.SendNotify(NOTIFY.ShowBBMsg, "你还未拥有" .. DB.GetOnceGuardByKey1(GuardUI.SelectGuardID).Name)
            GuardUI.OnAttrTabBtnClick()
            return
        end

        -- 获取页面
        local guardTrain_Right = _gt.GetUI("guardTrain_Right")
        if not guardTrain_Right then
            local guard_Bg = _gt.GetUI("guard_Bg")
            local guardTrain_Right = GUI.GroupCreate(guard_Bg, "guardTrain_Right", 358, 8, 345, 575)
            UILayout.SetSameAnchorAndPivot(guardTrain_Right, UILayout.Center)
            _gt.BindName(guardTrain_Right, "guardTrain_Right")
        end

        GuardUI.CreateGuardLovePage()
        GuardUI.guardLovePageGetData()
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, tostring(Level) .. "级开启" .. Key .. "功能")
        UILayout.OnTabClick(GuardUI.TabIndex, tabList)
        return
    end
    GuardUI.TeamReset()
end
-- 侍从技能添加升级图片
function GuardUI.AddBtnUpAndActiveSp(btn)
    if btn == nil then
        return
    end

    local activeSp = GUI.ImageCreate(btn, "activeSp", "1801407060", 0, 0) -- 加号图片
    SetAnchorAndPivot(activeSp, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(activeSp, false);

    local upSp = GUI.ImageCreate(btn, "upSp", "1801401050", 0, 0) -- 黑正方形
    SetAnchorAndPivot(upSp, UIAnchor.Center, UIAroundPivot.Center)

    local up = GUI.ImageCreate(upSp, "up", "1801407070", 0, 0) -- 向左上转箭头
    SetAnchorAndPivot(up, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(upSp, false);

    local effect = GUI.RichEditCreate(btn, "effect", "", 0, 26, 130, 155);
    SetAnchorAndPivot(effect, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(effect, 24);
    GUI.SetIsRaycastTarget(effect, false);
    --GUI.StaticSetText(effect,"3408900000")
    GUI.SetVisible(effect, false);
end
-- 创建情缘页面
function GuardUI.CreateGuardLovePage()
    if _gt.GetUI("guardLove_Bg") == nil then
        local parent = _gt.GetUI("guardTrain_Right")
        local guardLove_Bg = GUI.ImageCreate(parent, "guardLove_Bg", "1800400010", -2, 0, false, 344, 575)
        SetAnchorAndPivot(guardLove_Bg, UIAnchor.Top, UIAroundPivot.Top)
        _gt.BindName(guardLove_Bg, "guardLove_Bg")
        local tmpHeight = 15;
        local tipsBg = GUI.ImageCreate(guardLove_Bg, "tipsBg", "1800601320", 0, 20, false, 330, 80); -- 字体文本框图片
        SetAnchorAndPivot(tipsBg, UIAnchor.Top, UIAroundPivot.Top)

        local tips = GUI.CreateStatic(tipsBg, "tips", "", 2, 0, 305, 60, "system", true, false)
        SetAnchorAndPivot(tips, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(tips, 20)
        GUI.StaticSetText(tips, "<color=#975c22>提升相应情缘侍从星级，可以提升当前侍从被动技能的等级</color>")

        local extraSkillHeight = 35;

        for i = 1, 3 do
            local line1 = GUI.ImageCreate(guardLove_Bg, "line" .. i, "1801208380", (i - 2) * 110, 180 + extraSkillHeight) -- 向下黑色箭头
            SetAnchorAndPivot(line1, UIAnchor.Top, UIAroundPivot.Top)
            local sp = GUI.ImageCreate(line1, "sp", "1801208381", 0, 0, false, GUI.GetWidth(line1), GUI.GetHeight(line1)) -- 向下亮箭头
            SetAnchorAndPivot(sp, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(sp, false);

            local line1 = GUI.ImageCreate(guardLove_Bg, "line", "1801208390", (i - 2) * 110, 322 + extraSkillHeight) -- 黑长方形竖线
            SetAnchorAndPivot(line1, UIAnchor.Top, UIAroundPivot.Top)

            local line = GUI.ImageCreate(guardLove_Bg, "line2_" .. i, "1801208391", (i - 2) * 110, 322 + extraSkillHeight) -- 亮长方形竖线
            SetAnchorAndPivot(line, UIAnchor.Top, UIAroundPivot.Top)
            GUI.SetVisible(line, false);

            local loveGuard = GUI.ImageCreate(guardLove_Bg, "loveGuard_" .. i, _loveGuardQualityBg[1], -110 + (i - 1) * 110, 75 + tmpHeight + extraSkillHeight) -- 头像品质框+底部星星
            SetAnchorAndPivot(loveGuard, UIAnchor.Top, UIAroundPivot.Top)

            local guard = GUI.ImageCreate(loveGuard, "guard", "1900000000", 0, 6, false, 76, 76) -- 问号
            guard:RegisterEvent(UCE.PointerClick);
            SetAnchorAndPivot(guard, UIAnchor.Top, UIAroundPivot.Top)
            GUI.RegisterUIEvent(guard, UCE.PointerClick, "GuardUI", "OnLoveGuardItemBtnClick"); -- 绑定事件tips
            GUI.SetIsRaycastTarget(guard, true); -- 是否响应交互事件

            for j = 0, starCount - 1 do
                -- 六颗星星
                --名字对应侍从星级
                local star = GUI.ImageCreate(loveGuard, "star_" .. j, "1801208420", -30 + j * 12, -4) -- 黑星
                SetAnchorAndPivot(star, UIAnchor.Bottom, UIAroundPivot.Bottom)

                --local sp=GUI.ImageCreate(star, "sp","1801208360",0,0) -- 亮星
                --SetAnchorAndPivot(sp, UIAnchor.Center, UIAroundPivot.Center)
                --GUI.SetVisible(sp,false);

            end

            local skill = GUI.ItemCtrlCreate(loveGuard, "skill", quality[1][2], 0, 162) -- 情缘技能框
            SetAnchorAndPivot(skill, UIAnchor.Top, UIAroundPivot.Top)
            GUI.SetWidth(skill, 80)
            GUI.SetHeight(skill, 81)
            GUI.RegisterUIEvent(skill, UCE.PointerClick, "GuardUI", "guardLovePageSkillTips");
            _gt.BindName(skill, "guardLovePage_Skill_" .. i)
            GUI.ItemCtrlSetElementValue(skill, eItemIconElement.Icon, "1900000000")
            local icon = GUI.ItemCtrlGetElement(skill, eItemIconElement.Icon);
            GUI.SetPositionY(icon, -1)
            --GUI.SetItemIconBtnIconScale(skill,0.90)
            GUI.SetWidth(icon, 71)
            GUI.SetHeight(icon, 70)
            -- 添加小红点
            --GUI.AddRedPoint(skill,UIAnchor.TopLeft)
            --GUI.SetRedPointVisable(skill,false)

            GuardUI.AddBtnUpAndActiveSp(skill)
            GuardUI.AddBtn_LevelSp(skill)

            local btnSelectImage = GUI.ImageCreate(skill, "btnSelectImage", "1800400280", 0, 0) -- 亮四边正方形框
            SetAnchorAndPivot(btnSelectImage, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(btnSelectImage, false);

            -- 技能特效
            local Special_Effects = GUI.SpriteFrameCreate(skill, "Special_Effects_" .. i, "340891", 0, 0) -- 340891
            SetAnchorAndPivot(Special_Effects, UIAnchor.Center, UIAroundPivot.Center)
            _gt.BindName(Special_Effects, "lovePage_Special_Effects_" .. i)
            GUI.SetIsRaycastTarget(Special_Effects, false) -- 是否响应交互事件
            GUI.SetVisible(Special_Effects, false)
            GUI.Play(Special_Effects)

            -- 设置小红点层级
            --local red_point = GUI.GetChild(skill,'redPoint')
            --GUI.SetDepth(red_point,GUI.GetDepth(Special_Effects) + 2)
        end

        local line1 = GUI.ImageCreate(guardLove_Bg, "line", "1801208400", -55, 336 + tmpHeight + extraSkillHeight, false, 103, 37) -- 黑长方形横线
        SetAnchorAndPivot(line, UIAnchor.Top, UIAroundPivot.Top)
        local line2 = GUI.ImageCreate(guardLove_Bg, "line", "1801208400", 55, 336 + tmpHeight + extraSkillHeight, false, 103, 37) -- 黑长方形横线
        SetAnchorAndPivot(line, UIAnchor.Top, UIAroundPivot.Top)
        local bottomNarrow = GUI.ImageCreate(guardLove_Bg, "bottomNarrow", "1801208410", 0, 358 + tmpHeight + extraSkillHeight) -- 黑色向下箭头
        SetAnchorAndPivot(bottomNarrow, UIAnchor.Top, UIAroundPivot.Top)

        local tmp1 = GUI.ImageCreate(guardLove_Bg, "tmp1", "1801208401", GUI.GetPositionX(line1), -GUI.GetPositionY(line1), false, GUI.GetWidth(line1), GUI.GetHeight(line1)) -- 亮长方形横线
        SetAnchorAndPivot(tmp1, UIAnchor.Top, UIAroundPivot.Top)
        GUI.SetVisible(tmp1, false);

        local tmp2 = GUI.ImageCreate(guardLove_Bg, "tmp2", "1801208401", GUI.GetPositionX(line2), -GUI.GetPositionY(line2), false, GUI.GetWidth(line2), GUI.GetHeight(line2)) -- 亮长方形横线
        SetAnchorAndPivot(tmp2, UIAnchor.Top, UIAroundPivot.Top)
        GUI.SetVisible(tmp2, false);

        local bottomLine = GUI.ImageCreate(guardLove_Bg, "bottomLine", "1801208411", GUI.GetPositionX(bottomNarrow), -GUI.GetPositionY(bottomNarrow)) -- 亮向下箭头
        SetAnchorAndPivot(bottomLine, UIAnchor.Top, UIAroundPivot.Top)
        GUI.SetVisible(bottomLine, false);

        local skill = GUI.ItemCtrlCreate(guardLove_Bg, "skill", quality[1][2], 0, 386 + tmpHeight + extraSkillHeight) -- 最终技能
        SetAnchorAndPivot(skill, UIAnchor.Top, UIAroundPivot.Top)
        GUI.SetWidth(skill, 80)
        GUI.SetHeight(skill, 81)
        GUI.ItemCtrlSetElementValue(skill, eItemIconElement.Icon, "1900000000")
        local icon = GUI.ItemCtrlGetElement(skill, eItemIconElement.Icon);
        GUI.SetPositionY(icon, -1)
        --GUI.SetItemIconBtnIconScale(skill,0.9)
        GUI.SetWidth(icon, 71)
        GUI.SetHeight(icon, 70)
        GUI.RegisterUIEvent(skill, UCE.PointerClick, "GuardUI", "guardLovePageSkillTips");
        _gt.BindName(skill, "guardLovePage_Skill_4")
        -- 小红点
        --GUI.AddRedPoint(skill,UIAnchor.TopLeft)
        --GUI.SetRedPointVisable(skill,false)

        GuardUI.AddBtnUpAndActiveSp(skill)
        GuardUI.AddBtn_LevelSp(skill)

        local btnSelectImage = GUI.ImageCreate(skill, "btnSelectImage", "1800400280", 0, 0) -- 亮四边正方形框
        SetAnchorAndPivot(btnSelectImage, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetVisible(btnSelectImage, false);

        -- 技能特效
        local Special_Effects = GUI.SpriteFrameCreate(skill, "Special_Effects_end", "340891", 0, 0, true, 80, 81) -- 340891
        SetAnchorAndPivot(Special_Effects, UIAnchor.Center, UIAroundPivot.Center)
        _gt.BindName(Special_Effects, "lovePage_Special_Effects_end")
        GUI.SetVisible(Special_Effects, false)
        GUI.Play(Special_Effects)
        GUI.SetIsRaycastTarget(Special_Effects, false) -- 是否响应交互事件

        -- 设置小红点层级
        --local red_point = GUI.GetChild(skill,'redPoint')
        --GUI.SetDepth(red_point,GUI.GetDepth(Special_Effects) + 2)

    else
        GUI.SetVisible(_gt.GetUI("guardLove_Bg"), true);
    end
    -- GuardUI.RefreshGuardLovePage() -- 刷新情缘页面
end
-- 刷新情缘页面
function GuardUI.RefreshGuardLovePage()
    local guardLove_Bg = _gt.GetUI("guardLove_Bg")
    if guardLove_Bg and GuardUI.SelectGuardID and GuardUI.LovePageData then
        local guard = DB.GetOnceGuardByKey1(GuardUI.SelectGuardID)

        -- 将所有的 亮四边正方形框  关闭
        for i = 1, 4 do
            local skill_bg = _gt.GetUI("guardLovePage_Skill_" .. i)
            local btnSelectImage = GUI.GetChild(skill_bg, "btnSelectImage") -- 亮四边正方形框
            GUI.SetVisible(btnSelectImage, false)
        end

        -- 显示人物头像和星级和情缘技能   可能可以用循环来处理，许多重复代码。
        local skill_1_Level
        local isHaveGuard_1
        local skill_2_Level
        local isHaveGuard_2
        local skill_3_Level
        local isHaveGuard_3

        for i = 1, 3 do
            local LoveSkill_Data = GuardUI.LovePageData["LoveSkill_" .. i] -- 从服务器端获取到的技能数据

            local loveGuard_Element = GUI.GetChild(guardLove_Bg, "loveGuard_" .. i) -- 情缘对象节点

            -- 头像
            local loveGuard_Obj = DB.GetOnceGuardByKey1(LoveSkill_Data.LoveGuard_id) -- 侍从对象
            local loveGuard_Head_Element = GUI.GetChild(loveGuard_Element, "guard") -- 情缘头像
            GUI.ImageSetImageID(loveGuard_Element, _loveGuardQualityBg[loveGuard_Obj.Grade]) -- 头像品质
            GUI.ImageSetImageID(loveGuard_Head_Element, tostring(loveGuard_Obj.Head)) -- 头像
            GUI.SetData(loveGuard_Head_Element, "guard_id", LoveSkill_Data.LoveGuard_id)
            -- 技能
            local skill_Element = GUI.GetChild(loveGuard_Element, "skill") -- 技能节点
            local loveSkill = DB.GetOnceSkillByKey1(LoveSkill_Data.skill_id) -- 情缘技能
            local levelBg = GUI.GetChild(skill_Element, "levelBg") -- 背景
            local level_grade = GUI.GetChild(levelBg, "txt") -- 等级文本

            GUI.ItemCtrlSetElementValue(skill_Element, eItemIconElement.Icon, tostring(loveSkill.Icon)) -- 设置情缘技能图片
            GUI.ItemCtrlSetElementValue(skill_Element, eItemIconElement.Border, quality[loveSkill.SkillQuality][2]) -- 设置情缘技能背景
            GUI.SetData(skill_Element, "skill_id", loveSkill.Id) -- tips 需要
            GUI.SetData(skill_Element, "skillIndex", i) -- 技能升级需要
            -- 插入技能等级，用于显示tips
            GUI.SetData(skill_Element, 'skill_level', LoveSkill_Data.skill_level)

            local activeSp = GUI.GetChild(skill_Element, "activeSp") -- 加号图片
            local upSp = GUI.GetChild(skill_Element, "upSp") -- 向上升级箭头
            local skill_Level = LoveSkill_Data.skill_level -- 情缘技能等级
            -- 技能等级
            if i == 1 then
                skill_1_Level = skill_Level
            end
            if i == 2 then
                skill_2_Level = skill_Level
            end
            if i == 3 then
                skill_3_Level = skill_Level
            end

            -- 线条
            local line1 = GUI.GetChild(guardLove_Bg, "line" .. i) -- 向下黑色箭头
            local line1_1 = GUI.GetChild(line1, "sp") -- 向下亮箭头

            local line2 = GUI.GetChild(guardLove_Bg, "line2_" .. i) -- 亮长方形竖线

            -- 技能特效
            local lovePage_Special_Effects = _gt.GetUI("lovePage_Special_Effects_" .. i)

            local isHaveGuard = LD.IsHaveGuard(LoveSkill_Data.LoveGuard_id) -- 判断此侍从是否拥有

            if i == 1 then
                isHaveGuard_1 = isHaveGuard
            end
            if i == 2 then
                isHaveGuard_2 = isHaveGuard
            end
            if i == 3 then
                isHaveGuard_3 = isHaveGuard
            end

            if isHaveGuard then
                -- 星级
                local Star1_Count = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(LoveSkill_Data.LoveGuard_id))) -- 获取当前侍从星级
                -- 倒叙变黑上一次星星
                for j = starCount - 1, Star1_Count, -1 do
                    local guard_star_j = GUI.GetChild(loveGuard_Element, "star_" .. j)
                    GUI.ImageSetImageID(guard_star_j, "1801208420")
                end
                -- 变亮星星
                for j = 0, Star1_Count - 1 do
                    local guard_1_star_j = GUI.GetChild(loveGuard_Element, "star_" .. j)
                    GUI.ImageSetImageID(guard_1_star_j, "1801208360") -- 星星变亮
                    GUI.ImageSetGray(loveGuard_Head_Element, false)
                end
                -- 技能部分
                if skill_Level == 0 then
                    -- 技能等级为0

                    GUI.ItemCtrlSetIconGray(skill_Element, true) -- 技能变灰
                    GUI.SetVisible(levelBg, false) -- 技能等级图标不显示
                    GUI.SetVisible(line2, false) -- 亮长方形竖线不可见
                    GUI.SetVisible(activeSp, false) -- 技能从0升级加号变灰
                    GUI.SetVisible(upSp, false) -- 技能升级箭头变灰
                    GUI.SetVisible(lovePage_Special_Effects, false) -- 关闭特效


                    if LoveSkill_Data.CanUp then
                        -- 是否可升级 情缘侍从星级大于0
                        GUI.SetVisible(activeSp, true)
                        GUI.SetData(skill_Element, "isUpSkill", "true") -- 技能是否可升级
                        GUI.SetVisible(lovePage_Special_Effects, true) -- 显示特效
                        -- 显示小红点
                        --GUI.SetRedPointVisable(skill_Element,true)
                        GlobalProcessing.SetRetPoint(skill_Element, true, UIDefine.red_type.common)

                    else
                        GUI.SetVisible(activeSp, false)
                        GUI.SetVisible(lovePage_Special_Effects, false) -- 关闭特效
                        -- 关闭小红点
                        --GUI.SetRedPointVisable(skill_Element,false)
                        GlobalProcessing.SetRetPoint(skill_Element, false, UIDefine.red_type.common)

                    end

                elseif skill_Level > 0 then
                    GUI.ItemCtrlSetIconGray(skill_Element, false) -- 技能变亮
                    GUI.SetVisible(levelBg, true) -- 技能等级图标显示
                    GUI.ImageSetImageID(levelBg, _IconRightCornerRes[loveSkill.SkillQuality]) -- 设置等级品质
                    GUI.StaticSetText(level_grade, skill_Level)

                    GUI.SetVisible(activeSp, false) -- 加号变灰

                    GUI.SetVisible(line2, true) -- 亮长方形竖线可见

                    if LoveSkill_Data.CanUp then
                        -- 是否可升级 情缘侍从等级大于技能等级
                        GUI.SetVisible(upSp, true)
                        GUI.SetData(skill_Element, "isUpSkill", "true") -- 技能是否可升级
                        GUI.SetVisible(lovePage_Special_Effects, true) -- 显示特效
                        -- 显示小红点
                        --GUI.SetRedPointVisable(skill_Element,true)
                        GlobalProcessing.SetRetPoint(skill_Element, true, UIDefine.red_type.common)
                    else
                        GUI.SetVisible(upSp, false)
                        GUI.SetVisible(activeSp, false)
                        GUI.SetData(skill_Element, "isUpSkill", "false") -- 技能是否可升级
                        GUI.SetVisible(lovePage_Special_Effects, false) -- 关闭特效
                        -- 关闭小红点
                        --GUI.SetRedPointVisable(skill_Element,false)
                        GlobalProcessing.SetRetPoint(skill_Element, false, UIDefine.red_type.common)
                    end
                end

                GUI.SetVisible(line1_1, true) -- 向下亮箭头可见
            else
                for j = 0, starCount - 1 do
                    -- 变黑全部星星
                    local guard_1_star_j = GUI.GetChild(loveGuard_Element, "star_" .. j)
                    GUI.ImageSetImageID(guard_1_star_j, "1801208420")
                end
                GUI.ImageSetGray(loveGuard_Head_Element, true) --头像变灰

                GUI.ItemCtrlSetIconGray(skill_Element, true) -- 技能变灰
                GUI.SetVisible(levelBg, false) -- 技能等级图标不显示

                GUI.SetVisible(line1_1, false) -- 向下亮箭头不可见
                GUI.SetVisible(line2, false) -- 亮长方形竖线不可见

                GUI.SetVisible(activeSp, false) -- 技能从0升级加号变灰
                GUI.SetVisible(upSp, false) -- 技能升级箭头变灰
                GUI.SetVisible(lovePage_Special_Effects, false) -- 关闭特效

                GUI.SetData(skill_Element, "isUpSkill", "false") -- 技能是否可升级

                -- 关闭小红点
                --GUI.SetRedPointVisable(skill_Element,false)
                GlobalProcessing.SetRetPoint(skill_Element, false, UIDefine.red_type.common)
            end
        end

        -- 横线显示
        local tmp1 = GUI.GetChild(guardLove_Bg, "tmp1") -- 左横线
        local tmp2 = GUI.GetChild(guardLove_Bg, "tmp2") -- 右横线
        if skill_2_Level > 0 and isHaveGuard_2 then
            if skill_1_Level > 0 and isHaveGuard_1 then
                GUI.SetVisible(tmp1, true)
            else
                GUI.SetVisible(tmp1, false)
            end

            if skill_3_Level > 0 and isHaveGuard_3 then
                GUI.SetVisible(tmp2, true)
            else
                GUI.SetVisible(tmp2, false)
            end
        else
            GUI.SetVisible(tmp1, false)
            GUI.SetVisible(tmp2, false)
        end


        -- 最终技能
        local LoveSkill_4 = GuardUI.LovePageData.AllLoveAddSkill1
        local skill = DB.GetOnceSkillByKey1(LoveSkill_4.skill_id)
        local skill_Icon = GUI.GetChild(guardLove_Bg, "skill")
        GUI.ItemCtrlSetElementValue(skill_Icon, eItemIconElement.Icon, tostring(skill.Icon)) -- 技能图片
        GUI.ItemCtrlSetElementValue(skill_Icon, eItemIconElement.Border, quality[skill.SkillQuality][2]) -- 技能背景
        GUI.SetData(skill_Icon, "skill_id", skill.Id)
        GUI.SetData(skill_Icon, "skillIndex", 4) -- 技能升级需要
        -- 插入技能等级，用于显示tips
        GUI.SetData(skill_Icon, 'skill_level', LoveSkill_4.skill_level)

        local levelBg = GUI.GetChild(skill_Icon, "levelBg")
        local levelText = GUI.GetChild(levelBg, "txt")

        local activeSp_4 = GUI.GetChild(skill_Icon, "activeSp") -- 加号图片
        local upSp_4 = GUI.GetChild(skill_Icon, "upSp") -- 向上升级箭头

        local skill_Level = LoveSkill_4.skill_level -- 最终技能等级

        local bottomLine = GUI.GetChild(guardLove_Bg, "bottomLine") -- 向下亮箭头

        local lovePage_Special_Effects_end = _gt.GetUI("lovePage_Special_Effects_end")

        if isHaveGuard_2 and isHaveGuard_1 and isHaveGuard_3 and skill_2_Level > 0 and skill_3_Level > 0 and skill_1_Level > 0 then
            GUI.SetVisible(bottomLine, true) -- 向下箭头
            if skill_Level == 0 then

                GUI.ItemCtrlSetIconGray(skill_Icon, true) -- 设置技能变灰
                GUI.SetVisible(levelBg, false) -- 技能等级图标变灰
                GUI.SetVisible(activeSp_4, false) -- 技能从0升级加号变灰
                GUI.SetVisible(upSp_4, false) -- 技能升级箭头变灰
                GUI.SetVisible(lovePage_Special_Effects_end, false) -- 关闭特效

                if LoveSkill_4.CanUp then
                    GUI.SetData(skill_Icon, "isUpSkill", "true") -- 技能是否可升级
                    GUI.SetVisible(activeSp_4, true)
                    GUI.SetVisible(lovePage_Special_Effects_end, true) -- 显示特效
                    -- 显示小红点
                    --GUI.SetRedPointVisable(skill_Icon,true)
                    GlobalProcessing.SetRetPoint(skill_Icon, true, UIDefine.red_type.common)
                else
                    GUI.SetVisible(activeSp_4, false)
                    GUI.SetVisible(lovePage_Special_Effects_end, false) -- 关闭特效
                    -- 关闭小红点
                    --GUI.SetRedPointVisable(skill_Icon,false)
                    GlobalProcessing.SetRetPoint(skill_Icon, false, UIDefine.red_type.common)

                end
            elseif skill_Level > 0 then
                GUI.ItemCtrlSetIconGray(skill_Icon, false) -- 取消技能被灰
                GUI.SetVisible(levelBg, true)
                GUI.ImageSetImageID(levelBg, _IconRightCornerRes[skill.SkillQuality]) -- 技能等级图标
                GUI.StaticSetText(levelText, skill_Level)
                GUI.SetVisible(activeSp_4, false) -- 加号变灰
                if LoveSkill_4.CanUp then
                    -- 是否可用 最小技能等级大于最终技能等级
                    GUI.SetVisible(upSp_4, true)
                    GUI.SetData(skill_Icon, "isUpSkill", "true") -- 技能是否可升级
                    GUI.SetVisible(lovePage_Special_Effects_end, true) -- 显示特效
                    -- 显示小红点
                    --GUI.SetRedPointVisable(skill_Icon,true)
                    GlobalProcessing.SetRetPoint(skill_Icon, true, UIDefine.red_type.common)
                else
                    GUI.SetVisible(upSp_4, false)
                    GUI.SetVisible(activeSp_4, false)
                    GUI.SetData(skill_Icon, "isUpSkill", "false") -- 技能是否可升级
                    GUI.SetVisible(lovePage_Special_Effects_end, false) -- 关闭特效
                    -- 关闭小红点
                    --GUI.SetRedPointVisable(skill_Icon,false)
                    GlobalProcessing.SetRetPoint(skill_Icon, false, UIDefine.red_type.common)
                end
            end
        else
            GUI.ItemCtrlSetIconGray(skill_Icon, true) -- 设置技能变灰
            GUI.SetVisible(levelBg, false) -- 技能等级图标变灰
            GUI.SetVisible(bottomLine, false) -- 向下亮箭头变灰

            GUI.SetVisible(activeSp_4, false) -- 技能从0升级加号变灰
            GUI.SetVisible(upSp_4, false) -- 技能升级箭头变灰

            GUI.SetData(skill_Icon, "isUpSkill", "false") -- 技能是否可升级
            GUI.SetVisible(lovePage_Special_Effects_end, false) -- 关闭特效

            -- 关闭小红点
            --GUI.SetRedPointVisable(skill_Icon,false)
            GlobalProcessing.SetRetPoint(skill_Icon, false, UIDefine.red_type.common)
        end

    end
end
-- 情缘侍从头像tips点击事件
function GuardUI.OnLoveGuardItemBtnClick(guid)
    local guard_Bg = _gt.GetUI("guard_Bg")
    local btn = GUI.GetByGuid(guid)
    local guard_Id = tonumber(GUI.GetData(btn, "guard_id"))

    if not (guard_Bg and btn and guard_Id) then
        test("情缘页面中 情缘侍从头像tips点击事件 中 数据为空nil错误")
        return
    end

    local GuardHeadTips = GuardUI.CreateLoveGuardHeadTips(guard_Bg, "GuardHeadTips", guard_Id, 0, 0)
    _gt.BindName(GuardHeadTips, "GuardHeadTips")

    -- 前往查看按钮
    local go_Guard_Btn = GUI.ButtonCreate(GuardHeadTips, "go_Guard_Btn", "1800402110", 0, -8, Transition.ColorTint, "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">前往查看</size></color>", 150, 50, false)
    SetAnchorAndPivot(go_Guard_Btn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.SetData(go_Guard_Btn, "guard_Id", guard_Id)
    GUI.RegisterUIEvent(go_Guard_Btn, UCE.PointerClick, "GuardUI", "goGuardAttr")
    GUI.AddWhiteName(GuardHeadTips, GUI.GetGuid(go_Guard_Btn)) -- 添加到对应的点击销毁白名单
end
-- 情缘侍从头像tips
function GuardUI.CreateLoveGuardHeadTips(parent, name, guardId, x, y, extHeight)

    if not (parent and name and guardId) then
        test("创建情缘侍从头像tips时 传入参数为空 ")
        return
    end

    local guard = DB.GetOnceGuardByKey1(tonumber(guardId))

    if extHeight == nil then
        extHeight = 0
    end

    local GuardHeadTips = GUI.TipsCreate(parent, name, x, y, extHeight) -- ItemTipsCreate(parent, name, x, y, extHeight)
    GUI.SetIsRemoveWhenClick(GuardHeadTips, true) -- 是否检测到点击就销毁
    GUI.SetHeight(GuardHeadTips, 181)

    -- 头像
    local Icon = GUI.TipsGetItemIcon(GuardHeadTips)
    GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Icon, tostring(guard.Head)) -- 设置头像
    GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Border, quality[guard.Grade][2]) -- 设置品质
    GUI.SetWidth(Icon, 80)
    GUI.SetHeight(Icon, 81)
    local headImage = GUI.ItemCtrlGetElement(Icon, eItemIconElement.Icon)
    GUI.SetWidth(headImage, 71)
    GUI.SetHeight(headImage, 70)

    -- 侍从名称
    local guard_Name = GUI.CreateStatic(GuardHeadTips, "GuardName", guard.Name, 20, 5, 200, 50)
    SetAnchorAndPivot(guard_Name, UIAnchor.Top, UIAroundPivot.Top)
    GUI.StaticSetFontSize(guard_Name, 22)
    GUI.SetColor(guard_Name, UIDefine.GradeColor[guard.Grade])
    GUI.StaticSetAlignment(guard_Name, TextAnchor.LowerLeft)

    local guard_Type = GUI.CreateStatic(GuardHeadTips, "GuardType", "类型： 侍从", -5, 50, 150, 40)
    SetAnchorAndPivot(guard_Type, UIAnchor.Top, UIAroundPivot.Top)
    GUI.StaticSetFontSize(guard_Type, 20)
    GUI.SetColor(guard_Type, UIDefine.YellowColor)
    GUI.StaticSetAlignment(guard_Type, TextAnchor.LowerLeft)

    -- 侍从介绍
    local infoLabel = GUI.TipsAddLabel(GuardHeadTips, 25, guard.Tips, UIDefine.WhiteColor, false)
    SetAnchorAndPivot(btn, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.SetPositionX(infoLabel,20)
    GUI.SetWidth(infoLabel, 350)
    GUI.StaticSetAlignment(infoLabel, TextAnchor.MiddleLeft)

    return GuardHeadTips
end
-- "前往查看"按钮点击事件
function GuardUI.goGuardAttr(guid)

    local guardId = GUI.GetData(GUI.GetByGuid(guid), "guard_Id")
    GuardUI.SelectGuardID = tonumber(guardId)
    GuardUI.SelectType = 0  -- 将侍从种类列表改为全部
    -- 刷新左边选中
    GuardUI.UpdateGuardLst()
    GuardUI.autoScrollPosition(GuardUI.SelectGuardID) -- 自动滚动到左边侍从列表位置
    -- 刷新中间形象
    GuardUI.ShowGuardDetailInfo()
    -- 跳转到属性页面
    GuardUI.OnAttrTabBtnClick()
    -- 关闭头像tips
    local GuardHeadTips = _gt.GetUI("GuardHeadTips")
    GUI.Destroy(GuardHeadTips)
    -- 刷新页签小红点
    GuardUI._refresh_bookmark_red(GuardUI.SelectGuardID)
    -- 刷新侍从技能、侍从属性按钮上的小红点
    GuardUI.OnSelectGuardAttr()
end
-- 技能tips事件+升级技能事件
function GuardUI.guardLovePageSkillTips(guid)

    -- 获取   技能的id  父类
    local skill_bg = GUI.GetByGuid(guid)
    local skill_id = GUI.GetData(skill_bg, "skill_id") -- 技能id
    local skill_level = tonumber(GUI.GetData(skill_bg, 'skill_level'))
    local panelBg = _gt.GetUI("panelBg") -- 父类

    local btnSelectImage = GUI.GetChild(skill_bg, "btnSelectImage") -- 亮四边正方形框

    if not (skill_bg and skill_id and panelBg and btnSelectImage) then
        test("情缘页面 技能tips事件+升级技能事件 中数据为空nil错误")
        return
    end

    local isUpSkill = GUI.GetData(skill_bg, "isUpSkill") -- 是否可升级

    if isUpSkill == "true" then
        -- 获取侍从guid和技能index
        local guardGuid = LD.GetGuardGUIDByID(GuardUI.SelectGuardID)
        local skillIndex = GUI.GetData(skill_bg, "skillIndex")
        -- 发送升级请求
        if skillIndex == "4" then
            -- 当升级技能是最终技能时
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "SuperLoveSkillUp", tostring(guardGuid))
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "CommonLoveSkillUp", tostring(guardGuid), tostring(skillIndex))
        end
    else
        -- 如果不可升级 弹出tips
        -- 如果技能为空，则不需要注册事件，须处理
        if GUI.ItemCtrlGetElementValue(skill_bg, eItemIconElement.Icon) ~= "1900000000" then
            -- 判断图片是否不是 ？图片
            Tips.CreateSkillId(tonumber(skill_id), panelBg, "activeSkill_Tips", 0, 0, 0, 0, skill_level)

            -- 将所有的 亮四边正方形框  关闭
            for i = 1, 4 do
                local skill_bg = _gt.GetUI("guardLovePage_Skill_" .. i)
                local btnSelectImage = GUI.GetChild(skill_bg, "btnSelectImage") -- 亮四边正方形框
                GUI.SetVisible(btnSelectImage, false)
            end

            GUI.SetVisible(btnSelectImage, true)
        end
    end

end

---------------------------情缘部分结束-------------------------------

---------------------------自动滚动到左边侍从列表位置开始---------------
function GuardUI.autoScrollPosition(guardId)

    if guardId == nil then
        test("自动滚动到左边侍从列表位置 传入参数为空")
        return
    end

    local allList = LD.GetGuardList_Have_Sorted() -- 获取所有的侍从id
    local selected_Guard_Index = 0 -- 传入侍从在所有侍从中的下标
    for i = 0, allList.Count - 1 do
        if allList[i] == guardId then
            selected_Guard_Index = i -- 这里不要加1，不然显示位置刚好在上一格
            break
        end
    end

    local scr_Guard = _gt.GetUI("scr_Guard")
    -- local n = selected_Guard_Index/allList.Count

    --CDebug.LogError(tostring(n))
    --CDebug.LogError(tostring(selected_Guard_Index))
    --CDebug.LogError(tostring(allList.Count))
    GUI.ScrollRectSetNormalizedPosition(scr_Guard, Vector2.New(0, selected_Guard_Index / allList.Count))
end
---------------------------自动滚动到左边侍从列表位置结束----------------


---------------------------人物气势特效开始-----------------------------
-- 人物特效表 从二星开始
local _RoleEffectTable = {
    10, 11, 12, 13, 14
}
-- 销毁人物特效ID列表
GuardUI._DestroyRoleEffectTable = {}

function GuardUI.addRoleEffect()

    local _RoleModel = _gt.GetUI("GuardModel") -- 获取人物模型
    if _RoleModel == nil then
        test("添加人物气势特效时，获取人物模型为空")
        return
    end

    if GuardUI.SelectGuardID == nil then
        test("添加人物气势特效时，获取选中侍从ID为空")
        return
    end

    -- 删除人物特效
    local DestroyRoleEffectID = GuardUI._DestroyRoleEffectTable[tostring(GuardUI.SelectGuardID)]
    if DestroyRoleEffectID ~= nil then
        -- 获取创建特效时得到的特效ID
        GUI.DestroyRoleEffect(_RoleModel, DestroyRoleEffectID)
        GuardUI._DestroyRoleEffectTable[tostring(GuardUI.SelectGuardID)] = nil
    end
    -- 获取人物当前星级
    local currentSelectedGuardStar = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardUI.SelectGuardID)))

    -- 添加人物特效
    if currentSelectedGuardStar > 1 then
        -- 防止星级为1
        local newDestroyRoleEffectID = GUI.CreateRoleEffect(_RoleModel, _RoleEffectTable[currentSelectedGuardStar - 1]) -- 添加人物特效
        -- 更新销毁人物特效ID
        GuardUI._DestroyRoleEffectTable[tostring(GuardUI.SelectGuardID)] = newDestroyRoleEffectID
    end
end
---------------------------人物气势特效结束-----------------------------

---------------------------start #加成 侍从加成start------------------------
-- 页签点击事件
function GuardUI.OnAddAttrTabBtnClick()
    -- 如果当前页签就是加成时，则啥都不执行，防止多次刷新
    if GuardUI.TabIndex == 4 then
        UILayout.OnTabClick(4, tabList)
        return
    end
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[4][1])
    local Level = MainUI.MainUISwitchConfig["侍从"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        UILayout.OnTabClick(4, tabList)
        GuardUI.Right_RefreshMethod(4)

        -- 隐藏全部内容
        local panelBg = _gt.GetUI("panelBg")
        local guard_Bg = GUI.GetChild(panelBg, "guard_Bg")
        GUI.SetVisible(guard_Bg, false)

        GuardUI.CreateAddAttrPage()
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, tostring(Level) .. "级开启" .. Key .. "功能")
        UILayout.OnTabClick(GuardUI.TabIndex, tabList)
        return
    end
    GuardUI.TeamReset()
end
-- 创建侍从加成页面
local guardAddArrItemSize = Vector2.New(490, 100)
function GuardUI.CreateAddAttrPage()
    -- 判断此页面是否存在
    local AddAttrPage = _gt.GetUI("AddAttrPage")
    if AddAttrPage == nil then
        -- 创建此页面
        local panelBg = _gt.GetUI("panelBg")
        if panelBg then
            AddAttrPage = GUI.GroupCreate(panelBg, "AddAttrPage", 0, 0, 1, 1) -- 创建阵法加成父类
            _gt.BindName(AddAttrPage, "AddAttrPage")

            -- 人物角色组
            local rolePanelBg = GUI.GroupCreate(AddAttrPage, "rolePanelBg", -300, 0, 1, 1);
            SetAnchorAndPivot(rolePanelBg, UIAnchor.Center, UIAroundPivot.Center)
            _gt.BindName(rolePanelBg, "AddAttrPage_RolePanelBg")

            -- 横框，字体背景
            local fightBg = GUI.ImageCreate(rolePanelBg, "fightBg", "1801300180", 0, -240, false, 333, 52);
            SetAnchorAndPivot(fightBg, UIAnchor.Center, UIAroundPivot.Center)

            -- 🗡剑型图标
            local fightFlower1 = GUI.ImageCreate(fightBg, "fightFlower1", "1800407010", -90, 0);
            SetAnchorAndPivot(fightFlower1, UIAnchor.Center, UIAroundPivot.Center)

            -- 角色战斗力字体图片
            local fightFlower2 = GUI.ImageCreate(fightBg, "fightFlower2", "1801405360", -20, 0);
            SetAnchorAndPivot(fightFlower2, UIAnchor.Center, UIAroundPivot.Center)

            -- 战斗力
            local fightTxt = GUI.CreateStatic(fightBg, "fightTxt", "0", 45, 1, 150, 30, "system", true, false);
            GUI.SetPivot(fightTxt, UIAroundPivot.Left);
            GUI.StaticSetAlignment(fightTxt, TextAnchor.MiddleLeft)
            GUI.StaticSetFontSize(fightTxt, fontSize);
            GUI.SetColor(fightTxt, colorTypeOne);
            _gt.BindName(fightTxt, "AddAttrPage_FightTxt")

            -- I 型图片
            local scoreHint = GUI.ButtonCreate(fightBg, "scoreHint", "1800702030", -127, 0, Transition.ColorTint, "")
            SetAnchorAndPivot(scoreHint, UIAnchor.Center, UIAroundPivot.Center)
            GUI.RegisterUIEvent(scoreHint, UCE.PointerClick, "GuardUI", "OnScoreHintBtnClick")

            -- 灰色字体背景图片
            local bottomBg = GUI.ImageCreate(rolePanelBg, "bottomBg", "1801401100", 0, 260);
            local txt = GUI.CreateStatic(bottomBg, "txt", "侍从加成可永久提升主角属性", 0, 0, 300, 26);
            SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
            GUI.StaticSetFontSize(txt, fontSize);

            -- 侍从加成字体上的图片
            local guardAddArrTip = GUI.ButtonCreate(bottomBg, "guardAddArrTip", "1801202200", 355, -10, Transition.ColorTint);
            SetAnchorAndPivot(guardAddArrTip, UIAnchor.Left, UIAroundPivot.Left)
            -- 侍从加成字体图片
            local sp = GUI.ImageCreate(guardAddArrTip, "sp", "1801205140", 0, 6)
            SetAnchorAndPivot(sp, UIAnchor.Bottom, UIAroundPivot.Bottom)
            GUI.RegisterUIEvent(guardAddArrTip, UCE.PointerClick, "GuardUI", "OnGuardAddArrBtnClick");

            -- 右边侍从加成属性
            local rightBg = GUI.ImageCreate(AddAttrPage, "rightBg", "1801401110", 520, 8, false, 537, 565);
            SetAnchorAndPivot(rightBg, UIAnchor.Right, UIAroundPivot.Right)
            _gt.BindName(rightBg, "AddAttrPage_RightBg")

            -- 底板
            local scrBg = GUI.ImageCreate(rightBg, "scrBg", "1800400200", 0, 68, false, 502, 480)
            SetAnchorAndPivot(scrBg, UIAnchor.Top, UIAroundPivot.Top)

            -- 按钮
            local arrangeBtn = GUI.ButtonCreate(rightBg, "arrangeBtn", "1801201220", 52, 23, Transition.ColorTint, "", 170, 40, false);
            SetAnchorAndPivot(arrangeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
            local btnTxt = GUI.CreateStatic(arrangeBtn, "btnTxt", "全部侍从", -20, 0, 100, 26);
            SetAnchorAndPivot(btnTxt, UIAnchor.Left, UIAroundPivot.Left)
            GUI.StaticSetFontSize(btnTxt, fontSize);
            GUI.SetColor(btnTxt, colorTypeOne);
            GUI.RegisterUIEvent(arrangeBtn, UCE.PointerClick, "GuardUI", "OnArrangeGuardBtnClick")

            -- 滚动列表展示  改为loopScrollRect 解决第一次打开时 要创建许多节点 导致卡顿问题
            --local scr=GUI.ScrollRectCreate( scrBg, "scr", 0, 7, guardAddArrItemSize.x, 468, 0, false, guardAddArrItemSize, UIAroundPivot.Top, UIAnchor.Top, 1)
            local scr = GUI.LoopScrollRectCreate(scrBg, "scr", 0, 7, guardAddArrItemSize.x, 468,
                    "GuardUI", "Create_AddAttrPage_Scr", "GuardUI", "Refresh_AddAttrPage_SCr",
                    0, false, guardAddArrItemSize, 1, UIAroundPivot.Top, UIAnchor.Top)
            SetAnchorAndPivot(scr, UIAnchor.Top, UIAroundPivot.Top)
            GUI.ScrollRectSetChildAnchor(scr, UIAnchor.Top)
            GUI.ScrollRectSetChildPivot(scr, UIAroundPivot.Top)
            GUI.ScrollRectSetChildSpacing(scr, Vector2.New(0, 0))
            _gt.BindName(scr, "AddAttrPage_Scr")
        end
    else
        -- 显示此页面
        GUI.SetVisible(AddAttrPage, true)
    end
    --GuardUI.RefreshAddAttrPage_Left()
    -- 当再次打开界面时，使侍从种类数据为‘全部'
    if GuardUI.showAddAttrData and GuardUI._guard_add_attr_data then
        local rightBg = _gt.GetUI("AddAttrPage_RightBg") -- 父类
        local btnTxt = GUI.GetChild(GUI.GetChild(rightBg, "arrangeBtn"), "btnTxt")  -- 全部侍从按钮文本
        if GUI.StaticGetText(btnTxt) == '全部侍从' then
            GuardUI.showAddAttrData = GuardUI._guard_add_attr_data['all']
        end
    end
    GuardUI.getLeftAddAttrData()
    GuardUI.getRightAddAttrData()
end

local roleSpriteInfo = {
    [31] = { "1800107010", "600001779", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [32] = { "1800107020", "600001842", "(0,2.24,-3.25),(0,0,0,1),True,5,0.42,4.27,60" },
    [33] = { "1800107030", "600001989", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [34] = { "1800107040", "600001982", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [35] = { "1800107050", "600001995", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [36] = { "1800107060", "600001880", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [37] = { "1800107070", "600001921", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [38] = { "1800107080", "600001885", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    [39] = { "1800107090", "600001837", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    [40] = { "1800107100", "3000001490", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    [41] = { "1800107110", "600001956", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    [42] = { "1800107120", "600001959", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
}
local attrNameTransform = {
    ["血量上限"] = "血量",
    ["物理攻击"] = "攻击",
    ["物理防御"] = "物防",
    ["法术防御"] = "法防",
    ["战斗速度"] = "速度",
    ["物暴率"] = "暴击"
}

-- 刷新左边的方法
local AllAddAttrData_Sorted = nil
function GuardUI.RefreshAddAttrPage_Left()
    -- 所需要的数据

    -- 整理数据
    local GuardSortTypeArr = {}
    if GuardUI.AllAddAttrData == nil or GuardUI.CombatPower == nil then
        test("GuardUI界面  GuardUI.RefreshAddAttrPage_Left()方法 GuardUI.AllAddAttrData 数据为空 ")
        return
    end

    for k, v in pairs(GuardUI.AllAddAttrData) do
        local attrObj = DB.GetOnceAttrByKey1(k)
        local attrName = attrNameTransform[attrObj.KeyName]
        --if attrObj.KeyName == "血量上限" then attrName = "血量" end
        --if attrObj.KeyName == "物理攻击" then attrName = "攻击" end
        --if attrObj.KeyName == "物理防御" then attrName = "防御" end
        --if attrObj.KeyName == "法术防御" then attrName = "法防" end
        --if attrObj.KeyName == "战斗速度" then attrName = "速度" end
        --if attrObj.KeyName == "物暴率" then attrName = "暴击" end
        table.insert(GuardSortTypeArr, { ["AttrName"] = attrName, ["Value"] = v })
    end

    AllAddAttrData_Sorted = GuardSortTypeArr

    local Combat_Effectiveness = GuardUI.CombatPower.PlayerValue  -- 角色战斗力
    --local role = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole)) -- 角色对象
    -- 所需要修改的节点
    local rolePanelBg = _gt.GetUI("AddAttrPage_RolePanelBg") -- 父类
    local fightTxt = _gt.GetUI("AddAttrPage_FightTxt") -- 战斗力字体

    --设置战斗力
    if fightTxt then
        GUI.StaticSetText(fightTxt, Combat_Effectiveness)
    end

    -- 创建角色模型
    if rolePanelBg then

        local SelfTemplateID = CL.GetRoleTemplateID() -- 获取当前角色id
        if not SelfTemplateID or SelfTemplateID == 0 then
            return
        end
        local _RoleNodeModel = _gt.GetUI("AddAttrPage_RoleNodeModel")
        if _RoleNodeModel == nil then
            -- 如果父类不存在 创建父类
            _RoleNodeModel = GUI.RawImageCreate(rolePanelBg, false, "RoleNodeModel", "", 0, 0, 3, false, 600, 600)
            GUI.SetIsRaycastTarget(_RoleNodeModel, false); -- 是否响应交互事件
            SetAnchorAndPivot(_RoleNodeModel, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetDepth(_RoleNodeModel, 0)
            _gt.BindName(_RoleNodeModel, "AddAttrPage_RoleNodeModel")
        end

        local _roleModel = _gt.GetUI("AddAttrPage_RoleModel")
        if _roleModel == nil and _RoleNodeModel ~= nil then
            _roleModel = GUI.RawImageChildCreate(_RoleNodeModel, false, "RoleModel", roleSpriteInfo[SelfTemplateID][2], 0, 0)
            _gt.BindName(_roleModel, "AddAttrPage_RoleModel")
            GUI.AddToCamera(_RoleNodeModel);
            GUI.RawImageSetCameraConfig(_RoleNodeModel, roleSpriteInfo[SelfTemplateID][3]);
            UILayout.SetSameAnchorAndPivot(_roleModel, UILayout.Center)
            GUI.RawImageChildSetModleRotation(_roleModel, Vector3.New(0, 180, 0))
        end

    end

end
-- I图片的点击事件
function GuardUI.OnScoreHintBtnClick(guid)
    if GuardUI.CombatPower == nil then
        test("GuardUI界面  GuardUI.OnScoreHintBtnClick I图片的点击事件 传入战力参数为空")
        return
    end

    local combatPower = GuardUI.CombatPower  -- 战力列表

    local panelBg = _gt.GetUI("panelBg")
    if panelBg == nil then
        return
    end
    local hint = GUI.GetChild(panelBg, "hint")
    if hint == nil then
        hint = GUI.ImageCreate(panelBg, "hint", "1800400290", -220, -139, false, 480, 155)
        GUI.SetIsRemoveWhenClick(hint, true)
        SetAnchorAndPivot(hint, UIAnchor.Center, UIAroundPivot.Center)
        GUI.AddWhiteName(hint, guid)

        local hintText = GUI.CreateStatic(hint, "hintText", "", 0, 15, 200, 70, "system", true)
        GUI.StaticSetFontSize(hintText, 22)
        GUI.StaticSetAlignment(hintText, TextAnchor.MiddleLeft)
        SetAnchorAndPivot(hintText, UIAnchor.Center, UIAroundPivot.Center)

        local roleScore = combatPower.PlayerValue  --CL.GetIAttr(role_attr.role_fight_value)
        local guardScore = combatPower.GuardValue  --GlobalUtils.GetGuardScore()
        local petScore = combatPower.PetValue  --GlobalUtils.GetPetScore()
        local score = roleScore + petScore + guardScore
        score = "总战力：" .. "<color=#FCF326>" .. score .. "</color>" .. "\n"
        roleScore = "角色战力：" .. "<color=#FCF326>" .. roleScore .. "</color>" .. "\n"
        petScore = "宠物战力：" .. "<color=#FCF326>" .. petScore .. "</color>" .. "(战力最高的5个宠物的总和)" .. "\n"
        guardScore = "侍从战力：" .. "<color=#FCF326>" .. guardScore .. "</color>" .. "(战力最高的4个侍从的总和)" .. "\n"
        local allString = "总战力=角色战力+宠物战力+侍从战力" .. "\n"

        local hintStr = allString .. score .. roleScore .. petScore .. guardScore --GlobalUtils.GetRoleScoreText(score, roleScore, petScore, guardScore)

        GUI.StaticSetText(hintText, hintStr)

        local height = GUI.StaticGetLabelPreferHeight(hintText)
        local width = GUI.StaticGetLabelPreferWidth(hintText)

        --GUI.SetHeight(hint, height + 30)
        GUI.SetHeight(hintText, height)
        --GUI.SetWidth(hint, width + 30)
        GUI.SetWidth(hintText, width)
    else
        GUI.Destroy(hint)
    end
end

-- 请求 左边界面的 数据
function GuardUI.getLeftAddAttrData()
    -- FormGuard.GetAttrAddList(player)   --玩家已有侍从加成属性列表  执行刷新左边的方法GuardUI.RefreshAddAttrPage_Left()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "GetAttrAddList") -- 绑定变量 GuardUI.AllAddAttrData {[36]=22,[43]=9,} 属性id  加成属性值
end

-- 侍从加成点击事件
local colorYellow1 = Color.New(252 / 255, 243 / 255, 38 / 255, 255 / 255);
local colorYellow2 = Color.New(255 / 255, 242 / 255, 208 / 255, 255 / 255)
function GuardUI.OnGuardAddArrBtnClick()
    -- 需要的数据
    local GuardSortTypeArr = nil -- 侍从加成数据

    -- 整理数据
    if AllAddAttrData_Sorted == nil then
        test("GuardUI界面 GuardUI.OnGuardAddArrBtnClick()侍从加成点击事件 GuardUI.AllAddAttrData 数据为空 ")
        return
    else
        GuardSortTypeArr = AllAddAttrData_Sorted
    end

    --for k,v in pairs(GuardUI.AllAddAttrData) do
    --    local attrObj = DB.GetOnceAttrByKey1(k)
    --    local attrName = nil
    --    if attrObj.KeyName == "血量上限" then attrName = "血量" end
    --    if attrObj.KeyName == "物理攻击" then attrName = "攻击" end
    --    if attrObj.KeyName == "物理防御" then attrName = "防御" end
    --    if attrObj.KeyName == "法术防御" then attrName = "法防" end
    --    if attrObj.KeyName == "战斗速度" then attrName = "速度" end
    --    if attrObj.KeyName == "物暴率" then attrName = "暴击" end
    --    table.insert(GuardSortTypeArr,{["AttrName"]= attrName, ["Value"]= v})
    --end


    local panelBg = _gt.GetUI("panelBg")
    local addArrTip = GUI.ImageCreate(panelBg, "addArrTip", "1800400290", -140, -115, false, 240, 95);
    SetAnchorAndPivot(addArrTip, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local tipBg = GUI.ImageCreate(addArrTip, "tipBg", "1800001140", 0, -15, false, 215, 33);
    SetAnchorAndPivot(tipBg, UIAnchor.Top, UIAroundPivot.Top)

    local tip = GUI.CreateStatic(tipBg, "tip", "侍从加成总属性", 0, 0, 155, 26);
    SetAnchorAndPivot(tip, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(tip, fontSize);
    GUI.SetIsRemoveWhenClick(addArrTip, true) -- 是否检测到点击就销毁
    --GUI.AddWhiteName(addArrTip, guid)

    local txt1 = GUI.CreateStatic(addArrTip, "txt1", "基础属性", -55, -57, 100, 26);
    SetAnchorAndPivot(txt1, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetColor(txt1, colorYellow1)
    GUI.StaticSetFontSize(txt1, fontSize);
    GUI.StaticSetAlignment(txt1, TextAnchor.MiddleCenter)

    local txt2 = GUI.CreateStatic(addArrTip, "txt2", "属性加成", 55, -57, 100, 26);
    SetAnchorAndPivot(txt2, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetColor(txt2, colorYellow1)
    GUI.StaticSetFontSize(txt2, fontSize);
    GUI.StaticSetAlignment(txt2, TextAnchor.MiddleCenter)

    local index = 1;
    for i = 1, #GuardSortTypeArr do
        if GuardSortTypeArr[i] ~= nil and GuardSortTypeArr[i]["Value"] ~= 0 then
            -- 属性名称
            local name = GUI.CreateStatic(addArrTip, "name_" .. index, "", -55, -(85 + (index - 1) * 30), 100, 26);
            SetAnchorAndPivot(name, UIAnchor.Top, UIAroundPivot.Top)
            GUI.SetColor(name, colorYellow2)
            GUI.StaticSetFontSize(name, fontSize);
            GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)

            -- 属性值
            local value = GUI.CreateStatic(addArrTip, "value" .. index, "", 55, -(85 + (index - 1) * 30), 100, 26);
            SetAnchorAndPivot(value, UIAnchor.Top, UIAroundPivot.Top)
            GUI.SetColor(value, colorYellow2)
            GUI.StaticSetFontSize(value, fontSize);
            GUI.StaticSetAlignment(value, TextAnchor.MiddleCenter)

            -- 插入属性
            GUI.StaticSetText(name, GuardSortTypeArr[i]["AttrName"])
            GUI.StaticSetText(value, GuardSortTypeArr[i]["Value"])
            --addArrTip.Height = addArrTip.Height+30
            GUI.SetHeight(addArrTip, GUI.GetHeight(addArrTip) + 30)
            index = index + 1;
        end
    end
end
---------------------- 左右分割 ----------------------------
local fontColor1_Type = Color.New(172 / 255, 117 / 255, 39 / 255);
local colorType_Green = Color.New(8 / 255, 175 / 255, 0 / 255);

-- 创建loopScrollRect节点
local AddAttrPage_Scr_Index = 1 -- Scroll节点下标
function GuardUI.Create_AddAttrPage_Scr()
    local scr = _gt.GetUI("AddAttrPage_Scr") -- LoopScrollRect节点
    if scr == nil then
        return
    end
    -- 需要的数据
    local maxGuardStar = GUARD_MAX_STAR -- 侍从的最大星级
    local parent = scr -- 父节点
    local key = "AddAttrPage_Scr_" .. AddAttrPage_Scr_Index

    local item = GUI.ButtonCreate(parent, key, "1800700030", 0, 0, Transition.ColorTint, "", guardAddArrItemSize.x, guardAddArrItemSize.y, false);
    SetAnchorAndPivot(item, UIAnchor.Top, UIAroundPivot.Top)

    local itemIcon = GUI.ItemCtrlCreate(item, "iconBg", quality[1][2], 10, 0) -- 这里插入了品质背景，需修改
    SetAnchorAndPivot(itemIcon, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1900000000")
    local icon = GUI.ItemCtrlGetElement(itemIcon, eItemIconElement.Icon)
    GUI.SetWidth(icon, 71)
    GUI.SetHeight(icon, 70)

    -- 星星框
    local starBg = GUI.ImageCreate(itemIcon, "starBg", "1800400220", 0, -7, false, GUI.GetWidth(itemIcon) - 10, 17)
    SetAnchorAndPivot(starBg, UIAnchor.Bottom, UIAroundPivot.Bottom)
    for i = 1, maxGuardStar do
        -- 黑星
        local star = GUI.ImageCreate(starBg, "star_" .. i, "1801208420", (i - 3) * 12 - 6, 0)
        SetAnchorAndPivot(star, UIAnchor.Center, UIAroundPivot.Center)
        -- 亮星
        --local sp=GUI.ImageCreate(star, "sp","1801208360",0,0)
        --GUI.SetVisible(sp,false);
    end

    -- 角色名称
    local name = GUI.CreateStatic(item, "name", "", 95, -20, 390, 30, "system", true);
    SetAnchorAndPivot(name, UIAnchor.Left, UIAroundPivot.Left)
    GUI.StaticSetFontSize(name, fontSize_BigOne);
    GUI.SetColor(name, colorTypeOne);

    -- 属性名以及增加的属性
    local attr = GUI.CreateStatic(item, "attr", "", 95, 20, 290, 30, "system", true);
    SetAnchorAndPivot(attr, UIAnchor.Left, UIAroundPivot.Left)
    GUI.StaticSetFontSize(attr, fontSize_BigOne);
    GUI.SetColor(attr, fontColor1_Type);

    -- 绿色向右箭头
    local narrow = GUI.ImageCreate(attr, "narrow", "1801407080", 195, 0);
    SetAnchorAndPivot(narrow, UIAnchor.Left, UIAroundPivot.Left)

    -- 绿色箭头后的，下一级增加的属性
    local add = GUI.CreateStatic(attr, "add", "", 225, 0, 70, 30);
    SetAnchorAndPivot(add, UIAnchor.Left, UIAroundPivot.Left)
    GUI.StaticSetFontSize(add, fontSize_BigOne);
    GUI.SetColor(add, colorType_Green);

    -- 升级/激活按钮，到侍从最大星级时隐藏
    local btn = GUI.ButtonCreate(item, "btn", "1800402110", -15, 19, Transition.ColorTint, "", 82, 38, false);
    SetAnchorAndPivot(btn, UIAnchor.Right, UIAroundPivot.Right)
    GUI.ButtonSetTextFontSize(btn, fontSize)
    GUI.ButtonSetTextColor(btn, colorTypeOne)
    GUI.AddRedPoint(btn, UIAnchor.TopRight) -- 添加红点
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardUI", "OnOpenGuardBtnClick")

    AddAttrPage_Scr_Index = AddAttrPage_Scr_Index + 1 -- 节点下标自增
    return item;

end

-- 刷新loopScrollRect节点
function GuardUI.Refresh_AddAttrPage_SCr(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1

    -- 需要的数据
    local guardAddAttrData = nil
    if GuardUI.showAddAttrData ~= nil then
        guardAddAttrData = GuardUI.showAddAttrData
    elseif GuardUI.GuardAddAttrData ~= nil then
        guardAddAttrData = GuardUI.GuardAddAttrData
    else
        test("GuardUI界面 GuardUI.Create_AddAttrPage_Scr()方法 缺少GuardUI.showAddAttrData数据")
        return
    end

    local addAttrPage_Scr_i = GUI.GetByGuid(guid) -- 控制的节点
    local attr_Obj = DB.GetOnceAttrByKey1(guardAddAttrData[index]["Attr_id"]) -- 属性对象
    local guard_Obj = DB.GetOnceGuardByKey1(guardAddAttrData[index]["id"]) -- 侍从对象
    -- 设置头像
    local head = GUI.GetChild(addAttrPage_Scr_i, "iconBg") -- 头像节点
    local head_Image_Id = tostring(guard_Obj.Head) -- 头像图片id
    local head_Grad_Id = quality[guard_Obj.Grade][2] -- 头像品质背景
    GUI.ItemCtrlSetElementValue(head, eItemIconElement.Icon, head_Image_Id) -- 插入头像
    GUI.ItemCtrlSetElementValue(head, eItemIconElement.Border, head_Grad_Id) -- 插入品质
    -- 是否拥有侍从
    local isHaveGuard = LD.IsHaveGuard(guard_Obj.Id) -- 判断此侍从是否拥有
    -- 如果没有侍从则变黑
    GUI.ItemCtrlSetIconGray(head, isHaveGuard ~= true)

    -- 设置星级
    local star = GUI.GetChild(addAttrPage_Scr_i, "starBg") -- 星级节点
    local star_Level = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(guard_Obj.Id))) -- 侍从星级
    local isMaxStar = guardAddAttrData[index].Attr_Add_Level ~= GUARD_MAX_STAR -- 判断是否是最大等级
    local isNotZero = guardAddAttrData[index].Attr_Add_Level > 0 -- 判断属性加成是否大于0
    -- 先倒序将星星变黑 防止节点重复使用时，星级未被隐藏
    for i = GUARD_MAX_STAR, star_Level + 1, -1 do
        local star_child = GUI.GetChild(star, "star_" .. i)
        GUI.ImageSetImageID(star_child, "1801208420")
    end
    -- 再将星星变亮
    for i = 1, star_Level do
        local star_child = GUI.GetChild(star, "star_" .. i)
        GUI.ImageSetImageID(star_child, "1801208360")
    end

    -- 设置侍从名称
    local guardName = GUI.GetChild(addAttrPage_Scr_i, "name") -- 侍从名称
    local nameString = guard_Obj.Name
    if isMaxStar then
        -- 如果侍从星级不等于最大星级
        if star_Level == 0 then
            nameString = nameString .. "<color=#975c22>(获得侍从后可激活)</color>"
        elseif star_Level > 0 then
            if guardAddAttrData[index].Attr_Add_Level == 0 then
                nameString = nameString .. '<color=#975c22>（当前可激活）</color>'
            elseif star_Level > guardAddAttrData[index].Attr_Add_Level then
                nameString = nameString .. '<color=#975c22>（当前可升级）</color>'
            else
                nameString = nameString .. "<color=#975c22>(达到<color=#e17a00>" .. (star_Level + 1) .. "星</color>即可升级)</color>"
            end
        end
    else
        nameString = nameString .. "<color=#975c22>(已达最高级)</color>"
    end
    GUI.StaticSetText(guardName, nameString)

    -- 设置侍从属性加成
    local guardAttr = GUI.GetChild(addAttrPage_Scr_i, "attr") -- 侍从属性加成字体
    local attrName = attrNameTransform[attr_Obj.KeyName]
    --if attr_Obj.KeyName == "血量上限" then attrName = "血量" end
    --if attr_Obj.KeyName == "物理攻击" then attrName = "攻击" end
    --if attr_Obj.KeyName == "物理防御" then attrName = "防御" end
    --if attr_Obj.KeyName == "法术防御" then attrName = "法防" end
    --if attr_Obj.KeyName == "战斗速度" then attrName = "速度" end
    --if attr_Obj.KeyName == "物暴率" then attrName = "暴击" end

    local attrString = "主角" .. attrName
    if not isNotZero then
        attrString = attrString .. "<color=#533620>+" .. guardAddAttrData[index]["Next_Attr_Num"] .. "</color>"
    else
        attrString = attrString .. "<color=#533620>+" .. guardAddAttrData[index]["Now_Attr_Num"] .. "</color>"
    end

    GUI.StaticSetText(guardAttr, attrString)

    -- 设置下一级加成属性
    local guardAdd = GUI.GetChild(addAttrPage_Scr_i, "add") -- 侍从下一级加成属性
    local narrow = GUI.GetChild(addAttrPage_Scr_i, "narrow") -- 向右小箭头
    -- 判断加成属性是否是满级
    --CDebug.LogError("  level"..guardAddAttrData[index].Attr_Add_Level.." num"..guardAddAttrData[index]["Next_Attr_Num"] )
    if guardAddAttrData[index].Attr_Add_Level ~= GUARD_MAX_STAR and isNotZero then
        -- 如果不满级
        GUI.SetVisible(narrow, true)
        GUI.StaticSetText(guardAdd, "+" .. guardAddAttrData[index]["Next_Attr_Num"])
    else
        GUI.SetVisible(narrow, false)
        GUI.StaticSetText(guardAdd, "")
    end

    -- 设置按钮
    local guardBtn = GUI.GetChild(addAttrPage_Scr_i, "btn") -- 升级/激活按钮
    -- 插入数据，用于点击事件
    if GuardUI.showAddAttrData ~= nil and GuardUI.showAddAttrData._select_type then
        --GUI.SetData(guardBtn,"OneAddAttrData",tostring(guardAddAttrData[index].Attr_id).."-"..index) -- attrId-index
        GUI.SetData(guardBtn, "OneAddAttrData", tostring(GuardUI.showAddAttrData._select_type) .. "-" .. index) -- attrId-index
    else
        GUI.SetData(guardBtn, "OneAddAttrData", "all-" .. index)
    end

    -- 判断是否是最大等级
    if guardAddAttrData[index].Attr_Add_Level < GUARD_MAX_STAR then
        -- 如果不是最大等级
        GUI.SetVisible(guardBtn, true)
        -- 判断等级是否大于0
        if isNotZero then
            GUI.ButtonSetText(guardBtn, "升级")
        else
            -- 如果不大于0
            GUI.ButtonSetText(guardBtn, "激活")
        end
    else
        -- 如果是最大等级
        GUI.SetVisible(guardBtn, false) -- 隐藏按钮
    end

    -- 判断是否添加红点
    GUI.SetRedPointVisable(guardBtn, guardAddAttrData[index].Attr_Add_Level < star_Level)

end

-- 请求右边界面的数据
function GuardUI.getRightAddAttrData()
    -- FormGuard.AttrAddData(player)   --侍从加成数据   刷新方法GuardUI.RefreshGuardAddItem()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "AttrAddData") -- 绑定数据GuardUI.GuardAddAttrData {[1]={["Attr_id"]=43,["Attr_Add_Level"]=0,["Now_Attr_Num"]=0,["Next_Attr_Num"]=2,["id"]=128,}
end

-- 对右边界面数据数据进行排序
local addAttrPage_Sort = function(a, b)
    local canUp_a = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(a.id))) > a.Attr_Add_Level -- 是否可升级加成属性
    local canUp_b = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(b.id))) > b.Attr_Add_Level -- 是否可升级加成属性
    -- 是否可升级
    if canUp_a and not canUp_b then
        -- 如果 a能升级而b不能升级
        return true
    elseif not canUp_a and canUp_b then
        -- 如果b能升级而a不能升级
        return false
    else
        -- 如果都不能升级 或都能升级
        -- 是否拥有
        local isHaveGuard_a = LD.IsHaveGuard(a.id) -- 判断此侍从是否拥有
        local isHaveGuard_b = LD.IsHaveGuard(b.id) -- 判断此侍从是否拥有
        if isHaveGuard_a and not isHaveGuard_b then
            return true
        elseif not isHaveGuard_a and isHaveGuard_b then
            return false
        else
            -- 品质
            local grade_a = DB.GetOnceGuardByKey1(a.id).Grade -- 侍从品质
            local grade_b = DB.GetOnceGuardByKey1(b.id).Grade -- 侍从品质
            if grade_a ~= grade_b then
                return grade_a > grade_b
            else
                -- id
                return a.id < b.id
            end
        end
    end
end

local attrNameList = {} -- [attrId] = attrName 的列表 用于 全部侍从按钮点击事件
local GuardAddAttrData = nil -- 分类排序后 列表节点需要的数据
function GuardUI.SortedGuardAddAttrData()
    if GuardUI.AllAddAttrData == nil then
        return
    end

    -- 开始排序
    table.sort(GuardUI.GuardAddAttrData, addAttrPage_Sort)

    GuardAddAttrData = { ["all"] = GuardUI.GuardAddAttrData } -- 排序后的数据容器

    -- 根据属性加成的种类分类数据
    for k, v in ipairs(GuardUI.GuardAddAttrData) do

        if attrNameList[v.Attr_id] == nil then
            local attrName = attrNameTransform[DB.GetOnceAttrByKey1(v.Attr_id).KeyName]
            attrNameList[v.Attr_id] = attrName
        end

        local attrId = tostring(v.Attr_id)
        if GuardAddAttrData[attrId] == nil then
            GuardAddAttrData[attrId] = {}
        end
        table.insert(GuardAddAttrData[attrId], v)
    end


    -- 加成-侍从加成属性种类-小红点数据
    local attr_red = {}
    -- 遍历所有 ‘全部侍从+其他选项内的'
    for k, v in pairs(GuardAddAttrData) do
        -- 排除‘全部侍从’选项内的
        if k ~= 'all' then
            if attr_red[k] == nil then

                -- 遍历其他选项 速度/物防等
                for j, q in ipairs(v) do
                    local id = q.id
                    -- 判断这个加成属性内的侍从是否能提升加成等级
                    if GuardUI.red_point_data and GuardUI.red_point_data.guard_reds and GuardUI.red_point_data.guard_reds[tostring(id)] then
                        local data = GuardUI.red_point_data.guard_reds[tostring(id)]
                        if data.can_up_attr_level == true then
                            attr_red[k] = true
                            -- 如果这个选项能显示小红点就退出循环
                            break
                        end
                    end
                end

            end
        end
    end

    -- 判断’全部侍从‘选项的小红点
    for k, v in pairs(attr_red) do
        if v == true then
            attr_red['all'] = true
            break
        end
    end

    -- 设为全局变量
    GuardUI.attr_red = attr_red

end
-- 将GuardAddAttrData数据提升为全局变量，用于重新打开界面时，选中‘全部’，不想大改只能这样了
GuardUI._guard_add_attr_data = nil
-- 刷新右边侍从加成属性列表
function GuardUI.RefreshGuardAddItem()
    -- 需要的数据
    local guardAddAttrDataCount = nil
    if GuardUI.showAddAttrData ~= nil then
        guardAddAttrDataCount = #GuardUI.showAddAttrData
    elseif GuardUI.GuardAddAttrData ~= nil then
        guardAddAttrDataCount = #GuardUI.GuardAddAttrData
    else
        test("GuardUI界面 GuardUI.RefreshGuardAddItem()方法 缺少GuardUI.GuardAddAttrData数据")
        return
    end

    GuardUI.SortedGuardAddAttrData() -- 整理数据
    -- 提升为全局变量
    GuardUI._guard_add_attr_data = GuardAddAttrData

    -- 全部侍从按钮小红点
    local rightBg = _gt.GetUI("AddAttrPage_RightBg") -- 父类
    local arrange_btn = GUI.GetChild(rightBg, "arrangeBtn")

    -- 根据当前选中的种类
    if GuardUI.showAddAttrData ~= nil and GuardUI.showAddAttrData._select_type then
        if GuardUI.attr_red ~= nil and GuardUI.attr_red[tostring(GuardUI.showAddAttrData._select_type)] == true then
            GlobalProcessing.SetRetPoint(arrange_btn, true)
        else
            GlobalProcessing.SetRetPoint(arrange_btn, false)
        end
        -- 如果没有选，则设为’全部侍从‘选项
    else
        if GuardUI.attr_red ~= nil and GuardUI.attr_red['all'] == true then
            GlobalProcessing.SetRetPoint(arrange_btn, true)
        else
            GlobalProcessing.SetRetPoint(arrange_btn, false)
        end
    end

    local addAttrPage_Scr = _gt.GetUI("AddAttrPage_Scr") -- 滚动列表节点
    GUI.LoopScrollRectSetTotalCount(addAttrPage_Scr, guardAddAttrDataCount) -- 创建侍从加成列表节点
    GUI.LoopScrollRectRefreshCells(addAttrPage_Scr) -- 刷新侍从加成列表节点

end

-- 全部侍从点击按钮
local guidMap = {} -- [guid] = [attrId] 用于全部侍从下拉列表的点击事件，因为点击以后节点被销毁了，无法通过guid获取到对象从而获得数据。所以用这种方式
function GuardUI.OnArrangeGuardBtnClick()
    if next(attrNameList) == nil then
        return ''
    end

    local rightBg = _gt.GetUI("AddAttrPage_RightBg")
    local guardTypeBg = GUI.GetChild(rightBg, "guardTypeBg")

    if guardTypeBg ~= nil then
        GUI.Destroy(guardTypeBg);
        return ''
    end

    guardTypeBg = GUI.ImageCreate(rightBg, "guardTypeBg", "1800400290", 50, 62, false, 180, 20);
    SetAnchorAndPivot(guardTypeBg, UIAnchor.TopRight, UIAroundPivot.TopRight)
    local btnWidth = 165;
    local btnHeight = 40;
    local btn = GUI.ButtonCreate(guardTypeBg, "all", "1800600100", 0, GUI.GetHeight(guardTypeBg) - 10, Transition.ColorTint, "全部侍从", btnWidth, btnHeight, false);
    SetAnchorAndPivot(btn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ButtonSetTextFontSize(btn, fontSize_BigOne)
    GUI.ButtonSetTextColor(btn, colorType_UpdateStarBrown1)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardUI", "OnGuardAttrTypeBtnClick")
    GUI.SetHeight(guardTypeBg, GUI.GetHeight(guardTypeBg) + GUI.GetHeight(btn))
    -- 存入数据
    guidMap[GUI.GetGuid(btn)] = "all"

    -- 全部侍从按钮小红点
    if GuardUI.attr_red ~= nil and GuardUI.attr_red['all'] == true then
        GlobalProcessing.SetRetPoint(btn, true)
    else
        GlobalProcessing.SetRetPoint(btn, false)
    end

    for k, v in pairs(attrNameList) do
        local btn = GUI.ButtonCreate(guardTypeBg, "addAttrKind_" .. k, "1800600100", 0, GUI.GetHeight(guardTypeBg) - 10, Transition.ColorTint, "主角" .. v, btnWidth, btnHeight, false);
        SetAnchorAndPivot(btn, UIAnchor.Top, UIAroundPivot.Top)
        GUI.ButtonSetTextFontSize(btn, fontSize_BigOne)
        GUI.ButtonSetTextColor(btn, colorType_UpdateStarBrown1)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardUI", "OnGuardAttrTypeBtnClick")
        GUI.SetHeight(guardTypeBg, GUI.GetHeight(guardTypeBg) + GUI.GetHeight(btn))


        -- 显示小红点
        if GuardUI.attr_red ~= nil and GuardUI.attr_red[tostring(k)] == true then
            GlobalProcessing.SetRetPoint(btn, true)
        else
            GlobalProcessing.SetRetPoint(btn, false)
        end

        -- 存入数据
        guidMap[GUI.GetGuid(btn)] = tostring(k)
    end

    GUI.SetIsRemoveWhenClick(guardTypeBg, true) -- 是否检测到点击就销毁

end

-- 全部侍从下拉列表点击事件
GuardUI.showAddAttrData = nil -- 显示的数据
function GuardUI.OnGuardAttrTypeBtnClick(guid)
    if GuardAddAttrData == nil or next(attrNameList) == nil or next(guidMap) == nil then
        return
    end

    -- 获取类型名称
    local attrId = guidMap[guid]
    GuardUI.showAddAttrData = GuardAddAttrData[attrId]

    local rightBg = _gt.GetUI("AddAttrPage_RightBg") -- 父类
    local btnTxt = GUI.GetChild(GUI.GetChild(rightBg, "arrangeBtn"), "btnTxt")  -- 全部侍从按钮文本

    -- 修改文本
    if attrId == "all" then
        GUI.StaticSetText(btnTxt, "全部侍从")
    else
        GUI.StaticSetText(btnTxt, "主角" .. attrNameList[tonumber(attrId)])
    end
    -- 选择的侍从种类type
    GuardUI.showAddAttrData._select_type = attrId

    -- 刷新列表
    GuardUI.RefreshGuardAddItem()

end

-- 在左边侍从列表loop-scroll隐藏的情况下，无法刷新它，设置它显示后还是原来的样子，针对这个bug设置变量
GuardUI._is_refresh_left_loop_scroll = false
-- 激活/升级按钮点击事件
local AddAttrPage_UpAttrElement_Index = nil
function GuardUI.OnOpenGuardBtnClick(guid)

    if GuardAddAttrData == nil then
        return
    end

    local btn = GUI.GetByGuid(guid) -- 本按钮节点
    local index = string.split(GUI.GetData(btn, "OneAddAttrData"), "-")
    local data = GuardAddAttrData[index[1]][tonumber(index[2])] -- 此点击节点 对应 侍从加成的数据
    AddAttrPage_UpAttrElement_Index = { index[1], index[2] }

    local isHaveGuard = LD.IsHaveGuard(data.id) -- 是否拥有此侍从
    local star_Level = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(data.id))) -- 此侍从的星级

    -- 如果是激活按钮
    if not isHaveGuard then
        -- 如果没有此侍从
        -- 跳转到属性页面
        GuardUI.SelectGuardID = data.id
        GuardUI.SelectType = 0  -- 将侍从种类列表改为全部
        -- 刷新左边列表和中间形象以及右边属性页面
        GuardUI.UpdateGuardLst()
        GuardUI.autoScrollPosition(GuardUI.SelectGuardID) -- 自动跳转到左边列表中选中侍从的位置
        GuardUI.ShowGuardDetailInfo()

        GuardUI.OnAttrTabBtnClick() -- 跳转到属性页面
        -- 刷新页签小红点
        GuardUI._refresh_bookmark_red(GuardUI.SelectGuardID)
        -- 刷新侍从属性和侍从技能上的小红点
        GuardUI.OnSelectGuardAttr()
    else
        -- 如果拥有此按钮，是升级按钮
        -- 判断是否可升级
        if data.Attr_Add_Level < star_Level then
            --CDebug.LogError('当前加成等级:'..tostring(data.Attr_Add_Level))
            GuardUI._is_refresh_left_loop_scroll = true
            -- 发送升级请求
            --FormGuard.AttrAddLevelup(player,data.id)
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "AttrAddLevelup", data.id)
        else
            -- 跳转到升星页面
            GuardUI.SelectGuardID = data.id
            GuardUI.SelectType = 0  -- 将侍从种类列表改为全部
            -- 左边列表和侍从形象也要切换
            GuardUI.UpdateGuardLst()
            GuardUI.autoScrollPosition(GuardUI.SelectGuardID) -- 自动跳转到左边列表中选中侍从的位置
            GuardUI.ShowGuardDetailInfo()
            -- 跳转到对应情缘侍从的升星界面
            GuardUI.OnTrainTabBtnClick()
            -- 刷新页签小红点
            GuardUI._refresh_bookmark_red(GuardUI.SelectGuardID)
        end
    end

end
-- 升级按钮点击后的回调事件
function GuardUI.RefreshAddAttrAllPage()
    -- 更新 升级节点的数据
    if AddAttrPage_UpAttrElement_Index == nil or GuardAddAttrData == nil
            or GuardUI.AttAttrPage_Next_Attr_Num == nil or GuardUI.AllAddAttrData == nil then
        return
    end

    -- 拿到需要更新的数据
    local index = AddAttrPage_UpAttrElement_Index
    local data = GuardAddAttrData[index[1]][tonumber(index[2])]

    -- 将总加成属性 修改
    if GuardUI.AllAddAttrData[data.Attr_id] == nil then
        GuardUI.AllAddAttrData[data.Attr_id] = 0
    end
    GuardUI.AllAddAttrData[data.Attr_id] = GuardUI.AllAddAttrData[data.Attr_id] - data.Now_Attr_Num + data.Next_Attr_Num  -- 此种类的总加成属性 = 总加成属性 - 当前此种类加成属性 + 下一级此种类加成属性

    -- 将当前等级自增
    data.Attr_Add_Level = data.Attr_Add_Level + 1
    -- 将当前加成属性，变为下一级加成属性
    data.Now_Attr_Num = data.Next_Attr_Num
    -- 将下一级加成属性，通过请求服务器来的值进行赋值
    data.Next_Attr_Num = GuardUI.AttAttrPage_Next_Attr_Num

    -- 将战力数据修改   服务器重新设置战力属性

    -- 刷新页面
    GuardUI.RefreshAddAttrPage_Left() -- 刷新左边
    GuardUI.RefreshGuardAddItem() -- 刷新右边

end

---------------------------end 侍从加成 end------------------------
--信物id相对应的侍从id
local FragmentList = {
    Id_31211 = 101, Id_31212 = 102, Id_31213 = 103, Id_31214 = 104,
    Id_31215 = 105, Id_31216 = 106, Id_31217 = 107, Id_31218 = 108,
    Id_31219 = 109, Id_31220 = 110, Id_31221 = 111, Id_31222 = 112,
    Id_31223 = 113, Id_31224 = 114, Id_31225 = 115, Id_31226 = 116,
    Id_31227 = 117, Id_31228 = 118, Id_31229 = 119, Id_31230 = 120,
    Id_31231 = 121, Id_31232 = 122, Id_31233 = 123, Id_31234 = 124,
    Id_31235 = 125, Id_31236 = 126, Id_31237 = 127, Id_31238 = 128,
    Id_31239 = 129, Id_31240 = 130, Id_31241 = 131, Id_31242 = 132,
    Id_31243 = 133, Id_31244 = 134, Id_31245 = 135, Id_31246 = 136,
    Id_31247 = 137, Id_31248 = 138, Id_31249 = 139, Id_31250 = 140,
}
--将侍从的信物id改变成为侍从的id
function GuardUI.FragmentItemIdChangeToGuardId(itemId)
    local str = "Id_" .. itemId
    local guardId = FragmentList[str]
    --print("guardid====="..guardId)
    GuardUI.SelectedByGuardId(guardId)

end

-- 选中到某个侍从通过侍从ID
function GuardUI.SelectedByGuardId(guardId)

    GuardUI.SelectGuardID = tonumber(guardId)
    --print(" GuardUI.SelectGuardID".. GuardUI.SelectGuardID)
    GuardUI.SelectType = 0  -- 将侍从种类列表改为全部
    -- 左边列表和侍从形象也要切换
    GuardUI.UpdateGuardLst()
    GuardUI.autoScrollPosition(GuardUI.SelectGuardID) -- 自动跳转到左边列表中选中侍从的位置
    GuardUI.OnSelectGuardAttr()
    GuardUI.ShowGuardDetailInfo()
    GuardUI.RefreshSkillPage()
    GuardUI.OnAttrTabBtnClick()
end
---------------------------end 侍从加成 end------------------------


------------------------------------------------------------------ 小红点
-- 页签小红点
function GuardUI._refresh_bookmark_red(guard_id)
    if not guard_id then
        return
    end

    if type(guard_id) == 'number' then
        guard_id = tostring(guard_id)
    end

    if GuardUI.red_point_data and GuardUI.red_point_data.guard_reds and GuardUI.red_point_data.guard_reds[guard_id] then
        local data = GuardUI.red_point_data.guard_reds[guard_id]

        -- 判断侍从是否拥有
        if not data.is_activation then
            -- 如果未拥有，只判断属性页签,其他页签隐藏小红点
            for k, v in ipairs(tabList) do
                local attrTabBtn = GUI.GetByGuid(tabList[k].btnGuid)
                if k == 1 then
                    --GUI.SetRedPointVisable(attrTabBtn,data.can_activation)
                    GlobalProcessing.SetRetPoint(attrTabBtn, data.can_activation, UIDefine.red_type.bookmark)
                else
                    --GUI.SetRedPointVisable(attrTabBtn,false)
                    GlobalProcessing.SetRetPoint(attrTabBtn, false, UIDefine.red_type.bookmark)
                end
            end
        else
            -- 遍历页签表
            for k, v in ipairs(tabList) do
                local btn = GUI.GetByGuid(tabList[k].btnGuid)

                -- 属性页签
                if v[1] == "属性" then
                    -- 侍从被动技能 + 侍从能否升星（侍从主动技能能否升级)
                    --GUI.SetRedPointVisable(btn,data.can_up_skill or data.can_up_star )
                    GlobalProcessing.SetRetPoint(btn, data.can_up_skill or data.can_up_star, UIDefine.red_type.bookmark)
                elseif v[1] == '升星' then
                    --GUI.SetRedPointVisable(btn,data.can_up_star)
                    GlobalProcessing.SetRetPoint(btn, data.can_up_star, UIDefine.red_type.bookmark)
                elseif v[1] == '情缘' then
                    --GUI.SetRedPointVisable(btn,data.can_up_love_skill)
                    GlobalProcessing.SetRetPoint(btn, data.can_up_love_skill, UIDefine.red_type.bookmark)
                    --elseif v[1] == '加成' then
                    --GUI.SetRedPointVisable(btn,data.can_up_attr_level)
                    --GlobalProcessing.SetRetPoint(btn, data.can_up_attr_level,UIDefine.red_type.bookmark)
                end
            end

        end

    end
    -- 加成页签规则修改为 其内有可点就显示加成小红点
    if GuardUI.red_point_data and GuardUI.red_point_data.attr_level ~= nil then
        local btn = GUI.GetByGuid(tabList[4].btnGuid)
        GlobalProcessing.SetRetPoint(btn, GuardUI.red_point_data.attr_level, UIDefine.red_type.bookmark)
    end
end
------------------------------------------------------------------ 小红点


------------------------------------------------------------------ 命魂
function GuardUI.guard_soul_image_click()
    local wnd = GUI.GetWnd('GuardUI')
    if wnd and GUI.GetVisible(wnd) then
        GUI.SetVisible(wnd, false)
    end
    GUI.OpenWnd('GuardSoulUI', 'index:1,index2:0,guard_id:' .. GuardUI.SelectGuardID)
end

function GuardUI.guardScore_red_point(is_show)
    local guard_soul_img = _gt.GetUI('guard_soul_img')
    if guard_soul_img then
        GlobalProcessing.SetRetPoint(guard_soul_img, is_show, UIDefine.red_type.common)
    end
end
------------------------------------------------------------------ 命魂
