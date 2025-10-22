local GambleUI = {}
_G.GambleUI = GambleUI

--孤注一掷活动界面

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
----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------

local selfState = 0

local leaderGUID = nil

local enemyGUID = nil

local teamStatus = nil

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

local allTeamData = {}

local allItemTeamGuid = {}

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

function GambleUI.Main(parameter)
    local panel = GUI.WndCreateWnd("GambleUI" , "GambleUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "孤 注 一 掷",960,620,"GambleUI","OnExit",_gt)

    local centerBg = GUI.ImageCreate(panelBg, "LeftBg", "1800400200", 0, 70, false, 860, 460)
    _gt.BindName(centerBg,"centerBg")
    SetSameAnchorAndPivot(centerBg, UILayout.Top)


    local seatBg = GUI.ImageCreate(centerBg, "seatBg", "1800800120", 1, 0, false, 573, 36)
    SetSameAnchorAndPivot(seatBg, UILayout.TopLeft)

    local txt = GUI.CreateStatic(seatBg, "txt", "阵容", 25, 0, 97, 30)
    SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local itemBg = GUI.ImageCreate(centerBg, "itemBg", "1800800140", -1, 0, false, 285, 36)
        SetSameAnchorAndPivot(itemBg, UILayout.TopRight)

    local txt = GUI.CreateStatic(itemBg, "txt", "物品", -20, 0, 97, 30)
   SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local GambleLoop =
    GUI.LoopScrollRectCreate(
            centerBg,
            "GambleLoop",
            10,
            40,
            840,
            410,
            "GambleUI",
            "CreateGambleItem",
            "GambleUI",
            "RefreshGambleItem",
            0,
            false,
            Vector2.New(840, 270),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(GambleLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(GambleLoop, TextAnchor.UpperLeft)
    _gt.BindName(GambleLoop, "GambleLoop")
    GUI.ScrollRectSetChildSpacing(GambleLoop, Vector2.New(0, 15))

    local pnSellout = GUI.ImageCreate(centerBg, "pnSellout", "1801100010", 0, 0, false, 360, 100)
    _gt.BindName(pnSellout, "pnSellout")
    SetSameAnchorAndPivot(pnSellout, UILayout.Center)
    GUI.SetVisible(pnSellout, false)

    local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "没有报名队伍信息", 0, 0, 260, 50, "system", true)
    SetSameAnchorAndPivot(txtSellout, UILayout.Center)
    GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtSellout, 30)
    GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
    GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleCenter)


    local refreshBtn = GUI.ButtonCreate(panelBg, "refreshBtn", "1800402090", -200, -20, Transition.ColorTint, "刷 新", 180, 55, false)
    _gt.BindName(refreshBtn,"refreshBtn")
    GUI.ButtonSetTextFontSize(refreshBtn, 30)
    GUI.SetIsOutLine(refreshBtn, true)
    GUI.ButtonSetTextColor(refreshBtn, WhiteColor)
    GUI.SetOutLine_Color(refreshBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(refreshBtn,OutLineDistance)
    SetSameAnchorAndPivot(refreshBtn, UILayout.Bottom)
    GUI.SetEventCD(refreshBtn,UCE.PointerClick, 1)
    GUI.RegisterUIEvent(refreshBtn, UCE.PointerClick, "GambleUI", "OnRefreshBtnClick")



    local applyBtn = GUI.ButtonCreate(panelBg, "applyBtn", "1800402080", 200, -20, Transition.ColorTint, "报 名", 180, 55, false)
    _gt.BindName(applyBtn,"applyBtn")
    GUI.ButtonSetTextFontSize(applyBtn, 30)
    GUI.SetIsOutLine(applyBtn, true)
    GUI.ButtonSetTextColor(applyBtn, WhiteColor)
    GUI.SetOutLine_Color(applyBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(applyBtn,OutLineDistance)
    SetSameAnchorAndPivot(applyBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(applyBtn, UCE.PointerClick, "GambleUI", "OnSubmitApplyBtnClick")
end

function GambleUI.OnShow(parameter)
    local wnd = GUI.GetWnd("GambleUI");
    if wnd == nil then
        return
    end
    GambleUI.Init()
    GUI.SetVisible(wnd, true)

end

function GambleUI.Init()

    allTeamData = {}

    selfState = 0


    leaderGUID = nil

    enemyGUID = nil

    teamStatus = nil

end

function GambleUI.RefreshAllData()

    leaderGUID = tostring(GambleUI.TeamLeaderGUID)

    enemyGUID = tostring(GambleUI.EnemyTeamGUID)

    test("leaderGUID",inspect(leaderGUID))

    selfState = tonumber(GambleUI.PlayerState)
    test("selfState",tostring(selfState))


    local temporaryTeamDta = GambleUI.AllTeamData
    allTeamData = {}

    test("temporaryTeamDta",inspect(temporaryTeamDta))

    for i, v in pairs(temporaryTeamDta) do
        if selfState == 0 then

            if v.TeamState == 1 then
                table.insert(allTeamData,v)
            end

        elseif selfState == 1 then

            if v.TeamState == 1 then

                if i == leaderGUID then

                    table.insert(allTeamData,1,v)
                    teamStatus = v.TeamState

                end

            else
                if i == leaderGUID then
                    table.insert(allTeamData,1,v)
                    teamStatus = v.TeamState
                end

                if i == enemyGUID then
                    table.insert(allTeamData,v)
                    teamStatus = v.TeamState
                end

            end

        elseif selfState == 2 then

            if i == leaderGUID then
                table.insert(allTeamData,1,v)
                teamStatus = v.TeamState
            end
            if i == enemyGUID then
                table.insert(allTeamData,v)
                teamStatus = v.TeamState
            end

        end
    end

    test("selfState",tostring(selfState))

    test("allTeamData",inspect(allTeamData))

    GambleUI.RefreshGambleLoopData()

    GambleUI.SetApplyBtnStatus()
end

function GambleUI.RefreshGambleLoopData()
    test("allTeamData",inspect(allTeamData))

    local GambleLoop = _gt.GetUI("GambleLoop")
    local pnSellout = _gt.GetUI("pnSellout")



    if #allTeamData > 0 then

        GUI.SetVisible(GambleLoop,true)
        GUI.SetVisible(pnSellout,false)

    else

        GUI.SetVisible(pnSellout,true)
        GUI.SetVisible(GambleLoop,false)

    end


    GUI.LoopScrollRectSetTotalCount(GambleLoop, #allTeamData)
    GUI.LoopScrollRectRefreshCells(GambleLoop)
end

function GambleUI.SetApplyBtnStatus()
    local applyBtn = _gt.GetUI("applyBtn")

    if selfState ~= 0 then
        GUI.ButtonSetText(applyBtn,"取 消")

        if selfState == 1 then

            for i, v in pairs(allTeamData) do

                    if v.TeamLeaderGUID == leaderGUID then

                        if v.TeamState == 2 then

                            GUI.ButtonSetShowDisable(applyBtn,false)
                        else

                            GUI.ButtonSetShowDisable(applyBtn,true)

                        end

                    end

                end

        end

    else

        GUI.ButtonSetText(applyBtn,"报 名")
        GUI.ButtonSetShowDisable(applyBtn,true)


    end
end

function GambleUI.CreateGambleItem()
    local GambleLoop = _gt.GetUI("GambleLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(GambleLoop) + 1

    local itemGroup = GUI.GroupCreate(GambleLoop,"itemGroup"..index, 0, 0, 840, 270,false)

    local groupBg = GUI.ImageCreate(itemGroup, "groupBg", "1800001150", 0, 0, false, 840, 270)
    SetSameAnchorAndPivot(groupBg, UILayout.TopLeft)




    --local teamNameBg = GUI.ImageCreate(groupBg, "teamNameBg", "1800600190", -140, -10, false, 180, 42)
    --SetSameAnchorAndPivot(teamNameBg, UILayout.Top)

    ----提示信息
    --local teamInfoTxt = GUI.CreateStatic(teamNameBg,"teamInfoTxt","阵容" ,0,3,160, 40, "system", false, false)
    --GUI.StaticSetFontSize(teamInfoTxt,22)
    --GUI.StaticSetAlignment(teamInfoTxt,TextAnchor.MiddleCenter)
    --SetSameAnchorAndPivot(teamInfoTxt, UILayout.Center)
    --GUI.SetColor(teamInfoTxt,Brown4Color)

    for i = 1, 5 do
        local roleItem = GUI.ItemCtrlCreate(groupBg,"roleItem"..i,QualityRes[1],(i - 1) * 110 + 20,20,80,80,false,"system",false)
        GUI.ItemCtrlSetElementRect(roleItem,eItemIconElement.Icon,0,-1,70,70)
        GUI.RegisterUIEvent(roleItem, UCE.PointerClick, "GambleUI", "OnRoleItemClick")

        --角色名字
        local nameTxt = GUI.CreateStatic(roleItem,"nameTxt","六个字名字" ,0,30,140, 30, "system", false, false)
        GUI.StaticSetFontSize(nameTxt,20)
        GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleCenter)
        SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)
        GUI.SetColor(nameTxt,Brown4Color)
    end

    for i = 1, 5 do
        local petItem = GUI.ItemCtrlCreate(groupBg,"petItem"..i,QualityRes[1],(i - 1) * 110 + 20,140,80,80,false,"system",false)
        GUI.ItemCtrlSetElementRect(petItem,eItemIconElement.Icon,0,-1,70,70)
        GUI.RegisterUIEvent(petItem, UCE.PointerClick, "GambleUI", "OnPetItemClick")

        --宠物名字
        local nameTxt = GUI.CreateStatic(petItem,"nameTxt","六个字名字" ,0,30,140, 30, "system", false, false)
        GUI.StaticSetFontSize(nameTxt,20)
        GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleCenter)
        SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)
        GUI.SetColor(nameTxt,Brown4Color)
    end

    local cutLine = GUI.ImageCreate(groupBg, "cutLine", "1800300040", -275, 0, false, 2, 270)
    SetSameAnchorAndPivot(cutLine, UILayout.TopRight)

    --local itemNameBg = GUI.ImageCreate(groupBg, "itemNameBg", "1800600190", -60, -10, false, 160, 42)
    --SetSameAnchorAndPivot(itemNameBg, UILayout.TopRight)

    ----提示信息
    --local itemInfoTxt = GUI.CreateStatic(itemNameBg,"itemInfoTxt","物 品" ,0,3,160, 40, "system", false, false)
    --_gt.BindName(itemInfoTxt,"itemInfoTxt")
    --GUI.StaticSetFontSize(itemInfoTxt,22)
    --GUI.SetColor(itemInfoTxt,Brown4Color)
    --GUI.StaticSetAlignment(itemInfoTxt,TextAnchor.MiddleCenter)
    --SetSameAnchorAndPivot(itemInfoTxt, UILayout.Center)

    local rightBg = GUI.ImageCreate(groupBg, "rightBg", "1800400200", -10, 20, false, 260, 180)
    SetSameAnchorAndPivot(rightBg, UILayout.TopRight)

    local GambleItemLoop =
    GUI.LoopScrollRectCreate(
            rightBg,
            "GambleItemLoop",
            -5,
            5,
            270,
            170,
            "GambleUI",
            "CreateGambleRoleItem",
            "GambleUI",
            "RefreshGambleRoleItem",
            0,
            false,
            Vector2.New(60, 60),
            4,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(GambleItemLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(GambleItemLoop, TextAnchor.UpperLeft)
    GUI.ScrollRectSetChildSpacing(GambleItemLoop, Vector2.New(3, 3))


    local applyBtn = GUI.ButtonCreate(rightBg, "applyBtn", "1800402080", 0, 55, Transition.ColorTint, "接 受", 120, 45, false)
    GUI.SetVisible(applyBtn,false)
    GUI.ButtonSetTextFontSize(applyBtn, 30)
    GUI.SetIsOutLine(applyBtn, true)
    GUI.ButtonSetTextColor(applyBtn, WhiteColor)
    GUI.SetOutLine_Color(applyBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(applyBtn,OutLineDistance)
    SetSameAnchorAndPivot(applyBtn, UILayout.BottomLeft)
    GUI.RegisterUIEvent(applyBtn, UCE.PointerClick, "GambleUI", "OnApplyBtnClick")

    local refuseBtn = GUI.ButtonCreate(rightBg, "refuseBtn", "1800402080", 0, 55, Transition.ColorTint, "拒 绝", 120, 45, false)
    GUI.SetVisible(refuseBtn,false)
    GUI.ButtonSetTextFontSize(refuseBtn, 30)
    GUI.SetIsOutLine(refuseBtn, true)
    GUI.ButtonSetTextColor(refuseBtn, WhiteColor)
    GUI.SetOutLine_Color(refuseBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(refuseBtn,OutLineDistance)
    SetSameAnchorAndPivot(refuseBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(refuseBtn, UCE.PointerClick, "GambleUI", "OnRefuseBtnClick")

    local lockImg = GUI.ImageCreate(rightBg, "lockImg", "1800404110", 0, 58, false, 150, 50)
    GUI.SetVisible(lockImg,false)
    SetSameAnchorAndPivot(lockImg, UILayout.Bottom)


    local challengeBtn = GUI.ButtonCreate(rightBg, "challengeBtn", "1800402090", 0, 58, Transition.ColorTint, "挑 战", 150, 50, false)
    GUI.SetVisible(challengeBtn,false)
    GUI.ButtonSetTextFontSize(challengeBtn, 32)
    GUI.SetIsOutLine(challengeBtn, true)
    GUI.ButtonSetTextColor(challengeBtn, WhiteColor)
    GUI.SetOutLine_Color(challengeBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(challengeBtn,OutLineDistance)
    SetSameAnchorAndPivot(challengeBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(challengeBtn, UCE.PointerClick, "GambleUI", "OnChallengeBtnClick")

    return itemGroup
end

function GambleUI.RefreshGambleItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    if allTeamData[index] == nil then
        return
    end

    if allTeamData[index].MemberData == nil then
        return
    end

    local seatId = allTeamData[index].SeatId

    local teamData = allTeamData[index].MemberData
    test("allTeamData",inspect(allTeamData))
    local teamLeaderGUID = allTeamData[index].TeamLeaderGUID
    local teamState = allTeamData[index].TeamState

    local groupBg = GUI.GetChild(item,"groupBg",false)

    if teamData then

        --local teamNameBg = GUI.GetChild(groupBg,"teamNameBg",false)
        --local teamInfoTxt = GUI.GetChild(teamNameBg,"teamInfoTxt",false)
        --local seat = DB.GetOnceSeatByKey1(seatId)
        --GUI.StaticSetText(teamInfoTxt,seat.Name)


        for i = 1, 5 do
            local roleItem = GUI.GetChild(groupBg,"roleItem"..i,false)
            local nameTxt = GUI.GetChild(roleItem,"nameTxt",false)
            local roleData = teamData.Member[i]
            if roleData ~= nil then
                if roleData.Type == 0 then
                    local roleDB = DB.GetRole(roleData.Role_Id)
                    GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.Icon,tostring(roleDB.Head))
                    GUI.StaticSetText(nameTxt,roleData.Name)

                    GUI.SetData(roleItem,"roleName",roleData.Name)
                else
                    local guardDB = DB.GetOnceGuardByKey2(roleData.KeyName)
                    GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.Icon,tostring(guardDB.Head))
                    GUI.StaticSetText(nameTxt,guardDB.Name)

                    GUI.SetData(roleItem,"guardGuid",roleData.GUID)
                    GUI.SetData(roleItem,"ownerName",roleData.OwnerName)
                end


                GUI.SetData(roleItem,"type",roleData.Type)

                GUI.RegisterUIEvent(roleItem, UCE.PointerClick, "GambleUI", "OnRoleItemClick")
            else
                GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.Icon,"")
                GUI.StaticSetText(nameTxt,"")
                GUI.UnRegisterUIEvent(roleItem, UCE.PointerClick, "GambleUI", "OnRoleItemClick")
            end

        end


        for i = 1, 5 do
            local petItem = GUI.GetChild(groupBg,"petItem"..i,false)
            local nameTxt = GUI.GetChild(petItem,"nameTxt",false)
            local petData = teamData.Pet[i]

            if petData ~= nil then
                if petData.GUID ~= nil then
                    local petDB = DB.GetOncePetByKey1(petData.Id)
                    GUI.ItemCtrlSetElementValue(petItem,eItemIconElement.Icon,tostring(petDB.Head))
                    GUI.StaticSetText(nameTxt,petData.Name)
                    GUI.SetData(petItem,"petGuid",petData.GUID)
                    GUI.SetData(petItem,"petOwnerName",petData.OwnerName)
                    GUI.RegisterUIEvent(petItem, UCE.PointerClick, "GambleUI", "OnPetItemClick")
                else
                    GUI.ItemCtrlSetElementValue(petItem,eItemIconElement.Icon,"")
                    GUI.StaticSetText(nameTxt,"")
                    GUI.UnRegisterUIEvent(petItem, UCE.PointerClick, "GambleUI", "OnPetItemClick")
                end

            else
                GUI.ItemCtrlSetElementValue(petItem,eItemIconElement.Icon,"")
                GUI.StaticSetText(nameTxt,"")
                GUI.UnRegisterUIEvent(petItem, UCE.PointerClick, "GambleUI", "OnPetItemClick")
            end

        end
    end


    local rightBg = GUI.GetChild(groupBg,"rightBg",false)
    local GambleItemLoop = GUI.GetChild(rightBg,"GambleItemLoop",false)

    local applyBtn = GUI.GetChild(rightBg,"applyBtn",false)
    local refuseBtn = GUI.GetChild(rightBg,"refuseBtn",false)
    local challengeBtn = GUI.GetChild(rightBg,"challengeBtn",false)
    local lockImg = GUI.GetChild(rightBg,"lockImg",false)





    if selfState == 0 then
        GUI.SetHeight(rightBg,180)
        GUI.SetHeight(GambleItemLoop,170)
        GUI.SetVisible(applyBtn,false)
        GUI.SetVisible(refuseBtn,false)
        GUI.SetVisible(challengeBtn,true)

        GUI.SetVisible(lockImg,false)

        GUI.SetData(challengeBtn,"challengeTeamGuid",teamLeaderGUID)

    elseif selfState == 1 then

        if leaderGUID == teamLeaderGUID then

            if teamState == 1 then
                GUI.SetVisible(lockImg,false)
                GUI.SetHeight(rightBg,200)
                GUI.SetHeight(GambleItemLoop,190)
                GUI.SetVisible(applyBtn,false)
                GUI.SetVisible(refuseBtn,false)
                GUI.SetVisible(challengeBtn,false)
            else
                GUI.SetVisible(lockImg,true)
                GUI.SetHeight(rightBg,180)
                GUI.SetHeight(GambleItemLoop,170)
                GUI.SetVisible(applyBtn,false)
                GUI.SetVisible(refuseBtn,false)
                GUI.SetVisible(challengeBtn,false)
            end


        else
            if teamState == 3 then
                GUI.SetHeight(rightBg,180)
                GUI.SetHeight(GambleItemLoop,170)
                GUI.SetVisible(applyBtn,true)
                GUI.ButtonSetShowDisable(applyBtn,false)
                GUI.SetVisible(refuseBtn,true)
                GUI.SetVisible(challengeBtn,false)
                GUI.SetVisible(lockImg,false)
            else
                GUI.SetHeight(rightBg,180)
                GUI.SetHeight(GambleItemLoop,170)
                GUI.SetVisible(applyBtn,true)
                GUI.ButtonSetShowDisable(applyBtn,true)
                GUI.SetVisible(refuseBtn,true)
                GUI.SetVisible(challengeBtn,false)
                GUI.SetVisible(lockImg,false)
            end
        end

    elseif selfState == 2 then

        if leaderGUID == teamLeaderGUID then

            GUI.SetVisible(lockImg,true)
            GUI.SetHeight(rightBg,180)
            GUI.SetHeight(GambleItemLoop,170)
            GUI.SetVisible(applyBtn,false)
            GUI.SetVisible(refuseBtn,false)
            GUI.SetVisible(challengeBtn,false)

        else
            GUI.SetHeight(rightBg,180)
            GUI.SetHeight(GambleItemLoop,170)
            if teamState == 3 then
                GUI.SetVisible(applyBtn,true)
                GUI.ButtonSetShowDisable(applyBtn,false)
                GUI.SetVisible(refuseBtn,true)
                GUI.SetVisible(challengeBtn,false)
                GUI.SetVisible(lockImg,false)
            else
                GUI.SetVisible(lockImg,true)
                GUI.SetVisible(applyBtn,false)
                GUI.SetVisible(refuseBtn,false)
                GUI.SetVisible(challengeBtn,false)
            end
        end

    end


    local itemData = allTeamData[index].TeamItemList
    if itemData then
        local refreshNum = 12
        if #itemData > refreshNum then
            refreshNum = math.ceil(#itemData / 4) * 4
        end

        GUI.SetData(GambleItemLoop,"index",index)



        GUI.LoopScrollRectSetTotalCount(GambleItemLoop, refreshNum)
        GUI.LoopScrollRectRefreshCells(GambleItemLoop)
    end

end

function GambleUI.CreateGambleRoleItem(guid)
    local GambleItemLoop = GUI.GetByGuid(tostring(guid))
    local index = GUI.LoopScrollRectGetChildInPoolCount(GambleItemLoop) + 1

    local item = GUI.ItemCtrlCreate(GambleItemLoop,"ShoppingItem"..index,QualityRes[1],0,0,50,50,false,"system",false)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,45,45)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "GambleUI", "OnRightItemClick")

    local itemGuid = tostring(GUI.GetGuid(item))

    allItemTeamGuid[itemGuid] = tostring(guid)


    return item
end

function GambleUI.RefreshGambleRoleItem(parameter)

    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)


    local parentGuid = allItemTeamGuid[tostring(guid)]

    local parent = GUI.GetByGuid(parentGuid)

    local parentIndex = tonumber(GUI.GetData(parent,"index"))


    if allTeamData[parentIndex] == nil then

        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.UnRegisterUIEvent(item, UCE.PointerClick, "GambleUI", "OnRightItemClick")

    end

    if allTeamData[parentIndex].TeamItemList == nil then

        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.UnRegisterUIEvent(item, UCE.PointerClick, "GambleUI", "OnRightItemClick")
    end

    local data = allTeamData[parentIndex].TeamItemList[index]


    if data then
        local itemDB = DB.GetOnceItemByKey2(data[1])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,tostring(itemDB.Icon))
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,data[2])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[tonumber(itemDB.Grade)])
        GUI.RegisterUIEvent(item, UCE.PointerClick, "GambleUI", "OnRightItemClick")
        GUI.SetData(item,"itemId",itemDB.Id)
    else
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,"")
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.UnRegisterUIEvent(item, UCE.PointerClick, "GambleUI", "OnRightItemClick")
    end
