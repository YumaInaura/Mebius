
use strict;
package Mebius::Base::Comment;
use Mebius::Regist;
use Mebius::URL;
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
sub limited_junction{

my $self = shift;
my($param) = Mebius::query_single_param();

	if($param->{'mode'} eq "recently_comment_core"){
		my $print = $self->recently_line();
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
"comment";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic_column{
my $self = shift;
$self->main_table_column(@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
my $self = shift;
my $main_limited_package_name = $self->main_limited_package_name() || die;
my $limited_package_name = $main_limited_package_name . "_comment";
$limited_package_name;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;
my $add_column = $self->add_and_ovewrite_main_table_column() || {};

my %column = (

target => { PRIMARY => 1 } , 
relation_target => { INDEX => 1 } , 

text => { text => 1 , other_names => { comment => 1 } } , 

handle => { } , 
account => { INDEX => 1 } , 
addr => { } , 
host => { } , 
cnumber => { INDEX => 1 } , 
mobile_uid => { } , 
user_id => {} , 
trip => {}  ,
font_color => { } ,

good_num => { int => 1 } , 
good_accounts => { text => 1 } ,
good_cnumbers => { text => 1 } ,
good_addrs => { text => 1 } ,

deleted_flag => { int => 1 } ,
penalty_flag => { int => 1 } , 

create_time => { int => 1 ,  INDEX => 1  } , 
last_update_time => { int => 1 } ,


);

my %column = (%column,%{$add_column});

\%column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub add_and_ovewrite_main_table_column{
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_comment{

my $self = shift;
my $query = new Mebius::Query;
my $device = new Mebius::Device;
my $crypt = new Mebius::Crypt;
my $text = new Mebius::Text;
my $page_back = new Mebius::PageBack;
my $text = new Mebius::Text;
my $regist = new Mebius::Regist;
my $mebius  = new Mebius;
my $cookie = new Mebius::Cookie;
my $param_utf8 = $query->single_param_utf8_judged_device();
my $init = $self->init();
my($my_account) = Mebius::my_account();
my(%insert);
my $relation_object = $self->relation_object();

$mebius->axs_check();

my $new_handle = $insert{'handle'} = $self->new_handle();
my $new_comment = $insert{'text'} = $param_utf8->{'comment'};
my $new_target = $insert{'target'} = $crypt->char(35);

$self->create_comment_common_error();

my $relation_target_param = $param_utf8->{'relation_target'} || $self->regist_error("投稿先のデータを指定して下さい。");
my $relation_data = $self->relation_data($relation_target_param) || $self->regist_error("投稿先のデータが存在しません。");
	if($relation_data->{'lock_flag'}){
		$self->regist_error("ロック中のタグです。");
	}
my $relation_target = $insert{'relation_target'} = $relation_data->{'target'};

my $adjusted_insert = $device->add_hash_with_my_connection(\%insert);
$self->insert_main_table($adjusted_insert) || $self->regist_error();

	if($relation_object){

		$relation_object->update_main_table({ target => $relation_target , response_num => ["+",1] , last_modified => time });

		$relation_object->create_common_history_on_comment({ content_targetA => $relation_target , last_response_target => $new_target , last_response_num =>  $relation_data->{'response_num'}+1 , subject => $relation_data->{'title'} , last_account => $my_account->{'id'} , last_handle => $new_handle });

	}

$cookie->param_to_set_cookie_main();


#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq()); }

$page_back->redirect() || $self->print_html("実行しました。");

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub new_handle{

my $self = shift;
my $regist = new Mebius::Regist;
my $query = new Mebius::Query;
my $param_utf8 = $query->single_param_utf8_judged_device();

my $new_handle = $regist->name_to_handle($param_utf8->{'name'});
$new_handle;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub handle_regist_error{

my $self = shift;
my($my_account) = Mebius::my_account();
my $text = new Mebius::Text;

my $new_handle = $self->new_handle();

	if(!$my_account->{'login_flag'} && $text->character_num($new_handle) < 1){
		$self->regist_error("ハンドルネームをつけてください。");
	} elsif($text->character_num($new_handle) > 20){
		$self->regist_error("ハンドルネームが長過ぎます。");
	}


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_comment_common_error{

my $self = shift;
my $text = new Mebius::Text;
my $regist = new Mebius::Regist;
my $query = new Mebius::Query;
my $param_utf8 = $query->single_param_utf8_judged_device();

my $new_comment =  $param_utf8->{'comment'};

	if( my $error = $self->response_limit_per_hour_error_message()){
		$self->regist_error($error);
	}

	if( my $error = $self->response_limit_per_day_error_message()){
		$self->regist_error($error);
	}

	if( my $error = $self->redun_comment_error_message($new_comment)){
		$self->regist_error($error);
	}

	if( my $error = $regist->url_check($new_comment)){
		$self->regist_error($error);
	}

	if($text->character_num($new_comment) < 1){
		$self->regist_error("文字数が少なすぎます。");
	}	elsif($text->character_num($new_comment) > 1000){
		$self->regist_error("文字数が多すぎます。");
	}

$self->handle_regist_error();

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub response_limit_per_hour{
30;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub response_limit_per_hour_error_message{

my $self = shift;
my $limit_num = $self->response_limit_per_hour() || die;
$self->response_limit_error_message(60*60,$limit_num);
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub response_limit_per_day{
180;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub response_limit_per_day_error_message{


my $self = shift;
my $limit_num = $self->response_limit_per_day() || die;
$self->response_limit_error_message(24*60*60,$limit_num);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub response_limit_error_message{

my $self = shift;
my $relative_border_time = shift;
my $max_num = shift || die;
my $device = new Mebius::Device;
my $dbi = new Mebius::DBI;
my(%where,$error,$add_query,%add_query);

my %user_target = $device->my_user_target_on_hash();
my $border_time = time - $relative_border_time;

$add_query{'create_time'} = [">",$border_time];
my $add_query = " AND " .  $dbi->hash_to_where(\%add_query);

%where = (%where,%user_target);

my $data_group = $self->fetchrow_main_table(\%where,{ OR => 1 , add_query => $add_query , Debug => 0 });
my $comment_num = @{$data_group};

	if($comment_num > $max_num){
		$error = "投稿数が多すぎます。しばらくお待ち下さい。";
	}

$error;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub redun_comment_error_message{

my $self = shift;
my $comment = shift;
my ($error);

my $border_time = time - 60*60;
my $data_group = $self->fetchrow_main_table({ create_time => [">",$border_time] });

	foreach my $data (@{$data_group}){

			if($comment eq $data->{'text'}){
				$error = "コメントが重複しています。";
			}

	}

$error;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub deny_url_switch{
1;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub relation_data{

my $self = shift;
my $target = shift || return();
my($param) = Mebius::query_single_param();
my($relation_data,$relation_target);

	if(my $object = $self->relation_object()){
		$relation_data = $object->target_to_data($param->{'relation_target'});
	} else {
		0;
	}

$relation_data;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub comment_form{

my $self = shift;
my $relation_data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $page_back = new Mebius::PageBack;
my $query = new Mebius::Query;
my($my_cookie) = Mebius::my_cookie_main_utf8();
my($my_account) = Mebius::my_account();
my $param_utf8 = $query->single_param_utf8_judged_device();
my($form,$textarea_inputed);

$form .= $html->start_tag("div",{ style => "width:100%;max-width:20em;"  });

$form .= $html->start_tag("form",{ method => "post" });

$form .= $html->input("hidden","mode","comment");
$form .= $html->input("hidden","relation_target",$relation_data->{'target'});


	if(!$my_account->{'login_flag'}){
		$form .= $html->input("text","name",$my_cookie->{'name'},{ placeholder => "ハンドルネーム" , style => "width:90%;" });
	}

$form .= qq(<br>);
$form .= $html->textarea("comment",$textarea_inputed,{ placeholder => "コメント" , style => "width:90%;height:8em;" });

$form .= qq(<br>);

$form .= $page_back->input_hidden();

$form .= $html->start_tag("div",{ class => "right" });
$form .= $html->input("submit","","コメントする",{ class => "isubmit" });
$form .= $html->close_tag("div");

$form .= $html->close_tag("form");

$form .= $html->close_tag("div");

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $mebius = new Mebius;
my $url = new Mebius::URL;
my $fillter = new Mebius::Fillter;
my($line,$class,$style);

	if($use->{'hit'} >= 1){
		$class .= " border-top";
	}


	if($data->{'deleted_flag'}){
			if($mebius->common_admin_judge()){
				$class .= " deleted";
			} else {
				return();
			}
	}

#my $full_package_name = $self->limited_full_package_name();

$class .= " padding-height";

$line .= $html->start_tag("div",{ class => $class , id => "s_$data->{'target'}" });

$line .= $self->data_to_name_line($data);

my $comment_text = e($data->{'text'});

	if( my $message = $fillter->each_comment_fillter($comment_text)){
		$comment_text = $message;
	} else {
		$comment_text = $self->comment_effect($comment_text);
		$comment_text = $url->auto_link($comment_text);
	}

	if( my $font_color = $data->{'font_color'}){
		$style .= "color:$font_color;";
	}

$line .= $html->tag("div",$comment_text,{ NotEscape => 1 , class => "comment" , style => $style });

$line .= $html->start_tag("div",{ class => "float-left" });
$line .= $self->good_button($data);
	if(Mebius::alocal_judge()){
		$line .= $self->good_button($data,{ Debug => 1 });
	}
$line .= $html->close_tag("div");

$line .= $html->start_tag("div",{ class => "float-right" });
$line .= $self->data_to_option_data_line($data);
$line .= $html->close_tag("div");

$line .= $html->tag("div","",{ class => "clear" });
$line .= $self->data_to_control_parts($data);

$line .= $html->close_tag("div");

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub comment_effect{
my $self = shift;
my $comment = shift;
$comment;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub regist_error{
my $self = shift;
my $mebius = new Mebius;
$mebius->error(@_);
}

1;
