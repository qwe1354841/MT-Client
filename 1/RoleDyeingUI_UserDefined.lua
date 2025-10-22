local RoleDyeingUI_UserDefined = {
}

_G.RoleDyeingUI_UserDefined = RoleDyeingUI_UserDefined
local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorOutline = Color.New(162 / 255.0, 75 / 225.0, 21 / 255.0, 1)

function RoleDyeingUI_UserDefined.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("RoleDyeingUI_UserDefined", "RoleDyeingUI_UserDefined", 0, 0);
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "人物染色","RoleDyeingUI_UserDefined", "OnCloseBtnClick", _gt)
	_gt.BindName(panelBg,"RoleDyeingPage")
	GUI.SetVisible(panel, false)
		
	RoleDyeingUI_UserDefined.CreateBase(panelBg)
end

function RoleDyeingUI_UserDefined.OnShow(parameter)
	--判断是否有数据
	if not GlobalProcessing.PlayerColorItem or not GlobalProcessing.PlayerColorPlan or not GlobalProcessing.PlayerColorPart then
		CL.SendNotify(NOTIFY.ShowBBMsg,"暂时未存在数据")
		return
	end
	
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(GlobalProcessing.PlayerColorPlan))
	
	-- CDebug.LogError(inspect(GlobalProcessing.PlayerColorPart))
	
	-- CDebug.LogError(inspect(GlobalProcessing.PlayerColorItem))
	
	--第一次对染色方案数据进行统一处理（增加一个方案名为自定义 放在第一个）
	if GlobalProcessing.PlayerColorPlan[1].Name ~= "自定义" then
		local temp = {Name = "自定义",
			Part1 = {},
			Part2 = {},
			Part3 = {},
		}
		table.insert(GlobalProcessing.PlayerColorPlan,1,temp)
	end
	

	
	--对服务器染色道具列表排序
	if GlobalProcessing.PlayerColorItem and #GlobalProcessing.PlayerColorItem > 0 then
		local temp = {}
		for i = 1 , #GlobalProcessing.PlayerColorItem do
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.PlayerColorItem[i])
			table.insert(temp,{Id = itemDB.Id , KeyName =GlobalProcessing.PlayerColorItem[i]})
		end	
		table.sort(temp,function(a,b)return (tonumber(a.Id) <  tonumber(b.Id)) end)
		GlobalProcessing.PlayerColorItem = {}
		for i = 1 , #temp do
			table.insert(GlobalProcessing.PlayerColorItem,temp[i].KeyName)
		end
	end	
	--获得染色道具列表
	RoleDyeingUI_UserDefined.InitPlayerColorItemList()
	
	--注册道具监听事件
	RoleDyeingUI_UserDefined.Register()
	
	
	local wnd = GUI.GetWnd("RoleDyeingUI_UserDefined")
	if wnd then
		GUI.SetVisible(wnd, true)
	end

	-- RoleDyeingUI_UserDefined.Refresh()
	CL.SendNotify(NOTIFY.SubmitForm,"FormPlayerColor","GetColorData")
end


function RoleDyeingUI_UserDefined.Register()
    CL.RegisterMessage(GM.AddNewItem, "RoleDyeingUI_UserDefined", "OnItemUpdate")
    CL.RegisterMessage(GM.UpdateItem, "RoleDyeingUI_UserDefined", "OnItemUpdate")
    CL.RegisterMessage(GM.RemoveItem, "RoleDyeingUI_UserDefined", "OnItemUpdate")
end

--当物品变化
function RoleDyeingUI_UserDefined.OnItemUpdate(item_guid,item_id)
    if not item_id then
        -- 如果是侍从信物之类的物品,背包不同无法获取到，就直接退出
        local item_data = LD.GetItemDataByGuid(item_guid)
        if item_data and item_data.id then
            item_id = item_data.id
        else
            return 
        end
    end
    item_id = tonumber(item_id)
    local itemDB = DB.GetOnceItemByKey1(item_id)
	if GlobalProcessing.PlayerColorItem then
		for k , v in pairs(GlobalProcessing.PlayerColorItem) do
			if itemDB.KeyName == v then
				RoleDyeingUI_UserDefined.InitPlayerColorItemList()
				break
			end
		end
	end

	local Scroll = _gt.GetUI("ColorItemScroll")
	if Scroll and GUI.GetVisible(Scroll) then
		RoleDyeingUI_UserDefined.RefreshColorItem()
		--刷新消耗
		if RoleDyeingUI_UserDefined.ConsumeItemList and RoleDyeingUI_UserDefined.ConsumeItemList[itemDB.KeyName] then
			RoleDyeingUI_UserDefined.RefreshConsumeItem()
		end
	end
end

function RoleDyeingUI_UserDefined.InitPlayerColorItemList()
	RoleDyeingUI_UserDefined.PlayerColorItem = {} 
	if GlobalProcessing.PlayerColorItem then
		local temp_tb = {}
		for i = 1 ,#GlobalProcessing.PlayerColorItem do
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.PlayerColorItem[i])
			
			local count = LD.GetItemCountById(itemDB.Id) 
			
			if count >= 1 then
				table.insert(RoleDyeingUI_UserDefined.PlayerColorItem,{keyname = GlobalProcessing.PlayerColorItem[i], num = count})					
			else
				table.insert(temp_tb,{keyname = GlobalProcessing.PlayerColorItem[i], num = 0 })
			end			
		end
		
		if #temp_tb > 0 then
			for i = 1 ,#temp_tb do
				table.insert(RoleDyeingUI_UserDefined.PlayerColorItem,temp_tb[i])
			end
		end
	end
end

