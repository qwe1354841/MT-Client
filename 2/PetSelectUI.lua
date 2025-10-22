local PetSelectUI = {}


-------------------------------------------------------

_G.PetSelectUI = PetSelectUI
local _gt = UILayout.NewGUIDUtilTable();
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local PetType = {
    [1] = "1801408060";
    [2] = "1801408070";
    [3] = "1801408080";
    [4] = "1801408090";
    [5] = "1801408100";
    [6] = "1801408110";
    [7] = "1801408120";
    [8] = "1801408130";
    [9] = "1801408140";
}

local PetGuid = nil
local SelectEatPetList = {}
local SelectPetList = {}
local petList ={}
function PetSelectUI.Main(parameter)
	SelectEatPetList={}
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("PetSelectUI", "PetSelectUI", 0, 0);
	GUI.SetVisible(panel, false)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "选择宠物", 515,425,"PetSelectUI", "OnCloseBtnClick", _gt)
end


function PetSelectUI.OnShow(parameter)
    local wnd = GUI.GetWnd("PetSelectUI")
    if wnd then
        GUI.SetVisible(wnd, true)
    end
	PetGuid = parameter
	PetSelectUI.CreateBase()
end

function PetSelectUI.OnCloseBtnClick()
	GUI.DestroyWnd("PetSelectUI")
end



