local DistributionGambleUI = {}
_G.DistributionGambleUI = DistributionGambleUI

require "jsonUtil"

--孤注一掷活动队长分配资源界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
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
local BrownColor = UIDefine.BrownColor
local Brown4Color = UIDefine.Brown4Color
local Brown6Color = UIDefine.Brown6Color
local Yellow3Color = UIDefine.Yellow3Color
local Yellow2Color = UIDefine.Yellow2Color
local Yellow4Color = UIDefine.Yellow4Color
local Yellow5Color = UIDefine.Yellow5Color
local YellowStdColor = UIDefine.YellowStdColor
local YellowColor = UIDefine.YellowColor
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
local colorType_Input = Color.New(135 / 255, 135 / 255, 135 / 255)

local fontColor2 = "662F16"


----------------------------------------------End 颜色配置 End-----------------------------------


------------------------------------------Start 全局变量 Start----------------------------------

local selfGuid = nil

local isOpenDistribution = false

local nowSelectItemGuid = nil

local selfStatus = 0 -- 0:未锁定，1:已锁定

local lastSelectPlayerGuid = nil --上一个左边选择的玩家的GUID

----------------------------------------------End 全局变量 End-----------------------------------


------------------------------------------Start 表配置 Start----------------------------------

local DistributionAllDataTable = {}

local distributionItemTable = {} --右边物品数据表

local memberListTable = {}

local memberListGainTable = {} --玩家物品栏GUID表

local memberListGUIDGainTable = {} --玩家GUID对应物品GUID和数量临时处理表

local leaderGainTable = {} --队长物品GUID和数量临时处理表

local gainMemberItemTable = {}


local role_HeadList = {
    [1] = "1900300010",
    [2] = "1900300020",
    [3] = "1900300030",
    [4] = "1900300040",
    [5] = "1900300050",
    [6] = "1900300060",
    [7] = "1900300070",
    [8] = "1900300080",
    [9] = "1900300090",
    [10] = "1900300100",
    [11] = "1900300110",
    [12] = "1900300120",
}

local SetTableSort = function(a,b)
    if a[2] ~= b[2] then

        return a[2] > b[2]
    end
    return false
end

