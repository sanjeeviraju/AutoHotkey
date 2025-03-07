#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
#NoTrayIcon


title:="ahk_class MainWindowClassName ahk_exe SystemInformer.exe"
path:="C:\Program Files\SystemInformer\SystemInformer.exe"

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