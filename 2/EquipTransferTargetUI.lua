local EquipTransferTargetUI = {}
_G.EquipTransferTargetUI = EquipTransferTargetUI
local _gt = UILayout.NewGUIDUtilTable()
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local colorYellow = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorBlue = Color.New(55 / 255, 160 / 255, 248 / 255, 255 / 255)
local RequestAfterEquipTable = {}
local AfterEquipTable = {}
local BeforeSubtype2 = nil
local LastCheckBoxGuid = nil
local AfterEquipKeyName = nil
local QualityRes =
{
  "1800400330","1800400100","1800400110","1800400120","1800400320"
}

function EquipTransferTargetUI.Main(parameter)

  local panel = GUI.WndCreateWnd("EquipTransferTargetUI", "EquipTransferTargetUI", 0, 0);
  GUI.SetAnchor(panel, UIAnchor.Center);
  GUI.SetPivot(panel, UIAroundPivot.Center);

  local panelBg = UILayout.CreateFrame_WndStyle2(panel, "选择目标武器", 900,550,"EquipTransferTargetUI", "OnExit",_gt)
  _gt.BindName(panelBg,"panelBg")

  GUI.ImageCreate(panelBg,"bg", "1800400200", 0, -10,  false, 860, 420)

  local equipScroll = GUI.LoopScrollRectCreate(
          panelBg,
          "equipScroll",
          0,
          65,
          840,
          400,
          "EquipTransferTargetUI",
          "CreateAfterEquip",
          "EquipTransferTargetUI",
          "RefreshAfterEquip",
          0,
          false,
          Vector2.New(280, 100),
          3,
          UIAroundPivot.Top,
          UIAnchor.Top,
          false
  )
  _gt.BindName(equipScroll,"equipScroll")
  GUI.SetAnchor(equipScroll,UIAnchor.Top)
  GUI.SetPivot(equipScroll,UIAroundPivot.Top)
  GUI.LoopScrollRectRefreshCells(equipScroll)

  local cancelBtn = GUI.ButtonCreate(panelBg,"cancelBtn", "1800402110", -200, 235,  Transition.ColorTint, "取消", 145, 50, false)
  GUI.ButtonSetTextFontSize(cancelBtn, 24);
  GUI.ButtonSetTextColor(cancelBtn, colorDark);
  GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick, "EquipTransferTargetUI", "OnExit")

  local confirmBtn = GUI.ButtonCreate(panelBg,"confirmBtn", "1800402110", 200, 235,  Transition.ColorTint, "确定", 145, 50, false);
  GUI.ButtonSetTextFontSize(confirmBtn, 24);
  GUI.ButtonSetTextColor(confirmBtn, colorDark)
  _gt.BindName(confirmBtn,"confirmBtn")
  GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "EquipTransferTargetUI", "OnConfirmBtnClick")
  GUI.ButtonSetShowDisable(confirmBtn, false)
end

function EquipTransferTargetUI.OnShow(parameter)
  local wnd = GUI.GetWnd("EquipTransferTargetUI")
  if wnd == nil then
    return
  end
  LastCheckBoxGuid = nil
  GUI.SetVisible(wnd,true)
end

