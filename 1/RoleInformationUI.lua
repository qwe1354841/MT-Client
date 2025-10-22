RoleInformationUI = {}

-- 代理可配置
-- 是否开启显示曾用名功能 开启true 关闭nil
RoleInformationUI.isActiveNameHistory = true

RoleInformationUI.VIPLevel = {}
local _gt = UILayout.NewGUIDUtilTable()
local LabelList = {
    [1] = { "名称", "name" },
    [2] = { "等级", "level" },
    [3] = { "门派", "job" },
    [4] = { "帮派", "faction" },
}
local BtnList = {
    [1] = { "移除黑名单", "remove", "OnRemoveFromBlackName", -30, 140 },
    [2] = { "邀请入帮", "invite", "OnInviteToMyFaction", 156, 120 },
    [3] = { "加为好友", "addFriend", "OnAddFriend", 328, 120 },
}
local EquipBtnPos = {
    [0] = { -60, 240 },
    [1] = { -150, 190 },
    [2] = { -200, 100 },
    [3] = { -200, 10 },
    [4] = { -150, -80 },
    [5] = { 60, 240 },
    [6] = { 150, 190 },
    [7] = { 200, 100 },
    [8] = { 200, 10 },
    [9] = { 150, -80 },
}

RoleInformationUI.RoleInfo = nil
RoleInformationUI.RoleGuildName = "无"

