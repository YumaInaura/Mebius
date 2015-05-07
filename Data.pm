
use strict;
package Mebius::Data;

#-----------------------------------------------------------
# テーブルのカラム設定
#-----------------------------------------------------------
sub main_table_column{

my $column = {

number => { PRIMARY => 1 } ,

title => { } , 
text => { text => 1 } , 

good_num => { int => 1 } ,
good_accounts => { text => 1 } ,
good_cnumbers => { text => 1 } ,
good_addrs => { text => 1 } ,

access_count => { int => 1  } , 
access_addrs => { text => 1 }  ,
access_cnumbers => { text => 1 }  ,

deleted_flag => { int => 1 } ,
penalty_flag => { int => 1 } ,

account => { } ,
addr => { } , 
host => { } ,  
cnumber => { } ,
mobile_uid => { } , 
user_id => {} , 

handle => { } ,

create_time => { int => 1 } ,
last_update_time => { int => 1 } , 
last_modified => { int => 1 } , 

};

$column;

}

1;
