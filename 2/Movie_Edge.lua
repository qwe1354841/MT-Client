Movie_Edge = {}

--对话框内名字背景颜色
local content_NameColor="f1d1ac";
--对话框内文字颜色
local content_TxtColor="ffffff";
local task_Title="805538";

Movie_Edge.LinkPoint= {
	['Bottom'] = UILayout.Bottom,
	['BottomLeft'] = UILayout.BottomLeft,
	['BottomRight'] = UILayout.BottomRight,
	['Center'] = UILayout.Center,
	['Left'] = UILayout.Left,
	['Right'] = UILayout.Right,
	['Top'] = UILayout.Top,
	['TopLeft'] = UILayout.TopLeft,
	['TopRight'] = UILayout.TopRight,
}

function Movie_Edge.Main( parameter )	
	Movie_Edge['Panel'] = GUI.WndCreateWnd("Movie_Edge" , "Movie_Edge" , 0 , 0 ,eCanvasGroup.Movie);
	local panel = Movie_Edge['Panel']
	
	Movie_Edge['topBG'] = GUI.ImageCreate(Movie_Edge['Panel'],"topBG","1800600310",0,299,false,GUI.GetWidth(Movie_Edge['Panel']),299);
 	UILayout.SetSameAnchorAndPivot(Movie_Edge['topBG'], UILayout.Top)
	GUI.SetDepth(Movie_Edge['topBG'],0);
	GUI.RegisterUIEvent(Movie_Edge['topBG'],ULE.TweenCallBack,"Movie_Edge","Tween_Callback");
	
	Movie_Edge['downBG'] = GUI.ImageCreate(Movie_Edge['Panel'],"downBG","1800600300",0,299,false,GUI.GetWidth(Movie_Edge['Panel']),299);
 	UILayout.SetSameAnchorAndPivot(Movie_Edge['downBG'], UILayout.Bottom)
	GUI.SetDepth(Movie_Edge['downBG'],1);
	
	Movie_Edge['TalkBG'] = GUI.ImageCreate( Movie_Edge['Panel'], "TalkBG" , "1800600010" , 0 , -108 , false  ,GUI.GetWidth(Movie_Edge['Panel']) - 20 ,175);
	GUI.SetIsRaycastTarget(Movie_Edge['TalkBG'],false);
 	UILayout.SetAnchorAndPivot(Movie_Edge['TalkBG'], UIAnchor.Bottom, UIAroundPivot.Center)
	
	Movie_Edge['NameBG'] = GUI.ImageCreate( Movie_Edge['TalkBG'], "NameBG" , "1800601010" , 42 , -4 );
 	UILayout.SetSameAnchorAndPivot(Movie_Edge['NameBG'], UILayout.BottomLeft)
	
	Movie_Edge['txtName'] = GUI.CreateStatic(Movie_Edge['NameBG'],"txtName","<color=#"..content_NameColor.."><size=22>".."紫霞仙子".."</size></color>",0,0,200,50,"system",true);
    UILayout.SetSameAnchorAndPivot(Movie_Edge['txtName'], UILayout.Center)
	GUI.StaticSetAlignment(Movie_Edge['txtName'],TextAnchor.MiddleCenter)
	GUI.StaticSetFontSize(Movie_Edge['txtName'],24);
	
	local func_text = [[放弃阿飞还是啊海飞丝发违法司法司法玩法发违法司法司法玩法发我份V
	发发我份发放玩法无法哇嘎嘎三个散热
	]]
	Movie_Edge['txtDialog'] = GUI.RichEditCreate(Movie_Edge['TalkBG'],"txtDialog","",350,40,760,26,"system",true);
	GUI.StaticSetFontSize(Movie_Edge['txtDialog'], 24)
 	UILayout.SetSameAnchorAndPivot(Movie_Edge['txtDialog'], UILayout.TopLeft)
 	GUI.StaticSetText(Movie_Edge['txtDialog'], func_text);
	GUI.SetHeight(Movie_Edge['txtDialog'],GUI.RichEditGetPreferredHeight(Movie_Edge['txtDialog']));
	
	Movie_Edge['pnImage'] = GUI.ImageCreate(Movie_Edge['Panel'],"pnImage","1800600010",0,0,false,GUI.GetWidth(Movie_Edge['Panel']),GUI.GetHeight(Movie_Edge['Panel']));
 	UILayout.SetSameAnchorAndPivot(Movie_Edge['pnImage'], UILayout.TopLeft)
	GUI.SetColor(Movie_Edge['pnImage'],Color.New(255/255,255/255,255/255,0/255))
	GUI.SetDepth(Movie_Edge['pnImage'],0);
	
	local txt = GUI.CreateStatic(Movie_Edge['TalkBG'],"Tips","点击任意位置继续对话",1000,54,400,50,"system",true);
	UILayout.SetSameAnchorAndPivot(txt, UILayout.BottomRight)
	GUI.StaticSetAlignment(txt, TextAnchor.LowerLeft)
 	UILayout.StaticSetFontSizeColorAlignment(txt, 24, Color.New(174/255,174/255,174/255, nil))
	
	local Underline = GUI.CreateStatic(Movie_Edge['TalkBG'],"Underline","____________________",1000,54,400,50,"system",true);
	UILayout.SetSameAnchorAndPivot(Underline, UILayout.BottomRight)
	GUI.StaticSetAlignment(Underline, TextAnchor.LowerLeft)
 	UILayout.StaticSetFontSizeColorAlignment(Underline, 24, Color.New(174/255,174/255,174/255, nil))
	
	Movie_Edge['MaxBtn'] = GUI.ButtonCreate( panel, "MaxBtn" , "1800600010" , 0, 0, Transition.ColorTint, "", GUI.GetWidth(panel) , GUI.GetHeight(panel), false);
	GUI.SetColor(Movie_Edge['MaxBtn'],Color.New(255/255,255/255,255/255,0/255));
	GUI.RegisterUIEvent(Movie_Edge['MaxBtn'] , UCE.PointerClick , "Movie_Edge", "OnScreenClick" )
	GUI.SetVisible(Movie_Edge['MaxBtn'], false)
	
	Movie_Edge['BtnSkip'] = GUI.ButtonCreate( panel, "BtnSkip" , "1800600010" , 0, 0, Transition.ColorTint, "", 280 , 50, false);
	UILayout.SetSameAnchorAndPivot(Movie_Edge['BtnSkip'], UILayout.TopRight)
	GUI.SetColor(Movie_Edge['BtnSkip'],Color.New(255/255,255/255,255/255,0/255));
	GUI.RegisterUIEvent(Movie_Edge['BtnSkip'] , UCE.PointerClick , "Movie_Edge", "OnSkipClick" )
	GUI.SetVisible(Movie_Edge['BtnSkip'], false)
	
	local imgSkip = GUI.ImageCreate( Movie_Edge['BtnSkip'], "imgSkip" , "1800604410" , -40 , 0, false );
 	UILayout.SetSameAnchorAndPivot(imgSkip, UILayout.Left)
	
   UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
   UILayout.StaticSetFontSizeColorAlignment(txt, 24, Color.New(174/255,174/255,174/255, nil))

   UILayout.SetSameAnchorAndPivot(Underline, UILayout.Left)
   UILayout.StaticSetFontSizeColorAlignment(Underline, 24, Color.New(174/255,174/255,174/255, nil))
	
	--test("模型加载完毕")
	--Movie_Edge['Boom'] = Timer.New(Movie_Edge.Destroy, 15)
	--Movie_Edge['Boom']:Start()
	Movie_Edge['modelRole'] = {}
	Movie_Edge['Camera_Data'] = {}
	
	Movie_Edge['Animations'] = {true,true,true,true,true}
	Movie_Edge['Alphas'] = {true,true,true,true,true}
	
	Movie_Edge.LeaveScreen("")
	--Movie_Edge.EnterScreen()
	GUI.SetVisible(Movie_Edge['TalkBG'], false)
	
	
	--GlobalProssesing里面的升级回调依赖
	--local selfNickName = CL.GetINickName()
	--test("注册升级回调")
	--CL.RegisterAttributeEvent(role_attr.role_level,selfNickName,"Movie_Edge","On_PlayerLevelUp");
