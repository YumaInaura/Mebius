
use strict;
#use Mebius::Saying::View;
use Mebius::Saying::Content;
use Mebius::Saying::Review;
use Mebius::Saying::Saying;
use Mebius::Saying::Comment;
use Mebius::Penalty;
use Mebius::Encode;
package Mebius::Saying;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub init{

my $self = shift;
my %init;

$init{'title'} = "名言処";
$init{'title_read'} = "めいげんどころ";

	if(Mebius::alocal_judge()){
		$init{'base_url'} = "http://localhost/_saying/";
	} else {
		$init{'base_url'} = "http://saying.mb2.jp/";
	}

# タイトルの連続投稿禁止設定
$init{'content_create_border_num'} = 3;
$init{'content_create_border_hour'} = 24;

# 名言の連続投稿禁止設定
$init{'saying_create_border_hour'} = 24;
$init{'saying_max_create_num'} = 10;
$init{'saying_max_length'} = 140;

$init{'review_create_border_num'} = 24;
$init{'review_max_length'} = 1000;

$init{'comment_create_border_num'} = 24;
$init{'comment_max_length'} = 500;
$init{'comment_min_length'} = 1;

$init{'service_start_year'} = 2013;

\%init;

}


#-----------------------------------------------------------
# モード分岐
#-----------------------------------------------------------
sub junction{

my $self = shift;
my($param) = Mebius::query_single_param();
my $content = $self->content();
my $saying = $self->saying();
my $review = $self->review();
my $comment = $self->comment();
my $query = new Mebius::Query;

	if($param->{'tail'} eq ""){

			if($param->{'mode'} eq ""){

					if($param->{'content'}){
							if($param->{'q'}){
									if($param->{'edit'}){
										$saying->edit_form_view();
									} else {
										$saying->saying_view();
									}
							} else {
								$content->content_view();
							}
					} else {
						$self->top_page_view();
					}
			} elsif($param->{'mode'} eq "search"){
				$self->search_view();
			} elsif($param->{'mode'} eq "create_content_view"){
				$content->create_content_view();
			} elsif($param->{'mode'} eq "create_content"){
				$content->create_content();
			} elsif($param->{'mode'} eq "create_saying"){
				$saying->create_saying();
			} elsif($param->{'mode'} eq "edit_review"){
				$review->edit_review();
			} elsif($param->{'mode'} eq "edit_review_form"){
				$review->edit_or_submit_view();
			} elsif($param->{'mode'} eq "create_review"){
				$review->create_review();
			} elsif($param->{'mode'} eq "comment"){
				$comment->create_comment();
			} elsif($param->{'mode'} eq "edit_saying"){
				$saying->edit_saying();
			} elsif($param->{'mode'} eq "control"){
				$self->query_to_control();
			} else {
				Mebius->error("モードを選択して下さい。");
			}

	} elsif($param->{'tail'} eq "xml"){

		if($param->{'mode'} =~ /^content_sitemap_([0-9]+)$/){
			$content->sitemap_view($1);
		} elsif($param->{'mode'} =~ /^saying_sitemap_([0-9]+)$/){
			$saying->sitemap_view($1);
		} elsif($param->{'mode'} eq "content_sitemap_index"){
			$content->sitemap_index_view($1);
		} elsif($param->{'mode'} eq "saying_sitemap_index"){
			$saying->sitemap_index_view($1);

		} else {
			Mebius->error("モードを選択して下さい。");
		}

	} else {
		Mebius->error("モードを選択して下さい。");
	}


}

