--清空善恶值页面
--从RoleAttributeUI独立出来

local ClearGoodAndEvilValuesUI={}
_G.ClearGoodAndEvilValuesUI = ClearGoodAndEvilValuesUI
local _gt=UILayout.NewGUIDUtilTable()
-----------------------------------------------Start缓存常用的全局变量------------------------------
local GUI=GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
----------------------------------------------End缓存常用的全局变量------------------------------
local outLineColor = UIDefine.OutLine_BrownColor
local sizeDefault = UIDefine.FontSizeS
local itemGradeImage={
    1801100120,1801100130,1801100140,1801100150,1801100160
}
local itemGradeColor={
    "#66310eff","#46DC5Fff","#42B1F0ff","#E855FFff","#FF8700ff"
}
--test("ClearGoodAndEvilValuesUI1321321")
function ClearGoodAndEvilValuesUI.Main()
    local panel = GUI.WndCreateWnd("ClearGoodAndEvilValuesUI", "ClearGoodAndEvilValuesUI", 0, 0, eCanvasGroup.Normal)
    _gt.BindName(panel,"wnd")
    --local panelCover = GuidCacheUtil.GetUI("panelCover")
    local cover = GUI.ImageCreate(panel, "clearBeevilCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    SetAnchorAndPivot(cover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(cover, true)
    cover:RegisterEvent(UCE.PointerClick)

    local bgSp = GUI.ImageCreate(cover, "clearBeevilBg", "1800001120", 0, 22, false, 480, 350)
    SetAnchorAndPivot(bgSp, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(bgSp, "clearBeevilBg")
    local flower = GUI.ImageCreate(bgSp, "flower", "1800007060", -25, -25, false)
    SetAnchorAndPivot(flower, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    --关闭
    local closeBtn = GUI.ButtonCreate(bgSp, "closeBeevilBtn", "1800002050", -20, 20, Transition.ColorTint)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)


    local titleBg=GUI.ImageCreate(bgSp,"titleBg","1800001030",0,25,true)
    SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Top)

    local titleTxt=GUI.CreateStatic(titleBg,"titleTxt","清除善恶值",0,0,100,50)
    SetAnchorAndPivot(titleTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(titleTxt,UIDefine.FontSizeS)
    GUI.SetColor(titleTxt,UIDefine.WhiteColor)

    local itemIconBg=GUI.ImageCreate(bgSp,"itemIconBg","",0,-40,false,90,90)
    SetAnchorAndPivot(itemIconBg, UIAnchor.Center, UIAroundPivot.Center)
    local itemIcon=GUI.ImageCreate(itemIconBg,"itemIcon","",0,0,false,70,70)
    local itemAmountTxt=GUI.CreateStatic(itemIconBg,"itemAmountTxt","",-10,-5,80,30)
    GUI.StaticSetFontSize(itemAmountTxt,UIDefine.FontSizeM)
    SetAnchorAndPivot(itemAmountTxt, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetIsOutLine(itemAmountTxt,true);
	GUI.SetOutLine_Setting(itemAmountTxt,OutLineSetting.OutLine_BlackColor_1)	
    GUI.SetOutLine_Color(itemAmountTxt,UIDefine.BlackColor);
    GUI.SetOutLine_Distance(itemAmountTxt,1);
    GUI.StaticSetAlignment(itemAmountTxt, TextAnchor.MiddleRight)


    local tipsLabel = GUI.CreateStatic(bgSp, "tipsLabel", "当前善恶值", -20, 40, 200, 50)
    GUI.SetColor(tipsLabel,UIDefine.BrownColor)
    GUI.StaticSetFontSize(tipsLabel,UIDefine.FontSizeS)
    local clearTxtBg = GUI.ImageCreate(bgSp, "clearTxtBg", "1800500070", 60, 40, false, 100, 30)
    SetAnchorAndPivot(clearTxtBg, UIAnchor.Center, UIAroundPivot.Center)
    --local pk_value =CL.GetIntAttr(RoleAttr.RoleAttrPK)
    --local name = "currentBeevilValue"
    --test("pk_value"..tostring(pk_value))
    local txt = GUI.CreateStatic(clearTxtBg, "currentBeevilValue","0" , 0, 0, 80, 30)
    GUI.SetColor(txt,UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt,UIDefine.FontSizeS)
    --GuidCacheUtil.BindName(txt, name)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)


    local costLabel = GUI.RichEditCreate(bgSp, "clearBeevilCostLabel", "", 0, 80, 390, 90)
    --GuidCacheUtil.BindName(costLabel, "clearBeevilCostLabel")
    GUI.SetColor(costLabel,UIDefine.BrownColor)
    GUI.StaticSetFontSize(costLabel,UIDefine.FontSizeS)
    GUI.StaticSetAlignment(costLabel, TextAnchor.MiddleCenter)
    GUI.SetIsRaycastTarget(costLabel, false)

    --使用1个
    local oneClearButton = GUI.ButtonCreate(bgSp, "oneClearBeevilButton", "1800402080", 130, -20, Transition.ColorTint, "", 160, 46, false)
    SetAnchorAndPivot(oneClearButton, UIAnchor.Bottom, UIAroundPivot.Bottom)
    local oneClearLabel = GUI.CreateStatic(oneClearButton, "oneClearBeevilButtonLabel", "使用1个", 0, 0, 160, 46)
    ClearGoodAndEvilValuesUI.SetTextBasicInfo(oneClearLabel, nil, TextAnchor.MiddleCenter, 24, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsOutLine(oneClearLabel, true)
	GUI.SetOutLine_Setting(oneClearLabel,OutLineSetting.OutLine_BrownColor_1)	
    GUI.SetOutLine_Color(oneClearLabel, outLineColor)
    GUI.SetOutLine_Distance(oneClearLabel, 1)

    --全部清除
    local allClearButton = GUI.ButtonCreate(bgSp, "allClearBeevilButton", "1800402080", -130, -20, Transition.ColorTint, "", 160, 46, false)
    SetAnchorAndPivot(allClearButton, UIAnchor.Bottom, UIAroundPivot.Bottom)
    local allClearLabel = GUI.CreateStatic(allClearButton, "allClearBeevilButtonLabel", "全部清除", 0, 0, 160, 46)
    ClearGoodAndEvilValuesUI.SetTextBasicInfo(allClearLabel, nil, TextAnchor.MiddleCenter, 24, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsOutLine(allClearLabel, true)
	GUI.SetOutLine_Setting(allClearLabel,OutLineSetting.OutLine_BrownColor_1)	
    GUI.SetOutLine_Color(allClearLabel, outLineColor)
    GUI.SetOutLine_Distance(allClearLabel, 1)


    GUI.RegisterUIEvent(oneClearButton, UCE.PointerClick, "ClearGoodAndEvilValuesUI", "OneClearBeevil")
    GUI.RegisterUIEvent(allClearButton, UCE.PointerClick, "ClearGoodAndEvilValuesUI", "AllClearBeevil")
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "ClearGoodAndEvilValuesUI", "OnCancleClearBeevil")


    GUI.SetVisible(panel, false)

    CL.RegisterAttr(RoleAttr.RoleAttrPK,ClearGoodAndEvilValuesUI.SetClearBeevilInfo)
end

function ClearGoodAndEvilValuesUI.SetTextBasicInfo(txt, color, alignment, txtSize, uiAnchor, pivot)
    if not txt then
        return
    end
    SetAnchorAndPivot(txt, uiAnchor or UIAnchor.Center, pivot or UIAroundPivot.Center)
    GUI.StaticSetFontSize(txt, txtSize or sizeDefault)
    if color then
        GUI.SetColor(txt, color)
    end
    GUI.StaticSetAlignment(txt, alignment or TextAnchor.MiddleLeft)
end


function ClearGoodAndEvilValuesUI.OnShow(parameter)
    --test("ClearGoodAndEvilValuesUI------onShow")

    local wnd = _gt.GetUI("wnd")

    if not wnd then
        test("wnd must be not nil")
        return
    end

    local PkValue=CL.GetIntAttr(RoleAttr.RoleAttrPK)
    if PkValue >= 0 and tostring(parameter)~="NPC" then
        CL.SendNotify(NOTIFY.ShowBBMsg, "无需清空善恶值")
        return
    end

    CL.RegisterMessage(GM.AddNewItem, "ClearGoodAndEvilValuesUI", "ResetBag")
    CL.RegisterMessage(GM.UpdateItem, "ClearGoodAndEvilValuesUI", "ResetBag")
    CL.RegisterMessage(GM.RemoveItem, "ClearGoodAndEvilValuesUI", "ResetBag")
    --test("测试到此处")
    --CL.RegisterMessage(GM.RefreshBag, "ClearGoodAndEvilValuesUI", "SetClearBeevilInfo")

    ClearGoodAndEvilValuesUI.GetClearBeevilInfo()

    GUI.SetVisible(wnd, true)

end
--向服务器请求数据
function ClearGoodAndEvilValuesUI.GetClearBeevilInfo()
    CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "getReduceEvilItemId")
end
--服务器回调方法
function ClearGoodAndEvilValuesUI.SetClearBeevilInfo(attrType, value)
    local page = GUI.Get("ClearGoodAndEvilValuesUI/clearBeevilCover")
    --if rolePKValue>=0 and page~= nil then
    --    GUI.SetVisible(page,false)
    --end
    if not page then
        return
    end

    local rolePKValue=CL.GetIntAttr(RoleAttr.RoleAttrPK)
    if attrType == RoleAttr.RoleAttrPK then
        rolePKValue=value
    end

    local itemId=ClearGoodAndEvilValuesUI.ReduceEvilItemId
    --test("data is "..tonumber(itemId))
    --itemId=itemId or RoleAttributeUI.ReduceEvilItemId
    local itemDB=DB.GetOnceItemByKey1(itemId)
    local itemAmountInBag=LD.GetItemCountById(itemId)

    local clearBeevilBg=_gt.GetUI("clearBeevilBg")
    local itemIconBg=GUI.GetChild(clearBeevilBg,"itemIconBg")
    local itemIcon=GUI.GetChild(itemIconBg,"itemIcon")
    local itemAmountTxt=GUI.GetChild(itemIconBg,"itemAmountTxt")
    local clearTxtBg=GUI.GetChild(clearBeevilBg,"clearTxtBg")
    local currentBeevilValue=GUI.GetChild(clearTxtBg,"currentBeevilValue")
    local costLabel=GUI.GetChild(clearBeevilBg,"clearBeevilCostLabel")

    GUI.ImageSetImageID(itemIconBg,itemGradeImage[itemDB.Grade])
    GUI.ImageSetImageID(itemIcon,itemDB.Icon)
    local amountTxt=itemAmountInBag.."/1"
    GUI.StaticSetText(itemAmountTxt,amountTxt)
    if itemAmountInBag>=1 then
        GUI.SetColor(itemAmountTxt,UIDefine.WhiteColor)
    else
        GUI.SetColor(itemAmountTxt,UIDefine.RedColor)
    end
    test("rolePKValue"..tostring(rolePKValue))
    GUI.StaticSetText(currentBeevilValue,tostring(rolePKValue))
    local strUseful=string.split(itemDB.Info,"，")
    local infoTxt="是否消耗 <color="..itemGradeColor[itemDB.Grade]..">"..itemDB.Name.."</color> 清除善恶值("..strUseful[2]..")"
    GUI.StaticSetText(costLabel,infoTxt)
    --GUI.SetColor(costLabel,UIDefine.PurpleColor)
    --test("SetClearBeevilInfo-------Over")
end

function ClearGoodAndEvilValuesUI.OneClearBeevil(key)
    test("点击了使用一个按钮"..ClearGoodAndEvilValuesUI.ReduceEvilItemId)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "useReduceEvilItem","1",tostring(ClearGoodAndEvilValuesUI.ReduceEvilItemId))
    --RoleAttributeUI.OnCancleClearBeevil(key)
end
function ClearGoodAndEvilValuesUI.AllClearBeevil(key)
    test("点击了清除全部按钮"..ClearGoodAndEvilValuesUI.ReduceEvilItemId)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "useReduceEvilItem","2",tostring(ClearGoodAndEvilValuesUI.ReduceEvilItemId))
