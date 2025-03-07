;@Ahk2Exe-SetMainIcon %A_ScriptDir%\Icon-Minimalism-App-Network-Monitor.ico
#SingleInstance force
#NoEnv
/*@Ahk2Exe-Keep
#NoTrayIcon
*/
SetBatchLines, -1

;forum upd Jan10 2019
/*  
=== Drozd net monitor
-- net usage monitor ; since last shutdown and total since chosen date
-- upload, download bars; horizontal, vertical bars
-- graph showing upload, download history 
-- green indicator - internet connection on
-- get IP - click on text next to green indicator
-- F4 - show GUI
-- top left circle = toggle always on top
-- click on "Today" and date to reset
-- 1kB=1000 bytes; in ini file data saved also in KB, 1KB=1024 bytes
-- double click tray icon to exit, click to show 
-- 
-- arrow= toggle between extended and simple GUI
-- more options in right click context menu
=== 
XNET.ahk by SKAN must be included  http://ahkscript.org/boards/viewtopic.php?&t=4542 
https://autohotkey.com/board/topic/16574-network-downloadupload-meter/
Gdip library by tic must be included ;	https://autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
; https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk
*/

help=
(
● net usage monitor ; since last shutdown and total since chosen date
● upload, download bars; horizontal, vertical bars
● graph showing upload, download history

● top left circle - toggle always on top
● arrow - toggle between extended and simple GUI
● double click on the title to go to the saved position  
● F4 - show GUI , or click on tray icon
● more options in the right click context menu: Settings, GUI color; save position for next launch
● Settings: choose 2 versions of GUI and vertical bars on/off

● green indicator - internet connection on
● get IP - click on text control next to green indicator, mouse over to get last checked (if connection problem, it may freeze)

● click on graph to show scale; set scale in Settings
● click on horizontal bars to show last peak rate up/down

● 1kB=1000 bytes; in ini file data saved also in KB, 1KB=1024 bytes
● click on "Today" or "Since date" to reset


)

iconSet:=RegExMatch(A_OSVersion,"WIN_VISTA|WIN_7") ? 25 : 18  

Menu, Tray, Icon, %A_ScriptDir%\Icon-Minimalism-App-Network-Monitor.ico
Menu, Tray, NoStandard
Menu, Tray, Add, Window Spy, WindowSpy 
Menu, Tray, Add
Menu, Tray, Add , Clear peaks, clear_peaks
Menu, Tray, Add , Open settings file , Open_ini
Menu, Tray, Icon , Open settings file , Shell32.dll, 70
Menu, Tray, Add ,
Menu, Tray, Add, Settings, Settings
; Menu, Tray, Icon, Settings, wmploc.dll, %iconSet%  ; 18  ;in Win8
Menu, Tray, Icon, Settings, Shell32.dll, %iconSet%  ; 18  ;in Win8+
Menu, Tray, Add ,
Menu, Tray, Add , Edit in Scite, Edit_Scite
Menu, Tray, Add , Edit in Notepad, Edit_Notepad
Menu, Tray, Add
Menu, Tray, Add, Reload , Reload
Menu, Tray, Add, Exit , Exit 
Menu, Tray, Default, Exit ; double click tray icon to exit

Menu, ContextMenu, Add, On Top, OnTop
;Menu, ContextMenu, Icon, On Top, Shell32.dll, 147
Menu, ContextMenu, Icon, On Top, Shell32.dll, 248 ;wmploc.dll, 17
Menu, ContextMenu, Add, Save current position , save_position
Menu, ContextMenu, Icon, Save current position , Shell32.dll,124 ; 268 ;101 124
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Reset TODAY data, Reset_cumul_Today
Menu, ContextMenu, Icon, Reset TODAY data, Shell32.dll, 132
Menu, ContextMenu, Add, Reset TOTAL data, Reset_cumul_Total 
Menu, ContextMenu, Icon, Reset TOTAL data, Shell32.dll, 132
Menu, ContextMenu, Add,


Menu, ContextMenu, Add, Settings, Settings
;Menu, ContextMenu, Icon, Settings, wmploc.dll, 25
; Menu, ContextMenu, Icon, Settings, wmploc.dll, %iconSet%  ;25
Menu, ContextMenu, Icon, Settings, Shell32.dll, %iconSet%  ;25
;Menu, ContextMenu, Icon, Settings, Shell32.dll, 70
;Menu, ContextMenu, Icon, Settings, wmploc.dll,18  ;in Win8

Menu, Submenu1, Add, Black , set_bgrd_black
Menu, Submenu1, Add, Steel , set_bgrd_steel
Menu, Submenu1, Add, Blue , set_bgrd_blue  
Menu, Submenu1, Add, Green , set_bgrd_green
Menu, Submenu1, Add, 
Menu, Submenu1, Add, Funny style: dots, set_bgrd_style_dots
Menu, Submenu1, Add,  Funny style: dots 2, set_bgrd_style_dots2
Menu, Submenu1, Add, Funny style: bricks, set_bgrd_style_bricks 
Menu, Submenu1, Add, 
Menu, Submenu1, Add, Reset background, reset_bgrd
Menu, ContextMenu, Add, Background color, :Submenu1 
;Menu, ContextMenu, Icon, Background color, imageres.dll,181 
Menu, Submenu2, Add, Open settings file , Open_ini
Menu, Submenu2, Icon, Open settings file, Shell32.dll, 70
Menu, Submenu2, Add, Open log file , Open_log
Menu, Submenu2, Icon, Open log file, Shell32.dll, 71
Menu, Submenu2, Add,
Menu, Submenu2, Add , Clear peaks, clear_peaks
;Menu, Submenu2, Add, Help , show_help
;Menu, Submenu2, Icon, Help , shell32.dll, 24
Menu, ContextMenu, Add, more, :Submenu2 
;Menu, ContextMenu, Icon, more , Shell32.dll, 268
Menu, ContextMenu, Add,

;Menu, ContextMenu, Add, Open settings file , Open_ini
;Menu, ContextMenu, Icon, Open settings file, Shell32.dll, 70
;Menu, ContextMenu, Add,

Menu, ContextMenu, Add, Help , show_help
Menu, ContextMenu, Icon, Help , shell32.dll, 24
Menu, ContextMenu, Add, Restart, Reload
Menu, ContextMenu, Add, Exit, Exit

SetWorkingDir %A_ScriptDir%


If !pToken := Gdip_Startup()
{
	MsgBox, No Gdiplus 
	ExitApp
}

Net := new XNET(True)

OnExit, Save_data_exit

global grid_h:=29 , grid_w:=121
global array_down := Object() , array_up := Object()
global max_up:= 100, max_down:= 1000

 Loop, 120 {
		array_down[A_Index]:=29
		array_up[A_Index]:=29
}  

global months:={01:"I",02:"II",03:"III",04:"IV",05:"V",06:"VI",07:"VII",08:"VIII",09:"IX",10:"X",11:"XI",12:"XII"}  

;===============================

	SysGet, MonitorWorkArea, MonitorWorkArea, 1
	pos_x:=A_ScreenWidth - 140
	pos_y:= MonitorWorkAreaBottom -620 ;-380


;===============================

bgrd_grad_black:="0xff0F0F0F|0xff222222|25"
bgrd_grad_steel:="0xff2D3F5D|0xff1A2333|25"
bgrd_grad_blue:="0xff012243|0xff13365A|75"
bgrd_grad_green:="0xff00290C|0xff1C4527|75"

bgrd_grad:=bgrd_grad_steel 


bgrd_ramki_black:="0xff353535|0xff1C1C1C|7"
bgrd_ramki_steel:="0xff2D3F5D|0xff1A2333|10"
bgrd_ramki_blue:="0xff16416B|0xff0D263E|10" 
bgrd_ramki_green:="0xff0F5221|0xff0A3315|10" ;"0xee0F5221|0xee0A3315|10"
bgrd_ramki:= bgrd_ramki_steel , bgrd_ramki_1:=bgrd_ramki_2:=bgrd_ramki

;===============================
global log_file := "log_AHKfile_temp.txt"


global settings_ini := "Drozd Net monitor.ini"


IfNotExist, %settings_ini%
{
		IniWrite, 100 , %settings_ini%, Graph scale , maximum upload rate
		IniWrite, 1000, %settings_ini%,Graph scale, max download rate
		IniWrite, %A_Now%	, %settings_ini%, Statistics, start cumulation date
		IniWrite,  0	, %settings_ini%, Statistics, total upload
		IniWrite,  0	, %settings_ini%, Statistics, total download
		IniWrite, %pos_x%	, %settings_ini%, window position, x
		IniWrite, %pos_y%	, %settings_ini%, window position, y
		
		IniWrite, 1, %settings_ini%, Window , Version
		IniWrite, 0, %settings_ini%, Window, Show vertical bars		
		IniWrite, 0, %settings_ini%, TEMP, shutdown
}

	IniRead, GUI_bgrd, %settings_ini%, Window , background color	

	if(GUI_bgrd!="ERROR" && GUI_bgrd!=""){
				bgrd_grad:=GUI_bgrd
	}else{
		IniWrite, %bgrd_grad%	, %settings_ini%, Window , background color
	}

