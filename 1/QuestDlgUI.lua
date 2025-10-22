QuestDlgUI = {}

local JIN_DOU_YUN_ID = 31022
QuestDlgUI.AllQuests = nil
QuestDlgUI.SelectQuestI = 0
QuestDlgUI.SelectQuestJ = 0
local _gt = UILayout.NewGUIDUtilTable()

function QuestDlgUI.Main( parameter )
	QuestDlgUI.IsFirstShow = 1
	_gt = UILayout.NewGUIDUtilTable()
	print("QuestDlgUI lua ")
	
    local _Panel = GUI.WndCreateWnd("QuestDlgUI", "QuestDlgUI", 0, 0, eCanvasGroup.Normal)

	--创建背景
	local _GreyBack = GUI.ImageCreate( _Panel, "GreyBack" , "1800400220" , 0 , 0 ,false, GUI.GetWidth(_Panel),GUI.GetHeight(_Panel));
    UILayout.SetSameAnchorAndPivot(_GreyBack, UILayout.Center)
	GUI.SetIsRaycastTarget(_GreyBack, true)
	_GreyBack:RegisterEvent(UCE.PointerClick)
	
    local _PanelBack = UILayout.CreateFrame_WndStyle0(_Panel, "任    务","QuestDlgUI", "OnClickCloseBtn", _gt)

	--已接页签
	local _ReceivedPage = GUI.CheckBoxCreate(_PanelBack,"ReceivedPage","1800402010","1800402011",-21,163,Transition.ColorTint,true)
    _gt.BindName(_ReceivedPage, "ReceivedPage")
    UILayout.SetSameAnchorAndPivot(_ReceivedPage, UILayout.TopRight)
	local _ReceivedPageTxt = GUI.CreateStatic( _ReceivedPage,"ReceivedPageTxt", "已\n接", -18, 0, 70, 58)
    _gt.BindName(_ReceivedPageTxt, "ReceivedPageTxt")
    UILayout.SetSameAnchorAndPivot(_ReceivedPageTxt, UILayout.Center)
    GUI.StaticSetFontSize(_ReceivedPageTxt, 24)
    GUI.SetColor(_ReceivedPageTxt, UIDefine.Brown5Color)
    GUI.SetIsRaycastTarget(_ReceivedPageTxt, false)
	GUI.RegisterUIEvent(_ReceivedPage , UCE.PointerClick , "QuestDlgUI", "OnReceivedPage" )
	
	--未接页签
	local _NoReceivedPage = GUI.CheckBoxCreate(_PanelBack,"NoReceivedPage","1800402010","1800402011",-21,275,Transition.ColorTint,false)
    _gt.BindName(_NoReceivedPage, "NoReceivedPage")
    UILayout.SetSameAnchorAndPivot(_NoReceivedPage, UILayout.TopRight)
	local _NoReceivedPageTxt = GUI.CreateStatic( _NoReceivedPage,"NoReceivedPageTxt", "未\n接", -18, 0, 70, 58)
    _gt.BindName(_NoReceivedPageTxt, "NoReceivedPageTxt")
    UILayout.SetSameAnchorAndPivot(_NoReceivedPageTxt, UILayout.Center)
    GUI.StaticSetFontSize(_NoReceivedPageTxt, 24)
    GUI.SetColor(_NoReceivedPageTxt, UIDefine.Brown7Color)
    GUI.SetIsRaycastTarget(_NoReceivedPageTxt, false)
	GUI.RegisterUIEvent(_NoReceivedPage , UCE.PointerClick , "QuestDlgUI", "OnNoReceivedPage" )

	--是否使用筋斗云勾选框
	local _IsUseCheck = GUI.CheckBoxCreate(_PanelBack,"IsUseCheck","1800607150","1800607151",886,83,Transition.ColorTint,MainUI.IsJindouyunTransfer)
    _gt.BindName(_IsUseCheck, "IsUseCheck")
    UILayout.SetSameAnchorAndPivot(_IsUseCheck, UILayout.TopLeft)
	GUI.RegisterUIEvent(_IsUseCheck , UCE.PointerClick , "QuestDlgUI", "OnIsUseCheck" )
	local _Title = GUI.CreateStatic( _IsUseCheck,"Title", "默认使用筋斗云传送", 30, -15, 200, 30)
    UILayout.SetSameAnchorAndPivot(_Title, UILayout.TopLeft)
	GUI.StaticSetFontSize(_Title, 22)
	GUI.SetColor(_Title, UIDefine.Brown4Color)
	GUI.SetIsRaycastTarget(_Title, true)
	GUI.RegisterUIEvent(_Title , UCE.PointerClick , "QuestDlgUI", "OnIsUseCheck" )

	--左侧任务列表底板
	local _MissionLstBack = GUI.ImageCreate( _PanelBack,"MissionLstBack", "1800400200", 78, 60, false, 314, 558)
    UILayout.SetSameAnchorAndPivot(_MissionLstBack, UILayout.TopLeft)

	local _ListScroll  = GUI.ScrollListCreate(_MissionLstBack,"ListScroll", 8, 4, 298, 550, false, UIAroundPivot.Top,UIAnchor.Top)
	_gt.BindName(_ListScroll, "ListScroll")
    UILayout.SetSameAnchorAndPivot(_ListScroll, UILayout.TopLeft)
	_ListScroll:RegisterEvent(UCE.PointerClick)

	--任务详情底板
    local _DetailBack = GUI.ImageCreate( _PanelBack,"DetailBack", "1800400200", 406, 105, false, 712, 512)
	_gt.BindName(_DetailBack, "DetailBack")
    UILayout.SetSameAnchorAndPivot(_DetailBack, UILayout.TopLeft)

	--滚动区域
	local _DetailScroll = GUI.ScrollRectCreate(_DetailBack,"DetailScroll",0,4,710,430,0,false,Vector2.New(0,0),UIAroundPivot.Top,UIAnchor.Top, 2)
    _gt.BindName(_DetailScroll, "DetailScroll")
    UILayout.SetSameAnchorAndPivot(_DetailScroll, UILayout.TopLeft)
	GUI.ScrollRectSetChildSpacing(_DetailScroll,Vector2.New(0,0))
	GUI.ScrollRectSetNormalizedPosition(_DetailScroll,Vector2.New(0,0))
	_DetailScroll:RegisterEvent(UCE.PointerClick)

	local _DetailScrollLst = GUI.ImageCreate( _DetailScroll,"DetailScrollLst", "1800499999", 0, 0)
    _gt.BindName(_DetailScrollLst, "DetailScrollLst")
    UILayout.SetSameAnchorAndPivot(_DetailScrollLst, UILayout.TopLeft)
	
	--放弃任务
	local _GiveUpBtn = GUI.ButtonCreate(_DetailBack,"GiveUpBtn", "1800602030",112,450, Transition.ColorTint, "放弃任务")
    _gt.BindName(_GiveUpBtn, "GiveUpBtn")
    UILayout.SetSameAnchorAndPivot(_GiveUpBtn, UILayout.TopLeft)
	GUI.ButtonSetTextFontSize(_GiveUpBtn, 26)
	GUI.ButtonSetTextColor(_GiveUpBtn, UIDefine.WhiteColor)
	GUI.SetIsOutLine(_GiveUpBtn,true)
	GUI.SetOutLine_Color(_GiveUpBtn,UIDefine.Orange2Color)
	GUI.SetOutLine_Distance(_GiveUpBtn,1)
	GUI.RegisterUIEvent(_GiveUpBtn , UCE.PointerClick , "QuestDlgUI", "OnGiveUpBtn" )

	--前往领取
	local _GoToBtn = GUI.ButtonCreate(_DetailBack,"GoToBtn", "1800602030",446,450, Transition.ColorTint, "前往领取")
    _gt.BindName(_GoToBtn, "GoToBtn")
    UILayout.SetSameAnchorAndPivot(_GoToBtn, UILayout.TopLeft)
	GUI.ButtonSetTextFontSize(_GoToBtn, 26)
	GUI.ButtonSetTextColor(_GoToBtn, UIDefine.WhiteColor)
	GUI.SetIsOutLine(_GoToBtn,true)
	GUI.SetOutLine_Color(_GoToBtn,UIDefine.Orange2Color)
	GUI.SetOutLine_Distance(_GoToBtn,1)
	GUI.RegisterUIEvent(_GoToBtn , UCE.PointerClick , "QuestDlgUI", "OnGoToBtn" )

	--显示任务列表
	QuestDlgUI.ShowMissionTypeLst()
	
	--注册消息
	CL.RegisterMessage(GM.QuestInfoUpdate,"QuestDlgUI" , "OnQuestInfoUpdate")

	--默认展开所有项
	QuestDlgUI.OnShowAllTypeList()
