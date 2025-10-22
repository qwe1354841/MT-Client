---@diagnostic disable: undefined-global, undefined-doc-name
local Pray_2UI = {
    ---@type PrayServerCfg[]
    ServerData = {},
    ---@type PrayShowData
    ShowData = {},
    onLineTimer = nil,
    uinode = {},
    tmptypeTable = {},
	FreeTimeUsed = {}
}
_G.Pray_2UI = Pray_2UI
local fontSizeSmall = UIDefine.FontSizeS
local fontSizeDefault = UIDefine.FontSizeM
local fontSizeBigger = UIDefine.FontSizeXL
local fontSizeTitle = UIDefine.FontSizeXXL
local _gt = UILayout.NewGUIDUtilTable()

local colorWhite = UIDefine.WhiteColor
local colorDark = UIDefine.BrownColor
local iconGradeBg = UIDefine.ItemIconBg2

local colorblack = UIDefine.BlackColor
local QualityRes = UIDefine.ItemIconBg
local TitemBg = {"1800601190", "1800601220"}
local TitemPosX = {-340, 340}
local Pray_2UI_redpoint = {0, 0}
local uinode = {"pagePray", "petPray", "festPray", "panelBg", "PrizeWnd", "prizeScroll", "tipsWnd", "tipsScroll"}
setmetatable(
    Pray_2UI.uinode,
    {
        __newindex = function(mytable, key, value)
            for i = 1, #uinode do
                if key == uinode[i] then
                    rawset(mytable, "_" .. uinode[i], GUI.GetGuid(value))
                end
            end
        end,
        __index = function(mytable, key)
            for i = 1, #uinode do
                if key == uinode[i] then
                    return GUI.GetByGuid(mytable["_" .. uinode[i]])
                end
            end
            return nil
        end
    }
)

Pray_2UI.prizeTable = {}
Pray_2UI.showBtnTimer = nil
function Pray_2UI.InitData()
    return {
        ---@type PrayClientCfg[]
        cfg = {},
        curClickIndex = 1,
        curShowCnt = 0,
        prizeItemCnt = 0,
        typeTable = {},
        firstOpen = true
    }
end

local data = Pray_2UI.InitData()
function Pray_2UI.OnExitGame()
    data = Pray_2UI.InitData()
end

function Pray_2UI.weaponsBtnClick()
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "神兵预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    Pray_2UI.Refresh()
end

function Pray_2UI.petTabBtnClick()
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "灵宠预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    Pray_2UI.Refresh()
end

function Pray_2UI.festTabBtnClick()
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "限时预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    Pray_2UI.Refresh()
end

function Pray_2UI.Main(parameter)
    --等级不足时禁止打开
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = MainUI.MainUISwitchConfig["祈福"].OpenLevel
	if CurLevel < Level then
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启祈福功能")
		return
	end
    GameMain.AddListen("Pray_2UI", "OnExitGame")
    local panel = GUI.WndCreateWnd("Pray_2UI", "Pray_2UI", 0, 0, eCanvasGroup.Normal)
    _gt.BindName(panel,"panel")
    
    GUI.SetIgnoreChild_OnVisible(panel, true)
    Pray_2UI.uinode.panelBg = UILayout.CreateFrame_WndStyle0(panel, "祈 福", "Pray_2UI", "OnCloseBtnClick")
    Pray_2UI.CreatePage()
	-- if data.firstOpen then
    --     data.firstOpen = false
    --     assert(loadstring("Pray_2UI.".. tabList[1][3].."()"))()
    -- end
end

function Pray_2UI.OnShow(scriptname)
    local wnd = GUI.GetWnd("Pray_2UI")
    if wnd == nil then
        return
    end
    data = Pray_2UI.InitData()
    Pray_2UI.tabIndex = 1
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "GetData")
    test("请求数据")
    GUI.SetVisible(wnd, true)
    CL.UnRegisterMessage(GM.CustomDataUpdate, "Pray_2UI", "OnCustomDataUpdate")
    CL.UnRegisterMessage(GM.RefreshBag, "Pray_2UI", "OnRefreshBag")
    CL.RegisterMessage(GM.CustomDataUpdate, "Pray_2UI", "OnCustomDataUpdate")
    CL.RegisterMessage(GM.RefreshBag, "Pray_2UI", "OnRefreshBag")
    -- Pray_2UI.RefreshRankTime()
    -- Pray_2UI.RefreshUI()
end
function Pray_2UI.OnRefreshBag()
    for i = 1, #data.cfg do
        for j = i, #data.cfg[i] do
            local id =  DB.GetOnceItemByKey2(data.cfg[i][j].ItemKey).Id
            data.cfg[i][j].ItemNums = LD.GetItemCountById(id, item_container_type.item_container_bag)
        end
    end
    Pray_2UI.ClientRefresh()
end
function Pray_2UI.OnCustomDataUpdate(type, key, val)
    print(int64.longtonum2(val))
    if type == 2 then

        local l, h = int64.longtonum2(val)
        
        for i = 1, #data.cfg do
            for j = i, #data.cfg[i] do
                if key == "PrayFreeTimeUsed" .. i .. "_"..j then
                    data.cfg[i][j].FreeTimes = data.cfg[i][j].DayFreeMax - l
                end
                if key == "PrayNextFreeTime" .. i .. "_".. j then
                    data.cfg[i][j].NextFreeSecond = l
                end 
            end
        end
        Pray_2UI.ClientRefresh()
    end
end
--创建祈福ITEM页面
function Pray_2UI.CreatePage()
    local pagePray = GUI.GroupCreate(Pray_2UI.uinode.panelBg, "pagePray", 0, -20, 0, 0)
    Pray_2UI.uinode.pagePray = pagePray
    GUI.SetIgnoreChild_OnVisible(pagePray, true)
    GUI.SetAnchor(pagePray, UIAnchor.Center)
    GUI.SetPivot(pagePray, UIAroundPivot.Center)
    GUI.SetVisible(pagePray, false)
    _gt.BindName(pagePray,"pagePray")

    local petPray = GUI.GroupCreate(Pray_2UI.uinode.panelBg, "petPray", 0, -20, 0, 0)
    Pray_2UI.uinode.petPray = petPray
    GUI.SetIgnoreChild_OnVisible(petPray, true)
    GUI.SetAnchor(petPray, UIAnchor.Center)
    GUI.SetPivot(petPray, UIAroundPivot.Center)
    GUI.SetVisible(petPray, false)
    _gt.BindName(petPray,"petPray")

    local festPray = GUI.GroupCreate(Pray_2UI.uinode.panelBg, "festPray", 0, -20, 0, 0)
    Pray_2UI.uinode.festPray = festPray
    GUI.SetIgnoreChild_OnVisible(festPray, true)
    GUI.SetAnchor(festPray, UIAnchor.Center)
    GUI.SetPivot(festPray, UIAroundPivot.Center)
    GUI.SetVisible(festPray, false)
    _gt.BindName(festPray,"festPray")

    for i = 1, #TitemBg do
        Pray_2UI.WeaponsOutItem(pagePray, i)
        Pray_2UI.PetOutItem(petPray, i)
    end
    Pray_2UI.FestOutItem()
end

