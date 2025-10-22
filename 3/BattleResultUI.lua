BattleResultUI={}
local _gt = UILayout.NewGUIDUtilTable()

local REQ_ONE_PAGE_COUNT = 200
BattleResultUI.TankType0 = 0
BattleResultUI.TankType1 = 0
BattleResultUI.EndTimer = nil
BattleResultUI.EndTimeTxt = nil

function BattleResultUI.Main( parameter )
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("BattleResultUI" , "BattleResultUI" , 0 , 0)
    local panelCover = GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)

    local panelBg = GUI.GroupCreate(panel, "panelBg", 0, 33, 1197, 660)
    UILayout.SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)

    local middle = GUI.ImageCreate(panelBg, "middle","1800608420",0,-260)
    UILayout.SetSameAnchorAndPivot(middle, UILayout.Center)
    local pic = GUI.ImageCreate(middle, "pic","1800608080",-320,272)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local pic = GUI.ImageCreate(middle, "pic","1800608090",320,272)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local pic = GUI.ImageCreate(middle, "pic","1800608060",-54,32)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local pic = GUI.ImageCreate(middle, "pic","1800608070",54,32)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local pic = GUI.ImageCreate(middle, "pic","1800608010",0,65)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local pic = GUI.ImageCreate(middle, "pic","1800608020",-166,55, false, 290, 20)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    _gt.BindName(pic, "LeftHP")
    GUI.ImageSetType(pic, SpriteType.Filled);
    GUI.SetImageFillMethod(pic, SpriteFillMethod.Horizontal_Right)
    local pic = GUI.ImageCreate(middle, "pic","1800608020",166,55, false, 290, 20)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    _gt.BindName(pic, "RightHP")
    GUI.ImageSetType(pic, SpriteType.Filled);
    GUI.SetImageFillMethod(pic, SpriteFillMethod.Horizontal_Left)
    local pic = GUI.ImageCreate(middle, "pic","1900100370",-2,63, false, 104, 104)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local pic = GUI.ImageCreate(middle, "pic","1801401130",0,464, false, 480, 34)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local pic = GUI.ImageCreate(middle, "pic","1800600620",-320,305,false, 640, 296)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local pic = GUI.ImageCreate(middle, "pic","1800600620",320,305,false, 640, 296)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local txt = GUI.CreateStatic(middle,"txt", "朱雀", -66, 32,100,30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    local txt = GUI.CreateStatic(middle,"txt", "青龙", 66, 32,100,30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    local name = {tostring(TrackUI.FactionName1),"帮战积分",tostring(TrackUI.Team1Score),tostring(TrackUI.FactionName2),"帮战积分",tostring(TrackUI.Team2Score),"排名","玩家名称","战场积分","对抗积分","排名","玩家名称","战场积分","对抗战绩"}
    local color = {UIDefine.WhiteColor,UIDefine.WhiteColor,UIDefine.WhiteColor,UIDefine.WhiteColor,UIDefine.WhiteColor,UIDefine.WhiteColor,UIDefine.OrangeColor,UIDefine.OrangeColor,UIDefine.OrangeColor,UIDefine.OrangeColor,UIDefine.Blue4Color,UIDefine.Blue4Color,UIDefine.Blue4Color,UIDefine.Blue4Color}
    local posX = {-517,-260,-57,466,230,57,-548,-411,-252,-93,95,227,385,546}
    local posY = {94,94,94,94,94,94,138,138,138,138,138,138,138,138}
    local count = #name
    for i = 1, count do
        local txt = GUI.CreateStatic(middle,"txt"..i, name[i], posX[i], posY[i],200,30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, color[i], TextAnchor.MiddleCenter)
    end

    local txt = GUI.CreateStatic(middle,"time", "距离 帮战结束 还有 00:01", 0, 464,400,30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSS, UIDefine.YellowStdColor, TextAnchor.MiddleCenter)
    BattleResultUI.EndTimeTxt = txt

    local rankScrollLeft = GUI.LoopScrollRectCreate(middle,"rankScrollLeft", -320, 306, 640, 290,
            "BattleResultUI","CreatRankItemPoolLeft","BattleResultUI","RefreshRankLeftScroll", 0, false, Vector2.New(640, 35), 1,UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(rankScrollLeft, Vector2.New(0, 10))
    _gt.BindName(rankScrollLeft, "rankScrollLeft")
    local rankScrollRight = GUI.LoopScrollRectCreate(middle,"rankScrollRight", 320, 306, 640, 290,
            "BattleResultUI","CreatRankItemPoolRight","BattleResultUI","RefreshRankRightScroll", 0, false, Vector2.New(640, 35), 1,UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(rankScrollRight, Vector2.New(0, 10))
    _gt.BindName(rankScrollRight, "rankScrollRight")

    local retPos = {-384,384}
    for i = 1, 2 do
        local pic = GUI.ImageCreate(middle, "pic","1800604270",retPos[i],56)
        UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
        _gt.BindName(pic, "loseFlag"..i)
        GUI.SetVisible(pic, false)
        local pic = GUI.ImageCreate(middle, "pic","1800604280",retPos[i],56)
        UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
        _gt.BindName(pic, "winFlag"..i)
        GUI.SetVisible(pic, false)
    end

    local CloseBtn = GUI.ButtonCreate(panelBg,"CloseBtn", "1800602110", 590, -166, Transition.ColorTint)
    UILayout.SetAnchorAndPivot(CloseBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(CloseBtn, UCE.PointerClick, "BattleResultUI", "OnExit")

    CL.RegisterMessage(GM.RankDateUpdate, "BattleResultUI", "OnRankDateUpdate")
end

function BattleResultUI.OnShow(parameter)
    if GUI.GetWnd("BattleResultUI") == nil then
        return
    end

    --尝试清空上一次的数据：到点才清除
    LD.ClearRankData()
    CL.SendNotify(NOTIFY.SubmitForm, "FormActivity", "GuildBattle_GetPanelInfo")
end

function BattleResultUI.RefreshData()
    --分别请求榜单数据
    BattleResultUI.TankType0 = BattleResultUI.RankRed
    BattleResultUI.TankType1 = BattleResultUI.RankBlue
    CL.SendNotify(NOTIFY.RankOpe, 1, BattleResultUI.TankType0, REQ_ONE_PAGE_COUNT)
    CL.SendNotify(NOTIFY.RankOpe, 1, BattleResultUI.TankType1, REQ_ONE_PAGE_COUNT)

    BattleResultUI.EndTimer = Timer.New(BattleResultUI.OnEndTimer, 1, -1)
    BattleResultUI.EndTimer:Start()

    --胜负标记
    local loseFlag = _gt.GetUI("loseFlag1")
    if loseFlag then
        GUI.SetVisible(loseFlag, BattleResultUI.Winner==2)
    end
    local loseFlag = _gt.GetUI("loseFlag2")
    if loseFlag then
        GUI.SetVisible(loseFlag, BattleResultUI.Winner==1)
    end
    local winFlag = _gt.GetUI("winFlag1")
    if winFlag then
        GUI.SetVisible(winFlag, BattleResultUI.Winner==1)
    end
    local winFlag = _gt.GetUI("winFlag2")
    if winFlag then
        GUI.SetVisible(winFlag, BattleResultUI.Winner==2)
    end

    --血量
    local LeftHP = _gt.GetUI("LeftHP")
    if LeftHP then
        GUI.SetImageFillAmount(LeftHP, TrackUI.Team1HP/10000)
    end
    local RightHP = _gt.GetUI("RightHP")
    if RightHP then
        GUI.SetImageFillAmount(RightHP, TrackUI.Team2HP/10000)
    end
end

function BattleResultUI.OnEndTimer()
    if TrackUI.TimePoint == 0 or TrackUI.TimePoint == nil then
        GUI.StaticSetText(BattleResultUI.EndTimeTxt, tostring(BattleResultUI.TimeDesc))
    else
        local str, day, hour, minute, second = UIDefine.LeftTimeFormatEx(TrackUI.TimePoint)
        GUI.StaticSetText(BattleResultUI.EndTimeTxt, string.format( tostring(BattleResultUI.TimeDesc).." %02d:%02d", minute, second ))
    end
end

function BattleResultUI.OnDestroy()
    CL.UnRegisterMessage(GM.RankDateUpdate, "BattleResultUI", "OnRankDateUpdate")
end

function BattleResultUI.OnRankDateUpdate(type, rankType)
    print("-------------------- 收到 数据："..tostring(type)..", "..tostring(rankType))
    if type == 1 then
        if rankType == BattleResultUI.TankType0 then
            local rankScrollLeft = _gt.GetUI("rankScrollLeft")
            local count = LD.GetRankTotalCount(rankType)
            GUI.LoopScrollRectSetTotalCount(rankScrollLeft, count+1)
            GUI.LoopScrollRectSetTotalCount(rankScrollLeft, count)
        elseif rankType == BattleResultUI.TankType1 then
            local rankScrollRight = _gt.GetUI("rankScrollRight")
            local count = LD.GetRankTotalCount(rankType)
            GUI.LoopScrollRectSetTotalCount(rankScrollRight, count+1)
            GUI.LoopScrollRectSetTotalCount(rankScrollRight, count)
        end
    end
end

function BattleResultUI.CreatRankItemPoolLeft()
    local rankScrollLeft = _gt.GetUI("rankScrollLeft")
    return BattleResultUI.CreatRankItemPool(rankScrollLeft, UIDefine.OrangeColor)
end

function BattleResultUI.CreatRankItemPoolRight()
    local rankScrollRight = _gt.GetUI("rankScrollRight")
    return BattleResultUI.CreatRankItemPool(rankScrollRight, UIDefine.Blue4Color)
end

function BattleResultUI.CreatRankItemPool(rankScroll,color)
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(rankScroll)
    local bg = GUI.ImageCreate( rankScroll,"bg" .. curCount, "1800499999", 0, 0, false, 600, 35)
    GUI.ImageCreate( bg,"line", "1800607100", 0, 26, false, 600, 2)

    --名称
    local index = GUI.CreateStatic( bg,"index", tostring(curCount), -228, 0, 80, 35)
    UILayout.SetSameAnchorAndPivot(index, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(index, UIDefine.FontSizeM, color, TextAnchor.MiddleCenter)

    --名称
    local txt = GUI.CreateStatic( bg,"name", "玩家名称六字", -89, 0, 200, 35)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, color, TextAnchor.MiddleCenter)

    --分数
    local txt = GUI.CreateStatic( bg,"score0", "89998"..curCount, 66, 0, 180, 35)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, color, TextAnchor.MiddleCenter)

    --分数
    local txt = GUI.CreateStatic( bg,"score1", "112798"..curCount, 225, 0, 180, 35)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, color, TextAnchor.MiddleCenter)

    return bg
end

function BattleResultUI.RefreshRankLeftScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local datas = LD.GetRankData(BattleResultUI.TankType0)
    BattleResultUI.RefreshRankScroll(guid, index, datas)
end

function BattleResultUI.RefreshRankRightScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local datas = LD.GetRankData(BattleResultUI.TankType1)
    BattleResultUI.RefreshRankScroll(guid, index, datas)
end

function BattleResultUI.RefreshRankScroll(guid, index, datas)
    if datas ~= nil and index < datas.Count then
        print("--------------index :"..tostring(index)..", datas.Count:"..tostring(datas.Count))
        local bg = GUI.GetByGuid(guid)
        local indexItem = GUI.GetChild(bg, "index")
        if indexItem then
            GUI.StaticSetText(indexItem, tostring(datas[index].rank))
        end

        local name = GUI.GetChild(bg, "name")
        if name then
            GUI.StaticSetText(name, datas[index].name)
        end

        local score0 = GUI.GetChild(bg, "score0")
        if score0 then
            GUI.StaticSetText(score0, tostring(datas[index].rank_data1))
        end

        local score1 = GUI.GetChild(bg, "score1")
        if score1 then
            GUI.StaticSetText(score1, tostring(datas[index].rank_info))
        end
    end
end

--退出界面
function BattleResultUI.OnExit()
    if BattleResultUI.EndTimer then
        BattleResultUI.EndTimer:Stop()
        BattleResultUI.EndTimer = nil
    end
    GUI.DestroyWnd("BattleResultUI")
end