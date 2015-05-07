
use strict;
package Mebius::Video::Tag;
use Mebius::Video::Basic;
use Mebius::Video::Post;
use Mebius::Video::TagList;
use base qw(Mebius::Base::Tag);

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
my $basic = new Mebius::Video;
$basic;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"video_tag";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub relation_object{
my $object = new Mebius::Video::Post;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tag_list_object{
my $object = new Mebius::Video::TagList;
}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub taglist_object{

my $self = shift;
my $tag_list = new Mebius::Video::TagList;
$tag_list;
}




1;