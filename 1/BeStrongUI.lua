local BeStrongUI = {}
_G.BeStrongUI = BeStrongUI

--变强界面

require("EndlessTrialsUI")



------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local UILayout = UILayout
local _gt = UILayout.NewGUIDUtilTable()
local GoTORec
local Achievement_Max_Point = 0
local FINISHED_TYPE = false
local Now_Main_Type = 0
local Now_Child_Type = 0
local jump = nil
local TIME = 0
local PointList = {}
------------------------------------ end缓存一下全局变量end --------------------------------

-- 提升页战斗力数值显示最大数量
local max_digit_num = 7

-- 侧边栏选项
local labelList = {
    { "提升", "PromotionToggle", "OnPromotionToggleClick", "PromotionTogglePage", "CreatePromotionTogglePage" },
    { "变强", "StrengthenToggle", "OnStrengthenToggleClick", "StrengthenTogglePage", "CreateStrengthenTogglePage" },
    { "成就", "AchievementToggle", "OnAchievementToggleClick", "AchievementTogglePage", "CreateAchievementTogglePage" },
}
local labelListTitle = {
    { "变    强", "PromotionToggle", "OnPromotionToggleClick", "PromotionTogglePage", "CreatePromotionTogglePage" },
    { "变    强", "StrengthenToggle", "OnStrengthenToggleClick", "StrengthenTogglePage", "CreateStrengthenTogglePage" },
    { "变    强", "AchievementToggle", "OnAchievementToggleClick", "AchievementTogglePage", "CreateAchievementTogglePage" },
}

