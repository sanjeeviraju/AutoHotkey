#NoEnv
#SingleInstance, Force
DetectHiddenWindows, On
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
#NoTrayIcon


; updater:="Discord Updater ahk_exe Discord.exe"
; loading:="ahk_exe Discord.exe"
; discord:="Friends - Discord ahk_class Chrome_WidgetWin_1 ahk_exe Discord.exe"
updater:="Legcord ahk_class Chrome_WidgetWin_1 ahk_exe Legcord.exe"
loading:="ahk_exe Legcord.exe"
discord:="• Discord | Friends ahk_class Chrome_WidgetWin_1 ahk_exe Legcord.exe"

Loop
{
    ; Check if Discord is already running
    ; if WinExist("ahk_exe Discord.exe")
    if WinExist("ahk_exe Legcord.exe")
    {
        ExitApp
    }

    ; Check if connected to the internet
    If IsConnectedToInternet()
    {
        ; Run, shell:AppsFolder\com.squirrel.Discord.Discord,, Min
        Run, shell:AppsFolder\app.legcord.Legcord,, Min

        WinWait, %updater%,, 10
        WinHide, %updater%

        WinWait, %loading%,,10, %updater%
        WinHide, %loading%,, %updater%

        WinWait, %discord%,,10, %updater%
        WinHide, %discord%,, %updater%
        ExitApp
    }
}
Return