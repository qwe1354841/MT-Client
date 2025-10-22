--这是副本确认UI界面
local InstanceConfirmUI={}
_G.InstanceConfirmUI=InstanceConfirmUI
local _gt=UILayout.NewGUIDUtilTable()
---------------------------------缓存需要的全局变量Start------------------------------
local GUI=GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot=UILayout.SetSameAnchorAndPivot
local inspect = require("inspect")   --测试用的
---------------------------------缓存需要的全局变量End-------------------------------
----------------------------------变量Start---------------------------------------
InstanceConfirmUI.MemberInfos=nil
InstanceConfirmUI.TeamInfos=nil
InstanceConfirmUI.RoleEffectIDs = {-1,-1,-1,-1,-1}   --角色的特效id
InstanceConfirmUI.LastTick=0
local MaxTeammateAmount = 5  --队伍最多人员数
--InstanceConfirmUI.CountDownTime = 30     --倒数时间

local RoleNumPic = {"1800605010","1800605020","1800605030","1800605040","1800605050"}


----------------------------------变量End-----------------------------------------

function InstanceConfirmUI.Main()
    _gt=UILayout.NewGUIDUtilTable()
    local panel=GUI.WndCreateWnd("InstanceConfirmUI","InstanceConfirmUI",0,0,eCanvasGroup.Normal)
    SetAnchorAndPivot(panel,UIAnchor.Center,UIAroundPivot.Center)
    local panelBg=UILayout.CreateFrame_WndStyle0_WithoutCloseBtn(panel,"副本进入确认","InstanceConfirmUI",_gt)

	if not GlobalProcessing.InstanceConfirmUICountDownTime then
		GlobalProcessing.InstanceConfirmUICountDownTime = 30
	end
    --右上角的装饰
    local decorationGroup=  GUI.GroupCreate(panelBg,"decorationGroup",560,-3,50,100)
    local bottomBg = GUI.ImageCreate(decorationGroup, "bottomBg", "1801305030", 0,  10)
    local intervalSp = GUI.ImageCreate(decorationGroup, "intervalSp", "1801305010", 0, 0, false, 17, 100)
    SetSameAnchorAndPivot(decorationGroup, UILayout.Top)
    SetAnchorAndPivot(bottomBg, UIAnchor.Top, UIAroundPivot.Top)
    SetSameAnchorAndPivot(intervalSp, UILayout.Top)

    InstanceConfirmUI.Content()

    GUI.SetVisible(panel,false)
end

function InstanceConfirmUI.InitData()
    InstanceConfirmUI.MemberInfos=nil
    InstanceConfirmUI.TeamInfos=nil
    InstanceConfirmUI.RoleEffectIDs = {-1,-1,-1,-1,-1}   --角色的特效id
    InstanceConfirmUI.LastTick=0
end

function InstanceConfirmUI.OnShow()
    local wnd=GUI.GetWnd("InstanceConfirmUI")
    if wnd==nil then
        return
    end
    GUI.SetVisible(wnd,true)

    CL.SendNotify(NOTIFY.SubmitForm, "FormDungeon", "GetReadyData")
end

function InstanceConfirmUI.OnExit()
    InstanceConfirmUI.OnDestroy()
end

function InstanceConfirmUI.OnClose()
    InstanceConfirmUI.InitData()
    local wnd=GUI.GetWnd("InstanceConfirmUI");
    GUI.SetVisible(wnd,false)
end
function InstanceConfirmUI.OnDestroy()
    InstanceConfirmUI.OnClose()
