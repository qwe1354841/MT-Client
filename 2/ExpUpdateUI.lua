ExpUpdateUI = {}

local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
-- 颜色
local colorDark = Color.New(102/255, 47/255, 22/255, 255/255)
local colorWhite = Color.New(255/255, 246/255, 232/255, 255/255)
local colorGreen = Color.New(25 / 255, 200 / 255, 0 / 255, 255 / 255);

-- 比最大等级少1,后悔没写成5，但用的地方太多难改动了
local MAX_LEVEL = 4

local QualityRes = { "1800400330","1800400100","1800400110","1800400120","1800400320" }

--阵法碎片的ID（用于剪影展示）
local ShadowItemID = 20961

-- 是否第一次打开界面
ExpUpdateUI._first_open_page = true

function ExpUpdateUI.Main()


    local _Panel = GUI.WndCreateWnd("ExpUpdateUI", "ExpUpdateUI", 0, 0, eCanvasGroup.Normal)

    local _PanelBack = UILayout.CreateFrame_WndStyle2(_Panel,"提升阵法",560,435,"ExpUpdateUI","OnExit")


    --道具列表
    local _ItemLstBack = GUI.ImageCreate( _PanelBack, "ItemLstBack", "1800400200", 0, -24, false, 506, 268)
    SetAnchorAndPivot(_ItemLstBack, UIAnchor.Center, UIAroundPivot.Center)

    local _OneRequestPanelSize = Vector2.New(78,78)
    local _SeatScroll = GUI.ScrollRectCreate(_ItemLstBack, "SeatScroll",4,16,500,241,0,false,_OneRequestPanelSize,UIAroundPivot.Top,UIAnchor.Top, 6)
    SetAnchorAndPivot(_SeatScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(_SeatScroll,Vector2.New(1,1))
    GUI.ScrollRectSetNormalizedPosition(_SeatScroll,Vector2.New(0,0))


    --背景框
    local _FaceBack = GUI.ImageCreate( _PanelBack, "FaceBack", "1800700020", 26, -19)
    SetAnchorAndPivot(_FaceBack, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    _gt.BindName(_FaceBack,"FaceBack")

    --图标
    local _Icon = GUI.ImageCreate( _FaceBack, "Icon", "1800700020", 0, 0, false, 76, 76)
    SetAnchorAndPivot(_Icon, UIAnchor.Center, UIAroundPivot.Center)

    --阵法名称
    local _BattleSeatName = GUI.CreateStatic( _FaceBack, "Name", "1级鹰啸阵", 90, -10, 200, 35, "system", true)
    SetAnchorAndPivot(_BattleSeatName, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_BattleSeatName, 24)
    GUI.SetColor(_BattleSeatName, colorDark)
    _gt.BindName(_BattleSeatName,"BattleSeatName")

    -- 阵法升级字体
    local _BattleSeat_Up_Text = GUI.CreateStatic(_FaceBack,"BattleSeat_Up_Text","(+1级)",210,-10,100,35)
    SetAnchorAndPivot(_BattleSeat_Up_Text,UIAnchor.TopLeft,UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_BattleSeat_Up_Text,24)
    GUI.SetColor(_BattleSeat_Up_Text,colorGreen)
    _gt.BindName(_BattleSeat_Up_Text,"BattleSeat_Up_Text")
    GUI.SetVisible(_BattleSeat_Up_Text,false)

    --经验条ExpPreView
    local _ExpPreView = GUI.ScrollBarCreate(_FaceBack, "ExpPreView","","1800408130","1800408110",251,-66,0,0,1,false,Transition.None,0,1,Direction.LeftToRight,false)
    local _ExpPreviewValue =Vector2.New(327,26)
    GUI.ScrollBarSetFillSize(_ExpPreView,_ExpPreviewValue)
    GUI.ScrollBarSetBgSize(_ExpPreView, _ExpPreviewValue)
    SetAnchorAndPivot(_ExpPreView, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(_ExpPreView,"ExpPreView")

    --经验条
    local _Exp = GUI.ScrollBarCreate(_FaceBack, "Exp","","1800408160","1800499999",251,-66,0,0,1,false,Transition.None,0,1,Direction.LeftToRight,false)
    local _ExpValue =Vector2.New(327,26)
    GUI.ScrollBarSetFillSize(_Exp,_ExpValue)
    GUI.ScrollBarSetBgSize(_Exp, _ExpValue)
    SetAnchorAndPivot(_Exp, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(_Exp,"Exp")

    -- 经验条文本
    local _ExpTxt = GUI.CreateStatic( _Exp, "ExpTxt", "100/400", 0, 1,327,26)
    SetAnchorAndPivot(_ExpTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_ExpTxt, 20)
    GUI.SetColor(_ExpTxt, colorWhite)
    GUI.StaticSetAlignment(_ExpTxt,TextAnchor.MiddleCenter)
    _gt.BindName(_ExpTxt,"ExpTxt")

    --使用按钮
    local _UseBtn = GUI.ButtonCreate(_FaceBack, "UseBtn", "1800402110",424,-38, Transition.ColorTint, "使用", 82, 46, false)
    SetAnchorAndPivot(_UseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_UseBtn, 24)
    GUI.ButtonSetTextColor(_UseBtn, colorDark)
    GUI.RegisterUIEvent(_UseBtn , UCE.PointerClick , "ExpUpdateUI", "OnUseBtn" )

    --选中最大可用
    local _Chosen = GUI.CheckBoxCreate( _FaceBack, "ChooseUsefulCheckBox", "1800607150", "1800607151", 338, 45, Transition.None, true, 32, 32) -- ExpUpdateUI.GetChooseUseful()
    local _ChosenLabel = GUI.CreateStatic( _Chosen, "ChooseUsefulLabel", "选中最大可用", 35, 5, 140, 30)
    GUI.StaticSetFontSize(_ChosenLabel, 22)
    GUI.SetColor(_ChosenLabel, colorDark)
    GUI.RegisterUIEvent(_Chosen, UCE.PointerClick, "ExpUpdateUI", "OnChooseUsefulCheckBoxClick")

    --注册消息
    --CL.RegisterMessage(GM.TeamSeatInfoUpdate,"ExpUpdateUI" , "OnTeamSeatInfoUpdate");
    --CL.RegisterMessage(GM.InFight,"ExpUpdateUI","OnEnterFight")
    --ExpUpdateUI.TeamUpdateTimer = Timer.New(ExpUpdateUI.TeamUpdateTimerListener,0.1, -1, true)
    CL.RegisterMessage(GM.RefreshBag,'ExpUpdateUI','Get_Formation_UpMaterialID')
end

ExpUpdateUI.BattleSeatInfo = nil  -- 打开窗口时传入的信息
function ExpUpdateUI.OnShow(BattleSeatInfo)
    -- 第一次打开界面
    ExpUpdateUI._first_open_page = true

    --刷新经验条
    if BattleSeatInfo == nil then
        test("传入到ExpUpdateUI页面的参数为空")
        return
    end
    -- 格式化数据
    local info = string.split(BattleSeatInfo,"-")
    local BattleSeatInfo = {["Id"]=tonumber(info[1]),["Level"]=tonumber(info[2]),["Score"]=tonumber(info[3])}

    ExpUpdateUI.FORMATION_HAVE_EXP = BattleSeatInfo["Score"]
    ExpUpdateUI.BattleSeatInfo = BattleSeatInfo
    info = nil
    BattleSeatInfo = nil

    --ExpUpdateUI.InitData()  -- 执行初始化数据方法
    --显示道具列表
    --ExpUpdateUI.CreateItems()
    ExpUpdateUI.Get_Formation_UpMaterialID() -- 向服务器请求阵法升级材料物品的id
end

-- 初始化数据
ExpUpdateUI.MaterialInfo = {} -- 材料列表
ExpUpdateUI.GotoMaxLevelNeedExp = nil -- 从当前等级升到最大等级所需要的经验值
function ExpUpdateUI.InitData()
    ExpUpdateUI.MaterialInfo = {} -- 清空数据
    ExpUpdateUI.FORMATION_ADD_EXP = 0 -- 清空数据

    if ExpUpdateUI.ScoreItem_Config then -- 如果请求服务器数据存在

        for k,v in pairs(ExpUpdateUI.ScoreItem_Config) do
            local item = DB.GetOnceItemByKey1(v.id) -- 获取此物品对象
            -- 获取物品格子GUID
            local itemCell_GUIDList = LD.GetItemGuidsById(v.id)
            if itemCell_GUIDList then
                for i=0,itemCell_GUIDList.Count -1  do -- 遍历所获取的格子
                    -- 获取此物品的数量
                    local Count = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,itemCell_GUIDList[i]))
                    -- 获取此物品是否绑定
                    local isBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,itemCell_GUIDList[i]) == "1"
                    -- 1图片、2品质、3数量、4加的经验值、5选择数量、6是否绑定、7物品Id
                    table.insert(ExpUpdateUI.MaterialInfo,{ tostring(item.Icon), item.Grade, Count, v.addscore, Count,isBind,item.Id})
                    -- 计算出增加的经验值
                    ExpUpdateUI.FORMATION_ADD_EXP = ExpUpdateUI.FORMATION_ADD_EXP + Count * v.addscore
                end
            end
        end
        ExpUpdateUI.Formation_Current_Add_Exp = ExpUpdateUI.FORMATION_ADD_EXP
        -- 打印
        --local inspect = require("inspect")
        --CDebug.LogError(inspect(ExpUpdateUI.MaterialInfo))
        ExpUpdateUI.CreateItems() -- 创建道具列表
        ExpUpdateUI.ShowItems() -- 刷新阵法材料框

        if ExpUpdateUI.BattleSeatInfo ~= nil then
            ExpUpdateUI.ShowExpInfo(ExpUpdateUI.BattleSeatInfo) -- 刷新阵法头像和等级和经验条

            -- 计算升到最大等级所需要的经验值
            ExpUpdateUI.GotoMaxLevelNeedExp = 0
            for i = ExpUpdateUI.BattleSeatInfo.Level , MAX_LEVEL do
                local exp = DB.GetSeat(ExpUpdateUI.BattleSeatInfo.Id,i).UpExp
                ExpUpdateUI.GotoMaxLevelNeedExp = ExpUpdateUI.GotoMaxLevelNeedExp + exp
            end

        end
        ExpUpdateUI.OnChooseUsefulCheckBoxClick() -- 选中最大可用点击事件
    end
end
-------------------------------------上部分开始-------------------------------------------
-- 向服务器请求阵法升级材料物品的id
function ExpUpdateUI.Get_Formation_UpMaterialID()

    if ExpUpdateUI.BattleSeatInfo.Id then
        CL.SendNotify(NOTIFY.SubmitForm,"FormSeat","ScoreItem_Config", tostring(ExpUpdateUI.BattleSeatInfo.Id))
    else
        test('ExpUpdateUI界面  ExpUpdateUI.Get_Formation_UpMaterialID方法 ExpUpdateUI.BattleSeatInfo.Id数据为空')
        CL.SendNotify(NOTIFY.ShowBBMsg, "系统错误")
    end
    -- 请求数据ExpUpdateUI.ScoreItem_Config 一行为{id = 20961 , key = '阵法书残卷' , addscore = 200}
    -- 执行initdata方法
end

-- 创建阵法升级材料框静态页面
function ExpUpdateUI.CreateItems()
    if ExpUpdateUI.MaterialInfo == nil  then
        test("ExpUpdateUI 创建阵法升级材料框静态页面时 材料数据为空")
        return
    end
    local MaxNum = #ExpUpdateUI.MaterialInfo
    local IsShow = true -- 物品是否显示
    local IconID = "" -- 材料图片
    local GradeIcon = "" -- 材料背景
    local NumInfo = "5/5"
    if MaxNum < 18 then MaxNum = 18 end -- 最小18 格
    if MaxNum > 18 then MaxNum = math.ceil(MaxNum / 6) * 6 end
    if MaxNum > 150 then MaxNum = 150 end -- 最大150 格


    local _SeatScroll = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll")

    for i=1,MaxNum do
        local _Item = GUI.GetChild(_SeatScroll,"Item"..i)
        if _Item == nil then
            --底板
            _Item = GUI.ImageCreate( _SeatScroll, "Item"..i, "1800600050", 0, 0, false, 78, 78)
            SetAnchorAndPivot(_Item, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetVisible(_Item, true)

            --图标
            local _Icon = GUI.ItemCtrlCreate( _Item, tostring(i), "1800600050", 0, 0, 76, 76, false)
            SetAnchorAndPivot(_Icon, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(_Icon, IsShow)
            GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Icon, IconID)
            GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Border, GradeIcon)
            GUI.RegisterUIEvent(_Icon , UCE.PointerClick , "ExpUpdateUI", "OnClickItem" )
            _Icon:RegisterEvent(UCE.PointerUp)
            _Icon:RegisterEvent(UCE.PointerDown)
            GUI.RegisterUIEvent(_Icon, UCE.PointerDown , "ExpUpdateUI", "OnClickItemDown")
            GUI.RegisterUIEvent(_Icon, UCE.PointerUp , "ExpUpdateUI", "OnClickItemUp")

            --数量
            local _Num = GUI.CreateStatic( _Item, "Num"..i, NumInfo, 0, 27, 100, 35)
            SetAnchorAndPivot(_Num, UIAnchor.Center, UIAroundPivot.Center)
            GUI.StaticSetFontSize(_Num, 18)
            GUI.SetColor(_Num, colorDark)
            GUI.StaticSetAlignment(_Num,TextAnchor.MiddleCenter)
            GUI.SetVisible(_Num, false)

            --选中标记
            local _SelectFlag = GUI.ImageCreate( _Item, "SelectFlag", "1800400280", 0, 0)
            SetAnchorAndPivot(_SelectFlag, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(_SelectFlag, false)

            --减少按钮
            local _DecBtn = GUI.ButtonCreate(_Item, "DecBtn"..i, "1800402140",2,0, Transition.ColorTint, "", 32,32, false)
            SetAnchorAndPivot(_DecBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.SetVisible(_DecBtn, false)
            GUI.RegisterUIEvent(_DecBtn , UCE.PointerClick , "ExpUpdateUI", "OnDecBtn" )
            _DecBtn:RegisterEvent(UCE.PointerUp)
            _DecBtn:RegisterEvent(UCE.PointerDown)
            GUI.RegisterUIEvent(_DecBtn, UCE.PointerDown , "ExpUpdateUI", "OnDecDown")
            GUI.RegisterUIEvent(_DecBtn, UCE.PointerUp , "ExpUpdateUI", "OnDecUp")

        end
    end
    --ExpUpdateUI.Get_Formation_UpMaterialID()
end
-- 刷新阵法材料框
function ExpUpdateUI.ShowItems()
    if ExpUpdateUI.MaterialInfo == nil  then
        test("刷新阵法材料框时 材料数据为空")
        return
    end
    local MaxNum = #ExpUpdateUI.MaterialInfo
    local IsShow = true -- 物品是否显示
    local IconID = "1900352700" -- 物品id
    local GradeIcon = "1800400320" -- 物品品质背景
    local NumInfo = 5
    local IsHaveFragShadow = false -- 是否有阴影
    local Count = 9

    if MaxNum > 150 then MaxNum = 150 end  -- 最多显示150个材料

    for i=1,MaxNum do
        local _Item = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll/Item"..i)
        if _Item then
            GUI.SetVisible(_Item, IsShow )
            --图标
            local _Icon = GUI.GetChild(_Item,tostring(i))
            if _Icon ~= nil then
                if IsShow then
                    GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Icon,ExpUpdateUI.MaterialInfo[i][1])
                    GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Border,QualityRes[ExpUpdateUI.MaterialInfo[i][2]])
                    GUI.SetData(_Icon,"index",i)
                end
                GUI.SetVisible(_Icon, IsShow)
            end
            --数量
            local _Num = GUI.GetChild(_Item,"Num"..i)
            if _Num ~= nil then
                if IsShow then
                    GUI.StaticSetText(_Num,(ExpUpdateUI.MaterialInfo[i][5].."/"..ExpUpdateUI.MaterialInfo[i][3]) or NumInfo)
                end
                GUI.SetVisible(_Num, IsShow)
            end
            --减少按钮
            local _DecBtn = GUI.GetChild(_Item,"DecBtn"..i)
            if _DecBtn ~= nil then
                GUI.SetData(_DecBtn,"index",i)
                GUI.SetVisible(_DecBtn, IsShow)
            end

            -- 选中框和tips  如果是第一次打开界面时
            if ExpUpdateUI._first_open_page and i == 1 then
                local _SelectFlag = GUI.GetChild(_Item,"SelectFlag")
                GUI.SetVisible(_SelectFlag, true)
                ExpUpdateUI._first_open_page = false
                ExpUpdateUI.OnClickItem(GUI.GetGuid(_Icon))
            end

        end
    end
    -- 如果没有任何材料则显示灰色阵法残卷
    if MaxNum == 0 then
        local _Item = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll/Item"..1)
        if _Item ~= nil then
            local _Icon = GUI.GetChild(_Item,tostring(1))
            GUI.SetVisible(_Icon,true)
            GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Icon,"1900000640")
            GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Border,QualityRes[1])
            GUI.ItemCtrlSetIconGray(_Icon,true)

            -- 选中框和tips  如果是第一次打开界面时
            if ExpUpdateUI._first_open_page then
                local _SelectFlag = GUI.GetChild(_Item,"SelectFlag")
                GUI.SetVisible(_SelectFlag, true)
                ExpUpdateUI._first_open_page = false
                ExpUpdateUI.OnClickItem(GUI.GetGuid(_Icon))
            end
        end
    end

    local ceil_count = math.ceil(MaxNum / 6) * 6
    if ceil_count < 18 then ceil_count = 18 end

    if ExpUpdateUI._max_ceil_count == nil or ExpUpdateUI._max_ceil_count < ceil_count then ExpUpdateUI._max_ceil_count = ceil_count end
    if ExpUpdateUI._max_ceil_count > ceil_count then
        for i = ceil_count + 1 , ExpUpdateUI._max_ceil_count do
            local _Item = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll/Item"..i)
            if _Item ~= nil and GUI.GetVisible(_Item) then
                GUI.SetVisible(_Item, false)
            else
                break
            end
        end
    end

