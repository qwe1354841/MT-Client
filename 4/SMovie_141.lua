local  this_file = "SMovie_141.lua:"
-- @@runlua SMovie_141
SMovie_141 = {}


--新建脚本须知：复制本脚本后，使用Ctrl + F 进入查找模式，切换到替换页面
--将SMovie_141全部替换成目标名称
--命名规则     SMovie_  + 第几幕 + 两位数的第几幕的第几个动画
--例如第一幕进战斗前： SMovie_141    ， 第一幕战斗后动画： SMovie_141，第一幕到傲来村（因为切换场景需要新的脚本）动画： SMovie_103

--注：脚本中所有跟时间相关的内容，皆可用小数，但最多精确到小数点后3位
-----------------------全局配置-----------------------
local GlobalConfig = {
	MovieName = "SMovie_141",
	--LeadingActor = "npc7",
	--LeadingActor = {
	LeadingActor = {
		Frame1 = {{0.1,"npc3"}},
				},
	--	Frame1 = {{3,"npc4"},{5,"npc3"}},
	--	Frame3 = {{1,"npc2"},{6,"npc3"}},
	--	}
	--LeadingActor如果是单个文本的话，则锁定该NPC
	--LeadingActor如果是二维表格的话，则是在第多少秒时看向指定NPC
	TotalTime = 20,
	PlotEdge = {onoff = 0, start = 1, s_consume = 2, s_frame = 1, ext = 0.1, e_consume = 2, e_frame = 7},
	--剧情压边设置： onoff -是否开启   start -开启时间    s_consume -开启消耗时间    ext -移除时间   e_consume -移除消耗时间
	FrameTable = {
		Frame1 = {FrameType = "自由运动", FrameTime = 2},
		Frame2 = {FrameType = "压边对话", FrameTalk = "TalkList1"},
		Frame3 = {FrameType = "自由运动", FrameTime = 1},
		Frame4 = {FrameType = "压边对话", FrameTalk = "TalkList2"},
		Frame5 = {FrameType = "自由运动", FrameTime = 1},
		Frame6 = {FrameType = "压边对话", FrameTalk = "TalkList3"},
	}
}


-----------------------NPC配置-----------------------
--NPC配置依次由 npc + 数字组成，不可跳数字
--[[
Basic配置为NPC基础配置，
	其中id 为npc表中的模型id，name 自行填入，空值则沿用npc表的配置，
	Occtime 和 Exttime是NPC的出现和消失时间，  posx，posy，dir 分别是 位置和转向
	Dye 配置为染色配置，染色配置为 client/setting/AvatarModelDye
	hid 配置为该NPC是否为隐藏NPC，true 指隐藏，false指显示

Action配置为NPC进阶配置
	每个配置的命名为Action + 依次的数字，不可跳数字
		ActionTime NPC刷出后多久进行行为，这个值必须大于0.1
		ActType 进行行为的类型，有3种，分别为（【说话】，【移动】 和 【动作】）
			当行为为【说话】时，ActData表格的第一个数据为 说话内容
			当行为为【移动】时，ActData表格的第一个数据为 目标点x值， 第二个数据为 目标点y值
			当行为为【动作】时，ActData表格的第一个数据为 动作编号， 第二个数据为动作循环模式（0--不循环，1--循环播放，2--播放至最后一帧停住）
			当行为为【转身】时，ActData表格的第一个数据为 转向方向（0-7）
			
Frame配置中
	所有时间相关参数都是从进入这一frame开始计算的
	]]
local NpcTable = {
		npc1 = {Basic = {id = 10476, name = "天兵", Occtime = 0, OccFrame = 1, Exttime = 0.5, ExitFrame = 9, posx = 72, posy = 28, dir = 2},
				Frame3 = {
					Action1 = { ActionTime = 0.1, ActType = "转身", ActData = {6}},}
				},
		npc2 = {Basic = {id = 22046, name = "哪吒", Occtime = 0, OccFrame = 1, Exttime = 1, ExitFrame = 9, posx = 41, posy = 32, dir = 6},
						},
		npc3 = {Basic = {id = 0, name = "player", Occtime = 0, OccFrame = 1, Exttime = 1, ExitFrame = 9, posx = 110, posy = 32, dir = 6},
				Frame1 = {
							Action1 = { ActionTime = 1, ActType = "移动", ActData = {92,31}},
			},
		},
	}
-----------------------NPC染色配置-----------------------
	
	

	
	
	
-----------------------压边对话配置-----------------------
--主要配置讲解
--Npc 说话者         
--Content  对话内容          
--NpcAction NPC动作，括号里的配置等同于NPC表中的 ActData   填-1,-1则表示无动作   
--NpcPop NPC产生一个泡泡对话   
--NpcMove NPC同时产生移动，填-1,-1则表示不移动

