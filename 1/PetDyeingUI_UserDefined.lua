local PetDyeingUI_UserDefined = {
}
_G.PetDyeingUI_UserDefined = PetDyeingUI_UserDefined
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

function PetDyeingUI_UserDefined.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("PetDyeingUI_UserDefined", "PetDyeingUI_UserDefined", 0, 0);
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "宠物染色","PetDyeingUI_UserDefined", "OnCloseBtnClick", _gt)
	_gt.BindName(panelBg,"PetDyeingPage")
	GUI.SetVisible(panel, false)

	
	-- CDebug.LogError(inspect(GlobalProcessing.PetColorPlan))
	
	-- CDebug.LogError(inspect(GlobalProcessing.PetColorPart))
		
	PetDyeingUI_UserDefined.CreateBase(panelBg)
end

function PetDyeingUI_UserDefined.OnShow(parameter)
	--判断是否有数据
	if not GlobalProcessing.PetColorItem or not GlobalProcessing.PetColorPlan or not GlobalProcessing.PetColorPart then
		CL.SendNotify(NOTIFY.ShowBBMsg,"暂时未存在数据")
		return
	end
	
	--第一次对染色方案数据进行统一处理（增加一个方案名为自定义 放在第一个）
	for k ,v in pairs(GlobalProcessing.PetColorPlan) do
		if v[1].Name ~= "自定义" then
			local temp = {Name = "自定义",
				Part1 = {},
				Part2 = {},
			}
			table.insert(v,1,temp)
		end
	end
	
	--获得我的坐骑相关列表
	PetDyeingUI_UserDefined.MyPetList = {}
	PetDyeingUI_UserDefined.HavePetCount = 0
	--默认选择显示第一个坐骑
	PetDyeingUI_UserDefined.CurPetIndex = 1
	
	local petList = LD.GetPetGuids()
	if petList.Count > 0 then
		PetDyeingUI_UserDefined.HavePetCount = petList.Count
		local tb = {}
		local temp = {}
		for i=0, 4 do
			if UIDefine.NowLineupList[i] ~= "-1" then
				table.insert(tb,UIDefine.NowLineupList[i])
				temp[UIDefine.NowLineupList[i]] = "true"
			end
		end
		
		for i = 0 ,petList.Count -1 do
			if not temp[tostring(petList[i])] then
				table.insert(tb,petList[i])
			end
		end
		
		for i =1 , #tb do
			local id  = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,tb[i])
			local petDB =DB.GetOncePetByKey1(id)
			if GlobalProcessing.PetColorPlan[tonumber(petDB.Model)] then
				table.insert(PetDyeingUI_UserDefined.MyPetList,{Guid = tb[i] ,Id = petDB.Id, Model = tonumber(petDB.Model)})
				--优先显示当前展示的宠物
				if LD.GetPetState(PetState.Show,tb[i]) then
					PetDyeingUI_UserDefined.CurPetIndex = #PetDyeingUI_UserDefined.MyPetList
				end
			else
				PetDyeingUI_UserDefined.HavePetCount = PetDyeingUI_UserDefined.HavePetCount - 1
			end
		end
	end
	
	--如果没有坐骑，关闭窗口
	if PetDyeingUI_UserDefined.HavePetCount == 0 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"暂未拥有可染色宠物")
		return
	end 		
	
	--对服务器染色道具列表排序
	if GlobalProcessing.PetColorItem and #GlobalProcessing.PetColorItem > 0 then
		local temp = {}
		for i = 1 , #GlobalProcessing.PetColorItem do
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.PetColorItem[i])
			table.insert(temp,{Id = itemDB.Id , KeyName =GlobalProcessing.PetColorItem[i]})
		end	
		table.sort(temp,function(a,b)return (tonumber(a.Id) <  tonumber(b.Id)) end)
		GlobalProcessing.PetColorItem = {}
		for i = 1 , #temp do
			table.insert(GlobalProcessing.PetColorItem,temp[i].KeyName)
		end
	end	
	--获得染色道具列表
	PetDyeingUI_UserDefined.InitPetColorItemList()
	
	--注册道具监听事件
	PetDyeingUI_UserDefined.Register()
	
	
	local wnd = GUI.GetWnd("PetDyeingUI_UserDefined")
	if wnd then
		GUI.SetVisible(wnd, true)
	end

	-- PetDyeingUI_UserDefined.Refresh()
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetColor","GetColorData",PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Guid)
end


function PetDyeingUI_UserDefined.Register()
    CL.RegisterMessage(GM.AddNewItem, "PetDyeingUI_UserDefined", "OnItemUpdate")
    CL.RegisterMessage(GM.UpdateItem, "PetDyeingUI_UserDefined", "OnItemUpdate")
    CL.RegisterMessage(GM.RemoveItem, "PetDyeingUI_UserDefined", "OnItemUpdate")
end

--当物品变化
function PetDyeingUI_UserDefined.OnItemUpdate(item_guid,item_id)
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
	if GlobalProcessing.PetColorItem then
		for k , v in pairs(GlobalProcessing.PetColorItem) do
			if itemDB.KeyName == v then
				PetDyeingUI_UserDefined.InitPetColorItemList()
				break
			end
		end
	end

	local Scroll = _gt.GetUI("ColorItemScroll")
	if Scroll and GUI.GetVisible(Scroll) then
		PetDyeingUI_UserDefined.RefreshColorItem()
		--刷新消耗
		if PetDyeingUI_UserDefined.ConsumeItemList and PetDyeingUI_UserDefined.ConsumeItemList[itemDB.KeyName] then
			PetDyeingUI_UserDefined.RefreshConsumeItem()
		end
	end
end

