PlayScreenEffectUI = {}
PlayScreenEffectUI.Timers = {}

PlayScreenEffectUI.EffectList = {
    MarriageEffect = {
        --{ ID = "-1962413848", EffectKey = "MarriageEffect1", LifeTime = 1.5, Pos = Vector2.New(0, 0), Scale = Vector3.New(100, 100, 100), TweenKey = "AttributeChangeTipMove"  },
		--{ ID = "-35693090", EffectKey = "MarriageEffect1", LifeTime = 500, Pos = Vector2.New(-260, -200), Scale = Vector3.New(1, 1, 1), UseRawImage = false },
		{ ID = 349350000, EffectKey = "MarriageEffect2", LifeTime = 3.6, Pos = Vector2.New(100, -90), Scale = Vector3.New(55, 55, 55), EulerAngles = Vector3.New(-90, 0, 0)},
		{ ID = 349360000, EffectKey = "MarriageEffect3", LifeTime = 3.1, Pos = Vector2.New(0, 0), Scale = Vector3.New(100, 100, 100), },
		{ ID = 349350000, EffectKey = "MarriageEffect4", LifeTime = 3.6, Pos = Vector2.New(500, -90), Scale = Vector3.New(55, 55, 55), EulerAngles = Vector3.New(-90, 0, 0)},
    },
	-- MouseEffect = {
        -- { ID = "-59059938", EffectKey = "MouseEffect1", LifeTime = 4.3, Pos = Vector2.New(0, 0), Scale = Vector3.New(100, 100, 100) },
		-- { ID = "-35693090", EffectKey = "MarriageEffect2", LifeTime = 4, Pos = Vector2.New(100, 100), Scale = Vector3.New(90, 90, 90), },
    -- },
}

--战斗中不显示的特效
PlayScreenEffectUI.FightNotShow = {
	"MarriageEffect"
}

function PlayScreenEffectUI.Main(parameter)
	local panel = GUI.WndCreateWnd("PlayScreenEffectUI", "PlayScreenEffectUI", 0, 0, eCanvasGroup.Top)
	GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panel, false)

    local group = GUI.GroupCreate(panel, "Group", 0, 0, 1280, 720)
end

function PlayScreenEffectUI.OnShow(parameter)
	if CL.GetFightState() then
		for _,v in ipairs(PlayScreenEffectUI.FightNotShow) do
			if parameter == v then
				return
			end
		end
	end
	
	local effect_config = PlayScreenEffectUI.EffectList[parameter]
	local parent = GUI.Get("PlayScreenEffectUI/Group")
	
	for _,v in ipairs(effect_config) do
		local particle = GUI.ParticleCreate(v.EffectKey, v.ID, v.Pos.x, v.Pos.y, parent, 1280, 720, true)
		GUI.SetScale(particle, v.Scale)
		GUI.SetVisible(particle, true)
		if v.EulerAngles then
			GUI.SetEulerAngles(particle, v.EulerAngles)
		end
		
		local guid = GUI.GetGuid(particle)
		local onTimer = function()
            PlayScreenEffectUI.Timers[guid] = nil
            local p = GUI.GetByGuid(guid)
            if p then
                GUI.Destroy(p)
            end
        end
        local timer = Timer.New(onTimer, v.LifeTime, 1)
        PlayScreenEffectUI.Timers[guid] = timer
        timer:Start()
	end

end


function PlayScreenEffectUI.OnDestroy()
	if not next(PlayScreenEffectUI.Timers) then return end 
    for k, v in pairs(PlayScreenEffectUI.Timers) do
        local p = GUI.GetByGuid(k)
        if p then
            GUI.Destroy(p)
        end
        v:Stop()
    end
    PlayScreenEffectUI.Timers = {}
end
