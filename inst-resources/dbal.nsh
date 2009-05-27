!macro db_connect result user pass
  Push "${user}"
  Push "${pass}"
  ClearErrors
  StrCmp $db_driver "mysql" 0 +3
    Call mysql_connect
    Goto +2
    Call postgresql_connect
  Pop ${result}
!macroend

!define db_connect "!insertmacro db_connect"

!macro db_create result user pass dbname nuser npass
  Push "${user}"
  Push "${pass}"
  Push "${dbname}"
  Push "${nuser}"
  Push "${npass}"
  StrCmp $db_driver "mysql" 0 +3
    Call mysql_create_db
    Goto +2
    Call postgresql_create_db
  Pop ${result}
!macroend

!define db_create "!insertmacro db_create"