IniRead, GUI_buttons_1, %settings_ini%, Window , GUI_buttons_1	
IniRead, GUI_buttons_2, %settings_ini%, Window , GUI_buttons_2	

	if(GUI_buttons_1!="ERROR" && GUI_buttons_1!=""){
				bgrd_ramki_1:=GUI_buttons_1
	}else{
		IniWrite, %bgrd_ramki%	, %settings_ini%, Window, GUI_buttons_1
	}
	
	if(GUI_buttons_2!="ERROR" && GUI_buttons_2!=""){
				bgrd_ramki_2:=GUI_buttons_2
	}else{
		IniWrite, %bgrd_ramki%	, %settings_ini%, Window, GUI_buttons_2
	}


	global max_down, max_up, 

	IniRead, max_up, %settings_ini%, Graph scale, maximum upload rate
	IniRead, max_down, %settings_ini%, Graph scale, max download rate	
	
	IniRead, pos_x_saved, %settings_ini%, window position, x	
	IniRead, pos_y_saved, %settings_ini%, window position, y	

	if(max_up=="ERROR" || max_up=="" || max_down=="ERROR" || max_down==""){
		max_up:= 100 
		max_down:= 1000
		IniWrite, 100 , %settings_ini%, Graph scale , maximum upload rate
		IniWrite, 1000, %settings_ini%,Graph scale, max download rate
  }


	if(!pos_x_saved || !pos_y_saved || pos_x_saved=="ERROR" || pos_y_saved=="ERROR"){
			IniWrite, %pos_x%	, %settings_ini%, window position, x
			IniWrite, %pos_y%	, %settings_ini%, window position, y
	}else{
		if(pos_x_saved<A_ScreenWidth-120 && pos_y_saved<A_ScreenHeight-130){
			pos_x:=pos_x_saved
			pos_y:=pos_y_saved
		}
	}


global Day_cumul_raw, total_down_saved, total_up_saved , today_down_saved, today_up_saved
global total_down , total_up, today_down, today_up

	;Gosub, Get_Saved_data
	IniRead, Day_cumul_raw, %settings_ini%, Statistics, start cumulation date
	IniRead, total_down_saved, %settings_ini%, Statistics, total download	
	IniRead, total_up_saved, %settings_ini%, Statistics, total upload
	
	if(Day_cumul_raw=="ERROR" || total_down_saved=="ERROR" || total_up_saved=="ERROR" || total_down_saved=="" || total_up_saved==""){
		;IniWrite, 100 , %settings_ini%, Graph scale , maximum upload rate
		;IniWrite, 1000, %settings_ini%,Graph scale, max download rate
		IniWrite, %A_Now%	, %settings_ini%, Statistics, start cumulation date
		IniWrite,  0	, %settings_ini%, Statistics, total upload
		IniWrite,  0	, %settings_ini%, Statistics, total download
		Day_cumul_raw:= A_Now
		total_down_saved:=0 , total_up_saved:=0
  } 
	
	FormatTime, Day_cumul, %Day_cumul_raw%, MMMd 


	global old_peak_up:=0, old_peak_down:=0 , showPeaks:=0


	today_down:=0 , today_up:=0
	total_down:=total_down_saved , total_up :=total_up_saved
	max_up:= max_up*1000, max_down:= max_down*1000


	IniRead, after_shutdown, %settings_ini%, TEMP, shutdown

	if(after_shutdown=="ERROR"){
		IniWrite, 0, %settings_ini%, TEMP, shutdown
	}
	
	if(after_shutdown==1){
		today_down:=0 , today_up:=0
		IniWrite, 0, %settings_ini%, TEMP, shutdown
	}else {
		IniRead, today_down_saved , %settings_ini%, Statistics, current download
		IniRead, today_up_saved, %settings_ini%, Statistics, current upload	
		if(today_down_saved!="ERROR" && today_down_saved!="" && today_up_saved!="ERROR" && today_up_saved!=""){
			today_down:=today_down_saved , today_up :=today_up_saved
		}
	}


	IniRead, ver, %settings_ini%, Window, Version
		if(ver=="ERROR" || ver==""){
			IniWrite, 1, %settings_ini%, Window , Version
			IniWrite, 0, %settings_ini%, Window , Show vertical bars
			version:=1
			show_vert_bars:=0
				
		}else{		
			IniRead, ver, %settings_ini%, Window, Version
			IniRead, Show_vert_, %settings_ini%, Window, Show vertical bars	
			if(ver==1){
				version:=1
			}else if(ver==2){
				version:=2
			}
		}
	
	
	IniRead, Show_vert_, %settings_ini%, Window, Show vertical bars
		if(Show_vert_==0 || Show_vert_==1){
			show_vert_bars:=Show_vert_
		}else{
			show_vert_bars:=0
			IniWrite, 0, %settings_ini%, Window, Show vertical bars
		}
		
 
	
if(version==1){
		grid_down_x:=6 ,grid_down_y:= 22
		grid_up_x:=6 , grid_up_y:=74
		
 		Bar_dn_h_x:=6 , Bar_dn_h_y:=57
		Bar_up_h_x:=6 , Bar_up_h_y:=110

		down_speed_x:=72 , down_speed_y:=57
		up_speed_x:=72 , up_speed_y:=110

		arrowDown_x:=121 , arrowDown_y:=58			
		arrowUp_x:=120 , arrowUp_y:=110	
		
		if(show_vert_bars){
			grid_down_x:=1 ,grid_down_y:= 22
			grid_up_x:=1 , grid_up_y:=74
			
			Bar_up_v_x:=124 , Bar_up_v_y:=74
			Bar_dn_v_x:=124 , Bar_dn_v_y:=22
			
			arrowDown_x:=123 , arrowDown_y:=58			
			arrowUp_x:=122 , arrowUp_y:=110	
		}else{
			grid_down_x:=6 ,grid_down_y:= 22
			grid_up_x:=6 , grid_up_y:=74
		}
	
}else if(version==2){

		Bar_up_h_x:=20 , Bar_up_h_y:=110
		Bar_dn_h_x:=20 , Bar_dn_h_y:=93

		up_speed_x:=89 , up_speed_y:=110
		down_speed_x:=89 , down_speed_y:=93

		arrowUp_x:=3 , arrowUp_y:=110
		arrowDown_x:=4 , arrowDown_y:=95	

		Bar_up_v_x:=124 , Bar_up_v_y:=57
		Bar_dn_v_x:=124 , Bar_dn_v_y:=22	
		
		if(show_vert_bars){
			grid_down_x:=1 ,grid_down_y:= 22
			grid_up_x:=1 , grid_up_y:=57
		}else{
			grid_down_x:=6 ,grid_down_y:= 22
			grid_up_x:=6 , grid_up_y:=57
		}
}


;========================================


Gui,1: +ToolWindow -border +HwndGuiHwnd  +AlwaysOnTop	
WonTop:=1	
Gui,1:Color, 120F00
Gui,1: -DPIScale

Gui, Add, Picture, x0 y0 h200 w135 vbgrd 0xE,
GoSub, bgrd

Gui, 1: Add, Picture, x0 y0 w134 h15 vramkaT 0xE, 
Gui,1: Font, S7 w700 cE1E1E1 ,  Segoe UI 
Gui,1: Add, Text , x17 y1 w100  gDoubleClick BackgroundTrans  Center, Drozd Net Monitor  ;gGoToSavedPos

Gui,1: Font, S7 w700 cD0D0D0 , Segoe UI ;
Gui,1: Add, Text , x122 y1 w10 h10 cD0D0D0 gexit BackgroundTrans Center ,  X 

Gui,1: Font, S6 w700 c9C9C9C , Segoe UI
Gui,1: Add, Text , x3 y1  c676767 vonTop_off gonTop BackgroundTrans, % Chr(9675) ; ○    
Gui,1: Font, S9
Gui,1: Add, Text , x3 y+-13  c676767 vonTop_on gonTop BackgroundTrans, % Chr(9679) ;  ● 
GuiControl, Hide, onTop_off



Gui, 1: Add, Picture, x%grid_down_x% y%grid_down_y% w122 h31 vGrid_img_in  gScaleInfoShow 0xE, 
Gui, 1: Add, Picture, x%grid_up_x% y%grid_up_y% w122 h31 vGrid_img_out gScaleInfoShow 0xE,
if(show_vert_bars){
	Gui, 1: Add, Picture, x%Bar_dn_v_x% y%Bar_dn_v_y%  w8 h31 vBar_dn_v BackgroundTrans 0xE 
	Gui, 1: Add, Picture, x%Bar_up_v_x% y%Bar_up_v_y% w8 h31 vBar_up_v BackgroundTrans 0xE , 	
}

