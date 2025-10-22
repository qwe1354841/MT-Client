--这是生产系统的UI
local ProduceUI={}

_G.ProduceUI=ProduceUI
local _gt=UILayout.NewGUIDUtilTable()

---------------------------------缓存需要的全局变量Start------------------------------
local GUI=GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
-- local inspect = require("inspect")
-- CDebug.LogError("-------------"..inspect())
local FoodData=nil
local MedicineData=nil
local CurSelectFoodId=0
local CurSelectMedicineId=0
---------------------------------缓存需要的全局变量End-------------------------------

---------------------------------变量Start----------------------------------------
local PageNum={
    cookingPage=1,
    refiningMedicinePage=2
}
local CurSelectPage=nil
local index2 = nil
local fontSize_Btn=26
local IsFirstUseUnBindMaterials=false   --是否优先使用非绑材料
---------------------------------变量End------------------------------------------
local LabelList={
    {"烹饪","cookingTog","OnCookingToggle","cookingPage","CreateCookingPage"},
    {"炼药","refiningMedicineTog","OnRefiningMedicineToggle","refiningMedicinePage","CreateRefiningMedicinePage"}
}

--物品等级图标
local itemGradeImage={
    1801100120,1801100130,1801100140,1801100150,1801100160
}

function ProduceUI.Main()
    _gt=UILayout.NewGUIDUtilTable()
    local panel=GUI.WndCreateWnd("ProduceUI","ProduceUI",0,0,eCanvasGroup.Normal)
    SetAnchorAndPivot(panel,UIAnchor.Center,UIAroundPivot.Center)

    local panelBg=UILayout.CreateFrame_WndStyle0(panel,"生     产","ProduceUI","OnExit",_gt)
    UILayout.CreateRightTab(LabelList,"ProduceUI")
    GUI.SetVisible(panel,false)

    -- 设置默认的小红点
    local foodText = GUI.Get("ProduceUI/panelBg/tabList/cookingTog/text")
    GUI.AddRedPoint(foodText,UIAnchor.TopRight,5,5,"1800208080")
    GUI.SetRedPointVisable(foodText,false)

    local medicineText = GUI.Get("ProduceUI/panelBg/tabList/refiningMedicineTog/text")
    GUI.AddRedPoint(medicineText,UIAnchor.TopRight,5,5,"1800208080")
    GUI.SetRedPointVisable(medicineText,false)

    ProduceUI.refreshRedPoint()
end

function ProduceUI.OnShow(parameter)
    --等级不足时禁止打开
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = MainUI.MainUISwitchConfig["生产"].OpenLevel
	if CurLevel < Level then
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启生产功能")
		return
	end
    local wnd=GUI.GetWnd("ProduceUI")
    if wnd then
        GUI.SetVisible(wnd,true)
    end
    if parameter then
        CurSelectPage, CurSelectFoodId = UIDefine.GetParameterStr(parameter)
        CurSelectPage = tonumber(CurSelectPage)

        if CurSelectPage == 2 then
            CurSelectMedicineId = CurSelectFoodId
            CurSelectFoodId = 0
        end
        --if string.find(parameter,"index") then
        --    CurSelectPage = UIDefine.GetParameterStr(parameter)
        --    CurSelectPage = tonumber(CurSelectPage)
        --end
    else
        CurSelectPage = parameter ~= nil and tonumber(parameter) or 1
    end

    if CurSelectPage ~= 1 and CurSelectPage ~= 2 then
        CurSelectPage = 1
    end

    if CurSelectPage == PageNum.cookingPage then
        CurSelectPage = nil
        ProduceUI.OnCookingToggle()
    elseif CurSelectPage==PageNum.refiningMedicinePage then
        CurSelectPage = nil
        ProduceUI.OnRefiningMedicineToggle()
    end
    -- 活力监听
    CL.UnRegisterAttr(RoleAttr.RoleAttrVp, ProduceUI.ResetVPProduce)
    CL.UnRegisterMessage(GM.RefreshBag, "ProduceUI", "RefreshServerData");
    CL.RegisterAttr(RoleAttr.RoleAttrVp, ProduceUI.ResetVPProduce)
    CL.RegisterMessage(GM.RefreshBag, "ProduceUI", "RefreshServerData");
    -- CDebug.LogError("-------------"..inspect(GlobalProcessing.produce_data))
    ProduceUI.refreshRedPoint()
end

function ProduceUI.OnExit()
    CL.UnRegisterMessage(GM.RefreshBag, "ProduceUI", "RefreshServerData");
    CL.UnRegisterAttr(RoleAttr.RoleAttrVp, ProduceUI.ResetVPProduce)
    GUI.CloseWnd("ProduceUI")
end

function ProduceUI.OnClose()
    ProduceUI.SetLastPageInvisible()
end

function ProduceUI.OnDestroy()
    ProduceUI.OnClose()
end

function ProduceUI.ResetLastSelectPage(index)
    -- test("index==============="..index)

    UILayout.OnTabClick(index,LabelList)
    if CurSelectPage==index then
        return false
    end
    ProduceUI.SetLastPageInvisible()
    CurSelectPage=index
    return true
end


function ProduceUI.SetLastPageInvisible()
    if CurSelectPage then
        local scroll = _gt.GetUI("medicineScroll")
        GUI.ScrollRectSetNormalizedPosition(scroll, Vector2.New(0))
        local scroll2 = _gt.GetUI("foodScroll")
        GUI.ScrollRectSetNormalizedPosition(scroll2, Vector2.New(0))
        local name=LabelList[CurSelectPage][4]
        local lastPage=_gt.GetUI(name)
        if lastPage then
            GUI.SetVisible(lastPage,false)
        end
        CurSelectPage=nil
    end
end

--服务端脚本调用刷新
function ProduceUI.RefreshServerData()
    -- test("服务器数据刷新")
    if CurSelectPage==PageNum.cookingPage then
        ProduceUI.RefreshCookingPage()
    elseif CurSelectPage==PageNum.refiningMedicinePage then
        ProduceUI.RefreshRefiningMedicinePage()
    end
end

function ProduceUI.GetData()
    if CurSelectPage==PageNum.cookingPage then
        CL.SendNotify(NOTIFY.SubmitForm, "FormProduce", "GetProduceFoodData")
    elseif CurSelectPage==PageNum.refiningMedicinePage then
        CL.SendNotify(NOTIFY.SubmitForm, "FormProduce", "GetProduceMedicineData")
    end
end
-------------------------------烹饪Start-------------------------------------------------------
local CurSelectFoodIndex=1
local FoodList=nil
local LabelListRedPointFlag = 0
--初始化数据
function ProduceUI.InitFoodData()
    CurSelectFoodIndex=1
    FoodData=nil
    FoodList=nil
    --CurSelectFoodId=0
    LabelListRedPointFlag = 0
end
function ProduceUI.OnCookingToggle()

    if not ProduceUI.ResetLastSelectPage(PageNum.cookingPage) then
        return
    end
    --CL.SendNotify(NOTIFY.SubmitForm, "FormProduce", "GetProduceFoodData")
    -- test("CurSelectPage"..CurSelectPage)
    ProduceUI.InitFoodData()
    ProduceUI.GetData()
    --ProduceUI.RefreshCookingPage()
    --在 ProduceUI.GetData()中从给服务端获取数据，服务端那边调用了刷新方法

end

function ProduceUI.RefreshCookingPage()
    local pageName=LabelList[PageNum.cookingPage][4]
    local pageBg=_gt.GetUI(pageName)
    if not pageBg then
        pageBg=ProduceUI.CreateCookingPage(pageName)
    else
        GUI.SetVisible(pageBg,true)
    end
    ProduceUI.RefreshCookingPageData()
end

