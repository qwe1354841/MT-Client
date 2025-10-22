local RegionalTaskContentUI = {}
_G.RegionalTaskContentUI = RegionalTaskContentUI

--区域活动详情界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local _gt = UILayout.NewGUIDUtilTable()

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

------------------------------------------Start 颜色配置 Start----------------------------------
local RedColor = UIDefine.RedColor
local Brown4Color = UIDefine.Brown4Color
local Brown6Color = UIDefine.Brown6Color
local WhiteColor = UIDefine.WhiteColor
local White2Color = UIDefine.White2Color
local White3Color = UIDefine.White3Color
local GrayColor = UIDefine.GrayColor
local Gray2Color = UIDefine.Gray2Color
local Gray3Color = UIDefine.Gray3Color
local OrangeColor = UIDefine.OrangeColor
local GreenColor = UIDefine.GreenColor
local Green2Color = UIDefine.Green2Color
local Green3Color = UIDefine.Green3Color
local Blue3Color = UIDefine.Blue3Color
local Purple2Color = UIDefine.Purple2Color
local PinkColor = UIDefine.PinkColor
local OutLineDistance = UIDefine.OutLineDistance
local OutLine_BrownColor = UIDefine.OutLine_BrownColor
----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------


----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------


--------------------------------------------End 表配置 End------------------------------------

