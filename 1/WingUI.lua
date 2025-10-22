local WingUI = {}
_G.WingUI = WingUI
local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local greenTextColor = Color.New(129 / 255, 60 / 255, 176 / 255, 255 / 255)
local colorwrite = Color.New(1, 1, 1, 1);
local coloroutline = Color.New(162 / 255.0, 75 / 225.0, 21 / 255.0, 1)
local colorblack = Color.New(0, 0, 0, 1);
local yellowTextColor = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255)

local ColorType_FontColor2 = Color.New(102 / 255, 47 / 255, 22 / 255);
local fontSize = 22;
local addWingExpTextColor = Color.New(54 / 255, 183 / 255, 109 / 255, 255 / 255)
local fontColor2 = "662F16";    --深色文字

local cntPerLine = 6; -- 物品栏没行多少个框

--local BagUI = _G.BagUI

local quality = { -- 品质框
    "1800400330",
    "1800400100",
    "1800400110",
    "1800400120",
    "1800400320",
}

-- 二级页签
local WingTabList = {
    { "成长", "growingSubTabBtn", "1800402030", "1800402032", "OnGrowingSubTabBtnClick", 95, -256, 175, 40, 100, 35 },
    { "拥有", "haveSubTabBtn", "1800402030", "1800402032", "OnHaveSubTabBtnClick", 265, -256, 175, 40, 100, 35 },
    { "图鉴", "outwardSubTabBtn", "1800402030", "1800402032", "OnOutwardSubTabBtnClick", 435, -256, 175, 40, 100, 35 }, -- 2021-8-5 外观改为图鉴
}

-- 查找永久羽翼id时，限制循环的次数
local max_search_times = 20

-- 创建基础页面
function WingUI.CreateWingPage()

    local wnd = GUI.GetWnd("BagUI")
    local panelBg = GUI.GetChild(wnd,"panelBg")   --GUI.GetByGuid(_gt.panelBg);
    local WingPage = GUI.GroupCreate(panelBg, "WingPage", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd));

    _gt.BindName(WingPage,"WingPage")

    UILayout.CreateSubTab(WingTabList, WingPage, "WingUI"); -- 创建二级页签

    -- 创建左边页面
    WingUI.CreateLeftPage(WingPage)

    -- 创建右边页面
    WingUI.CreateRightPage(WingPage,panelBg)

    return GUI.GetGuid(WingPage)

end
-- 向服务器发送请求
function WingUI.getSeverWingData()
    --FormClothes.GetWingData(player)  --获取玩家羽翼信息
    CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","GetWingData")
    -- 绑定数据
        -- WingUI.HaveWing_Data 已拥有的翅膀数据
        -- WingUI.CurrentUsedWingId 当前装备的羽翼Id
        -- WingUI.WingGrow_Data 成长界面数据
    -- 执行方法
        -- WingUI.RefreshWingPage() 刷新方法
    -- 执行另一个服务端方法
        -- WingSystem.GetGrowWndData(player)
end
-- 刷新基础页面
WingUI.WingSubTabIndex = 3 -- 当前选中的二级页签
WingUI.HaveWing_Data = nil  -- 已拥有的翅膀数据
WingUI.CurrentUsedWingId = CL.GetIntCustomData("Model_Wing") -- 当前装备的羽翼Id
WingUI.Current_Selected_WingId = 0 -- 当前选中的羽翼ID
WingUI.WingGrow_Data = nil  -- 成长界面数据
function WingUI.RefreshWingPage()
    local WingPage = _gt.GetUI("WingPage") -- 如果父类不存在
    if WingPage == nil then
        return
    end

    -- 初始化数据
    WingUI.InitData()

    -- 刷新角色模型
    --WingUI.Refresh_RoleModel()

    -- 根据服务器数据 刷新本地数据

    -- 确定二级页签
    --直接打开成长界面
    if WingUI.parameter_tab_index then
        WingUI.WingSubTabIndex = WingUI.parameter_tab_index
        WingUI.parameter_tab_index = nil
    else
        WingUI.WingSubTabIndex = 1
    end
    UILayout.OnSubTabClickEx(WingUI.WingSubTabIndex,WingTabList)

    -- 根据二级页签刷新页面
    --WingUI.RefreshSubPage1()

    -- 刷新成长页签小红点
    local growing_btn = GUI.GetChild(WingPage, 'growingSubTabBtn')
    -- 如果羽翼已达到最大等级
    if GlobalProcessing.wing_is_max_level == true then
        GlobalProcessing.SetRetPoint(growing_btn, false)
    else
        local red_data = WingUI.is_show_red()
        if red_data.upgrade ~= nil then
            GlobalProcessing.SetRetPoint(growing_btn, red_data.upgrade)
        elseif red_data.level_up ~= nil then
            GlobalProcessing.SetRetPoint(growing_btn, red_data.level_up)
        end
    end

end
-- 刷新角色事件
--local preClothesId = nil -- 上一次时装
local pre_clothes_info = nil -- 上一次时装信息，用于减少刷新次数
--local preWingID = nil -- 上一次羽翼
function WingUI.Refresh_RoleModel()
    -- 刷新角色模型
    local WingPage_roleModel = _gt.GetUI("WingPage_roleModel")
    -- 刷新时装
    local FashionPage_roleModel = WingPage_roleModel
    local fashionClothes_Item = nil
    --if WingUI == nil or WingUI.Fashion_CurrentDress_Id == nil  then
    --    test("还未选择时装")
    --end
    if WingUI and WingUI.Fashion_CurrentDress_Id and WingUI.Fashion_CurrentDress_Id ~= 0 then
        fashionClothes_Item = DB.GetOnceIllusionByKey1(WingUI.Fashion_CurrentDress_Id)
    else
        -- 使用自定义变量查询当前装备的时装id
        local fashion_clothes_id =CL.GetIntCustomData("Model_Clothes", 0)
        if fashion_clothes_id and fashion_clothes_id ~= 0 then
            fashionClothes_Item = DB.GetOnceIllusionByKey1(fashion_clothes_id)
            if fashionClothes_Item then
                WingUI.Fashion_CurrentDress_Id = fashion_clothes_id
            end
        end
    end

    local dyn1 = CL.GetIntAttr(RoleAttr.RoleAttrColor1)
    local dyn2 = CL.GetIntAttr(RoleAttr.RoleAttrColor2)
    local role = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole))
    local model = role.Model
    local sex = role.Sex
    local weapon_id = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId)
    local weapon_effect = CL.GetIntAttr(RoleAttr.RoleAttrEffect1)


    --if preClothesId == WingUI.Fashion_CurrentDress_Id then goto wearWing end -- 如果与上次时装id相同则不刷新
    -- 如果与上次时装id相同则不刷新
    local cur_clothes_info = tostring(WingUI.Fashion_CurrentDress_Id or 0) .. tostring(dyn1) .. tostring(dyn2) .. tostring(model) .. tostring(weapon_id) ..tostring(weapon_effect)..tostring(sex)
    if pre_clothes_info ==  cur_clothes_info then
        goto wearWing
    end


    if fashionClothes_Item then
        -- 全身时装
        if fashionClothes_Item.Type == 0 then
            ModelItem.Bind(FashionPage_roleModel,tonumber(tostring(fashionClothes_Item.Model)),dyn1,dyn2,eRoleMovement.STAND_W1,weapon_id,fashionClothes_Item.Sex,weapon_effect,0,model)
            -- 添加武器和宝石特效
            ModelItem.BindRoleEquipGemEffect(FashionPage_roleModel)
            -- 帽子时装
        elseif fashionClothes_Item.Type == 1 then
            ModelItem.Bind(FashionPage_roleModel,model,dyn1,dyn2,eRoleMovement.STAND_W1,weapon_id,fashionClothes_Item.Sex,weapon_effect,tonumber(tostring(fashionClothes_Item.Model)),model)
            -- 添加武器和宝石特效
            ModelItem.BindRoleEquipGemEffect(FashionPage_roleModel)
			--人物染色
			if CL.GetStrCustomData("Model_DynJson1") ~= "" then
				GUI.RefreshDyeSkinJson(FashionPage_roleModel, CL.GetStrCustomData("Model_DynJson1"), "")
			end	
        end
        --preClothesId = WingUI.Fashion_CurrentDress_Id
        pre_clothes_info = cur_clothes_info
    else -- 使用最开始的装扮，无时装
        --local role = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole))
        --local model = role.Model
        --local sex = role.Sex
        ModelItem.Bind(FashionPage_roleModel,model,dyn1,dyn2,eRoleMovement.STAND_W1,weapon_id,sex,weapon_effect,0,model)
        -- 添加武器和宝石特效
        ModelItem.BindRoleEquipGemEffect(FashionPage_roleModel)
        --preClothesId = 0
        pre_clothes_info = cur_clothes_info
		--人物染色
		if CL.GetStrCustomData("Model_DynJson1") ~= "" then
			GUI.RefreshDyeSkinJson(FashionPage_roleModel, CL.GetStrCustomData("Model_DynJson1"), "")
		end	
    end

    ::wearWing::

    local wing_Item = nil
    -- 获取当前穿戴的羽翼，然后通过它获取的羽翼对象
    if WingUI.WingSubTabIndex == 1 then
        if WingUI.CurrentUsedWingId and WingUI.CurrentUsedWingId ~= 0 then wing_Item = DB.GetOnceIllusionByKey1(WingUI.CurrentUsedWingId) end
    else -- 如果页签是 2 或 3
        if WingUI.Current_Selected_WingId and WingUI.Current_Selected_WingId ~= 0 then wing_Item = DB.GetOnceIllusionByKey1(WingUI.Current_Selected_WingId) end
    end

    --if preWingID == WingUI.Current_Selected_WingId then return end -- 如果与上一次羽翼id相同 则不刷新
    if wing_Item then
        if wing_Item.Type == 2 then

            if WingUI.WingGrow_Data and WingUI.WingGrow_Data.WingGrow_Stage then
                GUI.ReplaceWing(WingPage_roleModel, tonumber(tostring(wing_Item.Model)),WingUI.WingGrow_Data.WingGrow_Stage)
                --preWingID = WingUI.Current_Selected_WingId
            end
            --GUI.ReplaceWing(WingPage_roleModel, tonumber(tostring(wing_Item.Model)))
        end

    else -- 使用最开始的装扮，无羽翼
        GUI.ReplaceWing(WingPage_roleModel,0)
        --preWingID = 0
    end



