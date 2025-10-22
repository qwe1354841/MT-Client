local AddPointUI = {}
_G.AddPointUI = AddPointUI

local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local pointAttr = {
    { BaseName = "力量", BaseAttr = RoleAttr.RoleAttrStr, AddPointAttr = RoleAttr.RoleAttrStrPoint, BaseValue = 0, AddValue = 0, OtherValue = 0, },
    { BaseName = "法力", BaseAttr = RoleAttr.RoleAttrInt, AddPointAttr = RoleAttr.RoleAttrIntPoint, BaseValue = 0, AddValue = 0, OtherValue = 0, },
    { BaseName = "体质", BaseAttr = RoleAttr.RoleAttrVit, AddPointAttr = RoleAttr.RoleAttrVitPoint, BaseValue = 0, AddValue = 0, OtherValue = 0, },
    { BaseName = "耐力", BaseAttr = RoleAttr.RoleAttrEnd, AddPointAttr = RoleAttr.RoleAttrAgiPoint, BaseValue = 0, AddValue = 0, OtherValue = 0, },
    { BaseName = "敏捷", BaseAttr = RoleAttr.RoleAttrAgi, AddPointAttr = RoleAttr.RoleAttrAgiPoint, BaseValue = 0, AddValue = 0, OtherValue = 0, },
}

local showAttr = {
    { RoleAttr.RoleAttrHpLimit, "气血" , RoleAttr.PetAttrHpTalent},
    { RoleAttr.RoleAttrMpLimit, "魔法", RoleAttr.PetAttrMpTalent },
    { RoleAttr.RoleAttrPhyAtk, "物攻", RoleAttr.PetAttrPhyAtkTalent },
    { RoleAttr.RoleAttrMagAtk, "法攻", RoleAttr.PetAttrMagAtkTalent },
    { RoleAttr.RoleAttrPhyDef, "物防", RoleAttr.PetAttrPhyDefTalent },
    { RoleAttr.RoleAttrMagDef, "法防", RoleAttr.PetAttrMagDefTalent },
    { RoleAttr.RoleAttrFightSpeed, "速度", RoleAttr.PetAttrSpeedTalent },
}

-- 缓存种族对应的属性
local race2Attr = {}

local AddPointType = {
    PET = 1,
    GUARD = 2,
    PLAYER = 3,
}
local AutoPanelState = false
local AutoPointBtnGuid = {}
local MaxAutoPointCount = 5
local RemainAutoPointCount = 0
local AutoLastPoint = {} -- 上次修改后的分配方式
local AutoPointTable = {} -- 当前自动加点分配方式
local IsAutoPoint = false
local IsFirstEnter = true

function AddPointUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable();
    AddPointUI.RestData()
    AddPointUI.InitData()

    local wnd = GUI.WndCreateWnd("AddPointUI", "AddPointUI", 0, 0);

    local panelCover = GUI.ImageCreate(wnd, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)

    AddPointUI.CreateAutoAddPointPanel(wnd)
    local panelBg = UILayout.CreateFrame_WndStyle2_WithoutCover(wnd, "加点分配", 540, 465, "AddPointUI", "OnExit", _gt)
    local left = 45;
    local top = 155;
    local spacing = 50

    local remainPoint = GUI.CreateStatic(panelBg, "remainPoint", "可分配点数", 80, 75, 150, 30);
    GUI.SetColor(remainPoint, UIDefine.BrownColor);
    GUI.StaticSetFontSize(remainPoint, UIDefine.FontSizeL);
    GUI.StaticSetAlignment(remainPoint, TextAnchor.MiddleLeft);
    UILayout.SetSameAnchorAndPivot(remainPoint, UILayout.TopLeft);

    local bg = GUI.ImageCreate(remainPoint, "bg", "1800700010", 130, 1, false, 100, 35);
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Left);

    local remainPointText = GUI.CreateStatic(bg, "remainPointText", "0", 0, -1, 100, 30);
    GUI.SetColor(remainPointText, UIDefine.White2Color);
    GUI.StaticSetFontSize(remainPointText, UIDefine.FontSizeM);
    GUI.StaticSetAlignment(remainPointText, TextAnchor.MiddleCenter);
    --GUI.StaticSetAutoSize(remainPointText, true)
    UILayout.SetSameAnchorAndPivot(remainPointText, UILayout.Center);
    _gt.BindName(remainPointText, "remainPointText");

    local resetBtn = GUI.ButtonCreate(panelBg, "resetBtn", "1800402110", 320, 70, Transition.ColorTint, "洗点", 80, 40, false);
    GUI.ButtonSetTextColor(resetBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(resetBtn, UIDefine.FontSizeM)
    GUI.RegisterUIEvent(resetBtn, UCE.PointerClick, "AddPointUI", "OnResetBtnClick");
    UILayout.SetSameAnchorAndPivot(resetBtn, UILayout.TopLeft);

    local helpBtn = GUI.ButtonCreate(panelBg, "helpBtn", "1800702030", -50, 70, Transition.ColorTint);
    UILayout.SetSameAnchorAndPivot(helpBtn, UILayout.TopRight);
    GUI.RegisterUIEvent(helpBtn, UCE.PointerClick, "AddPointUI", "OnHelpBtnClick");

    for i = 1, #showAttr do
        local advNameText = GUI.CreateStatic(panelBg, "advNameText" .. i, showAttr[i][2], left, 135 + (i - 1) * 35, 80, 30);
        GUI.SetColor(advNameText, UIDefine.BrownColor);
        GUI.StaticSetFontSize(advNameText, UIDefine.FontSizeL);
        GUI.StaticSetAlignment(advNameText, TextAnchor.MiddleLeft);
        UILayout.SetSameAnchorAndPivot(advNameText, UILayout.TopLeft);

        local advValueText = GUI.CreateStatic(advNameText, "advValueText", "0", 50, 0, 100, 30,"system",true);
        GUI.SetColor(advValueText, UIDefine.Yellow2Color);
        GUI.StaticSetFontSize(advValueText, UIDefine.FontSizeL);
        GUI.StaticSetAlignment(advValueText, TextAnchor.MiddleCenter);
        UILayout.SetSameAnchorAndPivot(advValueText, UILayout.Left);
        _gt.BindName(advValueText, "advValueText" .. i);

        local advValueText_child = GUI.CreateStatic(advNameText, "advValueText_child", "0", 140, 0, 100, 30,"system",true);
        GUI.SetColor(advValueText_child, UIDefine.Yellow2Color);
        GUI.StaticSetFontSize(advValueText_child, UIDefine.FontSizeL);
        GUI.StaticSetAlignment(advValueText_child, TextAnchor.MiddleLeft);
        UILayout.SetSameAnchorAndPivot(advValueText_child, UILayout.Left);
        _gt.BindName(advValueText_child, "advValueText_child" .. i);
    end

    for i = 1, #pointAttr do
        local group = GUI.GroupCreate(panelBg, "group" .. i, left, top + (i - 1) * spacing)
        UILayout.SetSameAnchorAndPivot(group, UILayout.TopLeft);
        local baseNameText = GUI.CreateStatic(group, "baseNameText", pointAttr[i].BaseName, 200, 0, 80, 30);
        GUI.SetColor(baseNameText, UIDefine.BrownColor);
        GUI.StaticSetFontSize(baseNameText, UIDefine.FontSizeL);
        GUI.StaticSetAlignment(baseNameText, TextAnchor.MiddleLeft);
        UILayout.SetSameAnchorAndPivot(baseNameText, UILayout.Left);

        local bg = GUI.ImageCreate(group, "bg", "1800700010", 265, 1, false, 105, 35);
        UILayout.SetSameAnchorAndPivot(bg, UILayout.Left);
        local baseValueText = GUI.CreateStatic(bg, "baseValueText", "0", 0, -1, 70, 30);
        GUI.SetColor(baseValueText, UIDefine.White2Color);
        GUI.StaticSetFontSize(baseValueText, UIDefine.FontSizeM);
        GUI.StaticSetAlignment(baseValueText, TextAnchor.MiddleCenter);
        --GUI.StaticSetAutoSize(baseValueText, true)
        UILayout.SetSameAnchorAndPivot(baseValueText, UILayout.Center);
        _gt.BindName(baseValueText, "baseValueText" .. i);

        local subPointBtn = GUI.ButtonCreate(group, "subPointBtn", "1800702080", 377, 0, Transition.ColorTint, "", 40, 40, false);
        UILayout.SetSameAnchorAndPivot(subPointBtn, UILayout.Left);
        subPointBtn:RegisterEvent(UCE.PointerUp)
        subPointBtn:RegisterEvent(UCE.PointerDown)
        GUI.RegisterUIEvent(subPointBtn, UCE.PointerClick, "AddPointUI", "OnSubPointBtnClick");
        GUI.RegisterUIEvent(subPointBtn, UCE.PointerUp, "AddPointUI", "OnSubPointBtnUp");
        GUI.RegisterUIEvent(subPointBtn, UCE.PointerDown, "AddPointUI", "OnSubPointBtnDown");
        GUI.SetData(subPointBtn, "Index", i);

        local addPointBtn = GUI.ButtonCreate(group, "addPointBtn", "1800702020", 420, 0, Transition.ColorTint, "", 40, 40, false);
        UILayout.SetSameAnchorAndPivot(addPointBtn, UILayout.Left);
        addPointBtn:RegisterEvent(UCE.PointerUp)
        addPointBtn:RegisterEvent(UCE.PointerDown)
        GUI.RegisterUIEvent(addPointBtn, UCE.PointerClick, "AddPointUI", "OnAddPointBtnClick");
        GUI.RegisterUIEvent(addPointBtn, UCE.PointerUp, "AddPointUI", "OnAddPointBtnUp");
        GUI.RegisterUIEvent(addPointBtn, UCE.PointerDown, "AddPointUI", "OnAddPointBtnDown");
        GUI.SetData(addPointBtn, "Index", i);
    end

    local suggestBtn = GUI.ButtonCreate(panelBg, "suggestBtn", "1800402110", -100, -20, Transition.ColorTint, "推荐加点", 140, 50, false);
    GUI.ButtonSetTextColor(suggestBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(suggestBtn, UIDefine.FontSizeM)
    GUI.RegisterUIEvent(suggestBtn, UCE.PointerClick, "AddPointUI", "OnSuggestBtnClick");
    UILayout.SetSameAnchorAndPivot(suggestBtn, UILayout.Bottom);

    local confirmBtn = GUI.ButtonCreate(panelBg, "confirmBtn", "1800402110", 100, -20, Transition.ColorTint, "确认加点", 140, 50, false);
    GUI.ButtonSetTextColor(confirmBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(confirmBtn, UIDefine.FontSizeM)
    GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "AddPointUI", "OnConfirmBtnClick");
    UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.Bottom);

    local setAutoBtn = GUI.ButtonCreate(panelBg, "setAutoBtn", "1801202120", 215, -45, Transition.ColorTint);
    GUI.SetEventCD(setAutoBtn, UCE.PointerClick, 0.5)
    GUI.SetEulerAngles(setAutoBtn, Vector3.New(0, 0, -90));
    UILayout.SetAnchorAndPivot(setAutoBtn, UIAnchor.Bottom, UIAroundPivot.Center)
    GUI.RegisterUIEvent(setAutoBtn, UCE.PointerClick, "AddPointUI", "OnSetAutoBtnClick");
    _gt.BindName(setAutoBtn, "setAutoBtn");

    CL.RegisterMessage(GM.PetInfoUpdate, "AddPointUI", "RefreshPetInfo");
    --CL.RegisterMessage(GM.GuardListUpdate, "AddPointUI", "RefreshGuardInfo");
end

function AddPointUI.CreateAutoAddPointPanel(wnd)
    local autoPanel = GUI.ImageCreate(wnd, "AutoPanel", "1801100030", 280, 2, false, 350, 445)
    _gt.BindName(autoPanel, "AutoPanel")
    UILayout.SetSameAnchorAndPivot(autoPanel, UILayout.Center)

    local bg = GUI.ImageCreate(autoPanel, "bg", "1800400200", 10, 13, false, 290, 380)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)

    local left = GUI.ImageCreate(bg, "left", "1801502040", 2, -2, false, 120, 120)
    UILayout.SetSameAnchorAndPivot(left, UILayout.BottomLeft)

    local right = GUI.ImageCreate(bg, "right", "1801502020", -2, -2, false, 120, 120)
    UILayout.SetSameAnchorAndPivot(right, UILayout.BottomRight)

    local title = GUI.CreateStatic(autoPanel, "title", "自动加点", 7, 3, 200, 35)
    UILayout.SetSameAnchorAndPivot(title, UILayout.Top)
    GUI.SetColor(title, UIDefine.BrownColor)
    GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(title, UIDefine.FontSizeL)

    local tip = GUI.CreateStatic(bg, "tip", "启用后，每一级所获得的5点属性将会按照以下方案自动分配", 4, -155, 275, 50)
    GUI.SetColor(tip, UIDefine.BrownColor)
    GUI.StaticSetFontSize(tip, UIDefine.FontSizeS)
    UILayout.SetSameAnchorAndPivot(tip, UILayout.Center)

    AutoPointBtnGuid = {}
    local spacing = 45
    for i = 1, #pointAttr do
        local group = GUI.GroupCreate(bg, "group" .. i, 0, -105 + (i - 1) * spacing)
        local baseNameText = GUI.CreateStatic(group, "baseNameText", pointAttr[i].BaseName, -115, 0, 80, 30);
        GUI.SetColor(baseNameText, UIDefine.BrownColor);
        GUI.StaticSetFontSize(baseNameText, UIDefine.FontSizeL);
        GUI.StaticSetAlignment(baseNameText, TextAnchor.MiddleLeft);
        UILayout.SetSameAnchorAndPivot(baseNameText, UILayout.Left);

        local bg = GUI.ImageCreate(group, "bg", "1800700010", -58, 1, false, 80, 35);
        UILayout.SetSameAnchorAndPivot(bg, UILayout.Left);
        local baseValueText = GUI.CreateStatic(bg, "baseValueText", "0", 0, -1, 80, 30);
        GUI.SetColor(baseValueText, UIDefine.White2Color);
        GUI.StaticSetFontSize(baseValueText, UIDefine.FontSizeM);
        GUI.StaticSetAlignment(baseValueText, TextAnchor.MiddleCenter);
        --GUI.StaticSetAutoSize(baseValueText, true)
        UILayout.SetSameAnchorAndPivot(baseValueText, UILayout.Center);
        _gt.BindName(baseValueText, "autoPointText" .. i)

        local subPointBtn = GUI.ButtonCreate(group, "subPointBtn", "1800702080", 30, 0, Transition.ColorTint, "", 40, 40, false);
        UILayout.SetSameAnchorAndPivot(subPointBtn, UILayout.Left);
        subPointBtn:RegisterEvent(UCE.PointerUp)
        subPointBtn:RegisterEvent(UCE.PointerDown)
        GUI.RegisterUIEvent(subPointBtn, UCE.PointerClick, "AddPointUI", "OnSubPointBtnClick");
        GUI.RegisterUIEvent(subPointBtn, UCE.PointerUp, "AddPointUI", "OnSubPointBtnUp");
        GUI.RegisterUIEvent(subPointBtn, UCE.PointerDown, "AddPointUI", "OnSubPointBtnDown");
        AutoPointBtnGuid[GUI.GetGuid(subPointBtn)] = i

        local addPointBtn = GUI.ButtonCreate(group, "addPointBtn", "1800702020", 75, 0, Transition.ColorTint, "", 40, 40, false);
        UILayout.SetSameAnchorAndPivot(addPointBtn, UILayout.Left);
        addPointBtn:RegisterEvent(UCE.PointerUp)
        addPointBtn:RegisterEvent(UCE.PointerDown)
        GUI.RegisterUIEvent(addPointBtn, UCE.PointerClick, "AddPointUI", "OnAddPointBtnClick");
        GUI.RegisterUIEvent(addPointBtn, UCE.PointerUp, "AddPointUI", "OnAddPointBtnUp");
        GUI.RegisterUIEvent(addPointBtn, UCE.PointerDown, "AddPointUI", "OnAddPointBtnDown");
        AutoPointBtnGuid[GUI.GetGuid(addPointBtn)] = i
    end

    local sureBtn = GUI.ButtonCreate(bg, "sureBtn", "1800402080", 0, -30, Transition.ColorTint, "", 130, 45, false)
    _gt.BindName(sureBtn, "sureBtn")
    UILayout.SetAnchorAndPivot(sureBtn, UIAnchor.Bottom, UIAroundPivot.Center)
    GUI.RegisterUIEvent(sureBtn, UCE.PointerClick, "AddPointUI", "OnSureAutoPoint")
    local btnText = GUI.CreateStatic(sureBtn, "surePointBtnTxt", "确认修改", 0, 0, 120, 35, "system", true)
    UILayout.SetSameAnchorAndPivot(btnText, UILayout.Center)
    GUI.SetColor(btnText, UIDefine.WhiteColor)
    GUI.StaticSetAlignment(btnText, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(btnText, UIDefine.FontSizeXL)
    GUI.SetIsOutLine(btnText, true)
    GUI.SetOutLine_Color(btnText, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(btnText, 1)

    local autoPointCheckBox = GUI.CheckBoxCreate(bg, "autoPointCheckBox", "1800607150", "1800607151", 93, 118, Transition.None, false, 40, 40)
    UILayout.SetSameAnchorAndPivot(autoPointCheckBox, UILayout.Center)
    --GUI.CheckBoxSetCheck(autoPointCheckBox, true)
    GUI.RegisterUIEvent(autoPointCheckBox, UCE.PointerClick, "AddPointUI", "OnAutoPointCheckBoxChange")
    _gt.BindName(autoPointCheckBox, "autoPointCheckBox")

    local CheckBoxLabel = GUI.CreateStatic(autoPointCheckBox, "autoPointCheckBoxLabel", "是否开启自动加点", -188, 0, 200, 35)
    GUI.StaticSetFontSize(CheckBoxLabel, 22)
    UILayout.SetSameAnchorAndPivot(CheckBoxLabel, UILayout.Left)
    GUI.SetColor(CheckBoxLabel, UIDefine.BrownColor)
end

function AddPointUI.RestData()
    AddPointUI.CurType = AddPointType.PET
    AddPointUI.remainPoint = 0;
    AddPointUI.curGuid = nil;
    AddPointUI.Timer = nil;
    AddPointUI.GuardId = 0;
    AutoPanelState = false
    RemainAutoPointCount = 0
    IsFirstEnter = true
end

function AddPointUI.InitData()
    race2Attr = {}
    local temp = {}
    for i = 1, #showAttr do
        temp[showAttr[i][1]] = true
    end
    local ids = DB.GetRaceAllKeys()
    for i = 0, ids.Count - 1 do
        local raceDB = DB.GetRace(ids[i])
        local attr = RoleAttr.IntToEnum(raceDB.Attr)
        if temp[attr] then
            local raceData = race2Attr[raceDB.Race]
            if not raceData then
                raceData = {}
                race2Attr[raceDB.Race] = raceData
            end
            raceData[attr] = {
                AgiPct = raceDB.AgiPct,
                EndPct = raceDB.EndPct,
                StrPct = raceDB.StrPct,
                VitPct = raceDB.VitPct,
                IntPct = raceDB.IntPct,
            }
        end
    end
end

function AddPointUI.OnShow(parameter)
    local wnd = GUI.GetWnd("AddPointUI");
    if wnd == nil then
        return ;
    end
    GUI.SetVisible(wnd, true);
    parameter = UIDefine.GetParameter1(parameter)
    if parameter == AddPointType.PLAYER then
        AddPointUI.SetPlayer()
    end
end

local PanelBgFromPos = Vector3.New(0, 0, 0)
local PanelBgEndPos = Vector3.New(-150, 0, 0)
local AutoPanelFromPos = Vector3.New(90, 2, 0)
local AutoPanelEndPos = Vector3.New(268, 2, 0)
function AddPointUI.OnSetAutoBtnClick(guid)
    local panelBg = _gt.GetUI("panelBg")
    if panelBg then
        local tween = TweenData.New()
        tween.Type = GUITweenType.DOLocalMove
        tween.Duration = 0.3
        tween.From = AutoPanelState and PanelBgEndPos or PanelBgFromPos
        tween.LoopType = UITweenerStyle.Once
        tween.To = AutoPanelState and PanelBgFromPos or PanelBgEndPos
        GUI.DOTween(panelBg, tween)
    end

    local autoPanel = _gt.GetUI("AutoPanel")
    if autoPanel then
        local tween = TweenData.New()
        tween.Type = GUITweenType.DOLocalMove
        tween.Duration = 0.3
        tween.From = AutoPanelState and AutoPanelEndPos or AutoPanelFromPos
        tween.LoopType = UITweenerStyle.Once
        tween.To = AutoPanelState and AutoPanelFromPos or AutoPanelEndPos
        GUI.DOTween(autoPanel, tween)
    end

    AutoPanelState = not AutoPanelState
    local setAutoBtn = _gt.GetUI("setAutoBtn")
    GUI.SetEulerAngles(setAutoBtn, Vector3.New(0, 0, AutoPanelState and 90 or -90));
end

function AddPointUI.RefreshAutoSettingPanel(isOpen)
    local panelBg = _gt.GetUI("panelBg")
    if panelBg then
        GUI.SetPositionX(panelBg, isOpen and PanelBgEndPos.x or PanelBgFromPos.x)
    end
    local autoPanel = _gt.GetUI("AutoPanel")
    if autoPanel then
        GUI.SetPositionX(autoPanel, isOpen and AutoPanelEndPos.x or AutoPanelFromPos.x)
    end
    local setAutoBtn = _gt.GetUI("setAutoBtn")
    GUI.SetEulerAngles(setAutoBtn, Vector3.New(0, 0, isOpen and 90 or -90));
end

--- 洗点按钮处理
function AddPointUI.OnResetBtnClick(guid)
    if AddPointUI.CurType == AddPointType.PET then
        CL.SendNotify(NOTIFY.SubmitForm, "FormAddPoint", "Pet_ResetPoint", AddPointUI.curGuid)
    elseif AddPointUI.CurType == AddPointType.PLAYER then
        CL.SendNotify(NOTIFY.SubmitForm, "FormAddPoint", "Player_ResetPoint")
    elseif AddPointUI.CurType == AddPointType.GUARD then
        CL.SendNotify(NOTIFY.SubmitForm, "FormAddPoint", "Guard_ResetPoint", AddPointUI.curGuid)
    end
end

function AddPointUI.OnHelpBtnClick()
    local sellPage = _gt.GetUI("panelBg");
    Tips.CreateHint("提高力量属性，会影响血量上限、物攻。\n提高法力属性，会影响魔法上限、法攻、法防。\n提高体质属性，会影响血量上限、法防。\n提高耐力属性，会影响物防、法防。\n提高敏捷属性，会影响速度。", sellPage, 200, 110, UILayout.Top, 400)
end

function AddPointUI.OnAutoPointCheckBoxChange()
    local sureBtn = _gt.GetUI("sureBtn")
    GUI.ButtonSetShowDisable(sureBtn, AddPointUI.CheckAutoPointChange())
end

function AddPointUI.OnSureAutoPoint(guid)
    --设置自动加点方案
    local autoPointCheckBox = _gt.GetUI("autoPointCheckBox")
    local isCheck = GUI.CheckBoxGetCheck(autoPointCheckBox)
    local formStr = "FormAddPoint"
    local method = ""
    if AddPointUI.CurType == AddPointType.PET then
        method = "Pet_Auto_AddPoint"
    elseif AddPointUI.CurType == AddPointType.PLAYER then
        method = "Player_Auto_AddPoint"
        CL.SendNotify(NOTIFY.SubmitForm, formStr, method, AutoPointTable[1], AutoPointTable[2], AutoPointTable[3], AutoPointTable[4], AutoPointTable[5], isCheck and 1 or 0)
        return
    elseif AddPointUI.CurType == AddPointType.GUARD then
        method = "Guard_Auto_AddPoint"
    end
    CL.SendNotify(NOTIFY.SubmitForm, formStr, method, AddPointUI.curGuid, AutoPointTable[1], AutoPointTable[2], AutoPointTable[3], AutoPointTable[4], AutoPointTable[5], isCheck and 1 or 0)
end

function AddPointUI.CheckAutoPointChange()
    for i = 1, MaxAutoPointCount do
        if AutoPointTable[i] ~= AutoLastPoint[i] then
            return true
        end
    end
    local autoPointCheckBox = _gt.GetUI("autoPointCheckBox")
    local isCheck = GUI.CheckBoxGetCheck(autoPointCheckBox)
    if isCheck ~= IsAutoPoint then
        return true
    end
    return false
end

function AddPointUI.OnExit()
    GUI.CloseWnd("AddPointUI")
end

function AddPointUI.OnClose()
    if AddPointUI.Timer ~= nil then
        AddPointUI.Timer:Stop();
        AddPointUI.Timer = nil;
    end
    AddPointUI.RestData();
    AddPointUI.RefreshAutoSettingPanel(AutoPanelState)
    if AddPointUI.CurType == AddPointType.PLAYER then
        CL.UnRegisterAttr(RoleAttr.RoleAttrRemainPoint, AddPointUI.OnPlayerAttrChange)
    end
end

function AddPointUI.RefreshPetInfo()
    if AddPointUI.curGuid ~= nil then
        AddPointUI.SetPetGuid(AddPointUI.curGuid)
    end
end

function AddPointUI.SetPetGuid(petGuid)
    AddPointUI.CurType = AddPointType.PET
    AddPointUI.curGuid = petGuid;
    local rpStr = tostring(LD.GetPetAttr(RoleAttr.RoleAttrRemainPoint, petGuid));
    local remainPointText = _gt.GetUI("remainPointText");
    GUI.StaticSetText(remainPointText, rpStr);

    AddPointUI.remainPoint = tonumber(rpStr);
    for i = 1, #pointAttr do
        pointAttr[i].BaseValue = tonumber(tostring(LD.GetPetAttr(pointAttr[i].BaseAttr, petGuid)))
        pointAttr[i].AddValue = 0;
    end

    local str = LD.GetPetStrCustomAttr("ADDPOINT_Method", petGuid)
    AddPointUI.InitAutoPointTable(str)
    IsAutoPoint = LD.GetPetIntCustomAttr("ADDPOINT_Auto", petGuid) == 1

    AddPointUI.Refresh(true)
end

function AddPointUI.RefreshGuardInfo(guid)
    if AddPointUI.CurType ~= AddPointType.GUARD or guid ~= AddPointUI.curGuid then
        return
    end
    AddPointUI.SetGuardGuid(AddPointUI.curGuid, AddPointUI.GuardId)
end

function AddPointUI.SetGuardGuid(guardGuid, guardId)
    local guardData = LD.GetGuardData(guardGuid)
    if not guardData then
        return
    end
    AddPointUI.CurType = AddPointType.GUARD
    AddPointUI.curGuid = guardGuid;
    if guardId then
        AddPointUI.GuardId = guardId
    end
    local attrs = guardData.attrs
    local rpStr = tostring(LogicDefine.GetAttrFromFreeList(attrs, RoleAttr.RoleAttrRemainPoint))
    local remainPointText = _gt.GetUI("remainPointText");
    GUI.StaticSetText(remainPointText, rpStr);

    AddPointUI.remainPoint = tonumber(rpStr);
    for i = 1, #pointAttr do
        local baseAttrStr = tostring(LogicDefine.GetAttrFromFreeList(attrs, pointAttr[i].BaseAttr))
        pointAttr[i].BaseValue = tonumber(tostring(LogicDefine.GetAttrFromFreeList(attrs, pointAttr[i].AddPointAttr)))
                + tonumber(tostring(LogicDefine.GetAttrFromFreeList(attrs, RoleAttr.RoleAttrLevel)))
        pointAttr[i].OtherValue = tonumber(baseAttrStr) - pointAttr[i].BaseValue
        pointAttr[i].AddValue = 0;
    end

    local str = LD.GetGuardStrCustomAttr("ADDPOINT_Method", guardGuid)
    AddPointUI.InitAutoPointTable(str)
    IsAutoPoint = LD.GetGuardIntCustomAttr("ADDPOINT_Auto", guardGuid) == 1

    AddPointUI.Refresh(true)
end

function AddPointUI.SetPlayer()
    AddPointUI.CurType = AddPointType.PLAYER
    AddPointUI.curGuid = LD.GetSelfGUID()
    local rpStr = CL.GetIntAttr(RoleAttr.RoleAttrRemainPoint)
    local remainPointText = _gt.GetUI("remainPointText");
    GUI.StaticSetText(remainPointText, rpStr);

    AddPointUI.remainPoint = tonumber(rpStr);
    for i = 1, #pointAttr do
        pointAttr[i].BaseValue = CL.GetIntAttr(pointAttr[i].BaseAttr)
        pointAttr[i].AddValue = 0;
    end

    local str = CL.GetStrCustomData("ADDPOINT_Method")
    AddPointUI.InitAutoPointTable(str)
    IsAutoPoint = CL.GetIntCustomData("ADDPOINT_Auto") == 1

    CL.UnRegisterAttr(RoleAttr.RoleAttrRemainPoint, AddPointUI.OnPlayerAttrChange)
    CL.RegisterAttr(RoleAttr.RoleAttrRemainPoint, AddPointUI.OnPlayerAttrChange)

    AddPointUI.Refresh(true)
end

function AddPointUI.OnPlayerAttrChange(attrType, value)
    if AddPointUI.CurType == AddPointType.PLAYER then
        Timer.New(AddPointUI.SetPlayer, 0.1, 1):Start()
    end
end

function AddPointUI.OnSubPointBtnClick(guid)
    local index = AutoPointBtnGuid[guid]
    if index then
        -- 当前正在设置自动加点分配方案
        local val = AutoPointTable[index] or 0
        if val <= 0 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "当前属性未分配加点")
            return
        end

        val = val - 1
        RemainAutoPointCount = RemainAutoPointCount + 1
        AutoPointTable[index] = val
        AddPointUI.RefreshAutoPointValue()
        return
    end

    local subPointBtn = GUI.GetByGuid(guid);
    local index = tonumber(GUI.GetData(subPointBtn, "Index"))

    if pointAttr[index].AddValue > 0 then
        pointAttr[index].AddValue = pointAttr[index].AddValue - 1;
        AddPointUI.remainPoint = AddPointUI.remainPoint + 1;
        AddPointUI.Refresh()
    end
end

function AddPointUI.OnSubPointBtnDown(guid)
    local fun = function()
        AddPointUI.OnSubPointBtnClick(guid);
    end

    if AddPointUI.Timer == nil then
        AddPointUI.Timer = Timer.New(fun, 0.15, -1)
    else
        AddPointUI.Timer:Stop();
        AddPointUI.Timer:Reset(fun, 0.15, 1)
    end

    AddPointUI.Timer:Start();
end

function AddPointUI.OnSubPointBtnUp(guid)
    if AddPointUI.Timer ~= nil then
        AddPointUI.Timer:Stop();
        AddPointUI.Timer = nil;
    end
end

function AddPointUI.OnAddPointBtnClick(guid)
    local index = AutoPointBtnGuid[guid]
    if index then
        -- 当前正在设置自动加点分配方案
        if RemainAutoPointCount <= 0 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "可分配点数不足")
            return
        end
        local val = AutoPointTable[index] or 0
        val = val + 1
        RemainAutoPointCount = RemainAutoPointCount - 1
        AutoPointTable[index] = val
        AddPointUI.RefreshAutoPointValue()
        return
    end

    -- 正在手动分配加点
    local addPointBtn = GUI.GetByGuid(guid);
    index = tonumber(GUI.GetData(addPointBtn, "Index"))

    if AddPointUI.remainPoint > 0 then
        pointAttr[index].AddValue = pointAttr[index].AddValue + 1;
        AddPointUI.remainPoint = AddPointUI.remainPoint - 1;

        AddPointUI.Refresh()
    end
