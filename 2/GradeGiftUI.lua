GradeGiftUI = {}
--狂送大礼
_G.GradeGiftUI = GradeGiftUI
local _gt = UILayout.NewGUIDUtilTable();

GradeGiftUI.Show_Index = 1
--选项的默认值
local first_btn_choose = {true,false,false}
local second_btn_choose = {false,true,false}
local third_btn_choose = {false,false,true}
--数字的编号0-9
local num_imge = {"1801405010","1801405020","1801405030","1801405040","1801405050","1801405060","1801405070","1801405080","1801405090","1801405100"}
--文字图片
-- local txt_Config = {
--     [1] = {
--         ['txt1'] = { ['x'] = -233, ['y'] = -33, ['imge'] = "1801404020" },
--         ['txt2'] = { ['x'] = -152, ['y'] = -33, ['imge'] = "1801404040" },
--         ['txt3'] = { ['x'] = 2, ['y'] = -5, ['imge'] = "1801404070" },
--         ['txt5'] = { ['x'] = 155, ['y'] = 190, ['imge'] = "1801404100" },
--     },
--     [2] = {
--         ['txt1'] = { ['x'] = -233, ['y'] = -51, ['imge'] = "1801404010", },
--         ['txt2'] = { ['x'] = -152, ['y'] = -33, ['imge'] = "1801404050", },
--         ['txt3'] = { ['x'] = 2, ['y'] = -5, ['imge'] = "1801404060", },
--         ['txt5'] = { ['x'] = 155, ['y'] = 190, ['imge'] = "1801404090", },
--     },
--     [3] = {
--         ['txt1'] = { ['x'] = -233, ['y'] = -33, ['imge'] = "1801404030", },
--         ['txt2'] = { ['x'] = -152, ['y'] = -33, ['imge'] = "1801404140", },
--         ['txt3'] = { ['x'] = 2, ['y'] = -5, ['imge'] = "1801404080", },
--         ['txt5'] = { ['x'] = 155, ['y'] = 190, ['imge'] = "1801404110", },
--     },
-- }
local txt_Config = {
    [1] = {
        [1] = { ['x'] = 220, ['y'] = -65, ['w'] = 40, ['h'] = 200 , ['fontSize'] = 26 ,['fontType'] = "103"},
        [2] = { ['x'] = -152, ['y'] = -33, ['w'] = 40, ['h'] = 200 , ['fontSize'] = 24 ,['fontType'] = "101" ,['isOutLine'] = true},
        [3] = { ['x'] = -253, ['y'] = -33, ['w'] = 40, ['h'] = 500 , ['fontSize'] = 76 ,['fontType'] = "105" ,['isShadow'] = true ,['isBoldOutLine'] = true},
        [4] = { ['x'] = 155, ['y'] = 190, ['w'] = 200, ['h'] = 60 , ['fontSize'] = 42 ,['fontType'] = "103" ,['isRich'] = true ,['isShadow'] = true,['isBoldOutLine'] = true},
    },
    [2] = {
        [1] = { ['x'] = 220, ['y'] = -65, ['w'] = 40, ['h'] = 200, ['fontSize'] = 26 ,['fontType'] = "103"},
        [2] = { ['x'] = -152, ['y'] = -33, ['w'] = 40, ['h'] = 200 , ['fontSize'] = 24 ,['fontType'] = "101" ,['isOutLine'] = true},
        [3] = { ['x'] = -253, ['y'] = -51, ['w'] = 40, ['h'] = 600 , ['fontSize'] = 76 ,['fontType'] = "105" ,['isShadow'] = true,['isBoldOutLine'] = true},
        [4] = { ['x'] = 155, ['y'] = 190, ['w'] = 200, ['h'] = 60 , ['fontSize'] = 42 ,['fontType'] = "103",['isRich'] = true ,['isShadow'] = true,['isBoldOutLine'] = true},
    },
    [3] = {
        [1] = { ['x'] = 220, ['y'] = -65, ['w'] = 40, ['h'] = 200, ['fontSize'] = 26 ,['fontType'] = "103"},
        [2] = { ['x'] = -152, ['y'] = -33, ['w'] = 40, ['h'] = 200 , ['fontSize'] = 24 ,['fontType'] = "101" ,['isOutLine'] = true},
        [3] = { ['x'] = -253, ['y'] = -33, ['w'] = 40, ['h'] = 500 , ['fontSize'] = 76 ,['fontType'] = "105" ,['isShadow'] = true,['isBoldOutLine'] = true},
        [4] = { ['x'] = 155, ['y'] = 190, ['w'] = 200, ['h'] = 60 , ['fontSize'] = 42 ,['fontType'] = "103",['isRich'] = true ,['isShadow'] = true,['isBoldOutLine'] = true},
    },
}
-- local txt_list = {1,2,3,5}

