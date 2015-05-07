
use strict;
package Mebius::Report;
use Mebius::SNS::CommentBoad;
use Mebius::Video::Basic;

#-----------------------------------------------------------
# 報告を展開
#-----------------------------------------------------------
sub report_view_core{

my($use) = @_;
my($q) = Mebius::query_state();
my($kind_list_for_thread) = Mebius::Reason::kind_list_for_thread();
my($kind_list_for_res) = Mebius::Reason::kind_list_for_res();
my($table_name) = main_table_name() || die;
my $self = __PACKAGE__;
my $query = new Mebius::Query;
my $param  = $query->param();
my($return,$hit_thread,$max_view_thread,$hit_all_unique,$hit_all_report_for_thread,$hit_all_res,%all_hash,$report_array);

	# 汚染チェック
	if($use->{'content_type'} =~ /\W/){ die; }

	if($param->{'view_type'} eq "still_admin_check"){
		($report_array) = Mebius::DBI->fetchrow("SELECT * FROM `$table_name` WHERE content_type='$use->{'content_type'}';");
	} else {
		($report_array) = Mebius::DBI->fetchrow("SELECT * FROM `$table_name` WHERE content_type='$use->{'content_type'}' and answer_time='0';");
	}

	foreach(@$report_array){
		$all_hash{"$_->{'targetA'}-$_->{'targetB'}-$_->{'targetC'}"}{$_->{'report_res_number'}}{$_->{'unique_number'}} = { data => $_ };
	}

my $all_hash = \%all_hash;

	# スレッド最大表示数
	if(Mebius::Admin::admin_mode_judge()){
		$max_view_thread = 50;
	} else {
		$max_view_thread = 10;
	}

	# ●スレッドごとに展開
	foreach my $thread_key ( keys %{$all_hash} ){

		my $thread_value = $all_hash->{$thread_key};
		my($thread,$res_line,$hit_res,$thread_report_line,$unique_data_for_one_thread);
		my($bbs_data,%reason_kind_for_thread);

			# ●レスごとに展開
			my @res = sort { $a <=> $b } keys %{$thread_value} ;
			foreach my $res_number ( @res ){

				my($i_unique,$hit_unique_for_res,$unique_line,%user_report_kind_for_res,$user_report_invalid_handle_flag,$original_register_access_data,$unique_data_for_one_res,$invalid_handle_utf8,$report_details);
				my $res_value = $thread_value->{$res_number};

					# ●ユニーク単位(報告単位)ごとに展開
					my @unique = sort { $b->{'data'}->{'report_time'} <=> $a->{'data'}->{'report_time'} } values %{$res_value} ;
					foreach my $unique ( @unique ){

						my($unique_line_buffer);

						# 使いやすい変数を定義
						$i_unique++;
						my $unique_data = $unique_data_for_one_res = $unique_data_for_one_thread = $unique->{'data'};

							# 表示しないレポートを判定
							if(go_to_next_line_for_report_judge($unique_data)){
								next;
							}

						$report_details .= "$unique_data->{'report_detail'}\n";
						$hit_all_unique++;

							# 最大表示数を超えている場合は処理を終える ( 全ての報告数などを数えるため、この位置で良い )
							if($hit_thread >= $max_view_thread){ next; }

							# ▼掲示板スレッドの場合
							if($use->{'content_type'} eq "bbs_thread"){

								# 元スレッドを取得 ( state ) => 負荷軽減のためこの位置で ( 対応済みの場合はスレッド情報を取得しない )
								($thread) = Mebius::BBS::thread_state($unique_data->{'targetB'},$unique_data->{'targetA'});

								# 掲示板データを取得
								($bbs_data) = Mebius::BBS::init_bbs_parmanent($thread->{'bbs_kind'});

								# 報告された筆名
								($invalid_handle_utf8) = $thread->{'res_data'}->{$res_number}->{'handle'} if($unique_data->{'report_handle_check'}); 
								$res_number ||= 0;
								$original_register_access_data = $thread->{'res_data'}->{$res_number};

							# ▼SNS日記の場合
							} elsif ($use->{'content_type'} eq "sns_diary"){
								($thread) = Mebius::SNS::Diary::thread_state($unique_data->{'targetA'},$unique_data->{'targetB'});
							} elsif($use->{'content_type'} eq "sns_comment_boad"){
								($thread) = Mebius::SNS::CommentBoad::log_file({ year => $unique_data->{'targetB'} },$unique_data->{'targetA'});
							}

							# 筆名に対する報告がある場合
							if($unique_data->{'report_handle_check'})	{
								$user_report_invalid_handle_flag = 1;
							}

						# 報告の表示
						($unique_line_buffer) .= view_unique_line_core($unique_data,{ hit_round => $hit_unique_for_res , invalid_handle => $invalid_handle_utf8 , original_register_access_data => $original_register_access_data });

					# レス毎に報告されている種類を覚えておく
					$user_report_kind_for_res{$unique_data->{'main_reason'}} = 1;

							# ▼スレッドへの報告の場合
							if($unique_data->{'report_type_res_or_thread'} eq "Thread"){

								my($report_reason) = Mebius::Reason::type_to_detail_for_thread($unique_data->{'report_reason_for_thread'});
								$thread_report_line .= qq(<h3 class="red">).e($report_reason).qq(</h3>);
								$thread_report_line .= qq($unique_line_buffer);
								$reason_kind_for_thread{$unique_data->{'report_reason_for_thread'}} = 1;

								next;

							# ▼レスへの報告の場合
							} else {

								$hit_unique_for_res++;
								$unique_line .= $unique_line_buffer;

							}

						# 不適切な違反報告を選ぶボックス
							if(Mebius::alocal_judge()){
								$unique_line .= qq(<strong>不適切な報告： </strong> ).(improper_report_select_box());
							}

					} # ユニーク部分閉じ

					# ▼参照元の【レス】
					if($hit_unique_for_res >= 1){

						my($thread_name_data);

						$hit_res++;
						$hit_all_res++;

						 # レス部分 全体の開始タグ
						$res_line .= qq(<div class="border-top margin padding">\n);

							# レスのコア部分
							if($thread->{'f'}){

								# スレッド名など
								$thread_name_data .= qq(<strong class="red">);
								my($sub_utf8,$bbs_title) = utf8_return($thread->{'sub'} || $thread->{'subject'},$bbs_data->{'title'});
								$thread_name_data .= e($bbs_title);
								$thread_name_data .= qq( &gt; ) . e($sub_utf8);
								$thread_name_data .= qq( &gt; ) .  e($res_number);
								$thread_name_data .= qq(</strong>);
								$res_line .= qq(<h3 class="center">$thread_name_data </h3>);
							}

						# ▼報告部分
						$res_line .= qq(<div class="float-left report_per_res" style="width:48%;">$unique_line</div>);	

							# オリジナル投稿の表示を定義
							# 掲示板スレッドのレス
							if($use->{'content_type'} eq "bbs_thread"){

								my $line;

								$res_line .= qq(<div class=" float-right float-width">);

									if(Mebius::Admin::admin_mode_judge()){
										($line) = Mebius::BBS::Admin::res_core({ ViewReport => 1 , report_detail => $report_details },$thread,$res_number); #, report_text => $unique_data->{'text'}
									} else {
										($line) = utf8(main::thread_res_core({ ViewReport => 1 },$thread->{'all_line'}->[$res_number+1]));
									}
								$res_line .= $line;
								$res_line .= qq(</div>);

							# SNSの日記
							} elsif ($use->{'content_type'} eq "sns_diary"){
								my($diary_res_line) = Mebius::SNS::Diary::view_res_core({ NoAds => 1 } , $thread->{'account'},$unique_data_for_one_res->{'targetB'},$thread->{'res_data'}->[$res_number]);
								$res_line .= $diary_res_line;
							}	elsif ($use->{'content_type'} eq "sns_comment_boad"){
								# SSSSSSSSSS
								#Mebius::SNS::CommentBoad::
								my($init_directory) = Mebius::BaseInitDirectory();
								require "${init_directory}auth_comment.pl";
#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($thread->{'res_data_per_res_number'} $unique_data_for_one_res->{'targetA'})); }
								my($comments) .= main::auth_view_comment_core({ } , $thread->{'res_data_per_res_number'}->{$unique_data_for_one_res->{'report_res_number'}});
								utf8($comments);
								$res_line .= $comments;
							}

						# 回りこみを解除
						$res_line .= qq(<div class="clear"></div>);


							# ▼削除ボタン
							if($use->{'content_type'} eq "bbs_thread" && Mebius::Admin::admin_mode_judge()){

								my $unique_number = "$thread->{'bbs_kind'}-$thread->{'number'}-$res_number";
								$res_line .= qq(<div class="right" style="margin:0% 0% 3% 0%;">);
								($res_line) .= Mebius::Reason::res_control_box_full_set({ unique_number => $unique_number , res_data => $thread->{'res_data'}->{$res_number} , user_report_kind => \%user_report_kind_for_res , user_report_invalid_handle_flag => $user_report_invalid_handle_flag });

								$res_line .= qq(<div class="right"><input type="submit" name="" value="Go" class="white"></div>);	
								$res_line .= qq(</div>);
							}

						 # レス部分 全体の閉じタグ
						$res_line .= qq(</div>\n);

					}
			}

			# ▼スレッド本体部分
			if($hit_res >= 1 || $thread_report_line){

				my($line);

				# スレッドのヒットカウンタ (この位置で良い)
				$hit_thread ++;

					# ▼スレッドへの報告がある場合
					if($thread_report_line){
						$line .= qq(<div class="report_per_thread">);
						$line .= $thread_report_line;
						$line .= qq(</div>);
						$hit_all_report_for_thread++;

					# ▼スレッドへの報告がない場合
					} else {
						my $id_for_javascript = "$use->{'content_type'}_thread_body_$thread->{'bbs_kind'}-$thread->{'number'}";
							if($use->{'content_type'} eq "bbs_thread" || $use->{'content_type'} eq "sns_diary"){
								$line .= qq(<div class="center"><a href="javascript:vswitch\(').e($id_for_javascript).qq('\);" class="fold">スレッドを表示する</a></div>);
							}
						$line .= qq(<div class="none" id=").e($id_for_javascript).qq(">);
					}

					# 管理部分 ( 掲示板のスレッド )
					my($subject_utf8) = utf8_return($thread->{'sub'} || $thread->{'subject'});
					if($use->{'content_type'} eq "bbs_thread"){
							if(Mebius::Admin::admin_mode_judge()){
								($line) .= Mebius::Admin::bbs_thread_admin_console({ ViewReportMode => 1 , reported_reasons => \%reason_kind_for_thread },$thread->{'bbs_kind'},$thread->{'number'});
							} else {
								$line .= qq(<h3><a href=").e($thread->{'url'}).qq(">).e($subject_utf8).qq(</a></h3>);
							}
					} elsif($use->{'content_type'} eq "sns_diary"){
						$line .= q(<h3><a href=").e($thread->{'url'}).q(">).e($subject_utf8).q(</a></h3>);
						($line) .= Mebius::SNS::Diary::view_zero_res({ },$unique_data_for_one_thread->{'targetA'},$thread);
					}

					# スレッドへの報告がない場合
					if(!$thread_report_line){ $line .= qq(</div>); }

					# レスへの報告がある場合
					if($hit_res >= 1){
						$line .= qq(<div>);
						$line .= qq(<div class="right">レスの報告数： <strong class="red" style="font-size:180%;">).e($hit_res).qq(</strong></div>);
						#$line .= qq(<div class="message-blue center">レスに対する報告</div>);
						$line .= qq($res_line);
						$line .= qq(</div>);
					}


				$return .= $self->around_thread($line);

			}

	}

$return = qq(<div class="right">報告数： <strong class="red" style="font-size:160%;">).e($hit_all_res || 0).q(レス</strong> / <strong class="red" style="font-size:160%;">).e($hit_all_report_for_thread || 0).q(スレッド</strong></div>).$return;


$return;

}