end
-- 二级页签 1  成长界面刷新事件
function WingUI.RefreshSubPage1()
    local wingName = "斗气化翼" -- 羽翼的名称
    local Time = "永久"
    wingName = wingName .. "("..Time..")"

    local wingLevel = 0
    wingLevel = wingLevel.."级"
    local wingGrade = 0
    wingGrade = wingGrade.."阶"
    local wingDescription = "移动速度慢于斗气化马"

    local attrList = {0,0,0,0,0,0,0,0,0}
    local isDegree_Elevation = false -- 是否可以升阶
    local experience = 0 -- 经验值
    local upExperience = 100 -- 升级所需经验值

    local materialKindCount = 1  -- 升阶材料种类
    local  materialCount = {2,2,2} -- 升阶所需要材料数量
    local material1 = nil  -- 升阶材料123
    local material2 = DB.GetOnceItemByKey1(21005)
    local material3 = nil

    -- 修改数据
    if WingUI.WingGrow_Data then
        local WingGrow_Data = WingUI.WingGrow_Data
        -- 描述和名字
        if WingUI.CurrentUsedWingId and WingUI.CurrentUsedWingId ~= 0 then
            local wing = DB.GetOnceIllusionByKey1(WingUI.CurrentUsedWingId)
            wingDescription = wing.Info
            wingName = wing.Name
        else
            wingName = "未穿戴羽翼"
            wingDescription = "请挑选一件羽翼吧！！！"
        end
        -- 等级
        wingLevel = WingGrow_Data.WingGrow_Level
        wingLevel = wingLevel.."级"
        -- 品阶
        wingGrade  = WingGrow_Data.WingGrow_Stage
        wingGrade = wingGrade.."阶"
        -- 属性
        attrList[1] = WingGrow_Data.Attr["物攻"]
        attrList[2] = WingGrow_Data.Attr["法攻"]
        attrList[3] = WingGrow_Data.Attr["物防"]
        attrList[4] = WingGrow_Data.Attr["法防"]
        attrList[5] = WingGrow_Data.Attr["物暴"]
        attrList[6] = WingGrow_Data.Attr["法暴"]
        attrList[7] = WingGrow_Data.Attr["闪避"]
        attrList[8] = WingGrow_Data.Attr["命中"]
        attrList[9] = WingGrow_Data.Attr["速度"]
        -- 经验值
        experience = WingGrow_Data.HaveExp
        upExperience = WingGrow_Data.NeedExp
        -- 是否可升阶
        isDegree_Elevation = WingGrow_Data.CanAddStage
        -- 升阶的种类
        if isDegree_Elevation and UIDefine.WingStage_Config and UIDefine.WingStage_Config[WingGrow_Data.WingGrow_Stage+1] then
            local stage = UIDefine.WingStage_Config[WingGrow_Data.WingGrow_Stage+1]
            if stage.ItemKey_1 ~= "" then materialKindCount = 1 end
            if stage.ItemKey_2 ~= "" then materialKindCount = materialKindCount + 1 end
            if stage.ItemKey_3 ~= "" then materialKindCount = materialKindCount + 1 end
            -- 升阶所需要的材料数量
            local isOne = materialKindCount == 1
            if isOne then
                materialCount = {0,stage.ItemNum_1,0}
            else
                materialCount = {stage.ItemNum_1,stage.ItemNum_2,stage.ItemNum_3}
            end
            -- 升阶材料
            if isOne then
                material1 = nil
                material2 = DB.GetOnceItemByKey2(stage.ItemKey_1)
                material3 = nil
            else
                material1 = DB.GetOnceItemByKey2(stage.ItemKey_1)
                material2 = DB.GetOnceItemByKey2(stage.ItemKey_2)
                material3 = DB.GetOnceItemByKey2(stage.ItemKey_3)
            end

        end

    end


    -- 左边
        -- 把左上角色刷新
    WingUI.Refresh_RoleModel()
        -- 把左中选择时间按钮 和购买按钮 隐藏
    local dragonWings = _gt.GetUI("dragonWings")
    local moreWingsBtn = GUI.GetChild(dragonWings,"moreWingsBtn") -- 时间按钮
    local toMallBtn = GUI.GetChild(dragonWings,"toMallBtn") -- 购买按钮
    GUI.SetVisible(moreWingsBtn,false)
    GUI.SetVisible(toMallBtn,false)

        -- 左下 文本框隐藏
    local buttonWingHandBookDesBg = _gt.GetUI("buttonWingHandBookDesBg")
    GUI.SetVisible(buttonWingHandBookDesBg,false)

        -- 刷新左边
    local upClothDesBg = GUI.GetChild(dragonWings,"upClothDesBg") -- 左中 羽翼名称文本背景
    GUI.SetVisible(upClothDesBg,true)
    local WingSelectNameBig = GUI.GetChild(upClothDesBg,"WingSelectNameBig") -- 文本
    GUI.StaticSetText(WingSelectNameBig,wingName)
        --左边描述
    local buttonWingGrowDesBg = _gt.GetUI("buttonWingGrowDesBg")
    GUI.SetVisible(buttonWingGrowDesBg,true)

    local WingTxtLevelHas = GUI.GetChild(buttonWingGrowDesBg,"WingTxtLevelHas") -- 等级
    GUI.StaticSetText(WingTxtLevelHas,wingLevel)

    local WingTxtGradeHas = GUI.GetChild(buttonWingGrowDesBg,"WingTxtGradeHas") -- 品阶
    GUI.StaticSetText(WingTxtGradeHas,wingGrade)

    local WingTxtDesGrow = GUI.GetChild(buttonWingGrowDesBg,"WingTxtDesGrow") -- 描述
    GUI.StaticSetText(WingTxtDesGrow,wingDescription)


    -- 右边
        -- 隐藏右边物品栏
    local WingScroll = _gt.GetUI("WingScroll")
    GUI.SetVisible(WingScroll,false)

    -- 隐藏按钮
    local wnd = GUI.GetWnd("BagUI")
    local panelBg = GUI.GetChild(wnd,"panelBg")
    local SaveWingsBtn = GUI.GetChild(panelBg,"SaveWingsBtn") -- 穿戴
    GUI.SetVisible(SaveWingsBtn,false)
    local unlockWingsBtn = GUI.GetChild(panelBg,"unlockWingsBtn") -- 获取
    GUI.SetVisible(unlockWingsBtn,false)
    local unWearWingsBtn = GUI.GetChild(panelBg,"unWearWingsBtn") -- 卸下
    GUI.SetVisible(unWearWingsBtn,false)

        -- 刷新右边
    local WingsGrowUpBg = _gt.GetUI("WingsGrowUpBg")
    GUI.SetVisible(WingsGrowUpBg,true)

    local WingsGrowDownBg = GUI.GetChild(WingsGrowUpBg,"WingsGrowDownBg") -- 右边下部分

    local GrowTxtlabal = GUI.GetChild(WingsGrowDownBg,"GrowTxtlabal") -- 升级或升阶文本

    local experienceSlider = GUI.GetChild(WingsGrowDownBg,"experienceSlider") --经验条
    local experienceSliderCurrentTxt = GUI.GetChild(WingsGrowDownBg,"experienceSliderCurrentTxt") -- 经验条上的文本

    local wingsLevelUpBtn = GUI.GetChild(WingsGrowDownBg,"wingsLevelUpBtn") -- 升级按钮
    local wingsUpgradeUpBtn = GUI.GetChild(WingsGrowDownBg,"wingsUpgradeUpBtn") -- 升阶按钮

        -- 刷新属性
    if WingUI.attributeNumber ~= nil then
        for k,v in ipairs(WingUI.attributeNumber) do
            -- 1、6、2、7、3、8、4、9、5
            if v ~= nil and attrList[k] ~= nil then
                GUI.StaticSetText(v,attrList[k])
            elseif v == nil then
                test('WingUI.RefreshSubPage1() 376行左右，属性UI节点为空')
            elseif attrList[k] == nil then
                test('WingUI.RefreshSubPage1() 378行左右，服务器发送的属性为空')
            end
        end
    end
        -- 刷新经验值或物品
        -- 判断是升级还是升阶
    if not isDegree_Elevation then
        -- 改为升级
        GUI.StaticSetText(GrowTxtlabal,"升级")
        GUI.SetVisible(wingsLevelUpBtn,true)
        GUI.SetVisible(wingsUpgradeUpBtn,false)
        -- 隐藏升阶物品框
        for i=1,3 do
            local itemBg = GUI.GetChild(WingsGrowDownBg,"item".. i .."Bg")
            GUI.SetVisible(itemBg,false)
        end
        -- 显示经验条
        GUI.SetVisible(experienceSlider,true)
        GUI.SetVisible(experienceSliderCurrentTxt,true)
        -- 刷新经验值升级
        if UIDefine.WingStage_Config  and WingUI.WingGrow_Data then
            local WingGrow_Data = WingUI.WingGrow_Data
            local MaxStage = #UIDefine.WingStage_Config
            local MaxLevel = MaxStage * 10
            -- 判断是否是最大等级和阶数
            if WingGrow_Data.WingGrow_Level == MaxLevel and WingGrow_Data.WingGrow_Stage == MaxStage then
                GUI.ButtonSetShowDisable(wingsLevelUpBtn,false) --升级按钮不可用
                GUI.ScrollBarSetPos(experienceSlider,1) -- 经验值填满
                GUI.StaticSetText(experienceSliderCurrentTxt,"Max") -- 显示最大文本
            else
                GUI.ScrollBarSetPos(experienceSlider,experience/upExperience)
                GUI.StaticSetText(experienceSliderCurrentTxt,experience.."/"..upExperience)
            end
        end


    else
        GUI.StaticSetText(GrowTxtlabal,"升阶")
        GUI.SetVisible(wingsLevelUpBtn,false)
        GUI.SetVisible(wingsUpgradeUpBtn,true)
        GUI.SetVisible(experienceSlider,false)
        GUI.SetVisible(experienceSliderCurrentTxt,false)

        -- 刷新物品升阶
        local canDegree_Elevation = false -- 物品是否满足，是否可以升阶
        -- 显示升阶材料
        if materialKindCount == 1 then
            local item2Bg = GUI.GetChild(WingsGrowDownBg,"item".. 2 .."Bg")
            GUI.SetVisible(item2Bg,true)
            GUI.SetData(item2Bg,"itemID",material2.Id)
            -- 设置背景
            GUI.ButtonSetImageID(item2Bg,quality[material2.Grade])
            -- 设置图片
            local icon = GUI.GetChild(item2Bg,"icon")
            GUI.ImageSetImageID(icon,tostring(material2.Icon))

            -- 设置数量
            local num = GUI.GetChild(item2Bg,"num")
            local haveMaterialCount = LD.GetItemCountById(material2.Id)
            GUI.StaticSetText(num,haveMaterialCount.."/"..materialCount[2])
            -- 添加小红点
            if haveMaterialCount >= materialCount[2] then
                --GUI.SetRedPointVisable(wingsUpgradeUpBtn,true)
                GUI.SetColor(num,UIDefine.WhiteColor)
            else
                GUI.SetColor(num,UIDefine.RedColor)
                --GUI.SetRedPointVisable(wingsUpgradeUpBtn,false)
            end
        elseif materialKindCount == 2 then
            -- 1
            local item1Bg = GUI.GetChild(WingsGrowDownBg,"item".. 1 .."Bg")
            GUI.SetVisible(item1Bg,true)
            GUI.SetData(item1Bg,"itemID",material1.Id)
            -- 设置背景
            GUI.ButtonSetImageID(item1Bg,quality[material1.Grade])
            -- 设置图片
            local icon = GUI.GetChild(item1Bg,"icon")
            GUI.ImageSetImageID(icon,tostring(material1.Icon))
            -- 设置数量
            local num = GUI.GetChild(item1Bg,"num")
            local haveMaterialCount = LD.GetItemCountById(material1.Id)
            GUI.StaticSetText(num,haveMaterialCount.."/"..materialCount[1])

            if haveMaterialCount >= materialCount[1] then
                canDegree_Elevation = true
            else
                canDegree_Elevation = false
            end

            -- 2
            local item2Bg = GUI.GetChild(WingsGrowDownBg,"item".. 2 .."Bg")
            GUI.SetVisible(item2Bg,true)
            GUI.SetData(item2Bg,"itemID",material2.Id)
            -- 设置背景
            GUI.ButtonSetImageID(item2Bg,quality[material2.Grade])
            -- 设置图片
            local icon = GUI.GetChild(item2Bg,"icon")
            GUI.ImageSetImageID(icon,tostring(material2.Icon))
            -- 设置数量
            local num = GUI.GetChild(item2Bg,"num")
            local haveMaterialCount = LD.GetItemCountById(material2.Id)
            GUI.StaticSetText(num,haveMaterialCount.."/"..materialCount[2])

            -- 添加小红点
            if canDegree_Elevation and haveMaterialCount >= materialCount[2]  then
                canDegree_Elevation = true
                --GUI.AddRedPoint(wingsUpgradeUpBtn,UIAnchor.TopRight)
                GUI.SetColor(num,UIDefine.WhiteColor)
            else
                GUI.SetColor(num,UIDefine.RedColor)
                canDegree_Elevation = false
            end

        else
            for i=1,3 do
                local itemBg = GUI.GetChild(WingsGrowDownBg,"item".. i .."Bg")
                GUI.SetVisible(itemBg,true)
                local material = nil
                if i == 1 then material = material1 end
                if i == 2 then material = material2 end
                if i == 3 then material = material3 end
                GUI.SetData(itemBg,"itemID",material.Id)
                -- 设置背景
                GUI.ButtonSetImageID(itemBg,quality[material.Grade])
                -- 设置图片
                local icon = GUI.GetChild(itemBg,"icon")
                GUI.ImageSetImageID(icon,tostring(material.Icon))
                -- 设置数量
                local num = GUI.GetChild(itemBg,"num")
                local haveMaterialCount = LD.GetItemCountById(material.Id)
                GUI.StaticSetText(num,haveMaterialCount.."/"..materialCount[i])

                if haveMaterialCount >= materialCount[i] then canDegree_Elevation = true end
                if i == 3 and canDegree_Elevation then
                    --GUI.AddRedPoint(wingsUpgradeUpBtn,UIAnchor.TopRight)
                    GUI.SetColor(num,UIDefine.WhiteColor)
                else
                    GUI.SetColor(num,UIDefine.RedColor)
                end

            end
        end


    end

    -- 小红点
    -- 如果羽翼已达到最大等级
    if GlobalProcessing.wing_is_max_level == true then
        -- 将升级按钮小红点隐藏
        GlobalProcessing.SetRetPoint(wingsLevelUpBtn, false)
        -- 将升阶按钮小红点隐藏
        GlobalProcessing.SetRetPoint(wingsUpgradeUpBtn, false)
        return ''
    end

    if GlobalProcessing['bagBtn'..'_Reds'] and GlobalProcessing['bagBtn'..'_Reds']['wing_upgrade'] then
        -- 如果是升阶
        if GlobalProcessing['bagBtn'..'_Reds']['wing_upgrade'] ~= 3 then

            -- 将升级按钮小红点隐藏
            GlobalProcessing.SetRetPoint(wingsLevelUpBtn, false)

            if GlobalProcessing['bagBtn'..'_Reds']['wing_upgrade'] == 1 then
                GlobalProcessing.SetRetPoint(wingsUpgradeUpBtn, true)
            else
                GlobalProcessing.SetRetPoint(wingsUpgradeUpBtn, false)
            end
            -- 如果不是升阶，而是升级
        else
            -- 将升阶按钮小红点隐藏
            GlobalProcessing.SetRetPoint(wingsUpgradeUpBtn, false)

            if GlobalProcessing['bagBtn'..'_Reds'] and GlobalProcessing['bagBtn'..'_Reds']['wing_level_up'] then
                if GlobalProcessing['bagBtn'..'_Reds']['wing_level_up'] == 1 then
                    GlobalProcessing.SetRetPoint(wingsLevelUpBtn, true)
                else
                    GlobalProcessing.SetRetPoint(wingsLevelUpBtn, false)
                end
            end

        end
    end


end
-- 二级页签 2 拥有界面刷新事件
function WingUI.RefreshSubPage2()

    local name = "时间领主" -- 羽翼名称
    local time = "永久" -- 羽翼时间

    local description = "时间领主描述" -- 描述文本

    local attrList = {
        {["attrName"]="物理攻击",["attrValue"]=10},
        {["attrName"]="法术攻击",["attrValue"]=11},
        {["attrName"]="物理防御",["attrValue"]=12},
        {["attrName"]="法术防御",["attrValue"]=13},
        {["attrName"]="血量上限",["attrValue"]=14},
    }-- 属性加成数据

    local cellCount = 36 -- 格子总数

    -- 修改数据
    if WingUI.Current_Selected_WingId and WingUI.Current_Selected_WingId ~= 0 then

        if WingUI.HaveWing_Data and WingUI.haveWingByID and  next(WingUI.haveWingByID) then
            local wing = nil
            wing = WingUI.haveWingByID[WingUI.Current_Selected_WingId]
            if wing then
                local isForever = wing.Time == -1
                if not isForever then
                    local day,house,minute,second = GlobalUtils.Get_DHMS2_BySeconds(wing.Time - CL.GetServerTickCount() )
                    time = day.."天"..house.."小时"
                end
                wing = DB.GetOnceIllusionByKey1(wing.Id)
                name = wing.Name
                name = name .. "（"..time.."）"
                description = wing.Info

                for k,v in ipairs(attrList) do
                    local attrId = wing["Att"..k]
                    local attrValue = wing["Att".. k .."Num"]
                    if attrId == 0 or attrValue == 0 then
                        v.attrName = ""
                        v.attrValue = 0
                    else
                        local attrName = DB.GetOnceAttrByKey1(attrId).ChinaName
                        v.attrName = attrName
                        v.attrValue = attrValue
                    end
                end
            end
        end
    else -- 如果没有选中的羽翼ID 或者选中的为0
        name = "未穿戴羽翼"
        description = "请挑选一件羽翼吧！！！"
        attrList = nil
    end

    local dragonWings = _gt.GetUI("dragonWings")
    -- 左边
    -- 把左上角色刷新
    WingUI.Refresh_RoleModel()
        -- 隐藏左边下面文本
    local buttonWingGrowDesBg = GUI.GetChild(dragonWings,"buttonWingGrowDesBg")
    GUI.SetVisible(buttonWingGrowDesBg,false)

    -- 把左中选择时间按钮 和购买按钮 隐藏
    local moreWingsBtn = GUI.GetChild(dragonWings,"moreWingsBtn") -- 时间按钮
    local toMallBtn = GUI.GetChild(dragonWings,"toMallBtn") -- 购买按钮
    GUI.SetVisible(moreWingsBtn,false)
    GUI.SetVisible(toMallBtn,false)
        -- 显示左边中间文本
    local upClothDesBg = GUI.GetChild(dragonWings,"upClothDesBg") -- 左中 羽翼名称文本背景
    GUI.SetVisible(upClothDesBg,true)
    local WingSelectNameBig = GUI.GetChild(upClothDesBg,"WingSelectNameBig") -- 文本
    GUI.StaticSetText(WingSelectNameBig,name)

            -- 左边文本
    local buttonWingHandBookDesBg = GUI.GetChild(dragonWings,"buttonWingHandBookDesBg")
    GUI.SetVisible(buttonWingHandBookDesBg,true)
    local WingTxtDesHasHbPage = GUI.GetChild(buttonWingHandBookDesBg,"WingTxtDesHasHbPage") -- 描述文本
    GUI.StaticSetText(WingTxtDesHasHbPage,description)

            -- 属性显示
    local EmptyDesTxt = GUI.GetChild(buttonWingHandBookDesBg,"EmptyDesTxt") -- 无字体 没有属性加成

    local attr_Count = 5 -- 加成属性数量
    local isHaveAttrList = attrList ~= nil -- 是否有加成属性
    for i=1,attr_Count do
        local AttrTxt = GUI.GetChild(buttonWingHandBookDesBg,"AttrTxt"..i) -- 属性加成字体 属性名+属性值
        if isHaveAttrList then
            GUI.SetVisible(AttrTxt,true)
            if attrList[i].attrValue > 0 then GUI.StaticSetText(AttrTxt,attrList[i].attrName.."+"..attrList[i].attrValue)
            else
                GUI.StaticSetText(AttrTxt,"")
            end
        else
            GUI.SetVisible(AttrTxt,false)
        end
    end
    if isHaveAttrList then
        GUI.SetVisible(EmptyDesTxt,false)
    else
        GUI.SetVisible(EmptyDesTxt,true)
    end

    -- 右边
        -- 隐藏
    local WingsGrowUpBg = _gt.GetUI("WingsGrowUpBg")
    GUI.SetVisible(WingsGrowUpBg,false)

    local WingsGrowDownBg = GUI.GetChild(WingsGrowUpBg,"WingsGrowDownBg")
    local wingsLevelUpBtn = GUI.GetChild(WingsGrowDownBg,"wingsLevelUpBtn") -- 升级按钮
    GUI.SetVisible(wingsLevelUpBtn,false)
    local wingsUpgradeUpBtn = GUI.GetChild(WingsGrowDownBg,"wingsUpgradeUpBtn") -- 升阶按钮
    GUI.SetVisible(wingsUpgradeUpBtn,false)
        -- 调用显示按钮函数，判断显示哪一个按钮
    WingUI.showActiveBtn()
        -- 刷新显示
    local WingScroll = _gt.GetUI("WingScroll")
    GUI.SetVisible(WingScroll,true)

    GUI.LoopScrollRectSetTotalCount(WingScroll,cellCount)
    GUI.LoopScrollRectRefreshCells(WingScroll)

