
use strict;

package Mebius::LWP;

use Mebius::Encoding;
use Mebius::Proxy;

use LWP::Simple qw();
use LWP::UserAgent qw();
use HTTP::Cookies;
use HTTP::Request qw();
use Mebius::Console;
#use Crypt::SSLeay;

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
sub get{

my $self = shift;
my $url = shift || die;
my $use = shift || {};
my $encoding = new Mebius::Encoding;
my $console = new Mebius::Console;
my($html);

console("Access to $url ( GET )");

my %new_use = (%{$use},( url => $url ));
my ($ua,$cookie_jar) = $self->ready(\%new_use);

my $request = new HTTP::Request (GET => $url);
$self->use_to_request_setting($request,\%new_use);


	for(1..5){

		my $response = $ua->request($request);
		my $temporary_html = $response->content();

			if($self->html_to_failed_proxy_judge($temporary_html,$use)){
				console "Try again.";
				$console->count_sleep(5);
			} else {
				$html = $temporary_html;
				last;
			}
	}


$cookie_jar->save($use->{'cookie_file'});

#$html = $encoding->eucjp_to_utf8($html);

	if(wantarray){
		$html,$cookie_jar;
	} else {
		$html;
	}


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub post{

my $self = shift;
my $url = shift || die;
my $input = shift || die;
my $use = shift || {};
my $encoding = new Mebius::Encoding;
my $console = new Mebius::Console;
my(@input,$html);

console("Post to $url ( POST )");

my %new_use = (%{$use},( url => $url ));

my($ua,$cookie_jar) = $self->ready(\%new_use);

	if(ref $input eq "HASH"){

			foreach my $key ( keys %{$input} ){

				my $value = $input->{$key};

					push @input , $key; #console "key: $key"; 

					#if(ref $value){
					#	die "Value : $value is not normal scalar.";
					#} else {	
						push @input , $value; #console "key: $key"; 
					#}


			}
	}

my $request = HTTP::Request::Common::POST(
	$url,
	Content_Type => 'form-data',
	Content => \@input ,
);


$self->use_to_request_setting($request,\%new_use);

#my $response = $ua->request($request);
#my $html = $response->content();


	for(1..5){

		my $response = $ua->request($request);
		my $temporary_html = $response->content();

			if($self->html_to_failed_proxy_judge($temporary_html,$use)){
				console "Try again.";
				$console->count_sleep(5);
			} else {
				$html = $temporary_html;
				last;
			}
	}


$cookie_jar->save($use->{'cookie_file'});

	if(wantarray){
		$html,$cookie_jar;
	} else {
		$html;
	}


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub html_to_failed_proxy_judge{

my $self = shift;
my $html = shift;
my $use = shift || {};
my $proxy = new Mebius::Proxy;
my($failed_flag);

	if(!$html){
		console "Proxy is strange? HTML is empty. ";
		$failed_flag = 1;
	} elsif($html =~ /^read timeout at/){
		console "Proxy $use->{'proxy'} read timeout .";
		$failed_flag = 1;
	} elsif($html =~ /^Can't connect to |^establishing SSL tunnel failed|^Maximum number of open connections reached/){
		console "Proxy $use->{'proxy'} can't connect ";
		$failed_flag = 1;
	}

	if($failed_flag){
		$proxy->update_main_table({ failed_count => ["+",1] },{ WHERE => { proxy => $use->{'proxy'}  } });
	}

$failed_flag;

#read timeout at C:/Perl64/site/lib/Net/HTTP/Methods.pm line 268.
#Can't connect to 180.150.178.21:80 (10061) LWP::Protocol::http::Socket: connect: 10061 at C:/Perl64/site/lib/LWP/Protocol/http.pm line 49.

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub use_to_request_setting{

my $self = shift;
my $request = shift;
my $use = shift || {};
my($referer);

	if( $referer = $use->{'referer'} ){
		$request->referer($referer);
	} elsif ( $use->{'AutoReferer'} && ( $referer = $use->{'url'} ) && $use->{'url'} !~ /^https?/){
		$request->referer($referer);
	}

	if($referer){
		console "referer is " . $referer || "none";
	} else {
		console "referer is none";
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub ready{

my $self = shift;
my $use = shift || {};
my($cookie_jar,$cookie_file,$autosave,%cookie_setting,$proxy_addr_and_port);

my $user_agent = $use->{'user_agent'} || $self->browser_user_agent();
console "User agent is $user_agent";

my $ua = new LWP::UserAgent;
$ua->timeout(60);
$ua->env_proxy();

$ua->agent($user_agent);



$self->proxy_setting($ua,$use);
my $cookie_jar = $self->cookie_setting($ua,$use,wantarray);

$self->header_setting($ua);

	if(wantarray){
		($ua,$cookie_jar)
	} else {
		$ua;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub cookie_setting{

my $self = shift;
my $ua = shift || die;
my $use = shift || {};
my $wantarray = shift;
my($autosave);

my $cookie_file = $use->{'cookie_file'};

	if($wantarray){
		$autosave = 0;
	} else {
		$autosave = 1;
	}


my $cookie_jar = new HTTP::Cookies(
	file => "$cookie_file" ,
	autosave => $autosave ,
	ignore_discard => 1 ,
);

$ua->cookie_jar($cookie_jar);

$cookie_jar->load($cookie_file);

$cookie_jar;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub proxy_setting{

my $self = shift;
my $ua = shift;
my $use = shift || {};
my $proxy = new Mebius::Proxy;
my($proxy_addr_and_port,$http_proxy);

	if($use->{'random_proxy'} || $use->{'Proxy'} || $use->{'proxy'} eq "random"){

			if($use->{'url'} =~ /^https/){
				#$proxy_addr_and_port = $proxy->ssl_random_proxy() || die;
				$proxy_addr_and_port = $proxy->random_proxy() || die;
			} else {
				$proxy_addr_and_port = $proxy->random_proxy() || die;
			}

	} elsif( my $use_proxy = $use->{'proxy'} ){

		$proxy_addr_and_port = $use_proxy;

	}


	if($proxy_addr_and_port && !$use->{'url'}){
		die('Please relay url to proxy object. for example { url => "http://example.com" } ');
	}

	if($proxy_addr_and_port){

		$proxy_addr_and_port =~ s/[^0-9\.:]//g;

			if($use->{'url'} =~ /^https/){
				$http_proxy = "http://$proxy_addr_and_port/";
			} else {
				$http_proxy = "http://$proxy_addr_and_port/";
			}
	}

	if($http_proxy){
		#$ua->proxy([qw( https http )], "$proxy_ip:$proxy_port");

		$ua->proxy([qw(http https)], $http_proxy );
		console "Use proxy $proxy_addr_and_port ";
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub header_setting{

my $self = shift;
my $ua = shift || die;

$ua->default_header('Accept-Language' => "ja,en-US;q=0.8,en;q=0.6");
#$ua->default_headers->push_header("Accept-Encoding" => "gzip,deflate,sdch");
$ua->default_headers->push_header("Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8");


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub browser_user_agents{

my $self = shift;

my @list = (
'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)',
'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Win64; x64; Trident/6.0)',
'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)',
'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0)',
'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Win64; x64; Trident/6.0)',
'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; ARM; Trident/6.0)',
'Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; Touch; rv:11.0) like Gecko',
'Opera/9.52 (Macintosh; Intel Mac OS X; U; ja)',
'Opera/9.52 (Windows NT 5.1; U; ja)',
'Opera/9.60 (Macintosh; Intel Mac OS X; U; ja) Presto/2.1.1',
'Opera/9.60 (Windows NT 5.1; U; ja) Presto/2.1.1',
'Opera/9.61 (Windows NT 5.1; U; ja) Presto/2.1.1',
'Opera/9.62 (Windows NT 5.1; U; ja) Presto/2.1.1',
'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1) Opera 7.53 [ja]',
'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1) Opera 7.54 [ja]',
'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0) Opera 7.54u1 [ja]',
'Opera/7.54 (Windows 98; U) [ja]',
'Mozilla/4.78 (Windows NT 5.1; U) Opera 7.23 [ja]'
);

@list;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub random_browser_user_agent{

my $self = shift;

my @list = $self->browser_user_agents();

my $browser = $list[int rand(@list)];

$browser;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub browser_user_agent{

my $self = shift;

'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36';
}



1;