local GradeGift_Camere_Data = {
    [1] = {
        ['show1'] = "(0.0, -2.3, 0.4),(0.6, 0.3, 0.3, -0.6),False,50,0.01,1.64,81",
        ['show2'] = "(1.9, -1.4, -0.5),(0.4, 0.5, 0.0, -0.8),False,50,0.01,1.64,81",
        ['show3'] = "(-0.3, -0.9, 1.8),(-1.0, -0.2, -0.1, 0.2),False,50,0.01,1.64,81",
        ['show4'] = "(-0.1, -2.4, 0.2),(-0.7, 0.3, 0.3, 0.6),False,50,0.01,1.64,81",
        ['show5'] = "(0.0, -1.4, 0.0),(-0.7, -0.2, -0.2, 0.7),False,50,0.01,1.64,81",
        ['show6'] = "(-1, -2.0, -0.2),(-0.2, 0.6, 0.5, 0.5),False,50,0.01,1.64,81",
        ['show7'] = "(0.7, -2.4, 0.3),(-0.6, -0.3, -0.1, 0.7),False,50,0.01,1.64,81",
        ['show8'] = "(0.12, -3.9, 0.34),(-0.7, -0.2, -0.2, 0.7),False,50,0.01,1.64,81",
        ['show9'] = "(0.0, 0.1, 2),(-0.8, -0.5, 0.1, 0.0),False,50,0.01,1.64,81",
        ['show10'] = "(-0.55, 2, -0.15),(-0.6, 0.4, -0.5, -0.5),False,50,0.01,1.64,81",
        ['show11'] = "(-0.1, -3.4, 0),(-0.6, 0.3, 0.3, 0.6),False,50,0.01,1.64,81",
        ['show12'] = "(-2.5, -1.7, 0),(-0.1, -0.7, -0.5, -0.5),False,50,0.01,1.64,81",
    },
    [2] = {
        ['camereData'] = "(-1.2, 1.8, 2.6),(0.0, -1.0, 0.2, -0.2),True,4.79,0.01,3.8,37"
    },
    [3] = {
        ['camereData'] = "(0.1, 1.3, 2.6),(0.0, -1.0, 0.1, 0.0),True,4.79,0.01,3.8,37"
    }
}

