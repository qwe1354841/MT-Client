local GivenPresentUI = {}
_G.GivenPresentUI = GivenPresentUI
-- 赠送礼物界面

local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")

-- 字体大小
local fontSizeDefault = 22
local PresentCount = 5
local fontSizeBtn = 26
local fontSizeSmaller = 20
local fontSizeBigger = 24
local CurFriendList = {}
local CurPresentList = {}
local GUI = GUI
local SelectCheckBoxItemRoleGuid = nil
local CountNum = 25
local PresentListNum = 0
local SelectCheckBoxRoleGuid = nil
local SelectCheckBoxRoleItemGuid = nil
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local _gt = UILayout.NewGUIDUtilTable()
local IsIntoRefreshBag = 1
local PresentList = {}
local GivenPresentGuid = {}
local GrayPresentList = {}

local CONTACT_TYPE = {
    contact_friend = 2, --//好友
}

-- 颜色
local colorDark = Color.New(102/255, 47/255, 22/255, 255/255)
local colorWhite = Color.New(255/255, 246/255, 232/255, 255/255)
local colorOutline = Color.New(175/255, 96/255, 19/255, 255/255)

local QualityRes = UIDefine.ItemIconBg

function GivenPresentUI.Main(parameter)
    GUI.PostEffect()
    local panel = GUI.WndCreateWnd("GivenPresentUI", "GivenPresentUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)
    local width = 780
    local height = 584

    -- 底图
    local panelBg = UILayout.CreateFrame_WndStyle2(panel,"赠送礼物",width,height,"GivenPresentUI","OnExit",_gt)

    GUI.SetAnchor(panelBg, UIAnchor.Center)
    GUI.SetPivot(panelBg, UIAroundPivot.Center)
    panelBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(panelBg, UCE.PointerClick, "GivenPresentUI", "OnBgClick")
    GivenPresentUI.CreateUI()

    if parameter ~= nil then
        GivenPresentUI.NeedDefaultSelected = true
        GivenPresentUI.SelectedRoleGuid = parameter
    end

end

function GivenPresentUI.OnShow(parameter)
    local wnd = GUI.GetWnd("GivenPresentUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
    GivenPresentUI.Init()
    if parameter ~= nil then
        SelectCheckBoxRoleGuid = tostring(parameter)
    end
    if SelectCheckBoxRoleItemGuid ~= SelectCheckBoxRoleGuid then
        local item = GUI.GetByGuid(SelectCheckBoxRoleItemGuid)
        GUI.CheckBoxExSetCheck(item, false)
    end
    SelectCheckBoxRoleItemGuid = SelectCheckBoxRoleGuid
    local giveTimesText = _gt.GetUI("giveTimesText")

    test("SelectCheckBoxRoleGuid",tostring(SelectCheckBoxRoleGuid))
    local giveAwayCount = tostring(LD.GetContactLongCustomData("giveAwayCount",tostring(SelectCheckBoxRoleGuid)))
    test("giveAwayCount",tostring(giveAwayCount))
    GUI.StaticSetText(giveTimesText,giveAwayCount.."/10")


    GivenPresentUI.Register()
    GivenPresentUI.Refresh()

end

-- 初始化一些数据
function GivenPresentUI.Init()
    GivenPresentUI.SelectedRoleGuid = "0"
    GivenPresentUI.FriendContactItemMax = 5
    GivenPresentUI.ItemMax = 25
    GivenPresentUI.SelectItems = {}
    GrayPresentList = {}
    IsIntoRefreshBag = 1
    SelectCheckBoxRoleGuid = nil
    SelectCheckBoxRoleItemGuid = nil
    GivenPresentUI.NeedDefaultSelected = false
end

-- 创建UI
function GivenPresentUI.CreateUI()

    local parent = GUI.Get("GivenPresentUI/panelBg")
    
    -- 列表背景
    local contactListBg = GUI.ImageCreate(parent, "contactListBg", "1800400200", 16, 60, false, 312, 512)
    GUI.SetAnchor(contactListBg, UIAnchor.TopLeft)
    GUI.SetPivot(contactListBg, UIAroundPivot.TopLeft)


    GivenPresentUI.CreateRoleLoopScroll()

    local TipsWithoutEquip = GUI.GroupCreate(contactListBg, "TipsWithoutEquip", 0, 0, 0, 0)
    _gt.BindName(TipsWithoutEquip, "TipsWithoutEquip")
    GUI.SetVisible(TipsWithoutEquip,false)

    local Img = GUI.ImageCreate(TipsWithoutEquip, "Img", "1800608770", 150, 385, false, 330,275)
    GUI.SetEulerAngles(Img, Vector3.New(-180, 0, -180))
    GUI.SetAnchor(Img, UIAnchor.Center)
    GUI.SetPivot(Img, UIAroundPivot.Center)

    local TxtBg = GUI.ImageCreate(TipsWithoutEquip, "TxtBg", "1800601250",155,220,false, 310,110)
    GUI.SetEulerAngles(TxtBg, Vector3.New(-180, 0, -180))
    GUI.SetAnchor(TxtBg, UIAnchor.Center)
    GUI.SetPivot(TxtBg, UIAroundPivot.Center)

    local Txt = GUI.CreateStatic(TxtBg, "Txt", "少侠,您还没有在线的好友呦~", 0,-12,320,50)
    GUI.StaticSetAlignment(Txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(Txt, UIDefine.FontSizeM)
    GUI.SetColor(Txt, UIDefine.BrownColor)


    -- 道具列表
    local itemListBg = GUI.ImageCreate(parent, "itemListBg", "1800400200", 342, 60, false, 416, 424)
    GUI.SetAnchor(itemListBg, UIAnchor.TopLeft)
    GUI.SetPivot(itemListBg, UIAroundPivot.TopLeft)

    GivenPresentUI.CreatePresentLoopScroll()

    -- 获得好感度
    local getFriendshipLabel = GUI.CreateStatic(parent,"getFriendshipLabel", "获得好感度", 342, 494,  130, 30)
    GUI.SetAnchor(getFriendshipLabel, UIAnchor.TopLeft)
    GUI.SetPivot(getFriendshipLabel, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(getFriendshipLabel, fontSizeDefault)
    GUI.StaticSetAlignment(getFriendshipLabel, TextAnchor.MiddleLeft)
    GUI.SetColor(getFriendshipLabel, colorDark)

    local getFriendshipBg = GUI.ImageCreate(parent,"getFriendshipBg", "1800700010", 462, 492,  false, 166, 34)
    GUI.SetAnchor(getFriendshipBg, UIAnchor.TopLeft)
    GUI.SetPivot(getFriendshipBg, UIAroundPivot.TopLeft)
    
    local getFriendshipText = GUI.CreateStatic(parent,"getFriendshipText", "0", 462, 494,  166, 34, "system", false, false)
    GUI.SetAnchor(getFriendshipText, UIAnchor.TopLeft)
    GUI.SetPivot(getFriendshipText, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(getFriendshipText, fontSizeDefault)
    GUI.StaticSetAlignment(getFriendshipText, TextAnchor.MiddleCenter)
    GUI.SetColor(getFriendshipText, colorWhite)
    _gt.BindName(getFriendshipText,"getFriendshipText")

    -- 赠送次数
    local giveTimesLabel = GUI.CreateStatic(parent,"giveTimesLabel", "赠送次数", 342, 527,  130, 30)
    GUI.SetAnchor(giveTimesLabel, UIAnchor.TopLeft)
    GUI.SetPivot(giveTimesLabel, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(giveTimesLabel, fontSizeDefault)
    GUI.StaticSetAlignment(giveTimesLabel, TextAnchor.MiddleLeft)
    GUI.SetColor(giveTimesLabel, colorDark)

    local giveTimesBg = GUI.ImageCreate(parent,"giveTimesBg", "1800700010", 462, 529,  false, 166, 34)
    GUI.SetAnchor(giveTimesBg, UIAnchor.TopLeft)
    GUI.SetPivot(giveTimesBg, UIAroundPivot.TopLeft)
    
    local giveTimesText = GUI.CreateStatic( parent,"giveTimesText", "0/10", 143, -22, 80, 34, "system", false, false)
    GUI.SetAnchor(giveTimesText, UIAnchor.Bottom)
    GUI.SetPivot(giveTimesText, UIAroundPivot.Bottom)
    GUI.StaticSetFontSize(giveTimesText, fontSizeDefault)
    GUI.StaticSetAlignment(giveTimesText, TextAnchor.MiddleRight)
    GUI.SetColor(giveTimesText, colorWhite)
    _gt.BindName(giveTimesText,"giveTimesText")

    -- 赠送
    local giveBtn = GUI.ButtonCreate(parent,"giveBtn", "1800402080", 640, 506,  Transition.ColorTint, "", 118, 49, false)
    GUI.SetAnchor(giveBtn, UIAnchor.TopLeft)
    GUI.SetPivot(giveBtn, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(giveBtn, UCE.PointerClick , "GivenPresentUI", "OnGiveBtnClick")

    local giveBtnText = GUI.CreateStatic(giveBtn,"giveBtnText", "赠送", 0, 0,  118, 49, "system", true)

    GUI.SetAnchor(giveBtnText, UIAnchor.Center)
    GUI.SetPivot(giveBtnText, UIAroundPivot.Center)
    GUI.StaticSetFontSize(giveBtnText, fontSizeBtn)
    GUI.StaticSetAlignment(giveBtnText, TextAnchor.MiddleCenter)
    GUI.SetColor(giveBtnText, colorWhite)
    GUI.SetIsOutLine(giveBtnText, true)
    GUI.SetOutLine_Color(giveBtnText, colorOutline)
    GUI.SetOutLine_Distance(giveBtnText, 1)

end

function GivenPresentUI.CreatePresentLoopScroll()
    local parent = GUI.Get("GivenPresentUI/panelBg/itemListBg")
    local PresentLoopScroll=
    GUI.LoopScrollRectCreate(
            parent,
            "PresentLoopScroll",
            0,
            10,
            400,
            405,
            "GivenPresentUI",
            "CreatePresentListPool",
            "GivenPresentUI",
            "RefreshPresentLoopScroll",
            0,
            false,
            Vector2.New(80,81),
            5,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    _gt.BindName(PresentLoopScroll,"PresentLoopScroll")
    GUI.SetAnchor(PresentLoopScroll,UIAnchor.Top)
    GUI.SetPivot(PresentLoopScroll,UIAroundPivot.Top)
end

function GivenPresentUI.CreatePresentListPool()
    local PresentLoopScroll = _gt.GetUI("PresentLoopScroll")
    if PresentLoopScroll == nil then
        return
    end
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(PresentLoopScroll) + 1

    local name = "PresentItem"..curIndex
    local ItemIconBg = GUI.ItemCtrlCreate(PresentLoopScroll,name,QualityRes[1],0,0,90,90)
    ItemIcon.SetEmpty(ItemIconBg)

    local decreaseBtn = GUI.ButtonCreate( ItemIconBg,"decreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerClick, "GivenPresentUI", "OnItemIconReduceBtnClick")
    GUI.SetVisible(decreaseBtn, false)
    UILayout.SetSameAnchorAndPivot(decreaseBtn, UILayout.TopRight)

    return ItemIconBg
end

function GivenPresentUI.RefreshPresentLoopScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item =  GUI.GetByGuid(guid)
    local decreaseBtn= GUI.GetChild(item,"decreaseBtn")
    if item == nil then
        return
    end

    if PresentListNum ~= 0 then
        if index > PresentListNum then
            ItemIcon.SetEmpty(item)
            GUI.UnRegisterUIEvent(item, UCE.PointerClick, "GivenPresentUI", "OnItemClick")
            GUI.SetVisible(decreaseBtn,false)
        else
            if GivenPresentGuid[1] ~= nil then
                local data = PresentList[GivenPresentGuid[1]]
                test("data",inspect(GivenPresentGuid))
                if data.clickNum > 0 then
                    GUI.SetVisible(decreaseBtn,true)
                else
                    GUI.SetVisible(decreaseBtn,false)
                end

                GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,data.icon)--物品图片设置

                if data.isBound == 1 then
                    GUI.ItemCtrlSetElementValue(item,eItemIconElement.LeftTopSp,"1800707120")--是否为绑定
                else
                    GUI.ItemCtrlSetElementValue(item,eItemIconElement.LeftTopSp,"")--是否为绑定
                end
                if data.amount > 0  then
                    GUI.ItemCtrlSetIconGray(item,false)
                    GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,data.clickNum.."/"..data.amount)--右下角数字
                    GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[data.grade])--背景设置
                else
                    GUI.ItemCtrlSetIconGray(item,true)
                    GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])--背景设置
                    GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,"")--右下角数字
                end
                GUI.SetData(item,"ItemAmount",data.amount)
                GUI.SetData(item,"favoriteId",data.id)
                GUI.SetData(item,"PresentGuid",GivenPresentGuid[1])
                GUI.SetData(item,"PresentItemIndex",tostring(index))
                GUI.RegisterUIEvent(item, UCE.PointerClick, "GivenPresentUI", "OnItemClick")
                table.remove(GivenPresentGuid,1)
            end
        end
    end
end

-- 道具被点击
function GivenPresentUI.OnItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local ItemAmount = tonumber(GUI.GetData(item,"ItemAmount"))
    IsIntoRefreshBag = 1
    if ItemAmount == 0 then
        local parent = GUI.GetWnd("GivenPresentUI")
        local itemid = tonumber(GUI.GetData(item,"favoriteId"))
        local tips = Tips.CreateByItemId(itemid,parent,"favoriteTips",200,60,20)
        GUI.SetData(tips, "ItemId", itemid)
        _gt.BindName(tips,"favoriteTips")
        local wayBtn = GUI.ButtonCreate(tips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false)
        UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"GivenPresentUI","OnClickFormationWayBtn")
        GUI.AddWhiteName(tips, GUI.GetGuid(wayBtn))
    else
        local PresentGuid = tostring(GUI.GetData(item,"PresentGuid"))
        local PresentItemIndex = tostring(GUI.GetData(item,"PresentItemIndex"))
        local decreaseBtn= GUI.GetChild(item,"decreaseBtn")
        local clickNum = 1
        local giveAwayCount = tostring(LD.GetContactLongCustomData("giveAwayCount",tostring(SelectCheckBoxRoleGuid)))
        if giveAwayCount == "10" then
            CL.SendNotify(NOTIFY.ShowBBMsg,"已达每日赠送上限")
            return
        end
        for k, v in pairs(PresentList) do
            clickNum = clickNum +v.clickNum
        end
        if tonumber(clickNum)+tonumber(giveAwayCount) > 10  then
            CL.SendNotify(NOTIFY.ShowBBMsg,"已达每日赠送上限")
            return
        end
        if PresentList[PresentGuid].clickNum < PresentList[PresentGuid].amount then
            PresentList[PresentGuid].clickNum = PresentList[PresentGuid].clickNum + 1
        end
        if PresentList[PresentGuid].clickNum > 0 then
            GUI.SetVisible(decreaseBtn,true)
        end
        local temp = {
            ItemGuid = tostring(guid),
            PresentGuid = PresentGuid,
            BtnGuid = tostring(GUI.GetGuid(decreaseBtn))
        }
        CurPresentList[PresentItemIndex] = temp
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,PresentList[PresentGuid].clickNum.."/"..PresentList[PresentGuid].amount)
        GivenPresentUI.ShowFriendshipVal()
    end
end

-- 获取途径
function GivenPresentUI.OnClickFormationWayBtn()
    local tip = _gt.GetUI("favoriteTips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end

-- 赠送
function GivenPresentUI.OnGiveBtnClick(guid)
    local RoleGuid = SelectCheckBoxRoleGuid
    local PresentIdInfo = ""
    local SumNum = 0
    for k, v in pairs(PresentList) do
        SumNum = SumNum + v.clickNum
    end
    if RoleGuid == nil or RoleGuid == "nil" then
        CL.SendNotify(NOTIFY.ShowBBMsg,"请选中要赠送礼物的好友")
        return
    end
    if SumNum == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg,"请选中一个礼物再赠送")
        return
    end
    for k, v in pairs(PresentList) do
        if v.clickNum > 0 then
            PresentIdInfo = PresentIdInfo..tostring(k)..":"..tostring(v.clickNum).."_"
            table.insert(GivenPresentGuid,tostring(k))
        end
    end
    CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","useLikeabilityItem",tostring(RoleGuid),PresentIdInfo)
    IsIntoRefreshBag = 2
end

-- 减少按钮被点击
function GivenPresentUI.OnItemIconReduceBtnClick(guid)
    local reduceBtn = GUI.GetByGuid(guid)
    local item = GUI.GetParentElement(reduceBtn)
    local PresentGuid = tostring(GUI.GetData(item,"PresentGuid"))
    local decreaseBtn= GUI.GetChild(item,"decreaseBtn")
    if PresentList[PresentGuid].clickNum > 0 then
        PresentList[PresentGuid].clickNum = PresentList[PresentGuid].clickNum - 1
    end
    if PresentList[PresentGuid].clickNum == 0 then
        GUI.SetVisible(decreaseBtn,false)
    end
    GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,PresentList[PresentGuid].clickNum.."/"..PresentList[PresentGuid].amount)
    GivenPresentUI.ShowFriendshipVal()
