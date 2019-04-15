
package Mebius::Mixi::Login;

use strict;

use Mebius::Mixi::Basic;
use Mebius::Mixi::Account;

use Mebius::LWP;
use Mebius::Encoding;

use LWP::UserAgent qw();
use LWP::Simple qw();
use HTTP::Cookies;
use HTTP::Request::Common qw();
use LWP::UserAgent qw();

use Mebius::Export;
use base qw(Mebius::Base::DBI Mebius::Mixi::Account);

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
my $object = new Mebius::Mixi;
}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub use_proxy_switch{
return 1;
}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub login{

my $self = shift;
my $email = shift || return();
my $use = shift || {};
my $basic = $self->basic_object();
my $encoding = new Mebius::Encoding;
my $mixi_account = new Mebius::Mixi::Account;
my $mebius_lwp = new Mebius::LWP;
my($print,@line,$success_flag,$password,$post_key,$use_proxy);

	if($email =~ /^([0-9]+)$/){
		my $mixi_id = $1;
		my $data = $mixi_account->fetchrow_main_table({ account => $mixi_id },{ Debug => 0 })->[0];
		$email = $data->{'email'} || return();
		$password = $data->{'password'} || return();
	}

$password ||= $basic->email_to_password($email);

$email =~ s/[^0-9a-zA-Z\@\-_\.]//g;
	if(!$email){ return(); }

my $data = my $data_exists = $self->fetchrow_main_table({ email => $email })->[0];

	if($self->use_proxy_switch()){
		#$use_proxy = $data->{'proxy'} || warn("No use proxy.");
		$use_proxy = $self->useful_proxy($data) || die;
	}

my $cookie_file = $self->cookie_file($email);
my $login_inverval_time = 3*24*60*60 || die;

	if($use->{'login_mode'} eq "input" || $data->{'last_logout_time'} >= $data->{'last_login_time'}){
		$basic->try_log($email,"Forced new login.");
	} elsif($self->cookie_logined_check($email)){
		console "Login by cookie.";
		return 1;
		#elsif($data->{'last_login_time'} && time < $data->{'last_login_time'} + $login_inverval_time && -f $cookie_file){
	} else {
		$basic->try_log($email,"New input login because cookie is invalidity.");
		console("$email try login to mixi.");
	}

my $login_menu_url = "https://mixi.jp/";

my $login_menu_html = $mebius_lwp->get($login_menu_url,{ proxy => $use_proxy , cookie_file => $cookie_file });
$login_menu_html = $encoding->eucjp_to_utf8($login_menu_html);
my $post_key = $basic->html_to_post_key($login_menu_html,$email);

	if($login_menu_html =~ m!<title>[mixi]</title>!){

		$basic->succeed_log($email,"Still logined at mixi home.",$login_menu_html);
		$self->update_main_table({ target => $data->{'target'} , email => $email , last_login_time => time , last_login_missed_time => 0 });
		return 1;

	} elsif(!$post_key && $self->ssl_broken_mode()){

		my $mixi_news_login_form_url = "http://news.mixi.jp/?show_login=1";
		my $mixi_news_login_form_html = $mebius_lwp->get($mixi_news_login_form_url,{ proxy => $use_proxy , cookie_file => $cookie_file });
		$basic->try_log($email,"News top page was got.",$mixi_news_login_form_html);

			if($mixi_news_login_form_html =~ m!<title>mixiニュース</title>!){
				$basic->succeed_log($email,"Still logined mixi news.",$login_menu_html);
				$self->update_main_table({ target => $data->{'target'} , email => $email , last_login_time => time , last_login_missed_time => 0 });
				return 1;
			}

		$post_key = $basic->html_to_post_key($mixi_news_login_form_html,$email);
	}

	if($post_key){
		$basic->succeed_log($email,"View at first page of mixi.",$login_menu_html);
	} else {
		$basic->failed_log($email,"Can not view at first page of mixi.",$login_menu_html);
		$basic->sleep(3);
		next;
	}

#$basic->try_log($email,"At first , access to mixi top page.",$login_menu_html);

$basic->preview_sleep();

my %input = (email => $email , password => $password , post_key => $post_key , next_url => "/home.pl" , sticky => 1 );
my $url_for_post = "https://mixi.jp/login.pl?from=login0";
my $logined_html = $mebius_lwp->post($url_for_post,\%input,{ proxy => $use_proxy , cookie_file => $cookie_file , referer => $login_menu_url });
$logined_html = $encoding->eucjp_to_utf8($logined_html);

	if($logined_html =~ m!http-equiv="refresh"!){

		$success_flag = 1;
		$self->login_succeed_log($data,$data_exists,$logined_html);

	} elsif($self->html_to_update_account($logined_html,$email,"login")){

		$success_flag = 0;
		$basic->failed_log($email,"Can not input new login.",$logined_html);
		return();


	} elsif($logined_html =~ /id="additional_auth_data_id" value="([0-9a-z]+)"/) {

		my $auth_data_id = $1;

		$basic->failed_log($email,"Can not input new login without input birthday.",$logined_html);

		$basic->preview_sleep();

		# 誕生日を入力
		my %input_for_birthday = ( year => $data->{'year'} , month => $data->{'month'} , day => $data->{'day'} , mode => "additional_auth_post" , additional_auth_data_id => $auth_data_id );
		my $url_for_birthday = "https://mixi.jp/login.pl?from=login1";
		my $birthday_inputed_html = $mebius_lwp->post($url_for_birthday,\%input_for_birthday,{ proxy => $use_proxy , cookie_file => $cookie_file , referer => $url_for_birthday });

			if($birthday_inputed_html =~ m!http-equiv="refresh"!){
				$self->login_succeed_log($data,$data_exists,$birthday_inputed_html);
				$success_flag = 1;
			} else {
				$basic->failed_log($email,"Failed birthday input.",$birthday_inputed_html);
				return();
			}

	} else {

		$basic->failed_log($email,"Can not input new login.",$logined_html);
		return();

	}

my $home_url = "http://mixi.jp/home.pl";
my $home_html = $mebius_lwp->get($home_url,{ proxy => $use_proxy ,  cookie_file => $cookie_file , referer => $login_menu_url });
$home_html = $encoding->eucjp_to_utf8($home_html);

$mixi_account->profile_html_to_update_account($home_html,$data);

$basic->rest_sleep();

$success_flag;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub login_succeed_log{

my $self = shift;
my $data = shift;
my $data_exists = shift;
my $logined_html = shift;
my $basic = $self->basic_object();

my $email = $data->{'email'};

$basic->succeed_log($email,"New input login succeed.",$logined_html);

	if($data_exists){
		$self->update_main_table({ target => $data->{'target'} , email => $email , last_login_time => time , last_login_missed_time => 0 });
	} else {
		my $new_target = $self->new_target_char();
		$self->insert_main_table({ target => $new_target , email => $email , last_login_time => time , last_login_missed_time => 0 });
	}

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub logout{

my $self = shift;
my $email = shift || (warn && return());
my $use = shift || {};
my $mebius_lwp = new Mebius::LWP;
my $basic = $self->basic_object();
my $account = new Mebius::Mixi::Account;
my $encoding = new Mebius::Encoding;
my($use_proxy);

	if(!$use->{'referer'}){
		warn "Referer is empty.";
	}

my $account_data = my $account_data_exists = $self->fetchrow_main_table({ email => $email })->[0];
my $cookie_file = $self->cookie_file($email);

	if($self->use_proxy_switch()){
		$use_proxy = $self->useful_proxy($account_data) || die;
	}

my %new_use = (%{$use},( proxy => $use_proxy , cookie_file => $cookie_file ));

my $logout_url = "https://mixi.jp/logout.pl";
my $logouted_html = $mebius_lwp->get($logout_url,\%new_use);
$logouted_html = $encoding->eucjp_to_utf8($logouted_html);

	#if($logouted_html =~ m!次回から自動的にログイン!){
	if($logouted_html =~ m!<title>ソーシャル・ネットワーキング サービス!){

		$basic->finished_log($email,"Logouted.",$logouted_html);
		$account->update_main_table({ target => $account_data->{'target'} , last_logout_time => time });
	} else {
		$basic->failed_log($email,"Can not logout.",$logouted_html);
	}

#my %login_use = %new_use;
#$login_use{'referer'} = $logout_url;
#my $login_url = "https://mixi.jp/";
#my $login_html = $mebius_lwp->get($login_url,\%new_use);
#$login_html = $encoding->eucjp_to_utf8($login_html);

$basic->rest_sleep();

}




#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub cookie_logined_check{

my $self = shift;
my $email = shift || die;
my $mebius_lwp = new Mebius::LWP;
my $mixi_account = new Mebius::Mixi::Account;
my $encoding = new Mebius::Encoding;
my $basic = $self->basic_object();
my($flag,$do,$use_proxy);

my $cookie_file = $self->cookie_file($email) || die;
my $account_data = my $account_data_exists = $self->fetchrow_main_table({ email => $email })->[0];

	if($self->use_proxy_switch()){
		$use_proxy = $self->useful_proxy($account_data) || die;
	}

	if($account_data->{'last_login_missed_time'}){
		$do = 1;
	} elsif(!$account_data->{'last_login_check_time'}){
		$do = 2;
	} elsif(time > $account_data->{'last_login_check_time'} + 3*60*60){
		$do = 3;
	} else {
		return 1;
	}

$basic->try_log($email,"Periodic login check.");

#my $url = "http://mixi.jp/home.pl";
my $url = "https://mixi.jp/home.pl";

my $html = $mebius_lwp->get($url,{ proxy => $use_proxy , cookie_file => $cookie_file , AutoReferer => 1   });
$html = $encoding->eucjp_to_utf8($html);

	#if($html =~ /マイミク一覧|友人一覧/){
	if($html =~ /さん\([0-9]+\)/){
		$basic->try_log($email,"Periodic login check succeed.",$html);
		$mixi_account->update_main_table({ target => $account_data->{'target'} , email => $email , last_login_check_time => time  , last_login_missed_time => 0 });
		$flag = 1;
	} else {
		$basic->try_log($email,"Periodic login check failed. Cookie is invalid and logout .",$html);
		$mixi_account->update_main_table({ target => $account_data->{'target'} , email => $email  });
		# , last_login_check_time => time
		$flag = 0;

	}

$basic->rest_sleep();

$flag;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub html_to_update_account{

my $self = shift;
my $html = shift || return();
my $email = shift || return();
my $type = shift || die;
my $mixi_account = new Mebius::Mixi::Account;
my $basic = $self->basic_object();
my($flag,$print,$message);

	if($html =~ m!<p>(メールアドレスもしくはパスワードが異なります。)</p>!){

		$basic->failed_log($email,"Email or password is invalid.",$html);
		$mixi_account->update_main_table({ can_not_login_message => "パスワードが異なります" , status => "empty" , last_login_missed_time => time },{ WHERE => { email => $email } });
		$flag = 1;
		$message = $1;

	} elsif($html =~ m!<strong>(現在、mixiの利用を停止させていただいております。)</strong>!){

		$basic->failed_log($email,"Denied account.",$html);
		$mixi_account->update_main_table({ can_not_login_message => "利用停止" , status => "deny" , last_login_missed_time => time },{ WHERE => { email => $email } });
		$flag = 1;
		$message = $1;

	} elsif($html =~ m!(一時的に機能を制限させていただきます。自動的に解除されるまでお待ちください。)</p>!){

		$basic->failed_log($email,"Temporary blocked account.",$html);
		$mixi_account->update_main_table({ can_not_login_message => "一時制限" , account_type => "limited" , temporary_block_time => time , last_login_missed_time => time },{ WHERE => { email => $email } });
		$flag = 1;
		$message = $1;

	} elsif($html =~ m!<label for="auto">次回から自動的にログイン</label>!){

		$flag = 1;
		$message = "ログイン不可";


		my $account_data = $self->fetchrow_main_table({ email => $email })->[0];
		$mixi_account->update_main_table({ last_login_missed_time => time  },{ WHERE => { email => $email }});

		$basic->failed_log($email,"Logout page view only.",$html);

		#$mixi_account->update_main_table({ last_login_time => 0 },{ WHERE => { email => $email } });

			#if( time < $account_data->{'last_login_time'} - 60*60 ){
			#	$mixi_account->update_main_table({ last_login_missed_time => time , status => "empty" },{ WHERE => { email => $email }});
			#} else {
			#}
	}


	if($flag){

		$basic->failed_log($email,"Can not login. [$type]",$html);

		#$print = "実行できませんでした。 " . e($email) . " - "  .  e($message) . " - " . e($type);
		#$basic->print_html($print);
		#exit;
	}

$flag;

}





#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub random_account_get{

my $self = shift;
my $url = shift || return();
my $basic = $self->basic_object();

my $account_data = $basic->random_limited_account_data();
$self->get($url,$account_data->{'email'},@_);

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub get{

my $self = shift;
my $url = shift || return();
my $email = shift || return();
my $use = shift || {};
my $password = shift;
my $encoding = new Mebius::Encoding;
my $basic = $self->basic_object();
my $lwp = new Mebius::LWP;
my($got_html,$use_proxy);

	if($url !~ /https?/){
		die("URL format is starnge. $url ")
	}

my $data = my $data_exists = $self->fetchrow_main_table({ email => $email })->[0];
	if($self->use_proxy_switch()){
		#$use_proxy = $data->{'proxy'} || warn("No use proxy.");
		$use_proxy = $self->useful_proxy($data) || die;
	}

my $cookie_file = $self->cookie_file($email);
my %new_use = (%{$use},( cookie_file => $cookie_file , proxy => $use_proxy , AutoReferer => 1 , user_agent => $data->{'browser_user_agent'} ));

my $login_succeed = $self->login($email);

	if(!$login_succeed){
		return();
	}

$basic->try_log($email,"Access to ${url} .");

$got_html = $lwp->get($url,\%new_use);
my $utf8_html = $encoding->eucjp_to_utf8($got_html);

	if($url !~ m!^https?://mixi\.jp/logout\.pl! && $self->html_to_update_account($utf8_html,$email,"get")){
		return 0;
	} else {
		return $got_html;
	}


}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub post{

my $self = shift;
my $url = shift || return();
my $email = shift || return();
my $input = shift || {};
my $use = shift || {};
my $basic = $self->basic_object();
my $encoding = new Mebius::Encoding;
my $mebius_lwp = new Mebius::LWP;
my(%euc_input,$ua,$got_html,$use_proxy);

	if($url !~ /https?/){
		die("URL format is starnge. $url ")
	}

my $data = my $data_exists = $self->fetchrow_main_table({ email => $email })->[0];

my %euc_input = %{$input};

	foreach my $key ( keys %{$input} ){
		$euc_input{$key} = $encoding->utf8_to_eucjp($euc_input{$key});
	}

my $cookie_file = $self->cookie_file($email);

	if($self->use_proxy_switch()){
		$use_proxy = $self->useful_proxy($data) || die;
	}

my %new_use = (%{$use},( cookie_file => $cookie_file , proxy => $use_proxy , AutoReferer => 1 , user_agent => $data->{'browser_user_agent'} ));

my $login_succeed = $self->login($email);

	if(!$login_succeed){
		return();
	}

#$basic->try_log($email,"Post to ${url}.");

$got_html = $mebius_lwp->post($url,\%euc_input,\%new_use);
my $utf8_html = $encoding->eucjp_to_utf8($got_html);

	if($url !~ m!^https?://mixi\.jp/logout\.pl! && $self->html_to_update_account($utf8_html,$email,"post")){
		return 0;
	} else {
		return $got_html;
	}


$got_html;


}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub useful_proxy{

my $self = shift;
my $account_data = shift;
my($use_proxy);
my $proxy = new Mebius::Proxy;
my $mixi_account = new Mebius::Mixi::Account;
my $basic = $self->basic_object();
my($now_proxy_data,$change_flag,$useful_proxy_flag);

my $email = $account_data->{'email'};
my $use_proxy = $account_data->{'proxy'};

	if(!$self->our_proxy_mode()){

		$useful_proxy_flag = $proxy->useful_proxy_judge($account_data->{'proxy'});

			if($account_data->{'proxy'} eq ""){
				$basic->try_log($email,"Proxy is empty.");
				$change_flag = 1;
			} elsif(!$useful_proxy_flag){
				$basic->try_log($email,"$account_data->{'proxy'} is not useful proxy.");
				$change_flag = 1;
			} elsif(time > $account_data->{'change_proxy_time'} + 3*24*60*60){
				$basic->try_log($email,"$account_data->{'proxy'} is old setting proxy.");
				$change_flag = 1;
			}

			if($change_flag){
				$use_proxy = my $useful_proxy = $proxy->random_proxy();
				$basic->try_log($email,"Change proxy, $account_data->{'proxy'} to $useful_proxy.");
				$mixi_account->update_main_table({ target => $account_data->{'target'} , proxy => $useful_proxy , change_proxy_time => time });
			}

	}

$use_proxy;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub our_proxy_mode{
1;
}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub cookie_file{

my $self = shift;
my $email = shift || return();

my $directory = $self->cookie_directory();
my $file = "${directory}$email.cookie.txt";

$file;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub cookie_directory{

my $self = shift;
my($directory);

	if(Mebius::alocal_judge()){
		$directory = "C:/Apache2.2/cgi-bin/navi-tomo/cookie/mixi/";
	} else {
		$directory = "/perl/mixi/cookie/";
	}

$directory;

}




#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub url_to_post_key{

my $self = shift;
my $url = shift;
my $email = shift;
my $basic = $self->basic_object();

my $html = $self->get($url,$email);
my $post_key = $self->html_to_post_key($html,$email);


$post_key;

}




#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub html_to_postkey{

my $self = shift;
my $html = shift;
my $email = shift;

$self->html_to_post_key($html,$email,"postkey");

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub html_to_post_key{

my $self = shift;
my $html = shift || return();
my $email = shift;
my $input_name = shift || "post_key";
my $order = shift;
my $basic = $self->basic_object();
my $mixi_account = new Mebius::Mixi::Account;
my($return_post_key,@post_key,$account_data);

	if($email){
		$account_data = $mixi_account->fetchrow_main_table({ email => $email });
	}

	#if($html =~ m!(?:\s+)value=(?:\s*)"([0-9a-zA-Z]+)"(?:\s+)name="$input_name"!){
	#	$post_key = $1;
	#} elsif($html =~ m!(?:\s+)name="$input_name"(?:\s+)value=(?:\s*)"([0-9a-zA-Z]+)"!){
	#	$post_key = $1;
	#} elsif($html =~ m!<input(?:\s+)name="$input_name"(?:\s+)type="hidden"(?:\s+)value=(?:\s*)"([0-9a-zA-Z]+)"!){
	#	$post_key = $1;
	#}

	while($html =~ s!(?:\s+)value=(?:\s*)"([0-9a-zA-Z]+)"(?:\s+)name="$input_name"!!){
		push @post_key , $1;
	}
	while($html =~ s!(?:\s+)name="$input_name"(?:\s+)value=(?:\s*)"([0-9a-zA-Z]+)"!!){
		push @post_key , $1;
	}
	while($html =~ s!<input(?:\s+)name="$input_name"(?:\s+)type="hidden"(?:\s+)value=(?:\s*)"([0-9a-zA-Z]+)"!!){
		push @post_key , $1;
	}

	# 成功
	if(@post_key){

		$basic->succeed_log($email,"Get $input_name : @post_key",$html);

			if($order){
				$return_post_key = $post_key[$order];
			} else {
				$return_post_key = $post_key[0];
			}

			if($email){
				$mixi_account->update_main_table_where({ $input_name => $return_post_key },{ email => $email });
			}

	} else {
		$basic->try_log($email,"Can not get $input_name.",$html);
	}



return $return_post_key;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub html_to_token{

my $self = shift;
my $html = shift || return();
my($token);


	if($html =~ m!name="token" value="([0-9a-z_]+)"!){
		$token = $1;
	}

$token;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub ssl_broken_mode{
1;
}


1;