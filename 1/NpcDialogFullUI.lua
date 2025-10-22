NpcDialogFullUI={}
--计算与Npc的距离
NpcDialogFullUI.DistanceTimer = nil
NpcDialogFullUI.PlayMovie = true
NpcDialogFullUI.SkipMovie = false
NpcDialogFullUI.PanelClickController = true
NpcDialogFullUI.PreRoleID = nil
NpcDialogFullUI.PreRolePosLeft = false
NpcDialogFullUI.PreIsSelfModel = false
NpcDialogFullUI.SelfInTeamState = 0
NpcDialogFullUI.DelayCloseWndTimer = nil
NpcDialogFullUI.AutoSkipTimer = nil
NpcDialogFullUI.AutoSkipEndTime = 0
local AUTO_SKIP_WAIT_TIME = 1

local _gt = UILayout.NewGUIDUtilTable()
local scrHeight=130
local playAnimTime=0.5
--对话有效距离
local talkEffectiveDistance = 30
--队员对话有效距离
local talkEffectiveDistance_Member = 20

function NpcDialogFullUI.Main( parameter )
	_gt = UILayout.NewGUIDUtilTable()
	local panel= GUI.WndCreateWnd("NpcDialogFullUI" , "NpcDialogFullUI" , 0 , 0 ,eCanvasGroup.Movie)
    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)

	local w = GUI.GetWidth(panel)
	local h = GUI.GetHeight(panel)
	local fullScreenBtn=GUI.ButtonCreate( panel, "fullScreenBtn" , "1800600010" , 0 , 0 ,Transition.ColorTint,"", w, h,false)
	GUI.SetColor(fullScreenBtn,UIDefine.Transparent)
	GUI.RegisterUIEvent(fullScreenBtn , UCE.PointerClick , "NpcDialogFullUI", "OnFullScreenBtnClick" )
	fullScreenBtn:RegisterEvent(UCE.PointerUp )
	fullScreenBtn:RegisterEvent(UCE.PointerDown )
	GUI.RegisterUIEvent(fullScreenBtn , UCE.PointerUp , "NpcDialogFullUI","BottomMovieBgPointUp")
	GUI.RegisterUIEvent(fullScreenBtn , UCE.PointerDown , "NpcDialogFullUI","BottomMovieBgPointDown")

	NpcDialogFullUI["TopMovieBg"]=GUI.ImageCreate(panel,"topMovieBg","1800600420",0,-410,false,w,104)
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["TopMovieBg"], UILayout.Top)

	local clickTips=GUI.ImageCreate(NpcDialogFullUI["TopMovieBg"],"clickTips","1800604650",35,50)
    UILayout.SetSameAnchorAndPivot(clickTips, UILayout.TopLeft)

	NpcDialogFullUI["BottomMovieBg"]=GUI.ImageCreate(panel,"bottomMovieBg","1800600430",0,410,false,w,209)
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["BottomMovieBg"], UILayout.Bottom)

	NpcDialogFullUI["ModelGrop"] = GUI.GroupCreate(NpcDialogFullUI["BottomMovieBg"], "modelGrop",0 ,0 ,400,400)
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["ModelGrop"], UILayout.BottomLeft)

	NpcDialogFullUI["ModelGropCamera"] = GUI.RawImageCreate(NpcDialogFullUI["ModelGrop"], false, "model", "", 0, 0, 2, false, 800, 400, 2)
	_gt.BindName(NpcDialogFullUI["ModelGropCamera"], "model");
	NpcDialogFullUI["ModelGropCamera"]:RegisterEvent(UCE.Drag)
	UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["ModelGropCamera"], UILayout.BottomLeft)
	GUI.AddCameraCullingMask(NpcDialogFullUI["ModelGropCamera"],eLayer.RoleImage4)
	GUI.AddToCamera(NpcDialogFullUI["ModelGropCamera"])
	GUI.SetIsRaycastTarget(NpcDialogFullUI["ModelGropCamera"],false)

	-- local autoSkipCheck = GUI.CheckBoxCreate(NpcDialogFullUI["TopMovieBg"] ,"autoSkipCheck", "1800607150", "1800607151", -164, 13, Transition.None, false, 38, 38)
	-- _gt.BindName(autoSkipCheck,"autoSkipCheck")
	-- UILayout.SetSameAnchorAndPivot(autoSkipCheck, UILayout.TopRight)
	-- GUI.RegisterUIEvent(autoSkipCheck, UCE.PointerClick , "NpcDialogFullUI", "OnAutoSkipCheck")

	-- local autoSkipTip = GUI.CreateStatic(NpcDialogFullUI["TopMovieBg"], "autoSkipTip", "自动跳过剧情", 9,12,200,38,"103")
	-- UILayout.StaticSetFontSizeColorAlignment(autoSkipTip, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
	-- UILayout.SetSameAnchorAndPivot(autoSkipTip, UILayout.TopRight)
	-- GUI.StaticSetIsGradientColor(autoSkipTip,true)
	-- GUI.StaticSetGradient_ColorTop(autoSkipTip,Color.New(341/255,238/255,249/255,255/255))
	-- GUI.StaticSetGradient_ColorBottom(autoSkipTip,Color.New(231/255,180/255,32/255,255/255))
	-- GUI.SetIsOutLine(autoSkipTip,true)
	-- GUI.SetOutLine_Setting(autoSkipTip,OutLineSetting.OutLine_NpcDialogFullTip)
	-- GUI.SetOutLine_Distance(autoSkipTip,3)
	-- GUI.SetOutLine_Color(autoSkipTip,Color.New(180/255,70/255,18/255,255/255))
	-- autoSkipTip:RegisterEvent(UCE.PointerClick)
	-- GUI.SetIsRaycastTarget(autoSkipTip, true)
	-- GUI.RegisterUIEvent(autoSkipTip, UCE.PointerClick , "NpcDialogFullUI", "OnAutoSkipTipCheck")

	local SkipBtnTxt =GUI.CreateStatic(NpcDialogFullUI["TopMovieBg"], "SkipBtnTxt", "点击此处跳过剧情", -13,38,200,50,"103")
	UILayout.SetSameAnchorAndPivot(SkipBtnTxt, UILayout.TopRight)
	GUI.StaticSetAlignment(SkipBtnTxt, TextAnchor.UpperCenter)
	GUI.StaticSetFontSize(SkipBtnTxt,UIDefine.FontSizeM)
	GUI.StaticSetIsGradientColor(SkipBtnTxt,true)
	GUI.StaticSetGradient_ColorTop(SkipBtnTxt,Color.New(341/255,238/255,249/255,255/255))
	GUI.StaticSetGradient_ColorBottom(SkipBtnTxt,Color.New(231/255,180/255,32/255,255/255))
	GUI.SetIsOutLine(SkipBtnTxt,true)
	GUI.SetOutLine_Setting(SkipBtnTxt,OutLineSetting.OutLine_NpcDialogFullTip)
	GUI.SetOutLine_Distance(SkipBtnTxt,3)
	GUI.SetOutLine_Color(SkipBtnTxt,Color.New(180/255,70/255,18/255,255/255))
	SkipBtnTxt:RegisterEvent(UCE.PointerClick)
	GUI.SetIsRaycastTarget(SkipBtnTxt, true)
	NpcDialogFullUI["skipBtnTxt"] = SkipBtnTxt
	GUI.RegisterUIEvent(SkipBtnTxt, UCE.PointerClick , "NpcDialogFullUI", "OnSkipTalkBtnClick")

	NpcDialogFullUI["nameBg"]=GUI.ImageCreate( NpcDialogFullUI["BottomMovieBg"], "nameBg" , "1800600440" , 49 , 0 )
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["nameBg"], UILayout.BottomLeft)
	GUI.SetIsRaycastTarget(NpcDialogFullUI["nameBg"],false)

	NpcDialogFullUI["NameTxtUI"]=GUI.CreateStatic(NpcDialogFullUI["nameBg"], "name", "", 0,0,500,440,"system",true)
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["NameTxtUI"], UILayout.Center)
	GUI.StaticSetFontSize(NpcDialogFullUI["NameTxtUI"],UIDefine.FontSizeM)
	GUI.SetColor(NpcDialogFullUI["NameTxtUI"],UIDefine.Brown6Color)
	GUI.StaticSetAlignment(NpcDialogFullUI["NameTxtUI"], TextAnchor.MiddleCenter)
	GUI.SetIsRaycastTarget(NpcDialogFullUI["NameTxtUI"],false)

	NpcDialogFullUI["TalkTxtScr"]=GUI.ScrollRectCreate(NpcDialogFullUI["BottomMovieBg"],"txtScr",150,-20,760,scrHeight,0,false,Vector2.New(760,200),UIAroundPivot.Center,UIAnchor.Center)
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["TalkTxtScr"], UILayout.Center)
	GUI.SetDepth(NpcDialogFullUI["TalkTxtScr"],0)
	NpcDialogFullUI["TalkTxtScr"]:RegisterEvent(UCE.PointerClick)
	GUI.RegisterUIEvent(NpcDialogFullUI["TalkTxtScr"],UCE.PointerClick,"NpcDialogFullUI","OnTxtScrClick")

	NpcDialogFullUI["TalkTxt"] = GUI.RichEditCreate(NpcDialogFullUI["TalkTxtScr"],"txt","",0,0,760,26,"system",true)
	GUI.StaticSetFontSize(NpcDialogFullUI["TalkTxt"],UIDefine.FontSizeL)
	GUI.SetIsRaycastTarget(NpcDialogFullUI["TalkTxt"],false)

	--#CL.RegisterMessage(GM.InFight,"NpcDialogFullUI" , "InFight")
	CL.RegisterMessage(GM.TeamLearderOpe,"NpcDialogFullUI" , "OnTeamTearderOpe")
	CL.RegisterMessage(GM.FightStateNtf,"NpcDialogFullUI" , "OnFightStateNtf")

    NpcDialogFullUI.DistanceTimer = Timer.New(NpcDialogFullUI.CalcuDistance,playAnimTime,-1)
