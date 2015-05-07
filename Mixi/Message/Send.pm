
use strict;

package Mebius::Mixi::Message::Send;

use Mebius::Mixi::Message;
use Mebius::Mixi::Account::Useful;

use Mebius::Query;

use Data::Dumper;

use base qw(Mebius::Base::DBI Mebius::Base::Data Mebius::Mixi::Account);
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
sub basic_object{

my $self = shift;
my $object = new Mebius::Mixi;

$object;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_account{

my $mixi_account = new Mebius::Mixi::Account;
my $mixi_account_useful = new Mebius::Mixi::Account::Useful;

#my $account_group = $mixi_account->fetchrow_main_table({ account_type => "message" },{ ORDER_BY => ["last_action_time ASC"] });

#my $account_group = $mixi_account_useful->useful_account_data_group({ account_type => "message" });
my $account_group = $mixi_account_useful->useful_account_data_group();

return $account_group->[0];

}

#-----------------------------------------------------------
# タスクを展開して送信する
#-----------------------------------------------------------
sub doing{

my $self = shift;
my $basic = $self->basic_object();
my $task = new Mebius::Mixi::Message::Task;
#my $query = new Mebius::Query;
#my $param  = $query->param();

my $task_send_group = $task->send_group();
my $task_num = @{$task_send_group};

console "$task_num tasks found.";

	foreach my $task_data (@{$task_send_group}){

		#my $profile_url = "http://mixi.jp/show_friend.pl?id=$mixi_id";
		#my $profile_html = $basic->get($profile_url,$email);

		my $flag = $self->send($task_data);
		
		#last;

	}

#http://mixi.jp/send_message.pl?id=59196146&ref=show_friend
#

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub send{

my $self = shift;
my $task_data = shift;
my $mixi_account = new Mebius::Mixi::Account;
my $task = new Mebius::Mixi::Message::Task;
my $basic = $self->basic_object();
my(%post,%preview);

my $account_data = $self->useful_account();

my $email = $account_data->{'email'};
my $mixi_id = $task_data->{'to_account'};

my $message_url = "http://mixi.jp/send_message.pl?id=$mixi_id";
my $message_html = $basic->get($message_url,$email);

$basic->try_log($email,"Access to message send page $message_url ",$message_html);

my $post_key = $basic->html_to_post_key($message_html,$email,undef,1);

console "post key is $post_key";

$preview{'mode'} = "confirm_or_save";
$preview{'from_show_friend'} = "0";
$preview{'subject'} = $task_data->{'subject'};
$preview{'body'} = $task_data->{'body'};
#	$preview{'photo'} = "";
#$preview{'save'} = 1;
#$preview{'submit'} = "入力内容を確認する";
$preview{'post_key'} = $post_key || die("Post key is empty.");
$preview{'original_message_id'} = "";
$preview{'reply_message_id'} = "";
$preview{'id'} = $mixi_id;

#print Dumper \%post; 

my $preview_url = "http://mixi.jp/send_message.pl";
my $preview_html = $basic->post($preview_url,$email,\%preview,{ referer => $message_url });

	if($preview_html =~ m!<p>以下の内容でメッセージを送信します!){
		$basic->try_log($email,"Preview message.",$preview_html);
	} else {
		$basic->failed_log($email,"Can not preview message.",$preview_html);
		exit;
	}


	if($ARGV[1] eq "preview"){
		exit;
	}

$post{'post_key'} = $post_key || die("Post key is empty.");
$post{'mode'} = "commit_or_edit";
$post{'from_show_friend'} = "0";
$post{'subject'} = $task_data->{'subject'};
$post{'body'} = $task_data->{'body'};
$post{'id'} = $mixi_id;
$post{'original_message_id'} = "";
$post{'reply_message_id'} = "";
$post{'yes'} = "同意して送信する";

my $post_url = "http://mixi.jp/send_message.pl";
my $post_html = $basic->post($post_url,$email,\%post,{ referer => $preview_url });

	if($post_html =~ m!<h1>Found</h1>!){
		$mixi_account->action($email);
		$task->update_main_table({ target => $task_data->{'target'} , done_flag => 1 });
		$basic->try_log($email,"Send message.",$post_html);
	} else {
		$basic->failed_log($email,"Can not send message.",$post_html);
	}
 
}



1;

