
#kd106137213119.au-net.ne.jp
#kd106137206043.au-net.ne.jp

use strict;
package Mebius::Mixi;
use Mebius::Basic;

use Mebius::Mixi::Login;
use Mebius::Mixi::Community;
use Mebius::Mixi::Account;
use Mebius::Mixi::ActionLog;
use Mebius::Mixi::Event;
use Mebius::Mixi::EventSchedule;
use Mebius::Mixi::Message;

use Mebius::Mixi::Submit;
use Mebius::Mixi::Saint;
use Mebius::Mixi::Navitomo;
use Mebius::Mixi::Friend;
use Mebius::Mixi::Task;

use Mebius::HTML;
use Mebius::Query;
use Mebius::Console;

use LWP::Simple qw();
use Mebius::Export;
use base qw(Mebius::Base::Basic Mebius::Mixi::Login);

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
"mixi";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my $query = new Mebius::Query;
my($param) = $query->param();
my $navi_tomo = new Mebius::Mixi::Navitomo;
my $community = new Mebius::Mixi::Community;
my $mixi_account = new Mebius::Mixi::Account;
my $submit_event = new Mebius::Mixi::Submit;
my $login = new Mebius::Mixi::Login;
my $event = new Mebius::Mixi::Event;
my $saint = new Mebius::Mixi::Saint;
my $friend = new Mebius::Mixi::Friend;
my $action_log = new Mebius::Mixi::ActionLog;
my $message = new Mebius::Mixi::Message;
my $out_comment = new Mebius::Mixi::Submit::OutComment;

