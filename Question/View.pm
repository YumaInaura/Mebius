
use strict;
package Mebius::Question::View;
use Mebius::Question::Post;
use Mebius::Question::URL;
use Mebius::Question::Response;
use Mebius::Question::Ranking;
use Mebius::Control;
use Mebius::SNS::URL;
use Mebius::Time;
use Mebius::Sitemap;
use Mebius::Javascript;
use Mebius::SNS::Account;
use Mebius::Export;

use base qw(Mebius::Question);

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# トップページ
#-----------------------------------------------------------
sub top_page_view{

my $self = shift;
my $error = shift;
my $html = new Mebius::HTML;
my $init = Mebius::Question->init();
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my($basic_init) = Mebius::basic_init();
my $post = new Mebius::Question::Post;
my($line);

#my $head_javascript = $self->head_javascript_word_length_count();

$line .= qq(<div class="margin">);
$line .= $html->strong("”$init->{'title'}”",{ class => "green" }) . qq(は気になることを、短文で、聞いたり答えたり出来るサービスです。) ;
$line .= " ( ". $html->href("$basic_init->{'guide_url'}%A4%AF%A4%A8%A4%B9%A4%C1%A4%E7%A4%F3%A1%A9","ガイド",{ target => "_blank" , class => "blank" }) . " )";
$line .= qq(</div>);

$line .= $self->new_form_parts();

	if($error){
		$line .= $html->span($error,{ class => "red" });
	}

#$line .= $html->tag("h2","検索",{ class => "inline" });
#$line .= $self->search_form();

my($my_results) = $self->one_account_results($my_account);
	if($my_results){
		$line .= $html->tag("h2","あなたの成績");
		$line .= $my_results;
	}

$line .= $html->tag("h2",$html->href("$init->{'base_url'}recently","新着"),{ NotEscape => 1 });
$line .= $self->recently_question(10);

$line .= $html->tag("h2",$html->href("$init->{'base_url'}recently_response","回答"),{ NotEscape => 1 });
$line .= $self->recently_responsed_question(10);

my $high_access_question = $self->high_access_question(10);
	if($high_access_question){
		$line .= $html->tag("h2",$html->href("$init->{'base_url'}high_access","人気"),{ NotEscape => 1 });
		$line .= $high_access_question;
	}

my $my_question = $self->my_question(10);
	if($my_question){
		$line .= $html->tag("h2",$html->href("$init->{'base_url'}my_question","あなた"),{ NotEscape => 1 });
		$line .= $my_question;
	}

$line .= $html->tag("h2",$html->href("$init->{'base_url'}no_answer","未回答"),{ NotEscape => 1 });

	if(Mebius->common_admin_judge()){
		$line .= $html->tag("h2",$html->href("$init->{'base_url'}deleted","削除済み"),{ NotEscape => 1 });
	}

$line .= $html->tag("h2",$html->href("$init->{'base_url'}log","いままで"),{ NotEscape => 1 });
$line .= $self->log_index_per_month();


$self->print_html($line,{ h1 => $init->{'title'} , GoogleWebMasterToolTag => 1 });

exit;

}



#-----------------------------------------------------------
# 検索フォーム
#-----------------------------------------------------------
sub search_form{

my $self = shift;
my $init = $self->init();
my $html = new Mebius::HTML;
my $param_utf8 = Mebius::Query->single_param_utf8_judged_device();
my($line);

$line .= $html->start_tag("form",{ action => $init->{'base_url'} });
$line .= $html->input("hidden","mode","search");
$line .= $html->input("search","keyword",$param_utf8->{'keyword'});
$line .= $html->input("submit","","質問を検索");

$line .= $html->close_tag("form");
$line;

}



#-----------------------------------------------------------
# 成績
#-----------------------------------------------------------
sub one_account_results{

my $self = shift;
my $account = shift;
#my $response = $self->response_object();
my $ranking = new Mebius::Question::Ranking;
my($line,$my_response_num,$good_num);

	if(!$account->{'question_last_response_time'}){
		return();
	}

my $ranking_data = $ranking->fetchrow_main_table({ account => $account->{'id'} })->[0];


my $all_good_num = $ranking_data->{'all_good_num'} || 0;
my $all_bad_num = $ranking_data->{'all_bad_num'} || 0;
my $my_response_num = $ranking_data->{'all_response_num'} || 0;

$line = e(qq(いいね $all_good_num : いまいち $all_bad_num / 回答 $my_response_num));

$line;

}


#-----------------------------------------------------------
# 検索結果ページ
#-----------------------------------------------------------
sub search_view{

my $self = shift;
my $post = $self->post_object();
my $param_utf8 = Mebius::Query->single_param_utf8_judged_device();
my($line);

my $title = "検索結果";

my $post_dbi = $post->fetchrow_main_table({ text => ["LIKE","%$param_utf8->{'keyword'}%"] , account => ["LIKE","%$param_utf8->{'keyword'}%"]  },{ OR => 1, LIMIT => 100 , ORDER_BY => ['post_time DESC'] });

#$line .= $self->search_form();
$line .= $self->post_dbi_to_html_list($post_dbi,{ });

$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

$line;

}

