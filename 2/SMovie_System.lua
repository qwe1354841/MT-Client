SMovie_System = {}



function SMovie_System.Main( parameter )	
	MoviePlaying = 0
	SMovie_System_SeverData = {}
end

function tablecount(datatable)
    local count = 0
    if type(datatable) == "table" then
      for i,v in pairs(datatable) do
        count = count+1
      end
    end
    return count
  end

function SMovie_System.MovieAction(m_name, GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable, TalkTable)
	if m_name == nil then
		test("缺少 GlobalConfig -- MovieName 配置，动画无法运行。");
		return
	end
	Movie_Edge.PanelCheck()
	SMovie_System['MovieName'] = m_name
	SMovie_System.DataIntil(m_name)
	
	SMovie_System[m_name]['GlobalConfig'] = GlobalConfig;
	SMovie_System[m_name]['NpcTable'] = NpcTable;
	SMovie_System[m_name]['EffectTable'] = EffectTable;
	SMovie_System[m_name]['ImageTable'] = ImageTable;
	SMovie_System[m_name]['WordTable'] = WordTable;
	
	if GlobalConfig['FrameTable'] and tablecount(GlobalConfig['FrameTable']) > 0 then
		SMovie_System[m_name]['frame'] = 1
	else
		SMovie_System[m_name]['frame'] = 0
	end
	if TalkTable == nil then
		SMovie_System[m_name]['frame'] = 0
	else
		SMovie_System[m_name]['TalkTable'] = TalkTable;
	end
	
	SMovie_System[m_name]['EDGE'] = ""
	SMovie_System[m_name]['OverTiming'] = 0;
	SMovie_System[m_name]['Camera'] = 0
	
	SMovie_System[m_name]['OverTrigger'] = 0
	if SMovie_System[m_name]['frame'] == 0 then
		SMovie_System.NPCMod(m_name)
		SMovie_System.IMGMod(m_name)
		SMovie_System.WRDMod(m_name)
		SMovie_System.EFTMod(m_name)
	end
	SMovie_System.DEFINE(m_name)
end

function SMovie_System.DataIntil(m_name)
	SMovie_System[m_name] = {};
	SMovie_System[m_name]['GlobalConfig'] = {}
	SMovie_System[m_name]['NpcTable'] = {}
	SMovie_System[m_name]['EffectTable'] = {}
	SMovie_System[m_name]['ImageTable'] = {}
	SMovie_System[m_name]['WordTable'] = {}
	
	
	SMovie_System[m_name]['Escing'] = 0;

	SMovie_System[m_name]['NPC'] = {}
	SMovie_System[m_name]['EFFECT'] = {}
	SMovie_System[m_name]['IMG'] = {}
	SMovie_System[m_name]['WORD'] = {}
	SMovie_System[m_name]['MODEL'] = {}
	SMovie_System[m_name]['DYE'] = {}
	
end

-------------------------------------------------------------封装内容请勿修改--------------------------------------------------------------------------
-------------------------------------------------------------脚本版本：V_2.12--------------------------------------------------------------------------
------------全局模块------------
function SMovie_System.DEFINE(m_name)
	MainUI.OnTryDestroyGuideUI()
	LD.SetMovieMode(true)
	CL.StopMove()
	MoviePlaying = 1
	GlobalProcessing.WndOpenCallBack("NpcDialogBoxUI")
	GUI.SetCameraLayer(eLayer.Movie)
	print("开始剧情动画-------------------")
	CL.SetTypeRoleVisible(false , eRoleType.Npc)
	CL.SetTypeRoleVisible(false , eRoleType.Player)
	CL.SetTypeRoleVisible(false , eRoleType.Pet)
	CL.SetTypeRoleVisible(false , eRoleType.Guard)
	
	local GlobalConfig = SMovie_System[m_name]['GlobalConfig']
	if GlobalConfig then
		if GlobalConfig['PlotEdge'] then
			local e_table = GlobalConfig['PlotEdge']
			if e_table['onoff'] == 1 then
				if SMovie_System[m_name]['frame'] == 0 then
					if not GlobalConfig['PlotEdge']['s_frame'] and not GlobalConfig['PlotEdge']['e_frame'] then
						--test("测试qqq");
						local fun = function ()
							Movie_Edge.EnterScreen()
						end
						Timer.New(fun, e_table['start']):Start()
						
						fun = function ()
							Movie_Edge.LeaveScreen()
						end
						Timer.New(fun, e_table['ext']):Start()
					end
				end
			end
		end
		if GlobalConfig['FrameTable'] and tablecount(GlobalConfig['FrameTable']) > 0 then
			SMovie_System.FrameStart(m_name)
		else
			if GlobalConfig['TotalTime'] then
				if GlobalConfig['TotalTime'] > 0 then
					local fun = function ()
						SMovie_System.MovieOver(''..m_name)
					end
					Timer.New(fun, GlobalConfig['TotalTime']):Start()
				end
			end
			if GlobalConfig['LeadingActor'] then
				if type(GlobalConfig['LeadingActor']) == 'table' then
					local fun
					for k,v in ipairs(GlobalConfig['LeadingActor']) do
						fun = function ()
							SMovie_System.CameraEx(''..m_name, ''..v[2])
						end
						Timer.New(fun, v[1]):Start()
					end
				end
			end
		end
	end
	--跟端游比这里没有HideAgain了
