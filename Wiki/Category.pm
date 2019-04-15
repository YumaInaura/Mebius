	
use strict;
package Mebius::Wiki::Category;
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
"wiki_category";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $column = {
target => { PRIMARY => 1 } ,
domain => { INDEX => 1 } , 
title => { INDEX => 1 } ,
priority => { int => 1 } , 
page_num => { int => 1 } ,  
};

$column;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_view{

my $self = shift;
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my($print);
my($param) = Mebius::query_single_param();

my $site_title = $basic->site_title();

$print .= $html->start_tag("form",{ method => "post" });
$print .= $html->tag("h2","カテゴリ名の変更 ( $site_title )");
$print .= $html->input("hidden","mode","change_category_name");
$print .= $html->input("hidden","domain",$param->{'domain'});

$print .= $html->start_tag("select",{ name => "from" });
$print .= $self->all_category_name_select_box_options();
$print .= $html->close_tag("select");
#$print .= $html->input("text","from") . "を";
$print .= " を ";

$print .= $html->input("text","to") . " に ";
$print .= $html->input("submit","","変更する");

$print .= $html->close_tag("form");

$print .= $html->start_tag("div",{ style => "margin:1em;" });
$print .= "@{$self->all_category_name()}";
$print .= $html->close_tag("div");

$print .= $html->start_tag("form",{ method => "post" });
$print .= $html->tag("h2","全てのカテゴリ名を修正する");
$print .= $html->input("hidden","mode","dbi_control_all_post_to_create_category");
$print .= $html->input("submit","","カテゴリを修正");
$print .= $html->close_tag("form");

$basic->print_html($print,{ Title => "カテゴリの管理" });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_category_name{

my $self = shift;
my $basic = new Mebius::Wiki;
my $post = new Mebius::Wiki::Post;
my(%category_name);

my $site_domain = $basic->site_domain() || die;

my $data_group = $post->fetchrow_main_table({ domain => $site_domain });

	foreach my $data (@{$data_group}){

			if( my $category_name = $data->{'category'} ){
				$category_name{$category_name} = $category_name;
			} else {
				next;
			}
	}

my @category_name_on_array = keys %category_name;

\@category_name_on_array;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_category_name_select_box_options{

my $self = shift;
my $html = new Mebius::HTML;
my $all_category = $self->all_category_name();
my($print);

	foreach my $category_name ( @{$all_category} ) {
		$print .= $html->tag("option",$category_name,{ value => $category_name });
	}

$print;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub change_category_name{

my $self = shift;
my $basic = new Mebius::Wiki;
my $post = new Mebius::Wiki::Post;
my($param) = Mebius::query_single_param();
my($print);

my $from = $param->{'from'} || die;
my $to = $param->{'to'} || die;
my $site_domain = $basic->site_domain() || die;


$post->update_main_table({ category => $to } , { WHERE => { domain => $site_domain ,  category => $from }  , Debug => 0 });

my $edit_category_url = $self->edit_category_url();

Mebius::redirect($edit_category_url);

$print .= "OK.";

$basic->print_html($print);

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_category_url{

my $self = shift;
my $basic = new Mebius::Wiki;
my($url);

my $site_url = $basic->site_base_url() || return();

	#if($basic->edit_site_mode()){
	#	$url = "${site_url}?mode=category_edit";
	#} else {
		$url = "${site_url}category_edit";
	#}

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub update_or_create_category{

my $self = shift;
my $domain = shift || return();
my $title = shift || return();
my $basic = new Mebius::Wiki;
my $crypt = new Mebius::Crypt;
my(%insert);

$basic->allow_edit() || die;

$insert{'domain'} = $domain || die("Domain is empty.");
$insert{'title'} = $title || die("Category title is empty.");

my $data = $self->fetchrow_main_table({ domain => $domain , title => $title })->[0];

	if($data){
		$self->update_main_table(\%insert);
	} else {
		$insert{'target'} = $crypt->char(30);
		$self->insert_main_table(\%insert);
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub dbi_control_all_post_to_create_category {

my $self = shift;
my $post = new Mebius::Wiki::Post;
my $basic = new Mebius::Wiki;

$basic->allow_edit() || die;

my $data_group = $post->fetchrow_main_table();

	foreach my $data (@{$data_group}){
		$self->update_or_create_category($data->{'domain'},$data->{'category'});
	}

$basic->print_html("修正が完了しました。");

exit;

}

1;