end 
function Movie_Edge.PanelCheck()
	if GUI.GetWnd('Movie_Edge') == nil then
		print("---------------------Movie_Edge为nil")
		Movie_Edge.Main()
	end
end

function Movie_Edge.EnterScreen()
	GUI.SetVisible(Movie_Edge['topBG'], true)
	GUI.SetVisible(Movie_Edge['downBG'], true)

	GUI.DOTween(Movie_Edge['topBG'],"NPCTalkMovie","NPCTalkMovie")
	GUI.DOTween(Movie_Edge['downBG'],"NPCTalkMovie","NPCTalkMovie")
	GUI.SetVisible(Movie_Edge['MaxBtn'], true)
	GUI.SetVisible(Movie_Edge['BtnSkip'], true)
	Movie_Edge.IsEdging = true
	Movie_Edge.EdgeMoving = true
	Movie_Edge.MoviePlaying = ""
	--Timer.New("Movie_Edge.EnterScreenBack", 0.6, 1)
end

function Movie_Edge.LeaveScreen(m_name)
	GUI.DOTween(Movie_Edge['topBG'],"NPCTalkMovieBack","NPCTalkMovieBack")
	GUI.DOTween(Movie_Edge['downBG'],"NPCTalkMovieBack","NPCTalkMovieBack")
	Movie_Edge.EdgeMoving = true
	Movie_Edge.MoviePlaying = m_name
	--Timer.New("Movie_Edge.LeaveScreenBack", 0.6, 1)