--------------------------------------------End 表配置 End------------------------------------
function DistributionGambleUI.Main(parameter)
    local panel = GUI.WndCreateWnd("DistributionGambleUI" , "DistributionGambleUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "获 胜 分 配",720,520,"DistributionGambleUI","OnExit",_gt)

    local centerBg = GUI.ImageCreate(panelBg, "centerBg", "1800400200", 0, 70, false, 660, 360)
    _gt.BindName(centerBg,"centerBg")
    SetSameAnchorAndPivot(centerBg, UILayout.Top)

    --队伍Loop
    local RoleApplyItemLoop =
    GUI.LoopScrollRectCreate(
            centerBg,
            "RoleApplyItemLoop",
            10,
            15,
            320,
            332,
            "DistributionGambleUI",
            "CreateRoleApplyItem",
            "DistributionGambleUI",
            "RefreshRoleApplyItem",
            0,
            false,
            Vector2.New(320, 160),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(RoleApplyItemLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(RoleApplyItemLoop, TextAnchor.UpperLeft)
    _gt.BindName(RoleApplyItemLoop, "RoleApplyItemLoop")
    GUI.ScrollRectSetChildSpacing(RoleApplyItemLoop, Vector2.New(0, 5))


    local arrowsBg = GUI.ImageCreate(centerBg, "arrowsBg", "1801208610", 35, 0, false)
    GUI.SetEulerAngles(arrowsBg, Vector3.New(0, -180, 0))
    SetSameAnchorAndPivot(arrowsBg, UILayout.Center)

    -------------------------------------------------------------------------------聊分割线-----------------------------------------------------------

    local rightItemBg = GUI.ImageCreate(centerBg, "rightItemBg", "1800201130", -10, 10, false, 250, 340,false)
    _gt.BindName(rightItemBg,"rightItemBg")
    SetSameAnchorAndPivot(rightItemBg, UILayout.TopRight)

    local rightItemPage = GUI.GroupCreate(rightItemBg, "rightItemPage", 0, 0, GUI.GetWidth(rightItemBg), GUI.GetHeight(rightItemBg))
    _gt.BindName(rightItemPage,"rightItemPage")
    SetSameAnchorAndPivot(rightItemPage, UILayout.Top)

    local rightBagItemLoop =
    GUI.LoopScrollRectCreate(
            rightItemPage,
            "rightBagItemLoop",
            0,
            45,
            GUI.GetWidth(rightItemBg) - 14,
            GUI.GetHeight(rightItemBg) - 60,
            "DistributionGambleUI",
            "CreateRightBagItem",
            "DistributionGambleUI",
            "RefreshRightBagItem",
            0,
            false,
            Vector2.New(77, 77),
            3,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(rightBagItemLoop, UILayout.Top)
    GUI.ScrollRectSetAlignment(rightBagItemLoop, TextAnchor.UpperLeft)
    _gt.BindName(rightBagItemLoop, "rightBagItemLoop")
    GUI.ScrollRectSetChildSpacing(rightBagItemLoop, Vector2.New(3, 3))

    local tipsTxt = GUI.CreateStatic(rightItemPage,"tipsTxt","在此选择物品进行分配：" ,10,10,260, 30, "system", true, false)
    GUI.StaticSetFontSize(tipsTxt,22)
    GUI.StaticSetAlignment(tipsTxt,TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(tipsTxt, UILayout.TopLeft)
    GUI.SetColor(tipsTxt,Brown4Color)


    local applyBtn = GUI.ButtonCreate(panelBg, "applyBtn", "1800402090", 0, -25, Transition.ColorTint, "提 交", 170, 50, false)
    _gt.BindName(applyBtn,"applyBtn")
    GUI.ButtonSetTextFontSize(applyBtn, 30)
    GUI.SetIsOutLine(applyBtn, true)
    GUI.ButtonSetTextColor(applyBtn, WhiteColor)
    GUI.SetOutLine_Color(applyBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(applyBtn,OutLineDistance)
    SetSameAnchorAndPivot(applyBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(applyBtn, UCE.PointerClick, "DistributionGambleUI", "OnSubmitBtnClick")

end

function DistributionGambleUI.OnShow()
    local wnd = GUI.GetWnd("DistributionGambleUI")

    if not wnd then
        return
    end

    GUI.SetVisible(wnd, true)

    CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","GetFightOverData")

end

function DistributionGambleUI.RefreshAllData()

    DistributionGambleUI.AllDataInit()

    DistributionAllDataTable = DistributionGambleUI.AllData

    test("DistributionAllDataTable",inspect(DistributionAllDataTable))

    for k, v in pairs(DistributionAllDataTable.ItemList) do
        local temp = {
            keyName = k,
            amount = tonumber(v),
            clickNum = tonumber(v)
        }
        table.insert(distributionItemTable,temp)
    end


    leaderGainTable = DistributionAllDataTable.ItemList

    selfGuid = tostring(LD.GetSelfGUID())

    --服务器刷新左边队伍表数据
    DistributionGambleUI.RefreshAllSetMemberListTableData()

    ----设置玩家GUID对应物品GUID和数量临时处理表数据
    --DistributionGambleUI.SetMemberListGUIDGainTableData()
    --

    --test("memberListTable",inspect(memberListTable))
    --

    --刷新队伍Loop
    DistributionGambleUI.RefreshRoleApplyItemLoopData()

    --刷新右边分配Loop
    DistributionGambleUI.RefreshRightBagItemLoopData()

end

--刷新队伍Loop
function DistributionGambleUI.RefreshRoleApplyItemLoopData()

    local RoleApplyItemLoop = _gt.GetUI("RoleApplyItemLoop")
    GUI.LoopScrollRectSetTotalCount(RoleApplyItemLoop, #memberListTable)
    GUI.LoopScrollRectRefreshCells(RoleApplyItemLoop)

end

--刷新右边分配Loop
function DistributionGambleUI.RefreshRightBagItemLoopData()

    local rightBagItemLoop = _gt.GetUI("rightBagItemLoop")
    GUI.LoopScrollRectSetTotalCount(rightBagItemLoop, 30)
    GUI.LoopScrollRectRefreshCells(rightBagItemLoop)

end

--服务器刷新左边队伍表数据
function DistributionGambleUI.RefreshAllSetMemberListTableData()

    local leaderTable = {}

    for i = 1, #DistributionAllDataTable.MemberList do


        if DistributionAllDataTable.MemberList[i].GUID == DistributionAllDataTable.TeamLeaderGUID then

            leaderTable = DistributionAllDataTable.MemberList[i]

            test("leaderTable",inspect(leaderTable))

        elseif DistributionAllDataTable.MemberList[i].GUID == selfGuid then

            table.insert(memberListTable,1,DistributionAllDataTable.MemberList[i])

            test("memberListTable",inspect(memberListTable))

        else

            table.insert(memberListTable,DistributionAllDataTable.MemberList[i])

        end

    end

    table.insert(memberListTable,1,leaderTable)

    for i = 1, #memberListTable do
        table.sort(memberListTable[i].GetItem,SetTableSort)
    end

end

function DistributionGambleUI.CreateRoleApplyItem()
    local RoleApplyItemLoop = _gt.GetUI("RoleApplyItemLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(RoleApplyItemLoop) + 1


    local groupBg = GUI.CheckBoxExCreate(RoleApplyItemLoop,"groupBg"..index, "1800800030", "1800800040", 1, 0,  false, 300, 100)
    GUI.CheckBoxExSetCheck(groupBg, false)
    GUI.SetAnchor(groupBg, UIAnchor.Top)
    GUI.SetPivot(groupBg, UIAroundPivot.Top)
    GUI.RegisterUIEvent(groupBg, UCE.PointerClick , "DistributionGambleUI", "OnContactItemClick")

    local roleItem = GUI.ItemCtrlCreate(groupBg,"roleItem",QualityRes[1],20,16,70,70,false,"system",false)
    GUI.ItemCtrlSetElementRect(roleItem,eItemIconElement.Icon,0,-1,60,60)
    GUI.ItemCtrlSetElementRect(roleItem,eItemIconElement.LeftTopSp,5,5,40,22)
    SetSameAnchorAndPivot(roleItem, UILayout.TopLeft)
    GUI.RegisterUIEvent(roleItem, UCE.PointerClick, "DistributionGambleUI", "OnRoleItemClick")

    --角色名字
    local nameTxt = GUI.CreateStatic(roleItem,"nameTxt","六个字名字" ,0,33,140, 30, "system", false, false)
    GUI.StaticSetFontSize(nameTxt,18)
    GUI.SetColor(nameTxt,Brown4Color)
    GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)

    local ApplyItemLoop =
    GUI.LoopScrollRectCreate(
            groupBg,
            "ApplyItemLoop",
            -8,
            15,
            210,
            127,
            "DistributionGambleUI",
            "CreateApplyItem",
            "DistributionGambleUI",
            "RefreshApplyItem",
            0,
            false,
            Vector2.New(65, 65),
            3,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(ApplyItemLoop, UILayout.TopRight)
    GUI.ScrollRectSetAlignment(ApplyItemLoop, TextAnchor.UpperLeft)
    GUI.ScrollRectSetChildSpacing(ApplyItemLoop, Vector2.New(3, 5))

    return groupBg
end


function DistributionGambleUI.RefreshRoleApplyItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1

    local data = memberListTable[index]

    if data then

        local groupBg = GUI.GetByGuid(guid)

        GUI.CheckBoxExSetCheck(groupBg, false)

        local roleItem = GUI.GetChild(groupBg,"roleItem",false)

        local nameTxt = GUI.GetChild(roleItem,"nameTxt",false)

        local roleDB = DB.GetRole(data.Role_Id)
        GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.Icon,tostring(roleDB.Head))

        if data.GUID == DistributionAllDataTable.TeamLeaderGUID then
            GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.LeftTopSp,"1800604010")
        else
            GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.LeftTopSp,"1800604090")
        end


        GUI.StaticSetText(nameTxt,data.Name)

        if lastSelectPlayerGuid == nil then

            if index == 1 then
                GUI.CheckBoxExSetCheck(groupBg, true)

                lastSelectPlayerGuid = tostring(guid)
            end

        else
            if lastSelectPlayerGuid == tostring(guid) then

                GUI.CheckBoxExSetCheck(groupBg, true)

            end

        end

        GUI.SetData(groupBg,"memberGuid",tostring(data.GUID))

        local ApplyItemLoop = GUI.GetChild(groupBg,"ApplyItemLoop",false)

        local refreshNum = 9
        local itemTable = data.GetItem
        if #itemTable > refreshNum then
            refreshNum = math.ceil(#itemTable / 3) * 3
        end

        GUI.SetData(ApplyItemLoop,"index",index)
        GUI.SetData(ApplyItemLoop,"MemberListGuid",data.GUID)

        if refreshNum < 4 then
            GUI.ScrollRectSetVertical(ApplyItemLoop,true)
        else
            GUI.ScrollRectSetVertical(ApplyItemLoop,false)
        end

        GUI.LoopScrollRectSetTotalCount(ApplyItemLoop, refreshNum)
        GUI.LoopScrollRectRefreshCells(ApplyItemLoop)
    end

end


function DistributionGambleUI.CreateApplyItem(guid)
    local ApplyItemLoop = GUI.GetByGuid(tostring(guid))

    local index = GUI.LoopScrollRectGetChildInPoolCount(ApplyItemLoop) + 1

    local item = GUI.ItemCtrlCreate(ApplyItemLoop,"ShoppingItem"..index,QualityRes[1],0,0,50,50,false,"system",false)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,55,55)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.RightBottomNum,5,2,25,25)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "DistributionGambleUI", "OnApplyItemClick")

    --金色选择框图片
    local SelectImage = GUI.ImageCreate(item,"SelectImage","1800400280",0,-2,false,75,75)
    GUI.SetVisible(SelectImage,false)
    SetSameAnchorAndPivot(SelectImage, UILayout.Center)

    --减少图片
    local DeleteButton = GUI.ButtonCreate(item,"DeleteButton","1800607310",0,0,Transition.ColorTint,"",25,25,false,false)
    GUI.RegisterUIEvent(DeleteButton, UCE.PointerClick, "DistributionGambleUI", "OnDeleteButtonClick")
    GUI.SetVisible(DeleteButton,false)
    SetSameAnchorAndPivot(DeleteButton, UILayout.TopRight)

    local itemGuid = tostring(GUI.GetGuid(item))

    memberListGainTable[itemGuid] = tostring(guid)

    return item
end

function DistributionGambleUI.RefreshApplyItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)


    local SelectImage = GUI.GetChild(item,"SelectImage",false)
    local DeleteButton = GUI.GetChild(item,"DeleteButton",false)


    local parentGuid = memberListGainTable[tostring(guid)]

    local parent = GUI.GetByGuid(parentGuid)

    local parentIndex = tonumber(GUI.GetData(parent,"index"))

    if memberListTable[parentIndex] == nil then

        GUI.SetVisible(SelectImage,false)
        GUI.SetVisible(DeleteButton,false)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,"")
        GUI.UnRegisterUIEvent(item, UCE.PointerClick, "DistributionGambleUI", "OnApplyItemClick")
        GUI.DelData(item,"itemId")

        return

    end

    if memberListTable[parentIndex].GetItem == nil then

        GUI.SetVisible(SelectImage,false)
        GUI.SetVisible(DeleteButton,false)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,"")
        GUI.DelData(item,"itemId")

        return

    end

    local data = memberListTable[parentIndex].GetItem[index]


    if data then

        local itemDB = DB.GetOnceItemByKey2(tostring(data[1]))
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,itemDB.Icon)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[itemDB.Grade])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,tostring(data[2]))
        GUI.SetData(item,"itemId",tostring(itemDB.Id))


        GUI.SetVisible(SelectImage,false)
        GUI.SetVisible(DeleteButton,false)

        GUI.SetData(DeleteButton,"memberGuid",tostring(memberListTable[parentIndex].GUID))

        GUI.SetData(DeleteButton,"keyName",tostring(data[1]))

    else


        GUI.SetVisible(SelectImage,false)
        GUI.SetVisible(DeleteButton,false)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,"")
        GUI.DelData(item,"itemId")

        GUI.DelData(DeleteButton,"memberGuid")

        GUI.DelData(DeleteButton,"keyName")

    end


    if isOpenDistribution then

        if guid == nowSelectItemGuid then

            GUI.SetVisible(SelectImage,true)
            GUI.SetVisible(DeleteButton,true)

        else

            GUI.SetVisible(SelectImage,false)
            GUI.SetVisible(DeleteButton,false)

        end

    else

        GUI.SetVisible(SelectImage,false)
        GUI.SetVisible(DeleteButton,false)

    end
