local MountsDyeingUI = {
}
_G.MountsDyeingUI = MountsDyeingUI
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

function MountsDyeingUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("MountsDyeingUI", "MountsDyeingUI", 0, 0);
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "坐骑染色","MountsDyeingUI", "OnCloseBtnClick", _gt)
	_gt.BindName(panelBg,"MountsDyeingPage")
	GUI.SetVisible(panel, false)

	
	-- CDebug.LogError(inspect(GlobalProcessing.MountsColorPlan))
	
	-- CDebug.LogError(inspect(GlobalProcessing.MountsColorPart))
		
	MountsDyeingUI.CreateBase(panelBg)
end

function MountsDyeingUI.OnShow(parameter)
	--判断是否有数据
	if not GlobalProcessing.MountsColorItem or not GlobalProcessing.MountsColorPlan or not GlobalProcessing.MountsColorPart then
		CL.SendNotify(NOTIFY.ShowBBMsg,"暂时未存在数据")
		return
	end
	
	--第一次对染色方案数据进行统一处理（增加一个方案名为自定义 放在第一个）
	for k ,v in pairs(GlobalProcessing.MountsColorPlan) do
		if v[1].Name ~= "自定义" then
			local temp = {Name = "自定义",
				Part1 = {},
				Part2 = {},
			}
			table.insert(v,1,temp)
		end
	end
	
	--获得我的坐骑相关列表
	MountsDyeingUI.MyMountsList = {}
	MountsDyeingUI.HaveMountsCount = 0
	--默认选择显示第一个坐骑
	MountsDyeingUI.CurMountsIndex = 1
	
	if GlobalProcessing.MountsConfig and next(GlobalProcessing.MountsConfig) then
		local tb = {}
		for k , v in pairs(GlobalProcessing.MountsConfig) do
			table.insert(tb,k)
		end
		table.sort(tb,function(a,b)return (tonumber(a) <  tonumber(b)) end)
		
		--取得当前骑乘的modelId
		local modelId = tonumber(tostring(CL.GetIntAttr(RoleAttr.RoleAttrMountId))) or 0 
		
		for i =1 , #tb do
			if tonumber(CL.GetIntCustomData("HaveMount_"..tostring(tb[i]))) == 1 then
				local temp = GlobalProcessing.MountsConfig[tb[i]]
				local model = tonumber(tostring(DB.GetOnceBuffByKey1(tonumber(tb[i])).FixedAtt1Att1Coef1))
				table.insert(MountsDyeingUI.MyMountsList,{["Id"] = tb[i],["Model"] = model , ["Name"] = temp.Name ,["Grade"] = temp.Grade})
				MountsDyeingUI.HaveMountsCount = MountsDyeingUI.HaveMountsCount + 1
				if modelId == model then
					MountsDyeingUI.CurMountsIndex = MountsDyeingUI.HaveMountsCount
				end
			end
		end
	end
	
	--如果没有坐骑，关闭窗口
	if MountsDyeingUI.HaveMountsCount == 0 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"暂未拥有可染色坐骑")
		return
	end 
	
	--对服务器染色道具列表排序
	if GlobalProcessing.MountsColorItem and #GlobalProcessing.MountsColorItem > 0 then
		local temp = {}
		for i = 1 , #GlobalProcessing.MountsColorItem do
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.MountsColorItem[i])
			table.insert(temp,{Id = itemDB.Id , KeyName =GlobalProcessing.MountsColorItem[i]})
		end	
		table.sort(temp,function(a,b)return (tonumber(a.Id) <  tonumber(b.Id)) end)
		GlobalProcessing.MountsColorItem = {}
		for i = 1 , #temp do
			table.insert(GlobalProcessing.MountsColorItem,temp[i].KeyName)
		end
	end	
	--获得染色道具列表
	MountsDyeingUI.InitMountsColorItemList()
	
	--注册道具监听事件
	MountsDyeingUI.Register()
	
	
	local wnd = GUI.GetWnd("MountsDyeingUI")
	if wnd then
		GUI.SetVisible(wnd, true)
	end

	-- MountsDyeingUI.Refresh()
	CL.SendNotify(NOTIFY.SubmitForm,"FormMount","GetColorData",MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Id)
end


function MountsDyeingUI.Register()
    CL.RegisterMessage(GM.AddNewItem, "MountsDyeingUI", "OnItemUpdate")
    CL.RegisterMessage(GM.UpdateItem, "MountsDyeingUI", "OnItemUpdate")
    CL.RegisterMessage(GM.RemoveItem, "MountsDyeingUI", "OnItemUpdate")
end

--当物品变化
function MountsDyeingUI.OnItemUpdate(item_guid,item_id)
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
	if GlobalProcessing.MountsColorItem then
		for k , v in pairs(GlobalProcessing.MountsColorItem) do
			if itemDB.KeyName == v then
				MountsDyeingUI.InitMountsColorItemList()
				break
			end
		end
	end

	local Scroll = _gt.GetUI("ColorItemScroll")
	if Scroll and GUI.GetVisible(Scroll) then
		MountsDyeingUI.RefreshColorItem()
		--刷新消耗
		if MountsDyeingUI.ConsumeItemList and MountsDyeingUI.ConsumeItemList[itemDB.KeyName] then
			MountsDyeingUI.RefreshConsumeItem()
		end
	end
end

