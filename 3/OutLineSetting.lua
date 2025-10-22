OutLineSetting = {}

OutLineSetting.OUTLINE_BROWN6_1 = 1 --描边_棕色6_粗细1
OutLineSetting.OutLine_Orange2_1 = 2 --描边_橘红2_粗细1
OutLineSetting.OutLine_BlackColor_1 = 3--黑色描边
OutLineSetting.OutLine_BrownColor_1 = 4--棕色描边
OutLineSetting.OutLine_GreenColor_1 = 5--绿色描边
OutLineSetting.OutLine_RedColor_1 = 6--红色描边
OutLineSetting.OutLine_BlueColor_1 = 7--蓝色描边
OutLineSetting.OutLine_PurpleColor_1 = 8--紫色描边
OutLineSetting.OutLine_YellowColor_1 = 9--黄色描边
OutLineSetting.OutLine_NpcDialogFullTip = 10--任务对白描边字

function OutLineSetting.InitSetting()
    --local cnt = OutLineSetting.GetOutLineSettingCnt()
	--print("cnt ===>"..cnt)
	TextOutLineMgr.InitTxtTypeMatDic()
	--[[
	for i = 1,cnt do
		--print("OutLineSetting.InitSetting======"..i)
		TextOutLineMgr.AddOutLineSetting(i)
	end
	]]
	--此接口过于滥用，OUTLINE_BROWN6_1 材质用到的Text很多，所以需要共享材质。其它就一个Text一个材质
	TextOutLineMgr.AddOutLineSetting(OutLineSetting.OUTLINE_BROWN6_1)
	
end

function OutLineSetting.GetOutLineSettingCnt()
	--print("#OutLineSetting="..#OutLineSetting)
	local cnt = 0
	for k,v in pairs(OutLineSetting) do 
		if type(v) == "number" then
			--print(k.."==="..v)
			cnt = cnt + 1
		end
	end
	return cnt
end

--print("===========OutLineSetting================")
OutLineSetting.InitSetting()
