local SealedBookUI = {
    ServerData = {
        ---@type table<string,SealedBookChapter>
        Config = nil,
        Chapter = 0,
        Mission = 0
    },
    IsAutoReChallenge=false,
    IsInFighting=false
}
_G.SealedBookUI = SealedBookUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
--local inspect = require("inspect")   --TODO 测试用，之后需要注释掉

------------------------------------ end缓存一下全局变量end --------------------------------
local guidt = UILayout.NewGUIDUtilTable()
--local test = function()
--end
function SealedBookUI.InitData()
    return {
        ---@type table<string,SealedBookChapter>
        cfg = {},
        --当前章节
        curIndex = 0,
        --当前解锁章节
        curMxaIndex = 0,
        --当前章节选中怪物
        curMonsterIndex = 0,
        --最大章节
        maxIndex = 0,
        --上次章节
        lastIndex=0,
        --上次章节选中的怪物
        lastMonsterIndex=0,
        --当前选择的怪物是否是最新解锁的
        theCurSelectedMonsterIsTheLatest=true,
        --是否自动
        isAuto=false
    }
end
local DefClickRate = 1.1 --被选中按钮放大比例
local DefMonsterNum = 5
local data = SealedBookUI.InitData()
function SealedBookUI.OnExitGame()
    data = SealedBookUI.InitData()
    SealedBookUI.ServerData.Config = nil
end
function SealedBookUI.OnExit()
    guidt = nil
    data.lastIndex=0
    data.lastMonsterIndex=0
    if data.isAuto then
        CL.SendNotify(NOTIFY.SubmitForm, "FormWordlessBook", "CloseAuto")
        SealedBookUI.IsAutoReChallenge=false
        SealedBookUI.ServerData.IsAuto=false
    end
    GUI.DestroyWnd("SealedBookUI")
