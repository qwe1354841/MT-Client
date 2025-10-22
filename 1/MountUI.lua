--坐骑系统
local MountUI = {}

_G.MountUI = MountUI
local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------


local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local greenTextColor = Color.New(129 / 255, 60 / 255, 176 / 255, 255 / 255)
local colorwrite = Color.New(1, 1, 1, 1);
local coloroutline = Color.New(162 / 255.0, 75 / 225.0, 21 / 255.0, 1)
local colorblack = Color.New(0, 0, 0, 1);
local yellowTextColor = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255)

local ColorType_FontColor2 = Color.New(102 / 255, 47 / 255, 22 / 255);
local fontSize = 22;
local addWingExpTextColor = Color.New(54 / 255, 183 / 255, 109 / 255, 255 / 255)
local fontColor2 = "662F16";    --深色文字

-- 二级页签
local MountTabList = {
    { "属性", "AttributeSubTabBtn", "1800402030", "1800402032", "OnAttributeSubTabBtnClick", 95, -256, 175, 40, 100, 35 },
    { "统驭", "ControlSubTabBtn", "1800402030", "1800402032", "OnControlSubTabBtnClick", 265, -256, 175, 40, 100, 35 },
    { "驯养", "DomesticateSubTabBtn", "1800402030", "1800402032", "OnDomesticateSubTabBtnClick", 435, -256, 175, 40, 100, 35 }, 
}

--属性对应资源图
MountUI.AttrClientList= {
	["物攻"] = "1800407040",
	["物暴"] = "1800407060",
	["闪避"] = "1800407100",
	["移动速度"] = "1800407120",
	["物防"] = "1800407050",
	["法攻"] = "1800407070",
	["法防"] = "1800407080",
	["法暴"] = "1800407090",
	["命中"] = "1800407110",
	["封印"] = "1801507210",
	["速度"] = "1800407120",
	["封抗"] = "1801507220",
}

MountUI.SkillsLvImg = {
	[1] = "1800707140",
	[2] = "1800707150",
	[3] = "1800707160",
	[4] = "1801718014",
	[5] = "1801718015",
	[6] = "1801718016",			
	[7] = "1801718017",
	[8] = "1801718018",
	[9] = "1801718019",
	[10] = "1801718020",
}

--驯养值道具最大堆叠数量
-- MountUI.DomesticateItemMaxStack = 10


-- 创建基础页面
function MountUI.CreateMountPage()

    local wnd = GUI.GetWnd("BagUI")
    local panelBg = GUI.GetChild(wnd,"panelBg") 
    local MountPage = GUI.GroupCreate(panelBg, "MountPage", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd));

    _gt.BindName(MountPage,"MountPage")
	
	--背景图
    local Bg = GUI.ImageCreate(MountPage, "Bg", "1800400010", 265, 15, false,515,510);
    SetAnchorAndPivot(Bg, UIAnchor.Center, UIAroundPivot.Center)
	
    UILayout.CreateSubTab(MountTabList, MountPage, "MountUI"); -- 创建二级页签

    -- 创建左侧页面
    MountUI.CreateLeftPage(MountPage)

    -- 创建右侧页面
    MountUI.CreateRightPage(MountPage)
	
	MountUI.TabIndex = 1
	
	MountUI.InitData()
	
	--注册监听事件
	MountUI.Register()
	
    return GUI.GetGuid(MountPage)
	
	

end

function MountUI.InitData()
	--对表进行处理
	MountUI.GetMountList()
	
	--对好感值道具数据进行处理
	MountUI.MountsLikePointItem = {}
	if GlobalProcessing.MountsLikePointItem and next(GlobalProcessing.MountsLikePointItem) then
		for k , v in pairs(GlobalProcessing.MountsLikePointItem) do
			table.insert(MountUI.MountsLikePointItem,{keyname = k , value = v.addpoint})
		end
		table.sort(MountUI.MountsLikePointItem,function(a,b)return (tonumber(a.value) <  tonumber(b.value)) end)
	end
	MountUI.InitLikePointItemList()
	
	
	
	--对默契值道具数据进行处理
	MountUI.MountsTacitItem = {}
	if GlobalProcessing.MountsTacitNumItem and next(GlobalProcessing.MountsTacitNumItem) then
		for k , v in pairs(GlobalProcessing.MountsTacitNumItem) do
			table.insert(MountUI.MountsTacitItem,{keyname = k , value = v.addpoint})
		end
		table.sort(MountUI.MountsTacitItem,function(a,b)return (tonumber(a.value) <  tonumber(b.value)) end)
	end
	MountUI.InitMountsTacitItemList()
	
	
	--对驯养道具数据进行处理
	MountUI.MountsDomesticateItem = {}
	--排序
	if GlobalProcessing.MountsDomesticateItem and next(GlobalProcessing.MountsDomesticateItem) then
		for k , v in pairs(GlobalProcessing.MountsDomesticateItem) do
			table.insert(MountUI.MountsDomesticateItem,{keyname = k , value = v.addpoint["Domesticate"]})
		end
		table.sort(MountUI.MountsDomesticateItem,
		function(a,b) 
			local value_a = a.value
			local value_b = b.value
			if value_a < 0 then  
				value_a  = 0 - value_a
			end
			if value_b < 0 then  
				value_b  = 0 - value_b
			end
			if value_a ~= value_b then
				return (tonumber(value_a) <  tonumber(value_b))
			else
				return (tonumber(a.value) <  tonumber(b.value))
			end
		end	
		)
	end
	
	
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(GlobalProcessing.MountsSkillPointItem))	
	
	MountUI.InitDomesticateItemList()
	
	--对技能点道具表进行处理
	MountUI.InitSkillPointItemList()
	
end

function MountUI.GetMountList()
	MountUI.MountsConfig = {}
	MountUI.MountIsHave = 0 
	if GlobalProcessing.MountsConfig and next(GlobalProcessing.MountsConfig) then
		local tb = {}
		local modelId = tonumber(tostring(CL.GetIntAttr(RoleAttr.RoleAttrMountId)))
		local curIsRide = 0
		
		--顺便得出好感值上限的表
		MountUI.MountLikePointLimit = {}
	
		for k , v in pairs(GlobalProcessing.MountsConfig) do
			table.insert(tb,k)
			if modelId and modelId ~= 0 and tonumber(v.Model) == modelId then
				curIsRide = k
				MountUI.CurMountID = k
			end
			---------好感值上限相关-------
			local likePoint_temp = v.LikePointAttr
			local count = #likePoint_temp
			local limit = likePoint_temp[count].LikePoint
			MountUI.MountLikePointLimit[k] = limit
			------------------------------
		end
		table.sort(tb,function(a,b)return (tonumber(a) <  tonumber(b)) end)
		
		local tb1 = {}
		local tb2 = {}
		

		for i =1, #tb do
			--记录下来第一个
			if not MountUI.CurMountID then
				MountUI.CurMountID = tb[i] or 10001
			end
			local ishave = tonumber(CL.GetIntCustomData("HaveMount_"..tostring(tb[i])))
			if ishave and ishave == 1 then
				
				if tonumber(tb[i]) ~= curIsRide then
					table.insert(tb1,tb[i])
				end
				
				MountUI.MountIsHave = MountUI.MountIsHave + 1				
			else
				table.insert(tb2,tb[i])
			end
		end

		--先当前骑乘的坐骑
		if curIsRide~= 0 then
			table.insert(MountUI.MountsConfig , {[tostring(curIsRide)] = GlobalProcessing.MountsConfig[curIsRide]})
		end
		
		--当前拥有的进行排序
		if #tb1 > 0 then
			for i = 1 , #tb1 do
				table.insert(MountUI.MountsConfig , {[tostring(tb1[i])] = GlobalProcessing.MountsConfig[tb1[i]]})
			end
		end
		
		--当前未拥有
		if #tb2 > 0 then
			for i = 1 , #tb2 do
				table.insert(MountUI.MountsConfig , {[tostring(tb2[i])] = GlobalProcessing.MountsConfig[tb2[i]]})
			end
		end		

	end
end

function MountUI.Register()
    CL.RegisterMessage(GM.AddNewItem, "MountUI", "OnItemUpdate")
    CL.RegisterMessage(GM.UpdateItem, "MountUI", "OnItemUpdate")
    CL.RegisterMessage(GM.RemoveItem, "MountUI", "OnItemUpdate")
end

--当物品变化
function MountUI.OnItemUpdate(item_guid,item_id)
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
	--好感值相关
	if GlobalProcessing.MountsLikePointItem and GlobalProcessing.MountsLikePointItem[itemDB.KeyName] then
		MountUI.InitLikePointItemList()
		local likePointPage = _gt.GetUI("likePointPage") 
		if likePointPage and GUI.GetVisible(likePointPage) then
			local likePointScroll = _gt.GetUI("likePointScroll")
			if likePointScroll then
				GUI.LoopScrollRectSetTotalCount(likePointScroll, math.max(#MountUI.LikePointItemList,6)) 
				GUI.LoopScrollRectRefreshCells(likePointScroll)
				return
			end
		end		
	end
	
	--默契值相关
	if GlobalProcessing.MountsTacitNumItem and GlobalProcessing.MountsTacitNumItem[itemDB.KeyName] then
		MountUI.InitMountsTacitItemList()
		local addTacitPage = _gt.GetUI("addTacitPage") 
		if addTacitPage and GUI.GetVisible(addTacitPage) then
			local addTacitScroll = _gt.GetUI("addTacitScroll")
			GUI.LoopScrollRectSetTotalCount(addTacitScroll, math.max(#MountUI.TacitItemList,6)) 
			GUI.LoopScrollRectRefreshCells(addTacitScroll)
			return
		end
	end
	
	--驯养相关
	if GlobalProcessing.MountsDomesticateItem and GlobalProcessing.MountsDomesticateItem[itemDB.KeyName] then
		MountUI.InitDomesticateItemList()
		local MountPage = _gt.GetUI("MountPage") 
		if MountPage and GUI.GetVisible(MountPage) and MountUI.TabIndex == 3 then
			MountUI.RefreshDomesticatePage()
			return
		end
	end
	
	--技能点相关
	if GlobalProcessing.MountsSkillPointItem and GlobalProcessing.MountsSkillPointItem[itemDB.KeyName] then
		MountUI.InitSkillPointItemList()
		local addSkillPointPage = _gt.GetUI("addSkillPointPage") 
		if addSkillPointPage and GUI.GetVisible(addSkillPointPage) then
			local skillPointScroll = _gt.GetUI("skillPointScroll")
			if skillPointScroll then
				GUI.LoopScrollRectSetTotalCount(skillPointScroll, math.max(#MountUI.SkillPointItemList,6)) 
				GUI.LoopScrollRectRefreshCells(skillPointScroll)
				return
			end
		end			
	end
	
	--升阶
	if MountUI.MountStageConfig and MountUI.MountStageConfig["Item"] then
		local page = _gt.GetUI("RaiseGradePage")
		if not page or not GUI.GetVisible(page) then
			return
		end
		local flag = 0
		for _ , v in pairs(MountUI.MountStageConfig["Item"]) do 
			if itemDB.KeyName == v then
				flag = 1 
				break
			end
		end
		if flag == 1 then
			local raiseGradeScroll = _gt.GetUI("raiseGradeScroll")
			GUI.LoopScrollRectRefreshCells(raiseGradeScroll)
			return
		end
	end
end

--得到好感值道具列表
function MountUI.InitLikePointItemList()
	MountUI.LikePointItemList = {} 
	if MountUI.MountsLikePointItem then
		for i = 1 ,#MountUI.MountsLikePointItem do
			local itemDB = DB.GetOnceItemByKey2(MountUI.MountsLikePointItem[i].keyname)
			local itemGuids = LD.GetItemGuidsById(itemDB.Id)
			if itemGuids.Count >= 1 then
				local num0 = 0   --不绑定的数量
				local num1 = 0   --绑定数量
				for m = 0 , itemGuids.Count - 1 do
					local isBound = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, itemGuids[m]))  -- 此格子内的物品是否绑定
					local amount = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, itemGuids[m])) 	
					if isBound == 0 then
						num0 = num0 + amount
					elseif isBound == 1 then
						num1 = num1 + amount
					end				
				end
				if num0 ~= 0 then
					table.insert(MountUI.LikePointItemList,{keyname = MountUI.MountsLikePointItem[i].keyname , value = MountUI.MountsLikePointItem[i].value , bind = 0 , num = num0 })
				end
					
				if num1 ~= 0 then
					table.insert(MountUI.LikePointItemList,{keyname = MountUI.MountsLikePointItem[i].keyname , value = MountUI.MountsLikePointItem[i].value , bind = 1 , num = num1 })
				end	
			end			
		end
		if #MountUI.LikePointItemList == 0 then
			for i = 1 ,#MountUI.MountsLikePointItem do
				table.insert(MountUI.LikePointItemList,{keyname = MountUI.MountsLikePointItem[i].keyname , value = MountUI.MountsLikePointItem[i].value , bind = 0 , num = 0 })
			end
		end
	end


end


--得到默契值道具列表

function MountUI.InitMountsTacitItemList()
	MountUI.TacitItemList = {}
	if MountUI.MountsTacitItem then
		for i = 1 ,#MountUI.MountsTacitItem do
			local itemDB = DB.GetOnceItemByKey2(MountUI.MountsTacitItem[i].keyname)
			local itemGuids = LD.GetItemGuidsById(itemDB.Id)
			if itemGuids.Count >= 1 then
				local num0 = 0   --不绑定的数量
				local num1 = 0   --绑定数量
				for m = 0 , itemGuids.Count - 1 do
					local isBound = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, itemGuids[m]))  -- 此格子内的物品是否绑定
					local amount = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, itemGuids[m])) 	
					if isBound == 0 then
						num0 = num0 + amount
					elseif isBound == 1 then
						num1 = num1 + amount
					end				
				end
				if num0 ~= 0 then
					table.insert(MountUI.TacitItemList,{keyname = MountUI.MountsTacitItem[i].keyname , value = MountUI.MountsTacitItem[i].value , bind = 0 , num = num0 })
				end
					
				if num1 ~= 0 then
					table.insert(MountUI.TacitItemList,{keyname = MountUI.MountsTacitItem[i].keyname , value = MountUI.MountsTacitItem[i].value , bind = 1 , num = num1 })
				end	
			end			
		end
		if #MountUI.TacitItemList == 0 then
			for i = 1 ,#MountUI.MountsTacitItem do
				table.insert(MountUI.TacitItemList,{keyname = MountUI.MountsTacitItem[i].keyname , value = MountUI.MountsTacitItem[i].value , bind = 0 , num = 0 })
			end
		end		
	end
end

--得到驯养道具列表
function MountUI.InitDomesticateItemList()
	MountUI.DomesticateItemList = {} 
	if MountUI.MountsDomesticateItem then
		local temp_tb = {}
		for i = 1 ,#MountUI.MountsDomesticateItem do
			local itemDB = DB.GetOnceItemByKey2(MountUI.MountsDomesticateItem[i].keyname)
			local itemGuids = LD.GetItemGuidsById(itemDB.Id)
			
			if itemGuids.Count >= 1 then
				for m = 0 , itemGuids.Count - 1 do
					local isBound = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, itemGuids[m]))  -- 此格子内的物品是否绑定
					local amount = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, itemGuids[m]))
					table.insert(MountUI.DomesticateItemList,{keyname = MountUI.MountsDomesticateItem[i].keyname, bind = isBound , num = amount ,item_guid =itemGuids[m]  })					
				end
			else
				--一个都没有
				table.insert(temp_tb,{keyname = MountUI.MountsDomesticateItem[i].keyname, bind = 0 , num = 0 })
			end			
		end
		
		if #temp_tb > 0 then
			for i = 1 ,#temp_tb do
				table.insert(MountUI.DomesticateItemList,temp_tb[i])
			end
		end
		
		
		if not MountUI.DomesticateItemIndex or MountUI.DomesticateItemIndex > #MountUI.DomesticateItemList then
			MountUI.DomesticateItemIndex = 1
		end
	end
end

--得到技能点道具表
function MountUI.InitSkillPointItemList()
	MountUI.SkillPointItemList = {}
	if GlobalProcessing.MountsSkillPointItem and next(GlobalProcessing.MountsSkillPointItem)then
		for k ,v in pairs(GlobalProcessing.MountsSkillPointItem) do
			local itemDB = DB.GetOnceItemByKey2(k)
			local itemGuids = LD.GetItemGuidsById(itemDB.Id)
			if itemGuids.Count >= 1 then
				local num0 = 0   --不绑定的数量
				local num1 = 0   --绑定数量
				for m = 0 , itemGuids.Count - 1 do
					local isBound = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, itemGuids[m]))  -- 此格子内的物品是否绑定
					local amount = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, itemGuids[m])) 	
					if isBound == 0 then
						num0 = num0 + amount
					elseif isBound == 1 then
						num1 = num1 + amount
					end				
				end
				if num0 ~= 0 then
					table.insert(MountUI.SkillPointItemList,{keyname = k , value = v.addpoint , bind = 0 , num = num0 })
				end
					
				if num1 ~= 0 then
					table.insert(MountUI.SkillPointItemList,{keyname = k , value = v.addpoint , bind = 1 , num = num1 })
				end	
			end
		end
		
		if #MountUI.SkillPointItemList == 0 then
			for k ,v in pairs(GlobalProcessing.MountsSkillPointItem) do
				table.insert(MountUI.SkillPointItemList,{keyname = k, value = v.addpoint , bind = 0 , num = 0 })
			end
		end
		
		table.sort(MountUI.SkillPointItemList,function(a,b)return (tonumber(a.value) <  tonumber(b.value)) end)
	end

end

-- 向服务器发送请求获取数据
function MountUI.getSeverMountData(IsSwitch)
	--从背包打开默认第一个坐骑（切换时传入true）
	if not IsSwitch then
		if MountUI.MountsConfig and MountUI.MountsConfig[1] then
			for k ,v in pairs(MountUI.MountsConfig[1]) do
				MountUI.CurMountID = tonumber(k)
			end
		else
			MountUI.InitData()
		end
		--以及第一页
		MountUI.TabIndex = 1
		--是否根据物品跳转
		if GlobalProcessing.MountTabIndex then
			MountUI.TabIndex = GlobalProcessing.MountTabIndex
			GlobalProcessing.MountTabIndex = nil
		end
	end
    CL.SendNotify(NOTIFY.SubmitForm,"FormMount","GetData",MountUI.CurMountID,GlobalProcessing.MountsVersion)
end

--点击属性页
function MountUI.OnAttributeSubTabBtnClick()
	MountUI.TabIndex = 1
	UILayout.OnSubTabClickEx(MountUI.TabIndex,MountTabList)
	MountUI.RefreshRightPage()
end


--点击统驭页
function MountUI.OnControlSubTabBtnClick()
	MountUI.TabIndex = 2
	UILayout.OnSubTabClickEx(MountUI.TabIndex,MountTabList)
	MountUI.RefreshRightPage()
end

--点击驯养页
function MountUI.OnDomesticateSubTabBtnClick()
	MountUI.TabIndex = 3
	UILayout.OnSubTabClickEx(MountUI.TabIndex,MountTabList)
	MountUI.RefreshRightPage()
end

function MountUI.Refresh()
	--重置一些值
	-- MountUI.IsAddSkillPoint = 0  --更新后作废
	
	MountUI.CurSkillItemGuid = nil
	
	--刷新子页签
	UILayout.OnSubTabClickEx(MountUI.TabIndex,MountTabList)
	
	--刷信左侧信息界面
	MountUI.RefreshBaseInfo()
	
	
	--新增 皮肤切换相关刷新
	MountUI.RefreshSkinSwtich()
	MountUI.SetBuySkinBtn()
	
	--模型刷新
	MountUI.RefreshModel()
	
	--刷新显示按钮（移至属性页）
	-- MountUI.RefreshMountShowBtn()
	
	
	--右侧界面刷新
	MountUI.RefreshRightPage()
	
	
end


function MountUI.RefreshSkinSwtich()
	MountUI.CurMountSkin = {}
	local SkinLeftBtn = _gt.GetUI("SkinLeftBtn")
	local SkinRightBtn = _gt.GetUI("SkinRightBtn")
		
	if GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Skin and next(GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Skin) then
		GUI.SetVisible(SkinLeftBtn,true)
		GUI.SetVisible(SkinRightBtn,true)
		--数据处理
		table.insert(MountUI.CurMountSkin,{id = tonumber(MountUI.CurMountID) , model = tonumber(tostring(DB.GetOnceBuffByKey1(tonumber(MountUI.CurMountID)).FixedAtt1Att1Coef1))})
		
		local tb = GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Skin
		for i = 1, #tb do
			table.insert(MountUI.CurMountSkin,{id =tb[i] ,model = tonumber(tostring(DB.GetOnceBuffByKey1(tb[i]).FixedAtt1Att1Coef1))})
		end
		
		local curModelId = GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Model
		for i = 1 , #MountUI.CurMountSkin do 
			if MountUI.CurMountSkin[i].model == curModelId then
				MountUI.MountSkinIndex = i
			end
		end
	else
		GUI.SetVisible(SkinLeftBtn,false)
		GUI.SetVisible(SkinRightBtn,false)		
	end
end


function MountUI.SetBuySkinBtn()
	local btn = _gt.GetUI("buySkinBtn")
	local text = _gt.GetUI("buySkinBtnText")
	local name = _gt.GetUI("SkinName")
	if GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Skin and next(GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Skin) then
		local curModel = GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Model
		local baseBuffId = tonumber(MountUI.CurMountID)
		if MountUI.CurMountSkin[MountUI.MountSkinIndex].model == curModel then
			if baseBuffId == MountUI.CurMountSkin[MountUI.MountSkinIndex].id then
				GUI.SetVisible(btn,false)
			else
				GUI.StaticSetText(text,"卸下")
				GUI.SetVisible(btn,true)
				GUI.SetData(btn,"state",2)
			end
		else
			local state = tonumber(CL.GetIntCustomData("MountHaveSkin_"..MountUI.CurMountSkin[MountUI.MountSkinIndex].id))
			if baseBuffId == MountUI.CurMountSkin[MountUI.MountSkinIndex].id then
				state = 1 
			end
			GUI.SetData(btn,"state",state)
			if state == 1  then
				GUI.StaticSetText(text,"穿戴")
			else
				GUI.StaticSetText(text,"解锁")
			end
			GUI.SetVisible(btn,true)
		end
		if GlobalProcessing.MountsSkinConfig and GlobalProcessing.MountsSkinConfig[MountUI.CurMountSkin[MountUI.MountSkinIndex].id] then
			GUI.StaticSetText(name,GlobalProcessing.MountsSkinConfig[MountUI.CurMountSkin[MountUI.MountSkinIndex].id].Name)
			GUI.SetVisible(name,true)
		else
			GUI.SetVisible(name,false)
		end
	else
		GUI.SetVisible(btn,false)
		GUI.SetVisible(name,false)
	end