end

function AddPointUI.OnAddPointBtnDown(guid)
    local fun = function()
        AddPointUI.OnAddPointBtnClick(guid);
    end

    if AddPointUI.Timer == nil then
        AddPointUI.Timer = Timer.New(fun, 0.15, -1)
    else
        AddPointUI.Timer:Stop();
        AddPointUI.Timer:Reset(fun, 0.15, 1)
    end

    AddPointUI.Timer:Start();
end

function AddPointUI.OnAddPointBtnUp(guid)
    if AddPointUI.Timer ~= nil then
        AddPointUI.Timer:Stop();
        AddPointUI.Timer = nil;
    end
end

function AddPointUI.InitAutoPointTable(configStr)
    if configStr and configStr ~= "" then
        local strs = string.split(configStr, ",")
        local t = { tonumber(strs[1] or "0"), tonumber(strs[2] or "0"), tonumber(strs[3] or "0"), tonumber(strs[4] or "0"), tonumber(strs[5] or "0") }
        if t[1] + t[2] + t[3] + t[4] + t[5] == MaxAutoPointCount then
            AutoLastPoint = t
            AutoPointTable = { t[1], t[2], t[3], t[4], t[5] }
            return
        end
    end
    if AddPointUI.curGuid == nil then
        AutoLastPoint = { 1, 1, 1, 1, 1 }
        AutoPointTable = { 1, 1, 1, 1, 1 }
        return
    end
    local pointSuggest = 1
    if AddPointUI.CurType == AddPointType.PET then
        local petId = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, AddPointUI.curGuid);
        local petDB = DB.GetOncePetByKey1(petId);
        pointSuggest = petDB.PointSuggest
    elseif AddPointUI.CurType == AddPointType.GUARD then
        local guardData = LD.GetGuardData(AddPointUI.curGuid)
        if not guardData then
            AutoLastPoint = { 1, 1, 1, 1, 1 }
            AutoPointTable = { 1, 1, 1, 1, 1 }
            return
        end
        local guardDB = DB.GetOnceGuardByKey1(AddPointUI.GuardId)
        pointSuggest = guardDB.PointSuggest
    elseif AddPointUI.CurType == AddPointType.PLAYER then
        local roleData = DB.GetRole(CL.GetRoleTemplateID())
        local school = CL.GetIntAttr(RoleAttr.RoleAttrJob1)
        if not roleData or roleData.Id == 0 then
            AutoLastPoint = { 1, 1, 1, 1, 1 }
            AutoPointTable = { 1, 1, 1, 1, 1 }
            return
        end
        if school == roleData.School1 then
            pointSuggest = roleData.PointSuggest1
        elseif school == roleData.School2 then
            pointSuggest = roleData.PointSuggest2
        elseif school == roleData.School3 then
            pointSuggest = roleData.PointSuggest3
        end
    end
    local pointDB = DB.GetOncePointByKey1(pointSuggest);
    local t = { pointDB.Str, pointDB.Int, pointDB.Vit, pointDB.End, pointDB.Agi }
    AutoLastPoint = t
    AutoPointTable = { t[1], t[2], t[3], t[4], t[5] }
