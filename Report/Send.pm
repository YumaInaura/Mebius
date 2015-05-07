
use strict;
use Mebius::BBS;
use Mebius::Vine::Basic;
package Mebius::Report;
use Mebius::Export;
use Mebius::Video::Basic;

#-----------------------------------------------------------
# 報告送信時の、基本エラーチェック
#-----------------------------------------------------------
sub send_report_basic_error_check{

my(@error,@alert);
my($q) = Mebius::query_state();
my($param) = Mebius::query_single_param();

# アクセス制限
main::axscheck("User-report-send");

	# ● Unique-char の判定
	if($q->param('char') eq "" || $q->param('char') !~ /^([a-zA-Z0-9]{20,})$/){
		push(@error,"送信に必要な情報が足りません。");
	}

	# ●筆名のチェック
	{
		my(undef,$handle_error) = Mebius::Regist::name_check($param->{'name'});
			if(ref $handle_error eq "ARRAY"){
				push(@error,@$handle_error);
			}
	}

	# ●メールアドレスの書式チェック
	if($q->param('email')){	
		my($error) = Mebius::Email->format_error($q->param('email'));
			if($error){
				push(@error,g_utf8($error));
			}
	}

	# ●詳細の判定
	{

		# 詳細の文字数判定
		{
			my $detail = $param->{'report_detail'};
			g_utf8($detail);
			$detail =~ s/(\s|　|\r|\n)//g;

				if(length($detail) < 5){
					push(@error,"詳細が短すぎます。");
				} elsif(length($detail) >= 10000){
					push(@error,"詳細が長過ぎます。");
				}
		}

	}

# アラート
my $report_detail = $param->{'report_detail'};
gq_utf8($report_detail);

# 報告本文のキーワードチェック
push @alert,(alert_keyword_check($report_detail));

# クエリを展開してエラーを取得
my(undef,$error_foreach_query,$alert_foreach_query) = foreach_query();
push @error, @$error_foreach_query if @$error_foreach_query;
push @alert, @$alert_foreach_query if @$alert_foreach_query;

\@error,\@alert;

}


#-----------------------------------------------------------
# アラートを出すキーワード
#-----------------------------------------------------------
sub alert_keyword_check{

my($report_detail) = @_;
my(@alert);

	# ネタバレ
	if($report_detail =~ /(ネタバレ)/){
			push(@alert,"「ネタバレ」はルール違反ではないため、基本的に削除されませんが、よろしいですか？");
	}

	# フレコ
	if($report_detail =~ /(フレコ|フレンド(コード|登録))/){
		push(@alert,"違反報告で「フレンドコード」を交換しようとしていませんか？　こちらに送信しても、フレンドコードは交換出来ません。");
	}

	# 投稿ミス
	if($report_detail =~ /(二重投稿|(投稿|送信)ミス|同じ内容|(間違)(.*)(投稿))/){
		push(@alert,"投稿ミスを報告しようとしていませんか？　投稿ミスは基本的に、放置するか、訂正投稿をするなどして対応してください。もし他の方に迷惑がかかっていたり、いちじるしくスレッド進行の邪魔になっている場合は、何をどのように書き間違ったのか、具体的に教えてください。");
	}

@alert;

}

#-----------------------------------------------------------
#報告を送る
#-----------------------------------------------------------
sub send_report{

my $self = shift;
my $report = shift;
my $use = shift;
my $page_back = new Mebius::PageBack;
my($view_line);
my($param) = Mebius::query_single_param();
my($thread,@BCL);
my($table_name) = main_table_name();
my $query = new Mebius::Query;

	# 送信オフの場合
	if(Mebius::Switch::stop_user_report()){
		return();
	}

push(@BCL,"報告の送信");

# 重複チェックなど
my $char = $param->{'char'};
	$char =~ s/\W//g;
my($report_data_group,$result) = Mebius::DBI->fetchrow("SELECT * FROM `$table_name` WHERE unique_char='$char';");
	if($result >= 1 && !Mebius::alocal_judge()){ main::error("この報告は既に完了しています。ブラウザの「戻る」を使って報告を送ると、このエラーが出る場合があります。"); }

# テーブルに新しいレコードを挿入
my($reported_num) = $self->add_new_line($report);

	if(!$reported_num){
		main::error("ひとつも報告する内容がありませんでした。");
	}

$view_line .= qq(<strong class="red">違反報告</strong>を送信しました！);

	if( my $link = $page_back->link()){
		$view_line .= $link;
	}

my $set_cookie = { name => $param->{'name'} , email => $param->{'email'}  };

	#if(Mebius::alocal_judge()){ Mebius::Debug::print_hash($param); }
	#if(Mebius::alocal_judge()){ Mebius::Debug::Error($query->selected_encode_is_utf8()); }

	if($query->selected_encode_is_utf8()){
		$use->{'source'} = "utf8";
	}

# Cookieをセット
Mebius::Cookie::set_main($set_cookie,{ source => $use->{'source'} , SaveToFile => 1 });

# ヘッダ
Mebius::Template::gzip_and_print_all({ Title => "報告の送信" , BCL => \@BCL , source => "utf8" , UTF8 => 1 },$view_line);

exit;

}

