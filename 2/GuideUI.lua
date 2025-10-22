local GuideUI = {
    timer = {}
}
_G.GuideUI = GuideUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local guidt = UILayout.NewGUIDUtilTable()
local MOVE_OFFSET_Y = 10
local DEFAULT_DURATION = 30
local GUIDE_AREAX = 500
local GUIDE_AREAY = 300
local ANCHOR_DEFINE = {"TopLeft","Top","TopRight","Left","Center","Right","BottomLeft","Bottom","BottomRight"}

--在引导状态时的UI开启控制：白名单里的UI才允许通过
local UIWhiteList = {"GuideUI"}

GuideUI.curIndex = 0
GuideUI.ScreenWidth = 1280
GuideUI.ScreenHeight = 720

function GuideUI.InitData()
    GuideUI.curIndex = 0
end

function GuideUI.OnExit()
    GUI.DestroyWnd("GuideUI")
end

function GuideUI.Main(parameter)
    print("GuideUI Main")
    guidt = UILayout.NewGUIDUtilTable()

    local panel = GUI.WndCreateWnd("GuideUI", "GuideUI", 0, 0, eCanvasGroup.Top)
    GuideUI.ScreenWidth = GUI.GetWidth(panel)
    GuideUI.ScreenHeight = GUI.GetHeight(panel)

    local width = GUI.GetWidth(panel)
    local height = GUI.GetHeight(panel)
    local maskLeft = GUI.ImageCreate(panel, "maskLeft", "1800499999", 0, 0, false, 100, height)
    UILayout.SetSameAnchorAndPivot(maskLeft, UILayout.Left)
    maskLeft:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(maskLeft, true)
    local maskRight = GUI.ImageCreate(panel, "maskRight", "1800499999", 0, 0, false, 100, height)
    UILayout.SetSameAnchorAndPivot(maskRight, UILayout.Right)
    maskRight:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(maskRight, true)
    local maskTop = GUI.ImageCreate(panel, "maskTop", "1800499999", 0, 0, false, width, 100)
    UILayout.SetSameAnchorAndPivot(maskTop, UILayout.Top)
    maskTop:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(maskTop, true)
    local maskBottom = GUI.ImageCreate(panel, "maskBottom", "1800499999", 0, 0, false, width, 100)
    UILayout.SetSameAnchorAndPivot(maskBottom, UILayout.Bottom)
    maskBottom:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(maskBottom, true)
    local maskCenterGroup = GUI.GroupCreate(panel, "maskCenterGroup", 0, 0, 1, 1)
    UILayout.SetSameAnchorAndPivot(maskCenterGroup, UILayout.TopLeft)
    guidt.BindName(maskCenterGroup, "maskCenterGroup")

    local group = GUI.GroupCreate(panel, "group", 0, 0, 1, 1)
    --GUI.AddWhiteName(group, GUI.GetGuid(group))
    UILayout.SetSameAnchorAndPivot(group, UILayout.Center)
    guidt.BindName(group, "group")

    local bg = GUI.ImageCreate(group, "bg", "1800601060", 0, 0, false, 250, 150)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)
    local arrow = GUI.ImageCreate(group, "arrow", "1800208230", 0, 0)
    UILayout.SetSameAnchorAndPivot(arrow, UILayout.Center)
    local fox = GUI.ImageCreate(bg, "fox", "1800228220", -162, 0)
    local txt = GUI.CreateStatic(bg, "txt", " ", -10, 10, 160, 130)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Top)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

    guidt.BindName(group, "group")
    guidt.BindName(txt, "txt")
    guidt.BindName(arrow, "arrow")
    guidt.BindName(bg, "bg")
    guidt.BindName(fox, "fox")
    guidt.BindName(maskLeft, "maskLeft")
    guidt.BindName(maskRight, "maskRight")
    guidt.BindName(maskTop, "maskTop")
    guidt.BindName(maskBottom, "maskBottom")

    CL.RegisterMessage(UM.CloseWhenClicked, "GuideUI", "OnGuideClicked")
    CL.RegisterMessage(GM.ShowWnd,"GuideUI","OnShowUIWnd")
    CL.RegisterMessage(GM.ClickObject, "GuideUI", "OnClickModel")
    CL.RegisterMessage(GM.FightClickRole, "GuideUI", "OnClickModel")
