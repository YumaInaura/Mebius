
package Mebius::BBS::Res;
use strict;

use base qw(Mebius::Base::DBI Mebius::Base::Data);

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"bbs_res";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

# データ分解
my $column = {
target => { INDEX => 1 } , 
bbs_kind => { INDEX => 1 },
thread_number => { int => 1 , INDEX => 1 } ,
res_number => { int => 1 , INDEX => 1 } , 
cookie_char => { INDEX => 1 },
handle => { INDEX => 1 },
trip => { INDEX => 1 },
comment => { text => 1 , },
date => { },
host => { INDEX => 1 },
id => { INDEX => 1 },
color => { },
user_agent => { INDEX => 1 },
user_name => { },
deleted => { INDEX => 1 },
account => { INDEX => 1 },
image_data => { },
concept => { },
regist_time => { int => 1 , INDEX => 1 },
addr => { INDEX => 1 },
};

$column;

}

1;