--狂送大礼界面
function GradeGiftUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    test("GradeGiftUI lua ")
	
    local panel = GUI.WndCreateWnd("GradeGiftUI","GradeGiftUI",0,0)

    local panelCover = GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)
    UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center)

    local FirstGiftBtn = GUI.ButtonCreate(panel, "FirstGiftBtn", "1801402020", 399, -88, Transition.ColorTint, "", 0, 0, false, false)
    GUI.SetAnchor(FirstGiftBtn,UIAnchor.Center);
    GUI.SetPivot(FirstGiftBtn,UIAroundPivot.Center);
    GUI.RegisterUIEvent(FirstGiftBtn , UCE.PointerClick , "GradeGiftUI", "FirstGiftBtnClick" )

    local SecondGiftBtn = GUI.ButtonCreate(panel, "SecondGiftBtn", "1801402030", 421, 0, Transition.ColorTint, "", 0, 0, false, false)
    GUI.SetAnchor(SecondGiftBtn,UIAnchor.Center);
    GUI.SetPivot(SecondGiftBtn,UIAroundPivot.Center);
    GUI.RegisterUIEvent(SecondGiftBtn , UCE.PointerClick , "GradeGiftUI", "SecondGiftBtnClick" )

    local ThirdGiftBtn = GUI.ButtonCreate(panel, "ThirdGiftBtn", "1801402040", 396, 82, Transition.ColorTint, "", 0, 0, false, false)
    GUI.SetAnchor(ThirdGiftBtn,UIAnchor.Center);
    GUI.SetPivot(ThirdGiftBtn,UIAroundPivot.Center);
    GUI.RegisterUIEvent(ThirdGiftBtn , UCE.PointerClick , "GradeGiftUI", "ThirdGiftBtnClick" )

    local FirstGiftBtnText = GUI.CreateStatic(FirstGiftBtn,"FirstGiftBtnText","",40,7,190,65)
    --GUI.StaticSetAlignment(FirstGiftBtnText,TextAnchor.MiddleCenter)
    GUI.SetAnchor(FirstGiftBtnText,UIAnchor.Center);
    GUI.SetPivot(FirstGiftBtnText,UIAroundPivot.Center);
    GUI.SetColor(FirstGiftBtnText,UIDefine.Yellow4Color)
    GUI.StaticSetFontSize(FirstGiftBtnText,26)

    local SecondGiftBtnText = GUI.CreateStatic(SecondGiftBtn,"SecondGiftBtnText","",35,0,190,65)
    --GUI.StaticSetAlignment(SecondGiftBtn,TextAnchor.MiddleCenter)
    GUI.SetAnchor(SecondGiftBtnText,UIAnchor.Center);
    GUI.SetPivot(SecondGiftBtnText,UIAroundPivot.Center);
    GUI.SetColor(SecondGiftBtnText,UIDefine.Yellow4Color)
    GUI.StaticSetFontSize(SecondGiftBtnText,26)

    local ThirdGiftBtnText = GUI.CreateStatic(ThirdGiftBtn,"ThirdGiftBtnText","",40,-4,190,65)
    --GUI.StaticSetAlignment(ThirdGiftBtn,TextAnchor.MiddleCenter)
    GUI.SetAnchor(ThirdGiftBtnText,UIAnchor.Center);
    GUI.SetPivot(ThirdGiftBtnText,UIAroundPivot.Center);
    GUI.SetColor(ThirdGiftBtnText,UIDefine.Yellow4Color)
    GUI.StaticSetFontSize(ThirdGiftBtnText,26)

    _gt.BindName(FirstGiftBtn,"FirstGiftBtn")
    _gt.BindName(SecondGiftBtn,"SecondGiftBtn")
    _gt.BindName(ThirdGiftBtn,"ThirdGiftBtn")

    _gt.BindName(FirstGiftBtnText,"FirstGiftBtnText")
    _gt.BindName(SecondGiftBtnText,"SecondGiftBtnText")
    _gt.BindName(ThirdGiftBtnText,"ThirdGiftBtnText")

    local FirstGiftBtn1 = GUI.ButtonCreate(panel, "FirstGiftBtn1", "1801402021", 399, -88, Transition.ColorTint, "", 0, 0, false, false)
    GUI.SetAnchor(FirstGiftBtn1,UIAnchor.Center);
    GUI.SetPivot(FirstGiftBtn1,UIAroundPivot.Center);

    local SecondGiftBtn1 = GUI.ButtonCreate(panel, "SecondGiftBtn1", "1801402031", 421, 0, Transition.ColorTint, "", 0, 0, false, false)
    GUI.SetAnchor(SecondGiftBtn1,UIAnchor.Center);
    GUI.SetPivot(SecondGiftBtn1,UIAroundPivot.Center);
    GUI.SetVisible(SecondGiftBtn1,false)

    local ThirdGiftBtn1 = GUI.ButtonCreate(panel, "ThirdGiftBtn1", "1801402041", 396, 82, Transition.ColorTint, "", 0, 0, false, false)
    GUI.SetAnchor(ThirdGiftBtn1,UIAnchor.Center);
    GUI.SetPivot(ThirdGiftBtn1,UIAroundPivot.Center)
    GUI.SetVisible(ThirdGiftBtn1,false)

    local FirstGiftBtnText1 = GUI.CreateStatic(FirstGiftBtn1,"FirstGiftBtnText1","",45,8,190,65)
    --GUI.StaticSetAlignment(FirstGiftBtnText1,TextAnchor.MiddleCenter)
    GUI.SetAnchor(FirstGiftBtnText1,UIAnchor.Center);
    GUI.SetPivot(FirstGiftBtnText1,UIAroundPivot.Center);
    GUI.SetColor(FirstGiftBtnText1,UIDefine.YellowColor)
    GUI.StaticSetFontSize(FirstGiftBtnText1,34)

    local SecondGiftBtnText1 = GUI.CreateStatic(SecondGiftBtn1,"SecondGiftBtnText1","",40,3,190,65)
    --GUI.StaticSetAlignment(SecondGiftBtnText1,TextAnchor.MiddleCenter)
    GUI.SetAnchor(SecondGiftBtnText1,UIAnchor.Center);
    GUI.SetPivot(SecondGiftBtnText1,UIAroundPivot.Center);
    GUI.SetColor(SecondGiftBtnText1,UIDefine.YellowColor)
    GUI.StaticSetFontSize(SecondGiftBtnText1,34)

    local ThirdGiftBtnText1 = GUI.CreateStatic(ThirdGiftBtn1,"ThirdGiftBtnText1","",45,-4,190,65)
    --GUI.StaticSetAlignment(ThirdGiftBtnText1,TextAnchor.MiddleCenter)
    GUI.SetAnchor(ThirdGiftBtnText1,UIAnchor.Center);
    GUI.SetPivot(ThirdGiftBtnText1,UIAroundPivot.Center);
    GUI.SetColor(ThirdGiftBtnText1,UIDefine.YellowColor)
    GUI.StaticSetFontSize(ThirdGiftBtnText1,34)

    _gt.BindName(FirstGiftBtn1,"FirstGiftBtn1")
    _gt.BindName(SecondGiftBtn1,"SecondGiftBtn1")
    _gt.BindName(ThirdGiftBtn1,"ThirdGiftBtn1")

    _gt.BindName(FirstGiftBtnText1,"FirstGiftBtnText1")
    _gt.BindName(SecondGiftBtnText1,"SecondGiftBtnText1")
    _gt.BindName(ThirdGiftBtnText1,"ThirdGiftBtnText1")


    local panelBg = GUI.ImageCreate(panel,"PanelBg","1801400020",0,0);
    _gt.BindName(panelBg,"panelBg")
    GUI.SetAnchor(panelBg,UIAnchor.Center);
    GUI.SetPivot(panelBg,UIAroundPivot.Center);
    GUI.SetIsRaycastTarget(panelBg,true)
    panelBg:RegisterEvent(UCE.PointerClick)

    local TopPic = GUI.ImageCreate(panelBg, "TopPic", "1801408030", 29, -268)
    GUI.SetAnchor(TopPic,UIAnchor.Center);
    GUI.SetPivot(TopPic,UIAroundPivot.Center);

    local CloseBtn = GUI.ButtonCreate(panelBg, "CloseBtn", "1800402070", -65, 35, Transition.ColorTint, "", 63, 80, false, false)
    GUI.SetAnchor(CloseBtn,UIAnchor.TopRight);
    GUI.SetPivot(CloseBtn,UIAroundPivot.TopRight);
    GUI.RegisterUIEvent(CloseBtn , UCE.PointerClick , "GradeGiftUI", "OnExit" )

    local PIC = GUI.ImageCreate(panelBg, "PIC", "1801408010", 28, 85)
    GUI.SetAnchor(PIC,UIAnchor.Center);
    GUI.SetPivot(PIC,UIAroundPivot.Center);

    local modelParent = GUI.RawImageCreate(panelBg,true,"modelParent","",10,-90, 4, false, 1200, 1200)
    GUI.SetAnchor(modelParent,UIAnchor.Center)
    GUI.SetPivot(modelParent,UIAroundPivot.Center)
    GUI.AddToCamera(modelParent)
    GUI.SetIsRaycastTarget(modelParent, false)
    GUI.RawImageSetCameraConfig(modelParent,"(0.09119999,1.336,2.56),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,4.79,0.01,3.8,37")
    _gt.BindName(modelParent,"modelParent")

    local IconBG = GUI.ImageCreate(panelBg, "IconBG", "1801400010", 28, 95,false,450,93)
    _gt.BindName(IconBG,"IconBG")
    GUI.SetAnchor(IconBG,UIAnchor.Center);
    GUI.SetPivot(IconBG,UIAroundPivot.Center);

    local itemSrc = GUI.LoopScrollRectCreate(IconBG,"itemSrc",10,7,430,80,"GradeGiftUI","CreateItemIcon",
                        "GradeGiftUI","RefreshItemIcon",0,true,Vector2.New(80, 80),1,UIAroundPivot.TopLeft,UIAnchor.TopLeft)
    UILayout.SetSameAnchorAndPivot(itemSrc, UILayout.TopLeft)
    GUI.ScrollRectSetChildSpacing(itemSrc, Vector2.New(8, 8))
    _gt.BindName(itemSrc, "itemSrc")

    local TXTBG = GUI.ImageCreate(panelBg, "TXTBG", "1801408020",-110,180);
    GUI.SetAnchor(TXTBG,UIAnchor.TopRight);
    GUI.SetPivot(TXTBG,UIAroundPivot.TopRight);

    -- local Txt1 = GUI.ImageCreate(panelBg, "txt1", "1801404010", -233,-51)
    -- _gt.BindName(Txt1,"txt1")
    -- GUI.SetAnchor(Txt1,UIAnchor.Center);
    -- GUI.SetPivot(Txt1,UIAroundPivot.Center);

    -- local Txt2 = GUI.ImageCreate(panelBg, "txt2", "1801404040", -152,-33)
    -- _gt.BindName(Txt2,"txt2")
    -- GUI.SetAnchor(Txt2,UIAnchor.Center);
    -- GUI.SetPivot(Txt2,UIAroundPivot.Center);

    -- local Txt3 = GUI.ImageCreate(TXTBG, "txt3", "1801404060", -3,-5)
    -- _gt.BindName(Txt3,"txt3")
    -- GUI.SetAnchor(Txt3,UIAnchor.Center);
    -- GUI.SetPivot(Txt3,UIAroundPivot.Center);

    -- local Txt4 = GUI.ImageCreate(panelBg, "txt4", "1801404120", -55, 190)
    -- _gt.BindName(Txt4,"txt4")
    -- GUI.SetAnchor(Txt4,UIAnchor.Center);
    -- GUI.SetPivot(Txt4,UIAroundPivot.Center);

    -- local TxtLevel1 = GUI.ImageCreate(panelBg, "TxtLevel1", "1801405010", -95, 190)
    -- _gt.BindName(TxtLevel1,"TxtLevel1")
    -- GUI.SetAnchor(TxtLevel1,UIAnchor.Center);
    -- GUI.SetPivot(TxtLevel1,UIAroundPivot.Center);

    -- local TxtLevel2 = GUI.ImageCreate(panelBg, "TxtLevel2", "1801405010", -65, 190)
    -- _gt.BindName(TxtLevel2,"TxtLevel2")
    -- GUI.SetAnchor(TxtLevel2,UIAnchor.Center);
    -- GUI.SetPivot(TxtLevel2,UIAroundPivot.Center);

    -- local Txt5 = GUI.ImageCreate(panelBg, "txt5", "1801404090", 155,190)
    -- _gt.BindName(Txt5,"txt5")
    -- GUI.SetAnchor(Txt5,UIAnchor.Center);
    -- GUI.SetPivot(Txt5,UIAroundPivot.Center);

    local text = GUI.CreateStatic(panelBg, "text", "<i>达到      级，赠送</i>", -55, 190, 270, 60,"103",true)
    GUI.SetColor(text,UIDefine.Blue2Color)
    GUI.StaticSetFontSize(text,32)
    _gt.BindName(text,"text")
    --设置颜色渐变
    GUI.StaticSetIsGradientColor(text,true)
    GUI.StaticSetGradient_ColorTop(text,Color.New(30/255,43/255,142/255,255/255))


    local GetGiftBtn = GUI.ButtonCreate(panelBg, "GetGiftBtn", "1801402010", 28, 250, Transition.ColorTint, "", 204, 71, false, false)
    GUI.SetAnchor(GetGiftBtn,UIAnchor.Center);
    GUI.SetPivot(GetGiftBtn,UIAroundPivot.Center);
    GUI.RegisterUIEvent(GetGiftBtn , UCE.PointerClick , "GradeGiftUI", "GetTheGift" )
    GUI.ButtonSetShowDisable(GetGiftBtn,false)

    local BthTxt = GUI.ImageCreate(GetGiftBtn, "BthTxt", "1801404130", 0,0)
    GUI.SetAnchor(BthTxt,UIAnchor.Center);
    GUI.SetPivot(BthTxt,UIAroundPivot.Center);

    _gt.BindName(GetGiftBtn,"GetGiftBtn")
    _gt.BindName(BthTxt,"BthTxt")

    GradeGiftUI.itemList = {}
    --CL.SendNotify(NOTIFY.SubmitForm, "FormGradePresent", "GetPresetnData")