end

function GuideUI.OnClickModel(param)
    GuideUI.OnStep()
end

function GuideUI.OnShowUIWnd(uiname)
    --在剧情或者任务对白开启时候，则会强制隐藏引导，待结束后再重启引导的播放
    if uiname == "NpcDialogFullUI" then
        MainUI.OnTryDestroyGuideUI()
        return
    end
    local data = GuideData.ServerData[GuideUI.curIndex]
    --type1 强引导才需要关心
    if data and data.type == 1 then
        local _UIWhiteList = {}
        for i = 1, #UIWhiteList do
            table.insert(_UIWhiteList, UIWhiteList[i])
        end

        --设置本步骤引导，并隐藏其他UI
        if data.ui and #data.ui>0 then
            for i = 1, #data.ui do
                table.insert(_UIWhiteList, data.ui[i])
            end
        end
        MainUI.CloseOtherWnds(_UIWhiteList)
    end
end

function GuideUI.CreateClickAreaMask()
    local maskCenterGroup = guidt.GetUI("maskCenterGroup")
    local maskCenter = guidt.GetUI("maskCenter")
    if maskCenter == nil then
        maskCenter = GUI.ImageCreate(maskCenterGroup, "maskCenter", "1800499999", 0, 0, false, 100, 100)
        UILayout.SetSameAnchorAndPivot(maskCenter, UILayout.Center)
        --下面两行开启，则点击无法穿透，隐藏则可穿透点击到底层UI。但都不影响点击关闭引导的响应事件
        --GUI.SetIsRaycastTarget(maskCenter, true)
        --maskCenter:RegisterEvent(UCE.PointerClick)

        GUI.SetIsRemoveWhenClick(maskCenter, true)
        guidt.BindName(maskCenter, "maskCenter")
        local maskLeft = guidt.GetUI("maskLeft")
        local maskRight = guidt.GetUI("maskRight")
        local maskTop = guidt.GetUI("maskTop")
        local maskBottom = guidt.GetUI("maskBottom")
        GUI.AddWhiteName(maskCenter, GUI.GetGuid(maskLeft))
        GUI.AddWhiteName(maskCenter, GUI.GetGuid(maskRight))
        GUI.AddWhiteName(maskCenter, GUI.GetGuid(maskTop))
        GUI.AddWhiteName(maskCenter, GUI.GetGuid(maskBottom))
    end
    CL.UnRegisterMessage(UM.CloseWhenClicked, "GuideUI", "OnGuideClicked")
    CL.RegisterMessage(UM.CloseWhenClicked, "GuideUI", "OnGuideClicked")
end

function GuideUI.OnGuideClicked()
    guidt.BindName(nil, "maskCenter")
    GuideUI.OnStep()
end

function GuideUI.OnShow(parameter)
    local wnd = GUI.GetWnd("GuideUI")
    if wnd == nil then
        return
    end
    GuideUI.curIndex = 0
    GUI.SetVisible(wnd, true)
    GuideUI.RefreshUI()
end

function GuideUI.OnDestroy()
    CL.UnRegisterMessage(UM.CloseWhenClicked, "GuideUI", "OnGuideClicked")
    CL.UnRegisterMessage(GM.ShowWnd,"GuideUI","OnShowUIWnd")
    CL.UnRegisterMessage(GM.ClickObject, "GuideUI", "OnClickModel")
    CL.UnRegisterMessage(GM.FightClickRole, "GuideUI", "OnClickModel")
    GuideUI.OnClose()
end

function GuideUI.OnClose()
    local wnd = GUI.GetWnd("GuideUI")
    GUI.SetVisible(wnd, false)
    for key, value in pairs(GuideUI.timer) do
        if value then
            value:Stop()
        end
    end
    GuideUI.timer = {}
end

function GuideUI.RefreshUI()
    GuideUI.InitData()
    GuideUI.Next()
end