end

function Movie_Edge.Tween_Callback(guid , animate)
	--这个key现在是回调了topBG，我需要它回调一下动画的KEY值
	if animate == "NPCTalkMovie" then
		if MoviePlaying == 1 then
			Movie_Edge.EdgeMoving = false
		end
	elseif animate == "NPCTalkMovieBack" then
		Movie_Edge.EdgeMoving = false
		Movie_Edge.IsEdging = false
		GUI.SetVisible(Movie_Edge['MaxBtn'], false)
		GUI.SetVisible(Movie_Edge['BtnSkip'], false)
		if Movie_Edge.MoviePlaying ~= "" then
			SMovie_System.CanOver(Movie_Edge.MoviePlaying)
		end
	end
end

function Movie_Edge.EnterScreenBack()
	if MoviePlaying == 1 then
		Movie_Edge.EdgeMoving = false
	end
end

function Movie_Edge.LeaveScreenBack()
	Movie_Edge.EdgeMoving = false
	Movie_Edge.IsEdging = false
end

function Movie_Edge.Destroy()
	--Movie_Edge['Boom']:Stop()
	GUI.SetVisible(Movie_Edge['topBG'], false)
	GUI.SetVisible(Movie_Edge['downBG'], false)
	GUI.SetVisible(Movie_Edge['TalkBG'], false)
	for k,v in pairs(Movie_Edge['modelRole']) do
		GUI.Destroy(v)
	end
	Movie_Edge['modelRole'] = {}
	Movie_Edge["Npc_Data"] = {}
	Movie_Edge["Dye_Data"] = {}
	--GUI.DestroyWnd("Movie_Edge")
	--Movie_Edge = nil
end

function Movie_Edge.OnRawImageCreate()
	local model = GUI.Get("Movie_Edge/TalkBG/modelRole_"..Movie_Edge['Talker'] .. "/modelRole_"..Movie_Edge['Talker']);
	--test("显示子模型")
	--GUI.RegisterUIEvent(model,ULE.CreateFinsh,"Movie_Edge","OnRawImageCreate_Child");
	 Movie_Edge.OnRawImageCreate_Child()
	--GUI.SetVisible(model,true);
end

