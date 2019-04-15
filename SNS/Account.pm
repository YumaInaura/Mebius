
use strict;
package Mebius::SNS::Account;
use Mebius::Base::DBI;
use base qw(Mebius::Encoding Mebius::Escape Mebius::Base::DBI);

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub my_frieds_on_hash{

my $self = shift;
my($my_account) = Mebius::my_account();
my(%friend);

	foreach my $account (split(/\s/,$my_account->{'friend_accounts'})){
		$friend{$account} = 1;
	}

\%friend;

}


#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new{
my $class = shift;
bless {} , $class;
}

#-----------------------------------------------------------
# メインのテーブル名
#-----------------------------------------------------------
sub main_table_name{
my $self = shift;
"account";
}

#-----------------------------------------------------------
# メインテーブルのカラム名
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;
my $column = {
account_key => { text => 1 , other_names => { key => } } ,
account => { PRIMARY => 1 , other_names => { id => } } ,
pass => { text => 1 } ,
salt => { text => 1 } ,
firsttime => { int => 1 } ,
blocktime => { int => 1 } ,
lasttime => { int => 1 } ,
adlasttime => { int => 1 } ,
concept => { text => 1 } ,
pass_crypt => { text => 1 } ,
salt_crypt => { text => 1 } ,
name => { text => 1 } ,
mtrip => { text => 1 } ,
color1 => { text => 1 } ,
color2 => { text => 1 } ,
prof => { text => 1 } ,
edittime => { int => 1 } ,
last_profile_edit_time => { int => 1 } ,
comment_font_color => { text => 1 } ,
ocomment => { text => 1 } ,
odiary => { text => 1 } ,
obbs => { text => 1 } ,
osdiary => { text => 1 } ,
osbbs => { text => 1 } ,
orireki => { text => 1 } ,
ohistory => { text => 1 } ,
okr => { text => 1 } ,
allow_vote => { text => 1 } ,
allow_message => { text => 1 } ,
allow_view_last_access => { text => 1 } ,
allow_crap_diary => { text => 1 } ,
use_bbs => { text => 1 } ,
encid => { text => 1 } ,
enctrip => { text => 1 } ,
level => { text => 1 } ,
level2 => { text => 1 } ,
surl => { text => 1 } ,
admin => { text => 1 } ,
chat => { text => 1 } ,
reason => { text => 1 } ,
last_locked_period => { text => 1 } ,
all_locked_period => { text => 1 } ,
alert_end_time => { int => 1 } ,
alert_count => { text => 1 } ,
alert_decide_time => { int => 1 } ,
email => { text => 1 } ,
mlpass => { text => 1 } ,
myurl => { text => 1 } ,
myurltitle => { text => 1 } ,
remain_email => { text => 1 } ,
birthday_concept => { text => 1 } ,
birthday_year => { text => 1 } ,
birthday_month => { text => 1 } ,
birthday_day => { text => 1 } ,
birthday_time => { int => 1 } ,
all_renew_count => { text => 1 } ,
account_locked_count => { text => 1 } ,
catch_mail_message => { text => 1 } ,
catch_mail_resdiary => { text => 1 } ,
catch_mail_comment => { text => 1 } ,
catch_mail_etc => { text => 1 } ,
first_email => { text => 1 } ,
first_host => { text => 1 } ,
first_agent => { text => 1 } ,
set_cookie_count => { text => 1 } ,
cookie_name => { text => 1 } ,
cookie_refresh_second => { text => 1 } ,
cookie_font_color => { text => 1 } ,
cookie_thread_up => { text => 1 } ,
cookie_gold => { text => 1 } ,
cookie_regist_all_length => { text => 1 } ,
cookie_regist_count => { text => 1 } ,
cookie_font_size => { text => 1 } ,
cookie_follow => { text => 1 } ,
cookie_last_view_thread => { text => 1 } ,
cookie_use_history => { text => 1 } ,
cookie_omit_text => { text => 1 } ,
cookie_bbs_news => { text => 1 } ,
cookie_age => { text => 1 } ,
cookie_email => { text => 1 } ,
cookie_secret => { text => 1 } ,
cookie_account_link => { text => 1 } ,
cookie_id_fillter => { text => 1 } ,
cookie_account_fillter => { text => 1 } ,
cookie_use_id_history => { text => 1 } ,
optionkey => { text => 1 } ,
last_action_time => { int => 1 } ,
addr => { text => 1 } ,
agent => { text => 1 } ,
cnumber => { text => 1 } ,
todaypresentgold => { text => 1 } ,
lastpresentgold => { text => 1 } ,
votepoint => { text => 1 } ,
todayvotepoint => { text => 1 } ,
lastvote => { text => 1 } ,
last_send_message_yearmonthday => { text => 1 } ,
today_send_message_num => { text => 1 } ,
unread_message_num => { text => 1 } ,
deny_count => { text => 1 } ,
denied_count => { text => 1 } ,
friend_num => { text => 1 } ,
last_access_time => { int => 1 } ,
last_access_addr => { text => 1 } ,
last_access_multi_user_agent => { text => 1 } ,
last_access_cookie_char => { text => 1 } ,
last_apply_friend_time => { int => 1 } ,
last_comment_time => { int => 1 } ,
next_diary_post_time => { int => 1 } ,
next_comment_time => { int => 1 } ,
penalty_time => { int => 1 } ,
account_char => { text => 1 , other_names => { char => } } ,
option_to_account_time => { int => 1 } ,
new_applied_num => { text => 1 } ,
last_applied_time => { int => 1 } ,
cookie_gold_old_server => { text => 1 } ,
cookie_regist_all_length_old_server => { text => 1 } ,
cookie_regist_count_old_server => { text => 1 } ,
cookie_gold_save_original => { text => 1 } ,
cookie_regist_all_length_save_original => { text => 1 } ,
cookie_regist_count_save_original => { text => 1 } ,

friend_accounts => { text => 1 } ,
deny_accounts => { text => 1 } ,


last_update_time => { int => 1 } ,

};

