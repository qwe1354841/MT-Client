local function basevisFun(self, curLv, preLv, curTurnBron, ...)
    if self.FunctionSwitch then
        if UIDefine.FunctionSwitch == nil then
            return -1
        end
        if UIDefine.FunctionSwitch[self.FunctionSwitch] ~= "on" then
            return -1
        end
    end
    if self.Lv > curLv and curTurnBron < 1 then
        --关闭
        return -1
    end
    if preLv and self.Lv > preLv and curTurnBron == 0 then
        --"等待开启"
        return 0
    else
        --开启
        return 1
    end
end

local function newData(id, name, lv, visFun, functionSwitch)
    visFun = visFun or basevisFun
    return {Id = id, Name = name, Lv = lv, VisFun = visFun, FunctionSwitch = functionSwitch}
end

-- priority是战斗界面显示的排序，如果不填，则在战斗界面中不显示
MainUIBtnOpenDef = {
    Data = {
        newData(1, "包裹", 1),
        newData(2, "队伍", 25),
        newData(3, "好友", 1),
        newData(4, "任务", 1),
        newData(5, "技能", 12),
        newData(6, "帮派", 28),
        newData(7, "系统", 1),
        newData(8, "商城", 1),
        newData(9, "阵容", 13),
        newData(10, "活动", 25),
        newData(11, "商会", 30, nil, "Exchange"),
        newData(
            12,
            "装备",
            32,
            function(self, curLv, preLv, curTurnBron, ...)
                if UIDefine.FunctionSwitch == nil then
                    return -1
                end
                local key = {
                    "EquipCreat",
                    "EquipIntensify",
                    "EquipRebuild",
                    "EquipArtifice",
                    "EquipLevelUp",
                    "EquipGem",
                    "EquipLight",
                    "EquipBless"
                }
                local index = 0
                for i = 1, #key do
                    if UIDefine.FunctionSwitch[key[i]] == "on" then
                        break
                    end
                    index = i
                end
                if index == #key then
                    return -1
                end
                local tmp = basevisFun(self, curLv, preLv, curTurnBron, ...)
                return tmp
            end
        ),
        newData(13, "邮箱", 1),
        newData(14, "超值", 1),
        newData(15, "VIP", 1, nil, "VIP"),
        newData(16, "交易行", 30),
        newData(17, "排行", 40),
        newData(18, "称号", 1),
        newData(19, "兑换", 1),
        newData(20, "提升", 1,function ()
            return -1
        end),
        newData(21, "福利", 10),
        newData(
            22,
            "首充",
            1,
            function(self, curLv, preLv, curTurnBron, ...)
                local tmp = basevisFun(self, curLv, preLv, curTurnBron, ...)
                if tmp == -1 then
                    return tmp
                end
                if CL.GetIntCustomData("GotFirstRecharge") ~= 2 then
                    return 1
                else
                    return -1
                end
            end,
            "FirstRecharge"
        ),
        newData(23, "侍从", 13),
        --newData(24, "异兽", 40, nil, "GodAnimal"),
        newData(24, "变强", 25),
        --newData(26, "双倍", 35),
        newData(25, "祈福", 13, nil,  "Pray"),
		newData(26, "挂机", 25 , nil,  "HangUp"),
        newData(27, "生产", 41),
        newData(28, "辅助", 34),
        newData(
            29,
            "七日",
            5,
            function(self, curLv, preLv, curTurnBron, ...)
                if CL.GetIntCustomData("SevenDaySwitch") == 1 then
                    return 1
                else
                    return -1
                end
            end,
            "SevenDay"
        ),
        newData(30,"限时购",20,function ()
            if GlobalProcessing.DISCOUNT_DATA == nil then
                return -1
            else
                if #GlobalProcessing.DISCOUNT_DATA == 0 then
                    return -1
                else
                    return 1
                end
            end
        end),
		newData(31, "特惠", 1, nil, "DiscountShop"),
        newData(32, "刑天降世", 1,
            function (self, curLv, preLv, curTurnBron, ...)
                local tmp = basevisFun(self, curLv, preLv, curTurnBron, ...)
                if tmp == -1 then
                    return tmp
                end
                if GlobalProcessing.IntegralPK_SeverData == nil then
                    return -1
                else
                    local TimeLimit = GlobalProcessing.IntegralPK_SeverData[1].TimeLimit
                    local beginTime = TimeLimit[1]
                    local closeTime = TimeLimit[3]
                    local nowTime = os.date("!%Y-%m-%d %H:%M:%S",CL.GetServerTickCount())
                    local nowtime = UIDefine.GetTimeCountByFormat(nowTime)
                    local closetime = UIDefine.GetTimeCountByFormat(closeTime)
                    local begintime = UIDefine.GetTimeCountByFormat(beginTime)
                    if nowtime > begintime and nowtime < closetime then
                        return 1
                    end
                    return -1
                end
            end,
            "IntegralPK"
            -- nil,"VIP"
        ),
        newData(33, "开服冲榜", 1,
            function (self, curLv, preLv, curTurnBron, ...)
                local tmp = basevisFun(self, curLv, preLv, curTurnBron, ...)
                if tmp == -1 then
                    return tmp
                end
                if GlobalProcessing.RushRankData == nil then
                    return -1
                else
					local list = GlobalProcessing.RushRankData.RankList
					local NowTime = CL.GetServerTickCount()
					for i = 1, #list do
						local temp = list[i]
						if NowTime < temp.Retain_Time then
							return 1		
						end
					end
					return -1
                end
            end,
            "Act_RankList"
            -- nil,"VIP"
        ),
		newData(34, "密藏", 1, function ()
				if not GlobalProcessing.SeasonPass_FunctionSwitch then
					return -1
                else
					if GlobalProcessing.SeasonPass_FunctionSwitch ~= "on" then
						return -1
					else
                        return 1
                    end
                    return -1
                end
            end,
		"SeasonPass"),
        newData(35, "灵宝", 1, function ()
            if not GlobalProcessing.SpiritualEquipFunctionOpen then
                return -1
            else
                if GlobalProcessing.SpiritualEquipFunctionOpen ~= "on" then
                    return -1
                else
                    return 1
                end
            end
            return -1
        end,
		"SpiritualEquip"),
    },
    buttonRightBottomLst = {
        -- 汉字名称 btnKey btn图标 btn方法  btn文字图片 对应open表序号 是否接受功能表
        -- 右下角按钮
        {"装备", "equipBtn", "1800202100", "EquipUI", "1800204130", 12, true, priority = 12},
        {"技能", "skillBtn", "1800202090", "RoleSkillUI", "1800204120", 5, true, priority = 3},
        {"帮派", "factionBtn", "1800202120", "", "1800204150", 6, true, OnClick = "OnFactionClick", priority = 5},
        {"生产", "produceBtn", "1800202110", "ProduceUI", "1800204140", 27,  true, priority = 15},
        {"队  伍", "teamBtn", "1800202070", "TeamPanelUI", "1800204110", 2, true, priority = 2},
        {"侍  从", "retinueBtn", "1800202050", "GuardUI", "1800204100", 23, true, priority = 4},
        {"包裹", "bagBtn", "1800202080", "BagUI", "1800204170", 1, true, priority = 1},
        {"系统", "systemBtn", "1800202060", "SystemSettingUI", "1800204160", 7, true, priority = 6},
        {"辅  助", "PluginBtn", "1800202490", "PlugSystemUI", "1800204540", 28, true, priority = 17},
		{"变强", "BeStrongBtn", "1800202170", "BeStrongUI", "0", 24, true, priority = 9},
		{"挂机", "hangupBtn", "1800202410", "HangUpUI", "0", 26, true, priority = 16},
        {"灵宝", "spiritualEquipBtn", "1801720280", "SpiritualEquipUI", "1801720300", 35, true, priority = 18},
        GetPos = function(index)
            local maxCount = 7
            local tmp = math.floor(index / maxCount)
            return -((index % maxCount) * 70 + 12), 0 - tmp * 83
        end
    },
    buttonLeftTopLst = {		
		{"超值", "superValueBtn", "1800202510", "SuperValueUI", "0", 14, true, effect = "3403700000", priority = 18},
        {"商城", "storeBtn", "1800202020", "MallUI", "0", 8, true, priority = 7}, -- 节点修改完成
		--{"限时购", "DiscountBtn", "1800202530", "WelfareUI", "1800204590", 30,true,index = "index:4,index2:0", priority = 19},
        {"特惠", "DiscountShopBtn", "1800202530", "DiscountMallUI", "0", 31, true},
        {"密藏", "SeasonPassUIBtn", "1800202500", "SeasonPassUI", "0", 34, true},
		{"兑换", "ExchangeBtn", "1800202510", "ShopStoreUI", "0", 19, true},
        {"交易", "TradeBtn", "1800202440", "CommerceUI", "0", 16, true, priority = 11},
        --{"商会", "CommerceBtn", "1800202110", "CommerceUI", "0", 11, true},
        --{"异兽", "MythicalAnimalsBtn", "1800202090", "MythicalAnimalsUI", "0", 24, true},
        --{"双倍", "DoubleExpBtn", "1800202490", "DoubleExpUI", "0", 26, true},

        -- {"首充", "FirstRechargeBtn", "1800202010", "OpenDataWnd", "1800204530", 42,  false},
        -- {"刑天降世", "FightScoreRankBtn", "1800208240", "FightScoreRankWnd", "1800208250", 42,  false}
		{"VIP", "VIPBtn", "1801202010", "VipUI", "0", 15, false,effect = "3403700000"},
        {"首充", "firstRechargeBtn", "1800202010", "FirstRechargeUI", "0", 22, true, effect = "3403700000"},
        --{"刑天降世", "FightScoreRankBtn", "1800208240", "FightValueRankUI", "0", 32,  false, effect = "3403700000"},
        GetPos = function(index)
            local tmp = (index - 1) * 80
            return 40 + tmp, 0
        end
    },

    buttonLeftLst = {

        -- 左上角按钮
        {"活动", "activityBtn", "1800202040", "ActivityPanelUI", "0", 10, true, priority = 10}, -- 节点不变
		{"排行", "rankBtn", "1800202180", "RankUI", "0", 17, true, priority = 8},
		{"七日", "dayBtn", "1800202160", "Activity7DaysUI", "0", 29, true,effect = "3403700000", priority = 14},
        -- 节点不变
		{"福利", "WelfareBtn", "1800202390", "WelfareUI", "0", 21, true, priority = 13},
		--{"VIP", "VIPBtn", "1801202010", "VipUI", "0", 15, false,effect = "3403700000"},
        -- 节点修改完成
        -- {"变  强", "beStrongBtn", "1800202170", "OnBeStrongBtnClick", "1800204230", 21,  true},
        -- {"双倍挂机", "hangupBtn", "1800202410", "OnHangupClick", "1800204490", 34,  true},
        -- {"限时购", "DiscountBtn", "1800202530", "WelDiscountUI", "1800204590", 39,  true},
        -- 节点修改完成 ，
        -- {"称号", "TitleBtn", "1800202510", "TitleUI", "0", 18, true},
        --{"提升", "promoteBtn", "1800202400", "", "0", 20, false, OnClick = "OnPromoteClick"},
        {"祈福", "prayBtn", "1800202520", "PrayUI", "0", 25, true, priority = 20},
        --{"挂机", "hangupBtn", "1800202410", "HangUpUI", "0", 26, true, priority = 16},
		{"开服冲榜", "RushRankBtn", "1801706010", "RushRankUI", "0", 33,  false, effect = "3403700000"},
		{"限时购", "DiscountBtn", "1800202530", "WelfareUI", "1800204590", 30,true,index = "index:4,index2:0", priority = 19},
		{"刑天降世", "FightScoreRankBtn", "1800208240", "FightValueRankUI", "0", 32,  false, effect = "3403700000"},
        GetPos = function(index)
            local tmp = (index - 1) * 80
            return 40 + tmp, 80
        end	 
    },
    leftDynamicBtnList = {
        -- 名称   节点名     创建方法    是否可见
		{"即将开启的活动", "willOpenActivityGroup", "CreateWillOpenActivityBtn", "WillOpenActivityBtnVisible"},
        {"功能预览", "functionPreviewGroup", "CreateFunctionPreviewBtn", "FunctionPreviewBtnVisible"},
        --{"邮件", "mailGroup", "CreateMailBtn"},
        GetPos = function(index)
            local tmp = (index - 1) * 90
            return 0, 96 + tmp
        end
    }
}

function CanSystemOpen(id)
    local count = #MainUIBtnOpenDef.Data
    local level = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    for i = 1, count do
        if id == MainUIBtnOpenDef.Data[i].Id then
            return MainUIBtnOpenDef.Data[id].Lv <= level
        end
    end
    return false
end
