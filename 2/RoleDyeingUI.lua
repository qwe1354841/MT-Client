RoleDyeingUI = {}
--local test = print
local colorDark = UIDefine.Brown4Color
local colorRed = UIDefine.RedColor
local colorWhite = UIDefine.WhiteColor
local colorOutline = UIDefine.BrownColor

local sizeTitle = UIDefine.FontSizeL
local guidt = UILayout.NewGUIDUtilTable()
function RoleDyeingUI.Main(parameter)
    -- table init
    guidt = UILayout.NewGUIDUtilTable()
    -- 属性刷新定时器
    RoleDyeingUI.reset = nil
    RoleDyeingUI.DataPart = {}
    ---@type dynColorInfo[]
    RoleDyeingUI.DataPart.AllColorCfg = {}
    ---@type dynColorInfo[]
    RoleDyeingUI.DataPart.AllClolorCgf2 = {}

    --ui part init
    local panel = GUI.WndCreateWnd("RoleDyeingUI", "RoleDyeingUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)

    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "人物染色", "RoleDyeingUI", "OnExit")
    local pendant = GUI.ImageCreate(panelBg, "pendant", "1800408080", -559, -190)
    GUI.SetAnchor(pendant, UIAnchor.Center)
    GUI.SetPivot(pendant, UIAroundPivot.Center)

    local listBg = GUI.ImageCreate(panelBg, "listBg", "1800400200", 230, -145, false, 580, 250)

    local nameBg1 = GUI.ImageCreate(listBg, "nameBg1", "1800900040", 30, -50, false, 170, 40)
    local txtPart1Name = GUI.CreateStatic(nameBg1, "txtPart1Name", "defaultup", 0, 0, 120, 50)
    GUI.SetAnchor(txtPart1Name, UIAnchor.Center)
    GUI.SetPivot(txtPart1Name, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txtPart1Name, sizeTitle)
    GUI.StaticSetAlignment(txtPart1Name, TextAnchor.MiddleCenter)
    GUI.SetColor(txtPart1Name, colorWhite)
    guidt.BindName(txtPart1Name, "txtPart1Name")

    local part1Label = GUI.CreateStatic(listBg, "PreviewLabelTxt", "部位一", -190, -50, 100, 50)
    GUI.SetAnchor(part1Label, UIAnchor.Center)
    GUI.SetPivot(part1Label, UIAroundPivot.Center)
    GUI.StaticSetFontSize(part1Label, sizeTitle)
    GUI.StaticSetAlignment(part1Label, TextAnchor.MiddleCenter)
    GUI.SetColor(part1Label, colorDark)

    local part1LeftArrBtn = GUI.ButtonCreate(nameBg1, "part2LeftArrBtn", "1800402160", -130, 0, Transition.ColorTint)
    GUI.RegisterUIEvent(part1LeftArrBtn, UCE.PointerClick, "RoleDyeingUI", "OnClickPart1LeftArrBtn")

    local part1RightArrBtn = GUI.ButtonCreate(nameBg1, "part2RightArrBtn", "1800402170", 130, 0, Transition.ColorTint)
    GUI.RegisterUIEvent(part1RightArrBtn, UCE.PointerClick, "RoleDyeingUI", "OnClickPart1RightArrBtn")

    local nameBg2 = GUI.ImageCreate(listBg, "nameBg2", "1800900040", 30, 50, false, 170, 40)
    local txtPart2Name = GUI.CreateStatic(nameBg2, "PreviewLabelTxt", "defaultdown", 0, 0, 120, 50)
    GUI.SetAnchor(txtPart2Name, UIAnchor.Center)
    GUI.SetPivot(txtPart2Name, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txtPart2Name, sizeTitle)
    GUI.StaticSetAlignment(txtPart2Name, TextAnchor.MiddleCenter)
    GUI.SetColor(txtPart2Name, colorWhite)
    guidt.BindName(txtPart2Name, "txtPart2Name")

    local part2LeftArrBtn = GUI.ButtonCreate(nameBg2, "part2LeftArrBtn", "1800402160", -130, 0, Transition.ColorTint)
    GUI.RegisterUIEvent(part2LeftArrBtn, UCE.PointerClick, "RoleDyeingUI", "OnClickPart2LeftArrBtn")

    local part2RightArrBtn = GUI.ButtonCreate(nameBg2, "part2RightArrBtn", "1800402170", 130, 0, Transition.ColorTint)
    GUI.RegisterUIEvent(part2RightArrBtn, UCE.PointerClick, "RoleDyeingUI", "OnClickPart2RightArrBtn")

    local part2Label = GUI.CreateStatic(listBg, "PreviewLabelTxt", "部位二", -190, 50, 100, 50)
    GUI.SetAnchor(part2Label, UIAnchor.Center)
    GUI.SetPivot(part2Label, UIAroundPivot.Center)
    GUI.StaticSetFontSize(part2Label, sizeTitle)
    GUI.StaticSetAlignment(part2Label, TextAnchor.MiddleCenter)
    GUI.SetColor(part2Label, colorDark)

    local ModelBottonBg = GUI.ImageCreate(panelBg, "ModelBottonBg", "1800600210", -(1200 - 610) / 2, 160)
    local shadow = GUI.ImageCreate(ModelBottonBg, "shadow", "1800400240", 0, 0)
    local recoverBtn =
        GUI.ButtonCreate(
        panelBg,
        "RecoverBtn",
        "1800602030",
        -(1200 - 610) / 2 - 120,
        230,
        Transition.ColorTint,
        "还原",
        170,
        50,
        false
    )
    GUI.ButtonSetTextFontSize(recoverBtn, 26)
    GUI.ButtonSetTextColor(recoverBtn, colorWhite)
    GUI.SetIsOutLine(recoverBtn, true)
    GUI.SetOutLine_Color(recoverBtn, colorOutline)
    GUI.SetOutLine_Distance(recoverBtn, 1)
    GUI.RegisterUIEvent(recoverBtn, UCE.PointerClick, "RoleDyeingUI", "OnClickRecoverBtn")

    local ranseBtn =
        GUI.ButtonCreate(
        panelBg,
        "CreateBtn",
        "1800602030",
        -(1200 - 610) / 2 + 120,
        230,
        Transition.ColorTint,
        "染色",
        170,
        50,
        false
    )
    GUI.ButtonSetTextFontSize(ranseBtn, 26)
    GUI.ButtonSetTextColor(ranseBtn, colorWhite)
    GUI.SetIsOutLine(ranseBtn, true)
    GUI.SetOutLine_Color(ranseBtn, colorOutline)
    GUI.SetOutLine_Distance(ranseBtn, 1)
    GUI.RegisterUIEvent(ranseBtn, UCE.PointerClick, "RoleDyeingUI", "OnClickRanseBtn")

    local PreviewLabelBg = GUI.ImageCreate(panelBg, "PreviewLabelBg", "1800400420", -(1200 - 610) / 2, -262 + 15)
    local PreviewLabelTxt = GUI.CreateStatic(PreviewLabelBg, "PreviewLabelTxt", "形象预览", 0, 0, 100, 50)
    GUI.SetAnchor(PreviewLabelTxt, UIAnchor.Center)
    GUI.SetPivot(PreviewLabelTxt, UIAroundPivot.Center)
    GUI.StaticSetFontSize(PreviewLabelTxt, sizeTitle)
    GUI.StaticSetAlignment(PreviewLabelTxt, TextAnchor.MiddleCenter)
    GUI.SetColor(PreviewLabelTxt, colorDark)

    local CostBg = GUI.ImageCreate(panelBg, "PreviewLabelBg", "1800600200", 238, 25)
    local CostBgTxt = GUI.CreateStatic(CostBg, "CostBgTxt", "染色消耗", 0, 0, 100, 50)
    GUI.SetAnchor(CostBgTxt, UIAnchor.Center)
    GUI.SetPivot(CostBgTxt, UIAroundPivot.Center)
    GUI.StaticSetFontSize(CostBgTxt, sizeTitle)
    GUI.StaticSetAlignment(CostBgTxt, TextAnchor.MiddleCenter)
    GUI.SetColor(CostBgTxt, colorDark)

    local upCostItemBg = GUI.ItemCtrlCreate(panelBg, "upCostItemBg", 1800400050, 25, 120)
    guidt.BindName(upCostItemBg, "upCostItemBg")
    local upItemNameLabel = GUI.CreateStatic(upCostItemBg, "upItemNameLabel", "道具名称", 120, -24, 100, 50)
    local upItemNeedNumLabel = GUI.CreateStatic(upCostItemBg, "upItemNeedNumLabel", "需要数量", 120, 24, 100, 50)
    GUI.StaticSetFontSize(upItemNameLabel, sizeTitle)
    GUI.SetColor(upItemNameLabel, colorDark)
    GUI.StaticSetFontSize(upItemNeedNumLabel, sizeTitle)
    GUI.SetColor(upItemNeedNumLabel, colorDark)
    local upCostNameBg = GUI.ImageCreate(upCostItemBg, "upCostNameBg", "1800900040", 320, -24, false, 240, 35)
    local upCostNumBg = GUI.ImageCreate(upCostItemBg, "upCostNumBg", "1800900040", 320, 24, false, 240, 35)
    local txtCostUpName = GUI.CreateStatic(upCostNameBg, "txtCostUpName", "txtCostUpName", 0, 0, 100, 50)
    guidt.BindName(txtCostUpName, "txtCostUpName")
    GUI.SetAnchor(txtCostUpName, UIAnchor.Center)
    GUI.SetPivot(txtCostUpName, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txtCostUpName, sizeTitle)
    GUI.StaticSetAlignment(txtCostUpName, TextAnchor.MiddleCenter)
    GUI.SetColor(txtCostUpName, colorWhite)
    local txtCostUpNum = GUI.CreateStatic(upCostNumBg, "txtCostUpNum", "txtCostUpNum", 0, 0, 100, 50)
    guidt.BindName(txtCostUpNum, "txtCostUpNum")
    GUI.SetAnchor(txtCostUpNum, UIAnchor.Center)
    GUI.SetPivot(txtCostUpNum, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txtCostUpNum, sizeTitle)
    GUI.StaticSetAlignment(txtCostUpNum, TextAnchor.MiddleCenter)
    GUI.SetColor(txtCostUpNum, colorWhite)
    guidt.BindName(txtCostUpNum, "txtCostUpNum")
    guidt.BindName(txtCostUpName, "txtCostUpName")

    local downCostItemBg = GUI.ItemCtrlCreate(panelBg, "downCostItemBg", "1800400050", 25, 220)
    guidt.BindName(downCostItemBg, "downCostItemBg")
    local downItemNameLabel = GUI.CreateStatic(downCostItemBg, "downItemNameLabel", "道具名称", 120, -24, 100, 50)
    local downItemNeedNumLabel = GUI.CreateStatic(downCostItemBg, "downItemNeedNumLabel", "需要数量", 120, 24, 100, 50)
    GUI.StaticSetFontSize(downItemNameLabel, sizeTitle)
    GUI.SetColor(downItemNameLabel, colorDark)
    GUI.StaticSetFontSize(downItemNeedNumLabel, sizeTitle)
    GUI.SetColor(downItemNeedNumLabel, colorDark)
    local downCostNameBg = GUI.ImageCreate(downCostItemBg, "upCostNameBg", "1800900040", 320, -24, false, 240, 35)
    local txtCostDownName = GUI.CreateStatic(downCostNameBg, "txtCostDownName", "txtCostDownName", 0, 0, 100, 50)
    guidt.BindName(txtCostDownName, "txtCostDownName")
    GUI.SetAnchor(txtCostDownName, UIAnchor.Center)
    GUI.SetPivot(txtCostDownName, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txtCostDownName, sizeTitle)
    GUI.StaticSetAlignment(txtCostDownName, TextAnchor.MiddleCenter)
    GUI.SetColor(txtCostDownName, colorWhite)
    local downCostNumBg = GUI.ImageCreate(downCostItemBg, "upCostNumBg", "1800900040", 320, 24, false, 240, 35)
    local txtCostDownNum = GUI.CreateStatic(downCostNumBg, "txtCostDownNum", "txtCostDownNum", 0, 0, 100, 50)
    guidt.BindName(txtCostDownNum, "txtCostDownNum")
    GUI.SetAnchor(txtCostDownNum, UIAnchor.Center)
    GUI.SetPivot(txtCostDownNum, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txtCostDownNum, sizeTitle)
    GUI.StaticSetAlignment(txtCostDownNum, TextAnchor.MiddleCenter)
    GUI.SetColor(txtCostDownNum, colorWhite)

    local model = GUI.RawImageCreate(ModelBottonBg, true, "roleModel", nil, -20, -200, 2)
    GUI.SetDepth(model, 0)

    GUI.RawImageSetCameraConfig(
        model,
        "(0.0912,1.6,2.608),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,4.79,0.01,1.15,37"
    )
    model:RegisterEvent(UCE.Drag)

    guidt.BindName(model, "modelPart")
    guidt.BindName(txtCostDownName, "txtCostDownName")
    guidt.BindName(txtCostDownNum, "txtCostDownNum")
    guidt.BindName(ModelBottonBg, "ModelBottonBg")
    guidt.BindName(shadow, "shadow")

    --data part init
    RoleDyeingUI.RefreshModel()
    RoleDyeingUI.ResetDataAndShowWnd()
