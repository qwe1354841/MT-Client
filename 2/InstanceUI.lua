--这是副本系统的UI

local InstanceUI={}
_G.InstanceUI=InstanceUI
local _gt=UILayout.NewGUIDUtilTable()


---------------------------------缓存需要的全局变量Start------------------------------
local GUI=GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
--local inspect = require("inspect")   测试用的
---------------------------------缓存需要的全局变量End-------------------------------
----------------------------------变量Start---------------------------------------
--local GlobalProcessing.InstanceUI_LabelList={
--    {"秘境","secretAreaTog","OnSecretAreaToggle","secretAreaPage","CreateSecretAreaPage"},
--    {"副本","instanceTog","OnInstanceToggle","instancePage","CreateInstancePage"}
--}
--local GlobalProcessing.InstanceUI_PageNum={
--    secretAreaPage=1,
--    instancePage=2
--}
local CurSelectPage=1   --当前选择的页面
local levelCount=8  --副本的数量
local CurSelectLevelIndex=1  --游戏当前选择的关卡
local CurSelectLevelRewardCount=4  --当前选择的关卡的奖励数量
local secretAreaServerData={}   --秘境的数据
local instanceServerData={}   --副本的数据
local curServerData={}  --当前的数据

--已移至服务器
--local parameterOne = {
--    Rift = 1,
--    Raid = 2
--}
--local parameterTwo = {
--    ["大雁塔"] = 1,
--    ["沙城遗址"] = 2,
--    ["大雁塔(困难)"] = 3,
--    ["水帘洞"] = 4,
--    ["沙城遗址(困难)"] = 5,
--    ["巅峰试炼"] = 6,
--    ["水帘洞(困难)"] = 7,
--    ["巅峰试炼(困难)"] = 8,
--    ["傲来秘宝"] = 1,
--    ["梦回千古"] = 2,
--    ["洞窟伏魔"] = 3,
--    ["人鬼绝恋"] = 4,
--    ["傲来秘宝(困难)"] = 5,
--    ["梦回千古(困难)"] = 6,
--    ["洞窟伏魔(困难)"] = 7,
--    ["人鬼绝恋(困难)"] = 8
--}
----------------------------------变量End-----------------------------------------

function InstanceUI.Main()
	_gt=UILayout.NewGUIDUtilTable()
	local panel=GUI.WndCreateWnd("InstanceUI","InstanceUI",0,0,eCanvasGroup.Normal)
	SetAnchorAndPivot(panel,UIAnchor.Center,UIAroundPivot.Center)
	local panelBg=UILayout.CreateFrame_WndStyle0(panel,"副本","InstanceUI","OnExit")
	_gt.BindName(panelBg, "panelBg")
	UILayout.CreateRightTab(GlobalProcessing.InstanceUI_LabelList,"InstanceUI")
	GUI.SetVisible(panel,false)
end



--初始化数据
function InstanceUI.InitData()
    CurSelectLevelIndex = 1
    curServerData={}
end

function InstanceUI.OnShow(parameter)
    local wnd = GUI.GetWnd("InstanceUI")
    if wnd then
        GUI.SetVisible(wnd,true)
		InstanceUI.GetData()
    end

    if parameter then
        print(tostring(parameter))
		parameter = string.split(parameter,"/")
		if GlobalProcessing.InstanceUI_parameterOne then
			CurSelectPage = GlobalProcessing.InstanceUI_parameterOne[tostring(parameter[1])] or 1
		else
			CurSelectPage = 1
		end
		if CurSelectPage == GlobalProcessing.InstanceUI_PageNum.secretAreaPage then
			CurSelectPage=nil
			InstanceUI.OnSecretAreaToggle()
		elseif CurSelectPage == GlobalProcessing.InstanceUI_PageNum.instancePage then
			CurSelectPage=nil
			InstanceUI.OnInstanceToggle()
		end
		if GlobalProcessing.InstanceUI_parameterTwo then
			CurSelectLevelIndex = GlobalProcessing.InstanceUI_parameterTwo[tostring(parameter[2])] or 1
		else
			CurSelectLevelIndex = 1
		end
		--CDebug.LogError("参数是"..tostring(parameter[]))
    end
    
end

--处理Onshow的parameter中的pageIndex
--function InstanceUI.ProcessingParameter1(parameter)
--    local pageIndex = 1
--    if parameter ~= nil then
--        local matchRule1 = "pageIndex:(%d+)"
--        pageIndex = string.match(parameter, matchRule1)
--    end
--    return tonumber(pageIndex)  or 1
--end
--处理Onshow的parameter中的levelIndex
--function InstanceUI.ProcessingParameter2(parameter)
--    local levelIndex=1
--    if parameter ~= nil then
--        local matchRule2 = "levelIndex:(%d+)"
--        levelIndex =string.match(parameter, matchRule2)
--    end
--    return tonumber(levelIndex) or 1
--end