function MountsDyeingUI.InitMountsColorItemList()
	MountsDyeingUI.MountsColorItem = {} 
	if GlobalProcessing.MountsColorItem then
		local temp_tb = {}
		for i = 1 ,#GlobalProcessing.MountsColorItem do
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.MountsColorItem[i])
			
			local count = LD.GetItemCountById(itemDB.Id) 
			
			if count >= 1 then
				table.insert(MountsDyeingUI.MountsColorItem,{keyname = GlobalProcessing.MountsColorItem[i], num = count})					
			else
				table.insert(temp_tb,{keyname = GlobalProcessing.MountsColorItem[i], num = 0 })
			end			
		end
		
		if #temp_tb > 0 then
			for i = 1 ,#temp_tb do
				table.insert(MountsDyeingUI.MountsColorItem,temp_tb[i])
			end
		end
	end
end

function MountsDyeingUI.Refresh()
	--重置参数
	
	--默认显示第一个道具
	MountsDyeingUI.CurColorItemIndex = 1
	
	--默认选择第一个部位
	MountsDyeingUI.MountsPartIndex = 1
	
	--清空当前已选择道具
	MountsDyeingUI.ColorItemList = {}
	
	--默认显示不选择模板
	MountsDyeingUI.SchemeIndex = 1
	
	--消耗物品列表
	MountsDyeingUI.ConsumeItemList = {}
	
	--清空预览
	MountsDyeingUI.ColorPreList1 = {}
	MountsDyeingUI.ColorPreList2 = {}
	MountsDyeingUI.ColorPreList3 = {}
	MountsDyeingUI.ColorPreList4 = {}
	MountsDyeingUI.ColorPreList5 = {}
	
	
	--刷新模型
	MountsDyeingUI.RefreshModel()
	
	--刷新染色消耗
	MountsDyeingUI.RefreshConsumeItem()
	
	--刷新部位相关
	MountsDyeingUI.RefreshPart()
	
	--刷新染色道具
	MountsDyeingUI.RefreshColorItem()
	
	--刷新模板选择
	MountsDyeingUI.RefreshSchemeItem()
end


--模型刷新
function MountsDyeingUI.RefreshModel()
	local Model = _gt.GetUI("MountModel")
	GUI.RawImageChildSetModelID(Model, MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Model)
	GUI.ReplaceWeapon(Model, 0, eRoleMovement.STAND_W1, 0)
	GUI.RawImageChildSetModleRotation(Model, Vector3.New(0, -45, 0))
	if MountsDyeingUI.ColorList and next(MountsDyeingUI.ColorList) then
		GUI.RefreshDyeSkinJson(Model, jsonUtil.encode(MountsDyeingUI.ColorList), "")
	else
		GUI.RefreshDyeSkinJson(Model, "", "")
	end
end