end

function RoleDyeingUI.RefreshModel()
    local ModelBottonBg = guidt.GetUI("ModelBottonBg")
    local key = CL.GetRoleTemplateID()
    local sex = CL.GetIntAttr(RoleAttr.RoleAttrGender)
    test(key)
    local roleData = DB.GetRole(key)
    local modelID = 1
    if roleData ~= nil then
        modelID = roleData.Model
        test(modelID)
    end
    ---@type dynColorInfo[]
    RoleDyeingUI.DataPart.AllColorCfg = {}
    ---@type dynColorInfo[]
    RoleDyeingUI.DataPart.AllClolorCgf2 = {}
    local allIds = DB.GetColorAllKeys()
    for i = 0, allIds.Count - 1 do
        local config = DB.GetColor(allIds[i])
        if config ~= nil and key == config.TempletId and config.Table == 1 then
            ---@type dynColorInfo
            local cfg = {
                id = config.Id,
                appearId = config.AppearId
            }
            if config.Group == 1 then
                RoleDyeingUI.DataPart.AllColorCfg[config.Index] = cfg
            elseif config.Group == 2 then
                RoleDyeingUI.DataPart.AllClolorCgf2[config.Index] = cfg
            end
        end
    end

    --ui model part
    GUI.SetDepth(guidt.GetUI("shadow"), 0)
    local modelp = guidt.GetUI("model")
    local model = guidt.GetUI("modelPart")
    if modelp == nil then
        modelp = GUI.RawImageChildCreate(model, false, "role", 0, 0, 0)
        guidt.BindName(modelp, "model")
        GUI.BindPrefabWithChild(model, guidt.GetGuid("model"))
    end
    GUI.SetVisible(model, true)
    test(modelID)
    GUI.ReplaceWeapon(modelp, 0, eRoleMovement.STAND_W1, sex, modelID)
    GUI.AddToCamera(model)