Gui,1: Font, S7 w700 cF4F4F4 , Segoe UI 
Gui, Add, Picture, x%arrowUp_x% y%arrowUp_y% w11 h11 varrowUp BackgroundTrans 0xE, 
Gui, Add, Picture, x%arrowDown_x% y%arrowDown_y% w11 h11 varrowDown BackgroundTrans 0xE,

Gui, 1: Add, Picture, x%Bar_up_h_x% y%Bar_up_h_y% w66 h12 vBar_up_h gPeakUp 0xE 
Gui, 1: Add, Picture, x%Bar_dn_h_x% y%Bar_dn_h_y% w66 h12 vBar_dn_h gPeakDown 0xE ,

Gui,1: Add, Text , x%up_speed_x% y%up_speed_y% w44 vup_speed  BackgroundTrans Center , 
Gui,1: Add, Text , x%down_speed_x% y%down_speed_y% w44 vdown_speed  BackgroundTrans Center  , 




Gui,1: Font, S7 w700 c676767 , Segoe UI
Gui,1: Add, Text , x5 y126  c930000 vnet_Off_  BackgroundTrans,  % Chr(9675) ; ○  
Gui,1: Font, S11
Gui,1: Add, Text , x5 y121 c00932A vnet_On_  BackgroundTrans, % Chr(9679) ;  ●  
GuiControl, Hide, net_On_

Gui,1: Font, S6 w400 cD7D7D7, Arial ;Segoe UI 
Gui,1: Add, Text , x15 y128 w100 c8291C9 vconn gGet_IP BackgroundTrans  Center, ;   Local Area Connection

;Gui,1: Add, Picture, x115 y125 w16 h16  gbigger BackgroundTrans Icon249 AltSubmit, shell32.dll ;
Gui, 1: Add, Picture, x115 y125  w14 h14 vbig_switch gbigger BackgroundTrans 0xE ,
Gdip_icon_switch(big_switch)


Gui, Add, Picture, x2 y163 w11 h11 varrowUp2 BackgroundTrans 0xE,
Gui, Add, Picture, x3 y181 w11 h11 varrowDown2  BackgroundTrans 0xE,


Gui, Add, Picture, x16 y143 w49 h14 vramka1 0xE, 
Gui, Add, Picture, x68 y143 w60 h14 vramka2 0xE,

Gui, Add, Picture, x16 y161 w49 h15 vramka31 0xE,
Gui, Add, Picture, x16 y179 w49 h15 vramka32 0xE,
Gui, Add, Picture, x78 y161 w49 h15 vramka41 0xE,
Gui, Add, Picture, x78 y179 w49 h15 vramka42 0xE,

Gosub, ramka


Gui,1: Font, S7 w700 cD2D2D2 , Segoe UI ;cD7D7D7 cCDCDCD
Gui,1: Add, Text , x27 y143 w20 cD8C591 gReset_cumul_Today BackgroundTrans   , Today   ; c8291C9 cD0AE53
Gui,1: Add, Text , x72 y143 w20 cD8C591 gReset_cumul_Total BackgroundTrans, Since  ;Total
Gui,1: Add, Text , x98 y143 w30 cC13030 vDaySince gReset_cumul_Total  BackgroundTrans  ,  %Day_cumul%  ;cC13030



Gui,1: Font, S7 w700 cE1E1E1, Segoe UI  ; cD7D7D7
Gui,1: Add, Text , x16 y162 w44  vup_cumul_today BackgroundTrans  Right, % Size_format(today_up_saved,1)
Gui,1: Add, Text , x16 y180 w44  vdown_cumul_today BackgroundTrans  Right, % Size_format(today_down_saved,1)
Gui,1: Add, Text , x78 y162 w44  vcumul_up_tot BackgroundTrans  Right, % Size_format(total_up_saved,1) ; Size_format_file
Gui,1: Add, Text , x78 y180 w44  vcumul_down_tot BackgroundTrans  Right,% Size_format(total_down_saved,1) ; Size_format_file

GoSub, draw_icons

toggle_big:=0

/* Gui, 1: Show, x%pos_x% y%pos_y% w128 h137  , Drozd_net_monitor
WinSet, Style, -0xC00000, Drozd_net_monitor ; COMPLETELY remove window border
;Winset, Transparent,200, Drozd_net_monitor  
 */
;Gui,1: -0xC00000 
Gui,1: -caption
Gui,1: Show, Hide x%pos_x% y%pos_y% w134 h143  , Drozd_net_monitor
DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 200, "Int", 0x00000004 )
;DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 300, "Int", 0x00000010 )


OnMessage(0x6555, "MsgMonitor_IP")
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x218, "WM_POWERBROADCAST") ; on standby
OnMessage(0x11, "WM_QUERYENDSESSION") ;  on system shutdown
OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
OnMessage(0x404, "AHK_NOTIFYICON") ;click tray icon to show




	GoSub, bigger
	GoSub, onTop
	GoSub, grid_NET
	GoSub, bars_horizontal
	
	if(show_vert_bars){
		GoSub, bars_vertical
	}
	
	Gosub, check_connection
	GoSub, start_timers
return



AHK_NOTIFYICON(wParam, lParam){ ;click tray icon to show
    if (lParam = 0x202) {       ; WM_LBUTTONUP
				Gui,1:Show  				
    }else if (lParam = 0x203){   ; WM_LBUTTONDBLCLK
		}
}

WM_LBUTTONDOWN(){
	if (A_Gui=1){
	PostMessage, 0xA1, 2    ; movable borderless window 
	}
}

;===================
WM_MOUSEMOVE(){
		global GuiHwnd , show_old_IP
		MouseGetPos,, ,winID,control 
		if(winID==GuiHwnd && control=="Static17"){
			if(!show_old_IP){	
				show_old_IP:=1				
				PostMessage, 0x6555, 210, 0,, ahk_id %GuiHwnd%  ; OnMessage(0x6555, "MsgMonitor_IP")
				SetTimer, check_connection ,Off
				SetTimer, Set_Timer ,3000
			}
		}
}

;===================

; 4,5 to sleep/standby,hibernation ; 7,8 resume from sleep/standby,hibernation


WM_POWERBROADCAST(wParam, lParam){ ; standby
	if(wParam = 7 OR wParam = 8){ ; from hibernation ,standby  ; fix bug
		time_:= A_MMM A_DD " " A_Hour ":" A_Min ":" A_Sec 
			data1:= "today_down: "  Size_format(today_down) "  | " "today_up: " Size_format(today_up)  "`n" "total_down: " Size_format(total_down) " | " "total_up: " Size_format(total_up) 
				Settimer, get_up_down_data ,Off
				Settimer, timer_after_standby ,-30000
	;FileAppend, %  "`n`n" time_ " RESUME from standby 7/ hibernation 8 wParam: " wParam  "  | Off for 5 sec`n" data1 , %log_file%			 
	}
	
	if(wParam = 4 OR wParam = 5){ ; to standby, hibernation
		time_:= A_MMM A_DD " " A_Hour ":" A_Min ":" A_Sec 
		data1:= "today_down: "  Size_format(today_down) "  | " "today_up: " Size_format(today_up)  "`n" "total_down: " Size_format(total_down) " | " "total_up: " Size_format(total_up) 
			Settimer, get_up_down_data ,Off
			Settimer, timer_after_standby ,-20000
			Gosub, Save_data
		;FileAppend, %  "`n`n" time_ " TO standby 4 /hibernation 5 wParam: " wParam  "  | Off for 15 sec`n" data1, %log_file%	 
	}	
	
	if(wParam = 7 OR wParam = 4){
		Text_ := {7: "from", 4: "to"}
		;======= ini - standby
		time_now:= A_Hour ":" A_Min " " A_DD "." months[A_MM]  
		IniRead, read_, %settings_ini%, Comp, standby
		read_:=(read_!="ERROR" && read_!="") ? read_ : "" 
		time_write:=read_ 
		arr:=StrSplit(time_write,"|"), len:=arr.Length()
		if(len>20){
			arr.Pop()
			time_write:=joinArray("|", arr)
		}
			if(InStr(time_write,time_now) && (read_!="ERROR" && read_!="")){
					return
			}else{
				time_write:= Text_[wparam] " " time_now " | " time_write 
			}
		IniWrite, %time_write% , %settings_ini%, Comp, standby
		;======= ini - standby
	}
}

timer_after_standby:
	Settimer, timer_after_standby ,Off
	Settimer, get_up_down_data ,1000
return


