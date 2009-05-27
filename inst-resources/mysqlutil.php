<?php

// MySQL utility script.

if ( $argc < 2 )
  die("Usage: {$argv[0]} port username password");

$user = $argv[2];
$pass = $argv[3];
$handle = mysql_connect("localhost:{$argv[1]}", $user, $pass);
if ( !$handle )
{
  echo "MySQL authentication failed.";
  exit(1);
}

if ( !empty($argv[4]) )
{
  $queries = explode(';', $argv[4]);
  foreach ( $queries as $query )
  {
    $query = trim($query);
    if ( empty($query) )
      continue;
    echo "$query;\n";
    if ( !mysql_query("$query;") )
      exit(1);
  }
}

exit(0);
