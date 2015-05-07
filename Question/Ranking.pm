
use strict;
use Mebius::Question;
package Mebius::Question::Ranking;
use base qw(Mebius::Base::DBI Mebius::Question);
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
sub sorted_data_group{

my $self = shift;
my(@adjusted_data_group);

my $data_group = $self->fetchrow_main_table({ all_good_num => [">=",10] });

	foreach my $data (@{$data_group}){
		my %adjusted_data = %{$data};
		my($def_good_num);

		my $def_good_num = $data->{'all_good_num'}-$data->{'all_bad_num'};
		my $good_percent = $def_good_num / $data->{'all_response_num'} if($data->{'all_response_num'}) ;
		$adjusted_data{'point'} = int($def_good_num * $good_percent);
		push @adjusted_data_group , \%adjusted_data;
	}

my @sorted_data_group = sort { $b->{'point'} <=> $a->{'point'} } @adjusted_data_group;

\@sorted_data_group;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub response_data_group_to_insert_main_table{

my $self = shift;
#my $response_data_group = shift;
my $response = new Mebius::Question::Response;
my(@insert,%per_account_data);

my $response_data_group = $response->fetchrow_main_table({});

	foreach my $response_data ( @{$response_data_group} ){
			if(!$response_data->{'deleted_flag'}){
				$per_account_data{$response_data->{'account'}}{'all_good_num'} += $response_data->{'good_num'};
			}
		$per_account_data{$response_data->{'account'}}{'all_bad_num'} += $response_data->{'bad_num'};
		$per_account_data{$response_data->{'account'}}{'all_response_num'} += 1;
	}

	foreach my $account ( keys %per_account_data ){
		my %data = %{$per_account_data{$account}};
		my(%insert);

		if($data{'all_response_num'}){
			my $good_percent = $data{'all_good_num'} / $data{'all_response_num'};
			#$data{'account'} = $insert{'account'} = $account;
			#$data{'point'} = int($data{'all_good_num'} * $good_percent);

			$insert{'account'} = $account;
			$insert{'all_good_num'} = $data{'all_good_num'};
			$insert{'all_bad_num'} = $data{'all_bad_num'};
			$insert{'all_response_num'} = $data{'all_response_num'};
		} else {

		}
		#push @data , \%data ;
		push @insert , \%insert;	
	}

	if(@insert){
		$self->delete_record_from_main_table();
		$self->insert_main_table(\@insert,{ Debug => 0 });
	}


}

#-----------------------------------------------------------
# 良回答者
#-----------------------------------------------------------
sub answerer_ranking_view{

my $self = shift;
my $response = new Mebius::Question::Response;
my $html = new Mebius::HTML;
my $title = "回答者ランキング";
my(%per_account_data,$print,@data);
my $sns_url = new Mebius::SNS::URL;
my $ranking = new Mebius::Question::Ranking;
my $sns_account = new Mebius::SNS::Account;
my($my_account) = Mebius::my_account();
my($hit,@insert);

my $inline_css .= qq(
.me{background:#ff7;}
);

my $max_view_line = 100;

	#if($my_account->{'master_flag'}){
	#	$ranking->response_data_group_to_insert_main_table();
	#}

my $ranking_data_group = $ranking->sorted_data_group();
my $adjusted_data_group = $sns_account->add_handle_to_data_group($ranking_data_group) || [];

	foreach my $hash (@{$adjusted_data_group}){

		my($class);

			if($my_account->{'id'} eq $hash->{'account'}){
				$class .= qq( me);
			}
		$hit++;
		$print .= $html->start_tag("li",{ id => "$hash->{'account'}" , class => $class });
		$print .= $sns_url->account_link($hash->{'account'},$hash->{'handle'},"QUESTION");
		$print .= e(qq( [ $hash->{'point'}p ] いいね $hash->{'all_good_num'} / いまいち $hash->{'all_bad_num'} / 回答 $hash->{'all_response_num'}));
		$print .= $html->close_tag("li",);
			if($hit >= $max_view_line){ 
				last;
			}
	}

	if($print){
		$print = qq(<ol>$print</ol>);
	}

$self->print_html($print,{ Title => $title , h1 => $title ,BCL => [$title] , inline_css => $inline_css });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"question_ranking";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"raning";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub use_push_bad{

my $response = new Mebius::Question::Response;
$response->use_push_bad();
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $column = {
account => { PRIMARY => 1 } , 
all_good_num => { int => 1 } , 
all_bad_num => { int => 1 } , 
all_response_num => { int => 1 } , 
};

$column;

}


1;
