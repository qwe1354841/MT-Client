local EquipGemMergeUI = {
    ---@type table<number,>
    serverData = {}
}
-- local test = test
local test = function()
end
_G.EquipGemMergeUI = EquipGemMergeUI
local _gt = UILayout.NewGUIDUtilTable()


EquipGemMergeUI.MoneyAttrs = {
	[1] = RoleAttr.RoleAttrIngot,
	[2] = RoleAttr.RoleAttrBindIngot,
	[4] = RoleAttr.RoleAttrGold,
	[5] = RoleAttr.RoleAttrBindGold,
}


local mergeNum=2;
function EquipGemMergeUI.InitData()
    return {
        -- 背包中，装备中类型
        type = 1,
        -- 选中的道具下标
        index = 1,
        -- 选中的道具uiGuId
        indexGuid = int64.new(0),
        config=nil,
        levelConfig=nil,
        visible=false,
        levelIndex=1,
        firstGuid=nil;
        secondGuid=nil;
        equipGemIndex=1;
    }
end

local data = EquipGemMergeUI.InitData()
data.EquipGemMergeUI_Check_Redpot_gemID = {}
data.EquipGemMergeUI_Check_Redpot_gemLevel = {}


function EquipGemMergeUI.OnExitGame()
    data = EquipGemMergeUI.InitData()
    EquipGemMergeUI.attrConfig=nil;
end

function EquipGemMergeUI.GetConfig(configData,attrData)		--大唐版本参数格式(configData,attrData)
    if CL.GetMode() == 1 then
        local inspect = require("inspect")
        test(inspect(configData))
        --test(inspect(attrData))
    end
	data.ComposeData = configData
    data.config={};
    data.levelConfig={};
    for k, v in pairs(configData) do
        local itemDB = DB.GetOnceItemByKey1(k);
        if itemDB.Type == 3 and itemDB.Subtype == 9 then
            if data.config[itemDB.Itemlevel] == nil then
                data.config[itemDB.Itemlevel]={};
                table.insert(data.levelConfig,itemDB.Itemlevel);
            end
            table.insert(data.config[itemDB.Itemlevel],{ItemId=k,SubItemId=v.Item});
        end
    end
	
    for k, v in pairs(data.config) do
        table.sort(data.config[k],function (a,b)
            return a.ItemId<b.ItemId;
        end)
    end
    table.sort(data.levelConfig,function (a,b)
        return a<b;
    end)
	EquipGemMergeUI.levelConfig = data.levelConfig
	
	EquipGemMergeUI.attrConfig=attrData;
    if data.visible == true then
        EquipGemMergeUI.Refresh();
    end
end

function EquipGemMergeUI.OnLevelItemClick(guid)
    local levelItem = GUI.GetByGuid(guid);
    local index =GUI.ButtonGetIndex(levelItem)
    data.levelIndex=index + 1;
    data.index=1;
    data.firstGuid=nil;
    data.secondGuid=nil;
    EquipGemMergeUI.OnLevelSelectCoverClick();
    EquipGemMergeUI.Refresh();
end


function EquipGemMergeUI.OnLevelSelectCoverClick()
    local levelSelectCover = _gt.GetUI("levelSelectCover");
    GUI.SetVisible(levelSelectCover,false);
end

