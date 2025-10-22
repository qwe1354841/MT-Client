local DiscountWnd = {
    DiscountData = {},
    IsShowing = false,
}

_G.DiscountWnd = DiscountWnd
---@type guidTable
local GuidCacheUtil = nil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local QualityRes = UIDefine.ItemIconBg
local SurplusTime = nil

function DiscountWnd.Main()
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("DiscountWnd", "DiscountWnd", 0, 0, eCanvasGroup.Normal_Extend);
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)

    local panelCover = GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    GUI.SetGroupAlpha(panelCover, 0)
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)

    local bgPanel = GUI.ImageCreate(panel, "bgPanel", "1800001120", 0, 0, false, 460, 300);
    GuidCacheUtil.BindName(bgPanel, "bgPanel")
    SetAnchorAndPivot(bgPanel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.ImageSetType(bgPanel, SpriteType.Sliced)

    local flower = GUI.ImageCreate(bgPanel, "flower", "1800007060", -25, -25, false);
    SetAnchorAndPivot(flower, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local tipsBg = GUI.ImageCreate(bgPanel, "tipsBg", "1800001030", 0, 20);
    SetAnchorAndPivot(tipsBg, UIAnchor.Top, UIAroundPivot.Top)
    --t提示
    local tipLabel = GUI.CreateStatic(tipsBg, "tipLabel", "优惠限时购", 0, 0, 100, 50, "system", true, false);
    GUI.StaticSetFontSize(tipLabel, 20)
    GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(tipLabel, UIAnchor.Center, UIAroundPivot.Center)
    local tipColor = Color.New(248 / 255, 244 / 255, 221 / 255, 255 / 255);
    GUI.SetColor(tipLabel, tipColor);

    --确认
    local btnBuy = GUI.ButtonCreate(bgPanel, "btnBuy", "1800002060", 90, -30, Transition.ColorTint);
    SetAnchorAndPivot(btnBuy, UIAnchor.Bottom, UIAroundPivot.Bottom)
    local okLabel = GUI.CreateStatic(btnBuy, "okLabel", "购买", 0, 0, 100, 50, "system", true, false);
    GUI.StaticSetFontSize(okLabel, 24)
    GUI.StaticSetAlignment(okLabel, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(okLabel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(okLabel, UIDefine.WhiteColor);
    GUI.SetIsOutLine(okLabel, true)
    local outLineColor = Color.New(180 / 255, 92 / 255, 31 / 255, 255 / 255);
    GUI.SetOutLine_Color(okLabel, outLineColor)
    GUI.SetOutLine_Distance(okLabel, 1)
    GUI.RegisterUIEvent(btnBuy, UCE.PointerClick, "DiscountWnd", "btnBuy_OnClick")

    --关闭
    local btnClose = GUI.ButtonCreate(bgPanel, "btnClose", "1800002050", -20, 20, Transition.ColorTint);
    GuidCacheUtil.BindName(btnClose, "btnClose")
    SetAnchorAndPivot(btnClose, UIAnchor.TopRight, UIAroundPivot.TopRight)
    --GUI.SetVisible(btnClose, false)

    GUI.RegisterUIEvent(btnClose, UCE.PointerClick, "DiscountWnd", "btnClose_OnClick")

    local btnClosePlus = GUI.ButtonCreate(btnClose, "btnClosePlus", "1800001060", 0, 0, Transition.ColorTint, "", 120, 120, false);
    SetAnchorAndPivot(btnClosePlus, UIAnchor.Center, UIAroundPivot.Center)

    GUI.RegisterUIEvent(btnClosePlus, UCE.PointerClick, "DiscountWnd", "btnClose_OnClick")

    local txtDesc = GUI.CreateStatic(bgPanel, "txtDesc", "升级当然要加东西啦", 0, 50, 400, 55, "system", true, false);
    GuidCacheUtil.BindName(txtDesc, "txtDesc")
    SetAnchorAndPivot(txtDesc, UIAnchor.Top, UIAroundPivot.Top)
    GUI.StaticSetFontSize(txtDesc, 15)
    GUI.SetColor(txtDesc, Color.New(175 / 255, 153 / 255, 132 / 255, 255 / 255))
    GUI.StaticSetAlignment(txtDesc, TextAnchor.MiddleCenter)

    local txtTimes = GUI.CreateStatic(bgPanel, "txtTimes", "购买剩余时间：<color=#32CD32>这里显示默认窗口</color>", 0, 75, 400, 50, "system", true, false);
    GuidCacheUtil.BindName(txtTimes, "txtTimes")
    SetAnchorAndPivot(txtTimes, UIAnchor.Top, UIAroundPivot.Top)
    GUI.StaticSetFontSize(txtTimes, 20)
    GUI.SetColor(txtTimes, Color.New(175 / 255, 153 / 255, 132 / 255, 255 / 255))
    GUI.StaticSetAlignment(txtTimes, TextAnchor.MiddleCenter)

    --打折部分
    local imgMoneyType = GUI.ImageCreate(bgPanel, "imgMoneyType", UIDefine.GetMoneyIcon(1), -130, -40)
    GuidCacheUtil.BindName(imgMoneyType, "imgMoneyType")
    SetAnchorAndPivot(imgMoneyType, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local txtOriginal = GUI.CreateStatic(imgMoneyType, "txtOriginal", "99999", 50, 15, 80, 55, "system", true, false);
    GuidCacheUtil.BindName(txtOriginal, "txtOriginal")
    SetAnchorAndPivot(txtOriginal, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(txtOriginal, 20)
    GUI.SetColor(txtOriginal, Color.New(175 / 255, 153 / 255, 132 / 255, 255 / 255));
    GUI.StaticSetAlignment(txtOriginal, TextAnchor.MiddleCenter)

    local txtTransline = GUI.CreateStatic(imgMoneyType, "txtTransline", "______", 50, 25, 80, 55, "system", true, false);
    SetAnchorAndPivot(txtTransline, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(txtTransline, 20)
    GUI.SetColor(txtTransline, UIDefine.RedColor);
    GUI.StaticSetAlignment(txtTransline, TextAnchor.MiddleCenter)

    local txtDiscount = GUI.CreateStatic(imgMoneyType, "txtDiscount", "9999", 50, -10, 80, 55, "system", true, false)
    GuidCacheUtil.BindName(txtDiscount, "txtDiscount")
    SetAnchorAndPivot(txtDiscount, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(txtDiscount, 20)
    GUI.SetColor(txtDiscount, Color.New(175 / 255, 153 / 255, 132 / 255, 255 / 255));
    GUI.StaticSetAlignment(txtDiscount, TextAnchor.MiddleCenter)

    GUI.SetVisible(txtOriginal, false)
    GUI.SetVisible(txtDiscount, false)
end

function DiscountWnd.OnShow(parameter)
    if parameter == nil then
        return
    end
    local wnd = GUI.GetWnd("DiscountWnd")
    if wnd == nil then
        return
    end
    if DiscountWnd.IsShowing then
        table.insert(DiscountWnd.DiscountData, tonumber(parameter))
    else
        GUI.SetVisible(wnd, true)
        DiscountWnd.ShowItemList(tonumber(parameter))
        DiscountWnd.IsShowing = true
    end
end

function DiscountWnd.OnDestroy()
    if DiscountWnd['SurplusTimer'] then
        DiscountWnd['SurplusTimer']:Stop()
    end
    DiscountWnd.IsShowing = false
end

function DiscountWnd.CloseWnd()
    if #DiscountWnd.DiscountData == 0 then
        GUI.DestroyWnd("DiscountWnd")
        DiscountWnd['SurplusTimer']:Stop()
    else
        GUI.DestroyWnd("DiscountWnd")
        DiscountWnd['SurplusTimer']:Stop()
        local fun = function()
            local index = DiscountWnd.DiscountData[1]
            table.remove(DiscountWnd.DiscountData, 1)
            DiscountWnd.IsShowing = false
            GUI.OpenWnd("DiscountWnd", index)
        end
        Timer.New(fun, 0.2):Start()
    end
end

function DiscountWnd.btnClose_OnClick()
    DiscountWnd.CloseWnd()
end

function DiscountWnd.btnBuy_OnClick()
    if DiscountWnd.ShowIndex then
        CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "DiscountPurchase", DiscountWnd.ShowIndex)
    end
end

function DiscountWnd.ShowItemList(index)
    if not DISCOUNT_CONFIG then
        print("-----------未获取到DISCOUNT_CONFIG-------------")
        return
    end
    local config = DISCOUNT_CONFIG[index]
    if not config then
        print("------------DISCOUNT_CONFIG中不存在第" .. index .. "序列的配置")
        return
    end

    DiscountWnd.ShowIndex = index
    local txtDesc = GuidCacheUtil.GetUI("txtDesc")
    GUI.StaticSetText(txtDesc, config.Desc or "恭喜你开启了以下优惠项目！")
    if config.DiscountTime_1 then
        if config.DiscountTime_1 > 0 then
            SurplusTime = config.DiscountTime_1
            DiscountWnd.TimeCallBack()
            DiscountWnd['SurplusTimer'] = Timer.New(DiscountWnd.TimeCallBack, 1, -1)
            DiscountWnd['SurplusTimer']:Start()
        end
    end

    local imgMoneyType = GuidCacheUtil.GetUI("imgMoneyType")
    local txtOriginal = GuidCacheUtil.GetUI("txtOriginal")
    local txtDiscount = GuidCacheUtil.GetUI("txtDiscount")
    GUI.ImageSetImageID(imgMoneyType, UIDefine.GetMoneyIcon(config['MoneyType'] or 1))
    GUI.StaticSetText(txtOriginal, (config.MoneyVal or "99999"))
    GUI.StaticSetText(txtDiscount, (math.floor(config.MoneyVal * config.Discounter_1) or "9999"))
    GUI.SetVisible(txtOriginal, true)
    GUI.SetVisible(txtDiscount, true)

    local items = {}
    local numbers = {}
    local pets = config.PetList or {}
    for k, v in ipairs(config.ItemList) do
        if type(v) == "string" then
            table.insert(items, v)
            if type(config.ItemList[k + 1]) == "number" then
                table.insert(numbers, config.ItemList[k + 1])
            else
                table.insert(numbers, 1)
            end
        end
    end

    local role = CL.GetIntAttr(RoleAttr.RoleAttrRole)
    if config["ItemList_" .. role] then
        for k, v in ipairs(config["ItemList_" .. role]) do
            if type(v) == "string" then
                table.insert(items, v)
                if type(config["ItemList_" .. role]) == "number" then
                    table.insert(numbers, config["ItemList_" .. role][k + 1])
                else
                    table.insert(numbers, 1)
                end
            end
        end
    end

    if #items ~= #numbers then
        print("数据解析错误")
        return
    end
    local num = #items + #pets
    if num > 4 then
        num = 4
    end
    local bgPanel = GuidCacheUtil.GetUI("bgPanel")
    for i = 1, num do
        local itmExhibition = GUI.ItemCtrlCreate(bgPanel, "itmExhibition_" .. i, "1800600050", 88 * i - 44 * num - 44, 120, 80, 80, false)
        SetAnchorAndPivot(itmExhibition, UIAnchor.Top, UIAroundPivot.Top)
        GUI.RegisterUIEvent(itmExhibition, UCE.PointerClick, "DiscountWnd", "IconClick")

        if i <= #items then
            if type(items[i]) == "string" then
                GUI.SetData(itmExhibition, "itemKey", items[i])
                if string.find(items[i], "#") then
                    items[i] = string.split(items[i], "#")[1]
                end
            end
            local item = DB.GetOnceItemByKey2(items[i])
            if item then
                local grade = QualityRes[item.Grade]
                GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Border, grade)

                GUI.SetData(itmExhibition, "posX", 88 * i - 44 * num - 44)
                GUI.SetData(itmExhibition, "item", item.Id)
                GUI.SetData(itmExhibition, "type", "item")

                GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Icon, item.Icon)
                GUI.ItemCtrlSetElementRect(itmExhibition, eItemIconElement.Icon,0,-1,68,68)
                GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.RightBottomNum, numbers[i])

                local _item_RightBottom = GUI.ItemCtrlGetElement(itmExhibition, eItemIconElement.RightBottomNum)
                if _item_RightBottom then
                    GUI.SetPositionX(_item_RightBottom, 7)
                    GUI.SetPositionY(_item_RightBottom, 5)
                    GUI.StaticSetFontSize(_item_RightBottom, 20)
                    GUI.SetIsOutLine(_item_RightBottom, true)
                    GUI.SetOutLine_Color(_item_RightBottom, Color.New(0 / 255, 0 / 255, 0 / 255, 255 / 255))
                    GUI.SetOutLine_Distance(_item_RightBottom, 1)
                    GUI.SetColor(_item_RightBottom, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
                end
            else
                DiscountWnd.CloseWnd()
            end
        else
            local pet = DB.GetOncePetByKey2(pets[i - #items])
            local grade = tonumber(pet.Type)
            GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Border, (QualityRes[grade] or "1800400330"))
            GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Icon, tostring(pet.Head))
            GUI.ItemCtrlSetElementRect(itmExhibition, eItemIconElement.Icon,0,-1,68,68)
            local wnd = GUI.GetChild(itmExhibition, "item_Icon")
            if wnd ~= 0 then
                GUI.SetScale(wnd, Vector3.New(0.88, 0.88, 0.88))
                GUI.SetPositionY(wnd, -1.5)
            end
            GUI.ItemCtrlSetIconGray(itmExhibition, false)

            GUI.SetData(itmExhibition, "type", "pet")
            GUI.SetData(itmExhibition, "PetKeyName",pet.KeyName)
            --GUI.SetData(itmExhibition, "info", pet.KeyName .. "," .. (i - #items))
        end
    end
    local btnClose = GuidCacheUtil.GetUI("btnClose")
    GUI.SetVisible(btnClose, true)
end

function DiscountWnd.IconClick(guid)
    local bgPanel = GuidCacheUtil.GetUI("bgPanel")
    local item_bg = GUI.GetByGuid(guid)
    local types = GUI.GetData(item_bg, "type")
    if types == "item" then
        local item = GUI.GetData(item_bg, "itemKey")
        if item then
            local posX = tonumber(GUI.GetData(item_bg, "posX")) - math.floor(GUI.GetWidth(bgPanel) / 2) - 54
            local posY = 0
            local tips = Tips.CreateByItemKeyName(item, bgPanel, "itemTips", posX + 300, posY)
        end
    elseif types == "pet" then
        --CL.SendNotify(NOTIFY.SubmitForm, "Discount", "InquirePetData", GUI.GetData(item_bg, "info"));
        CL.SendNotify(NOTIFY.SubmitForm,"FormPet","QueryPetByKeyName",tostring(GUI.GetData(item_bg, "PetKeyName")))
    end
end

function DiscountWnd.TimeCallBack()
    if DiscountWnd then
        if SurplusTime then
            if SurplusTime >= 0 then
                local surp = SurplusTime
                local Days = math.floor(surp / (3600 * 24))
                surp = surp - Days * 3600 * 24
                local Hours = math.floor(surp / 3600)
                surp = surp - Hours * 3600
                local Mins = math.floor(surp / 60)
                surp = surp - Mins * 60
                local Secs = surp
                local str = "购买剩余时间：<color=#32CD32>"
                if Days > 0 then
                    str = str .. Days .. "天"
                end
                str = str .. (Hours < 10 and "0" or "") .. Hours .. ":" .. (Mins < 10 and "0" or "") .. Mins .. ":" .. (Secs < 10 and "0" or "") .. Secs .. "</color>"
                local txt = GuidCacheUtil.GetUI("txtTimes")
                if txt then
                    GUI.StaticSetText(txt, str)
                end
                SurplusTime = SurplusTime - 1
            else
                DiscountWnd.btnClose_OnClick()
            end
        end
    end
end