function GuideUI.ShowMask(x,y,Anchor,sx,sy,type)
    local maskLeft = guidt.GetUI("maskLeft")
    local maskRight = guidt.GetUI("maskRight")
    local maskTop = guidt.GetUI("maskTop")
    local maskBottom = guidt.GetUI("maskBottom")
    if maskLeft and maskRight and maskTop and maskBottom then
        local bShow = type == 1
        GUI.SetVisible(maskLeft, bShow)
        GUI.SetVisible(maskRight, bShow)
        GUI.SetVisible(maskTop, bShow)
        GUI.SetVisible(maskBottom, bShow)
        if bShow then
            local widthLeft = 0
            local widthRight = 0
            local heightTop = 0
            local heightBottom = 0
            if Anchor == UILayout.TopLeft then
                widthLeft = math.max(0,x - sx/2)
                widthRight = math.max(0,GuideUI.ScreenWidth-x-sx/2)
                heightTop = math.max(0,y - sy/2)
                heightBottom = math.max(0,GuideUI.ScreenHeight-y-sy/2)
            elseif Anchor == UILayout.Top then
                widthLeft = math.max(0,GuideUI.ScreenWidth/2 + x - sx/2)
                widthRight = math.max(0,GuideUI.ScreenWidth/2 - x - sx/2)
                heightTop = math.max(0,y - sy/2)
                heightBottom = math.max(0,GuideUI.ScreenHeight-y-sy/2)
            elseif Anchor == UILayout.TopRight then
                widthLeft = math.max(0,GuideUI.ScreenWidth + x - sx/2)
                widthRight = math.max(0,-x - sx/2)
                heightTop = math.max(0,y - sy/2)
                heightBottom = math.max(0,GuideUI.ScreenHeight-y-sy/2)
            elseif Anchor == UILayout.Left then
                widthLeft = math.max(0,x - sx/2)
                widthRight = math.max(0,GuideUI.ScreenWidth-x-sx/2)
                heightTop = math.max(0,GuideUI.ScreenHeight/2 + y - sy/2)
                heightBottom = math.max(0,GuideUI.ScreenHeight/2 - y - sy/2)
            elseif Anchor == UILayout.Center then
                widthLeft = math.max(0,GuideUI.ScreenWidth/2 + x - sx/2)
                widthRight = math.max(0,GuideUI.ScreenWidth/2 - x - sx/2)
                heightTop = math.max(0,GuideUI.ScreenHeight/2 + y - sy/2)
                heightBottom = math.max(0,GuideUI.ScreenHeight/2 - y - sy/2)
            elseif Anchor == UILayout.Right then
                widthLeft = math.max(0,GuideUI.ScreenWidth + x - sx/2)
                widthRight = math.max(0,-x - sx/2)
                heightTop = math.max(0,GuideUI.ScreenHeight/2 + y - sy/2)
                heightBottom = math.max(0,GuideUI.ScreenHeight/2 - y - sy/2)
            elseif Anchor == UILayout.BottomLeft then
                widthLeft = math.max(0,x - sx/2)
                widthRight = math.max(0,GuideUI.ScreenWidth-x-sx/2)
                heightTop = math.max(0,GuideUI.ScreenHeight + y - sy/2)
                heightBottom = math.max(0,-y - sy/2)
            elseif Anchor == UILayout.Bottom then
                widthLeft = math.max(0,GuideUI.ScreenWidth/2 + x - sx/2)
                widthRight = math.max(0,GuideUI.ScreenWidth/2 - x - sx/2)
                heightTop = math.max(0,GuideUI.ScreenHeight + y - sy/2)
                heightBottom = math.max(0,-y - sy/2)
            elseif Anchor == UILayout.BottomRight then
                widthLeft = math.max(0,GuideUI.ScreenWidth + x - sx/2)
                widthRight = math.max(0,-x - sx/2)
                heightTop = math.max(0,GuideUI.ScreenHeight + y - sy/2)
                heightBottom = math.max(0,-y - sy/2)
            end
            GUI.SetWidth(maskLeft, widthLeft)
            GUI.SetWidth(maskRight, widthRight)
            GUI.SetHeight(maskTop, heightTop)
            GUI.SetHeight(maskBottom, heightBottom)
        end
    end
end