--ui刷新
function EquipGemMergeUI.Refresh()
	test("Refresh")

    local eqiupIcon =EquipUI.guidt.GetUI("eqiupIcon");
	local eqiupIcon_Bef = EquipUI.guidt.GetUI("eqiupIcon_Bef")
    --local equipNameText = EquipUI.guidt.GetUI("equipNameText");
    local scroll = EquipUI.guidt.GetUI("itemScroll")
    local equipGemScroll=EquipUI.guidt.GetUI("equipGemScroll")
    local levelText = _gt.GetUI("levelText");
	local equipTypeText_Bef = _gt.GetUI("equipTypeText_Bef")
	local equipTypeText = _gt.GetUI("equipTypeText")
	local Merge_possibility_Txt_2 = _gt.GetUI("Merge_possibility_Txt_2")			--合成成功率
	local gem_Name_Bef = _gt.GetUI("gem_Name_Bef")
	local gem_Name_Aft = _gt.GetUI("gem_Name_Aft")
	local Merge_Preview_1_Att1 = _gt.GetUI("Merge_Preview_1_Att1")                  --宝石1属性1                       --合成前宝石
	local Merge_Preview_1_Att2 = _gt.GetUI("Merge_Preview_1_Att2")                  --宝石1属性2(属性可能为空)         --合成前宝石
	local Merge_Preview_2_Att1 = _gt.GetUI("Merge_Preview_2_Att1")                  --宝石2属性1                       --合成后宝石
	local Merge_Preview_2_Att2 = _gt.GetUI("Merge_Preview_2_Att2")                  --宝石2属性2(属性可能为空)         --合成后宝石
	local Merge_Preview_1_Tips = _gt.GetUI("Merge_Preview_1_Tips") 
	local Merge_Preview_2_Tips = _gt.GetUI("Merge_Preview_2_Tips")
    local gem_Num = _gt.GetUI("gem_Num")
	local levelScr = _gt.GetUI("levelScr")
    local levelSelectBtn = _gt.GetUI("levelSelectBtn")
	
	if data.config and data.levelConfig and  EquipGemMergeUI.attrConfig then   --大唐版本
		--右侧宝石预览
		local isCheck = false
		if EquipUI.CheckItemId ~= 0 then
			local checkItemDB = DB.GetOnceItemByKey1(EquipUI.CheckItemId)
			local maxLevel = false
			data.index = checkItemDB.Subtype2
			data.levelIndex = checkItemDB.Itemlevel
			while data.levelConfig[data.levelIndex] == nil do
				maxLevel = true
				data.levelIndex = data.levelIndex - 1
			end
			local level = data.levelConfig[data.levelIndex]
			local geminfo = data.config[level][data.index]
			if geminfo and (maxLevel and geminfo.ItemId == EquipUI.CheckItemId or
					not maxLevel and geminfo.SubItemId == EquipUI.CheckItemId) then
				isCheck = true
				EquipUI.CheckItemId = 0
			else
				data.index = 1
				data.levelIndex = 1
				EquipUI.CheckItemId = 0
			end
		end
		local gemId =EquipGemMergeUI.GetCurGemId()										--合成后的宝石id
		local itemDB = DB.GetOnceItemByKey1(gemId);	
		ItemIcon.BindItemDB(eqiupIcon,itemDB)
		GUI.StaticSetText(equipTypeText, itemDB['Itemlevel'].."级   ".."宝石")
		
		local gem_Bef_Id = EquipGemMergeUI.ComposeData[gemId]['Item']					--合成前的宝石id
		local gemDB = DB.GetOnceItemByKey1(gem_Bef_Id)
		local gem_Icon = gemDB['Icon']
		--test("======================gem_Icon = "..gem_Icon)
		ItemIcon.BindItemDB(eqiupIcon_Bef,gemDB)
		GUI.StaticSetText(equipTypeText_Bef, gemDB['Itemlevel'].."级   ".."宝石")
		
		local curLevel = data.levelConfig[data.levelIndex]
		GUI.StaticSetText(levelText,curLevel.."级");
		
		local Merge_possibility = GUI.StaticSetText(Merge_possibility_Txt_2, ""..tostring(EquipGemMergeUI.ComposeData[gemId]['Rate']/100).."%")
		
		GUI.StaticSetText(gem_Name_Bef, ""..gemDB['Name'])

		GUI.StaticSetText(gem_Name_Aft, ""..itemDB['Name'])
		
		local item_AttDB = DB.GetOnceItem_AttByKey1(gemId)
		local gem_AttDB = DB.GetOnceItem_AttByKey1(gem_Bef_Id)
		
		local gem_1_Att_1_Type = DB.GetOnceAttrByKey1(gem_AttDB['Att1'])['ChinaName']
		local gem_1_Att_1_Num = gem_AttDB['Att1Max']
		GUI.StaticSetText(Merge_Preview_1_Att1, ""..gem_1_Att_1_Type.."   ".."<color=#19c800ff>+"..gem_1_Att_1_Num.."</color>")
		
		if gem_AttDB['Att2'] ~= 0 then
			local gem_1_Att_2_Type = DB.GetOnceAttrByKey1(gem_AttDB['Att2'])['ChinaName']
			local gem_1_Att_2_Num = gem_AttDB['Att2Max']
			GUI.StaticSetText(Merge_Preview_1_Att2, ""..gem_1_Att_2_Type.."   ".."<color=#19c800ff>+"..gem_1_Att_2_Num.."</color>")
		else
			GUI.StaticSetText(Merge_Preview_1_Att2, "")
		end
		
		local gem_2_Att_1_Type = DB.GetOnceAttrByKey1(item_AttDB['Att1'])['ChinaName']
		local gem_2_Att_1_Num = item_AttDB['Att1Max']
		GUI.StaticSetText(Merge_Preview_2_Att1, ""..gem_2_Att_1_Type.."   ".."<color=#19c800ff>+"..gem_2_Att_1_Num.."</color>")
		
		if item_AttDB['Att2'] ~= 0 then
			local gem_2_Att_2_Type = DB.GetOnceAttrByKey1(item_AttDB['Att2'])['ChinaName']
			local gem_2_Att_2_Num = item_AttDB['Att2Max']
			GUI.StaticSetText(Merge_Preview_2_Att2, ""..gem_2_Att_2_Type.."   ".."<color=#19c800ff>+"..gem_2_Att_2_Num.."</color>")
		else
			GUI.StaticSetText(Merge_Preview_2_Att2, "")
		end
		
		local Tips_1 = string.split(gemDB['Info'], "，")[1]
		GUI.StaticSetText(Merge_Preview_1_Tips, ""..Tips_1)
		
		local Tips_2 = string.split(itemDB['Info'], "，")[1]
		GUI.StaticSetText(Merge_Preview_2_Tips, ""..Tips_2)
		
		local gem_Num_Have = LD.GetItemCountById(gem_Bef_Id, item_container_type.item_container_gem_bag)
		local gem_Num_Need = EquipGemMergeUI.ComposeData[gemId]['ItemNumber']
		GUI.StaticSetText(gem_Num, ""..gem_Num_Have.."/"..gem_Num_Need)
		if gem_Num_Need <= gem_Num_Have then
			GUI.SetColor(gem_Num, UIDefine.WhiteColor)
			GUI.SetData(eqiupIcon_Bef, "Enough", "true")
		else
			GUI.SetColor(gem_Num, Color.New(255 / 255, 0 / 255, 0 / 255, 255))
			GUI.SetData(eqiupIcon_Bef, "Enough", "false")
		end
		
		-- EquipUI.CheckEquipRedPoint()
		if #data.EquipGemMergeUI_Check_Redpot_gemLevel > 0 then
			GlobalProcessing.SetRetPoint(levelSelectBtn,true)
		else
			GlobalProcessing.SetRetPoint(levelSelectBtn,false)
		end
		GUI.LoopScrollRectSetTotalCount(scroll, #data.config[curLevel])
		GUI.LoopScrollRectRefreshCells(scroll)
		if isCheck then
			GUI.LoopScrollRectSrollToCell(scroll,data.index - 1,1000)
		end
	
		--EquipGemMergeUI.RefreshGemListScr()
    end
	local gem_Id = EquipGemMergeUI.GetCurGemId()
	local num = _gt.GetUI("EquipGemMergeUI.num_Money_Cost_Number")
	local itemnum = 100
	local moneytype = 5
	if gem_Id then
		itemnum = EquipGemMergeUI.ComposeData[gem_Id]['MoneyVal']
		moneytype = EquipGemMergeUI.ComposeData[gem_Id]['MoneyType']
	end
	local l, h = int64.longtonum2(CL.GetAttr(UIDefine.GetMoneyEnum(moneytype)))
	local curnum = l
	if curnum < itemnum then
		GUI.SetColor(num, UIDefine.RedColor)
	else
		GUI.SetColor(num, UIDefine.WhiteColor)
	end
	GUI.StaticSetText(num, itemnum)
end

function EquipGemMergeUI.OnDemountBtnClick(guid)
    local demountBtn=GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(demountBtn,"GemType"));
    if index==1 then
        data.firstGuid=nil;
    elseif index==2 then
        data.secondGuid=nil;
    end

    data.equipGemIndex=index;
    EquipGemMergeUI.Refresh();
