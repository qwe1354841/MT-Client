local BagUI = {}
_G.BagUI = BagUI

--包裹界面

require "PetItem"
-- 导入羽翼界面
local WingUI = require("WingUI")
require("MountUI")

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local _gt = UILayout.NewGUIDUtilTable();


------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------





------------------------------------------Start 颜色配置 Start----------------------------------
local colorDark = UIDefine.BrownColor
----------------------------------------------End 颜色配置 End--------------------------------





------------------------------------------Start 全局变量 Start--------------------------------

local isSetNewSeverBag = 0 --0为道具、宝石、侍从包裹，1为服务器配置包裹

--当前选中item的Guid
local selectItemGuid = nil

local MoreBtnNmu = 1
local ItemIndex = 0
local BagSelectIndex1 = 0
local BagSelectIndex2 = 0
local cntPerWarehousePage = 36;
local warehousePageMax = LogicDefine.WarehousePageMax;
local cntPerLine = 6;
local sizeBig = UIDefine.FontSizeM
BagUI.GemTabBtn = nil
BagUI.GuardTabBtn = nil

--更多按钮的Loop是否滚动
local bagMoreBtnLoopIsRoll = 1 --0为滚动，1为不滚动

----------------------------------------------End 全局变量 End---------------------------------





------------------------------------------Start 表配置 Start----------------------------------

--设置顶部包裹类型表
local topBagTypeTable = {}

--中间包裹物品数据表
local bagTypeItemTable = {

}

--背包物品归属哪个背包类型表
local bagTemporarySeverTable = {}

--Type，Subtype，Subtype2
local severBag = {}
local NowClick = {}

local tabList = {
    { "包裹", "bagTabBtn", "OnBagBtnClick"},
    { "仓库", "warehouseTabBtn", "OnWarehouseTabBtnClick"},
    { "时装", "FashionTabBtn", "OnFashionTabBtnClick"},
    { "羽翼", "WingTabBtn", "OnWingTabBtnClick"},
    { "坐骑", "MountTabBtn", "OnMountTabBtnClick"}	
}

local subTabList = {
    { "道具", "itemSubTabBtn", "1800402030", "1800402032", "OnItemSubTabBtnClick", 95, -256, 175, 40, 100, 35 },
    { "宝石", "gemSubTabBtn", "1800402030", "1800402032", "OnGemSubTabBtnClick", 265, -256, 175, 40, 100, 35 },
    { "信物", "tokenSubTabBtn", "1800402030", "1800402032", "OnTokenSubTabBtnClick", 435, -256, 175, 40, 100, 35 },
}

--背包更多按钮子类表
local bagMoreBtnTable = {
    btnName = {},
    Type = 0,
    Subtype = 0,
    Subtype2 = 0,
    ShowType = 0,
}

--------------------------------------------End 表配置 End------------------------------------

function BagUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable();

    local wnd = GUI.WndCreateWnd("BagUI", "BagUI", 0, 0);
    GUI.SetVisible(wnd,false)
    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "包    裹", "BagUI", "OnExit", _gt);

    UILayout.CreateRightTab(tabList, "BagUI");

    local rightBg = GUI.ImageCreate(panelBg, "rightBg", "1800400010", 265, 0, false, 515, 480);
    local itemScroll = GUI.LoopScrollRectCreate(panelBg, "itemScroll", 265, 0, 490, 450,
            "BagUI", "CreateItemIconPool", "BagUI", "RefreshItemScroll", 0, false, Vector2.New(80, 80), cntPerLine, UIAroundPivot.Top, UIAnchor.Top);
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(1, 1));
    _gt.BindName(itemScroll, "itemScroll");

    local arrangeBtn = GUI.ButtonCreate(panelBg, "arrangeBtn", "1800402090", 470, 268, Transition.ColorTint, "整理", 100, 47, false);
    GUI.SetIsOutLine(arrangeBtn, true);
    GUI.ButtonSetTextFontSize(arrangeBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(arrangeBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(arrangeBtn,UIDefine.OutLine_GreenColor);
    GUI.SetOutLine_Distance(arrangeBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(arrangeBtn, UCE.PointerClick, "BagUI", "OnArrangeBtnClick");
    GUI.SetEventCD(arrangeBtn,UCE.PointerClick,2);
    _gt.BindName(arrangeBtn, "arrangeBtn");


    local capacityText = GUI.CreateStatic(panelBg, "capacityText", "包裹空间:0/0", 15, -60, 200, 35);
    GUI.SetColor(capacityText, UIDefine.Yellow2Color);
    GUI.StaticSetFontSize(capacityText, UIDefine.FontSizeM);
    GUI.SetAnchor(capacityText, UIAnchor.Bottom);
    GUI.SetPivot(capacityText, UIAroundPivot.Left);
    _gt.BindName(capacityText, "capacityText");

    BagUI.InitData();

end

function BagUI.InitData()

    BagSelectIndex1 = 1
    BagSelectIndex2 = 1
    BagUI.tabIndex = 1;
    BagUI.subTabIndex = 1
    BagUI.subSeverTabIndex = 1
    BagUI.warehouseType = 1;
    BagUI.warehousePageIndex = 1;
    BagUI.selectedIndex = 0;

    BagUI.petGuidList = nil;
    BagUI.warehousePetGuidList = nil;
    BagUI.selectedGuid = nil;

    BagUI.GemRedPointFlag = false
    BagUI.GuardRedPointFlag = false
end

--打开界面的时候调用
function BagUI.OnShow(parameter)
    if parameter ~= nil then
        local data = string.split(parameter,",")
        if data[1] == "index:4" then
            if MainUI and MainUI.MainUISwitchConfig then
                local level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
                if level < MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel["羽翼"] then
                    CL.SendNotify(NOTIFY.ShowBBMsg,MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel["羽翼"].."级开启羽翼功能")
                    return
                end
            end
		-- elseif data[1] == "index:5" then
            -- if MainUI and MainUI.MainUISwitchConfig then
                -- local level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
                -- if level < MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel["坐骑"] then
                    -- CL.SendNotify(NOTIFY.ShowBBMsg,MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel["坐骑"].."级开启坐骑功能")
                    -- return
                -- end
            -- end
        end
    end

    local wnd = GUI.GetWnd("BagUI");
    if wnd == nil then
        return ;
    end

    BagUI.InitData()
    GUI.PostEffect();
    GUI.SetVisible(wnd, true);
    -- BagUI.open = Timer.New(BagUI.OnShowWnd,0.025,1)
    -- BagUI.open:Start()
    local data = string.split(parameter,",")
    if data[1] == "index:4" then
        if data[2] == "index2:3" then
            WingUI.parameter_tab_index = 3
        end
        BagUI.set_wing_tab_red()
        BagUI.OnWingTabBtnClick()
        return
	elseif data[1] == "index:5" then
		BagUI.OnMountTabBtnClick()
		return
    end
    BagUI.OnShowWnd()

    BagUI.GetOpenLevel() -- -- 请求打开羽翼界面的等级

    local roleModel = _gt.GetUI("roleModel")
    if roleModel then
        GUI.RawImageChildSetModleRotation(roleModel, Vector3.New(0,0,0))
    end
    if parameter == "2" then
        BagUI.OnWarehouseTabBtnClick()
    end

    -- 羽翼页签小红点
    BagUI.set_wing_tab_red()

    --宝石信物小红点
    if MainUI.GemRedPointFlag then
        BagUI.ShowGemTabRedPoint(true)
    end
    if MainUI.GuardRedPointFlag then
        BagUI.ShowGuardTabRedPoint(true)
    end
end


--设置顶部包裹类型表
function BagUI.SetTopBagTypeTable()

    test("设置顶部包裹类型表")

    topBagTypeTable = {}

    if GlobalProcessing.BagTypeConfig ~= nil and next(GlobalProcessing.BagTypeConfig) then

        severBag = GlobalProcessing.BagTypeConfig

        for k, v in pairs(severBag) do
            if v.isShow == true then

                local temp = {
                    name = k,
                    isClick = false,
                    order = v.order,
                    allType = v.AllType

                }
                table.insert(topBagTypeTable,temp)

            end

        end

        table.sort(topBagTypeTable,function (a,b)
            if a.order ~= b.order then
                return a.order < b.order
            end
            return false

        end)

    end



    --设置顶部包裹类型点击数据
    BagUI.SetTopBagTypeTableClickData()

    test("topBagTypeTable",inspect(topBagTypeTable))

    bagTemporarySeverTable = {}

    if GlobalProcessing.ItemBagType ~= nil and next(GlobalProcessing.ItemBagType) then

        bagTemporarySeverTable = GlobalProcessing.ItemBagType

    end



    --设置背包类型包裹数据
    BagUI.SetBagTypeItemTableData()

end

--设置背包类型包裹数据
function BagUI.SetBagTypeItemTableData()


    test("bagTemporarySeverTable",inspect(bagTemporarySeverTable))

    bagTypeItemTable = {}

    local BagItemCount = LD.GetBagCapacity()

    for i = 0, BagItemCount-1 do
        local itemData =LD.GetItemDataByIndex(i,item_container_type.item_container_bag,0)
        local id = tonumber(LD.GetItemAttrByIndex(ItemAttr_Native.Id, i))

        if id ~= nil then

            local itemDB = DB.GetOnceItemByKey1(id)

            local temp = {
                index = i,
                Guid = tostring(itemData.guid),
                Name = itemDB.Name,
            }

            if bagTemporarySeverTable[itemDB.Type] ~= nil then

                if bagTemporarySeverTable[itemDB.Type][itemDB.Subtype] ~= nil then

                    if bagTemporarySeverTable[itemDB.Type][itemDB.Subtype][itemDB.Subtype2] ~= nil then

                        if bagTemporarySeverTable[itemDB.Type][itemDB.Subtype][itemDB.Subtype2][1] ~= nil then

                            local bagType = bagTemporarySeverTable[itemDB.Type][itemDB.Subtype][itemDB.Subtype2][1]

                            if bagTypeItemTable[bagType] == nil then

                                bagTypeItemTable[bagType] = {}

                            end

                            table.insert(bagTypeItemTable[bagType],temp)

                        end

                    end

                end

            end

        end

    end

    test("bagTypeItemTable",inspect(bagTypeItemTable))

end

--设置顶部包裹类型点击数据
function BagUI.SetTopBagTypeTableClickData()

    test("设置顶部包裹类型点击数据")

    for i = 1, #topBagTypeTable do

        if i == tonumber(BagUI.subSeverTabIndex) then

            topBagTypeTable[i].isClick = true

        else

            topBagTypeTable[i].isClick = false

        end

    end

end


--包裹类型Loop刷新
function BagUI.RefreshBagTypeItemScrollData()


    local arrangeBtn =  _gt.GetUI("arrangeBtn")
    GUI.SetVisible(arrangeBtn, true);

    local itemScroll = _gt.GetUI("itemScroll")
    GUI.SetVisible(itemScroll, true);

    if isSetNewSeverBag == 1 then

        local curBagType = item_container_type.item_container_bag;
        local curCount = LD.GetItemCount(curBagType);
        local capacity = LD.GetBagCapacity(curBagType);

        local capacityText =  _gt.GetUI("capacityText")
        GUI.SetVisible(capacityText, true);


        if topBagTypeTable[BagUI.subSeverTabIndex].allType == true then

            GUI.StaticSetText(capacityText, "包裹空间：" .. curCount .. "/" .. capacity);

            local count = capacity;
            if BagUI.tabIndex == 1 and BagUI.subSeverTabIndex == 1 then
                count = math.floor(capacity / cntPerLine) * cntPerLine + cntPerLine;
                if count > LogicDefine.BagMaxLimit then
                    count = LogicDefine.BagMaxLimit
                end
            end

            GUI.LoopScrollRectSetTotalCount(itemScroll, count);

        else

            test("BagUI.subSeverTabIndex",BagUI.subSeverTabIndex)

            local bagType = topBagTypeTable[BagUI.subSeverTabIndex].name

            test("bagType",inspect(bagType))
            test("bagTypeItemTable[bagType]",inspect(bagTypeItemTable[bagType]))
            if bagTypeItemTable[bagType] == nil then

                bagTypeItemTable[bagType] = {}

            end

            local count = math.ceil(#bagTypeItemTable[bagType] / cntPerLine) * cntPerLine
            if count < cntPerWarehousePage then

                count = cntPerWarehousePage

            end

            GUI.StaticSetText(capacityText, "道具数量：" .. #bagTypeItemTable[bagType]);

            GUI.LoopScrollRectSetTotalCount(itemScroll, count)

        end

        GUI.LoopScrollRectRefreshCells(itemScroll);

    end

end

function BagUI.OnShowWnd()

    test("isSetNewSeverBag",isSetNewSeverBag)

    test("GlobalProcessing.isSetNewSeverBag",GlobalProcessing.isSetNewSeverBag,type(GlobalProcessing.isSetNewSeverBag))

    if GlobalProcessing.isSetNewSeverBag ~= nil then

        isSetNewSeverBag = tonumber(GlobalProcessing.isSetNewSeverBag)

    end

    if isSetNewSeverBag == 1 then

        BagUI.SetTopBagTypeTable()

    end

    BagUI.Register();
    BagUI.OnBagBtnClick()
    BagUI.open = nil
end

function BagUI.OnNewItemAdd(guid)
    BagUI.wing_message_event(guid)
end

function BagUI.OnItemAdd(guid)

    --设置背包类型包裹数据
    BagUI.SetBagTypeItemTableData()

    BagUI.ResetBag(guid)

end

function BagUI.ResetBag(guid)
    --test("ResetBag=>guid======================="..tostring(guid))
    --切换到放置到的仓库页
    local itemData=LD.GetItemDataByGuid(guid,item_container_type.item_container_warehouse_items)
    if itemData then
        local Site = itemData:GetAttr(ItemAttr_Native.Site)
        --test("Site========>"..Site)

        ------------------------Start 2024.05.13 装备配置隐藏装备仓库 Start-------------------------
        local warehouse_index = CL.GetIntCustomData("EquipPlan_WarehouseIndex")

        if warehouse_index ~= 0 then

            if tonumber(Site) >= warehouse_index then

                Site = Site - cntPerWarehousePage

            end

        end

        ------------------------End  2024.05.13 装备配置隐藏装备仓库  End-------------------------

        local SiteInPage = math.floor(Site/cntPerWarehousePage)
        --test("SiteInPage="..SiteInPage)
        BagUI.warehousePageIndex = SiteInPage+1

    end
end

function BagUI.ShowGemTabRedPoint(show)
    if BagUI.GemTabBtn then
        GUI.SetRedPointVisable(BagUI.GemTabBtn,show)
    end
end

function BagUI.ShowGuardTabRedPoint(show)
    if BagUI.GuardTabBtn then
        GUI.SetRedPointVisable(BagUI.GuardTabBtn,show)
    end
end

function BagUI.OnCustomDataUpdate(type, key, value)
    --test("------------ BagUI, OnCustomDataUpdate type:"..tostring(type)..",key: "..tostring(key)..",value: "..tostring(value))
    if type == 1 then
        if key == "EquipRewardLevel" or key == "GemRewardLevel" then
            BagUI.RefreshModel()
        end
    end
end

--刷新界面
function BagUI.Refresh()
    test("背包监听刷新")
    -- 羽翼页签小红点
    BagUI.set_wing_tab_red()

    --宝石信物小红点
    if MainUI.GemRedPointFlag then
        BagUI.ShowGemTabRedPoint(true)
    end
    if MainUI.GuardRedPointFlag then
        BagUI.ShowGuardTabRedPoint(true)
    end

    -- 如果已经打开时装界面，就直接退出
    if BagUI.tabIndex == 3 and _gt["tabPage"..BagUI.tabIndex] ~= nil and GUI.GetVisible(GUI.GetByGuid(_gt["tabPage"..BagUI.tabIndex])) then
        UILayout.OnTabClick(BagUI.tabIndex, tabList);
        return
        -- 如果已经打开羽翼界面，直接退出
    elseif BagUI.tabIndex == 4 and _gt["tabPage"..BagUI.tabIndex] ~= nil and GUI.GetVisible(GUI.GetByGuid(_gt["tabPage"..BagUI.tabIndex])) then
        UILayout.OnTabClick(BagUI.tabIndex, tabList);
        return
		 -- 如果已经打开坐骑界面，直接退出
	elseif BagUI.tabIndex == 5 and _gt["tabPage"..BagUI.tabIndex] ~= nil and GUI.GetVisible(GUI.GetByGuid(_gt["tabPage"..BagUI.tabIndex])) then
        UILayout.OnTabClick(BagUI.tabIndex, tabList);
        return		
    end

    for i = 1, #tabList do

        local page = _gt.GetUI("tabPage"..i);

        GUI.SetVisible(page, i == BagUI.tabIndex);

        if i == 3 and i == BagUI.tabIndex and _gt["tabPage"..BagUI.tabIndex] ~= nil then
            BagUI.firstOpenFashionPage = true
            BagUI.FashionRequest() -- 刷新时装页面
        end

        -- 羽翼
        if i == 4 and i == BagUI.tabIndex then
            if _gt["tabPage"..BagUI.tabIndex] ~= nil then
                -- 隐藏其他界面的内容
                -- 隐藏包裹数量字体
                local capacityText =  _gt.GetUI("capacityText")
                if capacityText then
                    GUI.SetVisible(capacityText,false)
                end
                -- 隐藏整理按钮
                local arrangeBtn = _gt.GetUI("arrangeBtn")
                if arrangeBtn then
                    GUI.SetVisible(arrangeBtn,false)
                end

                -- 关闭原先的物品栏
                local itemScroll = _gt.GetUI("itemScroll")
                if itemScroll  then
                    GUI.SetVisible(itemScroll, false);
                end
                -- 刷新羽翼界面
                WingUI.getSeverWingData()
            end
        end
		
		--坐骑
        if i == 5 and i == BagUI.tabIndex then
            if _gt["tabPage"..BagUI.tabIndex] ~= nil then
                -- 隐藏其他界面的内容
                -- 隐藏包裹数量字体
                local capacityText =  _gt.GetUI("capacityText")
                if capacityText then
                    GUI.SetVisible(capacityText,false)
                end
                -- 隐藏整理按钮
                local arrangeBtn = _gt.GetUI("arrangeBtn")
                if arrangeBtn then
                    GUI.SetVisible(arrangeBtn,false)
                end

                -- 关闭原先的物品栏
                local itemScroll = _gt.GetUI("itemScroll")
                if itemScroll  then
                    GUI.SetVisible(itemScroll, false);
                end
                -- 刷新坐骑界面
                MountUI.getSeverMountData()
            end
        end
    end
    UILayout.OnTabClick(BagUI.tabIndex, tabList);
    if BagUI.tabIndex == 1 then

        test("BagUI.tabIndex",BagUI.tabIndex)
        test("_gt[\"tabPage\"..BagUI.tabIndex]",_gt["tabPage"..BagUI.tabIndex])
        if _gt["tabPage"..BagUI.tabIndex] == nil then
            _gt["tabPage"..BagUI.tabIndex] = BagUI.CreateBagPage()
        end
        if isSetNewSeverBag == 0 then

            UILayout.OnSubTabClickEx(BagUI.subTabIndex, subTabList);

        elseif  isSetNewSeverBag == 1 then

            --创建或刷新顶部背包类型选项
            BagUI.CreateOrRefreshTopBagTypeLoop()

            --设置背包类型包裹数据
            BagUI.SetBagTypeItemTableData()

            --设置背包类型包裹数据
            BagUI.SetBagTypeItemTableData()

            --设置顶部包裹类型点击数据
            BagUI.SetTopBagTypeTableClickData()

        end

        BagUI.RewardBtnValueRefresh()
        BagUI.RefreshBag();
    elseif BagUI.tabIndex == 2 then
        if _gt["tabPage"..BagUI.tabIndex]  == nil then
            _gt["tabPage"..BagUI.tabIndex] = BagUI.CreateWarehousePage()
        end
        BagUI.RefreshWarehouse();
        if  isSetNewSeverBag == 1 then

        --设置背包类型包裹数据
        BagUI.SetBagTypeItemTableData()

        --设置背包类型包裹数据
        BagUI.SetBagTypeItemTableData()

        --设置顶部包裹类型点击数据
        BagUI.SetTopBagTypeTableClickData()
        end
    elseif BagUI.tabIndex == 3 then -- 如果当前页面下标为3
        if _gt["tabPage"..BagUI.tabIndex] == nil then -- 如果页面3 未创建
            _gt["tabPage"..BagUI.tabIndex] = BagUI.CreateFashionPage() -- 执行创建页面3 时装方法
            BagUI.FashionRequest() -- 刷新时装页面
        end

    elseif BagUI.tabIndex == 4 then
        if _gt["tabPage"..BagUI.tabIndex] == nil  then -- 如果页面4 未创建
            _gt["tabPage"..BagUI.tabIndex] = WingUI.CreateWingPage() -- 执行创建页面4 时装方法
            -- 隐藏其他界面的内容
            -- 隐藏包裹数量字体
            local capacityText =  _gt.GetUI("capacityText")
            if capacityText then
                GUI.SetVisible(capacityText,false)
            end
            -- 隐藏整理按钮
            local arrangeBtn = _gt.GetUI("arrangeBtn")
            if arrangeBtn then
                GUI.SetVisible(arrangeBtn,false)
            end

            -- 关闭原先的物品栏
            local itemScroll = _gt.GetUI("itemScroll")
            if itemScroll  then
                GUI.SetVisible(itemScroll, false);
            end
            -- 刷新界面
            WingUI.getSeverWingData()
        end
    elseif BagUI.tabIndex == 5 then
        if _gt["tabPage"..BagUI.tabIndex] == nil  then -- 如果页面4 未创建
            _gt["tabPage"..BagUI.tabIndex] = MountUI.CreateMountPage() -- 执行创建页面4 时装方法
            -- 隐藏其他界面的内容
            -- 隐藏包裹数量字体
            local capacityText =  _gt.GetUI("capacityText")
            if capacityText then
                GUI.SetVisible(capacityText,false)
            end
            -- 隐藏整理按钮
            local arrangeBtn = _gt.GetUI("arrangeBtn")
            if arrangeBtn then
                GUI.SetVisible(arrangeBtn,false)
            end

            -- 关闭原先的物品栏
            local itemScroll = _gt.GetUI("itemScroll")
            if itemScroll  then
                GUI.SetVisible(itemScroll, false);
            end
            -- 刷新界面
            MountUI.getSeverMountData()
        end
    end
    BagSelectIndex1 = BagUI.tabIndex
end

function BagUI.RefreshBag()

    if BagUI.subTabIndex == 1 then

    elseif BagUI.subTabIndex == 2 then

    elseif BagUI.subTabIndex == 3 then

    end

    BagUI.RefreshModel();
    BagUI.RefreshEquipItem();
    BagUI.ShowItemScr();

    local roleName = GUI.GetByGuid(_gt.roleName);
    GUI.StaticSetText(roleName, CL.GetRoleName());

    local jobImg = _gt.GetUI("jobImg")
    local roleDB = DB.GetSchool(CL.GetIntAttr(RoleAttr.RoleAttrJob1))
    GUI.ImageSetImageID(jobImg, tostring(roleDB.Icon))

    --local fightValue = _gt.GetUI("fightValue");
    --GUI.StaticSetText(fightValue, tostring(CL.GetAttr(RoleAttr.RoleAttrFightValue)))

    local fightText = _gt.GetUI("fightTxt");
    GUI.StaticSetText(fightText, tostring(CL.GetAttr(RoleAttr.RoleAttrFightValue)))


    ----------------------------------------------Start 装备方案 Start------------------------------------------------------

    if UIDefine.FunctionSwitch["EquipPlan"] and UIDefine.FunctionSwitch["EquipPlan"] == "on" then

        local panelBg = GUI.GetByGuid(_gt.panelBg);
        local bagPage = GUI.GetChild(panelBg,"bagPage",false)
        local equipmentSchemeBtn = GUI.GetChild(bagPage,"equipmentSchemeBtn",false)

        if equipmentSchemeBtn == nil then

            equipmentSchemeBtn = GUI.ButtonCreate(bagPage, "equipmentSchemeBtn", "1800602310", 400, -130, Transition.ColorTint, "配装", 90, 46, false);
            SetSameAnchorAndPivot(equipmentSchemeBtn, UILayout.BottomLeft)
            GUI.ButtonSetTextFontSize(equipmentSchemeBtn, 24);
            GUI.ButtonSetTextColor(equipmentSchemeBtn, UIDefine.Brown4Color);
            GUI.RegisterUIEvent(equipmentSchemeBtn, UCE.PointerClick, "BagUI", "OnEquipmentSchemeBtnClick");

        end

    end


    ----------------------------------------------End  装备方案  End------------------------------------------------------


end

function BagUI.RefreshModel()
    local roleModel = GUI.GetByGuid(_gt.roleModel);
    --
    --local roleId = CL.GetRoleTemplateID();
    --local roleDB = DB.GetRole(roleId);
    --if roleDB.Id ~= 0 then
    --  local sex = CL.GetIntAttr(RoleAttr.RoleAttrGender);
    --  local weaponId = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId);
    --  ModelItem.Bind(roleModel, tonumber(roleDB.Model),CL.GetIntAttr(RoleAttr.RoleAttrGender),CL.GetIntAttr(RoleAttr.RoleAttrGender),eRoleMovement.STAND_W1,weaponId,sex)
    --end

    ModelItem.BindSelfRole(roleModel,eRoleMovement.STAND_W1)
end

function BagUI.ShowItemScr()


    local arrangeBtn =  _gt.GetUI("arrangeBtn")
    GUI.SetVisible(arrangeBtn, true);

    local itemScroll = _gt.GetUI("itemScroll")
    GUI.SetVisible(itemScroll, true);

    if isSetNewSeverBag == 0 then

        local curBagType = BagUI.GetCurBagType();
        local curCount = LD.GetItemCount(curBagType);
        local capacity = LD.GetBagCapacity(curBagType);

        local capacityText =  _gt.GetUI("capacityText")
        GUI.SetVisible(capacityText, true);
        GUI.StaticSetText(capacityText, "包裹空间：" .. curCount .. "/" .. capacity);

        local count = capacity;
        if BagUI.tabIndex == 1 and curBagType == item_container_type.item_container_bag then
            count = math.floor(capacity / cntPerLine) * cntPerLine + cntPerLine;
            if count > LogicDefine.BagMaxLimit then
                count = LogicDefine.BagMaxLimit
            end
        end

        GUI.LoopScrollRectSetTotalCount(itemScroll, count);
        GUI.LoopScrollRectRefreshCells(itemScroll);

    elseif isSetNewSeverBag == 1 then


        --设置顶部包裹类型点击数据
        BagUI.SetTopBagTypeTableClickData()

        --刷新顶部loop数据
        BagUI.RefreshTopBagTypeLoop()

        local curBagType = item_container_type.item_container_bag;
        local curCount = LD.GetItemCount(curBagType);
        local capacity = LD.GetBagCapacity(curBagType);

        local capacityText =  _gt.GetUI("capacityText")
        GUI.SetVisible(capacityText, true);


        if topBagTypeTable[BagUI.subSeverTabIndex].allType == true then

            GUI.StaticSetText(capacityText, "包裹空间：" .. curCount .. "/" .. capacity);

            local count = capacity;
            if BagUI.tabIndex == 1 and BagUI.subSeverTabIndex == 1 then
                count = math.floor(capacity / cntPerLine) * cntPerLine + cntPerLine;
                if count > LogicDefine.BagMaxLimit then
                    count = LogicDefine.BagMaxLimit
                end
            end

            GUI.LoopScrollRectSetTotalCount(itemScroll, count);

        else

            test("BagUI.subSeverTabIndex",BagUI.subSeverTabIndex)

            local bagType = topBagTypeTable[BagUI.subSeverTabIndex].name

            test("bagType",inspect(bagType))
            test("bagTypeItemTable[bagType]",inspect(bagTypeItemTable[bagType]))
            if bagTypeItemTable[bagType] == nil then
                bagTypeItemTable[bagType] = {}
            end

            local count = math.ceil(#bagTypeItemTable[bagType] / cntPerLine) * cntPerLine
            if count < cntPerWarehousePage then

                count = cntPerWarehousePage

            end

            GUI.StaticSetText(capacityText, "道具数量：" .. #bagTypeItemTable[bagType]);

            test("count",count)
            GUI.LoopScrollRectSetTotalCount(itemScroll, count)

        end

        GUI.LoopScrollRectRefreshCells(itemScroll);

    end


end

function BagUI.RefreshEquipItem()
    for i = 0, 9 do
        local equipItem = GUI.GetByGuid(_gt["equipItem" .. i]);
        ItemIcon.BindIndexForBag(equipItem, i, item_container_type.item_container_equip);
    end
end

function BagUI.GetCurBagType()

    if BagUI.tabIndex == 1 then
        if BagUI.subTabIndex == 1 then
            return item_container_type.item_container_bag;
        elseif BagUI.subTabIndex == 2 then
            return item_container_type.item_container_gem_bag;
        elseif BagUI.subTabIndex == 3 then
            return item_container_type.item_container_guard_bag;
        end
    elseif BagUI.tabIndex == 2 then
        if BagUI.warehouseType == 1 then
            return item_container_type.item_container_bag;
        elseif BagUI.warehouseType == 2 then
            return item_container_type.item_container_gem_bag;
        elseif BagUI.warehouseType == 3 then
            return item_container_type.item_container_guard_bag;
        end
    end
end

function BagUI.RefreshWarehouse()
    if BagUI.tabIndex ~= 2 then
        return;
    end

    local itemWarehouse = GUI.GetByGuid(_gt.itemWarehouse);
    local petWarehouse = GUI.GetByGuid(_gt.petWarehouse);
    local warehouseTypeBtn = GUI.GetByGuid(_gt.warehouseTypeBtn);
    test("RefreshWarehouse==> BagUI.warehouseType="..BagUI.warehouseType)
    if BagUI.warehouseType == 1 or BagUI.warehouseType == 2 or BagUI.warehouseType == 3 then
        GUI.ButtonSetText(warehouseTypeBtn, "宠物仓库");
        GUI.SetVisible(itemWarehouse, true);
        GUI.SetVisible(petWarehouse, false);
        BagUI.ShowItemScr();

        local warehouseItemScroll = GUI.GetByGuid(_gt.warehouseItemScroll)
        GUI.LoopScrollRectSetTotalCount(warehouseItemScroll, cntPerWarehousePage);
        GUI.LoopScrollRectRefreshCells(warehouseItemScroll);

        local depositBg = _gt.GetUI("depositBg");
        UILayout.RefreshAttrBar(depositBg,RoleAttr.RoleAttrBindGold,UIDefine.ExchangeMoneyToStr(tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrWarehouseGold)))))

        local warehousePageText = _gt.GetUI("warehousePageText");

        GUI.StaticSetText(warehousePageText,"仓库"..BagUI.warehousePageIndex);

        local BagTypeBtn = _gt.GetUI("BagTypeBtn")
        local BagTypeBtnText = GUI.GetChild(BagTypeBtn,"text")
        if isSetNewSeverBag == 0 then

            GUI.StaticSetText(BagTypeBtnText,subTabList[BagUI.warehouseType][1])

        elseif isSetNewSeverBag == 1 then

            GUI.StaticSetText(BagTypeBtnText,topBagTypeTable[BagUI.subSeverTabIndex].name)

        end


    elseif BagUI.warehouseType == 4 then

        -- BagUI.petGuidList = LD.GetPetGuids(pet_container_type.pet_container_panel);
        -- BagUI.warehousePetGuidList = LD.GetPetGuids(pet_container_type.pet_container_warehouse_pets);

        BagUI.petGuidList = BagUI.GetPetList(pet_container_type.pet_container_panel)
        BagUI.warehousePetGuidList = BagUI.GetPetList(pet_container_type.pet_container_warehouse_pets)

        GUI.ButtonSetText(warehouseTypeBtn, "道具仓库");
        GUI.SetVisible(itemWarehouse, false);
        GUI.SetVisible(petWarehouse, true);
        local capacityText = GUI.GetByGuid(_gt.capacityText);
        GUI.SetVisible(capacityText, false);
        local arrangeBtn = GUI.GetByGuid(_gt.arrangeBtn);
        GUI.SetVisible(arrangeBtn, false);
        local itemScroll = GUI.GetByGuid(_gt.itemScroll);
        GUI.SetVisible(itemScroll, false);

        local warehousePetScroll = _gt.GetUI("warehousePetScroll");
        GUI.LoopScrollRectSetTotalCount(warehousePetScroll,  BagUI.warehousePetGuidList.Count);
        GUI.LoopScrollRectRefreshCells(warehousePetScroll);

        local petScroll = _gt.GetUI("petScroll");

        GUI.LoopScrollRectSetTotalCount(petScroll, LD.GetPetCount());
        GUI.LoopScrollRectRefreshCells(petScroll);

        local warehousePetCapacityText = _gt.GetUI("warehousePetCapacityText");
        GUI.StaticSetText(warehousePetCapacityText, LD.GetPetCount(pet_container_type.pet_container_warehouse_pets) .. "/" .. LD.GetPetCapacity(pet_container_type.pet_container_warehouse_pets))

        local petCapacityText = _gt.GetUI("petCapacityText");
        GUI.StaticSetText(petCapacityText, LD.GetPetCount(pet_container_type.pet_container_panel) .. "/" .. LD.GetPetCapacity(pet_container_type.pet_container_panel))
    end
end

function BagUI.GetPetList(petBagType)
    local a = -1
    local num1 = 0
    local petGuids = LD.GetPetGuids(petBagType);
    local petGuidList = {}
    petGuidList.Count = petGuids.Count

    if petGuids.Count == 0 then
    else
        --出战的宠物阵容
        for i=0, 4 do
            if UIDefine.NowLineupList[i] ~= "-1" then
                for j = 0, petGuids.Count - 1, 1 do
                    if tostring(petGuids[j]) == UIDefine.NowLineupList[i] then
                        a= a + 1
                        table.insert(petGuidList,a,petGuids[j])
                        num1 = num1 + 1
                    end
                end
            end
        end
        --出战阵容以外的宠物
        for i = 0, petGuids.Count - 1, 1 do
            local TorF = 0
            if num1 > 0 then
                for j = 0, num1-1, 1 do
                    if tostring(petGuids[i]) ~= tostring(petGuidList[j]) then
                        TorF = 0
                    else
                        TorF = 1
                        break
                    end
                end
                if TorF == 0 then
                    a= a + 1
                    table.insert(petGuidList,a,petGuids[i])
                end
            else
                a= a + 1
                table.insert(petGuidList,a,petGuids[i])
            end
        end
    end
    return petGuidList
end


--创建或刷新顶部背包类型选项
function BagUI.CreateOrRefreshTopBagTypeLoop()

    test("创建或刷新顶部背包类型选项")

    local panelBg = GUI.GetByGuid(_gt.panelBg);
    local bagPage = GUI.GetChild(panelBg,"bagPage",false)

    if bagPage == nil then

        bagPage = GUI.GroupCreate(panelBg, "bagPage", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg));
        SetSameAnchorAndPivot(bagPage, UILayout.Center)

    end

    if isSetNewSeverBag == 1 then

        local temp = {}

        for i = 1, #subTabList do

            local t = subTabList[i]
            t.hide = true

            table.insert(temp,t)
        end


        UILayout.CreateSubTab(temp, bagPage, "BagUI");

        local topBagTypeLoop = GUI.GetChild(bagPage,"topBagTypeLoop",false)
        if topBagTypeLoop == nil then

            topBagTypeLoop =
            GUI.LoopScrollRectCreate(
                    bagPage,
                    "topBagTypeLoop",
                    610,
                    -256,
                    510,
                    40,
                    "BagUI",
                    "CreateTopBagTypeItem",
                    "BagUI",
                    "RefreshTopBagTypeItem",
                    0,
                    true,
                    Vector2.New(170, 40),
                    1,
                    UIAroundPivot.TopLeft,
                    UIAnchor.TopLeft,
                    false
            )
            SetSameAnchorAndPivot(topBagTypeLoop, UILayout.Left)
            GUI.ScrollRectSetAlignment(topBagTypeLoop, TextAnchor.UpperLeft)
            _gt.BindName(topBagTypeLoop, "topBagTypeLoop")
            GUI.ScrollRectSetChildSpacing(topBagTypeLoop, Vector2.New(0, 15))
            topBagTypeLoop:RegisterEvent(UCE.EndDrag)
            GUI.RegisterUIEvent(topBagTypeLoop, UCE.EndDrag , "BagUI", "OnTypeBtnDrag")

            local leftTag = GUI.ImageCreate(bagPage, "leftTag", "1801507230", 595, -258, false, 32, 32)
            _gt.BindName(leftTag, "leftTag")
            SetSameAnchorAndPivot(leftTag, UILayout.Left)
            GUI.SetVisible(leftTag, false)

            local rightTag = GUI.ImageCreate(bagPage, "rightTag", "1801507230", -100, -258, false, 32, 32)
            _gt.BindName(rightTag, "rightTag")
            SetSameAnchorAndPivot(rightTag, UILayout.Right)
            GUI.SetEulerAngles(rightTag,Vector3.New(0, 0, -180))
            GUI.SetVisible(rightTag, #topBagTypeTable > 3)

        end

        GUI.LoopScrollRectSetTotalCount(topBagTypeLoop, #topBagTypeTable)
        GUI.LoopScrollRectRefreshCells(topBagTypeLoop)

    end

end

function BagUI.CreateBagPage()

    local panelBg = GUI.GetByGuid(_gt.panelBg);
    local bagPage = GUI.GroupCreate(panelBg, "bagPage", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg));
    SetSameAnchorAndPivot(bagPage, UILayout.Center)

    if isSetNewSeverBag == 0 then

        UILayout.CreateSubTab(subTabList, bagPage, "BagUI");
        BagUI.GemTabBtn = GUI.GetChild(bagPage, subTabList[2][2])
        BagUI.GuardTabBtn = GUI.GetChild(bagPage, subTabList[3][2])
        if BagUI.GemTabBtn then
            GUI.AddRedPoint(BagUI.GemTabBtn,UIAnchor.TopLeft,20,18,"1800208080")
            BagUI.ShowGemTabRedPoint(false)
        end
        if BagUI.GuardTabBtn then
            GUI.AddRedPoint(BagUI.GuardTabBtn,UIAnchor.TopLeft,20,18,"1800208080")
            BagUI.ShowGuardTabRedPoint(false)
        end

    end


    local sellBtn = GUI.ButtonCreate(bagPage, "sellBtn", "1800402080", 365, 268, Transition.ColorTint, "出售", 100, 47, false);
    GUI.SetIsOutLine(sellBtn, true);
    GUI.ButtonSetTextFontSize(sellBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(sellBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(sellBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(sellBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(sellBtn, UCE.PointerClick, "BagUI", "OnSellBtnClick");

	if UIDefine.FunctionSwitch and UIDefine.FunctionSwitch["Stall"] == "on" then
		local stallBtn = GUI.ButtonCreate(bagPage, "stallBtn", "1800402080", 260, 268, Transition.ColorTint, "摆摊", 100, 47, false);
		GUI.SetIsOutLine(stallBtn, true);
		GUI.ButtonSetTextFontSize(stallBtn, UIDefine.FontSizeXL);
		GUI.ButtonSetTextColor(stallBtn, UIDefine.WhiteColor);
		GUI.SetOutLine_Color(stallBtn, UIDefine.OutLine_BrownColor);
		GUI.SetOutLine_Distance(stallBtn, UIDefine.OutLineDistance);
		GUI.RegisterUIEvent(stallBtn, UCE.PointerClick, "BagUI", "OnStallBtnClick")
	end
	

    local shadow = GUI.ImageCreate(bagPage, "shadow", "1800400240", -265, 180);

    local model = GUI.RawImageCreate(bagPage, false, "model", "", -300, 0, 3,false,620,620)
    _gt.BindName(model, "model");
    model:RegisterEvent(UCE.Drag)
    model:RegisterEvent(UCE.PointerClick)
    GUI.AddToCamera(model);
    GUI.RawImageSetCameraConfig(model, "(0.15,1.55,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,5,0.01,1.45,1E-05");
    --model:RegisterEvent(UCE.PointerClick)
    --GUI.RegisterUIEvent(model, UCE.PointerClick, "BagUI", "OnModelClick")

    local roleModel = GUI.RawImageChildCreate(model, false, "roleModel", "", 0, 0)
    _gt.BindName(roleModel, "roleModel");
    GUI.BindPrefabWithChild(model, GUI.GetGuid(roleModel));
    --GUI.RegisterUIEvent(roleModel, ULE.AnimationCallBack, "BagUI", "OnAnimationCallBack")

    for i = 0, 9 do
        local equipItem;
        if i > 4 then
            equipItem = ItemIcon.Create(bagPage, "equipItem" .. i, -60, -190 + (100 * (i - 5)));
        else
            equipItem = ItemIcon.Create(bagPage, "equipItem" .. i, -470, -190 + (100 * i));
        end
        GUI.RegisterUIEvent(equipItem, UCE.PointerClick, "BagUI", "OnEquipItemClick");
        GUI.ItemCtrlSetIndex(equipItem, i);
        _gt.BindName(equipItem, "equipItem" .. i);
    end

    local gemRewardBtn = GUI.ButtonCreate(bagPage,"gemRewardBtn", "1800602310", -335, -230, Transition.ColorTint, "", 90, 45, false);
    GUI.SetData(gemRewardBtn, "Index", 1);
    GUI.RegisterUIEvent(gemRewardBtn, UCE.PointerClick, "BagUI", "OnEquipRewardClick");
    GUI.ImageCreate(gemRewardBtn,"sprite", "1800607360", -15, -5, false, 50, 40);
    _gt.BindName(gemRewardBtn, "gemRewardBtn")

    local gemRewardBtn_value = GUI.CreateStatic(gemRewardBtn,"gemRewardBtn_value", "0", 22, 0, 45, 40, "system", true, false);
    GUI.SetColor(gemRewardBtn_value, UIDefine.WhiteColor);
    GUI.SetIsOutLine(gemRewardBtn_value, true);
    GUI.SetOutLine_Color(gemRewardBtn_value, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(gemRewardBtn_value, UIDefine.OutLineDistance);
    GUI.StaticSetFontSize(gemRewardBtn_value, UIDefine.FontSizeL);
    GUI.StaticSetAlignment(gemRewardBtn_value, TextAnchor.MiddleCenter);
    _gt.BindName(gemRewardBtn_value, "gemRewardBtn_value")

    local enhanceRewardBtn = GUI.ButtonCreate(bagPage,"enhanceRewardBtn", "1800602310", -195, -230, Transition.ColorTint, "", 90, 45, false);
    GUI.SetData(enhanceRewardBtn, "Index", 2);
    GUI.RegisterUIEvent(enhanceRewardBtn, UCE.PointerClick, "BagUI", "OnEquipRewardClick");
    GUI.ImageCreate(enhanceRewardBtn, "sprite", "1800607370", -15, -5,false, 50, 40);
    local enhanceRewardBtn_value = GUI.CreateStatic(enhanceRewardBtn, "enhanceRewardBtn_value", "0", 22, 0,  45, 40, "system", true, false);
    GUI.SetColor(enhanceRewardBtn_value, UIDefine.WhiteColor );
    GUI.SetIsOutLine(enhanceRewardBtn_value, true);
    GUI.SetOutLine_Color(enhanceRewardBtn_value, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(enhanceRewardBtn_value, UIDefine.OutLineDistance);
    GUI.StaticSetFontSize(enhanceRewardBtn_value, UIDefine.FontSizeL);
    GUI.StaticSetAlignment(enhanceRewardBtn_value, TextAnchor.MiddleCenter);
    _gt.BindName(enhanceRewardBtn_value, "enhanceRewardBtn_value")

    CL.SendNotify(NOTIFY.SubmitForm, "FormAttributeEnhance", "GetData")

    local nameBg = GUI.ImageCreate(bagPage, "nameBg", "1800400210", -265, 225);
    _gt.BindName(nameBg,"nameBg")
    local roleName = GUI.CreateStatic(nameBg, "roleName", "名字", 0, 1,190,32);
    GUI.SetColor(roleName, UIDefine.WhiteColor);
    GUI.StaticSetFontSize(roleName, UIDefine.FontSizeS);
    GUI.StaticSetAlignment(roleName, TextAnchor.MiddleCenter);
    _gt.BindName(roleName, "roleName");
    local jobImg = GUI.ImageCreate(nameBg, "jobImg", "1800903010", 70, 1);--,false,45,45
    GUI.SetPivot(jobImg, UIAroundPivot.Right);
    GUI.SetAnchor(jobImg, UIAnchor.Left);
    _gt.BindName(jobImg, "jobImg");

    -- local fightLogo = GUI.ImageCreate(nameBg, "fightLogo", "1800407010", -100, 45);

    -- local fightText = GUI.CreateStatic(nameBg, "fightText", "装备评分", -80, 45, 150, 30);
    -- GUI.SetColor(fightText, UIDefine.BrownColor);
    -- GUI.StaticSetFontSize(fightText, UIDefine.FontSizeM);
    -- GUI.StaticSetAlignment(fightText, TextAnchor.MiddleLeft);
    -- GUI.SetPivot(fightText, UIAroundPivot.Left)

    -- local fightValue = GUI.CreateStatic(nameBg, "fightValue", "0", 30, 45, 200, 30);
    -- GUI.SetColor(fightValue, UIDefine.BrownColor);
    -- GUI.StaticSetFontSize(fightValue, UIDefine.FontSizeM);
    -- GUI.StaticSetAlignment(fightValue, TextAnchor.MiddleLeft);
    -- GUI.SetPivot(fightValue, UIAroundPivot.Left)
    -- _gt.BindName(fightValue, "fightValue");

    --local fightBg = GUI.ImageCreate(nameBg, "fightBg", "1801300180", 0, 40, false, 333, 52);
    local fightBg = GUI.GroupCreate(nameBg,"fightBg",0,40,333,52)
    SetAnchorAndPivot(fightBg, UIAnchor.Center, UIAroundPivot.Center)
    local fightFlower1 = GUI.ImageCreate(fightBg, "fightFlower1", "1800407010", -90, 0);
    SetAnchorAndPivot(fightFlower1, UIAnchor.Center, UIAroundPivot.Center)
    local fightFlower2 = GUI.ImageCreate(fightBg, "fightFlower2", "1801405360", -20, 0);
    SetAnchorAndPivot(fightFlower2, UIAnchor.Center, UIAroundPivot.Center)
    local fightTxt = GUI.CreateStatic(fightBg, "fightTxt", "0", 35, 1, 150, 30, "system", true, false);
    _gt.BindName(fightTxt, "fightTxt")
    GUI.SetPivot(fightTxt, UIAroundPivot.Left);
    GUI.StaticSetAlignment(fightTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(fightTxt, sizeBig);
    GUI.SetColor(fightTxt, colorDark);
    local scoreHint = GUI.ButtonCreate(fightBg, "scoreHint", "1800702030", -127, 0, Transition.ColorTint, "")
    SetAnchorAndPivot(scoreHint, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(scoreHint, UCE.PointerClick, "BagUI", "OnScoreHintBtnClick")

    return GUI.GetGuid(bagPage);
end

function BagUI.OnEquipmentSchemeBtnClick()

    GUI.OpenWnd("EquipmentSchemeUI")

end

function BagUI.OnTypeBtnDrag(guid)
    local leftTag = _gt.GetUI("leftTag")
    local rightTag = _gt.GetUI("rightTag")
    local typeBtnScroll = GUI.GetByGuid(guid)
    local x,y = GUI.GetNormalizedPosition(typeBtnScroll):Get()

    if x <= 1 and x > 0.93 then

        GUI.SetVisible(leftTag,false)
        GUI.SetVisible(rightTag,true)

    elseif x < 0.07 and x >= 0 then

        GUI.SetVisible(leftTag,true)
        GUI.SetVisible(rightTag,false)
    else

        GUI.SetVisible(leftTag,true)
        GUI.SetVisible(rightTag,true)

    end

end


function BagUI.CreateTopBagTypeItem()

    local topBagTypeLoop = _gt.GetUI("topBagTypeLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(topBagTypeLoop) + 1

    local subTab = GUI.CheckBoxExCreate(topBagTypeLoop, "subTab"..index, "1800402030", "1800402032",0, 0, false, 175, 40,false)
    GUI.RegisterUIEvent(subTab, UCE.PointerClick, "BagUI", "topBagTypeItemClick")

    local text = GUI.CreateStatic(subTab, "text", "包裹名字", 0, 0, 175, 40)
    SetSameAnchorAndPivot(text, UILayout.Center)
    GUI.StaticSetFontSize(text, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
    GUI.SetColor(text, UIDefine.BrownColor)

    return subTab

end

function BagUI.RefreshTopBagTypeItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = topBagTypeTable[index]

    if data then

        local text = GUI.GetChild(item,"text",false)
        GUI.StaticSetText(text,data.name)

        GUI.CheckBoxExSetCheck(item,data.isClick)
        GUI.SetData(item,"index",index)

    end

end

function BagUI.topBagTypeItemClick(guid)

    local checkBox = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(checkBox,"index"))

    BagUI.subSeverTabIndex = index

    --设置顶部包裹类型点击数据
    BagUI.SetTopBagTypeTableClickData()

    --刷新顶部loop数据
    BagUI.RefreshTopBagTypeLoop()

    --包裹类型Loop刷新
    BagUI.RefreshBagTypeItemScrollData()

end

--刷新顶部loop数据
function BagUI.RefreshTopBagTypeLoop()

    test("刷新顶部loop数据")

    local topBagTypeLoop = _gt.GetUI("topBagTypeLoop")
    GUI.LoopScrollRectSetTotalCount(topBagTypeLoop, #topBagTypeTable)
    GUI.LoopScrollRectRefreshCells(topBagTypeLoop)

end

function BagUI.OnScoreHintBtnClick()
    --角色战力
    local fightValue = CL.GetAttr(RoleAttr.RoleAttrFightValue)

    --上阵宠物
    local petNum = 0
    --local linup_pet_guid = GlobalUtils.GetMainLineUpPetGuid()
    --test("===linup_pet_guid===="..tostring(linup_pet_guid))
    --petNum = LD.GetPetAttr(RoleAttr.RoleAttrFightValue, linup_pet_guid)
    local petList=LD.GetPetGuids()
    for i = 0, petList.Count-1 do
        local id = petList[i]
        --local state = tostring(LD.GetPetAttr(id, RoleAttr.PetAttrStatus))--获取宠物状态，>宠物状态：bit0:绑定 bit1:锁定 bit2:展示 bit3:上阵
        local isLineup = LD.GetPetState(PetState.Lineup,id)
        if isLineup then
            local zl = LD.GetPetAttr(RoleAttr.RoleAttrFightValue, id)
            petNum = petNum + zl
        end
    end

    --上阵侍从
    local guardNum = 0
    local activeGuardList = LD.GetActivedGuard()
    for i = 0,activeGuardList.Count-1 do
        local id = activeGuardList[i]
        local linup = tostring(LD.GetGuardAttr(id,RoleAttr.GuardAttrIsLinup))
        if linup == "1" then --已上阵的
            local zl = LD.GetGuardAttr(id,RoleAttr.RoleAttrFightValue)
            --test("=========zl======="..tostring(zl))
            guardNum = guardNum + zl
        end
    end

    --总战力
    local totalNum = fightValue + petNum + guardNum

    local parent = _gt.GetUI("nameBg")
    local zongzhanli_desc = "总战力=角色战力+上阵宠物战力+上阵侍从战力"
    local zongzhanli_num = "总战力:".."<color=yellow>"..tostring(totalNum).."</color>"
    local jusezhanli_num = "角色战力:".."<color=yellow>"..tostring(fightValue).."</color>"
    local petzhanli_num = "上阵宠物战力:".."<color=yellow>"..tostring(petNum).."</color>"
    local guardzhanli_num = "上阵侍从战力:".."<color=yellow>"..tostring(guardNum).."</color>"
    local info = string.format("%s\n%s\n%s\n%s\n%s",zongzhanli_desc,zongzhanli_num,jusezhanli_num,petzhanli_num,guardzhanli_num)
    Tips.CreateHint(info, parent, 100, -70, {UIAnchor.Center, UIAroundPivot.Center}, 480,150,true)

end

function BagUI.OnEquipRewardClick(Guid)
    local RewardBtn = GUI.GetByGuid(Guid)
    local Index = GUI.GetData(RewardBtn, "Index")
    GUI.OpenWnd("EquipRewardUI", Index)
end

function BagUI.OnModelClick()
    local roleModel = GUI.GetByGuid(_gt.roleModel);
    math.randomseed(os.time())
    local index = math.random(2)
    local movements = { eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1 }
    ModelItem.BindSelfRole(roleModel,movements[index])

end

function BagUI.OnAnimationCallBack(guid, action)
    if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
        return
    end

    local roleModel = GUI.GetByGuid(_gt.roleModel);
    ModelItem.BindSelfRole(roleModel,eRoleMovement.ATTSTAND_W1)
end

function BagUI.OnSellBtnClick(guid)
    GUI.OpenWnd("ShopUI", 2)
end

function BagUI.OnStallBtnClick()
	 GUI.OpenWnd("StallsUI", "0")
end

function BagUI.OnArrangeBtnClick(guid)
    local curBagType = BagUI.GetCurBagType();

    CL.SendNotify(NOTIFY.RearrangeItem, System.Enum.ToInt(curBagType));

end

function BagUI.OnWarehouseArrangeBtnClick(guid)
    if GlobalProcessing.WarehouseClassify_Switch and GlobalProcessing.WarehouseClassify_Switch == 'on' then
        CL.SendNotify(NOTIFY.SubmitForm, "FormWarehouseClassify", "RearrangeItem", cntPerWarehousePage, BagUI.warehousePageIndex)
    else
        CL.SendNotify(NOTIFY.RearrangeItem, System.Enum.ToInt(item_container_type.item_container_warehouse_items));
    end
end

--创建仓库界面
function BagUI.CreateWarehousePage()
    local wnd = GUI.GetWnd("BagUI");
    local panelBg = GUI.GetByGuid(_gt.panelBg);
    local warehousePage = GUI.GroupCreate(panelBg, "warehousePage", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd));

    local warehouseScroll = GUI.ImageCreate(warehousePage, "warehouseScroll", "1800400010", -265, 0, false, 515, 480);
    local scroll = GUI.ScrollRectCreate(warehouseScroll, "scroll", 0, 0, 490, 450, 0, false, Vector2.New(80, 80), UIAroundPivot.Top, UIAnchor.Top,6);
    GUI.ScrollRectSetChildSpacing(scroll, Vector2.New(1, 1));
    local title = GUI.ImageCreate(warehousePage, "title", "1800400420", 96, -256);
    local text = GUI.CreateStatic(title, "text", "我的包裹", 0, 0, 150, 35);
    GUI.StaticSetFontSize(text, UIDefine.FontSizeM);
    GUI.SetColor(text, UIDefine.BrownColor);
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);


    --道具仓库
    local itemWarehouse = GUI.GroupCreate(warehousePage, "itemWarehouse", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd));
    _gt.BindName(itemWarehouse, "itemWarehouse");

    local warehouseTypeBtn = GUI.ButtonCreate(warehousePage, "warehouseTypeBtn", "1800402110", -70, -255, Transition.ColorTint, "宠物仓库", 118, 38, false);
    GUI.ButtonSetTextFontSize(warehouseTypeBtn, UIDefine.FontSizeS);
    GUI.ButtonSetTextColor(warehouseTypeBtn, UIDefine.BrownColor);
    GUI.RegisterUIEvent(warehouseTypeBtn, UCE.PointerClick, "BagUI", "OnWarehouseTypeBtnClick");
    _gt.BindName(warehouseTypeBtn, "warehouseTypeBtn");

    --包裹类型选择按钮
    local BagTypeBtn = GUI.ButtonCreate(itemWarehouse, "BagTypeBtn", "1800700070", 425, -255, Transition.ColorTint, "", 180, 36, false);
    GUI.SetAnchor(BagTypeBtn, UIAnchor.Center);
    GUI.SetPivot(BagTypeBtn, UIAroundPivot.Center);
    GUI.RegisterUIEvent(BagTypeBtn, UCE.PointerClick, "BagUI", "OnBagTypeBtnClick");
    _gt.BindName(BagTypeBtn,"BagTypeBtn");
    local text = GUI.CreateStatic(BagTypeBtn, "text", subTabList[1][1], 0, 0, 180, 35);
    GUI.StaticSetFontSize(text, UIDefine.FontSizeS)
    GUI.SetColor(text, UIDefine.BrownColor);
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);
    _gt.BindName(text,"BagTypeText")
    local arrow = GUI.ImageCreate(BagTypeBtn, "arrow", "1800607140", 70, 0, false, 20, 12);
    GUI.SetAnchor(arrow, UIAnchor.Center);
    GUI.SetPivot(arrow, UIAroundPivot.Center);

    local warehousePageBtn = GUI.ButtonCreate(itemWarehouse, "warehousePageBtn", "1800700070", -428, -255, Transition.ColorTint, "", 180, 36, false);
    GUI.RegisterUIEvent(warehousePageBtn, UCE.PointerClick, "BagUI", "OnWarehousePageBtnClick");
    _gt.BindName(warehousePageBtn,"warehousePageBtn");
    local text = GUI.CreateStatic(warehousePageBtn, "text", "仓库1", -5, 0, 150, 35);
    GUI.StaticSetFontSize(text, UIDefine.FontSizeS)
    GUI.SetColor(text, UIDefine.BrownColor);
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);
    _gt.BindName(text,"warehousePageText")
    local arrow = GUI.ImageCreate(warehousePageBtn, "arrow", "1800607140", 60, 0, false, 20, 12);
    GUI.SetAnchor(arrow, UIAnchor.Center);
    GUI.SetPivot(arrow, UIAroundPivot.Center);

    local saveCoinBtn = GUI.ButtonCreate(itemWarehouse, "saveCoinBtn", "1800402080", 335, 268, Transition.ColorTint, "存入银币", 140, 47, false);
    GUI.SetIsOutLine(saveCoinBtn, true);
    GUI.ButtonSetTextFontSize(saveCoinBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(saveCoinBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(saveCoinBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(saveCoinBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(saveCoinBtn, UCE.PointerClick, "BagUI", "OnSaveCoinBtnClick");

    local takeOutCoinBtn = GUI.ButtonCreate(itemWarehouse, "takeOutCoinBtn", "1800402080", -226, 268, Transition.ColorTint, "取出银币", 140, 47, false);
    GUI.SetIsOutLine(takeOutCoinBtn, true);
    GUI.ButtonSetTextFontSize(takeOutCoinBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(takeOutCoinBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(takeOutCoinBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(takeOutCoinBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(takeOutCoinBtn, UCE.PointerClick, "BagUI", "OnTakeOutCoinBtnClick");

    local arrangeWareHouseBtn = GUI.ButtonCreate(itemWarehouse, "arrangeWareHouseBtn", "1800402090", -80, 268, Transition.ColorTint, "整理仓库", 140, 47, false);
    GUI.SetIsOutLine(arrangeWareHouseBtn, true);
    GUI.ButtonSetTextFontSize(arrangeWareHouseBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(arrangeWareHouseBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(arrangeWareHouseBtn, UIDefine.OutLine_GreenColor);
    GUI.SetOutLine_Distance(arrangeWareHouseBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(arrangeWareHouseBtn, UCE.PointerClick, "BagUI", "OnWarehouseArrangeBtnClick");
    GUI.SetEventCD(arrangeWareHouseBtn,UCE.PointerClick,2);


    local depositBg=UILayout.CreateAttrBar(itemWarehouse,"depositBg",-415,268,195,UILayout.Center);
    _gt.BindName(depositBg, "depositBg");

    --左边仓库界面
    local warehouseItemScroll = GUI.LoopScrollRectCreate(itemWarehouse, "warehouseItemScroll", -265, 0, 490, 450,
            "BagUI", "CreatWarehouseItemIconPool", "BagUI", "RefreshWarehouseItemScroll", 0, false, Vector2.New(80, 80), cntPerLine, UIAroundPivot.Top, UIAnchor.Top);
    GUI.ScrollRectSetChildSpacing(warehouseItemScroll, Vector2.New(1, 1));
    _gt.BindName(warehouseItemScroll, "warehouseItemScroll");

    --宠物仓库
    local petWarehouse = GUI.GroupCreate(warehousePage, "petWarehouse", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd));
    _gt.BindName(petWarehouse, "petWarehouse");
    GUI.SetVisible(petWarehouse, false);


    local text1 = GUI.CreateStatic(petWarehouse, "text1", "仓库容量", -465, 268, 100, 30);
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeL);
    GUI.SetColor(text1, UIDefine.BrownColor);

    local warehousePetCapacityBg = GUI.ImageCreate(petWarehouse, "warehousePetCapacityBg", "1800700010", -335, 270, false, 150, 35);
    local warehousePetCapacityText = GUI.CreateStatic(warehousePetCapacityBg, "warehousePetText", "0/0", 0, -1, 150, 30);
    GUI.StaticSetFontSize(warehousePetCapacityText, UIDefine.FontSizeM);
    GUI.StaticSetAlignment(warehousePetCapacityText, TextAnchor.MiddleCenter);
    GUI.SetColor(warehousePetCapacityText, UIDefine.WhiteColor);
    _gt.BindName(warehousePetCapacityText, "warehousePetCapacityText");


    local addPetCapacityBtn = GUI.ButtonCreate(petWarehouse, "addPetCapacityBtn", "1800702020", -225, 270, Transition.ColorTint, "", 45, 45, false);
    GUI.RegisterUIEvent(addPetCapacityBtn, UCE.PointerClick, "BagUI", "OnAddPetCapacityBtnClick");

    local text2 = GUI.CreateStatic(petWarehouse, "text2", "携带数量", 305, 268, 100, 30);
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeL);
    GUI.SetColor(text2, UIDefine.BrownColor);

    local petCapacityBg = GUI.ImageCreate(petWarehouse, "petCapacityText", "1800700010", 440, 270, false, 150, 35);
    local petCapacityText = GUI.CreateStatic(petCapacityBg, "petCapacityText", "0/0", 0, -1, 150, 30);
    GUI.StaticSetFontSize(petCapacityText, UIDefine.FontSizeM);
    GUI.StaticSetAlignment(petCapacityText, TextAnchor.MiddleCenter);
    GUI.SetColor(petCapacityText, UIDefine.WhiteColor);
    _gt.BindName(petCapacityText, "petCapacityText");

    local petScroll = GUI.LoopScrollRectCreate(petWarehouse, "petScroll", 265, 0, 490, 450,
            "BagUI", "CreatPetItemPool", "BagUI", "RefreshPetScroll", 0, false,
            Vector2.New(485, 100), 1, UIAroundPivot.Top, UIAnchor.Top);
    _gt.BindName(petScroll, "petScroll");

    local warehousePetScroll = GUI.LoopScrollRectCreate(petWarehouse, "warehousePetScroll", -265, 0, 490, 450,
            "BagUI", "CreatWarehosePetItemPool", "BagUI", "RefreshWarehousePetScroll", 0, false,
            Vector2.New(485, 100), 1, UIAroundPivot.Top, UIAnchor.Top);
    _gt.BindName(warehousePetScroll, "warehousePetScroll");

    local pageSelectCover = GUI.ImageCreate(warehousePage, "pageSelectCover", "1800400220", 0, GUI.GetPositionY(panelBg), false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    pageSelectCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(pageSelectCover, true)
    GUI.RegisterUIEvent(pageSelectCover, UCE.PointerClick, "BagUI", "OnPageSelectCoverClick")
    GUI.SetVisible(pageSelectCover, false);
    _gt.BindName(pageSelectCover, "pageSelectCover");

    --左侧仓库选择背景
    local pageSelectBorder = GUI.ImageCreate(pageSelectCover, "pageSelectBorder", "1800400290", -340, 155, false, 360, 15 + 50 * 1);
    GUI.SetAnchor(pageSelectBorder, UIAnchor.Top);
    GUI.SetPivot(pageSelectBorder, UIAroundPivot.Top);

    local scr = GUI.ScrollRectCreate(pageSelectCover, "scr", -340, 165, 360, 50 * 1, 0, false, Vector2.New(165, 45), UIAroundPivot.Top, UIAnchor.Top, 2);
    --SetAnchorAndPivot(scr, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    SetAnchorAndPivot(scr, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(scr, Vector2.New(5, 5))

    --右侧背包选择背景
    local BagTypeCover = GUI.ImageCreate(warehousePage, "BagTypeCover", "1800400220", 0, GUI.GetPositionY(panelBg), false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    BagTypeCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(BagTypeCover, true)
    GUI.RegisterUIEvent(BagTypeCover, UCE.PointerClick, "BagUI", "OnBagTypeSelectClick")
    GUI.SetVisible(BagTypeCover, false);
    _gt.BindName(BagTypeCover, "BagTypeCover");

    --背包类型选择背景
    local BagSelectBorder = GUI.ImageCreate(BagTypeCover, "BagSelectBorder", "1800400290", 425, 155, false, 180, 15 + 50 * #subTabList);
    SetAnchorAndPivot(BagSelectBorder, UIAnchor.Top, UIAroundPivot.Top)

    --背包滚动列表
    local BagTypeScr = GUI.ScrollRectCreate(BagSelectBorder, "BagTypeScr", 0, 10, 180,   49 * #subTabList, 0, false, Vector2.New(165, 45), UIAroundPivot.Top, UIAnchor.Top, 1);
    GUI.SetAnchor(BagTypeScr, UIAnchor.TopLeft);
    GUI.SetPivot(BagTypeScr, UIAroundPivot.TopLeft);
    GUI.ScrollRectSetChildSpacing(BagTypeScr, Vector2.New(5, 5))


    return GUI.GetGuid(warehousePage);
end

function BagUI.ShowCoinMsg(isSave)
    local titleText , allCoinBtnText , msgText = ""
    if isSave then
        titleText = "银币存入"
        allCoinBtnText = "全部存入"
        msgText = "请输入存放银币的数额"
    else
        titleText = "银币取出"
        allCoinBtnText = "全部取出"
        msgText = "请输入提取银币的数额"
    end
    local itemWarehouse = _gt.GetUI("itemWarehouse")
    local msgPanel = GUI.ImageCreate(itemWarehouse,"msgPanel","1800001060",0,0,false,GUI.GetWidth(itemWarehouse),GUI.GetHeight(itemWarehouse))
    GUI.SetIsRaycastTarget(msgPanel, true)
    GUI.RegisterUIEvent(msgPanel, UCE.PointerClick, "BagUI", "OnMsgBoxCloseBtnClick")
    UILayout.SetAnchorAndPivot(msgPanel, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(msgPanel,"msgPanel")

    local msgBox = GUI.ImageCreate(msgPanel,"msgBox","1800001120",0,0,false,460,260)
    _gt.BindName(msgBox,"msgBox")
    --装饰花
    local flower = GUI.ImageCreate(msgBox,"flower","1800007060",-20,-20,true)
    UILayout.SetAnchorAndPivot(flower, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --标题
    local TitleBg = GUI.ImageCreate(msgBox,"TitleBg","1800001030",0,15,true)
    UILayout.SetAnchorAndPivot(TitleBg, UIAnchor.Top, UIAroundPivot.Top)
    local Title= GUI.CreateStatic(TitleBg, "title", titleText, 0, 4, 150, 30);
    UILayout.StaticSetFontSizeColorAlignment(Title, UIDefine.FontSizeL, UIDefine.White2Color, TextAnchor.MiddleCenter)

    --右上角关闭
    local ExitBtn = GUI.ButtonCreate(msgBox,"ExitBtn","1800002050",-10,10,Transition.ColorTint,"",0,0,true)
    UILayout.SetAnchorAndPivot(ExitBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(ExitBtn, UCE.PointerClick, "BagUI", "OnMsgBoxCloseBtnClick")

    --提交按钮
    local SubmitBtn = GUI.ButtonCreate(msgBox,"SubmitBtn","1800102090",100,90,Transition.ColorTint,"",160,46,false)
    UILayout.SetAnchorAndPivot(SubmitBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(SubmitBtn, UCE.PointerClick, "BagUI", "OnMsgBoxSubmitBtnClick")

    local SubmitBtnText = GUI.CreateStatic(SubmitBtn, "SubmitBtnText", "确定", 0, 0, 160, 80, "system", true)
    UILayout.SetAnchorAndPivot(SubmitBtnText, UIAnchor.Center, UIAroundPivot.Center)
    UILayout.StaticSetFontSizeColorAlignment(SubmitBtnText, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(SubmitBtnText, true)
    GUI.SetOutLine_Color(SubmitBtnText,Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(SubmitBtnText,1)

    --全选按钮
    local AllCoinBtn = GUI.ButtonCreate(msgBox,"AllCoinBtn","1800102090",-100,90,Transition.ColorTint,"",160,46,false)
    UILayout.SetAnchorAndPivot(AllCoinBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(AllCoinBtn, UCE.PointerClick, "BagUI", "OnMsgBoxAllCoinBtnClick")

    local AllCoinBtnText = GUI.CreateStatic( AllCoinBtn, "AllCoinBtnText", allCoinBtnText, 0, 0, 160, 80, "system", true)
    UILayout.SetAnchorAndPivot(AllCoinBtnText, UIAnchor.Center, UIAroundPivot.Center)
    UILayout.StaticSetFontSizeColorAlignment(AllCoinBtnText, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(AllCoinBtnText, true)
    GUI.SetOutLine_Color(AllCoinBtnText,Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(AllCoinBtnText,1)

    -- Msg
    local Msg = GUI.CreateStatic( msgBox, "Msg", msgText, 0, 50, 480, 80, "system", true)
    UILayout.SetAnchorAndPivot(Msg, UIAnchor.Top, UIAroundPivot.Top)
    UILayout.StaticSetFontSizeColorAlignment(Msg, UIDefine.FontSizeL, UIDefine.Brown4Color, TextAnchor.MiddleCenter)

    local Input = GUI.EditCreate(msgBox, "Input","1800001040", "", 0, 30, Transition.ColorTint, "system", 380, 50, 25, 10)
    GUI.EditSetBNumber(Input,true)
    GUI.EditSetProp(Input, 22, 50, TextAnchor.MiddleLeft, TextAnchor.MiddleLeft)
    GUI.EditSetMultiLineEdit(Input, LineType.SingleLine)
    GUI.EditSetTextColor(Input, UIDefine.BrownColor)
    GUI.RegisterUIEvent(Input, UCE.EndEdit, "BagUI", "InputValueChange")
    _gt.BindName(Input,"Input")
end

function BagUI.OnMsgBoxCloseBtnClick()
    local msgPanel = _gt.GetUI("msgPanel")
    GUI.Destroy(msgPanel)
end

function BagUI.InputValueChange()
    local msgBox = _gt.GetUI("msgBox")
    local Input = GUI.GetChild(msgBox,"Input")
    local coinNum = tonumber(GUI.EditGetTextM(Input))
    if coinNum == nil then
        coinNum = ""
    end
    GUI.EditSetTextM(Input,coinNum)
end

local isSave
function BagUI.OnMsgBoxSubmitBtnClick()
    local msgBox = _gt.GetUI("msgBox")
    local Input = GUI.GetChild(msgBox,"Input")
    local coinNum = tonumber(GUI.EditGetTextM(Input))
    if coinNum == nil then
        coinNum = 0
    end
    local ownCoinNum = 0
    --FormReserveMoney.AddWarehouseGold(player, val)  --向仓库存贮银币
    --FormReserveMoney.SubWarehouseGold(player, val)  --向仓库取出银币
    if isSave then
        ownCoinNum = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
        test("存入 " .. coinNum)
        if coinNum > ownCoinNum then
            CL.SendNotify(NOTIFY.ShowBBMsg, "您身上的银币不足！")
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormReserveMoney", "AddWarehouseGold",tostring(coinNum))
        end
    else
        test("取出 " .. coinNum)
        ownCoinNum = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrWarehouseGold)))
        if coinNum > ownCoinNum then
            CL.SendNotify(NOTIFY.ShowBBMsg, "您仓库中的银币不足！")
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormReserveMoney", "SubWarehouseGold",tostring(coinNum))
        end
    end
    BagUI.OnMsgBoxCloseBtnClick()
end

function BagUI.OnMsgBoxAllCoinBtnClick()
    local msgBox = _gt.GetUI("msgBox")
    local Input = GUI.GetChild(msgBox,"Input")
    local coinNum = 0
    if isSave then
        coinNum = tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold))
        test("身上 " .. coinNum)
    else
        coinNum = tostring(CL.GetAttr(RoleAttr.RoleAttrWarehouseGold))
        test("仓库 " .. coinNum)
    end
    GUI.EditSetTextM(Input,coinNum)
end


function BagUI.OnSaveCoinBtnClick()
    isSave = true
    BagUI.ShowCoinMsg(isSave)
end

function BagUI.OnTakeOutCoinBtnClick()
    isSave = false
    BagUI.ShowCoinMsg(isSave)
end

function BagUI.OnAddPetCapacityBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormBaseFunction", "UnlockPetDepotField")
end

function BagUI.OnWarehousePageBtnClick(guid)
    local pageSelectCover = GUI.GetByGuid(_gt.pageSelectCover);
    GUI.SetVisible(pageSelectCover,true)

    local pageSelectBorder = GUI.GetChild(pageSelectCover,"pageSelectBorder");
    local scr = GUI.GetChild(pageSelectCover,"scr");

    local capacity=LD.GetBagCapacity(item_container_type.item_container_warehouse_items)

    ------------------------Start 2024.05.13 装备配置隐藏装备仓库 Start-------------------------
    local warehouse_index = CL.GetIntCustomData("EquipPlan_WarehouseIndex")

    if warehouse_index ~= 0 then

        capacity = warehouse_index

    end

    ------------------------End  2024.05.13 装备配置隐藏装备仓库  End-------------------------

    local pageCount =math.floor(capacity/cntPerWarehousePage)
    local line = math.floor(pageCount/2)+1
    if pageCount>=warehousePageMax then
        line= math.floor(pageCount/2);
    end
    GUI.SetHeight(pageSelectBorder,15 + 50 * line)
    GUI.SetHeight(scr,50 * line)

    for i = 1, pageCount+1>warehousePageMax and warehousePageMax or pageCount+1 do
        local text = "仓库" .. i;
        if i == pageCount+1 then
            text = "购买仓库";
        end

        local pageBtn = GUI.GetChild(scr,"pageBtn"..i);
        if pageBtn==nil then
            pageBtn = GUI.ButtonCreate(scr, "pageBtn" .. i, "1801102010", 0, 0, Transition.ColorTint, text, 175, 40, false);
            GUI.ButtonSetTextColor(pageBtn, UIDefine.BrownColor);
            GUI.ButtonSetTextFontSize(pageBtn, UIDefine.FontSizeM);
            GUI.SetData(pageBtn, "Index", i);
            GUI.RegisterUIEvent(pageBtn, UCE.PointerClick, "BagUI", "OnPageBtnClick")
        end

        GUI.ButtonSetText(pageBtn,text);
    end

end

function BagUI.OnPageBtnClick(guid)
    local pageBtn = GUI.GetByGuid(guid);
    local index = tonumber(GUI.GetData(pageBtn,"Index"));

    local capacity=LD.GetBagCapacity(item_container_type.item_container_warehouse_items)

    ------------------------Start 2024.05.13 装备配置隐藏装备仓库 Start-------------------------
    local warehouse_index = CL.GetIntCustomData("EquipPlan_WarehouseIndex")

    if warehouse_index ~= 0 then

        capacity = warehouse_index

    end

    ------------------------End  2024.05.13 装备配置隐藏装备仓库  End-------------------------

    local pageCount =math.floor(capacity/cntPerWarehousePage)

    if index==pageCount+1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormBaseFunction", "UnlockDepotField")
    else
        BagUI.warehousePageIndex=index;
    end

    BagUI.OnPageSelectCoverClick();
    BagUI.Refresh();
end

--右侧背包类型点击事件
function BagUI.OnBagTypeBtnSelectClick(guid)
    local BagTypeSelectBtn = GUI.GetByGuid(guid);
    local index = tonumber(GUI.GetData(BagTypeSelectBtn,"Index"));

    local BagTypeCover = _gt.GetUI("BagTypeCover")
    GUI.SetVisible(BagTypeCover, false)

    if isSetNewSeverBag == 0 then
        BagUI.RefreshSelectTypeBag(2,index)

    elseif isSetNewSeverBag == 1 then

        local BagTypeBtn = _gt.GetUI("BagTypeBtn")
        local BagTypeBtnText = GUI.GetChild(BagTypeBtn,"text",false)
        GUI.StaticSetText(BagTypeBtnText,topBagTypeTable[index].name)

        BagUI.subSeverTabIndex = index

        local topBagTypeLoop = _gt.GetUI("topBagTypeLoop")
        GUI.LoopScrollRectSrollToCell(topBagTypeLoop,BagUI.subSeverTabIndex - 1,2000)


        if BagUI.subSeverTabIndex > #topBagTypeTable - 3 then

            local rightTag = _gt.GetUI("rightTag")
            GUI.SetVisible(rightTag,false)


            local leftTag = _gt.GetUI("leftTag")
            GUI.SetVisible(leftTag,true)

        elseif BagUI.subSeverTabIndex >= 1 then



            local rightTag = _gt.GetUI("rightTag")
            GUI.SetVisible(rightTag,true)


            local leftTag = _gt.GetUI("leftTag")
            GUI.SetVisible(leftTag,false)

        end

        --设置顶部包裹类型点击数据
        BagUI.SetTopBagTypeTableClickData()

        --包裹类型Loop刷新
        BagUI.RefreshBagTypeItemScrollData()

    end

end

--刷新包裹类型道具列表
function BagUI.RefreshSelectTypeBag(index1,index2)
    --index1 1为包裹，2为仓库
    --index2 1为包裹，2为宝石，3为侍从信物
    if index1 == nil then
        print("index1为空")
        return
    end
    if index1 > 2 then
        print("index1超出选择数值")
        return
    end
    if index2 == nil then
        print("index2为空")
        return
    end
    if index2 > #subTabList then
        print("index2超出选择背包数值")
        return
    end
    if index1 == 2 then
        local BagTypeBtn = _gt.GetUI("BagTypeBtn")
        local BagTypeBtnText = GUI.GetChild(BagTypeBtn,"text",false)
        GUI.StaticSetText(BagTypeBtnText,subTabList[index2][1])
    end
    BagSelectIndex1 = tonumber(index1)
    BagSelectIndex2 = tonumber(index2)
    BagUI.tabIndex = index1
    BagUI.warehouseType = index2
    local curBagType = BagUI.GetCurBagType();
    local capacity = LD.GetBagCapacity(curBagType);
    local curCount = LD.GetItemCount(curBagType);

    local capacityText =  _gt.GetUI("capacityText")
    GUI.SetVisible(capacityText, true);
    GUI.StaticSetText(capacityText, "包裹空间：" .. curCount .. "/" .. capacity)
    if curBagType then
        local count = capacity;
        local itemScroll = _gt.GetUI("itemScroll")
        GUI.LoopScrollRectSetTotalCount(itemScroll, count);
        GUI.LoopScrollRectRefreshCells(itemScroll);
    end
end

function BagUI.OnPageSelectCoverClick()
    local pageSelectCover = _gt.GetUI("pageSelectCover")
    GUI.SetVisible(pageSelectCover, false)
end

function BagUI.OnBagTypeSelectClick(guid)
    local BagTypeCover = GUI.GetByGuid(guid)
    GUI.SetVisible(BagTypeCover, false)
end

--创建包裹道具列表
function BagUI.CreateItemIconPool()
    local itemScroll = _gt.GetUI("itemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll);
    local itemicon = ItemIcon.Create(itemScroll, "itemIcon"..curCount, 0, 0)
    GUI.RegisterUIEvent(itemicon, UCE.PointerClick, "BagUI", "OnItemClick");
    return itemicon;
end

function BagUI.CreatWarehouseItemIconPool()
    local warehouseItemScroll = _gt.GetUI("warehouseItemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(warehouseItemScroll);
    local itemicon = ItemIcon.Create(warehouseItemScroll, "itemIcon"..curCount, 0, 0)
    GUI.RegisterUIEvent(itemicon, UCE.PointerClick, "BagUI", "OnWarehouseItemClick");
    return itemicon;
end


--刷新包裹道具列表
function BagUI.RefreshItemScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local itemIcon = GUI.GetByGuid(guid);

    if isSetNewSeverBag == 0 then
        local curBagType = BagUI.GetCurBagType();
        --控件，index，背包类型
        ItemIcon.BindIndexForBag(itemIcon, index, curBagType)

    elseif isSetNewSeverBag == 1 then

        if topBagTypeTable[BagUI.subSeverTabIndex].allType == true then

            local curBagType = BagUI.GetCurBagType();
            --控件，index，背包类型
            ItemIcon.BindIndexForBag(itemIcon, index, curBagType)
            GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "BagUI", "OnItemClick");
        else


            local bagType = topBagTypeTable[BagUI.subSeverTabIndex].name

            local data =  nil

            if bagTypeItemTable[bagType] ~= nil then

                if bagTypeItemTable[bagType][index + 1] ~= nil then

                    data = bagTypeItemTable[bagType][index + 1]

                end

            end

            if data ~= nil then
                --index,背包类型，玩家guid

                local itemData = LD.GetItemDataByIndex(data.index,item_container_type.item_container_bag,0)

                if itemData~=nil then

                    ItemIcon.BindItemData(itemIcon,itemData)

                    GUI.SetData(itemIcon,"severIndex",data.index)
                    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "BagUI", "OnItemClick");
                end

            else

                ItemIcon.SetEmpty(itemIcon)
                GUI.UnRegisterUIEvent(itemIcon, UCE.PointerClick, "BagUI", "OnItemClick");

            end


        end



    end

end

function BagUI.RefreshWarehouseItemScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local itemIcon = GUI.GetByGuid(guid);

    index = (BagUI.warehousePageIndex - 1) * cntPerWarehousePage + index;

    local curBagType = item_container_type.item_container_warehouse_items;
    ItemIcon.BindIndexForBag(itemIcon, index, curBagType);
end

function BagUI.CreatPetItemPool()

    local petScroll = _gt.GetUI("petScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(petScroll);
    local petItem = PetItem.Create(petScroll, "petItem"..curCount, 0, 0)
    GUI.RegisterUIEvent(petItem, UCE.PointerClick, "BagUI", "OnPetItemClick");
    return petItem;
end


function BagUI.CreatWarehosePetItemPool()
    local warehousePetScroll = _gt.GetUI("warehousePetScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(warehousePetScroll);
    local petItem = PetItem.Create(warehousePetScroll, "petItem"..curCount, 0, 0)
    GUI.RegisterUIEvent(petItem, UCE.PointerClick, "BagUI", "OnWarehousePetItemClick");
    return petItem;
end

function BagUI.RefreshPetScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);

    if index >= LD.GetPetCount() then
        return ;
    end

    local petItem = GUI.GetByGuid(guid);
    local petGuid = BagUI.petGuidList[index];
    PetItem.BindPetGuid(petItem, petGuid, pet_container_type.pet_container_panel)
end

function BagUI.RefreshWarehousePetScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);

    if index >= LD.GetPetCount(pet_container_type.pet_container_warehouse_pets) then
        return ;
    end

    local petItem = GUI.GetByGuid(guid);
    local petGuid = BagUI.warehousePetGuidList[index];
    PetItem.BindPetGuid(petItem, petGuid, pet_container_type.pet_container_warehouse_pets)
end

function BagUI.OnEquipItemClick(guid)

    local equipItem = GUI.GetByGuid(guid);
    local index = GUI.ItemCtrlGetIndex(equipItem);
    local itemData = LD.GetItemDataByIndex(index, item_container_type.item_container_equip);


    ItemIndex = 1
    if itemData ~= nil then
        selectItemGuid = tostring(itemData.guid)
        NowClick = itemData
        if BagUI.selectedGuid == guid then
            local itemTips = _gt.GetUI("itemTips");
            GUI.Destroy(itemTips);

            BagUI.OnRemoveEquipBtnClick();
            BagUI.CancelSelectedItem();
            return;
        end

        BagUI.CancelSelectedItem();
        BagUI.selectedGuid = guid;
        BagUI.selectedIndex = index;
        GUI.ItemCtrlSelect(equipItem);
        local panelBg = GUI.GetByGuid(_gt.panelBg);
        --local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", 200, 0, 55);

        ---------------------------------------------2023.11.17  修改地方Start------------------------------------------------
        local itemTips = Tips.CreateSpecilaItemTips(itemData, panelBg, "itemTips", 200, 0, 55)
        --原来的代码
        --local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", 200, 0, 55);
        ---------------------------------------------2023.11.17  修改地方End------------------------------------------------
                   


        GUI.AddWhiteName(itemTips,guid);
        _gt.BindName(itemTips,"itemTips");
        local inEquip=GUI.ImageCreate(itemTips, "inEquip", "1800707290", 0, 0)
        UILayout.SetSameAnchorAndPivot(inEquip, UILayout.TopLeft);
        local removeEquipBtn = GUI.ButtonCreate(itemTips, "removeEquipBtn", 1800402110, 0, -10, Transition.ColorTint, "卸下", 150, 50, false);
        UILayout.SetSameAnchorAndPivot(removeEquipBtn, UILayout.Bottom);
        GUI.ButtonSetTextColor(removeEquipBtn, UIDefine.BrownColor);
        GUI.ButtonSetTextFontSize(removeEquipBtn, UIDefine.FontSizeL)
        GUI.SetPositionX(removeEquipBtn,90)
        GUI.RegisterUIEvent(removeEquipBtn, UCE.PointerClick, "BagUI", "OnRemoveEquipBtnClick");
        local moreBtn = GUI.ButtonCreate(itemTips,"moreBtn",1800402110, 0 , -10, Transition.ColorTint, "", 150, 50, false);
        _gt.BindName(moreBtn,"moreBtn")
        UILayout.SetSameAnchorAndPivot(moreBtn, UILayout.Bottom);
        GUI.SetPositionX(moreBtn,-90)
        local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","更多",30,0,150,50)
        UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
        UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        GUI.RegisterUIEvent(moreBtn, UCE.PointerClick, "BagUI", "OnMoreBtnClick");
        local Arrow = GUI.ImageCreate(moreBtn,"moreArrow",1800607140,40,15,false,35,20)
        _gt.BindName(Arrow,"Arrow")
        GUI.AddWhiteName(itemTips,GUI.GetGuid(moreBtn))


    end
end

local TempGuid = nil
function BagUI.OnItemClick(guid)

    test("物品点击tips")

    local itemIcon = GUI.GetByGuid(guid);
    local index = GUI.ItemCtrlGetIndex(itemIcon)


    if isSetNewSeverBag == 1 then

        if topBagTypeTable[BagUI.subSeverTabIndex].allType ~= true then

            index = tonumber(GUI.GetData(itemIcon,"severIndex"))

        end

    end

    local curBagType = BagUI.GetCurBagType();
    local capacity = LD.GetBagCapacity(curBagType);
    if index >= capacity then
        --解锁
        CL.SendNotify(NOTIFY.SubmitForm, "FormBaseFunction", "UnlockBagField")
        BagUI.CancelSelectedItem();
    else

        local itemData = LD.GetItemDataByIndex(index, curBagType);

        -----------------------------------------2021.6.3  新增东西Start------------------------------------
        local itemCustomAttr_Level= LD.GetItemIntCustomAttrByIndex("itemRandomLevel",index,curBagType)
        local tmp_itemCustomData={}
        tmp_itemCustomData.itemRandomLevel=nil
        tmp_itemCustomData.itemRandomLevel=tonumber(itemCustomAttr_Level)
        -----------------------------------------2021.6.3  新增东西End-------------------------------------

        if itemData ~= nil then

            selectItemGuid = tostring(itemData.guid)

            TempGuid = tostring(itemData.guid)
            local itemDB = DB.GetOnceItemByKey1(itemData.id);
            NowClick = itemData
            if itemDB.Id == 0 then
                return ;
            end

            if BagUI.selectedGuid == guid then
                local itemTips = _gt.GetUI("itemTips");
                GUI.Destroy(itemTips);
                local itemTips2 = _gt.GetUI("itemTips2");
                if itemTips2 then
                    GUI.Destroy(itemTips2);
                end
                if BagUI.tabIndex == 1 then
                    if  LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)~=-1 then
                        BagUI.OnEquipBtnClick()
                    else
                        BagUI.OnUseBtnClick(itemDB.Id);
                    end
                elseif BagUI.tabIndex == 2 then
                    BagUI.OnInWarehouseClick();
                end

                BagUI.CancelSelectedItem();
                return ;
            end

            BagUI.CancelSelectedItem();
            BagUI.selectedGuid = guid;
            BagUI.selectedIndex = index;
            GUI.ItemCtrlSelect(itemIcon);

            local panelBg = GUI.GetByGuid(_gt.panelBg);
            ---------------------------------------------2021.6.3  修改地方Start------------------------------------------------
            
            --local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", -200, 0, 55,nil,tmp_itemCustomData);
            --原来的代码
            --local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", -200, 0, 55);
            ---------------------------------------------2021.6.3  修改地方End------------------------------------------------
            
            ---------------------------------------------2023.11.17  修改地方Start------------------------------------------------
            local itemTips = Tips.CreateSpecilaItemTips(itemData, panelBg, "itemTips", -200, 0, 55,nil,tmp_itemCustomData)
            --原来的代码
            --local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", -200, 0, 55,nil,tmp_itemCustomData);
            ---------------------------------------------2023.11.17  修改地方End------------------------------------------------
            
            GUI.AddWhiteName(itemTips,guid);
            _gt.BindName(itemTips,"itemTips");

            local useBtn = GUI.ButtonCreate(itemTips, "useBtn", 1800402110, 0, -10, Transition.ColorTint, "", 150, 50, false);
            UILayout.SetSameAnchorAndPivot(useBtn, UILayout.Bottom);
            GUI.ButtonSetTextColor(useBtn, UIDefine.BrownColor);
            GUI.ButtonSetTextFontSize(useBtn, UIDefine.FontSizeL)
            ItemIndex = 2

            if BagUI.tabIndex == 1 then
                local site = LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
                if site~=-1 then
                    local moreBtn = GUI.ButtonCreate(itemTips,"moreBtn",1800402110, 0 , -10, Transition.ColorTint, "", 150, 50, false);
                    _gt.BindName(moreBtn,"moreBtn")
                    UILayout.SetSameAnchorAndPivot(moreBtn, UILayout.Bottom);
                    GUI.SetPositionX(moreBtn,-90)
                    local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","更多",30,0,150,50)
                    UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                    UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                    GUI.RegisterUIEvent(moreBtn, UCE.PointerClick, "BagUI", "OnMoreBtnClick");
                    local Arrow = GUI.ImageCreate(moreBtn,"moreArrow",1800607140,40,15,false,35,20)
                    _gt.BindName(Arrow,"Arrow")
                    GUI.AddWhiteName(itemTips,GUI.GetGuid(moreBtn))

                    GUI.ButtonSetText(useBtn, "装备");
                    UILayout.SetSameAnchorAndPivot(useBtn, UILayout.Bottom);
                    GUI.ButtonSetTextColor(useBtn, UIDefine.BrownColor);
                    GUI.ButtonSetTextFontSize(useBtn, UIDefine.FontSizeL)
                    GUI.SetPositionX(useBtn,90)

                    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnEquipBtnClick");
                    --存下第一件装备的itemdata
                    local itemData_1 = itemData

                    local itemData = LD.GetItemDataByIndex(site, item_container_type.item_container_equip)
                    if itemData ~= nil then
                        --local itemTips2 = Tips.CreateByItemData(itemData, panelBg, "itemTips2", 200, 0)

                        ---------------------------------------------2023.11.17  修改地方Start------------------------------------------------
                        local itemTips2 = Tips.CreateSpecilaItemTips(itemData, panelBg, "itemTips2", 200, 0)
                        --原来的代码
                        --local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips2", 200, 0)
                        ---------------------------------------------2023.11.17  修改地方End------------------------------------------------


                        GUI.AddWhiteName(itemTips2,guid)
                        _gt.BindName(itemTips2,"itemTips2")

                        -- 添加特技特效相关到白名单
                        local itemInfoScr = GUI.GetChildByPath(itemTips,"InfoScr/InfoGroup")
                        local itemInfoScr2 = GUI.GetChildByPath(itemTips2,"InfoScr/InfoGroup")
                        local itemInfoCount = GUI.GetChildCount(itemInfoScr)
                        local itemInfoCount2 = GUI.GetChildCount(itemInfoScr2)
                        for i = 0, itemInfoCount - 1, 1 do
                            local label = GUI.GetChildByIndex(itemInfoScr,i)
                            if GUI.GetData(label,"SpecialEffect") or GUI.GetData(label,"StuntID") then
                                GUI.AddWhiteName(itemTips2,GUI.GetGuid(label))
                            end
                        end
                        for i = 0, itemInfoCount2 - 1, 1 do
                            local label = GUI.GetChildByIndex(itemInfoScr2,i)
                            if GUI.GetData(label,"SpecialEffect") or GUI.GetData(label,"StuntID") then
                                GUI.AddWhiteName(itemTips,GUI.GetGuid(label))
                            end
                        end

                        --调整装备tips的位置
                        local itemTipsX = GUI.GetPositionX(itemTips)
                        local itemTips2X = GUI.GetPositionX(itemTips2)
                        GUI.SetPositionX(itemTips,itemTips2X)
                        GUI.SetPositionX(itemTips2,itemTipsX)

                        if itemTips2 then
                            local t = {}
                            local T = {}
                            LogicDefine.GetItemDynAttrDataByMark(itemData_1, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)
                            LogicDefine.GetItemDynAttrDataByMark(itemData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, T)
                            local InfoScr = GUI.GetChild(itemTips,"InfoScr")
                            if #t > 0 and #T > 0 then
                                for i = 1, #t, 1 do
                                    --获得提升的图片
                                    local attrName = t[i].name
                                    local UpImg = nil
                                    for j = 1, #t, 1 do
                                        local curUpImg = GUI.GetChild(InfoScr,"UpImg"..j)
                                        local label = GUI.GetParentElement(curUpImg)
                                        if string.find(GUI.StaticGetText(label),attrName) then
                                            UpImg = curUpImg
                                        end
                                    end

                                    local attrIndex = 0
                                    for j = 1, #T, 1 do
                                        if t[i].name == T[j].name then
                                            attrIndex = j
                                        end
                                    end
                                    if attrIndex == 0 then
                                        local value = tonumber(tostring(t[i].value))
                                        if value > 0 then
                                            GUI.ImageSetImageID(UpImg,"1800607060")
                                            GUI.SetVisible(UpImg,true)
                                        elseif value < 0 then
                                            GUI.ImageSetImageID(UpImg,"1800607070")
                                            GUI.SetVisible(UpImg,true)
                                        else
                                            GUI.SetVisible(UpImg,false)
                                        end
                                    else
                                        local value1 = tonumber(tostring(t[i].value))
                                        local value2 = tonumber(tostring(T[attrIndex].value))
                                        if value1 > value2 then
                                            GUI.ImageSetImageID(UpImg,"1800607060")
                                            GUI.SetVisible(UpImg,true)
                                        elseif  value1 < value2 then
                                            GUI.ImageSetImageID(UpImg,"1800607070")
                                            GUI.SetVisible(UpImg,true)
                                        elseif value1 == value2 then
                                            GUI.SetVisible(UpImg,false)
                                        end
                                    end
                                end
                            end
                        end
                    else
                        local InfoScr = GUI.GetChild(itemTips,"InfoScr")
                        local t = {}
                        LogicDefine.GetItemDynAttrDataByMark(itemData_1, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)
                        if #t > 0 then
                            for i = 1, #t do
                                --获得提升的图片
                                local attrName = t[i].name
                                local UpImg = nil
                                for j = 1, #t, 1 do
                                    local curUpImg = GUI.GetChild(InfoScr,"UpImg"..j)
                                    local label = GUI.GetParentElement(curUpImg)
                                    if string.find(GUI.StaticGetText(label),attrName) then
                                        UpImg = curUpImg
                                    end
                                end
                                local value = tonumber(tostring(t[i].value))
                                if value > 0 then
                                    GUI.ImageSetImageID(UpImg,"1800607060")
                                    GUI.SetVisible(UpImg,true)
                                elseif value < 0 then
                                    GUI.ImageSetImageID(UpImg,"1800607070")
                                    GUI.SetVisible(UpImg,true)
                                else
                                    GUI.SetVisible(UpImg,false)
                                end
                            end
                        end
                    end
                elseif tonumber(itemDB.Type) == 2 then
                    local moreBtn = GUI.ButtonCreate(itemTips,"moreBtn",1800402110, 0 , -10, Transition.ColorTint, "", 150, 50, false);
                    _gt.BindName(moreBtn,"moreBtn")
                    UILayout.SetSameAnchorAndPivot(moreBtn, UILayout.Bottom);
                    GUI.SetPositionX(moreBtn,-90)

                    -- GUI.AddWhiteName(itemTips,GUI.GetGuid(moreBtn))

                    GUI.ButtonSetText(useBtn, "使用")
                    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnUseBtnClick");
                    GUI.SetPositionX(useBtn,90)
                    if itemDB.ShowType == "制药材料" then
                        local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","炼药",45,0,150,50)
                        UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                        UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                        GUI.RegisterUIEvent(moreBtn, UCE.PointerClick ,"BagUI","OnLianYaoBtnClick")
                    elseif itemDB.ShowType == "烹饪材料" or itemDB.ShowType == "烹饪佐料"  then
                        local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","烹饪",45,0,150,50)
                        UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                        UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                        GUI.RegisterUIEvent(moreBtn, UCE.PointerClick ,"BagUI","OnCookBtnClick")
                        -- 如果是羽翼激活 或 时装激活 修改时间 2021-8-24
                    elseif tonumber(itemDB.Subtype) == 44 or tonumber(itemDB.Subtype) == 45 or tonumber(itemDB.Subtype) == 23 then
                        -- 将使用按钮放中间
                        GUI.SetPositionX(useBtn, 0)
                        -- 将使用全部按钮隐藏
                        GUI.SetVisible(moreBtn, false)
					elseif tonumber(itemDB.Subtype) == 47 or tonumber(itemDB.Subtype) == 48 or tonumber(itemDB.Subtype) == 15 then --坐骑相关
                        -- 将使用按钮放中间
                        GUI.SetPositionX(useBtn, 0)
                        -- 将使用全部按钮隐藏
                        GUI.SetVisible(moreBtn, false)							
                    else
                        if tonumber(itemDB.Subtype) == 42 then
                            local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","兑换",45,0,150,50)
                            UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                            UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                            GUI.RegisterUIEvent(moreBtn, UCE.PointerClick, "BagUI", "OnExchangeBtnClick");
                        else
                            local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","使用全部",25,0,150,50)
                            UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                            UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                            GUI.RegisterUIEvent(moreBtn, UCE.PointerClick, "BagUI", "OnUseAllBtnClick");
                        end
                    end
                elseif tonumber(itemDB.Type) == 1 and tonumber(itemDB.Subtype) == 7 then
                    local moreBtn = GUI.ButtonCreate(itemTips,"moreBtn",1800402110, 0 , -10, Transition.ColorTint, "", 150, 50, false);
                    _gt.BindName(moreBtn,"moreBtn")
                    UILayout.SetSameAnchorAndPivot(moreBtn, UILayout.Bottom);
                    GUI.SetPositionX(moreBtn,-90)

                    local Arrow = GUI.ImageCreate(moreBtn,"moreArrow",1800607140,40,15,false,35,20)
                    _gt.BindName(Arrow,"Arrow")
                    GUI.AddWhiteName(itemTips,GUI.GetGuid(moreBtn))

                    local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","更多",30,0,150,50)
                    UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                    UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                    GUI.RegisterUIEvent(moreBtn, UCE.PointerClick ,"BagUI","OnMoreBtnClick")

                    GUI.ButtonSetText(useBtn, "使用")
                    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnUseBtnClick");
                    GUI.SetPositionX(useBtn,90)
                elseif tonumber(itemDB.Type) == 6 then
                    local moreBtn = GUI.ButtonCreate(itemTips,"moreBtn",1800402110, 0 , -10, Transition.ColorTint, "", 150, 50, false);
                    _gt.BindName(moreBtn,"moreBtn")
                    UILayout.SetSameAnchorAndPivot(moreBtn, UILayout.Bottom);
                    GUI.SetPositionX(moreBtn,-90)

                    local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","上交",45,0,150,50)
                    UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                    UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                    GUI.RegisterUIEvent(moreBtn, UCE.PointerClick ,"BagUI","OnHandInBtnClick")

                    GUI.ButtonSetText(useBtn, "使用")
                    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnUseBtnClick");
                    GUI.SetPositionX(useBtn,90)
                    -- 灵宝五行，灵宝精华
                elseif (tonumber(itemDB.Type) == 3 and tonumber(itemDB.Subtype) == 34) or (tonumber(itemDB.Type) == 3 and tonumber(itemDB.Subtype) == 31) then
                    local moreBtn = GUI.ButtonCreate(itemTips,"moreBtn",1800402110, 0 , -10, Transition.ColorTint, "", 150, 50, false);
                    _gt.BindName(moreBtn,"moreBtn")
                    UILayout.SetSameAnchorAndPivot(moreBtn, UILayout.Bottom);
                    GUI.SetPositionX(moreBtn,-90)

                    local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","分解",45,0,150,50)
                    UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                    UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                    GUI.RegisterUIEvent(moreBtn, UCE.PointerClick ,"BagUI","OnBrkBtnClick")

                    GUI.ButtonSetText(useBtn, "使用")
                    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnUseBtnClick");
                    GUI.SetPositionX(useBtn,90)
                elseif tonumber(itemDB.Type) == 3 and tonumber(itemDB.Subtype) == 9 then
                    local moreBtn = GUI.ButtonCreate(itemTips,"moreBtn",1800402110, 0 , -10, Transition.ColorTint, "", 150, 50, false);
                    _gt.BindName(moreBtn,"moreBtn")
                    UILayout.SetSameAnchorAndPivot(moreBtn, UILayout.Bottom);
                    GUI.SetPositionX(moreBtn,-90)

                    local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","合成",45,0,150,50)
                    UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                    UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                    GUI.RegisterUIEvent(moreBtn, UCE.PointerClick ,"BagUI","OnGamSynthesisBtnClick")

                    GUI.ButtonSetText(useBtn, "镶嵌")
                    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnUseBtnClick");
                    GUI.SetPositionX(useBtn,90)
                elseif tonumber(itemDB.Type) == 3 and tonumber(itemDB.Subtype) == 7 and tonumber(itemDB.Subtype2) == 23 then --强化石
                    GUI.ButtonSetText(useBtn, "使用");
                    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnUseBtnClick");
                    GUI.SetPositionX(useBtn,-85)

                    local moreBtn = GUI.ButtonCreate(itemTips,"moreBtn",1800402110, 0 , -10, Transition.ColorTint, "", 150, 50, false);
                    _gt.BindName(moreBtn,"moreBtn")
                    UILayout.SetSameAnchorAndPivot(moreBtn, UILayout.Bottom);
                    GUI.SetPositionX(moreBtn,85)

                    local moreBtnTxt = GUI.CreateStatic(moreBtn,"moreBtnTxt","合成",50,0,150,50)
                    UILayout.SetSameAnchorAndPivot(moreBtnTxt, UILayout.Bottom)
                    UILayout.StaticSetFontSizeColorAlignment(moreBtnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
                    GUI.RegisterUIEvent(moreBtn, UCE.PointerClick ,"BagUI","OnFossilSynthesisClick")

                else
                    GUI.ButtonSetText(useBtn, "使用");
                    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnUseBtnClick");
                    GUI.SetPositionX(useBtn,0)
                end
            elseif BagUI.tabIndex == 2 then
                GUI.ButtonSetText(useBtn, "移入仓库");
                GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnInWarehouseClick");
            end

        end

    end
end

function BagUI.OnWarehouseItemClick(guid)

    test("仓库物品点击事件")

    local itemIcon = GUI.GetByGuid(guid);
    local index = GUI.ItemCtrlGetIndex(itemIcon)
    local realIndex = (BagUI.warehousePageIndex - 1) * cntPerWarehousePage + index;
    local curBagType = item_container_type.item_container_warehouse_items;

    local itemData = LD.GetItemDataByIndex(realIndex, curBagType);
    -----------------------------------------2021.6.3  新增东西Start------------------------------------
    local itemCustomAttr_Level= LD.GetItemIntCustomAttrByIndex("itemRandomLevel",realIndex,curBagType)
    local tmp_itemCustomData={}
    tmp_itemCustomData.itemRandomLevel=nil
    tmp_itemCustomData.itemRandomLevel=tonumber(itemCustomAttr_Level)
    -----------------------------------------2021.6.3  新增东西End-------------------------------------
    if itemData ~= nil then

        if BagUI.selectedGuid == guid then
            local itemTips = _gt.GetUI("itemTips");
            GUI.Destroy(itemTips);

            BagUI.OnOutWarehouseClick();
            BagUI.CancelSelectedItem();
            return;
        end

        BagUI.CancelSelectedItem();
        BagUI.selectedGuid = guid;
        BagUI.selectedIndex = index;
        GUI.ItemCtrlSelect(itemIcon);

        local panelBg = GUI.GetByGuid(_gt.panelBg);
        --------------------------------增加点击选择刷新右侧背包类型Start----------------------------------

        if isSetNewSeverBag == 0 then

            if BagSelectIndex1 == 2 or BagSelectIndex1 == "2" then
                local itemId = itemData:GetAttr(ItemAttr_Native.Id)
                local itemDB = DB.GetOnceItemByKey1(tonumber(itemId))
                if itemDB.Type == 3 and itemDB.Subtype == 9 then --宝石|
                    BagSelectIndex2 = 2
                elseif itemDB.Type == 6 and itemDB.Subtype == 0 then --信物
                    BagSelectIndex2 = 3
                else
                    BagSelectIndex2 = 1
                end
                BagUI.RefreshSelectTypeBag(BagSelectIndex1,BagSelectIndex2)
            end

        elseif isSetNewSeverBag == 1 then

            local itemId = itemData:GetAttr(ItemAttr_Native.Id)
            local itemDB = DB.GetOnceItemByKey1(tonumber(itemId))

            local bagType = topBagTypeTable[1].name

            if bagTemporarySeverTable[itemDB.Type] ~= nil then

                if bagTemporarySeverTable[itemDB.Type][itemDB.Subtype] ~= nil then

                    if bagTemporarySeverTable[itemDB.Type][itemDB.Subtype][itemDB.Subtype2] ~= nil then

                        if bagTemporarySeverTable[itemDB.Type][itemDB.Subtype][itemDB.Subtype2][1] ~= nil then

                            bagType = bagTemporarySeverTable[itemDB.Type][itemDB.Subtype][itemDB.Subtype2][1]


                        end

                    end

                end

            end

            local index = 1
            local isAllType = false

            for i = 1, #topBagTypeTable do

                if topBagTypeTable[i].allType == true then

                    index = i

                    isAllType = true

                end


            end

            if isAllType == true then

                local BagTypeBtn = _gt.GetUI("BagTypeBtn")
                local BagTypeBtnText = GUI.GetChild(BagTypeBtn,"text",false)
                GUI.StaticSetText(BagTypeBtnText,topBagTypeTable[index].name)

                BagUI.subSeverTabIndex = index

                local topBagTypeLoop = _gt.GetUI("topBagTypeLoop")
                GUI.LoopScrollRectSrollToCell(topBagTypeLoop,BagUI.subSeverTabIndex - 1,2000)


                if BagUI.subSeverTabIndex > #topBagTypeTable - 3 then

                    local rightTag = _gt.GetUI("rightTag")
                    GUI.SetVisible(rightTag,false)


                    local leftTag = _gt.GetUI("leftTag")
                    GUI.SetVisible(leftTag,true)

                elseif BagUI.subSeverTabIndex >= 1 then



                    local rightTag = _gt.GetUI("rightTag")
                    GUI.SetVisible(rightTag,true)


                    local leftTag = _gt.GetUI("leftTag")
                    GUI.SetVisible(leftTag,false)

                end

                --设置顶部包裹类型点击数据
                BagUI.SetTopBagTypeTableClickData()

                --包裹类型Loop刷新
                BagUI.RefreshBagTypeItemScrollData()

            else

                for i = 1, #topBagTypeTable do

                    if bagType == topBagTypeTable[i].name then

                        index = i

                    end

                end

                local BagTypeBtn = _gt.GetUI("BagTypeBtn")
                local BagTypeBtnText = GUI.GetChild(BagTypeBtn,"text",false)
                GUI.StaticSetText(BagTypeBtnText,topBagTypeTable[index].name)

                BagUI.subSeverTabIndex = index

                local topBagTypeLoop = _gt.GetUI("topBagTypeLoop")
                GUI.LoopScrollRectSrollToCell(topBagTypeLoop,BagUI.subSeverTabIndex - 1,2000)


                if BagUI.subSeverTabIndex > #topBagTypeTable - 3 then

                    local rightTag = _gt.GetUI("rightTag")
                    GUI.SetVisible(rightTag,false)


                    local leftTag = _gt.GetUI("leftTag")
                    GUI.SetVisible(leftTag,true)

                elseif BagUI.subSeverTabIndex >= 1 then



                    local rightTag = _gt.GetUI("rightTag")
                    GUI.SetVisible(rightTag,true)


                    local leftTag = _gt.GetUI("leftTag")
                    GUI.SetVisible(leftTag,false)

                end

                --设置顶部包裹类型点击数据
                BagUI.SetTopBagTypeTableClickData()

                --包裹类型Loop刷新
                BagUI.RefreshBagTypeItemScrollData()

            end

        end


        --------------------------------增加点击选择刷新右侧背包类型End----------------------------------

        ---------------------------------------------2021.6.3  修改地方Start------------------------------------------------
        --local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", 200, 0, 55,nil,tmp_itemCustomData);
        --原来的代码
        --local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", -200, 0, 55);
        ---------------------------------------------2021.6.3  修改地方End------------------------------------------------
        
        ---------------------------------------------2023.11.17  修改地方Start------------------------------------------------
        local itemTips = Tips.CreateSpecilaItemTips(itemData, panelBg, "itemTips", -200, 0, 55,nil,tmp_itemCustomData)
        --原来的代码
        --local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", -200, 0, 55,nil,tmp_itemCustomData);
        ---------------------------------------------2023.11.17  修改地方End------------------------------------------------
           
        
        GUI.AddWhiteName(itemTips,guid);
        _gt.BindName(itemTips,"itemTips");

        local useBtn = GUI.ButtonCreate(itemTips, "useBtn", 1800402110, 0, -10, Transition.ColorTint, "移入包裹", 150, 50, false);
        UILayout.SetSameAnchorAndPivot(useBtn, UILayout.Bottom);
        GUI.ButtonSetTextColor(useBtn, UIDefine.BrownColor);
        GUI.ButtonSetTextFontSize(useBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "BagUI", "OnOutWarehouseClick");
    end
end

function BagUI.OnPetItemClick(guid)
    if BagUI.petGuidList.Count==0 then
        return;
    end

    local petItem = GUI.GetByGuid(guid);
    GUI.CheckBoxExSetCheck(petItem, false);
    local index = GUI.CheckBoxExGetIndex(petItem);
    local petGuid = BagUI.petGuidList[index];
    if petGuid~=nil then
        --判读仓库是否已满，已满，弹出购买购买仓库
        local petCnt = LD.GetPetCount(pet_container_type.pet_container_warehouse_pets)
        local petCapacity = LD.GetPetCapacity(pet_container_type.pet_container_warehouse_pets)
        test("petCnt="..petCnt..",petCapacity="..petCapacity)
        if petCnt >= petCapacity then
            test("弹出购买宠物仓库")
            CL.SendNotify(NOTIFY.ShowBBMsg, "仓库已满")
            CL.SendNotify(NOTIFY.SubmitForm, "FormBaseFunction", "UnlockPetDepotField")
            return
        end
        test("移入宠物到仓库")
        local dst = System.Enum.ToInt(pet_container_type.pet_container_warehouse_pets);
        CL.SendNotify(NOTIFY.MovePet, petGuid, dst);
    end
end

function BagUI.OnWarehousePetItemClick(guid)
    if BagUI.warehousePetGuidList.Count==0 then
        return;
    end

    local petItem = GUI.GetByGuid(guid);
    GUI.CheckBoxExSetCheck(petItem, false);
    local index = GUI.CheckBoxExGetIndex(petItem);
    local realIndex =index;
    local petGuid = BagUI.warehousePetGuidList[realIndex];
    if petGuid~=nil then
        local dst = System.Enum.ToInt(pet_container_type.pet_container_panel);
        CL.SendNotify(NOTIFY.MovePet, petGuid, dst);
    end

end

function BagUI.OnEquipBtnClick()
    local bagType = BagUI.GetCurBagType();
    if isSetNewSeverBag == 1 then


    end
    local guid = LD.GetItemGuidByIndex(BagUI.selectedIndex, bagType);
    local dst = System.Enum.ToInt(item_container_type.item_container_equip);
    --CL.SendNotify(NOTIFY.MoveItem, guid, dst);
    GlobalProcessing.PutOnEquip(guid, dst)
end

function BagUI.OnRemoveEquipBtnClick()

    local guid = LD.GetItemGuidByIndex(BagUI.selectedIndex, item_container_type.item_container_equip);
    local dst = System.Enum.ToInt(item_container_type.item_container_bag);
    CL.SendNotify(NOTIFY.MoveItem, guid, dst);
end

function BagUI.OnUseBtnClick(itemId)
    local bagType = BagUI.GetCurBagType();
    local guid = LD.GetItemGuidByIndex(BagUI.selectedIndex, bagType);
    --如果是信物  点击信物跳转至侍从界面，并显示相对应的侍从
    --if  bagType==item_container_type.item_container_guard_bag then
    --local itemData=LD.GetItemDataByIndex(BagUI.selectedIndex,bagType)
    --test(itemData.id)
    --GUI.OpenWnd("GuardUI")
    --GuardUI.FragmentItemIdChangeToGuardId(itemData.id)
    --else
    --end
    GlobalUtils.UseItem(guid)

end

function BagUI.OnUseAllBtnClick()
    local bagType = BagUI.GetCurBagType();
    local guid = LD.GetItemGuidByIndex(BagUI.selectedIndex, bagType);
    GlobalUtils.UseAllItem(guid)
end

function BagUI.OnBrkBtnClick()  -- 打开灵宝分解页面
    local bagType = BagUI.GetCurBagType();
    local guid = LD.GetItemGuidByIndex(BagUI.selectedIndex, bagType);
    GetWay.Def[1].jump("SpiritualEquipBrkUI", "2", guid)
end

function BagUI.OnInWarehouseClick()
    local curCount = LD.GetItemCount(item_container_type.item_container_warehouse_items);
    local capacity=LD.GetBagCapacity(item_container_type.item_container_warehouse_items)
    --test("capaity="..tostring(capacity)..",curCount="..tostring(curCount))
    local pageCount =math.floor(capacity/cntPerWarehousePage)
    --test("PageCount="..tostring(pageCount))
    local itemInPage = math.floor(curCount/cntPerWarehousePage)+1
    --test("itemInPage:"..itemInPage)
    --查看仓库itemInPage是否解锁。，已解锁，跳转到对应页。 未解锁，弹出购买仓库
    local bagType = BagUI.GetCurBagType();
    local guid = LD.GetItemGuidByIndex(BagUI.selectedIndex, bagType);

    if itemInPage > pageCount then
        -- test("弹出购买道具仓库")
        --CL.SendNotify(NOTIFY.ShowBBMsg, "仓库已满")
        -- 仓库格子已满时，查看选中物品的堆叠情况，判断是否需要解锁道具
        local isNeedUnlook = true
        local itemData = LD.GetItemDataByGuid(guid,bagType)
        local itemDB = DB.GetOnceItemByKey1(itemData.id)
        local StackMax = itemDB.StackMax
        local item_GUIDList_Warehouse = LD.GetItemGuidsById(itemData.id,item_container_type.item_container_warehouse_items)
        if item_GUIDList_Warehouse and item_GUIDList_Warehouse.Count ~= 0 then
            local selectedCount = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,itemData.guid,bagType))
            local selectedIsBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,itemData.guid,bagType) == "1"
            for i = 0, item_GUIDList_Warehouse.Count - 1 do
                local guid = item_GUIDList_Warehouse[i]
                local Count = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,guid,item_container_type.item_container_warehouse_items))
                local isBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,guid,item_container_type.item_container_warehouse_items) == "1"
                if (selectedIsBind == isBind) and Count < StackMax then
                    selectedCount = selectedCount - (StackMax - Count)
                end
            end
            if selectedCount <= 0 then
                isNeedUnlook = false
            end
        end
        -- 是否
        if isNeedUnlook then
            CL.SendNotify(NOTIFY.SubmitForm, "FormBaseFunction", "UnlockDepotField")
            -- return
        end
    end
    local dst = System.Enum.ToInt(item_container_type.item_container_warehouse_items);
    test("bagType="..tostring(bagType)..",guid="..tostring(guid)..",dst="..tostring(dst))
    --BagUI.TempMoveItemGuid = guid
    test("移入道具仓库")
    if GlobalProcessing.WarehouseClassify_Switch and GlobalProcessing.WarehouseClassify_Switch == 'on' then
        CL.SendNotify(NOTIFY.SubmitForm, "FormWarehouseClassify", "ItemMoveIn", guid, cntPerWarehousePage, BagUI.warehousePageIndex)
    else
        CL.SendNotify(NOTIFY.MoveItem, guid, dst);
    end
end

function BagUI.OnOutWarehouseClick()
    --移出仓库
    local bagType = item_container_type.item_container_warehouse_items;
    local index = (BagUI.warehousePageIndex - 1) * cntPerWarehousePage + BagUI.selectedIndex;
    local guid = LD.GetItemGuidByIndex(index, bagType);
    local curBagType = BagUI.GetCurBagType();
    --移出背包类型移出到不同的包裹栏（道具，宝石，碎片）
    --local dst = System.Enum.ToInt(item_container_type.item_container_bag);
    local dst = System.Enum.ToInt(curBagType);
    CL.SendNotify(NOTIFY.MoveItem, guid, dst);
end

function BagUI.OnTipsClicked()
    BagUI.CancelSelectedItem();
end

function BagUI.CancelSelectedItem()
    if BagUI.selectedGuid ~= nil then
        GUI.ItemCtrlUnSelect(GUI.GetByGuid(BagUI.selectedGuid));
        BagUI.selectedGuid = nil;
    end
end

function BagUI.OnBagBtnClick()
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[1][1])
    local Level = MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        BagUI.tabIndex = 1;
        BagUI.OnItemSubTabBtnClick();
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
        UILayout.OnTabClick(BagUI.tabIndex, tabList)
        return
    end
end

function BagUI.OnWarehouseTabBtnClick()
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[2][1])
    local Level = MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        BagUI.tabIndex = 2;
        BagUI.warehouseType = 1;
        BagUI.warehousePageIndex=1;

        local itemScroll = GUI.GetByGuid(_gt.itemScroll);
        GUI.ScrollRectSetNormalizedPosition(itemScroll, Vector2.New(0, 0));

        BagUI.Refresh();
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
        UILayout.OnTabClick(BagUI.tabIndex, tabList)
        return
    end

end

function BagUI.OnItemSubTabBtnClick()

    BagUI.subTabIndex = 1;

    BagUI.Refresh();

    local itemScroll = GUI.GetByGuid(_gt.itemScroll);
    GUI.ScrollRectSetNormalizedPosition(itemScroll, Vector2.New(0, 0));
end

function BagUI.OnGemSubTabBtnClick()
    BagUI.subTabIndex = 2;
    if MainUI.GemRedPointFlag then
        MainUI.GemRedPointFlag = false
        BagUI.ShowGemTabRedPoint(false)
        GlobalProcessing.RedPointController('bagBtn', 'add_new_item_gem', 0)
    end
    BagUI.Refresh();

    local itemScroll = GUI.GetByGuid(_gt.itemScroll);
    GUI.ScrollRectSetNormalizedPosition(itemScroll, Vector2.New(0, 0));
end

function BagUI.OnTokenSubTabBtnClick()
    BagUI.subTabIndex = 3;
    if MainUI.GuardRedPointFlag then
        MainUI.GuardRedPointFlag = false
        BagUI.ShowGuardTabRedPoint(false)
        GlobalProcessing.RedPointController('bagBtn', 'add_new_item_guard', 0)
    end
    BagUI.Refresh();

    local itemScroll = GUI.GetByGuid(_gt.itemScroll);
    GUI.ScrollRectSetNormalizedPosition(itemScroll, Vector2.New(0, 0));
end

--点击仓库类型按钮，切换道具仓库和宠物仓库
function BagUI.OnWarehouseTypeBtnClick()
    if BagUI.warehouseType ~= 4 then
        BagUI.warehouseType = 4;
    elseif BagUI.warehouseType == 4 then
        BagUI.warehouseType = 1;
    end

    BagUI.Refresh();
end

--点击背包类型按钮，切换道具背包，宝石背包和信物背包
function BagUI.OnBagTypeBtnClick(guid)
    local BagTypeCover = GUI.GetByGuid(_gt.BagTypeCover);
    GUI.SetVisible(BagTypeCover,true)

    local BagSelectBorder = GUI.GetChild(BagTypeCover,"BagSelectBorder",false);
    local BagTypeScr = GUI.GetChild(BagSelectBorder,"BagTypeScr",false)

    local temp = {}

    if isSetNewSeverBag == 0 then

        temp = subTabList

    elseif isSetNewSeverBag == 1 then

        temp = topBagTypeTable
    end

    local height = 0

    if #temp > 4 then

        height = 40

    end

    if height > 0 then

        GUI.SetHeight(BagSelectBorder,height * #temp - 40)
        GUI.SetHeight(BagTypeScr,(height - 4) * #temp - 40)

    end


    for i = 1, #temp do
        local BagTypeBtn = GUI.GetChild(BagTypeScr,"BagTypeBtn"..i)

        if BagTypeBtn == nil then
            BagTypeBtn = GUI.ButtonCreate(BagTypeScr, "BagTypeBtn" .. i, "1801102010", 0, 0, Transition.ColorTint, "", 175, 40, false);
            GUI.ButtonSetTextColor(BagTypeBtn, UIDefine.BrownColor);
            GUI.ButtonSetTextFontSize(BagTypeBtn, UIDefine.FontSizeM);
            GUI.SetData(BagTypeBtn, "Index", i)
            if isSetNewSeverBag == 0 then

                GUI.ButtonSetText(BagTypeBtn,subTabList[i][1])

            elseif isSetNewSeverBag == 1 then

                GUI.ButtonSetText(BagTypeBtn,topBagTypeTable[i].name)

            end

            GUI.RegisterUIEvent(BagTypeBtn, UCE.PointerClick, "BagUI", "OnBagTypeBtnSelectClick")

        else

            if isSetNewSeverBag == 0 then

                GUI.ButtonSetText(BagTypeBtn,subTabList[i][1])

            elseif isSetNewSeverBag == 1 then

                GUI.ButtonSetText(BagTypeBtn,topBagTypeTable[i].name)

            end
            GUI.SetData(BagTypeBtn, "Index", i)

        end

    end

end

function BagUI.RewardBtnValueRefresh()
    local gemRewardBtn_value = _gt.GetUI("gemRewardBtn_value")
    if gemRewardBtn_value then
        GUI.StaticSetText(gemRewardBtn_value, tostring(CL.GetIntCustomData("attribute_gem_index")))
    end
    local enhanceRewardBtn_value = _gt.GetUI("enhanceRewardBtn_value")
    if enhanceRewardBtn_value then
        GUI.StaticSetText(enhanceRewardBtn_value, tostring(CL.GetIntCustomData("attribute_equip_index")))
    end
end

-------------------------------------------------start 时装 start -----------------------------------------------------
-- 发送请求
function BagUI.FashionRequest()
    -- FormClothes.GetClothesData(player)
    CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","GetClothesData")
    -- 执行 BagUI.RefreshFashionPage()回调函数  传入数据BagUI.FashionClothesItems={[1]={Id,Time}} 为BagUI.Fashion_CurrentDress_Id赋值
end
-- 数据整理函数
-- 排序函数
local sex = nil
local sortFun = function(a, b)
    if a.Sex == sex and b.Sex ~= sex then
        return true
    elseif a.Sex ~= sex and b.Sex == sex then
        return false
    else
        return a.Index < b.Index
    end
end
BagUI.foreverClothes = nil  -- 永久时装表
local sortFashionData = function()
    -- 将永久的时装从表中拿出来
    BagUI.foreverClothes = {}

    local allClothesId = DB.GetIllusionAllKey1s()
    for i=0,allClothesId.Count-1 do
        local clothes = DB.GetOnceIllusionByKey1(allClothesId[i])
        if clothes.Time == 0 and (clothes.Type == 0 or clothes.Type == 1) then
            table.insert(BagUI.foreverClothes,clothes)
        end
    end
    sex = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole )).Sex -- 当前角色性别
    -- 获取当前角色性别，将符合角色性别的排在前面
    table.sort(BagUI.foreverClothes,sortFun)
    --local inspect = require("inspect")
    --CDebug.LogError(inspect(BagUI.foreverClothes))
    -- 插入其数量
    BagUI.foreverClothes["Count"] = #BagUI.foreverClothes

end
-- 时装tab点击事件
function BagUI.OnFashionTabBtnClick()
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[3][1])
    local Level = MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        BagUI.tabIndex = 3 -- 设置时装一级下标页签
        sortFashionData()

        BagUI.Refresh() -- 通过请求的回调函数执行
        --BagUI.FashionRequest() -- 发送请求
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
        UILayout.OnTabClick(BagUI.tabIndex, tabList)
        return
    end

end

-- 创建时装物品框节点的函数
function BagUI.Create_FashionClothesIconPool()
    local FashionClothesScroll = _gt.GetUI("FashionClothesScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(FashionClothesScroll);
    local FashionIcon = ItemIcon.Create(FashionClothesScroll, "FashionIcon"..curCount, 0, 0)

    return FashionIcon;
end
-- 刷新时装物品节点的函数
function BagUI.Refresh_FashionClothesScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local itemIcon = GUI.GetByGuid(guid);

    -- 添加事件
    if BagUI.FashionSubTabIndex == 2 and   BagUI.foreverClothes and BagUI.foreverClothes.Count -1 >= index  then
        GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "BagUI", "OnFashionItemClick");
    end

    if BagUI.FashionSubTabIndex == 1 then
        GUI.UnRegisterUIEvent(itemIcon, UCE.PointerClick, "BagUI", "OnFashionItemClick")
        if BagUI.FashionClothesItems and #BagUI.FashionClothesItems >= index then -- 这里省略-1，因为有未穿戴时装，所有事件数量需要+1,而index从0开始需-1，中和了
            GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "BagUI", "OnFashionItemClick");
        end
    end

    -- 隐藏格子内 内容
    BagUI.HideClothesItem(itemIcon)

    -- 如果是时装页面 则填入时装页面的数据
    if BagUI.tabIndex == 3 then
        if BagUI.FashionClothesItems == nil or   next(BagUI.foreverClothes) == nil then -- 如果没有获取到服务器数据
            return
        end
        -- 消除右下角数字
        --local RightBottomNum = GUI.GetChild(itemIcon,"RightBottomNum")
        --if RightBottomNum then
        --    GUI.SetVisible(RightBottomNum,false)
        --end

        local item = nil
        if BagUI.FashionSubTabIndex == 2 then -- 如果是图鉴页面
            item = BagUI.foreverClothes[index+1]
            if item then GUI.SetData(itemIcon,"index",index+1) else
                GUI.SetData(itemIcon,"index",0)
            end

            if item then -- 如果数据存在
                local fashionClothes = item

                local isForever = false -- 玩家是否用于此节点的时装，并且是永久的
                for k,v in ipairs(BagUI.FashionClothesItems) do
                    if fashionClothes.Id == v.Id and v.Time == -1 then
                        isForever =true
                    end
                end


                -- 插入图片
                GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,tostring(fashionClothes.Icon))
                -- 插入品质框
                GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400320")
                -- 插入性别不符红色框
                -- 获取当前角色的性别
                local sex = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole )).Sex
                if sex ~= fashionClothes.Sex then
                    local notSexConform = GUI.GetChild(itemIcon,"notSexConform")
                    if notSexConform then GUI.SetVisible(notSexConform,true) else
                        local notSexConform = GUI.ImageCreate(itemIcon,"notSexConform","1801300230",0,0)
                        SetAnchorAndPivot(notSexConform,UIAnchor.Center,UIAroundPivot.Center)
                    end
                    -- 恢复默认品质
                    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400330")
                else
                    local notSexConform = GUI.GetChild(itemIcon,"notSexConform")
                    if notSexConform then GUI.SetVisible(notSexConform,false) end
                end
                -- 插入选择框
                local selectedBox = GUI.GetChild(itemIcon,"selectedBox")
                if selectedBox then GUI.SetVisible(selectedBox,(index+1) == BagUI.Fashion_SelectedClothes_Index) else
                    selectedBox = GUI.ImageCreate(itemIcon,"selectedBox","1800400280",0,0)
                    SetAnchorAndPivot(selectedBox,UIAnchor.Center,UIAroundPivot.Center)
                    GUI.SetVisible(selectedBox,(index+1) == BagUI.Fashion_SelectedClothes_Index)
                end
                -- 插入锁图片
                -- 如果不是永久的衣服
                if  not isForever then
                    local lock = GUI.GetChild(itemIcon,"lock")
                    if lock then GUI.SetVisible(lock,true) else
                        lock = GUI.ImageCreate(itemIcon,"lock","1800400070",0,0, false, 65, 66)
                        SetAnchorAndPivot(lock,UIAnchor.Center,UIAroundPivot.Center)
                    end
                    -- 添加灰色阴影
                    GUI.ItemCtrlSetIconGray(itemIcon, true)
                else
                    local lock = GUI.GetChild(itemIcon,"lock")
                    if lock then GUI.SetVisible(lock,false) end
                    -- 删除灰色阴影
                    GUI.ItemCtrlSetIconGray(itemIcon, false)
                end
                -- 插入已装备时装图片
                if BagUI.Fashion_CurrentDress_Id and BagUI.Fashion_CurrentDress_Id == item.Id and  isForever then
                    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,"1801207010")
                    local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                    GUI.SetVisible(alreadyEquipped,true)
                else
                    local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                    if alreadyEquipped then
                        GUI.SetVisible(alreadyEquipped,false)
                    end
                end
                -- 插入男女符号
                if fashionClothes.Sex == 1 then -- 男
                    local sexFlag = GUI.GetChild(itemIcon,"sexFlag")
                    if sexFlag then
                        GUI.SetVisible(sexFlag,true)
                        GUI.ImageSetImageID(sexFlag,"1801307180")
                    else
                        sexFlag = GUI.ImageCreate(itemIcon,"sexFlag","1801307180",-5,-5)
                        SetAnchorAndPivot(sexFlag,UIAnchor.BottomRight,UIAroundPivot.BottomRight)
                    end
                elseif fashionClothes.Sex == 2 then -- 女
                    local sexFlag = GUI.GetChild(itemIcon,"sexFlag")
                    if sexFlag then
                        GUI.SetVisible(sexFlag,true)
                        GUI.ImageSetImageID(sexFlag,"1801307170")
                    else
                        sexFlag = GUI.ImageCreate(itemIcon,"sexFlag","1801307170",-5,-5)
                        SetAnchorAndPivot(sexFlag,UIAnchor.BottomRight,UIAroundPivot.BottomRight)
                    end
                end


            end
        elseif BagUI.FashionSubTabIndex == 1 then
            item = BagUI.FashionClothesItems[index]
            if item then
                GUI.SetData(itemIcon,"index",index)
            else
                GUI.SetData(itemIcon,"index",0) -- 如果是无时装时
            end
            if index == 0  then -- 空时装 默认
                -- 插入图片
                GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,"1901000080")
                -- 插入穿戴图片
                GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,"1801207010")
                local leftIcon = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                GUI.SetVisible(leftIcon,false) -- 隐藏穿戴图片
                -- 插入选择框
                local selectedBox = GUI.GetChild(itemIcon,"selectedBox")
                if selectedBox then GUI.SetVisible(selectedBox,(index) == BagUI.Fashion_SelectedClothes_Index) else
                    selectedBox = GUI.ImageCreate(itemIcon,"selectedBox","1800400280",0,0)
                    SetAnchorAndPivot(selectedBox,UIAnchor.Center,UIAroundPivot.Center)
                    GUI.SetVisible(selectedBox,(index) == BagUI.Fashion_SelectedClothes_Index)
                end
                -- 插入品质背景
                GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400320")
                -- 插入圈中带斜杠图片
                --local circle = GUI.ImageCreate(itemIcon,"circle","",0,0)
                --SetAnchorAndPivot(selectedBox,UIAnchor.Center,UIAroundPivot.Center)
                -- 插入已装备时装图片
                if BagUI.Fashion_CurrentDress_Id and BagUI.Fashion_CurrentDress_Id == 0 then
                    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,"1801207010")
                    local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                    GUI.SetVisible(alreadyEquipped,true)
                else
                    local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                    if alreadyEquipped then
                        GUI.SetVisible(alreadyEquipped,false)
                    end
                end
            else
                -- 判断是否 拥有,拥有才显示,如果不是永久的就不加背景加右上的闹钟图标
                if item and item.Time ~= 0 then
                    local fashionClothes = DB.GetOnceIllusionByKey1(item.Id)   --UIDefine.IllusionTable_Id[item.Id]
                    -- 插入图片
                    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,tostring(fashionClothes.Icon))
                    -- 插入已装备时装图片
                    if BagUI.Fashion_CurrentDress_Id and BagUI.Fashion_CurrentDress_Id == item.Id and  item.Time ~= 0  then
                        GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,"1801207010")
                        local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                        GUI.SetVisible(alreadyEquipped,true)
                    else
                        local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
                        if alreadyEquipped then
                            GUI.SetVisible(alreadyEquipped,false)
                        end
                    end
                    -- 插入男女符号
                    if fashionClothes.Sex == 1 then -- 男
                        local sexFlag = GUI.GetChild(itemIcon,"sexFlag")
                        if sexFlag then
                            GUI.SetVisible(sexFlag,true)
                            GUI.ImageSetImageID(sexFlag,"1801307180")
                        else
                            local sexFlag = GUI.ImageCreate(itemIcon,"sexFlag","1801307180",-5,-5)
                            SetAnchorAndPivot(sexFlag,UIAnchor.BottomRight,UIAroundPivot.BottomRight)
                        end
                    elseif fashionClothes.Sex == 2 then -- 女
                        local sexFlag = GUI.GetChild(itemIcon,"sexFlag")
                        if sexFlag then
                            GUI.SetVisible(sexFlag,true)
                            GUI.ImageSetImageID(sexFlag,"1801307170")
                        else
                            local sexFlag = GUI.ImageCreate(itemIcon,"sexFlag","1801307170",-5,-5)
                            SetAnchorAndPivot(sexFlag,UIAnchor.BottomRight,UIAroundPivot.BottomRight)
                        end
                    end
                    -- 插入选择框
                    local selectedBox = GUI.GetChild(itemIcon,"selectedBox")
                    if selectedBox then GUI.SetVisible(selectedBox,(index) == BagUI.Fashion_SelectedClothes_Index) else
                        selectedBox = GUI.ImageCreate(itemIcon,"selectedBox","1800400280",0,0)
                        SetAnchorAndPivot(selectedBox,UIAnchor.Center,UIAroundPivot.Center)
                        GUI.SetVisible(selectedBox,(index) == BagUI.Fashion_SelectedClothes_Index)
                    end

                    if item.Time ~= -1 then -- 如果不是永久
                        -- 插入右上的闹钟图标
                        local clock = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.RightTopSp)
                        if clock then
                            GUI.SetVisible(clock,true)
                        else
                            GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.RightTopSp,"1800408530")
                            GUI.ItemCtrlSetElementRect(itemIcon,eItemIconElement.RightTopSp,8,7)
                        end
                    else
                        -- 插入背景
                        GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400320")
                    end
                end
            end

        end
        --return
    end

end
-- 隐藏物品框内所有图像
function BagUI.HideClothesItem(itemIcon)

    -- 插入图片
    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,"1800499999")
    -- 插入品质框
    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,"1800400330")
    -- 插入选择框
    local selectedBox = GUI.GetChild(itemIcon,"selectedBox")
    if selectedBox then GUI.SetVisible(selectedBox,false) end
    -- 插入锁图片
    local lock = GUI.GetChild(itemIcon,"lock")
    if lock then GUI.SetVisible(lock,false) end

    -- 关闭灰色阴影
    GUI.ItemCtrlSetIconGray(itemIcon, false)

    -- 插入已装备时装图片
    local alreadyEquipped = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.LeftTopSp)
    if alreadyEquipped then GUI.SetVisible(alreadyEquipped,false) end
    -- 插入男女符号
    local sexFlag = GUI.GetChild(itemIcon,"sexFlag")
    if sexFlag then GUI.SetVisible(sexFlag,false) end
    -- 插入性别不符红色框
    local notSexConform = GUI.GetChild(itemIcon,"notSexConform")
    if notSexConform then GUI.SetVisible(notSexConform,false) end
    -- 隐藏时钟
    local clock = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.RightTopSp)
    if clock then GUI.SetVisible(clock,false) end
end

-- 二级页签列表
local fashionSubTabList = {
    { "拥有", "HaveFashionSubTabBtn", "1800402030", "1800402032", "OnHaveFashionSubTabBtnClick", 134, -256, 259, 40, 100, 35 },
    { "图鉴", "pictorial_BookSubTabBtn", "1800402030", "1800402032", "OnPictorial_BookSubTabBtnClick", 394, -256, 259, 40, 100, 35 },
}
local colorwrite = Color.New(1, 1, 1, 1);
local coloroutline = Color.New(162 / 255.0, 75 / 225.0, 21 / 255.0, 1)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local yellowTextColor = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255)
local greenTextColor = Color.New(129 / 255, 60 / 255, 176 / 255, 255 / 255)

