/**
 * Search the Apache configuration for the Include line for Apache settings.
 * @return int 0 if successful (found line); 1 if not found
 */

Function search_apache_config
  FileOpen $0 "$INSTDIR\apache2\conf\httpd.conf" "r"
  loop:
    ClearErrors
    FileRead $0 $1 1024
    IfErrors done
    Push $1
    Push "Include "
    Call StrStr
    Pop $2
    StrCmp $2 "" loop
      ; This is an include line
      Push $1
      Push "/apps/${PRODUCT_SHORTNAME}/"
      Call StrStr
      Pop $2
      StrCmp $2 "" loop
        ; We found it
        Push 0
        FileClose $0
        Return
  done:
  FileClose $0
  Push 1
FunctionEnd

Function write_apache_config
  Call search_apache_config
  Pop $0
  IntCmp $0 1 +2 0 0
    Goto WriteLocalConfig
    
  ClearErrors
  FileOpen $0 "$INSTDIR\apache2\conf\httpd.conf" "a"
  IfErrors 0 +4
    Push "write to the Apache configuration file"
    Call ks_error
    Return
    
  FileSeek $0 0 END
  FileWrite $0 "$\r$\nInclude $\"../apps/${PRODUCT_SHORTNAME}/conf/httpd.conf$\"$\r$\n"
FileClose $0
  
  WriteLocalConfig:
  
  ClearErrors
  CreateDirectory "$INSTDIR\apps\${PRODUCT_SHORTNAME}\conf"
  IfErrors 0 +4
    Push "create the configuration directory"
    Call ks_error
    Return
    
  ClearErrors
  FileOpen $0 "$INSTDIR\apps\${PRODUCT_SHORTNAME}\conf\httpd.conf" "w"
  IfErrors 0 +4
    Push "write to the local configuration file"
    Call ks_error
    Return

  FileWrite $0 "Alias /${PRODUCT_SHORTNAME} $\"../apps/${PRODUCT_SHORTNAME}/htdocs$\"$\r$\n$\r$\n"
  FileWrite $0 "<Directory $\"../apps/${PRODUCT_SHORTNAME}/htdocs$\">$\r$\n"
  FileWrite $0 "  Options -Indexes MultiViews FollowSymLinks$\r$\n"
  FileWrite $0 "  AllowOverride All$\r$\n"
  FileWrite $0 "  Order allow,deny$\r$\n"
  FileWrite $0 "  Allow from all$\r$\n"
  FileWrite $0 "</Directory>$\r$\n"
  FileClose $0

FunctionEnd

; Remove from Apache config upon uninstall
Function un.disable_in_apache_config
  StrCpy $0 "$stack_instdir\apache2\conf\httpd.conf"
  ClearErrors
  FileOpen $1 $0 "r"
  
  ; input file
  IfErrors 0 +3
    Push 1
    Return
  
  ; output file
  FileOpen $2 $0.tmp "w"
  IfErrors 0 +3
    Push 1
    Return
  
  ; read each line, if nothing to do with enano, pass through
  loop:
    ClearErrors
    FileRead $1 $3 1024
    IfErrors done
    Push $3
    Push "/apps/${PRODUCT_SHORTNAME}/"
    Call un.StrStr
    Pop $4
    StrCmp $4 "" 0 loop
      ; no mention of Enano, ok to write it
      FileWrite $2 $3
      Goto loop
    
  done:
    
  FileClose $1
  FileClose $2
  Delete "$0"
  Rename "$0.tmp" "$0"
  
  Push 0
FunctionEnd

; Remove from applications.html upon uninstall
Function un.disable_in_applications_html
  StrCpy $0 "$stack_instdir\apache2\htdocs\applications.html"
  ClearErrors
  FileOpen $1 $0 "r"
  
  ; State variable: are we in the Enano section or not?
  StrCpy $5 0
  
  ; input file
  IfErrors 0 +3
    Push 1
    Return
  
  ; output file
  FileOpen $2 $0.tmp "w"
  IfErrors 0 +3
    Push 1
    Return
  
  ; read each line, if nothing to do with enano, pass through
  loop:
    ClearErrors
    FileRead $1 $3 1024
    IfErrors done
    Push $3
    StrCmp $5 1 0 outsideblock
      ; inside of the block - don't write
      StrCpy $6 0
      Push "END BitNami ${PRODUCT_NAME} Module ${PRODUCT_SHORTNAME}"
      Call un.StrStr
      Pop $4
      StrCmp $4 "" +2
        ; found it - don't write this line, but set $5 to 0 so we write the next one
        StrCpy $5 0
      Goto loop
      outsideblock:
      Push "START BitNami ${PRODUCT_NAME} Module ${PRODUCT_SHORTNAME}"
      Call un.StrStr
      Pop $4
      StrCmp $4 "" +3
        ; found the start of the block - disable writes
        StrCpy $5 1
        Goto loop
        
      FileWrite $2 $3
      Goto loop
      
  done:
    
  FileClose $1
  FileClose $2
  Delete "$0"
  Rename "$0.tmp" "$0"
  
  Delete "$stack_instdir\apache2\htdocs\img\${PRODUCT_SHORTNAME}-module.png"
  
  Push 0
FunctionEnd