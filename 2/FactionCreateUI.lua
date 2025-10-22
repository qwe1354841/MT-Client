FactionCreateUI = {}

local _gt = UILayout.NewGUIDUtilTable()
local ONE_PAGE_NUM = 10

FactionCreateUI.lastSelectFactionID = 0
FactionCreateUI.lastSelectFactionLeaderGUID = 0
FactionCreateUI.lastSelectFactionItemElementGuid = nil
FactionCreateUI.FirstSelectFactionItemElementGuid = nil
FactionCreateUI.PageNumber = 0
FactionCreateUI.TotalPageNumber = 1
FactionCreateUI.FactionList = nil
FactionCreateUI.TotalFactionCount = 1
FactionCreateUI.SearchMode = false
local AddGuid = nil

--创建帮派需要花费的银币
local CREATE_FACTION_COST = 100000
--一键申请帮派时间间隔的标记 和 时间间隔
local ONEKEY_APPLY_LABEL = "FactionOneKeyApply_"
local ONEKEY_APPLY_TIME_INTERVAL = 1800

function FactionCreateUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    test("FactionCreateUI")

    local wnd = GUI.WndCreateWnd("FactionCreateUI", "FactionCreateUI", 0, 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "帮派列表", "FactionCreateUI", "OnExit", _gt)

    local factionListBg = GUI.ImageCreate(panelBg, "factionListBg", "1800400200", 78, 68, false, 710, 500)
    UILayout.SetSameAnchorAndPivot(factionListBg, UILayout.TopLeft)

    local idBg = GUI.ImageCreate(factionListBg, "idBg", "1800800120", 2, -9, false, 112, 36)
    UILayout.SetSameAnchorAndPivot(idBg, UILayout.TopLeft)
    local txt = GUI.CreateStatic(idBg, "txt", "编号", 0, 0, 49, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local factionNameBg = GUI.ImageCreate(factionListBg, "factionNameBg", "1800800130", 114, -9, false, 156, 36)
    UILayout.SetSameAnchorAndPivot(factionNameBg, UILayout.TopLeft)
    local txt = GUI.CreateStatic(factionNameBg, "txt", "帮派名称", 0, 0, 97, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local leaderNameBg = GUI.ImageCreate(factionListBg, "leaderNameBg", "1800800130", 270, -9, false, 172, 36)
    UILayout.SetSameAnchorAndPivot(leaderNameBg, UILayout.TopLeft)
    local txt = GUI.CreateStatic(leaderNameBg, "txt", "帮主名称", 0, 0, 97, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local factionLevelBg = GUI.ImageCreate(factionListBg, "factionLevelBg", "1800800130", 442, -9, false, 136, 36)
    UILayout.SetSameAnchorAndPivot(factionLevelBg, UILayout.TopLeft)
    local txt = GUI.CreateStatic(factionLevelBg, "txt", "帮派等级", 0, 0, 97, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local memberCountBg = GUI.ImageCreate(factionListBg, "memberCountBg", "1800800140", 578, -9, false, 130, 36)
    UILayout.SetSameAnchorAndPivot(memberCountBg, UILayout.TopLeft)
    local txt = GUI.CreateStatic(memberCountBg, "txt", "帮派人数", 0, 0, 97, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local factionListScr = GUI.GroupCreate(factionListBg, "factionListScr", 0, 30, 700, 458)
    _gt.BindName(factionListScr, "factionListScr")
    UILayout.SetSameAnchorAndPivot(factionListScr, UILayout.Top)

    local factionInfoBg = GUI.ImageCreate(panelBg, "factionInfoBg", "1800400200", -78, 68, false, 310, 445)
    UILayout.SetSameAnchorAndPivot(factionInfoBg, UILayout.TopRight)

    local factionInfoTitleBg = GUI.ImageCreate(factionInfoBg, "factionInfoTitleBg", "1800700070", 0, -9, false, 306, 36)
    UILayout.SetSameAnchorAndPivot(factionInfoTitleBg, UILayout.Top)
    local txt = GUI.CreateStatic(factionInfoTitleBg, "txt", "帮派信息", 0, 0, 97, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local factionNameBg = GUI.ImageCreate(factionInfoBg, "factionNameBg", "1800607180", -5, 35)
    UILayout.SetSameAnchorAndPivot(factionNameBg, UILayout.TopLeft)
    local txt = GUI.CreateStatic(factionNameBg, "txt", "帮派名称", 10, 0, 97, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local factionName = GUI.CreateStatic(factionNameBg, "factionName", "", 10, 30, 250, 30)
    _gt.BindName(factionName, "factionName")
    UILayout.SetSameAnchorAndPivot(factionName, UILayout.TopLeft)
    GUI.SetColor(factionName, UIDefine.BrownColor)
    GUI.StaticSetFontSize(factionName, UIDefine.FontSizeL)

    local factionLeardBg = GUI.ImageCreate(factionInfoBg, "factionLeardBg", "1800607180", -5, 110)
    UILayout.SetSameAnchorAndPivot(factionLeardBg, UILayout.TopLeft)
    local txt = GUI.CreateStatic(factionLeardBg, "txt", "帮主信息", 10, 0, 97, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local leaderName = GUI.CreateStatic(factionLeardBg, "leaderName", "", 10, 30, 200, 30)
    _gt.BindName(leaderName, "leaderName")
    UILayout.SetSameAnchorAndPivot(leaderName, UILayout.TopLeft)
    GUI.SetColor(leaderName, UIDefine.BrownColor)
    GUI.StaticSetFontSize(leaderName, UIDefine.FontSizeL)

    local leaderSchool = GUI.CreateStatic(factionLeardBg, "leaderSchool", "", 10, 60, 120, 30)
    _gt.BindName(leaderSchool, "leaderSchool")
    UILayout.SetSameAnchorAndPivot(leaderSchool, UILayout.TopLeft)
    GUI.SetColor(leaderSchool, UIDefine.BrownColor)
    GUI.StaticSetFontSize(leaderSchool, UIDefine.FontSizeL)

    local leaderLevel = GUI.CreateStatic(leaderSchool, "leaderLevel", "", 140, 0, 120, 30)
    _gt.BindName(leaderLevel, "leaderLevel")
    UILayout.SetSameAnchorAndPivot(leaderLevel, UILayout.Left)
    GUI.SetColor(leaderLevel, UIDefine.BrownColor)
    GUI.StaticSetFontSize(leaderLevel, UIDefine.FontSizeL)

    local factionBoardBg = GUI.ImageCreate(factionInfoBg, "factionBoardBg", "1800607180", -5, 210)
    UILayout.SetSameAnchorAndPivot(factionBoardBg, UILayout.TopLeft)
    local txt = GUI.CreateStatic(factionBoardBg, "txt", "帮派宣言", 10, 0, 97, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)

    local factionBoard = GUI.CreateStatic(factionBoardBg, "factionBoard", "", 10, 30, 290, 165, "system", false)
    _gt.BindName(factionBoard, "factionBoard")
    UILayout.SetSameAnchorAndPivot(factionBoard, UILayout.TopLeft)
    GUI.SetColor(factionBoard, UIDefine.BrownColor)
    GUI.StaticSetFontSize(factionBoard, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(factionBoard, TextAnchor.UpperLeft)

    local previousPageBtn = GUI.ButtonCreate(panelBg, "previousPageBtn", "1800402110", 78, -35, Transition.SpriteSwap, "", 120, 45, false)
    _gt.BindName(previousPageBtn, "previousPageBtn")
    UILayout.SetSameAnchorAndPivot(previousPageBtn, UILayout.BottomLeft)
    local btnTxt = GUI.CreateStatic(previousPageBtn, "btnTxt", "上一页", 22, 0, 120, 35)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    GUI.SetColor(btnTxt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(previousPageBtn, UCE.PointerClick, "FactionCreateUI", "OnPreviousPageBtnClick")

    local pageNumBg = GUI.ImageCreate(panelBg, "pageNumBg", "1800400200", 200, -40, false, 70, 35)
    UILayout.SetSameAnchorAndPivot(pageNumBg, UILayout.BottomLeft)
    local txt = GUI.CreateStatic(pageNumBg, "txt", "0/0", 0, 0, 60, 35)
    _gt.BindName(txt, "pageNumTxt")
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetColor(txt, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeSS)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

    local nextPageBtn = GUI.ButtonCreate(panelBg, "nextPageBtn", "1800402110", 270, -35, Transition.SpriteSwap, "", 120, 45, false)
    _gt.BindName(nextPageBtn, "nextPageBtn")
    UILayout.SetSameAnchorAndPivot(nextPageBtn, UILayout.BottomLeft)
    local btnTxt = GUI.CreateStatic(nextPageBtn, "btnTxt", "下一页", 22, 0, 120, 35)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    GUI.SetColor(btnTxt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(nextPageBtn, UCE.PointerClick, "FactionCreateUI", "OnNextPageBtnClick")

    local searchTips = GUI.CreateStatic(panelBg, "searchTips", "", 405, -42, 112, 30)
    UILayout.SetSameAnchorAndPivot(searchTips, UILayout.BottomLeft)
    GUI.SetColor(searchTips, UIDefine.BrownColor)
    GUI.StaticSetFontSize(searchTips, UIDefine.FontSizeL)
    GUI.StaticSetText(searchTips, "帮派搜索:")

    local inputField = GUI.EditCreate(searchTips, "inputField", "1800400390", "输入名称或ID", 110, 0, Transition.ColorTint, "system", 225, 40, 10)
    _gt.BindName(inputField, "inputField")
    UILayout.SetSameAnchorAndPivot(inputField, UILayout.Left)
    GUI.EditSetLabelAlignment(inputField, TextAnchor.MiddleCenter)
    GUI.EditSetFontSize(inputField, UIDefine.FontSizeL)
    GUI.EditSetTextColor(inputField, UIDefine.BrownColor)
    GUI.SetPlaceholderTxtColor(inputField, UIDefine.GrayColor)


    local searchBtn = GUI.ButtonCreate(searchTips, "searchBtn", "1800802010", 340, 0, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(searchBtn, UILayout.Left)
    GUI.RegisterUIEvent(searchBtn, UCE.PointerClick, "FactionCreateUI", "OnSearchBtnClick")

    local createFactionBtn = GUI.ButtonCreate(panelBg, "createFactionBtn", "1800602030", -245, -90, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(createFactionBtn, UILayout.BottomRight)
    local btnTxt = GUI.CreateStatic(createFactionBtn, "btnTxt", "创建帮派", -14, 0, 135, 45)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeXL)
    GUI.SetColor(btnTxt, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(btnTxt, 1)
    GUI.SetIsOutLine(btnTxt, true)
    GUI.RegisterUIEvent(createFactionBtn, UCE.PointerClick, "FactionCreateUI", "OnCreateFactionBtnClick")

    local applyAllFactionBtn = GUI.ButtonCreate(panelBg, "applyAllFactionBtn", "1800602030", -80, -90, Transition.ColorTint)
    _gt.BindName(applyAllFactionBtn, "applyAllFactionBtn")
    GUI.SetEventCD(applyAllFactionBtn,UCE.PointerClick,5)
    UILayout.SetSameAnchorAndPivot(applyAllFactionBtn, UILayout.BottomRight)
    local btnTxt = GUI.CreateStatic(applyAllFactionBtn, "btnTxt", "一键申请", -14, 0, 135, 45)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeXL)
    GUI.SetColor(btnTxt, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(btnTxt, 1)
    GUI.SetIsOutLine(btnTxt, true)
    GUI.RegisterUIEvent(applyAllFactionBtn, UCE.PointerClick, "FactionCreateUI", "OnApplyAllFactionBtnClick")

    local connectLeaderBtn = GUI.ButtonCreate(panelBg, "connectLeaderBtn", "1800602030", -245, -36, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(connectLeaderBtn, UILayout.BottomRight)
    local btnTxt = GUI.CreateStatic(connectLeaderBtn, "btnTxt", "联系帮主", -14, 0, 135, 45)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeXL)
    GUI.SetColor(btnTxt, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(btnTxt, 1)
    GUI.SetIsOutLine(btnTxt, true)
    GUI.RegisterUIEvent(connectLeaderBtn, UCE.PointerClick, "FactionCreateUI", "OnConnectLeaderBtnClick")

    local applyFactionBtn = GUI.ButtonCreate(panelBg, "applyFactionBtn", "1800602030", -80, -36, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(applyFactionBtn, UILayout.BottomRight)
    local btnTxt = GUI.CreateStatic(applyFactionBtn, "btnTxt", "申请入帮", -14, 0, 135, 45)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeXL)
    GUI.SetColor(btnTxt, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(btnTxt, 1)
    GUI.SetIsOutLine(btnTxt, true)
    GUI.RegisterUIEvent(applyFactionBtn, UCE.PointerClick, "FactionCreateUI", "OnApplyFactionBtnClick")

    FactionCreateUI.OnRefreshCreateFactionUI(0)

    --刷新帮派列表申请标志
    CL.RegisterMessage(GM.FactionInfoUpdate,"FactionCreateUI","FactionInfoUpdate")
end

function FactionCreateUI.FactionInfoUpdate(type, param0, param1)
    --更新帮派列表
    if type == 1 then
        --获取数据列表
        FactionCreateUI.TotalFactionCount = LD.GetGuildTotalCount()
        --CDebug.LogError("111111111......."..FactionCreateUI.TotalFactionCount)
        FactionCreateUI.TotalPageNumber = FactionCreateUI.TotalFactionCount==0 and 1 or FactionCreateUI.TotalFactionCount%ONE_PAGE_NUM==0 and FactionCreateUI.TotalFactionCount/ONE_PAGE_NUM or math.ceil(FactionCreateUI.TotalFactionCount / ONE_PAGE_NUM)
        FactionCreateUI.FactionList = LD.GetGuildList()
        FactionCreateUI.OnRefreshFactionList()
        --默认选中第一项
        FactionCreateUI.OnFactionItemClick(FactionCreateUI.FirstSelectFactionItemElementGuid)
    --搜索的帮派列表更新
    elseif type == 2 then
        FactionCreateUI.SearchMode = true
        --得到搜索结果，则重置显示回第一页
        FactionCreateUI.PageNumber = 0
        FactionCreateUI.TotalFactionCount = LD.GetSearchGuildTotalCount()
        --CDebug.LogError("222222222......."..FactionCreateUI.TotalFactionCount)
        FactionCreateUI.TotalPageNumber = FactionCreateUI.TotalFactionCount==0 and 1 or FactionCreateUI.TotalFactionCount%ONE_PAGE_NUM==0 and FactionCreateUI.TotalFactionCount/ONE_PAGE_NUM or math.ceil(FactionCreateUI.TotalFactionCount / ONE_PAGE_NUM)
        FactionCreateUI.FactionList = LD.GetSearchGuildList()
        FactionCreateUI.OnRefreshFactionList()
        FactionCreateUI.OnRefreshCreateFactionUI(FactionCreateUI.PageNumber)
    elseif type == 10 then
        --创建帮派成功
        local nameInputField = _gt.GetUI("nameInputField")
        local boardInputField = _gt.GetUI("boardInputField")
        if nameInputField and boardInputField then
            GUI.EditSetTextM(nameInputField, "")
            GUI.EditSetTextM(boardInputField, "")
        end
        FactionCreateUI.OnExit()
        GUI.OpenWnd("FactionUI")
    elseif type == 11 then
        --申请入帮
        local guildID = tonumber(param0)
        local enterGuild = (param1 == "1" and true or false)
        if enterGuild then
            --申请入帮成功
            FactionCreateUI.OnExit()
            GUI.OpenWnd("FactionUI")
        else
            --更新帮派标记
            FactionCreateUI.ShowApplyFlag(guildID)
        end
    elseif type == 12 then
        --一键申请
        local guildIDs = string.split(param0, ",")
        local enterGuild = (param1 == "1" and true or false)
        if enterGuild then
            --申请入帮成功
            FactionCreateUI.OnExit()
            GUI.OpenWnd("FactionUI")
        else
            local count = #guildIDs
            for i = 1, count do
                --更新帮派标记
                FactionCreateUI.ShowApplyFlag(tonumber(guildIDs[i]))
            end
        end

        --记录30分钟时间间隔标记
        --[[
        local areaID = CL.GetIntGameData(GameDataType.LastAreaID)
        areaID = areaID ~= nil and areaID or 0
        local saveKey = ONEKEY_APPLY_LABEL..areaID.."_"..tostring(LD.GetSelfGUID())
        local savedPreTime = CL.GetUserOperateRecord(saveKey)
        local nowTime = tonumber(tostring(LD.GetTickCount()))
        CL.SetUserOperateRecord(saveKey, tostring(nowTime))
        --]]
    elseif type == 17 then
        --申请入帮成功
        FactionCreateUI.OnExit()
        GUI.OpenWnd("FactionUI")
    end
end

function FactionCreateUI.ShowApplyFlag(guildID)
    local item = nil
    if guildID == FactionCreateUI.lastSelectFactionID then
        --是当前选中项
        item = GUI.GetByGuid(FactionCreateUI.lastSelectFactionItemElementGuid)
    else
        --在当前页查询
        for i = 0, ONE_PAGE_NUM-1 do
            local index = i + FactionCreateUI.PageNumber * ONE_PAGE_NUM
            local oneFraction = FactionCreateUI.FactionList ~= nil and LD.GetGuildByIndex(index, FactionCreateUI.SearchMode) or nil
            if oneFraction and oneFraction.guild_id == guildID then
                item = _gt.GetUI("factionItem_" .. i)
                break
            end
        end
    end
    if item ~= nil then
        local itemName = GUI.GetName(item)
        local indexI = tonumber(string.sub(itemName, 13))
        local applyTips = _gt.GetUI("applyTips"..indexI)
        GUI.SetVisible(applyTips, true)
    end
end

function FactionCreateUI.OnShow()
    FactionCreateUI.PageNumber = 0
    --请求帮派列表数据
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildList", 0, ONE_PAGE_NUM)
end

function FactionCreateUI.OnExit(...)
    GUI.DestroyWnd("FactionCreateUI")
end

function FactionCreateUI.OnSearchBtnClick(guid)
    local inputField = _gt.GetUI("inputField")
    local txt = inputField.Text
    if txt == nil or string.len(txt) == 0 then
        FactionCreateUI.SearchMode = false
        --清空搜索列表
        FactionCreateUI.TotalFactionCount = LD.GetGuildTotalCount()
        FactionCreateUI.TotalPageNumber = FactionCreateUI.TotalFactionCount==0 and 1 or FactionCreateUI.TotalFactionCount%ONE_PAGE_NUM==0 and FactionCreateUI.TotalFactionCount/ONE_PAGE_NUM or math.ceil(FactionCreateUI.TotalFactionCount / ONE_PAGE_NUM)
        --CDebug.LogError("33333333......."..FactionCreateUI.TotalFactionCount)
        FactionCreateUI.OnRefreshCreateFactionUI(0)
    else
        --请求搜索
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "SearchGuild", txt)
    end
end

function FactionCreateUI.OnRefreshCreateFactionUI(index)
    local pageNumTxt = _gt.GetUI("pageNumTxt")
    local showNowPage = index+1
    GUI.StaticSetText(pageNumTxt, showNowPage .. "/" .. FactionCreateUI.TotalPageNumber)
    FactionCreateUI.PageNumber = index
    FactionCreateUI.RefreshPageBtnState(index)
    FactionCreateUI.OnRefreshFactionList()
end

--刷新上一页、下一页按钮状态
function FactionCreateUI.RefreshPageBtnState(index)
    local previousPageBtn = _gt.GetUI("previousPageBtn")
    local nextPageBtn = _gt.GetUI("nextPageBtn")

    if index == 0 then
        GUI.ButtonSetShowDisable(previousPageBtn, false)
    else
        GUI.ButtonSetShowDisable(previousPageBtn, true)
    end

    if index == FactionCreateUI.TotalPageNumber-1 then
        GUI.ButtonSetShowDisable(nextPageBtn, false)
    else
        GUI.ButtonSetShowDisable(nextPageBtn, true)
    end

    if FactionCreateUI.TotalFactionCount == 0 then
        GUI.ButtonSetShowDisable(previousPageBtn, false)
        GUI.ButtonSetShowDisable(nextPageBtn, false)
    end
end

function FactionCreateUI.OnClickPageBtnForFresh()
    local index = FactionCreateUI.PageNumber * ONE_PAGE_NUM
    local oneFraction = LD.GetGuildByIndex(index, FactionCreateUI.SearchMode)
    --当前页为空，则请求数据
    if oneFraction == nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildList", index, ONE_PAGE_NUM)
    end
    FactionCreateUI.OnRefreshCreateFactionUI(FactionCreateUI.PageNumber)
end

function FactionCreateUI.OnPreviousPageBtnClick(guid)
    FactionCreateUI.PageNumber = math.max(FactionCreateUI.PageNumber - 1,0)
    FactionCreateUI.OnClickPageBtnForFresh()
end

function FactionCreateUI.OnNextPageBtnClick(guid)
    FactionCreateUI.PageNumber = math.min(FactionCreateUI.PageNumber + 1, FactionCreateUI.TotalPageNumber-1)
    FactionCreateUI.OnClickPageBtnForFresh()
end

function FactionCreateUI.OnRefreshFactionList()
    FactionCreateUI.lastSelectFactionID = 0
    FactionCreateUI.lastSelectFactionItemElementGuid = nil

    local factionListScr = _gt.GetUI("factionListScr")

    if _gt.GetUI("factionItem_0") == nil then
        --固定显示一页10个
        for i = 0, ONE_PAGE_NUM-1 do
            local child = GUI.ItemCtrlCreate(factionListScr, "factionItem_" .. i, "1800600230", 0, 46 * i, 705, 45, false)
            _gt.BindName(child, "factionItem_" .. i)
            UILayout.SetSameAnchorAndPivot(child, UILayout.Top)
            GUI.RegisterUIEvent(child, UCE.PointerClick, "FactionCreateUI", "OnFactionItemClick")
            FactionCreateUI.UnSelectItem(child, math.fmod(i, 2) == 0)
            if i==0 then
                FactionCreateUI.FirstSelectFactionItemElementGuid = GUI.GetGuid(child)
            end

            local txt = GUI.CreateStatic(child, "idTxt" .. i, "", -302, 0, 100, 30)
            _gt.BindName(txt, "idTxt" .. i)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            GUI.SetColor(txt, UIDefine.BrownColor)
            GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

            local txt = GUI.CreateStatic(child, "factionNameTxt" .. i, "", -163, 0, 156, 30, "system", false)
            _gt.BindName(txt, "factionNameTxt" .. i)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            GUI.SetColor(txt, UIDefine.BrownColor)
            GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

            local txt = GUI.CreateStatic(child, "leaderNameTxt" .. i, "", 0, 0, 156, 30, "system", false)
            _gt.BindName(txt, "leaderNameTxt" .. i)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            GUI.SetColor(txt, UIDefine.BrownColor)
            GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

            local txt = GUI.CreateStatic(child, "factionLevelTxt" .. i, "", 155, 0, 156, 30)
            _gt.BindName(txt, "factionLevelTxt" .. i)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            GUI.SetColor(txt, UIDefine.BrownColor)
            GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

            local txt = GUI.CreateStatic(child, "memberCountTxt" .. i, "", 284, 0, 100, 30)
            _gt.BindName(txt, "memberCountTxt" .. i)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            GUI.SetColor(txt, UIDefine.BrownColor)
            GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

            local applyTips = GUI.ImageCreate(child, "applyTips", "1800805010", 80, 5)
            UILayout.SetSameAnchorAndPivot(applyTips, UILayout.TopLeft)
            _gt.BindName(applyTips, "applyTips" .. i)
            GUI.SetVisible(applyTips, false)
        end
    end
    --刷新数据
    for i = 0, ONE_PAGE_NUM-1 do
        local index = i + FactionCreateUI.PageNumber * ONE_PAGE_NUM
        local oneFraction = FactionCreateUI.FactionList ~= nil and LD.GetGuildByIndex(index, FactionCreateUI.SearchMode) or nil

        --[[oneFraction = {
            guild_id = 100 + i,
            name = "萌途第" .. (i + 1) .. "帮",
            leader_name = "空间",
            level = 10,
            member_count = 1,
            max_member_count = 500,
        }]]

        local bShow = oneFraction ~= nil and true or false
        local child = _gt.GetUI("factionItem_" .. i)
        if child then
            GUI.SetVisible(child, bShow)
            if bShow then
                GUI.SetData(child, "ItemIndex", index)
            end
        end
        if bShow then
            if child then
                if oneFraction.guild_id == FactionCreateUI.lastSelectFactionID then
                    GUI.ItemCtrlSetElementValue(child, eItemIconElement.Border, "1800600250")
                else
                    FactionCreateUI.UnSelectItem(child, math.fmod(i, 2) == 0)
                end
            end
            local idTxt = _gt.GetUI("idTxt" .. i)
            if idTxt then
                GUI.StaticSetText(idTxt, tostring(oneFraction.guild_id))
            end
            local factionNameTxt = _gt.GetUI("factionNameTxt" .. i)
            if factionNameTxt then
                GUI.StaticSetText(factionNameTxt, oneFraction.name)
            end
            local leaderNameTxt = _gt.GetUI("leaderNameTxt" .. i)
            if leaderNameTxt then
                GUI.StaticSetText(leaderNameTxt, oneFraction.leader_name)
            end
            local factionLevelTxt = _gt.GetUI("factionLevelTxt" .. i)
            if factionLevelTxt then
                GUI.StaticSetText(factionLevelTxt, oneFraction.level .. "级")
            end
            local memberCountTxt = _gt.GetUI("memberCountTxt" .. i)
            if memberCountTxt then
                GUI.StaticSetText(memberCountTxt, oneFraction.member_count .. "/" .. oneFraction.max_member_count)
            end
            local applyTips = _gt.GetUI("applyTips" .. i)
            if applyTips then
                GUI.SetVisible(applyTips, oneFraction.applyed==1)
            end
        end
    end
end

function FactionCreateUI.UnSelectItem(item, bSelect)
    if item then
        if bSelect then
            GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800600230")
        else
            GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800600240")
        end
    end
end

function FactionCreateUI.OnFactionItemClick(strGUID)
    if FactionCreateUI.FactionList == nil then
        return
    end

    local factionName = _gt.GetUI("factionName")
    local leaderName = _gt.GetUI("leaderName")
    local leaderSchool = _gt.GetUI("leaderSchool")
    local leaderLevel = _gt.GetUI("leaderLevel")
    local factionBoardTxt = _gt.GetUI("factionBoard")

    if FactionCreateUI.lastSelectFactionItemElementGuid ~= nil and string.len(FactionCreateUI.lastSelectFactionItemElementGuid) > 0 then
        local lastBtn = GUI.GetByGuid(FactionCreateUI.lastSelectFactionItemElementGuid)
        local lastItemIndex = GUI.GetData(lastBtn, "ItemIndex")
        FactionCreateUI.UnSelectItem(lastBtn, math.fmod(lastItemIndex, 2) == 0)
    end

    local btn = GUI.GetByGuid(strGUID)
    GUI.ItemCtrlSetElementValue(btn, eItemIconElement.Border, "1800600250")
    local index = tonumber(GUI.GetData(btn, "ItemIndex"))
    if index == nil then
        return
    end
    local factionInfo = LD.GetGuildByIndex(index, FactionCreateUI.SearchMode)
    --test
    --[[
    factionInfo = {
        guid = 0,
        name = "这里显示帮派名",
        leader_name = "时代分",
        leader_level = 100,
        declaration = "这里显示帮派的宣言这里显示帮派的宣言这里显示帮派的宣言这里显示帮派的宣言这里显示帮派的宣言这里显示帮派的宣言",
    }
    --]]

    if factionInfo == nil then
        test("factionInfo == nil")
        return
    end
    local School = DB.GetSchool(factionInfo.leader_school)
    GUI.StaticSetText(factionName, factionInfo.name)
    GUI.StaticSetText(leaderName, factionInfo.leader_name)
    GUI.StaticSetText(leaderSchool,School.Name)
    GUI.StaticSetText(leaderLevel,--[[tostring(factionInfo.leader_reincarnation).."转"..]]tostring(factionInfo.leader_level) .. "级")
    GUI.StaticSetText(factionBoardTxt, factionInfo.declaration)

    FactionCreateUI.lastSelectFactionID = factionInfo.guild_id
    FactionCreateUI.lastSelectFactionLeaderGUID = factionInfo.leader_guid
    FactionCreateUI.lastSelectFactionItemElementGuid = strGUID
end

function FactionCreateUI.OnCreateFactionBtnClick(guid)
    local createFactionPanel = _gt.GetUI("createFactionPanel")
    if createFactionPanel == nil then
        local panel = GUI.GetWnd("FactionCreateUI")
        local createFactionBg = UILayout.CreateSmallMenuBgFreeWithName(panel, "帮派创建", 520, 426, "createFactionPanel", "createFactionBg")
        _gt.BindName(createFactionBg, "createFactionPanel")
        local closeBtn = GUI.GetChild(createFactionBg, "closeBtn")
        local factionNameTips = GUI.CreateStatic(createFactionBg, "factionNameTips", "", 20, 65, 250, 30)
        UILayout.SetSameAnchorAndPivot(factionNameTips, UILayout.TopLeft)
        GUI.StaticSetFontSize(factionNameTips, UIDefine.FontSizeL)
        GUI.SetColor(factionNameTips, UIDefine.BrownColor)
        GUI.StaticSetText(factionNameTips, "请输入帮派名称")

        local nameInputField = GUI.EditCreate(createFactionBg, "nameInputField", "1800400200", "", 20, 95, Transition.ColorTint, "system", 470, 45, 10)
        _gt.BindName(nameInputField, "nameInputField")
        UILayout.SetSameAnchorAndPivot(nameInputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(nameInputField, TextAnchor.MiddleLeft)
        GUI.EditSetFontSize(nameInputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(nameInputField, UIDefine.BrownColor)

        local factionBoardTips = GUI.CreateStatic(createFactionBg, "factionBoardTips", "", 20, 155)
        UILayout.SetSameAnchorAndPivot(factionBoardTips, UILayout.TopLeft)
        GUI.StaticSetFontSize(factionBoardTips, UIDefine.FontSizeL)
        GUI.SetColor(factionBoardTips, UIDefine.BrownColor)
        GUI.StaticSetText(factionBoardTips, "请输入帮派宣言")

        local boardInputField = GUI.EditCreate(createFactionBg, "boardInputField", "1800400200", "", 20, 185, Transition.ColorTint, "system", 470, 115, 10, 5)
        _gt.BindName(boardInputField, "boardInputField")
        UILayout.SetSameAnchorAndPivot(boardInputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(boardInputField, TextAnchor.UpperLeft)
        GUI.EditSetFontSize(boardInputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(boardInputField, UIDefine.BrownColor)
        GUI.EditSetMultiLineEdit(boardInputField, LineType.MultiLineSubmit)

        local createCostTips = GUI.CreateStatic(createFactionBg, "createCostTips", "", 20, -90)
        UILayout.SetSameAnchorAndPivot(createCostTips, UILayout.BottomLeft)
        GUI.StaticSetFontSize(createCostTips, UIDefine.FontSizeL)
        GUI.SetColor(createCostTips, UIDefine.BrownColor)
        GUI.StaticSetText(createCostTips, "创建费用")
        local costBg = GUI.ImageCreate(createCostTips, "costBg", "1800700010", 107, 0, false, 190, 33)
        UILayout.SetSameAnchorAndPivot(costBg, UILayout.Left)
        local costIcon = GUI.ImageCreate(costBg, "costIcon", "1800408280", 0, -1, false, 33, 33)
        UILayout.SetSameAnchorAndPivot(costIcon, UILayout.Left)
        local txt = GUI.CreateStatic(costBg, "createCostTipsTxt", "", 45, 0)
        _gt.BindName(txt, "createCostTipsTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
        GUI.SetColor(txt, UIDefine.WhiteColor)

        local concelBtn = GUI.ButtonCreate(createFactionBg, "concelBtn", "1800602030", 20, -22, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(concelBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(concelBtn, "btnTxt", "", 0, 0)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeXL)
        GUI.SetColor(btnTxt, UIDefine.WhiteColor)
        GUI.StaticSetText(btnTxt, "取消")
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "FactionCreateUI", "OnConcelBtnClick_CreateFactionPanel")

        local confirmBtn = GUI.ButtonCreate(createFactionBg, "confirmBtn", "1800602030", -20, -22, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(confirmBtn, "btnTxt", "", 0, 0)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeXL)
        GUI.SetColor(btnTxt, UIDefine.WhiteColor)
        GUI.StaticSetText(btnTxt, "创建帮派")
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "FactionCreateUI", "OnConfirmBtnClick_CreateFactionPanel")
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionCreateUI", "OnCloseBtnClick_CreateFactionPanel")
    else
        GUI.SetVisible(createFactionPanel, true)
    end

    FactionCreateUI.RefreshCreateFactionPanel()
end

--刷新帮派创建界面
function FactionCreateUI.RefreshCreateFactionPanel(...)
    local createFactionPanel = _gt.GetUI("createFactionPanel")
    if createFactionPanel == nil then
        return
    end

    local nameInputField = _gt.GetUI("nameInputField")
    local boardInputField = _gt.GetUI("boardInputField")
    local costTxt = _gt.GetUI("createCostTipsTxt")

    local globalConfig = DB.Get_global(1)

    GUI.EditSetTextM(nameInputField, "")
    GUI.EditSetTextM(boardInputField, "")
    if globalConfig ~= nil then
        GUI.StaticSetText(costTxt, tostring(globalConfig.CreateGuildGold))
        local selfBindGold = CL.GetIAttrEx(role_attr_ext.role_bind_gold)
        if tonumber(tostring(globalConfig.CreateGuildGold)) > tonumber(selfBindGold) then
            GUI.SetColor(costTxt, UIDefine.RedColor)
        else
            GUI.SetColor(costTxt, UIDefine.WhiteColor)
        end
    end
end

function FactionCreateUI.OnCloseBtnClick_CreateFactionPanel(guid)
    local createFactionPanel = _gt.GetUI("createFactionPanel")
    GUI.SetVisible(createFactionPanel, false)
end

function FactionCreateUI.OnConcelBtnClick_CreateFactionPanel(guid)
    local nameInputField = _gt.GetUI("nameInputField")
    local boardInputField = _gt.GetUI("boardInputField")
    if nameInputField and boardInputField then
        GUI.EditSetTextM(nameInputField, "")
        GUI.EditSetTextM(boardInputField, "")
    end
    local createFactionPanel = _gt.GetUI("createFactionPanel")
    GUI.SetVisible(createFactionPanel, false)
end

function FactionCreateUI.OnConfirmBtnClick_CreateFactionPanel(guid)
    local selfBindGold = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
    if selfBindGold < CREATE_FACTION_COST then
        CL.SendNotify(NOTIFY.ShowBBMsg, "银币不足，无法创建帮派")
        return
    end

    local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    local needLevel = tonumber(DB.GetGlobal(1).Guildestablishlvl)
    if roleLevel < needLevel then
        CL.SendNotify(NOTIFY.ShowBBMsg, "您的等级不足" .. tostring(needLevel) .. "级，无法创建帮派")
    else
        local nameInputField = _gt.GetUI("nameInputField")
        local boardInputField = _gt.GetUI("boardInputField")
        if nameInputField and boardInputField then
            local nameTxt = nameInputField.Text
            local boardTxt = boardInputField.Text
            if nameTxt ~= nil then
                if string.len(nameTxt) < 6 or string.len(nameTxt) > 15 then
                    CL.SendNotify(NOTIFY.ShowBBMsg, "帮派名称最少2个汉字，最多5个汉字")
                else
                    if CL.IsHaveForbiddenWord(nameTxt) then
                        CL.SendNotify(NOTIFY.ShowBBMsg, "帮派名称含有不合法字符，请重新输入")
                        return
                    end
                    if CL.IsHaveForbiddenWord(boardTxt) then
                        CL.SendNotify(NOTIFY.ShowBBMsg, "帮派宣言含有不合法字符，请重新输入")
                        return
                    end
                    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 23, nameTxt, boardTxt)
                end
            else
                CL.SendNotify(NOTIFY.ShowBBMsg, "帮派名称不能为空")
            end
        end
    end
end

--一键申请
function FactionCreateUI.OnApplyAllFactionBtnClick(guid)
    --[[
    local areaID = CL.GetIntGameData(GameDataType.LastAreaID)
    areaID = areaID ~= nil and areaID or 0
    local saveKey = ONEKEY_APPLY_LABEL..areaID.."_"..tostring(LD.GetSelfGUID())
    local savedPreTime = CL.GetUserOperateRecord(saveKey)
    local preTime = savedPreTime ~= nil and tonumber(savedPreTime) or 0
    local nowTime = LD.GetTickCount()
    local timeElapse = nowTime - preTime
    if timeElapse < ONEKEY_APPLY_TIME_INTERVAL then
        CL.SendNotify(NOTIFY.ShowBBMsg, "您已提交过一键申请，请"..math.ceil((ONEKEY_APPLY_TIME_INTERVAL - timeElapse)/60).."分钟后再试")
        return
    end
    --]]
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 26)
end
--联系帮主
function FactionCreateUI.OnConnectLeaderBtnClick(guid)
    if FactionCreateUI.lastSelectFactionLeaderGUID ~= 0 then
        if not LD.IsMyFriend(FactionCreateUI.lastSelectFactionLeaderGUID) then
            AddGuid = FactionCreateUI.lastSelectFactionLeaderGUID
            FactionCreateUI.OnExit()
            GlobalUtils.ShowBoxMsg2Btn("提示","该玩家还不是您的好友，是否要发送好友申请？","FactionCreateUI","确认","confirm","取消")
        else
            FactionCreateUI.OnExit()
            GUI.OpenWnd("FriendUI", tostring(FactionCreateUI.lastSelectFactionLeaderGUID))
        end
    end
end

function FactionCreateUI.OnApplyFactionBtnClick(guid)
    if FactionCreateUI.lastSelectFactionID ~= 0 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 24, tostring(FactionCreateUI.lastSelectFactionID))
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "请选择一个帮派")
    end
end

function FactionCreateUI.OnGetApplicationList(...)
    FactionCreateUI.OnRefreshCreateFactionUI(FactionCreateUI.PageNumber)
    if FactionCreateUI.lastSelectFactionItemElementGuid == nil or string.len(FactionCreateUI.lastSelectFactionItemElementGuid) == 0 then
        return
    end
    FactionCreateUI.OnFactionItemClick(FactionCreateUI.lastSelectFactionItemElementGuid)
end

function FactionCreateUI.OnDestroy()
    FactionCreateUI.lastSelectFactionID = 0
    FactionCreateUI.lastSelectFactionItemElementGuid = nil
    --CL.UnRegisterMessage(GM.GetFactionList,"MainUI","OnRecvFactionList")
end

function FactionCreateUI.OnCreateFactionBtnClick(guid)
    local createFactionPanel = _gt.GetUI("createFactionPanel")
    if createFactionPanel == nil then
        local panel = GUI.GetWnd("FactionCreateUI")
        createFactionPanel = GUI.ImageCreate(panel, "createFactionPanel", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        _gt.BindName(createFactionPanel, "createFactionPanel")
        UILayout.SetSameAnchorAndPivot(createFactionPanel, UILayout.Center)
        GUI.SetIsRaycastTarget(createFactionPanel, true)
        createFactionPanel:RegisterEvent(UCE.PointerClick)
        local createFactionBg = GUI.GroupCreate(createFactionPanel, "createFactionBg", -8, 6, 520, 426)
        local panelBg = GUI.ImageCreate(createFactionBg, "center", "1800600182", 0, 0, false, 520, 372)
        UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Bottom)

        local topBarLeft = GUI.ImageCreate(createFactionBg, "topBarLeft", "1800600180", 130, 28, false, 261, 54)
        UILayout.SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

        local topBarRight = GUI.ImageCreate(createFactionBg, "topBarRight", "1800600181", -130, 28, false, 260, 54)
        UILayout.SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

        local topBarCenter = GUI.ImageCreate(createFactionBg, "topBarCenter", "1800600190", -6, 27, false, 267, 50)
        UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

        local closeBtn = GUI.ButtonCreate(createFactionBg, "closeBtn", "1800302120", 0, 4, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionCreateUI", "OnCloseBtnClick_CreateFactionPanel")

        local tipLabel = GUI.CreateStatic(createFactionBg, "tipLabel", "帮派创建", -6, 27, 104, 45)
        GUI.StaticSetFontSize(tipLabel, UIDefine.FontSizeXL)
        GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
        GUI.SetColor(tipLabel, UIDefine.BrownColor)
        UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)

        local factionNameTips = GUI.CreateStatic(createFactionBg, "factionNameTips", "请输入帮派名称", 20, 65, 175, 32)
        UILayout.SetSameAnchorAndPivot(factionNameTips, UILayout.TopLeft)
        GUI.StaticSetFontSize(factionNameTips, UIDefine.FontSizeL)
        GUI.SetColor(factionNameTips, UIDefine.BrownColor)

        local nameInputField = GUI.EditCreate(createFactionBg, "nameInputField", "1800400200", "", 20, 95, Transition.ColorTint, "system", 470, 45, 10)
        _gt.BindName(nameInputField, "nameInputField")
        UILayout.SetSameAnchorAndPivot(nameInputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(nameInputField, TextAnchor.MiddleLeft)
        GUI.EditSetFontSize(nameInputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(nameInputField, UIDefine.BrownColor)
        --GUI.EditSetMaxCharNum(nameInputField, 10)

        local factionBoardTips = GUI.CreateStatic(createFactionBg, "factionBoardTips", "请输入帮派宣言", 20, 155, 175, 32)
        UILayout.SetSameAnchorAndPivot(factionBoardTips, UILayout.TopLeft)
        GUI.StaticSetFontSize(factionBoardTips, UIDefine.FontSizeL)
        GUI.SetColor(factionBoardTips, UIDefine.BrownColor)

        local boardInputField = GUI.EditCreate(createFactionBg, "boardInputField", "1800400200", "", 20, 185, Transition.ColorTint, "system", 470, 115, 10, 5)
        _gt.BindName(boardInputField, "boardInputField")
        UILayout.SetSameAnchorAndPivot(boardInputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(boardInputField, TextAnchor.UpperLeft)
        GUI.EditSetFontSize(boardInputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(boardInputField, UIDefine.BrownColor)
        GUI.EditSetMultiLineEdit(boardInputField, LineType.MultiLineSubmit)
        GUI.EditSetMaxCharNum(boardInputField, 100)

        local createCostTips = GUI.CreateStatic(createFactionBg, "createCostTips", "创建费用", 20, -90, 97, 30)
        UILayout.SetSameAnchorAndPivot(createCostTips, UILayout.BottomLeft)
        GUI.StaticSetFontSize(createCostTips, UIDefine.FontSizeL)
        GUI.SetColor(createCostTips, UIDefine.BrownColor)
        local costBg = GUI.ImageCreate(createCostTips, "costBg", "1800700010", 107, 0, false, 190, 33)
        UILayout.SetSameAnchorAndPivot(costBg, UILayout.Left)
        local costIcon = GUI.ImageCreate(costBg, "costIcon", "1800408280", 0, -1, false, 33, 33)
        UILayout.SetSameAnchorAndPivot(costIcon, UILayout.Left)
        local txt = GUI.CreateStatic(costBg, "txt", tostring(CREATE_FACTION_COST), 28, 0, 155, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
        GUI.SetColor(txt, UIDefine.WhiteColor)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

        local concelBtn = GUI.ButtonCreate(createFactionBg, "concelBtn", "1800602030", 20, -22, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(concelBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(concelBtn, "btnTxt", "取消", 0, 0, 52, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeXL)
        GUI.SetColor(btnTxt, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "FactionCreateUI", "OnCloseBtnClick_CreateFactionPanel")

        local confirmBtn = GUI.ButtonCreate(createFactionBg, "confirmBtn", "1800602030", -20, -22, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(confirmBtn, "btnTxt", "创建帮派", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeXL)
        GUI.SetColor(btnTxt, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "FactionCreateUI", "OnConfirmBtnClick_CreateFactionPanel")
    else
        GUI.SetVisible(createFactionPanel, true)
    end
    --FactionCreateUI.RefreshCreateFactionPanel( )
end

function FactionCreateUI.OnCloseBtnClick_CreateFactionPanel(guid)
    local nameInputField = _gt.GetUI("nameInputField")
    if nameInputField then
        GUI.EditSetTextM(nameInputField, "")
    end
    local boardInputField = _gt.GetUI("boardInputField")
    if boardInputField then
        GUI.EditSetTextM(boardInputField, "")
    end
    local createFactionPanel = _gt.GetUI("createFactionPanel")
    GUI.SetVisible(createFactionPanel, false)
end
--确认添加帮主为好友
function FactionCreateUI.confirm()
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyFriend", AddGuid)
    CL.SendNotify(NOTIFY.ShowBBMsg, "好友请求已发送")
end

