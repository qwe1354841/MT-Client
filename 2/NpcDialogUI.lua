local NpcDialogUI = {}
_G.NpcDialogUI = NpcDialogUI

local _gt = UILayout.NewGUIDUtilTable()
NpcDialogUI.QuestInfo = {IsQuestTalk = false}
NpcDialogUI.Options = {}
NpcDialogUI.NeedDelayShow = true
NpcDialogUI.DynamicOptionsTextList = {}
NpcDialogUI.DynamicText = {}
NpcDialogUI.DynamicOptionsGuid = nil
local contentWidth = 780;
function NpcDialogUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("NpcDialogUI" , "NpcDialogUI" , 0 , 0);

    local maskBtn = GUI.ButtonCreate(wnd, "maskBtn", "1800400220", 0, 0, Transition.None, "", GUI.GetWidth(wnd), GUI.GetHeight(wnd), false);
    UILayout.SetSameAnchorAndPivot(maskBtn, UILayout.Center);
    GUI.SetColor(maskBtn, UIDefine.Transparent);
    GUI.RegisterUIEvent(maskBtn, UCE.PointerClick, "NpcDialogUI", "OnMaskBtnClick");

    local contentBg = GUI.ImageCreate(maskBtn, "contentBg", "1800600010", 0, 0, false, GUI.GetWidth(wnd) - 45, 155);
    UILayout.SetSameAnchorAndPivot(contentBg, UILayout.Bottom)

    local model = GUI.RawImageCreate(maskBtn, false, "model", "", -180, 0, 2, false, 800, 400, 2)
    _gt.BindName(model, "model");
    model:RegisterEvent(UCE.Drag)
    UILayout.SetSameAnchorAndPivot(model, UILayout.BottomLeft)
    GUI.AddToCamera(model);
    GUI.RawImageSetCameraConfig(model, "(-0.05,1.2,2),(1.225183E-08,0.9990483,-0.04361941,2.80613E-07),True,5,0.01,0.6,1E-05");
    local npcModel = GUI.RawImageChildCreate(model, false, "npcModel", "", 0, 0)
    --GUI.BindPrefabWithChild(model,GUI.GetGuid(npcModel));
    GUI.RegisterUIEvent(npcModel, ULE.AnimationCallBack, "NpcDialogUI", "OnAnimationCallBack")
    _gt.BindName(npcModel, "npcModel");


    local textScr = GUI.ScrollRectCreate(contentBg, "textScr", 155, 0, contentWidth, 120, 0, false, Vector2.New(contentWidth, 0), UIAroundPivot.Center, UIAnchor.Center, 1);
    UILayout.SetSameAnchorAndPivot(textScr, UILayout.Center)
    _gt.BindName(textScr, "textScr");

    local content = GUI.RichEditCreate(textScr, "content", "", 0, 0, contentWidth, 0);
    GUI.StaticSetFontSize(content, UIDefine.FontSizeXL);
    _gt.BindName(content, "content");
    UILayout.SetSameAnchorAndPivot(content, UILayout.TopLeft)

    local nameBg = GUI.ImageCreate(maskBtn, "nameBg", "1800600440", 85, 0);
    UILayout.SetSameAnchorAndPivot(nameBg, UILayout.BottomLeft)

    local nameText = GUI.CreateStatic(nameBg, "name", "AAAAAAAA", 0, 1, 180, 35);
    GUI.SetColor(nameText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(nameText, UIDefine.FontSizeM);
    GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter);
    UILayout.SetSameAnchorAndPivot(nameText, UILayout.Center)
    _gt.BindName(nameText, "nameText");

    local optionsBg = GUI.ImageCreate(maskBtn, "optionsBg", "1800600010", 0, -200, false, 450, 260);
    UILayout.SetSameAnchorAndPivot(optionsBg, UILayout.BottomRight)
    _gt.BindName(optionsBg, "optionsBg")
    GUI.SetVisible(optionsBg, false);

    local text = GUI.CreateStatic(optionsBg, "name", "请选择你想要做的事", 0, -15, 400, 35);
    UILayout.SetSameAnchorAndPivot(text, UILayout.Top)
    GUI.SetColor(text, UIDefine.WhiteColor);
    GUI.StaticSetFontSize(text, UIDefine.FontSizeM);
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);

    local cutLine = GUI.ImageCreate(optionsBg, "cutLine", "1800600030", 0, -55, false, 450, 4);
    UILayout.SetSameAnchorAndPivot(cutLine, UILayout.Top)

    local upArrow = GUI.ImageCreate(optionsBg, "upArrow", "1800607340", 0, -85);
    UILayout.SetSameAnchorAndPivot(upArrow, UILayout.Top)
    GUI.SetEulerAngles(upArrow, Vector3.New(0, 0, 180));
    _gt.BindName(upArrow, "upArrow")

    local downArrow = GUI.ImageCreate(optionsBg, "downArrow", "1800607340", 0, 10);
    UILayout.SetSameAnchorAndPivot(downArrow, UILayout.Bottom)
    _gt.BindName(downArrow, "downArrow")

    local optionsScr = GUI.LoopScrollRectCreate(optionsBg, "optionsScr", 0, 15, 415, 180,
            "NpcDialogUI", "CreatOptionsPool", "NpcDialogUI", "RefreshOptionsScr", 0, false, Vector2.New(415, 60), 1, UIAroundPivot.Top, UIAnchor.Top);
    UILayout.SetSameAnchorAndPivot(optionsScr, UILayout.Bottom)
    _gt.BindName(optionsScr, "optionsScr");
    GUI.SetInertia(optionsScr,false)
    optionsScr:RegisterEvent(UCE.PointerClick)
    optionsScr:RegisterEvent(UCE.EndDrag)
	GUI.RegisterUIEvent(optionsScr, UCE.EndDrag , "NpcDialogUI", "OnTabBtnDrag")