end

-- 关闭或者打开只属于子页签的东西r
function EquipGemMergeUI.SetVisible(visible)
	data.visible=visible;
	local gemMergeGroup = EquipUI.guidt.GetUI("gemMergeGroup")
	local EquipBottom= EquipUI.guidt.GetUI("EquipBottom")

	local remainder = EquipUI.guidt.GetUI("emptyIamge")
    local remainder_bg = EquipUI.guidt.GetUI("emptyIamgeTxtBg")
    GUI.SetVisible(remainder,not visible)
    GUI.SetVisible(remainder_bg,not visible)
	GUI.SetVisible(gemMergeGroup,visible)
    GUI.SetVisible(EquipBottom,not visible);

    if visible==true then
        EquipGemMergeUI.OnLevelSelectCoverClick();
        EquipUI.RefreshLeftItemScroll = EquipGemMergeUI.RefreshLeftItem
        EquipUI.ClickLeftItemScroll = EquipGemMergeUI.OnLeftItemClick
    else
        if EquipUI.RefreshLeftItemScroll == EquipGemMergeUI.RefreshLeftItem then
            EquipUI.RefreshLeftItemScroll = nil
            EquipUI.ClickLeftItemScroll = nil
        end
    end
end

function EquipGemMergeUI.Show(reset)
	--test("====================Show")
    if reset then
        data.index = 1
        data.type = 1
        data.indexGuid = nil
        data.levelIndex = 1
        data.firstGuid=nil
        data.secondGuid=nil
        data.equipGemIndex=1
    end
    EquipGemMergeUI.SetVisible(true)
	EquipGemMergeUI.Refresh()
end

function EquipGemMergeUI.OnEquipGemItemClick(guid)
	--test("=================OnEquipGemItemClick")
    local equipGemItem =GUI.GetByGuid(guid);
    local index=GUI.CheckBoxExGetIndex(equipGemItem)
    index=index+1;
    data.equipGemIndex=index;
    local equipGemScroll=EquipUI.guidt.GetUI("equipGemScroll")
    GUI.LoopScrollRectRefreshCells(equipGemScroll)
end

function EquipGemMergeUI.RefreshEquipGemScroll(parameter)

end

