EndlessTrialsUI = {}
EndlessTrialsUI.FormShiLianData = {}
local _gt = UILayout.NewGUIDUtilTable()
local itemIconBg = UIDefine.ItemIconBg;
EndlessTrialsUI.Choice = 1
EndlessTrialsUI.DifficutyIndex = 1
local JISHU = nil
local Now_choice = nil

function EndlessTrialsUI.Main()

    _gt = UILayout.NewGUIDUtilTable()
    test("EndlessTrialsUI.Main")
--创建窗口
    local wnd = GUI.WndCreateWnd("EndlessTrialsUI", "EndlessTrialsUI", 0, 0)
    local background = UILayout.CreateFrame_WndStyle0(wnd, "无尽的试炼", "EndlessTrialsUI", "OnExit", _gt)

    local board = GUI.ImageCreate(background,"board","1801401110",60,7,false,305,570)
    _gt.BindName (board,"board")
    UILayout.SetSameAnchorAndPivot(board, UILayout.Left)

    local boardR = GUI.ImageCreate(background,"boardR","1801100180",150,10,false,750,560)
    _gt.BindName(boardR,"boardR")
    UILayout.SetSameAnchorAndPivot(boardR, UILayout.Center)
--活动背包
    local BagpackBoard = GUI.ImageCreate(board,"BagpackBoard","1800400010",0,-10,false,275,205)
    UILayout.SetSameAnchorAndPivot(BagpackBoard, UILayout.Center)
    local txt = GUI.CreateStatic(BagpackBoard, "txt","随行包裹",0, 0, 104, 45)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Top)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)

    local Bagpack = GUI.LoopScrollRectCreate(BagpackBoard,"Bakpack",8,40,280,155,"EndlessTrialsUI", "CreateItemIconPool",
       "EndlessTrialsUI", "RefreshItemScroll", 0, false, Vector2.New(64, 64), 4, UIAroundPivot.TopLeft, UIAnchor.TopLeft)

    GUI.ScrollRectSetChildSpacing(Bagpack, Vector2.New(1, 1));

    UILayout.SetAnchorAndPivot(Bagpack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    _gt.BindName(Bagpack,"Bagpack")

    GUI.LoopScrollRectSetTotalCount(Bagpack, 16)

    --活动技能
    local Skill = GUI.ButtonCreate(board,"Skill","1800202090",175,145,Transition.ColorTint,"",75,75,false)
    _gt.BindName(Skill,"SkillBtn")
    local txt = GUI.CreateStatic(Skill, "txt","技能",35, 30, 104, 45)
    GUI.SetOutLine_Color(txt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(txt, 1)
    GUI.SetIsOutLine(txt, true)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, nil)
    GUI.RegisterUIEvent(Skill, UCE.PointerClick, "EndlessTrialsUI", "OnSkillBtnClick")

    --活动buff
    local Buff = GUI.ButtonCreate(board,"buff","1800202490",-50,145,Transition.ColorTint,"",75,75,false)
    _gt.BindName(Buff,"BuffBtn")
    UILayout.SetSameAnchorAndPivot(Buff, UILayout.Center)
    local txt = GUI.CreateStatic(Buff, "txt","护身符",20, 30, 104, 45)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, nil)
    GUI.SetOutLine_Color(txt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(txt, 1)
    GUI.SetIsOutLine(txt, true)
    GUI.RegisterUIEvent(Buff, UCE.PointerClick, "EndlessTrialsUI", "OnBuffBtnClick")

    --试炼进度条
    local txt = GUI.CreateStatic(board, "txt","试炼进度",0,-165, 104, 45)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

    local Speed_Slider = GUI.ScrollBarCreate(board, "Speed_Slider", "", "1800408160", "1800408110", 30, -140, 245,25, 0, false, Transition.None, 0, 1)
    _gt.BindName(Speed_Slider,"Speed_SliderBar")
    GUI.ScrollBarSetBgSize(Speed_Slider, Vector2.New(150, 24))
    GUI.ScrollBarSetHandlePivot(Speed_Slider, UIAroundPivot.Right)
    UILayout.SetSameAnchorAndPivot(Speed_Slider, UILayout.Left)
    GUI.ScrollBarSetPos(Speed_Slider, 0.1)

    local txt = GUI.CreateStatic(Speed_Slider, "txt", "1/10", 0, 0, 150, 35)
    _gt.BindName(txt,"Speed_SliderTxt")
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
--难度选择
    local DifficultyTxt = GUI.CreateStatic(board, "DifficultyTxt","初入西游", 0, 50, 104, 45)
    _gt.BindName(DifficultyTxt,"Difficulty_txt")
    UILayout.SetSameAnchorAndPivot(DifficultyTxt, UILayout.Top)
    UILayout.StaticSetFontSizeColorAlignment(DifficultyTxt, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
    --信息玩法介绍

    local Message = GUI.ButtonCreate(board,"Message","1800702030",30,55,Transition.ColorTint,"",40,40,false)
    _gt.BindName(Message,"Message")
    UILayout.SetSameAnchorAndPivot(Message, UILayout.TopLeft)
    GUI.RegisterUIEvent(Message, UCE.PointerClick, "EndlessTrialsUI", "OnMessageBtnClick")

    --活动货币
    local coinBg = GUI.ImageCreate(board, "coinBg", "1800700010", 0, -40, false, 180, 36)
    _gt.BindName(coinBg,"coinBg")
    UILayout.SetSameAnchorAndPivot(coinBg, UILayout.Bottom)
    local coinpt = GUI.ButtonCreate(coinBg, "coinpt", "1900910120", 0, 0, Transition.ColorTint,"", 50, 50,false)
    GUI.RegisterUIEvent(coinpt, UCE.PointerClick, "EndlessTrialsUI", "OnCoinBtnClick")
    UILayout.SetSameAnchorAndPivot(coinpt, UILayout.Left)
    local txt = GUI.CreateStatic(coinBg, "txt","1000",0, 0, 180, 45)
    _gt.BindName(txt,"coinTxt")
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

    local leftNarrow = GUI.ImageCreate(boardR, "leftNarrow", "1800800050", -250, 55)
    UILayout.SetSameAnchorAndPivot(leftNarrow, UILayout.Top)
    local rightNarrow = GUI.ImageCreate(boardR, "rightNarrow", "1800800060", 250,55)
    UILayout.SetSameAnchorAndPivot(rightNarrow, UILayout.Top)
    --事件交互
    local Title = GUI.CreateStatic(boardR, "Title","ShiLianData.Title",0, -220, 150, 45)
    _gt.BindName(Title,"TitleTxt")
    UILayout.SetSameAnchorAndPivot(Title, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(Title, UIDefine.FontSizeXXL, UIDefine.Brown5Color, TextAnchor.MiddleCenter)

    local Msg = GUI.CreateStatic(boardR, "Msg","massage",0, -170, 700, 300)
    _gt.BindName(Msg,"MsgTxt")
    UILayout.SetSameAnchorAndPivot(Msg, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(Msg, UIDefine.FontSizeL, UIDefine.Brown5Color,TextAnchor.MiddleCenter)

    local Choice_List = GUI.LoopScrollRectCreate(boardR,"Choice_List", 0 , 0 , 700 , 250 ,
            "EndlessTrialsUI" , "CreateChoice_List" ,
            "EndlessTrialsUI", "RefreshChoice_List" ,
            0,true ,Vector2.New(170, 230),1,UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(Choice_List, Vector2.New(30, 0))
    _gt.BindName(Choice_List, "Choice_List")

    local info = GUI.ScrollListCreate(boardR,"info",0,150,670,80,false,UIAroundPivot.Top,UIAnchor.Top,false)
    local Info_Txt = GUI.CreateStatic(info,"info_Txt","ShiLianData.Info",0, 150, 670,150,"system",true)
    UILayout.SetSameAnchorAndPivot(Info_Txt, UILayout.Top)
    UILayout.StaticSetFontSizeColorAlignment(Info_Txt, UIDefine.FontSizeL, UIDefine.Brown5Color, TextAnchor.UpperCenter)

    local Button1 = GUI.ButtonCreate(boardR,"choice1","1800002060",-220,225,Transition.ColorTint,"1",165,48,false)
    GUI.RegisterUIEvent(Button1, UCE.PointerClick, "EndlessTrialsUI", "OnChoiceBtnClick")
    GUI.SetData(Button1,"Number",1)
    UILayout.SetSameAnchorAndPivot(Button1, UILayout.Center)
    GUI.ButtonSetTextFontSize(Button1, UIDefine.FontSizeXXL)
    GUI.ButtonSetTextColor(Button1, UIDefine.WhiteColor)
    local Button2 = GUI.ButtonCreate(boardR,"choice2","1800002060",0,225,Transition.ColorTint,"2",165,48,false)
    GUI.RegisterUIEvent(Button2, UCE.PointerClick, "EndlessTrialsUI", "OnChoiceBtnClick")
    GUI.SetData(Button2,"Number",2)
    UILayout.SetSameAnchorAndPivot(Button2, UILayout.Center)
    GUI.ButtonSetTextFontSize(Button2, UIDefine.FontSizeXXL)
    GUI.ButtonSetTextColor(Button2, UIDefine.WhiteColor)
    local Button3 = GUI.ButtonCreate(boardR,"choice3","1800002060",220,225,Transition.ColorTint,"3",165,48,false)
    GUI.RegisterUIEvent(Button3, UCE.PointerClick, "EndlessTrialsUI", "OnChoiceBtnClick")
    GUI.SetData(Button3,"Number",3)
    UILayout.SetSameAnchorAndPivot(Button3, UILayout.Center)
    GUI.ButtonSetTextFontSize(Button3, UIDefine.FontSizeXXL)
    GUI.ButtonSetTextColor(Button3, UIDefine.WhiteColor)
end
--创建选项
function EndlessTrialsUI.CreateChoice_List()
    local sellScroll =  _gt.GetUI("Choice_List")
    local Count = GUI.LoopScrollRectGetChildInPoolCount(sellScroll)

    local bg = GUI.ButtonCreate(sellScroll,"bg"..Count,"1800601020",0,120,Transition.ColorTint,"",170,230,false)
    GUI.DelData(bg,"index")
    GUI.SetData(bg,"index",Count + 1)
    GUI.RegisterUIEvent(bg, UCE.PointerClick, "EndlessTrialsUI", "OnbgBtnClick")
    local txt = GUI.CreateStatic(bg, "txt","name",0, -85, 160, 45)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.Brown3Color, TextAnchor.MiddleCenter)
    local picBg = GUI.ImageCreate(bg,"picBg",itemIconBg[1],0,20,false,140,140)
    UILayout.SetSameAnchorAndPivot(picBg, UILayout.Center)
    local pic = GUI.ImageCreate(picBg,"pic","1800400280",0,-2,false,125,125)
    UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
    local ChoiceFrame = GUI.ImageCreate(picBg,"ChoiceFrame","1800400280",0,0,false,160,160)
    GUI.SetVisible(ChoiceFrame,false)
    local finish = GUI.ImageCreate(bg,"finish","1800608300",0,30,false,160,120)
    _gt.BindName(finish,"finish"..Count)
    GUI.SetVisible(finish,false)
    return bg
end

--刷新选项
function EndlessTrialsUI.RefreshChoice_List(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1

    local bg = GUI.GetByGuid(guid)
    local txt = GUI.GetChild(bg,"txt")
    local picBg = GUI.GetChild(bg,"picBg")
    local pic = GUI.GetChild(picBg,"pic")
    local ChoiceFrame = GUI.GetChild(picBg,"ChoiceFrame")
    _gt.BindName(ChoiceFrame,"ChoiceFrame"..index)
    GUI.SetData(bg,"index",index)
    GUI.SetVisible(ChoiceFrame,false)
    if index == EndlessTrialsUI.FormShiLianData.SelectOptionIndex then
        GUI.SetVisible(ChoiceFrame,true)
    end

    GUI.StaticSetText(txt,EndlessTrialsUI.FormShiLianData.Event[index].Name)
    GUI.ImageSetImageID(picBg,itemIconBg[EndlessTrialsUI.FormShiLianData.Event[index].Grade])
    GUI.ImageSetImageID(pic,EndlessTrialsUI.FormShiLianData.Event[index].Icon)
end


--玩法介绍按钮
function EndlessTrialsUI.OnMessageBtnClick()
    local Message = _gt.GetUI("boardR")
    local tip = Tips.CreateHint(EndlessTrialsUI.FormShiLianData.Tips, Message,-350, 20, UILayout.Top, 520, nil, true)
    GUI.SetIsRemoveWhenClick(tip, true)
end
--护身符按钮
function EndlessTrialsUI.OnBuffBtnClick()
    if EndlessTrialsUI.FormShiLianData.Juju.Icon == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "未选中护身符")
        return
    end
    local BuffBg = _gt.GetUI("BuffBg")
    local boardR = _gt.GetUI("boardR")
    local buffBtn = _gt.GetUI("BuffBtn")
    if BuffBg==nil then
        BuffBg = GUI.GroupCreate(boardR, "BuffBg",70, 0,400,200)
        _gt.BindName(BuffBg,"BuffBg")
        UILayout.SetSameAnchorAndPivot(BuffBg, UILayout.Top)
        GUI.SetIsRemoveWhenClick(BuffBg, true)

        local bg = GUI.ImageCreate(BuffBg,"bg","1800400290",-425,200,false,400,250)
        local picbg = GUI.ImageCreate(bg,"picbg",itemIconBg[EndlessTrialsUI.FormShiLianData.Juju.Grade],-135,20,false,80,80)
        UILayout.SetSameAnchorAndPivot(picbg, UILayout.Top)
        local pic = GUI.ImageCreate(picbg,"pic",EndlessTrialsUI.FormShiLianData.Juju.Icon,0,0,false,70,70)
        UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
        local txt = GUI.CreateStatic(picbg, "txt",EndlessTrialsUI.FormShiLianData.Juju.Name,120, -10, 140, 45)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.GradeColor[EndlessTrialsUI.FormShiLianData.Juju.Grade], TextAnchor.MiddleLeft)
        local txt2 = GUI.CreateStatic(bg, "txt2",EndlessTrialsUI.FormShiLianData.Juju.Info, 0, 120, 360, 120,"system",true)
        UILayout.StaticSetFontSizeColorAlignment(txt2, UIDefine.FontSizeM, UIDefine.Brown2Color, TextAnchor.UpperLeft)
        local pic2 = GUI.ImageCreate(bg,"pic2","1800600030",0,-10,false,400,5)
        UILayout.SetSameAnchorAndPivot(pic2, UILayout.Center)
    end
end
--技能按钮
function EndlessTrialsUI.OnSkillBtnClick()

    if #EndlessTrialsUI.FormShiLianData.Buff == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "未获得技能")
        return
    end
    local SkillBg = _gt.GetUI("SkillBg")
    local boardR = _gt.GetUI("boardR")
    local SkillBtn = _gt.GetUI("SkillBtn")
    if SkillBg==nil then
        SkillBg = GUI.GroupCreate(boardR, "SkillBg",-400, 150,400,200)
        _gt.BindName(SkillBg,"SkillBg")
        UILayout.SetSameAnchorAndPivot(SkillBg, UILayout.Top)
        GUI.SetIsRemoveWhenClick(SkillBg, true)

        local pc = GUI.ImageCreate(SkillBg,"pc","1800400290",150,50,false,400,250)
        local ScrollSkill = GUI.ScrollListCreate(pc, "ScrollSkill",0, 10, 380, 80, true, UIAroundPivot.TopLeft,UIAnchor.Top)
        GUI.ScrollRectSetNormalizedPosition(ScrollSkill,Vector2(0,0))
        local typeCount = #EndlessTrialsUI.FormShiLianData.Buff
        for i=1,typeCount do
            local btn = GUI.ButtonCreate(ScrollSkill,"btn"..i,itemIconBg[EndlessTrialsUI.FormShiLianData.Buff[i].Grade],0,0, Transition.ColorTint,"",80,80,false)
            _gt.BindName(btn, "ScrollSkillBtn"..i)
            GUI.AddWhiteName(SkillBg,GUI.GetGuid(btn))
            local pic = GUI.ImageCreate(btn,"pic",EndlessTrialsUI.FormShiLianData.Buff[i].Icon,0,0,false,70,70)
            UILayout.SetSameAnchorAndPivot(pic, UILayout.Center)
            GUI.SetData(btn,"index", i)
            GUI.SetPreferredHeight(btn,65)
            UILayout.SetSameAnchorAndPivot(btn, UILayout.Center)
            GUI.RegisterUIEvent(btn , UCE.PointerClick , "EndlessTrialsUI", "OnScrollSkillBtnClick")
        end
        EndlessTrialsUI.OnScrollSkillBtnClick(nil,1)
    end
end
--退出
function EndlessTrialsUI.OnExit()
    GUI.DestroyWnd("EndlessTrialsUI")
    CL.SendNotify(NOTIFY.SubmitForm,"FormShiLian","CloseSelect")
end
--服务器调用刷新
function EndlessTrialsUI.RefreshForm()

    local Bagpack = _gt.GetUI("Bagpack")
    GUI.LoopScrollRectRefreshCells(Bagpack)
    local re = _gt.GetUI("Groups")
    GUI.SetVisible(re, false)
    --print(EndlessTrialsUI.serialize(EndlessTrialsUI.FormShiLianData))
    EndlessTrialsUI.ShiLianList = {}

    local boardR = _gt.GetUI("boardR")
    local Info = GUI.GetChild(boardR,"info",false)
    local info_Txt = GUI.GetChild(Info,"info_Txt")
    GUI.StaticSetText(info_Txt,EndlessTrialsUI.FormShiLianData.Event[EndlessTrialsUI.FormShiLianData.SelectOptionIndex].Info)
    local Choice_List = GUI.GetChild(boardR,"Choice_List")

    GUI.LoopScrollRectRefreshCells(Choice_List)
    GUI.LoopScrollRectSetTotalCount(Choice_List,#EndlessTrialsUI.FormShiLianData.Event)
    GUI.LoopScrollRectRefreshCells(Choice_List)


    if EndlessTrialsUI.FormShiLianData~=nil then
        EndlessTrialsUI.ShiLianList = EndlessTrialsUI.FormShiLianData.DifficultyConfig
    end
    local txt = _gt.GetUI("TitleTxt")
    if txt then
        GUI.StaticSetText(txt, EndlessTrialsUI.FormShiLianData.Title)
    end
    txt = _gt.GetUI("MsgTxt")
    if txt then
        GUI.StaticSetText(txt, EndlessTrialsUI.FormShiLianData.Msg)
    end
    txt = _gt.GetUI("coinTxt")
    if txt then
        GUI.StaticSetText(txt, EndlessTrialsUI.FormShiLianData.ShiLianMoneyVal)
    end
    txt = _gt.GetUI("Speed_SliderTxt")
    if txt then
        if not EndlessTrialsUI.FormShiLianData.Step[1] then
            GUI.StaticSetText(txt, 0 .."/"..EndlessTrialsUI.FormShiLianData.Step[2])
        else
            GUI.StaticSetText(txt, EndlessTrialsUI.FormShiLianData.Step[1].."/"..EndlessTrialsUI.FormShiLianData.Step[2])
        end
    end
    txt = _gt.GetUI("Speed_SliderBar")
    if txt then
        if not EndlessTrialsUI.FormShiLianData.Step[1] then
            GUI.ScrollBarSetPos(txt,0/EndlessTrialsUI.FormShiLianData.Step[2])
        else
            GUI.ScrollBarSetPos(txt,EndlessTrialsUI.FormShiLianData.Step[1]/EndlessTrialsUI.FormShiLianData.Step[2])
        end

    end
    txt = _gt.GetUI("Difficulty_txt")
    if txt then
        GUI.StaticSetText(txt,EndlessTrialsUI.FormShiLianData.SelectDifficulty)
    end

--[[    EndlessTrialsUI.Reform()]]
    EndlessTrialsUI.RefreshMsg()
end

function EndlessTrialsUI.OnCoinBtnClick()
    local parent = _gt.GetUI("coinBg")
    local CoinTip= GUI.ImageCreate(parent,"CoinTip","1800400290",50,-50,false,200,100)
    local CoinTipTxt = GUI.CreateStatic(CoinTip,"CoinTipTxt",EndlessTrialsUI.FormShiLianData.MoneyInfo,0,10,180,80)
    UILayout.StaticSetFontSizeColorAlignment(CoinTipTxt, UIDefine.FontSizeM, UIDefine.Brown2Color, TextAnchor.UpperLeft)
    GUI.SetIsRemoveWhenClick(CoinTip, true)
end

function EndlessTrialsUI.RefreshMsg()
    local bg = _gt.GetUI("boardR")

    local Button1 = GUI.GetChild(bg,"choice1",false)
    local Button2 = GUI.GetChild(bg,"choice2",false)
    local Button3 = GUI.GetChild(bg,"choice3",false)
    local index = EndlessTrialsUI.FormShiLianData.SelectOptionIndex
    local sellScroll =  _gt.GetUI("Choice_List")
    for i = 1 ,#EndlessTrialsUI.FormShiLianData.Event do
        local ChoiceFrame = _gt.GetUI("ChoiceFrame"..i-1)
        GUI.SetVisible(ChoiceFrame,false)
    end
    if index ~= 1 then
        local Num = #EndlessTrialsUI.FormShiLianData.Event
        for i=1,Num do
            local finish = _gt.GetUI("finish"..i-2)
            GUI.SetVisible(finish,true)
        end
    else
        for i=1,5 do
            local finish = _gt.GetUI("finish"..i-1)
            GUI.SetVisible(finish,false)
        end
    end
    Now_choice = index
    local Button_num = #EndlessTrialsUI.FormShiLianData.Event[index].Button
    if Button_num == 1 then
        --print("1111111111")
        GUI.SetVisible(Button2,false)
        GUI.SetVisible(Button3,false)
        GUI.SetPositionX(Button1,0)
        GUI.ButtonSetText(Button1,EndlessTrialsUI.FormShiLianData.Event[index].Button[1])
    elseif Button_num == 2 then
        GUI.SetVisible(Button2,true)
        GUI.SetVisible(Button3,false)
        GUI.SetPositionX(Button1,-160)
        GUI.SetPositionX(Button2,160)
        GUI.ButtonSetText(Button1,EndlessTrialsUI.FormShiLianData.Event[index].Button[1])
        GUI.ButtonSetText(Button2,EndlessTrialsUI.FormShiLianData.Event[index].Button[2])
    elseif Button_num == 3 then
        GUI.SetVisible(Button2,true)
        GUI.SetVisible(Button3,true)
        GUI.SetPositionX(Button1,-220)
        GUI.SetPositionX(Button2,0)
        GUI.SetPositionX(Button3,220)
        GUI.ButtonSetText(Button1,EndlessTrialsUI.FormShiLianData.Event[index].Button[1])
        GUI.ButtonSetText(Button2,EndlessTrialsUI.FormShiLianData.Event[index].Button[2])
        GUI.ButtonSetText(Button3,EndlessTrialsUI.FormShiLianData.Event[index].Button[3])
    end
end

function EndlessTrialsUI.OnbgBtnClick(guid)
    local button = GUI.GetByGuid(guid)
    local PicBg = GUI.GetChild(button,"picBg",false)
    local index = tonumber(GUI.GetData(button,"index"))
    local bg = _gt.GetUI("boardR")
    local info = GUI.GetChild(bg,"info",false)
    GUI.ScrollRectSetNormalizedPosition(info,Vector2.New(0,1))
    local info_Txt = GUI.GetChild(info,"info_Txt",false)
    --CDebug.LogError(index)
    if index-1 > #EndlessTrialsUI.FormShiLianData.Event then
        GUI.StaticSetText(info_Txt,EndlessTrialsUI.FormShiLianData.Event[1].Info)
    else
        GUI.StaticSetText(info_Txt,EndlessTrialsUI.FormShiLianData.Event[index].Info)
    end

    for i = 1 ,5 do
        local ChoiceFrame =_gt.GetUI("ChoiceFrame"..i)
        GUI.SetVisible(ChoiceFrame,false)
    end

    local ChoiceFrame = GUI.GetChild(PicBg,"ChoiceFrame",false)
    GUI.SetVisible(ChoiceFrame,true)

    local Button1 = GUI.GetChild(bg,"choice1",false)
    local Button2 = GUI.GetChild(bg,"choice2",false)
    local Button3 = GUI.GetChild(bg,"choice3",false)
    Now_choice = index
    local Button_num = #EndlessTrialsUI.FormShiLianData.Event[index].Button
    if Button_num == 1 then
        --print("1111111111")
        GUI.SetVisible(Button2,false)
        GUI.SetVisible(Button3,false)
        GUI.SetPositionX(Button1,0)
        GUI.ButtonSetText(Button1,EndlessTrialsUI.FormShiLianData.Event[index].Button[1])
    elseif Button_num == 2 then
        GUI.SetVisible(Button2,true)
        GUI.SetVisible(Button3,false)
        GUI.SetPositionX(Button1,-160)
        GUI.SetPositionX(Button2,160)
        GUI.ButtonSetText(Button1,EndlessTrialsUI.FormShiLianData.Event[index].Button[1])
        GUI.ButtonSetText(Button2,EndlessTrialsUI.FormShiLianData.Event[index].Button[2])
    elseif Button_num == 3 then
        GUI.SetVisible(Button2,true)
        GUI.SetVisible(Button3,true)
        GUI.SetPositionX(Button1,-220)
        GUI.SetPositionX(Button2,0)
        GUI.SetPositionX(Button3,220)
        GUI.ButtonSetText(Button1,EndlessTrialsUI.FormShiLianData.Event[index].Button[1])
        GUI.ButtonSetText(Button2,EndlessTrialsUI.FormShiLianData.Event[index].Button[2])
        GUI.ButtonSetText(Button3,EndlessTrialsUI.FormShiLianData.Event[index].Button[3])
    end
end

function EndlessTrialsUI.OnChoiceBtnClick(guid)
    --print("click")
    local Choice = GUI.GetByGuid(guid)
    local Choice_num = tonumber(GUI.GetData(Choice,"Number"))
    CL.SendNotify(NOTIFY.SubmitForm,"FormShiLian","GetButtonClick",Now_choice,EndlessTrialsUI.FormShiLianData.Event[Now_choice].Button[Choice_num])
end



function EndlessTrialsUI.OnScrollSkillBtnClick(guid,btnIndex)
    local Msg = _gt.GetUI("Msg")
    local bg = _gt.GetUI("SkillBg")
    local btn = guid ~= nil and GUI.GetByGuid(guid) or _gt.GetUI("ScrollSkillBtn"..btnIndex)
    if btn then
        local index = tonumber(GUI.GetData(btn,"index"))
        if Msg==nil then
            local Msg = GUI.GroupCreate(bg, "MsgBg",70, -200,400,200)
            _gt.BindName(Msg,"MsgBg")
            UILayout.SetSameAnchorAndPivot(Msg, UILayout.Top)
            GUI.SetIsRemoveWhenClick(Msg, true)

            local txt1 = GUI.CreateStatic(Msg, "txt1",EndlessTrialsUI.FormShiLianData.Buff[index].Name,70, 350, 140, 45)
            UILayout.StaticSetFontSizeColorAlignment(txt1, UIDefine.FontSizeM, UIDefine.GradeColor[EndlessTrialsUI.FormShiLianData.Buff[index].Grade], TextAnchor.MiddleCenter)
            local txt2 = GUI.CreateStatic(Msg, "txt2",EndlessTrialsUI.FormShiLianData.Buff[index].Info,80, 385, 370, 105,"system",true)
            UILayout.StaticSetFontSizeColorAlignment(txt2, UIDefine.FontSizeM, UIDefine.Brown2Color ,TextAnchor.UpperLeft)
            local pic2 = GUI.ImageCreate(Msg,"pic2","1800600030",90,250,false,400,5)
            UILayout.SetSameAnchorAndPivot(pic2, UILayout.Center)
        end

    end
end

function EndlessTrialsUI.CreateItemIconPool()
    local itemScroll = _gt.GetUI("Bagpack")
    local index = GUI.LoopScrollRectGetChildInPoolCount(itemScroll)
    local itemIcon = ItemIcon.Create(itemScroll, "itemIcon"..tonumber(index)+1, 0, 0)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "EndlessTrialsUI", "OnBagIconClick")
    return itemIcon

end

function EndlessTrialsUI.Reform()
--[[    local ReFrom = _gt.GetUI("pic1")
    local infoTips = _gt.GetUI("infoTips"..6)

    local bg = _gt.GetUI("boardR")
    if infoTips ==nil then
        infoTips = GUI.GroupCreate(bg, "infoTip", 0, 130,650,500)
        _gt.BindName(infoTips,"infoTips"..6)
        UILayout.SetSameAnchorAndPivot(infoTips, UILayout.Center)

        local frame = GUI.ImageCreate(ReFrom,"frame","1800400280",0,0,false,150,150)
        _gt.BindName(frame,"frame"..6)




        local cho = #EndlessTrialsUI.FormShiLianData.Event[1].Button
        if cho == 1 then
            for x=1,cho do
                local choice = GUI.ButtonCreate(infoTips,"choice"..x,"1800002060",0,100,Transition.ColorTint,"",165,48,false)
                _gt.BindName(choice,"choice")
                GUI.AddWhiteName(infoTips,GUI.GetGuid(choice))
                GUI.RegisterUIEvent(choice, UCE.PointerClick, "EndlessTrialsUI", "OnChoiceBtnClick1")
                UILayout.SetSameAnchorAndPivot(choice, UILayout.Center)
                local txt = GUI.CreateStatic(choice, "txt"..x,EndlessTrialsUI.FormShiLianData.Event[1].Button[x],0, 0, 104, 45)
                UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
                UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeXXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
            end
        elseif cho == 2 then
            for x=1,cho do
                if x==1 then
                    local choice = GUI.ButtonCreate(infoTips,"choice"..x,"1800002060",410*x-375,100,Transition.ColorTint,"",165,48,false)
                    _gt.BindName(choice,"choice")
                    GUI.AddWhiteName(infoTips,GUI.GetGuid(choice))
                    GUI.RegisterUIEvent(choice, UCE.PointerClick, "EndlessTrialsUI", "OnChoiceBtnClick1")
                    UILayout.SetSameAnchorAndPivot(choice, UILayout.Left)
                    local txt = GUI.CreateStatic(choice, "txt"..x,EndlessTrialsUI.FormShiLianData.Event[1].Button[x],0, 0, 104, 45)
                    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
                    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeXXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
                else
                    local choice = GUI.ButtonCreate(infoTips,"choice"..x,"1800002060",410*x-375,100,Transition.ColorTint,"",165,48,false)
                    _gt.BindName(choice,"choice")
                    GUI.AddWhiteName(infoTips,GUI.GetGuid(choice))
                    GUI.RegisterUIEvent(choice, UCE.PointerClick, "EndlessTrialsUI", "OnChoiceBtnClick2")
                    UILayout.SetSameAnchorAndPivot(choice, UILayout.Left)
                    local txt = GUI.CreateStatic(choice, "txt"..x,EndlessTrialsUI.FormShiLianData.Event[1].Button[x],0, 0, 104, 45)
                    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
                    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeXXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
                end
            end
        elseif cho == 3 then
            for x=1,cho do
                if x==1 then
                    local choice = GUI.ButtonCreate(infoTips,"choice"..x,"1800002060",240*x-230,100,Transition.ColorTint,"",165,48,false)
                    _gt.BindName(choice,"choice")
                    GUI.RegisterUIEvent(choice, UCE.PointerClick, "EndlessTrialsUI", "OnChoiceBtnClick1")
                    UILayout.SetSameAnchorAndPivot(choice, UILayout.Left)
                    local txt = GUI.CreateStatic(choice, "txt"..x,EndlessTrialsUI.FormShiLianData.Event[1].Button[x],0, 0, 104, 45)
                    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
                    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeXXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
                elseif x==2 then
                    local choice = GUI.ButtonCreate(infoTips,"choice"..x,"1800002060",240*x-230,100,Transition.ColorTint,"",165,48,false)
                    _gt.BindName(choice,"choice")
                    GUI.RegisterUIEvent(choice, UCE.PointerClick, "EndlessTrialsUI", "OnChoiceBtnClick2")
                    UILayout.SetSameAnchorAndPivot(choice, UILayout.Left)
                    local txt = GUI.CreateStatic(choice, "txt"..x,EndlessTrialsUI.FormShiLianData.Event[1].Button[x],0, 0, 104, 45)
                    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
                    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeXXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
                else
                    local choice = GUI.ButtonCreate(infoTips,"choice"..x,"1800002060",240*x-230,100,Transition.ColorTint,"",165,48,false)
                    _gt.BindName(choice,"choice")
                    GUI.RegisterUIEvent(choice, UCE.PointerClick, "EndlessTrialsUI", "OnChoiceBtnClick3")
                    UILayout.SetSameAnchorAndPivot(choice, UILayout.Left)
                    local txt = GUI.CreateStatic(choice, "txt"..x,EndlessTrialsUI.FormShiLianData.Event[1].Button[x],0, 0, 104, 45)
                    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
                    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeXXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
                end
            end
        end
    end]]
end

function EndlessTrialsUI.RefreshItemScroll(para)
    para = string.split(para, "#");
    local guid = para[1];
    local index = tonumber(para[2]);
    local itemIcon = GUI.GetByGuid(guid);

    ItemIcon.SetEmpty(itemIcon)

    GUI.SetData(itemIcon, "index", tostring(index))

    if not EndlessTrialsUI.FormShiLianData.Goods then
        return
    end
    if index == 0 then
        if EndlessTrialsUI.FormShiLianData.Goods ~= nil then
            if EndlessTrialsUI.FormShiLianData.Goods.Money ~= nil and EndlessTrialsUI.FormShiLianData.Goods.PetExp > 0 or EndlessTrialsUI.FormShiLianData.Goods.Exp > 0 then
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, itemIconBg[4])
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, 1900013700)
            end
        end
    end
    local i = 1
    for k, v in pairs(EndlessTrialsUI.FormShiLianData.Goods.Item) do
        if i==index then
            local GoodsDB = DB.GetOnceItemByKey2(k)
            if EndlessTrialsUI.FormShiLianData.Goods.Item[k]["1"]~=nil then
                ItemIcon.BindItemDB(itemIcon, GoodsDB)
                GUI.SetData(itemIcon, "ItemId", tostring(GoodsDB.Id))
                GUI.SetData(itemIcon,"KeyName",tostring(k))
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, EndlessTrialsUI.FormShiLianData.Goods.Item[k]["1"])
                if EndlessTrialsUI.FormShiLianData.Goods.Item[k]["2"]~=nil then
                    ItemIcon.BindItemDB(itemIcon, GoodsDB)
                    GUI.SetData(itemIcon, "ItemId", tostring(GoodsDB.Id))
                    GUI.SetData(itemIcon,"KeyName",tostring(k))
                    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, EndlessTrialsUI.FormShiLianData.Goods.Item[k]["2"])
                end
            else
                ItemIcon.BindItemDB(itemIcon, GoodsDB)
                GUI.SetData(itemIcon, "ItemId", tostring(GoodsDB.Id))
                GUI.SetData(itemIcon,"KeyName",tostring(k))
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120)
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum,EndlessTrialsUI.FormShiLianData.Goods.Item[k]["2"])
            end
        end
        i=i+1
    end