end

function AddPointUI.OnSuggestBtnClick()
    if AddPointUI.curGuid == nil then
        return ;
    end
    local rpStr
    local pointSuggest = 1
    if AddPointUI.CurType == AddPointType.PET then
        rpStr = LD.GetPetIntAttr(RoleAttr.RoleAttrRemainPoint, AddPointUI.curGuid);
        local petId = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, AddPointUI.curGuid);
        local petDB = DB.GetOncePetByKey1(petId);
        pointSuggest = petDB.PointSuggest
    elseif AddPointUI.CurType == AddPointType.GUARD then
        local guardData = LD.GetGuardData(AddPointUI.curGuid)
        if not guardData then
            return
        end
        rpStr = tonumber(tostring(LogicDefine.GetAttrFromFreeList(guardData.attrs, RoleAttr.RoleAttrRemainPoint)))
        local guardDB = DB.GetOnceGuardByKey1(AddPointUI.GuardId)
        pointSuggest = guardDB.PointSuggest
    elseif AddPointUI.CurType == AddPointType.PLAYER then
        local roleData = DB.GetRole(CL.GetRoleTemplateID())
        if not roleData or roleData.Id == 0 then
            return
        end
        rpStr = CL.GetIntAttr(RoleAttr.RoleAttrRemainPoint)
        pointSuggest = roleData.PointSuggest1
        local job = CL.GetIntAttr(RoleAttr.RoleAttrJob1)
        for i = 1, 3 do
            if roleData["School" .. i] == job then
                pointSuggest = roleData["PointSuggest" .. i]
                break
            end
        end
    end
    print(rpStr, pointSuggest)
    if rpStr < MaxAutoPointCount then
        CL.SendNotify(NOTIFY.ShowBBMsg, "可分配点数不足")
    end
    local pointDB = DB.GetOncePointByKey1(pointSuggest);
    local n = math.floor(rpStr / MaxAutoPointCount);

    AddPointUI.remainPoint = rpStr - n * MaxAutoPointCount;
    pointAttr[1].AddValue = n * pointDB.Str;
    pointAttr[2].AddValue = n * pointDB.Int;
    pointAttr[3].AddValue = n * pointDB.Vit;
    pointAttr[4].AddValue = n * pointDB.End;
    pointAttr[5].AddValue = n * pointDB.Agi;

    AddPointUI.Refresh()
