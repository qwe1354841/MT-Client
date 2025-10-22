local ActivityCollectRewardUI = {}
_G.ActivityCollectRewardUI = ActivityCollectRewardUI
local _gt = UILayout.NewGUIDUtilTable();

local gradeEffect1 = "#IMAGE3404100000#"
local gradeEffect2 = "#IMAGE3404200000#"
local QualityRes = UIDefine.ItemIconBg
local showEffect = "#IMAGE3404000000#";
local roleIcon = {
    ["谪剑仙"] = {"1800107010"},
    ["飞翼姬"] = {"1800107020"},
    ["烟云客"] = {"1800107030"},
    ["冥河使"] = {"1800107040"},
    ["阎魔令"] = {"1800107050"},
    ["雨师君"] = {"1800107060"},
    ["神霄卫"] = {"1800107070"},
    ["傲红莲"] = {"1800107080"},
    ["花弄影"] = {"1800107090"},
    ["青丘狐"] = {"1800107100"},
    ["海鲛灵"] = {"1800107110"},
    ["凤凰仙"] = {"1800107120"}
}
local sound = {
    [1] = "Att_zhang",
    [2] = "Panel_Warning",
}

local collectionName = nil

function ActivityCollectRewardUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable();
    local wnd = GUI.WndCreateWnd("ActivityCollectRewardUI", "ActivityCollectRewardUI", 0, 0);

    local panelCover = GUI.ImageCreate(wnd, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center);
    GUI.SetIsRaycastTarget(panelCover, true)

    local bg = GUI.ImageCreate(wnd, "bg", "1800601240", 0, -10, false, GUI.GetWidth(wnd), 340)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Center);
    _gt.BindName(bg,"bg")

    local title = GUI.ImageCreate(bg, "title", "1800608750", 0, -70)
    UILayout.SetSameAnchorAndPivot(title, UILayout.Top);

    local itemScroll = GUI.ScrollRectCreate(bg,"itemScroll", 0, -25, 700, 250, 0, false, Vector2.New(80, 80), UIAroundPivot.Center, UIAnchor.Center, 5)
    UILayout.SetSameAnchorAndPivot(itemScroll, UILayout.Center);
    GUI.ScrollRectSetAlignment(itemScroll, TextAnchor.MiddleCenter)
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(15, 15))
    for i = 1, 1 do
        local itemIcon = GUI.ItemCtrlCreate(itemScroll,"itemIcon"..i ,QualityRes[1], 0, 0, 100,100)
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon,roleIcon["谪剑仙"][1])
        _gt.BindName(itemIcon, "roleRoulette"..i)
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border,"1800608290")

        local showEffect= GUI.RichEditCreate(itemIcon,"showEffect",showEffect,0,42,0,0)
        GUI.SetWidth(showEffect,GUI.RichEditGetPreferredWidth(showEffect))
        GUI.SetHeight(showEffect,GUI.RichEditGetPreferredHeight(showEffect))
        GUI.SetVisible(showEffect,false)
        GUI.SetIsRaycastTarget(showEffect,false)
    end
    _gt.BindName(itemScroll,"itemScroll");

    local rightBtn = GUI.ButtonCreate(bg, "rightBtn", 1800402110, 0, -25, Transition.ColorTint, "确定", 140, 50, false);
    UILayout.SetSameAnchorAndPivot(rightBtn, UILayout.Bottom);
    GUI.ButtonSetTextColor(rightBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(rightBtn, UIDefine.FontSizeL)
    _gt.BindName(rightBtn,"rightBtn");
    GUI.RegisterUIEvent(rightBtn, UCE.PointerClick, "ActivityCollectRewardUI", "OnRightBtnClick");
end

function ActivityCollectRewardUI.OnShow(parameter)
    if not parameter then
        return
    end

    local wnd = GUI.GetWnd("ActivityCollectRewardUI");
    if wnd == nil then
        return ;
    end

    collectionName = parameter

    local itemScroll =_gt.GetUI("itemScroll");
    for i = 0, GUI.GetChildCount(itemScroll)-1 do
        local itemIcon = GUI.GetChildByIndex(itemScroll,i);
        local gradeEffect = GUI.GetChild(itemIcon,"gradeEffect");
        GUI.SetVisible(gradeEffect,false);
        local showEffect = GUI.GetChild(itemIcon,"showEffect");
        GUI.SetVisible(showEffect,false);
        GUI.SetVisible(itemIcon,false);
    end
    local rightBtn =_gt.GetUI("rightBtn");
    GUI.SetVisible(rightBtn,false);

    ActivityCollectRewardUI.InitData();

    GUI.SetVisible(wnd, true);

    ActivityCollectRewardUI.ShowItem(parameter)
end

function ActivityCollectRewardUI.InitData()
    ActivityCollectRewardUI.itemDataList ={};
    ActivityCollectRewardUI.itemIndex=1;
    ActivityCollectRewardUI.timer=nil
end

function ActivityCollectRewardUI.ShowItem(itemDataList)
    ActivityCollectRewardUI.itemIndex=1;
    ActivityCollectRewardUI.itemDataList=itemDataList;
    if  ActivityCollectRewardUI.timer==nil then
        ActivityCollectRewardUI.timer = Timer.New(ActivityCollectRewardUI.Performance, 0.5,2)
    else
        ActivityCollectRewardUI.timer:Stop()
        ActivityCollectRewardUI.timer:Reset(ActivityCollectRewardUI.Performance, 0.5, 2)
    end

    ActivityCollectRewardUI.timer:Start()
end

function ActivityCollectRewardUI.Performance()

    local itemScroll =_gt.GetUI("itemScroll");

    local preItemIcon =GUI.GetChild(itemScroll,"itemIcon1");
    if preItemIcon~=nil then
        local showEffect = GUI.GetChild(preItemIcon,"showEffect");
        GUI.SetVisible(showEffect,false);
    end


    local itemInfo = ActivityCollectRewardUI.itemDataList;
    if itemInfo ==nil then
        return;
    end

    local itemIcon = GUI.GetChild(itemScroll,"itemIcon1");

    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon,roleIcon[itemInfo][1])
    GUI.SetVisible(itemIcon, true)

    local showEffect = GUI.GetChild(itemIcon,"showEffect");
    GUI.SetVisible(showEffect,true);

    if ActivityCollectRewardUI.itemIndex == 2 then
        local rightBtn =_gt.GetUI("rightBtn");
        GUI.SetVisible(rightBtn,true);

        GUI.SetVisible(showEffect,false);
    end

    ActivityCollectRewardUI.itemIndex=ActivityCollectRewardUI.itemIndex+1;
end

function ActivityCollectRewardUI.OnRightBtnClick()
    ActivityCollectRewardUI.OnExit()
end

function ActivityCollectRewardUI.OnExit()
    ActivityCollectUI.GetCollect(collectionName)
    GUI.CloseWnd("ActivityCollectRewardUI")
end