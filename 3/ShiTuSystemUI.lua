ShiTuSystemUI = {}

_G.ShiTuSystemUI = ShiTuSystemUI
local _gt = UILayout.NewGUIDUtilTable();

ShiTuSystemUI.Guid1 = nil
ShiTuSystemUI.Guid2 = nil
ShiTuSystemUI.Type = 0 
ShiTuSystemUI.Name = nil
ShiTuSystemUI.ItemID = nil

function ShiTuSystemUI.Main(parameter)
	if parameter == nil then
		return
	end
	
	ShiTuSystemUI.SetData(parameter)

	_gt = UILayout.NewGUIDUtilTable()
	local wnd = GUI.WndCreateWnd("ShiTuSystemUI", "ShiTuSystemUI", 0, 0)
	GUI.SetVisible(panel, false)
    UILayout.SetAnchorAndPivot(wnd, UIAnchor.Center, UIAroundPivot.Center)
	local panel = GUI.ImageCreate(wnd,"panel","1800001120",0,0,false,460,260)
	UILayout.SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
	local flower = GUI.ImageCreate(panel,"flower","1800007060",-25,-25,true)
	UILayout.SetAnchorAndPivot(flower, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	local TitleBg = GUI.ImageCreate(panel,"TitleBg","1800001030",0,25,true) 
	UILayout.SetAnchorAndPivot(TitleBg, UIAnchor.Top, UIAroundPivot.Top)
	local Title= GUI.CreateStatic(TitleBg, "Title", "提示", 0, 4, 150, 30);
	GUI.SetColor(Title, UIDefine.White2Color)
	GUI.StaticSetFontSize(Title, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(Title, TextAnchor.MiddleCenter)
	
	local CloseBtn = GUI.ButtonCreate(panel,"CloseBtn","1800002050",-20,20,Transition.ColorTint,"",0,0,true)
	UILayout.SetAnchorAndPivot(CloseBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
	GUI.RegisterUIEvent(CloseBtn, UCE.PointerClick, "ShiTuSystemUI", "OnCloseBtnClick")
	
	local DetermineBtn = GUI.ButtonCreate(panel,"DetermineBtn","1800002060",130,90,Transition.ColorTint,"",0,0,true)
	UILayout.SetAnchorAndPivot(DetermineBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(DetermineBtn, UCE.PointerClick, "ShiTuSystemUI", "OnDetermineBtnClick")
	
    local DetermineBtnText = GUI.CreateStatic( DetermineBtn, "DetermineBtnText", "确定", 0, 0, 160, 50, "system", true)
    UILayout.SetAnchorAndPivot(DetermineBtnText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(DetermineBtnText,UIDefine.WhiteColor)
    GUI.StaticSetFontSize(DetermineBtnText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(DetermineBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(DetermineBtnText, true)
    GUI.SetOutLine_Color(DetermineBtnText,Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(DetermineBtnText,1)	
	
	local CancelBtn = GUI.ButtonCreate(panel,"CancelBtn","1800002060",-130,90,Transition.ColorTint,"",0,0,true)
	UILayout.SetAnchorAndPivot(CancelBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(CancelBtn, UCE.PointerClick, "ShiTuSystemUI", "OnCloseBtnClick")

    local CancelBtnText = GUI.CreateStatic( CancelBtn, "CancelBtnText", "取消", 0, 0, 160, 50, "system", true)
    UILayout.SetAnchorAndPivot(CancelBtnText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(CancelBtnText,UIDefine.WhiteColor)
    GUI.StaticSetFontSize(CancelBtnText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(CancelBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(CancelBtnText, true)
    GUI.SetOutLine_Color(CancelBtnText,Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(CancelBtnText,1)
	 
	if ShiTuSystemUI.Type == 1 then
		local MsgText = GUI.CreateStatic(panel, "MsgText", "是否拜<color=#42B1F0>"..ShiTuSystemUI.Name.."</color>为师呢？", 0, 0, 400, 100, "system", true)
		UILayout.SetAnchorAndPivot(MsgText, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetColor(MsgText,UIDefine.BrownColor)
		GUI.StaticSetFontSize(MsgText, UIDefine.FontSizeS)
		GUI.StaticSetAlignment(MsgText, TextAnchor.MiddleCenter)	
	elseif ShiTuSystemUI.Type == 2 then
		local MsgText = GUI.CreateStatic(panel, "MsgText", "是否与<color=#42B1F0>"..ShiTuSystemUI.Name.."</color>解除师徒关系？", 0, 0, 400, 100, "system", true)
		UILayout.SetAnchorAndPivot(MsgText, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetColor(MsgText,UIDefine.BrownColor)
		GUI.StaticSetFontSize(MsgText, UIDefine.FontSizeS)
		GUI.StaticSetAlignment(MsgText, TextAnchor.MiddleCenter)	
	elseif ShiTuSystemUI.Type == 3 then
		local itemDB = DB.GetOnceItemByKey1(ShiTuSystemUI.ItemID)
		local ItemIcon = GUI.ItemCtrlCreate(panel, "ItemIcon", "1801100120", 0, -20,70,70,false)
		local Num = tostring(LD.GetItemCountById(ShiTuSystemUI.ItemID))
		GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Icon,tostring(itemDB.Icon))
		GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Border,UIDefine.ItemIconBg2[itemDB.Grade])
		GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.RightBottomNum,Num.."/"..ShiTuSystemUI.CostNum)
		
		local MsgText = GUI.CreateStatic(panel, "MsgText", "是否消耗"..ShiTuSystemUI.CostNum.."个<color=#E855FF>"..itemDB.Name.."</color>解除你与<color=#46DC5F>"..ShiTuSystemUI.Name.."</color>的师徒关系？", 0, 45, 400, 100, "system", true)
		UILayout.SetAnchorAndPivot(MsgText, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetColor(MsgText,UIDefine.BrownColor)
		GUI.StaticSetFontSize(MsgText, UIDefine.FontSizeS)
		GUI.StaticSetAlignment(MsgText, TextAnchor.MiddleCenter)	
	
	elseif ShiTuSystemUI.Type == 4 then
		local itemDB = DB.GetOnceItemByKey1(ShiTuSystemUI.ItemID)
		local ItemIcon = GUI.ItemCtrlCreate(panel, "ItemIcon", "1801100120", 0, -20,70,70,false)
		local Num = tostring(LD.GetItemCountById(ShiTuSystemUI.ItemID))
		GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Icon,tostring(itemDB.Icon))
		GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Border,UIDefine.ItemIconBg2[itemDB.Grade])
		GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.RightBottomNum,Num.."/"..ShiTuSystemUI.CostNum)
		
		local MsgText = GUI.CreateStatic(panel, "MsgText", "是否消耗"..ShiTuSystemUI.CostNum.."个<color=#E855FF>"..itemDB.Name.."</color>解除你与<color=#46DC5F>"..ShiTuSystemUI.Name.."</color>的师徒关系？", 0, 45, 400, 100, "system", true)
		UILayout.SetAnchorAndPivot(MsgText, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetColor(MsgText,UIDefine.BrownColor)
		GUI.StaticSetFontSize(MsgText, UIDefine.FontSizeS)
		GUI.StaticSetAlignment(MsgText, TextAnchor.MiddleCenter)		
	end

end

function ShiTuSystemUI.OnShow(parameter)
    local Wnd = GUI.GetWnd("ShiTuSystemUI")
    if Wnd then
        GUI.SetVisible(Wnd, true)
    end
	-- ShiTuSystemUI.SetData(parameter)
	
end

function ShiTuSystemUI.SetData(parameter)
	parameter = string.split(parameter, "_")
	ShiTuSystemUI.Name = parameter[1];
	ShiTuSystemUI.Type = tonumber(parameter[2])
	ShiTuSystemUI.Guid1 = parameter[3]
	ShiTuSystemUI.Guid2 = parameter[4]
	ShiTuSystemUI.ItemID = tonumber(parameter[5])
	ShiTuSystemUI.CostNum = tostring(parameter[6])
end

--当点击确定时
function ShiTuSystemUI.OnDetermineBtnClick()
	--拜师
	if ShiTuSystemUI.Type == 1 then
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeacherPupilSystem", "BaiShi",ShiTuSystemUI.Guid1,ShiTuSystemUI.Guid2,1)
	--解除
	elseif ShiTuSystemUI.Type == 2 then
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeacherPupilSystem", "RelieveRelation",ShiTuSystemUI.Guid1,ShiTuSystemUI.Guid2,1)
	--逐出
	elseif ShiTuSystemUI.Type == 3 then
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeacherPupilSystem", "ConsumeItem",ShiTuSystemUI.Guid1,ShiTuSystemUI.Guid2,3)
	--判出
	elseif ShiTuSystemUI.Type == 4 then
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeacherPupilSystem", "ConsumeItem",ShiTuSystemUI.Guid1,ShiTuSystemUI.Guid2,4)
	end
	GUI.DestroyWnd("ShiTuSystemUI")
end

--当点击取消或关闭时
function ShiTuSystemUI.OnCloseBtnClick()
	if ShiTuSystemUI.Type == 1 then
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeacherPupilSystem", "BaiShi",ShiTuSystemUI.Guid1,ShiTuSystemUI.Guid2,2)
	--解除
	elseif ShiTuSystemUI.Type == 2 then
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeacherPupilSystem", "RelieveRelation",ShiTuSystemUI.Guid1,ShiTuSystemUI.Guid2,2)
	end
	GUI.DestroyWnd("ShiTuSystemUI")
end



