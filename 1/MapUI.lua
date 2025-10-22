local MapUI = {}
_G.MapUI = MapUI

local _gt = UILayout.NewGUIDUtilTable();
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

------------------------------------------Start 颜色配置 Start----------------------------------
local RedColor = UIDefine.RedColor
local Brown4Color = UIDefine.Brown4Color
local Brown6Color = UIDefine.Brown6Color
local WhiteColor = UIDefine.WhiteColor
local White2Color = UIDefine.White2Color
local White3Color = UIDefine.White3Color
local GrayColor = UIDefine.GrayColor
local Gray2Color = UIDefine.Gray2Color
local Gray3Color = UIDefine.Gray3Color
local OrangeColor = UIDefine.OrangeColor
local GreenColor = UIDefine.GreenColor
local Green2Color = UIDefine.Green2Color
local Green3Color = UIDefine.Green3Color
local Blue3Color = UIDefine.Blue3Color
local Purple2Color = UIDefine.Purple2Color
local PinkColor = UIDefine.PinkColor
local OutLineDistance = UIDefine.OutLineDistance
local OutLine_BrownColor = UIDefine.OutLine_BrownColor
----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------

local lastSelectOccupyPlanItemGuid = nil

local lastSelectOccupyPlanNpcGuid = nil

----------------------------------------------End 全局变量 End---------------------------------


local miniMapBorderPadding = 10;
local worldMapBorderPadding = 17.5;
local pointSpacing = 22
local minPointSpcaing = pointSpacing * 0.7;
local itemIconBg = UIDefine.ItemIconBg;
local npcTypeColor = {
    [1] = { UIDefine.Blue3Color, UIDefine.OutLine_BlueColor },
    [2] = { UIDefine.Purple2Color, UIDefine.OutLine_PurpleColor },
    [3] = { UIDefine.Yellow3Color, UIDefine.OutLine_YellowColor },
    [4] = { UIDefine.Green4Color, UIDefine.OutLine_GreenColor },
    [5] = { UIDefine.WhiteColor, UIDefine.OutLine_BrownColor }
}

local sceneTypeColor = {
    UIDefine.Green3Color,
    UIDefine.PinkColor,
    UIDefine.Purple3Color,
    UIDefine.WhiteColor,
}

