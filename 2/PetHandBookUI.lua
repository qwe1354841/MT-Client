-- 宠物图鉴
PetHandBookUI = {}

PetHandBookUI.PetData = nil

-- 宠物类型(普通 -- 宝宝 -- 变异 -- 仙兽 -- 神兽 -- 魔兽 -- 圣兽 -- 元灵 -- 洪荒)
PetHandBookUI.PetType = {
    { typeName = "普通", iconPath = "1800704040" },
    { typeName = "宝宝", iconPath = "1800704010" },
    { typeName = "变异", iconPath = "1800704030" },
    { typeName = "仙兽", iconPath = "1801304030" },
    { typeName = "神兽", iconPath = "1800704020" },
    { typeName = "魔兽", iconPath = "1801604100" },
    { typeName = "圣兽", iconPath = "1801304040" },
    { typeName = "元灵", iconPath = "1801304050" },
    { typeName = "洪荒", iconPath = "1801304060" },
}

-- 脚本名称常量
local PET_HANDBOOK_UI = "PetHandBookUI"

local _gt = UILayout.NewGUIDUtilTable()
-- 灰色
local DarkColor = Color.New(102/255, 47/255, 22/255, 255/255)
-- 宠物滚动列表行数
local petScrollRow = 3
-- 宠物滚动列表列数
local petScrollCol = 6
-- 技能滚动列表行数
local skillScrollRow = 5
-- 技能滚动grid列数
local skillScrollCol = 2
-- 获取途径按钮数量
local approachCount = 5
-- 当前宠物 itemIcon
local currPetItemIconBgBtn = nil
-- 当前宠物数据
local currPetDB = nil
-- 每个宠物所拥有的最大技能数量
local CntOfSkillsPerPet = 40
-- 当前宠物天生可携带技能Id列表
local currSkillIdList = nil
-- 当前宠物索引
local currPetIndex = 0

-- 宠物图鉴右侧底层资质相关UI文本信息
local talentTxtList = {
    { txt = "血量资质", lowerLimit = 0, upperLimit = 0, spiritName = "TalentHP" },
    { txt = "物攻资质", lowerLimit = 0, upperLimit = 0, spiritName = "TalentPhyAtk" },
    { txt = "物防资质", lowerLimit = 0, upperLimit = 0, spiritName = "TalentPhyDef" },
    { txt = "法攻资质", lowerLimit = 0, upperLimit = 0, spiritName = "TalentMagAtk" },
    { txt = "法防资质", lowerLimit = 0, upperLimit = 0, spiritName = "TalentMagDef" },
    { txt = "速度资质", lowerLimit = 0, upperLimit = 0, spiritName = "TalentSpeed" },
    { txt = "成  长  率", lowerLimit = 0, upperLimit = 0, spiritName = "GrowthRate" },
}

function PetHandBookUI.Main()

    if not PetUI then
        test("PetUI must be not nil")
        return
    end

    if not UIDefine.PetHandbookData then
        test("PetHandbookData must be not nil")
        return
    end

    PetHandBookUI.PetData = UIDefine.PetHandbookData

    -- 创建背景容器
    local panelBg = PetHandBookUI.CreateBackgroundUI()

    -- 创建左侧滑动页面UI
    PetHandBookUI.CreateLeftScrollPageUI(panelBg)

    -- 创建右侧宠物相关信息页面UI
    PetHandBookUI.CreateRightPetInfoPageUI(panelBg)

end

