
use strict;
package Mebius::ActionLog;

#-----------------------------------------------------------
# �e�[�u����
#-----------------------------------------------------------
sub main_table_name{
"action_log";
}


#-----------------------------------------------------------
# �J�����̐ݒ�
#-----------------------------------------------------------
sub main_table_column{

# �f�[�^��`
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
# �e�[�u�����쐬
#-----------------------------------------------------------
sub create_main_table{

my($main_table_name) = main_table_name() || die;

my($set) = main_table_column();

Mebius::DBI->create_memory_table(undef,$main_table_name,$set);

}


1;