end

function NpcDialogFullUI.OnDestroy()
	GUI.Destroy(NpcDialogFullUI["selfModel"])
	GUI.Destroy(NpcDialogFullUI["npcModel"])
    NpcDialogFullUI["selfModel"] = nil
    NpcDialogFullUI["npcModel"] = nil
	NpcDialogFullUI["TopMovieBg"] = nil

	CL.UnRegisterMessage(GM.TeamLearderOpe,"NpcDialogFullUI" , "OnTeamTearderOpe")
	CL.UnRegisterMessage(GM.FightStateNtf,"NpcDialogFullUI" , "OnFightStateNtf")
end

function NpcDialogFullUI.OnFightStateNtf()
	NpcDialogFullUI.DelayCloseWnd()
end

function NpcDialogFullUI.BottomMovieBgPointUp()
	GUI.SetColor(NpcDialogFullUI["BottomMovieBg"], UIDefine.WhiteColor)
end

function NpcDialogFullUI.BottomMovieBgPointDown()
	GUI.SetColor(NpcDialogFullUI["BottomMovieBg"], UIDefine.Gray3Color)
end

--计算距离
function NpcDialogFullUI.CalcuDistance( ... )
	if GUI.GetVisible(GUI.GetWnd("NpcDialogFullUI")) then
		if NpcDialogFullUI["NpcGuid"] ~= nil then
			local dis = CL.GetRoleDistance(NpcDialogFullUI["NpcGuid"])
			local tmpDis
			if NpcDialogFullUI.SelfInTeamState == 3 then
				tmpDis =talkEffectiveDistance_Member
			else
				tmpDis = talkEffectiveDistance
			end
			if dis < tmpDis then
				return
			end
			print("距离太远，关闭剧情对话-------------------:"..dis)
            if NpcDialogFullUI.SelfInTeamState == 2 then
                NpcDialogFullUI.SendTeamNotify(3)
            end
			NpcDialogFullUI.StopMovie()
			NpcDialogFullUI.CloseWnd()
		end
	end