end
function ClearGoodAndEvilValuesUI.OnCancleClearBeevil()
    --CL.UnRegisterMessage(GM.RefreshBag, "RoleAttributeUI", "SetClearBeevilInfo")
    CL.UnRegisterAttr(RoleAttr.RoleAttrPK,ClearGoodAndEvilValuesUI.SetClearBeevilInfo)
    CL.UnRegisterMessage(GM.AddNewItem, "ClearGoodAndEvilValuesUI", "ResetBag")
    CL.UnRegisterMessage(GM.UpdateItem, "ClearGoodAndEvilValuesUI", "ResetBag")
    CL.UnRegisterMessage(GM.RemoveItem, "ClearGoodAndEvilValuesUI", "ResetBag")
    GUI.CloseWnd("ClearGoodAndEvilValuesUI")
end

function ClearGoodAndEvilValuesUI.ResetBag(guid, id)
    if id and tostring(id) ~= "" then
        local itemDB = DB.GetOnceItemByKey1(tostring(id))
        ClearGoodAndEvilValuesUI.toResetBag(itemDB["ShowType"])
    elseif guid then
        local itemData = LD.GetItemDataByGuid(tostring(guid))
        if itemData then
            local itemDB = DB.GetOnceItemByKey1(tostring(itemData.id))
            ClearGoodAndEvilValuesUI.toResetBag(itemDB["ShowType"])
            -- CDebug.LogError(itemDB["ShowType"])
        end
    end
end

function ClearGoodAndEvilValuesUI.toResetBag(ShowType)
    if ShowType == "善恶值道具" then
        ClearGoodAndEvilValuesUI.SetClearBeevilInfo()
    end
end
