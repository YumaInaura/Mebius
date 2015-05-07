
use strict;
package Mebius::Server;

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
sub local_machine_lan_addr{
"192.168.0.6";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub local_machine_lan_judge{

my $self = shift;
my($flag);

my $local_machine_addr = $self->local_machine_lan_addr();

	if($local_machine_addr eq $ENV{'SERVER_ADDR'}){
		$flag = 1;
	} else {
		0;
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub http_host{

my $self = shift;
my $http_host = $ENV{'HTTP_HOST'};
$http_host;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub http_host_url{

my $self = shift;

my $http_host = $self->http_host();

my $http_host_url = "http://$http_host/";

$http_host_url;

}


#-----------------------------------------------------------
# BBS用のサーバーかどうかを判定
#-----------------------------------------------------------
sub bbs_server_judge{

my $flag;

my($server_init) = Mebius::all_server_addrs_multi();

	if($server_init->{$ENV{'SERVER_ADDR'}}->{'bbs_server_flag'}){
		$flag = 1;
	}

$flag;

}

#-----------------------------------------------------------
# 全サーバーの IP 
#-----------------------------------------------------------
sub all_server_addrs{

my @self;

my($server_init) = Mebius::all_server_addrs_multi();
	foreach( keys %$server_init ){
		push(@self,$_);
	}

\@self;

}


1;