function Movie_Edge.OnRawImageCreate_Child( ... )
	--test("子模型加载完毕")
	local rootModel=GUI.Get("Movie_Edge/TalkBG/modelRole_"..Movie_Edge['Talker'])
	local model=GUI.Get("Movie_Edge/TalkBG/modelRole_"..Movie_Edge['Talker'].."/modelRole_"..Movie_Edge['Talker']);

	GUI.SetLocalPosition(model,0,0,0);
	GUI.SetVisible(rootModel,true);
	if Movie_Edge['Dye_Data']['NewColorId_1'] ~= nil then
		--test("DyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDyeDye         " .. Movie_Edge['Npc_Data']['NewColorId'])
		GUI.RefreshDyeSkin(model, Movie_Edge['Dye_Data']['NewColorId_1'], Movie_Edge['Dye_Data']['NewColorId_2'] or 0)
	end
	--GUI.RawImageSetCameraConfig(Movie_Edge['modelRole'][Movie_Edge['Talker']],Movie_Edge['Camera_Data'][Movie_Edge['Talker']]);
	
end

function Movie_Edge.CloseTalkBG()
	GUI.SetVisible(Movie_Edge['TalkBG'], false)
	Movie_Edge.Close_MovieSkip()
end


---------------------对话设置---------------------
function Movie_Edge.NpcTalk(npc_id, model, dyeID_1, dyeID_2, dlg, fun, param)
	local UL_npcID = npc_id
	npc_id = tostring(npc_id)
	local NpcName = CL.GetRoleName(npc_id)
	--test( "=========================          NpcName = " .. NpcName)
	
	local index
	if not Movie_Edge["Npc_Data"] then
		Movie_Edge["Npc_Data"] = {}
	end
	if not Movie_Edge["Dye_Data"] then
		Movie_Edge["Dye_Data"] = {}
	end
	if Movie_Edge["Npc_Data"]["Npc_" ..npc_id] then
		--test("id = " .. npc_id .. "         不创建")
		index = Movie_Edge["Npc_Data"]["Npc_" ..npc_id]
		GUI.SetVisible(Movie_Edge['modelRole'][index], true);
		GUI.RawImageSetCameraConfig(Movie_Edge['modelRole'][index], Movie_Edge['Camera_Data'][index]);
		local new_model = GUI.Get("Movie_Edge/TalkBG/modelRole_"..Movie_Edge['Talker'].."/modelRole_"..Movie_Edge['Talker']);
		GUI.SetLocalPosition(new_model,0,0,0);
		Movie_Edge['Talker'] = index
	else
		--test("       tablecount = " .. tablecount(Movie_Edge["Npc_Data"]))
		--if tablecount(Movie_Edge["Npc_Data"]) >= 1 then
		--	for k,v in pairs(Movie_Edge["Npc_Data"]) do
		--		test("                             序列" .. k .. " = " .. v)
		--	end
		--end
		Movie_Edge["Npc_Data"]["Npc_" ..npc_id] = tablecount(Movie_Edge["Npc_Data"]) + 1
		index = Movie_Edge["Npc_Data"]["Npc_" ..npc_id]
		Movie_Edge['Talker'] = index
		local new_model = nil
		if model == -1 then
			new_model = CL.GetIntAttr(RoleAttr.RoleAttrRole)
			if Movie_Edge.NowNPCisLead == 1 then-- 判断主角 todo
				local key = CL.GetRoleTemplateID();
				if key ~= 0 then
					local roleData = DB.GetRole(key);--, 1
					if roleData ~= nil then
						new_model = roleData.Model
					end
				end
			end
		else
			new_model = model
		end
		
		if dyeID_1 ~= -1 then
			--test("Dye1111111111111111111111111111111111111111111111111111111       " .. dyeID_1)
			Movie_Edge['Dye_Data']['NewColorId_1'] = dyeID_1
		else
			--test("Dye2222222222222222222222222222222222222222222222222222222")
			Movie_Edge['Dye_Data']['NewColorId_1'] = nil
		end
		
		if dyeID_2 ~= -1 then
			--test("Dye1111111111111111111111111111111111111111111111111111111")
			Movie_Edge['Dye_Data']['NewColorId_2'] = dyeID_2
		else
			--test("Dye2222222222222222222222222222222222222222222222222222222")
			Movie_Edge['Dye_Data']['NewColorId_2'] = nil
		end

		--test(" ModelID = " .. model )
		if index ~= nil then
			local avatarCfg = SETTING.GetAvatarmodelconfig(new_model)
			--Movie_Edge['modelRole'][index] = GUI.RawImageCreate(Movie_Edge['TalkBG'],true,"modelRole_" .. index,0,-7,-10,2,false,400,400);
			Movie_Edge['modelRole'][index] = GUI.RawImageCreate(Movie_Edge['TalkBG'],true,"modelRole_" .. index,"",0,0,2,false,400,400);
   			UILayout.SetSameAnchorAndPivot(Movie_Edge['modelRole'][index], UILayout.BottomLeft)
			--test(GUI.GetGuid(Movie_Edge['modelRole'][index]))
			GUI.SetDepth(Movie_Edge['modelRole'][index],0)
			
			--local roleModel = GUI.RawImageChildCreate(Movie_Edge['modelRole'][index],false,"roleMadel","",0,0)
			--GUI.ReplaceWeapon(roleModel,0,eRoleMovement.STAND_W1,model);
			--GUI.RegisterUIEvent(Movie_Edge['modelRole'][index],ULE.CreateFinsh,"Movie_Edge","OnRawImageCreate");
			--GUI.SetIsRaycastTarget(Movie_Edge['modelRole'][index],false);
			--GUI.AddToCamera(Movie_Edge['modelRole'][index]);
		
		
			--GUI.SetVisible(Movie_Edge['modelRole'][index], false)
			
			
			if SETTING.GetNpcdialogcamera(avatarCfg.ResKey)~=nil then
				--test(SETTING.GetNpcdialogcamera(avatarCfg.ResKey).Data)
				Movie_Edge['Camera_Data'][index] = SETTING.GetNpcdialogcamera(avatarCfg.ResKey).Data
			elseif id == 10 then
				--test("id == 10")
				Movie_Edge['Camera_Data'][index] = "(0.09119999,1.336,2.56),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,4.79,0.01,2.33,37"
			else  
				Movie_Edge['Camera_Data'][index] = "(0.76,1.8,2.56),(-0.005699173,0.9774809,-0.1495397,-0.1487837),True,4.79,0.01,0.74,32"
			end
			GUI.AddToCamera(Movie_Edge['modelRole'][index]);
			GUI.RawImageSetCameraConfig(Movie_Edge['modelRole'][index],Movie_Edge['Camera_Data'][index]);
			local roleModel = GUI.RawImageChildCreate(Movie_Edge['modelRole'][index],false,"roleMadel","",0,0)
			if model == -1 then
				local sex = CL.GetIntAttr(RoleAttr.RoleAttrGender, 0)
				local weaponId = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId, 0)
                local WeaponEffect = CL.GetIntAttr(RoleAttr.RoleAttrEffect1, 0)
                local Color1 =  CL.GetIntAttr(RoleAttr.RoleAttrColor1, 0)
                local Color2 =  CL.GetIntAttr(RoleAttr.RoleAttrColor2, 0)
				ModelItem.BindRoleWithClothAndWind(roleModel,new_model,Color1,Color2,eRoleMovement.STAND_W1,weaponId,sex,WeaponEffect,0)
				ModelItem.BindRoleEquipGemEffect(roleModel)
			else
				ModelItem.Bind(roleModel,new_model)
			end
			UILayout.SetSameAnchorAndPivot(roleModel,UILayout.Center)
			GUI.BindPrefabWithChild(Movie_Edge['modelRole'][index],GUI.GetGuid(roleModel))
			--GUI.ReplaceWeapon(roleModel,0,eRoleMovement.STAND_W1,model);
			--GUI.RegisterUIEvent(Movie_Edge['modelRole'][index],ULE.CreateFinsh,"Movie_Edge","OnRawImageCreate");
			--GUI.SetIsRaycastTarget(Movie_Edge['modelRole'][index],false);
		end
	end
	
	Movie_Edge['PassFunction'] = fun
	Movie_Edge['PassParam'] = param
	if Movie_Edge['txtDialog'] then
		GUI.StaticSetText(Movie_Edge['txtDialog'], dlg);
	end
	if Movie_Edge['txtName'] then
		GUI.StaticSetText(Movie_Edge['txtName'], NpcName);
	end
	if Movie_Edge['TalkBG'] then
		GUI.SetVisible(Movie_Edge['TalkBG'], true)
	end
	if Movie_Edge['MaxBtn'] then
		GUI.SetVisible(Movie_Edge['MaxBtn'], true)
	end
	Movie_Edge['CanClick'] = true
