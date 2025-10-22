GameHelpTipsUI = {}
-- 要展示的游戏帮助列表
GameHelpTipsUI.ShowTipsList = {}
-- 要展示的游戏帮助列表的角标列表
GameHelpTipsUI.ShowTipsIndex = {}
-- 展示游戏帮助的间隔时间
GameHelpTipsUI.Time = 30
-- 展示游戏帮助的角标
GameHelpTipsUI.ShowIndex = 1

-- 游戏帮助列表 {最小等级，最大等级，提示文本}
GameHelpTipsUI.TipsList = {
    {MinLevel = 0,MaxLevel = 120,Content = " #202 加入<color=#ffffffff>帮派</color>可以更加容易的获得其他玩家的帮助。"},
}

-- 刷新要展示的游戏帮助列表（根据当前等级，判断要展示的游戏帮助）
function GameHelpTipsUI.RefreshHelpTipsList(attrType, value)
    GameHelpTipsUI.ShowTipsList = {}
    GameHelpTipsUI.ShowTipsIndex = {}
    GameHelpTipsUI.ShowIndex = 1
    local CurLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    if attrType == RoleAttr.RoleAttrLevel then
        CurLevel = tonumber(tostring(value))
    end
    for i = 1, #GameHelpTipsUI.TipsList do
        local curHelpTips = GameHelpTipsUI.TipsList[i]
        if CurLevel >= curHelpTips.MinLevel and CurLevel <= curHelpTips.MaxLevel then
            table.insert(GameHelpTipsUI.ShowTipsList,curHelpTips)
            table.insert(GameHelpTipsUI.ShowTipsIndex,{index = GameHelpTipsUI.ShowIndex,random = math.random()})
            GameHelpTipsUI.ShowIndex = GameHelpTipsUI.ShowIndex + 1
        end
    end
    GameHelpTipsUI.ShowIndex = 1
    -- 排序（根据随机数来打乱帮助的角标列表的排序，达到随机展示的目的）
    table.sort(GameHelpTipsUI.ShowTipsIndex,function (a, b)
        return a.random < b.random
    end)
end

-- 展示游戏帮助（计时器，在间隔时间后展示游戏帮助）
function GameHelpTipsUI.ShowHelpTips()
    if GameHelpTipsUI.ShowHelpTipsTimer == nil then
        GameHelpTipsUI.ShowHelpTipsTimer = Timer.New(GameHelpTipsUI.ShowHelpTipsFuc,GameHelpTipsUI.Time,-1)
    else
        GameHelpTipsUI.ShowHelpTipsTimer:Stop()
        GameHelpTipsUI.ShowHelpTipsTimer:Reset(GameHelpTipsUI.ShowHelpTipsFuc,GameHelpTipsUI.Time,-1)
    end
    GameHelpTipsUI.ShowHelpTipsTimer:Start()
end

-- 展示游戏帮助（计时器调用的方法）
function GameHelpTipsUI.ShowHelpTipsFuc()
    if #GameHelpTipsUI.ShowTipsList > 0 then
        -- 从帮助的角标列表取出要展示的游戏帮助的角标
        if GameHelpTipsUI.ShowIndex > #GameHelpTipsUI.ShowTipsList then
            GameHelpTipsUI.ShowIndex = 1
        end
        local index = GameHelpTipsUI.ShowTipsIndex[GameHelpTipsUI.ShowIndex].index
        GameHelpTipsUI.ShowIndex = GameHelpTipsUI.ShowIndex + 1
        local str = GameHelpTipsUI.ShowTipsList[index].Content
        LD.SendSystemHelpMsg(str)
    end
end

-- 关闭游戏帮助
function GameHelpTipsUI.UnShowHelpTips()
    if GameHelpTipsUI.ShowHelpTipsTimer then
        GameHelpTipsUI.ShowHelpTipsTimer:Stop()
        GameHelpTipsUI.ShowHelpTipsTimer = nil
    end
end