end

function NpcDialogFullUI.InFight( ... )
	local panel=GUI.GetWnd("NpcDialogFullUI")
	if panel ~= nil and GUI.GetVisible(panel) then
		test("InFight 关闭界面-------------------------")
		NpcDialogFullUI.CloseWnd()
	end
end


-- function NpcDialogFullUI.OnAutoSkipTipCheck()
	-- local check = _gt.GetUI("autoSkipCheck")
	-- if check then
		-- local isCheck = GUI.CheckBoxGetCheck(check)
		-- GUI.CheckBoxSetCheck(check, not isCheck)
		-- GUI.SetVisible(NpcDialogFullUI["skipBtnTxt"], isCheck)
		-- NpcDialogFullUI.OnAutoSkipCheck()
	-- end
-- end

-- function NpcDialogFullUI.OnAutoSkipCheck()
	-- local check = _gt.GetUI("autoSkipCheck")
	-- if check then
		-- local isCheck = GUI.CheckBoxGetCheck(check)
		-- local userKey = NpcDialogFullUI.GetDialogAutoSkipSaveKey()
		-- if isCheck then
			-- CL.SetUserOperateRecord(userKey,"1")
			-- NpcDialogFullUI.StartAutoSkipTimer()
		-- else
			-- CL.SetUserOperateRecord(userKey,"0")
			-- NpcDialogFullUI.StopAutoSkipTimer()
		-- end
	-- end