function GuideUI.ParseGroupPosInfo(x,y,Anchor)
    --首先分类到4个象限：左上，右上，左下，右下
    local isLeftOrRight = true
    local isTopOrBottom = true
    if Anchor == UILayout.TopLeft then
        isLeftOrRight = x < GuideUI.ScreenWidth - GUIDE_AREAX
        isTopOrBottom = y < GuideUI.ScreenHeight - GUIDE_AREAY
    elseif Anchor == UILayout.Top then
        isLeftOrRight = x < GuideUI.ScreenWidth/2 - GUIDE_AREAX
        isTopOrBottom = y < GuideUI.ScreenHeight - GUIDE_AREAY
    elseif Anchor == UILayout.TopRight then
        isLeftOrRight = x < -GUIDE_AREAX
        isTopOrBottom = y < GuideUI.ScreenHeight - GUIDE_AREAY
    elseif Anchor == UILayout.Left then
        isLeftOrRight = x < GuideUI.ScreenWidth - GUIDE_AREAX
        isTopOrBottom = y < GuideUI.ScreenHeight/2  - GUIDE_AREAY
    elseif Anchor == UILayout.Center then
        isLeftOrRight = x < GuideUI.ScreenWidth/2 - GUIDE_AREAX
        isTopOrBottom = y < GuideUI.ScreenHeight/2  - GUIDE_AREAY
    elseif Anchor == UILayout.Right then
        isLeftOrRight = x < -GUIDE_AREAX
        isTopOrBottom = y < GuideUI.ScreenHeight/2  - GUIDE_AREAY
    elseif Anchor == UILayout.BottomLeft then
        isLeftOrRight = x < GuideUI.ScreenWidth - GUIDE_AREAX
        isTopOrBottom = y < -GUIDE_AREAY
    elseif Anchor == UILayout.Bottom then
        isLeftOrRight = x < GuideUI.ScreenWidth/2 - GUIDE_AREAX
        isTopOrBottom = y < -GUIDE_AREAY
    elseif Anchor == UILayout.BottomRight then
        isLeftOrRight = x < -GUIDE_AREAX
        isTopOrBottom = y < -GUIDE_AREAY
    end
    local dirX = 1
    local dirY = 1
    if isLeftOrRight and isTopOrBottom then
        --左上
    elseif not isLeftOrRight and isTopOrBottom then
        --右上
        dirX = -1
    elseif isLeftOrRight and not isTopOrBottom then
        --左下
        dirY = -1
    elseif not isLeftOrRight and not isTopOrBottom then
        --右下
        dirX = -1
        dirY = -1
    end
    return dirX,dirY
end

function GuideUI.SwitchXYNormalized(x,y,Anchor,w,h)
    if Anchor == UILayout.TopLeft then
        return x,y,x-w/2,y-h/2
    elseif Anchor == UILayout.Top then
        return x,y,x,y-h/2
    elseif Anchor == UILayout.TopRight then
        return -x,y,-x-w/2,y-h/2
    elseif Anchor == UILayout.Left then
        return x,y,x-w/2,y
    elseif Anchor == UILayout.Center then
        return x,y,x,y
    elseif Anchor == UILayout.Right then
        return -x,y,-x-w/2,y
    elseif Anchor == UILayout.BottomLeft then
        return x,-y,x-w/2,-y-h/2
    elseif Anchor == UILayout.Bottom then
        return x,-y,x,-y-h/2
    elseif Anchor == UILayout.BottomRight then
        return -x,-y,-x-w/2,-y-h/2
    end
    return x,y,x-w/2,y-h/2
end

