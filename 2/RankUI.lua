RankUI={}
local _gt = UILayout.NewGUIDUtilTable()

--每次请求的数据量（包含头尾，实际个数为 REQ_ONE_PAGE_COUNT+1）
local REQ_ONE_PAGE_COUNT = 29
--当到达数据边缘X时，请求下一页数据
local SYN_LIMIT_PAGE_COUNT = 15
local PosX = {-300,-120,120,300}
local EmpryInfos = {"未上榜","","",""}

RankUI.LastSelectSubBtn = nil
RankUI.SelectTypeIndex = 1
RankUI.SelectSubTypeIndex = 1
RankUI.RankDatas = nil
RankUI.RankTotalCount = 0
RankUI.RankTypeN = 1
RankUI.ReqRankDataControl = true
RankUI.ShowNumRow = nil

--[[
--排行表头数据（服务器配置）
local SubTitle = {
    [1] = {"排名","角色名","性别种族","装备评分"},
    [2] = {"排名","角色名","等级","装备评分"},
    [3] = {"排名","角色名","性别种族","等级"},
    [4] = {"排名","角色名","帮派等级","帮派威望"},
    [5] = {"排名","角色名","等级","活动积分"},
    [6] = {"排名","角色名","装备评分","活动积分"},
    [7] = {"排名","角色名","总战力","天梯排名"},
}
local RankTypeNameList =
{
    [1] = {{name="装备评分榜"}, {name="装备评分总榜",type=1, enum=ranklist_type.ranklist_equip_total},{name="人族装备评分榜",type=1, enum=ranklist_type.ranklist_equip_Human},{name="魔族装备评分榜",type=1, enum=ranklist_type.ranklist_equip_Demon},{name="仙族装备评分榜",type=1, enum=ranklist_type.ranklist_equip_Immortal},{name="鬼族装备评分榜",type=1, enum=ranklist_type.ranklist_equip_Ghost},{name="龙族装备评分榜",type=1, enum=ranklist_type.ranklist_equip_Dragon}},
    [2] = {{name="等级榜"}, {name="玩家等级总榜",type=3, enum=ranklist_type.ranklist_level_total}},
    [3] = {{name="活动榜"}, {name="水陆大会",type=5, enum=ranklist_type.ranklist_land_water}, {name="天下会武",type=6, enum=30},{name="天下第一",type=6, enum=32}, {name="天梯",type=7, enum=33}},
    [4] = {{name="帮派榜"}, {name="帮派威望榜",type=4, enum=ranklist_type.ranklist_guild,tag=1, shownum=0 }},
}
]]--

function RankUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()

    local panel = GUI.WndCreateWnd("RankUI" , "RankUI" , 0 , 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "排行榜","RankUI","OnExit")

    local leftBg = GUI.ImageCreate(panelBg, "leftBg","1800400200",-395,10,false,270,560)
    UILayout.SetSameAnchorAndPivot(leftBg, UILayout.Center)
    local rightBg = GUI.ImageCreate(panelBg, "rightBg","1800400200",135,10,false,780,560)
    UILayout.SetSameAnchorAndPivot(rightBg, UILayout.Center)

    --左侧榜单类型按钮列表
    local leftScroll  = GUI.ScrollListCreate(leftBg, "leftScroll", 0, 5, 270, 550, false, UIAroundPivot.Top,UIAnchor.Top)
    _gt.BindName(leftScroll, "leftScroll")
    GUI.ScrollRectSetAlignment(leftScroll,TextAnchor.UpperCenter)
    UILayout.SetSameAnchorAndPivot(leftScroll, UILayout.Top)

    --右侧榜单表头
    local SubTitleBg = GUI.ImageCreate(rightBg, "subTitleBg","1800700070",0,3,false,777,40)
    _gt.BindName(SubTitleBg,"subTitleBg")
    UILayout.SetSameAnchorAndPivot(SubTitleBg, UILayout.Top)

    local selfInfoBg = GUI.ImageCreate(rightBg, "selfInfoBg","1800600250",0,-2,false,778,55)
    _gt.BindName(selfInfoBg, "selfInfoBg")
    UILayout.SetSameAnchorAndPivot(selfInfoBg, UILayout.Bottom)

    --榜单列表区
    local loopScroll = GUI.LoopScrollRectCreate(rightBg,"loopScroll", 0, -7, 775, 460,
            "RankUI","CreatRankItem","RankUI","OnRefreshRankScroll",0, false, Vector2.New(775, 46),1, UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(loopScroll, Vector2.New(0, 0))
    _gt.BindName(loopScroll, "loopScroll")

    CL.RegisterMessage(GM.RankDateUpdate, "RankUI", "OnRankDateUpdate")
end

function RankUI.OnRankDateUpdate(type, rankType)
    if type == 1 then
        RankUI.ReqRankDataControl = true
        if rankType == RankUI.RankTypeN then
            local typeEnum = RankUI.RankTypeNameList[RankUI.SelectTypeIndex][RankUI.SelectSubTypeIndex].enum
            RankUI.RankDatas = LD.GetRankData(typeEnum)
            RankUI.RankTotalCount = LD.GetRankTotalCount(typeEnum)
            local loopScroll = _gt.GetUI("loopScroll")
            if GUI.LoopScrollRectGetTotalCount(loopScroll) ~= RankUI.RankTotalCount then
                GUI.LoopScrollRectSetTotalCount(loopScroll, RankUI.RankTotalCount)
            else
                GUI.LoopScrollRectRefreshCells(loopScroll)
            end
        end
    elseif type == 2 then
        --自己排名数据更新
        if rankType == RankUI.RankTypeN then
            RankUI.UpdateSelfRankNode()
        end
    end
end

function RankUI.UpdateSelfRankNode(useCache)
    useCache = useCache or false
    local typeEnum = RankUI.RankTypeNameList[RankUI.SelectTypeIndex][RankUI.SelectSubTypeIndex].enum
    local TypeN = type(typeEnum) == "number" and typeEnum or LD.ConvertRanklistType(typeEnum)
    if useCache and (UIDefine.CacheSelfData == nil or UIDefine.CacheSelfData[TypeN] == nil) then
        --如果使用缓存，但是缓存却为空，则请求新的数据
        CL.SendNotify(NOTIFY.RankOpe, 2, TypeN)
        return
    end
    local infos1 = nil
    if not useCache then
        local selfRank = LD.GetSelfRankData(typeEnum)
        infos1 = {tostring(selfRank.rank), selfRank.name, selfRank.rank_info, RankUI.ParseRankDaraShow(RankUI.RankTypeN, selfRank)}
    else
        infos1 = UIDefine.CacheSelfData[TypeN]
    end
    if not useCache then
        --则存储数据
        if UIDefine.CacheSelfData == nil then
            UIDefine.CacheSelfData = {}
        end
        UIDefine.CacheSelfData[TypeN] = infos1
    end
    for i = 1, 4 do
        local selfRankInfo = _gt.GetUI("selfRankInfo"..i)
        if selfRankInfo then
            GUI.StaticSetText(selfRankInfo, infos1[1] == "0" and EmpryInfos[i] or tostring(infos1[i]))
        end
    end
end

function RankUI.ParseRankDaraShow(type, rankInfo)
    if rankInfo ~= nil then
        if false then
            return tostring(rankInfo.rank_data1)
        else
            return tostring(rankInfo.rank_data1)
        end
    end
    return ""
end

--子菜单点击
function RankUI.SubTypeBtnClick(guid, target)
    if RankUI.ReqRankDataControl==false then
        CL.SendNotify(NOTIFY.ShowMessageBubble,"数据刷新中，请稍等")
        return
    end
    if RankUI.LastSelectSubBtn ~= nil then
        GUI.ButtonSetImageID(RankUI.LastSelectSubBtn, "1800602040")
    end
    local item = guid ~= nil and GUI.GetByGuid(guid) or target
    RankUI.LastSelectSubBtn = item
    GUI.ButtonSetImageID(item, "1800602041")

    RankUI.SelectSubTypeIndex = tonumber(GUI.GetData(item, "index"))
    RankUI.RefreshSubTitleText(RankUI.SelectSubTypeIndex)

    local typeEnum = RankUI.RankTypeNameList[RankUI.SelectTypeIndex][RankUI.SelectSubTypeIndex].enum
    local showNumRow = RankUI.RankTypeNameList[RankUI.SelectTypeIndex][RankUI.SelectSubTypeIndex].shownum or 1
    RankUI.SwitchRowStyle(showNumRow==1)
    RankUI.RankTypeN = type(typeEnum) == "number" and typeEnum or LD.ConvertRanklistType(typeEnum)
    --这里有缓存的数据，但是缓存的数据只是浏览到的一部分，因此本次UI打开下才使用缓存部分数据，待界面关闭则清空缓存数据
    RankUI.RankDatas = LD.GetRankData(typeEnum)
    RankUI.RankTotalCount = LD.GetRankTotalCount(typeEnum)
    if RankUI.RankDatas == nil or RankUI.RankDatas.Count == 0 then
        CL.SendNotify(NOTIFY.RankOpe, 1, RankUI.RankTypeN, REQ_ONE_PAGE_COUNT)
        --请求自己的排行数据
        CL.SendNotify(NOTIFY.RankOpe, 2, RankUI.RankTypeN)
    else
        --刷新本页数据
        local loopScroll = _gt.GetUI("loopScroll")
        GUI.LoopScrollRectSetTotalCount(loopScroll, RankUI.RankTotalCount)
        GUI.LoopScrollRectRefreshCells(loopScroll)
        --使用缓存数据
        RankUI.UpdateSelfRankNode(true)
    end
end

function RankUI.SwitchRowStyle(showNumRow)
    if showNumRow ~= RankUI.ShowNumRow then
        RankUI.ShowNumRow = showNumRow

        local subTitleText2 = _gt.GetUI("subTitleText2")
        if subTitleText2 then
            GUI.SetPositionX(subTitleText2, showNumRow and -120 or -77)
        end
        local subTitleText3 = _gt.GetUI("subTitleText3")
        if subTitleText3 then
            GUI.SetPositionX(subTitleText3, showNumRow and 120 or 232)
        end
        local cutLine2 = _gt.GetUI("cutLine2")
        if cutLine2 then
            GUI.SetPositionX(cutLine2, showNumRow and 0 or 75)
        end
        local selfRankInfo2 = _gt.GetUI("selfRankInfo2")
        if selfRankInfo2 then
            GUI.SetPositionX(selfRankInfo2, showNumRow and -120 or -75)
        end
        local selfRankInfo3 = _gt.GetUI("selfRankInfo3")
        if selfRankInfo3 then
            GUI.SetPositionX(selfRankInfo3, showNumRow and 120 or 235)
        end
        local cutLine3 = _gt.GetUI("cutLine3")
        if cutLine3 then
            GUI.SetVisible(cutLine3, showNumRow)
        end
        local subTitleText4 = _gt.GetUI("subTitleText4")
        if subTitleText4 then
            GUI.SetVisible(subTitleText4, showNumRow)
        end
        local selfRankInfo4 = _gt.GetUI("selfRankInfo4")
        if selfRankInfo4 then
            GUI.SetVisible(selfRankInfo4, showNumRow)
        end
    end
end

-- 排行界面的页签
function RankUI.RefreshSubTitleText(titleIndex)
    for i=1,4 do
        local txt = _gt.GetUI("subTitleText"..i)
        if txt ~=nil then
            if i == 1 then
				GUI.StaticSetText(txt, "排名")
			else	
				GUI.StaticSetText(txt, RankUI.RankTypeNameList[RankUI.SelectTypeIndex][titleIndex]['TXT_'..tostring(i - 1)])
			end
		end
    end
end

-- 类别菜单点击
function RankUI.TypeBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(btn, "index"))
    RankUI.SelectTypeIndex = index
    local count = #RankUI.RankTypeNameList
    for i=1,count do
        local item = _gt.GetUI("listType"..i)
        if item ~=nil then
            if i == index then
                local show = GUI.GetVisible(item)
                GUI.SetVisible(item,not show)
                if show == false then
                    local firstSubBtn = _gt.GetUI("subTypeBtn"..index)
                    if firstSubBtn then
                        RankUI.SubTypeBtnClick(nil, firstSubBtn)
                    end
                end
            else
                GUI.SetVisible(item, false)
            end
        end
    end