end

--报名按钮点击事件
function GambleUI.OnSubmitApplyBtnClick(guid)
    test("报名按钮点击事件")
    if selfState == 0 then
        CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","SignUp")
    else
        CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","CancelRegistration")
    end

end

function GambleUI.OnRoleItemClick(guid)
    local roleItem = GUI.GetByGuid(guid)

    local type = tonumber(GUI.GetData(roleItem,"type"))


    if type == 0 then
        local roleName = GUI.GetData(roleItem,"roleName")
        if CL.GetRoleName() == roleName then
            CL.SendNotify(NOTIFY.ShowBBMsg,"无法查看自己的信息")
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "QueryOfflinePlayerByName", roleName)
        end
    else
        local guardGuid = GUI.GetData(roleItem,"guardGuid")
        local ownerName = GUI.GetData(roleItem,"ownerName")
        CL.SendNotify(NOTIFY.SubmitForm,"FormGuardInfo","get_offline_guard_data",ownerName,guardGuid)
    end

end

function GambleUI.OnPetItemClick(guid)
    local petItem = GUI.GetByGuid(guid)
    local petGuid = GUI.GetData(petItem,"petGuid")
    local petOwnerName = GUI.GetData(petItem,"petOwnerName")

    test(petGuid,petOwnerName)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "query_offline_pet_by_player_name",petOwnerName, petGuid)