function RoleInformationUI.Main(parameter)
    test("RoleInformationUI")_gt = UILayout.NewGUIDUtilTable()

    local _Panel = GUI.WndCreateWnd("RoleInformationUI", "RoleInformationUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetIgnoreChild_OnVisible(_Panel,true)
    --创建背景
    local _GreyBack = GUI.ImageCreate( _Panel,"GreyBack", "1800400220", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
    UILayout.SetSameAnchorAndPivot(_GreyBack, UILayout.Center)
    GUI.SetIsRaycastTarget(_GreyBack, true)
    _GreyBack:RegisterEvent(UCE.PointerClick)

    local _PanelBack = GUI.ImageCreate( _Panel,"PanelBack", "1800600180", -142, -312, false, 286, 54)
    _gt.BindName(_PanelBack, "PanelBack")
    UILayout.SetSameAnchorAndPivot(_PanelBack, UILayout.Center)
    local _PanelBack3 = GUI.ImageCreate( _PanelBack,"PanelBack3", "1800600181", 0, 0, false, 286, 54)
    UILayout.SetAnchorAndPivot(_PanelBack3, UIAnchor.Right, UIAroundPivot.Left)
    local _PanelBack4 = GUI.ImageCreate( _PanelBack,"PanelBack4", "1800600182", 143, -1, false, 572, 612)
    UILayout.SetAnchorAndPivot(_PanelBack4, UIAnchor.Bottom, UIAroundPivot.Top)
    local _TitleBack = GUI.ImageCreate( _PanelBack,"TitleBack", "1800600190", 144, 29)
    UILayout.SetAnchorAndPivot(_TitleBack, UIAnchor.Top, UIAroundPivot.Center)

    --关闭按钮
    local _CloseBtn = GUI.ButtonCreate( _PanelBack,"CloseBtn", "1800302120", 286, 2, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(_CloseBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(_CloseBtn, UCE.PointerClick, "RoleInformationUI", "OnClose")

    local _TitleName = GUI.CreateStatic( _PanelBack,"TitleName", "角色信息", 167, 30, 150, 35)
    UILayout.SetAnchorAndPivot(_TitleName, UIAnchor.Top, UIAroundPivot.Center)
    UILayout.StaticSetFontSizeColorAlignment(_TitleName, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)

    local modelBg = GUI.ImageCreate(_PanelBack, "modelBg", "1800221230", 140, 249)
    _gt.BindName(modelBg,"modelBg")
    UILayout.SetSameAnchorAndPivot(modelBg, UILayout.Center)
    --战斗力
    local fightValueBg = GUI.ImageCreate(_PanelBack, "fightValueBg", "1800201240", 142, 404)
    UILayout.SetSameAnchorAndPivot(fightValueBg, UILayout.Center)
    -- 这里是战力右边的小剑图标
    --local tempSp = GUI.ImageCreate(fightValueBg, "fightValueFlower1", "1800407010", -85, 0)
    --UILayout.SetSameAnchorAndPivot(tempSp, UILayout.Center)
    local tempSp = GUI.ImageCreate(fightValueBg, "fightValueFlower2", "1800404020", 10, 0)
    UILayout.SetSameAnchorAndPivot(tempSp, UILayout.Left)
    local fightValue = GUI.CreateStatic(fightValueBg, "fightValue", "", 10, 0, 200, 30)
    _gt.BindName(fightValue, "fightValue")
    UILayout.SetSameAnchorAndPivot(fightValue, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(fightValue, UIDefine.FontSizeL, UIDefine.White2Color, TextAnchor.MiddleCenter)

    --几组文本框
    local txt = GUI.CreateStatic(_PanelBack, "titleTip", "称号", -10, 459, 100, 30)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    tempSp = GUI.ImageCreate(_PanelBack, "titleBg", "1800700010", 140, 459, false, 240, 30)
    UILayout.SetSameAnchorAndPivot(tempSp, UILayout.Center)
    txt = GUI.CreateStatic(tempSp, "titleText", "", 0, 0, 200, 30, "system", true)
    _gt.BindName(txt, "titleText")
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.White2Color, TextAnchor.MiddleCenter)
    for i = 1, #LabelList do
        local txt = GUI.CreateStatic(_PanelBack, LabelList[i][2] .. "Tip", LabelList[i][1], i % 2 == 0 and 170 or -80, i > 2 and 539 or 499, 100, 30)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
        tempSp = GUI.ImageCreate(_PanelBack, LabelList[i][2] .. "Bg", "1800700010", i % 2 == 0 and 300 or 40, i > 2 and 539 or 499, false, 190, 30)
        UILayout.SetSameAnchorAndPivot(tempSp, UILayout.Center)
        txt = GUI.CreateStatic(tempSp, LabelList[i][2] .. "Text", "", 0, 0, 140, 26, "system", true)
        _gt.BindName(txt, LabelList[i][2].."Text")
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.White2Color, TextAnchor.MiddleCenter)
    end

    -- 在名称上加个眼镜按钮 用来查看角色曾用名
    RoleInformationUI.historyNameClass.createButton()

    --vip等级
    local VipV = GUI.ImageCreate(_PanelBack, "vipV", "1801605010", 105,502, false, 18,15)
    local vipVNum1 = GUI.ImageCreate(_PanelBack, "vipVNum1", "1801605020", 116, 500, false, 13,20)
    local vipVNum2 = GUI.ImageCreate(_PanelBack, "vipVNum2", "1801605020", 127, 500, false, 13,20)
    GUI.SetVisible(vipVNum2,false)
    --三个按钮
    for i = 1, #BtnList do
        local btn = GUI.ButtonCreate(_PanelBack, BtnList[i][2], "1800402110", BtnList[i][4], 589, Transition.ColorTint, BtnList[i][1], BtnList[i][5], 45, false)
        GUI.SetEventCD(btn,UCE.PointerClick, 1)
        _gt.BindName(btn, BtnList[i][2].."Btn")
        GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(btn, 24)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "RoleInformationUI", BtnList[i][3])
    end

    --装备框
    for i = 0, 9 do
        local equipItem = ItemIcon.Create(_PanelBack, "equipItem" .. i, 0,0)
        _gt.BindName(equipItem,"equipItem"..i)
        GUI.SetPositionX(equipItem, EquipBtnPos[i][1]+142)
        GUI.SetPositionY(equipItem, -EquipBtnPos[i][2]+308)
        GUI.RegisterUIEvent(equipItem, UCE.PointerClick, "RoleInformationUI", "EquipClick")
        GUI.ItemCtrlSetIndex(equipItem, i)
    end

    CL.RegisterMessage(GM.FriendListUpdate, "RoleInformationUI", "OnFriendListUpdate")
end

function RoleInformationUI.EquipClick(guid)
    local _Item = GUI.GetByGuid(guid)
    if _Item then
        local index = GUI.ItemCtrlGetIndex(_Item)
        local _PanelBack = _gt.GetUI("PanelBack")
        local item = RoleInformationUI.GetSiteEquip(index)
        if item then
            Tips.CreateByItemData(item, _PanelBack, "itemTips", 150, 310, nil, nil, nil, RoleInformationUI.GetRoleSuitInfos())
        end
    end
end

function RoleInformationUI.OnDestroy()
    CL.UnRegisterMessage(GM.FriendListUpdate, "RoleInformationUI", "OnFriendListUpdate")
end

function RoleInformationUI.OnFriendListUpdate()
    RoleInformationUI.SwitchFriendState()
end

function RoleInformationUI.GetSiteEquip(index)
    if RoleInformationUI.RoleInfo.equips and RoleInformationUI.RoleInfo.equips.items then
        local Count = RoleInformationUI.RoleInfo.equips.items.Length
        for i = 0, Count-1 do
            if RoleInformationUI.RoleInfo.equips.items[i].site == index then
                return RoleInformationUI.RoleInfo.equips.items[i]
            end
        end
    end
    return nil
end

function RoleInformationUI.GetRoleSuitInfos()
    local suits = {}
    if RoleInformationUI.RoleInfo.equips and RoleInformationUI.RoleInfo.equips.items and GlobalUtils.suitConfig then
        local Count = RoleInformationUI.RoleInfo.equips.items.Length
        for i = 0, Count-1 do
            local suitName=RoleInformationUI.RoleInfo.equips.items[i]:GetStrCustomAttr(GlobalUtils.suitConfig.Sign_STR)
            table.insert(suits, suitName)
        end
        return suits
    end
    return nil
end

function RoleInformationUI.UpdatePanelInfo()
    --显示模型
    RoleInformationUI.ShowRoleModel()
    --显示装备
    for i = 0, 9 do
        local equipItem = _gt.GetUI("equipItem"..i)
        if equipItem then
            local item = RoleInformationUI.GetSiteEquip(i)
            if item then
                ItemIcon.BindItemData(equipItem, item,true)
            else
                ItemIcon.SetEmpty(equipItem)
            end
        end
    end
    --显示数据杂项
    local fightValue = _gt.GetUI("fightValue")
    if fightValue then
        GUI.StaticSetText(fightValue, tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrFightValue)))
    end
    local title = _gt.GetUI("titleText")
    if title then
        local titleID = tonumber(tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrTitle)))
        local titleName = DB.GetOnceTitleByKey1(titleID).Name
        if titleName==nil or string.len(titleName)==0 then
            titleName = "无"
        end
        GUI.StaticSetText(title, titleName)
    end
    --显示VIP等级
    local _PanelBack = _gt.GetUI("PanelBack")
    local level = tonumber(RoleInformationUI.VIPLevel[tostring(RoleInformationUI.RoleInfo.guid)])
	if not level or level == 0 then
		level = tonumber(tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrVip)))
	end
	
    local VipNum1 = GUI.GetChild(_PanelBack,"vipVNum1",false)
    local VipNum2 = GUI.GetChild(_PanelBack,"vipVNum2",false)
    if level then
        if level >= 10 then
            if VipNum1 and VipNum2 then
                local l = math.floor(level / 10)
                if l > 9 then
                    test("设置VIP等级出错，当前设置等级：" .. level)
                    l = 9
                end
                local h = level % 10
                local tmp = { VipNum1, VipNum2 }
                local picNum = { l, h }
                local picbase = { 1801605020, 1801605020}
                for i = 1, 2 do
                    local pic = picbase[i]
                    if picNum[i] then
                        pic = pic + picNum[i]
                    end
                    if i == 1 then
                        GUI.SetVisible(tmp[i], true)
                    elseif i == 2 then
                        local b = h >= 0
                        GUI.SetVisible(tmp[i], b)
                    else
                        GUI.SetVisible(tmp[i], true)
                    end
                    GUI.ImageSetImageID(tmp[i], tostring(pic))
                end
            end
        else
            GUI.ImageSetImageID(VipNum1, tostring(1801605020+level))
        end
    end

    local guildName = RoleInformationUI.GetRoleStrCustomData(RoleInformationUI.RoleInfo.customs.strdata, "__title_guild_name")
    if guildName==nil or string.len(guildName)==0 then
        guildName = "无"
    end
    RoleInformationUI.RoleGuildName = guildName
    local groupDatas = {RoleInformationUI.RoleInfo.name, tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrLevel)),
                        DB.GetSchool(tonumber(tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrJob1)))).Name,
                        guildName}
    for i = 1, #LabelList do
        local txt = _gt.GetUI(LabelList[i][2].."Text")

        if i == 1 and #groupDatas[i] >= 16 then
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSS, UIDefine.White2Color, TextAnchor.MiddleCenter)
            GUI.SetWidth(txt,127)
            GUI.SetPositionX(txt,-5)
        end

        GUI.StaticSetText(txt, groupDatas[i])
    end
    --显示按钮
    RoleInformationUI.SwitchFriendState()
