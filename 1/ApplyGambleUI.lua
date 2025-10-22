local ApplyGambleUI = {}
_G.ApplyGambleUI = ApplyGambleUI

--孤注一掷活动报名界面


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
----------------------------------------------End 颜色配置 End-----------------------------------

------------------------------------------Start 全局变量 Start----------------------------------

--二级页签index
local secondaryLabelIndex = 1

--开启选择物品表
local OpenChoice = true

local lastSubmitBagItemGuid = nil

--限制提交数量--客户端默认15，服务器可更改
local limitSubmitItemNum = 15

local selfState = 0

local teamState = nil

local enemyTotalCount = nil

local selfTotalCount = nil

----------------------------------------------End 全局变量 End-----------------------------------


------------------------------------------Start 表配置 Start----------------------------------

local subTabList = {
    { "道具", "itemSubTabBtn", "1800402030", "1800402032", "OnItemSubTabBtnClick", -160, -195, 165, 40, 100, 35 },
    { "宝石", "gemSubTabBtn", "1800402030", "1800402032", "OnGemSubTabBtnClick", 0, -195, 165, 40, 100, 35 },
    { "信物", "tokenSubTabBtn", "1800402030", "1800402032", "OnTokenSubTabBtnClick", 159, -195, 165, 40, 100, 35 },
}



local bagTypeItemTable = {
    item = {},
    gem = {},
    guard = {}
}

local teamTable = {}

--提交的物品表
local submitBagItemTable = {}

--------------------------------------------End 表配置 End------------------------------------