end

-- function QuestDlgUI.OnShow()
	-- QuestDlgUI.IsFirstShow = 1
	-- QuestDlgUI.ShowMissionTypeLst()
-- end

function QuestDlgUI.OnDestroy()
	CL.UnRegisterMessage(GM.QuestInfoUpdate, "QuestDlgUI", "OnQuestInfoUpdate")
end

function QuestDlgUI.OnQuestInfoUpdate(Type)
	test("刷新任务数据，QuestDlgUI Lua")
	if Type == 0 then
		QuestDlgUI.ShowQuestDetail()
		QuestDlgUI.ShowMissionTypeLst()
	elseif Type == 1 then
		QuestDlgUI.ShowMissionTypeLst()
	end
end

function QuestDlgUI.OnGiveUpBtn()
	local Quest = QuestDlgUI.AllQuests[QuestDlgUI.SelectQuestI][QuestDlgUI.SelectQuestJ]
	if Quest.can_abandon then
		CL.SendNotify(NOTIFY.QuestOpeUpdate, 1, Quest.quest_id)
		QuestDlgUI.SelectQuestI = 0
		QuestDlgUI.SelectQuestJ = 0
	else
		CL.SendNotify(NOTIFY.ShowBBMsg, "该任务无法放弃")
	end
end

function QuestDlgUI.ParseJindouyuntransfer(id)
	local DirTransfer = false
	--如果存在道具筋斗云则直接传送
	if CL.GetIntAttr(RoleAttr.RoleAttrPathfindingTransfer) == 0 and MainUI.IsJindouyunTransfer then
		if LD.GetItemCountById(JIN_DOU_YUN_ID) > 0 then
			CL.StopMove()
			CL.SendNotify(NOTIFY.SubmitForm,"FormJinDouYun","Main", id)
			DirTransfer = true
		end
	end
	return DirTransfer
