local TitleUI = {
    -- 刷新定时器
    limitTime = {}
}
local test = print
_G.TitleUI = TitleUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local inspect = require("inspect")
------------------------------------ end缓存一下全局变量end --------------------------------
local TitleAll = -1
local TitleIndex = {
    TitleAll,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    0
}
local TitleType = {
    [-1] = "全部",
    [1] = "活动",
    [2] = "门派",
    [3] = "帮派",
    [4] = "婚姻",
    [5] = "结义",
    [6] = "师徒",
    [7] = "强化",
    [8] = "镶嵌",
    [9] = "官职",
    [10] = "变身",
    [0] = "其他"
}
-- 子类型
local TitleSubtype = {
    [-1] = {},
    [0] = {},
    [1] = {
        [1] = "帮派竞技",
        [2] = "天下会武",
        [3] = "魔神降临",
        [4] = "无字真经",
        [5] = "善恶",
        [6] = "科举",
		[7] = "鸡王争霸赛"
    },
    [2] = {
        [1] = "花果山",
        [2] = "西海龙宫",
        [3] = "慈恩寺",
        [4] = "流沙界",
        [5] = "净坛禅院",
        [6] = "酆都"
    },
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
    [9] = {
        [1] = "品阶",
        [2] = "排行榜"
    },
    [10] = {
        [1] = "神兽",
        [2] = "宠物",
        [3] = "侍从"
    }
}
local ImageSice={256,100}
local guidt = UILayout.NewGUIDUtilTable()
function TitleUI.InitData()
    return {
        --当前id
        curId = 0,
        --类型
        typeIndex = -1,
        --类型判断标志   使用-2在于 -1~10的数字都有了对应的   作用：与typeIndex进行比较，实现把有子类型且打开的类型进行关闭
        typeIndexFlag=-2,
        --子类型
        subTypeIndex = 1,
        Index = 1,
        ---@type table<number,titleInfo>
        title = {},
        ---@type table<number, DynAttrData>
        attr = {},
        ---@type number[]
        attrId = {},
        ---@type table<number,table<number,table[]>>
        type = {},
        ---@type table<number,table<number,table[]>>
        hastype = {},
        isHas = false
    }
end
local data = TitleUI.InitData()
function TitleUI.OnExitGame()
    data = TitleUI.InitData()
end
function TitleUI.OnExit()
    -- test("TitleUI.OnExit()")
    guidt = nil
    GUI.DestroyWnd("TitleUI")
