
use strict;
package Mebius::Base::Post;
use Mebius::Export;

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_junction{

my $self = shift;
my($param) = Mebius::query_single_param();

	if($self->query_to_sitemap_view()){
		1;
	} elsif($self->query_to_sitemap_index_view()){
		1;
	} elsif($param->{'mode'} eq "search"){		$self->search_view();
	} elsif($param->{'mode'} eq "recently_core"){
		my $print = $self->recently_line();
		my $print = $self->print_html($print,{ ReturnLimitedPrint => 1 });
		print "Content-type:text/html\n\n";
		print $print;
		exit;
	}

0;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"post";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
my $self = shift;
my $main_limited_package_name = $self->main_limited_package_name() || die;
my $limited_package_name = $main_limited_package_name . "_post";
$limited_package_name;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {

target => { PRIMARY => 1 }  ,
title => { INDEX => 1 } , 

handle => { } , 

account => { } , 
cnumber => { } , 
addr => { }  ,
host => {  } , 
mobile_uid => { text => 1 } , 
user_id => { } , 

response_num => { int => 1 } , 
deleted_response_num => { int => 1 } , 

good_num => { int => 1 } , 
good_accounts => { text => 1 } ,
good_cnumbers => { text => 1 } ,
good_addrs => { text => 1 } ,

create_time => { int => 1 } , 
comment_num => { int => 1 } , 
last_modified => { int => 1 } , 

full_deleted_flag => { int => 1 } ,
deleted_flag => { int => 1 } ,
penalty_flag => { int => 1 } ,

};

$column;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub length_check{

my $self = shift;
my $check_param = shift;
my $param_title = shift || die;
my $min_border = shift || die ;
my $max_border = shift || die ;
my $text = new Mebius::Text;
my(@error);

my $character_num = $text->character_num_pure($check_param) || 0;
my $min_character_num = $text->character_num($check_param) || 0;

	if($min_character_num < $min_border){
		push @error , e($param_title) . qq(が短すぎます。).e($min_character_num).qq(文字/).e($min_border).qq(文字);
	} elsif($character_num > $max_border){
		push @error , e($param_title) . qq(が長すぎます。).e($character_num).qq(文字/).e($max_border).qq(文字);
	}
	

@error;

}




1;
