
use strict;
use Mebius::Getstatus;
package Mebius::Vine::Post;
use base qw(Mebius::Base::DBI Mebius::Base::Post Mebius::Base::Data Mebius::Vine);

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"vine_post";
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
sub content_target_setting{

my $self = shift;
my $setting = ["target"];

$setting;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub recently_create_line{

my $self = shift;
my($print);

my $data_group = $self->fetchrow_main_table();

my @sorted_data_group = sort { $b->{'create_time'} <=> $a->{'create_time'} } @{$data_group};

$print = $self->data_group_to_line(\@sorted_data_group,{ max_view => 3  });

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $comment = new Mebius::Vine::Comment;
my($print,$audio);

	if( my $embed_tag = $self->embed_tag($data->{'target'},{ AudioOff => $audio })){

		my $response_num = $data->{'response_num'} || 0;

			if($use->{'hit'}){
				$print .= qq(<hr>);
			}
		my $url = $self->data_to_url($data);

			if(!$use->{'NotViewTitle'}){
				$print .= $html->start_tag("h2");
				$print .= $html->href($url,"$data->{'title'}($response_num)");
				$print .= $html->close_tag("h2");
			}

		$print .= $html->start_tag("div");
		$print .= $embed_tag;
		$print .= $html->close_tag("div");

		$print .= $self->data_to_control_parts($data);

		#$print .= $comment->comment_form($data);

	} else {
		return();
	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub self_view{

my $self = shift;
my $vine_target = shift;
my $error = shift;
my $comment = new Mebius::Vine::Comment;
my $text = new Mebius::Text;
my $html = new Mebius::HTML;
my($print);

my $data_group = $self->fetchrow_main_table({ target => $vine_target });
my $data = $data_group->[0];

my $full_title = $data->{'title'};
my $title = $text->omit_character($data->{'title'},20);

	if($data->{'deleted_flag'}){
		$print .= $html->tag("strong","※削除済みページです。",{ class => "red" });
	}

	if($error){
		$print .= $html->div($error,{ class => "red message-red" });
	}

	if($ENV{'REQUEST_METHOD'} eq "GET"){
		$self->read_on_history($data);
	}

my $video_line .= $self->data_to_line($data,{ NotViewTitle => 1 } );
$print .= $self->around_control_form($video_line);

$print .= $comment->comment_form($data);

my $comment_data_group = $comment->fetchrow_main_table({ relation_target => $vine_target });
my @sorted_comment_data_group = sort { $b->{'create_time'} <=> $a->{'create_time'} } @{$comment_data_group};

my $comment_line = $comment->data_group_to_line(\@sorted_comment_data_group);
$print .= $comment->around_control_form($comment_line);

$print .= $comment->push_good_javascript();

$self->print_html($print,{ h1 => $full_title , Title => $title , BCL => [$title] });


exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_form{

my $self = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $sns = new Mebius::SNS;
my $param_utf8 = $query->single_param_utf8_judged_device();
my($print,$disabled_url);

	if(!$self->allow_create()){
		$print .= "動画案内を追加するには".$sns->please_login_link();
		return($print);
	}

$print .= $html->start_tag("form",{ method => "post" });

	if($use->{'Preview'}){
		$disabled_url = 1;
		$print .= $html->start_tag("div",{ class => "alert margin-bottom" });
		$print .= qq(※ご注意 … エロ/グロ/ショッキングな動画や、誹謗中傷/マナーに反する動画は禁止です。);
		$print .= $html->close_tag("div");
	}

	if($use->{'Preview'}){
		$print .= $html->input("hidden","mode","create_post",{ NotOverwrite => 1 });
		$print .= $html->input("hidden","vine_url",$param_utf8->{'vine_url'});
	} else {
		$print .= $html->input("hidden","mode","create_post_preview");
		$print .= $html->input("url","vine_url",undef,{ placeholder => "例) https://vine.co/v/bgLMlhO3lYh" , style => "width:12em;" , disabled => $disabled_url });
	}

	if($use->{'Preview'}){
		#$print .= $html->tag("textarea","",{ name => "title" , placeholder => "動画の説明を入力して下さい。" , style => "width:100%;max-width:50em;height:5em;" , class => "block" });
		$print .= "説明 ".$html->input("text","title","",{ placeholder => "動画の見出し・簡単な説明を入力して下さい。" , style => "width:30em;"  });
	}

$print .= $html->input("submit","","VineのURLを送信");

	if($use->{'Preview'}){

	} else {
		my $id = "vine_guide_on_top_page";

		$print .= $html->start_tag("span",{ class => "guide " });
		$print .= $html->href("#","※使い方",{ onclick => "vswitch('$id','inline');" , class => "fold" });
		$print .= $html->start_tag("span",{ id => $id , class => "none" });
		$print .= qq( … スマートフォンやタブレットで<a href="https://vine.co/" class="blank" target="_blank">Vineアプリ</a>をダウンロードし、好きな動画で「…」→「Share this post」→「copy link」を選びます。そこで得られたURLと一緒に、動画の解説を登録して下さい。);
		$print .= $html->close_tag("span");
		$print .= $html->close_tag("span");
	}

$print .= $html->close_tag("form");

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_post_preview{

my $self = shift;
my $query = new Mebius::Query;
my $mebius = new Mebius;
my $html = new Mebius::HTML;
my $param_utf8 = $query->single_param_utf8_judged_device();
my($print,$vine_target);

my $title = "投稿確認";

$mebius->axs_check();

	if( $vine_target = $self->vine_url_to_vine_target($param_utf8->{'vine_url'}) ){

			if( my $error = $self->common_post_error($vine_target)){
				main::error($error);
			}

	} else {
		main::error("VineのURLを認識できませんでした。");
	}

my $embed_tag = $self->embed_tag($vine_target);

$print .= $html->start_tag("div");
$print .= $embed_tag;
$print .= $html->close_tag("div");

$print .= $self->create_form({ Preview => 1 });

$self->print_html($print,{ h1 => $title , Title => $title , BCL => [$title] });

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_post{

my $self = shift;
my $init = $self->init();
my $query = new Mebius::Query;
my $param_utf8 = $query->single_param_utf8_judged_device();
my $text = new Mebius::Text;
my $device = new Mebius::Device;
my $mebius = new Mebius;
my $crypt = new Mebius::Crypt;
my(%insert,$target);

my $video_title = $param_utf8->{'title'};

$mebius->axs_check();

	if(!$query->post_method()){
		main::error("GET送信はできません。");
	}


	if($text->character_num($video_title) < 10){
		main::error("動画の説明文が短すぎます。");
	}

	if( my $vine_target = $self->vine_url_to_vine_target($param_utf8->{'vine_url'})){
		$target = $insert{'target'} = $vine_target;
			if( my $error = $self->common_post_error($vine_target)){
				main::error($error);
			}
	} else {
		main::error("VineのURLが認識できませんでした。");
	}

#$insert{'target'} = $crypt->char(35);
$insert{'title'} = $video_title;
$insert{'deleted_flag'} = 0;
$insert{'create_time'} = time;

my $insert_with_connection = $device->add_hash_with_my_connection(\%insert);

$self->create_common_history_on_post({ content_targetA => $target , subject => $video_title , content_create_time => time  });

#	if(Mebius::alocal_judge()){ Mebius::Debug::print_hash(\%insert); }

my $success = $self->update_or_insert_main_table($insert_with_connection,{ Debug => 0 });

Mebius::redirect($init->{'base_url'});

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub common_post_error{

my $self = shift;
my $vine_target = shift || (warn && return());
my($error,$status);

my $vine_url = $self->vine_target_to_vine_url($vine_target);
my $still_data = my $exists_data = $self->fetchrow_main_table({ target => $vine_target })->[0];

	if($still_data->{'full_deleted_flag'}){
		$error = qq(この動画を登録することは出来ません。);
	}	elsif($exists_data && !$still_data->{'deleted_flag'}){ # !Mebius::alocal_judge()
		$error = qq(既に他の人が登録済みの動画です。);
	} elsif($vine_url){
		$status = $self->vine_target_to_video_status_code($vine_target);
			if($status ne "200"){
				$error = qq(存在しない、または削除済みの動画です。);
			}
	}


$error;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub vine_target_to_video_status_code{

my $self = shift;
my $vine_target = shift || (warn && return());
my $get_page = new Mebius::GetPage;

my $vine_url = $self->vine_target_to_vine_url($vine_target);

my $video_url = "$vine_url/embed/simple";

my $status_code = $get_page->get_status($video_url);

$status_code;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub allow_create{

my $self = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($flag);

	if($my_account->{'login_flag'}){
		$flag = 1;
	}elsif($my_cookie->{'char'}){
		$flag = 1;
	} else {
		0;
	}

$flag = 1;

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $data = shift;
my $init = $self->init();
my($url);
my $target = $data->{'target'};
#$data->{'content_targetA'} || 

$url = "$init->{'base_url'}v/$target";

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub use_full_delete{
1;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"post";
}



1;