end

function AddPointUI.Refresh(refreshCheck)
    if AddPointUI.CurType == AddPointType.PET then
        AddPointUI.RefreshPetPreview()
    elseif AddPointUI.CurType == AddPointType.GUARD then
        AddPointUI.RefreshGuardPreview()
    elseif AddPointUI.CurType == AddPointType.PLAYER then
        AddPointUI.RefreshPlayerPreview()
    end
    if IsFirstEnter then
        --TODO  如果不想打开时显示自动加点页面 ，把下面一行的 改成 AutoPanelState = IsAutoPoint
        AutoPanelState = true
        AddPointUI.RefreshAutoSettingPanel(AutoPanelState)
        IsFirstEnter = false
    end
    if refreshCheck then
        local autoPointCheckBox = _gt.GetUI("autoPointCheckBox")
        GUI.CheckBoxSetCheck(autoPointCheckBox, IsAutoPoint)
    end
    AddPointUI.RefreshAutoPointValue()
end

function AddPointUI.RefreshAutoPointValue()
    for i = 1, #AutoPointTable do
        local autoPointText = _gt.GetUI("autoPointText" .. i)
        GUI.StaticSetText(autoPointText, AutoPointTable[i])
        GUI.SetColor(autoPointText, AutoPointTable[i] == AutoLastPoint[i] and UIDefine.White2Color or UIDefine.GreenColor)
    end

    local sureBtn = _gt.GetUI("sureBtn")
    GUI.ButtonSetShowDisable(sureBtn, AddPointUI.CheckAutoPointChange())