end

function Movie_Edge.OnScreenClick()
	if Movie_Edge['CanClick'] == false then
		return
	end
	if not Movie_Edge['Talker'] then
		return
	end
	
	Movie_Edge['CanClick'] = false
	GUI.SetVisible(Movie_Edge['TalkBG'], false)
	GUI.SetVisible(Movie_Edge['modelRole'][Movie_Edge['Talker']], false)
	
	if Movie_Edge['PassParam'] then
		if type(Movie_Edge['PassParam']) == "string" then
			assert(loadstring("" .. Movie_Edge['PassFunction'] .. "('" .. Movie_Edge['PassParam'].."')"))()
		else
			assert(loadstring("" .. Movie_Edge['PassFunction'] .. "(" .. Movie_Edge['PassParam']..")"))()
		end
	else
		assert(loadstring("" .. Movie_Edge['PassFunction'] .. "()"))()
	end
	if Movie_Edge.IsEdging == false then
		GUI.SetVisible(Movie_Edge['MaxBtn'], false)
	end
end

---------------------图片动画---------------------
function Movie_Edge.CreatImage(img_name, x, y, isfullscrean,linkpoint)
	if not Movie_Edge["Img_Data"] then
		Movie_Edge["Img_Data"] = {}
	end
	local index = tablecount(Movie_Edge["Img_Data"]) + 1
	Movie_Edge["Img_Data"]["Img_" .. index] = {}
	
	local width = 0
	local height = 0
	local autoSize = true
	if isfullscrean == true then
		--local aa = GUI.ImageCreate(Movie_Edge['Panel'],"aa","" .. img_name,x,y);
		--GUI.SetVisible(aa,false)
		width = GUI.GetWidth(Movie_Edge['Panel'])+1
		height = GUI.GetHeight(Movie_Edge['Panel'])
		--[[
		if width/height >= GUI.GetWidth(aa)/GUI.GetHeight(aa) then
			--test("width/height=======================================1")
			width = GUI.GetWidth(Movie_Edge['Panel'])
			height = GUI.GetWidth(Movie_Edge['Panel']) *(GUI.GetHeight(aa)/GUI.GetWidth(aa))
		else
			--test("width/height=======================================2")
			width = GUI.GetHeight(Movie_Edge['Panel'])*(GUI.GetWidth(aa)/GUI.GetHeight(aa))
			height = GUI.GetHeight(Movie_Edge['Panel'])
		end
		]]
		autoSize = false
		--GUI.Destroy(aa)
		--test("width33====================="..width)
		--test("height33====================="..height)
	end
	Movie_Edge["Img_Data"]["Img_" .. index]['guid'] = GUI.ImageCreate(Movie_Edge['pnImage'],"Img_" .. index,"" .. img_name,x,y,autoSize,width,height);
 	UILayout.SetSameAnchorAndPivot(Movie_Edge["Img_Data"]["Img_" .. index]['guid'], Movie_Edge.LinkPoint[linkpoint]);
	Movie_Edge["Img_Data"]["Img_" .. index]['exist'] = true
	GUI.SetGroupAlpha(Movie_Edge["Img_Data"]["Img_" .. index]['guid'], 0)
	--GUI.SetVisible(Movie_Edge["Img_Data"]["Img_" .. index]['guid'], visible or false)
	--GUI.SetLayer(Movie_Edge["Img_Data"]["Img_" .. index]['guid'], eLayer.Movie)
	
	return index