WM_QUERYENDSESSION(wParam, lParam){ ; on shutdown
	if(lParam=0){
		IniWrite, %A_Now%	, %settings_ini%, TEMP, shutdown time
		IniWrite, 1	, %settings_ini%, TEMP, shutdown
		Gosub, Save_data
		Gosub, archive_today
		
		;======= ini - shutdown
		time_now:= A_Hour ":" A_Min " " A_DD "." months[A_MM] 
		IniRead, read_, %settings_ini%, Comp, shutdown
		read_:=(read_!="ERROR" && read_!="") ? read_ : "" 
		time_write:=read_ 
		arr:=StrSplit(time_write,"|"), len:=arr.Length()
		if(len>20){
			arr.Pop()
			time_write:=joinArray("|", arr)
		}
			if(InStr(time_write,time_now) && (read_!="ERROR" && read_!="")){
					return
			}else{
				time_write:= time_now   " | " time_write ;")" " -" lParam
			}
		IniWrite, %time_write% , %settings_ini%, Comp, shutdown
		;======= ini - shutdown
		
	/* 	data1:= "today_down: "  Size_format(today_down) "  | " "today_up: " Size_format(today_up)  "`n" "total_down: " Size_format(total_down) " | " "total_up: " Size_format(total_up) 
		data2:= "today_down_saved: "  Size_format(today_down_saved) "  | " "today_up_saved: " Size_format(today_up_saved)  " |  " "total_down_saved: " Size_format(total_down_saved) " | " "total_up_saved: " Size_format(total_up_saved) 
		time_:= A_MMM A_DD " " A_Hour ":" A_Min ":" A_Sec	
		FileAppend, %   "`n`nNetMon WM_QUERYENDSESSION computer shutdown " A_MMM A_DD " " A_Hour ":" A_Min ":" A_Sec "`n"  data1 "`n" data2   "`n" , %log_file% 
		 */
	}
}

joinArray(sep, array){
	AutoTrim, Off
	for index, value in array
		str .= value sep
	;str:=RegExReplace(str, sep "$","")
	str:=SubStr(str, 1, -StrLen(sep))		
	AutoTrim, On		
	return str
}
;===============================

start_timers:
	Settimer, start_timers , Off
  Settimer, get_up_down_data , 1000
	Settimer, check_connection ,3000
	
	Settimer, Save_data ,60000	
return

;======================================


check_connection:
		if InternetConnection() {
			GuiControl, Show, net_on_ 
			GuiControl, Hide, net_Off_			
			if(!IsObject(NET))
				Net := new XNET(True)
		}else {
			GuiControl, Hide, net_On_			
			GuiControl, Show, net_Off_
			Net=
		}
	
		if(Net.State=="Connected"){
			network:=Net.Alias
			network_card:=Net.Description
			show_:= RegExReplace(network,"i)Local Area Connection","LAN") ": " network_card
			conn_n:=SubStr(show_,1,20)
			GuiControlGet,conn_,1:, conn
			if(conn_n != conn_)
				GuiControl,,conn, % conn_n
			;if(conn_n != conn_old)
			;conn_old:=conn_n
		}else if (Net.State=="Disconnected"){
			GuiControlGet,conn_,1:, conn
			if(conn_!="no connection")
				conn_n:="no connection"
			;if(conn_ != conn_old)
			;GuiControl,,conn, % conn_n
			;conn_old:=conn_n
		}		
return

get_up_down_data:
/* 	
	;===== test
	Random, RanUpRate, 1,100
	Random, RanDownRate, 1, 1000
	RanUpRate:=RanUpRate*1000
	RanDownRate:=RanDownRate*1000
	DownRate:=RanDownRate
  UpRate:=RanUpRate
	;===== test
	 */
	
 	Net.Update()
	DownRate:=Net.RxBPS
  UpRate:=Net.TxBPS



 	if(UpRate<0 || DownRate<0 ){     ; bug fix in resume from standby 
			;data_s:=A_MMM A_DD " " A_Hour ":" A_Min ":" A_Sec "`n" "DownRate: " DownRate " | UpRate: " UpRate 
			;FileAppend, % "`n`nNetMon error UpRate<0 || DownRate<0 " data_s , %log_file%
		return
	}
	
	DownRate_perc:= Round(DownRate/max_down,2) ;*100
	UpRate_perc:= Round(UpRate/max_up, 2)	 ;*100
	
	downRate_draw:=Round(grid_h - grid_h*(DownRate_perc))	
	UpRate_draw:=Round(grid_h - grid_h*(UpRate_perc))
	
	array_down.InsertAt(1,downRate_draw)
	array_down.Pop()

	array_up.InsertAt(1,UpRate_draw)
	array_up.Pop()
	
	DownRate_f:=Size_format(DownRate)
	UpRate_f:=Size_format(UpRate)
	
	DownRate_b:= (DownRate==0) ? "" : Size_format_bar(DownRate)
	UpRate_b:= (UpRate==0) ? "" : Size_format_bar(UpRate)
	


		if(DownRate_f != DownRate_old){
			GuiControl,, down_speed, %DownRate_f% 
			DownRate_old:=DownRate_f
		}

		if(UpRate_f != UpRate_old){
			GuiControl,, up_speed, %UpRate_f% 
			UpRate_old:=UpRate_f
		}


	 
	if(UpRate>10000000 || DownRate>10000000){     ; bug fix in resume from standby 		
		;if(UpRate!=0 || DownRate!=0){
		;	data_s:=A_MMM A_DD " " A_Hour ":" A_Min ":" A_Sec "`n" "DownRate: " DownRate " | UpRate: " UpRate "  ||  " "today_down: " today_down " | today_up: " today_up
			;FileAppend, % "`n`nNetMon  UpRate>10000000 || DownRate>10000000  " data_s , %log_file% ;C:\a\x\log_AHKfile_temp.txt 
		;return
	}else{
		today_down:= today_down + DownRate
		today_up:= today_up + UpRate
		
		total_down:= total_down + DownRate
		total_up := total_up + UpRate		
	
	

		if(UpRate>old_peak_up){
			old_peak_up:=UpRate
			if(UpRate>10000){
				IniWrite, % old_peak_up " | " Size_format(old_peak_up) " | " A_Now , %settings_ini%, TEMP, peak_up
			}
		}
			
		if(DownRate>old_peak_down){
			old_peak_down:=DownRate
			if(DownRate>100000){
				IniWrite, % old_peak_down  " | " Size_format(old_peak_down) " | " A_Now , %settings_ini%, TEMP, peak_down
			}
		}
	}
	

/* 	today_down:= today_down + DownRate
	today_up:= today_up + UpRate
	
	total_down:= total_down + DownRate
	total_up := total_up + UpRate		
	 */
	 
		total_down_show:=Size_format(total_down,1)
		total_up_show:=Size_format(total_up,1) 
		
		if(total_down_show != total_down_old){
			GuiControl,, cumul_down_tot , %total_down_show%
			total_down_old:=total_down_show
		}

		if(total_up_show != total_up_old){
			GuiControl,, cumul_up_tot, %total_up_show%  
			total_up_old:=total_up_show
		}
		
		down_now_show:=Size_format(today_down) 
		up_now_show:=Size_format(today_up)
		
		if(down_now_show != down_now_show_old){
			GuiControl,, down_cumul_today , %down_now_show%  
			down_now_show_old:=down_now_show
		}
		
		if(up_now_show != up_now_show_old){
			GuiControl,, up_cumul_today, %up_now_show%
			up_now_show_old:=up_now_show
		}		
		


	
/* 
	DownRate_f:=Size_format_file(DownRate)
	UpRate_f:=Size_format_file(UpRate)
	GuiControl,, down_speed, %DownRate_f% 
	GuiControl,, up_speed, %UpRate_f% 
	
	GuiControl,, down_cumul_today , % Size_format(today_down)  
	GuiControl,, up_cumul_today, % Size_format(today_up)
	
	GuiControl,, cumul_down_tot , % Size_format(total_down)  
	GuiControl,, cumul_up_tot, % Size_format(total_up)  
 */

	
 ;gradient: "grad_color_rim|grad_color_mid|width"

	grad_col_red:="0xff4C2700|0xffDC1904|6"  
	grad_col_green:="0xff004614|0xff03AF34|6"	
	
	
	GoSub, grid_NET
	
	if(showPeaks!=1){
		GoSub, bars_horizontal
	}
	
	if(show_vert_bars){
		GoSub, bars_vertical
	}
return



bars_horizontal:	
	Gdip_SetProgress(Bar_up_h, UpRate_perc*100, grad_col_red, 0xff2C2C2C,UpRate_b ,"x0p y4p s78p Center cffEEEEEE r5 Bold","Arial")
	Gdip_SetProgress(Bar_dn_h, DownRate_perc*100, grad_col_green, 0xff2C2C2C,DownRate_b ,"x0p y4p s78p Center cffEEEEEE r5 Bold","Arial") 
return

bars_vertical:
	Gdip_SetProgress_vert(Bar_dn_v, DownRate_perc*100, "0xff004614|0xff01DC3F|4", 0xff161616) 
	Gdip_SetProgress_vert(Bar_up_v, UpRate_perc*100, "0xff4C2700|0xffFD1900|4", 0xff161616 ) 
return

/* grid_NET:
Gdip_Set_Grid(Grid_img_in, array_down,0xff0BAC00, 0xFF131313) 
Gdip_Set_Grid(Grid_img_out,array_up ,0xffBC0032, 0xFF131313) 
return
 */
 
grid_NET:
if(showScaleInfo!=1){
	Gdip_Set_Grid(Grid_img_in, array_down,0xff0BAC00, 0xFF131313) 
	Gdip_Set_Grid(Grid_img_out,array_up ,0xffBC0032, 0xFF131313) 
}else {
	show_max_down:=Size_format(max_down,1) 
	show_max_up:=Size_format(max_up,1)	
	Gdip_Set_Grid(Grid_img_in, array_down,0xff0BAC00, 0xFF131313,"scale: " show_max_down,"x0p y22p s38p Center caaEEEEEE r5 Bold") 
	Gdip_Set_Grid(Grid_img_out,array_up ,0xffBC0032, 0xFF131313,"scale: " show_max_up,"x0p y22p s38p Center caaEEEEEE r5 Bold")
}
return

Gdip_Set_Grid(ByRef Variable, ByRef array, Foreground=0xffE36524, Background=0xFF101010, Text="", TextOptions="x0p y20p s48p Center caaEEEEEE r5 Bold", Font="Arial"){ 
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	
	pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)	

	pBrushBack := Gdip_BrushCreateSolid(Background)	
	Gdip_FillRectangle(G, pBrushBack, 0, 0, PosW-1, PosH-1)	
		;pBrushFront := Gdip_BrushCreateSolid(Foreground)
    ;Gdip_FillRectangle(G, pBrushFront, 0, 0, 50, Posh)
  
		;<==== Grid		
    pPen:=Gdip_CreatePen(0xff2E5050, 1)
    w:=PosW -2 ,  h:=PosH-2
    
	Loop, 4 {
    y:=A_Index*6
		Gdip_DrawLine(G, pPen, 1, y, w, y)
  } 

  Loop, 14 {
    x:=A_Index*8
		Gdip_DrawLine(G, pPen, x, 1, x, h)
  } 
  ;====> Grid
	
	;<==== plot
	; grid_h:29, grid_w:=121
	points:="0,29|121,29|"	
  Loop, % array.Length() {
    x:=121 - A_Index
		y:=array[A_Index]
    points:= points  x "," y "|"
  } 	
	points:= points x ",29"
	
		pBrushFront := Gdip_BrushCreateSolid(Foreground)
    pPath := Gdip_CreatePath(0)
    Gdip_AddPathPolygon(pPath,points)  
    Gdip_FillPath(G,pBrushFront, pPath) 

/* 		pPen:=Gdip_CreatePen(0xffDC1904, 1)
		Loop, % array.Length() {
			x:=121 - A_Index
			y:=array[A_Index]
			points2:= points2  x "," y "|"
		} 	
		Gdip_DrawLines(G, pPen, points2)  ; not filled
		 */
	Gdip_TextToGraphics(G, Text, TextOptions, Font, Posw, Posh)
	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack), Gdip_DeletePath(pPath), Gdip_DeletePen(pPen)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}