function MountsDyeingUI.RefreshPart()
	MountsDyeingUI.CurMountsPartData = {}
	MountsDyeingUI.CurMountsPartData = GlobalProcessing.MountsColorPart[MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Name]
	
	local PartItemScroll = _gt.GetUI("PartItemScroll")	
	GUI.LoopScrollRectSetTotalCount(PartItemScroll, #MountsDyeingUI.CurMountsPartData) 
	GUI.LoopScrollRectRefreshCells(PartItemScroll)

end

function MountsDyeingUI.RefreshConsumeItem()
	-- MountsDyeingUI.ConsumeItemList = {}
	--得到数量
	local num = 0
	for k , v in pairs(MountsDyeingUI.ConsumeItemList) do
		num = num +1
	end
	
	local ConsumeItemScroll = _gt.GetUI("ConsumeItemScroll")
	GUI.LoopScrollRectSetTotalCount(ConsumeItemScroll,num)
	GUI.LoopScrollRectRefreshCells(ConsumeItemScroll)
end

function MountsDyeingUI.RefreshColorItem()
	local ColorItemScroll = _gt.GetUI("ColorItemScroll")
	GUI.LoopScrollRectSetTotalCount(ColorItemScroll, math.max(#GlobalProcessing.MountsColorItem,15)) 
	GUI.LoopScrollRectRefreshCells(ColorItemScroll)	
	
	MountsDyeingUI.RefreshColorItemInfo()
end


function MountsDyeingUI.RefreshSchemeItem()
	local Scheme = _gt.GetUI("Scheme")
	GUI.ButtonSetText(Scheme,GlobalProcessing.MountsColorPlan[MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Name][MountsDyeingUI.SchemeIndex].Name)
	
	-- local SchemeItemScroll = _gt.GetUI("SchemeItemScroll")
	-- GUI.LoopScrollRectSetTotalCount(SchemeItemScroll, #GlobalProcessing.MountsColorPlan) 
	-- GUI.LoopScrollRectRefreshCells(SchemeItemScroll)
	
end


function MountsDyeingUI.CreateBase(panelBg)	
	--模型
	local ModelGroup = GUI.GroupCreate(panelBg, "ModelGroup", -280, 0, 0, 0)
	
	
	local ModelBottonBg = GUI.ImageCreate(ModelGroup, "ModelBottonBg", "1800600210", 20, 30)
	
	local shadow = GUI.ImageCreate(ModelGroup, "shadow", "1800400240", 15, 0)
	
	local model = GUI.RawImageCreate(ModelGroup, false, "model", "", -5, -120, 3,false,600,600)
	_gt.BindName(model, "model")
	model:RegisterEvent(UCE.Drag)
	model:RegisterEvent(UCE.PointerClick)
	GUI.AddToCamera(model)
	GUI.RawImageSetCameraConfig(model, "(0,1.55,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,5,0.01,2.0,1E-05");
	GUI.RegisterUIEvent(model, UCE.PointerClick, "MountsDyeingUI", "OnModelClick")

	
	local MountModel = GUI.RawImageChildCreate(model, false, "MountModel", "", 0, 0)
	_gt.BindName(MountModel, "MountModel")
	GUI.BindPrefabWithChild(model, GUI.GetGuid(MountModel))
	GUI.RegisterUIEvent(MountModel, ULE.AnimationCallBack, "MountsDyeingUI", "OnAnimationCallBack")
	
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
	"MountsDyeingUI", "CreateConsumeItem", "MountsDyeingUI", "RefreshConsumeItemScroll", 0, true, Vector2.New(80, 81), 1, UIAroundPivot.Left, UIAnchor.Left)
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
    GUI.RegisterUIEvent(DyeingBtn, UCE.PointerClick, "MountsDyeingUI", "OnDyeingBtnClick")
	
    local RestoreBtn =GUI.ButtonCreate(panelBg,"RestoreBtn","1800602030", -436,-42,Transition.ColorTint,"还 原",150,48,false)
	SetAnchorAndPivot(RestoreBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
	GUI.ButtonSetTextFontSize(RestoreBtn, 26)
    GUI.ButtonSetTextColor(RestoreBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(RestoreBtn, true)
    GUI.SetOutLine_Color(RestoreBtn, colorOutline)
    GUI.SetOutLine_Distance(RestoreBtn, 1)
	GUI.RegisterUIEvent(RestoreBtn, UCE.PointerClick, "MountsDyeingUI", "OnRestoreBtnClick")	
	
	--切换按钮
    local switchBtn = GUI.ButtonCreate( panelBg, "switchBtn", "1800600100", -460, -240, Transition.None,"",110,40,false)
    SetAnchorAndPivot(switchBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(switchBtn, UCE.PointerClick, "MountsDyeingUI", "OnSwitchBtnClick")

    local switchBtnTxt = GUI.CreateStatic(switchBtn, "switchBtnTxt", "切 换", 15, 0, 100, 50, "system", true, false);
    SetAnchorAndPivot(switchBtnTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(switchBtnTxt, 22);
    GUI.StaticSetAlignment(switchBtnTxt, TextAnchor.MiddleLeft)
    GUI.SetColor(switchBtnTxt, colorDark)
	
    local pull = GUI.ImageCreate(switchBtn, "pull", "1800707070", -10, 0)
    SetAnchorAndPivot(pull, UIAnchor.Right, UIAroundPivot.Right)
	
	
    local PreviewLabelBg = GUI.ImageCreate(panelBg, "PreviewLabelBg", "1801302011",-55,-220,false,46.5,76)
    local PreviewLabelTxt = GUI.CreateStatic(PreviewLabelBg, "PreviewLabelTxt", "预览", 9, 0, 40, 120,"101")
	SetAnchorAndPivot(PreviewLabelTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(PreviewLabelTxt, 22)
    -- GUI.StaticSetAlignment(PreviewLabelTxt, TextAnchor.MiddleCenter)
    -- GUI.SetColor(PreviewLabelTxt, colorDark)
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
	"MountsDyeingUI", "CreatePartItem", "MountsDyeingUI", "RefreshPartItemScroll", 0, true, Vector2.New(30, 30), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
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
	GUI.RegisterUIEvent(LeftBtn, UCE.PointerClick, "MountsDyeingUI", "OnLeftBtnClick")
	GUI.SetEulerAngles(LeftBtn, Vector3.New(0, 0, 90))
	
	local RightBtn = GUI.ButtonCreate(Text,"RightBtn","1800202470",300,0,Transition.ColorTint,"",40,34,false)
	SetAnchorAndPivot(RightBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(RightBtn, UCE.PointerClick, "MountsDyeingUI", "OnRightBtnClick")
	GUI.SetEulerAngles(RightBtn, Vector3.New(0, 0, -90))
	--1800800030
    local Scheme = GUI.ButtonCreate(Text,"Scheme","1800800030", 200,0,Transition.None," ",120,40,false)
	-- GUI.RegisterUIEvent(Scheme, UCE.PointerClick , "MountsDyeingUI", "OnChooseSchemeClick")
	SetAnchorAndPivot(Scheme, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ButtonSetTextFontSize(Scheme, 22)
    GUI.ButtonSetTextColor(Scheme, colorDark)
	_gt.BindName(Scheme,"Scheme")
	
	-- local SchemeItemScroll = GUI.LoopScrollRectCreate(Text, "SchemeItemScroll", 210, -1, 270, 45,
	-- "MountsDyeingUI", "CreateSchemeItem", "MountsDyeingUI", "RefreshSchemeItemScroll", 0, true, Vector2.New(120, 40), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
	-- UILayout.SetSameAnchorAndPivot(SchemeItemScroll, UILayout.Center)
	-- _gt.BindName(SchemeItemScroll,"SchemeItemScroll")
	-- GUI.ScrollRectSetChildSpacing(SchemeItemScroll, Vector2.New(20, 10))
	
	
    -- local Bg = GUI.ImageCreate(panelBg, "Bg", "1800400010", 265, 135, false,510,310);
    -- SetAnchorAndPivot(Bg, UIAnchor.Center, UIAroundPivot.Center)
	
    local Bg2 = GUI.ImageCreate( Bg, "Bg2", "1800001150", -122, 100, false, 240, 270)
    SetAnchorAndPivot(Bg2, UIAnchor.Center, UIAroundPivot.Center)
	
	local ColorItemScroll = GUI.LoopScrollRectCreate(Bg2, "ColorItemScroll", 0, 0, 210, 235,
	"MountsDyeingUI", "CreateColorItem", "MountsDyeingUI", "RefreshColorItemScroll", 0, false, Vector2.New(67, 67), 3, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(ColorItemScroll, UILayout.Center)
	_gt.BindName(ColorItemScroll, "ColorItemScroll")
	GUI.ScrollRectSetChildSpacing(ColorItemScroll, Vector2.New(3, 4))		
	
    local Bg3 = GUI.ImageCreate( Bg, "Bg3", "1800001150", 122, 100, false, 240, 270)
    SetAnchorAndPivot(Bg3, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(Bg3,"ColorItemDes")

	local Item = GUI.ItemCtrlCreate(Bg3, "Item", "1800400050", -60, -75, 76, 76)
	SetAnchorAndPivot(Item, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "MountsDyeingUI", "OnColorItemDesTips")

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
	GUI.RegisterUIEvent(AddBtn, UCE.PointerClick, "MountsDyeingUI", "OnAddBtnClick")
	-- GUI.RegisterUIEvent(AddBtn, UCE.PointerDown, "MountsDyeingUI", "OnAddBtnDown")
	-- GUI.RegisterUIEvent(AddBtn, UCE.PointerUp, "MountsDyeingUI", "OnAddBtnUp")
	
	local CutDownBtn = GUI.ButtonCreate(Bg3,"CutDownBtn","1800402140",-80,100,Transition.ColorTint,"",46,46,false)
	SetAnchorAndPivot(CutDownBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(CutDownBtn, UCE.PointerClick, "MountsDyeingUI", "OnCutDownBtnClick")
	-- GUI.RegisterUIEvent(CutDownBtn, UCE.PointerDown, "MountsDyeingUI", "OnCutDownBtnDown")
	-- GUI.RegisterUIEvent(CutDownBtn, UCE.PointerUp, "MountsDyeingUI", "OnCutDownBtnUp")

	--输入框
    local Input = GUI.EditCreate(Bg3, "Input","1800001040", "", 0, 100, Transition.ColorTint, "system", 100, 50, 25, 10)
    GUI.EditSetBNumber(Input,true)
    GUI.EditSetProp(Input, 22, 50, TextAnchor.MiddleCenter, TextAnchor.MiddleCenter)
    GUI.EditSetMultiLineEdit(Input, LineType.SingleLine)
	GUI.EditSetMaxCharNum(Input, 4)
    GUI.EditSetTextColor(Input, UIDefine.BrownColor)
	GUI.RegisterUIEvent(Input, UCE.EndEdit, "MountsDyeingUI", "OnInputNumChange")
    _gt.BindName(Input,"Input")	
end

function MountsDyeingUI.OnColorItemDesTips(guid)
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
		GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"MountsDyeingUI","OnClickColorItemWayBtn")
		GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
	end
end

function MountsDyeingUI.OnClickColorItemWayBtn()
	local tips = _gt.GetUI("ColorItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

function MountsDyeingUI.OnModelClick()
	local MountModel = _gt.GetUI("MountModel")
	GUI.ReplaceWeapon(MountModel, 0, eRoleMovement.WALK_W1, 0)
end

function MountsDyeingUI.OnAnimationCallBack(guid,action)
	local MountModel = _gt.GetUI("MountModel")
	
	if action == System.Enum.ToInt(eRoleMovement.STAND_W1) then
		return
	end
	GUI.ReplaceWeapon(MountModel, 0, eRoleMovement.STAND_W1, 0)
end


--消耗道具
function MountsDyeingUI.CreateConsumeItem()
	local ConsumeItemScroll = _gt.GetUI("ConsumeItemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(ConsumeItemScroll)
	local Item = ItemIcon.Create(ConsumeItemScroll, "ConsumeItem"..curCount, 0, 0)
	UILayout.SetSameAnchorAndPivot(Item,UILayout.Center)
	-- GUI.RegisterUIEvent(petItem, UCE.PointerClick, "MountUI", "OpenSelectedControlPetWnd")
	
	return Item
end

function MountsDyeingUI.RefreshConsumeItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	index = index +1 
	local tb = {}
	for k ,v in pairs(MountsDyeingUI.ConsumeItemList) do
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
function MountsDyeingUI.CreateSchemeItem()
	local SchemeItemScroll = _gt.GetUI("SchemeItemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(SchemeItemScroll)
	
    local Scheme =GUI.ButtonCreate(SchemeItemScroll,"Scheme","1800800030", 0,0,Transition.ColorTint,GlobalProcessing.MountsColorPlan[MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Name][curCount+1].Name,0,0,false)
	GUI.RegisterUIEvent(Scheme, UCE.PointerClick , "MountsDyeingUI", "OnChooseSchemeClick")
	SetAnchorAndPivot(Scheme, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ButtonSetTextFontSize(Scheme, 22)
    GUI.ButtonSetTextColor(Scheme, Color.New(169/255, 127/255, 85/255, 255/255))
	
	return Scheme
end

function MountsDyeingUI.RefreshSchemeItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	
	index = index + 1
	
	GUI.ButtonSetText(Item,GlobalProcessing.MountsColorPlan[MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Name][index].Name)
	GUI.SetData(Item,"Index",index)
	if MountsDyeingUI.SchemeIndex and index == MountsDyeingUI.SchemeIndex then
		GUI.ButtonSetImageID(Item,"1800800040")
		GUI.ButtonSetTextColor(Item, colorDark)
	else
		GUI.ButtonSetImageID(Item,"1800800030")
		GUI.ButtonSetTextColor(Item, Color.New(169/255, 127/255, 85/255, 255/255))
	end
end

--当选择染色方案
function MountsDyeingUI.OnChooseSchemeClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"Index"))
	if MountsDyeingUI.SchemeIndex and index == MountsDyeingUI.SchemeIndex then
		return
	end
	MountsDyeingUI.SchemeIndex = index
	
	local SchemeItemScroll = _gt.GetUI("SchemeItemScroll")
	GUI.LoopScrollRectRefreshCells(SchemeItemScroll)


	MountsDyeingUI.SelectedColorPlan(index)
	
end

function MountsDyeingUI.OnLeftBtnClick(guid)
	local count = #GlobalProcessing.MountsColorPlan[MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Name]
	if MountsDyeingUI.SchemeIndex > 1 then
		MountsDyeingUI.SchemeIndex = MountsDyeingUI.SchemeIndex - 1
	else
		MountsDyeingUI.SchemeIndex = count 
	end
	
	MountsDyeingUI.RefreshSchemeItem()
	
	MountsDyeingUI.SelectedColorPlan()
end

function MountsDyeingUI.OnRightBtnClick(guid)
	local count = #GlobalProcessing.MountsColorPlan[MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Name]
	if MountsDyeingUI.SchemeIndex < count then
		MountsDyeingUI.SchemeIndex = MountsDyeingUI.SchemeIndex + 1
	else
		MountsDyeingUI.SchemeIndex = 1 
	end
	
	MountsDyeingUI.RefreshSchemeItem()
	
	MountsDyeingUI.SelectedColorPlan()
end

function MountsDyeingUI.OnCloseBtnClick(guid)
	GUI.CloseWnd("MountsDyeingUI")
end


--点击切换坐骑
function MountsDyeingUI.OnSwitchBtnClick()
	--数据处理
	local Page = _gt.GetUI("MountsDyeingPage")
    local Bg = GUI.ImageCreate(Page, "Bg", "1800400010", 80, 110, false, 250, 400)
    UILayout.SetSameAnchorAndPivot(Bg, UILayout.TopLeft)
    GUI.SetIsRaycastTarget(Bg, true)
    Bg:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRemoveWhenClick(Bg, true)
    local titelBg = GUI.ImageCreate(Bg, "titelBg", "1800700250", 4, 4,true)
    UILayout.SetSameAnchorAndPivot(titelBg, UILayout.TopLeft)
    local titel = GUI.CreateStatic(titelBg, "titel", "我的坐骑",20, 0, 200, 50,"system", true)
    UILayout.SetSameAnchorAndPivot(titel, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(titel, UIDefine.FontSizeS, UIDefine.BrownColor)
	
	local MountsScroll = GUI.LoopScrollRectCreate(Bg, "MountsScroll", 0, 15, 230, 340,
	"MountsDyeingUI", "CreateMountsItem", "MountsDyeingUI", "RefreshMountsScroll", 0, false, Vector2.New(240, 80), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(MountsScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(MountsScroll, Vector2.New(1, 1))
	_gt.BindName(MountsScroll, "MountsScroll")		
	
	GUI.LoopScrollRectSetTotalCount(MountsScroll, MountsDyeingUI.HaveMountsCount or 0) 
	GUI.LoopScrollRectRefreshCells(MountsScroll)	
end


function MountsDyeingUI.CreateMountsItem()
    local MountsScroll = _gt.GetUI("MountsScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(MountsScroll)
    local MountsItem = GUI.ButtonCreate(MountsScroll, "MountsItem" .. tostring(curCount), "1800700030", 0, 0, Transition.ColorTint, "", 330, 100, false)
    GUI.RegisterUIEvent(MountsItem, UCE.PointerClick, "MountsDyeingUI", "OnMountsItemClick")
	
    local Name = GUI.CreateStatic(MountsItem, "Name", "坐骑",80, 0, 200, 50,"system", true)
    UILayout.SetSameAnchorAndPivot(Name, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(Name, UIDefine.FontSizeL, UIDefine.BrownColor)
	GUI.StaticSetAlignment(Name, TextAnchor.MiddleLeft)

    local Grade = GUI.ImageCreate(MountsItem, "Grade", "1800201110", 20, 0,true,67,68)
    UILayout.SetSameAnchorAndPivot(Grade, UILayout.Left)
	
    -- local Have = GUI.CreateStatic(MountsItem, "Have", "",20, 16, 200, 50,"system", true)
    -- UILayout.SetSameAnchorAndPivot(Have, UILayout.Left)
    -- UILayout.StaticSetFontSizeColorAlignment(Have, UIDefine.FontSizeSS, UIDefine.BrownColor)
	-- GUI.StaticSetAlignment(Have, TextAnchor.MiddleLeft)
	
	return MountsItem

end

function MountsDyeingUI.RefreshMountsScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
	local item = GUI.GetByGuid(guid)
	
	local grade = GUI.GetChild(item,"Grade")
	local name = GUI.GetChild(item,"Name")
	
	index = index + 1
	local tb = MountsDyeingUI.MyMountsList[index]
	GUI.ImageSetImageID(grade,UIDefine.ItemSSR[tb.Grade])
	GUI.StaticSetText(name,tb.Name)
	GUI.SetData(item,"Index",index)
	if MountsDyeingUI.CurMountsIndex == index then
		GUI.ButtonSetImageID(item,"1800700040")
	else
		GUI.ButtonSetImageID(item,"1800700030")
	end
end



function MountsDyeingUI.OnMountsItemClick(guid)
	local Index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"Index"))
	if Index then
		MountsDyeingUI.CurMountsIndex = Index
		CL.SendNotify(NOTIFY.SubmitForm,"FormMount","GetColorData",MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Id)
	end
end

--染色部位相关
function MountsDyeingUI.CreatePartItem()
    local PartItemScroll = _gt.GetUI("PartItemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(PartItemScroll)
    local PartItem = GUI.ButtonCreate(PartItemScroll, "PartItem" .. tostring(curCount), "1800208210", 0, 0, Transition.ColorTint, "", 330, 100, false)
    GUI.RegisterUIEvent(PartItem, UCE.PointerClick, "MountsDyeingUI", "OnPartItemClick")
	
    local Text = GUI.CreateStatic(PartItem, "Text", "",40, 2, 200, 50,"system", true)
    UILayout.SetSameAnchorAndPivot(Text, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(Text, UIDefine.FontSizeM, UIDefine.BrownColor)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleLeft)


	
	return PartItem

end

function MountsDyeingUI.RefreshPartItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
	local item = GUI.GetByGuid(guid)
	local text = GUI.GetChild(item,"Text")
	
	index = index + 1

	GUI.StaticSetText(text,MountsDyeingUI.CurMountsPartData[index])
	GUI.SetData(item,"Index",index)
	
	if MountsDyeingUI.MountsPartIndex and MountsDyeingUI.MountsPartIndex == index then
		GUI.ButtonSetImageID(item,"1800208211")
	else
		GUI.ButtonSetImageID(item,"1800208210")
	end
	
end

function MountsDyeingUI.OnPartItemClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"Index"))
	if MountsDyeingUI.MountsPartIndex ~= index then
		MountsDyeingUI.MountsPartIndex = index
		local PartItemScroll = _gt.GetUI("PartItemScroll")	
		GUI.LoopScrollRectRefreshCells(PartItemScroll)
	end
	
	--刷新染色道具
	-- MountsDyeingUI.RefreshColorItem()
	local ColorItemScroll = _gt.GetUI("ColorItemScroll")
	-- GUI.LoopScrollRectSetTotalCount(ColorItemScroll, math.max(#GlobalProcessing.MountsColorItem,15)) 
	GUI.LoopScrollRectRefreshCells(ColorItemScroll)	
end



--染色道具
function MountsDyeingUI.CreateColorItem()
	local ColorItemScroll = _gt.GetUI("ColorItemScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(ColorItemScroll)
	local ColorItem = GUI.ItemCtrlCreate(ColorItemScroll, "ColorItem" .. curCount, "1800400050", 0, 0, 89, 89)
	GUI.RegisterUIEvent(ColorItem, UCE.PointerClick, "MountsDyeingUI", "OnColorItemClick")
	local select_ = GUI.ImageCreate(ColorItem, "select_", "1800600160", 0,-1, false, 73, 73)
    SetAnchorAndPivot(select_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(select_,false)
	local DecreaseBtn = GUI.ButtonCreate( ColorItem,"DecreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
	GUI.RegisterUIEvent(DecreaseBtn, UCE.PointerClick, "MountsDyeingUI", "OnDecreaseBtnClick")	
	SetAnchorAndPivot(DecreaseBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)	
	GUI.SetVisible(DecreaseBtn,false)
	
	return ColorItem
end

function MountsDyeingUI.RefreshColorItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid);
	local index = index+1
	local select_ = GUI.GetChild(Item,"select_")
	local DecreaseBtn = GUI.GetChild(Item,"DecreaseBtn")
	if index <= #MountsDyeingUI.MountsColorItem then
		local tb = MountsDyeingUI.MountsColorItem[index]
		local itemDB = DB.GetOnceItemByKey2(tb.keyname)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(itemDB.Icon))
		GUI.ItemCtrlSetElementRect(Item, eItemIconElement.Icon, 0, 0,60,61)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,tb.num)
		-- GUI.ItemCtrlSetIconGray(Item,tb.num == 0)
		-- GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,tb.bind == 1 and "1800707120" or nil)
		GUI.SetData(Item,"index",index)
		-- 是否选择
		if MountsDyeingUI.CurColorItemIndex and index == MountsDyeingUI.CurColorItemIndex then
			GUI.SetVisible(select_,true)
			MountsDyeingUI.CurColorItemGuid = guid
			MountsDyeingUI.RefreshInputText(itemDB.KeyName)
		else
			GUI.SetVisible(select_,false)
		end
		
		local NumTxt = GUI.ItemCtrlGetElement(Item,eItemIconElement.RightBottomNum)
		if MountsDyeingUI.ColorItemList and MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex] and MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][tb.keyname] and MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][tb.keyname] > 0  then
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][tb.keyname].."/"..tb.num)
			if tb.num >= MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][tb.keyname] then
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


function MountsDyeingUI.OnColorItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local index = tonumber(GUI.GetData(item,"index"))
	if index then
		local select_  = GUI.GetChild(item,"select_")
		GUI.SetVisible(select_,true)
		if MountsDyeingUI.CurColorItemGuid then
			if MountsDyeingUI.CurColorItemGuid ~= guid then
				local select_last  = GUI.GetChild(GUI.GetByGuid(MountsDyeingUI.CurColorItemGuid),"select_")
				GUI.SetVisible(select_last,false)	
			else
				MountsDyeingUI.CurColorItemIndex = index
				MountsDyeingUI.OnAddBtnClick()
			end
		end
		MountsDyeingUI.CurColorItemGuid = guid
		MountsDyeingUI.CurColorItemIndex = index
		--刷新道具信息
		MountsDyeingUI.RefreshColorItemInfo()
	end
end


function MountsDyeingUI.RefreshColorItemInfo()
	local tb = MountsDyeingUI.MountsColorItem[MountsDyeingUI.CurColorItemIndex]
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
	
	
	MountsDyeingUI.RefreshInputText(tb.keyname)
	--按钮
	--如果数量已满
	-- local num1 = tb.num --拥有的数量
	-- local num2 = --当前选中的数量
	-- if tb.num > 
	
	
	-- else
	
	
	-- end
	-- MountsDyeingUI.RefreshInputText(itemDB.KeyName)
end

function  MountsDyeingUI.RefreshInputText(keyname)

	local Input = _gt.GetUI("Input")
	if MountsDyeingUI.ColorItemList and MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex] and MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][keyname] then
		GUI.EditSetTextM(Input,MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][keyname])
	else
		GUI.EditSetTextM(Input,0)
	end

end




function MountsDyeingUI.OnInputNumChange()
	local Edit = _gt.GetUI("Input")
	local InputNum = tonumber(GUI.EditGetTextM(Edit)) or 0
	local IsAdd = true
	local num = 0
	
	if InputNum < 0 then
		GUI.EditSetTextM(Edit,0)
		return
	end
	
	local tb = MountsDyeingUI.MountsColorItem[MountsDyeingUI.CurColorItemIndex]
	if MountsDyeingUI.ColorItemList and  MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex]  and MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][tb.keyname] then
		local num0 =  MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][tb.keyname]
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
	
	MountsDyeingUI.CustomDyeingScheme(tb.keyname,IsAdd,num,tb.num)
end
--添加道具数量
function MountsDyeingUI.OnAddBtnClick()
	local tb = MountsDyeingUI.MountsColorItem[MountsDyeingUI.CurColorItemIndex]
	MountsDyeingUI.CustomDyeingScheme(tb.keyname,true,1,tb.num)
end

--减少道具数量
function MountsDyeingUI.OnCutDownBtnClick()
	local tb = MountsDyeingUI.MountsColorItem[MountsDyeingUI.CurColorItemIndex]
	MountsDyeingUI.CustomDyeingScheme(tb.keyname,false,1,tb.num)
end

function MountsDyeingUI.OnAddBtnDown()
	

end

function MountsDyeingUI.OnDecreaseBtnClick(guid)
	local btn = GUI.GetByGuid(guid)
	local num = tonumber(GUI.GetData(btn,"limit"))
	local keyname = GUI.GetData(btn,"keyname")
	MountsDyeingUI.CustomDyeingScheme(keyname,false,1,num)
end

--设置选中染色道具的数量(道具的keyname,增加true,减少false,改变的数量,拥有的数量)
function MountsDyeingUI.CustomDyeingScheme(item_keyname,isAdd,num,count)
	--判断当前是否为模板选择状态
	if MountsDyeingUI.SchemeIndex ~=1 then
		MountsDyeingUI.ColorItemList = {}
		MountsDyeingUI.ColorPreList1 = {}
		MountsDyeingUI.ColorPreList2 = {}
		MountsDyeingUI.ColorPreList3 = {}
		MountsDyeingUI.ColorPreList4 = {}
		MountsDyeingUI.ColorPreList5 = {}
		MountsDyeingUI.ConsumeItemList = {}
		MountsDyeingUI.SchemeIndex = 1
		MountsDyeingUI.RefreshSchemeItem()
		CL.SendNotify(NOTIFY.ShowBBMsg,"非自定义染色状态下无法调整染料道具数量！")
	end

	if not MountsDyeingUI.ColorItemList then
		MountsDyeingUI.ColorItemList = {}
	end
	
	--当前部位为 MountsDyeingUI.MountsPartIndex
	if not MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex] then
		MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex] = {}
	end
	
	local count_ = 0
	--当前所有部位已选中的数量
	if MountsDyeingUI.ConsumeItemList and MountsDyeingUI.ConsumeItemList[item_keyname] then
		count_ = MountsDyeingUI.ConsumeItemList[item_keyname].num
	end
	if MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][item_keyname] then
		local num_ = MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][item_keyname]
		if isAdd then
			MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][item_keyname] = num_ + num
			-- if num_ + num > count - count_ +num_ then
				-- CL.SendNotify(NOTIFY.ShowBBMsg, "拥有数量不足，请调整其它染色部位该道具的预览添加数量")
			-- end
		else
			MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][item_keyname] = math.max(num_ - num,0)
			--当减到0时
			if num_ - num <= 0 then
				MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][item_keyname] = nil
				--若表里没有其他物品，则还原该部位颜色
				-- if not next(MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex]) then
					
				-- end
			end
		end		
	else
		if isAdd then
			-- if count ~= 0 then
				MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex][item_keyname] = num
				-- if num > count-count_ then
					-- CL.SendNotify(NOTIFY.ShowBBMsg, "拥有数量不足，请调整其它染色部位该道具的预览添加数量")
				-- end
			-- end
		end
	end
	
	--得到表以后
	MountsDyeingUI.ConsumeItemList = {}
	local flag = 0
	for _ ,temp in pairs(MountsDyeingUI.ColorItemList)do
		if temp and next(temp) then
			for k ,v in pairs(temp) do
				if MountsDyeingUI.ConsumeItemList[k] then
					MountsDyeingUI.ConsumeItemList[k].num = MountsDyeingUI.ConsumeItemList[k].num + v
				else
					MountsDyeingUI.ConsumeItemList[k] = {}
					MountsDyeingUI.ConsumeItemList[k].num = v
					flag = flag +1
					MountsDyeingUI.ConsumeItemList[k].index = flag
				end
			end
		end
	end
	
	--刷新消耗
	MountsDyeingUI.RefreshConsumeItem()
	MountsDyeingUI.RefreshColorItem()

	--发送预览请求
	local itemlist = ""
	for k,v in pairs(MountsDyeingUI.ColorItemList[MountsDyeingUI.MountsPartIndex]) do
		itemlist = itemlist..k.."_"..v.."_"
	end
	CL.SendNotify(NOTIFY.SubmitForm,"FormMount","MountDyeing_Item",MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Id,MountsDyeingUI.MountsPartIndex,itemlist,1)
