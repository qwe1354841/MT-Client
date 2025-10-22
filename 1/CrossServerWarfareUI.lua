local CrossServerWarfareUI = {}
_G.CrossServerWarfareUI = CrossServerWarfareUI

--跨服战界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local _gt = UILayout.NewGUIDUtilTable()

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

------------------------------------------Start 颜色配置 Start----------------------------------
local RedColor = UIDefine.RedColor
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
----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

local NowIntegralData = {}

--------------------------------------------End 表配置 End------------------------------------

function CrossServerWarfareUI.CreateOrRefreshRightLoop()

    test("============================服务器调用左边栏创建=============================")

    local wnd = GUI.GetWnd("MainUI")
    local CrossServerWarfareGroup = GUI.GetChild(wnd,"CrossServerWarfareGroup")

    if CrossServerWarfareGroup == nil then

        local width = 260
        local height = 390
        CrossServerWarfareGroup = GUI.GroupCreate(wnd,"CrossServerWarfareGroup", 0, 90, width, height,false)
        _gt.BindName(CrossServerWarfareGroup,"CrossServerWarfareGroup")
        SetSameAnchorAndPivot(CrossServerWarfareGroup, UILayout.TopLeft)

        local teamAndIntegralBg = GUI.ImageCreate(CrossServerWarfareGroup, "teamAndIntegralBg", "1800001010", 0, 0, false, width, height)
        SetSameAnchorAndPivot(teamAndIntegralBg, UILayout.Top)

        local teamAndIntegralLoop =
        GUI.LoopScrollRectCreate(
                teamAndIntegralBg,
                "GambleItemLoop",
                0,
                20,
                width - 40,
                height - 40,
                "CrossServerWarfareUI",
                "CreateTeamAndIntegralItem",
                "CrossServerWarfareUI",
                "RefreshTeamAndIntegralItem",
                0,
                false,
                Vector2.New(220, 100),
                1,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        _gt.BindName(teamAndIntegralLoop,"teamAndIntegralLoop")
        SetSameAnchorAndPivot(teamAndIntegralLoop, UILayout.Top)
        GUI.ScrollRectSetAlignment(teamAndIntegralLoop, TextAnchor.UpperCenter)
        GUI.ScrollRectSetChildSpacing(teamAndIntegralLoop, Vector2.New(3, 5))

        NowIntegralData = {}

        CL.UnRegisterMessage(GM.FightStateNtf, "CrossServerWarfareUI", "OnInFight")
        CL.RegisterMessage(GM.FightStateNtf, "CrossServerWarfareUI", "OnInFight")

    end

    CrossServerWarfareUI.RefreshAllData(1)

end

function CrossServerWarfareUI.RefreshAllData(index)

    test("CrossServerWarfareUI.IntegralData",inspect(CrossServerWarfareUI.IntegralData))


    test("CrossServerWarfareUI.IntegralData",inspect(CrossServerWarfareUI.IntegralData))

    test("MainUI.Act_CrossServerData",inspect(MainUI.Act_CrossServerData))

    local MaxIntegral = MainUI.Act_CrossServerData.MaxIntegral

    CrossServerWarfareUI.NowIntegralData = {}

    for i = 1, #CrossServerWarfareUI.IntegralData do



        if NowIntegralData[i] == nil then

            local temp = {
                Name = MainUI.Act_CrossServerData.CampBuff[i].Name,
                Icon = MainUI.Act_CrossServerData.CampBuff[i].Icon,
                MaxIntegral = MaxIntegral,
                value1 = CrossServerWarfareUI.IntegralData[i],
            }
            
            table.insert(NowIntegralData,temp)

        else

            if NowIntegralData[i].value1 < CrossServerWarfareUI.IntegralData[i] then


                NowIntegralData[i].isAdd = true

                NowIntegralData[i].value2 = CrossServerWarfareUI.IntegralData[i] - NowIntegralData[i].value1

                NowIntegralData[i].value1 = CrossServerWarfareUI.IntegralData[i]

            else

                NowIntegralData[i].isAdd = false

                NowIntegralData[i].value2 = NowIntegralData[i].value1 - CrossServerWarfareUI.IntegralData[i]

                NowIntegralData[i].value1 = CrossServerWarfareUI.IntegralData[i]

            end



        end

    end

    test("NowIntegralData",inspect(NowIntegralData))

    local teamAndIntegralLoop = _gt.GetUI("teamAndIntegralLoop")
    GUI.LoopScrollRectSetTotalCount(teamAndIntegralLoop, #NowIntegralData)
    GUI.LoopScrollRectRefreshCells(teamAndIntegralLoop)
    
end

function CrossServerWarfareUI.CreateTeamAndIntegralItem()
    local teamAndIntegralLoop = _gt.GetUI("teamAndIntegralLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(teamAndIntegralLoop) + 1

    local groupBg = GUI.ImageCreate(teamAndIntegralLoop, "groupBg"..index, "1800001150", 0, 0, false, 220, 100)
    SetSameAnchorAndPivot(groupBg, UILayout.TopLeft)

    local battleArrayIcon = GUI.ItemCtrlCreate(groupBg,"battleArrayIcon","1800700020",10,12,75,75,false,"system",false)
    SetSameAnchorAndPivot(battleArrayIcon, UILayout.TopLeft)
    GUI.ItemCtrlSetElementValue(battleArrayIcon,eItemIconElement.Border,"1800302190")
    GUI.ItemCtrlSetElementRect(battleArrayIcon,eItemIconElement.Icon,0,-1,65,65)
    GUI.ItemCtrlSetElementValue(battleArrayIcon,eItemIconElement.Icon,nil)
    GUI.RegisterUIEvent(battleArrayIcon, UCE.PointerClick, "CrossServerWarfareUI", "OnContributionDegreeItemClick")

    local nameTxt = GUI.CreateStatic(groupBg,"nameTxt","名字" ,95,5,160, 40, "101", false, false)
    GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(nameTxt,22)
    SetSameAnchorAndPivot(nameTxt, UILayout.TopLeft)
    GUI.SetColor(nameTxt,Brown6Color)

    local integralTxt = GUI.CreateStatic(groupBg,"integralTxt","积分:999" ,95,30,160, 40, "101", false, false)
    GUI.StaticSetAlignment(integralTxt,TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(integralTxt,22)
    SetSameAnchorAndPivot(integralTxt, UILayout.TopLeft)
    GUI.SetColor(integralTxt,Brown4Color)

    --积分背景进度条
    local sliderBg = GUI.ImageCreate(groupBg, "sliderBg", "1800608120", 95, 70, false, 115, 18,false)
    SetSameAnchorAndPivot(sliderBg, UILayout.TopLeft)

    --积分绿色进度条
    local fill = GUI.ImageCreate(sliderBg, "fill", "1800608110", 1, 0, false, 60, 18)
    SetSameAnchorAndPivot(fill, UILayout.Left)
    GUI.SetVisible(fill,false)

    --增加进度条
    local addFill = GUI.ImageCreate(fill, "addFill", "1800608110", 0, 0, false, 30, 18)
    GUI.SetColor(addFill,Color.New(0 / 255, 196 / 255, 0 / 255, 255 / 255))
    GUI.SetVisible(addFill,false)
    SetAnchorAndPivot(addFill, UIAnchor.Right, UIAroundPivot.Right)

    --减少进度条
    local reduceFill = GUI.ImageCreate(fill, "reduceFill", "1800608110", 0, 0, false, 30, 18)
    GUI.SetColor(reduceFill,Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255))
    SetAnchorAndPivot(reduceFill, UIAnchor.Right, UIAroundPivot.Left)
    GUI.SetVisible(reduceFill,false)

    return groupBg
end

function CrossServerWarfareUI.RefreshTeamAndIntegralItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = NowIntegralData[index]

    test("data",inspect(data))
    if data then


        local battleArrayIcon = GUI.GetChild(item,"battleArrayIcon",false)
        test("data.Icon",data.Icon)
        GUI.ItemCtrlSetElementValue(battleArrayIcon,eItemIconElement.Icon,tostring(data.Icon))


        local nameTxt = GUI.GetChild(item,"nameTxt",false)
        GUI.StaticSetText(nameTxt,data.Name)

        local integralTxt = GUI.GetChild(item,"integralTxt",false)
        GUI.StaticSetText(integralTxt,"积分:"..data.value1)

        local sliderBg = GUI.GetChild(item,"sliderBg",false)

        if data.value2 == nil then
            local fill = GUI.GetChild(sliderBg,"fill",false)
            local addFill = GUI.GetChild(fill,"addFill",false)
            local reduceFill = GUI.GetChild(fill,"reduceFill",false)

            local sliderBgWidth = GUI.GetWidth(sliderBg)


            GUI.SetVisible(fill,true)
            GUI.SetWidth(fill,sliderBgWidth * (data.value1/data.MaxIntegral))

            GUI.SetVisible(addFill,false)
            GUI.SetVisible(reduceFill,false)

        else

            CrossServerWarfareUI.SetIntegralAddOrReduce(sliderBg,(data.value1/data.MaxIntegral)*100,(data.value2/data.MaxIntegral)*100,data.isAdd)

        end

    end

end

--设置积分进度条增加或减少（进度条父类，原本的值，增加或减少的值，true：增加，false：减少）
function CrossServerWarfareUI.SetIntegralAddOrReduce(item,value1,value2,isAdd)

    local sliderBgWidth = GUI.GetWidth(item)

    local fill = GUI.GetChild(item,"fill",false)


    local addFill = GUI.GetChild(fill,"addFill",false)

    local reduceFill = GUI.GetChild(fill,"reduceFill",false)

    GUI.SetWidth(fill,sliderBgWidth * value1/100)

    local fillItem = nil

    if isAdd then

        GUI.SetVisible(addFill,true)
        GUI.SetVisible(reduceFill,false)
        fillItem = addFill

    else

        GUI.SetVisible(addFill,false)
        GUI.SetVisible(reduceFill,true)

        fillItem = reduceFill

    end

    GUI.SetWidth(fillItem,sliderBgWidth * value2 / 100)

    local time = 1 * (value2 / 10)
    local tween = TweenData.New()
    tween.Type =GUITweenType.DOScale;
    tween.Duration= time;
    tween.From = Vector3.New(1,1,1);
    tween.To =  Vector3.New(0,1,1);
    tween.LoopType = UITweenerStyle.Once;
    GUI.DOTween(fillItem,tween);


end

function CrossServerWarfareUI.OnInFight(inFight)

    local CrossServerWarfareGroup = _gt.GetUI("CrossServerWarfareGroup")

    if inFight then

        GUI.SetVisible(CrossServerWarfareGroup,false)

    else

        GUI.SetVisible(CrossServerWarfareGroup,true)

    end
end