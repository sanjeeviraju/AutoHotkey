#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#SingleInstance Force

Menu, Tray, Icon, ..\Hotkeys\imports\Discord.ico

SoundSet, 15
Run, imports\Drozd_net_monitor_original.lnk
Run, imports\Hotkeys.ahk(elevated).lnk,,Hide
Run, Include\Startup.Discord.ahk,,hide
;Run, imports\windhawk.exe.lnk
;Run, Include\Startup.YouTube_Music.ahk,,hide
;Run, Include\Startup.Taiga.ahk
Run, Include\Startup.Systeminformer.ahk,,hide
ExitApp

` & Esc::ExitApp