end


-- 长按
local btn_Guid = nil
local TimerFunction = function ()
    if btn_Guid ~= nil then
        ExpUpdateUI.OnClickItem(btn_Guid)
    end
end

-- 阵法升级材料 点击事件 创建tips、如果不是最大值增加选中数量
ExpUpdateUI.PreSelectedElementIndex = nil -- 上一次选中的材料框节点下标
function ExpUpdateUI.OnClickItem(guid)
    local _Icon = GUI.GetByGuid(guid) -- 材料图片节点
    local index = tonumber(GUI.GetData(_Icon,"index")) -- 材料下标
    local MaterialInfo = ExpUpdateUI.MaterialInfo[index]

    -- 如果达到最大等级
    if ExpUpdateUI.BattleSeatInfo ~= nil and ExpUpdateUI.BattleSeatInfo.Level == MAX_LEVEL + 1 then
        ExpUpdateUI.ClickItemTimer:Stop()
        ExpUpdateUI.ClickItemTimer:Reset(TimerFunction,0.1,-1)
        CL.SendNotify(NOTIFY.ShowBBMsg,"经验已达阵法学习上限")
        return ''
    end

    if ExpUpdateUI.Formation_Current_Add_Exp and ExpUpdateUI.FORMATION_HAVE_EXP and ExpUpdateUI.Formation_UP_Exp
        and ExpUpdateUI.BattleSeatInfo and ExpUpdateUI.BattleSeatInfo.Level then

        -- 如果增加的经验达到最大等级
        local exp = ExpUpdateUI.Formation_Current_Add_Exp + ExpUpdateUI.FORMATION_HAVE_EXP -- 经验值
        local up_need_exp = ExpUpdateUI.Formation_UP_Exp
        local can_up = true

        if up_need_exp <= exp then
            -- 两边同时-1 简化判断条件ExpUpdateUI.BattleSeatInfo.Level +1 >= MAX_LEVEL + 1
            if ExpUpdateUI.BattleSeatInfo.Level  >= MAX_LEVEL  then
                can_up = false
            else
                for i =ExpUpdateUI.BattleSeatInfo.Level +2,  MAX_LEVEL + 1 do

                    -- 阵法从0级开始，4->5级经验为0,所以得减1
                    local seat = DB.GetSeat(ExpUpdateUI.BattleSeatInfo.Id,i-1)
                    up_need_exp = up_need_exp + seat.UpExp

                    -- 如果再升一级的经验也满足
                    if up_need_exp <= exp then
                        -- 判断再升一级后是否满级
                        if i >= MAX_LEVEL +1 then
                            -- 如果满级就修改变量，跳出循环
                            can_up = false
                            break
                        end
                        -- 如果无法再升一级，且未达到最大等级
                    else
                        break
                    end

                end
            end
        end

        if can_up == false then
            ExpUpdateUI.ClickItemTimer:Stop()
            ExpUpdateUI.ClickItemTimer:Reset(TimerFunction,0.1,-1)
            --CL.SendNotify(NOTIFY.ShowBBMsg,"已填充经验至最大等级")
            return ''
        end

    end

    -- 创建tips
    local panelBg = GUI.Get("ExpUpdateUI/panelBg")

    local tip = _gt.GetUI('up_seat_Tips')
    -- 如果tip存在，则销毁它
    if tip then GUI.Destroy(tip) end

    if MaterialInfo == nil then
        -- 如果没有物品显示阵法残卷tips
        tip = Tips.CreateByItemId(ShadowItemID, panelBg,"materialTips",434,16)
        index = 1
    else
        tip = Tips.CreateByItemId(MaterialInfo[7],panelBg,"materialTips",434,16)
        local isBind = MaterialInfo[6]
        if isBind then -- 添加绑定图标
            local tipsIcon = GUI.TipsGetItemIcon(tip)
            GUI.ItemCtrlSetElementValue(tipsIcon,eItemIconElement.LeftTopSp,"1800707120")
        end
    end

    -- 增加获取途径按钮
    local item_id = MaterialInfo and MaterialInfo[7] or ShadowItemID
    GUI.SetData(tip, "ItemId", item_id)
    GUI.SetHeight(tip,GUI.GetHeight(tip)+40)
    _gt.BindName(tip, "up_seat_Tips")
    local wayBtn = GUI.ButtonCreate(tip, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
    UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"ExpUpdateUI","OnClickFormationWayBtn")
    GUI.AddWhiteName(tip, GUI.GetGuid(wayBtn))

    -- 增加选中数量
    local _SeatScroll = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll")
    -- 写在这是为了给阵法残片用
    local _Item = GUI.GetChild(_SeatScroll,"Item"..index)
    if MaterialInfo then
        --_Item = GUI.GetChild(_SeatScroll,"Item"..index)
        local  _Num = GUI.GetChild(_Item,"Num"..index)
        local _DecBtn = GUI.GetChild(_Item,"DecBtn"..index)
        if MaterialInfo[5] < MaterialInfo[3] then -- 如果选择的数量小于拥有的数量
            if MaterialInfo[5] +1 <= MaterialInfo[3] then -- 如果选择的数量+1 不大于拥有的数量
                MaterialInfo[5] = MaterialInfo[5] + 1
                GUI.StaticSetText(_Num,MaterialInfo[5].."/"..MaterialInfo[3])

                -- 刷新底部阵法经验值
                local  ExpPreView = _gt.GetUI("ExpPreView")
                local ExpTxt = _gt.GetUI("ExpTxt")
                if ExpUpdateUI.Formation_Current_Add_Exp ~= nil and ExpUpdateUI.Formation_UP_Exp ~= nil and ExpUpdateUI.FORMATION_HAVE_EXP ~= nil then
                    ExpUpdateUI.Formation_Current_Add_Exp = ExpUpdateUI.Formation_Current_Add_Exp + MaterialInfo[4]
                    GUI.ScrollBarSetPos(ExpPreView,(ExpUpdateUI.Formation_Current_Add_Exp + ExpUpdateUI.FORMATION_HAVE_EXP)/ExpUpdateUI.Formation_UP_Exp)
                    -- 设置经验条文本
                    GUI.StaticSetText(ExpTxt,ExpUpdateUI.FORMATION_HAVE_EXP.."( +"..ExpUpdateUI.Formation_Current_Add_Exp..") /"..ExpUpdateUI.Formation_UP_Exp)
                    ExpUpdateUI.Formation_Up_Level() -- 更新+多少级字体
                end

                -- 当选中数量大于零时显示减少按钮
                if MaterialInfo[5] > 0 then
                    GUI.SetVisible(_DecBtn,true)
                end

            end
        end
    end

    -- 显示选中框
    local _SelectFlag = GUI.GetChild(_Item,"SelectFlag")
    GUI.SetVisible(_SelectFlag,true)
    -- 将上一个选中框隐藏
    if ExpUpdateUI.PreSelectedElementIndex ~= nil and ExpUpdateUI.PreSelectedElementIndex ~= index then
        local Pre_Item = GUI.GetChild(_SeatScroll,"Item"..ExpUpdateUI.PreSelectedElementIndex)
        local Pre_SelectFlag = GUI.GetChild(Pre_Item,"SelectFlag")
        GUI.SetVisible(Pre_SelectFlag,false)
    end
    ExpUpdateUI.PreSelectedElementIndex = index