end

function AddPointUI.RefreshPetPreview()
    local petData = LD.GetPetData(AddPointUI.curGuid);
    if petData == nil then
        return ;
    end
    local remainPointText = _gt.GetUI("remainPointText");
    GUI.StaticSetText(remainPointText, tostring(AddPointUI.remainPoint));

    local race = petData:GetIntAttr(RoleAttr.RoleAttrRace)
    local raceData = race2Attr[race]

    local attrStr = pointAttr[1].AddValue
    local attrInt = pointAttr[2].AddValue
    local attrVit = pointAttr[3].AddValue
    local attrEnd = pointAttr[4].AddValue
    local attrAgi = pointAttr[5].AddValue

    for i = 1, #showAttr do
        local advValueText = _gt.GetUI("advValueText" .. i);
        local attrType = showAttr[i][1]
        local curValue = petData:GetIntAttr(attrType)
        local talentAttr = petData:GetIntAttr(showAttr[i][3])
        local config = raceData[attrType]
        local addPointValue = 0
        if config then
            addPointValue = math.floor((attrStr * config.StrPct + attrAgi * config.AgiPct + attrEnd * config.EndPct + attrInt * config.IntPct + attrVit * config.VitPct) * talentAttr / 10000  / 10000)
        end
        --GUI.StaticSetText(advValueText, curValue + addPointValue);
        --GUI.SetColor(advValueText, addPointValue > 0 and UIDefine.GreenColor or UIDefine.BrownColor)
        local s = "<color=#66310eff>"..curValue.."</color>"
        GUI.StaticSetText(advValueText,s);

        local advValueText_child = _gt.GetUI("advValueText_child" .. i);
        if addPointValue > 0  then
            local s = "<color=#46DC5Fff>".."+"..addPointValue.."</color>"
            GUI.StaticSetText(advValueText_child,s);
        else
            GUI.StaticSetText(advValueText_child,"");
        end
       
    end

    for i = 1, #pointAttr do
        local baseValueText = _gt.GetUI("baseValueText" .. i);
        local addValue = pointAttr[i].AddValue
        GUI.StaticSetText(baseValueText, tostring(pointAttr[i].BaseValue + addValue));
        if addValue > 0 then
            GUI.SetColor(baseValueText, UIDefine.GreenColor);
        else
            GUI.SetColor(baseValueText, UIDefine.White2Color);
        end
    end