#-----------------------------------------------------------
# クエリを元に、ファイルに新しい行を追加
#-----------------------------------------------------------
sub add_new_line{

my $self = shift;
my $report = shift;
my(@self,@query,@error);
my($q) = Mebius::query_state();
my($param) = Mebius::query_single_param();
my $param_utf8 = Mebius::Query->single_param_utf8();
my($my_connection) = Mebius::my_connection();
my $new_unique_number;
my($table_name) = main_table_name();

# 採番のための処理 ( 現在の最大の unique_number を取得する )
my($record) = Mebius::DBI->fetchrow("SELECT unique_number FROM `$table_name`;");
	foreach(@$record){
		$new_unique_number = $_->{'unique_number'} if($_->{'unique_number'} > $new_unique_number);
	}

	# ●クエリを展開して、報告数分の行を増やす
	foreach (@$report) {

		my(@renew_buffer_line);
		my %new = %$_;

		# 筆名
		($new{'handle'}) = Mebius::Regist::name_check($param->{'name'}); # ここでは UTF8 の筆名が返されている
		#($new{'trip'}) = main::trip($param->{'name'});
		$new{'email'} = $param->{'email'};
		$new{'unique_char'} = $param->{'char'};
		$new{'report_time'} = time;

		my($access) = Mebius::my_connection();
		%new = (%new,%$access);

		($new{'report_detail'}) = Mebius::format_query_with_paragraph($param_utf8->{'report_detail'});

		# ユニーク番号を増やす
		$new{'unique_number'} = ++$new_unique_number;

		my($adjusted_set) = adjust_set_main_table(\%new);
		push(@self,$adjusted_set);

	}

Mebius::DBI->insert(undef,$table_name,\@self) if @self;

my $reported_num = @$report;

$reported_num;


}