;=============================


Gdip_SetProgress(ByRef Variable, Percentage, Foreground, Background=0xff2C2C2C, Text="", TextOptions="x0p y2p s80p Center cffEEEEEE r5 Bold", Font="Arial"){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	
	pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)	

	pBrushBack := Gdip_BrushCreateSolid(Background)	
	;Gdip_FillRectangle(G, pBrushBack,0, 0, Posw, Posh)	
	Gdip_FillRectangle(G, pBrushBack,-1, -1, Posw+1, Posh+1)	
	
	Foreground_:=StrSplit(Foreground,"|")
	if(Foreground_.Length() >1){
		;=== with gradient =====
		;pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, 10, grad_color1, grad_color2 ,1) 
		grad_color_rim:=Foreground_[1]
		grad_color_mid:=Foreground_[2]
		size:=Foreground_[3]
		pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, size, grad_color_rim, grad_color_mid ,1) 
		Gdip_FillRectangle(G, pBrushFront,0, 0,  Posw*(Percentage/100), Posh)
	;========
	}else{
		pBrushFront := Gdip_BrushCreateSolid(Foreground)
		Gdip_FillRectangle(G, pBrushFront, 0, 0, Posw*(Percentage/100), Posh)
	}

	Gdip_TextToGraphics(G, Text, TextOptions, Font, Posw, Posh)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}

;==============================

Gdip_SetProgress_vert(ByRef Variable, Percentage, Foreground, Background=0xFF131313){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	
	pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)	

	Foreground_:=StrSplit(Foreground,"|")
	if(Foreground_.Length() >1){
		;=== with gradient =====
		grad_color_rim:=Foreground_[1]
		grad_color_mid:=Foreground_[2]
		size:=Foreground_[3]
	
		pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, size, 1, grad_color_rim, grad_color_mid ,0) 
		Gdip_FillRectangle(G, pBrushFront, -1, -1, PosW+1, PosH+1)
	;========
	}else{
		pBrushFront := Gdip_BrushCreateSolid(Foreground)
		Gdip_FillRectangle(G, pBrushFront, -1, -1, PosW, PosH +1)		
	}

	pBrushBack := Gdip_BrushCreateSolid(Background)
	Gdip_FillRectangle(G, pBrushBack, -1, -1, PosW+2, PosH -(PosH)*(Percentage/100)+1)
	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}

;=============================
;=============================


bgrd:
	IniRead, bgrd_style, %settings_ini%, Window , GUI_style	
	if(bgrd_style=="dots"){
		Gdip_Set_bgrd(bgrd, bgrd_grad,6) ; dots
	}else if(bgrd_style=="dots2"){	
		Gdip_Set_bgrd(bgrd, bgrd_grad,35) ; dots
	}else if(bgrd_style=="bricks"){
		Gdip_Set_bgrd(bgrd, bgrd_grad,39) ; bricks
	}else{
		Gdip_Set_bgrd(bgrd, bgrd_grad) 
	}
	;Gdip_Set_bgrd(bgrd, bgrd_grad) 
	;Gdip_Set_bgrd(bgrd, "0xff0F0F0F|0xff222222|25" ) ;black
	;Gdip_Set_bgrd(bgrd, "0xff2D3F5D|0xff1A2333|25" ) ; bl steel

	;Gdip_Set_bgrd(bgrd, "0xff00290C|0xff1C4527|75" ) ; green
	;Gdip_Set_bgrd(bgrd, "0xff012243|0xff13365A|75" ) ;blue
return



Gdip_Set_bgrd(ByRef Variable, Background=0x00000000,Hatch=0){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	;PosH:=PosH + 5 , PosW:=PosW + 5
	pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)	
	
	Background_:=StrSplit(Background,"|")
	if(Background_.Length() >1){
		;=== with gradient =====
		;pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, 10, grad_color1, grad_color2 ,1) 
		grad_color_rim:=Background_[1]
		grad_color_mid:=Background_[2]
		size:=Background_[3]
    ;MsgBox,,, %  grad_color_mid "`n" grad_color_rim, 6  
		
		if(Hatch=0){
			pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, size, grad_color_rim, grad_color_mid ,1) 
		}else{
			pBrushFront :=Gdip_BrushCreateHatch(grad_color_rim, grad_color_mid, Hatch) ; kropki
		}

		;Gdip_FillRectangle(G, pBrushFront,0, 0,  PosW, Posh)
		Gdip_FillRectangle(G, pBrushFront,-1, -1,  PosW+1, Posh+1)
	;========
	}else{
		pBrushBack := Gdip_BrushCreateSolid(Background)
		Gdip_FillRectangle(G, pBrushBack, 0, 0, PosW, Posh)
	}
	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}

;=============================

ramka:
	Gdip_Set_ramka(ramkaT,"0xff383D46|0xff1E2126|8",0)

	Gdip_Set_ramka(ramka1,bgrd_ramki_1)
	Gdip_Set_ramka(ramka2,bgrd_ramki_1)
	
	Gdip_Set_ramka(ramka31,bgrd_ramki_2)
	Gdip_Set_ramka(ramka32,bgrd_ramki_2)
	Gdip_Set_ramka(ramka41,bgrd_ramki_2)
	Gdip_Set_ramka(ramka42,bgrd_ramki_2)	
	