-- 创建背景容器
function PetHandBookUI.CreateBackgroundUI()
    local wnd = GUI.WndCreateWnd(PET_HANDBOOK_UI, PET_HANDBOOK_UI, 0, 0)
    --GUI.CreateSafeArea(wnd)
    GUI.SetVisible(wnd, false)
    UILayout.SetAnchorAndPivot(wnd, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(wnd, "wnd")

    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "宠    物", PET_HANDBOOK_UI, "OnExit", _gt)
    local group = GUI.GetChild(panelBg, "tabList")
    GUI.SetVisible(group, true)
    local intervalSp = GUI.ImageCreate(group, "intervalSp", "1801305010", 0, 0, false, 17, 100)
    UILayout.SetSameAnchorAndPivot(intervalSp, UILayout.Top)

    local bottomBg = GUI.GetChild(group, "bottomBg")
    bottomBg = GUI.ImageCreate(group, "bottomBg", "1801305030", 0, 0)
    UILayout.SetAnchorAndPivot(bottomBg, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetDepth(bottomBg, 0);
    _gt.BindName(panelBg, "panelBg")
    return panelBg
end

-- 创建左侧滑动页面UI
function PetHandBookUI.CreateLeftScrollPageUI(panelBg)

    local leftPetIconGroup = GUI.GroupCreate(panelBg, "leftPetIconGroup", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
    _gt.BindName(leftPetIconGroup, "leftPetIconGroup");

    -- 创建背景
    local itemScrollBg = GUI.ImageCreate(leftPetIconGroup, "itemScrollBg", "1800400200", -353, 8, false, 338, 570)
    UILayout.SetAnchorAndPivot(itemScrollBg, UIAnchor.Center, UIAroundPivot.Center)

    -- 创建标题背景
    local titleBg = GUI.ImageCreate(itemScrollBg, "titleBg", "1800700070", 2, 2, false, 334, 34, false)
    UILayout.SetAnchorAndPivot(titleBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 创建标题文本框
    local titleTxt = GUI.CreateStatic(titleBg, "titleTxt", "全部宠物", 0, 0, 330, 35, "system", true)
    PetHandBookUI.StaticSetTextProperty(titleTxt, UIAnchor.Center, UIAroundPivot.Center)

    -- 创建滑动界面
    local leftItemScroll = GUI.LoopScrollRectCreate(itemScrollBg, "leftItemScroll", 0, 20, 336, 526,
            PET_HANDBOOK_UI, "CreatPetItemIconPool", PET_HANDBOOK_UI, "RefreshPetItemIconScroll", 0,
            false, Vector2.New(100, 98), petScrollRow, UIAroundPivot.Top, UIAnchor.Top)

    GUI.ScrollRectSetChildSpacing(leftItemScroll, Vector2.New(10, 2));

    _gt.BindName(leftItemScroll, "leftItemScroll")
	
	local leftnum = petScrollRow * petScrollCol
	if PetHandBookUI.PetData and #PetHandBookUI.PetData > 0 then
		leftnum = #PetHandBookUI.PetData
	end
    GUI.LoopScrollRectSetTotalCount(leftItemScroll, leftnum)
end

-- 创建右侧宠物相关信息页面UI
function PetHandBookUI.CreateRightPetInfoPageUI(panelBg)

    local rightPetInfoGroup = GUI.GroupCreate(panelBg, "rightPetInfoGroup", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
    _gt.BindName(rightPetInfoGroup, "rightPetInfoGroup")

    -- 创建宠物信息UI
    PetHandBookUI.CreatePetInfoUI(rightPetInfoGroup)
    -- 创建宠物获取途径UI
    PetHandBookUI.CreateApproachUI(rightPetInfoGroup)
    -- 创建下方资质信息UI
    PetHandBookUI.CreateTalentInfoUI(rightPetInfoGroup)

end

-- 创建宠物信息UI
function PetHandBookUI.CreatePetInfoUI(parent)

    local petInfoBgGroup = GUI.GroupCreate(parent, "petInfoBgGroup", 0, 0, GUI.GetWidth(parent), GUI.GetHeight(parent))
    _gt.BindName(petInfoBgGroup, "petInfoBgGroup")

    -- 圆框背景
    local modelBg = GUI.ImageCreate(petInfoBgGroup, "modelBg", "1800700120", -10, -145)
    _gt.BindName(modelBg, "modelBg")

    -- 宠物阴影
    local shadow = GUI.ImageCreate(petInfoBgGroup, "shadow", "1800400240", -10, -60)
    _gt.BindName(shadow, "shadow")

    -- 宠物模型
    local model = GUI.RawImageCreate(petInfoBgGroup, false, "model", "", 0, -145, 50, false, 360, 360)
    _gt.BindName(model, "model");
    model:RegisterEvent(UCE.Drag)
    GUI.AddToCamera(model);
    GUI.RawImageSetCameraConfig(model, "(1.65, 1.3, 2),(-0.04464257, 0.9316535, -0.1226545, -0.3390941), True, 5, 0.01, 1.25, 1E-05");
    model:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(model, UCE.PointerClick, PET_HANDBOOK_UI, "OnModelClick")
    local petModel = GUI.RawImageChildCreate(model, true, "petModel", "", 0, 0)
    _gt.BindName(petModel, "petModel");
    GUI.BindPrefabWithChild(model, GUI.GetGuid(petModel))
    GUI.RegisterUIEvent(petModel, ULE.AnimationCallBack, PET_HANDBOOK_UI, "OnAnimationCallBack")

    -- 创建宠物类型UI
    local petTypeImage = GUI.ImageCreate(petInfoBgGroup, "petTypeImage", "1800704040", 135, -220)
    UILayout.SetAnchorAndPivot(petTypeImage, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(petTypeImage, "petTypeImage")

    -- 创建宠物名称文本UI
    local petNameTxt = GUI.CreateStatic(petInfoBgGroup, "petNameTxt", "", -15, 16, 164, 40)
    PetHandBookUI.StaticSetTextProperty(petNameTxt, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(petNameTxt, "petNameTxt")

    -- 创建参战等级UI
    local levelLabelTxt = GUI.CreateStatic(petInfoBgGroup, "levelLabelTxt", "参战等级", 268, 16, 120, 40)
    PetHandBookUI.StaticSetTextProperty(levelLabelTxt, UIAnchor.Center, UIAroundPivot.Center)

    GUI.ImageCreate(petInfoBgGroup, "levelLabelBg", "1800600040", 412, 16, false, 134, 28)

    local levelTxt = GUI.CreateStatic(petInfoBgGroup, "levelTxt", "", 412, 16, 134, 28)
    PetHandBookUI.StaticSetTextProperty(levelTxt, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(levelTxt, "levelTxt")

    -- 创建饰品ToggleUI
    local showEffectToggle = GUI.CheckBoxExCreate(petInfoBgGroup, "showEffectToggle", "1801202050", "1801202051", 130, -50, false)
    UILayout.SetAnchorAndPivot(showEffectToggle, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(showEffectToggle, UCE.PointerClick, PET_HANDBOOK_UI, "OnShowEffectToggleClick")
    _gt.BindName(showEffectToggle, "showEffectToggle")

end

-- 创建宠物获取途径UI
function PetHandBookUI.CreateApproachUI(parent)
    local petApproachGroup = GUI.GroupCreate(parent, "petApproachGroup", 0, 0, GUI.GetWidth(parent), GUI.GetHeight(parent))
    _gt.BindName(petApproachGroup, "petApproachGroup")

    -- 创建背景UI
    local approachBg = GUI.ImageCreate(petApproachGroup, "approachBg", "1800400200", 368, -140, false, 304, 265)
    UILayout.SetAnchorAndPivot(approachBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(approachBg, "approachBg")

    -- 创建标题背景UI
    local titleBg = GUI.ImageCreate(approachBg, "titleBg", "1800700070", 2, 2, false, 300, 34, false)
    UILayout.SetAnchorAndPivot(titleBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 创建标题文本UI
    local titleTxt = GUI.CreateStatic(approachBg, "titleTxt", "获取途径", 0, 0, 300, 34, "system", true, false)
    PetHandBookUI.StaticSetTextProperty(titleTxt)

    -- 创建获取途径列表UI
    for i = 1, approachCount do
        local btn = GUI.ButtonCreate(approachBg, "approachBtn"..i, "1800402110", 0, 60 + (i - 1) * 45, Transition.ColorTint, "获取途径"..i, 186, 42, false)
        GUI.SetAnchor(btn, UIAnchor.Top)
        GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeM)
        GUI.ButtonSetTextColor(btn, DarkColor)
        GUI.SetData(btn, "index", i)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, PET_HANDBOOK_UI, "OnApproachBtnClick")
        GUI.SetVisible(btn, false)
    end

end

-- 创建下方资质信息UI
function PetHandBookUI.CreateTalentInfoUI(parent)

    local petTalentInfoGroup = GUI.GroupCreate(parent, "petTalentInfoGroup", 0, 0, GUI.GetWidth(parent), GUI.GetHeight(parent))
    _gt.BindName(petTalentInfoGroup, "petTalentInfoGroup")

    -- 创建宠物类型ToggleUI
    local toggleWidth = 170
    local toggleHeight = 43

    local toggleGroup = GUI.GroupCreate(petTalentInfoGroup, "toggleGroup", 0, 0, GUI.GetWidth(petTalentInfoGroup), GUI.GetHeight(petTalentInfoGroup))
    GUI.SetIsToggleGroup(toggleGroup, true)
    _gt.BindName(toggleGroup, "toggleGroup")

    local petInfoBg = GUI.ImageCreate(petTalentInfoGroup, "petInfoBg", "1800400200", 171, 188, false, toggleWidth * 4 + 20, 210)
    _gt.BindName(petInfoBg, "petInfoBg")

    for i = 1, 4 do
        local petTypeToggle = GUI.CheckBoxExCreate(toggleGroup, "petTypeToggle"..i, "1800702010", "1800702011", (i - 1) * toggleWidth - 86, 65, false, toggleWidth, toggleHeight, false)
        UILayout.SetAnchorAndPivot(petTypeToggle, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetToggleGroupGuid(petTypeToggle, GUI.GetGuid(toggleGroup))

        local labelTxt = GUI.CreateStatic(petTypeToggle, "labelTxt", "类型"..i, 0, 3, toggleWidth, toggleHeight, "system", true, false)
        PetHandBookUI.StaticSetTextProperty(labelTxt)

        GUI.RegisterUIEvent(petTypeToggle, UCE.PointerClick, PET_HANDBOOK_UI, "OnPetTypeToggleClick")

        GUI.CheckBoxExSetCheck(petTypeToggle, false)
        GUI.SetVisible(petTypeToggle, false)

        GUI.SetData(petTypeToggle, "index", tonumber(i))

        if i == 1 then
            GUI.CheckBoxExSetCheck(petTypeToggle, true)
        end

        local buttonOfTips = GUI.ButtonCreate(petInfoBg, "buttonOfTips"..i, "1800702030", -6, 8, Transition.ColorTint, "")
        UILayout.SetAnchorAndPivot(buttonOfTips, UIAnchor.TopRight, UIAroundPivot.TopRight)
        GUI.RegisterUIEvent(buttonOfTips, UCE.PointerClick, PET_HANDBOOK_UI, "OnBreakTipsBtnClick")
        GUI.SetVisible(buttonOfTips, false)

        _gt.BindName(buttonOfTips, "buttonOfTips"..i)
    end

    -- 创建底层宠物资质and技能信息UI
    local ttl = talentTxtList
    for i = 1, #ttl do
        local posX = 12
        local posY = 14 + (i - 1) * 27
        local label = GUI.CreateStatic(petInfoBg, ttl[i].spiritName .. "_label", ttl[i].txt, posX, posY, 90, 26, "system", true, false)
        PetHandBookUI.StaticSetTextProperty(label)

        local labelTxt = GUI.CreateStatic(petInfoBg, ttl[i].spiritName .. "_labelTxt", "", posX + 100, posY, 150, 26, "system", true, false)
        PetHandBookUI.StaticSetTextProperty(labelTxt)

    end

    -- 创建技能滚动窗口标题UI
    local skillTitle = GUI.CreateStatic(petInfoBg, "skillTitle", "宠物天生可携带技能", 215, 14, 300, 26, "system", true, false)
    PetHandBookUI.StaticSetTextProperty(skillTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(skillTitle, "skillTitle")

    -- 创建技能滚动gridUI
    local rightItemScroll = GUI.LoopScrollRectCreate(petInfoBg, "rightItemScroll", 260, 45, 410, 160,
            PET_HANDBOOK_UI, "CreatPetSkillItemIconPool", PET_HANDBOOK_UI, "RefreshPetSkillItemIconScroll", 0,
            false, Vector2.New(80, 80), skillScrollRow, UIAroundPivot.TopLeft, UIAnchor.TopLeft)

    GUI.ScrollRectSetChildSpacing(rightItemScroll, Vector2.New(2, 1));

    UILayout.SetAnchorAndPivot(rightItemScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    _gt.BindName(rightItemScroll, "rightItemScroll")

    GUI.LoopScrollRectSetTotalCount(rightItemScroll, skillScrollRow * skillScrollCol)

end

-- 设置资质文本数据
function PetHandBookUI.TalentSetData(currPetData)

    if not currPetData then return nil end

    local petTypeDataList = {}

    local ttl = talentTxtList

    for i = 1, #currPetData do
        local petDB = DB.GetOncePetByKey2(currPetData[i].PetKeyname)
        local temp = {}

        for j = 1, #ttl do
            temp[j] = {}
            if j == 1 then  -- 血量资质
                temp[j].lowerLimit = petDB.TalentHPMin
                temp[j].upperLimit = petDB.TalentHPMax
            elseif j == 2 then  -- 物功资质
                temp[j].lowerLimit = petDB.TalentPhyAtkMin
                temp[j].upperLimit = petDB.TalentPhyAtkMax
            elseif j == 3 then  -- 物防资质
                temp[j].lowerLimit = petDB.TalentPhyDefMin
                temp[j].upperLimit = petDB.TalentPhyDefMax
            elseif j == 4 then  -- 法攻资质
                temp[j].lowerLimit = petDB.TalentMagAtkMin
                temp[j].upperLimit = petDB.TalentMagAtkMax
            elseif j == 5 then  -- 法防资质
                temp[j].lowerLimit = petDB.TalentMagDefMin
                temp[j].upperLimit = petDB.TalentMagDefMax
            elseif j == 6 then  -- 速度资质
                temp[j].lowerLimit = petDB.TalentSpeedMin
                temp[j].upperLimit = petDB.TalentSpeedMax
            elseif j == 7 then  -- 成长率
                temp[j].lowerLimit = petDB.GrowthRateMin
                temp[j].upperLimit = petDB.GrowthRateMax
            end
        end

        local tmp = { ttl = temp, type = petDB.Type, petDB = petDB, toggleTxt = PetHandBookUI.PetType[petDB.Type].typeName }
        table.insert(petTypeDataList, tmp)

        -- 当前宠物可以突破
        if i == #currPetData then
            if currPetData[i].IsUpStar == 1 then
                temp = {}
                for j = 1, #ttl do
                    temp[j] = {}
                    if j == 1 then  -- 血量资质
                        temp[j].lowerLimit = petDB.TalentHPMin
                        temp[j].upperLimit = currPetData[i].TalentMax.TalentHPMax
                    elseif j == 2 then  -- 物功资质
                        temp[j].lowerLimit = petDB.TalentPhyAtkMin
                        temp[j].upperLimit = currPetData[i].TalentMax.TalentPhyAtkMax
                    elseif j == 3 then  -- 物防资质
                        temp[j].lowerLimit = petDB.TalentPhyDefMin
                        temp[j].upperLimit = currPetData[i].TalentMax.TalentPhyDefMax
                    elseif j == 4 then  -- 法攻资质
                        temp[j].lowerLimit = petDB.TalentMagAtkMin
                        temp[j].upperLimit = currPetData[i].TalentMax.TalentMagAtkMax
                    elseif j == 5 then  -- 法防资质
                        temp[j].lowerLimit = petDB.TalentMagDefMin
                        temp[j].upperLimit = currPetData[i].TalentMax.TalentMagDefMax
                    elseif j == 6 then  -- 速度资质
                        temp[j].lowerLimit = petDB.TalentSpeedMin
                        temp[j].upperLimit = currPetData[i].TalentMax.TalentSpeedMax
                    elseif j == 7 then  -- 成长率
                        temp[j].lowerLimit = petDB.GrowthRateMin
                        temp[j].upperLimit = petDB.GrowthRateMax
                    end
                end
            end
            tmp = { ttl = temp, petDB = petDB, toggleTxt = "突破" }
            table.insert(petTypeDataList, tmp)
        end
    end

    return petTypeDataList
end

-- 创建左侧leftItemScroll
function PetHandBookUI.CreatPetItemIconPool()
    local itemScroll = _gt.GetUI("leftItemScroll")
    local index = GUI.LoopScrollRectGetChildInPoolCount(itemScroll) + 1
    local itemIcon = ItemIcon.Create(itemScroll, "itemIcon"..index, 0, 0)

    -- 创建grid背景按钮
    local itemBgBtn = GUI.ButtonCreate(itemIcon, "itemBgBtn", "1800700110", 0, 0, Transition.ColorTint)
    UILayout.SetAnchorAndPivot(itemBgBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(itemBgBtn, UCE.PointerClick, PET_HANDBOOK_UI, "OnPetItemIconBgBtnClick")
    GUI.SetData(itemIcon, "itemBgBtnGuid", tostring(GUI.GetGuid(itemBgBtn)))

    -- 创建宠物头像
    local avatar = GUI.ImageCreate(itemBgBtn, "avatar", "", 0, 0, false, 80, 80, false)
    GUI.SetData(itemBgBtn, "avatarGuid", tostring(GUI.GetGuid(avatar)))
    GUI.SetVisible(avatar, false)

    -- 创建选中UI
    local selected = GUI.ImageCreate(avatar, "selected", "1800707330", 0, 0)
    UILayout.SetAnchorAndPivot(selected, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetData(itemBgBtn, "selectedGuid", tostring(GUI.GetGuid(selected)))
    GUI.SetVisible(selected, false)

    GUI.SetData(itemIcon, "index", index)

    return itemIcon
end

-- 刷新左侧leftItemScroll
function PetHandBookUI.RefreshPetItemIconScroll(para)

    para = string.split(para, "#");
    local guid = para[1];
    local index = tonumber(para[2]) + 1;
    local itemIcon = GUI.GetByGuid(guid);

    -- 获取宠物数据
    local data = PetHandBookUI.PetData
    if not data then return itemIcon end

    if not data[index] then return itemIcon end
    local petDB = DB.GetOncePetByKey2(data[index][1].PetKeyname)

    local itemBgBtn = GUI.GetByGuid(GUI.GetData(itemIcon, "itemBgBtnGuid"))
    local avatar = GUI.GetByGuid(GUI.GetData(itemBgBtn, "avatarGuid"))
    local selected = GUI.GetByGuid(GUI.GetData(itemBgBtn, "selectedGuid"))

    GUI.ImageSetImageID(avatar, tostring(petDB.Head))

    GUI.SetVisible(avatar, true)
    --GUI.SetVisible(selected, false)

    GUI.SetData(itemBgBtn, "index", tostring(index))
    GUI.SetData(itemBgBtn, "petKeyName", tostring(petDB.KeyName))

    if not currPetDB then
        currPetDB = petDB
    end

    if currPetDB.KeyName == petDB.KeyName then
        GUI.SetVisible(selected, true)
        currPetItemIconBgBtn = itemBgBtn
        currPetIndex = tonumber(index)
        PetHandBookUI.RefreshRightUIData()

        currSkillIdList = PetHandBookUI.GetSkillIdByPetDB(petDB)
    else
        GUI.SetVisible(selected, false)
    end

end

-- 创建右侧rightItemScroll
function PetHandBookUI.CreatPetSkillItemIconPool()
    local itemScroll = _gt.GetUI("rightItemScroll")
    local index = GUI.LoopScrollRectGetChildInPoolCount(itemScroll)
    local itemIcon = ItemIcon.Create(itemScroll, "itemIcon"..tonumber(index) + 1, 0, 0)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, PET_HANDBOOK_UI, "OnPetSkillItemIconClick")

    -- 创建技能相关UI
    local skillLvImg = GUI.ImageCreate(itemIcon, "skillLvImg", "", -7, -8)
    UILayout.SetAnchorAndPivot(skillLvImg, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetVisible(skillLvImg, false)
    GUI.SetData(itemIcon, "skillLvImgGuid", tostring(GUI.GetGuid(skillLvImg)))

    -- 创建必带图片UI
    local takeImg = GUI.ImageCreate(itemIcon, "takeImg", "1800707130", 0, 0)
    UILayout.SetAnchorAndPivot(takeImg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(takeImg, false)
    GUI.SetData(itemIcon, "takeImgGuid", tostring(GUI.GetGuid(takeImg)))

    return itemIcon
end

-- 刷新右侧rightItemScroll
function PetHandBookUI.RefreshPetSkillItemIconScroll(para)
    para = string.split(para, "#");
    local guid = para[1];
    local index = tonumber(para[2]) + 1;
    local itemIcon = GUI.GetByGuid(guid);

    ItemIcon.SetEmpty(itemIcon)
    local skillLvImg = GUI.GetByGuid(GUI.GetData(itemIcon, "skillLvImgGuid"))
    GUI.SetVisible(skillLvImg, false)

    local takeImg = GUI.GetByGuid(GUI.GetData(itemIcon, "takeImgGuid"))
    GUI.SetVisible(takeImg, false)

    GUI.SetData(itemIcon, "index", tostring(index))

    if not currSkillIdList then return end
    if index > #currSkillIdList then return end

    local skillDB = DB.GetOnceSkillByKey1(currSkillIdList[index].Id)
    ItemIcon.BindSkillDB(itemIcon, skillDB)

    GUI.SetData(itemIcon, "skillId", tostring(skillDB.Id))

    local skillImgId = PetHandBookUI.GetSkillLvImgIdBySkillDB(skillDB)

    GUI.ImageSetImageID(skillLvImg, skillImgId)

    if currSkillIdList[index].Take == 1 then
        GUI.SetVisible(takeImg, true)
    else
        GUI.SetVisible(takeImg, false)
    end

    if PetHandBookUI.StrIsEmpty(skillImgId) then
        GUI.SetVisible(skillLvImg, false)
    else
        GUI.SetVisible(skillLvImg, true)
    end

end

-- 刷新函数(可当作服务端刷新客户端数据的回调函数)
function PetHandBookUI.Refresh()

    if not PetHandBookUI.PetData then return end

    -- 刷新左侧UI数据
    PetHandBookUI.RefreshLeftUIData()

end

-- 刷新左侧UI数据
function PetHandBookUI.RefreshLeftUIData()
    local leftItemScroll = _gt.GetUI("leftItemScroll")

    local gridNR = petScrollRow * petScrollCol
    local leftItemNR = #PetHandBookUI.PetData

    if leftItemNR > gridNR then
        gridNR = petScrollRow * math.ceil(leftItemNR / petScrollRow)
    end

    GUI.LoopScrollRectSetTotalCount(leftItemScroll, leftItemNR)
    GUI.ScrollRectSetNormalizedPosition(leftItemScroll, Vector2.New(0, 0))

end

-- 刷新右侧UI数据
function PetHandBookUI.RefreshRightUIData(guid)

    if not PetHandBookUI.PetData then return end

    local petData = PetHandBookUI.PetData

    local petTypeToggle = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(petTypeToggle, "index"))
    index = index or 1

    local petDB = nil
    if not petData[currPetIndex][index] then
        petDB = DB.GetOncePetByKey2(petData[currPetIndex][#petData[currPetIndex]].PetKeyname)
    else
        petDB = DB.GetOncePetByKey2(petData[currPetIndex][index].PetKeyname)
    end

    currPetDB = petDB

    local petDBList = PetHandBookUI.TalentSetData(petData[currPetIndex])
    if not petDBList then return end

    currSkillIdList = PetHandBookUI.GetSkillIdByPetDB(currPetDB)

    -- 刷新携带技能
    if index > #petData[currPetIndex] then
        local tb = petData[currPetIndex][#petData[currPetIndex]].UpStarSkill
        for i = 1, #tb do
            local skillId = DB.GetOnceSkillByKey2(tb[i]).Id
            table.insert(currSkillIdList, { Id = skillId, Take = 0 })
        end
    end

    local rightItemScroll = _gt.GetUI("rightItemScroll")
    GUI.LoopScrollRectRefreshCells(rightItemScroll)

    -- 刷新宠物信息UI
    PetHandBookUI.RefreshPetInfoUI(petData, petDBList, index)

    -- 刷新资质数据
    PetHandBookUI.RefreshTalentInfoUI(petDBList, index)

    -- 刷新获取途径
    if index > #petData[currPetIndex] then index = #petData[currPetIndex] end
    PetHandBookUI.RefreshApproach(petData, index)

end

-- 刷新宠物信息UI
function PetHandBookUI.RefreshPetInfoUI(petData, petDBList, index)
    if not petData then return end
    if not currPetDB then return end

    -- 宠物模型
    local petModel = _gt.GetUI("petModel")
    ModelItem.Bind(petModel, tonumber(currPetDB.Model), tonumber(currPetDB.ColorId), 0, eRoleMovement.ATTSTAND_W1)
    PetHandBookUI.OnShowEffectToggleClick()

    -- 宠物名称
    local petNameTxt = _gt.GetUI("petNameTxt")
    GUI.StaticSetText(petNameTxt, currPetDB.Name)

    -- 参战等级
    local levelTxt = _gt.GetUI("levelTxt")
    GUI.StaticSetText(levelTxt, currPetDB.CarryLevel)

    local toggleGroup = _gt.GetUI("toggleGroup")
    -- 刷新宠物类型ToggleUI
    PetHandBookUI.RefreshPetTypeToggle(toggleGroup, petDBList, index)

    -- 宠物类型UI
    local petTypeImage = _gt.GetUI("petTypeImage")
    local imageId = PetHandBookUI.PetType[currPetDB.Type].iconPath
    GUI.ImageSetImageID(petTypeImage, imageId)

end

-- 刷新宠物类型复选框
function PetHandBookUI.RefreshPetTypeToggle(toggleGroup, petDBList, index)
    for i = 1, 4 do
        local petTypeToggle = GUI.GetChild(toggleGroup, "petTypeToggle"..i, false)
        GUI.SetVisible(petTypeToggle, false)
    end

    for i = 1, #petDBList do

        local petTypeToggle = GUI.GetChild(toggleGroup, "petTypeToggle"..i, false)
        GUI.SetVisible(petTypeToggle, true)

        local labelTxt = GUI.GetChild(petTypeToggle, "labelTxt", false)
        GUI.StaticSetText(labelTxt, petDBList[i].toggleTxt)

        local buttonOfTips = _gt.GetUI("buttonOfTips"..i)
        GUI.SetVisible(buttonOfTips, false)
    end

    local skillTitle = _gt.GetUI("skillTitle")
    local buttonOfTips = _gt.GetUI("buttonOfTips"..index)
    if index == #petDBList then
        GUI.StaticSetText(skillTitle, "突破到最高星级可获得的技能")
        GUI.SetPositionX(skillTitle, 260)
        GUI.SetVisible(buttonOfTips, true)
    else
        GUI.StaticSetText(skillTitle, "宠物天生可携带技能")
        GUI.SetPositionX(skillTitle, 215)
        GUI.SetVisible(buttonOfTips, false)
    end
end

-- 刷新资质数据
function PetHandBookUI.RefreshTalentInfoUI(petDBList, toggleIndex)

    if not petDBList then return end

    local petInfoBg = _gt.GetUI("petInfoBg")
    local toggleGroup = _gt.GetUI("toggleGroup")

    local ttl = talentTxtList

    local talentData = petDBList[toggleIndex]
    for i = 1, #ttl do
        local talentLabelTxt = GUI.GetChild(petInfoBg, ttl[i].spiritName .. "_labelTxt", false)
        local _ttl = talentData.ttl

        GUI.StaticSetText(talentLabelTxt, tostring(_ttl[i].lowerLimit) .. "~" .. tostring(_ttl[i].upperLimit))
    end

    GUI.CheckBoxExSetCheck(GUI.GetChild(toggleGroup, "petTypeToggle"..toggleIndex, false), true)
end

-- 刷新获取途径
function PetHandBookUI.RefreshApproach(petData, toggleIndex)

    local approach = petData[currPetIndex][toggleIndex].GetWay

    -- 重新设置button显示位置
    local approachBg = _gt.GetUI("approachBg")
    for i = 1, approachCount do
        local btn = GUI.GetChild(approachBg, "approachBtn"..i)
        GUI.SetVisible(btn, false)
    end

    for i = 1, #approach do
        local btn = GUI.GetChild(approachBg, "approachBtn"..i)
        local posY = PetHandBookUI.GetPosY(#approach, i)
        GUI.ButtonSetText(btn, tostring(approach[i]))
        GUI.SetPositionY(btn, posY)
        GUI.SetVisible(btn, true)

        GUI.SetData(btn, "petIndex", currPetIndex)
        GUI.SetData(btn, "toggleIndex", toggleIndex)
    end

end

function PetHandBookUI.GetPosY(count, index)
    if count <= 3 then
        return 85 + (index - 1) * 62
    else
        return 70 + (index - 1) * 55
    end
end

-- ------------点击事件函数--------------
-- 宠物模型点击事件
function PetHandBookUI.OnModelClick(guid)
    if not currPetDB then return end

    local petModel = _gt.GetUI("petModel")
    math.randomseed(os.time())
    local index = math.random(2)
    local movements = { eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1 }
    ModelItem.Bind(petModel, tonumber(currPetDB.Model), tonumber(currPetDB.ColorId), 0, movements[index])
end

-- 点击模型后的回调函数
function PetHandBookUI.OnAnimationCallBack(guid, action)
    if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
        return
    end

    local petModel = _gt.GetUI("petModel")
    ModelItem.Bind(petModel, tonumber(currPetDB.Model), tonumber(currPetDB.ColorId), 0, eRoleMovement.ATTSTAND_W1)
end

-- 饰品toggle点击事件
function PetHandBookUI.OnShowEffectToggleClick()
    local showEffectToggle = _gt.GetUI("showEffectToggle")
    local petModel = _gt.GetUI("petModel")
    if showEffectToggle and petModel then
        local isOn = GUI.CheckBoxExGetCheck(showEffectToggle)
        if isOn then
            if currPetDB then
                local preTrinketEff = GUI.GetData(petModel, "trinketEff")
                if preTrinketEff ~= currPetDB.TrinketEff then
                    local preEffectID = tonumber(GUI.GetData(petModel, "effectID"))
                    if preEffectID and preEffectID ~= 0 then
                        GUI.DestroyRoleEffect(petModel, preEffectID)
                    end
                    local effectID = GUI.CreateRoleEffect(petModel, TOOLKIT.Str2uLong(currPetDB.TrinketEff))
                    GUI.SetData(petModel, "effectID", effectID)
                    GUI.SetData(petModel, "trinketEff", currPetDB.TrinketEff)
                end
            end
        else
            local effectID = tonumber(GUI.GetData(petModel, "effectID"))
            if effectID and effectID ~= 0 then
                GUI.DestroyRoleEffect(petModel, effectID)
                GUI.SetData(petModel, "trinketEff", "")
            end
        end
    end
end

-- 宠物类型Toggle点击事件
function PetHandBookUI.OnPetTypeToggleClick(guid)

    if not PetHandBookUI.PetData then return end

    -- 刷新右侧UI数据
    PetHandBookUI.RefreshRightUIData(guid)
end

-- 左侧宠物滚动列表itemIcon点击事件
function PetHandBookUI.OnPetItemIconBgBtnClick(guid)

    if not currPetItemIconBgBtn then return end

    local itemBgBtn = GUI.GetByGuid(guid)

    -- 取消当前选中宠物
    local currSelected = GUI.GetByGuid(GUI.GetData(currPetItemIconBgBtn, "selectedGuid"))
    GUI.SetVisible(currSelected, false)

    -- 设置当前选中宠物
    currPetItemIconBgBtn = itemBgBtn
    currSelected = GUI.GetByGuid(GUI.GetData(currPetItemIconBgBtn, "selectedGuid"))
    GUI.SetVisible(currSelected, true)

    currPetIndex = tonumber(GUI.GetData(currPetItemIconBgBtn, "index"))

    -- 刷新右侧UI数据
    PetHandBookUI.RefreshRightUIData()
end

-- 右侧底层技能滚动列表itemIcon点击事件
function PetHandBookUI.OnPetSkillItemIconClick(guid)
    local itemIcon = GUI.GetByGuid(guid)

    if not itemIcon then return end

    local skillId = GUI.GetData(itemIcon, "skillId")

    local index = tonumber(GUI.GetData(itemIcon, "index"))

    if index > #currSkillIdList then skillId = "" end

    if PetHandBookUI.StrIsEmpty(skillId) then return end

    local petTalentInfoGroup = _gt.GetUI("petTalentInfoGroup")
    -- 创建tips
    local skillTips = Tips.CreateSkillId(skillId, petTalentInfoGroup, "skillTips", -80, 100, 320,0,0)
    GUI.AddWhiteName(skillTips, tostring(GUI.GetGuid(petTalentInfoGroup)))

end

-- 获取途径按钮点击事件
function PetHandBookUI.OnApproachBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local approachIndex = tonumber(GUI.GetData(btn, "index"))
    local petIndex = tonumber(currPetIndex)
    local toggleIndex = tonumber(GUI.GetData(btn, "toggleIndex"))

    CL.SendNotify(NOTIFY.SubmitForm,"FormPetGuide", "PetGetWay", petIndex, toggleIndex, approachIndex)
    GUI.CloseWnd("PetUI")
    GUI.CloseWnd("PetHandBookUI")
end

-- 突破界面tips按钮点击事件
function PetHandBookUI.OnBreakTipsBtnClick(guid)
    Tips.CreateHint("资质区间为最高品质突破后的区间", _gt.GetUI("panelBg"), 285, 135, UILayout.Center, 330, 80)
end

-- ------------------------------------

-- 初始化数据
function PetHandBookUI.InitData()
    -- 当前宠物 itemIcon
    currPetItemIconBgBtn = nil
    -- 当前宠物数据
    currPetDB = nil
    -- 当前宠物天生可携带技能Id列表
    currSkillIdList = nil

    currPetIndex = 0
end

-- 打开图鉴界面后第一个的回调函数
function PetHandBookUI.OnShow()
    local wnd = _gt.GetUI("wnd")

    if not wnd then
        test("wnd must be not nil")
        return
    end

    if not PetHandBookUI.PetData then
        test("PetHandBookUI.PetData must be not nil")
        return
    end

    GUI.SetVisible(wnd, true)

    PetHandBookUI.InitData()

    PetHandBookUI.Refresh()

end

-- 关闭页面函数
function PetHandBookUI.OnExit()
    GUI.CloseWnd(PET_HANDBOOK_UI)
end

-- --------------辅助函数--------------

-- 设置文本标签属性
function PetHandBookUI.StaticSetTextProperty(text, anchor, aroundPivot)
    anchor = anchor or UIAnchor.TopLeft
    aroundPivot = aroundPivot or UIAroundPivot.TopLeft

    UILayout.SetAnchorAndPivot(text, anchor, aroundPivot)
    GUI.StaticSetFontSize(text, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
    GUI.SetColor(text, DarkColor)
end

-- 获取当前宠物的所有技能ID
function PetHandBookUI.GetSkillIdByPetDB(petDB)

    local skillGroups = { tonumber(petDB.SkillGroup1), tonumber(petDB.SkillGroup2), tonumber(petDB.SkillGroup3) }

    local tb_skillData = {}
    for i = 1, #skillGroups do
        local skillGroup = DB.GetOnceSkill_GroupByKey1(skillGroups[i])
        local t = { SkillGroup = skillGroup, Take = 0 }
        if skillGroup ~= 0 then
            if (i == 1 or i == 2) then
                t.Take = 1
            else
                t.Take = 0
            end
            table.insert(tb_skillData, t)
        end
    end

    local skillIdList = {}

    for i = 1, #tb_skillData do
        local skillGroup = tb_skillData[i].SkillGroup
        for j = 1, CntOfSkillsPerPet do
            local id = tonumber(skillGroup["Skill"..j])
            if id ~= 0 then
                local t = { Id = id, Take = 0 }
                if tb_skillData[i].Take == 1 then
                    t.Take = 1
                end
                table.insert(skillIdList, t)
            end
        end
    end

    return skillIdList
end

-- 获取技能等级imageId
function PetHandBookUI.GetSkillLvImgIdBySkillDB(skillDB)
    local imgId = ""
    if not skillDB then return imgId end

    local skillLv = skillDB.UpSkill
    if skillLv == 1 then
        imgId = "1800707140"
    elseif skillLv == 2 then
        imgId = "1800707150"
    elseif skillLv == 3 then
        imgId = "1800707160"
	elseif skillLv == 4 then
		imgId = "1801718014"
	elseif skillLv == 5 then
		imgId = "1801718015"
	elseif skillLv == 6 then
		imgId = "1801718016"
	elseif skillLv == 7 then
		imgId = "1801718017"
	elseif skillLv == 8 then
		imgId = "1801718018"
	elseif skillLv == 9 then
		imgId = "1801718019"
	elseif skillLv == 10 then
		imgId = "1801718020"
    end

    return imgId
end

-- 判断字符串是否为空
function PetHandBookUI.StrIsEmpty(str)
    return not str or string.len(str) < 1
end

local test = function()  end