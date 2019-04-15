
use strict;
use Mebius::PageBack;
use Mebius::Escape;
use Mebius::SNS::Account;
use Mebius::Control;
use Mebius::Javascript;
package Mebius::Tags::Tag;
use base qw(Mebius::Base::DBI Mebius::Base::Post Mebius::Base::Data Mebius::Tags);

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
sub content_target_setting{
my $self = shift;
my $setting = ["title"];
$setting;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"tags_tag";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $column = {

target => { INDEX => 1 } , 
title => { PRIMARY => 1 } , 

handle => { } , 
account => { } , 
addr => { } , 
host => { } , 
cnumber => { } , 
mobile_uid => { } , 
user_id => {} , 

deleted_comment_num => { int => 1 } , 
comment_num => { int => 1 } ,

lock_flag => { int => 1 } ,
deleted_flag => { int => 1 } ,
penalty_flag => { int => 1 } , 

create_time => { int => 1 , INDEX => 1  } , 
last_update_time => { int => 1 } ,
last_modified => { int => 1 , INDEX => 1 } ,

};

$column;

}





#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_created_tags{

my $self = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($data_group,$line);

	if($my_account->{'login_flag'}){
		$data_group = $self->fetchrow_main_table({ account => $my_account->{'id'} });
	} elsif ($my_cookie->{'char'}){
		$data_group = $self->fetchrow_main_table({ cnumber => $my_cookie->{'char'} });
	}

$line = $self->data_group_to_list($data_group);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $encoding = new Mebius::Encoding;
my $tag_mark = $self->tag_mark();
my $mebius = new Mebius;
my $control = new Mebius::Control;
my($line,$mark,$comment_num_view);

my $title = $data->{'title'} || $data->{'tag_title'} || return();

	if(Mebius::Fillter::heavy_fillter($title)){
		return();
	}

	if($data->{'deleted_flag'}){
			if($mebius->common_admin_judge()){
				$mark = $control->deleted_mark();
			} else {
				return();
			}
	}

my $comment_num = $data->{'comment_num'} - $data->{'deleted_comment_num'};

	if($comment_num >= 1){
		$comment_num_view = "($comment_num)" ;
	} elsif($data->{'deleted_comment_num'}) {
		return();
	}