end

--画面开始
function SMovie_System.FrameStart(m_name)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	local GlobalConfig = SMovie_System[m_name]['GlobalConfig']
	local Frame = SMovie_System[m_name]['frame']
	if type(GlobalConfig['LeadingActor']) == 'table' then
		local fun
		if GlobalConfig['LeadingActor']['Frame'..Frame] then
			for k,v in ipairs(GlobalConfig['LeadingActor']['Frame'..Frame]) do
				fun = function ()
					SMovie_System.CameraEx(''..m_name, ''..v[2], ''..Frame)
				end
				Timer.New(fun, v[1]):Start()
			end
		end
	end
	
	
	local e_table = GlobalConfig['PlotEdge']
	if e_table['s_frame'] == Frame then
		local fun = function ()
			Movie_Edge.EnterScreen()
		end
		Timer.New(fun, e_table['start']):Start()
	end
	if e_table['e_frame'] == Frame then
		if SMovie_System[m_name]['EDGE'] then		
			local fun = function ()
				--test("某次爆炸1")
				Movie_Edge.LeaveScreen()
			end
			Timer.New(fun, e_table['ext']):Start()
		end
	end
	
	local FrameTable = SMovie_System[m_name]['GlobalConfig']['FrameTable']
	if FrameTable["Frame"..Frame] then
		
		if FrameTable["Frame"..Frame]['FrameType'] == "自由运动" then
			if FrameTable["Frame"..Frame]['FrameTime'] then
				if FrameTable["Frame"..Frame]['FrameTime'] > 0 then
					SMovie_System.NPCMod(m_name)
					SMovie_System.IMGMod(m_name)
					SMovie_System.WRDMod(m_name)
					SMovie_System.EFTMod(m_name)	
					local fun = function ()
						SMovie_System.FrameOver(''..m_name)
					end
					Timer.New(fun, FrameTable["Frame"..Frame]['FrameTime']):Start()
					
					fun = function ()
						SMovie_System.AntiBlocking(''..m_name, ''..Frame)
					end
					Timer.New(fun, FrameTable["Frame"..Frame]['FrameTime'] + 10):Start()
				end
			end
		elseif FrameTable["Frame"..Frame]['FrameType'] == "压边对话" then
			SMovie_System.TLKMod(m_name)
		end
	end
end

function SMovie_System.FrameOver(m_name)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if SMovie_System[m_name]['frame'] >= tablecount(SMovie_System[m_name]['GlobalConfig']['FrameTable']) then
		SMovie_System.MovieOver(m_name)
	elseif SMovie_System[m_name]['frame'] > 0 then
		SMovie_System[m_name]['frame'] = SMovie_System[m_name]['frame'] + 1
		SMovie_System.FrameStart(m_name)
	end
end

function SMovie_System.MovieOver(m_name)
	
	if not SMovie_System[m_name] then
		if GUI.GetByGuid(m_name) ~= nil then--此处的m_name有可能为跳过按钮的guid
			local btn = GUI.GetByGuid(m_name)
			m_name = GUI.GetData(btn,"movie_name")
			GUI.Destroy(Movie_Edge['MovieSkip'])
		else
			GlobalProcessing['MovieSkiper'] = m_name
			local fun = function ()
				GlobalProcessing['MovieSkiper'] = ""
			end
			Timer.New(fun, 10):Start()
			return
		end
	end

	if m_name == nil then
		m_name = SMovie_System['MovieName']
	end
	if m_name == "" then
		return
	end
	if GlobalProcessing['MovieWaiting'] == m_name then
		if not SMovie_System[m_name] then
			SMovie_System.DataIntil(m_name)
		end
		if not SMovie_System[m_name]['OverTrigger'] then
			SMovie_System[m_name]['OverTrigger'] = 0
		end
		SMovie_System.Upload(''..m_name)
		GlobalProcessing['MovieWaiting'] = ""
		return
	end
	if m_name == nil then
		LD.OnSendChatMsg_ClientLocal("动画数据读取错误",true);
		return
	end

	SMovie_System[m_name]['CanClick'] = 0;
	Movie_Edge['CanClick'] = false
	SMovie_System[m_name]['OverTiming'] = 1;
	if ConfirmBox then
		local obj = GUI.GetWnd("ConfirmBox")
		GUI.SetLayer(obj, eLayer.UI)
	end

	if SMovie_System[m_name]['Escing'] ~= 1 then
		local _TeamInfo = LD.GetTeamInfo()
		--print("---------------------------------队伍成员人数 = ")
		if _TeamInfo.members ~= nil and _TeamInfo.team_guid ~= 0 then
			local myname = CL.GetRoleName();
			--print("---------------------------------进入队长判定")
			if _TeamInfo.members[0].name == myname then
				--print("---------------------------------判定成功，关闭队友剧情")
				CL.SendNotify(NOTIFY.SubmitForm , "FormMovie" , "LeaderSkip" , "" .. m_name)
			end
		end
	end

	Movie_Edge.LeaveScreen(m_name)
	SMovie_System.Upload(m_name)
	Movie_Edge.CloseTalkBG()
	
	local fun = function ()
		SMovie_System.Upload(''..m_name)
	end
	Timer.New(fun, 0.05):Start()
					
	fun = function ()
		SMovie_System.Upload(''..m_name)
	end
	Timer.New(fun, 1):Start()
	
