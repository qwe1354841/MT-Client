-- 自定义boss挑战界面
local CustomBossUI = {}
_G.CustomBossUI = CustomBossUI
local _gt = UILayout.NewGUIDUtilTable()
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot

-- 可以写成其他名字，不局限于挑战boss
local uiName = "挑战Boss"

-- 建议此配置表放入到服务器端,通过表单获取
-- 默认选中第一个，未添加指定哪一个功能
-- 发送挑战boss表单后注意关闭界面
-- name(boos名称 建议四个汉字以内),image(boss 背景图片),故事名称，故事内容，奖励名称，奖励表，攻打boss点击请求文件名称，攻打boss点击请求方法
CustomBossUI.needData = {{
    name = "深入浅出",
    level = 10,
    image = "",
    storyName = "背景故事",
    storyContent = "多种草，才能骑更多的马",
    awardName = "boss奖励",
    awardList = {59110, 59111, 59112, 59113, 59114},
    btnName = "挑战boss",
    formFileName = "",
    formMethod = "",
    model_id = 5987,
    model_color = 0,
    model_effect = "2244"
}, {
    name = "有球必应",
    level = 20,
    image = "",
    storyName = "背景故事",
    storyContent = "多种草，才能骑更多的马",
    awardName = "boss奖励",
    awardList = {59110, 59111, 59112},
    btnName = "挑战boss",
    formFileName = "",
    formMethod = "",
    model_id = 5987,
    model_color = 8361,
    model_effect = "2244"
}, {
    name = "日理万机",
    level = 30,
    image = "",
    storyName = "背景故事",
    storyContent = "多种草，才能骑更多的马",
    awardName = "boss奖励",
    awardList = {59110, 59111},
    btnName = "挑战boss",
    formFileName = "",
    formMethod = "",
    model_id = 5987,
    model_color = 7034,
    model_effect = "2244"
}}

function CustomBossUI.Main()
    local wnd = GUI.WndCreateWnd("CustomBossUI", "CustomBossUI", 0, 0, eCanvasGroup.Normal_Extend);
    SetAnchorAndPivot(wnd, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, uiName, "CustomBossUI", "OnExit")
    _gt.BindName(panelBg, "panelBg")
end

CustomBossUI.isFirstOpen = true
function CustomBossUI.OnExit()
    GUI.Destroy(GUI.GetWnd("CustomBossUI"))
    CustomBossUI.isFirstOpen = true
    CustomBossUI.currentSelectIndex = nil
end

