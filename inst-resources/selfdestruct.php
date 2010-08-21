<?php

// basically: self-destruct the database side of Enano.

$mydir = dirname(__FILE__);
require($mydir . '/../htdocs/includes/common.php');
if ( !defined('ENANO_CLI') )
	die("Don't even try.");

require(ENANO_ROOT . '/config.php');

if ( !in_array('--skip-revoke', $argv) )
{
	$db->sql_query("DROP DATABASE `$dbname`;");
	// one is mysql, one is postgresql
	// too lazy to check right now
	// FIXME this fails right now because we don't have root
	$db->sql_query("DROP ROLE `$dbuser`;");
	$db->sql_query("REVOKE ALL PRIVILEGES ON `$dbname`.* FROM `$dbuser`@localhost;");
}
else
{
	foreach ( $system_table_list as $table )
	{
		$q = "DROP TABLE `" . table_prefix . "$table`;";
		echo "$q\n";
		$db->sql_query($q);
	}
}

exit(0);

