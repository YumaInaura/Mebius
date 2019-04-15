
package Mebius::Mixi::SubmitEvent;

use strict;

use Mebius::Mixi::Basic;
#use Mebius::Mixi::Community;
#use Mebius::Mixi::Account;
use Mebius::Mixi::Event;
use Mebius::Mixi::Community;
use Mebius::Mixi::Account;
use Mebius::Mixi::Task;
use Mebius::Mixi::Comment;


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
sub BEGIN{

our $total_submit_count = undef;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {
target => { PRIMARY => 1 } ,
account => { INDEX => 1 } ,
email => { } , 
mixi_community_id => { INDEX => 1 } ,
mixi_event_id => { INDEX => 1 } ,
event_target => { INDEX => 1 } ,
submit_type => { INDEX => 1 } , 
topic_type => { INDEX => 1 } , 
event_num => { int => 1 } , 

create_time => { INDEX => 1, int => 1 } , 
last_modified => { int => 1 } ,

last_edit_time => { int => 1 } , 
event_deleted_flag => { int => 1 } ,
comment_deleted_flag => { int => 1 } ,
comment_full_flag => { int => 1 } , 

forced_event_deleted_flag => { int => 1 } , 
last_check_order_time => { int => 1 } , 
last_check_alive_time => { int => 1 } ,
last_comment_time => { int => 1 } , 
event_kind_number => { int => 1 }  ,
schedule_target => { } ,

try_time => { int => 1 } , 

};

$column;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my $query = new Mebius::Query;
my $comment = new Mebius::Mixi::Comment;

my $param  = $query->param();

my $mode = $param->{'mode'} || $ARGV[0];

	if($mode eq "auto_submit_event_view"){
		$self->self_view();
	} elsif($mode eq "event_comment" || $mode eq "submit_comments"){
		$comment->auto_submit("event","comment");
	} elsif($mode eq "topic_comment"){
		$comment->auto_submit("topic","comment");
	} elsif($mode eq "edit_events"){
		$self->all_edit_events();
	#} elsif($mode =~ /^(?:submit_)?(topic|event)s?_(post|comment)_roop$/){
	#	$self->auto_submit_roop($1,$2);
	} elsif($mode eq "edit_event_with_schedule"){
		$self->edit_event_with_schedule();
	} elsif($mode =~ /^delete_all_comments_on_(topic|event)$/){
		$self->delete_before_comments_on_event_or_topic($ARGV[1],$ARGV[2],$1);
	} elsif($mode eq "submit_events" || $mode eq "event_post"){
		$self->auto_submit_post("event","post");
	} elsif($mode eq "submit_topics" || $mode eq "topic_post"){
		$self->auto_submit_post("topic","post");
	}	elsif($mode eq "overwrite_events"){
		$self->auto_overwrite_events();
	#}	elsif($mode eq "overwrite_events_roop"){
	#	$self->auto_submit_roop("overwrite_events");
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
"mixi_submit_event";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub self_view{

my $self = shift;
my $basic = $self->basic_object();
my $html = new Mebius::HTML;
my $community = new Mebius::Mixi::Community;
my $mixi_account = new Mebius::Mixi::Account;
my $view = new Mebius::View;
my($print);

my $page_title = "自動投稿の管理";

my @links = (
{ url => "?mode=auto_submit_event_view" , title => "全て" } ,
{ url => "?mode=auto_submit_event_view&view_only_url=1" ,  title => "URLのみ" } ,
);

my $data_group = $self->fetchrow_main_table_desc({ },"create_time",{ LIMIT => 500 });

$print .= $view->links(\@links);

$print .= $html->tag("h2","登録");
$print .= $self->submit_forms();

$print .= $html->tag("h2","登録履歴");
$print .= $self->data_group_to_list($data_group);

my $data_group = $mixi_account->useful_account_data_group();
$print .= $mixi_account->data_group_to_table($data_group,"利用可能アカウント");


$basic->print_html($print,{ Title => $page_title , h1 => $page_title } );

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_data_to_edit_out_sites{

my $self = shift;
my $event_data = shift || return();

my $data_group = $self->fetchrow_main_table({ event_target => $event_data->{'target'} });

	foreach my $data (@{$data_group}){
		$self->edit_event($data);
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_forms{

my $self = shift;
my($print);

$print .= $self->submit_form("topic","post");
$print .= $self->submit_form("topic","comment");

$print .= $self->submit_form("event","post");
$print .= $self->submit_form("event","comment");

#$print .= $self->submit_form("overwrite_event");

$print;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_form{

my $self = shift;
my $topic_type = shift || die;
my $submit_type = shift || die;
my $html = new Mebius::HTML;
my $basic = $self->basic_object();
my($print,$mode_value,$mode_label);

$mode_value = "${topic_type}_${submit_type}";

	if($topic_type eq "event"){
		$mode_label .= "イベントへの";
	} elsif($topic_type eq "topic"){
		$mode_label .= "トピックへの";
	}

	if($submit_type eq "post"){
		$mode_label .= "新規登録";
	} elsif($submit_type eq "comment"){
		$mode_label .= "コメント";
	}

$print .= $html->start_tag("form",{ method => "post" , style => "margin:1em 0em;" });
$print .= $html->input("hidden","mode",$mode_value);

	#if($type eq "preview"){
		$print .= $html->input("submit","preview","【$mode_label】のプレビュー ",{ style => "color:blue;" , NotOverwrite => 1 } );
	#} els

	#if($type eq "submit"){
	#	$print .= $html->input("submit","submit","【$mode_label】を自動登録する(実行)",{ style => "color:red;"} );
	#}

#$print .= $basic->max_hit_selectbox();

$print .= $html->input("checkbox","all",1,{ text => "all" });


$print .= $html->close_tag("form");

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub auto_overwrite_events{

my $self = shift;
my $event = new Mebius::Mixi::Event;
my $task = new Mebius::Mixi::Task;
my $basic = $self->basic_object();
my $community = new Mebius::Mixi::Community;
my $mixi_account = new Mebius::Mixi::Account;
my $event = new Mebius::Mixi::Event;
my $query = new Mebius::Query;
my $param  = $query->param();
my $times = new Mebius::Time;
my($print,@all_message,@event_target);

my $interval_second = 15*60;
my $page_title = "イベントの上書き登録";

	if(!$task->allow_task_judge("overwite_events")){
		return();
	}

my @event_target = $self->useful_event_targets();

my $data_group = $self->fetchrow_main_table_asc({ submit_type => "post" , topic_type => "event" , event_deleted_flag => 0 , event_target => ["IN",\@event_target] },"create_time");
my $data_num = @{$data_group} || 0;

	if($data_num){
		console "$data_num OVERWRITE EVENTS";
		$basic->sleep(3);
	} else {
		console "No events for overwrite";
	}

	foreach my $data (@{$data_group}){

		my($old_submited_data_group);

		my $community_id = $data->{'mixi_community_id'} || (warn && next);
		my $event_id = $data->{'mixi_event_id'} || (warn && next);

		my $event_data = $event->fetchrow_main_table({ target => $data->{'event_target'} })->[0];
	
		my $community_data = $community->fetchrow_main_table({ id => $community_id })->[0];

		my $email = $data->{'email'};
		$email ||= $mixi_account->fetchrow_main_table({ account => $data->{'account'} })->[0]->{'email'};

			if(!$param->{'preview'}){
					$old_submited_data_group = $self->fetchrow_main_table({ submit_type => "post" , topic_type => "event" , mixi_community_id => $community_id  , event_target => $data->{'event_target'} , event_deleted_flag => 0 },"create_time");
					#die "$community_id / $event_id / @$old_submited_data_group"; 
			} # Place before "submit event".

		my $result = $self->submit_event($event_data,$community_data,"overwrite");

			if($param->{'preview'}){
		
				my($message);

				my $community_link = $community->community_data_to_link($community_data);
				my $event_link = $community->event_topic_link($community_id,$event_id,$event_data->{'title'});

				$message .= $times->how_before($data->{'create_time'}) . "\n";
				$message .= $community_link . " <br>\n";
				$message .= $event_link . "\n";

					if($result eq "1"){
						$message .=  qq(<span style="color:red;">上書きできそうです。</span>);
					} else {
						$message .=  $result;
					}
				
				push @all_message , $message;

			} elsif($result eq "1" && console){

				$task->submit_next_time_tremor("overwrite_events",$interval_second);

					foreach my $old_data (@{$old_submited_data_group}){

						my $old_email = $old_data->{'email'} || $mixi_account->fetchrow_main_table({ account => $old_data->{'account'} })->[0]->{'email'};

						my $delete_suceed_flag = $community->delete_event_or_topic($old_email,$old_data->{'mixi_community_id'},$old_data->{'mixi_event_id'},"event");
						
							if($delete_suceed_flag){
								$self->update_main_table({ target => $old_data->{'target'} , event_deleted_flag => 1 });
							}

					}

					console "FINISHED OVERWRITE EVENT";
					return();

			}

	}


$print .= join "<hr>" , @all_message;

console "AUTO SUBMIT EVENT FINISHED.";

	if(!console){
		$basic->print_html($print,{ Title => $page_title , h1 => $page_title });
		exit;
	}

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub check_all_old_submits{

my $self = shift;
my $topic_type = shift;
my $mixi_account = new Mebius::Mixi::Account;

	if($topic_type ne "event"){
		return();
	}

my @event_target = $self->useful_event_targets();

console "[ALL CHECK OLD SUBMITS START]";

my $data_group = $self->fetchrow_main_table_asc({ last_check_alive_time => ["<",time-2*60*60] , submit_type => "post" , event_deleted_flag => 0 , event_target => ["IN",\@event_target] },"create_time");

my $account_data = $mixi_account->forview_account_data();

	if(!$account_data){
		warn "No useful accounts";
		return();
	}

	foreach my $data (@{$data_group}){
		$self->check_old_submit($data,$account_data->{'email'},$data->{'topic_type'});
	}

console "[ALL CHECK OLD SUBMITS FINISHED]";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub check_old_submit{

my $self = shift;
my $data = shift;
my $email = shift || die;
my $topic_type = shift;
my $basic = $self->basic_object();
my($flag,$event_deleted_flag);

	if(!$data){
		$basic->succeed_log($email,"No history submited.");
		return 1;
	}

my $event_url = $self->data_to_event_topic_url($data);

my $get = $basic->get($event_url,$email);

	if($get =~ m!参加者一覧へ</a>|最初から表示</a>!) {
		$basic->succeed_log($email,"$topic_type is alive. $event_url",$get);
		$flag = 1;
	} elsif($get =~ m!<p class="messageAlert">データがありません!){
		$basic->failed_log($email,"$topic_type is dead $event_url",$get);
		$event_deleted_flag = time;

		$flag = 0;
	} else {
		$basic->failed_log($email,"$topic_type is strange $event_url",$get);
		$flag = 0;
	}

$self->update_main_table({ target => $data->{'target'} , last_check_alive_time => time , event_deleted_flag => $event_deleted_flag , forced_event_deleted_flag => $event_deleted_flag });

$basic->rest_sleep();

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub check_order_event_topic_and_allow{

my $self = shift;
my $data = shift || (console "Not submit yet." && return 1 );
my $border_order = shift || 5;
my $community_id = $data->{'mixi_community_id'} || (warn && return());
my $event_id = $data->{'mixi_event_id'} || (warn && return());
my $type = shift || die;
my $community = new Mebius::Mixi::Community;
my $basic = $self->basic_object();
my($allow_flag);

my $forview_account_data = $basic->forview_account_data() || (warn "No found for view account." && return());
my $email = $forview_account_data->{'email'} || (warn "" && return());

	#if(time < $data->{'last_check_order_time'} + 1.5*60*60){
		#$basic->try_log($email,"Maybe event topic order is enough. Because I checked order recently.");
	#	console("Maybe event topic order is enough. Because I checked order recently.");
	#	return 0;
	#}

my $event_order = $community->event_order_at_list($community_id,$event_id,$email,$type);

	if(!$event_order || $event_order > $border_order){
		$allow_flag = 1;
		$basic->try_log($email,"Event order is $event_order / $border_order , not enough.");
	} else {
		$self->update_main_table({ target => $data->{'target'} , last_check_order_time => time });
		$basic->try_log($email,"Event order is $event_order / $border_order , it's enough.");
		$allow_flag = 0;
	}

$basic->rest_sleep();

$allow_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub upload_picture_directory{

my $self = shift;
my($directory);

	if(Mebius::alocal_judge()){
		$directory = "C:/Apache2.2/cgi-bin/navi-tomo/upload_picture/event/";
	} else {
		$directory = "/perl/mixi/upload_picture/event/";
	}

$directory;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_event_targets{

my $self = shift;
my $topic_type = shift;
my(@event_target);

my $event_hash_group = $self->useful_event_hash_group($topic_type);


	foreach my $event_target ( keys %{$event_hash_group}){
		push @event_target , $event_target;
	}

	if(@event_target <= 0){
		console "No event targets found.";
	}



@event_target;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_event_data_group{

my $self = shift;
my $topic_type = shift;
my $event = new Mebius::Mixi::Event;

my $fetch = $self->useful_event_fetch($topic_type);
my $data_group = $event->fetchrow_main_table_asc($fetch,"start_time",{ Debug => 0 });


$data_group;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_event_hash_group{

my $self = shift;
my $topic_type = shift;
my $event = new Mebius::Mixi::Event;

my $fetch = $self->useful_event_fetch($topic_type);
my $event_hash_group = $event->fetchrow_on_hash_main_table($fetch , "target" , { Debug => 0 } );

$event_hash_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_event_fetch{

my $self = shift;
my $topic_type = shift;
my $console = new Mebius::Console;
my(%fetch);

$fetch{'deleted_flag'} = 0;

	if($topic_type eq "topic"){
		$fetch{'end_time'} = [">",time];
		$fetch{'topic_auto_submit_flag'} = 1;

	} elsif($topic_type eq "event"){
		$fetch{'event_auto_submit_flag'} = 1;
	}

	if($console->option("-preview")){
		$fetch{'submit_doing_flag'} = 1;
	}

\%fetch;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub auto_submit_roop{

my $self = shift;
my $topic_type = shift || die;
my $submit_type = shift || die;
my $basic = $self->basic_object();
my $task = new Mebius::Mixi::Task;


	while(1){

			if( my $left_time = $task->wait_time("${topic_type}_${submit_type}")){

				$self->check_all_old_submits($topic_type);

				$basic->sleep(60);

			} else {

					if($submit_type eq "post"){
						$self->auto_submit_post($topic_type,$submit_type);
					} elsif ($submit_type eq "comment"){
						$self->auto_submit_comments($topic_type,$submit_type);
					} elsif ($topic_type eq "overwrite_events"){
						$self->auto_overwrite_events();
					}

				console "Just wait before next doing.";
				$basic->sleep(10);

			}

	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub max_post_num_per_event{
9;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub auto_submit_post{

my $self = shift;
my $topic_type = shift || die;
my $submit_type = shift || die;
my $encoding = new Mebius::Encoding;
my $query = new Mebius::Query;
my $html = new Mebius::HTML;
my $event = new Mebius::Mixi::Event;
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my $mixi_account = new Mebius::Mixi::Account;
my $basic = $self->basic_object();
my $param  = $query->param();
my $task = new Mebius::Mixi::Task;
my($print,@all_message,$page_title,$task_interval_second,$max_submit_num_per_event);


console "EVENT/TOPIC POST START";

	if($topic_type eq "event"){
		$max_submit_num_per_event = 19;
		$task_interval_second = 6*60*60;
	} elsif($topic_type eq "topic"){
		$max_submit_num_per_event = 14;
		$task_interval_second = 3*60*60;
	}

	if(!$task->allow_task_judge("${topic_type}_${submit_type}") && console){
		return();
	}

my $hit = 0;

	if($param->{'preview'}){
		$page_title = "自動登録(プレビュー) $param->{'mode'}";
	} else {
		$page_title = "自動登録";
	}

console "[AUTO " . uc $submit_type . " " . uc $topic_type . " START]";
$basic->sleep(3);

my $event_data_group = $self->useful_event_data_group($topic_type);
my $event_data_num = @{$event_data_group};

console "$event_data_num EVENTS TRY.";

	foreach my $event_data (@{$event_data_group}){

		my($message);

		my $event_url = $event->data_to_url($event_data);
		my $title = e($event_data->{'title'});
		my $htag = $html->tag("h2",$title,"",{ href => $event_url });
		#my $event_data = $event->useful_event_data($event_data->{'target'});

		my $submit_count_data_group =  $self->fetchrow_main_table_desc({ submit_type => "post" , topic_type => $topic_type , event_target => $event_data->{'target'}  },"create_time");
		my $submited_num = @{$submit_count_data_group};

			if($submited_num >= $max_submit_num_per_event){
				console "Over max submit num per event. $submited_num / $max_submit_num_per_event ";
				$message .= e("イベント登録数が多いので、新規登録しません。 ${submited_num}個 / ${max_submit_num_per_event}個"); 
			} elsif( my @error = $self->event_data_to_escape_post($event_data,$topic_type)){
				console "Event skip.";
				console "@error";
				$message .= "@error"; 
			} else {

				my $result =  $self->foreach_community_and_submit_events($event_data,$topic_type,$submit_type);
	
					if($result eq "1"){
						$task->submit_next_time_tremor("${topic_type}_${submit_type}",$task_interval_second);
						return 1;
					} else {
						$message = $result;
					}

			}

		push @all_message , $htag .  "<ul>" . $message . "</ul>";

	}


$task->unlock("${topic_type}_${submit_type}");

	if(console){
		console "[AUTO " . uc $submit_type . " " . uc $topic_type . " FINISHED]";
	} elsif(!console){
		$print .= $self->submit_forms();
		$print .= join "<hr>" , @all_message;
		$basic->print_html($print,{ Title => $page_title , h1 => $page_title });
		exit;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub foreach_community_and_submit_events{

my $self = shift;
my $event_data = shift || return();
my $topic_type = shift;
my $submit_type = shift;
my $mixi_account = new Mebius::Mixi::Account;
my $community = new Mebius::Mixi::Community;
my $query = new Mebius::Query;
my $console = new Mebius::Console;
my $basic = $self->basic_object();
my $param  = $query->param();
my(@all_message,$count);

my $community_data_group = $community->fetchrow_main_table_desc({ use_flag => 1 , deleted_flag => 0 , block_flag => 0 },"total_member_num");


	foreach my $community_data (@{$community_data_group}){

		my($message,$result,$while_count);

		my $community_link = $community->community_data_to_link($community_data);

				for(1..1){

					my($temporary_result);

						if($topic_type eq "event" || $topic_type eq "topic"){
							$temporary_result = $self->submit_event_or_topic($event_data,$community_data,$topic_type);
						} else {
							die "Please set \$topic_type";
						}

						if($temporary_result eq "1"){
								$result = 1;
								last;
						} elsif($temporary_result eq "0"){
							$basic->failed_log("","Failed to submit event. So try again other account.");
							next;
						} else {
							$message = $temporary_result;
							last;
						}

				}

				if($result eq "1"){

						if($param->{'preview'}){
							$message = qq(<span style="color:#050;background:#afa;padding:0.1em 0.5em;">登録できそうです。\(プレビュー\)) ."</span>";;
						} else {
							return 1;
						}

				}


		push @all_message , "<li>" . "$community_link : " . $message . "</li>";

	}


"@all_message";

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_event_or_topic{

my $self = shift;
my $event_data = shift || (warn && return());
my $community_data = shift || (warn && return());
my $topic_type = shift;
my $community = new Mebius::Mixi::Community;
my $mixi_account = new Mebius::Mixi::Account;
my $event = new Mebius::Mixi::Event;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $console = new Mebius::Console;
my $basic = $self->basic_object();
my $param  = $query->param();
my(%input,@message,$succeed_flag,$event_kind_number,$event_edit_flag,$submit_type);

my $community_id = $community_data->{'id'} || (warn && return());
my $event_target = $event_data->{'target'} || (warn && return());

# When comment to common topic only , Do not create new topic
my $comment_topic_event_id = $community_data->{'commment_topic_event_id'};
	#if($comment_topic_event_id){
	#	$submit_type = "comment";
	#} else {
		$submit_type = "post";
	#}

my $submited_data_group =  $self->fetchrow_main_table_desc({ submit_type => $submit_type , topic_type => $topic_type , mixi_community_id => $community_id , event_target => $event_target },"create_time");
my $submit_data = my $submit_data_exists = $submited_data_group->[0];

	if($submit_data->{'event_deleted_flag'}){
		push @message , qq(<span style="color:red;">トピック/イベントが削除済みです。</span>);
	}

	if($submit_data_exists && !$console->option("all") && !$param->{'all'}){

			if($topic_type eq "topic"){

					if($submit_type eq "comment"){

					} else {
						push @message , qq(登録済みです。);
					}
			} elsif($topic_type eq "event"){
					push @message , qq(登録済みです。);

			} elsif($topic_type eq "overwrite"){

			}

	} elsif( my @error = $self->some_data_to_escape_submit_event($submit_data,$event_data,$community_data,$topic_type,$submit_type)){
		console "Skip submit $topic_type.";
		push @message , @error;
	}

	if(@message){
		return "@message";
	}
	if($param->{'preview'}){
		return "1";
	}

console || die;

	if($event_edit_flag){
		console "EDIT EVENT";
		$self->edit_event($submit_data);
		console "EDIT DONE";
		exit;
	}

my $account_data = my $account_data_exists = $mixi_account->useful_account_data();
my $account = $account_data->{'account'}; # || return()
my $email = $account_data->{'email'} || return();
my $new_target = $self->new_target();

	if(!$account_data_exists){
		warn "No useful accounts";
		return();
	}

	if($basic->lock($email)){
		return();
	}

# JOIN COMMUNITY
my $succedd_join_community = $community->join_community($community_id,$email);
	if(!$succedd_join_community){
		return("Can not join to community.");
	}

	if($topic_type eq "event"){
		$succeed_flag = $self->submit_event($account_data,$event_data,$community_id,$topic_type,$event_kind_number);
	} elsif($topic_type eq "topic"){
				# comment to other man's topic, Because community master deny create new topic
				#if($comment_topic_event_id){
				#	$succeed_flag = $self->comment_to_topic({ mixi_community_id => $community_id , mixi_event_id => $comment_topic_event_id },$account_data,$event_data,{ event_on_comment_flag => 1 });
				#} else {
					$succeed_flag = $self->submit_topic($account_data,$event_data,$community_id,$topic_type,$event_kind_number);
				#}
	}

$basic->logout($email);

$basic->unlock($email);

$succeed_flag;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_event_with_schedule{

my $self = shift;
my $event = new Mebius::Mixi::Event;
my $community = new Mebius::Mixi::Community;
my $mixi_account = new Mebius::Mixi::Account;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $task = new Mebius::Mixi::Task;
my $param  = $query->param();
my $basic = $self->basic_object();

my $task_interval_second = 30*60;
my $task_name = "edit_event";

	if(!$task->allow_task_judge($task_name)){
		return();
	}

#my @event_target = $self->useful_event_targets();
my $event_hash_group = $event->fetchrow_on_hash_main_table({ event_auto_submit_flag => 1 , submit_doing_flag => 1 , deleted_flag => "0" },"target");

my $data_group = $self->fetchrow_main_table_asc({ submit_type => "post" , topic_type => "event" , event_deleted_flag => 0 , create_time => [">=",1416029734 - 3*24*60*60] },"create_time");
my $data_num = @{$data_group};

console "EVENTS EDIT WITH SCHEDULE START";
console "$data_num EVENTS TRY.";

	foreach my $data (@{$data_group}){

		my($message,$result);

			if(!$data->{'event_target'}){
				next;
			}

			console "Event target $data->{'event_target'}";

		my $event_data = $event_hash_group->{$data->{'event_target'}};
		$event_data = $event->useful_event_data_with_refresh($event_data);

			if( my @error = $self->event_data_to_escape_post($event_data,"event")){
				console "@error";
				console "Skip";
				next;
			} elsif($event_data->{'schedule_target'} eq $data->{'schedule_target'}){
				console "This event [$event_data->{'schedule_target'}]  has already edited.";
				next;
			}

		my $event_url = $self->data_to_event_topic_url($data);

		my $result = $self->edit_event($data);

			if($result eq "1"){

				$task->submit_next_time_tremor($task_name,$task_interval_second);
				last;

			} 
	}

console "EVENTS EDIT WITH SCHEDULE, FINISHED.";

$task->unlock($task_name);
exit;



}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_event{

my $self = shift;
my $submit_data = shift || return();
my $mixi_account = new Mebius::Mixi::Account;
my $event = new Mebius::Mixi::Event;
my $community = new Mebius::Mixi::Community;
my $basic = $self->basic_object();
my(@message,$succeed_flag);

	if($submit_data->{'event_deleted_flag'}){
		$basic->failed_log("Event is already deleted.");
		return 0;
	}

my $account_data = $mixi_account->fetchrow_main_table({ account => $submit_data->{'account'} })->[0];
my $account_name = $account_data->{'account'};

my $event_data = $event->fetchrow_main_table({ target => $submit_data->{'event_target'} })->[0];
my $edit_schedule_target = $event_data->{'schedule_target'} || warn("Schedule target is empty");

my $community_data = $community->fetchrow_main_table({ id => $submit_data->{'mixi_community_id'} })->[0];
my $email = $account_data->{'email'} || die("Account e-mail is empty.");

	# IF IN PAST, EVENT POSTED ACCOUNT IS NOW DENIED
	if($account_data->{'status'}){
		$basic->failed_log($email,"This account is already $account_data->{'status'}. Can not edit.");
		$self->update_main_table({ target => $submit_data->{'target'} , schedule_target => $edit_schedule_target });
		return();
	}

my $event_url = $self->data_to_event_topic_url($submit_data);
my $event_html = $basic->get($event_url,$email);

	if($self->topic_no_data_to_update($event_html,$submit_data)){
		$basic->failed_log($email,"Event is already deleted. $event_url ",$event_html);
		return();
	}elsif($event_html =~ m!開催場所!){
		$basic->succeed_log($email,"View event topic. $event_url ",$event_html);
	} else {
		$basic->failed_log($email,"Can not view event topic. $event_url ",$event_html);
		return();
	}

$basic->input_sleep();

my %input_common = %{$self->event_data_to_input_data($event_data)};

$input_common{'submit'} = "main";
$input_common{'comm_id'} = $submit_data->{'mixi_community_id'};
$input_common{'id'} = $submit_data->{'mixi_event_id'};

my %input_for_preview = my %input_for_submit = %input_common;

my $url = "http://mixi.jp/edit_event.pl";

$basic->try_log($email,"Edit event.");

# PREVIEW
my $preview_html = $basic->post($url,$account_data->{'email'},\%input_for_preview,{ referer => $event_url });

	if(!$preview_html){
		$basic->failed_log($email,"Can not preview event topic. $event_url",$preview_html);
		return();
	} else {
		$basic->succeed_log($email,"Preview event topic for edit. $event_url",$preview_html);
	}

$basic->preview_sleep();

# PREVIEW
$input_for_submit{'submit'} = "confirm";
$input_for_submit{'post_key'} = $basic->html_to_post_key($preview_html,$email);
my $submited_html = $basic->post($url,$account_data->{'email'},\%input_for_submit,{ referer => $url });

	if($submited_html =~ /編集が完了しました/){
		$basic->finished_log($email,"Edited event. $event_url ",$submited_html);
		$succeed_flag = 1;

			$self->update_main_table({ target => $submit_data->{'target'} , last_edit_time => time , schedule_target => $edit_schedule_target });
			$self->insert_main_table({ event_target => $submit_data->{'event_target'} , email => $email , account => $account_name , submit_type => "edit" , topic_type => "event" , mixi_community_id => $submit_data->{'mixi_community_id'} , mixi_event_id => $submit_data->{'mixi_event_id'}  });

	} else {
		$succeed_flag = 0;
		$basic->failed_log($email,"Can not edit event. $event_url ",$submited_html);
		push @message , "編集できませんでした。";
	}

$basic->rest_sleep();

$succeed_flag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_topic{

my $self = shift;
my $account_data = shift;
my $event_data = shift;
my $community_id = shift;
my $topic_type = shift || die;
my $event_kind_number = shift;
my $basic = $self->basic_object();
my $event = new Mebius::Mixi::Event;
my $mixi_account = new Mebius::Mixi::Account;
my($flag,%input_preview);

my $account = $account_data->{'account'};
my $email = $account_data->{'email'} || (warn && return());
my $event_target = $event_data->{'target'} || (warn && return());

#my $bbs_body = $event->text_to_bbs_body($event_data->{"bbs_body$event_kind_number"},$event_data,$event_kind_number) || die "BBS body is empty.";
#my $title = $event->effect($event_data->{"title$event_kind_number"},$event_data,$event_kind_number) || die "Title is empty.";

my $bbs_body = $event->text_to_bbs_body($event_data->{'bbs_body'},$event_data) || die "BBS body is empty";
my $title = $event->effect($event_data->{'title'},$event_data) || die "Title is empty";

my $new_target = $self->new_target();


my $first_form_url = "http://mixi.jp/add_bbs.pl?id=$community_id";
my $first_form_html = $basic->get($first_form_url,$email,{ referer => "http://mixi.jp/view_community.pl?id=$community_id" });

	if($first_form_html){
		$basic->succeed_log($email,"Access to new form of event topic.",$first_form_html);
	} else {
		$basic->failed_log($email,"Can not access to new form of event topic.",$first_form_html);
		return();
	}


$input_preview{'submit'} = "main";
$input_preview{'bbs_title'} = $title;
$input_preview{'bbs_body'} = $bbs_body;
#$input_preview{'photo1'} = [];
#$input_preview{'photo1'} = [];
#$input_preview{'photo1'} = [];

$basic->input_sleep();

my $preview_url = "http://mixi.jp/add_bbs.pl?id=$community_id";
my $preview_html = $basic->post($preview_url,$email,\%input_preview,{ referer => $first_form_url });
my $post_key = $basic->html_to_post_key($preview_html,$email);

	if($post_key){
		$basic->succeed_log($email,"Preview topic. $preview_url ",$preview_html);
	} else {
		$basic->failed_log($email,"Can not preview topic. $preview_url ",$preview_html);
		return();
	}


my %input_submit = %input_preview;

	if($preview_html =~ m!<input type="hidden" name="packed" value="([^"]+)" />!){
		$input_submit{'packed'} = $1;
	} else {
		$input_submit{'packed'} = "";
	}

$input_submit{'post_key'} = $post_key || die;
$input_submit{'submit'} = "confirm";

$basic->preview_sleep();

my $submit_url = $preview_url;
my $submit_html = $basic->post($submit_url,$email,\%input_submit,{ referer => $preview_url });
my $mixi_event_id = $self->submited_html_to_event_id($submit_html);

	if($mixi_event_id){

		$self->insert_main_table({ event_target => $event_target , email => $email , account => $account , submit_type => "post" , topic_type => $topic_type , mixi_community_id => $community_id , mixi_event_id => $mixi_event_id , event_kind_number => $event_kind_number });

		# ACCOUNT DATA UPDATE
		$mixi_account->account_data_to_one_action_plus($account_data);

		$basic->finished_log($email,"Submited topic. ",$submit_html);

	} else {
		$basic->failed_log($email,"Can not submit topic. ",$submit_html);
		return();
	}

$basic->rest_sleep();

1;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_event{

my $self = shift;
my $account_data = shift;
my $event_data = shift;
my $community_id = shift;
my $topic_type = shift || die;
my $event_kind_number = shift;
my $basic = $self->basic_object();
my $mixi_account = new Mebius::Mixi::Account;
my $event = new Mebius::Mixi::Event;
my($flag);

my $account = $account_data->{'account'};
my $email = $account_data->{'email'} || (warn && return());
my $event_target = $event_data->{'target'} || (warn && return());

my $new_target = $self->new_target();

my $first_form_url = "http://mixi.jp/add_event.pl?id=$community_id";
my $first_form_html = $basic->get($first_form_url,$email,{ referer => "http://mixi.jp/view_community.pl?id=$community_id" });

	if($first_form_html){
		$basic->succeed_log($email,"Access to new form of event topic.",$first_form_html);
	} else {
		$basic->failed_log($email,"Can not access to new form of event topic.",$first_form_html);

	}

$basic->rest_sleep();


my %input_for_preview = %{$self->event_data_to_input_data($event_data,$event_kind_number)};
$input_for_preview{'submit'} = "main";
$input_for_preview{'id'} = $community_id;

# PREVIEW
my $preview_url = "http://mixi.jp/add_event.pl";
my $preview_html = $basic->post($preview_url,$email,\%input_for_preview,{ referer => $first_form_url });

	if($preview_html){
		$basic->succeed_log($email,"Post data and view 	preview page.",$preview_html);
	} else {
		$basic->failed_log($email,"Can not access to preview page.",$preview_html);
		return("プレビューページにアクセス出来ませんでした。");
	}

$basic->input_sleep();

# POST
my %input_submit = %input_for_preview;
$input_submit{'post_key'} = $basic->html_to_post_key($preview_html,$email);
$input_submit{'mode'} = "main";
$input_submit{'submit'} = "confirm";

my $submit_url = $preview_url;
my $submited_html = $basic->post($submit_url,$email,\%input_submit,{ referer => $preview_url });
my $mixi_event_id = $self->submited_html_to_event_id($submited_html);# || return("投稿後のページでイベントIDが取得出来ませんでした。");

	if($mixi_event_id){

		$flag = 1;

		# SUBMIT EVENT DATA UPDATE
		$self->insert_main_table({ target => $new_target , event_target => $event_target , email => $email , account => $account , submit_type => "post" , topic_type => $topic_type , mixi_community_id => $community_id , mixi_event_id => $mixi_event_id , event_kind_number => $event_kind_number , schedule_target => $event_data->{'schedule_target'} });

		# ACCOUNT DATA UPDATE
		$mixi_account->account_data_to_one_action_plus($account_data,{ keep_job => "event_post" });

		$basic->finished_log($email,"Submited event.",$submited_html);

	} else {

		$flag = 0;
		$basic->failed_log($email,"Can not submit event.",$submited_html);



	}


$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub effective_event_kind_number{

my $self = shift;
my $event_data = shift || die;
my $event = new Mebius::Mixi::Event;
my $basic = $self->basic_object();
my(@effective_number,@error);

my @event_kind_number = $event->event_kind_numbers($event_data);
my $event_kind_all_num = @event_kind_number;
my $max_post_num_per_event = $self->max_post_num_per_event();

	foreach my $event_kind_number (@event_kind_number){

		my $submit_data_group = $self->fetchrow_main_table({ event_target => $event_data->{'target'} , submit_type => "post" , event_kind_number => $event_kind_number });
		my $submited_num = @{$submit_data_group};

			if($submited_num >= $max_post_num_per_event){
				#push @error , e("イベント$event_kind_number / $event_kind_all_num - 既に多く投稿しています。 $submited_num / $max_post_num_per_event ");
				console "$event_kind_number is still posted over border num. $submited_num / $max_post_num_per_event";
			} else {
				push @effective_number , $event_kind_number;
			}
	}

	if(@effective_number <= 0){
		push @error , e("有効なイベントが見つかりません。");
		console "No effective event number found.";
	}

my $event_kind_number_decide = $effective_number[int rand(@effective_number)] || die;

	if(@error >= 1){
		return @error;
	} else {
		return $event_kind_number_decide;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub early_morning_or_midnight{

my $self = shift;
my $times = new Mebius::Time;
my($flag);

my $this_hour = $times->hour(time);

	if($this_hour >= 2 && $this_hour < 6){
		$flag = 1;
		console "It's early morning or midnight.";
	}

$flag;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_before_comments_on_event_or_topic{

my $self = shift;
my $mixi_community_id = shift || (warn("") && return());
my $mixi_event_id = shift || (warn("") && return());
my $topic_type = shift || (warn("") && return());
my $exclution_target = shift;
my $community = new Mebius::Mixi::Community;

my %fetch = ( submit_type => "comment" , mixi_community_id => $mixi_community_id , mixi_event_id => $mixi_event_id , comment_deleted_flag => 0 );

console "Community $mixi_community_id - Event $mixi_event_id - Exclution target $exclution_target";

	if($exclution_target){
		$fetch{'target'} => ["<>",$exclution_target];
	}

my $before_comment_data_group = $self->fetchrow_main_table(\%fetch);
my $num = @{$before_comment_data_group};

console "Try to delete $num comments on  $topic_type.";

	foreach my $submit_data (@{$before_comment_data_group}){
		my $email = $submit_data->{'email'} || next;
		$community->delete_all_comments_on_event_or_topic($email,$mixi_community_id,$mixi_event_id,$topic_type,$submit_data);
	}



}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topic_no_data_to_update{

my $self = shift;
my $html = shift || (warn && return());
my $submit_data = shift || (warn && return());
my($deleted_flag);

	if($html =~ m!<p class="messageAlert">データがありません!){
		console "No data to update table.";
		$self->update_main_table({ target => $submit_data->{'target'} , event_deleted_flag => time , forced_event_deleted_flag => time });
	}

$deleted_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_event_topic_url{

my $self = shift;
my $data = shift;
my $community = new Mebius::Mixi::Community;
my($url);

	if($data->{'topic_type'} eq "event"){
		$url = $community->event_url($data->{'mixi_community_id'},$data->{'mixi_event_id'});
	} elsif($data->{'topic_type'} eq "topic"){
		$url = $community->topic_url($data->{'mixi_community_id'},$data->{'mixi_event_id'});
	}


$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_data_to_decide_comment_message{

my $self = shift;
my $event_data = shift || (warn("") && return());
my $account_data = shift || (warn("") && return());
my $times = new Mebius::Time;
my $event = new Mebius::Mixi::Event;
my(@message);

my $start_time = $event_data->{'start_time'};
my $how_after = $times->how_after($start_time);

	if(time > $start_time - 3*24*60*60 ){
		push @message , qq(イベントが近づいてきました。よろしくお願いします[mark] [face] \n\n 受付・お問い合せはこちらまでどうぞ < [contact] > [mark] );
	}

push @message , qq([mark] 当日間際だと参加枠が埋まってしまう場合が多いです。行き違いになったらすいません (>_<) \n\n 受付・お問い合せはこちらまでどうぞ < [contact] > [mark] [face]);
push @message , qq(参加のご希望、お問い合わせがありましたら、受付スタッフ < [contact] > までお願いします [mark] [face] );

my $message = $message[int rand(@message)];
$message .= "$account_data->{'nickname'}より"."\n";

$message = $event->effect($message,$event_data);

$message;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_edit_events{

my $self = shift;

my $event_data_group = $self->useful_event_data_group();

	foreach my $event_data (@{$event_data_group}){

		my $data_group = $self->fetchrow_main_table_asc({ submit_type => "post" , event_target => $event_data->{'target'} },"create_time");

			if(!$event_data->{'edit_decide_time'}){
				console "Event skip.";
			}

			foreach my $data (@{$data_group}){
					if($data->{'topic_type'} ne "event"){
						console "This is not event , next.";
					} elsif($event_data->{'edit_decide_time'} > $data->{'last_edit_time'}){
						my $succeed_flag = $self->edit_event($data);
					} else {
						console "Skip.";
					}
			}

	}

exit;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_data_to_input_data{

my $self = shift;
my $event_data = shift;
my $event_kind_number = shift;
my $event = new Mebius::Mixi::Event;
my $times = new Mebius::Time;

#my $bbs_body = $event->text_to_bbs_body($event_data->{"bbs_body$event_kind_number"},$event_data,$event_kind_number) || die "BBS body is empty";
#my $title = $event->effect($event_data->{"title$event_kind_number"},$event_data,$event_kind_number) || die "Title is empty";

my $bbs_body = $event->text_to_bbs_body($event_data->{'bbs_body'},$event_data) || die "BBS body is empty";
my $title = $event->effect($event_data->{'title'},$event_data) || die "Title is empty";

my $start_year = $times->year($event_data->{'start_time'});
my $start_month = $times->month($event_data->{'start_time'});
my $start_day = $times->day($event_data->{'start_time'});

my $deadline_year = $times->year($event_data->{'deadline_time'});
my $deadline_month = $times->month($event_data->{'deadline_time'});
my $deadline_day = $times->day($event_data->{'deadline_time'});

my %input = (
title => $title , 
start_year => $start_year,
start_month => $start_month ,
start_day => $start_day  ,
deadline_year => $deadline_year || $start_year ,
deadline_month => $deadline_month || $start_month ,
deadline_day => $deadline_day || $start_day ,
location_pref_id => $event_data->{'location_pref_id'},
bbs_body => $bbs_body,
 );

\%input;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_topics{

my $self = shift;
my $event = new Mebius::Mixi::Event;

my $event_data_group = $event->fetchrow_main_table({});


}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_all_finished_event{

my $self = shift;
my $type = shift || die;
my $event = new Mebius::Mixi::Event;
my $community = new Mebius::Mixi::Community;

console "[DELETE ALL FINISHED EVENT START]";

my $event_data_group = $event->fetchrow_main_table({ end_time => ["<",time] });
my $event_data_num = @{$event_data_group};

console "$event_data_num EVENTS CHECK.";

	foreach my $event_data (@{$event_data_group}){

		my $data_group = $self->fetchrow_main_table({ submit_type => "post" , topic_type => $type , event_target => $event_data->{'target'} , event_deleted_flag => 0 });
		my $data_num = @{$data_group};
		console "$data_num RELATION TOPICS/EVENTS CHECK";

			foreach my $data (@{$data_group}){
				my $delete_suceed_flag = $community->delete_event_or_topic($data->{'email'},$data->{'mixi_community_id'},$data->{'mixi_event_id'},$data->{'topic_type'});
					if($delete_suceed_flag){
						$self->update_main_table({ target => $data->{'target'} , event_deleted_flag => 1 });
					}
			}


	}


console "[ALL FINISHED EVENT FINISHED]";

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_data_to_escape_post{

my $self = shift;
my $event_data = shift;
my $topic_type = shift || die;
my $times = new Mebius::Time;
my(@message,@console);

	#if($event_data->{'title'} eq ""){ push @message , qq(イベントタイトルが登録されていません。); push @console , "Event title is empty."; }
	#if($event_data->{'bbs_body'} eq ""){ push @message , qq(イベント本文が登録されていません。); push @console , "Event text body is empty."; }

	#if(!$event_data->{'start_year'}){ push @message , qq(イベント開始年が登録されていません。);  push @console , "Event start year is empty.";  }
	#if(!$event_data->{'start_month'}){ push @message , qq(イベント開始月が登録されていません。);  push @console , "Event start month is empty.";  }
	#if(!$event_data->{'start_day'}){ push @message , qq(イベント開始日が登録されていません。);  push @console , "Event start day is empty.";  }
	#if(!$event_data->{'start_hour'}){ push @message , qq(イベント開始時間が登録されていません。); push @console , "Event start hour is empty.";  }
	#if($event_data->{'start_minute'} eq ""){ push @message , qq(イベント開始分が登録されていません。); push @console , "Event start minute is empty."; }

	if(!$event_data->{'start_time'}){
		push @message , qq(イベント開始時刻が設定出来ていません。);
		push @console , "Event start time is empty.";
	}
	if(!$event_data->{'end_time'}){
		push @message , qq(イベント終了時刻が設定出来ていません。);
		push @console , "Event end time is empty.";
	}
	if(!$event_data->{'deadline_time'}){
		push @message , qq(イベント締切時刻が設定出来ていません。);
		push @console , "Event deadline time is empty.";
	}

	#if(!$event_data->{'deadline_year'}){ push @message , qq(イベント募集期限の年が登録されていません。); push @console , "Event deadline year is empty."; }
	#if(!$event_data->{'deadline_month'}){ push @message , qq(イベント募集期限の月が登録されていません。); push @console , "Event deadline month is empty."; }
	#if(!$event_data->{'deadline_day'}){ push @message , qq(イベント募集期限の日が登録されていません。); push @console , "Event deadline day is empty."; }
	
	if(!$event_data->{'submit_doing_flag'} && console()){
		#push @message , qq(登録対象になっていません。イベント編集画面で変更できます。);
		push @console , "This topic/event is not target for submit. ";
	}

	if(!$event_data->{"${topic_type}_auto_submit_flag"}){
		push @message , qq(イベントが登録対象になっていません。イベント編集画面で変更できます。);
		push @console , "This event is not target for submit. ";
	}

	if($topic_type eq "event" && time < $event_data->{'start_time'} - 7*24*60*60){
		push @console , "This event is too fast to submit.";
		push @message , "イベントを登録するには早すぎます。";
	} elsif($topic_type eq "topic" && time < $event_data->{'start_time'} - 7*24*60*60){
		push @console , "This topic is too fast to submit.";
		push @message , "トピックを登録するには早すぎます。";
	} elsif($event_data->{'end_time'} && time >= $event_data->{'end_time'}){
		push @console , "This event was still finished.";
		push @message , "イベント/トピックが終了してます。";
	} elsif($event_data->{'end_time'} && time > $event_data->{'end_time'} - 2*60*60){
		push @console , "This event was still started.";
		push @message , "イベント/トピックが終了間際です。";
	}

	# elsif($event_data->{'start_time'} && time > $event_data->{'start_time'} - 30*60){
	#	push @console , "This even't start time is ready to.";
	#	push @message , "イベント開始がもうすぐです。";
	#}

	if(console){
		return @console;
	} else {
		return @message;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub some_data_to_escape_submit_event{

my $self = shift;
my $submit_data = my $submit_data_exists = shift;
my $event_data = shift || die;
my $community_data = shift || die;
my $topic_type = shift || (warn("") && return());
my $submit_type = shift || (warn("") && return());
my $console = new Mebius::Console;
my $query = new Mebius::Query;
my $times = new Mebius::Time;
my $param  = $query->param();
my(@message,$min_border_community_member_num);

my $border_hour = 6;

my $community_id = $community_data->{'id'} || (warn && return());

my $event_data_desc_on_community = $self->fetchrow_main_table_desc({ submit_type => $submit_type  , mixi_community_id => $community_id },"create_time")->[0];

	if($topic_type eq "event"){

		$min_border_community_member_num = 3000;

			#if($self->early_morning_or_midnight()){
			#	push @message , "深夜・早朝のため登録しません。";
			#}

	} elsif($topic_type eq "topic"){

		$min_border_community_member_num = 5000;

			if($submit_type eq "post"){

					if($community_data->{'allow_submit_topic_flag'} ne "1"){
						push @message , qq(トピック登録対象外です。);
					}

			} elsif($submit_type eq "comment"){

					if(!$community_data->{'comment_topic_event_id'}){
						push @message , qq(コメント対象のトピックが設定されていません。);
					}

			}
	}

	if(time < $submit_data->{'create_time'} + 6*60*60){ #  && $topic_type eq "overwrite" 
		push @message , qq(前に同じイベントを登録したばかりです。);
	}	elsif(time < $event_data_desc_on_community->{'create_time'} + 1*60*60){
		push @message , qq(このコミュニティには前に他のイベントを登録したばかりです。);
	}

	if($community_data->{'id'} eq ""){
		push @message , qq(コミュニティIDが登録されていません。);
	} elsif($community_data->{'total_member_num'} < $min_border_community_member_num){
		push @message , qq(コミュニティ参加人数が少なすぎます。);
	} elsif($community_data->{'low_age'} && $event_data->{'low_age'} && $community_data->{'low_age'} < $event_data->{'low_age'}){
		push @message , "対象外の年齢です。(下)";
	} elsif($community_data->{'high_age'} && $event_data->{'high_age'} && $community_data->{'high_age'} > $event_data->{'high_age'}){
		push @message , "対象外の年齢です。(上)";
	} elsif($community_data->{'weekday'} && $community_data->{'weekday'} ne "all" && $community_data->{'weekday'} ne $event_data->{'weekday'}){
		push @message , "対象外の曜日です。";
	} elsif($self->location_pref_error($community_data->{'location_pref_id'},$event_data->{'location_pref_id'})){
		push @message , "対象外の地域です。";		
	} elsif($community_data->{'sex_target'} && $community_data->{'sex_target'} ne $event_data->{'target'}){
		push @message , "対象外の性別です。";		
	} elsif($community_data->{'event_kinds'} && $community_data->{'event_kinds'} ne $event_data->{'event_kinds'}){
		push @message , "対象外のイベントタイプです。";		
	}


push @message , $self->event_data_to_escape_post($event_data,$topic_type);

@message;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub location_pref_error{

my $self = shift;
my $community_location_pref_id = shift || return();
my $event_location_pref = shift || return();
my($hit_flag,$error_flag);

my @event_pref_id = split(/,/,$event_location_pref);

	foreach my $pref_id (@event_pref_id){
			if($pref_id eq $community_location_pref_id){
				$hit_flag = 1;
				last;
			}
	}

	if(!$hit_flag){
		$error_flag = 1;
	}

$error_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub location_pref_to_error{

my $self = shift;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submited_html_to_event_id{

my $self = shift;
my $html = shift || return();
my($event_id);


	if($html =~ m! href="(?:http://mixi.jp/)?view_(?:event|bbs)\.pl\?id=([0-9]+)&comm_id=([0-9]+)"!){ # 作成したイベントへ
		$event_id = $1;
	} elsif($html =~ m! href="(?:http://mixi.jp/)?view_(?:event|bbs).pl\?comm_id=(?:[0-9]+)&id=([0-9]+)"!){
		$event_id = $1;
	} elsif($html =~ m!<p class="messageAlert">作成が完了しました。!){
		$event_id = 1; #Temporary writing
	}

$event_id;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift || return();
my $use = shift || {};
my $html = new Mebius::HTML;
my $community = new Mebius::Mixi::Community;
my $query = new Mebius::Query;
my $times = new Mebius::Time;
my $basic = $self->basic_object();
my $param  = $query->param();
my($print);

my $community_data = $use->{'community_data'} || {};
my $event_data = $use->{'event_data'} || {};

$print .= qq(<li>);

my $event_url = $self->data_to_event_topic_url($data);
#$print .= $basic->mixi_href($event_url) . "\n";
$print .= $html->href($event_url) . "\n";

	if(!$param->{'view_only_url'}){
		#$print .= e($data->{'mixi_community_id'}) . "\n";

			if($data->{'account'}){
				$print .= $html->href("http://mixi.jp/show_friend.pl?id=$data->{'account'}",$data->{'account'}) . "\n";
			}

		$print .= $html->href("?mode=per_account_view&type=email&target=$data->{'email'}",$data->{'email'}) . "\n";

		$print .= $html->href("?mode=submit_event&target=$data->{'event_target'}",$data->{'event_target'}) . "\n";
		$print .= e($data->{'submit_type'}) . "\n";
		$print .= e($data->{'topic_type'}) . "\n";

		$print .= $times->how_before($data->{'create_time'}) . "\n";
		$print .= $times->how_before($data->{'last_check_alive_time'}) . "\n";

			if($data->{'event_deleted_flag'}){
				$print .= $html->tag("span","イベント削除済み",{ style => "color:red;" } ) . "\n";
			}

			if($data->{'comment_deleted_flag'}){
				$print .= $html->tag("span","コメント削除済み",{ style => "color:red;" } ) . "\n";
			}

	}



$print .= qq(</li>);

$print;

}





#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub community_id_to_event_list_ids{

my $self = shift;
my $community_id = shift || return();
my $basic = $self->basic_object();
my $mixi_account = new Mebius::Mixi::Account;
my(@event_id);

my $account_data = $mixi_account->random_limited_account_data();
my $account = $account_data->{'account'};
my $mixi_url = $basic->mixi_url();

my $event_list_url = "http://mixi.jp/list_bbs.pl?type=event&id=$community_id";
my $event_list_html = $basic->get($event_list_url,$account);

	while($event_list_html =~ s!http://mixi.jp/view_event\.pl\?comm_id=(?:[0-9]+)&id=([0-9]+)!!){
		push @event_id , $1;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub community_url_to_event_redun_check{

my $self = shift;

my $border_time = time - 7*24*60*60;
my $data_group = $self->fetchrow_main_table({ create_time => [">",$border_time] });

}



1;
