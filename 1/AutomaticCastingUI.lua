local AutomaticCastingUI = {}
_G.AutomaticCastingUI = AutomaticCastingUI

--自动施法界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local _gt = UILayout.NewGUIDUtilTable()

require("jsonUtil")

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

------------------------------------------Start 颜色配置 Start----------------------------------
local RedColor = UIDefine.RedColor
local BrownColor = UIDefine.BrownColor
local Brown4Color = UIDefine.Brown4Color
local Brown6Color = UIDefine.Brown6Color
local WhiteColor = UIDefine.WhiteColor
local White2Color = UIDefine.White2Color
local White3Color = UIDefine.White3Color
local GrayColor = UIDefine.GrayColor
local Gray2Color = UIDefine.Gray2Color
local Gray3Color = UIDefine.Gray3Color
local OrangeColor = UIDefine.OrangeColor
local GreenColor = UIDefine.GreenColor
local Green2Color = UIDefine.Green2Color
local Green3Color = UIDefine.Green3Color
local Blue3Color = UIDefine.Blue3Color
local Purple2Color = UIDefine.Purple2Color
local PinkColor = UIDefine.PinkColor
local OutLineDistance = UIDefine.OutLineDistance
local OutLine_BrownColor = UIDefine.OutLine_BrownColor
local Green5Color = Color.New(6/255, 129/255, 43/255, 255/255)
local colorOutline = Color.New(175/255, 96/255, 19/255, 255/255)
----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------


----------------------------------------------End 全局变量 End---------------------------------

local subTabIndex1 = 1
local subTabIndex2 = 1

local lastClickLeftTabGuid = nil

------------------------------------------Start 表配置 Start----------------------------------

local turnAbleSubTabList = {
    { "人物", "SubTabBtn1", "1800402180", "1800402181", "OnSubTabBtn1Click", -205, -210, 145, 55, 100, 40 },
    { "宠物", "SubTabBtn2", "1800402180", "1800402181", "OnSubTabBtn2Click", -50, -210, 145, 55, 100, 40 },
}

local showSkillIdTable = {
    role = {},
    pet = {}
}

local petSkillTable = {
    [1] = {},
    [2] = {},
    [3] = {},
}


--------------------------------------------End 表配置 End------------------------------------

