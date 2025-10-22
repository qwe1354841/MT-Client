local CrossServerWarfareParticipationUI = {}
_G.CrossServerWarfareParticipationUI = CrossServerWarfareParticipationUI

--跨服战报名匹配界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local StaticSetFontSizeColorAlignment = UILayout.StaticSetFontSizeColorAlignment
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
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorOutline = Color.New(162 / 255, 75 / 255, 21 / 255)
local tipColor = Color.New(208 / 255, 140 / 255, 15 / 255, 255 / 255)
local contentColor = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------

local CrossServerWarfareActivityId = nil

local isRegistration = false
local canJoin = false

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

local awardItemTable = {}

--------------------------------------------End 表配置 End------------------------------------

function CrossServerWarfareParticipationUI.Main(parameter)

    local panel = GUI.WndCreateWnd("CrossServerWarfareParticipationUI" , "CrossServerWarfareParticipationUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "跨服战活动", 700, 570, "CrossServerWarfareParticipationUI","OnExit",_gt)
    _gt.BindName(panelBg, "panelBg")

    -- 功能名称
    local NameTip = GUI.CreateStatic(panelBg,"NameTip", "[活动名称]", 30, 45, 200, 35)
    SetSameAnchorAndPivot(NameTip, UILayout.TopLeft)
    StaticSetFontSizeColorAlignment(NameTip, 24, tipColor, nil)

    local NameText = GUI.CreateStatic(panelBg,"NameText", "30", 40, 65, 200, 70)
    SetSameAnchorAndPivot(NameText, UILayout.TopLeft)
    StaticSetFontSizeColorAlignment(NameText, 28, contentColor, nil)

    -- 功能介绍
    local InfoTip = GUI.CreateStatic(panelBg,"InfoTip", "[活动介绍]", 30, 120, 200, 35)
    SetSameAnchorAndPivot(InfoTip, UILayout.TopLeft)
    StaticSetFontSizeColorAlignment(InfoTip, 24, tipColor, nil)


    local InfoText = GUI.CreateStatic(panelBg,"InfoText", "", 0, -35, 620, 180, "system", false, false)
    SetSameAnchorAndPivot(InfoText, UILayout.Center)
    StaticSetFontSizeColorAlignment(InfoText, UIDefine.FontSizeM, contentColor, TextAnchor.UpperLeft)

    -- 活动奖励
    local rewardTip = GUI.CreateStatic(panelBg,"RewardTip", "[活动奖励]", 30, 50, 200, 35)
    SetSameAnchorAndPivot(rewardTip, UILayout.Left)
    StaticSetFontSizeColorAlignment(rewardTip, 24, tipColor, nil)


    local activityAwardItemLoop =
    GUI.LoopScrollRectCreate(
            panelBg,
            "activityAwardItemLoop",
            0,
            -90,
            620,
            120,
            "CrossServerWarfareParticipationUI",
            "CreateActivityAwardItem",
            "CrossServerWarfareParticipationUI",
            "RefreshActivityAwardItem",
            0,
            true,
            Vector2.New(100, 100),
            1,
            UIAroundPivot.Center,
            UIAnchor.Center,
            false
    )
    SetAnchorAndPivot(activityAwardItemLoop, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ScrollRectSetAlignment(activityAwardItemLoop, TextAnchor.MiddleCenter)
    GUI.ScrollRectSetChildSpacing(activityAwardItemLoop, Vector2.New(3, 3))
    _gt.BindName(activityAwardItemLoop,"activityAwardItemLoop")


    --前往按钮
    local GoBtn = GUI.ButtonCreate(panelBg,"GoBtn", "1800402080", 0, -55, Transition.ColorTint, "点击前往", 158, 55, false)
    SetAnchorAndPivot(GoBtn, UIAnchor.Bottom, UIAroundPivot.Center)
    _gt.BindName(GoBtn,"GoBtn")
    GUI.ButtonSetTextFontSize(GoBtn, 28)
    GUI.ButtonSetTextColor(GoBtn, WhiteColor)
    GUI.SetIsOutLine(GoBtn, true)
    GUI.SetOutLine_Color(GoBtn, colorOutline)
    GUI.SetOutLine_Distance(GoBtn, 1)
    GUI.RegisterUIEvent(GoBtn, UCE.PointerClick, "CrossServerWarfareParticipationUI", "OnClickGoBtn")


end


function CrossServerWarfareParticipationUI.OnShow(parameter)
    local wnd = GUI.GetWnd("CrossServerWarfareParticipationUI");
    if wnd == nil then
        return
    end


    CrossServerWarfareParticipationUI.Init()
    GUI.SetVisible(wnd, true)

    CL.SendNotify(NOTIFY.GetActivityList)
    CL.SendNotify(NOTIFY.SubmitForm, "FormAct_CrossServer", "GetRegistration")



end

function CrossServerWarfareParticipationUI.Init()

    isRegistration = false
    canJoin = false

    CrossServerWarfareActivityId = nil

    awardItemTable = {}

end

--服务器回调刷新
function CrossServerWarfareParticipationUI.RefreshAllData()
    test("服务器回调刷新")

    CrossServerWarfareActivityId = CrossServerWarfareParticipationUI.Act_CrossServerID
    isRegistration = CrossServerWarfareParticipationUI.IsRegistration
    canJoin = CrossServerWarfareParticipationUI.CanJoinAct_CrossServer

    test("isRegistration",isRegistration)
    test("canJoin",canJoin)

    if CrossServerWarfareActivityId ~= nil then

        test("CrossServerWarfareActivityId",CrossServerWarfareActivityId)
        local activityDB = DB.GetActivity(CrossServerWarfareActivityId)

        local panelBg = _gt.GetUI("panelBg")

        local NameText = GUI.GetChild(panelBg,"NameText",false)
        GUI.StaticSetText(NameText,activityDB.Name)

        local InfoText = GUI.GetChild(panelBg,"InfoText",false)
        GUI.StaticSetText(InfoText,activityDB.DesInfo)


        local activityData = LD.GetActivityDataByID(CrossServerWarfareActivityId)
        if activityData == nil then
            print("奖励中找不到此活动的数据")
        else
            local custom = string.split(activityData.custom, ":")
            awardItemTable = string.split(custom[5], ",")
        end


        local activityAwardItemLoop = _gt.GetUI("activityAwardItemLoop")
        GUI.LoopScrollRectSetTotalCount(activityAwardItemLoop, #awardItemTable)
        GUI.LoopScrollRectRefreshCells(activityAwardItemLoop)

    end

    local GoBtn = _gt.GetUI("GoBtn")

    if canJoin then

        GUI.ButtonSetText(GoBtn,"点击前往")

    else

        if isRegistration then

            GUI.ButtonSetText(GoBtn,"取消报名")

        else

            GUI.ButtonSetText(GoBtn,"报  名")

        end

    end


end





function CrossServerWarfareParticipationUI.OnClickGoBtn()

    if canJoin then

        if CrossServerWarfareActivityId and CrossServerWarfareActivityId > 0 then

            if UIDefine.IsFunctionOrVariableExist(CL, "UpdateOem") and UIDefine.IsFunctionOrVariableExist(CL, "JumpServer") and UIDefine.IsFunctionOrVariableExist(CL, "GetServerListDatasIncludeTest") then
                CDebug.LogError("GM.UpdateOem  "..tostring(GM.UpdateOem))
                CL.RegisterMessage(GM.UpdateOem, "CrossServerWarfareParticipationUI", "OnUpdateOem")
                local res = CL.UpdateOem()
                if not res then
                    CL.SendNotify(NOTIFY.ShowBBMsg, "正在处理中,请勿连续操作");
                end
                CDebug.LogError("CL.UpdateOem() res "..tostring(res))
            else
                CDebug.LogError("IsFunctionOrVariableExist false ")
            end

        end

    else

        if isRegistration then

            CL.SendNotify(NOTIFY.SubmitForm, "FormAct_CrossServer", "CancelRegistration")

        else

            CL.SendNotify(NOTIFY.SubmitForm, "FormAct_CrossServer", "Registration")

        end

    end

end

function CrossServerWarfareParticipationUI.OnUpdateOem()

    CL.UnRegisterMessage(GM.UpdateOem, "CrossServerWarfareParticipationUI", "OnUpdateOem")
    local _GroupLst = CL.GetServerListAllKeys()
    local _GroupCount = _GroupLst.Count
    local _GroupLst2 = {}
    for i = 0, _GroupCount - 1 do
        local groupID = tonumber(tostring(_GroupLst[i]))
        local serverDatas = CL.GetServerListDatasIncludeTest(groupID)
        local _ServerCount = serverDatas.Count
        for j = 0,_ServerCount - 1 do
            local sevname = serverDatas[j].ServerName
            local areaID = serverDatas[j].AreaID
            local flag = serverDatas[j].Flag
            CDebug.LogError("sevname "..sevname)
            CDebug.LogError("areaID "..areaID)
            CDebug.LogError("flag "..tostring(flag))

            if string.find(tostring(flag), "jump") then
                CL.JumpServer(groupID, areaID, j, "")
                return
            end
        end
    end
end

function CrossServerWarfareParticipationUI.CreateActivityAwardItem()

    local activityAwardItemLoop = _gt.GetUI("activityAwardItemLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(activityAwardItemLoop) + 1

    local item = GUI.ItemCtrlCreate(activityAwardItemLoop,"ShoppingItem"..index,QualityRes[1],0,0,50,50,false,"system",false)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,80,80)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "CrossServerWarfareParticipationUI", "OnActivityAwardItemClick")

    return item
end

function CrossServerWarfareParticipationUI.RefreshActivityAwardItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = awardItemTable[index]

    if data then

        local itemDB = DB.GetOnceItemByKey1(tonumber(data))
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,itemDB.Icon)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[itemDB.Grade])
        GUI.SetData(item,"itemId",tonumber(data))
    end

end

function CrossServerWarfareParticipationUI.OnActivityAwardItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local itemId= tonumber(GUI.GetData(item,"itemId"))
    local panelBg = _gt.GetUI("panelBg")
    local tip = Tips.CreateByItemId(tonumber(itemId), panelBg, "rightItemTips",0,-30)
    SetSameAnchorAndPivot(tip, UILayout.Center)
    GUI.SetData(tip, "ItemId", itemId)
end

function CrossServerWarfareParticipationUI.OnExit()

    GUI.CloseWnd("CrossServerWarfareParticipationUI")

end