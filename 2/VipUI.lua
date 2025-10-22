local VipUI = {
    ---@type table<string,VipInfo>
    ServerData = {},
    Version = "",
    got = 0,
    dayGot = 0,
    RefreshUITimer = nil,
    firstShow = 0
}
--require("GlobalProcessing")
_G.VipUI = VipUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local guidt = UILayout.NewGUIDUtilTable()
local test = print
local progressBarSize = 730
local UPMode = nil
local BtnGuid = nil
local closeTip = nil
function VipUI.InitData()
    VipUI.ServerData = {}
    VipUI.Version = ""
    return {
        vipLv = 0,
        vipExp = 0,
        ---@type VipClientInfo[]
        vipDef = {},
        curLv = 0
    }
end

VipUI.IsGot = {}

local VIPLevelNumIcon = {
    ["0"] = "#IMAGE1800605230#",
    ["1"] = "#IMAGE1800605231#",
    ["2"] = "#IMAGE1800605232#",
    ["3"] = "#IMAGE1800605233#",
    ["4"] = "#IMAGE1800605234#",
    ["5"] = "#IMAGE1800605235#",
    ["6"] = "#IMAGE1800605236#",
    ["7"] = "#IMAGE1800605237#",
    ["8"] = "#IMAGE1800605238#",
    ["9"] = "#IMAGE1800605239#"
}
local data = VipUI.InitData()
function VipUI.OnExitGame()
    data = VipUI.InitData()
end
function VipUI.OnExit()
    guidt = nil
    GUI.DestroyWnd("VipUI")
