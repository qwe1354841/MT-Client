local CrossServerWarfareBattlefieldReportUI = {}
_G.CrossServerWarfareBattlefieldReportUI = CrossServerWarfareBattlefieldReportUI

--跨服战战报界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
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
----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

--战报表
local BattlefieldReportTable = {}

--------------------------------------------End 表配置 End------------------------------------

function CrossServerWarfareBattlefieldReportUI.Main(parameter)

    local panel = GUI.WndCreateWnd("CrossServerWarfareBattlefieldReportUI" , "CrossServerWarfareBattlefieldReportUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local logPanelBg = UILayout.CreateFrame_WndStyle2(panel, "跨服战战报", 700, 570, "CrossServerWarfareBattlefieldReportUI","OnExit",_gt)

    -- 创建日志滚动列表
    local logLoopScrollBg = GUI.ImageCreate(logPanelBg, "logLoopScrollBg", "1800600040", 0, 55, false, 660, 450)
    SetSameAnchorAndPivot(logLoopScrollBg, UILayout.Top)

    local logLoopScroll = GUI.LoopListCreate(
            logLoopScrollBg,
            "logLoopScroll",
            0,
            15,
            600,
            420,

            "CrossServerWarfareBattlefieldReportUI",
            "CreateLogTxtPool",
            "CrossServerWarfareBattlefieldReportUI",
            "RefreshLogTxtPool",
            0,
            false,
            Vector2.New(600, 30),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft
    )
    GUI.ScrollRectSetChildSpacing(logLoopScroll, Vector2.New(0, 3))
    _gt.BindName(logLoopScroll, "logLoopScroll")


    -- 创建底部关闭按钮
    local logCloseBtn = GUI.ButtonCreate(logPanelBg, "logCloseBtn", "1800402110", 0, -20, Transition.ColorTint, "关闭战报", 120, 45, false)
    SetSameAnchorAndPivot(logCloseBtn, UILayout.Bottom)
    GUI.ButtonSetTextFontSize(logCloseBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(logCloseBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(logCloseBtn, UCE.PointerClick, "CrossServerWarfareBattlefieldReportUI", "OnLogCloseBtnClick")

end


function CrossServerWarfareBattlefieldReportUI.OnShow(parameter)
    local wnd = GUI.GetWnd("CrossServerWarfareBattlefieldReportUI");
    if wnd == nil then
        return
    end

    CrossServerWarfareBattlefieldReportUI.Init()
    GUI.SetVisible(wnd, true)

    CL.SendNotify(NOTIFY.SubmitForm, "FormAct_CrossServer", "FightData")

end

function CrossServerWarfareBattlefieldReportUI.Init()

    BattlefieldReportTable = {}

end

--服务器回调刷新
function CrossServerWarfareBattlefieldReportUI.RefreshAllData()
    test("服务器回调刷新")

    BattlefieldReportTable = CrossServerWarfareBattlefieldReportUI.FightData

    test("BattlefieldReportTable",inspect(BattlefieldReportTable))

    local logLoopScroll = _gt.GetUI("logLoopScroll")
    GUI.LoopScrollRectSetTotalCount(logLoopScroll, #BattlefieldReportTable)
    GUI.LoopScrollRectRefreshCells(logLoopScroll)

end

-- 创建日志循环列表
function CrossServerWarfareBattlefieldReportUI.CreateLogTxtPool()
    local logLoopScroll = _gt.GetUI("logLoopScroll")
    local index = tonumber(GUI.LoopScrollRectGetChildInPoolCount(logLoopScroll)) + 1
    local chatImg = GUI.LoopListChatCreate(logLoopScroll, "chatImg"..tonumber(index), "1800400200", 0, 0)
    GUI.SetColor(chatImg, Color.New(1, 1, 1, 0))
    GUI.LoopListChatSetPreferredWidth(chatImg, 600)
    GUI.LoopListChatSetPreferredHeight(chatImg, 30)
    SetSameAnchorAndPivot(chatImg, UILayout.TopLeft)
    GUI.SetVisible(chatImg, false)
    GUI.SetIsRaycastTarget(chatImg, false)

    local logTxt = GUI.CreateStatic(chatImg, "logTxt", "", 0, 0, 600, 30, "system", true)
    GUI.StaticSetFontSize(logTxt, UIDefine.FontSizeL)
    SetSameAnchorAndPivot(logTxt, UILayout.TopLeft)
    GUI.SetColor(logTxt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(logTxt, TextAnchor.MiddleLeft)
    GUI.SetIsRaycastTarget(logTxt, false)

    GUI.SetVisible(chatImg, false)

    return chatImg
end

-- 刷新日志循环列表
function CrossServerWarfareBattlefieldReportUI.RefreshLogTxtPool(para)
    para = string.split(para, "#")
    local guid = para[1]
    local index = tonumber(para[2]) + 1
    local chatImg = GUI.GetByGuid(guid)


    local logTxtList = BattlefieldReportTable
    if not logTxtList or not next(logTxtList) then
        GUI.SetVisible(chatImg, false)
        return
    end

    GUI.SetVisible(chatImg, true)

    local logTxt = GUI.GetChild(chatImg, "logTxt")
    GUI.StaticSetText(logTxt, logTxtList[#logTxtList+1 - index])

    if #logTxtList[#logTxtList+1 - index] > 96 then
        GUI.SetHeight(logTxt, 65)
        GUI.LoopListChatSetPreferredHeight(chatImg, 65)
    else
        GUI.SetHeight(logTxt, 30)
        GUI.LoopListChatSetPreferredHeight(chatImg, 30)
    end
end

function CrossServerWarfareBattlefieldReportUI.OnLogCloseBtnClick()

    GUI.CloseWnd("CrossServerWarfareBattlefieldReportUI")

end

function CrossServerWarfareBattlefieldReportUI.OnExit()

    GUI.CloseWnd("CrossServerWarfareBattlefieldReportUI")

end