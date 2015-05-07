
use strict;
use Mebius::SNS;
use Mebius::View;
use Mebius::URL;
use Mebius::Javascript;
use Mebius::AllComments;
package Mebius::Saying::Review;
use base qw(Mebius::Base::DBI Mebius::Saying Mebius::Regist);
use Mebius::Export;

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"saying_review"
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $column = {

number => { PRIMARY => 1 } , 

text => { text => 1 } , 

content_number => { } , 
saying_number => { } ,
content_number => { } ,
content_title => { } , 

good_num => { int => 1 } , 
good_accounts => { text => 1 } ,
good_cnumbers => { text => 1 } ,
good_addrs => { text => 1 } ,

handle => { } , 
account => { } , 
addr => { } , 
host => { } , 
cnumber => { } , 
mobile_uid => { } , 
user_id => {} , 

deleted_flag => { int => 1 } ,
penalty_flag => { int => 1 } , 

last_edit_time => { int => 1 } ,
 
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
my $review_data_group = shift || die;
my($line,@line,$hit);

	foreach	 my $review_data (@{$review_data_group}){

		if( my $data_line = $self->data_to_line($review_data,{ hit => $hit } )){
			$line .= $data_line;
			$hit++;
		}

	}


$line;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $review_data = shift;
my $use = shift;
my $sns_url = new Mebius::SNS::URL;
my $times = new Mebius::Time;
my $control = new Mebius::Control;
my $view = new Mebius::View;
my $url = new Mebius::URL;
my $html = new Mebius::HTML;
my $init = $self->init();
my($my_account) = Mebius::my_account();
my($line,%div);

	if($review_data->{'deleted_flag'}){

			if(Mebius->common_admin_judge()){
				$div{'style'} .= "background:#fee;";
			} else {
				return();
			}
	}

$div{'id'} = "review_$review_data->{'number'}";
$div{'class'} .= " padding-height";

	if($use->{'hit'}){
		$div{'class'} .= " border-top-gray";
	}

my $review_text = e($review_data->{'text'});
$review_text = $url->auto_link($review_text);
$review_text =~ s/[\n]/<br>/gi;

$line .= $html->start_tag("div",\%div);

	if(!$use->{'SayingListView'}){
		$line .= $html->start_tag("div",{ class => "margin-bottom" });
		#$line .= $view->data_to_name_line($review_data);
		$line .= $html->close_tag("div");
	}

$line .= $review_text;

	if($self->allow_edit($review_data)){
		my $form_id = "saying_review_edit_$review_data->{'number'}";
		$line .= " " . $html->href("$init->{'base_url'}?mode=edit_review_form&review_number=$review_data->{'number'}","編集",{ onclick => "vswitch('$form_id');return false;" });
	}

	if(!$use->{'SayingListView'}){

		$line .= qq(<div class="margin-top">);
		$line .= $self->good_button($review_data);
		$line .= $self->good_button($review_data,{ Debug => 1 }) if(Mebius::alocal_judge());
		$line .= qq(</div>);

		$line .= qq(<div class="right">);
		$line .= $view->data_to_name_line($review_data);
		$line .= " " . $times->how_before($review_data->{'last_edit_time'}) . "\n";
		$line .= $self->report_button($review_data);
		$line .= qq(</div>);

	}

$line .= $self->control_parts($review_data);

$line .= $html->close_tag("div");
$line .= "\n";

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub form{

my $self = shift;
my $saying_or_review_number = shift || die;
my $use = shift;
my $saying = $self->saying();
my $init = $self->init();
my $html = new Mebius::HTML;
my $javascript = new Mebius::Javascript;
my $query = new Mebius::Query;
my($my_account) = Mebius::my_account();
my($my_cookie_utf8) = Mebius::my_cookie_main_utf8();
my($form,$review_data,$disabled,$succession_error);

my $style_max_width = "max-width:35em;";

	if($use->{'Edit'}){
		$review_data = $self->fetchrow_main_table({ number => $saying_or_review_number })->[0];
			if(!$self->allow_edit($review_data) && !Mebius::alocal_judge()){ return(); }
	} else {
		$review_data = $self->fetchrow_main_table({ account => $my_account->{'id'} , saying_number => $saying_or_review_number })->[0];
	}

my $saying_data = $saying->number_to_data($review_data->{'saying_number'});
my $saying_url = $saying->data_to_url($saying_data);

my $counter_id = "saying_review_form_counter";
my $submit_button_id = "saying_review_form_submit";

	if(!$use->{'Edit'} && ($succession_error = $self->succession_error_message())){
		$disabled = 1;
	}

$form .= $html->start_tag("div",{ style => "$style_max_width" });
$form .= $html->start_tag("form",{ method => "post" });
	if(!$my_account->{'login_flag'}){		$form .= $html->input("text","name",$my_cookie_utf8->{'name'},{ placeholder => "ハンドルネーム" , style => "width:100%;" , disabled => $disabled });	}$form .= $html->textarea("review",$review_data->{'text'},{ style => "width:100%;height:8em;" , id => "saying_submit_textarea" , disabled => $disabled , placeholder => "解説の内容" , onkeyup => "count_character_num(value,'$init->{'review_max_length'}','$counter_id','$submit_button_id');" });	if($use->{'Edit'}){		$form .= $html->input("hidden","mode","edit_review");
	} else {
		$form .= $html->input("hidden","mode","create_review");
	}


#$form .= $html->input("hidden","content_number",$content_data->{'number'});

	if($use->{'Edit'}){
		$form .= $html->input("hidden","review_number",$saying_or_review_number);
	} else {
		$form .= $html->input("hidden","saying_number",$saying_or_review_number);
	}

$form .= $html->input("hidden","backurl",$saying_url);
$form .= $query->input_hidden_encode();
$form .= $html->input("hidden","my_account",$my_account->{'id'});

$form .= $html->start_tag("div",{ class => "right" });
$form .= $html->tag("span",$init->{'review_max_length'},{ id => $counter_id }) . " " ;
$form .= $html->input("submit","","解説を登録する",{ class => "isubmit" , disabled => $disabled , id => $submit_button_id });

	if($succession_error){
		$form .= $html->start_tag("div");
		$form .= $html->tag("span","※$succession_error",{ class => "alert" });
		$form .= $html->close_tag("div");
	}

$form .= $html->close_tag("div");

$form .= $html->close_tag("form");
$form .= $html->close_tag("div");

$form .= $javascript->count_character_num();

$form;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_review{

my $self = shift;
my $basic = $self->basic();
my $init = $basic->init();
my $saying = $basic->saying();
my $content = $basic->content();
my $review = $basic->review();
my($my_account) = Mebius::my_account();
my $query = new Mebius::Query;
my $param_utf8_judged = $query->single_param_utf8_judged_device();
my $text = new Mebius::Text;
my $crypt = new Mebius::Crypt;
my $device = new Mebius::Device;
my $regist = new Mebius::Regist;
my $all_comments = new Mebius::AllComments;
my(%update,$saying_data,$saying_number,$content_data);

$basic->common_post_check_or_error();

$self->common_regist_error($param_utf8_judged->{'review'});

$self->dupulication_regist_error($param_utf8_judged->{'review'});

$saying_number = $param_utf8_judged->{'saying_number'};

	if($saying_data = $saying->number_to_data($saying_number)){
		$update{'saying_number'} = $saying_number || die;
	} else {
		$self->error("この名言は存在しません。");
	}

	if($content_data = $content->number_to_data($saying_data->{'content_number'})){
		$update{'content_number'} = $content_data->{'number'} || die;
	} else {
		$self->error("このコンテンツは存在しません。");
	}

my $saying_url = $saying->data_to_url($saying_data);

$update{'text'} = $param_utf8_judged->{'review'};
$update{'last_edit_time'} = time;
#$update{'content_number'} = $param_utf8_judged->{'content_number'} || die;

	if(!$my_account->{'login_flag'}){
		$update{'handle'} = $self->name_to_handle_or_regist_error("name");
	}

$update{'create_time'} = time;

$update{'number'} = $crypt->char(30);

	if( my $still_review_data = $self->number_to_data($update{'number'})){
		$self->regist_error("もういちどお試し下さい。");
	}

my $update_or_insert_with_connection = $device->my_connection_add_hash(\%update);

$self->insert_main_table($update_or_insert_with_connection);

$all_comments->submit_new_comment($param_utf8_judged->{'review'});

Mebius::redirect("$saying_url#review_$update{'number'}") || $basic->print_html("登録しました。",{ BCL => ["解説の登録"] });

exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_review{

my $self = shift;
my $basic = $self->basic();
my $init = $basic->init();
my $saying = $basic->saying();
my $content = $basic->content();
my $review = $basic->review();
my $regist = new Mebius::Regist;
my $query = new Mebius::Query;
my $text = new Mebius::Text;
my $crypt = new Mebius::Crypt;
my $device = new Mebius::Device;
my $param_utf8_judged = $query->single_param_utf8_judged_device();
my($my_account) = Mebius::my_account();
my(%update,$saying_number);

$basic->common_post_check_or_error();

$self->common_regist_error($param_utf8_judged->{'review'});

$update{'number'} = $param_utf8_judged->{'review_number'};

my $review_data = $review->number_to_data($param_utf8_judged->{'review_number'}) || $self->error("編集しようとしている解説が存在しません。");
$saying_number = $review_data->{'saying_number'};

	if(!$self->allow_edit($review_data)){ $self->error("編集できません。"); }

my $saying_data = $saying->number_to_data($saying_number);

	#	1;
	#} else {
	#	$self->error("この名言は存在しません。");
	#}

my $saying_url = $saying->data_to_url($saying_data);

	if(!$my_account->{'login_flag'}){
		$update{'handle'} = $self->name_to_handle_or_regist_error("name");
	}


$update{'text'} = $param_utf8_judged->{'review'};
$update{'last_edit_time'} = time;

my $update_or_insert_with_connection = $device->my_connection_add_hash(\%update);

$self->update_main_table($update_or_insert_with_connection);

Mebius::redirect("$saying_url#review_$update{'number'}") || $basic->print_html("登録しました。",{ BCL => ["解説の登録"] });

exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub common_regist_error{

my $self = shift;
my $text_body = shift;
my $text = new Mebius::Text;
my $regist = new Mebius::Regist;
my $init = $self->init();

	if( my $error = $text->character_num_error_message($text_body,10,$init->{'review_max_length'},"解説")){
		$self->regist_error($error);
	}

	if( my $error = $regist->url_check($text_body)){
		$self->regist_error($error);
	}

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub allow_edit{

my $self = shift;
my $review_data = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($allow_flag);

	if(!$review_data){ return(); }
	if($review_data->{'deleted_flag'}){ return(); }

	if($review_data->{'account'}){
			if($review_data->{'account'} eq $my_account->{'id'}){
				$allow_flag = 1;
			} else {
				0;
			}
	} else {
			if($review_data->{'cnumber'} && $review_data->{'cnumber'} eq $my_cookie->{'char'}){
				$allow_flag = 1;
			} else {
				0;
			}
	}

$allow_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub still_reviewed{

my $self = shift;
my $review_data_group = shift;
my($my_account) = Mebius::my_account();
my($flag);

	#if(!$my_account->{'login_flag'}){ return(); }

	foreach	my $data (@{$review_data_group}){

			if($my_account->{'id'} eq $data->{'account'}){
				$flag = 1;
			} else {
				0;
			}
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_or_submit_view{

my $self = shift;
my $error = shift;
my $saying = $self->saying();
my $content = $self->content();
my $html = new Mebius::HTML;
my($param) = Mebius::query_single_param();
my($print,$review_data,$saying_data,$saying_number,$edit_mode,$create_mode,$title);

	if($param->{'review_number'}){
		$review_data = $self->number_to_data($param->{'review_number'});
		$saying_number = $review_data->{'saying_number'};
		$edit_mode = 1;
		$title = "解説の編集";
	}elsif($param->{'saying_number'}){
		$saying_number = $param->{'saying_number'};
		$create_mode = 1;
		$title = "解説の登録";
	} else {
		$self->error("表示するモードを指定して下さい。");
	}

$saying_data = $saying->number_to_data($saying_number) || $self->error("名言の登録がありません。");;

my $content_data = $content->number_to_data($saying_data->{'content_number'});

	if($error){
		$print .= $html->tag("div",$error,{ class => "message-red" , NotEscape => 1 });
	}

	if($edit_mode){
		$print .= $html->tag("h2",$title);
	} elsif($create_mode){
		$print .= $html->tag("h2",$title);
	
	}

	# 解説フォーム
	if($param->{'review_number'}){
			if(my $form = $self->form($param->{'review_number'},{ Edit => 1 })){
				$print .= $form;
			}
	} elsif($param->{'saying_number'}){
			if(my $form = $self->form($param->{'saying_number'})){
				$print .= $form;
			}
	}

my $content_url = $content->url($saying_data->{'content_title'});
my $saying_url = $saying->url($saying_data->{'content_title'},$saying_data->{'number'});

my $h1 = $saying_data->{'text'};
$self->print_html($print,{ h1 => $h1 , BCL => [ { title => $content_data->{'title'} , url => $content_url } , { url => $saying_url , title => $saying_data->{'text'} },$title] , Title => $title });

exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_border_num{
my $self = shift;
my $init = $self->init();
$init->{'review_create_border_num'};
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub error{
my $self = shift;
Mebius->error(@_);
}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub regist_error{
my $self = shift;
$self->edit_or_submit_view(@_);
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"review";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub japanese_label_name{
"解説";
}

1;