-- 创建时装静态页面
function BagUI.CreateFashionPage()
    local wnd = GUI.GetWnd("BagUI")
    local panelBg = GUI.GetByGuid(_gt.panelBg);
    local FashionPage = GUI.GroupCreate(panelBg, "FashionPage", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd)); -- 时装父类
    _gt.BindName(FashionPage,"FashionPage")

    UILayout.CreateSubTab(fashionSubTabList, FashionPage, "BagUI"); -- 创建二级页签

    -- 创建左边页面

    -- 龙背景
    local dragon = GUI.ImageCreate( FashionPage, "dragon", "1800400230", -252.71, -115.8, false);
    SetAnchorAndPivot(dragon, UIAnchor.Center, UIAroundPivot.Center)

    -- 创建左边模型
    local shadow = GUI.ImageCreate(dragon, "shadow", "1800400240", 0, 110); -- 父类

    local model = GUI.RawImageCreate(shadow, false, "model", "", -33, -120, 3,false,520,520)
    model:RegisterEvent(UCE.Drag)
    model:RegisterEvent(UCE.PointerClick)
    GUI.AddToCamera(model);
    GUI.RawImageSetCameraConfig(model, "(0.15,1.55,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,5,0.01,1.45,1E-05");

    local roleModel = GUI.RawImageChildCreate(model, false, "roleModel", "", 0, 0)
    _gt.BindName(roleModel, "FashionPage_roleModel");
    GUI.BindPrefabWithChild(model, GUI.GetGuid(roleModel));
    ModelItem.BindSelfRole(roleModel,eRoleMovement.STAND_W1)

    -- 文本背景
    local upClothDesBg = GUI.ImageCreate( dragon, "upClothDesBg", "1801200030", 0, 157.9, false);
    SetAnchorAndPivot(dragon, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(upClothDesBg,"upClothDesBg")
    --GUI.SetDepth(GUI.ImageCreate( dragon), "shadow", "1800400240", 0, 114.88, 0);

    local HasPageClothNameText = GUI.CreateStatic( upClothDesBg, "HasPageClothNameText", "未穿戴时装", -5, 0, 473.1, 73.8, "system", true, false);
    GUI.StaticSetFontSize(HasPageClothNameText, 24)
    GUI.StaticSetAlignment(HasPageClothNameText, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(HasPageClothNameText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(HasPageClothNameText, colorDark);
    _gt.BindName(HasPageClothNameText,"HasPageClothNameText")

    -- 文本背景
    local buttonClothDesBg = GUI.ImageCreate( dragon, "buttonClothDesBg", "1801200030", 0, 287.6, false, 539.6, 192.5);
    SetAnchorAndPivot(dragon, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(buttonClothDesBg,"buttonClothDesBg")

    local labelTxt1 = GUI.CreateStatic( buttonClothDesBg, "DesTxtlabal", "描述", -212, -70, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt1, 22);
    GUI.StaticSetAlignment(labelTxt1, TextAnchor.MiddleCenter);
    GUI.SetColor(labelTxt1, colorDark);

    local labelTxt2 = GUI.CreateStatic( buttonClothDesBg, "DesTxtlabal2", "附加属性", -191.4, 13, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt2, 22);
    GUI.StaticSetAlignment(labelTxt2, TextAnchor.MiddleCenter);
    GUI.SetColor(labelTxt2, colorDark);

    local labelTxt3 = GUI.CreateStatic( buttonClothDesBg, "DesTxtContent", "时间领主的服装，可以减缓时间的流失", -1, -13, 454, 73.4, "system", true, false);
    SetAnchorAndPivot(labelTxt3, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt3, 20);
    GUI.StaticSetAlignment(labelTxt3, TextAnchor.UpperLeft);
    GUI.SetColor(labelTxt3, yellowTextColor);
    _gt.BindName(labelTxt3,"DesTxtContent")

    local labelTxt4 = GUI.CreateStatic( buttonClothDesBg, "EmptyDesTxt", "无", -213, 47.6, 100, 40, "system", true, false);
    SetAnchorAndPivot(labelTxt4, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(labelTxt4, 20);
    GUI.StaticSetAlignment(labelTxt4, TextAnchor.MiddleCenter);
    GUI.SetColor(labelTxt4, colorDark);


    local AttrTxt1 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt1", "物攻+30", -152, 57.8, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt1, 20);
    GUI.StaticSetAlignment(AttrTxt1, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt1, greenTextColor);

    local AttrTxt2 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt2", "法攻+30", 18, 57.8, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt2, 20);
    GUI.StaticSetAlignment(AttrTxt2, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt2, greenTextColor);

    local AttrTxt3 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt3", "抗封印+60", 182, 57.8, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt3, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt3, 20);
    GUI.StaticSetAlignment(AttrTxt3, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt3, greenTextColor);

    local AttrTxt4 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt4", "抗封印+60", -152, 85.4, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt4, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt4, 20);
    GUI.StaticSetAlignment(AttrTxt4, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt4, greenTextColor);

    local AttrTxt5 = GUI.CreateStatic( buttonClothDesBg, "AttrTxt5", "抗封印+60", 18, 85.4, 149, 49, "system", true, false);
    SetAnchorAndPivot(AttrTxt5, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(AttrTxt5, 20);
    GUI.StaticSetAlignment(AttrTxt5, TextAnchor.UpperLeft);
    GUI.SetColor(AttrTxt5, greenTextColor);

    -- I图标
    local addPointTipBtn = GUI.ButtonCreate( buttonClothDesBg, "addPointTipBtn", "1800702030", -44.5, -331.8, Transition.ColorTint, "")
    SetAnchorAndPivot(addPointTipBtn, UIAnchor.TopRight, UIAroundPivot.Center)
    GUI.RegisterUIEvent(addPointTipBtn, UCE.PointerClick, "BagUI", "OnClothTipBtnClick")

    -- 时间选择按钮
    local moreCLothBtn = GUI.ButtonCreate( dragon, "moreCLothBtn", "1801202030", -5.2, 162.79, Transition.ColorTint, "",277, 44, false);
    GUI.RegisterUIEvent(moreCLothBtn, UCE.PointerClick, "BagUI", "OnClothHBMoreBtnClick")
    _gt.BindName(moreCLothBtn,"moreCLothBtn")

    -- 时间选择按钮上的文本
    local moreCLothNameText = GUI.CreateStatic( moreCLothBtn, "moreCLothNameText", "时间领主（7天）", -15.8, 0, 264.3, 50, "system", true, false);
    GUI.StaticSetFontSize(moreCLothNameText, 24)
    GUI.SetColor(moreCLothNameText, colorDark);
    GUI.StaticSetAlignment(moreCLothNameText, TextAnchor.MiddleCenter)
    _gt.BindName(moreCLothNameText,"moreCLothNameText")

    -- 时间选择按钮旁边按钮
    local toMallBtn = GUI.ButtonCreate( dragon, "toMallBtn", "1800402110", 195.8, 162.79, Transition.ColorTint, "购买",100, 45, false);
    GUI.ButtonSetTextFontSize(toMallBtn, 24);
    GUI.ButtonSetTextColor(toMallBtn, colorDark);
    GUI.RegisterUIEvent(toMallBtn, UCE.PointerClick, "BagUI", "OnClothHBToMallBtnClick")
    _gt.BindName(toMallBtn,"toMallBtn")


    -- 创建右边界面

    -- 时装物品栏
    local FashionClothesScroll = GUI.LoopScrollRectCreate(FashionPage, "FashionClothesScroll", 265, 0, 490, 450,
            "BagUI", "Create_FashionClothesIconPool", "BagUI", "Refresh_FashionClothesScroll", 0, false, Vector2.New(80, 80), cntPerLine, UIAroundPivot.Top, UIAnchor.Top);
    GUI.ScrollRectSetChildSpacing(FashionClothesScroll, Vector2.New(1, 1));
    _gt.BindName(FashionClothesScroll, "FashionClothesScroll");

    local wearClothBtn = GUI.ButtonCreate( FashionPage, "wearClothBtn", "1800402080", 451.8, 268, Transition.ColorTint, "穿戴", 140.2, 47, false);
    GUI.SetIsOutLine(wearClothBtn, true);
    GUI.ButtonSetTextFontSize(wearClothBtn, 26);
    GUI.ButtonSetTextColor(wearClothBtn, colorwrite);
    GUI.SetOutLine_Color(wearClothBtn, coloroutline);
    GUI.SetOutLine_Distance(wearClothBtn, 1);
    GUI.RegisterUIEvent(wearClothBtn, UCE.PointerClick, "BagUI", "OnWearClothBtnClick");

    local unlockClothBtn = GUI.ButtonCreate( FashionPage, "unlockClothBtn", "1800402080", 451.8, 268, Transition.ColorTint, "获取", 140.2, 47, false);
    GUI.SetIsOutLine(unlockClothBtn, true);
    GUI.ButtonSetTextFontSize(unlockClothBtn, 26);
    GUI.ButtonSetTextColor(unlockClothBtn, colorwrite);
    GUI.SetOutLine_Color(unlockClothBtn, coloroutline);
    GUI.SetOutLine_Distance(unlockClothBtn, 1);
    GUI.RegisterUIEvent(unlockClothBtn, UCE.PointerClick, "BagUI", "OnUnlockClothBtnClick");

    local unWearClothBtn = GUI.ButtonCreate( FashionPage, "unWearClothBtn", "1800402080", 451.8, 268, Transition.ColorTint, "卸下", 140.2, 47, false);
    GUI.SetIsOutLine(unWearClothBtn, true);
    GUI.ButtonSetTextFontSize(unWearClothBtn, 26);
    GUI.ButtonSetTextColor(unWearClothBtn, colorwrite);
    GUI.SetOutLine_Color(unWearClothBtn, coloroutline);
    GUI.SetOutLine_Distance(unWearClothBtn, 1);
    GUI.RegisterUIEvent(unWearClothBtn, UCE.PointerClick, "BagUI", "OnUnWearClothBtnClick");

    return GUI.GetGuid(FashionPage)
end

-- 插入属性的函数
local insetAttr = function (attrCount,fashionClothes_Item)
    local buttonClothDesBg = _gt.GetUI("buttonClothDesBg") -- 属性文本背景

    for i=1,attrCount do
        local attrTxt_i = GUI.GetChild(buttonClothDesBg,"AttrTxt"..i)
        if fashionClothes_Item["Att"..i.."Num"] < 1 then -- 如果加成属性小于1
            GUI.SetVisible(attrTxt_i,false)
        else
            GUI.SetVisible(attrTxt_i,true)
            local attrName = DB.GetOnceAttrByKey1(fashionClothes_Item["Att"..i]).KeyName
            local attrValue = fashionClothes_Item["Att"..i.."Num"]
            GUI.StaticSetText(attrTxt_i,attrName.."+"..attrValue)
        end
    end
end

-- 刷新时装页面方法
BagUI.FashionSubTabIndex = 2 -- 当选中的二级页签
BagUI.Fashion_SelectedClothes_Index = 0 -- 当前选中的衣物下标
BagUI.Fashion_CurrentSelectedClothesId = nil -- 当前选择的时装ID
BagUI.Fashion_CurrentDress_Id = CL.GetIntCustomData("Model_Clothes") -- 当前装备的时装ID
BagUI.firstOpenFashionPage = true -- 第一次打开
function BagUI.RefreshFashionPage()

    if BagUI.FashionClothesItems == nil or BagUI.foreverClothes == nil then -- 如果请求服务器的数据不存在
        test("BagUI界面 执行BagUI.RefreshFashionPage()方法时,数据为空")
        return
    end

    local FashionPage = _gt.GetUI("FashionPage") -- 如果父类不存在
    if FashionPage == nil then
        return
    end

    --local inspect = require("inspect")
    --CDebug.LogError(inspect(BagUI.FashionClothesItems))
    -- 刷新物品栏的方法
    -- 隐藏包裹数量字体
    local capacityText =  _gt.GetUI("capacityText")
    GUI.SetVisible(capacityText,false)
    -- 隐藏整理按钮
    GUI.SetVisible(_gt.GetUI("arrangeBtn"),false)

    -- 关闭原先的物品栏
    local itemScroll = _gt.GetUI("itemScroll")
    GUI.SetVisible(itemScroll, false);
    -- 使用自己创建的物品栏
    local count = 36 -- 刷36个格子
    local FashionClothesScroll = _gt.GetUI("FashionClothesScroll")
    GUI.SetVisible(FashionClothesScroll,true)
    GUI.LoopScrollRectSetTotalCount(FashionClothesScroll, count);
    GUI.LoopScrollRectRefreshCells(FashionClothesScroll);


    -- 第一次打开页面
    if next(BagUI.FashionClothesItems) ~= nil and BagUI.firstOpenFashionPage then -- 如果玩家有时装
        BagUI.firstOpenFashionPage = false
        BagUI.FashionSubTabIndex = 1 -- 选择拥有界面
        UILayout.OnSubTabClick(BagUI.FashionSubTabIndex,fashionSubTabList)
        if BagUI.Fashion_CurrentDress_Id ~= nil and BagUI.Fashion_CurrentDress_Id ~= 0 then -- 如果当前玩家装备的时装不为空
            for k,v in ipairs(BagUI.FashionClothesItems) do
                if v.Id == BagUI.Fashion_CurrentDress_Id then
                    BagUI.Fashion_SelectedClothes_Index = k
                end
            end
        else
            BagUI.Fashion_SelectedClothes_Index = 0
        end
    elseif BagUI.firstOpenFashionPage  and next(BagUI.FashionClothesItems) == nil then
        BagUI.firstOpenFashionPage = false
        -- 如果玩家没有一件时装，传来的是空{}
        BagUI.FashionSubTabIndex = 2 -- 图鉴界面
        UILayout.OnSubTabClick(BagUI.FashionSubTabIndex,fashionSubTabList)
        BagUI.Fashion_SelectedClothes_Index = 1
    end

    if BagUI.FashionSubTabIndex == nil or  (BagUI.FashionSubTabIndex ~= 1 and BagUI.FashionSubTabIndex ~= 2) then
        BagUI.FashionSubTabIndex = 2
    end
    UILayout.OnSubTabClick(BagUI.FashionSubTabIndex,fashionSubTabList)

    local items = nil  -- 当前选中的时装对象
    if BagUI.FashionSubTabIndex == 1 then --如果是 1 二级页签界面
        if BagUI.Fashion_SelectedClothes_Index ~= 0 and next(BagUI.FashionClothesItems) ~= nil and BagUI.FashionClothesItems[BagUI.Fashion_SelectedClothes_Index] ~= nil then -- 如果选中的时装下标不是0
            items = BagUI.FashionClothesItems[BagUI.Fashion_SelectedClothes_Index]
            if items and items.Id then
                BagUI.Fashion_CurrentSelectedClothesId = items.Id
            end
        else
            items = nil
            BagUI.Fashion_SelectedClothes_Index = 0
        end
    elseif BagUI.FashionSubTabIndex == 2 then
        if BagUI.Fashion_SelectedClothes_Index == 0 then
            BagUI.Fashion_SelectedClothes_Index = 1
        end
        items = BagUI.foreverClothes[BagUI.Fashion_SelectedClothes_Index]
        BagUI.Fashion_CurrentSelectedClothesId = items.Id
    end

    local fashionClothes_Item = nil
    local name = nil
    local attrCount = 5 -- 加成属性个数
    if items ~= nil then
        fashionClothes_Item = DB.GetOnceIllusionByKey1(items.Id)
        name = fashionClothes_Item.Name
    end

    -- 刷新角色的方法
    BagUI.RefreshRoleFashionClothes(fashionClothes_Item)

    -- 刷新选择时间选择文本
    local upClothDesBg = _gt.GetUI("upClothDesBg") -- 文本背景
    local timeAndNameText = _gt.GetUI("HasPageClothNameText") -- 拥有界面文本
    local moreCLothBtn = _gt.GetUI("moreCLothBtn") -- 选择时间按钮
    local moreCLothNameText = _gt.GetUI("moreCLothNameText") -- 按钮上的文本
    local toMallBtn = _gt.GetUI("toMallBtn") -- 购买按钮
    local buttonClothDesBg = _gt.GetUI("buttonClothDesBg") -- 属性文本背景
    local DesTxtContent = _gt.GetUI("DesTxtContent") -- 描述文本
    local EmptyDesTxt = GUI.GetChild(buttonClothDesBg,"EmptyDesTxt")
    local AttrTxt1 = GUI.GetChild(buttonClothDesBg,"AttrTxt1")
    local AttrTxt2 = GUI.GetChild(buttonClothDesBg,"AttrTxt2")
    local AttrTxt3 = GUI.GetChild(buttonClothDesBg,"AttrTxt3")
    local AttrTxt4 = GUI.GetChild(buttonClothDesBg,"AttrTxt4")
    local AttrTxt5 = GUI.GetChild(buttonClothDesBg,"AttrTxt5")

    if BagUI.FashionSubTabIndex == 1 then -- 如果二级页签是1，"拥有"页面
        GUI.SetVisible(upClothDesBg,true)
        GUI.SetVisible(timeAndNameText,true)
        GUI.SetVisible(toMallBtn,false) -- 隐藏选择时间按钮
        GUI.SetVisible(moreCLothBtn,false) -- 隐藏购买按钮

        if BagUI.Fashion_SelectedClothes_Index == 0 then -- 如果选中的是 ”未穿戴时装"
            GUI.StaticSetText(timeAndNameText,"未穿戴时装")
            GUI.StaticSetText(DesTxtContent,"请挑选一件衣服吧~！")
            GUI.SetVisible(EmptyDesTxt,true)
            GUI.SetVisible(AttrTxt1,false)
            GUI.SetVisible(AttrTxt2,false)
            GUI.SetVisible(AttrTxt3,false)
            GUI.SetVisible(AttrTxt4,false)
            GUI.SetVisible(AttrTxt5,false)
        elseif BagUI.Fashion_SelectedClothes_Index > 0 then

            -- 转换为时间（物品过期时间戳 - 服务器当前时间戳）
            local day,house,minute,second = GlobalUtils.Get_DHMS2_BySeconds(items.Time - CL.GetServerTickCount() )
            local time = day.."天"..house.."小时"

            if items.Time == -1 then
                GUI.StaticSetText(timeAndNameText,name.."（永久）")
                GUI.StaticSetText(DesTxtContent,"激活时装将会永久获得属性并解锁图鉴，该属性可与其他不同名的时装的属性叠加。")
            else
                GUI.StaticSetText(timeAndNameText,name.."（"..time.."）")
                GUI.StaticSetText(DesTxtContent,"激活时装将会在限时内获得属性，该属性可与其他不同名的时装的属性叠加。")
            end
            -- 显示加成属性
            GUI.SetVisible(EmptyDesTxt,false) -- 无字
            insetAttr(attrCount,fashionClothes_Item) -- 插入属性

        end
    elseif BagUI.FashionSubTabIndex == 2 then
        GUI.SetVisible(upClothDesBg,false)
        GUI.SetVisible(timeAndNameText,false)
        GUI.SetVisible(moreCLothBtn,true) -- 显示时间按钮
        GUI.StaticSetText(moreCLothNameText,fashionClothes_Item.Name.."（永久）")
        GUI.StaticSetText(DesTxtContent,"激活时装将会永久获得属性并解锁图鉴，该属性可与其他不同名的时装的属性叠加。")
        GUI.SetVisible(toMallBtn,true)
        GUI.SetVisible(EmptyDesTxt,false) -- 无字
        insetAttr(attrCount,fashionClothes_Item) -- 插入属性
    end

    -- 刷新按钮
    local wearClothBtn = GUI.GetChild(FashionPage,"wearClothBtn") --穿戴
    local unlockClothBtn = GUI.GetChild(FashionPage,"unlockClothBtn") -- 获取
    local unWearClothBtn = GUI.GetChild(FashionPage,"unWearClothBtn") -- 卸下
    GUI.SetVisible(wearClothBtn,false)
    GUI.SetVisible(unlockClothBtn,false)
    GUI.SetVisible(unWearClothBtn,false)

    -- 判断是否是"未穿戴时装"
    if BagUI.Fashion_SelectedClothes_Index == 0 then
        -- 判断是否已穿戴
        if BagUI.Fashion_CurrentDress_Id and BagUI.Fashion_CurrentDress_Id == 0 then
            GUI.SetVisible(unWearClothBtn,true)
            GUI.ButtonSetShowDisable(unWearClothBtn,false)
        else
            GUI.SetVisible(wearClothBtn,true)
        end
    else
        GUI.ButtonSetShowDisable(unWearClothBtn,true) -- 将卸下按钮设为可用
        -- 判断是否拥有
        if next(BagUI.FashionClothesItems) == nil then
            GUI.SetVisible(unlockClothBtn,true)
        else
            local isHave = false
            for k,v in ipairs(BagUI.FashionClothesItems) do
                if items.Id == v.Id then
                    isHave = true
                end
                if isHave then  -- 判断是否拥有，只要拥有了，就执行一下，然后跳出循环
                    -- 判断是否已穿戴
                    if BagUI.Fashion_CurrentDress_Id and BagUI.Fashion_CurrentDress_Id == items.Id then
                        GUI.SetVisible(unWearClothBtn,true)
                    else
                        GUI.SetVisible(wearClothBtn,true)
                    end
                    break
                end
            end
            if not isHave then
                GUI.SetVisible(unlockClothBtn,true)
            end
        end
    end

end
-- 刷新角色时装
local preClothesId = nil -- 上一次时装id
--local preWingId = nil -- 上一次羽翼id
function BagUI.RefreshRoleFashionClothes(fashionClothes_Item)
    -- 刷新角色的方法
    local FashionPage_roleModel = _gt.GetUI("FashionPage_roleModel")

    local dyn1 = CL.GetIntAttr(RoleAttr.RoleAttrColor1)
    local dyn2 = CL.GetIntAttr(RoleAttr.RoleAttrColor2)

    if fashionClothes_Item then
        local model = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole)).Model
        --if preClothesId == fashionClothes_Item.Id then goto wearWing end  -- 如果与上次时装相同 则跳转到穿戴羽翼刷新
        if fashionClothes_Item.Type == 0 then
            ModelItem.Bind(FashionPage_roleModel, tonumber(tostring(fashionClothes_Item.Model)), dyn1, dyn2, eRoleMovement.STAND_W1, CL.GetIntAttr(RoleAttr.RoleAttrWeaponId), fashionClothes_Item.Sex, CL.GetIntAttr(RoleAttr.RoleAttrEffect1), 0, model)
            --CDebug.LogError('model1 :'..tonumber(tostring(fashionClothes_Item.Model)) .."  model2 : "..model)
            -- 添加武器和宝石特效
            ModelItem.BindRoleEquipGemEffect(FashionPage_roleModel)
        elseif fashionClothes_Item.Type == 1 then
            ModelItem.Bind(FashionPage_roleModel, model, dyn1, dyn2, eRoleMovement.STAND_W1, CL.GetIntAttr(RoleAttr.RoleAttrWeaponId), fashionClothes_Item.Sex, CL.GetIntAttr(RoleAttr.RoleAttrEffect1), tonumber(tostring(fashionClothes_Item.Model)), model)
            --CDebug.LogError('wingModel1 :'..model.." wingmodel2 :"..tonumber(tostring(fashionClothes_Item.Model)))
            -- 添加武器和宝石特效
            ModelItem.BindRoleEquipGemEffect(FashionPage_roleModel)
			--人物染色
			if CL.GetStrCustomData("Model_DynJson1") and CL.GetStrCustomData("Model_DynJson1") ~= "" then
				if UIDefine.IsFunctionOrVariableExist(GUI,"RefreshDyeSkinJson") then
					GUI.RefreshDyeSkinJson(FashionPage_roleModel, CL.GetStrCustomData("Model_DynJson1"), "")
				end
			end	
        end

        --preClothesId = fashionClothes_Item.Id

    else
        -- 使用最开始的装扮，无时装
        --if preClothesId == 0 then goto wearWing end
        local role = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole))
        local model = role.Model
        local sex = role.Sex
        ModelItem.Bind(FashionPage_roleModel, model, dyn1, dyn2, eRoleMovement.STAND_W1, CL.GetIntAttr(RoleAttr.RoleAttrWeaponId), sex, CL.GetIntAttr(RoleAttr.RoleAttrEffect1), 0, model)
        -- 添加武器和宝石特效
        ModelItem.BindRoleEquipGemEffect(FashionPage_roleModel)
        --preClothesId = 0
			--人物染色
		if CL.GetStrCustomData("Model_DynJson1") and CL.GetStrCustomData("Model_DynJson1") ~= "" then
			if UIDefine.IsFunctionOrVariableExist(GUI,"RefreshDyeSkinJson") then
				GUI.RefreshDyeSkinJson(FashionPage_roleModel, CL.GetStrCustomData("Model_DynJson1"), "")
			end
		end
		
    end
	
    --::wearWing::
    -- 刷新羽翼
    if WingUI then
        local WingPage_roleModel = FashionPage_roleModel
        local wing_Item = nil

        -- 获取当前穿戴的羽翼，然后通过它获取的羽翼对象
        --if WingUI.CurrentUsedWingId and WingUI.CurrentUsedWingId ~= 0 then
        --    wing_Item = DB.GetOnceIllusionByKey1(WingUI.CurrentUsedWingId)
        --else
        -- 获取服务器绑定的自定义变量
        local wing_id = CL.GetIntCustomData("Model_Wing", 0)
        if wing_id and wing_id ~= 0 then
            wing_Item = DB.GetOnceIllusionByKey1(wing_id)
        end
        --end
        --if WingUI.CurrentUsedWingId == preWingId then return end -- 如果这次羽翼id与上次相同，则不刷新
        if wing_Item then
            if wing_Item.Type == 2 then
                --if WingUI.WingGrow_Data and WingUI.WingGrow_Data.WingGrow_Stage then
                --    GUI.ReplaceWing(WingPage_roleModel, tonumber(tostring(wing_Item.Model)), tonumber(WingUI.WingGrow_Data.WingGrow_Stage))
                --    --preWingId = WingUI.CurrentUsedWingId
                --else
                -- 如果没有等级数据，通过自定义变量获取
                local wing_stage = CL.GetIntCustomData("WingGrow_Stage", 0)
                if wing_stage then
                    GUI.ReplaceWing(WingPage_roleModel, tonumber(tostring(wing_Item.Model)), wing_stage)
                end
                --end
            end

        else
            -- 使用最开始的装扮，无羽翼
            GUI.ReplaceWing(WingPage_roleModel, 0)
            --preWingId = 0
        end
    end
end

-- I图标点击事件
function BagUI.OnClothTipBtnClick(guid)
    local tabAttributePanel = GUI.Get("BagUI/panelBg/FashionPage/dragon");
    if tabAttributePanel == nil then
        return
    end
    local tips = GUI.GetChild(tabAttributePanel,"Fashion_I_Image")
    if tips == nil then
        local tips = GUI.ImageCreate(tabAttributePanel,"Fashion_I_Image","1800400290",-10.7,-28.1,false,480,170)
        GUI.SetIsRemoveWhenClick(tips,true) -- 点击后销毁
        GUI.AddWhiteName(tips,guid) -- 添加到点击销毁白名单
        local txt = GUI.CreateStatic(tips,"Fashion_I_txt","",3,0,430,GUI.GetHeight(tips),"system",true)
        GUI.StaticSetFontSize(txt,22)
        GUI.StaticSetAlignment(txt,TextAnchor.MiddleLeft)

        local message = "<color=#ffffff>1.时装一旦解锁，即获得其属性。</color> \n"..
                "<color=#ffffff>2.时装到达时限后，属性会相应扣除。</color> \n"..
                "<color=#ffffff>3.获得永久时装后，其图鉴才会被解锁。</color> \n"..
                "<color=#ffffff>4.激活更高时限的时装后，低时限的同一时装将无法使用，请避免获得。</color>"

        GUI.StaticSetText(txt,message)
    end
end

--local PreSelectedClothesIndex = {} -- 上一次选中的衣物下标
--local PreSelectedClothesId  = {} -- 上一次选择的时装ID
-- 拥有点击事件
function BagUI.OnHaveFashionSubTabBtnClick()
    if BagUI.FashionSubTabIndex == 1 then
        return ''
    end
    -- 如果有已装备时装
    if BagUI.Fashion_CurrentDress_Id and BagUI.Fashion_CurrentDress_Id ~= 0 then
        if BagUI.FashionClothesItems and next(BagUI.FashionClothesItems) then
            for k, v in ipairs(BagUI.FashionClothesItems) do
                if v.Id == BagUI.Fashion_CurrentDress_Id then
                    BagUI.Fashion_SelectedClothes_Index = k
                    BagUI.Fashion_CurrentSelectedClothesId = v.Id
                end
            end
        end
        -- 如果==0是 "未装备时装", 或者不存在，就直接选中第一个
    else
        BagUI.Fashion_SelectedClothes_Index = 0
        BagUI.Fashion_CurrentSelectedClothesId = 0
    end


    --if BagUI.FashionSubTabIndex ~= 1 then
    --    if PreSelectedClothesIndex[1] ~= nil and PreSelectedClothesId[1] ~= nil then -- 如果上一次记录的 选中的时装 存在
    --        --CDebug.LogError("拥有".." index:"..PreSelectedClothesIndex[BagUI.FashionSubTabIndex].." ID:"..PreSelectedClothesId[BagUI.FashionSubTabIndex].." tabindex:"..BagUI.FashionSubTabIndex)
    --        BagUI.Fashion_SelectedClothes_Index  = PreSelectedClothesIndex[1]
    --        BagUI.Fashion_CurrentSelectedClothesId = PreSelectedClothesId[1]
    --    else -- 如果上一次 没选中
    --        if BagUI.Fashion_CurrentDress_Id and BagUI.Fashion_CurrentDress_Id ~= 0 and next(BagUI.FashionClothesItems) ~= nil then -- 判断是否有已装备的
    --            for k,v in ipairs(BagUI.FashionClothesItems) do
    --                if v.Id == BagUI.Fashion_CurrentDress_Id then
    --                    BagUI.Fashion_SelectedClothes_Index = k
    --                    BagUI.Fashion_CurrentSelectedClothesId = v.Id
    --                end
    --            end
    --        else -- 如果没有已装备的 选中 ”未穿戴“
    --            BagUI.Fashion_SelectedClothes_Index  = 0
    --            BagUI.Fashion_CurrentSelectedClothesId = nil
    --        end
    --    end
    --end
    BagUI.FashionSubTabIndex = 1
    BagUI.RefreshFashionPage()

end
-- 图鉴点击事件
function BagUI.OnPictorial_BookSubTabBtnClick()
    if BagUI.FashionSubTabIndex == 2 then
        return ''
    end
    -- 如果有已装备时装
    if BagUI.Fashion_CurrentDress_Id and BagUI.Fashion_CurrentDress_Id ~= 0 then
        if BagUI.Fashion_CurrentDress_Id ~= 0 and BagUI.FashionClothesItems and next(BagUI.FashionClothesItems) then
            --是否在永久羽翼中，是永久羽翼
            local is_forever_clothed = false
            for k, v in pairs(BagUI.foreverClothes) do
                if k ~= 'Count' and v.Id == BagUI.Fashion_CurrentDress_Id then
                    BagUI.Fashion_SelectedClothes_Index = k
                    BagUI.Fashion_CurrentSelectedClothesId = v.Id
                    is_forever_clothed = true
                    break
                end
            end

            -- 如果不是永久羽翼，则选择第一个格子
            if is_forever_clothed == false then
                if BagUI.foreverClothes and BagUI.foreverClothes[1] then
                    -- 如果没有永久的时装 选物品格子的第一个
                    BagUI.Fashion_SelectedClothes_Index = 1
                    BagUI.Fashion_CurrentSelectedClothesId = BagUI.foreverClothes[1].Id
                end
            end

        end
    elseif BagUI.Fashion_CurrentDress_Id == 0 then
        -- 如果是 "未装备时装"
        -- 判断是否有已拥有的永久的时装 选中第一个
        local clothesId = nil
        if BagUI.FashionClothesItems and next(BagUI.FashionClothesItems) then
            for k, v in ipairs(BagUI.FashionClothesItems) do
                if v.Time == -1 then
                    clothesId = v.Id
                    break
                end
            end
        end

        if clothesId then
            for k, v in pairs(BagUI.foreverClothes) do
                if k ~= 'Count' and v.Id == clothesId then
                    BagUI.Fashion_SelectedClothes_Index = k
                    BagUI.Fashion_CurrentSelectedClothesId = v.Id
                end
            end
        elseif BagUI.foreverClothes and BagUI.foreverClothes[1] then
            -- 如果没有永久的时装 选物品格子的第一个
            BagUI.Fashion_SelectedClothes_Index = 1
            BagUI.Fashion_CurrentSelectedClothesId = BagUI.foreverClothes[1].Id
        end
    end

    --if BagUI.FashionSubTabIndex ~= 2 then
    --    if PreSelectedClothesIndex[2] ~= nil and PreSelectedClothesId[2] ~= nil then
    --        --CDebug.LogError("图鉴".." index:"..PreSelectedClothesIndex[BagUI.FashionSubTabIndex].." ID:"..PreSelectedClothesId[BagUI.FashionSubTabIndex].." tabindex:"..BagUI.FashionSubTabIndex)
    --        BagUI.Fashion_SelectedClothes_Index  = PreSelectedClothesIndex[2]
    --        BagUI.Fashion_CurrentSelectedClothesId = PreSelectedClothesId[2]
    --    else
    --        -- 判读是否拥有
    --        local isHave = false
    --        if BagUI.Fashion_CurrentDress_Id and BagUI.Fashion_CurrentDress_Id ~= 0 and next(BagUI.FashionClothesItems) ~= nil then
    --            for k,v in ipairs(BagUI.FashionClothesItems) do
    --                if v.Id == BagUI.Fashion_CurrentDress_Id then
    --                    if v.Time == -1 then -- 如果拥有 并且是永久的
    --                        isHave = true
    --                    end
    --                end
    --            end
    --        end
    --        if isHave and next(BagUI.foreverClothes) ~= nil then -- 判断是否有已装备的
    --            for k,v in ipairs(BagUI.foreverClothes) do
    --                if v.Id == BagUI.Fashion_CurrentDress_Id then
    --                    BagUI.Fashion_SelectedClothes_Index = k
    --                    BagUI.Fashion_CurrentSelectedClothesId = v.Id
    --                end
    --            end
    --        else -- 如果没有已装备的 选中 第一个
    --            BagUI.Fashion_SelectedClothes_Index  = 1
    --            BagUI.Fashion_CurrentSelectedClothesId = BagUI.foreverClothes[1].Id
    --        end
    --    end
    --
    --end

    BagUI.FashionSubTabIndex = 2
    BagUI.RefreshFashionPage()

end
-- 时间选择按钮的事件
local transferString = {} -- 将点击后选择的数据传输到下一个点击事件
function BagUI.OnClothHBMoreBtnClick(guid)

    local FashionPage = _gt.GetUI("FashionPage")
    local FashionClothTime_Bg =GUI.GetChild(FashionPage,"guardTypeBg") -- 选择列表黑色背景

    if FashionClothTime_Bg ~= nil then
        GUI.Destroy(FashionClothTime_Bg);
        return
    end
    FashionClothTime_Bg =GUI.ImageCreate(FashionPage, "FashionClothTime_Bg","1800400290",-258,-57,false,277,160);
    SetAnchorAndPivot(FashionClothTime_Bg, UIAnchor.Center, UIAroundPivot.Center)

    local scrollRect = GUI.ScrollRectCreate(FashionClothTime_Bg,"scrollRect",0,0,277,140,0,false,Vector2.New(250,48))

    local data = {{["name"]="时间领主",["time"]=7},{["name"]="春风万里",["time"]=30},{["name"]="雪花飘飘",["time"]=0},}
    -- 获取当前选中的时装
    if BagUI.Fashion_CurrentSelectedClothesId ~= nil then
        local item = DB.GetOnceIllusionByKey1(BagUI.Fashion_CurrentSelectedClothesId)
        data = {}
        table.insert(data,{["name"]=item.Name,["time"]=item.Time,["id"]=item.Id})

        -- 时装名称
        local wing_name = item.Name

        -- 先往上找,当Name字段不同时再往下找
        while(wing_name == item.Name) do
            item = DB.GetOnceIllusionByKey1(item.Id -1 )
            if item ~= nil and item.Id ~= 0 and wing_name == item.Name then
                table.insert(data,{["name"]=item.Name,["time"]=item.Time,["id"]=item.Id})
            end
        end

        -- 往下找
        while(wing_name == item.Name) do
            item = DB.GetOnceIllusionByKey1(item.Id +1 )
            if item ~= nil and item.Id ~= 0 and wing_name == item.Name then
                table.insert(data,{["name"]=item.Name,["time"]=item.Time,["id"]=item.Id})
            end
        end

        table.sort(data,function(a, b) return a.id < b.id end)  -- 排下序 id 从小到大

    end

    for i=1,#data do
        local name = data[i].name
        local timeDes = data[i].time
        if timeDes > 0 then
            timeDes = "（" .. timeDes  .. "天）"
        else
            timeDes = "（永久）"
        end
        local level = GUI.ButtonCreate( scrollRect, "fashionBtn_"..i, "1801102010", 0, GUI.GetHeight(FashionClothTime_Bg), Transition.ColorTint, name .. timeDes, 250, 48, false);
        GUI.ButtonSetTextColor(level, colorDark);
        GUI.ButtonSetTextFontSize(level, 24);
        SetAnchorAndPivot(level, UIAnchor.Top, UIAroundPivot.Top)
        GUI.SetData(level, "LevelIndex", i);
        GUI.RegisterUIEvent(level, UCE.PointerClick, "BagUI", "OnClothHBMoreScrollItemClick")

        --GUI.SetHeight(FashionClothTime_Bg,GUI.GetHeight(FashionClothTime_Bg)+GUI.GetHeight(level)) -- 更新高度
        transferString[GUI.GetGuid(level)] = data[i]
    end
    -- 将列表滚动到开头
    GUI.ScrollRectSetNormalizedPosition(scrollRect, Vector2.New(0,1))
    -- 是否检测到点击就销毁
    GUI.SetIsRemoveWhenClick(FashionClothTime_Bg,true)

end

-- 选择时间后的点击事件
local selectedFashionItem = nil
function BagUI.OnClothHBMoreScrollItemClick(guid)
    if next(transferString) == nil then
        return
    end

    selectedFashionItem = transferString[guid]

    local name = transferString[guid].name
    local timeDes = transferString[guid].time
    if timeDes > 0 then
        timeDes = "（" .. timeDes  .. "天）"
    else
        timeDes = "（永久）"
    end

    local moreCLothNameText = _gt.GetUI("moreCLothNameText") -- 选择时间按钮上的文本
    local toMallBtn = _gt.GetUI("toMallBtn") -- 购买按钮
    local DesTxtContent = _gt.GetUI("DesTxtContent") -- 描述信息

    GUI.StaticSetText(moreCLothNameText,name..timeDes)
    if transferString[guid].time == 0 then
        GUI.SetVisible(toMallBtn,true)
        GUI.StaticSetText(DesTxtContent,"激活时装将会永久获得属性并解锁图鉴，该属性可与其他不同名的时装的属性叠加。")
    else
        GUI.SetVisible(toMallBtn,false)
        GUI.StaticSetText(DesTxtContent,"激活时装将会在限时内获得属性，该属性可与其他不同名的时装的属性叠加。")
    end
end
-- 购买的事件
function BagUI.OnClothHBToMallBtnClick(guid)
    -- 点击后跳转到商城-金砖-对应的时装
    if BagUI.Fashion_CurrentSelectedClothesId ~= nil then
        local fashion_key_name = DB.GetOnceIllusionByKey1(BagUI.Fashion_CurrentSelectedClothesId).KeyName
        GUI.OpenWnd("MallUI",fashion_key_name)
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,'数据异常')
        test('BagUI.OnClothHBToMallBtnClick 时装购买按钮传入参数错误')
    end
end
-- 时装点击事件
function BagUI.OnFashionItemClick(guid)
    local itemIcon = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(itemIcon,"index"))
    local clothesID = nil
    local clothes = nil
    if index > 0 then
        if BagUI.FashionSubTabIndex == 1 then
            clothesID = BagUI.FashionClothesItems[index].Id
            clothes = DB.GetOnceIllusionByKey1(clothesID)
        elseif BagUI.FashionSubTabIndex == 2 then
            clothesID = BagUI.foreverClothes[index].Id
            clothes = BagUI.foreverClothes[index]
        end
    elseif index == 0 then
        clothesID = 0
    end

    -- 判断性别是否符合
    local sex = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole)).Sex
    if clothes and clothes.Sex ~= sex then
        CL.SendNotify(NOTIFY.ShowBBMsg,"性别不符，无法穿戴")
        return
    end

    -- 隐藏上一个选中节点的选中框
    local FashionClothesScroll = _gt.GetUI("FashionClothesScroll")
    if BagUI.Fashion_SelectedClothes_Index ~= 0 then
        local Icon = GUI.LoopScrollRectGetChildInPool(FashionClothesScroll,"FashionIcon"..BagUI.Fashion_SelectedClothes_Index-1)
        local selectedBox = GUI.GetChild(Icon,"selectedBox")
        if selectedBox then GUI.SetVisible(selectedBox,false) end
    else
        local Icon = GUI.LoopScrollRectGetChildInPool(FashionClothesScroll,"FashionIcon"..BagUI.Fashion_SelectedClothes_Index)
        local selectedBox = GUI.GetChild(Icon,"selectedBox")
        if selectedBox then GUI.SetVisible(selectedBox,false) end
    end

    -- 物品选中框
    local selectedBox = GUI.GetChild(itemIcon,"selectedBox")
    if selectedBox then
        GUI.SetVisible(selectedBox,true)
    end

    BagUI.Fashion_SelectedClothes_Index = index -- 当前选中的时装的下标
    BagUI.Fashion_CurrentSelectedClothesId = clothesID -- 当前选中的时装的ID

    --PreSelectedClothesIndex[BagUI.FashionSubTabIndex] = BagUI.Fashion_SelectedClothes_Index
    --PreSelectedClothesId[BagUI.FashionSubTabIndex] = BagUI.Fashion_CurrentSelectedClothesId

    BagUI.RefreshFashionPage()

    -- 获取事件 切换时装 切换其显示tips为永久
    selectedFashionItem = nil

