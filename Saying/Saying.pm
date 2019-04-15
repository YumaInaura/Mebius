
use strict;
package Mebius::Saying::Saying;

use base qw(Mebius::Base::DBI Mebius::Saying);
use Mebius::Control;
use Mebius::Javascript;
use Mebius::Operate;
use Mebius::Export;

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
"saying";
}

#-----------------------------------------------------------
# テーブルのカラム設定
#-----------------------------------------------------------
sub main_table_column{

my $column = {

number => { PRIMARY => 1 } ,

content_number => { } ,
content_title => { } ,

text => { text => 1 } ,
human => { } ,
split_number => { int => 1 } ,

order_number => { int => 1 } ,

good_num => { int => 1 } ,
good_accounts => { text => 1 } ,
good_cnumbers => { text => 1 } ,
good_addrs => { text => 1 } ,

access_count => { int => 1  } ,
access_addrs => { text => 1 }  ,
access_cnumbers => { text => 1 }  ,

deleted_flag => { int => 1 } ,
penalty_flag => { int => 1 } ,

account => { } ,
addr => { } ,
host => { } ,
cnumber => { } ,
mobile_uid => { } ,
user_id => {} ,

handle => { } ,

create_time => { int => 1 } ,


};

$column;

}


#-----------------------------------------------------------
# 名言の新規登録
#-----------------------------------------------------------
sub create_saying{

my $self = shift;
my($param) = Mebius::query_single_param();
my $query = new Mebius::Query;
my $basic = $self->basic();
my $init = $basic->init();
my($my_account) = Mebius::my_account();
my $text = new Mebius::Text;
my $device = new Mebius::Device;
my $title = new Mebius::Saying::Content;

$basic->common_post_check_or_error();

my $saying_text = $text->fix_space($param->{'saying'});
#$saying_text = $text->fullsize_to_halfsize($saying_text);

my $saying_max_length = $init->{'saying_max_length'} || die;

$self->succession_error();

$self->dupulication_regist_error($saying_text);

	if( my $error = $text->character_num_error_message($saying_text,1,$saying_max_length,"解説")){
		$self->error($error);
	}

my $new_number = Mebius::Crypt->char(25);

	if($self->fetchrow_main_table({ number => $new_number })->[0]){
		$self->error("もういちどお試し下さい。");
	}

	if($self->fetchrow_main_table({ text => $saying_text })->[0]){
		$self->error("既にこの名言は登録されています。");
	}

my $content_data = $title->fetchrow_main_table({ number => $param->{'content_number'} , deleted_flag => ["<>",1] } )->[0] || $self->error("このタイトルは存在しません。");

my %insert = ( text => $saying_text , number => $new_number , create_time => time , content_number => $param->{'content_number'} , content_title => $content_data->{'title'} );
%insert = (%insert,%{$device->my_connection()});

#$insert{'account'} || die;

$self->create_main_table();

$self->insert_main_table(\%insert);

$self->max_create_num_error();

my $saying_url = $basic->saying_url($content_data->{'title'},$new_number);

Mebius::redirect($saying_url);

exit;

}


