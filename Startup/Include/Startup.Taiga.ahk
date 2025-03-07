#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
#NoTrayIcon


title:="Taiga ahk_exe Taiga.exe"
path:="Z:\Applications\Taiga\Taiga.exe"

Loop
{
    If IsConnectedToInternet()
    {
        If !WinExist(title) 
        {
            Run, %path%,, Min
            WinWait, %title%,,10
            WinHide, %title%
        }
        ExitApp
    }
}
Return