#-----------------------------------------------------------
# 自分の質問
#-----------------------------------------------------------
sub log_question_view{

my $self = shift;
my($line);

$line .= $self->log_index_per_month();

my $title = "いままでのくえすちょん";


$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

exit;

}

#-----------------------------------------------------------
# 月別の質問
#-----------------------------------------------------------
sub log_index_per_month{

my $self = shift;
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my($line);
my $init = $self->init();
my $service_start_localtime = $init->{'service_start_localtime'} || die;

my $year_and_months = $times->foreach_year_and_month_with_localtime($service_start_localtime,time);
	foreach my $hash (@{$year_and_months}){
		$line .= qq(<li>);
		$line .= $html->href("log-$hash->{'year'}-$hash->{'month'}","$hash->{'year'}/$hash->{'month'}");
		$line .= qq(</li>);
	}

$line = qq(<ul>$line</ul>);

$line;

}

#-----------------------------------------------------------
# 月別の表示
#-----------------------------------------------------------
sub month_question_view{

my $self = shift;
my $year = shift;
my $month = shift;
my $post = new Mebius::Question::Post;
my $times = new Mebius::Time;
my($line);

	if(!$year){ die; }
	if(!$month){ die; }

my $start_border_time = $times->year_and_month_to_localtime($year,$month);
my $end_border_time = $times->year_and_month_to_localtime_end($year,$month);

my $post_dbi = $post->fetchrow_main_table([ ["post_time",">=",$start_border_time] , ["post_time","<",$end_border_time] ] , { ORDER_BY => ["post_time DESC"] });

	if($post_dbi->[0] eq ""){
		$self->error("ログがありません。");
	}

$line = $self->post_dbi_to_html_list($post_dbi,{ });

my $title = "${year}年${month}月のくえすちょん";


$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

}


#-----------------------------------------------------------
# アクセス回数の多い質問
#-----------------------------------------------------------
sub high_access_question_view{

my $self = shift;
my($line);

$line .= $self->high_access_question(100);

my $title = "人気のくえすちょん";

$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

exit;

}

#-----------------------------------------------------------
# アクセス回数の多いくえすちょん
#-----------------------------------------------------------
sub high_access_question{

my $self = shift;
my $max_get = shift;
my($line,$access_border);

	if(Mebius::alocal_judge()){
		$access_border = 0;
	} else {
		$access_border = 100;
	}

my $post_dbi = Mebius::Question::Post->fetchrow_main_table({ access_count => [">",$access_border] , deleted_flag => ["<>",1] } , { LIMIT => $max_get , ORDER_BY => ["access_count DESC"] });

$line = $self->post_dbi_to_html_list($post_dbi,{ });

$line;

}


#-----------------------------------------------------------
# 最近の質問
#-----------------------------------------------------------
sub recently_question{

my $self = shift;
my $get_line = shift;
my $get_till_how_before_time = shift; # 未使用
my($line);
my $html = new Mebius::HTML;

$get_till_how_before_time  ||= 3*24*60*60;
my $border_time = time - $get_till_how_before_time;
my $post_dbi = Mebius::Question::Post->fetchrow_main_table({ post_time => [">",$border_time] , deleted_flag => ["<>",1] },{ LIMIT => $get_line , ORDER_BY => ["post_time DESC"] });

$line = $self->post_dbi_to_html_list($post_dbi,{ RecentlyQuestion => 1 });

$line;

}


#-----------------------------------------------------------
# 最近の質問
#-----------------------------------------------------------
sub recently_question_view{

my $self = shift;
my($line);

$line .= $self->recently_question(100);

my $title = "最近のくえすちょん";

$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

exit;

}

#-----------------------------------------------------------
# 回答がない質問
#-----------------------------------------------------------
sub no_answer_question{

my $self = shift;
my $max_get_line = shift;
my($line);

my $post_dbi = Mebius::Question::Post->fetchrow_main_table({ response_num => "0" , deleted_flag => ["<>",1] },{ LIMIT => $max_get_line , ORDER_BY => ["post_time DESC"]  });

$line = $self->post_dbi_to_html_list($post_dbi,{  });

$line;

}
#-----------------------------------------------------------
# 最近の質問
#-----------------------------------------------------------
sub no_answer_question_view{

my $self = shift;
my($line);

$line .= $self->no_answer_question(100);

my $title = "未回答の質問";

$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

exit;

}

#-----------------------------------------------------------
# 最近回答があった質問
#-----------------------------------------------------------
sub recently_responsed_question{

my $self = shift;
my $get_line = shift;
my($line);

my $border_time = time - 3*24*60*60;
my $post_dbi = Mebius::Question::Post->fetchrow_main_table({ last_response_time => [">",$border_time] , deleted_flag => ["<>",1] },{ LIMIT => $get_line , ORDER_BY => ["last_response_time DESC"] ,  Debug => 0 });

$line = $self->post_dbi_to_html_list($post_dbi,{ MyQuestion => 1 });

$line;

}

