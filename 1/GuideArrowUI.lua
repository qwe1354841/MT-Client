local GuideArrowUI = {}
_G.GuideArrowUI = GuideArrowUI

--指引箭头界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local _gt = UILayout.NewGUIDUtilTable()

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------


------------------------------------------Start 颜色配置 Start----------------------------------


----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------

local logicX = 0 --地图横坐标

local logicZ = 0 --地图纵坐标

--箭头图片ID
local ImageID = "1800208230"

--箭头重置旋转角度
local initRotate = 45

--箭头距离中心距离
local radiusLength = 260

--地点距离
local siteLength = -1

local siteIsInRange = false

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

local mapTable = {}

--移动监听事件表
local timeCallback = {
    move = nil,
    device = nil
}




--------------------------------------------End 表配置 End------------------------------------

function GuideArrowUI.Main(parameter)

    local panel = GUI.WndCreateWnd("GuideArrowUI" , "GuideArrowUI" , 0 , 0 ,eCanvasGroup.Lowest)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local guideArrowGroup = GUI.GroupCreate(panel,"guideArrowGroup", 0, 0, 400, 400,false)
    SetSameAnchorAndPivot(guideArrowGroup, UILayout.Center)
    _gt.BindName(guideArrowGroup,"guideArrowGroup")
    
end

function GuideArrowUI.OnShow(parameter)
    local wnd = GUI.GetWnd("GuideArrowUI");
    if wnd == nil then
        return
    end

    if parameter == nil then

        GUI.SetVisible(wnd, false)

        return

    else
        GuideArrowUI.Init()
        GUI.SetVisible(wnd, true)

    end

    local tableData = jsonUtil.decode(parameter);
    test("tableData",inspect(tableData))

    GuideArrowUI.RefreshAllData(tableData)

    CL.UnRegisterMessage(GM.MoveStart,'GuideArrowUI','OnMoveStart')
    CL.RegisterMessage(GM.MoveStart,'GuideArrowUI','OnMoveStart')

    CL.UnRegisterMessage(GM.MoveEnd,'GuideArrowUI','OnMoveEnd')
    CL.RegisterMessage(GM.MoveEnd,'GuideArrowUI','OnMoveEnd')


    CL.UnRegisterMessage(GM.FightStateNtf,'GuideArrowUI','InFightStatus')
    CL.RegisterMessage(GM.FightStateNtf,'GuideArrowUI','InFightStatus')
end

--进出战斗状态监听
function GuideArrowUI.InFightStatus(inFight, is_pvp, fightResult)
    fightResult = fightResult or 1
    local guideArrowGroup = _gt.GetUI("guideArrowGroup")
    if guideArrowGroup == nil then
        return
    end
    if type(inFight) ~= "boolean" then
        return
    end

    -- 判断是否处于观战中
    if inFight and CL.GetFightViewState() then
        --观战的时候，只开一个观战按钮
        GUI.SetVisible(guideArrowGroup, false)
    end

    if inFight then
        GUI.SetVisible(guideArrowGroup, false)
    else
        GUI.SetVisible(guideArrowGroup, true)

    end

    if not inFight and (fightResult == 1 or fightResult == 3) then
        -- 战斗结束，并且战斗失败，打开战斗欧失败界面
        local value = CL.GetIntCustomData("ACTIVITY_FAILESHEILD")
        if value ~= 1 then
            GUI.SetVisible(guideArrowGroup, true)
        end
    end
end

function GuideArrowUI.Init()

end

--服务器回调刷新
function GuideArrowUI.RefreshAllData(tableData)



    logicX, logicZ = CL.GetHostLogicX(), CL.GetHostLogicZ()

    if tableData.TrackPos == nil then
        GuideArrowUI.OnExit()
    end


    if tableData.ShowRange ~= nil then

        siteLength = tonumber(tableData.ShowRange)

    end


    mapTable = tableData.TrackPos

    GuideArrowUI.SetArrowImage()


end


