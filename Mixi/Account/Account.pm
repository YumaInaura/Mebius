
package Mebius::Mixi::Account;

use strict;

use Mebius::Mixi::Basic;
use Mebius::Mixi::Friend;
use Mebius::Mixi::Submit;
use Mebius::Mixi::Event;
use Mebius::Mixi::ActionLog;
use Mebius::Mixi::Account::View;
use Mebius::Mixi::Account;

use Mebius::HTML;
use Mebius::Query;
use Mebius::Export;
use Mebius::Time;
use Mebius::Move;
use Mebius::Crypt;
use Mebius::Proxy;
use Mebius::View;
use Mebius::Console;

use Mebius::Encoding;
use Mebius::Directory;
use Mebius::Move;

use HTTP::Cookies;
use File::Copy qw();
use CGI qw();

use List::Util qw();

use Mebius::Export;
use Mebius::LikePHP;

use base qw(
Mebius::Mixi::Account::Useful
Mebius::Mixi::Account::View
Mebius::Base::DBI
Mebius::Base::Data 
);


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
sub data{

my $self = shift;
my $email = shift;

my $account_data = $self->fetchrow_main_table({ email => $email })->[0];

return $account_data;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my $account_view = new Mebius::Mixi::Account::View;
my $query = new Mebius::Query;
my $param = $query->param();
my $basic = $self->basic_object();
my $mode = $param->{'mode'} || $ARGV[0];

	if($mode eq "submit_account" || $mode eq "account"){
		$account_view->self_view();
		1;
	} elsif($mode eq "submit_account_do"){
		$self->submit_accounts($param->{'max_hit'});
		1;
	} elsif($mode eq "all_accounts_profile_check" || $mode eq "profile_check"){
		$self->all_accounts_profile_check($param->{'max_hit'});
		1;
	} elsif($mode eq "edit_accounts"){
		$self->edit();
		1;
	} elsif($mode eq "set_our_proxies"){
		$self->set_our_proxies();
		1;
	} elsif($mode =~ /^adjust_account(s)?$/){
		$self->adjust_all_accounts();
		1;
	} elsif($mode eq "refresh_accounts" || $mode eq "refresh_accounts_from_mixi_data"){
		$self->refresh_accounts_from_mixi_data();
		1;
	} elsif($mode eq "put_proxy" || $mode eq "put_proxy_all_accounts"){
		$self->put_proxy_to_all_accounts();
		1;
	} elsif($mode eq "put_user_agent"){
		$self->put_user_agent();
		1;

	} elsif($mode eq "per_account_view"){
		$self->per_account_view();
		1;
	} elsif($mode eq "all_account_upload_pictures"){
		$self->all_account_upload_pictures($param->{'max_hit'});
		1;
	} elsif($mode eq "refresh_all_accounts_password"){
		$self->refresh_all_accounts_password($param->{'max_hit'});
		1;
	} elsif($mode eq "random_login"){
		$self->random_login_view();
		1;
	}	elsif($mode eq "make_good_profile" || $mode eq "all_accounts_make_good_profiles"){
		$self->all_accounts_make_good_profiles();
		1;
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"mixi_account";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $column = {
target => { PRIMARY => 1 } , 
email => { INDEX => 1 } , 
account => { INDEX => 1 } , 
password => { } , 
old_password => { } , 
temporary_password => { } , 

name => { } , 
nickname => {} ,

create_time => { int => 1 } ,
last_modified => { int => 1 } ,
account_type => {} , 
deleted_flag => { int => 1 } ,

last_login_time => { int => 1 } ,
last_login_check_time => { int => 1 } ,

last_action_time => { int => 1 , INDEX => 1 } ,
total_action_count => { int => 1 } ,

can_not_login_message => { } , 
status => { } , 
last_login_missed_time => { int => 1 , INDEX => 1 } ,
temporary_block_time => { int => 1 } ,

year => { int => 1 } ,
month => { int => 1 } ,	
day => { int => 1 } ,
location_pref => { int => 1 } ,
blood_type => { } ,
job => { int => 1 } ,
last_edit_profile_time => { int => 1 } ,
introduction => { text => 1 } ,
last_upload_picture_time => { int => 1 } ,
upload_picture_file_name => { } , 

last_profile_check_time => { int => 1 , INDEX => 1 } ,
denied_time => { int => 1 } , 

browser_user_agent => { text => 1 } ,
create_account_char => { } ,

friend_num => { int => 1 , INDEX => 1 } ,

proxy => {} ,
last_apply_friend_time => { int => 1 } , 
last_applied_friend_time => { int => 1 } , 
change_proxy_time => { int => 1 } , 

last_logout_time => { int => 1 } , 
last_failed_time => { int => 1 } , 
failed_count => { int => 1 } , 
post_key => { } , 
postkey => { } , 
lock_time => { int => 1 } ,

keep_job => { } , 
owner => { } , 
try_time => { int => 1 } , 
memo => { text => 1 } , 

};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub try{

my $self = shift;
my $account_data = shift || (warn("Account data is empty.") && return());

$self->update_main_table({ target => $account_data->{'target'} , try_time => time });


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub lock_or_sleep{

my $self = shift;
my $basic = $self->basic_object();
my($lock_left_time);

	for(1..10){

		$lock_left_time = $self->lock(@_);

			if($lock_left_time >= 1){
				$basic->sleep($lock_left_time+5);
			}
	}

$lock_left_time;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub lock{

my $self = shift;
my $email = shift || (warn && return 1 );
my($lock_flag);
my $basic = $self->basic_object();

my $data = my $data_exists = $self->fetchrow_main_table({ email => $email })->[0];

my $left_time = ($data->{'lock_time'} + 10*60) - time;

	if($left_time >= 1){
		$lock_flag = $left_time;
		$basic->try_log($email,"Account is be locking. $left_time second wait.");
	} else {
		$self->update_main_table_where({ lock_time => time },{ email => $email });
		$lock_flag = 0;
		console "Account is free.";
	}


$lock_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub unlock{

my $self = shift;
my $email = shift || (warn && return());

console "Account unlock : $email";
$self->update_main_table_where({ lock_time => 0 },{ email => $email });

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub per_account_view{

my $self = shift;
my $basic = $self->basic_object();
my $query = new Mebius::Query;
my $html = new Mebius::HTML;
my $submit_event = new Mebius::Mixi::Submit;
my $action_log = new Mebius::Mixi::ActionLog;
my $param  = $query->param();
my($print,%fetch);

	if($param->{'type'} eq "email"){
		$fetch{'email'} = $param->{'target'};
	}	elsif($param->{'type'} eq "proxy"){
		$fetch{'proxy'} = $param->{'target'};
	} else {
		$self->error("Please tell me target type.");
		exit;
	}

my $account_data_group = $self->fetchrow_main_table(\%fetch,{ Debug => 0 });
my @email = map { $_->{'email'}; } @{$account_data_group};

my $page_title = "アカウント情報";

$print .= $self->data_group_to_table($account_data_group,"アカウント",{ Password => $param->{'view_password'} });

$print .= $html->tag("h2","登録履歴");
my $submit_data_group = $submit_event->fetchrow_main_table({ email => ["IN",\@email] },{ Debug => 0 });

$print .= $html->tag("h2","アクションログ");
my $action_data_group = $action_log->fetchrow_main_table_desc({ email => ["IN",\@email] },"create_micro_time",{ Debug => 0 });
$print .= qq(<table>);
$print .= $action_log->data_group_to_list($action_data_group);
$print .= qq(</table>);

$print .= $submit_event->data_group_to_list($submit_data_group);

$basic->print_html($print,{ Title => $page_title , h1 => $page_title });

exit;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_accounts_profile_check{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();
my $basic = $self->basic_object();
my $move = new Mebius::Move;
my($hit,$print,$checker_account_data,$data_group);

my $ok = 0;
my $denied = 0;

my $border_second = 1*24*60*60;
#my $max_hit = $param->{'max_hit'} || $ARGV[1] || 10000;
my $checker_email = $ARGV[2];

	if($checker_email){
		$checker_account_data = $self->fetchrow_main_table({ email => $checker_email })->[0] || die("No checker account find in $checker_email");
	} else{
		$checker_account_data = $self->forview_account_data() || die("No checker account found.");
	}


$data_group = $self->fetchrow_main_table_asc({ account => ["IS","NOT NULL"] , last_action_time => [">=",1] , status => ["IS","NULL"] , account_type => "limited" , last_profile_check_time => ["<=",time-$border_second] },"last_profile_check_time"); #account_type => "limited"
my $num = @{$data_group};

console "Checker is $checker_account_data->{'email'}.";
console "$num ACCOUNTS PROFILE CHECK.";
#console "Max roop $max_hit roop will do.";

$basic->sleep(3);

	foreach my $data (@{$data_group}){

		my($new_status,$denied_time);

			if(time < $data->{'last_profile_check_time'}+$border_second || $data->{'status'}){ # || $data->{'account_type'} eq "special"
				console "Skip. Profile check time is lately.";
				next;
			} elsif(!$data->{'account'}){
				console "Skip, Account num is empty.";
				next;
			}

			if($hit >= 1){
				console "DONE";
				exit;
				#$basic->tremor_sleep(30);
			}

		console "check $data->{'account'}";

		$hit++;

		my $profile_url = $basic->profile_url($data->{'account'});
		my $profile_html = $basic->get($profile_url,$checker_account_data->{'email'});

			if($profile_html eq ""){
				$basic->failed_log($data->{'email'},"Can't get profile HTML.");
				next;
			} elsif($profile_html =~ /<p class="messageAlert">申し訳ございませんが、該当のユーザーページにアクセスできません。/){

				$denied++;
				$basic->failed_log($data->{'email'},"$data->{'account'} is denied.",$profile_html);

				$new_status = "deny";
				$denied_time = time;

			} elsif($profile_html =~ /<p class="messageAlert">ユーザは既に退会したか、存在しないユーザIDです。/){

				$denied++;
				$basic->failed_log($data->{'email'},"$data->{'account'} is canceld account.",$profile_html);

				$new_status = "cancel";
				$denied_time = time;

			} else {

				$ok++;
				$self->profile_html_to_update_account($profile_html,$data);
				$basic->succeed_log($data->{'email'},"Account $data->{'account'} is alive.",$profile_html);

			}

		console "ok $ok / denied $denied";

		$self->update_main_table({ target => $data->{'target'} , last_profile_check_time => time , status => $new_status , denied_time => $denied_time });

	}

	if(console){
		console "Roop was end.";
		exit;
	}

$basic->print_html($print);
exit;

$move->redirect_to_self_url();
exit;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub profile_html_to_update_account{

my $self = shift;
my $html = shift || (warn && return());
my $data = shift || (warn && return());
my(%update);

	if($html =~ m! href="http://mixi\.jp/show_(?:friend|profile)\.pl\?id=([0-9]+)">([^<>]+?)さん\(([0-9]+)\)</a>!){

		$update{'target'} = $data->{'target'};

		$update{'account'} = $1;
		console "account is $1";

		$update{'nickname'} = $2;
		console "nickname is $2";

		$update{'friend_num'} = $3;
		console "friend num is $3";

			if($update{'account'}){
				$self->update_main_table(\%update);
			}

	} else {
		console "Can't sampling profile data.";
	}


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_account_upload_pictures{

my $self = shift;
my $max_hit = shift || 10;
my $move = new Mebius::Move;
my $query = new Mebius::Query;
my $param  = $query->param();
my($hit);

my $data_group = $self->fetchrow_main_table({ last_upload_picture_time => 0  });

	foreach my $data (@{$data_group}){

			if(!$self->data_to_upload_picture_judge($data)){
				next;
			}

		$hit++;
			if($hit > $max_hit){ last; }
		$self->upload_picture($data);
	}

$move->redirect_to_self_url();

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub upload_picture{

my $self = shift;
my $account_data = shift || return();
my $email = $account_data->{'email'} || return();
my $basic = $self->basic_object();
my $encoding = new Mebius::Encoding;
my(%input,$success_flag,$image_data,$hit_handle,$succeed_flag);

$basic->try_log($email,"Try to edit profile for $email.");

#http://img.mixi.net/img/basic/common/noimage_member180.gif

my $form_url = "http://mixi.jp/list_self_profile_image.pl";
my $form_html = $basic->get($form_url,$email);

	if($form_html =~ m!プロフィール写真!){
		$basic->succeed_log($email,"View page for upload picture",$form_html);
	} else {
		$basic->failed_log($email,"Can not view page for upload picture",$form_html);
		return();
	}

$basic->input_sleep();

my $image_file_name = $self->upload_file_random() || die;
my $image_file_path = $self->upload_picture_directory() . $image_file_name;

$input{'mode'} = "upload";
$input{'level'} = 2;
$input{'post_key'} = $basic->html_to_post_key($form_html,$email) || return();
$input{'image'} = [$image_file_path];

my $submited_html1 = $basic->post($form_url,$email,\%input,{ referer => $form_url } );

$basic->preview_sleep();

my %input_for_friend = %input;
$input_for_friend{'level'} = 1;
my $submited_html2 = $basic->post($form_url,$email,\%input_for_friend,{ referer => $form_url });

	if($submited_html2 =~ m!<title>302 Found</title>! && $submited_html2 =~ m!<a href="list_self_profile_image.pl">here</a>!){

		$succeed_flag = 1;
		$self->update_main_table({ target => $account_data->{'target'} , upload_picture_file_name => $image_file_name , last_upload_picture_time => time });
		$basic->finished_log($email,"Uploaded picture.",$submited_html2);

	} else {

		$succeed_flag = 0;
		$basic->failed_log($email,"Can not upload picture.",$submited_html2);
		return();

	}

my $moved_url = $form_url;
my $moved_html = $basic->get($moved_url,$email);


	if($moved_html){
		$basic->succeed_log($email,"Moved after upload picture.",$moved_html,$moved_url);
	} else {
		$basic->failed_log($email,"Can not move after upload picture.",$moved_html,$moved_url);
		return();
	}

$basic->rest_sleep();

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_upload_picture_judge{

my $self = shift;
my $data = shift || return();
my($flag);

	if(!$data->{'last_upload_picture_time'}){
		$flag = 1;
	}

$flag;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub upload_file_random{

my $self = shift;
my($file);

my $directory = $self->upload_picture_directory();
my @directory = Mebius::Directory::get_directory($directory);

my $file = $directory[int rand(@directory)];

$file;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub upload_picture_directory{

my $self = shift;
my($directory);

	if(Mebius::alocal_judge()){
		$directory = "C:/Apache2.2/cgi-bin/navi-tomo/upload_picture/";
	} else {
		$directory = "/perl/mixi/upload_picture/";
	}

$directory;

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
sub action{

my $self = shift;
return $self->account_data_to_one_action_plus(@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub one_action_plus{

my $self = shift;
return $self->account_data_to_one_action_plus(@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub account_data_to_one_action_plus{

my $self = shift;
my $account_data_or_email = shift || die;
my $free_update = shift || {};
my($account_data);

	if(ref $account_data_or_email eq "HASH"){
		$account_data = $account_data_or_email;
	} else {
		$account_data = $self->data($account_data_or_email);
	}

my %update = (( target => $account_data->{'target'} , last_action_time => time , total_action_count => ["+",1]),%{$free_update});

$self->update_main_table(\%update);

}





#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub random_login_view{

my $self = shift;
my $basic = $self->basic_object();
my $query = new Mebius::Query;
my $param  = $query->param();
my($print,$account_data);

my $email = my $email = $param->{'email'} || $ARGV[1];

	if( $email ){
		$account_data = $self->fetchrow_main_table({ email => $email })->[0];
	} else {
		$account_data = $basic->random_limited_account_data();
	}

#my $html = $basic->get("http://mixi.jp/",$account_data->{'email'});
my $html = $basic->get("http://mixi.jp/list_self_profile_image.pl",$account_data->{'email'});

$print .= e($account_data->{'email'});
$print .= $html;

my $basic = $basic->print_html($print);

exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_account_data_group{

my $self = shift;
my $all_of_text = shift || return();
my $query = new Mebius::Query;
my $email_object = new Mebius::Email;
my $param  = $query->param();
my(@account);


my @text = split(/\n|\r/,$all_of_text);

	foreach my $text (@text){

		my($email,$password,$birthday,$account_number,$nickname) = split(/[\t\s]+/,$text);

			#if(!$email){ next; }
			#if(!$password){ next; }
			if($email eq '-'){
				$email = '';
			}

			if($birthday eq '-'){
				$birthday = '';
			}

		my($year,$month,$day) = split(/\//,$birthday);

			if($password eq '-'){
				$password = '';
			}

			if($account_number eq '-'){
				$account_number = '';
			}

			if($email && $email_object->format_error($email)){ warn("$email is is invalid for email."); next; }

		push @account , { email => $email , password => $password , account => $account_number , nickname => $nickname , year => $year , month => $month , day => $day };
	}


#my $num = @account;

@account;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_accounts{

my $self = shift;
#my $text = shift || return();
#my $account_type = shift || die;
my $email = new Mebius::Email;
my $move = new Mebius::Move;
my $basic = $self->basic_object();
my $query = new Mebius::Query;
my $param  = $query->param();

my $text = $param->{'text'} || die;
my $account_type = $param->{'account_type'} || die;

my @account = $self->text_to_account_data_group($text);
my $data_group_hash = $self->fetchrow_on_hash_main_table({},"email");

	foreach my $data (@account){

		#my %update = %{$data};

		my(%update);

		my $email = $data->{'email'};
		my $password = $data->{'password'};

			if($data->{'email'}){
				$update{'email'} = $data->{'email'};
			}

		my $account_data = my $account_data_exists = $self->fetchrow_main_table({ email => $data->{'email'} })->[0];
			if($data->{'account'}){
				$update{'account'} = $data->{'account'};
			}

			if($data->{'password'}){
				$update{'password'} = $data->{'password'};
				$update{'old_password'} = "$account_data->{'password'},$account_data->{'old_password'}";
			}

			if($data->{'nickname'}){
				$update{'nickname'} = $data->{'nickname'};
			}

			if($data->{'year'} && $data->{'month'} && $data->{'day'}){
				$update{'year'} = $data->{'year'};
				$update{'month'} = $data->{'month'};
				$update{'day'} = $data->{'day'};
			}

			if($account_type =~ /^([0-9a-zA-Z]+)$/){
				$update{'account_type'} = $account_type;
			} else {
				die("Please relay account_type");
			}

			if($param->{'owner'} =~ /^([0-9a-zA-Z]+)$/){
				$update{'owner'} = $param->{'owner'};
			}

		$update{'last_modified'} = time;

			# DO NOT OVERWRITE PASSWORD
			# Because maybe password in mixi and pasword in local DBI are deferent
			if($account_data_exists){
				$update{'target'} = $account_data->{'target'};
				#$self->update_main_table(\%update);
			} else {
				$update{'target'} = $self->new_target();
				$self->insert_main_table(\%update);
			}

	}

$move->redirect_to_self_url();

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_button{

my $self = shift;
my $mode = shift || die;
my $submit_value = shift || die;
my $use = shift || {};
my $basic = $self->basic_object();

my($print);
my $html = new Mebius::HTML;

$print .= qq(<form action="" enctype="multipart/form-data" method="post" style="margin:1em 0em;">);
$print .= $html->input("hidden","mode",$mode);
$print .= $html->input("submit","",$submit_value);

$print .= $basic->max_hit_selectbox();

$print .= qq(</form>);
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub refresh_accounts_from_mixi_data{

my $self = shift;
my $move = new Mebius::Move;
my $query = new Mebius::Query;
my $param  = $query->param();

$self->refresh_accounts_from_mixi_data_do($param->{'max_hit'});

$move->redirect_to_self_url();

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub refresh_accounts_from_mixi_data_do{

my $self = shift;
my $max_hit = shift || 100;
my $basic = $self->basic_object();
my $console = new Mebius::Console;
my($hit,$data_group);

console "REFRESH ACCOUNTS FROM MIXI";
console "$max_hit round will do.";

	if($console->option("-all")){
		console "Option : All accounts check.";
		 $data_group = $self->fetchrow_main_table_asc({ status => ["IS","NULL"] , account => ["IS","NULL"]  },"last_login_missed_time");
	} else {
		console "Limited accounts check. [ or use option '-all' ? ]";
		 $data_group = $self->fetchrow_main_table_asc({ status => ["IS","NULL"] , account => ["IS","NULL"] , last_login_missed_time => ["<",time-24*60*60] },"last_login_missed_time");
	}

my $data_num = @{$data_group};


console "$data_num accounts try.";

	if($data_num){
		$basic->sleep(3);		
	}



my $mixi_profile_edit_url = "http://mixi.jp/edit_profile.pl";

	foreach my $data (@{$data_group}){

		my(%update);

		$hit++;

			if($hit >= $max_hit){
				last;
			} elsif($hit >= 2){
				$basic->sleep(5*60);
			}

		$basic->try_log($data->{'email'},"Check $data->{'email'}.");

		my $html = $basic->get($mixi_profile_edit_url,$data->{'email'});

		my $update = $self->html_to_account_data($html);
	
			if($update->{'account'}){
				$self->update_main_table($update,{ WHERE => { target => $data->{'target'} } });
				$basic->finished_log($data->{'email'},"Account data get for $data->{'email'}.",$html);

			} else {
				$basic->failed_log($data->{'email'},"Can not get account data for $data->{'email'}.",$html);

			}




	}


console "FINISHED - REFRESH ACCOUNTS FROM MIXI";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub html_to_account_data{

my $self = shift;
my $html = shift;
my(%data);

	if($html =~ /"login_member_id":"([0-9]+)"/){
		$data{'account'} = $1;
	}

	if($html =~ /value="([^"]+)" name="nickname"/){
		$data{'nickname'} = $data{'name'} = $1;
	}

	if($html =~ m! value="([^"]+?)" name="first_name"!){
		$data{'first_name'} = $1;
	}

	if($html =~ m! value="([^"]+?)" name="last_name"!){
		$data{'last_name'} = $1;
	}

	if($html =~ m!<select name="year">(?:.+?)<option value="([0-9]{4})" selected="selected">!s){
		$data{'year'} = $1;
	}

	if($html =~ m!<select name="month">(?:.+?)<option value="([0-9]{1,2})" selected="selected">!s){
		$data{'month'} = $1;
	}

	if($html =~ m!<select name="day">(?:.+?)<option value="([0-9]{1,2})" selected="selected">!s){
		$data{'day'} = $1;
	}

	if($html =~ m! name="location_pref"(?:.+?)<option value="([0-9]{1,2})" selected="selected">!s){
		$data{'location_pref'} = $1;
	}


#<select name="day">
#<option value="6" selected="selected">6</option>

#<select name="year">
#<option value="1987" selected="selected">1987</option>

#location_pref
#<option value="13" selected="selected">東京都</option>

\%data;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub login_form{

my $self = shift;
my $data = shift || return();
my $html = new Mebius::HTML;
my($print);

$print .= qq(<form action="https://mixi.jp/login.pl?from=login1" method="post" name="login_form" target="_blank">);

$print .= $html->input("hidden","next_url","/home.pl");
$print .= $html->input("hidden","post_key","");
$print .= $html->input("hidden","email",$data->{'email'});
$print .= $html->input("hidden","password",$data->{'password'});

#<input type="checkbox" checked="checked" id="auto" name="sticky" tabindex="3" />
$print .= $html->input("submit","","ログインする");
$print .= qq(</form>);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_password_list{

my $self = shift;
my $data = shift;
my $use = shift || {};
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my($print);

$print .= qq(<tr>);

$print .= qq(<td>);
$print .= e($use->{'hit'}+1);
$print .= qq(</td>);

$print .= qq(<td>);
$print .= e($data->{'account'});
$print .= qq(</td>);

$print .= qq(<td>);
$print .= e($data->{'password'});
$print .= qq(</td>);


$print .= qq(</tr>);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub table_th{

my $self = shift;
my $th = qq(<tr style="text-align:left;">
<th>No</th>
<th>mixi ID</th>
<th>名前</th>
<th>誕生日</th>
<th>メールアドレス</th>
<th>前回のアクション</th>
<th>アクション回数</th>
<th>プロクシ</th>
<th>マイミク</th>
<th>ログイン</th>

<th>星</th>
<th>B</th>

<th>プロフチェック</th>
<th>作成</th>
<th>ログイン失敗</th>
<th>状態</th>
<th></th>
<th></th>
<th>所有</th>
</tr>);

$th
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub refresh_all_accounts_password{

my $self = shift;
my $max_hit = shift || 10;
my $data_group = $self->fetchrow_main_table();
my $move = new Mebius::Move;
my($hit);

	foreach my $data (@{$data_group}){

			if($self->data_to_change_password_judge($data)){
				$hit++;
				$self->change_password($data->{'email'});
			}

			if($hit >= $max_hit){
				last;
			}

	}

$move->redirect_to_self_url();

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub change_password{

my $self = shift;
my $email = shift || return();
my $basic = $self->basic_object();
my $crypt = new Mebius::Crypt;
my(%input,%input_for_submit,%input_for_last_confirm,$flag,$http_or_https);

my $account_data = $self->fetchrow_main_table({ email => $email })->[0];
my $email = $account_data->{'email'};

	#if($basic->lock($email)){
	#	return();
	#}

$basic->try_log($email,"TRY TO CHANGE PASSWORD FOR $email.");

	#if($basic->ssl_broken_mode()){
	#	$http_or_https = "http";
	#} else {
		$http_or_https = "https";
	#}

my $url = "$http_or_https://mixi.jp/edit_account.pl?basic";
my $form_html = $basic->get($url,$email);

	if($form_html =~ m!セキュリティ保持のため!){
		$basic->succeed_log($email,"View first form for change password. $url ",$form_html);
	} else {
		$basic->failed_log($email,"Can not view first form for change password. $url ",$form_html);
		$self->unlock($email);
		return();
	}

#$basic->try_log($email,"View change password form",$form_html);

$basic->rest_sleep();

$input{'block_password'} = $account_data->{'password'};
$input{'mode'} = "basic_main";
$input{'post_key'} = $basic->html_to_post_key($form_html,$email) || return();
my $confirm_html = $basic->post($url,$email,\%input,{ referer => $url });

$basic->try_log($email,"Confirm submit.",$confirm_html);

#my $url_for_last_confirm = "$http_or_https://mixi.jp/edit_account.pl";
my $url_for_last_confirm = "$http_or_https://mixi.jp/verify_password.pl?s="; #5db7bf09188a66c06adb2a5dd01d0b6a
$input_for_last_confirm{'mode'} = "basic_other_confirm";
$input_for_last_confirm{'post_key'} = $basic->html_to_post_key($confirm_html,$email) || (warn("") && return());
$input_for_last_confirm{'token'} = $basic->html_to_token($confirm_html) || (warn("") && return());
$input_for_last_confirm{'current_email'} = $email;
$input_for_last_confirm{'current_mobile_email'} = "";
$input_for_last_confirm{'mobile_address'} = "";
$input_for_last_confirm{'mobile_domain'} = "0";
$input_for_last_confirm{'email'} = $email;

my $new_password = $input_for_last_confirm{'password1'} = $input_for_last_confirm{'password2'} = $crypt->char(10) || die;

$basic->input_sleep();

my $last_confirm_html = $basic->post($url_for_last_confirm,$email,\%input_for_last_confirm,{ referer => $url } );

$basic->try_log($email,"Last confirm.",$last_confirm_html);

#$input_for_submit{'post_key'} = $basic->html_to_post_key($last_confirm_html,$email) || return();
#$input_for_submit{'token'} = $basic->html_to_token($last_confirm_html) || return();

$input_for_submit{'mode'} = "basic_other_commit";
$input_for_submit{'post_key'} = $basic->html_to_post_key($last_confirm_html,$email) || return();
$input_for_submit{'token'} = $basic->html_to_token($last_confirm_html) || return();
$input_for_submit{'email'} = $email;
$input_for_submit{'mobile_email'} = "";
$input_for_submit{'password1'} = $new_password;
$input_for_submit{'password2'} = $new_password;

$basic->preview_sleep();

$self->update_main_table({ target => $account_data->{'target'} , temporary_password => $new_password });

my $url_for_submit = "$http_or_https://mixi.jp/edit_account.pl";
my $submited_html = $basic->post($url_for_submit,$email,\%input_for_submit,{ referer => $url_for_last_confirm } );

	if($submited_html =~ /設定(変更)?が完了しました/){

		$self->update_main_table({ target => $account_data->{'target'} , old_password =>  "$account_data->{'password'},$account_data->{'old_password'}" , password => $new_password });
		$basic->finished_log($email,"Changed password for $email.",$submited_html);
		$flag = 1;

	} else {

		$basic->failed_log($email,"Can not change password for $email.",$submited_html);
		#$self->unlock($email);
		return();
	}

#$self->unlock($email);
$basic->rest_sleep();

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_change_password_judge{

my $self = shift;
my $data = shift || return();
my($flag);

	if($data->{'password'} =~ /^aaaa1111$/){
		$flag = 1;
	} elsif($data->{'old_password'} eq ""){
		$flag = 1;
	}

$flag;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_all_accounts{

my $self = shift;
my $max_hit = shift || 10;
my $move = new Mebius::Move;
my $task = new Mebius::Mixi::Task;
my $console = new Mebius::Console;
my($hit,@email,$data_group);

	if(!$task->allow_task_judge("adjust_account")){
		return();
	}

my $task_interval_time = 10*60;

console || die;

	# 
	if($console->option('-reserve_accounts')){
		$data_group = $self->fetchrow_main_table({ account_type => "limited" , status => ["IS","NULL"] , nickname => ["IS","NULL"] });
	} else {
		$data_group = $self->fetchrow_main_table_asc({ account_type => ["<>","special"] , last_failed_time => ["<",time-1*24*60*60] , last_login_missed_time => ["<",time-7*24*60*60] , status => ["IS","NULL"] },"try_time",{ Debug => 0 });
	}
 
	foreach my $data (@{$data_group}){

		my $hit_flag = $self->adjust_account($data);

			if($hit_flag){

				push @email , $data->{'email'};

				$task->submit_next_time_tremor("adjust_account",$task_interval_time);
				last;

			}
	}


$task->unlock("adjust_account");


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_account{

my $self = shift;
my $data = shift || (warn && return());
my $task = new Mebius::Mixi::Task;
my $basic = $self->basic_object();
my $mixi_account = new Mebius::Mixi::Account;
my($some_hit_flag);

console || die;

my $email = $data->{'email'} || die;

	if($self->lock($email)){
		return();
	}

	#if($self->data_to_change_password_judge($data)){
	#	$mixi_account->try($data);
	#	my $hit_flag = $self->change_password($data->{'email'});
	#		if($hit_flag){
	#			console "[CHANGED PASSWORD]";
	#			$some_hit_flag = 1;
	#		}
	#}

	if($self->data_to_upload_picture_judge($data)){

		$mixi_account->try($data);

		my $hit_flag = $self->upload_picture($data);
			if($hit_flag){
				console "[UPLOADED PICTURE]";
				$some_hit_flag = 1;
			}
	}

	if($self->data_to_edit_profile_judge($data)){

		$mixi_account->try($data);

		my $hit_flag = $self->edit_profile($data);
			if($hit_flag){
				console "[EDITED PROFILE]";
				$some_hit_flag = 1;
			}
	}

	if($some_hit_flag){
		$basic->logout($data->{'email'});
	}

$self->unlock($email);

$some_hit_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_edit_profile_judge{

my $self = shift;
my $data = shift || return();
my($flag);

	if($self->bad_name_judge($data->{'nickname'})){
		$flag = 1;
	}

$flag

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit{

my $self = shift;
my $query = new Mebius::Query;
my $move = new Mebius::Move;
my $mixi_account = new Mebius::Mixi::Account;

my $account_data_on_target = $self->fetchrow_on_hash_main_table($mixi_account,'target');

my $param  = $query->param();

	foreach my $key ( keys %{$param} ){

		my(%update);
		my $value = $param->{$key};

			if($key =~ /^mixi_account_status_([0-9a-zA-Z]+)$/){
				$update{'target'} = $1;

					if($value =~ /^(empty|deny)$/){
						$update{'status'} = $value;
					}

			} elsif($key =~ /^mixi_account_account_type_([0-9a-zA-Z]+)$/){
				$update{'target'} = $1;

					if($value =~ /^([0-9a-zA-Z]+)$/){
						$update{'account_type'} = $value;
					}
			} elsif($key =~ /^mixi_account_account_([0-9a-zA-Z]+)$/){
				$update{'target'} = $1;

					if($value =~ /^([0-9a-zA-Z]+)$/){
						$update{'account'} = $value;
					}

			} elsif($key =~ /^mixi_account_nickname_([0-9a-zA-Z]+)$/){
				$update{'target'} = $1;
				$update{'nickname'} = $value;

			# 最終アクション時間を更新する
			} elsif($key =~ /^mixi_account_last_action_time_refresh_([0-9a-zA-Z]+)$/){
				$update{'target'} = $1;
				$update{'last_action_time'} = time;
			} 


			if(%update){
				my $account_data = $account_data_on_target->{$update{'target'}};
				$self->eq_or_update($account_data,\%update,undef,['create_time']);
			}

	}

$move->redirect_to_self_url();

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_accounts_make_good_profiles{

my $self = shift;
my $basic = $self->basic_object();
my $move = new Mebius::Move;
my($print,$hit,@use_data_group,@name);

my $data_group = $self->fetchrow_main_table({ status => ["IS","NULL"] , nickname => ["IS","NOT NULL"] });
#last_edit_profile_time => "0"

	foreach my $data (@{$data_group}){

			if($self->data_to_edit_profile_judge($data)){
				push @use_data_group , $data;
				push @name , $data->{'nickname'};
			} else {
				next;
			}

	}

my $num = @use_data_group;

console("ALL ACCOUNTS MAKE GOOD PROFILE");
console("$num ACCOUNTS CHECK.");
console("They are ... @name");

$basic->sleep(3);

	foreach my $data (@use_data_group){

		$hit++;
			#if($hit > 10){
			#	last;
			#}
		$self->edit_profile($data);
	}

console_exit;

$move->redirect_to_self_url();

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_profile{

my $self = shift;
my $data = shift || (warn && return());
my $basic = $self->basic_object();
my($succeed_flag,$acocunt_id);

my $email = $data->{'email'} || (warn && return());
my $account_data = $self->fetchrow_main_table({ email => $email })->[0];

$basic->try_log($email,"Make good profile for $email.");

my $edit_page_url = "http://mixi.jp/edit_profile.pl";
my $edit_page_html = $basic->get($edit_page_url,$email);

$basic->try_log($email,"Access to edit setting page.",$edit_page_html);

my $html_data = $self->edit_page_html_to_data($edit_page_html);

#my $hash_print = Mebius::Debug::print_hash_core($html_data);

my %input_data = %{$html_data};
my %input = (%input_data,(
mode => "main" , 
hometown_change => "",
job_details => "" , 

job_level => "4" , 
job_details_level => "4" , 
hometown_level => "4" , 

location_change => "",

hometown_pref => "0" , 
hometown_area => "0" , 
location_area => "0" , 

job => "0" , 
fav1 => "" , 
fav2 => "" , 
fav3 => "" , 
fav1_value => "" , 
fav2_value => "" , 
fav3_value => "" ));

my $make_good_input_for_preview = $self->make_good_profile_data(\%input);

$basic->input_sleep();

my $preview_url = $edit_page_url;
my $preview_html = $basic->post($preview_url,$email,$make_good_input_for_preview,{ referer => $edit_page_url } );

my %input_for_submit = %{$make_good_input_for_preview};
$input_for_submit{'post_key'} = $basic->html_to_post_key($preview_html,$email);
$input_for_submit{'mode'} = "confirm";

	if($input_for_submit{'post_key'}){
		$basic->succeed_log($email,"Got post key for edit profile.",$preview_html);
	} else{
		$basic->failed_log($email,"Can not get post key for edit profile.",$preview_html);
		return();
	}

$basic->preview_sleep();

my $make_good_input_for_submit = $self->make_good_profile_data(\%input_for_submit);

my $submited_html = $basic->post($edit_page_url,$email,$make_good_input_for_submit,{ referer => $edit_page_url });

	if($submited_html =~ m!<title>302 Found</title>! && $submited_html =~ m!The document has moved <a href="show_profile\.pl\?id=([0-9]+)">here</a>!){
		$acocunt_id = $1;
		$basic->finished_log($email,"Edited profile.",$submited_html);

		my %update = (%{$html_data},%{$make_good_input_for_submit},( last_edit_profile_time => time ));
		$self->update_main_table(\%update,{ WHERE => { target => $account_data->{'target'} } });

	} else {

		$basic->failed_log($email,"Can not edit profile.",$submited_html);
		return();
	}

my $moved_url = "http://mixi.jp/show_friend.pl?id=$acocunt_id";
my $moved_html = $basic->get($moved_url,$email,{ referer => $edit_page_url });

	if($moved_html){

		$basic->succeed_log($email,"Page redirect succeed.",$moved_html);
		$succeed_flag = 1;

	} else {

		$basic->failed_log($email,"Can not redirect page.",$moved_html);
		return();
	}


$basic->rest_sleep();

$succeed_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub make_good_profile_data{

my $self = shift;
my $relay_data = shift || die;


my $make_good_default = $self->make_good_profile_common_default($relay_data);
my %data = %{$make_good_default};

	if($data{'introduction'} eq ""){
		$data{'introduction'} = "　";
	}

	if(!$data{'job'}){
		my @job = qw(2 4 6 7);
		$data{'job'} = $job[rand int(@job)];
	}

	if(!$data{'blood_type'}){
		my @blood_type = qw(a b o ab);
		$data{'blood_type'} = $blood_type[rand int(@blood_type)];
	}

$data{'hobby'} ||= int rand(24) + 1;

\%data;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub make_good_profile_common_default{

my $self = shift;
my $relay_data = shift || {};
my $basic = $self->basic_object();
my(@year,@month,@day);

my %data = %{$relay_data};

my @first_name = $self->lady_first_names();
my @last_name = $self->popular_last_names();
my $random_first_name = $first_name[rand int(@first_name)];
my $random_last_name = $last_name[rand int(@last_name)];

	if($self->bad_name_judge($data{'nickname'})){
		$data{'nickname'} = $random_first_name;
	}

	if($self->bad_name_judge($data{'first_name'})){
		$data{'first_name'} = $data{'nickname'};
	}

	if($self->bad_name_judge($data{'last_name'})){
		$data{'last_name'} = $random_last_name;
	}


$data{'sex'} ||= "f";
$data{'name_level'} ||= "3";
$data{'sex_level'} ||= "4";
$data{'location_level'} ||= "2";
$data{'age_level'} ||= "4";
$data{'birthday_level'} ||= "4";


#my @location = $basic->todoufuken();
#$data{'location_pref'} ||= $location[int rand(@location)]->{'id'};

	if(!$data{'location_pref'}){
		$data{'location_pref'} = 27;

		#my @area = qw(27102 27201 27202 27203 27204 27205 27206 27207 27208 27209 27210 27211 27212 27213 27214 27215 27216 27217 27218 27219 27220 27221 27222 27223 27224 27225 27226 27227 27228 27229 27230 27231 27232 27301 27321 27341 27361 27381);

		#$data{'locationArea'} = $area[int rand(@area)];

	}

	for(1990..1999){ push @year , $_; }
$data{'year'} ||= $year[int rand(@year)];

	for(1..12){ push @month , $_; }
$data{'month'} ||= $month[int rand(@month)];

	for(1..29){ push @day , $_; }
$data{'day'} ||= $day[int rand(@day)];

\%data;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub bad_name_judge{

my $self = shift;
my $name = shift;
my($bad_flag);

	if($name eq "" || $name =~ /^[0-9a-zA-Z\s　]+$/ || $name =~ /^(あ)+$/){
		$bad_flag = 1;
	}

$bad_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_page_html_to_data{

my $self = shift;
my $html = shift;
my(%data,@hobby);

	if($html =~ /"login_member_id":"([0-9]+)"/){
		$data{'account'} = $1;
	}

	if($html =~ /value="([^"]+)" name="nickname"/){
		$data{'name'} = $data{'nickname'} = $1;
	}

	if($html =~ m! value="([^"]+?)" name="first_name"!){
		$data{'first_name'} = $1;
	}

	if($html =~ m! value="([^"]+?)" name="last_name"!){
		$data{'last_name'} = $1;
	}

	if($html =~ m!<option value="(o)" selected="selected">!s){
		$data{'blood_type'} = $1;
	}

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($data{'blood_type'} $html)); }


	if($html =~ m!<select name="job">(?:.+?)<option value="([0-9]+)" selected="selected">!s){
		$data{'job'} = $1;
	}

	if($html =~ m!<select name="year">(?:.+?)<option value="([0-9]{4})" selected="selected">!s){
		$data{'year'} = $1;
	}

	if($html =~ m!<select name="month">(?:.+?)<option value="([0-9]{1,2})" selected="selected">!s){
		$data{'month'} = $1;
	}

	if($html =~ m!<select name="day">(?:.+?)<option value="([0-9]{1,2})" selected="selected">!s){
		$data{'day'} = $1;
	}

	if($html =~ m! name="location_pref"(?:.+?)<option value="([0-9]{1,2})" selected="selected">!s){
		$data{'location_pref'} = $1;
	}

	if($html =~ m!<textarea(?:.+?)>([^<>]+)</textarea>!s){
		$data{'introduction'} = $1;
	}

my $html_copy = $html;

	while($html_copy =~ s!<input type="checkbox" name="hobby" id="hobby(?:[0-9]+)" value="([0-9]+)" checked="checked"!!s){
		push @hobby , $1;
	}

	if(@hobby){
		$data{'hobby'} = $hobby[0];
	}

#$data{'hobby'} = join "" , @hobby;	
#$data{'hobby'} = \@hobby;	

\%data;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub confirm_new_account{

my $self = shift;
my $encoding = new Mebius::Encoding;
my $proxy = new Mebius::Proxy;
my $mebius_lwp = new Mebius::LWP;
my $basic = $self->basic_object();

my $email = 'yuma.inaura@gmail.com';
my $cookie_file = $basic->cookie_file($email) || die;

my $random_proxy = $proxy->random_proxy() || die("Can't get random proxy addr and port.");

my $first_url = "https://mixi.jp/register.pl?m=pi&c=48621f3184fc0ca27cd4fc6af7d925e5";
my $first_html = $mebius_lwp->get($first_url,{ proxy => $random_proxy , cookie_file => $cookie_file });
$encoding->eucjp_to_utf8($first_html);

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub qm15_cookie_file{

my $self = shift;
my $email = shift || return();
my $basic = $self->basic_object();

my $cookie_directory = $basic->cookie_directory();
my $file = "${cookie_directory}15qm/$email.txt";

$file;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_email_for_new_account{

my $self = shift;
my $mebius_lwp = new Mebius::LWP;
my $proxy = new Mebius::Proxy;
my $basic = $self->basic_object();
my $encoding = new Mebius::Encoding;
my $crypt = new Mebius::Crypt;
my(%input,$confirm_url,%input_profile,$submit_profile_url,$preview_profile_url);
	
my $email = $self->get_free_email() || die;
my $cookie_file = $basic->cookie_file($email) || die;
my $random_proxy = $proxy->random_proxy() || die("Can't get random proxy addr and port.");

#my $random_proxy = "184.164.77.109:3127";

$basic->try_log("","Access to mixi top page.");

my $first_url = "https://mixi.jp/";
my $first_html = $mebius_lwp->get($first_url,{ proxy => $random_proxy , cookie_file => $cookie_file });
$encoding->eucjp_to_utf8($first_html);

$basic->rest_sleep();

$basic->try_log("","Accessed to submit email page.");

my $form_url = "https://mixi.jp/register.pl?from=login0_form";
my $form_html = $mebius_lwp->get($form_url,{ proxy => $random_proxy , referer => $first_url , cookie_file => $cookie_file });
$encoding->eucjp_to_utf8($form_html);

$basic->input_sleep();

$basic->try_log("","Input email and submit.");

$input{'email'} = $email;
$input{'postkey'} = $basic->html_to_postkey($form_html,$email) || die;
my $submit_url = "https://mixi.jp/register.pl?m=email_finish";
my $submited_html = $mebius_lwp->post($submit_url,\%input,{ proxy => $random_proxy , referer => $form_url , cookie_file => $cookie_file });
$encoding->eucjp_to_utf8($submited_html);

$basic->sleep(5);

	for(1..5){
			if($confirm_url = $self->check_free_email_and_get_mixi_confirm_url($email)){
				last;
			} else {
				console "Try again.";
				$basic->sleep(10);
			}
	}

$basic->sleep(10);

my $confirm_html = $mebius_lwp->get($confirm_url,{ proxy => $random_proxy , cookie_file => $cookie_file });
$encoding->eucjp_to_utf8($confirm_html);

	if($confirm_html =~ m!<form name="regForm" action="(register\.pl\?([a-zA-Z0-9\.=&]+))"!){
		$preview_profile_url = "https://mixi.jp/$1";
		$basic->succeed_log("","Access to mixi confirm page.",$confirm_html);
	} else {
		$basic->failed_log("","Could not get mixi confirm page.",$confirm_html);
		die;
	}

$basic->input_sleep();

$input_profile{'postkey'} = $basic->html_to_postkey($confirm_html,$email) || die;
$input_profile{'email'} = $email;
$input_profile{'password1'} = $input_profile{'password2'} = $crypt->char(10);
$input_profile{'agree'} = 1;
$input_profile{'state'} = "";
$input_profile{'service_name'} = "";
$input_profile{'location_change'} = 1;
$input_profile{'location_area'} = 0;

my $input_profile_make_good = $self->make_good_profile_common_default(\%input_profile);
my %input_confirm = %{$input_profile_make_good};
my %input_euc_profile = %{$input_profile_make_good};
	foreach my $key ( keys %{$input_profile_make_good} ){
		$input_euc_profile{$key} = $encoding->utf8_to_eucjp($input_euc_profile{$key});
	}
my $profile_preview_html = $mebius_lwp->post($preview_profile_url,\%input_euc_profile,{ proxy => $random_proxy , referer => $confirm_url , cookie_file => $cookie_file });
$encoding->eucjp_to_utf8($profile_preview_html);

	if($profile_preview_html =~ m!<form action="(register\.pl\?([a-zA-Z0-9\.=&]+))"!){
		$submit_profile_url = "https://mixi.jp/$1";
		$basic->succeed_log("","Preview new account profile.",$profile_preview_html);
	} else {
		$basic->failed_log("","Could not input profile.",$profile_preview_html);
		die;
	}

$input_confirm{'submit_ok'} = "次へ";
	foreach my $key ( keys %{$input_profile_make_good} ){
		$input_confirm{$key} = $encoding->utf8_to_eucjp($input_confirm{$key});
	}

$basic->preview_sleep();

my $profile_submited_html = $mebius_lwp->post($submit_profile_url,\%input_confirm,{ proxy => $random_proxy , referer => $submit_profile_url , cookie_file => $cookie_file });
$encoding->eucjp_to_utf8($profile_submited_html);

$basic->try_log("","Submited account.",$profile_submited_html);

exit;

#$basic->succeed_log("","Submited email for make new account.",$submited_html);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_free_email{

my $self = shift;
my $basic = $self->basic_object();
my $mebius_lwp = new Mebius::LWP;
my($email);

$basic->try_log("","Get free email.");

my $url = "http://15qm.com/?act=sevin";
my $time = time;

my $cookie_directory = $basic->cookie_directory();
my $temporary_cookie_file = "${cookie_directory}15qm/$time.txt";

my($get_html,$cookie_jar) = $mebius_lwp->get($url,{ cookie_file => $temporary_cookie_file , Proxy => 1 });
unlink $temporary_cookie_file;

	if($get_html =~ m!<input size="30" type="text" value="([0-9a-zA-Z\@\.\-]+)"/>!){
		$email = $1;
		$basic->succeed_log($email,"Email is $email");
	} else {
		$basic->failed_log("","Could not get email.");
		return();
	}

my $cookie_file_with_email = $self->qm15_cookie_file($email) || die;
$cookie_jar->save($cookie_file_with_email);

$self->insert_main_table({ email => $email , account_type => "pre" });

$email;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub check_free_email_and_get_mixi_confirm_url{

my $self = shift;
my $email = shift || return();
my $mebius_lwp = new Mebius::LWP;
my $basic = $self->basic_object();
my($email_url,$mixi_confirm_url);

my $cookie_file = $self->qm15_cookie_file($email) || die;
my $email_list_url = "http://15qm.com/?act=sevin";

$basic->try_log("","Access to Email list on 15qm.com .");

my $email_list_html = $mebius_lwp->get($email_list_url,{ cookie_file => $cookie_file , Proxy => 1 });

	if($email_list_html =~ m!href="(http://15qm.com/\?act=mde&amp;mid=[^"]+)!){
		$email_url = $1;
		$email_url =~ s/&amp;/&/g;
		$basic->succeed_log("","Got email list.",$email_list_html);
	} else {
		$basic->failed_log("","Got email list failed. Email is not exists.",$email_list_html);
		return();
	}

$basic->try_log("","Access to email page. $email_url");

my $email_html = $mebius_lwp->get($email_url,{ cookie_file => $cookie_file , Proxy => 1 });

	if($email_html =~ m!(https://mixi\.jp/register\.pl\?m=pi&amp;c=[0-9a-zA-Z]+)!){
		$mixi_confirm_url = $1;
		$basic->succeed_log("","Got mixi confirm url. $mixi_confirm_url",$email_html);
	} else {
		$basic->failed_log("","Couldn't get mixi confirm url.");
	}


$mixi_confirm_url;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub put_user_agent{

my $self = shift;
my $mebius_lwp = new Mebius::LWP;

my $data_group = $self->fetchrow_main_table({ status => ["IS","NULL"] });

	foreach my $data (@{$data_group}){

			if($data->{'browser_user_agent'}){
				console "Still exists browser user agent.";

			} else {
				my $random_browser_user_agent = $mebius_lwp->random_browser_user_agent();
				$self->update_main_table({ target => $data->{'target'} , browser_user_agent => $random_browser_user_agent });
				console "Put $random_browser_user_agent";

			}

	}


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub our_proxies{

my $self = shift;

#'61.195.97.203:80',

my @proxy = (
'182.163.56.52:80',
'36.55.239.25:80',
'182.163.56.58:80',
'36.55.239.189:80',
'182.163.56.88:80'
);

return @proxy;

}


#-----------------------------------------------------------
# 定義された安全な Proxy を、全アカウントにランダムに設定する
#-----------------------------------------------------------
sub set_our_proxies{

my $self = shift;
my($count);
my $console = new Mebius::Console;
my($new_proxy);

console "SET OUR PROXIES START.";

my $account_data_group = $self->fetchrow_main_table({ });


	if($console->option('--overwrite')){
		console "OVER WRITE MODE.";
		sleep 1;
	}

	if( $new_proxy = $console->point_option('--proxy')){
		console "New proxy is $new_proxy.";
		sleep 1;
	}

	foreach my $account_data (@{$account_data_group}){

		$count++;

		my @proxy_list = $self->our_proxies();
		my $rand = int rand(@proxy_list);
		console "Account $account_data->{'account'} Email $account_data->{'email'}";

			# 基本的には上書きしない
			# オプション --overwrite が指定された場合を除く
			if($console->option('--overwrite')){
					if($rand == 1){
						console "Random $rand == 1";
					} else {
						console "Random $rand > 1";
						next;
					}
			} elsif(in_array($account_data->{'proxy'},@proxy_list)){
				next;
			}

		my $use_proxy = $new_proxy || $proxy_list[int rand(@proxy_list)];

		$self->update_main_table({ target => $account_data->{'target'} , proxy => $use_proxy });

		console "$count. Set Proxy . $account_data->{'email'} $use_proxy ";
		#sleep 1;

	}

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub put_proxy_to_all_accounts{

my $self = shift;
my $proxy = new Mebius::Proxy;
my $move = new Mebius::Move;
my $console = new Mebius::Console;
my($count);

my $data_group = $self->fetchrow_main_table({ status => ["IS","NULL"] });

	foreach my $data (@{$data_group}){

		my($still_flag);

		$count++;

		my @proxy_list = $proxy->proxy_list();

			foreach my $proxy_per (@proxy_list){
					if($data->{'proxy'} eq $proxy_per){
						$still_flag = 1;
						last;
					}
			}

		my $random_proxy = $proxy->random_proxy();

			if($still_flag && !$console->{'all'}){
				next;
			} else {
				console "$count. Set Proxy . $data->{'email'} $random_proxy ";
			}

		$self->update_main_table({ target => $data->{'target'} , proxy => $random_proxy });

	}

$move->redirect_to_self_url();

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub popular_last_names{

my $self = shift;

my @last_name = (
'佐藤','鈴木','高橋','田中','伊藤','山本','渡辺','中村','小林','加藤','吉田','山田','佐々木','山口','松本','井上','木村','林','斎藤','清水','山崎','阿部','森','池田','橋本','山下','石川','中島','前田','藤田','後藤','小川','岡田','村上','長谷川','近藤','石井','斉藤','坂本','遠藤','藤井','青木','福田','三浦','西村','藤原','太田','松田','原田','岡本','中野','中川','小野','田村','竹内','金子','中山','和田','石田','工藤','上田','原','森田','酒井','横山','柴田','宮崎','宮本','内田','高木','谷口','安藤','丸山','今井','大野','高田','菅原','河野','武田','藤本','上野','杉山','千葉','村田','増田','小島','小山','大塚','平野','久保','渡部','松井','菊地','岩崎','松尾','佐野','木下','野口','野村','新井');

@last_name;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub lady_first_names{

my $self = shift;
my @name = (
"はな","ひまり","かんな","あかり","いちか","さら","ゆい","あおい","ほのか","めい","にこ","ひなた","みゆ","さな","りこ","ひより","ゆずき","ここな","ひかり","るな","はる","のあ","そら","ののか","かのん","ゆきな","こはる","りお","いろは","ゆあ","みのり","あさひ","みお","みう","あこ","ひな","りん","りあ","さくら","ゆな","あいり","かれん","はるか","すみれ","ゆら","まひろ","みこと","ことは","みおり","みく","しずく","みはる","ゆき","みなみ","りな","あかね","れい","らら","あやか","あい","えま","あいか","かりん","ふうか","はるひ","さき","あいら","ゆめ","あき","せな","かほ","ぷう","さやか","りんか","あみ","ここ","しおり","かな","ゆうな","さえ","ゆの","かすみ","りの","ゆう","ねね","れな","しおん","なな","ゆいか","ゆうか","みつき","みずき","まな","くるみ","りおな","ゆず","みあ","えれな","ななみ","るか",
"結菜","ゆいな","蓮","れん","陽菜","ひな","葵","あおい","結愛","ゆあ","結衣","ゆい","凛","りん","愛莉","あいり","心春","こはる","そうま","愛梨","あいり","芽依","めい",

);

@name;

}






1;