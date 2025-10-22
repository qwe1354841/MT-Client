local  this_file = "SMovie_836.lua:"
-- @@runlua SMovie_836
SMovie_836 = {}


--新建脚本须知：复制本脚本后，使用Ctrl + F 进入查找模式，切换到替换页面
--将SMovie_108全部替换成目标名称
--命名规则     SMovie_  + 第几幕 + 两位数的第几幕的第几个动画
--例如第一幕进战斗前： SMovie_836    ， 第一幕战斗后动画： SMovie_102，第一幕到傲来村（因为切换场景需要新的脚本）动画： SMovie_836

--注：脚本中所有跟时间相关的内容，皆可用小数，但最多精确到小数点后3位
-----------------------全局配置-----------------------
local GlobalConfig = {
	MovieName = "SMovie_836",
	LeadingActor = {
				},

	TotalTime = 80,
	PlotEdge = {onoff = 1, start = 0, s_consume = 1, s_frame = 1},
	--剧情压边设置： onoff -是否开启   start -开启时间    s_consume -开启消耗时间    ext -移除时间   e_consume -移除消耗时间
	FrameTable = {
		Frame1 = {FrameType = "自由运动", FrameTime = 1.5},
		Frame2 = {FrameType = "压边对话", FrameTalk = "TalkList1"},	
		
		
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
		local p_posx = 95
		local p_posy = 64
		local p_dir = 0
local NpcTable = {
		npc1 = {Basic = {id = 0, name = "player", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = p_posx, posy = p_posy, dir = p_dir},
			},
		npc2 = {Basic = {id = 30246, name = "千年女妖", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 206, posy = 53, dir = 5},
			},
		npc3 = {Basic = {id = 30247, name = "青年妻子", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 196, posy = 52, dir = 4},
			},
		npc4 = {Basic = {id = 30253, name = "黑无常", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 196, posy = 63, dir = 1},
			},
		npc5 = {Basic = {id = 30254, name = "白无常", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 188, posy = 58, dir = 1},
			},
		npc6 = {Basic = {id = 30250, name = "青年书生", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 0, posy = 0, dir = 0},
			},
		npc7 = {Basic = {id = 30344, name = "圣灵残魂", Occtime = 0.1, OccFrame = 1, Exttime = 5, ExitFrame = 3, posx = 999, posy = 999, dir = 4},
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
		TalkData1 = {Npc = "npc2", Content = "可恶啊，就差那么一点点了！我就可以恢复了！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData2 = {Npc = "npc1", Content = "可惜，你只能去阴曹地府！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData3 = {Npc = "npc2", Content = "呵呵呵，你们以为我输了么？我要是死了，这个书呆子也没的活！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData4 = {Npc = "npc1", Content = "黑无常大人，真的就没有办法了么？", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData5 = {Npc = "npc4", Content = "确实，这个妖怪附身在女子身上，若要除妖那这个女子也会香消玉殒，而就这么死了，这个书生阳气不得回流，不出三炷香阳寿也殆尽。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData6 = {Npc = "npc1", Content = "怎么会这样？难道没有其他方法了么？", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData7 = {Npc = "npc3", Content = "小女子谢过各位好意了，看来这就是我的命了，能见到相公我死而无憾了。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData8 = {Npc = "npc3", Content = "（啜泣）未能与卿同根生，但愿与卿相伴死。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData9 = {Npc = "npc6", Content = "（眼角湿润）生时没能给你过上衣食无忧的日子，现在也…也罢，黄泉路上有娘子相伴，幽幽奈河也是别样景致。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData10 = {Npc = "npc7", Content = "小子，可曾听我两句，此局并非无解，先前我们的魂魄合体，方才让我想到了解法…是的，兴许可行！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData11 = {Npc = "npc1", Content = "嗯…嗯！诸位且慢！我有一计可试，要解妖怪附体，不斩肉身，只除魂魄，也许可行！只是在这期间需要仙物稳住女子的肉身。", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
		TalkData12 = {Npc = "npc4", Content = "…是了！我怎么没想到！这解阳山倒也是宝地，山巅圣泉泉水有镇妖封灵奇效，我与妹妹在此禁锢住女妖肉身，少侠你准保好了我们就动手！", ClickDelay = 3, NpcAction = {-1,-1}, NpcPop = "", NpcMove = {-1,-1}},
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
function SMovie_836.main()
	if not SMovie_System then
		CL:LoadLuaFileForce("SMovie_System.lua")
	end
	
	if GlobalConfig['MovieName'] then
		SMovie_System.MovieAction(GlobalConfig['MovieName'], GlobalConfig, NpcTable, EffectTable, ImageTable, WordTable, TalkTable)
	end
end

--SMovie_836.main()