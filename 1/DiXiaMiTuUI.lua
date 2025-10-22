-- 这是地下迷途活动的UI
DiXiaMiTuUI = {}

_G.DiXiaMiTuUI = DiXiaMiTuUI
local _gt = UILayout.NewGUIDUtilTable()

local BtnList = {
    { "探险道具", "activeSubTabBtn" , "1800402030", "1800402032", "OnActiveSubTabBtnClick" , 160, -216, 135, 40, 100, 35 },
    { "状态", "buffSubTabBtn", "1800402030", "1800402032", "OnPassiveSubTabBtnClick", 292, -216, 135, 40, 100, 35 },
    { "宝藏", "collectSubTabBtn", "1800402030", "1800402032", "OnCollectSubTabBtnClick", 420, -216, 135, 40, 100, 35 }
}
local Bag = {"ActItem", "Buff", "CollectItem"}

local MineBoxMax    = 0     -- 记录生成过的最大矿石按钮数量
local BagPage       = 1     -- 当前背包的页签位置
local ShopItemIndex         -- 商店页面当前选中的index
local TalkStr
local TalkIndex
local TalkByte
local ChangeNum
local ChangeIndex
local BagMaxNum     = 40    -- 背包格子数量，不够再加
local HeartMax      = 0     -- 记录生成过的最多血量图标
local NowUseKeyName = ""

function DiXiaMiTuUI.Main()

    DiXiaMiTuUI.InitData()

    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("DiXiaMiTuUI","DiXiaMiTuUI", 0, 0, eCanvasGroup.Normal)
    UILayout.SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)

    local panelBg = UILayout.CreateFrame_WndStyle0(panel,"地下迷途","DiXiaMiTuUI","OnExit", _gt)
    GUI.SetVisible(panel, true)
    _gt.BindName(panelBg, "panelBg")

    local hintBtn = GUI.ButtonCreate(panelBg, "hintBtn", "1800702030", 13, -65, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(hintBtn, UILayout.Bottom, UIAroundPivot.Bottom)
    GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "DiXiaMiTuUI", "OnHintBtnClick")

    -- 左侧标题背景
    local title = GUI.ImageCreate(panelBg, "title", "1800601010", 170, 74, false, 300, 60)
    UILayout.SetAnchorAndPivot(title, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 左侧标题
    local titleTxt = GUI.CreateStatic(title, "titleTxt", "地下一层", 0, 0, 300, 50)
    DiXiaMiTuUI.SetStatic(titleTxt)

    -- 左侧矿物框的背景
    local mineBg = GUI.ImageCreate(panelBg, "mineBg", "1800400350", 80, -40, false, 480, 480)
    UILayout.SetAnchorAndPivot(mineBg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)

    -- 当前使用的道具
    local prop = ItemIcon.Create(panelBg, "prop", 10, -150, 80, 80)
    GUI.RegisterUIEvent(prop, UCE.PointerClick, "DiXiaMiTuUI", "OnPropClick")
    UILayout.SetAnchorAndPivot(prop, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(prop, "prop")

    -- 道具框上的酷炫特效
    local effect = GUI.RichEditCreate(prop, "effect", "", 1, 22, 160, 185)
    UILayout.SetAnchorAndPivot(effect, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(effect, false)
    GUI.SetScale(effect, Vector3.New(0.75, 0.75, 0.75))
    GUI.StaticSetText(effect, "#IMAGE3407700000#")

    -- 这个heartGroup是给后面的CreateHeart方法用的
    GUI.GroupCreate(panelBg, "heartGroup", 0, 0, 600, 600)

    -- 创建右侧背包
    DiXiaMiTuUI.CreateBagPage(panelBg)

    local dateBtn = GUI.ButtonCreate(panelBg, "dateBtn", "1800002010", -18, -216, Transition.ColorTint, "探险日志", 135, 40, false)
    DiXiaMiTuUI.SetButton(dateBtn, "DateBtnClick", UIAnchor.Center, UIAroundPivot.Center)

    -- 商店按钮
    local shopBtn = GUI.ButtonCreate(panelBg, "shopBtn", "1800202150", -155, -55, Transition.ColorTint, "", 85, 85, false)
    DiXiaMiTuUI.SetButton(shopBtn, "ShopBtnClick", UIAnchor.BottomRight, UIAroundPivot.BottomRight)

    local shopBtnTxt = GUI.CreateStatic(shopBtn, "shopBtnTxt", "土地的宝物店", 0, -10, 140, 40)
    DiXiaMiTuUI.SetStatic(shopBtnTxt, UIAnchor.Bottom, UIAroundPivot.Bottom, 22, TextAnchor.MiddleCenter, true)

    -- 排行榜按钮
    local rankBtn = GUI.ButtonCreate(panelBg, "rankBtn", "1800002010", 80, 94, Transition.ColorTint, "排行榜", 85, 40, false)
    DiXiaMiTuUI.SetButton(rankBtn, "RankBtnClick", UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local runBtn = GUI.ButtonCreate(panelBg, "runBtn", "1800102090", -320, -55, Transition.ColorTint, "提前结算", 180, 65, false)
    DiXiaMiTuUI.SetButton(runBtn, "RefreshUploadPage", UIAnchor.BottomRight, UIAroundPivot.BottomRight)

    -- 回到矿井按钮
    local backBtn = GUI.ButtonCreate(panelBg, "backBtn", "1800102090", -80, -70, Transition.ColorTint, "回到矿井", 180, 65, false)
    DiXiaMiTuUI.SetButton(backBtn, "ShopBtnClick", UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetVisible(backBtn, false)

    -- 创建商店页面
    DiXiaMiTuUI.CreateShopPage(panelBg)
end

function DiXiaMiTuUI.OnShow()
    local wnd = GUI.GetWnd("DiXiaMiTuUI")
    if wnd then
        GUI.SetVisible(wnd, true)
    end

    if _gt.GetUI("uploadBg") ~= nil then
        DiXiaMiTuUI.UploadClose()
    end

    DiXiaMiTuUI.GetData()
end

-- 初始化全局变量
function DiXiaMiTuUI.InitData()
    MineBoxMax    = 0
    BagPage       = 1
    ShopItemIndex = 0
    TalkStr       = ""
    TalkIndex     = 1
    TalkByte      = 1
    ChangeNum     = 0
    ChangeIndex   = 1
    HeartMax      = 0
    NowUseKeyName = ""
end

-- 向服务器发起请求，回调Refresh方法
function DiXiaMiTuUI.GetData()
    DiXiaMiTuUI["show_data"] = {}
    --test("start get data form server")
    CL.SendNotify(NOTIFY.SubmitForm, "FormDiXiaMiTu", "GetData")
end

-- 做一些数据的整理
function DiXiaMiTuUI.ResetData()
    --test("start reset data")
    DiXiaMiTuUI["show_data"]["AllActShop"] = {}
    DiXiaMiTuUI.InsertTable("CollectItem", "ActItem", "Item")
    DiXiaMiTuUI.InsertTable2("ActItem", "CollectItem", "Buff")
end

-- 把服务器的表整合为一个表，主要是为了滚动列表那边方便
function DiXiaMiTuUI.InsertTable(...)
    for _, v in pairs({...}) do
        for _, y in pairs(DiXiaMiTuUI["show_data"]["ActShop"][v]) do
            y["selectNum"] = 0
            y["key"] = v
            table.insert(DiXiaMiTuUI["show_data"]["AllActShop"], y)
        end
    end
end

function DiXiaMiTuUI.InsertTable2(...)
    for _, v in pairs({...}) do
        DiXiaMiTuUI["show_data"][v..2] = {}
        for k, y in pairs(DiXiaMiTuUI["show_data"][v]) do
            if y > 0 then
                table.insert(DiXiaMiTuUI["show_data"][v..2], {
                    ["keyName"]   = k,
                    ["selectNum"] = 0,
                })
            end
        end
    end
end

-- GetData服务器回调
function DiXiaMiTuUI.Refresh()
    --test("get server data start refresh")
    local panelBg    = _gt.GetUI("panelBg")
    local mineBg     = GUI.GetChild(panelBg, "mineBg"    , false)
    local heartGroup = GUI.GetChild(panelBg, "heartGroup", false)

    DiXiaMiTuUI.ResetData()

    --local inspect = require("inspect")
    --CDebug.LogError("-------------"..inspect(DiXiaMiTuUI["show_data"]))

    local nowLayerData = DiXiaMiTuUI["show_data"]["LayerList"]["Layer_"..DiXiaMiTuUI["show_data"]["NowLayer"]]

    DiXiaMiTuUI.CreateMineBox(mineBg, nowLayerData["Height"], nowLayerData["Width"])
    DiXiaMiTuUI.SetMineBox(mineBg, nowLayerData["Height"], nowLayerData["Width"])

    DiXiaMiTuUI.CreateHeart(heartGroup, DiXiaMiTuUI["show_data"]["ActMaxBlood"])
    DiXiaMiTuUI.SetHeart(heartGroup, DiXiaMiTuUI["show_data"]["NowBlood"], DiXiaMiTuUI["show_data"]["ActMaxBlood"])

    UILayout.OnSubTabClick(BagPage, BtnList)

    DiXiaMiTuUI.RefreshBagPage()
end

-- 创建背包页面
function DiXiaMiTuUI.CreateBagPage(panelBg)
    local wnd = GUI.GetWnd("DiXiaMiTuUI")
    local bagPage = GUI.GroupCreate(panelBg, "bagPage", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.CreateSubTab(BtnList, bagPage, "DiXiaMiTuUI")

    local bagBg = GUI.ImageCreate(panelBg, "bagBg", "1800400350", -80, 140, false, 460, 360)
    UILayout.SetAnchorAndPivot(bagBg, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local itemScroll = GUI.LoopScrollRectCreate(
            bagBg, "itemScroll",
            10, 10, 440, 340,
            "DiXiaMiTuUI", "CreatItemScroll",
            "DiXiaMiTuUI", "RefreshItemScroll",
            0, false,
            Vector2.New(80, 80),
            5,
            UIAroundPivot.Top, UIAnchor.Top
    )
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(5, 5))
    _gt.BindName(itemScroll, "itemScroll")
end

-- 创建背包滚动列表
function DiXiaMiTuUI.CreatItemScroll()
    local itemScroll =  _gt.GetUI("itemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll)
    local ItemIconBg = ItemIcon.Create(itemScroll,"itemIcon" .. curCount,0,0)
    _gt.BindName(ItemIconBg,"ItemIconBg"..curCount)
    GUI.RegisterUIEvent(ItemIconBg, UCE.PointerClick, "DiXiaMiTuUI", "OnItemClick")
    GUI.ItemCtrlSetElementRect(ItemIconBg, eItemIconElement.RightBottomNum, 7, 5)

    local decreaseBtn = GUI.ButtonCreate(ItemIconBg, "decreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerClick, "DiXiaMiTuUI", "OnBagClickMinusBtn")
    GUI.SetVisible(decreaseBtn, false)
    UILayout.SetSameAnchorAndPivot(decreaseBtn, UILayout.TopRight)

    return ItemIconBg
end

-- 刷新背包滚动列表
function DiXiaMiTuUI.RefreshItemScroll(parameter)

    if DiXiaMiTuUI["show_data"] == nil then return end
    if DiXiaMiTuUI["show_data"][Bag[BagPage]..2] == nil then return end

    parameter      = string.split(parameter, "#")
    local guid     = parameter[1]
    local index    = tonumber(parameter[2])
    local itemIcon = GUI.GetByGuid(guid)

    local decreaseBtn = GUI.GetChild(itemIcon, "decreaseBtn", false)
    GUI.SetVisible(decreaseBtn, false)
    GUI.SetData(decreaseBtn, "index", index)

    if DiXiaMiTuUI["show_data"][Bag[BagPage]..2][index+1] == nil then
        GUI.SetData(itemIcon, "keyName", "")
        GUI.SetData(itemIcon, "index"  , "")
        ItemIcon.SetEmpty(itemIcon)
        return
    end

    local itemKey = DiXiaMiTuUI["show_data"][Bag[BagPage]..2][index+1]["keyName"]
    GUI.SetData(itemIcon, "keyName", itemKey)
    GUI.SetData(itemIcon, "index"  , index)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, DiXiaMiTuUI["show_data"][Bag[BagPage]][itemKey])

    if Bag[BagPage] == "Buff" then
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, DiXiaMiTuUI["show_data"]["TrapAndAltar"][itemKey]["Icon"])
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[DiXiaMiTuUI["show_data"]["TrapAndAltar"][itemKey]["Grade"]])
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, DiXiaMiTuUI["show_data"][Bag[BagPage]][itemKey])
        return
    end
    ItemIcon.BindItemKeyName(itemIcon, itemKey)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, DiXiaMiTuUI["show_data"][Bag[BagPage]][itemKey])
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Selected, 1800600160)
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Selected, 0, 0, 87, 87)

    local panelBg  = _gt.GetUI("panelBg")
    if not GUI.GetVisible(GUI.GetChild(panelBg, "mineBg", false)) then
        DiXiaMiTuUI.RefreshItemScrollForShop(index, itemIcon)
    end
end

-- 矿井页面额外显示的刷新效果
function DiXiaMiTuUI.RefreshItemScrollForShop(index, itemIcon)
    local decreaseBtn = GUI.GetChild(itemIcon, "decreaseBtn", false)
    local itemData = DiXiaMiTuUI["show_data"][Bag[BagPage]..2][index+1]

    if itemData["selectNum"] > 0 then
        GUI.SetVisible(decreaseBtn, true)
        GUI.ItemCtrlSelect(itemIcon)
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, itemData["selectNum"] .. "/" ..DiXiaMiTuUI["show_data"][Bag[BagPage]][itemData["keyName"]])
    else
        GUI.SetVisible(decreaseBtn, false)
        GUI.ItemCtrlUnSelect(itemIcon)
    end
