	
use strict;
use Mebius::Question::View;
use Mebius::Question::Post;
use Mebius::Question::Response;
use Mebius::Question::URL;
use Mebius::Question::Ranking;
use Mebius::URL;
use Mebius::PenaltyUTF8;
package Mebius::Question;
use base qw(Mebius::Base::Basic);

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
sub limited_all_objects{

my $self = shift;
my(%object);

$object{'post'} = $self->post_object();
$object{'response'} = $self->response_object();
#$object{'view'} = $self->view_object();

\%object;

}


#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub post_object{
my $self = shift;
my $post = new Mebius::Question::Post;
}

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub response_object{
my $self = shift;
my $response = new Mebius::Question::Response;
}

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub view_object{
my $self = shift;
my $response = new Mebius::Question::View;
}

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub init{

my(%init);
my $url = new Mebius::URL;

$init{'title'} = qq(くえすちょん？);
$init{'word_length_limit'} = 140;
$init{'word_length_small_limit'} = 6;
$init{'word_length_small_limit_response'} = 1;

$init{'service_start_localtime'} = 1376636888;

# 一定時間内に新規質問できる個数
$init{'max_post_border_hour'} = 24;
$init{'max_post_num_per_limit'} = 5;

# 一定時間内に回答できる個数
$init{'max_response_border_hour'} = 24;
$init{'max_response_num'} = 50;

$init{'domain'} = "question.mb2.jp";

# 回答締め切り時間
$init{'allow_response_time_since_post'} = 1*24*60*60;

# いいね! 締め切り時間
#$init{'push_good_limit_since_post_time'} = 3*24*60*60;
$init{'push_good_limit_since_post_time'} = 1*24*60*60;

	if(Mebius::alocal_judge()){
		$init{'base_url'} = $url->server_url() . "/_question/";
	} else {
		#$init{'base_url'} = $url->relative_or_full_url("http://question.mb2.jp/");
		$init{'base_url'} = "http://question.mb2.jp/";
	}


\%init;

}


#-----------------------------------------------------------
# モード分岐
#-----------------------------------------------------------
sub junction{

my $self = shift;
my($param) = Mebius::query_single_param();

my $view = new Mebius::Question::View;
my $response = new Mebius::Question::Response;
my $ranking = new Mebius::Question::Ranking;

# 違反報告
Mebius::Report::report_mode_junction({ });


	if($param->{'tail'}){
			if($param->{'mode'} eq "sitemap_index" && $param->{'tail'} eq "xml"){
				$view->sitemap_index_view();
			} elsif($param->{'mode'} =~ /^sitemap-([0-9]{1,4})-([0-9]{1,2})$/ && $param->{'tail'} eq "xml"){
				my $year = $1;
				my $month = $2;
				$view->sitemap_view($year,$month);
			} else {
				Mebius->error("このページは存在しません。");
			}
	} elsif($param->{'mode'} eq "post") {
		Mebius::Question::Post->new_post();
	} elsif($param->{'mode'} eq "response"){
		Mebius::Question::Response->new_response();
	} elsif($param->{'mode'} eq "control"){
		$self->control();
	} elsif($param->{'mode'} eq "my_question"){
		$view->my_question_view();
	} elsif($param->{'mode'} eq "deleted"){
		$view->deleted_question_view();
	} elsif($param->{'mode'} eq "recently"){
		$view->recently_question_view();
	} elsif($param->{'mode'} eq "search"){
		$view->search_view();
	} elsif($param->{'mode'} eq "ranking"){
		$ranking->answerer_ranking_view();
	} elsif($param->{'mode'} eq "my_history"){
		$response->my_history_view();
	} elsif($param->{'mode'} eq "no_answer"){
		$view->no_answer_question_view();
	} elsif($param->{'mode'} eq "recently_response"){
		$view->recently_responsed_question_view();
	} elsif($param->{'mode'} eq "log"){
		$view->log_question_view();
	} elsif($param->{'mode'} eq "high_access"){
		$view->high_access_question_view();
	} elsif($param->{'mode'} =~ /^log-([0-9]+)-([0-9]+)$/) {
		$view->month_question_view($1,$2);
	} elsif($param->{'mode'} eq "") {

			# 個別の質問ページを閲覧
			if($param->{'q'}){
				$view->question_view();
			# トップページを閲覧
			} else {
				$view->top_page_view();
			}

	} else {
		Mebius->error("このページは存在しません。");
	}

}

