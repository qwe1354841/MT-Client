-- 活力界面
local VitalityUI = {}
_G.VitalityUI = VitalityUI

-------------------------------start缓存一下常用的全局变量start---------------------------
local _gt = UILayout.NewGUIDUtilTable()
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
-- 物品品质背景
VitalityUI.ItemQualityImage = {
    "1801100120",
    "1801100130",
    "1801100140",
    "1801100150",
    "1801100160",
    "1801401200",
    "1801401210",
    "1801401220",
    "1801401230"
}

VitalityUI.Vitality_tb = {}
VitalityUI.Vitality_shopid= {}

----------------------------------- 颜色
local colorDark = Color.New(102/255, 47/255, 22/255, 255/255)
local colorGreen = Color.New(8/255, 175/255, 0/255, 255/255)
local colorRed = Color.New(255/255, 0/255, 0/255, 255/255)
-----------------------------------

function VitalityUI.Main(parameter)
    VitalityUI.openParameter = parameter
    VitalityUI.Init()



    local panel = GUI.WndCreateWnd("VitalityUI", "VitalityUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetIgnoreChild_OnVisible(panel,true)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    panel:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(panel, true)

    --底图
    local w = 860
    local h = 604
    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "", w, h, "VitalityUI", "OnExit", _gt)

    local tipLabel=GUI.CreateStatic( panelBg,  "tipLabel","活 力" ,3,30,100,34);
    GUI.StaticSetFontSize(tipLabel,28)
    GUI.StaticSetAlignment(tipLabel,TextAnchor.MiddleCenter)
    GUI.SetColor(tipLabel,colorDark);
    SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)

    _gt.BindName(panelBg, "panelBg")

    local panelBg = GUI.Get("VitalityUI/panelBg/center")

    -- 活力字体
    local label=GUI.CreateStatic( panelBg,  "vitalityLabel","活力",152,-26,100,50,"system",true,false);
    SetAnchorAndPivot(label, UIAnchor.TopLeft, UIAroundPivot.Center)
    GUI.StaticSetAlignment(label,TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(label,24);
    GUI.SetColor(label,colorDark);



    -- 活力条
    local tempSlider = GUI.ScrollBarCreate(panelBg, "vitalitySlider","","1800408150","1800408110",0,249,0,0,1,false,Transition.None,0,1,Direction.LeftToRight,false,false)
    local silderFillSize=Vector2.New(470,24)
    GUI.ScrollBarSetFillSize(tempSlider,silderFillSize)
    GUI.ScrollBarSetBgSize(tempSlider,silderFillSize)
    SetAnchorAndPivot(tempSlider, UIAnchor.Center, UIAroundPivot.Left)

    local currentTxt=GUI.CreateStatic( tempSlider, "SliderTxtlabel","3200/3200" ,0,0,110,30,"system",true)
    SetAnchorAndPivot(currentTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(currentTxt,22);


    -- i 图标
    local tipBtn = GUI.ButtonCreate( panelBg, "tipBtn", "1800702030", 685, -8, Transition.ColorTint, "")
    SetAnchorAndPivot(tipBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick , "VitalityUI", "OnTipBtnClick")

    -- 创建左边 获取活力值
    VitalityUI.CreateGetList(panelBg)
    -- 创建右边 获取活力值
    VitalityUI.CreateUseList(panelBg)


end

function VitalityUI.OnShow()

    local wnd = GUI.GetWnd("VitalityUI")
    if not wnd then return end
    GUI.SetVisible(wnd,true)

    -- 刷新界面
    VitalityUI.Refresh()

    VitalityUI.Register()
end

function VitalityUI.OnExit()
    VitalityUI.UnRegister()
    GUI.CloseWnd("VitalityUI")
end

---------------------------------------------------------------------------------------------------------------------区分线
-- 创建右边 获取活力值
function VitalityUI.CreateUseList(parent)
    local parent = GUI.Get("VitalityUI/panelBg/center")

    local pageList = GUI.GroupCreate( parent, "pageList", 0, 0)
    GUI.SetIgnoreChild_OnVisible(pageList,true)
    SetAnchorAndPivot(pageList, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local ListBg = GUI.ImageCreate( pageList, "ListBg", "1800400010", 432, 55, false, 417, 487)
    SetAnchorAndPivot(ListBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local ListTitleBar = GUI.ImageCreate( pageList, "ListTitleBar", "1800400470", 435, 60, false, 410, 40)
    SetAnchorAndPivot(ListTitleBar, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local ListTitleTxt = GUI.CreateStatic( ListTitleBar, "ListTitleTxt","活力使用" ,0,0,96,33,"system",true);
    SetAnchorAndPivot(ListTitleTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(ListTitleTxt,24);
    GUI.SetColor(ListTitleTxt,colorDark);

    --滚动框
    local itemUseScroll =
    GUI.LoopScrollRectCreate(
            parent,
            "itemUseScroll",
            210,
            12,
            410,
            433,
            "VitalityUI",
            "CreateUseItemPool",
            "VitalityUI",
            "RefreshUserScroll",
            0,
            false,
            Vector2.New(400, 100),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft
    )
    _gt.BindName(itemUseScroll, "itemUseScroll")
    VitalityUI.itemUseScroll = itemUseScroll
    GUI.ScrollRectSetChildAnchor(itemUseScroll, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(itemUseScroll, UIAroundPivot.Top)
    -- 设置每个框的距离
    GUI.ScrollRectSetChildSpacing(itemUseScroll, Vector2.New(10, 3))
    -- 刷新每个框
    GUI.LoopScrollRectRefreshCells(itemUseScroll);
end

function VitalityUI.CreateUseItemPool()
    local itemUseScroll = GUI.GetByGuid(_gt.itemUseScroll);
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(itemUseScroll)+1;
    local icon = GUI.ImageCreate(itemUseScroll, "useItem"..curIndex,"1800400460", -120, 40,false,100,100)
    SetAnchorAndPivot(icon, UIAnchor.Center, UIAroundPivot.Center)

    --图标
    local itemIcon = GUI.ItemCtrlCreate( icon, "itemIcon", "1800400050", 8, 10, 0, 0, false,system)
    SetAnchorAndPivot(itemIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetIsRaycastTarget(itemIcon, false)

    -- 名字
    local name = GUI.CreateStatic( icon, "name", "生龙活虎散", 104, 15, 150, 30,"system",true)
    SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(name, 24)
    GUI.SetColor(name, colorDark)

    -- 等级
    local textInfo = GUI.CreateStatic( icon, "textInfo", "恢复200体力", 103, 57, 200, 25,"system",true)
    SetAnchorAndPivot(textInfo, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(textInfo, 20)
    GUI.SetColor(textInfo, colorDark)

    local tipBtn = GUI.ButtonCreate(icon, "tipBtn", "1800702030", -162, 12, Transition.ColorTint, "",32,32,false)
    SetAnchorAndPivot(tipBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick , "VitalityUI", "OnWorkTipBtnClick")

    local funcBtn = GUI.ButtonCreate( icon, "funcBtn", "1800402110", 310, 25, Transition.ColorTint, "",80,38,false)
    SetAnchorAndPivot(funcBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    -- 按钮上的文本
    local txt = GUI.CreateStatic(funcBtn,"txt","购买",0,0,80,38)
    GUI.StaticSetAlignment(txt,TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt,24)
    GUI.SetColor(txt,colorDark)
    -- 按钮点击事件
    GUI.RegisterUIEvent(funcBtn , UCE.PointerClick , "VitalityUI", "JumpToUI");
    return icon;
end
function VitalityUI.SetUseItem(item,index)
    if not item then
        return
    end
    local icon = GUI.GetChild(item,"itemIcon")
    local name = GUI.GetChild(item,"name")
    local textInfo = GUI.GetChild(item,"textInfo")
    local funcBtn = GUI.GetChild(item,"funcBtn")
    local tipBtn = GUI.GetChild(item,"tipBtn")
    local btnTxt = GUI.GetChild(funcBtn,"txt")
    local temp = VitalityUI.UseTable[index]
    GUI.SetVisible(tipBtn,false)
    if temp.UI_Index == 1 then
        GUI.SetVisible(tipBtn,true)
    end
    if temp then
        GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Icon,tostring(temp.Icon))
        GUI.StaticSetText(name,temp.Name);
        if temp.UI_Index and temp.UI_Index == 1 then
            GUI.StaticSetText(textInfo,temp.Info..temp.Price);
            GUI.SetData(tipBtn,"tipsPrice",temp.Price)
            GUI.SetData(tipBtn,"tipsBingGold",temp.BindGold)
            local curValue = CL.GetIntAttr(RoleAttr.RoleAttrVp)
            if curValue < 50 then
                GUI.SetColor(textInfo,colorRed)
            elseif curValue >= 50 then
                GUI.SetColor(textInfo,colorGreen)
            end
            _gt.BindName(textInfo,"TextInfo")
        else
            GUI.StaticSetText(textInfo,temp.Info);
            GUI.SetColor(textInfo,colorDark)
        end
        GUI.StaticSetText(btnTxt, temp.Button_Name)
        GUI.SetData(funcBtn,"dataIndex",tostring(index))
    end
end

--右边按钮点击事件
function VitalityUI.JumpToUI(guid)
    local  item = GUI.GetByGuid(guid)
    GUI.SetEventCD(item,UCE.PointerClick,0.5)
    local index = tonumber(GUI.GetData(item,"dataIndex"))
    local RoleLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local CurLevel = 0
    if index then
        local uiIndex = nil
        if VitalityUI.UseTable then
            local temp = VitalityUI.UseTable[index]
            uiIndex = temp.UI_Index
            if uiIndex == 1 then
                CL.SendNotify(NOTIFY.SubmitForm,"FormVitality","UseReceive",tostring(uiIndex))
            elseif uiIndex == 2 then
                CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel_2["打造"]))
                if RoleLevel < CurLevel then
                    CL.SendNotify(NOTIFY.ShowBBMsg,temp.Name.."功能"..CurLevel.."级开启")
                else
                    local index = string.split(temp.Param,'-')
                    GUI.OpenWnd(temp.Wnd,string.format("index:%s,index2:%s",index[1] , index[2]))
                end
            elseif uiIndex == 3 then
                CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel_2["合成"]))
                if RoleLevel < CurLevel then
                    CL.SendNotify(NOTIFY.ShowBBMsg,temp.Name.."功能"..CurLevel.."级开启")
                else
                    local index = string.split(temp.Param,'-')
                    GUI.OpenWnd(temp.Wnd,string.format("index:%s,index2:%s",index[1] , index[2]))
                end
            elseif uiIndex == 4 then
                CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["生产"].Subtab_OpenLevel["烹饪"]))
                if RoleLevel < CurLevel then
                    CL.SendNotify(NOTIFY.ShowBBMsg,temp.Name.."功能"..CurLevel.."级开启")
                else
                    local index = string.split(temp.Param,'-')
                    GUI.OpenWnd(temp.Wnd,string.format("index:%s,index2:%s",index[1] , index[2]))
                end
            elseif uiIndex == 5 then
                CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["生产"].Subtab_OpenLevel["炼药"]))
                if RoleLevel < CurLevel then
                    CL.SendNotify(NOTIFY.ShowBBMsg,temp.Name.."功能"..CurLevel.."级开启")
                else
                    local index = string.split(temp.Param,'-')
                    GUI.OpenWnd(temp.Wnd,string.format("index:%s,index2:%s",index[1] , index[2]))
                end
            end
        end

    end
end



function VitalityUI.RefreshUserScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1];
    local index = tonumber(parameter[2])+1
    local item = GUI.GetByGuid(guid)
    VitalityUI.SetUseItem(item,index)
