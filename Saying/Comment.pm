
use strict;
use Mebius::URL;
use Mebius::View;
use Mebius::AllComments;
package Mebius::Saying::Comment;
use Mebius::Export;
use base qw(Mebius::Base::DBI Mebius::Saying Mebius::Regist);

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
"saying_comment"
}

#-----------------------------------------------------------
# テーブルのカラム設定
#-----------------------------------------------------------
sub main_table_column{

my $column = {

number => { PRIMARY => 1 } , 

text => { text => 1 } , 

content_number => { } , 
saying_number => { } ,
content_number => { } ,
content_title => { } , 

handle => { } , 
account => { } , 
addr => { } , 
host => { } , 
cnumber => { } , 
mobile_uid => { } , 
user_id => {} , 

deleted_flag => { int => 1 } ,
penalty_flag => { int => 1 } , 

create_time => { int => 1 } , 
last_update_time => { int => 1 } ,

};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_line{

my $self = shift;
my $data_group = shift;

my($line,$hit);

	foreach my $data (@{$data_group}){

		if( my $return = $self->data_to_line($data,{ hit => $hit })){
			$hit++;
			$line .= $return;
		}

	}

$line;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $data = shift;
my $use = shift;
my $times = new Mebius::Time;
my $sns_url = new Mebius::SNS::URL;
my $control = new Mebius::Control;
my $html = new Mebius::HTML;
my $url = new Mebius::URL;
my $view = new Mebius::View;
my($line,@navigation_data,%html_class,$mark);


	if($data->{'deleted_flag'}){
			if(Mebius->common_admin_judge()){
				$mark = $html->span(" [削除済み]",{ class => "red" });
				$html_class{'style'} .= "background:#fee;";
			} else {
				return();
			}
	}

$html_class{'style'} .= "padding:1em 0em;";
$html_class{'id'} .= "comment_$data->{'number'}";
	if($use->{'hit'} >= 1){
		$html_class{'class'} .= " border-top-gray";
	}

$line .= $html->start_tag("div",\%html_class);

	if($mark){
		$line .= $mark;
	}


$line .= $view->data_to_name_line($data);

my $comment = " &nbsp;" . e($data->{'text'});
$line .= $url->auto_link($comment);

$line .= qq(<div class="right">);

push @navigation_data , $times->how_before($data->{'create_time'});
push @navigation_data , $self->report_button($data);

$line .= join " ", @navigation_data;

$line .= qq(</div>);

$line .= $self->control_parts($data);


$line .= qq(</div>);

$line;

}


#-----------------------------------------------------------
# コメントフォーム
#-----------------------------------------------------------
sub form{

my $self = shift;
my $saying_data = shift;
my $html = new Mebius::HTML;
my $init = $self->init();
my $javascript = new Mebius::Javascript;
my($my_cookie) = Mebius::my_cookie_main_utf8();
my $query = new Mebius::Query;
my($form,$succession_error,$disabled);

my $id = "comment_form";
my $counter_id = "saying_comment_form_counter";
my $submit_button_id = "saying_comment_form_submit";

	if($succession_error = $self->succession_error_message()){
		$disabled = 1;
	}

$form .= $html->start_tag("form",{ action => "#comment_form" , method => "post" , style => "max-width:30em;" , id => $id });
$form .= $html->input("hidden","mode","comment");
$form .= $html->input("hidden","saying_number",$saying_data->{'number'});
$form .= Mebius::back_url_input_hidden();
$form .= $html->input("text","name",$my_cookie->{'name'},{ placeholder => "ハンドルネーム" ,style => "width:100%;" ,disabled => $disabled }) . "<br>"; # 
$form .= $query->input_hidden_encode();
$form .= $html->textarea("comment","",{ placeholder => "コメント内容" , style => "width:100%;height:6em;" , disabled => $disabled , onkeyup => "count_character_num(value,'$init->{'comment_max_length'}','$counter_id','$submit_button_id');" });
$form .= qq(<br>);


$form .= qq(<div class="right">);
$form .= $html->tag("span",$init->{'comment_max_length'},{ id => $counter_id } ) . " ";
$form .= $html->input("submit","","コメントする",{ class => "isubmit" , id => $submit_button_id , disabled => $disabled });
$form .= qq(</div>);

	if($succession_error){
		$form .= $html->tag("div","※$succession_error",{ class => "alert right" })
	}


$form .= $html->close_tag("form");


$form .= $javascript->count_character_num();

$form;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_comment{

my $self = shift;
my $query = new Mebius::Query;
my $crypt = new Mebius::Crypt;
my $text = new Mebius::Text;
my $saying = $self->saying();
my $content = $self->content();
my $init = $self->init();
my $device = new Mebius::Device;
my $regist = new Mebius::Regist;
my $all_comments = new Mebius::AllComments;
my $param_utf8_judged = $query->single_param_utf8_judged_device();
my($content_data,$content_number);

	if(!$query->post_method()){
		Mebius->regist_error("GET送信はできません。");
	}

Mebius->axs_check();

$self->succession_error();

	if( my $error = $all_comments->dupulication($param_utf8_judged->{'comment'})){
		$self->regist_error($error);
	}

	if( my $error = $regist->url_check($param_utf8_judged->{'comment'})){
		$self->regist_error($error);
	}

my $saying_data = $saying->number_to_data($param_utf8_judged->{'saying_number'}) || $self->error("名言が登録されていません。");
my $saying_url = $saying->data_to_url($saying_data);

	if($content_data = $content->number_to_data($saying_data->{'content_number'})){
		$content_number = $content_data->{'number'} || die;
	} else {
		$self->error("このコンテンツは存在しません。");
	}

	if($saying_data->{'deleted_flag'}){
		$self->regist_error("名言が削除済みです。");
	}

	if(my $error = $text->character_num_error_message($param_utf8_judged->{'comment'},$init->{'comment_min_length'},$init->{'comment_max_length'} || die,"コメント")){
		$self->regist_error($error);
	}

my $new_number = $crypt->char(30);
my $new_handle = $self->name_to_handle_or_regist_error("name");

my %insert = ( handle => $new_handle , number => $new_number , saying_number => $saying_data->{'number'} , content_number => $content_number , text => $param_utf8_judged->{'comment'} , create_time => time );
my $insert_with_connection = $device->my_connection_add_hash(\%insert);

$self->insert_main_table($insert_with_connection);

$all_comments->submit_new_comment($param_utf8_judged->{'comment'});

Mebius::redirect("$saying_url#comment_$new_number") || $self->print_html("書き込みました。");


exit;

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
sub japanese_label_name{
"コメント";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_border_num{
my $self = shift;
my $init = $self->init();
$init->{'comment_create_border_num'};
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub regist_error{
my $self = shift;
my $saying = $self->saying();
$saying->saying_view({ comment_error_message => $_[0] });
}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub error{
my $self = shift;
Mebius->error(@_);

}


1;