function PetDyeingUI_UserDefined.InitPetColorItemList()
	PetDyeingUI_UserDefined.PetColorItem = {} 
	if GlobalProcessing.PetColorItem then
		local temp_tb = {}
		for i = 1 ,#GlobalProcessing.PetColorItem do
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.PetColorItem[i])
			
			local count = LD.GetItemCountById(itemDB.Id) 
			
			if count >= 1 then
				table.insert(PetDyeingUI_UserDefined.PetColorItem,{keyname = GlobalProcessing.PetColorItem[i], num = count})					
			else
				table.insert(temp_tb,{keyname = GlobalProcessing.PetColorItem[i], num = 0 })
			end			
		end
		
		if #temp_tb > 0 then
			for i = 1 ,#temp_tb do
				table.insert(PetDyeingUI_UserDefined.PetColorItem,temp_tb[i])
			end
		end
	end
end

function PetDyeingUI_UserDefined.Refresh()
	--重置参数
	
	--默认显示第一个道具
	PetDyeingUI_UserDefined.CurColorItemIndex = 1
	
	--默认选择第一个部位
	PetDyeingUI_UserDefined.PetPartIndex = 1
	
	--清空当前已选择道具
	PetDyeingUI_UserDefined.ColorItemList = {}
	
	--默认显示不选择模板
	PetDyeingUI_UserDefined.SchemeIndex = 1
	
	--消耗物品列表
	PetDyeingUI_UserDefined.ConsumeItemList = {}
	
	--清空预览
	PetDyeingUI_UserDefined.ColorPreList1 = {}
	PetDyeingUI_UserDefined.ColorPreList2 = {}
	PetDyeingUI_UserDefined.ColorPreList3 = {}
	PetDyeingUI_UserDefined.ColorPreList4 = {}
	PetDyeingUI_UserDefined.ColorPreList5 = {}
	
	
	--宠物自身染色特殊处理
	PetDyeingUI_UserDefined.InitPetBaseColorData()
	
	--刷新模型
	PetDyeingUI_UserDefined.RefreshModel()
	
	--刷新染色消耗
	PetDyeingUI_UserDefined.RefreshConsumeItem()
	
	--刷新部位相关
	PetDyeingUI_UserDefined.RefreshPart()
	
	--刷新染色道具
	PetDyeingUI_UserDefined.RefreshColorItem()
	
	--刷新模板选择
	PetDyeingUI_UserDefined.RefreshSchemeItem()
end

function PetDyeingUI_UserDefined.InitPetBaseColorData()
	local petId = PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Id
	local petDB = DB.GetOncePetByKey1(petId)
	if tostring(petDB.ColorId) ~= "0" then
		local appearId = 0
        local allIds = DB.GetColorAllKeys()
        for i = 0, allIds.Count - 1 do
            local config = DB.GetColor(allIds[i])
            if config ~= nil and petDB.ColorId == config.Id and config.Table == 2 then
				appearId = config.AppearId
				break
            end
        end
		if appearId ~= 0 then
			local tb = SETTING.GetAppearancecolor(appearId)
			for i =1, 5 do
				if tb["IsFillPart"..i] and tostring(tb["IsFillPart"..i]) ~= "False" and not PetDyeingUI_UserDefined.ColorList["IsFillPart"..i] then
					PetDyeingUI_UserDefined.ColorList["IsFillPart"..i] = tb["IsFillPart"..i]
					PetDyeingUI_UserDefined.ColorList["IsAddColorFirst"..i] = tb["IsAddColorFirst"..i]
					PetDyeingUI_UserDefined.ColorList["ColorAddFirst"..i] = tb["ColorAddFirst"..i]
					PetDyeingUI_UserDefined.ColorList["HOffset"..i] = tb["HOffset"..i]
					PetDyeingUI_UserDefined.ColorList["SOffset"..i] = tb["SOffset"..i]
					PetDyeingUI_UserDefined.ColorList["VOffset"..i] = tb["VOffset"..i]
				end			
			end
		end
	end
end


--模型刷新
function PetDyeingUI_UserDefined.RefreshModel()	
	local Model = _gt.GetUI("PetModel")
	GUI.RawImageChildSetModelID(Model, PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Model)
	GUI.ReplaceWeapon(Model, 0, eRoleMovement.STAND_W1, 0)
	GUI.RawImageChildSetModleRotation(Model, Vector3.New(0, -45, 0))
	if PetDyeingUI_UserDefined.ColorList and next(PetDyeingUI_UserDefined.ColorList) then
		GUI.RefreshDyeSkinJson(Model, jsonUtil.encode(PetDyeingUI_UserDefined.ColorList), "")
	else
		GUI.RefreshDyeSkinJson(Model, "", "")
	end
end