end

function NpcDialogUI.InitData(parameter)
    NpcDialogUI.preNpcModelID = 0
    NpcDialogUI.QuestInfo.IsQuestTalk = false

    local str=string.split(parameter,"#cutl#")
    if #str >= 5 then
        NpcDialogUI.QuestInfo["NpcGuid"] =str[1]
        NpcDialogUI.QuestInfo["TaskId"] = str[2]
        NpcDialogUI.QuestInfo["TalkNpcId"] = str[3]
        NpcDialogUI.QuestInfo["TalkText"] = str[4]
        NpcDialogUI.QuestInfo["TalkCurIndex"] = tonumber(str[5])
        NpcDialogUI.QuestInfo.IsQuestTalk = true
    end

    NpcDialogUI.Options = NpcDialogUI.QuestInfo.IsQuestTalk and LD.GetCurQuestTalkOptions(NpcDialogUI.QuestInfo["TalkCurIndex"]) or CL.GetNpcOptionDatas()
end

--打开界面的时候调用
function NpcDialogUI.OnShow(parameter)
    local wnd = GUI.GetWnd("NpcDialogUI")
    if wnd == nil then
        return
    end

    if CL.GetFightState() then
        GUI.SetVisible(wnd, false)
        return;
    end

    GUI.SetVisible(wnd, true)
    NpcDialogUI.InitData(parameter)
    NpcDialogUI.Refesh()
    CL.RegisterMessage(GM.TeamLearderOpe,"NpcDialogUI" , "OnTeamTearderOpe")
    CL.RegisterMessage(GM.FightStateNtf, "NpcDialogUI", "OnExit")
end

function NpcDialogUI.OnDestroy()
    CL.UnRegisterMessage(GM.TeamLearderOpe,"NpcDialogUI" , "OnTeamTearderOpe")
    CL.UnRegisterMessage(GM.FightStateNtf, "NpcDialogUI", "OnExit")
end

function NpcDialogUI.OnExit()
    --隐藏
    local optionsBg = _gt.GetUI("optionsBg")
    GUI.SetVisible(optionsBg,false)

    NpcDialogUI.NeedDelayShow = true
    NpcDialogUI.DynamicOptionsTextList = {}
    NpcDialogUI.DynamicText = {}
    NpcDialogUI.DynamicOptionsGuid = nil
    if NpcDialogUI.DynamicSettingOptionsTimer then
        NpcDialogUI.DynamicSettingOptionsTimer:Stop()
        NpcDialogUI.DynamicSettingOptionsTimer = nil
    end

    GUI.CloseWnd("NpcDialogUI")
end

function NpcDialogUI.OnTeamTearderOpe(parameter)
    if parameter == nil then
        return
    end
    --只有在队伍中的队员才接收此状态更新
    if LD.GetRoleInTeamState() ~= 3 then
        return
    end

    parameter=TeamLeaderOprType.IntToEnum(tonumber(parameter))
    if parameter == TeamLeaderOprType.tlot_npctalk_sel_sub_quest
    or parameter == TeamLeaderOprType.tlot_manual_close_npctalk then
        NpcDialogUI.OnExit()
    end
end

