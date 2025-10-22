OneKeyPurchaseUI = {}
OneKeyPurchaseUI.ItemIDList = {}
OneKeyPurchaseUI.ItemNumList = {}
OneKeyPurchaseUI.CostIngotNum = 0
OneKeyPurchaseUI.ScrollNode = nil
OneKeyPurchaseUI.EndFunc = nil
OneKeyPurchaseUI.PanelBg = nil
OneKeyPurchaseUI.ItemBuyListStrs = ""
OneKeyPurchaseUI.MAX_ITEM_NUM = 1
local _gt = UILayout.NewGUIDUtilTable()

function OneKeyPurchaseUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()

    local panel = GUI.WndCreateWnd("OneKeyPurchaseUI", "OneKeyPurchaseUI", 0, 0, eCanvasGroup.Normal)
    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)
    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "一键购买", 580, 380)
    OneKeyPurchaseUI.PanelBg = panelBg
    -- 右侧关闭按钮
    local closeBtn = GUI.GetChild(panelBg, "closeBtn", false)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "OneKeyPurchaseUI", "OnCloseBtnClick")

    local tipText = GUI.CreateStatic(panelBg, "TipText", "以下材料可以快捷购买", 0, -119, 500, 35)
    UILayout.SetSameAnchorAndPivot(tipText, UILayout.Center)
    GUI.StaticSetAlignment(tipText, TextAnchor.MiddleCenter)

    UILayout.StaticSetFontSizeColorAlignment(tipText, UIDefine.FontSizeS, UIDefine.RedColor, nil)

    local contentBg = GUI.ImageCreate(panelBg, "ContentBg", "1800300040", 0, -30, false, 536, 145)
    UILayout.SetSameAnchorAndPivot(contentBg, UILayout.Center)

    OneKeyPurchaseUI.ScrollNode = GUI.ScrollRectCreate( panelBg, "scroll", 0, -26, 480, 112, 0, true, Vector2.New(80,80), UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(OneKeyPurchaseUI.ScrollNode, Vector2.New(40, 0))

    local costLabel = GUI.CreateStatic(panelBg, "CostLabel", "需要花费", -140, 85, 100, 30)
    UILayout.StaticSetFontSizeColorAlignment(costLabel, 22, UIDefine.BrownColor, nil)
    UILayout.SetSameAnchorAndPivot(costLabel, UILayout.Center)

    local costBg = GUI.ImageCreate(panelBg, "CostBg", "1800700010", 50, 85, false, 260, 35)
    local coinIcon = GUI.ImageCreate(costBg, "CoinIcon", "1800408250", 5, -1, false, 35, 35)
    UILayout.SetSameAnchorAndPivot(coinIcon, UILayout.Left)

    local costNum = GUI.CreateStatic(costBg, "CostNum", "0", 15, 0, 230, 35)
    _gt.BindName(costNum, "CostNum")
    UILayout.SetSameAnchorAndPivot(costNum, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(costNum, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

    --购买按钮
    local buyBtn = GUI.ButtonCreate(panelBg, "BuyBtn", "1800402080", -220, -25, Transition.ColorTint, "确定购买", 135, 46, false)
    GUI.SetEventCD(buyBtn,UCE.PointerClick, 1)
    UILayout.SetSameAnchorAndPivot(buyBtn, UILayout.BottomRight)
    GUI.ButtonSetTextFontSize(buyBtn, UIDefine.FontSizeL)
    GUI.ButtonSetTextColor(buyBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(buyBtn, true)
    GUI.SetOutLine_Color(buyBtn, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(buyBtn, 1)
    GUI.RegisterUIEvent(buyBtn, UCE.PointerClick, "OneKeyPurchaseUI", "OnClickBuy")
end

function OneKeyPurchaseUI.OnShow(parameter)
    OneKeyPurchaseUI.RefreshPanel(parameter)
end

function OneKeyPurchaseUI.RefreshPanel(parameter)
    if parameter == nil then
        return
    end
    local vals = string.split(parameter, ";")
    if #vals ~= 2 then
        return
    end

    OneKeyPurchaseUI.ItemIDList = {}
    OneKeyPurchaseUI.ItemNumList = {}
    OneKeyPurchaseUI.CostIngotNum = tonumber(vals[1])

    local list = string.split(vals[2], ",")
    local count = #list
    if count == 0 or count%2 ~= 0 then
        print("OneKeyPurchaseUI parameter 异常 ！数据为空或者键值不成对："..tostring(parameter))
        return
    end
    count = count / 2

    for i = 1, OneKeyPurchaseUI.MAX_ITEM_NUM do
        local item = _gt.GetUI("item"..i)
        if item ~= nil then
            GUI.SetVisible(item, false)
        end
    end

    if OneKeyPurchaseUI.MAX_ITEM_NUM < count then
        OneKeyPurchaseUI.MAX_ITEM_NUM = count
    end

    for i = 1, count do
        local item = _gt.GetUI("item"..i)
        if item == nil then
            item = ItemIcon.Create(OneKeyPurchaseUI.ScrollNode, "item"..i,  0, 0, 0, 0)
            _gt.BindName(item, "item"..i)
            local name = GUI.CreateStatic(item, "name", "材料", 0, 58, 250, 30)
            UILayout.StaticSetFontSizeColorAlignment(name, UIDefine.FontSizeS, UIDefine.BrownColor, TextAnchor.MiddleCenter)
            UILayout.SetSameAnchorAndPivot(name, UILayout.Center)
            GUI.RegisterUIEvent(item, UCE.PointerClick, "OneKeyPurchaseUI", "OnItemBgClick")

            local Count = GUI.CreateStatic( item,"Count", "99", -10, -8, 80, 25)
            GUI.StaticSetFontSize(Count, UIDefine.FontSizeSS)
            GUI.StaticSetAlignment(Count, TextAnchor.LowerRight)
            GUI.SetIsOutLine(Count, true)
            GUI.SetOutLine_Color(Count, Color.New(0/255,0/255,0/255,255/255))
            GUI.SetOutLine_Distance(Count, 1)
            GUI.SetColor(Count, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
            UILayout.SetSameAnchorAndPivot(Count, UILayout.BottomRight)
        else
            GUI.SetVisible(item, true)
        end
    end

    OneKeyPurchaseUI.ItemBuyListStrs = ""
    local strTab = {}
    local numIndex = 0
    for i = 1, count do
        local itemId = tonumber(list[(i-1)*2+1])
        local needCount = tonumber(list[i*2])
        local itemData = DB.GetOnceItemByKey1(itemId)
        if itemData then
            if needCount > 0 then
                numIndex = numIndex + 1
                OneKeyPurchaseUI.ItemIDList[numIndex] = itemId
                OneKeyPurchaseUI.ItemNumList[numIndex] = needCount
                strTab[#strTab + 1] = itemId
                strTab[#strTab + 1] = needCount
                local item = _gt.GetUI("item"..numIndex)
                GUI.SetData(item, "ItemIndex", numIndex)
                ItemIcon.BindItemDB(item, itemData)
                local CountItem = GUI.GetChild(item, "Count")
                if CountItem then
                    GUI.StaticSetText(CountItem, tonumber(needCount))
                end
                local name = GUI.GetChild(item, "name")
                GUI.StaticSetText(name, itemData.Name)
            else
                print("---> 传的道具个数为0，已忽略此道具："..itemData.Name.."("..itemData.Id..")")
            end
        end
    end
    if numIndex > 0 then
        OneKeyPurchaseUI.ItemBuyListStrs = table.concat(strTab, ",")
    end
    local costNum = _gt.GetUI("CostNum")
    if costNum then
        GUI.StaticSetText(costNum, tostring(OneKeyPurchaseUI.CostIngotNum))
    end
    for i = 1, count do
        local item = _gt.GetUI("item"..i)
        if item ~= nil then
            GUI.SetVisible(item, i <= numIndex and true or false)
        end
    end
    --设置到初始位置
    if OneKeyPurchaseUI.ScrollNode ~= nil then
        GUI.ScrollRectSetNormalizedPosition(OneKeyPurchaseUI.ScrollNode, Vector2.New(0,0))
    end
end

function OneKeyPurchaseUI.OnCloseBtnClick()
    GUI.DestroyWnd("OneKeyPurchaseUI")
end

function OneKeyPurchaseUI.OnItemBgClick(guid)
    local itemBg = GUI.GetByGuid(guid)
    local itemIndex = tonumber(GUI.GetData(itemBg, "ItemIndex"))
    local itemId = OneKeyPurchaseUI.ItemIDList[itemIndex]

    local tips = GUI.GetChild(OneKeyPurchaseUI.PanelBg, "tips")
    if tips ~= nil then
        GUI.Destroy(tips)
    end
    tips = Tips.CreateByItemId(itemId, OneKeyPurchaseUI.PanelBg, "tips", 440, 0, 0)
end

function OneKeyPurchaseUI.OnClickBuy()
    if OneKeyPurchaseUI.ItemBuyListStrs == nil or string.len(OneKeyPurchaseUI.ItemBuyListStrs) == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "购买道具为空")
        return
    end

    local ingotNum = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrIngot)))
    if ingotNum < OneKeyPurchaseUI.CostIngotNum then
        CL.SendNotify(NOTIFY.ShowBBMsg, "元宝不足，无法购买")
        return
    end

    --执行购买
    CL.SendNotify(NOTIFY.SubmitForm, "FormOneKeyBuy", "Main")
end