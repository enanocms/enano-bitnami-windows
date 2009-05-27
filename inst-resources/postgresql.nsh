/**
 * Verify credentials for a PostgreSQL database. Assumes we are connecting to BitNami's DB.
 * @param string Username
 * @param string Password
 * @return int 0 if successful, >0 on error. Will push an error string to the stack if >0.
 */

!macro postgresql_get_bin_dir
  StrCpy $R2 "$stack_instdir\postgresql\bin"
!macroend

Function postgresql_connect
  Pop $R1 ; Password
  Pop $R0 ; Username

  SetOutPath $PLUGINSDIR
  File "inst-resources\postgresqlutil.php"
  
  nsExec::ExecToLog '"$stack_instdir\php\php.exe" "$PLUGINSDIR\postgresqlutil.php" "$R0" "$R1"'
  Delete "$PLUGINSDIR\postgresqlutil.php"
  ; just be done; nsExec's result is on the top of the stack.
FunctionEnd

/**
 * Create a postgresql database and grant privileges on it to the given user.
 * @param string User to connect with
 * @param string Password to connect with
 * @param string Database name
 * @param string New user
 * @param string New user's password
 */

Function postgresql_create_db
  Pop $R5 ; Password
  Pop $R4 ; User
  Pop $R3 ; Database
  Pop $R1 ; Password
  Pop $R0 ; Username

  /*
  ; This isn't a working feature in PostgreSQL.
  IfFileExists "$stack_instdir\postgresql\data\$R3" 0 DatabaseDoesNotExist
    MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "The database $\"$R3$\" already exists. Do you want to delete and recreate it?$\n$\nIf you choose No, Setup will not alter PostgreSQL's permissions, and you may need to set up permissions manually." IDYES +2
      Return

  DatabaseDoesNotExist:
  */

  SetOutPath $PLUGINSDIR
  File "inst-resources\postgresqlutil.php"

  nsExec::ExecToLog '"$stack_instdir\php\php.exe" "$PLUGINSDIR\postgresqlutil.php" "$R0" "$R1" \
                     "DROP DATABASE IF EXISTS $R3; \
                      DROP ROLE IF EXISTS $R4; \
                      CREATE ROLE $R4 WITH PASSWORD $\'$R5$\' LOGIN; \
                      CREATE DATABASE $R3 WITH OWNER $R4;"'
  Delete "$PLUGINSDIR\postgresqlutil.php"
FunctionEnd