-- end

function NpcDialogFullUI.OnSkipTalkBtnClick()
	if NpcDialogFullUI.SelfInTeamState == 3 then
		return
	end

	if NpcDialogFullUI.SkipMovie then
		return
	end

	if not NpcDialogFullUI.PanelClickController then
		return
	end

	NpcDialogFullUI.PanelClickController = false
	if NpcDialogFullUI.SelfInTeamState == 2 then
		NpcDialogFullUI.SendTeamNotify(10)
	end
	local Info = LD.GetLastOptionsIfNotNull()
	if Info==nil or string.len(Info)==0 then
		NpcDialogFullUI.OnCloseByTween()
		CL.SendNotify(NOTIFY.QuestOpeUpdate,3,-1)
	else
		--打开NPC选项对白面板
		GUI.OpenWnd("NpcDialogUI", Info)
		--有选项，则打开NpcDiglogUI,关闭本界面
		NpcDialogFullUI.CloseWnd()
	end
end

function NpcDialogFullUI.OnClose()
	NpcDialogFullUI.StopAutoSkipTimer()
	MainUI.OnMovieDialogFinish(true)
end

function NpcDialogFullUI.OnShow(parameter,update)
	if parameter == nil then
		return
	end

	local panel=GUI.GetWnd("NpcDialogFullUI")
	if panel ==nil then
		return
	end

	NpcDialogFullUI.PanelClickController = true
	NpcDialogFullUI.SkipMovie = false
	NpcDialogFullUI.PlayMovie = true
	if update == nil or update == false then
		NpcDialogFullUI.InitData()
		GUI.SetCameraLayer(eLayer.Movie)
	end
	if CL.GetFightState() then
		NpcDialogFullUI.InFight( )
		return
	end
	NpcDialogFullUI.SelfInTeamState = LD.GetRoleInTeamState()
	NpcDialogFullUI.SplitParameter( parameter )
	NpcDialogFullUI.CreateModel()
	NpcDialogFullUI.CreateTalkTxt()
	if update == nil or update == false then
		GUI.SetVisible(panel, true)
		NpcDialogFullUI.SlideIn()
        NpcDialogFullUI.DistanceTimer:Start()
	end
	NpcDialogFullUI.InitAutoSkipCheck()
end


function NpcDialogFullUI.InitAutoSkipCheck()
	-- local check = _gt.GetUI("autoSkipCheck")
	-- if check then
		-- local userKey = NpcDialogFullUI.GetDialogAutoSkipSaveKey()
		-- local val = CL.GetUserOperateRecord(userKey)
		-- local isAutoSkip = val == "1"
		-- GUI.CheckBoxSetCheck(check, isAutoSkip)
		-- if isAutoSkip then
			-- NpcDialogFullUI.StartAutoSkipTimer()
		-- end
		-- --GUI.SetVisible(NpcDialogFullUI["skipBtnTxt"], not isAutoSkip)
	-- end
	
	local isAutoSkip = LD.GetSystemSettingValue(SystemSettingOption.AutoClickSkipNpcDialog) == 1
	if isAutoSkip then
		NpcDialogFullUI.StartAutoSkipTimer()
	end
end

function NpcDialogFullUI.StartAutoSkipTimer()
	NpcDialogFullUI.AutoSkipEndTime = Time.time + AUTO_SKIP_WAIT_TIME
	NpcDialogFullUI.AutoSkipTimer = Timer.New(NpcDialogFullUI.AutoSkipTimerLoop, 0.2, -1)
	NpcDialogFullUI.AutoSkipTimer:Start()
end

function NpcDialogFullUI.StopAutoSkipTimer()
	if NpcDialogFullUI.AutoSkipTimer ~= nil then
		NpcDialogFullUI.AutoSkipTimer:Stop()
		NpcDialogFullUI.AutoSkipTimer = nil
	end
	NpcDialogFullUI.AutoSkipEndTime = 0
end