end

function GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    
    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))

    return nRet;
end

function Movie_Edge.ImageMove(img_id, x, y, times)
	if not Movie_Edge["Img_Data"] then
		return
	end
	if not Movie_Edge["Img_Data"]["Img_" .. img_id] then
		return
	end
	if not Movie_Edge["Img_Data"]["Img_" .. img_id]['guid'] then
		return
	end
	if Movie_Edge["Img_Data"]["Img_" .. img_id]['exist'] == false then
		return
	end
	if type(x) ~= "number" then
		return
	end
	if type(y) ~= "number" then
		return
	end
	
	local AniIndex = 0
	for k,v in pairs(Movie_Edge['Animations']) do
		if v == true then
			AniIndex = k
			break;
		end
	end
	if AniIndex == 0 then
		test('同时存在的剧情图片动画过多')
		return
	end
	
	local tween = TweenData.New()
	tween.Type = GUITweenType.DOLocalMove
	tween.Duration = times
	tween.To = Vector3.New(x,y,0)
	tween.LoopType = UITweenerStyle.Once;
	GUI.DOTween(Movie_Edge["Img_Data"]["Img_" .. img_id]['guid'],tween);

	GUI.SetVisible(Movie_Edge["Img_Data"]["Img_" .. img_id]['guid'], true)
