local RewardProbabilityUI = {}
_G.RewardProbabilityUI = RewardProbabilityUI
local _gt = UILayout.NewGUIDUtilTable()
function RewardProbabilityUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    local _Panel = GUI.WndCreateWnd("RewardProbabilityUI", "RewardProbabilityUI", 0, 0, eCanvasGroup.Normal)
    local _PanelCover = GUI.ImageCreate(_Panel, "PanelCover", "1800001060", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
    UILayout.SetAnchorAndPivot(_PanelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(_PanelCover, true)
    _PanelCover:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(_PanelCover, UCE.PointerClick, "RewardProbabilityUI", "OnCloseWnd")
    _gt.BindName(_PanelCover,"panelCover")
end

function RewardProbabilityUI.OnCloseWnd()
    GUI.CloseWnd("RewardProbabilityUI")
end

function RewardProbabilityUI.CreateRewardProbability()
    local panelCover = _gt.GetUI("panelCover")
    local hintBg = GUI.GetChild(panelCover,"hintBg")
    if hintBg then
        GUI.Destroy(hintBg)
    end
    hintBg = GUI.ImageCreate(panelCover, "hintBg", "1800400290", 0, 0, false, 200, 300)
    GUI.SetIsRaycastTarget(hintBg, true)
    hintBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(hintBg, UCE.PointerClick, "RewardProbabilityUI", "OnCloseWnd")
end

function RewardProbabilityUI.OnShow()
    local wnd = GUI.GetWnd("RewardProbabilityUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd,true)
end

function RewardProbabilityUI.RefreshUI()
    RewardProbabilityUI.CreateRewardProbability()
    local panelCover = _gt.GetUI("panelCover")
    local hintBg = GUI.GetChild(panelCover,"hintBg")
    local TipsText = GUI.CreateStatic(hintBg, "TipsText", RewardProbabilityUI.ServerData.Tips, 20, 15, 200, 0, "system")
    GUI.SetColor(TipsText, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(TipsText, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(TipsText, UILayout.TopLeft)

    local w = GUI.StaticGetLabelPreferWidth(TipsText)
    GUI.SetWidth(TipsText, w)
    local h = GUI.StaticGetLabelPreferHeight(TipsText)
    GUI.SetHeight(TipsText, h)

    local NameTitleText = GUI.CreateStatic(hintBg, "NameTitleText", "可获得物品", 50, 65, 200, 30, "system")
    GUI.SetColor(NameTitleText, UIDefine.Brown2Color)
    GUI.StaticSetFontSize(NameTitleText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(NameTitleText, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(NameTitleText, UILayout.TopLeft)

    local ValueTitleText = GUI.CreateStatic(hintBg, "ValueTitleText", "获得概率", 300, 65, 200, 30, "system")
    GUI.SetColor(ValueTitleText, UIDefine.Brown2Color)
    GUI.StaticSetFontSize(ValueTitleText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(ValueTitleText, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(ValueTitleText, UILayout.TopLeft)

    local cutLine1 = GUI.ImageCreate(hintBg,"cutLine1" ,"1800600030",-5, 100,false,550,3);
    UILayout.SetSameAnchorAndPivot(cutLine1, UILayout.TopLeft)

    h = h + 80

    local itemInfoScroll = GUI.ScrollRectCreate(hintBg,"itemInfoScroll", 20, h, w + 80, 330,
            0, false, Vector2.New(w + 80, 320), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    UILayout.SetSameAnchorAndPivot(itemInfoScroll, UILayout.TopLeft)

    local itemInfoDesc = GUI.CreateStatic(itemInfoScroll, "itemInfoDesc", "", 0, 0, w + 80, 280, "system")

    local descHeight = 0
    for i = 1, #RewardProbabilityUI.ServerData.Show do
        local ItemInfo = RewardProbabilityUI.ServerData.Show[i]
        for Name, Value in pairs(ItemInfo) do
            local ItemInfoBg = GUI.ImageCreate(itemInfoDesc, "ItemInfoBg" .. i, "1800600840", 0, descHeight + 10, false, w + 80, 40)
            GUI.SetColor(ItemInfoBg, Color.New(1, 1, 1, 0.5))
            GUI.SetVisible(ItemInfoBg,i % 2 == 1)

            local ItemNameText = GUI.CreateStatic(itemInfoDesc, "ItemNameText" .. i, Name, 30, descHeight + 15, 200, 30, "system")
            GUI.SetColor(ItemNameText, UIDefine.WhiteColor)
            GUI.StaticSetFontSize(ItemNameText, UIDefine.FontSizeM)
            GUI.StaticSetAlignment(ItemNameText, TextAnchor.MiddleCenter)

            local ItemValueText = GUI.CreateStatic(itemInfoDesc, "ItemValueText" .. i, Value, 280, descHeight + 15 , 200, 30, "system")
            GUI.SetColor(ItemValueText, UIDefine.WhiteColor)
            GUI.StaticSetFontSize(ItemValueText, UIDefine.FontSizeM)
            GUI.StaticSetAlignment(ItemValueText, TextAnchor.MiddleCenter)

            descHeight = descHeight + 40
        end
    end
    GUI.SetHeight(itemInfoDesc, descHeight)
    GUI.ScrollRectSetChildSize(itemInfoScroll, Vector2.New(w + 80, descHeight))
    h = h + 280

    -- local cutLine2 = GUI.ImageCreate(hintBg,"cutLine2" ,"1800600030",-5, h + 15,false,550,3);
    -- UILayout.SetSameAnchorAndPivot(cutLine2, UILayout.TopLeft)

    -- local tipsIcon = GUI.ImageCreate(hintBg,"cutLine2" ,"1800702030",20, h + 25,false,30,30);
    -- UILayout.SetSameAnchorAndPivot(tipsIcon, UILayout.TopLeft)

    -- local TipsEndText = GUI.CreateStatic(hintBg, "TipsEndText", "以上概率为非祈福状态，祈福奖励会提升概率", 60, h + 25, w + 100, 30, "system")
    -- GUI.SetColor(TipsEndText, UIDefine.Brown2Color)
    -- GUI.StaticSetFontSize(TipsEndText, UIDefine.FontSizeS)
    -- GUI.StaticSetAlignment(TipsEndText, TextAnchor.MiddleLeft)
    -- UILayout.SetSameAnchorAndPivot(TipsEndText, UILayout.TopLeft)
    
    GUI.SetWidth(hintBg, w + 100)
    GUI.SetHeight(hintBg, h + 75)
end