setmetatable(sceneTypeColor, {
    __index = function(t, k)
        if k <= 1 then
            return t[1];
        end
        return t[#t];
    end }
)

setmetatable(npcTypeColor, {
    __index = function(t, k)
        if k <= 1 then
            return t[1];
        end
        return t[#t];
    end }
)


function MapUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable();
    local wnd = GUI.WndCreateWnd("MapUI", "MapUI", 0, 0);

    local maskBtn = GUI.ButtonCreate(wnd, "maskBtn", "1800400220", 0, 0, Transition.None, "", GUI.GetWidth(wnd), GUI.GetHeight(wnd), false);
    SetSameAnchorAndPivot(maskBtn, UILayout.Center);
    GUI.RegisterUIEvent(maskBtn, UCE.PointerClick, "MapUI", "OnMaskBtnClick");

    MapUI.CreateMiniMap(wnd);
    MapUI.CreateWorldMap(wnd);

    MapUI.InitData();

    CL.RegisterMessage(GM.FightStateNtf, "MapUI", "OnExit");
end

function MapUI.InitData()

    MapUI.type=1;

    MapUI.mapId = 0;
    MapUI.targetPos = nil;
    MapUI.movePoints = {};
    MapUI.fakePoints = {};
    MapUI.pointPool = {};

    MapUI.logicSizeX = 0;
    MapUI.logicSizeZ = 0;

    MapUI.miniMapW = 0;
    MapUI.miniMapH = 0;

    MapUI.hostX=0;
    MapUI.hostY=0;

    MapUI.targetX=0;
    MapUI.targetY=0;

    MapUI.GRID_SIZE_DISTANCE_X=CL.GRID_SIZE_DISTANCE_X();

    MapUI.Timer=nil;
    MapUI.npcKeyNames={};

    lastSelectOccupyPlanItemGuid = nil

end

function MapUI.OnShow(parameter)
    local wnd = GUI.GetWnd("MapUI");
    if wnd == nil then
        return ;
    end

    if CL.GetFightState() then
        GUI.SetVisible(wnd, false)
        CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法进行该操作");
        return;
    end

    GUI.SetVisible(wnd, true);

    CL.RegisterMessage(GM.LoadedBaseMap, "MapUI", "OnExit")
    CL.RegisterMessage(GM.SelfPlayerTileChange, "MapUI", "OnMovePathUpdate")
    CL.RegisterMessage(GM.MoveEnd, "MapUI", "OnMoveEnd")

    if parameter == "1" then
        MapUI.OnMiniMapBtnClick();
    elseif parameter == "2" then
        MapUI.OnWorldMapBtnClick();
    end
end

function MapUI.OnClose()
    MapUI.StopTimer();
    MapUI.StopBornPointTimer()

    local sceneBtn = _gt.GetUI("pressSceneBtn");
    GUI.StopTween(sceneBtn, GUITweenType.DOScale)
    GUI.SetScale(sceneBtn, Vector3.New(1, 1, 1))

    CL.UnRegisterMessage(GM.LoadedBaseMap, "MapUI", "OnExit")
    CL.UnRegisterMessage(GM.SelfPlayerTileChange, "MapUI", "OnMovePathUpdate")
    CL.UnRegisterMessage(GM.MoveEnd, "MapUI", "OnMoveEnd")
end

function MapUI.StopBornPointTimer()
    if MapUI.ChooseBornPointCountDownTimer ~= nil then
        MapUI.ChooseBornPointCountDownTimer:Stop()
        MapUI.ChooseBornPointCountDownTimer = nil
    end
end

function MapUI.OnMaskBtnClick()
    MapUI.OnExit();
end


function MapUI.OnExit()
    GUI.CloseWnd("MapUI");
end

function MapUI.OnDestroy()
    MapUI.StopTimer()

    CL.UnRegisterMessage(GM.LoadedBaseMap, "MapUI", "OnExit")
    CL.UnRegisterMessage(GM.SelfPlayerTileChange, "MapUI", "OnMovePathUpdate")
end

function MapUI.OnMiniMapBtnClick()
    MapUI.type=1;
    local miniMapPage = _gt.GetUI("miniMapPage");
    local worldMapPage = _gt.GetUI("worldMapPage");
    GUI.SetVisible(miniMapPage, true);
    GUI.SetVisible(worldMapPage, false);

    local npcScrollBg = _gt.GetUI("npcScrollBg");
    GUI.SetVisible(npcScrollBg,false);

    local mapId = CL.GetCurrentMapId();


    if MapUI.mapId ~= mapId then
        local mapDB = DB.GetOnceMapByKey1(mapId)
        if mapDB.Id ~= 0 then
            MapUI.mapId = mapId;

            MapUI.logicSizeX = CL.GetCurrentMapLogicSizeX()
            MapUI.logicSizeZ = CL.GetCurrentMapLogicSizeZ()


            local miniMap = _gt.GetUI("miniMap");
            GUI.Destroy(miniMap);
            MapUI.ClearPointPool();

            MapUI.movePoints = {};
            MapUI.fakePoints = {};

            local miniMapBorder =_gt.GetUI("miniMapBorder");
            local miniMap = GUI.ImageCreate(miniMapBorder, "miniMap", tostring(mapDB.MiniMap), 0, 0)
            SetSameAnchorAndPivot(miniMap, UILayout.Center)
            _gt.BindName(miniMap, "miniMap");
            GUI.ImageSetMiniMapMode(miniMap, true)
            miniMap:RegisterEvent(UCE.PointerClick)
            GUI.RegisterUIEvent(miniMap, UCE.PointerClick, "MapUI", "OnMiniMapClick")

            MapUI.miniMapW = GUI.GetWidth(miniMap)
            MapUI.miniMapH = GUI.GetHeight(miniMap)
            local miniMapBorder = _gt.GetUI("miniMapBorder");
            GUI.SetWidth(miniMapBorder,    MapUI.miniMapW + miniMapBorderPadding * 2)
            GUI.SetHeight(miniMapBorder,  MapUI.miniMapH + miniMapBorderPadding * 2)

            MapUI.GenerateNpcPoint(miniMap)
            MapUI.CreateJumpPoint(miniMap)
            if TrackUI.ChickingAddressPointFlag or TrackUI.ChickingBornPointFlag then
                MapUI.CreateChickingAddressPoint(miniMap)
                MapUI.CreateChickingBornPoint(miniMap)
            end

            local npcFindBtn = GUI.GetChild(miniMapBorder,"npcFindBtn",false)
            local worldMapBtn = GUI.GetChild(miniMapBorder,"worldMapBtn",false)

            test("TrackUI.CrossServerWarfarePointFlag",TrackUI.CrossServerWarfarePointFlag)

            if TrackUI.CrossServerWarfarePointFlag then --跨服战

                GUI.SetVisible(npcFindBtn,false)
                GUI.SetVisible(worldMapBtn,false)


            else

                GUI.SetVisible(npcFindBtn,true)
                GUI.SetVisible(worldMapBtn,true)



                local crossServerWarfarePointFunctionBg = GUI.GetChild(miniMapBorder,"crossServerWarfarePointFunctionBg",false)
                if crossServerWarfarePointFunctionBg then

                    GUI.SetVisible(crossServerWarfarePointFunctionBg,false)

                end


            end

            local pathGroup = _gt.GetUI("pathGroup");
            GUI.SetWidth(pathGroup, MapUI.miniMapW )
            GUI.SetHeight(pathGroup,  MapUI.miniMapH)

            local pathGroup2 = _gt.GetUI("pathGroup2");
            GUI.SetWidth(pathGroup2, MapUI.miniMapW )
            GUI.SetHeight(pathGroup2,  MapUI.miniMapH)


            MapUI.npcKeyNames={};

            local ids=DB.GetNpc_GenAllKeys();
            for i = 0, ids.Count-1 do
                local id = ids[i];
                local npcGenDB = DB.GetNpc_Gen(id);
                if npcGenDB.MapKeyName==CL.GetCurrentMapKeyName() and npcGenDB.ShowMapAndRadarUI==1 then
                    table.insert(MapUI.npcKeyNames,npcGenDB.NpcKeyName);
                end
            end
        end
    end

    MapUI.OnMovePathUpdate();
    MapUI.OnHostPointUpdate();
    if TrackUI.ChickingAddressPointFlag then
        MapUI.RefreshChickingAddressPoint()
    elseif TrackUI.ChickingBornPointFlag then
        MapUI.RefreshBornPointCountDown()
    elseif TrackUI.CrossServerWarfarePointFlag then --跨服战

        CL.SendNotify(NOTIFY.SubmitForm,"FormAct_CrossServer","MapData")

    end

end

function MapUI.StartTimer()
    if MapUI.Timer==nil then
        MapUI.Timer=Timer.New(MapUI.OnHostPointUpdate,0.05,-1)
        MapUI.Timer:Start();
    end
end


function MapUI.StopTimer()
    if MapUI.Timer~=nil then
        MapUI.Timer:Stop();
        MapUI.Timer=nil;
    end
end


function MapUI.OnMiniMapClick(guid)
    local RoleAttrIsAutoGame = CL.GetIntAttr(RoleAttr.RoleAttrIsAutoGame)
    if RoleAttrIsAutoGame == 1 then
        CL.SendNotify(NOTIFY.ShowBBMsg,"当前正在辅助中，无法移动")
        return
    end

    local miniMap = GUI.GetByGuid(guid);
    local posStr = GUI.GetData(miniMap, "pressPosition")

    local x = tonumber(string.split(posStr, '/')[1]) +  MapUI.miniMapW / 2
    local z = tonumber(string.split(posStr, '/')[2]) +  MapUI.miniMapH / 2

    local logicSizeX = CL.GetCurrentMapLogicSizeX()
    local logicSizeZ = CL.GetCurrentMapLogicSizeZ()

    local logicX = math.floor(x /  MapUI.miniMapW * logicSizeX);
    local logicZ = math.floor(z / MapUI.miniMapH * logicSizeZ);

    CL.StartMove(logicX, logicZ);
end

function MapUI.OnMovePathUpdate()

    if MapUI.type==2 then
        return;
    end


    --local x, y = MapUI.ConvertToMapPostion(logicX,logicZ);
    --local hostPoint = _gt.GetUI("hostPoint");
    --GUI.SetPositionX(hostPoint, x)
    --GUI.SetPositionY(hostPoint, y)
    --MapUI.hostX=x;
    --MapUI.hostY=-y;


    local pointPos = CL.GetMoveKeyPoints()
    if pointPos == nil or pointPos.Count == 0 then
        MapUI.ClearTartgetPoint()
    else
        MapUI.StartTimer();

        local targetPoint = _gt.GetUI("targetPoint");
        GUI.SetVisible(targetPoint, true);

        local targetPos =  pointPos[pointPos.Count - 1];
        if MapUI.targetPos == nil or not Vector2.__eq(targetPos, MapUI.targetPos) then
            MapUI.targetPos = targetPos;
            local x, y = MapUI.ConvertToMapPostion(targetPos.x, targetPos.y);
            GUI.SetPositionX(targetPoint, x)
            GUI.SetPositionY(targetPoint, -y)
            MapUI.targetX=x;
            MapUI.targetY=-y;

            MapUI.ResetAllPoint();
            MapUI.CreateMovePoints(pointPos)
            MapUI.CreateFakePoints(pointPos)
        else
            MapUI.RefreshKeyPoint(pointPos)
            MapUI.RefreshFakePoint(pointPos)
        end
    end
end

function MapUI.ClearTartgetPoint()
    local targetPoint = _gt.GetUI("targetPoint");
    GUI.SetVisible(targetPoint, false);
    MapUI.ResetAllPoint();
    MapUI.targetPos = nil;
    MapUI.targetX=0;
    MapUI.targetY=0;
end

function MapUI.OnHostPointUpdate()
    local clientPosX= CL.GetHostClientPositionX();
    local clientPosZ= CL.GetHostClientPositionZ();
    local logicX =clientPosX* MapUI.GRID_SIZE_DISTANCE_X;
    local logicZ= MapUI.logicSizeZ-1- clientPosZ* MapUI.GRID_SIZE_DISTANCE_X;

    local x, y = MapUI.ConvertToMapPostion(logicX,logicZ);
    local hostPoint = _gt.GetUI("hostPoint");
    GUI.SetPositionX(hostPoint, x)
    GUI.SetPositionY(hostPoint, y)
    MapUI.hostX=x;
    MapUI.hostY=-y;

    if math.abs(MapUI.hostX-MapUI.targetX)<2 and math.abs(MapUI.hostY-MapUI.targetY)<2 then
        MapUI.ClearTartgetPoint()
        MapUI.StopTimer();
    end
end


function MapUI.OnMoveEnd()
    MapUI.ClearTartgetPoint()
    MapUI.StopTimer()
end

function MapUI.RefreshKeyPoint(pointPos)
    if MapUI.movePoints ~= nil then
        for i = #MapUI.movePoints,1,-1 do
            if i >= pointPos.Count then
                local movePoint = GUI.GetByGuid(MapUI.movePoints[i][1]);
                GUI.SetVisible(movePoint, false);
            else
                return;
            end
        end
    end
end

function MapUI.RefreshFakePoint(pointPos)

    local v_host = Vector2.New( MapUI.hostX,  MapUI.hostY)

    if MapUI.fakePoints ~= nil then
        for i = #MapUI.fakePoints, 1, -1 do
            if i > pointPos.Count then
                for j = #MapUI.fakePoints[i], 1, -1 do
                    MapUI.RecyclePointGuid(MapUI.fakePoints[i][j][1])
                    table.remove(MapUI.fakePoints[i],j);
                end
            elseif i == pointPos.Count then
                local v_lastPoint=nil
                if i == 1 then
                    v_lastPoint = Vector2.New(MapUI.targetX, MapUI.targetY);
                else
                    local movePoint = GUI.GetByGuid(MapUI.movePoints[i - 1][1]);
                    v_lastPoint = Vector2.New(GUI.GetPositionX(movePoint), GUI.GetPositionY(movePoint));
                end

                local d = Vector2.Distance(v_host, v_lastPoint)
                for j = #MapUI.fakePoints[i], 1, -1 do
                    if MapUI.fakePoints[i][j] ~= nil then
                        local v_fakePoint = Vector2.New(MapUI.fakePoints[i][j][2], -MapUI.fakePoints[i][j][3]);
                        local d2 = Vector2.Distance(v_fakePoint, v_lastPoint)

                        if d2 >= d then
                            MapUI.RecyclePointGuid(MapUI.fakePoints[i][j][1])
                            table.remove(MapUI.fakePoints[i],j);
                        end
                    end
                end
            else
                return ;
            end
        end
    end

end

function MapUI.CreateFakePoints(pointPos)
    local v_host = Vector2.New( MapUI.hostX,  MapUI.hostY)
    local v_target = Vector2.New(MapUI.targetX, MapUI.targetY);

    if pointPos.Count == 1 then
        MapUI.FillFakePoiont(v_target, v_host, 1);
    else
        for i = 1, pointPos.Count - 1 do
            local v_point = Vector2.New(MapUI.movePoints[i][2], MapUI.movePoints[i][3])

            if i == 1 then
                MapUI.FillFakePoiont(v_target, v_point, 1);
            end

            if i + 1 == pointPos.Count then
                MapUI.FillFakePoiont(v_point, v_host, i + 1);
            else
                local nextMovePoint = GUI.GetByGuid(MapUI.movePoints[i + 1][1])
                if GUI.GetVisible(nextMovePoint) then
                    local v_nextPoint = Vector2.New(MapUI.movePoints[i + 1][2], MapUI.movePoints[i + 1][3])
                    MapUI.FillFakePoiont(v_point, v_nextPoint, i + 1);
                end
            end
        end
    end


end

function MapUI.FillFakePoiont(pos1, pos2, i)

    if MapUI.fakePoints[i] == nil then
        MapUI.fakePoints[i] = {};
    end

    local j = 1;
    local dis = Vector2.Distance(pos1, pos2)
    local ratio = pointSpacing / dis
    local t = ratio
    while t < 1 do
        if (1 - t) * dis < minPointSpcaing then
            break
        end

        local pos = Vector2.Lerp(pos1, pos2, t)
        MapUI.SetFakePoint(pos, i, j)
        j = j + 1
        t = t + ratio
    end

end

function MapUI.SetFakePoint(pos, i, j)
    if MapUI.fakePoints[i][j] == nil then
        MapUI.fakePoints[i][j] = {MapUI.CreatePointGuid(),pos.x,-pos.y};
    end
    local fakePoint = GUI.GetByGuid(MapUI.fakePoints[i][j][1]);
    GUI.SetVisible(fakePoint, true)
    GUI.SetPositionX(fakePoint, pos.x)
    GUI.SetPositionY(fakePoint, -pos.y)
    MapUI.fakePoints[i][j][2]=pos.x;
    MapUI.fakePoints[i][j][3]=-pos.y;
end

function MapUI.CreateMovePoints(pointPos)
    if pointPos.Count == 1 then
        return ;
    end

    for i = 1, pointPos.Count - 1 do
        local x, y = MapUI.ConvertToMapPostion(pointPos[i - 1].x, pointPos[i - 1].y)
        local index = pointPos.Count - i;

        if MapUI.movePoints[index] == nil then
            MapUI.movePoints[index] = {MapUI.CreatePointGuid(),x,-y};
        end
        local movePoint = GUI.GetByGuid(MapUI.movePoints[index][1]);
        GUI.SetVisible(movePoint, true)
        GUI.SetPositionX(movePoint, x)
        GUI.SetPositionY(movePoint, y)
        MapUI.movePoints[index][2]=x;
        MapUI.movePoints[index][3]=-y;
    end
end

function MapUI.CreatePointGuid()

    for i = 1, #MapUI.pointPool do
        local data = MapUI.pointPool[i];
        if data[1] == false then
            data[1] = true;
            return data[2];
        end
    end

    local pathGroup = _gt.GetUI("pathGroup");
    local movePoint = GUI.ImageCreate(pathGroup, "point"..#MapUI.pointPool, "1800508020", 0, 0)
    SetAnchorAndPivot(movePoint, UIAnchor.TopLeft, UIAroundPivot.Center)
    local guid = GUI.GetGuid(movePoint);
    table.insert(MapUI.pointPool, { true, guid });
    return guid;

end

function MapUI.RecyclePointGuid(guid)
    for i = 1, #MapUI.pointPool do
        local data = MapUI.pointPool[i];
        if data[2] == guid then
            local movePoint = GUI.GetByGuid(guid);
            GUI.SetVisible(movePoint, false);
            data[1] = false;
        end
    end
end

function MapUI.ResetAllPoint()
    if MapUI.movePoints ~= nil then
        for i = 1, #MapUI.movePoints do
            MapUI.RecyclePointGuid(MapUI.movePoints[i][1])
        end
    end


    if MapUI.fakePoints ~= nil then
        for i = 1, #MapUI.fakePoints do
            for j = 1, #MapUI.fakePoints[i] do
                test(tostring(MapUI.fakePoints[i][j][1]))
                MapUI.RecyclePointGuid(MapUI.fakePoints[i][j][1])
            end
        end
    end

    MapUI.movePoints = {};
    MapUI.fakePoints = {};
end


function MapUI.ClearPointPool()
    local pathGroup = _gt.GetUI("pathGroup");
    for i = 0, GUI.GetChildCount(pathGroup)-1 do
        GUI.Destroy(GUI.GetChildByIndex(pathGroup,i));
    end

    MapUI.pointPool={};
end

function MapUI.GetSceneBtnName(keyName)
    local name = keyName;
    if string.find(keyName, "大雁塔") ~= nil then
        name = "大雁塔一层";
    end

    if string.find(keyName, "水帘洞窟") ~= nil then
        name = "水帘洞窟一层";
    end

    if string.find(keyName, "遗址地宫") ~= nil then
        name = "沙城遗址";
    end

    if string.find(keyName, "丹炉地宫") ~= nil then
        name = "丹炉地宫一层";
    end
    return name;
end

function MapUI.OnWorldMapBtnClick()
    MapUI.StopTimer();

    MapUI.type=2;
    local miniMapPage = _gt.GetUI("miniMapPage");
    local worldMapPage = _gt.GetUI("worldMapPage");
    GUI.SetVisible(miniMapPage, false);
    GUI.SetVisible(worldMapPage, true);

    local preSceneBtn = _gt.GetUI("preSceneBtn");
    if preSceneBtn ~= nil then
        local fakeImage = GUI.GetChild(preSceneBtn, "fakeImage");
        GUI.ImageSetImageID(fakeImage, "1800500050");
    end

    local sceneBtnName = MapUI.GetSceneBtnName(CL.GetCurrentMapKeyName())
    local worldMap = _gt.GetUI("worldMap");
    local sceneBtn = GUI.GetChild(worldMap, sceneBtnName);
    local host = _gt.GetUI("host");
    if sceneBtn ~= nil then
        _gt.BindName(sceneBtn, "preSceneBtn")
        local fakeImage = GUI.GetChild(sceneBtn, "fakeImage");
        GUI.ImageSetImageID(fakeImage, "1800500060");
        GUI.SetVisible(host,true);
        local icon = GUI.GetChild(host, "icon");

        local roleId = CL.GetRoleTemplateID();
        local roleDB = DB.GetRole(roleId);
        if roleDB.Id ~= 0 then
            GUI.ImageSetImageID(icon, tostring(roleDB.Head));
        end

        local x = GUI.GetPositionX(sceneBtn)
        local y = GUI.GetPositionY(sceneBtn)

        GUI.SetPositionX(host, x)
        GUI.SetPositionY(host, y + 18)
    else
        GUI.SetVisible(host,false);
    end


end

function MapUI.GenerateNpcPoint(miniMap)
    local ids = DB.GetNpc_GenAllKeys()
    for i = 0, ids.Count - 1 do
        local npcGenDB = DB.GetNpc_Gen(ids[i]);
        if npcGenDB.MapKeyName == CL.GetCurrentMapKeyName() then
            if npcGenDB.ShowMapAndRadarUI == 1 then
                local npcDB = DB.GetOnceNpcByKey2(npcGenDB.NpcKeyName)
                if npcDB.Id ~= 0 then
                    local x, z = MapUI.ConvertToMapPostion(npcGenDB.X, npcGenDB.Y)
                    test("npcDB.IndexName",npcDB.IndexName)
                    local npcPoint = GUI.CreateStatic(miniMap, npcDB.IndexName, npcDB.IndexName, x, z, 200, 35);
                    SetAnchorAndPivot(npcPoint, UIAnchor.TopLeft, UIAroundPivot.Center);
                    GUI.StaticSetAlignment(npcPoint, TextAnchor.MiddleCenter);
                    GUI.StaticSetFontSize(npcPoint, UIDefine.FontSizeSS);
                    GUI.SetIsOutLine(npcPoint, true)
                    GUI.SetOutLine_Distance(npcPoint, UIDefine.OutLineDistance)
                    GUI.SetColor(npcPoint, npcTypeColor[npcDB.Type][1])
                    GUI.SetOutLine_Color(npcPoint, npcTypeColor[npcDB.Type][2])

                    --调整位置，防止出边框
                    local w = (16 * string.len(npcDB.IndexName)) / 3
                    local h = 18

                    local padding = 10
                    if x - w / 2 < padding then
                        GUI.SetPositionX(npcPoint, w / 2 + padding)
                    end

                    if x + w / 2 > MapUI.miniMapW - padding then
                        GUI.SetPositionX(npcPoint,   MapUI.miniMapW - padding - w / 2)
                    end

                    if z - h / 2 < padding then
                        GUI.SetPositionY(npcPoint, h / 2 + padding)
                    end

                    if z + h / 2 > MapUI.miniMapH - padding then
                        GUI.SetPositionY(npcPoint,   MapUI.miniMapH - padding - h / 2)
                    end
                end
            end
        end

    end
end

function MapUI.CreateChickingAddressPoint(miniMap)
    local addPointGroup = GUI.GroupCreate(miniMap,"addPointGroup",0,0,GUI.GetWidth(miniMap), GUI.GetHeight(miniMap))
    _gt.BindName(addPointGroup,"addPointGroup")
    for name, value in pairs(TrackUI.Act_Chickings_Config.BornPoint) do
        local x, y = MapUI.ConvertToMapPostion(value.PosX, value.PosY)
        local x = x - MapUI.miniMapW / 2;
        local y = y - MapUI.miniMapH / 2
        local addPoint = GUI.CreateStatic(addPointGroup, name, name, x, y, 200, 35,"100");
        SetSameAnchorAndPivot(addPoint, UILayout.Center)
        GUI.StaticSetAlignment(addPoint, TextAnchor.MiddleCenter);
        GUI.StaticSetFontSize(addPoint, UIDefine.FontSizeSS);
        GUI.SetIsOutLine(addPoint, true)
        GUI.SetOutLine_Distance(addPoint, UIDefine.OutLineDistance)
        GUI.SetColor(addPoint, Color.New(241/255,241/255,241/255,178/255))
        GUI.SetOutLine_Color(addPoint, Color.New(87/255,87/255,87/255,255/255))
    end
    GUI.SetVisible(addPointGroup,false)
end

function MapUI.CreateChickingAirdropPoint(x,y,Rand)
    local miniMap = _gt.GetUI("miniMap")
    local MaxMapX, MaxMapY = MapUI.ConvertToMapPostion(x + Rand, y + Rand)
    local MapX, MapY = MapUI.ConvertToMapPostion(x, y)
    local diamX = (MaxMapX - MapX) * 2
    local diamY = (MaxMapY - MapY) * 2
    local MapX = MapX - MapUI.miniMapW / 2;
    local MapY = MapY - MapUI.miniMapH / 2
    local AirdropPoint = GUI.ImageCreate(miniMap, "AirdropPoint", "1800707221", MapX, MapY, false,diamX,diamY)
    SetSameAnchorAndPivot(AirdropPoint, UILayout.Center)
    local pointTip = GUI.CreateStatic(AirdropPoint,"pointTip","鸡王至宝\n即将刷新",0,0,200,60,"100")
    UILayout.StaticSetFontSizeColorAlignment(pointTip, UIDefine.FontSizeS, UIDefine.Green6Color,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(pointTip, UILayout.Center)
    GUI.SetIsOutLine(pointTip, true)
    GUI.SetOutLine_Distance(pointTip, UIDefine.OutLineDistance)
    GUI.SetColor(pointTip, Color.New(220 / 255, 255 / 255, 222 / 255, 1))
    GUI.SetOutLine_Color(pointTip, Color.New(8/255,164/255,16/255,1))
    GUI.StaticSetLineSpacing(pointTip,1.4)
    return AirdropPoint
end

--跨服战地图
function MapUI.RefreshCrossServerWarfarePoint()
    local miniMap = _gt.GetUI("miniMap");
    test("MapUI.Act_CrossServerMapData",inspect(MapUI.Act_CrossServerMapData))

    local crossServerWarfarePointGroup = GUI.GetChild(miniMap,"crossServerWarfarePointGroup",false)

    if crossServerWarfarePointGroup == nil then

        crossServerWarfarePointGroup = GUI.GroupCreate(miniMap,"CrossServerWarfarePointGroup",0,0,GUI.GetWidth(miniMap), GUI.GetHeight(miniMap),false)
        _gt.BindName(crossServerWarfarePointGroup,"crossServerWarfarePointGroup")

        for i = 1, #MapUI.Act_CrossServerMapData do
            local data = MapUI.Act_CrossServerMapData[i]

            local crossServerWarfarePoint = GUI.GetChild(crossServerWarfarePointGroup,"crossServerWarfarePoint"..data.npc_guid,false)
            if crossServerWarfarePoint == nil then
                local x, y = MapUI.ConvertToMapPostion(data.posx, data.posy)
                local x = x - MapUI.miniMapW / 2;
                local y = y - MapUI.miniMapH / 2

                crossServerWarfarePoint = GUI.CreateStatic(crossServerWarfarePointGroup,"crossServerWarfarePoint"..data.npc_guid,data.land_name, x, y, 160, 35,"100");
                SetSameAnchorAndPivot(crossServerWarfarePoint, UILayout.Center)
                GUI.StaticSetAlignment(crossServerWarfarePoint, TextAnchor.MiddleCenter);
                GUI.StaticSetFontSize(crossServerWarfarePoint, 22);
                GUI.SetIsOutLine(crossServerWarfarePoint, true)
                GUI.SetOutLine_Distance(crossServerWarfarePoint, UIDefine.OutLineDistance)
                GUI.SetColor(crossServerWarfarePoint, UIDefine.Green3Color);
                GUI.SetOutLine_Color(crossServerWarfarePoint, UIDefine.OutLine_GreenColor)


                local teamIcon = GUI.ItemCtrlCreate(crossServerWarfarePoint,"teamIcon","1800700020",0,5,50,50,false,"system",false)
                SetAnchorAndPivot(teamIcon, UIAnchor.Top, UIAroundPivot.Bottom)
                GUI.ItemCtrlSetElementValue(teamIcon,eItemIconElement.Border,"1800302190")
                GUI.ItemCtrlSetElementRect(teamIcon,eItemIconElement.Icon,0,-1,45,45)
                local npcGuid = data.npc_guid
                if MainUI.LandData ~= nil and npcGuid ~= nil then

                    MapUI.OccupyPlanLoopDataTable = {}

                    if MainUI.LandData[npcGuid] ~= nil then

                        local index = 0
                        local rate = 0

                        for i = 1, #MainUI.LandData[npcGuid].rate do

                            local data = MainUI.LandData[npcGuid].rate[i]
                            if rate <= data.rate and data.rate > 0 then

                                rate = data.rate
                                index = i

                            end

                        end

                        if index ~= 0 then

                            GUI.SetVisible(teamIcon,true)
                            GUI.ItemCtrlSetElementValue(teamIcon,eItemIconElement.Icon,MainUI.Act_CrossServerData.CampBuff[index].Icon)

                        else

                            GUI.SetVisible(teamIcon,false)

                        end


                    end

                end

            end




        end

    end

    local miniMapBorder = _gt.GetUI("miniMapBorder")

    local crossServerWarfarePointFunctionBg = GUI.GetChild(miniMapBorder,"crossServerWarfarePointFunctionBg",false)

    if crossServerWarfarePointFunctionBg == nil then

        crossServerWarfarePointFunctionBg = GUI.ImageCreate(miniMapBorder, "crossServerWarfarePointFunctionBg","1800001200", 0, 0, false, 320, 580)
        _gt.BindName(crossServerWarfarePointFunctionBg,"crossServerWarfarePointFunctionBg")
        SetAnchorAndPivot(crossServerWarfarePointFunctionBg, UIAnchor.TopRight, UIAroundPivot.TopLeft)

        local titleTxt = GUI.CreateStatic(crossServerWarfarePointFunctionBg, "ContributionDegree", "查看领地占领进度", 0, 10, 300, 40)
        GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleCenter);
        SetSameAnchorAndPivot(titleTxt, UILayout.Top)
        GUI.StaticSetFontSize(titleTxt, 20)
        GUI.SetColor(titleTxt, UIDefine.YellowColor)

        local crossServerWarfareFunctionLoop =
        GUI.LoopScrollRectCreate(
                crossServerWarfarePointFunctionBg,
                "crossServerWarfareFunctionLoop",
                0,
                60,
                300,
                140,
                "MapUI",
                "CreateCrossServerWarfareFunctionItem",
                "MapUI",
                "RefreshCrossServerWarfareFunctionItem",
                0,
                false,
                Vector2.New(140, 55),
                2,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        _gt.BindName(crossServerWarfareFunctionLoop,"crossServerWarfareFunctionLoop")
        SetSameAnchorAndPivot(crossServerWarfareFunctionLoop, UILayout.Top)
        GUI.ScrollRectSetAlignment(crossServerWarfareFunctionLoop, TextAnchor.UpperCenter)
        GUI.ScrollRectSetChildSpacing(crossServerWarfareFunctionLoop, Vector2.New(3, 5))

        local cutLine = GUI.ImageCreate(crossServerWarfarePointFunctionBg, "cutLine", "1800300040", 0, 210, false, 300, 2)
        SetAnchorAndPivot(cutLine, UIAnchor.Top, UIAroundPivot.Top)


        local occupyPlanLoop =
        GUI.LoopScrollRectCreate(
                crossServerWarfarePointFunctionBg,
                "occupyPlanLoop",
                10,
                225,
                300,
                335,
                "MapUI",
                "CreateOccupyPlanLoopItem",
                "MapUI",
                "RefreshOccupyPlanLoopItem",
                0,
                false,
                Vector2.New(280, 100),
                1,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        _gt.BindName(occupyPlanLoop,"occupyPlanLoop")
        SetSameAnchorAndPivot(occupyPlanLoop, UILayout.Top)
        GUI.ScrollRectSetAlignment(occupyPlanLoop, TextAnchor.UpperCenter)
        GUI.ScrollRectSetChildSpacing(occupyPlanLoop, Vector2.New(3, 5))

    end

    MapUI.GetAct_CrossServerMapData()
    local crossServerWarfareFunctionLoop = GUI.GetChild(crossServerWarfarePointFunctionBg,"crossServerWarfareFunctionLoop",false)
    GUI.LoopScrollRectSetTotalCount(crossServerWarfareFunctionLoop, #MapUI.NewAct_CrossServerMapData)
    GUI.LoopScrollRectRefreshCells(crossServerWarfareFunctionLoop)

end

function MapUI.GetAct_CrossServerMapData()

    MapUI.NewAct_CrossServerMapData = {}

    for i, v in ipairs(MapUI.Act_CrossServerMapData) do

        if v.land_name ~= nil then

            table.insert(MapUI.NewAct_CrossServerMapData,v)

        end

    end

end

function MapUI.RefreshCrossServerWarfareFunctionLoopData()

    MapUI.RefreshOccupyPlanLoopData(lastSelectOccupyPlanNpcGuid)

    local crossServerWarfarePointGroup = _gt.GetUI("crossServerWarfarePointGroup")

    if crossServerWarfarePointGroup ~= nil then

        for i = 1, #MapUI.Act_CrossServerMapData do

            local data = MapUI.Act_CrossServerMapData[i]

            local crossServerWarfarePoint = GUI.GetChild(crossServerWarfarePointGroup,"crossServerWarfarePoint"..data.npc_guid,false)

            if crossServerWarfarePoint == nil then


                if data.is_destory ~= 0 then

                    GUI.Destroy(crossServerWarfarePoint)

                else

                    local x, y = MapUI.ConvertToMapPostion(data.posx, data.posy)
                    local x = x - MapUI.miniMapW / 2;
                    local y = y - MapUI.miniMapH / 2

                    crossServerWarfarePoint = GUI.CreateStatic(crossServerWarfarePointGroup,"crossServerWarfarePoint"..data.npc_guid,data.land_name, x, y, 160, 35,"100");
                    SetSameAnchorAndPivot(crossServerWarfarePoint, UILayout.Center)
                    GUI.StaticSetAlignment(crossServerWarfarePoint, TextAnchor.MiddleCenter);
                    GUI.StaticSetFontSize(crossServerWarfarePoint, 22);
                    GUI.SetIsOutLine(crossServerWarfarePoint, true)
                    GUI.SetOutLine_Distance(crossServerWarfarePoint, UIDefine.OutLineDistance)
                    GUI.SetColor(crossServerWarfarePoint, UIDefine.Green3Color);
                    GUI.SetOutLine_Color(crossServerWarfarePoint, UIDefine.OutLine_GreenColor)


                    local teamIcon = GUI.ItemCtrlCreate(crossServerWarfarePoint,"teamIcon","1800700020",0,5,50,50,false,"system",false)
                    SetAnchorAndPivot(teamIcon, UIAnchor.Top, UIAroundPivot.Bottom)
                    GUI.ItemCtrlSetElementValue(teamIcon,eItemIconElement.Border,"1800302190")
                    GUI.ItemCtrlSetElementRect(teamIcon,eItemIconElement.Icon,0,-1,45,45)

                    local npcGuid = data.npc_guid
                    if MainUI.LandData ~= nil and npcGuid ~= nil then

                        MapUI.OccupyPlanLoopDataTable = {}

                        if MainUI.LandData[npcGuid] ~= nil then

                            local index = 0
                            local rate = 0

                            for i = 1, #MainUI.LandData[npcGuid].rate do

                                local data = MainUI.LandData[npcGuid].rate[i]
                                if rate <= data.rate and data.rate > 0 then

                                    rate = data.rate
                                    index = i

                                end

                            end

                            if index ~= 0 then

                                GUI.SetVisible(teamIcon,true)
                                GUI.ItemCtrlSetElementValue(teamIcon,eItemIconElement.Icon,MainUI.Act_CrossServerData.CampBuff[index].Icon)
                            else

                                GUI.SetVisible(teamIcon,false)

                            end


                        end

                    end

                end


            else

                local teamIcon = GUI.GetChild(crossServerWarfarePoint,"teamIcon",false)

                local npcGuid = data.npc_guid
                if MainUI.LandData ~= nil and npcGuid ~= nil then

                    MapUI.OccupyPlanLoopDataTable = {}

                    if MainUI.LandData[npcGuid] ~= nil then

                        local index = 0
                        local rate = 0

                        for i = 1, #MainUI.LandData[npcGuid].rate do

                            local data = MainUI.LandData[npcGuid].rate[i]
                            if rate <= data.rate and data.rate > 0 then

                                rate = data.rate
                                index = i

                            end

                        end

                        if index ~= 0 then

                            GUI.SetVisible(teamIcon,true)
                            GUI.ItemCtrlSetElementValue(teamIcon,eItemIconElement.Icon,MainUI.Act_CrossServerData.CampBuff[index].Icon)

                        else

                            GUI.SetVisible(teamIcon,false)

                        end


                    end

                end

                if data.is_destory ~= 0 then

                    GUI.Destroy(crossServerWarfarePoint)

                end

            end



        end

    end

    MapUI.GetAct_CrossServerMapData()
    local crossServerWarfarePointFunctionBg = _gt.GetUI("crossServerWarfarePointFunctionBg");
    local crossServerWarfareFunctionLoop = GUI.GetChild(crossServerWarfarePointFunctionBg,"crossServerWarfareFunctionLoop",false)
    GUI.LoopScrollRectSetTotalCount(crossServerWarfareFunctionLoop, #MapUI.NewAct_CrossServerMapData)
    GUI.LoopScrollRectRefreshCells(crossServerWarfareFunctionLoop)


end


function MapUI.CreateOccupyPlanLoopItem()
    local occupyPlanLoop = _gt.GetUI("occupyPlanLoop")

    local index = GUI.LoopScrollRectGetChildInPoolCount(occupyPlanLoop) + 1

    local groupBg = GUI.ImageCreate(occupyPlanLoop, "groupBg"..index, "1800001150", 0, 0 , false, 100, 10)
    SetSameAnchorAndPivot(groupBg, UILayout.TopLeft)

    local battleArrayIcon = GUI.ItemCtrlCreate(groupBg,"battleArrayIcon","1800700020",10,10,80,80,false,"system",false)
    GUI.ItemCtrlSetElementRect(battleArrayIcon,eItemIconElement.Icon,0,-1,70,70)
    GUI.ItemCtrlSetElementValue(battleArrayIcon,eItemIconElement.Icon,"1800903100")
    SetSameAnchorAndPivot(battleArrayIcon, UILayout.TopLeft)
    GUI.RegisterUIEvent(battleArrayIcon, UCE.PointerClick, "MapUI", "OnBattleArrayIconClick")


    local battleArrayName = GUI.CreateStatic(battleArrayIcon,"battleArrayName","四个字名" ,10,0,200, 40, "101", false, false)
    GUI.StaticSetAlignment(battleArrayName,TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(battleArrayName,25)
    SetAnchorAndPivot(battleArrayName, UIAnchor.TopRight, UIAroundPivot.TopLeft)
    GUI.SetColor(battleArrayName,UIDefine.Brown4Color)


    local scheduleGroup = GUI.ImageCreate(battleArrayIcon, "scheduleGroup", "1800001060", 10, 40,false,40,40,false)
    GUI.SetVisible(scheduleGroup,false)
    SetAnchorAndPivot(scheduleGroup, UIAnchor.TopRight, UIAroundPivot.TopLeft)

    local scheduleTxt = GUI.CreateStatic(scheduleGroup,"scheduleTxt","20%" ,0,0,60, 30, "101", false, false)
    GUI.StaticSetAlignment(scheduleTxt,TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(scheduleTxt,25)
    SetAnchorAndPivot(scheduleTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetColor(scheduleTxt,UIDefine.Brown4Color)


    local addScheduleTxt = GUI.CreateStatic(scheduleTxt,"addScheduleTxt","+30%" ,0,0,120, 30, "101", false, false)
    GUI.StaticSetAlignment(addScheduleTxt,TextAnchor.MiddleLeft)
    GUI.SetVisible(addScheduleTxt,false)
    GUI.StaticSetFontSize(addScheduleTxt,25)
    SetAnchorAndPivot(addScheduleTxt, UIAnchor.Right, UIAroundPivot.Left)
    GUI.SetColor(addScheduleTxt,UIDefine.GreenColor)


    local addY = 0
    for j = 1, 3 do

        addY = (j - 1) * 12 + 15

        local scaleValue = 1
        local addImg = GUI.ImageCreate(scheduleGroup, "addImg"..j, "1800607340", 105, addY)
        GUI.SetEulerAngles(addImg, Vector3.New(0, 0, 180))
        GUI.SetScale(addImg, Vector3.New(scaleValue, scaleValue, scaleValue))
        SetAnchorAndPivot(addImg, UIAnchor.TopRight, UIAroundPivot.TopLeft)

    end

    local accomplishTxt = GUI.CreateStatic(battleArrayIcon,"accomplishTxt","已完成" ,5,35,100, 30, "101", false, false)
    GUI.StaticSetAlignment(accomplishTxt,TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(accomplishTxt,22)
    SetAnchorAndPivot(accomplishTxt, UIAnchor.TopRight, UIAroundPivot.TopLeft)
    GUI.SetColor(accomplishTxt,UIDefine.RedColor)
    GUI.SetVisible(accomplishTxt,false)

    return groupBg

end

function MapUI.RefreshOccupyPlanLoopItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = MapUI.OccupyPlanLoopDataTable[index]

    if data then

        local battleArrayIcon = GUI.GetChild(item,"battleArrayIcon",false)
        GUI.SetData(battleArrayIcon,"index",index)

        GUI.ItemCtrlSetElementValue(battleArrayIcon,eItemIconElement.Icon,data.Icon)

        local battleArrayName = GUI.GetChild(battleArrayIcon,"battleArrayName",false)
        GUI.StaticSetText(battleArrayName,data.Name)

        if MapUI.OccupyPlanLoopDataTable[index] == nil then

            return

        end

        if MapUI.OccupyPlanLoopDataTable[index].Status == nil then

            MapUI.OccupyPlanLoopDataTable[index].Status = 0

        end
        MapUI.OccupyPlanLoopDataTable[index].Status = MapUI.OccupyPlanLoopDataTable[index].Status + 1

        test("MapUI.OccupyPlanLoopDataTable[index]",inspect(MapUI.OccupyPlanLoopDataTable[index]))

        local data = MapUI.OccupyPlanLoopDataTable[index]

        GUI.ItemCtrlSetElementValue(battleArrayIcon,eItemIconElement.Icon,data.Icon)

        local shelterImg = GUI.GetChild(battleArrayIcon,"shelterImg",false)

        GUI.SetHeight(shelterImg,55*(data.Rate/data.NeedP))

        local scheduleGroup = GUI.GetChild(battleArrayIcon,"scheduleGroup",false)

        local accomplishTxt = GUI.GetChild(battleArrayIcon,"accomplishTxt",false)



        if data.Rate >= data.NeedP then

            GUI.SetVisible(accomplishTxt,true)
            GUI.SetVisible(scheduleGroup,false)


        else

            GUI.SetVisible(accomplishTxt,false)
            GUI.SetVisible(scheduleGroup,true)

            local scheduleTxt = GUI.GetChild(scheduleGroup,"scheduleTxt",false)

            if data.Add == 0 then

                GUI.StaticSetText(scheduleTxt,(data.Rate/data.NeedP*100).."%")

                for i = 1, 3 do

                    local addImg = GUI.GetChild(scheduleGroup,"addImg"..i,false)


                    GUI.SetVisible(addImg,i <= data.Gear)
                end

            else


                local addScheduleTxt = GUI.GetChild(scheduleTxt,"addScheduleTxt",false)


                if data.Status == 6 then

                    GUI.StaticSetText(scheduleTxt,(data.Rate/data.NeedP*100).."%")


                    MapUI.OccupyPlanLoopDataTable[index].Status = 0

                    for i = 1, 3 do

                        local addImg = GUI.GetChild(scheduleGroup,"addImg"..i,false)

                        GUI.SetVisible(addImg,i <= data.Gear)

                    end

                    MapUI.StopCrossServerWarfareTimer(guid)

                else

                    GUI.StaticSetText(scheduleTxt,((data.Rate-data.Add)/data.NeedP*100).."%")

                    GUI.StaticSetText(addScheduleTxt,"+"..(data.Add/data.NeedP*100).."%")

                    for i = 1, 3 do

                        local addImg = GUI.GetChild(scheduleGroup,"addImg"..i,false)

                        GUI.SetVisible(addImg,false)

                    end

                end

                local desPreferHeight = GUI.StaticGetLabelPreferWidth(scheduleTxt)
                GUI.SetWidth(scheduleTxt,desPreferHeight)
                test("desPreferHeight",desPreferHeight)
                GUI.SetVisible(addScheduleTxt,data.Status%2 == 1)


            end


        end

        MapUI.RefreshCrossServerWarfareNpcData(battleArrayIcon)

    end

end

function MapUI.RefreshCrossServerWarfareNpcData(parent)

    test("=====================================")
    local guid = tostring(GUI.GetGuid(parent))
    MapUI.StartCrossServerWarfareTimer(guid)

end

--计时器启动
function MapUI.StartCrossServerWarfareTimer(guid)

    local Guid = tostring(guid)
    local fun = function()
        MapUI.CrossServerWarfareTimerCallBack(Guid)
    end

    if MapUI.RefreshCrossServerWarfareTimer == nil then

        MapUI.RefreshCrossServerWarfareTimer = {}

    end

    if MapUI.RefreshCrossServerWarfareTimer[guid] == nil then

        MapUI.RefreshCrossServerWarfareTimer[guid] = Timer.New(fun, 0.5, -1)
        MapUI.RefreshCrossServerWarfareTimer[guid]:Start()

    end

end


--计时器调用函数
function MapUI.CrossServerWarfareTimerCallBack(guid)

    local battleArrayIcon = GUI.GetByGuid(guid)

    local index = tonumber(GUI.GetData(battleArrayIcon,"index"))

    if MapUI.OccupyPlanLoopDataTable[index] == nil then

        return

    end

    if MapUI.OccupyPlanLoopDataTable[index].Status == nil then

        MapUI.OccupyPlanLoopDataTable[index].Status = 0

    end
    MapUI.OccupyPlanLoopDataTable[index].Status = MapUI.OccupyPlanLoopDataTable[index].Status + 1

    test("MapUI.OccupyPlanLoopDataTable[index]",inspect(MapUI.OccupyPlanLoopDataTable[index]))

    local data = MapUI.OccupyPlanLoopDataTable[index]

    GUI.ItemCtrlSetElementValue(battleArrayIcon,eItemIconElement.Icon,data.Icon)

    local battleArrayName = GUI.GetChild(battleArrayIcon,"battleArrayName",false)
    GUI.StaticSetText(battleArrayName,data.Name)

    local shelterImg = GUI.GetChild(battleArrayIcon,"shelterImg",false)

    GUI.SetHeight(shelterImg,55*(data.Rate/data.NeedP))

    local scheduleGroup = GUI.GetChild(battleArrayIcon,"scheduleGroup",false)

    local accomplishTxt = GUI.GetChild(battleArrayIcon,"accomplishTxt",false)



    if data.Rate == data.NeedP then

        GUI.SetVisible(accomplishTxt,true)
        GUI.SetVisible(scheduleGroup,false)


    else

        GUI.SetVisible(accomplishTxt,false)
        GUI.SetVisible(scheduleGroup,true)

        local scheduleTxt = GUI.GetChild(scheduleGroup,"scheduleTxt",false)

        if data.Add == 0 then

            GUI.StaticSetText(scheduleTxt,(data.Rate/data.NeedP*100).."%")

            for i = 1, 3 do

                local addImg = GUI.GetChild(scheduleGroup,"addImg"..i,false)


                GUI.SetVisible(addImg,i <= data.Gear)
            end

        else


            local addScheduleTxt = GUI.GetChild(scheduleTxt,"addScheduleTxt",false)


            if data.Status == 6 then

                GUI.StaticSetText(scheduleTxt,(data.Rate/data.NeedP*100).."%")


                MapUI.OccupyPlanLoopDataTable[index].Status = 0

                for i = 1, 3 do

                    local addImg = GUI.GetChild(scheduleGroup,"addImg"..i,false)

                    GUI.SetVisible(addImg,i <= data.Gear)

                end

                MapUI.StopCrossServerWarfareTimer(guid)

            else

                GUI.StaticSetText(scheduleTxt,((data.Rate-data.Add)/data.NeedP*100).."%")

                GUI.StaticSetText(addScheduleTxt,"+"..(data.Add/data.NeedP*100).."%")

                for i = 1, 3 do

                    local addImg = GUI.GetChild(scheduleGroup,"addImg"..i,false)

                    GUI.SetVisible(addImg,false)

                end

            end

            local desPreferHeight = GUI.StaticGetLabelPreferWidth(scheduleTxt)
            GUI.SetWidth(scheduleTxt,desPreferHeight)
            GUI.SetVisible(addScheduleTxt,data.Status%2 == 1)


        end


    end

end

function MapUI.StopCrossServerWarfareTimer(guid)

    if MapUI.RefreshCrossServerWarfareTimer[guid]~=nil then

        MapUI.RefreshCrossServerWarfareTimer[guid]:Stop()
        MapUI.RefreshCrossServerWarfareTimer[guid] = nil

    end
end

function MapUI.CreateCrossServerWarfareFunctionItem()

    local crossServerWarfareFunctionLoop = _gt.GetUI("crossServerWarfareFunctionLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(crossServerWarfareFunctionLoop) + 1

    local contactItem = GUI.CheckBoxExCreate(crossServerWarfareFunctionLoop,"checkbox"..index, "1800800030", "1800800040", 1, 0,  false, 300, 100)
    GUI.CheckBoxExSetCheck(contactItem, false)
    GUI.SetAnchor(contactItem, UIAnchor.Top)
    GUI.SetPivot(contactItem, UIAroundPivot.Top)
    GUI.RegisterUIEvent(contactItem, UCE.PointerClick, "MapUI", "OnCrossServerWarfareFunctionBtnClick");

    local txt = GUI.CreateStatic(contactItem,"txt","" ,0,3,140, 40, "system", false, false)
    GUI.StaticSetFontSize(txt,22)
    GUI.SetColor(txt,UIDefine.Brown4Color)
    GUI.StaticSetAlignment(txt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(txt, UILayout.Center)

    return contactItem

end

function MapUI.RefreshCrossServerWarfareFunctionItem(parameter)

    parameter = string.split(parameter, "#")
    local guid = tostring(parameter[1])
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = MapUI.NewAct_CrossServerMapData[index]

    if data then

        local txt = GUI.GetChild(item,"txt",false)

        GUI.StaticSetText(txt,data.land_name)


        if lastSelectOccupyPlanItemGuid == nil then

            if index == 1 then

                GUI.CheckBoxExSetCheck(item, true)


                lastSelectOccupyPlanItemGuid = guid

                lastSelectOccupyPlanNpcGuid = tostring(data.npc_guid)

                MapUI.RefreshOccupyPlanLoopData(data.npc_guid)

            else

                GUI.CheckBoxExSetCheck(item, false)

            end

        else

            if guid == lastSelectOccupyPlanItemGuid then

                GUI.CheckBoxExSetCheck(item, true)

                MapUI.RefreshOccupyPlanLoopData(data.npc_guid)

                lastSelectOccupyPlanItemGuid = guid


            else


                GUI.CheckBoxExSetCheck(item, false)

            end


        end

    end

    GUI.SetData(item,"npcGuid",data.npc_guid)

end

function MapUI.OnCrossServerWarfareFunctionBtnClick(guid)

    local checkbox = GUI.GetByGuid(guid)

    local npcGuid = GUI.GetData(checkbox,"npcGuid")


    if tostring(guid) ~= lastSelectOccupyPlanItemGuid then


        test("lastSelectOccupyPlanItemGuid",lastSelectOccupyPlanItemGuid)
        test("guid",tostring(guid))

        if lastSelectOccupyPlanItemGuid ~= nil then

            local lastCheckBox = GUI.GetByGuid(lastSelectOccupyPlanItemGuid)

            GUI.CheckBoxExSetCheck(lastCheckBox, false)

        end

    end


    GUI.CheckBoxExSetCheck(checkbox, true)

    lastSelectOccupyPlanItemGuid = tostring(guid)

    lastSelectOccupyPlanNpcGuid = tostring(npcGuid)

    MapUI.RefreshOccupyPlanLoopData(npcGuid)

end

--查看领地占领进度
function MapUI.RefreshOccupyPlanLoopData(npcGuid)
    test("查看领地占领进度")

    test("MainUI.LandData",inspect(MainUI.LandData))

    test("npcGuid",npcGuid)

    if MainUI.LandData ~= nil and npcGuid ~= nil then

        MapUI.OccupyPlanLoopDataTable = {}

        if MainUI.LandData[npcGuid] ~= nil then

            local type = MainUI.LandData[npcGuid].type
            local index = MainUI.LandData[npcGuid].index
            local needP = MainUI.Act_CrossServerData.LandConfig[type][index].NeedP

            for i, v in pairs(MainUI.LandData[npcGuid].rate) do

                local temp = {
                    Icon = MainUI.Act_CrossServerData.CampBuff[i].Icon,
                    Name = MainUI.Act_CrossServerData.CampBuff[i].Name,
                    Rate = v.rate,
                    Gear = v.gear,
                    Add = v.add,
                    npcGuid = tostring(npcGuid),
                    NeedP = needP,
                }

                table.insert(MapUI.OccupyPlanLoopDataTable,temp)
            end

            test("MapUI.OccupyPlanLoopDataTable",inspect(MapUI.OccupyPlanLoopDataTable))

            local occupyPlanLoop = _gt.GetUI("occupyPlanLoop")
            GUI.LoopScrollRectSetTotalCount(occupyPlanLoop, #MapUI.OccupyPlanLoopDataTable)
            GUI.LoopScrollRectRefreshCells(occupyPlanLoop)

        end

    end


end

function MapUI.RefreshChickingAddressPoint(addPointList)
    local addPointGroup = _gt.GetUI("addPointGroup")
    local bornPointGroup = _gt.GetUI("bornPointGroup")
    GUI.SetVisible(addPointGroup,true)
    GUI.SetVisible(bornPointGroup,false)
    if addPointList then
        for name, value in pairs(TrackUI.Act_Chickings_Config.BornPoint) do
            local addPoint = GUI.GetChild(addPointGroup,name)
            local canUse = false
            for i = 1, #addPointList, 1 do
                if name == addPointList[i] then
                    canUse = true
                    break
                end
            end
            if canUse then
                GUI.SetColor(addPoint, UIDefine.Green3Color)
                GUI.SetOutLine_Color(addPoint, UIDefine.OutLine_GreenColor)
            else
                GUI.SetColor(addPoint, Color.New(241/255,241/255,241/255,178/255))
                GUI.SetOutLine_Color(addPoint, Color.New(87/255,87/255,87/255,255/255))
            end
        end
    end
end

function MapUI.RefreshBornText()
    local bornPointGroup = _gt.GetUI("bornPointGroup")
    local ChooseBorn = GUI.GetChild(bornPointGroup,"ChooseBorn")
    count = TrackUI.DynamicActivityMessage[3].sec
    if count <= 0 then
        if MapUI.ChooseBornPointCountDownTimer ~= nil then
            MapUI.ChooseBornPointCountDownTimer:Stop()
            MapUI.ChooseBornPointCountDownTimer = nil
        end
    end
    local text = count .. "秒之后比赛开始，请选择您的出生点"
    GUI.StaticSetText(ChooseBorn,text)
    if MapUI.ChooseBornPointCountDownTimer == nil then
        MapUI.ChooseBornPointCountDownTimer = Timer.New(MapUI.RefreshBornText,1,-1)
        MapUI.ChooseBornPointCountDownTimer:Start()
    end
end

function MapUI.RefreshBornPointCountDown()
    local addPointGroup = _gt.GetUI("addPointGroup")
    local bornPointGroup = _gt.GetUI("bornPointGroup")
    GUI.SetVisible(addPointGroup,false)
    GUI.SetVisible(bornPointGroup,true)
    MapUI.RefreshBornText()
end

function MapUI.CreateChickingBornPoint(miniMap)
    local bornPointGroup = GUI.GroupCreate(miniMap,"bornPointGroup",0,0,GUI.GetWidth(miniMap), GUI.GetHeight(miniMap))
    _gt.BindName(bornPointGroup,"bornPointGroup")
    local ChooseBorn = GUI.CreateStatic(bornPointGroup, "ChooseBorn", "xx秒之后比赛开始，请选择您的出生点", 0, -60, 900, 45,"100");
    SetSameAnchorAndPivot(ChooseBorn, UILayout.Top)
    GUI.StaticSetAlignment(ChooseBorn, TextAnchor.MiddleCenter);
    GUI.StaticSetFontSize(ChooseBorn, 40);

    for name, value in pairs(TrackUI.Act_Chickings_Config.BornPoint) do
        local x, y = MapUI.ConvertToMapPostion(value.PosX, value.PosY)
        local x = x - MapUI.miniMapW / 2;
        local y = y - MapUI.miniMapH / 2
        local bornBtn = GUI.ButtonCreate(bornPointGroup, name, "1800500050", x, y, Transition.ColorTint, "", 110, 90, false)
        SetSameAnchorAndPivot(bornBtn, UILayout.Center)
        GUI.SetColor(bornBtn, UIDefine.Transparent);
        GUI.RegisterUIEvent(bornBtn, UCE.PointerClick, "MapUI", "OnBornBtnClick")
        bornBtn:RegisterEvent(UCE.PointerDown)
        GUI.RegisterUIEvent(bornBtn, UCE.PointerDown, "MapUI", "OnBornBtnDown")
        bornBtn:RegisterEvent(UCE.PointerUp)
        GUI.RegisterUIEvent(bornBtn, UCE.PointerUp, "MapUI", "OnBornBtnUp")
        GUI.SetData(bornBtn,"BornPointName",name)
        local backImg = GUI.ImageCreate(bornBtn, "backImg", "1800500050", 0, 0, false, 120, 40)
        SetSameAnchorAndPivot(backImg, UILayout.Center)
        local bornPoint = GUI.CreateStatic(bornBtn, name, name, 0, 0, 200, 35);
        SetSameAnchorAndPivot(bornPoint, UILayout.Center)
        GUI.StaticSetAlignment(bornPoint, TextAnchor.MiddleCenter);
        GUI.StaticSetFontSize(bornPoint, UIDefine.FontSizeSS);
        GUI.SetColor(bornPoint, UIDefine.Green3Color)
    end
    GUI.SetVisible(bornPointGroup,false)
end

function MapUI.OnBornBtnDown(guid)
    local bornBtn = GUI.GetByGuid(guid)
    local data = TweenData.New();
    data.Type = GUITweenType.DOScale;
    data.Duration = 0.1;
    data.From = Vector3.New(1, 1, 1);
    data.To = Vector3.New(0.8, 0.8, 0.8);
    data.LoopType = UITweenerStyle.Once;
    GUI.DOTween(bornBtn, data);
end

function MapUI.OnBornBtnUp(guid)
    local bornBtn = GUI.GetByGuid(guid)
    GUI.StopTween(bornBtn, GUITweenType.DOScale)
    GUI.SetScale(bornBtn, Vector3.New(1, 1, 1))
end

function MapUI.OnBornBtnClick(guid)
    if TrackUI.DynamicActivityMessage.index == 3 then
        if TrackUI.ChooseBornPointName == nil then
            MapUI.CheckBornPointGuid = guid
            GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("是否选择", "选定出生点后将不能修改，是否选择？", "MapUI", "确定", "confirm1", "取消")
        else
            CL.SendNotify(NOTIFY.ShowBBMsg,"您已经选择出生点")
        end
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,"暂时还不能选择出生点")
    end
end

function MapUI.confirm1()
    local bornBtn = GUI.GetByGuid(MapUI.CheckBornPointGuid)
    local BornPointName = GUI.GetData(bornBtn,"BornPointName")
    local backImg = GUI.GetChild(bornBtn,"backImg")
    GUI.ImageSetImageID(backImg,"1800500060")
    test("选择"..BornPointName)
    TrackUI.ChooseBornPointName = BornPointName
    CL.SendNotify(NOTIFY.SubmitForm,"FormAct_Chikings","ChooseBorn",BornPointName)
end

function MapUI.CreateJumpPoint(miniMap)
    local ids = DB.GetJumpAllKey1s();
    for i = 0, ids.Count - 1 do
        local jumpDB = DB.GetOnceJumpByKey1(ids[i]);
        if jumpDB.FromMap == CL.GetCurrentMapKeyName() then
            local toMapDB = DB.GetOnceMapByKey2(jumpDB.ToMap);
            if toMapDB.Id ~= 0 then
                local x, z = MapUI.ConvertToMapPostion(jumpDB.FromLeft, jumpDB.FromTop)
                local jumpPoint = GUI.CreateStatic(miniMap, toMapDB.Name, toMapDB.Name, x, z, 200, 35);
                SetAnchorAndPivot(jumpPoint, UIAnchor.TopLeft, UIAroundPivot.Center);
                GUI.StaticSetAlignment(jumpPoint, TextAnchor.MiddleCenter);
                GUI.StaticSetFontSize(jumpPoint, UIDefine.FontSizeS);
                GUI.SetIsOutLine(jumpPoint, true)
                GUI.SetOutLine_Distance(jumpPoint, UIDefine.OutLineDistance)
                if toMapDB.LogicType == 1 then
                    GUI.SetColor(jumpPoint, UIDefine.Green3Color);
                    GUI.SetOutLine_Color(jumpPoint, UIDefine.OutLine_GreenColor)
                else
                    GUI.SetColor(jumpPoint, UIDefine.RedColor);
                    GUI.SetOutLine_Color(jumpPoint, UIDefine.OutLine_RedColor)
                end


                --调整位置，防止出边框
                local w = (20 * string.len(toMapDB.Name)) / 3
                local h = 24

                local padding = 15
                if x - w / 2 < padding then
                    GUI.SetPositionX(jumpPoint, w / 2 + padding)
                end

                if x + w / 2 > MapUI.miniMapW  - padding then
                    GUI.SetPositionX(jumpPoint, MapUI.miniMapW  - padding - w / 2)
                end

                if z - h / 2 < padding then
                    GUI.SetPositionY(jumpPoint, h / 2 + padding)
                end

                if z + h / 2 > MapUI.miniMapH - padding then
                    GUI.SetPositionY(jumpPoint, MapUI.miniMapH - padding - h / 2)
                end

            end
        end
    end

end

--逻辑坐标转地图坐标
function MapUI.ConvertToMapPostion(logicX, logicZ)

    local ratioX =logicX / MapUI.logicSizeX;
    local ratioZ =logicZ / MapUI.logicSizeZ;

    local x = math.floor(MapUI.miniMapW * ratioX)
    local y = math.floor(MapUI.miniMapH * ratioZ)

    return x,y
end

function MapUI.GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0;
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal);
    local nRet = nTemp / nDecimal;
    return nRet;
end

function MapUI.CreateMiniMap(wnd)
    local miniMapPage = GUI.GroupCreate(wnd, "miniMapPage", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd));
    _gt.BindName(miniMapPage, "miniMapPage");

    local miniMapBorder = GUI.ImageCreate(miniMapPage, "miniMapBorder", "1800500010", 0, 0, false, 500, 500)
    SetSameAnchorAndPivot(miniMapBorder, UILayout.Center)
    GUI.SetIsRaycastTarget(miniMapBorder, true)
    _gt.BindName(miniMapBorder, "miniMapBorder");

    local flyFlagBtn = GUI.ButtonCreate(miniMapBorder, "flyFlagBtn", "1800502060", -40, -170, Transition.ColorTint)
    SetAnchorAndPivot(flyFlagBtn, UIAnchor.BottomLeft, UIAroundPivot.Center)
    GUI.RegisterUIEvent(flyFlagBtn, UCE.PointerClick, "MapUI", "OnFlyFlagBtnClick")
    GUI.SetVisible(flyFlagBtn,false);

    local npcFindBtn = GUI.ButtonCreate(miniMapBorder, "npcFindBtn", "1800502020", -40, -100, Transition.ColorTint)
    SetAnchorAndPivot(npcFindBtn, UIAnchor.BottomLeft, UIAroundPivot.Center)
    GUI.RegisterUIEvent(npcFindBtn, UCE.PointerClick, "MapUI", "OnNpcFindBtnClick")

    local worldMapBtn = GUI.ButtonCreate(miniMapBorder, "worldMapBtn", "1800502010", -40, -30, Transition.ColorTint)
    SetAnchorAndPivot(worldMapBtn, UIAnchor.BottomLeft, UIAroundPivot.Center)
    GUI.RegisterUIEvent(worldMapBtn, UCE.PointerClick, "MapUI", "OnWorldMapBtnClick")

    local pathGroup = GUI.GroupCreate(miniMapPage, "pathGroup", 0, 0);
    SetSameAnchorAndPivot(pathGroup, UILayout.Center)
    _gt.BindName(pathGroup, "pathGroup");

    local pathGroup2 = GUI.GroupCreate(miniMapPage, "pathGroup2", 0, 0);
    SetSameAnchorAndPivot(pathGroup2, UILayout.Center)
    _gt.BindName(pathGroup2, "pathGroup2");

    local hostPoint = GUI.ImageCreate(pathGroup2, "hostPoint", "1800508030", 0, 0)
    SetAnchorAndPivot(hostPoint, UIAnchor.TopLeft, UIAroundPivot.Center)
    _gt.BindName(hostPoint, "hostPoint");

    local targetPoint = GUI.ImageCreate(pathGroup2, "targetPoint", "1800508010", 0, 0)
    SetAnchorAndPivot(targetPoint, UIAnchor.TopLeft, UIAroundPivot.Bottom)
    _gt.BindName(targetPoint, "targetPoint");
    GUI.SetVisible(targetPoint, false)

    local npcScrollBg = GUI.ImageCreate(pathGroup2, "npcScrollBg", "1800400290", 0, 0,false,290,550)
    SetAnchorAndPivot(npcScrollBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(npcScrollBg, "npcScrollBg");
    GUI.SetVisible(npcScrollBg, false)

    local npcScroll = GUI.LoopScrollRectCreate(npcScrollBg, "itemScroll", 2, 5, 286, 540,
            "MapUI", "CreateNpcItem", "MapUI", "RefreshNpcScroll", 0, false, Vector2.New(280, 90), 1, UIAroundPivot.Top, UIAnchor.Top);
    _gt.BindName(npcScroll, "npcScroll");


    local closeBtn = GUI.ButtonCreate(pathGroup2,"closeBtn", "1800502050", 0, 0,Transition.ColorTint);
    GUI.SetAnchor(closeBtn, UIAnchor.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "MapUI", "OnExit")
end

function MapUI.OnNpcFindBtnClick()

    local npcScrollBg = _gt.GetUI("npcScrollBg");
    GUI.SetVisible(npcScrollBg,not GUI.GetVisible(npcScrollBg));


    local npcScroll = _gt.GetUI("npcScroll");
    GUI.ScrollRectSetNormalizedPosition(npcScroll, Vector2.New(0, 0));
    GUI.LoopScrollRectSetTotalCount(npcScroll, #MapUI.npcKeyNames);
    GUI.LoopScrollRectRefreshCells(npcScroll);
end

function MapUI.CreateNpcItem()
    local npcScroll = GUI.GetByGuid(_gt.npcScroll);
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(npcScroll);
    local npcItem = GUI.ButtonCreate(npcScroll, "npcItem"..curCount, "1800700030", 0, 0, Transition.ColorTint)
    GUI.RegisterUIEvent(npcItem, UCE.PointerClick, "MapUI", "OnNpcItemClick");
    local icon = ItemIcon.Create(npcItem, "icon", 15, 2)
    SetSameAnchorAndPivot(icon,UILayout.Left);
    local nameText = GUI.CreateStatic(npcItem, "nameText", "name", 105, 0, 170, 40)
    GUI.SetColor(nameText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(nameText, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(nameText,UILayout.Left);
    return npcItem;
end


function MapUI.RefreshNpcScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local npcItem = GUI.GetByGuid(guid);

    local npcKeyName = MapUI.npcKeyNames[index+1];
    local npcDB =DB.GetOnceNpcByKey2(npcKeyName);

    GUI.SetData(npcItem,"NpcId",npcDB.Id);
    local icon = GUI.GetChild(npcItem,"icon");
    local nameText = GUI.GetChild(npcItem,"nameText");
    GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Icon, tostring(npcDB.Head));
    GUI.ItemCtrlSetElementRect(icon,eItemIconElement.Icon, 0,-1, 67, 67);

    GUI.StaticSetText(nameText,npcDB.Name)
end


function MapUI.OnNpcItemClick(guid)
    local npcItem = GUI.GetByGuid(guid);
    local npcId = GUI.GetData(npcItem,"NpcId");
    CL.StartMove(npcId);
    MapUI.OnExit();

end

function MapUI.CreateWorldMap(wnd)
    local worldMapPage = GUI.GroupCreate(wnd, "worldMapPage ", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd));
    _gt.BindName(worldMapPage, "worldMapPage");

    local worldMapBorder = GUI.ImageCreate(worldMapPage, "worldMapBorder", "1800500020", 0, 0, false)
    SetSameAnchorAndPivot(worldMapBorder, UILayout.Center)
    GUI.SetIsRaycastTarget(worldMapBorder, true)
    _gt.BindName(worldMapBorder, "worldMapBorder");

    local miniMapBtn = GUI.ButtonCreate(worldMapBorder, "currentMapBtn", "1800502030", -40, -30, Transition.ColorTint)
    SetAnchorAndPivot(miniMapBtn, UIAnchor.BottomLeft, UIAroundPivot.Center)
    GUI.RegisterUIEvent(miniMapBtn, UCE.PointerClick, "MapUI", "OnMiniMapBtnClick")

    local worldMap = GUI.ImageCreate(worldMapPage, "worldMap", "1800500030", 0, 0)
    SetSameAnchorAndPivot(worldMap, UILayout.Center)
    _gt.BindName(worldMap, "worldMap");

    local w = GUI.GetWidth(worldMap)
    local h = GUI.GetHeight(worldMap)
    GUI.SetWidth(worldMapBorder, w + worldMapBorderPadding * 2)
    GUI.SetHeight(worldMapBorder, h + worldMapBorderPadding * 2)

    MapUI.CreateSceneBtn(worldMap)

    local host = GUI.ImageCreate(worldMap, "host", "1800500040", 0, 0)
    SetAnchorAndPivot(host, UIAnchor.Center, UIAroundPivot.Bottom)
    _gt.BindName(host, "host");

    local icon = GUI.ImageCreate(host, "icon", "1900300010", 0, 0, false, 50, 50)
    SetSameAnchorAndPivot(icon, UILayout.Center)

    local closeBtn = GUI.ButtonCreate(worldMap,"closeBtn", "1800502040", 22, -22, Transition.ColorTint)
    GUI.SetAnchor(closeBtn, UIAnchor.TopRight)
    GUI.SetPivot(closeBtn, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "MapUI", "OnExit")
end

function MapUI.CreateSceneBtn(worldMap)
    local w = GUI.GetWidth(worldMap)
    local h = GUI.GetHeight(worldMap)

    local allMap = DB.GetMapAllKey1s()
    for i = 0, allMap.Count-1 do
        local mapId = allMap[i]
        local mapData = DB.GetOnceMapByKey1(mapId)
        if mapData.MapShow == 1 then --需要在大地图上显示的
            --test("mapid=====>"..allMap[i]..",MapName="..mapData.MapName..",X="..mapData.MapAxisX..",Y="..mapData.MapAxisY)

            local mapDB = mapData
            if mapDB.Id ~= 0 then
                local x = mapData.MapAxisX - w / 2;
                local y = mapData.MapAxisY - h / 2
                local sceneBtn = GUI.ButtonCreate(worldMap, mapData.KeyName, "1800500050", x, y, Transition.ColorTint, "", 110, 90, false)
                SetSameAnchorAndPivot(sceneBtn, UILayout.Center)
                GUI.SetColor(sceneBtn, UIDefine.Transparent);
                GUI.RegisterUIEvent(sceneBtn, UCE.PointerClick, "MapUI", "OnSceneBtnClick")
                sceneBtn:RegisterEvent(UCE.PointerDown)
                GUI.RegisterUIEvent(sceneBtn, UCE.PointerDown, "MapUI", "OnSceneBtnDown")
                sceneBtn:RegisterEvent(UCE.PointerUp)
                GUI.RegisterUIEvent(sceneBtn, UCE.PointerUp, "MapUI", "OnSceneBtnUp")
                GUI.SetData(sceneBtn,"KeyName",mapDB.KeyName)


                local fakeImage = GUI.ImageCreate(sceneBtn, "fakeImage", "1800500050", 0, 0, false, 120, 40)
                SetSameAnchorAndPivot(fakeImage, UILayout.Center)

                local name = GUI.CreateStatic(sceneBtn, mapDB.MapName, mapDB.MapName, 0, 0, 200, 35);
                SetSameAnchorAndPivot(name, UILayout.Center)
                GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter);
                GUI.StaticSetFontSize(name, UIDefine.FontSizeSS);
                GUI.SetColor(name, sceneTypeColor[mapDB.LogicType])
            end
        end
    end
end

function MapUI.OnSceneBtnDown(guid)
    local sceneBtn = GUI.GetByGuid(guid)
    local data = TweenData.New();
    data.Type = GUITweenType.DOScale;
    data.Duration = 0.1;
    data.From = Vector3.New(1, 1, 1);
    data.To = Vector3.New(0.8, 0.8, 0.8);
    data.LoopType = UITweenerStyle.Once;
    GUI.DOTween(sceneBtn, data);
end

function MapUI.OnSceneBtnUp(guid)
    local sceneBtn = GUI.GetByGuid(guid)
    GUI.StopTween(sceneBtn, GUITweenType.DOScale)
    GUI.SetScale(sceneBtn, Vector3.New(1, 1, 1))
end

function MapUI.OnSceneBtnClick(guid)
    local RoleAttrIsAutoGame = CL.GetIntAttr(RoleAttr.RoleAttrIsAutoGame)
    if RoleAttrIsAutoGame == 1 then
        CL.SendNotify(NOTIFY.ShowBBMsg,"当前正在辅助中，无法移动")
        return
    end

    local sceneBtn = GUI.GetByGuid(guid)
    _gt.BindName(sceneBtn, "pressSceneBtn");
    GUI.StopTween(sceneBtn, GUITweenType.DOScale)
    GUI.SetScale(sceneBtn, Vector3.New(1, 1, 1))

    local keyName = GUI.GetData(sceneBtn,"KeyName");

    print("OnSceneBtnClick:"..keyName)
    CL.StopMove()
    CL.SendNotify(NOTIFY.SubmitForm, "FormTransfer", "Jump_ByWorldMap", keyName, 0)

    MapUI.OnExit()
end




