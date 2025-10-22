WebFrameUI = {}

--是否横屏
WebFrameUI.IsLandscape = true

--入口函数
function WebFrameUI.Main( parameter )
	--创建窗口句柄
	local hWnd = GUI.WndCreateWnd("WebFrameUI" , "WebFrameUI" , 0 , 0, eCanvasGroup.TopMost)
	--获得窗口句柄的尺寸,实际上就是当前的屏幕尺寸
	local wndWidth = GUI.GetWidth(hWnd)
	local wndHeight = GUI.GetHeight(hWnd)

	--叠底
	local topBorder = GUI.ImageCreate(hWnd, "topBorder", "1800001050", 0, -50, false, wndWidth+150, wndHeight+150)
	GUI.SetAnchor(topBorder,UIAnchor.Top)
	GUI.SetPivot(topBorder,UIAroundPivot.Top)
	--关闭按钮
	local btnClose = GUI.ButtonCreate(hWnd,"1801502010", "1801502010",10,6,Transition.ColorTint)
	GUI.SetAnchor(btnClose,UIAnchor.TopLeft)
	GUI.SetPivot(btnClose,UIAroundPivot.TopLeft)
	GUI.RegisterUIEvent(btnClose , UCE.PointerClick , "WebFrameUI", "OnBtnClose" )
end

function WebFrameUI.OnShow( parameter )
	WebFrameUI.IsLandscape = tostring(parameter)~="0"
	CDebug.LogError("WebFrameUI.IsLandscape:"..tostring(WebFrameUI.IsLandscape))
	CL.SetScreenOrientation(WebFrameUI.IsLandscape)
end

function WebFrameUI.OnBtnClose()
	if not WebFrameUI.IsLandscape then
		CL.SetScreenOrientation(true)
	end
	CL.CloseWeb(0)
	GUI.DestroyWnd("WebFrameUI")
end
