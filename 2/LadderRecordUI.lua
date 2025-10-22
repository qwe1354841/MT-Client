local LadderRecordUI = {}
_G.LadderRecordUI = LadderRecordUI

local _gt = UILayout.NewGUIDUtilTable();
local HourToSecond = 60 * 60
local DayToSecond = 24 * HourToSecond
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot

function LadderRecordUI.Main(parameter)
  _gt = UILayout.NewGUIDUtilTable();
  local wnd = GUI.WndCreateWnd("LadderRecordUI", "LadderRecordUI", 0, 0);
  local panelBg=UILayout.CreateFrame_WndStyle2(wnd,"战  报",740,580,"LadderRecordUI","OnExit")

  local bg = GUI.ImageCreate(panelBg, "bg", "1800400200", 0, 20, false, 700, 500);
  UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)

  local scroll = GUI.LoopScrollRectCreate(bg, "scroll", 0, 0, 685, 485,
      "LadderRecordUI", "CreateItemPool", "LadderRecordUI", "RefreshScroll", 0, false,
      Vector2.New(685, 120), 1, UIAroundPivot.Top, UIAnchor.Top);
  UILayout.SetSameAnchorAndPivot(scroll, UILayout.Center);
  _gt.BindName(scroll, "scroll");

  local pnSellout = GUI.ImageCreate(bg, "pnSellout", "1801100010", 0, -20, false, 320, 100)
  _gt.BindName(pnSellout, "pnSellout")
  SetAnchorAndPivot(pnSellout, UIAnchor.Center, UIAroundPivot.Center)

  local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "您还未进行任何挑战", 0, 0, 320, 50, "system", true)
  SetAnchorAndPivot(txtSellout, UIAnchor.Center, UIAroundPivot.Center)
  GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
  GUI.StaticSetFontSize(txtSellout, 28)
  GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
  GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleCenter)
  GUI.SetVisible(pnSellout, false)

  CL.RegisterMessage(GM.FightStateNtf, "LadderRecordUI", "OnFightStateNtf");

end

function LadderRecordUI.OnShow(parameter)
  local wnd = GUI.GetWnd("LadderRecordUI")
  if wnd == nil then
    return
  end
  GUI.SetVisible(wnd, true)
end

function LadderRecordUI.OnFightStateNtf(inFight)
  if inFight then
    LadderRecordUI.OnExit();
  end
end

function LadderRecordUI.OnExit()
  GUI.DestroyWnd("LadderRecordUI");
end

function LadderRecordUI.SetData(data)
  local scroll = _gt.GetUI("scroll")
  LadderRecordUI.data=data;
  local pnSellout = _gt.GetUI("pnSellout")
  if next(data) then
    GUI.SetVisible(pnSellout,false)
    GUI.LoopScrollRectSetTotalCount(scroll, #data);
  else
    GUI.SetVisible(pnSellout,true)
    GUI.LoopScrollRectSetTotalCount(scroll, 0);
  end

  GUI.LoopScrollRectRefreshCells(scroll)
end


function LadderRecordUI.CreateItemPool()
  local scroll = _gt.GetUI("scroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll);
  local item =  GUI.ImageCreate(scroll, "item"..curCount, "1800600590", 0, 0);

  local nameBg =  GUI.ImageCreate(item, "nameBg", "1800600580", 18, -25,false,630,35);
  local img =  GUI.ImageCreate(nameBg, "img", "1800600570", 10, 0,false,128,45);
  local text = GUI.CreateStatic(img, "text", "挑战", 0, 1, 100, 30);
  GUI.SetColor(text, UIDefine.BrownColor);
  GUI.StaticSetFontSize(text, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);

  local name1 = GUI.CreateStatic(nameBg, "name1", "name1", -160, 1, 200, 30);
  GUI.SetColor(name1, UIDefine.RedColor);
  GUI.StaticSetFontSize(name1, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(name1, TextAnchor.MiddleCenter);

  local name2 = GUI.CreateStatic(nameBg, "name2", "name2", 180, 1, 200, 30);
  GUI.SetColor(name2, UIDefine.Green8Color);
  GUI.StaticSetFontSize(name2, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(name2, TextAnchor.MiddleCenter);

  local resultImg =  GUI.ImageCreate(item, "resultImg", "1800604280", -280, 0,false,110,110);


  local timeText = GUI.CreateStatic(item, "timeText", "time", -150, 28, 150, 30);
  GUI.SetColor(timeText, UIDefine.BrownColor);
  GUI.StaticSetFontSize(timeText, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(timeText, TextAnchor.MiddleCenter);

  local desText = GUI.CreateStatic(item, "desText", "des", 155, 28, 350, 30);
  GUI.SetColor(desText, UIDefine.BrownColor);
  GUI.StaticSetFontSize(desText, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(desText, TextAnchor.MiddleLeft);

  return item;
end

function LadderRecordUI.RefreshScroll(parameter)
  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2])+1;
  local item = GUI.GetByGuid(guid);
  local nameBg=GUI.GetChild(item,"nameBg")
  local name1=GUI.GetChild(nameBg,"name1")
  local name2=GUI.GetChild(nameBg,"name2")
  local resultImg=GUI.GetChild(item,"resultImg")
  local timeText=GUI.GetChild(item,"timeText")
  local desText=GUI.GetChild(item,"desText")

  if LadderRecordUI.data and LadderRecordUI.data[index] then
    local data= LadderRecordUI.data[index]
    GUI.StaticSetText(name1,data.InitiatorName)
    GUI.StaticSetText(name2,data.TargetName)
    local str = ""
    local rankStr = ""
    if data.iswin then
      GUI.ImageSetImageID(resultImg,"1800604280")
      str = "胜利"
      if data.Rank > 0 then
        rankStr = string.format("上升至%d", data.Rank)
      else
        rankStr = string.format("未发生变化")
      end
    else
      GUI.ImageSetImageID(resultImg,"1800604270")
      str = "失败"

      if data.Rank > 0 then
        rankStr = string.format("下降至%d", data.Rank)
      else
        rankStr = string.format("未发生变化")
      end
    end

    GUI.StaticSetText(timeText,LadderRecordUI.GetDateString(CL.GetServerTickCount()- data.time))
    GUI.StaticSetText(desText, string.format("战斗%s, 我的排名%s", str, rankStr))
  end
end

function LadderRecordUI.GetDateString(passTime)
  if passTime >= DayToSecond then
    return string.format("%d天前", math.floor(passTime / DayToSecond))
  elseif passTime >= HourToSecond then
    return string.format("%d小时前", math.floor(passTime / HourToSecond))
  elseif passTime >= 60 then
    return string.format("%d分钟前", math.floor(passTime / 60))
  end
  return string.format("%d秒前", passTime)
end