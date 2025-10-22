DiscipleVoteUI = {}
DiscipleVoteUI.PlayerList = nil
DiscipleVoteUI.CurrentIndex = 0
DiscipleVoteUI.CurrentGuid = -1
local _gt = UILayout.NewGUIDUtilTable()

-- 大弟子投票界面
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)


function DiscipleVoteUI.Main(parameter)
    local panel = GUI.WndCreateWnd("DiscipleVoteUI", "DiscipleVoteUI", 0, 0)
    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)
	--_gt.BindName(panel, "panel")

    -- 底图
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "门派大弟子", "DiscipleVoteUI", "OnCloseBtnClick")

    -- 底板
    local playersBg = GUI.ImageCreate( panelBg,"PlayersBg", "1800400200", 0, -12, false, 1030, 431)
    UILayout.SetSameAnchorAndPivot(playersBg, UILayout.Center)

    DiscipleVoteUI.CreateScrollView(playersBg)

    local SubTitleBg = GUI.ImageCreate( panelBg,"subTitleBg", "1800700070", 0, -240, false, 1026, 40)
    UILayout.SetSameAnchorAndPivot(SubTitleBg, UILayout.Center)

    local txt = GUI.CreateStatic(SubTitleBg, "subTitleText1", "竞选人", -415, 0, 180, 35, "system", false)
    DiscipleVoteUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 26)
    local txt = GUI.CreateStatic(SubTitleBg, "subTitleText2", "当前选票", -245, 0, 180, 35, "system", false)
    DiscipleVoteUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 26)
    local txt = GUI.CreateStatic(SubTitleBg, "subTitleText3", "竞选宣言", 166, 0, 180, 35, "system", false)
    DiscipleVoteUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 26)

    local cutLine = GUI.ImageCreate(SubTitleBg,"cutLine1", "1800600220", -318, 0)
    UILayout.SetSameAnchorAndPivot(cutLine, UILayout.Center)
    cutLine = GUI.ImageCreate(SubTitleBg,"cutLine2", "1800600220", -175, 0)
    UILayout.SetSameAnchorAndPivot(cutLine, UILayout.Center)

    local costTxt = GUI.CreateStatic(panelBg, "CostText", "投票需消耗  20活力", -401, 226, 235, 35)
    UILayout.SetSameAnchorAndPivot(costTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(costTxt, 22, colorDark, nil)
	_gt.BindName(costTxt, "costTxt")

    local gainTxt = GUI.CreateStatic(panelBg, "GainText", "投票可获得  20000银币", -401, 259, 235, 35)
    UILayout.SetSameAnchorAndPivot(gainTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(gainTxt, 22, colorDark, nil)
	_gt.BindName(gainTxt, "gainTxt")

    -- 编辑宣言
    local editBtn = GUI.ButtonCreate(panelBg,"EditBtn", "1800402080", 258, 249, Transition.ColorTint, "", 150, 47, false)
    _gt.BindName(editBtn, "editBtn")
	UILayout.SetSameAnchorAndPivot(editBtn, UILayout.Center)
    GUI.ButtonSetTextFontSize(editBtn, 24)
    GUI.ButtonSetTextColor(editBtn, colorWhite)
    GUI.RegisterUIEvent(editBtn, UCE.PointerClick, "DiscipleVoteUI", "OnClickEdit")
	GUI.ButtonSetShowDisable(editBtn, false)

    local editBtnText = GUI.CreateStatic( editBtn,"EditBtnText", "编辑宣言", 0, 0, 150, 47, "system")
    UILayout.SetSameAnchorAndPivot(editBtnText, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(editBtnText, 26, colorWhite, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(editBtnText, true)
    GUI.SetOutLine_Color(editBtnText, colorOutline)
    GUI.SetOutLine_Distance(editBtnText, 1)

    -- 投票
    local voteBtn = GUI.ButtonCreate( panelBg,"VoteBtn", "1800402080", 441, 249, Transition.ColorTint, "", 150, 47, false)
    _gt.BindName(voteBtn, "voteBtn")
	UILayout.SetSameAnchorAndPivot(voteBtn, UILayout.Center)
    GUI.RegisterUIEvent(voteBtn, UCE.PointerClick, "DiscipleVoteUI", "OnClickVote")

    local voteBtnText = GUI.CreateStatic( voteBtn,"VoteBtnText", "投票", 0, 0, 150, 47, "system")
    UILayout.SetSameAnchorAndPivot(voteBtnText, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(voteBtnText, 26, colorWhite, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(voteBtnText, true)
    GUI.SetOutLine_Color(voteBtnText, colorOutline)
    GUI.SetOutLine_Distance(voteBtnText, 1)

    --CL.RegisterMessage(GM.DiscipleVoteUpdate, "DiscipleVoteUI", "RefreshPlayersData")
    --DiscipleVoteUI.RefreshPlayersData()
end

function DiscipleVoteUI.SetTextBasicInfo(txt, color, Anchor, txtSize)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, txtSize, color, Anchor)
end

function DiscipleVoteUI.OnClickEdit()
	CL.SendNotify(NOTIFY.SubmitForm, "FormFirstDisciple", "Get_Declaration")
end

function DiscipleVoteUI.OnClickVote()
    if not DiscipleVoteUI.Data or #DiscipleVoteUI.Data.rank_list <= 0 or #DiscipleVoteUI.Data.rank_list < DiscipleVoteUI.CurrentIndex then
        CL.SendNotify(NOTIFY.ShowBBMsg, "当前没有候选人数据！")
		return
    end
    if DiscipleVoteUI.CurrentIndex == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选择一名玩家！")
        return
    end
    local guid = DiscipleVoteUI.Data.rank_list[DiscipleVoteUI.CurrentIndex][3]
	if guid then
		test("guid = "..guid)
		CL.SendNotify(NOTIFY.SubmitForm, "FormFirstDisciple", "Vote", guid)
	else
		return
	end
end

function DiscipleVoteUI.RefreshPlayersData()
	local inspect = require("inspect")
	--CDebug.LogError(inspect(DiscipleVoteUI.Data))
    local count = #DiscipleVoteUI.Data.rank_list
    
    local voteBtn = _gt.GetUI("voteBtn")
    if voteBtn then
        GUI.ButtonSetShowDisable(voteBtn, DiscipleVoteUI.Data.vate_state < 1)
    end
	local costTxt = _gt.GetUI("costTxt")
	local gainTxt = _gt.GetUI("gainTxt")
	if DiscipleVoteUI.Data and DiscipleVoteUI.Data.vote_energy then
		if tonumber(DiscipleVoteUI.Data.vote_energy) == 0 then
			GUI.SetVisible(costTxt, false)
		else
			GUI.SetVisible(costTxt, true)
			GUI.StaticSetText(costTxt, "投票需消耗  "..tostring(DiscipleVoteUI.Data.vote_energy).."活力")
		end
	end
	if DiscipleVoteUI.Data and DiscipleVoteUI.Data.vote_bind_gold then
		if tonumber(DiscipleVoteUI.Data.vote_bind_gold) ~= 0 then
			GUI.SetVisible(gainTxt, true)
			GUI.StaticSetText(gainTxt, "投票可获得  "..tostring(DiscipleVoteUI.Data.vote_bind_gold).."银币")
		else
			GUI.SetVisible(gainTxt, false)
		end
	end
    DiscipleVoteUI.RefreshPlayerList(count)
	DiscipleVoteUI.DataReset()
end

-- 创建循环滚动
function DiscipleVoteUI.CreateScrollView(playersBg)
    local loopScroll = GUI.LoopScrollRectCreate(playersBg, "LoopScroll", 0, 0, 1025, 415, "DiscipleVoteUI", "CreatePlayerItem", "DiscipleVoteUI", "RefreshLoopScroll", 0, false, Vector2.New(1025, 42), 1, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(loopScroll, "loopScroll")
	UILayout.SetSameAnchorAndPivot(loopScroll, UILayout.Center)
	--GUI.LoopScrollRectSetTotalCount(loopScroll, 10)
    GUI.ScrollRectSetChildSpacing(loopScroll, Vector2.New(0, 0))
    GUI.LoopScrollRectRefreshCells(loopScroll)
end

function DiscipleVoteUI.CreatePlayerItem()
    local loopScroll = _gt.GetUI("loopScroll")
    --if not loopScroll then
    --    return nil
    --end
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(loopScroll)
	local index = tostring(tonumber(curCount) + 1)
	
    local playerItem = GUI.ItemCtrlCreate(loopScroll, "PlayerItem"..index, "1800600240", 0, 0, 1025, 42, false)
    UILayout.SetSameAnchorAndPivot(playerItem, UILayout.Center)

    -- 名字
    local nameText = GUI.CreateStatic(playerItem,"NameText", "成员名六个字", 100, 0, 200, 35)
    UILayout.SetAnchorAndPivot(nameText, UIAnchor.Left, UIAroundPivot.Center)
    UILayout.StaticSetFontSizeColorAlignment(nameText, 24, colorDark, nil)
	GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter)

    -- 选票
    local voteNum = GUI.CreateStatic(playerItem,"VoteNum", "666", 270, 0, 200, 35)
    UILayout.SetAnchorAndPivot(voteNum, UIAnchor.Left, UIAroundPivot.Center)
    UILayout.StaticSetFontSizeColorAlignment(voteNum, 24, colorDark, nil)
	GUI.StaticSetAlignment(voteNum, TextAnchor.MiddleCenter)

    -- 宣言
    local declaration = GUI.CreateStatic(playerItem, "Declaration", "成员名六个字", 700, 0, 685, 35)
    UILayout.SetAnchorAndPivot(declaration, UIAnchor.Left, UIAroundPivot.Center)
    UILayout.StaticSetFontSizeColorAlignment(declaration, 24, colorDark, nil)

    GUI.RegisterUIEvent(playerItem, UCE.PointerClick, "DiscipleVoteUI", "OnClickPlayerItem")
    return playerItem
end

function DiscipleVoteUI.RefreshLoopScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
	local index = tonumber(parameter[2]) + 1
    local playerItem = GUI.GetByGuid(guid)
    if DiscipleVoteUI.CurrentIndex == index then
        GUI.ItemCtrlSetElementValue(playerItem, eItemIconElement.Border, "1800600250")
    elseif (index + 1) % 2 == 1 then
        GUI.ItemCtrlSetElementValue(playerItem, eItemIconElement.Border, "1800600240")
    else
        GUI.ItemCtrlSetElementValue(playerItem, eItemIconElement.Border, "1800600230")
    end

    local info = DiscipleVoteUI.Data.rank_list[index]
    local name = GUI.GetChild(playerItem, "NameText", false)
    if name then
		GUI.StaticSetText(name, info[4])
    end
    local voteNum = GUI.GetChild(playerItem, "VoteNum", false)
    if voteNum then
        GUI.StaticSetText(voteNum, tostring(info[2]))
    end
    local declaration = GUI.GetChild(playerItem, "Declaration", false)
    if declaration then
        local word = DiscipleVoteUI.Data.declaration_tb[''..info[3]]
		GUI.StaticSetText(declaration, word)
    end
	GUI.SetData(playerItem, "index", index)
end

function DiscipleVoteUI.OnClickPlayerItem(guid)
	local playerItem = GUI.GetByGuid(guid)
	
    DiscipleVoteUI.CurrentGuid = guid
    if playerItem then
        GUI.ItemCtrlSetElementValue(playerItem, eItemIconElement.Border, "1800600250")
    end
	local index = tonumber(GUI.GetData(playerItem, "index"))

	DiscipleVoteUI.CurrentIndex = index
	
	local count = #DiscipleVoteUI.Data.rank_list
    local editBtn = _gt.GetUI("editBtn") 
    if editBtn then
        local enable = false
        local name = CL.GetRoleName()
        if tostring(DiscipleVoteUI.Data.rank_list[index][4]) == tostring(name) then
            enable = true
        end
        GUI.ButtonSetShowDisable(editBtn, enable)
    end
    local voteBtn = _gt.GetUI("voteBtn")
    if voteBtn then
        GUI.ButtonSetShowDisable(voteBtn, DiscipleVoteUI.Data.vate_state < 1)
    end
	
	local loopScroll = _gt.GetUI("loopScroll")
	GUI.LoopScrollRectRefreshCells(loopScroll)
end

function DiscipleVoteUI.RefreshPlayerList(count)
    local loopScroll = _gt.GetUI("loopScroll")
    if loopScroll and count then
        GUI.LoopScrollRectSetTotalCount(loopScroll, count)
        GUI.LoopScrollRectRefreshCells(loopScroll)
        GUI.ScrollRectSetNormalizedPosition(loopScroll, Vector2.New(0, 0))
    end
end

function DiscipleVoteUI.OnCloseBtnClick(key)
    local wnd = GUI.GetWnd("DiscipleVoteUI")
    if wnd ~= nil then
        DiscipleVoteUI.DataReset()
		GUI.CloseWnd("DiscipleVoteUI")
    end
end

function DiscipleVoteUI.OnShow(parameter)
    test("DiscipleVoteUI.OnShow")
	local wnd = GUI.GetWnd("DiscipleVoteUI")
    if wnd then
        GUI.SetVisible(wnd, true)
    --else
	--	DiscipleVoteUI.Main(parameter)
	end
	
end

function DiscipleVoteUI.DataReset()
	DiscipleVoteUI.CurrentIndex = 0
	DiscipleVoteUI.CurrentGuid = -1
	local loopScroll = _gt.GetUI("loopScroll")
	GUI.LoopScrollRectRefreshCells(loopScroll)
end