end

function SMovie_System.CanOver(m_name)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if SMovie_System[m_name]['OverTiming'] == 1 then
		SMovie_System.Upload(''..m_name)
	end
end

function SMovie_System.MovieDataCleaning(m_name)
	--CL:SpiritPossessionToPuppetNpc(0)  此处要补充角色镜头归为
	
	CL.SetTypeRoleVisible(true , eRoleType.Npc)
	CL.SetTypeRoleVisible(true , eRoleType.Player)
	CL.SetTypeRoleVisible(true , eRoleType.Pet)
	CL.SetTypeRoleVisible(true , eRoleType.Guard)
	
	Movie_Edge.Destroy()
	GUI.SetCameraLayer(eLayer.UI)
	LD.SetCameraTarget('0')
	if tablecount(SMovie_System[m_name]['NPC']) > 0 then
		for k,v in pairs(SMovie_System[m_name]['NPC']) do
			CL.DeleteRole(v)
		end
	end
	if tablecount(SMovie_System[m_name]['EFFECT']) > 0 then
		local EffectTable = SMovie_System[m_name]['EffectTable']
		for k,v in pairs(SMovie_System[m_name]['EFFECT']) do
			local e_table = EffectTable[k]
			if not e_table['target'] or e_table['target'] == "" then
				LD.DestroyEffect(0,v)
			else
				if e_table['target'] then
					local npc = e_table['target']
					if SMovie_System[m_name]['NPC'][npc] then
						LD.DestroyEffect(SMovie_System[m_name]['NPC'][npc],v)
					end
				end
			end
		end
	end
	if tablecount(SMovie_System[m_name]['IMG']) > 0 then
		for k,v in pairs(SMovie_System[m_name]['IMG']) do
			--挨个删除图片
			Movie_Edge.RemoveImg(v)
			--SMovie_System[m_name]['IMG']['img'..k] = nil
		end
	end
	if tablecount(SMovie_System[m_name]['WORD']) > 0 then
		for k,v in pairs(SMovie_System[m_name]['WORD']) do
			--挨个删除文字
			--SMovie_System[m_name]['WORD']['wrd'..k] = nil
		end
	end
	
	--if CL:JudgeIsStageCurtainShow() == true then
		
	--end
	SMovie_System['MovieName'] = ""
	LD.SetMovieMode(false)
	MoviePlaying = 0
	GlobalProcessing.WndCloseCallBack("NpcDialogBoxUI")

	--增加引导查看
	MainUI.OnMovieDialogFinish()
end

function SMovie_System.CameraEx(m_name, npc, frame) --（SMovie_103 , npc2 , 1）
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if frame == nil or frame == "" then
		LD.SetCameraTarget(tostring(SMovie_System[m_name]['NPC'][npc] or "0"))
		SMovie_System[m_name]['Camera'] = tostring(SMovie_System[m_name]['NPC'][npc])
		-- 镜头跟随NPC  CL:SpiritPossessionToPuppetNpc(SMovie_System[m_name]['NPC'][npc])
	else
		frame = tonumber(frame)
		if frame == SMovie_System[m_name]['frame'] then
			LD.SetCameraTarget(tostring(SMovie_System[m_name]['NPC'][npc] or "0"))
			SMovie_System[m_name]['Camera'] = tostring(SMovie_System[m_name]['NPC'][npc])
			-- 镜头跟随NPC  CL:SpiritPossessionToPuppetNpc(SMovie_System[m_name]['NPC'][npc])
		end
	end
	--CL:LogToChatWindow("ssssssssssss");
end

function SMovie_System.Upload(m_name, str)
	if Movie_Edge.IsEdging == false and SMovie_System[m_name]['OverTrigger'] == 0 then
		SMovie_System.MovieDataCleaning(m_name)
		print("------------------MovieEnd = "..m_name)
		CL.SendNotify(NOTIFY.SubmitForm,"FormMovie","MovieEnd",m_name)
		SMovie_System[m_name]['OverTrigger'] = 1
	end
end

function SMovie_System.AntiBlocking(m_name, frame)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if tostring(SMovie_System[m_name]['frame']) ~= frame then
		return
	end
	if Movie_Edge.IsEdging == true then
		Movie_Edge.Destroy()
	end
	SMovie_System.MovieOver(m_name)
end



