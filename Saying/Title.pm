
use strict;
package Mebius::Saying::Title;
use base qw(Mebius::Base::DBI);

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
"saying_title"
}

#-----------------------------------------------------------
# テーブルのカラム設定
#-----------------------------------------------------------
sub main_table_column{

my $column = {
title => { PRIMARY => 1 } , 
guide => { text => 1 } , 
category => {} , 
create_number => { int => } , 

creater_account => {} , 
creater_addr => {} , 

create_time => { int => 1 } , 
last_update_time => { int => 1 } , 
};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub {


}


1;