function AutomaticCastingUI.Main(parameter)
    local panel = GUI.WndCreateWnd("AutomaticCastingUI" , "AutomaticCastingUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "",590,610,"AutomaticCastingUI","OnExit",_gt)
    _gt.BindName(panelBg,"panelBg")

    local renameBtn = GUI.ButtonCreate(panelBg, "renameBtn", "1800402120", 90, 9, Transition.ColorTint)
    SetSameAnchorAndPivot(renameBtn, UILayout.Top)
    GUI.RegisterUIEvent(renameBtn, UCE.PointerClick, "AutomaticCastingUI", "OnRenameBtnClick")


    local centerBg = GUI.ImageCreate(panelBg, "centerBg", "1800400200", 0, 125, false,560, 400)
    SetSameAnchorAndPivot(centerBg, UILayout.Top)

    local skillLoop =
    GUI.LoopScrollRectCreate(
            centerBg,
            "skillLoop",
            0,
            8,
            540,
            380,
            "AutomaticCastingUI",
            "CreateSkillItem",
            "AutomaticCastingUI",
            "RefreshSkillItem",
            0,
            false,
            Vector2.New(540, 130),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(skillLoop, UILayout.Top)
    GUI.ScrollRectSetAlignment(skillLoop, TextAnchor.UpperLeft)
    _gt.BindName(skillLoop, "skillLoop")
    GUI.ScrollRectSetChildSpacing(skillLoop, Vector2.New(3, 3))

    UILayout.CreateSubTab(turnAbleSubTabList, panelBg, "AutomaticCastingUI")

    local applyBtn = GUI.ButtonCreate(panelBg, "applyBtn", "1800402090", 0, -25, Transition.ColorTint, "保 存", 150, 50, false)
    GUI.SetEventCD(applyBtn, UCE.PointerClick, 1)
    GUI.ButtonSetTextFontSize(applyBtn, 25)
    GUI.SetIsOutLine(applyBtn, true)
    GUI.ButtonSetTextColor(applyBtn, WhiteColor)
    GUI.SetOutLine_Color(applyBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(applyBtn,OutLineDistance)
    SetSameAnchorAndPivot(applyBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(applyBtn, UCE.PointerClick, "AutomaticCastingUI", "OnApplyBtnClick")


end

function AutomaticCastingUI.OnShow(parameter)
    local wnd = GUI.GetWnd("AutomaticCastingUI")
    
    if wnd == nil then
        return
    end

    -- 获取角色等级
    local curLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    if GlobalProcessing.AutomaticCasting_OpenLevel and curLevel >= GlobalProcessing.AutomaticCasting_OpenLevel  then

        if UIDefine.FunctionSwitch["AutomaticCasting"] and UIDefine.FunctionSwitch["AutomaticCasting"] == "on" then


        else

            return

        end


    else

        return

    end
    

    GUI.SetVisible(wnd, true)


    AutomaticCastingUI.Init()

    local index1, index2 = UIDefine.GetParameterStr(parameter)

    subTabIndex1 = tonumber(index1) ~= nil and tonumber(index1) or subTabIndex1
    subTabIndex2 = tonumber(index2) ~= nil and tonumber(index2) or subTabIndex2

    test("parameter",parameter)

    AutomaticCastingUI.Init()

    --刷新自动挂机施放技能的技能id
    GlobalProcessing.RefreshAutomaticCastingData()

    AutomaticCastingUI.SetTitleName()

    local panelBg = _gt.GetUI("panelBg")
    --创建或刷新左边页签
    AutomaticCastingUI.CreateOrRefreshLeftTab(panelBg)

    CL.UnRegisterMessage(GM.FightUpdateSkill, "AutomaticCastingUI", "OnRoleAutoFightSkill")
    CL.RegisterMessage(GM.FightUpdateSkill, "AutomaticCastingUI", "OnRoleAutoFightSkill")

    UILayout.OnSubTabClickEx(subTabIndex2, turnAbleSubTabList)
end


function AutomaticCastingUI.Init()

    petSkillTable = {
        [1] = {},
        [2] = {},
        [3] = {},
    }


end

--服务器回调刷新
function AutomaticCastingUI.RefreshAllData()

    test("服务器回调刷新")

    local panelBg = _gt.GetUI("panelBg")
    --创建或刷新左边页签
    AutomaticCastingUI.CreateOrRefreshLeftTab(panelBg)

    --设置顶部标题名字
    AutomaticCastingUI.SetTitleName()

    --设置loop技能表
    AutomaticCastingUI.SetSkillTableData()

end

function AutomaticCastingUI.CreateSkillItem()
    local skillLoop = _gt.GetUI("skillLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(skillLoop) + 1

    local skillCheckBox = GUI.CheckBoxExCreate(skillLoop, "skillCheckBox"..index,"1801100010", "1801100010",0, 0, false,90, 32,false)
    GUI.RegisterUIEvent(skillCheckBox, UCE.PointerClick , "AutomaticCastingUI", "OnSkillCheckBoxClick")

    local btnSelectImage = GUI.ImageCreate(skillCheckBox, "btnSelectImage", "1800802030", 60, 0, false, 110, 110)
    SetSameAnchorAndPivot(btnSelectImage, UILayout.Left)

    --技能图标
    local skillShow = GUI.ButtonCreate(btnSelectImage, "skillShow", "1800302210", -1,-2,Transition.ColorTint,"",87,87,false)
    SetSameAnchorAndPivot(skillShow, UILayout.Center)
    GUI.SetIsRaycastTarget(skillShow, true)
    skillShow:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(skillShow, UCE.PointerClick , "AutomaticCastingUI", "OnSkillShowClick")

    --技能类型
    local skillCornerLabel = GUI.ImageCreate(skillShow,"skillCornerLabel","1800807050",5,-5)
    SetSameAnchorAndPivot(skillCornerLabel, UILayout.TopRight)

    --是否被选中
    local statusImg = GUI.CheckBoxExCreate(skillCheckBox,"statusImg", "1800007011", "1800007010", 10, 0,  false, 50, 50)
    SetSameAnchorAndPivot(statusImg, UILayout.Left)
    GUI.RegisterUIEvent(statusImg, UCE.PointerClick , "AutomaticCastingUI", "OnStatusImgClick")

    local nameTxt = GUI.CreateStatic(skillCheckBox, "nameTxt", "技能名字", 35, 25, 240, 35, "system", true)
    SetSameAnchorAndPivot(nameTxt, UILayout.Top)
    GUI.StaticSetFontSize(nameTxt, 26)
    GUI.SetColor(nameTxt, Color.New(247 / 255, 232 / 255, 184 / 255, 255 / 255))
    GUI.SetIsOutLine(nameTxt, true)
    GUI.SetOutLine_Color(nameTxt, OutLine_BrownColor);
    GUI.SetOutLine_Distance(nameTxt,3)
    GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleLeft)

    local detailedTxt = GUI.CreateStatic(skillCheckBox, "detailedTxt", "技能介绍", 45, 75, 260, 35, "system", true)
    SetSameAnchorAndPivot(detailedTxt, UILayout.Top)
    GUI.StaticSetFontSize(detailedTxt, 23)
    GUI.SetColor(detailedTxt, Green5Color)
    GUI.StaticSetAlignment(detailedTxt, TextAnchor.MiddleLeft)


    --是否被选中
    local underwayImg = GUI.ImageCreate(skillCheckBox,"underwayImg","1800604460",-100,25)
    local sc = 1
    GUI.SetScale(underwayImg, Vector3.New(sc, sc, sc))
    SetSameAnchorAndPivot(underwayImg, UILayout.TopRight)

    local upBtn = GUI.ButtonCreate(skillCheckBox, "upBtn", "1800302170", -50,30,Transition.ColorTint,"")
    local sc = 1.4
    GUI.SetScale(upBtn, Vector3.New(sc, sc, sc))
    GUI.SetEulerAngles(upBtn,Vector3.New(0,0 , -90)) --重置旋转
    SetSameAnchorAndPivot(upBtn, UILayout.Right)
    GUI.RegisterUIEvent(upBtn, UCE.PointerClick , "AutomaticCastingUI", "OnUpBtnClick")

    return skillCheckBox

end

function AutomaticCastingUI.RefreshSkillItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = nil

    if subTabIndex2 == 1 then

        data = showSkillIdTable.role[index]

    elseif subTabIndex2 == 2 then

        data = showSkillIdTable.pet[index]

    end

    if data ~= nil then

        local skillDB = DB.GetOnceSkillByKey1(data.skill_id)

        local btnSelectImage = GUI.GetChild(item,"btnSelectImage",false)
        local statusImg = GUI.GetChild(item,"statusImg",false)
        local nameTxt = GUI.GetChild(item,"nameTxt",false)
        local detailedTxt = GUI.GetChild(item,"detailedTxt",false)
        local underwayImg = GUI.GetChild(item,"underwayImg",false)
        local upBtn = GUI.GetChild(item,"upBtn",false)



        local skillShow = GUI.GetChild(btnSelectImage,"skillShow",false)

        GUI.ButtonSetImageID(skillShow, tostring(skillDB.Icon)+3)

        local skillCornerLabel = GUI.GetChild(skillShow,"skillCornerLabel",false)

        if subTabIndex2 == 1 then

            GUI.ImageSetImageID(skillCornerLabel, "1800807050")

        else

            GUI.ImageSetImageID(skillCornerLabel, "1800807060")

        end


        if data.status == 1 then

            GUI.CheckBoxExSetCheck(statusImg, true)

            if index == 1 then

                GUI.SetVisible(upBtn,false)

            else

                GUI.SetVisible(upBtn,true)

            end

        else

            GUI.CheckBoxExSetCheck(statusImg, false)

            GUI.SetVisible(upBtn,false)

        end

        GUI.SetData(statusImg,"index",index)

        GUI.SetData(upBtn,"index",index)

        GUI.SetData(skillShow,"skillId",data.skill_id)

        GUI.StaticSetText(nameTxt,skillDB.Name)

        local Skill_Id = nil


        if CL.GetFightState() then

            if subTabIndex2 == 1 then

                Skill_Id = CL.OnGetAutoFightSkill(false)

            elseif subTabIndex2 == 2 then

                Skill_Id = CL.OnGetAutoFightSkill(true)

            end

            if data.skill_id == Skill_Id then


                GUI.SetVisible(underwayImg,true)


            else

                GUI.SetVisible(underwayImg,false)

            end

        else

            GUI.SetVisible(underwayImg,false)

        end



        local hurtTypeInfo = string.split(skillDB.DisplayDamageType, "|")

        if tonumber(skillDB.CoolDown) > 0 then

            GUI.StaticSetText(detailedTxt,hurtTypeInfo[1].."、冷却"..skillDB.CoolDown.."回合")

        else

            GUI.StaticSetText(detailedTxt,hurtTypeInfo[1].."、无冷却")

        end




    end

end

--上移按钮点击事件
function AutomaticCastingUI.OnUpBtnClick(guid)

    test("上移按钮点击事件")

    local upBtn = GUI.GetByGuid(guid)

    local index = tonumber(GUI.GetData(upBtn,"index"))

    if subTabIndex2 == 1 then

        local temp = showSkillIdTable.role[index - 1]

        table.remove(showSkillIdTable.role,index - 1)

        table.insert(showSkillIdTable.role,index,temp)

    elseif subTabIndex2 == 2 then

        local temp = showSkillIdTable.pet[index - 1]

        table.remove(showSkillIdTable.pet,index - 1)

        table.insert(showSkillIdTable.pet,index,temp)

    end

    --刷新技能loop数据
    AutomaticCastingUI.RefreshSkillLoopData()

end

--checkbox点击事件
function AutomaticCastingUI.OnSkillCheckBoxClick(guid)

    local checkbox = GUI.GetByGuid(guid)

    local statusImg = GUI.GetChild(checkbox,"statusImg",false)

    local index = tonumber(GUI.GetData(statusImg,"index"))

    if subTabIndex2 == 1 then

        if showSkillIdTable.role[index].status == 1 then

            showSkillIdTable.role[index].status = 0

        else

            showSkillIdTable.role[index].status = 1

        end

    elseif subTabIndex2 == 2 then

        if showSkillIdTable.pet[index].status == 1 then

            showSkillIdTable.pet[index].status = 0

        else

            showSkillIdTable.pet[index].status = 1

        end

    end

    --刷新技能loop数据
    AutomaticCastingUI.RefreshSkillLoopData()
end

--是否被选中checkbox点击事件
function AutomaticCastingUI.OnStatusImgClick(guid)

    test("是否被选中checkbox点击事件")

    local checkbox = GUI.GetByGuid(guid)

    local index = tonumber(GUI.GetData(checkbox,"index"))

    if subTabIndex2 == 1 then

        if showSkillIdTable.role[index].status == 1 then

            showSkillIdTable.role[index].status = 0

        else

            showSkillIdTable.role[index].status = 1

        end

    elseif subTabIndex2 == 2 then

        if showSkillIdTable.pet[index].status == 1 then

            showSkillIdTable.pet[index].status = 0

        else

            showSkillIdTable.pet[index].status = 1

        end

    end

    --刷新技能loop数据
    AutomaticCastingUI.RefreshSkillLoopData()

end

--人物技能页签点击事件
function AutomaticCastingUI.OnSubTabBtn1Click()

    test("人物技能页签点击事件")

    subTabIndex2 = 1

    --设置loop技能表
    AutomaticCastingUI.SetSkillTableData()

end

--宠物技能页签点击事件
function AutomaticCastingUI.OnSubTabBtn2Click()

    test("宠物技能页签点击事件")

    subTabIndex2 = 2

    --设置loop技能表
    AutomaticCastingUI.SetSkillTableData()

end

--设置loop技能表
function AutomaticCastingUI.SetSkillTableData()

    showSkillIdTable = {
        role = {},
        pet = {}
    }

    petSkillTable[subTabIndex1] = {}

    if subTabIndex2 == 1 then


        if GlobalProcessing.AutomaticCastingData ~= nil then

            if GlobalProcessing.AutomaticCastingData[subTabIndex1] ~= nil then

                if #GlobalProcessing.AutomaticCastingData[subTabIndex1].order > 0 then

                    showSkillIdTable.role = GlobalProcessing.AutomaticCastingData[subTabIndex1].order

                else

                    local skillList = LD.GetSelfSkillList()

                    local Skill_Id = CL.OnGetAutoFightSkill(false)

                    if skillList then
                        for i = 0, skillList.Count - 1 do
                            local skillData = skillList[i]
                            if skillData.enable == 1 then
                                local skillId = skillData.id
                                local skillDB = DB.GetOnceSkillByKey1(skillId)
                                if skillDB.Type == 1 then --普通技能才显示
                                    local skillSubType = skillDB.SubType
                                    if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then



                                        local is = 0
                                        if Skill_Id == skillId then

                                            is = 1

                                        end

                                        local temp = {
                                            skill_id = skillId,

                                            status = is,
                                        }


                                        table.insert(showSkillIdTable.role,temp)
                                    end
                                end
                            end
                        end
                    end

                    table.sort(showSkillIdTable.role,function (a,b)

                        if a.status ~= b.status then

                            return a.status > b.status

                        end
                    end)

                end



            end

        end

    elseif subTabIndex2 == 2 then


        local petGuid = tostring(GlobalUtils.GetMainLineUpPetGuid())

        local petSkillStr = LD.GetPetStrCustomAttr("AutomaticCasting_PetSkillOrder", petGuid)

        if #petSkillStr > 0 then

            local t = jsonUtil.decode(petSkillStr)

            petSkillTable[subTabIndex1] = t[subTabIndex1]

            if #petSkillTable[subTabIndex1] > 0 then

                local skillList = LD.GetPetSkills(petGuid)

                if skillList then
                    for i = 0, skillList.Count - 1 do
                        local skillData = skillList[i]
                        if skillData.enable == 1 then
                            local skillId = skillData.id
                            local skillDB = DB.GetOnceSkillByKey1(skillId)
                            if skillDB.Type == 1 then --普通技能才显示
                                local skillSubType = skillDB.SubType
                                if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then
                                    local mark = false

                                    for i = 1, #petSkillTable[subTabIndex1] do


                                        if petSkillTable[subTabIndex1][i].skill_id == skillId then

                                            mark = true

                                        end

                                    end


                                    if mark == true then

                                    else

                                        local temp = {
                                            status = 0,
                                            skill_id = skillId
                                        }
                                        table.insert(petSkillTable[subTabIndex1],temp)

                                    end

                                end
                            end
                        end
                    end
                end

            else

                local skillList = LD.GetPetSkills(petGuid)

                if skillList then
                    for i = 0, skillList.Count - 1 do
                        local skillData = skillList[i]
                        if skillData.enable == 1 then
                            local skillId = skillData.id
                            local skillDB = DB.GetOnceSkillByKey1(skillId)
                            if skillDB.Type == 1 then --普通技能才显示
                                local skillSubType = skillDB.SubType
                                if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then


                                    local Skill_Id = LD.GetPetIntCustomAttr("__auto_c_si", petGuid) --读取先前设置的自动战斗技能


                                    local is = 0
                                    if Skill_Id == skillId then

                                        is = 1

                                    end

                                    local temp = {
                                        skill_id = skillId,

                                        status = is,
                                    }


                                    table.insert(petSkillTable[subTabIndex1],temp)

                                    test("petSkillTable[subTabIndex1]",inspect(petSkillTable[subTabIndex1]))
                                end
                            end
                        end
                    end
                end

                table.sort(petSkillTable[subTabIndex1],function (a,b)

                    if a.status ~= b.status then

                        return a.status > b.status

                    end
                end)

            end

            showSkillIdTable.pet = petSkillTable[subTabIndex1]



        else

            local skillList = LD.GetPetSkills(petGuid)

            if skillList then
                for i = 0, skillList.Count - 1 do
                    local skillData = skillList[i]
                    if skillData.enable == 1 then
                        local skillId = skillData.id
                        local skillDB = DB.GetOnceSkillByKey1(skillId)
                        if skillDB.Type == 1 then --普通技能才显示
                            local skillSubType = skillDB.SubType
                            if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then


                                local Skill_Id = LD.GetPetIntCustomAttr("__auto_c_si", petGuid) --读取先前设置的自动战斗技能


                                local is = 0
                                if Skill_Id == skillId then

                                    is = 1

                                end

                                local temp = {
                                    skill_id = skillId,

                                    status = is,
                                }


                                table.insert(petSkillTable[subTabIndex1],temp)

                                test("petSkillTable[subTabIndex1]",inspect(petSkillTable[subTabIndex1]))
                            end
                        end
                    end
                end
            end

            table.sort(petSkillTable[subTabIndex1],function (a,b)

                if a.status ~= b.status then

                    return a.status > b.status

                end
            end)

        end

        showSkillIdTable.pet = petSkillTable[subTabIndex1]

    end

    test("showSkillIdTable",inspect(showSkillIdTable))

    --刷新技能loop数据
    AutomaticCastingUI.RefreshSkillLoopData()

end

--刷新技能loop数据
function AutomaticCastingUI.RefreshSkillLoopData()

    test("刷新技能loop数据")

    local skillLoop = _gt.GetUI("skillLoop")

    if subTabIndex2 == 1 then

        GUI.LoopScrollRectSetTotalCount(skillLoop, #showSkillIdTable.role)

    elseif subTabIndex2 == 2 then

        GUI.LoopScrollRectSetTotalCount(skillLoop, #showSkillIdTable.pet)

    end

    GUI.LoopScrollRectRefreshCells(skillLoop)

end

--创建或刷新左边页签
function AutomaticCastingUI.CreateOrRefreshLeftTab(parent)

    test("创建或刷新左边页签")

    if GlobalProcessing.AutomaticCastingData ~= nil then

        local leftTabGroup = GUI.GetChild(parent,"leftTabGroup",false)

        if leftTabGroup == nil then
            leftTabGroup = GUI.GroupCreate(parent,"leftTabGroup",0,0)
            SetSameAnchorAndPivot(leftTabGroup, UILayout.TopLeft)
        end


        for i = 1, #GlobalProcessing.AutomaticCastingData do

            local leftTab = GUI.GetChild(leftTabGroup,"leftTab"..i,false)

            if leftTab == nil then

                local height = 140

                local toggle = GUI.CheckBoxCreate(leftTabGroup, "leftTab"..i, "1800602040", "1800602041", -26, (i-1) * (height + 5)+ 50, Transition.ColorTint, false,65,height,false)
                SetSameAnchorAndPivot(toggle, UILayout.Top)
                GUI.SetData(toggle,"index",i)
                GUI.RegisterUIEvent(toggle, UCE.PointerClick, "AutomaticCastingUI", "OnToggleCheckBoxClick")

                local text = GUI.CreateStatic(toggle, "text", GlobalProcessing.AutomaticCastingData[i].name, 1, -10, 10, height, "system", true, false)
                SetSameAnchorAndPivot(text, UILayout.Center)
                GUI.StaticSetAlignment(text,TextAnchor.MiddleCenter)
                GUI.StaticSetFontSize(text, 22)
                GUI.SetColor(text, Brown4Color)


                if i == subTabIndex1 then

                    GUI.CheckBoxSetCheck(toggle, true)

                    lastClickLeftTabGuid = tostring(GUI.GetGuid(toggle))

                else

                    GUI.CheckBoxSetCheck(toggle, false)

                end

            else

                local toggle = GUI.GetChild(leftTabGroup,"leftTab"..i,false)

                local text = GUI.GetChild(toggle,"text",false)
                GUI.StaticSetText(text,GlobalProcessing.AutomaticCastingData[i].name)

                if i == subTabIndex1 then

                    GUI.CheckBoxSetCheck(toggle, true)

                    lastClickLeftTabGuid = tostring(GUI.GetGuid(toggle))

                else

                    GUI.CheckBoxSetCheck(toggle, false)

                end

            end


        end

        --设置loop技能表
        AutomaticCastingUI.SetSkillTableData()

    end

end

--左侧页签点击事件
function AutomaticCastingUI.OnToggleCheckBoxClick(guid)

    test("左侧页签点击事件")

    local checkBox = GUI.GetByGuid(guid)

    local index = tonumber(GUI.GetData(checkBox,"index"))

    if lastClickLeftTabGuid == nil then

        GUI.CheckBoxSetCheck(checkBox, true)

    else

        if lastClickLeftTabGuid ~= tostring(guid) then

            local lastCheckbox = GUI.GetByGuid(lastClickLeftTabGuid)
            GUI.CheckBoxSetCheck(lastCheckbox, false)
        end

        GUI.CheckBoxSetCheck(checkBox, true)

        
    end


    local panelBg = _gt.GetUI("panelBg")

    local topBarCenter = GUI.GetChild(panelBg,"topBarCenter",false)

    local tipLabel = GUI.GetChild(topBarCenter,"tipLabel",false)

    GUI.StaticSetText(tipLabel,GlobalProcessing.AutomaticCastingData[index].name)

    subTabIndex1 = index

    lastClickLeftTabGuid = tostring(guid)

    --设置loop技能表
    AutomaticCastingUI.SetSkillTableData()
    
end

--设置顶部标题名字
function AutomaticCastingUI.SetTitleName()

    test("设置顶部标题名字")

    test("GlobalProcessing.AutomaticCastingData",inspect(GlobalProcessing.AutomaticCastingData))

    if GlobalProcessing.AutomaticCastingData ~= nil then

        if #GlobalProcessing.AutomaticCastingData > 0 then

            test("GlobalProcessing.AutomaticCastingData",inspect(GlobalProcessing.AutomaticCastingData))

            local name = GlobalProcessing.AutomaticCastingData[subTabIndex1].name

            local panelBg = _gt.GetUI("panelBg")

            local topBarCenter = GUI.GetChild(panelBg,"topBarCenter",false)

            local tipLabel = GUI.GetChild(topBarCenter,"tipLabel",false)

            GUI.StaticSetText(tipLabel,name)

        end

    end

end

--改名按钮点击事件
function AutomaticCastingUI.OnRenameBtnClick()

    test("改名按钮点击事件")

    local panelBg = _gt.GetUI("panelBg")

    local renameGroup = GUI.GetChild(panelBg,"renameGroup",false)

    if renameGroup == nil then

        local width = 464
        local height = 280

        renameGroup = GUI.GroupCreate(panelBg,"renameGroup",0,0,width,height,false)
        _gt.BindName(renameGroup,"renameGroup")
        SetSameAnchorAndPivot(renameGroup, UILayout.Center)


        -- 底图
        local panelBg = GUI.ImageCreate(renameGroup, "panelBg", "1800001120", 0, 0, false, width, height)
        GUI.SetIsRaycastTarget(panelBg, true)
        panelBg:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(panelBg, UCE.PointerClick, "AutomaticCastingUI", "OnInputAreaBgClick")
        SetSameAnchorAndPivot(panelBg, UILayout.Center)

        -- 左边装饰
        local pendant = GUI.ImageCreate(panelBg, "pendant", "1800007060", -20, -20)
        SetSameAnchorAndPivot(pendant, UILayout.TopLeft)

        -- 右侧关闭按钮
        local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800002050", -10, 10, Transition.ColorTint)
        SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "AutomaticCastingUI", "OnRenameCloseBtnClick")

        -- 标题
        local titleBg = GUI.ImageCreate(panelBg, "titleBg", "1800001030", 0, 25)
        SetSameAnchorAndPivot(titleBg, UILayout.Top)

        local titleLabel = GUI.CreateStatic( titleBg, "titleLabel", "方案改名", 0, 0, 150, 35, "system", true, false)
        SetSameAnchorAndPivot(titleLabel, UILayout.Center)
        GUI.StaticSetFontSize(titleLabel, 24)
        GUI.StaticSetAlignment(titleLabel, TextAnchor.MiddleCenter)
        GUI.SetColor(titleLabel, Color.New(255/255, 246/255, 232/255, 255/255))

        -- 输入框底图
        local inputAreaBg = GUI.ImageCreate( panelBg, "inputAreaBg", "1800400200", 0, 0, false, 412, 136)
        SetSameAnchorAndPivot(inputAreaBg, UILayout.Center)

        -- 确认
        local OKBtn = GUI.ButtonCreate( panelBg, "OKBtn", "1800402080", -30, -18, Transition.ColorTint, "")
        SetSameAnchorAndPivot(OKBtn, UILayout.BottomRight)
        GUI.RegisterUIEvent(OKBtn, UCE.PointerClick , "AutomaticCastingUI", "OnSureRenameBtnClick")

        local OKBtnText = GUI.CreateStatic( OKBtn, "OKBtnText", "确认", 0, 0, 160, 47, "system", true)
        SetSameAnchorAndPivot(OKBtnText, UILayout.Center)
        GUI.StaticSetFontSize(OKBtnText, 26)
        GUI.StaticSetAlignment(OKBtnText, TextAnchor.MiddleCenter)
        GUI.SetColor(OKBtnText, WhiteColor)
        GUI.SetIsOutLine(OKBtnText, true)
        GUI.SetOutLine_Color(OKBtnText, colorOutline)
        GUI.SetOutLine_Distance(OKBtnText, 1)

        -- 关闭
        local cancelBtn = GUI.ButtonCreate( panelBg, "cancelBtn", "1800402080", 30, -18, Transition.ColorTint, "")
        SetSameAnchorAndPivot(cancelBtn, UILayout.BottomLeft)
        GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick , "AutomaticCastingUI", "OnRenameCloseBtnClick")

        local cancelBtnText = GUI.CreateStatic( cancelBtn, "cancelBtnText", "取消", 0, 0, 160, 47, "system", true)
        SetSameAnchorAndPivot(cancelBtnText, UILayout.Center)
        GUI.StaticSetFontSize(cancelBtnText, 26)
        GUI.StaticSetAlignment(cancelBtnText, TextAnchor.MiddleCenter)
        GUI.SetColor(cancelBtnText, WhiteColor)
        GUI.SetIsOutLine(cancelBtnText, true)
        GUI.SetOutLine_Color(cancelBtnText, colorOutline)
        GUI.SetOutLine_Distance(cancelBtnText, 1)

        -- 输入框
        local input = GUI.EditCreate(panelBg, "input","1800001040", "请输入新的方案名称", 0, 0, Transition.ColorTint, "system", 0, 0, 40, 8)
        GUI.EditSetMaxCharNum(input, 12) -- 名字字符最多6个中文
        GUI.EditSetTextColor(input, BrownColor)
        GUI.SetPlaceholderTxtColor(input, GrayColor)
        GUI.EditSetLabelAlignment(input, TextAnchor.MiddleCenter)
        GUI.EditSetFontSize(input, 22)
        _gt.BindName(input,"SureInput")

    else

        GUI.SetVisible(renameGroup,true)

    end

end

function AutomaticCastingUI.OnInputAreaBgClick()

end

function AutomaticCastingUI.OnSureRenameBtnClick()

    local input = _gt.GetUI("SureInput")
    local newName = GUI.EditGetTextM(input)

    local nameLength = utf8.len(newName)

    if nameLength > 4 then

        CL.SendNotify(NOTIFY.ShowBBMsg, "名字长度过长，请重新输入")

        return

    elseif nameLength == 0 then

        CL.SendNotify(NOTIFY.ShowBBMsg, "请输入新的方案名称")

        return

    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormAutomaticCasting", "EditSchemeName", subTabIndex1, newName)

    AutomaticCastingUI.OnRenameCloseBtnClick()

end

--应用方案按钮点击事件
function AutomaticCastingUI.OnApplyBtnClick()

    test("应用方案按钮点击事件")

    if subTabIndex2 == 1 then

        local json=jsonUtil.encode(showSkillIdTable.role)

        test("json",inspect(json))

        CL.SendNotify(NOTIFY.SubmitForm, "FormAutomaticCasting", "SetRoleScheme", subTabIndex1, json)

    elseif subTabIndex2 == 2 then

        local json=jsonUtil.encode(petSkillTable)

        test("json",inspect(json))

        local petGuid = tostring(GlobalUtils.GetMainLineUpPetGuid())

        CL.SendNotify(NOTIFY.SubmitForm, "FormAutomaticCasting", "SetPetScheme", petGuid, json)

    end

    CL.SendNotify(NOTIFY.ShowBBMsg, "保存成功")

end

--技能图标点击事件
function AutomaticCastingUI.OnSkillShowClick(guid)

    test("技能图标点击事件")

    local skillImage = GUI.GetByGuid(guid)

    local skillId = tonumber(GUI.GetData(skillImage,"skillId"))

    test("skillId",skillId)

    local panelBg = _gt.GetUI("panelBg")

    local skillTips = GUI.GetChild(panelBg,"skillTips",false)

    if skillTips == nil then

        local tip = Tips.CreateSkillId(skillId, panelBg, "SkillTip", 100, 40, 0, 0)
        GUI.SetIsRemoveWhenClick(tip, true)
        GUI.SetIsRaycastTarget(tip, true)
        tip:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(tip, UCE.PointerClick, "SkillItemUtil", "OnSkillCoverClick")

    end

end

--自动技能更新监听事件回调
function AutomaticCastingUI.OnRoleAutoFightSkill()

    test("自动技能更新监听事件回调")

    --刷新技能loop数据
    AutomaticCastingUI.RefreshSkillLoopData()

end

function AutomaticCastingUI.OnRenameCloseBtnClick()

    local renameGroup = _gt.GetUI("renameGroup")

    GUI.SetVisible(renameGroup,false)

    local input = _gt.GetUI("SureInput")
    GUI.EditSetTextM(input,"")

end

function AutomaticCastingUI.OnExit()
    GUI.CloseWnd("AutomaticCastingUI")
end
