local BountyQuestUI = {}
_G.BountyQuestUI = BountyQuestUI

local _gt = UILayout.NewGUIDUtilTable();

local headLevelBgSprites = 
{
	[1] = "1801408180",
	[2] = "1801408190",
	[3] = "1801408200",
	[4] = "1801408210",
	[5] = "1801408220"
}

local headBgSprites = 
{
	[1] = "1801401140",
	[2] = "1801401150",
	[3] = "1801401160",
	[4] = "1801401170",
	[5] = "1801401180"
}

local QUEST_DONE = 2               --已完成
local QUEST_RECEIVED = 1            --已接受未完成
local QUEST_NOT_RECEIVED = 0        --未接受
local QUEST_GIVE_UP = -1             --已放弃


function BountyQuestUI.Main(parameter)
	_gt = UILayout.NewGUIDUtilTable();
	local wnd = GUI.WndCreateWnd("BountyQuestUI", "BountyQuestUI", 0, 0)
	local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "", "BountyQuestUI", "OnExit");
	_gt.BindName(panelBg, "panelBg")
	local BountyQuestUI_titleText = GUI.CreateStatic(panelBg, "BountyQuestUI_titleText", "歪比巴布", 0, -311, 250, 40, "system", false, false)
    UILayout.SetAnchorAndPivot(BountyQuestUI_titleText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(BountyQuestUI_titleText, UIDefine.FontSizeXXL)
    GUI.StaticSetAlignment(BountyQuestUI_titleText, TextAnchor.MiddleCenter)
    GUI.SetColor(BountyQuestUI_titleText, UIDefine.BrownColor)
	_gt.BindName(BountyQuestUI_titleText, "BountyQuestUI_titleText")

	local leftPanel = GUI.ImageCreate(panelBg, "leftPanel", "1800400200", -195, -30, false, 650, 450)
	UILayout.SetSameAnchorAndPivot(leftPanel, UILayout.Center);
	local questScroll = GUI.LoopScrollRectCreate(leftPanel, "questScroll", 0, 0, 635, 420,
		"BountyQuestUI", "CreateQuestItem", "BountyQuestUI", "RefreshQuestScroll", 0, false,
		Vector2.New(610, 78), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(questScroll, UILayout.Center);
	GUI.ScrollRectSetChildSpacing(questScroll, Vector2.New(1, 8));
	_gt.BindName(questScroll, "questScroll")

	local rightPanel = GUI.ImageCreate(panelBg, "rightPanel", "1800400200", 330, -30, false, 380, 450)
	UILayout.SetSameAnchorAndPivot(rightPanel, UILayout.Center);
	_gt.BindName(rightPanel,"rightPanel")

	local titleBg = GUI.ImageCreate(rightPanel, "titleBg", "1800001030", 0, 15, false, 240, 39);
	UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top);
	local questTitle = GUI.CreateStatic(titleBg, "questTitle", "任务标题", 0, 1, 200, 30);
	GUI.SetColor(questTitle, UIDefine.WhiteColor);
	GUI.StaticSetFontSize(questTitle, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(questTitle, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(questTitle, UILayout.Center);
	_gt.BindName(questTitle,"questTitle");
	
	local split1 = GUI.ImageCreate(rightPanel, "split1", "1801401070", 0, 65, false, 315, 4);
	UILayout.SetSameAnchorAndPivot(split1, UILayout.Top);
	
	local text1 = GUI.CreateStatic(rightPanel, "text1", "任务奖励", -120, 75, 150, 30);
	GUI.SetColor(text1, UIDefine.BrownColor);
	GUI.StaticSetFontSize(text1, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(text1, UILayout.Top);

	for i = 1, 4 do
		local rewardItem=ItemIcon.Create(rightPanel,"rewardItem"..i,-125+(i-1)*85,110)
		UILayout.SetSameAnchorAndPivot(rewardItem, UILayout.Top);
		_gt.BindName(rewardItem, "rewardItem"..i)
		GUI.RegisterUIEvent(rewardItem, UCE.PointerClick, "BountyQuestUI", "OnRewardItemClick");
	end

	local split2 = GUI.ImageCreate(rightPanel, "split2", "1801401070", 0, 200, false, 315, 4);
	UILayout.SetSameAnchorAndPivot(split2, UILayout.Top);

	local text2 = GUI.CreateStatic(rightPanel, "text2", "任务描述", -120, 215, 150, 30);
	GUI.SetColor(text2, UIDefine.BrownColor);
	GUI.StaticSetFontSize(text2, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(text2, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(text2, UILayout.Top);

	local questDesc = GUI.CreateStatic(rightPanel, "questDesc", "任务描述", 0, 250, 300, 140);
	GUI.SetColor(questDesc, UIDefine.Yellow2Color);
	GUI.StaticSetFontSize(questDesc, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(questDesc, TextAnchor.UpperLeft);
	UILayout.SetSameAnchorAndPivot(questDesc, UILayout.Top);
	_gt.BindName(questDesc, "questDesc")

	local split3 = GUI.ImageCreate(rightPanel, "split3", "1801401070", 0, 400, false, 315, 4);
	UILayout.SetSameAnchorAndPivot(split3, UILayout.Top);

	local acceptNum= GUI.CreateStatic(rightPanel, "acceptNum", "今日已接次数", 0, 405, 240, 40,"system",true);
	GUI.SetColor(acceptNum, UIDefine.BrownColor);
	GUI.StaticSetFontSize(acceptNum, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(acceptNum, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(acceptNum, UILayout.Top);
	_gt.BindName(acceptNum,"acceptNum");

	local hintBtn = GUI.ButtonCreate(rightPanel, "hintBtn", "1800702030", 140, 405, Transition.ColorTint);
	UILayout.SetSameAnchorAndPivot(hintBtn, UILayout.Top);
	GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "BountyQuestUI", "OnHintBtnClick");



	local consumeItem=ItemIcon.Create(panelBg,"consumeItem",-458,250);
	UILayout.SetSameAnchorAndPivot(consumeItem, UILayout.Center);
	_gt.BindName(consumeItem,"consumeItem")
	GUI.RegisterUIEvent(consumeItem, UCE.PointerClick, "BountyQuestUI", "OnConsumeItemClick");

	local refreshBtn = GUI.ButtonCreate(panelBg, "refreshBtn", "1800402080", 200, -42, Transition.ColorTint, "刷新", 160, 47, false);
	GUI.SetIsOutLine(refreshBtn, true);
	GUI.ButtonSetTextFontSize(refreshBtn, UIDefine.FontSizeXL);
	GUI.ButtonSetTextColor(refreshBtn, UIDefine.WhiteColor);
	GUI.SetOutLine_Color(refreshBtn, UIDefine.OutLine_BrownColor);
	GUI.SetOutLine_Distance(refreshBtn, UIDefine.OutLineDistance);
	GUI.RegisterUIEvent(refreshBtn, UCE.PointerClick, "BountyQuestUI", "OnRefreshBtnClick");
	UILayout.SetSameAnchorAndPivot(refreshBtn, UILayout.BottomLeft);

	local refreshHintBtn = GUI.ButtonCreate(panelBg, "refreshHintBtn", "1800702030", 370, -42, Transition.ColorTint);
	UILayout.SetSameAnchorAndPivot(refreshHintBtn, UILayout.BottomLeft);
	GUI.RegisterUIEvent(refreshHintBtn, UCE.PointerClick, "BountyQuestUI", "OnRefreshBtnHintBtnClick");
	
	
	local doubleTimeImg = GUI.ImageCreate(panelBg, "doubleTimeImg", "1801604140", -275, -95);
	UILayout.SetSameAnchorAndPivot(doubleTimeImg, UILayout.BottomRight);
	
	local doubleTimeText= GUI.CreateStatic(doubleTimeImg, "doubleTimeText", "00:00-00:00", -155, -1, 200, 35);
	GUI.SetColor(doubleTimeText, UIDefine.RedColor);
	GUI.StaticSetFontSize(doubleTimeText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(doubleTimeText, TextAnchor.MiddleLeft);
	UILayout.SetSameAnchorAndPivot(doubleTimeText, UILayout.Left);
	_gt.BindName(doubleTimeText,"doubleTimeText");
	
	local acceptBtn = GUI.ButtonCreate(panelBg, "acceptBtn", "1800402080", -90, -42, Transition.ColorTint, "领取", 160, 47, false);
	GUI.SetIsOutLine(acceptBtn, true);
	GUI.ButtonSetTextFontSize(acceptBtn, UIDefine.FontSizeXL);
	GUI.ButtonSetTextColor(acceptBtn, UIDefine.WhiteColor);
	GUI.SetOutLine_Color(acceptBtn, UIDefine.OutLine_BrownColor);
	GUI.SetOutLine_Distance(acceptBtn, UIDefine.OutLineDistance);
	GUI.RegisterUIEvent(acceptBtn, UCE.PointerClick, "BountyQuestUI", "OnAcceptBtnClick");
	UILayout.SetSameAnchorAndPivot(acceptBtn, UILayout.BottomRight);
	_gt.BindName(acceptBtn,"acceptBtn");
	
	BountyQuestUI.InitData();
	--CL.SendNotify(NOTIFY.SubmitForm, "FormShangJinBang", "Main")

end

function BountyQuestUI.OnRefreshBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm, "FormShangJinBang", "Refresh_Quest")
end


function BountyQuestUI.OnAcceptBtnClick()
	local config = BountyQuestUI.config.QuestList[BountyQuestUI.index]
	if config then
		if config.State ==1 then
			test("Player_Failed_Quest:"..config.QuestId)
			CL.SendNotify(NOTIFY.SubmitForm, "FormShangJinBang", "Player_Failed_Quest",config.QuestId)
		else
			test("Player_Accept_Quest:"..config.QuestId)
			CL.SendNotify(NOTIFY.SubmitForm, "FormShangJinBang", "Player_Accept_Quest",config.QuestId)
		end
	end

end

function BountyQuestUI.InitData()
	BountyQuestUI.index=1;
	BountyQuestUI.config=nil
end

function BountyQuestUI.OnConsumeItemClick()
	local panelBg = _gt.GetUI("panelBg");
	local itemTips=Tips.CreateByItemId(BountyQuestUI.config.Refresh.RefreshItem,panelBg,"itemTips",-310,-130)
	UILayout.SetSameAnchorAndPivot(itemTips, UILayout.Bottom);
end

function BountyQuestUI.OnRewardItemClick(guid)

	local rewardItem = GUI.GetByGuid(guid);
	local itemId = tonumber(GUI.GetData(rewardItem,"ItemId"))
	test(itemId)
	
	local rightPanel = _gt.GetUI("rightPanel");
	local itemTips=Tips.CreateByItemId(itemId,rightPanel,"itemTips",-360,0)
	UILayout.SetSameAnchorAndPivot(itemTips, UILayout.Right);
end

function BountyQuestUI.GetConfig(table)

	if CL.GetMode() == 1 then
		local inspect = require("inspect")
		test(inspect(table))
	end

	BountyQuestUI.config=table;
	local inspect = require("inspect")
	--CDebug.LogError(inspect(BountyQuestUI.config))
	BountyQuestUI.Refresh();
end

function BountyQuestUI.OnExit()
	local wnd = GUI.GetWnd("BountyQuestUI")
    if wnd ~= nil then
        GUI.CloseWnd("BountyQuestUI")
		CL.UnRegisterMessage(GM.RefreshBag, "BountyQuestUI", "Refresh");
    end
end

function BountyQuestUI.OnShow(parameter)
	local wnd = GUI.GetWnd("BountyQuestUI");
	if wnd == nil then
		test("OnShow 赏金榜生成错误")
		return;
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormShangJinBang", "Main")
	GUI.SetVisible(wnd, true);
	
	CL.RegisterMessage(GM.RefreshBag, "BountyQuestUI", "Refresh");
	--BountyQuestUI.Refresh();
end

function BountyQuestUI.Refresh()
	if not BountyQuestUI.config then
		test("没有BountyQuestUI.config")
		return
	end
	
	local config = BountyQuestUI.config.QuestList[BountyQuestUI.index]
	if config then
		local questTitle = _gt.GetUI("questTitle");
		GUI.StaticSetText(questTitle,config.QuestName)

		for i = 1, 4 do
			local itemId = config.ShowReward[2 * i - 1]
			local itemCount = config.ShowReward[2 * i]
			local rewardItem=_gt.GetUI("rewardItem"..i)
			if itemId then
				GUI.SetVisible(rewardItem,true);
				ItemIcon.BindItemId(rewardItem,itemId)
				GUI.ItemCtrlSetElementValue(rewardItem, eItemIconElement.RightBottomNum, itemCount)
				GUI.SetData(rewardItem,"ItemId",itemId)
			else
				GUI.SetVisible(rewardItem,false);
			end
		end

		local questDesc = _gt.GetUI("questDesc")
		GUI.StaticSetText(questDesc,config.QuestDescribe)

		local acceptBtn= _gt.GetUI("acceptBtn")
		local isFinish = config.State == QUEST_DONE;
		if isFinish then
			GUI.SetVisible(acceptBtn,false);
		end

		local isReceived = config.State == QUEST_RECEIVED
		if isReceived then
			GUI.SetVisible(acceptBtn,true);
			GUI.ButtonSetText(acceptBtn,"放弃")
		end

		local isGiveUp = config.State ==QUEST_GIVE_UP
		if isGiveUp then
			GUI.SetVisible(acceptBtn,false);
		end

		local isNotReceived = config.State == QUEST_NOT_RECEIVED
		if isNotReceived then
			GUI.SetVisible(acceptBtn,true);
			GUI.ButtonSetText(acceptBtn,"领取")
		end
	end
	
	local BountyQuestUI_titleText = _gt.GetUI("BountyQuestUI_titleText")
	local title_str = BountyQuestUI.config.Name
	if title_str == nil then
		title_str = "赏金榜"
	end
	GUI.StaticSetText(BountyQuestUI_titleText, title_str)

	local consumeItem =_gt.GetUI("consumeItem")
	ItemIcon.BindItemIdWithNum(consumeItem, BountyQuestUI.config.Refresh.RefreshItem, BountyQuestUI.config.Refresh.Num )
	
	
	local acceptNum = _gt.GetUI("acceptNum");
	local str ="今日已接次数 " .. "<color=#08af00>( ".. BountyQuestUI.config.DayCount .."/".. BountyQuestUI.config.DayCountMax.." )</color>"
	GUI.StaticSetText(acceptNum,str);
	
	local doubleTimeText = _gt.GetUI("doubleTimeText")
	GUI.StaticSetText(doubleTimeText,BountyQuestUI.config.DoubleTimeStart..":00-"..BountyQuestUI.config.DoubleTimeEnd..":00");
	
	
	local questScroll = _gt.GetUI("questScroll")
	GUI.LoopScrollRectSetTotalCount(questScroll, #BountyQuestUI.config.QuestList);
	GUI.LoopScrollRectRefreshCells(questScroll);
	
end


function BountyQuestUI.OnHintBtnClick()
	local rightPanel = _gt.GetUI("rightPanel");
	Tips.CreateHint("放弃任务不会归还接取次数",rightPanel,0,345,UILayout.Top,330)
end

function BountyQuestUI.OnRefreshBtnHintBtnClick()
	local panelBg = _gt.GetUI("panelBg");
	local str="1 消耗赏金令可以刷新赏金榜\n";
	
	local config= BountyQuestUI.config.Refresh.Config
	for i = 1, #config do
		if config[i].min==config[i].max  then
			if config[i].num==0 then
				str=str..""..(i+1).." 剩余"..config[i].min.."个未接任务时，可免费刷新赏金榜"
			else
				str=str..""..(i+1).." 剩余"..config[i].min.."个未接任务时，可消耗"..config[i].num .."个赏金令刷新赏金榜\n"
			end
		else
			str=str..""..(i+1).." 剩余"..config[i].min.."-"..config[i].max.."个未接任务时，可消耗"..config[i].num .."个赏金令刷新赏金榜\n"
		end
	end
  
	Tips.CreateHint(str,panelBg,0,-95,UILayout.Bottom,540)
end

function BountyQuestUI.CreateQuestItem()
	local questScroll =_gt.GetUI("questScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(questScroll);
	local questItem = GUI.CheckBoxExCreate(questScroll, "questItem"..curCount, "1800400360", "1800400361", 0, 0, false)
	GUI.RegisterUIEvent(questItem, UCE.PointerClick, "BountyQuestUI", "OnQuestItemClick");
	
	local middleBg = GUI.ImageCreate(questItem, "middleBg", "1801401190", 100, 0);
	UILayout.SetSameAnchorAndPivot(middleBg, UILayout.Left);
	
	local headBg = GUI.ImageCreate(questItem, "headBg", "1801401160", 0, 0);
	UILayout.SetSameAnchorAndPivot(headBg, UILayout.Left);
	
	local headLevelBg = GUI.ImageCreate(questItem, "headLevelBg", "1801408200", 5, 0);
	UILayout.SetSameAnchorAndPivot(headLevelBg, UILayout.Left);
	
	local questName= GUI.CreateStatic(questItem, "questName", "任务名称", 70, 0, 110, 35);
	GUI.SetColor(questName, UIDefine.BrownColor);
	GUI.StaticSetFontSize(questName, UIDefine.FontSizeS)
	GUI.StaticSetAlignment(questName, TextAnchor.MiddleLeft);
	UILayout.SetSameAnchorAndPivot(questName, UILayout.Left);

	for i = 1, 5 do
		local star=GUI.ImageCreate(questItem, "star"..i, "1801407100", 220+(i-1)*50, 0);
		UILayout.SetSameAnchorAndPivot(star, UILayout.Left);
	end

	local stateImg = GUI.ImageCreate(questItem, "stateImg", "1801308070", -15, 0);
	UILayout.SetSameAnchorAndPivot(stateImg, UILayout.Right);
	
	return questItem;
end

function BountyQuestUI.RefreshQuestScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2])+1;
	local questItem = GUI.GetByGuid(guid);
	
	local config = BountyQuestUI.config.QuestList[index]
	if config == nil then
		return;
	end

	GUI.CheckBoxExSetCheck(questItem,index == BountyQuestUI.index)
	
	local headBg = GUI.GetChild(questItem,"headBg")
	local headLevelBg = GUI.GetChild(questItem,"headLevelBg")
	local questName = GUI.GetChild(questItem,"questName")
	GUI.ImageSetImageID(headBg,headBgSprites[config.Star])
	GUI.ImageSetImageID(headLevelBg,headLevelBgSprites[config.Star])
	GUI.StaticSetText(questName,config.QuestName)
	
	for i = 1, 5 do
		local star = GUI.GetChild(questItem,"star"..i);
		if i<=config.Star then
		GUI.ImageSetImageID(star,"1801407100")
		else
		GUI.ImageSetImageID(star,"1801407110")
		end
	end
	
	local stateImg =GUI.GetChild(questItem,"stateImg")
	
	if config.State == QUEST_DONE then
		GUI.ImageSetImageID(stateImg,"1801208670")
		GUI.SetVisible(stateImg,true);
	elseif config.State == QUEST_RECEIVED then
		GUI.ImageSetImageID(stateImg,"1801208710")
		GUI.SetVisible(stateImg,true);
	elseif config.State ==QUEST_GIVE_UP then
		GUI.ImageSetImageID(stateImg,"1801308070")
		GUI.SetVisible(stateImg,true);
	elseif config.State == QUEST_NOT_RECEIVED then
		GUI.SetVisible(stateImg,false);
	end
	
end

function BountyQuestUI.OnQuestItemClick(guid)
	local questItem=GUI.GetByGuid(guid);
	local index = GUI.CheckBoxExGetIndex(questItem)+1;
	BountyQuestUI.index=index;
	BountyQuestUI.Refresh();
end