#-----------------------------------------------------------
# レポート内で、データ1行ごとに表示しないレポートの判定
#-----------------------------------------------------------
sub go_to_next_line_for_report_judge{

my($unique_data) = @_;
my($q) = Mebius::query_state();
my($kind_list_for_thread) = Mebius::Reason::kind_list_for_thread();
my($kind_list_for_res) = Mebius::Reason::kind_list_for_res();
my($flag);

	# 対応済みだけ表示させる場合
	if($q->param('view_type') eq "still_admin_check"){

			# 確認済みでも、管理者対応から一定時間が経過していれば表示しない
			if(time >= $unique_data->{'answer_time'} + 1*24*60*60){
					$flag = 1;
			}

	# 普通に表示する場合、対応済みのものは表示しない
	} elsif($unique_data->{'answer_time'}) {
		$flag = 1;
	}

	# ▼スレッドへの報告の場合
	if($unique_data->{'report_type_res_or_thread'} eq "Thread"){

			# 個人情報等の報告はユーザーに見せない
			if($kind_list_for_thread->{$unique_data->{'report_reason_for_thread'}}->{'ReportForAdminOnly'} && !Mebius::Admin::admin_mode_judge()){
				$flag = 1;
			}

	} else {
			# 個人情報等の報告はユーザーに見せない
			if($kind_list_for_res->{$unique_data->{'main_reason'}}->{'ReportForAdminOnly'} && !Mebius::Admin::admin_mode_judge()){
				$flag = 1;
			}
	}

$flag;

}