#-----------------------------------------------------------
# いろいろな操作
#-----------------------------------------------------------
sub query_to_control{

my $self = shift;
my $use = shift;
my($param) = Mebius::query_single_param();
my $saying = $self->saying();
my $review = $self->review();
my $comment = $self->comment();
my $content = $self->content();
my $report = new Mebius::Report;
my (@report);

	foreach my $name ( %{$param} ){

		my $value = $param->{$name};

			if(!$value){ next; }

			if($name =~ /^saying_saying_push_good_(.+)$/){
				my $saying_number = $1;
				$saying->push_good($saying_number);
				last;
			}	elsif($name =~ /^saying_review_push_good_(.+)$/){
				my $review_number = $1;
				$review->push_good($review_number);
				last;

			}	elsif($name =~ /^saying_saying_control_(.+)$/){
				my $saying_number = $1;
				$saying->control($saying_number,$param->{$name});
			}	elsif($name =~ /^saying_content_control_(.+)$/){
				my $content_number = $1;
				$content->control($content_number,$param->{$name});
			} elsif($name =~ /^saying_review_control_(.+)$/){
				my $review_number = $1;
				$review->control($review_number,$param->{$name});
			} elsif($name =~ /^saying_comment_control_(.+)$/){
				my $comment_number = $1;
				$comment->control($comment_number,$param->{$name});

			} elsif($name =~ /^saying_content_report_preview_(.+)$/){
				$content->report_preview($1);
			} elsif($name =~ /^saying_saying_report_preview_(.+)$/){
				$saying->report_preview($1);
			} elsif($name =~ /^saying_review_report_preview_(.+)$/){
				$review->report_preview($1);
			} elsif($name =~ /^saying_comment_report_preview_(.+)$/){
				$comment->report_preview($1);

			}

	}


	if(!$use->{'NotRedirect'}){
		Mebius::redirect_to_back_url() || $self->print_html("実行しました。",{ BCL => ["操作"] });
		exit;
	}



}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub single_query_to_report_data{

my $self = shift;
my $query_name = shift || return();
my($param) = Mebius::query_single_param();
my(%report);

my $limited_package_name = $self->limited_package_name();
my $report_query_name = $self->report_query_name();

	if($query_name =~ /^${report_query_name}_([^_]+)$/){
		my $number = $1;
		$report{'target_unique_number'} = $number;
		$report{'content_type'} = "saying";
		$report{'targetA'} = $limited_package_name;

		my $adjusted_report = $self->adjust_report_data($number);
		%report = (%report,%{$adjusted_report});
		return \%report;
	} else {
		return();
	}

}


#-----------------------------------------------------------
# review /comment - common action
#-----------------------------------------------------------
sub adjust_report_data{

my $self = shift;
my $number = shift;
my(%report);

my $data = $self->number_to_data($number);

$report{'targetB'} = $data->{'content_number'};
$report{'targetC'} = $data->{'saying_number'};
$report{'targetD'} = $number;

\%report;

}



#-----------------------------------------------------------
# カテゴリ設定
#-----------------------------------------------------------
sub all_categories{

my $category = {
comic => { title => "漫画" } , 
animation => { title => "アニメ" } , 
movie => { title => "映画" } , 
game => { title => "ゲーム" } , 
drama => { title => "ドラマ" } , 
human => { title => "人物" } , 

};

$category;

}


#-----------------------------------------------------------
# 共通のエラーチェック
#-----------------------------------------------------------
sub common_post_check_or_error{

my $self = shift;
my($my_account) = Mebius::my_account();
my $query = new Mebius::Query;
my $content = $self->content();

Mebius->axs_check("ACCOUNT");

	if(!$my_account->{'login_flag'} && $self->account_only_mode()){
		Mebius->error("ログインして下さい。");
	}

	if(!$query->post_method()){
		Mebius->error("GET送信はできません。");
	}

}


#-----------------------------------------------------------
# 名言データからコンテンツデータを取得
#-----------------------------------------------------------
sub saying_data_to_content_data{

my $self = shift;
my $saying_data = shift;
my $content = new Mebius::Saying::Content;

my $content_data = $content->fetchrow_main_table({ number => $saying_data->{'content_number'} })->[0];

$content_data;


}



#-----------------------------------------------------------
# トップページ
#-----------------------------------------------------------
sub top_page_view{

my $self = shift;
my $init = $self->init();
my $content = $self->content();
my($my_account) = Mebius::my_account();
my $html = new Mebius::HTML;
my $sns = new Mebius::SNS;
my $print;

$print .= $html->tag("div",qq($init->{'title'}).qq(は、色々な名言や台詞を登録できるやつです。),{ class => "margin-bottom" });
#まずは作品名などを「コンテンツ」として登録し、その中に名言/台詞を登録して下さい。

#$print .= $content->form();

#$print .= $html->tag("h2","検索");
$print .= $self->search_form();

$print .= $html->tag("h2","最近登録されたコンテンツ");

$print .= $html->start_tag("div",{ class => "margin-bottom" });

	if($my_account->{'login_flag'} || !$content->account_only_mode()){
		$print .= $html->href("$init->{'base_url'}create_content_view","→新しいコンテンツの登録");
	} else {
		$print .= "→コンテンツを登録するには" . $sns->please_login_link();
	}

$print .= $html->close_tag("div");

$print .= $content->recently_contents();

	if(Mebius::alocal_judge()){
		
		my $report_line .= $html->tag("h2","違反報告(ローカル用)");
		$report_line .= $self->report_line();
		$print .= $self->around_control_form($report_line);
		
	}

$self->print_html($print,{ h1 => $init->{'title'} , ContentsTopPage => 1 , });

exit;

}

