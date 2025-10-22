local GuardInfoUI = {}
_G.GuardInfoUI = GuardInfoUI
local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
--local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
--local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
--侍从配置的最大星级
local GUARD_MAX_STAR = 6
--侍从配置的最高等级
local GUARD_MAX_LEVEL = 200
local attrLst = {
    {RoleAttr.RoleAttrPhyAtk,System.Enum.ToInt(RoleAttr.RoleAttrPhyAtk)},
    {RoleAttr.RoleAttrMagAtk, System.Enum.ToInt(RoleAttr.RoleAttrMagAtk)},
    {RoleAttr.RoleAttrPhyDef,System.Enum.ToInt(RoleAttr.RoleAttrPhyDef)},
    {RoleAttr.RoleAttrMagDef, System.Enum.ToInt(RoleAttr.RoleAttrMagDef)},
    {RoleAttr.RoleAttrPhyBurstRate,System.Enum.ToInt(RoleAttr.RoleAttrPhyBurstRate)},
    {RoleAttr.RoleAttrMagBurstRate, System.Enum.ToInt(RoleAttr.RoleAttrMagBurstRate)},
    {RoleAttr.RoleAttrSealRate, System.Enum.ToInt(RoleAttr.RoleAttrSealRate)},
    {RoleAttr.RoleAttrSealResistRate,System.Enum.ToInt(RoleAttr.RoleAttrSealResistRate)},
    {RoleAttr.RoleAttrMissRate, System.Enum.ToInt(RoleAttr.RoleAttrMissRate)},
    {RoleAttr.RoleAttrFightSpeed, System.Enum.ToInt(RoleAttr.RoleAttrFightSpeed)}
}
--侍从类型
local guardType = {
    { "物攻", "1800707170" },
    { "法攻", "1800707180" },
    { "治疗", "1800707190" },
    { "控制", "1800707210" },
    { "辅助", "1800707200" },
    { "全部", "" },
}
-- 品质
local quality = {
    {"1801205100","1800400330"},
    {"1801205110","1800400100"},
    {"1801205120","1800400110"},
    {"1801205130","1800400120"},
    {"1801205130","1800400320"},
}
-- 侍从技能品质等级右下图片
local _IconRightCornerRes = {
    "1801407010",
    "1801407020",
    "1801407030",
    "1801407040",
    "1801407050"
}
-- 侍从加成属性转换
local attrNameTransform = {
    ["血量上限"] = "血量",
    ["物理攻击"] = "攻击",
    ["法术攻击"] = "攻击",
    ["物理防御"] = "物御",
    ["法术防御"] = "法防",
    ["战斗速度"] = "速度",
    ["物暴率"] = "暴击",
    ["法爆率"] = "暴击"
}

-- 侍从ID
GuardInfoUI.GuardId = nil
-- 侍从加成信息 -- 服务器表单请求获取
GuardInfoUI.GuardAddAttrInfo = nil
-- 侍从主动技能信息 -- 服务器表单请求获取
GuardInfoUI.GuardSkillInfo = nil

-- 打开侍从信息的类型 1 自己有或没有的侍从 2 离线玩家的离线侍从
GuardInfoUI._type = nil


