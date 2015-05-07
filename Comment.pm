
package Mebius::Mixi::Comment;

use strict;

use Mebius::Mixi::Basic;
use Mebius::Mixi::Event;
use Mebius::Mixi::Community;
use Mebius::Mixi::Account;
use Mebius::Mixi::Task;

use Mebius::Time;
use Mebius::Console;
use Mebius::View;
use Mebius::Query;
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
sub basic_object{

my $self = shift;
my $object = new Mebius::Mixi;

$object;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub auto_submit{

my $self = shift;
my $topic_type = shift;
my $submit_type = shift;

my $event = new Mebius::Mixi::Event;
my $community = new Mebius::Mixi::Community;
my $mixi_account = new Mebius::Mixi::Account;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $task = new Mebius::Mixi::Task;
my $submit_event = new Mebius::Mixi::SubmitEvent;

my $param  = $query->param();
my $basic = $self->basic_object();

my(@event_target,@all_message,$hit,$print,%done);
	
	if($submit_event->early_morning_or_midnight()){
		exit;
	}


	# 実行がロックされている場合は戻る 
	#if(!$task->allow_task_judge("${topic_type}_${submit_type}") && console){
	#	return();
	#}

# 有効なイベントを取得する
my @event_target = $submit_event->useful_event_targets($topic_type);
my $event_hash_group = $submit_event->useful_event_hash_group($topic_type);

my $data_group = $submit_event->fetchrow_main_table_asc({ submit_type => "post" , topic_type => $topic_type , event_deleted_flag => 0 , event_target => ["IN",\@event_target] },"try_time,create_time",{ Debug => 0 });
my $data_num = @{$data_group};

console "$data_num topics/events try.";

	foreach my $data (@{$data_group}){

		my($message,$result);

			# このループの中で同じイベントに投稿した場合
			if($done{$data->{'mixi_event_id'}}){
				console "Comment to $data->{'mixi_event_id'} is still done.";
			}

			# トライ時間を記録する
			if(console()){
				$submit_event->update_main_table({ target => $data->{'target'} , try_time => time });
			}

		my $community_data = $community->fetchrow_main_table({ id => $data->{'mixi_community_id'} })->[0];
		my $community_link = $community->community_data_to_link($community_data);

		my $event_data = $event_hash_group->{$data->{'event_target'}};
		my $event_url = $submit_event->data_to_event_topic_url($data);

		# プレビューのためのに HTML リンクを定義する
		$message .= $community_link;
		$message .= " &gt; ";
		$message .= $html->href($event_url,$event_data->{'title'}) . "\n"; 

		# コメントを実行する
		$result = $self->submit($data,$topic_type);

			# コメントに成功した場合、終了する
			if($result eq "1"){

				$hit++;
				$done{$data->{'mixi_event_id'}}++;

				my $task_interval_second = $self->task_interval_second($topic_type);
				$task->submit_next_time_tremor("${topic_type}_${submit_type}",$task_interval_second);

				last;

			# コメントに失敗した場合、コメントしなかった場合
			} else {
				$message .= $result;
			}

		push @all_message , qq(<li>) . $message . qq(</li>); 
	}

$task->unlock("${topic_type}_${submit_type}");

	if(console){

		console 'FINISHED AUTO COMMENT';
		exit;

	} else {

		$print .= $submit_event->submit_forms();

		$print .= join "<hr>" , @all_message;

		$basic->print_html($print);
		exit;
	}

}


#-----------------------------------------------------------
# タスク全体の実行間隔
#-----------------------------------------------------------
sub task_interval_second{

my $self = shift;
my $topic_type = shift;
my($task_interval_second);

	# 実行間隔の定義 (イベント)
	if($topic_type eq "event"){

		$task_interval_second = 1*60*60;

	# 実行間隔の定義 (トピック)
	} elsif($topic_type eq "topic"){
		$task_interval_second = 1*60;

	} else {
		die;
	}

return $task_interval_second;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event{

my $self = shift;
my $basic = $self->basic_object();
my $data = shift || (warn && return());
my $account_data = shift || (warn && return());
my $event_data = shift|| (warn && return());

my $mixi_account = new Mebius::Mixi::Account;
my $community = new Mebius::Mixi::Community;
my $submit_event = new Mebius::Mixi::SubmitEvent;

my $basic = $self->basic_object();
my(%input,$flag,$post_key);

my $mixi_community_id = $data->{'mixi_community_id'} || (warn && return());
my $mixi_event_id = $data->{'mixi_event_id'} || (warn && return());

my $comment = $self->event_data_to_decide_comment_message($event_data,$account_data);
my $email = $account_data->{'email'} || (warn && return());

my $community_top_url = "http://mixi.jp/view_community.pl?id=$mixi_community_id";
my $event_topic_url = "http://mixi.jp/view_event.pl?comm_id=$mixi_community_id&id=$mixi_event_id";
my $event_topic_html = $basic->get($event_topic_url,$email,\%input, { referer => $community_top_url } );

	if($self->topic_no_data_to_update($event_topic_html,$data)){
		$basic->failed_log($email,"Topic data is already deleted $event_topic_url",$event_topic_html);
	} elsif($event_topic_html){
		$basic->succeed_log($email,"Viewed event topic. $event_topic_url ",$event_topic_html);
	} else {
		$basic->failed_log($email,"Can not view event topic $event_topic_url",$event_topic_html);
		return();
	}

$basic->input_sleep();

$basic->try_log($email,"Preview for comment.");

$input{'id'} =  $mixi_event_id;
$input{'comm_id'} =  $mixi_community_id;
$input{'comment'} = $comment;


my $preview_url = "http://mixi.jp/add_event_comment.pl";
my $preview_html = $basic->post($preview_url,$email,\%input, { referer => $event_topic_url } );

	if( $post_key = $basic->html_to_post_key($preview_html,$email)){
		$basic->succeed_log($email,"Got post key for submit.",$preview_html);
	} else {
		$basic->failed_log($email,"Can not get post key for submit comment.",$preview_html);
		return();
	}

$basic->try_log($email,"Comment to event topic.");

my %input_for_submit = %input;
#$input_for_submit{'join_click'} = "イベントに参加する";
$input_for_submit{'submit'} = "confirm";
$input_for_submit{'post_key'} = $post_key || die;

$basic->preview_sleep();

my $submit_url = $preview_url;
my $submited_html = $basic->post($submit_url,$email,\%input_for_submit,{ referer => $preview_url });

	if($submited_html =~ m!<p([^<>]+)>書き込みが完了しました!){

		my $new_target = $self->new_target();
		$self->insert_main_table({ email => $email , account => $account_data->{'account'} , target => $new_target , topic_type => "event" , submit_type => "comment" , mixi_community_id => $mixi_community_id , mixi_event_id => $mixi_event_id , last_comment_time => time });

		$mixi_account->account_data_to_one_action_plus($account_data);

		$flag = 1;
		$basic->finished_log($email,"Commented to event topic. $event_topic_url",$submited_html);

		$basic->rest_sleep();

		$community->delete_all_comments_on_event_or_topic($email,$mixi_community_id,$mixi_event_id,"event");

	} else {

		$flag = 0;
		$basic->failed_log($email,"Can not comment to event topic. ",$submited_html);

	}

$basic->rest_sleep();

$flag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topic{

my $self = shift;
my $data = shift || (warn && return());
my $account_data = shift || (warn && return());
my $event_data = shift || (warn && return());
my $use = shift || {};

my $mixi_account = new Mebius::Mixi::Account;
my $community = new Mebius::Mixi::Community;
my $event = new Mebius::Mixi::Event;
my $submit_event = new Mebius::Mixi::SubmitEvent;

my $basic = $self->basic_object();
my(%input_submit,$flag,$post_key);

my $mixi_community_id = $data->{'mixi_community_id'} || (warn && return());
my $mixi_event_id = $data->{'mixi_event_id'} || (warn && return());

my $email = $account_data->{'email'} || (warn && return());

my $community_top_url = "http://mixi.jp/view_community.pl?id=$mixi_community_id";
my $topic_url = "http://mixi.jp/view_bbs.pl?comm_id=$mixi_community_id&id=$mixi_event_id";
my $topic_html = $basic->get($topic_url,$email,{ referer => $community_top_url } );
my $post_key = $basic->html_to_post_key($topic_html,$email);

	if($submit_event->topic_no_data_to_update($topic_html,$data)){
		$basic->failed_log($email,"Topic data is already deleted $topic_url",$topic_html);
	} elsif($post_key){
		$basic->succeed_log($email,"Viewed topic. $topic_url ",$topic_html);
	} else {
		$basic->failed_log($email,"Can not view topic $topic_url",$topic_html);
		return();
	}

$submit_event->delete_before_comments_on_event_or_topic($mixi_community_id,$mixi_event_id,"topic");

$basic->input_sleep();

$input_submit{'mode'} = "write";

	if($use->{'event_on_comment_flag'}){
		my $title = $event->effect($event_data->{'title'},$event_data) || die "Title is empty";
		my $bbs_body = $event->text_to_bbs_body($event_data->{'bbs_body'},$event_data) || die "BBS body is empty";
		$input_submit{'comment'} =  $title."\n\n".$bbs_body;
	} else {
		$input_submit{'comment'} =  $submit_event->event_data_to_decide_comment_message($event_data,$account_data);;
	}

$input_submit{'post_key'} = $post_key || die;

my $submit_url = "http://mixi.jp/add_bbs_comment.pl?id=$mixi_event_id&comm_id=$mixi_community_id";
my $submit_html = $basic->post($submit_url,$email,\%input_submit, { referer => $topic_url } );

	if( $submit_html =~ m!<p([^<>]+)>書き込みが完了しました。!){

		my $new_target = $submit_event->new_target_char();
		$submit_event->insert_main_table({ target => $new_target , email => $email , account => $account_data->{'account'} , topic_type => "topic" , submit_type => "comment" , mixi_community_id => $mixi_community_id , mixi_event_id => $mixi_event_id , event_target => $event_data->{'target'} , last_comment_time => time });

		$mixi_account->account_data_to_one_action_plus($account_data);

		$flag = 1;
		$basic->finished_log($email,"Submited comment to topic. $topic_url",$submit_html);

		#$submit_event->delete_before_comments_on_event_or_topic($mixi_community_id,$mixi_event_id,"topic",$new_target);
		#$community->delete_all_comments_on_event_or_topic($email,$mixi_community_id,$mixi_event_id,"topic");

		$basic->rest_sleep();

	} else {
		$basic->failed_log($email,"Can not submit comment to topic.",$submit_html);
		return();
	}
$basic->rest_sleep();

$flag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit{

my $self = shift;
my $data = shift || (warn && return());
my $topic_type = shift || die;

my $community = new Mebius::Mixi::Community;
my $mixi_account = new Mebius::Mixi::Account;
my $event = new Mebius::Mixi::Event;
my $query = new Mebius::Query;
my $times = new Mebius::Time;
my $submit_event = new Mebius::Mixi::SubmitEvent;

my $param  = $query->param();
my $basic = $self->basic_object();

my(@message,$message,$flag,$account_data,$account_data_exists,@console);

my $interval_second_special = 2*60*60;

my $mixi_community_id = $data->{'mixi_community_id'} || (warn && return());
my $mixi_event_id = $data->{'mixi_event_id'} || (warn && return());

console "Try to comment $topic_type $data->{'mixi_community_id'} $data->{'mixi_event_id'}.";

my $recently_comment_data = $submit_event->fetchrow_main_table_desc({ submit_type => "comment" , mixi_community_id => $mixi_community_id , mixi_event_id => $mixi_event_id },"create_time")->[0];

my $recently_post_data = $submit_event->fetchrow_main_table_desc({ submit_type => "post" , mixi_community_id => $mixi_community_id , mixi_event_id => $mixi_event_id },"create_time")->[0];

my $community_data = $community->fetchrow_main_table({ id => $mixi_community_id });

my $event_data = $event->fetchrow_main_table({ target => $data->{'event_target'} })->[0];

	#if(console()){
	#	$submit_event->update_main_table({ target => $data->{'target'} , try_time => time });
	#}

	if($event_data->{'end_time'} && time > $event_data->{'end_time'} - 2*60*60){
		push @message , "イベントが既に終了間際/もしくは終了済みです。";
		push @console , "Event is still finished of will be finished soon.";
	} elsif(time < $data->{'last_check_order_time'} + $self->border_second()){
		push @message , qq(前に順位をチェックしたばかりです。);
		push @console , "I checked order of $topic_type recently. Please wait ". ($data->{'last_check_order_time'} - time + $self->border_second())." seconds.";
	} elsif(time < $recently_comment_data->{'create_time'} + $self->border_second()){
		push @message , qq(このイベントには前にコメントしたばかりです。);
		push @console , "This event is recently commented.";
	} elsif(time < $recently_post_data->{'create_time'} + $interval_second_special){
		push @message , qq(このイベントは登録したばかりです。);
		push @console , "This event is recently created.";
	} elsif($param->{'preview'}){
		push @message , qq(<span style="color:red;">コメントできそうです。</span>);
	}

	if(@message >= 1){
		#console "Do not comment, skip.";
		console join '\n' , @console;
		return "@message";
	}

	if(!($submit_event->check_order_event_topic_and_allow($data,5,$topic_type))){
		return "コミュニティでの順位がまだ上にあります。";
	}

	if($topic_type eq "event"){
		$account_data = $account_data_exists = $mixi_account->main_useful_account_data();
	} elsif($topic_type eq "topic"){
		$account_data = $account_data_exists = $mixi_account->useful_account_data();
	}

$mixi_account->update_main_table({ target => $account_data->{'target'} , try_time => time });

	if(!$account_data_exists){
		console "No accounts found for comment to $topic_type.";
		return();
	}

my $email = $account_data->{'email'} || (warn && return());

	if($basic->lock($email)){
		return();
	}


my $joined_succeed_flag = $community->join_community($mixi_community_id,$email);
	if(!$joined_succeed_flag){	
		return("Do not comment because can not join community.");
	}

	if($topic_type eq "event"){
		$flag = $self->event($data,$account_data,$event_data);
	}	elsif($topic_type eq "topic"){
		$flag = $self->topic($data,$account_data,$event_data,{ and_delete_flag => 1 });
	} else {
		die;
	}

$basic->logout($email);

$basic->unlock($email);

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub border_second{
return 1*60*60;
}

1;