#-----------------------------------------------------------
# 共通のHTMLを出力
#-----------------------------------------------------------
sub print_html{

my $self = shift;
my $print_body = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $text = new Mebius::Text;
my $init = $self->init();
my($print,@BCL);

	if($use->{'ContentsTopPage'}){
		push @BCL , $init->{'title'};
	} else {
		push @BCL , { url => $init->{'base_url'} , title => $init->{'title'} } ;
	}

push @BCL , @{$use->{'BCL'}} if(ref $use->{'BCL'} eq "ARRAY");
my $relay_use = Mebius::Operate->overwrite_hash($use,{ source => "utf8" , BCL => \@BCL });

	if($relay_use->{'Title'}){
		#$relay_use->{'Title'} = $text->omit_character($relay_use->{'Title'},25) . qq( | $init->{'title'});
		$relay_use->{'Title'} = $relay_use->{'Title'} . qq( | $init->{'title'});
	} else {
		$relay_use->{'Title'} = $init->{'title'};
	}

$print .= $html->tag("h1",$use->{'h1'});
$print .= $print_body;

$print .= $html->start_tag("div",{ class => "right" });
#$print .= $html->tag("h2","検索");
$print .= $self->search_form();
$print .= $html->close_tag("div");

Mebius::Template::gzip_and_print_all($relay_use,$print);

}


