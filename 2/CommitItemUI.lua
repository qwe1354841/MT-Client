CommitItemUI = {}
require "UILayout"

local ItemIconInfo = {}
ItemIconInfo.Icon = "1800400050"
ItemIconInfo.Bg = "1800400060"
ItemIconInfo.Select = "1800600160"
ItemIconInfo.QualityRes = UIDefine.ItemIconBg
ItemIconInfo.QualityCor = UIDefine.GradeColor

CommitItemUI.commit_item = true
CommitItemUI.commitQuestID = 0
CommitItemUI.task_id = 0
CommitItemUI.guid = {}
CommitItemUI.itemNum = {}
CommitItemUI.requireNum = {}
CommitItemUI.haveMax = {}
CommitItemUI.pet = {}
CommitItemUI.ItemIconTimer = nil
CommitItemUI.ItemScroll = nil
CommitItemUI.PetScroll = nil
CommitItemUI.PetIndex = -1
CommitItemUI.SelectPetItem = nil

function CommitItemUI.Main(parameter)
    test("CommitItemUI.Main")

    print("CommitItemUI params : "..parameter)
    CommitItemUI.InitData(parameter)

    local panel = GUI.WndCreateWnd("CommitItemUI", "CommitItemUI", 0, 0)
    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)

    local max = 0
    local panelBg = nil
    local subBtn = nil
    --道具
    if CommitItemUI.commit_item then
        max = math.max(#CommitItemUI.guid, 18)
        --上交道具
        panelBg = UILayout.CreateFrame_WndStyle2(panel, "上交道具", 560, 435)
        GUI.RegisterUIEvent(GUI.GetChild(panelBg, "closeBtn"), UCE.PointerClick, "CommitItemUI", "Exit")
        local scrollBg = GUI.ImageCreate(panelBg, "scrollBg", "1800400010", -3, -30, false, 509, 274)
        CommitItemUI.ItemScroll = GUI.LoopScrollRectCreate(panelBg,"scroll", -3, -30, 485, 238,
                "CommitItemUI","CreatIconPool","CommitItemUI","OnRefreshItem",0, false, Vector2.New(80, 80),6, UIAroundPivot.Top, UIAnchor.Top)
        GUI.ScrollRectSetChildSpacing(CommitItemUI.ItemScroll, Vector2.New(0, 0))
        GUI.LoopScrollRectSetTotalCount(CommitItemUI.ItemScroll, max)
        subBtn = GUI.ButtonCreate(panelBg, "subBtn", "1800402080", -5, 172, Transition.ColorTint, "上交", 140, 47, false)
        local txt = GUI.CreateStatic(panelBg, "txt", "", 0, 0)
    else
        max = math.max(#CommitItemUI.guid)
        --上交宠物
        panelBg = UILayout.CreateFrame_WndStyle2(panel, "上交宠物",560, 580)
        GUI.SetPositionX(panelBg, 17)
        GUI.SetPositionY(panelBg, -18)
        GUI.RegisterUIEvent(GUI.GetChild(panelBg, "closeBtn"), UCE.PointerClick, "CommitItemUI", "Exit")
        local scrollBg = GUI.ImageCreate(panelBg, "scrollBg", "1800400010", -3, -30, false, 509, 408)
        CommitItemUI.PetScroll = GUI.LoopScrollRectCreate(panelBg,"scroll", -3, -30, 560, 400,
                "CommitItemUI","CreatPetPool","CommitItemUI","OnRefreshPet",0, false, Vector2.New(490, 100),1, UIAroundPivot.Top, UIAnchor.Top)
        GUI.ScrollRectSetChildSpacing(CommitItemUI.PetScroll, Vector2.New(0, 0))
        GUI.LoopScrollRectSetTotalCount(CommitItemUI.PetScroll, CommitItemUI.guid~=nil and #CommitItemUI.guid or 0)
        subBtn = GUI.ButtonCreate(panelBg, "subBtn", "1800402080", 4, 242, Transition.ColorTint, "上交", 118, 47, false)
        local txt = GUI.CreateStatic(panelBg, "tip", "点击头像可查看宠物详情", 0, 195, 340, 30)
        GUI.StaticSetFontSize(txt, 23)
        GUI.SetColor(txt, UIDefine.Brown4Color)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    end
    GUI.SetIsOutLine(subBtn, true)
    GUI.ButtonSetTextFontSize(subBtn, 22)
    GUI.ButtonSetTextColor(subBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(subBtn, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(subBtn, 1)
    GUI.RegisterUIEvent(subBtn, UCE.PointerClick, "CommitItemUI", "OnSubmitItem")
end

function CommitItemUI.OnDestroy()
end

function CommitItemUI.InitData(parameter)
    CommitItemUI.commit_item = true
    CommitItemUI.commitQuestID = 0
    CommitItemUI.task_id = 0
    CommitItemUI.guid = {}
    CommitItemUI.itemNum = {}
    CommitItemUI.requireNum = {}
    CommitItemUI.haveMax = {}
    CommitItemUI.pet = {}
    CommitItemUI.ItemIconTimer = nil
    CommitItemUI.ItemScroll = nil
    CommitItemUI.PetScroll = nil
    CommitItemUI.PetIndex = -1
    CommitItemUI.SelectPetItem = nil

    parameter = string.split(parameter, "#")
    if #parameter >= 4 then
        CommitItemUI.commit_item = (parameter[1]=="1" and true or false)
        CommitItemUI.commitQuestID = tonumber(parameter[2])
        local guidList = string.len(parameter[3])>0 and parameter[3] or ""
        local numList = string.len(parameter[4])>0 and parameter[4] or ""
        local haveList = CommitItemUI.commit_item and string.len(parameter[5])>0 and parameter[5] or ""

        if guidList ~= nil and string.len(guidList) > 0 then
            guidList = string.split(guidList, ",")
            local Count = #guidList
            for i = 1, Count do
                guidList[i] = TOOLKIT.Str2uLong(guidList[i])
            end
        end
        if numList ~= nil and string.len(numList) > 0 then
            numList = string.split(numList, ",")
            local Count = #numList
            CommitItemUI.itemNum = {}
            for i = 1, Count do
                numList[i] = tonumber(numList[i])
                CommitItemUI.itemNum[i] = 0
            end
        end
        if haveList ~= nil and string.len(haveList) > 0 then
            haveList = string.split(haveList, ",")
            local Count = #haveList
            for i = 1, Count do
                haveList[i] = tonumber(haveList[i])
            end
        end

        CommitItemUI.guid = guidList
        CommitItemUI.requireNum = numList
        CommitItemUI.haveMax = haveList
    end
end

function CommitItemUI.UnSelect(index, item)
    if #CommitItemUI.guid >= index then
        CommitItemUI.itemNum[index] = math.max(CommitItemUI.itemNum[index] - 1, 0)
        CommitItemUI.ShowReduceBtn(item, CommitItemUI.itemNum[index]>0)
    end
    if CommitItemUI.itemNum[index]== nil or CommitItemUI.itemNum[index]<=0 then
        GUI.ItemCtrlUnSelect(item)
    end
end

function CommitItemUI.Select(index, item)
    if #CommitItemUI.guid >= index then
        local num = CommitItemUI.itemNum[index]
        CommitItemUI.itemNum[index] = math.min(CommitItemUI.itemNum[index] + 1, math.min(CommitItemUI.requireNum[index], CommitItemUI.haveMax[index]))
        if num == CommitItemUI.haveMax[index] and num < CommitItemUI.requireNum[index] then
            CL.SendNotify(NOTIFY.ShowBBMsg, "此道具你只有"..num.."个，无法继续增加")
        end
    end

    GUI.ItemCtrlSelect(item)
    CommitItemUI.ShowReduceBtn(item, true)
end

--创建或刷新icon
function CommitItemUI.CreateIcon(key, i, parent, icon)
    if icon == nil then
        icon = ItemIcon.Create(parent, key, 0, 0)
    end
    if i <= #CommitItemUI.guid then
        --模板ID
        local itemData = LD.GetItemDataByGuid(CommitItemUI.guid[i])
        if itemData == nil then
            itemData = LD.GetItemDataByGuid(CommitItemUI.guid[i], item_container_type.item_container_gem_bag)
        end
        if itemData ~= nil then
            --判断是否选中
            if CommitItemUI.itemNum[i]>0 then
                GUI.ItemCtrlSelect(icon)
            else
                GUI.ItemCtrlUnSelect(icon)
            end

            --个数
            ItemIcon.BindItemData(icon,itemData,false)
            GUI.ItemCtrlSetElementValue(icon,eItemIconElement.RightBottomNum, "0/"..CommitItemUI.requireNum[i])
            local reduce = GUI.GetChild(icon, "reduce")
            if reduce == nil then
                local reduce = GUI.ButtonCreate(icon, "reduce","1800702070",0,0,Transition.ColorTint)
                GUI.RegisterUIEvent(reduce, UCE.PointerClick , "CommitItemUI", "OnClickItemIconReduce" )
    			UILayout.SetSameAnchorAndPivot(reduce, UILayout.TopRight)
                GUI.SetVisible(reduce,false)
            end
        end
    else
        GUI.ItemCtrlUnSelect(icon)
        GUI.ItemCtrlSetElementValue(icon,eItemIconElement.RightBottomNum, "")
        GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Icon, nil)
        CommitItemUI.ShowReduceBtn(icon, false)
    end
    return icon
end

function CommitItemUI.ShowReduceBtn(item, isShow)
    local reduce = GUI.GetChild(item, "reduce")
    if reduce ~= nil then
        GUI.SetVisible(reduce, isShow)
    end
end

--创建宠物节点
function CommitItemUI.CreatePetIcon(key, i, parent, item)
    local name = nil
    local lv = nil
    local typepic = nil
    local icon = nil
    if item == nil then
        item = GUI.ItemCtrlCreate(parent, key, "1800700030", 0, 0)
        name = GUI.CreateStatic(item, "name", "", 100, -17, 200, 30)
        GUI.StaticSetFontSize(name, 24)
        GUI.SetAnchor(name, UIAnchor.Left)
        GUI.StaticSetAlignment(name, TextAnchor.MiddleLeft)
        GUI.SetPivot(name, UIAroundPivot.Left)
        GUI.SetColor(name, UIDefine.BrownColor)

        lv = GUI.CreateStatic(item, "lv", "", 100, 24, 200, 30)
        GUI.StaticSetFontSize(lv, 22)
        GUI.SetAnchor(lv, UIAnchor.Left)
        GUI.StaticSetAlignment(lv, TextAnchor.MiddleLeft)
        GUI.SetPivot(lv, UIAroundPivot.Left)
        GUI.SetColor(lv, UIDefine.Yellow2Color)

        typepic = GUI.ImageCreate(item, "typepic", "", 218, 0)
        icon = GUI.ItemCtrlCreate(item, "icon", ItemIconInfo.Icon, -197, -1)
		GUI.RegisterUIEvent(icon, UCE.PointerClick, "CommitItemUI", "OnClickPetIcon")
        GUI.RegisterUIEvent(item, UCE.PointerClick, "CommitItemUI", "OnClickPet")
    else
        name = GUI.GetChild(item, "name")
        lv = GUI.GetChild(item, "lv")
        typepic = GUI.GetChild(item, "typepic")
        icon = GUI.GetChild(item, "icon")
    end
    GUI.SetVisible(item, true)
    GUI.SetData(item, "index", i - 1)
    local count =#CommitItemUI.guid
    if count == 1 then
        CommitItemUI.PetIndex = 0
    end
    if i <= count then
        --模板ID
        local modleId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, CommitItemUI.guid[i])))
        --test(modleId)
        if modleId ~= 0 then
            local petInfo = DB.GetOncePetByKey1(modleId)
            --判断是否选中
            if CommitItemUI.PetIndex == i-1 then
                GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border, "1800700040")
            else
                GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border, "1800700030")
            end
            --icon
            if petInfo ~= nil then
                test(" petInfo.Head  : "..tostring(petInfo.Head))
                GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Icon, tostring(petInfo.Head))
                GUI.ItemCtrlSetElementRect(icon,eItemIconElement.Icon, 0,-1,70,70)

                GUI.StaticSetText(name, petInfo.Name)
                GUI.ImageSetImageID(typepic, UIDefine.PetType[petInfo.Grade])
				GUI.SetData(icon,"PetGUID",CommitItemUI.guid[i])
            end
            GUI.StaticSetText(lv, "等级：" .. tostring(LD.GetPetAttr(RoleAttr.RoleAttrLevel, CommitItemUI.guid[i])))
            return item
        end
    else
        GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Icon, nil)
        GUI.SetVisible(name, false)
        GUI.SetVisible(lv, false)
        GUI.SetVisible(typepic, false)
    end
    return item
