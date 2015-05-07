
use strict;
package Mebius::Namae;
use base qw(Mebius::Base::Post Mebius::Base::Data );

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


