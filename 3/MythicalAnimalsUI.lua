-- local test = print
local test = function()
end
local MythicalAnimalsUI = {
    ---@type AnimalsServerData
    ServerData = {},
    ---@type table<string,table<number,AnimalDetail>>
    Details = {}
}
_G.MythicalAnimalsUI = MythicalAnimalsUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local guidt = UILayout.NewGUIDUtilTable()
-- 拥有个数前缀
local CustomKey = "GodAnimalItem_"
local CustomKey_AllScore = "GodAnimalOverallScore"
local starImage = "1801202190"
local GrayStarImage = "1801202192"
local CustomAutoKey = "GodAnimalAutoLevelUp"

local findKey = {"全部", "SSR", "SR", "R", "N", "6星", "5星", "4星", "3星", "2星", "1星", "0星"}
local findF = {
    function(AnimalItemData)
        return true
    end,
    function(AnimalItemData)
        return AnimalItemData.Grade == 5
    end,
    function(AnimalItemData)
        return AnimalItemData.Grade == 4
    end,
    function(AnimalItemData)
        return AnimalItemData.Grade == 3
    end,
    function(AnimalItemData)
        return AnimalItemData.Grade == 2
    end,
    function(AnimalItemData)
        return AnimalItemData.Level == 6
    end,
    function(AnimalItemData)
        return AnimalItemData.Level == 5
    end,
    function(AnimalItemData)
        return AnimalItemData.Level == 4
    end,
    function(AnimalItemData)
        return AnimalItemData.Level == 3
    end,
    function(AnimalItemData)
        return AnimalItemData.Level == 2
    end,
    function(AnimalItemData)
        return AnimalItemData.Level == 1
    end,
    function(AnimalItemData)
        return AnimalItemData.Level == 0
    end
}
function MythicalAnimalsUI.InitData()
    return {
        allScore = 0,
        ---@type AnimalItemData[]
        Animal = {},
        ---@type table<string,number>
        KeyNameList = {},
        ---@type enhanceDynAttrData[]
        attrs = {},
        auto = false,
        curNum = 0,
        ---@type AnimalItemData[]
        data = {},
        ---@type table<string,number>
        dataKeyNameList = {},
        findType = 1
    }
end
local data = MythicalAnimalsUI.InitData()
function MythicalAnimalsUI.RequestDetailsData(name)
    if MythicalAnimalsUI.GetDetailsData(name) then
        GUI.OpenWnd("MythicalAnimalsLvUpUI", name)
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormGodAnimal", "GetDetails", name)
    end
end
function MythicalAnimalsUI.GetDetailsData(keyname)
    if keyname == nil or MythicalAnimalsUI.Details == nil then
        return nil
    end
    local info = MythicalAnimalsUI.GetInfo(MythicalAnimalsUI.GetIndex(keyname))
    if MythicalAnimalsUI.Details[keyname] == nil then
        MythicalAnimalsUI.Details[keyname] = {}
    end
    return MythicalAnimalsUI.Details[keyname][info.Level]
end
function MythicalAnimalsUI.OnExitGame()
    -- data = MythicalAnimalsUI.InitData()
end
function MythicalAnimalsUI.OnExit()
    guidt = nil
    GUI.DestroyWnd("MythicalAnimalsUI")
    GUI.DestroyWnd("MythicalAnimalsLvUpUI")