end

function Movie_Edge.ImageAlpha(img_id, start, finish, times)
	--test("000000000000000000000000000000000000000000000")
	if not Movie_Edge["Img_Data"] then
		return
	end
	if not Movie_Edge["Img_Data"]["Img_" .. img_id] then
		return
	end
	if not Movie_Edge["Img_Data"]["Img_" .. img_id]['guid'] then
		return
	end
	--test("111111111111111111111111111111111111111111111")
	if Movie_Edge["Img_Data"]["Img_" .. img_id]['exist'] == false then
		return
	end
	if type(start) ~= "number" then
		return
	end
	if type(finish) ~= "number" then
		return
	end
	--test("2222222222222222222222222222222222222222222222")
	local AniIndex = 0
	for k,v in pairs(Movie_Edge['Alphas']) do
		if v == true then
			AniIndex = k
			break;
		end
	end
	if AniIndex == 0 then
		test('同时存在的剧情图片隐藏过多')
		return
	end
	--test("33333333333333333333333333333333333333333333333")
	if start == 0 then
		start = 0.01
	end
	local tween = TweenData.New();--CFG.Get_GUITweenInfo("Movie_Alpha_" .. AniIndex);
	tween.Type = GUITweenType.DOGroupAlpha
	tween.From = Vector3.New(start,0,0)
	tween.To = Vector3.New(finish,0,0)
	tween.LoopType = UITweenerStyle.Once;
	tween.Duration = times
	GUI.DOTween(Movie_Edge["Img_Data"]["Img_" .. img_id]['guid'],tween,"");--"Movie_Alpha_" .. AniIndex
end

function Movie_Edge.RemoveImg(img_id)
	if not Movie_Edge["Img_Data"] then
		return
	end
	if not Movie_Edge["Img_Data"]["Img_" .. img_id] then
		return
	end
	if not Movie_Edge["Img_Data"]["Img_" .. img_id]['guid'] then
		return
	end
	if Movie_Edge["Img_Data"]["Img_" .. img_id]['exist'] == false then
		return
	end
	Movie_Edge["Img_Data"]["Img_" .. img_id]['exist'] = false
	GUI.Destroy(Movie_Edge["Img_Data"]["Img_" .. img_id]['guid'])
	--test("删除图片")
end