end

function RoleInformationUI.SwitchFriendState()
    --是否在黑名单
    local removeBtn = _gt.GetUI("removeBtn")
    if removeBtn then
        if LD.IsInMyBlackList(tostring(RoleInformationUI.RoleInfo.guid)) then
            GUI.ButtonSetText(removeBtn, "移出黑名单")
        else
            GUI.ButtonSetText(removeBtn, "加入黑名单")
        end
    end

    local btn = _gt.GetUI("addFriendBtn")
    if btn then
        GUI.ButtonSetText(btn, LD.IsMyFriend(tostring(RoleInformationUI.RoleInfo.guid)) and "删除好友" or "加为好友")
    end
end

function RoleInformationUI.OnShow()
    if GUI.GetWnd("RoleInformationUI") == nil then
        return
    end
    RoleInformationUI.RoleInfo = CL.GetQueriedTargetRoleInfo()
    CL.SendNotify(NOTIFY.SubmitForm,"FormVip","GetVipLevel",RoleInformationUI.RoleInfo.guid)
    RoleInformationUI.UpdatePanelInfo()
end

function RoleInformationUI.ShowRoleModel()
    local _RoleLstNodeModel = _gt.GetUI("RoleLstNodeModel")
    if _RoleLstNodeModel == nil then
        local modelBg= _gt.GetUI("modelBg")
        _RoleLstNodeModel=GUI.RawImageCreate(modelBg,false,"RoleLstNodeModel","",0,17,2,false,438,438)
        _gt.BindName(_RoleLstNodeModel,"RoleLstNodeModel")
        _RoleLstNodeModel:RegisterEvent(UCE.Drag)
        _RoleLstNodeModel:RegisterEvent(UCE.PointerClick)
        GUI.AddToCamera(_RoleLstNodeModel)
        GUI.RawImageSetCameraConfig(_RoleLstNodeModel, "(0,1.41,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,10,0.01,1.2,0")
    end

    --模型
    local _RoleModel = _gt.GetUI("RoleModel")
    if _RoleModel == nil then
        _RoleModel = GUI.RawImageChildCreate(_RoleLstNodeModel, false, "RoleModel","", 0, 666)
        _gt.BindName(_RoleModel, "RoleModel")
        UILayout.SetSameAnchorAndPivot(_RoleModel, UILayout.Center)
        GUI.BindPrefabWithChild(_RoleLstNodeModel, GUI.GetGuid(_RoleModel))
        --GUI.RawImageChildSetModleRotation(_RoleModel, Vector3.New(0,0,0))
        GUI.RegisterUIEvent(_RoleModel, ULE.AnimationCallBack, "GuardUI", "OnAnimationCallBack")
    end

    local RoleID = tonumber(tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrRole)))
    local modelid = DB.GetRole(RoleID).Model
    local defaultModelID = modelid
    local headid = 0
	local DynJson = CL.GetStrCustomData("Model_DynJson1",RoleInformationUI.RoleInfo.guid)
    --角色的时装信息
    local _ClosthID = RoleInformationUI.GetRoleIntCustomData(RoleInformationUI.RoleInfo.customs.intdata, "Model_Clothes")
    if _ClosthID ~= 0 then
        local config = DB.GetOnceIllusionByKey1(_ClosthID)
        if config.Id ~= 0 then
            --如果是全身时装，则需要替换模型ID
            if config.Type == 0 then
                modelid = tonumber(tostring(config.Model))
				DynJson = ""
            elseif config.Type == 1 then
                headid = tonumber(tostring(config.Model))
            end
        end
    end
    --羽翼信息
    local _WingID = RoleInformationUI.GetRoleIntCustomData(RoleInformationUI.RoleInfo.customs.intdata, "Model_Wing")
    local _WingLevel = 0
    local _WingModelID = 0
    if _WingID ~= 0 then
        _WingLevel = RoleInformationUI.GetRoleIntCustomData(RoleInformationUI.RoleInfo.customs.intdata, "WingGrow_Stage")
        local _Config = DB.GetOnceIllusionByKey1(_WingID)
        _WingModelID = tonumber(tostring(_Config.Model))
    end

    local dyn1 = tonumber(tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrColor1)))
    local dyn2 = tonumber(tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrColor2)))
    local itemID = tonumber(tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrWeaponId)))
    local config = DB.GetOnceItemByKey1(itemID)
    local WeaponID = 0
    if RoleID == config.Role or config.Role == 0 then
        WeaponID = tonumber(tostring(config.ModelRole1))
    elseif RoleID == config.Role2 then
        WeaponID = tonumber(tostring(config.ModelRole2))
    end
    local Gender = tonumber(tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrGender)))
    local WeaponEffect = tonumber(tostring(RoleInformationUI.GetRoleAttr(RoleInformationUI.RoleInfo.attrs, RoleAttr.RoleAttrEffect1)))
    ModelItem.Bind(_RoleModel, modelid, dyn1, dyn2, eRoleMovement.STAND_W1, WeaponID, Gender,WeaponEffect, headid, defaultModelID)
    GUI.ReplaceWing(_RoleModel, _WingModelID, _WingLevel)

    --装备和宝石特效
    local equipLevel = RoleInformationUI.GetRoleIntCustomData(RoleInformationUI.RoleInfo.customs.intdata, "EquipRewardLevel")
    local gemLevel = RoleInformationUI.GetRoleIntCustomData(RoleInformationUI.RoleInfo.customs.intdata, "GemRewardLevel")
    ModelItem.BindRoleEquipGemEffectWithLevel(_RoleModel,equipLevel,gemLevel)
	
	--染色
	if DynJson ~= "" then
		if UIDefine.IsFunctionOrVariableExist(GUI,"RefreshDyeSkinJson") then
			GUI.RefreshDyeSkinJson(_RoleModel, DynJson, "")
		end
	end