function InstanceUI.OnExit()
    InstanceUI.OnDestroy()
end
function InstanceUI.OnClose()
    InstanceUI.SetLastPageInvisible()
    local wnd=GUI.GetWnd("InstanceUI");
    GUI.SetVisible(wnd,false)
end
function InstanceUI.OnDestroy()
    InstanceUI.OnClose()
end

function InstanceUI.ResetLastSelectPage(index)
    UILayout.OnTabClick(index,GlobalProcessing.InstanceUI_LabelList)
    if CurSelectPage==index then
        return false
    end
    InstanceUI.SetLastPageInvisible()
    CurSelectPage=index
    return true
end


function InstanceUI.SetLastPageInvisible()
    if CurSelectPage then
        local name=GlobalProcessing.InstanceUI_LabelList[CurSelectPage][4]
        local lastPage=_gt.GetUI(name)
        if lastPage then
            GUI.SetVisible(lastPage,false)
        end
        CurSelectPage=nil
    end
end

--服务端脚本调用刷新
function InstanceUI.Refresh()
	--local inspect = require("inspect")
	--print(inspect(InstanceUI.Data))
    InstanceUI.RefreshClient()
end
function InstanceUI.RefreshClient()
    --处理从服务端传过来的数据
    secretAreaServerData=InstanceUI.Data.Rift
    instanceServerData=InstanceUI.Data.Raid
    table.sort(secretAreaServerData,function(a,b)
        return a.LevelMin<b.LevelMin
    end)
    table.sort(instanceServerData,function(a,b)
        return a.LevelMin<b.LevelMin
    end)

    InstanceUI.RefreshUI(true)
end
--刷新UI界面
function InstanceUI.RefreshUI(flag)
    --刷新UI界面
    if CurSelectPage==GlobalProcessing.InstanceUI_PageNum.secretAreaPage then
        curServerData=secretAreaServerData
    elseif CurSelectPage==GlobalProcessing.InstanceUI_PageNum.instancePage then
        curServerData=instanceServerData
    end
    local curPage=_gt.GetUI(GlobalProcessing.InstanceUI_LabelList[CurSelectPage][4])
    local ScrollBg=GUI.GetChild(curPage,"ScrollBg")
    --关卡列表
    local ScrollList=GUI.GetChild(ScrollBg,"ScrollList")

    --背景介绍
    local backgroundStoryGroup=GUI.GetChild(curPage,"backgroundStoryGroup")
    local backgroundStoryInfo=GUI.GetChild(backgroundStoryGroup,"backgroundStoryInfo")
    --奖励
    --local rewardGroup=GUI.GetChild(curPage,"rewardGroup")
    --创建奖励的方法
    InstanceUI.CreateAndRefreshRewardItem()
    --刷新界面信息
    levelCount=#curServerData

    GUI.StaticSetText(backgroundStoryInfo,curServerData[CurSelectLevelIndex].ShowDesc)

    GUI.LoopScrollRectSetTotalCount(ScrollList,levelCount)
    GUI.LoopScrollRectRefreshCells(ScrollList)
    if flag then
		GUI.LoopScrollRectSrollToCell(ScrollList,CurSelectLevelIndex-1,2000)
    end
	local RemainTimes = _gt.GetUI("RemainTimes")
	if RemainTimes then
		local JoinTimes = tonumber(curServerData[CurSelectLevelIndex].JoinTimes)
		local MaxJoinTimes = tonumber(curServerData[CurSelectLevelIndex].MaxJoinTimes)
		if JoinTimes and MaxJoinTimes and MaxJoinTimes - JoinTimes >= 1 then
			GUI.StaticSetText(RemainTimes,"今日剩余次数："..(MaxJoinTimes - JoinTimes).."次")
		else
			GUI.StaticSetText(RemainTimes,"今日剩余次数：0次")
		end
	end
end

function InstanceUI.GetData()
	CL.SendNotify(NOTIFY.SubmitForm, "FormDungeon", "GetDungeonData")
end
-------------------------------------------秘境Start-----------------------------------------------------