function GuideUI.Next()
    GuideUI.curIndex = GuideUI.curIndex + 1
    if GuideUI.curIndex > #GuideData.ServerData then
        GuideUI.OnExit()
        return
    end

    --创建响应点击区域
    GuideUI.CreateClickAreaMask()

    local data = GuideData.ServerData[GuideUI.curIndex]

    --设置本步骤引导，并隐藏其他UI
    if data.ui and #data.ui>0 then
        table.insert(data.ui, "GuideUI")
        MainUI.CloseOtherWnds(data.ui)
    end

    local x = data.x
    local y = data.y
    local w = data.w
    local h = data.h
    local type = data.type or 0
    local durationTime = data.time or DEFAULT_DURATION --默认持续 DEFAULT_DURATION 秒
    local group = guidt.GetUI("group")
    local txt = guidt.GetUI("txt")
    local arrow = guidt.GetUI("arrow")
    local bg = guidt.GetUI("bg")
    local fox = guidt.GetUI("fox")
    local maskCenter = guidt.GetUI("maskCenter")
    local maskCenterGroup = guidt.GetUI("maskCenterGroup")
    --设置提示内容
    GUI.StaticSetText(txt, data.str)

    --设置group位置和遮罩
    local posAnchor = UILayout.Center
    if data.ali and ANCHOR_DEFINE[data.ali] and UILayout[ANCHOR_DEFINE[data.ali]] then
        posAnchor = UILayout[ANCHOR_DEFINE[data.ali]]
    end

    --设置group内的狐狸和箭头
    local dirX, dirY = GuideUI.ParseGroupPosInfo(x,y,posAnchor)
    GUI.SetPositionX(bg, 191*dirX)
    GUI.SetPositionY(bg, 145*dirY)
    GUI.SetPositionX(arrow, 52*dirX)
    GUI.SetPositionY(arrow, 56*dirY)
    GUI.SetPositionX(txt, -10*dirX)
    GUI.SetScale(arrow, Vector3.New(dirX, dirY, 1))
    GUI.SetScale(fox, Vector3.New(-dirX, 1, 1))
    GUI.SetPositionX(fox, 162*dirX)

    local posx,posy,cposx,cposy = GuideUI.SwitchXYNormalized(x,y,posAnchor,w,h)
    GUI.SetPositionX(group, posx)
    GUI.SetPositionY(group, posy)
    UILayout.SetSameAnchorAndPivot(group, posAnchor)
    UILayout.SetSameAnchorAndPivot(maskCenter, posAnchor)
    UILayout.SetSameAnchorAndPivot(maskCenterGroup, posAnchor)
    GUI.SetPositionX(maskCenter, cposx)
    GUI.SetPositionY(maskCenter, cposy)
    GUI.SetWidth(maskCenter, w)
    GUI.SetHeight(maskCenter, h)
    GuideUI.ShowMask(x,y,posAnchor,w,h,type)

    --浮动展示指引
    local tw = TweenData.New()
    tw.Type = GUITweenType.DOLocalMove
    tw.Duration = 1
    tw.From = Vector3.New(posx, posy - MOVE_OFFSET_Y/2, 0)
    tw.To = Vector3.New(posx, posy + MOVE_OFFSET_Y/2, 0)
    tw.LoopType = UITweenerStyle.PingPong
    GUI.StopTween(group, GUITweenType.DOLocalMove)
    GUI.DOTween(group, tw)

    --展示时长
    if GuideUI.timer.onNext == nil then
        GuideUI.timer.onNext = Timer.New(GuideUI.OnTimeOut, durationTime, 1)
    else
        GuideUI.timer.onNext:Reset(GuideUI.OnTimeOut, durationTime, 1, false)
    end
    GuideUI.timer.onNext:Start()

    --播放点击效果
    if GuideUI.timer.clickEffect == nil then
        GuideUI.timer.clickEffect = Timer.New(GuideUI.ClickEffect, 1, -1)
    else
        GuideUI.timer.clickEffect:Reset(GuideUI.ClickEffect, 1, -1, false)
    end
    GuideUI.timer.clickEffect:Start()
end

function GuideUI.OnTimeOut()
    GuideUI.SendFinishNotify(1)
end

function GuideUI.OnStep()
    if GuideData.ServerData and GuideUI.curIndex >= #GuideData.ServerData then
        GuideUI.SendFinishNotify()
    end
    --启动下一步引导
    GuideUI.Next()
end

function GuideUI.SendFinishNotify(timeout)
    timeout = timeout or 0
    --完成了当前引导步骤了，finish发送parm参数
    local data = GuideData.ServerData[GuideUI.curIndex]
	if data then
		CL.SendNotify(NOTIFY.SubmitForm,"FormGuidance","Finish", tostring(data.parm), GuideUI.curIndex,timeout)
	end
end

function GuideUI.ClickEffect()
    GUI.PlayClickEffect(uint64.new(3000001442), guidt.GetGuid("group"))
end