end
-- 穿戴/卸下/获取事件
-- 穿戴事件
function BagUI.OnWearClothBtnClick(guid)
    if BagUI.Fashion_CurrentSelectedClothesId == nil then return end
    --FormClothes.WearClothes(player,Clothes_Id) -- 穿戴请求
    CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","WearClothes",tostring(BagUI.Fashion_CurrentSelectedClothesId)) -- 执行刷新页面

end
-- 卸下事件
function BagUI.OnUnWearClothBtnClick()
    -- 当是拥有界面时，卸下 会使用 "未穿戴装备"
    if BagUI.FashionSubTabIndex == 1 then
        BagUI.Fashion_SelectedClothes_Index = 0 -- 当前选中的衣物下标
        BagUI.Fashion_CurrentSelectedClothesId = nil -- 当前选择的时装ID
    end
    CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","WearClothes","0") -- 执行刷新页面
end
-- 获取事件
function BagUI.OnUnlockClothBtnClick()
    -- 通过keyname找到 时装itemID
    local id = nil
    if selectedFashionItem and selectedFashionItem.id then -- 如果时间选中框已有选中
        id = selectedFashionItem.id
    elseif BagUI.Fashion_CurrentSelectedClothesId then -- 如果上面没用 就默认用图鉴界面 永久的
        id = BagUI.Fashion_CurrentSelectedClothesId
    else
        test("BagUI界面 BagUI.OnUnlockClothBtnClick()获取事件 需要的数据为空")
        --CL.SendNotify(NOTIFY.ShowBBMsg,"开发中")
        return
    end

    if id then
        local clothes = DB.GetOnceIllusionByKey1(id)
        local clothesItem = DB.GetOnceItemByKey2(clothes.KeyName)
        local clothesItemId = clothesItem.Id
        -- 判读是否已经拥有 物品数量>0
        if LD.GetItemCountById(clothesItemId) > 0 then
            -- 如果拥有就直接使用
            -- FormClothes.UseClothesItem(player,Item_Id)
            --CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","UseClothesItem",clothesItemId)
            -- 如果拥有就直接使用
            GlobalUtils.ShowBoxMsg2Btn('提示',"您已拥有"..clothesItem.Name.."是否立即使用",
                    "BagUI","确认",
                    "use_wing_item","取消")
        else
            -- 如果没有就弹出tips 以及获取方式
            local FashionPage = _gt.GetUI("FashionPage")
            local tip = Tips.CreateByItemId(tonumber(clothesItemId), FashionPage, "FashionPageTips",120,32)
            GUI.SetData(tip, "ItemId", tostring(clothesItemId))
            GUI.SetHeight(tip,GUI.GetHeight(tip)+40)
            _gt.BindName(tip, "FashionPageTips")
            local wayBtn = GUI.ButtonCreate(tip, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
            UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"BagUI","OnClickFormationWayBtn")
            GUI.AddWhiteName(tip, GUI.GetGuid(wayBtn))
        end

    end