end

function DistributionGambleUI.CreateRightBagItem()
    local rightBagItemLoop = _gt.GetUI("rightBagItemLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(rightBagItemLoop) + 1

    local item = GUI.ItemCtrlCreate(rightBagItemLoop,"RightBagItem"..index,QualityRes[1],0,0,50,50,false,"system",false)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,0,65,65)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.RightBottomNum,7,6,65,65)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "DistributionGambleUI", "OnRightBagItemClick")

    return item

end

function DistributionGambleUI.RefreshRightBagItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = distributionItemTable[index]


    if data then

        local itemDB = DB.GetOnceItemByKey2(data.keyName)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,itemDB.Icon)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[itemDB.Grade])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,data.clickNum.."/"..data.amount)

        GUI.SetData(item,"index",index)
        GUI.SetData(item,"Id",itemDB.Id)
        GUI.SetData(item,"keyName",itemDB.KeyName)

        GUI.RegisterUIEvent(item, UCE.PointerClick, "DistributionGambleUI", "OnRightBagItemClick")


    else

        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,"")

        GUI.UnRegisterUIEvent(item, UCE.PointerClick, "DistributionGambleUI", "OnRightBagItemClick")

    end
end

function DistributionGambleUI.AllDataInit()

    DistributionAllDataTable = {}

    distributionItemTable = {}

    memberListGUIDGainTable = {}

    leaderGainTable = {}

    memberListTable = {}

    gainMemberItemTable = {}

    isOpenDistribution = false

    nowSelectItemGuid = nil

    lastSelectPlayerGuid = nil

    selfStatus = 0

