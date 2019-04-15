
use strict;
package Mebius::Video::Post;
use Mebius::Video::Basic;
use Mebius::Video::Video;
use Mebius::Video::Chapter;
use Mebius::Video::Tag;
use Mebius::Getpage;
use Mebius::Video::PushGoodPost;
use Mebius::Export;

use base qw(Mebius::Base::DBI Mebius::Base::Post Mebius::Base::Data Mebius::Base::Tag);

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
sub main_limited_package_name{
"video";
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
response_num => { int => 1 } , 

create_time => { int => 1 , INDEX => 1 } , 
comment_num => { int => 1 } , 
last_modified => { int => 1 } , 
total_good_num => { int => 1 } , 

deleted_flag => { int => 1 } ,
penalty_flag => { int => 1 } ,

};

$column;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic_object{
my $self = shift;
my $basic = new Mebius::Video;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my($param) = Mebius::query_single_param();
my $basic = $self->basic_object();
my $mebius = new Mebius;

my($mode,$must_post_method_flag);

$mebius->axs_check();

	if(!$self->allow_post_judge()){
		$basic->error("投稿が許可されていません。");
	}

	if($param->{'title'} && $param->{'text'} && $param->{'submit'}){
		$mode = "submit";
	} elsif($param->{'title'} && $param->{'text'}){
		$mode = "guide";
	} elsif($param->{'title'}){
		$mode = "url";
	} else {
		$mode = "title";
	}


	if( $ENV{'REQUEST_METHOD'} eq "POST" && (my @error = $self->title_length_check($param->{'title'})) ){
		$self->create_title_view("@error");
	} 

	if($param->{'title'} && $param->{'title'} =~ /http:/){
		$self->create_title_view("まとめのタイトルにURLは使えません。");
	}


	if( my @error = $self->redun_submit_check()){
		$self->input_video_url_view("@error");
	}

	if( my @error = $self->deleted_history_check()){
		$self->input_video_url_view("@error");
	}


	if( ($mode eq "submit" || $mode eq "guide") && (my @error = $self->text_to_video_num_check($param->{'text'})) ){
		$self->input_video_url_view("@error");
	}

	if(!Mebius::alocal_judge() && $param->{'title'} && ( my @error = $self->title_redun_check($param->{'title'})) ){
		$self->input_video_url_view("@error");
	}

	if( $mode eq "submit"  && (my @error = $self->text_to_video_data_check($param->{'text'})) ){
		$self->input_guide_videos_view(\@error);
	}

	if( $param->{'tag'}){
			my @tag = $self->text_splited_space_to_tags($param->{'tag'});
			if(@tag > 5){
				$self->input_guide_videos_view("タグの数が多すぎます。");
			}
	}

	if($mode eq "submit"){
		$self->create_new_page();	
	} elsif($mode eq "guide"){
		$self->input_guide_videos_view();
	} elsif($mode eq "url"){
		$self->input_video_url_view();
	} else {
		$self->create_title_view();
	}


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_video_data_check{

my $self = shift;
my $check = shift;
my $text = new Mebius::Text;
my $basic = $self->basic_object();
my $get_page = new Mebius::Getpage;
my(@error,$count);

my @video_data = $self->text_to_video_datas($check);

	foreach my $data (@video_data){

		my $title_length = $text->character_num_pure($data->{'title'});
		my $title_length_min = $text->character_num($data->{'title'});
		my $text_length = $text->character_num_pure($data->{'text'});

		my $api_data = $basic->video_id_to_api_data_on_cache($data->{'video_id'});

		$count++;

			if(!$api_data->{'title'}){
				push @error , e($count) . "番目の動画は存在しません。  " . e($data->{'video_id'});
			}

			if($self->must_title_switch() && $title_length_min < 5){
				push @error , e($count) . "番目の動画タイトルが短すぎます。  " . e($data->{'video_id'});
			}

			if($title_length > 50){
				push @error , e($count) . "番目の動画タイトルが長過ぎます。  " . e($data->{'video_id'});
			}
			if($text_length > 2000){
				push @error , e($count) . "番目の動画解説が長過ぎます。  " . e($data->{'video_id'});
			}
	}

@error;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"video_post";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub self_view{

my $self = shift;
#my $target_id = shift;
my $basic = $self->basic_object();
my $html = new Mebius::HTML;
my $chapter = new Mebius::Video::Chapter;
my $push_good = new Mebius::Video::PushGoodPost;
my($param) = Mebius::query_single_param();
my($print,$control,$page_title,$head_title,@BCL);

my $target = $param->{'v'} || die;
my $post_data = $self->fetchrow_main_table({ target => $target })->[0];
my $url = $self->data_to_url($post_data);

	# CHAPTER MODE
	if( my $chapter_target = $param->{'chapter'}){
		my $video_data = $chapter->fetchrow_main_table({ target => $chapter_target })->[0];
		$page_title = $post_data->{'title'};
		$head_title = "$video_data->{'title'} | $page_title";
		push @BCL , { url => $url ,  title => $page_title  };
		push @BCL , $video_data->{'title'};
	# PAGE MODE
	} else {
		$page_title = $head_title = $post_data->{'title'};
		push @BCL , $page_title;
	}

$control .= qq(<div class="right">);
$control .= $self->report_button($post_data);
$control .= qq(</div>);

$control .= $self->data_to_line($post_data);
$control .= $self->push_good_javascript();
$control .= $html->input("hidden","v",$target);

$print .= $self->data_to_deleted_error($post_data);
$print .= $self->around_control_or_report_form($control,$post_data);

$basic->print_html($print,{ Title => $head_title , h1 => $page_title , BCL => \@BCL });

exit;


}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $data = shift;
my $use = shift;
my $chapter = new Mebius::Video::Chapter;
my $push_good = new Mebius::Video::PushGoodPost;
my $tag = new Mebius::Video::Tag;
my($param) = Mebius::query_single_param();
my($print);

my $video_data_group = $chapter->fetchrow_main_table({ relation_target => $data->{'target'} });
my @sorted_video_data_group = sort{ $a->{'number_per_post'} <=> $b->{'number_per_post'} } @{$video_data_group};

	if($use->{'view_report_mode'}){
		$print .= $self->data_to_h1_link($data);
	}

$print .= $tag->relation_data_to_list($data);

	if(!$self->report_preview_mode()){
		$print .= $self->data_to_control_parts($data);
			if(!$use->{'view_report_mode'}){
				$print .= $push_good->good_button($data,{ NewMode => 1 });
			}
	}

	foreach my $video_data (@sorted_video_data_group){
			if($param->{'chapter'} && $param->{'chapter'} ne $video_data->{'target'}){
				next;
			}
		$print .= qq(<div>);
		$print .= $chapter->data_to_line($video_data);
		$print .= qq(</div>);

	}

$print;
}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub input_guide_videos_view{

my $self = shift;
my $error = shift;
my $basic = new Mebius::Video;
my $html = new Mebius::HTML;
my($param) = Mebius::query_single_param();
my($my_use_device) = Mebius::my_use_device();
my($print,$count,$width);

my $page_title = "動画の解説";

my @video_data = $self->text_to_video_datas($param->{'text'});


$print .= $self->error_to_message($error);


$print .= qq(<form action="" method="post">);

$print .= $self->title_to_input_box($param->{'title'});

$print .= $html->input("hidden","mode","create");


	if($my_use_device->{'smart_phone_flag'}){
		$width = "width:90%;";
	} else {
		$width = "width:560px;";
	}

	foreach my $data (@video_data){

		$count++;

		my $video_id = $data->{'video_id'};
		my $start_time = $data->{'start_time'};

		my($autofocus);

			if($count == 1){
				$autofocus = 1;
			}

		my $video_url = $basic->video_id_to_video_url($video_id,$start_time);
		my $video_input_name = "video_introduce_${video_id}";
		my $max_length = $self->max_produce_length();
		my $min_length = $self->min_produce_length();


		$print .= qq(<div style="margin:1em 0em 2em 0em;">);

		$print .= qq(<div>);
		$print .= $html->input("hidden","text",$video_url,{ NotOverwrite => 1 });
		$print .= $html->tag("textarea",$param->{$video_input_name},{ name => $video_input_name , style => "font-size:180%;border:3px dashed #aaa;height:3em;${width}" , placeholder => "解説を入力してください。1行目がタイトル、2行目以降が解説になります。" ,tabindex => $count , autofocus => $autofocus });
		$print .= qq(</div>);

		$print .= $basic->video_id_to_embed_tag($video_id,$start_time);
		$print .= qq(</div>);
	}

$print .= $html->tag("h2","#タグ");
#my $tags = $self->text_to_tags_with_marks($param->{'text'});
my @tag = $self->text_splited_space_to_tags($param->{'tag'});

my $tags = join " " , @tag;

$print .= $html->tag("textarea",$tags,{ name => "tag" ,  style => "display:block;font-size:160%;font-weight:bold;$width"  , tabindex => 99 });
$print .= qq(<div><span class="guide">※スペースや改行で区切ってタグを付けてください。 例: #ポップス #お笑い  </span></div>);

$print .= $html->input("submit","submit","投稿する",{ class => "isubmit" , style => "background-color:#f99;font-weight:bold;" , tabindex => 100 });

$print .= qq(</form>);

$basic->print_html($print,{ h1 => $page_title , Title => $page_title , BCL => ["$page_title"] });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub input_video_url_view{

my $self = shift;
my $error = shift;
my $basic = new Mebius::Video;
my $html = new Mebius::HTML;
my($print);
my($param) = Mebius::query_single_param();

#my $page_title = $param->{'title'};
my $page_title = "新規登録";

$print .= $html->start_tag("form",{ action => "" , method => "post" });
$print .= $html->input("hidden","mode","create");
#$print .= $html->input("hidden","title",$param->{'title'});

$print .= $self->error_to_message();

$print .= $self->title_to_input_box($param->{'title'});
$print .= qq(<textarea name="text" style="width:90%;height:20em;" autofocus="1"  placeholder="※Video動画のURLを1行ずつ入力してください">);
	if($param->{'text'} && $ENV{'REQUEST_METHOD'} eq "POST"){
		$print .= e($param->{'text'});
	} elsif(Mebius::alocal_judge()) {
		$print .= qq(http://youtu.be/vlZ4Ap6pL3A?t=3m32s) . "\n";
		$print .= qq(https://www.youtube.com/watch?v=hNGOl_vyCdw) . "\n";
		$print .= qq(https://www.youtube.com/watch?v=6nePeXZ4tTc) . "\n";
	}
$print .= qq(</textarea>);

$print .= qq(<div>);
$print .= $html->input("submit","","次に進む",{ class => "isubmit" });
$print .= qq(</div>);

$print .= $html->close_tag("form");


$basic->print_html($print,{ h1 => $page_title , Title => $page_title , BCL => ["$page_title"] });

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_video_datas{

my $self = shift;
my $text = shift;
my $basic = new Mebius::Video;
my $video_url_format = $basic->video_url_format();
my(%video_kind,@video_id);
my($param) = Mebius::query_single_param();

	while($text =~ s!($video_url_format)!!e){

		my $video_url = $1;
		my $minute_and_second = $2;
		my $video_id = $basic->video_url_to_video_id($video_url);
		my $start_time = $basic->video_url_to_start_time($video_url);
		my $title = $self->text_to_title($param->{"video_introduce_$video_id"});

		my $introduce = $self->text_to_introduce($param->{"video_introduce_$video_id"});

			if($video_kind{$video_id}){ next; }
		push @video_id , { video_id => $video_id , start_time => $start_time , title => $title , text => $introduce };
		$video_kind{$video_id} = 1;

	}

@video_id;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_title{

my $self = shift;
my $text = shift || return();
my($title);

$text =~ s/\r//g;

my @text = split(/\n/,$text);

	foreach my $text_per_line (@text){
			if($text_per_line =~ /^[\s\t　\n\r]+$/){
				next;
			} else {
				$title = $text_per_line;
				last;
			}
	}

$title;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_introduce{

my $self = shift;
my $text = shift || return();
my($introduce,$title_flag);

$text =~ s/\r//g;

my @text = split(/\n/,$text);

	foreach my $text_per_line (@text){
			if($text_per_line =~ /^[\s\t　\n\r]+$/){
				next;
			} else {
					if(!$title_flag){
						$title_flag = 1;
					} else {
						$introduce .= $text_per_line . "\n";
					}
			}
	}

$introduce;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_video_ids{

my $self = shift;
my $text = shift;
my $basic = new Mebius::Video;
my $video_url_format = $basic->video_url_format();
my(%video_kind,@video_id);

	while($text =~ s!($video_url_format)!!e){

		my $video_url = $1;
		my $video_id = $basic->video_url_to_video_id($video_url);
			if($video_kind{$video_id}){ next; }
		push @video_id , $video_id;
		$video_kind{$video_id} = 1;

	}

@video_id;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub title_to_input_box{

my $self = shift;
my $title = shift;
my $html = new Mebius::HTML;

my $print = $html->input("text","title",$title,{ style => "font-size:200%;font-weight:bold;width:90%;border:1px none #ddd;" });
$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_title_view{

my $self = shift;
my $error = shift;
my $basic = new Mebius::Video;
my $html = new Mebius::HTML;
my($print);

my $page_title = "新規登録";

#$print .= qq(まとめのタイトル：<br>);
$print .= $html->tag("h2","まとめのタイトル");

$print .= $self->error_to_message();

$print .= $html->start_tag("form",{ action => "" , method => "post" });
$print .= $html->input("hidden","mode","create");
$print .= $html->input("text","title","",{ style => "font-size:140%;width:20em;" , autofocus => 1 , placeholder => "まとめのタイトルを入力してください。" });
$print .= $html->input("submit","","次に進む",{ class => "isubmit" });
$print .= $html->close_tag("form");

$basic->print_html($print,{ h1 => $page_title , Title => $page_title , BCL => ["$page_title"] });

exit;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_new_page{

my $self = shift;
my $query = new Mebius::Query;
my($param) = Mebius::query_single_param();
my $basic = $self->basic_object();
my $device = new Mebius::Device;
my $crypt = new Mebius::Crypt;
my $tag = new Mebius::Video::Tag;

my(%insert);

$insert{'title'} = $param->{'title'};
my $target = $insert{'target'} = $self->new_target_char(20);
$insert{'last_modified'} = time;

#my @tag = $self->text_to_tags($param->{'text'});
#my @tag = $self->text_to_tags_on_comma($param->{'tag'});

my $insert_with_connection = $device->add_hash_with_my_connection(\%insert);
$self->insert_main_table($insert_with_connection);

$self->submit_videos(\%insert);

$tag->text_splited_space_to_submit_tags($param->{'tag'},\%insert);

$self->redirect_to_self_page(\%insert);
#$basic->print_html("投稿しました。");

exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_videos{

my $self = shift;
my $post_data = shift;
my $chapter = new Mebius::Video::Chapter;
my($param) = Mebius::query_single_param();
my($count);

my @video_data = $self->text_to_video_datas($param->{'text'});

	foreach my $data (@video_data){
		my $target = $chapter->new_target_char(20);
		my $video_id = $data->{'video_id'};

		$count++;
		$chapter->insert_main_table({ title => $data->{'title'} , text => $data->{'text'} , target => $target , video_id => $video_id , start_time => $data->{'start_time'} , relation_target => $post_data->{'target'} , number_per_post => $count });
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_video_num_check{

my $self = shift;
my $target_param = shift;
my(@error);

my $video_max_border = 10;
my $video_min_border = 1;

my @video_id = $self->text_to_video_ids($target_param);

	if(@video_id > $video_max_border){
		push @error , qq(動画の数が多すぎます。);
	}	elsif(@video_id < $video_min_border){
		push @error , qq(動画の数が少なすぎます。 <a href="https://www.youtube.com/watch?v=6nePeXZ4tTc" target="_blank" class="blank">https://www.youtube.com/watch?v=6nePeXZ4tTc</a> というような形式でYoutube動画のURLを入力してください。);
	}

@error;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub title_length_check{

my $self = shift;
my $target_param = shift;

my @error = $self->length_check($target_param,"タイトル",1,50);

@error;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub title_redun_check{

my $self = shift;
my $new_title = shift;

my $still_data = $self->fetchrow_main_table({ title => $new_title })->[0];

	if($still_data){ return("このタイトルはもう他の誰かが使っています。別のタイトルを付けてください。"); } else { return(); }

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub max_produce_length{
"50";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub min_produce_length{
"1";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub allow_post_judge{

my $self = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($flag);

	if($my_account->{'login_flag'} || $my_cookie->{'char'}){
		$flag = 1;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $data = shift;
my $basic = $self->basic_object();
my($url);

my $site_url = $basic->site_url();

$url = "${site_url}?v=$data->{'target'}";

$url;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub must_title_switch{
1;
}



1;