end

-- 获取途径方法
function ExpUpdateUI.OnClickFormationWayBtn()
    local tip = _gt.GetUI("up_seat_Tips")
    if tip then
        -- 点击后会跳转到这x的位置，然后再执行下一条语句时，x 会-200, 所以最终结果是-52
        GUI.SetPositionX(tip,148)
        Tips.ShowItemGetWay(tip)
    end
end

ExpUpdateUI.ClickItemTimer = Timer.New(TimerFunction,0.1,-1)
-- 按下 开始计时器 循环执行函数
function ExpUpdateUI.OnClickItemDown(guid)
    if ExpUpdateUI.ClickItemTimer ~= nil then
        btn_Guid = guid
        ExpUpdateUI.ClickItemTimer:Start()
    end
end
-- 松开 暂停计时器
function ExpUpdateUI.OnClickItemUp(guid)
    if ExpUpdateUI.ClickItemTimer ~= nil then
        btn_Guid = nil
        ExpUpdateUI.ClickItemTimer:Stop()
        ExpUpdateUI.ClickItemTimer:Reset(TimerFunction,0.1,-1)
    end
end

-- 长按
local DecBtn_Guid = nil
local DecTimerFunction = function ()
    if DecBtn_Guid ~= nil then
        ExpUpdateUI.OnDecBtn(DecBtn_Guid)
    end