--创建单个祈福ITEM
function Pray_2UI.WeaponsOutItem(parent, itemIndex)
    --背景
    local itemBg =
        GUI.ImageCreate(parent, "itemBg" .. itemIndex, TitemBg[itemIndex], TitemPosX[itemIndex], -239, false, 330, 530)
    UILayout.SetSameAnchorAndPivot(itemBg, UILayout.Top)

    local table = GUI.ImageCreate(parent, "table", "1801408010", 0, 150, false)
    local image1 = GUI.ImageCreate(table, "image1", "1800201090", 0, -185, false, 415, 415)
	local image3 = GUI.ImageCreate(table, "image3", "1900013900", 66.4, -278.6, false, 130, 130)
    local image4 = GUI.ImageCreate(table, "image4", "1900013920", 73.4, -99.3, false, 110, 110)
    local image5 = GUI.ImageCreate(table, "image5", "1900013850", -89.3, -250.8, false, 110, 110)
	local image7 = GUI.ImageCreate(table, "image7", "1900013940", -40.9, -162.4, false, 90, 90)
	local image9 = GUI.ImageCreate(table, "image9", "1900001320", 8.2, -98.8, false, 90, 90)
	local image8 = GUI.ImageCreate(table, "image8", "1900013890", -70.8, -80, false, 110, 110)
    local image6 = GUI.ImageCreate(table, "image6", "1900001340", 33.42, -171.6, false, 110, 110)
    local image10 = GUI.ImageCreate(table, "image10", "1900001330", -14.6, -229.2, false, 100, 100)
	local image2 = GUI.ImageCreate(table, "image2", "1800007130", -91.9, -295.6, false, 88, 66)
	GUI.SetScale(image2, Vector3.New(1.1, 1.1, 1.1))

    local text = GUI.CreateStatic(table,"text","绝世神兵 点击就送",0,170,300,50,"100");
	GUI.SetAnchor(text,UIAnchor.TopLeft)
	GUI.SetPivot(text,UIAroundPivot.TopLeft)
	GUI.StaticSetFontSize(text,35)
	
	--设置颜色渐变
	GUI.StaticSetIsGradientColor(text,true)
	GUI.StaticSetGradient_ColorTop(text,Color.New(255/255,244/255,139/255,255/255))
	--GUI.StaticSetGradient_ColorLeft(text,UIDefine.BrownColor)--文本左边顶点颜色
	--GUI.StaticSetGradient_SplitText(text,true)--是否控制单字的顶点颜色
	
	--设置描边
	GUI.SetIsOutLine(text,true)
	GUI.SetOutLine_Distance(text,3)
	GUI.SetOutLine_Color(text,Color.New(182/255,52/255,40/255,255/255))
	
	--设置阴影
	GUI.SetIsShadow(text,true)
	GUI.SetShadow_Distance(text,Vector2.New(0,-1))
	GUI.SetShadow_Color(text,UIDefine.BlackColor)
    
    --图标
    local iconBg = GUI.ImageCreate(itemBg, "iconBg", "1800601180", 0, -118, false)
    UILayout.SetSameAnchorAndPivot(iconBg, UILayout.Center)

    local itemIcon = ItemIcon.Create(iconBg, "itemIcon", 0, 0)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "Pray_2UI", "OnWeaponsBtnClick")
    GUI.SetData(itemIcon,"tipIndex",itemIndex)
    _gt.BindName(itemIcon,"itemIcon01")

    --标题
    local titleBg = GUI.ImageCreate(itemBg, "titleBg", "1800601230", -3, -223, false, 277, 54)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Center)
    local itemTitle = GUI.RichEditCreate(titleBg, "itemTitle", "", 0, 0, 270, 54, "system", true)
    UILayout.SetSameAnchorAndPivot(itemTitle, UILayout.Center)
    GUI.StaticSetAlignment(itemTitle, TextAnchor.UpperCenter)
    GUI.SetColor(itemTitle, colorWhite)
    GUI.StaticSetFontSize(itemTitle, fontSizeDefault)

    --提示按钮
    local tipBtn = GUI.ButtonCreate(itemBg, "tipBtn", "1800702030", -11, 204, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(tipBtn, UILayout.TopRight)
    --    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick, "Pray_2UI", "OnTipsBtnClick")
    --    GUI.SetData(tipBtn,"tipIndex",itemIndex)
    GUI.SetVisible(tipBtn, false)

    --item抽奖描述
    local descBg = GUI.ImageCreate(itemBg, "descBg", "1800601170", 0, 28, false)
    UILayout.SetSameAnchorAndPivot(descBg, UILayout.Center)

    --    local itemSelectDescScroll = GUI.ScrollRectCreate( 100), "itemSelectDescScroll", 0, 0, 233, 68, 0, false, Vector2.New(233, descBg, UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    --    GUI.SetAnchor(itemSelectDescScroll, UIAnchor.Center)
    --    GUI.SetPivot(itemSelectDescScroll, UIAroundPivot.Center)
    --    GUI.ScrollRectSetChildAnchor(itemSelectDescScroll, UIAnchor.Top)
    --    GUI.ScrollRectSetChildPivot(itemSelectDescScroll, UIAroundPivot.Top)
    --    GUI.ScrollRectSetChildSpacing(itemSelectDescScroll, Vector2.New(0, 0))

    local itemDesc = GUI.RichEditCreate(descBg, "itemDesc", "", 0, 0, 233, 68, "system", true)
    UILayout.SetSameAnchorAndPivot(itemDesc, UILayout.Center)
    GUI.StaticSetAlignment(itemDesc, TextAnchor.MiddleCenter)
    GUI.SetColor(itemDesc, colorDark)
    GUI.StaticSetFontSize(itemDesc, fontSizeSmall)

    --抽奖详细信息
    local detailBg = GUI.GroupCreate(itemBg, "detailBg", 1, 0, 0, 0)
    UILayout.SetSameAnchorAndPivot(detailBg, UILayout.BottomLeft)
    GUI.SetVisible(detailBg, true)
    --剩余道具
    local propNum = GUI.CreateStatic(detailBg, "propNum", "", 158, 147, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(propNum, UILayout.Center)
    GUI.StaticSetAlignment(propNum, TextAnchor.MiddleCenter)
    GUI.SetColor(propNum, colorWhite)
    GUI.StaticSetFontSize(propNum, fontSizeSmall)

    --免费次数
    local freeTime = GUI.CreateStatic(detailBg, "freeTime", "", -16, 120, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(freeTime, UILayout.TopLeft)
    GUI.StaticSetAlignment(freeTime, TextAnchor.MiddleCenter)
    GUI.SetColor(freeTime, colorWhite)
    GUI.StaticSetFontSize(freeTime, fontSizeSmall)

    --折扣优惠
    local discount = GUI.CreateStatic(detailBg, "discount", "9折优惠", 343, 120, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(discount, UILayout.TopRight)
    GUI.StaticSetAlignment(discount, TextAnchor.MiddleCenter)
    GUI.SetColor(discount, colorWhite)
    GUI.StaticSetFontSize(discount, fontSizeSmall)

    --祈福一次
    local oneTimeBtn = GUI.ButtonCreate(detailBg, "oneTimeBtn", "1800602290", 8, 5, Transition.ColorTint)
    GUI.SetAnchor(oneTimeBtn, UIAnchor.BottomLeft)
    GUI.SetPivot(oneTimeBtn, UIAroundPivot.BottomLeft)
    GUI.RegisterUIEvent(oneTimeBtn, UCE.PointerClick, "Pray_2UI", "OnOneWeaponsTimeBtnClick")
    GUI.SetData(oneTimeBtn, "prayItemIndex", itemIndex)

    local oneTime = GUI.CreateStatic(detailBg, "oneTime", "祈福一次", 86, 69, 100, 30, "system", false, true)
    GUI.SetAnchor(oneTime, UIAnchor.Center)
    GUI.SetPivot(oneTime, UIAroundPivot.Center)
    GUI.StaticSetAlignment(oneTime, TextAnchor.MiddleCenter)
    GUI.SetColor(oneTime, colorDark)
    GUI.StaticSetFontSize(oneTime, fontSizeDefault)

    -- 金钱
    local coinBg1, icon, numText = UILayout.CreateAttrBar(detailBg, "coinBg1", 30, 50, 117, UILayout.TopLeft)
	GUI.SetPositionX(icon, -12)
	
    --祈福十次
    local tenTimeBtn =
        GUI.ButtonCreate(detailBg, "tenTimeBtn", "1800402110", 319, 5, Transition.ColorTint, "", 152, 86, false)
    GUI.SetAnchor(tenTimeBtn, UIAnchor.BottomRight)
    GUI.SetPivot(tenTimeBtn, UIAroundPivot.BottomRight)
    GUI.RegisterUIEvent(tenTimeBtn, UCE.PointerClick, "Pray_2UI", "OnTenWeaponsTimeBtnClick")
    GUI.SetData(tenTimeBtn, "prayItemIndex", itemIndex)

    local tenTime = GUI.CreateStatic(detailBg, "tenTime", "祈福十次", 240, 069, 100, 30, "system", false, true)
    GUI.SetAnchor(tenTime, UIAnchor.Center)
    GUI.SetPivot(tenTime, UIAroundPivot.Center)
    GUI.StaticSetAlignment(tenTime, TextAnchor.MiddleCenter)
    GUI.SetColor(tenTime, colorDark)
    GUI.StaticSetFontSize(tenTime, fontSizeDefault)

    -- 金钱
    local coinBg2, icon, numText = UILayout.CreateAttrBar(detailBg, "coinBg2", 190, 50, 117, UILayout.TopLeft)
	GUI.SetPositionX(icon, -12)
end

function Pray_2UI.PetOutItem(parent, itemIndex)
    --背景

    local itemBg =
        GUI.ImageCreate(parent, "itemBg" .. itemIndex, TitemBg[itemIndex], TitemPosX[itemIndex], -239, false, 330, 530)
    UILayout.SetSameAnchorAndPivot(itemBg, UILayout.Top)

    local table = GUI.ImageCreate(parent, "table", "1801408010", 0, 150, false)
    local image1 = GUI.ImageCreate(table, "image1", "1800201090", 0, -185, false, 415, 415)
    local image = GUI.ImageCreate(table, "image", "1801608060", 15, -260, false, 470, 470)
    local flower1 = GUI.ImageCreate(table, "flower1", "1800007110", -130, -45, false, 100, 100)
    local flower2 = GUI.ImageCreate(table, "flower2", "1800007120", 140, -170, false)
    local name = GUI.ImageCreate(table, "name", "1800704020", 120, -100, false, 35, 70)
    local text = GUI.CreateStatic(table,"text","高阶灵宠 应有尽有",0,170,300,50,"100");
	GUI.SetAnchor(text,UIAnchor.TopLeft)
	GUI.SetPivot(text,UIAroundPivot.TopLeft)
	GUI.StaticSetFontSize(text,35)
	
	--设置颜色渐变
	GUI.StaticSetIsGradientColor(text,true)
	GUI.StaticSetGradient_ColorTop(text,Color.New(255/255,244/255,139/255,255/255))
	--GUI.StaticSetGradient_ColorLeft(text,UIDefine.BrownColor)--文本左边顶点颜色
	--GUI.StaticSetGradient_SplitText(text,true)--是否控制单字的顶点颜色
	
	--设置描边
	GUI.SetIsOutLine(text,true)
	GUI.SetOutLine_Distance(text,3)
	GUI.SetOutLine_Color(text,Color.New(182/255,52/255,40/255,255/255))
	
	--设置阴影
	GUI.SetIsShadow(text,true)
	GUI.SetShadow_Distance(text,Vector2.New(0,-1))
	GUI.SetShadow_Color(text,UIDefine.BlackColor)

    --图标
    local iconBg = GUI.ImageCreate(itemBg, "iconBg", "1800601180", 0, -118, false)
    UILayout.SetSameAnchorAndPivot(iconBg, UILayout.Center)

    local itemIcon = ItemIcon.Create(iconBg, "itemIcon", 0, 0)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "Pray_2UI", "OnPetBtnClick")
    GUI.SetData(itemIcon, "tipIndex", itemIndex)

    --标题
    local titleBg = GUI.ImageCreate(itemBg, "titleBg", "1800601230", -3, -223, false, 277, 54)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Center)
    local itemTitle = GUI.RichEditCreate(titleBg, "itemTitle", "", 0, 0, 270, 54, "system", true)
    UILayout.SetSameAnchorAndPivot(itemTitle, UILayout.Center)
    GUI.StaticSetAlignment(itemTitle, TextAnchor.UpperCenter)
    GUI.SetColor(itemTitle, colorWhite)
    GUI.StaticSetFontSize(itemTitle, fontSizeDefault)

    --提示按钮
    local tipBtn = GUI.ButtonCreate(itemBg, "tipBtn", "1800702030", -11, 204, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(tipBtn, UILayout.TopRight)
    --    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick, "Pray_2UI", "OnTipsBtnClick")
    --    GUI.SetData(tipBtn,"tipIndex",itemIndex)
    GUI.SetVisible(tipBtn, false)

    --item抽奖描述
    local descBg = GUI.ImageCreate(itemBg, "descBg", "1800601170", 0, 28, false)
    UILayout.SetSameAnchorAndPivot(descBg, UILayout.Center)

    --    local itemSelectDescScroll = GUI.ScrollRectCreate( 100), "itemSelectDescScroll", 0, 0, 233, 68, 0, false, Vector2.New(233, descBg, UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    --    GUI.SetAnchor(itemSelectDescScroll, UIAnchor.Center)
    --    GUI.SetPivot(itemSelectDescScroll, UIAroundPivot.Center)
    --    GUI.ScrollRectSetChildAnchor(itemSelectDescScroll, UIAnchor.Top)
    --    GUI.ScrollRectSetChildPivot(itemSelectDescScroll, UIAroundPivot.Top)
    --    GUI.ScrollRectSetChildSpacing(itemSelectDescScroll, Vector2.New(0, 0))

    local itemDesc = GUI.RichEditCreate(descBg, "itemDesc", "", 0, 0, 233, 68, "system", true)
    UILayout.SetSameAnchorAndPivot(itemDesc, UILayout.Center)
    GUI.StaticSetAlignment(itemDesc, TextAnchor.MiddleCenter)
    GUI.SetColor(itemDesc, colorDark)
    GUI.StaticSetFontSize(itemDesc, fontSizeSmall)

    --抽奖详细信息
    local detailBg = GUI.GroupCreate(itemBg, "detailBg", 1, 0, 0, 0)
    UILayout.SetSameAnchorAndPivot(detailBg, UILayout.BottomLeft)
    GUI.SetVisible(detailBg, true)
    --剩余道具
    local propNum = GUI.CreateStatic(detailBg, "propNum", "", 158, 147, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(propNum, UILayout.Center)
    GUI.StaticSetAlignment(propNum, TextAnchor.MiddleCenter)
    GUI.SetColor(propNum, colorWhite)
    GUI.StaticSetFontSize(propNum, fontSizeSmall)

    --免费次数
    local freeTime = GUI.CreateStatic(detailBg, "freeTime", "", -16, 120, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(freeTime, UILayout.TopLeft)
    GUI.StaticSetAlignment(freeTime, TextAnchor.MiddleCenter)
    GUI.SetColor(freeTime, colorWhite)
    GUI.StaticSetFontSize(freeTime, fontSizeSmall)

    --折扣优惠
    local discount = GUI.CreateStatic(detailBg, "discount", "9折优惠", 343, 120, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(discount, UILayout.TopRight)
    GUI.StaticSetAlignment(discount, TextAnchor.MiddleCenter)
    GUI.SetColor(discount, colorWhite)
    GUI.StaticSetFontSize(discount, fontSizeSmall)

    --祈福一次
    local oneTimeBtn = GUI.ButtonCreate(detailBg, "oneTimeBtn", "1800602290", 8, 5, Transition.ColorTint)
    GUI.SetAnchor(oneTimeBtn, UIAnchor.BottomLeft)
    GUI.SetPivot(oneTimeBtn, UIAroundPivot.BottomLeft)
    GUI.RegisterUIEvent(oneTimeBtn, UCE.PointerClick, "Pray_2UI", "OnOnePetTimeBtnClick")
    GUI.SetData(oneTimeBtn, "prayItemIndex", itemIndex)

    local oneTime = GUI.CreateStatic(detailBg, "oneTime", "祈福一次", 86, 69, 100, 30, "system", false, true)
    GUI.SetAnchor(oneTime, UIAnchor.Center)
    GUI.SetPivot(oneTime, UIAroundPivot.Center)
    GUI.StaticSetAlignment(oneTime, TextAnchor.MiddleCenter)
    GUI.SetColor(oneTime, colorDark)
    GUI.StaticSetFontSize(oneTime, fontSizeDefault)

    -- 金钱
    local coinBg1, icon, numText = UILayout.CreateAttrBar(detailBg, "coinBg1", 30, 50, 117, UILayout.TopLeft)
	GUI.SetPositionX(icon, -12)
	
    --祈福十次
    local tenTimeBtn =
        GUI.ButtonCreate(detailBg, "tenTimeBtn", "1800402110", 319, 5, Transition.ColorTint, "", 152, 86, false)
    GUI.SetAnchor(tenTimeBtn, UIAnchor.BottomRight)
    GUI.SetPivot(tenTimeBtn, UIAroundPivot.BottomRight)
    GUI.RegisterUIEvent(tenTimeBtn, UCE.PointerClick, "Pray_2UI", "OnTenPetTimeBtnClick")
    GUI.SetData(tenTimeBtn, "prayItemIndex", itemIndex)

    local tenTime = GUI.CreateStatic(detailBg, "tenTime", "祈福十次", 240, 069, 100, 30, "system", false, true)
    GUI.SetAnchor(tenTime, UIAnchor.Center)
    GUI.SetPivot(tenTime, UIAroundPivot.Center)
    GUI.StaticSetAlignment(tenTime, TextAnchor.MiddleCenter)
    GUI.SetColor(tenTime, colorDark)
    GUI.StaticSetFontSize(tenTime, fontSizeDefault)

    -- 金钱
    local coinBg2, icon, numText = UILayout.CreateAttrBar(detailBg, "coinBg2", 190, 50, 117, UILayout.TopLeft)
	GUI.SetPositionX(icon, -12)
end

function Pray_2UI.FestOutItem()
    local parent = _gt.GetUI("festPray")
    local itemBg =
        GUI.ImageCreate(parent, "itemBg", "1800601210",340 , -239, false, 330, 530)
    UILayout.SetSameAnchorAndPivot(itemBg, UILayout.Top)

    --图标
    local iconBg = GUI.ImageCreate(itemBg, "iconBg", "1800601180", 0, -118, false)
    UILayout.SetSameAnchorAndPivot(iconBg, UILayout.Center)

    local itemIcon = ItemIcon.Create(iconBg, "itemIcon", 0, 0)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "Pray_2UI", "OnFestBtnClick")
    -- GUI.SetData(itemIcon, "tipIndex", itemIndex)

    --标题
    local titleBg = GUI.ImageCreate(itemBg, "titleBg", "1800601230", -3, -223, false, 277, 54)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Center)
    local itemTitle = GUI.RichEditCreate(titleBg, "itemTitle", "", 0, 0, 270, 54, "system", true)
    UILayout.SetSameAnchorAndPivot(itemTitle, UILayout.Center)
    GUI.StaticSetAlignment(itemTitle, TextAnchor.UpperCenter)
    GUI.SetColor(itemTitle, colorWhite)
    GUI.StaticSetFontSize(itemTitle, fontSizeDefault)

    --提示按钮
    local tipBtn = GUI.ButtonCreate(itemBg, "tipBtn", "1800702030", -11, 204, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(tipBtn, UILayout.TopRight)
    --    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick, "Pray_2UI", "OnTipsBtnClick")
    --    GUI.SetData(tipBtn,"tipIndex",itemIndex)
    GUI.SetVisible(tipBtn, false)

    --item抽奖描述
    local descBg = GUI.ImageCreate(itemBg, "descBg", "1800601170", 0, 28, false)
    UILayout.SetSameAnchorAndPivot(descBg, UILayout.Center)

    --    local itemSelectDescScroll = GUI.ScrollRectCreate( 100), "itemSelectDescScroll", 0, 0, 233, 68, 0, false, Vector2.New(233, descBg, UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    --    GUI.SetAnchor(itemSelectDescScroll, UIAnchor.Center)
    --    GUI.SetPivot(itemSelectDescScroll, UIAroundPivot.Center)
    --    GUI.ScrollRectSetChildAnchor(itemSelectDescScroll, UIAnchor.Top)
    --    GUI.ScrollRectSetChildPivot(itemSelectDescScroll, UIAroundPivot.Top)
    --    GUI.ScrollRectSetChildSpacing(itemSelectDescScroll, Vector2.New(0, 0))

    local itemDesc = GUI.RichEditCreate(descBg, "itemDesc", "", 0, 0, 233, 68, "system", true)
    UILayout.SetSameAnchorAndPivot(itemDesc, UILayout.Center)
    GUI.StaticSetAlignment(itemDesc, TextAnchor.MiddleCenter)
    GUI.SetColor(itemDesc, colorDark)
    GUI.StaticSetFontSize(itemDesc, fontSizeSmall)

    --抽奖详细信息
    local detailBg = GUI.GroupCreate(itemBg, "detailBg", 1, 0, 0, 0)
    UILayout.SetSameAnchorAndPivot(detailBg, UILayout.BottomLeft)
    GUI.SetVisible(detailBg, true)
    --剩余道具
    local propNum = GUI.CreateStatic(detailBg, "propNum", "", 158, 147, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(propNum, UILayout.Center)
    GUI.StaticSetAlignment(propNum, TextAnchor.MiddleCenter)
    GUI.SetColor(propNum, colorWhite)
    GUI.StaticSetFontSize(propNum, fontSizeSmall)

    --免费次数
    local freeTime = GUI.CreateStatic(detailBg, "freeTime", "", -16, 120, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(freeTime, UILayout.TopLeft)
    GUI.StaticSetAlignment(freeTime, TextAnchor.MiddleCenter)
    GUI.SetColor(freeTime, colorWhite)
    GUI.StaticSetFontSize(freeTime, fontSizeSmall)

    --折扣优惠
    local discount = GUI.CreateStatic(detailBg, "discount", "9折优惠", 343, 120, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(discount, UILayout.TopRight)
    GUI.StaticSetAlignment(discount, TextAnchor.MiddleCenter)
    GUI.SetColor(discount, colorWhite)
    GUI.StaticSetFontSize(discount, fontSizeSmall)

    --祈福一次
    local oneTimeBtn = GUI.ButtonCreate(detailBg, "oneTimeBtn", "1800602290", 8, 5, Transition.ColorTint)
    GUI.SetAnchor(oneTimeBtn, UIAnchor.BottomLeft)
    GUI.SetPivot(oneTimeBtn, UIAroundPivot.BottomLeft)
    GUI.RegisterUIEvent(oneTimeBtn, UCE.PointerClick, "Pray_2UI", "OnOneFestTimeBtnClick")
    GUI.SetData(oneTimeBtn, "prayItemIndex", itemIndex)

    local oneTime = GUI.CreateStatic(detailBg, "oneTime", "祈福一次", 86, 69, 100, 30, "system", false, true)
    GUI.SetAnchor(oneTime, UIAnchor.Center)
    GUI.SetPivot(oneTime, UIAroundPivot.Center)
    GUI.StaticSetAlignment(oneTime, TextAnchor.MiddleCenter)
    GUI.SetColor(oneTime, colorDark)
    GUI.StaticSetFontSize(oneTime, fontSizeDefault)

    -- 金钱
    local coinBg1, icon, numText = UILayout.CreateAttrBar(detailBg, "coinBg1", 30, 50, 117, UILayout.TopLeft)
	GUI.SetPositionX(icon, -12)
	
    --祈福十次
    local tenTimeBtn =
        GUI.ButtonCreate(detailBg, "tenTimeBtn", "1800402110", 319, 5, Transition.ColorTint, "", 152, 86, false)
    GUI.SetAnchor(tenTimeBtn, UIAnchor.BottomRight)
    GUI.SetPivot(tenTimeBtn, UIAroundPivot.BottomRight)
    GUI.RegisterUIEvent(tenTimeBtn, UCE.PointerClick, "Pray_2UI", "OnTenFestTimeBtnClick")
    GUI.SetData(tenTimeBtn, "prayItemIndex", itemIndex)

    local tenTime = GUI.CreateStatic(detailBg, "tenTime", "祈福十次", 240, 069, 100, 30, "system", false, true)
    GUI.SetAnchor(tenTime, UIAnchor.Center)
    GUI.SetPivot(tenTime, UIAroundPivot.Center)
    GUI.StaticSetAlignment(tenTime, TextAnchor.MiddleCenter)
    GUI.SetColor(tenTime, colorDark)
    GUI.StaticSetFontSize(tenTime, fontSizeDefault)

    -- 金钱
    local coinBg2, icon, numText = UILayout.CreateAttrBar(detailBg, "coinBg2", 190, 50, 117, UILayout.TopLeft)
	GUI.SetPositionX(icon, -12)

    local red = GUI.ImageCreate(parent,"red", "1800608630" , -180, 25, false, 700, 535)
    _gt.BindName(red,"red")

    local back = GUI.ImageCreate(red,"back", "1801706040" ,195, -250, false, 310, 45)
    _gt.BindName(back,"back")

    local text = GUI.CreateStatic(red,"text","祈福将有机会获得\n".."  强力SSR随从\n".."    更有诸更更多好礼可得",270,80,350,140,"201");
    GUI.StaticSetLineSpacing(text,1.5)
	GUI.SetAnchor(text,UIAnchor.TopLeft)
	GUI.SetPivot(text,UIAroundPivot.TopLeft)
	GUI.StaticSetFontSize(text,25)
	--设置颜色渐变
	GUI.StaticSetIsGradientColor(text,true)
	GUI.StaticSetGradient_ColorTop(text,Color.New(255/255,244/255,139/255,255/255))
	--设置描边
	GUI.SetIsOutLine(text,true)
	GUI.SetOutLine_Distance(text,3)
	GUI.SetOutLine_Color(text,Color.New(182/255,52/255,40/255,255/255))
	--设置阴影
	GUI.SetIsShadow(text,true)
	GUI.SetShadow_Distance(text,Vector2.New(0,-1))
	GUI.SetShadow_Color(text,UIDefine.BlackColor)

    local text1 = GUI.CreateStatic(red,"text1","",470,40,350,140,"201");
    _gt.BindName(text1,"text1")
    GUI.StaticSetLineSpacing(text1,1.5)
	GUI.SetAnchor(text1,UIAnchor.TopLeft)
	GUI.SetPivot(text1,UIAroundPivot.TopLeft)
	GUI.StaticSetFontSize(text1,30)
	--设置颜色渐变
	GUI.StaticSetIsGradientColor(text1,true)
	GUI.StaticSetGradient_ColorTop(text1,Color.New(255/255,200/255,100/255,255/255))
	--设置描边
	GUI.SetIsOutLine(text1,true)
	GUI.SetOutLine_Distance(text1,3)
	GUI.SetOutLine_Color(text1,Color.New(182/255,52/255,40/255,255/255))
	--设置阴影
	GUI.SetIsShadow(text1,true)
	GUI.SetShadow_Distance(text1,Vector2.New(0,-1))
	GUI.SetShadow_Color(text1,UIDefine.BlackColor)

    local text2 = GUI.CreateStatic(red,"text2","",420,80,350,140,"201");
    _gt.BindName(text2,"text2")
    GUI.StaticSetLineSpacing(text2,1.5)
	GUI.SetAnchor(text2,UIAnchor.TopLeft)
	GUI.SetPivot(text2,UIAroundPivot.TopLeft)
	GUI.StaticSetFontSize(text2,30)
	--设置颜色渐变
	GUI.StaticSetIsGradientColor(text2,true)
	GUI.StaticSetGradient_ColorTop(text2,Color.New(255/255,200/255,100/255,255/255))
	--设置描边
	GUI.SetIsOutLine(text2,true)
	GUI.SetOutLine_Distance(text2,3)
	GUI.SetOutLine_Color(text2,Color.New(182/255,52/255,40/255,255/255))
	--设置阴影
	GUI.SetIsShadow(text2,true)
	GUI.SetShadow_Distance(text2,Vector2.New(0,-1))
	GUI.SetShadow_Color(text2,UIDefine.BlackColor)

    local figure = GUI.ImageCreate(red,"figure", "1800608680", -120, 20, false, 440, 465)

    local DialogBoxBg = GUI.ImageCreate(figure, "DialogBoxBg","1800700240",-50,-350);
	UILayout.SetSameAnchorAndPivot(DialogBoxBg, UILayout.TopLeft);
	data = TweenData.New()
	data.Type = GUITweenType.DOLocalMoveY
	data.Duration = 2
	data.To = Vector3.New(0,  15, 0)
	local Keyframe ="((-2.311231,-2.311231,34,-0.00701759,-0.002449036),(0.03038119,0.03038119,0,0.2328766,-0.5569),(0.008459799,0.008459799,0,0.7485815,0.5560657),(-2.333295,-2.333295,34,0.987442,-0.001266479))"
	data.Keyframe = TOOLKIT.Str2Curve(Keyframe)
	data.LoopType = UITweenerStyle.Loop
	GUI.DOTween(DialogBoxBg,data)
	GUI.SetScale(DialogBoxBg,Vector3(1,-1,-1))

	local msg = [[上天赐福，珍宝现世！]]
	local DialogBoxText = GUI.CreateStatic(DialogBoxBg,"DialogBoxText", msg,20,-10,300,100,"system",false,false);
	GUI.StaticSetFontSize(DialogBoxText, 22)
	GUI.StaticSetAlignment(DialogBoxText, TextAnchor.MiddleLeft)
	UILayout.SetSameAnchorAndPivot(DialogBoxText, UILayout.Center);
	GUI.SetColor(DialogBoxText,Color.New(154/255,109/255,62/255,255/255))
	GUI.SetScale(DialogBoxText,Vector3(1,-1,1))
	_gt.BindName(DialogBoxText, "DialogBoxText");

    local festText = GUI.CreateStatic(red,"festText","节日限定",40,10,220,70,"104");
	GUI.SetAnchor(festText,UIAnchor.TopLeft)
	GUI.SetPivot(festText,UIAroundPivot.TopLeft)
	GUI.StaticSetFontSize(festText,50)
	
	--设置颜色渐变
	GUI.StaticSetIsGradientColor(festText,true)
	GUI.StaticSetGradient_ColorTop(festText,Color.New(255/255,244/255,139/255,255/255))
	--GUI.StaticSetGradient_ColorLeft(festText,UIDefine.BrownColor)--文本左边顶点颜色
	--GUI.StaticSetGradient_SplitText(festText,true)--是否控制单字的顶点颜色
	
	--设置描边
	GUI.SetIsOutLine(festText,true)
	GUI.SetOutLine_Distance(festText,3)
	GUI.SetOutLine_Color(festText,Color.New(182/255,52/255,40/255,255/255))
	
	--设置阴影
	GUI.SetIsShadow(festText,true)
	GUI.SetShadow_Distance(festText,Vector2.New(0,-1))
	GUI.SetShadow_Color(festText,UIDefine.BlackColor)

    Pray_2UI.itemList = {}
    Pray_2UI.festCountdown()
end
--限时活动
function Pray_2UI.GetConfig(tabIndex)
    if not data.cfg then
        return
    end

    local pageBg = nil

    if data.cfg[tabIndex].ShowImgKey == "限时预览_1" then
        pageBg = Pray_2UI.uinode.festPray
    end

    if pageBg == nil then
        return
    end

    local config = data.cfg[#data.cfg].ShowGoods.GuardList
    local guardData = data.cfg[#data.cfg].ShowGoods.ItemList
    local inspect = require("inspect")
  
    local n = 0;
    if guardData and #guardData > 0 then
        n = n + 1
        Pray_2UI.itemList[n] = {KeyName = config[1]}
        Pray_2UI.itemList[n].Num = 1
        Pray_2UI.itemList[n].Bind = config[2]
        Pray_2UI.itemList[n].isGuard = true
    end
    for i, v in ipairs(guardData) do
      if type(v) == "string" then
        n = n + 1;
        Pray_2UI.itemList[n] = {KeyName = v };
        if type(guardData[i + 1]) == "number" then
          Pray_2UI.itemList[n].Num = config[i + 1];
        elseif n then
          Pray_2UI.itemList[n].Num = 1;
        end
  
        if type(guardData[i + 2]) == "number" then
          Pray_2UI.itemList[n].Bind = guardData[i + 2];
        else
          Pray_2UI.itemList[n].Bind = 1;
        end
      end
    end
  
    local x =-140;
    local y = 0;
    local red = _gt.GetUI("red")
    for i = 1, #Pray_2UI.itemList do
      local data=Pray_2UI.itemList[i]
      local itemName = data.KeyName
      if string.find(itemName,"#") then
        itemName = string.split(itemName,"#")[1]
      end
      local itemDB =DB.GetOnceItemByKey2(itemName);
      if data.isGuard then
        local guardDB = DB.GetOnceGuardByKey2(data.KeyName)
        itemDB = DB.GetOnceItemByKey1(guardDB.CallItemIcon);
      end
      x = x + 90;
      if i~=1 and math.fmod(i-1, 4) == 0 then
        y = y + 90;
        x = x - 90 * 4 + 60;
      end
  
      local itemIcon = GUI.GetChild(red,"itemIcon" .. i)
      if itemIcon == nil then
        itemIcon = ItemIcon.Create(red, "itemIcon" .. i, x, y)
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[itemDB.Grade]);
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, itemDB.Icon);
        if data.isGuard then
            -- 侍从头像  调整大小
            GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,71,70);
            local effect = GUI.RichEditCreate(itemIcon, "effect", "", 1, 22, 160, 185)
            UILayout.SetAnchorAndPivot(effect, UIAnchor.Center, UIAroundPivot.Center)
            GUI.StaticSetFontSize(effect, 22)
            GUI.SetIsRaycastTarget(effect, false)
            GUI.SetScale(effect, Vector3.New(0.75, 0.75, 0.75))
            GUI.SetIsRaycastTarget(icon, true)
            local effect = GUI.GetChild(itemIcon, "effect")
            GUI.StaticSetText(effect, "#IMAGE3407700000#")
        else
            GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60);
        end
        if data.Bind ~= 1 or data.isGuard then
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil);
        else
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120);
            GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
        end
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, data.Num);
        _gt.BindName(itemIcon, "itemIcon" .. i);
        GUI.SetData(itemIcon,"Index",i);
        GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "Pray_2UI", "OnItemClick");
      end
    end
end

function Pray_2UI.OnItemClick(guid)
    local itemIcon = GUI.GetByGuid(guid);
    local index = tonumber(GUI.GetData(itemIcon,"Index"));
    local data=Pray_2UI.itemList[index]
    if data.isGuard then
      local guardDB = DB.GetOnceGuardByKey2(data.KeyName)
      if not GlobalProcessing then
        require "GlobalProcessing"
      end
      GlobalProcessing.ShowGuardInfo(guardDB.Id)
    elseif data then
      local red = _gt.GetUI("red")
      local itemTips=Tips.CreateByItemKeyName(data.KeyName,red,"itemTips",-250,0)
      UILayout.SetSameAnchorAndPivot(itemTips, UILayout.Center);
    end
end

function Pray_2UI.festCountdown()
    local back = _gt.GetUI("back")
    local txt = GUI.CreateStatic(back, "txt", "", 20, 0, 260, 35)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetFontSize(txt, 25)
    GUI.SetColor(txt, Color.New(255/255,255/255,255/255,255/255))
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    _gt.BindName(txt, "txt")
end

function Pray_2UI.CountRankTime()

    if data.cfg[#data.cfg].ShowImgKey ~= "限时预览_1" then
        return
    end
    local TimeLimit = data.cfg[#data.cfg].TimeLimit
    local inspect = require("inspect")
    print(inspect(TimeLimit))
    local nowTime = os.date("!%Y-%m-%d %H:%M:%S",CL.GetServerTickCount())
    Pray_2UI.startTime = UIDefine.GetTimeCountByFormat(TimeLimit[1])
    Pray_2UI.endTime = UIDefine.GetTimeCountByFormat(TimeLimit[2])
    Pray_2UI.nowtime = UIDefine.GetTimeCountByFormat(nowTime)
    print(Pray_2UI.startTime)
    print(Pray_2UI.endTime)
    print(Pray_2UI.nowtime)
    local now = Pray_2UI.endTime - Pray_2UI.nowtime
    local txt = _gt.GetUI("txt")
    if now >0 then
        -- GUI.StaticSetText(txt,"活动剩余时间")
        -- GUI.SetPositionX(txt, 16)
        local str = {}
        str[1] = math.floor(now / 86400) -- 天
        str[2] = math.floor(now % 86400 / 3600)
        str[3] = math.floor(now % 3600 / 60)
        str[4] = now % 60

        for i = 3, 4, 1 do
            if str[i] < 10 then
                str[i] = "0" .. str[i]
            end
        end
        GUI.StaticSetText(txt,"剩余:"..str[1].."天"..str[2].."小时"..str[3].."分")

    end
end

-- function Pray_2UI.RefreshRankTime()
--     Pray_2UI.CountRankTime()
--     if not Pray_2UI.RankTimer then
--         Pray_2UI.RankTimer = Timer.New(Pray_2UI.CountRankTime, 1, -1)
--     end
--     Pray_2UI.RankTimer:Stop()
--     Pray_2UI.RankTimer:Start()
-- end

--刷新祈福界面
function Pray_2UI.Refresh()
    data.cfg = Pray_2UI.ServerData
    local panel = _gt.GetUI("panel")
    local tabList = {}
    if Pray_2UI.nowtime == nil then
        Pray_2UI.CountRankTime()
    end
    local flag = false
    if data.cfg[#data.cfg].ShowImgKey == "限时预览_1" then
        if Pray_2UI.endTime - Pray_2UI.nowtime > 0  and Pray_2UI.nowtime - Pray_2UI.startTime >= 0  then
            flag = true
        end
    end
    -- if Pray_2UI.endTime - Pray_2UI.nowtime > 0  and Pray_2UI.nowtime - Pray_2UI.startTime >= 0  then
    --     flag = true
    -- end

    for i = 1, #data.cfg do
        local value = data.cfg[i]
        local TabName = value.TabName
        local btnName = ""
        local fucName = ""
        if value.ShowImgKey == "神兵预览_1" then
            btnName = "weaponsTabBtn"
            fucName = "weaponsBtnClick"
        elseif value.ShowImgKey == "灵宠预览_1" then
            btnName = "petTabBtn"
            fucName = "petTabBtnClick"
        elseif value.ShowImgKey == "限时预览_1" and flag then
            btnName = "festTabBtn"
            fucName = "festTabBtnClick"
        end
        if btnName ~= "" then
            tabList[i] = {TabName,btnName,fucName}
        end
    end
    
    -- for i = #tabList, 1,-1 do
    --     local TabName = tabList[i][1]
    --     if TabName == nil then
    --         table.remove(tabList,i)
    --     end
    -- end
    -- assert(loadstring("Pray_2UI".. tabList[1].fucName))
    UILayout.CreateRightTab(tabList, "Pray_2UI");
    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)
    UILayout.OnTabClick(Pray_2UI.tabIndex, tabList);
    for i = 1, #tabList do
        local page = _gt.GetUI("tabPage" .. i);
        GUI.SetVisible(page, i == Pray_2UI.tabIndex);
    end
    local inspect = require("inspect")
    -- print(inspect(data.cfg))
    -- print(Pray_2UI.tabIndex)
    -- assert(loadstring("Pray_2UI.".. tabList[Pray_2UI.tabIndex][3].."()"))()

    if data.cfg[Pray_2UI.tabIndex].ShowImgKey == "神兵预览_1" then
        Pray_2UI.RefreshweaponsPage()
    elseif data.cfg[Pray_2UI.tabIndex].ShowImgKey == "灵宠预览_1" then
        Pray_2UI.RefreshPetPage()
    elseif data.cfg[Pray_2UI.tabIndex].ShowImgKey == "限时预览_1" then
        Pray_2UI.RefreshFestPage()
    end
    Pray_2UI.ClientRefresh()
end
--打开界面太卡了，分开做
-- function Pray_2UI.RefreshRewardsItemData(index)
-- 	if data.cfg == nil or data.cfg[index] == nil or Pray_2UI.ServerData == nil or Pray_2UI.ServerData[index] == nil or Pray_2UI.ServerData[index].Rewards_Shows == nil then
-- 		test("Pray_2UI.RefreshRewardsItemData 错误")
-- 		return false
-- 	end
-- 	data.cfg[index]["Rewards_Item"] = LogicDefine.SeverItems2ClientItems(Pray_2UI.ServerData[index].Rewards_Shows)
-- 	return true
-- end

function Pray_2UI.ClientRefresh()
    local NextFreeFlag = false
    for i = 1, #data.cfg do
        for j = 1, #data.cfg[i] do
            local id =  DB.GetOnceItemByKey2(data.cfg[i][j].ItemKey).Id
            data.cfg[i][j].ItemNums = LD.GetItemCountById(id, item_container_type.item_container_bag)
            data.cfg[i][j].FreeTimes = data.cfg[i][j].DayFreeMax - (Pray_2UI.FreeTimeUsed[i][j] or 0)
            data.cfg[i][j].NextFreeSecond = CL.GetIntCustomData("PrayNextFreeTime" .. i .. "_".. j)
            if data.cfg[i][j].FreeTimes > 0 and data.cfg[i][j].NextFreeSecond ~= nil then
                NextFreeFlag = true
            end
        end
    end
    Pray_2UI.RefreshUI()
    if NextFreeFlag then
        Pray_2UI.onLineCountDownStart()
    else
        if Pray_2UI.onLineTimer == nil then
        else
            Pray_2UI.onLineTimer:Stop()
            Pray_2UI.onLineTimer:Reset(Pray_2UI.SetOnlineTime, 1, -1, true)
        end
    end
end

function Pray_2UI.onLineCountDownStart()
    if Pray_2UI.onLineTimer == nil then
        Pray_2UI.onLineTimer = Timer.New(Pray_2UI.SetOnlineTime, 1, -1, true)
        for i = 1, #Pray_2UI_redpoint do
            Pray_2UI_redpoint[i] = 1
        end
        test("新计时")
    else
        Pray_2UI.onLineTimer:Stop()
        Pray_2UI.onLineTimer:Reset(Pray_2UI.SetOnlineTime, 1, -1, true)
    end
    Pray_2UI.onLineTimer:Start()
end

function Pray_2UI.RefreshUI()
    test("刷新祈福")
    if Pray_2UI.uinode.pagePray == nil then
        print("***************")
        return
    end

    if Pray_2UI.uinode.petPray == nil then
        print("++++++++++++++++++")
        return
    end

    if Pray_2UI.uinode.festPray == nil then
        print("---------------")
        return
    end

    if data.cfg == nil then
        test("祈福数据为空")
        return
    end
    
    local text1 = _gt.GetUI("text1")
    GUI.StaticSetText(text1,"  春节限定")

    local text2 = _gt.GetUI("text2")
    GUI.StaticSetText(text2,"  白骨夫人")

    Pray_2UI.prayPageRefresh(Pray_2UI.tabIndex)
    -- Pray_2UI.SetOnlineTime(Pray_2UI.tabIndex)
    Pray_2UI.festPageRefresh()
    Pray_2UI.SetOnlineTime(Pray_2UI.tabIndex)
    Pray_2UI.GetConfig(Pray_2UI.tabIndex)
    Pray_2UI.CountRankTime()

    -- local txt = _gt.GetUI("txt")
    -- GUI.StaticSetText(txt, "剩余时间" .. "123")

end

function Pray_2UI.prayPageRefresh(tabIndex)
    local pageBg = nil
    if data.cfg[tabIndex].ShowImgKey == "神兵预览_1" then
        pageBg = Pray_2UI.uinode.pagePray
    elseif data.cfg[tabIndex].ShowImgKey == "灵宠预览_1" then
        pageBg = Pray_2UI.uinode.petPray
    end

    if pageBg == nil then
        return
    end

    for i = 1, #data.cfg[tabIndex] do
        local itemParet = GUI.GetChild(pageBg, "itemBg" .. i)
        local coinBg1 = GUI.GetChild(itemParet, "coinBg1")
        local coinBg2 = GUI.GetChild(itemParet, "coinBg2")
        local itemTitle = GUI.GetChild(itemParet, "itemTitle")
        local itemIcon = GUI.GetChild(itemParet, "itemIcon")
        local itemDesc = GUI.GetChild(itemParet, "itemDesc")
        local propNum = GUI.GetChild(itemParet, "propNum")
        local freeTime = GUI.GetChild(itemParet, "freeTime")
        local discount = GUI.GetChild(itemParet, "discount")
        local price1 = GUI.GetChild(coinBg1, "numText")
        local price2 = GUI.GetChild(coinBg2, "numText")
        local oneTimeBtn = GUI.GetChild(itemParet, "oneTimeBtn")

        local data = data.cfg[tabIndex][i]
        if data == nil then
            return
        end

        local keyInfo = DB.GetOnceItemByKey2(data.ItemKey)
        GUI.StaticSetText(itemTitle, "" .. data.Title)
        local itemID = data.ShowItem
        test(data.ShowItem)
        if itemID ~= nil then
            ItemIcon.BindItemKeyName(itemIcon, itemID)
            GUI.SetData(itemIcon, "itemId", itemID)
        end
        GUI.StaticSetText(itemDesc, data.Desc)
        GUI.StaticSetText(propNum, "剩余抽奖道具: " .. data.ItemNums)

        -- 设置祈福一次按钮显示
        if data.NextFreeSecond ~= nil then
            if data.FreeTimes > 0 and data.NextFreeSecond == 0 then
                UILayout.RefreshAttrBar(coinBg1, nil, "本次免费")
                GUI.SetColor(price1, colorWhite)
            elseif UIDefine.MoneyTypes[data.MoneyType] == nil or data.ItemNums > 0 then
                if data.ItemNums < 1 then
                    GUI.SetColor(price1, UIDefine.RedColor)
                else
                    GUI.SetColor(price1, colorWhite)
                end
                UILayout.RefreshAttrBar2(coinBg1, keyInfo.Icon, "×1")
            else
                UILayout.RefreshAttrBar(coinBg1, UIDefine.GetMoneyEnum(data.MoneyType), data.OncePrice)
                GUI.SetColor(price1, colorWhite)
            end
        end
            --设置祈福十次按钮显示
        if UIDefine.MoneyTypes[data.MoneyType] == nil or data.ItemNums >= 10 then
            UILayout.RefreshAttrBar2(coinBg2, keyInfo.Icon, "×10")
            if data.ItemNums < 10 then
                GUI.SetColor(price2, UIDefine.RedColor)
            else
                GUI.SetColor(price2, colorWhite)
            end
        else
            UILayout.RefreshAttrBar(coinBg2, UIDefine.GetMoneyEnum(data.MoneyType), data.TenthPrice)
            GUI.SetColor(price2, colorWhite)
        end
        if UIDefine.MoneyTypes[data.MoneyType] ~= nil then
            GUI.SetVisible(discount, true)
            local per = string.format("%.1f", data.TenthPrice / (data.OncePrice * 10))
            per = per * 10
            GUI.StaticSetText(discount, per .. "折优惠")
        else
            GUI.SetVisible(discount, false)
        end
    end
end

function Pray_2UI.festPageRefresh()
    
    local itemParet = GUI.GetChild(Pray_2UI.uinode.festPray, "itemBg")
    local coinBg1 = GUI.GetChild(itemParet, "coinBg1")
    local coinBg2 = GUI.GetChild(itemParet, "coinBg2")
    local itemTitle = GUI.GetChild(itemParet, "itemTitle")
    local itemIcon = GUI.GetChild(itemParet, "itemIcon")
    local itemDesc = GUI.GetChild(itemParet, "itemDesc")
    local propNum = GUI.GetChild(itemParet, "propNum")
    local freeTime = GUI.GetChild(itemParet, "freeTime")
    local discount = GUI.GetChild(itemParet, "discount")
    local price1 = GUI.GetChild(coinBg1, "numText")
    local price2 = GUI.GetChild(coinBg2, "numText")
    local oneTimeBtn = GUI.GetChild(itemParet, "oneTimeBtn")

    local data = data.cfg[#data.cfg][1]
    if data == nil then
        return
    end

    local keyInfo = DB.GetOnceItemByKey2(data.ItemKey)
    GUI.StaticSetText(itemTitle, "" .. data.Title)
    local itemID = data.ShowItem
    test(data.ShowItem)
    if itemID ~= nil then
        ItemIcon.BindItemKeyName(itemIcon, itemID)
        GUI.SetData(itemIcon, "itemId", itemID)
    end
    GUI.StaticSetText(itemDesc, data.Desc)
    GUI.StaticSetText(propNum, "剩余抽奖道具: " .. data.ItemNums)

    -- 设置祈福一次按钮显示
    if data.NextFreeSecond ~= nil then
        -- if data.FreeTimes > 0 and data.NextFreeSecond == 0 then
        --     -- UILayout.RefreshAttrBar(coinBg1, nil, "本次免费")
        --     GUI.SetColor(price1, colorWhite)
        if UIDefine.MoneyTypes[data.MoneyType] == nil or data.ItemNums > 0 then
            if data.ItemNums < 1 then
                GUI.SetColor(price1, UIDefine.RedColor)
            else
                GUI.SetColor(price1, colorWhite)
            end
            UILayout.RefreshAttrBar2(coinBg1, keyInfo.Icon, "×1")
        else
            UILayout.RefreshAttrBar(coinBg1, UIDefine.GetMoneyEnum(data.MoneyType), data.OncePrice)
            GUI.SetColor(price1, colorWhite)
        end
    end
        --设置祈福十次按钮显示
    if UIDefine.MoneyTypes[data.MoneyType] == nil or data.ItemNums >= 10 then
        UILayout.RefreshAttrBar2(coinBg2, keyInfo.Icon, "×10")
        if data.ItemNums < 10 then
            GUI.SetColor(price2, UIDefine.RedColor)
        else
            GUI.SetColor(price2, colorWhite)
        end
    else
        UILayout.RefreshAttrBar(coinBg2, UIDefine.GetMoneyEnum(data.MoneyType), data.TenthPrice)
        GUI.SetColor(price2, colorWhite)
    end
    if UIDefine.MoneyTypes[data.MoneyType] ~= nil then
        GUI.SetVisible(discount, true)
        local per = string.format("%.1f", data.TenthPrice / (data.OncePrice * 10))
        per = per * 10
        GUI.StaticSetText(discount, per .. "折优惠")
    else
        GUI.SetVisible(discount, false)
    end

    -- Pray_2UI.SetOnlineTime()

end

function Pray_2UI.RefreshweaponsPage()
    local pagePray = _gt.GetUI("pagePray")
    local petPray = _gt.GetUI("petPray")
    local festPray = _gt.GetUI("festPray")
    GUI.SetVisible(pagePray,true)
    GUI.SetVisible(petPray,false)
    GUI.SetVisible(festPray,false)
end

function Pray_2UI.RefreshPetPage()
    local pagePray = _gt.GetUI("pagePray")
    local petPray = _gt.GetUI("petPray")
    local festPray = _gt.GetUI("festPray")
    GUI.SetVisible(pagePray,false)
    GUI.SetVisible(petPray,true)
    GUI.SetVisible(festPray,false)
end

function Pray_2UI.RefreshFestPage()
    local pagePray = _gt.GetUI("pagePray")
    local petPray = _gt.GetUI("petPray")
    local festPray = _gt.GetUI("festPray")
    GUI.SetVisible(pagePray,false)
    GUI.SetVisible(petPray,false)
    GUI.SetVisible(festPray,true)
end

--刷新祈福ITEM上的免费时间
function Pray_2UI.SetOnlineTime(tabIndex)
    tabIndex = tabIndex or Pray_2UI.tabIndex
    if not data.cfg then
        return
    end

    local pageBg = nil
    if data.cfg[tabIndex].ShowImgKey == "神兵预览_1" then
        pageBg = Pray_2UI.uinode.pagePray
    elseif data.cfg[tabIndex].ShowImgKey == "灵宠预览_1" then
        pageBg = Pray_2UI.uinode.petPray
    elseif data.cfg[tabIndex].ShowImgKey == "限时预览_1"  then
        pageBg = Pray_2UI.uinode.festPray
    end


    if pageBg == nil then
        return
    end

    for i = 1, 2 do
        local itemBgIndex = i
        local itemBgName = "itemBg" .. itemBgIndex
        if data.cfg[tabIndex].ShowImgKey == "限时预览_1" then
            itemBgName = "itemBg"
            itemBgIndex = 1
        end
        local itemParet = GUI.GetChild(pageBg, itemBgName)
        local freeTime = GUI.GetChild(itemParet, "freeTime")
        local oneTimeBtn = GUI.GetChild(itemParet, "oneTimeBtn")

        local coinBg1 = GUI.GetChild(itemParet, "coinBg1")
        local price1 = GUI.GetChild(coinBg1, "numText")
        local str, day, hours, minutes, sec = UIDefine.LeftTimeFormatEx(data.cfg[tabIndex][itemBgIndex].NextFreeSecond)
        local freefun = function()
            return day == 0 and hours == 0 and minutes == 0 and sec == 0
        end
        if data.cfg[1][itemBgIndex].DayFreeMax > 0 then
            if freefun() then
                GUI.StaticSetText(freeTime, "免费次数: " .. data.cfg[tabIndex][itemBgIndex].FreeTimes)
                -- test("redpoint =====================按钮"..i.."状态"..Pray_2UI_redpoint[i])
                if data.cfg[tabIndex][itemBgIndex].FreeTimes > 0 and Pray_2UI_redpoint[tabIndex] == 0 then
                    Pray_2UI_redpoint[tabIndex] = 1
                end
            else
                Pray_2UI_redpoint[tabIndex] = 0
                if data.cfg[tabIndex][itemBgIndex].NextFreeSecond ~= nil then
                    GUI.StaticSetText(freeTime, str .. "后免费")
                else
                    test("获取剩余免费时间失败")
                    GUI.StaticSetText(freeTime, "")
                end
            end
        end

        if data.cfg[tabIndex][itemBgIndex].FreeTimes > 0 and freefun() then
            UILayout.RefreshAttrBar(coinBg1, nil, "本次免费")
            GUI.SetColor(price1, colorWhite)
        end
    end
end

--点击TIPS按钮
function Pray_2UI.OnWeaponsBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(element, "tipIndex"))
    GUI.OpenWnd("ItemListUI", "可获得列表")
    local tmp = {}
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "神兵预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    for i = 1, #data.cfg[Pray_2UI.tabIndex][index].Rewards_Shows do
        local id =  DB.GetOnceItemByKey2(data.cfg[Pray_2UI.tabIndex][index].Rewards_Shows[i]).Id
        tmp[i] = {id = id}
    end
    ItemListUI.ShowTipsPage(tmp)
end

function Pray_2UI.OnPetBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(element, "tipIndex"))
    GUI.OpenWnd("ItemListUI", "可获得列表")
    local tmp = {}
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "灵宠预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    for i = 1, #data.cfg[Pray_2UI.tabIndex][index].Rewards_Shows do
        local id =  DB.GetOnceItemByKey2(data.cfg[Pray_2UI.tabIndex][index].Rewards_Shows[i]).Id
        tmp[i] = {id = id}
    end
    ItemListUI.ShowTipsPage(tmp)
end

function Pray_2UI.OnFestBtnClick()
    GUI.OpenWnd("ItemListUI", "可获得列表")
    local tmp = {}
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "限时预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    for i = 1, #data.cfg[Pray_2UI.tabIndex][1].Rewards_Shows do
        local id =  DB.GetOnceItemByKey2(data.cfg[Pray_2UI.tabIndex][1].Rewards_Shows[i]).Id
        tmp[i] = {id = id}
    end
    ItemListUI.ShowTipsPage(tmp)
end

--祈福一次按钮点击
function Pray_2UI.OnOneWeaponsTimeBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    local index = tonumber(GUI.GetData(element, "prayItemIndex"))
    data.curClickIndex = index
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "神兵预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", index, 1 , Pray_2UI.tabIndex)
    test("点击抽一次: " .. index,1,Pray_2UI.tabIndex)
end

--祈福十次按钮点击
function Pray_2UI.OnTenWeaponsTimeBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    local index = tonumber(GUI.GetData(element, "prayItemIndex"))
    data.curClickIndex = index
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "神兵预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", index, 2 , Pray_2UI.tabIndex)
    test("点击抽一次: " .. index,2,Pray_2UI.tabIndex)
end

--祈福一次按钮点击
function Pray_2UI.OnOnePetTimeBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    local index = tonumber(GUI.GetData(element, "prayItemIndex"))
    data.curClickIndex = index
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "灵宠预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", index, 1 , Pray_2UI.tabIndex)
    test("点击抽一次: " .. index,1,Pray_2UI.tabIndex)
