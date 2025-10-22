local UIDefine = {}
_G.UIDefine = UIDefine


--[[重新整理，合并相似或相同的颜色，更加清晰明确 Start]]--
UIDefine.WhiteColor = Color.New(255 / 255, 255 / 255, 255 / 255, 1) -- Color HexNumber: #ffffffff  白色
UIDefine.White2Color = Color.New(255 / 255, 246 / 255, 232 / 255, 1)  -- Color HexNumber: #fff6e8ff  淡白色
UIDefine.White3Color = Color.New(248 / 255, 244 / 255, 221 / 255, 1)   -- Color HexNumber: #f8f4ddff 淡白色
UIDefine.White4Color = Color.New(237 / 255, 232 / 255, 206 / 255, 1) -- Color HexNumber: #ede8ceff 淡白色

UIDefine.BlackColor = Color.New(0 / 255, 0 / 255, 0 / 255, 1)       -- Color HexNumber: #000000ff  黑色

UIDefine.BrownColor = Color.New(102 / 255, 49 / 255, 14 / 255, 1)   -- Color HexNumber: #66310eff  棕色
UIDefine.Brown2Color = Color.New(251 / 255, 220 / 255, 203 / 255, 1)   -- Color HexNumber: #FBDCB7ff 浅棕色
UIDefine.Brown3Color = Color.New(146 / 255, 72 / 255, 43 / 255, 1)   -- Color HexNumber: #92482bff , 亮棕色
UIDefine.Brown4Color = Color.New(109 / 255, 60 / 255, 20 / 255, 1)   -- Color HexNumber: #6D3C14ff 棕色4
UIDefine.Brown5Color = Color.New(98 / 255, 74 / 255, 60 / 255, 1)   -- Color HexNumber: #624A3Cff 棕色5
UIDefine.Brown6Color = Color.New(48 / 255, 12 / 255, 9 / 255, 1)   -- Color HexNumber: #624A3Cff 棕色6
UIDefine.Brown7Color = Color.New(229 / 255, 213 / 255, 195 / 255, 1)  -- Color HexNumber: #E5D5C3ff 薄棕色
UIDefine.Brown8Color = Color.New(217 / 255, 98 / 255, 30 / 255, 1)  -- Color HexNumber: #D9621Eff 棕色8

UIDefine.PurpleColor = Color.New(232 / 255, 85 / 255, 255 / 255, 1)   -- Color HexNumber: #E855FFff 紫色
UIDefine.Purple2Color = Color.New(240 / 255, 139 / 255, 255 / 255, 1) -- Color HexNumber: #f08bffff 浅紫色
UIDefine.Purple3Color = Color.New(249 / 255, 192 / 255, 109 / 255, 1) -- Color HexNumber: #f9c06dff 深紫色



UIDefine.YellowStdColor = Color.New(1, 1, 0, 1)   -- Color HexNumber: #FFFF00ff 黄色
UIDefine.YellowColor = Color.New(221 / 255, 210 / 255, 33 / 255, 1)   -- Color HexNumber: #ddd221ff 黄色
UIDefine.Yellow2Color = Color.New(172 / 255, 117 / 255, 39 / 255, 1)  -- Color HexNumber: #ac7529ff 深黄
UIDefine.Yellow3Color = Color.New(255 / 255, 223 / 255, 114 / 255, 1)  -- Color HexNumber: #ffdf72ff 浅黄色
UIDefine.Yellow4Color = Color.New(245 / 255, 237 / 255, 177 / 255, 1)  -- Color HexNumber: #f5edb1ff 薄黄
UIDefine.Yellow5Color = Color.New(251 / 255, 248 / 255, 234 / 255, 1) -- Color HexNumber: #fbf8eaff 淡黄

UIDefine.RedColor = Color.New(255 / 255, 0 / 255, 0 / 255, 1)   -- Color HexNumber: #FF0000ff 红色

UIDefine.BlueStdColor = Color.New(0, 0, 1, 1)   -- Color HexNumber: #0000ffff 蓝色
UIDefine.BlueColor = Color.New(66 / 255, 177 / 255, 240 / 255, 1)   -- Color HexNumber: #42B1F0ff 蓝色
UIDefine.Blue2Color = Color.New(14 / 255, 147 / 255, 216 / 255, 1)  -- Color HexNumber: #0e93d8ff 深蓝色
UIDefine.Blue3Color = Color.New(139 / 255, 194 / 255, 255 / 255, 1) -- Color HexNumber: #8bc2ffff 淡蓝色
UIDefine.SkyBlueColor = Color.New(22 / 255, 226 / 255, 171 / 255, 1) -- Color HexNumber: #16e2abff 天蓝色
UIDefine.EnhanceBlueColor = Color.New(57 / 255, 141 / 255, 219 / 255, 1) -- Color HexNumber: #398DDBff 天蓝色
UIDefine.Blue4Color = Color.New(0 / 255, 200 / 255, 233 / 255, 1) -- Color HexNumber: #00C8E9FF 亮蓝色