end
local DecTimer = Timer.New(DecTimerFunction,0.1,-1)

-- 松开
function ExpUpdateUI.OnDecUp(guid)
    if DecTimer ~= nil then
        DecBtn_Guid = nil
        DecTimer:Stop()
        DecTimer:Reset(DecTimerFunction,0.1,-1)
    end
end


-- 减少按钮点击事件
function ExpUpdateUI.OnDecBtn(guid)
   local _DecBtn = GUI.GetByGuid(guid)

    local index = tonumber(GUI.GetData(_DecBtn,"index"))
    local MaterialInfo = ExpUpdateUI.MaterialInfo[index]

    -- 减少材料选中数量
    local _SeatScroll = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll")
    local _Item = GUI.GetChild(_SeatScroll,"Item"..index)
    local  _Num = GUI.GetChild(_Item,"Num"..index)
    if MaterialInfo[5] <= MaterialInfo[3] and MaterialInfo[5] >= 0 then -- 选中材料数量 <= 拥有材料的数量
        if MaterialInfo[5] - 1 >= 0 then -- 选中材料数量-1 不小于0
           MaterialInfo[5] = MaterialInfo[5] -1
            GUI.StaticSetText(_Num,MaterialInfo[5].."/"..MaterialInfo[3])

            -- 刷新底部阵法经验值
            local  ExpPreView = _gt.GetUI("ExpPreView")
            local ExpTxt = _gt.GetUI("ExpTxt")
            if ExpUpdateUI.Formation_Current_Add_Exp ~= nil and ExpUpdateUI.Formation_UP_Exp ~= nil and ExpUpdateUI.FORMATION_HAVE_EXP ~= nil then
                ExpUpdateUI.Formation_Current_Add_Exp = ExpUpdateUI.Formation_Current_Add_Exp - MaterialInfo[4]
                GUI.ScrollBarSetPos(ExpPreView,(ExpUpdateUI.Formation_Current_Add_Exp + ExpUpdateUI.FORMATION_HAVE_EXP)/ExpUpdateUI.Formation_UP_Exp)
                -- 设置经验条文本
                GUI.StaticSetText(ExpTxt,ExpUpdateUI.FORMATION_HAVE_EXP.."( +"..ExpUpdateUI.Formation_Current_Add_Exp..") /"..ExpUpdateUI.Formation_UP_Exp)
                ExpUpdateUI.Formation_Up_Level() -- 更新+多少级字体
            end

            -- 当减少到零时隐藏按钮
            if MaterialInfo[5] == 0 then
                GUI.SetVisible(_DecBtn,false)
                -- 防止减少按钮隐藏后 计时器不终止
                if DecTimer ~= nil then
                    DecBtn_Guid = nil
                    DecTimer:Stop()
                    DecTimer:Reset(DecTimerFunction,0.1,-1)
                end

            end
        end
    end

