
use strict;
package Mebius::Status;
use Mebius::Crypt;
use base qw(Mebius::Base::DBI);

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
sub main_table_name{
"status";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $column = {

target => { PRIMARY => 1 } , 

content_typeA => {} ,
content_typeB => {} ,
content_typeC => {} ,

content_targetA => {} ,
content_targetB => {} ,
content_targetC => {} ,

content_create_time => { int => 1 , INDEX => 1 } ,

deleted_flag => { int => 1 } ,

last_response_target => { } , 
last_handle => { INDEX => 1 , other_names => { handle => 1  } } , 
last_account => { INDEX => 1 , other_names => {  } } , 
last_modified => { int => 1 , INDEX => 1 } , 
last_response_num => { int => 1 } , 

first_account => { INDEX => 1 } , 
first_handle => { INDEX => 1 } , 
hidden_from_feed_flag => { int => 1 } , 

subject => { INDEX => 1 } , 

};

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_data_group_for_feed_topics{

my $self = shift;
my $data_group = shift;
my $use = shift;
my(@adjusted_data_group,%still_account);

my @sorted_data_group = sort { $b->{'content_create_time'} <=> $a->{'content_create_time'} } @{$data_group};

	foreach my $data (@sorted_data_group){

			if(!Mebius::alocal_judge() && !$use->{'Index'}  && $still_account{$data->{'first_account'}}++){
				next;
			}

			if($data){
				push @adjusted_data_group , $data;
			}

	}

\@adjusted_data_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub renew_status{

my $self = shift;
my $where = shift || die;
my $insert = shift;
my %insert = %{$insert};
my $crypt = new Mebius::Crypt;
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my($data);

$insert{'last_modified'} ||= time;

	if($param->{'on_feed'} eq "0"){
		$insert{'hidden_from_feed_flag'} = 1;
	}

	if( $data = $self->fetchrow_main_table($where)->[0]){
		$insert{'target'} = $data->{'target'};
		$self->update_main_table(\%insert,{ Debug => 0 });
	} else {
		$insert{'target'} ||= $crypt->char(30);
		$self->insert_main_table(\%insert);
	}

$insert{'target'};


}





1;