function ApplyGambleUI.Main(parameter)
    local panel = GUI.WndCreateWnd("ApplyGambleUI" , "ApplyGambleUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "投 掷 报 名",960,620,"ApplyGambleUI","OnExit",_gt)

    local centerBg = GUI.ImageCreate(panelBg, "LeftBg", "1800400200", 0, 70, false, 860, 460)
    SetSameAnchorAndPivot(centerBg, UILayout.Top)

    --左边队伍Loop
    local RoleApplyItemLoop =
    GUI.LoopScrollRectCreate(
            centerBg,
            "RoleApplyItemLoop",
            10,
            15,
            340,
            430,
            "ApplyGambleUI",
            "CreateRoleApplyItem",
            "ApplyGambleUI",
            "RefreshRoleApplyItem",
            0,
            false,
            Vector2.New(340, 200),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(RoleApplyItemLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(RoleApplyItemLoop, TextAnchor.UpperLeft)
    _gt.BindName(RoleApplyItemLoop, "RoleApplyItemLoop")
    GUI.ScrollRectSetChildSpacing(RoleApplyItemLoop, Vector2.New(0, 10))

    local rightItemBg = GUI.ImageCreate(centerBg, "rightItemBg", "1800201130", -10, 10, false, 490, 440)
    SetSameAnchorAndPivot(rightItemBg, UILayout.TopRight)

    local rightItemPage = GUI.GroupCreate(rightItemBg, "rightItemPage", 0, 0, GUI.GetWidth(rightItemBg), GUI.GetHeight(rightItemBg))
    _gt.BindName(rightItemPage,"rightItemPage")
    SetSameAnchorAndPivot(rightItemPage, UILayout.Top)

    UILayout.CreateSubTab(subTabList, rightItemPage, "ApplyGambleUI")

    local rightBagItemLoop =
    GUI.LoopScrollRectCreate(
            rightItemPage,
            "rightBagItemLoop",
            0,
            45,
            GUI.GetWidth(rightItemBg) - 14,
            GUI.GetHeight(rightItemBg) - 150,
            "ApplyGambleUI",
            "CreateRightBagItem",
            "ApplyGambleUI",
            "RefreshRightBagItem",
            0,
            false,
            Vector2.New(77, 77),
            6,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(rightBagItemLoop, UILayout.Top)
    GUI.ScrollRectSetAlignment(rightBagItemLoop, TextAnchor.UpperLeft)
    _gt.BindName(rightBagItemLoop, "rightBagItemLoop")
    GUI.ScrollRectSetChildSpacing(rightBagItemLoop, Vector2.New(3, 3))

    local bg = GUI.ImageCreate(rightItemPage, "bg", "1800600140", 8, -8, false,340, 80)
    SetSameAnchorAndPivot(bg, UILayout.BottomLeft)

    local submitBagItemLoop =
    GUI.LoopScrollRectCreate(
            bg,
            "submitBagItemLoop",
            -1,
            -5,
            324,
            80,
            "ApplyGambleUI",
            "CreateSubmitBagItem",
            "ApplyGambleUI",
            "RefreshSubmitBagItem",
            0,
            true,
            Vector2.New(70, 70),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(submitBagItemLoop, UILayout.Top)
    GUI.ScrollRectSetAlignment(submitBagItemLoop, TextAnchor.UpperLeft)
    _gt.BindName(submitBagItemLoop, "submitBagItemLoop")
    GUI.ScrollRectSetChildSpacing(submitBagItemLoop, Vector2.New(3, 3))


    --提交物品数量
    local selfItemTxt = GUI.CreateStatic(rightItemPage,"selfItemTxt","已选择:0" ,42,-62,180, 30, "system", true, false)
    _gt.BindName(selfItemTxt,"selfItemTxt")
    GUI.StaticSetFontSize(selfItemTxt,22)
    GUI.StaticSetAlignment(selfItemTxt,TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(selfItemTxt, UILayout.BottomRight)
    GUI.SetColor(selfItemTxt,Brown4Color)

    local submitBtn = GUI.ButtonCreate(rightItemPage, "submitBtn", "1800402080", -8, -7, Transition.ColorTint, "提 交", 130, 55, false)
    GUI.ButtonSetTextFontSize(submitBtn, 30)
    _gt.BindName(submitBtn,"submitBtn")
    GUI.SetIsOutLine(submitBtn, true)
    GUI.ButtonSetTextColor(submitBtn, WhiteColor)
    GUI.SetOutLine_Color(submitBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(submitBtn,OutLineDistance)
    SetSameAnchorAndPivot(submitBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(submitBtn, UCE.PointerClick, "ApplyGambleUI", "OnSubmitBtnClick")


    --提交物品数量
    local submitItemTxt = GUI.CreateStatic(panelBg,"submitItemTxt","" ,50,-20,320, 30, "system", true, false)
    _gt.BindName(submitItemTxt,"submitItemTxt")
    GUI.StaticSetFontSize(submitItemTxt,24)
    GUI.StaticSetAlignment(submitItemTxt,TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(submitItemTxt, UILayout.BottomLeft)
    GUI.SetColor(submitItemTxt,Brown4Color)

    local applyBtn = GUI.ButtonCreate(panelBg, "applyBtn", "1800402080", 0, -25, Transition.ColorTint, "确 认", 180, 55, false)
    _gt.BindName(applyBtn,"applyBtn")
    GUI.ButtonSetTextFontSize(applyBtn, 30)
    GUI.SetIsOutLine(applyBtn, true)
    GUI.ButtonSetTextColor(applyBtn, WhiteColor)
    GUI.SetOutLine_Color(applyBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(applyBtn,OutLineDistance)
    SetSameAnchorAndPivot(applyBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(applyBtn, UCE.PointerClick, "ApplyGambleUI", "OnApplyBtnClick")

end

function ApplyGambleUI.OnShow(parameter)
    local wnd = GUI.GetWnd("ApplyGambleUI");
    if wnd == nil then
        return
    end
    ApplyGambleUI.Init()
    GUI.SetVisible(wnd, true)

end

function ApplyGambleUI.Init()
    secondaryLabelIndex = 1

    lastSubmitBagItemGuid = nil

    selfState = 0

    teamState = nil

    enemyTotalCount = nil

    selfTotalCount = nil

    OpenChoice = true

    bagTypeItemTable = {
        item = {},
        gem = {},
        guard = {}
    }
end

--服务器回调刷新
function ApplyGambleUI.RefreshAllData()
    test("服务器回调刷新")


    limitSubmitItemNum = tonumber(ApplyGambleUI.MaxSubmitNum)


    --左边队伍Loop(一定要放在所有刷新最前面)
    ApplyGambleUI.RefreshRoleApplyItemLoopData()


    local temporaryTable = ApplyGambleUI.TeamData.MemberAllData

    local selfGuid = tostring(LD.GetSelfGUID())
    for i = 1, #temporaryTable do

        if selfGuid == temporaryTable[i].GUID then

            submitBagItemTable = temporaryTable[i].ItemList

        end

    end

    local selfItemTxt = _gt.GetUI("selfItemTxt")
    GUI.StaticSetText(selfItemTxt,"已选择："..#submitBagItemTable)

    teamState = tonumber(ApplyGambleUI.state)

    test("teamState",tostring(teamState))

    test("submitBagItemTable",inspect(submitBagItemTable))

    --右下角loop
    ApplyGambleUI.RefreshSubmitBagItemLoopData()

    --设置确认按钮状态
    ApplyGambleUI.SetApplyBtnStatus()

    --获取背包数据
    ApplyGambleUI.GetTypeBagItemData()

    --设置提交按钮状态
    ApplyGambleUI.SetSubmitBtnStatus()

    --设置提交物品数量提示文字
    ApplyGambleUI.SetSubmitItemTxtData()



end

--设置提交物品数量提示文字
function ApplyGambleUI.SetSubmitItemTxtData()

    local submitItemTxt = _gt.GetUI("submitItemTxt")

    if teamState == 0 then
        GUI.SetVisible(submitItemTxt,true)

        local txt = ""

        if enemyTotalCount > limitSubmitItemNum then
            txt = "可提交物品总数：".."<color=#FF0000>"..selfTotalCount.."</color>".."/"..limitSubmitItemNum
        else
            txt = "可提交物品总数："..selfTotalCount.."/"..limitSubmitItemNum
        end

        GUI.StaticSetText(submitItemTxt,txt)

    else

        GUI.SetVisible(submitItemTxt,true)

        local txt = ""

        if enemyTotalCount > selfTotalCount then
            txt = "需提交物品总数：".."<color=#FF0000>"..selfTotalCount.."</color>".."/"..enemyTotalCount
        else
            txt = "需提交物品总数："..selfTotalCount.."/"..enemyTotalCount
        end

        GUI.StaticSetText(submitItemTxt,txt)

    end



end
--设置提交按钮状态
function ApplyGambleUI.SetSubmitBtnStatus()
    local submitBtn = _gt.GetUI("submitBtn")

    if selfState == 1 then
        GUI.ButtonSetText(submitBtn,"取 消")
        OpenChoice = false
    else
        GUI.ButtonSetText(submitBtn,"提 交")
        OpenChoice = true
    end
end

--设置确认按钮状态
function ApplyGambleUI.SetApplyBtnStatus()
    test("设置确认按钮状态")
    local selfGuid = tostring(LD.GetSelfGUID())
    local LeaderGUID = ApplyGambleUI.TeamData.LeaderGUID

    local applyBtn = _gt.GetUI("applyBtn")

    if selfGuid == LeaderGUID then
        GUI.SetVisible(applyBtn,true)
    else
        GUI.SetVisible(applyBtn,false)
    end

end

function ApplyGambleUI.RefreshSubmitBagItemLoopData()

    local submitBagItemLoop = _gt.GetUI("submitBagItemLoop")
    GUI.LoopScrollRectSetTotalCount(submitBagItemLoop, limitSubmitItemNum)
    GUI.LoopScrollRectRefreshCells(submitBagItemLoop)
end

function ApplyGambleUI.RefreshSubmitBagItemLoopDataAndGoBy()
    local submitBagItemLoop = _gt.GetUI("submitBagItemLoop")
    GUI.LoopScrollRectSetTotalCount(submitBagItemLoop, limitSubmitItemNum)
    if #submitBagItemTable > 4 then
        GUI.LoopScrollRectSrollToCell(submitBagItemLoop,#submitBagItemTable - 4,1000)
    end

    GUI.LoopScrollRectRefreshCells(submitBagItemLoop)
end


function ApplyGambleUI.RefreshRoleApplyItemLoopData()

    enemyTotalCount = ApplyGambleUI.EnemyTotalCount

    selfTotalCount = ApplyGambleUI.SelfTotalCount

    test("enemyTotalCount",tostring(enemyTotalCount))
    test("selfTotalCount",tostring(selfTotalCount))

    local temporaryTable = ApplyGambleUI.TeamData.MemberAllData

    local selfGuid = tostring(LD.GetSelfGUID())
    teamTable = {}
    for i = 1, #temporaryTable do

        if selfGuid == temporaryTable[i].GUID then

            selfState = temporaryTable[i].state

            table.insert(teamTable,1,temporaryTable[i])
        else
            table.insert(teamTable,temporaryTable[i])
        end

    end


    test("teamTable",inspect(teamTable))

    --设置提交按钮状态
    ApplyGambleUI.SetSubmitBtnStatus()

    --设置提交物品数量提示文字
    ApplyGambleUI.SetSubmitItemTxtData()

    local RoleApplyItemLoop = _gt.GetUI("RoleApplyItemLoop")
    GUI.LoopScrollRectSetTotalCount(RoleApplyItemLoop, #teamTable)
    GUI.LoopScrollRectRefreshCells(RoleApplyItemLoop)
end

function ApplyGambleUI.CreateRoleApplyItem()
    local RoleApplyItemLoop = _gt.GetUI("RoleApplyItemLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(RoleApplyItemLoop) + 1

    local itemGroup = GUI.GroupCreate(RoleApplyItemLoop,"itemGroup"..index, 0, 0, 340, 200,false)
    SetSameAnchorAndPivot(itemGroup, UILayout.TopLeft)

    local groupBg = GUI.ImageCreate(itemGroup, "groupBg", "1800400020", 0, 0, false, 340, 200)
    SetSameAnchorAndPivot(groupBg, UILayout.TopLeft)

    local roleItem = GUI.ItemCtrlCreate(groupBg,"roleItem",QualityRes[1],25,10,100,100,false,"system",false)
    GUI.ItemCtrlSetElementRect(roleItem,eItemIconElement.Icon,0,-1,85,85)
    GUI.ItemCtrlSetElementRect(roleItem,eItemIconElement.LeftTopSp,7,7,44,24)
    SetSameAnchorAndPivot(roleItem, UILayout.TopLeft)
    --GUI.RegisterUIEvent(roleItem, UCE.PointerClick, "ApplyGambleUI", "OnRoleItemClick")


    local confirmIcon = GUI.ImageCreate(roleItem,"confirmIcon" , "1800608400" , 0 , 10,false,80,80)
    GUI.SetVisible(confirmIcon,false)
    SetSameAnchorAndPivot(confirmIcon, UILayout.Center)

    --角色战力图标
    local fightIcon = GUI.ImageCreate(roleItem,"fightIcon" , "1800407010" , -15 , 100,false,30,30)
    SetSameAnchorAndPivot(fightIcon, UILayout.Left)

    --角色战力
    local fightTxt = GUI.CreateStatic(fightIcon,"fightTxt","1234567" ,35,0,140, 30, "system", false, false)
    GUI.StaticSetFontSize(fightTxt,24)
    GUI.StaticSetAlignment(fightTxt,TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(fightTxt, UILayout.Left)
    GUI.SetColor(fightTxt,Brown4Color)

    --角色名字
    local nameTxt = GUI.CreateStatic(fightIcon,"nameTxt","六个字名字" ,-10,-30,140, 30, "system", false, false)
    GUI.StaticSetFontSize(nameTxt,25)
    GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(nameTxt, UILayout.Left)
    GUI.SetIsOutLine(nameTxt,true)
    GUI.SetOutLine_Color(nameTxt,UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(nameTxt,1)

    local ApplyItemLoop =
    GUI.LoopScrollRectCreate(
            itemGroup,
            "ApplyItemLoop",
            27,
            7,
            220,
            180,
            "ApplyGambleUI",
            "CreateApplyItem",
            "ApplyGambleUI",
            "RefreshApplyItem",
            0,
            false,
            Vector2.New(60, 60),
            3,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(ApplyItemLoop, UILayout.TopRight)
    GUI.ScrollRectSetAlignment(ApplyItemLoop, TextAnchor.UpperLeft)
    GUI.ScrollRectSetChildSpacing(ApplyItemLoop, Vector2.New(3, 3))

    return itemGroup
end

function ApplyGambleUI.RefreshRoleApplyItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemGroup = GUI.GetByGuid(guid)

    local data = teamTable[index]



    if data then

        local groupBg = GUI.GetChild(itemGroup,"groupBg",false)

        local roleItem = GUI.GetChild(groupBg,"roleItem",false)

        local confirmIcon = GUI.GetChild(roleItem,"confirmIcon",false)

        local fightIcon = GUI.GetChild(roleItem,"fightIcon",false)

        local fightTxt = GUI.GetChild(fightIcon,"fightTxt",false)

        local nameTxt = GUI.GetChild(fightIcon,"nameTxt",false)

        local roleDB = DB.GetRole(data.Role_Id)
        GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.Icon,tostring(roleDB.Head))

        if data.GUID == ApplyGambleUI.TeamData.LeaderGUID then
            GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.LeftTopSp,"1800604010")
        else
            GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.LeftTopSp,"1800604090")
        end


        GUI.StaticSetText(fightTxt,data.FightValue)

        GUI.StaticSetText(nameTxt,data.Name)

        if data.state == 1 then
            GUI.SetVisible(confirmIcon,true)
        else
            GUI.SetVisible(confirmIcon,false)
        end


        local ApplyItemLoop = GUI.GetChild(itemGroup,"ApplyItemLoop",false)
        local refreshNum = 9
        local itemTable = data.ItemList
        if #itemTable > refreshNum then
            refreshNum = math.ceil(#itemTable / 3) * 3
        end
        GUI.SetData(ApplyItemLoop,"index",index)
        GUI.LoopScrollRectSetTotalCount(ApplyItemLoop, refreshNum)
        GUI.LoopScrollRectRefreshCells(ApplyItemLoop)
    end

end

function ApplyGambleUI.CreateApplyItem(guid)
    local ApplyItemLoop = GUI.GetByGuid(tostring(guid))

    local parentIndex = tonumber(GUI.GetData(ApplyItemLoop,"index"))


    local index = GUI.LoopScrollRectGetChildInPoolCount(ApplyItemLoop) + 1

    local item = GUI.ItemCtrlCreate(ApplyItemLoop,"ShoppingItem"..index,QualityRes[1],0,0,50,50,false,"system",false)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,45,45)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "ApplyGambleUI", "OnApplyItemClick")

    GUI.SetData(item,"parentIndex",parentIndex)

    return item
end

function ApplyGambleUI.RefreshApplyItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local parentIndex = tonumber(GUI.GetData(item,"parentIndex"))
    if teamTable[parentIndex] == nil then
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.DelData(item,"itemId")
        return
    end
    if teamTable[parentIndex].ItemList == nil then
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.DelData(item,"itemId")
        return
    end
    local data = teamTable[parentIndex].ItemList[index]
    if data then
        local itemDB = DB.GetOnceItemByKey1(tostring(data.id))
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,itemDB.Icon)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[itemDB.Grade])
        GUI.SetData(item,"itemId",tostring(data.id))
    else
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.DelData(item,"itemId")
    end
end

function ApplyGambleUI.OnApplyItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local itemId= tonumber(GUI.GetData(item,"itemId"))
    local rightItemPage = _gt.GetUI("rightItemPage")
    local tip = Tips.CreateByItemId(tonumber(itemId), rightItemPage, "appleItemTips",-40,40)
    GUI.SetData(tip, "ItemId", itemId)
end

function ApplyGambleUI.CreateRightBagItem()
    local rightBagItemLoop = _gt.GetUI("rightBagItemLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(rightBagItemLoop) + 1

    local item = GUI.ItemCtrlCreate(rightBagItemLoop,"RightBagItem"..index,QualityRes[1],0,0,50,50,false,"system",false)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,0,65,65)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "ApplyGambleUI", "OnRightBagItemClick")

    return item
end

function ApplyGambleUI.RefreshRightBagItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)


    local data = nil

    if secondaryLabelIndex == 1 then

        data = bagTypeItemTable.item[index]

    elseif secondaryLabelIndex == 2 then

        data = bagTypeItemTable.gem[index]

    elseif secondaryLabelIndex == 3 then

        data = bagTypeItemTable.guard[index]

    end

    if data then
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,data.Icon)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[data.Grade])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,data.ClickNum.."/"..data.Amount)


        GUI.SetData(item,"guid",data.Guid)
        GUI.SetData(item,"index",index)
        GUI.SetData(item,"Id",data.Id)

        GUI.RegisterUIEvent(item, UCE.PointerClick, "ApplyGambleUI", "OnRightBagItemClick")
    else
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,"")

        GUI.UnRegisterUIEvent(item, UCE.PointerClick, "ApplyGambleUI", "OnRightBagItemClick")
    end
end

--右边背包Item点击事件
function ApplyGambleUI.OnRightBagItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(item,"index"))
    local itemGuid = GUI.GetData(item,"guid")
    local id = GUI.GetData(item,"Id")

    test("右边背包Item点击事件")

    if #submitBagItemTable >= limitSubmitItemNum then

        CL.SendNotify(NOTIFY.ShowBBMsg, "可提交物品已达上限")
        return

    end

    if OpenChoice then

        if #submitBagItemTable < limitSubmitItemNum then

            if secondaryLabelIndex == 1 then


                if bagTypeItemTable.item[index].ClickNum < bagTypeItemTable.item[index].Amount then
                    local temp = {
                        guid = itemGuid,
                        id = id
                    }
                    table.insert(submitBagItemTable,temp)

                    bagTypeItemTable.item[index].ClickNum = bagTypeItemTable.item[index].ClickNum + 1

                    test("bagTypeItemTable",inspect(bagTypeItemTable))

                end

            elseif secondaryLabelIndex == 2 then

                if bagTypeItemTable.gem[index].ClickNum < bagTypeItemTable.gem[index].Amount then
                    local temp = {
                        guid = itemGuid,
                        id = id
                    }
                    table.insert(submitBagItemTable,temp)

                    bagTypeItemTable.gem[index].ClickNum = bagTypeItemTable.gem[index].ClickNum + 1

                end

            elseif secondaryLabelIndex == 3 then


                if bagTypeItemTable.guard[index].ClickNum < bagTypeItemTable.guard[index].Amount then
                    local temp = {
                        guid = itemGuid,
                        id = id
                    }
                    table.insert(submitBagItemTable,temp)

                    bagTypeItemTable.guard[index].ClickNum = bagTypeItemTable.guard[index].ClickNum + 1

                end

            end

            local selfItemTxt = _gt.GetUI("selfItemTxt")

            GUI.StaticSetText(selfItemTxt,"已选择："..#submitBagItemTable)

            --右下角loop
            ApplyGambleUI.RefreshSubmitBagItemLoopDataAndGoBy()

            --右边背包
            ApplyGambleUI.RefreshRightBagItemLoop()

        end

    end

    local rightItemPage = _gt.GetUI("rightItemPage")
    local tip = Tips.CreateByItemId(tonumber(id), rightItemPage, "ItemTips",-450,0)
    GUI.SetData(tip, "ItemId", id)

end

function ApplyGambleUI.CreateSubmitBagItem()
    local submitBagItemLoop = _gt.GetUI("submitBagItemLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(submitBagItemLoop) + 1

    local item = GUI.ItemCtrlCreate(submitBagItemLoop,"SubmitBagItem"..index,QualityRes[1],0,0,50,50,false,"system",false)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,0,55,55)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "ApplyGambleUI", "OnSubmitBagItemClick")

    --加号添加图片
    local addImage = GUI.ImageCreate(item,"addImage","1800707060",0,0,false,50,50)
    GUI.SetVisible(addImage,false)
    SetSameAnchorAndPivot(addImage, UILayout.Center)

    --金色选择框图片
    local SelectImage = GUI.ImageCreate(item,"SelectImage","1800400280",0,0,false,75,75)
    GUI.SetVisible(SelectImage,false)
    SetSameAnchorAndPivot(SelectImage, UILayout.Center)

    --X删除图片
    local DeleteButton = GUI.ButtonCreate(item,"DeleteButton","1800702100",0,0,Transition.ColorTint)
    GUI.RegisterUIEvent(DeleteButton, UCE.PointerClick, "ApplyGambleUI", "OnDeleteButtonClick")
    GUI.SetVisible(DeleteButton,false)
    SetSameAnchorAndPivot(DeleteButton, UILayout.TopRight)

    return item
end

function ApplyGambleUI.OnDeleteButtonClick(guid)
    local btn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(btn,"index"))
    table.remove(submitBagItemTable,index)
    --右下角loop
    ApplyGambleUI.RefreshSubmitBagItemLoopDataAndGoBy()

    ApplyGambleUI.GetTypeBagItemData()

    local selfItemTxt = _gt.GetUI("selfItemTxt")
    GUI.StaticSetText(selfItemTxt,"已选择："..#submitBagItemTable)


    test("submitBagItemTable",inspect(submitBagItemTable))

end

function ApplyGambleUI.RefreshSubmitBagItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local data = submitBagItemTable[index]

    local addImage = GUI.GetChild(item,"addImage",false)
    local SelectImage = GUI.GetChild(item,"SelectImage",false)
    local DeleteButton = GUI.GetChild(item,"DeleteButton",false)

    if data then
        GUI.SetVisible(addImage,false)
        GUI.SetVisible(SelectImage,false)
        GUI.SetVisible(DeleteButton,false)

        local itemDB = DB.GetOnceItemByKey1(data.id)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,itemDB.Icon)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[itemDB.Grade])

        if index == limitSubmitItemNum then
            lastSubmitBagItemGuid = tostring(guid)

            GUI.SetVisible(addImage,false)
            GUI.SetVisible(SelectImage,false)
            GUI.SetVisible(DeleteButton,false)

            OpenChoice = false
        end
        GUI.RegisterUIEvent(item, UCE.PointerClick, "ApplyGambleUI", "OnSubmitBagItemClick")

    else
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])

        if index > #submitBagItemTable  then
            if index == #submitBagItemTable + 1 then
                if OpenChoice then

                    lastSubmitBagItemGuid = tostring(guid)

                    GUI.SetVisible(addImage,true)
                    GUI.SetVisible(SelectImage,true)
                    GUI.SetVisible(DeleteButton,false)

                else
                    GUI.SetVisible(addImage,true)
                    GUI.SetVisible(SelectImage,false)
                    GUI.SetVisible(DeleteButton,false)
                end
                GUI.RegisterUIEvent(item, UCE.PointerClick, "ApplyGambleUI", "OnSubmitBagItemClick")

            else
                GUI.SetVisible(addImage,false)
                GUI.SetVisible(SelectImage,false)
                GUI.SetVisible(DeleteButton,false)
                GUI.UnRegisterUIEvent(item, UCE.PointerClick, "ApplyGambleUI", "OnSubmitBagItemClick")
            end
        end
    end
    GUI.SetData(item,"index",index)
    GUI.SetData(DeleteButton,"index",index)
end

function ApplyGambleUI.OnSubmitBagItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(item,"index"))


    if selfState == 1 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先取消提交状态")
        return
    end

    local addImage = GUI.GetChild(item,"addImage",false)
    local SelectImage = GUI.GetChild(item,"SelectImage",false)
    local DeleteButton = GUI.GetChild(item,"DeleteButton",false)

    local data = submitBagItemTable[index]

    if data then
        if OpenChoice then
            if lastSubmitBagItemGuid ~= tostring(guid) then
                GUI.SetVisible(addImage,false)
                GUI.SetVisible(SelectImage,true)
                GUI.SetVisible(DeleteButton,true)

                OpenChoice = true

            else
                GUI.SetVisible(addImage,false)
                GUI.SetVisible(SelectImage,false)
                GUI.SetVisible(DeleteButton,false)
                OpenChoice = false
            end

        else
            GUI.SetVisible(addImage,false)
            GUI.SetVisible(SelectImage,true)
            GUI.SetVisible(DeleteButton,true)

            OpenChoice = true

        end

    else

        if OpenChoice then

            if lastSubmitBagItemGuid ~= tostring(guid) then
                GUI.SetVisible(addImage,true)
                GUI.SetVisible(SelectImage,true)
                GUI.SetVisible(DeleteButton,false)

                OpenChoice = true
            else
                GUI.SetVisible(addImage,true)
                GUI.SetVisible(SelectImage,false)
                GUI.SetVisible(DeleteButton,false)
                OpenChoice = false
            end

        else

            if lastSubmitBagItemGuid ~= tostring(guid) then
                GUI.SetVisible(addImage,true)
                GUI.SetVisible(SelectImage,true)
                GUI.SetVisible(DeleteButton,false)
            else
                GUI.SetVisible(addImage,true)
                GUI.SetVisible(SelectImage,true)
                GUI.SetVisible(DeleteButton,false)

            end

            OpenChoice = true
        end

    end

    if lastSubmitBagItemGuid ~= tostring(guid) then

        local lastItem = GUI.GetByGuid(lastSubmitBagItemGuid)
        local lastIndex = tonumber(GUI.GetData(lastItem,"index"))

        local lastData = submitBagItemTable[lastIndex]

        local lastAddImage = GUI.GetChild(lastItem,"addImage",false)
        local lastSelectImage = GUI.GetChild(lastItem,"SelectImage",false)
        local lastDeleteButton = GUI.GetChild(lastItem,"DeleteButton",false)

        if lastData then
            GUI.SetVisible(lastAddImage,false)
            GUI.SetVisible(lastSelectImage,false)
            GUI.SetVisible(lastDeleteButton,false)
        else
            GUI.SetVisible(lastAddImage,true)
            GUI.SetVisible(lastSelectImage,false)
            GUI.SetVisible(lastDeleteButton,false)
        end
    else


    end

    lastSubmitBagItemGuid = tostring(guid)

    test("OpenChoice",inspect(OpenChoice))

    --右边背包
    ApplyGambleUI.RefreshRightBagItemLoop()