end


-- 按下
function ExpUpdateUI.OnDecDown(guid)
    if DecTimer ~= nil then
        DecBtn_Guid = guid
        DecTimer:Start()
    end
end

-------------------------------------上部分结束-------------------------------------------

-------------------------------------下部分开始-------------------------------------------
-- 刷新阵法头像和等级和经验条
ExpUpdateUI.FORMATION_HAVE_EXP = nil -- 阵法已有的经验值
ExpUpdateUI.FORMATION_ADD_EXP = nil -- 阵法使用所有材料增加的经验值
ExpUpdateUI.Formation_Current_Add_Exp = nil -- 当前阵法使用材料增加的经验值
ExpUpdateUI.Formation_UP_Exp = nil -- 当前等级阵法升级所需经验值
function ExpUpdateUI.ShowExpInfo(BattleSeatInfo)
    local BattleSeat = nil -- 阵法对象
    if not (BattleSeatInfo and ExpUpdateUI.Formation_Current_Add_Exp) then
        test("刷新阵法头像和等级和经验条时 传入的阵法数据为空")
        return
    else
        BattleSeat = DB.GetSeat(BattleSeatInfo.Id,BattleSeatInfo.Level)
        ExpUpdateUI.Formation_UP_Exp = BattleSeat.UpExp
        ExpUpdateUI.FORMATION_HAVE_EXP = BattleSeatInfo.Score
    end
    local FaceBack = _gt.GetUI("FaceBack") -- 父类
    local Icon = GUI.GetChild(FaceBack,"Icon") -- 图标
    local Name = GUI.GetChild(FaceBack,"Name") -- 阵法名称
    local Exp = GUI.GetChild(FaceBack,"Exp") -- 经验条
    local UpExp = GUI.GetChild(FaceBack,"ExpPreView") -- 升级经验条
    local ExpTxt = GUI.GetChild(Exp, "ExpTxt") -- 经验条文本

    local materialAddEX = ExpUpdateUI.Formation_Current_Add_Exp -- 使用升级阵法材料所获得的经验

    -- 插入阵法图标
    if Icon then
        GUI.ImageSetImageID(Icon,BattleSeat.Icon)
    end

    -- 插入阵法名称
    if Name then
        GUI.StaticSetText(Name,BattleSeat.Name.." "..BattleSeatInfo.Level.."级")
        ExpUpdateUI.Formation_Up_Level() -- 插入升级等级
    end

    local is_max_levle = (BattleSeatInfo.Level >= MAX_LEVEL + 1) and true or nil

    -- 插入经验条
    if Exp then
        if is_max_levle then
            GUI.ScrollBarSetPos(Exp,1)
        else
            if BattleSeat.UpExp ~= 0 then
                GUI.ScrollBarSetPos(Exp,BattleSeatInfo.Score/BattleSeat.UpExp)
            else
                test('ExpUpdateUI.ShowExpInfo(BattleSeatInfo) 除零异常')
            end
        end
    end

    -- 插入经验条文本
    if ExpTxt then
        if is_max_levle then
            GUI.StaticSetText(ExpTxt,"Max")
        else
            if materialAddEX == 0 then -- 如果使用阵法材料所获得的经验 == 0
                GUI.StaticSetText(ExpTxt,BattleSeatInfo.Score.." /"..BattleSeat.UpExp)
            else
                GUI.StaticSetText(ExpTxt,BattleSeatInfo.Score.."( +".. materialAddEX ..")".." /"..BattleSeat.UpExp)
            end
        end
    end

    -- 插入升级经验条
    if UpExp then
        if is_max_levle then
            GUI.ScrollBarSetPos(UpExp,1)
        else
            if BattleSeat.UpExp ~= 0 then
                GUI.ScrollBarSetPos(UpExp,(BattleSeatInfo.Score + materialAddEX)/BattleSeat.UpExp)
            else
                test('ExpUpdateUI.ShowExpInfo(BattleSeatInfo) 除零异常')
            end
        end
    end