end

function QuestDlgUI.OnGoToBtn()
	local Quest = QuestDlgUI.AllQuests[QuestDlgUI.SelectQuestI][QuestDlgUI.SelectQuestJ]
	if Quest ~= nil then
		local DirTransfer = QuestDlgUI.ParseJindouyuntransfer(Quest.quest_id)
		if not DirTransfer then
			CL.SendNotify(NOTIFY.QuestOpeUpdate, 2, Quest.quest_id)
		end
	end
	QuestDlgUI.OnClickCloseBtn()
end

function QuestDlgUI.OnIsUseCheck()
	local _IsUseCheck = _gt.GetUI("IsUseCheck")
	if _IsUseCheck ~= nil then
		local IsOn = GUI.CheckBoxGetCheck(_IsUseCheck)
		if TrackUI then
			TrackUI.EnableShowJindouyunBtn(IsOn)
		end
		MainUI.IsJindouyunTransfer = IsOn
	end
end

QuestDlgUI.MissionTypeCount = 0
QuestDlgUI.MissionSubTypeCounts = {}
function QuestDlgUI.ShowMissionTypeLst()
	local _ListScroll = _gt.GetUI("ListScroll")
	local _ReceivedPage = _gt.GetUI("ReceivedPage")
	local IsReceivedPage = GUI.CheckBoxGetCheck(_ReceivedPage)
	QuestDlgUI.AllQuests = LD.GetAllQuest(IsReceivedPage)
	local Count = QuestDlgUI.AllQuests.Count
	--设置放弃任务按钮的状态
	local _GiveUpBtn = _gt.GetUI("GiveUpBtn")
	if IsReceivedPage then
		GUI.SetVisible(_GiveUpBtn,Count~=0)
		if Count ==0 then
			local lst = LD.GetAllQuest(false)
			if lst.Count > 0 then
				if QuestDlgUI.IsFirstShow == 0 then
					CL.SendNotify(NOTIFY.ShowBBMsg, "当前没有已接取任务！")
				end
				QuestDlgUI.OnSwitchPage(false)
				--默认展开所有项
				QuestDlgUI.OnShowAllTypeList()				
				return
			end
			GUI.SetVisible(_GiveUpBtn,false)
		else
			GUI.SetVisible(_GiveUpBtn,true)
		end
	else
		GUI.SetVisible(_GiveUpBtn,false)
	end
    --test("QuestDlgUI.AllQuests Count : "..Count)
	if QuestDlgUI.MissionTypeCount < Count then
		QuestDlgUI.MissionTypeCount = Count
	end
	for i=1,QuestDlgUI.MissionTypeCount do
		local IsShow = (i<=Count)
		local TypeName = ""
		if IsShow then
			TypeName = QuestDlgUI.AllQuests[i-1][0].quest_type_name
			local TypeNameSplit = string.split(QuestDlgUI.AllQuests[i-1][0].quest_type_name, "$")
			if #TypeNameSplit == 2 then
				TypeName = TypeNameSplit[1]
			end
		end
		--父节点按钮
		local _ListTypeBtn = _gt.GetUI("ListTypeBtn"..i)
		local _ListType = _gt.GetUI("ListType"..i)
		if _ListTypeBtn == nil then
			if IsShow then
				_ListTypeBtn = GUI.ButtonCreate(_ListScroll,"ListTypeBtn"..i, "1800002030",0,0, Transition.ColorTint, TypeName, 298, 65, false)
				_gt.BindName(_ListTypeBtn, "ListTypeBtn"..i)
    UILayout.SetSameAnchorAndPivot(_ListTypeBtn, UILayout.TopLeft)
				GUI.ButtonSetTextFontSize(_ListTypeBtn, 26)
				GUI.ButtonSetTextColor(_ListTypeBtn, UIDefine.Brown4Color)
				GUI.RegisterUIEvent(_ListTypeBtn , UCE.PointerClick , "QuestDlgUI", "OnListTypeBtn" )
				GUI.SetPreferredHeight(_ListTypeBtn, 65)

				--方向箭头
				local Arrow = GUI.ImageCreate( _ListTypeBtn,"Arrow"..i, "1800607140", -30, 0)
                _gt.BindName(Arrow, "Arrow"..i)
    UILayout.SetSameAnchorAndPivot(Arrow, UILayout.Right)

				--子节点列表框
				_ListType  = GUI.ListCreate(_ListScroll, "ListType"..i, 6, 6, 298, 412)
                _gt.BindName(_ListType, "ListType"..i)
    UILayout.SetSameAnchorAndPivot(_ListType, UILayout.TopLeft)
				GUI.SetVisible(_ListType, false)
			end
		else
			GUI.SetVisible(_ListTypeBtn, IsShow)
			GUI.SetVisible(_ListType, false)

			if IsShow then
				GUI.ButtonSetText(_ListTypeBtn, TypeName)
			end
		end

		local SubCount = i-1<QuestDlgUI.AllQuests.Count and QuestDlgUI.AllQuests[i-1].Count or 0
		GUI.SetHeight(_ListType, 72 * SubCount)
		--子节点
		if IsShow then
			if QuestDlgUI.MissionSubTypeCounts[i] == nil or QuestDlgUI.MissionSubTypeCounts[i] < SubCount then
				QuestDlgUI.MissionSubTypeCounts[i] = SubCount
			end
			for j=1,QuestDlgUI.MissionSubTypeCounts[i] do
				local IsSubShow = (j<=SubCount)
				local SubTypeName = ""
				local TypeNameColor = UIDefine.Brown4Color
				if IsSubShow then
					SubTypeName = QuestDlgUI.AllQuests[i-1][j-1].quest_name
					local TypeNameSplit = string.split(QuestDlgUI.AllQuests[i-1][j-1].quest_name, "$")
					if #TypeNameSplit == 2 then
						SubTypeName = TypeNameSplit[1]
					end
					if QuestDlgUI.AllQuests[i-1][j-1].quest_state == 4 then --ready状态
						TypeNameColor = UIDefine.Green5Color
					end
				end

				local _ListTypeSubBtn = _gt.GetUI(tostring((i-1)*100+(j-1)))
				if _ListTypeSubBtn == nil then
					if IsSubShow then
						_ListTypeSubBtn = GUI.ButtonCreate(_ListType,tostring((i-1)*100+(j-1)), "1800602040",0,64, Transition.ColorTint, SubTypeName, 298, 65, false)
						_gt.BindName(_ListTypeSubBtn, tostring((i-1)*100+(j-1)))
    					UILayout.SetSameAnchorAndPivot(_ListTypeSubBtn, UILayout.TopLeft)
						GUI.ButtonSetTextFontSize(_ListTypeSubBtn, 26)
						GUI.ButtonSetTextColor(_ListTypeSubBtn, TypeNameColor)
						GUI.RegisterUIEvent(_ListTypeSubBtn , UCE.PointerClick , "QuestDlgUI", "OnListTypeSubBtn")
					end
				else
					GUI.SetVisible(_ListTypeSubBtn, IsSubShow)
					if IsSubShow then
						GUI.ButtonSetText(_ListTypeSubBtn, SubTypeName)
					end
				end
			end
		end
	end

	QuestDlgUI.OnListTypeBtn(nil, "ListTypeBtn"..(QuestDlgUI.SelectQuestI+1))
