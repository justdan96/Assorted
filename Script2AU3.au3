#cs ----------------------------------------------------------------------------

 Version: 		 1.0.0.1
 Author:         Dan Bryant

 Script Function:
	Convert a VBscript or Javascript file into an AU3 COM function.
	Useful for UDFs.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

Global $AU3 = 'Func @@AFUNCTION@@($string)' & @CRLF
$AU3 &= '#region configure code' & @CRLF
$AU3 &= '@@CODE@@' & @CRLF
$AU3 &= '#endregion' & @CRLF
$AU3 &= "Local $script = ObjCreate('ScriptControl')" & @CRLF
$AU3 &= "$script.language='@@LANGUAGE@@'" & @CRLF
$AU3 &= '$script.addcode($Code)' & @CRLF
$AU3 &= "Return $script.run('@@FUNCTION@@', $string)" & @CRLF
$AU3 &= 'EndFunc' & @CRLF

$File = FileOpenDialog("Please select script", @ScriptDir, "VBScript (*.vbs)|Javascript (*.js)", 1)
$Code = FileRead($File)

If StringRight($File,3) = ".js" OR StringRight($File,3) = ".JS" OR StringRight($File,3) = ".Js" OR StringRight($File,3) = ".jS" Then
	$AU3 = StringReplace($AU3,"@@LANGUAGE@@", "javascript")
Else
	$AU3 = StringReplace($AU3,"@@LANGUAGE@@", "vbscript")
EndIf

$CodeA = StringSplit($Code,@CRLF)
$Function = InputBox("Function", "Enter the name of the function in the JS/VBS script you wish to use")
$AU3 = StringReplace($AU3,"@@FUNCTION@@", $Function)

$AFunction = InputBox("AU3 Function", "Enter the name you wish to give to this function in the AU3")
$AU3 = StringReplace($AU3,"@@AFUNCTION@@", $AFunction)

$SCode = "$Code = ''; Start Code" & @CRLF

For $i = 1 to UBound($CodeA) - 1
	If $CodeA[$i] <> "" And StringLen($CodeA[$i]) < 140 Then
		$SCode &= "$Code &= '" & StringReplace($CodeA[$i],"'", "''") & "' & @CRLF" & @CRLF
	ElseIf $CodeA[$i] <> "" And StringLen($CodeA[$i]) >= 140 Then
		$i_StringPoint = 0
		Do
			If $i_StringPoint = 0 Then
				$SCode &= "$Code &= '" & StringLeft($CodeA[$i], 140) & "' & _ " & @CRLF
			Else
				If StringMid($CodeA[$i], $i_StringPoint, 140) <> "" Then $SCode &= "'" & StringMid(StringReplace($CodeA[$i],"'", "''"), $i_StringPoint, 140) & "' & _ " & @CRLF
			EndIf
			$i_StringPoint += 140
		Until $i_StringPoint-140 >= StringLen($CodeA[$i])
		$SCode &= "'' & @CRLF ; Long Line End" & @CRLF
	EndIf
Next

$SCode = StringStripWS($SCode,2)

$AU3 = StringReplace($AU3,"@@CODE@@", $SCode)

$Save = FileSaveDialog("Save File" , @ScriptDir, "AU3 (*.au3)", 16)
FileWrite($Save, $AU3)