local roleSpriteInfo = {
    --烟云客
    [33] = { "1800107030", "600001989", "(0,2.65,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 傲红莲
    [38] = { "1800107080", "600001885", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 谪剑仙
    [31] = { "1800107010", "600001779", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 凤凰仙
    [42] = { "1800107120", "600001959", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 阎魔令
    [35] = { "1800107050", "600001995", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 青丘狐
    [40] = { "1800107100", "3000001490", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 冥河使
    [34] = { "1800107040", "600001982", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 花弄影
    [39] = { "1800107090", "600001837", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 雨师君
    [36] = { "1800107060", "600001880", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 海鲛灵
    [41] = { "1800107110", "600001956", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 飞翼姬
    [32] = { "1800107020", "600001842", "(0,2.24,-3.25),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 神霄卫
    [37] = { "1800107070", "600001921", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
}

-- 提升右侧数据配置
local promotion_cfg = {
    { Name = "装备强化", Icon = "1801409120", UnlockLevel = 0, ScoreLevel = 0, Percent = 0 },
    { Name = "宠物", Icon = "1801409130", UnlockLevel = 0, ScoreLevel = 0, Percent = 0 },
    { Name = "技能", Icon = "1801409140", UnlockLevel = 0, ScoreLevel = 0, Percent = 0 },
    { Name = "侍从", Icon = "1801409150", UnlockLevel = 0, ScoreLevel = 0, Percent = 0 },
    { Name = "羽翼", Icon = "1801409160", UnlockLevel = 0, ScoreLevel = 0, Percent = 0 },
    -- 对应上面table的索引
    Equip = 1, Pet = 2, Skill = 3, Guard = 4, Wing = 5
}

-- 评分图片配置
local grade_cfg = {
    --    big           small     name
    { "1801407120", "1801407160", "S" },
    { "1801407130", "1801407170", "A" },
    { "1801407140", "1801407180", "B" },
    { "1801407150", "1801407190", "C" },
    { "1801407260", "1801407270", "D" },
}

local BianQiang_Red_Point_data = {

}

local TiSheng_Red = {false,false,false,false,false}
-- 提升页所需配置(服务端发送过来)
BeStrongUI.PromotionConfig = {}

BeStrongUI.RefreshData = {}
-- 技能评分
BeStrongUI.SkillScore = nil
-- 宠物评分
BeStrongUI.PetScore = nil
-- 侍从评分
BeStrongUI.GuardScore = nil
-- 装备评分
BeStrongUI.EquipScore = nil
-- 羽翼评分
BeStrongUI.WingScore = nil
-- 成就点
BeStrongUI.AchievementPoint = nil
local pageNum = {
    Promotion = 1,
    Strengthen = 2,
    Achievement = 3,
    Realm = 4,
}

-- 当前选中的侧边栏索引
local currToggleIndex = 1

-- Id -> Id
-- Level -> 等级(玩家等级)
-- CharacterScore -> 角色评分(推荐战斗力)
-- EquipmentScore -> 装备评分
-- PetScore -> 宠物评分
-- SkillScore -> 技能评分
-- AttendantScore -> 侍从评分
-- WingScore -> 羽翼评分
local Promotion_table_Id = {
    Id_1 = {Id = 1, Level = 1, CharacterScore = 289, EquipmentScore = 1199, PetScore = 9355, SkillScore = 60, AttendantScore = 0, WingScore = 0, },
    Id_2 = {Id = 2, Level = 2, CharacterScore = 314, EquipmentScore = 1199, PetScore = 9800, SkillScore = 120, AttendantScore = 0, WingScore = 0, },
    Id_3 = {Id = 3, Level = 3, CharacterScore = 338, EquipmentScore = 1199, PetScore = 10245, SkillScore = 180, AttendantScore = 0, WingScore = 0, },
    Id_4 = {Id = 4, Level = 4, CharacterScore = 363, EquipmentScore = 1199, PetScore = 10690, SkillScore = 240, AttendantScore = 0, WingScore = 0, },
    Id_5 = {Id = 5, Level = 5, CharacterScore = 388, EquipmentScore = 1199, PetScore = 11135, SkillScore = 300, AttendantScore = 0, WingScore = 0, },
    Id_6 = {Id = 6, Level = 6, CharacterScore = 412, EquipmentScore = 1199, PetScore = 11580, SkillScore = 360, AttendantScore = 0, WingScore = 0, },
    Id_7 = {Id = 7, Level = 7, CharacterScore = 437, EquipmentScore = 1199, PetScore = 12025, SkillScore = 420, AttendantScore = 0, WingScore = 0, },
    Id_8 = {Id = 8, Level = 8, CharacterScore = 462, EquipmentScore = 1199, PetScore = 12470, SkillScore = 480, AttendantScore = 0, WingScore = 0, },
    Id_9 = {Id = 9, Level = 9, CharacterScore = 486, EquipmentScore = 1199, PetScore = 12915, SkillScore = 540, AttendantScore = 0, WingScore = 0, },
    Id_10 = {Id = 10, Level = 10, CharacterScore = 511, EquipmentScore = 1199, PetScore = 13360, SkillScore = 600, AttendantScore = 0, WingScore = 0, },
    Id_11 = {Id = 11, Level = 11, CharacterScore = 536, EquipmentScore = 1199, PetScore = 13805, SkillScore = 660, AttendantScore = 0, WingScore = 0, },
    Id_12 = {Id = 12, Level = 12, CharacterScore = 560, EquipmentScore = 1199, PetScore = 14250, SkillScore = 720, AttendantScore = 0, WingScore = 0, },
    Id_13 = {Id = 13, Level = 13, CharacterScore = 585, EquipmentScore = 1199, PetScore = 14695, SkillScore = 780, AttendantScore = 14120, WingScore = 0, },
    Id_14 = {Id = 14, Level = 14, CharacterScore = 610, EquipmentScore = 1199, PetScore = 15140, SkillScore = 840, AttendantScore = 14576, WingScore = 0, },
    Id_15 = {Id = 15, Level = 15, CharacterScore = 634, EquipmentScore = 1199, PetScore = 15585, SkillScore = 900, AttendantScore = 15020, WingScore = 0, },
    Id_16 = {Id = 16, Level = 16, CharacterScore = 659, EquipmentScore = 1199, PetScore = 17645, SkillScore = 960, AttendantScore = 15472, WingScore = 0, },
    Id_17 = {Id = 17, Level = 17, CharacterScore = 684, EquipmentScore = 1199, PetScore = 18090, SkillScore = 1020, AttendantScore = 15944, WingScore = 0, },
    Id_18 = {Id = 18, Level = 18, CharacterScore = 708, EquipmentScore = 1199, PetScore = 18535, SkillScore = 1080, AttendantScore = 16384, WingScore = 0, },
    Id_19 = {Id = 19, Level = 19, CharacterScore = 733, EquipmentScore = 1199, PetScore = 18980, SkillScore = 1140, AttendantScore = 16840, WingScore = 0, },
    Id_20 = {Id = 20, Level = 20, CharacterScore = 758, EquipmentScore = 1199, PetScore = 19425, SkillScore = 1200, AttendantScore = 17296, WingScore = 0, },
    Id_21 = {Id = 21, Level = 21, CharacterScore = 782, EquipmentScore = 1199, PetScore = 19870, SkillScore = 1260, AttendantScore = 17752, WingScore = 0, },
    Id_22 = {Id = 22, Level = 22, CharacterScore = 807, EquipmentScore = 1199, PetScore = 20315, SkillScore = 1320, AttendantScore = 18208, WingScore = 0, },
    Id_23 = {Id = 23, Level = 23, CharacterScore = 832, EquipmentScore = 1199, PetScore = 20760, SkillScore = 1380, AttendantScore = 18664, WingScore = 0, },
    Id_24 = {Id = 24, Level = 24, CharacterScore = 856, EquipmentScore = 1199, PetScore = 21205, SkillScore = 1440, AttendantScore = 19120, WingScore = 0, },
    Id_25 = {Id = 25, Level = 25, CharacterScore = 881, EquipmentScore = 1199, PetScore = 21650, SkillScore = 1500, AttendantScore = 19576, WingScore = 0, },
    Id_26 = {Id = 26, Level = 26, CharacterScore = 906, EquipmentScore = 1199, PetScore = 22095, SkillScore = 1560, AttendantScore = 20032, WingScore = 0, },
    Id_27 = {Id = 27, Level = 27, CharacterScore = 930, EquipmentScore = 1199, PetScore = 22540, SkillScore = 1620, AttendantScore = 20488, WingScore = 0, },
    Id_28 = {Id = 28, Level = 28, CharacterScore = 955, EquipmentScore = 1199, PetScore = 22985, SkillScore = 1680, AttendantScore = 20944, WingScore = 0, },
    Id_29 = {Id = 29, Level = 29, CharacterScore = 980, EquipmentScore = 1199, PetScore = 23430, SkillScore = 1740, AttendantScore = 21400, WingScore = 0, },
    Id_30 = {Id = 30, Level = 30, CharacterScore = 1004, EquipmentScore = 2978, PetScore = 23875, SkillScore = 2460, AttendantScore = 23604, WingScore = 0, },
    Id_31 = {Id = 31, Level = 31, CharacterScore = 1029, EquipmentScore = 2978, PetScore = 24320, SkillScore = 2580, AttendantScore = 24096, WingScore = 0, },
    Id_32 = {Id = 32, Level = 32, CharacterScore = 1054, EquipmentScore = 2978, PetScore = 24765, SkillScore = 2700, AttendantScore = 24589, WingScore = 0, },
    Id_33 = {Id = 33, Level = 33, CharacterScore = 1079, EquipmentScore = 2978, PetScore = 25210, SkillScore = 2820, AttendantScore = 25081, WingScore = 0, },
    Id_34 = {Id = 34, Level = 34, CharacterScore = 1103, EquipmentScore = 2978, PetScore = 25655, SkillScore = 2940, AttendantScore = 25574, WingScore = 0, },
    Id_35 = {Id = 35, Level = 35, CharacterScore = 1128, EquipmentScore = 5948, PetScore = 26100, SkillScore = 3060, AttendantScore = 26066, WingScore = 0, },
    Id_36 = {Id = 36, Level = 36, CharacterScore = 1153, EquipmentScore = 5948, PetScore = 26545, SkillScore = 3180, AttendantScore = 26559, WingScore = 0, },
    Id_37 = {Id = 37, Level = 37, CharacterScore = 1177, EquipmentScore = 5948, PetScore = 26990, SkillScore = 3300, AttendantScore = 27051, WingScore = 0, },
    Id_38 = {Id = 38, Level = 38, CharacterScore = 1202, EquipmentScore = 5948, PetScore = 27435, SkillScore = 3420, AttendantScore = 27544, WingScore = 0, },
    Id_39 = {Id = 39, Level = 39, CharacterScore = 1227, EquipmentScore = 5948, PetScore = 27880, SkillScore = 3540, AttendantScore = 28036, WingScore = 0, },
    Id_40 = {Id = 40, Level = 40, CharacterScore = 1251, EquipmentScore = 5948, PetScore = 28325, SkillScore = 3680, AttendantScore = 28529, WingScore = 0, },
    Id_41 = {Id = 41, Level = 41, CharacterScore = 1276, EquipmentScore = 5948, PetScore = 31647, SkillScore = 3860, AttendantScore = 29021, WingScore = 0, },
    Id_42 = {Id = 42, Level = 42, CharacterScore = 1301, EquipmentScore = 5948, PetScore = 32137, SkillScore = 4040, AttendantScore = 29514, WingScore = 0, },
    Id_43 = {Id = 43, Level = 43, CharacterScore = 1325, EquipmentScore = 5948, PetScore = 32626, SkillScore = 4220, AttendantScore = 30006, WingScore = 0, },
    Id_44 = {Id = 44, Level = 44, CharacterScore = 1350, EquipmentScore = 5948, PetScore = 33116, SkillScore = 4400, AttendantScore = 30499, WingScore = 0, },
    Id_45 = {Id = 45, Level = 45, CharacterScore = 1375, EquipmentScore = 5948, PetScore = 33605, SkillScore = 5060, AttendantScore = 30991, WingScore = 0, },
    Id_46 = {Id = 46, Level = 46, CharacterScore = 1399, EquipmentScore = 5948, PetScore = 35647, SkillScore = 5240, AttendantScore = 31484, WingScore = 0, },
    Id_47 = {Id = 47, Level = 47, CharacterScore = 1424, EquipmentScore = 5948, PetScore = 40168, SkillScore = 5420, AttendantScore = 31976, WingScore = 0, },
    Id_48 = {Id = 48, Level = 48, CharacterScore = 1449, EquipmentScore = 5948, PetScore = 40718, SkillScore = 5600, AttendantScore = 32469, WingScore = 0, },
    Id_49 = {Id = 49, Level = 49, CharacterScore = 1473, EquipmentScore = 5948, PetScore = 41268, SkillScore = 5780, AttendantScore = 32961, WingScore = 0, },
    Id_50 = {Id = 50, Level = 50, CharacterScore = 1498, EquipmentScore = 6756, PetScore = 41818, SkillScore = 6140, AttendantScore = 33454, WingScore = 0, },
    Id_51 = {Id = 51, Level = 51, CharacterScore = 1523, EquipmentScore = 6756, PetScore = 42373, SkillScore = 6320, AttendantScore = 36775, WingScore = 0, },
    Id_52 = {Id = 52, Level = 52, CharacterScore = 1547, EquipmentScore = 6756, PetScore = 48783, SkillScore = 6500, AttendantScore = 37308, WingScore = 0, },
    Id_53 = {Id = 53, Level = 53, CharacterScore = 1572, EquipmentScore = 6756, PetScore = 49414, SkillScore = 6680, AttendantScore = 37842, WingScore = 0, },
    Id_54 = {Id = 54, Level = 54, CharacterScore = 1597, EquipmentScore = 6756, PetScore = 50045, SkillScore = 6860, AttendantScore = 38376, WingScore = 0, },
    Id_55 = {Id = 55, Level = 55, CharacterScore = 1621, EquipmentScore = 6951, PetScore = 50677, SkillScore = 7200, AttendantScore = 38909, WingScore = 0, },
    Id_56 = {Id = 56, Level = 56, CharacterScore = 1646, EquipmentScore = 6951, PetScore = 51308, SkillScore = 7380, AttendantScore = 39443, WingScore = 0, },
    Id_57 = {Id = 57, Level = 57, CharacterScore = 1671, EquipmentScore = 6951, PetScore = 51939, SkillScore = 7560, AttendantScore = 39976, WingScore = 0, },
    Id_58 = {Id = 58, Level = 58, CharacterScore = 1695, EquipmentScore = 6951, PetScore = 52570, SkillScore = 7740, AttendantScore = 40510, WingScore = 175, },
    Id_59 = {Id = 59, Level = 59, CharacterScore = 1720, EquipmentScore = 6951, PetScore = 53202, SkillScore = 7920, AttendantScore = 41043, WingScore = 175, },
    Id_60 = {Id = 60, Level = 60, CharacterScore = 1745, EquipmentScore = 7286, PetScore = 53833, SkillScore = 8280, AttendantScore = 41577, WingScore = 275, },
    Id_61 = {Id = 61, Level = 61, CharacterScore = 1769, EquipmentScore = 7286, PetScore = 54464, SkillScore = 8340, AttendantScore = 42110, WingScore = 275, },
    Id_62 = {Id = 62, Level = 62, CharacterScore = 1794, EquipmentScore = 7286, PetScore = 55095, SkillScore = 8400, AttendantScore = 42644, WingScore = 275, },
    Id_63 = {Id = 63, Level = 63, CharacterScore = 1819, EquipmentScore = 7286, PetScore = 55727, SkillScore = 8460, AttendantScore = 43177, WingScore = 275, },
    Id_64 = {Id = 64, Level = 64, CharacterScore = 1843, EquipmentScore = 7286, PetScore = 56358, SkillScore = 8520, AttendantScore = 43711, WingScore = 275, },
    Id_65 = {Id = 65, Level = 65, CharacterScore = 1868, EquipmentScore = 7445, PetScore = 56989, SkillScore = 8660, AttendantScore = 44244, WingScore = 385, },
    Id_66 = {Id = 66, Level = 66, CharacterScore = 1893, EquipmentScore = 7445, PetScore = 58806, SkillScore = 8720, AttendantScore = 44778, WingScore = 385, },
    Id_67 = {Id = 67, Level = 67, CharacterScore = 1917, EquipmentScore = 7445, PetScore = 59437, SkillScore = 8780, AttendantScore = 45311, WingScore = 385, },
    Id_68 = {Id = 68, Level = 68, CharacterScore = 1942, EquipmentScore = 7445, PetScore = 60069, SkillScore = 8840, AttendantScore = 45845, WingScore = 385, },
    Id_69 = {Id = 69, Level = 69, CharacterScore = 1967, EquipmentScore = 7445, PetScore = 60700, SkillScore = 8900, AttendantScore = 46378, WingScore = 385, },
    Id_70 = {Id = 70, Level = 70, CharacterScore = 1991, EquipmentScore = 7946, PetScore = 61331, SkillScore = 9060, AttendantScore = 46912, WingScore = 540, },
    Id_71 = {Id = 71, Level = 71, CharacterScore = 2016, EquipmentScore = 7946, PetScore = 61962, SkillScore = 9120, AttendantScore = 51501, WingScore = 540, },
    Id_72 = {Id = 72, Level = 72, CharacterScore = 2041, EquipmentScore = 7946, PetScore = 72609, SkillScore = 9180, AttendantScore = 52080, WingScore = 540, },
    Id_73 = {Id = 73, Level = 73, CharacterScore = 2066, EquipmentScore = 7946, PetScore = 73341, SkillScore = 9240, AttendantScore = 52659, WingScore = 540, },
    Id_74 = {Id = 74, Level = 74, CharacterScore = 2090, EquipmentScore = 7946, PetScore = 74073, SkillScore = 9300, AttendantScore = 53238, WingScore = 540, },
    Id_75 = {Id = 75, Level = 75, CharacterScore = 2115, EquipmentScore = 8123, PetScore = 74805, SkillScore = 9440, AttendantScore = 53817, WingScore = 720, },
    Id_76 = {Id = 76, Level = 76, CharacterScore = 2140, EquipmentScore = 8123, PetScore = 75538, SkillScore = 9500, AttendantScore = 54396, WingScore = 720, },
    Id_77 = {Id = 77, Level = 77, CharacterScore = 2164, EquipmentScore = 8123, PetScore = 76270, SkillScore = 9560, AttendantScore = 54975, WingScore = 720, },
    Id_78 = {Id = 78, Level = 78, CharacterScore = 2189, EquipmentScore = 8123, PetScore = 77002, SkillScore = 9620, AttendantScore = 55554, WingScore = 720, },
    Id_79 = {Id = 79, Level = 79, CharacterScore = 2214, EquipmentScore = 8123, PetScore = 77734, SkillScore = 9680, AttendantScore = 56134, WingScore = 720, },
    Id_80 = {Id = 80, Level = 80, CharacterScore = 2238, EquipmentScore = 8309, PetScore = 78467, SkillScore = 9840, AttendantScore = 56713, WingScore = 965, },
    Id_81 = {Id = 81, Level = 81, CharacterScore = 2263, EquipmentScore = 8541, PetScore = 79199, SkillScore = 9900, AttendantScore = 57292, WingScore = 965, },
    Id_82 = {Id = 82, Level = 82, CharacterScore = 2288, EquipmentScore = 8541, PetScore = 79931, SkillScore = 9960, AttendantScore = 57871, WingScore = 965, },
    Id_83 = {Id = 83, Level = 83, CharacterScore = 2312, EquipmentScore = 8541, PetScore = 80663, SkillScore = 10020, AttendantScore = 58450, WingScore = 965, },
    Id_84 = {Id = 84, Level = 84, CharacterScore = 2337, EquipmentScore = 8541, PetScore = 81396, SkillScore = 10080, AttendantScore = 59029, WingScore = 965, },
    Id_85 = {Id = 85, Level = 85, CharacterScore = 2362, EquipmentScore = 8706, PetScore = 82128, SkillScore = 10220, AttendantScore = 59608, WingScore = 1250, },
    Id_86 = {Id = 86, Level = 86, CharacterScore = 2386, EquipmentScore = 8706, PetScore = 84218, SkillScore = 10280, AttendantScore = 60187, WingScore = 1250, },
    Id_87 = {Id = 87, Level = 87, CharacterScore = 2411, EquipmentScore = 8706, PetScore = 84951, SkillScore = 10340, AttendantScore = 60766, WingScore = 1250, },
    Id_88 = {Id = 88, Level = 88, CharacterScore = 2436, EquipmentScore = 8706, PetScore = 85683, SkillScore = 10400, AttendantScore = 61346, WingScore = 1250, },
    Id_89 = {Id = 89, Level = 89, CharacterScore = 2460, EquipmentScore = 8706, PetScore = 86415, SkillScore = 10460, AttendantScore = 61925, WingScore = 1250, },
    Id_90 = {Id = 90, Level = 90, CharacterScore = 2485, EquipmentScore = 9152, PetScore = 87147, SkillScore = 10620, AttendantScore = 62504, WingScore = 1575, },
    Id_91 = {Id = 91, Level = 91, CharacterScore = 2510, EquipmentScore = 9152, PetScore = 87880, SkillScore = 10680, AttendantScore = 68547, WingScore = 1575, },
    Id_92 = {Id = 92, Level = 92, CharacterScore = 2534, EquipmentScore = 9152, PetScore = 103890, SkillScore = 10740, AttendantScore = 69176, WingScore = 1575, },
    Id_93 = {Id = 93, Level = 93, CharacterScore = 2559, EquipmentScore = 9152, PetScore = 104748, SkillScore = 10800, AttendantScore = 69805, WingScore = 1575, },
    Id_94 = {Id = 94, Level = 94, CharacterScore = 2584, EquipmentScore = 9152, PetScore = 105607, SkillScore = 10860, AttendantScore = 70435, WingScore = 1575, },
    Id_95 = {Id = 95, Level = 95, CharacterScore = 2608, EquipmentScore = 9335, PetScore = 106465, SkillScore = 11000, AttendantScore = 71064, WingScore = 1940, },
    Id_96 = {Id = 96, Level = 96, CharacterScore = 2633, EquipmentScore = 9335, PetScore = 107324, SkillScore = 11060, AttendantScore = 71693, WingScore = 1940, },
    Id_97 = {Id = 97, Level = 97, CharacterScore = 2658, EquipmentScore = 9335, PetScore = 108182, SkillScore = 11120, AttendantScore = 72323, WingScore = 1940, },
    Id_98 = {Id = 98, Level = 98, CharacterScore = 2682, EquipmentScore = 9335, PetScore = 109041, SkillScore = 11180, AttendantScore = 72952, WingScore = 1940, },
    Id_99 = {Id = 99, Level = 99, CharacterScore = 2707, EquipmentScore = 9335, PetScore = 109899, SkillScore = 11240, AttendantScore = 73581, WingScore = 1940, },
    Id_100 = {Id = 100, Level = 100, CharacterScore = 2732, EquipmentScore = 9802, PetScore = 110758, SkillScore = 11400, AttendantScore = 74210, WingScore = 2605, },
    Id_101 = {Id = 101, Level = 101, CharacterScore = 2756, EquipmentScore = 9802, PetScore = 111616, SkillScore = 11460, AttendantScore = 81348, WingScore = 2605, },
    Id_102 = {Id = 102, Level = 102, CharacterScore = 2781, EquipmentScore = 9802, PetScore = 112475, SkillScore = 11520, AttendantScore = 82032, WingScore = 2605, },
    Id_103 = {Id = 103, Level = 103, CharacterScore = 2806, EquipmentScore = 9802, PetScore = 113333, SkillScore = 11580, AttendantScore = 82716, WingScore = 2605, },
    Id_104 = {Id = 104, Level = 104, CharacterScore = 2830, EquipmentScore = 9802, PetScore = 114192, SkillScore = 11640, AttendantScore = 83400, WingScore = 2605, },
    Id_105 = {Id = 105, Level = 105, CharacterScore = 2855, EquipmentScore = 9961, PetScore = 115050, SkillScore = 11780, AttendantScore = 84084, WingScore = 3278, },
    Id_106 = {Id = 106, Level = 106, CharacterScore = 2880, EquipmentScore = 9961, PetScore = 117515, SkillScore = 11840, AttendantScore = 84768, WingScore = 3278, },
    Id_107 = {Id = 107, Level = 107, CharacterScore = 2904, EquipmentScore = 9961, PetScore = 118373, SkillScore = 11900, AttendantScore = 85452, WingScore = 3278, },
    Id_108 = {Id = 108, Level = 108, CharacterScore = 2929, EquipmentScore = 9961, PetScore = 119232, SkillScore = 11960, AttendantScore = 86136, WingScore = 3278, },
    Id_109 = {Id = 109, Level = 109, CharacterScore = 2954, EquipmentScore = 9961, PetScore = 120090, SkillScore = 12020, AttendantScore = 86820, WingScore = 3278, },
    Id_110 = {Id = 110, Level = 110, CharacterScore = 2978, EquipmentScore = 10487, PetScore = 120949, SkillScore = 12180, AttendantScore = 87504, WingScore = 4175, },
    Id_111 = {Id = 111, Level = 111, CharacterScore = 3003, EquipmentScore = 10487, PetScore = 121807, SkillScore = 12240, AttendantScore = 88188, WingScore = 4175, },
    Id_112 = {Id = 112, Level = 112, CharacterScore = 3028, EquipmentScore = 10487, PetScore = 122666, SkillScore = 12300, AttendantScore = 88872, WingScore = 4175, },
    Id_113 = {Id = 113, Level = 113, CharacterScore = 3053, EquipmentScore = 10487, PetScore = 123524, SkillScore = 12360, AttendantScore = 89556, WingScore = 4175, },
    Id_114 = {Id = 114, Level = 114, CharacterScore = 3077, EquipmentScore = 10487, PetScore = 124383, SkillScore = 12420, AttendantScore = 90240, WingScore = 4175, },
    Id_115 = {Id = 115, Level = 115, CharacterScore = 3102, EquipmentScore = 10754, PetScore = 125241, SkillScore = 12560, AttendantScore = 90924, WingScore = 5310, },
    Id_116 = {Id = 116, Level = 116, CharacterScore = 3127, EquipmentScore = 10754, PetScore = 126100, SkillScore = 12620, AttendantScore = 91608, WingScore = 5310, },
    Id_117 = {Id = 117, Level = 117, CharacterScore = 3151, EquipmentScore = 10754, PetScore = 126958, SkillScore = 12680, AttendantScore = 92292, WingScore = 5310, },
    Id_118 = {Id = 118, Level = 118, CharacterScore = 3176, EquipmentScore = 10754, PetScore = 127817, SkillScore = 12740, AttendantScore = 92976, WingScore = 5310, },
    Id_119 = {Id = 119, Level = 119, CharacterScore = 3201, EquipmentScore = 10754, PetScore = 128675, SkillScore = 12800, AttendantScore = 93660, WingScore = 5310, },
    Id_120 = {Id = 120, Level = 120, CharacterScore = 3225, EquipmentScore = 11301, PetScore = 129534, SkillScore = 12960, AttendantScore = 94344, WingScore = 6665, },
}

local NbTable_Id = {
 [1 ]= {Id = 1, Type = 0, Name = "角色提升", SubName = "角色积分", LevelMin = 1, LevelMax = 0, Info = "获得不同种类的角色积分，可兑换更多道具。", Icon = 1801109110, UIwindow = "RoleAttributeUI,2", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [2 ]= {Id = 2, Type = 0, Name = "角色提升", SubName = "角色加点", LevelMin = 51, LevelMax = 0, Info = "按角色特色分配潜力点数，可以提升角色战力。", Icon = 1801109080, UIwindow = "RoleAttributeUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [3 ]= {Id = 3, Type = 1, Name = "角色经验", SubName = "剧情任务", LevelMin = 1, LevelMax = 0, Info = "参与剧情任务，可以获得大量的角色经验。", Icon = 1801109120, UIwindow = "QuestDlgUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [4 ]= {Id = 4, Type = 1, Name = "角色经验", SubName = "师门任务", LevelMin = 34, LevelMax = 0, Info = "每天完成20次师门任务，可以获得大量的角色经验。", Icon = 1801109130, UIwindow = "QuestDlgUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [5 ]= {Id = 5, Type = 1, Name = "角色经验", SubName = "降妖任务", LevelMin = 35, LevelMax = 0, Info = "组队参与降妖任务，可以获得大量的角色经验。", Icon = 1801109140, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10014, RedPoint = false, },
 [6 ]= {Id = 6, Type = 1, Name = "角色经验", SubName = "修业试炼", LevelMin = 50, LevelMax = 0, Info = "每周完成1次修业试炼，可以获得大量的角色经验。", Icon = 1801109150, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 50003, RedPoint = false, },
 [7 ]= {Id = 7, Type = 1, Name = "角色经验", SubName = "闹事的妖怪", LevelMin = 25, LevelMax = 0, Info = "组队降伏闹事的妖怪，可以获得角色经验。", Icon = 1801109500, UIwindow = "ActivityPanelUI,0", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [8 ]= {Id = 8, Type = 2, Name = "技能学习", SubName = "门派技能学习", LevelMin = 12, LevelMax = 0, Info = "学习门派技能，可以提升角色战力。", Icon = 1801109090, UIwindow = "RoleSkillUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [9 ]= {Id = 9, Type = 2, Name = "技能学习", SubName = "帮派技能学习", LevelMin = 28, LevelMax = 0, Info = "学习帮派技能，可以提升角色战力。", Icon = 1801109410, UIwindow = "RoleSkillUI,4", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [10 ]= {Id = 10, Type = 2, Name = "技能学习", SubName = "修炼技能学习", LevelMin = 45, LevelMax = 0, Info = "学习修炼技能，可以提升角色战力。", Icon = 1801109110, UIwindow = "RoleSkillUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [11 ]= {Id = 11, Type = 2, Name = "技能学习", SubName = "天赋技能学习", LevelMin = 30, LevelMax = 0, Info = "学习天赋技能，可以提升角色战力。", Icon = 1801109410, UIwindow = "RoleSkillUI,2", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [12 ]= {Id = 12, Type = 3, Name = "装备获得", SubName = "武器商店购买", LevelMin = 1, LevelMax = 0, Info = "在商店可以购买普通武器。", Icon = 1801109210, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20022, RedPoint = false, },
 [13 ]= {Id = 13, Type = 3, Name = "装备获得", SubName = "装备商店购买", LevelMin = 1, LevelMax = 0, Info = "在商店可以购买普通装备。", Icon = 1801109220, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20021, RedPoint = false, },
 [14 ]= {Id = 14, Type = 3, Name = "装备获得", SubName = "限时特惠", LevelMin = 1, LevelMax = 0, Info = "达到一定等级后，升级时会自动弹出限时特惠，可以低价购得紫装。", Icon = 1801109270, Map = 0, Jump = 0, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [15 ]= {Id = 15, Type = 3, Name = "装备获得", SubName = "首充大礼", LevelMin = 1, LevelMax = 0, Info = "可获得无穿着级别限制的橙品发光武器。", Icon = 1801109190, UIwindow = "FirstRechargeUI,10", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [16 ]= {Id = 16, Type = 3, Name = "装备获得", SubName = "累计充值", LevelMin = 1, LevelMax = 0, Info = "可获得属性更高的无穿着级别限制的橙品发光武器。", Icon = 1801109190, UIwindow = "SuperValueUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [17 ]= {Id = 17, Type = 3, Name = "装备获得", SubName = "降妖任务", LevelMin = 35, LevelMax = 0, Info = "组队参与降妖任务，可以有几率获得装备。", Icon = 1801109140, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10014, RedPoint = false, },
 [18 ]= {Id = 18, Type = 3, Name = "装备获得", SubName = "装备打造", LevelMin = 41, LevelMax = 0, Info = "收集材料可以在长安城打造师处打造装备，几率获得品质较高的装备。", Icon = 1801109250, UIwindow = "EquipUI,1,2", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [19 ]= {Id = 19, Type = 3, Name = "装备获得", SubName = "挑战神兽", LevelMin = 30, LevelMax = 0, Info = "挑战神兽有概率开出高级装备。", Icon = 1801109280, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10023, RedPoint = false, },
 [20 ]= {Id = 20, Type = 3, Name = "装备获得", SubName = "天下会武", LevelMin = 40, LevelMax = 0, Info = "参与天下会武活动，可在战功商店兑换战功套装。", Icon = 1801109290, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 21074, RedPoint = false, },
 [21 ]= {Id = 21, Type = 3, Name = "装备获得", SubName = "天下第一", LevelMin = 40, LevelMax = 0, Info = "参与天下第一活动，可在战功商店兑换战功套装。", Icon = 1801109290, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 21075, RedPoint = false, },
 [22 ]= {Id = 22, Type = 3, Name = "装备获得", SubName = "等级礼包", LevelMin = 10, LevelMax = 0, Info = "达到特定等级可领取等级礼包，获得强力装备。", Icon = 1801109480, UIwindow = "WelfareUI,2", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [23 ]= {Id = 23, Type = 4, Name = "装备强化", SubName = "强化装备", LevelMin = 32, LevelMax = 0, Info = "强化装备可以提升装备的基础属性。", Icon = 1801109100, UIwindow = "EquipUI,1,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [24 ]= {Id = 24, Type = 4, Name = "装备强化", SubName = "宝石镶嵌", LevelMin = 32, LevelMax = 0, Info = "给装备的孔位镶嵌宝石，可以提升装备的属性。", Icon = 1801109260, UIwindow = "EquipUI,2,2", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 20030, RedPoint = false, },
 [25 ]= {Id = 25, Type = 4, Name = "装备强化", SubName = "装备炼化", LevelMin = 40, LevelMax = 0, Info = "炼化装备为装备增加特技特效。", Icon = 1801109250, UIwindow = "EquipUI,3,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 20030, RedPoint = false, },
 [26 ]= {Id = 26, Type = 4, Name = "装备强化", SubName = "装备修理", LevelMin = 32, LevelMax = 0, Info = "修理装备恢复装备效果。", Icon = 1801109100, UIwindow = "EquipUI,1,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 20030, RedPoint = false, },
 [27 ]= {Id = 27, Type = 5, Name = "宝石获得", SubName = "商城购买", LevelMin = 1, LevelMax = 0, Info = "在商城可以购买宝石。", Icon = 1801109270, UIwindow = "MallUI,1,2", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [28 ]= {Id = 28, Type = 5, Name = "宝石获得", SubName = "每日特惠", LevelMin = 1, LevelMax = 0, Info = "每日刷新和手动刷新可随机出现3级以上宝石出售。", Icon = 1801109270, UIwindow = "DiscountMallUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [29 ]= {Id = 29, Type = 5, Name = "宝石获得", SubName = "限时特惠", LevelMin = 1, LevelMax = 0, Info = "达到一定等级后，升级时会自动弹出限时特惠，可以低价购买高级宝石。", Icon = 1801109270, Map = 0, Jump = 0, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [30 ]= {Id = 30, Type = 5, Name = "宝石获得", SubName = "虔诚祈福", LevelMin = 13, LevelMax = 0, Info = "祈福可获得宝石。", Icon = 1801109520, UIwindow = "PrayUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 --[31 ]= {Id = 31, Type = 5, Name = "宝石获得", SubName = "VIP奖励", LevelMin = 1, LevelMax = 0, Info = "可从VIP福利领取宝石福袋。", Icon = 1801109480, UIwindow = "VipUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [32 ]= {Id = 32, Type = 5, Name = "宝石获得", SubName = "宝图挖宝", LevelMin = 35, LevelMax = 0, Info = "使用藏宝图挖宝，有几率获得宝石。", Icon = 1801109240, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 50001, RedPoint = false, },
 [33 ]= {Id = 33, Type = 5, Name = "宝石获得", SubName = "挑战神兽", LevelMin = 30, LevelMax = 0, Info = "参与神兽挑战活动，可以获得宝石。", Icon = 1801109280, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10023, RedPoint = false, },
 [34 ]= {Id = 34, Type = 5, Name = "宝石获得", SubName = "武道会", LevelMin = 50, LevelMax = 0, Info = "参与武道会活动，获胜方可以获得宝石。", Icon = 1801109450, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10243, RedPoint = false, },
 [35 ]= {Id = 35, Type = 5, Name = "宝石获得", SubName = "天梯挑战", LevelMin = 35, LevelMax = 0, Info = "每日参与天梯挑战，可以获得宝石奖励，并且可用荣誉换取宝石。", Icon = 1801109380, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10220, RedPoint = false, },
 [36 ]= {Id = 36, Type = 5, Name = "宝石获得", SubName = "宝石合成", LevelMin = 30, LevelMax = 0, Info = "低级宝石可合成高级宝石。", Icon = 1801109520, UIwindow = "EquipUI,2,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [37 ]= {Id = 37, Type = 5, Name = "宝石获得", SubName = "星官挑战", LevelMin = 40, LevelMax = 0, Info = "每天14:00-24:00参与十二星官挑战，有几率获得宝石。", Icon = 1801109520, UIwindow = "ActivityPanelUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [38 ]= {Id = 38, Type = 6, Name = "羽翼提升", SubName = "羽翼升级", LevelMin = 58, LevelMax = 0, Info = "可通过升级羽翼来提升属性。", Icon = 1801109480, UIwindow = "BagUI,4,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [39 ]= {Id = 39, Type = 6, Name = "羽翼提升", SubName = "羽翼解锁", LevelMin = 58, LevelMax = 0, Info = "可通过解锁羽翼来提升属性。", Icon = 1801109480, UIwindow = "BagUI,4,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [40 ]= {Id = 40, Type = 7, Name = "宠物获得", SubName = "商店购买", LevelMin = 10, LevelMax = 0, Info = "在商店可以购买野生宠物和仙兽。", Icon = 1801109300, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20015, RedPoint = false, },
 [41 ]= {Id = 41, Type = 7, Name = "宠物获得", SubName = "每日特惠", LevelMin = 10, LevelMax = 0, Info = "每日刷新和手动刷新可以随机出现变异宠物。", Icon = 1801109270, UIwindow = "DiscountMallUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [42 ]= {Id = 42, Type = 7, Name = "宠物获得", SubName = "连续充值", LevelMin = 10, LevelMax = 0, Info = "连续充值至第五天，可获得变异突破宠物蛋。", Icon = 1801109190, UIwindow = "SuperValueUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [43 ]= {Id = 43, Type = 7, Name = "宠物获得", SubName = "虔诚祈福", LevelMin = 13, LevelMax = 0, Info = "10连抽可以获得神兽碎片或仙兽，99碎片可以换取神兽。", Icon = 1801109520, UIwindow = "PrayUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [44 ]= {Id = 44, Type = 7, Name = "宠物获得", SubName = "VIP奖励", LevelMin = 10, LevelMax = 0, Info = "可从VIP福利领取神兽拼图。", Icon = 1801109480, UIwindow = "VipUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [45 ]= {Id = 45, Type = 7, Name = "宠物获得", SubName = "宠物捕捉", LevelMin = 35, LevelMax = 0, Info = "前往大雁塔、 遗址地宫、 水帘洞窟、 炼丹炉，可以捕捉宠物，几率遇到宠物宝宝或变异宠物宝宝。", Icon = 1801109310, Map = 0, Jump = 0, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [46 ]= {Id = 46, Type = 7, Name = "宠物获得", SubName = "帮派商店", LevelMin = 28, LevelMax = 0, Info = "低级商店出售神兽烈阳犬，满级商店出售神兽福气牛。", Icon = 1801109180, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20058, RedPoint = false, },
 [47 ]= {Id = 47, Type = 7, Name = "宠物获得", SubName = "宠物合成", LevelMin = 48, LevelMax = 0, Info = "通过宠物合成，可以获得新的宠物。", Icon = 1801109320, UIwindow = "PetUI,4,1", Map = 0, Jump = 4, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [48 ]= {Id = 48, Type = 7, Name = "宠物获得", SubName = "捐献兑换", LevelMin = 55, LevelMax = 0, Info = "通过捐献宠物，可以兑换适合突破的宠物蛋。", Icon = 1801109300, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20200, RedPoint = false, },
 [49 ]= {Id = 49, Type = 8, Name = "宠物提升", SubName = "宠物升级", LevelMin = 1, LevelMax = 0, Info = "提升宠物等级，可以提升宠物战力。", Icon = 1801109330, UIwindow = "PetUI,2,1", Map = 0, Jump = 4, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [50 ]= {Id = 50, Type = 8, Name = "宠物提升", SubName = "宠物培养", LevelMin = 30, LevelMax = 0, Info = "对宠物进行培养，可以提升宠物属性。", Icon = 1801109340, UIwindow = "PetUI,2,1", Map = 0, Jump = 4, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [51 ]= {Id = 51, Type = 8, Name = "宠物提升", SubName = "宠物洗炼", LevelMin = 46, LevelMax = 0, Info = "对宠物资质进行洗炼，可以提升宠物各项属性。", Icon = 1801109350, UIwindow = "PetUI,3,1", Map = 0, Jump = 4, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [52 ]= {Id = 52, Type = 8, Name = "宠物提升", SubName = "宠物学习技能", LevelMin = 30, LevelMax = 0, Info = "宠物学习技能可提升战斗力。", Icon = 1801109090, UIwindow = "PetUI,2,2", Map = 0, Jump = 4, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [53 ]= {Id = 53, Type = 8, Name = "宠物提升", SubName = "宠物穿戴装备", LevelMin = 1, LevelMax = 0, Info = "宠物穿戴装备可提升战斗力。", Icon = 1801109100, UIwindow = "PetUI,1,3", Map = 0, Jump = 4, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [54 ]= {Id = 54, Type = 8, Name = "宠物提升", SubName = "宠物修炼", LevelMin = 45, LevelMax = 0, Info = "学习宠物相关的修炼技能，可以提升宠物战力。", Icon = 1801109360, UIwindow = "RoleSkillUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [55 ]= {Id = 55, Type = 8, Name = "宠物提升", SubName = "宠物装备修理", LevelMin = 1, LevelMax = 0, Info = "修理宠物破损的装备恢复装备效果。", Icon = 1801109250, UIwindow = "PetEquipRepairUI", Map = 0, Jump = 5, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [56 ]= {Id = 56, Type = 8, Name = "宠物提升", SubName = "宠物突破", LevelMin = 46, LevelMax = 0, Info = "通过宠物突破可以提升宠物资质上限。", Icon = 1801109330, UIwindow = "PetUI,3,2", Map = 0, Jump = 4, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [57 ]= {Id = 57, Type = 8, Name = "宠物提升", SubName = "宠物加点", LevelMin = 51, LevelMax = 0, Info = "按宠物特色分配潜力点数，可以提升宠物战力。", Icon = 1801109080, UIwindow = "PetUI,1,1", Map = 0, Jump = 4, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [58 ]= {Id = 58, Type = 9, Name = "侍从获得", SubName = "剧情任务", LevelMin = 1, LevelMax = 0, Info = "参与剧情任务，可以获得侍从。", Icon = 1801109120, UIwindow = "QuestDlgUI,10", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [59 ]= {Id = 59, Type = 9, Name = "侍从获得", SubName = "商城购买", LevelMin = 1, LevelMax = 0, Info = "在商城可以购买侍从信物，用来合成召唤侍从。", Icon = 1801109270, UIwindow = "MallUI,2,5", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [60 ]= {Id = 60, Type = 9, Name = "侍从获得", SubName = "七日活动", LevelMin = 24, LevelMax = 0, Info = "连续登陆七天可以获得哪吒，每日完成七日目标可以获得敖丙碎片。", Icon = 1801109240, UIwindow = "Activity7DaysUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [61 ]= {Id = 61, Type = 9, Name = "侍从获得", SubName = "每日特惠", LevelMin = 1, LevelMax = 0, Info = "每日刷新和手动刷新可随机出现SSR信物出售。", Icon = 1801109270, UIwindow = "DiscountMallUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [62 ]= {Id = 62, Type = 9, Name = "侍从获得", SubName = "首充大礼", LevelMin = 1, LevelMax = 0, Info = "可以获得SSR侍从：金角大王。", Icon = 1801109190, UIwindow = "FirstRechargeUI,10", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [63 ]= {Id = 63, Type = 9, Name = "侍从获得", SubName = "限时特惠", LevelMin = 1, LevelMax = 0, Info = "达到一定等级后，升级时会自动弹出限时特惠，可以购得侍从信物。", Icon = 1801109270, Map = 0, Jump = 0, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [64 ]= {Id = 64, Type = 9, Name = "侍从获得", SubName = "虔诚祈福", LevelMin = 13, LevelMax = 0, Info = "祈福可获得侍从信物。", Icon = 1801109520, UIwindow = "PrayUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [65 ]= {Id = 65, Type = 9, Name = "侍从获得", SubName = "VIP奖励", LevelMin = 1, LevelMax = 0, Info = "可从VIP福利领取侍从信物。", Icon = 1801109480, UIwindow = "VipUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [66 ]= {Id = 66, Type = 9, Name = "侍从获得", SubName = "帮派商店", LevelMin = 28, LevelMax = 0, Info = "可以购买侍从招募令。", Icon = 1801109180, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20058, RedPoint = false, },
 [67 ]= {Id = 67, Type = 10, Name = "侍从提升", SubName = "激活情缘技能", LevelMin = 13, LevelMax = 0, Info = "获得更多的侍从，激活情缘技能可以提升侍从的能力。", Icon = 1801109390, UIwindow = "GuardUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [68 ]= {Id = 68, Type = 10, Name = "侍从提升", SubName = "侍从升星", LevelMin = 13, LevelMax = 0, Info = "为侍从使用信物，可以提升侍从的星级，强化侍从的能力。", Icon = 1801109400, UIwindow = "GuardUI,2", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [69 ]= {Id = 69, Type = 10, Name = "侍从提升", SubName = "侍从技能提升", LevelMin = 13, LevelMax = 0, Info = "提升侍从的技能，可以强化侍从的能力。", Icon = 1801109110, UIwindow = "GuardUI,1,2", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [70 ]= {Id = 70, Type = 10, Name = "侍从提升", SubName = "侍从激活", LevelMin = 13, LevelMax = 0, Info = "激活侍从加成，可永久提升主角属性。", Icon = 1801109400, UIwindow = "GuardUI,4", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [71 ]= {Id = 71, Type = 11, Name = "阵法提升", SubName = "阵法获得", LevelMin = 30, LevelMax = 0, Info = "可从商会购买阵法书。", Icon = 1801109460, UIwindow = "CommerceUI,4,40", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [72 ]= {Id = 72, Type = 11, Name = "阵法提升", SubName = "阵法学习", LevelMin = 30, LevelMax = 0, Info = "可通过使用阵法道具，解锁更多阵法。", Icon = 1801109470, UIwindow = "BattleSeatUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [73 ]= {Id = 73, Type = 11, Name = "阵法提升", SubName = "阵法升级", LevelMin = 30, LevelMax = 0, Info = "可通过使用阵法道具，提升阵法等级。", Icon = 1801109470, UIwindow = "BattleSeatUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [74 ]= {Id = 74, Type = 12, Name = "银币获得", SubName = "剧情任务", LevelMin = 1, LevelMax = 0, Info = "参与剧情任务，可以获得大量的银币。", Icon = 1801109120, UIwindow = "QuestDlgUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [75 ]= {Id = 75, Type = 12, Name = "银币获得", SubName = "银币兑换", LevelMin = 1, LevelMax = 0, Info = "可以用金元宝兑换银币。", Icon = 1801109160, UIwindow = "ExchangeUI,296,300", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [76 ]= {Id = 76, Type = 12, Name = "银币获得", SubName = "商店出售", LevelMin = 1, LevelMax = 0, Info = "在商店出售游戏道具，可以获得银币。", Icon = 1801109170, Map = 0, Jump = 0, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [77 ]= {Id = 77, Type = 12, Name = "银币获得", SubName = "师门任务", LevelMin = 34, LevelMax = 0, Info = "每天完成20次师门任务，可以获得银币。", Icon = 1801109130, UIwindow = "QuestDlgUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [78 ]= {Id = 78, Type = 12, Name = "银币获得", SubName = "降妖任务", LevelMin = 35, LevelMax = 0, Info = "组队参与降妖任务，可以获得银币。", Icon = 1801109140, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10014, RedPoint = false, },
 [79 ]= {Id = 79, Type = 12, Name = "银币获得", SubName = "护送任务", LevelMin = 30, LevelMax = 0, Info = "每天完成3次护送任务，可以获得大量的银币。", Icon = 1801109180, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10122, RedPoint = false, },
 [80 ]= {Id = 80, Type = 12, Name = "银币获得", SubName = "闹事的妖怪", LevelMin = 25, LevelMax = 0, Info = "组队降伏闹事的妖怪，可以获得银币。", Icon = 1801109500, UIwindow = "ActivityPanelUI,0", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [81 ]= {Id = 81, Type = 12, Name = "银币获得", SubName = "天下会武", LevelMin = 42, LevelMax = 0, Info = "参与天下会武活动，可以获得大量银币。", Icon = 1801109290, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 21074, RedPoint = false, },
 [82 ]= {Id = 82, Type = 12, Name = "银币获得", SubName = "天下第一", LevelMin = 42, LevelMax = 0, Info = "参与天下第一活动，可以获得大量银币。", Icon = 1801109290, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 21075, RedPoint = false, },
 [83 ]= {Id = 83, Type = 13, Name = "银元宝获得", SubName = "成就奖励", LevelMin = 25, LevelMax = 0, Info = "完成成就目标，可领取银元宝。", Icon = 1801109480, UIwindow = "BeStrongUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [84 ]= {Id = 84, Type = 14, Name = "金元宝获得", SubName = "月卡福利", LevelMin = 10, LevelMax = 0, Info = "充值月卡后，即可每天获得超值的金元宝奖励。", Icon = 1801109130, UIwindow = "SuperValueUI,4", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [85 ]= {Id = 85, Type = 13, Name = "银元宝获得", SubName = "银元宝兑换", LevelMin = 1, LevelMax = 0, Info = "可以用金元宝兑换银元宝。", Icon = 1801109190, UIwindow = "ExchangeUI,296,297", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [86 ]= {Id = 86, Type = 13, Name = "银元宝获得", SubName = "活跃度奖励", LevelMin = 25, LevelMax = 0, Info = "每日活跃度达到70和90时，可领取银元宝奖励。", Icon = 1801109520, UIwindow = "ActivityPanelUI,0", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [87 ]= {Id = 87, Type = 13, Name = "银元宝获得", SubName = "师门任务", LevelMin = 34, LevelMax = 0, Info = "完成师门任务，有几率获得银元宝。", Icon = 1801109130, UIwindow = "QuestDlgUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [88 ]= {Id = 88, Type = 13, Name = "银元宝获得", SubName = "降妖任务", LevelMin = 35, LevelMax = 0, Info = "组队参与降妖任务，可以获得银元宝。", Icon = 1801109140, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10014, RedPoint = false, },
 [89 ]= {Id = 89, Type = 13, Name = "银元宝获得", SubName = "挑战神兽", LevelMin = 30, LevelMax = 0, Info = "挑战神兽有几率获得银元宝。", Icon = 1801109280, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10023, RedPoint = false, },
 [90 ]= {Id = 90, Type = 13, Name = "银元宝获得", SubName = "门派历练", LevelMin = 30, LevelMax = 0, Info = "周二、四、六、日，参与门派历练，有几率获得银元宝。", Icon = 1801109560, UIwindow = "ActivityPanelUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [91 ]= {Id = 91, Type = 13, Name = "银元宝获得", SubName = "护卫银子", LevelMin = 30, LevelMax = 0, Info = "参与护卫银子，有几率获得银元宝。", Icon = 1801109180, UIwindow = "ActivityPanelUI,0", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [92 ]= {Id = 92, Type = 13, Name = "银元宝获得", SubName = "挑战副本", LevelMin = 50, LevelMax = 0, Info = "参与副本，有几率获得银元宝。", Icon = 1801109140, UIwindow = "ActivityPanelUI,0", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [93 ]= {Id = 93, Type = 13, Name = "银元宝获得", SubName = "闹事的妖怪", LevelMin = 25, LevelMax = 0, Info = "组队降伏闹事的妖怪，有几率获得银元宝。", Icon = 1801109500, UIwindow = "ActivityPanelUI,0", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [94 ]= {Id = 94, Type = 13, Name = "银元宝获得", SubName = "门派入侵", LevelMin = 30, LevelMax = 0, Info = "每天10:00-22:00参与门派入侵，有几率获得银元宝。", Icon = 1801109460, UIwindow = "ActivityPanelUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [95 ]= {Id = 95, Type = 13, Name = "银元宝获得", SubName = "帮派强盗", LevelMin = 30, LevelMax = 0, Info = "参与帮派强盗，有几率获得银元宝。", Icon = 1801109560, UIwindow = "FactionUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [96 ]= {Id = 96, Type = 13, Name = "银元宝获得", SubName = "星官挑战", LevelMin = 40, LevelMax = 0, Info = "每天14:00-24:00参与十二星官挑战，有几率获得银元宝。", Icon = 1801109520, UIwindow = "ActivityPanelUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [97 ]= {Id = 97, Type = 13, Name = "银元宝获得", SubName = "天地大劫", LevelMin = 40, LevelMax = 0, Info = "每天10:00-13:00 17:00-22:00参与天地大劫，有几率获得银元宝。", Icon = 1801109460, UIwindow = "ActivityPanelUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [98 ]= {Id = 98, Type = 13, Name = "银元宝获得", SubName = "公主嫁妆", LevelMin = 30, LevelMax = 0, Info = "每天12:00-13:00 20:00-21:00参与公主嫁妆，有几率获得银元宝。", Icon = 1801109180, UIwindow = "ActivityPanelUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [99 ]= {Id = 99, Type = 13, Name = "银元宝获得", SubName = "长安保卫战", LevelMin = 10, LevelMax = 0, Info = "周日19:00-20:00在长安击退敌军，有几率获得银元宝。", Icon = 1801109550, Map = 0, Jump = 0, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [100 ]= {Id = 100, Type = 13, Name = "银元宝获得", SubName = "宝阁大开", LevelMin = 30, LevelMax = 0, Info = "周五19:30-20:30参与宝阁大开，有几率获得银元宝。", Icon = 1801109560, UIwindow = "FactionUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [101 ]= {Id = 101, Type = 13, Name = "银元宝获得", SubName = "守卫粮仓", LevelMin = 30, LevelMax = 0, Info = "周二、四19:30-20:30参与守卫粮仓，有几率获得银元宝。", Icon = 1801109560, UIwindow = "FactionUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [102 ]= {Id = 102, Type = 13, Name = "银元宝获得", SubName = "伏魔任务", LevelMin = 100, LevelMax = 0, Info = "参与伏魔任务，有几率获得银元宝。", Icon = 1801109140, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 10014, RedPoint = false, },
 [103 ]= {Id = 103, Type = 13, Name = "银元宝获得", SubName = "天降宝箱", LevelMin = 25, LevelMax = 0, Info = "每天11:00-13:00、17:00-19:00在长安拾取宝箱，有几率获得银元宝。", Icon = 1801109480, Map = 0, Jump = 0, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [104 ]= {Id = 104, Type = 14, Name = "金元宝获得", SubName = "充值", LevelMin = 1, LevelMax = 0, Info = "进入充值界面充值获得金元宝。", Icon = 1801109170, UIwindow = "MallUI,充值", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [105 ]= {Id = 105, Type = 15, Name = "药物获得", SubName = "烹饪", LevelMin = 41, LevelMax = 0, Info = "烹饪获得战斗外食用的菜肴。", Icon = 1801109110, UIwindow = "ProduceUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [106 ]= {Id = 106, Type = 15, Name = "药物获得", SubName = "炼药", LevelMin = 41, LevelMax = 0, Info = "炼药获得可在战斗内食用的丹药。", Icon = 1801109470, UIwindow = "ProduceUI,2", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [107 ]= {Id = 107, Type = 15, Name = "药物获得", SubName = "商店购买", LevelMin = 30, LevelMax = 0, Info = "可从商店购买成品药物。", Icon = 1801109210, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20025, RedPoint = false, },
 [108 ]= {Id = 108, Type = 16, Name = "功勋获得", SubName = "装备功勋获得", LevelMin = 55, LevelMax = 0, Info = "可通过捐献装备获得装备功勋。", Icon = 1801109100, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20200, RedPoint = false, },
 [109 ]= {Id = 109, Type = 16, Name = "功勋获得", SubName = "宠物功勋获得", LevelMin = 55, LevelMax = 0, Info = "可通过捐献宠物获得宠物功勋。", Icon = 1801109320, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20200, RedPoint = false, },
 [110 ]= {Id = 110, Type = 17, Name = "活力消耗", SubName = "活力消耗", LevelMin = 1, LevelMax = 0, Info = "可通过消耗活力完成获得奖励。", Icon = 1801109250, UIwindow = "VitalityUI,1", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [111 ]= {Id = 111, Type = 18, Name = "帮贡获得", SubName = "帮派玩法", LevelMin = 28, LevelMax = 0, Info = "参与帮派玩法可以获得帮贡。", Icon = 1801109410, UIwindow = "FactionUI,3", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [112 ]= {Id = 112, Type = 18, Name = "帮贡获得", SubName = "帮派捐献", LevelMin = 28, LevelMax = 0, Info = "通过帮派捐献获得帮贡。", Icon = 1801109410, UIwindow = "FactionUI,1,101", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 0, RedPoint = false, },
 [113 ]= {Id = 113, Type = 19, Name = "建立关系", SubName = "师徒关系", LevelMin = 25, LevelMax = 0, Info = "建立师徒关系，从其他维度让自己变得更强。", Icon = 1801109490, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20039, RedPoint = false, },
 [114 ]= {Id = 114, Type = 19, Name = "建立关系", SubName = "加入帮派", LevelMin = 28, LevelMax = 0, Info = "加入一个强大的帮派能够获得强大庇护。", Icon = 1801109410, UIwindow = "FactionUI,", Map = 0, Jump = 1, X = 0, Y = 0, NPC = 20045, RedPoint = false, },
 [115 ]= {Id = 115, Type = 19, Name = "建立关系", SubName = "夫妻关系", LevelMin = 31, LevelMax = 0, Info = "与伴侣确定关系，在风雨飘摇的江湖之中终究不再孤身一人。更可获得强大姻缘技能。", Icon = 1801109510, Map = 0, Jump = 2, X = 0, Y = 0, NPC = 20041, RedPoint = false, },
}
local NbTable = NbTable_Id
-- 提升页前往按钮对应跳转, 数字对应NbTable_Id表中的Type字段值, Count: 变强页左侧标签数量
local Nb_cfg = { Skill = 2, Equip = 4, Pet = 8, Guard = 10, Wing = 6, Count = 0 }

-- Id -> 编号
-- Type -> 类型
-- SubType -> 子类型
-- Name -> 名称
-- Info -> 介绍信息
-- Icon -> 图标编号
-- AchPoints -> 成就点
-- attr -> 货币属性ID
-- BindIngot -> 货币数量
-- ItemId -> 物品ID
-- ItemCount -> 物品数量
-- Goal -> 目标
-- CoefType1 -> 参数类型1
-- Coef1 -> 参数1
-- CoefType2 -> 参数类型2
-- Coef2 -> 参数2
-- FunType -> 前往类型
-- FunctionCoef -> 功能参数
-- Job -> 门派

BeStrongUI.GrowupTable_Id = {}

local FINISHED_LIST = { [0] = { Count = 1, TypeName = "全部", List = { [0] = { Count = 0, SubList = {} } }, SubType = 0 ,Finish = 0,Total = 0} }


local maintype_name_cfg = {
    [0] = "", [1] = "目标", [2] = "活动", [3] = "成长", [4] = "社交", [5] = "宠物", [6] = "侍从", [7] = "其他",
}

local subtype_name_cfg = {
    [201] = "主线任务",
    [202] = "日常任务",
    [203] = "日常副本",
    [204] = "限时活动",
    [205] = "活跃度奖励",
    [301] = "等级",
    [302] = "技能",
    [303] = "装备",
    [304] = "阵法",
    [305] = "战斗",
    [306] = "羽翼",
    [307] = "官职",
    [308] = "宠物",
    [309] = "侍从",
    [401] = "好友",
    [402] = "师徒",
    [403] = "帮派",
    [404] = "组队",
}

-- 成就页右侧奖励物品配置 297：银元宝 300：银币
local iconIdCfg = { [297] = "1900001460", [300] = "1900090030" }

local achievement_cfg = { [0] = { Count = 1, TypeName = "全部", List = { [0] = { Count = 0, SubList = {} } }, SubType = 0 ,Finish = 0,Total = 0} }

local currMainTypeBtn = nil -- 当前主标签按钮
local allMainTypeBtn = nil -- 全部主标签按钮
local currSubTypeBtn = nil  -- 当前子标签按钮

-------------------------------------
BeStrongUI.TypeGroup = {}
BeStrongUI.SelectType = -1
BeStrongUI.PreSelectTypeBtn = nil
BeStrongUI.FirstTypeBtn = nil

function BeStrongUI.Main(parameter)
    BeStrongUI.RedPointList = nil

    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("BeStrongUI", "BeStrongUI", 0, 0)
    UILayout.SetAnchorAndPivot(wnd, UIAnchor.Center, UIAroundPivot.Center)

    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "变    强", "BeStrongUI", "OnExit", _gt)
    UILayout.CreateRightTab(labelList, "BeStrongUI")
    _gt.BindName(panelBg, "panelBg")

    -- 创建侧边标签页UI
    local cnt = #labelList
    for i = 1, cnt do
        assert(load([[BeStrongUI.]]..labelList[i][5]..[[()]]))()
    end
    GUI.SetVisible(wnd, false)
end

function BeStrongUI.OnShow(parameter)
    --print(inspect(GlobalProcessing['BeStrongBtn_Reds']))
    if MainUI and MainUI.MainUISwitchConfig then
        local level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
        if level < MainUI.MainUISwitchConfig["变强"].OpenLevel then
            CL.SendNotify(NOTIFY.ShowBBMsg,MainUI.MainUISwitchConfig["变强"].OpenLevel.."级开启变强功能")
            return
        end
    end
    jump = nil
    if parameter then
        local index1
        index1 = UIDefine.GetParameterStr(parameter)
        index1 = tonumber(index1)
        if index1 == 3 then
            BeStrongUI.OnAchievementToggleClick()
            return
        end
    end
    local wnd = GUI.GetWnd("BeStrongUI")
    achievement_cfg = { [0] = { Count = 1, TypeName = "全部", List = { [0] = { Count = 0, SubList = {} } }, SubType = 0 ,Finish = 0 , Total = 0} , }
    Achievement_Max_Point = 0
    NbTable = NbTable_Id
    if wnd then
        --GUI.SetVisible(wnd, true)
        CL.SendNotify(NOTIFY.SubmitForm, "FormBeStrong", "GetPromotionConfig")
        CL.SendNotify(NOTIFY.SubmitForm,"FormBeStrong", "GetAchievement")
    end
    if parameter then
        jump = parameter
    end
end

function BeStrongUI.CreateAchievement()
--[[    local Achievement = _gt.GetUI(labelList[pageNum.Achievement][4])
    if Achievement then]]
        BeStrongUI.CreateAchievementTogglePage()
    --end
end
function BeStrongUI.RefreshAchievement()
    --print(inspect(BeStrongUI.RefreshData))
    local type = BeStrongUI.RefreshData.Type
    local subType = BeStrongUI.RefreshData.SubType
    local Num = #achievement_cfg[type].List[subType].SubList
    for i = 1,Num do
        if achievement_cfg[type].List[subType].SubList[i].Id == BeStrongUI.RefreshData.Id then
            table.remove(achievement_cfg[type].List[subType].SubList,i)
            table.insert(achievement_cfg[type].List[subType].SubList,BeStrongUI.RefreshData)
            --table.insert(FINISHED_LIST[type].List[subType].SubList,BeStrongUI.RefreshData,-1)
            achievement_cfg[type].Finish = achievement_cfg[type].Finish + 1
            --print("分级列表改变数据")
            break
        end
    end
    for i = 1 , #achievement_cfg[0].List[0].SubList do
        if achievement_cfg[0].List[0].SubList[i].Id == BeStrongUI.RefreshData.Id then
            table.remove(achievement_cfg[0].List[0].SubList,i)
            table.insert(achievement_cfg[0].List[0].SubList,BeStrongUI.RefreshData)
            --table.insert(FINISHED_LIST[0].List[0].SubList,BeStrongUI.RefreshData,-1)
            achievement_cfg[0].Finish = achievement_cfg[0].Finish + 1
            --print("全部列表改变数据")
            break
        end
    end
    local rightLoopScroll = _gt.GetUI("achRightLoopScroll")
    GUI.LoopScrollRectRefreshCells(rightLoopScroll)
    local rightPage = _gt.GetUI("Achievement_rightPage")
    local scrollBar = GUI.GetChild(rightPage,"scrollBar")
    local achTxt = GUI.GetChild(scrollBar,"achTxt")

    GUI.ScrollBarSetPos(scrollBar,BeStrongUI.AchievementPoint/Achievement_Max_Point)
    GUI.StaticSetText(achTxt,BeStrongUI.AchievementPoint.."/"..Achievement_Max_Point)

    local BtnAll = _gt.GetUI("typeBtn"..0)
    local NowBtn = _gt.GetUI("typeBtn"..type)
    local txtAll = "<color=#66310e>" .. "全部" ..
            "</color><color=#975c22><size=20>（" .. achievement_cfg[0].Finish .. "/" .. achievement_cfg[0].Total .. "）" .. "</size></color>"
    GUI.ButtonSetText(BtnAll,txtAll)
    local txtNow = "<color=#66310e>" .. maintype_name_cfg[type] ..
            "</color><color=#975c22><size=20>（" .. achievement_cfg[type].Finish .. "/" .. achievement_cfg[type].Total .. "）" .. "</size></color>"
    GUI.ButtonSetText(NowBtn,txtNow)
    local Count = 0
    if tonumber(achievement_cfg[0].List[0].SubList[1].ButtonState) ~= 1 then
        local TypeBtn = _gt.GetUI("typeBtn0")
        GUI.SetRedPointVisable(TypeBtn,false)
    else
        Count = Count + 1
    end
    if tonumber(achievement_cfg[type].List[subType].SubList[1].ButtonState) ~= 1 then
        local TypeBtn = _gt.GetUI("typeBtn"..type)
        local SubTypeBtn = _gt.GetUI("subtypeBtn"..subType)
        GUI.SetRedPointVisable(TypeBtn,false)
        GUI.SetRedPointVisable(SubTypeBtn,false)
    else
        Count = Count + 1
    end
    if Count == 0 then
        local panelBg = _gt.GetUI("panelBg")
        local tableList = GUI.GetChild(panelBg,"tabList",false)
        local AchievementToggle = GUI.GetChild(tableList,"AchievementToggle",false)
        GUI.SetRedPointVisable(AchievementToggle,false)
        local btn = _gt.GetUI("plusBtn")
        GUI.SetRedPointVisable(btn,false)
    end
end
function BeStrongUI.InitData()
    local cfg = BeStrongUI.PromotionConfig
    for i = 1, #promotion_cfg do
        local tb = cfg[promotion_cfg[i].Name]
        if tb then
            promotion_cfg[i].UnlockLevel = tb.UnlockLevel
        end
    end
end

function BeStrongUI.Refresh()
    BeStrongUI.InitData()
    if jump ~= nil then
        if string.find(jump, "index") then
            --print(jump)
            local index1, index2 = nil
            index1, index2 = UIDefine.GetParameterStr(jump)
            index1 = tonumber(index1)
            index2 = tonumber(index2)
            if index1 == 2 then
                local btn = _gt.GetUI("btn"..index2)
                local idx = tonumber(GUI.GetData(btn, "type"))
                if btn then
                    BeStrongUI.RefreshStrengthenTogglePage(_gt.GetUI(labelList[pageNum.Strengthen][4]))
                    BeStrongUI.OnTypeBtnClick(GUI.GetGuid(btn))
                    GUI.ScrollRectSetNormalizedPosition(_gt.GetUI("leftScroll"), Vector2.New(0, 1 - (idx / Nb_cfg.Count)))
                end
            elseif index1 == 3 then
                BeStrongUI.OnAchievementToggleClick()
            end
        end
    elseif jump == nil then
        BeStrongUI.OnPromotionToggleClick()
    end
    local wnd = GUI.GetWnd("BeStrongUI")
    if wnd then
        GUI.SetVisible(wnd,true)
    end
end

function BeStrongUI.OnTypeBtnClick(guid)
    --print(inspect(GlobalProcessing["BeStrongBtn_Reds"]))
    --print("1112")
    local btn = GUI.GetByGuid(guid)
--[[    if BeStrongUI.PreSelectTypeBtn == btn then
        return
    end]]
    if BeStrongUI.PreSelectTypeBtn ~= nil then
        GUI.ButtonSetImageID(BeStrongUI.PreSelectTypeBtn, "1800002030")
    end
    GUI.ButtonSetImageID(btn, "1800002031")
    BeStrongUI.PreSelectTypeBtn = btn
    --print(BeStrongUI.PreSelectTypeBtn)
    BeStrongUI.SelectType = tonumber(GUI.GetData(btn, "type"))
    if BeStrongUI.SelectType then
        local count = #(BeStrongUI.TypeGroup[BeStrongUI.SelectType].Ids)
        local rightScroll = _gt.GetUI("rightScroll")
        GUI.LoopScrollRectSetTotalCount(rightScroll, count)
        GUI.LoopScrollRectRefreshCells(rightScroll)
    end
end

function BeStrongUI.CreatItemPool()
    local sellScroll =  _gt.GetUI("rightScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(sellScroll)
    
    local bg = GUI.ImageCreate(sellScroll,"scrollItemBg"..curCount, "1801100010", 0, 0, false, 820, 120)
    local ItemBg = GUI.ImageCreate( bg,"ItemBg", "1800400050", -344, 0)
    local icon = GUI.ImageCreate( ItemBg,"icon", "1800400050", 0, 0)
    local line = GUI.ImageCreate( ItemBg,"cutline", "1801601080", 208, 0, false, 2, 115)

    local upName = GUI.CreateStatic( ItemBg,"name", "", 96, 7, 150, 30)
    UILayout.SetSameAnchorAndPivot(upName, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(upName, 24, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local downName = GUI.CreateStatic( ItemBg,"info", "等级需求:1", 96, 43, 150, 30)
    UILayout.SetSameAnchorAndPivot(downName, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(downName, 22, UIDefine.Yellow2Color, TextAnchor.MiddleLeft)

    local desTxt = GUI.CreateStatic( ItemBg,"desc", "", 255, -15, 380, 100, "system", true)
    UILayout.SetSameAnchorAndPivot(desTxt, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(desTxt, 22, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local clickBtn = GUI.ButtonCreate( ItemBg,"gotoBtn", "1800402110", 672, 0, Transition.ColorTint, "前往", 122, 46, false)
    GUI.ButtonSetTextFontSize(clickBtn, 24)
    GUI.ButtonSetTextColor(clickBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(clickBtn, UCE.PointerClick, "BeStrongUI", "OnClickGotoBtn")
    GUI.SetVisible(clickBtn, true)
    GUI.AddRedPoint(clickBtn,UIAnchor.TopLeft,10,10,"1800208080")
    GUI.SetRedPointVisable(clickBtn,false)
    return bg
end

function BeStrongUI.RefreshItemScroll(parameter)

    if BeStrongUI.SelectType == nil then
        return
    end

    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])

    local id = BeStrongUI.TypeGroup[BeStrongUI.SelectType].Ids[index+1]
    local targetItem = NbTable_Id[id]
    local itemBg = GUI.GetByGuid(guid)
    if targetItem and itemBg then
        local icon = GUI.GetChildByPath(itemBg, "ItemBg/icon")
        if icon then
            GUI.ImageSetImageID(icon, tostring(targetItem.Icon))
        end
        local name = GUI.GetChildByPath(itemBg, "ItemBg/name")
        if name then
            GUI.StaticSetText(name, targetItem.SubName)
        end
        local info = GUI.GetChildByPath(itemBg, "ItemBg/info")
        if info then
            GUI.StaticSetText(info, "等级需求："..tostring(targetItem.LevelMin))
        end
        local desc = GUI.GetChildByPath(itemBg, "ItemBg/desc")
        if desc then
            GUI.StaticSetText(desc, targetItem.Info)
        end
        local gotoBtn = GUI.GetChildByPath(itemBg, "ItemBg/gotoBtn")
        if gotoBtn then
            GUI.SetData(gotoBtn, "index", tostring(id))
            GUI.SetVisible(gotoBtn, targetItem.Jump ~= 0)
            GUI.SetRedPointVisable(gotoBtn,NbTable[id].RedPoint)
        end
    end
end

-- 变强前往按钮点击事件
function BeStrongUI.OnClickGotoBtn(guid)
    local btn = GUI.GetByGuid(guid)
    local id = tonumber(GUI.GetData(btn, "index"))
    local targetItem = NbTable_Id[id]
    if targetItem then
        local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
        if roleLevel < targetItem.LevelMin then
            CL.SendNotify(NOTIFY.ShowBBMsg, "您的等级不足，无法前往")
            return
        end

        local jumpType = targetItem.Jump
        --打开界面
        if jumpType==1 then
            if targetItem.UIwindow ~= "0" then
                local strs = string.split(targetItem.UIwindow, ",")
                local count = #strs
                local targetUI = ""
                local targetUIIndex1 = "0"
                local targetUIIndex2 = "0"
                if count >= 1 then
                    targetUI = strs[1]
                end
                if count >= 2 then
                    targetUIIndex1 = strs[2]
                end
                if count >= 3 then
                    targetUIIndex2 = strs[3]
                end
                if targetUI == "FactionUI" then
                    local FactionData = LD.GetGuildData()
                    if FactionData.guild == nil or tostring(FactionData.guild.guid) == "0" then
                        targetUI = "FactionCreateUI"
                    end
                end
                GetWay.Def[1].jump(targetUI, targetUIIndex1, targetUIIndex2)
            else
                --CDebug.LogError("!!! 变强前往配置错误，打开UI，参数UIwindow却配置为0")
            end
            --前往NPC
        elseif jumpType == 2 then
            GetWay.Def[2].jump(targetItem.NPC)
            BeStrongUI.OnExit()
            --前往到地图点
        elseif jumpType == 3 then
            GetWay.Def[3].jump(targetItem.Map, targetItem.X, targetItem.Y)
		elseif jumpType ==4 then --宠物
            if targetItem.UIwindow ~= "0" then
                local strs = string.split(targetItem.UIwindow, ",")
                local count = #strs
                local targetUI = ""
                local targetUIIndex1 = "0"
                local targetUIIndex2 = "0"
                if count >= 1 then
                    targetUI = strs[1]
                end
                if count >= 2 then
                    targetUIIndex1 = strs[2]
                end
                if count >= 3 then
                    targetUIIndex2 = strs[3]
                end			
                if targetUI == "FactionUI" then
                    local FactionData = LD.GetGuildData()
                    if FactionData.guild == nil or tostring(FactionData.guild.guid) == "0" then
                        targetUI = "FactionCreateUI"
                    end
                end		
				GetWay.Def[7].jump(targetUI, targetUIIndex1, targetUIIndex2)
			end
		elseif jumpType ==5 then  --宠物装备
			GUI.OpenWnd(targetItem.UIwindow)
        end
    end
end

function BeStrongUI.Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

function BeStrongUI.CheckForTeamMember()
    local RoleState =  LD.GetRoleInTeamState()
    if RoleState == 3 then
        CL.SendNotify(NOTIFY.ShowMessageBubble, "操作失败，您不是队长无法进行该操作。")
        return false
    end
    return true
end

function BeStrongUI.OnExit()
    --GUI.DestroyWnd("BeStrongUI")
    GUI.CloseWnd("BeStrongUI")
    BeStrongUI.OnPromotionToggleClick()
end

-- 重置选择的最后一个侧边栏标签页
function BeStrongUI.ResetLastSelectPage(index)
    index = tonumber(index) or 1

    UILayout.OnTabClick(index, labelList)
    if currToggleIndex ~= index then
        BeStrongUI.SetLastSelectPage()
        currToggleIndex = index
    end
end

function BeStrongUI.SetLastSelectPage()
    local togglePage = _gt.GetUI(labelList[currToggleIndex][4])
    if togglePage then
        GUI.SetVisible(togglePage, false)
    end
end

-------------------点击事件函数--------------------
-- 提升点击事件
function BeStrongUI.OnPromotionToggleClick()
    local togglePage = _gt.GetUI(labelList[pageNum.Promotion][4])
    if not togglePage then return end
    --print("提升点击")
    BeStrongUI.RefreshPromotionTogglePage(togglePage)
end

-- 变强点击事件
function BeStrongUI.OnStrengthenToggleClick()
    local togglePage = _gt.GetUI(labelList[pageNum.Strengthen][4])
    if not togglePage then return end
    local FirstBtn = _gt.GetUI("btn0")
    BeStrongUI.FirstTypeBtn = GUI.GetGuid(FirstBtn)
    BeStrongUI.OnTypeBtnClick(BeStrongUI.FirstTypeBtn)
    BeStrongUI.RefreshStrengthenTogglePage(togglePage)
end

-- 成就点击事件
function BeStrongUI.OnAchievementToggleClick()
    local togglePage = _gt.GetUI(labelList[pageNum.Achievement][4])
    if not togglePage then return end

    BeStrongUI.RefreshAchievementTogglePage(togglePage)
end
-- 提升点击前往按钮点击事件
function BeStrongUI.OnPromotionGotoBtnClick(guid)
    local gotoBtn = GUI.GetByGuid(guid)
    local unlockLevel = tonumber(GUI.GetData(gotoBtn, "unlockLevel"))
    local roleLevel = int64.longtonum2(CL.GetAttr(RoleAttr.RoleAttrLevel))
    if unlockLevel and roleLevel < unlockLevel then
        CL.SendNotify(NOTIFY.ShowBBMsg, "该功能"..unlockLevel.."级解锁")
        return
    end

    local index = tonumber(GUI.GetData(gotoBtn, "index"))
    BeStrongUI.ListScrolling(index)
end

function BeStrongUI.ListScrolling(index,type)
    local btn = nil
    local idx = nil
    if index == promotion_cfg.Equip then
        btn = _gt.GetUI("btn"..Nb_cfg.Equip)
        idx = tonumber(GUI.GetData(btn, "type"))
    elseif index == promotion_cfg.Pet then
        btn = _gt.GetUI("btn"..Nb_cfg.Pet)
        idx = tonumber(GUI.GetData(btn, "type"))
    elseif index == promotion_cfg.Skill then
        btn = _gt.GetUI("btn"..Nb_cfg.Skill)
        idx = tonumber(GUI.GetData(btn, "type"))
    elseif index == promotion_cfg.Guard then
        btn = _gt.GetUI("btn"..Nb_cfg.Guard)
        idx = tonumber(GUI.GetData(btn, "type"))
    elseif index == promotion_cfg.Wing then
        btn = _gt.GetUI("btn"..Nb_cfg.Wing)
        idx = tonumber(GUI.GetData(btn, "type"))
    end

    if btn then
        BeStrongUI.RefreshStrengthenTogglePage(_gt.GetUI(labelList[pageNum.Strengthen][4]))
        BeStrongUI.OnTypeBtnClick(GUI.GetGuid(btn))
        GUI.ScrollRectSetNormalizedPosition(_gt.GetUI("leftScroll"), Vector2.New(0,1-(idx / Nb_cfg.Count)))
    end

end

-- 成就页左侧主标签按钮点击事件
function BeStrongUI.OnMainTypeBtnClick(guid)
--[[    print(guid)
    local check = _gt.GetUI("check")
    GUI.CheckBoxExSetCheck(check,false)
    FINISHED_TYPE = false]]
    guid = tostring(guid)
    if not currMainTypeBtn then return end

    for k, v in pairs(achievement_cfg) do
        local typeBtn = _gt.GetUI("typeBtn"..k)
        local tp = GUI.GetData(typeBtn, "type")
        local subScroll = GUI.GetByGuid(GUI.GetData(typeBtn, "subtypeListScroll"..tp))
        local selectMark = GUI.GetChild(typeBtn, "selectMark")
        GUI.ButtonSetImageID(typeBtn, "1800002030")
        GUI.SetVisible(subScroll, false)
        GUI.SetPositionX(selectMark, 30)
        GUI.SetPositionY(selectMark, 0)
        GUI.SetEulerAngles(selectMark, Vector3.New(0, 0, 0))
    end

    local typeBtn = GUI.GetByGuid(guid)
    local tp = GUI.GetData(typeBtn, "type")
    --test(inspect(achievement_cfg[tonumber(tp)]))
    Now_Main_Type = tp
    local isClick = 0
    if typeBtn then
        isClick = tonumber(GUI.GetData(typeBtn, "isClick"))
        --if not isClick then
        --    isClick = 0
        --end
        --CDebug.LogError("BeStrongUI.OnMainTypeBtnClick111111...."..tostring(isClick))
    elseif currMainTypeBtn then
        isClick = tonumber(GUI.GetData(allMainTypeBtn, "isClick"))
        --CDebug.LogError("BeStrongUI.OnMainTypeBtnClick222222...."..tostring(isClick))
    else
        isClick = 0
        --CDebug.LogError("BeStrongUI.OnMainTypeBtnClick333333...."..tostring(isClick))
    end

    Now_Child_Type = 0
    local selectMark = GUI.GetChild(typeBtn, "selectMark")
    local Visible = GUI.GetVisible(selectMark)
    if Visible == false then
        GUI.ButtonSetImageID(typeBtn, "1800002031")
    end
    if GUI.GetGuid(currMainTypeBtn) ~= guid then
        isClick = 0
    end

    if isClick == 0 then
        local tp = GUI.GetData(typeBtn, "type")
        local subScroll = GUI.GetByGuid(GUI.GetData(typeBtn, "subtypeListScroll"..tp))

        GUI.ButtonSetImageID(typeBtn, "1800002031")
        GUI.SetVisible(subScroll, true)
        GUI.SetPositionX(selectMark, 38)
        GUI.SetPositionY(selectMark, 15)
        GUI.SetEulerAngles(selectMark, Vector3.New(0, 0, -90))
    end
    --print("isClick..."..isClick)
    GUI.SetData(typeBtn, "isClick", 1 - isClick)
    currMainTypeBtn = typeBtn

    BeStrongUI.RefreshAchievementLeftData()
    BeStrongUI.RefreshAchievementRightData(tp)
    BeStrongUI.OnCheckBoxClick()
end

-- 成就页左侧子标签按钮点击事件
function BeStrongUI.OnSubTypeBtnClick(guid)
--[[    local check = _gt.GetUI("check")
    GUI.CheckBoxExSetCheck(check,false)
    FINISHED_TYPE = false]]
    guid = tostring(guid)
    if not currMainTypeBtn then return end

    local tp = tonumber(GUI.GetData(currMainTypeBtn, "type"))
    local list = achievement_cfg[tp].List
    for k, v in pairs(list) do
        local subtypeBtn = _gt.GetUI("subtypeBtn"..k)
        GUI.ButtonSetImageID(subtypeBtn, "1801302060")
    end

    if currSubTypeBtn then
        GUI.ButtonSetImageID(currSubTypeBtn, "1801302060")
    end

    local subtypeBtn = GUI.GetByGuid(guid)
    GUI.ButtonSetImageID(subtypeBtn, "1801302061")
    currSubTypeBtn = subtypeBtn

    local subtype = tonumber(GUI.GetData(subtypeBtn, "subtype"))
    Now_Child_Type = subtype
    local rightLoopScroll = _gt.GetUI("achRightLoopScroll")
    GUI.LoopScrollRectSetTotalCount(rightLoopScroll, list[subtype].Count)
    GUI.LoopScrollRectRefreshCells(rightLoopScroll)
    BeStrongUI.OnCheckBoxClick()
end

-- 成就页右侧加号按钮点击事件
function BeStrongUI.OnPlusBtnClick()
    local Num = 0
    for i = 1,#achievement_cfg[0].List[0].SubList do
        if achievement_cfg[0].List[0].SubList[i].ButtonState == 1 then
            CL.SendNotify(NOTIFY.SubmitForm,"FormBeStrong","GetReward",achievement_cfg[0].List[0].SubList[i].Id)
            Num = Num + 1
        end
    end
    if Num == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg,"当前没有可领取的成就点")
    end
--[[    local btn = _gt.GetUI("plusBtn")
    GUI.SetRedPointVisable(btn,false)]]
end

-- 成就页右侧显示已达成复选框点击事件
function BeStrongUI.OnCheckBoxClick()
    local check = _gt.GetUI("check")
    local flag = GUI.CheckBoxExGetCheck(check)
    local Finish_Count = 0
    FINISHED_LIST = { [tonumber(Now_Main_Type)] = { Count = 1, TypeName = 1, List = { [Now_Child_Type] = { Count = 0, SubList = {} } }, SubType = 0 ,Finish = 0,Total = 0} }
    --print("Child"..Now_Child_Type)
    --print("Main"..Now_Main_Type)
    if flag == false then
        FINISHED_TYPE = false
        if Now_Child_Type == 0 then
            --test("子类的type...."..Now_Child_Type)
            Finish_Count = achievement_cfg[tonumber(Now_Main_Type)].Total
        else
            --test("子类的type...."..Now_Child_Type)
            Finish_Count = achievement_cfg[tonumber(Now_Main_Type)].List[tonumber(Now_Child_Type)].Count
        end
    elseif flag == true then
        FINISHED_TYPE = true
        for i = 1,#achievement_cfg[tonumber(Now_Main_Type)].List[tonumber(Now_Child_Type)].SubList do
            if achievement_cfg[tonumber(Now_Main_Type)].List[tonumber(Now_Child_Type)].SubList[i].ButtonState == 2 then
                table.insert(FINISHED_LIST[tonumber(Now_Main_Type)].List[Now_Child_Type].SubList,1,achievement_cfg[tonumber(Now_Main_Type)].List[tonumber(Now_Child_Type)].SubList[i])
                Finish_Count = Finish_Count + 1
            end
        end
    end
    --CDebug.LogError(#FINISHED_LIST[tonumber(Now_Main_Type)].List[tonumber(Now_Child_Type)].SubList)
    if #FINISHED_LIST[tonumber(Now_Main_Type)].List[Now_Child_Type].SubList == 0 and flag == true then
        local rolePic = _gt.GetUI("rolePic")
        GUI.SetVisible(rolePic,true)
    else
        local rolePic = _gt.GetUI("rolePic")
        GUI.SetVisible(rolePic,false)
    end
    local rightLoopScroll = _gt.GetUI("achRightLoopScroll")
    GUI.LoopScrollRectSetTotalCount(rightLoopScroll,Finish_Count)
    GUI.LoopScrollRectRefreshCells(rightLoopScroll)
end

-- 成就页右侧前往/领取按钮点击事件
function BeStrongUI.OnAchGotoBtnClick(guid)
    --print("点击前往/领取")
    local type = tonumber(GUI.GetData(currMainTypeBtn,"type"))
    local subtype = tonumber(GUI.GetData(currSubTypeBtn,"subtype"))
    test("subtype",subtype)
    test("type",type)
    if type == 0 or type == 1 or type == 5 or type == 7 then
        subtype = 0
    end
    local Btn = GUI.GetByGuid(guid)
    local Achievement_Id = tonumber(GUI.GetData(Btn,"Achievement_Id"))
    local Achievement_FunctionCoef = GUI.GetData(Btn,"Achievement_FunctionCoef")


    local Achievement_FunType = tonumber(GUI.GetData(Btn,"Achievement_FunType"))
    test("Achievement_FunType",Achievement_FunType)

--[[    print("Achievement_FunctionCoef......."..Achievement_FunctionCoef)
    print("Achievement_FunType......."..Achievement_FunType)
    if Achievement_Id ~= nil then
        print("Achievement_Id......."..Achievement_Id)
    else
        print("Achievement_Id.......nil")
    end]]
    test("achievement_cfg",inspect(achievement_cfg))
    test("subtype",subtype)
    if Achievement_Id ~= nil then
        for i = 1 , #achievement_cfg[type].List[subtype].SubList do
            if Achievement_Id == achievement_cfg[type].List[subtype].SubList[i].Id then
                CL.SendNotify(NOTIFY.SubmitForm,"FormBeStrong","GetReward",Achievement_Id)
                --CDebug.LogError("if True")
                break
            elseif achievement_cfg[type].List[subtype].SubList[i].ButtonState ~= 1 then
            --CDebug.LogError("if False")
                if Achievement_FunType==1 then
                    local strs = string.split(Achievement_FunctionCoef, ",")
                    local count = #strs
                    local targetUI = ""
                    local targetUIIndex1 = "0"
                    local targetUIIndex2 = "0"
                    if count >= 1 then
                        targetUI = strs[1]
                    end
                    if count >= 2 then
                        targetUIIndex1 = strs[2]
                    end
                    if count >= 3 then
                        targetUIIndex2 = strs[3]
                    end
                    if targetUI == "FactionUI" then
                        local FactionData = LD.GetGuildData()
                        if FactionData.guild == nil or tostring(FactionData.guild.guid) == "0" then
                            targetUI = "FactionCreateUI"
                        end
                    end
                    if targetUI == "PetUI" then
                        GetWay.Def[7].jump(targetUI, targetUIIndex1, targetUIIndex2)
                        return
                    end
                    if targetUI == "EquipUI" and targetUIIndex1 == "2" then
                        targetUIIndex2 = "2"
                    end
                    GetWay.Def[1].jump(targetUI, targetUIIndex1, targetUIIndex2)
                    --前往NPC
                elseif Achievement_FunType == 2 then
                    GetWay.Def[2].jump(Achievement_FunctionCoef)
                    BeStrongUI.OnExit()
                    --前往到地图点
                elseif Achievement_FunType == 3 then
                    GetWay.Def[3].jump(Achievement_FunctionCoef)
                    BeStrongUI.OnExit()
                end
            end
        end
    elseif Achievement_FunctionCoef ~= "" and Achievement_FunType ~= "" then

        if Achievement_FunType==1 then
                local strs = string.split(Achievement_FunctionCoef, ",")
                local count = #strs
                local targetUI = ""
                local targetUIIndex1 = "0"
                local targetUIIndex2 = "0"
                if count >= 1 then
                    targetUI = strs[1]
                end
                if count >= 2 then
                    targetUIIndex1 = strs[2]
                end
                if count >= 3 then
                    targetUIIndex2 = strs[3]
                end
                if targetUI == "FactionUI" then
                    local FactionData = LD.GetGuildData()
                    if FactionData.guild == nil or tostring(FactionData.guild.guid) == "0" then
                        targetUI = "FactionCreateUI"
                    end
                end
            if targetUI == "PetUI" then
                GetWay.Def[7].jump(targetUI, targetUIIndex1, targetUIIndex2)
                return
            end
            if targetUI == "EquipUI" and targetUIIndex1 == "2" then
                targetUIIndex2 = "2"
            end
                GetWay.Def[1].jump(targetUI, targetUIIndex1, targetUIIndex2)
            --前往NPC
        elseif Achievement_FunType == 2 then
            GetWay.Def[2].jump(Achievement_FunctionCoef)
            BeStrongUI.OnExit()
            --前往到地图点
        elseif Achievement_FunType == 3 then
            GetWay.Def[3].jump(Achievement_FunctionCoef)
            BeStrongUI.OnExit()
        end
    end
end

---------------------------------------
-- 获取人物评分
function BeStrongUI.GetRoleScore()
    return int64.longtonum2(CL.GetAttr(RoleAttr.RoleAttrFightValue))
end

-- 获取前五宠物战力
function BeStrongUI.GetPetScore()
    local sorted = {}
    local pets = LD.GetPetGuids()
    local Score = 0
    for i = 1, pets.Count do
        --sorted[i] = int64.longtonum2(LD.GetPetIntAttr(RoleAttr.RoleAttrFightValue, pets[i - 1]))
        --CDebug.LogError(LD.GetPetIntAttr(RoleAttr.RoleAttrLevel))
        if LD.GetPetState(PetState.Lineup,pets[i - 1]) then
            Score = Score + int64.longtonum2(LD.GetPetIntAttr(RoleAttr.RoleAttrFightValue, pets[i - 1]))
        end
    end

    --table.sort(sorted, function(a, b) return a > b end)

    --local score = 0
    --for i = 1, #sorted do
    --    if i > 5 then break end
--
    --    score = score + sorted[i]
    --end

    return Score
end

-- 获取出战侍从战力
function BeStrongUI.GetGuardScore()
    local sorted = {}
    local guards = LD.GetActivedGuard()
    local score = 0
    for i = 1, guards.Count do
        sorted[i] = int64.longtonum2(LD.GetGuardAttr(guards[i - 1], RoleAttr.RoleAttrFightValue))
        local id = tonumber(tostring(LD.GetGuardAttr(guards[i - 1], RoleAttr.RoleAttrRole)))
        if tostring(LD.GetGuardAttr(id, RoleAttr.GuardAttrIsLinup)) == "1" then
            score = score + int64.longtonum2(LD.GetGuardAttr(guards[i - 1], RoleAttr.RoleAttrFightValue))
        end
    end

    --table.sort(sorted, function(a, b) return a > b end)
    --
    --local score = 0
    --for i = 1, #sorted do
    --    if i > 4 then break end
    --
    --    score = score + sorted[i]
    --end

    return score
end

-- 获取人物装备评分
function BeStrongUI.GetEquipScore()
    local equip_score = 0
    

    return equip_score
end

-- 获取人物技能评分
function BeStrongUI.GetSkillScore()
    -- 门派技能
    local skill_score = 0
    local role_skill_list = LD.GetSelfSkillList()

    for i = 0, role_skill_list.Count - 1 do
        local skill_id = role_skill_list[i].id
        if skill_id then
            local skill_db = DB.GetOnceSkillByKey1(skill_id)
            if skill_db then
                skill_score = skill_score + tonumber(skill_db.SkillFight)
            end
        end
    end
    return skill_score
end

-- 获取人物羽翼评分
function BeStrongUI.GetWingScore()
    local wing_score = 0

    return wing_score
end

-- 获取评分等级
function BeStrongUI.GetScoreLevel(percent)
    if percent >= 0.8 then
        return 1
    elseif percent >= 0.5 then
        return 2
    elseif percent >= 0.4 then
        return 3
    elseif percent >= 0.2 then
        return 4
    else
        return 5
    end
end

-- 提升页左上Tip按钮点击事件
function BeStrongUI.OnTipHintBtnClick()
    -- 角色战力
    local role_score = BeStrongUI.GetRoleScore()
    -- 宠物战力
    local pet_score = BeStrongUI.GetPetScore()
    -- 出战侍从战力
    local guard_score = BeStrongUI.GetGuardScore()
    -- 总战力
    local total = role_score + pet_score + guard_score
    --local total = int64.longtonum2(CL.GetAttr(RoleAttr.IntToEnum(314)))

    local txt = "总战力=角色战力+宠物战力+侍从战力\n总战力: "
    txt = txt .. "<color=#ddd221>" .. total .. "</color>" .. "\n角色战力: "
    txt = txt .. "<color=#ddd221>" .. role_score .. "</color>" .. "\n宠物战力: "
    txt = txt .. "<color=#ddd221>" .. pet_score .. "</color>" .. " (出战的宠物的战斗力总和)" .. "\n侍从战力: "
    txt = txt .. "<color=#ddd221>" .. guard_score .. "</color>" .. " (战力最高的4个侍从的总和)"

    local hintBg = Tips.CreateHint(txt, _gt.GetUI("panelBg"), 62, 105, UILayout.TopLeft, 500, 130)
    local hintText = GUI.GetChild(hintBg, "hintText", false)
    GUI.StaticSetAlignment(hintText, TextAnchor.UpperLeft)
end

-------------------创建侧边标签页函数--------------------
-- 创建左侧模型
function BeStrongUI.CreateRoleModel(parent)
    local animroot = _gt.GetUI("2D")
    if not animroot then
        animroot = GUI.RawImageCreate(parent, true, "2D", nil, 35, 0, 3, false, 600, 600)
        GUI.SetDepth(animroot, 0)
        GUI.SetIsRaycastTarget(animroot, false)
        UILayout.SetSameAnchorAndPivot(animroot, UILayout.Center)
        _gt.BindName(animroot, "2D")
    end

    local templateID = CL.GetRoleTemplateID()
    if not templateID or templateID == 0 then return end

    local resKey = roleSpriteInfo[templateID][2]
    if resKey then
        local name = "roleModel"
        local anim = GUI.GetChild(animroot, name)
        if anim == nil then
            anim = GUI.RawImageChildCreate(animroot, false, name, resKey, 0, 0)
            _gt.BindName(anim, name)
            GUI.AddToCamera(animroot)
        end
        GUI.RawImageSetCameraConfig(animroot, roleSpriteInfo[templateID][3])
        GUI.BindPrefabWithChild(animroot, _gt.GetGuid(name))
    end
end

-- 创建提升页左侧UI
function BeStrongUI.CreateLeftPromotionTogglePage(parent)
    -- 创建tips按钮
    local tipHintBtn = GUI.ButtonCreate(parent, "tipHintBtn", "1800702030", 65, 65, Transition.ColorTint, "")
    GUI.RegisterUIEvent(tipHintBtn, UCE.PointerClick, "BeStrongUI", "OnTipHintBtnClick")
    UILayout.SetSameAnchorAndPivot(tipHintBtn, UILayout.TopLeft)

    -- 创建战力和推荐战力显示UI
    local totalFightingForceBg= GUI.ImageCreate(parent, "totalFightingForceBg", "1801401240", 106, 65, false, 240, 40)
    UILayout.SetSameAnchorAndPivot(totalFightingForceBg, UILayout.TopLeft)
    local totalFightingForceImg = GUI.ImageCreate(totalFightingForceBg, "totalFightingForceImg", "1801405330", 25, -1)
    UILayout.SetSameAnchorAndPivot(totalFightingForceImg, UILayout.Left)
    local recommendFightingForceBg = GUI.ImageCreate(parent, "recommendFightingForceBg", "1801401240", -8, 65, false, 240, 40)
    UILayout.SetSameAnchorAndPivot(recommendFightingForceBg, UILayout.TopRight)
    local recommendFightingForceImg = GUI.ImageCreate(recommendFightingForceBg, "recommendFightingForceImg", "1801405340", -20, -1)
    UILayout.SetSameAnchorAndPivot(recommendFightingForceImg, UILayout.Left)

    local fvTotalGroup = GUI.GroupCreate(totalFightingForceBg, "fvTotalGroup", 90, -11)
    UILayout.SetSameAnchorAndPivot(fvTotalGroup, UILayout.Left)
    local fvRecommendGroup = GUI.GroupCreate(recommendFightingForceBg, "fvRecommendGroup", -116, -11)
    UILayout.SetSameAnchorAndPivot(fvRecommendGroup, UILayout.Left)
    for i = 1, max_digit_num do
        local fv1 = GUI.ImageCreate(fvTotalGroup, "fv"..i, "1900505150", 15 + (i - 1) * 15, 0)
        UILayout.SetSameAnchorAndPivot(fv1, UILayout.TopLeft)
        local fv2 = GUI.ImageCreate(fvRecommendGroup, "fv"..i, "1900505150", 15 + (i - 1) * 15, 0)
        UILayout.SetSameAnchorAndPivot(fv2, UILayout.TopRight)
        GUI.SetVisible(fv1, false)
        GUI.SetVisible(fv2, false)
    end

    -- 创建评分UI
    local scoreImg = GUI.ImageCreate(parent, "scoreImg", "1801405220", 130, 160, false, 60, 33)
    UILayout.SetSameAnchorAndPivot(scoreImg, UILayout.Center)
    local gradeImg = GUI.ImageCreate(parent, "gradeImg", "1801407130", 210, 140)
    UILayout.SetSameAnchorAndPivot(gradeImg, UILayout.Center)

    -- 创建底部角色信息UI
    local roleInfoBg = GUI.ImageCreate(parent, "roleInfoBg", "1801300170", 0, -70)
    UILayout.SetSameAnchorAndPivot(roleInfoBg, UILayout.Bottom)
    local sectIcon = GUI.ImageCreate(roleInfoBg, "sectIcon", "1800903010", 60, -1)
    UILayout.SetSameAnchorAndPivot(sectIcon, UILayout.Left)
    local roleLevelTxt = GUI.CreateStatic(roleInfoBg, "roleLevelTxt", "120 级", -35, -2, 70, GUI.GetHeight(roleInfoBg), "system", true)
    UILayout.SetSameAnchorAndPivot(roleLevelTxt, UILayout.Center)
    GUI.StaticSetFontSize(roleLevelTxt, UIDefine.FontSizeS)
    GUI.SetIsOutLine(roleLevelTxt, true)
    GUI.SetOutLine_Color(roleLevelTxt, Color.New(83 / 255, 50 / 255, 21 / 255, 255 / 255))
    GUI.SetOutLine_Distance(roleLevelTxt, 1)
    local roleNameTxt = GUI.CreateStatic(roleInfoBg, "roleNameTxt", "司空善若", 70, -2, 140, GUI.GetHeight(roleInfoBg), "system", true)
    UILayout.SetSameAnchorAndPivot(roleNameTxt, UILayout.Center)
    GUI.StaticSetFontSize(roleNameTxt, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(roleNameTxt, TextAnchor.MiddleLeft)
    GUI.SetColor(roleNameTxt, UIDefine.Brown4Color)

    -- 创建模型
    BeStrongUI.CreateRoleModel(parent)

    _gt.BindName(fvTotalGroup, "fvTotalGroup")
    _gt.BindName(fvRecommendGroup, "fvRecommendGroup")
    _gt.BindName(gradeImg, "gradeImg")
    _gt.BindName(sectIcon, "sectIcon")
    _gt.BindName(roleLevelTxt, "roleLevelTxt")
    _gt.BindName(roleNameTxt, "roleNameTxt")

end

-- 创建提升页右侧UI
function BeStrongUI.CreateRightPromotionTogglePage(parent)
    -- 创建右半部分背景UI
    local rightPanelBg = GUI.ImageCreate(parent, "rightPanelBg", "1800400200", 38, 8, false, 525, 540)
    UILayout.SetSameAnchorAndPivot(rightPanelBg, UILayout.Center)

    local rightLoopScroll = GUI.LoopScrollRectCreate(rightPanelBg, "rightLoopScroll",
            0, 0, 510, 520,
            "BeStrongUI", "CreatePromotionRightLoopScroll",
            "BeStrongUI", "RefreshPromotionRightLoopScroll",
            0, false, Vector2.New(510, 96), 1, UIAroundPivot.Top, UIAnchor.Top)

    _gt.BindName(rightLoopScroll, "rightLoopScroll")
    UILayout.SetSameAnchorAndPivot(rightLoopScroll, UILayout.Center)
    GUI.ScrollRectSetChildSpacing(rightLoopScroll, Vector2.New(0, 10));

end

-- 创建提升页UI
function BeStrongUI.CreatePromotionTogglePage()
    local panelBg = _gt.GetUI("panelBg")
    local togglePage = GUI.GroupCreate(panelBg, labelList[pageNum.Promotion][4], 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
    _gt.BindName(togglePage, labelList[pageNum.Promotion][4])

    -- 创建左右GroupUI节点作为各自父节点
    local leftPage = GUI.GroupCreate(togglePage, "leftPage", 0, 0, GUI.GetWidth(togglePage) / 2, GUI.GetHeight(togglePage))
    UILayout.SetSameAnchorAndPivot(leftPage, UILayout.TopLeft)
    local rightPage = GUI.GroupCreate(togglePage, "rightPage", 0, 0, GUI.GetWidth(togglePage) / 2, GUI.GetHeight(togglePage))
    UILayout.SetSameAnchorAndPivot(rightPage, UILayout.TopRight)

    -- 创建左侧UI
    BeStrongUI.CreateLeftPromotionTogglePage(leftPage)
    -- 创建右侧UI
    BeStrongUI.CreateRightPromotionTogglePage(rightPage)
end

-- 创建变强页UI
function BeStrongUI.CreateStrengthenTogglePage()
    local panelBg = _gt.GetUI("panelBg")
    local togglePage = GUI.GroupCreate(panelBg, labelList[pageNum.Strengthen][4], 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
    _gt.BindName(togglePage, labelList[pageNum.Strengthen][4])

    local leftScroll  = GUI.ScrollListCreate(togglePage, "leftScroll", -432, 62, 200, 550, false, UIAroundPivot.Top,UIAnchor.Top)
    _gt.BindName(leftScroll, "leftScroll")
    GUI.ScrollRectSetAlignment(leftScroll,TextAnchor.UpperCenter)
    UILayout.SetSameAnchorAndPivot(leftScroll, UILayout.Top)

    local rightScroll = GUI.LoopScrollRectCreate(togglePage,"rightScroll", 97, 10, 830, 540,
            "BeStrongUI","CreatItemPool","BeStrongUI","RefreshItemScroll",0, false, Vector2.New(825, 120),1, UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(rightScroll, Vector2.New(0, 6))
    _gt.BindName(rightScroll, "rightScroll")

    BeStrongUI.TypeGroup = {}
    BeStrongUI.SelectType = -1
    BeStrongUI.PreSelectTypeBtn = nil
    local count = #NbTable_Id
    for i=1,count do
        if NbTable_Id[i] then
            if BeStrongUI.TypeGroup[NbTable_Id[i].Type] == nil then
                BeStrongUI.TypeGroup[NbTable_Id[i].Type] = {Name=NbTable_Id[i].Name,Ids = {i}}
            else
                table.insert(BeStrongUI.TypeGroup[NbTable_Id[i].Type].Ids, i)
            end
        end
    end
    --local leftScroll = _gt.GetUI("leftScroll")
    for k,v in pairs(BeStrongUI.TypeGroup) do
        local btn = GUI.ButtonCreate(leftScroll, "typeBtn", "1800002030", -434, -238, Transition.SpriteSwap, "<color=#805538><size=26>"..tostring(v.Name).."</size></color>", 175, 65, false)
        GUI.SetData(btn, "type", tostring(k))
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "BeStrongUI", "OnTypeBtnClick")
        _gt.BindName(btn, "btn"..k)
        GUI.AddRedPoint(btn,UIAnchor.TopLeft,10,10,"1800208080")
        GUI.SetRedPointVisable(btn,false)
        if BeStrongUI.FirstTypeBtn == nil then
            BeStrongUI.FirstTypeBtn = GUI.GetGuid(btn)
        end
        Nb_cfg.Count = Nb_cfg.Count + 1
    end
    --print(inspect(PointList))
    for k,v in pairs(PointList) do
        for i,j in pairs(v) do
            if j == true then
                local Btn = _gt.GetUI("btn"..k)
                GUI.SetRedPointVisable(Btn,true)
                break
            end
            local Btn = _gt.GetUI("btn"..k)
            GUI.SetRedPointVisable(Btn,false)
        end
    end

    GUI.SetVisible(togglePage, false)
    GlobalProcessing.get_guard_red_point_data(BeStrongUI.BianQiang_Red_Point, "BeStrongUI")
end

-- 创建成就页UI
function BeStrongUI.CreateAchievementTogglePage()
        local panelBg = _gt.GetUI("panelBg")
        local togglePage = GUI.GroupCreate(panelBg, labelList[pageNum.Achievement][4], 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
        _gt.BindName(togglePage, labelList[pageNum.Achievement][4])

        -- 创建左右GroupUI节点作为各自父节点
        local leftPage = GUI.GroupCreate(togglePage, "leftPage", 0, 0, 350, GUI.GetHeight(togglePage))
        UILayout.SetSameAnchorAndPivot(leftPage, UILayout.TopLeft)
        local rightPage = GUI.GroupCreate(togglePage, "rightPage", 0, 0, GUI.GetWidth(togglePage) - GUI.GetWidth(leftPage), GUI.GetHeight(togglePage))
        UILayout.SetSameAnchorAndPivot(rightPage, UILayout.TopRight)
        _gt.BindName(rightPage,"Achievement_rightPage")

        -- 创建左侧UI
        BeStrongUI.CreateLeftAchievementTogglePage(leftPage)
        -- 创建右侧UI
        BeStrongUI.CreateRightAchievementTogglePage(rightPage)

        GUI.SetVisible(togglePage, false)
end

-- 创建成就页左侧UI
function BeStrongUI.CreateLeftAchievementTogglePage(parent)
    -- 创建背景
    local typeListBg = GUI.ImageCreate(parent, "typeListBg", "1800400200", 70, 10, false, 250, 560)
    UILayout.SetSameAnchorAndPivot(typeListBg, UILayout.Left)

    local typeLeftScroll = GUI.ScrollListCreate(typeListBg, "typeLeftScroll", 5, 8, 240, 550, false, UIAroundPivot.Top, UIAnchor.Top)
    UILayout.SetSameAnchorAndPivot(typeLeftScroll, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(typeLeftScroll,TextAnchor.UpperCenter)
    GUI.SetPaddingVertical(typeLeftScroll, Vector2.New(5, 0))

    _gt.BindName(typeLeftScroll, "typeLeftScroll")

    local job = int64.longtonum2(CL.GetAttr(RoleAttr.RoleAttrJob1))
    local total = 0
    local cfg = BeStrongUI.GrowupTable_Id
    for k, v in ipairs(cfg) do
        local type = v.Type
        if job == v.Job or v.Job == 0 then
            Achievement_Max_Point = Achievement_Max_Point + v.AchPoints
            if not achievement_cfg[type] then
                -- Count: 子标签的数量; TypeName: 主标签的名字; List: 存储子标签列表; SubType: 首个子标签编号
                achievement_cfg[type] = { Count = 0, TypeName = maintype_name_cfg[v.Type], List = {}, SubType = v.SubType, Total = 0 ,Finish = 0}
            end

            if not FINISHED_LIST[type] then
                FINISHED_LIST[type] = { Count = 0, TypeName = maintype_name_cfg[v.Type], List = {}, SubType = v.SubType, Total = 0 ,Finish = 0}
            end

            local t = achievement_cfg[type]
            local subtype = v.SubType
            if not t.List[subtype] then
                t.Count = t.Count + 1
                t.List[subtype] = { Count = 1, SubList = { v } }
            else
                t.List[subtype].Count = t.List[subtype].Count + 1
                table.insert(t.List[subtype].SubList, v)
            end
            table.insert(achievement_cfg[0].List[0].SubList, v)

            total = total + 1
            if v.ButtonState == 2 then
                achievement_cfg[type].Finish = achievement_cfg[type].Finish + 1
                achievement_cfg[0].Finish = achievement_cfg[0].Finish + 1
                local t = FINISHED_LIST[type]
                local subtype = v.SubType
                if not t.List[subtype] then
                    t.Count = t.Count + 1
                    t.List[subtype] = { Count = 1, SubList = { v } }
                else
                    t.List[subtype].Count = t.List[subtype].Count + 1
                    table.insert(t.List[subtype].SubList, v)
                end
                --table.insert(FINISHED_LIST[0].List[0].SubList,v)
            end
        end
    end

    for k, v in pairs(achievement_cfg) do
        local typeName = v.TypeName
        local typeBtn = GUI.ButtonCreate(typeLeftScroll, "typeBtn"..k, "1800002030", 0, 0, Transition.ColorTint, typeName, 230, 62, false)
        GUI.RegisterUIEvent(typeBtn, UCE.PointerClick, "BeStrongUI", "OnMainTypeBtnClick")
        GUI.AddRedPoint(typeBtn,UIAnchor.TopLeft,10,10,"1800208080")
        GUI.SetRedPointVisable(typeBtn,false)
        UILayout.SetSameAnchorAndPivot(typeBtn, UILayout.Center)
        GUI.ButtonSetTextFontSize(typeBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(typeBtn, UIDefine.BrownColor)
        GUI.SetPreferredHeight(typeBtn, 62)
        GUI.SetData(typeBtn, "type", k)
        GUI.SetData(typeBtn, "isClick", 0)
        local isClick = GUI.GetData(typeBtn,"isClick")
        --CDebug.LogError("BeStrongUI.CreateLeftAchievementTogglePage...."..tostring(isClick))
        _gt.BindName(typeBtn, "typeBtn"..k)
        if not currMainTypeBtn and not allMainTypeBtn then
            currMainTypeBtn = typeBtn
            allMainTypeBtn = typeBtn
            --CDebug.LogError(GUI.GetGuid(typeBtn))
        end

        local selectMark = GUI.ImageCreate(typeBtn, "selectMark", "1801208630", -30, 0)
        UILayout.SetSameAnchorAndPivot(selectMark, UILayout.Right)

        local list = v.List
        local count = v.Count or 0
        local sub = v.SubType or 0
        GUI.SetVisible(selectMark, k ~= 0 and count > 0 and sub ~= 0)

        local subtypeListScroll = GUI.ListCreate(typeLeftScroll, "subtypeListScroll"..k, 0, 0, 240, 320, false)
        GUI.SetData(typeBtn, "subtypeListScroll"..k, GUI.GetGuid(subtypeListScroll))
        UILayout.SetSameAnchorAndPivot(subtypeListScroll, UILayout.Top)
        GUI.SetVisible(subtypeListScroll, false)
        GUI.SetPaddingHorizontal(subtypeListScroll, Vector2.New(5, 0))

        local cnt = 0
        for k, v in pairs(list) do
            local subtype = k
            if subtype ~= 0 then
                local subtypeName = subtype_name_cfg[subtype]
                local subtypeBtn = GUI.ButtonCreate(subtypeListScroll, "subtypeBtn"..k, "1801302060", 0, 0, Transition.ColorTint, subtypeName, 230, 62, false)
                GUI.AddRedPoint(subtypeBtn,UIAnchor.TopLeft,10,10,"1800208080")
                GUI.SetRedPointVisable(subtypeBtn,false)
                _gt.BindName(subtypeBtn, "subtypeBtn"..k)
                GUI.SetData(subtypeBtn, "subtype", k)
                UILayout.SetSameAnchorAndPivot(subtypeBtn, UILayout.Top)
                GUI.ButtonSetTextFontSize(subtypeBtn, UIDefine.FontSizeXL)
                GUI.ButtonSetTextColor(subtypeBtn, UIDefine.BrownColor)
                GUI.RegisterUIEvent(subtypeBtn, UCE.PointerClick, "BeStrongUI", "OnSubTypeBtnClick")
            end
            cnt = cnt + v.Count
        end
        v.Total = k == 0 and total or cnt
        local txt = "<color=#66310e>" .. typeName ..
                "</color><color=#975c22><size=20>（" .. v.Finish .. "/" .. v.Total .. "）" .. "</size></color>"
        GUI.ButtonSetText(typeBtn, txt)
        end
    BeStrongUI.OpenWndRedPoint()
end

-- 创建成就页右侧UI
function BeStrongUI.CreateRightAchievementTogglePage(parent)
    local label = GUI.CreateStatic(parent, "label", "我的成就点", 0, 50, 150, 60)
    UILayout.SetSameAnchorAndPivot(label, UILayout.TopLeft)
    GUI.StaticSetFontSize(label, UIDefine.FontSizeXL)
    GUI.StaticSetAlignment(label, TextAnchor.MiddleLeft)
    GUI.SetColor(label, UIDefine.Brown4Color)

    local scrollBar = GUI.ScrollBarCreate(parent, "scrollBar", "", "1800408160", "1800608140", -325, 78, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false, false)
    UILayout.SetSameAnchorAndPivot(scrollBar, UILayout.TopLeft)
    local size = Vector2.New(360, 23)
    GUI.ScrollBarSetFillSize(scrollBar, size)
    GUI.ScrollBarSetBgSize(scrollBar, size)
    GUI.ScrollBarSetPos(scrollBar, 1/2)


    local startImg = GUI.ImageCreate(scrollBar, "startImg", "1801407100", -195, -18,false,35,35)
    UILayout.SetSameAnchorAndPivot(startImg, UILayout.TopLeft)

    local plusBtn = GUI.ButtonCreate(scrollBar, "plusBtn", "1800702020", 205, -16, Transition.ColorTint)
    _gt.BindName(plusBtn,"plusBtn")
    UILayout.SetSameAnchorAndPivot(plusBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "BeStrongUI", "OnPlusBtnClick")
    GUI.AddRedPoint(plusBtn,UIAnchor.TopLeft,5,5,"1800208080")
    if BeStrongUI.RedPointList then
        if #BeStrongUI.RedPointList > 0 then
            GUI.SetRedPointVisable(plusBtn,true)
--[[            local panelBg = _gt.GetUI("panelBg")
            local tableList = GUI.GetChild(panelBg,"tabList",false)
            local AchievementToggle = GUI.GetChild(tableList,"AchievementToggle",false)
            GUI.SetRedPointVisable(AchievementToggle,true)]]
        else
            GUI.SetRedPointVisable(plusBtn,false)
--[[            local panelBg = _gt.GetUI("panelBg")
            local tableList = GUI.GetChild(panelBg,"tabList",false)
            local AchievementToggle = GUI.GetChild(tableList,"AchievementToggle",false)
            GUI.SetRedPointVisable(AchievementToggle,false)]]
        end
    end


    local achTxt = GUI.CreateStatic(scrollBar, "achTxt", "0/194", 20, 0, 150, 60)
    UILayout.SetSameAnchorAndPivot(achTxt, UILayout.Center)
    GUI.StaticSetFontSize(achTxt, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(achTxt, TextAnchor.MiddleLeft)

    local check = GUI.CheckBoxExCreate(parent, "check", "1800607150", "1800607151", 185, 60, false)
    _gt.BindName(check,"check")
    UILayout.SetSameAnchorAndPivot(check, UILayout.TopRight)
    GUI.RegisterUIEvent(check, UCE.PointerClick, "BeStrongUI", "OnCheckBoxClick")
    local showget = GUI.CreateStatic(check, "showGet", "显示已达成", -108, 3, 101, 25)
    GUI.StaticSetFontSize(showget, UIDefine.FontSizeS)
    UILayout.SetSameAnchorAndPivot(showget, UILayout.TopRight)
    GUI.SetColor(showget, UIDefine.BrownColor)
    GUI.SetIsRaycastTarget(showget, true)

    local rightPanelBg = GUI.ImageCreate(parent, "rightPanelBg", "1800400200", 45, 25, false, 790, 520)
    UILayout.SetSameAnchorAndPivot(rightPanelBg, UILayout.Center)

    local rolePic = GUI.ImageCreate(rightPanelBg,"pic","1800608770",-200,100,false,400,350)
    _gt.BindName(rolePic,"rolePic")
    local pic = GUI.ImageCreate(rolePic,"pic","1800201210",200,-200,true,0,0)
    local txt = GUI.CreateStatic(pic,"txt","当前没有已达成的成就",-50,30,300,100)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeXXL)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.TopRight)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.SetIsRaycastTarget(txt, true)
    GUI.SetVisible(rolePic,false)



    local rightLoopScroll = GUI.LoopScrollRectCreate(rightPanelBg, "rightLoopScroll",
            0, 8, 780, 510,
            "BeStrongUI", "CreateAchievementRightLoopScroll",
            "BeStrongUI", "RefreshAchievementRightLoopScroll",
            0, false, Vector2.New(770, 95), 1, UIAroundPivot.Top, UIAnchor.Top)

    _gt.BindName(rightLoopScroll, "achRightLoopScroll")
    UILayout.SetSameAnchorAndPivot(rightLoopScroll, UILayout.Center)
    GUI.ScrollRectSetChildSpacing(rightLoopScroll, Vector2.New(0, 5))

end

------------------刷新侧边栏页UI函数--------------------
-- 刷新变强页UI
function BeStrongUI.RefreshStrengthenTogglePage(togglePage)
    togglePage = togglePage or _gt.GetUI(labelList[pageNum.Strengthen][4])
    --默认选中
    BeStrongUI.ResetLastSelectPage(pageNum.Strengthen)
    --test("在这里设置滚动")
    GUI.ScrollRectSetNormalizedPosition(_gt.GetUI("leftScroll"), Vector2.New(0, 1))
    local panelBg = _gt.GetUI("panelBg")
    local titleText = GUI.GetChild(GUI.GetChild(panelBg, "titleBg", false), "titleText", false)
    GUI.StaticSetText(titleText, labelListTitle[pageNum.Strengthen][1])

    GUI.SetVisible(togglePage, true)
end

-- 刷新提升页UI
function BeStrongUI.RefreshPromotionTogglePage(togglePage)
    --("刷新提升页")
    togglePage = togglePage or _gt.GetUI(labelList[pageNum.Promotion][4])

    BeStrongUI.ResetLastSelectPage(pageNum.Promotion)
    local panelBg = _gt.GetUI("panelBg")
    local titleText = GUI.GetChild(GUI.GetChild(panelBg, "titleBg", false), "titleText", false)
    GUI.StaticSetText(titleText, labelListTitle[pageNum.Promotion][1])

    -- 刷新左侧数据
    BeStrongUI.RefreshPromotionLeftData()
    -- 刷新右侧数据
    BeStrongUI.RefreshPromotionRightData()
    GUI.SetVisible(togglePage, true)
end

-- 刷新提升页左侧数据
function BeStrongUI.RefreshPromotionLeftData()
    local sectIcon = _gt.GetUI("sectIcon")
    local id = int64.longtonum2(CL.GetAttr(RoleAttr.RoleAttrJob1))
    local sectDB = DB.GetSchool(id)
    if sectDB then
        GUI.ImageSetImageID(sectIcon, tostring(sectDB.Icon))
    end

    local roleLevelTxt = _gt.GetUI("roleLevelTxt")
    local roleLevel = tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))
    if roleLevel then
        GUI.StaticSetText(roleLevelTxt, roleLevel.." 级")
    end

    local roleNameTxt = _gt.GetUI("roleNameTxt")
    local roleName = tostring(CL.GetRoleName())
    if roleName then
        GUI.StaticSetText(roleNameTxt, roleName)
    end

    local fvTotalGroup = _gt.GetUI("fvTotalGroup")
    local fvRecommendGroup = _gt.GetUI("fvRecommendGroup")

    -- 角色战力
    local role_score = BeStrongUI.GetRoleScore()
    -- 前五宠物战力
    local pet_score = BeStrongUI.GetPetScore()
    -- 出战侍从战力
    local guard_score = BeStrongUI.GetGuardScore()
    -- 总战力
    local total_score = role_score + pet_score + guard_score

    -- 推荐战力
    local cfg = Promotion_table_Id["Id_"..roleLevel]
    local recommend_score = cfg.CharacterScore + cfg.EquipmentScore + cfg.PetScore + cfg.SkillScore + cfg.AttendantScore + cfg.WingScore

    for i = 1, max_digit_num do
        local fv1 = GUI.GetChild(fvTotalGroup, "fv"..i, false)
        local fv2 = GUI.GetChild(fvRecommendGroup, "fv"..i, false)

        if i <= #tostring(total_score) then
            local c1 = tostring(total_score):sub(i, i)
            GUI.ImageSetImageID(fv1, "190050515"..c1)
            GUI.SetVisible(fv1, true)
        else
            GUI.SetVisible(fv1, false)
        end
        if i <= #tostring(recommend_score) then
            local c2 = tostring(recommend_score):sub(i, i)
            GUI.ImageSetImageID(fv2, "190050515"..c2)
            GUI.SetVisible(fv2, true)
        else
            GUI.SetVisible(fv2, false)
        end
    end

    -- 评分等级
    local gradeImg = _gt.GetUI("gradeImg")

    local total_percent = 0.0
    total_percent = total_score / recommend_score



    local total_score_level = BeStrongUI.GetScoreLevel(total_percent)
    GUI.ImageSetImageID(gradeImg, grade_cfg[total_score_level][1])
end

-- 刷新提升页右侧数据
function BeStrongUI.RefreshPromotionRightData()
    --print("刷新提升右侧")
    local rightLoopScroll = _gt.GetUI("rightLoopScroll")
    GUI.LoopScrollRectSetTotalCount(rightLoopScroll, #promotion_cfg)
    GUI.LoopScrollRectRefreshCells(rightLoopScroll)
end

-- 刷新成就页UI
function BeStrongUI.RefreshAchievementTogglePage(togglePage)
    togglePage = togglePage or _gt.GetUI(labelList[pageNum.Achievement][4])

    BeStrongUI.ResetLastSelectPage(pageNum.Achievement)

    local panelBg = _gt.GetUI("panelBg")
    local titleText = GUI.GetChild(GUI.GetChild(panelBg, "titleBg", false), "titleText", false)
    GUI.StaticSetText(titleText, labelListTitle[pageNum.Achievement][1])

    -- 首次打开选中全部
    local MainBtn = _gt.GetUI("typeBtn0")
    BeStrongUI.OnMainTypeBtnClick(GUI.GetGuid(MainBtn))
    GUI.SetData(allMainTypeBtn, "isClick", 0)
    local isClick = GUI.GetData(allMainTypeBtn,"isClick")
    --CDebug.LogError("BeStrongUI.RefreshAchievementTogglePage...."..tostring(isClick))
    GUI.SetVisible(togglePage, true)
end

-- 刷新成就页左侧数据
function BeStrongUI.RefreshAchievementLeftData()
    BeStrongUI.RefreshAchievementLeftLoopScroll()
end

-- 刷新成就页右侧数据
function BeStrongUI.RefreshAchievementRightData(tp)
    --CDebug.LogError("wertyt")
    tp = tonumber(tp)
    local rightPage = _gt.GetUI("Achievement_rightPage")
    local rightLoopScroll = _gt.GetUI("achRightLoopScroll")
    local scrollBar = GUI.GetChild(rightPage,"scrollBar")
    local achTxt = GUI.GetChild(scrollBar,"achTxt")
    local cfg = achievement_cfg[tp]
    GUI.ScrollBarSetPos(scrollBar,BeStrongUI.AchievementPoint/Achievement_Max_Point)
    GUI.StaticSetText(achTxt,BeStrongUI.AchievementPoint.."/"..Achievement_Max_Point)
    --CDebug.LogError(debug.traceback())
    if cfg.SubType == 0 then
        GUI.LoopScrollRectSetTotalCount(rightLoopScroll, cfg.Total)
        GUI.LoopScrollRectRefreshCells(rightLoopScroll)
    else
        local subtype = nil
        for k, v in pairs(cfg.List) do
            subtype = k
            break
        end
        BeStrongUI.OnSubTypeBtnClick(_gt.GetGuid("subtypeBtn"..subtype))
    end
end

--------------------创建和刷新GridLayout函数---------------------
-- 创建提升页面右侧GridLayout函数
function BeStrongUI.CreatePromotionRightLoopScroll()
    local rightLoopScroll = _gt.GetUI("rightLoopScroll")
    local index = tonumber(GUI.LoopScrollRectGetChildInPoolCount(rightLoopScroll)) + 1
    local entryBg = GUI.ImageCreate(rightLoopScroll, "entryBg"..index, "1801100010", 0, 0)
    _gt.BindName(entryBg,"entryBg"..index)
    UILayout.SetSameAnchorAndPivot(entryBg, UILayout.Top)

    if not next(BeStrongUI.PromotionConfig) then return entryBg end

    local iconBg = GUI.ImageCreate(entryBg, "iconBg", "1800400330", 17, 2)
    UILayout.SetSameAnchorAndPivot(iconBg, UILayout.Left)
    local iconImg = GUI.ImageCreate(iconBg, "iconImg", "1800001060", 0, 0)
    UILayout.SetSameAnchorAndPivot(iconImg, UILayout.Center)
    local iconLockImg = GUI.ImageCreate(iconBg, "iconLockImg", "1800400070", 0, 0)
    UILayout.SetSameAnchorAndPivot(iconLockImg, UILayout.Center)
    local iconLabelTxt = GUI.CreateStatic(iconBg, "iconLabelTxt", "58级", 1, 22, 60, GUI.GetHeight(entryBg) / 2)
    GUI.StaticSetFontSize(iconLabelTxt, UIDefine.FontSizeS)
    GUI.SetColor(iconLabelTxt, UIDefine.White2Color)
    GUI.StaticSetAlignment(iconLabelTxt, TextAnchor.LowerCenter)
    UILayout.SetSameAnchorAndPivot(iconLabelTxt, UILayout.Center)
    GUI.SetVisible(iconLockImg, false)
    GUI.SetVisible(iconLabelTxt, false)

    local labelNameTxt = GUI.CreateStatic(entryBg, "labelNameTxt", "装备", 105, -20, 75, 30)
    GUI.StaticSetFontSize(labelNameTxt, UIDefine.FontSizeL)
    GUI.SetColor(labelNameTxt, UIDefine.Brown3Color)
    GUI.StaticSetAlignment(labelNameTxt, TextAnchor.UpperLeft)
    UILayout.SetSameAnchorAndPivot(labelNameTxt, UILayout.Left)

    local size = Vector2.New(270, 26)
    local size2 = Vector2.New(270,23)
    local scrollBar = GUI.ScrollBarCreate(entryBg, "scrollBar", "", "1800408160", "1800608140", -15, 20, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false, false)
    UILayout.SetSameAnchorAndPivot(scrollBar, UILayout.Center)
    GUI.ScrollBarSetFillSize(scrollBar, size)
    GUI.ScrollBarSetBgSize(scrollBar, size2)
    GUI.ScrollBarSetPos(scrollBar, 1/1)

    -- 创建评分UI
    local scoreImg = GUI.ImageCreate(entryBg, "scoreImg", "1801405220", 165, -20)
    UILayout.SetSameAnchorAndPivot(scoreImg, UILayout.Center)
    local gradeImg = GUI.ImageCreate(entryBg, "gradeImg", "1801407120", 210, -20, false, 30, 30)
    UILayout.SetSameAnchorAndPivot(gradeImg, UILayout.Center)

    local gotoBtn = GUI.ButtonCreate(entryBg, "gotoBtn", "1801402080", 185, 45, Transition.ColorTint, "点击前往", 105, 40, false)
    GUI.ButtonSetTextFontSize(gotoBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(gotoBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(gotoBtn, UCE.PointerClick, "BeStrongUI", "OnPromotionGotoBtnClick")
    GUI.AddRedPoint(gotoBtn,UIAnchor.TopLeft,5,5,"1800208080")
    GUI.SetRedPointVisable(gotoBtn,false)
    return entryBg
end

-- 刷新提升页面右侧GridLayout函数
function BeStrongUI.RefreshPromotionRightLoopScroll(para)
    --print("刷新Grid")
    if not next(BeStrongUI.PromotionConfig) then return end

    para = string.split(para, "#")
    local guid = para[1]
    local index = tonumber(para[2]) + 1
    local entryBg = GUI.GetByGuid(guid)

    local roleLevel = int64.longtonum2(CL.GetAttr(RoleAttr.RoleAttrLevel))
    local cfg = Promotion_table_Id["Id_"..roleLevel]

    -- 宠物评分
    local pet_score = BeStrongUI.PetScore
    -- 侍从评分
    local guard_score = BeStrongUI.GuardScore
    -- 装备评分
    local equip_score = BeStrongUI.EquipScore or 0
    -- 技能评分
    local skill_score = BeStrongUI.SkillScore
    -- 羽翼评分
    local wing_score = BeStrongUI.WingScore or 0

    local pet_percent = 0.0
    local guard_percent = 0.0
    local equip_percent = 0.0
    local skill_percent = 0.0
    local wing_percent = 0.0

    if cfg.EquipmentScore > 0 then equip_percent = equip_score / cfg.EquipmentScore end
    if cfg.PetScore > 0 then pet_percent = pet_score / cfg.PetScore end
    if cfg.SkillScore > 0 then skill_percent = skill_score / cfg.SkillScore end
    if cfg.AttendantScore > 0 then guard_percent = guard_score / cfg.AttendantScore end
    if cfg.WingScore > 0 then wing_percent = wing_score / cfg.WingScore end
    -- 如果提升页面右侧GridLayout需要添加额外的条目则需要改动这里
    if index == promotion_cfg.Equip then
        promotion_cfg[index].Percent = equip_percent
        promotion_cfg[index].ScoreLevel = BeStrongUI.GetScoreLevel(equip_percent)
    elseif index == promotion_cfg.Pet then
        promotion_cfg[index].Percent = pet_percent
        promotion_cfg[index].ScoreLevel = BeStrongUI.GetScoreLevel(pet_percent)
    elseif index == promotion_cfg.Skill then
        promotion_cfg[index].Percent = skill_percent
        promotion_cfg[index].ScoreLevel = BeStrongUI.GetScoreLevel(skill_percent)
    elseif index == promotion_cfg.Guard then
        promotion_cfg[index].Percent = guard_percent
        promotion_cfg[index].ScoreLevel = BeStrongUI.GetScoreLevel(guard_percent)
    elseif index == promotion_cfg.Wing then
        promotion_cfg[index].Percent = wing_percent
        promotion_cfg[index].ScoreLevel = BeStrongUI.GetScoreLevel(wing_percent)
    end

    BeStrongUI.SetPromotionRightEntryData(entryBg, index, roleLevel)
end

function BeStrongUI.SetPromotionRightEntryData(entryBg, index, roleLevel)
    --print("刷新右侧")
    local iconBg = GUI.GetChild(entryBg, "iconBg", false)
    local iconImg = GUI.GetChild(iconBg, "iconImg", false)
    GUI.ImageSetImageID(iconImg, promotion_cfg[index].Icon)

    local labelNameTxt = GUI.GetChild(entryBg, "labelNameTxt", false)
    GUI.StaticSetText(labelNameTxt, promotion_cfg[index].Name)

    local iconLockImg = GUI.GetChild(iconBg, "iconLockImg", false)
    local iconLabelTxt = GUI.GetChild(iconBg, "iconLabelTxt", false)

    local scrollBar = GUI.GetChild(entryBg, "scrollBar", false)

    local gradeImg = GUI.GetChild(entryBg, "gradeImg", false)

    local gotoBtn = GUI.GetChild(entryBg, "gotoBtn", false)
    GUI.SetData(gotoBtn, "index", index)
    if TiSheng_Red then
        --print(TiSheng_Red[index])
        GUI.SetRedPointVisable(gotoBtn,TiSheng_Red[index])
    end


    local score_level = promotion_cfg[index].ScoreLevel or 0
    local percent = promotion_cfg[index].Percent or 0
    local unlockLevel = promotion_cfg[index].UnlockLevel or -1
    if roleLevel < unlockLevel or unlockLevel < 0 then
        GUI.ImageSetImageID(entryBg, "1801501040")
        GUI.SetVisible(iconImg, false)
        GUI.SetVisible(iconLockImg, true)
        GUI.SetVisible(iconLabelTxt, true)
        GUI.StaticSetText(iconLabelTxt, unlockLevel.." 级")
        GUI.ScrollBarSetPos(scrollBar, 0/1)
        GUI.ImageSetImageID(gradeImg, grade_cfg[#grade_cfg][2])
        GUI.SetData(gotoBtn, "unlockLevel", unlockLevel)
    else
        GUI.ImageSetImageID(entryBg, "1801100010")
        GUI.SetVisible(iconLockImg, false)
        GUI.SetVisible(iconLabelTxt, false)
        GUI.SetVisible(iconImg, true)
        GUI.ScrollBarSetPos(scrollBar, percent)
        GUI.ImageSetImageID(gradeImg, grade_cfg[score_level][2])
    end

end

-- 创建成就页右侧GridLayout函数
function BeStrongUI.CreateAchievementRightLoopScroll()
    local rightLoopScroll = _gt.GetUI("achRightLoopScroll")
    local index = tonumber(GUI.LoopScrollRectGetChildInPoolCount(rightLoopScroll)) + 1
    local entryBg = GUI.ImageCreate(rightLoopScroll, "entryBg"..index, "1801100010", 0, 0)
    UILayout.SetSameAnchorAndPivot(entryBg, UILayout.Top)

    --local noTxt = GUI.CreateStatic(rightLoopScroll,"noTxt","当前没有已达成的成就",600,200,0,0)
    --GUI.StaticSetFontSize(noTxt, UIDefine.FontSizeL)
    --GUI.StaticSetAlignment(noTxt, TextAnchor.MiddleCenter)
    --UILayout.SetSameAnchorAndPivot(noTxt, UILayout.Center)

    local icon = GUI.ImageCreate(entryBg, "icon", "1801109130", 25, 0, false, 60, 60)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Left)
    
    local label = GUI.CreateStatic(entryBg, "label", "战力达到500", 110, -15, 400, 30)
    GUI.StaticSetFontSize(label, UIDefine.FontSizeL)
    GUI.SetColor(label, UIDefine.Brown3Color)
    GUI.StaticSetAlignment(label, TextAnchor.UpperLeft)
    UILayout.SetSameAnchorAndPivot(label, UILayout.Left)

    local scrollBar = GUI.ScrollBarCreate(entryBg, "scrollBar", "", "1800408160", "1800608140", 250, 15, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false, false)
    UILayout.SetSameAnchorAndPivot(scrollBar, UILayout.Left)
    local size = Vector2.New(280, 23)
    GUI.ScrollBarSetFillSize(scrollBar, size)
    GUI.ScrollBarSetBgSize(scrollBar, size)
    GUI.ScrollBarSetPos(scrollBar, 150/500)

    local scrollTxt = GUI.CreateStatic(scrollBar, "scrollTxt", "150/500", 0, 0, 150, 30)
    GUI.StaticSetFontSize(scrollTxt, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(scrollTxt, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(scrollTxt, UILayout.Center)

    local itemIcon = GUI.ItemCtrlCreate(entryBg, "itemIcon", "1800400320", 115, 20, 60, 60, false)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1900001460")
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, 0, 60, 60)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum , "10")
    GUI.RegisterUIEvent(itemIcon,UCE.PointerClick,"BeStrongUI","OnItemIconClick")
    local RightBottomNum = GUI.GetChild(itemIcon, "RightBottomNum", false)
    GUI.StaticSetFontSize(RightBottomNum, UIDefine.FontSizeSSS)

    local achStart = GUI.ItemCtrlCreate(entryBg, "achStart", "1800400120", 185, 20, 60, 60, false)
    GUI.ItemCtrlSetElementValue(achStart, eItemIconElement.Icon, "1801407100")
    GUI.ItemCtrlSetElementRect(achStart, eItemIconElement.Icon, 0, 0, 60, 60)
    GUI.ItemCtrlSetElementValue(achStart, eItemIconElement.RightBottomNum , "10")
    GUI.RegisterUIEvent(achStart,UCE.PointerClick,"BeStrongUI","OnachStartClick")
    local RightBottomNum = GUI.GetChild(achStart, "RightBottomNum", false)
    GUI.StaticSetFontSize(RightBottomNum, UIDefine.FontSizeSSS)

    local clickBtn = GUI.ButtonCreate(entryBg, "gotoBtn", "1800402110", -20, 0, Transition.ColorTint, "前往", 122, 46, false)
    UILayout.SetSameAnchorAndPivot(clickBtn, UILayout.Right)
    GUI.ButtonSetTextFontSize(clickBtn, 24)
    GUI.ButtonSetTextColor(clickBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(clickBtn, UCE.PointerClick, "BeStrongUI", "OnAchGotoBtnClick")
    GUI.SetVisible(clickBtn, false)

    GUI.AddRedPoint(clickBtn, UIAnchor.TopLeft)
    local redPoint = GUI.GetChild(clickBtn, "redPoint", false)
    GUI.SetPositionX(redPoint, 5)
    GUI.SetPositionY(redPoint, 5)
    GUI.SetVisible(redPoint,false)

    local finishImg = GUI.ImageCreate(entryBg, "finishImg", "1800404060", -20, 0)
    UILayout.SetSameAnchorAndPivot(finishImg, UILayout.Right)
    GUI.SetVisible(finishImg,false)

    return entryBg
end

-- 刷新成就页右侧GridLayout函数
function BeStrongUI.RefreshAchievementRightLoopScroll(para)
    --if not currSubTypeBtn then return end

    para = string.split(para, "#")
    local guid = para[1]
    local index = tonumber(para[2]) + 1
    local entryBg = GUI.GetByGuid(guid)

    local icon = GUI.GetChild(entryBg, "icon", false)
    local label = GUI.GetChild(entryBg, "label", false)
    local scrollBar = GUI.GetChild(entryBg, "scrollBar", false)
    local scrollTxt = GUI.GetChild(scrollBar, "scrollTxt", false)
    local itemIcon = GUI.GetChild(entryBg, "itemIcon", false)
    local achStart = GUI.GetChild(entryBg, "achStart", false)
    local gotoBtn = GUI.GetChild(entryBg, "gotoBtn", false)
    local redPoint = GUI.GetChild(gotoBtn,"redPoint")
    local finishImg = GUI.GetChild(entryBg, "finishImg", false)
    --按钮绑定数据刷新

    local tp = tonumber(GUI.GetData(currMainTypeBtn, "type"))
    local cfg = {}
    if FINISHED_TYPE == false then
        cfg = achievement_cfg[tp]
    else
        cfg = FINISHED_LIST[tp]
    end
    --CDebug.LogError("cfg......"..inspect(cfg))



    local subtype = -1
    local subList = nil -- 对于需要的排序只需将排好序的表赋值给该表
    if cfg.SubType ~= 0 then
        subtype = tonumber(GUI.GetData(currSubTypeBtn, "subtype"))
        subList = cfg.List[subtype].SubList
    else
        subtype = tonumber(Now_Child_Type)
        subList = cfg.List[subtype].SubList
    end

    if subtype == -1 or not subList then
        return
    end


    if subList[index].Icon and subList[index].Icon ~= 0 then
        GUI.ImageSetImageID(icon, subList[index].Icon)
    end

    if subList[index].Info then
        GUI.StaticSetText(label, subList[index].Info)
    end
    --test(inspect(cfg))

    if subList[index].AchPoints and subList[index].ItemId and subList[index].ItemCount then
        GUI.SetVisible(achStart,true)
        GUI.ItemCtrlSetElementValue(achStart, eItemIconElement.RightBottomNum, subList[index].AchPoints)
        if subList[index].AchPoints == 0 and subList[index].ItemCount ~= 0 then
            local item = DB.GetOnceItemByKey1(subList[index].ItemId)
            GUI.ItemCtrlSetElementValue(achStart,eItemIconElement.Icon,item.Icon)
            GUI.ItemCtrlSetElementValue(achStart,eItemIconElement.RightBottomNum ,subList[index].ItemCount)
            GUI.ItemCtrlSetElementValue(achStart,eItemIconElement.Border,UIDefine.ItemIconBg[item.Grade])
            GUI.SetData(achStart,"ItemOrPoint",item.Id)
        elseif subList[index].AchPoints ~= 0 then
            GUI.ItemCtrlSetElementValue(achStart,eItemIconElement.Icon,1801407100)
            GUI.ItemCtrlSetElementValue(achStart,eItemIconElement.Border,1800400120)
            GUI.SetData(achStart,"ItemOrPoint",20351)
        elseif subList[index].ItemCount == 0 then
            GUI.SetVisible(achStart,false)
        end
    end

    if subList[index].attr and subList[index].attr ~= 0 then
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, iconIdCfg[subList[index].attr])
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, subList[index].BindIngot)
    else
        GUI.SetVisible(itemIcon, false)
    end

    if subList[index].Now_Extent and subList[index].Max_Extent then
        GUI.ScrollBarSetPos(scrollBar,tonumber(subList[index].Now_Extent)/tonumber(subList[index].Max_Extent))
        GUI.StaticSetText(scrollTxt,tostring(subList[index].Now_Extent).."/"..tostring(subList[index].Max_Extent))
    end
    local Achievement_Id = subList[index].Id
    GUI.SetVisible(finishImg,false)
    GUI.SetVisible(gotoBtn,false)
    if subList[index].ButtonState == 0 and subList[index].FunType ~= 0 then
        GUI.DelData(gotoBtn,"Achievement_Id")
        GUI.SetVisible(gotoBtn,true)
        GUI.ButtonSetText(gotoBtn, "前往")
        GUI.SetVisible(redPoint,false)
        GUI.SetData(gotoBtn,"Achievement_FunctionCoef",subList[index].FunctionCoef)
        GUI.SetData(gotoBtn,"Achievement_FunType",subList[index].FunType)
    elseif subList[index].ButtonState == 1 then
        GUI.DelData(gotoBtn,"Achievement_Id")
        GUI.SetVisible(gotoBtn,true)
        GUI.ButtonSetText(gotoBtn, "可领取")
        GUI.SetVisible(redPoint,true)
        GUI.SetData(gotoBtn,"Achievement_Id",Achievement_Id)
        GUI.SetData(gotoBtn,"Achievement_FunType",subList[index].FunType)
    elseif subList[index].ButtonState == 2 then
        GUI.SetVisible(gotoBtn, false)
        GUI.SetVisible(finishImg,true)
    end
end

-- 刷新成就页左侧GridLayout函数
function BeStrongUI.RefreshAchievementLeftLoopScroll()
    
end

function BeStrongUI.OnItemIconClick(guid)
    local togglePage = _gt.GetUI(labelList[3][4])
    Tips.CreateByItemId(20046,togglePage,"Tips",0,0)
end
function BeStrongUI.OnachStartClick(guid)
    local achStart = GUI.GetByGuid(guid)
    local id = tonumber(GUI.GetData(achStart,"ItemOrPoint"))
    local togglePage = _gt.GetUI(labelList[3][4])
    Tips.CreateByItemId(id,togglePage,"Tips",0,0)
--[[    local Tips = GUI.GetChild(togglePage,"Tips",false)
    local ItemIcon = GUI.GetChild(Tips,"ItemIcon",false)
    local Icon = GUI.GetChild(ItemIcon,"Icon",false)
    GUI.ImageSetImageID(Icon,1801407100)]]

end

function BeStrongUI.RefreshAchievementPoint_list()
    achievement_cfg[1].List[0].SubList = BeStrongUI.AchievementPoint_list
    for i = 1 ,#BeStrongUI.AchievementPoint_list do
        local Num = 0
        for k = 1, #achievement_cfg[0].List[0].SubList do
            if BeStrongUI.AchievementPoint_list[i].Id == achievement_cfg[0].List[0].SubList[k].Id and BeStrongUI.AchievementPoint_list[i].ButtonState == 1 then
                table.remove(achievement_cfg[0].List[0].SubList,k)
                table.insert(achievement_cfg[0].List[0].SubList,1,BeStrongUI.AchievementPoint_list[i])
                break
            elseif BeStrongUI.AchievementPoint_list[i].Id == achievement_cfg[0].List[0].SubList[k].Id then
                achievement_cfg[0].List[0].SubList[k] = BeStrongUI.AchievementPoint_list[i]
            end
        end
    end

end

function BeStrongUI.OpenWndRedPoint()
    local rightPage = _gt.GetUI("Achievement_rightPage")
    local scrollBar = GUI.GetChild(rightPage,"scrollBar",false)
    local plusBtn = _gt.GetUI("plusBtn")
    --GUI.SetRedPointVisable(plusBtn,false)
    if BeStrongUI.RedPointList then
        if #BeStrongUI.RedPointList > 0 then
            --print(inspect(BeStrongUI.RedPointList))
            for i = 1,#BeStrongUI.RedPointList do
                local data = string.split(BeStrongUI.RedPointList[i], ",")
                if tonumber(data[2]) ~= 0 then
                    local TypeBtn = _gt.GetUI("typeBtn"..data[1])
                    local SubTypeBtn = _gt.GetUI("subtypeBtn"..data[2])
                    GUI.SetRedPointVisable(TypeBtn,true)
                    GUI.SetRedPointVisable(SubTypeBtn,true)
                else
                    local TypeBtn = _gt.GetUI("typeBtn"..data[1])
                    GUI.SetRedPointVisable(TypeBtn,true)
                end
            end
            local TypeBtn = _gt.GetUI("typeBtn0")
            GUI.SetRedPointVisable(TypeBtn,true)
            local panelBg = _gt.GetUI("panelBg")
            local tableList = GUI.GetChild(panelBg,"tabList",false)
            local AchievementToggle = GUI.GetChild(tableList,"AchievementToggle",false)
            GUI.SetRedPointVisable(AchievementToggle,true)
            --GUI.SetRedPointVisable(plusBtn,true)
            --print("显示红点")
        end
    end
end

function BeStrongUI.BianQiang_Red_Point(data,flag)

    local ID = 0
    local Point = nil
    if tonumber(flag) == 1 then
        Point = true
    elseif tonumber(flag) == 0 then
        Point = false
    end
    if type(data) == "table" then
        --print(inspect(data))
        --侍从提升
        if data.guard_reds then
            local up_attr_level,up_star,up_skill,up_love_skill = 0,0,0,0
            for k,v in pairs(data.guard_reds) do
                if v.is_activation then
                    if v.can_up_attr_level then
                        up_attr_level = up_attr_level + 1
                    end
                    if v.can_up_star then
                        up_star = up_star + 1
                    end
                    if v.can_up_skill then
                        up_skill = up_skill + 1
                    end
                    if v.can_up_love_skill then
                        up_love_skill = up_love_skill + 1
                    end
                end
                if up_attr_level > 0 then
                    NbTable[70].RedPoint = true
                    ID = 70
                else
                    NbTable[70].RedPoint = false
                    ID = 70
                end
                if up_star > 0 then
                    NbTable[68].RedPoint = true
                    ID = 68
                else
                    NbTable[68].RedPoint = false
                    ID = 68
                end
                if up_skill > 0 then
                    NbTable[69].RedPoint = true
                    ID = 69
                else
                    NbTable[69].RedPoint = false
                    ID = 69
                end
                if up_love_skill > 0 then
                    NbTable[67].RedPoint = true
                    ID = 67
                else
                    NbTable[67].RedPoint = false
                    ID = 67
                end
            end
        end
    end
    if data == "WelfareEquip" then
        --CDebug.LogError("WelfareEquip")
        NbTable[22].RedPoint = Point
        ID = 22
    elseif data == "SevenDay" then
        NbTable[60].RedPoint = Point
        ID = 60
    elseif data == "SkillPage1" then
        NbTable[8].RedPoint = Point
        ID = 8
    elseif data == "SkillPage2" then
        NbTable[11].RedPoint = Point
        ID = 11
    elseif data == "SkillPage3" then
        NbTable[10].RedPoint = Point
        ID = 10
    elseif data == "SkillPage4" then
        NbTable[9].RedPoint = Point
        ID = 9
    elseif data == "PetAddPoint" then
        NbTable[57].RedPoint = Point
        ID = 57
    elseif data == "PetEquip" then
        NbTable[53].RedPoint = Point
        ID = 53
    elseif data == "EquipProduce" then
        NbTable[18].RedPoint = Point
        ID = 18
    elseif data == "EquipEnhance" then
        NbTable[23].RedPoint = Point
        ID = 23
    elseif data == "GemMerg" then
        NbTable[36].RedPoint = Point
        ID = 36
    elseif data == "gemInlay" then
        NbTable[24].RedPoint = Point
        ID = 24
    elseif data == "RoleRemainPoint" then
        NbTable[2].RedPoint = Point
        ID = 2
    elseif data == "level_up_Battle" then
        NbTable[73].RedPoint = Point
        ID = 73
    elseif data == "lean_Battle" then
        NbTable[72].RedPoint = Point
        ID = 72
    elseif data == "Wing" then
        NbTable[38].RedPoint = Point
        ID = 38
    end
    BeStrongUI.Refresh_BianQiang_Red_Point(ID)
end

function BeStrongUI.Refresh_BianQiang_Red_Point(ID)

    local type = NbTable[ID].Type
    if not PointList[type] then
        PointList[type] = {}
    end
    PointList[type][ID] = NbTable[ID].RedPoint
    for k,v in pairs(PointList[type]) do
        if v == true then
            local Btn = _gt.GetUI("btn"..NbTable[ID].Type)
            GUI.SetRedPointVisable(Btn,true)
            type = NbTable[ID].Type
            if type == 4 then
                TiSheng_Red[1] = true
            elseif type == 8 then
                TiSheng_Red[2] = true
            elseif type == 2  then
                TiSheng_Red[3] = true
            elseif type == 10 then
                TiSheng_Red[4] = true
            elseif type == 6 then
                TiSheng_Red[5] = true
            end
            BeStrongUI.SetRedPoint()
            return
        end
    end
    local Btn = _gt.GetUI("btn"..NbTable[ID].Type)
    GUI.SetRedPointVisable(Btn,false)
    if NbTable[ID].Type == 4 then
        TiSheng_Red[1] = false
    elseif NbTable[ID].Type == 8 then
        TiSheng_Red[2] = false
    elseif NbTable[ID].Type == 2  then
        TiSheng_Red[3] = false
    elseif NbTable[ID].Type == 10 then
        TiSheng_Red[4] = false
    elseif NbTable[ID].Type == 6 then
        TiSheng_Red[5] = false
    end
    BeStrongUI.SetRedPoint()
end

function BeStrongUI.SetRedPoint()
    local redsCount = 0
    for k,v in pairs(NbTable) do
        if v.RedPoint == true then
            redsCount = redsCount + 1
        end
    end
    --print(redsCount)
    local panelBg = _gt.GetUI("panelBg")
    local tableList = GUI.GetChild(panelBg,"tabList",false)
    local StrengthenToggle = GUI.GetChild(tableList,"StrengthenToggle",false)
    local PromotionToggle = GUI.GetChild(tableList,"PromotionToggle",false)
    if redsCount > 0 then
        GUI.SetRedPointVisable(StrengthenToggle,true)
    else
        GUI.SetRedPointVisable(StrengthenToggle,false)
    end
    BeStrongUI.OnTypeBtnClick(GUI.GetGuid(BeStrongUI.PreSelectTypeBtn))
    for i = 1,#TiSheng_Red do
        local entry = _gt.GetUI("entryBg"..i)
        local gotoBtn = GUI.GetChild(entry,"gotoBtn",false)
        if entry and gotoBtn then
            if TiSheng_Red[i] then
                GUI.SetRedPointVisable(gotoBtn,true)
            else
                GUI.SetRedPointVisable(gotoBtn,false)
            end
        end
    end
    for i = 1,#TiSheng_Red do
        if TiSheng_Red[i] then
            GUI.SetRedPointVisable(PromotionToggle,true)
            break
        else
            GUI.SetRedPointVisable(PromotionToggle,false)
        end
    end
end
----------------------------------------
function BeStrongUI.serialize(obj)
    local text = ""
    local t = type(obj)
    if t == "number" then
        text = text .. obj
    elseif t == "boolean" then
        text = text .. tostring(obj)
    elseif t == "string" then
        text = text .. string.format("%q", obj)
    elseif t == "table" then
        text = text .. "{\n"
        for k, v in pairs(obj) do
            text = text .. "[" .. BeStrongUI.serialize(k) .. "]=" .. BeStrongUI.serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                text = text .. "[" .. BeStrongUI.serialize(k) .. "]=" .. BeStrongUI.serialize(v) .. ",\n"
            end
        end

        text = text .. "}"

    elseif t == "nil" then
        return nil
    else
        test("can not serialize a " .. t .. " type.")
    end

    return text
end