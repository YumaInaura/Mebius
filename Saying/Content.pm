
use strict;
package Mebius::Saying::Content;
use Mebius::Control;
use Mebius::Sitemap;
use Mebius::SNS;
use Mebius::Javascript;
use base qw(Mebius::Base::DBI Mebius::Saying);
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
"saying_title"
}

#-----------------------------------------------------------
# テーブルのカラム設定
#-----------------------------------------------------------
sub main_table_column{

my $column = {

number => { PRIMARY => 1 } , 
title => { INDEX => 1 } , 

category => {} , 
access_count => { int => 1 } ,

account => { } ,
addr => { } , 
host => { } ,  
cnumber => { } ,
mobile_uid => { } , 
user_id => {} , 

deleted_flag => { int => 1 } ,

create_time => { int => 1 } , 
last_modified => { int => 1 } ,

};

$column;

}



#-----------------------------------------------------------
# 作品登録のためのフォーム
#-----------------------------------------------------------
sub form{

my $self = shift;
my $basic = new Mebius::Saying;
my $init = $basic->init();
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my($my_account) = Mebius::my_account();
my($form,%element,$disabled,$deny_message);

	if( $deny_message = $self->deny_create()){
		$disabled = 1;
	}

$form .= $html->start_tag("form",{ method => "post" });

$form .= $html->input("hidden","mode","create_content");

$form .= $html->input("text","title","",{  placeholder => "例) ジョジョの奇妙な冒険" , disabled => $disabled });
$form .= $html->input("submit","","新しいコンテンツを登録する",{ disabled => $disabled });
$form .= $html->span("※作品名。",{ class => "guide" } );
$form .= $query->input_hidden_encode();
$form .= $html->close_tag("form");

	if($deny_message){
		$form .= $html->tag("div","※$deny_message",{ class => "margin alert" });
	}

$form;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub deny_create{

my $self = shift;
my $sns = new Mebius::SNS;
my $init = $self->init();
my($my_account) = Mebius::my_account();
my($error);

	if($self->account_only_mode() && !$my_account->{'login_flag'}){
		$error = "登録するには". $sns->please_login_link();
	} else {
		$error = $self->succession_error_message();
	}



$error;

}


#-----------------------------------------------------------
# タイトル表示
#-----------------------------------------------------------
sub content_view{

my $self = shift;
my($param) = Mebius::query_single_param();
my $html = new Mebius::HTML;
my $basic = new Mebius::Saying;
my $view = $basic->view();
my $saying = $basic->saying();
my $init = $basic->init();
my $html = new Mebius::HTML;
my $control = new Mebius::Control;
my $javascript = new Mebius::Javascript;
my $times = new Mebius::Time;
my($print,@BCL,$message);

my $select_title = $param->{'content'};
$select_title  =~ s/_/ /g;

my $content_data = $self->fetchrow_main_table({ title => $select_title })->[0] || $self->error("このコンテンツは登録されていません。");
my $saying_dbi = $saying->fetchrow_main_table({ content_number => $content_data->{'number'} },{ ORDER_BY => ["good_num DESC","create_time DESC"] });

$message = $self->deleted_judge($content_data);

push @BCL , $content_data->{'title'};

$print .= $html->tag("strong",$message,{ class => "red" }) if($message);

$print .= e($content_data->{'title'}).qq( の名言/台詞があれば、登録して下さい。);

$print .= $self->data_to_line($content_data,{ NotViewTitle => 1 });

$print .= $saying->form($content_data);

#$print .= $html->tag("h2","一覧");

my $saying_line .= $saying->data_group_to_line($saying_dbi,$content_data) || qq(また登録がありません。);
$print .= $self->around_control_form($saying_line);

$print .= $javascript->push_good("saying_control");

$basic->print_html($print,{ h1 => "$content_data->{'title'}の名言" , Title => "$content_data->{'title'}" , BCL => \@BCL });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_content_view{

my $self = shift;
my $html = new Mebius::HTML;
my($print);

my $title = "コンテンツの新規登録";

$print .= $self->form();

$print .= $html->tag("h2","説明");
$print .= qq(<ul style="margin:1em 0em">);
$print .= qq(<li>「ジョジョの奇妙な冒険」「ドラゴンボール」などの作品名を登録して下さい。);

$print .= qq(</ul>);

$self->print_html($print,{ h1 => $title , Title => $title , BCL => [$title] });

exit;

}


#-----------------------------------------------------------
# 最近登録されたコンテンツ
#-----------------------------------------------------------
sub recently_contents{

my $self = shift;
my $basic = new Mebius::Saying;
my $content = $basic->content();
my $html = new Mebius::HTML;
my($line);

my $content_dbi = $content->fetchrow_main_table({},{ ORDER_BY => ["create_time DESC"] });

$line = $self->data_group_to_line($content_dbi);

$line = qq(<ul>$line</ul>);

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_line{

my $self = shift;
my $data_group = shift;
my $basic = $self->basic();
my $html = new Mebius::HTML;
my($line);

	foreach my $data (@{$data_group}){

		$line .= $self->data_to_list($data);
	}

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $content_data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my $control = new Mebius::Control;
my($print);

	if(!$use->{'NotViewTitle'}){
		my $content_url = $self->data_to_url($content_data);
		$print .= $html->href($content_url,$content_data->{'title'});
	}

$print .= $html->start_tag("div",{ class => "right" });
$print .= "登録 ". $times->how_before($content_data->{'create_time'});
$print .= " " . $self->report_button($content_data); 
$print .= $html->close_tag("div");

$print .= $self->control_parts($content_data);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;
my($mark,$line);

my $encoded_content = Mebius::encode_text($data->{'title'});
my $content_url = $self->url($data->{'title'});
my $link = $html->href($content_url,$data->{'title'});

	if($data->{'deleted_flag'}){
			if(Mebius->common_admin_judge()){
				$mark = $html->span(" [削除済み]",{ class => "red" }) . "\n";
			} else {
				next;
			}
	}

$line .= $html->tag("li","$link$mark",{ NotEscape => 1 });

$line;

}



#-----------------------------------------------------------
# 新しい作品を登録
#-----------------------------------------------------------
sub create_content{

my $self = shift;
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my $basic = new Mebius::Saying;
my $query = new Mebius::Query;
my $text = new Mebius::Text;
my $device = new Mebius::Device;
my $init = $basic->init();

$basic->common_post_check_or_error();

$self->succession_error();

my $new_title = $text->fix_title($param->{'title'});
$new_title = $text->fullsize_to_halfsize($new_title);
my $title_legth = $text->character_num($new_title);

	if( my $error = $text->character_num_error_message($new_title,1,100,"作品名")){
		$self->error($error);
	}

my $same_title = $self->fetchrow_main_table({ title => $new_title })->[0];
	if($same_title){
		$self->error("この作品は既に登録されています。");
	}

	if( my $deny_create = $self->deny_create()){
		$self->error($deny_create);
	}

$self->create_main_table();

my $new_unique_target = Mebius::Crypt->char(20);

my $same_number = $self->fetchrow_main_table({ number => $new_unique_target })->[0];
	if($same_number){
		$self->error("もういちどお試し下さい。");
	}

my %insert = ( title => $new_title , number => $new_unique_target , create_time => time );
%insert = (%insert,%{$device->my_connection()});

	if($self->account_only_mode()){
		$insert{'account'} || die;
	}

$self->insert_main_table(\%insert);

Mebius::redirect($basic->title_url($new_title));

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sitemap_view{

my $self = shift;
my $content_data_group = $self->fetchrow_main_table({ deleted_flag => ["<>",1] });
my($print,@sitemap);
my $sitemap = new Mebius::Sitemap;

	foreach my $data (@{$content_data_group}){
		
		push @sitemap , { url => $self->url($data->{'title'}) , lastmod => $data->{'last_modified'} };

	}

$sitemap->array_to_print(\@sitemap);

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $data = shift;

$self->url($data->{'title'});

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub url{

my $self = shift;
my $title = shift;
my $encoding = new Mebius::Encoding;
my $init = $self->init();
my($url);

	if(!$title){ return(); }

my $encoded_title = $encoding->encode_url($title);

	if(Mebius::alocal_judge()){
		$url = "$init->{'base_url'}?content=$encoded_title";
	} else {
		$url = "$init->{'base_url'}$encoded_title/";
	}

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_report_data{

my $self = shift;
my $number = shift;
my(%report);

$report{'targetB'} = $number;

\%report;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub account_only_mode{
"0";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_border_num{
my $self = shift;
my $init = $self->init();
$init->{'content_create_border_num'};
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
sub limited_package_name{
"content";
}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub japanese_label_name{
"コンテンツ";
}



1;