------------NPC模块------------
function SMovie_System.NPCMod(m_name)

	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	
	
	local NpcTable = SMovie_System[m_name]['NpcTable']
	if NpcTable then
		for i = 1,tablecount(NpcTable) do
			if NpcTable['npc'..i] then
				if SMovie_System.NpcBornCheck( m_name, i) == true then
					if NpcTable['npc'..i]['Basic']['Occtime'] == 0 then
						SMovie_System.NPCCreat(m_name, i)
					else
						local fun = function ()
								SMovie_System.NPCCreat('' .. m_name, "" .. i)
							end
						Timer.New(fun, NpcTable['npc'..i]['Basic']['Occtime']):Start()
					end
				end
				if SMovie_System.NpcDelCheck( m_name, i) == true then
					if NpcTable['npc'..i]['Basic']['Exttime'] == 0 then
						SMovie_System.NPCDelete(m_name, i)
					else
						local fun = function ()
								SMovie_System.NPCDelete('' .. m_name, "" .. i)
							end
						Timer.New(fun, NpcTable['npc'..i]['Basic']['Exttime']):Start()
					end
				end
				if SMovie_System[m_name]['frame'] > 0 then
					local Frame = SMovie_System[m_name]['frame']
					if NpcTable['npc'..i]['Frame' .. Frame] then
						SMovie_System.NPCFrameActor(m_name, i)
					end
				end
			end
		end
	end
end

function SMovie_System.NPCCreat(m_name, index)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	
	if SMovie_System.NpcBornCheck( m_name, index) == true then
		local NpcTable = SMovie_System[m_name]['NpcTable']
		local npcdata = NpcTable['npc' .. index]['Basic'] --Basic = {id = 30029, name = "说书人", Occtime = 0, OccFrame = 1, Exttime = 90, ExitFrame = 9, posx = 131, posy = 29, dir = 5},

		if npcdata['id'] == 0 then
			--创建剧情角色 
			local npcID = CL.CreatePuppetRole(0, eRoleType.Player, SMovie_System_SeverData[m_name .. "_player_posx"] or npcdata['posx'], SMovie_System_SeverData[m_name .. "_player_posy"] or npcdata['posy'], -1, false)
			SMovie_System[m_name]['NPC']['npc'..index] = npcID
			SMovie_System[m_name]['NPC'][''..tostring(npcID)..'_isLead'] = 1
			local dir = npcdata['dir']
			--[[此段需要更新(获取主角的转向值)
			if SMovie_System_SeverData[m_name .. "_player_posx"] then
				if CL:GetPlayerSelfPropBase(ROLE_PROP_ROLENAME) then
					if UI:Lua_GetRoleDirectionByName(""..LuaRet) then
						dir = LuaRet
					end
				end
			end
			]]
			CL.SetPuppetRoleDir(SMovie_System[m_name]['NPC']['npc'..index],dir)
			SMovie_System[m_name]['DYE']['npc'..index..'_1'] = CL.GetIntAttr(RoleAttr.RoleAttrColor1)
			SMovie_System[m_name]['DYE']['npc'..index..'_2'] = CL.GetIntAttr(RoleAttr.RoleAttrColor2)
		else
			local npcID = CL.CreatePuppetRole(npcdata['id'], eRoleType.Npc, npcdata['posx'], npcdata['posy'], npcdata['dir'], npcdata['hide'] or false)
			SMovie_System[m_name]['NPC'][''..tostring(npcID) ..'_isLead'] = 1
			SMovie_System[m_name]['NPC']['npc'..index] = npcID
			SMovie_System[m_name]['MODEL']['npc'..index] = DB.GetOnceNpcByKey1(tonumber(npcdata['id'])).Model
			SMovie_System[m_name]['DYE']['npc'..index..'_1'] = DB.GetOnceNpcByKey1(tonumber(npcdata['id'])).ColorId or 0
			SMovie_System[m_name]['DYE']['npc'..index..'_2'] = nil
			--test("npcID = " .. npcdata['id'] .. "                   ColorId = " .. DB.GetOnceNpcByKey1(tonumber(npcdata['id'])).ColorId)
		end
		--加入染色效果--------------------------------
		--if npcdata['Dye'] then
		--	CL:SetPuppetDyePlan(SMovie_System[m_name]['NPC']['npc'..index], npcdata['Dye'] or 0)
		--end
		----------------------------------------------
		--[[摄像机跟随指定NPC]]
		if SMovie_System[m_name]['GlobalConfig']['LeadingActor'] == 'npc' .. index then
			LD.SetCameraTarget(tostring(SMovie_System[m_name]['NPC']['npc'..index] or "0"))
			SMovie_System[m_name]['Camera'] = tostring(SMovie_System[m_name]['NPC']['npc'..index])
		end

		if npcdata['name'] ~= "" then
			if npcdata['name'] == "player" then
				CL.SetRoleName(CL.GetRoleName() , SMovie_System[m_name]['NPC']['npc'..index])
			else
				CL.SetRoleName(npcdata['name'] , SMovie_System[m_name]['NPC']['npc'..index])
			end
		end
		local action = {}
		local ifAll = 1
		if SMovie_System[m_name]['frame'] > 0 then
			--CL:LogToChatWindow("Step0 = " .. SMovie_System[m_name]['frame']);
			if NpcTable['npc' .. index]['Frame' .. SMovie_System[m_name]['frame']] then
				action = NpcTable['npc' .. index]['Frame' .. SMovie_System[m_name]['frame']]
			end
			ifAll = 0
		else
			action = NpcTable['npc' .. index]
		end
		if action['Action1'] then
			for i = 1, tablecount(action)-ifAll do
				if action['Action'..i] then
					if action['Action'..i]['ActionTime'] > 0 then
						local fun = function()
							SMovie_System.NPCAct(''..m_name, ""..index, ""..i)
						end
						Timer.New(fun, action['Action'..i]['ActionTime']):Start()
					end
				end
			end
		end
	end