end

function RoleDyeingUI.OnShow()
    GUI.SetVisible(GUI.GetWnd("RoleDyeingUI"), true)
    RoleDyeingUI.RefreshModel()
    RoleDyeingUI.ResetDataAndShowWnd()
    CL.RegisterAttr(RoleAttr.RoleAttrColor1, RoleDyeingUI.OnRoleDyeAckRefresh)
    CL.RegisterAttr(RoleAttr.RoleAttrColor2, RoleDyeingUI.OnRoleDyeAckRefresh)
    CL.RegisterMessage(GM.AddNewItem, "RoleDyeingUI", "RefreshUI")
    CL.RegisterMessage(GM.UpdateItem, "RoleDyeingUI", "RefreshUI")
end

function RoleDyeingUI.ResetDataAndShowWnd()
    test("ResetDataAndShowWnd")
    local planCurrentId1 = CL.GetIntAttr(RoleAttr.RoleAttrColor1)
    local planCurrentId2 = CL.GetIntAttr(RoleAttr.RoleAttrColor2)
    test("ResetDataAndShowWnd:" .. planCurrentId1)
    test("ResetDataAndShowWnd:" .. planCurrentId2)
    RoleDyeingUI.DataPart.plan1Index = 1
    RoleDyeingUI.DataPart.plan2Index = 1

    for i = 1, #RoleDyeingUI.DataPart.AllColorCfg do
        if RoleDyeingUI.DataPart.AllColorCfg[i].id == planCurrentId1 then
            RoleDyeingUI.DataPart.plan1Index = i
        end
    end

    for i = 1, #RoleDyeingUI.DataPart.AllClolorCgf2 do
        if RoleDyeingUI.DataPart.AllClolorCgf2[i].id == planCurrentId2 then
            RoleDyeingUI.DataPart.plan2Index = i
        end
    end
    RoleDyeingUI.DataPart.planCurrentId1 = RoleDyeingUI.DataPart.AllColorCfg[RoleDyeingUI.DataPart.plan1Index].id or 1
    RoleDyeingUI.DataPart.planCurrentId2 = RoleDyeingUI.DataPart.AllClolorCgf2[RoleDyeingUI.DataPart.plan2Index].id or 1
    test(RoleDyeingUI.DataPart.planCurrentId1)
    test(RoleDyeingUI.DataPart.planCurrentId2)
    -- DumpTable(RoleDyeingUI.DataPart)

    RoleDyeingUI.RefreshUI()