my $mode = $param->{'mode'} || $ARGV[0];

	#if($param->{'mode'} eq "login"){
	#	$login->test_view();
	#} els


	if($mixi_account->junction()){
		1;
	} elsif($submit_event->junction()){
	} elsif($friend->junction()){
		1;
	} elsif($saint->junction()){
		1;
	} elsif($message->junction()){
		1;
	} elsif($action_log->junction()){
		1;
	} elsif($out_comment->junction()){
		1;
	} elsif($event->junction()){
		1;
	} elsif($community->junction()){
		1;
	} elsif($mode eq "test"){
		$self->test_view();
		1;
	} elsif($mode eq "logout"){
		$self->logout($ARGV[1]);
	} elsif($mode eq "url" || $mode eq "free_access"){
		$self->url_view();
		1;
	} elsif(console) {
		console "This mode is not exists. ";
	} else {
		$navi_tomo->login_form_view();
	}


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub url_view{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();
my $basic = $self->basic_object();
my($account_data);

my $email = $param->{'email'} || $ARGV[1] || die;
my $url = $param->{'url'} || $ARGV[2] || die;

	if($email){
		$account_data = $self->fetchrow_main_table({ email => $email })->[0];
	} else {
		$account_data = $basic->random_limited_account_data();
	}

my $html = $basic->get($url,$email);

$basic->try_log($email,"Free access to $url ",$html);

	if(console){
		print $html;
		exit;
	} else {
		$basic->print_html($html);
		exit;
	}


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub mixi_href{

my $self = shift;
my $url = shift;
my $title = shift;
my $html = new Mebius::HTML;
my $basic = $self->basic_object();

my $site_url = $basic->site_url();

my $encoded_url = Mebius::encode_text($url);
my $new_url = "${site_url}?mode=url&url=$encoded_url";

my $link = $html->href($new_url,$url);

$link;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub test_view{

my $self = shift;
my $basic = $self->basic_object();
my $encoding = new Mebius::Encoding;
my $community = new Mebius::Mixi::Community;
my $event = new Mebius::Mixi::Event;
my $submit_event = new Mebius::Mixi::Submit;
my $mixi_account = new Mebius::Mixi::Account;
my $action_log = new Mebius::Mixi::ActionLog;
my $friend = new Mebius::Mixi::Friend;

my($print,%input);

#$community->search_result_html_to_community_data_group();

#my $html = $basic->get("http://mixi.jp/",'tousiganbaru263@yahoo.co.jp');

$community->delete_all_comments_on_event_or_topic('m0931356670@z80-dea.info',1538067,77160488,"topic");




exit;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub control{

my $self = shift;
my $event = new Mebius::Mixi::Event;
my $query = new Mebius::Query;
my $param  = $query->param();

	foreach my $key ( keys %{$param} ){
		my $value = $param->{$key};
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub database_objects{

my(@object);

push @object , new Mebius::Mixi::Community;
push @object , new Mebius::Mixi::Event;

#push @object , new Mebius::Mixi::Login;
push @object , new Mebius::Mixi::Account;
push @object , new Mebius::Mixi::Submit;
push @object , new Mebius::Mixi::ActionLog;
push @object , new Mebius::Mixi::Friend;
push @object , new Mebius::Mixi::Task;
push @object , new Mebius::Mixi::EventSchedule;
push @object , new Mebius::Mixi::Message;
push @object , new Mebius::Mixi::Message::Task;

#push @object , new Mebius::Mixi::Submit::OutComment;

@object;

}





#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub navigation_link_group{

my $self = shift;
my $site_url = $self->site_url();

my @links = (
{ url => "${site_url}" , title => "トップ" },
{ url => "${site_url}?mode=account" , title => "アカウント" },
{ url => "${site_url}?mode=submit_community" , title => "コミュニティ" },
{ url => "${site_url}?mode=submit_event" , title => "イベント" },
{ url => "${site_url}?mode=auto_submit_event_view" , title => "自動登録" },
{ url => "${site_url}?mode=action_log" , title => "アクションログ" },
{ url => "${site_url}?mode=message&type=send" , title => "メッセージ" },
{ url => "${site_url}?mode=test" , title => "テスト" },
{ url => "${site_url}?mode=saint_get" , title => "SAINT" },

);

#{ url => "${site_url}?mode=random_login" , title => "ランダムログイン" },


	if(Mebius::alocal_judge()){
		push @links , { url => "/cgi-bin/labo/proxy.cgi" , title => "プロクシ" };
	} else {
		push @links , { url => "/proxy.cgi" , title => "プロクシ" };
	}


\@links;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub mixi_url{
"http://mixi.jp/";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub profile_url{

my $self = shift;
my $account_id = shift || return();

#my $url = "http://mixi.jp/show_friend.pl?id=$account_id";
my $url = "http://mixi.jp/show_friend.pl?id=$account_id";

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_html_core{

my $self = shift;
my $use = shift || {};
my $body = shift;
my $html = new Mebius::HTML;
my(%new_use);

$new_use{'html_head'} .= '
<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=0">
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
'."\n";

$new_use{'inline_css'} .= qq(
body{line-height:1.6em;}
.red{color:red;}
.green,.gre{color:green;}
input:checked + label , input:checked + span , input:checked + strong{background:yellow !important;}
input + span:hover{background:orange;}
input[type="text"]:focus,input[type="password"]:focus,input[type="search"]:focus{background: #ffa;}
textarea:focus{background: #ffb;}
);

%new_use = (%{$use},%new_use);

$html->simple_print($body,\%new_use);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub email_to_password{

my $self = shift;
my $account = shift || return();
my $mixi_account = new Mebius::Mixi::Account;

my $data = $mixi_account->fetchrow_main_table({ account => $account , email => $account },{ OR => 1 })->[0];

$data->{'password'};

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_url{

my $self = shift;
my($site_url);

	if(Mebius::alocal_judge()){
		$site_url = "/cgi-bin/navi-tomo/mixi.cgi";
	} else {
		$site_url = "http://admin.special-party.net/mixi.cgi";
	}

$site_url;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_location_pref_ids{

my $self = shift;
my $data = shift || return();;
my @todoufuken = $self->todoufuken();
my(@hit_id);

	foreach my $hash (@todoufuken){

			if(ref $hash->{'place'} eq "ARRAY"){

					foreach my $place_name (@{$hash->{'place'}}){
							if($data->{'title'} =~ /$place_name/){
								push @hit_id , $hash->{'id'};
							}
					}
			}

			if($data->{'title'} =~ /$hash->{'title'}/){
				push @hit_id , $hash->{'id'};
			}
	}


@hit_id;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_todoufuken_select_parts_automatic{

my $self = shift;
my $data = shift || return();

my @automatic_hit_id = $self->data_to_location_pref_ids($data);
my $selected_pref_id = $data->{'location_pref_id'} || $automatic_hit_id[0];

$self->todoufuken_select_parts($selected_pref_id,"mixi_community_location_pref_id_$data->{'target'}");

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_todoufuken_select_parts{

my $self = shift;
my $data = shift || return();
$self->todoufuken_select_parts($data->{'location_pref_id'},"mixi_community_location_pref_id_$data->{'target'}");

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub todoufuken_select_parts{

my $self = shift;
my $selected_id = shift;
my $input_name = shift || die;
my $html = new Mebius::HTML;
my $basic = $self->basic_object();
my($print);

my @todoufuken = $basic->todoufuken();

$print .= $html->start_tag("select",{ name => $input_name });
	foreach my $data (@todoufuken){
		my $selected = 1 if($selected_id && $selected_id eq $data->{'id'});
		$print .= $html->tag("option",$data->{'title'},{ value => $data->{'id'} , selected => $selected });
	}

$print .= $html->close_tag("select");

$print;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub todoufuken{

my $self = shift;

my @array = (
{ title => "なし" , id => 0 } , 
{ title => "大阪" , id => 27 , place => ["心斎橋","梅田","関西"] } , 
{ title => "東京" , id => 13 , place => ["関東","首都圏"] } , 
{ title => "愛知" , id => 23 , place => ["名古屋","東海"] } , 

{ title => "北海道" , id => 1 } , 
{ title => "青森" , id => 2 } , 
{ title => "岩手" , id => 3 } , 
{ title => "宮城" , id => 4 } , 
{ title => "秋田" , id => 5 } , 
{ title => "山形" , id => 6 } , 
{ title => "福島" , id => 7 } , 
{ title => "茨城" , id => 8 } , 
{ title => "栃木" , id => 9 } , 
{ title => "群馬" , id => 10 } , 
{ title => "埼玉" , id => 11 } , 
{ title => "千葉" , id => 12 } , 
{ title => "神奈川" , id => 14 , place => ["横浜"] } , 
{ title => "新潟" , id => 15 } , 
{ title => "富山" , id => 16 } , 
{ title => "石川" , id => 17 } , 
{ title => "福井" , id => 18 } , 
{ title => "山梨" , id => 19 } , 
{ title => "長野" , id => 20 } , 
{ title => "岐阜" , id => 21 } , 
{ title => "静岡" , id => 22 } , 
{ title => "三重" , id => 24 } , 
{ title => "滋賀" , id => 25 } , 
{ title => "京都府" , id => 26 } , 
{ title => "兵庫" , id => 28 } , 
{ title => "奈良" , id => 29 } , 
{ title => "和歌山" , id => 30 } , 
{ title => "鳥取" , id => 31 } , 
{ title => "島根" , id => 32 } , 
{ title => "岡山" , id => 33 } , 
{ title => "広島" , id => 34 } , 
{ title => "山口" , id => 35 } , 
{ title => "徳島" , id => 36 } , 
{ title => "香川" , id => 37 } , 
{ title => "愛媛" , id => 38 } , 
{ title => "高知" , id => 39 } , 
{ title => "福岡" , id => 40 } , 
{ title => "佐賀" , id => 41 } , 
{ title => "長崎" , id => 42 } , 
{ title => "熊本" , id => 43 } , 
{ title => "大分" , id => 44 } , 
{ title => "宮崎" , id => 45 } , 
{ title => "鹿児島" , id => 46 } , 
{ title => "沖縄" , id => 47 } , 
{ title => "海外" , id => 48 });

@array;

}





#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub max_hit_selectbox{

my $self = shift;
my($print);
my $html = new Mebius::HTML
my $query = new Mebius::Query;
my $param  = $query->param();
my(@number);

$print .= qq(<select name="max_hit">);

	for my $count (1..100){
			if($count % 5 != 0 && $count !~ /^[1-5]$/){
				next;
			}
			my $selected = 1 if($param->{'max_hit'} eq $count);
		$print .= $html->tag("option","${count}件",{ value => $count , selected => $selected });
	}

$print .= qq(</select>);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub succeed_log{

my $self = shift;
my $action_log = new Mebius::Mixi::ActionLog;
$action_log->action_and_update_core("succeed",@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub finished_log{

my $self = shift;
my $action_log = new Mebius::Mixi::ActionLog;
$action_log->action_and_update_core("finished",@_);

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub failed_log{

my $self = shift;
my $action_log = new Mebius::Mixi::ActionLog;
$action_log->action_and_update_core("failed",@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub try_log{

my $self = shift;
my $action_log = new Mebius::Mixi::ActionLog;
$action_log->action_and_update_core("try",@_);

}


#-----------------------------------------------------------
# When mixi blocks account temporary , How long second wait? ()
#-----------------------------------------------------------
sub temporary_block_revety_time{
7*24*60*60;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_title{
"ミクコミ";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tremor_sleep{

my $self = shift;
my $second = shift;
my $console = new Mebius::Console;

$console->tremor_sleep($second);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sleep{

my $self = shift;
my $sleep_second = shift || die;
my $console = new Mebius::Console;

	if(!$self->sleep_mode_switch()){
		console "No sleep mode , be cauful.";
		return();
	}

$console->count_sleep($sleep_second);


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub input_sleep{

my $self = shift;
$self->tremor_sleep(30);


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub preview_sleep{

my $self = shift;
$self->tremor_sleep(10);


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub rest_sleep{

my $self = shift;
$self->tremor_sleep(5);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sleep_mode_switch{
1;
}




1;