end
function TitleUI.Main(parameter)
    TitleUI.GetDate()
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("TitleUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("TitleUI", "TitleUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "称号", 1060, 612, "TitleUI", "OnExit")
    guidt.BindName(panelBg, "panelBg")
    local titleListBg = GUI.ImageCreate(panelBg, "titleListBg", "1800400200", 135, 0, false, 745, 498)
    local titleScr =
        GUI.LoopScrollRectCreate(
        titleListBg,
        "titleScr",
        0,
        0,
        726,
        478,
        "TitleUI",
        "CreateTitle",
        "TitleUI",
        "RefreshTitleScroll",
        0,
        false,
        Vector2.New(726, 105),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    guidt.BindName(titleScr, "titleScr")
    GUI.ScrollRectSetChildSpacing(titleScr, Vector2.New(0, 6))
    local tipText = GUI.CreateStatic(panelBg, "tipText", "已获得的称号，无论是否佩戴，激活属性永久有效", 294, -19, 441, 25)
    UILayout.SetSameAnchorAndPivot(tipText, UILayout.BottomLeft)
    GUI.StaticSetFontSize(tipText, UIDefine.FontSizeS)
    GUI.SetColor(tipText, UIDefine.Yellow2Color)

    local check = GUI.CheckBoxExCreate(panelBg, "check", "1800208210", "1800208211", -150, -20, data.isHas)
    guidt.BindName(check, "check")
    UILayout.SetSameAnchorAndPivot(check, UILayout.BottomRight)
    GUI.RegisterUIEvent(check, UCE.PointerClick, "TitleUI", "OnClickCheck")
    local showget = GUI.CreateStatic(check, "showGet", "显示已获得", -120, 0, 101, 25)
    GUI.StaticSetFontSize(showget, UIDefine.FontSizeS)
    UILayout.SetSameAnchorAndPivot(showget, UILayout.BottomRight)
    GUI.SetColor(showget, UIDefine.BrownColor)
    GUI.SetIsRaycastTarget(showget, true)

    local attrBg = GUI.ImageCreate(panelBg, "attrBg", "1800400200", -378, 197, false, 263, 188)
    local attrTitleBg = GUI.ImageCreate(attrBg, "attrTitleBg", "1800001140", 0, 16, false, 217, 35)
    UILayout.SetSameAnchorAndPivot(attrTitleBg, UILayout.Top)
    local attrTitleText = GUI.CreateStatic(attrTitleBg, "attrTitleText", "已激活总属性", 0, 0, 133, 30)
    GUI.StaticSetFontSize(attrTitleText, UIDefine.FontSizeM)
    UILayout.SetSameAnchorAndPivot(attrTitleText, UILayout.Center)

    local attrScr =
        GUI.LoopScrollRectCreate(
        attrBg,
        "attrScr",
        0,
        18,
        242,
        120,
        "TitleUI",
        "CreateAttr",
        "TitleUI",
        "RefreshAttrScroll",
        0,
        false,
        Vector2.New(240, 30),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    guidt.BindName(attrScr, "attrScr")
    GUI.ScrollRectSetChildSpacing(attrScr, Vector2.New(0, 2))
    local typeListBg = GUI.ImageCreate(panelBg, "typeListBg", "1800400200", -378, -77, false, 263, 342)
    TitleUI.CreateTypeList(typeListBg)
    TitleUI.RefreshUI()
end
function TitleUI.OnShow(parameter)
    --test("TitleUI.OnShow----------------")
    local wnd = GUI.GetWnd("TitleUI")
    if wnd == nil then
        return
    end
    -- 根据parameter决定跳转的标签
    local idx = tonumber(parameter)
    if idx ~= nil then
        local flag = 1
        TitleUI.OnListTypeBtnClick(guidt.GetGuid("btnType" .. idx),flag)
    end
    TitleUI.Refresh()
    GUI.SetVisible(wnd, true)
    CL.RegisterMessage(GM.TitleUpdate, "TitleUI", "ClientRefresh")
    CL.RegisterAttr(RoleAttr.RoleAttrTitle, TitleUI.RefreshCurTitleId)
end
function TitleUI.OnDestroy()
    TitleUI.OnClose()
end
function TitleUI.OnClose()
    CL.UnRegisterAttr(RoleAttr.RoleAttrTitle, TitleUI.RefreshCurTitleId)
    CL.UnRegisterMessage(GM.TitleUpdate, "TitleUI", "ClientRefresh")
    TitleUI.OnExitGame()
    local wnd = GUI.GetWnd("TitleUI")
    GUI.SetVisible(wnd, false)
    for key, value in pairs(TitleUI.limitTime) do
        value:Stop()
    end
    TitleUI.limitTime = {}
end
--当前称号变更
function TitleUI.RefreshCurTitleId(type, val)
    if type == RoleAttr.RoleAttrTitle then
        local h = 0
        data.curId, h = int64.longtonum2(val)
        TitleUI.RefreshUI()
    end
end
function TitleUI.GetDate()
    --test("运行到TitleUI.GetDate()1111111111111111111111111111111111111")
    data.type = {}
    data.hastype = {}
    data.curId = CL.GetIntAttr(RoleAttr.RoleAttrTitle)
    data.attr = {}
    data.attrId = {}
    local keys = DB.GetTitleAllKey1s()
    for i = 0, keys.Count - 1 do
        local t = DB.GetOnceTitleByKey1(keys[i])
        if t.Hide ~= 1 then
            ---@type titleInfo
            local tmp = {}
            tmp.id = t.Id

            tmp.has = LD.HasTitle(tmp.id)
            tmp.limitTime = LD.GetTitleLimit(tmp.id)
            -- 测试用
            -- if tmp.id == 701 then
            --     tmp.limitTime = CL.GetServerTickCount() + 60
            -- end
            tmp.getWay = t.Way
            tmp.color = t.Color
            tmp.pic = t.Pic
            tmp.name = t.Name
            tmp.keyname = t.KeyName
            tmp.type = t.Type
            tmp.subType = tonumber(t.SubType)
            tmp.index = t.IndexTitle
            tmp.tip = t.Tips
            tmp.guideType = t.GuideType
            tmp.guideCoef1 = t.GuideCoef1
            tmp.guideCoef2 = t.GuideCoef2
            tmp.guideCoef3 = t.GuideCoef3
            tmp.attr = {}
            local dbBuff = DB.GetOnceBuffByKey1(t.BuffId)
            for j = 1, 12 do
                local id = dbBuff["FixedAtt" .. j]
                local value = dbBuff["FixedAtt" .. j .. "Att1Coef1"]
                if id > 0 and value > int64.zero then
                    ---@type DynAttrData
                    local tmpattr = LogicDefine.NewAttrTable()
                    tmpattr.attr = id
                    tmpattr.value = value
                    local dbattr = DB.GetOnceAttrByKey1(id)
                    if dbattr.Id == 0 then
                        test("属性数据错误")
                    end
                    tmpattr.IsPct = dbattr.IsPct == 1
                    tmpattr.name = dbattr.ChinaName
                    tmp.attr[#tmp.attr + 1] = tmpattr
                    if tmp.has then
                        if data.attr[id] == nil then
                            data.attr[id] = LogicDefine.NewAttrTable()

                            data.attr[id].attr = tmpattr.attr
                            data.attr[id].value = tmpattr.value
                            data.attr[id].IsPct = tmpattr.IsPct
                            data.attr[id].name = tmpattr.name

                            data.attrId[#data.attrId + 1] = id
                        else
                            data.attr[id].value = tmpattr.value + data.attr[id].value
                        end
                    end
                end
            end
            data.title[t.Id] = tmp
            if tmp.subType == 0 then
                tmp.subType = 1
            end
            local fun = function(t, title, has)
                if t[TitleAll] == nil then
                    t[TitleAll] = {}
                end
                if t[title.type] == nil then
                    t[title.type] = {}
                end
                if t[title.type][title.subType] == nil then
                    t[title.type][title.subType] = {}
                end
                if t[TitleAll][1] == nil then
                    t[TitleAll][1] = {}
                end
                if has == nil or tmp.has then
                    t[TitleAll][1][#t[TitleAll][1] + 1] = title.id
                    t[title.type][title.subType][#t[title.type][title.subType] + 1] = title.id
                end
            end
            fun(data.type, tmp)
            fun(data.hastype, tmp, true)
        end
    end
    local t = {data.type, data.hastype}
    for i = 1, #t do
        for _, value in pairs(data.type) do
            -- body
            for _, value2 in pairs(value) do
                -- body
                table.sort(
                    value2,
                    function(a, b)
                        return data.title[a].index < data.title[b].index
                    end
                )
            end
        end
    end
end
function TitleUI.Refresh()
    -- test("TitleUI.Refresh()")
    TitleUI.ClientRefresh()
end
-- 客户端重新获取数据
function TitleUI.ClientRefresh()
    TitleUI.GetDate()
    TitleUI.RefreshUI()
end
function TitleUI.RefreshUI()
    local main_type = data.typeIndex
    local type_flag = data.typeIndexFlag
    if data.type[data.typeIndex][data.subTypeIndex] == nil then
        --配置中无该类型称号
        for i = 1, #TitleSubtype[data.typeIndex] do
            if data.type[data.typeIndex][i] then
                data.subTypeIndex = i
                break
            end
        end
    end

    for mainType, _ in pairs(TitleType) do
        local listType = guidt.GetUI("listType" .. mainType)
        local btnType = guidt.GetUI("btnType" .. mainType)
        if main_type ~= mainType or main_type==type_flag then
            GUI.ButtonSetImageID(btnType, "1800002030")
            GUI.SetVisible(listType, false)
            local selectMark = GUI.GetChild(btnType, "selectMark")
            GUI.SetPositionX(selectMark, 30)
            GUI.SetPositionY(selectMark, 0)
            GUI.SetEulerAngles(selectMark, Vector3.New(0, 0, 0))
        else
            GUI.ButtonSetImageID(btnType, "1800002031")
            GUI.SetVisible(listType, true)
            local selectMark = GUI.GetChild(btnType, "selectMark")
            GUI.SetPositionX(selectMark, 38)
            GUI.SetPositionY(selectMark, 15)
            GUI.SetEulerAngles(selectMark, Vector3.New(0, 0, -90))
        end
        for i, _ in pairs(TitleSubtype[data.typeIndex]) do
            local name = "subtype" .. data.typeIndex .. "_" .. i
            local sub = guidt.GetUI(name)
            if sub then
                if i == data.subTypeIndex then
                    GUI.ButtonSetImageID(sub, "1801302061")
                else
                    GUI.ButtonSetImageID(sub, "1801302060")
                end
            end
        end
    end

    local src = guidt.GetUI("titleScr")
    local cnt =
        data.isHas and #data.hastype[data.typeIndex][data.subTypeIndex] or #data.type[data.typeIndex][data.subTypeIndex]
    GUI.LoopScrollRectSetTotalCount(src, cnt)
    GUI.LoopScrollRectRefreshCells(src)
    local attrScr = guidt.GetUI("attrScr")
    GUI.LoopScrollRectSetTotalCount(attrScr, #data.attrId)
end
function TitleUI.CreateTitle()
    local scroll = guidt.GetUI("titleScr")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = GUI.CheckBoxExCreate(scroll, curCount, "1801100010", "1801100010", 0, 0, false, 280, 100)
    local titleBg = GUI.ImageCreate(item, "titleBg", "1801501050", -270, 0)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "TitleUI", "OnItemClick")
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Center)
    local titleIconBg = GUI.ImageCreate(titleBg, "titleIconBg", "1801502100", 0, 0)
    local titleImg = GUI.ImageCreate(titleBg, "titleImg", "1801501060", 0, 0)
    local sp = GUI.SpriteFrameCreate(titleBg, "ani", "", 0, 0)
    GUI.SetIsRaycastTarget(sp, false)
    local titleText = GUI.CreateStatic(titleImg, "titleText", " ", 0, 0, 140, 25)
    GUI.SetIsOutLine(titleText, true)
    GUI.SetOutLine_Color(titleText, UIDefine.BrownColor)
    GUI.SetOutLine_Distance(titleText, 1)
    GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(titleText, UIDefine.FontSizeS)
    local limitTimeText = GUI.CreateStatic(titleBg, "limitTimeText", " ", 0, 0, 150, 25)
    UILayout.SetSameAnchorAndPivot(limitTimeText, UILayout.Bottom)
    GUI.StaticSetAlignment(limitTimeText, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(limitTimeText, UIDefine.FontSizeS)
    GUI.SetColor(limitTimeText, UIDefine.GreenColor)
    local lockMark = GUI.ImageCreate(titleBg, "lockMark", "1800408170", 0, 0, false, 21, 26)
    UILayout.SetSameAnchorAndPivot(lockMark, UILayout.BottomRight)
    local currentMark = GUI.ImageCreate(item, "currentMark", "1801507150", 0, 0)
    UILayout.SetSameAnchorAndPivot(currentMark, UILayout.TopLeft)
    local cutLine = GUI.ImageCreate(item, "cutLine", "1801401090", 35, 0, false, 440, 3)
    local statusBtn = GUI.ButtonCreate(item, "statusBtn", "1801402080", -17, 0, Transition.ColorTint, " ")
    GUI.RegisterUIEvent(statusBtn, UCE.PointerClick, "TitleUI", "OnClick")
    UILayout.SetSameAnchorAndPivot(statusBtn, UILayout.Right)
    GUI.ButtonSetTextColor(statusBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(statusBtn, UIDefine.FontSizeL)
    local attrbg = GUI.CreateStatic(item, "attrbg", "激活属性:", 180, 18, 280, 30)
    UILayout.SetSameAnchorAndPivot(attrbg, UILayout.TopLeft)
    GUI.SetColor(attrbg, UIDefine.BrownColor)
    GUI.StaticSetFontSize(attrbg, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(attrbg, TextAnchor.LowerLeft)
    local getWayText = GUI.CreateStatic(item, "getWayText", "获取方式", 180, 61, 430, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(getWayText, UILayout.TopLeft)
    GUI.SetColor(getWayText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(getWayText, 20)
    local attr = GUI.CreateStatic(item, "attr", " ", 300, 18, 323, 30)
    UILayout.SetSameAnchorAndPivot(attr, UILayout.TopLeft)
    GUI.SetColor(attr, UIDefine.Green5Color)
    GUI.StaticSetFontSize(attr, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(attr, TextAnchor.LowerLeft)
    return item
end
function TitleUI.RefreshTitleScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local title =
        data.isHas and data.title[data.hastype[data.typeIndex][data.subTypeIndex][index]] or
        data.title[data.type[data.typeIndex][data.subTypeIndex][index]]
    if title == nil then
        test("无数据  " .. "typeIndex =" .. data.typeIndex .. "subTypeIndex =" .. data.subTypeIndex .. "index = " .. index)
        return
    end
    local item = GUI.GetByGuid(guid)
    local titleBg = GUI.GetChild(item, "titleBg", false)
    local titleImg = GUI.GetChild(titleBg, "titleImg", false)
    local sp = GUI.GetChild(titleBg, "ani", false)
    local titleText = GUI.GetChild(titleImg, "titleText", false)

    local limitTimeText = GUI.GetChild(titleBg, "limitTimeText", false)
    local lockMark = GUI.GetChild(titleBg, "lockMark", false)
    local currentMark = GUI.GetChild(item, "currentMark", false)
    local statusBtn = GUI.GetChild(item, "statusBtn", false)
    local getWayText = GUI.GetChild(item, "getWayText", false)
    local attr = GUI.GetChild(item, "attr", false)

    GUI.ButtonSetIndex(statusBtn, index - 1)
    if title.pic == nil or title.pic == uint64.zero then
        GUI.SetVisible(titleImg, true)
        GUI.SetFrameId(sp, 0)
        GUI.SetVisible(sp, false)
        local a = string.find(title.name, "$", 1)
        if string.sub(title.name, 1, 1) == "$" then
            GUI.StaticSetText(titleText, title.keyname)
        else
            GUI.StaticSetText(titleText, title.name)
        end
        local c = string.split(title.color, ",")
        if #c == 3 then
            GUI.SetColor(titleText, Color.New((tonumber(c[1])) / 255, tonumber(c[2]) / 255, tonumber(c[3]) / 255, 1))
        else
            GUI.SetColor(titleText, UIDefine.BlackColor)
        end
    else
        GUI.SetVisible(titleImg, false)
        GUI.SetFrameId(sp, tostring(title.pic))
        GUI.SpriteFrameSetIsLoop(sp, true)
        GUI.Play(sp)
        local W = GUI.GetWidth(sp)
        local scale = ImageSice[1]/W
        GUI.SetScale(sp,Vector3.New(scale, scale, 1))
        GUI.SetVisible(sp, true)
    end
    if TitleUI.limitTime[index] then
        TitleUI.limitTime[index]:Stop()
        TitleUI.limitTime[index] = nil
    end
    if title.limitTime > 0 then
        GUI.StaticSetText(limitTimeText, UIDefine.LeftTimeFormat(title.limitTime))
        local str, day, hour, minute, s = UIDefine.LeftTimeFormatEx(title.limitTime)
        if day == 0 and hour == 0 then
            test("new time " .. index)
            TitleUI.limitTime[index] =
                Timer.New(
                function()
                    local item = GUI.GetByGuid(guid)
                    local newindex = GUI.CheckBoxExGetIndex(item) + 1
                    test(index)
                    test(newindex)
                    if newindex == index then
                        local str, day, hour, minute, s = UIDefine.LeftTimeFormatEx(title.limitTime)
                        local titleBg = GUI.GetChild(item, "titleBg", false)
                        local limitTimeText = GUI.GetChild(titleBg, "limitTimeText", false)
                        GUI.StaticSetText(limitTimeText, str)
                        if day == 0 and hour == 0 and minute == 0 and s == 0 then
                            GUI.StaticSetText(limitTimeText, " ")
                            GUI.SetVisible(limitTimeText, false)
                            TitleUI.limitTime[index]:Stop()
                            TitleUI.limitTime[index] = nil
                        end
                    else
                        TitleUI.limitTime[index]:Stop()
                        TitleUI.limitTime[index] = nil
                    end
                end,
                1,
                -1
            )
            TitleUI.limitTime[index]:Start()
        end
        GUI.SetVisible(limitTimeText, true)
    else
        GUI.SetVisible(limitTimeText, false)
    end
    GUI.SetVisible(lockMark, not title.has)
    local isCur = title.id == data.curId
    GUI.SetVisible(currentMark, isCur)
    if isCur then
        GUI.ButtonSetText(statusBtn, "卸下")
    elseif title.has then
        GUI.ButtonSetText(statusBtn, "装备")
    else
        GUI.ButtonSetText(statusBtn, "获取")
    end
    GUI.StaticSetText(getWayText, title.getWay)
    -- test("title.getWay : ".. title.getWay)

    local attrTxt = ""
    for i = 1, #title.attr do
        attrTxt = attrTxt .. title.attr[i].name .. " "
        attrTxt = attrTxt .. title.attr[i].GetStrValue() .. " "
        if i ~= #title.attr then
            attrTxt = attrTxt .. "，"
        end
    end

    GUI.StaticSetText(attr, attrTxt)
end

function TitleUI.CreateAttr()
    local scroll = guidt.GetUI("attrScr")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = GUI.GroupCreate(scroll, curCount, 0, 0, 0, 0)
    local attr = GUI.CreateStatic(item, "attr", "属性", 12, 0, 200, 30, "system", true)

    GUI.StaticSetFontSize(attr, UIDefine.FontSizeS)
    GUI.SetColor(attr, UIDefine.BrownColor)
    GUI.StaticSetAlignment(attr, TextAnchor.MiddleLeft)
    -- local vale = GUI.CreateStatic(attr, "value", "+1", 50, 0, 100, 30)
    -- UILayout.SetSameAnchorAndPivot(vale, UILayout.Right)
    -- GUI.StaticSetFontSize(vale, UIDefine.FontSizeS)
    -- GUI.SetColor(vale, UIDefine.GreenColor)

    return item
end
function TitleUI.RefreshAttrScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local id = data.attrId[index]
    local tmp = data.attr[id].GetStrValue()
    if string.sub(tmp, 1, 1) == "-" then
    else
        tmp = "+" .. tmp
    end
    local text = "<color=#975c22>" .. data.attr[id].name .. "</color> <color=#08af00>" .. tmp .. "</color>"
    local group = GUI.GetByGuid(guid)
    local attr = GUI.GetChild(group, "attr", false)
    GUI.StaticSetText(attr, text)
end
-- 创建类型列表
function TitleUI.CreateTypeList(parent)
    local titleTypeListScroll =
        GUI.ScrollListCreate(parent, "titleTypeListScroll", 8, 8, 248, 320, false, UIAroundPivot.Top, UIAnchor.Top)
    UILayout.SetSameAnchorAndPivot(titleTypeListScroll, UILayout.TopLeft)
    guidt.BindName(titleTypeListScroll, "titleTypeListScroll")
    local mainTypeIndex = 0
    local subTypeIndex = 0
    for i = 1, #TitleIndex do
        local mainType = TitleIndex[i]
        --test("mainType " .. mainType)
        local mainTypeName = TitleType[mainType]
        if TitleSubtype[mainType] ~= nil and data.type[mainType] then
            mainTypeIndex = mainTypeIndex + 1
            -- 父节点按钮
            local listTypeBtn =
                GUI.ButtonCreate(
                titleTypeListScroll,
                "listTypeBtn" .. mainType,
                "1800002030",
                0,
                0,
                Transition.ColorTint,
                mainTypeName,
                248,
                62,
                false
            )
            guidt.BindName(listTypeBtn, "btnType" .. mainType)
            GUI.RegisterUIEvent(listTypeBtn, UCE.PointerClick, "TitleUI", "OnListTypeBtnClick")
            UILayout.SetSameAnchorAndPivot(listTypeBtn, UILayout.Top)
            GUI.ButtonSetTextFontSize(listTypeBtn, UIDefine.FontSizeXL)
            GUI.ButtonSetTextColor(listTypeBtn, UIDefine.BrownColor)
            GUI.SetPreferredHeight(listTypeBtn, 62)
            --当前个数和总个数
            local gainedCnt = 0
            local totalCnt = 0
            local selectMark = GUI.ImageCreate(listTypeBtn, "selectMark", "1801208630", -30, 0)
            UILayout.SetSameAnchorAndPivot(selectMark, UILayout.Right)
            GUI.SetVisible(selectMark, mainType ~= -1 and #TitleSubtype[mainType] > 0)

            -- 子节点列表框
            local listType = GUI.ListCreate(titleTypeListScroll, "listType" .. mainType, 0, 0, 248, 320, false)
            UILayout.SetSameAnchorAndPivot(listType, UILayout.Top)
            GUI.SetVisible(listType, mainType == 0)
            GUI.SetPaddingHorizontal(listType, Vector2.New(0, 0))
            guidt.BindName(listType, "listType" .. mainType)

            -- 子节点
            if TitleSubtype[mainType] ~= nil then
                for subType, item in pairs(data.type[mainType]) do
                    if data.hastype[mainType] and data.hastype[mainType][subType] then
                        gainedCnt = gainedCnt + #data.hastype[mainType][subType]
                    end
                    totalCnt = totalCnt + #data.type[mainType][subType]
                    if TitleSubtype[mainType][subType] then
                        local name = "subtype" .. mainType .. "_" .. subType
                        local listTypeSubBtn =
                            GUI.ButtonCreate(
                            listType,
                            name,
                            "1801302060",
                            0,
                            0,
                            Transition.ColorTint,
                            TitleSubtype[mainType][subType],
                            248,
                            62,
                            false
                        )
                        UILayout.SetSameAnchorAndPivot(listTypeSubBtn, UILayout.Top)
                        GUI.ButtonSetTextFontSize(listTypeSubBtn, UIDefine.FontSizeXL)
                        GUI.ButtonSetTextColor(listTypeSubBtn, UIDefine.BrownColor)
                        GUI.RegisterUIEvent(listTypeSubBtn, UCE.PointerClick, "TitleUI", "OnListTypeSubBtnClick")
                        guidt.BindName(listTypeSubBtn, name)
                    end
                end
            end

            local txt =
                "<color=#66310e>" ..
                mainTypeName ..
                    "</color><color=#975c22><size=20>（" .. gainedCnt .. "/" .. totalCnt .. "）" .. "</size></color>"
            GUI.ButtonSetText(listTypeBtn, txt)
        end
    end
end
--主类型点击
function TitleUI.OnListTypeBtnClick(guid, flag)
    -- test("OnListTypeBtnClick")
    if flag == 1 then
        local scroll = guidt.GetUI("titleTypeListScroll")
        GUI.ScrollRectSetNormalizedPosition(scroll, Vector2.New(0.7))
    end
    for i = 1, #TitleIndex do
        local main_type = TitleIndex[i]
        if guidt.GetGuid("btnType" .. main_type) == guid then
            if data.typeIndexFlag~=data.typeIndex and #TitleSubtype[TitleIndex[i]] > 0 then
                data.typeIndexFlag=data.typeIndex
            else
                data.typeIndexFlag=-2
            end
            data.typeIndex = main_type
            data.subTypeIndex = 1
            data.Index = 1
            break
        end
    end
    TitleUI.RefreshUI()
end
-- 子类型被点击
function TitleUI.OnListTypeSubBtnClick(guid)
    local main_type = data.typeIndex
    for i = 1, #TitleSubtype[data.typeIndex] do
        if guidt.GetGuid("subtype" .. main_type .. "_" .. i) == guid then
            data.subTypeIndex = i
            data.Index = 1
            break
        end
    end
    TitleUI.RefreshUI()
end
-- 点击是否拥有
function TitleUI.OnClickCheck(guid)
    data.isHas = not data.isHas
    TitleUI.RefreshUI()
end
function TitleUI.OnClick(guid)
    data.Index = GUI.ButtonGetIndex(GUI.GetByGuid(guid)) + 1
    local t = data.isHas and data.hastype or data.type
    local id = t[data.typeIndex][data.subTypeIndex][data.Index]
    local info = data.title[id]

    if data.curId == id then
        CL.SendNotify(NOTIFY.SubmitForm, "FormTitle", "SetCurTitle", 0)
    elseif info.has then
        CL.SendNotify(NOTIFY.SubmitForm, "FormTitle", "SetCurTitle", id)
    else
        if GetWay.Def[info.guideType] then
            GetWay.Def[info.guideType].jump(info.guideCoef1, info.guideCoef2, info.guideCoef3)
            if info.guideType==2 or info.guideType==3 then
                if TitleUI then
                    --TitleUI.OnExit()
                    GUI.CloseWnd("TitleUI")
                end
                if RoleAttributeUI then
                    GUI.CloseWnd("RoleAttributeUI")
                end
            end
        end
    end
end
function TitleUI.OnItemClick(guid)
    local tmp = GUI.GetByGuid(guid)
    local panelBg = guidt.GetUI("panelBg")
    local index = GUI.CheckBoxExGetIndex(tmp) + 1
    local t = data.isHas and data.hastype or data.type
    local id = t[data.typeIndex][data.subTypeIndex][index]
    test(id)
    local screenPoint = GUI.GetScreenPoint(tmp)
    local endP = GUI.GetPointByScreenPoint(panelBg, screenPoint)
    local posX = endP.x + 60
    local posY = -endP.y
    local tip = Tips.CreateHint(data.title[id].tip, panelBg, posX, posY, UILayout.Center, 490)
    GUI.SetIsRemoveWhenClick(tip, true)
end
