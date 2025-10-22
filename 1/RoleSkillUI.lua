---@diagnostic disable: undefined-global, undefined-field
local RoleSkillUI = {};

_G.RoleSkillUI = RoleSkillUI
local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
-- local inspect = require("inspect")
------------------------------------ end缓存一下全局变量end --------------------------------
local fontSize = 22;
local fontSize_BigOne = 24;
local fontColor1 = "AC7527";        --黄颜色文字
local fontColor2 = "662F16";        --深色文字
local font_RedColor = "ff3c3c";
local font_BlackColor = "000000";        --黑色
local font_GreenColor = "2EDA00";        --绿色
local fontSize_Btn = 26;
local colorblack = Color.New(0, 0, 0, 1);
local colorGreen = Color.New(46 / 255, 218 / 255, 0 / 255, 1);
RoleSkillUI.skill_practice_levelmax = 21;
local iconWidth = 70;
local iconHeight = 70;
local talentSkillEdition=nil  --天赋数据的版本号
local ColorType_FontColor1 = Color.New(172 / 255, 117 / 255, 39 / 255);
local ColorType_FontColor2 = Color.New(102 / 255, 47 / 255, 22 / 255)
local ColorType_Red = Color.New(255 / 255, 60 / 255, 60 / 255);
local ColorType_White = Color.New(255 / 255, 255 / 255, 255 / 255);
local colorTextGray = Color.New(146 / 255, 146 / 255, 146 / 255);
local Scrolls = {[1] = "heartSkillScroll", [3] = "practiceSkillScroll", [4] = "GuildSkillScroll"}

local PageEnum = {
    School = 1,
    Talent = 2,
    Practice = 3,
    Guild = 4,
}
local LabelList = {
    { "门派", "schoolSkillTog", "OnSchoolSkillToggle", "schoolSkillPage", "CreateSchoolSkillPage" },
    { "天赋", "talentSkillTog", "OnTalentSkillToggle", "talentSkillPage", "CreateTalentSkillPage" },
    { "修炼", "practiceSkillTog", "OnPracticeSkillToggle", "practiceSkillPage", "CreatePracticeSkillPage" },
    { "帮派", "guildSkillTog", "OnGuildSkillToggle", "guildSkillPage", "CreateGuildSkillPage" },
}

RoleSkillUI.isSelectLearnAllSkill = true;
RoleSkillUI.canDoLearnAllSkill = false;
RoleSkillUI.CurrentMaxPracticeSkillLevel = 21;


RoleSkillUI.JobType = nil;

RoleSkillUI.SelectSchoolSkillId = nil;
RoleSkillUI.SelectTalentSkillId = nil;
RoleSkillUI.SelectPracticleSkillId = nil;
RoleSkillUI.SelectFactionSkillId = nil;

local CurSelectPage = nil -- 当前选中的页签， 对应PageEnum
local redPointData = nil
RoleSkillUI.CulSkillData = {}
RoleSkillUI.GuildSkillData = {}

function RoleSkillUI.Main(parameter)
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(LabelList[1][1])
    local Level = MainUI.MainUISwitchConfig["技能"].Subtab_OpenLevel[Key]
    if CurLevel < Level then
        return
    end
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("RoleSkillUI", "RoleSkillUI", 0, 0);
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "技  能", "RoleSkillUI", "OnCloseBtnClick", _gt)
    UILayout.CreateRightTab(LabelList, "RoleSkillUI")
    GUI.SetVisible(panel, false)
end

--小红点方法
function RoleSkillUI.CheckRedPoint()
    local wnd = GUI.GetWnd('RoleSkillUI')
    if not GUI.GetVisible(wnd) then
        return
    end

    redPointData = GlobalProcessing.SkillRedPointTable

    if redPointData==nil or next(redPointData)==nil then
        return
    end

    --右边页签   小红点的刷新
    RoleSkillUI.TabRedPointCheck()
    --刷新页面
    RoleSkillUI.RefreshServerData()
end
function RoleSkillUI.TabRedPointCheck()
    --CDebug.LogError("页签小红点刷新")
    local panelBg = _gt.GetUI("panelBg")
    local tabList = GUI.GetChild(panelBg,"tabList")
    for i, v in ipairs(LabelList) do
        local btn=GUI.GetChild(tabList,v[2])
        local tabRedPoint = GlobalProcessing['skillBtn_Reds']
        if tabRedPoint["page"..i] == 1 then
            GlobalProcessing.SetRetPoint(btn,true,UIDefine.red_type.bookmark)
        else
            GlobalProcessing.SetRetPoint(btn,false,UIDefine.red_type.bookmark)
        end
    end
end

function RoleSkillUI.OnShow(parameter)
    local wnd = GUI.GetWnd("RoleSkillUI")

    -- 先取消再监听
    CL.UnRegisterAttr(RoleAttr.RoleAttrGuildContribute, RoleSkillUI.ResetAttrGuildContribute)
    CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold, RoleSkillUI.ResetAttrBindGold)
    -- 监听帮贡
    CL.RegisterAttr(RoleAttr.RoleAttrGuildContribute, RoleSkillUI.ResetAttrGuildContribute)
    -- 监听银币
    CL.RegisterAttr(RoleAttr.RoleAttrBindGold, RoleSkillUI.ResetAttrBindGold)

    -- TODO:显示某个页面
    CurSelectPage = parameter ~= nil and tonumber(parameter) or 1

    local data = string.split(parameter,",")
    if data[1] == "index:3" then
        CurSelectPage = 3
    elseif data[1] == "index:2" then
        CurSelectPage = 2
    elseif data[1] == "index:4" then
        CurSelectPage = 4
    end

    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(LabelList[CurSelectPage][1])
    local Level = MainUI.MainUISwitchConfig["技能"].Subtab_OpenLevel[Key]

    if CurLevel < Level then
        CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
        CurSelectPage = nil
        return
    end

    if wnd then
        GUI.SetVisible(wnd, true)
    end

    if CurSelectPage == PageEnum.School then
        CurSelectPage = nil
        RoleSkillUI.OnSchoolSkillToggle()
    elseif CurSelectPage==PageEnum.Talent then
        CurSelectPage = nil
        RoleSkillUI.OnTalentSkillToggle()
    elseif CurSelectPage==PageEnum.Practice then
        CurSelectPage = nil
        RoleSkillUI.OnPracticeSkillToggle()
    elseif CurSelectPage==PageEnum.Guild then
        CurSelectPage = nil
        RoleSkillUI.OnGuildSkillToggle()
    end
    --小红点的刷新
    GlobalProcessing.set_role_skill_red_methods(RoleSkillUI.CheckRedPoint)
end

function RoleSkillUI.OnCloseBtnClick(guid)
    --CL.UnRegisterMessage(GM.RefreshBag, "BagUI", "Refresh");
    CL.UnRegisterMessage(GM.RefreshBag, "RoleSkillUI", "CheckRedPoint")
    CL.UnRegisterAttr(RoleAttr.RoleAttrGuildContribute, RoleSkillUI.ResetAttrGuildContribute)
    CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold, RoleSkillUI.ResetAttrBindGold)
	GUI.CloseWnd("RoleSkillUI")
end

function RoleSkillUI.OnClose(key)
    RoleSkillUI.initializeTalentData()
    RoleSkillUI.SetLastPageInvisible()
end

function RoleSkillUI.OnDestroy()
    talentSkillEdition= nil
    RoleSkillUI.OnClose("RoleSkillUI")
end

function RoleSkillUI.ResetLastSelectPage(idx)
    --do
    --    return
    --end
    if idx==PageEnum.Talent then
        local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)

        if roleLevel<30 then
            UILayout.OnTabClick(CurSelectPage, LabelList)
            CL.SendNotify(NOTIFY.ShowBBMsg,"天赋：30级开启")
            return
        end	
	elseif idx == PageEnum.Practice then
		local roleLevel = tonumber(CL.GetIntAttr(RoleAttr.RoleAttrLevel))
		if roleLevel < 45 then
            UILayout.OnTabClick(CurSelectPage, LabelList)
            CL.SendNotify(NOTIFY.ShowBBMsg,"修炼：45级开启")
            return
        end
	end
    UILayout.OnTabClick(idx, LabelList)
    if CurSelectPage == idx then
        return false
    end
    RoleSkillUI.SetLastPageInvisible()
    CurSelectPage = idx
    return true
end

function RoleSkillUI.SetLastPageInvisible()
    if CurSelectPage then
        local name = LabelList[CurSelectPage][4]
        local lastPage = _gt.GetUI(name)
        if lastPage then
            if Scrolls[CurSelectPage] ~= nil then
                local scroll = _gt.GetUI(Scrolls[CurSelectPage])
                GUI.ScrollRectSetNormalizedPosition(scroll, Vector2.New(0))
            end
        GUI.SetVisible(lastPage, false)
            end
        CurSelectPage = nil
    end
end

---服务端脚本调用刷新
function RoleSkillUI.RefreshServerData()
    if RoleSkillUI.CulSkillData == nil then
        test("RoleSkillUI.CulSkillData 为空")
        return
    end
    if CurSelectPage == PageEnum.School then
        RoleSkillUI.RefreshSchoolSkillPage()
    elseif CurSelectPage ==PageEnum.Talent then
        RoleSkillUI.RefreshTalentSkillPage()
    elseif CurSelectPage ==PageEnum.Practice then
        --RoleSkillUI.RefreshPracticeSkillPage()
        RoleSkillUI.PracticeRefresh()
    elseif CurSelectPage ==PageEnum.Guild then
        --RoleSkillUI.RefreshGuildSkillPage()
        RoleSkillUI.GuildRefresh()
    end
end

