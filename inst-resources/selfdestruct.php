<?php

// basically: self-destruct the database side of Enano.

$mydir = dirname(__FILE__);
require($mydir . '/../htdocs/includes/common.php');
if ( !defined('ENANO_CLI') )
  die("Don't even try.");

require(ENANO_ROOT . '/config.php');

// one is mysql, one is postgresql
// too lazy to check right now
// FIXME this fails right now because we don't have root
$db->sql_query("DROP ROLE `$dbuser`;");
$db->sql_query("REVOKE ALL PRIVILEGES ON `$dbname`.* FROM `$dbuser`@localhost;");

$q = $db->sql_query("DROP DATABASE `$dbname`;");
if ( $q )
  exit(0);

exit(1);