function RegionalTaskContentUI.Main(parameter)
    local panel = GUI.WndCreateWnd("RegionalTaskContentUI" , "RegionalTaskContentUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "区 域 任 务",660,530,"RegionalTaskContentUI","OnExit",_gt)
    _gt.BindName(panelBg,"panelBg")

    local _DetailScrollLst = GUI.ImageCreate(panelBg,"DetailBack", "1800400200", 0, 60, false, 620, 440)
    _gt.BindName(_DetailScrollLst,"DetailScrollLst")
   SetSameAnchorAndPivot(_DetailScrollLst, UILayout.Top)

    local _Title = GUI.CreateStatic( _DetailScrollLst,"Title", "【任务名称】", 0, 20, 150, 30)
    SetSameAnchorAndPivot(_Title, UILayout.TopLeft)
    GUI.StaticSetFontSize(_Title, 24)
    GUI.SetColor(_Title, UIDefine.PurpleColor)

    local tipsBtn = GUI.ButtonCreate(_DetailScrollLst, "tipsBtn", "1800702030", -30, 20, Transition.ColorTint, "")
    SetSameAnchorAndPivot(tipsBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(tipsBtn, UCE.PointerClick, "RegionalTaskContentUI", "OnTipsBtnClick")

    local txt_x = 30

    local _TitleValue  = GUI.RichEditCreate(_DetailScrollLst, "TitleValue","哒哒",txt_x,56,654,60)
    SetSameAnchorAndPivot(_TitleValue, UILayout.TopLeft)
    GUI.StaticSetFontSize(_TitleValue, 22)
    GUI.SetColor(_TitleValue, UIDefine.Brown4Color)
    GUI.StaticSetAlignment(_TitleValue,TextAnchor.UpperLeft)
    GUI.RichEditSetLinkColor(_TitleValue, UIDefine.Green5Color)
    GUI.RegisterUIEvent(_TitleValue, UCE.PointerClick , "RegionalTaskContentUI", "OnClickQuestContent")

    local _Content = GUI.CreateStatic( _DetailScrollLst,"Content", "【任务描述】", 0, 94, 150, 30)
    SetSameAnchorAndPivot(_Content, UILayout.TopLeft)
    GUI.StaticSetFontSize(_Content, 24)
    GUI.SetColor(_Content, UIDefine.PurpleColor)

    local _ContentValue  = GUI.RichEditCreate(_DetailScrollLst, "ContentValue","哒",txt_x,129,570,100)
    SetSameAnchorAndPivot(_ContentValue, UILayout.TopLeft)
    GUI.StaticSetFontSize(_ContentValue, 20)
    GUI.SetColor(_ContentValue, UIDefine.Brown4Color)
    GUI.RichEditSetLinkColor(_ContentValue, UIDefine.Green5Color)
    GUI.StaticSetAlignment(_ContentValue,TextAnchor.UpperLeft)

    local _Award = GUI.CreateStatic( _DetailScrollLst,"Award", "【个人贡献】", 0, 228, 300, 30)
    SetSameAnchorAndPivot(_Award, UILayout.TopLeft)
    GUI.StaticSetFontSize(_Award, 24)
    GUI.SetColor(_Award, UIDefine.PurpleColor)

    local sliderBg = GUI.ImageCreate(panelBg, "sliderBg", "1800607190", -10, -130, false, 540, 18)
    _gt.BindName(sliderBg, "sliderBg")
    SetAnchorAndPivot(sliderBg, UIAnchor.Bottom, UIAroundPivot.Bottom)
    local fill = GUI.ImageCreate(sliderBg, "fill", "1800607200", 0, 1, false, 1, 18)
    SetAnchorAndPivot(fill, UIAnchor.Left, UIAroundPivot.Left)
    local handle = GUI.ImageCreate(fill, "handle", "1800607210", 17, 0)
    SetAnchorAndPivot(handle, UIAnchor.Right, UIAroundPivot.Right)
    local value = GUI.CreateStatic(handle, "txt", "", 0, 0, 30, 30, "system", false, false)
    GUI.StaticSetFontSize(value, 23)
    GUI.SetColor(value, WhiteColor)
    SetAnchorAndPivot(value, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(value, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(value, true)
    GUI.SetOutLine_Color(value, UIDefine.OutLine_YellowColor)
    GUI.SetOutLine_Distance(value, 1)
    GUI.StaticSetFontSizeBestFit(value)

    --前往领取
    local _GoToBtn = GUI.ButtonCreate(_DetailScrollLst,"GoToBtn", "1800602030",0,-15, Transition.ColorTint, "前往完成")
    SetSameAnchorAndPivot(_GoToBtn, UILayout.Bottom)
    GUI.ButtonSetTextFontSize(_GoToBtn, 26)
    GUI.ButtonSetTextColor(_GoToBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(_GoToBtn,true)
    GUI.SetOutLine_Color(_GoToBtn,UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(_GoToBtn,1)
    GUI.RegisterUIEvent(_GoToBtn , UCE.PointerClick , "RegionalTaskContentUI", "OnGoToBtn")

end


function RegionalTaskContentUI.OnShow()
    local wnd = GUI.GetWnd("RegionalTaskContentUI")

    if not wnd then

        return

    end

    GUI.SetVisible(wnd, true)
    RegionalTaskContentUI.Init()

end

function RegionalTaskContentUI.Init()

end

--服务器回调刷新
function RegionalTaskContentUI.RefreshAllData()
    test("服务器回调刷新")

    local DetailScrollLst = _gt.GetUI("DetailScrollLst")

    local TitleValue =  GUI.GetChild(DetailScrollLst,"TitleValue",false)
    GUI.StaticSetText(TitleValue,RegionalTaskContentUI.TaskTitle)

    local ContentValue =  GUI.GetChild(DetailScrollLst,"ContentValue",false)
    GUI.StaticSetText(ContentValue,RegionalTaskContentUI.Info)

    local sliderBg = _gt.GetUI("sliderBg")

    local fill = GUI.GetChild(sliderBg,"fill",false)
    local data = RegionalTaskContentUI.Reward

    test("RegionalTaskContentUI.Integral",RegionalTaskContentUI.Integral)

    if RegionalTaskContentUI.Integral <= data[#data].IntegralStage then

        GUI.SetWidth(fill,RegionalTaskContentUI.Integral / data[#data].IntegralStage * GUI.GetWidth(sliderBg))

    else

        GUI.SetWidth(fill,GUI.GetWidth(sliderBg))

    end


    local handle = GUI.GetChild(fill,"handle",false)
    local txt = GUI.GetChild(handle,"txt",false)
    GUI.StaticSetText(txt,RegionalTaskContentUI.Integral)

    local itemGroup = GUI.GetChild(sliderBg,"itemGroup",false)

    if itemGroup ~= nil then

        GUI.Destroy(itemGroup)

    end

    --创建任务奖励组
    RegionalTaskContentUI.CreateItemGroup()

end

--tips按钮点击事件
function RegionalTaskContentUI.OnTipsBtnClick()
    test("tips按钮点击事件")

    test("RegionalTaskContentUI.Tips",RegionalTaskContentUI.Tips)

    local panelBg = _gt.GetUI("panelBg")

    local Text = RegionalTaskContentUI.Tips

    local TipsBg = GUI.TipsCreate(panelBg, "SeniorConsumeTips", 0, 120, 500, 0)
    SetSameAnchorAndPivot(TipsBg, UILayout.Top)
    GUI.SetIsRemoveWhenClick(TipsBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(TipsBg),false)

    local TipsText = GUI.CreateStatic(TipsBg,"TipsText",Text,0,20,460,25,"system", true)
    GUI.StaticSetFontSize(TipsText,20)
    SetSameAnchorAndPivot(TipsText, UILayout.Top)
    GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
    local desPreferHeight = GUI.StaticGetLabelPreferHeight(TipsText)
    GUI.SetHeight(TipsText,desPreferHeight)
    GUI.SetHeight(TipsBg,desPreferHeight+40)

end

--创建任务奖励组
function RegionalTaskContentUI.CreateItemGroup()
    test("创建任务奖励组")

    local sliderBg = _gt.GetUI("sliderBg")

    local itemGroup = GUI.GroupCreate(sliderBg,"itemGroup", 0, 0, GUI.GetWidth(sliderBg), 270,false)
    SetSameAnchorAndPivot(itemGroup, UILayout.Left)

    local itemSize = 55

    local sumIntegralStage = RegionalTaskContentUI.Reward[#RegionalTaskContentUI.Reward].IntegralStage

    test("sumIntegralStage",sumIntegralStage)

    for i = 1, #RegionalTaskContentUI.Reward do

        local data = RegionalTaskContentUI.Reward[i]

        local itemData = RegionalTaskContentUI.Reward[i].Item

        local itemDB = DB.GetOnceItemByKey2(itemData[1])

        local item = GUI.ItemCtrlCreate(itemGroup,"item"..i,QualityRes[1],data.IntegralStage / sumIntegralStage * GUI.GetWidth(itemGroup),-42,itemSize,itemSize,false,"system",false)
        GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,itemSize - 5 ,itemSize - 5)
        SetAnchorAndPivot(item, UIAnchor.Left, UIAroundPivot.Center)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,tostring(itemDB.Icon))
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[itemDB.Grade])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,itemData[2])
        if itemData[3] == 1 then
            GUI.ItemCtrlSetElementValue(item,eItemIconElement.LeftTopSp,"1800707120")--是否为绑定
        else
            GUI.ItemCtrlSetElementValue(item,eItemIconElement.LeftTopSp,"")--是否为绑定
        end
        GUI.SetData(item,"itemId",itemDB.Id)
        GUI.RegisterUIEvent(item, UCE.PointerClick, "RegionalTaskContentUI", "OnItemClick")

        --角色名字
        local nameTxt = GUI.CreateStatic(item,"nameTxt",data.IntegralStage, 0, 30, 100, 30, "system", false, false)
        GUI.StaticSetFontSize(nameTxt,22)
        GUI.StaticSetAlignment(nameTxt,TextAnchor.UpperCenter)
        SetAnchorAndPivot(nameTxt, UIAnchor.Bottom, UIAroundPivot.Top)
        GUI.SetColor(nameTxt,Brown4Color)
    end

end

--奖励item点击事件
function RegionalTaskContentUI.OnItemClick(guid)
    test("奖励item点击事件")

    local item = GUI.GetByGuid(guid)

    local itemId = tonumber(GUI.GetData(item,"itemId"))
    local panelBg = _gt.GetUI("panelBg")
    local tip = Tips.CreateByItemId(tonumber(itemId), panelBg, "rightItemTips",0,0)
    SetSameAnchorAndPivot(tip, UILayout.Center)
    GUI.SetData(tip, "ItemId", itemId)


end

--前往完成按钮点击事件
function RegionalTaskContentUI.OnGoToBtn()
    test("前往完成按钮点击事件")

    CL.SendNotify(NOTIFY.SubmitForm,"FormRegionTask","MoveToNPC")

end

function RegionalTaskContentUI.OnExit()

    GUI.CloseWnd("RegionalTaskContentUI")

end
