local MoneyBar = {}
_G.MoneyBar = MoneyBar

----------------------------------------------------脚本修改说明Start---------------------------------
--1. 若想要改变金币栏的金钱种类只需要  在posX增删相对应数量的数据       并在第45，46行恢复注释，二者选其一
----------------------------------------------------脚本修改说明End-----------------------------------


local posX = {
	[1] = { 0 };
	[2] = { -100, 100 };
	[3] = { -200, 0, 200 },
	--[4] = { -300, -100, 100, 300 }
}

function MoneyBar.Init()
	if not MoneyBar.isInit then
		CL.RegisterMessage(UM.ShowWnd, "MoneyBar", "OnShowWnd");
		MoneyBar.isInit = true;
	end
end

function MoneyBar.OnShowWnd(scriptName, parameter)
	if MoneyBar.Groups ~= nil then
		for i = #MoneyBar.Groups, 1, -1 do
			local groupGuid = MoneyBar.Groups[i];
			local group = GUI.GetByGuid(groupGuid);
			if group == nil then
				table.remove(MoneyBar.Groups, i);
			else
			local m_scriptName = GUI.GetData(group, "scriptName");
			if m_scriptName == scriptName then
				MoneyBar.RefreshGroup(group);
				return;
			end
			end
		end
	end
end

function MoneyBar.CreateDefault(parent, scriptName)
	MoneyBar.Init();
	local moneyBarGroup = MoneyBar.CreateGroup(parent, scriptName)
	
	--MoneyBar.ModifyData(moneyBarGroup, RoleAttr.RoleAttrIngot, RoleAttr.RoleAttrBindIngot,RoleAttr.RoleAttrGold ,RoleAttr.RoleAttrBindGold)
	MoneyBar.ModifyData(moneyBarGroup, RoleAttr.RoleAttrIngot, RoleAttr.RoleAttrBindIngot, RoleAttr.RoleAttrBindGold)
end

function MoneyBar.Create(parent, scriptName, ...)
	MoneyBar.Init();
	local moneyBarGroup = MoneyBar.CreateGroup(parent, scriptName)
	
	MoneyBar.ModifyData(moneyBarGroup, ...)
end

function MoneyBar.CreateGroup(parent, scriptName)
	local moneyBarGroup = GUI.GroupCreate(parent, "moneyBarGroup", 0, 0, GUI.GetWidth(parent), GUI.GetHeight(parent));
	UILayout.SetSameAnchorAndPivot(moneyBarGroup, UILayout.Center);
	GUI.SetData(moneyBarGroup, "scriptName", scriptName);
	if MoneyBar.Groups == nil then
		MoneyBar.Groups = {};
	end
	table.insert(MoneyBar.Groups, GUI.GetGuid(moneyBarGroup));
	return moneyBarGroup;
end

