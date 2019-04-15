
use strict;
package Mebius::Video::TagList;
use Mebius::Video::Basic;
use Mebius::Video::Tag;
use base qw(Mebius::Base::TagList);

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
sub basic_object{
my $object = new Mebius::Video;
$object;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"video_taglist";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub relation_object{

my $self = shift;
my $object = new Mebius::Video::Tag;
$object;

}

1;
