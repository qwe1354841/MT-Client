local RoleTransferConfirmUI = {}
_G.RoleTransferConfirmUI = RoleTransferConfirmUI
local _gt = UILayout.NewGUIDUtilTable()
local TransferSchoolId = 0
local TransferRoleId = 0
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local test = print
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local RandomNumber = 0

local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorYellow = Color.New(141 / 255, 93 / 255, 44 / 255, 255 / 255)
local colorRed = Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255)

function RoleTransferConfirmUI.Main(parameter)
  local panel = GUI.WndCreateWnd("RoleTransferConfirmUI" , "RoleTransferConfirmUI" , 0 , 0)
  GUI.SetAnchor(panel,UIAnchor.Center);
  GUI.SetPivot(panel,UIAroundPivot.Center);

  local panelBg=UILayout.CreateFrame_WndStyle2(panel,"转换确认",550,550,"RoleTransferConfirmUI","OnExit",_gt)


  GUI.ImageCreate(panelBg,"bg","1800400200",0,-50,false ,480 ,300);

  local text =GUI.CreateStatic(panelBg,"text", "你的门派与角色将进行如下转换：", 0, -165,  400, 35,"system",false,false)
  GUI.StaticSetFontSize(text, 24)
  GUI.SetColor(text, colorDark)
  GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)


  local currentRoleBg=GUI.ImageCreate(panelBg,"currentRoleBg", "1800201110",-105, -100, false,75,75)

  --箭头左边头像
  local LeftIcon = GUI.ImageCreate(currentRoleBg,"LeftIcon","3400400001",0, 0, false,65,65)
  _gt.BindName(LeftIcon,"LeftIcon")


  local schoolBg =  GUI.ImageCreate(panelBg,"schoolBg", "1801201180", -105, -20)
  local LeftSchoolIcon= GUI.ImageCreate(schoolBg,"LeftSchoolIcon","3400400001", -68, 0, false,50,50)
  _gt.BindName(LeftSchoolIcon,"LeftSchoolIcon")
  local LeftSchoolName =GUI.CreateStatic(schoolBg,"LeftSchoolName", "门派名", 50, 1,  160, 35);
  _gt.BindName(LeftSchoolName,"LeftSchoolName")
  GUI.StaticSetFontSize(LeftSchoolName, 26)
  GUI.SetColor(LeftSchoolName, colorDark)

  local roleBg =  GUI.ImageCreate(panelBg,"roleBg", "1801201180", -105, 45);
  local LeftRoleIcon= GUI.ImageCreate(roleBg,"LeftRoleIcon", "3400400001", -65, 0, false,50,50);
  _gt.BindName(LeftRoleIcon,"LeftRoleIcon")

  local LeftRoleName =GUI.CreateStatic(roleBg,"LeftRoleName", "角色名", 50, 1,  160, 35);
  GUI.StaticSetFontSize(LeftRoleName, 26)
  GUI.SetColor(LeftRoleName, colorDark)
  _gt.BindName(LeftRoleName,"LeftRoleName")


  GUI.ImageCreate(panelBg,"sprite", "1801208610",0, -100);


  local afterRoleBg=GUI.ImageCreate(panelBg,"afterRoleBg", "1800201110",105, -100, false,75,75)
  local RightIcon = GUI.ImageCreate(afterRoleBg,"RightIcon","3400400001",0, 0, false,65,65)
  _gt.BindName(RightIcon,"RightIcon")

  local schoolBg =  GUI.ImageCreate(panelBg,"schoolBg", "1801201180", 105, -20)
  local RightSchoolIcon= GUI.ImageCreate(schoolBg,"RightSchoolIcon","3400400001", -68, 0, false,50,50)
  _gt.BindName(RightSchoolIcon,"RightSchoolIcon")

  local RightSchoolName =GUI.CreateStatic(schoolBg, "RightSchoolName","门派名" , 50, 1, 160, 35)
  GUI.StaticSetFontSize(RightSchoolName, 26)
  GUI.SetColor(RightSchoolName, colorDark)
  _gt.BindName(RightSchoolName,"RightSchoolName")

  local roleBg =  GUI.ImageCreate(panelBg,"roleBg", "1801201180", 105, 45);
  local RightRoleIcon= GUI.ImageCreate(roleBg,"RightRoleIcon", "3400400001", -65, 0, false,50,50);
  _gt.BindName(RightRoleIcon,"RightRoleIcon")

  local RightRoleName =GUI.CreateStatic(roleBg,"RightRoleName", "角色名", 50, 1,  160, 35);
  GUI.StaticSetFontSize(RightRoleName, 26)
  GUI.SetColor(RightRoleName, colorDark)
  _gt.BindName(RightRoleName,"RightRoleName")

  local text =GUI.CreateStatic(panelBg,"text", "确定要进行角色与门派转换，请输入验证码：", 0, 125,  460, 35,"system",false,false);
  GUI.StaticSetFontSize(text, 22)
  GUI.SetColor(text, colorYellow);
  GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);

  math.randomseed(tostring(os.time()):reverse():sub(1, 7))
  RoleTransferConfirmUI.securityCode =tonumber(tostring(math.random(1,9))..tostring(math.random(1,9))..tostring(math.random(1,9))..tostring(math.random(1,9)))

  local securityCode =GUI.CreateStatic(panelBg,"securityCode",  "1234", -150, 175,  100, 35,"system",false,false)
  GUI.StaticSetFontSize(securityCode, 26)
  GUI.SetColor(securityCode, colorRed)
  _gt.BindName(securityCode,"securityCode")

  local securityCodeInput = GUI.EditCreate(panelBg,"securityCodeInput", "1800400390", "请输入验证码", 40, 176,  Transition.ColorTint, "system", 205, 44, 8, 8, InputType.Standard, ContentType.IntegerNumber)
  GUI.EditSetLabelAlignment(securityCodeInput, TextAnchor.MiddleCenter)
  GUI.EditSetTextColor(securityCodeInput, colorDark)
  GUI.EditSetFontSize(securityCodeInput, 22)
  GUI.EditSetMaxCharNum(securityCodeInput,4)
  GUI.EditSetBNumber(securityCodeInput,true)
  _gt.BindName(securityCodeInput,"securityCodeInput")
  GUI.RegisterUIEvent(securityCodeInput, UCE.EndEdit, "RoleTransferConfirmUI", "OnSecurityCodeInputEndEdit")

  local cancelBtn = GUI.ButtonCreate(panelBg,"cancelBtn", "1800402110", -150, 230,  Transition.ColorTint, "取消", 145, 50, false);
  GUI.ButtonSetTextFontSize(cancelBtn, 24);
  GUI.ButtonSetTextColor(cancelBtn, colorDark)
  GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick, "RoleTransferConfirmUI", "OnExit")


  local confirmBtn = GUI.ButtonCreate(panelBg,"recordBtn", "1800402110", 150, 230,  Transition.ColorTint, "确认", 145, 50, false);
  GUI.ButtonSetTextFontSize(confirmBtn, 24);
  GUI.ButtonSetTextColor(confirmBtn, colorDark);
  GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "RoleTransferConfirmUI", "OnConfirmBtnClick");