end

function ApplyGambleUI.OnItemSubTabBtnClick()
    secondaryLabelIndex = 1
    ApplyGambleUI.GetTypeBagItemData()
end

function ApplyGambleUI.OnGemSubTabBtnClick()
    secondaryLabelIndex = 2
    ApplyGambleUI.GetTypeBagItemData()
end

function ApplyGambleUI.OnTokenSubTabBtnClick()
    secondaryLabelIndex = 3
    ApplyGambleUI.GetTypeBagItemData()
end

--获取背包数据
function ApplyGambleUI.GetTypeBagItemData()

    test("获取背包数据")

    test("secondaryLabelIndex",inspect(secondaryLabelIndex))

    UILayout.OnSubTabClickEx(secondaryLabelIndex, subTabList)

    local bagTypeData = item_container_type.item_container_bag

    if secondaryLabelIndex == 1 then

        bagTypeItemTable.item = {}

    elseif secondaryLabelIndex == 2 then

        bagTypeData = item_container_type.item_container_gem_bag
        bagTypeItemTable.gem = {}

    elseif secondaryLabelIndex == 3 then

        bagTypeData = item_container_type.item_container_guard_bag
        bagTypeItemTable.guard = {}

    end

    test("bagTypeItemTable.item",inspect(bagTypeItemTable))

    local sureSubmitBagItemTable = {}

    for i = 1, #submitBagItemTable do
        local tableData = submitBagItemTable[i]
        test("tableData.guid]",tostring(tableData.guid))
        if sureSubmitBagItemTable[tableData.guid] ~= nil then
            sureSubmitBagItemTable[tableData.guid] = sureSubmitBagItemTable[tableData.guid] + 1
        else
            sureSubmitBagItemTable[tableData.guid] = 1
        end
    end


    local BagItemCount = LD.GetItemCount(bagTypeData,0)

    test("BagItemCount",tostring(BagItemCount))
    for i = 0, BagItemCount - 1 do
        local itemData = LD.GetItemDataByItemIndex(i,bagTypeData,0)
        local itemDB = DB.GetOnceItemByKey1(itemData.id)
        if tonumber(itemData.isbound) == 0 then
            local temp = {
                Id = itemDB.Id,
                Guid = tostring(itemData.guid),
                Name = itemDB.Name,
                KeyName = itemDB.KeyName,
                Icon = tostring(itemDB.Icon),
                Subtype = itemDB.Subtype,
                Subtype2 = itemDB.Subtype2,
                IsBound = itemData.isbound,
                Amount = tonumber(itemData.amount),
                Grade = itemDB.Grade,
                ClickNum = sureSubmitBagItemTable[tostring(itemData.guid)] or 0,
                Status  = 1
            }

            if secondaryLabelIndex == 1 then

                table.insert(bagTypeItemTable.item,temp)

            elseif secondaryLabelIndex == 2 then

                table.insert(bagTypeItemTable.gem,temp)

            elseif secondaryLabelIndex == 3 then

                table.insert(bagTypeItemTable.guard,temp)

            end

        end
    end

    test("bagTypeItemTable",inspect(bagTypeItemTable))
    ApplyGambleUI.RefreshRightBagItemLoop()