end


function GradeGiftUI.GetGiftList()
    if GradeGiftUI.IsHaveList ~= nil then
        GradeGiftUI.OnRefresh()
    else
        return
    end
end

function GradeGiftUI.setGiftIndex(index)
    GradeGiftUI.Show_Index = index
	if GradeGiftUI.IsHaveList then
		test("---------------")
	end
    --GradeGiftUI.Main()
    --GradeGiftUI.OnShow()
    GradeGiftUI.OnRefresh()
end

function GradeGiftUI.FirstGiftBtnClick()
    GradeGiftUI.Show_Index = 1
    GradeGiftUI.OnRefresh()
end

function GradeGiftUI.SecondGiftBtnClick()
    GradeGiftUI.Show_Index = 2
    GradeGiftUI.OnRefresh()
end

function GradeGiftUI.ThirdGiftBtnClick()
    GradeGiftUI.Show_Index = 3
    GradeGiftUI.OnRefresh()
end

function GradeGiftUI.GetTheGift()
    local now_level = UIDefine.GradeGift_RewardLevel[GradeGiftUI.Show_Index]
    CL.SendNotify(NOTIFY.SubmitForm, "FormGradePresent", "GiveGradePresent",now_level)
    --GradeGiftUI.OnRefresh()
end

function GradeGiftUI.OnRefresh()
    local now_index = GradeGiftUI.Show_Index
    local now_level = UIDefine.GradeGift_RewardLevel[now_index]
    local panelBg = _gt.GetUI("panelBg")
    local FirstGiftBtn = _gt.GetUI("FirstGiftBtn")
    local SecondGiftBtn = _gt.GetUI("SecondGiftBtn")
    local ThirdGiftBtn = _gt.GetUI("ThirdGiftBtn")
    local FirstGiftBtnText = _gt.GetUI("FirstGiftBtnText")
    local SecondGiftBtnText = _gt.GetUI("SecondGiftBtnText")
    local ThirdGiftBtnText = _gt.GetUI("ThirdGiftBtnText")

    local FirstGiftBtn1 = _gt.GetUI("FirstGiftBtn1")
    local SecondGiftBtn1 = _gt.GetUI("SecondGiftBtn1")
    local ThirdGiftBtn1 = _gt.GetUI("ThirdGiftBtn1")
    local FirstGiftBtnText1 = _gt.GetUI("FirstGiftBtnText1")
    local SecondGiftBtnText1 = _gt.GetUI("SecondGiftBtnText1")
    local ThirdGiftBtnText1 = _gt.GetUI("ThirdGiftBtnText1")

    --刷新右边页签
    GUI.StaticSetText(FirstGiftBtnText,UIDefine.GradeGift_RewardLevel[1]..'级')
    GUI.StaticSetText(SecondGiftBtnText,UIDefine.GradeGift_RewardLevel[2]..'级')
    GUI.StaticSetText(ThirdGiftBtnText,UIDefine.GradeGift_RewardLevel[3]..'级')
    GUI.StaticSetText(FirstGiftBtnText1,UIDefine.GradeGift_RewardLevel[1]..'级')
    GUI.StaticSetText(SecondGiftBtnText1,UIDefine.GradeGift_RewardLevel[2]..'级')
    GUI.StaticSetText(ThirdGiftBtnText1,UIDefine.GradeGift_RewardLevel[3]..'级')

    GUI.SetVisible(FirstGiftBtn,not first_btn_choose[now_index])
    GUI.SetVisible(FirstGiftBtn1,first_btn_choose[now_index])
    GUI.SetVisible(SecondGiftBtn,not second_btn_choose[now_index])
    GUI.SetVisible(SecondGiftBtn1,second_btn_choose[now_index])
    GUI.SetVisible(ThirdGiftBtn,not third_btn_choose[now_index])
    GUI.SetVisible(ThirdGiftBtn1,third_btn_choose[now_index])


    --刷新获取礼物按钮
    local GetGiftBtn = _gt.GetUI("GetGiftBtn")
    local BthTxt = _gt.GetUI("BthTxt")
    local giftisopen = GradeGiftUI.IsHaveList[''..now_level]-- 获取当前礼物是否已被打开

    if giftisopen == 1 then
        GUI.ImageSetImageID(BthTxt,'1801404150')
        GUI.ButtonSetShowDisable(GetGiftBtn,false)
    else
        local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel);
        if roleLevel >= now_level then
            GUI.ButtonSetShowDisable(GetGiftBtn,true)
        else
            GUI.ButtonSetShowDisable(GetGiftBtn,false)
        end
        GUI.ImageSetImageID(BthTxt,'1801404130')
    end

    -- 刷新文字
    local fontConfig = UIDefine.GradeGift_ItemList_For_Show[''..now_level].GradeGiftFontArtConfig
    if fontConfig ~= nil then
        for i = 1, #fontConfig do
            local config = fontConfig[i]
            local fontName = "text" .. now_index .. "_" .. i
            local text = _gt.GetUI(fontName)
            if text == nil then
                local x = txt_Config[now_index][i]['x']
                local y = txt_Config[now_index][i]['y']
                local w = txt_Config[now_index][i]['w']
                local h = txt_Config[now_index][i]['h']
                local fontType = txt_Config[now_index][i]['fontType']
                local fontSize = txt_Config[now_index][i]['fontSize']
                local isRich = txt_Config[now_index][i]['isRich']
                local isOutLine = txt_Config[now_index][i]['isOutLine']
                local isBoldOutLine = txt_Config[now_index][i]['isBoldOutLine']
                local isShadow = txt_Config[now_index][i]['isShadow']
                local txt = config.FontValue
                local FontName = config.FontName
                if isRich then
                    txt = "<i>" .. txt .. "</i>"
                end
                text = GUI.CreateStatic(panelBg,fontName,txt,x,y,w,h,fontType,isRich)
                GUI.SetColor(text,UIDefine.Yellow4Color)
                GUI.StaticSetIsGradientColor(text,true)
                GUI.StaticSetGradient_ColorTop(text,Color.New(255/255,252/255,114/255,255/255))
                GUI.StaticSetFontSize(text,fontSize)
                if isOutLine then
                    GUI.SetIsOutLine(text,true)
                    GUI.SetOutLine_Distance(text,1)
                    GUI.SetOutLine_Color(text,Color.New(233/255,111/255,28/255,255/255))
                end
                if isBoldOutLine then
                    GUI.SetIsOutLine(text,true)
                    GUI.SetOutLine_Distance(text,4)
                    GUI.SetOutLine_Color(text,Color.New(233/255,111/255,28/255,255/255))
                end
                if isShadow then
                    GUI.SetIsShadow(text,true)
                    GUI.SetShadow_Distance(text,Vector2.New(2,-4))
                    GUI.SetShadow_Color(text,UIDefine.Brown4Color)
                end
                GUI.StaticSetLineSpacing(text,0.9)
                _gt.BindName(text,fontName)
            else
                GUI.SetVisible(text,true)
            end
            for j = 1, #UIDefine.GradeGift_RewardLevel do
                if now_index ~= j then
                    local otherName = "text" .. j .. "_" .. i
                    local otherText = _gt.GetUI(otherName)
                    GUI.SetVisible(otherText,false)
                end
            end
        end
    else
        test("UIDefine.GradeGift_ItemList_For_Show["..now_level.."].GradeGiftFontArtConfig -------- 为空")
    end
    -- for i = 1 , #txt_list do
    --     local imgeName = 'txt'..txt_list[i]
    --     local x = txt_Config[now_index][imgeName]['x']
    --     local y = txt_Config[now_index][imgeName]['y']
    --     local imgeId = txt_Config[now_index][imgeName]['imge']
    --     local imge = _gt.GetUI(imgeName)
    --     GUI.ImageSetImageID(imge,imgeId)
    --     GUI.SetPositionX(imge, x)
    --     GUI.SetPositionY(imge, y)
    --     GUI.SetVisible(imge,true)
    -- end

    -- 刷新等级
    local levelText = _gt.GetUI('levelText')
    local txt = "<i>" .. now_level .. "</i>"
    if levelText then
        GUI.StaticSetText(levelText,txt)
    else
        levelText = GUI.CreateStatic(panelBg,'levelText',txt,-100,185,200,60,"107",true)
        GUI.StaticSetAlignment(levelText,TextAnchor.MiddleCenter)
        GUI.SetColor(levelText,UIDefine.Yellow4Color)
        GUI.StaticSetIsGradientColor(levelText,true)
        GUI.StaticSetGradient_ColorTop(levelText,UIDefine.Yellow3Color)
        GUI.StaticSetFontSize(levelText,44)
        GUI.SetIsOutLine(levelText,true)
        GUI.SetOutLine_Distance(levelText,1)
        GUI.SetOutLine_Color(levelText,UIDefine.OrangeColor)
        GUI.SetIsShadow(levelText,true)
        GUI.SetShadow_Distance(levelText,Vector2.New(1,-3))
        GUI.SetShadow_Color(levelText,UIDefine.Brown4Color)
        _gt.BindName(levelText,'levelText')
    end
    -- local TxtLevel1 = _gt.GetUI('TxtLevel1')
    -- local TxtLevel2 = _gt.GetUI('TxtLevel2')

    -- local num1 = math.floor(now_level/10)
    -- local num2 = now_level%10
    -- if num1 == 0 then
    --     GUI.SetVisible(TxtLevel1,false)
    --     GUI.ImageSetImageID(TxtLevel2,""..num_imge[(num2+1)])
    --     GUI.SetPositionX(TxtLevel2, -85)
    --     GUI.SetPositionY(TxtLevel2, 190)
    --     GUI.SetVisible(TxtLevel2,true)
    -- else
    --     GUI.ImageSetImageID(TxtLevel1,""..num_imge[(num1+1)])
    --     GUI.SetPositionX(TxtLevel1, -95)
    --     GUI.SetPositionY(TxtLevel1, 190)
    --     GUI.SetVisible(TxtLevel1,true)
    --     GUI.ImageSetImageID(TxtLevel2,""..num_imge[(num2+1)])
    --     GUI.SetPositionX(TxtLevel2, -65)
    --     GUI.SetPositionY(TxtLevel2, 190)
    --     GUI.SetVisible(TxtLevel2,true)
    -- end

    GradeGiftUI.itemList = {}
    local config = UIDefine.GradeGift_ItemList_For_Show[''..now_level]["GradeGift"]
    local roleRace = CL.GetIntAttr(RoleAttr.RoleAttrRole)
    if now_index == 1 then
        for i = 1, #config['ItemList_'..roleRace], 2 do
            local count = #GradeGiftUI.itemList
            local name = config['ItemList_'..roleRace][i]
            local num = config['ItemList_'..roleRace][i + 1]
            table.insert(GradeGiftUI.itemList,count + 1 , {itemName = name,itemNum = num})
        end
    else
        if config["PetList"] then
            for i = 1, #config["PetList"], 1 do
                local name = config["PetList"][i]
                table.insert(GradeGiftUI.itemList,i,{itemName = name,itemNum = 1,isPet = true})
            end
        elseif config["GuardList"] then
            for i = 1, #config["GuardList"], 1 do
                local name = config["GuardList"][i]
                table.insert(GradeGiftUI.itemList,i,{itemName = name,itemNum = 1,isGuard = true})
            end
        end
        for i = 1, #config['ItemList'], 2 do
            local count = #GradeGiftUI.itemList
            local name = config['ItemList'][i]
            local num = config['ItemList'][i + 1]
            table.insert(GradeGiftUI.itemList,count + 1 , {itemName = name,itemNum = num})
        end
    end
    local scroll = _gt.GetUI("itemSrc")
    GUI.LoopScrollRectSetTotalCount(scroll, #GradeGiftUI.itemList)
    GUI.LoopScrollRectRefreshCells(scroll)

    local modelId = ''
    local camereData = ''

    if now_index == 1 then
        local weaponName = GradeGiftUI.itemList[1]["itemName"]
		if string.find(weaponName, "#") then
			weaponName = string.split(weaponName, "#")[1]
		end
        local weaponData = SETTING.GetOnceWeaponByKey1(tostring(DB.GetOnceItemByKey2(weaponName).ModelRole1))
        modelId = tostring(weaponData.ResKey)
        camereData =  GradeGift_Camere_Data[now_index]['show'..(roleRace-30)]
    elseif now_index == 2 then
        local petName = GradeGiftUI.itemList[1]["itemName"]
        local petData = DB.GetOncePetByKey2(petName)
        modelId = tostring(petData.Model)
        camereData = GradeGift_Camere_Data[now_index]['camereData']
    elseif now_index == 3 then
        local guardName = GradeGiftUI.itemList[1]["itemName"]
        local guardData = DB.GetOnceGuardByKey2(guardName)
        modelId = tostring(guardData.Model)
        camereData = GradeGift_Camere_Data[now_index]['camereData']
    end
    GradeGiftUI.showModel(now_index,modelId,camereData)
end

function GradeGiftUI.OnShow(isInfight)
    local wnd = GUI.GetWnd("GradeGiftUI");
    if wnd then
        local showWnd = true
        if isInfight ~= nil then
            if isInfight == "true" then
                showWnd = false
            end
        end
        GUI.SetVisible(wnd, showWnd);
    end
end

function GradeGiftUI.OnClose()
    
end

function GradeGiftUI.OnExit()
    GradeGiftBtn.IsHaveList = nil
    GUI.CloseWnd("GradeGiftUI")
end

function GradeGiftUI.CreateItemIcon()
    local itemSrc = _gt.GetUI("itemSrc")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemSrc) + 1
    local itemIcon = ItemIcon.Create(debuffSrc, "itemIcon" .. curCount, 0, 0)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "GradeGiftUI", "OnItemClick")
    return itemIcon