#-----------------------------------------------------------
# レポート部分の表示を定義
#-----------------------------------------------------------
sub view_unique_line_core{

my $data = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($line);


	# 枠
	if($use->{'hit_round'} >= 1){
		$line .= qq(<div class="border-top" style="border-color:#f00;padding:1em 0em;">\n);
	} else {
		$line .= qq(<div style="padding:1em 0em;">\n);
	}

	# レスへの依頼理由
	if($data->{'main_reason'}){
		my($reason_text_for_res) = Mebius::Reason::type_to_detail_for_res($data->{'main_reason'});
		$line .= qq(<h4>).e($reason_text_for_res).qq(</h4>);
	}

# レポート詳細 ( 本文 )
my($report_detail) = $data->{'report_detail'};
($report_detail) = e($report_detail);
($report_detail) = Mebius::users_tag_to_html($report_detail);

	# 詳細本文の 自動リンク
	if(Mebius::Admin::admin_mode_judge()){
		($report_detail) = Mebius::Admin::auto_link($report_detail);
	} else {
		($report_detail) = Mebius::auto_link($report_detail);
	}

$line .= $report_detail.qq(\n);

	# 参照スレッド
	if($data->{'report_referer_url'}){
		$line .= qq(<div class="margin">);
		($line) .= qq(<strong>参照：</strong> );

		my($referer_thread) = Mebius::BBS::thread_url_to_thread_data($data->{'report_referer_url'});
			if($referer_thread && Mebius::Admin::admin_mode_judge()){
				my $id = e("$referer_thread->{'bbs_kind'}-$referer_thread->{'number'}");
				$line .= qq( <a href="javascript:vswitch\(').e($id).qq('\);" class="fold">).e(utf8_return($referer_thread->{'sub'})).qq(</a> レス).e($referer_thread->{'res'});
				$line .= qq(<div style="background:#fff;border:solid 5px #0b0;" class="margin none" id=").e($id).qq(">);
				($line) .= Mebius::Admin::bbs_thread_admin_console({ ViewReportMode => 1 , NotViewConsole => 1 },$referer_thread->{'bbs_kind'},$referer_thread->{'number'});
				$line .= qq(</div>);
			} else {
				($line) .= Mebius::auto_link($data->{'report_referer_url'});
			}
		$line .= qq(</div>);
	}


	# ▼オプション情報
	{

		$line .= qq(<div class="right">);

			# 筆名に対する報告がある場合
			if($use->{'invalid_handle'}) {
				$line .= qq(<span class="red">※筆名に違反があると報告されています</span>\n);
			}

		$line .= qq(</div>);

	}

# レポート 送信者の情報
$line .= qq(<div class="right">\n);
#my($handle2_utf8) = utf8($data->{'handle'});
($line) .= e($data->{'handle'}).qq(\n);
$line .= Mebius::second_to_howlong({ ColorView => 1 , HowBefore => 1 , TopUnit => 1 } , time - $data->{'report_time'}).qq(\n);
$line .= qq([).e($data->{'unique_number'}).qq(]);

	# 管理用 ユーザーコントロールリンク
	if(Mebius::Admin::admin_mode_judge()){

		# スレッドのレスデータハッシュ
		#my $res_line_data = $thread->{'res_data'}->{$res_number};

		# 管理用リンクを生成
		my($user_control_link) = Mebius::Admin::user_control_link_multi({ host => $data->{'host'} , account => $data->{'account'} , cookie => $data->{'cnumber'} , user_agent => $data->{'user_agent'} });
		$line .= qq(<div>$user_control_link->{'host'} ┃ $user_control_link->{'isp'} ┃ $user_control_link->{'account'} ┃ $user_control_link->{'cookie'} ┃ $user_control_link->{'user_agent'}</div>);

	}


		# 自分の報告かどうかをチェックする
	if(Mebius->common_admin_judge()){
		($line) .= the_same_person_check_and_return_text($data,$use->{'original_register_access_data'}||$use->{'access_data'});

	}

$line .= qq(</div>\n);
$line .= qq(</div>\n);


$line;

}