end

function AddPointUI.RefreshGuardPreview()
    local remainPointText = _gt.GetUI("remainPointText");
    GUI.StaticSetText(remainPointText, tostring(AddPointUI.remainPoint))
    local guardData = LD.GetGuardData(AddPointUI.curGuid)
    if not guardData then
        return
    end

end

function AddPointUI.RefreshPlayerPreview()
    local remainPointText = _gt.GetUI("remainPointText");
    GUI.StaticSetText(remainPointText, tostring(AddPointUI.remainPoint))
    local race = CL.GetIntAttr(RoleAttr.RoleAttrRace)
    local raceData = race2Attr[race]

    local attrStr = pointAttr[1].AddValue  --CL.GetIntAttr(pointAttr[1].BaseAttr) +
    local attrInt = pointAttr[2].AddValue  --CL.GetIntAttr(pointAttr[2].BaseAttr) +
    local attrVit = pointAttr[3].AddValue  --CL.GetIntAttr(pointAttr[3].BaseAttr) +
    local attrEnd = pointAttr[4].AddValue  --CL.GetIntAttr(pointAttr[4].BaseAttr) +
    local attrAgi = pointAttr[5].AddValue  --CL.GetIntAttr(pointAttr[5].BaseAttr) +

    for i = 1, #showAttr do
        local advValueText = _gt.GetUI("advValueText" .. i);
        local attrType = showAttr[i][1]
        local curValue = CL.GetIntAttr(attrType)
        local config = raceData[attrType]
        local addPointValue = 0
        if config then
            addPointValue = math.floor((attrStr * config.StrPct + attrAgi * config.AgiPct + attrEnd * config.EndPct + attrInt * config.IntPct + attrVit * config.VitPct) / 10000)
        end
        -- GUI.StaticSetText(advValueText, curValue + addPointValue);
        -- GUI.SetColor(advValueText, addPointValue > 0 and UIDefine.GreenColor or UIDefine.BrownColor)
        local s = "<color=#66310eff>"..curValue.."</color>"
        GUI.StaticSetText(advValueText,s);

        local advValueText_child = _gt.GetUI("advValueText_child" .. i);
        if addPointValue > 0  then
            local s = "<color=#46DC5Fff>".."+"..addPointValue.."</color>"
            GUI.StaticSetText(advValueText_child,s);
        else
            GUI.StaticSetText(advValueText_child,"");
        end
    end

    for i = 1, #pointAttr do
        local baseValueText = _gt.GetUI("baseValueText" .. i);
        local addValue = pointAttr[i].AddValue
        GUI.StaticSetText(baseValueText, tostring(pointAttr[i].BaseValue + addValue));
        if addValue > 0 then
            GUI.SetColor(baseValueText, UIDefine.GreenColor);
        else
            GUI.SetColor(baseValueText, UIDefine.White2Color);
        end
    end