end

function GradeGiftUI.RefreshItemIcon(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemIcon = GUI.GetByGuid(guid)
    local item = GradeGiftUI.itemList[index]
    local itemName = item.itemName
    if string.find(itemName, "#") then
        itemName = string.split(itemName, "#")[1]
    end
    if item.isPet then
        ItemIcon.BindPetKeyName(itemIcon,itemName)
    elseif item.isGuard then
        ItemIcon.BindGuardKeyName(itemIcon,itemName)
    else
        ItemIcon.BindItemKeyName(itemIcon,itemName)
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, item.itemNum)
    end
    GUI.SetData(itemIcon,"Index",index)
end

function GradeGiftUI.ShowPetInfo()
    test(GradeGiftUI.ShowPetGUID)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "QueryPet", GradeGiftUI.ShowPetGUID)
end

function GradeGiftUI.OnItemClick(guid)
    local itemIcon = GUI.GetByGuid(guid);
    local index = tonumber(GUI.GetData(itemIcon,"Index"));
    local item = GradeGiftUI.itemList[index]
    test(item.itemName)
    if item.isPet then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGradePresent", "GetGradePresentPetGUID",index)
    elseif item.isGuard then
        local guardData = DB.GetOnceGuardByKey2(item.itemName)
        if not GlobalProcessing then
            require "GlobalProcessing"
        end
        GlobalProcessing.ShowGuardInfo(guardData.Id)
    else
        local panelBg = _gt.GetUI("panelBg")
        local itemTips=Tips.CreateByItemKeyName(item.itemName,panelBg,"itemTips",-250,0)
        UILayout.SetSameAnchorAndPivot(itemTips, UILayout.Center);
    end
