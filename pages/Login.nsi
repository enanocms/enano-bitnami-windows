Page custom CredentialsCreate CredentialsLeave " - Admin login"

Function CredentialsCreate
  !insertmacro XPUI_HEADER_TEXT "Create administrator" "Enter your desired username and password for administering your site."
  !insertmacro XPUI_INSTALLOPTIONS_EXTRACT_AS "pages\Login.ini" "Login.ini"
  !insertmacro XPUI_INSTALLOPTIONS_DISPLAY "Login.ini"
FunctionEnd

Function CredentialsLeave
  StrCmp $XPUI_ABORTED "1" 0 +2
    Return
  
  ReadIniStr $enano_user "$PLUGINSDIR\Login.ini" "Field 1" "State"
  StrCmp $enano_user "" 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "Please enter a username."
    Abort
  
  ReadIniStr $enano_password "$PLUGINSDIR\Login.ini" "Field 2" "State"
  Strlen $0 $enano_password
  IntCmp $0 6    +3  0  +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "Please enter a password that is at least six characters long."
    Abort
    
  ReadIniStr $0 "$PLUGINSDIR\Login.ini" "Field 3" "State"
  StrCmp $0 $enano_password +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "The passwords you entered do not match. Please enter them again."
    Abort
    
  ReadIniStr $admin_email "$PLUGINSDIR\Login.ini" "Field 4" "State"
  StrCmp $admin_email "" 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "Please enter your e-mail address."
    Abort
FunctionEnd