end
function SealedBookUI.Main(parameter)
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("SealedBookUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("SealedBookUI", "SealedBookUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "无字真经", "SealedBookUI", "OnExit")
    guidt.BindName(panelBg, "panelBg")

    --标题
    local title = GUI.CreateStatic(panelBg, "Title", "第   卷    章节名称", 0, 47, 270, 50)
    guidt.BindName(title, "title")
    GUI.StaticSetFontSize(title, UIDefine.FontSizeXL)
    GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(title, UILayout.Top)
    local tipColor = nil
    GUI.SetColor(title, UIDefine.BrownColor)

    local TitleImageLeft = GUI.ImageCreate(title, "TitleImageLeft", "1800800050", 0, 0)
    SetAnchorAndPivot(TitleImageLeft, UIAnchor.Left, UIAroundPivot.Right)

    local TitleImageRight = GUI.ImageCreate(title, "TitleImageRight", "1800800060", 0, 0)
    SetAnchorAndPivot(TitleImageRight, UIAnchor.Right, UIAroundPivot.Left)

    local helpBtn = GUI.ButtonCreate(panelBg, "helpBtn", "1800702030", -110, 62, Transition.ColorTint);
    UILayout.SetSameAnchorAndPivot(helpBtn, UILayout.TopRight);
    GUI.RegisterUIEvent(helpBtn, UCE.PointerClick, "SealedBookUI", "OnHelpBtnClick");

    --关卡栏
    local stage_bg = GUI.ImageCreate(panelBg, "stage_bg", "1800400010", 0, 110, false, 1006, 297)
    UILayout.SetSameAnchorAndPivot(stage_bg, UILayout.Top)
    guidt.BindName(stage_bg, "stage_bg")

    --每个关卡x轴差值
    local x0 = 193
    local art_number = {"1800605140", "1800605150", "1800605160", "1800605170", "1800605180"}
    local w = 0
    local h = 0
    local x = 0
    local y = 0

    for i = 1, 5 do
        local stage_bg_child =
            GUI.ButtonCreate(
            stage_bg,
            "stage_bg_child_" .. i,
            "1800601020",
            (i - 3) * x0,
            0,
            Transition.ColorTint,
            "",
            160,
            245,
            false
        )
        UILayout.SetSameAnchorAndPivot(stage_bg_child, UILayout.Center)
        GUI.ButtonSetIndex(stage_bg_child, i)
        GUI.RegisterUIEvent(stage_bg_child, UCE.PointerClick, "SealedBookUI", "btnOption_OnClick")

        local shadow = GUI.ImageCreate(stage_bg_child, "shadow", "1800608320", 0, 50, true, 0, 0)
        SetAnchorAndPivot(shadow, UIAnchor.Center, UIAroundPivot.Top)
    end

    --模型父节点
    local model = GUI.RawImageCreate(stage_bg, true, "model", "", 0, 0, 4, false, 1200, 1200)
    guidt.BindName(model, "model")
    UILayout.SetSameAnchorAndPivot(model, UILayout.Center)
    GUI.AddToCamera(model)
    GUI.SetIsRaycastTarget(model, false)
    GUI.RawImageSetCameraConfig(
        model,
        "(0,1.53,2.56),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,4.79,0.01,5.5,37"
    )

    for i = 1, DefMonsterNum do
        -- local stage_bg_i = GUI.ImageCreate(stage_bg, "stage_bg_" .. i, "", (i - 3) * x0, 0)
        local stage_bg_i = GUI.GroupCreate(stage_bg, "stage_bg_" .. i,(i - 3) * x0, 0)
        UILayout.SetSameAnchorAndPivot(stage_bg_i, UILayout.Center)

        local stage_ser = GUI.ImageCreate(stage_bg_i, "stage_ser", "1800602140", -63, -89, false, 45, 45)
        UILayout.SetSameAnchorAndPivot(stage_ser, UILayout.Center)

        local stage_number = GUI.ImageCreate(stage_ser, "stage_number", art_number[i], -1, 2, true, 0, 0)
        UILayout.SetSameAnchorAndPivot(stage_number, UILayout.Center)

        local stage_name = GUI.CreateStatic(stage_bg_i, "stage_name", "关卡名称", 6, -88, 120, 40, "system", true, false)
        GUI.StaticSetFontSize(stage_name, UIDefine.FontSizeS)
        GUI.StaticSetAlignment(stage_name, TextAnchor.MiddleCenter)
        UILayout.SetSameAnchorAndPivot(stage_name, UILayout.Center)
        tipColor = UIDefine.WhiteColor
        GUI.SetColor(stage_name, tipColor)

        tipColor = UIDefine.BrownColor
        GUI.SetIsOutLine(stage_name, true)
        GUI.SetOutLine_Color(stage_name, tipColor)
        GUI.SetOutLine_Distance(stage_name, 1)

        local unknow = GUI.ImageCreate(stage_bg_i, "unknow", 1800608310, 0, 0, true, 0, 0)
        UILayout.SetSameAnchorAndPivot(unknow, UILayout.Center)
        GUI.SetVisible(unknow, true)

        local over_image = GUI.ImageCreate(stage_bg_i, "over_image", 1800608300, 0, 70, true, 0, 0)
        UILayout.SetSameAnchorAndPivot(over_image, UILayout.Center)
        GUI.SetVisible(over_image, false)

        local monster = GUI.RawImageChildCreate(model, true, "monster"..i, "", 0, 0)
        UILayout.SetSameAnchorAndPivot(monster, UILayout.TopLeft)
        GUI.SetIsRaycastTarget(monster, false)
        -- GUI.SetData(monster, "Index", i)
        -- GUI.RegisterUIEvent(monster, ULE.CreateFinsh, "SealedBookUI", "OnCreateModel")
    end

    local next_page_btn = GUI.ButtonCreate(stage_bg, "next_page_btn", "1800602120", 0, 0, Transition.ColorTint)
    SetAnchorAndPivot(next_page_btn, UIAnchor.Right, UIAroundPivot.Center)
    GUI.RegisterUIEvent(next_page_btn, UCE.PointerClick, "SealedBookUI", "NextPage_OnClick")
    guidt.BindName(next_page_btn, "next_page_btn")

    local pre_page_btn = GUI.ButtonCreate(stage_bg, "pre_page_btn", "1800602190", 0, 0, Transition.ColorTint)
    SetAnchorAndPivot(pre_page_btn, UIAnchor.Left, UIAroundPivot.Center)
    GUI.RegisterUIEvent(pre_page_btn, UCE.PointerClick, "SealedBookUI", "PreviousPage_OnClick")
    guidt.BindName(pre_page_btn, "pre_page_btn")

    local rec_title = GUI.CreateStatic(panelBg, "rec_title", "推荐等级:", 97, 412, 102, 30, "system", true, false)
    GUI.StaticSetFontSize(rec_title, 22)
    GUI.StaticSetAlignment(rec_title, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(rec_title, UILayout.TopLeft)
    tipColor = UIDefine.Brown5Color
    GUI.SetColor(rec_title, tipColor)

    local rec_text = GUI.CreateStatic(rec_title, "rec_text", "暂无", 0, 0, 102, 30, "system", true, false)
    GUI.StaticSetFontSize(rec_text, 22)
    GUI.StaticSetAlignment(rec_text, TextAnchor.MiddleLeft)
    SetAnchorAndPivot(rec_text, UIAnchor.Right, UIAroundPivot.Left)
    tipColor = UIDefine.Yellow2Color
    GUI.SetColor(rec_text, tipColor)
    guidt.BindName(rec_text, "rec_text")

    local desc_title = GUI.CreateStatic(panelBg, "desc_title", "剧情描述:", 477, 412, 102, 30, "system", true, false)
    GUI.StaticSetFontSize(desc_title, 22)
    GUI.StaticSetAlignment(desc_title, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(desc_title, UILayout.TopLeft)
    tipColor = UIDefine.Brown5Color
    GUI.SetColor(desc_title, tipColor)

    local desc_text = GUI.CreateStatic(desc_title, "desc_text", "", 2, 2, 528, 60, "system", true, false)
    GUI.StaticSetFontSize(desc_text, 22)
    GUI.StaticSetAlignment(desc_text, TextAnchor.UpperLeft)
    SetAnchorAndPivot(desc_text, UIAnchor.TopRight, UIAroundPivot.TopLeft)
    tipColor = UIDefine.Yellow2Color
    GUI.SetColor(desc_text, tipColor)
    GUI.StaticSetText(desc_text, "")
    guidt.BindName(desc_text, "desc_text")

    local item_text = GUI.CreateStatic(panelBg, "item_text", "首通奖励:", 97, 474, 150, 30, "system", true, false)
    GUI.StaticSetFontSize(item_text, 22)
    GUI.StaticSetAlignment(item_text, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(item_text, UILayout.TopLeft)
    tipColor = UIDefine.Brown5Color
    GUI.SetColor(item_text, tipColor)
    guidt.BindName(item_text, "item_text")

    local rareBattleReward_text = GUI.CreateStatic(panelBg, "rareBattleReward_text", "稀有战斗奖励:", 477, 474, 150, 30, "system", true, false)
    GUI.StaticSetFontSize(rareBattleReward_text, 22)
    GUI.StaticSetAlignment(rareBattleReward_text, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(rareBattleReward_text, UILayout.TopLeft)
    GUI.SetColor(rareBattleReward_text, tipColor)
    GUI.SetVisible(rareBattleReward_text,false)
    guidt.BindName(rareBattleReward_text, "rareBattleReward_text")

    local autoReChallenge_checkbox = GUI.CheckBoxCreate (panelBg,"autoReChallenge_checkbox", "1800607150", "1800607151", 896, 488,Transition.ColorTint, false)
    UILayout.SetSameAnchorAndPivot(autoReChallenge_checkbox, UILayout.TopLeft)
    GUI.CheckBoxSetCheck(autoReChallenge_checkbox, SealedBookUI.IsAutoReChallenge)
    GUI.RegisterUIEvent(autoReChallenge_checkbox , UCE.PointerClick , "SealedBookUI", "OnIsAutoReChallengeCheck" )
    guidt.BindName(autoReChallenge_checkbox, "autoReChallenge_checkbox")

    local autoReChallenge_checkbox_text= GUI.CreateStatic( autoReChallenge_checkbox,"autoReChallenge_checkbox_text", " 自动重复战斗", 35, 0, 200, 50)
    UILayout.SetSameAnchorAndPivot(autoReChallenge_checkbox_text, UILayout.Left)
    GUI.StaticSetFontSize(autoReChallenge_checkbox_text, 23)
    GUI.SetColor(autoReChallenge_checkbox_text, UIDefine.Brown4Color)

    local battle_btn = GUI.ButtonCreate(panelBg, "battle_btn", "1800602130", 876, 529, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(battle_btn, UILayout.TopLeft)
    GUI.RegisterUIEvent(battle_btn, UCE.PointerClick, "SealedBookUI", "OnClickBattle")

    local battle_btn_text = GUI.CreateStatic(battle_btn, "battle_btn_text", "出  战", 0, 0, 232, 75, "system", true, false)
    GUI.StaticSetFontSize(battle_btn_text, 34)
    GUI.StaticSetAlignment(battle_btn_text, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(battle_btn_text, UILayout.Center)
    tipColor = UIDefine.WhiteColor
    GUI.SetColor(battle_btn_text, tipColor)

    tipColor = UIDefine.BrownColor
    GUI.SetIsOutLine(battle_btn_text, true)
    GUI.SetOutLine_Color(battle_btn_text, tipColor)
    GUI.SetOutLine_Distance(battle_btn_text, 1)

    --首通奖励以及重复战斗奖励
    local src =
        GUI.LoopScrollRectCreate(
        panelBg,
        "src",
        97,
        220,
        300,
        100,
        "SealedBookUI",
        "CreateItem",
        "SealedBookUI",
        "RefreshItem",
        0,
        true,
        UIDefine.Vector2One * 81,
        1,
        UIAroundPivot.Left,
        UIAnchor.Left,
        false
    )
    GUI.ScrollRectSetChildSpacing(src, UIDefine.Vector2One * 5)
    UILayout.SetSameAnchorAndPivot(src, UILayout.Left)
    guidt.BindName(src, "src")


    --稀有战斗奖励
    local src_rareBattleReward =
    GUI.LoopScrollRectCreate(
            panelBg,
            "src_rareBattleReward",
            477,
            220,
            300,
            100,
            "SealedBookUI",
            "CreateRareBattleRewardItem",
            "SealedBookUI",
            "RefreshRareBattleRewardItem",
            0,
            true,
            UIDefine.Vector2One * 81,
            1,
            UIAroundPivot.Left,
            UIAnchor.Left,
            false
    )
    GUI.ScrollRectSetChildSpacing(src_rareBattleReward, UIDefine.Vector2One * 5)
    UILayout.SetSameAnchorAndPivot(src_rareBattleReward, UILayout.Left)
    guidt.BindName(src_rareBattleReward, "src_rareBattleReward")
    GUI.SetVisible(src_rareBattleReward,false)
    CL.RegisterMessage(GM.FightStateNtf, "SealedBookUI", "OnFightStateNtf");
end
function SealedBookUI.OnFightStateNtf(isEnter,isOver)
    if isEnter then
        SealedBookUI.IsInFighting=true
        GUI.DestroyWnd("SealedBookUI")
    else
        SealedBookUI.IsInFighting=false
    end
end
function SealedBookUI.CreateItem()
    local scroll = guidt.GetUI("src")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = ItemIcon.Create(scroll, curCount, 0, 0)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "SealedBookUI", "OnItemClick")
    return item
end

function SealedBookUI.RefreshItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    ---@type SealedBookMission[]
    local tmp = SealedBookUI.GetMission()
    local info=tmp.Reward.items[index]
    if  tmp.over then
        info = tmp.Over_Reward.items[index]
    end
    ItemIcon.BindItemId(item, info.id)
    GUI.SetData(item, "ItemId", tostring(info.id))
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, UIDefine.ExchangeMoneyToStr(info.count))
end

function SealedBookUI.CreateRareBattleRewardItem()
    local scroll = guidt.GetUI("src_rareBattleReward")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = ItemIcon.Create(scroll, curCount, 0, 0)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "SealedBookUI", "OnItemClick")
    return item
end

function SealedBookUI.RefreshRareBattleRewardItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    ---@type SealedBookMission[]
    local tmp = SealedBookUI.GetMission()
    local info = tmp.Rare_Reward[index]
    if info.Item then
        ItemIcon.BindItemKeyName(item, info.Item)
        GUI.SetData(item, "KeyName", tostring(info.Item))
        -- test("info.Item : "..tostring(info.Item))
    elseif info.Pet then
        ItemIcon.BindPetKeyName(item, info.Pet)
        GUI.SetData(item, "KeyName", tostring(info.Pet))
    end

    --GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, UIDefine.ExchangeMoneyToStr(info.count))
end


function SealedBookUI.OnShow(parameter)
    test("Onshow")
    local wnd = GUI.GetWnd("SealedBookUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
    data.curIndex = 1
    data.curMonsterIndex = 1
    SealedBookUI.GetDate()
end
function SealedBookUI.OnDestroy()
    SealedBookUI.OnClose()
end
function SealedBookUI.OnClose()

    local wnd = GUI.GetWnd("SealedBookUI")
    GUI.SetVisible(wnd, false)
end
function SealedBookUI.GetDate()
    if SealedBookUI.ServerData.Config == nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormWordlessBook", "GetConfig")
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormWordlessBook", "GetData")
    end

end
function SealedBookUI.Refresh()
    if SealedBookUI.ServerData.Config then
        data.cfg = LuaTool.DupTable(SealedBookUI.ServerData.Config)
        for key, value in pairs(data.cfg) do
            ---@type SealedBookMission[]
            local tmp = {value.Mission_1, value.Mission_2, value.Mission_3, value.Mission_4, value.Mission_5}
            for i = 1, #tmp do
                tmp[i].Reward.items = LogicDefine.SeverReward2ClientItems(tmp[i].Reward)
                tmp[i].Over_Reward.items=LogicDefine.SeverReward2ClientItems(tmp[i].Over_Reward)
            end
        end
    end
    SealedBookUI.ClientRefresh()
end
function SealedBookUI.PlayerDataRefresh()
    test("PlayerDataRefresh")
    SealedBookUI.ClientRefresh()
end
function SealedBookUI.SetCurMonsterIndex(index)
    data.curMonsterIndex = index or SealedBookUI.GetCfg().cur
    if data.curMonsterIndex < 1 or data.curMonsterIndex > DefMonsterNum then
        data.curMonsterIndex = 1
    end
    local cfg = SealedBookUI.GetCfg()
    if data.curMonsterIndex < 1 or data.curMonsterIndex > cfg.cur then
        data.curMonsterIndex = 1
    end
end
function SealedBookUI.SetCurIndex(index)
    data.curIndex = index or data.curMxaIndex
    if data.curIndex < 1 or data.curIndex > data.maxIndex then
        data.curIndex = 1
    end
    if data.curIndex > data.curMxaIndex then
        data.curIndex = data.curMxaIndex
    end
end
function SealedBookUI.ClientRefresh()
    test("ClientRefresh")
    data.maxIndex = 0
    local tmp = data.maxIndex + 1
    while SealedBookUI.GetCfg(tmp) do
        tmp = tmp + 1
    end
    data.maxIndex = tmp - 1
    local isOver = true
    for i = 1, data.maxIndex do
        if isOver then
            data.curMxaIndex = i
        end
        local value = SealedBookUI.GetCfg(i)
        value.cur = 1
        ---@type SealedBookMission[]
        local tmp = {value.Mission_1, value.Mission_2, value.Mission_3, value.Mission_4, value.Mission_5}
        for j = 1, #tmp do
            tmp[j].over =
                (i < SealedBookUI.ServerData.Chapter) or
                (i == SealedBookUI.ServerData.Chapter and j <= SealedBookUI.ServerData.Mission)
            if tmp[j].over then
                value.cur = math.min(j + 1, DefMonsterNum)
            else
                isOver = false
            end
        end
    end
    if tonumber(SealedBookUI.ServerData.IsAuto) and tonumber(SealedBookUI.ServerData.IsAuto)==1 then
        data.isAuto=true
    else
        data.isAuto=false
    end

    if SealedBookUI.IsAutoReChallenge then
        SealedBookUI.SetCurIndex( data.lastIndex~=0 and data.lastIndex or nil )
        SealedBookUI.SetCurMonsterIndex( data.lastMonsterIndex~=0 and data.lastMonsterIndex or nil )
    else
        if data.theCurSelectedMonsterIsTheLatest then
            SealedBookUI.SetCurIndex()
            SealedBookUI.SetCurMonsterIndex()
        else
            SealedBookUI.SetCurIndex( data.lastIndex~=0 and data.lastIndex or nil )
            SealedBookUI.SetCurMonsterIndex( data.lastMonsterIndex~=0 and data.lastMonsterIndex or nil )
        end
    end

    --SealedBookUI.SetCurIndex()
    --SealedBookUI.SetCurMonsterIndex()
    SealedBookUI.RefreshUI()
end
function SealedBookUI.RefreshUI()
    test("RefreshUI")
    local wnd = GUI.GetWnd("SealedBookUI")
    if wnd == nil or GUI.GetVisible(wnd) == false then
        return
    end
    local cfg = SealedBookUI.GetCfg()
    local model = guidt.GetUI("model")
    local stage_bg = guidt.GetUI("stage_bg")
    local modelChild = {}
    local unknow = {}
    local stage_name = {}
    local stage_bg_child = {}
    local over_image = {}
    local stage_child = {}
    for i = 1, DefMonsterNum do
        modelChild[i] = GUI.GetChild(model, "monster"..i, false)
        stage_bg_child[i] = GUI.GetChild(stage_bg, "stage_bg_" .. i, false)
        stage_child[i] = GUI.GetChild(stage_bg, "stage_bg_child_" .. i, false)
        unknow[i] = GUI.GetChild(stage_bg_child[i], "unknow", false)
        stage_name[i] = GUI.GetChild(stage_bg_child[i], "stage_name", false)
        over_image[i] = GUI.GetChild(stage_bg_child[i], "over_image", false)
    end
    --页面标题
    local title = guidt.GetUI("title")
    GUI.StaticSetText(title, "第" .. data.curIndex .. "卷   " .. cfg.Chapter_Setting.Name)
    local cfg = SealedBookUI.GetCfg()
    ---@type SealedBookMission[]
    local missions = {cfg.Mission_1, cfg.Mission_2, cfg.Mission_3, cfg.Mission_4, cfg.Mission_5}
    for i = 1, DefMonsterNum do
        if missions[i] then
            GUI.SetVisible(model, true)
            GUI.SetVisible(stage_bg, true)
            GUI.SetVisible(over_image[i], missions[i].over)
            --GUI.RawImageChildSetModelID(modelChild[i], tonumber(missions[i].MonId))
            if i > cfg.cur then
                GUI.SetVisible(modelChild[i], false)
                GUI.StaticSetText(stage_name[i], "????")
                GUI.SetVisible(unknow[i], true)
                GUI.ButtonSetShowDisable(stage_child[i], false)
            else
                GUI.SetVisible(modelChild[i], true)
                --GUI.ReplaceWeapon(modelChild[i], 0, eRoleMovement.STAND_W1, 0, tonumber(missions[i].MonId), 0, 0, 0)
                ModelItem.Bind(modelChild[i], tonumber(missions[i].MonId), nil, nil, eRoleMovement.STAND_W1)
                GUI.SetLocalPosition(modelChild[i], 5.25 - 1.755 * i, 0, 0)
                GUI.SetVisible(unknow[i], false)
                GUI.ButtonSetShowDisable(stage_child[i], true)
                GUI.StaticSetText(stage_name[i], missions[i].MonName)
                --if i == cfg.cur then
                --end
            end

            if i == data.curMonsterIndex then
                if missions[i].MonId and missions[i].MonId > 0 and i <= cfg.cur then
                    GUI.RawImageChildSetAvatarModelScale(modelChild[i], DefClickRate * missions[i].Scale / 10000)
                end
                GUI.SetScale(stage_child[i], UIDefine.Vector3One * DefClickRate)
                GUI.SetScale(stage_bg_child[i], UIDefine.Vector3One * DefClickRate)
            else
                if missions[i].MonId and missions[i].MonId > 0 and i <= cfg.cur then
                    GUI.RawImageChildSetAvatarModelScale(modelChild[i], 1 * missions[i].Scale / 10000)
                end
                GUI.SetScale(stage_child[i], UIDefine.Vector3One)
                GUI.SetScale(stage_bg_child[i], UIDefine.Vector3One)
            end
        else
            GUI.SetVisible(model, false)
            GUI.SetVisible(stage_bg, false)
        end
    end
    local rec_text = guidt.GetUI("rec_text")
    local tmptxt = ""
    if cfg.Chapter_Setting.Rein and cfg.Chapter_Setting.Rein > 0 then
        tmptxt = cfg.Chapter_Setting.Rein .. "转"
    end
    tmptxt = tmptxt .. cfg.Chapter_Setting.Level .. "级"
    GUI.StaticSetText(rec_text, tmptxt)

    local desc_text = guidt.GetUI("desc_text")
    GUI.StaticSetText(desc_text, cfg["Mission_" .. data.curMonsterIndex].Info)
    local pre_page_btn = guidt.GetUI("pre_page_btn")
    if data.curIndex == 1 then
        GUI.ButtonSetShowDisable(pre_page_btn, false)
    else
        GUI.ButtonSetShowDisable(pre_page_btn, true)
    end
    local next_page_btn = guidt.GetUI("next_page_btn")
    if data.curIndex == data.curMxaIndex then
        GUI.ButtonSetShowDisable(next_page_btn, false)
    else
        GUI.ButtonSetShowDisable(next_page_btn, true)
    end

    local src = guidt.GetUI("src")
    local item_text=guidt.GetUI("item_text")
    local rareBattleReward_text= guidt.GetUI("rareBattleReward_text")
    local src_rareBattleReward= guidt.GetUI("src_rareBattleReward")
    
    if SealedBookUI.GetMission().over == true then
        GUI.StaticSetText(item_text,"重复战斗奖励:")
        GUI.SetWidth(src, 300)
        GUI.SetVisible(rareBattleReward_text, #missions[data.curMonsterIndex].Rare_Reward ~= 0)
        GUI.SetVisible(src_rareBattleReward,true)
        GUI.SetVisible(item_text,  #missions[data.curMonsterIndex].Over_Reward.items ~= 0)
        GUI.LoopScrollRectSetTotalCount(src, #missions[data.curMonsterIndex].Over_Reward.items)
        GUI.LoopScrollRectRefreshCells(src)
    else
        GUI.StaticSetText(item_text,"首通奖励:")
        GUI.SetWidth(src, 700)
        GUI.SetVisible(rareBattleReward_text,false)
        GUI.SetVisible(src_rareBattleReward,false)
        GUI.SetVisible(item_text, #missions[data.curMonsterIndex].Reward.items ~= 0)
        GUI.LoopScrollRectSetTotalCount(src, #missions[data.curMonsterIndex].Reward.items)
        GUI.LoopScrollRectRefreshCells(src)
    end

    if missions[data.curMonsterIndex].Rare_Reward then
        GUI.LoopScrollRectSetTotalCount(src_rareBattleReward, #missions[data.curMonsterIndex].Rare_Reward)
    else
        GUI.LoopScrollRectSetTotalCount(src_rareBattleReward, 0)
    end
    GUI.LoopScrollRectRefreshCells(src_rareBattleReward)
end

function SealedBookUI.PreviousPage_OnClick()
    local cfg = SealedBookUI.GetCfg()
    SealedBookUI.ChangeAutoCheckBox()
    if data.curIndex == 1 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "已经是第一章")
    else
        SealedBookUI.SetCurIndex(data.curIndex - 1)
        SealedBookUI.SetCurMonsterIndex()
        SealedBookUI.RefreshUI()
    end
end

function SealedBookUI.NextPage_OnClick()
    local cfg = SealedBookUI.GetCfg()
    SealedBookUI.ChangeAutoCheckBox()
    if cfg == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "已经是最后一章")
    elseif data.curIndex == data.curMxaIndex then
        CL.SendNotify(NOTIFY.ShowBBMsg, "需要通关当前章节才能进入下一章")
    else
        SealedBookUI.SetCurIndex(data.curIndex + 1)
        SealedBookUI.SetCurMonsterIndex()
        SealedBookUI.RefreshUI()
    end
end
---@return SealedBookChapter
function SealedBookUI.GetCfg(index)
    index = index or data.curIndex
    return data.cfg["Chapter_" .. index]
end
---@return SealedBookMission
function SealedBookUI.GetMission(index, mIndex)
    local cfg = SealedBookUI.GetCfg(index)
    mIndex = mIndex or data.curMonsterIndex
    ---@type SealedBookMission[]
    local tmp = {cfg.Mission_1, cfg.Mission_2, cfg.Mission_3, cfg.Mission_4, cfg.Mission_5}
    return tmp[mIndex]
end
function SealedBookUI.OnItemClick(guid)
    local panelBg = guidt.GetUI("panelBg")
    local item_bg = GUI.GetByGuid(guid)
    local itemId = tonumber(GUI.GetData(item_bg, "ItemId"))
    local KeyName = tostring(GUI.GetData(item_bg,"KeyName"))

    local item=DB.GetOnceItemByKey2(KeyName)
    local pet=DB.GetOncePetByKey2(KeyName)
    if itemId and itemId > 0 then
        Tips.CreateByItemId(itemId, panelBg, "tipsleft", 0, 111, 50)
    elseif KeyName and KeyName~="" then
        if item.Id~=0 and  pet.Id==0 then
            Tips.CreateByItemKeyName(KeyName, panelBg, "tipsleft", -320, 111, 50)
        elseif pet.Id~=0 then
            CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "QueryPetByKeyName", pet.KeyName)
        end
        --Tips.CreatePetTip(KeyName, panelBg, "tipsleft", -320, 111, 50)
    end
end
-- function SealedBookUI.OnCreateModel(guid)
--     local monster = GUI.GetByGuid(guid)
--     local index = tonumber(GUI.GetData(monster, "Index"))
-- end
function SealedBookUI.btnOption_OnClick(guid)
    test("btnOption_OnClick")

    local tmp = GUI.GetByGuid(guid)
    SealedBookUI.beforeBattleOrClickMonster(data.curIndex, data.curMonsterIndex)
    SealedBookUI.SetCurMonsterIndex(GUI.ButtonGetIndex(tmp))

    if data.curIndex~=data.lastIndex or data.curMonsterIndex~=data.lastMonsterIndex then
        SealedBookUI.ChangeAutoCheckBox()
    end
    data.theCurSelectedMonsterIsTheLatest=false
    if SealedBookUI.GetMission().over == false then
        data.theCurSelectedMonsterIsTheLatest=true
    end
    SealedBookUI.RefreshUI()
end
function SealedBookUI.ChangeAutoCheckBox()

    local autoReChallenge_checkbox=guidt.GetUI("autoReChallenge_checkbox")
    if data.isAuto then
        CL.SendNotify(NOTIFY.SubmitForm, "FormWordlessBook", "CloseAuto")
        SealedBookUI.IsAutoReChallenge=false
        data.isAuto=false
        GUI.CheckBoxSetCheck(autoReChallenge_checkbox,SealedBookUI.IsAutoReChallenge)
    end
end

function SealedBookUI.OnClickBattle(guid)
    if SealedBookUI.GetMission().over == false then
        SealedBookUI.beforeBattleOrClickMonster()
        data.theCurSelectedMonsterIsTheLatest=true
        SealedBookUI.Battle()
        SealedBookUI.OnExit()
    else
        GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", "你已获得该关卡奖励，是否要重复挑战？", "SealedBookUI", "确定", "OnReChallenge", "取消")
    end
end
function SealedBookUI.OnReChallenge()
    local isReChallengeFlag=0
    if SealedBookUI.IsAutoReChallenge then
        isReChallengeFlag=1
    end
    SealedBookUI.OnExit()
    SealedBookUI.beforeBattleOrClickMonster()
    --data.isAuto=true
    SealedBookUI.Battle()
end

function SealedBookUI.Battle()
    local battleFlag=0
    if SealedBookUI.IsAutoReChallenge then
        battleFlag=1
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormWordlessBook", "StartFight", data.curIndex, data.curMonsterIndex,battleFlag)
end

function SealedBookUI.beforeBattleOrClickMonster()
    data.lastIndex=data.curIndex or 0
    data.lastMonsterIndex= data.curMonsterIndex or 0
end

function SealedBookUI.OnHelpBtnClick()
    local panelBg = guidt.GetUI("panelBg");
    local diffText="不消耗活力。"
    if tonumber(SealedBookUI.ServerData.OverConsume)~=0 then
        diffText="消耗"..tonumber(SealedBookUI.ServerData.OverConsume).."点活力。"
    end
    Tips.CreateHint("1.首次通关每个关卡可获得丰厚的经验和金钱奖励。\n2.重复通关可反复获得奖励，并有几率获得稀有奖励。\n3.重复通关已通过的关卡，将"..diffText, panelBg,200,110,UILayout.Top,450)
end

function SealedBookUI.OnIsAutoReChallengeCheck()
    test("OnIsAutoReChallengeCheck")
    SealedBookUI.IsAutoReChallenge=not SealedBookUI.IsAutoReChallenge
    if SealedBookUI.IsAutoReChallenge then
        test("开启自动")
    else
        test("结束自动")
        CL.SendNotify(NOTIFY.SubmitForm, "FormWordlessBook", "CloseAuto")
        data.isAuto=false
    end
end