end
-- 获取途径
function BagUI.OnClickFormationWayBtn()
    local tip = _gt.GetUI("FashionPageTips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end

-- 使用时装物品
function BagUI.use_wing_item()
    if selectedFashionItem and selectedFashionItem.id then
        local clothes = DB.GetOnceIllusionByKey1(selectedFashionItem.id)
        local clothesItem = DB.GetOnceItemByKey2(clothes.KeyName)
        local itemGuid = LD.GetItemGuidsById(clothesItem.Id)
        if itemGuid and itemGuid[0] ~= 0 then
            GlobalUtils.UseItem(itemGuid[0])
        end
    end
end

-- 创建确认窗口
local Item_Id = nil -- 时装ID 客户端传来的参数 再传回去
function BagUI.CreateConfirmWindow(item_Id,type)
    if type == 0 or type == 1 then
        GlobalUtils.ShowBoxMsg2Btn("提示","你已解锁新的时装，是否直接穿戴？","BagUI","确认","ConfirmWindow","取消")
    elseif type == 2 then
        GlobalUtils.ShowBoxMsg2Btn("提示","你已解锁新的羽翼，是否直接穿戴？","BagUI","确认","ConfirmWing","取消")
    end
    if item_Id then
        Item_Id = item_Id
    else
        Item_Id = nil
    end
end
-- 时装确认事件
function BagUI.ConfirmWindow()
    if Item_Id then
        CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","WearClothes",tostring(Item_Id))
    else
        test("BagUI.ConfirmWindow()  传入的时装ID为空")
    end
end
-- 羽翼确认事件
function BagUI.ConfirmWing()
    if Item_Id then
        CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","WearWing",tostring(Item_Id))
    else
        test("BagUI.ConfirmWindow()  传入的羽翼ID为空")
    end
end

-- 时装监听器调用的函数
function BagUI.clothes_message_event(item_guid, item_id)
    if not item_id then
        -- 如果是侍从信物之类的物品,背包不同无法获取到，就直接退出
        local item_data = LD.GetItemDataByGuid(item_guid)
        if item_data and item_data.id then
            item_id = item_data.id
        else
            return ''
        end
    end
    item_id = tonumber(item_id)
    local item = DB.GetOnceItemByKey1(item_id)

    -- 如果是时装道具
    if item.Type == 2 and item.Subtype == 44 then
        -- 如果当前是在时装页签
        if 3 == BagUI.tabIndex and _gt["tabPage"..BagUI.tabIndex] ~= nil then
            BagUI.firstOpenFashionPage = true
            BagUI.FashionRequest() -- 刷新时装页面
        end
    end
end
-------------------------------------------------end 时装 end -----------------------------------------------------

-------------------------------------------------start 羽翼 start -----------------------------------------------------
-- 请求打开羽翼界面的等级
BagUI.OpenWingLevel = nil
function BagUI.GetOpenLevel()
    --FormClothes.GetOpenLevel(player)
    if BagUI then
        CL.SendNotify(NOTIFY.SubmitForm,"FormClothes","GetOpenLevel")
    end
end
-- 打开此界面的点击事件
function BagUI.OnWingTabBtnClick()
    --WingUI =  require("WingUI")
    WingUI.Fashion_CurrentDress_Id = BagUI.Fashion_CurrentDress_Id
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[4][1])
    local Level = MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        BagUI.tabIndex = 4 -- 设置羽翼一级下标页签
        BagUI.Refresh() -- 通过请求的回调函数执行
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
        UILayout.OnTabClick(BagUI.tabIndex, tabList);
        return false
    end
    -- local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    -- if BagUI.OpenWingLevel and roleLevel < BagUI.OpenWingLevel then
    -- CL.SendNotify(NOTIFY.ShowBBMsg,"羽翼：58级开启")
    -- UILayout.OnTabClick(BagUI.tabIndex, tabList);
    -- return
    -- end
    return true
