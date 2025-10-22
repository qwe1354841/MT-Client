-- 积分塔活动面板

-- 代理可配置
-- 显示的人物形象，可在roleSpriteInfo中寻找下标
-- local showRoleId={left=35,right=40}
local uiName = "积分塔排行榜"
-- 排名前的图标按顺序显示
local rangeImage = {
    "1801604010",
    "1801604020",
    "1801604030",
}
-- 显示多少位排名
local showRankNum = 50
-- 阵营0,1,2,3 服务端会发送数据，如果没有时使用下面的数据
local camplist={
    "未分配",
    "青龙",
    "朱雀",
    "白虎",
}
-- 刷新数据时间
local refreshTime = 1*60


local SevenTierClimbTowerIntegralUI = {}
_G.SevenTierClimbTowerIntegralUI = SevenTierClimbTowerIntegralUI
local _gt = UILayout.NewGUIDUtilTable()

local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorGary = Color.New(200 / 255, 200 / 255, 200 / 255, 1)

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

function SevenTierClimbTowerIntegralUI.Main(parameter)
    local panel = GUI.WndCreateWnd("SevenTierClimbTowerIntegralUI", "SevenTierClimbTowerIntegralUI", 0, 0);
    local panelCover = GUI.ImageCreate(panel, "panelCover", "1800001060", 0, 0, false, GUI.GetWidth(panel),GUI.GetHeight(panel))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(panelCover,UCE.PointerClick,"SevenTierClimbTowerIntegralUI", "OnCloseBtnClick")
    -- MoneyBar.CreateDefault(panelCover, "WuDaoHuiUI")
    local panelBg = GUI.GroupCreate(panel, "panelBg", 11, 0, 1280, 660)
    UILayout.SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(panelBg, "panelBg")

    SevenTierClimbTowerIntegralUI.campUI(panelBg, 0)

    -- local TitleBg = GUI.ImageCreate(panelBg, "TitleBg", "1801704040", 0, -270, false,280,160)
    -- UILayout.SetAnchorAndPivot(TitleBg, UIAnchor.Center, UIAroundPivot.Center)
    local TitleBg = GUI.ImageCreate(panelBg, "TitleBg", "1800608420", 0, -230, true)
    UILayout.SetAnchorAndPivot(TitleBg, UIAnchor.Center, UIAroundPivot.Center)
    -- local Title = GUI.ImageCreate(TitleBg, "Title", "1800604370", 0, 15, true)
    -- UILayout.SetAnchorAndPivot(Title, UIAnchor.Center, UIAroundPivot.Center)
    local CloseBtn = GUI.ButtonCreate(panelBg, "CloseBtn", "1800002050", 320, -204, Transition.ColorTint,'',34,35,false)
    UILayout.SetAnchorAndPivot(CloseBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(CloseBtn, UCE.PointerClick, "SevenTierClimbTowerIntegralUI", "OnCloseBtnClick")
    -- GUI.SetEulerAngles(CloseBtn,Vector3.New(0,0,15))

    local leftRole = GUI.GroupCreate(panelBg,"leftRole",0,0,600,600)
    UILayout.SetSameAnchorAndPivot(leftRole,UILayout.Left)
    SevenTierClimbTowerIntegralUI.createRoleModel(leftRole,-85,nil,35) -- showRoleId.left or 35)


    local rightRole = GUI.GroupCreate(panelBg,"rightRole",0,0,600,600)
    UILayout.SetSameAnchorAndPivot(rightRole,UILayout.Right)
    SevenTierClimbTowerIntegralUI.createRoleModel(rightRole,-41,nil,40) --showRoleId.right or 40)
end

function SevenTierClimbTowerIntegralUI.OnShow(parameter)
    local wnd = GUI.GetWnd("SevenTierClimbTowerIntegralUI")
    if wnd then
        GUI.SetVisible(wnd, true)
    end
    SevenTierClimbTowerIntegralUI.register()

    SevenTierClimbTowerIntegralUI.request()

    SevenTierClimbTowerIntegralUI.dataTimer = Timer.New(SevenTierClimbTowerIntegralUI.request,refreshTime,-1,true)
    SevenTierClimbTowerIntegralUI.dataTimer:Stop()
    SevenTierClimbTowerIntegralUI.dataTimer:Start()
end