end

function RankUI.CreatRankItem()
    local loopScroll= _gt.GetUI("loopScroll")
    local itemList  = GUI.ItemCtrlCreate(loopScroll,"itemList","1800600240",0,0,777,45,false)
    UILayout.SetSameAnchorAndPivot(itemList, UILayout.Center)
    GUI.RegisterUIEvent(itemList , UCE.PointerClick , "RankUI", "OnRankItemClick")

    for i = 1, 4 do
        local txt = GUI.CreateStatic(itemList,"str"..i,"",PosX[i],0,210,30,"system",false)
        RankUI.SetTextBasicInfo(txt,UIDefine.BrownColor,TextAnchor.MiddleCenter,22)
    end

    local rankSp = GUI.ImageCreate( itemList,"rankSp", "1800605110", -300,0)
    UILayout.SetSameAnchorAndPivot(rankSp, UILayout.Center)
    GUI.SetVisible(rankSp,false)
    return itemList
end

function RankUI.OnRankItemClick(guid)
    local clickArea = GUI.GetByGuid(guid)
    if clickArea then
        local tag = RankUI.RankTypeNameList[RankUI.SelectTypeIndex][RankUI.SelectSubTypeIndex].tag or 0
        if tag==1 then
            --宠物
            local guid = GUI.GetData(clickArea, "guid")
            local ownerName = GUI.GetData(clickArea, "ownerName")
			CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "query_offline_pet_by_player_name",ownerName, guid)
        elseif tag==2 then
            --侍从
            local guid = GUI.GetData(clickArea, "guid")
            local ownerName = GUI.GetData(clickArea, "ownerName")
            CL.SendNotify(NOTIFY.SubmitForm,"FormGuardInfo","get_offline_guard_data",ownerName,guid)
        elseif tag==3 then
            --通过帮派名查看帮主的信息
            local roleName = GUI.GetData(clickArea, "roleName")
            CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "QueryOfflineGuildLeaderByGuildName", roleName)
        else
            --查询玩家
            local roleName = GUI.GetData(clickArea, "roleName")
            if CL.GetRoleName() == roleName then
                CL.SendNotify(NOTIFY.ShowBBMsg,"无法查看自己的信息")
            else
                CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "QueryOfflinePlayerByName", roleName)
            end
        end
    end