end
function VipUI.Main(parameter)
    VipUI.firstShow = 0
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("VipUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("VipUI", "VipUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "VIP特权", "VipUI", "OnExit")
    guidt.BindName(panelBg, "panelBg")
    --vip等级
    local levelIcon = GUI.ImageCreate(panelBg, "levelIcon", "1800605220", 85, 68)
    UILayout.SetSameAnchorAndPivot(levelIcon, UILayout.TopLeft)

    local level = GUI.RichEditCreate(panelBg, "level", " ", 170, 65, 120, 50)
    UILayout.SetSameAnchorAndPivot(level, UILayout.TopLeft)
    guidt.BindName(level, "level")

    --升级描述
    local levelUpDesc1 = GUI.RichEditCreate(panelBg, "levelUp", "再消费", 240, 53, 1000, 30)
    GUI.StaticSetFontSize(levelUpDesc1, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(levelUpDesc1, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(levelUpDesc1, UILayout.TopLeft)
    GUI.SetColor(levelUpDesc1, UIDefine.BrownColor)
    guidt.BindName(levelUpDesc1, "levelUpDesc1")

    local ingotDesc = GUI.CreateStatic(panelBg, "ingotDesc", " ", 380, 53, 350, 30)
    GUI.StaticSetFontSize(ingotDesc, 24)
    GUI.StaticSetAlignment(ingotDesc, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(ingotDesc, UILayout.TopLeft)
    GUI.SetColor(ingotDesc, UIDefine.BrownColor)
    guidt.BindName(ingotDesc, "ingotDesc")

    local ingotIcon = GUI.ImageCreate(ingotDesc, "ingotIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], -15, 0)
    GUI.SetAnchor(ingotIcon, UIAnchor.Left)
    GUI.SetPivot(ingotIcon, UIAroundPivot.Right)
    guidt.BindName(ingotIcon, "ingotIcon")

    --进度条
    local progressBarBg = GUI.ImageCreate(panelBg, "progressBarBg", "1800408110", 237, 85, false, progressBarSize, 28)
    UILayout.SetSameAnchorAndPivot(progressBarBg, UILayout.TopLeft)

    local progressBar = GUI.ImageCreate(progressBarBg, "progressBar", "1800408160", 0, 0, false, 0, 28)
    UILayout.SetSameAnchorAndPivot(progressBar, UILayout.Left)
    guidt.BindName(progressBar, "progressBar")

    local progressBarText = GUI.CreateStatic(progressBarBg, "progressBarText", "100/100", 0, 0, progressBarSize, 35)
    GUI.StaticSetFontSize(progressBarText, 24)
    GUI.StaticSetAlignment(progressBarText, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(progressBarText, UILayout.Center)
    GUI.SetColor(progressBarText, UIDefine.WhiteColor)
    guidt.BindName(progressBarText, "progressBarText")

    --充值
    local buyBtn =
        GUI.ButtonCreate(panelBg, "buyBtn", "1800402110", 995, 70, Transition.ColorTint, "充 值", 120, 45, false)
    UILayout.SetSameAnchorAndPivot(buyBtn, UILayout.TopLeft)
    GUI.RegisterUIEvent(buyBtn, UCE.PointerClick, "VipUI", "OnPurchase")
    GUI.ButtonSetTextFontSize(buyBtn, UIDefine.FontSizeL)
    GUI.ButtonSetTextColor(buyBtn, UIDefine.BrownColor)
    local rollVecSize = Vector2.New(1070, 465)
    local src =
        GUI.LoopScrollRectCreate(
        panelBg,
        "src",
        56,
        145,
        1070,
        465,
        "VipUI",
        "CreateItem",
        "VipUI",
        "RefreshItemScroll",
        0,
        true,
        rollVecSize,
        1,
        UIAroundPivot.TopLeft,
        UIAnchor.TopLeft
    )
    GUI.SetInertia(src, false)
    guidt.BindName(src, "src")
    UILayout.SetSameAnchorAndPivot(src, UILayout.TopLeft)
    src:RegisterEvent(UCE.EndDrag)
    GUI.RegisterUIEvent(src, UCE.EndDrag, "VipUI", "OnRollEndDragCallBack")
    src:RegisterEvent(UCE.BeginDrag)
    GUI.RegisterUIEvent(src, UCE.BeginDrag, "VipUI", "OnRollBeginDragCallBack")
    local nextPageBtn = GUI.ButtonCreate(panelBg, "nextPageBtn", "1800102080", 500, -182, Transition.ColorTint)
    local upPageBtn = GUI.ButtonCreate(panelBg, "upPageBtn", "1800102080", -500, -182, Transition.ColorTint)
    guidt.BindName(nextPageBtn, "nextPageBtn")
    guidt.BindName(upPageBtn, "upPageBtn")
    GUI.SetScale(nextPageBtn, Vector3.New(-1, 1, 1))
    GUI.SetVisible(upPageBtn, false)
    GUI.SetVisible(nextPageBtn, false)

    GUI.RegisterUIEvent(nextPageBtn, UCE.PointerClick, "VipUI", "OnArrowClick")
    GUI.RegisterUIEvent(upPageBtn, UCE.PointerClick, "VipUI", "OnArrowClick")
end
function VipUI.OnShow(parameter)
    --test("787878")
    local wnd = GUI.GetWnd("VipUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
    VipUI.GetDate()
    CL.RegisterAttr(RoleAttr.RoleAttrVip, VipUI.OnAttr)
    CL.RegisterAttr(RoleAttr.RoleAttrVipExp, VipUI.OnAttr)
    if VipUI.RefreshUITimer then
        VipUI.RefreshUITimer:Stop()
        VipUI.RefreshUITimer = nil
    end
    VipUI.RefreshUITimer = Timer.New(VipUI.RefreshUI, 0.1)
    VipUI.RefreshUITimer:Start()
    data.curLv = data.vipLv
end
function VipUI.OnDestroy()
    VipUI.OnClose()
end
function VipUI.OnClose()
    local wnd = GUI.GetWnd("VipUI")
    GUI.SetVisible(wnd, false)
    if VipUI.RollTimer ~= nil then
        VipUI.RollTimer:Stop()
        VipUI.RollTimer = nil
    end
    CL.UnRegisterAttr(RoleAttr.RoleAttrVip, VipUI.OnAttr)
    CL.UnRegisterAttr(RoleAttr.RoleAttrVipExp, VipUI.OnAttr)
    if VipUI.RefreshUITimer then
        VipUI.RefreshUITimer:Stop()
        VipUI.RefreshUITimer = nil
    end
end
function VipUI.OnPurchase(guid)
    --GUI.OpenWnd("MallUI")
    GetWay.Def[1].jump("MallUI", "充值")
end
function VipUI.OnAttr(type, value)
    local h
    if type == RoleAttr.RoleAttrVip then
        data.vipLv, h = int64.longtonum2(value)
    elseif type == RoleAttr.RoleAttrVipExp then
        data.vipExp, h = int64.longtonum2(value)
    end
end
function VipUI.GetDate()
    --test("GetDate")
    data.vipLv = CL.GetIntAttr(RoleAttr.RoleAttrVip)
    data.vipExp = CL.GetIntAttr(RoleAttr.RoleAttrVipExp)
    CL.SendNotify(NOTIFY.SubmitForm, "FormVip", "VipGetData", VipUI.Version)
end
function VipUI.Refresh()
    VipUI.ClientRefresh()
end
-- 礼包领取通知
function VipUI.GotRefresh()
    if VipUI.RefreshUITimer then
        VipUI.RefreshUITimer:Stop()
        VipUI.RefreshUITimer:Start()
    end
end
function VipUI.ClientRefresh()
    for key, value in pairs(VipUI.ServerData) do
        local i = tonumber(string.sub(key, 4))
        if i ~= nil then
            ---@type VipClientInfo
            local tmp = {}
            tmp.gift_lvup = LogicDefine.SeverItems2ClientItems(value.gift_lvup.Item_list)
            tmp.gift_periodic = LogicDefine.SeverItems2ClientItems(value.gift_Periodic.Item_list)
            data.vipDef[i + 1] = tmp
        else
            --test("Vip参数错误")
        end
    end
    if VipUI.RefreshUITimer then
        VipUI.RefreshUITimer:Stop()
        VipUI.RefreshUITimer:Start()
    end
    data.curLv = data.vipLv
end
function VipUI.RefreshUI()
    local ui = GUI.GetWnd("VipUI")
    if ui == nil or GUI.GetVisible(ui) == false then
        return
    end
    local level = guidt.GetUI("level")
    local lvTxt = ""
    local vipLvStr = tostring(data.vipLv)
    if VipUI.ServerData["vip" .. (data.vipLv)] == nil then
        return
    end
    local nextVipExp = VipUI.ServerData["vip" .. (data.vipLv)].lvup_exp
    for i = 1, string.len(vipLvStr) do
        lvTxt = lvTxt .. VIPLevelNumIcon[(string.sub(vipLvStr, i, i))]
    end
    GUI.StaticSetText(level, lvTxt)
    local ingotDesc = guidt.GetUI("ingotDesc")
    local levelUpDesc1 = guidt.GetUI("levelUpDesc1")
    local ingotIcon = guidt.GetUI("ingotIcon")
    if data.vipLv == #data.vipDef - 1 then
        GUI.StaticSetText(ingotDesc, " ")
        GUI.StaticSetText(levelUpDesc1, " ")
        nextVipExp = data.vipExp
        GUI.SetVisible(ingotIcon,false)
    else
        if VipUI.ServerData.exp_mode == 1 then
            GUI.StaticSetText(levelUpDesc1, "再消费")
            GUI.StaticSetText(ingotDesc, nextVipExp - data.vipExp .. "，达到VIP" .. (data.vipLv + 1))
            GUI.SetPositionX(ingotDesc,380)
            GUI.SetVisible(ingotIcon,true)
        else
            GUI.StaticSetText(levelUpDesc1, "再充值")
            GUI.StaticSetText(ingotDesc, nextVipExp - data.vipExp .. "元，达到VIP" .. (data.vipLv + 1))
            GUI.SetPositionX(ingotDesc,305)
            GUI.SetVisible(ingotIcon,false)
        end
    end

    local progressBarText = guidt.GetUI("progressBarText")
    GUI.StaticSetText(progressBarText, data.vipExp .. "/" .. nextVipExp)
    if tonumber(data.vipLv) == 15 then
        GUI.StaticSetText(progressBarText, "已满级")
    end
    local progressBar = guidt.GetUI("progressBar")
    GUI.SetWidth(progressBar, progressBarSize * data.vipExp / nextVipExp)

    local src = guidt.GetUI("src")
    GUI.LoopScrollRectSetTotalCount(src, #data.vipDef)
    GUI.LoopScrollRectRefreshCells(src)
    VipUI.RefreshArrowUI()
end
function VipUI.RefreshArrowUI()
    if #data.vipDef <= 0 then
        return
    end
    local src = guidt.GetUI("src")
    local nextPageBtn = guidt.GetUI("nextPageBtn")
    local upPageBtn = guidt.GetUI("upPageBtn")
    if data.curLv <= 0 then
        GUI.SetVisible(upPageBtn, false)
        GUI.SetVisible(nextPageBtn, true)
    elseif data.curLv >= #data.vipDef - 1 then
        GUI.SetVisible(nextPageBtn, false)
        GUI.SetVisible(upPageBtn, true)
    else
        GUI.SetVisible(nextPageBtn, true)
        GUI.SetVisible(upPageBtn, true)
    end
    if VipUI.firstShow == 0 then
        GUI.ScrollRectSetNormalizedPosition(src, Vector2.New(data.curLv / (#data.vipDef), 1))
        VipUI.firstShow = 1
    else
        GUI.LoopScrollRectSrollToCell(src, data.curLv, 2500)
    end
end
function VipUI.CreateItem()
    local scroll = guidt.GetUI("src")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = GUI.GroupCreate(scroll, curCount, 0, 0, 280, 100)
    local privilegeBg = GUI.ImageCreate(item, "privilegeBg", "1800001160", 20, 0, false, 560, 467)
    GUI.SetIsRaycastTarget(privilegeBg, true)
    local privilegeTitleBg = GUI.ImageCreate(privilegeBg, "titleBg", "1800600800", 0, 0, false, 316, 115)
    UILayout.SetSameAnchorAndPivot(privilegeTitleBg, UILayout.Top)
    local title = GUI.CreateStatic(privilegeTitleBg, "title", " ", 0, 0, 300, 34)
    UILayout.SetSameAnchorAndPivot(title, UILayout.Center)
    GUI.StaticSetFontSize(title, UIDefine.FontSizeXXL)
    GUI.SetColor(title, UIDefine.YellowStdColor)
    GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)

    local privilegeText = GUI.CreateStatic(privilegeBg, "text", " ", 0, 110, 480, 345)
    UILayout.SetSameAnchorAndPivot(privilegeText, UILayout.Top)
    GUI.StaticSetFontSize(privilegeText, UIDefine.FontSizeL)
    GUI.SetColor(privilegeText, UIDefine.BrownColor)
    GUI.StaticSetAlignment(privilegeText, TextAnchor.MiddleLeft)
    local name = {"onceGiftBg", "DayGiftBg"}
    local ypos = {0, 240}
    local evt = {"OnOnceGiftClick", "OnDayGiftClick"}
    for j = 1, 2 do
        -- body
        local giftBg = GUI.ImageCreate(item, name[j], "1800600790", 597, ypos[j], false, 465, 225)
        GUI.SetIsRaycastTarget(giftBg, true)
        local titleBg = GUI.ImageCreate(giftBg, "titleBg", "1800400420", 0, 17)
        UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)
        local title = GUI.CreateStatic(titleBg, "title", " ", 0, 0, 190, 30)
        UILayout.SetSameAnchorAndPivot(title, UILayout.Center)
        GUI.StaticSetFontSize(title, UIDefine.FontSizeL)
        GUI.SetColor(title, UIDefine.BrownColor)
        GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)

        local PriceBg = GUI.ImageCreate(giftBg, "PriceBg", "1800601040",-50, -12,false,125,35)
        UILayout.SetSameAnchorAndPivot(PriceBg, UILayout.Bottom)
        local PriceM = GUI.ImageCreate(PriceBg,"PriceM","1800408250",-39,0,false ,35,35)
        if j==2 then
          GUI.ImageSetImageID(PriceM,"1800408260")
        end
        local Price_txt = GUI.CreateStatic(PriceBg,"Price_txt","9999",15,0,80,35)
        GUI.StaticSetFontSize(Price_txt, UIDefine.FontSizeS)
        GUI.SetColor(Price_txt, UIDefine.BrownColor)
        GUI.StaticSetAlignment(Price_txt, TextAnchor.MiddleCenter)

        local PriceTxt = GUI.CreateStatic(PriceBg,"PriceTxt","999",15,30,80,35)
        GUI.StaticSetFontSize(PriceTxt, UIDefine.FontSizeS)
        GUI.SetColor(PriceTxt, UIDefine.BrownColor)
        GUI.StaticSetAlignment(PriceTxt, TextAnchor.MiddleCenter)

        local temp = GUI.CreateStatic(PriceBg,"temp","________",25,7,90,50)
        GUI.StaticSetFontSize(temp, 30)
        GUI.SetColor(temp,UIDefine.RedColor)

        local txt = GUI.CreateStatic(giftBg,"txt","",233,170,200,50, "system")
        GUI.StaticSetFontSize(txt, 24)
        GUI.SetColor(txt, UIDefine.BrownColor)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
        GUI.SetVisible(txt,false)

        local SellOutPic = GUI.ImageCreate(giftBg,"SellOutPic","1801404200",175,165,false,120,45)
        GUI.SetVisible(SellOutPic,false)
        local getBtn =
            GUI.ButtonCreate(giftBg, "getBtn", "1800402110", 65, -8, Transition.ColorTint, "获取", 120, 45, false)
        UILayout.SetSameAnchorAndPivot(getBtn, UILayout.Bottom)
        GUI.ButtonSetTextFontSize(getBtn, UIDefine.FontSizeL)
        GUI.ButtonSetTextColor(getBtn, UIDefine.BrownColor)
        GUI.RegisterUIEvent(getBtn, UCE.PointerClick, "VipUI", evt[j])

        local roll = GUI.ListCreate(giftBg, "roll", 0, 66, 455, 111, true)
        UILayout.SetSameAnchorAndPivot(roll, UILayout.Top)
        for i = 1, 5 do
            local item = ItemIcon.Create(roll, i, 0, 0)
            GUI.RegisterUIEvent(item, UCE.PointerClick, "VipUI", "OnClickItemIcon")
        end
    end
    return item
end
function VipUI.RefreshItemScroll(parameter)
    if closeTip then
        GUI.Destroy(closeTip)
    end
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local curLv = tonumber(parameter[2])
    local index = curLv + 1
    local VipTxt = "VIP" .. curLv
    local item = GUI.GetByGuid(guid)
    local privilegeBg = GUI.GetChild(item, "privilegeBg", false)
    local privilegeTitleBg = GUI.GetChild(privilegeBg, "titleBg", false)
    local title = GUI.GetChild(privilegeTitleBg, "title", false)


    local privilegeText = GUI.GetChild(privilegeBg, "text", false)
    GUI.StaticSetText(title, VipTxt .. "特权")
    local txt = ""
    if VipUI.ServerData["vip" .. curLv] then
        for i = 1, #VipUI.ServerData["vip" .. curLv].describe do
            txt = txt .. i .. "." .. VipUI.ServerData["vip" .. curLv].describe[i]
            if (i ~= #VipUI.ServerData["vip" .. curLv].describe) then
                txt = txt .. "\n"
            end
        end
        GUI.StaticSetText(privilegeText, txt)
    end
    local name = {"onceGiftBg", "DayGiftBg"}
    local titleTxt = {"至尊礼盒", "贵族礼盒"}
    local isGot = {VipUI.got ~= 0, VipUI.dayGot ~= 0}
    local items = {data.vipDef[index].gift_lvup, data.vipDef[index].gift_periodic}
    for j = 1, 2 do
        -- body
        local giftBg = GUI.GetChild(item, name[j], false)
        local titleBg = GUI.GetChild(giftBg, "titleBg", false)
        local title = GUI.GetChild(titleBg, "title", false)
        local txt = GUI.GetChild(giftBg,"txt",false)
        local getBtn = GUI.GetChild(giftBg, "getBtn", false)
        local PriceBg = GUI.GetChild(giftBg,"PriceBg",false)
        local Price_txt = GUI.GetChild(PriceBg,"Price_txt",false)
        local PriceTxt = GUI.GetChild(PriceBg,"PriceTxt",false)
        local roll = GUI.GetChild(giftBg, "roll", false)
        local SellOutPic = GUI.GetChild(giftBg,"SellOutPic",false)
        local itemIcon = {}
        ---@type eqiupItem[]
        local itemList = items[j]
        for i = 1, 5 do
            itemIcon[i] = GUI.GetChild(roll, tostring(i), false)
        end
        GUI.StaticSetText(title, VipTxt .. titleTxt[j])
        if #itemList > 5 then
            --test("礼包数量超过5个")
        end
        if j == 1 then
            local level = "vip"..tonumber(curLv)
            GUI.StaticSetText(Price_txt,VipUI.ServerData[level].gift_lvup.ShowMoneyVal)
            GUI.StaticSetText(PriceTxt,VipUI.ServerData[level].gift_lvup.MoneyVal)
        else
            local level = "vip"..tonumber(curLv)
            GUI.StaticSetText(Price_txt,VipUI.ServerData[level].gift_Periodic.ShowMoneyVal)
            GUI.StaticSetText(PriceTxt,VipUI.ServerData[level].gift_Periodic.MoneyVal)
        end
        for i = 1, #itemList do
            -- test(itemList[i].keyname)
            local icon = itemIcon[i]
            GUI.SetVisible(icon, true)
            ItemIcon.BindItemId(icon, itemList[i].id)
            GUI.SetData(icon, "id", itemList[i].id)
            if itemList[i].isbind and itemList[i].isbind == 1 then
                GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp, 1800707120)
            else
                GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp, nil)
            end
            GUI.ItemCtrlSetElementValue(icon, eItemIconElement.RightBottomNum, itemList[i].count)
        end
        for i = #itemList + 1, 5 do
            GUI.SetVisible(itemIcon[i], false)
        end
        local v = tonumber(curLv)
        GUI.ButtonSetIndex(getBtn, curLv)
        if curLv > data.vipLv then
            GUI.SetVisible(getBtn,false)
            GUI.SetVisible(txt,true)
            GUI.StaticSetText(txt,"达到VIP"..curLv.."可购买")
            GUI.SetVisible(PriceBg,true)
            GUI.SetVisible(SellOutPic,false)
        elseif VipUI.IsGot[v][j] == 1 then
            GUI.SetVisible(getBtn,false)
            GUI.SetVisible(txt,false)
            GUI.SetVisible(PriceBg,false)
            GUI.SetVisible(SellOutPic,true)
        else
            GUI.ButtonSetText(getBtn, "购买")
            GUI.SetEventCD(getBtn, UCE.PointerClick, 1)
            GUI.ButtonSetShowDisable(getBtn, true)
            GUI.SetVisible(getBtn,true)
            GUI.SetVisible(PriceBg,true)
            GUI.SetVisible(txt,false)
            GUI.SetVisible(SellOutPic,false)

        end
    end
end
function VipUI.OnRollBeginDragCallBack(guid)
    local src = GUI.GetByGuid(guid)
    local pos = GUI.GetNormalizedPosition(src)
    VipUI.RollRateBegin = 1 - pos.x
end
--滚条条回调
function VipUI.OnRollEndDragCallBack(guid)
    local src = GUI.GetByGuid(guid)
    local pos = GUI.GetNormalizedPosition(src)
    -- local w = GUI.GetWidth(src)
    -- local tw = GUI.ScrollRectGetPreferredWidth(src)
    -- VipUI.RollRateNow = 1 - pos.x
    -- test(VipUI.RollRateNow)
    -- local base = 1 / 15.0 / 2
    -- VipUI.RollRateTarget = 1
    -- for i = 0, 15 do
    --     if i * base >= VipUI.RollRateNow then
    --         VipUI.RollRateTarget = i * base
    --         test(VipUI.RollRateTarget)
    --         break
    --     end
    -- end
    -- if false then
    --     VipUI.RollTimerStart()
    -- else
    --     GUI.ScrollRectSetNormalizedPosition(src, Vector2.New(VipUI.RollRateTarget, 1))
    -- end

    VipUI.RollRateNow = 1 - pos.x
    local lv = data.curLv
    if VipUI.RollRateNow > (VipUI.RollRateBegin + 0.01) then
        lv = lv + 1
    elseif VipUI.RollRateNow < (VipUI.RollRateBegin - 0.01) then
        lv = lv - 1
    end

    VipUI.SetCurLv(lv)
    VipUI.RollRateTarget = (data.curLv + 1) / #data.vipDef
    --test(VipUI.RollRateNow)
    --test(VipUI.RollRateTarget)

    -- VipUI.RollTimerStart()
    VipUI.RefreshArrowUI()
end
-- function VipUI.RollTimerStart()
--     if VipUI.RollRateNow <= VipUI.RollRateTarget then
--         VipUI.RollAutoDragSeed = 0.0075
--     else
--         VipUI.RollAutoDragSeed = -0.0075
--     end

--     if VipUI.RollTimer == nil then
--         VipUI.RollTimer = Timer.New(VipUI.RollTimerCallBack, 1, -1)
--     end
--     VipUI.RollTimer:Start()
-- end

-- function VipUI.RollTimerCallBack()
--     if math.abs(VipUI.RollRateNow - VipUI.RollRateTarget) <= math.abs(VipUI.RollAutoDragSeed) then
--         VipUI.RollRateNow = VipUI.RollRateTarget
--         VipUI.RollTimer:Stop()
--     elseif VipUI.RollRateNow < 0 then
--         VipUI.RollRateNow = 0
--         VipUI.RollTimer:Stop()
--     elseif VipUI.RollRateNow > 1 then
--         VipUI.RollRateNow = 1
--         VipUI.RollTimer:Stop()
--     else
--         VipUI.RollRateNow = VipUI.RollRateNow + VipUI.RollAutoDragSeed
--     end

--     local src = guidt.GetUI("src")
--     if VipUI.RollRateNow == VipUI.RollRateTarget then
--         VipUI.RefreshArrowUI()
--     else
--         test(VipUI.RollRateNow)
--         GUI.ScrollRectSetNormalizedPosition(src, Vector2.New(VipUI.RollRateNow, 1))
--     end
-- end
function VipUI.OnClickItemIcon(guid)
    local item = GUI.GetByGuid(guid)
    local id = tonumber(GUI.GetData(item, "id"))
    local tip = Tips.CreateByItemId(id, guidt.GetUI("panelBg"), "tip", 0, 33)
    closeTip = tip
    GUI.SetIsRemoveWhenClick(tip, true)
end
function VipUI.OnOnceGiftClick(guid)
    UPMode = 1
    BtnGuid = guid
    GlobalUtils.ShowBoxMsg2Btn("提示","是否购买该礼盒？","VipUI","确认","confirm","取消")
end

function VipUI.OnDayGiftClick(guid)
    UPMode = 0
    BtnGuid = guid
    GlobalUtils.ShowBoxMsg2Btn("提示","是否购买该礼盒？","VipUI","确认","confirm","取消")
end

function VipUI.confirm()
    VipUI.GetGift(BtnGuid,UPMode)
end

function VipUI.GetGift(guid, mode)
    local btn = GUI.GetByGuid(guid)
    local index = GUI.ButtonGetIndex(btn)
    if index then
            CL.SendNotify(NOTIFY.SubmitForm, "FormVip", "OpenVIPGift", mode, index)
    end
end
function VipUI.OnArrowClick(guid)
    if guid == guidt.GetGuid("nextPageBtn") then
        VipUI.SetCurLv(data.curLv + 1)
    elseif guid == guidt.GetGuid("upPageBtn") then
        VipUI.SetCurLv(data.curLv - 1)
    end
    VipUI.RefreshArrowUI()
end
function VipUI.SetCurLv(lv)
    data.curLv = math.min(lv, #data.vipDef - 1)
    data.curLv = math.max(data.curLv, 0)
end

