ActivityPreview = {}

local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorOutline = Color.New(162 / 255, 75 / 255, 21 / 255)
local tipColor = Color.New(208 / 255, 140 / 255, 15 / 255, 255 / 255)
local contentColor = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local _gt = UILayout.NewGUIDUtilTable()

local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot

ActivityPreview.ActivtiyID = nil
ActivityPreview.ScrollNode = nil
ActivityPreview.MAX_COUNT = 1
ActivityPreview.Panel = nil
ActivityPreview.GotoFunc = nil

function ActivityPreview.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()

	local panel = GUI.WndCreateWnd("ActivityPreview", "ActivityPreview", 0, 0, eCanvasGroup.Normal)
	UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)
	ActivityPreview.Panel = panel
	--GUI.SetVisible(panel,false)
    local panelCover = GUI.ImageCreate( panel,"panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)

    -- 底图
    local panelBg = GUI.ImageCreate( panel,"PanelBg", "1800600182", 0, 0, false,500, 440)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)

    local rightBg = GUI.ImageCreate( panelBg,"RightBg", "1800600181", 0, -9.5, false, 175, 50)
    UILayout.SetSameAnchorAndPivot(rightBg, UILayout.TopRight)

    local leftBg = GUI.ImageCreate( panelBg,"LeftBg", "1800600180", 0, -9.5, false, 175, 50)
    UILayout.SetSameAnchorAndPivot(leftBg, UILayout.TopLeft)

    -- 标题底板
    local titleBg = GUI.ImageCreate( panelBg,"TitleBg", "1800600190", 0, -8, false, 220, 49)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)

    -- 标题
    local titleTxt = GUI.CreateStatic( titleBg,"TitleText", "活动开启", 0, 0, 200, 35)
    UILayout.SetSameAnchorAndPivot(titleTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(titleTxt, 26, colorDark, TextAnchor.MiddleCenter)

    -- 功能名称
    local NameTip = GUI.CreateStatic( panelBg,"NameTip", "[活动名称]", 30, 45, 200, 35)
    UILayout.SetSameAnchorAndPivot(NameTip, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(NameTip, 24, tipColor, nil)

    local NameText = GUI.CreateStatic( panelBg,"NameText", "30", 40, 70, 200, 70)
    UILayout.SetSameAnchorAndPivot(NameText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(NameText, UIDefine.FontSizeM, contentColor, nil)

    -- 功能介绍
    local InfoTip = GUI.CreateStatic( panelBg,"InfoTip", "[活动介绍]", 30, 120, 200, 35)
    UILayout.SetSameAnchorAndPivot(InfoTip, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(InfoTip, 24, tipColor, nil)

	local InfoText_Scr = GUI.ScrollRectCreate(panelBg, "InfoText_Scr", 0, 150, 520, 80, 0, false, Vector2.New(0, 0), UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetAnchorAndPivot(InfoText_Scr, UIAnchor.Top, UIAroundPivot.Top)
	local InfoText = GUI.CreateStatic(InfoText_Scr,"InfoText", "!", 210, 0, 420, 100, "system", false, false)
	GUI.ScrollRectSetVertical(InfoText_Scr, true);
	UILayout.SetSameAnchorAndPivot(InfoText, UILayout.TopRight)
    UILayout.StaticSetFontSizeColorAlignment(InfoText, UIDefine.FontSizeM, contentColor, TextAnchor.UpperLeft)

    -- 开启奖励
    local rewardTip = GUI.CreateStatic( panelBg,"RewardTip", "[活动奖励]", 30, 226, 200, 35)
    UILayout.SetSameAnchorAndPivot(rewardTip, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(rewardTip, 24, tipColor, nil)

	--奖励列表
	ActivityPreview.ScrollNode = GUI.ScrollRectCreate( panelBg, "scroll", 0, 108, 465, 112, 0, true, Vector2.New(80,80), UIAroundPivot.Top, UIAnchor.Top)
	GUI.ScrollRectSetChildSpacing(ActivityPreview.ScrollNode, Vector2.New(10, 0))

    --前往按钮
    local GoBtn = GUI.ButtonCreate( panelBg,"GoBtn", "1800402080", 0, -44, Transition.ColorTint, "点击前往", 158, 46, false)
    UILayout.SetAnchorAndPivot(GoBtn, UIAnchor.Bottom, UIAroundPivot.Center)
    GUI.ButtonSetTextFontSize(GoBtn, 26)
    GUI.ButtonSetTextColor(GoBtn, colorWhite)
    GUI.SetIsOutLine(GoBtn, true)
    GUI.SetOutLine_Color(GoBtn, colorOutline)
    GUI.SetOutLine_Distance(GoBtn, 1)
    GUI.RegisterUIEvent(GoBtn, UCE.PointerClick, "ActivityPreview", "OnClickGoBtn")

    -- 关闭
    local closeBtn = GUI.ButtonCreate( panelBg,"ClosePanelBtn", "1800302120", 0, -6, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "ActivityPreview", "OnClosePanel")


	CL.RegisterMessage(GM.ActivityListUpdate, "ActivityPreview", "OnActivityListUpdate")
end

function ActivityPreview.OnShow(param)


	ActivityPreview.ActivtiyID = nil
	if param == nil then
		print("ActivityPreview OnShow param == nil")
		return
	end

	ActivityPreview.GotoFunc = nil
	ActivityPreview.ActivtiyID = tonumber(param)
	print("活动id========"..ActivityPreview.ActivtiyID)

	local oneActData = LD.GetActivityDataByID(ActivityPreview.ActivtiyID)
	if oneActData == nil then
		CL.SendNotify(NOTIFY.GetActivityList)
		return
	end

	--GUI.SetVisible(ActivityPreview.Panel,true)
	ActivityPreview.RefreshPanel(ActivityPreview.ActivtiyID)
end
--设置前往活动的方法
function ActivityPreview.SetGotoFunc(func)
	ActivityPreview.GotoFunc = func
end

function ActivityPreview.OnActivityListUpdate()
	ActivityPreview.RefreshPanel(ActivityPreview.ActivtiyID)
end
--关闭方法
function ActivityPreview.OnClosePanel(guid)
	GUI.DestroyWnd("ActivityPreview")
end

function ActivityPreview.OnDestroy()
end

--跳转活动按钮
function ActivityPreview.OnClickGoBtn(key,guid)
	if ActivityPreview.ActivtiyID ~= nil then
		--if ActivityPreview.GotoFunc then
		--	ActivityPreview.GotoFunc()
		--end
		--参加活动的方法
		GlobalUtils.JoinActivity(ActivityPreview.ActivtiyID)

	end
	GUI.DestroyWnd("ActivityPreview")
end

--刷新界面
function ActivityPreview.RefreshPanel(id)
	ActivityPreview.ActivtiyID = tonumber(id)
	--根据Id获得Activity
	local data = DB.GetActivity(ActivityPreview.ActivtiyID)
	if data == nil then
		print("配置中找不到此活动的数据："..ActivityPreview.ActivtiyID)
		return
	end

	local panelBg = GUI.Get("ActivityPreview/PanelBg")
	local NameText = GUI.GetChild(panelBg,"NameText")
	local InfoText = GUI.GetChild(panelBg,"InfoText")

	GUI.StaticSetText(NameText, data.Name)
	GUI.StaticSetText(InfoText, data.DesInfo)
	--获取活动数据
	local oneActData = LD.GetActivityDataByID(ActivityPreview.ActivtiyID)
	if oneActData == nil then
		print("奖励中找不到此活动的数据："..ActivityPreview.ActivtiyID)
		return
	end

	-- 1:2:1:10:61024,61025,21112:1:2,3,5
	-- 分别对应的是 当前参加次数， 次数上限，当前获得活跃值，活跃值上限，奖励List，活动状态，属于什么奖励类型的活动
	local custom = string.split(oneActData.custom, ":")
	if #custom >= 5 then
		local itemLst = custom[5]   --"61024,61025,21112"
		local oneItem = string.split(itemLst, ",")  --{61024,61025,21112}
		local count = #oneItem   --3
		local ItemList = {}
		for i = 1, count do
			ItemList[#ItemList + 1] = tonumber(oneItem[i])
		end

		for j = 1, ActivityPreview.MAX_COUNT do
			local itembg = _gt.GetUI("item"..j)
			if itembg ~= nil then
				GUI.SetVisible(itembg, false)
			end
		end
		local itemCount = #ItemList  --3
		if ActivityPreview.MAX_COUNT < itemCount then
			ActivityPreview.MAX_COUNT = itemCount
		end
		for j = 1, itemCount do
			local itemID = ItemList[j]
			local itembg = _gt.GetUI("item"..j)
			if itembg == nil then
				itembg = ItemIcon.Create(ActivityPreview.ScrollNode, "item"..j,  0, 0, 0, 0)
				_gt.BindName(itembg, "item"..j)
				GUI.SetData(itembg, "ItemId", itemID)
				UILayout.SetSameAnchorAndPivot(itembg, UILayout.Left)
				GUI.RegisterUIEvent(itembg , UCE.PointerClick , "ActivityPreview", "OnItemClick" )
			else
				GUI.SetVisible(itembg, true)
			end

			if itemID ~= 0 then
				local itemConfig = DB.GetOnceItemByKey1(itemID)
				if itemConfig then
					ItemIcon.BindItemDB(itembg, itemConfig)
				end
			end
		end
	end
end
--物品点击方法
function ActivityPreview.OnItemClick(guid)
	local itemBg = GUI.GetByGuid(guid)
	local itemId = tonumber(GUI.GetData(itemBg, "ItemId"))

	local tips = GUI.GetChild(ActivityPreview.Panel, "tips")
	if tips ~= nil then
		GUI.Destroy(tips)
	end

	tips = Tips.CreateByItemId(itemId, ActivityPreview.Panel, "tips", 370, 6, 0)
end