end

function RankUI.OnRefreshRankScroll(parameter)
    parameter = string.split(parameter , "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local itemList=GUI.GetByGuid(guid)

    GUI.ItemCtrlSetElementValue(itemList, eItemIconElement.Border, index%2 == 0 and "1800600230" or "1800600240")
    local currentItem = RankUI.RankDatas ~= nil and index < RankUI.RankDatas.Count and RankUI.RankDatas[index] or {rank=999,name="数据已更新",rank_info="滑动列表刷新",rank_data1=0,rank_data2=0,rank_data3=0}
    if currentItem ~= nil then
        local rank = GUI.GetChild(itemList,"str1")
        local str1 = GUI.GetChild(itemList,"str2")
        local str2 = GUI.GetChild(itemList,"str3")
        local str3 = GUI.GetChild(itemList,"str4")
        local rankSp = GUI.GetChild(itemList,"rankSp")

        local rankNum = tonumber(currentItem.rank)
        GUI.StaticSetText(rank,rankNum)

        GUI.SetPositionX(str1, RankUI.ShowNumRow and -120 or -75 )
        GUI.StaticSetText(str1,currentItem.name)

        GUI.SetPositionX(str2, RankUI.ShowNumRow and 120 or 235 )
        GUI.StaticSetText(str2,currentItem.rank_info)

        GUI.SetVisible(str3, RankUI.ShowNumRow)
        if RankUI.ShowNumRow then
            GUI.StaticSetText(str3,RankUI.ParseRankDaraShow(RankUI.RankTypeN, currentItem))
        end

        if rankNum < 4  then
            GUI.ImageSetImageID(rankSp,"18006051"..rankNum*10)
        end
        GUI.SetVisible(rankSp,rankNum < 4 and true or false)
        GUI.SetVisible(rank,rankNum < 4 and false or true)
        GUI.SetData(itemList, "roleName", currentItem.name)
        GUI.SetData(itemList, "guid", tostring(currentItem.rank_data2))
        GUI.SetData(itemList, "ownerName", tostring(currentItem.rank_info))
    end

    --滑动列表过程中,到达数据边界X，则请求下一页数据集
    if RankUI.ReqRankDataControl and RankUI.RankDatas ~= nil and RankUI.RankTotalCount > RankUI.RankDatas.Count and RankUI.RankDatas.Count - index < SYN_LIMIT_PAGE_COUNT then
        CL.SendNotify(NOTIFY.RankOpe, 1, RankUI.RankTypeN, REQ_ONE_PAGE_COUNT)
        RankUI.ReqRankDataControl = false
    end
end

function  RankUI.SetTextBasicInfo(txt,color,Anchor,txtSize)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, txtSize, color, Anchor)
end