my $url = $self->data_to_url($data);
$line .= $html->href($url,"$tag_mark$title$comment_num_view") . "\n";
$line .= $mark;

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tag_view{

my $self = shift;
my $tag_title = shift;
my $label_name = shift;
my $use = shift;
my $init = $self->init();
my $dbi = new Mebius::DBI;
my $html = new Mebius::HTML;
my $mebius = new Mebius;
my $sns_account = new Mebius::SNS::Account;
my $javascript = new Mebius::Javascript;
my($param) = Mebius::query_single_param();
my $comment = $self->comment_object();
my $follow = $self->follow_object();
my $max_tags_num = $self->max_tags_num();	
my $label_split_mark = $self->label_split_mark();
my($print,$where,@query);

my $title = "#$tag_title";

my($subject_fillter_error) = Mebius::Fillter::fillter_and_error($tag_title);

	if($label_name){
		$title .= "$label_split_mark$label_name";
	}

my $data = $self->fetchrow_main_table({ title => $tag_title })->[0] || $self->error("存在しないページです。");

$self->read_on_history($data);

	if($data->{'deleted_flag'} && !$mebius->common_admin_judge()){
		$self->error("削除済みページです。");
	}

	for my $number (1..$max_tags_num){
			#if($label_name){
			#	push @query , $dbi->hash_to_where({ "tag$number" => $tag_title , "label$number" => $label_name },{ AND => 1 });
			#} else {
				push @query , $dbi->hash_to_where({ "tag$number" => $tag_title });
			#}
		$where = join " OR " , @query;
	}

my $comment_data_group = $comment->fetchrow_main_table("WHERE $where ",{  ORDER_BY => ["create_time DESC"] , Debug => 0 });
my $comment_data_group_with_account_handle = $sns_account->add_handle_to_data_group($comment_data_group);
my $comment_num = @{$comment_data_group_with_account_handle};

	if($subject_fillter_error){
		$print .= $html->tag("strong",$subject_fillter_error,{ class => "red" , NotEscape => 1 });
	}

my $data_body_line = $self->data_to_line($data,{ NoTitle => 1 });
	if(!$param->{'directory2'}){
		$print .= $self->around_control_form($data_body_line);
	}

	if( my $form_error = $use->{'form_error'} ){
		$print .= $html->tag("strong","※$form_error",{ class => "red" } );
	}


$print .= $html->start_tag("div",{ class => "margin-top" });
$print .= $comment->form($data);
$print .= $html->close_tag("div");

$print .= $html->start_tag("div",{ class => "border-bottom padding-bottom" });
$print .= $self->data_to_link($data) . " ";
	if( my $label_links = $comment->data_group_to_label_links($comment_data_group_with_account_handle)){
		$print .= " - $label_links";
	}
$print .= $html->close_tag("div");

my $comment_line = $comment->data_group_to_line($comment_data_group_with_account_handle,{ label => $label_name , max_view => 50 });
$print .= $self->around_control_form($comment_line);

$print .= $self->push_good_javascript();

$self->print_html($print,{ h1 => "$title($comment_num)" , Title => $title ,  BCL => [$title] });

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $follow = $self->follow_object();
my($param) = Mebius::query_single_param();
my($line);

	if(!$use->{'NoTitle'}){
		$line .= $html->tag("strong","#$data->{'title'}") . " ";
	}

	if($data->{'deleted_flag'}){
		$line .= $html->strong("※削除済みページです。",{ class => "red" } ) . "\n";
	} else {
		$line .= $follow->follow_or_unfollow_button($data);
		$line .= $self->data_to_control_parts($data);
		$line .= $html->start_tag("div",{ class => "right margin-top" });
		$line .= $self->report_button($data);
		$line .= $html->close_tag("div");
	}


$line;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_view{

my $self = shift;
my $error = shift;
my $html = new Mebius::HTML;
my($print);

my $title = "タグの登録";

	if($error){
		$print .= $html->tag("strong",$error,{ class => "red" });
	}

$print .= $self->create_form();

$self->print_html($print,{ h1 => $title , Title => $title , BCL => [$title] });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_form{

my $self = shift;
my $html = new Mebius::HTML;
my $page_back = new Mebius::PageBack;
my($form);

$form .= $html->start_tag("form",{ method => "post" });
$form .= $html->input("hidden","mode","create_tag_submit");
$form .= $html->input("text","title","",{ placeholder => "例) " });
$form .= $page_back->input_hidden();
$form .= $html->input("submit","","作成");
$form .= $html->close_tag("form");

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
#sub create_tag_only{

#my $self = shift;
#my $query = new Mebius::Query;
#my $param_utf8 = $query->single_param_utf8_judged_device();
#my $text = new Mebius::Text;
#my $crypt = new Mebius::Crypt;
#my $device = new Mebius::Device;
#my $init = $self->init();

#my $new_target = $crypt->char(30);
#my $new_title = $self->fix_tag_name($param_utf8->{'title'});

#	if(my $error = $self->create_tag_error_message($new_title)){
#		$self->create_view($error);
#	}

#	if( my $error = $self->still_exists($new_title)){
#		$self->create_view("このタグは既に存在します。");
#	}

#$self->creata_tag($new_title);

#Mebius::redirect($init->{'base_url'});

#exit;

#}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_tag{

my $self = shift;
my $tag_name = shift;
my $query = new Mebius::Query;
my $param_utf8 = $query->single_param_utf8_judged_device();
my $text = new Mebius::Text;
my $crypt = new Mebius::Crypt;
my $device = new Mebius::Device;
my $init = $self->init();

my $new_target = $crypt->char(30);
my $new_title = $self->fix_tag_name($tag_name);

	if($self->fetchrow_main_table({ target => $new_target })->[0]){
		$self->error("もういちどお試しください。");
		#$self->create_tag(); # 意図的なループ
	}

my $insert = { target => $new_target , title => $new_title , last_modified => time , comment_num => 1 };

my $adjusted_insert = $device->add_hash_with_my_connection($insert);

$self->insert_main_table($adjusted_insert);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_tag_error_message{

my $self = shift;
my $tag_name = shift;
my $init = $self->init();
my $text = new Mebius::Text;
my $max_character_num = $init->{'tag_max_character_num'} || die;
my($error_message);

	if($tag_name =~ /\s|\t|\r|\n|\0|　/){
		$error_message = "タグにスペースは使えません。";
	} elsif( my $error = $text->character_num_error_message($tag_name,1,$max_character_num,"タグ")){
		$error_message = $error;
	}


$error_message;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub still_exists{

my $self = shift;
my $tag_name = shift;
my($error_message);

	if($self->fetchrow_main_table({ title => $tag_name })->[0]){
		$error_message = "このタグは既に存在します。";
	}

$error_message;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $data = shift;
my $init = $self->init();
my $encoding = new Mebius::Encoding;
my $escape = new Mebius::Escape;
my($url);

my $tag_title = $data->{'title'} || $data->{'tag_title'};
my $de_escaped_title = $escape->decode_html($tag_title);
my $encoded_title = $encoding->encode_url($de_escaped_title);

my $de_escaped_label_name = $escape->decode_html($data->{'label'});
my $endoded_label_name = $encoding->encode_url($de_escaped_label_name);

	if(Mebius::alocal_judge()){
		$url = "$init->{'base_url'}?mode=tag&directory1=$encoded_title";
			if($endoded_label_name){
				$url .= "&directory2=$endoded_label_name";
			}
	} else {
		$url = "$init->{'base_url'}t/$encoded_title/";
			if($endoded_label_name){
				$url .= "$endoded_label_name/";
			}
	}

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub label_url{

my $self = shift;
my $tag_name = shift;
my $label_name = shift;
my $encoding = new Mebius::Encoding;
my($label_url);

my $encoded_label_name = $encoding->encode_url($label_name);
my $tag_url = $self->data_to_url({ title => $tag_name });

	if(Mebius::alocal_judge()){
		$label_url = "${tag_url}&directory2=$encoded_label_name";
	} else {
		$label_url = "${tag_url}$encoded_label_name/";
	}


$label_url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_link{

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;
my $label_split_mark = $self->label_split_mark();
my($link_text);

my $url = $self->data_to_url($data);

my $title = $data->{'title'} || $data->{'tag_title'};

$link_text = "#$title";
	if( my $label_name = $data->{'label'}){
		$link_text .= $label_split_mark . $label_name;
	}

my $link = $html->href($url,$link_text);

$link;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_list{

my $self = shift;

my $data_group = $self->fetchrow_main_table({ },{ ORDER_BY => ["last_modified DESC"] , Debug => 0 });
my($print);

$print = $self->data_group_to_list($data_group);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub recently_create_line{

my $self = shift;

my $border_time = time - 30*24*60*60;

my $data_group = $self->fetchrow_main_table({ last_modified => [">",$border_time] },{ ORDER_BY => ["last_modified DESC"] , Debug => 0 });
my($print);

$print .= $self->data_group_to_list($data_group,{ max_view => 100 });

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"comment";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub japanese_label{
"タグ";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_tag_url{

my $self = shift;
my $init = $self->init();

"$init->{'base_url'}create_tag";

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub regist_error{

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"tag";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub target_to_data{

my $self = shift;
my $target = shift || return();

my $primary_key = $self->get_primary_key_from_main_table();

my $data = $self->fetchrow_main_table({ target => $target },{ Debug => 0 })->[0];

$data;


}



1;