end

--[[function EndlessTrialsUI.UIOF()
    if JISHU ~=EndlessTrialsUI.Choice then
    local index = EndlessTrialsUI.Choice
    local UI1 = _gt.GetUI("infoTips1")
    local K1 = _gt.GetUI("frame1")
    if UI1 and K1 then
        GUI.SetVisible(UI1, index==1)
        GUI.SetVisible(K1, index==1)
    end
    local UI2 = _gt.GetUI("infoTips2")
    local K2 = _gt.GetUI("frame2")
    if UI2 and K2 then
        GUI.SetVisible(UI2, index==2)
        GUI.SetVisible(K2, index==2)
    end
    local UI3 = _gt.GetUI("infoTips3")
    local K3 = _gt.GetUI("frame3")
    if UI3 and K3 then
        GUI.SetVisible(UI3, index==3)
        GUI.SetVisible(K3, index==3)
    end
    local UI4 = _gt.GetUI("infoTips4")
    local K4 = _gt.GetUI("frame4")
    if UI4 and K4 then
        GUI.SetVisible(UI4, index==4)
        GUI.SetVisible(K4, index==4)
    end
    local UI5 = _gt.GetUI("infoTips5")
    local K5 = _gt.GetUI("frame5")
    if UI5 and K5 then
        GUI.SetVisible(UI5, index==5)
        GUI.SetVisible(K5, index==5)
    end
    JISHU = EndlessTrialsUI.Choice
    else
        return
    end
end]]