#-----------------------------------------------------------
# 報告が同一人物のものかどうかを判定して、テキストを返す
#-----------------------------------------------------------
sub the_same_person_check_and_return_text{

my($reporter,$reser) = @_; #(報告者,レス投稿者) = @_;
my($self);

my($self_checked_text) = Mebius::same_values_check_and_foreach_text({
	"アカウント" => [$reporter->{'account'},$reser->{'account'}] , 
	"Cookie" => [$reporter->{'cnumber'},$reser->{'cnumber'}||$reser->{'cookie_char'}] , 
	"ホスト" => [$reporter->{'host'},$reser->{'host'}] ,
	"IPアドレス" => [$reporter->{'addr'},$reser->{'addr'}] ,
	"個体識別番号" => [$reporter->{'mobile_uid'},$reser->{'mobile_uid'}||$reser->{'user_agent'}]
}
);

	if($self_checked_text){
		$self .= qq(<div style="background:#9f9;" class="margin">元の投稿者と <strong class="red">$self_checked_text</strong> が一致しています。</div>);
	}


$self;

}

#-----------------------------------------------------------
# レポート閲覧
#-----------------------------------------------------------
sub report_view{

my($print);
my($main_table_name) = main_table_name() || die;
my(%all_hash_bbs_thread,$report_bbs_thread,$report_sns_diary);
my($server_domain) = Mebius::server_domain();
my $question_view = new Mebius::Question::View;
my $saying = new Mebius::Saying;
my $video = new Mebius::Video;
my $tags = new Mebius::Tags;
my $html = new Mebius::HTML;

	if(!Mebius::Admin::admin_mode_judge()){
		main::error("管理者でないと閲覧出来ません。");
	}

my($report_bbs_thread) = report_view_core({ content_type => "bbs_thread" });
my($report_sns_diary) = report_view_core({ content_type => "sns_diary" });
my($report_sns_comment_boad) = report_view_core({ content_type => "sns_comment_boad" });


$print .= qq(<h1>違反報告</h1>);

$print .= report_view_switch_link();

$print .= qq(<div>);
($print) .= Mebius::domain_links();
$print .= qq(</div>);

# 掲示板への報告
$print .= qq(<form action="" method="POST">);
$print .= qq(<input type="hidden" name="mode" value="report_control">);

# 見出し
$print .= qq(<h2>掲示板</h2>);
	if($report_bbs_thread){
		$print .= qq($report_bbs_thread);
	} else {
		$print .= qq(報告が存在しないか、全て確認済みです。);
	}
$print .= qq(<div class="right"><input type="submit" value="Go" class="white"></div>);

$print .= qq(<h2>SNS日記</h2>);
	if($report_sns_diary){
		$print .= qq($report_sns_diary);
	} else {
		$print .= qq(報告が存在しないか、全て確認済みです。);
	}
$print .= qq(<div class="right"><input type="submit" value="Go" class="white"></div>);

$print .= qq(<h2>SNS伝言板</h2>);
	if($report_sns_comment_boad){
		$print .= qq($report_sns_comment_boad);
	} else {
		$print .= qq(報告が存在しないか、全て確認済みです。);
	}
$print .= qq(<div class="right"><input type="submit" value="Go" class="white"></div>);

$print .= $question_view->report_line();

$print .= qq(<div class="right"><input type="submit" value="Go" class="white"></div>);

#$print .= qq(<h2>名言処</h2>);
#$print .= $saying->report_line();

$print .= $video->report_line();

$print .= $html->tag("h2",$tags->init()->{'title'});
$print .= $tags->report_line();

$print .= qq(<div class="right"><input type="submit" value="Go" class="white"></div>);


$print .= qq(</form>);

# 掲示板への報告
my($my_admin) = Mebius::my_admin();
	if($my_admin->{'master_flag'}){
		$print .= qq(<h2>特殊な操作</h2>);
		$print .= qq(<form action="" method="POST" class="right" style="line-height:2.0;">);
		$print .= qq(<input type="hidden" name="mode" value="report_control">);
		$print .= qq(<div><label><input type="radio" name="type" value=""><span>何もしない</span></label></div>);
		
		$print .= qq(<div><label><input type="radio" name="type" value="no_reaction_to_all_report"><span>残り全てのレポートを確認済み(未対応)にする <span class="alert">※対応が必要な報告がひとつでも残っている場合は、実行しないでください。</span></span></label></div>);
		$print .= qq(<div><label><input type="radio" name="type" value="undo_recently_answer"><span>最近対応したレポートを元に戻す</span></label></div>);

		$print .= qq(<input type="submit" value="特殊な操作を実行する" style="border:solid 1px #000;background:#fdd;">);
		$print .= qq(</form>);
	}

# CSS
my $inline_css .= qq(.report_per_res{background:#ffc;border:solid 1px #f00;margin-bottom:1em;padding:0.5em 1.0em;});
$inline_css .= qq(.report_per_thread{background:#fee;border:solid 1px #f00;margin:1em 0em;padding:0.5em 1.0em;});
$inline_css .= qq(.date{text-align:right;margin-bottom:1em;});
#$inline_css .= qq(h2{padding:0.5em;background:#ff9;border:solid 1px #f00;});
$inline_css .= qq(h2{font-size:200%;});


Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , RobotsNoIndexFollow => 1 , Title => "報告の一覧" , BCL => ["違反報告"] , source => "utf8" , inline_css => $inline_css },$print);

exit;

}


#-----------------------------------------------------------
# フォームで囲む ( 携帯版と共通 )
#-----------------------------------------------------------
sub around_report_form{

my $res_area = shift;
my $select_name = shift;
my $use = shift;

my $operate = new Mebius::Operate;

	if(Mebius::Report::report_mode_judge_for_res()){
		utf8($res_area);
		my $relay_use = $operate->overwrite_hash($use,{ Res => 1 , RelayInputHidden => 1 });
		($res_area) = shift_jis(Mebius::Report::report_mode_around_form($res_area,$select_name,$relay_use));
	} elsif(Mebius::Report::report_mode_judge_for_thread()){
		utf8($res_area);
		my $relay_use = $operate->overwrite_hash($use,{ Thread => 1 , RelayInputHidden => 1 });
		($res_area) = shift_jis(Mebius::Report::report_mode_around_form($res_area,$select_name,$relay_use));
	} else {
		0;
	}

$res_area;

}

#-----------------------------------------------------------
# スレッドを囲む
#-----------------------------------------------------------
sub around_thread{

my $self = shift;
my $line = shift;

# HTML 囲み部分開始
$line = qq(<div style="border:ridge 3px #777;margin-bottom:5em;padding:0em 1em;">$line</div>);

$line;

}



#-----------------------------------------------------------
# 元のコンテンツとレポートを左右に配置する
#-----------------------------------------------------------
sub place_by_the_side{

my $self = shift;
my $original_view = shift;
my $reports = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $html = new Mebius::HTML;
my($print);
my $data = $use->{'access_data'} || {};

#my $url = $self->data_to_url($data);
#$print .= $html->tag("h3",$data->{'title'},{ href => $url });

$print .= $html->tag("h3",$data->{'title'});

$print .= qq(<div class=" float-right float-width">);

$print .= $original_view;
$print .= qq(</div>);

$print .= $self->report_data_array_to_html($reports,$use);

$print .= qq(<div class="clear"></div>);

$print;

}



#-----------------------------------------------------------
# 復数のレポートデータを整形する
#-----------------------------------------------------------
sub report_data_array_to_html{

my $self = shift;
my $data = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($print,$hit,$class);
my $html = new Mebius::HTML;

	foreach my $report ( @{$data} ){
		my $relay_use = Mebius::Operate->overwrite_hash($use,{ hit_round => $hit });
		$print .= view_unique_line_core($report,$relay_use);
		$hit++;
	}

	if(!$print){
		$print = "報告はありません。";
	}

	# ▼報告部分
	if($print){

			if($use->{'Thread'}){
				$class .= " report_per_thread";
			} elsif($use->{'Res'}) {
				$class .= " report_per_res";
			} else {
				$class .= " report_per_res";
			}
		$print = $html->div($print,{ class => "float-left float-width $class" ,  NotEscape => 1 });
	}

$print;

}

1;