end

--展开所有项：第一项已做默认选中
function QuestDlgUI.OnShowAllTypeList()
	if QuestDlgUI.AllQuests ~= nil then
		local Count = QuestDlgUI.AllQuests.Count
		for i = 1, Count-1 do
			local _ListType = _gt.GetUI("ListType"..(i+1))
			if _ListType ~= nil then
				GUI.SetVisible(_ListType, true)
			end
		end
	end
end

function QuestDlgUI.OnListTypeBtn(guid, key)
	local btn = guid ~= nil and GUI.GetByGuid(guid) or nil
	local Name = btn ~= nil and GUI.GetName(btn) or key
	local Index = Name ~= nil and tonumber(string.sub(Name, 12)) or -1
	if Index == -1 then return end

	--展开选中项，折叠其余项
	local _ListType = _gt.GetUI("ListType"..Index)
	local TypeCount = QuestDlgUI.AllQuests.Count
	if _ListType ~= nil then
		local IsVisible = GUI.GetVisible(_ListType)
		GUI.SetVisible(_ListType, IsVisible==false and TypeCount>0)
	end

	--然后把其余展开项中，选中的子项取消
	QuestDlgUI.UnSelectOthers(Index)

	QuestDlgUI.SelectQuestI = Index-1
	QuestDlgUI.SelectQuestJ = 0
	QuestDlgUI.OnListTypeSubBtn(nil, tostring(QuestDlgUI.SelectQuestI*100+QuestDlgUI.SelectQuestJ))