end

-- 显示好感度
function GivenPresentUI.ShowFriendshipVal()
    local getFriendshipText = GUI.Get("GivenPresentUI/panelBg/getFriendshipText")
    local val = 0
    local num = 0
    for k, v in pairs(PresentList) do
        val =  val + (v.clickNum * v.favorable)
        num = num + 1
    end
    GUI.StaticSetText(getFriendshipText, val)
end

function GivenPresentUI.CreateRoleLoopScroll()
    local parent = GUI.Get("GivenPresentUI/panelBg/contactListBg")
    local RoleLoopScroll=
    GUI.LoopScrollRectCreate(
            parent,
            "RoleLoopScroll",
            0,
            7,
            320,
            498,
            "GivenPresentUI",
            "CreateRoleListPool",
            "GivenPresentUI",
            "RefreshRoleLoopScroll",
            0,
            false,
            Vector2.New(300,110),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top,
            false
    )
    _gt.BindName(RoleLoopScroll,"RoleLoopScroll")
    GivenPresentUI.RoleLoopScroll = RoleLoopScroll
    GUI.SetAnchor(RoleLoopScroll,UIAnchor.Top)
    GUI.SetPivot(RoleLoopScroll,UIAroundPivot.Top)
    GUI.LoopScrollRectRefreshCells(RoleLoopScroll)