end

function GambleUI.OnRightItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local itemId= tonumber(GUI.GetData(item,"itemId"))
    local centerBg = _gt.GetUI("centerBg")
    local tip = Tips.CreateByItemId(tonumber(itemId), centerBg, "rightItemTips",-50,0)
    SetSameAnchorAndPivot(tip, UILayout.Center)
    GUI.SetData(tip, "ItemId", itemId)
end

function GambleUI.OnChallengeBtnClick(guid)

    local challengeBtn = GUI.GetByGuid(guid)
    local challengeTeamGuid = GUI.GetData(challengeBtn,"challengeTeamGuid")


    CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","ChallengeApply",challengeTeamGuid)

end

function GambleUI.OnRefreshBtnClick()



    if selfState ~= 0 then

        if selfState == 1 then

            for i, v in pairs(allTeamData) do

                if v.TeamLeaderGUID == leaderGUID then

                    if v.TeamState == 2 then

                        CL.SendNotify(NOTIFY.ShowBBMsg,"您已被挑战，刷新失败")

                    else

                        CL.SendNotify(NOTIFY.ShowBBMsg,"您已报名，刷新失败")

                    end

                end

            end

        end

    else

        CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","RefreshTeamData")

    end


end



function GambleUI.OnApplyBtnClick()

    CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","AcceptFight")

end

function GambleUI.OnRefuseBtnClick(guid)

    CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","RejectFight")

end


function GambleUI.OnExit()
    GUI.CloseWnd("GambleUI")
end