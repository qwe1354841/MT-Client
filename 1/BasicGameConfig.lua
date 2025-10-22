local BasicGameConfig = {}
_G.BasicGameConfig = BasicGameConfig

function BasicGameConfig.GetData(key)
    if key then
        return BasicGameConfig.Data[key]
    end
    return nil
end

BasicGameConfig.Data = 
{
["RoleVisibleLimit"]="300",--最大可视范围内显示角色数量
["EquipRewardLevel"]="4-100,8-101,12-102,16-103,20-104,1000-300,1001-301,1002-302",--强化等级对应特效
["GemRewardLevel"]="3-200,5-201,7-202,9-203,10-204",--宝石等级对应特效
["PKMaxColorValue"]="2000",--颜色随PK值变化：最大值
["PKMinColorValue"]="-2000",--颜色随PK值变化：最小值
}