end

-- 判断加多少级的方法
function ExpUpdateUI.Formation_Up_Level()
    if not (ExpUpdateUI.BattleSeatInfo and ExpUpdateUI.FORMATION_HAVE_EXP and ExpUpdateUI.Formation_Current_Add_Exp and ExpUpdateUI.Formation_UP_Exp) then
        test("ExpUpdateUI页面，执行判断加多少级时 参数为空 无法计算")
       return nil
    end

    local Exp = ExpUpdateUI.Formation_Current_Add_Exp + ExpUpdateUI.FORMATION_HAVE_EXP -- 经验值
    local Level = ExpUpdateUI.BattleSeatInfo.Level -- 当前阵法等级
    local add_Level = 0 -- 增加的阵法等级
    local BattleSeat_Up_Text = _gt.GetUI("BattleSeat_Up_Text") -- 升级文本
    if BattleSeat_Up_Text then
        GUI.SetVisible(BattleSeat_Up_Text,false)
    end
    -- 判断是否够升一级，再深入判断能升多少级
    local upNeedExp = ExpUpdateUI.Formation_UP_Exp
    if Exp >= ExpUpdateUI.Formation_UP_Exp then --当前经验值是否 >= 当前等级升级所需的经验值
        local Formation = nil -- 阵法对象
        repeat
            add_Level = add_Level + 1
            if (Level + add_Level) > MAX_LEVEL then -- 如果当前等级 + 可升级的等级 高于 4级，达到最大等级5 5级升级所需经验为0 不处理会导致死循环
                if Level == MAX_LEVEL +1 then -- 如果当前等级为5 级 将加的等级为0
                    add_Level = 0
                end
                break
            end
            Formation = DB.GetSeat(ExpUpdateUI.BattleSeatInfo.Id,Level + add_Level)
            upNeedExp = upNeedExp + Formation.UpExp
        until(Exp < upNeedExp)


        if add_Level > 0 then
            GUI.SetVisible(BattleSeat_Up_Text,true)
            GUI.StaticSetText(BattleSeat_Up_Text,"(+"..add_Level.."级)")
        else
            GUI.SetVisible(BattleSeat_Up_Text,false)
        end

        return add_Level
    end

end