$column;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub add_handle_to_data_group{

my $self = shift;
my $data_group = shift;
my @group = @{$data_group};
my(@account_in,$account_name,@adjusted_data_group);

	foreach my $data (@group){
			if( my $account = $data->{'account'} ){
				push @account_in , $account;
			}
	}


	if(@account_in >= 1){
		$account_name = $self->fetchrow_on_hash_main_table([ ["account","IN",\@account_in] ],"account",{ Debug => 0 });
	} else {
		return([]);
	}

	foreach my $data (@group) {
		my %hash = %{$data};
			if( my $handle = $account_name->{$data->{'account'}}->{'name'}){
				$hash{'handle'} = $handle;
			}
		push @adjusted_data_group , \%hash;
	}

\@adjusted_data_group;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub account_group_to_name_group{

my $self = shift;
my $account_group = shift;
my($fetchrow);

my $data_group = $self->fetchrow_main_table({ account => [] });

}


#-----------------------------------------------------------
# メールアドレスの種類を確認
#-----------------------------------------------------------
sub kind_of_email_provider_view{

my $self = shift;
my $html = new Mebius::HTML;
my $print;
my $account_dbi = $self->fetchrow_main_table({ remain_email => ["IS NOT NULL"] });
my(%address,$all_email_address,$error_email_address);

	if(!Mebius->common_admin_judge()){
		Mebius->error("ページが存在しません。[A1]");
	}

my $title = "メールプロバイダの種類";

$print .= $html->tag("h1",$title);

	foreach my $data (@{$account_dbi}){

		my $email = lc $data->{'remain_email'};

			if($email =~ /\@([a-zA-Z0-9_\-\.]+?)(\.[A-Za-z]+)$/){

				my $provider = $1.$2;
				my $domain = $2;

					if($address{$domain}{$provider}){
						next;
					} else {
						$address{$domain}{$provider} = 1;
					}
			} else {
				$error_email_address .= $html->span($email,{ class => "red" });
			}

		$all_email_address .= $email;

	}

$print .= $html->tag("h2","ドメイン");
	foreach my $domain ( keys %address ){
		$print .= $html->tag("h3",$domain);

		$print .= qq(<ol>);
			foreach my $provider ( keys %{$address{$domain}} ){
				$print .= qq(<li>);
				$print .= $provider;
				$print .= qq(</li>);
			}
		$print .= qq(</ol>);

	}

	if($error_email_address){
		$print .= $html->tag("h2","エラー");
		$print .= $error_email_address;
	}

Mebius::Template::gzip_and_print_all({ source => "utf8" , Title => $title , BCL => [$title] },$print);


}

#-----------------------------------------------------------
# 全ての名前を覚えておく
#-----------------------------------------------------------
sub all_account_handle{

my $self = shift;
my(%handle);
my($my_account) = Mebius::my_account();

	#if(!$my_account->{'admin_flag'}){
		return();
	#}

# Near State （呼び出し） 2.30
my $HereName1 = "all_account_handle";
my $StateKey1 = "normal";
my($state) = Mebius::State::call_parmanent(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

my $account_dbi = $self->fetchrow_main_table({});

	foreach my $account_data ( @{$account_dbi} ){
		$handle{$account_data->{'account'}} = $account_data->{'name'};
	}

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::save_parmanent(__PACKAGE__,$HereName1,$StateKey1,\%handle); }

\%handle;

}





1;