function InstanceUI.OnSecretAreaToggle()
    if not InstanceUI.ResetLastSelectPage(GlobalProcessing.InstanceUI_PageNum.secretAreaPage) then
        return
    end
    InstanceUI.InitData()
    local pageName=GlobalProcessing.InstanceUI_LabelList[GlobalProcessing.InstanceUI_PageNum.secretAreaPage][4]
    local pageBg=_gt.GetUI(pageName)
    if not pageBg then
        InstanceUI.CreateSecretAreaPage(pageName)
    else
        GUI.SetVisible(pageBg,true)
    end
    --InstanceUI.Refresh()

    if next(secretAreaServerData) then
        InstanceUI.RefreshUI()
    end
end

--function InstanceUI.RefreshSecretAreaPage()
--
--end
function InstanceUI.CreateSecretAreaPage(pageName)
    local panelBg=_gt.GetUI("panelBg")
    local secretAreaPage=GUI.GroupCreate(panelBg,pageName,0,0,1197,635)
    _gt.BindName(secretAreaPage,pageName)
    InstanceUI.CreateLevelScroll(pageName)
    InstanceUI.CreateLevelDetails(pageName)
end
-------------------------------------------秘境End-------------------------------------------------------
-------------------------------------------副本Start-----------------------------------------------------

function InstanceUI.OnInstanceToggle()
    if not InstanceUI.ResetLastSelectPage(GlobalProcessing.InstanceUI_PageNum.instancePage) then
        return
    end
    InstanceUI.InitData()
    local pageName=GlobalProcessing.InstanceUI_LabelList[GlobalProcessing.InstanceUI_PageNum.instancePage][4]
    local pageBg=_gt.GetUI(pageName)
    if not pageBg then
        InstanceUI.CreateInstancePage(pageName)
    else
        GUI.SetVisible(pageBg,true)
    end
	--InstanceUI.Refresh()

    if next(instanceServerData) then
        InstanceUI.RefreshUI()
    end
end

--function InstanceUI.RefreshInstancePage()
--
--end
function InstanceUI.CreateInstancePage(pageName)
    local panelBg=_gt.GetUI("panelBg")
    local instancePage=GUI.GroupCreate(panelBg,pageName,0,0,1197,635)
    _gt.BindName(instancePage,pageName)
    InstanceUI.CreateLevelScroll(pageName)
    InstanceUI.CreateLevelDetails(pageName)
end
-------------------------------------------副本End-------------------------------------------------------
-------------------------------------------通用方法Start--------------------------------------------------
--创建关卡的循环列表   界面的上半部分
function InstanceUI.CreateLevelScroll(pageName)
    local curPage=_gt.GetUI(pageName)
    --背景图片
    local ScrollBg=GUI.ImageCreate(curPage,"ScrollBg","1800400200",85,55,false,1025,380)
    SetAnchorAndPivot(ScrollBg,UIAnchor.TopLeft,UIAroundPivot.TopLeft)

    --循环列表
    local childVectorSize=Vector2.New(210,380)
    local ScrollList=GUI.LoopScrollRectCreate(
            ScrollBg,
            "ScrollList",
            0,0,
            1025,380,
            "InstanceUI","CreateLevelScrollList",
            "InstanceUI","RefreshLevelScrollList",
            0,true,childVectorSize,
            0,UIAroundPivot.TopLeft,UIAnchor.TopLeft
    )
    --_gt.BindName(ScrollList,"ScrollList")
    GUI.ScrollRectSetChildSpacing(ScrollList,Vector2.New(10,0))

