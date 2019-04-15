
use strict;
package Mebius::BBS::Wait;
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
"bbs_wait";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

# データ定義
my $column = {
create_time => { int => 1 } ,
target => { PRIMARY => 1 } , 
acccout => { INDEX => 1 } , 
cnumber => { INDEX => 1 } , 
xip => { INDEX => 1 } , 
submit_type => { } , 
submit_time => { int => 1 } ,
wait_second => { int => 1 } ,
};

$column;

}

1;