end

-- 羽翼页签小红点
function BagUI.set_wing_tab_red()

    -- 判断等级是否足够
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[4][1])
    local Level = MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel[Key]

    if CurLevel >= Level then
        local btn = GUI.GetByGuid(tabList[4].btnGuid)

        -- 如果羽翼已达到最大等级
        if GlobalProcessing.wing_is_max_level == true then

            if GlobalProcessing['bagBtn'..'_Reds'] ~= nil then
                GlobalProcessing['bagBtn'..'_Reds']  = nil
            end

            GlobalProcessing.SetRetPoint(btn, false, UIDefine.countdown_type.bookmark)
            return ''
        end

        if GlobalProcessing['bagBtn'..'_Reds'] and GlobalProcessing['bagBtn'..'_Reds']['wing_upgrade'] then
            -- 如果是升阶
            if GlobalProcessing['bagBtn'..'_Reds']['wing_upgrade'] ~= 3 then

                if GlobalProcessing['bagBtn'..'_Reds']['wing_upgrade'] == 1 then
                    GlobalProcessing.SetRetPoint(btn, true, UIDefine.countdown_type.bookmark)
                else
                    GlobalProcessing.SetRetPoint(btn, false, UIDefine.countdown_type.bookmark)
                end
                -- 如果不是升阶，而是升级
            else
                if GlobalProcessing['bagBtn'..'_Reds'] and GlobalProcessing['bagBtn'..'_Reds']['wing_level_up'] then
                    if GlobalProcessing['bagBtn'..'_Reds']['wing_level_up'] == 1 then
                        GlobalProcessing.SetRetPoint(btn, true, UIDefine.countdown_type.bookmark)
                    else
                        GlobalProcessing.SetRetPoint(btn, false, UIDefine.countdown_type.bookmark)
                    end
                end

            end
        end
    else
        return false
    end

