;-----------------------------------------------------------------------------------------------------------------------
;[!y] YouTube Music
;-----------------------------------------------------------------------------------------------------------------------
Current_Volume:
ListLines Off
SoundGet, currentVolume
If ((currentVolume = 0) AND (YTM_playing != 0))	;Pause YTM on Mute
	{
		WinGetTitle, YTM_title, ahk_class Chrome_WidgetWin_1 ahk_exe YouTube Music.exe

		if (RegExMatch(YTM_title, "- YouTube Music"))
			YTM_state := 1
		If (YTM_title == "YouTube Music")
			YTM_state := 0
		
		If (YTM_state = 1) {
			Send, ^+!{F10}
			YTM_playing := 0
			ToolTip("YTM Paused", "1000", "1920", "-1080")
		}
	}
	If ( ((currentVolume > 0) AND (YTM_playing == 0)))		;Unpause YTM on Unmute
		{	
			Send, ^+!{F10}
			YTM_playing := 1
			ToolTip("YTM Playing", "1000", "1920", "-1080")
	}
Return

RControl & RButton::
RControl & MButton::
	WinGetTitle, YTM_title, ahk_class Chrome_WidgetWin_1 ahk_exe YouTube Music.exe
	if (RegExMatch(YTM_title, "- YouTube Music"))
		ToolTip("YTM Paused", "1000", "1920", "-1080")
	If (YTM_title == "YouTube Music")
		ToolTip("YTM Playing", "1000", "1920", "-1080")
	sleep, 100
	Send, ^+!{F10}
Return

#If