end

function QuestDlgUI.UnSelectOthers(ExceptTypeIndex)
	local _ListType = _gt.GetUI("ListType"..ExceptTypeIndex)
	local Count = QuestDlgUI.AllQuests.Count
	for i=1,Count do
		if i ~= ExceptTypeIndex and _ListType ~= nil then
			_ListType = _gt.GetUI("ListType"..i)
			--if GUI.GetVisible(_ListType) then
				local SubCount = QuestDlgUI.AllQuests[i-1].Count
				for j = 1, SubCount do
					local _ListTypeBtn = _gt.GetUI(tostring((i-1)*100+j-1))
					if _ListTypeBtn ~= nil then
						GUI.ButtonSetImageID(_ListTypeBtn, 1800602040)
					end
				end
			--end
		end
	end
end

function QuestDlgUI.OnListTypeSubBtn(guid, key)
	local Btn = guid ~= nil and GUI.GetByGuid(guid) or nil
	local Name = Btn ~= nil and GUI.GetName(Btn) or key
	local Num = Name ~= nil and tonumber(Name) or -1
	if Num == -1 then return end

	QuestDlgUI.SelectQuestI = (Num-Num%100)/100
	QuestDlgUI.SelectQuestJ = Num%100
	--test("QuestDlgUI.SelectQuestI:"..QuestDlgUI.SelectQuestI..", QuestDlgUI.SelectQuestJ:"..QuestDlgUI.SelectQuestJ)

    if QuestDlgUI.AllQuests ~= nil then
        local Count = 0
		if QuestDlgUI.AllQuests.Count > 0 and QuestDlgUI.SelectQuestI >=0 and QuestDlgUI.SelectQuestI<QuestDlgUI.AllQuests.Count then
			Count = QuestDlgUI.AllQuests[QuestDlgUI.SelectQuestI].Count
		else

		end
        --test("QuestDlgUI.AllQuests Count : "..Count)
        for m = 0, Count-1 do
            local _ListTypeBtn = _gt.GetUI(tostring(QuestDlgUI.SelectQuestI*100+m))
            if _ListTypeBtn ~= nil then
                if m==QuestDlgUI.SelectQuestJ then
                    GUI.ButtonSetImageID(_ListTypeBtn, "1800602041")
                else
                    GUI.ButtonSetImageID(_ListTypeBtn, "1800602040")
                end
            end
        end

		--取消其他页签下选中的
		QuestDlgUI.UnSelectOthers(QuestDlgUI.SelectQuestI+1)
        QuestDlgUI.ShowQuestDetail()
    else
        test("QuestDlgUI.AllQuests is nil !!")
    end
end