end

function CommitItemUI.SelectPet(item, nIndex)
    local index = item ~= nil and tonumber(GUI.GetData(item, "index")) or nIndex
    local select = CommitItemUI.PetIndex ~= index and true or false
    if select then
        CommitItemUI.PetIndex = index
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border, "1800700040")
    else
        CommitItemUI.PetIndex = -1
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border, "1800700030")
    end
end

function CommitItemUI.Init(parameter)
    --[[
    local commit_type = GUI.GetData(GUI.GetWnd("CommitItemUI"), commit_type_key)
    if scriptname ~= "CommitItemUI" then
        return
    end
    GUI.CloseWnd("BagUI")
    local scroll = GUI.Get("CommitItemUI/panelBg/scroll")
    local subBtn = GUI.Get("CommitItemUI/panelBg/subBtn")
    local txt = GUI.Get("CommitItemUI/panelBg/txt")
    --任务
    if commit_type == "0" then
        GUI.SetVisible(txt, false)
    end
    GUI.LoopScrollRectRefreshCells(scroll)
    CL.RegisterMessage(GM.RefreshBag, "CommitItemUI", "RefreshBag")
    --]]
end

function CommitItemUI.RefreshBag()
    local scroll = GUI.Get("CommitItemUI/panelBg/scroll")
    GUI.LoopScrollRectRefreshCells(scroll)
