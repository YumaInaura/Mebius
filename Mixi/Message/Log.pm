
use strict;

use Mebius::Mixi::Message;
package Mebius::Miix::Log;

use Mebius::Export;

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

my $self = shift;
my $object = new Mebius::Mixi;

$object;

}


1;

