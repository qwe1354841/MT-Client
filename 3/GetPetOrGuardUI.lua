local GetPetOrGuardUI = {}
_G.GetPetOrGuardUI = GetPetOrGuardUI

GetPetOrGuardUI.CurModelIndex = 1
GetPetOrGuardUI.AutoShowAnimationFlag = 1
GetPetOrGuardUI.ShowModelTimer = nil
GetPetOrGuardUI.data={}
GetPetOrGuardUI.isPlaying = false

--侍从类型
local guardType = {
  { "物攻", "1800707170" },
  { "法攻", "1800707180" },
  { "治疗", "1800707190" },
  { "控制", "1800707210" },
  { "辅助", "1800707200" },
  { "全部", "" },
}

local quality = {
  {"1800714050","1800400330"},
  {"1800714060","1800400100"},
  {"1800714070","1800400110"},
  {"1800714080","1800400120"},
  {"1800714080","1800400320"},
}

local _gt = UILayout.NewGUIDUtilTable()
function GetPetOrGuardUI.Main(parameter)
  test("==============main======")
  _gt = UILayout.NewGUIDUtilTable()
  local wnd = GUI.WndCreateWnd("GetPetOrGuardUI", "GetPetOrGuardUI", 0, 0)

  local panelCover = GUI.ImageCreate(wnd, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
  UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
  GUI.SetIsRaycastTarget(panelCover, true)
  panelCover:RegisterEvent(UCE.PointerClick)


  local panelBg = GUI.ImageCreate(wnd, "panelBg", "1800229060", 0, -15)
  UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)

  local title = GUI.ImageCreate(panelBg, "title", "1800205880", 0, 90)
  UILayout.SetSameAnchorAndPivot(title, UILayout.Top)
  _gt.BindName(title, "title")

  local model = GUI.RawImageCreate(panelBg, false, "model", "", 0, 110, 2, false, 550, 550)
  _gt.BindName(model, "model")
  model:RegisterEvent(UCE.Drag)
  GUI.AddToCamera(model)
  GUI.RawImageSetCameraConfig(model, "(1.65,1.3,2),(-0.04464257,0.9316535,-0.1226545,-0.3390941),True,5,0.01,1.25,1E-05")
  model:RegisterEvent(UCE.PointerClick)
  GUI.RegisterUIEvent(model, UCE.PointerClick, "GetPetOrGuardUI", "OnModelClick")

  local roleModel = GUI.RawImageChildCreate(model, true, "roleModel", "", 0, 0)
  _gt.BindName(roleModel, "roleModel")
  GUI.BindPrefabWithChild(model, GUI.GetGuid(roleModel))
  GUI.RegisterUIEvent(roleModel, ULE.AnimationCallBack, "GetPetOrGuardUI", "OnAnimationCallBack")

  local petGroup = GUI.GroupCreate(panelBg,"petGroup",0,0,0,0)
  _gt.BindName(petGroup, "petGroup")

  local petTypeLabel = GUI.ImageCreate(petGroup, "petTypeLabel", "1800704020", 240, -60)
  _gt.BindName(petTypeLabel, "petTypeLabel")
  
   --宠物显示升星上限
  for i = 1, 6 do
    local star=GUI.ImageCreate(petGroup,"PetstarPic"..tostring(i), "1801202192", -211, -173 + i*35, false,31,31)
    UILayout.SetSameAnchorAndPivot(star, UILayout.TopLeft)
    _gt.BindName(star, "PetstarPic"..tostring(i))
  end
  

  local guardGroup = GUI.GroupCreate(panelBg,"guardGroup",0,0,0,0)
  _gt.BindName(guardGroup, "guardGroup")

  local typeLabel = GUI.ImageCreate(guardGroup, "typeLabel", "1800704020", 198, -75)
  _gt.BindName(typeLabel, "typeLabel")
  local typeLabel2 = GUI.ImageCreate(guardGroup, "typeLabel2", "1800704020", 198, -125)
  _gt.BindName(typeLabel2, "typeLabel2")

  --显示升星上限
  for i = 1, 6 do
    local star=GUI.ImageCreate(guardGroup,"starPic"..tostring(i),"1801202192", -211, -173 + i*35, false,31,31)
    UILayout.SetSameAnchorAndPivot(star, UILayout.TopLeft)
    _gt.BindName(star, "starPic"..tostring(i))
  end

  local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800502050", 0,100,Transition.ColorTint,"",60,60,false)
  UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
  GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "GetPetOrGuardUI", "Next")

end

