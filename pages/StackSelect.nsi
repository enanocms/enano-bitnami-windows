Page custom StackSelectCreate StackSelectLeave " - Select stack"

Function StackSelectCreate
  ; Only show this page if both WAMPStack and WAPPStack are installed.
  StrCmp $wampstack_installed 0 "" +3
    Call StackSelectLeave
    Return
  StrCmp $wappstack_installed 0 "" +3
    Call StackSelectLeave
    Return
  StrCmp $XPUI_ABORTED 1 "" +2
    Abort
    
  !insertmacro XPUI_INSTALLOPTIONS_EXTRACT_AS "pages\StackSelect.ini" "StackSelect.ini"
  !insertmacro XPUI_HEADER_TEXT "Select server stack" "Choose which BitNami stack installation you want to use to run $(^Name)."
  !insertmacro XPUI_INSTALLOPTIONS_DISPLAY "StackSelect.ini"
FunctionEnd

Function StackSelectLeave
  ; Here is where we make the final decision on which stack will be used.
  IfFileExists "$PLUGINSDIR\StackSelect.ini" "" OnlyOneStackInstalled
  
    !macro ConfigCheck
      IfFileExists "$stack_instdir\apps\${PRODUCT_SHORTNAME}\htdocs\config.php" 0 +3
        MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "Setup has found that $(^Name) is already installed on this stack. If you continue and you do not want to delete your existing site, you must provide the database information of the current installation on the next page. Otherwise, the existing installation's configuration file will be deleted and your existing website will be replaced with a fresh one.$\n$\nIf you are upgrading $(^Name), you can safely click Yes below, and enter the database information found in $stack_instdir\apps\${PRODUCT_SHORTNAME}\config.php on the next page.$\n$\nDo you want to continue?" IDYES +2
          Abort
    !macroend
  
    ; Both stacks are installed; decide based on user selection
    ReadINIStr $0 "$PLUGINSDIR\StackSelect.ini" "Field 1" "State"
    StrCmp $0 1 "" UserSelectedWAPP
      ; User selected WAMP
      Call BNSetVarsForWAMP
      !insertmacro ConfigCheck
      LockWindow on
      Return
      
    UserSelectedWAPP:
      ; User selected WAPP
      Call BNSetVarsForWAPP
      !insertmacro ConfigCheck
      LockWindow on
      Return
  
  OnlyOneStackInstalled:
  StrCmp $wampstack_installed 0 +3
    ; MySQL
    Call BNSetVarsForWAMP
    !insertmacro ConfigCheck
    LockWindow on
    Return
    
    ; PostgreSQL
    Call BNSetVarsForWAPP
    !insertmacro ConfigCheck
    LockWindow on
    Return
FunctionEnd

Function BNSetVarsForWAMP
  StrCpy $stack_type "WAMP"
  StrCpy $stack_instdir "$wampstack_installed"
  StrCpy $db_driver "mysql"
  StrCpy $db_dbmsname "MySQL"
  StrCpy $db_rootuser "root"
  ReadINIStr $db_port "$stack_instdir\properties.ini" "MySQL" "mysql_port"
  
  StrCpy $stack_portbit ""
  ReadINIStr $0 "$stack_instdir\properties.ini" "Apache" "apache_server_port"
  StrCmp $0 "80" +2
    StrCpy $stack_portbit ":$0"
FunctionEnd

Function BNSetVarsForWAPP
  StrCpy $stack_type "WAPP"
  StrCpy $stack_instdir "$wappstack_installed"
  StrCpy $db_driver "postgresql"
  StrCpy $db_dbmsname "PostgreSQL"
  StrCpy $db_rootuser "postgres"
  ; NOTE: WAPPStack doesn't record the port of PostgreSQL - we have to assume the default
  StrCpy $db_port 5432
  
  StrCpy $stack_portbit ""
  ReadINIStr $0 "$stack_instdir\properties.ini" "Apache" "apache_server_port"
  StrCmp $0 "80" +2
    StrCpy $stack_portbit ":$0"
FunctionEnd