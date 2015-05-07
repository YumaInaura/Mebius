
use strict;
package Mebius::NewHistory;
use base qw(Mebius::Base::DBI);

#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
my $self = shift;
"history";
}


#-----------------------------------------------------------
# カラム名
#-----------------------------------------------------------
sub main_table_column{

my $column = {
content_type => { INDEX => 1 } , 

subject => { } , 

account => { INDEX => 1 } , 
handle => { } ,
post_time => { int => 1 } ,

deleted_flag => { int => 1 } , 

my_regist_time => { int => 1 } , 
last_read_time => { int => 1 } ,
last_modified => { int => 1 }  ,
last_modified_number => { int => 1 } ,

response_num => { int => 1 } , 

};

$column;

}



1;