#-----------------------------------------------------------
# 最近回答があった質問
#-----------------------------------------------------------
sub recently_responsed_question_view{

my $self = shift;
my($line);

$line .= $self->recently_responsed_question(100);

my $title = "最近回答があったくえすちょん";

$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

exit;

}



#-----------------------------------------------------------
# ひとつのアカウントの質問履歴
#-----------------------------------------------------------
sub one_account_question{

my $self = shift;
my $get_line = shift;
my $account = shift;
my($line);

	if(!$account){
		return();
	}

my $post_dbi = Mebius::Question::Post->fetchrow_main_table({ account => $account },{ LIMIT => $get_line , ORDER_BY => ["post_time DESC"] });

$line = $self->post_dbi_to_html_list($post_dbi,{});

$line;

}



#-----------------------------------------------------------
# 自分の質問
#-----------------------------------------------------------
sub my_question{

my $self = shift;
my $get_line = shift;
my($my_account) = Mebius::my_account();
my($line);

	if(!$my_account->{'id'}){
		return();
	}

my $post_dbi = Mebius::Question::Post->fetchrow_main_table({ account => $my_account->{'id'} , deleted_flag => ["<>",1] },{ LIMIT => $get_line , ORDER_BY => ["last_modified DESC"] });

$line = $self->post_dbi_to_html_list($post_dbi,{ MyQuestion => 1 });

$line;

}

#-----------------------------------------------------------
# 自分の質問
#-----------------------------------------------------------
sub my_question_view{

my $self = shift;
my($line);

my $title = "あなたのくえすちょん";

$line .= $self->my_question();

#my $head_javascript = $self->head_javascript_word_length_count();
$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

exit;

}

#-----------------------------------------------------------
# 削除済みの質問
#-----------------------------------------------------------
sub deleted_question{

my $self = shift;
my $max_get_line = shift;
my($line);

my $post_dbi = Mebius::Question::Post->fetchrow_main_table({ deleted_flag => 1 },{ LIMIT => $max_get_line , ORDER_BY => ["control_time DESC"] });

$line = $self->post_dbi_to_html_list($post_dbi,{  });

$line;


}


#-----------------------------------------------------------
# 削除済みの質問 を表示するページ
#-----------------------------------------------------------
sub deleted_question_view{

my $self = shift;
my($my_account) = Mebius::my_account();
my($line);

	if(!Mebius->common_admin_judge()){
		Mebius->error("ページが存在しません。[Q1]");
	}

my $title = "削除済み";

$line .= $self->deleted_question(100);

#my $head_javascript = $self->head_javascript_word_length_count();
$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

exit;

}


#-----------------------------------------------------------
# DBIのデータを HTML のリスト形式に
#-----------------------------------------------------------
sub post_dbi_to_html_list{

my $self = shift;
my $dbi = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($line);
my $html = new Mebius::HTML;

	foreach my $post_data (@{$dbi}){

			if($post_data->{'deleted_flag'} && !Mebius->common_admin_judge()){
				next;
			}

			# フィルタで非表示にする場合
			if(Mebius::Fillter::heavy_fillter($post_data->{'text'})){
				next;
			}

		$line .= qq(<li>);
		$line .= $self->post_data_to_html_core($post_data,$use);

		$line .= qq(</li>\n);
	}

	if($line){
		$line = qq(<ul>$line</ul>);
	}

$line;

}

#-----------------------------------------------------------
# １行の処理
#-----------------------------------------------------------
sub post_data_to_html_core{

my $self = shift;
my $post_data = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my $url = new Mebius::Question::URL;
my $sns_url = new Mebius::SNS::URL;
my($line);

my $substred_text = Mebius::Text->omit_character($post_data->{'text'},30);
my $response_num = $post_data->{'response_num'} || 0;
$line .= $html->href($url->question($post_data->{'number'}),"$substred_text\($response_num\)");

$line .= " - ";

	#if($use->{'MyQuestion'}){
	#	$line .= $sns_url->account_link($post_data->{'last_response_account'}); # $post_data->{'last_handle'}
	#}	else {
	#	$line .= $sns_url->account_link($post_data->{'account'}); # $post_data->{'handle'}
	#}

$line .= " ";

	if($use->{'MyQuestion'}){
		$line .= $times->how_before($post_data->{'last_modified'});
	} else {
		$line .= $times->how_before($post_data->{'post_time'});
	}

$line;

}