end

-- 羽翼监听器调用函数
function BagUI.wing_message_event(item_guid, item_id)

    -- 判断等级是否足够
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[4][1])
    local Level = MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel[Key]

    if CurLevel < Level then
        return ''
    else
        if not item_id then
            -- 如果是侍从信物之类的物品,背包不同无法获取到，就直接退出
            local item_data = LD.GetItemDataByGuid(item_guid)
            if item_data and item_data.id then
                item_id = item_data.id
            else
                return ''
            end
        end
        item_id = tonumber(item_id)
        local item = DB.GetOnceItemByKey1(item_id)

        -- 如果是羽翼物品，或羽翼升级道具
        if (item.Type == 2 and item.Subtype == 45) or
                (item.Type == 3 and (item.Subtype == 29 or item.Subtype == 30)) then
            -- 刷新羽翼界面
            WingUI.getSeverWingData()
        end
    end

end

-------------------------------------------------end 羽翼 end -----------------------------------------------------


-----------------------------------------------------坐骑------------------------------------------------

function BagUI.OnMountTabBtnClick()
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[5][1])
    local Level = MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        BagUI.tabIndex = 5 -- 设置坐骑一级下标页签
        BagUI.Refresh() -- 通过请求的回调函数执行
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
        UILayout.OnTabClick(BagUI.tabIndex, tabList)
        return false
    end
    return true