end
--创建关卡的详细信息及说明  界面的下半部分
function InstanceUI.CreateLevelDetails(pageName)
	print("pageName = "..pageName)
    local curPage=_gt.GetUI(pageName)
    --背景故事
    local backgroundStoryGroup=GUI.GroupCreate(curPage,"backgroundStoryGroup",20,145,420,300)
    local backgroundStoryBg=GUI.ImageCreate(backgroundStoryGroup,"backgroundStoryBg","1801100040",0,0)
    local backgroundStoryText=GUI.CreateStatic(backgroundStoryBg,"backgroundStoryText","背景故事",10,0,100,70)
    local backgroundStoryInfo=GUI.CreateStatic(backgroundStoryGroup,"backgroundStoryInfo","哈哈啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",65,55,420,150)
    SetAnchorAndPivot(backgroundStoryGroup,UIAnchor.Left,UIAroundPivot.Left)
    SetAnchorAndPivot(backgroundStoryText,UIAnchor.Left,UIAroundPivot.Left)
    SetAnchorAndPivot(backgroundStoryInfo,UIAnchor.Left,UIAroundPivot.Left)
    GUI.StaticSetFontSize(backgroundStoryText,UIDefine.FontSizeM)
    GUI.StaticSetFontSize(backgroundStoryInfo,UIDefine.FontSizeM)
    GUI.StaticSetAlignment(backgroundStoryInfo,TextAnchor.MiddleLeft)
    GUI.SetColor(backgroundStoryInfo,UIDefine.BrownColor)
	
	local TB = {}
	for k, v in pairs (GlobalProcessing.InstanceUI_LabelList) do
		TB[v[4]] = v[1]
	end
    local tmpStr = TB[pageName]
	
    --副本奖励
    local rewardGroup=GUI.GroupCreate(curPage,"rewardGroup",110,145,200,200)
    local rewardBg=GUI.ImageCreate(rewardGroup,"rewardBg","1801100040",0,0)
    local rewardText=GUI.CreateStatic(rewardBg,"rewardText",tmpStr.."奖励",10,0,100,50)
    SetAnchorAndPivot(rewardText,UIAnchor.Left,UIAroundPivot.Left)
    GUI.StaticSetFontSize(rewardText,UIDefine.FontSizeM)
    _gt.BindName(rewardGroup,"rewardGroup")
    --InstanceUI.CreateRewardItem()
	
	if tmpStr == "副本" then
		local RemainTimes = GUI.CreateStatic(curPage, "RemainTimes", "今日剩余次数：1次", 20, -95, 300, 40)
		SetAnchorAndPivot(RemainTimes, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
		GUI.StaticSetFontSize(RemainTimes,UIDefine.FontSizeM)
		GUI.SetColor(RemainTimes, UIDefine.BrownColor)
		_gt.BindName(RemainTimes,"RemainTimes")
	end
    --入口按钮
    local entranceBtn = GUI.ButtonCreate(curPage, "entranceBtn", "1800102090", -90, -35, Transition.ColorTint, "<color=#ffffff><size=26>进入"..tmpStr.."</size></color>", 160, 50, false);
    SetAnchorAndPivot(entranceBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetIsOutLine(entranceBtn,true);
    GUI.SetOutLine_Color(entranceBtn,Color.New(162/255,75/255,21/255));
    GUI.SetOutLine_Distance(entranceBtn,1);
    GUI.RegisterUIEvent(entranceBtn, UCE.PointerClick, "InstanceUI", "OnEntranceBtnClick")
end
--创建以及刷新奖励物品
function InstanceUI.CreateAndRefreshRewardItem()

    local curPage=_gt.GetUI(GlobalProcessing.InstanceUI_LabelList[CurSelectPage][4])
    local rewardGroup=GUI.GetChild(curPage,"rewardGroup")
    if not rewardGroup then
        return
    end
    --创建
    CurSelectLevelRewardCount=CurSelectPage==1 and 4 or 2

    for i = 1, CurSelectLevelRewardCount do
        local rewardItem=GUI.GetChild(rewardGroup,"rewardItem"..i)
        if rewardItem==nil then
            rewardItem=ItemIcon.Create(rewardGroup,"rewardItem"..i,-190+i*85,65,0,0)
            GUI.RegisterUIEvent(rewardItem, UCE.PointerClick, "InstanceUI", "OnItemClick");
        else
            GUI.SetVisible(rewardItem,true)
        end
    end
    --刷新   赋值
    local rewardList=string.split(curServerData[CurSelectLevelIndex].ShowItem,",")
    for i = 1,#rewardList do
        local rewardItem=GUI.GetChild(rewardGroup,"rewardItem"..i)
        local itemDB= DB.GetOnceItemByKey1(rewardList[i])
        if itemDB then
            ItemIcon.BindItemDB(rewardItem,itemDB)
            GUI.SetData(rewardItem,"ItemId",itemDB.Id)
        end
    end
    --将一些剩余的对象进行不可视
    if #rewardList<CurSelectLevelRewardCount then
        for i = #rewardList+1, CurSelectLevelRewardCount do
            local rewardItem=GUI.GetChild(rewardGroup,"rewardItem"..i)
            GUI.SetVisible(rewardItem,false)
        end
    end
end

--循环列表的创建
function InstanceUI.CreateLevelScrollList()
    local curPage=_gt.GetUI(GlobalProcessing.InstanceUI_LabelList[CurSelectPage][4])
    local ScrollBg=GUI.GetChild(curPage,"ScrollBg")
    local ScrollList=GUI.GetChild(ScrollBg,"ScrollList")
    local curCount=GUI.LoopScrollRectGetChildInPoolCount(ScrollList)
    --关卡背景
    local levelBg=GUI.ImageCreate(ScrollList,"levelBg"..curCount,"1800600270",0,0,false ,210,350)
    GUI.SetIsRaycastTarget(levelBg, true)
    levelBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(levelBg,UCE.PointerClick,"InstanceUI","OnLevelClick")
    --选中时的高亮外框
    local selectBg=GUI.ImageCreate(levelBg,"selectBg","1800600290",0,0,false ,210,380)
    GUI.SetVisible(selectBg,false)
    --关卡名字背景
    local titleBg=GUI.ImageCreate(levelBg,"titleBg","1800600260",15,20)
    local title=GUI.CreateStatic(titleBg,"title","傲来秘境",0,-30,30,125)
    local hardText=GUI.CreateStatic(levelBg,"hardText","困难",-15,0,30,125)
    GUI.StaticSetFontSize(title,UIDefine.FontSizeL)
    GUI.StaticSetFontSize(hardText,UIDefine.FontSizeL)
    --GUI.StaticSetAlignment(title,TextAnchor.MiddleCenter)
    GUI.SetColor(hardText,UIDefine.BrownColor)
    GUI.SetVisible(hardText,false)
    SetAnchorAndPivot(titleBg,UIAnchor.TopLeft,UIAroundPivot.TopLeft)
    SetAnchorAndPivot(title,UIAnchor.Center,UIAroundPivot.Center)
    SetAnchorAndPivot(hardText,UIAnchor.TopRight,UIAroundPivot.TopRight)

    --关卡需求等级
    local LevelRequirementsBg=GUI.ImageCreate(levelBg,"LevelRequirementsBg","1800600280",0,-22)
    local LevelRequirementsText=GUI.CreateStatic(LevelRequirementsBg,"LevelRequirementsText","等级"..curCount.."0",0,0,100,50)
    SetAnchorAndPivot(LevelRequirementsBg,UIAnchor.Bottom,UIAroundPivot.Bottom)
    SetAnchorAndPivot(LevelRequirementsText,UIAnchor.Center,UIAroundPivot.Center)
    GUI.StaticSetFontSize(LevelRequirementsText,UIDefine.FontSizeS)
    GUI.SetColor(LevelRequirementsText,UIDefine.BrownColor)
    GUI.StaticSetAlignment(LevelRequirementsText,TextAnchor.MiddleCenter)

    return levelBg
end
--循环列表的刷新
function InstanceUI.RefreshLevelScrollList(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local levelBg=GUI.GetByGuid(guid)
    local levelIndex=GUI.ImageGetIndex(levelBg)+1
    local selectBg=GUI.GetChild(levelBg,"selectBg")
    local titleBg=GUI.GetChild(levelBg,"titleBg")
    local title=GUI.GetChild(titleBg,"title")
    local hardText=GUI.GetChild(levelBg,"hardText")
    local LevelRequirementsBg=GUI.GetChild(levelBg,"LevelRequirementsBg")
    local LevelRequirementsText=GUI.GetChild(LevelRequirementsBg,"LevelRequirementsText")

    local levelName=string.split(curServerData[levelIndex].Dg_Name,"(")
    GUI.ImageSetImageID(levelBg,curServerData[levelIndex].ShowPic)
    GUI.StaticSetText(title,levelName[1])
    if #levelName==2 then
        GUI.SetVisible(hardText,true)
    else
        GUI.SetVisible(hardText,false)
    end
    GUI.StaticSetText(LevelRequirementsText,"等级"..curServerData[levelIndex].LevelMin)

    if CurSelectLevelIndex==levelIndex then
        GUI.SetVisible(selectBg,true)
    else
        GUI.SetVisible(selectBg,false)
    end

end
--关卡点击事件
function InstanceUI.OnLevelClick(guid)
    local levelBg=GUI.GetByGuid(guid)
    local levelIndex=GUI.ImageGetIndex(levelBg)+1
    if  CurSelectLevelIndex==levelIndex then
        return
    end
    CurSelectLevelIndex=levelIndex

    InstanceUI.RefreshUI()
end
function InstanceUI.OnItemClick(guid)
    local panelBg=_gt.GetUI(GlobalProcessing.InstanceUI_LabelList[CurSelectPage][4])
    local rewardItem=GUI.GetByGuid(guid)
    local ItemId=GUI.GetData(rewardItem,"ItemId")
    Tips.CreateByItemId(ItemId,panelBg,"ItemTips",-250,100)
end
--进入秘境/副本的点击方法
function InstanceUI.OnEntranceBtnClick()
    local levelName=curServerData[CurSelectLevelIndex].Dg_Name
    CL.SendNotify(NOTIFY.SubmitForm, "FormDungeon", "RequestEnter",levelName)
end
-------------------------------------------通用方法End----------------------------------------------------