end

function DistributionGambleUI.OnContactItemClick(guid)

    local checkBox = GUI.GetByGuid(guid)

    if lastSelectPlayerGuid == nil then

        GUI.CheckBoxExSetCheck(checkBox, false)


    else

        if lastSelectPlayerGuid ~= guid then

            local lastCheckBox = GUI.GetByGuid(lastSelectPlayerGuid)

            GUI.CheckBoxExSetCheck(lastCheckBox, false)

        end

        GUI.CheckBoxExSetCheck(checkBox, true)

    end

    isOpenDistribution = false

    nowSelectItemGuid = nil

    lastSelectPlayerGuid = tostring(guid)

    --刷新队伍Loop
    DistributionGambleUI.RefreshRoleApplyItemLoopData()

end

function DistributionGambleUI.OnRoleItemClick(guid)

    test("左边列表头像点击事件")

    local icon = GUI.GetByGuid(guid)

    local parent = GUI.GetParentElement(icon)

    local parentGuid = GUI.GetGuid(parent)

    DistributionGambleUI.OnContactItemClick(parentGuid)

end
--右边背包Item点击事件
function DistributionGambleUI.OnRightBagItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(item,"index"))
    local itemGuid = GUI.GetData(item,"guid")
    local id = GUI.GetData(item,"Id")
    local keyName = GUI.GetData(item,"keyName")

    local centerBg = _gt.GetUI("centerBg")
    local tip = Tips.CreateByItemId(tonumber(id), centerBg, "tip",-430,30)
    GUI.SetData(tip, "ItemId", id)

    if distributionItemTable[index].clickNum > 0 then

        distributionItemTable[index].clickNum = distributionItemTable[index].clickNum - 1

    else

        CL.SendNotify(NOTIFY.ShowBBMsg, "该物品已分配完毕")
        return

    end

    if lastSelectPlayerGuid ~= nil then

        local checkBox = GUI.GetByGuid(lastSelectPlayerGuid)

        local memberGuid = GUI.GetData(checkBox,"memberGuid")

        local index1 = nil
        local index2 = nil

        for i = 1, #memberListTable do

            if memberListTable[i].GUID == memberGuid then

                index1 = i

                for j = 1, #memberListTable[index1].GetItem do


                    if memberListTable[index1].GetItem[j][1] == keyName then

                        index2 = j

                    end

                end

            end


        end

        if index1 ~= nil then

            if index2 ~= nil then

                memberListTable[index1].GetItem[index2][2] = memberListTable[index1].GetItem[index2][2] + 1

            else

                local temp = {keyName,1}

                table.insert(memberListTable[index1].GetItem,temp)

            end

        end

        test("memberListTable",inspect(memberListTable))



    end

    --刷新队伍Loop
    DistributionGambleUI.RefreshRoleApplyItemLoopData()

    --刷新右边分配Loop
    DistributionGambleUI.RefreshRightBagItemLoopData()

    test("右边背包Item点击事件")