#-----------------------------------------------------------
# クエリを展開する
#-----------------------------------------------------------
sub foreach_query{

my $self = shift;
my(@report,@error,@alert,$hit_report);
my($param) = Mebius::query_single_param();

my $saying = new Mebius::Saying;
my $tag = new Mebius::Tags;
my $vine = new Mebius::Vine;

my $saying_content = $saying->content();
my $saying_saying = $saying->saying();
my $saying_review = $saying->review();
my $saying_comment = $saying->comment();
my $tags_tag = $tag->tag_object();
my $tags_comment = $tag->comment_object();
my $video = new Mebius::Video;

#my $saying_basic = new Mebius::Saying;

	# ●クエリの展開方法 (レス)
	#if(report_mode_judge_for_res()){

			# ▼複数選択モード
			#if(select_reason_per_res_judge()){

	# すべてのクエリを展開
	foreach my $key (keys %$param ){

		my(%report,$flag,$error_original_thread,$alert_original_thread,$error_reason);

			# 値が存在しない場合は、無視して次の処理へ
			if($param->{$key} eq ""){ next; }

			# 特定のクエリ以外は、関係がないので無視して次の処理へ

			# 掲示板のスレッド
			if($key =~ /^report_(bbs_thread)_([a-z0-9]+)_(\d+)$/){

				$report{'content_type'} = $1;
				my $bbs_kind = $report{'targetA'} = $2;
				my $thread_number = $report{'targetB'} = $3;
				$report{'report_type_res_or_thread'} = "Thread";
				$report{'report_referer_url'} = $param->{"referer_url_bbs_thread_${bbs_kind}_${thread_number}"};
				$report{'report_reason_for_thread'} = $param->{$key};
				($report{'report_category'}) = Mebius::BBS::bbs_kind_to_category_kind($bbs_kind);

				($error_original_thread,$alert_original_thread) = original_thread_error_check({ referer_url => $report{'report_referer_url'} } , "bbs_thread",$param->{$key},$bbs_kind,$thread_number);
				($error_reason) = reason_error_check_for_thread($param->{$key});

			# 掲示板のレス
			} elsif($key =~ /^report_(bbs_thread)_([a-z0-9]+)_(\d+)_(\d+)$/){

				$report{'content_type'} = $1;
				my $bbs_kind = $report{'targetA'} = $2;
				my $thread_number = $report{'targetB'} = $3;
				my $res_number = $report{'report_res_number'} = $4;
				($report{'report_category'}) = Mebius::BBS::bbs_kind_to_category_kind($bbs_kind);

				($error_original_thread,$alert_original_thread) = original_thread_error_check("bbs_thread",$param->{$key},$bbs_kind,$thread_number,$res_number);
				($report{'main_reason'},$report{'sub_reason'}) = split(/-/,$param->{$key});
				($error_reason) = reason_error_check_for_res($param->{$key});

			# SNS日記の本体
			} elsif($key =~ /^report_(sns_diary)_([a-z0-9]+)_(\d+)$/){

				$report{'content_type'} = $1;
				my $account = $report{'targetA'} = $2;
				my $diary_number = $report{'targetB'} = $3;
				$report{'report_type_res_or_thread'} = "Thread";
				$report{'report_reason_for_thread'} = $param->{$key};

				($error_original_thread,$alert_original_thread) = original_thread_error_check({  } , "sns_diary",$param->{$key},$account,$diary_number);
				($error_reason) = reason_error_check_for_thread($param->{$key});

			# SNS日記のレス
			} elsif($key =~ /^report_(sns_diary)_([a-z0-9]+)_(\d+)_(\d+)$/){

				$report{'content_type'} = $1;
				my $account = $report{'targetA'} = $2;
				my $diary_number = $report{'targetB'} = $3;
				my $res_number = $report{'report_res_number'} = $4;
				($report{'main_reason'},$report{'sub_reason'}) = split(/-/,$param->{$key});

				($error_original_thread,$alert_original_thread) = original_thread_error_check("sns_diary",$param->{$key},$account,$diary_number,$res_number);
				($error_reason) = reason_error_check_for_res($param->{$key});


			# SNSの伝言板
			} elsif($key =~ /^report_(sns_comment_boad)_([a-z0-9]+)_(\d+)(_(\d{4,5}))?$/){

				$report{'content_type'} = $1;
				my $account = $report{'targetA'} = $2;
				my $res_number = $report{'report_res_number'} = $3;
				my $year = $report{'targetB'} = $5 if($5);
				($error_reason) = reason_error_check_for_res($param->{$key});
				my($comment_boad) = Mebius::SNS::CommentBoad::log_file_state({ year => $year } ,$account);
					if(!$comment_boad->{'f'}){
						push @error , "この伝言板は存在しません。";
					}

			# くえすちょん？ の質問本体
			} elsif($key =~ /^report_(question_post)_([^_]+)$/){

				my $post = new Mebius::Question::Post;

				$report{'content_type'} = "question";
				my $post_number = $report{'targetA'} = $2;
				$report{'report_reason_for_thread'} = $param->{$key};

				my $post_data = $post->fetchrow_main_table({ number => $post_number })->[0];
					if($post_data->{'deleted_flag'}){
						push @error , "削除済みの質問が含まれています。";
						next;
					}

			# くえすちょん？ の回答
			} elsif($key =~ /^report_(question_response)_([^_]+)$/){

				my $response = new Mebius::Question::Response;

				$report{'content_type'} = "question";
				my $response_number = $report{'targetB'} = $2;
				my $response_data = $response->fetchrow_main_table({ number => $response_number })->[0];
					if($response_data->{'deleted_flag'}){
						push @error , "削除済みの回答が含まれています。";
						next;
					}

				my $post_number = $report{'targetA'} = $response_data->{'target_post_number'} || die;

				($report{'main_reason'},$report{'sub_reason'}) = split(/-/,$param->{$key});


			} elsif( my $report_data = $tags_tag->param_to_report_data($key)){
				%report = %{$report_data};
			}	elsif( my $report_data = $tags_comment->param_to_report_data($key)){
				%report = %{$report_data};
			}	elsif( my $report_data = $video->param_to_report_data_all_objects($key)){
				%report = %{$report_data};
			}	elsif( my $report_data = $vine->param_to_some_report_data($key)){
				%report = %{$report_data};
			} else {
				next;
			}

		push @alert , @$alert_original_thread if ($alert_original_thread);
		push @error , @$error_original_thread if($error_original_thread);
		push @error , @$error_reason if($error_reason);

			# 本文に対してのレポートの場合
			if(%report && !@error){
				$hit_report ++;
				push @report , \%report;
			}

	}

	if($hit_report >= 30){
		push @error , "そんなにいちどにたくさん報告できません。";
	} elsif($hit_report == 0){
		push @error , "報告対象がひとつも選ばれていない、もしくは報告理由が選ばれていません。";
	}


\@report,\@error,\@alert;

}


