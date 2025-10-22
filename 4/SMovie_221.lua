local  this_file = "SMovie_221.lua:"
-- @@runlua SMovie_221
SMovie_221 = {}


--新建脚本须知：复制本脚本后，使用Ctrl + F 进入查找模式，切换到替换页面
--将SMovie_108全部替换成目标名称
--命名规则     SMovie_  + 第几幕 + 两位数的第几幕的第几个动画
--例如第一幕进战斗前： SMovie_221    ， 第一幕战斗后动画： SMovie_102，第一幕到傲来村（因为切换场景需要新的脚本）动画： SMovie_221

--注：脚本中所有跟时间相关的内容，皆可用小数，但最多精确到小数点后3位
-----------------------全局配置-----------------------
local GlobalConfig = {
	MovieName = "SMovie_221",
	LeadingActor = {
		Frame1 = {{0.2,"npc1"}},
		Frame2 = {{0.1,"npc4"}},
		Frame4 = {{0.5,"npc1"}},		
				},

	TotalTime = 80,
	PlotEdge = {onoff = 1, start = 0, s_consume = 1, s_frame = 1},
	--剧情压边设置： onoff -是否开启   start -开启时间    s_consume -开启消耗时间    ext -移除时间   e_consume -移除消耗时间
	FrameTable = {
		Frame1 = {FrameType = "自由运动", FrameTime = 2},
		Frame2 = {FrameType = "自由运动", FrameTime = 6},
		Frame3 = {FrameType = "压边对话", FrameTalk = "TalkList1"},	
		Frame4 = {FrameType = "自由运动", FrameTime = 5},
		Frame5 = {FrameType = "压边对话", FrameTalk = "TalkList2"},	
		Frame6 = {FrameType = "自由运动", FrameTime = 2},	
		Frame7 = {FrameType = "压边对话", FrameTalk = "TalkList3"},	
	}
}


-----------------------NPC配置-----------------------
--NPC配置依次由 npc + 数字组成，不可跳数字
--[[
Basic配置为NPC基础配置，
	其中id 为npc表中的模型id，name 自行填入，空值则沿用npc表的配置，
	Occtime 和 Exttime是NPC的出现和消失时间，  posx，posy，dir 分别是 位置和转向

Action配置为NPC进阶配置
	每个配置的命名为Action + 依次的数字，不可跳数字
		ActionTime NPC刷出后多久进行行为，这个值必须大于0.1
		ActType 进行行为的类型，有3种，分别为（【说话】，【移动】 和 【动作】）
			当行为为【说话】时，ActData表格的第一个数据为 说话内容
			当行为为【移动】时，ActData表格的第一个数据为 目标点x值， 第二个数据为 目标点y值
			当行为为【动作】时，ActData表格的第一个数据为 动作编号
			当行为为【转身】时，ActData表格的第一个数据为 转向方向（0-7）
	]]

	
local NpcTable = {
	npc1 = {Basic = {id = 22075, name = "烟云客", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 5, posx = 201, posy = 129, dir = 4},
		Frame1 = {
					Action1 = { ActionTime = 1.5, ActType = "转身", ActData = {5}},
			},
		Frame6 = {
					Action1 = { ActionTime = 1, ActType = "转身", ActData = {1}},
			},	
		},
	npc2 = {Basic = {id = 22022, name = "阎魔令", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 5, posx = 156, posy = 143, dir = 5},
		},	
	npc3 = {Basic = {id = 22073, name = "小和尚", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 5, posx = 150, posy = 149, dir = 1},
		},	
	npc4 = {Basic = {id = 22073, name = "小和尚", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 5, posx = 200, posy = 128, dir = 4, hide = true},
			Frame2 = {
					Action1 = { ActionTime = 0.2, ActType = "移动", ActData = {156,143}},
				},
		},
	npc5 = {Basic = {id = 0, name = "player", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 5, posx = 207, posy = 102, dir = 4},
			Frame4 = {
					Action1 = { ActionTime = 1, ActType = "移动", ActData = {207,124}},
					Action2 = { ActionTime = 4, ActType = "转身", ActData = {5}},
			},
		},		
	}