end

function ApplyGambleUI.RefreshRightBagItemLoop()
    local refreshNum = 24

    local temp = {}

    if secondaryLabelIndex == 1 then

        temp = bagTypeItemTable.item

    elseif secondaryLabelIndex == 2 then

        temp = bagTypeItemTable.gem

    elseif secondaryLabelIndex == 3 then

        temp = bagTypeItemTable.guard

    end

    if #temp > refreshNum then
        refreshNum = math.ceil(#temp / 6) * 6
    end

    local rightBagItemLoop = _gt.GetUI("rightBagItemLoop")
    GUI.LoopScrollRectSetTotalCount(rightBagItemLoop, refreshNum)
    GUI.LoopScrollRectRefreshCells(rightBagItemLoop)
end

--提交按钮点击事件
function ApplyGambleUI.OnSubmitBtnClick()
    test("提交按钮点击事件")

    test("selfTotalCount",tostring(selfTotalCount))
    test("enemyTotalCount",tostring(enemyTotalCount))
    test("submitBagItemTable",inspect(submitBagItemTable))


    OpenChoice = false

    --右下角loop
    ApplyGambleUI.RefreshSubmitBagItemLoopData()

    local guidList = ""
    for i = 1, #submitBagItemTable do
        guidList = guidList..submitBagItemTable[i].guid..","
    end
    CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","SubmitAndJoin",guidList,selfState)
end

function ApplyGambleUI.OnApplyBtnClick()
    if teamState == 0 then
        CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","ConfirmJoin")
    elseif teamState == 1 then

        if enemyTotalCount > selfTotalCount then
            CL.SendNotify(NOTIFY.ShowBBMsg,"提交物品总数不足无法确认")
        else
            CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","LaunchChallenges")
        end

    end

end

function ApplyGambleUI.OnExit ()
    GUI.CloseWnd("ApplyGambleUI")
end