function EndlessTrialsUI.OnBagIconClick(guid)
    local BG = _gt.GetUI("boardR")
    local itemIcon = GUI.GetByGuid(guid);
    local index = GUI.ItemCtrlGetIndex(itemIcon);

    --乾坤袋
    if index == 0 then
        if EndlessTrialsUI.FormShiLianData.Goods ~= nil then
            for k,v in pairs(EndlessTrialsUI.FormShiLianData.Goods) do
                if k == "Money" then
                    if EndlessTrialsUI.FormShiLianData.Goods.Money["5"] ~= nil and EndlessTrialsUI.FormShiLianData.Goods.PetExp > 0 or EndlessTrialsUI.FormShiLianData.Goods.Exp > 0 then
                        local itemTips = GUI.ItemTipsCreate(BG, "qiankundai", -200, 0, 220)
                        GUI.SetIsRemoveWhenClick(itemTips, true)
                        GUI.ItemTipsSetItemType(itemTips,"类型：道具",UIDefine.YellowColor)
                        GUI.ItemTipsSetItemShowLevel(itemTips,"等级需求：1级",UIDefine.YellowColor)
                        GUI.ItemTipsSetItemLevel(itemTips,"所需角色：",UIDefine.YellowColor)
                        local itemLimit = GUI.GetChild(itemTips, "itemLimit")
                        if itemLimit then
                            GUI.SetVisible(itemLimit, false)
                        end
                        local itemIcon = GUI.TipsGetItemIcon(itemTips)
                        GUI.ItemTipsSetItemName(itemTips,"乾坤袋",UIDefine.PurpleColor)
                        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, itemIconBg[4])
                        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, 1900013700)
                        local CutLine = GUI.ImageCreate(itemTips,"line","1800600030",0,-70,false,400,4)
                        local txt = GUI.CreateStatic(CutLine,"txt","当前储存奖励:",-90,20,150,50)
                        GUI.StaticSetFontSize(txt, 22)
                        GUI.SetColor(txt, UIDefine.WhiteColor)
                        local playerEXP = GUI.ImageCreate(CutLine,"playerEXP",1800408330,-150,50,false,34,34)
                        local playerExpText = GUI.CreateStatic(playerEXP,"playerExpText",EndlessTrialsUI.FormShiLianData.Goods.Exp,75,0,100,30)
                        GUI.StaticSetFontSize(playerExpText, 20)
                        GUI.SetColor(playerExpText, UIDefine.WhiteColor)
                        local petEXP = GUI.ImageCreate(CutLine,"petEXP",1800408320,45,50,false,34,34)
                        local petExpText = GUI.CreateStatic(petEXP,"petExpText",EndlessTrialsUI.FormShiLianData.Goods.PetExp,75,0,100,30)
                        GUI.StaticSetFontSize(petExpText, 20)
                        GUI.SetColor(petExpText, UIDefine.WhiteColor)
                        local Money = GUI.ImageCreate(CutLine,"Money",1800408280,-150,90,false,34,34)
                        local MoneyText = GUI.CreateStatic(Money,"MoneyText",EndlessTrialsUI.FormShiLianData.Goods.Money["5"],75,0,100,30)
                        GUI.StaticSetFontSize(MoneyText, 20)
                        GUI.SetColor(MoneyText, UIDefine.WhiteColor)
                        local CutLine2 = GUI.ImageCreate(itemTips,"line2","1800600030",0,45,false,400,4)
                        local explain = GUI.CreateStatic(itemTips,"explain","乾坤袋拥有不可思议之力，内部有著奇异之空间。用于储存无尽试炼中所获得的经验和货币奖励,结束试炼后自动获得奖励。",0,105,360,120)
                        GUI.StaticSetFontSize(explain, 22)
                        GUI.SetColor(explain, UIDefine.Brown2Color)
                        --[[            if not EndlessTrialsUI.FormShiLianData.Goods.Exp > 0 then
                                        GUI.SetVisible(playerEXP,false)
                                        GUI.SetPositionX(petEXP,-150)
                                        GUI.SetPositionX(Money,45)
                                        GUI.SetPositionY(Money,50)
                                    end
                                    if not EndlessTrialsUI.FormShiLianData.Goods.PetExp > 0 then

                                    end]]
                        break
                    end
                end
            end
        end
    end


    local KeyName = GUI.GetData(itemIcon,"KeyName")
    local UI = Tips.CreateByItemKeyName(KeyName, BG, "BGUI", -200, 0, 50)
end
function EndlessTrialsUI.serialize(obj)
    local text = ""
    local t = type(obj)
    if t == "number" then
        text = text .. obj
    elseif t == "boolean" then
        text = text .. tostring(obj)
    elseif t == "string" then
        text = text .. string.format("%q", obj)
    elseif t == "table" then
        text = text .. "{\n"
        for k, v in pairs(obj) do
            text = text .. "[" .. EndlessTrialsUI.serialize(k) .. "]=" .. EndlessTrialsUI.serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                text = text .. "[" .. EndlessTrialsUI.serialize(k) .. "]=" .. EndlessTrialsUI.serialize(v) .. ",\n"
            end
        end

        text = text .. "}"

    elseif t == "nil" then
        return nil
    end

    return text
end

function EndlessTrialsUI.OnShow()

end