#-----------------------------------------------------------
# 質問本体の表示ページ
#-----------------------------------------------------------
sub question_view{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my $init = Mebius::Question->init();
my $html = new Mebius::HTML;
my $url = new Mebius::Question::URL;
my $post = new Mebius::Question::Post;
my $query = new Mebius::Query;
my $debug = new Mebius::Debug;
my $device = new Mebius::Device;
my $javascript = new Mebius::Javascript;
my($print,$response_line,$adverse_on_flag,$response_hash,$inline_css);
my $error = $use->{'error'};
my $question_number = $use->{'question_number'} || $param->{'q'};

# DBIからデータを取得 ( 質問本体 )
my $post_data = Mebius::Question::Post->fetchrow_main_table({ number => $question_number })->[0];

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($question_number)); }

$post->read_on_history($post_data);

# アクセスカウンタ
$post->new_access($post_data);

$inline_css = qq(
div.good_answer,div.limited_best_answer,div.best_answer,div.answer,div.deleted_answer{padding:1em 0.5em;}
div.limited_best_answer{background:#ffa;}
div.best_answer{background:#afa;}
div.deleted_answer{background:#fdd;}
div.control_answer{margin-top:1em;}
h1{margin:0em;line-height:1.6;}
.question_line{margin-bottom:2em;}
);

#div.good_answer{background:#ffd;}

my($subject_fillter_error) = Mebius::Fillter::fillter_and_error($post_data->{'text'},$post_data->{'text'});

	if($subject_fillter_error){
		$print .= $html->strong("※$subject_fillter_error",{ class => "red" , NotEscape => 1 });
	}

	if(!$post_data){
		Mebius->error("質問が存在しません。");
	} elsif($post_data->{'deleted_flag'}){
		my $message = $html->strong("※削除済みページです。削除者: \@$post_data->{'control_account'}",{ class => "red" });
			if(Mebius->common_admin_judge()){
				$print .= $message;
			} else {
				Mebius->error($message,"410");
			}
	}

#my $question_body = $post_data->{'text'};
#$question_body =~ s/[\r\n]/<br>/g;
#$print .= qq($question_body);

# 広告フィルタ
my $fillter_flag = Mebius::Fillter::basic($post_data->{'text'},$post_data->{'text'});

	# 広告の表示有無を定義
	if(!$self->report_mode_judge() && !$fillter_flag && !$post_data->{'deleted_flag'} && $query->get_method() && time > $post_data->{'post_time'} + 3){
		$adverse_on_flag = 1;
	}

	# スマフォ向け広告
	if($adverse_on_flag && $device->use_device_is_smart_phone()){
		$print .= $self->adverse_mobile_bunner_styled();
	}

$print .= $self->question_line($post_data);

	if(!$use->{'ReportPost'}){
		$response_hash = $self->response_line($question_number,$post_data,{ limited_view_response => $use->{'limited_view_response'} , no_adverse_flag => $fillter_flag });
		$response_line = $response_hash->{'line'};
	}

	if((!$self->report_mode_judge() && !$response_hash->{'still_responsed_flag'}) || Mebius::alocal_judge()){
		$print .= $self->response_form_parts({ post_data => $post_data ,  question_number => $question_number });
	}

	if($adverse_on_flag && !$device->use_device_is_smart_phone_or_mobile()){
		$print .= qq(<div class="float-left">);
		$print .= qq(<div class="big_bunner_label">広告</div>);
		$print .= $self->adverse_big_bunner();
		$print .= qq(</div>);
	}

	if($device->use_device_is_smart_phone()){
		$print .= qq(<div class="clear"></div>);
	} else {
		$print .= qq(<div class="clear" style="height:1em;"></div>);
	}

	if($error){
		$print .= $html->tag("div","※$error",{ class => "message-red" });
	}


	# 削除依頼モードの場合、フォームを追加
		if($self->report_mode_judge()){

			#$response_line .= $query->input_hidden_encode();

				# 質問本体の報告モード
				if($use->{'ReportPost'}){
					($response_line) = Mebius::Report::report_mode_around_form($response_line,"question_post_$post_data->{'number'}",{ Thread => 1 , source => "utf8" });

				# 回答の報告モード
				} else {
					my $target_response_number;
						foreach my $key ( keys %{$param} ){
								if($key =~ /^report_question_response_preview_(.+)$/){
									$target_response_number = $1;
								}
						}
					($response_line) = Mebius::Report::report_mode_around_form($response_line,"question_response_$target_response_number",{ OnlyTarget => 1 , source => "utf8" });
				}
			$print .= $response_line;
		} else {

			# 全体をフォームで囲む
			my $form;
			$form .= qq(<form action="" name="control" method="post" id="question_control_answer" utn>);
			$form .= $html->input("hidden","q",$param->{'q'});
			$form .= $html->input("hidden","mode","control",{ NotOverwrite => 1 });
			$form .= $html->input("hidden","my_account",$my_account->{'id'});
			$form .= $debug->escape_error_checkbox() if(Mebius::alocal_judge());
			$form .= Mebius::back_url_input_hidden();
			$form .= $response_line;
			$form .= qq(</form>);


			$print .= $form;
		}

my $substred_text = Mebius::Text->omit_character($post_data->{'text'},30);

$print .= $javascript->push_good("question_control_answer");

$self->print_html($print,{ inline_css => $inline_css , Title => $substred_text , h1 => "質問： $post_data->{'text'}" ,BCL => [$substred_text] });

exit;

}


#-----------------------------------------------------------
# 質問本体の表示
#-----------------------------------------------------------
sub question_line{

my $self = shift;
my $post_data = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($my_account) = Mebius::my_account();
my $html = new Mebius::HTML;
my($print);

	if(!$use->{'ViewReport'}){
		$print .= qq(<form action="" method="post" utn>);
		$print .= $html->input("hidden","mode","control");
		$print .= $html->input("hidden","my_account",$my_account->{'id'});
		$print .= Mebius::back_url_input_hidden();
	}

	if($use->{'ViewReport'}){
		$print .= $html->tag("h3",$post_data->{'text'});

	}

$print .= qq(<div class="right">);
$print .= Mebius::SNS::URL->account_link($post_data->{'account'},"","QUESTION"); # $post_data->{'handle'}
$print .= " " . Mebius::Time->how_before($post_data->{'post_time'});

$print .= qq( [ ).e($post_data->{'access_count'} || 0).qq( ]) ;

	if(!$self->report_mode_judge() && !$use->{'ViewReport'}){
		$print .= " " . $html->input("submit","report_question_post_preview_$post_data->{'number'}","報告",{ class => "report" });
	}
$print .= qq(</div>);

	if(Mebius->common_admin_judge() && !$self->report_mode_judge()){
		$print .= qq(<div class="right margin">);
		$print .= $html->strong("スレッドの操作：",{ class => "red" });
		$print .= Mebius::Control->radio_parts("question_control_post_$post_data->{'number'}",{ deleted_flag => $post_data->{'deleted_flag'} } );
		$print .= qq(</div>);
	}

	if(!$use->{'ViewReport'}){
		$print .= qq(</form>);
	}

$print = qq(<div class="question_line">$print</div>);

$print;

}

#-----------------------------------------------------------
# レス部分
#-----------------------------------------------------------
sub response_line{

my $self = shift;
my $target_number = shift;
my $post_data = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($my_account) = Mebius::my_account();
my($my_use_device) = Mebius::my_use_device();
my $init = $self->init();
my $sns_account = new Mebius::SNS::Account;
my $post = new Mebius::Question::Post;
my $html = new Mebius::HTML;
my $response = new Mebius::Question::Response;
my $query = new Mebius::Query;
my $device = new Mebius::Device;
my($response_line,$line,$good_answer_done,$answer_line,$hit,%return,$close_answer_flag,@order_by,$top_of_good_num);

	if($target_number eq ""){
		warn("target number is empty.");
		return("");
	}

	if(time > $post_data->{'first_response_time'} + $init->{'push_good_limit_since_post_time'}){
		$close_answer_flag = 1;
		@order_by = ( "good_num DESC","response_time DESC");
	} else {
		@order_by = ( "response_time DESC" );
	}

# DBIからデータを取得 ( レス )
my $dbi = $response->fetchrow_main_table({ target_post_number => $target_number },{ ORDER_BY => \@order_by }); # best_answer_time
my $adjusted_comment_data_group = $sns_account->add_handle_to_data_group($dbi) || [];
my @data = @{$adjusted_comment_data_group};

	foreach my $data ( @data ){
		my $def_good_num = $data->{'good_num'} - $data->{'bad_num'};
		$top_of_good_num = $def_good_num if($def_good_num > $top_of_good_num);
	}

	# この質問のすべてのレスを展開
	foreach my $data ( @data ){

		my($good_answer_flag,$best_answer_flag);
		my $def_good_num = $data->{'good_num'} - $data->{'bad_num'};

			if($data->{'account'} eq $my_account->{'id'}){
				$return{'still_responsed_flag'} = 1;
			}

			# 削除済みの場合
			if($data->{'deleted_flag'} && !Mebius->common_admin_judge()){
				next;
			} elsif($def_good_num >= 1 && !$data->{'deleted_flag'} && $top_of_good_num == $def_good_num && !$good_answer_done++){
					if($close_answer_flag){
						$best_answer_flag = 1;
					} else {
						$good_answer_flag = 1;
					}
			}

			# 特定のレスだけ表示する場合
			if($use->{'limited_view_response'} && !$use->{'limited_view_response'}->{$data->{'number'}}){
				next;
			}

			$hit++;

			# Good アンサー
			#if($post_data->{'best_answer_response_number'} eq $data->{'number'} && $self->use_best_answer_system()){
			#	$best_answer_line .= $self->response_data_to_html($data,$post_data,{ best_answer_flag => 1 });
			#} els

		$answer_line .= $response->data_to_line($data,$post_data,{ hit => $hit , best_answer_flag => $best_answer_flag , good_answer_flag => $good_answer_flag });

			# ベストアンサーが付いている場合は広告を表示

			if($best_answer_flag && !$self->report_mode_judge() && !$use->{'no_adverse_flag'} && $query->get_method()){

					if($device->use_device_is_smart_phone()){
						$answer_line .= $self->adverse_mobile_bunner_styled();
					} elsif(!$device->use_device_is_smart_phone_or_mobile()){
						$answer_line .= qq(<div class="big_bunner_label">広告</div>);
						$answer_line .= qq(<div>);
						$answer_line .= $self->adverse_big_bunner();
						$answer_line .= qq(</div>);
					}
			}

	}


$hit ||= 0;
$answer_line ||= "回答はまだありません。";

my $all_line .= $html->start_tag("div",{ class => "margin-top margin-bottom" });
$all_line .= $html->tag("h2","回答($hit)",{ class => "inline" });

	# まだ「いいね！」を受け付けている場合の説明メッセージ
	{
		my $push_good_limit_time = $post_data->{'first_response_time'} + $init->{'push_good_limit_since_post_time'} - time;
			if($push_good_limit_time > 1 && $hit >= 1){
				my $how_long = Mebius::second_to_howlong($push_good_limit_time); # { TopUnit => 1 },
						if(!$my_use_device->{'smart_phone_flag'}){
							$all_line .= $html->tag("span","　※いいね を押して、皆でべすとあんさーを決めましょう。あと [ $how_long ] ",{ class => "guide" } );
						}
			}
	}

$all_line .= $html->close_tag("div");
$all_line .= $answer_line;

$return{'line'} = $all_line;

\%return;

}



#-----------------------------------------------------------
# 返信フォーム
#-----------------------------------------------------------
sub response_form_parts{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $device = new Mebius::Device;
my $relay_use = Mebius::Operate->overwrite_hash($use,{ Response => 1 });
my($my_account) = Mebius::my_account();
my $html = new Mebius::HTML;
my($style);

my $form = $self->form_parts($relay_use);

	if($form){

		my($my_results) = $self->one_account_results($my_account);
			if($my_results){
				$form .= qq(<span class="guide">あなたの成績： ).$my_results.qq(</span>);
			}

		$style .= "margin-right:2em;width:18em;";
			if(!$device->use_device_is_smart_phone()){
				$style .= "margin-bottom:1em;"; # 広告 誤クリック防止用の のスペース
			}
		$form = $html->tag("div",$form,{ NotEscape => 1 , class => "float-left" , style => $style });
	}

$form;

}

#-----------------------------------------------------------
# 新規投稿フォーム
#-----------------------------------------------------------
sub new_form_parts{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");

my $relay_use = Mebius::Operate->overwrite_hash($use,{ New => 1 });
my $form = $self->form_parts($relay_use);

	if($form){
		$form = qq(<div style="width:18em;">$form</div>);
	}

$form;

}

#-----------------------------------------------------------
# 投稿フォーム
#-----------------------------------------------------------
sub form_parts{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $init = Mebius::Question->init();
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my($my_use_device) = Mebius::my_use_device();
my $basic = new Mebius::Question;
my $post = $basic->post_object();
my $response = $basic->response_object();
my $debug = new Mebius::Debug;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $form = new Mebius::Form;
my($print,$placeholder,$submit_value,$mode,$too_many_post_error,$disabled,$too_many_response_error,$color_select_box);

my $last_post_time = $post->my_last_post_time();
my $inputed_textarea = int rand(99999999999) if(Mebius::alocal_judge());

	# 新規投稿フォーム
	if($use->{'New'}){

		$placeholder = "何か質問したいことはありませんか？";
		$submit_value = "質問する";
		$mode = "post";

		$too_many_post_error = Mebius::Question::Post->too_many_post();

	# 回答フォーム
	} elsif ($use->{'Response'}){

			if($response->deny_response( $use->{'post_data'} , $use->{'response_dbi'} ) && !Mebius::alocal_judge()){
				return();
			}

		$too_many_response_error = $response->too_many_response();

		$placeholder = "質問の答えを書いて下さい。";
		$submit_value = "答える";
		$mode = "response";
		$color_select_box = $form->color_select_box();

	} else {
		die("This is not exists mode.");
	}

	# 投稿不可の場合
	if((!$my_account->{'login_flag'} || $too_many_post_error || $too_many_response_error) && !Mebius::alocal_judge()){
		$disabled = " disabled";
	}


# フォーム部品
$print .= $html->start_tag("form",{ name => $mode , action => "" , method => "post" , utn => 1 });
$print .= qq(<div>);
$print .= $html->input("hidden","mode",$mode);
$print .= $html->input("hidden","q",$use->{'question_number'}) if($use->{'question_number'});
$print .= $html->input("hidden","my_account",$my_account->{'id'});
$print .= $query->input_hidden_encode();
$print .= $html->textarea("text",$inputed_textarea,{ placeholder => $placeholder , onkeyup => "show_length(value);" , disabled => $disabled , style => "width:100%;height:6em;" , id => "question_textarea" });
#$print .= qq(<textarea name="text" cols="24" rows="3" onkeyup="show_length(value);" style="width:100%;height:6em;" id="question_textarea" placeholder="何か質問したいことはありませんか？"$disabled></textarea>);

#$print .= $html->textarea("",{ placeholder => "なにか聞きたいことはありませんか？" , style => "width:100%;height:5em;" });
$print .= qq(<div class="right">);
$print .= qq(<p id="inputlength" class="inline">).e($init->{'word_length_limit'}).qq(</p> );
$print .= $html->input("submit","submit",$submit_value,{ disabled => $disabled  , id => "question_submit" });

	# ローカル用送信ボタン ( Javascriptの動作に関わらず、いつでも送信できるように )
	if(Mebius::alocal_judge()){
		$print .= qq( );
		$print .= $html->input("submit","submit",$submit_value);
	}

$print .= $color_select_box;
$print .= qq(</div>);

$print .= qq(</div>);

$print .= $debug->escape_error_checkbox() if(Mebius::alocal_judge());
$print .= qq(</form>);

#$print .= $html->span("*個人情報掲載、誹謗中傷などはご遠慮ください。",{ class => "alert" });


	if(!$disabled){
		$print .= $self->head_javascript_word_length_count();
	}
$print .= qq(<script>show_length();</script>);

	if($my_account->{'login_flag'}){
		my $left_time_for_response = $use->{'post_data'}->{'first_response_time'} + $init->{'allow_response_time_since_post'} - time;
			if($left_time_for_response >= 1 && $use->{'Response'} && Mebius::alocal_judge()){
				my $how_long = Mebius::second_to_howlong($left_time_for_response);
				$print .= qq(<div class="guide">※あと [ ).e($how_long).qq( ]</div>);
			}
		$print .= $html->span("※$too_many_post_error",{ class => "red" }) if($too_many_post_error);
		$print .= $html->span("※$too_many_response_error",{ class => "red" }) if($too_many_response_error);
	} else {
		$print .= qq(<span class="size90">投稿するには) . Mebius::SNS->please_login_link() . qq(</span>);
	}


$print;


}

#-----------------------------------------------------------
# 報告を展開する
#-----------------------------------------------------------
sub report_line{

my $self = shift;
my $html = new Mebius::HTML;
my $init = $self->init();
my $report = new Mebius::Report;
my $response = new Mebius::Question::Response;
my $post = new Mebius::Question::Post;
my $report = new Mebius::Report;
my($print,%chain_data);

$print .= $html->tag("h2","$init->{'title'}");

my $report_dbi = $report->fetchrow_main_table({ content_type => "question" , answer_time => "0" });

	# すべてのデータを展開
	foreach my $report_data ( @$report_dbi ){

		my $post_number = $report_data->{'targetA'};
		my $response_number = $report_data->{'targetB'};

		my $post_data = $post->fetchrow_main_table({ number => $post_number })->[0]; #
		$chain_data{$post_number}{'post'}{'data'} = $post_data;

			if(!$response_number){
				push @{$chain_data{$post_number}{'post'}{'report_data'}} , $report_data;
			}

			if($response_number){
				my $response_data = $response->fetchrow_main_table({ number => $response_number })->[0];
				$chain_data{$post_number}{'response'}{$response_number}{'data'} = $response_data;
				push @{$chain_data{$post_number}{'response'}{$response_number}{'report_data'}} , $report_data ;
			}
	}


my $num = keys %chain_data;
#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($num)); }

	# 報告されたすべての質問を展開
	foreach my $post_number ( keys %chain_data ){

			my($line);
			my $post_data =	$chain_data{$post_number}->{'post'}->{'data'};
			my $report_data = $chain_data{$post_number}->{'post'}->{'report_data'};
			my $response_many_data = $chain_data{$post_number}->{'response'};

			my $question_view = $self->question_line($post_data,{ ViewReport => 1 });
			$line .= $report->place_by_the_side($question_view,$report_data,{ Thread => 1 , access_data => $post_data });

				# この質問に対してのすべての回答を展開
				foreach my $response_number ( keys %{$response_many_data} ){
					my $response_data = $response_many_data->{$response_number}->{'data'};
					my $report_data = $response_many_data->{$response_number}->{'report_data'};

					my $response_view = $response->data_to_line($response_data,$post_data,{ ViewReport => 1 });
					$line .= $report->place_by_the_side($response_view,$response_many_data->{$response_number}->{'report_data'},{ Res => 1 ,  access_data => $response_data  });
				}

		$print .= $report->around_thread($line);

	}

#$print .= qq(<div class="float-left report_per_res" style="width:48%;">);
#$print .= qq(</div>);
#$print .= qq(<div class="clear"></div>);


$print;

}

#-----------------------------------------------------------
# レポートを禁止する場合
#-----------------------------------------------------------
sub deny_report_response{

my $self = shift;
my $response_data = shift;
my($error);

	if(!$response_data){
		$error = "回答が存在しません。";
	}	elsif($response_data->{'deleted_flag'}){
		$error = "既にこの回答は削除済みです。";
	}

$error;

}


#-----------------------------------------------------------
# 投稿フォームの文字数カウントのための
#-----------------------------------------------------------
sub head_javascript_word_length_count{

my $init = Mebius::Question->init();

# || str.length < $init->{'word_length_small_limit'}

my $head_javascript = qq(
<script><!--
	function show_length( str ) {
			if(str === undefined){
				str = document.getElementById("question_textarea").value;

			}
		var counter = document.getElementById("inputlength");
			if(str.length > $init->{'word_length_limit'}){
				document.getElementById("inputlength").style.color = "red";
				document.getElementById("question_submit").disabled = true;
			} else {
				document.getElementById("inputlength").style.color = "black";
				document.getElementById("question_submit").disabled = false;
			}

		counter.innerHTML = $init->{'word_length_limit'} - str.length;
	}
// --></script>
);

$head_javascript;

}

#-----------------------------------------------------------
# PC向け広告
#-----------------------------------------------------------
sub adverse_big_bunner{

my $self = shift;
my($my_use_device) = Mebius::my_use_device();
my($adverse);
my $query = new Mebius::Query;

	if(!$query->get_method()){ return(); }

$adverse = q(
<script type="text/javascript"><!--
google_ad_client = "ca-pub-7808967024392082";
/* くえすちょん？ */
google_ad_slot = "3796468127";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);

$adverse =~ s/\t//gs;

$adverse = qq($adverse);

$adverse;

}

#-----------------------------------------------------------
# スマフォ向け広告
#-----------------------------------------------------------
sub adverse_mobile_bunner{

my $self = shift;
my($my_use_device) = Mebius::my_use_device();
my($adverse);
my $query = new Mebius::Query;

	if(!$query->get_method_judge()){ return(); }

$adverse = q(
<script type="text/javascript"><!--
google_ad_client = "ca-pub-7808967024392082";
/* くえすちょん？ スマフォ */
google_ad_slot = "2605609724";
google_ad_width = 320;
google_ad_height = 50;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);

$adverse =~ s/\t//gs;

$adverse;

}

#-----------------------------------------------------------
# スマフォ向け広告
#-----------------------------------------------------------
sub adverse_mobile_bunner_styled{

my $self = shift;
my($print);

$print .= qq(<div class="mobile_bunner_label margin-top">広告</div>);
$print .= qq(<div class="margin-bottom">);
$print .= $self->adverse_mobile_bunner();
$print .= qq(</div>);

$print;


}

#-----------------------------------------------------------
# サイトマップ
#-----------------------------------------------------------
sub sitemap_index_view{

my $self = shift;
my $post = new Mebius::Question::Post;
my $question_url = new Mebius::Question::URL;
my $times = new Mebius::Time;
my $init = $self->init();
my $post_dbi = $post->fetchrow_main_table({ deleted_flag => ["<>",1] });
my($line);


my $service_start_localtime = $init->{'service_start_localtime'} || die;
my $year_and_months = $times->foreach_year_and_month_with_localtime($service_start_localtime,time);

	foreach my $hash (@{$year_and_months}){
		$line .= qq(<sitemap>\n);
		$line .= qq(<loc>\n);
		$line .= $question_url->sitemap($hash->{'year'},$hash->{'month'}) . "\n";
		$line .= qq(</loc>\n);
		$line .= qq(</sitemap>\n);
	}

print "Content-type:text/xml\n\n";
print qq(<?xml version="1.0" encoding="UTF-8"?>);
print qq(<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">);
print $line;
print qq(</sitemapindex>);



}


#-----------------------------------------------------------
# サイトマップ
#-----------------------------------------------------------
sub sitemap_view{

my $self = shift;
my $year = shift;
my $month = shift;
my $post = new Mebius::Question::Post;
my $question_url = new Mebius::Question::URL;
my $times = new Mebius::Time;
my $sitemap = new Mebius::Sitemap;
my $init = $self->init();
my($line,@sitemap);

	if(!$year){ die; }
	if(!$month){ die; }

my $start_border_time = $times->year_and_month_to_localtime($year,$month);
my $end_border_time = $times->year_and_month_to_localtime_end($year,$month);
my $post_dbi = $post->fetchrow_main_table([ ["post_time",">=",$start_border_time] , ["post_time","<",$end_border_time] ] , { ORDER_BY => ["post_time DESC"] });

	foreach my $post_data (@{$post_dbi}){

			# フィルタで非表示にする場合
			if(Mebius::Fillter::heavy_fillter($post_data->{'text'})){
				next;
			}

		push @sitemap , { url => $question_url->question($post_data->{'number'}) , lastmod => $post_data->{'last_modified'} } ;

	}

	if(@sitemap >= 1){
		$sitemap->array_to_print(\@sitemap);
	} else {
		Mebius->error("この時期のサイトマップはありません。");
	}

}



1;

