/**
 * Search the Apache configuration for the Include line for this package's Apache settings.
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