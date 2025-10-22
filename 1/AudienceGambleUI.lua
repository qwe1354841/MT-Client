local  AudienceGambleUI = {}
_G.AudienceGambleUI = AudienceGambleUI

--孤注一掷观众界面

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
----------------------------------------------End 颜色配置 End-----------------------------------


------------------------------------------Start 全局变量 Start----------------------------------

--二级页签index
local secondaryLabelIndex = 1

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

local teamColorTable =
{
    ["普通阵"] = UIDefine.BlueColor,
    ["天罡阵"] = UIDefine.OrangeColor,
    ["玄武阵"] = UIDefine.YellowColor,
    ["朱雀阵"] = UIDefine.RedColor,
    ["白虎阵"] = UIDefine.Blue4Color,
    ["地煞阵"] = UIDefine.PurpleColor,
    ["雷光阵"] = UIDefine.PurpleColor,
    ["风吼阵"] = UIDefine.Green2Color,
    ["蛇行阵"] = UIDefine.PurpleColor,
    ["云雾阵"] = UIDefine.Blue4Color,
    ["青龙阵"] = UIDefine.GreenColor,
}

--------------------------------------------End 表配置 End------------------------------------

function AudienceGambleUI.Main(parameter)
    local panel = GUI.WndCreateWnd("AudienceGambleUI" , "AudienceGambleUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "孤 注 一 掷",960,620,"AudienceGambleUI","OnExit",_gt)

    local centerBg = GUI.ImageCreate(panelBg, "LeftBg", "1800400200", 0, 70, false, 860, 460)
    SetSameAnchorAndPivot(centerBg, UILayout.Top)

    --左边队伍Loop
    local RoleTeamListLoop =
    GUI.LoopScrollRectCreate(
            centerBg,
            "RoleApplyItemLoop",
            10,
            12,
            340,
            435,
            "AudienceGambleUI",
            "CreateTeamListItem",
            "AudienceGambleUI",
            "RefreshTeamListItem",
            0,
            false,
            Vector2.New(340, 140),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(RoleTeamListLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(RoleTeamListLoop, TextAnchor.UpperLeft)
    _gt.BindName(RoleTeamListLoop, "RoleTeamListLoop")
    GUI.ScrollRectSetChildSpacing(RoleTeamListLoop, Vector2.New(0, 8))
    GUI.LoopScrollRectSetTotalCount(RoleTeamListLoop, 6)
    GUI.LoopScrollRectRefreshCells(RoleTeamListLoop)


    local rightItemBg = GUI.ImageCreate(centerBg, "rightItemBg", "1800201130", -10, 10, false, 490, 440)
    _gt.BindName(rightItemBg,"rightItemBg")
    SetSameAnchorAndPivot(rightItemBg, UILayout.TopRight)


end


function AudienceGambleUI.OnShow(parameter)
    local wnd = GUI.GetWnd("AudienceGambleUI");
    if wnd == nil then
        return
    end
    AudienceGambleUI.Init()
    GUI.SetVisible(wnd, true)

    AudienceGambleUI.RefreshAllData()
end

function AudienceGambleUI.Init()
    bagTypeItemTable = {
        item = {},
        gem = {},
        guard = {}
    }
end

function AudienceGambleUI.RefreshAllData()

    --AudienceGambleUI.CreateOrRefreshRoleGamblePage()

    --AudienceGambleUI.CreateOrRefreshAllGamblePage()

    --AudienceGambleUI.CreateOrRefreshBagPage()
end

--是否交易界面
function AudienceGambleUI.CreateOrRefreshRoleGamblePage()

    local rightItemBg = _gt.GetUI("rightItemBg")

    local rightRoleGamblePage = GUI.GetChild(rightItemBg,"rightRoleGamblePage",false)

    if not rightRoleGamblePage then

        rightRoleGamblePage = GUI.GroupCreate(rightItemBg, "rightAllGamblePage", 0, 0, GUI.GetWidth(rightItemBg), GUI.GetHeight(rightItemBg))
        _gt.BindName(rightRoleGamblePage,"rightAllGamblePage")
        SetSameAnchorAndPivot(rightRoleGamblePage, UILayout.Top)

        local rightRoleGambleLoop =
        GUI.LoopScrollRectCreate(
                rightRoleGamblePage,
                "rightRoleGambleLoop",
                5,
                10,
                GUI.GetWidth(rightItemBg) - 14,
                GUI.GetHeight(rightItemBg) - 95,
                "AudienceGambleUI",
                "CreateRoleGambleItem",
                "AudienceGambleUI",
                "RefreshRoleGambleItem",
                0,
                false,
                Vector2.New(465, 140),
                1,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        SetSameAnchorAndPivot(rightRoleGambleLoop, UILayout.Top)
        GUI.ScrollRectSetAlignment(rightRoleGambleLoop, TextAnchor.UpperLeft)
        _gt.BindName(rightRoleGambleLoop, "rightAllGambleLoop")
        GUI.ScrollRectSetChildSpacing(rightRoleGambleLoop, Vector2.New(0, 8))
        GUI.LoopScrollRectSetTotalCount(rightRoleGambleLoop, 6)
        GUI.LoopScrollRectRefreshCells(rightRoleGambleLoop)

        local line = GUI.ImageCreate(rightRoleGamblePage, "line", "1800600140", 0, -75, false, GUI.GetWidth(rightItemBg), 2)
        SetSameAnchorAndPivot(line, UILayout.Bottom)

        local backBtn = GUI.ButtonCreate(rightRoleGamblePage, "backBtn", "1800402080", 0, -10, Transition.ColorTint, "返 回", 150, 55, false)
        GUI.ButtonSetTextFontSize(backBtn, 31)
        GUI.SetIsOutLine(backBtn, true)
        GUI.ButtonSetTextColor(backBtn, WhiteColor)
        GUI.SetOutLine_Color(backBtn, OutLine_BrownColor);
        GUI.SetOutLine_Distance(backBtn,OutLineDistance)
        SetSameAnchorAndPivot(backBtn, UILayout.Bottom)
        GUI.RegisterUIEvent(backBtn, UCE.PointerClick, "GambleTeamInfoUI", "OnRoleGambleBackBtnClick")

    end

end


function AudienceGambleUI.CreateRoleGambleItem()
    local rightAllGambleLoop = _gt.GetUI("rightAllGambleLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(rightAllGambleLoop) + 1

    local itemGroup = GUI.GroupCreate(rightAllGambleLoop,"itemGroup"..index, 0, 0, 465, 140,false)
    SetSameAnchorAndPivot(itemGroup, UILayout.TopLeft)

    local groupBg = GUI.ImageCreate(itemGroup, "groupBg", "1800600140", 0, 0, false, 465, 140)
    SetSameAnchorAndPivot(groupBg, UILayout.TopLeft)

    local role1 = GUI.ItemCtrlCreate(groupBg,"role1",QualityRes[1],30,20,80,80,false,"system",false)
    SetSameAnchorAndPivot(role1, UILayout.TopLeft)
    GUI.ItemCtrlSetElementRect(role1,eItemIconElement.Icon,0,-1,70,70)

    --角色名字
    local nameTxt = GUI.CreateStatic(role1,"nameTxt","六个字名字" ,0,32,140, 30, "system", false, false)
    GUI.StaticSetFontSize(nameTxt,22)
        GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)
    GUI.SetColor(nameTxt,Brown4Color)

    local img = GUI.ImageCreate(groupBg,"img","1801208610",-70,-10,false,68,100)
    SetSameAnchorAndPivot(img, UILayout.Center)


    local role1Item = GUI.ItemCtrlCreate(groupBg,"role1Item",QualityRes[1],25,10,100,100,false,"system",false)
    SetSameAnchorAndPivot(role1Item, UILayout.Top)
    GUI.ItemCtrlSetElementRect(role1Item,eItemIconElement.Icon,0,-1,70,70)

    local applyBtn = GUI.ButtonCreate(groupBg, "applyBtn", "1800402090", -18, 12, Transition.ColorTint, "接 受", 120, 50, false)
    GUI.ButtonSetTextFontSize(applyBtn, 30)
    GUI.SetIsOutLine(applyBtn, true)
    GUI.ButtonSetTextColor(applyBtn, WhiteColor)
    GUI.SetOutLine_Color(applyBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(applyBtn,OutLineDistance)
    SetSameAnchorAndPivot(applyBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(applyBtn, UCE.PointerClick, "GambleTeamInfoUI", "OnRoleGambleApplyBtnClick")

    local refuseBtn = GUI.ButtonCreate(groupBg, "refuseBtn", "1800402080", -18, -18, Transition.ColorTint, "拒 绝", 120, 50, false)
    GUI.ButtonSetTextFontSize(refuseBtn, 30)
    GUI.SetIsOutLine(refuseBtn, true)
    GUI.ButtonSetTextColor(refuseBtn, WhiteColor)
    GUI.SetOutLine_Color(refuseBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(refuseBtn,OutLineDistance)
    SetSameAnchorAndPivot(refuseBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(refuseBtn, UCE.PointerClick, "GambleTeamInfoUI", "OnRoleGambleRefuseBtnClick")



    return itemGroup
end

function AudienceGambleUI.RefreshRoleGambleItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemGroup = GUI.GetByGuid(guid)

end



--投掷信息界面
function AudienceGambleUI.CreateOrRefreshAllGamblePage()
    local rightItemBg = _gt.GetUI("rightItemBg")

    local rightAllGamblePage = GUI.GetChild(rightItemBg,"rightAllGamblePage",false)

    if not rightAllGamblePage then

        rightAllGamblePage = GUI.GroupCreate(rightItemBg, "rightAllGamblePage", 0, 0, GUI.GetWidth(rightItemBg), GUI.GetHeight(rightItemBg))
        _gt.BindName(rightAllGamblePage,"rightAllGamblePage")
        SetSameAnchorAndPivot(rightAllGamblePage, UILayout.Top)

        local rightAllGambleLoop =
        GUI.LoopScrollRectCreate(
                rightAllGamblePage,
                "rightAllGambleLoop",
                5,
                10,
                GUI.GetWidth(rightItemBg) - 14,
                GUI.GetHeight(rightItemBg) - 20,
                "AudienceGambleUI",
                "CreateAllGambleItem",
                "AudienceGambleUI",
                "RefreshAllGambleItem",
                0,
                false,
                Vector2.New(465, 180),
                1,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        SetSameAnchorAndPivot(rightAllGambleLoop, UILayout.Top)
        GUI.ScrollRectSetAlignment(rightAllGambleLoop, TextAnchor.UpperLeft)
        _gt.BindName(rightAllGambleLoop, "rightAllGambleLoop")
        GUI.ScrollRectSetChildSpacing(rightAllGambleLoop, Vector2.New(0, 8))
        GUI.LoopScrollRectSetTotalCount(rightAllGambleLoop, 6)
        GUI.LoopScrollRectRefreshCells(rightAllGambleLoop)

    end




end

--右边背包物品
function AudienceGambleUI.CreateOrRefreshBagPage()

    local rightItemBg = _gt.GetUI("rightItemBg")

    local rightItemPage = GUI.GetChild(rightItemBg,"rightItemPage",false)

    if not rightItemPage then
        rightItemPage = GUI.GroupCreate(rightItemBg, "rightItemPage", 0, 0, GUI.GetWidth(rightItemBg), GUI.GetHeight(rightItemBg))
        _gt.BindName(rightItemPage,"rightItemPage")
        SetSameAnchorAndPivot(rightItemPage, UILayout.Top)

        UILayout.CreateSubTab(subTabList, rightItemPage, "AudienceGambleUI")

        local rightBagItemLoop =
        GUI.LoopScrollRectCreate(
                rightItemPage,
                "rightBagItemLoop",
                0,
                45,
                GUI.GetWidth(rightItemBg) - 14,
                GUI.GetHeight(rightItemBg) - 150,
                "AudienceGambleUI",
                "CreateRightBagItem",
                "AudienceGambleUI",
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

        local line = GUI.ImageCreate(rightItemPage, "line", "1800600140", 0, -98, false, GUI.GetWidth(rightItemBg), 2)
        SetSameAnchorAndPivot(line, UILayout.Bottom)


        for i = 1, 5 do
            local roleItem = GUI.ItemCtrlCreate(rightItemPage,"roleItem"..i,QualityRes[1],(i - 1) * 75 + 10,-15,70,70,false,"system",false)
            SetSameAnchorAndPivot(roleItem, UILayout.BottomLeft)
            GUI.ItemCtrlSetElementRect(roleItem,eItemIconElement.Icon,0,-1,70,70)
            GUI.RegisterUIEvent(roleItem, UCE.PointerClick, "AudienceGambleUI", "OnRoleItemClick")
        end

        local line2 = GUI.ImageCreate(rightItemPage, "line2", "1800600140", -100, 0, false, 2, 100)
        SetSameAnchorAndPivot(line2, UILayout.BottomRight)

        local submitItem = GUI.ItemCtrlCreate(rightItemPage,"submitItem",QualityRes[1],-10,-10,80,80,false,"system",false)
        SetSameAnchorAndPivot(submitItem, UILayout.BottomRight)
        GUI.ItemCtrlSetElementRect(submitItem,eItemIconElement.Icon,0,-1,70,70)
        GUI.RegisterUIEvent(submitItem, UCE.PointerClick, "AudienceGambleUI", "OnSubmitItemClick")

        --加号添加图片
        local addImage = GUI.ImageCreate(submitItem,"addImage","1800707060",0,0,false,50,50)
        SetSameAnchorAndPivot(addImage, UILayout.Center)

        --金色选择框图片
        local SelectImage = GUI.ImageCreate(submitItem,"SelectImage","1800400280",0,0,false,75,75)
        GUI.SetVisible(SelectImage,false)
        SetSameAnchorAndPivot(SelectImage, UILayout.Center)

        --X删除图片
        local DeleteButton = GUI.ButtonCreate(submitItem,"DeleteButton","1800702100",0,0,Transition.ColorTint)
        GUI.RegisterUIEvent(DeleteButton, UCE.PointerClick, "AudienceGambleUI", "OnDeleteButtonClick")
        GUI.SetVisible(DeleteButton,false)
        SetSameAnchorAndPivot(DeleteButton, UILayout.TopRight)
    end


    AudienceGambleUI.GetTypeBagItemData()
end

function AudienceGambleUI.RefreshRightBagItemLoop()

    local refreshNum = 24
    if #bagTypeItemTable > refreshNum then
        refreshNum = math.ceil(#bagTypeItemTable / 6) * 6
    end

    local rightBagItemLoop = _gt.GetUI("rightBagItemLoop")
    GUI.LoopScrollRectSetTotalCount(rightBagItemLoop, refreshNum)
    GUI.LoopScrollRectRefreshCells(rightBagItemLoop)

end

function AudienceGambleUI.CreateAllGambleItem()
    local rightAllGambleLoop = _gt.GetUI("rightAllGambleLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(rightAllGambleLoop) + 1

    local itemGroup = GUI.GroupCreate(rightAllGambleLoop,"itemGroup"..index, 0, 0, 465, 180,false)
    SetSameAnchorAndPivot(itemGroup, UILayout.TopLeft)

    local groupBg = GUI.ImageCreate(itemGroup, "groupBg", "1800600140", 0, 0, false, 465, 180)
    SetSameAnchorAndPivot(groupBg, UILayout.TopLeft)


    local team1Bg = GUI.ImageCreate(groupBg, "team1Bg", "1801400070", 20, 10, false, 160, 50)
    SetSameAnchorAndPivot(team1Bg, UILayout.TopLeft)

    --队伍名字
    local teamTxt = GUI.CreateStatic(team1Bg,"teamTxt","六个字名字字" ,0,0,160, 35, "system", false, false)
    GUI.StaticSetFontSize(teamTxt,26)
    GUI.StaticSetAlignment(teamTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(teamTxt, UILayout.Center)
    GUI.SetColor(teamTxt,WhiteColor)

    local role1 = GUI.ItemCtrlCreate(groupBg,"role1",QualityRes[1],20,10,80,80,false,"system",false)
    SetSameAnchorAndPivot(role1, UILayout.Left)
    GUI.ItemCtrlSetElementRect(role1,eItemIconElement.Icon,0,-1,70,70)

    --角色名字
    local nameTxt = GUI.CreateStatic(role1,"nameTxt","六个字名字" ,35,32,140, 30, "system", false, false)
    GUI.StaticSetFontSize(nameTxt,22)
    GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)
    GUI.SetColor(nameTxt,Brown4Color)

    local role1Item = GUI.ItemCtrlCreate(groupBg,"role1Item",QualityRes[1],105,15,70,70,false,"system",false)
    SetSameAnchorAndPivot(role1Item, UILayout.Left)
    GUI.ItemCtrlSetElementRect(role1Item,eItemIconElement.Icon,0,-1,70,70)
    GUI.ItemCtrlSetElementRect(role1Item,eItemIconElement.LeftTopSp,5,5,30,30)
    GUI.ItemCtrlSetElementValue(role1Item,eItemIconElement.LeftTopSp,"1800707020")

    local centerImg = GUI.ImageCreate(groupBg, "centerImg", "1800707340", -15, 0, false,80,80,false)
    SetSameAnchorAndPivot(centerImg, UILayout.Center)


    local team2Bg = GUI.ImageCreate(groupBg, "team2Bg", "1801400080", -50, 10, false, 160, 50)
    SetSameAnchorAndPivot(team2Bg, UILayout.TopRight)

    --队伍名字
    local teamTxt = GUI.CreateStatic(team2Bg,"teamTxt","六个字名字" ,0,0,160, 35, "system", false, false)
    GUI.StaticSetFontSize(teamTxt,26)
    GUI.StaticSetAlignment(teamTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(teamTxt, UILayout.Center)
    GUI.SetColor(teamTxt,WhiteColor)

    local role2 = GUI.ItemCtrlCreate(groupBg,"role2",QualityRes[1],-50,10,80,80,false,"system",false)
    SetSameAnchorAndPivot(role2, UILayout.Right)
    GUI.ItemCtrlSetElementRect(role2,eItemIconElement.Icon,0,-1,70,70)

    --角色名字
    local nameTxt = GUI.CreateStatic(role2,"nameTxt","六个字名字" ,32,35,140, 30, "system", false, false)
    GUI.StaticSetFontSize(nameTxt,22)
    GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleRight)
    SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)
    GUI.SetColor(nameTxt,Brown4Color)

    local role2Item = GUI.ItemCtrlCreate(groupBg,"role2Item",QualityRes[1],-135,15,70,70,false,"system",false)
    SetSameAnchorAndPivot(role2Item, UILayout.Right)
    GUI.ItemCtrlSetElementRect(role2Item,eItemIconElement.Icon,0,-1,70,70)

    local tipsButton = GUI.ButtonCreate(groupBg,"tipsButton","1800702030",-10,10,Transition.ColorTint)
    GUI.RegisterUIEvent(tipsButton, UCE.PointerClick, "AudienceGambleUI", "OnTipsButtonClick")
    SetSameAnchorAndPivot(tipsButton, UILayout.TopRight)

    local redImg = GUI.ImageCreate(tipsButton, "redImg", "1800208080", -10, -10, false, 25, 25)
    SetSameAnchorAndPivot(redImg, UILayout.TopRight)

    return itemGroup
end

function AudienceGambleUI.RefreshAllGambleItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemGroup = GUI.GetByGuid(guid)

end

function AudienceGambleUI.CreateTeamListItem()
    local RoleTeamListLoop = _gt.GetUI("RoleTeamListLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(RoleTeamListLoop) + 1

    local itemGroup = GUI.GroupCreate(RoleTeamListLoop,"itemGroup"..index, 0, 0, 340, 140,false)
    SetSameAnchorAndPivot(itemGroup, UILayout.TopLeft)

    local groupBg = GUI.ImageCreate(itemGroup, "groupBg", "1800400410", 0, 0, false, 340, 140)
    SetSameAnchorAndPivot(groupBg, UILayout.TopLeft)

    local teamCheck1 = GUI.CheckBoxExCreate(groupBg,"teamCheck1" , "1800208210", "1800208211", 15, 15, false,40,40,false)
    SetSameAnchorAndPivot(teamCheck1, UILayout.TopLeft)
    GUI.RegisterUIEvent(teamCheck1, UCE.PointerClick, "AudienceGambleUI", "OnTeamCheckClick")

    local roleItem1 = GUI.ItemCtrlCreate(groupBg,"roleItem1",QualityRes[1],60,15,80,80,false,"system",false)
    SetSameAnchorAndPivot(roleItem1, UILayout.TopLeft)
    GUI.ItemCtrlSetElementRect(roleItem1,eItemIconElement.Icon,0,-1,70,70)
    GUI.RegisterUIEvent(roleItem1, UCE.PointerClick, "AudienceGambleUI", "OnRoleItemClick")

    --角色名字
    local nameTxt = GUI.CreateStatic(roleItem1,"nameTxt","六个字名字" ,0,30,140, 30, "system", false, false)
    GUI.StaticSetFontSize(nameTxt,20)
    GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)
    GUI.SetColor(nameTxt,Brown4Color)

    local fightImg = GUI.ImageCreate(groupBg, "fightImg", "1801502100", 0, 0, false,60,55,false)
    SetSameAnchorAndPivot(fightImg, UILayout.Center)


    local teamCheck2 = GUI.CheckBoxExCreate(groupBg,"teamCheck2" , "1800208210", "1800208211", -15, 15, false,40,40,false)
    SetSameAnchorAndPivot(teamCheck2, UILayout.TopRight)
    GUI.RegisterUIEvent(teamCheck2, UCE.PointerClick, "AudienceGambleUI", "OnTeamCheckClick")

    local roleItem2 = GUI.ItemCtrlCreate(groupBg,"roleItem2",QualityRes[1],-60,15,80,80,false,"system",false)
    SetSameAnchorAndPivot(roleItem2, UILayout.TopRight)
    GUI.ItemCtrlSetElementRect(roleItem2,eItemIconElement.Icon,0,-1,70,70)
    GUI.RegisterUIEvent(roleItem2, UCE.PointerClick, "AudienceGambleUI", "OnRoleItemClick")

    --角色名字
    local nameTxt = GUI.CreateStatic(roleItem2,"nameTxt","六个字名字" ,0,30,140, 30, "system", false, false)
    GUI.StaticSetFontSize(nameTxt,20)
    GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)
    GUI.SetColor(nameTxt,Brown4Color)

    return itemGroup
end

function AudienceGambleUI.RefreshTeamListItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemGroup = GUI.GetByGuid(guid)

end


function AudienceGambleUI.CreateRightBagItem()
    local rightBagItemLoop = _gt.GetUI("rightBagItemLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(rightBagItemLoop) + 1

    local item = GUI.ItemCtrlCreate(rightBagItemLoop,"RightBagItem"..index,QualityRes[1],0,0,50,50,false,"system",false)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,0,65,65)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "ApplyGambleUI", "OnRightBagItemClick")

    return item
end

function AudienceGambleUI.RefreshRightBagItem(parameter)
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


--获取背包数据
function AudienceGambleUI.GetTypeBagItemData()

    test("获取背包数据")

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


    test("sureSubmitBagItemTable",inspect(sureSubmitBagItemTable))

    local BagItemCount = LD.GetItemCount(bagTypeData,0)
    for i = 0, BagItemCount-1 do
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
    AudienceGambleUI.RefreshRightBagItemLoop()
end

function AudienceGambleUI.OnItemSubTabBtnClick()
    secondaryLabelIndex = 1
    AudienceGambleUI.GetTypeBagItemData()
end

function AudienceGambleUI.OnGemSubTabBtnClick()
    secondaryLabelIndex = 2
    AudienceGambleUI.GetTypeBagItemData()
end

function AudienceGambleUI.OnTokenSubTabBtnClick()
    secondaryLabelIndex = 3
    AudienceGambleUI.GetTypeBagItemData()
end

function AudienceGambleUI.OnTeamCheckClick()

end

function AudienceGambleUI.OnRoleItemClick()

end

function AudienceGambleUI.OnDeleteButtonClick()

end

function AudienceGambleUI.OnExit()
    GUI.CloseWnd("AudienceGambleUI")
end