
use strict;
package Mebius::Video::PushGoodVideo;
use base qw(Mebius::Base::DBI Mebius::Base::PushGood Mebius::Base::Data);

#-----------------------------------------------------------
# �I�u�W�F�N�g�֘A�t��
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic_object{
my $basic = new Mebius::Video;
}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_limited_package_name{
"video";
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
sub main_table_name{
"video_push_good_video";
}



1;
