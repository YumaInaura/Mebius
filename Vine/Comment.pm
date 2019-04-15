
use strict;
package Mebius::Vine::Comment;
use base qw(Mebius::Vine Mebius::Base::DBI Mebius::Base::Comment Mebius::Base::Data);

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
sub relation_object{

my $self = shift;
my $object = new Mebius::Vine::Post;
$object;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"comment";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub regist_error{

my $self = shift;
my $error = shift;
my $post = $self->relation_object();
my($param) = Mebius::query_single_param();
$post->self_view($param->{'relation_target'},$error);
}



1;