-----------------------压边对话配置-----------------------
--主要配置讲解
--Npc 说话者         
--Content  对话内容          
--NpcAction NPC动作，括号里的配置等同于NPC表中的 ActData   填-1,-1则表示无动作   
--NpcPop NPC产生一个泡泡对话   
--NpcMove NPC同时产生移动，填-1,-1则表示不移动

local TalkTable = {
	TalkList1 = {
		TalkData1 = {Npc = "npc1", Content = "咦，这不是慈恩寺的小和尚吗？那个红毛怪物莫不是要加害他！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData2 = {Npc = "npc1", Content = "真是岂有此理，我必须要阻止他！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
	},
	TalkList2 = {
		TalkData1 = {Npc = "npc5", Content = "嘿！这不是大名鼎鼎的烟云客吗！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
	},
	TalkList3 = {
		TalkData1 = {Npc = "npc1", Content = "哎呦吓死我了！能不能不要这么神出鬼没。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData2 = {Npc = "npc1", Content = "你来的正好，你我二人上前去教训一下这个红毛怪物！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
	},
	
}
	
-----------------------特效配置-----------------------
--特效配置依次由 eft + 数字组成，不可跳数字
--[[
	id 		特效id，对应在setting-magic-magic表
	start 	特效出现时间
	ext 	特效消失时间
	posx	特效位置x，需要注意的是这里要进行16倍的乘值，后面的+或-作为这个值的微调
	posy	特效位置y，需要注意的是这里要进行16倍的乘值，后面的+或-作为这个值的微调
]]
local EffectTable = {

	}
	
	
	
	
-----------------------图片配置-----------------------
--图片配置依次由 img + 数字组成，不可跳数字
--[[
	id 			图片id，对应在资源查看器，当配置成多个数值的表格时，则进行随机
	start 		图片出现时间
	s_consume	图片出现消耗时间
	s_type		图片出现方式(0 直接出现，2 渐入出现 ，6 从上至下出现， 8 从左至右出现)
	ext 		图片消失时间
	e_consume	图片消失消耗时间
	e_type		图片消失方式(1 直接消失，3 渐出消失 ，7 从下至上消失， 9 从右至左消失)
	posx		图片位置x，需要注意的是这里要进行16倍的乘值，后面的+或-作为这个值的微调
	posy		图片位置y，需要注意的是这里要进行16倍的乘值，后面的+或-作为这个值的微调
]]
local ImageTable = {
		
	}

	
	
-----------------------文字配置-----------------------
--文字配置依次由 eft + 数字组成，不可跳数字
--[[
	str 		文字内容，当出现\n时换行
	start 		文字出现时间
	s_consume	文字出现消耗时间
	s_type		文字出现方式(0 直接出现，2 渐入出现 ，8 从左至右出现)
	ext 		文字消失时间
	e_consume	文字消失消耗时间
	e_type		文字消失方式(1 直接消失，3 渐出消失 ，9 从右至左消失)
	posx		文字位置x，需要注意的是这里要进行16倍的乘值，后面的+或-作为这个值的微调
	posy		文字位置y，需要注意的是这里要进行16倍的乘值，后面的+或-作为这个值的微调
]]
local WordTable = {
	}

	
	
	
	
	
	
	
	
	
	
	
-------------------------------------------------------------脚本内容请勿修改--------------------------------------------------------------------------	
-------------------------------------------------------------脚本版本：V_1.02--------------------------------------------------------------------------
function SMovie_221.main()
	if not SMovie_System then
		require "SMovie_System"
	end
	
	if GlobalConfig['MovieName'] then
		SMovie_System.MovieAction(GlobalConfig['MovieName'], GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable, TalkTable)
	end
end

--SMovie_221.main()