#-----------------------------------------------------------
# タイトルページのURL
#-----------------------------------------------------------
sub title_url{

my $self = shift;
my $content = $self->content();

$self->content->url(@_);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub control{

my $self = shift;
my $number = shift;
my $control_type = shift;
my $penalty = new Mebius::Penalty;
my $report = new Mebius::Report;
my $init = $self->init();
my(%update);
my $limited_package_name = $self->limited_package_name();

$update{'number'} = $number;

	if(!Mebius->common_admin_judge()){
		return();
	}

my $data = $self->fetchrow_main_table({ number => $number })->[0];

	if(!$data){
		return();
	}

	if($control_type eq "delete" && !$data->{'deleted_flag'}){

		$update{'deleted_flag'} = 1;

	} elsif($control_type eq "penalty" && !$data->{'deleted_flag'} && Mebius->common_admin_judge()){

		$update{'deleted_flag'} = 1;
		$update{'penalty_flag'} = 1;

		$penalty->add($data,{ place => $init->{'title'} , source => "utf8" });

	} elsif($control_type eq "revive" && $data->{'deleted_flag'} && Mebius->common_admin_judge()){
		$update{'deleted_flag'} = 0;

			if($data->{'penalty_flag'}){
				$update{'penalty_flag'} = 0;
				$penalty->cancel($data,{ place => $init->{'title'} , source => "utf8" });
			}

	} else {
		return();
	}

$report->update_main_table({ answer_time => time },{ WHERE => { content_type => "saying" , targetA => $limited_package_name , target_unique_number => $number } });

$self->update_main_table(\%update);

}


#-----------------------------------------------------------
# いいね！ ボタン
#-----------------------------------------------------------
sub good_button{

my $self = shift;
my $data = shift || die;
my $use = shift || {};
my $html = new Mebius::HTML;
my($button,$onclick,$id,$disabled);

my $limited_package_name = $self->limited_package_name();

my $good_num = $data->{'good_num'} || 0;

	if(!$use->{'Debug'}){
		$onclick = qq(push_good({},this,$good_num,1);return false;);
		$id = "saying_${limited_package_name}_push_good_$data->{'number'}";

			if($self->still_push_good($data)){
				$disabled = 1;
			}
	}

$button = $html->input("submit","saying_${limited_package_name}_push_good_$data->{'number'}","いいね($good_num)",{ onclick => $onclick , id => $id ,  disabled => $disabled });

$button;

}

#-----------------------------------------------------------
# いいね！を押す
#-----------------------------------------------------------
sub push_good{

my $self = shift;
my $number = shift;
my $basic = $self->basic();
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my $operate = new Mebius::Operate;
my $data = $self->number_to_data($number);
my $debug = new Mebius::Debug;
my $query = new Mebius::Query;
my(@update_good_addrs,$dupulicate_flag);

Mebius->axs_check();

$query->post_method_or_error();

	if($self->still_push_good($data) && !$debug->escape_error()){
		$self->error("既にいいねを押しています。");

	} else{

		my @good_addrs = $operate->push_limited_num($data->{'good_addrs'} , $ENV{'REMOTE_ADDR'} , 50);
		my @good_cnumbers = $operate->push_limited_num($data->{'good_cnumbers'} , $my_cookie->{'char'} , 50);
		my @good_accounts = $operate->push_limited_num($data->{'good_accounts'} , $my_account->{'id'});

		$self->update_main_table({ number => $number , good_num => ["+",1] , good_addrs => "@good_addrs" , good_cnumbers => "@good_cnumbers" , good_accounts => "@good_accounts" }) || $self->error("更新できませんでした。");

	}

#my $saying_url = $basic->saying_url($content_data->{'title'},$data->{'number'});

Mebius::redirect_to_back_url() || $self->print_html("いいねを押しました。");

exit;

}


#-----------------------------------------------------------
# 既にいいねを押している場合
#-----------------------------------------------------------
sub still_push_good{

my $self = shift;
my $data = shift || die;
my $operate = new Mebius::Operate;
my($still_flag);
my($my_cookie) = Mebius::my_cookie_main();
my($my_account) = Mebius::my_account();

	if($operate->element_in_array($data->{'good_addrs'},$ENV{'REMOTE_ADDR'})){
		$still_flag = 1;
	}

	if($operate->element_in_array($data->{'good_accounts'},$my_account->{'id'})){
		$still_flag = 1;
	}

	if($operate->element_in_array($data->{'good_cnumbers'},$my_cookie->{'char'})){
		$still_flag = 1;
	}

$still_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub around_control_form{

my $self = shift;
my $inline_html = shift;
my $form_id = shift || "saying_control";
my $html = new Mebius::HTML;
my($print);

$print .= $html->start_tag("form",{ method => "post" , id => $form_id , action => "" } );
$print .= $html->input("hidden","mode","control");
$print .= Mebius::back_url_input_hidden();
$print .= $inline_html;

$print .= $html->close_tag("form");

$print;

}


#-----------------------------------------------------------
# 名言本体のURL
#-----------------------------------------------------------
sub saying_url{

my $self = shift;
my $saying = $self->saying();

$saying->url(@_);

}


#-----------------------------------------------------------
# 検索フォーム
#-----------------------------------------------------------
sub search_form{

my $self = shift;
my $html = new Mebius::HTML;
my $init = $self->init();
my $query = new Mebius::Query;
my $param_utf8_judged = $query->single_param_utf8_judged_device();
my($form);

$form .= $html->start_tag("form",{ action => $init->{'base_url'} });
$form .= $html->input("search","keyword",$param_utf8_judged->{'keyword'},{ placeholder => "キーワード" });
$form .= $html->input("hidden","mode","search");

$form .= $html->input("submit","","$init->{'title'}から検索");

$form .= $html->close_tag("form");

$form;

}


#-----------------------------------------------------------
# 検索結果ページ
#-----------------------------------------------------------
sub search_view{

my $self = shift;
my $content = $self->content();
my $saying = $self->saying();
my $html = new Mebius::HTML;
my $text = new Mebius::Text;
my $query = new Mebius::Query;
my $param_utf8_judged = $query->single_param_utf8_judged_device();
my($print,$title);

my $adjusted_keyword = $text->fix_title($param_utf8_judged->{'keyword'});
$adjusted_keyword = $text->fullsize_to_halfsize($adjusted_keyword);

my $content_group_data = $content->fetchrow_main_table({ title => ["LIKE","%$adjusted_keyword%"] }) if($param_utf8_judged->{'keyword'});
my $saying_group_data = $saying->fetchrow_main_table({ text => ["LIKE","%$adjusted_keyword%"] }) if($param_utf8_judged->{'keyword'});

$print .= $self->search_form();

	if($param_utf8_judged->{'keyword'}){
		$title = qq(”$param_utf8_judged->{'keyword'}”の検索結果);
	} else {
		$title = qq(検索);
	}

	if( my $content_line = $content->data_group_to_line($content_group_data)){
		$print .= $html->tag("h2","コンテンツ");
		$print .= $content_line;
	}

	if( my $saying_line = $saying->data_group_to_line($saying_group_data)){
		$print .= $html->tag("h2","登録");
		$print .= $saying_line;
	}

$self->print_html($print,{ h1 => "検索" , Title => $title , BCL => [$title] });

exit;


}


#-----------------------------------------------------------
# 番号からデータへ
#-----------------------------------------------------------
sub number_to_data{

my $self = shift;
my $number = shift;

my $saying_data = $self->fetchrow_main_table({ number => $number })->[0];

$saying_data;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub number_to_data_or_error{

my $self = shift;
my $limited_package_name = $self->limited_package_name();
$self->number_to_data(@_) || $self->error("このデータは存在しません。[$limited_package_name]");

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub deleted_judge{

my $self = shift;
my $data = shift;
my($message);

	if($data->{'deleted_flag'}){
		$message = "削除済みページです。";
			if(Mebius->common_admin_judge()){
			} else {
				$self->error($message);
			}
	}

$message;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub succession_error_message{

my $self = shift;
my $border_num = $self->create_border_num() || 3;
my $border_hour = 24;
my $relative_border_time = $border_hour *60*60;
my $border_time = time - $relative_border_time;
my $debug = new Mebius::Debug;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my $my_connection = Mebius::my_connection();
my $init = $self->init();
my($error);

	if($debug->escape_error()){
		return();
	}

my $escaped_addr = f($ENV{'REMOTE_ADDR'});
my $escaped_cnumber = f($my_cookie->{'char'});

my($data_group,$result) = $self->fetchrow_main_table("WHERE (addr = '$escaped_addr' OR cnumber = '$escaped_cnumber') AND create_time >= $border_time ",{ Debug => 0 });

	if($result >= $border_num){
		$error = "${border_hour}時間以内に登録できるのは${border_num}個までです。(現在${result}個)";
	}

$error;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
#sub character_num_error{

#my $self = shift;
#my $text_body = shift;
#my $text_label = shift;
#my $text = new Mebius::Text;

#	if(my $error = $text->character_num_error_message($text_body,$self->min_character_num()  ,$self->max_character_num() || die,$text_label)){
#		$self->error($error);
#	}

#}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_preview{

my $self = shift;
my $number = shift;
my $html = new Mebius::HTML;
my $report = new Mebius::Report;
my $data = $self->fetchrow_main_table({ number => $number , deleted_flag => ["<>",1] })->[0] || $self->error("報告できる対象がありません。");

my($print);

$report->report_mode_junction({ source => "utf8" });

my $title = "違反報告";
my $limited_package_name = $self->limited_package_name();
my $report_query_name_with_number = $self->report_query_name_with_number($data->{'number'});

$print .= $self->data_to_line($data);

#$print .= $html->tag("div",$data->{'text'});

$print .= $report->around_form(undef,$report_query_name_with_number,{ });

$self->print_html($print,{ h1 => $title , BCL => [$title] });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_line{

my $self = shift;
my $report = new Mebius::Report;
my($line,%report_group);
my $content = $self->content();
my $saying = $self->saying();
my $review = $self->review();
my $comment = $self->comment();

my $report_data_group = $report->fetchrow_main_table({ content_type => "saying" , answer_time => 0 });

	foreach my $data (@{$report_data_group}){

		my $content_type = $data->{'targetA'};
		push @{$report_group{$data->{'targetB'}}{$data->{'targetC'}}{$content_type}{$data->{'targetD'}}} , $data; # targetA はなくて正しい

	}

	foreach my $content_number ( keys %report_group ){

			if($content_number eq ""){ next; }

		my $content_group = $report_group{$content_number};
		my $content_report = $report_group{$content_number}{""}{"content"}{""};

		my $content_data = $content->number_to_data($content_number);
		$line .= $content->data_to_line_with_report($content_data,$content_report);

			foreach my $saying_number ( keys %{$content_group} ){

					if($saying_number eq ""){ next; }

				my $saying_group = $report_group{$content_number}{$saying_number};
				my $saying_report = $report_group{$content_number}{$saying_number}{"saying"}{""};

				my $saying_data = $saying->number_to_data($saying_number);
				$line .= $saying->data_to_line_with_report($saying_data,$saying_report);

					foreach my $review_number ( %{$saying_group->{'review'}}){

							if($review_number eq ""){ next; }

						my $review_report = $report_group{$content_number}{$saying_number}{"review"}{$review_number};

						my $review_data = $review->number_to_data($review_number,$review_report);
						$line .= $review->data_to_line_with_report($review_data);

					}

					foreach my $comment_number ( %{$saying_group->{'comment'}}){

							if($comment_number eq ""){ next; }

						my $comment_report = $report_group{$content_number}{$saying_number}{"comment"}{$comment_number};

						my $comment_data = $comment->number_to_data($comment_number);
						$line .= $comment->data_to_line_with_report($comment_data,$comment_report);

					}

			}


	}


$line;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sitemap_index_view{

my $self = shift;
my $mode = shift;
my $sitemap = new Mebius::Sitemap;
my $init = $self->init();
my $times = new Mebius::Time;
my $this_year = $times->year(time);
my(@sitemap);

	for my $year ( $init->{'service_start_year'} ..  $this_year ) {
		push @sitemap , { url => $self->sitemap_url($year) } ;
	}

$sitemap->print_sitemap_index(\@sitemap);

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub dupulication_regist_error{

my $self = shift;
my $all_comments = new Mebius::AllComments;
my $comment = shift;

	if( my $error = $all_comments->dupulication($comment)){
		$self->regist_error($error);
	} else {
		0;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub succession_error{

my $self = shift;
	if(my $error = $self->succession_error_message(@_)){
		$self->regist_error($error);
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line_with_report{

my $self = shift;
my $data = shift;
my $report_data_group = shift;
my $report = new Mebius::Report;
my($line);

my $data_line = $self->data_to_line($data);

$line .= $report->place_by_the_side($data_line,$report_data_group,{ access_data => $data });

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub control_parts{

my $self = shift;
my $data = shift;
my($line);
my $html = new Mebius::HTML;
my $control = new Mebius::Control;

my $limited_package_name = $self->limited_package_name();
my $label_name = $self->japanese_label_name();

	if(Mebius->common_admin_judge()){
		$line .= qq(<div class="right">);
		$line .= $html->tag("strong","${label_name}： ");
		$line .= $control->radio_parts("saying_${limited_package_name}_control_$data->{'number'}",{ deleted_flag => $data->{'deleted_flag'} } );
		$line .= qq(</div>);

	}

	if(Mebius->common_admin_judge()){
		$line .= qq(<div class="right margin-top">);
		$line .= $control->user_control_link_series($data);
		$line .= qq(</div>);

	}


$line;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_button{

my $self = shift;
my $data = shift;
my $query_name = $self->report_preview_query_name();
my $html = new Mebius::HTML;

my $button = $html->input("submit","${query_name}_$data->{'number'}","報告",{ class => "report" });

$button;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_query_name{

my $self = shift;
my $limited_package_name = $self->limited_package_name();

"report_saying_${limited_package_name}";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_query_name_with_number{

my $self = shift;
my $number = shift || die;

my $target = $self->report_query_name() . "_" . $number;

$target;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_preview_query_name{

my $self = shift;
my $limited_package_name = $self->limited_package_name();

"saying_${limited_package_name}_report_preview";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sitemap_url{

my $self = shift;
my $year = shift;
my $init = $self->init();
my($sitemap_url);

my $limited_package_name = $self->limited_package_name();

	if($year =~ /^([0-9]+)$/){
		$sitemap_url = "$init->{'base_url'}${limited_package_name}_sitemap_$year.xml";
	} else {
		warn;
		return();
	}


$sitemap_url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub account_only_mode{
0;
}



#-----------------------------------------------------------
# 関連付け
#-----------------------------------------------------------
sub view{
my $self = shift;
#my $view = new Mebius::Saying::View;
my $view = {};

}


#-----------------------------------------------------------
# 関連付け
#-----------------------------------------------------------
sub saying{
my $self = shift;
my $saying = new Mebius::Saying::Saying;
$saying;

}

#-----------------------------------------------------------
# 関連付け
#-----------------------------------------------------------
sub review{
my $self = shift;
my $review = new Mebius::Saying::Review;
$review;
}


#-----------------------------------------------------------
# 関連付け
#-----------------------------------------------------------
sub content{
my $self = shift;
my $content = new Mebius::Saying::Content;
$content;
}

#-----------------------------------------------------------
# 関連付け
#-----------------------------------------------------------
sub comment{
my $self = shift;
my $content = new Mebius::Saying::Comment;
$content;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic{
my $basic = new Mebius::Saying;
$basic;

}



1;