end
--刷新方法
function InstanceConfirmUI.Refresh()
    InstanceConfirmUI.LastTick=CL.GetServerTickCount()
    --队伍队列重新创建
    InstanceConfirmUI.ShowTeamList()
    local serverData=InstanceConfirmUI.Data
    local teamNum=InstanceConfirmUI.MemberInfos.Length
    for i = 1, teamNum do
        local roleNode=_gt.GetUI("roleNode"..i)
        local roleState=GUI.GetChild(roleNode,"roleState")
        local roleGuid=GUI.GetData(roleNode,"RoleGUID")
        for i, v in pairs(serverData) do
            if tostring(roleGuid)==tostring(i) and tonumber(v)==1 then
                GUI.ImageSetImageID(roleState,"1800604160")
                break
            else
                GUI.ImageSetImageID(roleState,"1800604170")
            end
        end
    end
    --如果玩家是队伍的队长 那么他就无法进行取消和确认按钮的点击
    local panelBg=_gt.GetUI("panelBg")
    local ConfirmBtn=GUI.GetChild(panelBg,"ConfirmBtn")
    local CancelBtn=GUI.GetChild(panelBg,"CancelBtn")
    local teamLeaderGuid=InstanceConfirmUI.TeamInfos.leader_guid

    --查询玩家自己的guid
    local curRoleGuid=LD.GetSelfGUID()

    if tostring(teamLeaderGuid)==tostring(curRoleGuid) then
        GUI.ButtonSetShowDisable(ConfirmBtn,false)
        GUI.ButtonSetShowDisable(CancelBtn,false)
    else
        GUI.ButtonSetShowDisable(ConfirmBtn,true)
        GUI.ButtonSetShowDisable(CancelBtn,true)
    end
    --刷新倒计时的滚动条
    InstanceConfirmUI.RefreshTimeSlider()
end