function SevenTierClimbTowerIntegralUI.OnCloseBtnClick()
    SevenTierClimbTowerIntegralUI.unRegister()
    SevenTierClimbTowerIntegralUI.dataTimer:Stop()
    SevenTierClimbTowerIntegralUI.dataTimer:Reset(SevenTierClimbTowerIntegralUI.request,refreshTime,-1,true)
    GUI.Destroy("SevenTierClimbTowerIntegralUI")
end

function SevenTierClimbTowerIntegralUI.register()
    CL.RegisterMessage(GM.RankDateUpdate,
     "SevenTierClimbTowerIntegralUI", "refresh")
end
function SevenTierClimbTowerIntegralUI.unRegister()
end

function SevenTierClimbTowerIntegralUI.campUI(parent, x, y, num)
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
    local LeftPanel = GUI.ImageCreate(panelBg, "LeftPanel" .. num, "1800600540", x, y, false,640,422)
    UILayout.SetAnchorAndPivot(LeftPanel, UIAnchor.Center, UIAroundPivot.Center)
    -- 左侧朱雀
    -- local BePresentNumText1 = GUI.CreateStatic(LeftPanel, "BePresentNumText1", "在场：", -180, -180, 280, 30,
    --     "system")
    -- UILayout.SetAnchorAndPivot(BePresentNumText1, UIAnchor.Center, UIAroundPivot.Center)
    -- GUI.SetColor(BePresentNumText1, colorWhite)
    -- GUI.StaticSetFontSize(BePresentNumText1, 22)
    -- GUI.StaticSetAlignment(BePresentNumText1, TextAnchor.MiddleCenter)

    -- local BePresentNum1 = GUI.CreateStatic(LeftPanel, "BePresentNum1", "0 / 0", -130, -180, 280, 30, "system")
    -- UILayout.SetAnchorAndPivot(BePresentNum1, UIAnchor.Center, UIAroundPivot.Center)
    -- GUI.SetColor(BePresentNum1, colorWhite)
    -- GUI.StaticSetFontSize(BePresentNum1, 22)
    -- GUI.StaticSetAlignment(BePresentNum1, TextAnchor.MiddleCenter)
    -- _gt.BindName(BePresentNum1, "BePresentNum1")

    local IntegralTotalText1 = GUI.CreateStatic(LeftPanel, "IntegralTotalText1", uiName or "积分塔排行榜", 0, -180, 280, 30,
        "100")
    UILayout.SetAnchorAndPivot(IntegralTotalText1, UIAnchor.Center, UIAroundPivot.Center)
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

    -- local IntegralTotal1 = GUI.CreateStatic(LeftPanel, "IntegralTotal1", "0", 260, -180, 280, 30, "system")
    -- UILayout.SetAnchorAndPivot(IntegralTotal1, UIAnchor.Center, UIAroundPivot.Center)
    -- GUI.SetColor(IntegralTotal1, colorWhite)
    -- GUI.StaticSetFontSize(IntegralTotal1, 22)
    -- GUI.StaticSetAlignment(IntegralTotal1, TextAnchor.MiddleCenter)
    -- _gt.BindName(IntegralTotal1, "IntegralTotal1")

    local WinImg = GUI.ImageCreate(LeftPanel, "WinImg", "1800604280", 30, -190, true)
    UILayout.SetAnchorAndPivot(WinImg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(WinImg, "WinImg")
    GUI.SetVisible(WinImg, false)

    local RankSpTitle1 = GUI.CreateStatic(LeftPanel, "RankSpTitle1", "排名", -240, -130, 280, 30, "system")
    UILayout.SetAnchorAndPivot(RankSpTitle1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(RankSpTitle1, showColor)
    GUI.StaticSetFontSize(RankSpTitle1, 22)
    GUI.StaticSetAlignment(RankSpTitle1, TextAnchor.MiddleCenter)

    local PlayerNameTitle1 = GUI.CreateStatic(LeftPanel, "PlayerNameTitle1", "角色名", -125, -130, 280, 30,
        "system")
    UILayout.SetAnchorAndPivot(PlayerNameTitle1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(PlayerNameTitle1, showColor)
    GUI.StaticSetFontSize(PlayerNameTitle1, 22)
    GUI.StaticSetAlignment(PlayerNameTitle1, TextAnchor.MiddleCenter)

    local OfficialRankTitle1 = GUI.CreateStatic(LeftPanel, "OfficialRankTitle1", "阵营", 0, -130, 280, 30, "system")
    UILayout.SetAnchorAndPivot(OfficialRankTitle1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(OfficialRankTitle1, showColor)
    GUI.StaticSetFontSize(OfficialRankTitle1, 22)
    GUI.StaticSetAlignment(OfficialRankTitle1, TextAnchor.MiddleCenter)

    local IntegralTitle1 = GUI.CreateStatic(LeftPanel, "IntegralTitle1", "积分", 120, -130, 280, 30, "system")
    UILayout.SetAnchorAndPivot(IntegralTitle1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(IntegralTitle1, showColor)
    GUI.StaticSetFontSize(IntegralTitle1, 22)
    GUI.StaticSetAlignment(IntegralTitle1, TextAnchor.MiddleCenter)

    local WinRateTitle1 = GUI.CreateStatic(LeftPanel, "WinRateTitle1", "层数", 240, -130, 280, 30, "system")
    UILayout.SetAnchorAndPivot(WinRateTitle1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(WinRateTitle1, showColor)
    GUI.StaticSetFontSize(WinRateTitle1, 22)
    GUI.StaticSetAlignment(WinRateTitle1, TextAnchor.MiddleCenter)

    local array = {RankSpTitle1,PlayerNameTitle1,OfficialRankTitle1,IntegralTitle1,WinRateTitle1}
    -- local c =  Color.New(182/255,52/255,40/255,255/255)
    for _,v in pairs(array) do
            --设置描边
	    -- GUI.SetIsOutLine(v,true)
	    -- GUI.SetOutLine_Distance(v,1)
	    -- GUI.SetOutLine_Color(v,c)
        	--设置阴影
	GUI.SetIsShadow(v,true)
	GUI.SetShadow_Distance(v,Vector2.New(0,-1))
	GUI.SetShadow_Color(v,UIDefine.BlackColor)
    end

    local PlayerCurrentRank1 = GUI.ImageCreate(LeftPanel, "PlayerCurrentRank1", "1800600250", 0, -10, false, 639, 43)
    UILayout.SetAnchorAndPivot(PlayerCurrentRank1, UIAnchor.Bottom, UIAroundPivot.Bottom)
    _gt.BindName(PlayerCurrentRank1, "PlayerCurrentRank1")
    GUI.SetVisible(PlayerCurrentRank1, true)

    local PlayerCurrentRank1_Sp = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Sp", "1", -240, 1, 280, 30,
        "system")
    UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Sp, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(PlayerCurrentRank1_Sp, colorDark)
    GUI.StaticSetFontSize(PlayerCurrentRank1_Sp, 22)
    GUI.StaticSetAlignment(PlayerCurrentRank1_Sp, TextAnchor.MiddleCenter)

    local PlayerCurrentRank1_Name = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Name", "我是谁", -130,
        1, 280, 30, "system")
    UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Name, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(PlayerCurrentRank1_Name, colorDark)
    GUI.StaticSetFontSize(PlayerCurrentRank1_Name, 22)
    GUI.StaticSetAlignment(PlayerCurrentRank1_Name, TextAnchor.MiddleCenter)

    local PlayerCurrentRank1_Pos = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Pos", "无名小吏", 0, 1,
        280, 30, "system")
    UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Pos, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(PlayerCurrentRank1_Pos, colorDark)
    GUI.StaticSetFontSize(PlayerCurrentRank1_Pos, 22)
    GUI.StaticSetAlignment(PlayerCurrentRank1_Pos, TextAnchor.MiddleCenter)

    local PlayerCurrentRank1_Integral = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Integral", "0", 120, 1,
        280, 30, "system")
    UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Integral, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(PlayerCurrentRank1_Integral, colorDark)
    GUI.StaticSetFontSize(PlayerCurrentRank1_Integral, 22)
    GUI.StaticSetAlignment(PlayerCurrentRank1_Integral, TextAnchor.MiddleCenter)

    local PlayerCurrentRank1_Rate = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Rate", "100%", 240, 1, 280,
        30, "system")
    UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Rate, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(PlayerCurrentRank1_Rate, colorDark)
    GUI.StaticSetFontSize(PlayerCurrentRank1_Rate, 22)
    GUI.StaticSetAlignment(PlayerCurrentRank1_Rate, TextAnchor.MiddleCenter)

    -- 朱雀阵营排行榜
    local ZhuQueRankScroll = GUI.LoopScrollRectCreate(LeftPanel, "ZhuQueRankScroll", 0, 28, 640, 260,
        "SevenTierClimbTowerIntegralUI", "CreateZhuQueRankItem", "SevenTierClimbTowerIntegralUI",
        "RefreshZhuQueRankScroll", 0, false, Vector2.New(660, 42), 1, UIAroundPivot.Top, UIAnchor.Top);
    UILayout.SetAnchorAndPivot(ZhuQueRankScroll, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(ZhuQueRankScroll, "ZhuQueRankScroll")
end

function SevenTierClimbTowerIntegralUI.CreateZhuQueRankItem()
    local ZhuQueRankScroll = _gt.GetUI("ZhuQueRankScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(ZhuQueRankScroll) + 1;
    local ZhuQueRankItem = GUI.ItemCtrlCreate(ZhuQueRankScroll, "ZhuQueRankItem" .. curCount, "1800600640", 0, 0, 660,
        42)
    local ZhuQue_Sp = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Sp", "2", -240, 1, 150, 50, "system")
    UILayout.SetAnchorAndPivot(ZhuQue_Sp, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Sp, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Sp, 24)
    GUI.StaticSetAlignment(ZhuQue_Sp, TextAnchor.MiddleCenter)
    local ZhuQue_Name = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Name", "我啊啊", -130, 1, 150, 50, "system")
    UILayout.SetAnchorAndPivot(ZhuQue_Name, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Name, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Name, 24)
    GUI.StaticSetAlignment(ZhuQue_Name, TextAnchor.MiddleCenter)
    local ZhuQue_Officer = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Officer", "无名小吏", 0, 1, 150, 50, "system")
    UILayout.SetAnchorAndPivot(ZhuQue_Officer, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Officer, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Officer, 24)
    GUI.StaticSetAlignment(ZhuQue_Officer, TextAnchor.MiddleCenter)
    local ZhuQue_Score = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Score", "2", 120, 1, 150, 50, "system")
    UILayout.SetAnchorAndPivot(ZhuQue_Score, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Score, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Score, 24)
    GUI.StaticSetAlignment(ZhuQue_Score, TextAnchor.MiddleCenter)
    local ZhuQue_Rate = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Rate", "99%", 240, 1, 150, 50, "system")
    UILayout.SetAnchorAndPivot(ZhuQue_Rate, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(ZhuQue_Rate, colorWhite)
    GUI.StaticSetFontSize(ZhuQue_Rate, 24)
    GUI.StaticSetAlignment(ZhuQue_Rate, TextAnchor.MiddleCenter)

    local OffLine1 = GUI.ImageCreate(ZhuQueRankItem, "OffLine1", "1800604360", -280, 0, false,30,30)
    UILayout.SetAnchorAndPivot(OffLine1, UIAnchor.Center, UIAroundPivot.Center)

    return ZhuQueRankItem;
end



function SevenTierClimbTowerIntegralUI.RefreshZhuQueRankScroll(parameter)

    if SevenTierClimbTowerIntegralUI.needData == nil then
        test("function SevenTierClimbTowerIntegralUI.RefreshZhuQueRankScroll(parameter) needData is null")
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

    local data = SevenTierClimbTowerIntegralUI.needData[index]
    if data == nil then
        test("function SevenTierClimbTowerIntegralUI.RefreshZhuQueRankScroll(parameter) data is null, out bounds error ")
        return
    end

    GUI.StaticSetText(Name, data.name)
    GUI.StaticSetText(Officer, data.camp)
    GUI.StaticSetText(Score, data.integral)
    GUI.StaticSetText(Rate, data.tier)

end

function SevenTierClimbTowerIntegralUI.refresh()
    -- 每次都会刷新两次，减少一次刷新次数
    if SevenTierClimbTowerIntegralUI.isSecond == nil then
        SevenTierClimbTowerIntegralUI.isSecond = true
        return 
    else
        SevenTierClimbTowerIntegralUI.isSecond = nil
    end

    local id = TrackUI.integralTowerRankID
    local rankData = LD.GetRankData(id)

    -- 如果存在服务器发来的阵容数据
    if TrackUI.integralTowerCampName then
        camplist = TrackUI.integralTowerCampName
        camplist[0] = "未分配"
    end

    SevenTierClimbTowerIntegralUI.needData={}
    if rankData then
        local c = tonumber(tostring(rankData.Count))
    
        for i=0,c-1 do
            local d = rankData[i]
            local s = string.split(d.rank_info,'_')
            
            local camp = s[1]
            local tier = s[2]
            tier = string.sub(tier,10,12)
            local nd = {
                ranking = d.rank,
                name = d.name,
                camp = camplist[tonumber(camp)],
                integral = tonumber(tostring(d.rank_data1)),
                tier = tier
            }
            table.insert(SevenTierClimbTowerIntegralUI.needData,nd)
        end
    end


    SevenTierClimbTowerIntegralUI.selfInfo={}
    local selfRankData = LD.GetSelfRankData(id)
    local nd = {ranking = "未上榜"}
    if selfRankData and selfRankData.name~="" then
        local s  =string.split(selfRankData.rank_info,'_')
        local camp=s[1]
        local tier=s[2]
        tier = string.sub(tier,10,12)
        nd = {
            ranking = tonumber(tostring(selfRankData.rank)),
            name = selfRankData.name,
            camp=camplist[tonumber(camp)],
            integral=tonumber(tostring(selfRankData.rank_data1)),
            tier=tier,
        }
    else
        nd = {
            ranking = "未上榜",
            name = "",
            camp = "",
            integral = "",
            tier = ""
        }
    end
    SevenTierClimbTowerIntegralUI.selfInfo = nd


    if SevenTierClimbTowerIntegralUI.selfInfo == nil then
        test("function SevenTierClimbTowerIntegralUI.refresh() selfInfo is null")
        return
    end
    local data = SevenTierClimbTowerIntegralUI.selfInfo
    local PlayerCurrentRank1 = _gt.GetUI("PlayerCurrentRank1")

    local Sp = GUI.GetChild(PlayerCurrentRank1, "PlayerCurrentRank1_Sp")
    local Name = GUI.GetChild(PlayerCurrentRank1, "PlayerCurrentRank1_Name")
    local Pos = GUI.GetChild(PlayerCurrentRank1, "PlayerCurrentRank1_Pos")
    local Integral = GUI.GetChild(PlayerCurrentRank1, "PlayerCurrentRank1_Integral")
    local Rate = GUI.GetChild(PlayerCurrentRank1, "PlayerCurrentRank1_Rate")

    GUI.StaticSetText(Sp, data.ranking)
    GUI.StaticSetText(Name, data.name)
    GUI.StaticSetText(Pos, data.camp)
    GUI.StaticSetText(Integral, data.integral)
    GUI.StaticSetText(Rate, data.tier)

    local ZhuQueRankScroll = _gt.GetUI("ZhuQueRankScroll")
    GUI.LoopScrollRectSetTotalCount(ZhuQueRankScroll, #SevenTierClimbTowerIntegralUI.needData)
    GUI.LoopScrollRectRefreshCells(ZhuQueRankScroll)
end


function SevenTierClimbTowerIntegralUI.createRoleModel(parent,x,y,roleId)
    if parent == nil then
        test("SevenTierClimbTowerIntegralUI.createRoleModel(parent) parent is null")
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
            UILayout.SetAnchorAndPivot(_RoleNodeModel, UIAnchor.Center, UIAroundPivot.Center)
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
            UILayout.SetSameAnchorAndPivot(_roleModel, UILayout.Center)
            GUI.RawImageChildSetModleRotation(_roleModel, Vector3.New(0,180,0))
        end

    end
end

SevenTierClimbTowerIntegralUI.needData = {{
    ranking = 1,
    name = "张三",
    camp = 1,
    integral = 10,
    tier = 10
}, {
    ranking = 1,
    name = "a三",
    camp = 1,
    integral = 10,
    tier = 10
}, {
    ranking = 1,
    name = "b三",
    camp = 1,
    integral = 10,
    tier = 10
}, }
SevenTierClimbTowerIntegralUI.selfInfo = {
    ranking = 1,
    name = "老六",
    camp = 1,
    integral = 10,
    tier = 10
}
function SevenTierClimbTowerIntegralUI.request()
    -- SevenTierClimbTowerIntegralUI.response()
    -- TrackUI.integralTowerRankID 排行榜id
    -- TrackUI.integralTowerCampName 阵营列表
    
    local id = TrackUI.integralTowerRankID

    -- 清空缓存数据，然后重新请求
    CL.SendNotify(NOTIFY.RankOpe, 3, id)
    CL.SendNotify(NOTIFY.RankOpe, 1, id, showRankNum or 50)

    CL.SendNotify(NOTIFY.RankOpe, 2, id)
end

function SevenTierClimbTowerIntegralUI.response()

    SevenTierClimbTowerIntegralUI.refresh()

end


