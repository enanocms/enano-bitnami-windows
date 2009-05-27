/**
 * Inserts an HTML file at the necessary point in applications.html.
 * @param string HTML file
 */

Function BNRegisterApplicationToList
  ClearErrors

  ; Make sure it's not already in there
  FileOpen $0 "$stack_instdir\apache2\htdocs\applications.html" "r"
  IfErrors 0 +3
    SetErrors
    Return
    
  loop:
    FileRead $0 $1
    IfErrors EOF
    Push $1
    Push "Module ${PRODUCT_SHORTNAME}"
    Call StrStr
    Pop $1
    StrCmp $1 "" +3
      ; found it, skip write
      FileClose $0
      Return
    Goto loop
  EOF:
  FileClose $0
  
  Pop $0
  Push "$stack_instdir\apache2\htdocs\applications.html"
  Push $0
  Push "<!-- @@BITNAMI_MODULE_PLACEHOLDER@@ -->"
  Call AppendBeforeSubstring
FunctionEnd

Function AppendBeforeSubstring
  Pop $R2 ; marker
  Pop $R1 ; file to insert
  Pop $R0 ; file to modify
  
  StrCpy $R7 0 ; $R7 = current offset
  
  ClearErrors
  FileOpen $R3 $R0 "a" ; $R3 = handle
  FileSeek $R3 0
  IfErrors 0 +3
    SetErrors
    Return
    
  loop:
    FileRead $R3 $R4 ${NSIS_MAX_STRLEN} ; $R4 = line
    IfErrors 0 +3
      DetailPrint "EOF"
      Goto EOF
    StrLen $R8 $R4 ; $R8 = length of line
    IntOp $R7 $R7 + $R8
    
    Push $R4
    Push $R2
    Call StrStr
    Pop $R5 ; $R5 = substring test
    StrCmp $R5 "" /* no match */ loop
    
    ; got a match!
    StrLen $R6 $R5 ; Length of found substring
    ; rewind a little bit, to right before the substring
    IntOp $R8 $R7 - $R6
    FileSeek $R3 -$R6 CUR $R5
    
    ; store the rest of the file
    StrCpy $R9 ""
    remainderloop:
      ClearErrors
      FileRead $R3 $R7
      StrCpy $R9 "$R9$R7"
      IfErrors 0 remainderloop
    ; now jump back to our point
    FileSeek $R3 $R5
    
    ; Now, write it all in
    FileOpen $R4 $R1 "r"
    IfErrors 0 +3
      SetErrors
      Return
    loop2:
      FileRead $R4 $R5 ${NSIS_MAX_STRLEN}
      IfErrors EOF2
      FileWrite $R3 $R5
      Goto loop2
      EOF2:
        FileClose $R5
      
    FileWrite $R3 $R9
  EOF:
  FileClose $R3
FunctionEnd

Function enano_add_to_applist
  StrCmp $PLUGINSDIR "" 0 +2
    InitPluginsDir
    
  SetOutPath "$stack_instdir\apache2\htdocs\img"
  File "gfx\enanocms-module.png"
  SetOutPath "$PLUGINSDIR"
  File "gfx\application.html"
  Push "$PLUGINSDIR\application.html"
  Call BNRegisterApplicationToList
  IfErrors 0 +2
    MessageBox MB_OK|MB_ICONEXCLAMATION "There was an error adding the application to the list."
FunctionEnd