end

function GradeGiftUI.showModel(now_index,modelId,camereData)
    local lastModel1 = _gt.GetUI("model1")
    local lastModel2 = _gt.GetUI("model2")
    local lastModel3 = _gt.GetUI("model3")
    local model = nil
    local ssrPic = _gt.GetUI("ssrPic")
    local modelParent = _gt.GetUI("modelParent")

    GUI.SetVisible(lastModel1,false)
    GUI.SetVisible(lastModel2,false)
    GUI.SetVisible(lastModel3,false)
    GUI.SetVisible(ssrPic,false)
    
    if now_index == 1 and lastModel1 ~= nil then
        model = lastModel1
    elseif now_index == 2 and lastModel2 ~= nil then
        model = lastModel2
    elseif now_index == 3 and lastModel3 ~= nil then
        model = lastModel3
    else
        if now_index == 1 then
            model = GUI.RawImageChildCreate(modelParent,true,"model"..now_index,modelId,0,0)
        else
            model = GUI.RawImageChildCreate(modelParent,true,"model"..now_index,nil,0,0)
            GUI.RawImageChildSetModelID(model,modelId)
        end
        _gt.BindName(model,"model"..now_index)
        GUI.SetAnchor(model,UIAnchor.Center)
        GUI.SetPivot(model,UIAroundPivot.Center)
        GUI.SetIsRaycastTarget(model, false)
    end
    
    GUI.SetLocalPosition(model,0,0,0)
    GUI.RawImageChildSetModleRotation(model,UIDefine.Vector3Zero)
    GUI.SetLocalScale(model,0.7,0.7,0.7)
    if now_index ~= 1 then
        GUI.ReplaceWeapon(model,0,eRoleMovement.STAND_W1,0)
        if now_index == 3 then
            if ssrPic == nil then
                local panelBg = _gt.GetUI("panelBg")
                local localssrPic = GUI.ImageCreate(panelBg, "ssrPic", "1800714050", -60,-210)
                GUI.SetColor(localssrPic,Color.New(255/255,228/255,6/255,255/255))
                GUI.SetAnchor(localssrPic,UIAnchor.Center);
                GUI.SetPivot(localssrPic,UIAroundPivot.Center);
                _gt.BindName(localssrPic,"ssrPic")
            else
                GUI.SetVisible(ssrPic,true)
            end
        end
    end
    GUI.SetVisible(model,true)
    GUI.RawImageSetCameraConfig(modelParent, camereData)
end