return

Gdip_Set_ramka(ByRef Variable, Background=0x00000000,border=0,Hatch=0){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)	

	
	Background_:=StrSplit(Background,"|")
	if(Background_.Length() >1){
		;=== with gradient =====
		;pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, 10, grad_color1, grad_color2 ,1) 
		grad_color_rim:=Background_[1]
		grad_color_mid:=Background_[2]
		size:=Background_[3]
	
		if(Hatch=0){
			pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, size, grad_color_rim, grad_color_mid ,1) 
		}else{
			pBrushFront :=Gdip_BrushCreateHatch(grad_color_rim, grad_color_mid, Hatch) 
		}

		Gdip_FillRectangle(G, pBrushFront,-1, -1,  PosW+1, Posh+1)
	;========
	}else{
		pBrushBack := Gdip_BrushCreateSolid(Background)
		;Gdip_FillRectangle(G, pBrushBack,-1, -1, PosW+1, Posh+1)
		;Gdip_FillRectangle(G, pBrushBack,-1, 0,  PosW-1, PosH)
		Gdip_FillRectangle(G, pBrushBack,-1, -1,  PosW, PosH+1)
	}
	
	if(border=1){
		pPen:=Gdip_CreatePen(0xffBABABA, 1)
		points:=  "0,0|" PosW ",0|" PosW "," PosH-1 "|" 0 "," PosH-1 "|0,0"  
		Gdip_DrawLines(G, pPen, points)  
	}	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack) , Gdip_DeletePen(pPen)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}

;=============================

Gdip_icon_switch(ByRef Variable, col1:=0xff7C95EF,col2:=0xff52639F,col3:=0xff3A4672,flip:=0){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	
	pBitmap := Gdip_CreateBitmap(PosW, PosH), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)			
	
	pPen1:=Gdip_CreatePen(col1, 1), pPen2:=Gdip_CreatePen(col2, 1), pPen3:=Gdip_CreatePen(col3, 1)

	Gdip_DrawLine(G, pPen1, Round(PosW*0.15) ,Round(PosH*0.33) , Round(PosW*0.86) ,Round(PosH*0.33))
	Gdip_DrawLine(G, pPen2, Round(PosW*0.25) ,Round(PosH*0.5) , Round(PosW*0.75) ,Round(PosH*0.5))
	Gdip_DrawLine(G, pPen3, Round(PosW*0.40) ,Round(PosH*0.67) , Round(PosW*0.63),Round(PosH*0.67))
	
	Gdip_ImageRotateFlip(pBitmap,flip)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeletePen(pPen1), Gdip_DeletePen(pPen2), Gdip_DeletePen(pPen3)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}

;=============================

draw_icons:
	Gdip_draw_arrow(arrowDown,0xff00A153,2)
	Gdip_draw_arrow(arrowUp,0xffCB0011,0)
	Gdip_draw_arrow(arrowDown2,0xff00A153,2)
	Gdip_draw_arrow(arrowUp2,0xffCB0011,0)		
return


Gdip_draw_arrow(ByRef Variable, Foreground,flip:=0){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	
	pBitmap := Gdip_CreateBitmap(PosW, PosH), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)	
	pPen:=Gdip_CreatePen(Foreground, 1)

		points:= PosW/2 ",0|" 0.9* PosW "," 0.4* PosH "|" 0.66* PosW "," 0.4* PosH "|" 0.66* PosW "," PosH "|" 0.33* PosW "," PosH 
		points:= points "|" 0.33* PosW "," 0.4* PosH "|" 0.33* PosW ","  0.4* PosH "|" 0.1* PosW "," 0.4* PosH "|" PosW/2 ",0"
	
		pBrushFront := Gdip_BrushCreateSolid(Foreground)
    pPath := Gdip_CreatePath(0)
    Gdip_AddPathPolygon(pPath,points)  
    Gdip_FillPath(G,pBrushFront, pPath) 
		
	Gdip_ImageRotateFlip(pBitmap,flip)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeletePen(pPen), Gdip_DeletePath(pPath)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}

;======================================



;==============================

Settings:
Gui,4:+owner1 
Gui,4:+ToolWindow
Gui,4:Add, Button , x46  y260 w60 h22  gSaveSet , Save
Gui,4:Add, Button , x140 y260 w60 h22  gCancel_but , Cancel

Gui,4: Font, S8  , Segoe UI Bold ;
Gui,4:Add, Text,  x65 y10   , Graph grid scale

Gui,4: Font, S8 W400 , Tahoma 
Gui,4: Add, GroupBox,  x10 y0 w240 h254  ,

Gui,4:Add, Text,  x20 y32   ,  Max download rate (kB/s)
Gui,4:Add, Edit, x160 y26 w60 vMax_down_ , 
Gui,4:Add, Text,  x20 y55   ,  Max upload rate (kB/s)
Gui,4:Add, Edit, x160 y52 w60 vMax_up_ , 

Gui,4:Add, Text,  x20 y84   , window position: x= 
Gui,4:Add, Text,  x168 y83  ,  y=
Gui,4:Add, Edit, x120 y80 w35 vSett_x , 1460
Gui,4:Add, Edit, x186 y80 w35 vSett_y , 317

Gui,4: Font, S7 W400 , Segoe UI 

Gui,4:Add, Text,  x20 y110   ,  Version 
Gui,4:Add, Radio,  x60 y110 vVersion1 Checked , 1
Gui,4:Add, Radio,  x90 y110  vVersion2 , 2

Gui,4:Add, Text,  x124 y110   ,  Show vertical bars
Gui,4:Add, Checkbox,  x205 y110  vShow_vert , 

Gui,4: Font, S8 W400 , Tahoma 
Gui,4:Add, Text,  x20 y140   ,  Net usage since: 
Gui,4:Add, Text,  x20 y161   ,  total download:  
Gui,4:Add, Text,  x20 y182   ,  total upload:

Gui,4:Add, Edit,  x110 y136 w114 vSett_date ReadOnly ,  
Gui,4:Add, Edit,  x110 y158 w114 vSett_down ReadOnly ,  
Gui,4:Add, Edit,  x110 y180 w114 vSett_up  ReadOnly,  

Gui,4: Font, S7 W700 ,  Tahoma 
Gui,4:Add, Text,  x12 y210 w230  Center , % Net.Description
Gui,4: Font, S8 W400 , Segoe UI 
Gui,4:Add, Text,  x20 y230 w100   , Local IP Address: 
Gui,4:Add, Text,  x120 y230 w110  Center , %A_IPAddress1%

Gui, 4:Show, w260 h290 , Drozd net monitor settings
Gosub, Load_Settings	

return 

Load_Settings:	
	IniRead, max_up_, %settings_ini%, Graph scale, maximum upload rate
	IniRead, max_down_, %settings_ini%, Graph scale, max download rate
	IniRead, Day_cumul_raw, %settings_ini%, Statistics, start cumulation date
	;IniRead, total_up_saved, %settings_ini%, Statistics, total upload
	;IniRead, total_down_saved, %settings_ini%, Statistics, total download
	
	FormatTime, Date_cumul, %Day_cumul_raw%,  MMM d, yyyy, HH:mm 
		
	GuiControl,4:, Max_down_, %max_down_%
	GuiControl,4:, Max_up_, %max_up_%
	
	GuiControl,4:, Sett_date, %Date_cumul%
	;GuiControl,4:, Sett_down, % Size_format_file(total_down_saved)
	;GuiControl,4:, Sett_up, % Size_format_file(total_up_saved)
	GuiControl,4:, Sett_down, % Size_format(total_down)
	GuiControl,4:, Sett_up, % Size_format(total_up)	
	
	IniRead, x1, %settings_ini%, window position, x	
	IniRead, y1, %settings_ini%, window position, y	
	;WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	GuiControl,4:, Sett_x, %x1%  
	GuiControl,4:, Sett_y, %y1%
	
	IniRead, Show_vert_, %settings_ini%, Window, Show vertical bars
	if(Show_vert_==0 || Show_vert_==1){
		GuiControl,4:, Show_vert, %Show_vert_%	
	}
	
	IniRead, ver, %settings_ini%, Window, Version
	if(ver==1){
		GuiControl, 4:, Version1 , 1
	}else if(ver==2){
		GuiControl, 4:, Version2 , 1
	}
return

