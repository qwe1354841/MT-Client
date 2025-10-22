local FunctionPreviewUI = {}
_G.FunctionPreviewUI = FunctionPreviewUI
local _gt = nil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
------------------------------------------Start Test Start----------------------------------
local test  = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------
FunctionPreviewUI.ConfigList = nil
FunctionPreviewUI.CurrentIndex = 1
FunctionPreviewUI.ItemData = {}
local _gt = UILayout.NewGUIDUtilTable()
local QualityRes =
{
    "1800400330","1800400100","1800400110","1800400120","1800400320"
}

local colorDark = UIDefine.BrownColor --Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorWhite = UIDefine.WhiteColor --Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorOutline = UIDefine.Orange2Color --Color.New(162 / 255, 75 / 255, 21 / 255)
local tipColor = Color.New(208 / 255, 140 / 255, 15 / 255, 255 / 255)
local contentColor = UIDefine.BrownColor --Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorRed = UIDefine.RedColor --Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255)
local colorGreen = Color.New(12 / 255, 161 / 255, 76 / 255, 255 / 255)
local importantInfoColor = Color.New(255 / 255, 242 / 255, 208 / 255, 255 / 255) -- Color HexNumber: fff2d0ff ，基础属性&基础信息
local MAX_ITEM_NUM = 3
local itemPositionXList = {
    { 170 },
    { 120, 220 },
    { 75, 170, 265 },
    { -180, -60, 60, 180 },
}

function FunctionPreviewUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("FunctionPreviewUI", "FunctionPreviewUI", 0, 0)

    -- 底图
    local panelBg = UILayout.CreateFrame_WndStyle2(wnd, "功能预告", 350,460,"FunctionPreviewUI", "OnExit", _gt)
    SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(panelBg, "panelBg")


    -- 向左
    local leftBtn = GUI.ButtonCreate(panelBg, "LeftBtn", "1800602190", -230, -6, Transition.ColorTint)
    _gt.BindName(leftBtn, "LeftBtn")
    SetAnchorAndPivot(leftBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(leftBtn, UCE.PointerClick, "FunctionPreviewUI", "OnClickLeft")

    -- 向右
    local rightBtn = GUI.ButtonCreate(panelBg, "RightBtn", "1800602120", 230, -6, Transition.ColorTint)
    _gt.BindName(rightBtn, "RightBtn")
    SetAnchorAndPivot(rightBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(rightBtn, UCE.PointerClick, "FunctionPreviewUI", "OnClickRight")

    local ShowGroup = GUI.GroupCreate(panelBg,"ShowGroup",0,0)
    SetAnchorAndPivot(ShowGroup, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local VanishGroup = GUI.GroupCreate(panelBg,"VanishGroup",0,0)
    SetAnchorAndPivot(ShowGroup, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(VanishGroup,false)

    local pnSellout = GUI.ImageCreate(VanishGroup, "pnSellout", "1801100010", 0, 0, false, 250, 80)
    SetAnchorAndPivot(pnSellout, UIAnchor.Center, UIAroundPivot.Center)

    local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "物品已全部领取", 0, 0, 200, 50, "system", true)
    SetAnchorAndPivot(txtSellout, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtSellout, 24)
    GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
    GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleCenter)

    -- 功能名称（原先是：开启等级）
    local levelTip = GUI.CreateStatic(ShowGroup, "LevelTip", "[功能名称]", 30, 55, 150, 35)
    SetAnchorAndPivot(levelTip, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(levelTip, 24)
    GUI.SetColor(levelTip, tipColor)

    local level = GUI.CreateStatic(ShowGroup, "Level", "30", 40, 85, 100, 35)
    _gt.BindName(level, "panelLevel")
    SetAnchorAndPivot(level, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(level, 20)
    GUI.SetColor(level, contentColor)

    -- 功能介绍
    local functionTip = GUI.CreateStatic(ShowGroup, "FunctionTip", "[功能介绍]", 30, 115, 150, 35)
    SetAnchorAndPivot(functionTip, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(functionTip, 24)
    GUI.SetColor(functionTip, tipColor)

    local functionText = GUI.CreateStatic(ShowGroup, "Function", "达到10级开启门派心法和技能成长的功能!", 40, 143, 270, 70, "system", false, false)
    _gt.BindName(functionText, "Function")
    SetAnchorAndPivot(functionText, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(functionText, 20)
    GUI.SetColor(functionText, contentColor)

    -- 开启奖励
    local rewardTip = GUI.CreateStatic(ShowGroup, "RewardTip", "[开启奖励]", 30, 205, 150, 35)
    SetAnchorAndPivot(rewardTip, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(rewardTip, 24)
    GUI.SetColor(rewardTip, tipColor)

    for i = 1, MAX_ITEM_NUM do
        local CenterItemIcon = ItemIcon.Create(ShowGroup,"CenterItemIcon"..i,itemPositionXList[MAX_ITEM_NUM][i], 340)
        GUI.ItemCtrlSetElementRect(CenterItemIcon,eItemIconElement.RightBottomNum,8,6,24,24)
        SetAnchorAndPivot(CenterItemIcon, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.RegisterUIEvent(CenterItemIcon, UCE.PointerClick, "FunctionPreviewUI", "OnCenterItemIconClick")
        GUI.SetVisible(CenterItemIcon,false)
    end


    local getTip = GUI.CreateStatic(ShowGroup, "GetTip", "可领取", 170, 380, 200, 35)
    _gt.BindName(getTip, "GetTip")
    SetAnchorAndPivot(getTip, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.StaticSetAlignment(getTip, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(getTip, 20)

    --获取按钮
    local getBtn = GUI.ButtonCreate(ShowGroup, "GetBtn", "1800402080", 170, 430, Transition.ColorTint, "领取", 120, 46, false)
    _gt.BindName(getBtn, "GetBtn")
    SetAnchorAndPivot(getBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ButtonSetTextFontSize(getBtn, 26)
    GUI.ButtonSetTextColor(getBtn, colorWhite)
    GUI.SetIsOutLine(getBtn, true)
    GUI.SetOutLine_Color(getBtn, colorOutline)
    GUI.SetOutLine_Distance(getBtn, 1)
    GUI.RegisterUIEvent(getBtn, UCE.PointerClick, "FunctionPreviewUI", "OnClickGetReward")

end

function FunctionPreviewUI.OnShow()
    local wnd = GUI.GetWnd("FunctionPreviewUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd,true)
    CL.SendNotify(NOTIFY.SubmitForm, "FormGetAward", "GetData")
end

function FunctionPreviewUI.SetPanelIndex()
    if #FunctionPreviewUI.ConfigList > 0 then
        for i = 1, #FunctionPreviewUI.ConfigList do
            if tostring(FunctionPreviewUI.ConfigList[i].Title) == tostring(UIDefine.FunctionPreviewUI_ShowTitle) then
                if FunctionPreviewUI.ConfigList[i].CanTake == 1 then
                    FunctionPreviewUI.RefreshPanel(tonumber(i))
                    break
                else
                    FunctionPreviewUI.RefreshPanel()
                end
            else
                FunctionPreviewUI.RefreshPanel()
            end
        end
    else
        FunctionPreviewUI.RefreshPanel()
    end
end

-- 刷新函数
function FunctionPreviewUI.RefreshUI()
    FunctionPreviewUI.InitConfig()
end

-- 初始化Config数据
function FunctionPreviewUI.InitConfig()

    FunctionPreviewUI.ConfigList = {}
    local ConfigOldList = {}
    for key, config in pairs(GlobalProcessing.SwitchOnAwardData) do
        table.insert(ConfigOldList, config)
    end

    --CanTake 1:可领取 2:已领取 3:不可领取,领取条件不足

    for i = 1, #ConfigOldList do
        if ConfigOldList[i].CanTake ~= 2 then
            table.insert(FunctionPreviewUI.ConfigList, ConfigOldList[i])
        end
    end
    table.sort(FunctionPreviewUI.ConfigList, function(a, b)
        if a.LevelParam[1] ~= b.LevelParam[1] then
            return a.LevelParam[1] < b.LevelParam[1]
        end
        if a.LevelParam[2] ~= b.LevelParam[2] then
            return a.LevelParam[2] < b.LevelParam[2]
        end
        if a.Id ~= b.Id then
            return a.Id < b.Id
        end
        return false
    end)
    local inspect = require("inspect")

    if UIDefine.FunctionPreviewUI_ShowTitle then
        FunctionPreviewUI.SetPanelIndex()
    else
        FunctionPreviewUI.RefreshPanel()
    end
end

function FunctionPreviewUI.GetPreviewState()
    return FunctionPreviewUI.ConfigList and #FunctionPreviewUI.ConfigList > 0
end

-- 刷新功能奖励UI
function FunctionPreviewUI.RefreshPanel(index)
    local panelBg = _gt.GetUI("panelBg")
    local ShowGroup = GUI.GetChild(panelBg,"ShowGroup")
    local VanishGroup = GUI.GetChild(panelBg,"VanishGroup")
    local leftBtn = _gt.GetUI("LeftBtn")
    local rightBtn = _gt.GetUI("RightBtn")
    if not FunctionPreviewUI.ConfigList or #FunctionPreviewUI.ConfigList == 0 then
        GUI.SetVisible(ShowGroup,false)
        GUI.SetVisible(VanishGroup,true)
        GUI.ButtonSetShowDisable(leftBtn, false)
        GUI.ButtonSetShowDisable(rightBtn, false)
        return
    end

    index = index or 1
    if index <= 0 or index > #FunctionPreviewUI.ConfigList then
        return
    end

    FunctionPreviewUI.CurrentIndex = index

    local config = FunctionPreviewUI.ConfigList[index]
    local level = _gt.GetUI("panelLevel")
    if level then
        GUI.StaticSetText(level, config.Title)
    end

    local functionText = _gt.GetUI("Function")
    if functionText then
        GUI.StaticSetText(functionText, config.Desc)
    end

    -- 获取奖励道具(Item.KeyName)
    local rewardList = {}
    local rewardListNum = {}
    for i = 1, #config.ItemList do
        if i % 2 == 0 then
            table.insert(rewardListNum, tostring(config.ItemList[i]))
        else
            table.insert(rewardList, tostring(config.ItemList[i]))
        end
    end


    -- 刷新奖励UI
    for i = 1, 3 do
        local CenterItemIcon = GUI.GetChild(ShowGroup,"CenterItemIcon"..i)
        if i <= #rewardList then
            local itemDB = DB.GetOnceItemByKey2(rewardList[i])
            GUI.ItemCtrlSetElementValue(CenterItemIcon,eItemIconElement.Icon,tostring(itemDB.Icon))

            GUI.ItemCtrlSetElementValue(CenterItemIcon,eItemIconElement.RightBottomNum,tostring(rewardListNum[i]))
            GUI.ItemCtrlSetElementValue(CenterItemIcon,eItemIconElement.Border,QualityRes[itemDB.Grade]) -- 插入品质背景图片
            GUI.SetPositionX(CenterItemIcon, itemPositionXList[#rewardList][i])
            GUI.SetVisible(CenterItemIcon,true)
            GUI.SetData(CenterItemIcon,"ItemId",itemDB.Id)
        else
            GUI.SetVisible(CenterItemIcon,false)
        end
    end

    -- 是否可领取道具
    -- 转生次数
    local rein = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
    -- 角色等级
    local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)

    local cfgRein = tonumber(config.LevelParam[1])
    local cfgCanTake = tonumber(config.CanTake)
    local cfgLevel =  tonumber(config.LevelParam[2])

    local getTip = _gt.GetUI("GetTip")
    if rein >= cfgRein and roleLevel >= cfgLevel then
        GUI.StaticSetText(getTip, "可领取")
        GUI.SetColor(getTip, colorGreen)
    else
        if cfgRein == 0 then
            GUI.StaticSetText(getTip, string.format("%d级可领取", cfgLevel))
        else
            GUI.StaticSetText(getTip, string.format("%d转%d级可领取", cfgRein, cfgLevel))
        end
        GUI.SetColor(getTip, colorRed)
    end

    -- 左右按钮
    GUI.ButtonSetShowDisable(leftBtn, index > 1)
    GUI.ButtonSetShowDisable(rightBtn, #FunctionPreviewUI.ConfigList > index)

    -- 领取按钮
    local getBtn = _gt.GetUI("GetBtn")
    --根据状态判断是否能领取
    GUI.ButtonSetShowDisable(getBtn, cfgCanTake==1)
end

function FunctionPreviewUI.OnCenterItemIconClick(guid)
    local panelBg = _gt.GetUI("panelBg")
    local element = GUI.GetByGuid(guid)
    local itemId = GUI.GetData(element,"ItemId")
    local Tips = Tips.CreateByItemId(itemId,panelBg,"Tips",370,0)
end

-- 获取按钮点击事件
function FunctionPreviewUI.OnClickGetReward(guid)
    -- 判断当前转生次数与当前人物等级是否符合领取规则
    if FunctionPreviewUI.CurrentIndex == nil then
        return
    end
    local currCfg = FunctionPreviewUI.ConfigList[FunctionPreviewUI.CurrentIndex]

    if not currCfg then
        return
    end

    local rein = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
    local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)

    local cfgRein = currCfg.LevelParam[1]
    local cfgLevel =  currCfg.LevelParam[2]

    if rein < cfgRein or roleLevel < cfgLevel then
        return
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormGetAward", "HaveTake", currCfg.Title)
end

-- 点击领取按钮后的回调函数
function FunctionPreviewUI.OnFormGetAwardsHandle(id)

    if not FunctionPreviewUI.ConfigList then return end

    local index = #FunctionPreviewUI.ConfigList
    for i = index, 1, -1 do
        if FunctionPreviewUI.ConfigList[i].Id == id then
            table.remove(FunctionPreviewUI.ConfigList, i)
            index = i
            break
        end
    end
    index = #FunctionPreviewUI.ConfigList < index and index - 1 or index
    FunctionPreviewUI.RefreshPanel(index)

    if #FunctionPreviewUI.ConfigList <= 0 then
        if MainDynamicUI and MainDynamicUI.RefreshLeftDynamicUIVisible then
            MainDynamicUI.RefreshLeftDynamicUIVisible()
        end
    end
end

-- 左侧按钮(箭头)点击事件
function FunctionPreviewUI.OnClickLeft()
    FunctionPreviewUI.RefreshPanel(FunctionPreviewUI.CurrentIndex - 1)
end

-- 右侧按钮(箭头)点击事件
function FunctionPreviewUI.OnClickRight()
    FunctionPreviewUI.RefreshPanel(FunctionPreviewUI.CurrentIndex + 1)
end


-- 关闭界面
function FunctionPreviewUI.OnExit()
    GUI.CloseWnd("FunctionPreviewUI")
end