end

function RoleInformationUI.GetRoleAttr(attrs, attType)
    if attrs then
        local attr = System.Enum.ToInt(attType)
        local Count = attrs.Count
        for i = 0, Count-1 do
            if attrs[i].attr == attr then
                return  attrs[i].value
            end
        end
    end
    return 0
end

function RoleInformationUI.GetRoleIntCustomData(datas, key)
    if datas then
        local Count = datas.Count
        for i = 0, Count-1 do
            if datas[i].key == key then
                return tonumber(tostring(datas[i].value))
            end
        end
    end
    return 0
end

function RoleInformationUI.GetRoleStrCustomData(datas, key)
    if datas then
        local Count = datas.Count
        for i = 0, Count-1 do
            if datas[i].key == key then
                return datas[i].value
            end
        end
    end
    return ""
end

function RoleInformationUI.OnClose()
    GUI.DestroyWnd("RoleInformationUI")
end

function RoleInformationUI.OnRemoveFromBlackName()
    if LD.IsInMyBlackList(tostring(RoleInformationUI.RoleInfo.guid)) then
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "RemoveBlackList", RoleInformationUI.RoleInfo.guid)
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "AddBlackList", RoleInformationUI.RoleInfo.guid)
    end
end

function RoleInformationUI.OnAddFriend()
    if LD.IsMyFriend(tostring(RoleInformationUI.RoleInfo.guid)) then
        GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", "是否删除好友？", "RoleInformationUI", "确定", "OnDelFriendConfirmYes", "取消")
    else
        if LD.IsInMyBlackList(tostring(RoleInformationUI.RoleInfo.guid)) then
            CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "RemoveBlackList", tostring(RoleInformationUI.RoleInfo.guid))
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyFriend", tostring(RoleInformationUI.RoleInfo.guid))
    end