end

function RoleDyeingUI.RefreshUI()
    local id1 = RoleDyeingUI.DataPart.AllColorCfg[RoleDyeingUI.DataPart.plan1Index].id
    local id2 = RoleDyeingUI.DataPart.AllClolorCgf2[RoleDyeingUI.DataPart.plan2Index].id
    local aid1 = RoleDyeingUI.DataPart.AllColorCfg[RoleDyeingUI.DataPart.plan1Index].appearId
    local aid2 = RoleDyeingUI.DataPart.AllClolorCgf2[RoleDyeingUI.DataPart.plan2Index].appearId
    test("RefreshUI")
    GUI.RefreshDyeSkin(guidt.GetUI("model"), aid1, aid2)

    local config1 = DB.GetColor(id1)
    local config2 = DB.GetColor(id2)
    test("染色id: " .. id1)
    test("染色id: " .. id2)
    local costItems = {}
    RoleDyeingUI.DataPart.WillSendPart1Id = 0
    RoleDyeingUI.DataPart.WillSendPart2Id = 0
    if config1 ~= nil then
        GUI.StaticSetText(guidt.GetUI("txtPart1Name"), "染色方案" .. RoleDyeingUI.DataPart.plan1Index)
        RoleDyeingUI.DataPart.WillSendPart1Id = id1
        if id1 ~= RoleDyeingUI.DataPart.planCurrentId1 then
            if config1.Item1 > 0 then
                if costItems[config1.Item1] == nil then
                    costItems[config1.Item1] = 0
                end
                costItems[config1.Item1] = costItems[config1.Item1] + config1.Num1
            end
            if config1.Item2 > 0 then
                if costItems[config1.Item2] == nil then
                    costItems[config1.Item2] = 0
                end
                costItems[config1.Item2] = costItems[config1.Item2] + config1.Num2
            end
        end
    end
    if config2 ~= nil then
        GUI.StaticSetText(guidt.GetUI("txtPart2Name"), "染色方案" .. RoleDyeingUI.DataPart.plan2Index)
        RoleDyeingUI.DataPart.WillSendPart2Id = id2
        if id2 ~= RoleDyeingUI.DataPart.planCurrentId2 then
            if config2.Item1 > 0 then
                if costItems[config2.Item1] == nil then
                    costItems[config2.Item1] = 0
                end
                costItems[config2.Item1] = costItems[config2.Item1] + config2.Num1
            end
            if config2.Item2 > 0 then
                if costItems[config2.Item2] == nil then
                    costItems[config2.Item2] = 0
                end
                costItems[config2.Item2] = costItems[config2.Item2] + config2.Num2
            end
        end
    end

    RoleDyeingUI.DataPart.costItemData = {}
    local costItemDataAfterSort = {}
    for k, v in pairs(costItems) do
        test(k)
        costItemDataAfterSort[#costItemDataAfterSort + 1] = {}
        costItemDataAfterSort[#costItemDataAfterSort].ItemId = k
        costItemDataAfterSort[#costItemDataAfterSort].ItemNum = v
    end

    table.sort(
        costItemDataAfterSort,
        function(a, b)
            return a.ItemId < b.ItemId
        end
    )
    RoleDyeingUI.DataPart.costItemData = costItemDataAfterSort
    local ui1 = {"upCostItemBg", "downCostItemBg"}
    local ui2 = {"txtCostUpName", "txtCostDownName"}
    local ui3 = {"txtCostUpNum", "txtCostDownNum"}
    for i = 1, 2 do
        if RoleDyeingUI.DataPart.costItemData[i] ~= nil then
            local config1 = DB.GetOnceItemByKey1(RoleDyeingUI.DataPart.costItemData[i].ItemId)
            if config1 ~= nil then
                RoleDyeingUI.DataPart.costItemData[i].name = config1.Name
                GUI.ItemCtrlSetElementValue(guidt.GetUI(ui1[i]), eItemIconElement.Icon, config1.Icon)
                GUI.StaticSetText(guidt.GetUI(ui2[i]), config1.Name)
            end

            local amount =
                LD.GetItemCountById(
                RoleDyeingUI.DataPart.costItemData[i].ItemId,
                item_container_type.item_container_bag
            )
            RoleDyeingUI.DataPart.costItemData[i].curCnt = amount
            GUI.StaticSetText(
                guidt.GetUI(ui3[i]),
                tostring(amount) .. "/" .. tostring(RoleDyeingUI.DataPart.costItemData[i].ItemNum)
            )
            if amount >= RoleDyeingUI.DataPart.costItemData[i].ItemNum then
                GUI.SetColor(guidt.GetUI(ui3[i]), colorWhite)
            else
                GUI.SetColor(guidt.GetUI(ui3[i]), colorRed)
            end
        else
            GUI.ItemCtrlSetElementValue(guidt.GetUI(ui1[i]), eItemIconElement.Icon, "")
            GUI.StaticSetText(guidt.GetUI(ui2[i]), "")
            GUI.StaticSetText(guidt.GetUI(ui3[i]), "")
        end
    end
end

function RoleDyeingUI.OnClickPart1RightArrBtn()
    RoleDyeingUI.DataPart.plan1Index = RoleDyeingUI.DataPart.plan1Index + 1
    if RoleDyeingUI.DataPart.plan1Index > #RoleDyeingUI.DataPart.AllColorCfg then
        RoleDyeingUI.DataPart.plan1Index = 1
    end
    RoleDyeingUI.RefreshUI()
end

function RoleDyeingUI.OnClickPart1LeftArrBtn()
    RoleDyeingUI.DataPart.plan1Index = RoleDyeingUI.DataPart.plan1Index - 1
    if RoleDyeingUI.DataPart.plan1Index < 1 then
        RoleDyeingUI.DataPart.plan1Index = #RoleDyeingUI.DataPart.AllColorCfg
    end
    RoleDyeingUI.RefreshUI()
end

function RoleDyeingUI.OnClickPart2RightArrBtn()
    RoleDyeingUI.DataPart.plan2Index = RoleDyeingUI.DataPart.plan2Index + 1
    if RoleDyeingUI.DataPart.plan2Index > #RoleDyeingUI.DataPart.AllClolorCgf2 then
        RoleDyeingUI.DataPart.plan2Index = 1
    end
    RoleDyeingUI.RefreshUI()
end

function RoleDyeingUI.OnClickPart2LeftArrBtn()
    RoleDyeingUI.DataPart.plan2Index = RoleDyeingUI.DataPart.plan2Index - 1
    if RoleDyeingUI.DataPart.plan2Index < 1 then
        RoleDyeingUI.DataPart.plan2Index = #RoleDyeingUI.DataPart.AllClolorCgf2
    end
    RoleDyeingUI.RefreshUI()
end
---@param table dynColorInfo[]
function RoleDyeingUI.GetIndexIntable(table, value)
    if table ~= nil then
        for i, v in ipairs(table) do
            if v.id == value then
                return i
            end
        end
    end
    return 1
end

function RoleDyeingUI.OnClickRecoverBtn()
    RoleDyeingUI.DataPart.plan1Index =
        RoleDyeingUI.GetIndexIntable(RoleDyeingUI.DataPart.AllColorCfg, RoleDyeingUI.DataPart.planCurrentId1)
    RoleDyeingUI.DataPart.plan2Index =
        RoleDyeingUI.GetIndexIntable(RoleDyeingUI.DataPart.AllClolorCgf2, RoleDyeingUI.DataPart.planCurrentId2)
    RoleDyeingUI.RefreshUI()
end

function RoleDyeingUI.OnClickRanseBtn()
    --test("pan1Index="..RoleDyeingUI.DataPart.plan1Index..",plan2Index="..RoleDyeingUI.DataPart.plan2Index)
    local id1 = RoleDyeingUI.DataPart.AllColorCfg[RoleDyeingUI.DataPart.plan1Index].id
    local id2 = RoleDyeingUI.DataPart.AllClolorCgf2[RoleDyeingUI.DataPart.plan2Index].id
    --test("id1="..id1..",id2="..id2..",planCurrentId1="..RoleDyeingUI.DataPart.planCurrentId1..",planCurrentId2="..RoleDyeingUI.DataPart.planCurrentId2)
    
    --check same
    if id1 == RoleDyeingUI.DataPart.planCurrentId1 and id2 == RoleDyeingUI.DataPart.planCurrentId2 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "您选择的染色方案和已有方案相同，无法染色")
        return
    end

    --check num
    local totalDataT={}
    for i = 1, 2 do
        if RoleDyeingUI.DataPart.costItemData[i] ~= nil then
            local amount = RoleDyeingUI.DataPart.costItemData[i].curCnt
            if
                amount < RoleDyeingUI.DataPart.costItemData[i].ItemNum and
                    RoleDyeingUI.DataPart.costItemData[i].name ~= nil
             then
                -- CL.SendNotify(
                --     NOTIFY.ShowBBMsg,
                --     string.format("您的%s不足，无法染色", RoleDyeingUI.DataPart.costItemData[i].name)
                -- )

                test("跳转商店")
                local itemDB = DB.GetOnceItemByKey1(RoleDyeingUI.DataPart.costItemData[i].ItemId)
                local fastShop = itemDB.FastShop
                test("fastShop="..fastShop)
                --test(type(fastShop))
                if fastShop == "1" then--商会
                    --test(itemDB.Name..","..itemDB.KeyName)
                    --local parameters=tostring(itemDB.Type)..","..tostring(itemDB.Subtype)..","..tostring(itemDB.Id)
                    --local parameters=tostring(4)..","..tostring(itemDB.Subtype)..","..tostring(itemDB.Id)
                    --test(parameters)
                    --GUI.OpenWnd("CommerceUI",parameters)
                    local data = itemDB.KeyName..","..(RoleDyeingUI.DataPart.costItemData[i].ItemNum - amount)
                    --CL.SendNotify(NOTIFY.SubmitForm, "FormOneKeyBuy", "TryBuy",data)
                   table.insert(totalDataT,data)
                elseif fastShop == "3" then--商城
                    --GUI.OpenWnd("MallUI",itemDB.KeyName)
                    local data = itemDB.KeyName..","..(RoleDyeingUI.DataPart.costItemData[i].ItemNum - amount)
                    --CL.SendNotify(NOTIFY.SubmitForm, "FormOneKeyBuy", "TryBuy",data)
                    table.insert(totalDataT,data)
                end
                --return
            end
        end
    end
    if totalDataT and #totalDataT>0 then
        local totalDataStr = table.concat(totalDataT,",")
        test("totalDataStr=>"..totalDataStr)
        CL.SendNotify(NOTIFY.SubmitForm, "FormOneKeyBuy", "TryBuy",totalDataStr)
        return
    end
    --confirm box
    RoleDyeingUI.OnMsgBoxOKBtnClick_Unlock()
end

function RoleDyeingUI.OnRoleDyeAckRefresh(attrType, value)
    if attrType == RoleAttr.RoleAttrColor1 or attrType == RoleAttr.RoleAttrColor2 then
        if RoleDyeingUI.reset == nil then
            RoleDyeingUI.reset = Timer.New(RoleDyeingUI.ResetDataAndShowWnd, 0.5, false)
        end
        RoleDyeingUI.reset:Stop()
        RoleDyeingUI.reset:Start()
        test("OnRoleDyeAckRefresh")
    end
end

function RoleDyeingUI.OnMsgBoxOKBtnClick_Unlock()
    if RoleDyeingUI ~= nil and RoleDyeingUI.DataPart ~= nil then
        -- local id1 = RoleDyeingUI.DataPart.AllPlan1Ids[RoleDyeingUI.DataPart.plan1Index]
        -- local id2 = RoleDyeingUI.DataPart.AllPlan2Ids[RoleDyeingUI.DataPart.plan2Index]
        local id1 = RoleDyeingUI.DataPart.WillSendPart1Id
        local id2 = RoleDyeingUI.DataPart.WillSendPart2Id

        test(id1)
        test(id2)

        CL.SendNotify(NOTIFY.SubmitForm, "FormColor", "PlayerDyeing", id1, id2)
    end
end
function RoleDyeingUI.OnDestroy()
    RoleDyeingUI.OnClose()
end
function RoleDyeingUI.OnClose()
    local model = guidt.GetUI("modelPart")
    GUI.Destroy(guidt.GetUI("model"))
    guidt.BindName(nil, "model")
    GUI.SetVisible(model, false)

    CL.UnRegisterAttr(RoleAttr.RoleAttrColor1, RoleDyeingUI.OnRoleDyeAckRefresh)
    CL.UnRegisterAttr(RoleAttr.RoleAttrColor2, RoleDyeingUI.OnRoleDyeAckRefresh)
    if RoleDyeingUI.reset then
        RoleDyeingUI.reset:Stop()
        RoleDyeingUI.reset = nil
    end
    CL.UnRegisterMessage(GM.AddNewItem, "RoleDyeingUI", "RefreshUI")
    CL.UnRegisterMessage(GM.UpdateItem, "RoleDyeingUI", "RefreshUI")
end
function RoleDyeingUI.OnExit(key)
    local wnd = GUI.GetWnd("RoleDyeingUI")
    if wnd ~= nil then
        GUI.DestroyWnd("RoleDyeingUI")
    end
end

--guidt.GetUI("")([a-zA-Z]*) = ([a-zA-Z]*)
--guidt.BindName($1,"$1")
