#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include <Array.au3>

$s_Input = InputBox("Enter a number in scientific notation", "Please enter a number in scientific notation:","1.79E12")

$s_Input = StringLower($s_Input)

Do
	If StringLeft($s_Input,2) = "00" Then
		$s_Input = StringTrimLeft($s_Input,1)
	Else
		ExitLoop
	EndIf
Until @error

$as_Parts = StringSplit($s_Input, "e")

;If $as_Parts[1] >= 10 Then Exit

;_ArrayDisplay($as_Parts)

$as_Dec = StringSplit($as_Parts[1], ".")

$i_DecOff = StringInStr($s_Input, ".") - 2

ConsoleWrite($i_DecOff & @CRLF)

$s_BigNum2 = $as_Dec[1]

; This basically moves the decimal point a number of places
For $a = 1 to $as_Parts[2]
	$s_Temp = StringMid($as_Dec[2], $a, 1)
	If $s_Temp <> "" Then
		$s_BigNum2 &= $s_Temp
	Else
		$s_BigNum2 &= "0"
	EndIf
Next

$s_BigNum2 &= ".0"

MsgBox(0,$s_Input, $as_Parts[1] & " x 10^" & ($i_DecOff+$as_Parts[2]) & @CRLF & $s_BigNum2)

ClipPut($s_BigNum2)