--------------------------------------------------布局Start-------------------------------------------------------------
--界面的主要内容
function InstanceConfirmUI.Content()

    local panelBg=_gt.GetUI("panelBg")

    local modelBg=GUI.ImageCreate(panelBg,"modelBg","1800400200",0,-18,false,1040,450)
    SetSameAnchorAndPivot(modelBg,UILayout.Center)
    _gt.BindName(modelBg,"modelBg")
    --倒计时
    InstanceConfirmUI.CountDown()
    --按钮

    --确认按钮
    local ConfirmBtn = GUI.ButtonCreate(panelBg, "ConfirmBtn", "1800102090", -80, -50, Transition.ColorTint, "<color=#ffffff><size=26>确认</size></color>", 160, 50, false);
    SetAnchorAndPivot(ConfirmBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetIsOutLine(ConfirmBtn,true);
    GUI.SetOutLine_Color(ConfirmBtn,Color.New(162/255,75/255,21/255));
    GUI.SetOutLine_Distance(ConfirmBtn,1);
    GUI.RegisterUIEvent(ConfirmBtn, UCE.PointerClick, "InstanceConfirmUI", "OnConfirmBtnClick")

    --取消按钮
    local CancelBtn = GUI.ButtonCreate(panelBg, "CancelBtn", "1800102090", -260, -50, Transition.ColorTint, "<color=#ffffff><size=26>取消</size></color>", 160, 50, false);
    SetAnchorAndPivot(CancelBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetIsOutLine(CancelBtn,true);
    GUI.SetOutLine_Color(CancelBtn,Color.New(162/255,75/255,21/255));
    GUI.SetOutLine_Distance(CancelBtn,1);
    GUI.RegisterUIEvent(CancelBtn, UCE.PointerClick, "InstanceConfirmUI", "OnCancelBtnClick")
end
--显示队伍列表
function InstanceConfirmUI.ShowTeamList()
    local modelBg=_gt.GetUI("modelBg")
    local teamInfo=LD.GetTeamInfo()

    local memberNum=0
    if tostring(teamInfo.team_guid)~="0" and teamInfo.members~=nil then
        memberNum=tonumber(teamInfo.members.Length)
    end
    if memberNum==0 then
        CDebug.LogError("队伍其他人数为0")
        return
    end
    InstanceConfirmUI.TeamInfos=teamInfo
    InstanceConfirmUI.MemberInfos=teamInfo.members
    for i = 1, MaxTeammateAmount do
        local roleNode=_gt.GetUI("roleNode"..i)
        if roleNode==nil then
            --底板
            roleNode=GUI.ImageCreate(modelBg,"roleNode"..i,"1800700050",4+(i-1)*206,4,false,208,440)
            _gt.BindName(roleNode,"roleNode"..i)
            SetSameAnchorAndPivot(roleNode,UILayout.TopLeft)

            --龙纹
            local backLight = GUI.ImageCreate( roleNode,"backLight", "1800400230", 0, -50, false, 176, 176)
            SetSameAnchorAndPivot(backLight,UILayout.Center)
            --队长标记
            if i==1 then
                local captainFlag=GUI.ImageCreate( roleNode,"captainFlag", "1800604010", 16, 15)
                SetSameAnchorAndPivot(captainFlag, UILayout.TopLeft)
            end

            --序号
            local number = GUI.ImageCreate( roleNode,"number", RoleNumPic[i], 72, 11)
            SetSameAnchorAndPivot(number, UILayout.Top)
            --脚底阴影
            local roleShadow = GUI.ImageCreate( roleNode,"roleShadow", "1800400240", 0, 60, false, 291, 94)
            SetSameAnchorAndPivot(roleShadow, UILayout.Center)
            --玩家名字
            local roleName = GUI.CreateStatic( roleNode,"roleName", "玩家名字", 0, 112, 190, 30, "system", false)
            SetSameAnchorAndPivot(roleName, UILayout.Center)
            GUI.StaticSetFontSize(roleName, 21)
            GUI.SetColor(roleName, UIDefine.BrownColor)
            GUI.StaticSetAlignment(roleName, TextAnchor.MiddleCenter)

            --门派
            local roleSchool = GUI.CreateStatic( roleNode,"roleSchool", "牛逼族", -7, 142, 200, 35)
            SetSameAnchorAndPivot(roleSchool, UILayout.Center)
            GUI.StaticSetFontSize(roleSchool, 20)
            GUI.SetColor(roleSchool, UIDefine.BrownColor)
            GUI.StaticSetAlignment(roleSchool, TextAnchor.MiddleCenter)

            --门派标记
            local schoolFlag = GUI.ImageCreate( roleNode,"schoolFlag", "1800102020", 29, -67, false, 25, 24)
           SetSameAnchorAndPivot(schoolFlag, UILayout.BottomLeft)

            --等级
            local roleLevel = GUI.CreateStatic( roleNode,"roleLevel", "69级", 90, 142, 100, 35)
            SetSameAnchorAndPivot(roleLevel, UILayout.Center)
            GUI.StaticSetFontSize(roleLevel, 20)
            GUI.SetColor(roleLevel, UIDefine.WhiteColor)
            GUI.SetIsOutLine(roleLevel,true)
            GUI.SetOutLine_Color(roleLevel,UIDefine.BlackColor)
            GUI.SetOutLine_Distance(roleLevel,1)
            GUI.StaticSetAlignment(roleLevel, TextAnchor.MiddleLeft)

            --vip等级
            local VipV = GUI.ImageCreate(roleNode, "vipV", "1801605010", 160,325, false, 18,15)
            local vipVNum1 = GUI.ImageCreate(roleNode, "vipVNum1", "1801605020", 173, 321, false, 15,20)
            local vipVNum2 = GUI.ImageCreate(roleNode, "vipVNum2", "1801605020", 185, 321, false, 15,20)
            GUI.SetVisible(vipVNum2,false)

            --状态信息   已确认/等待中
            local roleState=GUI.ImageCreate(roleNode,"roleState","1800604170",0,-20)
            SetSameAnchorAndPivot(roleState, UILayout.Bottom)
        end
    end

    --模型节点
    local roleLstNodeModelParent=_gt.GetUI("roleLstNodeModelParent")
    local roleLstNodeModel=_gt.GetUI("roleLstNodeModel")
    if roleLstNodeModelParent==nil then
        roleLstNodeModelParent= GUI.ImageCreate( modelBg,"roleLstNodeModelParent", "1800499999", -118, -85)
        _gt.BindName(roleLstNodeModelParent,"roleLstNodeModelParent")
        SetSameAnchorAndPivot(roleLstNodeModelParent,UILayout.TopLeft)

        if roleLstNodeModel==nil then
            roleLstNodeModel=GUI.RawImageCreate(roleLstNodeModelParent,false,"roleLstNodeModel","",0,0,4)
            _gt.BindName(roleLstNodeModel,"roleLstNodeModel")
            GUI.AddToCamera(roleLstNodeModel)
            GUI.RawImageSetCameraConfig(roleLstNodeModel, "(0,0,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,10,0.01,6.0,0");
        end
    end

    for i = 1, MaxTeammateAmount do
        local IsShow=(i<=memberNum)
        local roleNode=_gt.GetUI("roleNode"..i)
        local roleModel=_gt.GetUI("roleModel"..i)
        if roleNode then
           -- GUI.SetVisible(roleNode,IsShow)
            local roleName=GUI.GetChild(roleNode,"roleName")
            local roleSchool=GUI.GetChild(roleNode,"roleSchool")
            local schoolFlag=GUI.GetChild(roleNode,"schoolFlag")
            local roleLevel=GUI.GetChild(roleNode,"roleLevel")
            local VipV=GUI.GetChild(roleNode,"vipV")
            local vipVNum1=GUI.GetChild(roleNode,"vipVNum1")
            local vipVNum2=GUI.GetChild(roleNode,"vipVNum2")
            local roleState=GUI.GetChild(roleNode,"roleState")

            GUI.SetVisible(roleName,IsShow)
            GUI.SetVisible(roleSchool,IsShow)
            GUI.SetVisible(schoolFlag,IsShow)
            GUI.SetVisible(roleLevel,IsShow)
            GUI.SetVisible(VipV,IsShow)
            GUI.SetVisible(vipVNum1,IsShow)
            GUI.SetVisible(vipVNum2,IsShow)
            GUI.SetVisible(roleState,IsShow)
        end
        if roleModel then
            GUI.SetVisible(roleModel,IsShow)
        end
        if IsShow then
            --显示模型

            local ModelRoleID = 0
            local RoleName = ""
            local RoleReincarnation = 0
            local RoleLevel = 1
            local RoleSchoolFlag = "0"
            local SchoolName = ""
            local WeaponID = 0
            local RoleGUID = "-1"
            local RoleDB = nil
            local Gender = 0
            local Color1 = 0
            local Color2 = 0
            local Job = 0
            local WeaponEffect = 0
            local ModelID = 0

            --模型信息的数据收集
            if i<=memberNum then
                ModelRoleID = teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrRole)
                RoleDB = DB.GetRole(ModelRoleID)
                if RoleDB then
                    ModelID = RoleDB.Model
                end
                RoleName = InstanceConfirmUI.MemberInfos[i-1].name
                RoleReincarnation = teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrReincarnation)
                RoleLevel = teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrLevel)
                local itemID = teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrWeaponId)
                local config = DB.GetOnceItemByKey1(itemID)
                if config then
                    WeaponID = tonumber(tostring(config.ModelRole1))
                end
                RoleGUID = tostring(InstanceConfirmUI.MemberInfos[i-1].guid)

                Gender = teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrGender)
                Color1 = teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrColor1)
                Color2 = teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrColor2)
                WeaponEffect = teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrEffect1)
                Job = teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrJob1)
                local schoolConfig = DB.GetSchool(Job)
                if schoolConfig then
                    RoleSchoolFlag = tostring(schoolConfig.Icon)
                    SchoolName =  schoolConfig.Name
                end
            end
            GUI.SetData(roleNode,"RoleGUID",RoleGUID)
            --模型的创建
            if ModelID~=0 then
                --local roleModel=_gt.GetUI("roleModel"..i)
                local nowInfo=tostring(ModelID)..tostring(Color1)..tostring(Color2)..tostring(WeaponID)..tostring(Gender)..tostring(WeaponEffect)
                if roleModel==nil then
                    roleModel=GUI.RawImageChildCreate(roleLstNodeModel,false,"roleModel"..i,"",0,0)
                    _gt.BindName(roleModel,"roleModel"..i)
                    SetSameAnchorAndPivot(roleModel,UILayout.TopLeft)
                    ModelItem.BindRoleWithClothAndWind(roleModel, ModelID, Color1, Color2, eRoleMovement.STAND_W1, WeaponID, Gender, WeaponEffect, TOOLKIT.Str2uLong(RoleGUID))
                    ModelItem.BindRoleEquipGemEffect(roleModel, TOOLKIT.Str2uLong(RoleGUID), memberNum>0)
                    GUI.SetData(roleModel, "RoleModelID", nowInfo)
                    if InstanceConfirmUI.RoleEffectIDs[i] ~= -1 then
                        GUI.DestroyRoleEffect(roleModel, InstanceConfirmUI.RoleEffectIDs[i])
                        InstanceConfirmUI.RoleEffectIDs[i] = -1
                    end
                else
                    local roleModelInfo = GUI.GetData(roleModel, "RoleModelID")
                    GUI.SetVisible(roleModel, true)
                    if roleModelInfo ~= nowInfo then
                        if InstanceConfirmUI.RoleEffectIDs[i] ~= -1 then
                            GUI.DestroyRoleEffect(roleModel, InstanceConfirmUI.RoleEffectIDs[i])
                            InstanceConfirmUI.RoleEffectIDs[i] = -1
                        end
                        ModelItem.BindRoleWithClothAndWind(roleModel, ModelID, Color1, Color2, eRoleMovement.STAND_W1, WeaponID, Gender, WeaponEffect, TOOLKIT.Str2uLong(RoleGUID))
                        GUI.SetData(roleModel, "RoleModelID", nowInfo)
                    end
                    ModelItem.BindRoleEquipGemEffect(roleModel, TOOLKIT.Str2uLong(RoleGUID), memberNum>0)
                end

                GUI.SetLocalPosition(roleModel, 4.65-1.208*(i-1),3.03,-1)
                --模型的缩放
                GUI.SetLocalScale(roleModel,0.6,0.6,0.6)
                --InstanceConfirmUI.RoleModelLst[i] = roleModel
            end

            --姓名
            local roleName = GUI.GetChild(roleNode,"roleName")
            if roleName ~= nil then
                GUI.StaticSetText(roleName,RoleName)
            end

            --等级
            local roleLevel = GUI.GetChild(roleNode,"roleLevel")
            if roleLevel ~= nil then
                GUI.StaticSetText(roleLevel, tostring(RoleLevel).."级")
            end
            --门派标记
            local schoolFlag = GUI.GetChild(roleNode,"schoolFlag")
            if schoolFlag ~= nil then
                GUI.ImageSetImageID(schoolFlag,RoleSchoolFlag)
            end
            --门派名称
            local roleSchool = GUI.GetChild(roleNode,"roleSchool")
            if roleSchool ~= nil then
                GUI.StaticSetText(roleSchool,SchoolName)
            end
            --vip
            if i <= memberNum then
                local level = tonumber(teamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrVip))
                local VipNum1 = GUI.GetChild(roleNode,"vipVNum1",false)
                local VipNum2 = GUI.GetChild(roleNode,"vipVNum2",false)
                if level >= 10 then
                    if VipNum1 and VipNum2 then
                        local l = math.floor(level / 10)
                        if l > 9 then
                            l = 9
                        end
                        local h = level % 10
                        local tmp = { VipNum1, VipNum2 }
                        local picNum = { l, h }
                        local picbase = { 1801605020, 1801605020}
                        for i = 1, 2 do
                            local pic = picbase[i]
                            if picNum[i] then
                                pic = pic + picNum[i]
                            end
                            if i == 1 then
                                GUI.SetVisible(tmp[i], true)
                            elseif i == 2 then
                                local b = h >= 0
                                GUI.SetVisible(tmp[i], b)
                            else
                                GUI.SetVisible(tmp[i], true)
                            end
                            GUI.ImageSetImageID(tmp[i], tostring(pic))
                        end
                    end
                else
                    GUI.ImageSetImageID(VipNum1, tostring(1801605020+level))
					GUI.SetVisible(VipNum2, false)
                end
            end

        end
    end
