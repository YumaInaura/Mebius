
# 宣言
use strict;
package Mebius;
use Mebius::Export;

#-----------------------------------------------------------
# ドメインリンク
#-----------------------------------------------------------
sub domain_links{

#my($request_url) = Mebius::requst_url();
my($self);
my $request_uri = $ENV{'REQUEST_URI'};

my($all_server_init) = all_server_addrs_multi();
my($procotol_type) = Mebius::procotol_type();

	foreach( sort { $all_server_init->{$a}->{'number'} <=> $all_server_init->{$b}->{'number'} } keys  %$all_server_init ){
			if($_ eq $ENV{'SERVER_ADDR'}){
				$self .= qq(サーバー).e($all_server_init->{$_}->{'number'}).qq(\n);
			} else {
				$self .= qq(<a href=").e($procotol_type).qq(://).e($all_server_init->{$_}->{'main_domain'}).e($request_uri).qq(">サーバー).e($all_server_init->{$_}->{'number'}).qq(</a>\n);
			}
	}

$self;


}

#-----------------------------------------------------------
# メインサーバーのドメインを取得
#-----------------------------------------------------------
sub main_server_domain{

my($server_addr) = @_;
my($server_data) = Mebius::all_server_addrs_multi();

	if($server_addr eq ""){
		$server_addr = $ENV{'SERVER_ADDR'};
	}

my $self = $server_data->{$server_addr}->{'main_domain'};

}



#-----------------------------------------------------------
# 全てのサーバー・ドメイン
#-----------------------------------------------------------
sub all_server_addrs_multi{

my %self = (

"133.242.10.250" => {

	main_domain => "aurasoul.mb2.jp" ,

	number => 1 ,

	domains => {
		"aurasoul.mb2.jp" =>{
			ServerMainDomain => 1 , 
		} , 

		"sns.mb2.jp" => {
		} , 

		"question.mb2.jp" => {
		} , 


		"tags.mb2.jp" => {
		} , 

		"vine.mb2.jp" => {
		} , 


	} , 


} , 

"133.242.12.79" => {

	main_domain => "mb2.jp" ,

	bbs_server_flag => 1 ,

	number => 2 ,

	domains => {

		"mb2.jp" =>{
			ServerMainDomain => 1 , 
		} , 

	}

} , 

);


	if(Mebius::alocal_judge()){
		$self{'127.0.0.1'} = {
				number => 0 , 
				main_domain => "localhost" , 
				domains => { "localhost" => {} } , 
				bbs_server_flag => 1 ,
		};
	}

\%self;

}



#-----------------------------------------------------------
# サーバーアドレス情報からドメインを配列にして返す
#-----------------------------------------------------------
sub get_all_domains_core{

my(@self);
my $use = shift if(ref $_[0] eq "HASH");
my($all_addr_multi) = all_server_addrs_multi();
my $server = new Mebius::Server;

	foreach my $addr ( keys %$all_addr_multi ){

			foreach my $domain ( keys %{$all_addr_multi->{$addr}->{'domains'}} ){

						if($use->{'LimitedServerDomain'} && !$all_addr_multi->{$addr}->{$domain}->{'ServerMainDomain'}){ next; }

					push(@self,$domain);

			}


	}

	if(Mebius::alocal_judge()){
		push @self , "127.0.0.1";
		push @self , $server->local_machine_lan_addr();
	}

@self;

}


#-----------------------------------------------------------
# 全ドメイン
#-----------------------------------------------------------
sub all_domains{
my(@domains) = get_all_domains_core();
@domains;
}

#-----------------------------------------------------------
# 全サーバーのメイン・ドメイン
#-----------------------------------------------------------
sub all_server_domains{
my(@self) = get_all_domains_core({ LimitedServerDomain => 1 } );
}

#-----------------------------------------------------------
# ジャンプ
#-----------------------------------------------------------
sub Domainlinks{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$nowdomain,$plus_url) = @_;
my($line,$domain,$i,@domains,$http);

# リターン
if($nowdomain eq ""){ return(); }

$http = "http";
	if($type =~ /Admin-mode/){ $http = $basic_init->{'admin_http'}; }

# http ~ からの部分などを除外
$plus_url =~ s|^https?://([a-z0-9A-Z\.]+)/||;
$plus_url =~ s|^/||;

# ドメインを宣言
@domains = ("aurasoul.mb2.jp","mb2.jp");
	if(Mebius::alocal_judge() || $type =~/And-localhost/){ push(@domains,"localhost"); }

	# ドメインを展開
	foreach $domain (@domains){
		my($link);
		$i++;
		$plus_url =~ s|^/||g;
		$link = qq(${http}://$domain/$plus_url);
			if($i >= 2){ $line .= qq( - ); }
			if($domain eq $nowdomain){ $line .= qq($domain); }
			else{ $line .= qq(<a href="$link">$domain</a>); }
	}

return($line);

}

1;
