local GambleTeamInfoUI = {}
_G.GambleTeamInfoUI = GambleTeamInfoUI

local _gt = UILayout.NewGUIDUtilTable()

--孤注一掷活动查看队伍信息界面

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

local formationId = nil

local stateType = nil

----------------------------------------------End 全局变量 End-----------------------------------


------------------------------------------Start 表配置 Start----------------------------------

local teamData = {}

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

function GambleTeamInfoUI.Main(parameter)

    local wnd = GUI.WndCreateWnd("GambleTeamInfoUI", "GambleTeamInfoUI", 0, 0, eCanvasGroup.Normal)
    SetSameAnchorAndPivot(wnd, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(wnd, "查看队伍信息",640,460,"GambleTeamInfoUI","OnExit",_gt)
    _gt.BindName(panelBg,"panelBg")

    local teamNameBg = GUI.ImageCreate(panelBg, "teamNameBg", "1800100060", 0, 60, false, 160, 50)
    SetSameAnchorAndPivot(teamNameBg, UILayout.Top)

    --提示信息
    local teamInfoTxt = GUI.CreateStatic(teamNameBg,"teamInfoTxt","" ,0,0,160, 40, "system", false, false)
    _gt.BindName(teamInfoTxt,"teamInfoTxt")
    GUI.StaticSetFontSize(teamInfoTxt,25)
    GUI.StaticSetAlignment(teamInfoTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(teamInfoTxt, UILayout.Center)

    for i = 1, 5 do
        local roleItem = GUI.ItemCtrlCreate(panelBg,"roleItem"..i,QualityRes[1],(i - 1) * 115 + 50,-70,80,80,false,"system",false)
        SetSameAnchorAndPivot(roleItem, UILayout.Left)
        GUI.ItemCtrlSetElementRect(roleItem,eItemIconElement.Icon,0,-1,70,70)
        GUI.RegisterUIEvent(roleItem, UCE.PointerClick, "GambleTeamInfoUI", "OnRoleItemClick")

        --角色名字
        local nameTxt = GUI.CreateStatic(roleItem,"nameTxt","六个字名字" ,0,30,140, 30, "system", false, false)
        GUI.StaticSetFontSize(nameTxt,20)
        GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleCenter)
        SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)
        GUI.SetColor(nameTxt,Brown4Color)
    end

    for i = 1, 5 do
        local petItem = GUI.ItemCtrlCreate(panelBg,"petItem"..i,QualityRes[1],(i - 1) * 115 + 50,50,80,80,false,"system",false)
        SetSameAnchorAndPivot(petItem, UILayout.Left)
        GUI.ItemCtrlSetElementRect(petItem,eItemIconElement.Icon,0,-1,70,70)
        GUI.RegisterUIEvent(petItem, UCE.PointerClick, "GambleTeamInfoUI", "OnPetItemClick")

        --宠物名字
        local nameTxt = GUI.CreateStatic(petItem,"nameTxt","六个字名字" ,0,30,140, 30, "system", false, false)
        GUI.StaticSetFontSize(nameTxt,20)
        GUI.StaticSetAlignment(nameTxt,TextAnchor.MiddleCenter)
        SetSameAnchorAndPivot(nameTxt, UILayout.Bottom)
        GUI.SetColor(nameTxt,Brown4Color)
    end

    local line = GUI.ImageCreate(panelBg, "groupBg", "1800600140", 0, -90, false, 640, 2)
    SetSameAnchorAndPivot(line, UILayout.Bottom)

    local affirmBtn = GUI.ButtonCreate(panelBg, "affirmBtn", "1800402080", 0, -20, Transition.ColorTint, "确 认", 150, 55, false)
    GUI.SetVisible(affirmBtn,false)
    GUI.ButtonSetTextFontSize(affirmBtn, 31)
    GUI.SetIsOutLine(affirmBtn, true)
    GUI.ButtonSetTextColor(affirmBtn, WhiteColor)
    GUI.SetOutLine_Color(affirmBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(affirmBtn,OutLineDistance)
    SetSameAnchorAndPivot(affirmBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(affirmBtn, UCE.PointerClick, "GambleTeamInfoUI", "OnAffirmBtnClick")

    local applyBtn = GUI.ButtonCreate(panelBg, "applyBtn", "1800402090", 120, -20, Transition.ColorTint, "接 受", 150, 50, false)
    GUI.ButtonSetTextFontSize(applyBtn, 32)
    GUI.SetIsOutLine(applyBtn, true)
    GUI.ButtonSetTextColor(applyBtn, WhiteColor)
    GUI.SetOutLine_Color(applyBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(applyBtn,OutLineDistance)
    SetSameAnchorAndPivot(applyBtn, UILayout.BottomLeft)
    GUI.RegisterUIEvent(applyBtn, UCE.PointerClick, "GambleTeamInfoUI", "OnApplyBtnClick")

    local refuseBtn = GUI.ButtonCreate(panelBg, "refuseBtn", "1800402080", -120, -20, Transition.ColorTint, "拒 绝", 150, 50, false)
    GUI.ButtonSetTextFontSize(refuseBtn, 32)
    GUI.SetIsOutLine(refuseBtn, true)
    GUI.ButtonSetTextColor(refuseBtn, WhiteColor)
    GUI.SetOutLine_Color(refuseBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(refuseBtn,OutLineDistance)
    SetSameAnchorAndPivot(refuseBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(refuseBtn, UCE.PointerClick, "GambleTeamInfoUI", "OnRefuseBtnClick")

end

function GambleTeamInfoUI.OnShow(parameter)
    local wnd = GUI.GetWnd("GambleTeamInfoUI");
    if wnd == nil then
        return
    end
    GambleTeamInfoUI.Init()
    GUI.SetVisible(wnd, true)

end

function GambleTeamInfoUI.Init()

    formationId = nil

    teamData = {}

    stateType = nil

end

function GambleTeamInfoUI.RefreshAllData()

    --阵法id
    formationId = GambleTeamInfoUI.SeatId

    --阵容信息
    teamData = GambleTeamInfoUI.TeamData

    --队伍状态类型
    stateType = GambleTeamInfoUI.Type

    test("formationId",tostring(formationId))
    test("teamData",inspect(teamData))

    GambleTeamInfoUI.RefreshTeamInfoTxtData()

    GambleTeamInfoUI.RefreshTeamData()

    GambleTeamInfoUI.RefreshBtnStatus()
end

--设置按钮状态
function GambleTeamInfoUI.RefreshBtnStatus()

    local panelBg = _gt.GetUI("panelBg")
    local affirmBtn = GUI.GetChild(panelBg,"affirmBtn",false)
    local applyBtn = GUI.GetChild(panelBg,"applyBtn",false)
    local refuseBtn = GUI.GetChild(panelBg,"refuseBtn",false)

    if stateType == 0 then

        GUI.SetVisible(affirmBtn,true)
        GUI.SetVisible(applyBtn,false)
        GUI.SetVisible(refuseBtn,false)

    elseif stateType == 1 then

        GUI.SetVisible(affirmBtn,false)
        GUI.SetVisible(applyBtn,true)
        GUI.SetVisible(refuseBtn,true)

    else
        GUI.SetVisible(affirmBtn,false)
        GUI.SetVisible(applyBtn,false)
        GUI.SetVisible(refuseBtn,false)
    end


end

--刷新阵法名字
function GambleTeamInfoUI.RefreshTeamInfoTxtData()
    local seat = DB.GetOnceSeatByKey1(formationId)

    local teamInfoTxt = _gt.GetUI("teamInfoTxt")
    GUI.StaticSetText(teamInfoTxt,seat.Name)
    GUI.SetColor(teamInfoTxt,teamColorTable[seat.Name])
end

--刷新队伍信息
function GambleTeamInfoUI.RefreshTeamData()

    local panelBg = _gt.GetUI("panelBg")
    for i = 1, 5 do
        local roleItem = GUI.GetChild(panelBg,"roleItem"..i,false)
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

            GUI.RegisterUIEvent(roleItem, UCE.PointerClick, "GambleTeamInfoUI", "OnRoleItemClick")
        else
            GUI.ItemCtrlSetElementValue(roleItem,eItemIconElement.Icon,"")
            GUI.StaticSetText(nameTxt,"")
            GUI.UnRegisterUIEvent(roleItem, UCE.PointerClick, "GambleTeamInfoUI", "OnRoleItemClick")
        end
    end

    for i = 1, 5 do
        local petItem = GUI.GetChild(panelBg,"petItem"..i,false)
        local nameTxt = GUI.GetChild(petItem,"nameTxt",false)
        local petData = teamData.Pet[i]

        if petData ~= nil then
            if petData.GUID ~= nil then
                local petDB = DB.GetOncePetByKey1(petData.Id)
                GUI.ItemCtrlSetElementValue(petItem,eItemIconElement.Icon,tostring(petDB.Head))
                GUI.StaticSetText(nameTxt,petData.Name)
                GUI.SetData(petItem,"petGuid",petData.GUID)
                GUI.SetData(petItem,"petOwnerName",petData.OwnerName)
                GUI.RegisterUIEvent(petItem, UCE.PointerClick, "GambleTeamInfoUI", "OnPetItemClick")
            else
                GUI.ItemCtrlSetElementValue(petItem,eItemIconElement.Icon,"")
                GUI.StaticSetText(nameTxt,"")
                GUI.UnRegisterUIEvent(petItem, UCE.PointerClick, "GambleTeamInfoUI", "OnPetItemClick")
            end

        else
            GUI.ItemCtrlSetElementValue(petItem,eItemIconElement.Icon,"")
            GUI.StaticSetText(nameTxt,"")
            GUI.UnRegisterUIEvent(petItem, UCE.PointerClick, "GambleTeamInfoUI", "OnPetItemClick")
        end

    end


end

function GambleTeamInfoUI.OnRoleItemClick(guid)
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

function GambleTeamInfoUI.OnPetItemClick(guid)
    local petItem = GUI.GetByGuid(guid)
    local petGuid = GUI.GetData(petItem,"petGuid")
    local petOwnerName = GUI.GetData(petItem,"petOwnerName")

    test(petGuid,petOwnerName)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "query_offline_pet_by_player_name",petOwnerName, petGuid)
end


function GambleTeamInfoUI.OnApplyBtnClick()

    CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","FinalAccept")


end

function GambleTeamInfoUI.OnRefuseBtnClick()

    CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","FinalReject")

end

function GambleTeamInfoUI.OnAffirmBtnClick()

    GambleTeamInfoUI.OnExit()

end

function GambleTeamInfoUI.OnExit()
    GUI.CloseWnd("GambleTeamInfoUI")
end