function ProduceUI.RefreshCookingPageData()
    local serverFoodData=ProduceUI.serverFoodData
    if not serverFoodData then
        --test("ServerData不存在")
        return
        --else
        --    test("ServerData存在")
    end
    -- CDebug.LogError(inspect(serverFoodData))
    if not FoodList then
        FoodList={}
        for i, v in pairs(serverFoodData) do
            local tmpFoodId=v.ItemId
            local tmpFoodInfo=v.Info
            local tmpFoodVP=v.VP
            local tmpMaterials={}
            --local index=1
            for j = 1, 3 do
                local tmp={}
                if v["Item"..j]~="" then
                    table.insert(tmp,1,v["Item"..j])
                else
                    break
                end
                if v["ItemNumber"..j]~=0 then
                    table.insert(tmp,2,v["ItemNumber"..j])
                end
                --table.insert(tmp,1,v["Item"..j])
                --table.insert(tmp,2,v["ItemNumber"..j])
                table.insert(tmpMaterials,j,tmp)
            end

            FoodList[i]={}
            FoodList[i].ItemId=nil
            FoodList[i].FoodInfo=nil
            FoodList[i].FoodVP=nil
            FoodList[i].FoodMaterials=nil

            FoodList[i].ItemId=tmpFoodId
            FoodList[i].FoodInfo=tmpFoodInfo
            FoodList[i].FoodVP=tmpFoodVP
            FoodList[i].FoodMaterials=tmpMaterials
        end
    end

    -- CDebug.LogError(inspect(FoodList))
    if not FoodData then
        FoodData={}

        for i, v in pairs(serverFoodData) do
            --test("data的id"..v.Id.."-----------当前的index"..i)
            local tmp=DB.GetOnceItemByKey1(v.ItemId)
            table.insert(FoodData,tmp)
            table.sort(FoodData,function(a, b) return a.Id<b.Id end)
        end
    end

    if CurSelectFoodId ~= 0 then
        for i, v in pairs(serverFoodData) do
            if FoodList[i].ItemId == CurSelectFoodId then
                CurSelectFoodIndex = i
                break
            end
        end
    end
    -- CDebug.LogError(inspect(FoodData))
    local foodScroll=_gt.GetUI("foodScroll")
    if foodScroll then
        GUI.LoopScrollRectSetTotalCount(foodScroll,#FoodData)
        GUI.LoopScrollRectRefreshCells(foodScroll)
       -- GUI.ScrollRectSetNormalizedPosition(foodScroll,Vector2.New(0,0))
    end

    local foodItemDetailBg=_gt.GetUI("foodItemDetailBg")
    local firstUseUnBindMaterials=GUI.GetChild(foodItemDetailBg,"firstUseUnBindMaterials")
    local foodItemDetailIconBg=GUI.GetChild(foodItemDetailBg,"foodItemDetailIconBg")
    local foodItemDetailIcon=GUI.GetChild(foodItemDetailIconBg,"foodItemDetailIcon")
    local foodItemDetailName=GUI.GetChild(foodItemDetailBg,"foodItemDetailName")
    local foodItemDetailTips=GUI.GetChild(foodItemDetailBg,"foodItemDetailTips")
    local foodItemDetailInfo=GUI.GetChild(foodItemDetailBg,"foodItemDetailInfo")
    local cookingTips=GUI.GetChild(foodItemDetailBg,"cookingTips")

    local CurSelectFoodItemData=FoodData[CurSelectFoodIndex]
    local CurSelectFoodListData=FoodList[CurSelectFoodIndex]
    -- CDebug.LogError(inspect(CurSelectFoodListData))
    -- test("CurSelectFoodItemData.Id"..CurSelectFoodItemData.Id)
    if IsFirstUseUnBindMaterials then
        --test("优先使用")
        GUI.CheckBoxSetCheck(firstUseUnBindMaterials,true)
    else
        --test("非优先使用")
        GUI.CheckBoxSetCheck(firstUseUnBindMaterials,false)
    end

    GUI.ImageSetImageID(foodItemDetailIconBg,tostring(itemGradeImage[tonumber(CurSelectFoodItemData.Grade)]))
    GUI.ImageSetImageID(foodItemDetailIcon,tostring(CurSelectFoodItemData.Icon))
    GUI.StaticSetText(foodItemDetailName,CurSelectFoodItemData.Name)
    GUI.StaticSetText(foodItemDetailTips,CurSelectFoodItemData.Tips)
    GUI.StaticSetText(foodItemDetailInfo,CurSelectFoodItemData.Info)

    GUI.StaticSetText(cookingTips,CurSelectFoodListData.FoodInfo)
    --test("材料数量"..#foodIdList[CurSelectFoodIndex].materials)
    --ProduceUI.CreateOrRefreshFoodItemMaterials()
    local materialsGroup=GUI.GetChild(foodItemDetailBg,"materialsGroup")
    local materialsCount=#CurSelectFoodListData.FoodMaterials
    -- test("materialsCount"..materialsCount)
    -- CDebug.LogError(inspect(CurSelectFoodListData.FoodMaterials))

    for i = 1,3 do
        local positionX=0
        local materialsIconBg=GUI.GetChild(materialsGroup,"materialsIconBg"..i)
        local materialsIcon=GUI.GetChild(materialsIconBg,"materialsIcon")
        local materialsAmountTxt=GUI.GetChild(materialsIconBg,"materialsAmountTxt")
        local materialsName=GUI.GetChild(materialsGroup,"materialsName"..i)
        if materialsCount==2 then
            positionX=(i-1)*230-115
        elseif materialsCount==3 then
            positionX=(i-1)*150-150
        end
        GUI.SetPositionX(materialsIconBg,positionX)
        GUI.SetPositionX(materialsName,positionX)
        if i<=materialsCount then
            local materialsData=DB.GetOnceItemByKey2(CurSelectFoodListData.FoodMaterials[i][1])
            local materialsInBagAmount=LD.GetItemCountById(materialsData.Id)

            GUI.SetData(materialsIconBg,"materialsId",materialsData.Id)
            GUI.ImageSetImageID(materialsIconBg,itemGradeImage[tonumber(materialsData.Grade)])
            GUI.ImageSetImageID(materialsIcon,materialsData.Icon)
            GUI.StaticSetText(materialsAmountTxt,materialsInBagAmount.."/"..CurSelectFoodListData.FoodMaterials[i][2])
            GUI.SetIsOutLine(materialsAmountTxt,true);
            GUI.SetOutLine_Color(materialsAmountTxt,UIDefine.BlackColor);
            GUI.SetOutLine_Distance(materialsAmountTxt,1);
            GUI.StaticSetText(materialsName,materialsData.Name)

            if materialsInBagAmount<CurSelectFoodListData.FoodMaterials[i][2] then
                GUI.SetColor(materialsAmountTxt,UIDefine.RedColor)
            else
                GUI.SetColor(materialsAmountTxt,UIDefine.WhiteColor)
            end

            GUI.SetVisible(materialsIconBg,true)
            GUI.SetVisible(materialsIcon,true)
            GUI.SetVisible(materialsAmountTxt,true)
            GUI.SetVisible(materialsName,true)
        else
            GUI.SetVisible(materialsIconBg,false)
            GUI.SetVisible(materialsIcon,false)
            GUI.SetVisible(materialsAmountTxt,false)
            GUI.SetVisible(materialsName,false)
        end
    end

    local cookingPage=_gt.GetUI(LabelList[PageNum.cookingPage][4])
    local consumeEnergyTxt=GUI.GetChild(cookingPage,"consumeEnergyTxt")
    local haveEnergyTxt=GUI.GetChild(cookingPage,"haveEnergyTxt")

    GUI.StaticSetText(consumeEnergyTxt,CurSelectFoodListData.FoodVP)
    local roleVP=CL.GetIntAttr(RoleAttr.RoleAttrVp)
    --test("roleVP"..roleVP)
    if CurSelectFoodListData.FoodVP > roleVP then
        GUI.SetColor(consumeEnergyTxt, UIDefine.RedColor)
    else
        GUI.SetColor(consumeEnergyTxt,UIDefine.Yellow2Color)
    end
    GUI.StaticSetText(haveEnergyTxt,roleVP)
end

--创建烹饪页面
function ProduceUI.CreateCookingPage(pageName)
    -- test("CreateCookingPage")
    local panelBg=_gt.GetUI("panelBg")
    local cookingPage=GUI.GroupCreate(panelBg,pageName,0,0,1197,639)
    _gt.BindName(cookingPage,pageName)
    --烹饪页面的左侧
    --菜品列表
    ProduceUI.CreateFoodScrollList()
    --烹饪页面的右侧
    --菜品详情
    ProduceUI.CreateFoodItemDetail()
    --烹饪页面的右下侧
    --活力消耗提示以及制作按钮
    --活力提示
    local consumeEnergyTips=GUI.CreateStatic(cookingPage,"consumeEnergyTips","消耗活力",-160,-20,100,50)
    GUI.StaticSetFontSize(consumeEnergyTips,UIDefine.FontSizeM)
    GUI.SetColor(consumeEnergyTips,UIDefine.BrownColor)
    GUI.StaticSetAlignment(consumeEnergyTips,TextAnchor.MiddleCenter)
    SetAnchorAndPivot(consumeEnergyTips,UIAnchor.Bottom,UIAroundPivot.Bottom)
    local consumeEnergyTxt=GUI.CreateStatic(cookingPage,"consumeEnergyTxt","32",-90,-20,100,50)
    GUI.StaticSetFontSize(consumeEnergyTxt,UIDefine.FontSizeM)
    GUI.SetColor(consumeEnergyTxt,UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(consumeEnergyTxt,TextAnchor.MiddleCenter)
    _gt.BindName(consumeEnergyTxt, "consumeEnergyTxt");
    SetAnchorAndPivot(consumeEnergyTxt,UIAnchor.Bottom,UIAroundPivot.Bottom)
    local haveEnergyTips=GUI.CreateStatic(cookingPage,"haveEnergyTips","拥有活力",60,-20,100,50)
    GUI.StaticSetFontSize(haveEnergyTips,UIDefine.FontSizeM)
    GUI.SetColor(haveEnergyTips,UIDefine.BrownColor)
    GUI.StaticSetAlignment(haveEnergyTips,TextAnchor.MiddleCenter)
    SetAnchorAndPivot(haveEnergyTips,UIAnchor.Bottom,UIAroundPivot.Bottom)
    local haveEnergyTxt=GUI.CreateStatic(cookingPage,"haveEnergyTxt","1200",150,-20,100,50)
    GUI.StaticSetFontSize(haveEnergyTxt,UIDefine.FontSizeM)
    GUI.SetColor(haveEnergyTxt,UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(haveEnergyTxt,TextAnchor.MiddleCenter)
    SetAnchorAndPivot(haveEnergyTxt,UIAnchor.Bottom,UIAroundPivot.Bottom)
    --制作按钮
    local makeBtn = GUI.ButtonCreate(cookingPage, "makeBtn", "1800102090", -80, -30, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">制造</size></color>", 160, 45, false);
    SetAnchorAndPivot(makeBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetIsOutLine(makeBtn,true);
    GUI.SetOutLine_Color(makeBtn,Color.New(162/255,75/255,21/255));
    GUI.SetOutLine_Distance(makeBtn,1);
    GUI.RegisterUIEvent(makeBtn, UCE.PointerClick, "ProduceUI", "OnMakeBtnClick")
end
--创建food循环列表
--利用loopScrollRectCreate
function ProduceUI.CreateFoodScrollList()
    -- test("CreateFoodScrollList")
    local cookingPage=_gt.GetUI(LabelList[PageNum.cookingPage][4])
    --背景图片
    local foodScrollList_Bg=GUI.ImageCreate(cookingPage,"foodScrollList_Bg","1800400200",85,10,false,275,560)
    SetAnchorAndPivot(foodScrollList_Bg,UIAnchor.Left,UIAroundPivot.Left)
    --循环列表
    local foodChildVecSize=Vector2.New(270,100)
    local foodScroll=GUI.LoopScrollRectCreate(foodScrollList_Bg,"foodScroll",7,0,260,545,
    "ProduceUI","CreateFoodItem","ProduceUI","RefreshFoodItem",1,false,
            foodChildVecSize,1,UIAroundPivot.Top,UIAnchor.Top)
    _gt.BindName(foodScroll,"foodScroll")
    GUI.ScrollRectSetChildSpacing(foodScroll,Vector2.New(0,0))
end

--loopScrollRectCreate中的创建方法
function ProduceUI.CreateFoodItem()
    --test("CreateFoodItem")
    local foodScroll=_gt.GetUI("foodScroll")
    local curCount=GUI.LoopScrollRectGetChildInPoolCount(foodScroll)
    --test("curCount = "..curCount)
    local foodItem=GUI.CheckBoxExCreate(foodScroll,"foodItem"..curCount,"1800700030","1800700040",0,10,false,270,100)
    local foodItemIconBg=GUI.ImageCreate(foodItem,"foodItemIconBg","",10,0,false,80,80)
    GUI.AddRedPoint(foodItemIconBg, UIAnchor.TopLeft, 5, 5, "1800208080")
    GUI.SetRedPointVisable(foodItemIconBg, false)
    SetAnchorAndPivot(foodItemIconBg,UIAnchor.Left,UIAroundPivot.Left)
    local foodItemIcon=GUI.ImageCreate(foodItemIconBg,"foodItemIcon","",0,0,false,60,60)
    SetAnchorAndPivot(foodItemIcon,UIAnchor.Center,UIAroundPivot.Center)
    local foodItemName=GUI.CreateStatic(foodItem,"foodItemName","",-20,0,150,50)
    GUI.SetColor(foodItemName, UIDefine.BrownColor)
    GUI.StaticSetFontSize(foodItemName, UIDefine.FontSizeM)
    SetAnchorAndPivot(foodItemName,UIAnchor.TopRight,UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(foodItem,UCE.PointerClick,"ProduceUI","OnFoodItemClick")
    return foodItem
end
--loopScrollRectCreate中的刷新方法
function ProduceUI.RefreshFoodItem(parameter)
    --local foodScroll=_gt.GetUI("foodScroll")
    -- test("RefreshFoodItem")
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local foodItem=GUI.GetByGuid(guid)
    --test("Refreshindex"..index)
    if not FoodData then
        return
    end
    local foodItemData=FoodData[index]

    GUI.SetData(foodItem,"foodItemId",foodItemData.Id)
    local foodItemIconBg=GUI.GetChild(foodItem,"foodItemIconBg")
    local foodItemIcon=GUI.GetChild(foodItem,"foodItemIcon")
    local foodItemName=GUI.GetChild(foodItem,"foodItemName")

    GUI.ImageSetImageID(foodItemIconBg,itemGradeImage[tonumber(foodItemData.Grade)])
    GUI.ImageSetImageID(foodItemIcon,foodItemData.Icon)
    --CDebug.LogError(inspect(foodItemData.Icon))
    GUI.StaticSetText(foodItemName,foodItemData.Name)
    if CurSelectFoodIndex==index then
        CurSelectFoodId=foodItemData.Id
        GUI.CheckBoxExSetCheck(foodItem,true)
    else
        GUI.CheckBoxExSetCheck(foodItem,false)
    end
-----------------------------添加小红点------------------------------------------------------
    local text = GUI.Get("ProduceUI/panelBg/tabList/cookingTog/text")
    GUI.SetRedPointVisable(text, false)
    local CurSelectFoodListData=FoodList[index]
    local roleVP=CL.GetIntAttr(RoleAttr.RoleAttrVp)
    local materialsCount=#CurSelectFoodListData.FoodMaterials
    local redPointFlag = 0

    for i = 1, materialsCount do
        local materialsData=DB.GetOnceItemByKey2(CurSelectFoodListData.FoodMaterials[i][1])
        local materialsInBagAmount=LD.GetItemCountById(materialsData.Id)

        if CurSelectFoodListData["FoodMaterials"][i][2] <= materialsInBagAmount then
            redPointFlag = redPointFlag + 1
        end
    end

    if redPointFlag == materialsCount and  roleVP >= CurSelectFoodListData.FoodVP then
        GUI.SetRedPointVisable(foodItemIconBg, true)
        LabelListRedPointFlag = LabelListRedPointFlag + 1
    else
        GUI.SetRedPointVisable(foodItemIconBg, false)
    end

    if LabelListRedPointFlag ~= 0 then
        GUI.SetRedPointVisable(text, true)
    else
        GUI.SetRedPointVisable(text, false)
    end
-----------------------------------------------------------------------------------
end

function ProduceUI.OnFoodItemClick(guid)
    --test("guid"..guid)
    local foodItem=GUI.GetByGuid(guid)
    local index=GUI.CheckBoxExGetIndex(foodItem)+1
    local foodItemId=GUI.GetData(foodItem,"foodItemId")
    --test("OnFoodItemClickIndex=="..index)
    CurSelectFoodId=foodItemId
    CurSelectFoodIndex=index
    ProduceUI.RefreshCookingPageData()
end
--创建食物详情
function ProduceUI.CreateFoodItemDetail()
    local cookingPage=_gt.GetUI(LabelList[PageNum.cookingPage][4])
    --背景图片
    local foodItemDetailBg=GUI.ImageCreate(cookingPage,"foodItemDetailBg","1800400200",150,-25,false,740,490)
    SetAnchorAndPivot(foodItemDetailBg,UIAnchor.Center,UIAroundPivot.Center)
    _gt.BindName(foodItemDetailBg,"foodItemDetailBg")
    --优先使用非绑材料checkbox
    local firstUseUnBindMaterials = GUI.CheckBoxCreate(foodItemDetailBg, "firstUseUnBindMaterials", "1800607150", "1800607151", -210, 5, Transition.None, false, 35, 35)
    SetAnchorAndPivot(firstUseUnBindMaterials, UIAnchor.TopRight, UIAroundPivot.TopRight)
    --GUI.CheckBoxSetCheck(firstUseUnBindMaterials,false);
    GUI.RegisterUIEvent(firstUseUnBindMaterials, UCE.PointerClick, "ProduceUI", "OnFirstUseUnBindMaterialsClick");
    --优先使用非绑材料文字
    local firstUseUnBindMaterialsLabel = GUI.CreateStatic(firstUseUnBindMaterials, "firstUseUnBindMaterialsLabel", "优先使用非绑材料", -40, 0, 200, 30)
    GUI.StaticSetFontSize(firstUseUnBindMaterialsLabel, UIDefine.FontSizeM);
    SetAnchorAndPivot(firstUseUnBindMaterialsLabel, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(firstUseUnBindMaterialsLabel, UIDefine.BrownColor);
    --食物图标背景
    local foodItemDetailIconBg=GUI.ImageCreate(foodItemDetailBg,"foodItemDetailIconBg","",0,35,false,80,80)
    SetAnchorAndPivot(foodItemDetailIconBg,UIAnchor.Top,UIAroundPivot.Top)
    --食物图标icon
    local foodItemDetailIcon=GUI.ImageCreate(foodItemDetailIconBg,"foodItemDetailIcon","",0,0,false,60,60)
    SetAnchorAndPivot(foodItemDetailIcon,UIAnchor.Center,UIAroundPivot.Center)

    local foodItemDetailName=GUI.CreateStatic(foodItemDetailBg,"foodItemDetailName","食物名字",0,-115,200,50)
    GUI.StaticSetFontSize(foodItemDetailName,UIDefine.FontSizeL)
    GUI.SetColor(foodItemDetailName,UIDefine.BrownColor)
    GUI.StaticSetAlignment(foodItemDetailName,TextAnchor.MiddleCenter)

    local foodItemDetailTips=GUI.CreateStatic(foodItemDetailBg,"foodItemDetailTips","食物小提示",0,-65,700,50)
    GUI.StaticSetFontSize(foodItemDetailTips,UIDefine.FontSizeM)
    GUI.SetColor(foodItemDetailTips,UIDefine.BrownColor)
    GUI.StaticSetAlignment(foodItemDetailTips,TextAnchor.MiddleCenter)
    --SetAnchorAndPivot(foodItemDetailTips,UIAnchor.Center,UIAroundPivot.Center)


    local foodItemDetailInfo=GUI.CreateStatic(foodItemDetailBg,"foodItemDetailInfo","食物信息",0,0,700,100)
    GUI.StaticSetFontSize(foodItemDetailInfo,UIDefine.FontSizeL)
    GUI.SetColor(foodItemDetailInfo,UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(foodItemDetailInfo,TextAnchor.MiddleCenter)

    local cutLine1 = GUI.ImageCreate(foodItemDetailBg, "cutLine1", "1800700060", 0, 30, false, 740, 1);
    SetAnchorAndPivot(cutLine1, UIAnchor.Center, UIAroundPivot.Center)

    local cookingTips=GUI.CreateStatic(foodItemDetailBg,"cookingTips","你当前的等级能够",0,70,700,50)
    GUI.StaticSetFontSize(cookingTips,UIDefine.FontSizeM)
    GUI.SetColor(cookingTips,UIDefine.BrownColor)
    GUI.StaticSetAlignment(cookingTips,TextAnchor.MiddleCenter)
    --创建食物材料
    --ProduceUI.CreateOrRefreshFoodItemMaterials()
    ProduceUI.CreateFoodItemMaterials()
end
--创建食物详情中的材料
function ProduceUI.CreateFoodItemMaterials()
    local foodItemDetailBg=_gt.GetUI("foodItemDetailBg")
    if not  foodItemDetailBg then
        return
    end
    local materialsGroup=GUI.GroupCreate(foodItemDetailBg,"materialsGroup",0,150,500,100)
    SetAnchorAndPivot(materialsGroup, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(materialsGroup,"materialsGroup")
    --test("#FoodList[CurSelectFoodIndex].FoodMaterials=="..#FoodList[CurSelectFoodIndex].FoodMaterials)
    for i = 1, 3 do
        local materialsIconBg=GUI.ImageCreate(materialsGroup,"materialsIconBg"..i,"",(i-1)*150-150,0,false,90,90)
        GUI.SetIsRaycastTarget(materialsIconBg, true)
        materialsIconBg:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(materialsIconBg,UCE.PointerClick,"ProduceUI","OnMaterialsClick")
        local materialsIcon=GUI.ImageCreate(materialsIconBg,"materialsIcon","",0,0,false,60,60)
        local materialsAmountTxt=GUI.CreateStatic(materialsIconBg,"materialsAmountTxt","0/2",-10,8,90,50)
        GUI.StaticSetFontSize(materialsAmountTxt,UIDefine.FontSizeM)
        SetAnchorAndPivot(materialsAmountTxt,UIAnchor.BottomRight,UIAroundPivot.BottomRight)
        GUI.StaticSetAlignment(materialsAmountTxt,TextAnchor.MiddleRight)
        local materialsName=GUI.CreateStatic(materialsGroup,"materialsName"..i,"材料"..i,(i-1)*150-150,60,100,50)
        GUI.StaticSetFontSize(materialsName,UIDefine.FontSizeM)
        GUI.SetColor(materialsName,UIDefine.BrownColor)
        GUI.StaticSetAlignment(materialsName,TextAnchor.MiddleCenter)

    end
end
function ProduceUI.OnMaterialsClick(guid)
    --test("click")
    local materialsItem=GUI.GetByGuid(guid)
    local materialsId=GUI.GetData(materialsItem,"materialsId")
    --test("materialsId"..materialsId)
    ProduceUI.MaterialsTips(materialsId)
end

-------------------------------烹饪End---------------------------------------------------------

-------------------------------炼药Start-------------------------------------------------------
local CurSelectMedicineIndex=1

local MedicineList=nil
local LabelListRedPointFlag2 = 0
--初始化药物数据
function ProduceUI.InitMedicineData()
    CurSelectMedicineIndex=1
    MedicineData=nil
    MedicineList=nil
    --CurSelectMedicineId=0
    LabelListRedPointFlag2 = 0
end
function ProduceUI.OnRefiningMedicineToggle()

    if not ProduceUI.ResetLastSelectPage(PageNum.refiningMedicinePage) then
        return
    end
    -- test("执行到第二页面")
    -- test("CurSelectPage"..CurSelectPage)
    ProduceUI.InitMedicineData()
    ProduceUI.GetData()
end

function ProduceUI.RefreshRefiningMedicinePage()
    local pageName=LabelList[PageNum.refiningMedicinePage][4]
    local pageBg=_gt.GetUI(pageName)
    if not pageBg then
        pageBg=ProduceUI.CreateRefiningMedicinePage(pageName)
    else
        GUI.SetVisible(pageBg,true)
    end
    ProduceUI.RefreshRefiningMedicinePageData()
end

function ProduceUI.RefreshRefiningMedicinePageData()
    --test("CurSelectFoodIndex"..CurSelectFoodIndex)
    --test("CurSelectFoodId"..CurSelectFoodId)
    --local itemRandomLevel=ProduceUI.itemRandomLevel
    --if itemRandomLevel then
    --    test("ProduceUI.itemRandomLevel"..ProduceUI.itemRandomLevel)
    --end

    local serverMedicineData=ProduceUI.serverMedicineData
    if not serverMedicineData then
        --test("ServerData不存在")
        return
        --else
        --    test("ServerData存在")
    end
    --CDebug.LogError(inspect(serverMedicineData))

    if  not MedicineList then
        MedicineList={}
        for i, v in pairs(serverMedicineData) do
            local tmpMedicineId=v.ItemId
            local tmpMedicineInfo=v.Info
            local tmpMedicineVP=v.VP
            local tmpMaterials={}
            --local index=1
            for j = 1, 3 do
                local tmp={}
                if v["Item"..j]~="" then
                    table.insert(tmp,1,v["Item"..j])
                else
                    --因为lua中没有continue,所以使用goto方法实现continue效果
                    --ps.没有continue 这TMD的什么语言好垃圾啊
                    goto continue
                end
                if v["ItemNumber"..j]~=0 then
                    table.insert(tmp,2,v["ItemNumber"..j])
                end
                --table.insert(tmp,1,v["Item"..j])
                --table.insert(tmp,2,v["ItemNumber"..j])
                table.insert(tmpMaterials,j,tmp)
                ::continue::
            end
            MedicineList[i]={}
            MedicineList[i].ItemId=nil
            MedicineList[i].MedicineInfo=nil
            MedicineList[i].MedicineVP=nil
            MedicineList[i].MedicineMaterials=nil

            MedicineList[i].ItemId=tmpMedicineId
            MedicineList[i].MedicineInfo=tmpMedicineInfo
            MedicineList[i].MedicineVP=tmpMedicineVP
            MedicineList[i].MedicineMaterials=tmpMaterials
        end
    end

    --CDebug.LogError(inspect(MedicineList))
    if not MedicineData then
        MedicineData={}

        for i, v in pairs(serverMedicineData) do
            --test("data的id"..v.Id.."-----------当前的index"..i)
            local tmp=DB.GetOnceItemByKey1(v.ItemId)
            table.insert(MedicineData,tmp)
            table.sort(MedicineData,function(a, b) return a.Id<b.Id end)
        end
    end

    if CurSelectMedicineId ~= 0 then
        for i, v in pairs(serverMedicineData) do
            if MedicineList[i].ItemId == CurSelectMedicineId then
                CurSelectMedicineIndex = i
                break
            end
        end
    end
    --CDebug.LogError(inspect(MedicineData))
    local medicineScroll=_gt.GetUI("medicineScroll")
    if medicineScroll then
        GUI.LoopScrollRectSetTotalCount(medicineScroll,#MedicineData)
        GUI.LoopScrollRectRefreshCells(medicineScroll)
        -- GUI.ScrollRectSetNormalizedPosition(foodScroll,Vector2.New(0,0))
    end

    local medicineItemDetailBg=_gt.GetUI("medicineItemDetailBg")
    local firstUseUnBindMaterials=GUI.GetChild(medicineItemDetailBg,"firstUseUnBindMaterials")
    local medicineItemDetailIconBg=GUI.GetChild(medicineItemDetailBg,"medicineItemDetailIconBg")
    local medicineItemDetailIcon=GUI.GetChild(medicineItemDetailIconBg,"medicineItemDetailIcon")
    local medicineItemDetailName=GUI.GetChild(medicineItemDetailBg,"medicineItemDetailName")
    local medicineItemDetailTips=GUI.GetChild(medicineItemDetailBg,"medicineItemDetailTips")
    local medicineItemDetailInfo=GUI.GetChild(medicineItemDetailBg,"medicineItemDetailInfo")
    local medicineTips=GUI.GetChild(medicineItemDetailBg,"medicineTips")

    local CurSelectMedicineItemData=MedicineData[CurSelectMedicineIndex]
    local CurSelectMedicineListData=MedicineList[CurSelectMedicineIndex]
    --CDebug.LogError(inspect(CurSelectFoodListData))
    --test("CurSelectFoodItemData.Id"..CurSelectFoodItemData.Id)
    if IsFirstUseUnBindMaterials then
        --test("优先使用")
        GUI.CheckBoxSetCheck(firstUseUnBindMaterials,true)
    else
        --test("非优先使用")
        GUI.CheckBoxSetCheck(firstUseUnBindMaterials,false)
    end

    GUI.ImageSetImageID(medicineItemDetailIconBg,tostring(itemGradeImage[tonumber(CurSelectMedicineItemData.Grade)]))
    GUI.ImageSetImageID(medicineItemDetailIcon,tostring(CurSelectMedicineItemData.Icon))
    GUI.StaticSetText(medicineItemDetailName,CurSelectMedicineItemData.Name)
    GUI.StaticSetText(medicineItemDetailTips,CurSelectMedicineItemData.Tips)
    GUI.StaticSetText(medicineItemDetailInfo,CurSelectMedicineItemData.Info)

    GUI.StaticSetText(medicineTips,CurSelectMedicineListData.MedicineInfo)
    --test("材料数量"..#foodIdList[CurSelectFoodIndex].materials)
    --ProduceUI.CreateOrRefreshFoodItemMaterials()
    local medicineMaterialsGroup=GUI.GetChild(medicineItemDetailBg,"medicineMaterialsGroup")
    local materialsCount=#CurSelectMedicineListData.MedicineMaterials
    --test("materialsCount"..materialsCount)
    --CDebug.LogError(inspect(CurSelectFoodListData.FoodMaterials))
    for i = 1,3 do
        local positionX=0
        local materialsIconBg=GUI.GetChild(medicineMaterialsGroup,"materialsIconBg"..i)
        local materialsIcon=GUI.GetChild(materialsIconBg,"materialsIcon")
        local materialsAmountTxt=GUI.GetChild(materialsIconBg,"materialsAmountTxt")
        local materialsName=GUI.GetChild(medicineMaterialsGroup,"materialsName"..i)
        if materialsCount==2 then
            positionX=(i-1)*230-115
        elseif materialsCount==3 then
            positionX=(i-1)*150-150
        end
        GUI.SetPositionX(materialsIconBg,positionX)
        GUI.SetPositionX(materialsName,positionX)
        if i<=materialsCount then
            local materialsData=DB.GetOnceItemByKey2(CurSelectMedicineListData.MedicineMaterials[i][1])
            local materialsInBagAmount=LD.GetItemCountById(materialsData.Id)
            GUI.SetData(materialsIconBg,"materialsId",materialsData.Id)
            GUI.ImageSetImageID(materialsIconBg,itemGradeImage[tonumber(materialsData.Grade)])
            GUI.ImageSetImageID(materialsIcon,materialsData.Icon)
            GUI.StaticSetText(materialsAmountTxt,materialsInBagAmount.."/"..CurSelectMedicineListData.MedicineMaterials[i][2])
            GUI.SetIsOutLine(materialsAmountTxt,true);
            GUI.SetOutLine_Color(materialsAmountTxt,UIDefine.BlackColor);
            GUI.SetOutLine_Distance(materialsAmountTxt,1);
            GUI.StaticSetText(materialsName,materialsData.Name)

            if materialsInBagAmount<CurSelectMedicineListData.MedicineMaterials[i][2] then
                GUI.SetColor(materialsAmountTxt,UIDefine.RedColor)
            else
                GUI.SetColor(materialsAmountTxt,UIDefine.WhiteColor)
            end

            GUI.SetVisible(materialsIconBg,true)
            GUI.SetVisible(materialsIcon,true)
            GUI.SetVisible(materialsAmountTxt,true)
            GUI.SetVisible(materialsName,true)
        else
            GUI.SetVisible(materialsIconBg,false)
            GUI.SetVisible(materialsIcon,false)
            GUI.SetVisible(materialsAmountTxt,false)
            GUI.SetVisible(materialsName,false)
        end
    end

    local refiningMedicinePage=_gt.GetUI(LabelList[PageNum.refiningMedicinePage][4])
    local consumeEnergyTxt=GUI.GetChild(refiningMedicinePage,"consumeEnergyTxt")
    local haveEnergyTxt=GUI.GetChild(refiningMedicinePage,"haveEnergyTxt")

    GUI.StaticSetText(consumeEnergyTxt,CurSelectMedicineListData.MedicineVP)
    local roleVP=CL.GetIntAttr(RoleAttr.RoleAttrVp)
    --test("roleVP"..roleVP)
    GUI.StaticSetText(haveEnergyTxt,roleVP)
    if CurSelectMedicineListData.MedicineVP > roleVP then
        GUI.SetColor(consumeEnergyTxt, UIDefine.RedColor)
    else
        GUI.SetColor(consumeEnergyTxt, UIDefine.Yellow2Color)
    end

end
--创建炼药页面
function ProduceUI.CreateRefiningMedicinePage(pageName)
    -- test("CreateMedicinePage")
    local panelBg=_gt.GetUI("panelBg")
    local refiningMedicinePage=GUI.GroupCreate(panelBg,pageName,0,0,1197,639)
    _gt.BindName(refiningMedicinePage,pageName)
    --烹饪页面的左侧
    --菜品列表
    ProduceUI.CreateMedicineScrollList()
    --烹饪页面的右侧
    --菜品详情
    ProduceUI.CreateMedicineItemDetail()
    --烹饪页面的右下侧
    --活力消耗提示以及制作按钮
    --活力提示
    local consumeEnergyTips=GUI.CreateStatic(refiningMedicinePage,"consumeEnergyTips","消耗活力",-160,-20,100,50)
    GUI.StaticSetFontSize(consumeEnergyTips,UIDefine.FontSizeM)
    GUI.SetColor(consumeEnergyTips,UIDefine.BrownColor)
    GUI.StaticSetAlignment(consumeEnergyTips,TextAnchor.MiddleCenter)
    SetAnchorAndPivot(consumeEnergyTips,UIAnchor.Bottom,UIAroundPivot.Bottom)
    local consumeEnergyTxt=GUI.CreateStatic(refiningMedicinePage,"consumeEnergyTxt","32",-90,-20,100,50)
    GUI.StaticSetFontSize(consumeEnergyTxt,UIDefine.FontSizeM)
    GUI.SetColor(consumeEnergyTxt,UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(consumeEnergyTxt,TextAnchor.MiddleCenter)
    SetAnchorAndPivot(consumeEnergyTxt,UIAnchor.Bottom,UIAroundPivot.Bottom)
    local haveEnergyTips=GUI.CreateStatic(refiningMedicinePage,"haveEnergyTips","拥有活力",60,-20,100,50)
    GUI.StaticSetFontSize(haveEnergyTips,UIDefine.FontSizeM)
    GUI.SetColor(haveEnergyTips,UIDefine.BrownColor)
    GUI.StaticSetAlignment(haveEnergyTips,TextAnchor.MiddleCenter)
    SetAnchorAndPivot(haveEnergyTips,UIAnchor.Bottom,UIAroundPivot.Bottom)
    local haveEnergyTxt=GUI.CreateStatic(refiningMedicinePage,"haveEnergyTxt","1200",150,-20,100,50)
    GUI.StaticSetFontSize(haveEnergyTxt,UIDefine.FontSizeM)
    GUI.SetColor(haveEnergyTxt,UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(haveEnergyTxt,TextAnchor.MiddleCenter)
    SetAnchorAndPivot(haveEnergyTxt,UIAnchor.Bottom,UIAroundPivot.Bottom)
    --制作按钮
    local makeBtn = GUI.ButtonCreate(refiningMedicinePage, "makeBtn", "1800102090", -80, -30, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_Btn .. ">制造</size></color>", 160, 45, false);
    SetAnchorAndPivot(makeBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetIsOutLine(makeBtn,true);
    GUI.SetOutLine_Color(makeBtn,Color.New(162/255,75/255,21/255));
    GUI.SetOutLine_Distance(makeBtn,1);
    GUI.RegisterUIEvent(makeBtn, UCE.PointerClick, "ProduceUI", "OnMakeBtnClick")
end
--创建food循环列表
--利用loopScrollRectCreate
function ProduceUI.CreateMedicineScrollList()
    --test("CreateFoodScrollList")
    local refiningMedicinePage=_gt.GetUI(LabelList[PageNum.refiningMedicinePage][4])
    --背景图片
    local medicineScrollList_Bg=GUI.ImageCreate(refiningMedicinePage,"medicineScrollList_Bg","1800400200",85,10,false,275,560)
    SetAnchorAndPivot(medicineScrollList_Bg,UIAnchor.Left,UIAroundPivot.Left)
    --循环列表
    local medicineChildVecSize=Vector2.New(270,100)
    local medicineScroll=GUI.LoopScrollRectCreate(medicineScrollList_Bg,"medicineScroll",7,0,260,545,
            "ProduceUI","CreateMedicineItem","ProduceUI","RefreshMedicineItem",1,false,
            medicineChildVecSize,1,UIAroundPivot.Top,UIAnchor.Top)
    _gt.BindName(medicineScroll,"medicineScroll")
    GUI.ScrollRectSetChildSpacing(medicineScroll,Vector2.New(0,0))


end
--loopScrollRectCreate中的创建方法
function ProduceUI.CreateMedicineItem()
    --test("CreateFoodItem")
    local medicineScroll=_gt.GetUI("medicineScroll")
    local curCount=GUI.LoopScrollRectGetChildInPoolCount(medicineScroll)
    --test("curCount = "..curCount)
    local medicineItem=GUI.CheckBoxExCreate(medicineScroll,"medicineItem"..curCount,"1800700030","1800700040",0,10,false,270,100)
    local medicineItemIconBg=GUI.ImageCreate(medicineItem,"medicineItemIconBg","",10,0,false,80,80)
    GUI.AddRedPoint(medicineItemIconBg, UIAnchor.TopLeft, 5, 5, "1800208080")
    GUI.SetRedPointVisable(medicineItemIconBg, false)
    SetAnchorAndPivot(medicineItemIconBg,UIAnchor.Left,UIAroundPivot.Left)
    local medicineItemIcon=GUI.ImageCreate(medicineItemIconBg,"medicineItemIcon","",0,0,false,60,60)
    SetAnchorAndPivot(medicineItemIcon,UIAnchor.Center,UIAroundPivot.Center)
    local medicineItemName=GUI.CreateStatic(medicineItem,"medicineItemName","",-20,0,150,50)
    GUI.SetColor(medicineItemName, UIDefine.BrownColor)
    GUI.StaticSetFontSize(medicineItemName, UIDefine.FontSizeM)
    SetAnchorAndPivot(medicineItemName,UIAnchor.TopRight,UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(medicineItem,UCE.PointerClick,"ProduceUI","OnMedicineItemClick")
    return medicineItem
end
--loopScrollRectCreate中的刷新方法
function ProduceUI.RefreshMedicineItem(parameter)
    --local foodScroll=_gt.GetUI("foodScroll")
    --test("RefreshFoodItem")
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local medicineItem=GUI.GetByGuid(guid)
    --test("Refreshindex"..index)

    if not MedicineData then
        return
    end
    local medicineItemData=MedicineData[index]

    GUI.SetData(medicineItem,"medicineMaterialsId",medicineItemData.Id)

    local medicineItemIconBg=GUI.GetChild(medicineItem,"medicineItemIconBg")
    local medicineItemIcon=GUI.GetChild(medicineItem,"medicineItemIcon")
    local medicineItemName=GUI.GetChild(medicineItem,"medicineItemName")

    GUI.ImageSetImageID(medicineItemIconBg,itemGradeImage[tonumber(medicineItemData.Grade)])
    GUI.ImageSetImageID(medicineItemIcon,medicineItemData.Icon)
    --CDebug.LogError(inspect(foodItemData.Icon))
    GUI.StaticSetText(medicineItemName,medicineItemData.Name)
    if CurSelectMedicineIndex==index then
        CurSelectMedicineId=medicineItemData.Id

        GUI.CheckBoxExSetCheck(medicineItem,true)
    else
        GUI.CheckBoxExSetCheck(medicineItem,false)
    end

    -----------------------------添加小红点------------------------------------------------------
    local text = GUI.Get("ProduceUI/panelBg/tabList/refiningMedicineTog/text")
    GUI.SetRedPointVisable(text, false)
    local CurSelectMedicineListData=MedicineList[index]
    local roleVP=CL.GetIntAttr(RoleAttr.RoleAttrVp)
    local materialsCount=#CurSelectMedicineListData.MedicineMaterials
    local redPointFlag = 0

    for i = 1, materialsCount do
        local materialsData=DB.GetOnceItemByKey2(CurSelectMedicineListData.MedicineMaterials[i][1])
        local materialsInBagAmount=LD.GetItemCountById(materialsData.Id)

        if CurSelectMedicineListData.MedicineMaterials[i][2] <= materialsInBagAmount then
            redPointFlag = redPointFlag + 1
        end
    end

    if redPointFlag == materialsCount and roleVP >= CurSelectMedicineListData.MedicineVP then
        GUI.SetRedPointVisable(medicineItemIconBg, true)
        LabelListRedPointFlag2 = LabelListRedPointFlag2 + 1
    else
        GUI.SetRedPointVisable(medicineItemIconBg, false)
    end


    if LabelListRedPointFlag2 ~= 0 then
        GUI.SetRedPointVisable(text, true)
    else
        GUI.SetRedPointVisable(text, false)
    end
    -----------------------------------------------------------------------------------
end

function ProduceUI.OnMedicineItemClick(guid)
    --test("guid"..guid)
    local medicineItem=GUI.GetByGuid(guid)
    local index=GUI.CheckBoxExGetIndex(medicineItem)+1
    local medicineItemId=GUI.GetData(medicineItem,"medicineItemId")
    --test("OnFoodItemClickIndex=="..index)
    --CurSelectFoodId=foodItemId
    CurSelectMedicineIndex=index
    ProduceUI.RefreshRefiningMedicinePage()
end
--创建药详情
function ProduceUI.CreateMedicineItemDetail()
    local refiningMedicinePage=_gt.GetUI(LabelList[PageNum.refiningMedicinePage][4])
    --背景图片
    local medicineItemDetailBg=GUI.ImageCreate(refiningMedicinePage,"medicineItemDetailBg","1800400200",150,-25,false,740,490)
    SetAnchorAndPivot(medicineItemDetailBg,UIAnchor.Center,UIAroundPivot.Center)
    _gt.BindName(medicineItemDetailBg,"medicineItemDetailBg")
    --优先使用非绑材料checkbox
    local firstUseUnBindMaterials = GUI.CheckBoxCreate(medicineItemDetailBg, "firstUseUnBindMaterials", "1800607150", "1800607151", -210, 5, Transition.None, false, 35, 35)
    SetAnchorAndPivot(firstUseUnBindMaterials, UIAnchor.TopRight, UIAroundPivot.TopRight)
    --GUI.CheckBoxSetCheck(firstUseUnBindMaterials,false);
    GUI.RegisterUIEvent(firstUseUnBindMaterials, UCE.PointerClick, "ProduceUI", "OnFirstUseUnBindMaterialsClick");
    --优先使用非绑材料文字
    local firstUseUnBindMaterialsLabel = GUI.CreateStatic(firstUseUnBindMaterials, "firstUseUnBindMaterialsLabel", "优先使用非绑材料", -40, 0, 200, 30)
    GUI.StaticSetFontSize(firstUseUnBindMaterialsLabel, UIDefine.FontSizeM);
    SetAnchorAndPivot(firstUseUnBindMaterialsLabel, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(firstUseUnBindMaterialsLabel, UIDefine.BrownColor);
    --食物图标背景
    local medicineItemDetailIconBg=GUI.ImageCreate(medicineItemDetailBg,"medicineItemDetailIconBg","",0,35,false,80,80)
    SetAnchorAndPivot(medicineItemDetailIconBg,UIAnchor.Top,UIAroundPivot.Top)
    --食物图标icon
    local medicineItemDetailIcon=GUI.ImageCreate(medicineItemDetailIconBg,"medicineItemDetailIcon","",0,0,false,60,60)
    SetAnchorAndPivot(medicineItemDetailIcon,UIAnchor.Center,UIAroundPivot.Center)

    local medicineItemDetailName=GUI.CreateStatic(medicineItemDetailBg,"medicineItemDetailName","食物名字",0,-115,200,50)
    GUI.StaticSetFontSize(medicineItemDetailName,UIDefine.FontSizeL)
    GUI.SetColor(medicineItemDetailName,UIDefine.BrownColor)
    GUI.StaticSetAlignment(medicineItemDetailName,TextAnchor.MiddleCenter)

    local medicineItemDetailTips=GUI.CreateStatic(medicineItemDetailBg,"medicineItemDetailTips","食物小提示",0,-65,700,50)
    GUI.StaticSetFontSize(medicineItemDetailTips,UIDefine.FontSizeM)
    GUI.SetColor(medicineItemDetailTips,UIDefine.BrownColor)
    GUI.StaticSetAlignment(medicineItemDetailTips,TextAnchor.MiddleCenter)
    --SetAnchorAndPivot(foodItemDetailTips,UIAnchor.Center,UIAroundPivot.Center)


    local medicineItemDetailInfo=GUI.CreateStatic(medicineItemDetailBg,"medicineItemDetailInfo","食物信息",0,0,700,100)
    GUI.StaticSetFontSize(medicineItemDetailInfo,UIDefine.FontSizeL)
    GUI.SetColor(medicineItemDetailInfo,UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(medicineItemDetailInfo,TextAnchor.MiddleCenter)

    local cutLine1 = GUI.ImageCreate(medicineItemDetailBg, "cutLine1", "1800700060", 0, 30, false, 740, 1);
    SetAnchorAndPivot(cutLine1, UIAnchor.Center, UIAroundPivot.Center)

    local medicineTips=GUI.CreateStatic(medicineItemDetailBg,"medicineTips","你当前的等级能够",0,70,700,50)
    GUI.StaticSetFontSize(medicineTips,UIDefine.FontSizeM)
    GUI.SetColor(medicineTips,UIDefine.BrownColor)
    GUI.StaticSetAlignment(medicineTips,TextAnchor.MiddleCenter)
    --创建食物材料
    --ProduceUI.CreateOrRefreshFoodItemMaterials()
    ProduceUI.CreateMedicineItemMaterials()
end
--创建食物详情中的材料
function ProduceUI.CreateMedicineItemMaterials()
    local medicineItemDetailBg=_gt.GetUI("medicineItemDetailBg")
    if not  medicineItemDetailBg then
        return
    end
    local medicineMaterialsGroup=GUI.GroupCreate(medicineItemDetailBg,"medicineMaterialsGroup",0,150,500,100)
    SetAnchorAndPivot(medicineMaterialsGroup, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(medicineMaterialsGroup,"materialsGroup")
    --test("#FoodList[CurSelectFoodIndex].FoodMaterials=="..#FoodList[CurSelectFoodIndex].FoodMaterials)
    for i = 1, 3 do
        local materialsIconBg=GUI.ImageCreate(medicineMaterialsGroup,"materialsIconBg"..i,"",(i-1)*150-150,0,false,90,90)
        GUI.SetIsRaycastTarget(materialsIconBg, true)
        materialsIconBg:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(materialsIconBg,UCE.PointerClick,"ProduceUI","OnMedicineMaterialsClick")
        local materialsIcon=GUI.ImageCreate(materialsIconBg,"materialsIcon","",0,0,false,60,60)
        local materialsAmountTxt=GUI.CreateStatic(materialsIconBg,"materialsAmountTxt","0/2",-10,8,90,50)
        GUI.StaticSetFontSize(materialsAmountTxt,UIDefine.FontSizeM)
        SetAnchorAndPivot(materialsAmountTxt,UIAnchor.BottomRight,UIAroundPivot.BottomRight)
        GUI.StaticSetAlignment(materialsAmountTxt,TextAnchor.MiddleRight)
        local materialsName=GUI.CreateStatic(medicineMaterialsGroup,"materialsName"..i,"材料"..i,(i-1)*150-150,60,100,50)
        GUI.StaticSetFontSize(materialsName,UIDefine.FontSizeM)
        GUI.SetColor(materialsName,UIDefine.BrownColor)
        GUI.StaticSetAlignment(materialsName,TextAnchor.MiddleCenter)
    end
end
function ProduceUI.OnMedicineMaterialsClick(guid)
    --test("click")
    local materialsItem=GUI.GetByGuid(guid)
    local medicineMaterialsId=GUI.GetData(materialsItem,"materialsId")
    --test("materialsId"..medicineMaterialsId)
    ProduceUI.MaterialsTips(medicineMaterialsId)
end

----------------------------------炼药End---------------------------------------------------------
-------------------------------通用方法Start---------------------------------------------------
--优先绑定按钮点击
function ProduceUI.OnFirstUseUnBindMaterialsClick(guid)
    local firstUseUnBindMaterials=GUI.GetByGuid(guid)
    IsFirstUseUnBindMaterials=not IsFirstUseUnBindMaterials
    if IsFirstUseUnBindMaterials then
        test("优先使用")
    else
        test("非优先使用")
    end

end
--制造按钮点击
function ProduceUI.OnMakeBtnClick()
    LabelListRedPointFlag = 0
    LabelListRedPointFlag2 = 0
    -- test("触发点击事件")
    local flag=0
    if IsFirstUseUnBindMaterials then
        flag=1
    end
    --test("CurSelectFoodId"..CurSelectFoodIndex)
    --test("flag"..flag)
    local roleVP=CL.GetIntAttr(RoleAttr.RoleAttrVp)
    if CurSelectPage==PageNum.cookingPage then
        -- test("制造食物")
        local CurSelectFoodListData=FoodList[CurSelectFoodIndex]
        local FoodVP = CurSelectFoodListData.FoodVP
        if FoodVP > roleVP then
            CL.SendNotify(NOTIFY.ShowBBMsg,"活力不足")
            return
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormProduce", "MakeFood",tostring(CurSelectFoodIndex),tostring(flag))
    elseif  CurSelectPage==PageNum.refiningMedicinePage then
        -- test("制造药物")
        local CurSelectMedicineListData=MedicineList[CurSelectMedicineIndex]
        local MedicineVP = CurSelectMedicineListData.MedicineVP
        if MedicineVP > roleVP then
            CL.SendNotify(NOTIFY.ShowBBMsg,"活力不足")
            return
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormProduce", "MakeMedicine",tostring(CurSelectMedicineIndex),tostring(flag))
    end
end
--材料Tips
function ProduceUI.MaterialsTips(materialsId)
    local curPage=_gt.GetUI(LabelList[CurSelectPage][4])
    local MaterialsTips=Tips.CreateByItemId(materialsId,curPage,"MaterialsTips",0,0,50)
    GUI.SetData(MaterialsTips,"ItemId",materialsId)
    _gt.BindName(MaterialsTips,"MaterialsTips")
    local wayBtn=GUI.ButtonCreate(MaterialsTips,"wayBtn","1800402110",0,-10,Transition.ColorTint,"获得途径", 150, 50, false)
    SetAnchorAndPivot(wayBtn,UIAnchor.Bottom,UIAroundPivot.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"ProduceUI","onClickMaterialsWayBtn")
    GUI.AddWhiteName(MaterialsTips, GUI.GetGuid(wayBtn))
end
--获得途径按钮点击
function ProduceUI.onClickMaterialsWayBtn()
    -- test("waybtn点击")
    local MaterialsTips=_gt.GetUI("MaterialsTips")
    if MaterialsTips==nil then
        test("MaterialsTips is nil")
    end
    if MaterialsTips then
        Tips.ShowItemGetWay(MaterialsTips)
    end
end
--制造成功特效
function ProduceUI.MakeSuccess()
    GUI.OpenWnd("ShowEffectUI", 3000001548)
    ShowEffectUI.SetTimeOff(2)
end

-- 右侧红点刷新
function ProduceUI.refreshRedPoint()
    local foodText = GUI.Get("ProduceUI/panelBg/tabList/cookingTog/text")
    local medicineText = GUI.Get("ProduceUI/panelBg/tabList/refiningMedicineTog/text")
    GUI.SetRedPointVisable(foodText,false)
    GUI.SetRedPointVisable(medicineText,false)
    local food_data = GlobalProcessing.produce_data["food_data"]
    local medicine_data = GlobalProcessing.produce_data["medicine_data"]
    local roleVP=CL.GetIntAttr(RoleAttr.RoleAttrVp)
    for i, v in pairs(food_data) do
        local flag = 0
        for j = 1, 3 do
            local materialsData=DB.GetOnceItemByKey2(v["Item"..j])
            -- 背包物品数据
            local materialsInBagAmount = LD.GetItemCountById(materialsData.Id)
            if v["ItemNumber"..j] <= materialsInBagAmount then
                flag = flag + 1
            end
        end
        if flag == 3 and roleVP >= v["VP"] then
            GUI.SetRedPointVisable(foodText,true)
        end
    end

    for i, v in pairs(medicine_data) do
        local flag = 0
        for j = 1, 3 do
            local materialsData=DB.GetOnceItemByKey2(v["Item"..j])
            -- 背包物品数据
            local materialsInBagAmount = LD.GetItemCountById(materialsData.Id)
            if v["ItemNumber"..j] <= materialsInBagAmount then
                flag = flag + 1
            end
        end
        if flag == 3 and roleVP >= v["VP"] then
            GUI.SetRedPointVisable(medicineText,true)
        end
    end
end

function ProduceUI.ResetVPProduce(attrType, value)
    local VP = tonumber(tostring(value))
    local consumeEnergyTxt = nil
    if CurSelectPage == PageNum.cookingPage then
        local cookingPage=_gt.GetUI(LabelList[PageNum.cookingPage][4])
        consumeEnergyTxt=GUI.GetChild(cookingPage,"consumeEnergyTxt")
    elseif CurSelectPage==PageNum.refiningMedicinePage then
        local refiningMedicinePage=_gt.GetUI(LabelList[PageNum.refiningMedicinePage][4])
        consumeEnergyTxt=GUI.GetChild(refiningMedicinePage,"consumeEnergyTxt")
    end
    if consumeEnergyTxt == nil then
        return
    end
    if tonumber(GUI.StaticGetText(consumeEnergyTxt)) > VP then
        GUI.SetColor(consumeEnergyTxt, UIDefine.RedColor)
    else
        GUI.SetColor(consumeEnergyTxt, UIDefine.Yellow2Color)
    end
end
-------------------------------通用方法End---------------------------------------------------