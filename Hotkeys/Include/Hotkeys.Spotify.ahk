;-----------------------------------------------------------------------------------------------------------------------
;[F6] Spotify
;-----------------------------------------------------------------------------------------------------------------------
!s::
F6_Spotify:
WinGet, spotifyHwnd, ID, ahk_exe spotify.exe
WinGet, style, Style, ahk_id %spotifyHwnd%
if (style & 0x10000000) 	; WS_VISIBLE
{
	WinHide, ahk_id %spotifyHwnd%
	Send, !{Tab}
}Else {
	WinShow, ahk_id %spotifyHwnd%
	WinActivate, ahk_id %spotifyHwnd%
}
Return

; Send keypress to spotify
spotifyKey(key) {
	;spotifyHwnd := getSpotifyHwnd()
	WinGet, spotifyHwnd, ID, ahk_exe spotify.exe
	ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%	; Focus the document window without bringing the app to the foreground.
	ControlSend, , %key%, ahk_id %spotifyHwnd%
	If WinActive("ahk_class Chrome_WidgetWin_0 ahk_exe Spotify.exe")
		Send, %key%
	Return
}
; Keybinds
#F10::	spotifyKey("{Space}")	; Pause/Play
#Space::spotifyKey("{Space}")	; Pause/Play
#F11::	spotifyKey("^{Right}")	; Next
#F9::	spotifyKey("^{Left}")	; Prev
#+F10::	spotifyKey("+{Right}")	; Forward
#+F9::	spotifyKey("+{Left}")	; Backward
#F8::	spotifyKey("^{Up}")		; Volume Up
#F7::	spotifyKey("^{Down}")	; Volume Down

