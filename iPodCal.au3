#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=..\Icons\free_icons\Calender.ico
#AutoIt3Wrapper_Compression=4
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Opt("TrayAutoPause",0)          ;0=no pause, 1=Pause
Opt("TrayMenuMode",1)           ;0=append, 1=no default menu, 2=no automatic check, 4=menuitemID  not return
#cs ----------------------------------------------------------------------------

	iPodCal - Synchronise iPod Calendar with Google Calendar
	
    Compile this script, put it in the root dir of your iPod and run it.
    Enter your private Google Calendar address (iCal format, .ics) and it will
    download it for you, synchronising your iPod calendar with your Google
    Calendar. It saves data in an INI, protected with RC4. The key is the drive
    serial no., meaning it should only be able to be run from the same drive it
    is used on. If somebody doesn't manage to work out the key. It is a bit
    more secure than plaintext but still use at your own risk.

    Also includes a handy RFC date function.

#ce ----------------------------------------------------------------------------

#include "RC4.au3"
#include <Date.au3>

$s_GetPriv = 'private\-([^/]*)\/basic.ics'
$s_GetURL = '(.*)/private-'
$s_VerifyURL = '(http\:\/\/www\.google\.com\/calendar\/ical\/.*)'
$s_VerifyPriv = '([A-Fa-f0-9]+)'

;MsgBox(0,"", DriveGetSerial(StringLeft(@ScriptDir, 3)))

; Read the encrypted data
$s_URL = IniRead("iPodCal.ini", "Calendar", "URL", "F")
$s_Priv = IniRead("iPodCal.ini", "Calendar", "Priv", "F")

; If the data could not be read
If $s_URL = "F" Or $s_Priv = "F" Then
	;Start a new config
	FileDelete("iPodCal.ini")
	$s_TempURL = InputBox("Google Calendar iCal Private URL", "Please enter the private address of your Google Calendar (iCal ICS)."  & @CRLF & _
	"This information is stored in encrypted form.", "http://www.google.com/calendar/ical/example%40gmail.com/private-7728121a781271d3c/basic.ics")
	$as_Priv = StringRegExp($s_TempURL, $s_GetPriv, 3)
	$as_URL = StringRegExp($s_TempURL, $s_GetURL, 3)
	;Extract Private Key and URL, then write encrypted form to INI
	If IsArray($as_Priv) And IsArray($as_URL) Then
		IniWrite("iPodCal.ini", "Calendar", "URL", RC4($as_URL[0], DriveGetSerial(StringLeft(@ScriptDir, 3)), 0))
		IniWrite("iPodCal.ini", "Calendar", "Priv", RC4($as_Priv[0], DriveGetSerial(StringLeft(@ScriptDir, 3)), 0))
	EndIf
	; New values stored
	$s_URL = $as_URL[0]
	$s_Priv = $as_Priv[0]
Else
	; Data has been read, decrypt it
	$s_URL = RC4($s_URL, DriveGetSerial(StringLeft(@ScriptDir, 3)), 1)
	$s_Priv = RC4($s_Priv, DriveGetSerial(StringLeft(@ScriptDir, 3)), 1)
EndIf

;Verify Strings
$as_URL_Verify = StringRegExp($s_URL, $s_VerifyURL, 3)
$as_Priv_Verify = StringRegExp($s_Priv, $s_VerifyPriv, 3)

If IsArray($as_Priv_Verify) And IsArray($as_URL_Verify) Then
	$s_FullURL = $s_URL & '/private-' & $s_Priv & '/basic.ics'
	If FileExists(@ScriptDir & "\Calendars\basic.ics") Then FileDelete(@ScriptDir & "\Calendars\basic.ics")
	If InetGet($s_FullURL, @ScriptDir & "\Calendars\basic.ics", 1) Then
		MsgBox(64, "Calendar Sync Complete", "iPod Calendar successfully synchronised with Google Calendar." & @CRLF & _ 
		"Synchronised on: " & RFCDate())
	Else
		MsgBox(64, "Calendar Sync Error", "iPod Calendar not successfully synchronised with Google Calendar.")
	EndIf
Else
	MsgBox(64, "Calendar Sync Error", "iPod Calendar not successfully synchronised with Google Calendar.")
EndIf


Func RFCDate()
	Return _DateDayOfWeek( @WDAY, 1 ) & ", " & @MDAY & " " & _DateToMonth(@MON, 1) & " " & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & " GMT"
EndFunc