local AwardItemNum = 0
function QuestDlgUI.ShowQuestDetail()
	local _DetailScroll = _gt.GetUI("DetailScrollLst")
	local _DetailScroll2 = _gt.GetUI("DetailScroll")
	local _GoToBtn = _gt.GetUI("GoToBtn")
	local TotalPosY = 430
	if QuestDlgUI.AllQuests ~= nil and QuestDlgUI.SelectQuestI>=0 and QuestDlgUI.SelectQuestI < QuestDlgUI.AllQuests.Count then
		local QuestInfo = QuestDlgUI.AllQuests[QuestDlgUI.SelectQuestI][QuestDlgUI.SelectQuestJ]
		if QuestInfo ~= nil then
			local QuestShowInfo = LD.GetQuestShowInfo(QuestInfo.quest_type, QuestInfo.quest_id)

			local _Title = _gt.GetUI("Title")
			if _Title == nil then
				_Title = GUI.CreateStatic( _DetailScroll,"Title", "【任务目标】", 378, 20, 150, 30)
                _gt.BindName(_Title,"Title")
    			UILayout.SetSameAnchorAndPivot(_Title, UILayout.TopLeft)
				GUI.StaticSetFontSize(_Title, 24)
				GUI.SetColor(_Title, UIDefine.Brown4Color)

				local _TitleValue  = GUI.RichEditCreate(_DetailScroll, "TitleValue","哒哒",388,53,654,60)
                _gt.BindName(_TitleValue,"TitleValue")
    			UILayout.SetSameAnchorAndPivot(_TitleValue, UILayout.TopLeft)
				GUI.StaticSetFontSize(_TitleValue, 22)
				GUI.SetColor(_TitleValue, UIDefine.Brown4Color)
				GUI.StaticSetAlignment(_TitleValue,TextAnchor.UpperLeft)
				GUI.RichEditSetLinkColor(_TitleValue, UIDefine.Green5Color)
				GUI.RegisterUIEvent(_TitleValue, UCE.PointerClick , "QuestDlgUI", "OnClickQuestContent")

				local _Content = GUI.CreateStatic( _DetailScroll,"Content", "【任务描述】", 378, 124, 150, 30)
                _gt.BindName(_Content,"Content")
    			UILayout.SetSameAnchorAndPivot(_Content, UILayout.TopLeft)
				GUI.StaticSetFontSize(_Content, 24)
				GUI.SetColor(_Content, UIDefine.Brown4Color)

				local _ContentValue  = GUI.RichEditCreate(_DetailScroll, "ContentValue","哒",388,157,654,60)
                _gt.BindName(_ContentValue,"ContentValue")
    			UILayout.SetSameAnchorAndPivot(_ContentValue, UILayout.TopLeft)
				GUI.StaticSetFontSize(_ContentValue, 22)
				GUI.SetColor(_ContentValue, UIDefine.Brown4Color)
				GUI.RichEditSetLinkColor(_ContentValue, UIDefine.Green5Color)
				GUI.StaticSetAlignment(_ContentValue,TextAnchor.UpperLeft)

				local _Award = GUI.CreateStatic( _DetailScroll,"Award", "【任务奖励】", 378, 222, 300, 30)
                _gt.BindName(_Award,"Award")
    			UILayout.SetSameAnchorAndPivot(_Award, UILayout.TopLeft)
				GUI.StaticSetFontSize(_Award, 24)
				GUI.SetColor(_Award, UIDefine.Brown4Color)

				--人物经验,宠物经验,金币,银币，元宝，绑定元宝
				local IconPic = { "1800408330", "1800408320", UIDefine.AttrIcon[RoleAttr.RoleAttrGold], UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold], UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], UIDefine.AttrIcon[RoleAttr.RoleAttrBindIngot]}
				for i=0,5 do
					local PosX = 388
					local PosY = 260
					if i%2==1 then PosX = 718 end
					if i/2>=1 then PosY = 310 end
					local _Back = GUI.ImageCreate( _DetailScroll,"Back"..i, "1800900040", PosX, PosY, false, 308, 34)
                    _gt.BindName(_Back,"Back"..i)
    				UILayout.SetSameAnchorAndPivot(_Back, UILayout.TopLeft)

					local _Icon = GUI.ImageCreate( _Back,"Icon"..i, IconPic[i+1], 3, -2, false, 34, 34)
                    _gt.BindName(_Icon,"Icon"..i)
    				UILayout.SetSameAnchorAndPivot(_Icon, UILayout.TopLeft)

					local _Value = GUI.CreateStatic( _Back,"Value"..i, "009", 13, 0, 260, 30)
                    _gt.BindName(_Value,"Value"..i)
    				UILayout.SetSameAnchorAndPivot(_Value, UILayout.Center)
					GUI.StaticSetFontSize(_Value, 22)
					GUI.SetColor(_Value, UIDefine.WhiteColor)
				end

				--图标动态显示
			end

			if QuestShowInfo ~= nil then
				local OffSetPosY = 0
				local TitleValueHeight = 0
				--目标
				local _TitleValue = _gt.GetUI("TitleValue")
				if  _TitleValue ~= nil then
					GUI.StaticSetText(_TitleValue, QuestShowInfo.TargetInfo)
					TitleValueHeight = GUI.RichEditGetPreferredHeight(_TitleValue)
					if TitleValueHeight>0 then OffSetPosY = TitleValueHeight - 26 end
				end

				--描述标题
				local _ContentTitle = _gt.GetUI("Content")
				if _ContentTitle ~= nil then
					GUI.SetPositionY(_ContentTitle, 124+OffSetPosY)
				end

				--描述
				local ContentValueHeight = 0
				local _ContentValue = _gt.GetUI("ContentValue")
				if  _ContentValue ~= nil then
					GUI.SetPositionY(_ContentValue, 157+OffSetPosY)
					GUI.StaticSetText(_ContentValue, QuestShowInfo.Desc)
					ContentValueHeight = GUI.RichEditGetPreferredHeight(_ContentValue)
					GUI.SetHeight(_ContentValue, ContentValueHeight)
					if ContentValueHeight>0 then OffSetPosY = OffSetPosY + ContentValueHeight - 26 end
				end

				--奖励标题
				local _AwardTitle = _gt.GetUI("Award")
				if _AwardTitle ~= nil then
					GUI.SetPositionY(_AwardTitle, 222+OffSetPosY)
				end

				local ValidUnItemIndex = 0
				local AwardNum = {QuestShowInfo.Exp, QuestShowInfo.PetExp, QuestShowInfo.Gold, QuestShowInfo.BindGold, QuestShowInfo.Ingold, QuestShowInfo.BindIngold}
				for i=0,5 do
					local _AwardValue = _gt.GetUI("Value"..i)
					local _AwardNode = _gt.GetUI("Back"..i)
					if  _AwardValue ~= nil and _AwardNode ~= nil then
						GUI.StaticSetText(_AwardValue, AwardNum[i+1])
						GUI.SetVisible(_AwardNode, AwardNum[i+1] > 0)
						if AwardNum[i+1] > 0 then
							local PosX = 388
							local PosY = 260
							if ValidUnItemIndex%2==1 then PosX = 718 end
							PosY = PosY + math.floor(ValidUnItemIndex/2) * 50
							GUI.SetPositionX(_AwardNode, PosX)
							GUI.SetPositionY(_AwardNode, PosY+OffSetPosY)
							ValidUnItemIndex = ValidUnItemIndex + 1
						end
					end
				end

				local PER_LINE_COUNT = 7
				local Count = QuestShowInfo.ItemID.Count
				if AwardItemNum < Count then
					AwardItemNum = Count
				end
				local StartPosY = 82 + math.floor((ValidUnItemIndex+1)/2) * 50
				for i=1, AwardItemNum do
					local IsShow = (i<=Count)
					local _Item = _gt.GetUI("Item"..i)
					local PosX = (i-1)%PER_LINE_COUNT*86 +385
					local PosY = StartPosY + (i-1 - (i-1)%PER_LINE_COUNT)/PER_LINE_COUNT*86 + OffSetPosY + 174
					local ItemConfig = nil
                    if IsShow then
                        ItemConfig = DB.GetOnceItemByKey1(QuestShowInfo.ItemID[i-1])
					end
					if _Item == nil then
						if IsShow then
							--图标
							_Item = GUI.ItemCtrlCreate( _DetailScroll,"Item"..i, "1800600050", PosX, PosY, 76, 76, false)
							_gt.BindName(_Item,"Item"..i)
							GUI.SetData(_Item, "id", tostring(QuestShowInfo.ItemID[i-1]))
							UILayout.SetSameAnchorAndPivot(_Item, UILayout.TopLeft)
							if ItemConfig ~=nil and ItemConfig.Icon ~= 0 then
								GUI.ItemCtrlSetElementValue(_Item,eItemIconElement.Icon, tostring(ItemConfig.Icon))
							end
							GUI.RegisterUIEvent(_Item , UCE.PointerClick , "QuestDlgUI", "OnClickRewardItem")
						end
					else
						GUI.SetVisible(_Item, IsShow)
						if IsShow then
							GUI.SetData(_Item, "id", tostring(QuestShowInfo.ItemID[i-1]))
							GUI.SetPositionX(_Item, PosX)
							GUI.SetPositionY(_Item, PosY)
							if ItemConfig ~=nil and ItemConfig.Icon ~= 0 then
								GUI.ItemCtrlSetElementValue(_Item,eItemIconElement.Icon, tostring(ItemConfig.Icon))
							end
						end
					end

                    if IsShow then
						GUI.ItemCtrlSetElementValue(_Item,eItemIconElement.Border, UIDefine.ItemIconBg[ItemConfig.Grade])
                    end
				end
				local AwardCountInParse = AwardItemNum
				if AwardCountInParse > 0 then
					AwardCountInParse = AwardCountInParse - 1
				end
				TotalPosY = TotalPosY + (AwardCountInParse - AwardCountInParse%PER_LINE_COUNT)/PER_LINE_COUNT*86 + OffSetPosY + (ValidUnItemIndex>=5 and 50 or 0)

				local _AwardTitle = _gt.GetUI("Award")
				if _AwardTitle ~= nil then
					GUI.SetVisible(_AwardTitle, ValidUnItemIndex>0 or Count>0)
				end
			else
				test("任务数据异常，QuestInfo.quest_type："..QuestInfo.quest_type..",QuestInfo.quest_id:"..QuestInfo.quest_id)
			end
		end
		local _ReceivedPage = _gt.GetUI("ReceivedPage")
		local IsReceivedPage = GUI.CheckBoxGetCheck(_ReceivedPage)
		if IsReceivedPage then
			GUI.ButtonSetText(_GoToBtn,"前往完成")
		else
			GUI.ButtonSetText(_GoToBtn,"前往领取")
		end
		GUI.SetVisible(_GoToBtn, true)
		GUI.SetVisible(_DetailScroll2, true)
		GUI.ScrollRectSetChildSize(_DetailScroll2, Vector2.New(705, TotalPosY))
	else
		GUI.SetVisible(_GoToBtn, false)
		GUI.SetVisible(_DetailScroll2, false)
	end