#-----------------------------------------------------------
# オリジナルスレッドのエラーを確認する
#-----------------------------------------------------------
sub original_thread_error_check{

my $use = shift if(ref $_[0] eq "HASH");
my($content_type,$report_reason_type,$target_kind,$thread_number,$res_number) = @_;
my(@error,$success_flag,$thread,@alert);

	if($content_type eq "bbs_thread"){

		($thread) = Mebius::BBS::thread_state($thread_number,$target_kind); # 掲示板用

	} elsif($content_type eq "sns_diary"){
		($thread) = Mebius::SNS::Diary::thread_state($target_kind,$thread_number);

	} else {
		die;
	}


	# 判定
	if($thread->{'deleted_flag'}){

		push @error , "このスレッドは削除済みです。";

	} elsif($thread->{'f'}){

			# ▼レスの報告
			if($res_number ne ""){

					if($res_number eq "0"){
						push @error , "0番目のレスは報告出来ません。スレッド本体を報告してください。";
					} elsif($content_type eq "bbs_thread" && Mebius::BBS::comment_deleted_judge($thread->{'res_data'}->{$res_number})){
						push @error , e($res_number).q(番のコメントは削除済みです。);
					} elsif($res_number > $thread->{'res'}){
						push @error , "存在しないレスを報告しようとしています。";
					}

			# ▼スレッドの報告
			} else {

					# 古いスレッドの場合は警告を出す
					if(time > $thread->{'posttime'} + 3*30*24*60*60){
						my($how_long_ago) = Mebius::second_to_howlong({ TopUnit => 1 } , time - $thread->{'posttime'});
						push(@alert,e($how_long_ago).qq(前に作られたスレッドです。時効となっている可能性がありますが、よろしいですか？));
					}

					# レスが多い場合は警告を出す
					if($thread->{'res'} >= 200){
						push(@alert,e($thread->{'res'}).qq(個のレスがあるスレッドです。時効となっている可能性がありますが、よろしいですか？));
					}

					# 必須項目がない場合
					my($kind_list_for_thread) = Mebius::Reason::kind_list_for_thread();
					if($kind_list_for_thread->{$report_reason_type}->{'MustRefererURL'} && $use->{'referer_url'} eq ""){
						push @error,"参照URLを入力してください。";
					}

			}

	} else {
		push @error , "スレッドが存在しません。";
	}

	# 参照元のスレッド
	if($use->{'referer_url'}){

			# 書式チェック
			if($use->{'referer_url'} && !Mebius::url_format_check($use->{'referer_url'})){
				push(@error,"参照スレッドのURLの書式が間違っています。");

			# 書式が間違っていない場合
			} else {

				# 参照元スレッドの状態を判定
				my($referer_thread) = Mebius::BBS::thread_url_to_thread_data($use->{'referer_url'});

					if(!$referer_thread->{'f'}){
						push(@error,qq(参照元のスレッド \( ).e($use->{'referer_url'}).qq( \) は存在しません。));
					} elsif($referer_thread->{'keylevel'} < 1){
						push(@error,"参照元のスレッド \( ).e($use->{'referer_url'}).qq( \) は現行スレッドではありません。");
					} elsif($referer_thread->{'bbs_kind'} eq $target_kind && $referer_thread->{'thread_number'} eq $thread_number){
						push(@error,"同じスレッドは、参照元のスレッドとして報告出来ません。");
					} elsif($referer_thread->{'bbs_kind'} ne $target_kind && $report_reason_type eq "1"){
						push(@error,"他の掲示板のスレッドは、重複記事として報告出来ません。");
					} elsif($thread->{'res'} >= $referer_thread->{'res'} && $report_reason_type eq "1"){
						push(@error,"あなたが報告したスレッドは、参照スレッドより、レス数が多いです。");
					} elsif($thread->{'posttime'} < $referer_thread->{'posttime'} && $report_reason_type eq "1"){
						push(@error,"あなたが報告したスレッドは、参照スレッドより、昔に作られました。");
					}
			}

	}

\@error,\@alert;

}

