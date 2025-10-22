local EmojPanelUI = {}

_G.EmojPanelUI = EmojPanelUI
local GuidCacheUtil = nil


------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local fontSize_BigOne = 24
local fontSize_BigTwo = 26
local fontSize = 22

local colorType_DarkYellow = UIDefine.BrownColor
local colorType_LightYellow = UIDefine.Yellow2Color            --淡黄色文字
local colorwhite = Color.white --Color.New(1, 1, 1, 1)
local colorblack = Color.black --Color.New(0, 0, 0, 1)

local emojBtnList = {
    { "emoj_Btn", "表情", "1800902070", "1800902071", "OnEmojBtnClick_EmojPanel" },
    { "inputHistory_Btn", "历史", "1800902060", "1800902061", "OnInputHistoryBtnClick_EmojPanel" },
    { "pet_Btn", "宠物", "1800902080", "1800902081", "OnPetBtnClick_EmojPanel" },
    { "item_Btn", "道具", "1800902050", "1800902051", "OnItemBtnClick_EmojPanel" },
}

local CurSelectPanel = nil
local EmojiBagGuid2Id = {} -- 表情包按钮GUID对应表情包id
local lastSelectEmojBag = nil

local ChatHistoryBtn2Msg = {}

EmojPanelUI.BackToInputGuid = nil

