--转职角色Model展示
local GetRoleTipUI = {}
_G.GetRoleTipUI = GetRoleTipUI
local _gt = UILayout.NewGUIDUtilTable()
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local CurModelIndex = 1
local RoleAndSchoolData = {}
local ShowModelTimer = nil
local AutoShowAnimationFlag = 1

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

local SchoolBigPic =
{  [31] = 1801205170,
   [32] = 1801205180,
   [33] = 1801205190,
   [34] = 1801205200,
   [35] = 1801205210,
   [36] = 1801205220,
}

function GetRoleTipUI.Main(parameter)
    local wnd = GUI.WndCreateWnd("GetRoleTipUI", "GetRoleTipUI", 0, 0)

    local panelCover = GUI.ImageCreate(wnd, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)


    local panelBg = GUI.ImageCreate(wnd, "panelBg", "1800229060", 0, -15)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)

    local title = GUI.ImageCreate(panelBg, "title", "1801205230", 0, 90)
    UILayout.SetSameAnchorAndPivot(title, UILayout.Top)
    _gt.BindName(title, "title")

    local model = GUI.RawImageCreate(panelBg, false, "model", "", 0, 110, 2, false, 550, 550)
    _gt.BindName(model, "model")
    model:RegisterEvent(UCE.Drag)
    GUI.AddToCamera(model)
    GUI.RawImageSetCameraConfig(model, "(1.65,1.3,2),(-0.04464257,0.9316535,-0.1226545,-0.3390941),True,5,0.01,1.25,1E-05")
    model:RegisterEvent(UCE.PointerClick)

    local roleModel = GUI.RawImageChildCreate(model, true, "roleModel", "", 0, 0)
    _gt.BindName(roleModel, "roleModel")
    GUI.BindPrefabWithChild(model, GUI.GetGuid(roleModel))
    GUI.RegisterUIEvent(roleModel, ULE.AnimationCallBack, "GetRoleTipUI", "OnAnimationCallBack")

    local LeftRoleImage = GUI.ImageCreate(model, "LeftRoleImage", roleSpriteInfo[31][1], -290, -75)
    _gt.BindName(LeftRoleImage, "LeftRoleImage")

    local RightSchoolImage = GUI.ImageCreate(model, "RightSchoolImage", "1800102030", 280, -230)
    _gt.BindName(RightSchoolImage, "RightSchoolImage")

    GUI.ImageCreate(RightSchoolImage,"cloud", "1800102021", 0, 0 )

    local SchoolTextImage =  GUI.ImageCreate(RightSchoolImage,"name_Sprite", SchoolBigPic[32], 0, 70)
    SetAnchorAndPivot(SchoolTextImage, UIAnchor.Top, UIAroundPivot.Top)
    _gt.BindName(SchoolTextImage,"SchoolTextImage")

    local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800502050", 0,100,Transition.ColorTint,"",60,60,false)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "GetRoleTipUI", "Next")
end

function GetRoleTipUI.OnShow(parameter)
    AutoShowAnimationFlag = 1
    CurModelIndex = 1
    RoleAndSchoolData = {}

    local schoolId = tonumber(string.split(parameter, "#")[1])
    local roleId = tonumber(string.split(parameter, "#")[2])

    table.insert(RoleAndSchoolData,{RoleId = roleId , SchoolId=schoolId})

    if #RoleAndSchoolData>=1 then
        GetRoleTipUI.Refresh()
    end

    local wnd = GUI.GetWnd("GetRoleTipUI")
    if wnd == nil then
        return
    end
    if CL.GetFightState() then
        GUI.SetVisible(wnd, false)
        return
    end
    GUI.SetVisible(wnd, true)
end

function GetRoleTipUI.Refresh()
    if #RoleAndSchoolData <= 0 then
        GetRoleTipUI.OnExit()
    end

    local roleModel = _gt.GetUI("roleModel")
    local LeftRoleImage = _gt.GetUI("LeftRoleImage")
    local RightSchoolImage = _gt.GetUI("RightSchoolImage")
    local SchoolTextImage = _gt.GetUI("SchoolTextImage")

    local roleId = tonumber(RoleAndSchoolData[1].RoleId)
    local schoolId = tonumber(RoleAndSchoolData[1].SchoolId)

    local roleDB = DB.GetRole(roleId)
    local schoolDB = DB.GetSchool(schoolId)
    ModelItem.Bind(roleModel, tonumber(roleDB.Model),0,0,eRoleMovement.ATTSTAND_W1)

    GUI.ImageSetImageID(LeftRoleImage,roleSpriteInfo[roleId][2])
    GUI.ImageSetImageID(RightSchoolImage,tostring(schoolDB.BigIcon))

    GUI.ImageSetImageID(SchoolTextImage,SchoolBigPic[schoolId])
    GetRoleTipUI.AutoShowAnimation()
end

function GetRoleTipUI.AutoShowAnimation()
    ShowModelTimer = Timer.New(GetRoleTipUI.AutoShowAnimationFunc, 1, 4)
    ShowModelTimer:Start()
end

function GetRoleTipUI.AutoShowAnimationFunc()
    if next(RoleAndSchoolData) == nil  then
        return
    end
    local roleModel = _gt.GetUI("roleModel")
    --第2秒播放动作动画
    if AutoShowAnimationFlag == 2 then
        local roleId = tonumber(RoleAndSchoolData[1].RoleId)
        ModelItem.BindRoleId(roleModel,roleId,eRoleMovement.MAGIC_W1,roleSpriteInfo[roleId][5])

    elseif AutoShowAnimationFlag == 4 then--第4秒则关闭界面/或者显示下一个
        GetRoleTipUI.Next()
    end
    AutoShowAnimationFlag = AutoShowAnimationFlag + 1
end

function GetRoleTipUI.Next()
    table.remove(RoleAndSchoolData,1)
    if #RoleAndSchoolData<=0 then
        GetRoleTipUI.OnExit()
    else
        CurModelIndex = CurModelIndex + 1
        GetRoleTipUI.Show()
    end
end

function GetRoleTipUI.OnExit()
    GUI.DestroyWnd("GetRoleTipUI")
end