local TalkTable = {
	TalkList1 = {
		TalkData1 = {Npc = "npc1", Content = "大胆小贼竟敢私闯丹炉，盗窃仙丹！", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData2 = {Npc = "npc3", Content = "我不是，我没有。", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData3 = {Npc = "npc1", Content = "还敢狡辩，若非老君传令。还真让你得逞了！", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData4 = {Npc = "npc3", Content = "(老君传令？莫非刚才被发现啦？不行，不能被捉住。)",CNpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData5 = {Npc = "npc3", Content = "我说过我没有盗取仙丹，你若再纠缠，休怪我不客气了。", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData6 = {Npc = "npc2", Content = "住手！", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {66,30}},
		TalkData7 = {Npc = "npc2", Content = "大胆小贼，居然还敢反抗。", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},	
	},
	TalkList2 = {
		TalkData1 = {Npc = "npc1", Content = "见过三太子！", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}}, 
		TalkData2 = {Npc = "npc2", Content = "你先退下吧，此人交与我处理。", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData3 = {Npc = "npc1", Content = "遵命！", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {41,32}},
	},
	TalkList3 = {
		TalkData1 = {Npc = "npc2", Content = "此地不宜久留，先回两界山!", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData2 = {Npc = "npc3", Content = "是，三太子。", NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
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
	target	某些情况下对指定目标播放特定的特效，当它是正确配置时，posx 和posy配置会失效
]]
local EffectTable = {
		eft1 = {id = 100000004, start = 5, s_frame = 3, ext = 1, e_frame = 5, posx = 124 * 16 , posy = 115 * 16, target = ""},

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
		--img1 = {id = 1801004020,start = 3, s_consume = 3, s_type = 6, s_frame = 1, ext = 8, e_consume = 2, e_type = 3, e_frame = 1, posx = 120,posy = 120},
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

	
	
	
	
--[[
	版本更新文档： 
	
	【版本编号】2.05
	【更新日期】2017.09.21
	【更新内容】
		0.要使用新的配置，请将原配置的SMovie_XXX.main()
								中的SMovie_System.MovieAction(GlobalConfig['MovieName'], GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable)
								改成SMovie_System.MovieAction(GlobalConfig['MovieName'], GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable, TalkTable)
		1.调整了整个剧情动画的结构，现在剧情动画支持同时进行时间流程和静态流程（即以点击对话为剧情推进方式）
			1.1 我将剧情动画分成了多幕结构，每一幕可以选择【自由运动】方式或【压边对话】方式。
			1.2 自由运动方式与之前无差别，通过时间流逝作为剧情推进的标准
			1.3 压边对话方式则没有时间概念，点击完该幕中的所有对话则进入下一幕
			1.4 幕的标准是在GlobalConfig添加了FrameTable，详细配置方式请参见例句
		2.所有的【NPC】【特效】【图片】【文字】配置中，但凡开启了“幕”配置模式，就会有s_frame,e_frame,OccFrame,ExitFrame等相关配置去决定它们在哪一幕出现，在哪一幕移除
		3.NPC表中原Action？配置放到了Frame中，详情参见例句
		4.新增TalkTable配置，用于压边对话的详细内容
		5.NPC配置中加入了 hide配置，该配置是创建一个隐藏NPC，配置方式详见例句
		6.按Esc可跳过剧情
		7.新增了特效模式——对目标进行特效释放，配置方式详见例句
		8.修复了进入剧情后主角和宠物依然存在的BUG
		9.修复了进入剧情后鼠标划过依然能看到NPC残影的BUG
		
		
	--------------------------------------------------------------------------	
	【版本编号】2.10
	【更新日期】2017.10.10
	【更新内容】
		1.新增对话时间控制配置，在TalkData里填入ClickDelay，表示该对话会自动跳转下一句的时间。如果不填ClickDelay，则默认4秒后跳转下一句。
		
	
	--------------------------------------------------------------------------
	【版本编号】2.11
	【更新日期】2017.10.10
	【更新内容】
		1.新增了防卡死机制，但未经测试是否可以成功防止卡死。
	
	
	--------------------------------------------------------------------------
	【版本编号】2.12
	【更新日期】2017.10.11
	【更新内容】
		1.修复了一种高频率剧情卡住的BUG
]]	
-------------------------------------------------------------脚本内容请勿修改--------------------------------------------------------------------------	
-------------------------------------------------------------脚本版本：V_2.12--------------------------------------------------------------------------
function SMovie_141.main()
	--CL:LogToChatWindow("进入000000")
	--if not SMovie_System then
		require "SMovie_System"
	--end
	
	if GlobalConfig['MovieName'] then
		SMovie_System.MovieAction(GlobalConfig['MovieName'], GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable, TalkTable)
	end
end

--SMovie_141.main()