---------------------跳过动画---------------------
function Movie_Edge.OnSkipClick()

	--local str = "确定要跳过剧情动画吗？"
	--local m_name = SMovie_System['MovieName']
    --GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("跳过剧情", str, "SMovie_System", "取消", "", "跳过", "MovieOver", m_name)
	--local timer
	--local fun = function()
	--	GUI.SetLayer(GUI.GetWnd("BoxMessageUI") , eLayer.Movie)
	--end
	--timer = Timer.New(fun,0.2)
	--timer:Start()

	local _gt = UILayout.NewGUIDUtilTable();

	local wnd = Movie_Edge['Panel']
	if GUI.GetChild(wnd,"SkippanelBg") ~= nil then
		return
	end
	local SkippanelBg=GUI.ImageCreate(wnd,"SkippanelBg","1800001120",0,0,false ,460,260);
	Movie_Edge['MovieSkip'] = SkippanelBg
	UILayout.SetSameAnchorAndPivot(SkippanelBg,UILayout.Center);

  	local titleBg=GUI.ImageCreate(SkippanelBg,"titleBg","1800001030",0,25);
  	UILayout.SetSameAnchorAndPivot(titleBg,UILayout.Top);

  	local titleText = GUI.CreateStatic(titleBg,"titleText", "跳过剧情", 0, 1, 200, 35);
  	GUI.SetColor(titleText,UIDefine.White3Color);
  	GUI.StaticSetFontSize(titleText, UIDefine.FontSizeS);
  	GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter);
  	UILayout.SetSameAnchorAndPivot(titleText,UILayout.Center);
  	_gt.BindName(titleText,"titleText");

  	local msgText = GUI.RichEditCreate(SkippanelBg,"msgText","确定要跳过剧情动画吗？",0,0,420,120);
  	GUI.StaticSetAlignment(msgText, TextAnchor.MiddleCenter);
  	GUI.StaticSetFontSize(msgText,UIDefine.FontSizeS);
  	GUI.SetColor(msgText,UIDefine.BrownColor);
  	_gt.BindName(msgText,"msgText");

  	local firstBtn=GUI.ButtonCreate(SkippanelBg,"firstBtn","1800002060",120,-20, Transition.ColorTint, "跳过",130,45,false)
  	UILayout.SetSameAnchorAndPivot(firstBtn,UILayout.Bottom);
  	GUI.ButtonSetTextColor(firstBtn,UIDefine.WhiteColor);
  	GUI.ButtonSetTextFontSize(firstBtn,UIDefine.FontSizeL)
  	GUI.SetIsOutLine(firstBtn,true)
	GUI.SetOutLine_Setting(firstBtn,OutLineSetting.OutLine_BrownColor_1)
  	GUI.SetOutLine_Color(firstBtn,UIDefine.OutLine_BrownColor)
  	GUI.SetOutLine_Distance(firstBtn,UIDefine.OutLineDistance)
  	GUI.RegisterUIEvent(firstBtn, UCE.PointerClick, "SMovie_System", "MovieOver");

	local m_name = SMovie_System['MovieName']
	GUI.SetData(firstBtn,"movie_name",m_name)

  	local secondBtn = GUI.ButtonCreate(SkippanelBg,"secondBtn","1800002060",-120,-20, Transition.ColorTint, "取消",130,45,false)
	UILayout.SetSameAnchorAndPivot(secondBtn,UILayout.Bottom);
	GUI.ButtonSetTextColor(secondBtn,UIDefine.WhiteColor);
	GUI.ButtonSetTextFontSize(secondBtn,UIDefine.FontSizeL)
	GUI.SetIsOutLine(secondBtn,true)
	GUI.SetOutLine_Setting(secondBtn,OutLineSetting.OutLine_BrownColor_1)
	GUI.SetOutLine_Color(secondBtn,UIDefine.OutLine_BrownColor)
	GUI.SetOutLine_Distance(secondBtn,UIDefine.OutLineDistance)
	GUI.RegisterUIEvent(secondBtn, UCE.PointerClick, "Movie_Edge", "OnExit");
	_gt.BindName(secondBtn,"firstBtn");
end


function Movie_Edge.OnExit()
	GUI.Destroy(Movie_Edge['MovieSkip'])
end

function Movie_Edge.Close_MovieSkip()
	local wnd = GUI.GetWnd("Movie_Edge")
	if wnd~=nil then
		GUI.Destroy(Movie_Edge['MovieSkip'])
	end
end

function Movie_Edge.OnClose()
	Movie_Edge.Close_MovieSkip()
end

function Movie_Edge.OnDestroy()
	Movie_Edge.Close_MovieSkip()
end


Movie_Edge.Main()