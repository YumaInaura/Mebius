
use strict;
use Mebius::HTML;
package Mebius::PageBack;

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
sub link{

my $self = shift;
my $html = new Mebius::HTML;
my($param) = Mebius::query_single_param();
my($link);


	if( my $url = Mebius::justy_url_check($param->{'backurl'})){
		$link = "(" .$html->href($url,"戻る") . ")";
	} else {
		return();
	}


$link;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub input_hidden{

my $self = shift;
Mebius::back_url_input_hidden();
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub redirect{
my $self = shift;
Mebius::redirect_to_back_url();
}


1;
