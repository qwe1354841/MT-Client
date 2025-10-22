local  this_file = "SMovie_206.lua:"
-- @@runlua SMovie_206
SMovie_206 = {}


--新建脚本须知：复制本脚本后，使用Ctrl + F 进入查找模式，切换到替换页面
--将SMovie_108全部替换成目标名称
--命名规则     SMovie_  + 第几幕 + 两位数的第几幕的第几个动画
--例如第一幕进战斗前： SMovie_206    ， 第一幕战斗后动画： SMovie_102，第一幕到傲来村（因为切换场景需要新的脚本）动画： SMovie_206

--注：脚本中所有跟时间相关的内容，皆可用小数，但最多精确到小数点后3位
-----------------------全局配置-----------------------
local GlobalConfig = {
	MovieName = "SMovie_206",
	LeadingActor = {
		Frame5 = {{0.1,"npc3"}},
		Frame7 = {{0.1,"npc1"}},
				},

	TotalTime = 80,
	PlotEdge = {onoff = 1, start = 0, s_consume = 1, s_frame = 1},
	--剧情压边设置： onoff -是否开启   start -开启时间    s_consume -开启消耗时间    ext -移除时间   e_consume -移除消耗时间
	FrameTable = {
		Frame1 = {FrameType = "自由运动", FrameTime = 1.5},
		Frame2 = {FrameType = "压边对话", FrameTalk = "TalkList1"},
		Frame3 = {FrameType = "自由运动", FrameTime = 5},
		Frame4 = {FrameType = "压边对话", FrameTalk = "TalkList2"},
		Frame5 = {FrameType = "自由运动", FrameTime = 5},
		Frame6 = {FrameType = "压边对话", FrameTalk = "TalkList3"},	
		Frame7 = {FrameType = "自由运动", FrameTime = 1},	
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
	npc1 = {Basic = {id = 22077, name = "傲红莲", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 9, posx = 506, posy = 78, dir = 5},
		},
	npc2 = {Basic = {id = 0, name = "player", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 9, posx = 497, posy = 83, dir = 1},
		},
	npc3 = {Basic = {id = 22062, name = "阎魔令", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 9, posx = 533, posy = 109, dir = 7},
		Frame3 = {
						Action1 = { ActionTime = 0.1, ActType = "移动", ActData = {506,84}},							
			},
		Frame5 = {
						Action1 = { ActionTime = 0.1, ActType = "转身", ActData = {3}},
						Action2 = { ActionTime = 1, ActType = "移动", ActData = {533,109}},			
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
		TalkData1 = {Npc = "npc2", Content = "红莲，这一个月来我翻阅了不少典籍。话说这鬼师啊，本来是有很高深的本领的，但他却因为久居地府，变得惧怕起阳光来。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData2 = {Npc = "npc1", Content = "那就是说，在凡间阳光强烈的地方可以与他较个高下咯？", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData3 = {Npc = "npc2", Content = "即便是如此，但想引鬼师来到凡间，确是一件极难的事情……", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData4 = {Npc = "npc2", Content = "如果我们去地府的话，恐怕是有去无回，非但不能引出鬼师，就连我们能不能活着见到他，也不好说。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData5 = {Npc = "npc1", Content = "就算是死，我也要跟他拼个你死我活。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData6 = {Npc = "npc2", Content = "不行啊，太危险了！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData7 = {Npc = "npc3", Content = "不危险，不危险~", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
	},
	TalkList2 = {
		TalkData1 = {Npc = "npc2", Content = "你不是那个红毛怪么！叫，叫什么来着？", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData2 = {Npc = "npc1", Content = "好像是叫什么令？", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData3 = {Npc = "npc3", Content = "本大爷是大名鼎鼎的阎魔令！就知道你们记不住我的名字，本大爷可真是有点伤心啊……", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData4 = {Npc = "npc3", Content = "但是本大爷宽宏大量，就不跟你们计较了~就直接开门见山的说正事儿了~", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData5 = {Npc = "npc3", Content = "你们想引出鬼师老儿倒也简单，鬼师老儿宅邸里有一件镇宅之宝，叫厉鬼釜。但当年获取这宝贝，却是用的不太正当的手段。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData6 = {Npc = "npc3", Content = "若是将厉鬼釜偷出来，鬼师老儿怕是只能亲自出来寻取了……", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData7 = {Npc = "npc1", Content = "哼，你这话说了等于没说，我们要是能去地府偷东西，还用在这里想破脑袋吗？", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData8 = {Npc = "npc3", Content = "那可不一定，这宝贝的厉鬼釜啊，如今可是在解阳山躺着呢！你们最好快点去到解阳山，太晚的话我怕鬼师老儿会捷足先登了。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData9 = {Npc = "npc2", Content = "啊？是你去地府偷了厉鬼釜吗？", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData10 = {Npc = "npc3", Content = "小意思啦，你们不用谢本大爷，哈哈……", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
	},
	TalkList3 = {
		TalkData1 = {Npc = "npc3", Content = "唔……还好我跑得快，真是差点就死在鬼师先生手上了呢……", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
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
function SMovie_206.main()
	if not SMovie_System then
		require "SMovie_System"
	end
	
	if GlobalConfig['MovieName'] then
		SMovie_System.MovieAction(GlobalConfig['MovieName'], GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable, TalkTable)
	end
end

--SMovie_206.main()