function PetDyeingUI_UserDefined.RefreshPart()
	PetDyeingUI_UserDefined.CurMountsPartData = {}
	PetDyeingUI_UserDefined.CurMountsPartData = GlobalProcessing.PetColorPart[PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Model]
	
	local PartItemScroll = _gt.GetUI("PartItemScroll")	
	GUI.LoopScrollRectSetTotalCount(PartItemScroll, #PetDyeingUI_UserDefined.CurMountsPartData) 
	GUI.LoopScrollRectRefreshCells(PartItemScroll)

end

function PetDyeingUI_UserDefined.RefreshConsumeItem()
	-- PetDyeingUI_UserDefined.ConsumeItemList = {}
	--得到数量
	local num = 0
	for k , v in pairs(PetDyeingUI_UserDefined.ConsumeItemList) do
		num = num +1
	end
	
	local ConsumeItemScroll = _gt.GetUI("ConsumeItemScroll")
	GUI.LoopScrollRectSetTotalCount(ConsumeItemScroll,num)
	GUI.LoopScrollRectRefreshCells(ConsumeItemScroll)
end

function PetDyeingUI_UserDefined.RefreshColorItem()
	local ColorItemScroll = _gt.GetUI("ColorItemScroll")
	GUI.LoopScrollRectSetTotalCount(ColorItemScroll, math.max(#GlobalProcessing.PetColorItem,15)) 
	GUI.LoopScrollRectRefreshCells(ColorItemScroll)	
	
	PetDyeingUI_UserDefined.RefreshColorItemInfo()
end


function PetDyeingUI_UserDefined.RefreshSchemeItem()
	local Scheme = _gt.GetUI("Scheme")
	GUI.ButtonSetText(Scheme,GlobalProcessing.PetColorPlan[PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Model][PetDyeingUI_UserDefined.SchemeIndex].Name)
	
	-- local SchemeItemScroll = _gt.GetUI("SchemeItemScroll")
	-- GUI.LoopScrollRectSetTotalCount(SchemeItemScroll, #GlobalProcessing.PetColorPlan) 
	-- GUI.LoopScrollRectRefreshCells(SchemeItemScroll)
	
end


function PetDyeingUI_UserDefined.CreateBase(panelBg)	
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
	GUI.RegisterUIEvent(model, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnModelClick")

	
	local PetModel = GUI.RawImageChildCreate(model, false, "PetModel", "", 0, 0)
	_gt.BindName(PetModel, "PetModel")
	GUI.BindPrefabWithChild(model, GUI.GetGuid(PetModel))
	GUI.RegisterUIEvent(PetModel, ULE.AnimationCallBack, "PetDyeingUI_UserDefined", "OnAnimationCallBack")
	
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
	"PetDyeingUI_UserDefined", "CreateConsumeItem", "PetDyeingUI_UserDefined", "RefreshConsumeItemScroll", 0, true, Vector2.New(80, 81), 1, UIAroundPivot.Left, UIAnchor.Left)
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
    GUI.RegisterUIEvent(DyeingBtn, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnDyeingBtnClick")
	
    local RestoreBtn =GUI.ButtonCreate(panelBg,"RestoreBtn","1800602030", -436,-42,Transition.ColorTint,"还 原",150,48,false)
	SetAnchorAndPivot(RestoreBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
	GUI.ButtonSetTextFontSize(RestoreBtn, 26)
    GUI.ButtonSetTextColor(RestoreBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(RestoreBtn, true)
    GUI.SetOutLine_Color(RestoreBtn, colorOutline)
    GUI.SetOutLine_Distance(RestoreBtn, 1)
	GUI.RegisterUIEvent(RestoreBtn, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnRestoreBtnClick")	
	
	--切换按钮
    local switchBtn = GUI.ButtonCreate( panelBg, "switchBtn", "1800600100", -460, -240, Transition.None,"",110,40,false)
    SetAnchorAndPivot(switchBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(switchBtn, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnSwitchBtnClick")

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
	"PetDyeingUI_UserDefined", "CreatePartItem", "PetDyeingUI_UserDefined", "RefreshPartItemScroll", 0, true, Vector2.New(30, 30), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
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
	GUI.RegisterUIEvent(LeftBtn, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnLeftBtnClick")
	GUI.SetEulerAngles(LeftBtn, Vector3.New(0, 0, 90))
	
	local RightBtn = GUI.ButtonCreate(Text,"RightBtn","1800202470",300,0,Transition.ColorTint,"",40,34,false)
	SetAnchorAndPivot(RightBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(RightBtn, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnRightBtnClick")
	GUI.SetEulerAngles(RightBtn, Vector3.New(0, 0, -90))
	--1800800030
    local Scheme = GUI.ButtonCreate(Text,"Scheme","1800800030", 200,0,Transition.None," ",120,40,false)
	-- GUI.RegisterUIEvent(Scheme, UCE.PointerClick , "PetDyeingUI_UserDefined", "OnChooseSchemeClick")
	SetAnchorAndPivot(Scheme, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ButtonSetTextFontSize(Scheme, 22)
    GUI.ButtonSetTextColor(Scheme, colorDark)
	_gt.BindName(Scheme,"Scheme")
	
	-- local SchemeItemScroll = GUI.LoopScrollRectCreate(Text, "SchemeItemScroll", 210, -1, 270, 45,
	-- "PetDyeingUI_UserDefined", "CreateSchemeItem", "PetDyeingUI_UserDefined", "RefreshSchemeItemScroll", 0, true, Vector2.New(120, 40), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
	-- UILayout.SetSameAnchorAndPivot(SchemeItemScroll, UILayout.Center)
	-- _gt.BindName(SchemeItemScroll,"SchemeItemScroll")
	-- GUI.ScrollRectSetChildSpacing(SchemeItemScroll, Vector2.New(20, 10))
	
	
    -- local Bg = GUI.ImageCreate(panelBg, "Bg", "1800400010", 265, 135, false,510,310);
    -- SetAnchorAndPivot(Bg, UIAnchor.Center, UIAroundPivot.Center)
	
    local Bg2 = GUI.ImageCreate( Bg, "Bg2", "1800001150", -122, 100, false, 240, 270)
    SetAnchorAndPivot(Bg2, UIAnchor.Center, UIAroundPivot.Center)
	
	local ColorItemScroll = GUI.LoopScrollRectCreate(Bg2, "ColorItemScroll", 0, 0, 210, 235,
	"PetDyeingUI_UserDefined", "CreateColorItem", "PetDyeingUI_UserDefined", "RefreshColorItemScroll", 0, false, Vector2.New(67, 67), 3, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(ColorItemScroll, UILayout.Center)
	_gt.BindName(ColorItemScroll, "ColorItemScroll")
	GUI.ScrollRectSetChildSpacing(ColorItemScroll, Vector2.New(3, 4))		
	
    local Bg3 = GUI.ImageCreate( Bg, "Bg3", "1800001150", 122, 100, false, 240, 270)
    SetAnchorAndPivot(Bg3, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(Bg3,"ColorItemDes")

	local Item = GUI.ItemCtrlCreate(Bg3, "Item", "1800400050", -60, -75, 76, 76)
	SetAnchorAndPivot(Item, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnColorItemDesTips")

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
	GUI.RegisterUIEvent(AddBtn, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnAddBtnClick")
	-- GUI.RegisterUIEvent(AddBtn, UCE.PointerDown, "PetDyeingUI_UserDefined", "OnAddBtnDown")
	-- GUI.RegisterUIEvent(AddBtn, UCE.PointerUp, "PetDyeingUI_UserDefined", "OnAddBtnUp")
	
	local CutDownBtn = GUI.ButtonCreate(Bg3,"CutDownBtn","1800402140",-80,100,Transition.ColorTint,"",46,46,false)
	SetAnchorAndPivot(CutDownBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(CutDownBtn, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnCutDownBtnClick")
	-- GUI.RegisterUIEvent(CutDownBtn, UCE.PointerDown, "PetDyeingUI_UserDefined", "OnCutDownBtnDown")
	-- GUI.RegisterUIEvent(CutDownBtn, UCE.PointerUp, "PetDyeingUI_UserDefined", "OnCutDownBtnUp")

	--输入框
    local Input = GUI.EditCreate(Bg3, "Input","1800001040", "", 0, 100, Transition.ColorTint, "system", 100, 50, 25, 10)
    GUI.EditSetBNumber(Input,true)
    GUI.EditSetProp(Input, 22, 50, TextAnchor.MiddleCenter, TextAnchor.MiddleCenter)
    GUI.EditSetMultiLineEdit(Input, LineType.SingleLine)
	GUI.EditSetMaxCharNum(Input, 4)
    GUI.EditSetTextColor(Input, UIDefine.BrownColor)
	GUI.RegisterUIEvent(Input, UCE.EndEdit, "PetDyeingUI_UserDefined", "OnInputNumChange")
    _gt.BindName(Input,"Input")	
end

function PetDyeingUI_UserDefined.OnColorItemDesTips(guid)
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
		GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetDyeingUI_UserDefined","OnClickColorItemWayBtn")
		GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
	end
end

function PetDyeingUI_UserDefined.OnClickColorItemWayBtn()
	local tips = _gt.GetUI("ColorItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

function PetDyeingUI_UserDefined.OnModelClick()
	local PetModel = _gt.GetUI("PetModel")
	math.randomseed(os.time())
	local index = math.random(2)
	local movements = { eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1 }
	GUI.ReplaceWeapon(PetModel, 0, movements[index], 0)
end

function PetDyeingUI_UserDefined.OnAnimationCallBack(guid,action)
	local PetModel = _gt.GetUI("PetModel")
	
	if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
		return
	end
	GUI.ReplaceWeapon(PetModel, 0, eRoleMovement.ATTSTAND_W1, 0)
end


--消耗道具
function PetDyeingUI_UserDefined.CreateConsumeItem()
	local ConsumeItemScroll = _gt.GetUI("ConsumeItemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(ConsumeItemScroll)
	local Item = ItemIcon.Create(ConsumeItemScroll, "ConsumeItem"..curCount, 0, 0)
	UILayout.SetSameAnchorAndPivot(Item,UILayout.Center)
	-- GUI.RegisterUIEvent(petItem, UCE.PointerClick, "MountUI", "OpenSelectedControlPetWnd")
	
	return Item
end

function PetDyeingUI_UserDefined.RefreshConsumeItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	index = index +1 
	local tb = {}
	for k ,v in pairs(PetDyeingUI_UserDefined.ConsumeItemList) do
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
function PetDyeingUI_UserDefined.CreateSchemeItem()
	local SchemeItemScroll = _gt.GetUI("SchemeItemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(SchemeItemScroll)
	
    local Scheme =GUI.ButtonCreate(SchemeItemScroll,"Scheme","1800800030", 0,0,Transition.ColorTint,GlobalProcessing.PetColorPlan[PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Model][curCount+1].Name,0,0,false)
	GUI.RegisterUIEvent(Scheme, UCE.PointerClick , "PetDyeingUI_UserDefined", "OnChooseSchemeClick")
	SetAnchorAndPivot(Scheme, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ButtonSetTextFontSize(Scheme, 22)
    GUI.ButtonSetTextColor(Scheme, Color.New(169/255, 127/255, 85/255, 255/255))
	
	return Scheme
end

function PetDyeingUI_UserDefined.RefreshSchemeItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	
	index = index + 1
	
	GUI.ButtonSetText(Item,GlobalProcessing.PetColorPlan[PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Model][index].Name)
	GUI.SetData(Item,"Index",index)
	if PetDyeingUI_UserDefined.SchemeIndex and index == PetDyeingUI_UserDefined.SchemeIndex then
		GUI.ButtonSetImageID(Item,"1800800040")
		GUI.ButtonSetTextColor(Item, colorDark)
	else
		GUI.ButtonSetImageID(Item,"1800800030")
		GUI.ButtonSetTextColor(Item, Color.New(169/255, 127/255, 85/255, 255/255))
	end
end

--当选择染色方案
function PetDyeingUI_UserDefined.OnChooseSchemeClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"Index"))
	if PetDyeingUI_UserDefined.SchemeIndex and index == PetDyeingUI_UserDefined.SchemeIndex then
		return
	end
	PetDyeingUI_UserDefined.SchemeIndex = index
	
	local SchemeItemScroll = _gt.GetUI("SchemeItemScroll")
	GUI.LoopScrollRectRefreshCells(SchemeItemScroll)


	PetDyeingUI_UserDefined.SelectedColorPlan(index)
	
end

function PetDyeingUI_UserDefined.OnLeftBtnClick(guid)
	local count = #GlobalProcessing.PetColorPlan[PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Model]
	if PetDyeingUI_UserDefined.SchemeIndex > 1 then
		PetDyeingUI_UserDefined.SchemeIndex = PetDyeingUI_UserDefined.SchemeIndex - 1
	else
		PetDyeingUI_UserDefined.SchemeIndex = count 
	end
	
	PetDyeingUI_UserDefined.RefreshSchemeItem()
	
	PetDyeingUI_UserDefined.SelectedColorPlan()
end

function PetDyeingUI_UserDefined.OnRightBtnClick(guid)
	local count = #GlobalProcessing.PetColorPlan[PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Model]
	if PetDyeingUI_UserDefined.SchemeIndex < count then
		PetDyeingUI_UserDefined.SchemeIndex = PetDyeingUI_UserDefined.SchemeIndex + 1
	else
		PetDyeingUI_UserDefined.SchemeIndex = 1 
	end
	
	PetDyeingUI_UserDefined.RefreshSchemeItem()
	
	PetDyeingUI_UserDefined.SelectedColorPlan()
end

function PetDyeingUI_UserDefined.OnCloseBtnClick(guid)
	GUI.CloseWnd("PetDyeingUI_UserDefined")
end


--点击切换坐骑
function PetDyeingUI_UserDefined.OnSwitchBtnClick()
	--数据处理
	local Page = _gt.GetUI("PetDyeingPage")
    local Bg = GUI.ImageCreate(Page, "Bg", "1800400010", 80, 110, false, 335, 510)
    UILayout.SetSameAnchorAndPivot(Bg, UILayout.TopLeft)
    GUI.SetIsRaycastTarget(Bg, true)
    Bg:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRemoveWhenClick(Bg, true)
    local titelBg = GUI.ImageCreate(Bg, "titelBg", "1800700250", 4, 4,false,328,36)
    UILayout.SetSameAnchorAndPivot(titelBg, UILayout.TopLeft)
    local titel = GUI.CreateStatic(titelBg, "titel", "可染色宠物",20, 0, 200, 50,"system", true)
    UILayout.SetSameAnchorAndPivot(titel, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(titel, UIDefine.FontSizeS, UIDefine.BrownColor)
	
	local PetScroll = GUI.LoopScrollRectCreate(Bg, "PetScroll", 0, 15, 330, 450,
	"PetDyeingUI_UserDefined", "CreatePetItem", "PetDyeingUI_UserDefined", "RefreshPetScroll", 0, false, Vector2.New(325, 100), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(PetScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(PetScroll, Vector2.New(1, 1))
	_gt.BindName(PetScroll, "PetScroll")		
	
	GUI.LoopScrollRectSetTotalCount(PetScroll, PetDyeingUI_UserDefined.HavePetCount or 0) 
	GUI.LoopScrollRectRefreshCells(PetScroll)	
end


function PetDyeingUI_UserDefined.CreatePetItem()
    local PetScroll = _gt.GetUI("PetScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(PetScroll)
	local petItem = PetItem.Create(PetScroll, "petItem"..curCount, 0, 0)
    GUI.RegisterUIEvent(petItem, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnMountsItemClick")
	
	return petItem

end

function PetDyeingUI_UserDefined.RefreshPetScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
	local petItem = GUI.GetByGuid(guid)
	index = index + 1
	local tb = PetDyeingUI_UserDefined.MyPetList[index]
	GUI.SetData(petItem,"Index",index)
	if index == PetDyeingUI_UserDefined.CurPetIndex then
		GUI.CheckBoxExSetCheck(petItem, true)
	else
		GUI.CheckBoxExSetCheck(petItem, false)
	end
	PetItem.BindPetGuid(petItem, tb.Guid, pet_container_type.pet_container_panel,nil)
end



function PetDyeingUI_UserDefined.OnMountsItemClick(guid)
	local Index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"Index"))
	if Index then
		PetDyeingUI_UserDefined.CurPetIndex = Index
		CL.SendNotify(NOTIFY.SubmitForm,"FormPetColor","GetColorData",PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Guid)
	end
end

--染色部位相关
function PetDyeingUI_UserDefined.CreatePartItem()
    local PartItemScroll = _gt.GetUI("PartItemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(PartItemScroll)
    local PartItem = GUI.ButtonCreate(PartItemScroll, "PartItem" .. tostring(curCount), "1800208210", 0, 0, Transition.ColorTint, "", 330, 100, false)
    GUI.RegisterUIEvent(PartItem, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnPartItemClick")
	
    local Text = GUI.CreateStatic(PartItem, "Text", "",40, 2, 200, 50,"system", true)
    UILayout.SetSameAnchorAndPivot(Text, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(Text, UIDefine.FontSizeM, UIDefine.BrownColor)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleLeft)


	
	return PartItem

end

function PetDyeingUI_UserDefined.RefreshPartItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
	local item = GUI.GetByGuid(guid)
	local text = GUI.GetChild(item,"Text")
	
	index = index + 1

	GUI.StaticSetText(text,PetDyeingUI_UserDefined.CurMountsPartData[index])
	GUI.SetData(item,"Index",index)
	
	if PetDyeingUI_UserDefined.PetPartIndex and PetDyeingUI_UserDefined.PetPartIndex == index then
		GUI.ButtonSetImageID(item,"1800208211")
	else
		GUI.ButtonSetImageID(item,"1800208210")
	end
	
end

function PetDyeingUI_UserDefined.OnPartItemClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"Index"))
	if PetDyeingUI_UserDefined.PetPartIndex ~= index then
		PetDyeingUI_UserDefined.PetPartIndex = index
		local PartItemScroll = _gt.GetUI("PartItemScroll")	
		GUI.LoopScrollRectRefreshCells(PartItemScroll)
	end
	
	--刷新染色道具
	-- PetDyeingUI_UserDefined.RefreshColorItem()
	local ColorItemScroll = _gt.GetUI("ColorItemScroll")
	-- GUI.LoopScrollRectSetTotalCount(ColorItemScroll, math.max(#GlobalProcessing.PetColorItem,15)) 
	GUI.LoopScrollRectRefreshCells(ColorItemScroll)	
end



--染色道具
function PetDyeingUI_UserDefined.CreateColorItem()
	local ColorItemScroll = _gt.GetUI("ColorItemScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(ColorItemScroll)
	local ColorItem = GUI.ItemCtrlCreate(ColorItemScroll, "ColorItem" .. curCount, "1800400050", 0, 0, 89, 89)
	GUI.RegisterUIEvent(ColorItem, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnColorItemClick")
	local select_ = GUI.ImageCreate(ColorItem, "select_", "1800600160", 0,-1, false, 73, 73)
    SetAnchorAndPivot(select_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(select_,false)
	local DecreaseBtn = GUI.ButtonCreate( ColorItem,"DecreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
	GUI.RegisterUIEvent(DecreaseBtn, UCE.PointerClick, "PetDyeingUI_UserDefined", "OnDecreaseBtnClick")	
	SetAnchorAndPivot(DecreaseBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)	
	GUI.SetVisible(DecreaseBtn,false)
	
	return ColorItem
end

function PetDyeingUI_UserDefined.RefreshColorItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid);
	local index = index+1
	local select_ = GUI.GetChild(Item,"select_")
	local DecreaseBtn = GUI.GetChild(Item,"DecreaseBtn")
	if index <= #PetDyeingUI_UserDefined.PetColorItem then
		local tb = PetDyeingUI_UserDefined.PetColorItem[index]
		local itemDB = DB.GetOnceItemByKey2(tb.keyname)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(itemDB.Icon))
		GUI.ItemCtrlSetElementRect(Item, eItemIconElement.Icon, 0, 0,60,61)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,tb.num)
		-- GUI.ItemCtrlSetIconGray(Item,tb.num == 0)
		-- GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,tb.bind == 1 and "1800707120" or nil)
		GUI.SetData(Item,"index",index)
		-- 是否选择
		if PetDyeingUI_UserDefined.CurColorItemIndex and index == PetDyeingUI_UserDefined.CurColorItemIndex then
			GUI.SetVisible(select_,true)
			PetDyeingUI_UserDefined.CurColorItemGuid = guid
			PetDyeingUI_UserDefined.RefreshInputText(itemDB.KeyName)
		else
			GUI.SetVisible(select_,false)
		end
		
		local NumTxt = GUI.ItemCtrlGetElement(Item,eItemIconElement.RightBottomNum)
		if PetDyeingUI_UserDefined.ColorItemList and PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex] and PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][tb.keyname] and PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][tb.keyname] > 0  then
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][tb.keyname].."/"..tb.num)
			if tb.num >= PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][tb.keyname] then
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


function PetDyeingUI_UserDefined.OnColorItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local index = tonumber(GUI.GetData(item,"index"))
	if index then
		local select_  = GUI.GetChild(item,"select_")
		GUI.SetVisible(select_,true)
		if PetDyeingUI_UserDefined.CurColorItemGuid then
			if PetDyeingUI_UserDefined.CurColorItemGuid ~= guid then
				local select_last  = GUI.GetChild(GUI.GetByGuid(PetDyeingUI_UserDefined.CurColorItemGuid),"select_")
				GUI.SetVisible(select_last,false)	
			else
				PetDyeingUI_UserDefined.CurColorItemIndex = index
				PetDyeingUI_UserDefined.OnAddBtnClick()
			end
		end
		PetDyeingUI_UserDefined.CurColorItemGuid = guid
		PetDyeingUI_UserDefined.CurColorItemIndex = index
		--刷新道具信息
		PetDyeingUI_UserDefined.RefreshColorItemInfo()
	end
end


function PetDyeingUI_UserDefined.RefreshColorItemInfo()
	local tb = PetDyeingUI_UserDefined.PetColorItem[PetDyeingUI_UserDefined.CurColorItemIndex]
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
	
	
	PetDyeingUI_UserDefined.RefreshInputText(tb.keyname)
	--按钮
	--如果数量已满
	-- local num1 = tb.num --拥有的数量
	-- local num2 = --当前选中的数量
	-- if tb.num > 
	
	
	-- else
	
	
	-- end
	-- PetDyeingUI_UserDefined.RefreshInputText(itemDB.KeyName)
end

function  PetDyeingUI_UserDefined.RefreshInputText(keyname)

	local Input = _gt.GetUI("Input")
	if PetDyeingUI_UserDefined.ColorItemList and PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex] and PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][keyname] then
		GUI.EditSetTextM(Input,PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][keyname])
	else
		GUI.EditSetTextM(Input,0)
	end

end




function PetDyeingUI_UserDefined.OnInputNumChange()
	local Edit = _gt.GetUI("Input")
	local InputNum = tonumber(GUI.EditGetTextM(Edit)) or 0
	local IsAdd = true
	local num = 0
	
	if InputNum < 0 then
		GUI.EditSetTextM(Edit,0)
		return
	end
	
	local tb = PetDyeingUI_UserDefined.PetColorItem[PetDyeingUI_UserDefined.CurColorItemIndex]
	if PetDyeingUI_UserDefined.ColorItemList and  PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex]  and PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][tb.keyname] then
		local num0 =  PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][tb.keyname]
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
	
	PetDyeingUI_UserDefined.CustomDyeingScheme(tb.keyname,IsAdd,num,tb.num)
end
--添加道具数量
function PetDyeingUI_UserDefined.OnAddBtnClick()
	local tb = PetDyeingUI_UserDefined.PetColorItem[PetDyeingUI_UserDefined.CurColorItemIndex]
	PetDyeingUI_UserDefined.CustomDyeingScheme(tb.keyname,true,1,tb.num)
end

--减少道具数量
function PetDyeingUI_UserDefined.OnCutDownBtnClick()
	local tb = PetDyeingUI_UserDefined.PetColorItem[PetDyeingUI_UserDefined.CurColorItemIndex]
	PetDyeingUI_UserDefined.CustomDyeingScheme(tb.keyname,false,1,tb.num)
end

function PetDyeingUI_UserDefined.OnAddBtnDown()
	

end

function PetDyeingUI_UserDefined.OnDecreaseBtnClick(guid)
	local btn = GUI.GetByGuid(guid)
	local num = tonumber(GUI.GetData(btn,"limit"))
	local keyname = GUI.GetData(btn,"keyname")
	PetDyeingUI_UserDefined.CustomDyeingScheme(keyname,false,1,num)
end

--设置选中染色道具的数量(道具的keyname,增加true,减少false,改变的数量,拥有的数量)
function PetDyeingUI_UserDefined.CustomDyeingScheme(item_keyname,isAdd,num,count)
	--判断当前是否为模板选择状态
	if PetDyeingUI_UserDefined.SchemeIndex ~=1 then
		PetDyeingUI_UserDefined.ColorItemList = {}
		PetDyeingUI_UserDefined.ColorPreList1 = {}
		PetDyeingUI_UserDefined.ColorPreList2 = {}
		PetDyeingUI_UserDefined.ColorPreList3 = {}
		PetDyeingUI_UserDefined.ColorPreList4 = {}
		PetDyeingUI_UserDefined.ColorPreList5 = {}
		PetDyeingUI_UserDefined.ConsumeItemList = {}
		PetDyeingUI_UserDefined.SchemeIndex = 1
		PetDyeingUI_UserDefined.RefreshSchemeItem()
		CL.SendNotify(NOTIFY.ShowBBMsg,"非自定义染色状态下无法调整染料道具数量！")
	end

	if not PetDyeingUI_UserDefined.ColorItemList then
		PetDyeingUI_UserDefined.ColorItemList = {}
	end
	
	--当前部位为 PetDyeingUI_UserDefined.PetPartIndex
	if not PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex] then
		PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex] = {}
	end
	
	local count_ = 0
	--当前所有部位已选中的数量
	if PetDyeingUI_UserDefined.ConsumeItemList and PetDyeingUI_UserDefined.ConsumeItemList[item_keyname] then
		count_ = PetDyeingUI_UserDefined.ConsumeItemList[item_keyname].num
	end
	if PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][item_keyname] then
		local num_ = PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][item_keyname]
		if isAdd then
			PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][item_keyname] = num_ + num
			-- if num_ + num > count - count_ +num_ then
				-- CL.SendNotify(NOTIFY.ShowBBMsg, "拥有数量不足，请调整其它染色部位该道具的预览添加数量")
			-- end
		else
			PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][item_keyname] = math.max(num_ - num,0)
			--当减到0时
			if num_ - num <= 0 then
				PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][item_keyname] = nil
				--若表里没有其他物品，则还原该部位颜色
				-- if not next(PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex]) then
					
				-- end
			end
		end		
	else
		if isAdd then
			-- if count ~= 0 then
				PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex][item_keyname] = num
				-- if num > count-count_ then
					-- CL.SendNotify(NOTIFY.ShowBBMsg, "拥有数量不足，请调整其它染色部位该道具的预览添加数量")
				-- end
			-- end
		end
	end
	
	--得到表以后
	PetDyeingUI_UserDefined.ConsumeItemList = {}
	local flag = 0
	for _ ,temp in pairs(PetDyeingUI_UserDefined.ColorItemList)do
		if temp and next(temp) then
			for k ,v in pairs(temp) do
				if PetDyeingUI_UserDefined.ConsumeItemList[k] then
					PetDyeingUI_UserDefined.ConsumeItemList[k].num = PetDyeingUI_UserDefined.ConsumeItemList[k].num + v
				else
					PetDyeingUI_UserDefined.ConsumeItemList[k] = {}
					PetDyeingUI_UserDefined.ConsumeItemList[k].num = v
					flag = flag +1
					PetDyeingUI_UserDefined.ConsumeItemList[k].index = flag
				end
			end
		end
	end
	
	--刷新消耗
	PetDyeingUI_UserDefined.RefreshConsumeItem()
	PetDyeingUI_UserDefined.RefreshColorItem()

	--发送预览请求
	local itemlist = ""
	for k,v in pairs(PetDyeingUI_UserDefined.ColorItemList[PetDyeingUI_UserDefined.PetPartIndex]) do
		itemlist = itemlist..k.."_"..v.."_"
	end
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetColor","Dyeing_Item",PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Guid,PetDyeingUI_UserDefined.PetPartIndex,itemlist,1)
end


function PetDyeingUI_UserDefined.SelectedColorPlan()
	local index = PetDyeingUI_UserDefined.SchemeIndex
	if index ==1 then
		PetDyeingUI_UserDefined.Refresh()
		return
	end
	PetDyeingUI_UserDefined.ColorItemList = {}
	for part_index = 1 ,#PetDyeingUI_UserDefined.CurMountsPartData do
		local tb = GlobalProcessing.PetColorPlan[PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Model][tonumber(index)]["Part"..part_index]
		
		PetDyeingUI_UserDefined.ColorItemList[part_index] = {}
		for i =1 , #tb do
			if type(tb[i]) == "string" then
				PetDyeingUI_UserDefined.ColorItemList[part_index][tb[i]] = tb[i+1]
			end
		end
		
		--得到表以后
		PetDyeingUI_UserDefined.ConsumeItemList = {}
		local flag = 0
		for _ ,temp in pairs(PetDyeingUI_UserDefined.ColorItemList)do
			if temp and next(temp) then
				for k ,v in pairs(temp) do
					if PetDyeingUI_UserDefined.ConsumeItemList[k] then
						PetDyeingUI_UserDefined.ConsumeItemList[k].num = PetDyeingUI_UserDefined.ConsumeItemList[k].num + v
					else
						PetDyeingUI_UserDefined.ConsumeItemList[k]= {}
						PetDyeingUI_UserDefined.ConsumeItemList[k].num = v
						flag = flag +1
						PetDyeingUI_UserDefined.ConsumeItemList[k].index =  flag
					end
				end
			end
		end
	end
	
	--刷新消耗
	PetDyeingUI_UserDefined.RefreshConsumeItem()
	
	PetDyeingUI_UserDefined.RefreshColorItem()
	--发送预览请求
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetColor","Pre_Plan",PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Guid,index-1)
end

function PetDyeingUI_UserDefined.RefreshIsPre()
	--刷新模型
	local Model = _gt.GetUI("PetModel")
	local temp = {}
	
			-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(PetDyeingUI_UserDefined.ColorList))
	-- CDebug.LogError(inspect(PetDyeingUI_UserDefined.ColorPreList1))
	-- CDebug.LogError(inspect(PetDyeingUI_UserDefined.ColorPreList2))
		
	--若只有一个
	-- if next(PetDyeingUI_UserDefined.ColorList) then
		--if next(PetDyeingUI_UserDefined.ColorPreList1) and next(PetDyeingUI_UserDefined.ColorPreList2) then
		--	if PetDyeingUI_UserDefined.ColorPreList1 then
		--		for k ,v in pairs(PetDyeingUI_UserDefined.ColorPreList1) do
		--			temp[k] = v
		--		end
		--	end
		--		
		--	if PetDyeingUI_UserDefined.ColorPreList2 then
		--		for k ,v in pairs(PetDyeingUI_UserDefined.ColorPreList2) do
		--			temp[k] = v
		--		end
		--	end
		--	
		--elseif next(PetDyeingUI_UserDefined.ColorPreList1) then
		--	-- for k , v in pairs(PetDyeingUI_UserDefined.ColorList) do
		--		-- if PetDyeingUI_UserDefined.ColorPreList1[k] then
		--			-- temp[k] = PetDyeingUI_UserDefined.ColorPreList1[k]
		--		-- else
		--			-- temp[k] = v
		--		-- end
		--	-- end
		--	for k , v in pairs(PetDyeingUI_UserDefined.ColorPreList1) do
		--		temp[k] = v
		--	end
		--elseif next(PetDyeingUI_UserDefined.ColorPreList2) then
		--	-- for k , v in pairs(PetDyeingUI_UserDefined.ColorList) do
		--		-- if PetDyeingUI_UserDefined.ColorPreList2[k] then
		--			-- temp[k] = PetDyeingUI_UserDefined.ColorPreList2[k]
		--		-- else
		--			-- temp[k] = v
		--		-- end
		--	-- end	
		--	for k , v in pairs(PetDyeingUI_UserDefined.ColorPreList2) do
		--		temp[k] = v
		--	end
		--	
		---- else
		--	-- temp = PetDyeingUI_UserDefined.ColorList
		--end

		for i = 1, 5 do
			if next(PetDyeingUI_UserDefined["ColorPreList"..i]) then
				for k, v in pairs(PetDyeingUI_UserDefined["ColorPreList"..i]) do
					temp[k] = v
				end
			end
		end
		
		if next(PetDyeingUI_UserDefined.ColorList) then
			for k ,v in pairs(PetDyeingUI_UserDefined.ColorList) do
				if tostring(temp[k]) == "nil" then
					temp[k] = v
				end				
			end
		end
	-- else
		-- if PetDyeingUI_UserDefined.ColorPreList1 then
			-- for k ,v in pairs(PetDyeingUI_UserDefined.ColorPreList1) do
				-- temp[k] = v
			-- end
		-- end
		-- if PetDyeingUI_UserDefined.ColorPreList2 then
			-- for k ,v in pairs(PetDyeingUI_UserDefined.ColorPreList2) do
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


function PetDyeingUI_UserDefined.OnDyeingBtnClick()
	if PetDyeingUI_UserDefined.SchemeIndex == 1 then
		if PetDyeingUI_UserDefined.tablecount(PetDyeingUI_UserDefined.ColorItemList) > 0 then
			for n, m in pairs(PetDyeingUI_UserDefined.ColorItemList) do
				if m then
					local itemlist = ""
					for k , v in pairs(m) do
						itemlist = itemlist..k.."_"..v.."_"
					end
					CL.SendNotify(NOTIFY.SubmitForm,"FormPetColor","Dyeing_Item",PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Guid,n,itemlist,0)
				end
			end
			--for i =1 , PetDyeingUI_UserDefined.tablecount(PetDyeingUI_UserDefined.ColorItemList) do
			--	if PetDyeingUI_UserDefined.ColorItemList[i] then
			--		local itemlist = ""
			--		for k , v in pairs(PetDyeingUI_UserDefined.ColorItemList[i]) do
			--			itemlist = itemlist..k.."_"..v.."_"
			--		end
			--		CL.SendNotify(NOTIFY.SubmitForm,"FormMount","MountDyeing_Item",PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex],i,itemlist,0)
			--	end
			--end
		end
	else
		CL.SendNotify(NOTIFY.SubmitForm,"FormPetColor","Dyeing_Plan",PetDyeingUI_UserDefined.MyPetList[PetDyeingUI_UserDefined.CurPetIndex].Guid,PetDyeingUI_UserDefined.SchemeIndex-1)
	end
end

function PetDyeingUI_UserDefined.tablecount(datatable)
	local count = 0
	if type(datatable) == "table" then
		for i,v in pairs(datatable) do
			count = count+1
		end
	end
	return count
end

function PetDyeingUI_UserDefined.OnRestoreBtnClick()
	PetDyeingUI_UserDefined.Refresh()
end
