
use strict;
use Mebius::Text;
package Mebius::AllComments;
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
"all_comments";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $column = {
create_time => { int => 1 ,INDEX => 1 } ,
comment => { text => 1 } , 
last_update_time => { int => 1 } ,
};

$column;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub dupulication_error{

my $self = shift;
my $comment = shift;
my $text = new Mebius::Text;
my($error);

my $border_time = time - 30*60;

my $data_group = $self->fetchrow_main_table({ create_time => [">=",$border_time] });

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq()); }

	foreach my $data (@{$data_group}){


		if( $text->dupulication($comment,$data->{'comment'})){
			$error = 1;
			last;
		} else {
			0;
		}

	}

$error;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_new_comment{

my $self = shift;
my $new_comment = shift;

$self->insert_main_table({ comment => $new_comment });

	if(rand(1000) < 1){
		$self->delete_old_records_from_main_table();
	}


}






1;