SaveSet:
	Gui, Submit, Nohide
		IniWrite, %max_up_% , %settings_ini%, Graph scale, maximum upload rate
		IniWrite, %max_down_%, %settings_ini%, Graph scale, max download rate
		IniWrite, %Sett_x% , %settings_ini%, window position, x
		IniWrite, %Sett_y%, %settings_ini%,window position, y		
		
		IniWrite, %Show_vert%, %settings_ini%, Window, Show vertical bars		

		max_up:= max_up_*1000, max_down:= max_down_*1000
		GuiControlGet,v1,4:, Version1
		GuiControlGet,v2,4:, Version2
		if(v1==1){
			ver:=1 
		}else if(v2==1){
			ver:=2
		}
		IniWrite, %ver%, %settings_ini%, Window , Version		
		
		;IniWrite, %total_up%	, %settings_ini%, Statistics, total upload
		;IniWrite, %total_down%	, %settings_ini%, Statistics, total download
		;IniWrite, % A_Now	, %settings_ini%, Drozd net monitor, start cumulation date
	Gui,4: Destroy
return

Cancel_but:
Gui,4: Destroy
return


Save_data:
	IniWrite, %total_up%, %settings_ini%, Statistics, total upload
	IniWrite, %total_down%	, %settings_ini%, Statistics, total download
	IniWrite, %today_up%, %settings_ini%, Statistics, current upload
	IniWrite, %today_down%	, %settings_ini%, Statistics, current download	
	
	IniWrite, % Size_format_file(total_up), %settings_ini%, Statistics format, total upload
	IniWrite, % Size_format_file(total_down)	, %settings_ini%, Statistics format, total download
	IniWrite, % Size_format_file(today_up), %settings_ini%, Statistics format, current upload
	IniWrite, % Size_format_file(today_down)	, %settings_ini%, Statistics format, current download
return

Save_data_exit:
	IniWrite, %total_up%, %settings_ini%, Statistics, total upload
	IniWrite, %total_down%	, %settings_ini%, Statistics, total download
	IniWrite, %today_up%, %settings_ini%, Statistics, current upload
	IniWrite, %today_down%	, %settings_ini%, Statistics, current download
	Gosub, Exit 
return


Get_Saved_data:
	;IniRead, Day_cumul_raw, %settings_ini%, Statistics, start cumulation date
	IniRead, total_down_saved, %settings_ini%, Statistics, total download	
	IniRead, total_up_saved, %settings_ini%, Statistics, total upload
	if(total_down_saved!="ERROR" && total_down_saved!="" ){
		total_down:=total_down_saved 
  } 
	if(total_up_saved!="ERROR" && total_up_saved!=""){
		total_up :=total_up_saved 
  } 

	IniRead, today_down_saved , %settings_ini%, Statistics, current download
	IniRead, today_up_saved, %settings_ini%, Statistics, current upload	
	
	if(today_down_saved!="ERROR" && today_down_saved!="" && today_up_saved!="ERROR" && today_up_saved!=""){
		today_down:=today_down_saved , today_up :=today_up_saved
	}

return
;==============================


Size_format_bar(bytes,round:=0){
    size:=0
		 
    if(!bytes || bytes == 0){
				size :=0 ;" kB"				
    }else if(bytes >= 1000000000){
        if(Mod(bytes,1000000000) < 100000000){ ; 0.1 GB
            size :=Round(bytes/1000000000,0) " GB"
        }else			
        size :=Round(bytes/1000000000,1) " GB"
    }else if(bytes >= 500000){
			if(round){
				size :=Round(bytes/1000000,0) " MB"
			}else	
				size :=Round(bytes/1000000,1) " MB"	
    }else if(bytes >= 10000){
            size :=Round(bytes/1000) " kB"
            
/*     }else if(bytes < 100){
				;size :=Round(bytes/1000,2) " kB "
        size := "< 0.1 kB"
        */ 
    }else if(bytes && bytes < 100 ){
        size := bytes " B" 
    }else{
            size :=Round(bytes/1000,1) " kB" 
    }            
			return size
}

Size_format(bytes,round:=0){
      size:=0
		if(bytes >= 1000000000000){		
			size :=Round(bytes/1000000000000,2) " TB"
    }else if(bytes >= 1000000000){
        size :=Round(bytes/1000000000,2) " GB"
    }else if(bytes >= 1000000){
			if(round){
				size :=Round(bytes/1000000,0) " MB"
			}else	
				size :=Round(bytes/1000000,1) " MB"					
    }else if(bytes >= 1000) {
				size :=Round(bytes/1000) " kB"
		}else if(!bytes || bytes == 0){
				size :=0 " kB"
    }else{
				size := bytes " B"               
    } 
			return size
}

Size_format_file(bytes,round:=0){
      size:=0
    if(bytes >= 1073741824){
        if(Mod(bytes,1073741824) < 107374182){ ; 0.1 GB
            size :=Round(bytes/1073741824,0) " GB"
        }else			
        size :=Round(bytes/1073741824,2) " GB"
    }else if (bytes >= 1048576){
			if(round){
				size :=Round(bytes/1048576,0) " MB"
			}else	
				size :=Round(bytes/1048576,1) " MB"				
    }else if (bytes >= 1024){
				size :=Round(bytes/1024) " kB"
		}else if (bytes == 0){
				size :=0				
    }else {
			if(round){
				size := bytes 
			}else	
				size := bytes " B"               
    } 
			return size
 }



;=========================================

InternetConnection(flag=0x40) { 
	return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0) 
}

;=========================================


Reset_cumul_Total:
	Gui, Submit, Nohide
	FormatTime, Date_cumul, %Day_cumul_raw%,  MMM d, HH:mm 
	message:="Reset net usage data since " Date_cumul "?"
	;confirm:=DllCall("MessageBox","Uint",0,"Str",message,"Str","Reset total","Uint","0x00040004L")
	confirm:=DllCall("MessageBox","Uint",0,"Str","Reset today net usage data?","Str","Reset today","Uint","0x00040104L") ;+100 No default
	if(confirm==6){
		Gosub, archive_total
		total_down:=0 
		total_up :=0
		Day_cumul_raw:=A_Now
		IniWrite, %Day_cumul_raw% , %settings_ini%, Statistics, start cumulation date		
		IniWrite, 0, %settings_ini%, Statistics, total upload
		IniWrite, 0	, %settings_ini%, Statistics, total download
		
		FormatTime, Day_cumul, %Day_cumul_raw%, MMMd 
		GuiControl, ,  DaySince, %Day_cumul%
	}
  
return


Reset_cumul_Today:
	;Yes=6 No=7
	;confirm:=DllCall("MessageBox","Uint",0,"Str","Reset today net usage data?","Str","Reset today","Uint","0x00040004L")
	confirm:=DllCall("MessageBox","Uint",0,"Str","Reset today net usage data?","Str","Reset today","Uint","0x00040104L") ;+100 No default
	if(confirm==6){
		Gosub, archive_today
		today_down:= 0
		today_up:=0
		GuiControl,, down_cumul_today , % Size_format_file(today_down)  
		GuiControl,, up_cumul_today, % Size_format_file(today_up)  
	
		IniWrite, 0, %settings_ini%, Statistics, current upload
		IniWrite, 0	, %settings_ini%, Statistics, current download
	}
return


archive_today:
		IniRead, today_data_log, %settings_ini%, TEMP, today log
		today_data_log:= (today_data_log=="ERROR") ? "" : today_data_log
		today_data_log:=SubStr(today_data_log,1, 240)
		data_reg:= A_MMM A_DD " " A_Hour ":" A_Min  ", " "down=" Size_format(today_down) ", up=" Size_format(today_up) " | "
			if InStr(today_data_log,A_MMM A_DD " " A_Hour ":" A_Min)
				return
		data_reg:= " " data_reg today_data_log
		IniWrite, %data_reg% , %settings_ini%, TEMP, today log		
return

archive_total:
		IniRead, Day_cumul_raw, %settings_ini%, Statistics, start cumulation date
		FormatTime, Day_cumul, %Day_cumul_raw%, MMMd HH:mm
		
		IniRead, total_data_log, %settings_ini%, TEMP, total log
		total_data_log:= (total_data_log=="ERROR") ? "" : total_data_log	
		total_data_log:=SubStr(total_data_log,1, 360)

		data_reg:= A_MMM A_DD " " A_Hour ":" A_Min  ", down=" Size_format(total_down) ", up=" Size_format(total_up) ", Since: " Day_cumul " | "
		data_reg:= " " data_reg total_data_log
		IniWrite, %data_reg% , %settings_ini%, TEMP, total log		
		;FileAppend, %  "`n`n" data_reg  , %log_file%	
return


;=========================================

save_position:
	WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	IniWrite, %x1%	, %settings_ini%, window position, x
	IniWrite, %y1%	, %settings_ini%, window position, y
return


clear_peaks:
old_peak_up:=0 , old_peak_down:=0 
return


Open_ini:
Run, %settings_ini%
return

Open_log:
Run, %log_file%
return


show_help:
Progress, zh0 w600 M2 C0y ZX20 ZY10 CWFFFFFF FS8 FM10 WM700 WS700 ,%help%, Drozd Net Monitor , Drozd Net Monitor Help, Segoe UI Semibold
return
;=========================================

