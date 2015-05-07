
use strict;
package Mebius::UserData;

#-----------------------------------------------------------
# メインテーブル名
#-----------------------------------------------------------
sub main_table_name{
"user_data";
}

#-----------------------------------------------------------
# テーブル作成
#-----------------------------------------------------------
sub create_main_table{

my($table_name) = main_table_name() || die("Can't decide main table name.");

my $set = {
unique => { PRIMARY => 1 } , 
data_kind => { } , 
data_target => { } , 
deleted_count => { int => 1 } , 
penalty_deleted_count => { int => 1 } , 
improper_report_count => { int => 1 } , 
make_bbs_thread_penalty_time => { int => 1 } 
 };

# メモリテーブルを作成
Mebius::DBI->create_memory_table_and_backup(undef,$table_name,$set);

}


1;

