local  this_file = "SMovie_101.lua:"
-- @@runlua SMovie_101
SMovie_101 = {}


--新建脚本须知：复制本脚本后，使用Ctrl + F 进入查找模式，切换到替换页面
--将SMovie_101全部替换成目标名称
--命名规则     SMovie_  + 第几幕 + 两位数的第几幕的第几个动画
--例如第一幕进战斗前： SMovie_101    ， 第一幕战斗后动画： SMovie_102，第一幕到傲来村（因为切换场景需要新的脚本）动画： SMovie_103

--注：脚本中所有跟时间相关的内容，皆可用小数，但最多精确到小数点后3位
-----------------------全局配置-----------------------
local GlobalConfig = {
	MovieName = "SMovie_101",
	LeadingActor = "npc6",
	TotalTime = 32,
	PlotEdge = {onoff = 1, start = 0, s_consume = 1,s_frame = 1},
	--剧情压边设置： onoff -是否开启   start -开启时间    s_consume -开启消耗时间    ext -移除时间   e_consume -移除消耗时间
	FrameTable = {
		Frame1 = {FrameType = "自由运动", FrameTime = 23},
		Frame2 = {FrameType = "压边对话", FrameTalk = "TalkList1"},
		Frame3 = {FrameType = "自由运动", FrameTime = 3.5},
		Frame4 = {FrameType = "压边对话", FrameTalk = "TalkList2"},
		Frame5 = {FrameType = "自由运动", FrameTime = 3.5},
		Frame6 = {FrameType = "压边对话", FrameTalk = "TalkList3"},					
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
		npc1 = {Basic = {id = 30047, name = "斗战胜佛", Occtime = 15, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 247, posy = 32, dir = 1},
				Frame3 = {
				Action1 = { ActionTime = 2, ActType = "动作", ActData = { eRoleMovement.WAVE}},
				},
			},  
		npc2 = {Basic = {id = 30049, name = "净坛使者", Occtime = 15, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 243, posy = 40, dir = 1},
			},  
		npc3 = {Basic = {id = 10012, name = "金身罗汉", Occtime = 15, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 237, posy = 31, dir = 1},
			},  
		npc4 = {Basic = {id = 30050, name = "八部天龙", Occtime = 15, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 248, posy = 42, dir = 1},
			},  
		npc5 = {Basic = {id = 30048, name = "旃檀功德佛", Occtime = 15, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 263, posy = 30, dir = 7},
				Frame5 = {
				Action1 = { ActionTime = 2, ActType = "动作", ActData = {eRoleMovement.HURT_W1 }},
				},		
			},
		npc6 = {Basic = {id = 60122, name = "共工", Occtime = 15, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 254, posy = 25, dir = 5},
				Frame3 = {
					Action1 = { ActionTime = 0.1, ActType = "动作", ActData = { eRoleMovement.WAVE}},
				},
				Frame5 = {
					Action1 = { ActionTime = 0.1, ActType = "动作", ActData = { eRoleMovement.WAVE}},						
				},				
			},
		npc7 = {Basic = {id = 0, name = "player", Occtime = 15, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 242, posy = 19, dir = 3},
						Frame5 = {
				Action1 = { ActionTime = 2, ActType = "动作", ActData = {eRoleMovement.HURT_W1 }},
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
		TalkData1 = {Npc = "npc6", Content = "你们这些可耻的人类，使用诡计，将我骗到这玄阴池中，今日定要见个输赢！！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
	},
	TalkList2 = {
		TalkData1 = {Npc = "npc1", Content = "共工，你的法术不过如此，等于给老孙挠痒痒。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},		
	},
	TalkList3 = {
		TalkData1 = {Npc = "npc1", Content = "好胆，敢伤我师父和弟子。吃俺老孙一棒。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {250,28}},
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
		eft1 = {id = 349000000, start = 1, s_frame = 5, ext = 2, e_frame = 5, posx = 242 * 16 , posy = 16 * 16 - 7},
		eft2 = {id = 349000000, start = 1, s_frame = 3, ext = 2, e_frame = 3, posx = 248 * 16 , posy = 27 * 16 - 7},
		eft3 = {id = 349000000, start = 1, s_frame = 5, ext = 2, e_frame = 5, posx = 261 * 16 , posy = 26 * 16 - 7},		
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
		img1 = {id = 1801009010,start = 0, s_consume = 1, s_type = 2, s_frame = 1, ext = 21, e_frame = 1, e_consume = 2, e_type = 3, posx = 0,posy = 0,isfullscrean = true},
		img2 = {id = 1801004020,start = 3, s_consume = 3, s_type = 6, s_frame = 1, ext = 7, e_frame = 1, e_consume = 2, e_type = 3, posx = 50,posy = 50},
		img3 = {id = 1801004100,start = 10, s_consume = 3, s_type = 2, s_frame = 1, ext = 19, e_frame = 1, e_consume = 2, e_type = 3, posx = 330,posy = 100},		
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
function SMovie_101.main()
	if not SMovie_System then
		require "SMovie_System"
	end
	
	if GlobalConfig['MovieName'] then
		SMovie_System.MovieAction(GlobalConfig['MovieName'], GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable, TalkTable)
	end
end

SMovie_101.main()