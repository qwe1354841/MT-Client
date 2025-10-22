local RoleTransferUI = {}
_G.RoleTransferUI = RoleTransferUI
local _gt = UILayout.NewGUIDUtilTable()
local RoleSex = 1
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SchoolTransferId = 0
local RoleTransferId = 0
local TransferSchool = {}
local TransferRole = {}

-----------------颜色----------------------
local colorOrange = Color.New(255/255, 101/255, 0/255, 255/255)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorYellow = Color.New(141 / 255, 93 / 255, 44 / 255, 255 / 255)
local colorRed = Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255)

local roleSpriteInfo = {
    -- 谪剑仙
    [31] = { "1800107010", "1800104010", "600001779", "(0.6719999,2.4,-3.2528),(0,0,0,1),True,5,0.42,4.65,60",204 },
    ----飞翼姬
    [32] = { "1800107020", "1800104020", "600001842", "(0.6719999,2.4,-3.2528),(0,0,0,1),True,5,0.42,4.65,60",210 },
    --烟云客
    [33] = { "1800107030", "1800104030", "600001989", "(0.6719999,2.65,-3.2528),(0,0,0,1),True,5,0.42,4.65,60" ,202},
    -- 冥河使
    [34] = { "1800107040", "1800104040", "600001982", "(0.6719999,2.4,-3.2528),(0,0,0,1),True,5,0.42,4.65,60",203 },
    -- 阎魔令
    [35] = { "1800107050", "1800104050", "600001995", "(0.6719999,2.4,-3.2528),(0,0,0,1),True,5,0.42,4.65,60" ,201},
    -- 雨师君
    [36] = { "1800107060", "1800104060", "600001880", "(0.6719999,2.4,-3.2528),(0,0,0,1),True,5,0.42,4.65,60",205 },
    -- 傲红莲
    [38] = { "1800107080", "1800104080", "600001885", "(0.64,2.48,-3.2528),(0,0,0,1),True,5,0.42,4.27,60" ,206},
    --神霄卫
    [37] = { "1800107070", "1800104070", "600001921", "(0.64,2.48,-3.2528),(0,0,0,1),True,5,0.42,4.27,60" ,206},
    -- 花弄影
    [39] = { "1800107090", "1800104090", "600001837", "(0.64,2.48,-3.2528),(0,0,0,1),True,5,0.42,4.27,60",207 },
    -- 青丘狐
    [40] = { "1800107100", "1800104100", "3000001490", "(0.64,2.48,-3.2528),(0,0,0,1),True,5,0.42,4.27,60",208 },
    -- 海鲛灵
    [41] = { "1800107110", "1800104110", "600001956", "(0.64,2.48,-3.2528),(0,0,0,1),True,5,0.42,4.27,60",211 },
    -- 凤凰仙
    [42] = { "1800107120", "1800104120", "600001959", "(0.64,2.48,-3.2528),(0,0,0,1),True,5,0.42,4.27,60" ,212},
}

function RoleTransferUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()

    local wnd = GUI.WndCreateWnd("RoleTransferUI", "RoleTransferUI", 0, 0)
    _gt.BindName(wnd,"RoleTransferUIWnd")
    local panelBg = UILayout.CreateFrame_WndStyle2(wnd, "转职", 950, 620, "RoleTransferUI", "OnExit", _gt,true)

    RoleTransferUI.PanelBgRecord()

    local modelBg = GUI.ImageCreate(panelBg, "modelBg", "1800221230", 0, -35);
    UILayout.SetSameAnchorAndPivot(modelBg, UILayout.Center);

    local pedestal = GUI.ImageCreate(modelBg, "pedestal", "1800600210", 0, 150);
    UILayout.SetSameAnchorAndPivot(pedestal, UILayout.Center)

    local shadow = GUI.ImageCreate(pedestal, "shadow", "1800400240", 0, -16);
    UILayout.SetSameAnchorAndPivot(shadow, UILayout.Center);

    local raceLabel = GUI.ImageCreate(modelBg, "raceLabel", roleSpriteInfo[31][2], 150, -70,false,100,280);
    UILayout.SetSameAnchorAndPivot(raceLabel, UILayout.Center);
    _gt.BindName(raceLabel, "raceLabel")

    local modelRoot = GUI.RawImageCreate(modelBg, true, "modelRoot", nil, 0, -20, 3, false, 600, 600)
    _gt.BindName(modelRoot, "modelRoot")
    GUI.AddToCamera(modelRoot)
    modelRoot:RegisterEvent(UCE.Drag)
    modelRoot:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(modelRoot, UCE.PointerClick, "RoleTransferUI", "OnModelClick")

    local wheel = GUI.ImageCreate(panelBg, "wheel", "1800100011", -390, 25, false, 160, 580);
    UILayout.SetSameAnchorAndPivot(wheel, UILayout.Center);
    _gt.BindName(wheel, "wheel")

    RoleTransferUI.SchoolTable()

    local shor = -50 + (110 / #RoleTransferUI.raceDatas) / 2
    local radi = 322

    for i = 1, #RoleTransferUI.raceDatas do
        local hor = shor + (i - 1) * (100 / #RoleTransferUI.raceDatas)
        local x = radi * GlobalUtils.GetPreciseDecimal(math.cos(math.rad(hor)), 2) - 190
        local y = radi * GlobalUtils.GetPreciseDecimal(math.sin(math.rad(hor)), 2)

        --左边选项
        local raceItem = GUI.ButtonCreate(wheel, "raceItem" .. i, "1800600340", x, y, Transition.ColorTint);
        GUI.SetData(raceItem, "Index", i);
        GUI.RegisterUIEvent(raceItem, UCE.PointerClick, "RoleTransferUI", "OnRaceItemClick")

        local raceIcon = GUI.ButtonCreate(raceItem, "raceIcon", tostring(RoleTransferUI.raceDatas[i].BigIcon), -50, 0, Transition.ColorTint, "", 90, 90, false);
        GUI.SetData(raceIcon, "Index", i)
        UILayout.SetSameAnchorAndPivot(raceIcon,UILayout.Left)
        GUI.RegisterUIEvent(raceIcon, UCE.PointerClick, "RoleTransferUI", "OnRaceItemClick")

        local raceNameText = GUI.CreateStatic(raceItem, "raceNameText", RoleTransferUI.raceDatas[i].Name, 20, 0, 100, 35)
        GUI.StaticSetFontSize(raceNameText, UIDefine.FontSizeM)
        GUI.SetColor(raceNameText, UIDefine.WhiteColor);
        GUI.StaticSetAlignment(raceNameText, TextAnchor.MiddleLeft)
    end


    local headBg1 = GUI.ImageCreate(panelBg, "headBg1", "1801401100", 340, -215,false,240,35);
    UILayout.SetSameAnchorAndPivot(headBg1, UILayout.Center);
    local flower = GUI.ImageCreate(headBg1, "flower", "1800107140", 70, 10);
    UILayout.SetSameAnchorAndPivot(flower, UILayout.Center);
    local text = GUI.CreateStatic(headBg1, "text", "请选择角色", 0, 0, 200, 35);
    GUI.StaticSetFontSize(text, UIDefine.FontSizeM)
    GUI.SetColor(text, UIDefine.WhiteColor);
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);
    UILayout.SetSameAnchorAndPivot(text, UILayout.Center)

    for i = 1, 2 do
        local roleItem = GUI.ButtonCreate(panelBg, "roleItem"..i, roleSpriteInfo[i + 30][1], 340, -135+(i-1)*105,Transition.ColorTint, "", 90, 90, false);
        UILayout.SetSameAnchorAndPivot(roleItem, UILayout.Center);
        _gt.BindName(roleItem, "roleItem"..i)
        GUI.SetData(roleItem,"Index",i);
        GUI.RegisterUIEvent(roleItem, UCE.PointerClick, "RoleTransferUI", "OnRoleItemClick")

        --右边选择框
        local selected = GUI.ImageCreate(roleItem, "selected", "1800107130", 0, 0,false,135,90);
        GUI.SetColor(selected,UIDefine.OrangeColor)
    end



    local headBg2 = GUI.ImageCreate(panelBg, "headBg2", "1801401100", 340, 50,false,240,35);
    UILayout.SetSameAnchorAndPivot(headBg2, UILayout.Center);
    local flower = GUI.ImageCreate(headBg2, "flower", "1800107140", 70, 10);
    UILayout.SetSameAnchorAndPivot(flower, UILayout.Center);
    local text = GUI.CreateStatic(headBg2, "text", "转换说明", 0, 0, 200, 35);
    GUI.StaticSetFontSize(text, UIDefine.FontSizeM)
    GUI.SetColor(text, UIDefine.WhiteColor);
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);
    UILayout.SetSameAnchorAndPivot(text, UILayout.Center);

    local raceIcon = GUI.ImageCreate(panelBg, "raceIcon", tostring(RoleTransferUI.raceDatas[1].BigIcon), 255, 105, false, 80, 80)
    _gt.BindName(raceIcon, "raceIcon")
    GUI.SetAnchor(raceIcon, UIAnchor.Center)
    GUI.SetPivot(raceIcon, UIAroundPivot.Center)

    local cloudBg = GUI.ImageCreate(raceIcon, "cloudBg", "1800102021", 0, 0)
    UILayout.SetSameAnchorAndPivot(cloudBg, UILayout.Center)

    --门派名字
    local raceName = GUI.CreateStatic(raceIcon, "raceName",RoleTransferUI.raceDatas[1].Name, 85, 0, 100, 35)
    GUI.StaticSetFontSize(raceName, UIDefine.FontSizeL)
    UILayout.SetSameAnchorAndPivot(raceName, UILayout.Left)
    GUI.StaticSetAlignment(raceName,TextAnchor.MiddleLeft)
    GUI.SetColor(raceName,UIDefine.WhiteColor)

    --门派介绍
    local desInfo = GUI.CreateStatic(raceIcon, "desInfo","介绍", 70, 90, 270, 120)
    UILayout.SetSameAnchorAndPivot(desInfo, UILayout.Top)
    GUI.StaticSetFontSize(desInfo,  UIDefine.FontSizeS)
    GUI.SetColor(desInfo,UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(desInfo, TextAnchor.UpperLeft)


    --转职记录
    local TransferRecord = GUI.ButtonCreate(desInfo, "TransferRecord","1800402110", 78, 105, Transition.ColorTint,"",125, 44, false)
    GUI.RegisterUIEvent(TransferRecord, UCE.PointerClick, "RoleTransferUI", "OnTransferRecordClick")

    local TransferUnderLine = GUI.CreateStatic(TransferRecord, "TransferUnderLine","转换记录", -5, -7, 114, 30)
    UILayout.SetSameAnchorAndPivot(TransferUnderLine, UILayout.BottomRight)
    GUI.StaticSetFontSize(TransferUnderLine,  UIDefine.FontSizeM)
    GUI.SetColor(TransferUnderLine,UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(TransferUnderLine, TextAnchor.MiddleCenter)
    GUI.SetColor(TransferUnderLine,colorDark)


    local LeftItemIcon=ItemIcon.Create(panelBg,"LeftItemIcon",-45,195)
    GUI.RegisterUIEvent(LeftItemIcon, UCE.PointerClick, "RoleTransferUI", "OnLeftItemIconClick")

    local RightItemIcon=ItemIcon.Create(panelBg,"RightItemIcon",45,195)
    local line1 = GUI.ImageCreate(LeftItemIcon, "line1", "1800700150", -85, -58,false,150,10)
    local line2 = GUI.ImageCreate(LeftItemIcon, "line2", "1800700290", 175, -58,false,150,10)

    local desText = GUI.CreateStatic(LeftItemIcon, "desText","转换消耗", 45, -58, 150, 30)
    UILayout.SetSameAnchorAndPivot(desText, UILayout.Center)
    GUI.StaticSetAlignment(desText, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(desText,  UIDefine.FontSizeM)
    GUI.SetColor(desText,UIDefine.BrownColor)
    _gt.BindName(LeftItemIcon, "LeftItemIcon")
    _gt.BindName(RightItemIcon, "RightItemIcon")

    GUI.RegisterUIEvent(RightItemIcon, UCE.PointerClick, "RoleTransferUI", "OnRightItemIconClick")

    --Tips
    local tipBtn = GUI.ButtonCreate( panelBg, "tipBtn", "1800702030", -160, 80, Transition.ColorTint, "")
    SetAnchorAndPivot(tipBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick , "RoleTransferUI", "OnTipBtnClick")
    _gt.BindName(tipBtn,"tipBtn")

    local transferBtn = GUI.ButtonCreate(panelBg, "transferBtn", "1800402090", 0, 268, Transition.ColorTint, "确定转换", 150, 47, false);
    GUI.SetIsOutLine(transferBtn, true);
    GUI.ButtonSetTextFontSize(transferBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(transferBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(transferBtn,UIDefine.OutLine_GreenColor);
    GUI.SetOutLine_Distance(transferBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(transferBtn, UCE.PointerClick, "RoleTransferUI", "OnTransferBtnClick")
end

function RoleTransferUI.OnShow(parameter)
    GUI.SetVisible(GUI.GetWnd("RoleTransferUI"), true)
    RoleTransferUI.SchoolTable() --门派职业选择表
    RoleTransferUI.InitData()
    RoleTransferUI.Register()

    for i = 1, #RoleTransferUI.raceDatas do --门派循环

        for j = 1, #RoleTransferUI.raceDatas[i].RoleIds do --人物Role循环

            if  RoleTransferUI.raceDatas[i].RoleIds[j] == CL.GetRoleTemplateID() and RoleTransferUI.raceDatas[i].Id == CL.GetIntAttr(RoleAttr.RoleAttrJob1) then --如果门派里的某个role等于就取
                RoleTransferUI.raceIndex = i
                RoleTransferUI.roleIndex =j
                SchoolTransferId = tonumber(RoleTransferUI.raceDatas[i].Id)
                RoleTransferId = tonumber(RoleTransferUI.raceDatas[i].RoleIds[j])
            end
        end
    end
end

function RoleTransferUI.PanelBgRecord()
    local wnd = _gt.GetUI("RoleTransferUIWnd")
    local panelBg = UILayout.CreateFrame_WndStyle2_WithoutCover(wnd, "转换记录", 720, 620, "RoleTransferUI", "OnClose", _gt,false)
    GUI.SetVisible(panelBg,false)
    _gt.BindName(panelBg,"RecordPanelBg")

    local RecordBg = GUI.ImageCreate(panelBg, "itemListBg", "1800400200", 20, 60, false, 680, 540)
    GUI.SetAnchor(RecordBg, UIAnchor.TopLeft)
    GUI.SetPivot(RecordBg, UIAroundPivot.TopLeft)


    local text1 = GUI.CreateStatic(RecordBg, "text1", "你曾经加入过的门派:", 40, 20, 260, 35, "system", true, false);
    SetAnchorAndPivot(text1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(text1, 24)
    GUI.SetColor(text1, colorDark)

    local schoolScr = GUI.ScrollRectCreate(RecordBg,"schoolScr", 30, 60, 620, 160, 0, true, Vector2.New(85, 85),  UIAroundPivot.Top, UIAnchor.Top);
    _gt.BindName(schoolScr,"schoolScr")
    GUI.ScrollRectSetChildSpacing(schoolScr, Vector2.New(20, 0))

    for i = 1, 6  do
        local schoolBg = GUI.ImageCreate(schoolScr,"schoolBg"..i, "1800201110", 0, 0)

        local icon = GUI.ImageCreate(schoolBg,"icon", "3400400001", 5, 5,  false, 75, 75)
        GUI.SetAnchor(icon, UIAnchor.Center)
        GUI.SetPivot(icon, UIAroundPivot.Center)
        GUI.ImageSetGray(icon, true)

        --判断当前门派
        local current = GUI.ImageCreate(schoolBg,"current", "1801208600", 0, 0)
        GUI.SetAnchor(icon, UIAnchor.TopLeft)
        GUI.SetPivot(icon, UIAroundPivot.TopLeft)
        GUI.SetVisible(current, true)

        local name = GUI.CreateStatic(schoolBg,"name", "门派名称", 0, 45,  120, 30)
        GUI.StaticSetFontSize(name, 22)
        GUI.SetColor(name, colorYellow)
        GUI.StaticSetAlignment(name,TextAnchor.MiddleCenter)
        GUI.SetAnchor(name, UIAnchor.Center)
        GUI.SetPivot(name, UIAroundPivot.Top)

        local inactive = GUI.CreateStatic(schoolBg,"inactive", "(未激活)", 0, 85,  120, 30)
        GUI.StaticSetFontSize(inactive, 20)
        GUI.SetColor(inactive, colorRed)
        GUI.StaticSetAlignment(inactive,TextAnchor.MiddleCenter)
        GUI.SetAnchor(inactive, UIAnchor.Center)
        GUI.SetPivot(inactive, UIAroundPivot.Center)
    end

    local text2 = GUI.CreateStatic(RecordBg,"text2", "你曾经使用过的角色:", -170, -30,  260, 35, "system", true, false);
    GUI.StaticSetFontSize(text2, 24)
    SetAnchorAndPivot(text2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(text2, colorDark)

    local RoleScr = GUI.ScrollRectCreate(panelBg,"RoleScr", 0, 90, 620, 160, 0, true, Vector2.New(85, 85),  UIAroundPivot.Top, UIAnchor.Top);
    SetAnchorAndPivot(text2, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(RoleScr,"RoleScr")
    GUI.ScrollRectSetChildSpacing(RoleScr, Vector2.New(20, 0))

    for i = 1, 6 do
        local roleBg = GUI.ImageCreate(RoleScr,"roleBg" .. i, "1800201110", 0, 0)

        local icon = GUI.ImageCreate(roleBg,"icon", "3400400001", 5, 5,  false, 75, 75)
        GUI.SetAnchor(icon, UIAnchor.Center)
        GUI.SetPivot(icon, UIAroundPivot.Center)
        GUI.ImageSetGray(icon, true)

        local current = GUI.ImageCreate(roleBg,"current", "1801208600", -20, -20)
        GUI.SetAnchor(icon, UIAnchor.TopLeft)
        GUI.SetPivot(icon, UIAroundPivot.TopLeft)
        GUI.SetVisible(current,false)

        local name = GUI.CreateStatic(roleBg,"name", "三位数", 0, 60,  120, 30);
        GUI.StaticSetFontSize(name, 22)
        GUI.SetColor(name, colorYellow)
        GUI.StaticSetAlignment(name,TextAnchor.MiddleCenter)
        GUI.SetAnchor(name, UIAnchor.Center);
        GUI.SetPivot(name, UIAroundPivot.Center);

        local inactive = GUI.CreateStatic(roleBg,"inactive", "(未激活)", 0, 85,  120, 30);
        GUI.StaticSetFontSize(inactive, 20)
        GUI.SetColor(inactive, colorRed)
        GUI.StaticSetAlignment(inactive,TextAnchor.MiddleCenter)
        GUI.SetAnchor(inactive, UIAnchor.Center)
        GUI.SetPivot(inactive, UIAroundPivot.Center)
    end
end

--转换记录点击事件
function RoleTransferUI.OnTransferRecordClick()
    local RecordPanelBg = _gt.GetUI("RecordPanelBg")
    GUI.SetVisible(RecordPanelBg,true)
end

function RoleTransferUI.TransferTable()
    local RoleSex = RoleSex
    local RoleIds = DB.GetRoleAllKeys()

    for i = 1, #RoleTransferUI.raceDatas do
        local TransferStatus = tonumber(CL.GetIntCustomData("ChangeOccu_UsedSchool_"..tostring(RoleTransferUI.raceDatas[i].Id)))
        local SchoolStatus = nil
        if TransferStatus == 0 then
            SchoolStatus = "未激活"
        else
            SchoolStatus = "激活"
        end
        local SchoolTable = {
            Name = RoleTransferUI.raceDatas[i].Name,
            BigIcon = tostring(RoleTransferUI.raceDatas[i].BigIcon),
            Status = SchoolStatus,
            SchoolConsume = RoleTransferUI.SchoolConsume[TransferStatus + 1][1],
            SchoolConsumeNum = RoleTransferUI.SchoolConsume[TransferStatus + 1][2]
        }
        TransferSchool[tonumber(RoleTransferUI.raceDatas[i].Id)] = SchoolTable
    end
    for i = 0, RoleIds.Count-1 do
        local RoleDB = DB.GetRole(RoleIds[i])
        if RoleSex == RoleDB.Sex then
            local TransferStatus = tonumber(CL.GetIntCustomData("ChangeOccu_UsedRole_"..tostring(RoleDB.Id)))
            local RoleStatus = nil
            if TransferStatus == 0 then
                RoleStatus = "未激活"
            else
                RoleStatus = "激活"
            end
            local RoleTable = {
                RoleName = RoleDB.RoleName,
                Head = tostring(RoleDB.Head),
                Status = RoleStatus,
                RoleConsume = RoleTransferUI.RoleConsume[TransferStatus + 1][1],
                RoleConsumeNum = RoleTransferUI.RoleConsume[TransferStatus + 1][2]
            }
            TransferRole[tonumber(RoleDB.Id)] = RoleTable
        end
    end

end

function RoleTransferUI.SchoolTable()
    RoleTransferUI.raceDatas ={}
    RoleTransferUI.schoolDatas =  {}
    local schoolIds = DB.GetSchoolAllKeys()
    RoleSex = DB.GetRole(CL.GetRoleTemplateID()).Sex

    for i = 0, schoolIds.Count - 1 do
        local schoolDB = DB.GetSchool(schoolIds[i])
        local schoolData
        local SchoolRoleIds = {}
        for j = 1,#RoleTransferUI.schoolDatas do
            if RoleTransferUI.schoolDatas[j].Name == schoolDB.Name then
                schoolData = RoleTransferUI.schoolDatas[j]
                break
            end
        end

        if schoolData == nil then
            schoolData={
                Id = schoolDB.Id,
                Name=schoolDB.Name,
                BigIcon=schoolDB.BigIcon,
                RoleIds={
                    schoolDB.Role1,
                    schoolDB.Role2,
                    schoolDB.Role3,
                    schoolDB.Role4
                }
            }
            table.insert(RoleTransferUI.schoolDatas,schoolData)

            --新表建立性别role表
            for k = 1, 4 do
                local RoleId =  RoleTransferUI.schoolDatas[i+1].RoleIds[k]
                if tonumber(DB.GetRole(RoleId).Sex) == tonumber(RoleSex) then
                    table.insert(SchoolRoleIds,RoleId)
                end
            end
            local temp = {
                Id = RoleTransferUI.schoolDatas[i+1].Id,
                Name=RoleTransferUI.schoolDatas[i+1].Name,
                Icon = RoleTransferUI.schoolDatas[i+1].Icon,
                BigIcon=RoleTransferUI.schoolDatas[i+1].BigIcon,
                RoleIds = {
                    SchoolRoleIds[1],
                    SchoolRoleIds[2]
                }
            }
            table.insert(RoleTransferUI.raceDatas,temp)
        end
    end
    table.sort(RoleTransferUI.raceDatas,function (a,b)
        return a.Id < b.Id
    end)
end

function RoleTransferUI.OnLeftItemIconClick()
    local parent = GUI.GetWnd("RoleTransferUI")
    local SchoolItem = DB.GetOnceItemByKey2(RoleTransferUI.SchoolConsume[1][1])

    local LeftTips = Tips.CreateByItemId(SchoolItem.Id,parent,"LeftTips",0,0,50)
    GUI.SetData(LeftTips, "ItemId", SchoolItem.Id)
    UILayout.SetSameAnchorAndPivot(LeftTips, UILayout.Center)
    _gt.BindName(LeftTips,"LeftTips")

    local wayBtn = GUI.ButtonCreate(LeftTips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false)
    UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"RoleTransferUI","OnClickLeftTipsBtn")
    GUI.AddWhiteName(LeftTips, GUI.GetGuid(wayBtn))
end

function RoleTransferUI.OnClickLeftTipsBtn()
    local tip = _gt.GetUI("LeftTips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end

function RoleTransferUI.OnRightItemIconClick()
    local parent = GUI.GetWnd("RoleTransferUI")
    local RoleItem = DB.GetOnceItemByKey2(RoleTransferUI.RoleConsume[1][1])
    local RightTips = Tips.CreateByItemId(RoleItem.Id,parent,"RightTips",0,0,50)
    GUI.SetData(RightTips, "ItemId", RoleItem.Id)
    UILayout.SetSameAnchorAndPivot(RightTips, UILayout.Center)
    _gt.BindName(RightTips,"RightTips")

    local wayBtn = GUI.ButtonCreate(RightTips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false)
    UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"RoleTransferUI","OnClickRightTipsBtn")
    GUI.AddWhiteName(RightTips, GUI.GetGuid(wayBtn))
end

function RoleTransferUI.OnClickRightTipsBtn()
    local tip = _gt.GetUI("RightTips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end

function RoleTransferUI.OnTransferBtnClick()
    if tonumber(SchoolTransferId) == tonumber(CL.GetIntAttr(RoleAttr.RoleAttrJob1)) and tonumber(RoleTransferId) == tonumber(CL.GetRoleTemplateID()) then
        CL.SendNotify(NOTIFY.ShowBBMsg,"目标门派和角色与当前门派和角色完全一致，无需转换")
        return
    end
    CL.SendNotify(NOTIFY.SubmitForm,"FormChangeOccu","StartChange",SchoolTransferId,RoleTransferId,0)
end

function RoleTransferUI.OnModelClick()
    local roleId = RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].RoleIds[RoleTransferUI.roleIndex]
    local roleModel =_gt.GetUI("roleModel")
    math.randomseed(os.time())
    local index = math.random(2)
    local movements = { eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1 }
    ModelItem.BindRoleId(roleModel,roleId,movements[index],roleSpriteInfo[roleId][5])
end

function RoleTransferUI.OnAnimationCallBack(guid, action)
    if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
        return
    end

    local roleModel = GUI.GetByGuid(guid)
    local roleId = RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].RoleIds[RoleTransferUI.roleIndex]
    ModelItem.BindRoleId(roleModel,roleId,eRoleMovement.ATTSTAND_W1,roleSpriteInfo[roleId][5])
end

function RoleTransferUI.CreateOrRefreshModel(roleId)
    local modelRoot = _gt.GetUI("modelRoot")
    if modelRoot == nil then
        return
    end
    local roleModel = GUI.GetChild(modelRoot, "roleModel",false)
    if roleModel == nil then
        roleModel = GUI.RawImageChildCreate(modelRoot, false, "roleModel", "", 0, 0)
        _gt.BindName(roleModel, "roleModel")
        GUI.RegisterUIEvent(roleModel, ULE.AnimationCallBack, "RoleTransferUI", "OnAnimationCallBack")
    end
    GUI.RawImageSetCameraConfig(modelRoot, "(0,1.45,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,5,0.01,1.45,1E-05")
    GUI.BindPrefabWithChild(modelRoot, _gt.GetGuid("roleModel"))
    ModelItem.BindRoleId(roleModel,roleId,eRoleMovement.ATTSTAND_W1,roleSpriteInfo[roleId][5])

    local raceLabel = _gt.GetUI("raceLabel")
    GUI.ImageSetImageID(raceLabel,roleSpriteInfo[roleId][2])
end

function RoleTransferUI.InitData()

    RoleTransferUI.raceIndex = 1
    RoleTransferUI.roleIndex =1

end

function RoleTransferUI.OnTipBtnClick()
    local panelBg = GUI.TipsCreate(GUI.Get("RoleTransferUI/panelBg"), "Tips", 0, 0, 660, 300)
    GUI.SetIsRemoveWhenClick(panelBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(panelBg),false)
    local TipsText = GUI.CreateStatic(panelBg,"TipsText",RoleTransferUI.RoleTransferTips,0,15,620,420,"system", true)
    GUI.StaticSetFontSize(TipsText,22)
end

function RoleTransferUI.RefreshRecordItem()
    local schoolScr = _gt.GetUI("schoolScr")
    local RoleScr = _gt.GetUI("RoleScr")
    local schoolScrIndex = 1
    local RoleScrIndex = 1

    for k, v in pairs(TransferSchool) do
        local schoolBg = GUI.GetChild(schoolScr,"schoolBg"..schoolScrIndex)
        local icon = GUI.GetChild(schoolBg,"icon")
        local current = GUI.GetChild(schoolBg,"current")
        local name = GUI.GetChild(schoolBg,"name")
        local inactive = GUI.GetChild(schoolBg,"inactive")

        GUI.ImageSetImageID(icon,v.BigIcon)
        if tostring(v.Status) == "激活" then
            GUI.ImageSetGray(icon, false)
            GUI.SetVisible(inactive, false)
        else
            GUI.ImageSetGray(icon, true)
            GUI.SetVisible(inactive, true)
        end

        if tonumber(k) == tonumber(CL.GetIntAttr(RoleAttr.RoleAttrJob1)) then
            GUI.SetVisible(current, true)
        else
            GUI.SetVisible(current, false)
        end
        GUI.StaticSetText(name,v.Name)
        schoolScrIndex = schoolScrIndex + 1
    end

    for k, v in pairs(TransferRole) do
        local roleBg = GUI.GetChild(RoleScr,"roleBg"..RoleScrIndex)
        local icon = GUI.GetChild(roleBg,"icon")
        local current = GUI.GetChild(roleBg,"current")
        local name = GUI.GetChild(roleBg,"name")
        local inactive = GUI.GetChild(roleBg,"inactive")

        GUI.ImageSetImageID(icon,v.Head)
        if tostring(v.Status) == "激活" then
            GUI.ImageSetGray(icon, false)
            GUI.SetVisible(inactive, false)
        else
            GUI.ImageSetGray(icon, true)
            GUI.SetVisible(inactive, true)
        end
        if tonumber(k) == tonumber(CL.GetRoleTemplateID()) then
            GUI.SetVisible(current, true)
        else
            GUI.SetVisible(current, false)
        end
        GUI.StaticSetText(name,v.RoleName)
        RoleScrIndex = RoleScrIndex + 1
    end

end

function RoleTransferUI.Refresh()
    RoleTransferUI.TransferTable() --转换记录表
    RoleTransferUI.RefreshRecordItem() -- 刷新转换记录表

    local wheel = _gt.GetUI("wheel")
    for i = 1, #RoleTransferUI.raceDatas do
        local raceItem = GUI.GetChild(wheel, "raceItem" .. i)
        local raceIcon = GUI.GetChild(raceItem, "raceIcon")
        if i == RoleTransferUI.raceIndex then
            GUI.ButtonSetImageID(raceItem, "1800100110")
            GUI.SetScale(raceIcon, Vector3.New(1.1, 1.1, 1.1))
        else
            GUI.ButtonSetImageID(raceItem, "1800600340")
            GUI.SetScale(raceIcon, Vector3.New(1, 1, 1))
        end
    end

    for i = 1, 2 do
        local roleItem = _gt.GetUI("roleItem"..i)

        local roleId = RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].RoleIds[i]
        GUI.ButtonSetImageID(roleItem,roleSpriteInfo[roleId][1])
        local selected = GUI.GetChild(roleItem,"selected")
        GUI.SetVisible(selected,i==RoleTransferUI.roleIndex)

    end

    --门派信息
    local roleId = RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].RoleIds[RoleTransferUI.roleIndex]
    local SchoolId =  RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].Id
    local ShchoolInfo = DB.GetSchool(SchoolId).Info
    RoleTransferUI.CreateOrRefreshModel(roleId)

    local raceIcon =_gt.GetUI("raceIcon");
    GUI.ImageSetImageID(raceIcon,tostring(RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].BigIcon))

    local raceName = GUI.GetChild(raceIcon,"raceName")
    GUI.StaticSetText(raceName,RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].Name) --门派名称设置

    --门派Info内容
    local desInfo =  GUI.GetChild(raceIcon,"desInfo")--西海龙宫
    GUI.StaticSetText(desInfo,ShchoolInfo)

    RoleTransferUI.OnRefreshBag()

end

function RoleTransferUI.OnRefreshBag()
    --左边门派消耗的物品
    local SchoolItem = DB.GetOnceItemByKey2(RoleTransferUI.SchoolConsume[1][1])
    local LeftItemIcon =_gt.GetUI("LeftItemIcon")
    if tonumber(SchoolTransferId) == tonumber(CL.GetIntAttr(RoleAttr.RoleAttrJob1)) then
        ItemIcon.BindItemIdWithNum(LeftItemIcon,SchoolItem.Id, 0)
    else
        ItemIcon.BindItemIdWithNum(LeftItemIcon,SchoolItem.Id, TransferSchool[SchoolTransferId].SchoolConsumeNum)
    end

    --右边人物消耗的物品
    local RoleItem = DB.GetOnceItemByKey2(RoleTransferUI.RoleConsume[1][1])
    local RightItemIcon =_gt.GetUI("RightItemIcon")

    if tonumber(RoleTransferId) == tonumber(CL.GetRoleTemplateID()) then
        ItemIcon.BindItemIdWithNum(RightItemIcon,RoleItem.Id, 0)
    else
        ItemIcon.BindItemIdWithNum(RightItemIcon,RoleItem.Id, TransferRole[RoleTransferId].RoleConsumeNum)
    end
end

--左边门派选择按钮
function RoleTransferUI.OnRaceItemClick(guid)
    local index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "Index")) --第几个门派
    RoleTransferUI.raceIndex = index
    SchoolTransferId = tonumber(RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].Id)
    RoleTransferUI.roleIndex = 1
    RoleTransferId = tonumber(RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].RoleIds[RoleTransferUI.roleIndex])

    RoleTransferUI.Refresh()
end

--右边两个人物角色选择按钮
function RoleTransferUI.OnRoleItemClick(guid)
    local roleItem = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(roleItem,"Index"))
    RoleTransferUI.roleIndex = index
    RoleTransferId = tonumber(RoleTransferUI.raceDatas[RoleTransferUI.raceIndex].RoleIds[RoleTransferUI.roleIndex])
    RoleTransferUI.Refresh()
end

function RoleTransferUI.OnClose()
    local RecordPanelBg = _gt.GetUI("RecordPanelBg")
    GUI.SetVisible(RecordPanelBg,false)
end

function RoleTransferUI.OnExit()
    GUI.CloseWnd("RoleTransferUI")
    RoleTransferUI.UnRegister()
end

function RoleTransferUI.Register()
    CL.RegisterMessage(GM.RefreshBag,"RoleTransferUI","OnRefreshBag")
end

function RoleTransferUI.UnRegister()
    CL.UnRegisterMessage(GM.RefreshBag,"RoleTransferUI","OnRefreshBag")
end