end


function DistributionGambleUI.OnSubmitBtnClick()

    local temp = {}

    for i = 1, #memberListTable do

        temp[memberListTable[i].GUID] = memberListTable[i].GetItem

    end

    test("temp",inspect(temp))

    local json = jsonUtil.encode(temp)

    CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","JiangLiFenPei",json)

end

--左边物品栏点击事件
function DistributionGambleUI.OnApplyItemClick(guid)

    test("左边物品栏点击事件")

    local item = GUI.GetByGuid(guid)

    local index = tonumber(GUI.GetData(item,"index"))

    local itemId = tonumber(GUI.GetData(item,"itemId"))
    local centerBg = _gt.GetUI("centerBg")
    if itemId ~= nil then
        local tip = Tips.CreateByItemId(tonumber(itemId), centerBg, "tip",-430,30)
        GUI.SetData(tip, "ItemId", itemId)

        isOpenDistribution = true

        nowSelectItemGuid = tostring(guid)
    else
        isOpenDistribution = false

        nowSelectItemGuid = nil
    end

    --刷新队伍Loop
    DistributionGambleUI.RefreshRoleApplyItemLoopData()

end

--左边物品栏删除按钮点击事件
function DistributionGambleUI.OnDeleteButtonClick(guid)

    test("左边物品栏删除按钮点击事件")

    local item = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(item,"index"))

    local memberGuid = tostring(GUI.GetData(item,"memberGuid"))
    local keyName = tostring(GUI.GetData(item,"keyName"))


    test("memberGuid",tostring(memberGuid))
    test("keyName",tostring(keyName))


    local index1 = nil
    local index2 = nil

    for i = 1, #memberListTable do

        if memberListTable[i].GUID == memberGuid then

            index1 = i

            for j = 1, #memberListTable[index1].GetItem do


                if memberListTable[index1].GetItem[j][1] == keyName then

                    index2 = j

                end

            end

        end


    end

    if index1 ~= nil then

        if index2 ~= nil then

            if memberListTable[index1].GetItem[index2][2] > 0 then

                memberListTable[index1].GetItem[index2][2] = memberListTable[index1].GetItem[index2][2] - 1

            end


            if memberListTable[index1].GetItem[index2][2] == 0 then

                nowSelectItemGuid = nil
                table.remove(memberListTable[index1].GetItem,index2)

            end

            for i = 1, #distributionItemTable do

                if distributionItemTable[i].keyName == keyName then

                    if distributionItemTable[i].clickNum < distributionItemTable[i].amount then

                        distributionItemTable[i].clickNum = distributionItemTable[i].clickNum + 1

                    end

                end

            end

        end

    end

    test("memberListTable",inspect(memberListTable))

    --刷新队伍Loop
    DistributionGambleUI.RefreshRoleApplyItemLoopData()

    --刷新右边分配Loop
    DistributionGambleUI.RefreshRightBagItemLoopData()


end

function DistributionGambleUI.OnExit()
    GUI.CloseWnd("DistributionGambleUI")
end