end

function MountUI.OnSkinLeftBtnClick()
	MountUI.MountSkinIndex = MountUI.MountSkinIndex >1 and MountUI.MountSkinIndex - 1 or #MountUI.CurMountSkin
	MountUI.SetBuySkinBtn()
	
	local tb = MountUI.CurMountSkin[MountUI.MountSkinIndex] 
	CL.SendNotify(NOTIFY.SubmitForm, "FormMount","GetColorList",tb.id,GlobalProcessing.MountsVersion)
end

function MountUI.OnSkinRightBtnClick()
	MountUI.MountSkinIndex = MountUI.MountSkinIndex < #MountUI.CurMountSkin and MountUI.MountSkinIndex + 1 or 1
	MountUI.SetBuySkinBtn()
	local tb = MountUI.CurMountSkin[MountUI.MountSkinIndex] 
	CL.SendNotify(NOTIFY.SubmitForm, "FormMount","GetColorList",tb.id,GlobalProcessing.MountsVersion)
end

function MountUI.RefreshSkinEffect()
	-- MountUI.SetBuySkinBtn()
	MountUI.RefreshModel()
end


function MountUI.RefreshModel()
	local RoleModel = _gt.GetUI("RoleModel")
	local MountModel = _gt.GetUI("MountModel")
	local modelID = GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Model
	if GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Skin and next(GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Skin) then
		modelID = MountUI.CurMountSkin[MountUI.MountSkinIndex].model
	end
	GlobalProcessing.Mount_RefreshModel(RoleModel,MountModel,modelID)
	
	GUI.RawImageChildSetModleRotation(MountModel, Vector3.New(0, -45, 0))
	
	if MountUI.MountColorList and next(MountUI.MountColorList) then
		GUI.RefreshDyeSkinJson(MountModel, jsonUtil.encode(MountUI.MountColorList), "")
	end
end


function MountUI.RefreshBaseInfo()
	--品阶
	local mountGrade  = _gt.GetUI("mountGrade")
	GUI.StaticSetText(mountGrade,MountUI.Stage)
	
	--品阶按钮及默契值相关
	MountUI.RefreshGradeBtnAndTacit()
	
	--描述
	local mountDes  = _gt.GetUI("mountDes")
	GUI.StaticSetText(mountDes,GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].Tips)
	

end

function MountUI.RefreshGradeBtnAndTacit()
	local raiseGradeBtn = _gt.GetUI("raiseGradeBtn")
	local addTacitBtn = _gt.GetUI("addTacitBtn")
	local mountTacit  = _gt.GetUI("mountTacit")
	
	
	if tonumber(MountUI.Stage) < GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].MaxStage then --品阶未满的情况下
		--判断默契值是否已满
		local CurTacit = MountUI.Tacit
		local LimitTacit = MountUI.MountStageConfig["MaxTacitNum"]
		
		GUI.SetVisible(addTacitBtn,CurTacit < LimitTacit)
		GUI.SetVisible(raiseGradeBtn,CurTacit >= LimitTacit)
		
		GUI.StaticSetText(mountTacit,CurTacit.."/"..LimitTacit)
	else  --品阶已满
		
		--按钮
		GUI.SetVisible(raiseGradeBtn,false)
		
		--默契值
		GUI.SetVisible(addTacitBtn,false)
		GUI.StaticSetText(mountTacit,"已满")
	
	end
end

function MountUI.RefreshRightPage()
	if MountUI.TabIndex == 1 then
		--判断是否数据存在
		MountUI.RefreshAttributePage()
	
	elseif MountUI.TabIndex == 2 then
		--判断是否数据存在
		MountUI.RefreshControlPage()
	elseif MountUI.TabIndex == 3 then
		MountUI.RefreshDomesticatePage()
	end
	
	--界面显示
	local AttributePage =  _gt.GetUI("attributeBg")
	local ControlPage =  _gt.GetUI("controlBg")
	local DomesticatePage =  _gt.GetUI("domesticateBg")

	GUI.SetVisible(AttributePage,MountUI.TabIndex == 1)
	GUI.SetVisible(ControlPage,MountUI.TabIndex == 2)
	GUI.SetVisible(DomesticatePage,MountUI.TabIndex == 3)

end