end


function MountsDyeingUI.SelectedColorPlan()
	local index = MountsDyeingUI.SchemeIndex
	if index ==1 then
		MountsDyeingUI.Refresh()
		return
	end
	MountsDyeingUI.ColorItemList = {}
	for part_index = 1 ,#MountsDyeingUI.CurMountsPartData do
		local tb = GlobalProcessing.MountsColorPlan[MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Name][tonumber(index)]["Part"..part_index]
		
		MountsDyeingUI.ColorItemList[part_index] = {}
		for i =1 , #tb do
			if type(tb[i]) == "string" then
				MountsDyeingUI.ColorItemList[part_index][tb[i]] = tb[i+1]
			end
		end
		
		--得到表以后
		MountsDyeingUI.ConsumeItemList = {}
		local flag = 0
		for _ ,temp in pairs(MountsDyeingUI.ColorItemList)do
			if temp and next(temp) then
				for k ,v in pairs(temp) do
					if MountsDyeingUI.ConsumeItemList[k] then
						MountsDyeingUI.ConsumeItemList[k].num = MountsDyeingUI.ConsumeItemList[k].num + v
					else
						MountsDyeingUI.ConsumeItemList[k]= {}
						MountsDyeingUI.ConsumeItemList[k].num = v
						flag = flag +1
						MountsDyeingUI.ConsumeItemList[k].index =  flag
					end
				end
			end
		end
	end
	
	--刷新消耗
	MountsDyeingUI.RefreshConsumeItem()
	
	MountsDyeingUI.RefreshColorItem()
	--发送预览请求
	CL.SendNotify(NOTIFY.SubmitForm,"FormMount","MountPre_Plan",MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Id,index-1)
