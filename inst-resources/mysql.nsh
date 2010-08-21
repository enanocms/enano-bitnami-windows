/**
 * Verify credentials for a MySQL database. Assumes we are connecting to BitNami's DB.
 * @param string Username
 * @param string Password
 * @return int 0 if successful, >0 on error. Will push an error string to the stack if >0.
 */

Function mysql_connect
  Pop $R1 ; Password
  Pop $R0 ; Username

  SetOutPath $PLUGINSDIR
  File "inst-resources\mysqlutil.php"

  nsExec::ExecToLog '"$stack_instdir\php\php.exe" "$PLUGINSDIR\mysqlutil.php" $db_port "$R0" "$R1"'
  Delete "$PLUGINSDIR\mysqlutil.php"
  ; just be done; nsExec's result is on the top of the stack.
FunctionEnd

/**
 * Create a MySQL database and grant privileges on it to the given user.
 * @param string User to connect with
 * @param string Password to connect with
 * @param string Database name
 * @param string New user
 * @param string New user's password
 */

Function mysql_create_db
  Pop $R5 ; Password
  Pop $R4 ; User
  Pop $R3 ; Database
  Pop $R1 ; Password
  Pop $R0 ; Username
  
  ReadINIStr $R2 "$stack_instdir\properties.ini" "MySQL" "mysql_root_directory"
  ; IfFileExists "$R2\data\$R3" 0 DatabaseDoesNotExist
  ;   MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "The database $\"$R3$\" already exists. Do you want to delete and recreate it?$\n$\nIf you choose No, Setup will not alter MySQL's permissions, and you may need to set up permissions manually." IDYES +2
  ;     Return                                
    
  ; DatabaseDoesNotExist:
  
  SetOutPath $PLUGINSDIR
  File "inst-resources\mysqlutil.php"
  
  nsExec::ExecToLog '"$stack_instdir\php\php.exe" "$PLUGINSDIR\mysqlutil.php" $db_port "$R0" "$R1" \
                     "DROP DATABASE IF EXISTS `$R3`; \
                      CREATE DATABASE `$R3`; \
                      GRANT ALL PRIVILEGES ON `$R3`.* TO `$R4`@localhost \
                        IDENTIFIED BY $\'$R5$\' WITH GRANT OPTION;"'
  Delete "$PLUGINSDIR\mysqlutil.php"
FunctionEnd