#-----------------------------------------------------------
# 投稿時の共通のエラー
#-----------------------------------------------------------
sub regist_common_error{

my $self = shift;
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my $init = $self->init();
my $regist = new Mebius::Regist;

	if(!$my_account->{'login_flag'}){
		$self->error("答えるにはログインして下さい。");
	}

$self->send_common_error($self);

	my $url_error = $regist->deny_url($param->{'text'});
		if($url_error){
			$self->error("URLは書き込めません。");
		}


0;

}

#-----------------------------------------------------------
# 共通のエラー
#-----------------------------------------------------------
sub send_common_error{

my $self = shift;
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();

	if($my_account->{'id'} ne $param->{'my_account'}){
		warn("Strange send of  $self ");
		$self->error("送信方法が変です。");
	}

0;

}


#-----------------------------------------------------------
# いろいろな操作
#-----------------------------------------------------------
sub control{

my $self = shift;
my $use = shift || {};
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my $init = $self->init();
my $post = new Mebius::Question::Post;
my $response = new Mebius::Question::Response;
my $report = new Mebius::Report;
my $view = new Mebius::Question::View;
my $ranking = new Mebius::Question::Ranking;
my $penalty = new Mebius::Penalty;
my $sns_feed = new Mebius::SNS::Feed;

Mebius::Query->post_method_or_error();

	# すべてのクエリを展開
	foreach my $key ( keys %{$param} ){

			# ●報告モード
			if($key =~ /^report_question_post_preview_([^_]+)$/){
				my $post_number = $1;
				$view->question_view({ question_number => $post_number , ReportPost => 1 });

			# ●報告モード
			} elsif($key =~ /^report_question_response_preview_([^_]+)$/){

				my $response_number = $1;
				my $response_data = $response->fetchrow_main_table({ number => $response_number })->[0];
				$view->question_view({ question_number => $response_data->{'target_post_number'} , ReportResponse => 1 , limited_view_response => { $response_number => 1 } });



			} elsif($response->param_to_push_good($key)){
					if(rand(25) < 1 || Mebius::alocal_judge()){ $ranking->response_data_group_to_insert_main_table(); }
				last;
			# ●ベストアンサーをつける
			} elsif($key =~ /^question_best_answer_([^_]+)_([^_]+)$/){
				my $post_number = $1;
				my $response_number = $2;

				$self->decide_best_answer($post_number,$response_number);
				last;

			# ●ベストアンサーをキャンセルする
			} elsif($key =~ /^question_cancel_best_answer_([^_]+)_([^_]+)$/){
				my $post_number = $1;
				my $response_number = $2;

				$self->cancel_best_answer($post_number,$response_number);
				last;

			# ●質問本体の操作
			} elsif($key =~ /^question_control_post_([^_]+)$/ && Mebius->common_admin_judge()){

				$self->send_common_error() if(!Mebius::Admin::admin_mode_judge());

				my (%update,%where,$update_flag);
				my $post_number = $1;
				my $control_type = $param->{$key};
				my $post_data = $self->post_number_to_data($post_number);

				$update{'control_time'} = time;
				$update{'control_account'} = $my_account->{'id'};
				$where{'number'} = $post_number;

					# 管理者以外は、自分の投稿しか操作できないように
					if(!Mebius->common_admin_judge()){
						$where{'account'} = $my_account->{'id'};
					}


					if($control_type eq "delete"){
						$update{'deleted_flag'} = time;
						$update_flag = 1;
					} elsif($control_type eq "penalty" && Mebius->common_admin_judge()){
						$update{'deleted_flag'} = time;
						$update{'penalty_flag'} = time;
						$update_flag = 1;
						$penalty->add($post_data,{ place => $init->{'title'} , source => "utf8" });
					} elsif($control_type eq "revive" && Mebius->common_admin_judge()){
						$update{'deleted_flag'} = 0;
						$update_flag = 1;
							if($post_data->{'penalty_flag'}){
								$penalty->cancel($post_data);
								$update{'penalty_flag'} = 0;
							}
					} elsif($control_type eq "no-reaction"){
						0;
					} else {
						next;
					}

					if($update{'deleted_flag'} eq "1"){
						$post->delete_on_status($post_data);
					} elsif($update{'deleted_flag'} eq "0"){
						$post->revive_on_status($post_data);
					}


				$post->update_main_table(\%update,{ WHERE => \%where }) if($update_flag);

					# レポートへの対応
					if(Mebius->common_admin_judge()){
						$report->update_main_table({ answer_time => time },{ WHERE => { content_type => "question" , targetA => $post_number , targetB => ["is","NULL"] } });
					}

					# SNSの新着フィードから削除
					$sns_feed->update_main_table({ deleted_flag => 1 },{ WHERE => { content_type => "question" , data1 => $post_number  } });

			# ●回答の操作
			} elsif($key =~ /^question_control_response_([^_]+)$/ && Mebius->common_admin_judge()){

				$self->send_common_error() if(!Mebius::Admin::admin_mode_judge());

				my $response_number = $1;
				my $control_type = $param->{$key};
				my (%update,%where,$update_flag);
				my $response_data = $self->response_number_to_data($response_number);

				$where{'number'} = $response_number;
				$update{'control_time'} = time;
				$update{'control_account'} = $my_account->{'id'};

					# 管理者以外は、自分の投稿しか操作できないように
					if(!Mebius->common_admin_judge()){
						$where{'account'} = $my_account->{'id'};
					}

					if($control_type eq "delete"){
						$update{'deleted_flag'} = time;
						$update_flag = 1;
					} elsif($control_type eq "penalty" && Mebius->common_admin_judge()){
						$update{'deleted_flag'} = time;
						$update{'penalty_flag'} = 1;
						$update_flag = 1;
						$penalty->add($response_data,{ place => $init->{'title'} , source => "utf8" });
					} elsif($control_type eq "revive" && Mebius->common_admin_judge()){
						$update{'deleted_flag'} = 0;
						$update_flag = 1;
							if($response_data->{'penalty_flag'}){
								$penalty->cancel($response_data);
								$update{'penalty_flag'} = 0;
							}
					} elsif($control_type eq "no-reaction"){
						0;
					} else {
						next;
					}

				my $done = $response->update_main_table(\%update,{ WHERE => \%where }) if($update_flag);

					# レポートへの対応
					if(Mebius->common_admin_judge()){
						my $post_number = $self->response_number_to_post_number($response_number);
						$report->update_main_table({ answer_time => time },{ WHERE => { content_type => "question" , targetA => $post_number , targetB => $response_number } });
					}

			}

	}

	if(!$use->{'FROM_REPORT'}){
		Mebius::redirect_to_back_url();
		exit;
	}

}

