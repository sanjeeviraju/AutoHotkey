#If WinActive("Genshin Impact ahk_exe GenshinImpact.exe") OR WinActive("Honkai: Star Rail ahk_class UnityWndClass ahk_exe StarRail.exe")	  ;---------GENSHIN IMPACT-------------------------
F6::Send, {F6}
; F8::Goto, F6_Spotify
/::						;Chat
	Send, {/}
	Sleep, 300
	Click(705, 860)		;800, 1000
Return

!g::Send, #g			;game bar

~`::                        ;Elemental Sight
MButton::
    Send, {MButton Up}
    Sleep, 10
    Send, {MButton Down}
    loop {
        Sleep, 300
        If !WinActive("Genshin Impact ahk_exe GenshinImpact.exe") {
            Send, {MButton Up}
            break
        }
    }
Return

LAlt & d::GoTo, !d_Discord	;discord

~XButton1 & XButton2::Send, !{Esc}
~XButton2 & XButton1::Send, {Esc}

*RCtrl::Send, {LButton}	;Atk

+RCtrl::				;Charged Atk
*RAlt::
	Send, {LButton Down}
	; Sleep, 200
	Sleep, 350
	Send, {LButton Up}
Return

~f::Click, WheelDown 1	;interact

~Alt & CapsLock::		;SwitchDesktop()
~MButton & RButton::
#d::
Genshin_Boss_Key:
	Send, {g}
	; SoundSet, 0, , , 4
	SwitchDesktop()
Return

; #If (WinActive("ahk_exe GenshinImpact.exe") OR WinExist("ahk_group teyvat_map"))
; CapsLock::BossKey("ahk_group teyvat_map")	;Teyvat Interactive Map

#If