end

-- 刷新矿井部分
function DiXiaMiTuUI.RefreshBagPage()
    local panelBg    = _gt.GetUI("panelBg")
    local itemScroll =  _gt.GetUI("itemScroll")
    local shopBtn    = GUI.GetChild(panelBg, "shopBtn"   , false)
    local backBtn    = GUI.GetChild(panelBg, "backBtn"   , false)
    local rankBtn    = GUI.GetChild(panelBg, "rankBtn"   , false)
    local runBtn     = GUI.GetChild(panelBg, "runBtn"    , false)
    local hintBtn    = GUI.GetChild(panelBg, "hintBtn"   , false)
    local dateBtn    = GUI.GetChild(panelBg, "dateBtn"   , false)
    local title      = GUI.GetChild(panelBg, "title"     , false)
    local titleTxt   = GUI.GetChild(title  , "titleTxt"  , false)
    local mineBg     = GUI.GetChild(panelBg, "mineBg"    , false)
    local prop       = GUI.GetChild(panelBg, "prop"      , false)
    local shopBg     = GUI.GetChild(panelBg, "shopBg"    , false)
    local heartGroup = GUI.GetChild(panelBg, "heartGroup", false)
    local buyBtn     = GUI.GetChild(panelBg, "buyBtn"    , false)
    GUI.SetVisible(mineBg    , true)
    GUI.SetVisible(prop      , true)
    GUI.SetVisible(heartGroup, true)
    GUI.SetVisible(rankBtn   , true)
    GUI.SetVisible(runBtn    , true)
    GUI.SetVisible(hintBtn   , true)
    GUI.SetVisible(dateBtn   , true)
    GUI.SetVisible(shopBtn   , true)
    GUI.SetVisible(backBtn   , false)
    GUI.SetVisible(shopBg    , false)
    GUI.SetVisible(buyBtn    , false)

    GUI.SetPositionX(title, 170)
    GUI.StaticSetText(titleTxt, DiXiaMiTuUI["show_data"]["LayerList"]["Layer_"..DiXiaMiTuUI["show_data"]["NowLayer"]]["Title"])

    GUI.ButtonSetText(runBtn, DiXiaMiTuUI["show_data"]["PassLayer"] == DiXiaMiTuUI["show_data"]["NowLayer"] and "通关结算" or "提前结算")

    GUI.LoopScrollRectSetTotalCount(itemScroll, BagMaxNum)
    GUI.LoopScrollRectRefreshCells(itemScroll)

    local buffSubTabBtn = GUI.GetChild(GUI.GetChild(panelBg, "bagPage", false), "buffSubTabBtn", false)
    GUI.SetVisible(buffSubTabBtn, true)

    DiXiaMiTuUI.RefreshUseItem(NowUseKeyName)
end

-- 主动页签点击
function DiXiaMiTuUI.OnActiveSubTabBtnClick()
    local itemScroll =  _gt.GetUI("itemScroll")
    BagPage = 1
    GUI.LoopScrollRectRefreshCells(itemScroll)
    DiXiaMiTuUI.RefreshShopPre()
end

-- 被动页签点击
function DiXiaMiTuUI.OnPassiveSubTabBtnClick()
    local itemScroll =  _gt.GetUI("itemScroll")
    BagPage = 2
    GUI.LoopScrollRectRefreshCells(itemScroll)
    DiXiaMiTuUI.RefreshShopPre()
end

-- 收藏页签点击
function DiXiaMiTuUI.OnCollectSubTabBtnClick()
    local itemScroll =  _gt.GetUI("itemScroll")
    BagPage = 3
    GUI.LoopScrollRectRefreshCells(itemScroll)
    DiXiaMiTuUI.RefreshShopPre()
end

-- 点击事件：右边背包里的道具
function DiXiaMiTuUI.OnItemClick(guid)
    local item    = GUI.GetByGuid(guid)
    local keyName = tostring(GUI.GetData(item, "keyName"))
    local panelBg = _gt.GetUI("panelBg")
    if GUI.GetVisible(GUI.GetChild(panelBg, "mineBg", false)) then
        DiXiaMiTuUI.CreateTips(panelBg, keyName)
    else
        DiXiaMiTuUI.ShopBagClick(item)
    end
end

function DiXiaMiTuUI.OnPropClick()
    if NowUseKeyName == nil or NowUseKeyName == "" then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中一个道具")
        return
    end
    local panelBg  = _gt.GetUI("panelBg")
    local itemTips = Tips.CreateByItemKeyName(NowUseKeyName, panelBg, "itemTips", -120, -20, 40)
    local useBtn   = GUI.ButtonCreate(itemTips, "useBtn", "1800402110", 0, -10, Transition.ColorTint, "卸下", 150, 50, false)
    DiXiaMiTuUI.SetButton(useBtn, "OnUnUseBtnClick", UIAnchor.Bottom, UIAroundPivot.Bottom, UIDefine.FontSizeL, UIDefine.BrownColor, false)