function NpcDialogUI.Refesh()
    local npcGuid = NpcDialogUI.QuestInfo.IsQuestTalk and TOOLKIT.Str2uLong(NpcDialogUI.QuestInfo["NpcGuid"]) or CL.GetSelectNpcGuid();
    if npcGuid == nil or tostring(npcGuid) == "0" then
        NpcDialogUI.OnExit()
        return ;
    end

    local npcId = CL.GetRoleTemplateID(npcGuid)
    --有可能离开了对话
    if npcId == 0 then
        NpcDialogUI.OnExit()
        return
    end
    local npcDb = DB.GetOnceNpcByKey1(npcId);
    local nameText = _gt.GetUI("nameText");
    local npcName = CL.GetRoleName(npcGuid);
    GUI.StaticSetText(nameText, npcName)

    if npcDb.Id ~= 0 then
        local npcModel = _gt.GetUI("npcModel")
        local modelID = CL.GetIntAttr(RoleAttr.RoleAttrShape, npcGuid)
        if modelID == 0 then
            modelID = npcDb.Model
        end
        --1：role，2：npc，3：pet, 4：guard
        local npcDialogModelType = CL.GetIntCustomData("npcDialogModelType", npcGuid)
        local replaceModelID = CL.GetIntCustomData("npcDialogModelID", npcGuid)
		if npcDialogModelType == 1 then
            GUI.SetData(npcModel, "modelInfo", "")
            GUI.SetData(npcModel, "wingInfo", "")
			ModelItem.BindSelfRole(npcModel)
            GUI.StaticSetText(nameText, CL.GetRoleName())
		else
			if npcDialogModelType ~= 0 and replaceModelID ~= 0 then
				local roleModelID = 0        
				if npcDialogModelType == 2 then
					roleModelID = DB.GetOnceNpcByKey1(replaceModelID).Model
				elseif npcDialogModelType == 3 then
					roleModelID = DB.GetOncePetByKey1(replaceModelID).Model
				elseif npcDialogModelType == 4 then
					roleModelID = DB.GetOnceGuardByKey1(replaceModelID).Model
				end
				if roleModelID ~= 0 then
					modelID = roleModelID
				end
			end
			if NpcDialogUI.preNpcModelID ~= modelID then
				NpcDialogUI.preNpcModelID = modelID
				local sex = CL.GetIntAttr(RoleAttr.RoleAttrGender, npcGuid)
				local weaponId = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId, npcGuid)
                local WeaponEffect = CL.GetIntAttr(RoleAttr.RoleAttrEffect1, npcGuid)
                local Color1 =  CL.GetIntAttr(RoleAttr.RoleAttrColor1, npcGuid)
                local Color2 =  CL.GetIntAttr(RoleAttr.RoleAttrColor2, npcGuid)
                ModelItem.BindRoleWithClothAndWind(npcModel, modelID, Color1, Color2, eRoleMovement.SALUTE, weaponId, sex, WeaponEffect, npcGuid)
                ModelItem.BindRoleEquipGemEffect(npcModel, npcGuid, false)

				local avatar = SETTING.GetAvatarmodelconfig(npcDb.Model)
				if avatar then
					local resKey = avatar.ResKey
					local dialogCamera = SETTING.GetNpcdialogcamera(resKey)
					local modelCamera = _gt.GetUI("model");
					if modelCamera then
						if tostring(dialogCamera.ID)~="0" then
							GUI.RawImageSetCameraConfig(modelCamera,dialogCamera.Data)
						elseif npcDb.Model == 10 then
							GUI.RawImageSetCameraConfig(modelCamera,"(0.09119999,1.336,2.56),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,4.79,0.01,2.33,37")
						else
							GUI.RawImageSetCameraConfig(modelCamera,"(0.76,1.8,2.56),(-0.005699173,0.9774809,-0.1495397,-0.1487837),True,4.79,0.01,0.74,32")
						end
					end
				end
			end
		end
    end

    local msg = NpcDialogUI.QuestInfo.IsQuestTalk and NpcDialogUI.QuestInfo["TalkText"] or CL.GetSelectNpcMsg();
    if msg==nil or msg=="" or  tostring(msg)=="0" and npcDb.Id~=0 then
        msg = npcDb.Dialogue;
    end

    NpcDialogUI.SetContent(msg)
    local Count = NpcDialogUI.Options and NpcDialogUI.Options.Count or 0
    NpcDialogUI.SetOptions(Count)
end


function NpcDialogUI.OnAnimationCallBack(guid, action)
    if action == System.Enum.ToInt(eRoleMovement.STAND_W1) then
        return
    end

    local npcModel = _gt.GetUI("npcModel")
    GUI.ReplaceWeapon(npcModel, 0, eRoleMovement.STAND_W1, 0)
end