end

function CommitItemUI.Exit()
    CommitItemUI.RemoveItemIconEvent()
    CL.UnRegisterMessage(GM.RefreshBag, "CommitItemUI", "RefreshBag")
    GUI.DestroyWnd("CommitItemUI")
end

function CommitItemUI.OnRefreshPet(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local icon = GUI.GetByGuid(guid)
    local scroll = GUI.Get("CommitItemUI/panelBg/scroll")
    if icon ~= nil then
        CommitItemUI.CreatePetIcon("", index, scroll, icon)
    end
end

function CommitItemUI.OnRefreshItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local icon = GUI.GetByGuid(guid)
    GUI.SetData(icon, "index", index)
    if icon ~= nil then
        CommitItemUI.CreateIcon("", index, CommitItemUI.ItemScroll, icon)
    end
    if index==1 and CommitItemUI.requireNum ~= nil and #CommitItemUI.requireNum==1 and CommitItemUI.requireNum[1] == 1 then
        CommitItemUI.OnClickItemIcon(GUI.GetGuid(icon))
    end
end

function CommitItemUI.OnClickItemIconReduce(guid)
    local item = GUI.GetParentElement(GUI.GetByGuid(guid))
    local index = GUI.ItemCtrlGetIndex(item) + 1
    CommitItemUI.UnSelect(index, item)

    GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum, CommitItemUI.itemNum[index] .. '/' .. CommitItemUI.requireNum[index])