end

-- 创建tips
function DiXiaMiTuUI.CreateTips(panelBg, keyName)
    if keyName == nil or keyName == "" then return end
    if BagPage == 1 then
        local itemTips = Tips.CreateByItemKeyName(keyName, panelBg, "itemTips", -120, -20, 40)
        local useBtn   = GUI.ButtonCreate(itemTips, "useBtn", "1800402110",0,-10,Transition.ColorTint,"使用", 150, 50, false)
        DiXiaMiTuUI.SetButton(useBtn, "OnUseBtnClick", UIAnchor.Bottom, UIAroundPivot.Bottom, UIDefine.FontSizeL, UIDefine.BrownColor, false)
        GUI.SetData(useBtn, "keyName", keyName)
        GUI.AddWhiteName(itemTips, GUI.GetGuid(useBtn))
    elseif BagPage == 2 then
        local itemTips = GUI.ItemTipsCreate(panelBg, "itemTips", -120, -20, 0)
        local itemIcon = GUI.TipsGetItemIcon(itemTips)
        local data     = DiXiaMiTuUI["show_data"]["TrapAndAltar"][keyName]
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, data["Icon"])
        GUI.SetIsRemoveWhenClick(itemTips, true)
        GUI.ItemTipsSetItemName(itemTips, data["Name"], UIDefine.GradeColor[data["Grade"]])
        GUI.ItemTipsSetItemType(itemTips, "类型：Buff", UIDefine.YellowColor)
        GUI.ItemTipsSetItemLevel(itemTips, "剩余持续时间："..DiXiaMiTuUI["show_data"][Bag[BagPage]][keyName], UIDefine.YellowColor)
        GUI.ItemTipsSetItemLimit(itemTips, "", UIDefine.RedColor)
        GUI.TipsAddLabel(itemTips, 20, "效果：", UIDefine.Yellow3Color, false)
        GUI.TipsAddLabel(itemTips, 20, data["Info"], UIDefine.WhiteColor, false)
        Tips.DeleteItemShowLevel(itemTips)
        GUI.TipsAddCutLine(itemTips)
    else
        Tips.CreateByItemKeyName(keyName, panelBg, "itemTips", -120, -20, 0)
    end
end

-- 点击事件：点击使用按钮
function DiXiaMiTuUI.OnUseBtnClick(guid)
    local db = DB.GetOnceItemByKey2(GUI.GetData(GUI.GetByGuid(guid), "keyName"))
    if db.ShowType == "挖掘道具" then
        NowUseKeyName = db.KeyName
        DiXiaMiTuUI.RefreshUseItem(db.KeyName)
        CL.SendNotify(NOTIFY.ShowBBMsg, "已装备：" .. db.Name)
    elseif db.ShowType == "回复道具" then
        CL.SendNotify(NOTIFY.SubmitForm, "FormDiXiaMiTu", "UseItem", db.KeyName)
    end
    GUI.Destroy(GUI.GetParentElement(GUI.GetByGuid(guid)))
end

function DiXiaMiTuUI.OnUnUseBtnClick()
    NowUseKeyName = ""
    ItemIcon.SetEmpty(_gt.GetUI("prop"))
end

function DiXiaMiTuUI.RefreshUseItem(keyName)
    local panelBg = _gt.GetUI("panelBg")
    local prop    = GUI.GetChild(panelBg, "prop", false)

    if keyName == nil or keyName == "" or DiXiaMiTuUI["show_data"]["ActItem"][keyName] == nil or DiXiaMiTuUI["show_data"]["ActItem"][keyName] <= 0 then
		NowUseKeyName = ""
        ItemIcon.SetEmpty(prop)
        return
    end

    ItemIcon.BindItemKeyName(prop, keyName)
    GUI.ItemCtrlSetElementValue(prop, eItemIconElement.RightBottomNum, DiXiaMiTuUI["show_data"]["ActItem"][keyName])
end

-- 点击事件：点这个按钮来选择显示矿脉和商店这两块部分
function DiXiaMiTuUI.ShopBtnClick()
    local panelBg    = _gt.GetUI("panelBg")

    -- 获取当前矿脉背景的状态
    local flag = GUI.GetVisible(GUI.GetChild(panelBg, "mineBg", false))
    if flag then
        DiXiaMiTuUI.RefreshShopPage()
    else
        DiXiaMiTuUI.RefreshBagPage()
    end
end

-- 点击事件：点击打开排行榜
function DiXiaMiTuUI.RankBtnClick()
    GUI.OpenWnd("RankUI", "4,7")
end

