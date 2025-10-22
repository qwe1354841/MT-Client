local FriendSystemSettingUI = {}
_G.FriendSystemSettingUI = FriendSystemSettingUI

-- 好友系统聊天设置

local colorDark = Color.New(102/255, 47/255, 22/255, 255/255)
local colorWhite = Color.New(255/255, 246/255, 232/255, 255/255)
local colorOutline = Color.New(175/255, 96/255, 19/255, 255/255)
local colorGray = Color.New(192/255, 192/255, 192/255, 255/255)
local fontSizeBtn = 24
local couldApply = false
local GUI = GUI
local _gt = UILayout.NewGUIDUtilTable()
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local test = print
local configBtns = 
{
    {"isFriendSee",     "个人信息仅好友可见"},
    {"noStrangerMsg",   "不接收陌生人消息"},
    {"newMsgRemind",    "新消息提示"},
    {"friendRemind",    "好友上线提示"},
    {"isAutoReply",     "自动回复信息"},
}

function FriendSystemSettingUI.Main(parameter)

    local panel = GUI.WndCreateWnd("FriendSystemSettingUI", "FriendSystemSettingUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)

    local panelCover = GUI.ImageCreate(panel,"panelCover", "1800400220", 0, 0,  false, 1360, 960)
    GUI.SetAnchor(panelCover,UIAnchor.Center)
    GUI.SetPivot(panelCover,UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)

    local width = 500
    local height = 320

    -- 底图
    local panelBg = GUI.ImageCreate(panel,"panelBg", "1800001120", 0, 0,  false, width, height)
    GUI.SetAnchor(panelBg, UIAnchor.Center)
    GUI.SetPivot(panelBg, UIAroundPivot.Center)

    -- 右侧关闭按钮
    local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800302120", 3, -3, Transition.ColorTint)
    GUI.SetAnchor(closeBtn, UIAnchor.TopRight)
    GUI.SetPivot(closeBtn, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FriendSystemSettingUI", "OnCloseBtnClick")

    -- 标题
    local titleBg = GUI.ImageCreate(panelBg, "titleBg", "1800001140", 0, 35, false, 268, 34)
    GUI.SetAnchor(titleBg, UIAnchor.Top)
    GUI.SetPivot(titleBg, UIAroundPivot.Center)


    local titleLabel = GUI.CreateStatic(titleBg,"titleLabel", "设置", 0, 0,  192, 30, "system", true, false)
    GUI.SetAnchor(titleLabel, UIAnchor.Center)
    GUI.SetPivot(titleLabel, UIAroundPivot.Center)
    GUI.StaticSetFontSize(titleLabel, 22)
    GUI.StaticSetAlignment(titleLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(titleLabel, Color.New(255/255, 246/255, 232/255, 255/255))

    local MessageCheck = GUI.CheckBoxExCreate(panelBg, "MessageCheck", "1800607150", "1800607151",25 , 60, false)
    UILayout.SetSameAnchorAndPivot(MessageCheck, UILayout.TopLeft)
    _gt.BindName(MessageCheck,"MessageCheck")

    local MessageShowget = GUI.CreateStatic(MessageCheck, "showGet", "自动回复信息", 50, 0, 180, 30)
    GUI.StaticSetFontSize(MessageShowget, 24)
    GUI.StaticSetAlignment(MessageShowget, TextAnchor.MiddleLeft)
    GUI.SetColor(MessageShowget, colorDark)
    GUI.SetIsRaycastTarget(MessageShowget, true)

    local FriendCheck = GUI.CheckBoxExCreate(panelBg, "FriendCheck", "1800607150", "1800607151",25 , 100, false)
    UILayout.SetSameAnchorAndPivot(FriendCheck, UILayout.TopLeft)
    _gt.BindName(FriendCheck,"FriendCheck")

    local FriendShowget = GUI.CreateStatic(FriendCheck, "showGet", "好友上线提示", 50, 0, 180, 30)
    GUI.StaticSetFontSize(FriendShowget, 24)
    GUI.StaticSetAlignment(FriendShowget, TextAnchor.MiddleLeft)
    GUI.SetColor(FriendShowget, colorDark)
    GUI.SetIsRaycastTarget(FriendShowget, true)

    -- 确认
    local OKBtn = GUI.ButtonCreate(panelBg,"OKBtn", "1800402110", 26, -24,  Transition.ColorTint, "确认", 122, 46, false)
    GUI.SetAnchor(OKBtn, UIAnchor.BottomLeft)
    GUI.SetPivot(OKBtn, UIAroundPivot.BottomLeft)
    GUI.ButtonSetTextFontSize(OKBtn, fontSizeBtn)
    GUI.ButtonSetTextColor(OKBtn, colorDark)
    GUI.RegisterUIEvent(OKBtn, UCE.PointerClick , "FriendSystemSettingUI", "OnOKBtnClick")

    -- 取消
    local cancelBtn = GUI.ButtonCreate(panelBg, "cancelBtn", "1800402110", 0, -24, Transition.ColorTint, "取消", 122, 46, false)
    GUI.SetAnchor(cancelBtn, UIAnchor.Bottom)
    GUI.SetPivot(cancelBtn, UIAroundPivot.Bottom)
    GUI.ButtonSetTextFontSize(cancelBtn, fontSizeBtn)
    GUI.ButtonSetTextColor(cancelBtn, colorDark)
    GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick , "FriendSystemSettingUI", "OnCloseBtnClick")

    -- 应用
    local applyBtn = GUI.ButtonCreate(panelBg,"applyBtn", "1800402110", -26, -24,  Transition.ColorTint, "应用", 122, 46, false)
    GUI.SetAnchor(applyBtn, UIAnchor.BottomRight)
    GUI.SetPivot(applyBtn, UIAroundPivot.BottomRight)
    GUI.ButtonSetTextFontSize(applyBtn, fontSizeBtn)
    GUI.ButtonSetTextColor(applyBtn, colorDark)
    GUI.RegisterUIEvent(applyBtn, UCE.PointerClick , "FriendSystemSettingUI", "OnApplyBtnClick")

    -- 输入框
    local searchInput = GUI.EditCreate(panelBg, "searchInput", "1800001040", "请输入自动回复内容", 0, 50,  10,5,Transition.ColorTint,"system", 460, 50)
    _gt.BindName(searchInput, "searchInput")
    GUI.EditSetLabelAlignment(searchInput, TextAnchor.MiddleLeft)
    GUI.EditSetTextColor(searchInput, colorDark)
    GUI.SetPlaceholderTxtColor(searchInput, colorGray)
    GUI.EditSetFontSize(searchInput,22)
    GUI.EditSetPlaceholderAlignment(searchInput, TextAnchor.MiddleLeft)
    _gt.BindName(searchInput,"ReplyContent")
end

function FriendSystemSettingUI.OnShow()
    local wnd = GUI.GetWnd("FriendSystemSettingUI")
    if wnd == nil then
        return
    end
    FriendSystemSettingUI.SendMessage()
end

function FriendSystemSettingUI.SendMessage()
    CL.SendNotify(NOTIFY.SubmitForm,"FormContact","GetAutoReplyContent")
    CL.SendNotify(NOTIFY.SubmitForm,"FormContact","IsLoginWarn")
    CL.SendNotify(NOTIFY.SubmitForm,"FormContact","IsAutoReply")
end

function FriendSystemSettingUI.RefreshMessageCheck()
    local IsONClick = FriendSystemSettingUI.IsOnMessageCheck
    test(tostring(FriendSystemSettingUI.IsOnMessageCheck),"tostring(FriendSystemSettingUI.IsOnMessageCheck)")
    local MessageCheck = _gt.GetUI("MessageCheck")
    if IsONClick == true then
        GUI.CheckBoxExSetCheck(MessageCheck,true)
    else
        GUI.CheckBoxExSetCheck(MessageCheck,false)
    end
end

function FriendSystemSettingUI.RefreshFriendCheck()
    local IsONClick = FriendSystemSettingUI.IsOnFriendCheck
    test(tostring(FriendSystemSettingUI.IsOnFriendCheck),"tostring(FriendSystemSettingUI.IsOnFriendCheck)")
    local FriendCheck = _gt.GetUI("FriendCheck")
    if IsONClick == true then
        GUI.CheckBoxExSetCheck(FriendCheck,true)
    else
        GUI.CheckBoxExSetCheck(FriendCheck,false)
    end
end

function FriendSystemSettingUI.SetReplyContent()
    local ReplyContent = _gt.GetUI("ReplyContent")
    local content = FriendSystemSettingUI.ReplyRoleContent
    test(type(FriendSystemSettingUI.ReplyRoleContent),"tostring(FriendSystemSettingUI.ReplyRoleContent)")
    if tostring(content) == "nil" then
        content = "您好，我现在有事不在，一会再和您联系。"
    end
    GUI.EditSetTextM(ReplyContent,content)
end

-- 应用按钮被点击
function FriendSystemSettingUI.OnApplyBtnClick()
    --消息自动回复
    local MessageCheck = _gt.GetUI("MessageCheck")
    local MessageIsONClick = GUI.CheckBoxExGetCheck(MessageCheck)
    CL.SendNotify(NOTIFY.SubmitForm,"FormContact","SetAutoReply",tostring(MessageIsONClick))

    --好友上线提示
    local FriendCheck = _gt.GetUI("FriendCheck")
    local FriendIsONClick = GUI.CheckBoxExGetCheck(FriendCheck)
    CL.SendNotify(NOTIFY.SubmitForm,"FormContact","SetLoginWarn",tostring(FriendIsONClick))

    --回复信息内容
    local ReplyContent = _gt.GetUI("ReplyContent")
    local content= GUI.EditGetTextM(ReplyContent)
    test("content= GUI.EditGetTextM(ReplyContent)......."..tostring(content))
    CL.SendNotify(NOTIFY.SubmitForm,"FormContact","SetAutoReplyContent",tostring(content))
end

-- 关闭按钮被点击
function FriendSystemSettingUI.OnCloseBtnClick(key, guid)

    local wnd = GUI.GetWnd("FriendSystemSettingUI")
    if wnd ~= nil then
        GUI.DestroyWnd("FriendSystemSettingUI")
    end
end
-- 确认按钮被点击
function FriendSystemSettingUI.OnOKBtnClick()
    FriendSystemSettingUI.OnApplyBtnClick()
    GUI.CloseWnd("FriendSystemSettingUI")
end

