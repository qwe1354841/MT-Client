local  this_file = "SMovie_103.lua:"
-- @@runlua SMovie_103
SMovie_103 = {}


--新建脚本须知：复制本脚本后，使用Ctrl + F 进入查找模式，切换到替换页面
--将SMovie_103全部替换成目标名称
--命名规则     SMovie_  + 第几幕 + 两位数的第几幕的第几个动画
--例如第一幕进战斗前： SMovie_103    ， 第一幕战斗后动画： SMovie_102，第一幕到傲来村（因为切换场景需要新的脚本）动画： SMovie_103

--注：脚本中所有跟时间相关的内容，皆可用小数，但最多精确到小数点后3位
-----------------------全局配置-----------------------
local GlobalConfig = {
	MovieName = "SMovie_103",
	LeadingActor = {
		Frame1 = {{0.8,"npc2"}},
		Frame3 = {{0.1,"npc1"}},
		Frame5 = {{0.1,"npc6"}},
				},

	TotalTime = 90,
	PlotEdge = {onoff = 1, start = 0, s_consume = 1,s_frame = 1},
	--剧情压边设置： onoff -是否开启   start -开启时间    s_consume -开启消耗时间    ext -移除时间   e_consume -移除消耗时间
	FrameTable = {
		Frame1 = {FrameType = "自由运动", FrameTime = 3},
		Frame2 = {FrameType = "压边对话", FrameTalk = "TalkList1"},
		Frame3 = {FrameType = "自由运动", FrameTime = 2},
		Frame4 = {FrameType = "压边对话", FrameTalk = "TalkList2"},
		Frame5 = {FrameType = "自由运动", FrameTime = 13},
		Frame6 = {FrameType = "压边对话", FrameTalk = "TalkList3"},		
		Frame7 = {FrameType = "自由运动", FrameTime = 1.1},
		Frame8 = {FrameType = "压边对话", FrameTalk = "TalkList4"},				
		Frame9 = {FrameType = "自由运动", FrameTime = 1.9},	
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
			当行为为【动作】时，ActData表格的第一个数据为 动作编号， 第二个数据为动作循环模式（0--不循环，1--循环播放，2--播放至最后一帧停住）
			当行为为【转身】时，ActData表格的第一个数据为 转向方向（0-7）
	]]
	
	
	
