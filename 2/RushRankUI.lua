local RushRankUI = {}

_G.RushRankUI = RushRankUI

local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorOutline = Color.New(162 / 255, 75 / 255, 21 / 255)
-- local QualityRes = UILayout.ItemIcon.QualityRes
local REWARD_COUNT = 5
--local TIP_TEXT = "活动规则：\n每15分钟刷新一次战力排行榜排名，奖励在冲榜活动结束时，通过邮件的形式发放。"
local CurSelectTab = 1
local TAB_SELECTED = "1800002031"
local TAB_NORMAL = "1800002030"
local TAB_DISABLED = "1800002033"

function RushRankUI.Main(paramter)
	--创建wnd
    local panel = GUI.WndCreateWnd("RushRankUI", "RushRankUI", 0, 0, eCanvasGroup.Normal)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)

    --模板创建页面
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "开服冲榜","RushRankUI", "OnCloseBtnClick", _gt)
    RushRankUI.CreatePanel(panelBg)

	--自动Onshow onclose
    -- CL.RegisterMessage(GM.ShowWnd, "RushRankUI", "OnShowWnd");
    -- CL.RegisterMessage(GM.CloseWnd, "RushRankUI", "OnCloseWnd")
end

function RushRankUI.OnShow(paramter)
    local wnd = GUI.GetWnd("RushRankUI")
    if not wnd then
        return
    end
	--判断当前当前是否开启
    if not GlobalProcessing or not GlobalProcessing.RushRankData or not next(GlobalProcessing.RushRankData) then
        GUI.SetVisible(wnd, false)
        CL.SendNotify(NOTIFY.ShowBBMsg, "当前没有开启的活动")
        return
    end
	
    GUI.SetVisible(wnd, true)
	
    -- CurSelectTab = -1
    RushRankUI.RequestRankList(1)


	--上方页签滚动回最开始	
	local TabScroll = _gt.GetUI("TabScroll")
	if TabScroll then
		GUI.ScrollRectSetNormalizedPosition(TabScroll,Vector2.New(0, 0))
	end
end

function RushRankUI.RequestRankList(tab)
	--判断是否活动开启
    if not GlobalProcessing or not GlobalProcessing.RushRankData then
        return
    end
	
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(GlobalProcessing.RushRankData.RankList))
	
    local data = GlobalProcessing.RushRankData.RankList[tab]
	
    if not data then
        return
    end
    local tick = tonumber(tostring(CL.GetServerTickCount()))
    if tick < data.Start_Time  then
        CL.SendNotify(NOTIFY.ShowBBMsg, data.Not_Open_TXT);
        return
    end
    if tick > data.Retain_Time then
        CL.SendNotify(NOTIFY.ShowBBMsg, "活动已结束！");
        return
    end
	
    -- if tab == CurSelectTab then
        -- return
    -- end
    CurSelectTab = tab
    local key = data.ActKeyName
    CL.SendNotify(NOTIFY.SubmitForm, "FormActRankList", "get_act_ranklist_info_by_key",key);
end

function RushRankUI.OnCloseBtnClick()
    GUI.CloseWnd("RushRankUI")
end

function RushRankUI.ServerRankData(data)
    RushRankUI.RankList = data
    RushRankUI.RefreshUI()
end

