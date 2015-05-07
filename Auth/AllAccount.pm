
use strict;
package Mebius::Auth::AllAccount;

#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
"account";
}

#-----------------------------------------------------------
# DBIテーブルを作成
#-----------------------------------------------------------
sub create_main_table{

my($dbh) = Mebius::DBI->connect();
my($main_table_name) = main_table_name();

$dbh->do("
	CREATE TABLE IF NOT EXISTS `$main_table_name` (
	`account` char(100) NOT NULL PRIMARY KEY,
	`email` char(255) default NULL,
	`handle` char(100) default NULL,
	`entry_time` char(100) default NULL,
	`char` char(100) default NULL,
	`last_update_time` int default NULL
)
;
");

}

1;
