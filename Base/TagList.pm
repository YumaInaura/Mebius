
use strict;
package Mebius::Base::TagList;
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
sub limited_package_name{
"taglist";
}

#-----------------------------------------------------------
# カラム名
#-----------------------------------------------------------
sub main_table_column{

my $column = {

target => { PRIMARY => 1  } ,
title => { INDEX => 1 } ,
tag_num => { int => 1 } ,
last_modified => { int => 1 , INDEX => 1 } , 
create_time => { int => 1 , INDEX => 1 } , 
deleted_flag => { int => 1 } , 
};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $relation_object = $self->relation_object();

my $url = $relation_object->data_to_url(@_);
$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $data = shift || return();
my $use = shift;
my $html = new Mebius::HTML;
my($print);

	if( !$use->{'view_report_mode'} && (my $report_button = $self->report_button($data)) ){
		$print .= qq(<div class="right">);
		$print .= $report_button;
		$print .= qq(</div>);
	}
	
	if($use->{'view_report_mode'}){
		$print .= $self->data_to_h1_link($data);
	}
	
$print .= $self->data_to_control_parts($data);

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tag_names_to_update_or_insert{

my $self = shift;
my $tag_names = shift || return();
my $relation_object = $self->relation_object() || die;
my(%tag_kind);

	foreach my $tag_name (@{$tag_names}){

		my(%update);
		my $relation_data_group = $relation_object->fetchrow_main_table({ title => $tag_name });
		my $tag_num = $update{'tag_num'} = @{$relation_data_group} || 0;

		$update{'title'} = $tag_name;
		$update{'last_modified'} = time;

		my $data = $self->fetchrow_main_table({ title => $tag_name })->[0];

			if($data){
				$self->update_main_table(\%update,{ WHERE => { title => $tag_name } });
			} else {
				$update{'target'} = $self->new_target_char();
				$self->insert_main_table(\%update,{ WHERE => { title => $tag_name } });
			}
	}



}




1;