end

function VitalityUI.RefreshUseItems()
    VitalityUI.UseDataFunc()
    if VitalityUI.itemUseScroll ~= nil and VitalityUI.UseTable ~= nil then
        GUI.LoopScrollRectSetTotalCount(VitalityUI.itemUseScroll, #VitalityUI.UseTable);
        GUI.LoopScrollRectRefreshCells(VitalityUI.itemUseScroll);
    end
end

function VitalityUI.UseDataFunc()
    if not VitalityUI.Vitality_tb then
        return
    end
    VitalityUI.UseTable = {}
    for i = 1, #VitalityUI.Vitality_tb do
        if VitalityUI.Vitality_tb[i].Switch == "on" then
            table.insert(VitalityUI.UseTable,VitalityUI.Vitality_tb[i])
        end
    end
end

-----------------------------------------------------------------------------------------

function VitalityUI.SetVitalityValue(value)
    local wnd = GUI.GetWnd("VitalityUI")
    if wnd ~= nil and GUI.GetVisible(wnd) then
        local slider = GUI.Get("VitalityUI/panelBg/center/vitalitySlider")
        local text = GUI.GetChild(slider,"SliderTxtlabel")
        local curValue = value
        if not value then
            curValue = CL.GetIntAttr(RoleAttr.RoleAttrVp)
        end
        VitalityUI.CurValue = curValue
        local maxValue =  CL.GetIntAttr(RoleAttr.RoleAttrVpLimit)
        if curValue and maxValue then
            GUI.StaticSetText(text,curValue.."/"..maxValue)
            if slider~=nil then
                GUI.ScrollBarSetPos(slider,curValue/maxValue)
            end
        end
    end
end

function VitalityUI.Init()
    local selfNickName = CL.GetRoleName()
    if selfNickName~=nil and #selfNickName >0 then
        CL.SendNotify(NOTIFY.SubmitForm,"FormVitality","GetUseData")
    end
end

function VitalityUI.GetDataFunc()
    VitalityUI.GetTable = {}
    local itemTable = VitalityUI.Vitality_shopid
    if not itemTable then
        test("Vitality_shopid is nil")
        return
    end
    for i = 1, #itemTable do
        if VitalityUI.CheckShopName(itemTable[i]) then
            local tempTable = {}
            table.insert(tempTable,1)
            table.insert(tempTable,itemTable[i])
            table.insert(VitalityUI.GetTable,tempTable)
        end
    end
    local allActivity = LD.GetCurrentDayActivityList()
    local sortActTable = {}
    local roleLevel=CL.GetIAttr(RoleAttr.RoleAttrLevel)
    for i = 0, allActivity.Count - 1 do
        local actiConfig=DB.Get_activity(allActivity[i])
        if actiConfig.Athletics7Show == 0 and actiConfig.Show == 1 and actiConfig.AwardPoint > 0 then
            if actiConfig.LevelMin <= roleLevel and roleLevel <= actiConfig.LevelMax then
                table.insert(sortActTable,allActivity[i])
            end
        end
    end
    table.sort(sortActTable,VitalityUI.SortActivityByStatus)

    for i = 1, #sortActTable do
        local tempTable = {}
        table.insert(tempTable,2)
        table.insert(tempTable,sortActTable[i])
        table.insert(VitalityUI.GetTable,tempTable)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------- 左边列表 start
-- 左边恢复活力值药品数据
VitalityUI.LeftMedicineData = nil

-- 排序左边数据函数
local LeftSort = function (a,b)
    -- 查看活动状态，按进行中1、未开启0、已过期2 排序
    -- 如果活动状态相同，则判断index，如果index相同则判断id
    if a.state == 1 and b.state ~= 1 then
        return true
    elseif a.state ~= 1 and b.state == 1 then
        return false
    elseif a.state ~= 1 and b.state ~= 1 then

        if a.state == 0 and b.state == 2 then
            return true
        elseif a.state == 2 and b.state == 0 then
            return false
        elseif a.state == 2 and b.state == 2 then

            if a.Index == b.Index then
                return a.Id < b.Id
            else
                return a.Index < b.Index
            end

        elseif a.state == 0 and b.state == 0 then

            if a.Index == b.Index then
                return a.Id < b.Id
            else
                return a.Index < b.Index
            end

        end

    elseif a.state == 1 and b.state == 1 then

        if a.Index == b.Index then
            return a.Id < b.Id
        else
            return a.Index < b.Index
        end

    end
end

-- 左边的活动任务数据表
VitalityUI.ActivityData = {}
-- 获取左边数据函数
function VitalityUI.InitLeftData()
    -- 获取活动列表
    local dataList = LD.GetActivityList()

    if not dataList then
        return
    end

    local ActData = {}
    local count = dataList.Count
    for i = 1, count do
        local data = dataList[i - 1]
        local custom = string.split(data.custom, ":")
        local t = {
            state = data.state,
            today = data.today,
            -- 1:2:1:10:61024,61025,21112:1:2,3,5
            -- 分别对应的是 当前参加次数， 次数上限，当前获得活跃值，活跃值上限，奖励List，活动状态 0未开启 1进行中 2已结束，属于什么奖励类型的活动
            getVp = tonumber(custom[3]),
            vpLimit = tonumber(custom[4]),
        }
        -- 排除没有活跃值奖励 和今天不开始 的活动
        if (t.vpLimit and t.vpLimit ~= 0 ) and t.today == 1 then
            if data.id and t["vpLimit"] > 0 then
                t.today = nil
                ActData[data.id] = t
            end
        end
    end

    -- 查询当前服务器时间
    local curTickCount = CL.GetServerTickCount()
    local dateStr = string.split(os.date("!%d %w %H %M %S", curTickCount), " ")
    local day = dateStr[1]
    local week = dateStr[2] == "0" and "7" or dateStr[2]
    local hour = dateStr[3]
    local minute = dateStr[4]
    local second = dateStr[5]
    local curTime = tonumber(hour) * 3600 + tonumber(minute) * 60 + tonumber(second)

    -- 获取角色等级
    local curLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)

    -- 遍历筛选出来的活动，通过活动表查询，其活动是否能开启,同时组成新的数据
    for k,v in pairs(ActData) do
        local config = DB.GetActivity(k) -- 通过活动id获得活动对象
        -- 判断玩家等级是否足够
        if curLevel < config.LevelMin or curLevel > config.LevelMax then
            -- 如果玩家等级 小于活动等级 或 大于活动等级 则不显示这条活动
            v.isShow = false
            goto continue
        end

        if config.Show == 1 then
            local isShow = false
            local isOpen = false
            if config.TimeType == 2 then
                -- 周循环
                if LogicDefine.CheckActivityDay(config.Time, week) then
                    isShow = true
                    if (config.TimeStart == "0" or config.TimeEnd == "0") or LogicDefine.CheckActivityTime(config.TimeStart, config.TimeEnd, curTime) then
                        isOpen = true
                    end
                end
            elseif config.TimeType == 3 then
                -- 月循环
                if LogicDefine.CheckActivityDay(config.Time, day) then
                    isShow = true
                    if (config.TimeStart == "0" or config.TimeEnd == "0") or LogicDefine.CheckActivityTime(config.TimeStart, config.TimeEnd, curTime) then
                        isOpen = true
                    end
                end
            elseif config.TimeType == 0 then
                if (config.TimeStart == "0" or config.TimeEnd == "0") or LogicDefine.CheckActivityDate(config.TimeStart, config.TimeEnd, curTickCount) then
                    isShow = true
                    isOpen = true
                end
            else
                isShow = true
                if (config.TimeStart == "0" or config.TimeEnd == "0") or LogicDefine.CheckActivityTime(config.TimeStart, config.TimeEnd, curTime) then
                    isOpen = true
                end
            end

            -- 如果此活动可以显示
            if isShow then
                v.isShow = isShow -- 活动是否显示
                v.isOpen = isOpen -- 活动是否开始
                v.Name = config.Name -- 活动名称
                v.Id = config.Id -- 活动ID
                v.Icon = tostring(config.Icon) -- 活动图标
                v.TimeStart = config.TimeStart -- 活动开始时间
                --v.TimeEnd = config.TimeEnd -- 活动结束时间
                v.Index = config.Index -- 活动排序
            end
        end
        ::continue::
    end

    -- 删除多余的数据
    for k,v in pairs(ActData) do
        if not v.isShow then
            ActData[k] = nil
        else
            v.isShow = nil
        end
    end

    -- 无序的key无法用sort方法排序，需要变成有序
    local i = 1
    local list = {}
    for k,v in pairs(ActData) do
        list[i] = v
        i = i + 1
    end
    i = nil
    ActData = list
    list = nil

    -- 对活动进行排序
    table.sort(ActData,LeftSort)
    -- 将活动数据上升为全局变量
    VitalityUI.ActivityData  = ActData
