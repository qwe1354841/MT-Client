local  this_file = "SMovie_108.lua:"
-- @@runlua SMovie_108
SMovie_108 = {}


--新建脚本须知：复制本脚本后，使用Ctrl + F 进入查找模式，切换到替换页面
--将SMovie_108全部替换成目标名称
--命名规则     SMovie_  + 第几幕 + 两位数的第几幕的第几个动画
--例如第一幕进战斗前： SMovie_108    ， 第一幕战斗后动画： SMovie_102，第一幕到傲来村（因为切换场景需要新的脚本）动画： SMovie_108

--注：脚本中所有跟时间相关的内容，皆可用小数，但最多精确到小数点后3位
-----------------------全局配置-----------------------
local GlobalConfig = {
	MovieName = "SMovie_108",
	LeadingActor = {
		Frame1 = {{0.1,"npc1"}},
		Frame3 = {{0.1,"npc2"}},
				},

	TotalTime = 80,
	PlotEdge = {onoff = 1, start = 0, s_consume = 1, s_frame = 1},
	--剧情压边设置： onoff -是否开启   start -开启时间    s_consume -开启消耗时间    ext -移除时间   e_consume -移除消耗时间
	FrameTable = {
		Frame1 = {FrameType = "自由运动", FrameTime = 7},
		Frame2 = {FrameType = "压边对话", FrameTalk = "TalkList1"},
		Frame3 = {FrameType = "自由运动", FrameTime = 8},
		Frame4 = {FrameType = "压边对话", FrameTalk = "TalkList2"},
		Frame5 = {FrameType = "自由运动", FrameTime = 2},
		Frame6 = {FrameType = "压边对话", FrameTalk = "TalkList3"},
		Frame7 = {FrameType = "自由运动", FrameTime = 4},
		Frame8 = {FrameType = "压边对话", FrameTalk = "TalkList4"},
		--Frame9 = {FrameType = "自由运动", FrameTime = 1.9},		
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
		npc1 = {Basic = {id = 10094, name = "神偷空空儿", Occtime = 1, OccFrame = 1, Exttime = 3.4, ExitFrame = 7, posx = 70, posy = 30, dir = 4},
						Frame3 = {
						Action1 = { ActionTime = 1, ActType = "移动", ActData = {86,42}},
						Action2 = { ActionTime = 3, ActType = "移动", ActData = {89,56}},
						Action3 = { ActionTime = 5, ActType = "移动", ActData = {55,36}},
				},
				Frame7 = {
						Action1 = { ActionTime = 1, ActType = "移动", ActData = {70,30}},
				},						
			},  
		npc2 = {Basic = {id = 10077, name = "黑无常", Occtime = 1, OccFrame = 5, Exttime = 80, ExitFrame = 9, posx = 48, posy = 32, dir = 3},
			},
		npc3 = {Basic = {id = 10089, name = "白无常", Occtime = 1, OccFrame = 5, Exttime = 80, ExitFrame = 9, posx = 43, posy = 34, dir = 3},
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
		TalkData1 = {Npc = "npc1", Content = "“嘿嘿，听人说这大雁塔顶层有绝世的宝物，这塔内有阴灵守护，看来传言是真的，我岂能放过。待我瞧瞧是何宝物。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},  
	},
	TalkList2 = {
		TalkData1 = {Npc = "npc1", Content = "嗯？这个香炉也没啥特殊的啊。不像是宝物。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData2 = {Npc = "npc1", Content = "咦？那是什么光芒？", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData3 = {Npc = "npc1", Content = "切，我还以为什么宝贝，原来是几卷破经书，咦？不对，这经书怎么会放出金色光芒？难道？", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData4 = {Npc = "npc1", Content = "罪过罪过，原来是当年五圣从西天取来的真经。这真经用来教化世人，虽然是好宝物，但是我空空儿盗亦有道，不能盗走，免得祸害苍生，做个千古罪人。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
	},
	TalkList3 = {
		TalkData1 = {Npc = "npc2", Content = "大胆贼徒，竟敢在我兄妹眼皮底下盗宝。该当何罪。", ClickDelay = 3, NpcAction = {AVATARACTION_MAGIC_W1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData2 = {Npc = "npc1", Content = "哎呀妈呀，鬼啊。啊？原来是黑白无常两位鬼使大人。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData3 = {Npc = "npc1", Content = "黑白无常大人啊，你们可冤枉我了，我可没想偷取这真经呢。只是听人说大雁塔中有宝贝，才过来看看。", ClickDelay = 3,NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData4 = {Npc = "npc3", Content = "还敢诡辩，这经书就是有你们这帮贼子，才会失窃，造成现在残缺。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData5 = {Npc = "npc2", Content = "妹妹慎言，不要泄露天机。观音大士口中的天选之人快到了。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData6 = {Npc = "npc1", Content = "（啊呀呀。听到了不该听到的秘闻了。趁这两位鬼使大人争吵，我得跑路了。）", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
	},		
	TalkList4 = {		
		TalkData1 = {Npc = "npc2", Content = "这偷儿能绕过塔内守护阴灵，倒是有点本事。我看这偷儿眉眼正气，不像是个坏人，就放他一回。不过要让塔里的那些地府阴灵看紧点。别再让闲杂人等再进大雁塔来了。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData2 = {Npc = "npc3", Content = "大哥说的是，还是看紧点这里。观音大士马上也要来了。我们先去一层看守。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},		
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
		img1 = {id = 1801009010,start = 0, s_consume = 0.5, s_frame = 1, s_type = 2, ext = 6, e_consume = 1, e_type = 3, e_frame = 1, posx = 0,posy = 0,isfullscrean = true},
		img2 = {id = 1801004140,start = 1, s_consume = 1, s_frame = 1, s_type = 6, ext = 5, e_consume = 1, e_type = 3, e_frame = 1, posx = 330,posy = 100},
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
function SMovie_108.main()
	if not SMovie_System then
		require "SMovie_System"
	end
	
	if GlobalConfig['MovieName'] then
		SMovie_System.MovieAction(GlobalConfig['MovieName'], GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable, TalkTable)
	end
end

--SMovie_108.main()