end

function MountsDyeingUI.RefreshIsPre()
	--刷新模型
	local Model = _gt.GetUI("MountModel")
	local temp = {}
	
			-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(MountsDyeingUI.ColorList))
	-- CDebug.LogError(inspect(MountsDyeingUI.ColorPreList1))
	-- CDebug.LogError(inspect(MountsDyeingUI.ColorPreList2))
		
	--若只有一个
	-- if next(MountsDyeingUI.ColorList) then
		--if next(MountsDyeingUI.ColorPreList1) and next(MountsDyeingUI.ColorPreList2) then
		--	if MountsDyeingUI.ColorPreList1 then
		--		for k ,v in pairs(MountsDyeingUI.ColorPreList1) do
		--			temp[k] = v
		--		end
		--	end
		--		
		--	if MountsDyeingUI.ColorPreList2 then
		--		for k ,v in pairs(MountsDyeingUI.ColorPreList2) do
		--			temp[k] = v
		--		end
		--	end
		--	
		--elseif next(MountsDyeingUI.ColorPreList1) then
		--	-- for k , v in pairs(MountsDyeingUI.ColorList) do
		--		-- if MountsDyeingUI.ColorPreList1[k] then
		--			-- temp[k] = MountsDyeingUI.ColorPreList1[k]
		--		-- else
		--			-- temp[k] = v
		--		-- end
		--	-- end
		--	for k , v in pairs(MountsDyeingUI.ColorPreList1) do
		--		temp[k] = v
		--	end
		--elseif next(MountsDyeingUI.ColorPreList2) then
		--	-- for k , v in pairs(MountsDyeingUI.ColorList) do
		--		-- if MountsDyeingUI.ColorPreList2[k] then
		--			-- temp[k] = MountsDyeingUI.ColorPreList2[k]
		--		-- else
		--			-- temp[k] = v
		--		-- end
		--	-- end	
		--	for k , v in pairs(MountsDyeingUI.ColorPreList2) do
		--		temp[k] = v
		--	end
		--	
		---- else
		--	-- temp = MountsDyeingUI.ColorList
		--end

		for i = 1, 5 do
			if next(MountsDyeingUI["ColorPreList"..i]) then
				for k, v in pairs(MountsDyeingUI["ColorPreList"..i]) do
					temp[k] = v
				end
			end
		end
		
		if next(MountsDyeingUI.ColorList) then
			for k ,v in pairs(MountsDyeingUI.ColorList) do
				if tostring(temp[k]) == "nil" then
					temp[k] = v
				end				
			end
		end
	-- else
		-- if MountsDyeingUI.ColorPreList1 then
			-- for k ,v in pairs(MountsDyeingUI.ColorPreList1) do
				-- temp[k] = v
			-- end
		-- end
		-- if MountsDyeingUI.ColorPreList2 then
			-- for k ,v in pairs(MountsDyeingUI.ColorPreList2) do
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