function NpcDialogUI.OnMaskBtnClick(guid)
    local RoleAttrIsAutoGame = CL.GetIntAttr(RoleAttr.RoleAttrIsAutoGame)
    if RoleAttrIsAutoGame == 1 then
        return
    end
	
	if NpcDialogUI.NoneOption == 1 then
		local optionBtn = _gt.GetUI("optionBtn0")
		NpcDialogUI.OnOptionBtnClick(GUI.GetGuid(optionBtn))
	end
	
    NpcDialogUI.OnExit()
    --队长同步状态
    if LD.GetRoleInTeamState() == 2 then
        CL.SendNotify(NOTIFY.TeamLearderOpeReq,4)
    end
end

function NpcDialogUI.CreatOptionsPool()
    local optionsScr = GUI.GetByGuid(_gt.optionsScr);
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(optionsScr);
    local optionBtn = GUI.ButtonCreate(optionsScr, "optionBtn" .. curCount, "1800602010", 0, 0, Transition.ColorTint);
    GUI.ButtonSetTextColor(optionBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(optionBtn, UIDefine.FontSizeL);
    GUI.RegisterUIEvent(optionBtn, UCE.PointerClick, "NpcDialogUI", "OnOptionBtnClick");
	_gt.BindName(optionBtn, "optionBtn"..tostring(curCount))

    local icon = GUI.ImageCreate(optionBtn, "icon", "1800607040", 0, 2, false, 34, 34)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Center)
    GUI.SetIsRaycastTarget(icon, false)
    return optionBtn;
end

function NpcDialogUI.OnOptionBtnClick(guid)
    local RoleAttrIsAutoGame = CL.GetIntAttr(RoleAttr.RoleAttrIsAutoGame)
    if RoleAttrIsAutoGame == 1 then
        return
    end

    local optionBtn = GUI.GetByGuid(guid);
    local optionId = tonumber(GUI.GetData(optionBtn, "OptionId"));

    --队长同步状态
    if LD.GetRoleInTeamState() == 2 then
        CL.SendNotify(NOTIFY.TeamLearderOpeReq,6)
    end
    NpcDialogUI.OnExit()
    if NpcDialogUI.QuestInfo.IsQuestTalk then
        CL.SendNotify(NOTIFY.QuestOpeUpdate, 3, optionId)
    else
        CL.SendNotify(NOTIFY.NpcDialogReply, optionId)
    end
end