function RoleDyeingUI_UserDefined.Refresh()
	--重置参数
	
	--默认显示第一个道具
	RoleDyeingUI_UserDefined.CurColorItemIndex = 1
	
	--默认选择第一个部位
	RoleDyeingUI_UserDefined.MountsPartIndex = 1
	
	--清空当前已选择道具
	RoleDyeingUI_UserDefined.ColorItemList = {}
	
	--默认显示不选择模板
	RoleDyeingUI_UserDefined.SchemeIndex = 1
	
	--消耗物品列表
	RoleDyeingUI_UserDefined.ConsumeItemList = {}
	
	--清空预览
	RoleDyeingUI_UserDefined.ColorPreList1 = {}
	RoleDyeingUI_UserDefined.ColorPreList2 = {}
	RoleDyeingUI_UserDefined.ColorPreList3 = {}
	RoleDyeingUI_UserDefined.ColorPreList4 = {}
	RoleDyeingUI_UserDefined.ColorPreList5 = {}
	
	
	--刷新模型
	RoleDyeingUI_UserDefined.RefreshModel()
	
	--刷新染色消耗
	RoleDyeingUI_UserDefined.RefreshConsumeItem()
	
	--刷新部位相关
	RoleDyeingUI_UserDefined.RefreshPart()
	
	--刷新染色道具
	RoleDyeingUI_UserDefined.RefreshColorItem()
	
	--刷新模板选择
	RoleDyeingUI_UserDefined.RefreshSchemeItem()
end


--模型刷新
function RoleDyeingUI_UserDefined.RefreshModel()
    local RoleID = CL.GetRoleTemplateID()
    local Sex = CL.GetIntAttr(RoleAttr.RoleAttrGender)
	local RoleDB = DB.GetRole(RoleID)
	local Model = _gt.GetUI("RoleModel")
	GUI.ReplaceWeapon(Model, 0, eRoleMovement.STAND_W1, Sex, RoleDB.Model)
	GUI.RawImageChildSetModleRotation(Model, Vector3.New(0, 0, 0))	
	
	if RoleDyeingUI_UserDefined.ColorList and next(RoleDyeingUI_UserDefined.ColorList) then
		GUI.RefreshDyeSkinJson(Model, jsonUtil.encode(RoleDyeingUI_UserDefined.ColorList), "")
	else
		GUI.RefreshDyeSkinJson(Model, "", "")
	end
end