end

function CommitItemUI.OnClickPet(guid)
    if CommitItemUI.SelectPetItem ~= nil then
        GUI.ItemCtrlSetElementValue(CommitItemUI.SelectPetItem,eItemIconElement.Border, "1800700030")
    end
    local item = GUI.GetByGuid(guid)
    CommitItemUI.SelectPet(item)
    CommitItemUI.SelectPetItem = item
	
end

--点击头像查看宠物详情
function CommitItemUI.OnClickPetIcon(guid)
	local icon = GUI.GetByGuid(guid)
	local guid = GUI.GetData(icon,"PetGUID")
	if guid then
		GUI.OpenWnd("PetInfoUI","2,"..tostring(guid))
	end	
end

function CommitItemUI.OnClickItemIcon(guid)
    local item = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(item, "index"))
    if index <= #CommitItemUI.guid then
        local selectGUID = CommitItemUI.guid[index]
        local selectRequireNum = CommitItemUI.requireNum[index]
        local selectID = 0
        local itemData = LD.GetItemDataByGuid(selectGUID)
        if itemData == nil then
            itemData = LD.GetItemDataByGuid(selectGUID, item_container_type.item_container_gem_bag)
        end
        if itemData then
            selectID = itemData.id
        end
        if selectID ~= 0 then
            --同类的道具，需要检测数量
            local count = #CommitItemUI.guid
            local listAlreadyCount = 0
            for i = 1, count do
                if CommitItemUI.itemNum[i] > 0 then
                    local listItemData = LD.GetItemDataByGuid(CommitItemUI.guid[i])
                    if listItemData == nil then
                        listItemData = LD.GetItemDataByGuid(CommitItemUI.guid[i], item_container_type.item_container_gem_bag)
                    end
                    if listItemData and listItemData.id == selectID  then
                        listAlreadyCount = listAlreadyCount + CommitItemUI.itemNum[i]
                    end
                end
            end
            if listAlreadyCount >= selectRequireNum then
                CL.SendNotify(NOTIFY.ShowBBMsg, "已超过需要提交的道具个数")
                return
            end
        end

        CommitItemUI.Select(index,item)

        local reduce = GUI.GetChild(item, "reduce")
        local selected = GUI.ItemCtrlGetElement(item, eItemIconElement.Selected)
        if reduce ~= nil and selected ~= nil then
            GUI.SetDepth(reduce, GUI.GetDepth(selected)+1)
        end
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum, CommitItemUI.itemNum[index] .. '/' .. CommitItemUI.requireNum[index])
    end