end

function RoleInformationUI.OnDelFriendConfirmYes()
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "DeleteFriend", tostring(RoleInformationUI.RoleInfo.guid))
end

function RoleInformationUI.OnInviteToMyFaction()
    if RoleInformationUI.RoleGuildName ~= "无" then
        CL.SendNotify(NOTIFY.ShowBBMsg, "对方已有帮派，无法邀请")
        return
    end
    local FactionData = LD.GetGuildData()
    if FactionData.guild == nil or tostring(FactionData.guild.guid) == "0" then
        CL.SendNotify(NOTIFY.ShowBBMsg, "你没有加入帮派，无法邀请")
        return
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 19, tostring(RoleInformationUI.RoleInfo.guid))
end



------------------------------------------------------------------历史改名记录类-----------------------------------------------------------------------
RoleInformationUI.historyNameClass = {}
-- 创建查看按钮
RoleInformationUI.historyNameClass.createButton = function () 

    -- 检查是否开启角色历史名称
    if not RoleInformationUI.isActiveNameHistory  then
        return 
    end

    local PanelBack = _gt.GetUI("PanelBack")
    local parent = GUI.GetChild(PanelBack,LabelList[1][2].."Bg")
    if parent == nil then
        test("RoleInformationUI.historyNameClass.createButton = function () 父节点为nil")
        return 
    end

    local button = GUI.ButtonCreate( parent,"showHistoryNameButton", "1800702060", -2, -1, Transition.ColorTint,'',30,30,false)
    UILayout.SetSameAnchorAndPivot(button,UILayout.Left)
    GUI.RegisterUIEvent(button,UCE.PointerClick,"RoleInformationUI","historyNameClass.clickEvent")
    _gt.BindName(button,"showHistoryNameButton")