function RoleDyeingUI_UserDefined.RefreshPart()
	RoleDyeingUI_UserDefined.CurMountsPartData = {}
	RoleDyeingUI_UserDefined.CurMountsPartData = GlobalProcessing.PlayerColorPart
	
	local PartItemScroll = _gt.GetUI("PartItemScroll")	
	GUI.LoopScrollRectSetTotalCount(PartItemScroll, #RoleDyeingUI_UserDefined.CurMountsPartData) 
	GUI.LoopScrollRectRefreshCells(PartItemScroll)

end

function RoleDyeingUI_UserDefined.RefreshConsumeItem()
	-- RoleDyeingUI_UserDefined.ConsumeItemList = {}
	--得到数量
	local num = 0
	for k , v in pairs(RoleDyeingUI_UserDefined.ConsumeItemList) do
		num = num +1
	end
	
	local ConsumeItemScroll = _gt.GetUI("ConsumeItemScroll")
	GUI.LoopScrollRectSetTotalCount(ConsumeItemScroll,num)
	GUI.LoopScrollRectRefreshCells(ConsumeItemScroll)
end

function RoleDyeingUI_UserDefined.RefreshColorItem()
	local ColorItemScroll = _gt.GetUI("ColorItemScroll")
	GUI.LoopScrollRectSetTotalCount(ColorItemScroll, math.max(#GlobalProcessing.PlayerColorItem,15)) 
	GUI.LoopScrollRectRefreshCells(ColorItemScroll)	
	
	RoleDyeingUI_UserDefined.RefreshColorItemInfo()
end


function RoleDyeingUI_UserDefined.RefreshSchemeItem()
	local Scheme = _gt.GetUI("Scheme")
	GUI.ButtonSetText(Scheme,GlobalProcessing.PlayerColorPlan[RoleDyeingUI_UserDefined.SchemeIndex].Name)
	
end


function RoleDyeingUI_UserDefined.CreateBase(panelBg)	
	--模型
	local ModelGroup = GUI.GroupCreate(panelBg, "ModelGroup", -280, 0, 0, 0)
	
	
	local ModelBottonBg = GUI.ImageCreate(ModelGroup, "ModelBottonBg", "1800600210", 20, 30)
	
	local shadow = GUI.ImageCreate(ModelGroup, "shadow", "1800400240", 15, 0)
	
	local model = GUI.RawImageCreate(ModelGroup, false, "model", "", 20, -120, 3,false,600,600)--false,600,600
	_gt.BindName(model, "model")
	model:RegisterEvent(UCE.Drag)
	-- model:RegisterEvent(UCE.PointerClick)
	GUI.AddToCamera(model)
	GUI.RawImageSetCameraConfig(model, "(0,1.55,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,5,0.01,2.0,1E-05")
	-- GUI.RegisterUIEvent(model, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnModelClick")

	local RoleModel = GUI.RawImageChildCreate(model, false, "RoleModel", 0, 0, 0)
	_gt.BindName(RoleModel, "RoleModel")
	GUI.BindPrefabWithChild(model, GUI.GetGuid(RoleModel))
	-- GUI.RegisterUIEvent(RoleModel, ULE.AnimationCallBack, "RoleDyeingUI_UserDefined", "OnAnimationCallBack")
	
	--当前消耗物品
	--消耗物品处底图
    local ConsumeItemBg = GUI.ImageCreate(panelBg,"ConsumeItemBg", "1800400200", 85, -42,  false, 500, 158)
	SetAnchorAndPivot(ConsumeItemBg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
	--左下角装饰
    local foo = GUI.ImageCreate(ConsumeItemBg,"foo", "1801502030", 3, -3)
	SetAnchorAndPivot(foo, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)

    local TextBg = GUI.ImageCreate(ConsumeItemBg,"TextBg", "1801401060", 3, -13)
	SetAnchorAndPivot(TextBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local Text = GUI.CreateStatic(TextBg,"Text", "染色消耗", -33, 1, 120, 50, "system")
	SetAnchorAndPivot(Text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(Text, 22)

	local ConsumeItemScroll = GUI.LoopScrollRectCreate(ConsumeItemBg, "ConsumeItemScroll", 0, -20, 400, 85,
	"RoleDyeingUI_UserDefined", "CreateConsumeItem", "RoleDyeingUI_UserDefined", "RefreshConsumeItemScroll", 0, true, Vector2.New(80, 81), 1, UIAroundPivot.Left, UIAnchor.Left)
	UILayout.SetSameAnchorAndPivot(ConsumeItemScroll, UILayout.Center)
	_gt.BindName(ConsumeItemScroll,"ConsumeItemScroll")
	GUI.ScrollRectSetChildSpacing(ConsumeItemScroll, Vector2.New(5, 0))

	

    local DyeingBtn =GUI.ButtonCreate(panelBg,"DyeingBtn","1800602030", -80,-42,Transition.ColorTint,"染 色",150,48,false)
	SetAnchorAndPivot(DyeingBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
	GUI.ButtonSetTextFontSize(DyeingBtn, 26)
    GUI.ButtonSetTextColor(DyeingBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(DyeingBtn, true)
    GUI.SetOutLine_Color(DyeingBtn, colorOutline)
    GUI.SetOutLine_Distance(DyeingBtn, 1)
    GUI.RegisterUIEvent(DyeingBtn, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnDyeingBtnClick")
	
    local RestoreBtn =GUI.ButtonCreate(panelBg,"RestoreBtn","1800602030", -436,-42,Transition.ColorTint,"还 原",150,48,false)
	SetAnchorAndPivot(RestoreBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
	GUI.ButtonSetTextFontSize(RestoreBtn, 26)
    GUI.ButtonSetTextColor(RestoreBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(RestoreBtn, true)
    GUI.SetOutLine_Color(RestoreBtn, colorOutline)
    GUI.SetOutLine_Distance(RestoreBtn, 1)
	GUI.RegisterUIEvent(RestoreBtn, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnRestoreBtnClick")	
	
	
    local PreviewLabelBg = GUI.ImageCreate(panelBg, "PreviewLabelBg", "1801302011",-55,-220,false,46.5,76)
    local PreviewLabelTxt = GUI.CreateStatic(PreviewLabelBg, "PreviewLabelTxt", "预览", 9, 0, 40, 120,"101")
	SetAnchorAndPivot(PreviewLabelTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(PreviewLabelTxt, 22)
    GUI.StaticSetIsGradientColor(PreviewLabelTxt,true)
	GUI.StaticSetGradient_ColorBottom(PreviewLabelTxt,Color.New(236/255,219/255,161/255,255/255))
        --设置描边
	GUI.SetIsOutLine(PreviewLabelTxt,true)
	GUI.SetOutLine_Distance(PreviewLabelTxt,3)
	GUI.SetOutLine_Color(PreviewLabelTxt,Color.New(140/255,107/255,32/255,255/255))
	
	--右侧
    local Bg = GUI.ImageCreate(panelBg, "Bg", "1800400010", 265, -14, false,510,500);
    SetAnchorAndPivot(Bg, UIAnchor.Center, UIAroundPivot.Center)

    -- local Bg1 = GUI.ImageCreate( Bg, "Bg1", "1800400450", 0, 0, false, 480, 160)
    -- SetAnchorAndPivot(Bg1, UIAnchor.Center, UIAroundPivot.Center)
	
    local TitleBg = GUI.ImageCreate(Bg,"TitleBg", "1801300160", 0, -210,  false, 276, 48)
	SetAnchorAndPivot(TitleBg, UIAnchor.Top, UIAroundPivot.Top)

    local Title = GUI.CreateStatic(TitleBg,"Title", "自定义染色", 0, 1,  224, 48, "system", true)
	SetAnchorAndPivot(TitleBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Title, 22)
    GUI.StaticSetAlignment(Title, TextAnchor.MiddleCenter)
    GUI.SetColor(Title, colorDark)
	
    local TextBg = GUI.ImageCreate(Bg,"TextBg", "1801401060", 4, 75)
	SetAnchorAndPivot(TextBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local Text = GUI.CreateStatic(TextBg,"Text", "部位选择", -33, 1, 120, 50, "system")
	SetAnchorAndPivot(Text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(Text, 22)
	

	local PartItemScroll = GUI.LoopScrollRectCreate(panelBg, "PartItemScroll", 645, -435, 360, 30,
	"RoleDyeingUI_UserDefined", "CreatePartItem", "RoleDyeingUI_UserDefined", "RefreshPartItemScroll", 0, true, Vector2.New(30, 30), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
	SetAnchorAndPivot(PartItemScroll, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
	_gt.BindName(PartItemScroll,"PartItemScroll")
	GUI.ScrollRectSetChildSpacing(PartItemScroll, Vector2.New(90, 0))	
	
    local TextBg = GUI.ImageCreate(Bg,"TextBg", "1801401060", 4, 175)
	SetAnchorAndPivot(TextBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local Text = GUI.CreateStatic(TextBg,"Text", "染料预选", -33, 1, 120, 50, "system")
	SetAnchorAndPivot(Text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(Text, 22)
	


	local Text = GUI.CreateStatic(panelBg,"Text_0", "全身方案：",85, -200,  130, 50, "system", true, false)
	SetAnchorAndPivot(Text, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)
	GUI.StaticSetFontSize(Text, 24)
	GUI.SetColor(Text, colorDark)
	
	
	local LeftBtn = GUI.ButtonCreate(Text,"LeftBtn","1800202470",100,0,Transition.ColorTint,"",40,34,false)
	SetAnchorAndPivot(LeftBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(LeftBtn, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnLeftBtnClick")
	GUI.SetEulerAngles(LeftBtn, Vector3.New(0, 0, 90))
	
	local RightBtn = GUI.ButtonCreate(Text,"RightBtn","1800202470",300,0,Transition.ColorTint,"",40,34,false)
	SetAnchorAndPivot(RightBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(RightBtn, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnRightBtnClick")
	GUI.SetEulerAngles(RightBtn, Vector3.New(0, 0, -90))
	--1800800030
    local Scheme = GUI.ButtonCreate(Text,"Scheme","1800800030", 200,0,Transition.None," ",120,40,false)
	-- GUI.RegisterUIEvent(Scheme, UCE.PointerClick , "RoleDyeingUI_UserDefined", "OnChooseSchemeClick")
	SetAnchorAndPivot(Scheme, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ButtonSetTextFontSize(Scheme, 22)
    GUI.ButtonSetTextColor(Scheme, colorDark)
	_gt.BindName(Scheme,"Scheme")
	
	
    local Bg2 = GUI.ImageCreate( Bg, "Bg2", "1800001150", -122, 100, false, 240, 270)
    SetAnchorAndPivot(Bg2, UIAnchor.Center, UIAroundPivot.Center)
	
	local ColorItemScroll = GUI.LoopScrollRectCreate(Bg2, "ColorItemScroll", 0, 0, 210, 235,
	"RoleDyeingUI_UserDefined", "CreateColorItem", "RoleDyeingUI_UserDefined", "RefreshColorItemScroll", 0, false, Vector2.New(67, 67), 3, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(ColorItemScroll, UILayout.Center)
	_gt.BindName(ColorItemScroll, "ColorItemScroll")
	GUI.ScrollRectSetChildSpacing(ColorItemScroll, Vector2.New(3, 4))		
	
    local Bg3 = GUI.ImageCreate( Bg, "Bg3", "1800001150", 122, 100, false, 240, 270)
    SetAnchorAndPivot(Bg3, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(Bg3,"ColorItemDes")

	local Item = GUI.ItemCtrlCreate(Bg3, "Item", "1800400050", -60, -75, 76, 76)
	SetAnchorAndPivot(Item, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnColorItemDesTips")

    local Name = GUI.CreateStatic( Bg3, "Name", "", 43, -75, 140, 50, "system", true, false);
    SetAnchorAndPivot(Name, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Name, 22);
    GUI.StaticSetAlignment(Name, TextAnchor.MiddleCenter);
    GUI.SetColor(Name, colorDark)

	local InfoWnd = GUI.ScrollRectCreate(Bg3, "InfoWnd", 0, 20, 210,80, 0, false, Vector2.New(210,160), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    SetAnchorAndPivot(InfoWnd, UIAnchor.Center, UIAroundPivot.Center)

	local InfoText = GUI.CreateStatic(InfoWnd,"InfoText","",0,0,0,0)
	GUI.SetColor(InfoText, colorDark)
	GUI.StaticSetFontSize(InfoText, 22)
	GUI.StaticSetAlignment(InfoText, TextAnchor.UpperLeft)

	--按钮
	local AddBtn = GUI.ButtonCreate(Bg3,"AddBtn","1800402150",80,100,Transition.ColorTint,"",46,46,false)
	SetAnchorAndPivot(AddBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(AddBtn, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnAddBtnClick")
	-- GUI.RegisterUIEvent(AddBtn, UCE.PointerDown, "RoleDyeingUI_UserDefined", "OnAddBtnDown")
	-- GUI.RegisterUIEvent(AddBtn, UCE.PointerUp, "RoleDyeingUI_UserDefined", "OnAddBtnUp")
	
	local CutDownBtn = GUI.ButtonCreate(Bg3,"CutDownBtn","1800402140",-80,100,Transition.ColorTint,"",46,46,false)
	SetAnchorAndPivot(CutDownBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(CutDownBtn, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnCutDownBtnClick")
	-- GUI.RegisterUIEvent(CutDownBtn, UCE.PointerDown, "RoleDyeingUI_UserDefined", "OnCutDownBtnDown")
	-- GUI.RegisterUIEvent(CutDownBtn, UCE.PointerUp, "RoleDyeingUI_UserDefined", "OnCutDownBtnUp")

	--输入框
    local Input = GUI.EditCreate(Bg3, "Input","1800001040", "", 0, 100, Transition.ColorTint, "system", 100, 50, 25, 10)
    GUI.EditSetBNumber(Input,true)
    GUI.EditSetProp(Input, 22, 50, TextAnchor.MiddleCenter, TextAnchor.MiddleCenter)
    GUI.EditSetMultiLineEdit(Input, LineType.SingleLine)
	GUI.EditSetMaxCharNum(Input, 4)
    GUI.EditSetTextColor(Input, UIDefine.BrownColor)
	GUI.RegisterUIEvent(Input, UCE.EndEdit, "RoleDyeingUI_UserDefined", "OnInputNumChange")
    _gt.BindName(Input,"Input")	
end

function RoleDyeingUI_UserDefined.OnColorItemDesTips(guid)
	local itemId = GUI.GetData(GUI.GetByGuid(guid),"ItemId")
	if tonumber(itemId) then
		local parent = _gt.GetUI("Scheme")
		local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", 260, -200, 50)  --创造提示
		GUI.SetData(itemtips, "ItemId", tostring(itemId))
		_gt.BindName(itemtips,"ColorItemTips")
		local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
		GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
		GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
		GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"RoleDyeingUI_UserDefined","OnClickColorItemWayBtn")
		GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
	end
end

function RoleDyeingUI_UserDefined.OnClickColorItemWayBtn()
	local tips = _gt.GetUI("ColorItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

function RoleDyeingUI_UserDefined.OnModelClick()
	local RoleModel = _gt.GetUI("RoleModel")
	GUI.ReplaceWeapon(RoleModel, 0, eRoleMovement.WALK_W1, 0)
end

function RoleDyeingUI_UserDefined.OnAnimationCallBack(guid,action)
	local RoleModel = _gt.GetUI("RoleModel")
	
	if action == System.Enum.ToInt(eRoleMovement.STAND_W1) then
		return
	end
	GUI.ReplaceWeapon(RoleModel, 0, eRoleMovement.STAND_W1, 0)
end


--消耗道具
function RoleDyeingUI_UserDefined.CreateConsumeItem()
	local ConsumeItemScroll = _gt.GetUI("ConsumeItemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(ConsumeItemScroll)
	local Item = ItemIcon.Create(ConsumeItemScroll, "ConsumeItem"..curCount, 0, 0)
	UILayout.SetSameAnchorAndPivot(Item,UILayout.Center)
	-- GUI.RegisterUIEvent(petItem, UCE.PointerClick, "MountUI", "OpenSelectedControlPetWnd")
	
	return Item
end

function RoleDyeingUI_UserDefined.RefreshConsumeItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	index = index +1 
	local tb = {}
	for k ,v in pairs(RoleDyeingUI_UserDefined.ConsumeItemList) do
		if index == v.index then
			tb["keyname"] = k
			tb["num"]  = v.num
			break
		end
	end
	
	
	local itemDB = DB.GetOnceItemByKey2(tb.keyname)
	GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(itemDB.Icon))
	GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,UIDefine.ItemIconBg[itemDB.Grade])
	local count = LD.GetItemCountById(itemDB.Id) 
	GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,tb.num)
	
	local NumTxt = GUI.ItemCtrlGetElement(Item,eItemIconElement.RightBottomNum)
	if tb.num > count then
		GUI.SetColor(NumTxt,UIDefine.RedColor)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,tb.num.."/"..count)
	else
		GUI.SetColor(NumTxt,UIDefine.White2Color)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,tb.num)
	end
end

--方案模板
--消耗道具
function RoleDyeingUI_UserDefined.CreateSchemeItem()
	local SchemeItemScroll = _gt.GetUI("SchemeItemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(SchemeItemScroll)
	
    local Scheme =GUI.ButtonCreate(SchemeItemScroll,"Scheme","1800800030", 0,0,Transition.ColorTint,GlobalProcessing.PlayerColorPlan[curCount+1].Name,0,0,false)
	GUI.RegisterUIEvent(Scheme, UCE.PointerClick , "RoleDyeingUI_UserDefined", "OnChooseSchemeClick")
	SetAnchorAndPivot(Scheme, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ButtonSetTextFontSize(Scheme, 22)
    GUI.ButtonSetTextColor(Scheme, Color.New(169/255, 127/255, 85/255, 255/255))
	
	return Scheme
end

function RoleDyeingUI_UserDefined.RefreshSchemeItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	
	index = index + 1
	
	GUI.ButtonSetText(Item,GlobalProcessing.PlayerColorPlan[index].Name)
	GUI.SetData(Item,"Index",index)
	if RoleDyeingUI_UserDefined.SchemeIndex and index == RoleDyeingUI_UserDefined.SchemeIndex then
		GUI.ButtonSetImageID(Item,"1800800040")
		GUI.ButtonSetTextColor(Item, colorDark)
	else
		GUI.ButtonSetImageID(Item,"1800800030")
		GUI.ButtonSetTextColor(Item, Color.New(169/255, 127/255, 85/255, 255/255))
	end
end

--当选择染色方案
function RoleDyeingUI_UserDefined.OnChooseSchemeClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"Index"))
	if RoleDyeingUI_UserDefined.SchemeIndex and index == RoleDyeingUI_UserDefined.SchemeIndex then
		return
	end
	RoleDyeingUI_UserDefined.SchemeIndex = index
	
	local SchemeItemScroll = _gt.GetUI("SchemeItemScroll")
	GUI.LoopScrollRectRefreshCells(SchemeItemScroll)


	RoleDyeingUI_UserDefined.SelectedColorPlan(index)
	
end

function RoleDyeingUI_UserDefined.OnLeftBtnClick(guid)
	local count = #GlobalProcessing.PlayerColorPlan
	if RoleDyeingUI_UserDefined.SchemeIndex > 1 then
		RoleDyeingUI_UserDefined.SchemeIndex = RoleDyeingUI_UserDefined.SchemeIndex - 1
	else
		RoleDyeingUI_UserDefined.SchemeIndex = count 
	end
	
	RoleDyeingUI_UserDefined.RefreshSchemeItem()
	
	RoleDyeingUI_UserDefined.SelectedColorPlan()
end

function RoleDyeingUI_UserDefined.OnRightBtnClick(guid)
	local count = #GlobalProcessing.PlayerColorPlan
	if RoleDyeingUI_UserDefined.SchemeIndex < count then
		RoleDyeingUI_UserDefined.SchemeIndex = RoleDyeingUI_UserDefined.SchemeIndex + 1
	else
		RoleDyeingUI_UserDefined.SchemeIndex = 1 
	end
	
	RoleDyeingUI_UserDefined.RefreshSchemeItem()
	
	RoleDyeingUI_UserDefined.SelectedColorPlan()
end

function RoleDyeingUI_UserDefined.OnCloseBtnClick(guid)
	GUI.CloseWnd("RoleDyeingUI_UserDefined")
end


--染色部位相关
function RoleDyeingUI_UserDefined.CreatePartItem()
    local PartItemScroll = _gt.GetUI("PartItemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(PartItemScroll)
    local PartItem = GUI.ButtonCreate(PartItemScroll, "PartItem" .. tostring(curCount), "1800208210", 0, 0, Transition.ColorTint, "", 330, 100, false)
    GUI.RegisterUIEvent(PartItem, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnPartItemClick")
	
    local Text = GUI.CreateStatic(PartItem, "Text", "",40, 2, 200, 50,"system", true)
    UILayout.SetSameAnchorAndPivot(Text, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(Text, UIDefine.FontSizeM, UIDefine.BrownColor)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleLeft)

	
	return PartItem

end

function RoleDyeingUI_UserDefined.RefreshPartItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
	local item = GUI.GetByGuid(guid)
	local text = GUI.GetChild(item,"Text")
	
	index = index + 1

	GUI.StaticSetText(text,RoleDyeingUI_UserDefined.CurMountsPartData[index])
	GUI.SetData(item,"Index",index)
	
	if RoleDyeingUI_UserDefined.MountsPartIndex and RoleDyeingUI_UserDefined.MountsPartIndex == index then
		GUI.ButtonSetImageID(item,"1800208211")
	else
		GUI.ButtonSetImageID(item,"1800208210")
	end
	
end

function RoleDyeingUI_UserDefined.OnPartItemClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"Index"))
	if RoleDyeingUI_UserDefined.MountsPartIndex ~= index then
		RoleDyeingUI_UserDefined.MountsPartIndex = index
		local PartItemScroll = _gt.GetUI("PartItemScroll")	
		GUI.LoopScrollRectRefreshCells(PartItemScroll)
	end
	
	--刷新染色道具
	-- RoleDyeingUI_UserDefined.RefreshColorItem()
	local ColorItemScroll = _gt.GetUI("ColorItemScroll")
	-- GUI.LoopScrollRectSetTotalCount(ColorItemScroll, math.max(#GlobalProcessing.PlayerColorItem,15)) 
	GUI.LoopScrollRectRefreshCells(ColorItemScroll)	
end



--染色道具
function RoleDyeingUI_UserDefined.CreateColorItem()
	local ColorItemScroll = _gt.GetUI("ColorItemScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(ColorItemScroll)
	local ColorItem = GUI.ItemCtrlCreate(ColorItemScroll, "ColorItem" .. curCount, "1800400050", 0, 0, 89, 89)
	GUI.RegisterUIEvent(ColorItem, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnColorItemClick")
	local select_ = GUI.ImageCreate(ColorItem, "select_", "1800600160", 0,-1, false, 73, 73)
    SetAnchorAndPivot(select_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(select_,false)
	local DecreaseBtn = GUI.ButtonCreate( ColorItem,"DecreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
	GUI.RegisterUIEvent(DecreaseBtn, UCE.PointerClick, "RoleDyeingUI_UserDefined", "OnDecreaseBtnClick")	
	SetAnchorAndPivot(DecreaseBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)	
	GUI.SetVisible(DecreaseBtn,false)
	
	return ColorItem
end

function RoleDyeingUI_UserDefined.RefreshColorItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid);
	local index = index+1
	local select_ = GUI.GetChild(Item,"select_")
	local DecreaseBtn = GUI.GetChild(Item,"DecreaseBtn")
	if index <= #RoleDyeingUI_UserDefined.PlayerColorItem then
		local tb = RoleDyeingUI_UserDefined.PlayerColorItem[index]
		local itemDB = DB.GetOnceItemByKey2(tb.keyname)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(itemDB.Icon))
		GUI.ItemCtrlSetElementRect(Item, eItemIconElement.Icon, 0, 0,60,61)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,tb.num)
		-- GUI.ItemCtrlSetIconGray(Item,tb.num == 0)
		-- GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,tb.bind == 1 and "1800707120" or nil)
		GUI.SetData(Item,"index",index)
		-- 是否选择
		if RoleDyeingUI_UserDefined.CurColorItemIndex and index == RoleDyeingUI_UserDefined.CurColorItemIndex then
			GUI.SetVisible(select_,true)
			RoleDyeingUI_UserDefined.CurColorItemGuid = guid
			RoleDyeingUI_UserDefined.RefreshInputText(itemDB.KeyName)
		else
			GUI.SetVisible(select_,false)
		end
		
		local NumTxt = GUI.ItemCtrlGetElement(Item,eItemIconElement.RightBottomNum)
		if RoleDyeingUI_UserDefined.ColorItemList and RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex] and RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][tb.keyname] and RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][tb.keyname] > 0  then
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][tb.keyname].."/"..tb.num)
			if tb.num >= RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][tb.keyname] then
				GUI.SetColor(NumTxt,UIDefine.White2Color)
			else
				GUI.SetColor(NumTxt,UIDefine.RedColor)
			end
			
			--减
			GUI.SetVisible(DecreaseBtn,true)
			GUI.SetData(DecreaseBtn,"limit",tb.num)
			GUI.SetData(DecreaseBtn,"keyname",tb.keyname)
		else
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,tb.num)
			GUI.SetColor(NumTxt,UIDefine.White2Color)
			GUI.SetVisible(DecreaseBtn,false)
		end
	else
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,nil)
		-- GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,nil)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,nil)
		GUI.SetData(Item,"index","")
		GUI.SetVisible(select_,false)
		GUI.SetVisible(DecreaseBtn,false)
		GUI.SetVisible(DecreaseBtn,false)
	end
end


function RoleDyeingUI_UserDefined.OnColorItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local index = tonumber(GUI.GetData(item,"index"))
	if index then
		local select_  = GUI.GetChild(item,"select_")
		GUI.SetVisible(select_,true)
		if RoleDyeingUI_UserDefined.CurColorItemGuid then
			if RoleDyeingUI_UserDefined.CurColorItemGuid ~= guid then
				local select_last  = GUI.GetChild(GUI.GetByGuid(RoleDyeingUI_UserDefined.CurColorItemGuid),"select_")
				GUI.SetVisible(select_last,false)	
			else
				RoleDyeingUI_UserDefined.CurColorItemIndex = index
				RoleDyeingUI_UserDefined.OnAddBtnClick()
			end
		end
		RoleDyeingUI_UserDefined.CurColorItemGuid = guid
		RoleDyeingUI_UserDefined.CurColorItemIndex = index
		--刷新道具信息
		RoleDyeingUI_UserDefined.RefreshColorItemInfo()
	end
end


function RoleDyeingUI_UserDefined.RefreshColorItemInfo()
	local tb = RoleDyeingUI_UserDefined.PlayerColorItem[RoleDyeingUI_UserDefined.CurColorItemIndex]
	local itemDB = DB.GetOnceItemByKey2(tb.keyname)
	local Bg = _gt.GetUI("ColorItemDes")
	local item = GUI.GetChild(Bg,"Item")
	local name = GUI.GetChild(Bg,"Name")
	local info = GUI.GetChild(Bg,"InfoText")
	local add = GUI.GetChild(Bg,"AddBtn")
	local cutDown = GUI.GetChild(Bg,"CutDownBtn")
	
	GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,tostring(itemDB.Icon))
	GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,UIDefine.ItemIconBg[itemDB.Grade])
	GUI.SetData(item,"ItemId",itemDB.Id)
	GUI.StaticSetText(name,itemDB.Name)
	GUI.StaticSetText(info,itemDB.Info)
	
	
	RoleDyeingUI_UserDefined.RefreshInputText(tb.keyname)

end

function  RoleDyeingUI_UserDefined.RefreshInputText(keyname)

	local Input = _gt.GetUI("Input")
	if RoleDyeingUI_UserDefined.ColorItemList and RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex] and RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][keyname] then
		GUI.EditSetTextM(Input,RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][keyname])
	else
		GUI.EditSetTextM(Input,0)
	end
end



function RoleDyeingUI_UserDefined.OnInputNumChange()
	local Edit = _gt.GetUI("Input")
	local InputNum = tonumber(GUI.EditGetTextM(Edit)) or 0
	local IsAdd = true
	local num = 0
	
	if InputNum < 0 then
		GUI.EditSetTextM(Edit,0)
		return
	end
	
	local tb = RoleDyeingUI_UserDefined.PlayerColorItem[RoleDyeingUI_UserDefined.CurColorItemIndex]
	if RoleDyeingUI_UserDefined.ColorItemList and  RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex]  and RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][tb.keyname] then
		local num0 =  RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][tb.keyname]
		if InputNum > num0 then
			IsAdd = true
			num = InputNum - num0
		else
			IsAdd = false
			num = num0 - InputNum
		end
	else
		IsAdd = true
		num = InputNum
	end
	
	RoleDyeingUI_UserDefined.CustomDyeingScheme(tb.keyname,IsAdd,num,tb.num)
end
--添加道具数量
function RoleDyeingUI_UserDefined.OnAddBtnClick()
	local tb = RoleDyeingUI_UserDefined.PlayerColorItem[RoleDyeingUI_UserDefined.CurColorItemIndex]
	RoleDyeingUI_UserDefined.CustomDyeingScheme(tb.keyname,true,1,tb.num)
end

--减少道具数量
function RoleDyeingUI_UserDefined.OnCutDownBtnClick()
	local tb = RoleDyeingUI_UserDefined.PlayerColorItem[RoleDyeingUI_UserDefined.CurColorItemIndex]
	RoleDyeingUI_UserDefined.CustomDyeingScheme(tb.keyname,false,1,tb.num)
end


function RoleDyeingUI_UserDefined.OnDecreaseBtnClick(guid)
	local btn = GUI.GetByGuid(guid)
	local num = tonumber(GUI.GetData(btn,"limit"))
	local keyname = GUI.GetData(btn,"keyname")
	RoleDyeingUI_UserDefined.CustomDyeingScheme(keyname,false,1,num)
end

--设置选中染色道具的数量(道具的keyname,增加true,减少false,改变的数量,拥有的数量)
function RoleDyeingUI_UserDefined.CustomDyeingScheme(item_keyname,isAdd,num,count)
	--判断当前是否为模板选择状态
	if RoleDyeingUI_UserDefined.SchemeIndex ~=1 then
		RoleDyeingUI_UserDefined.ColorItemList = {}
		RoleDyeingUI_UserDefined.ColorPreList1 = {}
		RoleDyeingUI_UserDefined.ColorPreList2 = {}
		RoleDyeingUI_UserDefined.ColorPreList3 = {}
		RoleDyeingUI_UserDefined.ColorPreList4 = {}
		RoleDyeingUI_UserDefined.ColorPreList5 = {}
		RoleDyeingUI_UserDefined.ConsumeItemList = {}
		RoleDyeingUI_UserDefined.SchemeIndex = 1
		RoleDyeingUI_UserDefined.RefreshSchemeItem()
		CL.SendNotify(NOTIFY.ShowBBMsg,"非自定义染色状态下无法调整染料道具数量！")
	end

	if not RoleDyeingUI_UserDefined.ColorItemList then
		RoleDyeingUI_UserDefined.ColorItemList = {}
	end
	
	--当前部位为 RoleDyeingUI_UserDefined.MountsPartIndex
	if not RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex] then
		RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex] = {}
	end
	
	local count_ = 0
	--当前所有部位已选中的数量
	if RoleDyeingUI_UserDefined.ConsumeItemList and RoleDyeingUI_UserDefined.ConsumeItemList[item_keyname] then
		count_ = RoleDyeingUI_UserDefined.ConsumeItemList[item_keyname].num
	end
	if RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][item_keyname] then
		local num_ = RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][item_keyname]
		if isAdd then
			RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][item_keyname] = num_ + num
			-- if num_ + num > count - count_ +num_ then
				-- CL.SendNotify(NOTIFY.ShowBBMsg, "拥有数量不足，请调整其它染色部位该道具的预览添加数量")
			-- end
		else
			RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][item_keyname] = math.max(num_ - num,0)
			--当减到0时
			if num_ - num <= 0 then
				RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][item_keyname] = nil
				--若表里没有其他物品，则还原该部位颜色
				-- if not next(RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex]) then
					
				-- end
			end
		end		
	else
		if isAdd then
			-- if count ~= 0 then
				RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex][item_keyname] = num
				-- if num > count-count_ then
					-- CL.SendNotify(NOTIFY.ShowBBMsg, "拥有数量不足，请调整其它染色部位该道具的预览添加数量")
				-- end
			-- end
		end
	end
	
	--得到表以后
	RoleDyeingUI_UserDefined.ConsumeItemList = {}
	local flag = 0
	for _ ,temp in pairs(RoleDyeingUI_UserDefined.ColorItemList)do
		if temp and next(temp) then
			for k ,v in pairs(temp) do
				if RoleDyeingUI_UserDefined.ConsumeItemList[k] then
					RoleDyeingUI_UserDefined.ConsumeItemList[k].num = RoleDyeingUI_UserDefined.ConsumeItemList[k].num + v
				else
					RoleDyeingUI_UserDefined.ConsumeItemList[k] = {}
					RoleDyeingUI_UserDefined.ConsumeItemList[k].num = v
					flag = flag +1
					RoleDyeingUI_UserDefined.ConsumeItemList[k].index = flag
				end
			end
		end
	end
	
	--刷新消耗
	RoleDyeingUI_UserDefined.RefreshConsumeItem()
	RoleDyeingUI_UserDefined.RefreshColorItem()

	--发送预览请求
	local itemlist = ""
	for k,v in pairs(RoleDyeingUI_UserDefined.ColorItemList[RoleDyeingUI_UserDefined.MountsPartIndex]) do
		itemlist = itemlist..k.."_"..v.."_"
	end
	CL.SendNotify(NOTIFY.SubmitForm,"FormPlayerColor","Dyeing_Item",RoleDyeingUI_UserDefined.MountsPartIndex,itemlist,1)
end


function RoleDyeingUI_UserDefined.SelectedColorPlan()
	local index = RoleDyeingUI_UserDefined.SchemeIndex
	if index ==1 then
		RoleDyeingUI_UserDefined.Refresh()
		return
	end
	RoleDyeingUI_UserDefined.ColorItemList = {}
	for part_index = 1 ,#RoleDyeingUI_UserDefined.CurMountsPartData do
		local tb = GlobalProcessing.PlayerColorPlan[tonumber(index)]["Part"..part_index]
		
		RoleDyeingUI_UserDefined.ColorItemList[part_index] = {}
		for i =1 , #tb do
			if type(tb[i]) == "string" then
				RoleDyeingUI_UserDefined.ColorItemList[part_index][tb[i]] = tb[i+1]
			end
		end
		
		--得到表以后
		RoleDyeingUI_UserDefined.ConsumeItemList = {}
		local flag = 0
		for _ ,temp in pairs(RoleDyeingUI_UserDefined.ColorItemList)do
			if temp and next(temp) then
				for k ,v in pairs(temp) do
					if RoleDyeingUI_UserDefined.ConsumeItemList[k] then
						RoleDyeingUI_UserDefined.ConsumeItemList[k].num = RoleDyeingUI_UserDefined.ConsumeItemList[k].num + v
					else
						RoleDyeingUI_UserDefined.ConsumeItemList[k]= {}
						RoleDyeingUI_UserDefined.ConsumeItemList[k].num = v
						flag = flag +1
						RoleDyeingUI_UserDefined.ConsumeItemList[k].index =  flag
					end
				end
			end
		end
	end
	
	--刷新消耗
	RoleDyeingUI_UserDefined.RefreshConsumeItem()
	
	RoleDyeingUI_UserDefined.RefreshColorItem()
	--发送预览请求
	CL.SendNotify(NOTIFY.SubmitForm,"FormPlayerColor","Pre_Plan",index-1)
end

function RoleDyeingUI_UserDefined.RefreshIsPre()
	--刷新模型
	local Model = _gt.GetUI("RoleModel")
	local temp = {}
	
			-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(RoleDyeingUI_UserDefined.ColorList))
	-- CDebug.LogError(inspect(RoleDyeingUI_UserDefined.ColorPreList1))
	-- CDebug.LogError(inspect(RoleDyeingUI_UserDefined.ColorPreList2))
		
	--若只有一个
	-- if next(RoleDyeingUI_UserDefined.ColorList) then
		--if next(RoleDyeingUI_UserDefined.ColorPreList1) and next(RoleDyeingUI_UserDefined.ColorPreList2) then
		--	if RoleDyeingUI_UserDefined.ColorPreList1 then
		--		for k ,v in pairs(RoleDyeingUI_UserDefined.ColorPreList1) do
		--			temp[k] = v
		--		end
		--	end
		--		
		--	if RoleDyeingUI_UserDefined.ColorPreList2 then
		--		for k ,v in pairs(RoleDyeingUI_UserDefined.ColorPreList2) do
		--			temp[k] = v
		--		end
		--	end
		--	
		--elseif next(RoleDyeingUI_UserDefined.ColorPreList1) then
		--	-- for k , v in pairs(RoleDyeingUI_UserDefined.ColorList) do
		--		-- if RoleDyeingUI_UserDefined.ColorPreList1[k] then
		--			-- temp[k] = RoleDyeingUI_UserDefined.ColorPreList1[k]
		--		-- else
		--			-- temp[k] = v
		--		-- end
		--	-- end
		--	for k , v in pairs(RoleDyeingUI_UserDefined.ColorPreList1) do
		--		temp[k] = v
		--	end
		--elseif next(RoleDyeingUI_UserDefined.ColorPreList2) then
		--	-- for k , v in pairs(RoleDyeingUI_UserDefined.ColorList) do
		--		-- if RoleDyeingUI_UserDefined.ColorPreList2[k] then
		--			-- temp[k] = RoleDyeingUI_UserDefined.ColorPreList2[k]
		--		-- else
		--			-- temp[k] = v
		--		-- end
		--	-- end	
		--	for k , v in pairs(RoleDyeingUI_UserDefined.ColorPreList2) do
		--		temp[k] = v
		--	end
		--	
		---- else
		--	-- temp = RoleDyeingUI_UserDefined.ColorList
		--end

		for i = 1, 5 do
			if next(RoleDyeingUI_UserDefined["ColorPreList"..i]) then
				for k, v in pairs(RoleDyeingUI_UserDefined["ColorPreList"..i]) do
					temp[k] = v
				end
			end
		end
		
		if next(RoleDyeingUI_UserDefined.ColorList) then
			for k ,v in pairs(RoleDyeingUI_UserDefined.ColorList) do
				if tostring(temp[k]) == "nil" then
					temp[k] = v
				end				
			end
		end
	-- else
		-- if RoleDyeingUI_UserDefined.ColorPreList1 then
			-- for k ,v in pairs(RoleDyeingUI_UserDefined.ColorPreList1) do
				-- temp[k] = v
			-- end
		-- end
		-- if RoleDyeingUI_UserDefined.ColorPreList2 then
			-- for k ,v in pairs(RoleDyeingUI_UserDefined.ColorPreList2) do
				-- temp[k] = v
			-- end
		-- end
	-- end
	
	
		-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(temp))
	
	
	if next(temp) then
		GUI.RefreshDyeSkinJson(Model, jsonUtil.encode(temp), "")
	else
		GUI.RefreshDyeSkinJson(Model, "", "")
	end	
end


function RoleDyeingUI_UserDefined.OnDyeingBtnClick()
	if RoleDyeingUI_UserDefined.SchemeIndex == 1 then
		if RoleDyeingUI_UserDefined.tablecount(RoleDyeingUI_UserDefined.ColorItemList) > 0 then
			for n, m in pairs(RoleDyeingUI_UserDefined.ColorItemList) do
				if m then
					local itemlist = ""
					for k , v in pairs(m) do
						itemlist = itemlist..k.."_"..v.."_"
					end
					CL.SendNotify(NOTIFY.SubmitForm,"FormPlayerColor","Dyeing_Item",n,itemlist,0)
				end
			end
		end
	else
		CL.SendNotify(NOTIFY.SubmitForm,"FormPlayerColor","Dyeing_Plan",RoleDyeingUI_UserDefined.SchemeIndex-1)
	end
end

function RoleDyeingUI_UserDefined.tablecount(datatable)
	local count = 0
	if type(datatable) == "table" then
		for i,v in pairs(datatable) do
			count = count+1
		end
	end
	return count
end

function RoleDyeingUI_UserDefined.OnRestoreBtnClick()
	RoleDyeingUI_UserDefined.Refresh()
end