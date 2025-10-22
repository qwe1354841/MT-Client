local BourseRecordUI = {}
_G.BourseRecordUI = BourseRecordUI


local _gt = UILayout.NewGUIDUtilTable();

function BourseRecordUI.Main(parameter)
  _gt = UILayout.NewGUIDUtilTable();
  local wnd = GUI.WndCreateWnd("BourseRecordUI", "BourseRecordUI", 0, 0);

  local panelBg=UILayout.CreateFrame_WndStyle2(wnd,"交易记录",700,500,"BourseRecordUI","OnExit")

  local scrBg = GUI.ImageCreate(panelBg,"scrBg","1800400200",0,15,false ,670 ,420);

  local infoScr =  GUI.LoopScrollRectCreate(scrBg, "infoScr", 0, 0, 650, 400,
      "BourseRecordUI", "CreateInfoItem", "BourseRecordUI", "RefreshInfoScroll", 0, false, Vector2.New(640, 65), 1, UIAroundPivot.Top, UIAnchor.Top);
  GUI.ScrollRectSetChildSpacing(infoScr, Vector2.New(3, 3));
  _gt.BindName(infoScr, "infoScr");

end

function BourseRecordUI.CreateInfoItem()
  local infoScr = _gt.GetUI("infoScr")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(infoScr);

  local infoItem =   GUI.GroupCreate(infoScr,"infoItem"..curCount,0,0,0,0);

  local icon = GUI.ImageCreate(infoItem,"icon", "1800408360", 0, 2)
  UILayout.SetSameAnchorAndPivot(icon, UILayout.TopLeft);

  local text = GUI.CreateStatic(infoItem, "text", "", 35, 0, 600, 65,"system",true);
  GUI.SetColor(text, UIDefine.BrownColor);
  GUI.StaticSetFontSize(text, UIDefine.FontSizeL);
  GUI.StaticSetAlignment(text, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(text, UILayout.Left);

  return infoItem;
end


function BourseRecordUI.RefreshInfoScroll(parameter)
  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2]);
  local infoItem = GUI.GetByGuid(guid);
  local text = GUI.GetChild(infoItem,"text");

  index = index+1;
  if index>#BourseRecordUI.recordInfo then
    return;
  end

  GUI.StaticSetText(text,BourseRecordUI.recordInfo[#BourseRecordUI.recordInfo-index+1]);
end


function BourseRecordUI.OnShow()
  local wnd = GUI.GetWnd("BourseRecordUI");
  if wnd == nil then
    return ;
  end

  GUI.SetVisible(wnd, true);
end

function BourseRecordUI.SetContent(str)

  BourseRecordUI.recordInfo = loadstring("return " .. str)();
  local infoScr = _gt.GetUI("infoScr");
  GUI.LoopScrollRectSetTotalCount(infoScr, #BourseRecordUI.recordInfo);
  GUI.LoopScrollRectRefreshCells(infoScr);
end


function BourseRecordUI.OnExit()
  GUI.CloseWnd("BourseRecordUI");
end