function EquipTransferTargetUI.CreateAfterEquip()
  local equipScroll = _gt.GetUI("equipScroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(equipScroll) + 1
  local name = "contactItem"..curCount
  -- 背景
  local contactItem = GUI.CheckBoxExCreate(equipScroll,name, "1800800030", "1800800040", 1, 0,  false, 300, 100)
  GUI.SetAnchor(contactItem, UIAnchor.Top)
  GUI.SetPivot(contactItem, UIAroundPivot.Top)
  GUI.RegisterUIEvent(contactItem, UCE.PointerClick , "EquipTransferTargetUI", "OnEquipItemClick")

  -- iconBg
  local iconBg = GUI.ImageCreate(contactItem,"iconBg", QualityRes[1], 8, 10)
  GUI.SetAnchor(iconBg, UIAnchor.TopLeft)
  GUI.SetPivot(iconBg, UIAroundPivot.TopLeft)

  -- icon
  local icon = GUI.ImageCreate(iconBg,"icon", "1800707060", 0, 0,  false, 65, 65, false)
  GUI.SetAnchor(icon, UIAnchor.Center)
  GUI.SetPivot(icon, UIAroundPivot.Center)

  -- TopLeftIcon
  local TopLeftIcon = GUI.ImageCreate(icon,"TopLeftIcon", "1801104010", -5, -5,  false)
  GUI.SetAnchor(TopLeftIcon, UIAnchor.TopLeft)
  GUI.SetPivot(TopLeftIcon, UIAroundPivot.TopLeft)
  GUI.SetVisible(TopLeftIcon,false)

  --装备名字
  local EquipName = GUI.CreateStatic(contactItem,"EquipName", "装备名字", 60, -20, 180, 36, "system", true)
  GUI.SetColor(EquipName, colorDark)
  GUI.StaticSetFontSize(EquipName, 26)
  GUI.SetAnchor(EquipName, UIAnchor.Center)
  GUI.SetPivot(EquipName, UIAroundPivot.Center)
  GUI.StaticSetAlignment(EquipName,TextAnchor.MiddleLeft)

  --装备等级
  local EquipLevel = GUI.CreateStatic(contactItem,"EquipLevel", "120级", 20, -20, 100, 36, "system", true)
  GUI.SetColor(EquipLevel, colorYellow)
  GUI.StaticSetFontSize(EquipLevel, 24)
  GUI.SetAnchor(EquipLevel, UIAnchor.Bottom)
  GUI.SetPivot(EquipLevel, UIAroundPivot.Bottom)
  GUI.StaticSetAlignment(EquipLevel,TextAnchor.MiddleLeft)

  --装备类型
  local EquipType = GUI.CreateStatic(contactItem,"EquipType", "三个字", -10, -20, 130, 36, "system", true)
  GUI.SetColor(EquipType, colorYellow)
  GUI.StaticSetFontSize(EquipType, 24)
  GUI.SetAnchor(EquipType, UIAnchor.BottomRight)
  GUI.SetPivot(EquipType, UIAroundPivot.BottomRight)
  GUI.StaticSetAlignment(EquipType,TextAnchor.MiddleCenter)

  return contactItem
end

function EquipTransferTargetUI.RefreshAfterEquip(parameter)
  parameter = string.split(parameter , "#")
  local guid = parameter[1]
  local index = tonumber(parameter[2])+1
  local item=GUI.GetByGuid(guid)
  if not item then
    return
  end

  local IconBg = GUI.GetChild(item,"iconBg")
  local Icon = GUI.GetChild(IconBg,"icon")
  local TopLeftIcon = GUI.GetChild(Icon,"TopLeftIcon")
  local EquipName = GUI.GetChild(item,"EquipName")
  local EquipLevel = GUI.GetChild(item,"EquipLevel")
  local EquipType = GUI.GetChild(item,"EquipType")

  local data = AfterEquipTable[index]

  GUI.SetData(item,"AfterEquipKeyName",data.KeyName)
  GUI.ImageSetImageID(IconBg,QualityRes[tonumber(data.Grade)])
  GUI.ImageSetImageID(Icon,data.Icon)
  if data.SelfEquip then
    GUI.SetVisible(TopLeftIcon,true)
  else
    GUI.SetVisible(TopLeftIcon,false)
  end
  GUI.StaticSetText(EquipName,data.Name)
  if tostring(data.ShowType) == "★无级别★" then
    GUI.SetVisible(EquipLevel,false)
  else
    GUI.SetVisible(EquipLevel,true)
    GUI.StaticSetText(EquipLevel,data.Level.."级")
  end
  GUI.StaticSetText(EquipType,data.ShowType)

end

function EquipTransferTargetUI.OnEquipItemClick(guid)
  local CheckBox = GUI.GetByGuid(guid)
  if guid ~= nil then
    local ConfirmBtn = _gt.GetUI("confirmBtn")
    GUI.ButtonSetShowDisable(ConfirmBtn, true)
  end
  if LastCheckBoxGuid ~= nil then
    if tostring(guid) ~= tostring(LastCheckBoxGuid) then
      local LastCheckBox = GUI.GetByGuid(LastCheckBoxGuid)
      GUI.CheckBoxExSetCheck(LastCheckBox,false)
    end
  end
  AfterEquipKeyName = GUI.GetData(CheckBox,"AfterEquipKeyName")
  LastCheckBoxGuid = guid
  GUI.CheckBoxExSetCheck(CheckBox,true)
end

local TableSet = function(a,b)
  if a.Id ~= b.Id then
    return a.Id < b.Id
  end
  return false
end

function EquipTransferTargetUI.RefreshAfterEquipTable(parameter)
  RequestAfterEquipTable = EquipTransferTargetUI.AfterEquipTable
  local EquipBeforeKeyName = tostring(parameter)
  BeforeSubtype2 = DB.GetOnceItemByKey2(EquipBeforeKeyName).Subtype2
  AfterEquipTable = {}
  local SelfGuid = tonumber(CL.GetRoleTemplateID())
  for k, v in pairs(RequestAfterEquipTable) do
    local EquipDB= DB.GetOnceItemByKey2(k)
    local SelfEquip = false
    if tonumber(EquipDB.Role) == SelfGuid or tonumber(EquipDB.Role2)  == SelfGuid then
      SelfEquip = true
    else
      SelfEquip = false
    end
    local temp = {
      Id = EquipDB.Id,
      Grade = EquipDB.Grade,
      Icon = EquipDB.Icon,
      KeyName = EquipDB.KeyName,
      Level = EquipDB.Itemlevel,
      Name = EquipDB.Name,
      SelfEquip = SelfEquip,
      ShowType = EquipDB.ShowType,
      Type = tonumber(EquipDB.Type),
      SubType = tonumber(EquipDB.Subtype),
    }
    if tostring(BeforeSubtype2) ~= tostring(EquipDB.Subtype2) then
      AfterEquipTable[#AfterEquipTable + 1 ] = temp
    end
  end
  table.sort(AfterEquipTable, TableSet)
  EquipTransferTargetUI.RefreshEquipItems()
end

function EquipTransferTargetUI.RefreshEquipItems()
  local EquipScroll = _gt.GetUI("equipScroll")
  if  #AfterEquipTable > 0 then
    GUI.LoopScrollRectSetTotalCount(EquipScroll, #AfterEquipTable);
    GUI.LoopScrollRectRefreshCells(EquipScroll)
    GUI.ScrollRectSetNormalizedPosition(EquipScroll, Vector2.New(0, 0))
  else
    GUI.LoopScrollRectSetTotalCount(EquipScroll,0)
  end
end

function EquipTransferTargetUI.OnConfirmBtnClick()
  EquipTransferTargetUI.OnExit()
  local CheckBox = GUI.GetByGuid(LastCheckBoxGuid)
  GUI.CheckBoxExSetCheck(CheckBox,false)
  EquipTransferUI.SetAfterEquipId(AfterEquipKeyName)
end

function EquipTransferTargetUI.OnExit()
  if EquipTransferTargetUI.preEquipItemGuid ~= nil then
    local preEquipItem = GUI.GetByGuid(EquipTransferTargetUI.preEquipItemGuid)
    local selected = GUI.GetChild(preEquipItem, "selected");
    GUI.SetVisible(selected, false)
  end
  local CheckBox = GUI.GetByGuid(LastCheckBoxGuid)
  GUI.CheckBoxExSetCheck(CheckBox,false)
  GUI.CloseWnd("EquipTransferTargetUI")
end