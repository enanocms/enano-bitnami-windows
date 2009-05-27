<?php

// PostgreSQL utility script.

if ( $argc < 2 )
  die("Usage: {$argv[0]} username password");

$user = addslashes($argv[1]);
$pass = addslashes($argv[2]);
$handle = pg_connect("host=localhost port=5432 user='$user' password='$pass'");
if ( !$handle )
{
  echo "PostgreSQL authentication failed.";
  exit(1);
}

if ( !empty($argv[3]) )
{
  $queries = explode(';', $argv[3]);
  foreach ( $queries as $query )
  {
    $query = trim($query);
    if ( empty($query) )
      continue;
    echo "$query;\n";
    if ( !pg_query("$query;") )
      exit(1);
  }
}

exit(0);
