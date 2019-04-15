
package Mebius::Mixi::Saint;
use strict;

use Mebius::Mixi::Basic;

use Mebius::LWP;
use Mebius::Query;

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
sub login{

my $self = shift;
my(%input);
my $lwp = new Mebius::LWP;

my $account = "navitomo";
my $password = "yuma";

my $url = "https://www.saint-corporation.com/admin/login.php";

$input{'mode'} = "login";
$input{'login_id'} = $account;
$input{'passwd'} = $password;
$input{'send'} = "LOGIN";

#my $html = $lwp->post($url,\%input,"./saint/yuma_cookie.txt");
my $html = $lwp->get($url,"./saint/yuma_cookie.txt");

$html;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();

	if($param->{'mode'} eq "saint_get"){
		$self->self_view();
	}
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic_object{

my $self = shift;
my $object = new Mebius::Mixi;

$object;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub self_view{

my $self = shift;
my $basic = $self->basic_object();
my($print);

my $logined_html = $self->login();
$basic->print_html($logined_html);

exit;

}



1;