----------------------------------------------start 门派技能 start--------------------------------------
local CurSelectHeartIndex = 1 -- 当前选中心法的下标
local IndexToHeartItemGuid = {}
function RoleSkillUI.OnSchoolSkillToggle()
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(LabelList[1][1])
	local Level = MainUI.MainUISwitchConfig["技能"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		if not RoleSkillUI.ResetLastSelectPage(PageEnum.School) then
			return
		end
        CL.SendNotify(NOTIFY.SubmitForm, "FormPlayerSkill", "GetData")
		CurSelectHeartIndex = 1
		RoleSkillUI.RefreshSchoolSkillPage()
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(CurSelectPage, LabelList)
		return
	end
end

local positionX = 396

function RoleSkillUI.CreateSchoolSkillPage(pageName)
    local panelBg = _gt.GetUI("panelBg")
    local skillBg = GUI.GroupCreate(panelBg, pageName, 7, -2, 1197, 639);
    _gt.BindName(skillBg, pageName)

    --门派心法头部标题
    local heartSkill_Title = GUI.ImageCreate(skillBg, "heartSkill_Title", "1800700080", 130, 60, false, 245, 36);
    SetAnchorAndPivot(heartSkill_Title, UIAnchor.Top, UIAroundPivot.Top)
    local heartSkill_Txt = GUI.CreateStatic(heartSkill_Title, "heartSkill_Txt", "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">" .. "" .. "</size></color>", 0, 0, 150, 50, "system", true);
    _gt.BindName(heartSkill_Txt, "heartSkill_Txt")
    SetAnchorAndPivot(heartSkill_Txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(heartSkill_Txt, TextAnchor.MiddleCenter)
    --心法效果
    local heartSkill_Effect = GUI.CreateStatic(skillBg, "heartSkill_Effect", "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">" .. "心法效果:" .. "</size></color>", positionX, 110, 150, 27, "system", true);
    _gt.BindName(heartSkill_Effect, "heartSkill_Effect")
    SetAnchorAndPivot(heartSkill_Effect, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    --心法tips
    local heartSkill_Tips = GUI.CreateStatic(skillBg, "heartSkill_Tips", "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">" .. "强身健体是习武之人的根本，每学习一级可以提高一定的气血上限。" .. "</size></color>", positionX, 140, 720, 60, "system", true, false);
    _gt.BindName(heartSkill_Tips, "heartSkill_Tips")
    SetAnchorAndPivot(heartSkill_Tips, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local cutLine1 = GUI.ImageCreate(skillBg, "cutLine1", "1800700060", 155, 200, false, 715, 3);
    SetAnchorAndPivot(cutLine1, UIAnchor.Top, UIAroundPivot.Top)

    local schoolSkill_Bg = GUI.ImageCreate(skillBg, "schoolSkill_Bg", "1800400200", 153, 12, false, 715, 215);
    SetAnchorAndPivot(schoolSkill_Bg, UIAnchor.Center, UIAroundPivot.Center)
    local schoolChildVecSize = Vector2.New(345, 205)

    --创建技能列表
    local schoolSkillScroll = GUI.LoopScrollRectCreate(schoolSkill_Bg, "schoolSkillScroll", 2, 0, 700, 210,
            "RoleSkillUI", "CreateSchoolSkillItem", "RoleSkillUI", "RefreshSchoolSkillItem", 0, true,
            schoolChildVecSize, 1, UIAroundPivot.Left, UIAnchor.Left)
    _gt.BindName(schoolSkillScroll, "schoolSkillScroll")
    GUI.ScrollRectSetChildSpacing(schoolSkillScroll, Vector2.New(5, 0));
    schoolSkillScroll:RegisterEvent(UCE.EndDrag)
    GUI.RegisterUIEvent(schoolSkillScroll, UCE.EndDrag, "RoleSkillUI", "OnSchoolSkillScrollEndDrag")
    local leftArrow = GUI.ImageCreate(schoolSkill_Bg, "leftArrow", "1800607340", -6, -20)
    UILayout.SetSameAnchorAndPivot(leftArrow, UILayout.Left)
    GUI.SetEulerAngles(leftArrow, Vector3.New(0, 0, -90))
    _gt.BindName(leftArrow, "leftArrow")
    local rightArrow = GUI.ImageCreate(schoolSkill_Bg, "rightArrow", "1800607340", 6, -20)
    UILayout.SetSameAnchorAndPivot(rightArrow, UILayout.Right)
    GUI.SetEulerAngles(rightArrow, Vector3.New(0, 0, 90))
    _gt.BindName(rightArrow, "rightArrow")

    --技能学习消耗
    local skill_LearnCoinCost = GUI.CreateStatic(skillBg, "skill_LearnCoinCost", "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">消耗银币</size></color>", positionX, -42, 90, 27, "system", true);
    --_gt.BindName(skill_LearnCoinCost, "skill_LearnCoinCost")
    SetAnchorAndPivot(skill_LearnCoinCost, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    local skill_LearnCoinCost_Bg = GUI.ImageCreate(skill_LearnCoinCost, "skill_LearnCoinCost_Bg", "1800700010", 100, -2, false, 240, 30);
    local coinIcon_Cost = GUI.ImageCreate(skill_LearnCoinCost_Bg, "coinIcon_Cost", "1800408280", 0, 0);
    _gt.BindName(coinIcon_Cost, "coinIcon_Cost")
    local coinCount_Cost = GUI.CreateStatic(skill_LearnCoinCost_Bg, "coinCount_Cost", "999999999", 0, 0, 200, 40, "system", true);		--银币消耗
    _gt.BindName(coinCount_Cost, "coinCount_Cost")
    GUI.StaticSetFontSize(coinCount_Cost, fontSize)
    SetAnchorAndPivot(coinCount_Cost, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(coinCount_Cost, TextAnchor.MiddleCenter)

    local skill_LearnExpCost = GUI.CreateStatic(skillBg, "skill_LearnExpCost", "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">消耗经验</size></color>", positionX, -97, 90, 27, "system", true);
    _gt.BindName(skill_LearnExpCost, "skill_LearnExpCost")
    SetAnchorAndPivot(skill_LearnExpCost, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    local skill_LearnExpCost_Bg = GUI.ImageCreate(skill_LearnExpCost, "skill_LearnExpCost_Bg", "1800700010", 100, -2, false, 240, 30);
    local expIcon_Cost = GUI.ImageCreate(skill_LearnExpCost_Bg, "expIcon_Cost", "1800408330", 0, 0);
    local expCount_Cost = GUI.CreateStatic(skill_LearnExpCost_Bg, "expCount_Cost", "999999999", 0, 0, 200, 40, "system", true);
    _gt.BindName(expCount_Cost, "expCount_Cost")
    GUI.StaticSetFontSize(expCount_Cost, fontSize)
    SetAnchorAndPivot(expCount_Cost, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(expCount_Cost, TextAnchor.MiddleCenter)
    GUI.SetVisible(skill_LearnExpCost, false)

    --创建心法滑动列表
    local heartChildVecSize = Vector2.New(280, 100)
    local heartSkillScr_Bg = GUI.ImageCreate(skillBg, "heartSkillScr_Bg", "1800400200", 72, 60, false, 295, 540);
    SetAnchorAndPivot(heartSkillScr_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local heartSkillScroll = GUI.LoopScrollRectCreate(heartSkillScr_Bg, "heartSkillScroll", 6, 6, 285, 530,
            "RoleSkillUI", "CreateHeartSkillItem", "RoleSkillUI", "RefreshHeartSkillItem", 0, false,
            heartChildVecSize, 1, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(heartSkillScroll, "heartSkillScroll")

    local cutLine2 = GUI.ImageCreate(skillBg, "cutLine2", "1800700060", 155, -165, false, 715, 3);
    SetAnchorAndPivot(cutLine2, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local learnSkillBtn_One = GUI.ButtonCreate(skillBg, "learnSkill_One", "1800102090", -88, -99, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">学习技能</size></color>", 160, 45, false);
    SetAnchorAndPivot(learnSkillBtn_One, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    RoleSkillUI.SetBtnOutline(learnSkillBtn_One)
    GUI.RegisterUIEvent(learnSkillBtn_One, UCE.PointerClick, "RoleSkillUI", "OnLearnSkillBtn_OneClick")

    local learnSkillBtn_All = GUI.ButtonCreate(skillBg, "learnSkill_All", "1800102090", -88, -39, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">一键升级</size></color>", 160, 45, false);
    SetAnchorAndPivot(learnSkillBtn_All, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    RoleSkillUI.SetBtnOutline(learnSkillBtn_All)
    GUI.RegisterUIEvent(learnSkillBtn_All, UCE.PointerClick, "RoleSkillUI", "OnLearnSkillBtn_AllClick")

    local learAllSkillCheckBox = GUI.CheckBoxCreate(skillBg, "learAllSkillCheckBox", "1800607150", "1800607151", -360, -39, Transition.None, false, 40, 40)
    SetAnchorAndPivot(learAllSkillCheckBox, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.CheckBoxSetCheck(learAllSkillCheckBox, RoleSkillUI.isSelectLearnAllSkill);

    local CheckBoxLabel = GUI.CreateStatic(learAllSkillCheckBox, "learAllSkillCheckBoxLabel", "所有技能", -50, 0, 89, 27)
    GUI.StaticSetFontSize(CheckBoxLabel, UIDefine.FontSizeM);
    SetAnchorAndPivot(CheckBoxLabel, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(CheckBoxLabel, ColorType_FontColor2);
    GUI.RegisterUIEvent(learAllSkillCheckBox, UCE.PointerClick, "RoleSkillUI", "OnLearAllSkillCheckBoxChanged");

    return skillBg
end

function RoleSkillUI.RefreshSchoolSkillPage()
    --门派技能背景
    local pageName = LabelList[PageEnum.School][4]
    local skillBg = _gt.GetUI(pageName)
    if not skillBg then
        skillBg = RoleSkillUI.CreateSchoolSkillPage(pageName)
    else
        GUI.SetVisible(skillBg, true)
    end
    local serverData = RoleSkillUI.serverData
    if not serverData then
        return
    end

    local heartSkillScroll = _gt.GetUI("heartSkillScroll")
	--GUI.LoopScrollRectSrollToCell(heartSkillScroll, 0, 0)
    GUI.LoopScrollRectSetTotalCount(heartSkillScroll, #serverData.HeartMethod)
    GUI.LoopScrollRectRefreshCells(heartSkillScroll)
end

--更新心法名字/效果/描述信息
function RoleSkillUI.UpdateHeartInfo( skill_spell, idx )
    local heartSkill_Txt = _gt.GetUI("heartSkill_Txt")
    GUI.StaticSetText(heartSkill_Txt,"<color=#"..fontColor2.."><size="..fontSize..">"..skill_spell.Name.."</size></color>");
    local heartSkill_Tips = _gt.GetUI("heartSkill_Tips")
    GUI.StaticSetText(heartSkill_Tips,"<color=#"..fontColor2.."><size="..fontSize..">"..skill_spell.Info.."</size></color>");
    local serverData = RoleSkillUI.serverData
    if not serverData then
        return
    end
    local consume = serverData.Consume[idx]
    local skill_LearnExpCost = _gt.GetUI("skill_LearnExpCost")
    if serverData.IsShowExpConsume and serverData.IsShowExpConsume ~= 0 then
        GUI.SetVisible(skill_LearnExpCost, true)
        local expCount_Cost = _gt.GetUI("expCount_Cost")
        GUI.StaticSetText(expCount_Cost, consume.Exp)
    else
        GUI.SetVisible(skill_LearnExpCost, false)
    end
    local mt = UIDefine.GetMoneyEnum(consume.MoneyType)
    local num = CL.GetAttr(mt)
    local coinCount_Cost = _gt.GetUI("coinCount_Cost")
    GUI.StaticSetText(coinCount_Cost, consume.MoneyVal)
    GUI.SetColor(coinCount_Cost, num >= int64.new(consume.MoneyVal) and ColorType_White or ColorType_Red)
    local coinIcon_Cost = _gt.GetUI("coinIcon_Cost")
    GUI.ImageSetImageID(coinIcon_Cost, UIDefine.AttrIcon[mt] or "1800408250")


    --门派 小红点  按钮
    if CurSelectPage == nil then
        return
    end
    local curPage=_gt.GetUI(LabelList[CurSelectPage][4])
    local learnSkill_One=GUI.GetChild(curPage,"learnSkill_One")
    local learnSkill_All=GUI.GetChild(curPage,"learnSkill_All")
    --CDebug.LogError("redPointData--SCHool"..inspect(redPointData["school_data"]))
    if redPointData then
        if redPointData["school_data"] then
            if redPointData["school_data"][CurSelectHeartIndex] then
                GlobalProcessing.SetRetPoint(learnSkill_One, true, UIDefine.red_type.common)
                GlobalProcessing.SetRetPoint(learnSkill_All, true, UIDefine.red_type.common)
            else
                GlobalProcessing.SetRetPoint(learnSkill_One, false, UIDefine.red_type.common)
                GlobalProcessing.SetRetPoint(learnSkill_All, false, UIDefine.red_type.common)
            end
        end
    end
end

function RoleSkillUI.CreateSchoolSkillItem()
    local schoolSkillScroll = _gt.GetUI("schoolSkillScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(schoolSkillScroll)
    local schoolSkillBtn = GUI.ButtonCreate(schoolSkillScroll, "schoolSkill" .. curCount, "1800700030", 0, 0, Transition.None, "", 320, 205, false);
    local schoolSkill_Icon_Bg = GUI.ImageCreate(schoolSkillBtn, "schoolSkill_Icon_Bg", "1800400050", 15, 15);
    SetAnchorAndPivot(schoolSkill_Icon_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local schoolSkill_Icon = GUI.ImageCreate(schoolSkill_Icon_Bg, "schoolSkill_Icon", "1800408170", 0, -1, false, iconWidth, iconHeight);
    SetAnchorAndPivot(schoolSkill_Icon, UIAnchor.Center, UIAroundPivot.Center)

    local schoolSkill_Des_Scr = GUI.ScrollRectCreate(schoolSkillBtn, "schoolSkill_Des_Scr", -10, 120, 285, 78, 0, false, Vector2.New(285, 26), UIAroundPivot.Top, UIAnchor.Top);
    SetAnchorAndPivot(schoolSkill_Des_Scr, UIAnchor.Top, UIAroundPivot.Top)

    local schoolSkill_Des = GUI.CreateStatic(schoolSkill_Des_Scr, "schoolSkill_Des", "", 0, 0, 285, 26, "system", true, false);

    local schoolSkill_Name = GUI.CreateStatic(schoolSkillBtn, "schoolSkill_Name", "", 105, 20, 100, 30, "system", true);
    SetAnchorAndPivot(schoolSkill_Name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local schoolSkill_Level = GUI.CreateStatic(schoolSkillBtn, "schoolSkill_Level", "", -25, 20, 80, 27, "system", true);
    SetAnchorAndPivot(schoolSkill_Level, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetIsOutLine(schoolSkill_Level, true);
    GUI.SetOutLine_Color(schoolSkill_Level, Color.New(0 / 255, 0 / 255, 0 / 255));
    GUI.SetOutLine_Distance(schoolSkill_Level, 1);

    local schoolSkill_Type = GUI.CreateStatic(schoolSkillBtn, "schoolSkill_Type", "", 105, 60, 100, 30, "system", true);
    SetAnchorAndPivot(schoolSkill_Type, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    SetAnchorAndPivot(schoolSkill_Des, UIAnchor.Top, UIAroundPivot.Top)
    GUI.StaticSetAlignment(schoolSkill_Des, TextAnchor.UpperLeft);
    local schoolSkill_Cost = GUI.CreateStatic(schoolSkillBtn, "schoolSkill_Cost", "", -50, 60, 87, 27, "system", true);
    SetAnchorAndPivot(schoolSkill_Cost, UIAnchor.TopRight, UIAroundPivot.TopRight)
    return schoolSkillBtn
end

function RoleSkillUI.RefreshSchoolSkillItem(parameter)
    local serverData = RoleSkillUI.serverData
    if not serverData then
        return
    end

    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local heartId = serverData.HeartMethod[CurSelectHeartIndex]

    local skill_spell = DB.GetOnceSkill_SpellByKey2(heartId)
    local skill = DB.GetOnceSkillByKey1(skill_spell["Skill" .. index])
    local schoolSkillBtn = GUI.GetByGuid(guid)
    local skill_Level = serverData.HeartLevel[CurSelectHeartIndex]

    GlobalUtils.AddSkillIconTypeTipSp(schoolSkillBtn, skill.Id, -10, 20)

    local schoolSkill_Des = nil;
    local schoolSkill_Des_Scr = nil;

    local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    local tmpSkillLevel = skill_spell["Level" .. index]
    if skill_spell ~= nil then
        local schoolSkill_Icon = GUI.GetChildByPath(schoolSkillBtn, "schoolSkill_Icon_Bg/schoolSkill_Icon")
        GUI.ImageSetImageID(schoolSkill_Icon, tostring(skill.Icon))

        local tmpStr = nil;
        if roleLevel < tmpSkillLevel then
            tmpStr = skill.LockInfo
            GUI.SetWidth(schoolSkill_Icon, 42);
            GUI.SetHeight(schoolSkill_Icon, 53);
            GUI.ImageSetImageID(schoolSkill_Icon, "1800408170");
        else
            tmpStr = skill.Info
            GUI.SetWidth(schoolSkill_Icon, 70);
            GUI.SetHeight(schoolSkill_Icon, 70);
        end

        local newLineCount = RoleSkillUI.GetLineCount(tmpStr, 285);
        schoolSkill_Des_Scr = GUI.GetChild(schoolSkillBtn, "schoolSkill_Des_Scr")
        GUI.ScrollRectSetChildSize(schoolSkill_Des_Scr, Vector2.New(285, 26 * newLineCount))

        local str = string.gsub(tmpStr, "\\n", "\n");
        schoolSkill_Des = GUI.GetChild(schoolSkill_Des_Scr, "schoolSkill_Des")
        GUI.StaticSetText(schoolSkill_Des, "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">" .. str .. "</size></color>")

		 GUI.ScrollRectSetNormalizedPosition(schoolSkill_Des_Scr, Vector2.New(0, 1))
        if newLineCount <= 3 then
            --禁用滑动
			GUI.ScrollRectSetVertical(schoolSkill_Des_Scr, false);
            GUI.SetPositionY(schoolSkill_Des, 120)
        else
			GUI.ScrollRectSetVertical(schoolSkill_Des_Scr, true);
		end
    end

    local schoolSkill_Name = GUI.GetChild(schoolSkillBtn, "schoolSkill_Name")
    GUI.StaticSetText(schoolSkill_Name, "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">" .. skill.Name .. "</size></color>")

    local schoolSkill_Level = GUI.GetChild(schoolSkillBtn, "schoolSkill_Level")
    GUI.StaticSetText(schoolSkill_Level, "<color=#ffffff><size=" .. fontSize .. ">" .. tonumber(skill_Level) + CL.GetIntCustomData("PlayerSkill_ChangeAllLevel") .. "级</size></color>")

    local schoolSkill_Type = GUI.GetChild(schoolSkillBtn, "schoolSkill_Type")
    GUI.StaticSetText(schoolSkill_Type, "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">" .. GlobalUtils.GetSkillIconTypeTipString(skill.Id) .. "</size></color>")

    local costDes = GlobalUtils.GetSkillCostStr(skill.Id, skill_Level, skill)
    local schoolSkill_Cost = GUI.GetChild(schoolSkillBtn, "schoolSkill_Cost")
    GUI.StaticSetText(schoolSkill_Cost, "<color=#" .. fontColor1 .. "><size=" .. fontSize .. ">" .. costDes .. "</size></color>")
end

function RoleSkillUI.CreateHeartSkillItem()
    local heartSkillScroll = _gt.GetUI("heartSkillScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(heartSkillScroll) + 1
    local heartSkillBtn = GUI.CheckBoxExCreate(heartSkillScroll, "schoolSkillItem" .. curCount, "1800700030", "1800700040", 0, 0, false, 0, 0)
    local heartSkill_Icon_Bg = GUI.ImageCreate(heartSkillBtn, "heartSkill_Icon_Bg", "1800400050", 10, 10, false, 80, 81);
    local heartSkill_Icon = GUI.ImageCreate(heartSkill_Icon_Bg, "heartSkill_Icon", "1900000000", 0, -1, false, iconWidth, iconHeight);

    SetAnchorAndPivot(heartSkill_Icon, UIAnchor.Center, UIAroundPivot.Center)
    local heartSkill_Name = GUI.CreateStatic(heartSkillBtn, "heartSkill_Name", "", 105, -20, 100, 30, "system", true);
    SetAnchorAndPivot(heartSkill_Name, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(heartSkill_Name, ColorType_FontColor2)
    GUI.StaticSetFontSize(heartSkill_Name, fontSize_BigOne)

    local heartSkill_Level = GUI.CreateStatic(heartSkillBtn, "heartSkill_Level", "", 105, 15, 200, 30, "system", true);
    SetAnchorAndPivot(heartSkill_Level, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(heartSkill_Level, ColorType_FontColor1)
    GUI.StaticSetFontSize(heartSkill_Level, fontSize)
    GUI.RegisterUIEvent(heartSkillBtn, UCE.PointerClick, "RoleSkillUI", "OnSelectHeartSkill");
    return heartSkillBtn;
end

function RoleSkillUI.RefreshHeartSkillItem(parameter)
    local serverData = RoleSkillUI.serverData
    if not serverData then
        return
    end
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	IndexToHeartItemGuid[index] = guid
	local skill_spell = DB.GetOnceSkill_SpellByKey2(serverData.HeartMethod[index])
	local heartSkillBtn = GUI.GetByGuid(guid)
	GUI.SetData(heartSkillBtn, "skillId", skill_spell.Id)
	local heartSkill_Icon_Bg = GUI.GetChild(heartSkillBtn, "heartSkill_Icon_Bg")
	local heartSkill_Icon = GUI.GetChild(heartSkill_Icon_Bg, "heartSkill_Icon")
	GUI.ImageSetImageID(heartSkill_Icon, tostring(skill_spell.Icon))
	local heartSkill_Name = GUI.GetChild(heartSkillBtn, "heartSkill_Name")
	GUI.StaticSetText(heartSkill_Name, skill_spell.Name)
	local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
	local skill_Level = serverData.HeartLevel[index]
	local heartSkill_Level = GUI.GetChild(heartSkillBtn, "heartSkill_Level")
	--新增心法等级提高
	if CL.GetIntCustomData("PlayerSkill_ChangeAllLevel") ~= 0 then
		skill_Level = tostring(skill_Level).."<color=#007633ff>(+" .. CL.GetIntCustomData("PlayerSkill_ChangeAllLevel") .. ")</color>"
	end
	GUI.StaticSetText(heartSkill_Level, skill_Level .. "/" .. roleLevel)
	if CurSelectHeartIndex == index then
		GUI.CheckBoxExSetCheck(heartSkillBtn, true)
		RoleSkillUI.OnSelectHeartSkill(guid, true)
	else
		GUI.CheckBoxExSetCheck(heartSkillBtn, false)
	end

    --列表处小红点

    if redPointData and  next(redPointData["school_data"]) then
        local curData=redPointData["school_data"]
        if curData[index] then
            GlobalProcessing.SetRetPoint(heartSkill_Icon, true, UIDefine.red_type.icon)
        else
            GlobalProcessing.SetRetPoint(heartSkill_Icon, false, UIDefine.red_type.icon)
        end
    end
end

local MAX_VISIBLE_SCHOOL_SKILL_COUNT = 2
local Current_School_Skill_Count = 2

function RoleSkillUI.OnSelectHeartSkill(guid, forceRefresh)
    local heartSkillBtn = GUI.GetByGuid(guid)
    local index = GUI.CheckBoxExGetIndex(heartSkillBtn)
    index = index + 1
    if  not forceRefresh and index == CurSelectHeartIndex then
        GUI.CheckBoxExSetCheck(heartSkillBtn, true)
        --return
    end
    if CurSelectHeartIndex ~= index then
        local lastbtn = GUI.GetByGuid(IndexToHeartItemGuid[CurSelectHeartIndex])
        GUI.CheckBoxExSetCheck(lastbtn, false)
    end
    local serverData = RoleSkillUI.serverData
    if not serverData then
        return
    end
    CurSelectHeartIndex = index
    local skill_spell = DB.GetOnceSkill_SpellByKey2(serverData.HeartMethod[index])
    Current_School_Skill_Count = 0
    for i = 1, 5 do -- 心法技能最多五个，并且配置从1开始，紧挨着
        if skill_spell["Skill" .. i] == 0 then
            break
        end
        Current_School_Skill_Count = Current_School_Skill_Count + 1
    end
    local schoolSkillScroll = _gt.GetUI("schoolSkillScroll")
    GUI.LoopScrollRectSetTotalCount(schoolSkillScroll, Current_School_Skill_Count)
    GUI.LoopScrollRectRefreshCells(schoolSkillScroll)
    RoleSkillUI.UpdateHeartInfo(skill_spell, index)
    local startX = 1
    --GUI.ScrollRectSetNormalizedPosition(schoolSkillScroll, Vector2.New(startX, 0))
    RoleSkillUI.SetArrowVisible(startX)
	
end

function RoleSkillUI.OnLearnSkillBtn_OneClick(guid)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPlayerSkill", "ClkStudySkill", CurSelectHeartIndex)
end

function RoleSkillUI.OnLearnSkillBtn_AllClick(guid)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPlayerSkill", "ClkOneKeyStudySkill", RoleSkillUI.isSelectLearnAllSkill and -1 or CurSelectHeartIndex)
end

function RoleSkillUI.OnLearAllSkillCheckBoxChanged(guid)
    RoleSkillUI.isSelectLearnAllSkill = not RoleSkillUI.isSelectLearnAllSkill
end

function RoleSkillUI.OnSchoolSkillScrollEndDrag(guid)
    local scr = GUI.GetByGuid(guid)
    if scr then
        local vec = GUI.GetNormalizedPosition(scr)
        RoleSkillUI.SetArrowVisible(vec.x)
    end
end

function RoleSkillUI.SetArrowVisible(x)
    local leftArrow = _gt.GetUI("leftArrow")
    local rightArrow = _gt.GetUI("rightArrow")
    if Current_School_Skill_Count > MAX_VISIBLE_SCHOOL_SKILL_COUNT then
        GUI.SetVisible(leftArrow, x < 0.99)
        GUI.SetVisible(rightArrow, x > 0.01)
    else
        GUI.SetVisible(leftArrow, false)
        GUI.SetVisible(rightArrow, false)
    end
end
----------------------------------------------end 门派技能 end-------------------------------------

----------------------------------------------start 天赋技能 start--------------------------------------

RoleSkillUI.currentSelectTalentItemId=0  --当前点击的天赋技能
local roleTalentMaxLevel=120  --游戏角色最高等级
local roleTalentMinLevel=30     --游戏角色最低等级
local currentJob=nil  --角色当前的职业
local roleCurrentLevel=0   --角色当前等级
local roleSelectSchool=nil --天赋技能显示当前门派技能页面  角色选择的门派
local roleJoinedSchool={}   --角色加入过的门派
local roleCurrentSchoolTalentSkillList={}  --角色当前选择的门派的天赋技能
local roleCurrentSchoolLearnedOrEquipTalentSkillList={} --角色当前选择的门派学习过或者装备的天赋技能
local table_tmp={}
--门派技能列表
local talentSkillList = nil
local roleLearnedSKillid =nil
-------------------------------------------天赋技能的-------------------------------
--门派的图片
local RoleSchoolBigPic = {  [1] ="1800102020", [2] ="1800102030", [3] ="1800102040", [4] ="1800102050", [5] ="1800102060", [6] ="1800102070", }
local RoleSchoolBigPicTwo = {  ["Job_31"] ="1800102020", ["Job_32"] ="1800102030", ["Job_33"] ="1800102040", ["Job_34"] ="1800102050", ["Job_35"] ="1800102060", ["Job_36"] ="1800102070", }
--门派列表
local SchoolList={"花果山","西海龙宫","慈恩寺","流沙界","净坛禅院","酆都"}
local SchoolListTwo={ ["Job_31"]="花果山",["Job_32"]="西海龙宫",["Job_33"]="慈恩寺",["Job_34"]="流沙界",["Job_35"]="净坛禅院",["Job_36"]="酆都" }

--local inspect = require("inspect")
-------------------------------------------------------------------------------------------------------------

function RoleSkillUI.OnTalentSkillToggle()
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(LabelList[2][1])
	local Level = MainUI.MainUISwitchConfig["技能"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		if not RoleSkillUI.ResetLastSelectPage(PageEnum.Talent) then
			return
		end
		RoleSkillUI.initializeTalentData()
		local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
		roleCurrentLevel = roleLevel
		--从配置中获取到所有天赋技能的相关信息
		talentSkillList = UIDefine.PlayerSkillSpell.Spell_Config
		if talentSkillEdition == nil  then
			talentSkillEdition = ""
		end
		local talentSkillItemScroll = _gt.GetUI("talentSkillItemScroll")
		if talentSkillItemScroll then
			GUI.LoopScrollRectSrollToCell(talentSkillItemScroll, 0, 0)
		end
		--监测背包如果背包中刷新了  那么刷新一下天赋界面
		--主要是天赋节能书
		CL.RegisterMessage(GM.RefreshBag, "RoleSkillUI", "CheckRedPoint")
		CL.SendNotify(NOTIFY.SubmitForm,"FormPlayerSkillSpell"," Check_When_Open_Wnd",talentSkillEdition)
		--RoleSkillUI.RefreshTalentSkillPage()
	else
        --RoleSkillUI.OnSchoolSkillToggle()
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(CurSelectPage, LabelList)
		return
	end
	
end

function RoleSkillUI.CreateTalentSkillPage(pageName)
    --pageName 是 talentSkillPage
    local panelBg=_gt.GetUI("panelBg")
    local skillBg=GUI.GroupCreate(panelBg,pageName,7,-2,1197,639)
    _gt.BindName(skillBg,pageName)

    local talentSkillScroll_Bg=GUI.ImageCreate(skillBg,"talentSkillScroll_Bg","1800400200",-10,-10,false,1030,480)
    SetAnchorAndPivot(talentSkill_Bg,UIAnchor.Center,UIAroundPivot.Center)

    local talentSkillItemScroll =GUI.LoopScrollRectCreate(talentSkillScroll_Bg,"talentSkillItemScroll",0,5,1000,470,
    "RoleSkillUI","CreateTalentSkillItem","RoleSkillUI","RefreshTalentSkillItem",0,false,
            Vector2.New(1000, 112), 1, UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(talentSkillItemScroll,Vector2.New(0,5))
    _gt.BindName(talentSkillItemScroll,"talentSkillItemScroll")


    --门派选择  因为没有下拉框  使用button就行实现
    local schoolTalentChooseBtn=GUI.ButtonCreate(skillBg,"schoolTalentChooseBtn","1801102010",90,-30,Transition.ColorTint,"",180,50,false)
    SetAnchorAndPivot(schoolTalentChooseBtn,UIAnchor.BottomLeft,UIAroundPivot.BottomLeft)
    RoleSkillUI.SetBtnOutline(schoolTalentChooseBtn)
    GUI.RegisterUIEvent(schoolTalentChooseBtn,UCE.PointerClick,"RoleSkillUI","OnSchoolTalentChooseBtnClick")

    local schoolTalentChooseBtn_SchoolIcon=GUI.ImageCreate(schoolTalentChooseBtn,"schoolTalentChooseBtn_SchoolIcon","",8,0,false,47,47)
    SetAnchorAndPivot(schoolTalentChooseBtn_SchoolIcon,UIAnchor.Left,UIAroundPivot.Left)

    local schoolTalentChooseBtn_SchoolName=GUI.CreateStatic(schoolTalentChooseBtn,"schoolTalentChooseBtn_SchoolName","",18,0,100,50)
    SetAnchorAndPivot(schoolTalentChooseBtn_SchoolName,UIAnchor.Center,UIAroundPivot.Center)
    GUI.StaticSetFontSize(schoolTalentChooseBtn_SchoolName,20)
    GUI.SetColor(schoolTalentChooseBtn_SchoolName,ColorType_FontColor2)
    --向上icon
    local schoolTalentChooseBtn_UpIcon=GUI.ImageCreate(schoolTalentChooseBtn,"schoolTalentChooseBtn_UpIcon","1800707070",-40,0)
    SetAnchorAndPivot(schoolTalentChooseBtn_UpIcon,UIAnchor.Right,UIAroundPivot.Right)
    GUI.SetEulerAngles(schoolTalentChooseBtn_UpIcon, Vector3.New(0, 0, 180))

    --文本内容：只有角色当前所属的门派天赋才能学习、装备并生效
    --文本
    local talentSkillTipStr="只有角色当前所属的门派天赋才能学习、装备并生效"
    local talentSkillTip=GUI.CreateStatic(skillBg,"talentSkillTip",talentSkillTipStr,-10,-5,600,100)
    GUI.StaticSetFontSize(talentSkillTip,24)
    GUI.SetColor(talentSkillTip,ColorType_FontColor2)
    SetAnchorAndPivot(talentSkillTip,UIAnchor.Bottom,UIAroundPivot.Bottom)
    --学习技能按钮
    local LearnSkillBtn = GUI.ButtonCreate(skillBg, "LearnSkillBtn", "1800102090", -150, -32, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">学习技能</size></color>", 160, 45, false)
    SetAnchorAndPivot(LearnSkillBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    RoleSkillUI.SetBtnOutline(LearnSkillBtn)
    GUI.RegisterUIEvent(LearnSkillBtn, UCE.PointerClick, "RoleSkillUI", "OnLearnSkillBtn_Click")
    --装备技能按钮
    local equipSkillBtn = GUI.ButtonCreate(skillBg, "equipSkillBtn", "1800102090", -150,-32, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">装备天赋</size></color>", 160, 45, false);
    SetAnchorAndPivot(equipSkillBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    RoleSkillUI.SetBtnOutline(equipSkillBtn)
    GUI.SetVisible(equipSkillBtn,false)
    GUI.RegisterUIEvent(equipSkillBtn, UCE.PointerClick, "RoleSkillUI", "OnEquipSkillBtn_Click")

end
--天赋技能界面的刷新方法
function RoleSkillUI.RefreshTalentSkillPage()
    if CurSelectPage~=PageEnum.Talent then
        return
    end
    talentSkillEdition=UIDefine.PlayerSkillSpell.Edition --版本号
    local pageName=LabelList[PageEnum.Talent][4]
    local skillBg=_gt.GetUI(pageName)
    if not skillBg then
        skillBg=RoleSkillUI.CreateTalentSkillPage(pageName)
    else
        GUI.SetVisible(skillBg,true)
    end

    ------------------全局变量的赋值-----------------------------
    --获取角色当前的职业
    local roleJob="Job_"..tostring(CL.GetAttr(RoleAttr.RoleAttrJob1))
    currentJob=roleJob
    if roleSelectSchool==nil then
        roleSelectSchool=currentJob
    end
    --获取角色专职的门派
    for i = 31, 36 do
        local roleJoined=CL.GetIntCustomData("ChangeOccu_UsedSchool_"..i)
        if tonumber(roleJoined)==1 then
            local index=i%30
            roleJoinedSchool[index]=SchoolList[index]
        end
    end

    --获取角色学过那么天赋技能
    roleLearnedSKillid=UIDefine.PlayerSkillSpell.Player_State

    --角色当前门派的所有天赋技能
    roleCurrentSchoolTalentSkillList=talentSkillList[roleSelectSchool]
    --角色当前门派学习过的天赋技能
    roleCurrentSchoolLearnedOrEquipTalentSkillList=roleLearnedSKillid[roleSelectSchool]

    --------------------------------------------------------------
    --界面的UI刷新
    local talentSkillPage=_gt.GetUI("talentSkillPage")
    local schoolTalentChooseBtn=GUI.GetChild(talentSkillPage,"schoolTalentChooseBtn")
    local schoolTalentChooseBtn_SchoolIcon=GUI.GetChild(schoolTalentChooseBtn,"schoolTalentChooseBtn_SchoolIcon")
    local schoolTalentChooseBtn_SchoolName=GUI.GetChild(schoolTalentChooseBtn,"schoolTalentChooseBtn_SchoolName")
    local LearnSkillBtn=GUI.GetChild(talentSkillPage,"LearnSkillBtn")
    local equipSkillBtn=GUI.GetChild(talentSkillPage,"equipSkillBtn")
    local talent_tips=GUI.GetChild(talentSkillPage,"talent_tips")
    local LearnSkillBtnInTalentTips=GUI.GetChild(talent_tips,"LearnSkillBtnInTalentTips")
    local equipSkillBtnInTalentTips=GUI.GetChild(talent_tips,"equipSkillBtnInTalentTips")

    GUI.ImageSetImageID(schoolTalentChooseBtn_SchoolIcon,RoleSchoolBigPicTwo[roleSelectSchool])
    GUI.StaticSetText(schoolTalentChooseBtn_SchoolName,SchoolListTwo[roleSelectSchool])
    --技能学习还是装备的转换
    if roleCurrentSchoolLearnedOrEquipTalentSkillList[tonumber(RoleSkillUI.currentSelectTalentItemId)] then
        GUI.SetVisible(LearnSkillBtn,false)
        GUI.SetVisible(equipSkillBtn,true)
        GUI.SetVisible(LearnSkillBtnInTalentTips,false)
        GUI.SetVisible(equipSkillBtnInTalentTips,true)
    else
        GUI.SetVisible(equipSkillBtn,false)
        GUI.SetVisible(LearnSkillBtn,true)
        GUI.SetVisible(LearnSkillBtnInTalentTips,true)
        GUI.SetVisible(equipSkillBtnInTalentTips,false)
    end

    --当前角色门派与选择的门派不一样   那就置灰学习和装备按钮
    if roleJob~=roleSelectSchool then
        GUI.ButtonSetShowDisable(LearnSkillBtn,false)
        GUI.ButtonSetShowDisable(equipSkillBtn,false)
        GUI.ButtonSetShowDisable(LearnSkillBtnInTalentTips,false)
        GUI.ButtonSetShowDisable(equipSkillBtnInTalentTips,false)
    else
        GUI.ButtonSetShowDisable(LearnSkillBtn,true)
        GUI.ButtonSetShowDisable(equipSkillBtn,true)
        GUI.ButtonSetShowDisable(LearnSkillBtnInTalentTips,true)
        GUI.ButtonSetShowDisable(equipSkillBtnInTalentTips,true)
    end

    local talentSkillItemScroll = _gt.GetUI("talentSkillItemScroll")
    GUI.LoopScrollRectSetTotalCount(talentSkillItemScroll,math.floor((roleTalentMaxLevel-roleTalentMinLevel)/10)+1)
    GUI.LoopScrollRectRefreshCells(talentSkillItemScroll)

end

--天赋技能中数据初始化
function RoleSkillUI.initializeTalentData()
    RoleSkillUI.currentSelectTalentItemId = 0
    currentJob = nil  --角色当前的职业
    roleCurrentLevel = 0
    roleSelectSchool = nil --天赋技能显示当前门派技能页面  角色选择的门派
    roleJoinedSchool = {}   --角色加入过的门派
    -- roleCurrentSchoolTalentSkillList = {}  --角色当前选择的门派的天赋技能
    roleCurrentSchoolLearnedOrEquipTalentSkillList = {} --角色当前选择的门派学习过或者装备的天赋技能
    table_tmp = {}
    --门派技能列表
    talentSkillList = nil
    roleLearnedSKillid = nil
end

--LoopScrollRectCreate中的创建方法
function RoleSkillUI.CreateTalentSkillItem()

    local talentSkillItemScroll=_gt.GetUI("talentSkillItemScroll")
    local curCount=GUI.LoopScrollRectGetChildInPoolCount(talentSkillItemScroll)
    local talentSkill_item_Bg=GUI.ImageCreate(talentSkillItemScroll,"talentSkill_item_Bg"..curCount,"1800600060",0,0,false,1000,50)
    SetAnchorAndPivot(talentSkill_item_Bg,UIAnchor.Top,UIAroundPivot.Top)
    --背景图片
    local talentSkill_Level_Bg=GUI.ImageCreate(talentSkill_item_Bg,"talentSkill_Level_Bg","1800700090",10,0,false,125,110)
    SetAnchorAndPivot(talentSkill_Level_Bg,UIAnchor.Left,UIAroundPivot.Left)
    --等级数字的显示
    for i = 1, 3 do
        local talentSkill_Level_Number=GUI.ImageCreate(talentSkill_Level_Bg,"talentSkill_Level_Number"..i,"1800705000",-28+(i-1)*17,0,false,28,34)
        SetAnchorAndPivot(talentSkill_Level_Number,UIAnchor.Center,UIAroundPivot.Center)
    end
    -- "级 "字配置
    local talentSkill_Level_Ji=GUI.ImageCreate(talentSkill_Level_Bg,"talentSkill_Level_Ji","1800704060",25,5)
    SetAnchorAndPivot(talentSkill_Level_Ji,UIAnchor.Center,UIAroundPivot.Center)

    for i = 1, 3 do
        local talentSkill_Level_item=GUI.CheckBoxExCreate(talentSkill_item_Bg,"talentSkill_Level_item"..i,"1800700030","1800700040",150+(i-1)*265+(i-1)*15,0,false,264,100)
        SetAnchorAndPivot(talentSkill_Level_item,UIAnchor.Left,UIAroundPivot.Left)
        GUI.RegisterUIEvent(talentSkill_Level_item, UCE.PointerClick, "RoleSkillUI", "OnSelectTalentSkillBtn_Click")

        local talentSkill_Level_item_iconBg=GUI.ImageCreate(talentSkill_Level_item,"talentSkill_Level_item_iconBg","1800400050",10,2)
        SetAnchorAndPivot(talentSkill_Level_item_iconBg,UIAnchor.Left,UIAroundPivot.Left)

        local talentSkill_Level_item_icon=GUI.ImageCreate(talentSkill_Level_item_iconBg,"talentSkill_Level_item_icon","1900000000",0,-2)
        SetAnchorAndPivot(talentSkill_Level_item_icon,UIAnchor.Center,UIAroundPivot.Center)
        GUI.SetVisible(talentSkill_Level_item_icon,false)

        local talentSkill_Level_item_lockIcon=GUI.ImageCreate(talentSkill_Level_item_iconBg,"talentSkill_Level_item_lockIcon","1800408170",0,0)
        SetAnchorAndPivot(talentSkill_Level_item_lockIcon,UIAnchor.Center,UIAroundPivot.Center)

        local talentSkill_Level_item_effect=GUI.CreateStatic(talentSkill_Level_item,"talentSkill_Level_item_effect","",-89,25,160,185,"system",true)
        GUI.StaticSetFontSize(talentSkill_Level_item_effect,24)
        SetAnchorAndPivot(talentSkill_Level_item_effect,UIAnchor.Center,UIAroundPivot.Center)
        GUI.SetVisible(talentSkill_Level_item_effect,false)
        GUI.SetScale(talentSkill_Level_item_effect,Vector3.New(0.82,0.82,0.82))

        local talentSkill_Level_item_equipState=GUI.ImageCreate(talentSkill_Level_item,"talentSkill_Level_item_equipState","1800707040",0,0)
        SetAnchorAndPivot(talentSkill_Level_item_equipState,UIAnchor.TopRight,UIAroundPivot.TopRight)
        GUI.SetVisible(talentSkill_Level_item_equipState,false)

        local talentSkill_Level_item_skillName=GUI.CreateStatic(talentSkill_Level_item,"talentSkill_Level_item_skillName","技能名字",100,0,100,50)
        SetAnchorAndPivot(talentSkill_Level_item_skillName,UIAnchor.Left,UIAroundPivot.Left)
        GUI.StaticSetFontSize(talentSkill_Level_item_skillName,20)
        GUI.SetColor(talentSkill_Level_item_skillName,ColorType_FontColor2)

        local talentSkill_Level_item_LearnTips=GUI.CreateStatic(talentSkill_Level_item,"talentSkill_Level_item_LearnTips","可学习",100,15,100,50)
        SetAnchorAndPivot(talentSkill_Level_item_LearnTips,UIAnchor.Left,UIAroundPivot.Left)
        GUI.StaticSetFontSize(talentSkill_Level_item_LearnTips,22)
        GUI.SetColor(talentSkill_Level_item_LearnTips,colorGreen)
        GUI.SetVisible(talentSkill_Level_item_LearnTips,false)
    end
    return talentSkill_item_Bg
end
--LoopScrollRectCreate中的刷新方法
function RoleSkillUI.RefreshTalentSkillItem(parameter)

    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])+1

    --local talentSkillItemScroll=_gt.GetUI("talentSkillItemScroll")
    local talentSkill_item_Bg=GUI.GetByGuid(guid)
    local talentSkill_Level_Bg=GUI.GetChild(talentSkill_item_Bg,"talentSkill_Level_Bg")
    local talentSkill_Level_Number1=GUI.GetChild(talentSkill_Level_Bg,"talentSkill_Level_Number1")
    local talentSkill_Level_Number2=GUI.GetChild(talentSkill_Level_Bg,"talentSkill_Level_Number2")

    --天赋技能等级
    if index<=7 then
        GUI.SetVisible(talentSkill_Level_Number1,false)
        GUI.ImageSetImageID(talentSkill_Level_Number2,"18007050"..(index+2).."0")
    elseif index>7 then
        GUI.SetVisible(talentSkill_Level_Number1,true)
        GUI.ImageSetImageID(talentSkill_Level_Number1,"1800705010")
        GUI.ImageSetImageID(talentSkill_Level_Number2,"18007050"..(index%8).."0")
    end

    local indexLeveSkillList=roleCurrentSchoolTalentSkillList["TalentGroup_"..index]
    if indexLeveSkillList == nil then
        return
    end
    for i = 1, 3 do
        local talentSkill_Level_item=GUI.GetChild(talentSkill_item_Bg,"talentSkill_Level_item"..i)
        local itemId=indexLeveSkillList["TalentColumn_"..i]["Id"]
        if table_tmp["Id_"..itemId]==nil then
            table_tmp["Id_"..itemId]={}

        end
        table_tmp["Id_"..itemId]=indexLeveSkillList["TalentColumn_"..i]
        GUI.SetData(talentSkill_Level_item,"itemId",itemId)

    end

    if RoleSkillUI.currentSelectTalentItemId~=nil then

        for i = 1, 3 do
            local talentSkill_Level_item=GUI.GetChild(talentSkill_item_Bg,"talentSkill_Level_item"..i)
            local itemid=GUI.GetData(talentSkill_Level_item,"itemId")

            if RoleSkillUI.currentSelectTalentItemId==itemid then
                GUI.CheckBoxExSetCheck(talentSkill_Level_item,true)
            else
                GUI.CheckBoxExSetCheck(talentSkill_Level_item,false)
            end
        end
    end

    for i = 1, 3 do

        local talentSkill_Level_item=GUI.GetChild(talentSkill_item_Bg,"talentSkill_Level_item"..i)
        local talentSkill_Level_item_icon=GUI.GetChild(talentSkill_Level_item,"talentSkill_Level_item_icon")
        local talentSkill_Level_item_lockIcon=GUI.GetChild(talentSkill_Level_item,"talentSkill_Level_item_lockIcon")
        local talentSkill_Level_item_equipState=GUI.GetChild(talentSkill_Level_item,"talentSkill_Level_item_equipState")
        local talentSkill_Level_item_skillName=GUI.GetChild(talentSkill_Level_item,"talentSkill_Level_item_skillName")
        local talentSkill_Level_item_LearnTips=GUI.GetChild(talentSkill_Level_item,"talentSkill_Level_item_LearnTips")

        local skillindex=GUI.GetData(talentSkill_Level_item,"itemId")

        if   indexLeveSkillList["TalentColumn_"..i]["TalentGroup"]==index then
            if roleCurrentSchoolLearnedOrEquipTalentSkillList[tonumber(skillindex)] then

                GUI.SetVisible(talentSkill_Level_item_lockIcon,false)
                GUI.SetVisible(talentSkill_Level_item_icon,true)
                GUI.SetVisible(talentSkill_Level_item_LearnTips,false)
                GUI.ImageSetImageID(talentSkill_Level_item_icon,indexLeveSkillList["TalentColumn_"..i]["Icon"].."")
                GUI.SetPositionY(talentSkill_Level_item_skillName,0)
                if roleCurrentSchoolLearnedOrEquipTalentSkillList[tonumber(skillindex)]==2 then
                    GUI.SetVisible(talentSkill_Level_item_equipState,true)
                else
                    GUI.SetVisible(talentSkill_Level_item_equipState,false)
                end
            else
                GUI.SetVisible(talentSkill_Level_item_lockIcon,true)
                GUI.SetVisible(talentSkill_Level_item_icon,false)
                GUI.SetVisible(talentSkill_Level_item_equipState,false)
                local haveSkillBookCount=LD.GetItemCountById(indexLeveSkillList["TalentColumn_"..i]["TalentItem"])
                if haveSkillBookCount>0 and roleCurrentLevel>=indexLeveSkillList["TalentColumn_"..i]["TalentLevel"] then
                    GUI.SetVisible(talentSkill_Level_item_LearnTips,true)
                    GUI.SetPositionY(talentSkill_Level_item_skillName,-15)
                else
                    GUI.SetVisible(talentSkill_Level_item_LearnTips,false)
                    GUI.SetPositionY(talentSkill_Level_item_skillName,0)
                end
            end
        end

        GUI.StaticSetText(talentSkill_Level_item_skillName,indexLeveSkillList["TalentColumn_"..i]["Name"])
    end
end


--[[
    以下几个函数是为了天赋技能中的门派转换
    --------------------------------------------------------------------------------
]]--

local btnWidth=160
local btnHeight=50
local internal=2
RoleSkillUI.talentSchoolTips=nil


--门派选择
function RoleSkillUI.OnSchoolTalentChooseBtnClick()
    if  RoleSkillUI.talentSchoolTips~=nil then
        GUI.Destroy(RoleSkillUI.talentSchoolTips)
        RoleSkillUI.talentSchoolTips=nil
    else
        RoleSkillUI.CreateTalentSchoolTips()
    end
end
--RoleSkillUI.selectSchoolGuid={}
function RoleSkillUI.CreateTalentSchoolTips()
    local talentSkillPage= _gt.GetUI("talentSkillPage")
    local titalentSchoolTipsps=GUI.ImageCreate(talentSkillPage,"titalentSchoolTipsps","1800400290",100,-100, false,btnWidth+10,btnHeight*#SchoolList+(#SchoolList-1)*internal+10)
    SetAnchorAndPivot(titalentSchoolTipsps,UIAnchor.BottomLeft,UIAroundPivot.BottomLeft)
    RoleSkillUI.talentSchoolTips=titalentSchoolTipsps

    for i = 1, #SchoolList do
        local SchoolName=SchoolList[i]   --门派的名字

        if SchoolName ~=nil then
            local tmpBtn=GUI.ButtonCreate(titalentSchoolTipsps,"tmpBtn"..i,"1801201200",0, -(5+(i-1)*btnHeight+(i-1)*internal),Transition.ColorTint,"", btnWidth , btnHeight ,false)
            SetAnchorAndPivot(tmpBtn,UIAnchor.Top,UIAroundPivot.Top)
            GUI.RegisterUIEvent(tmpBtn, UCE.PointerClick, "RoleSkillUI", "changeSchool")
            local tmpBtnGuid=GUI.GetGuid(tmpBtn)
            GUI.SetData(tmpBtn,"selectSchoolIndex","Job_3"..i)

            local tmpBtn_Bg=GUI.ImageCreate(tmpBtn,"tmpBtn_Bg","1801201200",0,0,false,btnWidth,btnHeight)
            SetAnchorAndPivot(tmpBtn_Bg,UIAnchor.Center,UIAroundPivot.Center)

            local schoolIcon=GUI.ImageCreate(tmpBtn,"schoolIcon",tostring(RoleSchoolBigPic[i]),0,0,false,40,40)
            SetAnchorAndPivot(schoolIcon,UIAnchor.Left,UIAroundPivot.Left)

            local btnTxt=GUI.CreateStatic(tmpBtn,"btnTxt","",10,0,100,50);
            SetAnchorAndPivot(btnTxt,UIAnchor.Center,UIAroundPivot.Center)
            GUI.SetColor(btnTxt,ColorType_FontColor2)
            GUI.StaticSetFontSize(btnTxt,22)
            GUI.StaticSetText(btnTxt,SchoolName)

            if roleJoinedSchool[i]==nil then
                GUI.ButtonSetShowDisable(tmpBtn,false)
                GUI.SetColor(btnTxt,colorTextGray)
                GUI.ImageSetGray(tmpBtn_Bg,true)
                GUI.ImageSetGray(schoolIcon,true)
            end


            local leftSp=GUI.ImageCreate(tmpBtn,"leftSp","1801208600",0,0,false,35,35)
            SetAnchorAndPivot(leftSp,UIAnchor.TopLeft,UIAroundPivot.TopLeft)
            GUI.SetVisible(leftSp,false)

            if currentJob=="Job_3"..i  then
                GUI.SetVisible(leftSp,true)
            end
            GUI.AddWhiteName(titalentSchoolTipsps,tmpBtnGuid)
        end
    end
    GUI.SetIsRemoveWhenClick(titalentSchoolTipsps, true)

end
function RoleSkillUI.changeSchool(guid)

    local btn=GUI.GetByGuid(guid)
    local btnIndex=(GUI.GetData(btn,"selectSchoolIndex"))

    roleSelectSchool=btnIndex
    RoleSkillUI.RefreshTalentSkillPage()
    RoleSkillUI.OnSchoolTalentChooseBtnClick()
end
--[[
    门派转换函数结束--------------------------------------------------------------------
]]--
--------------------------------------------------------------
--学习技能按钮点击
function RoleSkillUI.OnLearnSkillBtn_Click()
    CL.SendNotify(NOTIFY.SubmitForm,"FormPlayerSkillSpell"," Activate_Or_Equip",talentSkillEdition,RoleSkillUI.currentSelectTalentItemId)
    CL.RegisterMessage(GM.RefreshBag, "BagUI", "Refresh");
end
function RoleSkillUI.OnEquipSkillBtn_Click()
    CL.SendNotify(NOTIFY.SubmitForm,"FormPlayerSkillSpell"," Activate_Or_Equip",talentSkillEdition,RoleSkillUI.currentSelectTalentItemId)
end
--天赋技能书tips
function RoleSkillUI.TalentSkillBookTips(skillBookId)
    local talentSkillPage=_gt.GetUI("talentSkillPage")
    local TSTips=Tips.CreateByItemId(skillBookId,talentSkillPage,"TSBookTips",0,0,50)
    GUI.SetData(TSTips,"ItemId",skillBookId)
    _gt.BindName(TSTips,"TSTips")
    local wayBtn=GUI.ButtonCreate(TSTips,"wayBtn","1800402110",0,-10,Transition.ColorTint,"获取途径", 150, 50, false)
    SetAnchorAndPivot(wayBtn,UIAnchor.Bottom,UIAroundPivot.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"RoleSkillUI","onClickTalentSkillWayBtn")
    GUI.AddWhiteName(TSTips, GUI.GetGuid(wayBtn))
end
function RoleSkillUI.onClickTalentSkillWayBtn()
    local TSTips=_gt.GetUI("TSTips")
    --if TSTips==nil then
    --    test("TSTips is nil")
    --end
    if TSTips then
        Tips.ShowItemGetWay(TSTips)
    end

end
----------------------------------------------------------------
--技能点击详情显示方法
function RoleSkillUI.OnSelectTalentSkillBtn_Click(guid)
    local talentSkillBtn=GUI.GetByGuid(guid)
    local talentSkillItemId=GUI.GetData(talentSkillBtn,"itemId")
    local talentSkillPage= _gt.GetUI("talentSkillPage")
    local LearnSkillBtn =GUI.GetChild(talentSkillPage,"LearnSkillBtn")
    local equipSkillBtn=GUI.GetChild(talentSkillPage,"equipSkillBtn")

    RoleSkillUI.currentSelectTalentItemId=talentSkillItemId
    RoleSkillUI.CreateTips(talentSkillItemId,guid)
    RoleSkillUI.RefreshTalentSkillPage()

end
--技能点击显示技能
function RoleSkillUI.CreateTips(talentSkillItemId,guid)
    local talentSkillPage= _gt.GetUI("talentSkillPage")

    local item=GUI.GetByGuid(guid)
    local itemPosX=GUI.GetPositionX(item)
    local itemPosY=GUI.GetPositionY(item)
    local tipsX=0
    if itemPosX==150 then
        tipsX=80
    elseif itemPosX==430 then
        tipsX=350
    elseif itemPosX==710 then
        tipsX=50
    end

    local info=table_tmp["Id_"..talentSkillItemId]

    local talent_tips=Tips.CreateTalentTipByInfo(info,talentSkillPage,"talent_tips",tipsX,0,320,50)
    --学习技能按钮
    local LearnSkillBtn = GUI.ButtonCreate(talent_tips, "LearnSkillBtnInTalentTips", "1800102090", 0, -10, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">学习技能</size></color>", 160, 45, false)
    SetAnchorAndPivot(LearnSkillBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    RoleSkillUI.SetBtnOutline(LearnSkillBtn)
    GUI.RegisterUIEvent(LearnSkillBtn, UCE.PointerClick, "RoleSkillUI", "OnLearnSkillBtn_Click")
    --装备技能按钮
    local equipSkillBtn = GUI.ButtonCreate(talent_tips, "equipSkillBtnInTalentTips", "1800102090", 0,-10, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">装备天赋</size></color>", 160, 45, false);
    SetAnchorAndPivot(equipSkillBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    RoleSkillUI.SetBtnOutline(equipSkillBtn)
    GUI.SetVisible(equipSkillBtn,false)
    GUI.RegisterUIEvent(equipSkillBtn, UCE.PointerClick, "RoleSkillUI", "OnEquipSkillBtn_Click")
end



----------------------------------------------end 天赋技能 end-------------------------------------

----------------------------------------------start 修炼技能 start--------------------------------------
local CurSelectPracticeIndex = 1 -- 当前选中心法的下标
local CurSelectPracticeElixirIndex = 0 -- 当前选择丹药的下标
local IndexToPracticeItemGuid = {}
local Elixir_TB = {Have_Guid = {}, Not_Have_Id = {}}
local ElixirGuids_TB = {}
local ElixirChosen_TB = {}     	--格式为ElixirChosen_TB = {[i] = count}
local ElixirData_TempTB = {}		--用于记录所选丹药的guid(点击"使用"按钮时需要数据)
local ElixirExp_Preview = 0
local Is_LevelMax = 0

function RoleSkillUI.OnPracticeSkillToggle()
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(LabelList[3][1])
	local Level = MainUI.MainUISwitchConfig["技能"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		if not RoleSkillUI.ResetLastSelectPage(PageEnum.Practice) then
			test("没有PageEnum.Practice")
			return
		end
		local version = RoleSkillUI.Version
		if version == nil then
			version = 0
		end
		CL.SendNotify(NOTIFY.SubmitForm, "FormCultivationSkill", "GetCulSKillData", version)
		CurSelectPracticeIndex = 1
		RoleSkillUI.RefreshPracticeSkillPage()
		--FormCultivationSkill.GetCulSKillData(player)
	else
        --RoleSkillUI.OnSchoolSkillToggle()
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(CurSelectPage, LabelList)
		return
	end
	
end

function RoleSkillUI.CreatePracticeSkillPage(pageName)
	local panelBg = _gt.GetUI("panelBg")
    local practiceBg = GUI.GroupCreate(panelBg, pageName, 7, -2, 1197, 639);
    _gt.BindName(practiceBg, pageName)
	
	local practiceSkill_Title = GUI.ImageCreate(practiceBg, "practiceSkill_Title", "1800700080", 130, 60, false, 245, 36);
    SetAnchorAndPivot(practiceSkill_Title, UIAnchor.Top, UIAroundPivot.Top)
    local practiceSkill_Txt = GUI.CreateStatic(practiceSkill_Title, "practiceSkill_Txt", "歪比歪比", 0, 0, 150, 50);
    _gt.BindName(practiceSkill_Txt, "practiceSkill_Txt")
    SetAnchorAndPivot(practiceSkill_Txt, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(practiceSkill_Txt, ColorType_FontColor2)
    GUI.StaticSetAlignment(practiceSkill_Txt, TextAnchor.MiddleCenter)
	GUI.StaticSetFontSize(practiceSkill_Txt, 22)
	local practiceSkill_preview_cur = GUI.CreateStatic(practiceBg, "practiceSkill_preview_cur", "【等级】:", -61, -187, 150, 50);
	SetAnchorAndPivot(practiceSkill_preview_cur, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(practiceSkill_preview_cur, TextAnchor.MiddleCenter)
	GUI.SetColor(practiceSkill_preview_cur, ColorType_FontColor2)
    GUI.StaticSetFontSize(practiceSkill_preview_cur, fontSize_BigOne)
	local practiceSkill_preview_curlevel = GUI.CreateStatic(practiceBg, "practiceSkill_preview_curlevel", "0级", 19, -187, 50, 50);
	SetAnchorAndPivot(practiceSkill_preview_curlevel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(practiceSkill_preview_curlevel, TextAnchor.MiddleCenter)
	GUI.SetColor(practiceSkill_preview_curlevel, ColorType_FontColor2)
    GUI.StaticSetFontSize(practiceSkill_preview_curlevel, fontSize_BigOne)
	_gt.BindName(practiceSkill_preview_curlevel, "practiceSkill_preview_curlevel")
	local practiceSkill_preview_Max = GUI.CreateStatic(practiceBg, "practiceSkill_preview_Max", "【等级上限】:", 328, -187, 150, 50);
	SetAnchorAndPivot(practiceSkill_preview_Max, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(practiceSkill_preview_Max, TextAnchor.MiddleCenter)
	GUI.SetColor(practiceSkill_preview_Max, ColorType_FontColor2)
    GUI.StaticSetFontSize(practiceSkill_preview_Max, fontSize_BigOne)
	local practiceSkill_preview_Maxlevel = GUI.CreateStatic(practiceBg, "practiceSkill_preview_Maxlevel", "0级", 434, -187, 50, 50);
	SetAnchorAndPivot(practiceSkill_preview_Maxlevel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(practiceSkill_preview_Maxlevel, TextAnchor.MiddleCenter)
	GUI.SetColor(practiceSkill_preview_Maxlevel, ColorType_FontColor2)
    GUI.StaticSetFontSize(practiceSkill_preview_Maxlevel, fontSize_BigOne)
	_gt.BindName(practiceSkill_preview_Maxlevel, "practiceSkill_preview_Maxlevel")
	local practiceSkill_expIcon = GUI.ImageCreate(practiceBg, "practiceSkill_expIcon", "1800404010", -84,-147,false, 50,28)
	local practiceSkill_expBar = GUI.ScrollBarCreate(practiceBg, "practiceSkill_expBar", "", "1800408160", "1800408110",563,160,440,28,1,false,Transition.None, 0, 1, Direction.LeftToRight, false)
	SetAnchorAndPivot(practiceSkill_expBar, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	_gt.BindName(practiceSkill_expBar, "practiceSkill_expBar")
	local silderFillSize = Vector2.New(435, 28)
    GUI.ScrollBarSetFillSize(practiceSkill_expBar, silderFillSize)
    GUI.ScrollBarSetBgSize(practiceSkill_expBar, silderFillSize)
	GUI.ScrollBarSetPos(practiceSkill_expBar, 0/1)
	local practiceSkill_expTxt = GUI.CreateStatic(practiceSkill_expBar, "practiceSkill_expTxt", "0/300", 120,2,200,25, "system", true)
    UILayout.StaticSetFontSizeColorAlignment(practiceSkill_expTxt, 21, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
	--GUI.SetIsOutLine(practiceSkill_expTxt, true)
	--GUI.SetOutLine_Color(practiceSkill_expTxt, UIDefine.OutLine_BlackColor)
    --GUI.SetOutLine_Distance(practiceSkill_expTxt, UIDefine.OutLineDistance)
	_gt.BindName(practiceSkill_expTxt, "practiceSkill_expTxt")
	local AddexpBtn = GUI.ButtonCreate(practiceBg, "AddexpBtn", "1800402060", 419,-145,Transition.ColorTint, "", 34,33, false)
	GUI.RegisterUIEvent(AddexpBtn, UCE.PointerClick, "RoleSkillUI", "OnPracticeAddexpBtnClick")
	_gt.BindName(AddexpBtn, "AddexpBtn")
	
	local practiceSkill_Hint = GUI.CreateStatic(practiceBg, "practiceSkill_Hint", "每一级使人物造成伤害时，额外增加2%伤害结果。", 99,-89,600,30)
	SetAnchorAndPivot(practiceSkill_Hint, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(practiceSkill_Hint, TextAnchor.MiddleLeft)
	GUI.SetColor(practiceSkill_Hint, ColorType_FontColor2)
    GUI.StaticSetFontSize(practiceSkill_Hint, 22)
	_gt.BindName(practiceSkill_Hint, "practiceSkill_Hint")
	
	local practiceSkill_InfoBg = GUI.ImageCreate(practiceBg, "practiceSkill_InfoBg", "1800400200", 152,26,false, 712, 175)
	
	local TB = {"当前级别", "下一级别"}
	for i = 1, 2 do
		local practiceSkill_Info = GUI.ImageCreate(practiceSkill_InfoBg, "practiceSkill_Info"..i, "1800700050", -573 + 382 * i ,0, false, 315, 164)
		local practiceSkill_Info_TitleBg = GUI.ImageCreate(practiceSkill_Info, "practiceSkill_Info_TitleBg"..i , "1800700080", 0, -52, false, 282, 32);
		local practiceSkill_Info_Title = GUI.CreateStatic(practiceSkill_Info_TitleBg, "practiceSkill_Info_Title"..i , TB[i], 0, 0, 150, 50);
		SetAnchorAndPivot(practiceSkill_Info_Title, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetAlignment(practiceSkill_Info_Title, TextAnchor.MiddleCenter)
		GUI.SetColor(practiceSkill_Info_Title, ColorType_FontColor2)
		GUI.StaticSetFontSize(practiceSkill_Info_Title, 21)
		local practiceSkill_Info_Txt = GUI.CreateStatic(practiceSkill_Info, "practiceSkill_Info_Txt"..i, "每一级使人物造成伤害时，额外增加"..tostring(-2 + 2 * i).."%伤害结果。", 0,22,280,100)
		SetAnchorAndPivot(practiceSkill_Info_Txt, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetAlignment(practiceSkill_Info_Txt, TextAnchor.MiddleLeft)
		GUI.SetColor(practiceSkill_Info_Txt, ColorType_FontColor2)
		GUI.StaticSetFontSize(practiceSkill_Info_Txt, 21)
		_gt.BindName(practiceSkill_Info_Txt, "practiceSkill_Info_Txt"..i)
	end
	
	GUI.ImageCreate(practiceSkill_InfoBg, "Arrow", "1800707050", 0,0,false, 48, 44)
	local practice_cutLine = GUI.ImageCreate(practiceBg, "practice_cutLine", "1800700060", 155, 470, false, 715, 3);
    SetAnchorAndPivot(practice_cutLine, UIAnchor.Top, UIAroundPivot.Top)
	
	--创建修炼滑动列表
    local practiceSkillScr_Bg = GUI.ImageCreate(practiceBg, "practiceSkillScr_Bg", "1800400200", 72, 60, false, 295, 540);
    SetAnchorAndPivot(practiceSkillScr_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local practiceSkillScroll = GUI.LoopScrollRectCreate(practiceSkillScr_Bg, "practiceSkillScroll", 6, 6, 285, 530,
            "RoleSkillUI", "CreatePracticeSkillItem", "RoleSkillUI", "RefreshPracticeSkillItem", 0, false,
            Vector2.New(280, 100), 1, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(practiceSkillScroll, "practiceSkillScroll")
	GUI.LoopScrollRectSetTotalCount(practiceSkillScroll, 8)
	
	local practiceSkill_Icon_preview_Bg = GUI.ImageCreate(practiceBg, "practiceSkill_Icon_preview_Bg", "1800400050", 396, 114);
    SetAnchorAndPivot(practiceSkill_Icon_preview_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	
	local practiceSkill_Icon_preview = GUI.ImageCreate(practiceSkill_Icon_preview_Bg, "practiceSkill_Icon_preview", "1800408170", 0, -1, false, iconWidth, iconHeight);
    SetAnchorAndPivot(practiceSkill_Icon_preview, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(practiceSkill_Icon_preview, "practiceSkill_Icon_preview")
	
	local practice_CoinCost = GUI.CreateStatic(practiceBg, "practice_CoinCost", "消耗银币", positionX, -42, 90, 27);
    SetAnchorAndPivot(practice_CoinCost, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
	GUI.SetColor(practice_CoinCost, fontColor2)
    GUI.StaticSetFontSize(practice_CoinCost, fontSize)
	GUI.SetColor(practice_CoinCost, UIDefine.BrownColor)
	
    local skill_LearnCoinCost_Bg = GUI.ImageCreate(practice_CoinCost, "skill_LearnCoinCost_Bg", "1800700010", 100, -2, false, 240, 30);
    local coinIcon_Cost = GUI.ImageCreate(skill_LearnCoinCost_Bg, "coinIcon_Cost", "1800408280", 0, 0);			--银币icon
	local practice_coinCount_Cost = GUI.CreateStatic(skill_LearnCoinCost_Bg, "practice_coinCount_Cost", "20000", 0, 0, 200, 40, "system", true);		--银币消耗
	GUI.StaticSetFontSize(practice_coinCount_Cost, fontSize)
	SetAnchorAndPivot(practice_coinCount_Cost, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(practice_coinCount_Cost, TextAnchor.MiddleCenter)
	_gt.BindName(practice_coinCount_Cost, "practice_coinCount_Cost")
	
	local practiceSkillBtn_Once = GUI.ButtonCreate(practiceBg, "practiceSkillBtn_Once", "1800102090", -88, -99, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">学习一次</size></color>", 160, 45, false);
    SetAnchorAndPivot(practiceSkillBtn_Once, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    RoleSkillUI.SetBtnOutline(practiceSkillBtn_Once)
	--GUI.SetEventCD(practiceSkillBtn_Once,UCE.PointerClick, 1)
    GUI.RegisterUIEvent(practiceSkillBtn_Once, UCE.PointerClick, "RoleSkillUI", "OnPracticeSkillBtn_OnceClick")
	_gt.BindName(practiceSkillBtn_Once, "practiceSkillBtn_Once")

    local practiceSkillBtn_Ten_times = GUI.ButtonCreate(practiceBg, "practiceSkillBtn_Ten_times", "1800102090", -88, -39, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">学习十次</size></color>", 160, 45, false);
    SetAnchorAndPivot(practiceSkillBtn_Ten_times, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    RoleSkillUI.SetBtnOutline(practiceSkillBtn_Ten_times)
	--GUI.SetEventCD(practiceSkillBtn_Ten_times,UCE.PointerClick, 1)
    GUI.RegisterUIEvent(practiceSkillBtn_Ten_times, UCE.PointerClick, "RoleSkillUI", "OnPracticeSkillBtn_Ten_timesClick")
    practiceSkillBtn_Ten_times:RegisterEvent(UCE.PointerDown)
    practiceSkillBtn_Ten_times:RegisterEvent(UCE.PointerUp)
    GUI.RegisterUIEvent(practiceSkillBtn_Ten_times, UCE.PointerDown, "RoleSkillUI", "OnPracticeSkillBtn_Down")
    GUI.RegisterUIEvent(practiceSkillBtn_Ten_times, UCE.PointerUp, "RoleSkillUI", "OnPracticeSkillBtn_Up")
	_gt.BindName(practiceSkillBtn_Ten_times, "practiceSkillBtn_Ten_times")
	
	local Practice_Cover = GUI.ImageCreate(panelBg, "Practice_Cover", "1800400220", 0, -32, false, 2000, 2000)
    UILayout.SetAnchorAndPivot(Practice_Cover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(Practice_Cover, true)
	_gt.BindName(Practice_Cover, "Practice_Cover")
	GUI.SetVisible(Practice_Cover, false)
	
	local AddBtn_PanelBack = UILayout.CreateFrame_WndStyle2_WithoutCover(Practice_Cover,"提升修炼",580,435,"RoleSkillUI","PracticeAddBtnOnExit")
	_gt.BindName(AddBtn_PanelBack, "AddBtn_PanelBack")

	--道具列表
    local ItemListBg = GUI.ImageCreate(AddBtn_PanelBack, "ItemListBg", "1800400200", 0, -26, false, 506, 268)
    SetAnchorAndPivot(ItemListBg, UIAnchor.Center, UIAroundPivot.Center)
	
	local ItemListScr = GUI.LoopScrollRectCreate(ItemListBg, "ItemListScr", 0,8,505,253, "RoleSkillUI", "CreateItemListScr", "RoleSkillUI", "RefreshItemListScr", 18, false, Vector2.New(78,78), 6, UIAroundPivot.Top,UIAnchor.Top)
    SetAnchorAndPivot(ItemListScr, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(ItemListScr,Vector2.New(3,8))
    GUI.ScrollRectSetNormalizedPosition(ItemListScr,Vector2.New(0,0))
	_gt.BindName(ItemListScr, "ItemListScr")
	GUI.LoopScrollRectSetTotalCount(ItemListScr, 18)


    --底部信息背景框
    local AddBtn_Bg = GUI.ImageCreate(AddBtn_PanelBack, "AddBtn_Bg", "1800700020", 26, -19)
    SetAnchorAndPivot(AddBtn_Bg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    _gt.BindName(AddBtn_Bg,"AddBtn_Bg")

    --图标
    local AddBtn_Skill_Icon = GUI.ImageCreate(AddBtn_Bg, "AddBtn_Skill_Icon", "1900815010", 0, 0, false, 76, 76)
    SetAnchorAndPivot(AddBtn_Skill_Icon, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(AddBtn_Skill_Icon, "AddBtn_Skill_Icon")

    --技能名称
    local AddBtn_SkillName = GUI.CreateStatic(AddBtn_Bg, "AddBtn_SkillName", "攻击修炼", 90, -5, 200, 35)
    SetAnchorAndPivot(AddBtn_SkillName, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(AddBtn_SkillName, 22)
    GUI.SetColor(AddBtn_SkillName, UIDefine.BrownColor)
    _gt.BindName(AddBtn_SkillName,"AddBtn_SkillName")
	
	--技能等级
	local PracticeSkill_Text = GUI.CreateStatic(AddBtn_Bg,"PracticeSkill_Text","0级",180,-5,100,35)
	SetAnchorAndPivot(PracticeSkill_Text,UIAnchor.TopLeft,UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(PracticeSkill_Text,22)
    GUI.SetColor(PracticeSkill_Text,UIDefine.BlackColor)
    _gt.BindName(PracticeSkill_Text, "PracticeSkill_Text")
	
    --技能升级字体
    local PracticeSkill_Up_Text = GUI.CreateStatic(AddBtn_Bg,"PracticeSkill_Up_Text","（+1级）",220,-5,130,35)
    SetAnchorAndPivot(PracticeSkill_Up_Text,UIAnchor.TopLeft,UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(PracticeSkill_Up_Text,22)
    GUI.SetColor(PracticeSkill_Up_Text,Color.New(0 / 255, 202 / 255, 0 / 255, 1))
    _gt.BindName(PracticeSkill_Up_Text,"PracticeSkill_Up_Text")
    GUI.SetVisible(PracticeSkill_Up_Text, false)

    --经验条ExpPreView
    local AddBtn_Skill_ExpPreView = GUI.ScrollBarCreate(AddBtn_Bg, "AddBtn_Skill_ExpPreView","","1800408130","1800408110",253,-66,0,0,1,false,Transition.None,0,1,Direction.LeftToRight,false)
    GUI.ScrollBarSetFillSize(AddBtn_Skill_ExpPreView,Vector2.New(327,26))
    GUI.ScrollBarSetBgSize(AddBtn_Skill_ExpPreView, Vector2.New(327,26))
	GUI.ScrollBarSetPos(AddBtn_Skill_ExpPreView, 0/1)
    SetAnchorAndPivot(AddBtn_Skill_ExpPreView, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(AddBtn_Skill_ExpPreView,"AddBtn_Skill_ExpPreView")

    --经验条
    local AddBtn_Skill_Exp = GUI.ScrollBarCreate(AddBtn_Bg, "AddBtn_Skill_Exp","","1800408160","1800499999",253,-66,0,0,1,false,Transition.None,0,1,Direction.LeftToRight,false)
    GUI.ScrollBarSetFillSize(AddBtn_Skill_Exp,Vector2.New(327,26))
    GUI.ScrollBarSetBgSize(AddBtn_Skill_Exp, Vector2.New(327,26))
	GUI.ScrollBarSetPos(AddBtn_Skill_Exp, 0/1)
    SetAnchorAndPivot(AddBtn_Skill_Exp, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(AddBtn_Skill_Exp,"AddBtn_Skill_Exp")

    -- 经验条文本    预览经验文本也在这里修改
    local AddBtn_Skill_ExpTxt = GUI.CreateStatic(AddBtn_Skill_Exp, "AddBtn_Skill_ExpTxt", "0/300", 0, 1,327,26)
    SetAnchorAndPivot(AddBtn_Skill_ExpTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AddBtn_Skill_ExpTxt, 20)
    GUI.SetColor(AddBtn_Skill_ExpTxt, UIDefine.WhiteColor)
    GUI.StaticSetAlignment(AddBtn_Skill_ExpTxt,TextAnchor.MiddleCenter)
    _gt.BindName(AddBtn_Skill_ExpTxt,"AddBtn_Skill_ExpTxt")

    --使用按钮
    local UseBtn = GUI.ButtonCreate(AddBtn_Bg, "UseBtn", "1800402110",440,-31, Transition.ColorTint, "使用", 80, 44, false)
    SetAnchorAndPivot(UseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(UseBtn, 22)
    GUI.ButtonSetTextColor(UseBtn, UIDefine.BrownColor)
    GUI.RegisterUIEvent(UseBtn , UCE.PointerClick , "RoleSkillUI", "OnUseBtn" )

    --选中最大可用
    local ChooseUsefulCheckBox = GUI.CheckBoxCreate(AddBtn_Bg, "ChooseUsefulCheckBox", "1800607150", "1800607151", 323, 50, Transition.None, true, 35, 35) -- ExpUpdateUI.GetChooseUseful()
    _gt.BindName(ChooseUsefulCheckBox, "ChooseUsefulCheckBox")
	local ChooseUsefulLabel = GUI.CreateStatic(ChooseUsefulCheckBox, "ChooseUsefulLabel", "选中最大可使用", 40, 4, 160, 30)
    GUI.StaticSetFontSize(ChooseUsefulLabel, 22)
    GUI.SetColor(ChooseUsefulLabel, UIDefine.BrownColor)
    GUI.RegisterUIEvent(ChooseUsefulCheckBox, UCE.PointerClick, "RoleSkillUI", "OnChooseUsefulCheckBoxClick")
end

function RoleSkillUI.PracticeAddBtnOnExit()
	local Practice_Cover = _gt.GetUI("Practice_Cover")
	GUI.SetVisible(Practice_Cover, false)
	--CurSelectPracticeElixirIndex = 0
	RoleSkillUI.ResetCountData()
end

function RoleSkillUI.CreatePracticeSkillItem()						--左侧技能列表生成
    local practiceSkillScroll = _gt.GetUI("practiceSkillScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(practiceSkillScroll)
	local Index = tonumber(curCount) + 1
    local practiceSkillBtn = GUI.CheckBoxExCreate(practiceSkillScroll, "practiceSkillItem"..Index, "1800700030", "1800700040", 0, 0, false, 0, 0)
    local practiceSkill_Icon_Bg = GUI.ImageCreate(practiceSkillBtn, "practiceSkill_Icon_Bg", "1800400050", 10, 10, false, 80, 81);
    local practiceSkill_Icon = GUI.ImageCreate(practiceSkill_Icon_Bg, "practiceSkill_Icon", "1900000000", 0, -1, false, iconWidth, iconHeight);

    SetAnchorAndPivot(practiceSkill_Icon, UIAnchor.Center, UIAroundPivot.Center)
    local practiceSkill_Name = GUI.CreateStatic(practiceSkillBtn, "practiceSkill_Name", "", 105, -20, 100, 30, "system", true);
    SetAnchorAndPivot(practiceSkill_Name, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(practiceSkill_Name, ColorType_FontColor2)
    GUI.StaticSetFontSize(practiceSkill_Name, fontSize_BigOne)

    local practiceSkill_Level = GUI.CreateStatic(practiceSkillBtn, "practiceSkill_Level", "", 105, 15, 100, 30, "system", true);
    SetAnchorAndPivot(practiceSkill_Level, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(practiceSkill_Level, ColorType_FontColor1)
    GUI.StaticSetFontSize(practiceSkill_Level, fontSize)
    GUI.RegisterUIEvent(practiceSkillBtn, UCE.PointerClick, "RoleSkillUI", "OnSelectpracticeSkill");
	
	--GUI.SetData(practiceSkillBtn, "Index", Index)
    return practiceSkillBtn;
end

function RoleSkillUI.RefreshPracticeSkillItem(parameter)			--左侧技能列表刷新
    local serverData = RoleSkillUI.CulSkillData.SkillInfo
    if not serverData or not RoleSkillUI.CulSkillData.SkillNowLevel or not RoleSkillUI.CulSkillData.SkillMaxLevel then
		return
    end
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    IndexToPracticeItemGuid[index] = guid
    local skill = DB.GetOnceSkillByKey1(tostring(serverData[index]['SkillID']))
    local practiceSkillBtn = GUI.GetByGuid(guid)
    GUI.SetData(practiceSkillBtn, "skillId", skill.Id)
    local practiceSkill_Icon_Bg = GUI.GetChild(practiceSkillBtn, "practiceSkill_Icon_Bg")
    local practiceSkill_Icon = GUI.GetChild(practiceSkill_Icon_Bg, "practiceSkill_Icon")
    GUI.ImageSetImageID(practiceSkill_Icon, tostring(skill.Icon))
    local practiceSkill_Name = GUI.GetChild(practiceSkillBtn, "practiceSkill_Name")
    GUI.StaticSetText(practiceSkill_Name, skill.Name)
    local skill_Level = RoleSkillUI.CulSkillData.SkillNowLevel[skill.Id]['NowLevel']
    local practiceSkill_Level = GUI.GetChild(practiceSkillBtn, "practiceSkill_Level")
    GUI.StaticSetText(practiceSkill_Level, skill_Level.."/"..RoleSkillUI.CulSkillData.SkillMaxLevel)
    if CurSelectPracticeIndex == index then
        GUI.CheckBoxExSetCheck(practiceSkillBtn, true)
    else
        GUI.CheckBoxExSetCheck(practiceSkillBtn, false)
    end

    --列表处小红点

    if redPointData then
        local curData=redPointData["practice_data"]
        if  curData and curData["is_has_item"] == true then
            if #curData[index] ~= 1 then
                GlobalProcessing.SetRetPoint(practiceSkill_Icon, true, UIDefine.red_type.icon)
            else
                GlobalProcessing.SetRetPoint(practiceSkill_Icon, false, UIDefine.red_type.icon)
            end
        else
            if next(curData)~=nil then
                for i, v in pairs(curData[index]) do
                    if v then
                        GlobalProcessing.SetRetPoint(practiceSkill_Icon, true, UIDefine.red_type.icon)
                        break
                    else
                        GlobalProcessing.SetRetPoint(practiceSkill_Icon, false, UIDefine.red_type.icon)
                    end
                end
            end
        end
    end
end

function RoleSkillUI.CreateItemListScr()				--丹药升级界面物品生成
	local ItemListScr = _gt.GetUI("ItemListScr")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(ItemListScr)
	local Index = tonumber(curCount) + 1
	local ItemListScr_ItemBg = GUI.ImageCreate(ItemListScr, "ItemListScr_ItemBg"..Index, "1800001060", 0,0, false, 78,78)
	SetAnchorAndPivot(ItemListScr_ItemBg, UIAnchor.Center, UIAroundPivot.Center)
	local ItemListScr_Item = ItemIcon.Create(ItemListScr_ItemBg, "ItemListScr_Item", 0, 3)
	--local ItemListScr_Item = GUI.ImageCreate(ItemListScr_ItemBg, "ItemListScr_Item", "1800700020", 0,0, false, 76,76)
	--SetAnchorAndPivot(ItemListScr_Item, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetIsRaycastTarget(ItemListScr_Item, true)
	ItemListScr_Item:RegisterEvent(UCE.PointerDown)
	ItemListScr_Item:RegisterEvent(UCE.PointerUp)
	ItemListScr_Item:RegisterEvent(UCE.PointerClick)
	GUI.RegisterUIEvent(ItemListScr_Item , UCE.PointerDown , "RoleSkillUI", "ItemListScr_Item_ClickDown" );
	GUI.RegisterUIEvent(ItemListScr_Item , UCE.PointerUp , "RoleSkillUI", "ItemListScr_Item_ClickUp" );
	GUI.RegisterUIEvent(ItemListScr_Item , UCE.PointerClick , "RoleSkillUI", "ItemListScr_Item_Click" );
	
	local Select_Icon = GUI.ImageCreate(ItemListScr_ItemBg, "Select_Icon", "1800400280", 0,1, false, 84,84)
	SetAnchorAndPivot(Select_Icon, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetVisible(Select_Icon, false)
	local DemountBtn = GUI.ButtonCreate(ItemListScr_ItemBg, "DemountBtn", "1800702070", 27,-27, Transition.ColorTint, "", 24,24,false)
	SetAnchorAndPivot(DemountBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetIsRaycastTarget(DemountBtn, true)
	DemountBtn:RegisterEvent(UCE.PointerDown)
	DemountBtn:RegisterEvent(UCE.PointerUp)
	DemountBtn:RegisterEvent(UCE.PointerClick)
	GUI.RegisterUIEvent(DemountBtn, UCE.PointerDown , "RoleSkillUI", "ItemListScr_DemountBtn_ClickDown" );
	GUI.RegisterUIEvent(DemountBtn, UCE.PointerUp , "RoleSkillUI", "ItemListScr_DemountBtn_ClickUp" );
	GUI.RegisterUIEvent(DemountBtn, UCE.PointerClick , "RoleSkillUI", "ItemListScr_DemountBtn_Click" );
	GUI.SetVisible(DemountBtn, false)
	
	local ItemChosenCountBg = GUI.ImageCreate(ItemListScr_ItemBg, "ItemChosenCountBg", "1800001240", 0,28, false, 78,22)
	SetAnchorAndPivot(ItemChosenCountBg, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetVisible(ItemChosenCountBg, false)
	local ItemChosenCount = GUI.CreateStatic(ItemChosenCountBg, "ItemChosenCount", "0/0", 0,0,70,22)
	SetAnchorAndPivot(ItemChosenCount, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(ItemChosenCount, TextAnchor.MiddleCenter)
	GUI.StaticSetFontSize(ItemChosenCount, 16)
	return ItemListScr_ItemBg
end

function RoleSkillUI.RefreshItemListScr(parameter)				--丹药升级界面物品刷新
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local Index = tonumber(parameter[2]) + 1
	
	local ItemListScr_ItemBg = GUI.GetByGuid(guid)
	local ItemListScr_Item = GUI.GetChild(ItemListScr_ItemBg, "ItemListScr_Item", false)
	local Select_Icon = GUI.GetChild(ItemListScr_ItemBg, "Select_Icon", false)
	local DemountBtn = GUI.GetChild(ItemListScr_ItemBg, "DemountBtn", false)
	local ItemChosenCountBg = GUI.GetChild(ItemListScr_ItemBg, "ItemChosenCountBg", false)
	local ItemChosenCount = GUI.GetChild(ItemChosenCountBg, "ItemChosenCount", false)
	
	GUI.SetData(ItemListScr_Item, "Index", Index)
	GUI.SetData(DemountBtn, "Index", Index)
	
	ItemIcon.SetEmpty(ItemListScr_Item)
	
	GUI.SetVisible(Select_Icon, CurSelectPracticeElixirIndex == Index)
	
	local amount = 0
	if ElixirGuids_TB and #ElixirGuids_TB ~= 0 and tonumber(Index - #ElixirGuids_TB) <= 0 then
		local Elixir_Guid = ElixirGuids_TB[Index]
		--test("AAAA  Index = "..Index)
		if Elixir_Guid then
			local ElixirData = LD.GetItemDataByGuid(Elixir_Guid, item_container_type.item_container_bag)
			if ElixirData then
				ItemIcon.BindItemData(ItemListScr_Item, ElixirData)
				amount = ElixirData:GetAttr(ItemAttr_Native.Amount)
				--test("amount = "..amount)
				GUI.ItemCtrlSetIconGray(ItemListScr_Item, false)
				GUI.SetData(ItemListScr_Item, "Is_Gray", "false")
				GUI.SetIsRaycastTarget(ItemListScr_Item, true)
			end
		else
			GUI.SetIsRaycastTarget(ItemListScr_Item, false)
		end
	elseif ElixirGuids_TB and #ElixirGuids_TB ~= 0 and tonumber(Index - #ElixirGuids_TB) > 0 and Elixir_TB['Not_Have_Id'] and #Elixir_TB['Not_Have_Id'] ~= 0 then
		--test("BBBB  Index = "..Index)
		local Elixir_Id = Elixir_TB['Not_Have_Id'][tonumber(Index - #ElixirGuids_TB)]
		if Elixir_Id then
			local ElixirDB = DB.GetOnceItemByKey1(Elixir_Id)
			ItemIcon.BindItemDB(ItemListScr_Item, ElixirDB)
			GUI.ItemCtrlSetIconGray(ItemListScr_Item, true)
			GUI.SetData(ItemListScr_Item, "Is_Gray", "true")
			GUI.SetData(ItemListScr_Item, "Elixir_Id", Elixir_Id)
			GUI.SetIsRaycastTarget(ItemListScr_Item, true)
			--GUI.SetVisible(DemountBtn, false)
			--GUI.SetVisible(Select_Icon, false)
		else	
			GUI.SetIsRaycastTarget(ItemListScr_Item, false)
		end
	elseif not ElixirGuids_TB or #ElixirGuids_TB == 0 then
		local Elixir_Id = Elixir_TB['Not_Have_Id'][Index]
		if Elixir_Id then
			local ElixirDB = DB.GetOnceItemByKey1(Elixir_Id)
			ItemIcon.BindItemDB(ItemListScr_Item, ElixirDB)
			GUI.ItemCtrlSetIconGray(ItemListScr_Item, true)
			GUI.SetData(ItemListScr_Item, "Is_Gray", "true")
			GUI.SetData(ItemListScr_Item, "Elixir_Id", Elixir_Id)
			GUI.SetIsRaycastTarget(ItemListScr_Item, true)
			--GUI.SetVisible(DemountBtn, false)
			--GUI.SetVisible(Select_Icon, false)
		else
			GUI.SetIsRaycastTarget(ItemListScr_Item, false)
		end
	end
	
	GUI.SetData(ItemListScr_Item, "amount", amount)
	
	if ElixirChosen_TB and ElixirChosen_TB[''..tostring(Index)] ~= nil and ElixirChosen_TB[''..tostring(Index)] > 0 and tonumber(amount) > 0 then 
		--test("amount = "..amount)
		GUI.StaticSetText(ItemChosenCount, tostring(ElixirChosen_TB[''..tostring(Index)]).."/"..amount)
		GUI.SetVisible(ItemChosenCountBg, true)
		GUI.SetVisible(DemountBtn, true)
	else
		GUI.SetVisible(ItemChosenCountBg, false)
		GUI.SetVisible(DemountBtn, false)
		GUI.SetVisible(Select_Icon, false)
	end
	
end

--"1900014300"修炼丹
--GUI.ImageSetGray 设置图片变灰

function RoleSkillUI.RefreshPracticeSkillPage()
    local pageName = LabelList[PageEnum.Practice][4]
    local practiceBg = _gt.GetUI(pageName)
    if not practiceBg then
        practiceBg = RoleSkillUI.CreatePracticeSkillPage(pageName)
    else
        GUI.SetVisible(practiceBg, true)
    end
    --local serverData = RoleSkillUI.serverData
    --if not serverData then
	--	test("没有serverData")
    --    return
    --end

	local practiceSkillScroll = _gt.GetUI("practiceSkillScroll")
	--GUI.LoopScrollRectSrollToCell(practiceSkillScroll, 0, 0)
	GUI.LoopScrollRectRefreshCells(practiceSkillScroll)
end

function RoleSkillUI.OnSelectpracticeSkill(guid)
    local practiceSkillBtn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.CheckBoxExGetIndex(practiceSkillBtn))
    index = index + 1
	--print("修炼技能practiceSkillBtn Index = "..index)
    --if index == CurSelectPracticeIndex then
    --    GUI.CheckBoxExSetCheck(practiceSkillBtn, true)
    --    return
    --end
    --if CurSelectPracticeIndex ~= index then
    --    local lastbtn = GUI.GetByGuid(IndexToPracticeItemGuid[CurSelectPracticeIndex])
    --    GUI.CheckBoxExSetCheck(lastbtn, false)
    --end
    local serverData = RoleSkillUI.serverData
    if not serverData then
        return
    end
	
	CurSelectPracticeIndex = index
	RoleSkillUI.PracticeRefresh()
	--test("CurSelectPracticeIndex = "..CurSelectPracticeIndex)
end

function RoleSkillUI.PracticeRefresh(BindGold)
	--test("PracticeRefresh")
    --小红点
    local Money = 0
    if BindGold ~= nil then
        Money = BindGold
    else
        Money = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
    end
    if CurSelectPracticeIndex == nil then
        CurSelectPracticeIndex = 1
    end
	
	local practiceSkill_Txt = _gt.GetUI("practiceSkill_Txt")								--技能名字
	local practiceSkill_Icon_preview = _gt.GetUI("practiceSkill_Icon_preview")              --预览技能图标
	local practiceSkill_preview_curlevel = _gt.GetUI("practiceSkill_preview_curlevel")		--当前等级
	local practiceSkill_preview_Maxlevel = _gt.GetUI("practiceSkill_preview_Maxlevel")		--最大等级
	local practiceSkill_expBar = _gt.GetUI("practiceSkill_expBar")                          --经验条
	local practiceSkill_expTxt = _gt.GetUI("practiceSkill_expTxt")                          --经验数值
	local practiceSkill_Hint = _gt.GetUI("practiceSkill_Hint")								--技能描述
	local practiceSkill_Info_Txt_1 = _gt.GetUI("practiceSkill_Info_Txt1")                   --左侧技能描述
	local practiceSkill_Info_Txt_2 = _gt.GetUI("practiceSkill_Info_Txt2")                   --右侧技能描述
	local practice_coinCount_Cost = _gt.GetUI("practice_coinCount_Cost")                    --升级消耗金钱
	
	local AddBtn_Skill_Icon = _gt.GetUI("AddBtn_Skill_Icon")                                --丹药升级界面 技能图标
	local AddBtn_SkillName = _gt.GetUI("AddBtn_SkillName")                                  --丹药升级界面 技能名称
	local PracticeSkill_Text = _gt.GetUI("PracticeSkill_Text")                              --丹药升级界面 技能等级
	local AddBtn_Skill_ExpPreView = _gt.GetUI("AddBtn_Skill_ExpPreView")                    --丹药升级界面 exp预览
	local AddBtn_Skill_Exp = _gt.GetUI("AddBtn_Skill_Exp")                    				--丹药升级界面 exp
	local AddBtn_Skill_ExpTxt = _gt.GetUI("AddBtn_Skill_ExpTxt")                    		--丹药升级界面 exp文本
	local PracticeSkill_Up_Text = _gt.GetUI("PracticeSkill_Up_Text")                    	--丹药升级界面 (+1级)

	GUI.ScrollBarSetPos(AddBtn_Skill_ExpPreView, (0/1))
	
	local SkillID = RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['SkillID']
	local NowLevel = tonumber(RoleSkillUI.CulSkillData.SkillNowLevel[SkillID]['NowLevel'])
	local Info = RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Info']
	GUI.StaticSetText(practiceSkill_Txt, RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Name'])
	GUI.StaticSetText(AddBtn_SkillName, RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Name'])
	GUI.ImageSetImageID(practiceSkill_Icon_preview, RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Icon'])
	GUI.ImageSetImageID(AddBtn_Skill_Icon, RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Icon'])
	GUI.StaticSetText(practiceSkill_Hint, Info)
	GUI.StaticSetText(practiceSkill_preview_curlevel, NowLevel.."级")
	GUI.StaticSetText(PracticeSkill_Text, NowLevel.."级")
	GUI.StaticSetText(practiceSkill_preview_Maxlevel, RoleSkillUI.CulSkillData.SkillMaxLevel.."级")

	if NowLevel == tonumber(RoleSkillUI.CulSkillData.SkillMaxLevel) then
		Is_LevelMax = 1
	else
		Is_LevelMax = 0
	end
	
	local info_L = string.split(Info, RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Up'])[1]..tostring(tonumber(RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Up']) * NowLevel)..string.split(Info, RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Up'])[2]
	local info_R = string.split(Info, RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Up'])[1]..tostring(tonumber(RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Up']) * (NowLevel + 1))..string.split(Info, RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['Up'])[2]
	GUI.StaticSetText(practiceSkill_Info_Txt_1, info_L)
	GUI.StaticSetText(practiceSkill_Info_Txt_2, info_R)
	local curexp = RoleSkillUI.CulSkillData.SkillNowLevel[SkillID]['NowExp']
	local Need_exp = 0
	for i = 1, NowLevel do 
		Need_exp = Need_exp + RoleSkillUI.CulSkillData.SkillLevelExtra[i]['Exp']
	end
	local curexp_Show = tostring((curexp - Need_exp).."/"..RoleSkillUI.CulSkillData.SkillLevelExtra[NowLevel + 1]['Exp'])
	GUI.StaticSetText(practiceSkill_expTxt, curexp_Show)
	GUI.StaticSetText(AddBtn_Skill_ExpTxt, curexp_Show)
	GUI.SetData(AddBtn_Skill_ExpTxt, "SkillID", SkillID)
	GUI.SetData(AddBtn_Skill_ExpTxt, "curexp_Show", curexp_Show)
	GUI.SetData(AddBtn_Skill_ExpTxt, "curexp", curexp)
	GUI.SetData(AddBtn_Skill_ExpTxt, "NowLevel", NowLevel)
	local BarSetPos = tonumber(curexp - Need_exp)/tonumber(RoleSkillUI.CulSkillData.SkillLevelExtra[NowLevel + 1]['Exp'])
	GUI.ScrollBarSetPos(practiceSkill_expBar, BarSetPos)
	GUI.ScrollBarSetPos(AddBtn_Skill_Exp, BarSetPos)
	
	GUI.StaticSetText(practice_coinCount_Cost, RoleSkillUI.CulSkillData.OnceCulConsume)

	if tonumber(Money) < tonumber(RoleSkillUI.CulSkillData.OnceCulConsume) then
		GUI.SetColor(practice_coinCount_Cost, UIDefine.RedColor)
	else
		GUI.SetColor(practice_coinCount_Cost, UIDefine.WhiteColor)
	end
	
	RoleSkillUI.ElixirOwn()
	--RoleSkillUI.CalculateElixirUse()
	
	local practiceSkillScroll = _gt.GetUI("practiceSkillScroll")
	GUI.LoopScrollRectSetTotalCount(practiceSkillScroll, #RoleSkillUI.CulSkillData.SkillInfo)
	GUI.LoopScrollRectRefreshCells(practiceSkillScroll)
	
	local ItemListScr = _gt.GetUI("ItemListScr")
	local ItemListScr_Count = #ElixirGuids_TB + #Elixir_TB['Not_Have_Id']
	if math.floor(ItemListScr_Count/6) < 3 then
		ItemListScr_Count = 18
	else
		ItemListScr_Count = (math.floor(ItemListScr_Count/6) + 1) * 6
	end
	GUI.LoopScrollRectSetTotalCount(ItemListScr, ItemListScr_Count)
	GUI.LoopScrollRectRefreshCells(ItemListScr)


    --修炼界面中按钮 以及修炼丹+号那个 小红点
    local practiceSkillBtn_Once = _gt.GetUI("practiceSkillBtn_Once")
    local practiceSkillBtn_Ten_times = _gt.GetUI("practiceSkillBtn_Ten_times")
    local AddexpBtn = _gt.GetUI("AddexpBtn")

    if redPointData then
		if redPointData["practice_data"] and next(redPointData["practice_data"])~=nil then
            if redPointData["practice_data"]["is_has_item"] == true then							--0000
                if #redPointData["practice_data"][CurSelectPracticeIndex] ~= 1 then
                    GlobalProcessing.SetRetPoint(AddexpBtn, true, UIDefine.red_type.plusIcon)
                else
                    GlobalProcessing.SetRetPoint(AddexpBtn, false, UIDefine.red_type.plusIcon)
                end
            else
                GlobalProcessing.SetRetPoint(AddexpBtn, false, UIDefine.red_type.plusIcon)
            end
        end
        if redPointData["practice_data"] and next(redPointData["practice_data"])~=nil then
            if redPointData["practice_data"][CurSelectPracticeIndex] then
                if redPointData["practice_data"][CurSelectPracticeIndex][1] then
                    GlobalProcessing.SetRetPoint(practiceSkillBtn_Once, true, UIDefine.red_type.common)
                else
                    GlobalProcessing.SetRetPoint(practiceSkillBtn_Once, false, UIDefine.red_type.common)
                end
            end
            if redPointData["practice_data"][CurSelectPracticeIndex] then
                if redPointData["practice_data"][CurSelectPracticeIndex][2] then
                    GlobalProcessing.SetRetPoint(practiceSkillBtn_Ten_times, true, UIDefine.red_type.common)
                else
                    GlobalProcessing.SetRetPoint(practiceSkillBtn_Ten_times, false, UIDefine.red_type.common)
                end
            end
        end
    end



end

function RoleSkillUI.OnPracticeAddexpBtnClick()
	--test("别点了别点了")
	local Practice_Cover = _gt.GetUI("Practice_Cover")
	GUI.SetVisible(Practice_Cover, true)
	RoleSkillUI.OnChooseUsefulCheckBoxClick()
end

function RoleSkillUI.OnPracticeSkillBtn_OnceClick()
	--FormCultivationSkill.LearnTime(player, skill_id, count)
	local SkillID = RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['SkillID']
	CL.SendNotify(NOTIFY.SubmitForm, "FormCultivationSkill", "LearnTime", SkillID, 1)
end

function RoleSkillUI.OnPracticeSkillBtn_Ten_timesClick()
	local SkillID = RoleSkillUI.CulSkillData.SkillInfo[CurSelectPracticeIndex]['SkillID']
	CL.SendNotify(NOTIFY.SubmitForm, "FormCultivationSkill", "LearnTime", SkillID, 10)
end

function RoleSkillUI.OnPracticeSkillBtn_Down()
    local Money = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold))) or 0
    local Need = math.floor(Money/200000)

	if Need > 0 then
        local fun = function()
            RoleSkillUI.OnPracticeSkillBtn_Ten_timesClick();
        end

        if RoleSkillUI.Timer == nil then
            RoleSkillUI.Timer = Timer.New(fun, 0.25, Need)
        else
            RoleSkillUI.Timer:Stop();
            RoleSkillUI.Timer:Reset(fun, 0.25, 1)
        end

        RoleSkillUI.Timer:Start();
    end
end

function RoleSkillUI.OnPracticeSkillBtn_Up()
	if RoleSkillUI.Timer ~= nil then
        RoleSkillUI.Timer:Stop();
        RoleSkillUI.Timer = nil;
    end
end

function RoleSkillUI.ElixirOwn()
	if not RoleSkillUI.CulSkillData.ItemData then
		--test("1788 没有丹药经验数据")
		return
	end
	local Have = {}
	ElixirGuids_TB = {}
	Elixir_TB['Have_Guid'] = {}
	Elixir_TB['Not_Have_Id'] = {}
	for i = 1, #RoleSkillUI.CulSkillData.ItemData do
		local Elixir_Id = RoleSkillUI.CulSkillData.ItemData[i]['Id']
		local Elixir_Count = LD.GetItemCountById(Elixir_Id, item_container_type.item_container_bag)
		if Elixir_Count > 0 then
			Have[i] = {}
			local Elixir_Guids = LD.GetItemGuidsById(Elixir_Id, item_container_type.item_container_bag)
			for j = 0, Elixir_Guids.Count - 1 do
				--test(tostring(Elixir_Guids[j]))
				table.insert(Have[i], tostring(Elixir_Guids[j]))
			end
			table.insert(Elixir_TB['Have_Guid'], Have[i])
		else
			table.insert(Elixir_TB['Not_Have_Id'], Elixir_Id)
			--test("Not_Have_Id输入 "..Elixir_Id)
		end
	end
	for k, v in pairs(Elixir_TB['Have_Guid']) do
		for m, n in pairs(v) do
			table.insert(ElixirGuids_TB, n)
		end
	end
end

function RoleSkillUI.CalculateElixirUse()
	if not RoleSkillUI.CulSkillData.ItemData then
		test("没有丹药经验数据")
		return
	end
	local AddBtn_Skill_ExpPreView = _gt.GetUI("AddBtn_Skill_ExpPreView")                    --丹药升级界面 exp预览
	local AddBtn_Skill_ExpTxt = _gt.GetUI("AddBtn_Skill_ExpTxt")                    		--丹药升级界面 exp文本
	local PracticeSkill_Up_Text = _gt.GetUI("PracticeSkill_Up_Text")                    	--丹药升级界面 (+1级)
	local curexp_Show = GUI.GetData(AddBtn_Skill_ExpTxt, "curexp_Show")
	local curexp = GUI.GetData(AddBtn_Skill_ExpTxt, "curexp")
	local NowLevel = GUI.GetData(AddBtn_Skill_ExpTxt, "NowLevel")
	--GUI.StaticSetText(AddBtn_Skill_ExpTxt, curexp_Show)
	
	ElixirData_TempTB = {}
	
	local ElixirExp_Preview = 0
	for i = 1, #ElixirGuids_TB do
		local ElixirGuid = ElixirGuids_TB[i]
		local ElixirData = LD.GetItemDataByGuid(ElixirGuid, item_container_type.item_container_bag)
		local ElixirExp = 0
		for j = 1, #RoleSkillUI.CulSkillData.ItemData do
			if tostring(ElixirData.id) == tostring(RoleSkillUI.CulSkillData.ItemData[j]['Id']) then
				ElixirExp = tonumber(RoleSkillUI.CulSkillData.ItemData[j]['Exp'])
			end
		end
		local ElixirCount = tonumber(ElixirChosen_TB[''..tostring(i)])
		if not ElixirCount then
			ElixirCount = 0
		end
		if ElixirCount > 0 then
			table.insert(ElixirData_TempTB, i)
		end
		ElixirExp_Preview = ElixirExp_Preview + ElixirExp * ElixirCount
	end
	--test("ElixirExp_Preview = "..ElixirExp_Preview)
	local curexp_TB = string.split(curexp_Show, "/")
	if ElixirExp_Preview > 0 then
		GUI.StaticSetText(AddBtn_Skill_ExpTxt, curexp_TB[1].."(+"..tostring(ElixirExp_Preview)..")/"..curexp_TB[2])
	else
		GUI.StaticSetText(AddBtn_Skill_ExpTxt, curexp_Show)
	end
	local BarSetPos = (tonumber(curexp_TB[1]) + ElixirExp_Preview) / tonumber(curexp_TB[2])
	GUI.ScrollBarSetPos(AddBtn_Skill_ExpPreView, BarSetPos)
	
	GUI.SetData(AddBtn_Skill_ExpTxt, "ElixirExp_Preview", ElixirExp_Preview)
	
	local Exp_Preview = tonumber(curexp) + ElixirExp_Preview 
	local totalExp = 0
	local level = 0
	for i = 1, #RoleSkillUI.CulSkillData.SkillLevelExtra do
		totalExp = totalExp + tonumber(RoleSkillUI.CulSkillData.SkillLevelExtra[i]['Exp'])
		if Exp_Preview < totalExp then
			level = i - 1
			break
		end
	end

	local Rank_Diff = level - tonumber(NowLevel)
	if Rank_Diff > 0 then
		GUI.SetVisible(PracticeSkill_Up_Text, true)
		GUI.StaticSetText(PracticeSkill_Up_Text, "（+"..tostring(Rank_Diff).."级）")
	else
		GUI.SetVisible(PracticeSkill_Up_Text, false)
	end
	
	if level == tonumber(RoleSkillUI.CulSkillData.SkillMaxLevel) then
		Is_LevelMax = 1
	else
		Is_LevelMax = 0
	end
end

function RoleSkillUI.OnChooseUsefulCheckBoxClick()
	local ChooseUsefulCheckBox = _gt.GetUI("ChooseUsefulCheckBox")
	local T_O_F = GUI.CheckBoxGetCheck(ChooseUsefulCheckBox)
	--test("T_O_F = "..tostring(T_O_F))
	local practiceSkill_preview_curlevel = _gt.GetUI("practiceSkill_preview_curlevel")
	local practiceSkill_preview_Maxlevel = _gt.GetUI("practiceSkill_preview_Maxlevel")
	local curlevel = GUI.StaticGetText(practiceSkill_preview_curlevel)
	local Maxlevel = GUI.StaticGetText(practiceSkill_preview_Maxlevel)
	local WB = 0
	if curlevel == Maxlevel then
		WB = 1
	end
	RoleSkillUI.CheckBoxClick_Calculate(T_O_F, WB)
end

function RoleSkillUI.CheckBoxClick_Calculate(T_O_F, WB)
	local Whether_Break = 0
	if WB == nil then
		Whether_Break = 0
	else
		Whether_Break = WB
	end
	local ChooseUsefulCheckBox = _gt.GetUI("ChooseUsefulCheckBox")
	GUI.CheckBoxSetCheck(ChooseUsefulCheckBox, T_O_F)
	
	for i = 1, #ElixirGuids_TB do
		ElixirChosen_TB[''..tostring(i)] = 0
	end
	
	if T_O_F then
		local AddBtn_Skill_ExpTxt = _gt.GetUI("AddBtn_Skill_ExpTxt") 
		local curexp = tonumber(GUI.GetData(AddBtn_Skill_ExpTxt, "curexp"))
		local Total_Exp_Need = 0
		for i = 1, tonumber(RoleSkillUI.CulSkillData.SkillMaxLevel) do
			Total_Exp_Need = Total_Exp_Need + tonumber(RoleSkillUI.CulSkillData.SkillLevelExtra[i]['Exp'])
		end
		local Exp_Need = Total_Exp_Need - curexp
		
		ElixirData_TempTB = {}
		local Total_Elixir_Exp = 0
		for i = 1, #ElixirGuids_TB do
			local ElixirGuid = ElixirGuids_TB[i]
			local ElixirData = LD.GetItemDataByGuid(ElixirGuid, item_container_type.item_container_bag)
			local ElixirExp = 0
			for j = 1, #RoleSkillUI.CulSkillData.ItemData do
				if tostring(ElixirData.id) == tostring(RoleSkillUI.CulSkillData.ItemData[j]['Id']) then
					ElixirExp = tonumber(RoleSkillUI.CulSkillData.ItemData[j]['Exp'])
				end
			end
			local amount = tonumber(ElixirData:GetAttr(ItemAttr_Native.Amount))
			if not amount then
				amount = 0
			end
			Total_Elixir_Exp = Total_Elixir_Exp + ElixirExp * amount
		end
		--test("Total_Elixir_Exp = "..Total_Elixir_Exp)
		if Total_Elixir_Exp > Exp_Need then
			local Temp_Exp = 0
			for i = 1, #ElixirGuids_TB do
				if Whether_Break == 1 then
					Is_LevelMax = 1
					break
				end
				local ElixirGuid = ElixirGuids_TB[i]
				local ElixirData = LD.GetItemDataByGuid(ElixirGuid, item_container_type.item_container_bag)
				local amount = tonumber(ElixirData:GetAttr(ItemAttr_Native.Amount))
				if not amount then
					amount = 0
				end
				--test("amount = "..amount)
				for j = 1, #RoleSkillUI.CulSkillData.ItemData do
					if Whether_Break == 1 then
						Is_LevelMax = 1
						break
					end
					local ElixirExp = 0
					if tonumber(ElixirData.id) == tonumber(RoleSkillUI.CulSkillData.ItemData[j]['Id']) then
						ElixirExp = tonumber(RoleSkillUI.CulSkillData.ItemData[j]['Exp'])
					end
					if ElixirExp ~= 0 and ElixirExp > 0 and amount > 0 then
						for k = 1, amount do
							Temp_Exp = Temp_Exp + ElixirExp
							ElixirChosen_TB[''..tostring(i)] = k
							if Temp_Exp >= Exp_Need then
								Whether_Break = 1
								Is_LevelMax = 1
								break
							end
						end
					end
				end
				table.insert(ElixirData_TempTB, i)
			end
		else
			for i = 1, #ElixirGuids_TB do
				local ElixirGuid = ElixirGuids_TB[i]
				local ElixirData = LD.GetItemDataByGuid(ElixirGuid, item_container_type.item_container_bag)
				local amount = tonumber(ElixirData:GetAttr(ItemAttr_Native.Amount))
				if not amount then
					amount = 0
				end
				table.insert(ElixirData_TempTB, i)
				ElixirChosen_TB[''..tostring(i)] = amount
				Is_LevelMax = 0
			end
		end
	else
		ElixirData_TempTB = {}
		for i = 1, #ElixirGuids_TB do
			ElixirChosen_TB[''..tostring(i)] = 0
			Is_LevelMax = 0
		end
	end
	
	for i = 1, #ElixirGuids_TB do
		--test("ElixirChosen_TB[''..tostring(i)] = "..ElixirChosen_TB[''..tostring(i)])
	end
	RoleSkillUI.CalculateElixirUse()
	local ItemListScr = _gt.GetUI("ItemListScr")
	GUI.LoopScrollRectRefreshCells(ItemListScr)
end

function RoleSkillUI.ItemListScr_Item_ClickDown(guid)
	--test("丹药连点开始，计时器开始")    
	local fun = function()
        RoleSkillUI.ItemListScr_Item_Click(guid);
    end

    if RoleSkillUI.Timer == nil then
        RoleSkillUI.Timer = Timer.New(fun, 0.15, -1)
    else
        RoleSkillUI.Timer:Stop();
        RoleSkillUI.Timer:Reset(fun, 0.15, 1)
    end

    RoleSkillUI.Timer:Start();
	
end

function RoleSkillUI.ItemListScr_Item_ClickUp(guid)
	--test("计时器结束")
	if RoleSkillUI.Timer ~= nil then
        RoleSkillUI.Timer:Stop();
        RoleSkillUI.Timer = nil;
    end
end

function RoleSkillUI.OnClickElixirWayBtn()
	local tips = _gt.GetUI("ElixirTips")
    if tips then
        Tips.ShowItemGetWay(tips, 450)
    end
end

function RoleSkillUI.ItemListScr_Item_Click(guid)
	--test("成功添加")
	local ItemListScr_Item = GUI.GetByGuid(guid)                                    
	local Index = tonumber(GUI.GetData(ItemListScr_Item, "Index"))                  
	local ChosenGuid = ElixirGuids_TB[Index]
	local AddBtn_PanelBack = _gt.GetUI("AddBtn_PanelBack")						--0000
	if ChosenGuid then
		local ElixirData = LD.GetItemDataByGuid(ChosenGuid, item_container_type.item_container_bag)
		local tips = Tips.CreateByItemData(ElixirData, AddBtn_PanelBack, "ElixirTips", 440, 0, 40)
		GUI.SetData(tips, "ItemId", tostring(ElixirData.id))
		_gt.BindName(tips, "ElixirTips")
		local wayBtn = GUI.ButtonCreate(tips, "wayBtn", "1800402110", 0, -10, Transition.ColorTint, "获取途径", 150, 50, false)
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(wayBtn, UCE.PointerClick, "RoleSkillUI", "OnClickElixirWayBtn")
        GUI.AddWhiteName(tips, GUI.GetGuid(wayBtn))
	else
		local Elixir_Id = GUI.GetData(ItemListScr_Item, "Elixir_Id")
		local tips = Tips.CreateByItemId(Elixir_Id, AddBtn_PanelBack, "ElixirTips", 440, 0, 40)
		GUI.SetData(tips, "ItemId", tostring(Elixir_Id))
		_gt.BindName(tips, "ElixirTips")
		local wayBtn = GUI.ButtonCreate(tips, "wayBtn", "1800402110", 0, -10, Transition.ColorTint, "获取途径", 150, 50, false)
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(wayBtn, UCE.PointerClick, "RoleSkillUI", "OnClickElixirWayBtn")
        GUI.AddWhiteName(tips, GUI.GetGuid(wayBtn))
	end
	if Is_LevelMax == 1 then
		local Is_Gray = GUI.GetData(ItemListScr_Item, "Is_Gray")
		if Is_Gray == "false" then
			local msg = "修炼已到达所能增加的最大等级"
			GlobalUtils.ShowServerBoxMessage1Btn(msg)
			return
		end
	end
	
	CurSelectPracticeElixirIndex = Index											--此处待加计时器，等计时器触发后才计算Index
	local amount = GUI.GetData(ItemListScr_Item, "amount")
	--test("amount = "..amount)
	if ElixirChosen_TB[''..tostring(Index)] then
		ElixirChosen_TB[''..tostring(Index)] = ElixirChosen_TB[''..tostring(Index)] + 1
	else
		ElixirChosen_TB[''..tostring(Index)] = 1 
	end
	
	if ElixirChosen_TB[''..tostring(Index)] > tonumber(amount) and tonumber(amount) ~= 0 then
		ElixirChosen_TB[''..tostring(Index)] = tonumber(amount)
		CL.SendNotify(NOTIFY.ShowBBMsg, "已达到最大数量")
	end
	RoleSkillUI.CalculateElixirUse()
	local ItemListScr = _gt.GetUI("ItemListScr")
	GUI.LoopScrollRectRefreshCells(ItemListScr)
end

function RoleSkillUI.ItemListScr_DemountBtn_ClickDown(guid)
	--test("丹药开始减少，计时器开始") 
	local fun = function()
        RoleSkillUI.ItemListScr_DemountBtn_Click(guid);
    end

    if RoleSkillUI.Timer == nil then
        RoleSkillUI.Timer = Timer.New(fun, 0.15, -1)
    else
        RoleSkillUI.Timer:Stop();
        RoleSkillUI.Timer:Reset(fun, 0.15, 1)
    end
    RoleSkillUI.Timer:Start();
end

function RoleSkillUI.ItemListScr_DemountBtn_ClickUp(guid)
	--test("DemountBtn 计时器结束")
	if RoleSkillUI.Timer ~= nil then
        RoleSkillUI.Timer:Stop();
        RoleSkillUI.Timer = nil;
    end
end

function RoleSkillUI.ItemListScr_DemountBtn_Click(guid)
	--test("成功减少")
	local DemountBtn = GUI.GetByGuid(guid)
	if GUI.GetVisible(DemountBtn) == false then
		if RoleSkillUI.Timer ~= nil then
			RoleSkillUI.Timer:Stop();
			RoleSkillUI.Timer = nil;
		end
	end
	local Index = GUI.GetData(DemountBtn, "Index")
	if ElixirChosen_TB[''..tostring(Index)] and ElixirChosen_TB[''..tostring(Index)] > 0 then
		ElixirChosen_TB[''..tostring(Index)] = ElixirChosen_TB[''..tostring(Index)] - 1
	else
		ElixirChosen_TB[''..tostring(Index)] = 0 
	end
	Is_LevelMax = 0
	RoleSkillUI.CalculateElixirUse()
	local ItemListScr = _gt.GetUI("ItemListScr")
	GUI.LoopScrollRectRefreshCells(ItemListScr)
end

function RoleSkillUI.OnUseBtn()
	local AddBtn_Skill_ExpTxt = _gt.GetUI("AddBtn_Skill_ExpTxt")
	local ElixirExp_Preview = GUI.GetData(AddBtn_Skill_ExpTxt, "ElixirExp_Preview")
	local SkillID = GUI.GetData(AddBtn_Skill_ExpTxt, "SkillID")
	local param = ""
	for i = 1, #ElixirData_TempTB do
		local Index = ElixirData_TempTB[i]
		local ElixirGuid = ElixirGuids_TB[Index]
		local ElixirCount = tonumber(ElixirChosen_TB[''..tostring(Index)])
		param = param..tostring(ElixirGuid).."-"..tostring(ElixirCount)..","
	end
	if #ElixirData_TempTB > 0 then
		param = string.sub(param, 1, -2)
	end
	--test("param = "..param)
	--FormCultivationSkill.UseElixir(player, skill_id, param, show_exp)
	if SkillID and tonumber(ElixirExp_Preview) ~= 0 and #param > 0 then
		CL.SendNotify(NOTIFY.SubmitForm, "FormCultivationSkill", "UseElixir", SkillID, param, ElixirExp_Preview)
	else
		return
	end
end

function RoleSkillUI.ResetCountData()
	CurSelectPracticeElixirIndex = 0 -- 当前选丹药的下标
	--IndexToPracticeItemGuid = {}
	ElixirChosen_TB = {}
	ElixirData_TempTB = {}
	local AddBtn_Skill_ExpPreView = _gt.GetUI("AddBtn_Skill_ExpPreView")                    --丹药升级界面 exp预览
	local AddBtn_Skill_ExpTxt = _gt.GetUI("AddBtn_Skill_ExpTxt")                    		--丹药升级界面 exp文本
	local PracticeSkill_Up_Text = _gt.GetUI("PracticeSkill_Up_Text")                    	--丹药升级界面 (+1级)
	local curexp_Show = GUI.GetData(AddBtn_Skill_ExpTxt, "curexp_Show")
	GUI.SetData(AddBtn_Skill_ExpTxt, "ElixirExp_Preview", 0)
	GUI.StaticSetText(AddBtn_Skill_ExpTxt, curexp_Show)
	GUI.ScrollBarSetPos(AddBtn_Skill_ExpPreView, 0/1)
	GUI.SetVisible(PracticeSkill_Up_Text, false)
end
----------------------------------------------end 修炼技能 end-------------------------------------

----------------------------------------------start 帮派技能 start--------------------------------------
local CurSelectGuildIndex = 1 -- 当前选中帮派技能的下标
--local IndexToHeartItemGuid = {}
function RoleSkillUI.OnGuildSkillToggle()
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(LabelList[4][1])
	local Level = MainUI.MainUISwitchConfig["技能"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		if not RoleSkillUI.ResetLastSelectPage(PageEnum.Guild) then
			return
		end
		local version = RoleSkillUI.GuildSkillData.Version
		if version == nil then
			version = 0
		end

		--FormGuildSkill.GetGuildSkillData(player, version)
		
		CL.SendNotify(NOTIFY.SubmitForm, "FormGuildSkill", "GetGuildSkillData", version)
		CurSelectGuildIndex = 1
		RoleSkillUI.RefreshGuildSkillPage()
	else
        --RoleSkillUI.OnSchoolSkillToggle()
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(CurSelectPage, LabelList)
		return
	end
	
end

function RoleSkillUI.RefreshGuildSkillPage()
    local pageName = LabelList[PageEnum.Guild][4]
    local GuildBg = _gt.GetUI(pageName)
    if not GuildBg then
        GuildBg = RoleSkillUI.CreateGuildSkillPage(pageName)
    else
        GUI.SetVisible(GuildBg, true)
    end
    --local serverData = RoleSkillUI.serverData
    --if not serverData then
	--	test("没有serverData")
    --    return
    --end

	local GuildSkillScroll = _gt.GetUI("GuildSkillScroll")
	--GUI.LoopScrollRectSrollToCell(GuildSkillScroll, 0, 0)
	GUI.LoopScrollRectRefreshCells(GuildSkillScroll)
end

function RoleSkillUI.CreateGuildSkillPage(pageName)
	local panelBg = _gt.GetUI("panelBg")
    local GuildBg = GUI.GroupCreate(panelBg, pageName, 7, -2, 1197, 639);
    _gt.BindName(GuildBg, pageName)
	
	local GuildSkill_Title = GUI.ImageCreate(GuildBg, "GuildSkill_Title", "1800700080", 130, 60, false, 245, 36);
    SetAnchorAndPivot(GuildSkill_Title, UIAnchor.Top, UIAroundPivot.Top)
    local GuildSkill_Txt = GUI.CreateStatic(GuildSkill_Title, "GuildSkill_Txt", "", 0, 0, 150, 50);
    _gt.BindName(GuildSkill_Txt, "GuildSkill_Txt")
    SetAnchorAndPivot(GuildSkill_Txt, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(GuildSkill_Txt, ColorType_FontColor2)
    GUI.StaticSetAlignment(GuildSkill_Txt, TextAnchor.MiddleCenter)
	GUI.StaticSetFontSize(GuildSkill_Txt, 22)
	local GuildSkill_preview_cur = GUI.CreateStatic(GuildBg, "GuildSkill_preview_cur", "当前等级:", -61, -187, 150, 50);
	SetAnchorAndPivot(GuildSkill_preview_cur, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(GuildSkill_preview_cur, TextAnchor.MiddleCenter)
	GUI.SetColor(GuildSkill_preview_cur, ColorType_FontColor2)
    GUI.StaticSetFontSize(GuildSkill_preview_cur, fontSize_BigOne)
	local GuildSkill_preview_curlevel = GUI.CreateStatic(GuildBg, "GuildSkill_preview_curlevel", "0级", 71, -187, 150, 50);
	SetAnchorAndPivot(GuildSkill_preview_curlevel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(GuildSkill_preview_curlevel, TextAnchor.MiddleLeft)
	GUI.SetColor(GuildSkill_preview_curlevel, ColorType_FontColor2)
    GUI.StaticSetFontSize(GuildSkill_preview_curlevel, fontSize_BigOne)
	_gt.BindName(GuildSkill_preview_curlevel, "GuildSkill_preview_curlevel")
	local GuildSkill_preview_Maxlevel = GUI.CreateStatic(GuildBg, "GuildSkill_preview_Maxlevel", "未加入帮派", 350, -187, 200, 50);
	SetAnchorAndPivot(GuildSkill_preview_Maxlevel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(GuildSkill_preview_Maxlevel, TextAnchor.MiddleCenter)
	GUI.SetColor(GuildSkill_preview_Maxlevel, ColorType_FontColor2)
    GUI.StaticSetFontSize(GuildSkill_preview_Maxlevel, fontSize_BigOne)
	_gt.BindName(GuildSkill_preview_Maxlevel, "GuildSkill_preview_Maxlevel")
	local GuildSkill_expIcon = GUI.ImageCreate(GuildBg, "GuildSkill_expIcon", "1800404010", -84,-147,false, 50,28)
	local GuildSkill_expBar = GUI.ScrollBarCreate(GuildBg, "GuildSkill_expBar", "", "1800408160", "1800408110",563,160,450,28,1,false,Transition.None, 0, 1, Direction.LeftToRight, false)
	SetAnchorAndPivot(GuildSkill_expBar, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	_gt.BindName(GuildSkill_expBar, "GuildSkill_expBar")
	local silderFillSize = Vector2.New(445, 28)
    GUI.ScrollBarSetFillSize(GuildSkill_expBar, silderFillSize)
    GUI.ScrollBarSetBgSize(GuildSkill_expBar, silderFillSize)
	GUI.ScrollBarSetPos(GuildSkill_expBar, 0/1)
	local GuildSkill_expTxt = GUI.CreateStatic(GuildSkill_expBar, "GuildSkill_expTxt", "0/40", 120,2,200,25, "system", true)
    UILayout.StaticSetFontSizeColorAlignment(GuildSkill_expTxt, 21, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
	_gt.BindName(GuildSkill_expTxt, "GuildSkill_expTxt")

	
	local GuildSkill_Hint = GUI.CreateStatic(GuildBg, "GuildSkill_Hint", "攻击随技能等级提高。", 99,-89,600,30)
	SetAnchorAndPivot(GuildSkill_Hint, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(GuildSkill_Hint, TextAnchor.MiddleLeft)
	GUI.SetColor(GuildSkill_Hint, ColorType_FontColor2)
    GUI.StaticSetFontSize(GuildSkill_Hint, 22)
	_gt.BindName(GuildSkill_Hint, "GuildSkill_Hint")
	
	local GuildSkill_InfoBg = GUI.ImageCreate(GuildBg, "GuildSkill_InfoBg", "1800400200", 152,26,false, 712, 175)
	
	local TB = {"当前级别", "下一级别"}
	for i = 1, 2 do
		local GuildSkill_Info = GUI.ImageCreate(GuildSkill_InfoBg, "GuildSkill_Info"..i, "1800700050", -573 + 382 * i ,0, false, 315, 164)
		local GuildSkill_Info_TitleBg = GUI.ImageCreate(GuildSkill_Info, "GuildSkill_Info_TitleBg"..i , "1800700080", 0, -52, false, 282, 32);
		local GuildSkill_Info_Title = GUI.CreateStatic(GuildSkill_Info_TitleBg, "GuildSkill_Info_Title"..i , TB[i], 0, 0, 150, 50);
		SetAnchorAndPivot(GuildSkill_Info_Title, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetAlignment(GuildSkill_Info_Title, TextAnchor.MiddleCenter)
		GUI.SetColor(GuildSkill_Info_Title, ColorType_FontColor2)
		GUI.StaticSetFontSize(GuildSkill_Info_Title, 21)
		local GuildSkill_Info_Txt = GUI.CreateStatic(GuildSkill_Info, "GuildSkill_Info_Txt"..i, "提升角色<color=#FF0000ff>物理攻击</color> 0\n提升角色<color=#FF0000ff>法术攻击</color> 0", 0,44,280,100, "system", true)
		SetAnchorAndPivot(GuildSkill_Info_Txt, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetAlignment(GuildSkill_Info_Txt, TextAnchor.UpperLeft)
		GUI.SetColor(GuildSkill_Info_Txt, ColorType_FontColor2)
		GUI.StaticSetFontSize(GuildSkill_Info_Txt, 21)
		_gt.BindName(GuildSkill_Info_Txt, "GuildSkill_Info_Txt"..i)
	end
	
	GUI.ImageCreate(GuildSkill_InfoBg, "Arrow", "1800707050", 0,0,false, 48, 44)
	
	--创建修炼滑动列表
    local GuildSkillScr_Bg = GUI.ImageCreate(GuildBg, "GuildSkillScr_Bg", "1800400200", 72, 60, false, 295, 540);
    SetAnchorAndPivot(GuildSkillScr_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local GuildSkillScroll = GUI.LoopScrollRectCreate(GuildSkillScr_Bg, "GuildSkillScroll", 6, 6, 285, 530,
            "RoleSkillUI", "CreateGuildSkillItem", "RoleSkillUI", "RefreshGuildSkillItem", 0, false,
            Vector2.New(280, 100), 1, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(GuildSkillScroll, "GuildSkillScroll")
	GUI.LoopScrollRectSetTotalCount(GuildSkillScroll, 6)
	
	local GuildSkill_Icon_preview_Bg = GUI.ImageCreate(GuildBg, "GuildSkill_Icon_preview_Bg", "1800400050", 396, 114);
    SetAnchorAndPivot(GuildSkill_Icon_preview_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	
	local GuildSkill_Icon_preview = GUI.ImageCreate(GuildSkill_Icon_preview_Bg, "GuildSkill_Icon_preview", "1800408170", 0, -1, false, iconWidth, iconHeight);
    SetAnchorAndPivot(GuildSkill_Icon_preview, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(GuildSkill_Icon_preview, "GuildSkill_Icon_preview")
	
	local Txt_1 = GUI.CreateStatic(GuildBg, "Txt_1", "当前帮贡", positionX, -160, 90, 27);
    SetAnchorAndPivot(Txt_1, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
	GUI.SetColor(Txt_1, fontColor2)
    GUI.StaticSetFontSize(Txt_1, fontSize)
	GUI.SetColor(Txt_1, UIDefine.BrownColor)
	
    local CurContributionBg = GUI.ImageCreate(Txt_1, "CurContributionBg", "1800700010", 100, -2, false, 240, 30);
    local ContributionIcon_Cost_1 = GUI.ImageCreate(CurContributionBg, "ContributionIcon_Cost_1", "1800408290", 0, 0);
	local CurContribution = GUI.CreateStatic(CurContributionBg, "CurContribution", "0", 0, 0, 200, 40, "system", true);
	GUI.StaticSetFontSize(CurContribution, fontSize)
	SetAnchorAndPivot(CurContribution, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(CurContribution, TextAnchor.MiddleCenter)
	_gt.BindName(CurContribution, "CurContribution")
	
	local Txt_2 = GUI.CreateStatic(GuildBg, "Txt_2", "消耗帮贡", positionX, -101, 90, 27);
    SetAnchorAndPivot(Txt_2, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
	GUI.SetColor(Txt_2, fontColor2)
    GUI.StaticSetFontSize(Txt_2, fontSize)
	GUI.SetColor(Txt_2, UIDefine.BrownColor)
	
    local ContributionCost_Bg = GUI.ImageCreate(Txt_2, "ContributionCost_Bg", "1800700010", 100, -2, false, 240, 30);
    local ContributionIcon_Cost_2 = GUI.ImageCreate(ContributionCost_Bg, "ContributionIcon_Cost_2", "1800408290", 0, 0);	
	local ContributionCost = GUI.CreateStatic(ContributionCost_Bg, "ContributionCost", "20", 0, 0, 200, 40, "system", true);
	GUI.StaticSetFontSize(ContributionCost, fontSize)
	SetAnchorAndPivot(ContributionCost, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(ContributionCost, TextAnchor.MiddleCenter)
	GUI.SetColor(ContributionCost, UIDefine.RedColor)
	_gt.BindName(ContributionCost, "ContributionCost")
	
	local Txt_3 = GUI.CreateStatic(GuildBg, "Txt_3", "消耗银币", positionX, -42, 90, 27);
    SetAnchorAndPivot(Txt_3, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
	GUI.SetColor(Txt_3, fontColor2)
    GUI.StaticSetFontSize(Txt_3, fontSize)
	GUI.SetColor(Txt_3, UIDefine.BrownColor)
	
    local skill_LearnCoinCost_Bg = GUI.ImageCreate(Txt_3, "skill_LearnCoinCost_Bg", "1800700010", 100, -2, false, 240, 30);
    local coinIcon_Cost = GUI.ImageCreate(skill_LearnCoinCost_Bg, "coinIcon_Cost", "1800408280", 0, 0);			--银币icon
	local Guild_coinCount_Cost = GUI.CreateStatic(skill_LearnCoinCost_Bg, "Guild_coinCount_Cost", "20000", 0, 0, 200, 40);		--银币消耗
	GUI.StaticSetFontSize(Guild_coinCount_Cost, fontSize)
	SetAnchorAndPivot(Guild_coinCount_Cost, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(Guild_coinCount_Cost, TextAnchor.MiddleCenter)
	GUI.SetColor(Guild_coinCount_Cost, UIDefine.RedColor)
	_gt.BindName(Guild_coinCount_Cost, "Guild_coinCount_Cost")
	
	local GuildSkillBtn_Once = GUI.ButtonCreate(GuildBg, "GuildSkillBtn_Once", "1800102090", -88, -99, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">学习一次</size></color>", 160, 45, false);
    SetAnchorAndPivot(GuildSkillBtn_Once, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    RoleSkillUI.SetBtnOutline(GuildSkillBtn_Once)
	GUI.SetEventCD(GuildSkillBtn_Once,UCE.PointerClick, 1)
    GUI.RegisterUIEvent(GuildSkillBtn_Once, UCE.PointerClick, "RoleSkillUI", "OnGuildSkillBtn_OnceClick")

    local GuildSkillBtn_Ten_times = GUI.ButtonCreate(GuildBg, "GuildSkillBtn_Ten_times", "1800102090", -88, -39, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">学习十次</size></color>", 160, 45, false);
    SetAnchorAndPivot(GuildSkillBtn_Ten_times, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    RoleSkillUI.SetBtnOutline(GuildSkillBtn_Ten_times)
	GUI.SetEventCD(GuildSkillBtn_Ten_times,UCE.PointerClick, 1)
    GUI.RegisterUIEvent(GuildSkillBtn_Ten_times, UCE.PointerClick, "RoleSkillUI", "OnGuildSkillBtn_Ten_timesClick")

end

function RoleSkillUI.CreateGuildSkillItem()
	local GuildSkillScroll = _gt.GetUI("GuildSkillScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(GuildSkillScroll)
    local sum = GUI.LoopScrollRectGetTotalCount(GuildSkillScroll)
	local Index = tonumber(curCount) + 1

	local GuildSkillBtn = GUI.CheckBoxExCreate(GuildSkillScroll, "GuildSkillBtn"..Index, "1800700030", "1800700040", 0, 0, false, 0, 0)
    local GuildSkill_Icon_Bg = GUI.ImageCreate(GuildSkillBtn, "GuildSkill_Icon_Bg", "1800400050", 10, 10, false, 80, 81);
    local GuildSkill_Icon = GUI.ImageCreate(GuildSkill_Icon_Bg, "GuildSkill_Icon", "1900000000", 0, -1, false, iconWidth, iconHeight);
    SetAnchorAndPivot(GuildSkill_Icon, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetData(GuildSkillBtn, "Index",Index)
    
	local GuildSkill_Name = GUI.CreateStatic(GuildSkillBtn, "GuildSkill_Name", "", 105, -20, 100, 30, "system", true);
    SetAnchorAndPivot(GuildSkill_Name, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(GuildSkill_Name, ColorType_FontColor2)
    GUI.StaticSetFontSize(GuildSkill_Name, fontSize_BigOne)

    local GuildSkill_Level = GUI.CreateStatic(GuildSkillBtn, "GuildSkill_Level", "", 105, 10, 100, 30, "system", true);
    SetAnchorAndPivot(GuildSkill_Level, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(GuildSkill_Level, UIDefine.BrownColor)
    GUI.StaticSetFontSize(GuildSkill_Level, 23)
    GUI.RegisterUIEvent(GuildSkillBtn, UCE.PointerClick, "RoleSkillUI", "OnSelectGuildSkill");
	return GuildSkillBtn
end

function RoleSkillUI.RefreshGuildSkillItem(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local Index = tonumber(parameter[2]) + 1
	local GuildSkillBtn = GUI.GetByGuid(guid)
    local GuildSkill_Icon = GUI.GetChild(GuildSkillBtn, "GuildSkill_Icon")
	if RoleSkillUI.GuildSkillData.SkillInfo and RoleSkillUI.GuildSkillData.SkillNowLevel and RoleSkillUI.GuildSkillData.SkillMaxLevel then
		local skill_id = RoleSkillUI.GuildSkillData.SkillInfo[Index]['SkillID']
		local skillDB = DB.GetOnceSkillByKey1(skill_id)
		local GuildSkill_Name = GUI.GetChild(GuildSkillBtn, "GuildSkill_Name", false)
		local GuildSkill_Level = GUI.GetChild(GuildSkillBtn, "GuildSkill_Level", false)
		GUI.ImageSetImageID(GuildSkill_Icon, tostring(skillDB.Icon))
		GUI.StaticSetText(GuildSkill_Name, tostring(skillDB.Name))
		local NowLevel = RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['NowLevel']
		GUI.StaticSetText(GuildSkill_Level, NowLevel.."/"..RoleSkillUI.GuildSkillData.SkillMaxLevel)
        -- test("RoleSkillUI.GuildSkillData.SkillMaxLevel : "..RoleSkillUI.GuildSkillData.SkillMaxLevel)
	end
	
	if Index == CurSelectGuildIndex then
		GUI.CheckBoxExSetCheck(GuildSkillBtn, true)
	else
		GUI.CheckBoxExSetCheck(GuildSkillBtn, false)
	end
    --列表处小红点


    --local inspect = require("inspect")
    --print("-------------"..inspect(redPointData))
    if redPointData then
        local curData = redPointData["guild_data"]
        if curData and next(curData) then
            for i, v in pairs(curData[Index]) do
                if v then
                    GlobalProcessing.SetRetPoint(GuildSkill_Icon, true, UIDefine.red_type.icon)
                    break
                else
                    GlobalProcessing.SetRetPoint(GuildSkill_Icon, false, UIDefine.red_type.icon)
                end
            end
        end
    end
end

function RoleSkillUI.OnSelectGuildSkill(guid)
	local GuildSkillBtn = GUI.GetByGuid(guid)
	local Index = GUI.CheckBoxExGetIndex(GuildSkillBtn) + 1
	CurSelectGuildIndex = Index

    -- test("CurSelectGuildIndex = "..CurSelectGuildIndex)
	RoleSkillUI.GuildRefresh()
end

function RoleSkillUI.GuildRefresh(BindGold)
    local serverData = RoleSkillUI.GuildSkillData.SkillInfo
    if not serverData or not RoleSkillUI.GuildSkillData.SkillNowLevel or not RoleSkillUI.GuildSkillData.SkillMaxLevel then
		test("缺少必要数据")
		return
    end
	--test("GuildRefresh")
	local GuildSkill_Txt = _gt.GetUI("GuildSkill_Txt")                                                            -- 技能名字
	local GuildSkill_preview_curlevel = _gt.GetUI("GuildSkill_preview_curlevel")                                  --当前等级
	local GuildSkill_preview_Maxlevel = _gt.GetUI("GuildSkill_preview_Maxlevel")                                  --帮派等级
	local CurContribution = _gt.GetUI("CurContribution")                                                          --当前帮贡
	local ContributionCost = _gt.GetUI("ContributionCost")                                                        --消耗帮贡
	local Guild_coinCount_Cost = _gt.GetUI("Guild_coinCount_Cost")                                                --消耗银币
	local GuildSkill_Hint = _gt.GetUI("GuildSkill_Hint")                                                          --技能提示
	local GuildSkill_Icon_preview = _gt.GetUI("GuildSkill_Icon_preview")                                          -- 预览技能图标
	local GuildSkill_expBar = _gt.GetUI("GuildSkill_expBar")                                                      -- 经验条
	local GuildSkill_expTxt = _gt.GetUI("GuildSkill_expTxt")                                                      -- 经验条文本

	local skill_id = RoleSkillUI.GuildSkillData.SkillInfo[CurSelectGuildIndex]['SkillID']
	local skillDB = DB.GetOnceSkillByKey1(skill_id)
	local NowLevel = RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['NowLevel']
	GUI.StaticSetText(GuildSkill_Txt, skillDB.Name)
	GUI.StaticSetText(GuildSkill_preview_curlevel, NowLevel.."级")
	GUI.StaticSetText(GuildSkill_Hint, skillDB.Info)
	GUI.ImageSetImageID(GuildSkill_Icon_preview, tostring(skillDB.Icon))
	
	local Total_Exp = 0
	for i = 1, NowLevel do
		Total_Exp = Total_Exp + tonumber(RoleSkillUI.GuildSkillData.SkillLevelExtra[i]['Exp'])
	end
	
	local Exp_OnShow = tonumber(RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['NowExp']) - Total_Exp
	GUI.StaticSetText(GuildSkill_expTxt, tostring(Exp_OnShow).."/"..tostring(RoleSkillUI.GuildSkillData.SkillLevelExtra[(NowLevel + 1)]['Exp']))
	GUI.ScrollBarSetPos(GuildSkill_expBar, (Exp_OnShow/RoleSkillUI.GuildSkillData.SkillLevelExtra[(NowLevel + 1)]['Exp']))
	--RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]
	for i = 1, 2 do
		local GuildSkill_Info_Txt = _gt.GetUI("GuildSkill_Info_Txt"..i)                                           --技能详细文本
		if RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['Att2'] == 0 then
			local Att1_DB = DB.GetOnceAttrByKey1(RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['Att1'])
			local str = "提升角色<color=#FF0000ff>"..Att1_DB['KeyName'].."</color> "..tostring((RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['Att1Coef'] * (NowLevel - 1 + i)) / 10000)
			GUI.StaticSetText(GuildSkill_Info_Txt, str)
		else
			local Att1_DB = DB.GetOnceAttrByKey1(RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['Att1'])
			local Att2_DB = DB.GetOnceAttrByKey1(RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['Att2'])
			local str = "提升角色<color=#FF0000ff>"..Att1_DB['KeyName'].."</color> "..tostring((RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['Att1Coef'] * (NowLevel - 1 + i)) / 10000).."\n提升角色<color=#FF0000ff>"..Att2_DB['KeyName'].."</color> "..tostring((RoleSkillUI.GuildSkillData.SkillNowLevel[skill_id]['Att2Coef'] * (NowLevel - 1 + i)) / 10000)
			GUI.StaticSetText(GuildSkill_Info_Txt, str)
		end
	end
	
	local GuildSkill_Info_Txt = _gt.GetUI("GuildSkill_Info_Txt2")                                                 --当等级到达或者超过上限
	--RoleSkillUI.GuildSkillData.NowMAXSkillLevel						                                          --当前系统设置的技能等级上限
	if NowLevel == RoleSkillUI.GuildSkillData.NowMAXSkillLevel then
		GUI.StaticSetText(GuildSkill_Info_Txt, "已达到最高等级")
	end
	
	local IsGuild = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrIsGuild)))
	if IsGuild == 0 then
		GUI.StaticSetText(GuildSkill_preview_Maxlevel, "未加入帮派")
	else
		GUI.StaticSetText(GuildSkill_preview_Maxlevel, "最高等级: "..RoleSkillUI.GuildSkillData.SkillMaxLevel.."级")
	end
	
	local GuildContribute = tostring(CL.GetAttr(RoleAttr.RoleAttrGuildContribute))
    local Coin = 0
    if BindGold ~= nil then
        Coin = BindGold
    else
        Coin = tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold))
    end
	GUI.StaticSetText(CurContribution, GuildContribute)

    GUI.StaticSetText(ContributionCost, RoleSkillUI.GuildSkillData.OnceGuildConsume['GuildContribute'])
	if tonumber(GuildContribute) < tonumber(RoleSkillUI.GuildSkillData.OnceGuildConsume['GuildContribute']) then
		GUI.SetColor(ContributionCost, UIDefine.RedColor)
	else
		GUI.SetColor(ContributionCost, UIDefine.WhiteColor)
	end

    GUI.StaticSetText(Guild_coinCount_Cost, RoleSkillUI.GuildSkillData.OnceGuildConsume['MoneyVal'])
	if tonumber(Coin) < tonumber(RoleSkillUI.GuildSkillData.OnceGuildConsume['MoneyVal']) then
		GUI.SetColor(Guild_coinCount_Cost, UIDefine.RedColor)
	else
		GUI.SetColor(Guild_coinCount_Cost, UIDefine.WhiteColor)
	end
	
	local GuildSkillScroll = _gt.GetUI("GuildSkillScroll")
	GUI.LoopScrollRectRefreshCells(GuildSkillScroll)
    GUI.LoopScrollRectSetTotalCount(GuildSkillScroll, #serverData)

    --帮派界面小红点
    local curPage=_gt.GetUI(LabelList[CurSelectPage][4])
    local GuildSkillBtn_Once=GUI.GetChild(curPage,"GuildSkillBtn_Once")
    local GuildSkillBtn_Ten_times=GUI.GetChild(curPage,"GuildSkillBtn_Ten_times")

    if redPointData then
        local guildData = redPointData["guild_data"]
        if guildData and next(guildData)~=nil then
            if guildData[CurSelectGuildIndex] then
                if guildData[CurSelectGuildIndex][1] then
                    GlobalProcessing.SetRetPoint(GuildSkillBtn_Once, true, UIDefine.red_type.common)
                else
                    GlobalProcessing.SetRetPoint(GuildSkillBtn_Once, false, UIDefine.red_type.common)
                end
            end
            if guildData[CurSelectGuildIndex] then
                if guildData[CurSelectGuildIndex][2] then
                    GlobalProcessing.SetRetPoint(GuildSkillBtn_Ten_times, true, UIDefine.red_type.common)
                else
                    GlobalProcessing.SetRetPoint(GuildSkillBtn_Ten_times, false, UIDefine.red_type.common)
                end
            end
        end
    end
end

function RoleSkillUI.OnGuildSkillBtn_OnceClick()
	--FormGuildSkill.LearnTime(player, skill_id, count)
	local IsGuild = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrIsGuild)))
	if IsGuild == 0 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请先加入一个帮派")
		return
	end
	local skill_id = RoleSkillUI.GuildSkillData.SkillInfo[CurSelectGuildIndex]['SkillID']
	CL.SendNotify(NOTIFY.SubmitForm, "FormGuildSkill", "LearnTime", skill_id, 1)
end

function RoleSkillUI.OnGuildSkillBtn_Ten_timesClick()
	--FormGuildSkill.LearnTime(player, skill_id, count)
	local IsGuild = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrIsGuild)))
	if IsGuild == 0 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请先加入一个帮派")
		return
	end
	local skill_id = RoleSkillUI.GuildSkillData.SkillInfo[CurSelectGuildIndex]['SkillID']
	CL.SendNotify(NOTIFY.SubmitForm, "FormGuildSkill", "LearnTime", skill_id, 10)
end

----------------------------------------------end 帮派技能 end-------------------------------------

function RoleSkillUI.AddSkillIconTypeTipSp(skillIcon, skillId, x, y)
    if skillIcon == nil then
        test("skillIcon is null")
        return ;
    end

    if x == nil then
        x = -10;
    end
    if y == nil then
        y = 20;
    end
    local TypeTipSp = GUI.GetChild(skillIcon, "TypeTipSp");
    local skill = DB.GetOnceSkillByKey1(skillId);
    if skill == nil then
        test("skillIcon is null")
        if TypeTipSp then
            GUI.SetVisible(TypeTipSp, false);
        end
        return ;
    end

    local hurtTypeInfo = string.split(skill.DisplayDamageType, "|")
    if hurtTypeInfo ~= nil and #hurtTypeInfo > 1 then
        if not TypeTipSp then
            TypeTipSp = GUI.ImageCreate(skillIcon, "TypeTipSp", hurtTypeInfo[2], x, y);
            SetAnchorAndPivot(TypeTipSp, UIAnchor.TopRight, UIAroundPivot.TopRight)
        else
            GUI.ImageSetImageID(TypeTipSp, hurtTypeInfo[2])
            GUI.SetVisible(TypeTipSp, true);
        end
        return ;
    end
    if TypeTipSp then
        GUI.SetVisible(TypeTipSp, false);
    end
end

--根据info,width获取行数
function RoleSkillUI.GetLineCount( info,width )
    local str = { };
    str=string.split(info,"\\n");
    local newLineCount = 0;
    for i=1,#str do
        local wordCount = string.len(str[i]) --CL.GetStringLength(str[i]);
        newLineCount=math.ceil(math.ceil(wordCount/3)/ math.floor(width/fontSize)) + newLineCount;
    end

    return newLineCount;
end

function RoleSkillUI.SetBtnOutline( btn )
    GUI.SetIsOutLine(btn,true);
    GUI.SetOutLine_Color(btn,Color.New(162/255,75/255,21/255));
    GUI.SetOutLine_Distance(btn,1);
end

function RoleSkillUI.ResetAttrGuildContribute()
    RoleSkillUI.GuildRefresh()
end

function RoleSkillUI.ResetAttrBindGold(attrType, value)
    --右边页签   小红点的刷新
    RoleSkillUI.TabRedPointCheck()
    --刷新页面
    RoleSkillUI.RefreshServerData()
    local BindGold = tonumber(tostring(value))
    if CurSelectPage == PageEnum.School then
        RoleSkillUI.RefreshSchoolSkillPage()
    elseif CurSelectPage ==PageEnum.Talent then
        RoleSkillUI.RefreshTalentSkillPage()
    elseif CurSelectPage ==PageEnum.Practice then
        RoleSkillUI.PracticeRefresh(BindGold)
    elseif CurSelectPage ==PageEnum.Guild then
        RoleSkillUI.GuildRefresh(BindGold)
    end
end

---------------------