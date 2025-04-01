#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
SetTitleMatchMode Fast
DetectHiddenWindows On
DetectHiddenText On
#KeyHistory 0
#WinActivateForce
SetControlDelay -1
SetWinDelay -1
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1
#UseHook
#Persistent
#InstallKeybdHook
ListLines, Off
#MaxHotkeysPerInterval 200
Process, Priority,, H

RegRead, AHK_Path, HKLM\SOFTWARE\AutoHotkey, InstallDir
#Include %A_ScriptDir%\Lib\VD.ahk
StartTime := A_TickCount

menu, tray, add, Edit This Script, Edit_This_Script
menu, tray, Default, Edit This Script

global Desktop, sdToggle

global currentFanSpeed := 0

;SetTimer, Battery_Check, 1000
SetTimer, Current_Volume, 10
SoundBeep(10000, 200, 5)


If not A_IsAdmin
{
	; MsgBox, This Script needs to run as Admin for best performance... So do that!!
	Run *RunAs "%A_ScriptFullPath%"
}
; AHK_Groups
GroupAdd, game, Genshin Impact ahk_exe GenshinImpact.exe
GroupAdd, game, Wuthering Waves ahk_exe Client-Win64-Shipping.exe
GroupAdd, game, ZenlessZoneZero ahk_exe ZenlessZoneZero.exe
GroupAdd, game, Nox ahk_exe nox.exe
GroupAdd, game, ahk_class TXGuiFoundation ahk_exe AndroidEmulatorEn.exe
GroupAdd, game, Wuthering Waves ahk_exe Client-Win64-Shipping.exe
GroupAdd, teyvat_map, Teyvat Interactive Map
GroupAdd, game, ahk_exe VALORANT-Win64-Shipping.exe 
GroupAdd, teyvat_map, Enkanomiya
GroupAdd, teyvat_map, The Chasm

GroupAdd, anime, - AniMixPlay
GroupAdd, anime, - YugenAnime
GroupAdd, anime, 9Anime -
GroupAdd, anime, - mpv.net
ListLines, On

; Double click tray icon to edit script
Edit_This_Script:
EndTime := A_TickCount
If ((EndTime - StartTime) > 5000)
	Run, "Z:\Applications\Notepad++\notepad++.exe" %A_ScriptFullPath%
Return

; Custom SoundBeep
SoundBeep(Frequency, Duration, Volume) {
    SoundGet, MasterVolume
    SoundSet, Volume
	Sleep, 100
    SoundBeep, Frequency, Duration
	Sleep, 500
    SoundSet, MasterVolume
}

; Change Brightness and display brightness in a ToolTip
ChangeBrightness(change) {
	For property in ComObjGet( "winmgmts:\\.\root\WMI" ).ExecQuery( "SELECT * FROM WmiMonitorBrightness" )
		currentBrightness := property.CurrentBrightness
	If (currentBrightness + change) > 100
		changedBrightness := 100
	Else If (currentBrightness + change) < 0
		changedBrightness := 0
	Else
		changedBrightness := currentBrightness + change
	ToolTip("--------------" . changedBrightness . "--------------")
	Run, nircmd.exe changebrightness %change%
}

; Change Fan Speed and update the global variable
global timerRunning := false
ChangeFanSpeed(change) {
    global currentFanSpeed, timerRunning
    currentFanSpeed += change
	if (currentFanSpeed > 100) {
		currentFanSpeed := 100
	} else if (currentFanSpeed < 0) {
		currentFanSpeed := 0
	}

    ToolTip("🪟--------------" . currentFanSpeed . "--------------")
    
    if (timerRunning)
        SetTimer, ExecuteFanSpeedChange, Off
    timerRunning := true
    SetTimer, ExecuteFanSpeedChange, -1500
}
ExecuteFanSpeedChange:
    global currentFanSpeed, timerRunning
    strStdOut := StdOutStream("Z:\Tools\AsusFanControl\AsusFanControl.exe --get-fan-speeds --get-cpu-temp --set-fan-speeds=" . currentFanSpeed)
    ToolTip(strStdOut, 3000)
    timerRunning := false
return