end













-----------------------------------------------------end----------------------------------------------------
function BagUI.OnMoreBtnClick(guid)
    test("guid"..guid)

    local Arrow = _gt.GetUI("Arrow")
    local Btn = _gt.GetUI("moreBtn")
    if Arrow ~= nil then
        if GUI.GetEulerAngles(Arrow).z == 0 then
            GUI.SetEulerAngles(Arrow, Vector3.New(0, 0, 180));
            GUI.SetPositionY(Arrow,35);
            MoreBtnNmu = 1;
        else
            GUI.SetEulerAngles(Arrow, Vector3.New(0, 0, 0));
            GUI.SetPositionY(Arrow,15)
            MoreBtnNmu = 0;
        end
    end

    local More = GUI.GetChild(Btn,"More",false)


    if MoreBtnNmu==1 then
        if More == nil then
            More = GUI.GroupCreate(Btn,"More",0,55,150,300)
            GUI.SetIsRaycastTarget(More, true)
            More:RegisterEvent(UCE.PointerClick)
            GUI.RegisterUIEvent(More, UCE.PointerClick, "BagUI", "OnMoreGroupBtnClick");

        end

        local moreBtnLoop = GUI.GetChild(More,"moreBtnLoop",false)

        if moreBtnLoop == nil then

            local moreBtnLoop =
            GUI.LoopScrollRectCreate(
                    More,
                    "moreBtnLoop",
                    0,
                    0,
                    150,
                    275,
                    "BagUI",
                    "CreateMoreBtnItem",
                    "BagUI",
                    "RefreshMoreBtnItem",
                    0,
                    false,
                    Vector2.New(150, 50),
                    1,
                    UIAroundPivot.BottomLeft,
                    UIAnchor.BottomLeft,
                    false
            )
            SetSameAnchorAndPivot(moreBtnLoop, UILayout.BottomLeft)
            GUI.ScrollRectSetAlignment(moreBtnLoop, TextAnchor.LowerLeft)
            _gt.BindName(moreBtnLoop, "moreBtnLoop")
            GUI.ScrollRectSetChildSpacing(moreBtnLoop, Vector2.New(0, 0))

        end

        --添加bagMoreBtnTable内数据
        BagUI.AddBagMoreBtnTableData()

    else
        if More ~= nil then
            GUI.SetVisible(More,false)
        end

    end


end

--添加bagMoreBtnTable内数据，需要服务器添加数据则在这里面写
function BagUI.AddBagMoreBtnTableData()
    local itemDB = DB.GetOnceItemByKey1(NowClick.id);


    test("itemDB.Type",itemDB.Type)
    test("itemDB.Subtype",itemDB.Subtype)
    test("itemDB.Subtype2",itemDB.Subtype2)
    test("itemDB.ShowType",itemDB.ShowType)

    --背包更多按钮刷新表
    bagMoreBtnTable = {
        btnName = {},
        Type = itemDB.Type,
        Subtype = itemDB.Subtype,
        Subtype2 = itemDB.Subtype2,
        ShowType = itemDB.ShowType,
    }

    local site = LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
    if site~=-1 then
        if UIDefine.EquipSite[site] == "法宝" then
            table.insert(bagMoreBtnTable.btnName,"修理")

            if UIDefine.DonateEquipAndPetData["EquipConfig"] then
                for i =1, #UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"] do
                    if UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"][i] == itemDB.Grade then

                        table.insert(bagMoreBtnTable.btnName,"捐献")

                    end
                end
            end


        else

            table.insert(bagMoreBtnTable.btnName,"强化")

            table.insert(bagMoreBtnTable.btnName,"修理")

            table.insert(bagMoreBtnTable.btnName,"镶嵌")

            table.insert(bagMoreBtnTable.btnName,"炼化")

            if UIDefine.DonateEquipAndPetData["EquipConfig"] then
                for i =1, #UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"] do
                    if UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"][i] == itemDB.Grade then

                        table.insert(bagMoreBtnTable.btnName,"捐献")

                    end
                end
            end

            if UIDefine.FunctionSwitch["EquipSoulReforge"] and UIDefine.FunctionSwitch["EquipSoulReforge"] == "on" then

                table.insert(bagMoreBtnTable.btnName,"拆分器灵")

            end


        end
    elseif tonumber(itemDB.Type) == 2 then
        
        if itemDB.ShowType == "制药材料" then

            table.insert(bagMoreBtnTable.btnName,"炼药")

        elseif itemDB.ShowType == "烹饪材料" or itemDB.ShowType == "烹饪佐料"  then

            table.insert(bagMoreBtnTable.btnName,"烹饪")

        else
            if tonumber(itemDB.Subtype) == 42 then

                table.insert(bagMoreBtnTable.btnName,"兑换")

            end

            table.insert(bagMoreBtnTable.btnName,"使用全部")

        end
    elseif tonumber(itemDB.Type) == 1 and tonumber(itemDB.Subtype) == 7 then
        local PosY = 0
        --如果宠物装备强化功能未开启
        if UIDefine.FunctionSwitch and UIDefine.FunctionSwitch["PetEquipIntensify"] == "on" and itemDB.Subtype2 ~= 4 then

            table.insert(bagMoreBtnTable.btnName,"强化")

        end

        table.insert(bagMoreBtnTable.btnName,"修理")

        table.insert(bagMoreBtnTable.btnName,"洗炼")

        if UIDefine.DonateEquipAndPetData["EquipConfig"] then
            for i =1, #UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"] do
                if UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"][i] == itemDB.Grade then

                    table.insert(bagMoreBtnTable.btnName,"捐献")

                end
            end
        end

    elseif tonumber(itemDB.Type) == 6 then

        table.insert(bagMoreBtnTable.btnName,"上交")

    elseif tonumber(itemDB.Type) == 3 and tonumber(itemDB.Subtype) == 9 then

        table.insert(bagMoreBtnTable.btnName,"镶嵌")

    end

    local moreBtnLoop = _gt.GetUI("moreBtnLoop")

    if bagMoreBtnLoopIsRoll == 0 then

        if #bagMoreBtnTable.btnName <= 5 then

            GUI.ScrollRectSetVertical(moreBtnLoop,false)

        else

            GUI.ScrollRectSetVertical(moreBtnLoop,true)

        end
        GUI.SetPositionY(moreBtnLoop,0)

    elseif bagMoreBtnLoopIsRoll == 1 then

        GUI.ScrollRectSetVertical(moreBtnLoop,false)
        GUI.SetHeight(moreBtnLoop,#bagMoreBtnTable.btnName * 52 + 5)
        GUI.SetPositionY(moreBtnLoop,-5)
    end

    GUI.LoopScrollRectSetTotalCount(moreBtnLoop, #bagMoreBtnTable.btnName)
    GUI.LoopScrollRectRefreshCells(moreBtnLoop)

end

function BagUI.CreateMoreBtnItem()
    local GambleLoop = _gt.GetUI("CreateMoreBtnItem")
    local index = GUI.LoopScrollRectGetChildInPoolCount(GambleLoop) + 1

    local moreChildBtn = GUI.ButtonCreate(GambleLoop,"moreChildBtn"..index,1800402110,0,50,Transition.ColorTint, "", 150, 50, false);
    GUI.ButtonSetTextColor(moreChildBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(moreChildBtn, UIDefine.FontSizeL);
    GUI.RegisterUIEvent(moreChildBtn, UCE.PointerClick, "BagUI", "OnMoreChildBtnClick");

    return moreChildBtn
end

function BagUI.RefreshMoreBtnItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = bagMoreBtnTable.btnName[index]

    if data then

        GUI.ButtonSetText(item,data)
        GUI.SetData(item,"btnName",data)

    end


end

--更多子类按钮点击事件配置
function BagUI.OnMoreChildBtnClick(guid)
    --更多子类按钮点击事件配置
    local btn = GUI.GetByGuid(guid)

    local btnName = GUI.GetData(btn,"btnName")
    local Type = bagMoreBtnTable.Type
    local Subtype = bagMoreBtnTable.ShowType
    local Subtype2 = bagMoreBtnTable.Subtype2
    local ShowType = bagMoreBtnTable.ShowType

    test("btnName",btnName)
    test("Type",Type)
    test("Subtype",Subtype)
    test("Subtype2",Subtype2)
    test("ShowType",ShowType)

    local itemDB = DB.GetOnceItemByKey1(NowClick.id);
    local site = LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
    if site~=-1 then
        if UIDefine.EquipSite[site] == "法宝" then
            if btnName == "修理" then
                BagUI.OnFixBtnClick()
            end

            if UIDefine.DonateEquipAndPetData["EquipConfig"] then
                for i =1, #UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"] do
                    if UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"][i] == itemDB.Grade then

                        if btnName == "捐献" then
                            BagUI.OnDonateBtnClick()
                        end

                    end
                end
            end


        else

            if btnName == "强化" then
                BagUI.OnStrengthenBtnClick()
            end

            if btnName == "修理" then
                BagUI.OnFixBtnClick()
            end

            if btnName == "镶嵌" then
                BagUI.OnSetBtnClick()
            end

            if btnName == "炼化" then
                BagUI.OnLianHuaBtnClick()
            end

            if UIDefine.DonateEquipAndPetData["EquipConfig"] then
                for i =1, #UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"] do
                    if UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"][i] == itemDB.Grade then

                        if btnName == "捐献" then
                            BagUI.OnDonateBtnClick()
                        end

                    end
                end
            end

            if btnName == "拆分器灵" then

                local level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel_2["升灵"]

                local RoleLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))

                if RoleLevel < level then

                    CL.SendNotify(NOTIFY.ShowBBMsg, level.."开启拆分器灵")

                    return

                else

                    GUI.OpenWnd("EquipSalvageSoulUI",tostring(selectItemGuid))

                end

            end

        end
    elseif tonumber(itemDB.Type) == 2 then
        if itemDB.ShowType == "制药材料" then

            if btnName == "炼药" then
                BagUI.OnLianYaoBtnClick()
            end

        elseif itemDB.ShowType == "烹饪材料" or itemDB.ShowType == "烹饪佐料"  then

            if btnName == "烹饪" then
                BagUI.OnCookBtnClick()
            end

        else
            if tonumber(itemDB.Subtype) == 42 then

                if btnName == "兑换" then
                    BagUI.OnExchangeBtnClick()
                end

            end

            if btnName == "使用全部" then
                BagUI.OnUseAllBtnClick()
            end

        end
    elseif tonumber(itemDB.Type) == 1 and tonumber(itemDB.Subtype) == 7 then




        local PosY = 0
        --如果宠物装备强化功能未开启
        if UIDefine.FunctionSwitch and UIDefine.FunctionSwitch["PetEquipIntensify"] == "on" and itemDB.Subtype2 ~= 4 then

            if btnName == "强化" then
                BagUI.OnQiangHuaBtnClick()
            end

        end

        if btnName == "修理" then
            BagUI.OnRepairClick()
        end


        if btnName == "洗炼" then
            BagUI.OnXiLianBtnClick()
        end

        if UIDefine.DonateEquipAndPetData["EquipConfig"] then
            for i =1, #UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"] do
                if UIDefine.DonateEquipAndPetData["EquipConfig"]["grade"][i] == itemDB.Grade then

                    if btnName == "捐献" then
                        BagUI.OnDonateBtnClick()
                    end

                end
            end
        end

    elseif tonumber(itemDB.Type) == 6 then

        if btnName == "上交" then
            BagUI.OnHandInBtnClick()
        end

    elseif tonumber(itemDB.Type) == 3 and tonumber(itemDB.Subtype) == 9 then

        if btnName == "镶嵌" then
            BagUI.OnGamSynthesisBtnClick()
        end

    end

end

--强化
function BagUI.OnStrengthenBtnClick()
    GUI.OpenWnd("EquipUI","index:1,index2:3")
    -- EquipUI.OnTabEquipBtnClick()
    -- EquipUI.tabSubIndex = 2
    -- EquipUI.Refresh()
    -- EquipUI.BagOpenUI(2)
    if ItemIndex == 2 then
        EquipEnhanceUI.OnInBagBtnClick()
    end
    EquipEnhanceUI.ClickItem(tostring(NowClick.guid))
end
--修理
function BagUI.OnFixBtnClick()
    GUI.OpenWnd("EquipUI","index:1,index2:1")
    -- EquipUI.OnTabEquipBtnClick()
    -- EquipUI.tabSubIndex = 1
    -- EquipUI.Refresh()
    -- EquipUI.BagOpenUI(1)
    if ItemIndex == 2 then
        EquipRepairUI.OnInBagBtnClick()
    end
    EquipRepairUI.ClickItem(tostring(NowClick.guid))
end
--镶嵌
function BagUI.OnSetBtnClick()
    GUI.OpenWnd("EquipUI","index:2,index2:2")
    -- EquipUI.OnTabGemBtnClick()
    if ItemIndex == 2 then
        EquipGemInlayUI.OnInBagBtnClick()
    end
    EquipGemInlayUI.ClickItem(tostring(NowClick.guid))
end
--捐献
function BagUI.OnDonateBtnClick()
    test("点击捐献自动寻路")
    CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "MoveToNpc")
    BagUI.OnExit()
    -- local npc = DB.GetOnceNpcByKey2("捐献-大将军")
    -- if npc then
    --     LD.StartAutoMove(tonumber(npc.Id))
    --     BagUI.OnExit()
    -- end
end
--交易
function BagUI.OnTransactionBtnClick()

end
--炼药
function BagUI.OnLianYaoBtnClick()
    GUI.OpenWnd("ProduceUI")
    ProduceUI.ResetLastSelectPage(2)
    ProduceUI.GetData()
end
--烹饪
function BagUI.OnCookBtnClick()
    GUI.OpenWnd("ProduceUI")
end
--炼化
function BagUI.OnLianHuaBtnClick()
    GUI.OpenWnd("EquipUI","index:3,index2:3")
    -- EquipUI.OnTabRefineBtnClick()
    if ItemIndex == 2 then
        EquipEffectsUI.OnInBagBtnClick()
    end
    EquipEffectsUI.ClickItem(tostring(NowClick.guid))
end
--宝石合成
function BagUI.OnGamSynthesisBtnClick()
    GUI.OpenWnd("EquipUI","index:2,index2:1,itemId:"..tostring(NowClick.id))
    -- EquipUI.OnTabGemBtnClick()
end

--强化石合成
function BagUI.OnFossilSynthesisClick()
    GUI.OpenWnd("EquipFossilSynthesisUI")
end


--洗炼
function BagUI.OnXiLianBtnClick()
    GUI.OpenWnd("PetEquipRepairUI","2,2,"..TempGuid)
    TempGuid = nil
end

function BagUI.OnRepairClick()
    GUI.OpenWnd("PetEquipRepairUI","1,2,"..TempGuid)
    TempGuid = nil
end

--宠物装备强化
function BagUI.OnQiangHuaBtnClick()
    GUI.OpenWnd("PetEquipRepairUI","1,2,"..TempGuid..",1")
    TempGuid = nil
end


--上交
function BagUI.OnHandInBtnClick()
    -- 云游仙npc ID
    local npc_id = 20066
    CL.StartMove(npc_id, false)
    -- 移动到npc处后执行的回调
    CL.SetMoveEndAction(MoveEndAction.LuaDefine, "BagUI",'_open_hand_in_guard_token_ui', "0")
    -- 关闭背包界面
    BagUI.OnExit()
end
-- 打开上交侍从信物换取奇遇值界面
function BagUI._open_hand_in_guard_token_ui()
    GUI.OpenWnd('HandInGuardTokenUI')
end

function BagUI.OnExchangeBtnClick()
    CL.StartMove("50009")
end

--退出界面
function BagUI.OnExit()
    GUI.CloseWnd("BagUI");
end

function BagUI.OnClose()
    BagUI.UnRegister();
    BagUI.OnTipsClicked();
end

function BagUI.Register()
    CL.RegisterMessage(GM.RefreshBag, "BagUI", "Refresh");
    CL.RegisterMessage(GM.PetInfoUpdate, "BagUI", "RefreshWarehouse");
    CL.RegisterMessage(UM.CloseWhenClicked, "BagUI", "OnTipsClicked");
    CL.RegisterMessage(GM.CustomDataUpdate, "BagUI", "OnCustomDataUpdate")
    -- CL.RegisterMessage(GM.UpdateItem, "BagUI", "ResetBag")
    CL.RegisterMessage(GM.ItemAdd, "BagUI", "OnItemAdd")--AddNewItem

    -- 时装
    --CL.RegisterMessage(GM.AddNewItem, "BagUI", "clothes_message_event")
    CL.RegisterMessage(GM.UpdateItem, "BagUI", "clothes_message_event")
    CL.RegisterMessage(GM.RemoveItem, "BagUI", "clothes_message_event")


    -- 羽翼
    CL.RegisterMessage(GM.AddNewItem, "BagUI", "OnNewItemAdd")
    CL.RegisterMessage(GM.UpdateItem, "BagUI", "wing_message_event")
    CL.RegisterMessage(GM.RemoveItem, "BagUI", "wing_message_event")
end

function BagUI.UnRegister()
    CL.UnRegisterMessage(GM.RefreshBag, "BagUI", "Refresh");
    CL.UnRegisterMessage(GM.PetInfoUpdate, "BagUI", "RefreshWarehouse");
    CL.UnRegisterMessage(UM.CloseWhenClicked, "BagUI", "OnTipsClicked");
    CL.UnRegisterMessage(GM.CustomDataUpdate, "BagUI", "OnCustomDataUpdate")
    -- CL.UnRegisterMessage(GM.UpdateItem, "BagUI", "ResetBag")
    CL.UnRegisterMessage(GM.ItemAdd, "BagUI", "OnItemAdd")

    -- 时装
    CL.UnRegisterMessage(GM.UpdateItem, "BagUI", "clothes_message_event")
    CL.UnRegisterMessage(GM.RemoveItem, "BagUI", "clothes_message_event")

    -- 羽翼
    CL.UnRegisterMessage(GM.AddNewItem, "BagUI", "OnNewItemAdd")
    CL.UnRegisterMessage(GM.UpdateItem, "BagUI", "wing_message_event")
    CL.UnRegisterMessage(GM.RemoveItem, "BagUI", "wing_message_event")


    if BagUI.open then
        FrameTimer.Stop(BagUI.open)
        BagUI.open = nil
    end
end