function EmojPanelUI.Main(parameter)
    if parameter == nil then
        test("表情界面需要传入输入框控件guid")
        return
    end
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("EmojPanelUI", "EmojPanelUI", 0, 0)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)

    --GUI.CreateSafeArea(panel)

    local emojPanel_Bg = GUI.ImageCreate(panel, "emojPanel_Bg", "1800900010", -10, -15, false, 900, 253)
    SetAnchorAndPivot(emojPanel_Bg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)

    local closeBtn = GUI.ButtonCreate(emojPanel_Bg, "closeBtn", "1800902040", -140, 30, Transition.None)
    GUI.SetEulerAngles(closeBtn, Vector3.New(0, 0, 90))
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "EmojPanelUI", "OnCloseBtnClick_EmojPanel")

    local rightScr_Bg = GUI.ImageCreate(emojPanel_Bg, "rightScr_Bg", "1800400200", -20, 0, false, 675, 220)
    GuidCacheUtil.BindName(rightScr_Bg, "rightScr_Bg")
    SetAnchorAndPivot(rightScr_Bg, UIAnchor.Right, UIAroundPivot.Right)

    local leftBtnChildSize = Vector2.New(72, 100)
    local leftBtnScr = GUI.ScrollRectCreate(emojPanel_Bg, "leftBtnScr", 25, -15, 165, 220, 0, false, leftBtnChildSize, UIAroundPivot.Top, UIAnchor.Top, 2)
    SetAnchorAndPivot(leftBtnScr, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(leftBtnScr, Vector2.New(20, 15))

    local group = GUI.GroupCreate(emojPanel_Bg, "emojToggleGroup", 0, 0)
    GUI.SetIsToggleGroup(group, true)
    for i = 1, #emojBtnList do
        local data = emojBtnList[i]
        local gr = GUI.GroupCreate(leftBtnScr, "item" .. i, 0, 0)
        local subTab = GUI.CheckBoxCreate(gr, data[1], data[3], data[4], 0, 5, Transition.ColorTint, false, 72, 75)
        GuidCacheUtil.BindName(subTab, data[1])
        local txt = GUI.CreateStatic(subTab, "txt", data[2], 0, 35, 80, 40)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(txt, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.StaticSetFontSize(txt, fontSize_BigTwo)
        GUI.SetColor(txt, colorType_DarkYellow)
        GUI.SetToggleGroupGuid(subTab, GUI.GetGuid(group))
        GUI.RegisterUIEvent(subTab, UCE.PointerClick, "EmojPanelUI", data[5])
    end
end

function EmojPanelUI.OnShow(parameter)
    local panel = GUI.GetWnd("EmojPanelUI")
    if not panel then
        return
    end
    EmojPanelUI.BackToInputGuid = UIDefine.GetParameter1(parameter)
    GUI.SetVisible(panel, true)
    --CurSelectPanel = nil
    local tabName = emojBtnList[1][1]
    local checkTab = GuidCacheUtil.GetUI(tabName)
    if checkTab then
        GUI.CheckBoxSetCheck(checkTab, true)
        EmojPanelUI.OnEmojBtnClick_EmojPanel(GUI.GetGuid(checkTab))
    end
end

---------------------------------------------- start 表情面板相关 start ----------------------------------------------------------
function EmojPanelUI.OnEmojBtnClick_EmojPanel(guid)
    local name = "emoj_ScrBg"
    if  CurSelectPanel then
        test("CurSelectPanel="..CurSelectPanel)
    end
    --if name == CurSelectPanel then --因为上下线重新打开就没有刷出表情包，注释掉则会刷出
    --    test("返回！！！")
    --    return
    --end
    if CurSelectPanel then
        local lastPanel = GuidCacheUtil.GetUI(CurSelectPanel)
        GUI.SetVisible(lastPanel, false)
    end
    CurSelectPanel = name

    local currentSelectScr = GuidCacheUtil.GetUI(name)
    if currentSelectScr == nil then
        local rightScr_Bg = GuidCacheUtil.GetUI("rightScr_Bg")
        local currentSelectScr = GUI.ImageCreate(rightScr_Bg, name, "1800400200", 0, 0, false, 675, 220)
        GuidCacheUtil.BindName(currentSelectScr, name)
        SetAnchorAndPivot(currentSelectScr, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(currentSelectScr, UIDefine.Transparent)

        local scr_Bag = GUI.ScrollRectCreate(currentSelectScr, "scr_Bag", 5, -5, 549, 35, 1, true, Vector2.New(135, 35), UIAroundPivot.Left, UIAnchor.Left, 1)
        GuidCacheUtil.BindName(scr_Bag, "scr_Bag")
        SetAnchorAndPivot(scr_Bag, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.ScrollRectSetHorizontal(scr_Bag, false)
    else
        GUI.SetVisible(currentSelectScr, true)
    end
    EmojPanelUI.OnRefreshEmojBag()
end

function EmojPanelUI.OnRefreshEmojBag()
    local scr_Bag = GuidCacheUtil.GetUI("scr_Bag")
    if scr_Bag == nil then
        test("scr_Bag == nil ")
        return
    end
    EmojiBagGuid2Id = {}
    local allemojiKeys = DB.GetEmoji_BagAllKey1s()
    if not allemojiKeys then
        return
    end
    --使用玩家数据，玩家解锁的表情包才显示
    local emjoyData={}--{1,2}
    local unlockFaceBagStr = LD.GetUnLockFaceBag()
    --test("unlockFaceBagStr="..unlockFaceBagStr)
    if unlockFaceBagStr and unlockFaceBagStr~="" then
        local unlockFaceBag = string.split(unlockFaceBagStr,',')
        --test("unlockFaceBag="..#unlockFaceBag)
        for i = 1, #unlockFaceBag do
            table.insert(emjoyData,tonumber(unlockFaceBag[i]))
        end
    end
    --local emjoyData={1,2} --始终显示
    local count = #emjoyData -- allemojiKeys.Count --获取表情包数量
    test("表情包数量="..count)
    --local childCount = GUI.GetChildCount(scr_Bag)
    if count > 4 then
        GUI.ScrollRectSetHorizontal(scr_Bag, true)
    end
    local selectGuid = nil
    for i = 0, count - 1 do
        local emojKey = emjoyData[i+1] --allemojiKeys[i]
        local emojBag = DB.GetOnceEmoji_BagByKey1(emojKey)
        local name = "emojBag_" .. emojKey
        local emojBagBtn = GUI.GetChild(scr_Bag, name)
        local txt = nil
        if not emojBagBtn then
            emojBagBtn = GUI.ButtonCreate(scr_Bag, name, "1800902090", 5 + 135 * (i - 1), -5, Transition.None, "", 135, 35)
            GUI.SetAnchor(emojBagBtn, UIAnchor.BottomLeft)
            GUI.SetPivot(emojBagBtn, UIAroundPivot.BottomLeft)
            GUI.RegisterUIEvent(emojBagBtn, UCE.PointerClick, "EmojPanelUI", "OnEmojBagBtnClick")
            local btnSelectImage = GUI.ImageCreate(emojBagBtn, "btnSelectImage", "1800902091", 0, 0, false, 135, 35)
            GUI.SetAnchor(btnSelectImage, UIAnchor.Center)
            GUI.SetPivot(btnSelectImage, UIAroundPivot.Center)
            GUI.SetVisible(btnSelectImage, false)

            txt = GUI.CreateStatic(emojBagBtn, "txt", "", 0, 0, 80, 26)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
            GUI.SetAnchor(txt, UIAnchor.Center)
            GUI.SetPivot(txt, UIAroundPivot.Center)
            GUI.StaticSetFontSize(txt, fontSize)
            GUI.SetColor(txt, colorType_DarkYellow)

            --新建的
        else
            GUI.SetVisible(emojBagBtn, true)
            txt = GUI.GetChild(emojBagBtn, "txt")
        end
        EmojiBagGuid2Id[GUI.GetGuid(emojBagBtn)] = emojKey
        if emojBag then
            GUI.StaticSetText(txt, emojBag.Name)
        end

        if i == 0 then
            selectGuid = GUI.GetGuid(emojBagBtn)
        end
    end
    if selectGuid then
        EmojPanelUI.OnEmojBagBtnClick(selectGuid)
    end

    -- if not lastSelectEmojBag then
    --     lastSelectEmojBag = selectGuid
    -- end
    -- if lastSelectEmojBag then
    --     EmojPanelUI.OnEmojBagBtnClick(lastSelectEmojBag)
    -- end
end

function EmojPanelUI.OnEmojBagBtnClick(guid)
    if lastSelectEmojBag == guid then
        return
    end
    local emoj_ScrBg = GuidCacheUtil.GetUI("emoj_ScrBg")
    --隐藏上一次选中的
    if lastSelectEmojBag then
        local lastBtn = GUI.GetByGuid(lastSelectEmojBag)
        local btnSelectImage = GUI.GetChild(lastBtn, "btnSelectImage")
        GUI.SetVisible(btnSelectImage, false)
        local lastemojiBagkey = EmojiBagGuid2Id[lastSelectEmojBag]
        local lastScr = GUI.GetChild(emoj_ScrBg, tostring(lastemojiBagkey))
        GUI.SetVisible(lastScr, false)
    end
    --打开现在的
    local btn = GUI.GetByGuid(guid)
    local btnSelectImage = GUI.GetChild(btn, "btnSelectImage")
    GUI.SetVisible(btnSelectImage, true)

    local emojiBagkey = EmojiBagGuid2Id[guid]
    local scr = GUI.GetChild(emoj_ScrBg, tostring(emojiBagkey))
    local emojBga = DB.GetOnceEmoji_BagByKey1(emojiBagkey)

    if emojBga == nil then
        test("emojBga == nil")
        return
    end

    if not scr then
        scr = GUI.ScrollRectCreate(emoj_ScrBg, tostring(emojiBagkey), 0, 10, 660, 115, 1, false, Vector2.New(38, 38), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 8)
        GUI.SetAnchor(scr, UIAnchor.Top)
        GUI.SetPivot(scr, UIAroundPivot.Top)
        GUI.ScrollRectSetChildSpacing(scr, Vector2.New(40, 30))
        GUI.SetDepth(scr, 0)
    else
        GUI.SetVisible(scr, true)
    end

    local scale = Vector3.New(1.5, 1.5, 1.5)
    local bagIndex = (emojiBagkey - 1) * 100
    for i = 1 + bagIndex, emojBga.Number + bagIndex do
        local emoj = DB.GetEmoji(i)
        if emoj ~= nil then
            local emojBtn = GUI.GetChild(scr, emoj.Shortcut2)
            local text = "#FACE<X:" .. emojiBagkey .. ",Y:" .. tostring(emoj.Icon) .. ">#"
            --test("text="..text..",Shortcut2="..emoj.Shortcut2)
            if not emojBtn then
                emojBtn = GUI.RichEditCreate(scr, emoj.Shortcut2, text, 0, 0, 44, 44)
                GUI.SetPivot(emojBtn, UIAroundPivot.TopLeft)
                GUI.StaticSetAlignment(emojBtn, TextAnchor.MiddleCenter)
                GUI.RegisterUIEvent(emojBtn, UCE.PointerClick, "EmojPanelUI", "OnEmojClick_RichTxt")
                GUI.SetScale(emojBtn, scale)
            else
                GUI.StaticSetText(emojBtn, text)
            end
        end
    end


    if emojiBagkey == 1 then

        local rollGroup = GUI.GetChild(scr,"rollGroup",false)

        if rollGroup == nil then

            rollGroup = GUI.GroupCreate(scr,"rollGroup",0,0,0,0,false)

            local rollBtn = GUI.ButtonCreate(rollGroup, "#ROLL", "1800600320", 10, 0, Transition.ColorTint,"",50,50,false)
            SetSameAnchorAndPivot(rollBtn, UILayout.Center)
            GUI.RegisterUIEvent(rollBtn, UCE.PointerClick, "EmojPanelUI", "OnRollBtnClick")

            local numBg = GUI.ImageCreate(rollBtn, "numBg", "1800705060", 0, 0, false, GUI.GetWidth(rollBtn)-10, GUI.GetHeight(rollBtn)-10)
            SetSameAnchorAndPivot(numBg, UILayout.Center)

        end

    end

    lastSelectEmojBag = guid
end

function EmojPanelUI.OnEmojClick_RichTxt(guid)
    local inputField = GUI.GetByGuid(EmojPanelUI.BackToInputGuid)
    if inputField == nil then
        test("inputField == nil")
        return
    end

    local btn = GUI.GetByGuid(guid)
    local txt = GUI.GetName(btn)
    if txt then
        test("txt="..txt)
        local inputText = GUI.EditGetTextM(inputField)
        GUI.EditSetTextM(inputField, inputText .. txt)
    end
end

function EmojPanelUI.OnRollBtnClick(guid)
    local inputField = GUI.GetByGuid(EmojPanelUI.BackToInputGuid)
    if inputField == nil then
        test("inputField == nil")
        return
    end

    local btn = GUI.GetByGuid(guid)
    local txt = GUI.GetName(btn)
    if txt then
        GUI.EditSetTextM(inputField, "")
        GUI.EditSetTextM(inputField,  txt)
    end
end

---------------------------------------------- end 表情面板相关 end ----------------------------------------------------------

---------------------------------------------- start 聊天历史相关 start ----------------------------------------------------------

--emoj面板 聊天历史按钮点击
function EmojPanelUI.OnInputHistoryBtnClick_EmojPanel(guid)
    local name = "history_ScrBg"
    if name == CurSelectPanel then
        return
    end
    if CurSelectPanel then
        local lastPanel = GuidCacheUtil.GetUI(CurSelectPanel)
        GUI.SetVisible(lastPanel, false)
    end
    CurSelectPanel = name

    local currentSelectScr = GuidCacheUtil.GetUI(name)
    if currentSelectScr == nil then
        local rightScr_Bg = GuidCacheUtil.GetUI("rightScr_Bg")
        local currentSelectScr = GUI.ImageCreate(rightScr_Bg, name, "1800400200", 0, 0, false, 675, 220)
        GuidCacheUtil.BindName(currentSelectScr, name)
        SetAnchorAndPivot(currentSelectScr, UIAnchor.Center, UIAroundPivot.Center)

        local scr_inputHistory = GUI.ScrollRectCreate(currentSelectScr, "scr_inputHistory", 0, 10, 660, 210, 1, false, Vector2.New(215, 45), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 3)
        GuidCacheUtil.BindName(scr_inputHistory, "scr_inputHistory")
        SetAnchorAndPivot(scr_inputHistory, UIAnchor.Top, UIAroundPivot.Top)
        GUI.ScrollRectSetVertical(scr_inputHistory, false)
        GUI.ScrollRectSetChildSpacing(scr_inputHistory, Vector2.New(5, 7))
    else
        GUI.SetVisible(currentSelectScr, true)
    end
    EmojPanelUI.OnRefreshChatHistory()
end

function EmojPanelUI.OnRefreshChatHistory()
    local scr_inputHistory = GuidCacheUtil.GetUI("scr_inputHistory")
    if scr_inputHistory == nil then
        return
    end
    ChatHistoryBtn2Msg = {}
    local childCount = GUI.GetChildCount(scr_inputHistory)
    local chatHistory = CL.GetChatHistoryList()
    if chatHistory ~= nil then
        if childCount > chatHistory.Count then
            for i = chatHistory.Count, childCount - 1 do
                local child = GUI.GetChildByIndex(scr_inputHistory, i)
                GUI.SetVisible(child, false)
            end
        end

        if childCount < chatHistory.Count then
            for i = 0, childCount - 1 do
                local child = GUI.GetChildByIndex(scr_inputHistory, i)
                local chatTxt = GUI.GetChild(child, "chatTxt")
                local content = chatHistory[chatHistory.Count - 1 - i]
                GUI.StaticSetText(chatTxt, content) --LD.GetRealSendContent(content)
                UILayout.SetUrlColor(chatTxt)
                --local height = GUI.RichEditGetPreferredHeight(chatTxt)
                GUI.SetHeight(chatTxt, 38)
                local childCount_chatTxt = GUI.GetChildCount(chatTxt)
                ChatHistoryBtn2Msg[GUI.GetGuid(child)] = content
                for j = 0, childCount_chatTxt - 1 do
                    local richChild = GUI.GetChildByIndex(chatTxt, j)
                    GUI.SetIsRaycastTarget(richChild, false)
                end
            end

            for i = childCount, chatHistory.Count - 1 do
                local btn = GUI.ButtonCreate(scr_inputHistory, "btn", "1800902090", 0, 0, Transition.ColorTint, "", 215, 45, false)
                local chatTxt = GUI.RichEditCreate(btn, "chatTxt", "", 0, 0, 180, 38)
                GUI.SetIsRaycastTarget(chatTxt, false)
                GUI.SetAnchor(chatTxt, UIAnchor.Center)
                GUI.SetPivot(chatTxt, UIAroundPivot.Center)
                GUI.StaticSetFontSize(chatTxt, fontSize_BigOne)
                GUI.SetColor(chatTxt, colorType_DarkYellow)
                local content = chatHistory[chatHistory.Count - 1 - i]
                GUI.StaticSetText(chatTxt, content) --LD.GetRealSendContent(content)
                UILayout.SetUrlColor(chatTxt)
                --local height = GUI.RichEditGetPreferredHeight(chatTxt)
                ChatHistoryBtn2Msg[GUI.GetGuid(btn)] = content
                local childCount_chatTxt = GUI.GetChildCount(chatTxt)
                for j = 0, childCount_chatTxt - 1 do
                    local richChild = GUI.GetChildByIndex(chatTxt, j)
                    GUI.SetIsRaycastTarget(richChild, false)
                end
                GUI.RegisterUIEvent(btn, UCE.PointerClick, "EmojPanelUI", "ChatHistoryBtnClick")
            end
        else
            local scrChildIndex = 0
            for i = chatHistory.Count - 1, 0, -1 do
                local child = GUI.GetChildByIndex(scr_inputHistory, scrChildIndex)
                local chatTxt = GUI.GetChild(child, "chatTxt")
                local content = chatHistory[i]
                GUI.StaticSetText(chatTxt, content) --LD.GetRealSendContent(content)
                UILayout.SetUrlColor(chatTxt)
                --local height = GUI.RichEditGetPreferredHeight(chatTxt)
                GUI.SetHeight(chatTxt, 38)
                ChatHistoryBtn2Msg[GUI.GetGuid(child)] = content
                local childCount = GUI.GetChildCount(chatTxt)
                for i = 0, childCount - 1 do
                    local richChild = GUI.GetChildByIndex(chatTxt, i)
                    GUI.SetIsRaycastTarget(richChild, false)
                end
                scrChildIndex = scrChildIndex + 1
            end
        end
    else
        for i = 0, childCount - 1 do
            local child = GUI.GetChildByIndex(scr_inputHistory, i)
            GUI.SetVisible(child, false)
        end
    end
end

function EmojPanelUI.ChatHistoryBtnClick(guid)
    local inputField = GUI.GetByGuid(EmojPanelUI.BackToInputGuid)
    local inputText = GUI.EditGetTextM(inputField)
    local txt = ChatHistoryBtn2Msg[guid]
    local itemArr = {}
    local value = nil
    itemArr, value = EmojPanelUI.GetItemInfo_RichText(txt, itemArr, 0)

    for i = 1, #itemArr do
        local itemInfo = itemArr[i]
        test(itemInfo.Name)
        LD.AddSendItemInfo("【" .. itemInfo.Name .. "】", itemInfo.Name, itemInfo.OwnerGuid, itemInfo.Guid, itemInfo.Type)
    end

    GUI.EditSetTextM(inputField, inputText .. value)
end

function EmojPanelUI.GetItemInfo_RichText(value, itemArr, index)
    local tmp1, tmp2, tmpValue, tmpValue2, tmpValue3, tmpValue4 = string.find(value, "#ITEMLINK<STR:【(.-)】,OWERGUID:(%d+),ITEMGUID:(%d+),ITEMGRADE:(%d+)>#")
    if tmp1 ~= nil then
        index = index + 1
        itemArr[index] = {}
        itemArr[index].Name = tmpValue
        itemArr[index].OwnerGuid = tmpValue2
        itemArr[index].Guid = tmpValue3
        itemArr[index].Type = tmpValue4
        local cutValue1 = string.sub(value, 1, tmp1 - 1)

        local itemStr = "#ITEMLINK<STR:【" .. tmpValue .. "】,OWERGUID:" .. tmpValue2 .. ",ITEMGUID:" .. tmpValue3 .. ",ITEMGRADE:" .. tmpValue4 .. ">#"
        local cutValue2 = string.sub(value, tmp1 + string.len(itemStr), string.len(value))
        value = cutValue1 .. "【" .. tmpValue .. "】" .. cutValue2
        --realLength = string.len(value) + string.len("【" .. tmpValue .. "】")
        if string.find(value, "#ITEMLINK<STR:【(.-)】,OWERGUID:(%d+),ITEMGUID:(%d+),ITEMGRADE:(%d+)>#") ~= nil then
            itemArr, value = EmojPanelUI.GetItemInfo_RichText(value, itemArr, index)
        else

        end
    end

    return itemArr, value
end

---------------------------------------------- end 聊天历史相关 end ----------------------------------------------------------

---------------------------------------------- start 宠物面板相关 start ----------------------------------------------------------

--emoj面板 宠物按钮点击
function EmojPanelUI.OnPetBtnClick_EmojPanel(guid, key)
    local name = "pet_ScrBg"
    if name == CurSelectPanel then
        return
    end
    if CurSelectPanel then
        local lastPanel = GuidCacheUtil.GetUI(CurSelectPanel)
        GUI.SetVisible(lastPanel, false)
    end
    CurSelectPanel = name
    local currentSelectScr = GuidCacheUtil.GetUI(name)
    if currentSelectScr == nil then
        local rightScr_Bg = GuidCacheUtil.GetUI("rightScr_Bg")
        local currentSelectScr = GUI.ImageCreate(rightScr_Bg, name, "1800400200", 0, 0, false, 675, 220)
        GuidCacheUtil.BindName(currentSelectScr, name)
        SetAnchorAndPivot(currentSelectScr, UIAnchor.Center, UIAroundPivot.Center)

        --local scr_Pet = GUI.ScrollRectCreate(currentSelectScr, "scr_Pet", 0, 5, 660, 210, 1, false, Vector2.New(330, 100), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 2)
        --SetAnchorAndPivot(scr_Pet, UIAnchor.Top, UIAroundPivot.Top)
        --GUI.ScrollRectSetVertical(scr_Pet, false)
        local scr_Pet = GUI.LoopScrollRectCreate(currentSelectScr, "scr_Pet", 0, 5, 660, 210,
                "EmojPanelUI", "CreatePetItemPool", "EmojPanelUI", "RefreshPetScroll", 0, false,
                Vector2.New(325, 100), 2, UIAroundPivot.Top, UIAnchor.Top)
        GuidCacheUtil.BindName(scr_Pet, "scr_Pet")
        SetAnchorAndPivot(scr_Pet, UIAnchor.Top, UIAroundPivot.Top)
    else
        GUI.SetVisible(currentSelectScr, true)
    end
    EmojPanelUI.petGuidList = LD.GetPetGuids()
    local scroll = GuidCacheUtil.GetUI("scr_Pet")
    if scroll then
        GUI.LoopScrollRectSetTotalCount(scroll, EmojPanelUI.petGuidList.Count)
        GUI.LoopScrollRectRefreshCells(scroll)
    end
end

function EmojPanelUI.CreatePetItemPool()
    local petScroll = GuidCacheUtil.GetUI("scr_Pet") --GUI.GetByGuid(_gt.petScroll)
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(petScroll)
    local petItem = PetItem.Create(petScroll, "petItem" .. curCount, 0, 0)
    GUI.RegisterUIEvent(petItem, UCE.PointerClick, "EmojPanelUI", "OnPetItemClick")
    return petItem
end

function EmojPanelUI.RefreshPetScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local petItem = GUI.GetByGuid(guid)

    local petGuid = EmojPanelUI.GetPetGuid(index)
    PetItem.BindPetGuid(petItem, petGuid, pet_container_type.pet_container_panel)
end

function EmojPanelUI.OnPetItemClick(guid)
    local petItem = GUI.GetByGuid(guid)
    local idx = GUI.CheckBoxExGetIndex(petItem)
    local petGuid = EmojPanelUI.GetPetGuid(idx)
    local bagType = pet_container_type.pet_container_panel
    local petData = LD.GetPetData(petGuid, bagType)
    local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid, bagType)))
    local petDB = DB.GetOncePetByKey1(petId)
    if petDB.Id == 0 then
        PetItem.SetEmpty(petItem)
        return 
    end
    local inputField = GUI.GetByGuid(EmojPanelUI.BackToInputGuid)
    local inputText = GUI.EditGetTextM(inputField)
    local itemNameOne = "【" .. petDB.Name .. "】"
    GUI.EditSetTextM(inputField, inputText .. itemNameOne)
    local itemName = tostring(petDB.Name)
    local itemOwnerGuid = tostring(LD.GetSelfGUID())
    local itemGuid = tostring(petData.guid)
    local itemType = tostring(petDB.Grade)
    test(itemNameOne .. ":" .. itemName .. ":" .. itemGuid .. ":" .. itemType)
    LD.AddSendItemInfo(itemNameOne, itemName, itemOwnerGuid, itemGuid, itemType)
    GUI.CheckBoxExSetCheck(petItem, false)
end

function EmojPanelUI.GetPetGuid(listIndex)
    local petGuid = 0
    if EmojPanelUI.petGuidList ~= nil and listIndex < EmojPanelUI.petGuidList.Count then
        petGuid = EmojPanelUI.petGuidList[listIndex]
    end

    return petGuid
end

---------------------------------------------- end 宠物面板相关 end ----------------------------------------------------------

---------------------------------------------- start 物品面板相关 start ----------------------------------------------------------

--emoj面板 道具按钮点击
function EmojPanelUI.OnItemBtnClick_EmojPanel(guid, key)
    local name = "item_ScrBg"
    if name == CurSelectPanel then
        return
    end
    if CurSelectPanel then
        local lastPanel = GuidCacheUtil.GetUI(CurSelectPanel)
        GUI.SetVisible(lastPanel, false)
    end
    CurSelectPanel = name
    local currentSelectScr = GuidCacheUtil.GetUI(name)
    if currentSelectScr == nil then
        local rightScr_Bg = GuidCacheUtil.GetUI("rightScr_Bg")
        local currentSelectScr = GUI.ImageCreate(rightScr_Bg, name, "1800400200", 0, 0, false, 675, 220)
        GuidCacheUtil.BindName(currentSelectScr, name)
        SetAnchorAndPivot(currentSelectScr, UIAnchor.Center, UIAroundPivot.Center)

        local scr_Item = GUI.LoopScrollRectCreate(currentSelectScr, "scr_Item", 0, 5, 661, 210, "EmojPanelUI", "CreatIcon4Pool", "EmojPanelUI", "OnRefreshItemIcon", 1, false, Vector2.New(80, 80), 8, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
        GuidCacheUtil.BindName(scr_Item, "scr_Item")
        SetAnchorAndPivot(scr_Item, UIAnchor.Top, UIAroundPivot.Top)
        GUI.ScrollRectSetChildSpacing(scr_Item, Vector2.New(3, 3))
        GUI.ScrollRectSetVertical(scr_Item, true)
    else
        GUI.SetVisible(currentSelectScr, true)
    end
    local scroll = GuidCacheUtil.GetUI("scr_Item")
    if scroll then
        GUI.LoopScrollRectSetTotalCount(scroll, LD.GetItemCount(item_container_type.item_container_bag))
        GUI.LoopScrollRectRefreshCells(scroll)
    end
end

function EmojPanelUI.CreatIcon4Pool()
    local scroll = GuidCacheUtil.GetUI("scr_Item")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    --local icon = GUI.ItemCtrlCreate(scroll, "itemIcon" .. curCount, "1800400050", 0, 0)
    local icon = ItemIcon.Create(scroll, "itemIcon" .. curCount, 0, 0)

    return icon
end

function EmojPanelUI.OnRefreshItemIcon(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local icon = GUI.GetByGuid(guid)
    local scroll = GuidCacheUtil.GetUI("scr_Item")
    if icon ~= nil then
        EmojPanelUI.CreateIcon("scroll" .. index, index, scroll, icon)
    end
end

function EmojPanelUI.CreateIcon(key, index, scroll, fightlogo)
    if fightlogo == nil then
        fightlogo = ItemIcon.Create(scroll, "itemIcon" .. index, 0, 0)
        --fightlogo = GUI.ItemCtrlCreate(scroll, key, "1800400050", 0, 0)
    end
    GUI.UnRegisterUIEvent(fightlogo, UCE.PointerClick, "EmojPanelUI", "OnItemBtnClick")
    GUI.RegisterUIEvent(fightlogo, UCE.PointerClick, "EmojPanelUI", "OnItemBtnClick")
    local itemData = LD.GetItemDataByItemIndex(index, item_container_type.item_container_bag)
    if itemData ~= nil then
        ItemIcon.BindItemData(fightlogo, itemData)
    else
        ItemIcon.SetEmpty(fightlogo)
    end
    --ItemIcon.BindIndexForBag(fightlogo, index, item_container_type.item_container_bag)
    return fightlogo
end

function EmojPanelUI.OnItemBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local inputField = GUI.GetByGuid(EmojPanelUI.BackToInputGuid)
    local inputText = GUI.EditGetTextM(inputField)
    --local itemNameOne = GUI.GetData(btn, "itemNameOne")
    local idx = GUI.ItemCtrlGetIndex(btn)
    local itemData = LD.GetItemDataByItemIndex(idx, item_container_type.item_container_bag) -- LD.GetItemDataByIndex(idx, item_container_type.item_container_bag)
    local itemDB = DB.GetOnceItemByKey1(itemData.id)
    local itemNameOne = "【" .. itemDB.Name .. "】"
    GUI.EditSetTextM(inputField, inputText .. itemNameOne)
    local itemName = tostring(itemDB.Name)
    local itemOwnerGuid = tostring(LD.GetSelfGUID())
    local itemGuid = tostring(itemData.guid)
    local itemType = tostring(itemDB.Grade)
    test(itemNameOne .. ":" .. itemName .. ":" .. itemGuid .. ":" .. itemType)
    LD.AddSendItemInfo(itemNameOne, itemName, itemOwnerGuid, itemGuid, itemDB.Grade)
end

---------------------------------------------- end 物品面板相关 end ----------------------------------------------------------

function EmojPanelUI.OnClose()
    --CurSelectPanel = nil
    --lastSelectEmojBag = nil
end

function EmojPanelUI.OnCloseBtnClick_EmojPanel(guid)
    GUI.CloseWnd("EmojPanelUI")
end