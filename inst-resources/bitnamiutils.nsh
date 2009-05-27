Function BNSetWAMPInstalledFlag
  ClearErrors
  ReadRegStr $wampstack_installed HKLM "Software\BitNami\BitNami WAMPStack" "Location"
  IfErrors 0 +2
    StrCpy $wampstack_installed 0

  ClearErrors
FunctionEnd

Function BNSetWAPPInstalledFlag
  ClearErrors
  ReadRegStr $wappstack_installed HKLM "Software\BitNami\BitNami WAPPStack" "Location"
  IfErrors 0 +2
    StrCpy $wappstack_installed 0

  ClearErrors
FunctionEnd