end

-- 创建历史名字显示列表
RoleInformationUI.historyNameClass.createNamesList = function()
    local parent  = _gt.GetUI("PanelBack")
    local list = GUI.GetChild(parent, "namesList")
    if list ~= nil then
        GUI.Destroy(list)
    end


    local nameCount = 0
    if RoleInformationUI.historyNameClass.namesData ~= nil and RoleInformationUI.historyNameClass.namesData ~= '' then
        nameCount = #RoleInformationUI.historyNameClass.namesData
        -- 最长显示10个 更多用滚动列表
        if nameCount > 10 then
            nameCount = 10
        end
    end

    local showTxt = nil
    if nameCount == 0 then
        showTxt = "无历史记录"
    else
        showTxt = "历史名称"
    end


    list = GUI.ImageCreate(parent, "namesList", "1800400290", 40, 457, false, 190, (nameCount==0 and 50 or 64 + nameCount*34))
    UILayout.SetSameAnchorAndPivot(list, UILayout.Bottom)
    GUI.SetVisible(list, true)
    -- 检测到点击就销毁
    GUI.SetIsRemoveWhenClick(list, true)
    local width = GUI.GetWidth(list)
    
    local title =
            GUI.CreateStatic(
            list,
            "showText",
            showTxt,
            0,
            0,
            width,
            60,
            "system"
        )
        UILayout.SetSameAnchorAndPivot(title, UILayout.Top)
        GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(title, UIDefine.FontSizeL)
        if nameCount > 0 then
            GUI.SetColor(title,UIDefine.OrangeColor)
        end


    local underline = GUI.ImageCreate(list, "underline", "1800600030", 0, -45, false, width, 4)
    UILayout.SetSameAnchorAndPivot(underline,UILayout.Top)

    local childSize = Vector2.New(width, 34)
    local namesScroll =
        GUI.ScrollRectCreate(
        list,
        "namesScroll",
        0,
        0,
        width,
        nameCount*childSize.y+13,
        0,
        false,
        childSize,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    UILayout.SetSameAnchorAndPivot(namesScroll, UILayout.Bottom)

    if nameCount > 0 then
        for i=#RoleInformationUI.historyNameClass.namesData,1,-1 do 
            local v = RoleInformationUI.historyNameClass.namesData[i]
            local name = GUI.CreateStatic(namesScroll,'name-'..i,v,0,0,0,0,"system")
            GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)
            GUI.StaticSetFontSize(name, UIDefine.FontSizeM)
        end
    end

end

-- 按钮点击事件
RoleInformationUI.historyNameClass.clickEvent = function(guid)
    if RoleInformationUI.RoleInfo.unid then
        RoleInformationUI.historyNameClass.request(RoleInformationUI.RoleInfo.unid)
    else
        test("RoleInformationUI.historyNameClass.clickEvent = function(guid)  role unid 不存在")
    end
end


-- 请求
function RoleInformationUI.historyNameClass.request(roleUnid)
    -- 显示弹出界面，当响应成功后刷新
    RoleInformationUI.historyNameClass.createNamesList()
    if roleUnid then
        CL.SendNotify(NOTIFY.SubmitForm,"FormChangeName","GetPlayerOldNameStr",tostring(roleUnid))
    end
end
-- 响应
-- 响应数据 该角色历史名称列表
RoleInformationUI.historyNameClass.namesData = nil
function RoleInformationUI.historyNameClass.response()
    if RoleInformationUI.historyNameClass.namesData then
        local names = string.split(RoleInformationUI.historyNameClass.namesData,'_')
        if names and names[1]=='' then
            table.remove(names,1)
        end
        RoleInformationUI.historyNameClass.namesData = names
    end
    RoleInformationUI.historyNameClass.createNamesList()
end