set_bgrd_black:
	IniWrite, %bgrd_grad_black%	, %settings_ini%, Window , background color
	IniWrite, %bgrd_ramki_black%	, %settings_ini%, Window, GUI_buttons_1
	IniWrite, %bgrd_ramki_black%	, %settings_ini%, Window, GUI_buttons_2
return

set_bgrd_steel:
	IniWrite, %bgrd_grad_steel%	, %settings_ini%, Window , background color
	IniWrite, %bgrd_ramki_steel%	, %settings_ini%, Window, GUI_buttons_1
	IniWrite, %bgrd_ramki_steel%	, %settings_ini%, Window, GUI_buttons_2
return

set_bgrd_blue:
	IniWrite, %bgrd_grad_blue%	, %settings_ini%, Window , background color
	IniWrite, %bgrd_ramki_blue%	, %settings_ini%, Window, GUI_buttons_1
	IniWrite, %bgrd_ramki_blue%	, %settings_ini%, Window, GUI_buttons_2
return

set_bgrd_green:
	IniWrite, %bgrd_grad_green%	, %settings_ini%, Window , background color
	IniWrite, %bgrd_ramki_green%	, %settings_ini%, Window, GUI_buttons_1
	IniWrite, %bgrd_ramki_green%	, %settings_ini%, Window, GUI_buttons_2
return



set_bgrd_style_bricks:
	bgrd_style:="bricks" 
	IniWrite, %bgrd_style%	, %settings_ini%, Window, GUI_style
return

set_bgrd_style_dots:
	bgrd_style:="dots"
	IniWrite, %bgrd_style%	, %settings_ini%, Window, GUI_style
return

set_bgrd_style_dots2:
bgrd_style:="dots2"
IniWrite, %bgrd_style%	, %settings_ini%, Window, GUI_style
return

reset_bgrd:
	bgrd_style:=""
	IniDelete, %settings_ini%, Window,
	IniWrite, %bgrd_grad_black%	, %settings_ini%, Window , background color
	IniWrite, %bgrd_ramki_black%	, %settings_ini%, Window, GUI_buttons_1
	IniWrite, %bgrd_ramki_black%	, %settings_ini%, Window, GUI_buttons_2
return
;=========================================


onTop:        
		if WonTop {
			WinSet, AlwaysOnTop, off, Drozd_net_monitor
			GuiControl, Show, onTop_off
			GuiControl, Hide, onTop_on
			WonTop:=0	
		}else{
			WinSet, AlwaysOnTop, on, Drozd_net_monitor
			GuiControl, Show, onTop_on
			GuiControl, Hide, onTop_off	
			WonTop:=1			
		}	
return

;=========================================
net_on:
		if(netOn) {
			GuiControl, Show, net_on_ 
			GuiControl, Hide, net_Off_
		}else{
			GuiControl, Hide, net_On_			
			GuiControl, Show, net_Off_
		}	
return

;===============

PeakDown: 
PeakUp:
Gdip_SetProgress(Bar_dn_h, Round(old_peak_down/max_down,2)*100, grad_col_green, 0xff2C2C2C,"peak: " Size_format(old_peak_down) ,"x0p y3p s78p Center cffEEEEEE r5 Bold","Arial") 
Gdip_SetProgress(Bar_up_h,  Round(old_peak_up/max_up,2)*100, grad_col_red, 0xff2C2C2C,"peak: " Size_format(old_peak_up) ,"x0p y3p s78p Center cffEEEEEE r5 Bold","Arial")
	showPeaks:=1
	SetTimer, showPeaksClear ,-3000
return

showPeaksClear:
	showPeaks:=0
	SetTimer, showPeaksClear ,Off
return

;=========================================

Get_IP:
	SetTimer, check_connection ,Off
	GuiControl,1:, conn,
	GuiControl, Move, conn, x15 y127 ; x15 y128
	Gui, Font , s7 w400 cE1E1E1 ,  ;, Segoe UI ; S6 w400 cE1E1E1, Arial
	GuiControl, Font, conn
	GuiControl,1:, conn, local: %A_IPAddress1%

	SetTimer, Get_IP_external ,-3000
	SetTimer, Set_Timer ,8000
return


MsgMonitor_IP(wParam){	
		global ext_IP
		if(wParam==210){
			if(!ext_IP){
				if(lParam==1){
					GuiControl,1:, conn, IP: error ;Ø
				}else
					return
			}else{
				GuiControl,1:, conn,
				GuiControl, Move, conn, x15 y127 ; x15 y128
				Gui, Font , s7 w700, Arial ; , Segoe UI; S6 w400 cE1E1E1, Arial
				GuiControl, Font, conn
				GuiControl,1:, conn, IP: %ext_IP%
			}		
		}		
}

Get_IP_external:
	if !InternetConnection()
		return
	SetTimer, check_connection ,Off
	GuiControl,1:, conn,
	HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")     
	HttpObj.Open("GET","http://checkip.dyndns.org/")    
	;HttpObj.Open("GET","http://192.168.0.1/modemstatus_home.html") 
	ComObjError(false) ; suppress error message	
	HttpObj.Send()    
		Response:=HttpObj.ResponseText
		RegExMatch(Response,"im)Current IP Address:\s+(\d+\.\d+\.\d+\.\d+)", out)
	ext_IP:=out1
	PostMessage, 0x6555, 210, ,, ahk_id %GuiHwnd%  ; OnMessage(0x6555, "MsgMonitor_IP")
	
/* 	if(!out1){
		GuiControl,1:, conn, IP: error ;Ø
	}else{
		GuiControl, Move, conn, x15 y127 ; x15 y128
		Gui, Font , s7 w700 ; , Segoe UI; S6 w400 cE1E1E1, Arial
		GuiControl, Font, conn
		GuiControl,1:, conn, IP: %out1%
	}
	 */
	;SetTimer, Set_Timer ,8000
return

Set_Timer:
	SetTimer, Set_Timer ,Off
	GuiControl,1:, conn,
	GuiControl, Move, conn, x15 y128
	Gui, Font , s6 w400 c8291C9, Arial 
	GuiControl, Font, conn
	Gosub, check_connection
	SetTimer, check_connection ,3000
	show_old_IP:=0
return


GoToSavedPos: ; DoubleClick
	;if A_GuiControlEvent <> DoubleClick
	;	return
	IniRead, pos_x_saved, %settings_ini%, window position, x	
	IniRead, pos_y_saved, %settings_ini%, window position, y	
	if(pos_x_saved<A_ScreenWidth-120 && pos_y_saved<A_ScreenHeight-140)
		WinMove,  Drozd_net_monitor, ,pos_x_saved,pos_y_saved
return

DoubleClick:
	;if A_GuiControlEvent <> DoubleClick
	;	return
return

DisableWindowsFeature(){ ; prevent copy to  clipboard when double clicked ; by just me autohotkey.com/boards/viewtopic.php?t=3569
   Static Dummy1 := OnMessage(0x00A3, "DisableWindowsFeature") ; WM_NCLBUTTONDBLCLK
   Static Dummy2 := OnMessage(0x0203, "DisableWindowsFeature") ; WM_LBUTTONDBLCLK
   If (A_GuiControl) {
      GuiControlGet, HCTRL, Hwnd, %A_GuiControl%
      WinGetClass, Class, ahk_id %HCTRL%
      If (Class = "Static")
				if(A_GuiControl="Drozd Net Monitor"){					
					Gosub, GoToSavedPos
				}			 
         Return 0
   }
}



;============================================

ScaleInfoShow:
	showScaleInfo:=1
	SetTimer, ScaleInfoHide ,-3000
return

ScaleInfoHide:
	SetTimer, ScaleInfoHide ,Off
	showScaleInfo:=0
return

;============================================
 
bigger:
	if(toggle_big==0){
		toggle_big:=1
		WinMove,  Drozd_net_monitor, ,,,,198
	}else if(toggle_big==1){
		toggle_big:=0
		WinMove,  Drozd_net_monitor, ,,,,143
	}
 
return


; ~$F4::
	; Gui 1: Show
; return



GuiContextMenu:
Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
Return

Reload:
Reload
return

WindowSpy:
Run, "C:\Program Files\AutoHotkey\WindowSpy.ahk"
return

Edit_Notepad:
Run, "C:\Program Files\Notepad++\Notepad++.exe" "%A_ScriptFullPath%"
return

Edit_Scite:
Run, "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"  "%A_ScriptFullPath%"
return


Close:
GuiClose:
;Esc:: 
Exit:
Gdip_Shutdown(pToken)
DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 200, "Int", 0x00050008 )
ExitApp





#Include C:\Program Files\AutoHotkey\Lib\XNET.ahk
#Include C:\Program Files\AutoHotkey\Lib\Gdip.ahk