end
--倒计时的创建
function InstanceConfirmUI.CountDown()
    local panelBg=_gt.GetUI("panelBg")
    local timeGroup=GUI.GroupCreate(panelBg,"timeGroup",85,-50,500,50)
    SetSameAnchorAndPivot(timeGroup,UILayout.BottomLeft)
    local timeLabel=GUI.CreateStatic(timeGroup,"timeLabel","确认倒计时",0,0,120,50,"system",false)
    GUI.StaticSetFontSize(timeLabel,UIDefine.FontSizeL)
    GUI.SetColor(timeLabel,UIDefine.BrownColor)
    local timeSlider = GUI.ScrollBarCreate(timeGroup, "timeSlider","","1800408160","1800408110",120,13,450,26,1,false, Transition.None, 0, 1,Direction.LeftToRight,false)
    local timeValue =Vector2.New(400,26)
    GUI.ScrollBarSetFillSize(timeSlider, timeValue)
    GUI.ScrollBarSetBgSize(timeSlider,timeValue)

    local timeText=GUI.CreateStatic(timeSlider,"timeText","00秒",0,0,100,50,"system",false)
    SetSameAnchorAndPivot(timeText,UILayout.Center)
    GUI.StaticSetFontSize(timeText,UIDefine.FontSizeL)
    GUI.SetColor(timeText,UIDefine.WhiteColor)