function MountsDyeingUI.OnDyeingBtnClick()
	if MountsDyeingUI.SchemeIndex == 1 then
		if MountsDyeingUI.tablecount(MountsDyeingUI.ColorItemList) > 0 then
			for n, m in pairs(MountsDyeingUI.ColorItemList) do
				if m then
					local itemlist = ""
					for k , v in pairs(m) do
						itemlist = itemlist..k.."_"..v.."_"
					end
					CL.SendNotify(NOTIFY.SubmitForm,"FormMount","MountDyeing_Item",MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Id,n,itemlist,0)
				end
			end
			--for i =1 , MountsDyeingUI.tablecount(MountsDyeingUI.ColorItemList) do
			--	if MountsDyeingUI.ColorItemList[i] then
			--		local itemlist = ""
			--		for k , v in pairs(MountsDyeingUI.ColorItemList[i]) do
			--			itemlist = itemlist..k.."_"..v.."_"
			--		end
			--		CL.SendNotify(NOTIFY.SubmitForm,"FormMount","MountDyeing_Item",MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Id,i,itemlist,0)
			--	end
			--end
		end
	else
		CL.SendNotify(NOTIFY.SubmitForm,"FormMount","MountDyeing_Plan",MountsDyeingUI.MyMountsList[MountsDyeingUI.CurMountsIndex].Id,MountsDyeingUI.SchemeIndex-1)
	end
end

function MountsDyeingUI.tablecount(datatable)
	local count = 0
	if type(datatable) == "table" then
		for i,v in pairs(datatable) do
			count = count+1
		end
	end
	return count
end

function MountsDyeingUI.OnRestoreBtnClick()
	MountsDyeingUI.Refresh()
end