UIDefine.GreenStdColor = Color.New(0, 1, 0, 1)   -- Color HexNumber: #00ff00ff 绿色
UIDefine.GreenColor = Color.New(70 / 255, 220 / 255, 95 / 255, 1)   -- Color HexNumber: #46DC5Fff 绿色
UIDefine.Green2Color = Color.New(144 / 255, 245 / 255, 69 / 255, 1) -- Color Hex #90F545FF 黄绿色
UIDefine.Green3Color = Color.New(24 / 255, 233 / 255, 48 / 255, 1)   -- Color HexNumber: #18e930ff 深绿色
UIDefine.Green4Color = Color.New(155 / 255, 255 / 255, 155 / 255, 1)-- Color HexNumber: #9bff9bff 浅绿色
UIDefine.Green5Color = Color.New(0 / 255, 200 / 255, 0 / 255, 1)-- Color HexNumber: #00C800ff 清纯绿
UIDefine.Green6Color = Color.New(90 / 255, 255 / 255, 106 / 255, 1)-- Color HexNumber: #5aff6aff 亮绿色
UIDefine.Green7Color = Color.New(8 / 255, 175 / 255, 0 / 255, 1)-- Color HexNumber: #5aff6aff 技能tip绿
UIDefine.Green8Color = Color.New(0 / 255, 118 / 255, 51 / 255, 1)-- Color HexNumber: #007633ff 文字绿

UIDefine.GrayColor = Color.New(146 / 255, 146 / 255, 146 / 255, 1) -- Color HexNumber: #929292ff 灰色
UIDefine.Gray2Color = Color.New(98 / 255, 98 / 255, 98 / 255, 1) -- Color HexNumber: #626262ff 98度灰
UIDefine.Gray3Color = Color.New(200 / 255, 200 / 255, 200 / 255, 1) -- Color HexNumber: #c8c8c8ff 200度灰

UIDefine.OrangeColor = Color.New(255 / 255, 135 / 255, 0 / 255, 1)   -- Color HexNumber: #FF8700ff 橙色
UIDefine.Orange2Color = Color.New(162 / 255, 75 / 255, 21 / 255, 1)   -- Color HexNumber: #a24b15ff , 橘红

UIDefine.PinkColor = Color.New(255 / 255, 155 / 255, 155 / 255, 1)   -- Color HexNumber: #ff9b9bff , 粉红

--透明
UIDefine.Transparent = Color.New(1, 1, 1, 0) --透明
UIDefine.HalfTransparent = Color.New(1, 1, 1, 0.5) --透明

UIDefine.FontSizeSSS = 16
UIDefine.FontSizeSS = 18
UIDefine.FontSizeS = 20
UIDefine.FontSizeM = 22
UIDefine.FontSizeL = 24
UIDefine.FontSizeXL = 26
UIDefine.FontSizeXXL = 28

UIDefine.Vector2One = Vector2.New(1, 1)
UIDefine.Vector3One = Vector3.New(1, 1, 1)
UIDefine.Vector3Zero = Vector3.New(0, 0, 0)
UIDefine.Vector3Z = Vector3.New(0, 0, 1)	--新增
UIDefine.FontSizeM2FontSizeXL = Vector3.New(1.1, 1.1, 1.1)
UIDefine.PetRotation = Vector3.New(0, -45, 0)

UIDefine.OutLine_BlackColor = Color.New(0 / 255, 0 / 255, 0 / 255, 1)       -- Color HexNumber: #000000ff  黑色描边
UIDefine.OutLine_BrownColor = Color.New(153 / 255, 102 / 255, 77 / 255, 1)  -- Color HexNumber: #99664dff , 棕色描边
UIDefine.OutLine_GreenColor = Color.New(12 / 255, 102 / 255, 0 / 255, 1)   -- Color HexNumber: #0c6600ff , 绿色描边
UIDefine.OutLine_RedColor = Color.New(135 / 255, 1 / 255, 1 / 255, 1)  -- Color HexNumber: #870101ff , 红色描边
UIDefine.OutLine_BlueColor = Color.New(0 / 255, 55 / 255, 193 / 255, 1)  -- Color HexNumber: #0037c1ff , 蓝色描边
UIDefine.OutLine_PurpleColor = Color.New(112 / 255, 0 / 255, 159 / 255, 1)  -- Color HexNumber: #70009fff , 紫色描边
UIDefine.OutLine_YellowColor = Color.New(159 / 255, 71 / 255, 0 / 255, 1)  -- Color HexNumber: #9f4700ff , 黄色描边


UIDefine.OutLineDistance = 1 -- 描边像素
--[[重新整理，合并相似或相同的颜色，更加清晰明确 End]]--


UIDefine.GradeColor = {
    UIDefine.Brown2Color,
    UIDefine.GreenColor,
    UIDefine.BlueColor,
    UIDefine.PurpleColor,
    UIDefine.OrangeColor,
    UIDefine.RedColor,
}
UIDefine.GradeColorLabel = {
    "5E4629",
    "46DC5F",
    "42B1F0",
    "E855FF",
    "FF8700",
    "FF0000",
}