#-----------------------------------------------------------
# いいねを押す
#-----------------------------------------------------------
#sub push_good{
#
#my $self = shift;
#my $response_number = shift;
#my $response = new Mebius::Question::Response;
#my $post = new Mebius::Question::Post;
#my($my_account) = Mebius::my_account();
#
#$self->send_common_error();
#
## アクセス制限
#Mebius->axs_check("ACCOUNT");
#
## レス固有のデータを取得
#my($dbi_response,$result_response) = $response->fetchrow_main_table({ number => $response_number });
#my $data_response = $dbi_response->[0];
#
## 質問本体のデータを取得
#my($dbi_post,$result_post) = $post->fetchrow_main_table({ number => $data_response->{'target_post_number'} });
#my $post_data = $dbi_post->[0];
#
#my $push_good_error = $self->deny_push_good($data_response,$post_data);
#	if($push_good_error){
#		$self->error($push_good_error);
#	}
#
#	if($result_post <= 0){
#		Mebius->error("この質問は存在しません。");
#	} #elsif($post->best_answered_judge($post_data)){
#		#Mebius->error("この質問には既にベストアンサーがついているのでいいね出来ません。");
#	#}
#
#$my_account->{'id'} || die;
#
#$response->update_main_table({ good_num => ['+','1',] , good_accounts => ['.'," $my_account->{'id'}"] , number => $response_number , decide_best_answer_account => $my_account->{'id'} });
#
#}