end

function AddPointUI.OnConfirmBtnClick()
    if AddPointUI.curGuid == nil then
        return ;
    end

    local p1 = pointAttr[1].AddValue;
    local p2 = pointAttr[2].AddValue;
    local p3 = pointAttr[3].AddValue;
    local p4 = pointAttr[4].AddValue;
    local p5 = pointAttr[5].AddValue;

    if p1 ~= 0 or p2 ~= 0 or p3 ~= 0 or p4 ~= 0 or p5 ~= 0 then
        print("AddPoint:" .. tostring(AddPointUI.curGuid) .. "-" .. p1 .. "," .. p2 .. "," .. p3 .. "," .. p4 .. "," .. p5)
        if AddPointUI.CurType == AddPointType.PET then
            CL.SendNotify(NOTIFY.SubmitForm, "FormAddPoint", "Pet_AddPoint", AddPointUI.curGuid, p1, p2, p3, p4, p5)
        elseif AddPointUI.CurType == AddPointType.GUARD then
            CL.SendNotify(NOTIFY.SubmitForm, "FormAddPoint", "Guard_AddPoint", AddPointUI.curGuid, p1, p2, p3, p4, p5)
        elseif AddPointUI.CurType == AddPointType.PLAYER then
            CL.SendNotify(NOTIFY.SubmitForm, "FormAddPoint", "Player_AddPoint", p1, p2, p3, p4, p5)
        end
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "未分配点数")
    end
end

-- 脚本调用过来刷新设置
function AddPointUI.OnAutoPointFinish()
    if AddPointUI.CurType == AddPointType.PET then
        AddPointUI.SetPetGuid(AddPointUI.curGuid)
    elseif AddPointUI.CurType == AddPointType.GUARD then
        AddPointUI.SetGuardGuid(AddPointUI.curGuid, AddPointUI.GuardId)
    elseif AddPointUI.CurType == AddPointType.PLAYER then
        AddPointUI.SetPlayer()
    end
end