function NpcDialogFullUI.AutoSkipTimerLoop()
	if NpcDialogFullUI.AutoSkipEndTime ~= 0 and Time.time >= NpcDialogFullUI.AutoSkipEndTime then
		NpcDialogFullUI.AutoSkipEndTime = 0
		NpcDialogFullUI.OnSkipTalkBtnClick()
	end
end

--获取真正的文本（解析名字、表情）
function NpcDialogFullUI.GetRealText( txt )
    if string.find(txt,"%$name%$") ~= nil then
        local roleName = CL.GetRoleName()
        txt = string.gsub(txt,"%$name%$","<color=#5aff6a>"..roleName.."</color>")
    end
    return txt
end

--参数拆分
function NpcDialogFullUI.SplitParameter( parameter )
	local str=string.split(parameter,"#cutl#")
	if #str >=4 then
		NpcDialogFullUI["NpcGuid"] = TOOLKIT.Str2uLong(str[1])
		NpcDialogFullUI["TalkQuestID"] = str[2]
		NpcDialogFullUI["TalkNpcId"] = str[3]
		NpcDialogFullUI["TalkText"] = NpcDialogFullUI.GetRealText( str[4] )
	end
end

function NpcDialogFullUI.InitData( ... )
	NpcDialogFullUI["NpcGuid"] = nil
	NpcDialogFullUI["TalkQuestID"] = nil
	NpcDialogFullUI["TalkNpcId"] = nil
	NpcDialogFullUI["TalkText"] = nil
	NpcDialogFullUI["LastNpcModelId"] = nil
end

function NpcDialogFullUI.CreateTalkTxt( ... )
	GUI.StaticSetText(NpcDialogFullUI["TalkTxt"],NpcDialogFullUI["TalkText"])
	local height=GUI.RichEditGetPreferredHeight(NpcDialogFullUI["TalkTxt"])
	GUI.SetHeight(NpcDialogFullUI["TalkTxt"],height)
	GUI.ScrollRectSetChildSize(NpcDialogFullUI["TalkTxtScr"],Vector2.New(760,height))
	if height > scrHeight then
		GUI.ScrollRectSetChildPivot(NpcDialogFullUI["TalkTxtScr"],UIAroundPivot.Top)
	else
		GUI.ScrollRectSetChildPivot(NpcDialogFullUI["TalkTxtScr"],UIAroundPivot.Center)
	end
	GUI.ScrollRectSetNormalizedPosition(NpcDialogFullUI["TalkTxtScr"],Vector2.New(0,1))
end

--开始播放npc剧情对话
function NpcDialogFullUI.SlideIn( ... )
	if NpcDialogFullUI.PlayMovie then
		GUI.DOTween(NpcDialogFullUI["TopMovieBg"],"NPCTalkMovie")
		GUI.DOTween(NpcDialogFullUI["BottomMovieBg"],"NPCTalkMovie")
		NpcDialogFullUI.PlayMovie = false
	end
end

--开始停止npc剧情对话(带有tween动画)
function NpcDialogFullUI.SlideOut( ... )
	if NpcDialogFullUI["TopMovieBg"] then
		GUI.DOTween(NpcDialogFullUI["TopMovieBg"],"NPCTalkMovieBack")
		GUI.DOTween(NpcDialogFullUI["BottomMovieBg"],"NPCTalkMovieBack")
	end
end

--立即停止npc剧情对话（立即结束tween动画）
function NpcDialogFullUI.StopMovie( ... )
	if NpcDialogFullUI["TopMovieBg"] then
		GUI.StopTween(NpcDialogFullUI["TopMovieBg"],"NPCTalkMovie")
		GUI.StopTween(NpcDialogFullUI["BottomMovieBg"],"NPCTalkMovie")
		GUI.StopTween(NpcDialogFullUI["TopMovieBg"],"NPCTalkMovieBack")
		GUI.StopTween(NpcDialogFullUI["BottomMovieBg"],"NPCTalkMovieBack")
		GUI.SetPositionY(NpcDialogFullUI["TopMovieBg"],-410)
		GUI.SetPositionY(NpcDialogFullUI["BottomMovieBg"],-410)
	end
end

