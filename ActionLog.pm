
use strict;
package Mebius::ActionLog;

#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
"action_log";
}


#-----------------------------------------------------------
# カラムの設定
#-----------------------------------------------------------
sub main_table_column{

# データ定義
my $column = {
unique_target => { PRIMARY => 1 } , 
action_time => { int => 1 } , 
last_update_time => { int => 1 } ,
cnumber => {} ,
host => {} ,
addr => {} ,
account => {} ,
user_agent => { } ,
mobile_uid => { } ,
};

$column;

}

#-----------------------------------------------------------
# テーブルを作成
#-----------------------------------------------------------
sub create_main_table{

my($main_table_name) = main_table_name() || die;

my($set) = main_table_column();

Mebius::DBI->create_memory_table(undef,$main_table_name,$set);

}


1;