-- 创建商店页面
function DiXiaMiTuUI.CreateShopPage(panelBg)
    local shopBg = GUI.ImageCreate(panelBg, "shopBg", "1800400350", 80, 140, false, 560, 360)
    UILayout.SetAnchorAndPivot(shopBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(shopBg, false)
    
    local shopScroll = GUI.LoopScrollRectCreate(
            shopBg, "shopScroll",
            10, 10, 540, 340,
            "DiXiaMiTuUI", "CreatShopScroll",
            "DiXiaMiTuUI", "RefreshShopScroll",
            0, false,
            Vector2.New(260, 100),
            2,
            UIAroundPivot.Top, UIAnchor.Top
    )
    GUI.ScrollRectSetChildSpacing(shopScroll, Vector2.New(5, 5))
    _gt.BindName(shopScroll, "shopScroll")

    -- 土地头像
    local shopHead = GUI.ImageCreate(shopBg, "shopHead", "1900352040", 0, 80, true)
    UILayout.SetAnchorAndPivot(shopHead, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    GUI.SetIsRaycastTarget(shopHead, true)
    GUI.RegisterUIEvent(shopHead, UCE.PointerClick , "DiXiaMiTuUI", "OnShopHeadClick")

    -- 对话的背景框
    local talkBg = GUI.ImageCreate(shopHead, "talkBg", "1800900020", 0, 0, false, 480, 70)
    UILayout.SetAnchorAndPivot(talkBg, UIAnchor.Right, UIAroundPivot.Left)

    -- 对话内容
    local talkTxt = GUI.CreateStatic(talkBg, "talkTxt", "", 10, 0, 470, 70)
    DiXiaMiTuUI.SetStatic(talkTxt, UIAnchor.Center, UIAroundPivot.Center, 22, TextAnchor.MiddleLeft, false)
    GUI.SetColor(talkTxt, UIDefine.BrownColor)
    _gt.BindName(talkTxt, "talkTxt")

    -- 兑换进度条
    local shopPreView = GUI.ScrollBarCreate(shopBg, "shopPreView","","1800408120","1800408130",40,100,0,0,1,false,Transition.None,0,1,Direction.LeftToRight,false)
    GUI.ScrollBarSetFillSize(shopPreView, Vector2.New(475,26))
    GUI.ScrollBarSetBgSize(shopPreView, Vector2.New(475,26))
    GUI.ScrollBarSetPos(shopPreView, 5/10)
    UILayout.SetAnchorAndPivot(shopPreView, UIAnchor.Bottom, UIAroundPivot.Bottom)
    _gt.BindName(shopPreView,"shopPreView")

    local shopPreTxt = GUI.CreateStatic(shopPreView, "shopPreTxt", "50/100", 0, 0, 420, 26)
    DiXiaMiTuUI.SetStatic(shopPreTxt, UIAnchor.Center, UIAroundPivot.Center, 22)

    -- 购买按钮
    local buyBtn = GUI.ButtonCreate(panelBg, "buyBtn", "1800102090", -340, -70, Transition.ColorTint, "兑换", 180, 65, false)
    DiXiaMiTuUI.SetButton(buyBtn, "BuyBtnClick", UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetVisible(buyBtn, false)
end

-- 创建商品滚动列表
function DiXiaMiTuUI.CreatShopScroll()
    local shopScroll =  _gt.GetUI("shopScroll")
    local curCount   = GUI.LoopScrollRectGetChildInPoolCount(shopScroll)
    local index      = tonumber(curCount) + 1
    local shopItem   = GUI.CheckBoxExCreate(shopScroll, "shopItem" .. index, "1800700030", "1800700040", 0, 0, false, 0, 0)
    GUI.RegisterUIEvent(shopItem, UCE.PointerClick , "DiXiaMiTuUI", "OnShopItemClick")
    _gt.BindName(shopItem, "shopItem" .. index)

    local shopIcon = ItemIcon.Create(shopItem, "shopIcon", 10, 0)
    GUI.RegisterUIEvent(shopIcon, UCE.PointerClick , "DiXiaMiTuUI", "OnShopIconClick")
    UILayout.SetAnchorAndPivot(shopIcon, UIAnchor.Left, UIAroundPivot.Left)

    local decreaseBtn = GUI.ButtonCreate(shopIcon, "decreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerClick, "DiXiaMiTuUI", "OnClickMinusBtn")
    GUI.SetVisible(decreaseBtn, false)
    UILayout.SetSameAnchorAndPivot(decreaseBtn, UILayout.TopRight)

    local shopName = GUI.CreateStatic(shopItem, "shopName", "道具名称", 95, -20, 155, 40)
    DiXiaMiTuUI.SetStatic(shopName, UIAnchor.Left, UIAroundPivot.Center, 24, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(shopName, UILayout.Left)

    UILayout.CreateAttrBar(shopItem,"CoinBg",95,20,155, UILayout.Left)
    local attrBar = GUI.GetChild(shopItem, "CoinBg", false)
    GUI.SetVisible(GUI.GetChild(attrBar, "icon", false), false)
    local priceTxt = GUI.CreateStatic(attrBar, "priceTxt", "价值 |", 5, 0, 155, 35)
    DiXiaMiTuUI.SetStatic(priceTxt, UIAnchor.Left, UIAroundPivot.Left, 20, TextAnchor.MiddleLeft, false)
    GUI.SetColor(priceTxt, UIDefine.White3Color)
    local sellOff = GUI.ImageCreate(shopItem, "sellOff", "1800404070", 0, 40, true)
    UILayout.SetAnchorAndPivot(sellOff, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetEulerAngles(sellOff, Vector3.New(0, 0, -45))
    GUI.SetVisible(sellOff, false)
    return shopItem
end

-- 刷新商品滚动列表
function DiXiaMiTuUI.RefreshShopScroll(parameter)
    parameter      = string.split(parameter, "#")
    local guid     = parameter[1]
    local index    = tonumber(parameter[2])
    local shopItem = GUI.GetByGuid(guid)
    local data     = DiXiaMiTuUI["show_data"]["AllActShop"][index + 1]

    GUI.SetData(shopItem, "index", index)

    local shopIcon    = GUI.GetChild(shopItem, "shopIcon"   , false)
    local decreaseBtn = GUI.GetChild(shopIcon, "decreaseBtn", false)
    local shopName    = GUI.GetChild(shopItem, "shopName"   , false)
    local attrBar     = GUI.GetChild(shopItem, "CoinBg"     , false)
    local sellOff     = GUI.GetChild(shopItem, "sellOff"    , false)
    local numText     = GUI.GetChild(attrBar , "numText"    , false)

    local shopItemData = DB.GetOnceItemByKey2(data["keyname"])

    ItemIcon.BindItemKeyName(shopIcon, data["keyname"])
    GUI.SetData(decreaseBtn, "index", index)
    GUI.StaticSetText(shopName, shopItemData.Name)
    GUI.StaticSetText(numText , data["cost"])

    GUI.ItemCtrlSetIconGray(shopIcon, data["limit"] <= 0)
    GUI.SetVisible(sellOff, data["limit"] <= 0)

    GUI.SetVisible(decreaseBtn, data["selectNum"] > 0)
    GUI.CheckBoxExSetCheck(shopItem, data["selectNum"] > 0)

    GUI.ItemCtrlSetElementValue(shopIcon, eItemIconElement.RightBottomNum, data["num"])
end

-- 点击事件：商店页面点击背包中的物品
function DiXiaMiTuUI.ShopBagClick(item)

    local index = tonumber(tostring(GUI.GetData(item, "index")))
    local keyName = GUI.GetData(item, "keyName")

    if keyName == nil or keyName == "" then
        return
    end

    if BagPage == 2 then
        DiXiaMiTuUI.TalkTxtTimerStart("这东西我可不收！")
        return
    end

    local itemData = DiXiaMiTuUI["show_data"][Bag[BagPage]..2][index+1]
    local num = DiXiaMiTuUI["show_data"][Bag[BagPage]][keyName]

    if itemData["selectNum"] < num then
        DiXiaMiTuUI["show_data"][Bag[BagPage]..2][index+1]["selectNum"] = DiXiaMiTuUI["show_data"][Bag[BagPage]..2][index+1]["selectNum"] + 1
        GUI.LoopScrollRectRefreshCells(_gt.GetUI("itemScroll"))
        DiXiaMiTuUI.TalkTxtTimerStart(DB.GetOnceItemByKey2(keyName).Name .. "，价值 " .. DiXiaMiTuUI["show_data"]["ItemCost"][keyName])
        DiXiaMiTuUI.RefreshShopPre()
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "已达上限！")
    end
end

-- 点击事件：点击商店页面中背包物品的减号
function DiXiaMiTuUI.OnBagClickMinusBtn(guid)
    local decreaseBtn = GUI.GetByGuid(guid)
    local itemScroll  =  _gt.GetUI("itemScroll")
    local index       = tonumber(tostring(GUI.GetData(decreaseBtn, "index")))
    local data        = DiXiaMiTuUI["show_data"][Bag[BagPage]..2][index+1]

    data["selectNum"] = data["selectNum"] - 1
    GUI.LoopScrollRectRefreshCells(itemScroll)
    DiXiaMiTuUI.RefreshShopPre()
end

-- 点击事件：点击商品
function DiXiaMiTuUI.OnShopItemClick(guid)
    local shopScroll   =  _gt.GetUI("shopScroll")
    local shopItem     = GUI.GetByGuid(guid)
    ShopItemIndex      = tonumber(GUI.GetData(shopItem, "index"))
    local data         = DiXiaMiTuUI["show_data"]["AllActShop"][ShopItemIndex + 1]
    local shopItemData = DB.GetOnceItemByKey2(data["keyname"])
    local decreaseBtn  = GUI.GetChild(shopItem, "decreaseBtn", true)

    if data["limit"] == 0 then
        DiXiaMiTuUI.TalkTxtTimerStart("没有更多道具了")
        GUI.LoopScrollRectRefreshCells(shopScroll)
        return
    end

    if data["selectNum"] < 1 then
        data["selectNum"] = data["selectNum"] + 1
        DiXiaMiTuUI.TalkTxtTimerStart(shopItemData.Tips)
    else
        DiXiaMiTuUI.OnClickMinusBtn(GUI.GetGuid(decreaseBtn))
        return
    end

    GUI.LoopScrollRectRefreshCells(shopScroll)
    DiXiaMiTuUI.RefreshShopPre()
end

-- 点击事件：点击货物Icon出Tips
function DiXiaMiTuUI.OnShopIconClick(guid)
    local icon     = GUI.GetByGuid(guid)
    local shopItem = GUI.GetParentElement(icon)
    local index    = tonumber(tostring(GUI.GetData(shopItem, "index")))
    local data     = DiXiaMiTuUI["show_data"]["AllActShop"][index + 1]
    local panelBg  = _gt.GetUI("panelBg")
    Tips.CreateByItemKeyNameWithBind(data["keyname"], data["bind"], panelBg, "rewardTips", -210 + (index % 2) * 260, 0, 0)
end

-- 点击事件：点击Icon上的减号
function DiXiaMiTuUI.OnClickMinusBtn(guid)
    local decreaseBtn = GUI.GetByGuid(guid)
    local shopScroll  =  _gt.GetUI("shopScroll")
    local index       = tonumber(tostring(GUI.GetData(decreaseBtn, "index")))
    local data        = DiXiaMiTuUI["show_data"]["AllActShop"][index + 1]

    data["selectNum"] = data["selectNum"] - 1
    GUI.LoopScrollRectRefreshCells(shopScroll)
    DiXiaMiTuUI.RefreshShopPre()
end

-- 点击事件：点击土地头像获得一些提示
function DiXiaMiTuUI.OnShopHeadClick()
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    DiXiaMiTuUI.TalkTxtTimerStart(DiXiaMiTuUI["show_data"]["TalkConfig"][math.random(1, #DiXiaMiTuUI["show_data"]["TalkConfig"])])
end

-- 刷新商店页面，商店换完东西也是回调这个方法
function DiXiaMiTuUI.RefreshShopPage()
    DiXiaMiTuUI.ResetData()
    local panelBg    = _gt.GetUI("panelBg")
    local shopBg     = GUI.GetChild(panelBg, "shopBg"    , false)
    local shopScroll = GUI.GetChild(shopBg , "shopScroll", false)
    local shopBtn    = GUI.GetChild(panelBg, "shopBtn"   , false)
    local backBtn    = GUI.GetChild(panelBg, "backBtn"   , false)
    local rankBtn    = GUI.GetChild(panelBg, "rankBtn"   , false)
    local runBtn     = GUI.GetChild(panelBg, "runBtn"    , false)
    local hintBtn    = GUI.GetChild(panelBg, "hintBtn"   , false)
    local dateBtn    = GUI.GetChild(panelBg, "dateBtn"   , false)
    local title      = GUI.GetChild(panelBg, "title"     , false)
    local titleTxt   = GUI.GetChild(title  , "titleTxt"  , false)
    local mineBg     = GUI.GetChild(panelBg, "mineBg"    , false)
    local prop       = GUI.GetChild(panelBg, "prop"      , false)
    local heartGroup = GUI.GetChild(panelBg, "heartGroup", false)
    local buyBtn     = GUI.GetChild(panelBg, "buyBtn"    , false)
    GUI.SetVisible(mineBg    , false)
    GUI.SetVisible(prop      , false)
    GUI.SetVisible(heartGroup, false)
    GUI.SetVisible(rankBtn   , false)
    GUI.SetVisible(runBtn    , false)
    GUI.SetVisible(hintBtn   , false)
    GUI.SetVisible(dateBtn   , false)
    GUI.SetVisible(shopBtn   , false)
    GUI.SetVisible(backBtn   , true)
    GUI.SetVisible(shopBg    , true)
    GUI.SetVisible(buyBtn    , true)
    GUI.SetPositionX(title, 210)
    GUI.StaticSetText(titleTxt, "土地的宝物店")

    GUI.LoopScrollRectSetTotalCount(shopScroll, #DiXiaMiTuUI["show_data"]["AllActShop"])
    GUI.LoopScrollRectRefreshCells(shopScroll)
    GUI.LoopScrollRectRefreshCells(_gt.GetUI("itemScroll"))

    local buffSubTabBtn = GUI.GetChild(GUI.GetChild(panelBg, "bagPage", false), "buffSubTabBtn", false)
    GUI.SetVisible(buffSubTabBtn, false)
    if BagPage == 2 then
        UILayout.OnSubTabClick(1, BtnList)
        DiXiaMiTuUI.OnActiveSubTabBtnClick()
    end

    DiXiaMiTuUI.TalkTxtTimerStart("地下的交易靠的就是以物易物！")
    DiXiaMiTuUI.RefreshShopPre()
end

function DiXiaMiTuUI.CreateMineBox(mineBg, x, y)
    local width     = GUI.GetWidth(mineBg)  / x
    local height    = GUI.GetHeight(mineBg) / y
    local mineIndex = 0
    for i = 0, x - 1 do
        for j = 0, y - 1 do
            local mineBox   = GUI.GetChild(mineBg, "mineBox"  ..mineIndex, false)
            local openMine  = GUI.GetChild(mineBg, "openMine" ..mineIndex, false)
            local mineBoxBg = GUI.GetChild(mineBg, "mineBoxBg"..mineIndex, false)
            if mineBox == nil then
                -- 这里宽高xy下面会改
                mineBoxBg = GUI.ImageCreate(mineBg, "mineBoxBg"..mineIndex, "1800400500", 0, 0, false, 65, 65)
                UILayout.SetAnchorAndPivot(mineBoxBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                openMine = GUI.ImageCreate(mineBg, "openMine"..mineIndex, "1800400500", 0, 0, false, 65, 65)
                UILayout.SetAnchorAndPivot(openMine, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                GUI.SetIsRaycastTarget(openMine, true)
                GUI.RegisterUIEvent(openMine, UCE.PointerClick , "DiXiaMiTuUI", "OnOpenMineClick")
                mineBox = GUI.ButtonCreate(mineBg, "mineBox"..mineIndex, "1801302090", 0, 0, Transition.ColorTint, "", 65, 65, false) -- 1800002010
                DiXiaMiTuUI.SetButton(mineBox, "MineClick", UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            end
            -- 对矿石按钮进行设置
            DiXiaMiTuUI.SetSingleMineBox(mineBox, width, height, i * width, j * height)
            GUI.SetData(mineBox , "index", mineIndex)
            GUI.SetData(mineBox , "pos"  , (i+1).."-"..(j+1))
            GUI.SetData(openMine, "pos"  , (i+1).."-"..(j+1))
            DiXiaMiTuUI.SetSingleMineBox(openMine, width-10, height-10, i * width+7, j * height+7)
            DiXiaMiTuUI.SetSingleMineBox(mineBoxBg, width, height, i * width, j * height)
            GUI.SetVisible(mineBoxBg, true)
            mineIndex = mineIndex + 1
        end
    end

    MineBoxMax = math.max(mineIndex, MineBoxMax)

    -- 隐藏掉多余的按钮，按照最初的设计应该是不会有这种情况发生的
    for i = mineIndex, MineBoxMax do
        local mineBox   = GUI.GetChild(mineBg, "mineBox"  ..i, false)
        local openMine  = GUI.GetChild(mineBg, "openMine" ..i, false)
        local mineBoxBg = GUI.GetChild(mineBg, "mineBoxBg"..i, false)
        GUI.SetVisible(mineBox  , false)
        GUI.SetVisible(openMine , false)
        GUI.SetVisible(mineBoxBg, false)
    end
end

-- 根据提供的宽高生成对应数量的矿石按钮
function DiXiaMiTuUI.SetMineBox(mineBg, x, y)
    local mineIndex = 0
    for i = 0, x - 1 do
        for j = 0, y - 1 do
            local mineBox  = GUI.GetChild(mineBg, "mineBox" ..mineIndex, false)
            local openMine = GUI.GetChild(mineBg, "openMine"..mineIndex, false)
            local data     = DiXiaMiTuUI["show_data"]["LayerInfo"][(i+1).."-"..(j+1)]

            if data["ListKey"] == "Door" then   -- 这个格子是个门
                GUI.ImageSetImageID(openMine, "1900000660")
            elseif data["ListKey"] == "MonsterKey" then -- 这个格子是一个怪物格
                GUI.ImageSetImageID(openMine, DiXiaMiTuUI["show_data"]["MonsterConfig"][data["List"]["MonsterKey"]]["Icon"])
            elseif data["ListKey"] == "ItemKey" or data["ListKey"] == "ActItemKey" or data["ListKey"] == "CollectItemKey" then    -- 这个格子是一个道具格
                local db = DB.GetOnceItemByKey2(data["List"][data["ListKey"]])
                GUI.ImageSetImageID(openMine, db.Icon)
            elseif data["ListKey"] == "ShopKey" then
                GUI.ImageSetImageID(openMine, "1800202150")
            elseif data["ListKey"] == "TrapKey" or data["ListKey"] == "AltarKey" then
                GUI.ImageSetImageID(openMine, DiXiaMiTuUI["show_data"]["TrapAndAltar"][data["List"][data["ListKey"]]]["Icon"])
            end

            GUI.SetGroupAlpha(mineBox, 1)

            if data["IsOpen"] == 0 then -- 这个格子没有被打开
                if data["CanSee"] == 1 then -- 这个格子被透视但是仍然需要打开
                    GUI.SetVisible(mineBox , true)
                    GUI.SetVisible(openMine, true)
                    GUI.SetGroupAlpha(mineBox, 0.5)
                else
                    GUI.SetVisible(mineBox , true)
                    GUI.SetVisible(openMine, false)
                end
            elseif data["IsOpen"] == 1 then
                GUI.SetVisible(mineBox , false)
                GUI.SetVisible(openMine, true)
            end

            if data["IsClear"] == 1 then    -- 这个格子已经被清空了
                GUI.SetVisible(mineBox, false)
                GUI.SetVisible(openMine, false)
            end

            if data["IsOpen"] == 0 and data["IsClear"] == 1 then    -- 尚未打开的空格子
                GUI.SetVisible(mineBox, true)
            end

            mineIndex = mineIndex + 1
        end
    end
end

-- 设置单个矿石按钮的宽高xy，包括按钮底下的图片也用这个方法
function DiXiaMiTuUI.SetSingleMineBox(mine, width ,height, x, y)
    GUI.SetWidth(mine, width)
    GUI.SetHeight(mine, height)
    GUI.SetPositionX(mine, x)
    GUI.SetPositionY(mine, y)
end

-- 点击事件：点击矿石按钮
function DiXiaMiTuUI.MineClick(guid)
    local mineBox  = GUI.GetByGuid(guid)
    if NowUseKeyName == nil or NowUseKeyName == "" then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中一个道具")
        return
    end
    --test("send server --> keyName : " .. NowUseKeyName .. " pos : " .. GUI.GetData(mineBox, "pos"))
    CL.SendNotify(NOTIFY.SubmitForm, "FormDiXiaMiTu", "UseItem", NowUseKeyName, GUI.GetData(mineBox, "pos"))
end

-- 点击事件：点击被打开的图片
function DiXiaMiTuUI.OnOpenMineClick(guid)
    --test(GUI.GetData(GUI.GetByGuid(guid), "pos"))
    CL.SendNotify(NOTIFY.SubmitForm, "FormDiXiaMiTu", "TouchEvent",GUI.GetData(GUI.GetByGuid(guid), "pos"))
end

-- 创建血量图标
function DiXiaMiTuUI.CreateHeart(heartGroup, max)
    for i = 1, max do
        local heart = GUI.GetChild(heartGroup, "heart" .. i, false)
        if heart == nil then
            heart = GUI.ImageCreate(heartGroup, "heart" .. i, "1801302110", 10, -120 + i * 50, false, 50, 50)
            UILayout.SetAnchorAndPivot(heart, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetIsRaycastTarget(heart, true)
            GUI.RegisterUIEvent(heart, UCE.PointerClick , "DiXiaMiTuUI", "OnHeartClick")
        end
        GUI.SetVisible(heart, true)
    end

    HeartMax = math.max(max, HeartMax)

    for i = max + 1, HeartMax do
        local heart  = GUI.GetChild(heartGroup, "heart" .. i, false)
        GUI.SetVisible(heart , false)
    end
end

-- 刷新当前血量状态(hp：当前血量，max：血量上限)
function DiXiaMiTuUI.SetHeart(heartGroup, hp, max)
    if heartGroup == nil then return end
    -- 这里是从下往上熄灭的
    for i = 1, max do
        -- 如果要从上往下熄灭就把下面这行改成 --> local heart = GUI.GetChild(heartGroup, "heart" .. (max - i + 1), false)
        local heart = GUI.GetChild(heartGroup, "heart" .. i, false)
        GUI.ImageSetImageID(heart, i <= hp and "1801302110" or "1801302100")
    end
end

-- 点击事件：点击血量出tips
function DiXiaMiTuUI.OnHeartClick()
    Tips.CreateHint("当前血量：" .. DiXiaMiTuUI["show_data"]["NowBlood"].."/"..DiXiaMiTuUI["show_data"]["ActMaxBlood"].."，血量归零则无法进行活动战斗",
            _gt.GetUI("panelBg"), -220, -130, UILayout.Center, 440)
end

-- 点击事件：在商店点击兑换按钮
function DiXiaMiTuUI.BuyBtnClick()
    local shopPrice = DiXiaMiTuUI.GetShopPrice()
    local bagPrice  = DiXiaMiTuUI.GetBagPrice()

    if shopPrice == 0 then
        DiXiaMiTuUI.TalkTxtTimerStart("请选择一些商店中的道具与我交换吧")
        return
    end
    if bagPrice == 0 then
        DiXiaMiTuUI.TalkTxtTimerStart("请选择一些主动道具或宝藏与我交换吧")
        return
    end

    if (shopPrice < bagPrice and bagPrice - shopPrice > DiXiaMiTuUI["show_data"]["ExchangeRange"]) or (shopPrice > bagPrice)  then
        DiXiaMiTuUI.TalkTxtTimerStart("买卖要公平，差价太大可不好")
    else
        --local needItem     = DiXiaMiTuUI.GetNeedItemString()
        --local exchangeItem = DiXiaMiTuUI.GetExchangeItemString()
        --test("needItem .. " .. needItem)
        --test("exchangeItem .. " .. exchangeItem)
        CL.SendNotify(NOTIFY.SubmitForm, "FormDiXiaMiTu", "ItemExchange", DiXiaMiTuUI.GetExchangeItemString(), DiXiaMiTuUI.GetNeedItemString())
    end
end

-- 提供给服务器的道具参数：9级暴击石,1,Item,1-9级攻击石,1,Item,1-9级魔攻石,1,Item,1
function DiXiaMiTuUI.GetNeedItemString()
    local shopString = ""
    for _, v in pairs(DiXiaMiTuUI["show_data"]["AllActShop"]) do
        if v["selectNum"] and v["selectNum"] > 0 then
            shopString = shopString .. v["keyname"] .. "," .. v["selectNum"] .. "," .. v["key"] .. "," .. v["bind"] .. "-"
        end
    end
    return string.sub(shopString, 0,#shopString-1)
end

-- 和上面那个差不多
function DiXiaMiTuUI.GetExchangeItemString()
    local exchangeItemString = ""
    for _, v in pairs(DiXiaMiTuUI["show_data"][Bag[BagPage]..2]) do
        if v["selectNum"] and v["selectNum"] > 0 then
            exchangeItemString = exchangeItemString .. v["keyName"] .. "," .. v["selectNum"] .. "," .. Bag[BagPage] .. ",0-"
        end
    end
    return string.sub(exchangeItemString, 0,#exchangeItemString-1)
end

-- 刷新商店下方进度条情况
function DiXiaMiTuUI.RefreshShopPre()
    local shopPreView = _gt.GetUI("shopPreView")
    local shopPreTxt  = GUI.GetChild(shopPreView, "shopPreTxt", false)

    local shopPrice = DiXiaMiTuUI.GetShopPrice()
    local bagPrice  = DiXiaMiTuUI.GetBagPrice()
    GUI.ScrollBarSetPos(shopPreView, bagPrice == 0 and 1 or shopPrice / (bagPrice + shopPrice))
    GUI.StaticSetText(shopPreTxt, shopPrice .. " | " .. bagPrice)
end

-- 获得商店选中的道具的价值
function DiXiaMiTuUI.GetShopPrice()
    local shopPrice = 0 -- 商店这边选中的道具的价值
    for _, v in pairs(DiXiaMiTuUI["show_data"]["AllActShop"]) do
        if v["selectNum"] and v["selectNum"] > 0 then
            shopPrice = shopPrice + v["selectNum"] * v["cost"]
        end
    end
    return shopPrice
end

-- 获得背包选中的道具的价值
function DiXiaMiTuUI.GetBagPrice()
    local bagPrice = 0
    for _, v in pairs(DiXiaMiTuUI["show_data"][Bag[BagPage]..2]) do
        if v["selectNum"] and v["selectNum"] > 0 then
            bagPrice = bagPrice + v["selectNum"] * DiXiaMiTuUI["show_data"]["ItemCost"][v["keyName"]]
        end
    end
    return bagPrice
end

-- 土地对话
function DiXiaMiTuUI.TalkTxtTimerStart(talkStr)
    TalkStr   = talkStr
    TalkIndex = 1
    TalkByte  = 1

    if DiXiaMiTuUI.TalkTxtTimer == nil then
        DiXiaMiTuUI.TalkTxtTimer = Timer.New(DiXiaMiTuUI.StartTalkAct, 0.015, -1, true)
    else
        DiXiaMiTuUI.ResetTimer()
    end
    DiXiaMiTuUI.TalkTxtTimer:Start()
end

-- 重置土地对话的Timer
function DiXiaMiTuUI.ResetTimer()
    DiXiaMiTuUI.TalkTxtTimer:Stop()
    DiXiaMiTuUI.TalkTxtTimer:Reset(DiXiaMiTuUI.StartTalkAct, 0.015, -1)
end

-- 土地对话动画
function DiXiaMiTuUI.StartTalkAct()
    local talkTxt = _gt.GetUI("talkTxt")
    TalkIndex = TalkIndex + 1

        if TalkByte <= TalkIndex then
            local curByte = string.byte(TalkStr, TalkIndex)
            local byteCount = 1;
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<=239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            GUI.StaticSetText(talkTxt, string.sub(TalkStr, 1, TalkIndex + byteCount - 1))
            TalkByte = TalkIndex + byteCount
        end
    if TalkIndex >= string.len(TalkStr) then
        DiXiaMiTuUI.ResetTimer()
    end
end

local UploadTable       -- 提交物品表
local UploadCollectItem -- 已有道具表
local SelectIndex       -- 选中的index
function DiXiaMiTuUI.SetUploadData()
    UploadTable       = {}
    UploadCollectItem = {}
    SelectIndex       = nil
    for i = 1, DiXiaMiTuUI["show_data"]["EndWidth"] do
        UploadTable[i] = {}
        for j = 1, DiXiaMiTuUI["show_data"]["EndHeight"] do
            UploadTable[i][j] = {
                ["keyName"] = nil,
                ["num"]  = nil,
            }
        end
    end

    for i, v in pairs(DiXiaMiTuUI["show_data"]["CollectItem"]) do
        if v ~= 0 then
            table.insert(UploadCollectItem, {
                ["keyName"] = i,
                ["num"]     = v,
            })
        end
    end
end

function DiXiaMiTuUI.RefreshUploadPage()
    local uploadBg = _gt.GetUI("uploadBg")
    if uploadBg == nil then
        uploadBg = DiXiaMiTuUI.CreateUploadPage()
    end

    GUI.SetVisible(_gt.GetUI("uploadCover"), true)

    DiXiaMiTuUI.SetUploadData()

    DiXiaMiTuUI.RefreshUpload()

    local upItemScroll = _gt.GetUI("upItemScroll")
    GUI.LoopScrollRectSetTotalCount(upItemScroll, BagMaxNum)
    GUI.LoopScrollRectRefreshCells(upItemScroll)
end

function DiXiaMiTuUI.CreateUploadPage()

    local panelBg = _gt.GetUI("panelBg")

    local uploadCover = GUI.ImageCreate(panelBg, "uploadCover", "1800400220", 0, -32, false, 2000, 2000)
    UILayout.SetAnchorAndPivot(uploadCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(uploadCover, true)
    _gt.BindName(uploadCover, "uploadCover")

    local uploadBg = UILayout.CreateFrame_WndStyle2_WithoutCover(uploadCover, "提交结算", 950, 550, "DiXiaMiTuUI", "UploadClose")
    _gt.BindName(uploadBg, "uploadBg")

    local upBg = GUI.ImageCreate(uploadBg, "upBg", "1800400010", 20, -7, false, 470, 495)
    UILayout.SetAnchorAndPivot(upBg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)

    --local upBgSelect = GUI.ImageCreate(upBg, "upBgSelect", "1800400280", 10, -40, false, 450, 450)
    --UILayout.SetAnchorAndPivot(upBgSelect, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local upBgmTitle = GUI.CreateStatic(upBg, "upBgmTitle", "提交位", 0, -5, 430, 35)
    DiXiaMiTuUI.SetStatic(upBgmTitle, UIAnchor.Top, UIAroundPivot.Top, 24, TextAnchor.MiddleCenter, false)
    GUI.SetColor(upBgmTitle, Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255))

    local width  = 450 / DiXiaMiTuUI["show_data"]["EndWidth"]
    local height = 450 / DiXiaMiTuUI["show_data"]["EndHeight"]
    for i = 1, DiXiaMiTuUI["show_data"]["EndWidth"] do
        for j = 1, DiXiaMiTuUI["show_data"]["EndHeight"] do
            local itemIcon = ItemIcon.Create(upBg,"itemIcon" .. i .. "_" .. j,(i-1) * width + 10,-(j-1) * height - 40, width, height)
            UILayout.SetAnchorAndPivot(itemIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            _gt.BindName(itemIcon,"itemIcon" .. i .. "_" .. j)
            GUI.SetData(itemIcon, "x", i)
            GUI.SetData(itemIcon, "y", j)
            GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "DiXiaMiTuUI", "OnUploadItemClick")
        end
    end

    local itemBg = GUI.ImageCreate(uploadBg, "itemBg", "1800400010", -15, 47, false, 430, 310)
    UILayout.SetAnchorAndPivot(itemBg, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local upItemTitle = GUI.CreateStatic(itemBg, "upItemTitle", "在探险中获得的宝藏", 0, 10, 430, 35)
    DiXiaMiTuUI.SetStatic(upItemTitle, UIAnchor.Top, UIAroundPivot.Top, 24, TextAnchor.MiddleCenter, false)
    GUI.SetColor(upItemTitle, Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255))

    local hintBtn = GUI.ButtonCreate(itemBg, "hintBtn", "1800702030", 10, 10, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(hintBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "DiXiaMiTuUI", "OnHint2BtnClick")

    local upItemScroll = GUI.LoopScrollRectCreate(
            itemBg, "upItemScroll",
            10, 50, 410, 250,
            "DiXiaMiTuUI", "CreatUpItemScroll",
            "DiXiaMiTuUI", "RefreshUpItemScroll",
            0, false,
            Vector2.New(80, 80),
            5,
            UIAroundPivot.Top, UIAnchor.Top
    )
    GUI.ScrollRectSetChildSpacing(upItemScroll, Vector2.New(2, 2))
    _gt.BindName(upItemScroll, "upItemScroll")

    local qualityBg = GUI.ImageCreate(uploadBg, "qualityBg", "1800400010", -15, 360, false, 430, 60)
    UILayout.SetAnchorAndPivot(qualityBg, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local qualityIcon1 = GUI.CheckBoxCreate(qualityBg, "qualityIcon1", "1800607150","1800607151", 380, 12, Transition.ColorTint, true, 38, 38)
    GUI.RegisterUIEvent(qualityIcon1, UCE.PointerClick, "DiXiaMiTuUI", "OnQuality1Click")
    _gt.BindName(qualityIcon1, "qualityIcon1")
    local qualityTxt1 = GUI.CreateStatic(qualityIcon1, "qualityTxt1", "添加材料", -40, 0, 140, 30)
    DiXiaMiTuUI.SetStatic(qualityTxt1, UIAnchor.Left, UIAroundPivot.Left, 24, TextAnchor.MiddleLeft)
    GUI.SetIsRaycastTarget(qualityTxt1, true)
    GUI.RegisterUIEvent(qualityTxt1, UCE.PointerClick, "DiXiaMiTuUI", "OnQuality1Click")

    local qualityIcon2 = GUI.CheckBoxCreate(qualityBg, "qualityIcon2", "1800607150","1800607151", 190, 12, Transition.ColorTint, false, 38, 38)
    GUI.RegisterUIEvent(qualityIcon2, UCE.PointerClick, "DiXiaMiTuUI", "OnQuality2Click")
    _gt.BindName(qualityIcon2, "qualityIcon2")
    local qualityTxt2 = GUI.CreateStatic(qualityIcon2, "qualityTxt2", "清空单格", -40, 0, 140, 30)
    DiXiaMiTuUI.SetStatic(qualityTxt2, UIAnchor.Left, UIAroundPivot.Left, 24, TextAnchor.MiddleLeft)
    GUI.SetIsRaycastTarget(qualityTxt2, true)
    GUI.RegisterUIEvent(qualityTxt2, UCE.PointerClick, "DiXiaMiTuUI", "OnQuality1Click")

    local uploadBtn = GUI.ButtonCreate(uploadBg, "uploadBtn", "1800102090", -135, -50, Transition.ColorTint, "提交", 180, 65, false)
    DiXiaMiTuUI.SetButton(uploadBtn, "OnUploadClick", UIAnchor.BottomRight, UIAroundPivot.BottomRight)

    return uploadBg
end

-- 创建背包滚动列表
function DiXiaMiTuUI.CreatUpItemScroll()
    local upItemScroll =  _gt.GetUI("upItemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(upItemScroll)
    local upItemIcon = ItemIcon.Create(upItemScroll,"upItemIcon" .. curCount,0,0)
    _gt.BindName(upItemIcon, "upItemIcon"..curCount)
    GUI.RegisterUIEvent(upItemIcon, UCE.PointerClick, "DiXiaMiTuUI", "OnUpItemClick")
    GUI.ItemCtrlSetElementRect(upItemIcon, eItemIconElement.RightBottomNum, 7, 5)

    return upItemIcon
end

-- 刷新背包滚动列表
function DiXiaMiTuUI.RefreshUpItemScroll(parameter)
    parameter      = string.split(parameter, "#")
    local guid     = parameter[1]
    local index    = tonumber(parameter[2])
    local itemIcon = GUI.GetByGuid(guid)

    local decreaseBtn = GUI.GetChild(itemIcon, "decreaseBtn", false)
    GUI.SetVisible(decreaseBtn, false)
    GUI.SetData(decreaseBtn, "index", index)

    if UploadCollectItem[index+1] == nil then
        GUI.SetData(itemIcon, "keyName", "")
        GUI.SetData(itemIcon, "index"  , "")
        ItemIcon.SetEmpty(itemIcon)
        return
    end

    local itemKey = UploadCollectItem[index+1]["keyName"]
    GUI.SetData(itemIcon, "keyName", itemKey)
    GUI.SetData(itemIcon, "index"  , index+1)

    ItemIcon.BindItemKeyName(itemIcon, itemKey)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, UploadCollectItem[index+1]["num"])
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Selected, 1800400280)
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Selected, 0, 0, 85, 85)

    if GUI.CheckBoxGetCheck(_gt.GetUI("qualityIcon1")) and SelectIndex == index + 1 then
        GUI.ItemCtrlSelect(itemIcon)
    else
        GUI.ItemCtrlUnSelect(itemIcon)
    end

    if UploadCollectItem[index+1]["num"] <= 0 then
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, 1801300230)
        GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.IconMask, 0, 0,80,81)
    else
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil)
    end
end

function DiXiaMiTuUI.OnUpItemClick(guid)
    if GUI.GetData(GUI.GetByGuid(guid), "keyName") ~= "" then
        if GUI.CheckBoxGetCheck(_gt.GetUI("qualityIcon2")) then
            DiXiaMiTuUI.OnQuality1Click()
        end
        local uploadBg = _gt.GetUI("uploadBg")
        local keyName = GUI.GetData(GUI.GetByGuid(guid), "keyName")
        local itemTips = Tips.CreateByItemKeyName(keyName, uploadBg, "itemTips", 420, -20, 0)
        GUI.TipsAddCutLine(itemTips)
        GUI.TipsAddLabel(itemTips, 20, "基础价值：".. DiXiaMiTuUI["show_data"]["ItemCost"][keyName]
                .. "，点击左侧提交位，将物品放入提交位后才会被计算分数", UIDefine.RedColor, false)
        SelectIndex = tonumber(tostring(GUI.GetData(GUI.GetByGuid(guid), "index")))
        GUI.LoopScrollRectRefreshCells(_gt.GetUI("upItemScroll"))
    end
end

function DiXiaMiTuUI.OnUploadItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local x    = tonumber(GUI.GetData(item, "x"))
    local y    = tonumber(GUI.GetData(item, "y"))
    local endLock = DiXiaMiTuUI["show_data"]["EndLock"][DiXiaMiTuUI["show_data"]["PassLayer"]]
    if x > endLock[1] or y > endLock[2] then
        CL.SendNotify(NOTIFY.ShowBBMsg, "继续深入洞穴开启更多提交位")
        return
    end
    if GUI.CheckBoxGetCheck(_gt.GetUI("qualityIcon1")) then -- 往上加材料
        if SelectIndex == nil then
            CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中一个材料！")
            return
        elseif UploadCollectItem[SelectIndex]["num"] == 0 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "这个材料已经用完了！")
            return
        else
            if UploadTable[x][y]["keyName"] == nil then    -- 这是一个空格子
                UploadTable[x][y]["keyName"] = UploadCollectItem[SelectIndex]["keyName"]
                UploadTable[x][y]["num"] = 1
                UploadCollectItem[SelectIndex]["num"] = UploadCollectItem[SelectIndex]["num"] - 1
            else
                if UploadTable[x][y]["keyName"] ~= UploadCollectItem[SelectIndex]["keyName"] then   --  选中的道具和已有的道具不一样不能叠加
                    CL.SendNotify(NOTIFY.ShowBBMsg, "不同物品不可堆叠！")
                    return
                elseif UploadTable[x][y]["num"] >= DiXiaMiTuUI["show_data"]["EndStackMax"] then -- 超过堆叠上限不能叠加
                    CL.SendNotify(NOTIFY.ShowBBMsg, "一格最高堆叠" .. DiXiaMiTuUI["show_data"]["EndStackMax"] .. "个物品")
                    return
                else    -- 在已经有的基础上添加一个
                    UploadTable[x][y]["num"] = UploadTable[x][y]["num"] + 1
                    UploadCollectItem[SelectIndex]["num"] = UploadCollectItem[SelectIndex]["num"] - 1
                end
            end
        end
    elseif GUI.CheckBoxGetCheck(_gt.GetUI("qualityIcon2")) then -- 清空一个单格
        for _, v in pairs(UploadCollectItem) do
            if v["keyName"] == UploadTable[x][y]["keyName"] then
                v["num"] = v["num"] + UploadTable[x][y]["num"]
                break
            end
        end
        UploadTable[x][y] = {
            ["keyName"] = nil,
            ["num"]  = nil,
        }
    end
    DiXiaMiTuUI.RefreshUpload()
    GUI.LoopScrollRectRefreshCells(_gt.GetUI("upItemScroll"))
end

function DiXiaMiTuUI.RefreshUpload()
    local endLock = DiXiaMiTuUI["show_data"]["EndLock"][DiXiaMiTuUI["show_data"]["PassLayer"]]
    for i = 1, DiXiaMiTuUI["show_data"]["EndWidth"] do
        for j = 1,DiXiaMiTuUI["show_data"]["EndHeight"] do
            local itemIcon = _gt.GetUI("itemIcon" .. i .. "_" .. j)

            if i > endLock[1] or j > endLock[2] then
                ItemIcon.SetLock(itemIcon)
            elseif UploadTable[i][j]["keyName"] == nil then
                ItemIcon.SetEmpty(itemIcon)
            else
                ItemIcon.BindItemKeyName(itemIcon, UploadTable[i][j]["keyName"])
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, UploadTable[i][j]["num"])
            end
        end
    end
end

function DiXiaMiTuUI.OnUploadClick()
    local str = ""
    for i = 1, DiXiaMiTuUI["show_data"]["EndWidth"] do
        for j = 1, DiXiaMiTuUI["show_data"]["EndHeight"] do
            str = str .. i .. "-" .. j .. "=" .. tostring(UploadTable[i][j]["keyName"]) .. "&" .. tostring(UploadTable[i][j]["num"]) .. ","
        end
    end
    --test(str)
    -- 向服务器提交数据，去掉最后一个逗号
    CL.SendNotify(NOTIFY.SubmitForm, "FormDiXiaMiTu", "ActivityEnd", string.sub(str, 0, #str - 1))
end

function DiXiaMiTuUI.OnQuality1Click()
    local qualityIcon1 = _gt.GetUI("qualityIcon1")
    local qualityIcon2 = _gt.GetUI("qualityIcon2")

    GUI.CheckBoxSetCheck(qualityIcon1, true)
    GUI.CheckBoxSetCheck(qualityIcon2, false)

    GUI.LoopScrollRectRefreshCells(_gt.GetUI("upItemScroll"))
end

function DiXiaMiTuUI.OnQuality2Click()
    local qualityIcon1 = _gt.GetUI("qualityIcon1")
    local qualityIcon2 = _gt.GetUI("qualityIcon2")

    GUI.CheckBoxSetCheck(qualityIcon1, false)
    GUI.CheckBoxSetCheck(qualityIcon2, true)

    GUI.LoopScrollRectRefreshCells(_gt.GetUI("upItemScroll"))
end

function DiXiaMiTuUI.OnHintBtnClick()
    local panelBg = _gt.GetUI("panelBg")
    Tips.CreateHint(
            "1.使用道具在洞穴中进行探索，不同的道具拥有各不相同的效果。\n"..
                  "2.寻找地洞前往下一层洞穴，可挖掘的石板会随着地下探险的深入而逐渐变多。\n"..
                  "3.洞穴中有着神秘的祭坛与危险的陷阱，一旦挖到就会对战斗或者探险产生不小的影响。\n"..
                  "4.战斗失败会损失部分活动生命值，一旦失去了所有生命值就无法再进行活动战斗了\n"..
                  "5.土地的宝物店会出售对探险有利的道具，但他只接受以物易物。",
            panelBg, -220, 60, UILayout.Center, 440)
end

function DiXiaMiTuUI.OnHint2BtnClick()
    local uploadBg = _gt.GetUI("uploadBg")
    Tips.CreateHint(
            "点击右侧选中探险中的宝藏，将宝藏添加到左侧的提交位中。\n"..
            "只有提交位中的宝藏才会被计算分数。\n"..
            "提交位会随着地下冒险的深入而逐渐增多。",
            uploadBg, 200, -130, UILayout.Center, 440)
end

function DiXiaMiTuUI.DateBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormDiXiaMiTu", "GetActInfo")
end

function DiXiaMiTuUI.RefreshDate()
    local bgSp = _gt.GetUI("bgSp")
    if bgSp == nil then
        bgSp = DiXiaMiTuUI.CreateDate()
    end
    GUI.SetVisible(_gt.GetUI("dateCover"), true)
    local dateScroll = _gt.GetUI("dateScroll")
    GUI.LoopScrollRectSetTotalCount(dateScroll, #DiXiaMiTuUI["show_data"]["ActInfo"])
    GUI.LoopScrollRectRefreshCells(dateScroll)
end

function DiXiaMiTuUI.CreateDate()
    local panelBg = _gt.GetUI("panelBg")
    local dateCover = GUI.ImageCreate(panelBg, "dateCover", "1800400220", 0, -32, false, 2000, 2000)
    UILayout.SetAnchorAndPivot(dateCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(dateCover, true)
    _gt.BindName(dateCover, "dateCover")
    local bgSp = UILayout.CreateFrame_WndStyle2_WithoutCover(dateCover, "探险日志", 705, 580, "DiXiaMiTuUI", "DateClose")
    _gt.BindName(bgSp, "bgSp")
    local dateScroll = GUI.LoopScrollRectCreate(
            bgSp,
            "dateScroll",
            3, 20,
            700, 500,
            "DiXiaMiTuUI", "CreateDateItem",
            "DiXiaMiTuUI", "RefreshDateItem",
            0,
            false,
            Vector2.New(680, 80),
            1,
            UIAroundPivot.Top, UIAnchor.Top
    )
    _gt.BindName(dateScroll, "dateScroll")

    return bgSp
end

function DiXiaMiTuUI.CreateDateItem()
    local dateScroll = _gt.GetUI("dateScroll")
    local curCount     = GUI.LoopScrollRectGetChildInPoolCount(dateScroll)
    local Index        = tonumber(curCount) + 1

    local chatBoxBg = GUI.LoopListChatCreate(dateScroll, "chatBoxBg"..Index, "1800400200", 0, 10)
    --GUI.SetColor(chatBoxBg, Color.New(1, 1, 1, 0))
    GUI.LoopListChatSetPreferredWidth(chatBoxBg, 660)
    GUI.LoopListChatSetPreferredHeight(chatBoxBg, 60)
    UILayout.SetAnchorAndPivot(chatBoxBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local advert = GUI.RichEditCreate(chatBoxBg, "advert", "", 0, 0, 660, 120)
    DiXiaMiTuUI.SetStatic(advert, UIAnchor.Center, UIAroundPivot.Center, 24, TextAnchor.MiddleCenter, false)
    GUI.SetColor(advert, Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255))

    return chatBoxBg
end

function DiXiaMiTuUI.RefreshDateItem(parameter)
    parameter   = string.split(parameter, "#")
    local guid  = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local info  = DiXiaMiTuUI["show_data"]["ActInfo"][index]

    local chatBoxBg = GUI.GetByGuid(guid)
    local advert    = GUI.GetChild(chatBoxBg, "advert", false)
    GUI.StaticSetText(advert, info)
end

function DiXiaMiTuUI.DateClose()
    GUI.SetVisible(_gt.GetUI("dateCover"), false)
end

function DiXiaMiTuUI.UploadClose()
    GUI.SetVisible(_gt.GetUI("uploadCover"), false)
end

function DiXiaMiTuUI.OnExit()
    GUI.CloseWnd("DiXiaMiTuUI")
end

function DiXiaMiTuUI.SetStatic(text, anchor, pivot, fontSize, alignment, outLine, outLine_Distance, outLine_Color)
    if text == nil then return end
    anchor           = anchor           == nil and UIAnchor.Center             or anchor
    pivot            = pivot            == nil and UIAroundPivot.Center        or pivot
    fontSize         = fontSize         == nil and 26                          or fontSize
    alignment        = alignment        == nil and TextAnchor.MiddleCenter     or alignment
    outLine          = outLine          == nil and true                        or outLine
    outLine_Distance = outLine_Distance == nil and 2                           or outLine_Distance
    outLine_Color    = outLine_Color    == nil and UIDefine.OutLine_BrownColor or outLine_Color

    UILayout.SetAnchorAndPivot(text, anchor, pivot)
    GUI.StaticSetFontSize(text, fontSize)
    GUI.StaticSetAlignment(text, alignment)
    GUI.SetIsOutLine(text, outLine)
    GUI.SetOutLine_Distance(text, outLine_Distance)
    GUI.SetOutLine_Color(text, outLine_Color)
end

function DiXiaMiTuUI.SetButton(button, functionName, anchor, pivot, fontSize, textColor, outLine, outLine_Distance, outLine_Color)
    if button == nil then return end
    anchor           = anchor           == nil and UIAnchor.Center             or anchor
    pivot            = pivot            == nil and UIAroundPivot.Center        or pivot
    fontSize         = fontSize         == nil and 26                          or fontSize
    textColor        = textColor        == nil and UIDefine.WhiteColor         or textColor
    outLine          = outLine          == nil and true                        or outLine
    outLine_Distance = outLine_Distance == nil and UIDefine.OutLineDistance    or outLine_Distance
    outLine_Color    = outLine_Color    == nil and UIDefine.OutLine_BrownColor or outLine_Color

    UILayout.SetAnchorAndPivot(button, anchor, pivot)
    GUI.ButtonSetTextColor(button, textColor)
    GUI.ButtonSetTextFontSize(button, fontSize)
    GUI.ButtonSetOutLineArgs(button, outLine, outLine_Color, outLine_Distance)
    GUI.RegisterUIEvent(button, UCE.PointerClick, "DiXiaMiTuUI", functionName)
end