function GetPetOrGuardUI.OnShow(parameter)
  -- GetPetOrGuardUI.AutoShowAnimationFlag = 1
  -- GetPetOrGuardUI.CurModelIndex = 1
  -- GetPetOrGuardUI.data={}

  local wnd = GUI.GetWnd("GetPetOrGuardUI")
  if wnd == nil then
    return 
  end
  if CL.GetFightState() then
    GUI.SetVisible(wnd, false)
    return
  end
  test("OnshowOnshowOnshowOnshowOnshowOnshowOnshowOnshowOnshowOnshowOnshow")
  GUI.SetVisible(wnd, true)
end

function GetPetOrGuardUI.SetPetId(petId,star)
  if CL.GetFightState() then
    return
  end
  test("SetPetId=========>petId="..petId..",star="..star)
  --table.insert(GetPetOrGuardUI.data,{Type=1,Id=petId,starLevel = star})
  GetPetOrGuardUI.data[#GetPetOrGuardUI.data + 1] = {Type=1,Id=petId,starLevel = star}

  if #GetPetOrGuardUI.data>=1 then
    GetPetOrGuardUI.Show()
  end
end

function GetPetOrGuardUI.SetGuardId(guardId)
  test("SetGuardId=======>"..tostring(guardId))
  --table.insert(GetPetOrGuardUI.data,{Type=2,Id=guardId, starLevel=1})
  GetPetOrGuardUI.data[#GetPetOrGuardUI.data + 1] ={Type=2,Id=guardId, starLevel=1}

  test("#GetPetOrGuardUI.data="..#GetPetOrGuardUI.data)
  if #GetPetOrGuardUI.data>=1 then
    GetPetOrGuardUI.Show()
  end
end

function GetPetOrGuardUI.Show()
  if GetPetOrGuardUI.isPlaying == true then
    test("GetPetOrGuardUI.isPlaying  ,please wait!!! ")
      return
  end
  GetPetOrGuardUI.isPlaying = true

  -- if #GetPetOrGuardUI.data<=0 then
  --   GetPetOrGuardUI.OnExit()
  -- end

  local type = GetPetOrGuardUI.data[1].Type
  local id = GetPetOrGuardUI.data[1].Id
  local starLevel = GetPetOrGuardUI.data[1].starLevel
  
  local title =_gt.GetUI("title")
  local roleModel = _gt.GetUI("roleModel")
  local petGroup = _gt.GetUI("petGroup")
  local guardGroup = _gt.GetUI("guardGroup")
  GUI.SetVisible(petGroup,type==1)
  GUI.SetVisible(guardGroup,type==2)
  
  if type==1 then--获得宠物
    GUI.ImageSetImageID(title,"1800205880")
    local petDB = DB.GetOncePetByKey1(id)
    ModelItem.Bind(roleModel, tonumber(petDB.Model),tonumber(petDB.ColorId),0,eRoleMovement.ATTSTAND_W1)
    local petTypeLabel=_gt.GetUI("petTypeLabel")
    GUI.ImageSetImageID(petTypeLabel, UIDefine.PetType[petDB.Type])
    for i = 1 , 6 do
    local star = _gt.GetUI("PetstarPic"..tostring(i))
      if i <= starLevel then
        GUI.ImageSetImageID(star,"1801202190")
      else
        GUI.ImageSetImageID(star,"1801202192")
      end
    end
    GetPetOrGuardUI.AutoShowAnimation()
  elseif type==2 then--获得侍从
    local guardDB =DB.GetOnceGuardByKey1(id)
    local typeLabel = _gt.GetUI("typeLabel")
    local typeLabel2 = _gt.GetUI("typeLabel2")
    if guardDB and typeLabel and typeLabel2 then
      GUI.ImageSetImageID(typeLabel, guardType[guardDB.Type][2])
      GUI.ImageSetImageID(typeLabel2, quality[guardDB.Quality][1])
      GUI.ImageSetImageID(title,"1800204410")
      ModelItem.Bind(roleModel, tonumber(guardDB.Model),guardDB.ColorID1,guardDB.ColorID2,eRoleMovement.ATTSTAND_W1)
      GetPetOrGuardUI.AutoShowAnimation()
    end
    for i = 1 , 6 do
      local star = _gt.GetUI("starPic"..tostring(i))
      if i <= starLevel then
        GUI.ImageSetImageID(star,"1801202190")
      else
        GUI.ImageSetImageID(star,"1801202192")
      end
    end
  end
end

function GetPetOrGuardUI.AutoShowAnimation()
  if GetPetOrGuardUI.ShowModelTimer==nil then
    GetPetOrGuardUI.ShowModelTimer = Timer.New(GetPetOrGuardUI.AutoShowAnimationFunc, 1, 4)
    GetPetOrGuardUI.ShowModelTimer:Start()
  end
end

function GetPetOrGuardUI.AutoShowAnimationFunc()
  test("GetPetOrGuardUI.AutoShowAnimationFlag==>"..GetPetOrGuardUI.AutoShowAnimationFlag)
  --第2秒播放动作动画
  if GetPetOrGuardUI.AutoShowAnimationFlag == 2 then
    local type = GetPetOrGuardUI.data[1].Type
    local id = GetPetOrGuardUI.data[1].Id
    if type == 2 then
      local guardDB = DB.GetOnceGuardByKey1(id)
      GetPetOrGuardUI.OnPlayActionAnimation(tonumber(guardDB.Model),guardDB.ColorID1,guardDB.ColorID2)
    end
	
    --第4秒则关闭界面/或者显示下一个
  elseif GetPetOrGuardUI.AutoShowAnimationFlag == 4 then
    GetPetOrGuardUI.Next()
    return
  end
  GetPetOrGuardUI.AutoShowAnimationFlag = GetPetOrGuardUI.AutoShowAnimationFlag+1
end

function GetPetOrGuardUI.OnModelClick()
  if #GetPetOrGuardUI.data<=0 then
    return
  end

  local type = GetPetOrGuardUI.data[1].Type
  local id = GetPetOrGuardUI.data[1].Id

  local model = 0
  local color1 = 0
  local color2 = 0
  if type==1 then
    local petDB = DB.GetOncePetByKey1(id)
	color1 = tonumber(petDB.ColorId)
    model = tonumber(petDB.Model)
  elseif type==2 then
    --侍从显示不再接受点击，自动展示动作后结束播放
    --local guardDB =DB.GetOnceGuardByKey1(id)
    --ModelItem.Bind(roleModel, tonumber(guardDB.Model),guardDB.ColorID1,guardDB.ColorID2,movements[index])
  end

  GetPetOrGuardUI.OnPlayActionAnimation(model, color1, color2)
end

function GetPetOrGuardUI.OnPlayActionAnimation(model, color1, color2)
  if model ~= 0 then
    --math.randomseed(os.time())
    --local index = math.random(2)
    --local movements = { eRoleMovement.MAGIC_W1, eRoleMovement.MAGIC_W1 }

    local roleModel = _gt.GetUI("roleModel")
    ModelItem.Bind(roleModel, model,color1,color2,eRoleMovement.MAGIC_W1)
  end
end

function GetPetOrGuardUI.OnAnimationCallBack(guid, action)
  if #GetPetOrGuardUI.data<=0 then
    return
  end

  if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
    return
  end

  local type = GetPetOrGuardUI.data[1].Type
  local id = GetPetOrGuardUI.data[1].Id

  local roleModel = _gt.GetUI("roleModel")
  if type==1 then
    local petDB = DB.GetOncePetByKey1(id)
    ModelItem.Bind(roleModel, tonumber(petDB.Model),tonumber(petDB.ColorId),0,eRoleMovement.ATTSTAND_W1)
  elseif type==2 then
    local guardDB =DB.GetOnceGuardByKey1(id)
    ModelItem.Bind(roleModel, tonumber(guardDB.Model),guardDB.ColorID1,guardDB.ColorID2,eRoleMovement.ATTSTAND_W1)
  end
end

function GetPetOrGuardUI.Next()
  test("==========GetPetOrGuardUI.Next================")
  if GetPetOrGuardUI.ShowModelTimer ~= nil then
    GetPetOrGuardUI.ShowModelTimer:Stop()
    GetPetOrGuardUI.ShowModelTimer = nil
  end
  GetPetOrGuardUI.isPlaying = false
  GetPetOrGuardUI.AutoShowAnimationFlag = 1
  table.remove(GetPetOrGuardUI.data,1)
  if #GetPetOrGuardUI.data<=0 then
    GetPetOrGuardUI.OnExit()
  else
    --GetPetOrGuardUI.CurModelIndex = GetPetOrGuardUI.CurModelIndex + 1
    GetPetOrGuardUI.Show()
  end
end

function GetPetOrGuardUI.OnExit()
  GUI.DestroyWnd("GetPetOrGuardUI")
end

function GetPetOrGuardUI.OnDestroy()
  if GetPetOrGuardUI.ShowModelTimer ~= nil then
    GetPetOrGuardUI.ShowModelTimer:Stop()
    GetPetOrGuardUI.ShowModelTimer = nil
  end
  GetPetOrGuardUI.data={}
end