function RushRankUI.CreatePanel(panelBg)
    local group = GUI.GroupCreate( panelBg, "TabGroup", 0, 0, 0, 0);
    SetAnchorAndPivot(group, UIAnchor.Center, UIAroundPivot.Center)
	
	--上方页签滚动
	local TabScroll = GUI.LoopScrollRectCreate(group, "TabScroll", -10, -230, 1035, 80,
	"RushRankUI", "CreateTabItem", "RushRankUI", "RefreshTabItem", 0, true, Vector2.New(148, 63), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft);
	UILayout.SetSameAnchorAndPivot(TabScroll, UILayout.Center)
    GUI.SetInertia(TabScroll,false)
    TabScroll:RegisterEvent(UCE.PointerClick)
    TabScroll:RegisterEvent(UCE.EndDrag)
    GUI.RegisterUIEvent(TabScroll, UCE.EndDrag , "RushRankUI", "OnTabBtnDrag")
	_gt.BindName(TabScroll,"TabScroll")
	
    local rightTag = GUI.ImageCreate(group, "rightTag", "1801507230", 540, -220, false, 32, 32)
    _gt.BindName(rightTag, "rightTag")
    UILayout.SetSameAnchorAndPivot(rightTag, UILayout.TopLeft)
    GUI.SetEulerAngles(rightTag,Vector3.New(0, 0, -180))

    local rankBg = GUI.ImageCreate( panelBg, "rankBg", "1800300040", 68, 127, false, 380, 480)
    SetAnchorAndPivot(rankBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local bg = GUI.ImageCreate( rankBg, "bg", "1801704050", 0, 0, false, 380, 480)
    SetAnchorAndPivot(bg, UIAnchor.Center, UIAroundPivot.Center)

    local myRankBg = GUI.ImageCreate( rankBg, "myRankBg", "1800001240", 0, -203, false, 270, 40)
    SetAnchorAndPivot(myRankBg, UIAnchor.Center, UIAroundPivot.Center)

    local myRankTxt = GUI.CreateStatic( myRankBg, "myRankText", "我的排名:1", 0, 0, 182, 30, "system", false, false)
    SetAnchorAndPivot(myRankTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(myRankTxt, 20)
	GUI.StaticSetAlignment(myRankTxt, TextAnchor.MiddleCenter)
    GUI.SetColor(myRankTxt, colorWhite)

    local bg4 = GUI.ImageCreate( rankBg, "bg4", "1801704040", 0, 55, false, 360, 200)
    SetAnchorAndPivot(bg4, UIAnchor.Center, UIAroundPivot.Center)

    local num1 = GUI.CreateStatic( rankBg, "num1Name", "名字名字名字", 0, 49, 182, 35, "system", false, false)
    SetAnchorAndPivot(num1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(num1, 18)
    GUI.StaticSetAlignment(num1, TextAnchor.MiddleCenter)
    GUI.SetColor(num1, colorWhite)

    local num2 = GUI.CreateStatic( rankBg, "num2Name", "名字名字名字", -120, 66, 182, 35, "system", false, false)
    SetAnchorAndPivot(num2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(num2, 18)
    GUI.StaticSetAlignment(num2, TextAnchor.MiddleCenter)
    GUI.SetColor(num2, colorWhite)

    local num3 = GUI.CreateStatic( rankBg, "num3Name", "名字名字名字", 120, 66, 182, 35, "system", false, false)
    SetAnchorAndPivot(num3, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(num3, 18)
    GUI.StaticSetAlignment(num3, TextAnchor.MiddleCenter)
    GUI.SetColor(num3, colorWhite)

    --查看排行榜
    local rankBtn = GUI.ButtonCreate(rankBg, "rankBtn", "1800402080", 0, 203, Transition.ColorTint, "查看排行榜", 150, 55, false)
    SetAnchorAndPivot(rankBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.ButtonSetTextFontSize(rankBtn, 24)
    GUI.ButtonSetTextColor(rankBtn, colorWhite)
    GUI.SetIsOutLine(rankBtn, true)
    GUI.SetOutLine_Color(rankBtn, colorOutline)
    GUI.SetOutLine_Distance(rankBtn, 1)
    GUI.RegisterUIEvent(rankBtn, UCE.PointerClick, "RushRankUI", "OnClickRankBtn")

    --右侧面板
    local rightBg = GUI.ImageCreate( panelBg, "rightBg", "1800300040", 456, 132, false, 660, 360)
    SetAnchorAndPivot(rightBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --GUI.ScrollRectSetChildSpacing(loopScroll, Vector2.New(0, 0));
	local loopScroll = GUI.LoopScrollRectCreate(rightBg, "loopScroll", -5, 2, 650, 350,
    "RushRankUI", "CreateRankRewardItem", "RushRankUI", "RefreshRankRewardItem", 10, false,
	Vector2.New(650, 90), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(loopScroll, UILayout.TopRight);
	_gt.BindName(loopScroll, "loopScroll")

    local tipTxt = GUI.CreateStatic( panelBg, "tipText", "活动规则：\n每15分钟刷新一次战力排行榜排名，奖励在冲榜活动结束时，通过邮件的形式发放。\n剩余时间：0天23小时40分", 195, 228, 675, 100, "system", false, false)
    SetAnchorAndPivot(tipTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(tipTxt, 18)
    GUI.StaticSetAlignment(tipTxt, TextAnchor.UpperLeft)
    GUI.SetColor(tipTxt, colorDark)

    local lastTimeTxt = GUI.CreateStatic( panelBg, "lastTimeTxt", "剩余时间：0天23小时40分", 195, 260, 675, 50, "system", false, false)
    SetAnchorAndPivot(lastTimeTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(lastTimeTxt, 18)
    GUI.SetColor(lastTimeTxt, colorDark)
end

function RushRankUI.OnClickTabBtn(guid)
	local tab = tonumber(GUI.GetData(GUI.GetByGuid(guid), "name"))
    RushRankUI.RequestRankList(tab)
end

function RushRankUI.OnClickRankBtn(guid)
    local rankListData = RushRankUI.RankList
    if not rankListData then
        return
    end
    local rankType = rankListData.Rank_Type
	-- CDebug.LogError(rankType)
    if not rankType then
        return
    end
    local rt, subType = math.floor(rankType / 10), rankType % 10
    if rt <= 0 or subType <= 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "无法打开对应的排行榜");
        return
    end
	-- CDebug.LogError(rt)
	-- CDebug.LogError(subType)
    GUI.OpenWnd("RankUI", rt..","..subType)
end

function RushRankUI.CreateRankRewardItem()
    --local loopScroll = GUI.Get("RushRankUI/panelBg/rightBg/loopScroll")
	local loopScroll = _gt.GetUI("loopScroll")
    local itemList = GUI.ItemCtrlCreate(loopScroll, "itemList", "1801100010", 0, 0, 650, 90, false);
    SetAnchorAndPivot(itemList, UIAnchor.Center, UIAroundPivot.Center)
    local desTxt = GUI.CreateStatic( itemList, "desTxt", "综合战力排行", -218, -21, 182, 35, "system", false, false)
    SetAnchorAndPivot(desTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(desTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(desTxt, 20)
    GUI.SetColor(desTxt, colorDark)

    local rankValueBg = GUI.ImageCreate( itemList, "rankValueBg", "1801100190", -218, 15, false, 170, 40)
    SetAnchorAndPivot(rankValueBg, UIAnchor.Center, UIAroundPivot.Center)

    local rankValueTxt = GUI.CreateStatic( rankValueBg, "rankValueTxt", "第一名", 0, 0, 182, 35, "system", false, false)
    SetAnchorAndPivot(rankValueTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(rankValueTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(rankValueTxt, 20)
    GUI.SetColor(rankValueTxt, colorWhite)

    for j = 1, REWARD_COUNT do
        local RewardItem = GUI.ItemCtrlCreate(itemList, "GiftItemBg" .. j, "1800600050", 203 + (j - 1) * (82 + 3), 5, 82, 82, false)
        SetAnchorAndPivot(RewardItem, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
		GUI.RegisterUIEvent(RewardItem, UCE.PointerClick, "RushRankUI", "OnItemBgClick")
    end

    return itemList
end

function RushRankUI.RefreshRankRewardItem(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(RushRankUI.RankList))
    local index = tonumber(parameter[2]);
    local config = RushRankUI.RankList.Reward_List[index + 1]
    local itemList = GUI.GetByGuid(guid);
    local desTxt = GUI.GetChild(itemList, "desTxt")
    GUI.StaticSetText(desTxt, config.Inf)
    local rankValueTxt = GUI.GetChild(itemList, "rankValueTxt")
    if config.Lower == config.Up then
        GUI.StaticSetText(rankValueTxt, "第" .. config.Lower .. "名")
    else
        GUI.StaticSetText(rankValueTxt, "第" .. config.Up .."-" .. config.Lower .. "名")
    end
    local list = config.Item_list
    local rewardNum = #list / 3 --此处的数据为{ "战功牌", 12, 1, "阵法书残卷", 10, 0, "高级宝石福袋", 1, 0 }
    for i = 1, REWARD_COUNT do
        local RewardItem = GUI.GetChild(itemList, "GiftItemBg" .. i)
        local item = i <= rewardNum and DB.GetOnceItemByKey1(list[3 * i - 2]) or nil
        local item_num = list[3 * i - 1]
        if item then
            local grade = UIDefine.ItemIconBg[item.Grade]
            if grade ~= "" then
                GUI.ItemCtrlSetElementValue(RewardItem,eItemIconElement.Border,grade)
            else
                GUI.ItemCtrlSetElementValue(RewardItem,eItemIconElement.Border"1800400050")
                GUI.ItemCtrlSetElementValue(_RewardIcon,eItemIconElement.Icon,"")
            end
			-- CDebug.LogError(item.Icon)
            GUI.ItemCtrlSetElementValue(RewardItem,eItemIconElement.Icon,item.Icon)
            GUI.ItemCtrlSetElementValue(RewardItem,eItemIconElement.RightBottomNum,item_num)
            -- local img = GUI.ItemCtrlGetElementValue(_RewardIcon,eItemIconElement.Icon)
            GUI.ItemCtrlSetIconGray(img, false)
            GUI.SetVisible(img, true)
            -- GUI.SetItemIconBtnIconScale(_RewardIcon, 1)
			-- CDebug.LogError(item.Id)
            GUI.SetData(RewardItem, "itemID", item.Id)
            local _item_RightBottom = GUI.ItemCtrlGetElement(RewardItem,eItemIconElement.RightBottomNum)
            if _item_RightBottom then
                GUI.SetPositionX(_item_RightBottom, 7)
                GUI.SetPositionY(_item_RightBottom, 5)
                GUI.StaticSetFontSize(_item_RightBottom, 20)
                GUI.SetIsOutLine(_item_RightBottom, true)
                GUI.SetOutLine_Color(_item_RightBottom, Color.New(0 / 255, 0 / 255, 0 / 255, 255 / 255))
                GUI.SetOutLine_Distance(_item_RightBottom, 1)
                GUI.SetColor(_item_RightBottom, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
            end
        else
            GUI.ItemCtrlSetElementValue(RewardItem,eItemIconElement.Icon,"")
            GUI.ItemCtrlSetElementValue(RewardItem,eItemIconElement.Border,"1800400050")
            GUI.ItemCtrlSetElementValue(RewardItem,eItemIconElement.Selected , "")
            GUI.ItemCtrlSetElementValue(RewardItem,eItemIconElement.RightBottomNum, 0)
            GUI.SetData(RewardItem, "itemID", nil)
        end
    end
end

function RushRankUI.OnItemBgClick(guid)
    local idstr = GUI.GetData(GUI.GetByGuid(guid), "itemID")
    if not idstr then
        return
    end
    local parent = GUI.Get("RushRankUI/panelBg")
    local itemId = tonumber(idstr)

    -- local tips = GUI.GetChild(parent, "tips")
    -- if tips ~= nil then
        -- GUI.Destroy(tips)
    -- end

    tips = Tips.CreateByItemId(itemId,parent,"tips",440, 0)
end

function RushRankUI.RefreshUI()
    if not GlobalProcessing or not GlobalProcessing.RushRankData or not RushRankUI.RankList then
        return
    end
    local data = GlobalProcessing.RushRankData
    local title = GUI.Get("RushRankUI/panelBg/tipLabel")
    if title then
        GUI.StaticSetText(title, data.Title_Name)
    end
    local rankListData = RushRankUI.RankList
    local myRankTxt = GUI.Get("RushRankUI/panelBg/rankBg/myRankBg/myRankText")
    if myRankTxt then
		--当活动结束但保留时，显示活动已结束
		local tick = tonumber(tostring(CL.GetServerTickCount()))
		local data =data.RankList[CurSelectTab]
		if data and data.End_Time and data.Retain_Time and tick > data.End_Time and tick < data.Retain_Time then
			GUI.StaticSetText(myRankTxt, "活动已结束")
		else
			GUI.StaticSetText(myRankTxt, rankListData.My_Rank_TXT)
		end
    end
    local rankValueText = GUI.Get("RushRankUI/panelBg/rankBg/rankValueBg/rankValueText")
    if rankValueText then
        GUI.StaticSetText(rankValueText, rankListData.On_List_TXT)
    end
    local num1Name = GUI.Get("RushRankUI/panelBg/rankBg/num1Name")
    if num1Name then
        GUI.StaticSetText(num1Name, rankListData.First)
    end
    local num2Name = GUI.Get("RushRankUI/panelBg/rankBg/num2Name")
    if num2Name then
        GUI.StaticSetText(num2Name, rankListData.Second)
    end
    local num3Name = GUI.Get("RushRankUI/panelBg/rankBg/num3Name")
    if num3Name then
        GUI.StaticSetText(num3Name, rankListData.Third)
    end
    local tipTxt = GUI.Get("RushRankUI/panelBg/tipText")
    if tipTxt then
        GUI.StaticSetText(tipTxt, rankListData.Inf)
    end
	
    local group = GUI.Get("RushRankUI/panelBg/TabGroup")
	
    -- local childCount = GUI.GetChildCount(group)
    local list = data.RankList
    -- local itemCount = #list
    -- for i = 1, itemCount do
        -- local name = tostring(i)
        -- local tabBtn = GUI.GetChild(group, name)
        -- if not tabBtn then
            -- tabBtn = GUI.ButtonCreate( group, name, TAB_NORMAL, i * 151 - 605, -237, Transition.ColorTint, "", 148, 63, false)
            -- SetAnchorAndPivot(tabBtn, UIAnchor.Center, UIAroundPivot.Center)
            -- GUI.ButtonSetTextFontSize(tabBtn, 24)
            -- GUI.RegisterUIEvent(tabBtn, UCE.PointerClick, "RushRankUI", "OnClickTabBtn")
			-- GUI.SetData(tabBtn,"name",i)
        -- else
            -- GUI.SetVisible(tabBtn, true)
        -- end
        -- local config = list[i]
        -- GUI.ButtonSetText(tabBtn, config.Name)
		-- GUI.ButtonSetTextColor(tabBtn, UIDefine.BrownColor)
        -- if CurSelectTab == i then
            -- GUI.ButtonSetImageID(tabBtn, TAB_SELECTED)
        -- else
            -- GUI.ButtonSetImageID(tabBtn, (config.State == 1 or config.State == 2 ) and TAB_NORMAL or TAB_DISABLED)
        -- end
    -- end
    -- if childCount > itemCount then
        -- for i = itemCount + 1, childCount do
            -- local name = tostring(i)
            -- local tabBtn = GUI.GetChild(group, name)
            -- GUI.SetVisible(tabBtn, false)
        -- end
    -- end
	local rightTag = _gt.GetUI("rightTag")
	GUI.SetVisible(rightTag,#list > 7)
	
	
	--刷新上方页签按钮
    local TabScroll = _gt.GetUI("TabScroll")
    GUI.LoopScrollRectSetTotalCount(TabScroll, #list);
    GUI.LoopScrollRectRefreshCells(TabScroll)
	

    local loopScroll = GUI.Get("RushRankUI/panelBg/rightBg/loopScroll")
    GUI.LoopScrollRectSetTotalCount(loopScroll, #RushRankUI.RankList.Reward_List);
    GUI.LoopScrollRectRefreshCells(loopScroll)
	
	test(12313)
	--活动时间计时器开启
    if not RushRankUI.CountDownTimer then
        RushRankUI.CountDownTimer = Timer.New(RushRankUI.OnTimer, 1, -1)
        RushRankUI.CountDownTimer:Start()
    end
end

function RushRankUI.CreateTabItem()
	local TabScroll = _gt.GetUI("TabScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(TabScroll);
    local tabBtn = GUI.ButtonCreate( group, curCount+1, TAB_NORMAL, 0,0, Transition.ColorTint, "", 148, 63, false)
    SetAnchorAndPivot(tabBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.ButtonSetTextFontSize(tabBtn, 24)
    GUI.RegisterUIEvent(tabBtn, UCE.PointerClick, "RushRankUI", "OnClickTabBtn")
	return tabBtn
end

function RushRankUI.RefreshTabItem(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	local tabBtn = GUI.GetByGuid(guid)
	
	
	GUI.SetData(tabBtn,"name",index)
	
	local data = GlobalProcessing.RushRankData
	local list = data.RankList
	local config = list[index]
    GUI.ButtonSetText(tabBtn, config.Name)
	GUI.ButtonSetTextColor(tabBtn, UIDefine.BrownColor)	
    if CurSelectTab == index then
		GUI.ButtonSetImageID(tabBtn, TAB_SELECTED)
	else
		GUI.ButtonSetImageID(tabBtn, (config.State == 1 or config.State == 2 ) and TAB_NORMAL or TAB_DISABLED)
    end	

end

function RushRankUI.OnTabBtnDrag(guid)
	test("进了吗")
    local rightTag = _gt.GetUI("rightTag")
    local TabScroll = GUI.GetByGuid(guid)
    local x,y = GUI.GetNormalizedPosition(TabScroll):Get()
	local data = GlobalProcessing.RushRankData
	local list = data.RankList
	 
    if rightTag then
        GUI.SetVisible(rightTag, #list>7)
    end
	
	test(x)
    if x == 0 then
        GUI.SetVisible(rightTag,false)
	end
end

function RushRankUI.OnTimer()
    if not GlobalProcessing or not GlobalProcessing.RushRankData then
        return
    end
    local data = GlobalProcessing.RushRankData.RankList
    if not data then
        return
    end
    local config = data[CurSelectTab]
    if not config then
        return
    end
    local tick = tonumber(tostring(CL.GetServerTickCount()))
    if config.Start_Time > tick or config.Retain_Time < tick then
        return
    end
    local lastTimeTxt = GUI.Get("RushRankUI/panelBg/lastTimeTxt")
    if not lastTimeTxt then
        return
    end
    if config.End_Time > tick then
        local lastTime = config.End_Time - tick
        GUI.StaticSetText(lastTimeTxt, string.format("剩余时间: %d天%02d小时%02d分%02d秒", GlobalUtils.Get_DHMS1_BySeconds(lastTime)))
    else
        GUI.StaticSetText(lastTimeTxt, "剩余时间: 已结束")
    end
end

function RushRankUI.OnClose(paramter)
    if paramter ~= "RushRankUI" then
        return
    end
    if RushRankUI.CountDownTimer then
        RushRankUI.CountDownTimer:Stop()
        RushRankUI.CountDownTimer = nil
    end
end

function RushRankUI.OnDestroy()
    if RushRankUI.CountDownTimer then
        RushRankUI.CountDownTimer:Stop()
        RushRankUI.CountDownTimer = nil
    end
end
