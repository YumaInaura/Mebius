
use strict;
package Mebius::Namae;
use base qw(Mebius::Base::Basic);

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
sub main_limited_package_name{
"namae";
}

