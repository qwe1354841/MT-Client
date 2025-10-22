PlayerStateUI = {}
local guidt = UILayout.NewGUIDUtilTable()
local data = {
    lv = nil
}
local eRoleHeadFlag = {
    None = 0,
    Pathfinding = 1,
    Patrol = 2,
    Escort = 3
}
function PlayerStateUI.OnExitGame()
    data = {
        lv = nil
    }
end
function PlayerStateUI.Main(parameter)
    GameMain.AddListen("PlayerStateUI", "OnExitGame")
    guidt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("PlayerStateUI", "PlayerStateUI", 0, 0, eCanvasGroup.Main)

    if panel == nil then
        test("PlayerStateUI not create")
    end
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)
    local findPath = GUI.SpriteFrameCreate(panel, "findPath", "340301", 0, -245)
    -- GUI.SetFrameId(findPath, 3403000000)
    GUI.SetVisible(findPath, false)
    GUI.SetIsRaycastTarget(findPath, false)

    local patrolingAnim = GUI.SpriteFrameCreate(panel, "patrolingAnim", "340311", 0, -245)
    -- GUI.SetFrameId(patrolingAnim, 3403100000)
    GUI.SetVisible(patrolingAnim, false)
    GUI.SetIsRaycastTarget(patrolingAnim, false)

    local escortAnim = GUI.SpriteFrameCreate(panel, "escortAnim", "340311", 0, -245)
    -- GUI.SetFrameId(patrolingAnim, 3403100000)
    GUI.SetVisible(escortAnim, false)
    GUI.SetIsRaycastTarget(escortAnim, false)

    local lvUp = GUI.SpriteFrameCreate(panel, "lvUp", "340081", 0, -150)
    -- GUI.SetFrameId(lvUp, 3400800000)
    GUI.SetAnchor(lvUp, UIAnchor.Center)
    GUI.SetPivot(lvUp, UIAroundPivot.Center)
    GUI.SetVisible(lvUp, false)
    GUI.SetIsRaycastTarget(lvUp, false)
    guidt.BindName(lvUp, "lvUp")

    CL.RegisterMessage(GM.MoveStart, "PlayerStateUI", "StartfindPath")
    CL.RegisterMessage(GM.MoveEnd, "PlayerStateUI", "StopfindPath")
    CL.RegisterMessage(GM.FightStateNtf, "PlayerStateUI", "OnFightStateNtf")
    CL.RegisterAttr(RoleAttr.RoleAttrLevel, PlayerStateUI.StartLvUp)
end

function PlayerStateUI.OnDestroy()
    CL.UnRegisterMessage(GM.MoveStart, "PlayerStateUI", "StartfindPath")
    CL.UnRegisterMessage(GM.MoveEnd, "PlayerStateUI", "StopfindPath")
    CL.UnRegisterMessage(GM.FightStateNtf, "PlayerStateUI", "OnFightStateNtf")
    CL.UnRegisterAttr(RoleAttr.RoleAttrLevel, PlayerStateUI.StartLvUp)
end

function PlayerStateUI.OnFightStateNtf(inFight)
    local isEscort = CL.GetIntAttr(RoleAttr.RoleAttrIsConvoy)
    if isEscort == 1 then
        if inFight then
            PlayerStateUI.StopfindPath(nil, nil, true)
        else
            PlayerStateUI.StartfindPath(0, nil)
        end
    end
end

function PlayerStateUI.RefreshByTable(t)
    for i = 1, #t do
        if t[i] ~= nil and t[i].ui ~= nil then
            if t[i].vis then
                GUI.SetFrameId(t[i].ui, t[i].name)
                GUI.Play(t[i].ui)
                GUI.SetVisible(t[i].ui, true)
            else
                GUI.Stop(t[i].ui)
                GUI.SetVisible(t[i].ui, false)
            end
        end
    end
end
function PlayerStateUI.StartfindPath(ftime, itype)
	local panel = GUI.GetWnd("PlayerStateUI")
    local findPath = GUI.GetChild(panel, "findPath")
    local patrolingAnim = GUI.GetChild(panel, "patrolingAnim")
    local escortAnim = GUI.GetChild(panel, "escortAnim")
    local t = {}
    t[1] = {ui = findPath, vis = false}
    t[2] = {ui = patrolingAnim, vis = false}
    t[3] = {ui = escortAnim, vis = false}

    --如果在护送中，则最优先显示护送
    local isEscort = CL.GetIntAttr(RoleAttr.RoleAttrIsConvoy)
    if isEscort == 1 then
        t[3] = {ui = escortAnim, vis = true, name = 3402500000}
    else
        --否则显示其他
        if itype == eRoleHeadFlag.Pathfinding then
            t[1] = {ui = findPath, vis = true, name = 3403000000}
        elseif itype == eRoleHeadFlag.Patrol then
            t[2] = {ui = patrolingAnim, vis = true, name = 3403100000}
        else
            --print("None")
            t[1] = {ui = findPath, vis = false}
            t[2] = {ui = patrolingAnim, vis = false}
            t[3] = {ui = escortAnim, vis = false}
        end
    end
    PlayerStateUI.RefreshByTable(t)
    end
function PlayerStateUI.StopfindPath(ftime, itype, force)
    if force == nil or force ~= true then
        local isEscort = CL.GetIntAttr(RoleAttr.RoleAttrIsConvoy)
        if isEscort == 1 then
            return
        end
    end
    local panel = GUI.GetWnd("PlayerStateUI")
    local findPath = GUI.GetChild(panel, "findPath")
    local patrolingAnim = GUI.GetChild(panel, "patrolingAnim")
    local escortAnim = GUI.GetChild(panel, "escortAnim")
    local t = {}
    t[1] = {ui = findPath, vis = false}
    t[2] = {ui = patrolingAnim, vis = false}
    t[3] = {ui = escortAnim, vis = false}
    PlayerStateUI.RefreshByTable(t)
end

function PlayerStateUI.StartLvUp(attrType, value)
    if attrType == RoleAttr.RoleAttrLevel then
        local lvUp = guidt.GetUI("lvUp")
        if lvUp ~= nil then
            GUI.SpriteFrameSetIsLoop(lvUp, false)
            local lv = value
            if data.lv and lv > data.lv then
                GUI.SetFrameId(lvUp, 3400800000)
                GUI.Play(lvUp)
                GUI.SetVisible(lvUp, true)
            end
            data.lv = lv
        end
    end
end

function PlayerStateUI.OnDestroy()
    test("PlayerStateUI.OnDestroy")
end
