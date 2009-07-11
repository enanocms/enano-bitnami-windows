; Now we're going to put the kickstart code into a separate file and try to keep it
; as clean and human-readable as possible.

!macro kickstart_var Var Value
  ${str_replace} $1 "$$" "\$$" "${Value}"
  FileWrite $0 "$$${Var} = <<<EOF$\r$\n$1$\r$\nEOF;$\r$\n$\r$\n"
!macroend
!macro kickstart_int Var Value
  FileWrite $0 "$$${Var} = ${Value};$\r$\n"
!macroend
!define "kickstart_var" "!insertmacro kickstart_var"
!define "kickstart_int" "!insertmacro kickstart_int"

Function enano_write_kickstart_script
  CreateDirectory "$INSTDIR\apps\enanocms\scripts"
  ClearErrors
  FileOpen $0 "$INSTDIR\apps\enanocms\scripts\kickstart.php" "w"
  IfErrors 0 +4
    Push "open the kickstart file"
    Call ks_error
    Return

  FileWrite $0 "<?php$\r$\n// Automatically generated kickstart script.$\r$\n$\r$\n"

  ${kickstart_int} "silent" "true"
  ${kickstart_var} "lang_id" "eng"
  ${kickstart_var} "scriptpath" "/${PRODUCT_SHORTNAME}"

  ${kickstart_var} "driver" "$db_driver"
  ${kickstart_var} "dbhost" "localhost"
  ${kickstart_int} "dbport" "$db_port"
  ${kickstart_var} "dbuser" "$db_user"
  ${kickstart_var} "dbpasswd" "$db_password"
  ${kickstart_var} "dbname" "$db_name"
  ${kickstart_var} "db_prefix" "enano_"
  ${kickstart_var} "user" "$enano_user"
  ${kickstart_var} "pass" "$enano_password"
  ${kickstart_var} "email" "$admin_email"
  ${kickstart_var} "sitename" "$site_name"
  ${kickstart_var} "sitedesc" "$site_desc"
  ${kickstart_var} "copyright" "$site_copyright"
  ${kickstart_var} "urlscheme" "$url_scheme"
  ${kickstart_var} "start_with" "$start_with"
  
  FileWrite $0 "$\r$\nrequire(dirname(__FILE__) . '/../htdocs/install/includes/cli-core.php');"
  FileClose $0

FunctionEnd

Function enano_run_kickstart_script
  ; Debug :)
  ; ExecWait '"$SYSDIR\notepad.exe" "$INSTDIR\apps\enanocms\scripts\kickstart.php"'
  DetailPrint "Installing $(^Name) database"
  nsExec::ExecToLog '"$INSTDIR\php\php.exe" "$INSTDIR\apps\enanocms\scripts\kickstart.php"'
FunctionEnd

Function ks_error
  Pop $0
  MessageBox MB_OK|MB_ICONEXCLAMATION "Setup failed to $0. You will need to install $(^Name) manually. To do this, navigate to:$\r$\n$\r$\n    http://localhost/apps/${PRODUCT_SHORTNAME}/$\r$\n$\r$\nYou will be presented with a screen that will allow you to continue the $(^Name) installation.$\r$\n$\r$\nYour database information is:$\r$\n$\r$\n  Server type: $db_dbmsname$\r$\n  Hostname: localhost$\r$\n  Port: $db_port$\r$\n  Database name: $db_name$\r$\n  Database user: $db_user$\r$\n  Database password: $db_password"
  Abort "Could not $0!"
FunctionEnd