end

--祈福十次按钮点击
function Pray_2UI.OnTenPetTimeBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    local index = tonumber(GUI.GetData(element, "prayItemIndex"))
    data.curClickIndex = index
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "灵宠预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    test("点击十连抽: " .. index,2,Pray_2UI.tabIndex)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", index, 2 , Pray_2UI.tabIndex)
end

--祈福一次按钮点击
function Pray_2UI.OnOneFestTimeBtnClick(guid)
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "限时预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    test("点击十连抽: " .. 1,1,Pray_2UI.tabIndex)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", 1, 1 , Pray_2UI.tabIndex)
end

--祈福十次按钮点击
function Pray_2UI.OnTenFestTimeBtnClick(guid)
    for i = 1, #data.cfg do
        local value = data.cfg[i]
        if value.ShowImgKey == "限时预览_1" then
            Pray_2UI.tabIndex = i
        end
        print(i,value.ShowImgKey)
    end
    test("点击十连抽: " .. 1,2,Pray_2UI.tabIndex)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", 1, 2 , Pray_2UI.tabIndex)
end

--关闭祈福页面按钮点击
function Pray_2UI.OnCloseBtnClick()
    GUI.DestroyWnd("Pray_2UI")
end

function Pray_2UI.OnDestroy()
    Pray_2UI.OnClose()