end

function GivenPresentUI.CreateRoleListPool()
    local RoleLoopScroll = _gt.GetUI("RoleLoopScroll")
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(RoleLoopScroll)+1
    local name = "ContactItem" .. curIndex

    -- 背景
    local contactItem = GUI.CheckBoxExCreate(RoleLoopScroll,name, "1800800030", "1800800040", 1, 0,  false, 300, 100)
    GUI.CheckBoxExSetCheck(contactItem, false)
    GUI.SetAnchor(contactItem, UIAnchor.Top)
    GUI.SetPivot(contactItem, UIAroundPivot.Top)
    GUI.RegisterUIEvent(contactItem, UCE.PointerClick , "GivenPresentUI", "OnContactItemClick")

    -- iconBg
    local iconBg = GUI.ImageCreate(contactItem,"iconBg", "1800201110", 8, 10)
    GUI.SetAnchor(iconBg, UIAnchor.TopLeft)
    GUI.SetPivot(iconBg, UIAroundPivot.TopLeft)

    -- icon
    local icon = GUI.ImageCreate(iconBg,"icon", "1900000000", 0, 0,  false, 76, 76, false)
    GUI.SetAnchor(icon, UIAnchor.Center)
    GUI.SetPivot(icon, UIAroundPivot.Center)
    GUI.AddRedPoint(icon,UIAnchor.TopLeft,0,0,"1800208080")
    GUI.SetRedPointVisable(icon, false)

    -- 玩家等级
    local level = GUI.CreateStatic(iconBg,"level", "120", -6, -1,  50, 25)
    GUI.SetAnchor(level, UIAnchor.BottomRight)
    GUI.SetPivot(level, UIAroundPivot.BottomRight)
    GUI.StaticSetFontSize(level, fontSizeSmaller)
    GUI.StaticSetAlignment(level,TextAnchor.MiddleRight)
    GUI.SetColor(level, colorWhite)
    GUI.SetIsOutLine(level, true)
    GUI.SetOutLine_Color(level, Color.New(0/255,0/255,0/255,255/255))
    GUI.SetOutLine_Distance(level, 1)

    -- 玩家名字
    local RoleName = GUI.CreateStatic(contactItem,"RoleName", "玩家有六个字", 138, 18,  150, 26, "system", false, false)
    GUI.SetAnchor(RoleName, UIAnchor.TopLeft)
    GUI.SetPivot(RoleName, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(RoleName, fontSizeBigger)
    GUI.StaticSetAlignment(RoleName,TextAnchor.MiddleLeft)
    GUI.SetColor(RoleName, colorDark)
    GUI.StaticSetFontSizeBestFit(RoleName)

    -- 门派标签
    local schoolMark = GUI.ImageCreate(contactItem,"schoolMark", "1800400200", 98, 18)
    GUI.SetAnchor(schoolMark, UIAnchor.TopLeft)
    GUI.SetPivot(schoolMark, UIAroundPivot.TopLeft)

    -- ID
    local idText = GUI.CreateStatic(contactItem,"idText", "ID：7777777", 110, 63,  150, 30,"system",true)
    GUI.SetAnchor(idText, UIAnchor.TopLeft)
    GUI.SetPivot(idText, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(idText, fontSizeDefault)
    GUI.SetColor(idText, colorDark)

    return contactItem
end

function GivenPresentUI.RefreshRoleLoopScroll(parameter)
    parameter = string.split(parameter , "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])+1
    local item=GUI.GetByGuid(guid)
    if not item then
        return
    end

    local icon = GUI.GetChild(item,"icon")
    local level = GUI.GetChild(item,"level")
    local RoleName = GUI.GetChild(item,"RoleName")
    local schoolMark = GUI.GetChild(item,"schoolMark")
    local idText = GUI.GetChild(item,"idText")
    local temp = CurFriendList[index]
    if temp then
        GUI.SetData(item,"RoleGuid",temp.guid)
        if SelectCheckBoxRoleGuid == nil then
            if index == 1 then
                SelectCheckBoxRoleGuid = tostring(temp.guid)
                GUI.CheckBoxExSetCheck(item, true)
            end
        end
        if SelectCheckBoxRoleGuid == tostring(temp.guid) then
            local OldItem = GUI.GetByGuid(SelectCheckBoxRoleItemGuid)
            GUI.CheckBoxExSetCheck(OldItem, false)
            SelectCheckBoxRoleItemGuid = tostring(guid)
            SelectCheckBoxItemRoleGuid = tostring(temp.guid)
            SelectCheckBoxRoleGuid = tostring(temp.guid)
            GUI.CheckBoxExSetCheck(item, true)
        end
        local role = DB.GetRole(tonumber(temp.role))
        GUI.ImageSetImageID(icon, tostring(role.Head))
        GUI.StaticSetText(level,temp.level)
        GUI.StaticSetText(RoleName,temp.name)
        local school = DB.GetSchool(tonumber(temp.school))
        GUI.ImageSetImageID(schoolMark, tostring(school.Icon))
        GUI.StaticSetText(idText,"ID:"..temp.roleId+1000000)
    end
end

-- 好友列表被点击
function GivenPresentUI.OnContactItemClick(guid)
    local element = GUI.GetByGuid(guid)
    local roleGuid = tostring(GUI.GetData(element, "RoleGuid"))
    local giveTimesText = _gt.GetUI("giveTimesText")
    local giveAwayCount = tostring(LD.GetContactLongCustomData("giveAwayCount",roleGuid))
    GUI.StaticSetText(giveTimesText,giveAwayCount.."/10")
    IsIntoRefreshBag = 1
    if element == nil then
        return
    end
    if SelectCheckBoxRoleItemGuid then
        if tostring(guid) ~= SelectCheckBoxRoleItemGuid then
            local getFriendshipText = GUI.Get("GivenPresentUI/panelBg/getFriendshipText")
            GUI.StaticSetText(getFriendshipText, 0)
            local item = GUI.GetByGuid(SelectCheckBoxRoleItemGuid)
            GUI.CheckBoxExSetCheck(item, false)
            for i, v in pairs(PresentList) do
                v["clickNum"] = 0
            end
            for k, v in pairs(CurPresentList) do
                local item = GUI.GetByGuid(v.ItemGuid)
                local Btn = GUI.GetByGuid(v["BtnGuid"])
                if PresentList[v.PresentGuid] ~= nil then
                    GUI.ItemCtrlSetElementValue(item,eItemIconElement.RightBottomNum,tostring(PresentList[v.PresentGuid]["clickNum"]).."/"..tostring(PresentList[v.PresentGuid]["amount"]))
                end
                GUI.SetVisible(Btn,false)
            end
        end
    end
    GUI.CheckBoxExSetCheck(element, true)
    SelectCheckBoxRoleItemGuid = guid
    SelectCheckBoxRoleGuid = roleGuid
end

--退出界面
function GivenPresentUI.OnExit()
    local wnd = GUI.GetWnd("GivenPresentUI")
    if wnd ~= nil then
        local item = GUI.GetByGuid(SelectCheckBoxRoleItemGuid)
        GUI.CheckBoxExSetCheck(item, false)
        GUI.CloseWnd("GivenPresentUI")
    end
end


function GivenPresentUI.OnRefreshBag()
    local RoleGuid = tostring(SelectCheckBoxRoleGuid)
    local getFriendshipText = _gt.GetUI("getFriendshipText")
    GUI.StaticSetText(getFriendshipText,"0")
    local giveTimesText = _gt.GetUI("giveTimesText")
    local giveAwayCount = tostring(LD.GetContactLongCustomData("giveAwayCount",RoleGuid))
    GUI.StaticSetText(giveTimesText,giveAwayCount.."/10")
    if IsIntoRefreshBag == 1 then
        GivenPresentUI.RefreshAllPresent()
    end
end

function GivenPresentUI.InitFriendData(contact_type)
    CurFriendList = {}
    local list = LD.GetContactDataListByType(contact_type)
    if not list then
        return
    end
    for i = 1, list.Count do
        local data = list[i - 1]
        local temp = {
            guid = data.guid,
            contact_type = data.contact_type,
            name = data.name,
            role = data.role,
            roleId = data.sn,
            level = data.level,
            school = data.job,
            friendship = data.friendship,
            last_contact_time = data.last_contact_time,
            status = data.status,
            vip = data.vip,
            reincarnation = data.reincarnation,
        }
        if data.status == 1 then
            if SelectCheckBoxRoleGuid == tostring(data.guid) then
                table.insert(CurFriendList,1,temp)
            else
                CurFriendList[#CurFriendList + 1] = temp
            end
        end
    end
end

function GivenPresentUI.RefreshRoleItems()


    local TipsWithoutEquip = _gt.GetUI("TipsWithoutEquip")

    if  #CurFriendList > 0 then

        GUI.SetVisible(TipsWithoutEquip,false)

        GUI.LoopScrollRectSetTotalCount(GivenPresentUI.RoleLoopScroll, #CurFriendList);
    else

        GUI.SetVisible(TipsWithoutEquip,true)

        GUI.LoopScrollRectSetTotalCount(GivenPresentUI.RoleLoopScroll ,0)
    end
    GUI.LoopScrollRectRefreshCells(GivenPresentUI.RoleLoopScroll)
end

function GivenPresentUI.RefreshAllPresent()
    GivenPresentUI.RefreshPresentData()
    GivenPresentUI.UpdatePresentList()
end


function GivenPresentUI.Refresh()
    CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_friend)
    CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","CanGiveAwayItemData")
end

function GivenPresentUI.RefreshPresentData()
    PresentList = {}
    GrayPresentList = {}
    GivenPresentGuid = {}
    local index = 0
    for k,v in pairs(GivenPresentUI.GiveAwayItemData) do
        local data = DB.GetOnceItemByKey2(k)
        local itemGuid = LD.GetItemGuidsById(data.Id) -- 获取物品所有的格子guid
        if itemGuid then
            if itemGuid.Count-1 >= 0 then
                for i=0,itemGuid.Count-1 do -- 遍历所有的格子
                    index = index + 1
                    local isBound= tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, itemGuid[i]))  -- 此格子内的物品是否绑定,1为绑定
                    local amount= tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, itemGuid[i])) -- 此格子内的物品数量
                    local temp = {
                        id = tonumber(data.Id),
                        name = data.Name,
                        KeyName = data.KeyName,
                        icon = data.Icon,
                        isBound = isBound,--物品是否绑定
                        grade = data.Grade,
                        amount = amount,--物品数量
                        clickNum = 0 ,
                        sign = tostring(itemGuid[i]),
                        info = data.Info, --使用提示
                        tips = data.Tips, -- 物品介绍
                        favorable = GivenPresentUI.GiveAwayItemData[data.KeyName],--好感度
                    }
                    GrayPresentList[#GrayPresentList + 1] = temp
                end
            else
                index = index + 1
                local temp = {
                    id = tonumber(data.Id),
                    name = data.Name,
                    KeyName = data.KeyName,
                    icon = data.Icon,
                    isBound = 0,--物品是否绑定
                    amount = 0,--物品数量
                    grade = data.Grade,
                    clickNum = 0 ,
                    sign = tostring(index),
                    info = data.Info, --使用提示
                    tips = data.Tips, -- 物品介绍
                    favorable = GivenPresentUI.GiveAwayItemData[data.KeyName],--好感度
                }
                GrayPresentList[#GrayPresentList + 1] = temp
            end
        end
    end

    local TableSet = function(a,b)
        if a.id ~= b.id then
            if a.amount > 0 and b.amount > 0  then
                return a.id < b.id
            elseif a.amount == 0 and b.amount == 0  then
                return a.id < b.id
            else
                return a.amount > b.amount
            end
        else
            return a.amount < b.amount
        end
        return false
    end

    table.sort(GrayPresentList, TableSet)
    test("GrayPresentList",inspect(GrayPresentList))

    for i = 1, #GrayPresentList do
        local tableData = GrayPresentList[i]
        PresentList[tableData.sign] = tableData
        table.insert(GivenPresentGuid,tostring(tableData.sign))
    end
    test("PresentList",inspect(PresentList))
end


function GivenPresentUI.UpdatePresentList()
    -- 道具栏格子数量
    local PresentLoopScroll =_gt.GetUI("PresentLoopScroll")
    PresentListNum = 0
    for k, v in pairs(PresentList) do
        PresentListNum = PresentListNum + 1
    end
    local itemsNR = PresentListNum
    -- 补足额外的道具格子
    if itemsNR > CountNum then
        local gridNR, total = PresentCount * PresentCount, PresentCount * math.ceil(itemsNR / PresentCount)
        if gridNR < total then
            gridNR = total
        end
        GUI.LoopScrollRectSetTotalCount(PresentLoopScroll, gridNR)
    else
        GUI.LoopScrollRectSetTotalCount(PresentLoopScroll,CountNum)
    end
    -- 刷新道具栏
    GUI.LoopScrollRectRefreshCells(PresentLoopScroll);
end

-- 好友列表刷新
function GivenPresentUI.OnFriendListUpdate(contact_type)
    if contact_type == CONTACT_TYPE.contact_friend then
        GivenPresentUI.InitFriendData(contact_type)
        GivenPresentUI.RefreshRoleItems()
    end
end

function GivenPresentUI.Register()
    CL.RegisterMessage(GM.FriendListUpdate, "GivenPresentUI", "OnFriendListUpdate")
    CL.RegisterMessage(GM.RefreshBag,"GivenPresentUI","OnRefreshBag")
end

function GivenPresentUI.UnRegister()
    CL.UnRegisterMessage(GM.FriendListUpdate, "GivenPresentUI", "OnFriendListUpdate")
    CL.UnRegisterMessage(GM.RefreshBag,"GivenPresentUI","OnRefreshBag")
end