end
-- 二级页签 3 外观界面刷新事件
function WingUI.RefreshSubPage3()
    local name = "时间领主" -- 羽翼名称
    local time = "永久" -- 羽翼时间

    local description = "时间领主描述" -- 描述文本

    local attrList = {
        {["attrName"]="物理攻击",["attrValue"]=10},
        {["attrName"]="法术攻击",["attrValue"]=11},
        {["attrName"]="物理防御",["attrValue"]=12},
        {["attrName"]="法术防御",["attrValue"]=13},
        {["attrName"]="血量上限",["attrValue"]=14},
    }-- 属性加成数据

    local cellCount = 36 -- 格子总数

    -- 插入数据
    local isExist_Selected_WingId = WingUI.Current_Selected_WingId and WingUI.Current_Selected_WingId ~= 0
    if isExist_Selected_WingId then
        local wing = nil

        if WingUI.foreverWingById then
            wing = WingUI.foreverWingById[WingUI.Current_Selected_WingId]
        end

        -- 如果是限时的羽翼，wing就为空，需要做些处理
        if wing == nil then

            wing = DB.GetOnceIllusionByKey1(WingUI.Current_Selected_WingId)

            -- 找到此限时羽翼对应的永久羽翼id
            -- 当前遍历到的下标
            local current_index = WingUI.Current_Selected_WingId
            local search_wing = DB.GetOnceIllusionByKey1(WingUI.Current_Selected_WingId)
            while(search_wing.Time ~= 0) do
                -- 设置限制次数
                if current_index - WingUI.Current_Selected_WingId >= max_search_times then
                    break
                end
                -- 向下找直到找到永久的羽翼
                current_index = current_index + 1
                search_wing = DB.GetOnceIllusionByKey1(current_index)
            end

            if search_wing.Time == 0 then
                WingUI.Current_Selected_WingId = current_index
                search_wing = nil
                current_index = nil
                -- 如果没找到其对应永久的羽翼
            else
                test("wingUI错误：刷新页签3外观界面时，羽翼时间有误，执行代码与Illusion表不适配")
                -- 让其选择洁白羽翼
                if WingUI.foreverWing then
                    WingUI.Current_Selected_WingId = WingUI.foreverWing[1].Id
                else
                    -- 洁白羽翼
                    WingUI.Current_Selected_WingId = 49
                end
                wing = DB.GetOnceIllusionByKey1(WingUI.Current_Selected_WingId)
            end

            -- 向下遍历，找出永久的羽翼，并使当前选中的羽翼ID变量等于其值
            --if wing.Time == 7 then -- 如果当前羽翼时限是7天
            --    if DB.GetOnceIllusionByKey1(WingUI.Current_Selected_WingId + 2).Time == 0 then
            --        WingUI.Current_Selected_WingId = WingUI.Current_Selected_WingId + 2
            --    end
            --elseif wing.Time == 30 then -- 如果当前羽翼时限是30天
            --    if DB.GetOnceIllusionByKey1(WingUI.Current_Selected_WingId + 1).Time == 0 then
            --        WingUI.Current_Selected_WingId = WingUI.Current_Selected_WingId + 1
            --    else
            --        test("wingUI错误：刷新页签3外观界面时，羽翼时间有误，执行代码与Illusion表不适配")
            --    end
            --end

        end

        if wing then
            name = wing.Name
            name = name .. "（"..time.."）"
            description = wing.Info
            for k,v in ipairs(attrList) do
                local attrId = wing["Att"..k]
                local attrValue = wing["Att".. k .."Num"]
                if attrId == 0 or attrValue == 0 then
                    v.attrName = ""
                    v.attrValue = 0
                else
                    local attrName = DB.GetOnceAttrByKey1(attrId).ChinaName
                    v.attrName = attrName
                    v.attrValue = attrValue
                end
            end
        end
    end

    local dragonWings = _gt.GetUI("dragonWings")
    -- 左边
    -- 把左上角色刷新
    WingUI.Refresh_RoleModel()
    -- 隐藏文本
    local upClothDesBg = GUI.GetChild(dragonWings,"upClothDesBg")
    GUI.SetVisible(upClothDesBg,false)

    local buttonWingGrowDesBg = GUI.GetChild(dragonWings,"buttonWingGrowDesBg")
    GUI.SetVisible(buttonWingGrowDesBg,false)
    -- 显示左边
    local moreWingsBtn = GUI.GetChild(dragonWings,"moreWingsBtn") -- 时间选择按钮底框
    GUI.SetVisible(moreWingsBtn,true)
    local moreWingNameText = GUI.GetChild(moreWingsBtn,"moreWingNameText") -- 时间选择按钮上的文本
    GUI.StaticSetText(moreWingNameText,name)

    local toMallBtn = GUI.GetChild(dragonWings,"toMallBtn") -- 购买按钮
    GUI.SetVisible(toMallBtn,true)

    -- 如果显示的是洁白羽翼
    if isExist_Selected_WingId and DB.GetOnceIllusionByKey1(WingUI.Current_Selected_WingId).Name == "洁白羽翼" then
        GUI.SetVisible(toMallBtn,false)
    end

    -- 左边文本
    local buttonWingHandBookDesBg = GUI.GetChild(dragonWings,"buttonWingHandBookDesBg")
    GUI.SetVisible(buttonWingHandBookDesBg,true)
    local WingTxtDesHasHbPage = GUI.GetChild(buttonWingHandBookDesBg,"WingTxtDesHasHbPage") -- 描述文本
    GUI.StaticSetText(WingTxtDesHasHbPage,description)

    -- 属性显示
    local EmptyDesTxt = GUI.GetChild(buttonWingHandBookDesBg,"EmptyDesTxt")
    local attr_Count = 5 -- 加成属性数量
    local isHaveAttrList = attrList ~= nil -- 是否有加成属性
    for i=1,attr_Count do
        local AttrTxt = GUI.GetChild(buttonWingHandBookDesBg,"AttrTxt"..i) -- 属性加成字体 属性名+属性值
        if isHaveAttrList then
            GUI.SetVisible(AttrTxt,true)
            if attrList[i].attrValue > 0 then GUI.StaticSetText(AttrTxt,attrList[i].attrName.."+"..attrList[i].attrValue)
            else
                GUI.StaticSetText(AttrTxt,"")
            end
        else
            GUI.SetVisible(AttrTxt,false)
        end
    end
    if isHaveAttrList then
        GUI.SetVisible(EmptyDesTxt,false)
    else
        GUI.SetVisible(EmptyDesTxt,true)
    end

    -- 右边
    -- 隐藏
    local WingsGrowUpBg = _gt.GetUI("WingsGrowUpBg")
    GUI.SetVisible(WingsGrowUpBg,false)

    local WingsGrowDownBg = GUI.GetChild(WingsGrowUpBg,"WingsGrowDownBg")
    local wingsLevelUpBtn = GUI.GetChild(WingsGrowDownBg,"wingsLevelUpBtn") -- 升级按钮
    GUI.SetVisible(wingsLevelUpBtn,false)
    local wingsUpgradeUpBtn = GUI.GetChild(WingsGrowDownBg,"wingsUpgradeUpBtn") -- 升阶按钮
    GUI.SetVisible(wingsUpgradeUpBtn,false)
    -- 调用显示按钮函数，判断显示哪一个按钮
    WingUI.showActiveBtn()
    -- 刷新显示
    local WingScroll = _gt.GetUI("WingScroll")
    GUI.SetVisible(WingScroll,true)

    GUI.LoopScrollRectSetTotalCount(WingScroll,cellCount)
    GUI.LoopScrollRectRefreshCells(WingScroll)

end
-- 显示 获取/穿戴/卸下 某个按钮
function WingUI.showActiveBtn()
    -- 隐藏按钮
    local wnd = GUI.GetWnd("BagUI")
    local panelBg = GUI.GetChild(wnd,"panelBg")
    local SaveWingsBtn = GUI.GetChild(panelBg,"SaveWingsBtn") -- 穿戴
    GUI.SetVisible(SaveWingsBtn,false)
    local unlockWingsBtn = GUI.GetChild(panelBg,"unlockWingsBtn") -- 获取
    GUI.SetVisible(unlockWingsBtn,false)
    local unWearWingsBtn = GUI.GetChild(panelBg,"unWearWingsBtn") -- 卸下
    GUI.SetVisible(unWearWingsBtn,false)

    -- 判断是否拥有此羽翼
    if WingUI.Current_Selected_WingId and WingUI.Current_Selected_WingId ~= 0 then
        if WingUI.HaveWing_Data and WingUI.haveWingByID and next(WingUI.haveWingByID) then
            local wing = WingUI.haveWingByID[WingUI.Current_Selected_WingId]
            if wing then -- 如果有此羽翼
                -- 判断是显示穿戴还是卸下
                if WingUI.CurrentUsedWingId and WingUI.CurrentUsedWingId ~= 0 and WingUI.CurrentUsedWingId == wing.Id then
                    -- 将卸下按钮变为可用
                    GUI.ButtonSetShowDisable(unWearWingsBtn,true)
                    GUI.SetVisible(unWearWingsBtn,true) --显示卸下
                else
                    GUI.SetVisible(SaveWingsBtn,true)  -- 显示穿戴
                end
            else
                GUI.SetVisible(unlockWingsBtn,true) -- 显示获取
            end
        end
    else -- 如果为0或空 选中了未穿戴羽翼
        -- 判断是穿戴还是卸下
        if WingUI.CurrentUsedWingId == nil or WingUI.CurrentUsedWingId == 0 then
            GUI.SetVisible(unWearWingsBtn,true) --显示卸下
            -- 将卸下按钮变为不可用
            GUI.ButtonSetShowDisable(unWearWingsBtn,false)
        else
            -- 将卸下按钮变为可用
            GUI.ButtonSetShowDisable(unWearWingsBtn,true)
            GUI.SetVisible(SaveWingsBtn,true)  -- 显示穿戴
        end

    end
end