function MountUI.RefreshDomesticatePage()
	local tb = GlobalProcessing.MountsConfig[MountUI.CurMountID]
	--驯养
		-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(GlobalProcessing.MountsConfig))	

	if MountUI.MountDomesticatePoint then
		local domesticateSlider = _gt.GetUI("domesticateSlider")
		local wildSlider = _gt.GetUI("wildSlider")
		local tb = tb.DomesticatePointAttr
		if MountUI.MountDomesticatePoint > 0 then
			local value = _gt.GetUI("CurDomesticateValue")
			GUI.SetVisible(domesticateSlider,true)
			GUI.SetVisible(wildSlider,false)
			local limit = tb["Max"].Point or 100
			GUI.SetWidth(domesticateSlider,(math.min(MountUI.MountDomesticatePoint/limit,1))*180)
			GUI.StaticSetText(value,MountUI.MountDomesticatePoint)
		elseif MountUI.MountDomesticatePoint == 0 then
			GUI.SetVisible(domesticateSlider,false)
			GUI.SetVisible(wildSlider,false)		
		elseif MountUI.MountDomesticatePoint < 0 then
			local value = _gt.GetUI("CurWildValue")
			GUI.SetVisible(domesticateSlider,false)
			GUI.SetVisible(wildSlider,true)	
			local limit = tb["Min"].Point or -100
			GUI.SetWidth(wildSlider,(math.min(MountUI.MountDomesticatePoint/limit,1))*180)
			GUI.StaticSetText(value,0-MountUI.MountDomesticatePoint)
		end	
	end
	
	--活跃
	if MountUI.MountActivePoint then
		local CalmSlider = _gt.GetUI("CalmSlider")
		local PassionateSlider = _gt.GetUI("PassionateSlider")
		local tb = tb.ActivePointAttr
		if MountUI.MountActivePoint > 0 then
			local value = _gt.GetUI("CurCalmValue")
			GUI.SetVisible(CalmSlider,true)
			GUI.SetVisible(PassionateSlider,false)
			local limit = tb["Max"].Point or 100
			GUI.SetWidth(CalmSlider,(math.min(MountUI.MountActivePoint/limit,1))*180)
			GUI.StaticSetText(value,MountUI.MountActivePoint)
		elseif MountUI.MountActivePoint == 0 then
			GUI.SetVisible(CalmSlider,false)
			GUI.SetVisible(PassionateSlider,false)		
		elseif MountUI.MountActivePoint < 0 then
			local value = _gt.GetUI("CurPassionateValue")
			GUI.SetVisible(CalmSlider,false)
			GUI.SetVisible(PassionateSlider,true)	
			local limit = tb["Min"].Point or -100
			GUI.SetWidth(PassionateSlider,(math.min(MountUI.MountActivePoint/limit,1))*180)
			GUI.StaticSetText(value,0-MountUI.MountActivePoint)
		end	
	end	
	
	--属性值
	local CurDomesticateAttr = _gt.GetUI("CurDomesticateAttr")
	local temp = ""
	for k , v in pairs(MountUI.MountDomesticateAttr) do
		if temp ~= "" then
			temp = temp.."，"
		end
		local attrDB = DB.GetOnceAttrByKey1(k)
		temp = temp .. attrDB.ChinaName.."+"..v
	end
	if temp == "" then
		GUI.StaticSetText(CurDomesticateAttr,"当前无属性加成")
	else
		GUI.StaticSetText(CurDomesticateAttr,"当前属性加成："..temp)
	end
	GUI.StaticSetFontSizeBestFit(CurDomesticateAttr)
	
	--刷新物品栏
	local DomesticateScroll = _gt.GetUI("DomesticateScroll")
	GUI.LoopScrollRectSetTotalCount(DomesticateScroll, math.max((math.ceil(#MountUI.DomesticateItemList/3))*3,9)) 
	GUI.LoopScrollRectRefreshCells(DomesticateScroll)
	
	MountUI.RefreshDomesticateInfo()
end

function MountUI.RefreshAttributePage()
	local AttributePage =  _gt.GetUI("attributeBg")
	
	--属性
	--对表进行处理
	MountUI.AttrListOrder = {}
	if MountUI.AttrList and next(MountUI.AttrList) then
		local tb = {}
		for k , v in pairs(MountUI.AttrList) do
			table.insert(tb,k)
		end
		table.sort(tb,function(a,b)return (tonumber(a) <  tonumber(b)) end)
		if #tb > 0 then
			for i = 1, #tb do
				local _value = MountUI.AttrList[tb[i]]
				local _id = tb[i]
				if _id == 52 then
					_value = math.floor((0-_value)/0.6).. "%"
				end
				MountUI.AttrListOrder[i] = {id = _id, value = _value }
			end
		end
	end
	
	local attrScroll = _gt.GetUI("attrScroll")
	GUI.LoopScrollRectSetTotalCount(attrScroll, #MountUI.AttrListOrder) 
	GUI.LoopScrollRectRefreshCells(attrScroll)
	
	
	--好感值刷新
	local slider = _gt.GetUI("friendshipSlider")
	local friendship = _gt.GetUI("friendshipSliderCurrentTxt")
	GUI.ScrollBarSetFillImgName(slider,"1800408160")
	GUI.ScrollBarSetPos(slider,MountUI.LikePoint/MountUI.MountLikePointLimit[MountUI.CurMountID])
	GUI.StaticSetText(friendship,MountUI.LikePoint.."/"..MountUI.MountLikePointLimit[MountUI.CurMountID])
	
	
	--好感值加成分割线
	MountUI.RefreshSliderSplit(slider)
	
	local likePointPage = _gt.GetUI("likePointPage")
	if likePointPage and GUI.GetVisible(likePointPage) then
		MountUI.OnAddPointClose()	
	end
	
	--按钮刷新
	local rideBtn = _gt.GetUI("rideBtn")
	local rideBtnText = _gt.GetUI("rideBtnText")
	-- local restBtn = _gt.GetUI("restBtn")
	if  MountUI.HaveMount and MountUI.HaveMount == 1 then
		GUI.ButtonSetShowDisable(rideBtn,true)
		if MountUI.IsRide and MountUI.IsRide == 1 then
			GUI.StaticSetText(rideBtnText,"休息")
			-- GUI.ButtonSetShowDisable(restBtn,true)
		else
			GUI.StaticSetText(rideBtnText,"骑乘")
			-- GUI.ButtonSetShowDisable(restBtn,false)
		end
	else
		GUI.StaticSetText(rideBtnText,"骑乘")
		GUI.ButtonSetShowDisable(rideBtn,false)
		-- GUI.ButtonSetShowDisable(restBtn,false)
	end
	
	--隐藏按钮刷新
	MountUI.RefreshMountShowBtn()


end

--分割下划线
function MountUI.RefreshSliderSplit(slider)
	local tb = GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].LikePointAttr
	local num = math.max(MountUI.SliderSplitCount or 0 , #tb)
	local TipsMark = 0
	
	--判断是否数据有效
	if MountUI.SliderSplitCount and MountUI.SliderSplitCount >0 then
		local Split_ = GUI.GetChild(slider,"Split_1")
		if not Split_ then
			MountUI.SliderSplitCount = 0
		end
	end
	for i = 1 , num do
		local Split_ = GUI.GetChild(slider,"Split_"..i)
		if not Split_ then
			Split_ = GUI.ImageCreate(slider, "Split_"..i, "1801208390", 0, 0, false,8,30);
			SetAnchorAndPivot(Split_, UIAnchor.Center, UIAroundPivot.Center)
			-- GUI.SetColor(Split_,Color.New(255 / 255, 255 / 255, 255 / 255, 0.5))
			-- local label = GUI.CreateStatic( Split_, "label", "0", 0, 0, 100, 40, "system", true, false);
			-- SetAnchorAndPivot(label, UIAnchor.Center, UIAroundPivot.Center)
			-- GUI.StaticSetFontSize(label, 22);
			-- GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter);
			-- GUI.SetColor(label, colorDark)			
			MountUI.SliderSplitCount = MountUI.SliderSplitCount and MountUI.SliderSplitCount +1 or 1
		end 	
		
		if tb[i] and tb[i].LikePoint then
			local posx = -180+(tb[i].LikePoint/MountUI.MountLikePointLimit[MountUI.CurMountID])*360
			GUI.SetPositionX(Split_,posx)
			if tb[i].LikePoint ~=0 and tb[i].LikePoint ~= MountUI.MountLikePointLimit[MountUI.CurMountID] then
				GUI.SetVisible(Split_,true)
			else
				GUI.SetVisible(Split_,false)
			end
			
			--Tips相关
			if TipsMark == 0 then
				local LikePointTips = _gt.GetUI("LikePointTips")
				if MountUI.LikePoint < tb[i].LikePoint then
					GUI.SetPositionX(LikePointTips,posx)
					GUI.SetVisible(LikePointTips,true)
					MountUI.LikePointTipsList = tb[i]
					TipsMark = 1
				end
				if i == num and TipsMark == 0 then
					GUI.SetPositionX(LikePointTips,posx)
					GUI.SetVisible(LikePointTips,true)
					MountUI.LikePointTipsList = tb[i]
				end
			end
		else
			GUI.SetVisible(Split_,false)
		end
	end


end



function MountUI.RefreshControlPage()
	local ControlPetScroll = _gt.GetUI("ControlPetScroll")
	GUI.LoopScrollRectSetTotalCount(ControlPetScroll, GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)].PetNum) 
	GUI.LoopScrollRectRefreshCells(ControlPetScroll)
	
	MountUI.IsUpSkill = 0
	for k , v in pairs(MountUI.SkillList) do
		if v.Level == v.MaxLevel and v.NextSkill and  v.NextSkill ~= "0" then
			MountUI.IsUpSkill = 1
		end
	end
	
	-- if MountUI.SkillPoint <=0 and MountUI.UniversalSkillPoint <= 0 and MountUI.IsUpSkill == 0 then
		-- MountUI.IsAddSkillPoint = 0
	-- end
	--对技能表进行处理
	-- MountUI.SkillListOrder = {}
	-- if MountUI.SkillList and next(MountUI.SkillList) then
		-- local tb = {}
		-- for k , v in pairs(MountUI.SkillList) do
			-- table.insert(tb,k)
		-- end
		-- table.sort(tb,function(a,b)return (tonumber(a) <  tonumber(b)) end)
		-- if #tb > 0 then
			-- for i = 1, #tb do
				-- MountUI.SkillListOrder[i] = {id = tb[i], lv = MountUI.SkillList[tb[i]] }
			-- end
		-- end
	-- end
	local skillScroll = _gt.GetUI("skillScroll")
	GUI.LoopScrollRectSetTotalCount(skillScroll, math.max(#MountUI.SkillList,15)) 
	GUI.LoopScrollRectRefreshCells(skillScroll)
	
	--学习技能框
	-- local skillFrame = _gt.GetUI("skillFrame")
	-- GUI.SetVisible(skillFrame,MountUI.IsAddSkillPoint == 1)
	-- local addPointOnExit = _gt.GetUI("addPointOnExit")
	-- GUI.SetVisible(addPointOnExit,MountUI.IsAddSkillPoint ==1)
	--技能点道具页面
	local addSkillPointPage = _gt.GetUI("addSkillPointPage")
	if addSkillPointPage and GUI.GetVisible(addSkillPointPage) then
		MountUI.OnAddSkillPointClose()	
	end
	
	--技能点
	local skillPoint = _gt.GetUI("skillPoint")
	local value = MountUI.SkillPoint
	if MountUI.UniversalSkillPoint and MountUI.UniversalSkillPoint > 0 then
		value = value .."<color=#42B1F0ff> +"..MountUI.UniversalSkillPoint.."</color>"
	end
	GUI.StaticSetText(skillPoint,value)
	
	--消耗技能点
	MountUI.RefreshConsumeSkillPoint()
	
	--刷新学习技能按钮
	MountUI.RefreshAddPointBtn()
end

--统驭宠物
function MountUI.CreateControlPetItem()
	local ControlPetScroll = _gt.GetUI("ControlPetScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(ControlPetScroll)
	local petItem = ItemIcon.Create(ControlPetScroll, "petItem", 0, 0)
	UILayout.SetSameAnchorAndPivot(petItem,UILayout.Center)
	GUI.RegisterUIEvent(petItem, UCE.PointerClick, "MountUI", "OpenSelectedControlPetWnd")
	-- _gt.BindName(petItem,"petItem")
	
	
	local AddPet = GUI.ImageCreate(petItem,"AddPet","1800707060",0,1,true)
	UILayout.SetSameAnchorAndPivot(AddPet, UILayout.Center)
	GUI.SetVisible(AddPet,false)
	
	return petItem
end

function MountUI.RefreshControlPetScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local petItem = GUI.GetByGuid(guid)
	local AddPet = GUI.GetChild(petItem,"AddPet")
	index = index + 1
	
	local Guid = MountUI.MountPet[index] or uint64.zero
	GUI.SetData(petItem,"index",index)
	
	if tostring(Guid) ~= "0" then
		local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,Guid)))
		local petDB = DB.GetOncePetByKey1(petId)
		GUI.ItemCtrlSetElementValue(petItem, eItemIconElement.Icon, tostring(petDB.Head))
		GUI.ItemCtrlSetElementRect(petItem, eItemIconElement.Icon, 0, 0,70,71);
		GUI.ItemCtrlSetElementValue(petItem, eItemIconElement.Border, UIDefine.PetItemIconBg3[tonumber(petDB.Grade)])
		GUI.SetVisible(AddPet,false)
	else
		ItemIcon.SetEmpty(petItem)
		GUI.SetVisible(AddPet,true)
	end	
end





--左侧界面
function MountUI.CreateLeftPage(MountPage)
	
    -- 龙背景
    local dragonBg = GUI.ImageCreate(MountPage, "dragonBg", "1800400230", -252.71, -115.8, false);
    SetAnchorAndPivot(dragonBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(dragonBg,"dragonBg")

    -- 创建左边模型
    local shadow = GUI.ImageCreate(dragonBg, "shadow", "1800400240", 0, 110)


	local model = GUI.RawImageCreate(shadow, false, "model", "", -5, -120, 3,false,600,600)
	_gt.BindName(model, "model")
	model:RegisterEvent(UCE.Drag)
	model:RegisterEvent(UCE.PointerClick)
	GUI.AddToCamera(model)
	GUI.RawImageSetCameraConfig(model, "(0,1.55,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,5,0.01,2.0,1E-05");
	GUI.RegisterUIEvent(model, UCE.PointerClick, "MountUI", "OnModelClick")

    local RoleModel = GUI.RawImageChildCreate(model, false, "MountPage_RoleModel", "", 0, 0)
	GUI.RegisterUIEvent(RoleModel, ULE.AnimationCallBack, "MountUI", "OnAnimationCallBack")
    _gt.BindName(RoleModel, "RoleModel")
	
	local MountModel = GlobalProcessing.Mount_ModelCreate_WithModel(model,RoleModel,"MountUI","ModelCreate")
	-- GUI.RegisterUIEvent(MountModel, ULE.AnimationCallBack, "MountUI", "OnAnimationCallBack")
	_gt.BindName(MountModel, "MountModel")

	
    local text = GUI.CreateStatic(MountPage,"SkinName","",240,90,300,50,"100");
	GUI.SetAnchor(text,UIAnchor.TopLeft)
	GUI.SetPivot(text,UIAroundPivot.TopLeft)
	GUI.StaticSetFontSize(text,26)
	GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
	GUI.SetVisible(text,false)
	_gt.BindName(text, "SkinName")
	--设置颜色渐变
	GUI.StaticSetIsGradientColor(text,true)
	GUI.StaticSetGradient_ColorTop(text,Color.New(255/255,244/255,139/255,255/255))
	--设置描边
	GUI.SetIsOutLine(text,true)
	GUI.SetOutLine_Distance(text,3)
	GUI.SetOutLine_Color(text,Color.New(82/255,80/255,76/255,255/255))
	--设置阴影
	GUI.SetIsShadow(text,true)
	GUI.SetShadow_Distance(text,Vector2.New(0,-1))
	GUI.SetShadow_Color(text,UIDefine.BlackColor)
	
	--皮肤切换
    local SkinLeftBtn = GUI.ButtonCreate(MountPage, "SkinLeftBtn", "1800602190", 130, -100, Transition.ColorTint,"",45,55,false)
    GUI.RegisterUIEvent(SkinLeftBtn, UCE.PointerClick, "MountUI", "OnSkinLeftBtnClick")
	SetAnchorAndPivot(SkinLeftBtn, UIAnchor.Left, UIAroundPivot.Left)
	_gt.BindName(SkinLeftBtn, "SkinLeftBtn")

    local SkinRightBtn = GUI.ButtonCreate(MountPage, "SkinRightBtn", "1800602190", -50, -100, Transition.ColorTint,"",45,55,false)
	GUI.SetEulerAngles(SkinRightBtn, Vector3.New(180, 180, 0))
	GUI.SetScale(SkinRightBtn,Vector3.New(1,-1,1))
    GUI.RegisterUIEvent(SkinRightBtn, UCE.PointerClick, "MountUI", "OnSkinRightBtnClick")	
	SetAnchorAndPivot(SkinRightBtn, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(SkinRightBtn, "SkinRightBtn")
	
	--解锁皮肤
	local buySkinBtn = GUI.ButtonCreate( MountPage, "buySkinBtn", "1800402090", -250, 45, Transition.ColorTint, "",100,40,false)
    SetAnchorAndPivot(buySkinBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(buySkinBtn, UCE.PointerClick, "MountUI", "OnBuySkinBtnClick")
	_gt.BindName(buySkinBtn,"buySkinBtn")
	GUI.SetVisible(buySkinBtn,false)
	-- GUI.ButtonSetShowDisable(buySkinBtn,false)

    local buySkinBtnText = GUI.CreateStatic( buySkinBtn, "buySkinBtnText", "解锁", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(buySkinBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(buySkinBtnText, 24)
    GUI.StaticSetAlignment(buySkinBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(buySkinBtnText, true)
    GUI.SetOutLine_Color(buySkinBtnText, coloroutline)
    GUI.SetOutLine_Distance(buySkinBtnText, 1)
	_gt.BindName(buySkinBtnText,"buySkinBtnText")

    local mountInfoBg = GUI.ImageCreate(dragonBg, "mountInfoBg", "1801200030", 0, 287.6, false, 539.6, 192.5); -- 父类
    -- GUI.SetVisible(mountInfoBg,t)
    SetAnchorAndPivot(mountInfoBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(mountInfoBg,"mountInfoBg")

    local labelTxt1 = GUI.CreateStatic( mountInfoBg, "InfoTxtlabal", "默契值", 40, -52.4, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt1, 22);
    GUI.StaticSetAlignment(labelTxt1, TextAnchor.MiddleLeft);
    GUI.SetColor(labelTxt1, colorDark);

    local labelTxt2 = GUI.CreateStatic( mountInfoBg, "InfoTxtlabal2", "描述", -185.6, 4, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt2, 22);
    GUI.StaticSetAlignment(labelTxt2, TextAnchor.MiddleLeft);
    GUI.SetColor(labelTxt2, colorDark);

    local labelTxt3 = GUI.CreateStatic( mountInfoBg, "InfoTxtlabal3", "品阶", -185.6, -52, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt3, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt3, 22);
    GUI.StaticSetAlignment(labelTxt3, TextAnchor.MiddleLeft);
    GUI.SetColor(labelTxt3, colorDark);

    local mountTacit = GUI.CreateStatic( mountInfoBg, "mountTacit", "0/0", 310, -27, 472.7, 73.4, "system", true, false);
    SetAnchorAndPivot(mountTacit, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(mountTacit, 20);
    GUI.StaticSetAlignment(mountTacit, TextAnchor.UpperLeft)
    GUI.SetColor(mountTacit, yellowTextColor)
	_gt.BindName(mountTacit,"mountTacit")

    local mountGrade = GUI.CreateStatic( mountInfoBg, "mountGrade", "0阶", 67, -27, 472.7, 73.4, "system", true, false);
    SetAnchorAndPivot(mountGrade, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(mountGrade, 20);
    GUI.StaticSetAlignment(mountGrade, TextAnchor.UpperLeft);
    GUI.SetColor(mountGrade, yellowTextColor)
	_gt.BindName(mountGrade,"mountGrade")

    local mountDes = GUI.CreateStatic( mountInfoBg, "mountDes", "XXXXXXXXXX坐骑描述", 10, 64, 472.7, 73.4, "system", true, false);
    SetAnchorAndPivot(mountDes, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(mountDes, 20);
    GUI.StaticSetAlignment(mountDes, TextAnchor.UpperLeft);
    GUI.SetColor(mountDes, yellowTextColor)
	_gt.BindName(mountDes,"mountDes")
	
	--升阶按钮
	local raiseGradeBtn = GUI.ButtonCreate(mountInfoBg,"raiseGradeBtn","1800402060",-100,-52,Transition.ColorTint,"",35,35,false,false)
    UILayout.SetSameAnchorAndPivot(raiseGradeBtn, UILayout.Center)
	GUI.RegisterUIEvent(raiseGradeBtn, UCE.PointerClick, "MountUI", "OpenMountRaiseGradePage")
	_gt.BindName(raiseGradeBtn,"raiseGradeBtn")
	-- GUI.SetVisible(raiseGradeBtn,false)
	
	--增加默契值
	local addTacitBtn = GUI.ButtonCreate(mountInfoBg,"addTacitBtn","1800402060",200,-52,Transition.ColorTint,"",35,35,false,false)
    UILayout.SetSameAnchorAndPivot(addTacitBtn, UILayout.Center)
	GUI.RegisterUIEvent(addTacitBtn, UCE.PointerClick, "MountUI", "OnAddTacitBtnClick")
	_gt.BindName(addTacitBtn,"addTacitBtn")
	
	--放生按钮
	local mountFreeBtn = GUI.ButtonCreate(MountPage,"mountFreeBtn","1801202210",-60,-60,Transition.ColorTint,"",45,46,false,false)
    UILayout.SetSameAnchorAndPivot(mountFreeBtn, UILayout.Center)
	GUI.RegisterUIEvent(mountFreeBtn, UCE.PointerClick, "MountUI", "OnMountFreeBtnClick")
	GUI.SetVisible(mountFreeBtn,false)

	--隐藏/显示
	local mountShowBtn = GUI.ButtonCreate(MountPage,"mountShowBtn","1800702060",-60,0,Transition.ColorTint,"",45,46,false,false)
    UILayout.SetSameAnchorAndPivot(mountShowBtn, UILayout.Center)
	GUI.RegisterUIEvent(mountShowBtn, UCE.PointerClick, "MountUI", "OnMountShowBtnClick")
	
    local AttrTips = GUI.ButtonCreate(MountPage, "AttrTips", "1800702030", -60, -220, Transition.ColorTint,"",38,39,false)
	UILayout.SetSameAnchorAndPivot(AttrTips, UILayout.Center)
	GUI.RegisterUIEvent(AttrTips, UCE.PointerClick, "MountUI", "OnAttrTipsClick")
	_gt.BindName(AttrTips,"AttrTips")
	
	
	
    local mountShowText = GUI.CreateStatic( mountShowBtn,"mountShowText", "_____", -20, -20, 100, 50, "system", true, false);
    SetAnchorAndPivot(mountShowText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(mountShowText, 20);
    GUI.StaticSetAlignment(mountShowText, TextAnchor.MiddleCenter);
    GUI.SetColor(mountShowText, Color.New(139 / 255, 89 / 255, 55 / 255, 1))
	_gt.BindName(mountShowText,"mountShowText")
	GUI.SetEulerAngles(mountShowText,Vector3.New(0, 0, 45)) 
	GUI.SetScale(mountShowText,Vector3.New(1,3, 1))
	GUI.SetVisible(mountShowText,false)
	
	--切换按钮
    local switchBtn = GUI.ButtonCreate( MountPage, "switchBtn", "1800600100", -460, -240, Transition.None,"",110,40,false)
    SetAnchorAndPivot(switchBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(switchBtn, UCE.PointerClick, "MountUI", "OnSwitchBtnClick")

    local switchBtnTxt = GUI.CreateStatic(switchBtn, "switchBtnTxt", "切 换", 15, 0, 100, 50, "system", true, false);
    SetAnchorAndPivot(switchBtnTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(switchBtnTxt, 22);
    GUI.StaticSetAlignment(switchBtnTxt, TextAnchor.MiddleLeft)
    GUI.SetColor(switchBtnTxt, colorDark)
	
    local pull = GUI.ImageCreate(switchBtn, "pull", "1800707070", -10, 0)
    SetAnchorAndPivot(pull, UIAnchor.Right, UIAroundPivot.Right)
	
end


function MountUI.OnBuySkinBtnClick()
	local state = tonumber(GUI.GetData(_gt.GetUI("buySkinBtn"),"state"))
	if state then
		if state == 1 then
			CL.SendNotify(NOTIFY.SubmitForm,"FormMount","ChangeSkin",MountUI.CurMountID,MountUI.CurMountSkin[MountUI.MountSkinIndex].id,GlobalProcessing.MountsVersion)
		elseif state == 0 then
			CL.SendNotify(NOTIFY.SubmitForm,"FormMount","BuySkin",MountUI.CurMountSkin[MountUI.MountSkinIndex].id,GlobalProcessing.MountsVersion)
		elseif state == 2 then
			CL.SendNotify(NOTIFY.SubmitForm,"FormMount","ChangeSkin",MountUI.CurMountID,MountUI.CurMountID,GlobalProcessing.MountsVersion)
		end
	end
end

function MountUI.OnAttrTipsClick()
	local MountPage = _gt.GetUI("MountPage")
	local tips = GUI.TipsCreate(MountPage,"AttrTips",0,0,400,150)
	tips:RegisterEvent(UCE.PointerClick)
	GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)

    local Label = GUI.CreateStatic(tips, "Label", GlobalProcessing.MountsAttrTips, 0, 0, 350, 350, "system", true, false);
    SetAnchorAndPivot(Label, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Label, 22)
    GUI.StaticSetAlignment(Label, TextAnchor.MiddleLeft)	
end

function MountUI.OnMountFreeBtnClick()
	--没有该坐骑不让打开
	if not MountUI.HaveMount or MountUI.HaveMount ~= 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得该坐骑")
		return
	end
	
	GlobalUtils.ShowBoxMsg2Btn("提示","是否确认将该坐骑放生？","MountUI","确定","SendDeleteMountNotify","取消")
	
end

function MountUI.SendDeleteMountNotify()
	CL.SendNotify(NOTIFY.SubmitForm, "FormMount","DeleteMount", MountUI.CurMountID)
end

function MountUI.OnMountShowBtnClick()
	--没有该坐骑不让打开
	if not MountUI.HaveMount or MountUI.HaveMount ~= 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得该坐骑")
		return
	end
	
	if not MountUI.IsShow then
		return
	end
	
	--MountUI.IsShow = 1 时为当前隐藏中
	if MountUI.IsShow == 1 then
		--显示
		CL.SendNotify(NOTIFY.SubmitForm, "FormMount","ShowMount", MountUI.CurMountID)
	else
		--隐藏
		CL.SendNotify(NOTIFY.SubmitForm, "FormMount","HideMount", MountUI.CurMountID)
	end
end

function MountUI.OnSwitchBtnClick()
	--数据处理
	local sum = #MountUI.MountsConfig 
	local count = MountUI.MountIsHave or 0

	local MountPage = _gt.GetUI("MountPage")
    local Bg = GUI.ImageCreate(MountPage, "Bg", "1800400010", 120, 140, false, 250, 400)
    UILayout.SetSameAnchorAndPivot(Bg, UILayout.TopLeft)
    GUI.SetIsRaycastTarget(Bg, true)
    Bg:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRemoveWhenClick(Bg, true)
	_gt.BindName(Bg,"mountsPage")
    local titelBg = GUI.ImageCreate(Bg, "titelBg", "1800700250", 4, 4,true)
    UILayout.SetSameAnchorAndPivot(titelBg, UILayout.TopLeft)
    local titel = GUI.CreateStatic(titelBg, "titel", "我的坐骑",20, 0, 200, 50,"system", true)
    UILayout.SetSameAnchorAndPivot(titel, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(titel, UIDefine.FontSizeS, UIDefine.BrownColor)
    local mountCount = GUI.CreateStatic(titelBg, "mountCount", count.."/"..sum, 60, 1, 200, 50)
    UILayout.SetSameAnchorAndPivot(mountCount, UILayout.Right)
    UILayout.StaticSetFontSizeColorAlignment(mountCount, UIDefine.FontSizeS, UIDefine.BrownColor)
	GUI.StaticSetAlignment(mountCount, TextAnchor.MiddleCenter)
	
	local mountsScroll = GUI.LoopScrollRectCreate(Bg, "mountsScroll", 0, 15, 230, 340,
	"MountUI", "CreateMountsItem", "MountUI", "RefreshMountsScroll", 0, false, Vector2.New(240, 80), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(mountsScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(mountsScroll, Vector2.New(1, 1))
	_gt.BindName(mountsScroll, "mountsScroll")		
	
	GUI.LoopScrollRectSetTotalCount(mountsScroll, sum) 
	GUI.LoopScrollRectRefreshCells(mountsScroll)	
end


function MountUI.CreateMountsItem()
    local mountsScroll = _gt.GetUI("mountsScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(mountsScroll)
	local mountsPage = _gt.GetUI("mountsPage")
    local MountItem = GUI.ButtonCreate(mountsScroll, "MountItem" .. tostring(curCount), "1800700030", 0, 0, Transition.ColorTint, "", 330, 100, false)
	-- GUI.AddWhiteName(mountsPage,GUI.GetGuid(MountItem))
    GUI.RegisterUIEvent(MountItem, UCE.PointerClick, "MountUI", "OnMountItemClick")
	
    -- local Icon = GUI.ImageCreate(MountItem, "Icon", "1800201110", 20, 0,false,67,68)
    -- UILayout.SetSameAnchorAndPivot(Icon, UILayout.Left)
    local Name = GUI.CreateStatic(MountItem, "Name", "坐骑",30, -16, 200, 50,"system", true)
    UILayout.SetSameAnchorAndPivot(Name, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(Name, UIDefine.FontSizeL, UIDefine.BrownColor)
	GUI.StaticSetAlignment(Name, TextAnchor.MiddleLeft)

    local Grade = GUI.ImageCreate(MountItem, "Grade", "1800201110", 170, -16,true,67,68)
    UILayout.SetSameAnchorAndPivot(Grade, UILayout.Left)
	
    local Have = GUI.CreateStatic(MountItem, "Have", "",20, 16, 200, 50,"system", true)
    UILayout.SetSameAnchorAndPivot(Have, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(Have, UIDefine.FontSizeSS, UIDefine.BrownColor)
	GUI.StaticSetAlignment(Have, TextAnchor.MiddleLeft)
	
	return MountItem

end

function MountUI.RefreshMountsScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
	local item = GUI.GetByGuid(guid)
	-- local icon = GUI.GetChild(item,"Icon")
	local Grade = GUI.GetChild(item,"Grade")
	local Have = GUI.GetChild(item,"Have")
	local name = GUI.GetChild(item,"Name")
	
	index = index + 1
	local tb = MountUI.MountsConfig[index]
	for k, v in pairs(tb) do
		GUI.ImageSetImageID(Grade,UIDefine.ItemSSR[v.Grade])
		GUI.StaticSetText(name,v.Name)
		GUI.SetData(item,"MountID",k)
		if MountUI.CurMountID == tonumber(k) then
			GUI.ButtonSetImageID(item,"1800700040")
		else
			if index <= MountUI.MountIsHave then
				GUI.ButtonSetImageID(item,"1800700030")
			else
				GUI.ButtonSetImageID(item,"1800700180")		
			end
		end
		if index <= MountUI.MountIsHave then
			GUI.StaticSetText(Have,"（已拥有）")
			-- GUI.ImageSetGray(icon,false)
		else
			GUI.StaticSetText(Have,"（未拥有）")
			-- GUI.ImageSetGray(icon,true)
		end
	end

end


function MountUI.OnMountItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local id = GUI.GetData(item,"MountID")
	
	MountUI.CurMountID = tonumber(id) ~= nil and tonumber(id) or MountUI.CurMountID
	
	MountUI.getSeverMountData(true)

end

--右侧界面
function MountUI.CreateRightPage(MountPage)
	
	--属性页
    local attributeBg = GUI.ImageCreate( MountPage, "attributeBg", "1800400450", 265, -95, false, 475, 270)
    SetAnchorAndPivot(attributeBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(attributeBg,"attributeBg")
	-- GUI.SetVisible(attributeBg,false)

    local labelTxt1 = GUI.CreateStatic( attributeBg, "DesTxtlabal", "属性", 0, -106, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt1, 25);
    GUI.StaticSetAlignment(labelTxt1, TextAnchor.MiddleCenter);
    GUI.SetColor(labelTxt1, colorDark);

    local leftNarrow = GUI.ImageCreate( attributeBg, "leftNarrow", "1800800050", 33.66, 26.51)
    SetAnchorAndPivot(leftNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local rightNarrow = GUI.ImageCreate( attributeBg, "rightNarrow", "1800800060", 283.6, 26.51)
    SetAnchorAndPivot(rightNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --属性
	local attrScroll = GUI.LoopScrollRectCreate(attributeBg, "attrScroll", 0, 25, 460, 210,
	"MountUI", "CreateAttrItem", "MountUI", "RefreshAttrScroll", 0, false, Vector2.New(220, 30), 2, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(attrScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(attrScroll, Vector2.New(20, 10))
	_gt.BindName(attrScroll, "attrScroll")	
	
	--属性详细情况
    local AttrDetails = GUI.ButtonCreate(attributeBg, "AttrDetails", "1800400420", 0, 90, Transition.ColorTint,"查看详情",130,48,false)
	UILayout.SetSameAnchorAndPivot(AttrDetails, UILayout.Center)
	GUI.RegisterUIEvent(AttrDetails, UCE.PointerClick, "MountUI", "ViewAttrDetails")
	GUI.ButtonSetTextFontSize(AttrDetails, UIDefine.FontSizeM)
	GUI.ButtonSetTextColor(AttrDetails, UIDefine.BrownColor)	

    local friendshipBg = GUI.ImageCreate( attributeBg, "friendshipBg", "1800400450", 0, 140, false, 477, 150)
    SetAnchorAndPivot(friendshipBg, UIAnchor.Center, UIAroundPivot.Top)

    local friendshipBgLabal = GUI.CreateStatic( friendshipBg, "friendshipBgLabal", "好感值", 0, 31.1, 100, 40, "system", true, false);
    SetAnchorAndPivot(friendshipBgLabal, UIAnchor.Top, UIAroundPivot.Center)
    GUI.StaticSetFontSize(friendshipBgLabal, 25);
    GUI.StaticSetAlignment(friendshipBgLabal, TextAnchor.MiddleCenter);
    GUI.SetColor(friendshipBgLabal, colorDark);

    local friendshipSlider = GUI.ScrollBarCreate( friendshipBg, "friendshipSlider", "", "1800408160", "1800607190", -15, 15, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    local silderFillSize = Vector2.New(360, 30);
    GUI.ScrollBarSetFillSize(friendshipSlider, silderFillSize);
    GUI.ScrollBarSetBgSize(friendshipSlider, silderFillSize)
    SetAnchorAndPivot(friendshipSlider, UIAnchor.Center, UIAroundPivot.Left)
	_gt.BindName(friendshipSlider,"friendshipSlider")
    local friendshipSliderCurrentTxt = GUI.CreateStatic( friendshipBg, "friendshipSliderCurrentTxt", "0/0", -15, 15, 300, 44, "system", true, false);
    SetAnchorAndPivot(friendshipSliderCurrentTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(friendshipSliderCurrentTxt, 20);
    GUI.StaticSetAlignment(friendshipSliderCurrentTxt, TextAnchor.MiddleCenter)
	_gt.BindName(friendshipSliderCurrentTxt,"friendshipSliderCurrentTxt")
	
	GUI.ScrollBarSetPos(friendshipSlider,0)

	
	--增加好感按钮
	local addFriendshipBtn = GUI.ButtonCreate(friendshipBg,"addFriendshipBtn","1800402060",190,15,Transition.ColorTint,"",35,35,false,false)
    UILayout.SetSameAnchorAndPivot(addFriendshipBtn, UILayout.Center)
	GUI.RegisterUIEvent(addFriendshipBtn, UCE.PointerClick, "MountUI", "OnAddFriendshipBtnClick")

    local leftNarrow = GUI.ImageCreate( friendshipBg, "leftNarrow2", "1800800050", 33.66, 24.95)
    SetAnchorAndPivot(leftNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local rightNarrow = GUI.ImageCreate( friendshipBg, "rightNarrow2", "1800800060", 283, 24.95)
    SetAnchorAndPivot(rightNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	
	
	--好感值相关tips
    local LikePointTips = GUI.ButtonCreate(friendshipSlider, "LikePointTips", "1800702030", 0, 35, Transition.ColorTint,"",32,33,false)
	UILayout.SetSameAnchorAndPivot(LikePointTips, UILayout.Center)
	GUI.RegisterUIEvent(LikePointTips, UCE.PointerClick, "MountUI", "OnLikePointTips")
	_gt.BindName(LikePointTips,"LikePointTips")
	
	--骑乘按钮
	local rideBtn = GUI.ButtonCreate( attributeBg, "rideBtn", "1800402080", 170, 325, Transition.ColorTint, "",140,47,false)
    SetAnchorAndPivot(rideBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(rideBtn, UCE.PointerClick, "MountUI", "OnRideBtnClick")
	_gt.BindName(rideBtn,"rideBtn")
	GUI.ButtonSetShowDisable(rideBtn,false)

    local rideBtnText = GUI.CreateStatic( rideBtn, "rideBtnText", "骑乘", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(rideBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(rideBtnText, 26)
    GUI.StaticSetAlignment(rideBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(rideBtnText, true)
    GUI.SetOutLine_Color(rideBtnText, coloroutline)
    GUI.SetOutLine_Distance(rideBtnText, 1)
	_gt.BindName(rideBtnText,"rideBtnText")

	--休息按钮
	-- local restBtn = GUI.ButtonCreate( attributeBg, "restBtn", "1800402080", -20, 325, Transition.ColorTint, "",140,47,false)
    -- SetAnchorAndPivot(restBtn, UIAnchor.Center, UIAroundPivot.Center)
    -- GUI.RegisterUIEvent(restBtn, UCE.PointerClick, "MountUI", "OnRestBtnClick")
	-- _gt.BindName(restBtn,"restBtn")
	-- GUI.ButtonSetShowDisable(restBtn,false)

    -- local restBtnText = GUI.CreateStatic( restBtn, "restBtnText", "休息", 0, 0, 160, 47, "system", true)
    -- SetAnchorAndPivot(restBtnText, UIAnchor.Center, UIAroundPivot.Center)
    -- GUI.StaticSetFontSize(restBtnText, 26)
    -- GUI.StaticSetAlignment(restBtnText, TextAnchor.MiddleCenter)
    -- GUI.SetIsOutLine(restBtnText, true)
    -- GUI.SetOutLine_Color(restBtnText, coloroutline)
    -- GUI.SetOutLine_Distance(restBtnText, 1)
	
	--统御页
    local controlBg = GUI.ImageCreate( MountPage, "controlBg", "1800400450", 265, -153, false, 475.8, 155)
    SetAnchorAndPivot(controlBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(controlBg,"controlBg")
	GUI.SetVisible(controlBg,false)

    local labelTxt1 = GUI.CreateStatic( controlBg, "DesTxtlabal", "统驭宠物", 0, -50, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt1, 25);
    GUI.StaticSetAlignment(labelTxt1, TextAnchor.MiddleCenter);
    GUI.SetColor(labelTxt1, colorDark);

    local leftNarrow = GUI.ImageCreate( controlBg, "leftNarrow", "1800800050", 23, 26.51)
    SetAnchorAndPivot(leftNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local rightNarrow = GUI.ImageCreate( controlBg, "rightNarrow", "1800800060", 293, 26.51)
    SetAnchorAndPivot(rightNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)	
	
	--添加统驭宠物
	local ControlPetScroll = GUI.LoopScrollRectCreate(controlBg, "ControlPetScroll", 0, 18, 410, 85,
	"MountUI", "CreateControlPetItem", "MountUI", "RefreshControlPetScroll", 0, true, Vector2.New(80, 81), 1, UIAroundPivot.Center, UIAnchor.Center)
	UILayout.SetSameAnchorAndPivot(ControlPetScroll, UILayout.Center)
	_gt.BindName(ControlPetScroll,"ControlPetScroll")
	GUI.ScrollRectSetChildSpacing(ControlPetScroll, Vector2.New(5, 0))
	-- local petItem = ItemIcon.Create(controlBg, "petItem", 0, 18)
	-- UILayout.SetSameAnchorAndPivot(petItem,UILayout.Center)
	-- GUI.RegisterUIEvent(petItem, UCE.PointerClick, "MountUI", "SelectedControlPet")
	-- _gt.BindName(petItem,"petItem")
	
	
	-- local AddPet = GUI.ImageCreate(petItem,"AddPet","1800707060",0,1,true)
	-- UILayout.SetSameAnchorAndPivot(AddPet, UILayout.Center)
	-- GUI.SetVisible(GetMorePet,false)
	
	------skill
	--统驭相关tips
    local ReinTips = GUI.ButtonCreate(controlBg, "ReinTips", "1800702030", 205, -50, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(ReinTips, UILayout.Center)
	GUI.RegisterUIEvent(ReinTips, UCE.PointerClick, "MountUI", "OnReinTips")
	
	--技能点
    local skillPointLabal = GUI.CreateStatic( controlBg, "skillPointLabal", "拥有", -135, 440, 200, 40, "system", true, false);
    SetAnchorAndPivot(skillPointLabal, UIAnchor.Top, UIAroundPivot.Center)
    GUI.StaticSetFontSize(skillPointLabal, 23);
    GUI.StaticSetAlignment(skillPointLabal, TextAnchor.MiddleLeft);
    GUI.SetColor(skillPointLabal, colorDark)
	
	local CostBg = GUI.ImageCreate(controlBg, "CostBg", "1800700010", -90,437, false, 180, 35)
	SetAnchorAndPivot(CostBg, UIAnchor.Top, UIAroundPivot.Center)
	
	local CostIcon = GUI.ImageCreate(CostBg, "CostIcon", "1900014680", 10, -1, false, 33, 33)
	SetAnchorAndPivot(CostIcon, UIAnchor.Left , UIAroundPivot.Left )
	
    local skillPoint = GUI.CreateStatic( CostBg, "skillPoint", "0", 15, -1, 200, 40, "system", true, false);
    SetAnchorAndPivot(skillPoint, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(skillPoint, 23);
    GUI.StaticSetAlignment(skillPoint, TextAnchor.MiddleCenter);
    GUI.SetColor(skillPoint, colorwrite)
	_gt.BindName(skillPoint, "skillPoint")	
	
    local skillPointLabal = GUI.CreateStatic( controlBg, "skillPointLabal", "消耗", -135, 476, 200, 40, "system", true, false);
    SetAnchorAndPivot(skillPointLabal, UIAnchor.Top, UIAroundPivot.Center)
    GUI.StaticSetFontSize(skillPointLabal, 23);
    GUI.StaticSetAlignment(skillPointLabal, TextAnchor.MiddleLeft);
    GUI.SetColor(skillPointLabal, colorDark)
	
	local CostBg = GUI.ImageCreate(controlBg, "CostBg", "1800700010", -90,475, false, 180, 35)
	SetAnchorAndPivot(CostBg, UIAnchor.Top, UIAroundPivot.Center)
	
	local CostIcon = GUI.ImageCreate(CostBg, "CostIcon", "1900014680", 10, -1, false, 33, 33)
	SetAnchorAndPivot(CostIcon, UIAnchor.Left , UIAroundPivot.Left )

    local ConsumeSkillPoint = GUI.CreateStatic( CostBg, "ConsumeSkillPoint", "0", 15, -1, 200, 40, "system", true, false);
    SetAnchorAndPivot(ConsumeSkillPoint, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(ConsumeSkillPoint, 23);
    GUI.StaticSetAlignment(ConsumeSkillPoint, TextAnchor.MiddleCenter);
    GUI.SetColor(ConsumeSkillPoint, colorwrite)
	_gt.BindName(ConsumeSkillPoint, "ConsumeSkillPoint")

	--增加技能点
	local addSkillPointBtn = GUI.ButtonCreate(skillPointLabal,"addSkillPointBtn","1800402060",155,-38,Transition.ColorTint,"",35,35,false,false)
    UILayout.SetSameAnchorAndPivot(addSkillPointBtn, UILayout.Center)
	GUI.RegisterUIEvent(addSkillPointBtn, UCE.PointerClick, "MountUI", "OnAddSkilllPointBtnClick")	
	
	local AddPointBtn = GUI.ButtonCreate( controlBg, "AddPointBtn", "1800402080", 165, 382, Transition.ColorTint, "",148,48,false)
    SetAnchorAndPivot(AddPointBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(AddPointBtn, UCE.PointerClick, "MountUI", "OnAddPointBtnClick")
	_gt.BindName(AddPointBtn,"AddPointBtn")

    local AddPointBtnText = GUI.CreateStatic( AddPointBtn, "AddPointBtnText", "学习技能", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(AddPointBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AddPointBtnText, 24)
    GUI.StaticSetAlignment(AddPointBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(AddPointBtnText, true)
    GUI.SetOutLine_Color(AddPointBtnText, Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(AddPointBtnText, 1)
	
    local BanAddPoint = GUI.CreateStatic( controlBg, "BanAddPoint", "", 190, 382, 300, 40, "system", true, false);
    SetAnchorAndPivot(BanAddPoint, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(BanAddPoint, 24);
    GUI.StaticSetAlignment(BanAddPoint, TextAnchor.MiddleLeft);
    GUI.SetColor(BanAddPoint, UIDefine.RedColor)
	GUI.SetVisible(BanAddPoint,false)
	_gt.BindName(BanAddPoint,"BanAddPoint")

	-- local AddPointBtn = GUI.ButtonCreate(skillPointLabal,"AddPointBtn","1800402060",140,0,Transition.ColorTint,"",35,35,false,false)
    -- UILayout.SetSameAnchorAndPivot(AddPointBtn, UILayout.Center)	
	-- GUI.RegisterUIEvent(AddPointBtn, UCE.PointerClick, "MountUI", "OnAddPointBtnClick")
	
    -- local addPointOnExit = GUI.ImageCreate(controlBg, "addPointOnExit", "1800400220", -265, 110, false, GUI.GetWidth(MountPage), GUI.GetHeight(MountPage))
    -- UILayout.SetAnchorAndPivot(addPointOnExit, UIAnchor.Center, UIAroundPivot.Center)
    -- GUI.SetIsRaycastTarget(addPointOnExit, true)
	
    local controlSkillBg = GUI.ImageCreate( controlBg, "controlSkillBg", "1800400450", 0, 82, false, 477.8, 255)
    SetAnchorAndPivot(controlSkillBg, UIAnchor.Center, UIAroundPivot.Top)
	-- _gt.BindName(controlSkillBg,"controlSkillBg")	
	
    local controlSkillBgLabal = GUI.CreateStatic( controlSkillBg, "controlSkillBgLabal", "统驭技能", 0, 31.1, 100, 40, "system", true, false);
    SetAnchorAndPivot(controlSkillBgLabal, UIAnchor.Top, UIAroundPivot.Center)
    GUI.StaticSetFontSize(controlSkillBgLabal, 25);
    GUI.StaticSetAlignment(controlSkillBgLabal, TextAnchor.MiddleCenter);
    GUI.SetColor(controlSkillBgLabal, colorDark)	

    local leftNarrow = GUI.ImageCreate( controlSkillBg, "leftNarrow2", "1800800050", 23, 24.95)
    SetAnchorAndPivot(leftNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local rightNarrow = GUI.ImageCreate( controlSkillBg, "rightNarrow2", "1800800060", 293, 24.95)
    SetAnchorAndPivot(rightNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)


    -- local  skillFrame = GUI.ImageCreate( controlSkillBg, "skillFrame", "1800600160", 0, 0, false, 477.8, 280)
    -- SetAnchorAndPivot(skillFrame, UIAnchor.Center, UIAroundPivot.Center)
	-- GUI.SetVisible(skillFrame,false)
	-- _gt.BindName(skillFrame,"skillFrame")
	
	-- local addPointOnExit = GUI.ButtonCreate(skillFrame,"addPointOnExit","1800702100",210,-110,Transition.ColorTint,"",30,32,false,false)
    -- SetAnchorAndPivot(addPointOnExit, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(addPointOnExit, UCE.PointerClick, "MountUI", "OnAddPointExitBtnClick")
	GUI.SetVisible(addPointOnExit,false)
	_gt.BindName(addPointOnExit,"addPointOnExit")
	
	
	local skillScroll = GUI.LoopScrollRectCreate(controlSkillBg, "skillScroll", 0, 21, 430, 190,
	"MountUI", "CreateSkillItem", "MountUI", "RefreshSkillScroll", 0, false, Vector2.New(80, 81), 5, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(skillScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(skillScroll, Vector2.New(5, 5))
	_gt.BindName(skillScroll, "skillScroll")	
	
	
	--驯养界面
    local domesticateBg = GUI.ImageCreate( MountPage, "domesticateBg", "1800400450", 265, -110, false, 475, 240)
    SetAnchorAndPivot(domesticateBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(domesticateBg,"domesticateBg")
	-- GUI.SetVisible(attributeBg,false)

    local labelTxt1 = GUI.CreateStatic( domesticateBg, "DesTxtlabal", "驯养值", 0, -90, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt1, 25);
    GUI.StaticSetAlignment(labelTxt1, TextAnchor.MiddleCenter);
    GUI.SetColor(labelTxt1, colorDark);

    local leftNarrow = GUI.ImageCreate( domesticateBg, "leftNarrow", "1800800050", 33.66, 26.51)
    SetAnchorAndPivot(leftNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local rightNarrow = GUI.ImageCreate( domesticateBg, "rightNarrow", "1800800060", 283.6, 26.51)
    SetAnchorAndPivot(rightNarrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)	
	
	--驯养值数值条
	local domesticateSliderBg = GUI.ImageCreate(domesticateBg, "domesticateSliderBg", "1800408110", 0, -41,false,360,30)
	SetAnchorAndPivot(domesticateSliderBg, UIAnchor.Center, UIAroundPivot.Center)
	
	--驯 绿
	local domesticateSlider = GUI.ImageCreate(domesticateSliderBg, "domesticateSlider", "1800408160", 180, 0,false,180,30)
	SetAnchorAndPivot(domesticateSlider, UIAnchor.Left, UIAroundPivot.Left)
	_gt.BindName(domesticateSlider,"domesticateSlider")
	
	--野 红
	local wildSlider = GUI.ImageCreate(domesticateSliderBg, "wildSlider", "1800408120", -180, 0,false,180,30)
	SetAnchorAndPivot(wildSlider, UIAnchor.Right, UIAroundPivot.Right)
	_gt.BindName(wildSlider,"wildSlider")
	
	local middle = GUI.ImageCreate(domesticateSliderBg, "middle", "1801208391", 0, 0,false,4,30)
	SetAnchorAndPivot(middle, UIAnchor.Center, UIAroundPivot.Center)
	-- GUI.SetColor(middle,Color.New(39 / 255, 234 / 255, 39 / 255, 255 / 255))

	--驯养值tips 右侧
    local domesticateValueTips = GUI.ButtonCreate(domesticateSliderBg, "domesticateValueTips", "1900803023", 200, 0, Transition.ColorTint,"",32,33,false)
	UILayout.SetSameAnchorAndPivot(domesticateValueTips, UILayout.Center)
	GUI.SetData(domesticateValueTips,"attr_tb","DomesticatePointAttr_Max")
	GUI.SetData(domesticateValueTips,"name","温顺")
	GUI.RegisterUIEvent(domesticateValueTips, UCE.PointerClick, "MountUI", "OnDomesticateValueTips")

    local label = GUI.CreateStatic( domesticateValueTips, "label", "温顺", 0, 28, 100, 40, "system", true, false);
    SetAnchorAndPivot(label, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(label, 16);
    GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter);
    GUI.SetColor(label, colorDark)
	-- GUI.RegisterUIEvent(LikePointTips, UCE.PointerClick, "MountUI", "OnLikePointTips")
	
	--野性值tips
    local wildValueTips = GUI.ButtonCreate(domesticateSliderBg, "wildValueTips", "1900802563", -200, 0, Transition.ColorTint,"",32,33,false)
	UILayout.SetSameAnchorAndPivot(wildValueTips, UILayout.Center)
	GUI.SetData(wildValueTips,"attr_tb","DomesticatePointAttr_Min")
	GUI.SetData(wildValueTips,"name","野性")
	GUI.RegisterUIEvent(wildValueTips, UCE.PointerClick, "MountUI", "OnDomesticateValueTips")
    local label_ = GUI.CreateStatic( wildValueTips, "label_", "野性", 0, 28, 100, 40, "system", true, false);
    SetAnchorAndPivot(label_, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(label_, 16);
    GUI.StaticSetAlignment(label_, TextAnchor.MiddleCenter);
    GUI.SetColor(label_, colorDark)
	
	---
    local CurDomesticateValue = GUI.CreateStatic( domesticateSlider, "CurDomesticateValue", "0", 0, 0, 200, 40, "system", true, false);
    SetAnchorAndPivot(CurDomesticateValue, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(CurDomesticateValue, 20);
    GUI.StaticSetAlignment(CurDomesticateValue, TextAnchor.MiddleCenter);
    -- GUI.SetColor(CurDomesticateValue, colorDark)
	_gt.BindName(CurDomesticateValue,"CurDomesticateValue")

    local CurWildValue = GUI.CreateStatic( wildSlider, "CurWildValue", "0", 0, 0, 200, 40, "system", true, false);
    SetAnchorAndPivot(CurWildValue, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(CurWildValue, 20);
    GUI.StaticSetAlignment(CurWildValue, TextAnchor.MiddleCenter);
    -- GUI.SetColor(CurDomesticateValue, colorDark)
	_gt.BindName(CurWildValue,"CurWildValue")
	--活跃值相关
	local activeSliderBg = GUI.ImageCreate(domesticateBg, "activeSliderBg", "1800408110", 0, 25,false,360,30)
	SetAnchorAndPivot(activeSliderBg, UIAnchor.Center, UIAroundPivot.Center)

	--冷静 蓝
	local CalmSlider = GUI.ImageCreate(activeSliderBg, "CalmSlider", "1800408130", 180, 0,false,180,30)
	SetAnchorAndPivot(CalmSlider, UIAnchor.Left, UIAroundPivot.Left)
	_gt.BindName(CalmSlider,"CalmSlider")
	
	--激昂 黄
	local PassionateSlider = GUI.ImageCreate(activeSliderBg, "PassionateSlider", "1800408140", -180, 0,false,180,30)
	SetAnchorAndPivot(PassionateSlider, UIAnchor.Right, UIAroundPivot.Right)
	_gt.BindName(PassionateSlider,"PassionateSlider")
	
	local middle = GUI.ImageCreate(activeSliderBg, "middle", "1801208391", 0, 0,false,4,30)
	SetAnchorAndPivot(middle, UIAnchor.Center, UIAroundPivot.Center)
	-- GUI.SetColor(middle,Color.New(39 / 255, 234 / 255, 39 / 255, 255 / 255))

	--驯养值tips 右侧
    local CalmValueTips = GUI.ButtonCreate(activeSliderBg, "CalmValueTips", "1900814373", 200, 0, Transition.ColorTint,"",32,33,false)
	UILayout.SetSameAnchorAndPivot(CalmValueTips, UILayout.Center)
	GUI.SetData(CalmValueTips,"attr_tb","ActivePointAttr_Max")
	GUI.SetData(CalmValueTips,"name","冷静")
	GUI.RegisterUIEvent(CalmValueTips, UCE.PointerClick, "MountUI", "OnDomesticateValueTips")

    local label = GUI.CreateStatic( CalmValueTips, "label", "冷静", 0, 28, 100, 40, "system", true, false);
    SetAnchorAndPivot(label, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(label, 16);
    GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter);
    GUI.SetColor(label, colorDark)
	-- GUI.RegisterUIEvent(LikePointTips, UCE.PointerClick, "MountUI", "OnLikePointTips")
	
	--野性值tips
    local PassionateValueTips = GUI.ButtonCreate(activeSliderBg, "PassionateValueTips", "1900801583", -200, 0, Transition.ColorTint,"",32,33,false)
	UILayout.SetSameAnchorAndPivot(PassionateValueTips, UILayout.Center)
	GUI.SetData(PassionateValueTips,"attr_tb","ActivePointAttr_Min")
	GUI.SetData(PassionateValueTips,"name","激昂")
	GUI.RegisterUIEvent(PassionateValueTips, UCE.PointerClick, "MountUI", "OnDomesticateValueTips")
	
    local label_ = GUI.CreateStatic( PassionateValueTips, "label_", "激昂", 0, 28, 100, 40, "system", true, false);
    SetAnchorAndPivot(label_, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(label_, 16);
    GUI.StaticSetAlignment(label_, TextAnchor.MiddleCenter);
    GUI.SetColor(label_, colorDark)
	
    local CurPassionateValue = GUI.CreateStatic( PassionateSlider, "CurPassionateValue", "0", 0, 0, 200, 40, "system", true, false);
    SetAnchorAndPivot(CurPassionateValue, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(CurPassionateValue, 20);
    GUI.StaticSetAlignment(CurPassionateValue, TextAnchor.MiddleCenter);
	_gt.BindName(CurPassionateValue,"CurPassionateValue")

    local CurCalmValue = GUI.CreateStatic( CalmSlider, "CurCalmValue", "0", 0, 0, 200, 40, "system", true, false);
    SetAnchorAndPivot(CurCalmValue, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(CurCalmValue, 20);
    GUI.StaticSetAlignment(CurCalmValue, TextAnchor.MiddleCenter);
	_gt.BindName(CurCalmValue,"CurCalmValue")
	
    local CurDomesticateAttr = GUI.CreateStatic( domesticateBg, "CurDomesticateAttr", "当前属性加成：", 0, 90, 400, 24, "system", true, false);
    SetAnchorAndPivot(CurDomesticateAttr, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(CurDomesticateAttr, 20);
    GUI.StaticSetAlignment(CurDomesticateAttr, TextAnchor.MiddleCenter);
    GUI.SetColor(CurDomesticateAttr, colorDark)
	_gt.BindName(CurDomesticateAttr,"CurDomesticateAttr")

	--驯养相关道具
    local domesticateItemBg = GUI.ImageCreate( domesticateBg, "domesticateItemBg", "1800400450", -120, 245, false, 235, 240)
    SetAnchorAndPivot(domesticateItemBg, UIAnchor.Center, UIAroundPivot.Center)	 


	local DomesticateScroll = GUI.LoopScrollRectCreate(domesticateItemBg, "DomesticateScroll", 0, -3, 210, 200,
	"MountUI", "CreateDomesticateItem", "MountUI", "RefreshDomesticateScroll", 0, false, Vector2.New(67, 67), 3, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(DomesticateScroll, UILayout.Center)
	_gt.BindName(DomesticateScroll, "DomesticateScroll")
	GUI.ScrollRectSetChildSpacing(DomesticateScroll, Vector2.New(3, 10))	
	
	--道具说明
    local domesticateItemDesBg = GUI.ImageCreate( domesticateBg, "domesticateItemDesBg", "1800400450", 120, 245, false, 235, 240)
    SetAnchorAndPivot(domesticateItemDesBg, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(domesticateItemDesBg,"domesticateItemDes")

	local Item = GUI.ItemCtrlCreate(domesticateItemDesBg, "Item", "1800400050", -60, -70, 76, 76)
	SetAnchorAndPivot(Item, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "MountUI", "OnDomesticateItemDesTips")

    local Name = GUI.CreateStatic( domesticateItemDesBg, "Name", "", 43, -70, 140, 50, "system", true, false);
    SetAnchorAndPivot(Name, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Name, 22);
    GUI.StaticSetAlignment(Name, TextAnchor.MiddleCenter);
    GUI.SetColor(Name, colorDark)

	local InfoWnd = GUI.ScrollRectCreate(domesticateItemDesBg, "InfoWnd", 0, 15, 210, 75, 0, false, Vector2.New(210,160), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    SetAnchorAndPivot(InfoWnd, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(InfoWnd,"DomesticateInfoWnd")

	local InfoText = GUI.CreateStatic(InfoWnd,"InfoText","",0,0,0,0)
	GUI.SetColor(InfoText, colorDark)
	GUI.StaticSetFontSize(InfoText, 22)
	GUI.StaticSetAlignment(InfoText, TextAnchor.UpperLeft)

	--按钮
	local domesticateItemUseBtn = GUI.ButtonCreate(domesticateItemDesBg,"domesticateItemUseBtn","1800402110",125,190,Transition.ColorTint,"使用",100,38,false)
	SetAnchorAndPivot(domesticateItemUseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(domesticateItemUseBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(domesticateItemUseBtn, 20)
	GUI.RegisterUIEvent(domesticateItemUseBtn, UCE.PointerClick, "MountUI", "OnDomesticateItemUseBtnClick")
	_gt.BindName(domesticateItemUseBtn,"domesticateItemUseBtn")
	-- GUI.SetData(domesticateItemUseBtn,"times",1)
	domesticateItemUseBtn:RegisterEvent(UCE.PointerDown )
	domesticateItemUseBtn:RegisterEvent(UCE.PointerUp )
	GUI.RegisterUIEvent(domesticateItemUseBtn, UCE.PointerDown, "MountUI", "OnDomesticateItemUseDown")
	GUI.RegisterUIEvent(domesticateItemUseBtn, UCE.PointerUp, "MountUI", "OnDomesticateItemUp")
	
	-- local domesticateItem10UseBtn = GUI.ButtonCreate(domesticateItemDesBg,"domesticateItem10UseBtn","1800402110",10,190,Transition.ColorTint,"使用十次",100,38,false)
	-- SetAnchorAndPivot(domesticateItem10UseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	-- GUI.ButtonSetTextColor(domesticateItem10UseBtn, UIDefine.BrownColor);
	-- GUI.ButtonSetTextFontSize(domesticateItem10UseBtn, 20)
	-- GUI.RegisterUIEvent(domesticateItem10UseBtn, UCE.PointerClick, "MountUI", "OnDomesticateItemUseBtnClick")
	-- _gt.BindName(domesticateItem10UseBtn,"domesticateItem10UseBtn")
	-- GUI.SetData(domesticateItem10UseBtn,"times",10)
end

function MountUI.OnDomesticateItemUseDown()
	if not MountUI.DomesticateItemTimer then
		MountUI.DomesticateItemTimer = Timer.New(MountUI.FuncUseDomesticateItem,0.2,-1)
	end
	MountUI.DomesticateQuickUse = "on"
	MountUI.DomesticateQuickUseFlage = 0
	MountUI.DomesticateItemTimer:Start()
end

function MountUI.OnDomesticateItemUp()
	MountUI.DomesticateQuickUse = "false"
	if MountUI.DomesticateItemTimer then
		MountUI.DomesticateItemTimer:Stop()
		MountUI.DomesticateItemTimer:Reset(MountUI.FuncUseDomesticateItem,0.2,-1)
	end
	MountUI.DomesticateQuickUseFlage = 0
end

function MountUI.FuncUseDomesticateItem()
	if MountUI.DomesticateQuickUse and MountUI.DomesticateQuickUse == "on" and MountUI.DomesticateQuickUseFlage == 1 then
		MountUI.OnDomesticateItemUseBtnClick()
	end
	MountUI.DomesticateQuickUseFlage = 1
end

function MountUI.OnAddSkilllPointBtnClick()
	--没有该坐骑不让打开
	if not MountUI.HaveMount or MountUI.HaveMount ~= 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得该坐骑")
		return
	end
	local Bg = _gt.GetUI("addSkillPointPage")
	local skillPointScroll = _gt.GetUI("skillPointScroll")
	if not Bg then
		local ControlPage = _gt.GetUI("controlBg")
		Bg = GUI.ImageCreate(ControlPage, "Bg", "1800400300", 0, 80, false, 320, 280)
		GUI.SetIsRaycastTarget(Bg, true)
		SetAnchorAndPivot(Bg, UIAnchor.Center, UIAroundPivot.Center)
		_gt.BindName(Bg,"addSkillPointPage")

		local Bg2 = GUI.ImageCreate(Bg, "Bg2", "1800400200", 0, -15, false, 260, 200)
		SetAnchorAndPivot(Bg2, UIAnchor.Center, UIAroundPivot.Center)
		
		local closeBtn = GUI.ButtonCreate(Bg, "closeBtn", "1800302120", -23, 22, Transition.ColorTint)
		SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.Center)
		GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "MountUI", "OnAddSkillPointClose")
	
		local useBtn = GUI.ButtonCreate( Bg, "useBtn", "1800402110", 90, 110, Transition.ColorTint, "使用", 80, 40, false);
		SetAnchorAndPivot(useBtn, UIAnchor.Center, UIAroundPivot.Center)
		GUI.ButtonSetTextFontSize(useBtn, 20)
		GUI.ButtonSetTextColor(useBtn, colorDark)
		GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "MountUI", "OnUseSkillPointItem");

		local addSum = GUI.CreateStatic( Bg, "addSum", "已选择：+0", -30,110, 200, 50, "system", true, false);
		SetAnchorAndPivot(addSum, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(addSum, 20);
		GUI.StaticSetAlignment(addSum, TextAnchor.MiddleLeft)
		GUI.SetColor(addSum, colorDark)	
		_gt.BindName(addSum,"addSum")		
		
		skillPointScroll = GUI.LoopScrollRectCreate(Bg, "skillPointScroll", 0, -10, 260, 170,
		"MountUI", "CreateSkillPointItem", "MountUI", "RefreshSkillPointScroll", 0, false, Vector2.New(80, 81), 3, UIAroundPivot.Top, UIAnchor.Top);
		UILayout.SetSameAnchorAndPivot(skillPointScroll, UILayout.Center)
		_gt.BindName(skillPointScroll, "skillPointScroll")
	end
	
	
	MountUI.CurSkillPointItem = nil
	MountUI.UseSkillPointItemList = {}
	
	GUI.LoopScrollRectSetTotalCount(skillPointScroll, math.max(#MountUI.LikePointItemList,6)) 
	GUI.LoopScrollRectRefreshCells(skillPointScroll)
	
	GUI.SetVisible(Bg,true)
end

function MountUI.OnAddSkillPointClose()
	local addSkillPointPage = _gt.GetUI("addSkillPointPage")
	GUI.SetVisible(addSkillPointPage,false)
	MountUI.CurSkillPointItem = nil
	MountUI.UseSkillPointItemList = {}
	MountUI.SetSkillPointAddSumm()
end

function MountUI.CreateSkillPointItem()
	local skillPointScroll = _gt.GetUI("skillPointScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(skillPointScroll)
	local Item = ItemIcon.Create(Bg2, "SkillPointItem"..curCount, 0, 0)
	UILayout.SetSameAnchorAndPivot(Item,UILayout.Center)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "MountUI", "OnSkillPointItemClick")
	local select_ = GUI.ImageCreate(Item, "select_", "1800707330", 0,-1, false, 80, 81)
    SetAnchorAndPivot(select_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(select_,false)

	local CutDownBtn = GUI.ButtonCreate(Item,"CutDownBtn","1800402140",24,-24,Transition.ColorTint,"",35,35,false,false)
    UILayout.SetSameAnchorAndPivot(CutDownBtn, UILayout.Center)	
	GUI.RegisterUIEvent(CutDownBtn, UCE.PointerClick, "MountUI", "OnSkillPointCutDown")
	GUI.SetVisible(CutDownBtn,false)
	
	return Item	
end

function MountUI.RefreshSkillPointScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	local select_ = GUI.GetChild(Item,"select_")
	local CutDownBtn = GUI.GetChild(Item,"CutDownBtn")
	index = index +1 
	
	if index <= #MountUI.SkillPointItemList then
		local tb = MountUI.SkillPointItemList[index]
		local ItemDB = DB.GetOnceItemByKey2(tb.keyname)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(ItemDB.Icon))
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,UIDefine.ItemIconBg[ItemDB.Grade])
		GUI.SetData(Item,"keyname",tb.keyname)
		GUI.SetData(Item,"bind",tb.bind)
		GUI.SetData(Item,"ItemId",ItemDB.Id)
		
		if tb.num ~=0 then
			GUI.SetData(Item,"limit",tb.num)
			local num0 = MountUI.UseSkillPointItemList[tb.keyname.."_"..tb.bind] or 0
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,num0.."/"..tb.num)
			GUI.ItemCtrlSetIconGray(Item,false)
			if num0 > 0 then
				--减少按钮出现
				GUI.SetVisible(CutDownBtn,true)
			else
				GUI.SetVisible(CutDownBtn,false)
			end
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,tb.bind == 1 and "1800707120" or nil)
		else
			GUI.SetVisible(CutDownBtn,false)
			GUI.ItemCtrlSetIconGray(Item,true)
			GUI.SetData(Item,"limit",nil)
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,"")
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp, nil)
		end
	
		if MountUI.CurSkillPointItem and MountUI.CurSkillPointItem == tb.keyname..tb.bind then
			GUI.SetVisible(select_,true)
		else
			GUI.SetVisible(select_,false)
		end
	else
		GUI.SetVisible(CutDownBtn,false)
		ItemIcon.SetEmpty(Item)
		GUI.SetVisible(select_,false)
		GUI.SetData(Item,"keyname",nil)
		GUI.SetData(Item,"bind",nil)
		GUI.SetData(Item,"limit",nil)
	end

end

--使用技能点道具
function MountUI.OnUseSkillPointItem()
	if next(MountUI.UseSkillPointItemList) then
		local item_list = ""
		for k ,v in pairs(MountUI.UseSkillPointItemList) do
			local tb = string.split(k,"_")
			item_list = item_list..tb[1].."_"..v.."_"..tb[2].."_"
		end
		CL.SendNotify(NOTIFY.SubmitForm, "FormMount","AddSkillPoint",item_list,GlobalProcessing.MountsVersion)
	end

end

--减少技能点道具
function MountUI.OnSkillPointCutDown(guid)
	local item = GUI.GetParentElement(GUI.GetByGuid(guid))
	local keyname = GUI.GetData(item,"keyname")
	local bind = GUI.GetData(item,"bind")
	MountUI.UseSkillPointItemList[keyname.."_"..bind] = math.max(MountUI.UseSkillPointItemList[keyname.."_"..bind] - 1 ,0)
	local skillPointScroll = _gt.GetUI("skillPointScroll")
	GUI.LoopScrollRectRefreshCells(skillPointScroll)
	-- MountUI.PreviewLikePointSlider()	
	MountUI.SetSkillPointAddSumm()
end

function MountUI.OnSkillPointItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local keyname = GUI.GetData(item,"keyname")
	local bind = GUI.GetData(item,"bind")
	
	if keyname and  keyname ~= "" then
		MountUI.CurSkillPointItem = keyname..bind
		local limit = GUI.GetData(item,"limit")
		if limit and limit ~= "" then
			if MountUI.UseSkillPointItemList[keyname.."_"..bind] then
				MountUI.UseSkillPointItemList[keyname.."_"..bind] = math.min(MountUI.UseSkillPointItemList[keyname.."_"..bind] + 1 ,tonumber(limit))
			else
				MountUI.UseSkillPointItemList[keyname.."_"..bind]  = 1
			end
			-- MountUI.PreviewLikePointSlider()
			MountUI.SetSkillPointAddSumm()
		end
		--tips
		local itemId = GUI.GetData(item,"ItemId")
		local parent = _gt.GetUI("addSkillPointPage")
		local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -380, -70, 62)  --创造提示
		GUI.SetData(itemtips, "ItemId", tostring(itemId))
		_gt.BindName(itemtips,"SkillPointItemTips")
		local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
		GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
		GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
		GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"MountUI","OnClickSkillPointItemWayBtn")
		GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
		
		local skillPointScroll = _gt.GetUI("skillPointScroll")
		GUI.LoopScrollRectRefreshCells(skillPointScroll)
		
	end
end


function MountUI.SetSkillPointAddSumm()
	local addSum = _gt.GetUI("addSum")
	local num = 0
	if next(MountUI.UseSkillPointItemList) then
		for k , v in pairs(MountUI.UseSkillPointItemList) do
			local tb = string.split(k,"_")
			local value = tonumber(GlobalProcessing.MountsSkillPointItem[tb[1]].addpoint)
			num = num + value * tonumber(v)
		end
	end
	GUI.StaticSetText(addSum,"已选择：+"..num)
end

function MountUI.OnClickSkillPointItemWayBtn()
	local tips = _gt.GetUI("SkillPointItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end


function MountUI.OnDomesticateItemDesTips(guid)
	local itemId = GUI.GetData(GUI.GetByGuid(guid),"ItemId")
	if tonumber(itemId) then
		local parent = _gt.GetUI("domesticateItemDes")
		local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -400, -200, 50)  --创造提示
		GUI.SetData(itemtips, "ItemId", tostring(itemId))
		_gt.BindName(itemtips,"DomesticateItemTips")
		local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
		GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
		GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
		GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"MountUI","OnClickDomesticateItemWayBtn")
		GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
	end
end

function MountUI.OnClickDomesticateItemWayBtn()
	local tips = _gt.GetUI("DomesticateItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

--使用驯养值道具
function MountUI.OnDomesticateItemUseBtnClick(guid)
	-- local times = tonumber(GUI.GetData(GUI.GetByGuid(guid),"times"))
	local tb = MountUI.DomesticateItemList[MountUI.DomesticateItemIndex]
	if tb.item_guid then
		CL.SendNotify(NOTIFY.SubmitForm, "FormMount","AddDomesticatePoint",MountUI.CurMountID,tostring(tb.item_guid),1,GlobalProcessing.MountsVersion)
	else
		local itemDB = DB.GetOnceItemByKey2(tb.keyname)
		if tonumber(itemDB.Id) then
			local itemtips = _gt.GetUI("DomesticateItemTips")
			if not itemtips then
				local parent = _gt.GetUI("domesticateItemDes")
				itemtips =  Tips.CreateByItemId(itemDB.Id,parent, "itemtips", -400, -200, 50)  --创造提示
				GUI.SetData(itemtips, "ItemId", tostring(itemDB.Id))
				_gt.BindName(itemtips,"DomesticateItemTips")
				local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
				UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
				GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
				GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
				GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"MountUI","OnClickDomesticateItemWayBtn")
				GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
			end
		end
	end
end


function MountUI.CreateDomesticateItem()
	local DomesticateScroll = _gt.GetUI("DomesticateScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(DomesticateScroll);
	local DomesticateItem = GUI.ItemCtrlCreate(DomesticateScroll, "DomesticateItem" .. curCount, "1800400050", 0, 0, 89, 89)
	GUI.RegisterUIEvent(DomesticateItem, UCE.PointerClick, "MountUI", "OnDomesticateItemClick")
	local select_ = GUI.ImageCreate(DomesticateItem, "select_", "1800400280", 0,-1, false, 74, 74)
    SetAnchorAndPivot(select_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(select_,false) 
	return DomesticateItem
end

-- 刷新Item项
function MountUI.RefreshDomesticateScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid);
	local index = index+1
	local select_ = GUI.GetChild(Item,"select_")
	if index <= #MountUI.DomesticateItemList then
		local tb = MountUI.DomesticateItemList[index]
		local itemDB = DB.GetOnceItemByKey2(tb.keyname)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(itemDB.Icon))
		GUI.ItemCtrlSetElementRect(Item, eItemIconElement.Icon, 0, 0,60,61)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,UIDefine.ItemIconBg[itemDB.Grade])
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,tb.num)
		GUI.ItemCtrlSetIconGray(Item,tb.num == 0)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,tb.bind == 1 and "1800707120" or nil)
		GUI.SetData(Item,"index",index)
		-- 是否选择
		if index == MountUI.DomesticateItemIndex then
			GUI.SetVisible(select_,true)
			MountUI.DomesticateItemGuid = guid
		else
			GUI.SetVisible(select_,false)
		end
	else
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,nil)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,"1800400050")	
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,nil)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,nil)
		GUI.SetData(Item,"index","")
		GUI.SetVisible(select_,false)
	end
end


function MountUI.OnDomesticateItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local index = tonumber(GUI.GetData(item,"index"))
	if index then
		local select_  = GUI.GetChild(item,"select_")
		GUI.SetVisible(select_,true)
		if MountUI.DomesticateItemGuid and MountUI.DomesticateItemGuid ~= guid then
			local select_last  = GUI.GetChild(GUI.GetByGuid(MountUI.DomesticateItemGuid),"select_")
			GUI.SetVisible(select_last,false)
		end
		MountUI.DomesticateItemGuid = guid
		MountUI.DomesticateItemIndex = index
		
		--滑动框回弹
		local InfoWnd = _gt.GetUI("DomesticateInfoWnd")
		GUI.ScrollRectSetNormalizedPosition(InfoWnd, Vector2.New(0, 1))
		--刷新道具信息
		MountUI.RefreshDomesticateInfo()
	end
end

function MountUI.RefreshDomesticateInfo()
	local tb = MountUI.DomesticateItemList[MountUI.DomesticateItemIndex]
	local itemDB = DB.GetOnceItemByKey2(tb.keyname)
	local Bg = _gt.GetUI("domesticateItemDes")
	local item = GUI.GetChild(Bg,"Item")
	local name = GUI.GetChild(Bg,"Name")
	local info = GUI.GetChild(Bg,"InfoText")
	GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,tostring(itemDB.Icon))
	-- GUI.ItemCtrlSetElementRect(Item, eItemIconElement.Icon, 0, 0,60,61)
	GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,UIDefine.ItemIconBg[itemDB.Grade])
	GUI.StaticSetText(name,itemDB.Name)
	GUI.StaticSetText(info,itemDB.Info)
	
	GUI.SetData(item,"ItemId",itemDB.Id)
	
	--相关按钮
	-- tb.num
	-- local UseBtn = _gt.GetUI("domesticateItemUseBtn")
	-- local Use10Btn = _gt.GetUI("domesticateItem10UseBtn")
	
	-- if not MountUI.HaveMount or MountUI.HaveMount ~= 1 then
		-- GUI.ButtonSetShowDisable(UseBtn,false)
		-- GUI.ButtonSetShowDisable(Use10Btn,false)		
	-- else
		-- if tb.num >= 10 then
			-- GUI.ButtonSetShowDisable(UseBtn,true)
			-- GUI.ButtonSetShowDisable(Use10Btn,true)
		-- elseif tb.num >= 1 then
			-- GUI.ButtonSetShowDisable(UseBtn,true)
			-- GUI.ButtonSetShowDisable(Use10Btn,false)	
		-- else
			-- GUI.ButtonSetShowDisable(UseBtn,false)
			-- GUI.ButtonSetShowDisable(Use10Btn,false)	
		-- end
	-- end
end

function MountUI.OnLikePointTips()
	local attributeBg = _gt.GetUI("attributeBg")
	local tips = GUI.TipsCreate(attributeBg,"LikePointTips",-250,40,400,-44)
	tips:RegisterEvent(UCE.PointerClick)
	GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
	
    -- local Labal = GUI.CreateStatic( tips, "Labal", GlobalProcessing.MountsLikePointTips, 0, 160, 350, 350, "system", true, false);
    -- SetAnchorAndPivot(Labal, UIAnchor.Top, UIAroundPivot.Center)
    -- GUI.StaticSetFontSize(Labal, 25);
    -- GUI.StaticSetAlignment(Labal, TextAnchor.MiddleLeft);
    -- GUI.SetColor(Labal, colorwrite)	

	local tb = MountUI.LikePointTipsList
	-- for k,v in pairs(tb) do
		-- table.insert(temp,k)
	-- end
	GUI.TipsAddLabel(tips,75,"好感值达到"..tb.LikePoint.."时可提供：",UIDefine.GreenStdColor,true)
	for k ,v in pairs(tb.Attr) do
		local AttrDB = DB.GetOnceAttrByKey2(k)
		local value = v
		
		if k == "移动速度" then
			value = math.floor((0-value)/0.6).."%"
		end
		local Lable = GUI.TipsAddLabel(tips,90,AttrDB.ChinaName,UIDefine.GreenStdColor ,true)
		local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", value, 50, 0, 100, 40, "system", true, false);
		SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(ValueLabal, 22)
		GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleCenter)
		GUI.SetColor(ValueLabal, UIDefine.GreenStdColor)	
	end
	
	local Lable = GUI.TipsAddLabel(tips,90,"默契值加成",UIDefine.GreenStdColor ,true)
	local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", tb.TacitAdd, 50, 0, 100, 40, "system", true, false);
	SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetFontSize(ValueLabal, 22)
	GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleCenter)
	GUI.SetColor(ValueLabal, UIDefine.GreenStdColor)		
	
	GUI.SetVisible(GUI.GetChild(tips,"CutLine"),false)
	
	GUI.TipsAddCutLine(tips)
	
	
	GUI.TipsAddLabel(tips,20,GlobalProcessing.MountsLikePointTips,colorwrite,true)
	GUI.SetPositionY(GUI.GetChild(tips,"InfoScr"),45)
end

function MountUI.OnReinTips()
	local controlBg = _gt.GetUI("controlBg")

	local tips = GUI.TipsCreate(controlBg,"ReinTips",-250,40,400,-50)
	tips:RegisterEvent(UCE.PointerClick)
	GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
	
	
	GUI.TipsAddLabel(tips,20,GlobalProcessing.MountsReinTips,colorwrite,true)
	
	GUI.SetPositionY(GUI.GetChild(tips,"InfoScr"),45)
	
	GUI.SetVisible(GUI.GetChild(tips,"CutLine"),false)
	
    -- local Labal = GUI.CreateStatic( tips, "Labal", GlobalProcessing.MountsReinTips, 0, 210, 350, 400, "system", true, false);
    -- SetAnchorAndPivot(Labal, UIAnchor.Top, UIAroundPivot.Center)
    -- GUI.StaticSetFontSize(Labal, 25);
    -- GUI.StaticSetAlignment(Labal, TextAnchor.MiddleLeft);
    -- GUI.SetColor(Labal, colorwrite)		
	


end


function MountUI.ViewAttrDetails()
	local attributeBg = _gt.GetUI("attributeBg")
	local tips = GUI.TipsCreate(attributeBg,"AttrDetailsTips",-250,40,400,-56)
	tips:RegisterEvent(UCE.PointerClick)
	GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
	_gt.BindName(tips,"AttrDetailsTips")
	GUI.SetVisible(tips,false)
	
    -- local Labal = GUI.CreateStatic( tips, "Labal", "属性详情", 0, -110, 100, 40, "system", true, false);
    -- SetAnchorAndPivot(Labal, UIAnchor.Center, UIAroundPivot.Center)
    -- GUI.StaticSetFontSize(Labal, 25)
    -- GUI.StaticSetAlignment(Labal, TextAnchor.MiddleCenter)
    -- GUI.SetColor(Labal, colorwrite)	
	

	
	CL.SendNotify(NOTIFY.SubmitForm, "FormMount","GetDetailedAttr",MountUI.CurMountID)
end

function MountUI.RfreshAttrrDetails()
	local tips = _gt.GetUI("AttrDetailsTips")
	GUI.SetVisible(tips,true)
	
	local temp = {}
	local tb = MountUI.DetailedAttrList["基础属性"]
	for k,v in pairs(tb) do
		table.insert(temp,k)
	end
	table.sort(temp,function(a,b)return (tonumber(a) <  tonumber(b)) end)
	
	GUI.TipsAddLabel(tips,150,"基础属性",UIDefine.YellowStdColor,true)
	for i = 1 , #temp do
		local AttrDB = DB.GetOnceAttrByKey1(temp[i])
		local value = tb[temp[i]]
		-- local white = "                    "
		if temp[i] == 52 then
			value = math.floor((0-value)/0.6).."%"
			-- white = "              "	
		end
		local Lable = GUI.TipsAddLabel(tips,80,AttrDB.ChinaName,UIDefine.YellowStdColor,true)
		local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", value, 60, 0, 100, 40, "system", true, false);
		SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(ValueLabal, 22)
		GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleCenter)
		GUI.SetColor(ValueLabal, UIDefine.YellowStdColor)	
	end
	
	GUI.SetVisible(GUI.GetChild(tips,"CutLine"),false)
	
	local temp = {}
	local tb = MountUI.DetailedAttrList["好感值属性"] or {}
	for k,v in pairs(tb) do
		table.insert(temp,k)
	end
	if #temp > 0 then
		GUI.TipsAddCutLine(tips)
		GUI.TipsAddLabel(tips,140,"好感值属性",UIDefine.GreenStdColor,true)
		table.sort(temp,function(a,b)return (tonumber(a) <  tonumber(b)) end)
		for i = 1 , #temp do
			local AttrDB = DB.GetOnceAttrByKey1(temp[i])
			local value = tb[temp[i]]
			-- local white = "                    "
			if temp[i] == 52 then
				value = math.floor((0-value)/0.6).."%"
				-- white = "             "
			end
			local Lable = GUI.TipsAddLabel(tips,80,AttrDB.ChinaName,UIDefine.GreenStdColor ,true)
			local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", value, 60, 0, 100, 40, "system", true, false);
			SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
			GUI.StaticSetFontSize(ValueLabal, 22)
			GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleCenter)
			GUI.SetColor(ValueLabal, UIDefine.GreenStdColor)	
		end
	end

	local temp = {}
	local tb = MountUI.DetailedAttrList["驯养值属性"] or {}
	for k,v in pairs(tb) do
		table.insert(temp,k)
	end
	if #temp > 0 then
		GUI.TipsAddCutLine(tips)
		GUI.TipsAddLabel(tips,140,"驯养值属性",UIDefine.BlueColor,true)
		table.sort(temp,function(a,b)return (tonumber(a) <  tonumber(b)) end)
		for i = 1 , #temp do
			local AttrDB = DB.GetOnceAttrByKey1(temp[i])
			local value = tb[temp[i]]
			-- local white = "                    "
			if temp[i] == 52 then
				value = math.floor((0-value)/0.6).."%"
				-- white = "             "
			end
			local Lable = GUI.TipsAddLabel(tips,80,AttrDB.ChinaName,UIDefine.BlueColor,true)
			local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", value, 60, 0, 100, 40, "system", true, false);
			SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
			GUI.StaticSetFontSize(ValueLabal, 22)
			GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleCenter)
			GUI.SetColor(ValueLabal, UIDefine.BlueColor)	
		end
	end
	GUI.SetPositionY(GUI.GetChild(tips,"InfoScr"),40)
end



--当点击骑乘按钮
function MountUI.OnRideBtnClick()
	if MountUI.IsRide and MountUI.IsRide == 1 then
		CL.SendNotify(NOTIFY.SubmitForm, "FormMount","AlightFormMount",GlobalProcessing.MountsVersion)
	else
		CL.SendNotify(NOTIFY.SubmitForm, "FormMount","RideOnMount", MountUI.CurMountID,GlobalProcessing.MountsVersion)
	end
end

--当点击休息按钮
-- function MountUI.OnRestBtnClick()
	-- CL.SendNotify(NOTIFY.SubmitForm, "FormMount","AlightFormMount")
-- end

--属性
function MountUI.CreateAttrItem()
	local attrScroll = _gt.GetUI("attrScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(attrScroll)
	local AttrItem = GUI.GroupCreate(attrScroll, "AttrItem", 0, 0, 0, 0)

    local AttrName = GUI.CreateStatic( AttrItem, "AttrName", "属性名称", -10, 0, 100, 40, "system", true, false);
    SetAnchorAndPivot(AttrName, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrName, 22);
    GUI.StaticSetAlignment(AttrName, TextAnchor.MiddleLeft);
    GUI.SetColor(AttrName, colorDark)
	
    local AttrValue = GUI.CreateStatic( AttrItem, "AttrValue", "0", 70, 0, 180, 40, "system", true, false);
    SetAnchorAndPivot(AttrValue, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrValue, 22);
    GUI.StaticSetAlignment(AttrValue, TextAnchor.MiddleCenter)
    GUI.SetColor(AttrValue, yellowTextColor)
	

	local AttrIcon = GUI.ImageCreate(AttrItem, "AttrIcon", "", -80,0, true, 80, 81)
    SetAnchorAndPivot(AttrIcon, UIAnchor.Center, UIAroundPivot.Center)		
	
	return AttrItem
end

function MountUI.RefreshAttrScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local AttrItem = GUI.GetByGuid(guid)
	local AttrName = GUI.GetChild(AttrItem,"AttrName")
	local AttrValue = GUI.GetChild(AttrItem,"AttrValue")
	local AttrIcon = GUI.GetChild(AttrItem,"AttrIcon")
	index = index +1 
	
	local tb = MountUI.AttrListOrder[index]
	local AttrDB = DB.GetOnceAttrByKey1(tb.id)
	GUI.StaticSetText(AttrName,AttrDB.ChinaName)
	
	local value = tb.value 
	if AttrDB.IsPct == 1 then
		value = tostring(tonumber(string.format("%.2f", tonumber(value)/100))).."%"
	end
	GUI.StaticSetText(AttrValue,value)
	
	if MountUI.AttrClientList[AttrDB.ChinaName] then
		GUI.ImageSetImageID(AttrIcon,MountUI.AttrClientList[AttrDB.ChinaName])
	else
		GUI.ImageSetImageID(AttrIcon,"1800407030")
	end
end

--好感值界面
function MountUI.OnAddFriendshipBtnClick()
	--没有该坐骑不让打开
	if not MountUI.HaveMount or MountUI.HaveMount ~= 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得该坐骑")
		return
	end
	local Bg = _gt.GetUI("likePointPage")
	local likePointScroll = _gt.GetUI("likePointScroll")
	if not Bg then
		local AttributePage = _gt.GetUI("attributeBg")
		Bg = GUI.ImageCreate(AttributePage, "Bg", "1800400300", 0, 80, false, 320, 280)
		SetAnchorAndPivot(Bg, UIAnchor.Center, UIAroundPivot.Center)
		-- GUI.SetIsRaycastTarget(Bg, true)
		-- Bg:RegisterEvent(UCE.PointerClick)
		-- GUI.SetIsRemoveWhenClick(Bg, true)
		_gt.BindName(Bg,"likePointPage")
		-- GUI.RegisterUIEvent(Bg, UCE.PointerClick, "MountUI", "OnAddPointClose")
		
		local Bg2 = GUI.ImageCreate(Bg, "Bg2", "1800400200", 0, -15, false, 260, 200)
		SetAnchorAndPivot(Bg2, UIAnchor.Center, UIAroundPivot.Center)
		

		local closeBtn = GUI.ButtonCreate(Bg, "closeBtn", "1800302120", -23, 22, Transition.ColorTint)
		SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.Center)
		GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "MountUI", "OnAddPointClose")
	
		local useBtn = GUI.ButtonCreate( Bg, "useBtn", "1800402110", 0, 110, Transition.ColorTint, "使用", 80, 40, false);
		SetAnchorAndPivot(useBtn, UIAnchor.Center, UIAroundPivot.Center)
		GUI.ButtonSetTextFontSize(useBtn, 18)
		GUI.ButtonSetTextColor(useBtn, colorDark)
		GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "MountUI", "OnUseLikePointItem");
		
		
		
		likePointScroll = GUI.LoopScrollRectCreate(Bg, "likePointScroll", 0, -10, 260, 170,
		"MountUI", "CreateLikePointItem", "MountUI", "RefreshLikePointScroll", 0, false, Vector2.New(80, 81), 3, UIAroundPivot.Top, UIAnchor.Top);
		UILayout.SetSameAnchorAndPivot(likePointScroll, UILayout.Center)
		-- GUI.ScrollRectSetChildSpacing(likePointScroll, Vector2.New(10, 10))
		_gt.BindName(likePointScroll, "likePointScroll")
	end
	
	
	MountUI.CurLikePointItem = nil
	MountUI.UseItemList = {}
	
	GUI.LoopScrollRectSetTotalCount(likePointScroll, math.max(#MountUI.LikePointItemList,6)) 
	GUI.LoopScrollRectRefreshCells(likePointScroll)
	
	GUI.SetVisible(Bg,true)
end

function MountUI.OnAddPointClose()
	local likePointPage = _gt.GetUI("likePointPage")
	GUI.SetVisible(likePointPage,false)
	MountUI.CurLikePointItem = nil
	MountUI.UseItemList = {}
	MountUI.PreviewLikePointSlider()
end

function MountUI.CreateLikePointItem()
	local likePointScroll = _gt.GetUI("likePointScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(likePointScroll)
	local Item = ItemIcon.Create(Bg2, "LikePointItem"..curCount, 0, 0)
	UILayout.SetSameAnchorAndPivot(Item,UILayout.Center)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "MountUI", "OnLikePointItemClick")
	local select_ = GUI.ImageCreate(Item, "select_", "1800707330", 0,-1, false, 80, 81)
    SetAnchorAndPivot(select_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(select_,false)

	local CutDownBtn = GUI.ButtonCreate(Item,"CutDownBtn","1800402140",24,-24,Transition.ColorTint,"",35,35,false,false)
    UILayout.SetSameAnchorAndPivot(CutDownBtn, UILayout.Center)	
	GUI.RegisterUIEvent(CutDownBtn, UCE.PointerClick, "MountUI", "OnCutDownBtnClick")
	GUI.SetVisible(CutDownBtn,false)
	
	return Item	
end

function MountUI.RefreshLikePointScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	local select_ = GUI.GetChild(Item,"select_")
	local CutDownBtn = GUI.GetChild(Item,"CutDownBtn")
	index = index +1 
	
	if index <= #MountUI.LikePointItemList then
		local tb = MountUI.LikePointItemList[index]
		local ItemDB = DB.GetOnceItemByKey2(tb.keyname)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(ItemDB.Icon))
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,UIDefine.ItemIconBg[ItemDB.Grade])
		GUI.SetData(Item,"keyname",tb.keyname)
		GUI.SetData(Item,"bind",tb.bind)
		GUI.SetData(Item,"ItemId",ItemDB.Id)
		
		if tb.num ~=0 then
			GUI.SetData(Item,"limit",tb.num)
			local num0 = MountUI.UseItemList[tb.keyname.."_"..tb.bind] or 0
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,num0.."/"..tb.num)
			GUI.ItemCtrlSetIconGray(Item,false)
			if num0 > 0 then
				--减少按钮出现
				GUI.SetVisible(CutDownBtn,true)
			else
				GUI.SetVisible(CutDownBtn,false)
			end
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,tb.bind == 1 and "1800707120" or nil)
		else
			GUI.SetVisible(CutDownBtn,false)
			GUI.ItemCtrlSetIconGray(Item,true)
			GUI.SetData(Item,"limit",nil)
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,"")
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp, nil)
		end
	
		if MountUI.CurLikePointItem and MountUI.CurLikePointItem == tb.keyname..tb.bind then
			GUI.SetVisible(select_,true)
		else
			GUI.SetVisible(select_,false)
		end
	else
		GUI.SetVisible(CutDownBtn,false)
		ItemIcon.SetEmpty(Item)
		GUI.SetVisible(select_,false)
		GUI.SetData(Item,"keyname",nil)
		GUI.SetData(Item,"bind",nil)
		GUI.SetData(Item,"limit",nil)
	end

end

--使用好感值道具
function MountUI.OnUseLikePointItem()
	if next(MountUI.UseItemList) then
		local item_list = ""
		for k ,v in pairs(MountUI.UseItemList) do
			local tb = string.split(k,"_")
			item_list = item_list..tb[1].."_"..v.."_"..tb[2].."_"
		end
		CL.SendNotify(NOTIFY.SubmitForm, "FormMount","AddLikePointByItem", MountUI.CurMountID,item_list,GlobalProcessing.MountsVersion)
	end

end

--减少
function MountUI.OnCutDownBtnClick(guid)
	local item = GUI.GetParentElement(GUI.GetByGuid(guid))
	local keyname = GUI.GetData(item,"keyname")
	local bind = GUI.GetData(item,"bind")
	MountUI.UseItemList[keyname.."_"..bind] = math.max(MountUI.UseItemList[keyname.."_"..bind] - 1 ,0)
	local likePointScroll = _gt.GetUI("likePointScroll")
	GUI.LoopScrollRectRefreshCells(likePointScroll)
	MountUI.PreviewLikePointSlider()	
end

--好感条的预览
function MountUI.PreviewLikePointSlider()
	local slider = _gt.GetUI("friendshipSlider")
	local text = _gt.GetUI("friendshipSliderCurrentTxt")
	if next(MountUI.UseItemList) then
		local num = 0
		for k , v in pairs(MountUI.UseItemList) do
			local tb = string.split(k,"_")
			local value = tonumber(GlobalProcessing.MountsLikePointItem[tb[1]].addpoint)
			num = num + value * tonumber(v)
		end
		if num ~= 0 then
			GUI.ScrollBarSetFillImgName(slider,"1800408130")
			GUI.ScrollBarSetPos(slider,math.min(MountUI.LikePoint+num,MountUI.MountLikePointLimit[MountUI.CurMountID])/MountUI.MountLikePointLimit[MountUI.CurMountID])
			GUI.StaticSetText(text,MountUI.LikePoint.."(+"..num..")/"..MountUI.MountLikePointLimit[MountUI.CurMountID])
			return
		end
	end
	
	GUI.ScrollBarSetFillImgName(slider,"1800408160")
	GUI.ScrollBarSetPos(slider,MountUI.LikePoint/MountUI.MountLikePointLimit[MountUI.CurMountID])
	GUI.StaticSetText(text,MountUI.LikePoint.."/"..MountUI.MountLikePointLimit[MountUI.CurMountID])
end

function MountUI.OnLikePointItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local keyname = GUI.GetData(item,"keyname")
	local bind = GUI.GetData(item,"bind")
	
	if keyname and  keyname ~= "" then
		MountUI.CurLikePointItem = keyname..bind
		local limit = GUI.GetData(item,"limit")
		if limit and limit ~= "" then
			if MountUI.UseItemList[keyname.."_"..bind] then
				MountUI.UseItemList[keyname.."_"..bind] = math.min(MountUI.UseItemList[keyname.."_"..bind] + 1 ,tonumber(limit))
			else
				MountUI.UseItemList[keyname.."_"..bind]  = 1
			end
			MountUI.PreviewLikePointSlider()
		end
		--tips
		local itemId = GUI.GetData(item,"ItemId")
		local parent = _gt.GetUI("likePointPage")
		local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -380, -70, 62)  --创造提示
		GUI.SetData(itemtips, "ItemId", tostring(itemId))
		_gt.BindName(itemtips,"LikePointItemTips")
		local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
		GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
		GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
		GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"MountUI","OnClickLikePointItemWayBtn")
		GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
		
		local likePointScroll = _gt.GetUI("likePointScroll")
		GUI.LoopScrollRectRefreshCells(likePointScroll)
	end
end

function MountUI.OnClickLikePointItemWayBtn()
	local tips = _gt.GetUI("LikePointItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end


function MountUI.OnAddPointBtnClick()
	if not MountUI.HaveMount or MountUI.HaveMount ~= 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得该坐骑")
		return
	end
	
	if not MountUI.SkillPoint or MountUI.SkillPoint== 0 and MountUI.UniversalSkillPoint == 0 and MountUI.IsUpSkill == 0 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"当前坐骑无可用技能点")
		return
	end
	
	if MountUI.CurSkillItemGuid then
		local item = GUI.GetByGuid(MountUI.CurSkillItemGuid)
		if item then
			local skill_id = GUI.GetData(item,"skill_id")
			CL.SendNotify(NOTIFY.SubmitForm, "FormMount","SkillLevelUp", MountUI.CurMountID,skill_id,GlobalProcessing.MountsVersion)
		end
	else
		CL.SendNotify(NOTIFY.ShowBBMsg, "请选中想要升级的技能！")
	end
	
	-- MountUI.IsAddSkillPoint = 1
	--显示
	-- local addPointOnExit = _gt.GetUI("addPointOnExit")
	-- GUI.SetVisible(addPointOnExit,MountUI.IsAddSkillPoint ==1)	
	-- local skillFrame = _gt.GetUI("skillFrame")
	-- GUI.SetVisible(skillFrame,MountUI.IsAddSkillPoint == 1)
	-- local skillScroll = _gt.GetUI("skillScroll")
	-- GUI.LoopScrollRectRefreshCells(skillScroll)
end

function MountUI.OnAddPointExitBtnClick()
	-- MountUI.IsAddSkillPoint = 0
	--显示
	-- local addPointOnExit = _gt.GetUI("addPointOnExit")
	-- GUI.SetVisible(addPointOnExit,MountUI.IsAddSkillPoint ==1)	
	-- local skillFrame = _gt.GetUI("skillFrame")
	-- GUI.SetVisible(skillFrame,MountUI.IsAddSkillPoint ==1)
	-- local skillScroll = _gt.GetUI("skillScroll")
	-- GUI.LoopScrollRectRefreshCells(skillScroll)
end

--坐骑技能

function MountUI.CreateSkillItem()
	local skillScroll = _gt.GetUI("skillScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(skillScroll)
	local skillItem = GUI.ItemCtrlCreate(skillScroll, "skillItem" .. curCount, "1800400330", 0, 0, 89, 89)
	GUI.RegisterUIEvent(skillItem, UCE.PointerClick, "MountUI", "OnSkillItemClick")
	
	local lv_ = GUI.ImageCreate(skillItem, "lv_", "1800707330", 20,22, false, 32, 27)
    SetAnchorAndPivot(lv_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(lv_,false)

	local text = GUI.CreateStatic( lv_, "text", "", 2, 0, 100, 40, "system", true, false);
	SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetFontSize(text, 20)
	GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
	GUI.SetColor(text, UIDefine.WhiteColor)		
	
	local select_ = GUI.ImageCreate(skillItem, "select_", "1800707330", 0,-1, false, 90, 91)
    SetAnchorAndPivot(select_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(select_,false)
	
	local lock_ = GUI.ImageCreate(skillItem, "lock_", "1800408170", -24,19, false, 20, 25)
    SetAnchorAndPivot(lock_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetColor(lock_,Color.New(255 / 255, 226 / 255, 148 / 255, 1))
	GUI.SetVisible(lock_,false)
		
	return skillItem
end

local SkillsIconBg = {
	["1"] = "1801407010",
	["2"] = "1801407020",
	["3"] = "1801407030",
	["4"] = "1801407040",
	["5"] = "1801407050",
}

function MountUI.RefreshSkillScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	-- local icon = GUI.GetChild(Item,"icon")
	local lv_ = GUI.GetChild(Item,"lv_")
	local select_ = GUI.GetChild(Item,"select_")
	local lock_ = GUI.GetChild(Item,"lock_")
	index = index+1
	
	
	-- GUI.SetData(Item,"upskill",nil)
	
	if index <= #MountUI.SkillList then
		local tb = MountUI.SkillList[index]
		local SkillDB = DB.GetOnceSkillByKey1(tb.Id)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(SkillDB.Icon))
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,UIDefine.ItemIconBg[SkillDB.SkillQuality])
		if tb.Level ~=0 and SkillsIconBg[tostring(SkillDB.SkillQuality)] then
			GUI.ImageSetImageID(lv_,SkillsIconBg[tostring(SkillDB.SkillQuality)])
			local text = GUI.GetChild(lv_,"text")
			GUI.StaticSetText(text,tb.Level)
			GUI.SetVisible(lv_,true)
		else
			GUI.SetVisible(lv_,false)
		end
		-- GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftBottomSp,tb.Level ~=0 and SkillsIconBg[tostring(SkillDB.SkillQuality)] or "")	
		GUI.ItemCtrlSetIconGray(Item,tb.Level==0)
		-- GUI.ItemCtrlSetElementRect(Item, eItemIconElement.LeftBottomSp, 45, 5,32,27)
		GUI.SetData(Item,"skill_id",tb.Id)
		GUI.SetData(Item,"skill_lv",tb.Level)
		GUI.SetData(Item,"skill_index",index)
		-- if MountUI.IsAddSkillPoint and MountUI.IsAddSkillPoint == 1 then
			-- if tb.Level == tb.MaxLevel then
				-- if tb.NextSkill and tostring(tb.NextSkill) ~= "0" then
					-- GUI.ImageSetImageID(icon,"1801407070")
					-- GUI.SetWidth(icon,53)
					-- GUI.SetHeight(icon,57)
					-- GUI.SetVisible(icon,true)
					-- GUI.SetData(Item,"upskill","1")
				-- else
					-- GUI.SetVisible(icon,false)
				-- end
			-- else
				-- GUI.SetWidth(icon,67)
				-- GUI.SetHeight(icon,68)
				-- GUI.ImageSetImageID(icon,"1800707360")
				-- GUI.SetVisible(icon,true)
			-- end
		-- else
			-- GUI.SetVisible(icon,false)
		-- end
		local isLock  = 0
		--锁定显示
		local lock_lv = 0
		if GlobalProcessing.MountsSkillLevelUpPoint[tonumber(tb.Id)] and GlobalProcessing.MountsSkillLevelUpPoint[tonumber(tb.Id)][tonumber(tb.Level)+1] then
			lock_lv = GlobalProcessing.MountsSkillLevelUpPoint[tonumber(tb.Id)][tonumber(tb.Level)+1].minstage
		end

		if tonumber(MountUI.Stage) < lock_lv then
			GUI.SetData(Item,"lock_lv",lock_lv)
			GUI.SetVisible(lock_,true)
		else
			GUI.SetData(Item,"lock_lv",nil)
			GUI.SetVisible(lock_,false)
		end
		
		--选择框
		if MountUI.CurSkillItemGuid and tostring(MountUI.CurSkillItemGuid) == guid then
			GUI.SetVisible(select_,true)
		else
			GUI.SetVisible(select_,false)
		end

		if not MountUI.CurSkillItemGuid then
			MountUI.OnSkillItemClick(guid)
		end
	else
		GUI.StaticSetText(skillLevel,"")
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,nil)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,"1800400330")
		-- GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftBottomSp,"")
		GUI.SetData(Item,"skill_id",nil)
		GUI.SetData(Item,"skill_lv",nil)
		GUI.SetData(Item,"skill_index",nil)
		GUI.SetData(Item,"lock_lv",nil)
		GUI.SetVisible(lv_,false)
		GUI.SetVisible(select_,false)
		GUI.SetVisible(lock_,false)
	end
	
end

function MountUI.OnSkillItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local skill_id = GUI.GetData(item,"skill_id")
	if skill_id and skill_id ~= "" then
		-- if MountUI.IsAddSkillPoint and MountUI.IsAddSkillPoint == 1 then
				-- local upskill = tonumber(GUI.GetData(item,"upskill"))
				-- if upskill and upskill == 1 then
					--打开技能升阶窗口
					-- MountUI.CurUpSkllItem = {}
					-- MountUI.CurUpSkllItem = GlobalProcessing.MountsSkillStageUpItem[tonumber(skill_id)]
					-- MountUI.OpenUpSkillItemWnd(GUI.GetData(item,"skill_index"))
				-- else
					-- CL.SendNotify(NOTIFY.SubmitForm, "FormMount","SkillLevelUp", MountUI.CurMountID,skill_id)
				-- end
		-- else
			--创建tips
			CL.SendNotify(NOTIFY.SubmitForm,"FormMount","GetSkillInfo",MountUI.CurMountID,skill_id)
			--刷新消耗技能点
			--选中
			if MountUI.CurSkillItemGuid and MountUI.CurSkillItemGuid ~= guid then
				local select_ = GUI.GetChild(GUI.GetByGuid(MountUI.CurSkillItemGuid),"select_")
				GUI.SetVisible(select_,false)
			end
			
			MountUI.CurSkillItemGuid = guid
			local select_ = GUI.GetChild(item,"select_")
			GUI.SetVisible(select_,true)
			
			local skill_lv = GUI.GetData(item,"skill_lv")
			MountUI.RefreshConsumeSkillPoint(skill_id,skill_lv)
			
			--刷新学习技能按钮
			MountUI.RefreshAddPointBtn()
		-- end
	end
end

function MountUI.RefreshConsumeSkillPoint(skill_id,skill_lv)
	local skill_id = skill_id
	local skill_lv = skill_lv
	if not skill_id or not skill_lv then
		if MountUI.CurSkillItemGuid then
			local item = GUI.GetByGuid(MountUI.CurSkillItemGuid)
			if item then
				skill_id = GUI.GetData(item,"skill_id")
				for k ,v in pairs(MountUI.SkillList) do
					if skill_id == tostring(v.Id) then
						skill_lv = v.Level
						break
					end
				end
			end
		end
	end
	local point = 0
	if skill_id and tonumber(skill_id) and GlobalProcessing.MountsSkillLevelUpPoint[tonumber(skill_id)] and GlobalProcessing.MountsSkillLevelUpPoint[tonumber(skill_id)][tonumber(skill_lv)+1]then
		point = GlobalProcessing.MountsSkillLevelUpPoint[tonumber(skill_id)][tonumber(skill_lv)+1].skillpoint
	end
	local ConsumeSkillPoint = _gt.GetUI("ConsumeSkillPoint")
	GUI.StaticSetText(ConsumeSkillPoint,point)

end

function MountUI.RefreshAddPointBtn()
	local bool = true
	local lock_lv = ""
	if MountUI.CurSkillItemGuid then
		local item = GUI.GetByGuid(MountUI.CurSkillItemGuid)
		lock_lv = GUI.GetData(item,"lock_lv") or ""
		if lock_lv and lock_lv ~= "" then
			bool = false
		end
	end
	local btn = _gt.GetUI("AddPointBtn")
	local text = _gt.GetUI("BanAddPoint")
	GUI.StaticSetText(text,"（坐骑"..lock_lv.."阶可学习）")
	GUI.SetVisible(btn,bool)
	GUI.SetVisible(text,not bool)
end

function MountUI.OnSkillTipsCallBack(skill_id,skill_lv,skill_list)
	if skill_id then
		local info = ""
		local skillDB = DB.GetOnceSkillByKey1(skill_id)
		local count = 0
		local inspect = require("inspect")
		if #skill_list > 0 then
			for i =1 , #skill_list do
				local num = i+17
				_, c = string.gsub(skillDB.Info,"{"..num.."}","{"..num.."}")
				count = count + c
			end
		end
		info = skillDB.Info
		if #skill_list > 0 and count ~= 0 then 
			for i =1 , math.min(count,#skill_list) do
				local num = i+17
				info = string.gsub(info,"{"..num.."}",skill_list[i],1)
			end		
		end
		Tips.CreateSkillId(skill_id,_gt.GetUI("controlBg"),"skilltips",-430,60,0,0,skill_lv,info)	
	end
end

function MountUI.OpenUpSkillItemWnd(skill_index)
	local Page = _gt.GetUI("UpSkillItemWnd")
	local cover = _gt.GetUI("PanelCover_UpSkill")
	local upSkillScroll = _gt.GetUI("upSkillScroll")
	if not Page then
		local parent = _gt.GetUI("MountPage")
		Page = UILayout.CreateFrame_WndStyle2(parent,"技能升阶",500,290,"MountUI","UpSkillItemWndOnClose")
		-- GUI.SetPositionX(Page,-310)
		GUI.SetPositionY(Page,-65)
		_gt.BindName(Page,"UpSkillItemWnd")
		
		cover =  GUI.GetChild(parent,"panelCover")
		_gt.BindName(cover,"PanelCover_UpSkill")
		
		GUI.SetPositionY(cover,-35)
		
		upSkillScroll = GUI.LoopScrollRectCreate(Page, "upSkillScroll", 0, 0, 300, 100,
		"MountUI", "CreateUpSkillItem", "MountUI", "RefreshUpSkillScroll", 0, true, Vector2.New(80, 81), 1, UIAroundPivot.Center, UIAnchor.Center);
		UILayout.SetSameAnchorAndPivot(upSkillScroll, UILayout.Center)
		_gt.BindName(upSkillScroll,"upSkillScroll")
		
		local UpSkillBtn = GUI.ButtonCreate(Page, "UpSkillBtn", "1800402080", 0, 90, Transition.ColorTint, "确定", 140, 47, false);
		GUI.SetIsOutLine(UpSkillBtn, true);
		GUI.ButtonSetTextFontSize(UpSkillBtn, 26);
		GUI.ButtonSetTextColor(UpSkillBtn, colorwrite);
		GUI.SetOutLine_Color(UpSkillBtn, coloroutline);
		GUI.SetOutLine_Distance(UpSkillBtn, 1);
		GUI.RegisterUIEvent(UpSkillBtn, UCE.PointerClick, "MountUI", "OnUpSkillBtnClick")
	end
	local UpSkillBtn = GUI.GetChild(Page,"UpSkillBtn")
	GUI.SetData(UpSkillBtn,"skill_index",skill_index)
	
	
	GUI.LoopScrollRectSetTotalCount(upSkillScroll, #MountUI.CurUpSkllItem/2) 
	GUI.LoopScrollRectRefreshCells(upSkillScroll)
	
	GUI.SetVisible(Page,true)
	GUI.SetVisible(cover,true)
end

function MountUI.OnUpSkillBtnClick(guid)
	MountUI.UpSkillItemWndOnClose()
	CL.SendNotify(NOTIFY.SubmitForm, "FormMount","SkillStageUp", MountUI.CurMountID,tonumber(GUI.GetData(GUI.GetByGuid(guid),"skill_index")) or nil,GlobalProcessing.MountsVersion )
end

function MountUI.CreateUpSkillItem()
	local upSkillScroll = _gt.GetUI("upSkillScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(upSkillScroll)
	local Item = ItemIcon.Create(upSkillScroll, "UpSkillItem"..curCount, 0, 0)
	UILayout.SetSameAnchorAndPivot(Item,UILayout.Center)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "MountUI", "OnUpSkillItemClick")
	
	return Item	
end

function MountUI.OnUpSkillItemClick(guid)
	local itemId = GUI.GetData(GUI.GetByGuid(guid),"id")
	local parent = _gt.GetUI("UpSkillItemWnd")
	Tips.CreateByItemId(itemId,parent, "itemtips", 330, -105, 50)
end	

function MountUI.UpSkillItemWndOnClose()
	local Page = _gt.GetUI("UpSkillItemWnd")
	local Cover = _gt.GetUI("PanelCover_UpSkill")
	GUI.SetVisible(Page,false)
	GUI.SetVisible(Cover,false)
end

function MountUI.RefreshUpSkillScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	index = index +1 
	
	local tb = MountUI.CurUpSkllItem
	if index <= #tb/2 then
		local keyname = tb[2*index-1]
		local num = tb[2*index]
		local ItemDB = DB.GetOnceItemByKey2(keyname)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(ItemDB.Icon))
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,UIDefine.ItemIconBg[ItemDB.Grade])
		local count = LD.GetItemCountById(ItemDB.Id) 
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,count.."/"..num)
		GUI.SetData(Item,"id",ItemDB.Id)
	else
		ItemIcon.SetEmpty(Item)
	end

end

function MountUI.OpenSelectedControlPetWnd(guid)
	if not MountUI.HaveMount or MountUI.HaveMount ~= 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得该坐骑")
		return
	end
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"index"))
	MountUI.ControlPetIndex = index
	if not MountUI.ControlPetIndex then
		return
	end	
	CL.SendNotify(NOTIFY.SubmitForm, "FormMount","GetReinPetList", MountUI.CurMountID)
end

function MountUI.SelectedControlPet()
	local Page = _gt.GetUI("ControlPetPage")
	local panelCover = _gt.GetUI("panelCover_ControlPetPage")
	if not Page then
		local parent = _gt.GetUI("MountPage")
		panelCover =GUI.ImageCreate(parent, "panelCover_ControlPetPage", "1800400220", 0, -35, false, GUI.GetWidth(parent), GUI.GetHeight(parent))
		UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetIsRaycastTarget(panelCover, true)
		_gt.BindName(panelCover,"panelCover_ControlPetPage")
	
		Page = UILayout.CreateFrame_WndStyle2_WithoutCover(parent,"宠物选择",500,360,"MountUI","ControlPetPageOnClose")
		_gt.BindName(Page,"ControlPetPage")
		
		local Bg = GUI.ImageCreate(Page, "Bg", "1800400200", 0, 0,false,450,220)
		SetAnchorAndPivot(Bg, UIAnchor.Center, UIAroundPivot.Center)
		
		local petScroll = GUI.LoopScrollRectCreate(Bg, "petScroll", 0, 0, 410, 200,
		"MountUI", "CreatePetItem", "MountUI", "RefreshPetScroll", 0, false, Vector2.New(95, 95), 4, UIAroundPivot.Top, UIAnchor.Top);
		UILayout.SetSameAnchorAndPivot(petScroll, UILayout.Center)
		GUI.ScrollRectSetChildSpacing(petScroll, Vector2.New(10, 10))
		_gt.BindName(petScroll, "petScroll")
		
		--确认按钮
		local petConfirmBtn = GUI.ButtonCreate(Page, "petConfirmBtn", "1800402080", 0, 143, Transition.ColorTint, "确认", 140, 47, false);
		GUI.SetIsOutLine(petConfirmBtn, true);
		GUI.ButtonSetTextFontSize(petConfirmBtn, 26);
		GUI.ButtonSetTextColor(petConfirmBtn, colorwrite);
		GUI.SetOutLine_Color(petConfirmBtn, coloroutline);
		GUI.SetOutLine_Distance(petConfirmBtn, 1);
		GUI.RegisterUIEvent(petConfirmBtn, UCE.PointerClick, "MountUI", "OnPetConfirmBtnClick");
	end
	
	MountUI.ControlPetGuid = MountUI.MountPet[MountUI.ControlPetIndex] or "0"

	MountUI.PetList = LD.GetPetGuids()
	
	local petScroll =  _gt.GetUI("petScroll")
	GUI.LoopScrollRectSetTotalCount(petScroll, math.max(MountUI.PetList.Count,8)) 
	GUI.LoopScrollRectRefreshCells(petScroll)
	
	GUI.SetVisible(Page,true)
	GUI.SetVisible(panelCover,true)
end

function MountUI.OnPetConfirmBtnClick()
	if MountUI.ControlPetGuid then
		CL.SendNotify(NOTIFY.SubmitForm, "FormMount","ReinPet", MountUI.CurMountID,MountUI.ControlPetGuid,MountUI.ControlPetIndex,GlobalProcessing.MountsVersion)
	end
end

function MountUI.CreatePetItem()
	local petScroll = _gt.GetUI("petScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(petScroll)
	local petItem = GUI.ItemCtrlCreate(petScroll, "petItem" .. curCount, "1800400330", 0, 0, 89, 89)
	GUI.RegisterUIEvent(petItem, UCE.PointerClick, "MountUI", "OnPetItemClick")
	
	local Flag = GUI.ImageCreate(petItem,"Flag","1801720250",-14,-13, false, 71, 71)
	SetAnchorAndPivot(Flag,UIAnchor.Center,UIAroundPivot.Center)
	-- GUI.SetEulerAngles(Flag, Vector3.New(0, 0, 180))
	-- GUI.SetScale(Flag, Vector3.New(1, -1,1))
	
	local Label = GUI.CreateStatic(Flag, "Label", "统驭中", -10, -10, 200, 40)
	GUI.StaticSetAlignment(Label, TextAnchor.MiddleCenter)
	UILayout.SetAnchorAndPivot(Label, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetFontSize(Label, 20)
	GUI.SetIsOutLine(Label, true)
    GUI.SetOutLine_Color(Label, coloroutline)
    GUI.SetOutLine_Distance(Label, 1)
	GUI.SetEulerAngles(Label, Vector3.New(0, 0,45))
	-- GUI.SetScale(Label, Vector3.New(-1, 1,1))
	GUI.SetVisible(Flag,false)
	
	--选中
	local checkBtn = GUI.CheckBoxExCreate(petItem,"checkBtn","1800408400","1800408401",35,35,false,45,41)
	GUI.RegisterUIEvent(checkBtn, UCE.PointerClick, "MountUI", "OnCheckPetBtnClick")
	
	GUI.SetVisible(checkBtn,false)	
	
	return petItem
end

function MountUI.RefreshPetScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local petItem = GUI.GetByGuid(guid)
	local checkBtn = GUI.GetChild(petItem,"checkBtn")
	local Flag = GUI.GetChild(petItem,"Flag")
	-- local Shadow = GUI.GetChild(petItem,"ShadowImg")
	-- GUI.SetVisible(lock,false)
	
	if index <= MountUI.PetList.Count-1 then
		GUI.SetVisible(checkBtn,true)
		local petGuid = tostring(MountUI.PetList[index])
		local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)))
		local petDB = DB.GetOncePetByKey1(petId)
		GUI.ItemCtrlSetElementValue(petItem, eItemIconElement.Icon, tostring(petDB.Head))
		GUI.ItemCtrlSetElementRect(petItem, eItemIconElement.Icon, 0, 0,84,84);
		GUI.ItemCtrlSetElementValue(petItem, eItemIconElement.Border, UIDefine.PetItemIconBg3[tonumber(petDB.Grade)])
		GUI.SetData(petItem,"petGuid",petGuid)
		--已选择
		if petGuid == tostring(MountUI.ControlPetGuid)  then
			 GUI.CheckBoxExSetCheck(checkBtn,true)
			-- if petGuid == MountUI.ControlPetGuid then
				-- GUI.SetVisible(Shadow,true)
			-- end
		else
			 GUI.CheckBoxExSetCheck(checkBtn,false)
		end
		--如果为当前携带宠物
		if MountUI.ReinPetGUIDList[petGuid] then
			local Label = GUI.GetChild(Flag,"Label")
			if MountUI.ReinPetGUIDList[petGuid] == 1 then
				GUI.StaticSetText(Label,"当前")
				GUI.SetColor(Flag,Color.New(255 / 255, 0 / 255, 0 / 255, 1))
			elseif  MountUI.ReinPetGUIDList[petGuid] == 2 then
				GUI.StaticSetText(Label,"统驭中")
				GUI.SetColor(Flag,Color.New(255 / 255, 255 / 255, 255 / 255, 1))
			end
			GUI.SetVisible(Flag,true)
		else
			GUI.SetVisible(Flag,false)
		end
	else
		GUI.SetVisible(checkBtn,false)
		GUI.SetVisible(Flag,false)
		GUI.ItemCtrlSetElementValue(petItem, eItemIconElement.Icon, nil)
		GUI.ItemCtrlSetElementValue(petItem, eItemIconElement.Border, "1800400330")
		-- GUI.ItemCtrlSetElementValue(petItem, eItemIconElement.LeftTopSp, nil)
		GUI.SetData(petItem,"petGuid","")
	end
end

function MountUI.OnCheckPetBtnClick(guid)
	local toggle = GUI.GetByGuid(guid)
	if GUI.CheckBoxExGetCheck(toggle) then
		local guid = GUI.GetData(GUI.GetParentElement(toggle),"petGuid")
		MountUI.ControlPetGuid = guid
	else
		MountUI.ControlPetGuid = "0"
	end
	
	local petScroll =  _gt.GetUI("petScroll")
	GUI.LoopScrollRectRefreshCells(petScroll)	

end

function MountUI.OnPetItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local petGuid = GUI.GetData(item,"petGuid")
	if petGuid and petGuid ~= "" then
		-- MountUI.ControlPetGuid = petGuid
		GUI.OpenWnd("PetInfoUI","2,"..petGuid)
		
		-- local petScroll = _gt.GetUI("petScroll")
		-- GUI.LoopScrollRectRefreshCells(petScroll)
	end
end

function MountUI.ControlPetPageOnClose()
	MountUI.ControlPetGuid = nil
	local ControlPetPage = _gt.GetUI("ControlPetPage")
	local panelCover = _gt.GetUI("panelCover_ControlPetPage")
	GUI.SetVisible(ControlPetPage,false)
	GUI.SetVisible(panelCover,false)
end



--升阶界面
function MountUI.OpenMountRaiseGradePage()
	--没有该坐骑不让打开
	if not MountUI.HaveMount or MountUI.HaveMount ~= 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得该坐骑")
		return
	end
	local page = _gt.GetUI("RaiseGradePage")
	local panelCover = _gt.GetUI("panelCover_RaiseGrade")
	if not page then
		local parent = _gt.GetUI("MountPage")
		
		panelCover = GUI.ImageCreate(parent, "panelCover_RaiseGrade", "1800400220", 0, -33, false, GUI.GetWidth(parent), GUI.GetHeight(parent))
		UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetIsRaycastTarget(panelCover, true)
		_gt.BindName(panelCover,"panelCover_RaiseGrade")
		
		page = GUI.GroupCreate(parent, "RaiseGradePage", 0, 0, 0, 0)
		UILayout.SetAnchorAndPivot(page, UIAnchor.Center, UIAroundPivot.Center)
		_gt.BindName(page,"RaiseGradePage")

		local center = GUI.ImageCreate(page, "center", "1800600182", 0, 100, false, 500, 300)
		UILayout.SetAnchorAndPivot(center, UIAnchor.Bottom, UIAroundPivot.Bottom)

		local topBar = GUI.ImageCreate(page, "topBar", "1800600183", 0, -210, false, 500, 54)
		UILayout.SetAnchorAndPivot(topBar, UIAnchor.Top, UIAroundPivot.Center)

		local topBarCenter = GUI.ImageCreate(page, "topBarCenter", "1800600190", 0, -210, false, 270, 50)
		UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

		local tipLabel = GUI.CreateStatic(topBarCenter, "tipLabel", "坐骑升阶", 0, 0, 200, 40)
		GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
		GUI.SetColor(tipLabel, UIDefine.BrownColor)
		UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(tipLabel, UIDefine.FontSizeL)

		local closeBtn = GUI.ButtonCreate(page, "closeBtn", "1800302120", 245, -230, Transition.ColorTint)
		UILayout.SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
		GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "MountUI", "OnRaiseGradeClose")
		
		--升阶按钮
		local raiseGradeBtn = GUI.ButtonCreate(page, "raiseGradeBtn", "1800402080", 0, 40, Transition.ColorTint, "升级", 140, 47, false);
		GUI.SetIsOutLine(raiseGradeBtn, true);
		GUI.ButtonSetTextFontSize(raiseGradeBtn, 26);
		GUI.ButtonSetTextColor(raiseGradeBtn, colorwrite);
		GUI.SetOutLine_Color(raiseGradeBtn, coloroutline);
		GUI.SetOutLine_Distance(raiseGradeBtn, 1);
		GUI.RegisterUIEvent(raiseGradeBtn, UCE.PointerClick, "MountUI", "OnRaiseGradeBtnClick")
		
		local raiseGradeTips = GUI.CreateStatic(page, "raiseGradeTips", "", 0, -20, 450, 50)
		GUI.StaticSetAlignment(raiseGradeTips, TextAnchor.MiddleCenter)
		GUI.SetColor(raiseGradeTips, UIDefine.BrownColor)
		UILayout.SetAnchorAndPivot(raiseGradeTips, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(raiseGradeTips, 22)
		
		
		local raiseGradeScroll = GUI.LoopScrollRectCreate(page, "raiseGradeScroll", 0, -100, 300, 100,
		"MountUI", "CreateRaiseGradeItem", "MountUI", "RefreshRaiseGradeScroll", 0, true, Vector2.New(80, 81), 1, UIAroundPivot.Center, UIAnchor.Center);
		UILayout.SetSameAnchorAndPivot(raiseGradeScroll, UILayout.Center)
		_gt.BindName(raiseGradeScroll,"raiseGradeScroll")
	end
	
	--道具刷新
	local raiseGradeScroll = _gt.GetUI("raiseGradeScroll")
	local tb = MountUI.MountStageConfig["Item"]
	GUI.LoopScrollRectSetTotalCount(raiseGradeScroll, #tb/2) 
	GUI.LoopScrollRectRefreshCells(raiseGradeScroll)
	
	
	--升阶提示
	local Tips = GUI.GetChild(page,"raiseGradeTips")
	GUI.StaticSetText(Tips,MountUI.MountStageTips)

	GUI.SetVisible(page,true)
	GUI.SetVisible(panelCover,true)


end

--点击升级按钮
function MountUI.OnRaiseGradeBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm,"FormMount","StageUp",MountUI.CurMountID,GlobalProcessing.MountsVersion)
end


function MountUI.CreateRaiseGradeItem()
	local raiseGradeScroll = _gt.GetUI("raiseGradeScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(raiseGradeScroll)
	local Item = ItemIcon.Create(raiseGradeScroll, "RaiseGradeItem"..curCount, 0, 0)
	UILayout.SetSameAnchorAndPivot(Item,UILayout.Center)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "MountUI", "OnRaiseGradeItemClick")
	
	return Item	
end

--当升阶材料被点击
function MountUI.OnRaiseGradeItemClick(guid)
	local itemId = GUI.GetData(GUI.GetByGuid(guid),"id")
	local parent = _gt.GetUI("RaiseGradePage")
	Tips.CreateByItemId(itemId,parent, "itemtips", 340, -180, 50)
end	

function MountUI.RefreshRaiseGradeScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	local select_ = GUI.GetChild(Item,"select_")
	index = index +1 
	
	local tb =MountUI.MountStageConfig["Item"]
	if index <= #tb/2 then
		local keyname = tb[2*index-1]
		local num = tb[2*index]
		local ItemDB = DB.GetOnceItemByKey2(keyname)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(ItemDB.Icon))
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,UIDefine.ItemIconBg[ItemDB.Grade])
		local count = LD.GetItemCountById(ItemDB.Id) 
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,count.."/"..num)
		GUI.SetData(Item,"id",ItemDB.Id)
	else
		ItemIcon.SetEmpty(Item)
	end

end

function MountUI.OnRaiseGradeClose()
	local page = _gt.GetUI("RaiseGradePage")
	local panelCover = _gt.GetUI("panelCover_RaiseGrade")
	GUI.SetVisible(page,false)
	GUI.SetVisible(panelCover,false)
end

--模型创建
function MountUI.ModelCreate()
	local RoleModel = _gt.GetUI("RoleModel")
	local MountModel = _gt.GetUI("MountModel")
	
	GlobalProcessing.Mount_ModelCreate(RoleModel,MountModel)
	

end

--模型点击
function MountUI.OnModelClick()
	local RoleModel = _gt.GetUI("RoleModel")
	local MountModel = _gt.GetUI("MountModel")
	
	GlobalProcessing.Mount_OnModelClick(RoleModel,MountModel)

end

function MountUI.OnAnimationCallBack(guid,action)
	local RoleModel = _gt.GetUI("RoleModel")
	local MountModel = _gt.GetUI("MountModel")
	

	local ModelID = tonumber(GUI.GetData(RoleModel,"ModelID"))
	local RoleMovement = eRoleMovement.HORSESTAND
	if ModelID then
		local MountType = 0
		local hookadapter = SETTING.GetBonehookadapter(ModelID)
		if UIDefine.IsFunctionOrVariableExist(hookadapter, "MountType") then
			MountType  = hookadapter.MountType or 0 
		end			
		if MountType == 0 then
			RoleMovement = eRoleMovement.HORSESTAND
		elseif MountType == 1 then
			RoleMovement = eRoleMovement.STAND_W1
		end
	end
	ModelItem.BindSelfRole(RoleModel,RoleMovement)
	GUI.ReplaceWeapon(MountModel, 0, eRoleMovement.STAND_W1, 0)
end


--选择统驭宠物后刷新
function MountUI.RefreshOnControlPet()
	MountUI.ControlPetPageOnClose()
	MountUI.RefreshControlPage()
end

--升级技能后刷新
function MountUI.RefreshOnSkillsLvUp()
	MountUI.RefreshControlPage()
end


--升阶请求后刷新（服务器调用整体刷新Refresh()
function MountUI.RefreshOnRaiseGrade()
	MountUI.OnRaiseGradeClose()
end

--刷新显示/隐藏按钮
function MountUI.RefreshMountShowBtn()
	local text = _gt.GetUI("mountShowText")
	--如果没有坐骑
	if not MountUI.HaveMount or MountUI.HaveMount ~=1 then
		GUI.SetVisible(text,false)
		return
	end
	if MountUI.IsShow and MountUI.IsShow == 1 then
		GUI.SetVisible(text,true)
	else
		GUI.SetVisible(text,false)
	end
end




function MountUI.OnDomesticateValueTips(guid)
	local NotifyParameter = {
		["DomesticatePointAttr"] = {
			["Min"] = -1 ,
			["Max"]  = 1,
		},
		["ActivePointAttr"] = {
			["Min"] = -2 ,
			["Max"]  = 2,
		},
	}
	
	local attr_tb = "DomesticatePointAttr_Min"
	local name = "野性"
	if guid then
		attr_tb = GUI.GetData(GUI.GetByGuid(guid),"attr_tb")
		name = GUI.GetData(GUI.GetByGuid(guid),"name")
	end
	
	local temp = string.split(attr_tb,"_")

	local tb = GlobalProcessing.MountsConfig[tonumber(MountUI.CurMountID)][temp[1]][temp[2]]
	
	MountUI.DomesticateTipsTemp = {}
	
	MountUI.DomesticateTipsTemp["name"] = name
	
	MountUI.DomesticateTipsTemp["now_max_value"] = tb.Point

	
	MountUI.DomesticateTipsTemp["now_max_attr"] = {}
	for k ,v in pairs(tb.Attr) do
		local AttrDB = DB.GetOnceAttrByKey2(k)
		table.insert(MountUI.DomesticateTipsTemp["now_max_attr"],{[tonumber(AttrDB.Id)] = tonumber(v)})
	end
	
	local type_ = NotifyParameter[temp[1]][temp[2]]
	CL.SendNotify(NOTIFY.SubmitForm, "FormMount","GetDomesticateTips", MountUI.CurMountID,type_)
	
end

function MountUI.ShowDomesticateTips()
	local domesticateBg = _gt.GetUI("domesticateBg")
	local tips = GUI.TipsCreate(domesticateBg,"DomesticateValueTips",-250,40,500,-46)
	tips:RegisterEvent(UCE.PointerClick)
	GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)	
	
	
	local Lable = GUI.TipsAddLabel(tips,40,MountUI.DomesticateTipsTemp["name"].."值",UIDefine.OrangeColor ,true)
	
	local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", "属性加成", 160, 0, 300, 40, "system", true, false);
	SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetFontSize(ValueLabal, 22)
	GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleLeft)
	GUI.SetColor(ValueLabal,UIDefine.OrangeColor)
	
	if MountUI.DomesticateTipsTable then
		--当前值
		local Lable = GUI.TipsAddLabel(tips,40,"当前："..math.abs(MountUI.DomesticateTipsTable["now_value"]),UIDefine.BlueColor ,true)
		local str = ""
		for i =1 ,#MountUI.DomesticateTipsTable["now_attr"] do
			for k ,v in pairs(MountUI.DomesticateTipsTable["now_attr"][i]) do
				local AttrDB = DB.GetOnceAttrByKey1(k)
				str = str..AttrDB.ChinaName.."+"..v.." "
			end
		end
		local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", str, 160, 0, 300, 40, "system", true, false);
		SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(ValueLabal, 22)
		GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleLeft)
		GUI.SetColor(ValueLabal, UIDefine.BlueColor)		
		
		--下阶的值
		if MountUI.DomesticateTipsTable["next_value"] then
			local Lable = GUI.TipsAddLabel(tips,40,"下次："..math.abs(MountUI.DomesticateTipsTable["next_value"]),UIDefine.GrayColor ,true)
			local str = ""
			for i =1 ,#MountUI.DomesticateTipsTable["next_attr"] do
				for k ,v in pairs(MountUI.DomesticateTipsTable["next_attr"][i]) do
					local AttrDB = DB.GetOnceAttrByKey1(k)
					str = str..AttrDB.ChinaName.."+"..v.." "
				end
			end
			local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", str, 160, 0, 300, 40, "system", true, false);
			SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
			GUI.StaticSetFontSize(ValueLabal, 22)
			GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleLeft)
			GUI.SetColor(ValueLabal, UIDefine.GrayColor)					
		end
		
		--当前上限
		local Lable = GUI.TipsAddLabel(tips,40,"当前上限："..math.abs(MountUI.DomesticateTipsTemp["now_max_value"]),UIDefine.BlueColor ,true)
		local str = ""
		for i =1 ,#MountUI.DomesticateTipsTemp["now_max_attr"] do
			for k ,v in pairs(MountUI.DomesticateTipsTemp["now_max_attr"][i]) do
				local AttrDB = DB.GetOnceAttrByKey1(k)
				str = str..AttrDB.ChinaName.."+"..v.." "
			end
		end
		local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", str, 160, 0, 300, 40, "system", true, false);
		SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(ValueLabal, 22)
		GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleLeft)
		GUI.SetColor(ValueLabal, UIDefine.BlueColor)			
		
		--下次上限
		if MountUI.DomesticateTipsTable["next_max_value"] then
			local Lable = GUI.TipsAddLabel(tips,40,"下阶上限："..math.abs(MountUI.DomesticateTipsTable["next_max_value"]),UIDefine.GrayColor ,true)
			local str = ""
			for i =1 ,#MountUI.DomesticateTipsTable["next_max_attr"] do
				for k ,v in pairs(MountUI.DomesticateTipsTable["next_max_attr"][i]) do
					local AttrDB = DB.GetOnceAttrByKey1(k)
					str = str..AttrDB.ChinaName.."+"..v.." "
				end
			end
			local ValueLabal = GUI.CreateStatic( Lable, "ValueLabal", str, 160, 0, 300, 40, "system", true, false);
			SetAnchorAndPivot(ValueLabal, UIAnchor.Center, UIAroundPivot.Center)
			GUI.StaticSetFontSize(ValueLabal, 22)
			GUI.StaticSetAlignment(ValueLabal, TextAnchor.MiddleLeft)
			GUI.SetColor(ValueLabal, UIDefine.GrayColor)					
		end
	end
	
	GUI.SetVisible(GUI.GetChild(tips,"CutLine"),false)
	GUI.SetPositionY(GUI.GetChild(tips,"InfoScr"),50)

end

--新加默契值
function MountUI.OnAddTacitBtnClick()
	--没有该坐骑不让打开
	if not MountUI.HaveMount or MountUI.HaveMount ~= 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得该坐骑")
		return
	end
	
	local addTacitPage = _gt.GetUI("addTacitPage")
	local addTacitScroll = _gt.GetUI("addTacitScroll")
	local curAddTatic = _gt.GetUI("curAddTatic")
	if not addTacitPage then
		local MountPage = _gt.GetUI("MountPage")
		local wnd = GUI.GetWnd("BagUI")
		addTacitPage =GUI.ImageCreate(MountPage, "addTacitPage", "1800400220", 0, -35, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
		UILayout.SetAnchorAndPivot(addTacitPage, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetIsRaycastTarget(addTacitPage, true)
		_gt.BindName(addTacitPage,"addTacitPage")
		
		Bg = GUI.ImageCreate(addTacitPage, "Bg", "1800400300", 0, 0, false, 320, 280)
		SetAnchorAndPivot(addTacitPage, UIAnchor.Center, UIAroundPivot.Center)
		
		local Bg2 = GUI.ImageCreate(Bg, "Bg2", "1800400200", 0, -15, false, 260, 200)
		SetAnchorAndPivot(Bg2, UIAnchor.Center, UIAroundPivot.Center)
		

		local closeBtn = GUI.ButtonCreate(Bg, "closeBtn", "1800302120", -23, 22, Transition.ColorTint)
		SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.Center)
		GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "MountUI", "OnAddTacitClose")
	
		local useBtn = GUI.ButtonCreate( Bg, "useBtn", "1800402110", 90, 110, Transition.ColorTint, "使用", 80, 40, false);
		SetAnchorAndPivot(useBtn, UIAnchor.Center, UIAroundPivot.Center)
		GUI.ButtonSetTextFontSize(useBtn, 18)
		GUI.ButtonSetTextColor(useBtn, colorDark)
		GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "MountUI", "OnUseTacitItem")
		
		
		curAddTatic = GUI.CreateStatic(Bg, "curAddTatic", "", 100, 110, 450, 50)
		GUI.StaticSetAlignment(curAddTatic, TextAnchor.MiddleLeft)
		GUI.SetColor(curAddTatic, UIDefine.BrownColor)
		UILayout.SetAnchorAndPivot(curAddTatic, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(curAddTatic, 22)
		_gt.BindName(curAddTatic, "curAddTatic")
		
		
		addTacitScroll = GUI.LoopScrollRectCreate(Bg, "addTacitScroll", 0, -10, 260, 170,
		"MountUI", "CreateTacitItem", "MountUI", "RefreshAddTacitScroll", 0, false, Vector2.New(80, 81), 3, UIAroundPivot.Top, UIAnchor.Top);
		UILayout.SetSameAnchorAndPivot(addTacitScroll, UILayout.Center)
		_gt.BindName(addTacitScroll, "addTacitScroll")
	end
	
	
	MountUI.CurTacitItem = nil
	MountUI.UseTacitItemList = {}
	
	GUI.LoopScrollRectSetTotalCount(addTacitScroll, math.max(#MountUI.TacitItemList,6)) 
	GUI.LoopScrollRectRefreshCells(addTacitScroll)
	
	--重置当前增长值
	MountUI.SetCurAddTacitNum()
	
	GUI.SetVisible(addTacitPage,true)
end

function MountUI.OnAddTacitClose()
	local addTacitPage = _gt.GetUI("addTacitPage")
	GUI.SetVisible(addTacitPage,false)
	MountUI.CurTacitItem = nil
	MountUI.UseTacitItemList = {}
end

function MountUI.CreateTacitItem()
	local addTacitScroll = _gt.GetUI("addTacitScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(addTacitScroll)
	local Item = ItemIcon.Create(Bg2, "TacitItem"..curCount, 0, 0)
	UILayout.SetSameAnchorAndPivot(Item,UILayout.Center)
	Item:RegisterEvent(UCE.PointerUp)
	Item:RegisterEvent(UCE.PointerDown)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "MountUI", "OnTacitItemClick")
	GUI.RegisterUIEvent(Item, UCE.PointerDown, "MountUI", "OnTacitItemDown")
	GUI.RegisterUIEvent(Item, UCE.PointerUp, "MountUI", "OnTacitItemUp")
	
	local select_ = GUI.ImageCreate(Item, "select_", "1800707330", 0,-1, false, 80, 81)
    SetAnchorAndPivot(select_, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(select_,false)

	local CutDownBtn = GUI.ButtonCreate(Item,"CutDownBtn","1800402140",24,-24,Transition.ColorTint,"",35,35,false,false)
    UILayout.SetSameAnchorAndPivot(CutDownBtn, UILayout.Center)	
	GUI.RegisterUIEvent(CutDownBtn, UCE.PointerClick, "MountUI", "OnTacitCutDownClick")
	GUI.SetVisible(CutDownBtn,false)
	
	return Item	
end

function MountUI.RefreshAddTacitScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local Item = GUI.GetByGuid(guid)
	local select_ = GUI.GetChild(Item,"select_")
	local CutDownBtn = GUI.GetChild(Item,"CutDownBtn")
	index = index +1 
	
	if index <= #MountUI.TacitItemList then
		local tb = MountUI.TacitItemList[index]
		local ItemDB = DB.GetOnceItemByKey2(tb.keyname)
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Icon,tostring(ItemDB.Icon))
		GUI.ItemCtrlSetElementValue(Item,eItemIconElement.Border,UIDefine.ItemIconBg[ItemDB.Grade])
		GUI.SetData(Item,"keyname",tb.keyname)
		GUI.SetData(Item,"bind",tb.bind)
		GUI.SetData(Item,"ItemId",ItemDB.Id)
		
		if tb.num ~=0 then
			GUI.SetData(Item,"limit",tb.num)
			local num0 = MountUI.UseTacitItemList[tb.keyname.."_"..tb.bind] or 0
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,num0.."/"..tb.num)
			GUI.ItemCtrlSetIconGray(Item,false)
			if num0 > 0 then
				--减少按钮出现
				GUI.SetVisible(CutDownBtn,true)
			else
				GUI.SetVisible(CutDownBtn,false)
			end
			--绑定
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,tb.bind == 1 and "1800707120" or nil)
		else
			GUI.SetVisible(CutDownBtn,false)
			GUI.ItemCtrlSetIconGray(Item,true)
			GUI.SetData(Item,"limit",nil)
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.RightBottomNum,"")
			GUI.ItemCtrlSetElementValue(Item,eItemIconElement.LeftTopSp,nil)
		end
	
		if MountUI.CurTacitItem and MountUI.CurTacitItem == tb.keyname..tb.bind then
			GUI.SetVisible(select_,true)
		else
			GUI.SetVisible(select_,false)
		end
	else
		GUI.SetVisible(CutDownBtn,false)
		ItemIcon.SetEmpty(Item)
		GUI.SetVisible(select_,false)
		GUI.SetData(Item,"keyname",nil)
		GUI.SetData(Item,"bind",nil)
		GUI.SetData(Item,"limit",nil)
	end

end

--使用默契值道具
function MountUI.OnUseTacitItem()
	if next(MountUI.UseTacitItemList) then
		local item_list = ""
		for k ,v in pairs(MountUI.UseTacitItemList) do
			local tb = string.split(k,"_")
			item_list = item_list..tb[1].."_"..v.."_"..tb[2].."_"
		end
		CL.SendNotify(NOTIFY.SubmitForm, "FormMount","AddTacitNumByItem", MountUI.CurMountID,item_list,GlobalProcessing.MountsVersion)
	end

end

--减少
function MountUI.OnTacitCutDownClick(guid)
	local item = GUI.GetParentElement(GUI.GetByGuid(guid))
	local keyname = GUI.GetData(item,"keyname")
	local bind = GUI.GetData(item,"bind")
	MountUI.UseTacitItemList[keyname.."_"..bind] = math.max(MountUI.UseTacitItemList[keyname.."_"..bind] - 1 ,0)
	local addTacitScroll = _gt.GetUI("addTacitScroll")
	GUI.LoopScrollRectRefreshCells(addTacitScroll)
	
	MountUI.SetCurAddTacitNum()
end

function MountUI.OnTacitItemClick(guid)
	local item = GUI.GetByGuid(guid)
	local keyname = GUI.GetData(item,"keyname")
	local bind = GUI.GetData(item,"bind")
	
	if keyname and  keyname ~= "" then
		local tips = _gt.GetUI("TacitItemTips")
		if not tips then
			MountUI.CurTacitItem = keyname..bind
			--tips
			local itemId = GUI.GetData(item,"ItemId")
			local parent = _gt.GetUI("addTacitPage")
			local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -380, -70, 62)  --创造提示
			GUI.SetData(itemtips, "ItemId", tostring(itemId))
			_gt.BindName(itemtips,"TacitItemTips")
			local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
			UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
			GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
			GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
			GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"MountUI","OnClickTacitItemWayBtn")
			GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
			GUI.AddWhiteName(itemtips, GUI.GetGuid(item))	
		end
		MountUI.CurTacitItem = keyname..bind
		local limit = GUI.GetData(item,"limit")
		if tonumber(limit) then
			MountUI.CurTacitFuncPar = keyname.."_"..bind.."_"..limit
			MountUI.CurTacitItemGuid = guid
			MountUI.TacitItemTimerFunc()
		end
	end
end

function MountUI.OnTacitItemDown(guid)
	local item = GUI.GetByGuid(guid)
	local keyname = GUI.GetData(item,"keyname")
	local bind = GUI.GetData(item,"bind")
	if keyname and  keyname ~= "" then
			
		local limit = GUI.GetData(item,"limit")
		if tonumber(limit) then
			MountUI.CurTacitFuncPar = keyname.."_"..bind.."_"..limit
			MountUI.CurTacitItemGuid = guid
			if MountUI.TacitItemTimer == nil then
				MountUI.TacitItemTimer = Timer.New(MountUI.TacitItemTimerFunc, 0.2,-1)
			else
				MountUI.TacitItemTimer:Stop()
				MountUI.TacitItemTimer:Reset(MountUI.TacitItemTimerFunc,0.2,-1)
			end		
			
			MountUI.TacitItemTimer:Start()
		else
			if MountUI.TacitItemTimer then
				MountUI.TacitItemTimer:Stop()
			end
		end
    end
	
	
	
		
end

function MountUI.OnTacitItemUp(guid)
	if MountUI.TacitItemTimer then
		MountUI.TacitItemTimer:Stop()
	end
	
	local addTacitScroll = _gt.GetUI("addTacitScroll")
	GUI.LoopScrollRectRefreshCells(addTacitScroll)	
end


function MountUI.TacitItemTimerFunc()
	if MountUI.CurTacitFuncPar then
		local Par = string.split(MountUI.CurTacitFuncPar,"_")
		local keyname = Par[1]
		local bind = Par[2]
		local limit = tonumber(Par[3])
	
		if MountUI.UseTacitItemList[keyname.."_"..bind] then
			MountUI.UseTacitItemList[keyname.."_"..bind] = math.min(MountUI.UseTacitItemList[keyname.."_"..bind] + 1 ,tonumber(limit))
		else
			MountUI.UseTacitItemList[keyname.."_"..bind] = 1
		end
		
		
		local item = GUI.GetByGuid(MountUI.CurTacitItemGuid)
		GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,MountUI.UseTacitItemList[keyname.."_"..bind].."/"..limit)
		
		MountUI.SetCurAddTacitNum()
	end

end

function MountUI.OnClickTacitItemWayBtn()
	local tips = _gt.GetUI("TacitItemTips")
	if tips then
        Tips.ShowItemGetWay(tips,0)
    end
end


function MountUI.SetCurAddTacitNum()
	local curAddTatic = _gt.GetUI("curAddTatic")
	local num = 0
	if MountUI.UseTacitItemList and next(MountUI.UseTacitItemList) then
		for k ,v in pairs(MountUI.UseTacitItemList) do
			local tb = string.split(k,"_")
			local value = GlobalProcessing.MountsTacitNumItem[tb[1]].addpoint
			num = num + v*(value)
		end
		if MountUI.Tacit + tonumber(num) >= MountUI.MountStageConfig["MaxTacitNum"] then
			CL.SendNotify(NOTIFY.ShowBBMsg, "使用前请检查所选中增加默契值是否已超上限，避免道具过度浪费")
		end
	end
	GUI.StaticSetText(curAddTatic,"已选择：+"..num)	
end


function MountUI.RefreshOnTacitItemUsed()
	MountUI.OnAddTacitClose()
	MountUI.RefreshGradeBtnAndTacit()
end


function MountUI.UpDataOnNewVersion()
	MountUI.InitData()
	MountUI.Refresh()
end


