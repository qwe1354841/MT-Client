local CrossServerWarfareRankingUI = {}
_G.CrossServerWarfareRankingUI = CrossServerWarfareRankingUI

--跨服战结算界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
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
local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorGary = Color.New(200 / 255, 200 / 255, 200 / 255, 1)

----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------

local uiName = "跨服战结算"

-- 显示多少位排名
local showRankNum = 50

-- 刷新数据时间
local refreshTime = 1*60

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

-- 阵营0,1,2,3 服务端会发送数据，如果没有时使用下面的数据
local camplist={
    "未分配",
    "青龙",
    "朱雀",
    "白虎",
}

-- 排名前的图标按顺序显示
local rangeImage = {
    "1801604010",
    "1801604020",
    "1801604030",
}

local roleSpriteInfo = {
    [31]= { "1800107010", "600001779", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [32]= { "1800107020", "600001842", "(0,2.24,-3.25),(0,0,0,1),True,5,0.42,4.27,60" },
    [33]= { "1800107030", "600001989", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [34]= { "1800107040", "600001982", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [35]= { "1800107050", "600001995", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [36]= { "1800107060", "600001880", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [37]= { "1800107070", "600001921", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    [38]= { "1800107080", "600001885", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    [39]= { "1800107090", "600001837", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    [40]= { "1800107100", "3000001490", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    [41]= { "1800107110", "600001956", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    [42]= { "1800107120", "600001959", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
}

--------------------------------------------End 表配置 End------------------------------------

function CrossServerWarfareRankingUI.Main(parameter)
    local panel = GUI.WndCreateWnd("CrossServerWarfareRankingUI", "CrossServerWarfareRankingUI", 0, 0);
    local panelCover = GUI.ImageCreate(panel, "panelCover", "1800001060", 0, 0, false, GUI.GetWidth(panel),GUI.GetHeight(panel))
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(panelCover,UCE.PointerClick,"CrossServerWarfareRankingUI", "OnCloseBtnClick")
    -- MoneyBar.CreateDefault(panelCover, "WuDaoHuiUI")
    local panelBg = GUI.GroupCreate(panel, "panelBg", 11, 0, 1280, 660)
    SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(panelBg, "panelBg")

    CrossServerWarfareRankingUI.campUI(panelBg, 0)

    local TitleBg = GUI.ImageCreate(panelBg, "TitleBg", "1800608420", 0, -230, true)
    SetAnchorAndPivot(TitleBg, UIAnchor.Center, UIAroundPivot.Center)
    
    local CloseBtn = GUI.ButtonCreate(panelBg, "CloseBtn", "1800002050", 320, -204, Transition.ColorTint,'',34,35,false)
    SetAnchorAndPivot(CloseBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(CloseBtn, UCE.PointerClick, "CrossServerWarfareRankingUI", "OnCloseBtnClick")

    local leftRole = GUI.GroupCreate(panelBg,"leftRole",100,0,600,600)
    SetSameAnchorAndPivot(leftRole,UILayout.Left)
    CrossServerWarfareRankingUI.createRoleModel(leftRole,-85,nil,35) -- showRoleId.left or 35)


    local rightRole = GUI.GroupCreate(panelBg,"rightRole",-100,0,600,600)
    SetSameAnchorAndPivot(rightRole,UILayout.Right)
    CrossServerWarfareRankingUI.createRoleModel(rightRole,-41,nil,40) --showRoleId.right or 40)
end

function CrossServerWarfareRankingUI.OnShow(parameter)
    local wnd = GUI.GetWnd("CrossServerWarfareRankingUI")
    if wnd then
        GUI.SetVisible(wnd, true)
    end

end



function CrossServerWarfareRankingUI.campUI(parent, x, y, num)
    if parent == nil then
        return
    end

    if num == nil then
        num = 1
    end

    local body = GUI.GetChild(parent, "LeftPanel" .. num)
    if body then
        return
    end

    if x == nil then
        x = 0
    end

    if y == nil then
        y = 0
    end
    local showColor = UIDefine.RedColor

    local panelBg = parent
    local LeftPanel = GUI.ImageCreate(panelBg, "LeftPanel" .. num, "1800600540", x, y, false,440,322)
    SetAnchorAndPivot(LeftPanel, UIAnchor.Center, UIAroundPivot.Center)

    local IntegralTotalText1 = GUI.CreateStatic(LeftPanel, "IntegralTotalText1", uiName or "跨服战结算", 0, -130, 280, 30,
            "100")
    SetAnchorAndPivot(IntegralTotalText1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(IntegralTotalText1, Color.New(1,225/255,57/255,1))
    GUI.StaticSetFontSize(IntegralTotalText1, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(IntegralTotalText1, TextAnchor.MiddleCenter)
    GUI.StaticSetIsGradientColor(IntegralTotalText1,true)
    GUI.StaticSetGradient_ColorTop(IntegralTotalText1,Color.New(255/255,244/255,139/255,255/255))
    --设置描边
    GUI.SetIsOutLine(IntegralTotalText1,true)
    GUI.SetOutLine_Distance(IntegralTotalText1,3)
    GUI.SetOutLine_Color(IntegralTotalText1,Color.New(182/255,52/255,40/255,255/255))

    --设置阴影
    GUI.SetIsShadow(IntegralTotalText1,true)
    GUI.SetShadow_Distance(IntegralTotalText1,Vector2.New(0,-1))
    GUI.SetShadow_Color(IntegralTotalText1,UIDefine.BlackColor)

    local WinImg = GUI.ImageCreate(LeftPanel, "WinImg", "1800604280", 30, -190, true)
    SetAnchorAndPivot(WinImg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(WinImg, "WinImg")
    GUI.SetVisible(WinImg, false)

    local RankSpTitle1 = GUI.CreateStatic(LeftPanel, "RankSpTitle1", "排名", -140, -90, 280, 30, "system")
    SetAnchorAndPivot(RankSpTitle1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(RankSpTitle1, showColor)
    GUI.StaticSetFontSize(RankSpTitle1, 22)
    GUI.StaticSetAlignment(RankSpTitle1, TextAnchor.MiddleCenter)


    local OfficialRankTitle1 = GUI.CreateStatic(LeftPanel, "OfficialRankTitle1", "阵营", 0, -90, 280, 30, "system")
    SetAnchorAndPivot(OfficialRankTitle1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(OfficialRankTitle1, showColor)
    GUI.StaticSetFontSize(OfficialRankTitle1, 22)
    GUI.StaticSetAlignment(OfficialRankTitle1, TextAnchor.MiddleCenter)

    local IntegralTitle1 = GUI.CreateStatic(LeftPanel, "IntegralTitle1", "积分", 140, -90, 280, 30, "system")
    SetAnchorAndPivot(IntegralTitle1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(IntegralTitle1, showColor)
    GUI.StaticSetFontSize(IntegralTitle1, 22)
    GUI.StaticSetAlignment(IntegralTitle1, TextAnchor.MiddleCenter)


    local array = {RankSpTitle1,OfficialRankTitle1,IntegralTitle1}
    for _,v in pairs(array) do
        --设置阴影
        GUI.SetIsShadow(v,true)
        GUI.SetShadow_Distance(v,Vector2.New(0,-1))
        GUI.SetShadow_Color(v,UIDefine.BlackColor)
    end



    -- 朱雀阵营排行榜
    local ZhuQueRankScroll = GUI.LoopScrollRectCreate(
            LeftPanel,
            "ZhuQueRankScroll",
            0,
            28,
            640,
            260,
            "CrossServerWarfareRankingUI",
            "CreateZhuQueRankItem",
            "CrossServerWarfareRankingUI",
            "RefreshZhuQueRankScroll",
            0,
            false,
            Vector2.New(660, 42),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top
    );
    SetAnchorAndPivot(ZhuQueRankScroll, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(ZhuQueRankScroll, "ZhuQueRankScroll")
end

function CrossServerWarfareRankingUI.CreateZhuQueRankItem()
    local ZhuQueRankScroll = _gt.GetUI("ZhuQueRankScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(ZhuQueRankScroll) + 1;
    local ZhuQueRankItem = GUI.ItemCtrlCreate(ZhuQueRankScroll, "ZhuQueRankItem" .. curCount, "1800600640", 0, 0, 660,
            42)
    local ZhuQue_Sp = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Sp", "2", -240, 1, 150, 50, "system")
    SetAnchorAndPivot(ZhuQue_Sp, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Sp, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Sp, 24)
    GUI.StaticSetAlignment(ZhuQue_Sp, TextAnchor.MiddleCenter)
    local ZhuQue_Name = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Name", "我啊啊", -130, 1, 150, 50, "system")
    SetAnchorAndPivot(ZhuQue_Name, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Name, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Name, 24)
    GUI.StaticSetAlignment(ZhuQue_Name, TextAnchor.MiddleCenter)
    local ZhuQue_Officer = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Officer", "无名小吏", 0, 1, 150, 50, "system")
    SetAnchorAndPivot(ZhuQue_Officer, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Officer, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Officer, 24)
    GUI.StaticSetAlignment(ZhuQue_Officer, TextAnchor.MiddleCenter)
    local ZhuQue_Score = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Score", "2", 120, 1, 150, 50, "system")
    SetAnchorAndPivot(ZhuQue_Score, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Score, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Score, 24)
    GUI.StaticSetAlignment(ZhuQue_Score, TextAnchor.MiddleCenter)
    local ZhuQue_Rate = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Rate", "99%", 240, 1, 150, 50, "system")
    SetAnchorAndPivot(ZhuQue_Rate, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Rate, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Rate, 24)
    GUI.StaticSetAlignment(ZhuQue_Rate, TextAnchor.MiddleCenter)

    local OffLine1 = GUI.ImageCreate(ZhuQueRankItem, "OffLine1", "1800604360", -280, 0, false,30,30)
    SetAnchorAndPivot(OffLine1, UIAnchor.Center, UIAroundPivot.Center)

    return ZhuQueRankItem;
end



function CrossServerWarfareRankingUI.RefreshZhuQueRankScroll(parameter)

    if CrossServerWarfareRankingUI.needData == nil then
        test("function CrossServerWarfareRankingUI.RefreshZhuQueRankScroll(parameter) needData is null")
        return
    end

    parameter = string.split(parameter, "#")
    local guid = parameter[1];
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local Sp = GUI.GetChild(item, "ZhuQue_Sp")
    local Name = GUI.GetChild(item, "ZhuQue_Name")
    local Officer = GUI.GetChild(item, "ZhuQue_Officer")
    local Score = GUI.GetChild(item, "ZhuQue_Score")
    local Rate = GUI.GetChild(item, "ZhuQue_Rate")
    local Img = GUI.GetChild(item, "OffLine1")


    if rangeImage and rangeImage[index] then
        local image = rangeImage[index]
        GUI.ImageSetImageID(Img,image)
        GUI.SetVisible(Img, true)
    else
        GUI.SetVisible(Img,false)
    end

    GUI.StaticSetText(Sp, tostring(index))

    local data = CrossServerWarfareRankingUI.needData[index]
    if data == nil then
        test("function CrossServerWarfareRankingUI.RefreshZhuQueRankScroll(parameter) data is null, out bounds error ")
        return
    end

    GUI.StaticSetText(Name, data.name)
    GUI.StaticSetText(Officer, data.camp)
    GUI.StaticSetText(Score, data.integral)
    GUI.StaticSetText(Rate, data.tier)

end


function CrossServerWarfareRankingUI.createRoleModel(parent,x,y,roleId)
    if parent == nil then
        test("CrossServerWarfareRankingUI.createRoleModel(parent) parent is null")
        return
    end
    if x == nil then
        x = 0
    end
    if y == nil then
        y = 0
    end
    local dn = GUI.GetName(parent)
    if dn == nil then
        dn = "roleName"
    end
    local rolePanelBg = parent
    -- 创建角色模型
    if rolePanelBg then

        local SelfTemplateID = nil
        if roleId then
            SelfTemplateID = roleId
        else
            SelfTemplateID = CL.GetRoleTemplateID() -- 获取当前角色id
            if not SelfTemplateID or SelfTemplateID == 0 then
                return
            end
        end

        local _RoleNodeModel = _gt.GetUI("AddAttrPage_RoleNodeModel-"..dn)
        if _RoleNodeModel == nil  then -- 如果父类不存在 创建父类
            _RoleNodeModel = GUI.RawImageCreate(rolePanelBg,false,"RoleNodeModel-"..dn,"",x,y,3,false,600,600)
            GUI.SetIsRaycastTarget(_RoleNodeModel, false); -- 是否响应交互事件
            SetAnchorAndPivot(_RoleNodeModel, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetDepth(_RoleNodeModel, 0)
            _gt.BindName(_RoleNodeModel,"AddAttrPage_RoleNodeModel-"..dn)
            if dn == 'leftRole' then
                GUI.SetEulerAngles(_RoleNodeModel,Vector3.New(0,180,0))
                GUI.SetPositionY(_RoleNodeModel, y+15)
            end
        end

        local _roleModel = _gt.GetUI("AddAttrPage_RoleModel-"..dn)
        if _roleModel == nil and _RoleNodeModel ~= nil then
            _roleModel = GUI.RawImageChildCreate(_RoleNodeModel,false,"RoleModel-"..dn,roleSpriteInfo[SelfTemplateID][2],0,0)
            _gt.BindName(_roleModel,"AddAttrPage_RoleModel-"..dn)
            GUI.AddToCamera(_RoleNodeModel);
            GUI.RawImageSetCameraConfig(_RoleNodeModel, roleSpriteInfo[SelfTemplateID][3]);
            SetSameAnchorAndPivot(_roleModel, UILayout.Center)
            GUI.RawImageChildSetModleRotation(_roleModel, Vector3.New(0,180,0))
        end

    end
end

function CrossServerWarfareRankingUI.OnCloseBtnClick()

    GUI.CloseWnd("CrossServerWarfareRankingUI")

end