--150到-150，1000
function NpcDialogFullUI.SwitchModelPos(showInLeft)
	if showInLeft then
		GUI.SetPositionX(NpcDialogFullUI["TalkTxtScr"],150)
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["ModelGrop"], UILayout.BottomLeft)
		GUI.SetPositionX(NpcDialogFullUI["ModelGrop"],-220)
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["nameBg"], UILayout.BottomLeft)
		GUI.SetPositionX(NpcDialogFullUI["nameBg"],49)
	else
		GUI.SetPositionX(NpcDialogFullUI["TalkTxtScr"],-150)
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["ModelGrop"], UILayout.BottomRight)
		GUI.SetPositionX(NpcDialogFullUI["ModelGrop"],128)
    UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["nameBg"], UILayout.BottomRight)
		GUI.SetPositionX(NpcDialogFullUI["nameBg"],69)
	end
end

function NpcDialogFullUI.CreateModel( ... )
	local isNpc = true
	local id = 0
	local modelID = 0
	local otherNpc=nil
	local gender = nil
	local weapon = nil
	local resKey = ""

	if NpcDialogFullUI["TalkNpcId"] ~= nil then
		if NpcDialogFullUI["TalkNpcId"] == "0" then
			isNpc = false
			id = CL.GetRoleTemplateID()
			local role = DB.GetRole(id)
			if role ~= nil then
				modelID = role.Model
			end
			gender = CL.GetIntAttr(RoleAttr.RoleAttrGender)
			weapon = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId)
		elseif NpcDialogFullUI["TalkNpcId"] == "1" then
			--类型1，则按GUID取出就近玩家角色的数据
			local roleID = CL.GetIntAttr(RoleAttr.RoleAttrRole, NpcDialogFullUI["NpcGuid"])
			local shapeID = CL.GetIntAttr(RoleAttr.RoleAttrShape, NpcDialogFullUI["NpcGuid"])
			if shapeID == 0 then
				local role = DB.GetRole(roleID)
				if role.Id ~= 0 then
					modelID = role.Model
				end
			else
				modelID = shapeID
			end
			gender = CL.GetIntAttr(RoleAttr.RoleAttrGender, NpcDialogFullUI["NpcGuid"])
			weapon = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId, NpcDialogFullUI["NpcGuid"])
		else
			id = tonumber(NpcDialogFullUI["TalkNpcId"])
			otherNpc = DB.GetOnceNpcByKey1(id)
			if otherNpc ~= nil then
				modelID = otherNpc.Model
			end
		end
	end

	if id ~= nil then
		--加入对白模型左右位置轮换效果：上一次模型与本次不同则切换到另一边
		if NpcDialogFullUI.PreRoleID == nil then
			NpcDialogFullUI.PreRoleID = id
			NpcDialogFullUI.PreRolePosLeft = true
			NpcDialogFullUI.PreIsSelfModel = (isNpc == false)
		end
		if isNpc == false then
			--玩家自己
			if NpcDialogFullUI.PreIsSelfModel then
				NpcDialogFullUI.SwitchModelPos(NpcDialogFullUI.PreRolePosLeft)
			else
				if NpcDialogFullUI.PreRolePosLeft then
					NpcDialogFullUI.PreRolePosLeft = false
				else
					NpcDialogFullUI.PreRolePosLeft = true
				end
				NpcDialogFullUI.SwitchModelPos(NpcDialogFullUI.PreRolePosLeft)
			end
			NpcDialogFullUI.PreIsSelfModel = true
		else
			--NPC
			if NpcDialogFullUI.PreIsSelfModel or NpcDialogFullUI.PreRoleID ~= id then
				if NpcDialogFullUI.PreRolePosLeft then
					NpcDialogFullUI.PreRolePosLeft = false
				else
					NpcDialogFullUI.PreRolePosLeft = true
				end
			end
			NpcDialogFullUI.SwitchModelPos(NpcDialogFullUI.PreRolePosLeft)
			NpcDialogFullUI.PreRoleID = id
			NpcDialogFullUI.PreIsSelfModel = false
		end

		local avatar = SETTING.GetAvatarmodelconfig(modelID)
		if avatar then
			resKey = avatar.ResKey
		end

		if isNpc == false then
			--玩家本身模型
			if NpcDialogFullUI["npcModel"] ~= nil then
				GUI.SetVisible(NpcDialogFullUI["npcModel"],false)
			end
			GUI.StaticSetText(NpcDialogFullUI["NameTxtUI"],CL.GetRoleName())
			if NpcDialogFullUI["selfModel"] == nil then
				NpcDialogFullUI["selfModel"]=GUI.RawImageChildCreate(NpcDialogFullUI["ModelGropCamera"],true,"roleModel_selfModel",modelID,-10,2)
				UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["selfModel"], UILayout.BottomLeft)
				GUI.SetIsRaycastTarget(NpcDialogFullUI["selfModel"],false)
			end
			GUI.SetVisible(NpcDialogFullUI["selfModel"],true)
			ModelItem.BindSelfRole(NpcDialogFullUI["selfModel"], eRoleMovement.STAND_W1)

			local dialogCamera = SETTING.GetNpcdialogcamera(resKey)
			if tostring(dialogCamera.ID)~="0" then
				GUI.RawImageSetCameraConfig(NpcDialogFullUI["ModelGropCamera"],dialogCamera.Data)
			elseif modelID == 10 then
				GUI.RawImageSetCameraConfig(NpcDialogFullUI["ModelGropCamera"],"(0.09119999,1.336,2.56),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,4.79,0.01,2.33,37")
			else
				GUI.RawImageSetCameraConfig(NpcDialogFullUI["ModelGropCamera"],"(0.928,1.7792,2.736),(0.004423198,-0.978643,0.141439,0.1491086),True,4.79,0.01,0.55,32")
			end
			NpcDialogFullUI["LastRoleModelId"] = modelID
		else
			--创建/刷新Npc模型
			if NpcDialogFullUI["selfModel"] ~= nil then
				GUI.SetVisible(NpcDialogFullUI["selfModel"],false)
			end
			local Color1 = CL.GetIntAttr(RoleAttr.RoleAttrColor1, NpcDialogFullUI["NpcGuid"])
			local Color2 = CL.GetIntAttr(RoleAttr.RoleAttrColor2, NpcDialogFullUI["NpcGuid"])
			if otherNpc ~= nil then
				GUI.StaticSetText(NpcDialogFullUI["NameTxtUI"],otherNpc.Name)
				Color1 = 0
				Color2 = otherNpc.ColorId
			else
				GUI.StaticSetText(NpcDialogFullUI["NameTxtUI"],CL.GetRoleName(NpcDialogFullUI["NpcGuid"]))
			end

			if NpcDialogFullUI["LastNpcModelId"] ~= modelID then
				gender = CL.GetIntAttr(RoleAttr.RoleAttrGender, NpcDialogFullUI["NpcGuid"])
				weapon = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId, NpcDialogFullUI["NpcGuid"])
				local WeaponEffect = CL.GetIntAttr(RoleAttr.RoleAttrEffect1, NpcDialogFullUI["NpcGuid"])

				if NpcDialogFullUI["npcModel"] == nil then
					NpcDialogFullUI["npcModel"] = GUI.RawImageChildCreate(NpcDialogFullUI["ModelGropCamera"], true, "roleModel", modelID, -10,2)
					UILayout.SetSameAnchorAndPivot(NpcDialogFullUI["npcModel"], UILayout.BottomLeft)
					GUI.SetIsRaycastTarget(NpcDialogFullUI["npcModel"],false)
				end
				GUI.SetVisible(NpcDialogFullUI["npcModel"],true)
				ModelItem.BindRoleWithClothAndWind(NpcDialogFullUI["npcModel"], modelID, Color1, Color2, eRoleMovement.STAND_W1, weapon, gender, WeaponEffect, NpcDialogFullUI["NpcGuid"])
				ModelItem.BindRoleEquipGemEffect(NpcDialogFullUI["npcModel"], NpcDialogFullUI["NpcGuid"])
			else
				GUI.SetVisible(NpcDialogFullUI["npcModel"],true)
			end

			local dialogCamera = SETTING.GetNpcdialogcamera(resKey)
			if tostring(dialogCamera.ID)~="0" then
				GUI.RawImageSetCameraConfig(NpcDialogFullUI["ModelGropCamera"],dialogCamera.Data)
			elseif modelID == 10 then
				GUI.RawImageSetCameraConfig(NpcDialogFullUI["ModelGropCamera"],"(0.09119999,1.336,2.56),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,4.79,0.01,2.33,37")
			else
				GUI.RawImageSetCameraConfig(NpcDialogFullUI["ModelGropCamera"],"(0.76,1.8,2.56),(-0.005699173,0.9774809,-0.1495397,-0.1487837),True,4.79,0.01,0.74,32")
			end
			NpcDialogFullUI["LastNpcModelId"] = modelID
		end
	end