UIDefine.PetEquipAttrGrade = {
	["OnWhite"] = {
	UIDefine.BrownColor,--黑
	UIDefine.GreenColor,--绿
	UIDefine.BlueColor,--蓝
	UIDefine.PurpleColor,--紫
	UIDefine.OrangeColor--橙
	},
	["OnBlack"] = {
	UIDefine.WhiteColor,--白
	UIDefine.GreenColor,--绿
	UIDefine.BlueColor,--蓝
	UIDefine.PurpleColor,--紫
	UIDefine.OrangeColor --橙	
	}
}

setmetatable(UIDefine.GradeColor, {
    __index = function(t, k)
        if k <= 1 then
            return t[1];
        end
        return t[#t];
    end }
)

UIDefine.EquipSite = {
    [0] = "武器",
    [1] = "帽子",
    [2] = "衣服",
    [3] = "腰带",
    [4] = "鞋子",
    [5] = "护腕",
    [6] = "戒指",
    [7] = "项链",
    [8] = "挂坠",
    [9] = "法宝",
    [10] = "坐骑",
}

--UIDefine.GemType={													--大唐版本
--    [1] = {Name="赤炎石",Icon="1801509030"},
--    [2] = {Name="紫元石",Icon="1801509050"},
--    [3] = {Name="璃雀石",Icon="1801509020"},
--    [4] = {Name="碧落石",Icon="1801509010"},
--    [5] = {Name="落阳石",Icon="1801509040"},
--    [6] = {Name="玉华石",Icon="1801509070"},
--    [7] = {Name="琉晶石",Icon="1801509060"},
--    [8] = {Name="冷铁石",Icon="1801509080"},
--    [9] = {Name="神秘宝石",Icon="1900120300"},
--}

UIDefine.GemType = {
    [1] = { Name = "攻击石", Icon = "1801509030" },
    [2] = { Name = "魔攻石", Icon = "1801509050" },
    [3] = { Name = "物抗石", Icon = "1801509060" },
    [4] = { Name = "生命石", Icon = "1801509020" },
    [5] = { Name = "速度石", Icon = "1801509070" },
    [6] = { Name = "封印石", Icon = "1801509080" },
    [7] = { Name = "魔抗石", Icon = "1801509040" },
    [8] = { Name = "暴击石", Icon = "1801509010" },
    --[9] = {Name="神秘宝石",Icon="1900120300"},
}

-- 宠物类型
UIDefine.PetType = {
    [1] = "1800704040";
    [2] = "1800704010";
    [3] = "1800704030";
    [4] = "1801304030";
    [5] = "1800704020";
    [6] = "1801604100";
    [7] = "1801304040";
    [8] = "1801304050";
    [9] = "1801304060";
}

-- 宠物类型
UIDefine.PetTypeTxt = {
    [1] = "普通";
    [2] = "宝宝";
    [3] = "变异";
    [4] = "仙兽";
    [5] = "神兽";
    [6] = "魔兽";
    [7] = "圣兽";
    [8] = "元灵";
    [9] = "洪荒";
}

UIDefine.AttrIcon = {
    [RoleAttr.RoleAttrIngot] = "1800408250", --金元宝
    [RoleAttr.RoleAttrBindIngot] = "1800408260", --银元宝
    [RoleAttr.RoleAttrGold] = "1800408270", --金币
    [RoleAttr.RoleAttrBindGold] = "1800408280", --银币
    [RoleAttr.RoleAttrHonor] = "1800408550", --荣誉
    [RoleAttr.RoleAttrGuildContribute] = "1800408290", --帮贡
    [RoleAttr.RoleAttrExp] = "1801208690", --经验
    [RoleAttr.RoleAttrGuildAchievement] = "1800408300", --帮派成就
    [RoleAttr.RoleAttrGuildFightScore] = "1800408550", --帮派战功
}

UIDefine.AttrName = {
    [RoleAttr.RoleAttrIngot] = "金元宝",
    [RoleAttr.RoleAttrBindIngot] = "银元宝",
    [RoleAttr.RoleAttrGold] = "金币",
    [RoleAttr.RoleAttrBindGold] = "银币",
    [RoleAttr.RoleAttrHonor] = "荣誉",
    [RoleAttr.RoleAttrGuildContribute] = "帮贡",
    [RoleAttr.RoleAttrExp] = "经验",
    [RoleAttr.RoleAttrGuildAchievement] = "帮派成就",
    [RoleAttr.RoleAttrGuildFightScore] = "帮派战功",
}

UIDefine.AttrItemId = {
    [RoleAttr.RoleAttrIngot] = 61021, --金元宝
    [RoleAttr.RoleAttrBindIngot] = 20046, --银元宝
    [RoleAttr.RoleAttrGold] = 61023, --金币
    [RoleAttr.RoleAttrBindGold] = 61024, --银币
    [RoleAttr.RoleAttrHonor] = 20350, --荣誉
    [RoleAttr.RoleAttrGuildContribute] = 20349, --帮贡
    [RoleAttr.RoleAttrExp] = 61025, --经验
    [RoleAttr.RoleAttrGuildAchievement] = 61025, --帮派成就
    [RoleAttr.RoleAttrGuildFightScore] = 61025, --帮派战功
}

function UIDefine.GetAttrIconByAttrId(attrId)
    for k, v in pairs(UIDefine.AttrIcon) do
        if attrId == System.Enum.ToInt(k) then
            return v;
        end
    end

    return nil;
end

function UIDefine.GetMoneyIcon(moneyInt)
    return UIDefine.AttrIcon[UIDefine.GetMoneyEnum(moneyInt)];
end

local MoneyTypes = {
    RoleAttr.RoleAttrIngot,
    RoleAttr.RoleAttrBindIngot,
    nil,
    RoleAttr.RoleAttrGold,
    RoleAttr.RoleAttrBindGold
}
UIDefine.MoneyTypes = MoneyTypes
function UIDefine.GetMoneyEnum(moneyInt)
    return MoneyTypes[moneyInt] or RoleAttr.RoleAttrIngot
    --moneyInt = System.Enum.ToInt(RoleAttr.RoleAttrExp) + moneyInt
    --return RoleAttr.IntToEnum(moneyInt);
end

local metaTable = {
    __index = function(t, k)
        if k <= 1 then
            return t[1];
        end
        return t[#t];
    end
}

UIDefine.ItemIconBg = {
    [1] = 1800400330,
    [2] = 1800400100,
    [3] = 1800400110,
    [4] = 1800400120,
    [5] = 1800400320,
    [6] = 1801300190,
    [7] = 1801300200,
    [8] = 1801300210,
    [9] = 1801300220,
}
UIDefine.ItemSSR = {
    [2] = 1801205130,
    [3] = 1801205120,
    [4] = 1801205110,
    [5] = 1801205100,
}
setmetatable(UIDefine.ItemIconBg, metaTable)

UIDefine.ItemIconBg2 = {
    [1] = 1801100120,
    [2] = 1801100130,
    [3] = 1801100140,
    [4] = 1801100150,
    [5] = 1801100160,
    [6] = 1801401200,
    [7] = 1801401210,
    [8] = 1801401220,
    [9] = 1801401230,
}
setmetatable(UIDefine.ItemIconBg2, metaTable)

UIDefine.PetItemIconBg3 = {
    [1] = 1801100130,
    [2] = 1801100140,
    [3] = 1801100150,
    [4] = 1801401200,
    [5] = 1801100160,
    [6] = 1801401230,
    [7] = 1801401210,
    [8] = 1801401220,
    [9] = 1801401200,
}
setmetatable(UIDefine.PetItemIconBg3, metaTable)

-- 聊天中物品颜色值
UIDefine.ItemQualityCorRGB = {
    { 102, 47, 22 },
    { 70, 220, 95 },
    { 66, 177, 240 },
    { 232, 85, 255 },
    { 255, 127, 1 },
}
setmetatable(UIDefine.ItemQualityCorRGB, metaTable)

UIDefine.PetQualityCorRGB = {
    { 70, 220, 95 },
    { 66, 177, 240 },
    { 232, 85, 255 },
    { 170, 73, 40 },
    { 255, 135, 0 },
    { 255, 41, 33 },
    { 144, 95, 194 },
    { 113, 96, 198 },
    { 168, 25, 36 },
}
setmetatable(UIDefine.PetQualityCorRGB, metaTable)

--生成带颜色和字体大小(可选)的字符串
function UIDefine.GenTxtColSizeStr(color_value, text, fontSize)
    local result = "<color=" .. color_value .. ">"
    if fontSize ~= nil and fontSize > 0 then
        result = result .. "<size=" .. fontSize .. ">"
    end
    result = result .. text
    if fontSize ~= nil and fontSize > 0 then
        result = result .. "</size>"
    end
    result = result .. "</color>"
    return result
end

function UIDefine.GetRaceName(race)
    local race = RoleRace.IntToEnum(race)
    if race == RoleRace.RaceHuman then
        return "人族"
    elseif race == RoleRace.RaceDemon then
        return "魔族"
    elseif race == RoleRace.RaceImmortal then
        return "仙族"
    elseif race == RoleRace.RaceGhost then
        return "鬼族"
    elseif race == RoleRace.RaceDragon then
        return "龙族"
    end
end

function UIDefine.GetSexName(sex)
    local sex = RoleGender.IntToEnum(sex)
    if sex == RoleGender.GenderMale then
        return "男"
    elseif sex == RoleGender.GenderFemale then
        return "女"
    end
end

function UIDefine.ExchangeMoneyToStr(num, ext)
    --默认保留两位小数
    local extFloat = ext ~= nil and ext or 2
    num = tonumber(tostring(num))

    if num >= 100000000 then
        if num % 100000000 == 0 then
            return (num / 100000000) .. "亿"
        else
            local extValue = math.pow(10, extFloat)
            num = math.floor(num / 100000000 * extValue) / extValue
            return num .. "亿"
        end
    elseif num >= 10000 then
        if num % 10000 == 0 then
            return (num / 10000) .. "万"
        else
            local extValue = math.pow(10, extFloat)
            num = math.floor(num / 10000 * extValue) / extValue
            return num .. "万"
        end
    else
        return tostring(num)
    end
end

function UIDefine.ParseShopIDs()
    local info = ""
    --UIDefine.ItemShopTrack = {[10001]=1,[10002]=2}
    --UIDefine.PetShopTrack  = {[20001]=3,[20002]=4}
    --UIDefine.ShopTrack = {[1]=10,[2]=20,[3]=30,[4]=40}

    if UIDefine.ItemShopTrack ~= nil and UIDefine.PetShopTrack ~= nil and UIDefine.ShopTrack ~= nil then
        local t = {}
        for k, v in pairs(UIDefine.ItemShopTrack) do
            t[#t + 1] = k
            t[#t + 1] = v
        end
        info = table.concat(t, ",")
        t = {}
        for k, v in pairs(UIDefine.PetShopTrack) do
            t[#t + 1] = k
            t[#t + 1] = v
        end
        info = info .. ";" .. table.concat(t, ",")
        t = {}
        for k, v in pairs(UIDefine.ShopTrack) do
            t[#t + 1] = k
            t[#t + 1] = v
        end
        info = info .. ";" .. table.concat(t, ",")
    end

    return info
end

function UIDefine.ReplaceSpecialRichText(context)
    local result = context;
    if CL.IsInGame() then
        local _start, _end, target = string.find(result, '(【.*】)')

        local x = 0;
        local y = -8;
        if _start ~= nil and target ~= nil then
            local tpMsg, times = string.gsub(result, "【.*】", "__TEMPREPLACESTRING")
            if times ~= nil and times > 0 then
                for k, v in pairs(UIDefine.AttrIcon) do
                    local attrId = System.Enum.ToInt(k);
                    local attrDB = DB.GetOnceAttrByKey1(attrId);
                    tpMsg = string.gsub(tpMsg, "(%d+)(" .. attrDB.ChinaName .. ")", "#OFFSET<X:" .. x .. ",Y:" .. y .. "#IMAGE" .. v .. "#OFFSETEND>#%1");
                    tpMsg = string.gsub(tpMsg, "(" .. attrDB.ChinaName .. ")(%d+)", "#OFFSET<X:" .. x .. ",Y:" .. y .. "#IMAGE" .. v .. "#OFFSETEND>#%2");
                end

                result = string.gsub(tpMsg, "__TEMPREPLACESTRING", target)
            end
        else
            for k, v in pairs(UIDefine.AttrIcon) do
                local attrId = System.Enum.ToInt(k);
                local attrDB = DB.GetOnceAttrByKey1(attrId);
                result = string.gsub(result, "(%d+)(" .. attrDB.ChinaName .. ")", "#OFFSET<X:" .. x .. ",Y:" .. y .. "#IMAGE" .. v .. "#OFFSETEND>#%1");
                result = string.gsub(result, "(" .. attrDB.ChinaName .. ")(%d+)", "#OFFSET<X:" .. x .. ",Y:" .. y .. "#IMAGE" .. v .. "#OFFSETEND>#%2");
            end
        end
    end
    return result;
end

UIDefine.RaceName = {
    "人",
    "魔",
    "仙",
    "鬼",
    "龙"
}

UIDefine.SexName = {
    "男",
    "女"
}

function UIDefine.GetRoleRace(id)
    local role = DB.GetRole(id)
    if role then
        if role.Race >= 1 and role.Race <= #UIDefine.RaceName and role.Sex >= 1 and role.Sex <= 2 then
            return UIDefine.SexName[role.Sex] .. UIDefine.RaceName[role.Race]
        else
            return ""
        end
    end
end

function UIDefine.GetPetLevelStrByGuid(petGuid, type)
    if type == nil then
        type = pet_container_type.pet_container_panel;
    end

    local petData = LD.GetPetData(petGuid, type);
    return UIDefine.GetPetLevelStr(petData)
end

function UIDefine.GetPetLevelStr(petData)

    if petData == nil then
        return "";
    end

    local petRe = petData:GetIntAttr(RoleAttr.RoleAttrReincarnation);
    local petLevel = petData:GetIntAttr(RoleAttr.RoleAttrLevel);

    --return petRe .. "转" .. petLevel .. "级";
    return petLevel;
end

function UIDefine.LeftTimeFormatEx(time)
    time = time or 0
    local leftTimeNum = time - CL.GetServerTickCount()
    leftTimeNum = math.max(leftTimeNum, 0)
    local day = math.floor(leftTimeNum / 86400)
    local hour = math.floor(leftTimeNum % 86400 / 3600)
    local minute = math.floor(leftTimeNum % 3600 / 60)
    local s = leftTimeNum % 60
    if day > 0 then
        return day .. "天" .. hour .. "小时", day, hour, minute, s
    elseif hour > 0 then
        return hour .. "小时" .. minute .. "分", day, hour, minute, s
    elseif minute > 0 then
        return minute .. "分" .. s .. "秒", day, hour, minute, s
    else
        return s .. "秒", day, hour, minute, s
    end
end

--新增
function UIDefine.LeftTimeFormatEx2(leftTimeNum, type)
    type = type or 0
    leftTimeNum = math.max(leftTimeNum, 0)
    local day = math.floor(leftTimeNum / 86400)
    local hour = math.floor(leftTimeNum % 86400 / 3600)
    local minute = math.floor(leftTimeNum % 3600 / 60)
    local s = leftTimeNum % 60
    if type == 1 then
        return string.format("%02d:%02d:%02d",day*24+hour,minute,s), day, hour, minute, s
    else
        if day > 0 then
            return day .. "天" .. hour .. "小时", day, hour, minute, s
        elseif hour > 0 then
            return hour .. "小时" .. minute .. "分", day, hour, minute, s
        elseif minute > 0 then
            return minute .. "分" .. s .. "秒", day, hour, minute, s
        else
            return s .. "秒", day, hour, minute, s
        end
    end
end

function UIDefine.LeftTimeFormat(time)
    local str, day, hour, minute, s = UIDefine.LeftTimeFormatEx(time)
    return str
end

function UIDefine.GetTimeCountByFormat(timeStr,format)
    format = format or "(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)"
    local date = {}
    if format == "(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)" then
        date.year,date.month,date.day,date.hour,date.min,date.sec = string.match(timeStr,format)
    end
    return os.time(date)
end

UIDefine.UIEvent = {
    OnMainEvt = "_OnMainEvt",
    OnShowEvt = "_OnShowEvt",
    OnCloseEvt = "_OnCloseEvt",
    OnDestroyEvt = "_OnDestroyEvt",
    OnPetLineUpEvt = "_OnPetLineUpEvt",
}

function UIDefine.GetParameter1(parameter)
    local temp = 0
    if parameter ~= nil then
        local matchrule = "index:(%d+)"
        temp = string.match(parameter, matchrule)
    end
    return tonumber(temp) or 0
end

function UIDefine.GetParameter2(parameter)
    local temp = 0
    if parameter ~= nil then
        local matchrule = "index2:(%d+)"
        temp = string.match(parameter, matchrule)
    end
    return tonumber(temp) or 0
end
function UIDefine.GetParameterGuardGuid(parameter)
    local temp = nil;
    if parameter ~= nil then
        local matchrule = "guardGuid:(%d+)"
        temp = string.match(parameter, matchrule)
    end
    return temp;
end
function UIDefine.GetParameterItemGuid(parameter)
    local temp = nil;
    if parameter ~= nil then
        local matchrule = "itemGuid:(%d+)"
        temp = string.match(parameter, matchrule)
    end
    return temp;
end

function UIDefine.GetParameterStr(parameter)
    local tempa, tempb
    if parameter ~= nil then
        local matchrule = "index:(.+),index2:(.+)"
        tempa, tempb = string.match(parameter, matchrule)
    end
    return tempa, tempb
end

function UIDefine.get_parameter_str_3(parameter)
    local temp_1, temp_2, temp_3
    if parameter ~= nil then
        local match_rule = "index:(.+),index2:(.+),index3:(.+)"
        temp_1, temp_2, temp_3 = string.match(parameter, match_rule)
    end
    return temp_1, temp_2, temp_3
end

function UIDefine.GetAttrDesStr(attrId, value)
    if attrId == 0 then
        return " ";
    end
    local attrDB = DB.GetOnceAttrByKey1(attrId)
    return attrDB.ChinaName .. UIDefine.GetAttrValueStr(attrDB, value)
end

function UIDefine.GetAttrValueStr(attrDB, value)
    if attrDB.Id == 0 then
        return " ";
    end

    value = tostring(value)
    local joint = "+"
    if tonumber(value) < 0 then
        joint = "";
    end
    if attrDB.IsPct == 1 then
        value = string.format("%.2f", tonumber(value) / 100) .. "%"
    end
    return joint .. value;
end

function UIDefine.UpdateRoleWingStageEffects()
    CL.SynRoleWingEffect()
end

function UIDefine.GetWingStageEffects(grade)
    if UIDefine.WingStage_Effects then
        if UIDefine.WingStage_Effects[grade] then
            return UIDefine.WingStage_Effects[grade].Effects_1 .. "," .. UIDefine.WingStage_Effects[grade].Effects_2
        else
            return ""
        end
    else
        -- 0表示未得到初始数据
        return "0"
    end
end

function UIDefine.InitData()
    UIDefine.WingStage_Effects = nil
end
function UIDefine.RefreshPetLineUp()
    MainUI.SendNotifiy(UIDefine.UIEvent.OnPetLineUpEvt)
	
	--设置主界面宠物装备红点
	GlobalProcessing.LineUpPetEquipRedPoint()
	--设置主界面宠物加点红点
	GlobalProcessing.PetAddPointRedPoint()
end


-- 获取侍从所需要的碎片数量
UIDefine.getGuardNeedAmount = 50


-- 小红点类型
UIDefine.red_type = {
    common = '常规',
    --kind = '侍从种类按钮上',
    bookmark = '页签上',
    --button = '按钮上',
    plusIcon = "+号小图标上",
    icon = '头像上'
}

-- 倒计时类型
UIDefine.countdown_type = {
    common = '常规',
    --kind = '侍从种类按钮上',
    bookmark = '页签上',
    --button = '按钮上',
    plusIcon = "+号小图标上",
    icon = '头像上'
}

-- 侍从升星所需的物品数量数据
UIDefine.guard_up_star_token_num = nil

-- 快速使用
-- 每日签到提示>等级礼包提示>侍从激活提示>装备使用>道具使用
-- 提示顺序数据
UIDefine.prompt_sequence = {
    ['ui'] = {
        [1] = {
            ['page'] = 'SignInAndLevelGiftUI', -- 对应的界面UI
            ['method'] = 'open_ui:WelfareUI:3:0', -- 是打开界面还是使用物品
            ['stack'] = {}, -- 栈数据
            --['type'] = 1, -- 属于哪个type -- type 与其index下标相等
            --['name'] = '每日签到' -- 名称
        },
        [2] = {
            ['page'] = 'SignInAndLevelGiftUI',
            ['method'] = 'open_ui:WelfareUI:2:0',
            ['stack'] = {},
            --['type'] = 2,
            --['name'] = '等级礼包'
        },
        [3] = {
            ['page'] = 'SignInAndLevelGiftUI',
            ['method'] = 'use_item:',
            ['stack'] = {},
            --['type'] = 3,
            --['name'] = '侍从激活'
        },
        [4] = {
            ['page'] = 'QuickUseUI',
            ['method'] = 'use_item:',
            ['stack'] = {},
            --['type'] = 4,
            --['name'] = '装备道具'
        }
    },
    current_show = nil, -- 当前打开页面
    current_show_type = nil, -- 当前打开界面的type
    --page_list = {'SignInAndLevelGiftUI','QuickUseUI'} -- 在这个功能内，所有的页面，按优先级排列
}


-- 获取所有阵法材料
-- {20961,31101,31102,31103,31104,31105,31106,31107,31108,31109,31110}
function UIDefine.get_all_seat_material()
    local material  = {20961} -- 20961 阵法书残卷
    -- 将阵法材料数据存入全局变量，减少获取材料的运行次数
    local seat_keys = DB.GetSeatAllKey1s()
    for i = 0, seat_keys.Count - 1 do
        local seat_key = seat_keys[i]
        -- 排除普通阵/怪物阵法/观察者及其他
        if seat_key >= 1000 then
            table.insert(material, DB.GetOnceSeatByKey1(seat_keys[i]).UpItem)
        end
    end
    UIDefine._seat_all_material = material
    return material
end

-- 判断玩家是否有阵法材料
function UIDefine.is_have_seat_material()

    -- 获取所有阵法材料，存入全局变量，减少执行次数
    if not UIDefine._seat_all_material then
        UIDefine.get_all_seat_material()
    end

    for i=1,#UIDefine._seat_all_material do
        local count = LD.GetItemCountById(UIDefine._seat_all_material[i]) -- 获取物品数量 传入所有的阵法物品id 进行遍历
        if count > 0 then -- 如果有阵法书 则可以提升
            return true
        end
    end
    return false
end

-- 判断是否有可学习阵法
function UIDefine.have_lean_seat(data)
    if not UIDefine._seat_all_material then
        UIDefine.get_all_seat_material()
    end

    -- 记录下拥有的阵法书材料
    local seat_items = {}
    for k, v in ipairs(UIDefine._seat_all_material ) do
        -- 排除阵法书残卷
        if v ~= 20961 then
            local count = LD.GetItemCountById(v) -- 获取物品数量 传入所有的阵法id 进行遍历
            if count > 0 then
                seat_items[tostring(v)] = count
            end
        end
    end

    -- 遍历已学习阵法书材料
    for k,v in ipairs(data) do
        -- 排除普通阵法
        if v ~= 1 then
            local seat = DB.GetOnceSeatByKey1(v)
            -- 将已学习阵法的阵法书材料移除
            if seat_items[tostring(seat.UpItem)] then
                seat_items[tostring(seat.UpItem)] = nil
            end
        end
    end

    -- 如果阵法书材料列表内还有其他阵法书时，显示小红点
    if next(seat_items) then return true end

    return false
end

function UIDefine.GetCustomData(data, key)
    if data then
        for i = 0, data.Count-1 do
            if data[i].key == key then
                return tostring(data[i].value)
            end
        end
    end
    return ""
end

--计算字符串中字符的个数
function UIDefine.strnum(inputstr)
	-- 可以计算出字符宽度，用于显示使用
	local inputstr = tostring(inputstr)
	if not inputstr then
		return 0, {0,0,0,0}
	end
	local lenInByte = #inputstr
	local width = 0
	local onebyte = 0
	local twobyte = 0
	local threebyte = 0
	local fourbyte = 0
	local i = 1
	while (i <= lenInByte) do
		local curByte = string.byte(inputstr, i)
		local byteCount = 1;
		if curByte > 0 and curByte <= 127 then
			byteCount = 1                                           --1字节字符
			onebyte = onebyte + 1
		elseif curByte>=192 and curByte<223 then
			byteCount = 2                                           --双字节字符
			twobyte = twobyte + 1
		elseif curByte>=224 and curByte<239 then
			byteCount = 3                                           --汉字
			threebyte = threebyte + 1
		elseif curByte>=240 and curByte<=247 then
			byteCount = 4                                           --4字节字符
			fourbyte = fourbyte + 1
		end
		local char = string.sub(inputstr, i, i+byteCount-1)		
		i = i + byteCount                                 -- 重置下一字节的索引
		width = width + 1                                 -- 字符的个数（长度）
	end
	local TB = {onebyte,twobyte,threebyte,fourbyte}
	return width, TB
end

-- 检查该方法是否存在
function UIDefine.IsFunctionOrVariableExist(tbl, name)
    if tbl ~= nil then
        if type(tbl) == "table" then
            return rawget(tbl, name) ~= nil
        elseif type(tbl) == "userdata" then
            local function foo()
                local x  = tbl[name]
            end

            if pcall(foo) then
                return true
            else
                return false
            end

        end
    end
    return false
end

UIDefine.OnKeyDownFuncs = {}
function UIDefine.RegisterKeyDown(Key, Name, FunName)
    if _G[Name] and _G[Name][FunName] then
        if type(_G[Name][FunName]) == "function" then
            if UIDefine.OnKeyDownFuncs[Key] == nil then
                UIDefine.OnKeyDownFuncs[Key] = {}
            end
            table.insert(UIDefine.OnKeyDownFuncs[Key], {Name, FunName})
        end
    end
end

function UIDefine.UnRegisterKeyDown(Key, Name, FunName)
    if _G[Name] and _G[Name][FunName] then
        if type(_G[Name][FunName]) == "function" then
            local Count = #UIDefine.OnKeyDownFuncs[Key]
            for i = 1, Count do
                if UIDefine.OnKeyDownFuncs[Key][i][1]==Name and UIDefine.OnKeyDownFuncs[Key][i][2]==FunName then
                    table.remove(UIDefine.OnKeyDownFuncs[Key], i)
                    break
                end
            end
        end
    end
end

function UIDefine.OnKeyDown(Key)
    if UIDefine.OnKeyDownFuncs[Key] then
        local Count = #UIDefine.OnKeyDownFuncs[Key]
        for i = 1, Count do
            local Name = UIDefine.OnKeyDownFuncs[Key][i][1]
            local Func = UIDefine.OnKeyDownFuncs[Key][i][2]
            if _G[Name] and _G[Name][Func] then
                pcall(_G[Name][Func])
            end
        end
    end
end


UIDefine.guardSoulImages = {
    { "攻击", "1801719180", '1801719130' },
    { "防御", "1801719150", '1801719100' },
    { "生存", "1801719140", '1801719090' },
    { "辅助", "1801719160", '1801719110' },
    { "特殊", "1801719170", '1801719120' },
    { "全部", "", '1801719080' }
}

UIDefine.guardTypeImages = {
    { "物攻", "1800707170" },
    { "法攻", "1800707180" },
    { "治疗", "1800707190" },
    { "控制", "1800707210" },
    { "辅助", "1800707200" },
    { "全部", "" }
}

UIDefine.guardAndItemQualityImages = {
    { "1801205100", "1800400330" },
    { "1801205110", "1800400100" },
    { "1801205120", "1800400110" },
    { "1801205130", "1800400120" },
    { "1801205130", "1800400320" },
    [9] = {'','1801300220'},
}

UIDefine.IconLevelBg = {
    "1801407010",
    "1801407020",
    "1801407030",
    "1801407040",
    "1801407050",
}

UIDefine.mandarin_num = {
    '1801719011',
    '1801719012',
    '1801719013',
    '1801719014',
    '1801719015',
    '1801719016',
}

-- 侍从命魂套装数据
UIDefine.guardSoulSuitListData = nil
-- 侍从命魂装备位置数据
UIDefine.guardSoulEquipPosition = nil
-- 侍从命魂装备位置开启所需星级和等级
UIDefine.guardSoulEquipLevel = nil
-- 特殊侍从命魂装备位置开启所需星级和等级
UIDefine.guardSoulEquipSpecialLevel = nil
-- 侍从命魂装备位置数据 根据不同的侍从特殊设置
UIDefine.guardSoulEquipSpecialPosition = nil

function UIDefine.adjustSoulEquipPositionData()

    if UIDefine.guardSoulEquipPosition then
        local data = {}
        for i = 1, 5 do
            data[i] = {}
            for k,v in ipairs(UIDefine.guardSoulEquipPosition) do
                for pk,pv in ipairs(v) do
                    if pv == i then
                        table.insert(data[i],k)
                    end
                end
            end
        end
        UIDefine.guardSoulEquipPosition = data
    end

    if UIDefine.guardSoulEquipSpecialPosition then
        local data = {}
        for k,v in pairs(UIDefine.guardSoulEquipSpecialPosition) do
            data[k] = {}
            for i=1,5 do
                data[k][i] = {}
                for ak,av in ipairs(v) do
                    for bk,bv in ipairs(av) do
                        if bv == i then
                            table.insert(data[k][i],ak)
                        end
                    end
                end
            end
        end
        UIDefine.guardSoulEquipSpecialPosition = data
    end
end

function UIDefine.GetTargetFrameRate(isHighRate)
    local devicePlatform = TOOLKIT.GetPlatformName()
    if UIDefine.IsFunctionOrVariableExist(CL, "IsPCEditor") and CL.IsPCEditor() then
        if devicePlatform == "iOS" then
            return isHighRate and 40 or 30
        else
            return isHighRate and 45 or 40
        end
    end
    local frame = 30
    if devicePlatform == "iOS" then
        frame = 30
        if isHighRate then frame = 40 end
    else
        frame = 40
        if isHighRate then frame = 60 end
    end
    return frame
end