end
function MythicalAnimalsUI.Main(parameter)
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("MythicalAnimalsUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("MythicalAnimalsUI", "MythicalAnimalsUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "异兽录", "MythicalAnimalsUI", "OnExit")
    local srcbg = GUI.ImageCreate(panelBg, "srcbg", "1800400010", 0, 0, false, 1020, 500)
    local src =
        GUI.LoopScrollRectCreate(
        srcbg,
        "src",
        0,
        0,
        1000,
        450,
        "MythicalAnimalsUI",
        "CreateItem",
        "MythicalAnimalsUI",
        "RefreshItem",
        0,
        false,
        Vector2.New(178, 272),
        5,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    GUI.ScrollRectSetChildSpacing(src, UIDefine.Vector2One * 15)
    guidt.BindName(src, "src")
    local hintBtn = GUI.ButtonCreate(panelBg, "hintBtn", "1800702030", 100, -40, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(hintBtn, UILayout.BottomLeft)
    GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "MythicalAnimalsUI", "OnHintBtnClick")
    local rank = GUI.CreateStatic(hintBtn, "rank", "评分:" .. data.allScore, 100, 0, 150, 50)
    GUI.StaticSetFontSize(rank, UIDefine.FontSizeL)
    GUI.SetColor(rank, UIDefine.BrownColor)
    GUI.StaticSetAlignment(rank, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(rank, UILayout.Center)
    guidt.BindName(rank, "rank")

    local check =
        GUI.CheckBoxCreate(panelBg, "check", "1800607150", "1800607151", 350, 275, Transition.None, false, 38, 38)
    guidt.BindName(check, "check")
    local tips = GUI.CreateStatic(check, "tips", "自动升阶", 100, 0, 150, 50)
    GUI.StaticSetFontSize(tips, UIDefine.FontSizeL)
    GUI.SetColor(tips, UIDefine.BrownColor)
    GUI.StaticSetAlignment(tips, TextAnchor.MiddleLeft)
    GUI.RegisterUIEvent(check, UCE.PointerClick, "MythicalAnimalsUI", "OnCheckClick")

    local find = GUI.CheckBoxExCreate(panelBg, "find", "1800700070", "1800700070", 95, 50, false, 180, 36)
    UILayout.SetSameAnchorAndPivot(find, UILayout.TopLeft)
    local arrow = GUI.ImageCreate(find, "arrow", "1800607140", 60, 0, false, 20, 12)
    local txt = GUI.CreateStatic(find, "txt", " ", -5, 0, 150, 35)
    guidt.BindName(txt, "findtxt")
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.SetSameAnchorAndPivot(arrow, UILayout.Center)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.RegisterUIEvent(find, UCE.PointerClick, "MythicalAnimalsUI", "OnlevelSelectBtnClick")

    local levelSelectCover =
        GUI.ImageCreate(
        panelBg,
        "levelSelectCover",
        "1800400220",
        0,
        -66,
        false,
        GUI.GetWidth(panel),
        GUI.GetHeight(panel)
    )
    UILayout.SetSameAnchorAndPivot(levelSelectCover, UILayout.Top)
    levelSelectCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(levelSelectCover, true)
    GUI.RegisterUIEvent(levelSelectCover, UCE.PointerClick, "MythicalAnimalsUI", "OnlevelSelectCoverClick")
    guidt.BindName(levelSelectCover, "levelSelectCover")
    local border = GUI.ImageCreate(levelSelectCover, "border", "1800400290", -413, 150, false, 188, 40 * 8 + 10)
    UILayout.SetSameAnchorAndPivot(border, UILayout.Top)

    local levelScr =
        GUI.LoopScrollRectCreate(
        levelSelectCover,
        "levelScr",
        -413,
        150,
        188,
        40 * 8,
        "MythicalAnimalsUI",
        "CreatLevelItemPool",
        "MythicalAnimalsUI",
        "RefreshLevelScr",
        0,
        false,
        Vector2.New(175, 40),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    guidt.BindName(levelScr, "levelScr")
    GUI.SetAnchor(levelScr, UIAnchor.Top)
    GUI.SetPivot(levelScr, UIAroundPivot.Top)

    GUI.SetVisible(levelSelectCover, false)

    MythicalAnimalsUI.ClientRefresh()
    MythicalAnimalsUI.GetDate()
end
function MythicalAnimalsUI.OnCheckClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGodAnimal", "SetAutoLevelUp", data.auto and 0 or 1)
end
function MythicalAnimalsUI.OnHintBtnClick()
    GUI.OpenWnd("ShowAttributeUI")
    ShowAttributeUI.RefreshAttributeUI(data.attrs, "加成人物属性")
end
function MythicalAnimalsUI.CreateItem()
    local scroll = guidt.GetUI("src")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = GUI.CheckBoxExCreate(scroll, tostring(curCount), "1800601020", "1800601020", 0, 0)
    local icon = ItemIcon.Create(item, "icon", 0, 30)

    GUI.ItemCtrlSetElementRect(icon, eItemIconElement.Icon, 0, -1, 122, 122)
    GUI.ItemCtrlSetElementRect(icon, eItemIconElement.Border, 0, -1, 142, 142)

    local cnt = GUI.CreateStatic(item, "cnt", " ", 0, -10, 160, 30)
    local name = GUI.CreateStatic(item, "name", " ", 0, 10, 160, 50)
    UILayout.SetSameAnchorAndPivot(cnt, UILayout.Bottom)
    UILayout.SetSameAnchorAndPivot(name, UILayout.Top)
    local txt = {cnt, name}
    local color = {UIDefine.Yellow2Color, UIDefine.OutLine_YellowColor}
    for i = 1, 2 do
        GUI.StaticSetFontSize(txt[i], UIDefine.FontSizeL)
        GUI.SetColor(txt[i], color[i])
        GUI.StaticSetAlignment(txt[i], TextAnchor.MiddleCenter)
    end
    -- GUI.SetIsOutLine(name, true)
    -- GUI.SetOutLine_Color(name, UIDefine.WhiteColor)
    -- GUI.SetOutLine_Distance(name, UIDefine.OutLineDistance)

    GUI.SetIsRaycastTarget(icon, false)

    local star = GUI.GroupCreate(item, "star", 0, -40, 22 * 6, 20) --GUI.ImageCreate(icon, "star", "1801200080", 0, 0)
    UILayout.SetSameAnchorAndPivot(star, UILayout.Bottom)
    for i = 1, 6 do
        local tmp = GUI.ImageCreate(star, i, GrayStarImage, 22 * (i - 1), 0, false, 24, 22)
        UILayout.SetSameAnchorAndPivot(tmp, UILayout.Left)
    end
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MythicalAnimalsUI", "OnItemClick")
    return item
end
function MythicalAnimalsUI.RefreshItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local icon = GUI.GetChild(item, "icon", false)
    local cnt = GUI.GetChild(item, "cnt", false)
    local name = GUI.GetChild(item, "name", false)
    local star = GUI.GetChild(item, "star", false)
    -- GUI.SetPositionY(icon,-10)
    GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Border, UIDefine.ItemIconBg[(data.data[index].Grade)])
    GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, tostring(data.data[index].Icon))
    if data.data[index].Level == data.data[index].MaxLevel then
        GUI.StaticSetText(cnt, "已满星")
    else
        GUI.StaticSetText(cnt, data.data[index].HasItemNum .. "/" .. data.data[index].NeedItemNum)
    end
    GUI.StaticSetText(name, data.data[index].Name)
    for i = 1, 6 do
        local tmp = GUI.GetChild(star, i, false)
        if i <= data.data[index].MaxLevel then
            GUI.SetVisible(tmp, true)
        else
            GUI.SetVisible(tmp, false)
        end
        if i <= data.data[index].Level then
            GUI.ImageSetImageID(tmp, starImage)
        else
            GUI.ImageSetImageID(tmp, GrayStarImage)
        end
    end
    if data.data[index].Level == 0 then
        GUI.ItemCtrlSetIconGray(icon, true)
    else
        GUI.ItemCtrlSetIconGray(icon, false)
    end
end
function MythicalAnimalsUI.OnItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local index = GUI.CheckBoxExGetIndex(item) + 1
    local info = data.data[index]
    MythicalAnimalsUI.RequestDetailsData(info.Name)
end
function MythicalAnimalsUI.OnShow(parameter)
    local wnd = GUI.GetWnd("MythicalAnimalsUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
    CL.RegisterMessage(GM.CustomDataUpdate, "MythicalAnimalsUI", "OnCustomDataUpdate")
end
function MythicalAnimalsUI.OnDestroy()
    MythicalAnimalsUI.OnClose()
end
function MythicalAnimalsUI.OnClose()
    local wnd = GUI.GetWnd("MythicalAnimalsUI")
    GUI.SetVisible(wnd, false)
    CL.UnRegisterMessage(GM.CustomDataUpdate, "MythicalAnimalsUI", "OnCustomDataUpdate")
end
function MythicalAnimalsUI.GetDate()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGodAnimal", "GetData")
end
function MythicalAnimalsUI.Refresh()
    MythicalAnimalsUI.ClientRefresh()
end
function MythicalAnimalsUI.SortData()
    if data == nil or data.Animal == nil then
        return
    end
    data.data = {}
    data.curNum = 0
    for i = 1, #data.Animal do
        if findF[data.findType](data.Animal[i]) then
            local index = #data.data + 1
            data.data[index] = data.Animal[i]

            if data.Animal[i].Level > 0 then
                data.curNum = data.curNum + 1
            end
        end
    end
    table.sort(
        data.data,
        function(a, b)
            ---@type AnimalItemData
            local item1 = a
            ---@type AnimalItemData
            local item2 = b
            local canUp1 = (item1.HasItemNum >= item1.NeedItemNum and item1.Level ~= item1.MaxLevel)
            local canUp2 = (item2.HasItemNum >= item2.NeedItemNum and item2.Level ~= item2.MaxLevel)
            local canactive1 = (item1.Level == 0 and canUp1)
            local canactive2 = (item2.Level == 0 and canUp2)
            local curactive1 = (item1.Level > 0)
            local curactive2 = (item2.Level > 0)
            if canactive1 and not canactive2 then
                return true
            elseif canactive2 and not canactive1 then
                return false
            end
            if canUp1 and not canUp2 then
                return true
            elseif canUp2 and not canUp1 then
                return false
            end
            if curactive1 and not curactive2 then
                return true
            elseif curactive2 and not curactive1 then
                return false
            end
            if item1.Grade > item2.Grade then
                return true
            elseif item2.Grade > item1.Grade then
                return false
            end
            if item1.Level > item2.Level then
                return true
            elseif item2.Level > item1.Level then
                return false
            end
            return item1.Index > item2.Index
        end
    )
    for i = 1, #data.data do
        data.dataKeyNameList[data.data[i].Name] = i
    end
end
function MythicalAnimalsUI.ClientRefresh()
    data = MythicalAnimalsUI.InitData()
    if MythicalAnimalsUI.ServerData and MythicalAnimalsUI.ServerData.Animal then
        for key, value in pairs(MythicalAnimalsUI.ServerData.Animal) do
            -- for i = 1, 100 do
            local tmp = MythicalAnimalsUI.CloneAnimal(value)
            test(value.NeedItemKeyName)
            local db = DB.GetOnceItemByKey2(value.NeedItemKeyName)
            tmp.NeedItemId = db.Id
            test(tmp.NeedItemId)
            tmp.Name = key
            test(CustomKey .. tostring(tmp.NeedItemId))
            tmp.HasItemNum = CL.GetIntCustomData(CustomKey .. tostring(tmp.NeedItemId))
            test(tmp.HasItemNum)
            data.KeyNameList[key] = #data.Animal + 1
            data.Animal[data.KeyNameList[key]] = tmp

            -- end
        end
    end
    if MythicalAnimalsUI.ServerData and MythicalAnimalsUI.ServerData.Attr then
        data.attrs = {}
        for i = 1, #MythicalAnimalsUI.ServerData.Attr do
            local tmp = LogicDefine.ServerIdAttr2Client(MythicalAnimalsUI.ServerData.Attr[i])
            local showattr = {Name = tmp.keyname, ChinaName = tmp.name, Value = tmp.value}
            setmetatable(tmp, {__index = showattr})
            data.attrs[i] = tmp
            test(tmp.Name)
        end
    end
    data.allScore = CL.GetIntCustomData(CustomKey_AllScore)
    data.auto = CL.GetIntCustomData(CustomAutoKey) == 1
    MythicalAnimalsUI.SortData()
    MythicalAnimalsUI.RefreshUI()
    if MythicalAnimalsLvUpUI then
        MythicalAnimalsLvUpUI.GetDate()
    end
end
function MythicalAnimalsUI.RefreshUI()
    local wnd = GUI.GetWnd("MythicalAnimalsUI")
    if wnd == nil or GUI.GetVisible(wnd) == false then
        return
    end
    local src = guidt.GetUI("src")
    GUI.LoopScrollRectSetTotalCount(src, #data.data)
    GUI.LoopScrollRectRefreshCells(src)
    GUI.StaticSetText(guidt.GetUI("rank"), "评分:" .. data.allScore)
    GUI.CheckBoxSetCheck(guidt.GetUI("check"), data.auto)
    GUI.StaticSetText(guidt.GetUI("findtxt"), findKey[data.findType] .. ":" .. data.curNum .. "/" .. #data.data)
end
function MythicalAnimalsUI.OnCustomDataUpdate(type, key, value)
    for i = 1, #data.Animal do
        if key == CustomKey .. tostring(data.Animal[i].NeedItemId) then
            data.Animal[i].HasItemNum = int64.longtonum2(value)
        end
    end
    if key == CustomKey_AllScore then
        data.allScore = int64.longtonum2(value)
    end
    if key == CustomAutoKey then
        data.auto = int64.longtonum2(value) == 1
    end
    MythicalAnimalsUI.RefreshUI()
    if MythicalAnimalsLvUpUI then
        MythicalAnimalsLvUpUI.GetDate()
    end
end
function MythicalAnimalsUI.GetDataCnt()
    return #data.data
end
function MythicalAnimalsUI.GetDataIndex(keyname)
    return data.dataKeyNameList[keyname]
end
function MythicalAnimalsUI.GetDataName(index)
    if data.data[index] then
        return data.data[index].Name
    else
        return nil
    end
end
function MythicalAnimalsUI.GetIndex(keyname)
    return data.KeyNameList[keyname]
end
function MythicalAnimalsUI.GetInfo(index)
    return data.Animal[index]
end
---@param Animal AnimalItemData
function MythicalAnimalsUI.CloneAnimal(Animal)
    ---@type AnimalItemData
    local item = {}
    if Animal then
        item.Index = Animal.Index or 0
        item.Level = Animal.Level or 0
        item.NeedItemNum = Animal.NeedItemNum or 0
        item.HasItemNum = Animal.HasItemNum or 0
        item.Icon = Animal.Icon or 1900000000
        item.Grade = Animal.Grade or 0
        item.NeedItemId = Animal.NeedItemId or 0
        item.NeedItemKeyName = Animal.NeedItemKeyName or ""
        item.Name = Animal.Name or ""
        item.MaxLevel = Animal.MaxLevel or 0
    else
        item.Index = 0
        item.Level = 0
        item.NeedItemNum = 0
        item.HasItemNum = 0
        item.Icon = 1900000000
        item.Grade = 0
        item.NeedItemId = 0
        item.NeedItemKeyName = ""
        item.Name = ""
        item.MaxLevel = 0
    end
    return item
end

function MythicalAnimalsUI.OnlevelSelectBtnClick()
    local levelScr = guidt.GetUI("levelScr")
    local levelSelectCover = guidt.GetUI("levelSelectCover")
    if levelSelectCover ~= nil then
        GUI.SetVisible(levelSelectCover, true)
    end
    local cnt = #findKey
    if levelScr ~= nil then
        GUI.SetHeight(levelScr, 40 * cnt)
        GUI.SetHeight(GUI.GetChild(levelSelectCover, "border"), 40 * cnt + 10)
        GUI.LoopScrollRectSetTotalCount(levelScr, 0)
        GUI.LoopScrollRectSetTotalCount(levelScr, cnt)
    end
end
function MythicalAnimalsUI.OnlevelSelectCoverClick()
    local levelSelectCover = guidt.GetUI("levelSelectCover")
    if levelSelectCover ~= nil then
        GUI.SetVisible(levelSelectCover, false)
    end
end
function MythicalAnimalsUI.CreatLevelItemPool()
    local scroll = guidt.GetUI("levelScr")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local level =
        GUI.ButtonCreate(scroll, tostring(curCount), "1801102010", 0, 0, Transition.ColorTint, "级", 175, 40, false)
    GUI.ButtonSetTextColor(level, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(level, UIDefine.FontSizeM)
    GUI.SetAnchor(level, UIAnchor.Top)
    GUI.RegisterUIEvent(level, UCE.PointerClick, "MythicalAnimalsUI", "OnLevelItemClick")

    local selected = GUI.ImageCreate(level, "selected", "1800600160", 0, 0, false, 180, 42)
    return level
end
function MythicalAnimalsUI.OnLevelItemClick(guid)
    local item = GUI.GetByGuid(guid)
    data.findType = GUI.ButtonGetIndex(item) + 1
    MythicalAnimalsUI.OnlevelSelectCoverClick()
    MythicalAnimalsUI.SortData()
    MythicalAnimalsUI.RefreshUI()
end
function MythicalAnimalsUI.RefreshLevelScr(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local lv = GUI.GetByGuid(guid)
    if lv == nil then
        return
    end
    GUI.ButtonSetText(lv, findKey[index + 1])

    local selected = GUI.GetChild(lv, "selected", false)
    if selected ~= nil then
        if data.findType == index + 1 then
            test(data.findType)
            GUI.SetVisible(selected, true)
        else
            GUI.SetVisible(selected, false)
        end
    end
end