end

function NpcDialogFullUI.OnTxtScrClick( ... )
	NpcDialogFullUI.OnFullScreenBtnClick( )
end

function NpcDialogFullUI.OnFullScreenBtnClick( ... )
	if NpcDialogFullUI.PanelClickController == false then
		return
	end

	NpcDialogFullUI.PanelClickController = false
	if NpcDialogFullUI.SelfInTeamState ~= 3 then
		local Info = nil
		--下一句对白有选项：则关闭压边对白，打开选项对白
		if LD.IsNextQuestDialogHasOption() == false then
			Info = LD.GetNextQuestDialogTxt()
			if Info ~= nil and string.len(Info)>0 then
				--延迟关闭
				NpcDialogFullUI.AutoSkipEndTime = CL.GetServerTickCount() + AUTO_SKIP_WAIT_TIME
				--对白过程中
				NpcDialogFullUI.OnShow( Info, true)
			else
				--最后一句对白
				CL.SendNotify(NOTIFY.QuestOpeUpdate,3, -1)
				NpcDialogFullUI.OnCloseByTween()
			end
		else
			Info = LD.GetNextQuestDialogTxt()
			GUI.OpenWnd("NpcDialogUI", Info)
			--有选项，则打开NpcDiglogUI,关闭本界面
			NpcDialogFullUI.CloseWnd()
		end
		if NpcDialogFullUI.SelfInTeamState == 2 then
			NpcDialogFullUI.SendTeamNotify( 1 )
		end
	end
