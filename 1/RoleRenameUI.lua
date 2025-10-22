local RoleRenameUI = {}

_G.RoleRenameUI = RoleRenameUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

-- 人物改名界面
local colorWhite = Color.New(255/255, 246/255, 232/255, 255/255)
local colorOutline = Color.New(175/255, 96/255, 19/255, 255/255)
local fontSizeBtn = 26
RoleRenameUI.newName = "" ;
RoleRenameUI.type=1;
RoleRenameUI.roleGuid=nil;

local _gt = UILayout.NewGUIDUtilTable();
function RoleRenameUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable();
    local panel = GUI.WndCreateWnd("RoleRenameUI", "RoleRenameUI", 0, 0, eCanvasGroup.Normal)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)

    local panelCover = GUI.ImageCreate( panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover,true)      

    local width = 464
    local height = 280

    -- 底图
    local panelBg = GUI.ImageCreate( panel, "panelBg", "1800001120", 0, 0, false, width, height)
    SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)

    -- 左边装饰
    local pendant = GUI.ImageCreate( panelBg, "pendant", "1800007060", -20, -20)
    SetAnchorAndPivot(pendant, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 右侧关闭按钮
    local closeBtn = GUI.ButtonCreate( panelBg, "closeBtn", "1800002050", -10, 10, Transition.ColorTint)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "RoleRenameUI", "OnCloseBtnClick")

    -- 标题
    local titleBg = GUI.ImageCreate( panelBg, "titleBg", "1800001030", 0, 45)
    SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Center)
    local titleLabel = GUI.CreateStatic( titleBg, "titleLabel", "角色改名", 0, 0, 150, 35, "system", true, false)
    SetAnchorAndPivot(titleLabel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(titleLabel, 24)
    GUI.StaticSetAlignment(titleLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(titleLabel, Color.New(255/255, 246/255, 232/255, 255/255))
    _gt.BindName(titleLabel,"titleText")

    -- 输入框底图
    local inputAreaBg = GUI.ImageCreate( panelBg, "inputAreaBg", "1800400200", 0, 0, false, 412, 136)
    SetAnchorAndPivot(inputAreaBg, UIAnchor.Center, UIAroundPivot.Center)

    -- 确认
    local OKBtn = GUI.ButtonCreate( panelBg, "OKBtn", "1800402080", -30, -18, Transition.ColorTint, "")
    SetAnchorAndPivot(OKBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.RegisterUIEvent(OKBtn, UCE.PointerClick , "RoleRenameUI", "OnOKBtnClick")

    local OKBtnText = GUI.CreateStatic( OKBtn, "OKBtnText", "确认", 0, 0, 160, 47, "system", true)    
    SetAnchorAndPivot(OKBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(OKBtnText, 26)
    GUI.StaticSetAlignment(OKBtnText, TextAnchor.MiddleCenter)
    GUI.SetColor(OKBtnText, colorWhite)
    GUI.SetIsOutLine(OKBtnText, true)
    GUI.SetOutLine_Color(OKBtnText, colorOutline)
    GUI.SetOutLine_Distance(OKBtnText, 1)

    -- 关闭
    local cancelBtn = GUI.ButtonCreate( panelBg, "cancelBtn", "1800402080", 30, -18, Transition.ColorTint, "")
    SetAnchorAndPivot(cancelBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick , "RoleRenameUI", "OnCloseBtnClick")

    local cancelBtnText = GUI.CreateStatic( cancelBtn, "cancelBtnText", "取消", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(cancelBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(cancelBtnText, fontSizeBtn)
    GUI.StaticSetAlignment(cancelBtnText, TextAnchor.MiddleCenter)
    GUI.SetColor(cancelBtnText, colorWhite)
    GUI.SetIsOutLine(cancelBtnText, true)
    GUI.SetOutLine_Color(cancelBtnText, colorOutline)
    GUI.SetOutLine_Distance(cancelBtnText, 1)

    -- 输入框
    local input = GUI.EditCreate(panelBg, "input","1800001040", "请输入新的名称", 0, 0, Transition.ColorTint, "system", 0, 0, 40, 8)
    GUI.EditSetMaxCharNum(input, 14) -- 名字字符最多7个中文
    GUI.EditSetTextColor(input, UIDefine.BrownColor)
    GUI.SetPlaceholderTxtColor(input, UIDefine.GrayColor)
    GUI.EditSetLabelAlignment(input, TextAnchor.MiddleCenter)
    GUI.EditSetFontSize(input, 22)
    _gt.BindName(input,"input")
end

function RoleRenameUI.SetSelfRole()
    RoleRenameUI.type=1;
    local titleText =_gt.GetUI("titleText");
    GUI.StaticSetText(titleText,"角色改名")
end

function RoleRenameUI.SetPetGuid(petGuid)
    RoleRenameUI.type=2;
    RoleRenameUI.roleGuid=petGuid;
    local titleText =_gt.GetUI("titleText");
    GUI.StaticSetText(titleText,"宠物改名")
end

-- 侍从界面阵容改名
RoleRenameUI.set_team_index = function(guard_page_btn_guid)
    RoleRenameUI.type=3
    RoleRenameUI.guard_page_btn_guid = guard_page_btn_guid
    local titleText =_gt.GetUI("titleText");
    GUI.StaticSetText(titleText,"阵容改名")
end


-- 关闭按钮被点击
function RoleRenameUI.OnCloseBtnClick(key)
    GUI.DestroyWnd("RoleRenameUI")
end

-- 确认按钮被点击
function RoleRenameUI.OnOKBtnClick(key)
    local input = GUI.Get("RoleRenameUI/panelBg/input")
    if input == nil then
        return
    end
	  RoleRenameUI.newName = "";
    RoleRenameUI.newName = GUI.EditGetTextM(input)

    print(RoleRenameUI.type);
    print(RoleRenameUI.newName);

    --本地过滤条件
    local name = RoleRenameUI.newName
    print("len="..string.len(name))
    if string.len(name) == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请输入名字")
        return
    elseif string.len(name) > 18 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "名字长度过长，请重新输入")
        return
    elseif CL.IsHaveForbiddenWord(name) then
        CL.SendNotify(NOTIFY.ShowBBMsg, "名字中含有不合法字符，请重新输入")
        return
    end
    if string.find(name, "#") then
        CL.SendNotify(NOTIFY.ShowBBMsg, "名字中不能包含特殊字符")
        return
    end
	
    if RoleRenameUI.type==1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormChangeName", "PlayerChangeName",RoleRenameUI.newName)
    elseif RoleRenameUI.type==2 then
        print(tostring(RoleRenameUI.roleGuid));
        CL.SendNotify(NOTIFY.SubmitForm, "FormChangeName", "PetChangeName",tostring(RoleRenameUI.roleGuid),RoleRenameUI.newName)
    elseif RoleRenameUI.type == 3 then
        GuardUI.TeamTab_Bar_ChangeName_Click_Comfirm(RoleRenameUI.guard_page_btn_guid,RoleRenameUI.newName)
    end
end