function EquipGemMergeUI.CreateSubPage(gemPage)						--生成页面
    GameMain.AddListen("EquipGemMergeUI", "OnExitGame")
    _gt = UILayout.NewGUIDUtilTable()
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipGem_GetComposeData")
	
    local gemMergeGroup = GUI.GroupCreate(gemPage, "gemMergeGroup", 0, 0, 0, 0)
    EquipUI.guidt.BindName(gemMergeGroup, "gemMergeGroup")

	local Merge_Bg = GUI.ImageCreate(gemMergeGroup, "Merge_Bg", "1801100100", 155,10,false, 740,460)
	_gt.BindName(Merge_Bg, "Merge_Bg")
	
	local Merge_Preview_1 = GUI.ImageCreate(Merge_Bg, "Merge_Preview_1", "1801100030", -190,-69,false, 300,260)
	local Merge_Preview_2 = GUI.ImageCreate(Merge_Bg, "Merge_Preview_2", "1801100030", 190,-69,false, 300,260)
	local Merge_Arrow = GUI.ImageCreate(Merge_Bg, "Merge_Arrow", "1801107010", 0, -70, false, 80, 150)
	local Merge_txt_1 = GUI.CreateStatic(Merge_Preview_1, "Merge_txt_1", "当前", -31, -108, 150, 40)
	GUI.StaticSetFontSize(Merge_txt_1, UIDefine.FontSizeL)
	GUI.SetColor(Merge_txt_1, UIDefine.BrownColor)
	local Merge_txt_2 = GUI.CreateStatic(Merge_Preview_2, "Merge_txt_2", "合成后", -35, -108, 150, 40)
	GUI.StaticSetFontSize(Merge_txt_2, UIDefine.FontSizeL)
	GUI.SetColor(Merge_txt_2, UIDefine.BrownColor)
	
	local Merge_Preview_1_Line = GUI.ImageCreate(Merge_Preview_1, "Merge_Preview_1_Line", "1801100040", 18,26,false, 290,32)
	local Merge_Preview_1_Line_Txt = GUI.CreateStatic(Merge_Preview_1_Line, "Merge_Preview_1_Line_Txt", "属性加成", -60, 0, 150, 30)
	GUI.StaticSetFontSize(Merge_Preview_1_Line_Txt, UIDefine.FontSizeL)
	GUI.SetColor(Merge_Preview_1_Line_Txt, UIDefine.WhiteColor)
	
	local Merge_Preview_2_Line = GUI.ImageCreate(Merge_Preview_2, "Merge_Preview_2_Line", "1801100040", 18,26,false, 290,32)
	local Merge_Preview_2_Line_Txt = GUI.CreateStatic(Merge_Preview_2_Line, "Merge_Preview_2_Line_Txt", "属性加成", -60, 0, 150, 30)
	GUI.StaticSetFontSize(Merge_Preview_2_Line_Txt, UIDefine.FontSizeL)
	GUI.SetColor(Merge_Preview_2_Line_Txt, UIDefine.WhiteColor)
	
	local Merge_Preview_1_Att1 = GUI.CreateStatic(Merge_Preview_1, "Merge_Preview_1_Att1", "物理攻击".." ".."+5", 49, 58, 300, 50,"system", true)
	GUI.StaticSetFontSize(Merge_Preview_1_Att1, 20)
	GUI.SetColor(Merge_Preview_1_Att1, UIDefine.BrownColor)
	_gt.BindName(Merge_Preview_1_Att1, "Merge_Preview_1_Att1")
	
	local Merge_Preview_1_Att2 = GUI.CreateStatic(Merge_Preview_1, "Merge_Preview_1_Att2", "物理攻击".." ".."+5", 49, 81, 300, 50,"system", true)
	GUI.StaticSetFontSize(Merge_Preview_1_Att2, 20)
	GUI.SetColor(Merge_Preview_1_Att2, UIDefine.BrownColor)
	_gt.BindName(Merge_Preview_1_Att2, "Merge_Preview_1_Att2")
	
	local Merge_Preview_2_Att1 = GUI.CreateStatic(Merge_Preview_2, "Merge_Preview_2_Att1", "物理攻击".." ".."+10", 49, 58, 300, 50,"system", true)
	GUI.StaticSetFontSize(Merge_Preview_2_Att1, 20)
	GUI.SetColor(Merge_Preview_2_Att1, UIDefine.BrownColor)
	_gt.BindName(Merge_Preview_2_Att1, "Merge_Preview_2_Att1")
	
	local Merge_Preview_2_Att2 = GUI.CreateStatic(Merge_Preview_2, "Merge_Preview_2_Att2", "物理攻击".." ".."+10", 49, 81, 300, 50,"system", true)
	GUI.StaticSetFontSize(Merge_Preview_2_Att2, 20)
	GUI.SetColor(Merge_Preview_2_Att2, UIDefine.BrownColor)
	_gt.BindName(Merge_Preview_2_Att2, "Merge_Preview_2_Att2")
	
	local Merge_Preview_1_Tips = GUI.CreateStatic(Merge_Preview_1, "Merge_Preview_1_Tips", "可镶嵌于武器、头盔、戒指", 0,110, 400, 30)
	GUI.StaticSetFontSize(Merge_Preview_1_Tips, 18)
	GUI.StaticSetAlignment(Merge_Preview_1_Tips, TextAnchor.MiddleCenter)
	GUI.SetColor(Merge_Preview_1_Tips, UIDefine.GrayColor)
	_gt.BindName(Merge_Preview_1_Tips, "Merge_Preview_1_Tips")
	
	local Merge_Preview_2_Tips = GUI.CreateStatic(Merge_Preview_2, "Merge_Preview_2_Tips", "可镶嵌于武器、头盔、戒指", 0,110, 400, 30)
	GUI.StaticSetFontSize(Merge_Preview_2_Tips, 18)
	GUI.StaticSetAlignment(Merge_Preview_2_Tips, TextAnchor.MiddleCenter)
	GUI.SetColor(Merge_Preview_2_Tips, UIDefine.GrayColor)
	_gt.BindName(Merge_Preview_2_Tips, "Merge_Preview_2_Tips")
	
	
	local Merge_possibility_Txt_1 = GUI.CreateStatic(Merge_Bg, "Merge_possibility_Txt_1", "成功率", 160, 195, 150, 50)
	GUI.StaticSetFontSize(Merge_possibility_Txt_1, UIDefine.FontSizeL)
	GUI.SetColor(Merge_possibility_Txt_1, UIDefine.BrownColor)
	local Merge_possibility_Txt_2 = GUI.CreateStatic(Merge_Bg, "Merge_possibility_Txt_2", "100%", 242, 195, 150, 50)
	GUI.StaticSetFontSize(Merge_possibility_Txt_2, UIDefine.FontSizeL)
	GUI.SetColor(Merge_possibility_Txt_2, UIDefine.Yellow2Color)
	_gt.BindName(Merge_possibility_Txt_2, "Merge_possibility_Txt_2")
	
	local eqiupIcon_Bef = ItemIcon.Create(Merge_Preview_1, "eqiupIcon_Bef", -88, -33);			--右侧预览_合成前
	EquipUI.guidt.BindName(eqiupIcon_Bef, "eqiupIcon_Bef")
	local eqiupIcon = ItemIcon.Create(Merge_Preview_2, "eqiupIcon_Aft", -88, -33);				--右侧预览_合成后
	EquipUI.guidt.BindName(eqiupIcon, "eqiupIcon")
	
	local gem_Name_Bef = GUI.CreateStatic(Merge_Preview_1, "gem_Name_Bef", "1级开锋石", 68, -56, 200, 50)
	GUI.StaticSetFontSize(gem_Name_Bef, 24);
	GUI.SetColor(gem_Name_Bef, UIDefine.BrownColor);
	_gt.BindName(gem_Name_Bef, "gem_Name_Bef")
	
	local gem_Name_Aft = GUI.CreateStatic(Merge_Preview_2, "gem_Name_Aft", "2级开锋石", 68, -56, 200, 50)
	GUI.StaticSetFontSize(gem_Name_Aft, 24);
	GUI.SetColor(gem_Name_Aft, UIDefine.BrownColor);
	_gt.BindName(gem_Name_Aft, "gem_Name_Aft")
	
	local equipTypeText_Bef = GUI.CreateStatic(Merge_Preview_1, "equipTypeText_Bef", "level  type", 19, -20, 350, 30);
	GUI.StaticSetFontSize(equipTypeText_Bef, UIDefine.FontSizeM);
	GUI.StaticSetAlignment(equipTypeText_Bef, TextAnchor.MiddleCenter);
	GUI.SetColor(equipTypeText_Bef, UIDefine.Yellow2Color);
	_gt.BindName(equipTypeText_Bef, "equipTypeText_Bef")
	
	local equipTypeText = GUI.CreateStatic(Merge_Preview_2, "equipTypeText", "level  type", 19, -20, 350, 30);
	GUI.StaticSetFontSize(equipTypeText, UIDefine.FontSizeM);
	GUI.StaticSetAlignment(equipTypeText, TextAnchor.MiddleCenter);
	GUI.SetColor(equipTypeText, UIDefine.Yellow2Color);
	_gt.BindName(equipTypeText, "equipTypeText")
	
	local gem_Num = GUI.CreateStatic(eqiupIcon_Bef, "gem_Num", "0/3", -6,24,80,30)
	GUI.StaticSetFontSize(gem_Num, 18);
	GUI.StaticSetAlignment(gem_Num, TextAnchor.MiddleRight)
	GUI.SetColor(gem_Num, UIDefine.RedColor)
	_gt.BindName(gem_Num, "gem_Num")
	GUI.SetIsOutLine(gem_Num,true)
	GUI.SetOutLine_Color(gem_Num,UIDefine.BlackColor)
	GUI.SetOutLine_Distance(gem_Num, 1)

    local mergeBtn = GUI.ButtonCreate(gemMergeGroup, "mergeBtn", "1800002060", 438, 266, Transition.ColorTint, "合成", 160, 50, false)
    GUI.SetEventCD(mergeBtn, UCE.PointerClick, 0.5)
    GUI.ButtonSetTextColor(mergeBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(mergeBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetOutLineArgs(mergeBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(mergeBtn, UCE.PointerClick, "EquipGemMergeUI", "OnMergeBtnClick");
	
	local mergeAllBtn = GUI.ButtonCreate(gemMergeGroup, "mergeAllBtn", "1800002060", 247, 266, Transition.ColorTint, "合成全部", 160, 50, false)
    GUI.SetEventCD(mergeAllBtn, UCE.PointerClick, 0.5)
    GUI.ButtonSetTextColor(mergeAllBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(mergeAllBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetOutLineArgs(mergeAllBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(mergeAllBtn, UCE.PointerClick, "EquipGemMergeUI", "OnMergeBtnClick_All_C");		--0000，对应方法待改
	
	local wnd= GUI.GetWnd("EquipUI")
    local Merge_All_Panel = GUI.ImageCreate(Merge_Bg,"Merge_All_Panel","1800001060",0,0,false,GUI.GetWidth(wnd),GUI.GetHeight(wnd))
	Merge_All_Panel:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(Merge_All_Panel, true)
    -- GUI.RegisterUIEvent(Merge_All_Panel, UCE.PointerClick, "EquipGemMergeUI", "Merge_All_CancelClick")
    GUI.SetVisible(Merge_All_Panel, false);
	_gt.BindName(Merge_All_Panel, "Merge_All_Panel")

	local Merge_All_Bg = GUI.ImageCreate(Merge_All_Panel, "Merge_All_Bg", "1800001120", -155, -30, false, 475, 260)
	local Merge_All_Flower = GUI.ImageCreate(Merge_All_Bg, "Merge_All_Flower", "1800007060", -204, -120, false, 120, 75)
	local Merge_All_Cancel = GUI.ButtonCreate(Merge_All_Bg, "Merge_All_Cancel", "1800002050", 206, -99, Transition.ColorTint, "", 23, 23, false)
	GUI.RegisterUIEvent(Merge_All_Cancel, UCE.PointerClick, "EquipGemMergeUI", "Merge_All_CancelClick");
	local Merge_All_1 = GUI.ImageCreate(Merge_All_Bg, "Merge_All_1", "1800001030",0, -87, false, 220, 37)
	local Merge_All_1_Txt = GUI.CreateStatic(Merge_All_1, "Merge_All_1_Txt", "合成全部", 0, 0, 200, 35)
	GUI.StaticSetFontSize(Merge_All_1_Txt, 20);
	GUI.StaticSetAlignment(Merge_All_1_Txt, TextAnchor.MiddleCenter);
	local Merge_All_Main_Txt = GUI.CreateStatic(Merge_All_Bg, "Merge_All_Main_Txt", "可合成3个2级开锋石", 0, -30, 300, 35)
	GUI.StaticSetFontSize(Merge_All_Main_Txt, 22);
	GUI.StaticSetAlignment(Merge_All_Main_Txt, TextAnchor.MiddleCenter);
	GUI.SetColor(Merge_All_Main_Txt, UIDefine.BrownColor);
	_gt.BindName(Merge_All_Main_Txt, "Merge_All_Main_Txt")
	local Merge_All_Cost = GUI.ImageCreate(Merge_All_Bg, "Merge_All_Cost", "1800700010", 0, 20, false, 180, 35)
	local Merge_All_Cost_1 = GUI.ImageCreate(Merge_All_Cost, "Merge_All_Cost_1", "1800408280",-74, -1, false, 36, 36)
	local Merge_All_Cost_Num = GUI.CreateStatic(Merge_All_Cost, "Merge_All_Cost_Num", "100", 0, 0, 160, 30)
	GUI.StaticSetFontSize(Merge_All_Cost_Num, 22);
	GUI.StaticSetAlignment(Merge_All_Cost_Num, TextAnchor.MiddleCenter);
	_gt.BindName(Merge_All_Cost_Num, "Merge_All_Cost_Num")
	local Merge_All_Cost_Cancel = GUI.ButtonCreate(Merge_All_Bg, "Merge_All_Cost_Cancel", "1800002060", -100,85,Transition.ColorTint,"取消", 140, 45, false)
	GUI.ButtonSetTextColor(Merge_All_Cost_Cancel, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(Merge_All_Cost_Cancel, UIDefine.FontSizeXL)
    GUI.ButtonSetOutLineArgs(Merge_All_Cost_Cancel, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
	GUI.RegisterUIEvent(Merge_All_Cost_Cancel, UCE.PointerClick, "EquipGemMergeUI", "Merge_All_CancelClick");
	local Merge_All_Cost_Comfirm = GUI.ButtonCreate(Merge_All_Bg, "Merge_All_Cost_Comfirm", "1800002060", 100,85,Transition.ColorTint,"合成", 140, 45, false)
	GUI.ButtonSetTextColor(Merge_All_Cost_Comfirm, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(Merge_All_Cost_Comfirm, UIDefine.FontSizeXL)
    GUI.ButtonSetOutLineArgs(Merge_All_Cost_Comfirm, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
	GUI.RegisterUIEvent(Merge_All_Cost_Comfirm, UCE.PointerClick, "EquipGemMergeUI", "OnMergeBtnClick_All_Finish");

    local levelLabel = GUI.CreateStatic(gemMergeGroup, "levelLabel", "宝石等级", -455, -244, 150, 30);
    GUI.StaticSetFontSize(levelLabel, UIDefine.FontSizeL);
    GUI.StaticSetAlignment(levelLabel, TextAnchor.MiddleCenter);
    GUI.SetColor(levelLabel, UIDefine.BrownColor);

    local levelSelectBtn = GUI.ButtonCreate(gemMergeGroup, "levelSelectBtn", "1801102010", -315, -245, Transition.ColorTint, "", 160, 40, false)
    GUI.RegisterUIEvent(levelSelectBtn, UCE.PointerClick, "EquipGemMergeUI", "OnLevelSelectBtnClick");
	_gt.BindName(levelSelectBtn,"levelSelectBtn");
    local levelText = GUI.CreateStatic(levelSelectBtn, "levelText", "1级", -10, 0, 150, 30);
    GUI.StaticSetFontSize(levelText, UIDefine.FontSizeL);
    GUI.StaticSetAlignment(levelText, TextAnchor.MiddleCenter);
    GUI.SetColor(levelText, UIDefine.BrownColor);
    _gt.BindName(levelText,"levelText");

    local arrow = GUI.ImageCreate(levelSelectBtn, "arrow", "1800707070", 55, 0)
	
    local consumeText = GUI.CreateStatic(Merge_Bg, "consumeText", "消耗", -253, 193, 100, 30)
    GUI.SetColor(consumeText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(consumeText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleCenter)

    local consumeBg = GUI.ImageCreate(Merge_Bg, "consumeBg", "1800700010", -123, 194, false, 180, 35)
    local coin = GUI.ImageCreate(consumeBg, "coin", "1800408280", -74, -1, false, 36, 36)
    local num = GUI.CreateStatic(consumeBg, "num", "100", 0, 0, 160, 30)
	_gt.BindName(num, "EquipGemMergeUI.num_Money_Cost_Number")
	
	--test("=========Money_Cost_Number = "..Money_Cost_Number)
    GUI.SetColor(num, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
    GUI.SetAnchor(num, UIAnchor.Center)
    GUI.SetPivot(num, UIAroundPivot.Center)
    GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
	
	local wnd= GUI.GetWnd("EquipUI")
    local panelBg =EquipUI.guidt.GetUI("panelBg")
    local levelSelectCover = GUI.ButtonCreate(gemMergeGroup, "levelSelectCover", "1800400220", 0, GUI.GetPositionY(panelBg), Transition.ColorTint,"",GUI.GetWidth(wnd),GUI.GetHeight(wnd),false);
    GUI.RegisterUIEvent(levelSelectCover, UCE.PointerClick, "EquipGemMergeUI", "OnLevelSelectCoverClick");
    _gt.BindName(levelSelectCover,"levelSelectCover")
    GUI.SetVisible(levelSelectCover,false)
	
    local border = GUI.ImageCreate(levelSelectCover, "border", "1800400290", -315, 165,false,175,40 * 8 + 10)
    UILayout.SetSameAnchorAndPivot(border, UILayout.Top);
	
    local levelScr =
        GUI.LoopScrollRectCreate(
        levelSelectCover,
        "levelScr",
        -315,
        170,
        165,
        40 * 8,
        "EquipGemMergeUI",
        "CreatLevelItemPool",
        "EquipGemMergeUI",
        "RefreshLevelScr",
        0,
        false,
        Vector2.New(160, 40),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
	_gt.BindName(levelScr, "levelScr")
    GUI.SetAnchor(levelScr, UIAnchor.Top)
    GUI.SetPivot(levelScr, UIAroundPivot.Top)
    GUI.SetVisible(levelSelectCover, false)

end

function EquipGemMergeUI.CreatLevelItemPool()
    local scroll = _gt.GetUI("levelScr")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local level = GUI.ButtonCreate(scroll, "level"..tostring(curCount), "1801102010", 0, 0, Transition.ColorTint, "级", 150, 40, false)
    GUI.ButtonSetTextColor(level, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(level, UIDefine.FontSizeM)
    GUI.SetAnchor(level, UIAnchor.Top)
    GUI.RegisterUIEvent(level, UCE.PointerClick, "EquipGemMergeUI", "OnLevelItemClick")
    local selected = GUI.ImageCreate(level, "selected", "1800600160", 0, -1, false, 166, 43)
	local LevelItemPool_redpot = GUI.ImageCreate(level, "LevelItemPool_redpot", "1800208080", -70,-1,false,25,25)
    GUI.SetVisible(LevelItemPool_redpot,false)
	return level
end

function EquipGemMergeUI.RefreshLevelScr(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local lv = GUI.GetByGuid(guid)
    if lv == nil then
        return
    end
    GUI.ButtonSetText(lv, data.levelConfig[index + 1].."级")

    local selected = GUI.GetChild(lv, "selected", false)
    if selected ~= nil then
		--test("====data.levelIndex = "..data.levelIndex)
        if data.levelIndex == index + 1 then
            --test(data.levelIndex)
            GUI.SetVisible(selected, true)
        else
            GUI.SetVisible(selected, false)
        end
    end
	
	local LevelItemPool_redpot = GUI.GetChild(lv, "LevelItemPool_redpot", false)
	GUI.SetVisible(LevelItemPool_redpot,false)
	if #data.EquipGemMergeUI_Check_Redpot_gemLevel > 0 then
		for k,v in pairs(data.EquipGemMergeUI_Check_Redpot_gemLevel) do
			if v == index + 1 then
				GUI.SetVisible(LevelItemPool_redpot,true)
			else
				--GUI.SetVisible(LevelItemPool_redpot,false)
			end
		end
	end
	--if data.EquipGemMergeUI_Check_Redpot == 1 then
	--	GUI.SetVisible(LevelItemPool_redpot,true)
	--else
	--	GUI.SetVisible(LevelItemPool_redpot,false)
	--end
end

function EquipGemMergeUI.CheckRedPoint()					--用于检测是否应该显示红点
	data.EquipGemMergeUI_Check_Redpot_gemID = {}
	data.EquipGemMergeUI_Check_Redpot_gemLevel = {}
	if GlobalProcessing.EquipGemMergeUI_Check_Redpot_gemID and GlobalProcessing.EquipGemMergeUI_Check_Redpot_gemLevel then
		data.EquipGemMergeUI_Check_Redpot_gemID = GlobalProcessing.EquipGemMergeUI_Check_Redpot_gemID
		data.EquipGemMergeUI_Check_Redpot_gemLevel = GlobalProcessing.EquipGemMergeUI_Check_Redpot_gemLevel
	end
	if EquipUI.tabIndex == 2 and EquipUI.tabSubIndex == 2 then
		EquipGemMergeUI.Refresh()
	end
	-- local count = LD.GetItemCount(item_container_type.item_container_gem_bag)
	-- local flag = false
	-- for i = 0, count - 1 do
	-- 	local itemGuid = LD.GetItemGuidByItemIndex(i, item_container_type.item_container_gem_bag);
	-- 	local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid, item_container_type.item_container_gem_bag);
	-- 	local itemDB = DB.GetOnceItemByKey1(itemId);
	-- 	local gem_Num_Have = LD.GetItemCountById(itemId, item_container_type.item_container_gem_bag)
	-- 	if itemDB.Type == 3 and itemDB.Subtype == 9 and gem_Num_Have >= 3 and itemDB['Itemlevel'] < 10 then
	-- 		table.insert(data.EquipGemMergeUI_Check_Redpot_gemID, itemId);
	-- 		table.insert(data.EquipGemMergeUI_Check_Redpot_gemLevel, itemDB['Itemlevel']);
	-- 	end
	-- end
	-- if #data.EquipGemMergeUI_Check_Redpot_gemID > 0 then
	-- 	flag = true
	-- end
	-- return flag
end

function EquipGemMergeUI.MergeSuccess()
	GUI.OpenWnd("ShowEffectUI", 3000001737)
	ShowEffectUI.SetTimeOff(1)
end

function EquipGemMergeUI.OnMergeBtnClick()
	EquipGemMergeUI.Check_Whether_Bind()
    local gem_Id = EquipGemMergeUI.GetCurGemId()
	local eqiupIcon_Bef = EquipUI.guidt.GetUI("eqiupIcon_Bef")
	local Enough = GUI.GetData(eqiupIcon_Bef, "Enough")
	if gem_Id and Enough == "true" then
		CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "ComposeGem",gem_Id, data.T_Or_F_Num)
	elseif gem_Id and Enough == "false" then
		gem_Id = gem_Id - 1
		local Merge_Bg = _gt.GetUI("Merge_Bg")
		local tips = Tips.CreateByItemId(gem_Id, Merge_Bg, "tips", -150, 0, 40)
		GUI.SetData(tips, "ItemId", tostring(gem_Id))
		_gt.BindName(tips, "GemTips")
		local wayBtn = GUI.ButtonCreate(tips, "wayBtn", "1800402110", 0, -10, Transition.ColorTint, "获取途径", 150, 50, false)
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(wayBtn, UCE.PointerClick, "EquipGemMergeUI", "OnClickGemWayBtn")
        GUI.AddWhiteName(tips, GUI.GetGuid(wayBtn))
	end
end

function EquipGemMergeUI.OnClickGemWayBtn()
	local tips = _gt.GetUI("GemTips")
    if tips then
        Tips.ShowItemGetWay(tips)
    end
end

function EquipGemMergeUI.OnMergeBtnClick_All_C()						--给服务器发送请求
	EquipGemMergeUI.Check_Whether_Bind()
	local gem_Id = EquipGemMergeUI.GetCurGemId()
	local eqiupIcon_Bef = EquipUI.guidt.GetUI("eqiupIcon_Bef")
	local Enough = GUI.GetData(eqiupIcon_Bef, "Enough")
	if gem_Id == nil then
		return
	elseif gem_Id and Enough == "true" then
		CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "ComposeGemAll", gem_Id, data.T_Or_F_Num)
	elseif gem_Id and Enough == "false" then
		gem_Id = gem_Id - 1
		local Merge_Bg = _gt.GetUI("Merge_Bg")
		local tips = Tips.CreateByItemId(gem_Id, Merge_Bg, "tips", -150, 0, 40)
		GUI.SetData(tips, "ItemId", tostring(gem_Id))
		_gt.BindName(tips, "GemTips")
		local wayBtn = GUI.ButtonCreate(tips, "wayBtn", "1800402110", 0, -10, Transition.ColorTint, "获取途径", 150, 50, false)
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(wayBtn, UCE.PointerClick, "EquipGemMergeUI", "OnClickGemWayBtn")
        GUI.AddWhiteName(tips, GUI.GetGuid(wayBtn))
	end
end

function EquipGemMergeUI.OnMergeBtnClick_All_S(targetNum, consumeNum)						--服务器调用
	local Merge_All_Panel = _gt.GetUI("Merge_All_Panel")
	GUI.SetVisible(Merge_All_Panel, true)
	local Merge_All_Main_Txt = _gt.GetUI("Merge_All_Main_Txt")
	local gem_Id = EquipGemMergeUI.GetCurGemId()
	local Gem_Name = DB.GetOnceItemByKey1(gem_Id)
	GUI.StaticSetText(Merge_All_Main_Txt, "可合成"..targetNum.."个"..Gem_Name['Name'])
	local Merge_All_Cost_Num = _gt.GetUI("Merge_All_Cost_Num")
	GUI.StaticSetText(Merge_All_Cost_Num, ""..consumeNum)
	EquipGemMergeUI.OnMergeBtnClick_All_targetNum = targetNum
	EquipGemMergeUI.OnMergeBtnClick_All_consumeNum = consumeNum
end

function EquipGemMergeUI.OnMergeBtnClick_All_Finish()
	local Merge_All_Panel = _gt.GetUI("Merge_All_Panel")
	
	local gem_Id = EquipGemMergeUI.GetCurGemId()
	
	if gem_Id == nil then
		return
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "GiveAllGem",gem_Id, EquipGemMergeUI.OnMergeBtnClick_All_targetNum, EquipGemMergeUI.OnMergeBtnClick_All_consumeNum, data.T_Or_F_Num)
	GUI.SetVisible(Merge_All_Panel, false)
	EquipGemMergeUI.OnMergeBtnClick_All_targetNum = 0
	EquipGemMergeUI.OnMergeBtnClick_All_consumeNum = 0
end

function EquipGemMergeUI.OnLevelSelectBtnClick()
	test("===================OnLevelSelectBtnClick")
    local levelSelectCover = _gt.GetUI("levelSelectCover");
    GUI.SetVisible(levelSelectCover,true)
	local levelScr = _gt.GetUI("levelScr")
	GUI.LoopScrollRectSetTotalCount(levelScr, #data.levelConfig)
	GUI.LoopScrollRectRefreshCells(levelScr)
end

function EquipGemMergeUI.RefreshLeftItem(guid, index)
	local gem_Id = EquipGemMergeUI.GetCurGemId(index)
	EquipScrollItem.RefreshLeftItemByGemId(guid, gem_Id)

	local attrId = DB.GetOnceItem_AttByKey1(gem_Id)['Att1']
	local attrValue = DB.GetOnceItem_AttByKey1(gem_Id)['Att1Max']

	local attrId_2 = DB.GetOnceItem_AttByKey1(gem_Id)['Att2']
	local attrValue_2 = DB.GetOnceItem_AttByKey1(gem_Id)['Att2Max']

	EquipScrollItem.RefreshLeftItemByGemIdEx(guid, EquipGemMergeUI.GetCurGemId(index),attrId,attrValue,attrId_2,attrValue_2)

    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end

	GlobalProcessing.SetRetPoint(item,false)
	if #data.EquipGemMergeUI_Check_Redpot_gemID > 0 then
		for k, v in pairs(data.EquipGemMergeUI_Check_Redpot_gemID) do
			if tonumber(v + 1) == tonumber(gem_Id) then
				GlobalProcessing.SetRetPoint(item,true)
			end
		end
	end
end


function EquipGemMergeUI.OnLeftItemClick(guid)
	local item = GUI.GetByGuid(guid)
	data.index = GUI.CheckBoxExGetIndex(item) + 1
	local Index = data.index
	EquipGemMergeUI.Chose_Gem_Id = EquipGemMergeUI.GetCurGemId(Index)
    GUI.CheckBoxExSetCheck(item, true)
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end

    data.firstGuid=nil
    data.secondGuid=nil
    data.equipGemIndex=1
    EquipGemMergeUI.Refresh();
end

function EquipGemMergeUI.GetCurGemId(index)
    if index == nil then
        index = data.index
    end
	
	if not data.levelConfig then
		return nil, nil
	end
	
	if not data.config then
		return nil, nil
	end
	
    local curLevel = data.levelConfig[data.levelIndex]
    local configData = data.config[curLevel][index]
    return configData.ItemId,configData.SubItemId;
end

function EquipGemMergeUI.Merge_All_CancelClick()
	local Merge_All_Panel = _gt.GetUI("Merge_All_Panel")
	GUI.SetVisible(Merge_All_Panel, false)
end

function EquipGemMergeUI.Check_Whether_Bind()
	local check = EquipUI.guidt.GetUI("bindBtn")
	local T_Or_F = GUI.CheckBoxExGetCheck(check)		--判断是否勾选"优先使用非绑材料"
	if T_Or_F == true then						--与服务器约定的格式，0代表false，1代表true
		data.T_Or_F_Num = 1
	else
		data.T_Or_F_Num = 0
	end
end