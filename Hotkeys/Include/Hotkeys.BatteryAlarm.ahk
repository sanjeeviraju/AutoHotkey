; Battery Alarm
Battery_Tan_Success := 0
Battery_Check:
ListLines, Off
VarSetCapacity(powerstatus, 1+1+1+1+4+4)
success := DllCall("kernel32.dll\GetSystemPowerStatus", "uint", &powerstatus)

AC_Status := ReadInteger(&powerstatus, 0, 1, false)
Battery_Life := ReadInteger(&powerstatus, 2, 1, false)

; Check for battery above 90%
If (Battery_Life > 90 AND AC_Status = 1)
{
    SoundPlay, %A_ScriptDir%\audios\Alarm_High.wav
    IfWinNotActive, ahk_group game
        SplashImage, %A_ScriptDir%\images\Battery-Tan-665x245.jpg, b,
    Else
        TrayTip("Battery Tan~", "Battery is above 90%, please unplug the charger (////)", 1)
    Sleep, 3000
    SplashImage, Off
    Sleep, 300000 ; 5 minutes
    Goto, Battery_Check ; Repeat after 5 minutes
}

; Check for battery below 40%
If ((Battery_Tan_Success < 1) AND ((AC_Status = 0 AND Battery_Life <= 40)))
{
    
    IfWinNotActive, ahk_group game
        TrayTip("Battery Tan~", "Battery is below 40%, please charge me (////)", 1)
    Sleep, 3000
    SplashImage, Off
    Battery_Tan_Success++
}
Else If ((Battery_Tan_Success = 1) AND ((Battery_Life = 41) OR (Battery_Life = 40)))
    Battery_Tan_Success := 0

; Critical battery level warning
If (Battery_Life = 10 AND AC_Status = 0)
{
    Loop, 10 {
        SplashImage, %A_ScriptDir%\images\Battery-Tan-665x245.jpg, b,
        Sleep, 100
        SplashImage, Off
        If AC_Status = 1
            Break
    } Until AC_Status = 1
    SplashImage, Off
}
Return

#If

TrayTip(Title, Text, Timeout) {
    TrayTip, %Title%, %Text%, %Timeout%
}