end

function QuestDlgUI.OnClickRewardItem(guid)
	local Item = GUI.GetByGuid(guid)
	local id = tonumber(GUI.GetData(Item, "id"))
	local DetailBack = _gt.GetUI("DetailBack")
	if DetailBack~= nil then
		test("显示点击的道具Tip")
		Tips.CreateByItemId(id, DetailBack, "tips", -370, 128, 0)
	end
end

function QuestDlgUI.OnClickQuestContent()
	local _Content = _gt.GetUI("TitleValue")
	if _Content ~= nil then
		local ClickInfo = GUI.RichEditGetSelectClickString(_Content)
		LD.OnParsePathFinding(ClickInfo)
	end
end

function QuestDlgUI.OnClickCloseBtn()
	print("关闭任务界面")
	local _Wnd = GUI.GetWnd("QuestDlgUI")
    if _Wnd ~= nil then
        --GUI.SetVisible(_Wnd, false)
		GUI.DestroyWnd("QuestDlgUI")
    end
end

function QuestDlgUI.OnReceivedPage()
	QuestDlgUI.OnSwitchPage(true)

	--默认展开所有项
	QuestDlgUI.OnShowAllTypeList()
end

function QuestDlgUI.OnNoReceivedPage()
	local lst = LD.GetAllQuest(false)
	if lst.Count > 0 then
		QuestDlgUI.OnSwitchPage(false)
		--默认展开所有项
		QuestDlgUI.OnShowAllTypeList()
	else
		CL.SendNotify(NOTIFY.ShowBBMsg, "没有未接的任务")
		QuestDlgUI.OnSwitchCheckPage(true)
	end
