
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
sub doing{

my $self = shift;
my $dbi = new Mebius::DBI;

my $community = new Mebius::Mixi::Community;

# comment_topic_event_id レコードに値がある列を展開
my $community_data_group = $dbi->fetch("SELECT * FROM `mixi_community` WHERE comment_topic_event_id <> ? AND comment_topic_event_id IS NOT NULL",['0']);

my $num = @$community_data_group;

console "OUT COMMENT START";
console "$num communities found.";

	# 該当のコミュニティを展開する
	foreach my $community_data (@{$community_data_group}){

		my @event_id = split ",", $community_data->{'comment_topic_event_id'};

			if(@event_id < 0){
				console "Target event not found, skip.";
			}

			foreach my $event_id (@event_id){
				console "Try submit, Community $community_data->{'id'} / Event $event_id";
				$self->events($community_data->{'id'},$event_id);
			}

	}

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub events{

my $self = shift;
my $mixi_community_id = shift || die("Community id is empty.");
my $mixi_event_id = shift || die("Event id is empty.");
my $mixi_account = new Mebius::Mixi::Account;

my $event = new Mebius::Mixi::Event;
my $comment = new Mebius::Mixi::Submit::Comment;

my $event_data_group = $event->useful_data_group("topic");

	foreach my $event_data (@{$event_data_group}){
		console "Event target $event_data->{'target'}";
		my $account_data = $mixi_account->useful_account_data_and_try();
		my $flag = $comment->topic({ mixi_community_id => $mixi_community_id , mixi_event_id => $mixi_event_id },$account_data,$event_data,{ and_delete_flag => 1 });
	}

}


1;
