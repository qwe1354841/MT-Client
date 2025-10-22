GradeGiftBtn = {}
--狂送大礼
_G.GradeGiftBtn = GradeGiftBtn
local _gt = UILayout.NewGUIDUtilTable();
--

function GradeGiftBtn.Main()
    _gt = UILayout.NewGUIDUtilTable()
    test("GradeGiftBtn lua ")

    local panel = GUI.WndCreateWnd("GradeGiftBtn","GradeGiftBtn",0,0,eCanvasGroup.Main)
    local ShowGradeGiftBtn = GUI.ButtonCreate(panel, "ShowGradeGiftBtn", "1801202170", -310, 100, Transition.ColorTint, "", 0, 0, false)
	_gt.BindName(ShowGradeGiftBtn,"ShowGradeGiftBtn")
    GUI.SetAnchor(ShowGradeGiftBtn,UIAnchor.TopRight);
    GUI.SetPivot(ShowGradeGiftBtn,UIAroundPivot.TopRight);
    GUI.RegisterUIEvent(ShowGradeGiftBtn , UCE.PointerClick , "GradeGiftBtn", "ShowGradeGiftBtnClick" )

    local effect = GUI.SpriteFrameCreate(ShowGradeGiftBtn, "effect", "", 0, 0)
    GUI.SetFrameId(effect, "3403700000")
    UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
    GUI.SpriteFrameSetIsLoop(effect, true)
    GUI.Play(effect)
    CL.RegisterMessage(GM.FightStateNtf, "GradeGiftBtn", "OnEnterFight")
    
    --local ShowGradeGiftTxt = GUI.ButtonCreate(ShowGradeGiftBtn, "ShowGradeGiftTxt", "1801205060", 0, 20, Transition.ColorTint, "", 0, 0, false)
    local ShowGradeGiftTxt = GUI.ImageCreate(ShowGradeGiftBtn, "ShowGradeGiftTxt", "1801205060", 0, 20)
    GUI.SetAnchor(ShowGradeGiftTxt,UIAnchor.Center);
    GUI.SetPivot(ShowGradeGiftTxt,UIAroundPivot.Center);
    --GUI.RegisterUIEvent(ShowGradeGiftTxt , UCE.PointerClick , "GradeGiftBtn", "ShowGradeGiftBtnClick" )
end

function GradeGiftBtn.OnEnterFight(isInfight)
    local ShowGradeGiftBtn = _gt.GetUI("ShowGradeGiftBtn")
    if type(isInfight) == "string" then
        isInfight = isInfight == "true"
    else
        isInfight = isInfight or CL.GetFightViewState()
    end
    if isInfight then
        GUI.SetVisible(ShowGradeGiftBtn,false)
    else
        GUI.SetVisible(ShowGradeGiftBtn,true)
    end
end

function GradeGiftBtn.ShowGradeGiftBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGradePresent", "GetPresetnData")
	--GUI.OpenWnd("GradeGiftUI")
end 

function GradeGiftBtn.OnRefresh()
    if GradeGiftBtn.IsHaveList == nil then
        return;
    end
    local index = 1
    for i = 1 , #UIDefine.GradeGift_RewardLevel do
        if GradeGiftBtn.IsHaveList[''..UIDefine.GradeGift_RewardLevel[i]] == 1 then
        else
            index = i
            break
        end
    end
    GradeGiftUI.setGiftIndex(index)
end

function GradeGiftBtn.OnShow()
    local wnd = GUI.GetWnd("GradeGiftBtn");
    if wnd then
        GUI.SetVisible(wnd, true);
    end
end

function GradeGiftBtn.OnExit()
    GUI.CloseWnd("GradeGiftBtn")
end