function NpcDialogUI.RefreshOptionsScr(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local optionBtn = GUI.GetByGuid(guid);

    if index >= NpcDialogUI.Options.Count then
        return
    end

    test("index="..index..",NpcDialogUI.Options.Count="..NpcDialogUI.Options.Count-1)
    --延迟显示，排列完再显示
	if not NpcDialogUI.NoneOption or NpcDialogUI.NoneOption ~= 1 then
        --小于3个情况：最后一个时触发。 大于3个情况，因最多显示3个，在第3个时候触发
        if (NpcDialogUI.Options.Count <= 3 and  index == NpcDialogUI.Options.Count-1) or  (NpcDialogUI.Options.Count > 3 and  index == 2) then
            if NpcDialogUI.NeedDelayShow == true then
                NpcDialogUI.NeedDelayShow = false
                test("delay show")
                local optionsBg = _gt.GetUI("optionsBg")
                Timer.New(function ()
                    GUI.SetVisible(optionsBg,true)
                end,0.1):Start()
            end
        end
	end
  
    local data =  NpcDialogUI.Options[index]

    if string.find(data.text,"#") then
        NpcDialogUI.DynamicSettingOptionsText(optionBtn, data.text)
    else
        GUI.ButtonSetText(optionBtn, data.text)
    end
    GUI.SetData(optionBtn, "OptionId", data.id)
    local optionIcon = GUI.GetChild(optionBtn, "icon")
    if optionIcon then
        if data.mark == 1 then
            GUI.ImageSetImageID(optionIcon,"1800607040")
        elseif data.mark == 2 then
            GUI.ImageSetImageID(optionIcon,"1800607030")
        elseif data.mark == 3 then
            GUI.ImageSetImageID(optionIcon,"1800607040")
        elseif data.mark == 4 then
            GUI.ImageSetImageID(optionIcon,"1800607010")
        elseif data.mark == 5 then
            GUI.ImageSetImageID(optionIcon,"1800607020")
        end
        local txtLength = string.len(data.text)
        local isShow = data.mark>=1 and data.mark <= 5 and txtLength>0
        GUI.SetVisible(optionIcon,isShow)
        if isShow then
            GUI.SetPositionX(optionIcon, -4 * txtLength - 21)
        end
    end
end

function NpcDialogUI.OnTabBtnDrag(guid)
	test("进了吗")
	local optionsScr = GUI.GetByGuid(_gt.optionsScr)
	local count = GUI.LoopScrollRectGetTotalCount(optionsScr)
    local x,y = GUI.GetNormalizedPosition(optionsScr):Get()

    local upArrow = GUI.GetByGuid(_gt.upArrow);
    local downArrow = GUI.GetByGuid(_gt.downArrow);
    GUI.SetVisible(upArrow, count > 3 and y ~= 1);
    GUI.SetVisible(downArrow, count > 3 and y ~= 0);
end

local FucDynamicSettingOptionsText = function ()
    local optionBtn = GUI.GetByGuid(NpcDialogUI.DynamicOptionsGuid)
    local second = tonumber(NpcDialogUI.DynamicText[2])
    local text = ""
    second = second - 1
    NpcDialogUI.DynamicText[2] = tostring(second)
    if second <= 0 then
        NpcDialogUI.DynamicSettingOptionsTimer:Stop()
        text = NpcDialogUI.DynamicOptionsTextList[2]
    else
        text = string.format(NpcDialogUI.DynamicText[3],second)
    end
    GUI.ButtonSetText(optionBtn, text)
end
function NpcDialogUI.DynamicSettingOptionsText(optionBtn,text)
    test(text)
    NpcDialogUI.DynamicOptionsGuid = GUI.GetGuid(optionBtn)
    local textList = string.split(text,"#")
    for i = 1, #textList, 1 do
        if textList[i] ~= "" then
            table.insert(NpcDialogUI.DynamicOptionsTextList,textList[i])
            if string.find(textList[i],"-") then
                NpcDialogUI.DynamicText = string.split(textList[i],"-")
                local text = string.format(NpcDialogUI.DynamicText[3],tonumber(NpcDialogUI.DynamicText[2]))
                GUI.ButtonSetText(optionBtn, text)
            end
        end
    end
    if NpcDialogUI.DynamicText[1] == "second" then
        NpcDialogUI.DynamicSettingOptionsTimer = Timer.New(FucDynamicSettingOptionsText,1,-1)
    end
    NpcDialogUI.DynamicSettingOptionsTimer:Start()
end
function NpcDialogUI.SetOptions(count)
	
	NpcDialogUI.NoneOption = 0
    local optionsBg = _gt.GetUI("optionsBg")
    local optionsScr = _gt.GetUI("optionsScr")
    local upArrow = _gt.GetUI("upArrow")
    local downArrow = _gt.GetUI("downArrow")

    if count == 0 then
        GUI.SetVisible(optionsBg, false);
        return ;
    end

	if count == 1 then
		local data = NpcDialogUI.Options[0]
		if data.text == "*None*" then
			GUI.SetVisible(optionsBg, false);
			NpcDialogUI.NoneOption = 1
		else
			--GUI.SetVisible(optionsBg, true);
		end
	else
		--GUI.SetVisible(optionsBg, true);
	end
    
	
    if count <= 3 then
        GUI.SetHeight(optionsScr, 60 * count);
        GUI.SetHeight(optionsBg, 80 + 60 * count);
        GUI.SetPositionY(optionsScr, 15);
        GUI.SetVisible(upArrow, false);
        GUI.SetVisible(downArrow, false);
    else
        GUI.SetHeight(optionsScr, 180);
        GUI.SetHeight(optionsBg, 305);
        GUI.SetPositionY(optionsScr, 35);
        GUI.SetVisible(upArrow, false);
        GUI.SetVisible(downArrow, true);
    end

    GUI.LoopScrollRectSetTotalCount(optionsScr, count);
    GUI.LoopScrollRectRefreshCells(optionsScr);
    GUI.ScrollRectSetNormalizedPosition(optionsScr, Vector2.New(0, 0));
end

function NpcDialogUI.SetContent(msg)

    local textScr = _gt.GetUI("textScr")
    local content = _gt.GetUI("content")

    GUI.StaticSetText(content, msg)
    local h = GUI.RichEditGetPreferredHeight(content)
    GUI.ScrollRectSetChildSize(textScr, Vector2.New(contentWidth, h))
    if h>=130 then
        GUI.ScrollRectSetChildAnchor(textScr, UIAnchor.Top)
        GUI.ScrollRectSetChildPivot(textScr, UIAroundPivot.Top)
    else
        GUI.ScrollRectSetChildAnchor(textScr, UIAnchor.Center)
        GUI.ScrollRectSetChildPivot(textScr, UIAroundPivot.Center)
    end
    GUI.ScrollRectSetNormalizedPosition(textScr, Vector2.New(0,0))
end