-- 选中最大可用按钮点击事件
function ExpUpdateUI.OnChooseUsefulCheckBoxClick()
   local FaceBack = _gt.GetUI("FaceBack") -- 父类
    local ChooseUsefulCheckBox = GUI.GetChild(FaceBack,"ChooseUsefulCheckBox") -- 最大可用复选框
    local isCheck = GUI.CheckBoxGetCheck(ChooseUsefulCheckBox) -- 开关 是否开启
    local ExpPreView = _gt.GetUI("ExpPreView") -- 经验条
    local Exp = _gt.GetUI("Exp") -- 已拥有经验 经验条
    local ExpTxt = _gt.GetUI("ExpTxt") -- 经验条文本

    -- 如果需要的数据不存在
    if not (ExpUpdateUI.Formation_Current_Add_Exp and ExpUpdateUI.FORMATION_HAVE_EXP and ExpUpdateUI.FORMATION_ADD_EXP and ExpUpdateUI.BattleSeatInfo and ExpUpdateUI.FORMATION_HAVE_EXP ) then
        test('ExpUpdateUI.OnChooseUsefulCheckBoxClick 需要的数据不存在')
        return
    end
    -- 升到阵法最大等级所需经验
    local GotoMaxLevelNeedExp = ExpUpdateUI.GotoMaxLevelNeedExp

    -- 获取对象，准备遍历所有材料
    if ExpUpdateUI.MaterialInfo == nil or #ExpUpdateUI.MaterialInfo < 1 then
        test("ExpUpdateUI页面 选中最大可用按钮点击事件 材料数据为空")
        return
    end

    local MaxNum = #ExpUpdateUI.MaterialInfo -- 所有材料的格数

    local isMaxLevel = ExpUpdateUI.BattleSeatInfo.Level == MAX_LEVEL + 1
    if isMaxLevel then -- 如果当前阵法等级达到最大级时，显示全部不选
        isCheck = false
    end


    -- 计算是否多出经验
    if isCheck then -- 如果选中，使用最大材料数量
        -- 先使用为最大状态，显示所有减少按钮
        for i=1, MaxNum do
            local _Item = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll/Item"..i)
            --减少按钮
            local _DecBtn = GUI.GetChild(_Item,"DecBtn"..i)
            --数量
            local _Num = GUI.GetChild(_Item,"Num"..i)

            if _DecBtn ~= nil then
                GUI.SetVisible(_DecBtn,true) -- 显示所有减少按钮
            end

            if _Num ~= nil then -- 显示最大选中数量
                ExpUpdateUI.MaterialInfo[i][5] = ExpUpdateUI.MaterialInfo[i][3] -- 使用全部材料
                GUI.StaticSetText(_Num,(ExpUpdateUI.MaterialInfo[i][5].."/"..ExpUpdateUI.MaterialInfo[i][3]) )
            end
        end
        ExpUpdateUI.Formation_Current_Add_Exp = ExpUpdateUI.FORMATION_ADD_EXP
        -- 显示经验条
        if ExpPreView ~= nil then
            if ExpUpdateUI.Formation_UP_Exp ~= 0 then
                GUI.ScrollBarSetPos(ExpPreView,(ExpUpdateUI.FORMATION_ADD_EXP + ExpUpdateUI.FORMATION_HAVE_EXP ) / ExpUpdateUI.Formation_UP_Exp)
            else
                test("ExpUpdateUI.OnChooseUsefulCheckBoxClick 除零错误")
            end
        end
        -- 显示经验文本
        if ExpTxt ~= nil then
            GUI.StaticSetText(ExpTxt,ExpUpdateUI.FORMATION_HAVE_EXP.."( +"..ExpUpdateUI.Formation_Current_Add_Exp..") /"..ExpUpdateUI.Formation_UP_Exp)
            ExpUpdateUI.Formation_Up_Level() -- 更新+多少级字体
        end

        -- 如果所有经验值 不大于 最大等级经验值
        if (ExpUpdateUI.FORMATION_ADD_EXP + ExpUpdateUI.FORMATION_HAVE_EXP ) <= GotoMaxLevelNeedExp then
            -- 已是最大状态
            return

        else -- 如果经验溢出

            -- 经验多出的值
            local overflow =  (ExpUpdateUI.FORMATION_ADD_EXP + ExpUpdateUI.FORMATION_HAVE_EXP ) - GotoMaxLevelNeedExp

            -- 减少部分使用量
            for i=MaxNum,1,-1 do
                local _Item = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll/Item"..i)
                --减少按钮
                local _DecBtn = GUI.GetChild(_Item,"DecBtn"..i)
                --数量
                local _Num = GUI.GetChild(_Item,"Num"..i)

                -- 如果一个格子内的材料大于经验的差值
                if ExpUpdateUI.MaterialInfo[i][3] * ExpUpdateUI.MaterialInfo[i][4] > overflow then

                    local count = math.floor(overflow / ExpUpdateUI.MaterialInfo[i][4]) -- 计算出能剩下来的数量
                    ExpUpdateUI.MaterialInfo[i][5] =  ExpUpdateUI.MaterialInfo[i][3] - count -- 使用数量 = 所有数量 - 可剩下的数量
                    ExpUpdateUI.Formation_Current_Add_Exp = ExpUpdateUI.Formation_Current_Add_Exp - ExpUpdateUI.MaterialInfo[i][4] * (  count) -- 更新当前使用材料增加的阵法经验

                    -- 显示使用数量
                    if _Num then
                        GUI.StaticSetText(_Num,(ExpUpdateUI.MaterialInfo[i][5].."/"..ExpUpdateUI.MaterialInfo[i][3]) )
                    end
                    -- 显示经验条
                    if ExpPreView ~= nil then
                        GUI.ScrollBarSetPos(ExpPreView,(ExpUpdateUI.Formation_Current_Add_Exp + ExpUpdateUI.FORMATION_HAVE_EXP ) / ExpUpdateUI.Formation_UP_Exp)
                    end
                    -- 显示经验文本
                    if ExpTxt ~= nil then
                        GUI.StaticSetText(ExpTxt,ExpUpdateUI.FORMATION_HAVE_EXP.."( +"..ExpUpdateUI.Formation_Current_Add_Exp..") /"..ExpUpdateUI.Formation_UP_Exp)
                        ExpUpdateUI.Formation_Up_Level() -- 更新+多少级字体
                    end

                    break
                else
                    ExpUpdateUI.MaterialInfo[i][5] = 0 -- 本格将全部不使用
                    overflow = overflow - ExpUpdateUI.MaterialInfo[i][3] * ExpUpdateUI.MaterialInfo[i][4] -- 溢出经验 = 溢出经验 - 材料数量*单个材料经验
                    ExpUpdateUI.Formation_Current_Add_Exp = ExpUpdateUI.Formation_Current_Add_Exp - ExpUpdateUI.MaterialInfo[i][3] * ExpUpdateUI.MaterialInfo[i][4] -- 更新当前使用材料所增加的经验值
                    GUI.SetVisible(_DecBtn,false) -- 将减少按钮隐藏

                    -- 显示使用数量
                    if _Num then
                        GUI.StaticSetText(_Num,(ExpUpdateUI.MaterialInfo[i][5].."/"..ExpUpdateUI.MaterialInfo[i][3]) )
                    end

                end
            end
        end
    else -- 如果没选中 取消所有使用
        for i=1, MaxNum do
            local _Item = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll/Item"..i)
            --减少按钮
            local _DecBtn = GUI.GetChild(_Item,"DecBtn"..i)
            --数量
            local _Num = GUI.GetChild(_Item,"Num"..i)

            if _DecBtn ~= nil then
                GUI.SetVisible(_DecBtn,false) -- 不显示所有减少按钮
            end

            if _Num ~= nil then
                ExpUpdateUI.MaterialInfo[i][5] = 0 -- 全部不使用
                GUI.StaticSetText(_Num,(ExpUpdateUI.MaterialInfo[i][5].."/"..ExpUpdateUI.MaterialInfo[i][3]) )
            end
        end
        ExpUpdateUI.Formation_Current_Add_Exp = 0
        -- 显示经验条
        if ExpPreView ~= nil then
            if isMaxLevel then
                GUI.ScrollBarSetPos(Exp,1)
            else
                GUI.ScrollBarSetPos(ExpPreView,(ExpUpdateUI.Formation_Current_Add_Exp + ExpUpdateUI.FORMATION_HAVE_EXP ) / ExpUpdateUI.Formation_UP_Exp)
            end
        end
        -- 显示经验文本
        if ExpTxt ~= nil then
            if isMaxLevel then
                GUI.StaticSetText(ExpTxt,"Max")
            else
                GUI.StaticSetText(ExpTxt,ExpUpdateUI.FORMATION_HAVE_EXP.." /"..ExpUpdateUI.Formation_UP_Exp)
            end
            ExpUpdateUI.Formation_Up_Level() -- 更新+多少级字体
        end

    end