end

function RoleTransferConfirmUI.InitData()

end

function RoleTransferConfirmUI.OnShow(parameter)
  local wnd = GUI.GetWnd("RoleTransferConfirmUI");
  if wnd == nil then
    return
  end
  GUI.SetVisible(wnd, true)
  TransferSchoolId = tonumber(string.split(parameter, "#")[1])
  TransferRoleId = tonumber(string.split(parameter, "#")[2])
  GUI.SetVisible(GUI.GetWnd("RoleTransferConfirmUI"), true)
  local securityCodeInput = _gt.GetUI("securityCodeInput")
  local InputContent = GUI.EditSetTextM(securityCodeInput,"")

  RoleTransferConfirmUI.Refresh()
end

function RoleTransferConfirmUI.Refresh()

  --左边刷新设置
  local NowRoleData = DB.GetRole(CL.GetRoleTemplateID())
  local NowSchoolData = DB.GetSchool(CL.GetIntAttr(RoleAttr.RoleAttrJob1))
  --左边顶上头像
  local LeftIcon = _gt.GetUI("LeftIcon")
  GUI.ImageSetImageID(LeftIcon,tostring(NowRoleData.Head))
  --左边门派头像
  local LeftSchoolIcon = _gt.GetUI("LeftSchoolIcon")
  GUI.ImageSetImageID(LeftSchoolIcon,tostring(NowSchoolData.BigIcon))
  --左边门派名称
  local LeftSchoolName = _gt.GetUI("LeftSchoolName")
  GUI.StaticSetText(LeftSchoolName,tostring(NowSchoolData.Name))
  --左边角色头像
  local LeftRoleIcon = _gt.GetUI("LeftRoleIcon")
  GUI.ImageSetImageID(LeftRoleIcon,tostring(NowRoleData.Head))
  --左边角色名称
  local LeftRoleName = _gt.GetUI("LeftRoleName")
  GUI.StaticSetText(LeftRoleName,tostring(NowRoleData.RoleName))



  --右边刷新设置
  local TransferRoleData = DB.GetRole(TransferRoleId)
  local TransFerSchoolData = DB.GetSchool(TransferSchoolId)
  --右边顶上头像
  local RightIcon = _gt.GetUI("RightIcon")
  GUI.ImageSetImageID(RightIcon,tostring(TransferRoleData.Head))
  --右边门派头像
  local RightSchoolIcon = _gt.GetUI("RightSchoolIcon")
  GUI.ImageSetImageID(RightSchoolIcon,tostring(TransFerSchoolData.BigIcon))
  --右边门派名称
  local RightSchoolName = _gt.GetUI("RightSchoolName")
  GUI.StaticSetText(RightSchoolName,tostring(TransFerSchoolData.Name))
  --右边角色头像
  local RightRoleIcon = _gt.GetUI("RightRoleIcon")
  GUI.ImageSetImageID(RightRoleIcon,tostring(TransferRoleData.Head))
  --右边角色名称
  local RightRoleName = _gt.GetUI("RightRoleName")
  GUI.StaticSetText(RightRoleName,tostring(TransferRoleData.RoleName))

  --刷新验证码
  local securityCode = _gt.GetUI("securityCode")
  local RandomNum = math.random(0001,9999)
  if RandomNum < 1000 then
    RandomNum = RandomNum + 1000
  end
  GUI.StaticSetText(securityCode,RandomNum)
  RandomNumber = RandomNum
end

function RoleTransferConfirmUI.OnConfirmBtnClick()
  local securityCodeInput = _gt.GetUI("securityCodeInput")
  local InputContent = GUI.EditGetTextM(securityCodeInput)
  if  tonumber(InputContent) == RandomNumber then
    CL.SendNotify(NOTIFY.SubmitForm,"FormChangeOccu","StartChange",TransferSchoolId,TransferRoleId,1)
    GUI.EditSetTextM(securityCodeInput,"")
    GUI.CloseWnd("RoleTransferConfirmUI")
  else
    CL.SendNotify(NOTIFY.ShowBBMsg, "请输入正确的验证码")
  end
end


function RoleTransferConfirmUI.OnExit()
  GUI.CloseWnd("RoleTransferConfirmUI")
end