; Create a auto hiding ToolTip at cursor location
ToolTip(text, time:=1000, ToolTip_X:=860, ToolTip_Y:=890) {
	CoordMode, Mouse, Screen
	If (ToolTip_X="") AND (ToolTip_Y="")
		MouseGetPos, ToolTip_X, ToolTip_Y
	ToolTip, %text%, %ToolTip_X%, %ToolTip_Y%
	SetTimer, RemoveToolTip, -%time%
	Return
}
RemoveToolTip:
	ToolTip
return

; Resolve Resolution in a 16:9 display
; Warning: Incomplete implementation for display with resolution less than 1600x900
ResRes(posx, posy) {
	CoordMode, Mouse, Screen
	If ((A_ScreenWidth > 1600) AND (A_ScreenHeight > 900)) {
		posx := posx * (A_ScreenWidth / 1920.0)
		posy := posy * (A_ScreenHeight / 1080.0)
	} Else If ((A_ScreenWidth < 1600) OR (A_ScreenHeight < 900)) {
		posx := posx / (A_ScreenWidth / 1600.0)
		posy := posy / (A_ScreenHeight / 900.0)
	}
	Return (posx, posy)
}

; Check If fullscreen or not
Fullscreen() {
	WinGetPos,,, w, h, A
	return (w = A_ScreenWidth && h = A_ScreenHeight)
}

; Boss key
BossKey(title, path:="") {
	If (!WinExist(title) And path != "")
		Run, %path%
	Else
	{
		IfWinActive, %title%
		{
			WinMinimize, %title%
			WinHide, %title%
		}Else {
			WinShow, %title%
			WinActivate, %title%
		}
	}
}

; Check whether a process is elevated
ProcessElevated(ProcessID)
{
    if !(hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", ProcessID, "ptr"))
        throw Exception("OpenProcess failed", -1)
    if !(DllCall("advapi32\OpenProcessToken", "ptr", hProcess, "uint", 0x0008, "ptr*", hToken))
        throw Exception("OpenProcessToken failed", -1), DllCall("CloseHandle", "ptr", hProcess)
    if !(DllCall("advapi32\GetTokenInformation", "ptr", hToken, "int", 20, "uint*", IsElevated, "uint", 4, "uint*", size))
        throw Exception("GetTokenInformation failed", -1), DllCall("CloseHandle", "ptr", hToken) && DllCall("CloseHandle", "ptr", hProcess)
    return IsElevated, DllCall("CloseHandle", "ptr", hToken) && DllCall("CloseHandle", "ptr", hProcess)
}

; Click in all resolutions
Click(x, y, z:=1) {
	x1 := x * (A_ScreenWidth / 1600.0)
	y2 := y * (A_ScreenHeight / 900.0)
	Click, %x1% %y2% %z%
}
; Sends a mouse button or mouse wheel event to a control in all resolutions
ControlClick(x, y, WinTitle, z:="LEFT", c:="1", opt:="") {		; ControlClick(X-Pos, Y-Pos, WinTitle, WhichButton, ClickCount, Options)
	x1 := x * (A_ScreenWidth / 1600.0)
	y2 := y * (A_ScreenHeight / 900.0)
	ControlClick, X%x1% Y%y1%, %WinTitle%,, %z%, %c%, %opt%
}

; Check whether process exists.
ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}

; Return path of active explorer window
GetActiveExplorerPath() {
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	if (explorerHwnd)
	{
		for window in ComObjCreate("Shell.Application").Windows {
			if (window.hwnd==explorerHwnd)
				return window.Document.Folder.Self.Path
		}
	}
}

#If WinExist("ahk_group teyvat_map")
CapsLock::BossKey("ahk_group teyvat_map")	;Teyvat Interactive Map
#If

; Discord-------------------------------
<!d::
+Numpad1::
+NumpadEnd::
!d_Discord:
	; IfWinNotExist, Discord ahk_class Chrome_WidgetWin_1
	; 	RunAsUser("C:\Users\Ainz\AppData\Local\Discord\Update.exe", "--processStart Discord.exe")
	; Else
		UltraBossKey("Discord", "ahk_class Chrome_WidgetWin_1 ahk_exe Legcord.exe", "shell:AppsFolder\app.legcord.Legcord", "d")
