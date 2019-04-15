	
package Mebius::Mixi::Friend;

use Mebius::Mixi::Account;
use Mebius::Move;

use Mebius::Query;

use strict;

use Mebius::Export;

use base qw(Mebius::Base::DBI Mebius::Base::Data);

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
sub junction{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();
my $basic = $self->basic_object();

my $mode = $param->{'mode'} || $ARGV[0];

	if($mode eq "apply_friend"){
		$self->all_accounts_apply_friend_each_other();
		1;
	} elsif($mode eq "admit_friend"){
		$self->all_accounts_admit_friend();
		1;
	} elsif($mode eq "apply_and_admit_friend"){
		$self->all_accounts_apply_friend_each_other();
		$self->all_accounts_admit_friend();
		1;
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
sub main_table_name{
"mixi_friend";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {
target => { PRIMARY => 1 } , 
from_email => { } ,
from_account => { } ,
to_account => { } ,
status => { } , 
create_time => { int => 1 } ,
};


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_accounts_apply_friend_each_other{

my $self = shift;
my $basic = $self->basic_object();
my $mixi_account = new Mebius::Mixi::Account;
my $console = new Mebius::Console;

console "ALL ACCOUNT APPLY FRIEND EACH OTHER START.";

my $border_friend_num = $console->point_option("-friend") || 1;
console "Border friend num is $border_friend_num.";

my $data_group = $mixi_account->fetchrow_main_table_asc({ account => ["IS","NOT NULL"] , status => ["IS","NULL"] , account_type => "limited" , last_action_time => ["<",time-24*60*60]  },"friend_num");
my $total_apply_num = @{$data_group};


# ,"main"

my %be_applied = (
account_type => ["IN",["limited"]] , 
status => ["IS","NULL"] ,
account => ["IS","NOT NULL"] ,
last_applied_friend_time => ["<",time-24*60*60] , 
friend_num => ["<",$border_friend_num] , 
);

my $be_applied_data_group = $mixi_account->fetchrow_main_table(\%be_applied);
my $be_applied_num = @{$be_applied_data_group};

	if(@{$data_group} == 0){
		$basic->try_log("","No accounts for apply.");
		return();
	} else {

		$basic->try_log("","$total_apply_num accounts for apply.");
		$basic->try_log("","$be_applied_num accounts for be applie.");

	}

$basic->sleep(3);

	foreach my $from_account_data (@{$data_group}){

			if(time < $from_account_data->{'last_apply_friend_time'} + 24*60*60){
				console("$from_account_data->{'email'} has apply friend recently, next.");
				next;
			}

		my %be_applied_per = %be_applied;
		$be_applied_per{'email'} => ["<>",$from_account_data->{'email'}];
		my $to_account_data = my $to_account_data_exists = $mixi_account->fetchrow_main_table_asc(\%be_applied,"friend_num")->[0];

				if(!$to_account_data_exists){
					$basic->try_log("","No account for be applied found.");
					last;
				}

		$self->apply_friend($from_account_data->{'email'},$to_account_data->{'account'});

	}

console "ALL ACCOUNT APPLY FRIEND EACH OTHER FINISHED.";

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub apply_friend{

my $self = shift;
my $from_email = shift || (warn && return());;
my $to_id = shift || (warn && return());;
my $basic = $self->basic_object();
#my $friend = new Mebius::Mixi::Friend:
my $mixi_account = new Mebius::Mixi::Account;
my($apply_url,%apply);

my $account_data = $mixi_account->fetchrow_main_table({ email => $from_email })->[0];
my $to_account_data = $mixi_account->fetchrow_main_table({ account => $to_id })->[0];

	if($account_data->{'account'} eq $to_id){
		$basic->failed_log($from_email,"They are same user, $account_data->{'account'} and $to_id .");
		return();
	}

my $apply_data_from = my $apply_data_exists = $self->fetchrow_main_table({ from_account => $account_data->{'account'} , to_account => $to_id })->[0];
	if($apply_data_exists){
		$basic->failed_log($from_email,"Already applied friend, $account_data->{'account'} to $to_id.");
	}

my $apply_data_to = my $apply_data_to_exists = $self->fetchrow_main_table({ to_account => $account_data->{'account'} , from_account => $to_id })->[0];
	if($apply_data_to_exists){
		$basic->failed_log("","Already be applied from other friend, $to_id to $account_data->{'account'}.");
	}

my $profile_url = "http://mixi.jp/show_friend.pl?id=$to_id";
my $profile_html = $basic->get($profile_url,$from_email);

$basic->try_log($account_data->{'email'},"$account_data->{'account'} apply to $to_id");

	if($profile_html =~ m! href="(add_friend\.pl\?route_trace=([0-9]+)&page_type=action_area_wide&id=([0-9]+))"!){
		$apply_url = "http://mixi.jp/$1";
		$basic->succeed_log($from_email,"Profile page to got apply url.",$profile_html);
	} elsif($profile_html =~ m!ハロー！</a>!){
		$basic->try_log($from_email,"By see profile page , still friend.",$profile_html);
	} else {
		$basic->failed_log($from_email,"Can not get apply url.",$profile_html);
		return();
	}

$basic->rest_sleep();

my $apply_html = $basic->get($apply_url,$from_email,{ referer => $profile_url });

$basic->try_log($from_email,"Got apply page.",$apply_html);

$apply{'id'} = $to_id;
$apply{'replacement_message'} = "";
$apply{'submit'} = "main";
$apply{'from'} = "add_friend_main";
$apply{'post_key'} = $basic->html_to_post_key($apply_html) || return();
$apply{'uid'} = "";

$basic->input_sleep();

my $preview_url = "http://mixi.jp/add_friend.pl";
my $preview_html = $basic->post($preview_url,$from_email,\%apply,{ referer => "http://mixi.jp/list_request.pl" });

	if($preview_html =~ m!<p>以下の内容で送信します。よろしいですか？</p>!){
		$basic->succeed_log($from_email,"Got a preview page.",$preview_html);
	} else {
		$basic->failed_log($from_email,"Can not get preview page.",$preview_html);
		return();
	}

my %input_submit = %apply;
$input_submit{'submit'} = "confirm";
$input_submit{'replacement_message'} = "";
$input_submit{'message'} = $apply{'replacement_message'};

$basic->preview_sleep();

my $submit_url = "http://mixi.jp/add_friend.pl";
my $submited_html = $basic->post($submit_url,$from_email,\%input_submit,{ referer => $preview_url });

	if($submited_html =~ m!<p class="messageAlert">追加リクエストを送信しました。</p>!){

		$basic->finished_log($from_email,"Submited apply friend. $account_data->{'account'} apply to $to_id .",$submited_html);

		$mixi_account->update_main_table({ target => $account_data->{'target'} , last_apply_friend_time => time });
		$mixi_account->one_action_plus($account_data);

		$mixi_account->update_main_table({ target => $to_account_data->{'target'} , last_applied_friend_time => time });

		$self->insert_main_table({ from_account => $account_data->{'account'} , from_email => $from_email , to_account => $to_id });

	} else {

		$basic->failed_log($from_email,"Could not apply friend .",$submited_html);
		return();

	}

$basic->rest_sleep();

1;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_accounts_admit_friend{

my $self = shift;
my $basic = $self->basic_object();
my($data_group,$count);

console "ALL ACCOUNTS ADMIT FRIEND.";

	if($ARGV[1] eq "all"){
		$data_group = $self->fetchrow_main_table({ status => ["<>","admit"] });		
	} else {
		$data_group = $self->fetchrow_main_table({ status => ["IS","NULL"] });
	}


my $num = @{$data_group};
	if(!$num){
		console "No accounts for admit applies." && return();
	}

console "$num ACCOUNTS.";
$basic->sleep(3);

	foreach my $data (@{$data_group}){
			
			$count++;
			console "Left " . $num - $count . " actions.";

			my $succeed_flag = $self->admit_friend($data->{'to_account'},$data->{'from_account'},$data);
			if(!$succeed_flag){
				$self->update_main_table({ target => $data->{'target'} , status => "failed" });
			}

	}

console "FINISHED";


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub admit_friend{

my $self = shift;
my $account_id = shift || die;
my $target_account_id = shift || die; 
my $friend_data = shift || die;
my $mixi_account = new Mebius::Mixi::Account;
my $basic = $self->basic_object();
my(%input_preview,$friend_requests_url);

my $account_data = $mixi_account->fetchrow_main_table({ account => $account_id })->[0] || die;
my $target_account_data = $mixi_account->fetchrow_main_table({ account => $target_account_id })->[0] || die;

my $email = $account_data->{'email'} || die;

my $home_url = "http://mixi.jp/home.pl";
my $home_html = $basic->get($home_url,$email);

	if($home_html =~ m!<a href="([^"<>]+)">マイミク追加リクエストが([0-9]+)件あります！</a></li>!){
		$friend_requests_url = "http://mixi.jp/$1";
		$basic->succeed_log($email,"Admit url is $friend_requests_url.",$home_html);
	} else {
		$basic->failed_log($email,"No apply from other accounts",$home_html);
		return();
	}

$basic->rest_sleep();

#my $friend_requests_url = "http://mixi.jp/list_request.pl";
my $friend_requests_html = $basic->get($friend_requests_url,$email,{ referer => $home_url } );

	if($friend_requests_html =~ m/<input type="hidden" value= "$target_account_id" name="id">/){
		$basic->succeed_log($email,"There is apply from $target_account_id.",$friend_requests_html);
	} else {
		$basic->failed_log($email,"No apply from $target_account_id.",$friend_requests_html);
		return();
	}


$input_preview{'id'} = $target_account_id;
$input_preview{'post_key'} = $basic->html_to_post_key($friend_requests_html) || return();
$input_preview{'page'} = 1;
$input_preview{'anchor'} = 1;
$input_preview{'submit_accept'} = "マイミクに追加する";

$basic->preview_sleep();

my $submit_url = "http://mixi.jp/accept_request.pl";
my $submited_html = $basic->post($submit_url,$email,\%input_preview,{ referer => $friend_requests_url  });

	if($submited_html =~ m!<title>302 Found</title>!){

		$basic->finished_log($email,"Submited apply from $target_account_id.",$submited_html);

		$self->update_main_table({ target => $friend_data->{'target'} , status => "admit"  });

		$mixi_account->update_main_table({ target => $account_data->{'target'} , friend_num => ["+",1] });
		$mixi_account->update_main_table({ target => $target_account_data->{'target'} , friend_num => ["+",1] });

	} else {
		$basic->failed_log($email,"Can not submit apply from $target_account_id.",$submited_html);
		return();
	}


$basic->rest_sleep();

1;

}



1;