end
-- 使用按钮点击事件
function ExpUpdateUI.OnUseBtn()
    -- 如果当前阵法等级达到最大级
    if ExpUpdateUI.BattleSeatInfo ~= nil and ExpUpdateUI.BattleSeatInfo.Level == MAX_LEVEL + 1 then
        GlobalUtils.ShowBoxMsg1Btn("提示","已是最大等级","ExpUpdateUI","确定")
        return
    end
    -- 如果需要的数据不存在
    if ExpUpdateUI.MaterialInfo == nil and ExpUpdateUI.BattleSeatInfo == nil then
        test('ExpUpdateUI.OnUseBtn 函数出错 需要的数据不存在 ')
        return
    end
    -- 拼接字符串向服务器发送
    local require  = ""
    for i=1,#ExpUpdateUI.MaterialInfo do
        local keyName = DB.GetOnceItemByKey1(ExpUpdateUI.MaterialInfo[i][7]).KeyName
        require = require .. keyName.."_"..ExpUpdateUI.MaterialInfo[i][5].."_" -- 阵法Id_
    end
    -- CDebug.LogError(require)
    -- 向服务器发送请求
    if require ~= "" then
        CL.SendNotify(NOTIFY.SubmitForm,"FormSeat","AddSeatScore",ExpUpdateUI.BattleSeatInfo.Id,require)
        -- 重设ExpUpdateUI.BattleSeatInfo数据
        -- 执行刷新页面方法ExpUpdateUI.RefreshAllPage()
        -- 执行BattleSeatUI.GetServerData()刷新前面的阵法页面
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,'请先选择材料')
    end
end

-- 使用按钮点击后，页面刷新函数
function ExpUpdateUI.RefreshAllPage()
    -- 服务器端更新battleSeatInfo 数据
    if ExpUpdateUI.MaterialInfo == nil and ExpUpdateUI.PreSelectedElementIndex == nil then
        test("ExpUpdateUI界面 使用按钮点击后，页面刷新函数 传入参数为空")
        return
    end
    -- 将阵法框隐藏
    local Clean_BoxElement = function (BoxElement,i)
        --图标
        local _Icon = GUI.GetChild(BoxElement,tostring(i))
        GUI.SetVisible(_Icon,false)
        --数量
        local _Num = GUI.GetChild(BoxElement,"Num"..i)
        GUI.SetVisible(_Num,false)
        --减少按钮
        local _DecBtn = GUI.GetChild(BoxElement,"DecBtn"..i)
        GUI.SetVisible(_DecBtn,false)
    end

    for i=1,#ExpUpdateUI.MaterialInfo do
        local _Item = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll/Item"..i)
        --if i > 18 then
        --    GUI.SetVisible(_Item,false)
        --end
        Clean_BoxElement(_Item,i)
        -- 隐藏选中框
        local _SeatScroll = GUI.Get("ExpUpdateUI/panelBg/ItemLstBack/SeatScroll")
        if ExpUpdateUI.PreSelectedElementIndex ~= nil then
            local Pre_Item = GUI.GetChild(_SeatScroll,"Item"..ExpUpdateUI.PreSelectedElementIndex)
            local Pre_SelectFlag = GUI.GetChild(Pre_Item,"SelectFlag")
            GUI.SetVisible(Pre_SelectFlag,false)
        end
    end
    -- 刷新整个页面
    ExpUpdateUI.Get_Formation_UpMaterialID()

end
-------------------------------------下部分结束-------------------------------------------
-- 关闭窗口
function ExpUpdateUI.OnExit()
    local _Wnd = GUI.GetWnd("ExpUpdateUI")
    if _Wnd ~= nil then
        GUI.DestroyWnd("ExpUpdateUI")
    end
    CL.UnRegisterMessage(GM.RefreshBag,'ExpUpdateUI','Get_Formation_UpMaterialID')
end

-- 销毁窗口
function ExpUpdateUI.OnDestroy()
    -- 最大格子数量
    ExpUpdateUI._max_ceil_count = nil
end