function CustomBossUI.OnShow(param)
    local bg = _gt.GetUI("panelBg")

    -- 背景图片
    local ScrollBg = GUI.ImageCreate(bg, "ScrollBg", "1800400200", 85, 55, false, 1025, 380)
    SetAnchorAndPivot(ScrollBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 创建模型
    -- 宠物阴影
    local modelBg = GUI.ImageCreate(ScrollBg, "modelBg", "1801720130", 700, 40, false, 300, 310);
    local shadow = GUI.ImageCreate(modelBg, "shadow", "1800300010", 20, 220);
    -- GUI.SetVisible(shadow,false)

    ----宠物模型
    local model = GUI.RawImageCreate(modelBg, false, "model", "", -30, -10, 50, false, 360, 360)
    -- _gt.BindName(model, "model")
    model:RegisterEvent(UCE.Drag)
    GUI.AddToCamera(model);
    GUI.RawImageSetCameraConfig(model,
        "(1.65,1.3,2),(-0.04464257,0.9316535,-0.1226545,-0.3390941),True,5,0.01,1.25,1E-05");
    model:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(model, UCE.PointerClick, "CustomBossUI", "OnModelClick")
    local BossModel = GUI.RawImageChildCreate(model, true, "BossModel", "", 0, 0)
    _gt.BindName(BossModel, "BossModel");
    GUI.BindPrefabWithChild(model, GUI.GetGuid(BossModel))
    GUI.RegisterUIEvent(BossModel, ULE.AnimationCallBack, "CustomBossUI", "OnAnimationCallBack")

    -- 创建下部分的界面
    local pageName = "自定义boss"
    local secretAreaPage = GUI.GroupCreate(bg, pageName, 0, 0, 1197, 635)
    _gt.BindName(secretAreaPage, pageName)
    CustomBossUI.CreateLevelDetails()

    -- 循环列表
    local childVectorSize = Vector2.New(210, 380)
    local ScrollList = GUI.LoopScrollRectCreate(ScrollBg, "ScrollList", 0, 0, 650, 380, "CustomBossUI",
        "CreateLevelScrollList", "CustomBossUI", "RefreshLevelScrollList", 0, true, childVectorSize, 0,
        UIAroundPivot.TopLeft, UIAnchor.TopLeft)
    _gt.BindName(ScrollList, "ScrollList")
    GUI.SetInertia(ScrollList, false)
    ScrollList:RegisterEvent(UCE.PointerClick)
    ScrollList:RegisterEvent(UCE.EndDrag)
    GUI.RegisterUIEvent(ScrollList, UCE.EndDrag, "CustomBossUI", "OnTabBtnDrag")
    GUI.ScrollRectSetChildSpacing(ScrollList, Vector2.New(10, 0))
    GUI.LoopScrollRectSetTotalCount(ScrollList, #CustomBossUI.needData)
    GUI.LoopScrollRectRefreshCells(ScrollList)

    local RightTag = GUI.ImageCreate(ScrollList, "RightTag", "1801507230", 685, 210, false, 40, 40)
    _gt.BindName(RightTag, "RightTag")
    UILayout.SetSameAnchorAndPivot(RightTag, UILayout.TopLeft)
    GUI.SetEulerAngles(RightTag, Vector3.New(0, 0, -180))
    GUI.SetVisible(RightTag, #CustomBossUI.needData > 3)
end

-- 页签滚动事件
function CustomBossUI.OnTabBtnDrag(guid)
    local RightTag = _gt.GetUI("RightTag")
    local TabScroll = GUI.GetByGuid(guid)
    local x, y = GUI.GetNormalizedPosition(TabScroll):Get()
    local list = #CustomBossUI.needData

    if RightTag then
        GUI.SetVisible(RightTag, list > 3)
    end

    test(x)
    if x == 0 then
        GUI.SetVisible(RightTag, false)
    end
end

function CustomBossUI.OnModelClick() -- 模型刷新

    if not CustomBossUI.currentSelectIndex then
        return;
    end

    local BossModel = GUI.GetByGuid(_gt.BossModel);
    math.randomseed(os.time())
    local index = math.random(2)
    local movements = {eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1}

    local data = CustomBossUI.needData[CustomBossUI.currentSelectIndex]
    ModelItem.Bind(BossModel, data.model_id, data.model_color, 0, movements[index])
end

function CustomBossUI.OnAnimationCallBack(guid, action) -- 宠物模型点击反馈
    if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
        return
    end
    if not CustomBossUI.currentSelectIndex then
        return
    end
    local BossModel = GUI.GetByGuid(_gt.BossModel);
    local data = CustomBossUI.needData[CustomBossUI.currentSelectIndex]
    ModelItem.Bind(BossModel, data.model_id, data.model_color, 0, eRoleMovement.ATTSTAND_W1)

end

-- 循环列表的创建
function CustomBossUI.CreateLevelScrollList()
    local ScrollList = _gt.GetUI("ScrollList")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(ScrollList)
    -- 关卡背景
    local levelBg = GUI.ImageCreate(ScrollList, "levelBg" .. curCount, "1800600270", 0, 0, false, 210, 350)
    GUI.SetIsRaycastTarget(levelBg, true)
    levelBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(levelBg, UCE.PointerClick, "CustomBossUI", "OnLevelClick")
    -- 选中时的高亮外框
    local selectBg = GUI.ImageCreate(levelBg, "selectBg", "1800600290", 0, 0, false, 210, 380)
    GUI.SetVisible(selectBg, false)
    -- 关卡名字背景
    local titleBg = GUI.ImageCreate(levelBg, "titleBg", "1800600260", 15, 20)
    local title = GUI.CreateStatic(titleBg, "title", "傲来秘境", 0, -30, 30, 125)
    local hardText = GUI.CreateStatic(levelBg, "hardText", "困难", -15, 0, 30, 125)
    GUI.StaticSetFontSize(title, UIDefine.FontSizeL)
    GUI.StaticSetFontSize(hardText, UIDefine.FontSizeL)
    GUI.SetColor(hardText, UIDefine.BrownColor)
    GUI.SetVisible(hardText, false)
    SetAnchorAndPivot(titleBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    SetAnchorAndPivot(title, UIAnchor.Center, UIAroundPivot.Center)
    SetAnchorAndPivot(hardText, UIAnchor.TopRight, UIAroundPivot.TopRight)

    -- 关卡需求等级
    local LevelRequirementsBg = GUI.ImageCreate(levelBg, "LevelRequirementsBg", "1800600280", 0, -22)
    local LevelRequirementsText = GUI.CreateStatic(LevelRequirementsBg, "LevelRequirementsText",
        "等级" .. curCount .. "0", 0, 0, 100, 50)
    SetAnchorAndPivot(LevelRequirementsBg, UIAnchor.Bottom, UIAroundPivot.Bottom)
    SetAnchorAndPivot(LevelRequirementsText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(LevelRequirementsText, UIDefine.FontSizeS)
    GUI.SetColor(LevelRequirementsText, UIDefine.BrownColor)
    GUI.StaticSetAlignment(LevelRequirementsText, TextAnchor.MiddleCenter)

    return levelBg
end
-- 循环列表的刷新
function CustomBossUI.RefreshLevelScrollList(parameter)

    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1

    local data = CustomBossUI.needData[index]

    if data == nil then
        test("CustomBossUI.RefreshLevelScrollList(parameter) data数据不存在")
        return
    end

    local levelBg = GUI.GetByGuid(guid)

    local selectBg = GUI.GetChild(levelBg, "selectBg")
    local titleBg = GUI.GetChild(levelBg, "titleBg")
    local title = GUI.GetChild(titleBg, "title")
    -- local hardText=GUI.GetChild(levelBg,"hardText")
    local LevelRequirementsBg = GUI.GetChild(levelBg, "LevelRequirementsBg")
    local LevelRequirementsText = GUI.GetChild(LevelRequirementsBg, "LevelRequirementsText")

    local levelName = data.name
    GUI.StaticSetText(title, levelName)

    -- 是否显示困难字体
    -- if false then
    --     GUI.SetVisible(hardText,true)
    -- else
    --     GUI.SetVisible(hardText,false)
    -- end

    GUI.StaticSetText(LevelRequirementsText, "等级" .. data.level)

    if CustomBossUI.currentSelectIndex == index then
        GUI.SetVisible(selectBg, true)
    else
        GUI.SetVisible(selectBg, false)
    end

    if data.image and data.image ~= '' then
        GUI.ImageSetImageID(levelBg, data.image)
    end

    if index == 1 and CustomBossUI.isFirstOpen then
        GUI.SetVisible(selectBg, true)
        CustomBossUI.OnLevelClick(guid)
        CustomBossUI.isFirstOpen = nil
    end

end

-- 创建关卡的详细信息及说明  界面的下半部分
function CustomBossUI.CreateLevelDetails()
    local curPage = _gt.GetUI("自定义boss")
    -- 背景故事
    local backgroundStoryGroup = GUI.GroupCreate(curPage, "backgroundStoryGroup", 20, 145, 420, 300)
    local backgroundStoryBg = GUI.ImageCreate(backgroundStoryGroup, "backgroundStoryBg", "1801100040", 0, 0)
    local backgroundStoryText = GUI.CreateStatic(backgroundStoryBg, "backgroundStoryText", "背景故事", 10, 0, 100,
        70)
    local backgroundStoryInfo = GUI.CreateStatic(backgroundStoryGroup, "backgroundStoryInfo",
        "女人影响你拔剑的速度，但是富婆能给你买更好的剑", 65, 90, 420, 150)
    _gt.BindName(backgroundStoryText, "backgroundStoryText")
    _gt.BindName(backgroundStoryInfo, "backgroundStoryInfo")
    SetAnchorAndPivot(backgroundStoryGroup, UIAnchor.Left, UIAroundPivot.Left)
    SetAnchorAndPivot(backgroundStoryText, UIAnchor.Left, UIAroundPivot.Left)
    SetAnchorAndPivot(backgroundStoryInfo, UIAnchor.Left, UIAroundPivot.Left)
    GUI.StaticSetFontSize(backgroundStoryText, UIDefine.FontSizeM)
    GUI.StaticSetFontSize(backgroundStoryInfo, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(backgroundStoryInfo, TextAnchor.UpperLeft)
    GUI.SetColor(backgroundStoryInfo, UIDefine.BrownColor)

    local tmpStr = "Boss"

    -- 副本奖励
    local rewardGroup = GUI.GroupCreate(curPage, "rewardGroup", 110, 145, 200, 200)
    local rewardBg = GUI.ImageCreate(rewardGroup, "rewardBg", "1801100040", 0, 0)
    local rewardText = GUI.CreateStatic(rewardBg, "rewardText", tmpStr .. "奖励", 10, 0, 100, 50)
    SetAnchorAndPivot(rewardText, UIAnchor.Left, UIAroundPivot.Left)
    GUI.StaticSetFontSize(rewardText, UIDefine.FontSizeM)
    _gt.BindName(rewardGroup, "rewardGroup")
    -- InstanceUI.CreateRewardItem()

    -- if tmpStr == "副本" then
    -- 	local RemainTimes = GUI.CreateStatic(curPage, "RemainTimes", "今日剩余次数：1次", 20, -95, 300, 40)
    -- 	SetAnchorAndPivot(RemainTimes, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    -- 	GUI.StaticSetFontSize(RemainTimes,UIDefine.FontSizeM)
    -- 	GUI.SetColor(RemainTimes, UIDefine.BrownColor)
    -- 	_gt.BindName(RemainTimes,"RemainTimes")
    -- end

    -- 入口按钮
    local entranceBtn = GUI.ButtonCreate(curPage, "entranceBtn", "1800102090", -90, -35, Transition.ColorTint,
        "<color=#ffffff><size=26>挑战" .. tmpStr .. "</size></color>", 160, 50, false);
    SetAnchorAndPivot(entranceBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetIsOutLine(entranceBtn, true);
    GUI.SetOutLine_Color(entranceBtn, Color.New(162 / 255, 75 / 255, 21 / 255));
    GUI.SetOutLine_Distance(entranceBtn, 1);
    GUI.RegisterUIEvent(entranceBtn, UCE.PointerClick, "CustomBossUI", "OnEntranceBtnClick")
    _gt.BindName(entranceBtn, "entranceBtn")
end

function CustomBossUI.refreshLevelDetails()
    if CustomBossUI.currentSelectIndex == nil then
        test("CustomBossUI.refreshLevelDetails() 未选中boos")
        return
    end
    local data = CustomBossUI.needData[CustomBossUI.currentSelectIndex]
    if data == nil then
        test("CustomBossUI.refreshLevelDetails() data 数据不存在")
        return
    end

    local backgroundStoryInfo = _gt.GetUI("backgroundStoryInfo")
    GUI.StaticSetText(backgroundStoryInfo, "  " .. data.storyContent)

    local backgroundStoryText = _gt.GetUI("backgroundStoryText")
    GUI.StaticSetText(backgroundStoryText, data.storyName)

    local rewardGroup = _gt.GetUI("rewardGroup")
    local rewardText = GUI.GetChild(rewardGroup, "rewardText")
    GUI.StaticSetText(rewardText, data.awardName)

    local entranceBtn = _gt.GetUI("entranceBtn")
    GUI.ButtonSetText(entranceBtn, "<color=#ffffff><size=26>" .. data.btnName .. "</size></color>")
end

-- 最大次数的物品框数量
CustomBossUI.preItemBoxCount = nil
-- 创建以及刷新奖励物品
function CustomBossUI.CreateAndRefreshRewardItem()
    if CustomBossUI.currentSelectIndex == nil then
        test("CustomBossUI.CreateAndRefreshRewardItem(pageName)  未选中boss")
        return
    end

    local curPage = _gt.GetUI("自定义boss")
    local rewardGroup = GUI.GetChild(curPage, "rewardGroup")
    if not rewardGroup then
        return
    end

    local data = CustomBossUI.needData[CustomBossUI.currentSelectIndex]
    if data == nil then
        test("CustomBossUI.CreateAndRefreshRewardItem(pageName) data 数据不存在")
        return
    end
    -- 创建
    local CurSelectLevelRewardCount = CustomBossUI.preItemBoxCount or #data.awardList or 0

    for i = 1, CurSelectLevelRewardCount do
        local rewardItem = GUI.GetChild(rewardGroup, "rewardItem" .. i)
        if rewardItem == nil then
            rewardItem = ItemIcon.Create(rewardGroup, "rewardItem" .. i, -190 + i * 85, 65, 0, 0)
            GUI.RegisterUIEvent(rewardItem, UCE.PointerClick, "CustomBossUI", "OnItemClick");
        else
            GUI.SetVisible(rewardItem, true)
        end
    end
    -- 刷新   赋值
    local rewardList = data.awardList
    for i = 1, #rewardList do
        local rewardItem = GUI.GetChild(rewardGroup, "rewardItem" .. i)
        local itemDB = DB.GetOnceItemByKey1(rewardList[i])
        if itemDB then
            ItemIcon.BindItemDB(rewardItem, itemDB)
            GUI.SetData(rewardItem, "ItemId", itemDB.Id)
        end
    end
    -- 将一些剩余的对象进行不可视
    if #rewardList < CurSelectLevelRewardCount then
        for i = #rewardList + 1, CurSelectLevelRewardCount do
            local rewardItem = GUI.GetChild(rewardGroup, "rewardItem" .. i)
            GUI.SetVisible(rewardItem, false)
        end
    end

    CustomBossUI.preItemBoxCount = #rewardList > CurSelectLevelRewardCount and #rewardList or CurSelectLevelRewardCount
end

-- 当前选中boss的下标
CustomBossUI.currentSelectIndex = nil
CustomBossUI.CurModelEffectID = nil
function CustomBossUI.OnLevelClick(guid)
    local btn = GUI.GetByGuid(guid)
    local indexData = GUI.ImageGetIndex(btn) + 1
    indexData = tonumber(indexData)
    -- 防止重复点击
    if indexData == CustomBossUI.currentSelectIndex then
        return
    end
    CustomBossUI.currentSelectIndex = (indexData)

    local data = CustomBossUI.needData[indexData]
    if data == nil then
        test("CustomBossUI.OnLevelClick(guid)  data 数据不存在")
        return
    end

    local curPage = _gt.GetUI("panelBg")
    local ScrollBg = GUI.GetChild(curPage, "ScrollBg")
    -- 关卡列表
    local ScrollList = GUI.GetChild(ScrollBg, "ScrollList")

    GUI.LoopScrollRectSetTotalCount(ScrollList, #CustomBossUI.needData)
    GUI.LoopScrollRectRefreshCells(ScrollList)

    local RightTag = _gt.GetUI("RightTag")
    if RightTag then
        GUI.SetVisible(RightTag, #CustomBossUI.needData > 3)
    end

    CustomBossUI.refreshLevelDetails()

    -- 创建奖励的方法
    CustomBossUI.CreateAndRefreshRewardItem()
    -- GUI.LoopScrollRectSrollToCell(ScrollList,indexData-1,2000)

    -- 模型显示
    local BossModel = _gt.GetUI("BossModel")
    ModelItem.Bind(BossModel, data.model_id, data.model_color, 0, eRoleMovement.ATTSTAND_W1)
    -- 特效
    if CustomBossUI.CurModelEffectID then
        GUI.DestroyRoleEffect(BossModel, CustomBossUI.CurModelEffectID)
    end
    if data.model_effect and data.model_effect ~= "" then
        local effectID = GUI.CreateRoleEffect(BossModel, TOOLKIT.Str2uLong(data.model_effect))
        CustomBossUI.CurModelEffectID = effectID
    end
end

-- 开始boss战点击事件
function CustomBossUI.OnEntranceBtnClick(guid)
    if CustomBossUI.currentSelectIndex == nil then
        test("CustomBossUI.OnEntranceBtnClick(guid) 未选中boss")
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中Boss")
        return
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormGonggong", "BossGetData", CustomBossUI.currentSelectIndex)
end

function CustomBossUI.OnItemClick(guid)
    local panelBg = _gt.GetUI("panelBg")
    local rewardItem = GUI.GetByGuid(guid)
    local ItemId = GUI.GetData(rewardItem, "ItemId")
    Tips.CreateByItemId(ItemId, panelBg, "ItemTips", -250, 100)
end
