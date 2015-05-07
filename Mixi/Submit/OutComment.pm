
package Mebius::Mixi::Submit::OutComment;

use Mebius::DBI;
use Mebius::Mixi::Community;
use Mebius::Mixi::Event;
use Mebius::Mixi::Submit::Comment;
use Mebius::Mixi::Account;

use Mebius::Export;

use strict;

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
my $comment = new Mebius::Mixi::Submit::Comment;
my $param  = $query->param();
my $mode = $ARGV[0];
my($flag);

	if($mode eq "outer_comment"){
		$self->doing();
	}

return $flag;
}


#-----------------------------------------------------------
# コメントを実行する （コミュニティを展開）
#-----------------------------------------------------------
sub doing{

my $self = shift;
my $dbi = new Mebius::DBI;

my $community = new Mebius::Mixi::Community;

# comment_topic_event_id レコードに値がある列
my $community_data_group = $dbi->fetch("SELECT * FROM `mixi_community` WHERE comment_topic_event_id <> ? AND comment_topic_event_id IS NOT NULL",['0']);

my $num = @$community_data_group;

console "OUT COMMENT START";
console "$num communities found.";

	# コミュニティを展開する
	foreach my $community_data (@{$community_data_group}){

		my @event_id = split ",", $community_data->{'comment_topic_event_id'};

			if(@event_id < 0){
				console "Target events not found, skip.";
			}

			foreach my $event_id (@event_id){
				console "Try submit, Community $community_data->{'id'} / Event $event_id";
				$self->foreach_events($community_data->{'id'},$event_id);
			}

	}

exit;

}


#-----------------------------------------------------------
# イベントデータを展開
#-----------------------------------------------------------
sub foreach_events{

my $self = shift;
my $mixi_community_id = shift || die("Community id is empty.");
my $mixi_event_id = shift || die("Event id is empty.");

my $useful_account = new Mebius::Mixi::Account::Useful;
my $comment = new Mebius::Mixi::Submit::Comment;
my $event = new Mebius::Mixi::Event;
my $comment = new Mebius::Mixi::Submit::Comment;
my $submit = new Mebius::Mixi::Submit;
my $mixi_account = new Mebius::Mixi::Account;
my $submit_event = new Mebius::Mixi::Submit;

my $event_data_group = $event->useful_data_group("topic");

	foreach my $event_data (@{$event_data_group}){

		console "Event target $event_data->{'target'}";

			# コメントが設定されていなければ何もしない
			if($event_data->{'comment_body'} eq ""){
				console "comment body is empty on event data.";
				next;
			}

			# イベント自体に問題がある場合は何もしない ( 開始時間を過ぎている場合など )
			if($submit->event_data_to_escape_post($event_data,"topic")){
				next;
			}

		my $comment_body = $event->effect($event_data->{'comment_body'},$event_data) || (warn("Comment body is empty.") && next);

		#my $account_data = $useful_account->useful_account_data() || next;
		#my $email = $account_data->{'email'};

		#	if(!keys %{$account_data}){ next; }

	#	$mixi_account->try($account_data);

		my $flag = $comment->submit(
			{ mixi_community_id => $mixi_community_id , mixi_event_id => $mixi_event_id },
			"topic",
			$event_data,
			{ comment => $comment_body , BeforeDelete => 1 }
		);

	}


}

1;