end

--刷新倒计时的滚动条
function InstanceConfirmUI.RefreshTimeSlider()
    if InstanceConfirmUI.GetCountDownInterval() < GlobalProcessing.InstanceConfirmUICountDownTime then

        local fun=function()
            local panelBg = _gt.GetUI("panelBg")
            local timeGroup = GUI.GetChild(panelBg,"timeGroup")
            local timeSlider = GUI.GetChild(timeGroup,"timeSlider")
            local timeText = GUI.GetChild(timeSlider,"timeText")

            if InstanceConfirmUI.GetCountDownInterval() < GlobalProcessing.InstanceConfirmUICountDownTime then
                GUI.StaticSetText(timeText,GlobalProcessing.InstanceConfirmUICountDownTime-InstanceConfirmUI.GetCountDownInterval().."秒")
                GUI.ScrollBarSetPos(timeSlider,1-(InstanceConfirmUI.GetCountDownInterval()/GlobalProcessing.InstanceConfirmUICountDownTime))
            else
                if InstanceConfirmUI.Timer~=nil then
                    InstanceConfirmUI.Timer:Stop()
                    InstanceConfirmUI.Timer=nil
                end
            end
        end

        if InstanceConfirmUI.Timer==nil then
            InstanceConfirmUI.Timer=Timer.New(fun,0.15,-1)
        else
            InstanceConfirmUI.Timer:Stop()
            InstanceConfirmUI.Timer:Reset(fun,1,-1)
        end

        InstanceConfirmUI.Timer:Start()
    end
end
function InstanceConfirmUI.GetCountDownInterval()
    return CL.GetServerTickCount() - InstanceConfirmUI.LastTick
end
--确认按钮点击方法
function InstanceConfirmUI.OnConfirmBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormDungeon", "ReadyTrue")
end
--取消按钮点击方法
function InstanceConfirmUI.OnCancelBtnClick()
    if InstanceConfirmUI.Timer~=nil then
        InstanceConfirmUI.Timer:Stop()
        InstanceConfirmUI.Timer=nil
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormDungeon", "ReadyFalse")
end

--------------------------------------------------布局End---------------------------------------------------------------