function MoneyBar.ModifyData(moneyBarGroup, ...)
	local moneyTypes = { ... }
	for i = 1, #moneyTypes do
		local moneyType = moneyTypes[i];
		GUI.SetData(moneyBarGroup, "MoneyTypeCount", #moneyTypes);
		CL.UnRegisterAttr(moneyType, MoneyBar.UpdateMoneyValue)
		CL.RegisterAttr(moneyType, MoneyBar.UpdateMoneyValue)
		local moneyItem = GUI.GetChild(moneyBarGroup, "moneyItem" .. i);
		local num = CL.GetAttr(moneyType);
		if moneyItem == nil then
			moneyItem = GUI.ButtonCreate(moneyBarGroup, "moneyItem" .. i, "1800400160", posX[#moneyTypes][i], 16, Transition.ColorTint, "", 150, 25, false)
			UILayout.SetSameAnchorAndPivot(moneyItem, UILayout.Top);
			local icon = GUI.ImageCreate(moneyItem, "icon", UIDefine.AttrIcon[moneyType], -65, 0);
			UILayout.SetSameAnchorAndPivot(icon, UILayout.Center);
			local numText = GUI.CreateStatic(moneyItem, "numText", UIDefine.ExchangeMoneyToStr(num), 0, 0, 100, 30);
			UILayout.SetSameAnchorAndPivot(numText, UILayout.Center);
			GUI.SetColor(numText, UIDefine.WhiteColor)
			GUI.StaticSetFontSize(numText, UIDefine.FontSizeS)
			GUI.StaticSetAlignment(numText, TextAnchor.MiddleCenter)
		
			local addBtn = GUI.ButtonCreate(moneyItem, "addBtn", "1800402100", 65, 0, Transition.ColorTint)
			UILayout.SetSameAnchorAndPivot(addBtn, UILayout.Center);
			GUI.RegisterUIEvent(addBtn, UCE.PointerClick, "MoneyBar", "OnAddBtnFunc"..i)
		end
		local attrInt = System.Enum.ToInt(moneyType)
		GUI.SetData(moneyItem, "AttrInt", attrInt);
		local icon = GUI.GetChild(moneyItem, "icon");
		local numText = GUI.GetChild(moneyItem, "numText");
		GUI.ImageSetImageID(icon, UIDefine.AttrIcon[moneyType]);
		GUI.StaticSetText(numText, UIDefine.ExchangeMoneyToStr(num));
	end
	
	for i = #moneyTypes + 1, GUI.GetChildCount(moneyBarGroup) do
		local moneyItem = GUI.GetChild(moneyBarGroup, "moneyItem" .. i);
		GUI.SetVisible(moneyItem, false);
	end
end

function MoneyBar.OnAddBtnFunc1()
	local msg = "是否前往充值界面"
	GlobalUtils.ShowBoxMsg2Btn("提示",msg,"MoneyBar","确认","SureJump","取消")
end

--跳转到商城充值界面
function MoneyBar.SureJump()
	GUI.OpenWnd("MallUI", "index:充值,index2:0")
end

--银元宝兑换
function MoneyBar.OnAddBtnFunc2()
	GUI.OpenWnd("ExchangeUI", "296,297")
end

--银币兑换
function MoneyBar.OnAddBtnFunc3()
	GUI.OpenWnd("ExchangeUI", "296,300")
end

function MoneyBar.UpdateMoneyValue(attrType, value)
	local attrInt = System.Enum.ToInt(attrType)
	local valueStr = tostring(value);
	if MoneyBar.Groups ~= nil then
		for i = #MoneyBar.Groups, 1, -1 do
			local groupGuid = MoneyBar.Groups[i];
			local group = GUI.GetByGuid(groupGuid);
			if group == nil then
				table.remove(MoneyBar.Groups, i);
			else
				local scriptName = GUI.GetData(group, "scriptName");
				local wnd = GUI.GetWnd(scriptName);
				if GUI.GetVisible(wnd) then
					MoneyBar.UpdateGroup(group, attrInt, valueStr)
				end
			end
		end
	end
end

function MoneyBar.UpdateGroup(moneyBarGroup, attrInt, valueStr)
	if moneyBarGroup == nil then
		return ;
	end
	local moneyTypeCount = tonumber(GUI.GetData(moneyBarGroup, "MoneyTypeCount"));
	for i = 1, moneyTypeCount do
		local moneyItem = GUI.GetChild(moneyBarGroup, "moneyItem" .. i);
		local m_attrInt = tonumber(GUI.GetData(moneyItem, "AttrInt"));
		if m_attrInt == attrInt then
			local numText = GUI.GetChild(moneyItem, "numText");
			GUI.StaticSetText(numText, UIDefine.ExchangeMoneyToStr(valueStr));
		end
	end
end

function MoneyBar.RefreshGroup(moneyBarGroup)
	if moneyBarGroup == nil then
		return ;
	end
	local moneyTypeCount = tonumber(GUI.GetData(moneyBarGroup, "MoneyTypeCount"));
	for i = 1, moneyTypeCount do
		local moneyItem = GUI.GetChild(moneyBarGroup, "moneyItem" .. i);
		local attrInt = tonumber(GUI.GetData(moneyItem, "AttrInt"));
		local moneyType = RoleAttr.IntToEnum(attrInt)
		local num = CL.GetAttr(moneyType);
		local numText = GUI.GetChild(moneyItem, "numText");
		GUI.StaticSetText(numText, UIDefine.ExchangeMoneyToStr(num));
	end
end