#-----------------------------------------------------------
# いいねを押せない場合
#-----------------------------------------------------------
sub deny_push_good{

my $self = shift;
my $response_data = shift;
my $post_data = shift;
my($my_account) = Mebius::my_account();
my $init = $self->init();
my($error);

my $limit = $init->{'push_good_limit_since_post_time'} || die("please setting init data.");

my $left_push_good_num = $self->left_push_good_num($response_data);

	if($self->escape_error()){
		return();
	} elsif(!$response_data){ 
		$error = "回答が存在しません。";
	} elsif($post_data->{'first_response_time'} && time > $post_data->{'first_response_time'} + $limit){
		$error = "いいねできる期限が切れています。";
	} elsif(!$my_account->{'login_flag'}){
		$error = "ログインしていません。";
	}	elsif($response_data->{'account'} eq $my_account->{'id'}){
		$error = "自分の回答にはいいね出来ません。";
	} elsif($left_push_good_num <= 0){
		$error = "既にいいねしています。";
	}

$error;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub left_push_good_num{

my $self = shift;
my $response_data = shift;
my $post_data = shift;
my($my_account) = Mebius::my_account();
my $push_good_num = $self->count_push_good_num($response_data);
my($max_push_good_num);

	# 自分の質問に存在する回答には、復数のいいねをつけられる
	if($post_data->{'account'} eq $my_account->{'id'}){
		$max_push_good_num = 3;
	# 他の人の回答には 1回までいいねをつけられる
	} else {
		$max_push_good_num = 1;
	}

my $left_push_good_num = $max_push_good_num - $push_good_num;

	if($left_push_good_num < 0){
		$left_push_good_num = 0;
	}

$left_push_good_num;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub count_push_good_num{

my $self = shift;
my $response_data = shift;
my($my_account) = Mebius::my_account();
my $push_good_num;

		foreach my $account (split/\s/,$response_data->{'good_accounts'}){
				if(!$account){ next; }
				if($account eq $my_account->{'id'}){ $push_good_num++; }
		}

$push_good_num;

}


#-----------------------------------------------------------
# ベストアンサーを決める
#-----------------------------------------------------------
sub decide_best_answer{

my $self = shift;
my $post_number = shift;
my $response_number = shift;
my $response = new Mebius::Question::Response;
my $post = new Mebius::Question::Post;
my($my_account) = Mebius::my_account();

$self->send_common_error();

my $post_data = $post->fetchrow_main_table({ number => $post_number })->[0];

	if($self->deny_best_answer($post_data) && !$self->escape_error()){
		$self->error($self->deny_best_answer($post_data));
	}

my $response_data = $response->fetchrow_main_table({ target_post_number => $post_number })->[0];

$post->update_main_table({ number => $post_number , best_answer_response_number => $response_number , best_answer_time => time , decide_best_answer_account => $my_account->{'id'} });


}

#-----------------------------------------------------------
# ベストアンサーを付けられない場合
#-----------------------------------------------------------
sub deny_best_answer{

my $self = shift;
my $post_data = shift;
my($my_account) = Mebius::my_account();
my $post = new Mebius::Question::Post;
my($error);
	
	if(!$self->use_best_answer_system()){
		$error = "ベストアンサー機能は停止中です。。";
	}	elsif(!$post_data){
		$error = "質問が存在しません。";
	} elsif(!$my_account->{'login_flag'}){
		$error = "ログインしていません。";
	} elsif($post_data->{'account'} ne $my_account->{'id'}){
		$error = ("あなたの質問ではありません。");
	} elsif($post->best_answered_judge($post_data)){
		$error = ("既にベストアンサーは決定済みです。");
	} elsif($post_data->{'deleted_flag'}){
		$error = ("この質問は削除済みです。");
	}

$error;

}
#-----------------------------------------------------------
# ベストアンサーを決める
#-----------------------------------------------------------
sub cancel_best_answer{

my $self = shift;
my $post_number = shift;
my $response_number = shift;
my $response = new Mebius::Question::Response;
my $post = new Mebius::Question::Post;
my($my_account) = Mebius::my_account();

$self->send_common_error();

my $post_data = $post->fetchrow_main_table({ number => $post_number })->[0];

	if($self->deny_cancel_best_answer($post_data) && !$self->escape_error()){
		$self->error($self->deny_cancel_best_answer($post_data));
	}

my $response_data = $response->fetchrow_main_table({ target_post_number => $post_number })->[0];

$post->update_main_table({ number => $post_number , best_answer_response_number => "" , best_answer_time => 0 , decide_best_answer_account => "" });


}

#-----------------------------------------------------------
# ベストアンサーを付けられない場合
#-----------------------------------------------------------
sub deny_cancel_best_answer{

my $self = shift;
my $post_data = shift;
my($my_account) = Mebius::my_account();
my $post = new Mebius::Question::Post;
my($error);

	if(!$self->use_best_answer_system()){
		$error = "ベストアンサー機能は停止中です。";
	} elsif(!$post_data){
		$error = "質問が存在しません。";
	} elsif($post_data->{'account'} ne $my_account->{'id'}){
		$error = ("あなたの質問ではありません。");
	} elsif(!$my_account->{'login_flag'}){
		$error = "ログインしていません。";
	} elsif(!$post_data->{'best_answer_time'}){
		$error = ("まだベストアンサーが付いていない質問です。");
	} elsif(time > $post_data->{'best_answer_time'} + 30*60){
		$error = ("ベストアンサーをつけてから時間が経ちすぎているため、取り消せません。");
	} elsif($post_data->{'deleted_flag'}){
		$error = ("この質問は削除済みです。");
	}

$error;

}

#-----------------------------------------------------------
# 新しい重複していない char を作る
#-----------------------------------------------------------
sub create_new_char{

my $self = shift;
my $length = shift;
my($new_char);

	# 新しい charの重複チェック
	for(1..20){

		my $char = Mebius::Crypt->char($length);

		my $dbi_data_char = $self->fetchrow_main_table({ number => $char })->[0];

			if(!$dbi_data_char){
				$new_char = $char;
				last;
			}
	}

$new_char;

}

#-----------------------------------------------------------
# エラー
#-----------------------------------------------------------
sub error{

my $self = shift;
Mebius->error(@_);

}

#-----------------------------------------------------------
# 動作確認のため、特定のエラーを回避する場合
#-----------------------------------------------------------
sub escape_error{

my $self = shift;
my $debug = new Mebius::Debug;
$debug->escape_error(@_);

}

#-----------------------------------------------------------
# ベストアンサー機能を使うかどうか
#-----------------------------------------------------------
sub use_best_answer_system{
0;
}

#-----------------------------------------------------------
# 報告モードかどうかを判定する
#-----------------------------------------------------------
sub report_mode_judge{

my $self = shift;
my($param) = Mebius::query_single_param();
my($report_mode_flag);

	if($ENV{'REQUEST_METHOD'} ne "POST"){
		return();
	}

	foreach my $key ( keys %{$param} ){

			if($key =~ /^report_question_(.+)_preview/){
				$report_mode_flag = 1;
			}
	}

	if(Mebius::Report::report_mode_judge()){
		$report_mode_flag = 1;
	}

$report_mode_flag;

}

#-----------------------------------------------------------
# 回答ナンバーから回答データを抽出
#-----------------------------------------------------------
sub response_number_to_data{

my $self = shift;
my $response_number = shift;
my $response = new Mebius::Question::Response;

my $response_data = $response->fetchrow_main_table({ number => $response_number })->[0];

$response_data;

}

#-----------------------------------------------------------
# 回答ナンバーから回答データを抽出
#-----------------------------------------------------------
sub post_number_to_data{

my $self = shift;
my $post_number = shift;
my $post = new Mebius::Question::Post;

my $post_data = $post->fetchrow_main_table({ number => $post_number })->[0];

$post_data;

}

#-----------------------------------------------------------
# 回答ナンバーから質問本体のデータを返す
#-----------------------------------------------------------
sub response_number_to_post_data{

my $self = shift;
my $response_number = shift;

my $response_data = $self->response_number_to_data($response_number);
my $post_data = $self->post_number_to_data($response_data->{'target_post_number'});

$post_data;

}

#-----------------------------------------------------------
# 回答ナンバーから質問本体のナンバーを割り出す
#-----------------------------------------------------------
sub response_number_to_post_number{

my $self = shift;
my $response_number = shift;

my $post_data = $self->response_number_to_post_data($response_number);

$post_data->{'number'};

}


#-----------------------------------------------------------
# HTMLを出力する共通処理
#-----------------------------------------------------------
sub print_html{

my $self = shift;
my $body = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $init = Mebius::Question->init();
my($my_account) = Mebius::my_account();
my($my_use_device) = Mebius::my_use_device();
my $html = new Mebius::HTML;
my $device = new Mebius::Device;
my $view = new Mebius::View;
my $question_view = new Mebius::Question::View;
my($title,$print,@BCL);

	if($use->{'BCL'}){
		push @BCL , { url => $init->{'base_url'}, title => $init->{'title'} };
	} else {
		push @BCL , $init->{'title'};
	}

my $inline_css = qq(
.question_textarea_width{width:18em;}
);

push @BCL , @{$use->{'BCL'}} if(ref $use->{'BCL'} eq "ARRAY");
	if($use->{'Title'}){
		$title = "$use->{'Title'} | $init->{'title'}";
	} else {
		$title = "$init->{'title'}";
	}

my $relay_use = Mebius::Operate->overwrite_hash($use,{ BCL => \@BCL , source => "utf8" , Title => $title , inline_css => $use->{'inline_css'}.$inline_css });

my @links = (
{ url => "$init->{'base_url'}" , title => "ホーム" } , 
{ url => "$init->{'base_url'}recently" , title => "新着" } , 
{ url => "$init->{'base_url'}ranking" , title => "ランキング" } , 
);

my @my_links = (
{ url => "$init->{'base_url'}my_question" , title => "質問" } , 
{ url => "$init->{'base_url'}my_history" , title => "回答" } , 
);

	#if(!$my_account->{'login_flag'}){
		#$print .= qq(<div class="message-blue" style="margin-bottom:2em;">);
		#$print .= qq(→このページを利用するには);
		#$print .= Mebius::SNS->please_login_link();
		#$print .= qq(</div>);
	#}


$print .= qq(<div class="">);
$print .= $html->tag("h1",$use->{'h1'});
$print .= qq(</div>);

	if($my_account->{'login_flag'}){
			if($my_use_device->{'smart_phone_flag'}){
				$print .= $html->start_tag("div",{ class => "margin-bottom word-spacing scroll" });
			} else {
				$print .= $html->start_tag("div",{ class => "margin-bottom float-left word-spacing" });
			}
		$print .= $html->start_tag("div",{ class => "scroll-element" });
		$print .= $view->on_off_links(\@links);
		$print .= " | 自分: ";
		$print .= $view->on_off_links(\@my_links);
		$print .= $html->close_tag("div");
		$print .= $html->close_tag("div");
	}

	if(!$device->use_device_is_smart_phone()){
		$print .= qq(<div class="float-right">);
		$print .= $question_view->search_form();
		$print .= qq(</div>);
	}

$print .= qq(<div class="clear"></div>);

$print .= $body;

Mebius::Template::gzip_and_print_all($relay_use,$print);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_limited_package_name{
"question";
}



1;