local NpcTable = {
		npc1 = {Basic = {id = 60065, name = "渔村女童", Occtime = 0, OccFrame = 1, Exttime = 90, ExitFrame = 9, posx = 124, posy = 40, dir = 1},
		Frame3 = {
						Action1 = { ActionTime = 0.1, ActType = "移动", ActData = {120,43}},
						Action2 = { ActionTime = 1.5, ActType = "转身", ActData = {1}},	
			},
		},	
		npc2 = {Basic = {id = 30029, name = "说书人", Occtime = 0, OccFrame = 1, Exttime = 90, ExitFrame = 9, posx = 131, posy = 29, dir = 5},
		Frame1 = {
			},
		},	
		npc3 = {Basic = {id = 10004, name = "金大娘", Occtime = 0, OccFrame = 1, Exttime = 90, ExitFrame = 9, posx = 103, posy = 44, dir = 2},
		Frame3 = {
						Action1 = { ActionTime = 22, ActType = "动作", ActData = {eRoleMovement.WAVE,0}},					
			},
		},	
		npc4 = {Basic = {id = 10001, name = "铁匠大叔", Occtime = 0, OccFrame = 1, Exttime = 90, ExitFrame = 9, posx = 109, posy = 51, dir = 1},
		Frame3 = {				
			},
		},	
		npc5 = {Basic = {id = 30103, name = "渔民大婶", Occtime = 0, OccFrame = 1, Exttime = 90, ExitFrame = 9, posx = 121, posy = 53, dir = 1},
		Frame7 = {
						Action1 = { ActionTime = 0.1, ActType = "转身", ActData = {7}},
			},
		},	
		npc6 = {Basic = {id = 0, name = "player", Occtime = 0, OccFrame = 1, Exttime = 90, ExitFrame = 9, posx = 114, posy = 48, dir = 1},
		Frame5 = {
				Action1 = { ActionTime = 0.1, ActType = "移动", ActData = {108,45}},
				Action2 = { ActionTime = 1.5, ActType = "移动", ActData = {114,49}},
				Action3 = { ActionTime = 3, ActType = "转身", ActData = {3}},				
				Action4 = { ActionTime = 3.2, ActType = "动作", ActData = {eRoleMovement.DIE_W2,2}},
				Action5 = { ActionTime = 10, ActType = "动作", ActData = {eRoleMovement.STAND_W1,0}},	
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
		TalkData1 = {Npc = "npc2", Content = "想当年，五圣历经九九八十一难，终于在那西天大雷音寺我佛如来处取回了三藏真经。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData2 = {Npc = "npc1", Content = "啊呀，大叔，你讲得太兴奋了，口水都溅到我身上了。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
	},
	TalkList2 = {
		TalkData1 = {Npc = "npc2", Content = "你你你，你这娃儿，我正说到紧要关头，别打断我。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData2 = {Npc = "npc3", Content = "啊呀，别停啊，你倒是快说下去啊，急死老娘了！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData3 = {Npc = "npc2", Content = "这位大娘倒是性急，别急，别急。待我慢慢道来。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData4 = {Npc = "npc2", Content = "话说当年啊，五圣取经归来，因为经书在那晒经石上粘连，故而经文有缺。这世上之事啊，本无十全十美，就是那天道都有缺口呢。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData5 = {Npc = "npc4", Content = "是啊是啊，这五圣取来真经，虽然度化了部分恶人，教导大家行善积德。可这世界上还是有这么多的妖魔鬼怪，哪里都能度化的干净哦。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData6 = {Npc = "npc2", Content = "这位大叔说得对，所以五圣和另一位圣贤才建立了这六大门派啊。门中弟子时常出来行侠仗义，斩妖除魔，所以我们这个人间才能暂时保持安宁。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData7 = {Npc = "npc1", Content = "等我长大了，我也要加入六大门派，行侠仗义，斩妖除魔去。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData8 = {Npc = "npc6", Content = "小妹妹真勇敢，你一定行的。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
 		TalkData9 = {Npc = "npc6", Content = "哎哟，怎么突然头好痛。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {114,47}},
	},
	TalkList3 = {
		TalkData1 = {Npc = "npc6", Content = "为啥我的脑中有这些……共工……五圣师父……是这些天做的噩梦还没醒吗？哎，不管这些乱七八糟的了。还是先完成师父交代的任务吧。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
	},
	TalkList4 = {
		TalkData1 = {Npc = "npc5", Content = "唉这孩子怎么晕倒了？看衣服好像是六大门派的呢。行侠仗义也不容易啊。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {116,51}}, 
		TalkData2 = {Npc = "npc5", Content = "估计是饿得头晕了吧。来来来，到大婶家来拿个饼吃吃，热乎着呢。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData3 = {Npc = "npc6", Content = "（咕噜噜，呃！！！还真是饿了呢。）谢谢大婶，那我就不客气了啊。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},  		
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
		img1 = {id = 1801009130,start = 5.5, s_consume = 1, s_type = 2, s_frame = 5, ext = 11, e_consume = 1, e_type = 3, e_frame = 5, posx = 0,posy = 0,isfullscrean = true},
		img2 = {id = 1801004999,start = 5.5, s_consume = 3, s_type = 6, s_frame = 5, ext = 10, e_consume = 1, e_type = 3, e_frame = 5, posx = 0,posy = 0,linkpoint = "Center"},
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
function SMovie_103.main()
	if not SMovie_System then
		require("SMovie_System")
	end
	if GlobalConfig['MovieName'] then
		GUI.OpenWnd('Movie_Edge')
		SMovie_System.MovieAction(GlobalConfig['MovieName'], GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable, TalkTable)
	end
end

--SMovie_103.main()