end

function SMovie_System.NPCFrameActor(m_name, index)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if not SMovie_System[m_name]['NPC']['npc'..index] then
		return
	end
	local NpcTable = SMovie_System[m_name]['NpcTable']
	local Frame = SMovie_System[m_name]['frame']
	local action = {}
	if SMovie_System[m_name]['frame'] > 0 then
		--CL:LogToChatWindow("Step1 = " .. SMovie_System[m_name]['frame']);
		if NpcTable['npc' .. index]['Frame' .. Frame] then
			action = NpcTable['npc' .. index]['Frame' .. SMovie_System[m_name]['frame']]
			if action['Action1'] then
				for i = 1, tablecount(action) do
					if action['Action'..i] then
						if action['Action'..i]['ActionTime'] > 0 then
							local fun = function()
							SMovie_System.NPCAct(''..m_name, ""..index, ""..i)
						end
						Timer.New(fun, action['Action'..i]['ActionTime']):Start()
						elseif action['Action'..i]['ActionTime'] == 0 then
							SMovie_System.NPCAct(m_name, index, i)
						end
					end
				end
			end
		end
	end
end

function SMovie_System.NPCAct(m_name, index, act)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if not SMovie_System[m_name]['NPC']['npc'..index] then
		return
	end
	local NpcTable = SMovie_System[m_name]['NpcTable']
	local action = {}
	if SMovie_System[m_name]['frame'] > 0 then
		--CL:LogToChatWindow("Step1 = " .. SMovie_System[m_name]['frame']);
		if NpcTable['npc' .. index]['Frame' .. SMovie_System[m_name]['frame']] then
			action = NpcTable['npc' .. index]['Frame' .. SMovie_System[m_name]['frame']]			
		end
	else
		action = NpcTable['npc' .. index]
	end
	
	if action['Action'..act] then
		local a_table = action['Action'..act]
		if a_table['ActType'] == "说话" then
			--[[对话泡泡]]
			CL.SendNotify(NOTIFY.ShowChatBBMsg , 1 , a_table['ActData'][1], tostring(SMovie_System[m_name]['NPC']['npc'..index]))
			
		elseif a_table['ActType'] == "动作" then
			--CL:LogToChatWindow("进行动作  ");
			LD.SetPuppetRoleAction(SMovie_System[m_name]['NPC']['npc'..index],a_table['ActData'][1],1,0,
							a_table['ActData'][2] == 1 and eAniamtionWrapMode.Loop or eAniamtionWrapMode.Once,
							a_table['ActData'][2] == 2 and eRoleMovement.NONE or eRoleMovement.STAND_W1)
		elseif a_table['ActType'] == "移动" then
			--test('move_1 = ' .. a_table['ActData'][1].. '               move_2 = ' .. a_table['ActData'][2])
			CL.SetPuppetRoleAutoMove(SMovie_System[m_name]['NPC']['npc'..index], a_table['ActData'][1], CL.ChangeLogicPosZ(a_table['ActData'][2]))
		elseif a_table['ActType'] == "转身" then
			CL.SetPuppetRoleDir(SMovie_System[m_name]['NPC']['npc'..index], a_table['ActData'][1])
		end
	end
end

function SMovie_System.NPCDelete(m_name, index)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if SMovie_System.NpcDelCheck( m_name, index) == true then
		if SMovie_System[m_name]['NPC']['npc'..index] then
			--test(" 1 = " .. SMovie_System[m_name]['Camera'] .. "          2 = " .. tostring(SMovie_System[m_name]['NPC']['npc'..index]))
			if SMovie_System[m_name]['Camera'] == tostring(SMovie_System[m_name]['NPC']['npc'..index]) then
				LD.SetCameraTarget("0")
				SMovie_System[m_name]['Camera'] = ""
			end
			--CL.DeleteRole(SMovie_System[m_name]['NPC']['npc'..index])
			CL.SetRoleVisible(tostring(SMovie_System[m_name]['NPC']['npc'..index]), false) --, eRoleType.Puppet
			--GUI.SetVisible(SMovie_System[m_name]['NPC']['npc'..index], false)
			--if Movie_Edge then
			--	Movie_Edge.RemoveRole(SMovie_System[m_name]['NPC']['npc'..index])
			--end
			--SMovie_System[m_name]['NPC']['npc'..index] = nil
		end
	end