function PetSelectUI.CreateBase()
	local panelBg = GUI.Get("PetSelectUI/panelBg")
	local PetSelectIconBg = GUI.ImageCreate(panelBg,"PetSelectIconBg","1800300040",0,25,false,455,220)
	
	local PetSelectText = GUI.CreateStatic(panelBg,"PetSelectText","仅与有主宠品质和星级一样的宠物会被筛选显示在此界面",0,-115,455,100,"system",true)
	GUI.SetColor(PetSelectText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(PetSelectText, 22)
	GUI.StaticSetAlignment(PetSelectText, TextAnchor.MiddleLeft)
	
	local PetSelectTipBtn = GUI.ButtonCreate( panelBg, "PetSelectTipBtn", "1800702030", -220 , -173 , Transition.ColorTint)
	SetAnchorAndPivot(PetSelectTipBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(PetSelectTipBtn, UCE.PointerClick, "PetSelectUI", "OnPetSelectTipBtnClick")	
	_gt.BindName(PetSelectTipBtn, "PetSelectTipBtn")


	local SelectPetScrollWnd = GUI.ScrollRectCreate(PetSelectIconBg,"SelectPetScrollWnd", 0, 3, 432, 204, 0, false, Vector2.New(78, 78),  UIAroundPivot.TopLeft, UIAnchor.TopLeft, 5)
    GUI.SetAnchor(SelectPetScrollWnd, UIAnchor.Center)
    GUI.SetPivot(SelectPetScrollWnd, UIAroundPivot.Center)
    GUI.ScrollRectSetChildAnchor(SelectPetScrollWnd, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(SelectPetScrollWnd, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(SelectPetScrollWnd, Vector2.New(10, 10))
	
--可选数量
	local PetSelectNumText = GUI.CreateStatic(panelBg,"PetSelectNumText","可选数量",-125,170,200,100,"system",true)
	GUI.SetColor(PetSelectNumText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(PetSelectNumText, 22)
	GUI.StaticSetAlignment(PetSelectNumText, TextAnchor.MiddleLeft)
	local PetSelectNum1 = GUI.CreateStatic(panelBg,"PetSelectNum1","0",-30,170,200,100,"system",true)
	GUI.SetColor(PetSelectNum1, UIDefine.BrownColor);
	GUI.StaticSetFontSize(PetSelectNum1, 22)
	GUI.StaticSetAlignment(PetSelectNum1, TextAnchor.MiddleLeft)
	_gt.BindName(PetSelectNum1,"PetSelectNum1")
	
	local PetSelectNum2 = GUI.CreateStatic(panelBg,"PetSelectNum2","5",-15,170,200,100,"system",true)
	GUI.SetColor(PetSelectNum2, UIDefine.BrownColor);
	GUI.StaticSetFontSize(PetSelectNum2, 22)
	GUI.StaticSetAlignment(PetSelectNum2, TextAnchor.MiddleLeft)
	_gt.BindName(PetSelectNum2,"PetSelectNum2")
	
	local ConfirmBtn = GUI.ButtonCreate(panelBg, "ConfirmBtn", "1800402080", 0, 170, Transition.ColorTint, "")
    SetAnchorAndPivot(ConfirmBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(ConfirmBtn, UCE.PointerClick, "PetSelectUI", "OnConfirmBtnClick")

    local BreachBtnText = GUI.CreateStatic( ConfirmBtn, "BreachBtnText", "确认", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(BreachBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(BreachBtnText, 26)
    GUI.StaticSetAlignment(BreachBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(BreachBtnText, true)
    GUI.SetOutLine_Color(BreachBtnText, Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(BreachBtnText, 1)

    for i = 1, 15 do
        PetSelectUI.CreateSelectPetItem(i, SelectPetScrollWnd)
    end
	PetSelectUI.ShowPetList()

end

function PetSelectUI.OnPetSelectTipBtnClick()
	local tips = GUI.TipsCreate(GUI.Get("PetSelectUI/panelBg"), "Tips", 0, 0, 490, -50) 
    GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
	local tipstext = GUI.CreateStatic(tips,"tipstext","注意：出战、展示、锁定的宠物无法被选择。",0,0,450,80,"system", true)
	GUI.StaticSetFontSize(tipstext,22)

end

function PetSelectUI.CreateSelectPetItem(index, parent)
    if parent == nil then
        return
    end

    local key = "SelectPet" .. index
    local item = GUI.GetChild(parent, key)
    if item ~= nil then
        return
    end
	
	 item = GUI.ItemCtrlCreate( parent, key, "1800400050", 0, 0,0, 0, false)
	 GUI.SetData(item, "index", index)

    GUI.RegisterUIEvent(item, UCE.PointerClick, "PetSelectUI", "OnPetItemClick")


	local selectEffect = GUI.ImageCreate(item,"selectEffect"..index, "1801401050", 0, 0)
	GUI.SetAnchor(selectEffect, UIAnchor.Center)
	GUI.SetPivot(selectEffect, UIAroundPivot.Center)
	local selectImg = GUI.ImageCreate(selectEffect,"selectImg", "1801407090", 0, 0)
	GUI.SetAnchor(selectImg, UIAnchor.Center)
	GUI.SetPivot(selectImg, UIAroundPivot.Center)
	GUI.SetVisible(selectEffect,false)

end

function PetSelectUI.ShowPetList()
	petList ={}
	-- PetUI.petGuidList = LD.GetPetGuids()
	petList = LD.GetPetGuids(pet_container_type.pet_container_panel)
	SelectPetList = {}
	local SelectPetScrollWnd = GUI.Get("PetSelectUI/panelBg/PetSelectIconBg/SelectPetScrollWnd")
    if SelectPetScrollWnd == nil then
        return
    end
	if petList.Count == 0 then
		return
	end
	local star1 =LD.GetPetIntCustomAttr("PetStarLevel",PetGuid,pet_container_type.pet_container_panel)
	local id1 = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, PetGuid)
	local moban1 =DB.GetOncePetByKey1(id1)
	local star2 =5
	local id2 = 0
	local moban2 = nil
	for i = 0 , petList.Count-1 do
		petGuid = petList[i]
		id2 = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, petList[i])
		moban2 =DB.GetOncePetByKey1(id2)
		star2 =LD.GetPetIntCustomAttr("PetStarLevel",petList[i],pet_container_type.pet_container_panel)
		local isLock = LD.GetPetState(PetState.Lock,petGuid)
		local isLineup = LD.GetPetState(PetState.Lineup,petGuid)
		local isShow = LD.GetPetState(PetState.Show, petGuid)
		if not isLock and not isLineup and not isShow then
			if tostring(petGuid) ~= PetGuid then
					if moban2.Type == moban1.Type then
						if star2 == star1 then
							table.insert(SelectPetList, petGuid)
						end
					end
			end
		end
	end
	local PetSelectNum2 = _gt.GetUI("PetSelectNum2")
	local num2 = star1
	GUI.StaticSetText(PetSelectNum2,"/"..num2)
	

	for i=1,#SelectPetList do
		local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, SelectPetList[i])
		local moban =DB.GetOncePetByKey1(id)
		local item = GUI.GetChild(SelectPetScrollWnd,"SelectPet" .. i)
		local LevelAre =UIDefine.GetPetLevelStrByGuid(SelectPetList[i])
		GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,tostring(moban.Head))
		GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,0,67,67)
		--等级
		GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightTopSp,PetType[moban.Type])
		local levelBg = GUI.ItemCtrlGetElement(item,eItemIconElement.RightTopSp)
		local level = GUI.CreateStatic(levelBg,"level", LevelAre, -3, 0, 40, 25)
		GUI.SetAnchor(level, UIAnchor.Center)
		GUI.SetPivot(level, UIAroundPivot.Center)
		GUI.StaticSetFontSize(level, 20)
		GUI.StaticSetAlignment(level, TextAnchor.MiddleCenter)
		--星星
		-- local StarBg = GUI.ItemCtrlGetElement(item,eItemIconElement.Icon)
		local star =LD.GetPetIntCustomAttr("PetStarLevel",SelectPetList[i],pet_container_type.pet_container_panel)
		UILayout.SetSmallStars(star, 6, item)
		--左上角绑定
		local isBind = LD.GetPetState(PetState.Bind, SelectPetList[i])
		if isBind then
			GUI.ItemCtrlSetElementValue(item,eItemIconElement.LeftTopSp ,1800707030)
		end
		--边框
		GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border  ,UIDefine.PetItemIconBg3[moban.Type])
	end
end

local num1=0
local num2 = 0
function PetSelectUI.OnPetItemClick(guid)
	local index = GUI.GetData(GUI.GetByGuid(guid), "index")
	local SelectPetScrollWnd = GUI.Get("PetSelectUI/panelBg/PetSelectIconBg/SelectPetScrollWnd")
	local item = GUI.GetChild(SelectPetScrollWnd,"SelectPet" ..index)
	local selectEffect = GUI.GetChild(item,"selectEffect" ..index)
	local PetSelectNum1 = _gt.GetUI("PetSelectNum1")
	index = tonumber(index)

	if index > #SelectPetList then
		return
	end
------------把多余的格子锁住
	-- for i = 1 ,15 do
		-- local item = GUI.GetChild(SelectPetScrollWnd,"SelectPet" .. i)	
		-- if tonumber(index) > #SelectPetList then	
			-- PetItem.SetLock(item)
		-- end
	-- end
---------------------------
	local star1 =LD.GetPetIntCustomAttr("PetStarLevel",PetGuid,pet_container_type.pet_container_panel)
	num2 = star1
	num1 = #SelectEatPetList
	
	if num1 > num2 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "已超过吞噬数量")
		return
	else
	GUI.SetVisible(selectEffect, PetSelectUI.SetPetGuid(SelectPetList[index]))
	end
	
	num1 = #SelectEatPetList
	GUI.StaticSetText(PetSelectNum1,num1)
	-- if tonumber(index) <= #SelectPetList then	
		--选择效果打开
		-- if GUI.GetVisible(selectEffect) then
		-- GUI.SetVisible(selectEffect,false)
		-- table.remove(SelectEatPetList,index)
		-- else
			-- GUI.SetVisible(selectEffect,true)
		-- table.insert(SelectEatPetList,index,SelectPetList[tonumber(index)])
		-- end
	-- end

end

function PetSelectUI.SetPetGuid(guid)
	for i = 1, #SelectEatPetList do
		if guid == SelectEatPetList[i] then
			table.remove(SelectEatPetList, i)
			return false
		end
	end
	if num1 < num2 then
	table.insert(SelectEatPetList, guid)
	return true
	else
	CL.SendNotify(NOTIFY.ShowBBMsg, "已超过吞噬数量")
	return false
	end
end
PetSelectUI.confirmCallBack = nil
function PetSelectUI.OnConfirmBtnClick()
    if PetSelectUI.confirmCallBack ~= nil then
        PetSelectUI.confirmCallBack(SelectEatPetList)
    end
	-- if SelectEatPetList ~= nil and #SelectEatPetList ~= 0 then
		-- test(SelectEatPetList)
		-- PetUI.SetEatPetList()
		-- PetUI.SetEatPetList(SelectEatPetList)
	-- end
	PetSelectUI.OnCloseBtnClick()
	-- local SwallowedPetGroup = GUI.Get("PetUI/panelBg/pageRefinePanel/tabBreachPanel/middleBg/EatPetScrollWnd/SwallowedPetGroup")
	-- for i = 1 , SelectEatPetList# do
	-- local item = GUI.GetChild(SwallowedPetGroup,"SwallowedPet" .. i)
	-- local petguid = 
	-- GUI.ItemCtrlSetElementValue (item,eitemIconElement.Icon,)
end

function PetSelectUI.SetConfirmCallBack(method)
    PetSelectUI.confirmCallBack = method
end