end

-- 创建左边 获取活力值
function VitalityUI.CreateGetList()
    local parent = GUI.Get("VitalityUI/panelBg/center")

    local pageList = GUI.GroupCreate( parent, "LeftPageList", 0, 0)
    GUI.SetIgnoreChild_OnVisible(pageList,true)
    SetAnchorAndPivot(pageList, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local ListBg = GUI.ImageCreate( pageList, "LeftListBg", "1800400010", 12, 55, false, 417, 487)
    SetAnchorAndPivot(ListBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local ListTitleBar = GUI.ImageCreate( pageList, "LeftListTitleBar", "1800400470", 15, 60, false, 410, 40)
    SetAnchorAndPivot(ListTitleBar, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local ListTitleTxt = GUI.CreateStatic( ListTitleBar, "LeftListTitleTxt","活力获得" ,0,0,96,33,"system",true,false);
    SetAnchorAndPivot(ListTitleTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(ListTitleTxt,24);
    GUI.SetColor(ListTitleTxt,colorDark);

    --滚动框
    local itemGetScroll = _gt.GetUI("itemGetScroll")

    -- 如果左边滚动列表已存在，就不再创建
    if itemGetScroll then return end

    -- 创建左边滚动列表
    itemGetScroll = GUI.LoopScrollRectCreate(
            ListBg,
            "itemGetScroll",
            4,
            50,
            410,
            433,
            "VitalityUI",
            "CreateGetItemPool",
            "VitalityUI",
            "RefreshLeftItemScroll",
            0,
            false,
            Vector2.New(400, 100),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft
    )

    SetSameAnchorAndPivot(itemGetScroll,UILayout.TopLeft)
    -- 设置滚动列表内每个框的锚点和中心点
    GUI.ScrollRectSetChildAnchor(itemGetScroll, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(itemGetScroll, UIAroundPivot.Top)
    -- 设置每个框的距离
    GUI.ScrollRectSetChildSpacing(itemGetScroll, Vector2.New(10, 3))
    -- 刷新每个框
    GUI.LoopScrollRectRefreshCells(itemGetScroll);
    _gt.BindName(itemGetScroll, "itemGetScroll")

end

-- 创建左边列表框的方法
function VitalityUI.CreateGetItemPool()

    local itemGetScroll = _gt.GetUI("itemGetScroll")
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(itemGetScroll)+1;

    local icon = GUI.ItemCtrlCreate(itemGetScroll,"getItem"..curIndex,"1800400460",-120,40)
    SetSameAnchorAndPivot(icon,UILayout.Center)

    --图标
    local itemIcon = GUI.ItemCtrlCreate( icon, "item", "1800400050", 8, 10, 0, 0, false)
    SetAnchorAndPivot(itemIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon, "1800400060" )

    local Icon = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.Icon)
    GUI.SetPositionY(Icon,-2)
    GUI.SetWidth(Icon,68)
    GUI.SetHeight(Icon,69)

    -- 不响应交互事件
    GUI.SetIsRaycastTarget(itemIcon, false)

    -- 名字
    local name = GUI.CreateStatic( icon, "name", "生龙活虎散", 104, 15, 175, 29,"system",true)
    SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(name, 24)
    GUI.SetColor(name, colorDark)

    -- 活力值
    local textInfo = GUI.CreateStatic( icon, "textInfo", "恢复200体力", 103, 57, 224, 25,"system",true)
    SetAnchorAndPivot(textInfo, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(textInfo, 20)
    GUI.SetColor(textInfo, UIDefine.Green7Color)

    -- 按钮
    local funcBtn = GUI.ButtonCreate( icon, "funcBtn", "1800402110", 310, 25, Transition.ColorTint, "",80,38,false)
    SetAnchorAndPivot(funcBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    -- 按钮上的文本
    local txt = GUI.CreateStatic(funcBtn,"txt","购买",0,0,80,38)
    GUI.StaticSetAlignment(txt,TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt,24)
    GUI.SetColor(txt,colorDark)
    -- 按钮点击事件
    GUI.RegisterUIEvent(funcBtn , UCE.PointerClick , "VitalityUI", "JumpToMedicineOrNpc")

    -- 未开启或已结束文本
    local notOpenSp = GUI.ImageCreate(icon, "notOpenSp","1800600040",-10,0,false,100,40)
    SetAnchorAndPivot(notOpenSp, UIAnchor.Right, UIAroundPivot.Right)
    local txt=GUI.CreateStatic(notOpenSp, "txt","已结束",0,0,90,35,"system",true);
    SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(txt,colorDark);
    GUI.StaticSetFontSize(txt,UIDefine.FontSizeSS)
    GUI.StaticSetAlignment(txt,TextAnchor.MiddleCenter)
    GUI.SetVisible(notOpenSp,false)
    return icon;
end
-- 刷新左边列表框的方法
function VitalityUI.RefreshLeftItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1];
    local index = tonumber(parameter[2])+1
    local item = GUI.GetByGuid(guid)

    -- 获取需要改变的GUI节点
    local itemIcon = GUI.GetChild(item,"item")
    local name = GUI.GetChild(item,"name")
    local textInfo = GUI.GetChild(item,"textInfo")
    local funcBtn = GUI.GetChild(item,"funcBtn")
    local btnTxt = GUI.GetChild(funcBtn,"txt")
    local notOpenSp = GUI.GetChild(item,"notOpenSp")
    local notOpenSpTxt = GUI.GetChild(notOpenSp,"txt")

    -- 先刷新加活力的药品
    if VitalityUI.LeftMedicineData and index <= #VitalityUI.LeftMedicineData then
        local v = VitalityUI.LeftMedicineData[index]
        -- 判断此药品是否开启显示
        if v.Switch == "on" then
            -- 通过药品keyName获取其对象
            if v.ItemKeyName then
                local medicineObj = DB.GetOnceItemByKey2(v.ItemKeyName)

                if medicineObj then

                    -- 修改图片
                    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,medicineObj.Icon)
                    -- 修改品质图片
                    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,VitalityUI.ItemQualityImage[medicineObj.Grade])

                    -- 修改名称
                    GUI.StaticSetText(name,medicineObj.Name)

                    -- 修改描述
                    GUI.StaticSetText(textInfo,medicineObj.Info)

                    -- 修改按钮字体
                    GUI.SetVisible(funcBtn,true)
                    GUI.SetVisible(notOpenSp,false)
                    -- 判断是否有此物品，如果没有就购买，如果有就使用
                    if LD.GetItemCountById(medicineObj.Id) <= 0 then
                        GUI.StaticSetText(btnTxt,"购买")
                        -- 为按钮绑定数据
                        GUI.SetData(funcBtn,"medicineID_Get",medicineObj.Id)
                    else
                        GUI.StaticSetText(btnTxt,"使用")
                        -- 为按钮绑定数据
                        GUI.SetData(funcBtn,"medicineID_Use",medicineObj.Id)
                        -- 删除get数据
                        GUI.SetData(funcBtn,"medicineID_Get",nil)
                    end

                end

            end
        end
        -- 再刷新活动任务
    elseif VitalityUI.ActivityData then

        local v = VitalityUI.ActivityData[index - #VitalityUI.LeftMedicineData]
        -- 为点击事件绑定数据
        GUI.SetData(funcBtn,"ActivityId",v.Id)
        -- 删除get数据
        GUI.SetData(funcBtn,"medicineID_Get",nil)
        -- 删除use数据
        GUI.SetData(funcBtn,"medicineID_Use",nil)
        -- 设置图片
        GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,v.Icon)

        -- 设置图片背景
        GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400050")
        -- 修改名称
        GUI.StaticSetText(name,v.Name)
        -- 修改描述
        GUI.StaticSetText(textInfo,"活跃 "..v.getVp.."/"..v.vpLimit)

        -- 修改按钮处显示
        -- 如果活动未开启,显示开启时间，如果活动已结束显示“已结束”字体
        if v.state == 1 then
            -- 显示按钮
            GUI.SetVisible(funcBtn,true)
            -- 关闭 未开启文本
            GUI.SetVisible(notOpenSp,false)
            -- 修改按钮字体
            GUI.StaticSetText(btnTxt,"前往")
        else
            -- 关闭按钮
            GUI.SetVisible(funcBtn,false)
            -- 显示未开启文本
            GUI.SetVisible(notOpenSp,true)
            if v.state == 0 then
                local time = string.split(v.TimeStart,":")
                time = time[1]..":"..time[2]
                GUI.ImageSetImageID(notOpenSp, "1800600040" )
                GUI.StaticSetText(notOpenSpTxt,"<color=#".."fe4f20"..">"..time.."</color>开启")
            elseif v.state == 2 then
                GUI.ImageSetImageID(notOpenSp, "1800604320" )
                GUI.StaticSetText(notOpenSpTxt,"")
            end
        end
    end


end

-- 刷新左边列表的方法
function VitalityUI.RefreshLeftList()

    local itemGetScroll = _gt.GetUI( "itemGetScroll" )
    if not itemGetScroll then return end
    -- 初始化左边数据
    VitalityUI.InitLeftData()

    if  VitalityUI.ActivityData and VitalityUI.LeftMedicineData then
        GUI.LoopScrollRectSetTotalCount(itemGetScroll ,#VitalityUI.ActivityData + #VitalityUI.LeftMedicineData)
        GUI.LoopScrollRectRefreshCells(itemGetScroll)
    else
        GUI.LoopScrollRectSetTotalCount(itemGetScroll ,5)
    end
end

-- 向服务器获取药品信息
function VitalityUI.GetMedicineDataRequest()
    CL.SendNotify(NOTIFY.SubmitForm,"FormVitality","GetMedicineData")
    -- 获取数据 VitalityUI.LeftMedicineData
    -- 执行刷新方法 VitalityUI.RefreshLeftList()
end

-- 左边按钮点击事件
function VitalityUI.JumpToMedicineOrNpc(guid)
    local item = GUI.GetByGuid(guid)
    local medicineID_Get = GUI.GetData(item,"medicineID_Get")
    local medicineID_Use = GUI.GetData(item,"medicineID_Use")
    local ActivityId = GUI.GetData(item,"ActivityId")

    -- 如果获取到的是药品GetID,打开商品界面
    if medicineID_Get then
        GUI.OpenWnd("MallUI", medicineID_Get)
        goto EventEnd
    end
    -- 如果获取到的是药品UseID，使用此药品
    if medicineID_Use then
        medicineID_Use = tonumber(medicineID_Use)
        if medicineID_Use == nil then
            return
        end
        local medicineCell = LD.GetItemGuidsById(medicineID_Use)
        if medicineCell and
                medicineCell[0]
        then
            -- 使用物品
            GlobalUtils.UseItem( medicineCell[0] )
            goto EventEnd
        end
    end

    -- 如果获取到的是活动ID，跳转到此活动
    if ActivityId then

        -- 判断活动ID是否正确
        if string.len(ActivityId) == 0 then
            return
        else
            -- 判断此活动ID是否能转换为数字
            ActivityId = tonumber(ActivityId)
            if ActivityId == nil then
                return
            else
                -- 判断此活动任务ID在表中是否存在
                local activity = DB.GetActivity(ActivityId)
                if activity and activity.Id then
                    -- 跳转地图，前往任务处
                    GlobalUtils.JoinActivity(ActivityId)
                    -- 关闭此窗口
                    VitalityUI.OnExit()
                    -- 关闭角色界面窗口
                    GUI.CloseWnd("RoleAttributeUI")
                end
            end
        end

    end

    ::EventEnd::

end
----------------------------------------------- 左边列表 end

function VitalityUI.Refresh()
    -- 刷新右边
    VitalityUI.SetVitalityValue()
    VitalityUI.RefreshUseItems()

    -- 刷新左边
    CL.SendNotify(NOTIFY.GetActivityList)
    VitalityUI.GetMedicineDataRequest()

end

function VitalityUI.OnTipBtnClick()
    local panelBg = GUI.TipsCreate(GUI.Get("VitalityUI/panelBg"), "Tips", 265, -65, 520, 120)
    GUI.SetIsRemoveWhenClick(panelBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(panelBg),false)
    local tipstext = GUI.CreateStatic(panelBg,"tipstext","1.使用活力道具和完成奖励活跃度的活动，可以获得活力值。",0,-75,480,120,"system", true)
    GUI.StaticSetFontSize(tipstext,26)
    local tipstext2 = GUI.CreateStatic(panelBg,"tipstext2","2.活跃度和活力值的兑换关系为1:1，获得活跃度时，会自动获得活力值。",0,-15,480,120,"system", true)
    GUI.StaticSetFontSize(tipstext2,26)
    local tipstext3 = GUI.CreateStatic(panelBg,"tipstext3","3.活力值上限会随着等级成长而提高。",0,30,480,120,"system", true)
    GUI.StaticSetFontSize(tipstext3,26)
    local tipstext4 = GUI.CreateStatic(panelBg,"tipstext4","4.活力值不可超出上限，达到上限时不可再获得活力值。",0,75,480,120,"system", true)
    GUI.StaticSetFontSize(tipstext4,26)
end

function VitalityUI.OnWorkTipBtnClick(guid)
    local  item = GUI.GetByGuid(guid)
    local Price = GUI.GetData(item,"tipsPrice")
    local BindGold = GUI.GetData(item,"tipsBingGold")
    local hintBg = Tips.CreateHint("消耗"..Price.."活力，可以赚取"..BindGold.."银币", _gt.GetUI("panelBg"), 210, -175, UILayout.Center, 420, 55)
    local hintText = GUI.GetChild(hintBg, "hintText", false)
    GUI.StaticSetAlignment(hintText, TextAnchor.MiddleCenter)
    GUI.SetVisible(GUI.TipsGetItemIcon(panelBg),false)

end



function VitalityUI.Register()
    CL.RegisterMessage(GM.RefreshBag, "VitalityUI", "RefreshLeftList");
    --CL.RegisterMessage(UM.CloseWhenClicked, "BagUI", "OnTipsClicked");
    CL.RegisterAttr(RoleAttr.RoleAttrVp, VitalityUI.OnPlayerAttrChange)
    CL.RegisterMessage(GM.ActivityListUpdate, "VitalityUI", "RefreshLeftList");
    CL.RegisterMessage(GM.FightStateNtf, "VitalityUI", "InFight");
end

function VitalityUI.UnRegister()
    CL.UnRegisterMessage(GM.RefreshBag, "VitalityUI", "RefreshLeftList");
    CL.UnRegisterAttr(RoleAttr.RoleAttrVp, VitalityUI.OnPlayerAttrChange)
    CL.UnRegisterMessage(GM.ActivityListUpdate, "VitalityUI", "RefreshLeftList");
    CL.UnRegisterMessage(GM.FightStateNtf, "VitalityUI", "InFight");
end

-- 进入战斗关闭窗口
function  VitalityUI.InFight(isFight)
    if isFight then
        VitalityUI.OnExit()
    end
end



function VitalityUI.OnPlayerAttrChange(attrType, value)
    local textInfo = _gt.GetUI("TextInfo")
    if CL.GetIntAttr(RoleAttr.RoleAttrVp) ~= value then
        value = tostring(value)
        local valueNum = tonumber(value)
        VitalityUI.SetVitalityValue(value)
        if valueNum < 50 then
            GUI.SetColor(textInfo,colorRed)
        elseif valueNum >= 50 then
            GUI.SetColor(textInfo,colorGreen)
        end
    end
end

--CurContactsList
--local parent = GuidCacheUtil.GetUI("latelyScrollWnd")
--    local index = GUI.LoopScrollRectGetChildInPoolCount(parent)
--    local name = "ContactItem" .. index
--contactsScrollWnd