end

function QuestDlgUI.OnSwitchPage(IsReceivePage)
	QuestDlgUI.IsFirstShow = 0
	QuestDlgUI.OnSwitchCheckPage(IsReceivePage)
	QuestDlgUI.ShowMissionTypeLst()
end

function QuestDlgUI.OnSwitchCheckPage(IsReceivePage)
	QuestDlgUI.SelectQuestI = 0
	QuestDlgUI.SelectQuestJ = 0
	local _ReceivedPage = _gt.GetUI("ReceivedPage")
	GUI.CheckBoxSetCheck(_ReceivedPage, IsReceivePage)
	local _NoReceivedPage = _gt.GetUI("NoReceivedPage")
	GUI.CheckBoxSetCheck(_NoReceivedPage, IsReceivePage==false)
	local _GiveUpBtn = _gt.GetUI("GiveUpBtn")
	GUI.SetVisible(_GiveUpBtn, IsReceivePage)
	local _ReceivedPageTxt = _gt.GetUI("ReceivedPageTxt")
	if IsReceivePage then
		GUI.SetColor(_ReceivedPageTxt, UIDefine.Brown5Color)
	else
		GUI.SetColor(_ReceivedPageTxt, UIDefine.Brown7Color)
	end
	local _NoReceivedPageTxt = _gt.GetUI("NoReceivedPageTxt")
	if IsReceivePage==false then
		GUI.SetColor(_NoReceivedPageTxt, UIDefine.Brown5Color)
	else
		GUI.SetColor(_NoReceivedPageTxt, UIDefine.Brown7Color)
	end
end