end

function SMovie_System.NpcBornCheck( m_name, index)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if SMovie_System[m_name]['frame'] == 0 then
		return true
	elseif SMovie_System[m_name]['frame'] > 0 then
		local NpcTable = SMovie_System[m_name]['NpcTable']
		if NpcTable['npc'..index]['Basic'] then
			if NpcTable['npc'..index]['Basic']['OccFrame'] == SMovie_System[m_name]['frame'] then
				return true
			end
		end
	end
	return false
end

function SMovie_System.NpcDelCheck( m_name, index)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if SMovie_System[m_name]['frame'] == 0 then
		return true
	elseif SMovie_System[m_name]['frame'] > 0 then
		local NpcTable = SMovie_System[m_name]['NpcTable']
		if NpcTable['npc'..index]['Basic'] then
			if NpcTable['npc'..index]['Basic']['ExitFrame'] == SMovie_System[m_name]['frame'] then
				return true
			end
		end
	end
	return false
end

------------特效模块------------
function SMovie_System.EFTMod(m_name)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	local EffectTable = SMovie_System[m_name]['EffectTable']
	if EffectTable then
		for i = 1,tablecount(EffectTable) do
			if EffectTable['eft'..i] then
				if SMovie_System.ObjBornCheck( m_name, EffectTable['eft'..i]) == true then
					local fun = function()
						SMovie_System.EftCreat(''..m_name, ''..i)
					end
					Timer.New(fun, EffectTable['eft'..i]['start']):Start()
				end
				if SMovie_System.ObjExitCheck( m_name, EffectTable['eft'..i]) == true then
					local fun = function()
						SMovie_System.EftDelete(''..m_name, ''..i)
					end
					Timer.New(fun, EffectTable['eft'..i]['ext']):Start()
				end
			end
		end
	end
end

function SMovie_System.EftCreat(m_name, index)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	local EffectTable = SMovie_System[m_name]['EffectTable']
	if SMovie_System.ObjBornCheck( m_name, EffectTable['eft'..index]) == true then
		if EffectTable['eft'..index] then
			local e_table = EffectTable['eft'..index]
			if not e_table['target'] or e_table['target'] == "" then
				--SMovie_System[m_name]['EFFECT']['eft'..index] = CL:AddMagicToPoint(e_table['id'], e_table['posx'], e_table['posy'], 0, 0)
				SMovie_System[m_name]['EFFECT']['eft'..index] = CL.CreateEffect(e_table['id'],0,e_table['posx'],0,e_table['posy'],1,-1)
			else
				if e_table['target'] then
					local npc = e_table['target']
					if SMovie_System[m_name]['NPC'][npc] then
						--CL:LogToChatWindow("NPC存在测试1" .. SMovie_System[m_name]['NPC'][npc]);
						--SMovie_System[m_name]['EFFECT']['eft'..index] = CL:AddMagicToRole(e_table['id'], ""..SMovie_System[m_name]['NPC'][npc], 0, 0)
						SMovie_System[m_name]['EFFECT']['eft'..index] = CL.CreateEffect(e_table['id'],SMovie_System[m_name]['NPC'][npc],0,0,0,1,-1)
						--CL:LogToChatWindow("NPC存在测试2");
					end
				end
			end
		end
	end
end

function SMovie_System.EftDelete(m_name, index)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	local EffectTable = SMovie_System[m_name]['EffectTable']
	if SMovie_System.ObjExitCheck( m_name, EffectTable['eft'..index]) == true then
		if SMovie_System[m_name]['EFFECT']['eft'..index] then
			local e_table = EffectTable['eft'..index]
			if not e_table['target'] or e_table['target'] == "" then
				LD.DestroyEffect(0,SMovie_System[m_name]['EFFECT']['eft'..index])
			else
				if e_table['target'] then
					local npc = e_table['target']
					if SMovie_System[m_name]['NPC'][npc] then
						LD.DestroyEffect(SMovie_System[m_name]['NPC'][npc],SMovie_System[m_name]['EFFECT']['eft'..index])
						SMovie_System[m_name]['EFFECT']['eft'..index] = nil
					end
				end
			end
		end
	end
end

