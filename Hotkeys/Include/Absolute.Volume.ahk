#Persistent
#SingleInstance Force
#NoEnv

; Set default volume level to 0%
MaxVolume := 0

; Set custom tray icon (provide the path to your custom icon here)
Menu, Tray, Icon, Z:\Archive\Icons\icons8-mute-100.ico
; Tray menu items
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, NoStandard

; Immediately set volume to 0
SoundSet, %MaxVolume%

; Monitor volume level
SetTimer, MonitorVolume, 1000  ; Check every 1 second
return

; Monitor and enforce volume level
MonitorVolume:
    ; Always set volume to 0
    SoundSet, %MaxVolume%
return

; Exit script from tray
ExitScript:
    ExitApp
return