Return
;-----------------------------------------------------------------------------------------------------------------------
;[Alt+*] ULTRA BOSS KEY
;-----------------------------------------------------------------------------------------------------------------------
UltraBossKey(name, title, path, key) {
	IfWinNotExist, %title%
    {
		SplashTextOn, 250, 25, System Directive Received , Press '%key%' to run %name%
		Input, SplashInput, T1 L1
		if (SplashInput = key)
		{
			SplashTextOn, 250, 25, Operation underway, Initaiting %name%. Standby
			SoundBeep(6000, 100, 5)
			Run, "%path%"
			WinWait, %title%,,3
			WinActivate, %title%
		}
		SplashTextOff
    }
	Else
		BossKey(title)
}

;#If !WinActive("ahk_group game") ;add this to make an exeception during tevyat interactive map
!y::UltraBossKey("YouTube Music"			,"ahk_class Chrome_WidgetWin_1 ahk_exe YouTube Music.exe"			, "shell:AppsFolder\com.github.th-ch.youtube-music"					,"y")
!c::UltraBossKey("ChatGPT"					, "ChatGPT ahk_class Chrome_WidgetWin_1 ahk_exe msedge.exe"			, "Shell:AppsFolder\chatgpt.com-DFCB3CE4_ch69rtgtz055j!App"			,"c")
;` & Esc:: UltraBossKey("Genshin Impact"		, "Genshin Impact ahk_class UnityWndClass ahk_exe GenshinImpact.exe", "Z:\Games\Genshin Impact game\GenshinImpact.exe"					,"g")
!t::UltraBossKey("Taiga"					, "ahk_class TaigaMainW ahk_exe Taiga.exe"							, "Z:\Applications\Taiga\Taiga.exe"									,"t")
!w::UltraBossKey("WhatsApp"					, "WhatsApp ahk_class ApplicationFrameWindow"						, "shell:AppsFolder\5319275A.WhatsAppDesktop_cv1g1gvanyjgm!App"		,"w")
!s::UltraBossKey("Spotify"					, "ahk_class Chrome_WidgetWin_1 ahk_exe Spotify.exe"				, "shell:AppsFolder\Chromium.FLYOSQQLXGPZQ6UZLVC3DOCS6Y"			,"s")
!a::UltraBossKey("Apple Music"				, "ahk_class WinUIDesktopWin32WindowClass ahk_exe AppleMusic.exe"	, "shell:AppsFolder\AppleInc.AppleMusicWin_nzyj5cx40ttqa!App"		,"a")
;-----------------------------------------------------------------------------------------------------------------------
;[Ctrl+Alt+S] Save Hotkeys.ahkŚ
;-----------------------------------------------------------------------------------------------------------------------
#If WinActive("- Notepad++") OR WinActive(" - Visual Studio Code")
^!s::
	Send, ^s
	SoundBeep(10000, 200, 5)
	WinActivate, ahk_class Shell_TrayWnd
	Reload		; Restart This script
Return
^+!s::
	{
		IfWinNotExist, Window Spy ahk_exe AutoHotKey.exe
			Run, "x:\Environments\AutoHotkey\AutoHotkeyU64.exe" /force "x:\Environments\AutoHotkey\WindowSpy.ahk"
		Else
			WinClose, Window Spy ahk_exe AutoHotKey.exe
	}
	Send, ^+!s
Return
^+!l::ListLines
^+!k::KeyHistory
^+!v::ListVars


#If !WinActive("ahk_group game")
;-----------------------------------------------------------------------------------------------------------------------
;[Shift+F4] Network Monitor
;-----------------------------------------------------------------------------------------------------------------------
F1::
    If !WinExist("Drozd_net_monitor ahk_class AutoHotkeyGUI")
    {
        Run,  %A_ScriptDir%\Drozd_net_monitor\Drozd_net_monitor_original.exe
    }Else  {
        If WinActive("Drozd_net_monitor ahk_class AutoHotkeyGUI") and !WinActive("ahk_class Notepad++")
            Send, !{Tab}
        Else If !WinActive("Drozd_net_monitor ahk_class AutoHotkeyGUI") and !WinActive("ahk_class Notepad++")
            WinActivate Drozd_net_monitor ahk_class AutoHotkeyGUI
    }
    If WinActive("ahk_exe notepad++.exe")
        Send, {F1}
Return
+F1::Send, {F1}

;-------------------------------------------------------------------------------
; Turn off NumLock & CapsLock & Show Taskbar/ Toggle F11
;-------------------------------------------------------------------------------
~NumLock::
	Sleep, 60000	;1 min
	SetNumLockState, Off
Return

~CapsLock::
	Sleep, 60000	;1 min
	SetCapsLockState, Off
Return

MButton::
	CoordMode, Mouse, Screen
	MouseGetPos, posx, posy
	
	; If ((A_ScreenWidth > 1600) AND (A_ScreenHeight > 900))
	; {
		; posx := posx / (A_ScreenWidth / 1600.0)
		; posy := posy / (A_ScreenHeight / 900.0)
	; } Else If ((A_ScreenWidth > 1600) AND (A_ScreenHeight > 900)) {
		; posx := posx * (A_ScreenWidth / 1600.0)
		; posy := posy * (A_ScreenHeight / 900.0)
	; }
	
	posx := posx * (A_ScreenWidth / 1920.0)
	posy := posy * (A_ScreenHeight / 1080.0)
		
	If ((posx > 0) AND (posy > 1070))
	{
		If WinActive("ahk_class Shell_TrayWnd")
			Send, !{Tab}
		Else
			WinActivate, ahk_class Shell_TrayWnd ahk_exe Explorer.EXE
	}
	Else If ((posx > 1750) AND (posy < 10))
	{
		Send, {F11}
	}
	Else
		Send, {MButton}
Return

#If		;------------Unlocked All Windows-------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------------------------------
; Remaps
;---------------------------------------------------------------------------------------------------------------------

#Include %A_ScriptDir%\Include\Hotkeys.Anime.ahk
;#Include %A_ScriptDir%\Include\Hotkeys.BatteryAlarm.ahk
#Include %A_ScriptDir%\Include\Hotkeys.GenshinImpact.ahk
;#Include %A_ScriptDir%\Include\Hotkeys.Spotify.ahk
;ś#Include %A_ScriptDir%\Include\Hotkeys.WSA.ahk
#Include %A_ScriptDir%\Include\Hotkeys.YouTube_Music.ahk


#If WinActive("ahk_class Windows.UI.Core.CoreWindow ahk_exe SearchHost.exe")	;--------SEARCH HOTSTRING------------------------------------------
:*O?:A\::{Home}Apps:{Space}{End}
:*O?:D\::{Home}Documents:{Space}{End}
:*O?:F\::{Home}Folder:{Space}{End}
:*O?:P\::{Home}Photos:{Space}{End}
:*O?:V\::{Home}Videos:{Space}{End}
:*O?:S\::{Home}Settings:{Space}{End}
:*O?:W\::{Home}Web:{Space}{End}
:O:p/::paimon.moe/wish


#If		;--------general HOTSTRING------------------------------------------
:O::lol::😂
:O::lmao::🤣
:O::sweat::😅
:O::exp::😑
:O::sad::😢
:O::cry::😢
:O::sob::😭
:O::smug::😏

:?*O:@g::@gmail.com
:?*O:@h::@hotmail.com
:?*O:@j::@jainuniversity.ac.in

#If ( (Fullscreen()) AND (WinActive("- YouTube")) )	;----------YouTube is Fullscreen-----------------------------
w::Send, {Up}
a::Send, {Left}
NumpadClear::
s::Send, {Down}
d::Send, {Right}


#If	;------------------------------------------------NORMAL-----------------------------------------------------------
#b::				;Taskbar
If WinActive("ahk_class Shell_TrayWnd")
	Send, !{Esc}
Else {
	Send, #{b}
}
Return


;-------------------------------------------------------------------------------
; 4 Finger Wand
;-------------------------------------------------------------------------------
#^+F24::	;4 Finger Tap on touchpad
 ;~XButton1 & XButton2::
4FingerWand:
	CoordMode, Mouse, Screen
	MouseGetPos, posx1, posy1
	posx := posx1 * (A_ScreenWidth / 1920.0)
	posy := posy1 * (A_ScreenHeight / 1080.0)
	If ((posx > 1400) AND (posy > 200))		;Quick Settings		bottom-right-large
	{
		Sleep, 10
		Send, #a
	}
	Else If ((posx > 650  AND posx < 1280) AND (posy < 1080 AND posy > 1020))
	{
		Sleep, 10
		Send, ^{Esc}
	}
	Else If ((posx < 600) AND (posy > 200))	;SwitchDesktop		bottom-left-large
	{
		Sleep, 10
		SwitchDesktop()
	}
	Else If ((posx > 1850) AND (posy < 50))	;OperaGX	top-right-small
	{
		Sleep, 10
		RunAsUser("Z:\Applications\Opera GX\launcher.exe", "--processStart https://yugenanime.tv/latest/")
	}
	Else If ((posx < 80) AND (posy < 50))	;Discord			top-left-small
	{
		Sleep, 10
		BossKey("ahk_class Chrome_WidgetWin_1 ahk_exe YouTube ŚMusic.exe")
	}
	Else	;Notification center
	{
		Sleep, 10
		Send, #n
	}
Return

~*WheelUp::
	CoordMode, Mouse, Screen
	MouseGetPos, posx1, posy1,, classnn
	posx := posx1 * (A_ScreenWidth / 1920.0)
	posy := posy1 * (A_ScreenHeight / 1080.0)
	if (posx > 1780) AND (posy > 1030)		;Increase Vol		bottom-right-small
		Send, {volume_Up}{volume_Up}
	Else If (posx < 140) AND (posy > 1030)	;increase Brt		bottom-left-small
		ChangeBrightness(+10)
    Else If (posx < 140) AND (posy < 30)	;increase fan		Top-left corner 
        ChangeFanSpeed(+10)
	; Else
		; Send, {WheelUp}
	Return
~*WheelDown::
	CoordMode, Mouse, Screen
	MouseGetPos, posx1, posy1,, classnn
	posx := posx1 * (A_ScreenWidth / 1920.0)
	posy := posy1 * (A_ScreenHeight / 1080.0)
	if (posx > 1780) AND (posy > 1030)		;Decrease Vol		bottom-right-small
		Send, {Volume_Down}{Volume_Down}
	Else If (posx < 140) AND (posy > 1030)	;Decrease Brt		bottom-left-small
		ChangeBrightness(-10)
    Else If (posx < 140) AND (posy < 30)	;Decrease fan		Top-left corner 
        ChangeFanSpeed(-10)
	
	Return    
	
	#WheelUp::Send, #=
	#WheelDown::Send, #-            
	
#If !WinActive("ahk_group game")
;~RButton & LButton Up::Goto, 4FingerWand
~RButton & WheelDown::AltTab
~RButton & WheelUp::ShiftAltTab
#If


;-------------------------------------------------------------------------------
; Switch Desktop
;-------------------------------------------------------------------------------
SwitchDesktop(CharToSend:="", Window:="A",CharToSend2:="" , Window2:="A") {
	Desktop := VD.getCurrentDesktopNum()
	If (sdToggle == "") {
		If (Desktop == 1)
			sdToggle = 0
		Else
		sdToggle = 1
	}
	Else If (Desktop == 4)
		sdToggle = 1

	ControlSend, , %CharToSend%, %Window%

	If (Desktop == 3 AND sdToggle == 0)
		Send, #^{Right}
	Else If (Desktop == 2 AND sdToggle == 1)
		Send, #^{Right}
	Else If (Desktop == 1)
		Send, #^{Right}
	Else
		Send, #^{Left}

	If WinExist(Window2)
		Sleep, 500
	If WinActive(Window2)
		Send, %CharToSend2%
}
#+d::
	Desktop := VD.getCurrentDesktopNum()
	If (Desktop == 3)
		sdToggle := 0
	Else If (Desktop == 2)
		sdToggle := !sdToggle
	SwitchDesktop()
Return

+NumpadHome::
#d::SwitchDesktop()

+#Numpad1::
+#NumpadEnd::
	VD.MoveWindowToDesktopNum("A",1)
#Numpad1::
#NumpadEnd::
	VD.goToDesktopNum(1)
Return

+#Numpad2::
+#NumpadDown::
	VD.MoveWindowToDesktopNum("A",2)
#Numpad2::
#NumpadDown::
	VD.goToDesktopNum(2)
Return

+#Numpad3::
+#NumpadPgDn::
	VD.MoveWindowToDesktopNum("A",3)
#Numpad3::
#NumpadPgDn::
	VD.goToDesktopNum(3)
Return

+#Numpad4::
+#NumpadLeft::
	VD.MoveWindowToDesktopNum("A",4)
#Numpad4::
#NumpadLeft::
	VD.goToDesktopNum(4)
Return


;-------------------------------------------------------------------------------
;[F12] System Informer & [Win+C] Copilot & Nero
;-------------------------------------------------------------------------------
F12::
WinTitle := "ahk_class MainWindowClassName ahk_exe SystemInformer.exe"
If WinActive(WinTitle)
{
	WinMinimize, %WinTitle%
	WinHide, %WinTitle%
}Else {
	WinShow, %WinTitle%
	WinActivate, %WinTitle%
	Send, ^k
}
Return

#c::
winTitle := "Copilot - ahk_exe msedge.exe"
If WinExist(winTitle) {
	BossKey(winTitle)
} Else {
	Run, shell:AppsFolder\Microsoft.Copilot_8wekyb3d8bbwe!App
}
Return

#!c::
IF !ProcessExist("talk.exe") {
    Run, z:\tools\Nero\talk.exe --ai gemini --se tts,  z:\tools\Nero,, talkPID
}Else {
    BossKey("ahk_pid "talkPID)
    If !talkPID {
        Run, TaskKill /IM talk.exe /F,, hide
    }
}
Return

;-------------------------------------------------------------------------------
; Bing Rewards
;-------------------------------------------------------------------------------
RunBingRewards(name, key, paths) {
    SplashTextOn, 250, 25, Bing Rewards %name%, Press '%key%' to run bing rewards (%name%)
    Input, SplashInput, T1 L1
    if (SplashInput = key)
    {
        SplashTextOn, 250, 25, Bing Rewards (%name%), Running Bing Rewards...
        searchTerms := ["anime", "manga", "light", "novels", "hinata", "nezuko", "demon", "slayer", "naruto", "attack", "on", "titan", "sakura", "tokyo", "kyoto", "osaka", "hokkaido", "fuji", "ramen", "sushi", "samurai", "shinto", "buddhism", "kanji", "katakana", "hiragana", "jpop", "kawaii", "otaku", "cosplay", "gundam", "pokemon", "ghibli", "miyazaki", "harajuku", "shibuya", "akihabara", "ikebukuro", "yokohama", "nagoya", "sapporo", "fukuoka", "kobe", "shinjuku", "asakusa", "tsukiji", "ryokan", "onsen", "kimono", "yukata"]
        query := "https://www.bing.com/search?q="
        Random, loopCount, 1, 5
        Loop % loopCount {    
            Random, randomIndex, 1, searchTerms.Length()
            randomWord := searchTerms[randomIndex]
            query .= randomWord . "%20"
        }
        query .= "&form=STARTSCRIPT"
        rewardsPage := "https://rewards.bing.com"
        SysGet, MonitorWorkArea, MonitorWorkArea
        windowWidth := MonitorWorkAreaRight // paths.Length()
        for index, path in paths {
			Run, %path% %query%
			; WinClose, ahk_pid %pid%
            ; WinRestore, AHK_pid %pid%
            Sleep, 300
            ; WinMove, AHK_pid %pid%,, (index-1)*windowWidth, 0, windowWidth, MonitorWorkAreaBottom
        }
    }
    SplashTextOff
}

^!b::RunBingRewards("Desktop", "b", ["C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge.exe", "C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge.exe --profile-directory=""Profile 1""", "C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge.exe --profile-directory=""Profile 2"""])
+!b::RunBingRewards("Mobile", "B", ["wsa://org.mozilla.fenix", "wsa://org.mozilla.firefox", "wsa://org.mozilla.firefox_beta" ,"wsa://net.waterfox.android.release"])

;-----------------------------------------------------------------------------------------------------------------------
; Set volume to zero forcebly after every 1 second
!m::
Run, "Z:\Tools\AHK\Hotkeys\Include\Absolute.Volume.ahk"
return
;-----------------------------------------------------------------------------------------------------------------------

#Persistent
toggle := false  ; Initialize the toggle variable as false
SetTimer, PressF, Off  ; Initially stop the timer

; This hotkey toggles the functionality with Alt + F
!f::
toggle := !toggle  ; Toggle the state between true and false
if (toggle) {
    SetTimer, PressF, 1000  ; Start the timer to trigger every 1000 ms (1 second)
} else {
    SetTimer, PressF, Off  ; Stop the timer
}
return

PressF:
IfWinActive, ahk_exe GenshinImpact.exe  ; Only proceed if Genshin Impact is active
{
    Send, {F}  ; Simulate pressing the F key
}
return

;-----------------------------------------------------------------------------------------------------------------------
;the reward for good work is more work!