function RankUI.OnDestroy()
    CL.UnRegisterMessage(GM.RankDateUpdate, "RankUI", "OnRankDateUpdate")
    if RankUI.AllDataResetTimer then
        RankUI.AllDataResetTimer:Stop()
        RankUI.AllDataResetTimer = nil
    end
    if RankUI.SubRanksTimer then
        RankUI.SubRanksTimer:Stop()
        RankUI.SubRanksTimer = nil
    end
end

--打开界面的时候调用
function RankUI.OnShow(parameter)
    if GUI.GetWnd("RankUI") == nil then
        return
    end

    RankUI.ReqRankDataControl = true
    RankUI.SelectTypeIndex = 1
    RankUI.SelectSubTypeIndex = 1
    if parameter ~= nil then
        local val = string.split(parameter, ",")
        if #val >= 2 then
            RankUI.SelectTypeIndex = tonumber(val[1])
            RankUI.SelectSubTypeIndex = tonumber(val[2])
        end
    end

    --请求排行头部定义数据
    CL.SendNotify(NOTIFY.SubmitForm, "FormRankingListSystem", "GetData")
end

function RankUI.OnParseSubRanksTimer()
    --分榜单定时器
    if RankUI.UpdateSubRanksSecondLeft then
        local timeNow = CL.GetServerTickCount()
        local nextUpdateTimeInter = -1
        for k, v in pairs(RankUI.UpdateSubRanksSecondLeft) do
            if v and #v>0 then
                if timeNow >= v[1] then
                    --清除数据
                    CL.SendNotify(NOTIFY.RankOpe, 3, k)
                    --如果是正在浏览的当前页，则重新申请数据
                    if k == RankUI.RankTypeN then
                        CL.SendNotify(NOTIFY.RankOpe, 1, RankUI.RankTypeN, REQ_ONE_PAGE_COUNT)
                        CL.SendNotify(NOTIFY.RankOpe, 2, RankUI.RankTypeN)
                    end
                    --移除当前更新时间
                    table.remove(v, 1)
                    if #v>0 and (nextUpdateTimeInter == -1 or v[1] - timeNow < nextUpdateTimeInter) then
                        nextUpdateTimeInter = v[1] - timeNow
                    end
                else
                    if #v>0 and (nextUpdateTimeInter == -1 or v[1] - timeNow < nextUpdateTimeInter) then
                        nextUpdateTimeInter = v[1] - timeNow
                    end
                end
            end
        end

        if nextUpdateTimeInter ~= -1 then
            nextUpdateTimeInter = math.max(1,nextUpdateTimeInter)
            RankUI.SubRanksTimer = Timer.New(RankUI.OnParseSubRanksTimer, nextUpdateTimeInter+2, 1)
            RankUI.SubRanksTimer:Start()
        end
    end
end