-- 创建左边页面
function WingUI.CreateLeftPage(WingPage)

    -- 龙背景
    local dragonWings = GUI.ImageCreate( WingPage, "dragonWings", "1800400230", -252.71, -115.8, false);
    SetAnchorAndPivot(dragonWings, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(dragonWings,"dragonWings")

    -- 创建左边模型
    local shadow = GUI.ImageCreate(dragonWings, "shadow", "1800400240", 0, 110); -- 父类

    local model = GUI.RawImageCreate(shadow, false, "model", "", -33, -120, 3,false,520,520)
    model:RegisterEvent(UCE.Drag)
    model:RegisterEvent(UCE.PointerClick)
    GUI.AddToCamera(model);
    GUI.RawImageSetCameraConfig(model, "(0.15,1.55,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,5,0.01,1.45,1E-05");

    local roleModel = GUI.RawImageChildCreate(model, false, "WingPage_RoleModel", "", 0, 0)
    _gt.BindName(roleModel, "WingPage_roleModel");
    GUI.BindPrefabWithChild(model, GUI.GetGuid(roleModel));
    ModelItem.BindSelfRole(roleModel,eRoleMovement.STAND_W1)

    -------------------------------------------- 左中 羽翼名称+时间文本 start

    local upClothDesBg = GUI.ImageCreate( dragonWings, "upClothDesBg", "1801200030", 0, 157.9, false);
    SetAnchorAndPivot(dragonWings, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(upClothDesBg,false)

    local HasPageWingNameText = GUI.CreateStatic( upClothDesBg, "WingSelectNameBig", "时间领主（xx）", -5, 0, 445.89, 76.1, "system", true, false);
    GUI.StaticSetFontSize(HasPageWingNameText, 24)

    GUI.StaticSetAlignment(HasPageWingNameText, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(HasPageWingNameText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(HasPageWingNameText, colorDark);

    -------------------------------------------- 左中 羽翼名称+时间文本 end

    -- I 图标
    local addPointTipBtn = GUI.ButtonCreate( dragonWings, "addPointTipBtn", "1800702030", 108.5, -23, Transition.ColorTint, "")
    SetAnchorAndPivot(addPointTipBtn, UIAnchor.TopRight, UIAroundPivot.Center)
    GUI.RegisterUIEvent(addPointTipBtn, UCE.PointerClick, "WingUI", "OnWingsTipBtnClick")

    -------------------------------------------- 左中 羽翼名称+时间按钮   and  购买按钮  start

    local moreWingsBtn = GUI.ButtonCreate( dragonWings, "moreWingsBtn", "1801202030", -5.2, 162.79, Transition.ColorTint, "",277, 44, false);
    GUI.RegisterUIEvent(moreWingsBtn, UCE.PointerClick, "WingUI", "OnWingsHBMoreBtnClick")
    local moreWingNameText = GUI.CreateStatic( moreWingsBtn, "moreWingNameText", "时间领主（7天）", -15.8, 0, 264.3, 50, "system", true, false);
    GUI.StaticSetFontSize(moreWingNameText, 24)
    GUI.SetColor(moreWingNameText, colorDark);
    GUI.StaticSetAlignment(moreWingNameText, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(moreWingNameText, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(moreWingNameText,"moreWingNameText")


    local toMallBtn = GUI.ButtonCreate( dragonWings, "toMallBtn", "1800402110", 195.8, 162.79, Transition.ColorTint, "购买",100, 45, false);
    GUI.ButtonSetTextFontSize(toMallBtn, 24);
    GUI.ButtonSetTextColor(toMallBtn, colorDark);
    GUI.RegisterUIEvent(toMallBtn, UCE.PointerClick, "WingUI", "OnWingHBToMallBtnClick")
    _gt.BindName(toMallBtn,"toMallBtn")

    -------------------------------------------- 左中 羽翼名称+时间按钮   and  购买按钮  end


    ------------------------------------------------------ 左下 成长界面部分 start
    local buttonClothDesBg = GUI.ImageCreate( dragonWings, "buttonWingGrowDesBg", "1801200030", 0, 287.6, false, 539.6, 192.5); -- 父类
    GUI.SetVisible(buttonClothDesBg,false)
    SetAnchorAndPivot(dragonWings, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(buttonClothDesBg,"buttonWingGrowDesBg")

    local labelTxt1 = GUI.CreateStatic( buttonClothDesBg, "DesTxtlabal", "等级", 69.2, -52.4, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt1, 22);
    GUI.StaticSetAlignment(labelTxt1, TextAnchor.MiddleLeft);
    GUI.SetColor(labelTxt1, colorDark);

    local labelTxt2 = GUI.CreateStatic( buttonClothDesBg, "DesTxtlabal2", "描述", -185.6, 4, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt2, 22);
    GUI.StaticSetAlignment(labelTxt2, TextAnchor.MiddleLeft);
    GUI.SetColor(labelTxt2, colorDark);

    local labelTxt3 = GUI.CreateStatic( buttonClothDesBg, "DesTxtlabal3", "品阶", -185.6, -52.4, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt3, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt3, 22);
    GUI.StaticSetAlignment(labelTxt3, TextAnchor.MiddleLeft);
    GUI.SetColor(labelTxt3, colorDark);

    local WingTxtLevelHas = GUI.CreateStatic( buttonClothDesBg, "WingTxtLevelHas", "时间领主的羽翼等级", 320.3, -26.97, 472.7, 73.4, "system", true, false);
    SetAnchorAndPivot(WingTxtLevelHas, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(WingTxtLevelHas, 20);
    GUI.StaticSetAlignment(WingTxtLevelHas, TextAnchor.UpperLeft);
    GUI.SetColor(WingTxtLevelHas, yellowTextColor);

    local WingTxtGradeHas = GUI.CreateStatic( buttonClothDesBg, "WingTxtGradeHas", "0品阶", 67.7, -26.97, 472.7, 73.4, "system", true, false);
    SetAnchorAndPivot(WingTxtGradeHas, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(WingTxtGradeHas, 20);
    GUI.StaticSetAlignment(WingTxtGradeHas, TextAnchor.UpperLeft);
    GUI.SetColor(WingTxtGradeHas, yellowTextColor);

    local WingTxtDesGrow = GUI.CreateStatic( buttonClothDesBg, "WingTxtDesGrow", "时间领主的羽翼描述", 9.94, 63, 472.7, 73.4, "system", true, false);
    SetAnchorAndPivot(WingTxtDesGrow, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(WingTxtDesGrow, 20);
    GUI.StaticSetAlignment(WingTxtDesGrow, TextAnchor.UpperLeft);
    GUI.SetColor(WingTxtDesGrow, yellowTextColor);

    ------------------------------------------------------ 左下 成长界面部分 end

    -----------------------------------------------------左下 拥有界面部分 start
    local buttonClothDesBg = GUI.ImageCreate( dragonWings, "buttonWingHandBookDesBg", "1801200030", 0, 287.6, false, 539.6, 192.5);
    SetAnchorAndPivot(dragonWings, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(buttonClothDesBg,"buttonWingHandBookDesBg")

    local labelTxt1 = GUI.CreateStatic( buttonClothDesBg, "DesTxtlabal", "描述", -183.2, -70.8, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt1, 22);
    GUI.StaticSetAlignment(labelTxt1, TextAnchor.MiddleLeft);
    GUI.SetColor(labelTxt1, colorDark);


    local labelTxt2 = GUI.CreateStatic( buttonClothDesBg, "DesTxtlabal2", "附加属性", -183, 12.4, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt2, 22);
    GUI.StaticSetAlignment(labelTxt2, TextAnchor.MiddleLeft);
    GUI.SetColor(labelTxt2, colorDark);

    local WingTxtDesHasHbPage = GUI.CreateStatic( buttonClothDesBg, "WingTxtDesHasHbPage", "时间领主的羽翼描述 外观", -2, -12.1, 453, 73.4, "system", true, false);
    SetAnchorAndPivot(WingTxtDesHasHbPage, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(WingTxtDesHasHbPage, 20);
    GUI.StaticSetAlignment(WingTxtDesHasHbPage, TextAnchor.UpperLeft);
    GUI.SetColor(WingTxtDesHasHbPage, yellowTextColor);

    local labelTxt4 = GUI.CreateStatic( buttonClothDesBg, "EmptyDesTxt", "无", -220.56, 44.1, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt4, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt4, 20);
    GUI.StaticSetAlignment(labelTxt4, TextAnchor.MiddleCenter);
    GUI.SetColor(labelTxt4, colorDark);

    local AttrTxt1 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt1", "物攻+30", -152.5, 57.8, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt1, 20);
    GUI.StaticSetAlignment(AttrTxt1, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt1, greenTextColor);

    local AttrTxt2 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt2", "法攻+30", 19.4, 57.8, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt2, 20);
    GUI.StaticSetAlignment(AttrTxt2, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt2, greenTextColor);

    local AttrTxt3 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt3", "抗封印+60", 179.6, 57.8, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt3, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt3, 20);
    GUI.StaticSetAlignment(AttrTxt3, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt3, greenTextColor);

    local AttrTxt4 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt4", "抗封印+60", -152.5, 85.4, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt4, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt4, 20);
    GUI.StaticSetAlignment(AttrTxt4, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt4, greenTextColor);

    local AttrTxt5 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt5", "抗封印+60", 19.4, 85.4, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt5, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt5, 20);
    GUI.StaticSetAlignment(AttrTxt5, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt5, greenTextColor);

    -----------------------------------------------------左下 拥有界面部分 end

end

-- 创建右边的页面
function WingUI.CreateRightPage(WingPage,panelBg)

    ------------------------------------------------------------- 成长二级页签界面  右边上部分
    local WingsGrowUpBg = GUI.ImageCreate( WingPage, "WingsGrowUpBg", "1800400450", 267.3, -88.2, false, 475.8, 272.2); -- 上 父类
    SetAnchorAndPivot(WingsGrowUpBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(WingsGrowUpBg,"WingsGrowUpBg")

    local labelTxt1 = GUI.CreateStatic( WingsGrowUpBg, "DesTxtlabal", "属性", 0, -103.88, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt1, 27);
    GUI.StaticSetAlignment(labelTxt1, TextAnchor.MiddleCenter);
    GUI.SetColor(labelTxt1, colorDark);

    local leftNarrow = GUI.ImageCreate( WingsGrowUpBg, "leftNarrow", "1800800050", 33.66, 26.51)
    SetAnchorAndPivot(leftNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local rightNarrow = GUI.ImageCreate( WingsGrowUpBg, "rightNarrow", "1800800060", 283.6, 26.51)
    SetAnchorAndPivot(rightNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 创建属性值
    WingUI.CreateWingGrowUpPage(WingsGrowUpBg);

    ------------------------------------------------------------- 成长二级页签界面  右边下部分
    local WingsGrowDownBg = GUI.ImageCreate( WingsGrowUpBg, "WingsGrowDownBg", "1800400450", 0, 145.5, false, 477.8, 166.6); -- 下 父类
    SetAnchorAndPivot(WingsGrowDownBg, UIAnchor.Center, UIAroundPivot.Top)
    -- I 图标
    local WingsTipBtn = GUI.ButtonCreate( WingsGrowDownBg, "WingsTipBtn", "1800702030", -25.81, 30, Transition.ColorTint, "")
    SetAnchorAndPivot(WingsTipBtn, UIAnchor.TopRight, UIAroundPivot.Center)
    GUI.RegisterUIEvent(WingsTipBtn, UCE.PointerClick, "WingUI", "OnWingEnhanceTipBtnClick")

    local GrowTxtlabal = GUI.CreateStatic( WingsGrowDownBg, "GrowTxtlabal", "升级", 0, 31.1, 100, 40, "system", true, false);
    SetAnchorAndPivot(GrowTxtlabal, UIAnchor.Top, UIAroundPivot.Center)
    GUI.StaticSetFontSize(GrowTxtlabal, 27);
    GUI.StaticSetAlignment(GrowTxtlabal, TextAnchor.MiddleCenter);
    GUI.SetColor(GrowTxtlabal, colorDark);

    local experienceSlider = GUI.ScrollBarCreate( WingsGrowDownBg, "experienceSlider", "", "1800408160", "1800408110", 0, 18, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    local silderFillSize = Vector2.New(420, 30);
    GUI.ScrollBarSetFillSize(experienceSlider, silderFillSize);
    GUI.ScrollBarSetBgSize(experienceSlider, silderFillSize)
    SetAnchorAndPivot(experienceSlider, UIAnchor.Center, UIAroundPivot.Left)
    local experienceSliderCurrentTxt = GUI.CreateStatic( WingsGrowDownBg, "experienceSliderCurrentTxt", "3200/3200", 0, 18, 300, 44, "system", true, false);
    SetAnchorAndPivot(experienceSliderCurrentTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(experienceSliderCurrentTxt, 20);
    GUI.StaticSetAlignment(experienceSliderCurrentTxt, TextAnchor.MiddleCenter);

    local leftNarrow = GUI.ImageCreate( WingsGrowDownBg, "leftNarrow2", "1800800050", 33.66, 24.95)
    SetAnchorAndPivot(leftNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local rightNarrow = GUI.ImageCreate( WingsGrowDownBg, "rightNarrow2", "1800800060", 283, 24.95)
    SetAnchorAndPivot(rightNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local wingsLevelUpBtn = GUI.ButtonCreate( WingsGrowDownBg, "wingsLevelUpBtn", "1800402080", 0, 103.4, Transition.ColorTint, "升级", 140.2, 47, false);
    GUI.SetIsOutLine(wingsLevelUpBtn, true);
    GUI.ButtonSetTextFontSize(wingsLevelUpBtn, 26);
    GUI.ButtonSetTextColor(wingsLevelUpBtn, colorwrite);
    GUI.SetOutLine_Color(wingsLevelUpBtn, coloroutline);
    GUI.SetOutLine_Distance(wingsLevelUpBtn, 1);
    GUI.RegisterUIEvent(wingsLevelUpBtn, UCE.PointerClick, "WingUI", "OnWingsLevelUpBtnClick");
    _gt.BindName(wingsLevelUpBtn, 'wingsLevelUpBtn')

    local wingsUpgradeUpBtn = GUI.ButtonCreate( WingsGrowDownBg, "wingsUpgradeUpBtn", "1800402080", 0, 103.4, Transition.ColorTint, "升阶", 140.2, 47, false);
    GUI.SetIsOutLine(wingsUpgradeUpBtn, true);
    GUI.ButtonSetTextFontSize(wingsUpgradeUpBtn, 26);
    GUI.ButtonSetTextColor(wingsUpgradeUpBtn, colorwrite);
    GUI.SetOutLine_Color(wingsUpgradeUpBtn, coloroutline);
    GUI.SetOutLine_Distance(wingsUpgradeUpBtn, 1);
    GUI.RegisterUIEvent(wingsUpgradeUpBtn, UCE.PointerClick, "WingUI", "OnWingsUpgradeBtnClick");
    --GUI.AddRedPoint(wingsUpgradeUpBtn,UIAnchor.TopRight)
    --GUI.SetRedPointVisable(wingsUpgradeUpBtn,false)
    _gt.BindName(wingsUpgradeUpBtn, 'wingsUpgradeUpBtn')


    -- 升阶材料框
    local positionX = -160
    for i = 1,3 do
        local item1Bg = GUI.ButtonCreate( WingsGrowDownBg, "item"..i.."Bg", quality[3], positionX, 18.3, Transition.None);
        SetAnchorAndPivot(item1Bg, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetVisible(item1Bg,false)
        --GUI.SetData(item1Bg, "ItemIndex", tostring(i));
        GUI.RegisterUIEvent(item1Bg, UCE.PointerClick, "WingUI", "OnWingUpgradeItemClick")

        local icon = GUI.ImageCreate( item1Bg, "icon", "1900000000", 0, 0, false, 60, 60);
        GUI.SetWidth(icon,80)
        GUI.SetHeight(icon,81)


        local num = GUI.CreateStatic( item1Bg, "num", "0/0", -7, -18, 100, 30, "system", true);
        GUI.StaticSetFontSize(num, 20);
        SetAnchorAndPivot(num, UIAnchor.BottomRight, UIAroundPivot.Right)
        GUI.SetIsOutLine(num, true)
        GUI.SetOutLine_Distance(num, 1)
        GUI.SetOutLine_Color(num, colorblack);
        GUI.StaticSetAlignment(num,TextAnchor.LowerRight)

        positionX = positionX + 160
    end

    -- 右边按钮
    local SaveWingsBtn = GUI.ButtonCreate( WingPage, "SaveWingsBtn", "1800402080", 451.8, 268, Transition.ColorTint, "穿戴", 140.2, 47, false);
    GUI.SetIsOutLine(SaveWingsBtn, true);
    GUI.ButtonSetTextFontSize(SaveWingsBtn, 26);
    GUI.ButtonSetTextColor(SaveWingsBtn, colorwrite);
    GUI.SetOutLine_Color(SaveWingsBtn, coloroutline);
    GUI.SetOutLine_Distance(SaveWingsBtn, 1);
    GUI.RegisterUIEvent(SaveWingsBtn, UCE.PointerClick, "WingUI", "OnSaveWingBtnClick");

    local unlockWingsBtn = GUI.ButtonCreate( WingPage, "unlockWingsBtn", "1800402080", 451.8, 268, Transition.ColorTint, "获取", 140.2, 47, false);
    GUI.SetIsOutLine(unlockWingsBtn, true);
    GUI.ButtonSetTextFontSize(unlockWingsBtn, 26);
    GUI.ButtonSetTextColor(unlockWingsBtn, colorwrite);
    GUI.SetOutLine_Color(unlockWingsBtn, coloroutline);
    GUI.SetOutLine_Distance(unlockWingsBtn, 1);
    GUI.RegisterUIEvent(unlockWingsBtn, UCE.PointerClick, "WingUI", "OnUnlockWingsBtnClick");

    local unWearWingsBtn = GUI.ButtonCreate( WingPage, "unWearWingsBtn", "1800402080", 451.8, 268, Transition.ColorTint, "卸下", 140.2, 47, false);
    GUI.SetIsOutLine(unWearWingsBtn, true);
    GUI.ButtonSetTextFontSize(unWearWingsBtn, 26);
    GUI.ButtonSetTextColor(unWearWingsBtn, colorwrite);
    GUI.SetOutLine_Color(unWearWingsBtn, coloroutline);
    GUI.SetOutLine_Distance(unWearWingsBtn, 1);
    GUI.RegisterUIEvent(unWearWingsBtn, UCE.PointerClick, "WingUI", "OnUnWearWingBtnClick");

    ------------------------------------------ 右边 物品栏
    -- 时装物品栏
    local WingScroll = GUI.LoopScrollRectCreate(WingPage, "WingScroll", 265, 0, 490, 450,
            "WingUI", "Create_WingIconPool",
            "WingUI", "Refresh_WingScroll",
            0, false, Vector2.New(80, 80), cntPerLine, UIAroundPivot.Top, UIAnchor.Top);
    GUI.ScrollRectSetChildSpacing(WingScroll, Vector2.New(1, 1));
    _gt.BindName(WingScroll, "WingScroll");
    GUI.SetVisible(WingScroll,false)

end

-- 创建 羽翼加成属性值展示
local attributeList2 = {
    { "物攻", "phyAttack", "1800407040" },
    { "物防", "phyDefence", "1800407050" },
    { "物暴", "phyBurstRate", "1800407060" },
    { "闪避", "miss", "1800407100" },
    { "速度", "speed", "1800407120" },

    { "法攻", "magicAttack", "1800407070" },
    { "法防", "magDefence", "1800407080" },
    { "法暴", "magBurstRate", "1800407090" },
    { "命中", "hit", "1800407110" },
}
WingUI.attributeNumber = nil  -- 用来修改其属性值
function WingUI.CreateWingGrowUpPage(attributePageBG2)
    local labels = {}
    for i = 1, 5 do
        local tempSprite = GUI.ImageCreate( attributePageBG2, attributeList2[i][2] .. "Icon", attributeList2[i][3], 40, 30 + i * 40);
        SetAnchorAndPivot(tempSprite, UIAnchor.TopLeft, UIAroundPivot.Center)
        local label = GUI.CreateStatic( attributePageBG2, attributeList2[i][2] .. "label", attributeList2[i][1], 109.5, 30 + i * 40, 63.9, 40.4, "system", true, false);
        SetAnchorAndPivot(label, UIAnchor.TopLeft, UIAroundPivot.Center)
        GUI.StaticSetFontSize(label, 22);
        GUI.SetColor(label, colorDark);

        local currentTxt = GUI.CreateStatic( label, attributeList2[i][2] .. "Txtlabel", "0", 98.7, 0, 100, 32.7, "system", true, false);
        GUI.StaticSetAlignment(currentTxt, TextAnchor.MiddleLeft);
        SetAnchorAndPivot(currentTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(currentTxt, 22);
        GUI.SetColor(currentTxt, yellowTextColor);
        labels[i] = currentTxt;
    end

    for i = 6, #attributeList2 do
        local tempSprite = GUI.ImageCreate( attributePageBG2, attributeList2[i][2] .. "Icon", attributeList2[i][3], 290, 30 + (i - 5) * 40);
        SetAnchorAndPivot(tempSprite, UIAnchor.TopLeft, UIAroundPivot.Center)
        local label = GUI.CreateStatic( attributePageBG2, attributeList2[i][2] .. "label", attributeList2[i][1], 362.2, 30 + (i - 5) * 40, 63.9, 40.4, "system", true);
        SetAnchorAndPivot(label, UIAnchor.TopLeft, UIAroundPivot.Center)
        GUI.StaticSetFontSize(label, 22);
        GUI.SetColor(label, colorDark);

        local currentTxt = GUI.CreateStatic( label, attributeList2[i][2] .. "Txtlabel", "0", 98.7, 0, 100, 32.7, "system", true, false);
        GUI.SetAnchor(currentTxt, UIAnchor.Center);
        GUI.StaticSetAlignment(currentTxt, TextAnchor.MiddleLeft);
        GUI.SetPivot(currentTxt, UIAroundPivot.Center);
        GUI.StaticSetFontSize(currentTxt, 22);
        GUI.SetColor(currentTxt, yellowTextColor);
        labels[i] = currentTxt;
    end
    WingUI.attributeNumber = {
        labels[1],
        labels[6],
        labels[2],
        labels[7],
        labels[3],
        labels[8],
        labels[4],
        labels[9],
        labels[5],
    }

end

WingUI.foreverWing = nil -- 永久的羽翼列表
WingUI.foreverWingById = nil -- 永久羽翼列表 通过id获取,
WingUI.haveWingByID = nil -- 拥有的羽翼 通过id获取
function WingUI.InitData()
    -- 将永久的羽翼从表中拿出来
    WingUI.foreverWing = {}
    WingUI.foreverWingById = {}
    WingUI.haveWingByID = {}

    local allClothesId = DB.GetIllusionAllKey1s()
    for i=0,allClothesId.Count-1 do
        local clothes = DB.GetOnceIllusionByKey1(allClothesId[i])
        if clothes.Time == 0 and (clothes.Type == 2 ) then
            table.insert(WingUI.foreverWing,clothes)
            -- 不应该存储整个对象，太占内存。只存储所有永久羽翼的id就够了，但已经写完..
            WingUI.foreverWingById[clothes.Id] = clothes
        end
    end
    table.sort(WingUI.foreverWing,WingUI._sort_forever_wing_data)
    WingUI.foreverWing["Count"] = #WingUI.foreverWing

    -- 如果请求服务器 拥有的羽翼数据存在
    if WingUI.HaveWing_Data then
        for k,v in ipairs(WingUI.HaveWing_Data) do
            WingUI.haveWingByID[v.Id] = v
        end
        WingUI.haveWingByID["Count"] = #WingUI.HaveWing_Data
    end

end

-- 对永久羽翼数据进行排序
function WingUI._sort_forever_wing_data(a,b)
    return a.Id < b.Id
end

-- 创建物品格子 scroll
function WingUI.Create_WingIconPool()

    local Count = 0 -- 羽翼数量
    if WingUI.foreverWing and next(WingUI.foreverWing) then
        Count = WingUI.foreverWing.Count
    end

    local WingScroll = _gt.GetUI("WingScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(WingScroll);
    local WingIcon = ItemIcon.Create(WingScroll, "WingIcon"..curCount, 0, 0)

    -- 为物品框添加其他图片
    if curCount < Count then -- curCount从零开始
        -- 插入品质框
        GUI.ItemCtrlSetElementValue(WingIcon,eItemIconElement.Border,"1800400320")
        -- 插入选择框
        local selectedBox = GUI.ImageCreate(WingIcon,"selectedBox","1800400280",0,0)
        SetAnchorAndPivot(selectedBox,UIAnchor.Center,UIAroundPivot.Center)
        GUI.SetVisible(selectedBox,false)
        -- 插入锁图片
        local lock = GUI.ImageCreate(WingIcon,"lock","1800400070",0,0, false, 65, 66)
        SetAnchorAndPivot(lock,UIAnchor.Center,UIAroundPivot.Center)
        GUI.SetVisible(lock,false)
        -- 插入已装备时装图片
        GUI.ItemCtrlSetElementValue(WingIcon,eItemIconElement.LeftTopSp,"1801207010")
        local alreadyEquipped = GUI.ItemCtrlGetElement(WingIcon,eItemIconElement.LeftTopSp)
        GUI.SetVisible(alreadyEquipped,false)
        -- 插入右上的闹钟图标
        GUI.ItemCtrlSetElementValue(WingIcon,eItemIconElement.RightTopSp,"1800408530")
        GUI.ItemCtrlSetElementRect(WingIcon,eItemIconElement.RightTopSp,8,7)
        local clock = GUI.ItemCtrlGetElement(WingIcon,eItemIconElement.RightTopSp)
        GUI.SetVisible(clock,false)

    end

    return WingIcon;
end
-- 刷新羽翼格子
function WingUI.Refresh_WingScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local itemIcon = GUI.GetByGuid(guid);

    -- 减少隐藏执行次数
    if WingUI.foreverWing and WingUI.foreverWing.Count-1 >= index then
        WingUI.HideCellContent(itemIcon) -- 隐藏格子内其他图标
    end

    if WingUI.WingSubTabIndex == 3 then
        if WingUI.foreverWing  == nil or next(WingUI.foreverWing) == nil then
            return
        end

        -- 注册点击事件
        if WingUI.foreverWing.Count -1 >= index then
            GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "WingUI", "OnWingUIItemClick");
        end

        local wing = WingUI.foreverWing[index+1] -- 羽翼对象
        local isSelected =  false -- 是否选中
        local isHave = false -- 是否拥有
        local isEquipped = false -- 是否装备


        if wing then

            -- 存入数据用于点击事件
            GUI.SetData(itemIcon,"wingId",wing.Id)

            if WingUI.Current_Selected_WingId then isSelected = WingUI.Current_Selected_WingId == wing.Id end
            if WingUI.CurrentUsedWingId then isEquipped = WingUI.CurrentUsedWingId == wing.Id end

            -- 判定是否拥有
            if WingUI.HaveWing_Data and WingUI.haveWingByID then
                if WingUI.haveWingByID[wing.Id] then isHave = true
                else
                    isHave = false
                end
            end

            -- 插入羽翼图片
            GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,wing.Icon)
            GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, 0, 70, 71)
            -- 插入品质背景
            GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400320")
            -- 显示是否选中 选中框
            if isSelected then
                local selectedBox = GUI.GetChild(itemIcon,"selectedBox")
                if selectedBox then GUI.SetVisible(selectedBox,true) end
            end
            -- 是否显示锁图片
            if not isHave then
                local lock = GUI.GetChild(itemIcon,"lock")
                if lock then GUI.SetVisible(lock,true) end
                -- 控制灰色
                GUI.ItemCtrlSetIconGray(itemIcon, true)
            else
                GUI.ItemCtrlSetIconGray(itemIcon, false)
            end
            -- 显示已装备图片
            if isEquipped then
                local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                if alreadyEquipped then GUI.SetVisible(alreadyEquipped,true) end
            end
        end
    end

    if WingUI.WingSubTabIndex == 2 then
        if WingUI.HaveWing_Data == nil or WingUI.haveWingByID == nil or next(WingUI.haveWingByID) == nil then
            return
        end
        -- 注册点击事件
        if WingUI.haveWingByID.Count >= index then
            GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "WingUI", "OnWingUIItemClick");
        end

        local wing = WingUI.HaveWing_Data[index]
        local isSelected = false
        local isEquipped = false
        local isForever = false

        -- 如果是“未穿戴羽翼”
        if index == 0 then

            -- 存入数据用于点击事件
            GUI.SetData(itemIcon,"wingId",0)

             isSelected = WingUI.Current_Selected_WingId == nil or WingUI.Current_Selected_WingId == 0
             isEquipped = WingUI.CurrentUsedWingId == nil or WingUI.CurrentUsedWingId == 0

            -- 插入羽翼图片
            GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,"1901020060")
            -- 插入品质背景
            GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400320")
            -- 显示是否选中 选中框
            if isSelected then
                local selectedBox = GUI.GetChild(itemIcon,"selectedBox")
                if selectedBox then GUI.SetVisible(selectedBox,true) end
            end
            -- 显示已装备图片
            if isEquipped then
                local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                if alreadyEquipped then GUI.SetVisible(alreadyEquipped,true) end
            end
        else -- 如果index不等于0
            if wing then
                -- 存入数据用于点击事件
                GUI.SetData(itemIcon,"wingId",wing.Id)

                if WingUI.Current_Selected_WingId then  isSelected = WingUI.Current_Selected_WingId == wing.Id end
                if WingUI.CurrentUsedWingId then isEquipped = WingUI.CurrentUsedWingId == wing.Id end
                isForever  = wing.Time == -1

                wing = DB.GetOnceIllusionByKey1(wing.Id)
                -- 插入羽翼图片
                GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,wing.Icon)
                -- 显示是否选中 选中框
                if isSelected then
                    local selectedBox = GUI.GetChild(itemIcon,"selectedBox")
                    if selectedBox then GUI.SetVisible(selectedBox,true) end
                end
                -- 显示已装备图片
                if isEquipped then
                    local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                    if alreadyEquipped then GUI.SetVisible(alreadyEquipped,true) end
                end
                if isForever then
                    -- 插入品质背景
                    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400320")
                else
                    -- 显示时钟图片
                    local clock = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.RightTopSp)
                    GUI.SetVisible(clock,true)
                end

            end
        end

    end

end
-- 隐藏格子内其他图标
function WingUI.HideCellContent(itemIcon)
    if itemIcon == nil then return end
    -- 羽翼图片
    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,"1800499999")

    -- 品质背景
    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400330")
    -- 选中框
    local selectedBox = GUI.GetChild(itemIcon,"selectedBox")
    if selectedBox then GUI.SetVisible(selectedBox,false) end
    -- 锁图片
    local lock = GUI.GetChild(itemIcon,"lock")
    if lock then GUI.SetVisible(lock,false) end
    -- 取消灰色阴影
    GUI.ItemCtrlSetIconGray(itemIcon, false)
    -- 已装备图片
    local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
    if alreadyEquipped then GUI.SetVisible(alreadyEquipped,false) end
    -- 时钟图片
    local clock = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.RightTopSp)
    if clock then GUI.SetVisible(clock,false) end
    -- 取消注册事件
    GUI.UnRegisterUIEvent(itemIcon, UCE.PointerClick, "WingUI", "OnWingUIItemClick")
end

-- 左边I图标点击事件
function WingUI.OnWingsTipBtnClick(guid)
    local tabAttributePanel = GUI.Get("BagUI/panelBg/WingPage/dragonWings");
    if tabAttributePanel == nil then
        return
    end
    local tips = GUI.GetChild(tabAttributePanel,"Fashion_I_Image")
    if tips == nil then
        local tips = GUI.ImageCreate(tabAttributePanel,"Fashion_I_Image","1800400290",-10.7,-28.1,false,480,170)
        GUI.SetIsRemoveWhenClick(tips,true) -- 点击后销毁
        GUI.AddWhiteName(tips,guid) -- 添加到点击销毁白名单
        local txt = GUI.CreateStatic(tips,"Fashion_I_txt","",3,0,430,GUI.GetHeight(tips),"system",true)
        GUI.StaticSetFontSize(txt,22)
        GUI.StaticSetAlignment(txt,TextAnchor.MiddleLeft)

        local message = "<color=#ffffff>1.羽翼一旦解锁，即获得其属性。</color> \n"..
                "<color=#ffffff>2.羽翼到时限后，属性会相应扣除。</color> \n"..
                "<color=#ffffff>3.同一名称的羽翼，高级会覆盖低级</color> \n"..
                "<color=#ffffff>4.如果有更高时限的羽翼时，无法解锁低时限的该羽翼。</color>"

        GUI.StaticSetText(txt,message)
    end
end

-- 右边I 图标点击事件
function WingUI.OnWingEnhanceTipBtnClick(guid)
    local tabAttributePanel = GUI.Get("BagUI/panelBg");
    if tabAttributePanel == nil then
        return
    end
    local tips = GUI.GetChild(tabAttributePanel,"Fashion_I_Image")
    if tips == nil then
        local tips = GUI.ImageCreate(tabAttributePanel,"Fashion_I_Image","1800400290",256,193,false,480,170)
        GUI.SetIsRemoveWhenClick(tips,true) -- 点击后销毁
        GUI.AddWhiteName(tips,guid) -- 添加到点击销毁白名单
        local txt = GUI.CreateStatic(tips,"Fashion_I_txt","",3,0,430,GUI.GetHeight(tips),"system",true)
        GUI.StaticSetFontSize(txt,22)
        GUI.StaticSetAlignment(txt,TextAnchor.MiddleLeft)

        local message = "<color=#ffffff>1.羽翼等级每提升10，级需要升阶才可用继续升级。</color> \n"..
                "<color=#ffffff>2.提升等级可用获得属性，提升品阶可用获得额外属性。</color> \n"..
                "<color=#ffffff>3.第1、4、9、15阶将获得新的外观奖励。</color> "

        GUI.StaticSetText(txt,message)
    end
end

-- 时间选中按钮点击事件
local transferString = {} -- 将点击后选择的数据传输到下一个点击事件
function WingUI.OnWingsHBMoreBtnClick()
    local WingPage = _gt.GetUI("WingPage")
    local WingTime_Bg =GUI.GetChild(WingPage,"guardTypeBg") -- 选择列表黑色背景

    if WingTime_Bg ~= nil then
        GUI.Destroy(WingTime_Bg);
        return
    end
    WingTime_Bg =GUI.ImageCreate(WingPage, "WingTime_Bg","1800400290",-258,-57,false,277,160);
    SetAnchorAndPivot(WingTime_Bg, UIAnchor.Center, UIAroundPivot.Center)

    local scrollRect = GUI.ScrollRectCreate(WingTime_Bg,"scrollRect",0,0,277,140,0,false,Vector2.New(250,48))

    local data = {{["name"]="时间领主",["time"]=7},{["name"]="春风万里",["time"]=30},{["name"]="雪花飘飘",["time"]=0},}
    -- 获取当前选中的羽翼
    if WingUI.Current_Selected_WingId ~= nil and WingUI.Current_Selected_WingId ~= 0 then
        local item = DB.GetOnceIllusionByKey1(WingUI.Current_Selected_WingId)
        data = {}
        table.insert(data,{["name"]=item.Name,["time"]=item.Time,["id"]=item.Id})

        -- 羽翼名称
        local wing_name = item.Name

        if item.Name == "洁白羽翼" then
            GUI.SetPositionY(WingTime_Bg,-8)
            GUI.SetHeight(WingTime_Bg,60)
            GUI.SetHeight(scrollRect,60)
            goto tail
        end


        -- 先往上找,当Name字段不同时再往下找
        while(wing_name == item.Name) do
            item = DB.GetOnceIllusionByKey1(item.Id -1 )
            if item ~= nil and item.Id ~= 0 and wing_name == item.Name then
                table.insert(data,{["name"]=item.Name,["time"]=item.Time,["id"]=item.Id})
            end
        end

        -- 往下找
        while(wing_name == item.Name) do
            item = DB.GetOnceIllusionByKey1(item.Id +1 )
            if item ~= nil and item.Id ~= 0 and wing_name == item.Name then
                table.insert(data,{["name"]=item.Name,["time"]=item.Time,["id"]=item.Id})
            end
        end

        table.sort(data,function(a, b) return a.id < b.id end)  -- 排下序 id 从小到大
        ::tail::

    end

    for i=1,#data do
        local name = data[i].name
        local timeDes = data[i].time
        if timeDes > 0 then
            timeDes = "（" .. timeDes  .. "天）"
        else
            timeDes = "（永久）"
        end
        local level = GUI.ButtonCreate( scrollRect, "fashionBtn_"..i, "1801102010", 0, GUI.GetHeight(WingTime_Bg), Transition.ColorTint, name .. timeDes, 250, 48, false);
        GUI.ButtonSetTextColor(level, colorDark);
        GUI.ButtonSetTextFontSize(level, 24);
        SetAnchorAndPivot(level, UIAnchor.Top, UIAroundPivot.Top)
        GUI.SetData(level, "LevelIndex", i);
        GUI.RegisterUIEvent(level, UCE.PointerClick, "WingUI", "OnClothHBMoreScrollItemClick")

        --GUI.SetHeight(FashionClothTime_Bg,GUI.GetHeight(FashionClothTime_Bg)+GUI.GetHeight(level)) -- 更新高度
        transferString[GUI.GetGuid(level)] = data[i]
    end
    -- 将列表滚动到开头
    GUI.ScrollRectSetNormalizedPosition(scrollRect, Vector2.New(0,1))
    -- 检测到点击就销毁
    GUI.SetIsRemoveWhenClick(WingTime_Bg,true)
end

-- 选中时间按钮 点击后 选中某个时间的点击事件
local selectedWingItem = nil -- 选中的哪个时间的数据
function WingUI.OnClothHBMoreScrollItemClick(guid)
    if next(transferString) == nil then
        return
    end

    selectedWingItem = transferString[guid]

    local name = transferString[guid].name
    local timeDes = transferString[guid].time
    if timeDes > 0 then
        timeDes = "（" .. timeDes  .. "天）"
    else
        timeDes = "（永久）"
    end

    local moreWingNameText = _gt.GetUI("moreWingNameText") -- 选择时间按钮上的文本
    local toMallBtn = _gt.GetUI("toMallBtn") -- 购买按钮
    local buttonWingHandBookDesBg = _gt.GetUI("buttonWingHandBookDesBg")
    local WingTxtDesHasHbPage = GUI.GetChild(buttonWingHandBookDesBg,"WingTxtDesHasHbPage")-- 描述信息

    GUI.StaticSetText(moreWingNameText,name..timeDes)

    if transferString[guid].time == 0 then
        GUI.SetVisible(toMallBtn,true)
        GUI.StaticSetText(WingTxtDesHasHbPage,"激活羽翼将会永久获得其属性并解锁图鉴，该属性可与其他不同名的羽翼的属性叠加。")
    else
        GUI.SetVisible(toMallBtn,false)
        GUI.StaticSetText(WingTxtDesHasHbPage,"激活羽翼将会在限时内获得其属性，该属性可与其他不同名的羽翼的属性叠加。")
    end

    if name == "洁白羽翼" then
        GUI.SetVisible(toMallBtn,false)
    end

end

-- 购买按钮点击事件
function WingUI.OnWingHBToMallBtnClick()
    if WingUI.Current_Selected_WingId then
        local wing_key_name = DB.GetOnceIllusionByKey1(WingUI.Current_Selected_WingId).KeyName
        -- 点击后跳转到商城-金砖-对应的时装
        GUI.OpenWnd("MallUI",wing_key_name)
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,'数据异常')
        test('WingUI.OnWingHBToMallBtnClick() 羽翼购买按钮点击事件数据错误')
    end
end

-- 切换页签点击事件
function WingUI.OnGrowingSubTabBtnClick()
    WingUI.WingSubTabIndex = 1
    UILayout.OnSubTabClickEx(WingUI.WingSubTabIndex,WingTabList)
    WingUI.RefreshSubPage1()
end
function WingUI.OnHaveSubTabBtnClick()
    WingUI.WingSubTabIndex = 2
    UILayout.OnSubTabClickEx(WingUI.WingSubTabIndex,WingTabList)
    -- 如果有已装备的羽翼，选中它
    local CurrentUsedWingId = WingUI.CurrentUsedWingId
    if CurrentUsedWingId and CurrentUsedWingId ~= 0 then
        WingUI.Current_Selected_WingId = CurrentUsedWingId
    else
        WingUI.Current_Selected_WingId = nil
    end
    WingUI.RefreshSubPage2()
end
function WingUI.OnOutwardSubTabBtnClick()
    WingUI.WingSubTabIndex = 3
    UILayout.OnSubTabClickEx(WingUI.WingSubTabIndex,WingTabList)
    -- 如果有已装备的羽翼，选中它
    local CurrentUsedWingId = WingUI.CurrentUsedWingId
    if CurrentUsedWingId and CurrentUsedWingId ~= 0 then
        WingUI.Current_Selected_WingId = CurrentUsedWingId
    else
        if WingUI.foreverWing then
            WingUI.Current_Selected_WingId = WingUI.foreverWing[1].Id
        else
            -- 洁白羽翼
            WingUI.Current_Selected_WingId = 49
        end
    end
    WingUI.RefreshSubPage3()
end

-- 物品tips点击事件
function WingUI.OnWingUpgradeItemClick(guid,x,y,isBind)

    -- 如果上一个tips还存在，则销毁它
    local pre_tips = _gt.GetUI('WingPageTips')
    if pre_tips then
        GUI.Destroy(pre_tips)
    end

    local X = x or 120
    local Y = y or 0

    local btn = GUI.GetByGuid(guid)
    local data = string.split(GUI.GetData(btn,"itemID"),"-")
    local itemID = tonumber(data[1])
    if not itemID then return end

    -- 如果没有就弹出tips 以及获取方式
    local WingPage = _gt.GetUI("WingPage")
    local tip = Tips.CreateByItemId(itemID, WingPage, "WingPageTips",X,Y)
    GUI.SetData(tip, "ItemId", itemID)
    GUI.SetHeight(tip,GUI.GetHeight(tip)+40)
    _gt.BindName(tip, "WingPageTips")

    local wayBtn = GUI.ButtonCreate(tip, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
    UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"WingUI","OnClickFormationWayBtn")
    GUI.AddWhiteName(tip, GUI.GetGuid(wayBtn))

    if isBind then -- 添加绑定图标
        local tipsIcon = GUI.TipsGetItemIcon(tip)
        GUI.ItemCtrlSetElementValue(tipsIcon,eItemIconElement.LeftTopSp,"1800707120")
    end

end
-- 获取途径
function WingUI.OnClickFormationWayBtn()
    local tip = _gt.GetUI("WingPageTips")
    if tip then
        if GUI.GetPositionX(tip) == 433 then
            GUI.SetPositionX(tip,149)
        end
        Tips.ShowItemGetWay(tip)
    end
end

-- 获取/穿戴/卸下事件
    -- 获取事件
function WingUI.OnUnlockWingsBtnClick()
    local id = nil
    if selectedWingItem and selectedWingItem.id then -- 如果有选中时间按钮 选中的
        id = selectedWingItem.id
    elseif WingUI.Current_Selected_WingId and WingUI.Current_Selected_WingId ~= 0 then -- 如果上面没有 就使用永久的
        id = WingUI.Current_Selected_WingId
    else
        test("WingUI界面 WingUI.OnUnlockWingsBtnClick()获取按钮事件 需要的数据为空")
        return
    end

    if id then
        local wing = DB.GetOnceIllusionByKey1(id)
        local wingItem = DB.GetOnceItemByKey2(wing.KeyName)
        local wingItemId = wingItem.Id
        -- 判读是否已经拥有 物品数量>0
        if LD.GetItemCountById(wingItemId) > 0 then
            -- 如果拥有就直接使用
            GlobalUtils.ShowBoxMsg2Btn('提示',"您已拥有"..wingItem.Name.."是否立即使用",
                    "WingUI","确认",
                    "use_wing_item","取消")
        else
            -- 如果没有就弹出tips 以及获取方式
            local WingPage = _gt.GetUI("WingPage")
            local tip = Tips.CreateByItemId(tonumber(wingItemId), WingPage, "WingPageTips",120,32)
            GUI.SetData(tip, "ItemId", tostring(wingItemId))
            GUI.SetHeight(tip,GUI.GetHeight(tip)+40)
            _gt.BindName(tip, "WingPageTips")
            local wayBtn = GUI.ButtonCreate(tip, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
            UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"WingUI","OnClickFormationWayBtn")
            GUI.AddWhiteName(tip, GUI.GetGuid(wayBtn))
        end

    end

end
    -- 穿戴事件
function WingUI.OnSaveWingBtnClick()
    -- FormClothes.WearWing(player,Wing_Id)  --玩家穿脱羽翼
    if WingUI.Current_Selected_WingId then
        CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","WearWing",tostring(WingUI.Current_Selected_WingId))
    end
end
    -- 卸下事件
function WingUI.OnUnWearWingBtnClick()
    -- 当是拥有界面时，卸下 会使用 "未穿戴装备"
    if WingUI.WingSubTabIndex == 2 then
        WingUI.Current_Selected_WingId = 0 --当前选择的羽翼ID
    end

    CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","WearWing","0")
end

-- 使用羽翼物品
function WingUI.use_wing_item()
    if selectedWingItem and selectedWingItem.id then
        local wing = DB.GetOnceIllusionByKey1(selectedWingItem.id)
        local wingItem = DB.GetOnceItemByKey2(wing.KeyName)
        local itemGuid = LD.GetItemGuidsById(wingItem.Id)
        if itemGuid and itemGuid[0] ~= 0 then
            GlobalUtils.UseItem(itemGuid[0])
        end
    end
end

-- 时装图标点击事件
function WingUI.OnWingUIItemClick(guid)
    local itemIcon = GUI.GetByGuid(guid)
    local wingId = tonumber(GUI.GetData(itemIcon,"wingId"))

    WingUI.Current_Selected_WingId = wingId

    if WingUI.WingSubTabIndex == 2 then
        WingUI.RefreshSubPage2()
    end
    if WingUI.WingSubTabIndex == 3 then
        WingUI.RefreshSubPage3()
    end
    -- 将获取事件中tips设为此羽翼的永久tips
    selectedWingItem = nil
end

-- 成长界面 升阶点击事件
function WingUI.OnWingsUpgradeBtnClick()
    --FormClothes.WingGrowAddStage(player)
    -- 材料满足时才能升阶 服务端判断
    CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","WingGrowAddStage")
        -- 更新WingUI.WingGrow_Data中的WingGrow_Stage当前阶数数据 阶数+1
        -- 刷新羽翼成长小窗口 WingUI.RefreshWingUpPage()
end

-------------------------------------- 羽翼升级界面 start

-- 成长界面 升级点击事件
function WingUI.OnWingsLevelUpBtnClick()

    local panel = _gt.GetUI("WingPage")

    local enhancePracticeExp = GUI.GetChild(panel,"panelBg")
    if enhancePracticeExp == nil then
        local enhancePracticeExp = UILayout.CreateFrame_WndStyle2(panel,"羽翼成长",560,435,"WingUI","UpWingOnExit")

        -- 羽翼图片
        local practiceItemIcon_Bg = GUI.ImageCreate( enhancePracticeExp, "practiceItemIcon_Bg", "1800400050", 25, -25);
        SetAnchorAndPivot(practiceItemIcon_Bg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)

        local practiceItemIcon = GUI.ImageCreate( practiceItemIcon_Bg, "practiceItemIcon", "", 0, 1, false, 70, 70);
        SetAnchorAndPivot(practiceItemIcon, UIAnchor.Center, UIAroundPivot.Center)
        GUI.ImageSetImageID(practiceItemIcon, tostring(1801207040))
        GUI.SetWidth(practiceItemIcon, 80);
        GUI.SetHeight(practiceItemIcon, 80);

        local practiceLevel = nil;

        -- 等级文本
        practiceLevel = GUI.CreateStatic( enhancePracticeExp, "practiceLevel", "3级", 110.7, -59.4, 149, 49, "system", true, false);
        SetAnchorAndPivot(practiceLevel, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.SetColor(practiceLevel, colorblack);
        GUI.StaticSetFontSize(practiceLevel, 22);
        GUI.StaticSetAlignment(practiceLevel, TextAnchor.MiddleRight)

        local practiceName = GUI.CreateStatic( enhancePracticeExp, "practiceName", "", 111.3, -60.1, 119.51, 47.1, "system", true, false);
        SetAnchorAndPivot(practiceName, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.SetColor(practiceName, ColorType_FontColor2)
        GUI.StaticSetFontSize(practiceName, fontSize)
        GUI.StaticSetText(practiceName, "羽翼成长")

        local autoWingExpTxt = GUI.CreateStatic( enhancePracticeExp, "autoWingExpTxt", "", 411.6, -64.1, 200, 47.1, "system", true, false);
        SetAnchorAndPivot(autoWingExpTxt, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.SetColor(autoWingExpTxt, ColorType_FontColor2)
        GUI.StaticSetFontSize(autoWingExpTxt, 18)
        GUI.StaticSetText(autoWingExpTxt, "选中最大可使用")

        local practiceAddLevel = GUI.CreateStatic( enhancePracticeExp, "practiceAddLevel", "（+1级）", 254.2, -59.4, 150, 50, "system", true, false);
        SetAnchorAndPivot(practiceAddLevel, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.SetColor(practiceAddLevel, addWingExpTextColor);
        GUI.StaticSetFontSize(practiceAddLevel, 22);

        local value = 0;
        local expSlider_Child = GUI.ScrollBarCreate( enhancePracticeExp, "expSlider_Child", "", "1800408130", "1800408110", 110, -30, 325, 24, value, false, Transition.None, 0, 1);
        GUI.ScrollBarSetFillSize(expSlider_Child, Vector2.New(325, 24));
        GUI.ScrollBarSetBgSize(expSlider_Child, Vector2.New(325, 24));
        SetAnchorAndPivot(expSlider_Child, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.ScrollBarSetPos(expSlider_Child, value);

        local expSlider = GUI.ScrollBarCreate( expSlider_Child, "expSlider", "", "1800408160", "", 0, 0, 325, 24, value, false, Transition.None, 0, 1);
        GUI.ScrollBarSetFillSize(expSlider, Vector2.New(325, 24));
        GUI.ScrollBarSetBgSize(expSlider, Vector2.New(325, 24));
        SetAnchorAndPivot(expSlider, UIAnchor.Left, UIAroundPivot.Left)
        GUI.ScrollBarSetPos(expSlider, value);

        -- 经验条显示文本
        local expTxt = GUI.CreateStatic( expSlider, "expTxt", "", 0, 0, 328.11, 44, "system", true, false);
        SetAnchorAndPivot(expTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(expTxt, fontSize);
        GUI.StaticSetAlignment(expTxt, TextAnchor.MiddleCenter)


        --使用按钮
        local useBtn = GUI.ButtonCreate( enhancePracticeExp, "useBtn", "1800402110", -28, -30, Transition.ColorTint, "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">使用</size></color>", 80, 45, false);
        SetAnchorAndPivot(useBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
        GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "WingUI", "OnClickAddWingExpPopupUseBtn");
        GUI.SetEventCD(useBtn,UCE.PointerClick,1)

        -- 选中最大可用多选框
        local autoCheckMaxBox = GUI.CheckBoxCreate( enhancePracticeExp, "autoCheckMaxBox", "1800607150", "1800607151", -152, -68.5, Transition.None, true, 42, 40)
        SetAnchorAndPivot(autoCheckMaxBox, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
        GUI.RegisterUIEvent(autoCheckMaxBox, UCE.PointerClick, "WingUI", "OnAutoUseWingExpBox")

        -- 物品框
        local grid_Bg = GUI.ImageCreate( enhancePracticeExp, "grid_Bg", "1800400200", 0, 55, false, 505, 265);
        SetAnchorAndPivot(grid_Bg, UIAnchor.Top, UIAroundPivot.Top)

        local enhanceVecSize = Vector2.New(78, 81)
        local enhanceScr = GUI.ScrollRectCreate( grid_Bg, "enhanceScr", 0, 0, 490, 250, 0, false, enhanceVecSize, UIAroundPivot.Center, UIAnchor.Center, 6);
        SetAnchorAndPivot(enhanceScr, UIAnchor.Center, UIAroundPivot.Center)
        GUI.ScrollRectSetChildSpacing(enhanceScr, Vector2.New(1, 1));
        _gt.BindName(enhanceScr,"wingUpEnhanceScr")
        enhanceScr:RegisterEvent(UCE.Drag)
        --WingUI.CreateMaterialBox() -- 创建材料框

        local panelCover = GUI.GetChild(panel,"panelCover")
        if panelCover then
            GUI.SetPositionY(panelCover,-33)
        end

    else
        GUI.SetVisible(enhancePracticeExp,true)
        local panelCover = GUI.GetChild(panel,"panelCover")
        if panelCover then
            GUI.SetVisible(panelCover,true)
        end
    end
    WingUI.RefreshWingUpPage() -- 刷新材料框
    -- 添加物品改变触发器，当打开羽翼升级界面后，购买物品能刷新此界面
    CL.RegisterMessage(GM.RefreshBag,'WingUI','_gm_refresh_wing_up_page')
end
-- 创建材料框
function WingUI.CreateMaterialBox(num)

    if UIDefine.WingItem_Config == nil then
        test("WingUI界面 创建材料框方法 缺少UIDefine.WingItem_Config")
        return
    end

    local MaxNum = 18
    if num and num > MaxNum then MaxNum = num end
    local IsShow = true -- 物品是否显示
    local IconID = "" -- 材料图片
    local GradeIcon = "" -- 材料背景
    local NumInfo = "0/0"
    --if MaxNum < 18 then MaxNum = 18 end -- 最小18 格
    if MaxNum > 18 then MaxNum = math.ceil(MaxNum / 6) * 6  end
    if MaxNum > 150 then MaxNum = 150 end -- 最大150 格

    local _SeatScroll = _gt.GetUI("wingUpEnhanceScr")

    for i=1,MaxNum do
        local _Item = GUI.GetChild(_SeatScroll,"Item"..i)
        if _Item == nil then
            --底板
            _Item = GUI.ImageCreate( _SeatScroll, "Item"..i, "1800600050", 0, 0, false, 78, 78)
            SetAnchorAndPivot(_Item, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetVisible(_Item, true)

            --图标
            local _Icon = GUI.ItemCtrlCreate( _Item, tostring(i), "1800600050", 0, 0, 78, 82, false)
            SetAnchorAndPivot(_Icon, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(_Icon, IsShow)
            GUI.ItemCtrlSetElementRect(_Icon,eItemIconElement.Icon,0,0,60,60)
            --GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Icon, IconID)
            --GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Border, GradeIcon)
            GUI.RegisterUIEvent(_Icon , UCE.PointerClick , "WingUI", "OnClickItem" )
            _Icon:RegisterEvent(UCE.PointerUp)
            _Icon:RegisterEvent(UCE.PointerDown)
            GUI.RegisterUIEvent(_Icon, UCE.PointerDown , "WingUI", "OnClickItemDown")
            GUI.RegisterUIEvent(_Icon, UCE.PointerUp , "WingUI", "OnClickItemUp")

            -- 数量黑色底框
            local middleNum_Bg = GUI.ImageCreate( _Item, "middleNum_Bg", "1800400220", 0, -5, false, 74, 23);
            SetAnchorAndPivot(middleNum_Bg, UIAnchor.Bottom, UIAroundPivot.Bottom)
            GUI.SetVisible(middleNum_Bg,false)

            --数量
            local _Num = GUI.CreateStatic( _Item, "Num"..i, NumInfo, 0, 24, 100, 35)
            SetAnchorAndPivot(_Num, UIAnchor.Center, UIAroundPivot.Center)
            GUI.StaticSetFontSize(_Num, 18)
            GUI.SetColor(_Num, UIDefine.WhiteColor)
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
            GUI.RegisterUIEvent(_DecBtn , UCE.PointerClick , "WingUI", "OnDecBtn" )
            _DecBtn:RegisterEvent(UCE.PointerUp)
            _DecBtn:RegisterEvent(UCE.PointerDown)
            GUI.RegisterUIEvent(_DecBtn, UCE.PointerDown , "WingUI", "OnDecDown")
            GUI.RegisterUIEvent(_DecBtn, UCE.PointerUp , "WingUI", "OnDecUp")

        end
    end

end


WingUI.sendWingUpData = {} -- 发送给服务器的数据,使用什么及多少升级羽翼的材料
WingUI.selectedWingUpPage_UpMaterialId = nil -- 选中的材料
WingUI.isCanUpWing = nil -- 是否可用继续升级
WingUI.WingItem_Config = nil  -- 能排序的格式

function WingUI.sortUpWingMaterialData()
    if UIDefine.WingItem_Config == nil then
        return
    end
    local WingItem_Config = UIDefine.WingItem_Config


    --  {keyName, count,  isBound ,exp}  先绑后非绑 0 非绑 1 绑定
    local wingMaterialData = {}
    for k,v in pairs(WingItem_Config) do
        table.insert(wingMaterialData,{["keyName"]=k,["isBound"]=0,["amount"]=0,["exp"]=v})
        table.insert(wingMaterialData,{["keyName"]=k,["isBound"]=1,["amount"]=0,["exp"]=v})
    end

    -- 判断是否有非绑定的物品，用来删除阴影格子
    local _is_del_shadow = false

    for k,v in pairs(WingItem_Config) do -- 遍历所有升级羽翼物品的keyName
        local item = DB.GetOnceItemByKey2(k)
        local itemGuids = LD.GetItemGuidsById(item.Id) -- 获取物品所有的格子guid
        if itemGuids then
            for i=0,itemGuids.Count-1 do -- 遍历所有的格子
                local isBound = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, itemGuids[i]))  -- 此格子内的物品是否绑定
                local amount = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, itemGuids[i])) -- 此格子内的物品数量

                -- 判断是否删除阴影格子
                if not _is_del_shadow then
                    if isBound == 0 and amount > 0 then
                        _is_del_shadow = true
                    end
                end

                for j=1,#wingMaterialData do
                    if wingMaterialData[j].keyName == k and wingMaterialData[j].isBound == isBound then
                        if wingMaterialData[j].amount ~= 0 then
                            wingMaterialData[j].amount = wingMaterialData[j].amount + amount -- 统计同名 同是否绑定 的物品数量
                        else
                            wingMaterialData[j].amount = amount
                            wingMaterialData[j]["exp"] = v
                        end
                    end
                end
            end
        end
    end


    -- 分割  99 个一组
    local function sortAmount(cell,index)
        if cell and index then
            if cell.amount > 99 then
                local count = cell.amount - 99
                cell.amount = 99
                local newCell = {["keyName"] = cell.keyName,["amount"] = count,["isBound"] = cell.isBound,["exp"]=cell.exp}
                if count > 99 then
                    sortAmount(newCell,index)
                end
                table.insert(wingMaterialData,index,newCell)
            end
        end
    end


    -- 当其是非绑定 且为空 将其数据删除，当有非绑定物品时，删除空的绑定阴影格
    for i=#wingMaterialData,1,-1 do
        -- 非绑定
        if wingMaterialData[i].isBound == 0 then
            -- 数量为0
            if wingMaterialData[i].amount <= 0 then
                table.remove(wingMaterialData,i)
            end
        end

        -- 绑定
        if wingMaterialData[i] then
            if _is_del_shadow then
                if wingMaterialData[i].isBound == 1 then
                    -- 数量为0
                    if wingMaterialData[i].amount <= 0 then
                        table.remove(wingMaterialData,i)
                    end
                end
            end
        end

    end

    -- 当物品数量超过99个则需要分开两份
    for i=#wingMaterialData,1,-1 do
        sortAmount(wingMaterialData[i],i)
    end

    -- 整理下顺序
    local sortOrder = function(a,b)
        -- 不同材料比较数量 >0 在前
        if a.amount == 0 and b.amount ~= 0 then
            return false
        elseif a.amount ~= 0 and b.amount ==0 then
            return true
        elseif a.exp == b.exp then
            -- 同材料比较 是否绑定 绑定在前
            if a.isBound == 1 and b.isBound == 0 then
                return true
            elseif a.isBound == 0 and b.isBound == 1 then
                return false
            else
                -- 同材料 同绑定 比较数量 多的在前
                return a.amount < b.amount
            end
        else
            -- 不同材料比较所加经验值
            return a.exp < b.exp
        end
    end

    table.sort(wingMaterialData,sortOrder)

    return wingMaterialData
end
WingUI.isSelectedMax = true -- 是否选中最大
-- 刷新羽翼升级界面
function WingUI.RefreshWingUpPage()
    if UIDefine.WingItem_Config == nil  and WingUI.sendWingUpData == nil  then
        test("WingUI界面 刷新羽翼升级界面方法 缺少UIDefine.WingItem_Config")
        return
    end

    WingUI.WingItem_Config = WingUI.sortUpWingMaterialData()

    local panel = _gt.GetUI("WingPage")
    local enhancePracticeExp = GUI.GetChild(panel,"panelBg")


    -- 选中最大可用
    if WingUI.isSelectedMax then
        local check_btn = GUI.GetChild(enhancePracticeExp,"autoCheckMaxBox")
        GUI.CheckBoxSetCheck(check_btn,WingUI.isSelectedMax)
        local guid = GUI.GetGuid(check_btn)
        WingUI.OnAutoUseWingExpBox(guid)
        return ''
    end


    local create_count = #WingUI.WingItem_Config
    -- 创建更多格子
    WingUI.CreateMaterialBox(create_count)
    -- 清空格子内容
    WingUI.CleanWingUpPageBox(create_count)


    -- 刷新格子内容
    local _SeatScroll = _gt.GetUI("wingUpEnhanceScr")
    if _SeatScroll then
        GUI.ScrollRectSetNormalizedPosition(_SeatScroll,Vector2.New(0, 1))
    end

    local WingItem_Config = WingUI.WingItem_Config
    local i = 1
    for k,v in pairs(WingItem_Config) do
        local k = v.keyName
        local Item = DB.GetOnceItemByKey2(k)
        local _Item = GUI.GetChild(_SeatScroll,"Item"..i)
        GUI.SetVisible(_Item, true)
        -- 显示数量
        local _Num = GUI.GetChild(_Item,"Num"..i)
        GUI.SetVisible(_Num,true)
        local middleNum_Bg = GUI.GetChild(_Item,"middleNum_Bg")
        local haveItemCount =  v.amount -- LD.GetItemCountById(Item.Id)  -- 获取角色拥有升级材料的数量
        if WingUI.sendWingUpData and WingUI.sendWingUpData[i] == nil then
            WingUI.sendWingUpData[i] = {}
            for k1,v1 in pairs(v) do
                WingUI.sendWingUpData[i][k1] = v1
            end
        end
        local usedItemCount = WingUI.sendWingUpData[i].amount -- 准备使用的数量
        local isNotZero = haveItemCount ~= 0 -- 拥有的数量不是0
        if isNotZero then
            GUI.StaticSetText(_Num,usedItemCount .."/".. haveItemCount)
            GUI.SetVisible(middleNum_Bg,true)
        else
            GUI.SetVisible(middleNum_Bg,false)
            GUI.SetVisible(_Num,false)  -- 如果拥有数量为0 就不显示
        end

        -- 显示图标
        -- 如果背包没有此物品 则显示灰色 且排到后面
        local _Icon = GUI.GetChild(_Item,i)
        GUI.SetVisible(_Icon,true)
        GUI.SetData(_Icon,"itemID",Item.Id.."-"..i) -- 插入数据
        GUI.SetData(_Icon,"IsBind",v.isBound)
        GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Icon, Item.Icon)
        if isNotZero then
            GUI.ItemCtrlSetIconGray(_Icon,false)
            GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Border, quality[Item.Grade])
        else
            if v.isBound == 1 then -- 绑定非绑定只显示一个 显示非绑定
                GUI.ItemCtrlSetIconGray(_Icon,true) -- 显示灰色
                GUI.ItemCtrlSetElementValue(_Icon,eItemIconElement.Border, "1800499999" ) -- 取消品质背景
            end
        end

        -- 显示选中框
        local SelectFlag = GUI.GetChild(_Item,"SelectFlag")
        if WingUI.selectedWingUpPage_UpMaterialId and  i == WingUI.selectedWingUpPage_UpMaterialId then
            GUI.SetVisible(SelectFlag,true)
        else
            if WingUI.selectedWingUpPage_UpMaterialId == nil and i == 1 then
                GUI.SetVisible(SelectFlag,true)
                -- 当不是升阶时才显示tips
                if GlobalProcessing.wing_upgrade_material == nil  or next(GlobalProcessing.wing_upgrade_material) == nil then
                    -- 显示tips
                    local guid = GUI.GetGuid(_Icon)
                    local isBind = v.isBound
                    WingUI.OnWingUpgradeItemClick(guid,433,15,isBind)

                end
            else
                GUI.SetVisible(SelectFlag,false)
            end
        end

        -- 减少按钮
            -- 如果数量为零，就不显示减号按钮，如果不是就显示
        local DecBtn = GUI.GetChild(_Item,"DecBtn"..i)
        GUI.SetData(DecBtn,"itemID",Item.Id.."-"..i)
        if WingUI.sendWingUpData[i].amount > 0 then
            GUI.SetVisible(DecBtn,true)
        else
            GUI.SetVisible(DecBtn,false)
        end

        i = i + 1
    end


    -- 刷新其余部分
    if WingUI.WingGrow_Data  then
        local WingGrow_Data = WingUI.WingGrow_Data
        -- 刷新等级
        local practiceLevel = GUI.GetChild(enhancePracticeExp,"practiceLevel")
        GUI.StaticSetText(practiceLevel,WingGrow_Data.WingGrow_Level.."级")
        -- 刷新经验条
        local expTxt = GUI.GetChild(enhancePracticeExp,"expTxt")
        local NeedExp =  WingGrow_Data.NeedExp  -- 当前等级所需要的经验
        local currentHaveExp = WingGrow_Data.HaveExp -- 当前所拥有的经验
        local currentAddExp = 0  -- 当前使用材料后所增加的经验值  使用材料获取的
        for i=1,#WingUI.sendWingUpData do
            currentAddExp = currentAddExp + WingUI.sendWingUpData[i].amount * WingUI.sendWingUpData[i].exp
        end

            -- 刷新经验条文本
        if currentAddExp == 0 then
            GUI.StaticSetText(expTxt,currentHaveExp.." /"..NeedExp)
        else
            GUI.StaticSetText(expTxt,currentHaveExp.."( +"..currentAddExp.." )".." /"..NeedExp)
        end
            -- 刷新经验条
        local expSlider_Child = GUI.GetChild(enhancePracticeExp,"expSlider_Child")
        GUI.ScrollBarSetPos(expSlider_Child,(currentAddExp+currentHaveExp)/NeedExp)
        local expSlider = GUI.GetChild(enhancePracticeExp,"expSlider")
        GUI.ScrollBarSetPos(expSlider,currentHaveExp/NeedExp)

        -- 刷新加成等级
        local practiceAddLevel = GUI.GetChild(enhancePracticeExp,"practiceAddLevel")
        local allExp = currentAddExp + currentHaveExp -- 已拥有经验 + 材料获取经验
        local addLevel = 0
        local upExp = UIDefine.WingStage_Exp[WingGrow_Data.WingGrow_Stage].Exp
        WingUI.isCanUpWing = true
        if allExp >= upExp then
            repeat
                addLevel = addLevel + 1
                upExp = upExp + UIDefine.WingStage_Exp[WingGrow_Data.WingGrow_Stage].Exp
                if addLevel + WingGrow_Data.WingGrow_Level - (WingGrow_Data.WingGrow_Stage * 10) == 10 then -- 每10级升一阶 必须升阶后才能继续升级
                    WingUI.isCanUpWing = false -- 不可以继续升级了
                    break
                end
                --if WingGrow_Data.WingGrow_Level - (WingGrow_Data.WingGrow_Stage*10) == 10 then
                --    addLevel = 0
                --    upExp = 0
                --    WingUI.isCanUpWing = false
                --    break
                --end
            until allExp < upExp  -- 直到为true
        end
        if addLevel == 0 then
            GUI.SetVisible(practiceAddLevel,false)
        else
            GUI.SetVisible(practiceAddLevel,true)
            GUI.StaticSetText(practiceAddLevel,"（+"..addLevel.."级）")
        end

    end
end

-- 清空升级羽翼材料框
function WingUI.CleanWingUpPageBox(num)
    if UIDefine.WingItem_Config == nil then
        test("WingUI界面 WingUI.CleanWingUpPageBox()方法 缺少UIDefine.WingItem_Config")
        return
    end

    local MaxNum = 18
    if num and num > MaxNum then MaxNum = num end
    --if MaxNum < 18 then MaxNum = 18 end -- 最小18 格
    if MaxNum > 18 then MaxNum = math.ceil(MaxNum / 6) * 6  end
    if MaxNum > 150 then MaxNum = 150 end -- 最大150 格

    local _SeatScroll = _gt.GetUI("wingUpEnhanceScr")
    for i=1,MaxNum do
        local _Item = GUI.GetChild(_SeatScroll,"Item"..i)
        if _Item ~= nil then
            -- 隐藏图标
            local _Icon = GUI.GetChild(_Item,tostring(i))
            if _Icon then GUI.SetVisible(_Icon,false) end
            -- 数量黑色框底板
            local middleNum_Bg = GUI.GetChild(_Item,"middleNum_Bg")
            if middleNum_Bg then GUI.SetVisible(middleNum_Bg,false) end
            -- 数量
            local Num = GUI.GetChild(_Item,"Num"..i)
            if Num then GUI.SetVisible(Num,false) end
            -- 选中标记
            local SelectFlag = GUI.GetChild(_Item,"SelectFlag")
            if SelectFlag then GUI.SetVisible(SelectFlag,false) end
            -- 减少按钮
            local DecBtn = GUI.GetChild(_Item,"DecBtn"..i)
            if DecBtn then GUI.SetVisible(DecBtn,false) end
        end
    end


    -- 隐藏多余的物品框
        -- 创建物品框的最大值
    if WingUI._material_max_count == nil or WingUI._material_max_count < MaxNum then WingUI._material_max_count = MaxNum end

    if WingUI._material_max_count > MaxNum then
        -- 如果节点不存在，刷新物品框数量最大值
        if GUI.GetChild(_SeatScroll,"Item"..MaxNum+1) == nil then
            WingUI._material_max_count = MaxNum
        end

        for i = MaxNum + 1 , WingUI._material_max_count do
            local _Item = GUI.GetChild(_SeatScroll,"Item"..i)
            if _Item then
                GUI.SetVisible(_Item, false)
            end
        end
    end

end

-- 选中最大可用点击事件
function WingUI.OnAutoUseWingExpBox(guid)
    if not (WingUI.WingGrow_Data and UIDefine.WingStage_Exp and WingUI.WingItem_Config) then
        return
    end
    local btn = GUI.GetByGuid(guid)
    local state = GUI.CheckBoxGetCheck(btn)
    if state then
        -- 选中最大

        -- 最大等级所需要的经验
        local WingGrow_Data = WingUI.WingGrow_Data
        local everyLevelExp = UIDefine.WingStage_Exp[WingGrow_Data.WingGrow_Stage].Exp
        local upExp = 0 -- 升到最大等级所需要的经验值 （最大等级-当前等级）*每级经验 - 当前拥有的经验
        upExp = (((WingGrow_Data.WingGrow_Stage+1) * 10) - WingGrow_Data.WingGrow_Level) * everyLevelExp - WingGrow_Data.HaveExp

        -- 所有物品所加的经验值
        local allExp = 0
        local WingItem_Config = WingUI.WingItem_Config
        for i=1,#WingItem_Config do
            allExp = allExp + WingItem_Config[i].amount * WingItem_Config[i].exp
            -- 使用全部物品
            if WingUI.sendWingUpData and WingUI.sendWingUpData[i] == nil then
                WingUI.sendWingUpData[i] = {}
                for k1,v1 in pairs(WingItem_Config[i]) do
                    WingUI.sendWingUpData[i][k1] = v1
                end
            else
                WingUI.sendWingUpData[i].amount = WingItem_Config[i].amount
            end
        end


        -- 选中最大可用
            -- 升到最大等级所需要的经验值 = 升到最大等级经验值
            local UpToMaxLevelExp = upExp
            -- 计算需要的物品数量
            -- 如果所需要的经验值 小于 物品总经验值
            if UpToMaxLevelExp < allExp then
                -- 经验多出的值
                local overflow = allExp - UpToMaxLevelExp
                for i=#WingUI.sendWingUpData,1,-1 do
                    local sendWingUpData = WingUI.sendWingUpData[i]
                    -- 如果一个格子内的材料大于经验的差值
                    if sendWingUpData.exp * sendWingUpData.amount > overflow then
                        local count = math.floor(overflow / sendWingUpData.exp) -- 计算出能剩下来的数量
                        sendWingUpData.amount = WingItem_Config[i].amount - count -- 使用数量 = 所有数量 - 可剩下的数量
                        break
                    else
                        overflow = overflow - sendWingUpData.exp * WingItem_Config[i].amount-- 溢出经验 = 溢出经验 - 所有材料数量*单个材料经验
                        sendWingUpData.amount = 0 -- 本格将全部不使用
                    end
                end
            end
            WingUI.isSelectedMax = false

            WingUI.RefreshWingUpPage() -- 刷新页面

    else
        -- 全部取消
        for i=1,#WingUI.sendWingUpData do
            WingUI.sendWingUpData[i].amount = 0
        end
        WingUI.isSelectedMax = false
        WingUI.RefreshWingUpPage()
    end

end


-- 长按
local btn_Guid = nil
local TimerFunction = function ()
    if btn_Guid ~= nil then
        WingUI.OnClickItem(btn_Guid)
    end
end

-- 羽翼升级材料 点击事件 创建tips、如果不是最大值增加选中数量
function WingUI.OnClickItem(guid)
    local _Icon = GUI.GetByGuid(guid) -- 材料图片节点
    local data = string.split(GUI.GetData(_Icon,"itemID"),"-")
    local itemId = tonumber(data[1]) -- 材料ID
    local index = tonumber(data[2]) --下标
    local item = DB.GetOnceItemByKey1(itemId)

    local isBind = GUI.GetData(_Icon,"IsBind")

    -- 显示选中框
    WingUI.selectedWingUpPage_UpMaterialId = index


    -- 等级最大值检测
    if not WingUI.isCanUpWing then
        -- 暂停计时器
        WingUI.ClickItemTimer:Stop()
        WingUI.ClickItemTimer:Reset(TimerFunction,0.2,-1)

        GlobalUtils.ShowBoxMsg1Btn("提示","已填充经验至当前最大等级，请提升等阶后再尝试羽翼升级。","WingUI","确认",nil,"")
    else
        -- 增加选中数量
        local haveItemCount = WingUI.WingItem_Config[index].amount
        if WingUI.sendWingUpData[index].amount < haveItemCount then
            WingUI.sendWingUpData[index].amount = WingUI.sendWingUpData[index].amount + 1
        end
        -- 创建tips
        if isBind == "1" then -- 如果是绑定
            isBind = true
        elseif isBind == "0" then -- 如果是非绑
            isBind = false
        else -- 其他非法值都设为绑定
            isBind = true
        end
        WingUI.OnWingUpgradeItemClick(guid,433,15,isBind)
    end

    -- 刷新羽翼升级界面
    WingUI.RefreshWingUpPage()

end

WingUI.ClickItemTimer = Timer.New(TimerFunction,0.2,-1)

-- 按下 开始计时器 循环执行函数
function WingUI.OnClickItemDown(guid)
    if WingUI.ClickItemTimer ~= nil then
        btn_Guid = guid
        WingUI.ClickItemTimer:Start()
    end
end

-- 松开 暂停计时器
function WingUI.OnClickItemUp(guid)
    if WingUI.ClickItemTimer ~= nil then
        btn_Guid = nil
        WingUI.ClickItemTimer:Stop()
        WingUI.ClickItemTimer:Reset(TimerFunction,0.2,-1)
    end
end

-- 长按
local DecBtn_Guid = nil
local DecTimerFunction = function ()
    if DecBtn_Guid ~= nil then
        WingUI.OnDecBtn(DecBtn_Guid)
    end
end

local DecTimer = Timer.New(DecTimerFunction,0.2,-1)

-- 松开
function WingUI.OnDecUp(guid)
    if DecTimer ~= nil then
        DecBtn_Guid = nil
        DecTimer:Stop()
        DecTimer:Reset(DecTimerFunction,0.2,-1)
    end
end

-- 减少按钮点击事件
function WingUI.OnDecBtn(guid)
    local _DecBtn = GUI.GetByGuid(guid)

    local data = string.split(GUI.GetData(_DecBtn,"itemID"),"-")
    local index = tonumber(data[2]) --下标

    -- 减少材料选中数量
    if WingUI.sendWingUpData[index].amount > 0 then

        WingUI.sendWingUpData[index].amount = WingUI.sendWingUpData[index].amount - 1
    end

    if WingUI.sendWingUpData[index].amount == 0 then
        -- 当减少到零时
        -- 防止减少按钮隐藏后 计时器不终止
        if DecTimer ~= nil then
            DecBtn_Guid = nil
            DecTimer:Stop()
            DecTimer:Reset(DecTimerFunction,0.2,-1)
        end
    end

    -- 刷新羽翼升级界面
    WingUI.RefreshWingUpPage()

end

-- 按下
function WingUI.OnDecDown(guid)
    if DecTimer ~= nil then
        DecBtn_Guid = guid
        DecTimer:Start()
    end
end

-- 关闭升级界面
function WingUI.UpWingOnExit()
    -- 隐藏界面
    local WingPage = _gt.GetUI("WingPage")
    local panelBg = GUI.GetChild(WingPage,"panelBg")
    local panelCover = GUI.GetChild(WingPage,"panelCover")
    if panelBg and panelCover then
        GUI.SetVisible(panelBg,false)
        GUI.SetVisible(panelCover,false)
    end

    -- 销毁tips
    local tips = _gt.GetUI('WingPageTips')
    if tips and GUI.GetVisible(tips) then
        GUI.Destroy(tips)
    end

    WingUI.sendWingUpData = {} -- 清空数据
    WingUI.isSelectedMax = true -- 选中最大可使用
    WingUI.selectedWingUpPage_UpMaterialId = nil

    -- 清除监听事件
    CL.UnRegisterMessage(GM.RefreshBag,'WingUI','_gm_refresh_wing_up_page')
end

-- 使用按钮点击事件
function WingUI.OnClickAddWingExpPopupUseBtn()

    -- 判断是否在战斗中
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法进行该操作")
        return false
    end

    -- FormClothes.WingGrowLevelUp(player,itemStr)  --羽翼升级
    if WingUI.sendWingUpData and next(WingUI.sendWingUpData) then
        local sendString = ""
        for k,v in pairs(WingUI.sendWingUpData) do
            if v.amount > 0 then
                sendString = sendString .. v.keyName.."_"..v.amount.."_"..v.isBound.."_"
            end
        end
        if sendString and sendString ~= '' then
            WingUI.sendWingUpData = {} -- 清空数据
            WingUI.isSelectedMax = true -- 选中最大可使用
            --CDebug.LogError("发送请求"..sendString)
            CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","WingGrowLevelUp",sendString) -- 调用WingUI.CloseUpWingPage()
        else
            CL.SendNotify(NOTIFY.ShowBBMsg,'没有选中任何材料')
        end
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,'没有选中任何材料')
    end
end

-- 关闭窗口
function WingUI.CloseUpWingPage()
    WingUI.UpWingOnExit()
end

-- 获取新物品后执行刷新方法
function WingUI._gm_refresh_wing_up_page()
    WingUI.sendWingUpData = {} -- 清空数据
    WingUI.isSelectedMax = true -- 选中最大可使用
    WingUI.selectedWingUpPage_UpMaterialId = nil

    local WingPage = _gt.GetUI("WingPage")
    local panelBg = GUI.GetChild(WingPage,"panelBg")
    -- 当页面正在显示时才执行刷新
    if panelBg and GUI.GetVisible(panelBg) then
        -- 当不是升阶时
        if GlobalProcessing.wing_upgrade_material == nil  or next(GlobalProcessing.wing_upgrade_material) == nil then
            WingUI.RefreshWingUpPage()
        end
    end
end

-------------------------------------- 羽翼升级界面 end

-- 判断是那个按钮，且是否显示小红点
function WingUI.is_show_red()
    local result = {}
    -- 小红点
    if GlobalProcessing['bagBtn'..'_Reds'] and GlobalProcessing['bagBtn'..'_Reds']['wing_upgrade'] then
        -- 如果是升阶
        if GlobalProcessing['bagBtn'..'_Reds']['wing_upgrade'] ~= 3 then

            if GlobalProcessing['bagBtn'..'_Reds']['wing_upgrade'] == 1 then
                result = {upgrade = true}
            else
                result = {upgrade = false}
            end
            -- 如果不是升阶，而是升级
        else

            if GlobalProcessing['bagBtn'..'_Reds'] and GlobalProcessing['bagBtn'..'_Reds']['wing_level_up'] then
                if GlobalProcessing['bagBtn'..'_Reds']['wing_level_up'] == 1 then
                    result = {level_up = true}
                else
                    result = {level_up = false}
                end
            end

        end
    end

    return result
end

-- 控制按钮显示小红点
function WingUI.set_red()

    -- 判断等级是否足够
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel['羽翼']
    if CurLevel >= Level then

        local wing_page = _gt.GetUI('WingPage')
        -- 成长 二级页签按钮
        local growing_btn = GUI.GetChild(wing_page, 'growingSubTabBtn')

        -- 升级和升阶按钮
        local level_up_btn = _gt.GetUI('wingsLevelUpBtn')
        local upgrade_btn = _gt.GetUI('wingsUpgradeUpBtn')

        -- 如果羽翼已达到最大等级
        if GlobalProcessing.wing_is_max_level == true then
            GlobalProcessing.SetRetPoint(growing_btn, false)
            GlobalProcessing.SetRetPoint(level_up_btn, false)
            GlobalProcessing.SetRetPoint(upgrade_btn, false)
            return ''
        end

        local red_data = WingUI.is_show_red()

        if red_data.upgrade ~= nil then
            GlobalProcessing.SetRetPoint(growing_btn, red_data.upgrade)
        elseif red_data.level_up ~= nil then
            GlobalProcessing.SetRetPoint(growing_btn, red_data.level_up)
        end

        -- 如果当前是成长页签
        if WingUI.WingSubTabIndex == 1 then
            if red_data.upgrade ~= nil then
                GlobalProcessing.SetRetPoint(level_up_btn, false)
                GlobalProcessing.SetRetPoint(upgrade_btn, red_data.upgrade)
            elseif red_data.level_up ~= nil then
                GlobalProcessing.SetRetPoint(upgrade_btn, false)
                GlobalProcessing.SetRetPoint(level_up_btn, red_data.level_up)
            else
                GlobalProcessing.SetRetPoint(level_up_btn, false)
                GlobalProcessing.SetRetPoint(upgrade_btn, false)
                test('WingUI.set_red() 设置羽翼小红点时，发生错误')
            end
        end

    else
        return false
    end

end


return WingUI
