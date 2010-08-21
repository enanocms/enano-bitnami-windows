!macro ShowRange hwnd low high value
  !define tmp_id ${__LINE__}
  StrCpy $R0 ${low}
  loop.${tmp_id}:
    GetDlgItem $R1 ${hwnd} $R0
    ShowWindow $R1 ${value}
    IntOp $R0 $R0 + 1
    IntCmp $R0 ${high} loop.${tmp_id} loop.${tmp_id}
    
  !undef tmp_id
!macroend
!define ShowRange "!insertmacro ShowRange"

Page custom DatabaseConfigCreate DatabaseConfigLeave " - Database configuration"

Function DatabaseConfigCreate
  StrCmp $XPUI_ABORTED 1 0 +2
    Return
  !insertmacro XPUI_INSTALLOPTIONS_EXTRACT_AS "pages\DatabaseConfig.ini" "DatabaseConfig.ini"
  !insertmacro XPUI_HEADER_TEXT "Database configuration" "Configure how $(^Name) will access your database."
  WriteINIStr "$PLUGINSDIR\DatabaseConfig.ini" "Field 9" "Text" \
    "$(^Name) needs database access to work properly. Setup can create a database for you if you provide \
     $db_dbmsname's administration password, or you can choose to enter credentials for a database that already exists."
     
  StrCpy $R2 0 ; Hide manual credential items
  StrCpy $R3 0 ; Hide root password/set manual to disabled
     
  ; if the back button was clicked we might have use manual checked
  ReadINIStr $0 "$PLUGINSDIR\DatabaseConfig.ini" "Field 3" "State"
  IntCmp $0 1 UseManualIsOn
  
    StrCpy $R2 1
    
  UseManualIsOn:
    
    ; do we need to disable the checkbox?
    ReadINIStr $0 "$PLUGINSDIR\DatabaseConfig.ini" "Field 2" "State"
    IntCmp $0 1   0 ShowDialog ShowDialog
    
      StrCpy $R3 1
      
  ShowDialog:
    
  !insertmacro XPUI_INSTALLOPTIONS_INITDIALOG "DatabaseConfig.ini"
  Pop $XPUI_HWND
  
  ; Our bold font
  CreateFont $2 "$(^Font)" "$(^FontSize)" 700
  ; Paint controls
  GetDlgItem $1 $XPUI_HWND 1200
  SendMessage $1 ${WM_SETFONT} $2 0
  GetDlgItem $1 $XPUI_HWND 1201
  SendMessage $1 ${WM_SETFONT} $2 0
  GetDlgItem $1 $XPUI_HWND 1214
  SendMessage $1 ${WM_SETFONT} $2 0
  
  IntCmp $R2 1 "" SkipHideManual
  
    ${ShowRange} $XPUI_HWND 1204 1207 ${SW_HIDE}
    ${ShowRange} $XPUI_HWND 1210 1213 ${SW_HIDE}
    
  SkipHideManual:
    
  IntCmp $R3 1 "" SkipForceManual

    ; check the box and disable
    GetDlgItem $0 $XPUI_HWND 1202
    SendMessage $0 ${BM_SETCHECK} ${BST_CHECKED} 0
    EnableWindow $0 0
    
    ; hide the root password, enter manually is selected
    GetDlgItem $0 $XPUI_HWND 1203
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $XPUI_HWND 1209
    ShowWindow $0 ${SW_HIDE}

  SkipForceManual:
    
  !insertmacro XPUI_INSTALLOPTIONS_SHOW
FunctionEnd