--服务器返回数据，并调用 OnUpdateRankTitles 刷新
function RankUI.OnUpdateRankTitles()
    if RankUI.UpdateSecondLeft then
        CDebug.Log("RankUI.UpdateSecondLeft:"..tostring(RankUI.UpdateSecondLeft))
        --尝试清空上一次的数据：到点才清除
        LD.ClearRankData(RankUI.UpdateSecondLeft)
        --总定时器
        if RankUI.UpdateSecondLeft > 0 then
            local allDataResetTimer = function()
                --强制刷新数据
                LD.ClearRankData(0)
                CL.SendNotify(NOTIFY.SubmitForm, "FormRankingListSystem", "GetData")
            end
            RankUI.AllDataResetTimer = Timer.New(allDataResetTimer, RankUI.UpdateSecondLeft, 1)
            RankUI.AllDataResetTimer:Start()
        end
    end

    --分榜单定时器
    RankUI.OnParseSubRanksTimer()

    local leftScroll = _gt.GetUI("leftScroll")
    local SubTitleBg = _gt.GetUI("subTitleBg")
    local selfInfoBg = _gt.GetUI("selfInfoBg")
    if leftScroll and SubTitleBg then
        for i=1,#RankUI.RankTypeNameList do
            local btn = GUI.ButtonCreate(leftScroll,i,"1800002030",0,0, Transition.ColorTint,RankUI.RankTypeNameList[i][1].name,265,65,false)
            _gt.BindName(btn, "typeBtn"..i)
            GUI.SetData(btn,"index", i)
            GUI.SetPreferredHeight(btn,65)
            UILayout.SetSameAnchorAndPivot(btn, UILayout.Center)
            GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeL)
            GUI.ButtonSetTextColor(btn,UIDefine.BrownColor)
            GUI.RegisterUIEvent(btn , UCE.PointerClick , "RankUI", "TypeBtnClick")

            local listType  = GUI.ListCreate(leftScroll,"listType"..i, 30, 6, 265, 555)
            _gt.BindName(listType, "listType"..i)
            UILayout.SetSameAnchorAndPivot(listType, UILayout.TopLeft)
            GUI.SetVisible(listType, false )
            for j=2,#RankUI.RankTypeNameList[i] do
                local subBtn = GUI.ButtonCreate(listType,i..(j-1),"1800602040",0,0, Transition.ColorTint,RankUI.RankTypeNameList[i][j].name,265,65,false)
                if j==2 then
                    --保存每一个大类的第一个子分类
                    _gt.BindName(subBtn, "subTypeBtn"..i)
                end
                GUI.SetData(subBtn, "index", j)
                UILayout.SetSameAnchorAndPivot(subBtn, UILayout.Center)
                GUI.ButtonSetTextFontSize(subBtn, UIDefine.FontSizeL)
                GUI.ButtonSetTextColor(subBtn,UIDefine.BrownColor)
                GUI.RegisterUIEvent(subBtn , UCE.PointerClick , "RankUI", "SubTypeBtnClick")
            end
        end

        for i = 1, 4 do
            if i == 1 then
				local txt = GUI.CreateStatic(SubTitleBg, "subTitleText"..i, "排名",PosX[i],0,180,30,"system",false)
				_gt.BindName(txt, "subTitleText"..i)
				RankUI.SetTextBasicInfo(txt,UIDefine.BrownColor,TextAnchor.MiddleCenter,22)
			else
				local txt = GUI.CreateStatic(SubTitleBg, "subTitleText"..i,RankUI.RankTypeNameList[1]['TXT_'..tostring(i - 1)],PosX[i],0,180,30,"system",false)
				_gt.BindName(txt, "subTitleText"..i)
				RankUI.SetTextBasicInfo(txt,UIDefine.BrownColor,TextAnchor.MiddleCenter,22)
			end

            local selfRankInfo = GUI.CreateStatic( selfInfoBg, "selfRankInfo"..i,"",PosX[i],0,210,30,"system",false)
            UILayout.SetSameAnchorAndPivot(selfRankInfo, UILayout.TopLeft)
            _gt.BindName(selfRankInfo, "selfRankInfo"..i)
            GUI.StaticSetText(selfRankInfo, i==1 and "未上榜" or "")
            RankUI.SetTextBasicInfo(selfRankInfo,UIDefine.BrownColor,TextAnchor.MiddleCenter,UIDefine.FontSizeL)

            if i <= 3 then
                local cutLine = GUI.ImageCreate(SubTitleBg, "cutLine"..i,"1800600220",-240 + 240 *(i-1),0)
                UILayout.SetSameAnchorAndPivot(cutLine, UILayout.Center)
                _gt.BindName(cutLine, "cutLine"..i)
            end
        end
    end

    --默认选中
    local lst = _gt.GetUI("listType"..RankUI.SelectTypeIndex)
    if lst then
        GUI.SetVisible(lst, true )
        RankUI.LastSelectSubBtn = GUI.GetChild(lst, tostring(RankUI.SelectTypeIndex)..RankUI.SelectSubTypeIndex)
        if RankUI.LastSelectSubBtn then
            --默认点击当前项
            RankUI.SubTypeBtnClick(nil, RankUI.LastSelectSubBtn)
        end
    end
end

--退出界面
function RankUI.OnExit()
    --清除所有缓存数据
    RankUI.ShowNumRow = nil
    CL.SendNotify(NOTIFY.RankOpe, 3, -1)
    GUI.DestroyWnd("RankUI")
end