#-----------------------------------------------------------
# 連続投稿制限
#-----------------------------------------------------------
sub max_create_num_error{

my $self = shift;
my $basic = $self->basic();
my $init = $basic->init();
my($error);
my($my_account) = Mebius::my_account();

my $max_create_num = $init->{'saying_max_create_num'} || die;
my $border_hour = $init->{'saying_create_border_hour'} || die;
my $border_time = time - $border_hour*60*60;
my(undef,$create_num) = $self->fetchrow_main_table({ account => $my_account->{'id'} , create_time  => ["<",$border_time]});
	if($create_num > $max_create_num && !Mebius::alocal_judge()){
		$error = qq(${border_hour}時間に${max_create_num}個以上は登録できません。");
	}

$error;

}


#-----------------------------------------------------------
# 名言の編集
#-----------------------------------------------------------
sub edit_saying{

my $self = shift;
my $basic = $self->basic();
my $print;
my($param) = Mebius::query_single_param();

my $saying_data = $self->fetchrow_main_table({ number => $param->{'saying_number'} })->[0] || $self->error("登録がありません。");
my $content_data = $basic->saying_data_to_content_data($saying_data);

my $allow_flag = $self->allow_edit($saying_data) || $self->error("編集権限がありません。");

$self->update_main_table({ number => $param->{'saying_number'} , human => $param->{'human'} , split_number => $param->{'split_number'} }); #  , guide => $param->{'guide'}

my $saying_url = $basic->saying_url($content_data->{'title'},$saying_data->{'number'});

Mebius::redirect($saying_url);

exit;

}


#-----------------------------------------------------------
# 編集権限
#-----------------------------------------------------------
sub allow_edit{

my $self = shift;
my $saying_data = shift || die;
my($my_account) = Mebius::my_account();
my($allow_flag);

	if(Mebius::Admin::admin_mode_judge()){
		$allow_flag = 1;
	} elsif($my_account->{'login_flag'}){
		$allow_flag = 1;
	#} elsif($saying_data->{'account'} eq $my_account->{'id'}){
	#	$allow_flag = 1;
	} else {
		0;
	}

$allow_flag;


}



#-----------------------------------------------------------
# 名言本体を表示
#-----------------------------------------------------------
sub saying_view{

my $self = shift;
my $use = shift;
my $basic = $self->basic();
my $saying = $basic->saying();
my $view = $basic->view();
my $review = $basic->review();
my $comment = $basic->comment();
my $init = $self->init();
my $control = new Mebius::Control;
my $debug = new Mebius::Debug;
my $javascript = new Mebius::Javascript;
#my $content = $basic->content();
my $html = new Mebius::HTML;
my $text = new Mebius::Text;
my($param) = Mebius::query_single_param();
my($print,@BCL,$message);

my $saying_number = $param->{'q'} || $param->{'saying_number'};
my $saying_data = $saying->fetchrow_main_table({ number => $saying_number })->[0] || $self->error("ページが存在しません。[S1]");
my $content_data = $basic->saying_data_to_content_data($saying_data);

$message = $self->deleted_judge($saying_data) || $self->deleted_judge($content_data);


my $title_url = $self->title_url($content_data->{'title'});

my $form_id = "saying_saying_control_$saying_data->{'number'}";

	if($message){
		$print .= qq(<div>);
		$print .= $html->tag("strong",$message,{ class => "red" } );
		$print .= qq(</div>);

	}

# FORM START
$print .= $self->data_to_line($saying_data,{ form_id => $form_id , NotViewTitle => 1 });
$print .= $debug->escape_error_checkbox();


# 解説エリア
my $review_data_group = $review->fetchrow_main_table({ saying_number => $saying_data->{'number'} },{ ORDER_BY => ["good_num DESC"] } );

$print .= $html->tag("h2","解説",{ style => "color:#f55;" });
$print .= $review->data_group_to_line($review_data_group) || "解説はまだありません。";


	if(!$review->still_reviewed($review_data_group)){
		$print .= $html->href("$init->{'base_url'}?mode=edit_review_form&saying_number=$saying_data->{'number'}","→解説を登録する",{ rel => "nofollow" });
	}

# コメント
$print .= $html->tag("h2","コメント",{ style => "color:#090;" });
my $comment_data_group = $comment->fetchrow_main_table({ saying_number => $saying_number },{ ORDER_BY => ["create_time ASC"] });
$print .= $comment->data_group_to_line($comment_data_group) || "コメントはまだありません。";

$print = $self->around_control_form($print,$form_id);

	# コメントフォーム
	if( my $form = $comment->form($saying_data)){
		$print .= qq(<div class="margin-top">);
			if($use->{'comment_error_message'}){
				$print .= $html->tag("div",$use->{'comment_error_message'},{ class => "message-red" });
			}
		$print .= $form;
		$print .= qq(</div>);
	}


push @BCL , { url => $title_url , title => $content_data->{'title'} };
push @BCL , $saying_data->{'text'};

my $saying_text_omited = $text->omit_character($saying_data->{'text'},20);
$basic->print_html($print,{ Title => "$saying_text_omited | $content_data->{'title'}" , h1 => $saying_data->{'text'} , BCL => \@BCL });

exit;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_group_to_line{

my $self = shift;
my $saying_data_group = shift || [];
my $content_data = shift;
my $review = $self->review();
my $basic = $self->basic();
my $html = new Mebius::HTML;
my($print,@review,%review_per_saying,$hit_saying);

	#foreach(@{$$review_data_group}){
	#}

	foreach my $saying_data (@{$saying_data_group}){
		push @review , ["saying_number","=",$saying_data->{'number'}] ;
	}

my $review_data_group = $review->fetchrow_main_table(\@review,{ OR => 1 });

	foreach my $review_data (@{$review_data_group}){
		push @{$review_per_saying{$review_data->{'saying_number'}}} , $review_data;
	}

my @sorted_data = sort { $b->{'good_num'} <=> $a->{'good_num'} } @{$saying_data_group};

	foreach my $saying_data (@sorted_data){

		my($hit_review);

			if( my $saying_line = $self->data_to_list($saying_data,{ hit => $hit_saying })){
				$hit_saying++;
				$print .= $saying_line;
			}

		my $review_data_group = $review_per_saying{$saying_data->{'number'}};
		my @sorted_review = sort { $b->{'good_num'} <=> $a->{'good_num'} } @{$review_data_group} if(ref $review_data_group eq "ARRAY");
			foreach my $review_data ( @{$review_per_saying{$saying_data->{'number'}}} ){
					if($hit_review >= 1){ last; }

					if(my $review_line = $review->data_to_line($review_data,{ hit => $hit_review , SayingListView => 1 })){
						$print .= $review_line;
						$hit_review++;
					}
			}

	}

$print;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $saying_data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my($mark,$print);

	if($saying_data->{'deleted_flag'}){

		$mark = $html->span("[削除済み]",{ class => "red" });
			if(Mebius->common_admin_judge()){
				1;
			} else {
				return();
			}
	}

	if($use->{'hit'} >= 1){
		$print .= qq(<hr style="border-top:solid 1px black;">);
	}

#my $hit = $use->{'hit'}+1;

my $saying_url = $self->url($saying_data->{'content_title'},$saying_data->{'number'});
$print .= $html->start_tag("h2",{ class => "inline" });
$print .= $html->href($saying_url,"$saying_data->{'text'}") . "\n";
$print .= $mark;
$print .= $html->close_tag("h2");

	if( my $human = $saying_data->{'human'}){
		$print .= $html->tag("b"," by $human",{ style => "font-size:140%;" });
	}

$print .= $html->start_tag("div",{ class => "margin-top" });
$print .= $self->good_button($saying_data);
$print .= $self->good_button($saying_data,{ Debug => 1 });
$print .= $html->close_tag("div");

$print;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $saying_data = shift;
my $use = shift;
my $init = $self->init();
my $content = $self->content();
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my $view = new Mebius::View;
my $javascript = new Mebius::Javascript;
my $control = new Mebius::Control;
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my($print);

my $content_url = $content->url($saying_data->{'content_title'});
my $saying_url = $self->data_to_url($saying_data);

	if(!$use->{'NotViewTitle'}){
		$print .= $html->start_tag("div");
		$print .= $html->href($saying_url,$saying_data->{'text'});
		$print .= $html->close_tag("div");
	}

	if( my $human = $saying_data->{'human'}){
		$print .= $html->tag("b","by $human");
	}

$print .= " ( " . $html->href($content_url,$saying_data->{'content_title'}) .qq( の名言) . " ) ";


	if($self->allow_edit($saying_data)){
		$print .= " &nbsp;" . $html->href("${saying_url}&edit=1","→編集",{ nofollow => 1 });
	}

	if($use->{'form_id'}){

		$print .= $html->start_tag("div",{ class => "margin-top" });
		$print .= $self->good_button($saying_data);

			if(Mebius::alocal_judge()){
				$print .= $self->good_button($saying_data,{ Debug => 1 });
			}

		$print .= $html->close_tag("div");

		$print .= $javascript->push_good($use->{'form_id'});

	}

$print .= $html->start_tag("div",{ class => "right" });
$print .= $view->data_to_name_line($saying_data);
$print .= " " . $times->how_before($saying_data->{'create_time'});
$print .= " " . $self->report_button($saying_data);
$print .= $html->close_tag("div");
$print .= $self->control_parts($saying_data);

}


#-----------------------------------------------------------
# 名言登録フォーム
#-----------------------------------------------------------
sub form{

my $self = shift;
my $content_data = shift;
my $basic = new Mebius::Saying;
my $init = $self->init();
my $html = new Mebius::HTML;
my $javascript = new Mebius::Javascript;
my $query = new Mebius::Query;
my($param) = Mebius::query_single_param();
my($form,$succession_error,$disabled);

my $counter_id = "saying_form_counter";
my $submit_button_id = "saying_form_submit";

	if( $succession_error = $self->succession_error_message()){
		$disabled = 1;
	}

$form .= qq(<div style="width:14em;">);
$form .= $html->start_tag("form",{ method => "post" });

$form .= $html->input("hidden","mode","create_saying");
$form .= $html->input("hidden","content_number",$content_data->{'number'});

$form .= $html->textarea("saying","",{ style => "width:100%;height:5em;" , id => "saying_submit_textarea" , disabled => $disabled , onkeyup => "count_character_num(value,'$init->{'saying_max_length'}','$counter_id','$submit_button_id');" });

$form .= qq(<div class="right">);
$form .= $html->tag("span",$init->{'saying_max_length'},{ id => $counter_id }) . " ";
$form .= $html->input("submit","","登録する",{ id => $submit_button_id , disabled => $disabled });
$form .= $query->input_hidden_encode();
$form .= qq(</div>);

	if($succession_error){
		$form .= $html->tag("div","※$succession_error",{ class => "alert" });
	}

$form .= qq(</div>);

$form .= $html->close_tag("form");

$form .= $javascript->count_character_num();

$form;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub edit_form_view{

my $self = shift;
my($param) = Mebius::query_single_param();


my $saying_data = $self->number_to_data($param->{'q'});
my $saying_url = $self->data_to_url($saying_data);
my $print = $self->edit_form($saying_data);

my $title = $saying_data->{'text'};

$self->print_html($print,{ h1 => $title , BCL => [{ url => $saying_url , title => $title } ,"編集"] });

exit;

}


#-----------------------------------------------------------
# 編集フォーム
#-----------------------------------------------------------
sub edit_form{

my $self = shift;
my $saying_data = shift || die;
my $basic = $self->basic();
my $content = $self->content();
my $html = new Mebius::HTML;
my($param) = Mebius::query_single_param();
my($form);

	if(!$self->allow_edit($saying_data)){ return(); }

$form .= qq(<div style="max-width:50em;width:100%;">);
$form .= $html->start_tag("form",{ method => "post" });

$form .= qq(発言者: );
$form .= $html->input("text","human",$saying_data->{'human'},{ placeholder => "例)悟空、空条承太郎など" });
$form .= $html->tag("span","※作中でこの台詞を言った人物を入力して下さい。",{ class => "guide " });


$form .= qq(<br>);
$form .= qq(ナンバー: );
$form .= $html->input("text","split_number","$saying_data->{'split_number'}",{ placeholder => "例)2" , style => "width:3em" });
$form .= $html->tag("span","※ たとえばこの台詞が登場したのが第23話であれば 23 などと、数字を入力して下さい。",{ class => "guide " });

$form .= $html->input("hidden","mode","edit_saying");
#$form .= $html->input("hidden","content_number",$content_data->{'number'});
$form .= $html->input("hidden","saying_number",$param->{'q'});

$form .= qq(<div class="margin-top">);
$form .= $html->input("submit","","編集する");
$form .= qq(</div>);

$form .= qq(</div>);

$form .= $html->close_tag("form");

$form;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub sitemap_view{

my $self = shift;
my $year = shift;
my $sitemap = new Mebius::Sitemap;
my $times = new Mebius::Time;
my $year_start_localtime = 0;
my $year_end_localtime = 0;
my(@sitemap_data);

my $year_start_local_time = $times->year_to_localtime_start($year);
my $year_end_local_time = $times->year_to_localtime_end($year);

my $data_group = $self->fetchrow_main_table([ ["deleted_flag","<>",1] , ["create_time",">=",$year_start_local_time] , ["create_time","<=",$year_end_local_time] ]);

	foreach my $data (@{$data_group}){

		push @sitemap_data , { url => $self->data_to_url($data) } ;

	}

$sitemap->print_sitemap(\@sitemap_data);

exit;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub url{

my $self = shift;
my $title = shift;
my $content = $self->content();
my $init = $self->init();
my $saying_number = shift;
my($url);

	if(!$saying_number){ return(); }
	if(!$title){ return(); }

my $title_url = $self->title_url($title);

	if(Mebius::alocal_judge()){
		$url = "${title_url}&amp;q=$saying_number";
	} else {
		$url = "${title_url}?q=$saying_number";
	}

$url;


}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $saying_data = shift;

my $saying_url = $self->url($saying_data->{'content_title'},$saying_data->{'number'});

$saying_url;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub create_border_num{
my $self = shift;
my $init = $self->init();
$init->{'saying_max_create_num'};
}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub adjust_report_data{

my $self = shift;
my $number = shift;
my(%report);

my $data = $self->number_to_data($number);

$report{'targetB'} = $data->{'content_number'};
$report{'targetC'} = $number;

\%report;

}

#-----------------------------------------------------------
# メインモジュールとの関連づけ
#-----------------------------------------------------------
sub basic{
my $self = shift;
my $basic = new Mebius::Saying;
$basic;

}


#-----------------------------------------------------------
# エラー
#-----------------------------------------------------------
sub error{
my $self = shift;
Mebius->error(@_);

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub limited_package_name{
"saying";
}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub japanese_label_name{
"名言";
}

1;