Function DatabaseConfigLeave
  StrCmp $XPUI_ABORTED 1 0 +2
    Return
    
  ReadINIStr $0 "$PLUGINSDIR\DatabaseConfig.ini" "Settings" "State"
  StrCmp $0 1 RadioButtonClicked
  StrCmp $0 2 RadioButtonClicked
  StrCmp $0 15 RadioButtonClicked
  StrCmp $0 3 UseManualClicked
  Goto NextClicked
  
  RadioButtonClicked:
    LockWindow on
	ReadINIStr $0 "$PLUGINSDIR\DatabaseConfig.ini" "Field 15" "State"
	IntCmp $0 1 SetBypass
    ReadINIStr $0 "$PLUGINSDIR\DatabaseConfig.ini" "Field 1" "State"
    IntCmp $0 0 SetUseExisting
    
      ; Show root password
      GetDlgItem $0 $XPUI_HWND 1203
      ShowWindow $0 ${SW_SHOW}
      GetDlgItem $0 $XPUI_HWND 1209
      ShowWindow $0 ${SW_SHOW}
    
      GetDlgItem $0 $XPUI_HWND 1202 ; Checkbox
      SendMessage $0 ${BM_SETCHECK} ${BST_UNCHECKED} 0
      EnableWindow $0 1
      ${ShowRange} $XPUI_HWND 1204 1207 ${SW_HIDE}
      ${ShowRange} $XPUI_HWND 1210 1213 ${SW_HIDE}
      LockWindow off
      Abort
    
    SetUseExisting:
    
      ; Hide root password
      GetDlgItem $0 $XPUI_HWND 1203
      ShowWindow $0 ${SW_HIDE}
      GetDlgItem $0 $XPUI_HWND 1209
      ShowWindow $0 ${SW_HIDE}
      
      GetDlgItem $0 $XPUI_HWND 1202 ; Checkbox
      SendMessage $0 ${BM_SETCHECK} ${BST_CHECKED} 0
      EnableWindow $0 0
      ${ShowRange} $XPUI_HWND 1204 1207 ${SW_SHOW}
      ${ShowRange} $XPUI_HWND 1210 1213 ${SW_SHOW}
      LockWindow off
      Abort
      
    SetBypass:
    	
      ; Hide root password
      GetDlgItem $0 $XPUI_HWND 1203
      ShowWindow $0 ${SW_HIDE}
      GetDlgItem $0 $XPUI_HWND 1209
      ShowWindow $0 ${SW_HIDE}
      
      GetDlgItem $0 $XPUI_HWND 1202 ; Checkbox
      SendMessage $0 ${BM_SETCHECK} ${BST_UNCHECKED} 0
      EnableWindow $0 0
      ${ShowRange} $XPUI_HWND 1204 1207 ${SW_HIDE}
      ${ShowRange} $XPUI_HWND 1210 1213 ${SW_HIDE}
      LockWindow off
      Abort
    
  UseManualClicked:
    ReadINIStr $0 "$PLUGINSDIR\DatabaseConfig.ini" "Field 3" "State"
    IntOp $0 $0 * ${SW_SHOW}
    ${ShowRange} $XPUI_HWND 1204 1207 $0
    ${ShowRange} $XPUI_HWND 1210 1213 $0
    Abort
  
  NextClicked:

    ; Figure out how we want to go about this.
    StrCpy $db_needroot 0
    StrCpy $skip_install 0
    ReadINIStr $0 "$PLUGINSDIR\DatabaseConfig.ini" "Field 15" "State"
    IntCmp $0 1 BypassInstaller
    ReadINIStr $0 "$PLUGINSDIR\DatabaseConfig.ini" "Field 1" "State"
    IntCmp $0 0 UseCustomLogin
    
      ; Validate based on root password.
      StrCpy $db_needroot 1
      ReadINIStr $db_rootpass "$PLUGINSDIR\DatabaseConfig.ini" "Field 4" "State"
      ${db_connect} $1 "$db_rootuser" "$db_rootpass"
      IntCmp $1 0 +3
        MessageBox MB_OK|MB_ICONEXCLAMATION "The $db_dbmsname root password you entered is incorrect. Please re-enter it."
        Abort
        
      ; Does the user have their own credentials?
      ReadINIStr $0 "$PLUGINSDIR\DatabaseConfig.ini" "Field 3" "State"
      IntCmp $0 0 GenerateRandomLogin
    
    UseCustomLogin:
    
      ; Pull database settings from dialog
      ReadINIStr $db_name "$PLUGINSDIR\DatabaseConfig.ini" "Field 5" "State"
      ReadINIStr $db_user "$PLUGINSDIR\DatabaseConfig.ini" "Field 6" "State"
      ReadINIStr $db_password "$PLUGINSDIR\DatabaseConfig.ini" "Field 7" "State"
      ReadINIStr $R0 "$PLUGINSDIR\DatabaseConfig.ini" "Field 8" "State"
      
      ; Check password length
      ; but don't if the user entered credentials that already exist
      IntCmp $db_needroot 0 SkipLengthCheck
        StrLen $R1 $R0
        IntCmp $R1 6 +3 0 +3
          MessageBox MB_OK|MB_ICONEXCLAMATION "Please choose a database password that is at least 6 characters in length."
          Abort
          
      SkipLengthCheck:
      ; Check password/confirm fields
      StrCmp $db_password $R0 +3
        MessageBox MB_OK|MB_ICONEXCLAMATION "The passwords you entered do not match. Please enter them again."
        Abort
        
      ; If we're root, we can assume the login doesn't exist yet, so skip the validation
      IntCmp $db_needroot 0 +3
        LockWindow on
        Return
        
      ${db_connect} $R0 $db_user $db_password
      IntCmp $R0 0 +3
        ; Database auth failed
        MessageBox MB_OK|MB_ICONEXCLAMATION "The username and password you entered are invalid. Please enter them again."
        Abort
        
      /*
      ; This can be an error-prone process because entering credentials manually will keep
      ; the installer from touching the database. If tables already exist, Enano's installer
      ; will throw an error. Confirm this with the user.
      MessageBox MB_YESNO|MB_ICONQUESTION "Are you sure you want to use manual database settings?$\r$\n\
                                           $\r$\n\
                                           Without your database root password, Setup cannot change your existing database. If there is an Enano installation \
                                           in this database already, the installer will fail with this option; you should go back and choose the $\"Upgrade or \
                                           configure database manually$\" option." IDYES +2
        Abort ; on No
      */
      
      LockWindow on
      Return
      
    BypassInstaller:
    	
      ; No validation - the user opted to configure everything manually.
      StrCpy $skip_install 1
      
    GenerateRandomLogin:
      StrCpy $db_name "bn_enanocms"
      StrCpy $db_user "bn_enanocms"
      Call GenerateRandomPassword
      Pop $db_password
      LockWindow on
      Return
  
FunctionEnd

Function GenerateRandomPassword
  SetOutPath $PLUGINSDIR
  File "inst-resources\randompass.php"
  nsExec::ExecToStack '"$stack_instdir\php\php.exe" "$PLUGINSDIR\randompass.php"'
  Pop $R0
FunctionEnd