#-----------------------------------------------------------
# 依頼理由の不正チェック ( レス )
#-----------------------------------------------------------
sub reason_error_check_for_res{

my($report_reason) = @_;
my(@error);

	# 依頼理由が選択されていない場合
	if($report_reason eq ""){
		push(@error,"依頼理由を選んで下さい。");

	# 依頼理由が不正な場合
	} else {
		my $justy_flag;
		my($kind_list) = Mebius::Reason::kind_list_for_res();
			foreach my $kind ( keys %$kind_list){
					foreach my $group ( @{$kind_list->{$kind}->{'group'}} ){
						if($report_reason =~ /^$kind_list->{$kind}->{'type'}-$group->{'type'}$/){ $justy_flag = 1; }
					}
			}
			if(!$justy_flag){
				push(@error,"依頼理由が不正です。");
			}
	}

\@error;

}

#-----------------------------------------------------------
# 依頼理由の不正チェック ( スレッド )
#-----------------------------------------------------------
sub reason_error_check_for_thread{

my($report_reason) = @_;
my(@error);

# 必須項目がない場合
my($kind_list_for_thread) = Mebius::Reason::kind_list_for_thread();


	# 違反報告のタイプの判定
	if($report_reason eq ""){
		push @error,"違反タイプを選んでください。";

	}elsif(!$kind_list_for_thread->{$report_reason}){
		push @error,"存在しない違反タイプが報告されています。";
	}

\@error;

}

#-----------------------------------------------------------
# 報告モードかどうかを判定する ( 全体 )
#-----------------------------------------------------------
sub report_mode_judge{

my($q) = Mebius::query_state();
my($self);

	if(report_mode_judge_for_res() || report_mode_judge_for_thread()){
		$self = 1;
	}

}


#-----------------------------------------------------------
# 報告モードかどうかを判定する ( レス )
#-----------------------------------------------------------
sub report_mode_judge_for_res{

my($q) = Mebius::query_state();
my($self);

	if($q->param('report_mode') eq "res" || $q->param('report_mode_for_res')){
		$self = 1;
	}

}


#-----------------------------------------------------------
# 報告モードかどうかを判定する ( スレッド )
#-----------------------------------------------------------
sub report_mode_judge_for_thread{

my($q) = Mebius::query_state();
my($self);

	if($q->param('report_mode') eq "thread" || $q->param('report_mode_for_thread')){
		$self = 1;
	}

}


#-----------------------------------------------------------
# 報告を送っているかどうかを判定する
#-----------------------------------------------------------
sub send_report_judge{

my($q) = Mebius::query_state();
my($self);

	if($ENV{'REQUEST_METHOD'} eq "POST" && $q->param('send_report')){
		$self = 1;
	}

$self;

}

#-----------------------------------------------------------
# 報告 本送信チェック (レス)
#-----------------------------------------------------------
sub send_report_justy_judge{

my $use = shift if(ref $_[0] eq "HASH");
my($q) = Mebius::query_state();
my($param) = Mebius::query_single_param();
my($self);

	# そもそも送信モードでなければリターン
	if(!send_report_judge()){ return(); }

	# 投稿制限
	main::axscheck("User-report-send");

# 基本エラーチェック
my($error,$alert) = send_report_basic_error_check();

	# エラーでもプレビューでもなければ
	if(@$error <= 0 && !$q->param('preview') && (@$alert <= 0 || $param->{'break_alert'})){

		$self = 1;
	}

$self;

}

#-----------------------------------------------------------
# 掲示板スレッドへの報告であることを判定
#-----------------------------------------------------------
sub bbs_thread_judge{

my($flag);
my($param) = Mebius::query_single_param();

	if(Mebius::BBS::bbs_script_judge() && $param->{'mode'} eq "view" && $param->{'no'} =~ /^(\d+)$/){
		$flag = 1;
	}

$flag;

}


#-----------------------------------------------------------
# SNS への違反報告であることを判定
#-----------------------------------------------------------
sub sns_diary_judge{

my($flag);
my($param) = Mebius::query_single_param();

	if($ENV{'SCRIPT_NAME'} =~ m!/auth\.cgi$! && $param->{'mode'} =~ /^d-/){
		$flag = 1;
	}

$flag;

}

#-----------------------------------------------------------
# SNS への違反報告であることを判定
#-----------------------------------------------------------
sub sns_comment_boad_judge{

my($flag);
my($param) = Mebius::query_single_param();

	if($ENV{'SCRIPT_NAME'} =~ m!/auth\.cgi$! && $param->{'mode'} =~ /^viewcomment/){
		$flag = 1;
	}

$flag;

}

1;