end

function NpcDialogFullUI.OnCloseByTween()
	NpcDialogFullUI.SlideOut()
    NpcDialogFullUI.DelayCloseWndTimer = Timer.New(NpcDialogFullUI.DelayCloseWnd,playAnimTime)
    NpcDialogFullUI.DelayCloseWndTimer:Start()
end

function NpcDialogFullUI.SendTeamNotify( par )
	CL.SendNotify(NOTIFY.TeamLearderOpeReq,par)
end

function NpcDialogFullUI.DelayCloseWnd()
	NpcDialogFullUI.StopMovie()
	NpcDialogFullUI.CloseWnd()
end

function NpcDialogFullUI.CloseWnd()
    if NpcDialogFullUI.DelayCloseWndTimer ~= nil then
        NpcDialogFullUI.DelayCloseWndTimer:Stop()
    end
    if NpcDialogFullUI.DistanceTimer ~= nil then
        NpcDialogFullUI.DistanceTimer:Stop()
    end
	NpcDialogFullUI.InitData()
	if NpcDialogFullUI["npcModel"] ~= nil then
		GUI.SetVisible(NpcDialogFullUI["npcModel"],false)
	end
	if NpcDialogFullUI["selfModel"] ~= nil then
		GUI.SetVisible(NpcDialogFullUI["selfModel"],false)
	end
	GUI.CloseWnd("NpcDialogFullUI")
	if not CL.IsStoryMode() then
		GUI.SetCameraLayer(eLayer.UI)
	end
end

function NpcDialogFullUI.OnTeamTearderOpe( parameter )
	if parameter == nil then
		return
	end
	--只有在队伍中的队员才接收此状态更新
	if NpcDialogFullUI.SelfInTeamState ~= 3 then
		return
	end

	parameter=TeamLeaderOprType.IntToEnum(tonumber(parameter))
	if parameter == TeamLeaderOprType.tlot_manual_close_npctalk or parameter == TeamLeaderOprType.tlot_long_distance_auto_close_npctalk  then
		NpcDialogFullUI.CloseWnd()

	elseif parameter == TeamLeaderOprType.tlot_story then
		local Info = nil
		--下一句对白有选项：则关闭压边对白，打开选项对白
		if LD.IsNextQuestDialogHasOption() == false then
			Info = LD.GetNextQuestDialogTxt()
			if Info ~= nil and string.len(Info)>0 then
				--对白过程中
				NpcDialogFullUI.OnShow( Info, true)
			else
				--最后一句对白
				CL.SendNotify(NOTIFY.QuestOpeUpdate,3, -1)
				NpcDialogFullUI.OnCloseByTween()
			end
		else
			NpcDialogFullUI.OnCloseByTween()
		end

	elseif parameter == TeamLeaderOprType.tlot_npctalk_skipTalkMovie then
		NpcDialogFullUI.OnCloseByTween()
	end
end