end

-------------------------------------------------------以下是抽奖二级界面------------------------------------------------------

--获取祈福奖励数据
function Pray_2UI.SummonLotteryReward()
    Pray_2UI.prizeTable = {}
    local table_now = {}
    Pray_2UI.tmptypeTable = {}
    test("抽奖数据: " .. #table_now)
    table_now = Pray_2UI.ShowData
    if table_now then
        Pray_2UI.tmptypeTable = table_now.Orders
        local itemTable = {}
        local petTable = {}
        local guardTable = {}
        if table_now.ItemList then
            --itemTable = LogicDefine.SeverItems2ClientItems(table_now.ItemList, itemTable)
			for k,v in ipairs(table_now.ItemList) do
                if type(v) == "string" then
                    local table_splited = {}
                    local num = 1
                    local bind = true
                    local soundType = 0
                    if type(table_now.ItemList[k+1]) == "number" then
                        num = table_now.ItemList[k+1]
                        if type(table_now.ItemList[k+2]) == "number" then
                            bind = (table_now.ItemList[k+2] == 0 and false or true)
                            if type(table_now.ItemList[k+3]) == "number" then
                                soundType = table_now.ItemList[k+3]
                            end
                        end
                    end
                    if num > 0 then
                        table_splited[1] = v
                        table_splited[2] = num
                        table_splited[3] = bind
                        table_splited[4] = soundType
                        table.insert(itemTable,table_splited)
                    end
                end
            end
        end
        --keyname,bind,soundType
        if table_now.PetList then
            for i, v in ipairs(table_now.PetList) do
                if type(v) == "string" then
                    local table_splited = {}
                    local bind = false
                    local soundType = 0
                    if type(table_now.PetList[i + 1]) == "number" then
                        bind = (table_now.PetList[i + 1] == 0 and false or true)
                        if type(table_now.PetList[i + 2]) == "number" then
                            soundType = table_now.PetList[i + 2]
                        end
                    end
					table_splited[1] = v
					table_splited[2] = 1
					table_splited[3] = bind
					table_splited[4] = soundType
					table.insert(petTable, table_splited)
				
                end
            end
        end
		if table_now.GuardList then
			for i, v in ipairs(table_now.GuardList) do
				if type(v) == "string" then
					local table_splited = {}
					local bind = false
                    if type(table_now.GuardList[i + 1]) == "number" then
                        bind = (table_now.GuardList[i + 1] == 0 and false or true)
						if type(table_now.GuardList[i + 2]) == "number" then
                            soundType = table_now.GuardList[i + 2]
                        end
                    end
					table_splited[1] = v
					table_splited[2] = 1
					table_splited[3] = bind
                    table_splited[4] = soundType
					table.insert(guardTable, table_splited)
				end
			end
		end

        local tableName = {itemTable, petTable, guardTable}
        local itemCnt = 1
        local petCnt = 1
        local guardCnt = 1
        if Pray_2UI.tmptypeTable then
            for a = 1, #Pray_2UI.tmptypeTable do
                local itemType = Pray_2UI.tmptypeTable[a]
                local tempTable = tableName[itemType]
                local tempData = nil
                --test("table type : ",itemType)
                if itemType == 1 then
                    if itemCnt <= #tempTable then
                        tempData = tempTable[itemCnt]
                        itemCnt = itemCnt + 1
                    end
                elseif itemType == 2 then
                    if petCnt <= #tempTable then
                        tempData = tempTable[petCnt]
                        petCnt = petCnt + 1
                    end
                else
                    if guardCnt <= #tempTable then
                        tempData = tempTable[guardCnt]
                        guardCnt = guardCnt + 1
                    end
                end
                if tempData then
                    table.insert(Pray_2UI.prizeTable, tempData)
                end
            end
        end
    end
    test(("item 数量: ") .. #Pray_2UI.prizeTable)
    Pray_2UI.ShowPrizePage()
end

--创建奖励页面
function Pray_2UI.CreatePrizeWnd()
    local panelCover = GUI.Get("Pray_2UI/panelCover")

    Pray_2UI.uinode.PrizeWnd = GUI.GroupCreate(Pray_2UI.uinode.panelBg, "pirzePage", 0, 0, 0, 0)
    GUI.SetIgnoreChild_OnVisible(Pray_2UI.uinode.PrizeWnd, true)
    GUI.SetAnchor(Pray_2UI.uinode.PrizeWnd, UIAnchor.Center)
    GUI.SetPivot(Pray_2UI.uinode.PrizeWnd, UIAroundPivot.Center)
    GUI.SetVisible(Pray_2UI.uinode.PrizeWnd, true)

    local prizeCover =
        GUI.ImageCreate(
        Pray_2UI.uinode.PrizeWnd,
        "prizeCover",
        "1800400220",
        0,
        -40,
        false,
        GUI.GetWidth(panelCover),
        GUI.GetHeight(panelCover) + 100
    )
    GUI.SetAnchor(prizeCover, UIAnchor.Center)
    GUI.SetPivot(prizeCover, UIAroundPivot.Center)
    prizeCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(prizeCover, true)

    local prizeBg = GUI.ImageCreate(Pray_2UI.uinode.PrizeWnd, "prizeBg", "1800601240", 0, -7, false, 1280, 343)
    GUI.SetAnchor(prizeBg, UIAnchor.Center)
    GUI.SetPivot(prizeBg, UIAroundPivot.Center)

    local titleBg = GUI.ImageCreate(Pray_2UI.uinode.PrizeWnd, "titleBg", "1800608750", 0, -188, false)
    GUI.SetAnchor(titleBg, UIAnchor.Center)
    GUI.SetPivot(titleBg, UIAroundPivot.Center)

    Pray_2UI.uinode.prizeScroll =
        GUI.ScrollRectCreate(
        Pray_2UI.uinode.PrizeWnd,
        "ScrollWnd",
        0,
        -30,
        699,
        300,
        0,
        false,
        Vector2.New(76, 76),
        UIAroundPivot.Top,
        UIAnchor.Top,
        5
    )
    GUI.SetAnchor(Pray_2UI.uinode.prizeScroll, UIAnchor.Center)
    GUI.SetPivot(Pray_2UI.uinode.prizeScroll, UIAroundPivot.Center)
    GUI.ScrollRectSetChildAnchor(Pray_2UI.uinode.prizeScroll, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(Pray_2UI.uinode.prizeScroll, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(Pray_2UI.uinode.prizeScroll, Vector2.New(14, 14))
    GUI.SetPaddingHorizontal(Pray_2UI.uinode.prizeScroll, Vector2.New(50, 50))
    GUI.SetPaddingVertical(Pray_2UI.uinode.prizeScroll, Vector2.New(64, 50))
    GUI.ScrollRectSetVertical(Pray_2UI.uinode.prizeScroll, false)
    GUI.ScrollRectSetHorizontal(Pray_2UI.uinode.prizeScroll, false)

    local againBtn =
        GUI.ButtonCreate(
        Pray_2UI.uinode.PrizeWnd,
        "againBtn",
        "1800402110",
        -90,
        103,
        Transition.ColorTint,
        "",
        120,
        46,
        false
    )
    GUI.SetAnchor(againBtn, UIAnchor.Center)
    GUI.SetPivot(againBtn, UIAroundPivot.Center)
    GUI.RegisterUIEvent(againBtn, UCE.PointerClick, "Pray_2UI", "OnAgainBtnClick")

    local againText = GUI.CreateStatic(againBtn, "againText", "再来一次", 0, 0, 120, 46, "system", false, true)
    GUI.SetAnchor(againText, UIAnchor.Center)
    GUI.SetPivot(againText, UIAroundPivot.Center)
    GUI.StaticSetAlignment(againText, TextAnchor.MiddleCenter)
    GUI.SetColor(againText, colorDark)
    GUI.StaticSetFontSize(againText, fontSizeDefault)

    local knowBtn =
        GUI.ButtonCreate(
        Pray_2UI.uinode.PrizeWnd,
        "knowBtn",
        "1800402110",
        90,
        103,
        Transition.ColorTint,
        "",
        120,
        46,
        false
    )
    GUI.SetAnchor(knowBtn, UIAnchor.Center)
    GUI.SetPivot(knowBtn, UIAroundPivot.Center)
    GUI.RegisterUIEvent(knowBtn, UCE.PointerClick, "Pray_2UI", "OnKnowBtnClick")

    local knowText = GUI.CreateStatic(knowBtn, "knowText", "知道了", 0, 0, 120, 46, "system", false, true)
    GUI.SetAnchor(knowText, UIAnchor.Center)
    GUI.SetPivot(knowText, UIAroundPivot.Center)
    GUI.StaticSetAlignment(knowText, TextAnchor.MiddleCenter)
    GUI.SetColor(knowText, colorDark)
    GUI.StaticSetFontSize(knowText, fontSizeDefault)
    GUI.SetVisible(knowBtn, false)
    GUI.SetVisible(againBtn, false)
end

--创建获得奖品页面
function Pray_2UI.ShowPrizePage()
    test("显示抽奖界面")

    data.curShowCnt = #Pray_2UI.prizeTable

    local knowBtn = GUI.GetChild(Pray_2UI.uinode.PrizeWnd, "knowBtn")
    if knowBtn ~= nil then
        GUI.SetVisible(knowBtn, false)
    end
    local againBtn = GUI.GetChild(Pray_2UI.uinode.PrizeWnd, "againBtn")
    if againBtn ~= nil then
        local againText = GUI.GetChild(againBtn, "againText")
        if data.curShowCnt == 1 then
            GUI.StaticSetText(againText, "再来一次")
        else
            GUI.StaticSetText(againText, "再来十次")
        end
        GUI.SetVisible(againBtn, false)
    end
    Pray_2UI.OpenGetRewardUI()
    Pray_2UI.ShowBtnTimerFunc()
end

function Pray_2UI.OpenGetRewardUI()
    GUI.OpenWnd("GetRewardUI")
    local itemDataList = {}
	local intervalTime = (Pray_2UI.ServerData["ShowTime"] or 380)/1000
    for i = 1, #Pray_2UI.prizeTable do
        itemDataList[i] = {}
		local tmp = Pray_2UI.prizeTable[i]
		itemDataList[i].KeyName = tmp[1]
		itemDataList[i].Num = tmp[2]
		itemDataList[i].Bind = tmp[3]
		itemDataList[i].Sound = tmp[4]
        if Pray_2UI.tmptypeTable[i] == 1 then
            ---@type eqiupItem
            -- local tmp = Pray_2UI.prizeTable[i]
            -- itemDataList[i].KeyName = tmp.keyname
            -- itemDataList[i].Num = tmp.count
            itemDataList[i].IsItem = true
        elseif Pray_2UI.tmptypeTable[i] == 2 then
            -- local tmp = Pray_2UI.prizeTable[i]
            -- itemDataList[i].KeyName = tmp[1]
            -- itemDataList[i].Num = tmp[2]
            itemDataList[i].IsPet = true
		elseif Pray_2UI.tmptypeTable[i] == 3 then
			-- local tmp = Pray_2UI.prizeTable[i]
            -- itemDataList[i].KeyName = tmp[1]
            -- itemDataList[i].Num = tmp[2]
			itemDataList[i].IsGuard = true
        end
        test(itemDataList[i].KeyName)
    end
    GetRewardUI.ShowItem(
        itemDataList,
        function()
            -- CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "LuckyWheel_Receive_Tenth")
        end,
		intervalTime
    )
    GetRewardUI.SetLeftBtn(data.curShowCnt == 1 and "再来一次" or "再来十次", Pray_2UI.OnAgainBtnClick)
    GetRewardUI.SetRightBtn("知道了", Pray_2UI.OnKnowBtnClick)
end

function Pray_2UI.ShowBtnTimerFunc()
    if not Pray_2UI.showBtnTimer then
    --//TODO  关闭自动关闭
    -- Pray_2UI.showBtnTimer = Timer.New(Pray_2UI.ShowPrizeBtns, 10, 1)
    -- Pray_2UI.showBtnTimer:Start()
    end
end

function Pray_2UI.ShowPrizeBtns()
    Pray_2UI.OnKnowBtnClick()
end

function Pray_2UI.BindItemId(itemIconBtn, itemId, amount)
    if itemIconBtn == nil then
        return
    else
        ItemIcon.BindItemId(itemIconBtn, itemId, amount)
        GUI.ItemCtrlSetElementValue(itemIconBtn, eItemIconElement.RightBottomNum, amount)
        return
    end

    local itemData = DB.GetOnceItemByKey2(itemId)
    if itemData ~= nil then
        GUI.ItemCtrlSetElementValue(itemIconBtn, eItemIconElement.Border, QualityRes[itemData.Grade])
        GUI.ItemCtrlSetElementValue(itemIconBtn, eItemIconElement.Icon, itemData.Icon)
        local icon = GUI.ItemCtrlGetSprite_Icon(itemIconBtn)
        GUI.SetPositionY(icon, -1)

        local itemConsumable = DB.Get_item_consumable(itemId)
        GUI.SetItemIconBtnIconScale(itemIconBtn, 0.8)
        if
            itemConsumable ~= nil and
                (itemConsumable.Type == 32 or itemConsumable.Type == 8 or itemConsumable.Type == 41)
         then
            GUI.SetItemIconBtnIconScale(itemIconBtn, 0.9)
        end

        local equip = DB.Get_item_equip(itemId)
        if equip ~= nil and equip.Type == 7 then
            GUI.SetItemIconBtnLeftBottomName(itemIconBtn, "1801208350")
            local lbSprite = GUI.GetItemIconBtnSprite_LeftBottom(itemIconBtn)
            GUI.SetPositionX(lbSprite, 4)
            GUI.SetPositionY(lbSprite, 6)
        else
            GUI.SetItemIconBtnLeftBottomName(itemIconBtn, nil)
        end

        GUI.SetItemIconBtnRightTopName(itemIconBtn, nil)
        if itemConsumable ~= nil and (itemConsumable.Type == 32) then
            GUI.SetItemIconBtnRightTopName(itemIconBtn, "1801208250")
        end

        GUI.ItemCtrlSetCount(itemIconBtn, amount)
        local count = GUI.ItemCtrlGetLabel_Num(itemIconBtn)
        if count ~= nil then
            GUI.SetPositionX(count, 8)
            GUI.SetPositionY(count, 5)
            GUI.StaticSetFontSize(count, 20)
            GUI.SetIsOutLine(count, true)
            GUI.SetOutLine_Color(count, colorblack)
            GUI.SetOutLine_Distance(count, 1)
            GUI.SetColor(count, colorWhite)
        end
    else
        ItemIconBtn.SetEmpty(itemIconBtn)
    end
end

--关闭奖品页面按钮点击
function Pray_2UI.OnKnowBtnClick()
    if Pray_2UI.showBtnTimer ~= nil then
        Pray_2UI.showBtnTimer:Stop()
        Pray_2UI.showBtnTimer = nil
    end
    GUI.CloseWnd("GetRewardUI")
end

--再来一次按钮点击
function Pray_2UI.OnAgainBtnClick()
    Pray_2UI.OnKnowBtnClick()
    test(data.curClickIndex)--1是左边 2是右边
    test(data.curShowCnt)
    print(Pray_2UI.tabIndex)
    if data.curShowCnt == nil or data.curClickIndex == nil then
        return
    end
    test("再抽一次index: " .. data.curClickIndex)
    if data.curShowCnt == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", data.curClickIndex, 1,Pray_2UI.tabIndex)
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", data.curClickIndex, 2,Pray_2UI.tabIndex)
    end
end
function Pray_2UI.OnClose()
    if Pray_2UI.onLineTimer then
        Pray_2UI.onLineTimer:Stop()
        Pray_2UI.onLineTimer = nil
    end
    CL.UnRegisterMessage(GM.CustomDataUpdate, "Pray_2UI", "OnCustomDataUpdate")
    CL.UnRegisterMessage(GM.RefreshBag, "Pray_2UI", "OnRefreshBag")
    Pray_2UI.OnKnowBtnClick()
end
