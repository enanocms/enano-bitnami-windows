Page custom SiteConfigCreate SiteConfigLeave " - Configure site information"

Function SiteConfigCreate
  !insertmacro XPUI_INSTALLOPTIONS_EXTRACT_AS "pages\SiteConfig.ini" "SiteConfig.ini"
  !insertmacro XPUI_HEADER_TEXT "Configure website" "Enter basic information about your website."
  !insertmacro XPUI_INSTALLOPTIONS_DISPLAY "SiteConfig.ini"
FunctionEnd

Function SiteConfigLeave
  StrCmp $XPUI_ABORTED 1 0 +2
    Return
    
  ReadINIStr $site_name "$PLUGINSDIR\SiteConfig.ini" "Field 1" "State"
  StrCmp $site_name "" 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "Please enter a name for your site."
    Abort
    
  ReadINIStr $site_desc "$PLUGINSDIR\SiteConfig.ini" "Field 2" "State"
  StrCmp $site_desc "" 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "Please enter a description for your site."
    Abort
    
  ReadINIStr $site_copyright "$PLUGINSDIR\SiteConfig.ini" "Field 3" "State"
  StrCmp $site_copyright "" 0 +2
    StrCpy $site_copyright "No copyright assigned."
    
  Push $site_copyright
  Call CleanCopyright
  Pop $site_copyright
  
  StrCpy $url_scheme "standard"
  ReadINIStr $0 "$PLUGINSDIR\SiteConfig.ini" "Field 4" "State"
  IntCmp $0 1 0 +2 +2
    StrCpy $url_scheme "short"
    
  StrCpy $start_with "blank"
  ReadINIStr $0 "$PLUGINSDIR\SiteConfig.ini" "Field 6" "State"
  IntCmp $0 1 0 +2 +2
    StrCpy $start_with "tutorial"
    
  LockWindow on
FunctionEnd

Function CleanCopyright
  Pop $0
  ${str_replace} $0 "©" "&copy;" "$0"
  Push $0
FunctionEnd