end

function CommitItemUI.IsPetCanCommit()
    if CommitItemUI.PetIndex >= 0 and CommitItemUI.PetIndex < #CommitItemUI.guid then
        local index = CommitItemUI.PetIndex + 1
        local petGuid = CommitItemUI.guid[index]
        if LD.GetPetState(PetState.Lock, petGuid) then
            CL.SendNotify(NOTIFY.ShowBBMsg, "宠物已锁定,无法提交")
        elseif LD.GetPetState(PetState.Show, petGuid) then
            CL.SendNotify(NOTIFY.ShowBBMsg, "宠物已展示,无法提交")
        elseif LD.GetPetState(PetState.Lineup, petGuid) then
            CL.SendNotify(NOTIFY.ShowBBMsg, "宠物已参战,无法提交")
        else
            return true
        end
    end
    return false
end

function CommitItemUI.IsSelectItem()
    local Count = #CommitItemUI.itemNum
    for i = 1, Count do
        if CommitItemUI.itemNum[i]>0 then
            return true
        end
    end
    return false
end

function CommitItemUI.OnSubmitItem()
    test("提交道具")
    if CommitItemUI.commit_item and CommitItemUI.IsSelectItem() == false then
        CL.SendNotify(NOTIFY.ShowBBMsg, "未选中任何道具")
        return
    elseif CommitItemUI.commit_item == false and CommitItemUI.PetIndex == -1 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "未选中任何宠物")
        return
    end

    if CommitItemUI.commit_item == false then
        if CommitItemUI.IsPetCanCommit() then
            CL.SendNotify(NOTIFY.QuestOpeUpdate, 5, tostring(CommitItemUI.guid[CommitItemUI.PetIndex + 1])..",1", CommitItemUI.commitQuestID)
            CommitItemUI.Exit()
        end
    else
        local count = #CommitItemUI.itemNum
        local info = ""
        local selectCount = 1
        for i = 1, count do
            if CommitItemUI.itemNum[i] > 0 then
                if selectCount == 1 then
                    info = tostring(CommitItemUI.guid[i])..","..CommitItemUI.itemNum[i]
                else
                    info = info.."#"..tostring(CommitItemUI.guid[i])..","..CommitItemUI.itemNum[i]
                end
                selectCount = selectCount + 1
            end
        end
        CL.SendNotify(NOTIFY.QuestOpeUpdate, 4, info, CommitItemUI.commitQuestID)
        CommitItemUI.Exit()
    end
end

--道具
function CommitItemUI.CreatIconPool()
    local scroll = GUI.Get("CommitItemUI/panelBg/scroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local icon = CommitItemUI.CreateIcon("itemIcon" .. curCount, curCount + 1, scroll, nil)
    GUI.RegisterUIEvent(icon, UCE.PointerClick, "CommitItemUI", "OnClickItemIcon")
    icon:RegisterEvent(UCE.PointerUp)
    icon:RegisterEvent(UCE.PointerDown)
    GUI.RegisterUIEvent(icon, UCE.PointerDown, "CommitItemUI", "OnItemIconPointDown")
    GUI.RegisterUIEvent(icon, UCE.PointerUp, "CommitItemUI", "OnItemIconPointUp")
    return icon
end

--宠物
function CommitItemUI.CreatPetPool()
    local scroll = GUI.Get("CommitItemUI/panelBg/scroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    return CommitItemUI.CreatePetIcon("itemIcon" .. curCount, curCount + 1, scroll, nil)
end

function CommitItemUI.OnItemIconPointDown(guid)
    local fun = function()
        CommitItemUI.OnClickItemIcon(guid)
    end
    CommitItemUI.RemoveItemIconEvent()
    CommitItemUI.ItemIconTimer = Timer.New(fun, 0.2, -1)
    CommitItemUI.ItemIconTimer:Start()
end

function CommitItemUI.OnItemIconPointUp(key, guid)
    CommitItemUI.RemoveItemIconEvent()
end

function CommitItemUI.RemoveItemIconEvent()
    if CommitItemUI.ItemIconTimer ~= nil then
        CommitItemUI.ItemIconTimer:Stop()
        CommitItemUI.ItemIconTimer = nil
    end
end
