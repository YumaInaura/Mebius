
use strict;
package Mebius::Video::Video;
use Mebius::Video::Basic;
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
sub limited_package_name{
"video";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {

target => { PRIMARY => 1 }  ,
video_id => { INDEX => 1 } , 
service_kind => { } ,
title => { } , 
description => { text => 1 } , 
disabled => { int => 1 } , 
last_modified => { int => 1 } , 
create_time => { int => 1 } ,

};

$column;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"video_video";
}

1;