function GuardInfoUI.Main(guardId)

    -- 检查传入的侍从ID是否正确，如果不正确则默认使用观音菩萨ID
    local IsTrue_GuardId = false
    if guardId then

        guardId = tonumber(guardId)
        if guardId and DB.GetOnceGuardByKey1(guardId) then
            GuardInfoUI.GuardId = guardId
            IsTrue_GuardId = true
        end
        GuardInfoUI._type = 1
    else
        GuardInfoUI._type = 2
    end
    if not IsTrue_GuardId then
        GuardInfoUI.GuardId = 113 -- 观音菩萨
    end

    local panel = GUI.WndCreateWnd("GuardInfoUI", "GuardInfoUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "侍从信息", 760, 585, "GuardInfoUI", "OnExit", _gt)

    local guard_Bg = GUI.ImageCreate(panelBg, "guard_Bg", "1800400220", -174, 0, false, 1197, 639)
    _gt.BindName(guard_Bg,"guard_Bg")
    GUI.SetColor(guard_Bg, Color.New(1, 1, 1, 0))

    --侍从稀有度
    local middle_GuardRarity_Sprite = GUI.ImageCreate(guard_Bg, "middle_GuardRarity_Sprite", "1800714050", 135, 113)
    _gt.BindName(middle_GuardRarity_Sprite, "middle_GuardRarity_Sprite")
    UILayout.SetSameAnchorAndPivot(middle_GuardRarity_Sprite, UILayout.Top)

    --侍从伤害类型
    local middle_GuardType_Sprite = GUI.ImageCreate(guard_Bg, "middle_GuardType_Sprite", "1800707170", 175, 113)
    _gt.BindName(middle_GuardType_Sprite, "middle_GuardType_Sprite")
    UILayout.SetSameAnchorAndPivot(middle_GuardType_Sprite, UILayout.Top)

    local bottomShadow = GUI.ImageCreate(guard_Bg, "bottomShadow", "1800400240", -4, 314)
    _gt.BindName(bottomShadow, "bottomShadow")
    UILayout.SetSameAnchorAndPivot(bottomShadow, UILayout.Top)

    --显示升星上限
    for i = 1, GUARD_MAX_STAR do
        local star=GUI.ImageCreate(guard_Bg,"starPic"..tostring(i),"1801202192",494 + 35*(i-1),426,false,31,31)
        UILayout.SetSameAnchorAndPivot(star, UILayout.TopLeft)
        _gt.BindName(star, "starPic"..tostring(i))
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

    -- 侍从模型背景
    local model_Bg = GUI.ImageCreate(guard_Bg, "model_Bg", "1800400230", 0, 125)
    _gt.BindName(model_Bg, "model_Bg")
    UILayout.SetSameAnchorAndPivot(model_Bg, UILayout.Top)
    GUI.SetWidth(model_Bg,260)
    GUI.SetHeight(model_Bg,260)

    local _RoleLstNodeModel = _gt.GetUI("RoleLstNodeModel")
    if _RoleLstNodeModel == nil then
        local model_Bg= _gt.GetUI("model_Bg")
        _RoleLstNodeModel=GUI.RawImageCreate(model_Bg,false,"RoleLstNodeModel","",0,-71,2,false,392,392)
        _gt.BindName(_RoleLstNodeModel,"RoleLstNodeModel")
        _RoleLstNodeModel:RegisterEvent(UCE.Drag)
        _RoleLstNodeModel:RegisterEvent(UCE.PointerClick)
        GUI.AddToCamera(_RoleLstNodeModel)
        GUI.RawImageSetCameraConfig(_RoleLstNodeModel, "(0,1.41,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,10,0.01,1.2,0")
    end

    --模型
    local guardDB = DB.GetOnceGuardByKey1(113)
    local _RoleModel = _gt.GetUI("GuardModel")
    if _RoleModel == nil then
        _RoleModel = GUI.RawImageChildCreate(_RoleLstNodeModel, false, "GuardModel"..tostring(113),"", 0, 666)
        _gt.BindName(_RoleModel, "GuardModel")
        UILayout.SetSameAnchorAndPivot(_RoleModel, UILayout.Center)
        ModelItem.Bind(_RoleModel, guardDB.Model, guardDB.ColorID1, guardDB.ColorID2, eRoleMovement.ATTSTAND_W1)
        GUI.BindPrefabWithChild(_RoleLstNodeModel, GUI.GetGuid(_RoleModel))
        GUI.RawImageChildSetModleRotation(_RoleModel, Vector3.New(0,-45,0))
        GUI.RegisterUIEvent(_RoleModel, ULE.AnimationCallBack, "GuardInfoUI", "OnAnimationCallBack")
    else
        ModelItem.Bind(_RoleModel, guardDB.Model, guardDB.ColorID1, guardDB.ColorID2, eRoleMovement.ATTSTAND_W1)
        GUI.RawImageChildSetModleRotation(_RoleModel, Vector3.New(0,-45,0))
    end

    local _ModelClickPic = _gt.GetUI("ModelClickPic")
    if _ModelClickPic == nil then
        _ModelClickPic = GUI.ImageCreate(_RoleLstNodeModel, "ModelClickPic", "1800499999", 0, 0, false, 392, 392)
        _gt.BindName(_ModelClickPic, "ModelClickPic")
        UILayout.SetSameAnchorAndPivot(_ModelClickPic, UILayout.Center)
        GUI.SetIsRaycastTarget(_ModelClickPic, true)
        _ModelClickPic:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(_ModelClickPic, UCE.PointerClick, "GuardInfoUI", "OnClickGuardModel")
    end


    ----------------------------------------------右边
    local guardArr_Right = GUI.GroupCreate(panelBg,"guardArr_Right",-6, 60,360,515)
    UILayout.SetSameAnchorAndPivot(guardArr_Right,UILayout.TopRight)

    local guardAttr_Bg=GUI.ImageCreate(guardArr_Right,"guardAttr_Bg","1800400010",-2,0,false,344,515)
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
    local hpTxt=GUI.CreateStatic(guardAttr_Bg,"hpTxt",HPName,12,15,110,30,"system",true)
    UILayout.SetSameAnchorAndPivot(hpTxt, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(hpTxt, UIDefine.FontSizeS, UIDefine.BrownColor)
    local mpTxt=GUI.CreateStatic(guardAttr_Bg,"mpTxt",MPName,12,55,110,30,"system",true)
    UILayout.SetSameAnchorAndPivot(mpTxt, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(mpTxt, UIDefine.FontSizeS, UIDefine.BrownColor)

    local hpSlider=GUI.ScrollBarCreate(hpTxt,"hpSlider","","1800408120","1800408110",55,0,260,24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    GUI.ScrollBarSetFillSize(hpSlider,Vector2.New(260,24))
    GUI.ScrollBarSetBgSize(hpSlider,Vector2.New(260,24))
    UILayout.SetSameAnchorAndPivot(hpSlider, UILayout.Left)

    local txt = GUI.CreateStatic(hpSlider,"txt","3200/3200",-20,0,300,30,"system",true)
    GUI.StaticSetFontSize(txt,UIDefine.FontSizeSS)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    _gt.BindName(txt, "HPTxt")

    local mpSlider=GUI.ScrollBarCreate(mpTxt,"mpSlider","","1800408130","1800408110",55,0,260,24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    GUI.ScrollBarSetFillSize(mpSlider,Vector2.New(260,24))
    GUI.ScrollBarSetBgSize(mpSlider,Vector2.New(260,24))
    UILayout.SetSameAnchorAndPivot(mpSlider, UILayout.Left)
    local txt = GUI.CreateStatic(mpSlider,"txt","3200/3200",-20,0,300,30,"system",true)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt,UIDefine.FontSizeSS)
    _gt.BindName(txt, "MPTxt")

    local attrCount =#attrLst
    for i = 1, attrCount do
        local attrConfig = DB.GetOnceAttrByKey1(attrLst[i][2])
        if attrConfig then
            local attr_name=GUI.CreateStatic(guardAttr_Bg,"attr_name"..tostring(i),attrConfig.ChinaName,12+178*((i+1)%2),95+30*(math.floor((i-1)/2)),110,30)
            UILayout.SetSameAnchorAndPivot(attr_name, UILayout.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(attr_name, UIDefine.FontSizeS, UIDefine.BrownColor)
            local txt =GUI.CreateStatic(attr_name,"txt","9999999",55,0,330,30)
            _gt.BindName(txt, "attr_value"..tostring(i))
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.Yellow2Color)
        end
    end

    -- 侍从加成
    local pointImage = GUI.ImageCreate(guardAttr_Bg,"pointImage","1801208280",-150,6)
    UILayout.SetSameAnchorAndPivot(pointImage,UILayout.Center)

    local txt = GUI.CreateStatic(pointImage,"txt","侍从加成",130,12,226,56,"system",true)
    _gt.BindName(txt, "guardAddAttrTxt")
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt,UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt,UIDefine.FontSizeM)
    GUI.StaticSetText(txt,"侍从属性加成（零星）\n血量上限+0")

    local cutLine=GUI.ImageCreate(guardAttr_Bg,"cutLine","1800700190",0,310)
    UILayout.SetSameAnchorAndPivot(cutLine, UILayout.Top)
    local txt =GUI.CreateStatic(cutLine,"txt","侍从技能",27,0,150,30)
    _gt.BindName(txt, "guardSubTitle")
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetFontSize(txt,UIDefine.FontSizeM)

    --------------------技能列表

    local GuardSkillScroll = GUI.LoopScrollRectCreate(panelBg, "GuardSkillScroll", 196, 195, 400, 160,
            "GuardInfoUI", "CreateGuardSkillItem", "GuardInfoUI", "RefreshGuardSkillScroll", 0, false, Vector2.New(80, 80), 4, UIAroundPivot.Top, UIAnchor.Top);
    UILayout.SetSameAnchorAndPivot(GuardSkillScroll, UILayout.Center)
    _gt.BindName(GuardSkillScroll, "GuardSkillScroll")

end

function GuardInfoUI.OnShow()

    if GuardInfoUI._type == 1 then
        if GuardInfoUI.GuardId then
            GuardInfoUI.RefreshPage(GuardInfoUI.GuardId)
        end
    elseif GuardInfoUI._type == 2 then
        GuardInfoUI._refresh_offline()
    end

end

function GuardInfoUI.OnExit()
    GuardInfoUI._DestroyRoleEffectTable = {}
    GUI.DestroyWnd("GuardInfoUI")
end

----------------------------------------------------------------------- 技能格刷新
-- loopScrollRect的两个方法
function GuardInfoUI.CreateGuardSkillItem()
    local GuardSkillScroll = _gt.GetUI("GuardSkillScroll")
    local curCount =GUI.LoopScrollRectGetChildInPoolCount(GuardSkillScroll);

    local GuardSkillItem = GUI.ItemCtrlCreate(GuardSkillScroll, "GuardSkillItem" .. curCount, "1800400330", 0, 0, 89, 89)
    GUI.RegisterUIEvent(GuardSkillItem, UCE.PointerClick, "GuardInfoUI", "OnGuardSkillItemClick")

    -- 主动技能等级
    local levelBg=GUI.ImageCreate(GuardSkillItem, "levelBg",_IconRightCornerRes[1],-2,-3) -- 技能等级图片
    UILayout.SetAnchorAndPivot(levelBg, UIAnchor.BottomRight, UIAroundPivot.BottomRight)

    local txt =GUI.CreateStatic(levelBg, "txt","1",-5,-2,24,26); -- 技能等级文本
    UILayout.SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(txt,TextAnchor.MiddleCenter) -- 设置文本居中
    GUI.SetIsOutLine(txt,true); -- 是否描边
	GUI.SetOutLine_Setting(txt,OutLineSetting.OutLine_BlackColor_1)	
	GUI.SetOutLine_Color(txt,UIDefine.BlackColor)
    GUI.SetOutLine_Distance(txt,1)
    GUI.StaticSetFontSize(txt,UIDefine.FontSizeM);
    GUI.SetVisible(levelBg,false)

    GUI.ItemCtrlSetElementValue(GuardSkillItem,eItemIconElement.Icon,"1900000000") -- 默认显示的技能前景
    UILayout.SetAnchorAndPivot(GuardSkillItem, UIAnchor.Left, UIAroundPivot.Left)
    -- 调整 技能前景 的大小和位置
    local icon = GUI.ItemCtrlGetElement(GuardSkillItem,eItemIconElement.Icon)
    GUI.SetPositionY(icon,-1);
    GUI.SetWidth(icon,71);
    GUI.SetHeight(icon,70)

    return GuardSkillItem;
end

function GuardInfoUI.RefreshGuardSkillScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2])+1;

    local skillItem = GUI.GetByGuid(guid)
    local levelBg = GUI.GetChild(skillItem,"levelBg")
    local txt = GUI.GetChild(levelBg,"txt")

    local guardObj = nil -- 侍从对象
    local IsHaveGuard = nil -- 侍从是否存在
    if GuardInfoUI.GuardId then
        guardObj = DB.GetOnceGuardByKey1(GuardInfoUI.GuardId)
        IsHaveGuard = LD.IsHaveGuard(GuardInfoUI.GuardId)
    else
        test("GuardInfoUI 刷新侍从技能栏时 传入侍从ID为空 ")
        return
    end

    -- 如果是离线侍从，需要调整下 侍从是否存在数据
    if GuardInfoUI.GuardSkillInfo and GuardInfoUI.GuardSkillInfo.is_have_guard ~= nil then
        IsHaveGuard = GuardInfoUI.GuardSkillInfo.is_have_guard
    end

    local skill = nil
    if not IsHaveGuard then
        skill = DB.GetOnceSkillByKey1(guardObj["Skill"..index]) -- 获取此技能对象
    elseif GuardInfoUI.GuardSkillInfo then
        if GuardInfoUI.GuardSkillInfo["skill"..index] and GuardInfoUI.GuardSkillInfo["skill"..index][1] then
            skill = DB.GetOnceSkillByKey1(GuardInfoUI.GuardSkillInfo["skill"..index][1])
            -- 过滤不显示的技能
            if GlobalProcessing.filter_skill_of_guard_or_pet(skill) ~= true then
                skill = {["SkillQuality"]=0}
            end
        else
            skill = {["SkillQuality"]=0}
        end
    end
    -- 如果不是空技能
    if skill.SkillQuality ~= 0 then
        GUI.ItemCtrlSetElementValue(skillItem,eItemIconElement.Icon,tostring(skill.Icon)) -- 插入此技能图片
        GUI.ItemCtrlSetElementValue(skillItem,eItemIconElement.Border,quality[skill.SkillQuality][2]) -- 插入品质背景图片
        -- 修改技能品质标签和等级文本
        GUI.SetVisible(levelBg,true)
        GUI.ImageSetImageID(levelBg,_IconRightCornerRes[skill.SkillQuality])
        if IsHaveGuard then
            if GuardInfoUI.GuardSkillInfo then
                GUI.StaticSetText(txt,GuardInfoUI.GuardSkillInfo["skill"..index][2])
                GUI.SetData(skillItem, 'skill_level', GuardInfoUI.GuardSkillInfo["skill"..index][2])
            end
        else
            GUI.StaticSetText(txt,1)
            GUI.SetData(skillItem, 'skill_level', 1)
        end

        GUI.SetData(skillItem,"skill_id",skill.Id) -- 将技能id插入缓存，用于显示tips
    else
        GUI.ItemCtrlSetElementValue(skillItem,eItemIconElement.Icon,"") -- 插入此技能图片
        GUI.SetVisible(levelBg,false)
    end

    -- 显示 优先 字
    if(index == guardObj.First) then
        GUI.ItemCtrlSetElementValue(skillItem,eItemIconElement.LeftTopSp ,"1800707100")
    else
        GUI.ItemCtrlSetElementValue(skillItem,eItemIconElement.LeftTopSp ,"")
    end

end

---------------------------------------------------------------------- 页面刷新
-- 刷新整个页面
function GuardInfoUI.RefreshPage(guardId)
    if guardId == nil then return end
    local IsHaveGuard = LD.IsHaveGuard(guardId) -- 侍从是否拥有

    local guardObj = DB.GetOnceGuardByKey1(guardId) -- 侍从对象
    local curLevel = IsHaveGuard and CL.GetIntAttr(RoleAttr.RoleAttrLevel) or 1

    -- 刷新品质
    local grade = _gt.GetUI("middle_GuardRarity_Sprite")
    GUI.ImageSetImageID(grade,quality[guardObj.Quality][1])

    -- 刷新类型
    local type = _gt.GetUI("middle_GuardType_Sprite")
    GUI.ImageSetImageID(type,guardType[guardObj.Type][2])

    -- 侍从星级
    local starLevel = IsHaveGuard and CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(guardId))) or 1
    for i = 1, GUARD_MAX_STAR do
        local star = _gt.GetUI("starPic"..tostring(i))
        GUI.ImageSetImageID(star, starLevel>=i and "1801202190" or "1801202192")
    end

    -- 侍从名称
    local name = _gt.GetUI("guardName")
    GUI.StaticSetText(name,guardObj.Name)

    -- 侍从等级
    local level = _gt.GetUI("guardLevel")
    GUI.StaticSetText(level,curLevel.."级")

    -- 侍从战力
    local fightValue = _gt.GetUI("guardFightValue")
    GUI.StaticSetText(fightValue, IsHaveGuard and tostring(LD.GetGuardAttr(guardId, RoleAttr.RoleAttrFightValue)) or "待激活")

    -- 侍从模型
    local _RoleModel = _gt.GetUI("GuardModel")
    ModelItem.Bind(_RoleModel, guardObj.Model, guardObj.ColorID1, guardObj.ColorID2, eRoleMovement.ATTSTAND_W1)
    GUI.RawImageChildSetModleRotation(_RoleModel, Vector3.New(0,-45,0))

    -- 添加人物特效
    GuardInfoUI.addRoleEffect(guardId)

    --显示属性
    local guardExtraConfig1 = DB.GetGuard_Extra(guardId, 1)
    local guardExtraConfigMax = DB.GetGuard_Extra(guardId, GUARD_MAX_LEVEL)
    if guardExtraConfig1 and guardExtraConfigMax then
        local GUARD_MAX_LEVEL_BASE = GUARD_MAX_LEVEL-1
        if GUARD_MAX_LEVEL == 1 then
            GUARD_MAX_LEVEL_BASE = 1
        end
        local GuardAttrTbValue = {}
        local attrCount = #attrLst
        if not IsHaveGuard then
            GuardAttrTbValue = {math.floor(guardExtraConfig1.PhyAtk + (guardExtraConfigMax.PhyAtk-guardExtraConfig1.PhyAtk)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
                                math.floor(guardExtraConfig1.MagAtk + (guardExtraConfigMax.MagAtk-guardExtraConfig1.MagAtk)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
                                math.floor(guardExtraConfig1.PhyDef + (guardExtraConfigMax.PhyDef-guardExtraConfig1.PhyDef)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
                                math.floor(guardExtraConfig1.MagDef + (guardExtraConfigMax.MagDef-guardExtraConfig1.MagDef)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
                                math.floor(guardExtraConfig1.PhyBurstLv + (guardExtraConfigMax.PhyBurstLv-guardExtraConfig1.PhyBurstLv)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
                                math.floor(guardExtraConfig1.MagBurstLv + (guardExtraConfigMax.MagBurstLv-guardExtraConfig1.MagBurstLv)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
                                math.floor(guardExtraConfig1.ResistanceLv + (guardExtraConfigMax.ResistanceLv-guardExtraConfig1.ResistanceLv)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
                                math.floor(guardExtraConfig1.Resistance + (guardExtraConfigMax.Resistance-guardExtraConfig1.Resistance)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
                                math.floor(guardExtraConfig1.Miss + (guardExtraConfigMax.Miss-guardExtraConfig1.Miss)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
                                math.floor(guardExtraConfig1.Speed + (guardExtraConfigMax.Speed-guardExtraConfig1.Speed)*(curLevel-1)/GUARD_MAX_LEVEL_BASE),
            }
        else
            for i = 1, attrCount do
                table.insert(GuardAttrTbValue, tonumber(tostring(LD.GetGuardAttr(guardId, attrLst[i][1]))))
            end
        end
        for i = 1, attrCount do
            local sttrConfig = DB.GetOnceAttrByKey1(attrLst[i][2])
            if sttrConfig and sttrConfig.IsPct == 1 then
                GuardAttrTbValue[i] = tostring(math.floor(GuardAttrTbValue[i]/100)).."%"
            end
        end

        for i = 1, attrCount do
            local attr_value = _gt.GetUI("attr_value"..tostring(i))
            GUI.StaticSetText(attr_value,tostring(GuardAttrTbValue[i]))
        end
        --红蓝量
        local txt = _gt.GetUI("HPTxt")
        if txt then
            local num = 0
            if not IsHaveGuard then
                num = math.floor(guardExtraConfig1.HP + (guardExtraConfigMax.HP-guardExtraConfig1.HP)*(curLevel-1)/GUARD_MAX_LEVEL_BASE)
            else
                num = LD.GetGuardAttr(guardId, RoleAttr.RoleAttrHpLimit)
            end
            GUI.StaticSetText(txt, tostring(num).."/"..tostring(num))
        end
        local txt = _gt.GetUI("MPTxt")
        if txt then
            local num = 0
            if not IsHaveGuard then
                num = math.floor(guardExtraConfig1.MP + (guardExtraConfigMax.MP-guardExtraConfig1.MP)*(curLevel-1)/GUARD_MAX_LEVEL_BASE)
            else
                num = LD.GetGuardAttr(guardId, RoleAttr.RoleAttrMpLimit)
            end
            GUI.StaticSetText(txt, tostring(num).."/"..tostring(num))
        end
    end


    -- 侍从加成
    if IsHaveGuard then
        GuardInfoUI.getAddAttrInfo(guardId) -- 向服务器发送请求 后执行回调方法刷新
    else
        GuardInfoUI.get_add_attr_info_1(guardId)
    end

    -- 刷新技能
    if IsHaveGuard then
        GuardInfoUI.getActiveSkillInfo(guardId)
    else
        local GuardSkillScroll = _gt.GetUI("GuardSkillScroll")
        GUI.LoopScrollRectSetTotalCount(GuardSkillScroll,8)
    end

end

-- 创建技能tips事件
function GuardInfoUI.OnGuardSkillItemClick(guid)
    -- 获取   技能的id  父类
    local skill_bg =  GUI.GetByGuid(guid)
    local skill_id = GUI.GetData(skill_bg,"skill_id") -- 技能id
    local skill_level = GUI.GetData(skill_bg, 'skill_level')
    local panelBg = _gt.GetUI("panelBg") -- 父类
    -- 如果技能为空，则不需要注册事件，须处理
    if skill_id then -- 判断技能id是否存在
        if skill_level then
            Tips.CreateSkillId(tonumber(skill_id),panelBg,"activeSkill_Tips",0,0,0,0, skill_level)
        else
            Tips.CreateSkillId(tonumber(skill_id),panelBg,"activeSkill_Tips",0,0,0,0)
        end
    end

end

-- 向服务器发送请求侍从加成的数据
function GuardInfoUI.getAddAttrInfo(guardId)
    if not guardId then return end
    local guardGuid = LD.GetGuardGUIDByID(guardId) -- 获取侍从GUID
    if guardGuid then
        CL.SendNotify(NOTIFY.SubmitForm,"FormGuardInfo","GetAddAttrInfo",tostring(guardGuid))
        -- 得到数据 GuardInfoUI.GuardAddAttrInfo
        -- 执行刷新方法 GuardInfoUI.RefreshGuardAddAttr
    end
end

--  向服务器发送请求获取侍从一星加成属性数据
function  GuardInfoUI.get_add_attr_info_1(guard_id)
    CL.SendNotify(NOTIFY.SubmitForm, 'FormGuardInfo', 'get_add_attr_info', tostring(guard_id))
    -- 得到数据 GuardInfoUI.GuardAddAttrInfo
    -- 执行刷新方法 GuardInfoUI.RefreshGuardAddAttr
end

-- 刷新侍从加成的回调函数
function GuardInfoUI.RefreshGuardAddAttr()
    if GuardInfoUI.GuardAddAttrInfo then
        local addTxt = _gt.GetUI("guardAddAttrTxt")
        local numberToChina = {"一","二","三","四","五","六"}
        local level = numberToChina[GuardInfoUI.GuardAddAttrInfo.Level]
        --local num = GuardInfoUI.GuardAddAttrInfo.Attr.Num
        local addAttrName = GuardInfoUI.GuardAddAttrInfo.Attr.Id and attrNameTransform[DB.GetOnceAttrByKey1(GuardInfoUI.GuardAddAttrInfo.Attr.Id).KeyName] or ""
        local addStr = "侍从属性加成（零星）\n"..tostring(addAttrName).."上限+".. 0
        if level ~= nil  then
            addStr = "侍从属性加成（".. tostring(numberToChina[GuardInfoUI.GuardAddAttrInfo.Level]) .."星）\n"..addAttrName.."上限+".. tostring(GuardInfoUI.GuardAddAttrInfo.Attr.Num)
        end
        GUI.StaticSetText(addTxt,addStr)
    else
        test("GuardInfoUI,向服务器请求侍从加成数据GuardInfoUI.GuardAddAttrInfo为空")
    end

end

-- 向服务器发送获取侍从主动技能信息的请求
function GuardInfoUI.getActiveSkillInfo(guardId)
    if not guardId then return end
    local guardGuid = LD.GetGuardGUIDByID(guardId) -- 获取侍从GUID
    if guardGuid then
        CL.SendNotify(NOTIFY.SubmitForm,"FormGuardInfo","GetSkillInfo",tostring(guardGuid))
        -- 得到数据 GuardInfoUI.GuardSkillInfo
        -- 执行刷新方法 GuardInfoUI.RefreshActiveSkill()
    end
end
-- 刷新侍从主动技能
function GuardInfoUI.RefreshActiveSkill()

    if GuardInfoUI.GuardSkillInfo then
        local GuardSkillScroll = _gt.GetUI("GuardSkillScroll")
        GUI.LoopScrollRectSetTotalCount(GuardSkillScroll,8)
    else
        test("GuardInfoUI,刷新侍从主动技能GuardInfoUI.GuardSkillInfo为空")
    end
end

-- 点击侍从动作事件
function GuardInfoUI.OnClickGuardModel()
    local model = _gt.GetUI("GuardModel")
    if model then
        GUI.ReplaceWeapon(model,0,eRoleMovement.PHYATT_W1,0)
    end
end
-- 添加侍从点击模型动画回调函数
function GuardInfoUI.OnAnimationCallBack(guid, action)
    if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
        return
    end
    local model = _gt.GetUI("GuardModel")
    if model then
        GUI.ReplaceWeapon(model,0,eRoleMovement.ATTSTAND_W1,0)
    end
end

-- 添加侍从特效
-- 人物特效表 从二星开始
local _RoleEffectTable = {
    10,11,12,13,14
}
-- 销毁人物特效ID列表
GuardInfoUI._DestroyRoleEffectTable = {}

function GuardInfoUI.addRoleEffect(guardId)

    local _RoleModel = _gt.GetUI("GuardModel") -- 获取人物模型
    if _RoleModel == nil then
        test("添加人物气势特效时，获取人物模型为空")
        return
    end

    if guardId == nil then
        test("添加人物气势特效时，获取选中侍从ID为空")
        return
    end

    -- 删除人物特效
    local DestroyRoleEffectID = GuardInfoUI._DestroyRoleEffectTable[tostring(guardId)]
    if DestroyRoleEffectID ~= nil then -- 获取创建特效时得到的特效ID
        GUI.DestroyRoleEffect(_RoleModel,DestroyRoleEffectID)
        GuardInfoUI._DestroyRoleEffectTable[tostring(guardId)] = nil
    end
    -- 获取人物当前星级
    local currentSelectedGuardStar = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(guardId)))

    -- 添加人物特效
    if currentSelectedGuardStar > 1 then -- 防止星级为1
        local newDestroyRoleEffectID =  GUI.CreateRoleEffect(_RoleModel, _RoleEffectTable[currentSelectedGuardStar-1]) -- 添加人物特效
        -- 更新销毁人物特效ID
        GuardInfoUI._DestroyRoleEffectTable[tostring(guardId)] = newDestroyRoleEffectID
    end
end



------------------------------------------------------------ start 获取离线侍从信息 start --------------------------------------------------------------------------
-- 侍从数据
GuardInfoUI._guard_data = nil
-- 插入数据
function GuardInfoUI.set_guard_data(data)
    if data then
        GuardInfoUI._guard_data = data
    end
end


-- 刷新界面
function GuardInfoUI._refresh_offline()
    if not GuardInfoUI._guard_data then return end
    local data = GuardInfoUI._guard_data

    local attrList = {}
    
    -- 侍从id
    local guard_id = nil
    -- 侍从等级
    local guard_level = nil
    -- 侍从气血
    local guard_hp = nil
    -- 侍从魔法
    local guard_mp = nil
    -- 侍从战力
    local guard_combat_power = nil
    
    -- 侍从成长率
    -- 侍从技能
    local skills = {}
    -- 侍从星级
    local star = nil
    -- 侍从加成
    -- 侍从加成等级
    local add_attr_level = nil
    -- 侍从加成属性id
    local add_attr_id = nil
    -- 侍从加成值
    local add_attr_num = nil

    -- 侍从id 等级 气血 魔法 战力
    for i=0, data.attrs.Count-1 do
        local attr = data.attrs[i].attr
        local name = DB.GetOnceAttrByKey1(attr).KeyName

        attrList[name] = tonumber(tostring(data.attrs[i].value))
    end

    guard_id = attrList['id']
    guard_level = attrList['等级']
    guard_hp = attrList['血量上限']
    guard_mp = attrList['法力上限']
    guard_combat_power = attrList['战力值']

    -- 侍从技能 侍从星级 加成
    for i = 0 ,data.customs.intdata.Count -1  do
        local customs = data.customs.intdata[i]
        -- 侍从技能
            -- 技能id
        if customs.key == 'GuardSkillID_1' then
            skills.skill_id_1 = tonumber(tostring(customs.value))
        elseif customs.key == 'GuardSkillID_2' then
            skills.skill_id_2 = tonumber(tostring(customs.value))
        elseif customs.key == 'GuardSkillID_3' then
            skills.skill_id_3 = tonumber(tostring(customs.value))
        elseif customs.key == 'GuardSkillID_4' then
            skills.skill_id_4 = tonumber(tostring(customs.value))
            -- 技能等级
        elseif customs.key == 'GuardSkillLV_1' then
            skills.skill_level_1 = tonumber(tostring(customs.value))
        elseif customs.key == 'GuardSkillLV_2' then
            skills.skill_level_2 = tonumber(tostring(customs.value))
        elseif customs.key == 'GuardSkillLV_3' then
            skills.skill_level_3 = tonumber(tostring(customs.value))
        elseif customs.key == 'GuardSkillLV_4' then
            skills.skill_level_4 = tonumber(tostring(customs.value))
        -- 侍从星级
        elseif customs.key == 'Guard_Star' then
            star = tonumber(tostring(customs.value))
        -- 侍从加成
            -- 侍从加成属性id
        elseif customs.key == 'Attr_Add_AttrId' then
            add_attr_id = tonumber(tostring(customs.value))
            -- 侍从加成值
        elseif customs.key == 'Attr_Add_AttrNum' then
            add_attr_num = tonumber(tostring(customs.value))
            -- 侍从加成等级
        elseif customs.key == 'Attr_Add_Level' then
            add_attr_level = tonumber(tostring(customs.value))
        end
    end


    GuardInfoUI.GuardId = guard_id
    local guardId = guard_id
    local guardObj = DB.GetOnceGuardByKey1(guardId) -- 侍从对象
    local curLevel = guard_level

    -- 刷新品质
    local grade = _gt.GetUI("middle_GuardRarity_Sprite")
    GUI.ImageSetImageID(grade,quality[guardObj.Quality][1])

    -- 刷新类型
    local type = _gt.GetUI("middle_GuardType_Sprite")
    GUI.ImageSetImageID(type,guardType[guardObj.Type][2])

    -- 侍从星级
    local starLevel = star or 1
    for i = 1, GUARD_MAX_STAR do
        local star = _gt.GetUI("starPic"..tostring(i))
        GUI.ImageSetImageID(star, starLevel >= i and "1801202190" or "1801202192")
    end

    -- 侍从名称
    local name = _gt.GetUI("guardName")
    GUI.StaticSetText(name,guardObj.Name)

    -- 侍从等级
    local level = _gt.GetUI("guardLevel")
    GUI.StaticSetText(level,curLevel.."级")

    -- 侍从战力
    local fightValue = _gt.GetUI("guardFightValue")
    GUI.StaticSetText(fightValue, guard_combat_power)

    -- 侍从模型
    local _RoleModel = _gt.GetUI("GuardModel")
    ModelItem.Bind(_RoleModel, guardObj.Model, guardObj.ColorID1, guardObj.ColorID2, eRoleMovement.ATTSTAND_W1)
    GUI.RawImageChildSetModleRotation(_RoleModel, Vector3.New(0,-45,0))

    -- 添加人物特效
    GuardInfoUI.addRoleEffect(guardId)


    for i = 1, #attrLst do
        local sttrConfig = DB.GetOnceAttrByKey1(attrLst[i][2])
        local keyName = sttrConfig.KeyName
        if sttrConfig and sttrConfig.IsPct == 1 then
            if attrList and attrList[keyName] then
                attrList[keyName] = tostring(math.floor(attrList[keyName]/100)).."%"
            else
                test('错误: GuardInfoUI 侍从信息界面获取不到该侍从属性数据')
            end
        end
        local attr_value = _gt.GetUI("attr_value"..tostring(i))
        GUI.StaticSetText(attr_value,tostring(attrList[keyName]))
    end

    --红蓝量
    local txt = _gt.GetUI("HPTxt")
    if txt then
        local num = guard_hp

        GUI.StaticSetText(txt, tostring(num).."/"..tostring(num))
    end
    local txt = _gt.GetUI("MPTxt")
    if txt then
        local num = guard_mp

        GUI.StaticSetText(txt, tostring(num).."/"..tostring(num))
    end

    -- 侍从加成
    local add_attr = {
        Attr = {
            Id = add_attr_id ,
            Num = add_attr_num
        },
        Level = add_attr_level
    }

    -- 将所需要的数据放入对应的容器，然后执行刷新
    GuardInfoUI.GuardAddAttrInfo = add_attr
    GuardInfoUI.RefreshGuardAddAttr()


    -- 刷新技能
    local skill_info = {
        skill1 = {
            skills.skill_id_1,
            skills.skill_level_1
        },
        skill2 = {
            skills.skill_id_2,
            skills.skill_level_2
        },
        skill3 = {
            skills.skill_id_3,
            skills.skill_level_3
        },
        skill4 = {
            skills.skill_id_4,
            skills.skill_level_4
        },
        is_have_guard = true
    }
    GuardInfoUI.GuardSkillInfo = skill_info
    GuardInfoUI.RefreshActiveSkill()

end
------------------------------------------------------------ end 获取离线侍从信息 end --------------------------------------------------------------------------