------------图片模块------------
function SMovie_System.IMGMod(m_name)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	
	local ImageTable = SMovie_System[m_name]['ImageTable']
	if ImageTable then
		for i = 1,tablecount(ImageTable) do
			if ImageTable['img'..i] then
				local i_table = ImageTable['img'..i]
				local pic = 0			
				if type(i_table['id']) == "table" then
					pic = i_table['id'][math.random(1,#i_table['id'])]
				else
					pic = i_table['id']
				end
				if SMovie_System.ObjBornCheck( m_name, i_table) == true then
					--[[创建图片并进行图片移动/各种值的变化	]]
					SMovie_System[m_name]['IMG']['img'..i] = Movie_Edge.CreatImage(pic, i_table['posx'], i_table['posy'], i_table['isfullscrean'] or false,i_table['linkpoint'] or "TopLeft")
					local fun = function()
						Movie_Edge.ImageAlpha(SMovie_System[m_name]['IMG']['img'..i], 0, 1, i_table['s_consume'])
					end
					Timer.New(fun, i_table['start']):Start()
				end
				if SMovie_System.ObjExitCheck( m_name, i_table) == true then
					local fun = function()
						Movie_Edge.ImageAlpha(SMovie_System[m_name]['IMG']['img'..i], 1, 0, i_table['e_consume'])
					end
					Timer.New(fun, i_table['ext']):Start()
					fun = function()
						SMovie_System.IMGDelete(''..m_name, ''..SMovie_System[m_name]['IMG']['img'..i])
					end
					Timer.New(fun, i_table['ext'] + i_table['e_consume']):Start()
				end
			end
		end
	end
end

function SMovie_System.IMGDelete(m_name, index)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	
	local ImageTable = SMovie_System[m_name]['ImageTable']
	if ImageTable then	
		if ImageTable['img'..index] then
			Movie_Edge.RemoveImg(index)
			--[[删除图片系列
			local i_table = ImageTable['img'..index]
			CL:RemoveImgEffectDisplay(0, i_table['e_consume'], SMovie_System[m_name]['IMG']['img'..index], i_table['e_type'], 0, 0, i_table['posx'], i_table['posy']);
			]]
		end
	end
end

------------文字模块------------

function SMovie_System.WRDMod(m_name)
	--[[文字模块暂时无用
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	local WordTable = SMovie_System[m_name]['WordTable']
	if WordTable then
		for i = 1,tablecount(WordTable) do
			if WordTable['wrd'..i] then
				
				local i_table = WordTable['wrd'..i]
				if SMovie_System.ObjBornCheck( m_name, i_table) == true then
					SMovie_System[m_name]['WORD']['word'..i] = CL:WordsEffectDisplay(i_table['start'], i_table['s_consume'], i_table['str'], i_table['s_type'], 0, 0, i_table['posx'], i_table['posy'],i_table['tff']);
				end
				if SMovie_System.ObjExitCheck( m_name, i_table) == true then
					CL:RemoveWordsEffectDisplay(i_table['ext'], i_table['e_consume'], SMovie_System[m_name]['WORD']['word'..i], i_table['e_type'], 0, 0, i_table['posx'], i_table['posy']);
					--SMovie_System[m_name]['WORD']['word'..i] = nil
				end
			end
		end
	end
	]]
end

------------压边对话模块------------
function SMovie_System.TLKMod(m_name)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	SMovie_System[m_name]['CanClick'] = 1
	Movie_Edge['CanClick'] = true
	local talker = 0
	local GlobalConfig = SMovie_System[m_name]['GlobalConfig']
	local TalkTable = SMovie_System[m_name]['TalkTable']
	local Frame = SMovie_System[m_name]['frame']
	if GlobalConfig['FrameTable'] then
		if GlobalConfig['FrameTable']['Frame' .. Frame] then
			if GlobalConfig['FrameTable']['Frame' .. Frame]['FrameType'] == '压边对话' then
				if GlobalConfig['FrameTable']['Frame' .. Frame]['FrameTalk'] then
					local talk = GlobalConfig['FrameTable']['Frame' .. Frame]['FrameTalk']
					if TalkTable[talk] then
						if tablecount(TalkTable[talk]) > 0 then
							talker = 1
						end
					end
				end
			end
		end
	end
	
	if talker == 1 then
		SMovie_System['TalkRate'] = 1
		SMovie_System.NpcTalk(m_name)
	else
		SMovie_System.FrameOver(m_name)
	end
end

function SMovie_System.NpcTalk(m_name)
	if not m_name then
		test("动画信息调用失败 _ 错误码 00000x012")
	end
	if SMovie_System['MovieName'] ~= m_name then
		test("动画信息调用失败 _ 错误码 00000x013")
		return
	end
	if SMovie_System[m_name]['OverTiming'] == 1 then
		return
	end
	if SMovie_System[m_name]['CanClick'] == 0 then
		--local temp0 = CL:AddDelayTask("SMovie_System.AllowClick", 1000, 1)
		--CL:TaskSetParam(temp0, "clickdata_1", ''..m_name)
		return
	end
	local Frame = SMovie_System[m_name]['frame']
	local GlobalConfig = SMovie_System[m_name]['GlobalConfig']
	local talk = GlobalConfig['FrameTable']['Frame' .. Frame]['FrameTalk'] --TalkList1
	local TalkList = SMovie_System[m_name]['TalkTable'][talk]
	if not TalkList then
		return
	end
	if TalkList['TalkData' .. SMovie_System['TalkRate']] and SMovie_System[m_name]['Escing'] ~= 1 then
		local data = TalkList['TalkData' .. SMovie_System['TalkRate']]
		local npcID = SMovie_System[m_name]['NPC'][data['Npc']] --data['Npc'] == "npc6"
		if data['NpcAction'] then
			if type(data['NpcAction']) == 'table' then
				if data['NpcAction'][1] then
					if data['NpcAction'][1] ~= -1 then
						LD.SetPuppetRoleAction(npcID,data['NpcAction'][1],1,0,
							data['NpcAction'][2] == 1 and eAniamtionWrapMode.Loop or eAniamtionWrapMode.Once,
							data['NpcAction'][2] == 0 and eRoleMovement.STAND_W1 or eRoleMovement.NONE)
						-- , data['NpcAction'][2] or 0
					end
				end
			end
		end
		if data['NpcPop'] then
			if data['NpcPop'] ~= "" then
				--[[对话泡泡部分]]
				CL.SendNotify(NOTIFY.ShowChatBBMsg , 1 , data['NpcPop'], tostring(npcID))
				
			end
		end
		if data['NpcMove'] then
			if type(data['NpcMove']) == 'table' then
				if data['NpcMove'][1] then
					if data['NpcMove'][1] ~= -1 then
						CL.SetPuppetRoleAutoMove(npcID,data['NpcMove'][1], CL.ChangeLogicPosZ(data['NpcMove'][2]))
					end
				end
			end
		end
		--CL:LogToChatWindow("sssssssssssssssssssssss");
		--local temp1 = CL:AddDelayTask("SMovie_System.AllowClick", 1000, 1)
		--CL:TaskSetParam(temp1, "clickdata_1", ''..m_name)
		--CL:TaskSetParam(temp1, "clickdata_2", ''..Frame)
		--CL:TaskSetParam(temp1, "clickdata_3", ''..SMovie_System['TalkRate'])
		SMovie_System['TalkRate'] = SMovie_System['TalkRate'] + 1
		--npcID = tostring(npcID)
		--test(" npcid = " .. npcID )
		if SMovie_System[m_name]['NPC'][''..tostring(npcID)..'_isLead']  then
			Movie_Edge.NowNPCisLead = 1
		else
			Movie_Edge.NowNPCisLead = 0
		end
		Movie_Edge.NpcTalk(npcID, SMovie_System[m_name]['MODEL'][data['Npc']] or -1, SMovie_System[m_name]['DYE'][data['Npc'].."_1"] or -1, SMovie_System[m_name]['DYE'][data['Npc'].."_2"] or -1, data['Content'], "SMovie_System.NpcTalk", "" .. m_name)
		SMovie_System[m_name]['CanClick'] = 0
		Movie_Edge['CanClick'] = false
		local flag = SMovie_System['TalkRate']
		
		local fun = function()
				SMovie_System.AllowClick(''..m_name, ''..Frame, ''..flag)
			end
		Timer.New(fun, 0.1):Start()

		local Delay = 30
		if data['ClickDelay'] then
			Delay = data['ClickDelay']
		end
		
		fun = function()
				SMovie_System.AutoClick(''..m_name, ''..Frame, ''..flag)
			end
		Timer.New(fun, Delay):Start()
	else
		--不需要的 关闭对话框 CL:SetMovieUITalkCurtain(false, 0, "", "", "")
		--test("---------------------------------结束本帧对话")
		SMovie_System.FrameOver(m_name)
	end
end

function SMovie_System.AutoClick(m_name, frame, flag)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if tostring(SMovie_System[m_name]['frame']) ~= frame then
		return
	end
	if tostring(SMovie_System['TalkRate']) ~= flag then
		return
	end
	Movie_Edge.OnScreenClick()
	SMovie_System.NpcTalk(m_name)
end

function SMovie_System.AllowClick(m_name, frame, flag)
	if SMovie_System['MovieName'] ~= m_name then
		test("点击事件中m_name参数不匹配")
		return
	end
	if tostring(SMovie_System[m_name]['frame']) ~= frame then
		test("点击事件中frame参数不匹配")
		return
	end
	if tostring(SMovie_System['TalkRate']) ~= flag then
		test("点击事件中flag参数不匹配")
		return
	end
	SMovie_System[m_name]['CanClick'] = 1
	Movie_Edge['CanClick'] = true
end


------------Frame判定模块------------
function SMovie_System.ObjBornCheck( m_name, i_table)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if SMovie_System[m_name]['frame'] == 0 then
		return true
	elseif SMovie_System[m_name]['frame'] > 0 then
		if i_table['s_frame'] == SMovie_System[m_name]['frame'] then
			return true
		end
	end
	return false
end

function SMovie_System.ObjExitCheck( m_name, i_table)
	if SMovie_System['MovieName'] ~= m_name then
		return
	end
	if SMovie_System[m_name]['frame'] == 0 then
		return true
	elseif SMovie_System[m_name]['frame'] > 0 then
		if i_table['e_frame'] == SMovie_System[m_name]['frame'] then
			return true
		end
	end
	return false
end

SMovie_System.Main()