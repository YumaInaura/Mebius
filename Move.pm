
package Mebius::Move;

use strict;
use Mebius::Redirect;
use Mebius::URL;

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
sub redirect_to_self_url{

my $self = shift;
my $url_obj = new Mebius::URL;

	if($ENV{'REQUEST_METHOD'} eq "POST"){
		my $request_url = $url_obj->request_url();
		Mebius::redirect($request_url);
	} else {
		0;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub redirect{
my $self = shift;
Mebius::redirect(@_);

}



1;