--创建或刷新箭头图片
function GuideArrowUI.SetArrowImage()

    test("创建或刷新箭头图片")

    siteIsInRange = false

    local guideArrowGroup = _gt.GetUI("guideArrowGroup")

    local childNum = tonumber(GUI.GetChildCount(guideArrowGroup))

    local tableLength = #mapTable

    local num = math.max(childNum,tableLength)

    test("num",num)

    GUI.SetVisible(guideArrowGroup, true)

    for i = 1, num do

        local guideArrow = GUI.GetChild(guideArrowGroup,"guideArrow"..i,false)

        if i <= tableLength then

            if guideArrow == nil then

                guideArrow = GUI.ImageCreate(guideArrowGroup, "guideArrow"..i, ImageID, 0, 0)
                SetSameAnchorAndPivot(guideArrow, UILayout.Center)

            end

            GUI.SetVisible(guideArrow,true)

            GuideArrowUI.SetRotateAngle(guideArrow,mapTable[i][1],mapTable[i][2])

        else

            if guideArrow ~= nil then

                GUI.SetVisible(guideArrow,false)

            end


        end

    end

    --一定范围内调用的函数
    if type(GlobalProcessing.OutOfFunction) == "function" then

        GlobalProcessing.OutOfFunction(siteIsInRange)

    end

end

--角度计算(逆时针旋转的！！！！！）
function GuideArrowUI.SetRotateAngle(item,tableX,tableZ)
    test("计算角度")

    local x = -(logicX - tableX)

    local z = (logicZ - tableZ)

    local angle = (math.atan2(x,z)*180/math.pi) --math.pi是圆周率

    test("角度：",angle)

    GUI.SetEulerAngles(item,Vector3.New(30,0 , -(angle + initRotate))) --重置旋转

    local newRadiusLength = radiusLength

    local length = math.abs(1 / math.sin(math.rad(angle)) * x)

    test("length",length,type(length))


    if length <= siteLength then

        siteIsInRange = true

    end

    if length <= 40 then

        newRadiusLength = length*6

    end

    if length > 5 then

        GUI.SetVisible(item,true)
    else
        GUI.SetVisible(item,false)

    end

    local setHostLogicX = math.sin(math.rad(angle)) * newRadiusLength

    local setHostLogicZ = math.cos(math.rad(angle)) * newRadiusLength


    local sc = 1-setHostLogicZ*(0.1/radiusLength)
    GUI.SetScale(item, Vector3.New(sc,sc,sc))

    GUI.SetPositionX(item,setHostLogicX)

    GUI.SetPositionY(item,-setHostLogicZ)


end

--等待获得地图坐标
function GuideArrowUI.GetMapPos()

    while true do

        GuideArrowUI.BindMapData()

        coroutine.wait(0.5)

        test("等待获得地图坐标")

    end

end

--开始移动监听
function GuideArrowUI.OnMoveStart()

    if timeCallback.move == nil then

        test("开始移动监听")

        timeCallback.move = coroutine.start(GuideArrowUI.GetMapPos)

    end

end

--停止移动监听
function GuideArrowUI.OnMoveEnd()

    if timeCallback.move ~= nil then

        test("停止移动监听")

        coroutine.stop(timeCallback.move)

        timeCallback.move = nil

    end

    GuideArrowUI.BindMapData()

end

--获得当前地图坐标
function GuideArrowUI.BindMapData()

    test("获得当前地图坐标")

    logicX, logicZ = CL.GetHostLogicX(), CL.GetHostLogicZ()

    test("logicX",logicX)

    test("logicZ",logicZ)

    GuideArrowUI.SetArrowImage()

end


function GuideArrowUI.OnExit()

    CL.UnRegisterMessage(GM.MoveStart,'GuideArrowUI','OnMoveStart')
    CL.UnRegisterMessage(GM.MoveEnd,'GuideArrowUI','OnMoveEnd')

    GUI.CloseWnd("GuideArrowUI")

end