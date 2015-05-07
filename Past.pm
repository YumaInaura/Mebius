
use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# 過去ログ表示ページ
#-----------------------------------------------------------
sub PastIndexView{

# 宣言
my($type) = @_;
my($plustype_all,%recentry_index,%year_index,%all_index,$recentry_line);
my($allindex_line,$yearindex_line,$h1_text,$plustype_search,$pagelinks_line,$monthf,$yearf,$start_page,$search_keyword);
my($allbbs_index_line,$all_line,$search_form,$navigation_line);

# CSS定義
$main::css_text .= qq(
table.past_index{border-style:none;width:100%;}
form.pastindex_search{padding:0.5em;margin:1em 0em;background:#ddd;}
h1{font-size:160%;}
h2{font-size:120%;}
td.past,th.past{border-style:none;padding:0.5em 0.2em;}
div.pagelinks_pastindex{padding:0.3em 0.75em;border:1px solid #333;margin:1em 0em;}
div.past_menu{padding:0.5em 1em;background:#fee;}
);

	# 管理モード定義
	if($type =~ /Admin-mode/){
		$plustype_all .= qq( Admin-mode);
	}

	# ページ指定エラー
	if($main::submode_num > 5){
		main::error("このモードは存在しません。");
	}

	# 基本タイトル定義
	if($type =~ /Select-BBS-view/){
		$main::head_link3 = qq(&gt; <a href="past.html">過去ログ</a>);
	}

	# 処理タイプを定義

	# 全掲示板の大メニュー
	if($type =~ /All-BBS-view/){
		$main::sub_title = qq(過去ログ | メビウスリング - $main::server_domain );
		$main::head_link4 = qq(&gt; 過去ログ);
		$h1_text = qq(過去ログ - $main::server_domain );
	}

	# 掲示板ごとのメニュ
	elsif($type =~ /Select-BBS-view/){

			# 過去ログ検索
			if($main::ch{'word'}){
				$type .= qq( Search-view);
				$plustype_all .= qq( Search-index);
				$main::head_link4 = qq(&gt; ”$main::in{'word'}”の検索結果);
				$main::sub_title = qq(”$main::in{'word'}”の検索結果 | 過去ログ | $main::head_title);
				$h1_text = qq(過去ログ);
					if($main::in{'handle'}){ $plustype_search .= qq( Handle-search); }
					if($main::in{'subject'}){ $plustype_search .= qq( Subject-search); }
					if($main::in{'strict'}){ $plustype_search .= qq( Strict-search); }
					$yearf = $main::in{'target'};
					$monthf = $main::in{'month'};
					$start_page = $main::in{'page'};
					$search_keyword = $main::in{'word'};
					if($yearf && !$monthf || $yearf eq "all"){ $type .= qq( Year-view); }
					elsif($yearf && $monthf){ $type .= qq( Month-view); }
					elsif($yearf eq "recentry"){ $type .= qq( Recentry-view); }
					else{ main::error("検索タイプを指定してください。"); }
			}
			# 基本メニュー
			elsif($main::submode2 eq ""){
				$type .= qq( All-view Toppage-view);
				$plustype_all .= qq( Normal-view);
				$main::sub_title = qq(過去ログ | $main::head_title);
				$main::head_link3 = qq(&gt; 過去ログ);
				$h1_text = qq($main::title - 過去ログ);
			}
			# 年別に表示
			elsif($main::submode2 eq "year" && $main::submode3 =~ /^(\d+)$/ && $main::submode4 =~ /^(all)$/ && $main::submode5 =~ /^(|\d+)$/){
				$type .= qq( Year-view);
				$plustype_all .= qq( Normal-view);
				$yearf = $main::submode3;
				$monthf = $main::submode4;
				$start_page = $main::submode5;
				$main::sub_title = qq($yearf年 過去ログ | $main::head_title);
				$main::head_link4 = qq(&gt; $yearf年);
				$h1_text = qq($main::title - $yearf年の過去ログ);
			}
			# 月別に表示
			elsif($main::submode2 eq "year" && $main::submode3 =~ /^(\d+)$/ && $main::submode4 =~ /^(\d{2})$/ && $main::submode5 =~ /^(|\d+)$/){
				$type .= qq( Month-view);
				$plustype_all .= qq( Normal-view);
				$yearf = $main::submode3;
				$monthf = $main::submode4;
				$start_page = $main::submode5;
				$main::sub_title = qq($yearf年$monthf月 過去ログ | $main::head_title);
				$main::head_link4 = qq(&gt; <a href="past-year-$yearf-all.html">$yearf年</a>);
				$main::head_link5 = qq(&gt; $monthf月);
				$h1_text = qq($main::title - $yearf年$monthf月の過去ログ);

			}

			else{
				main::error("表\示モードを指定してください。");
			}

	}


	# タイトル調整
	if($start_page){
		$main::sub_title = qq($main::sub_title | $start_page );
	}

	# モバイル型アクセスの場合
	if($main::device_type eq "mobile"){
		main::kget_items();
		$plustype_all .= qq( Mobile-view);
	}
	# デスクトップ型アクセスの場合
	else{
		$plustype_all .= qq( Desktop-view);
	}


	# 全掲示板のリストを取得する
	if($type =~ /All-BBS-view/){
		my(%all_bbs_index) = Mebius::BBS::PastIndexAllBBS("Get-index Addtion-Hx");
		$allbbs_index_line = $all_bbs_index{'index_line'};
	}

	# 全過去ログのメニューを取得する
	(%all_index) = Mebius::BBS::PastIndexAll("Get-index Months-link $plustype_all",$main::realmoto,$yearf,$monthf);

		# 調整更新
		# 2012/2/23 (木)
		if($all_index{'please_fix_renew_flag'}){
			Mebius::BBS::PastIndexAll("Renew",$main::realmoto,$yearf,$monthf);
		}

		if($type =~ /All-view|Year-view|Month-view/ && $all_index{'index_line'}){
			$allindex_line .= qq(<div class="past_menu">);
				#if($type =~ /Toppage-view/){ $allindex_line .= qq(<h2$main::kstyle_h2>過去ログ一覧</h2>\n); }
				#else{ $allindex_line .= qq(<h2$main::kstyle_h2><a href="past.html">過去ログ一覧</a></h2>\n); }
			$allindex_line .= qq(<div class="line-height">$all_index{'index_line'}</div>\n);
			$allindex_line .= qq(</div>);
		}


	# 年別のメニューを取得する
	if($type =~ /Year-view/){

		# 開くファイルの再定義
		my($yearf_select);
			if($yearf eq "all"){ $yearf_select = $all_index{'all_years'}; }
			else{ $yearf_select = $yearf; }

		(%year_index) = Mebius::BBS::PastIndex("Year-file Get-index Addtion-Hx $plustype_all",$main::realmoto,$yearf_select,$monthf,undef,$start_page,$search_keyword);
			if($year_index{'index_line'}){
				#$yearindex_line .= qq(<h2$main::kstyle_h2>$yearf年の過去ログ ( $year_index{'thread_num'}記事 )</h2>\n);
				$yearindex_line .= qq($year_index{'index_line'});
				$pagelinks_line = qq($year_index{'pagelinks_line'});
			}
	}

	# ●月別のメニューを取得する
	if($type =~ /Month-view/){
		(%year_index) = Mebius::BBS::PastIndex("Year-file Get-index Month-view Addtion-Hx $plustype_all",$main::realmoto,$yearf,$monthf,undef,$start_page,$search_keyword);
			if($year_index{'index_line'}){
				#$yearindex_line .= qq(<h2$main::kstyle_h2>$yearf年$monthf月の過去ログ ( $year_index{"thread_num_month$monthf"}記事 )</h2>\n);
				$yearindex_line .= qq($year_index{'index_line'});
				$pagelinks_line = qq($year_index{'pagelinks_line'});
			}
	}

	# 最近の過去ログを取得を取得する
	#if($type =~ /All-view/){
	#	(%recentry_index) = Mebius::BBS::PastIndex("Recentry-file Get-index Addtion-Hx $plustype_all",$main::realmoto,undef,undef,undef,undef,$search_keyword);
	#		if($recentry_index{'index_line'}){
	#			#$recentry_line .= qq(<h2$main::kstyle_h2>最近の過去ログ</h2>\n);
	#			$recentry_line .= qq($recentry_index{'index_line'});
	#		}
	#}

	# ●検索フォームを取得
	if($type =~ /Select-BBS-view/){
		($search_form) = Mebius::BBS::PastIndexSearchForm("$plustype_all",%all_index);
	}

# ヘッダ
main::header("Body-print");

	# ナビゲーションリンクを定義
	if(!$main::kflag){
		$navigation_line .= qq(<div class="word-spacing">);
		$navigation_line .= qq(<a href="$main::home">ＴＯＰページ</a>\n);

			if($type =~ /All-BBS-view/){ $navigation_line .= qq(全掲示板の過去ログ\n); }
			else{ $navigation_line .= qq(<a href="${main::main_url}past.html">全掲示板の過去ログ</a>\n);  }

			if($type !~ /All-BBS-view/){
					if($type =~ /All-view/){ $navigation_line .= qq($main::titleの過去ログ\n); }
					else{ $navigation_line .= qq(<a href="./past.html">$main::titleの過去ログ</a>\n); }
			}

		$navigation_line .= qq(<a href="./">$main::title</a>\n);
		$navigation_line .= qq(</div>);
	}

# 見出し表示
$all_line .= qq(<h1$main::kstyle_h1>$h1_text</h1>\n);
$all_line .= qq(
$navigation_line
$search_form
);

	# すべてのラインを定義
	if($type !~ /Search-view/){
		$all_line .= qq($allindex_line);
	}

$all_line .= qq(
<div id="LIST">
$yearindex_line
$recentry_line
$pagelinks_line
$allbbs_index_line
</div>
);

	# すべてのラインを定義
	if($type =~ /Search-view/){
		$all_line .= qq($allindex_line);
	}

# 管理用のURL変換
if($type =~ /Admin-mode/){ ($all_line) = Mebius::Fixurl("Normal-to-admin Multi-fix",$all_line); }

# HTMLを表示
print qq($all_line);

# フッタ
main::footer("Body-print");

exit;

}

#-----------------------------------------------------------
# 検索ボックス
#-----------------------------------------------------------
sub PastIndexSearchForm{

# 宣言
my($type,%all_index) = @_;
my($form,$checked_subject,$checked_handle,$checked_strict);
my($checked_target_recentry,$checked_target_all);

	# オートフォーカスを当てる
	if(!exists $main::in{'word'}){
		$main::body_javascript = qq( onload="document.pastindex_search.word.focus()");
	}

	# チェック
	if($main::in{'subject'}){ $checked_subject = $main::parts{'checked'}; }
	if($main::in{'handle'}){ $checked_handle = $main::parts{'checked'}; }
	if($main::in{'strict'}){ $checked_strict = $main::parts{'checked'}; }
	if($main::in{'target'} eq "all"){ $checked_target_all = $main::parts{'checked'}; }
	elsif($main::in{'target'} eq "recentry" || $main::in{'target'} eq ""){ $checked_target_recentry = $main::parts{'checked'}; }

	# 区切り線
	if($type =~ /Mobile-view/){
		$form .= qq(<hr>\n);
	}

# フォーム定義
$form .= qq(<form method="get" action="./$main::script" name="pastindex_search" class="pastindex_search">\n);
$form .= qq(<div class="size90">\n);
$form .= qq(<input type="hidden" name="mode" value="past"$main::xclose>\n);
$form .= qq(<input type="text" name="word" value="$main::in{'word'}" size="13" class="normal"$main::xclose>\n);


	# 送信ボタン
	if($type =~ /Desktop-view/){
		$form .= qq(<input type="submit" value="過去ログから検索する" class="isubmit"$main::xclose>\n);
	}
	elsif($type =~ /Mobile-view/){
		$form .= qq(<input type="submit" value="検索"$main::xclose>\n);
	}


# 絞り込み
	if($type =~ /Desktop-view/){ $form .= qq(　絞り込み： ); }
	elsif($type =~ /Mobile-view/){ $form .= qq(\n<br$main::xclose>); }

$form .= qq(<input type="checkbox" name="subject" value="1" id="past_search_subject"$checked_subject$main::xclose>);
$form .= qq(<label for="past_search_subject">題名</label>\n);
$form .= qq(<input type="checkbox" name="handle" value="1" id="past_search_handle"$checked_handle$main::xclose>);
$form .= qq(<label for="past_search_handle">作成者</label>\n);
$form .= qq(<input type="checkbox" name="strict" value="1" id="past_search_strict"$checked_strict$main::xclose>);
$form .= qq(<label for="past_search_strict">曖昧さをオフ</label>\n);

# 検索対象となるファイル
	if($type =~ /Desktop-view/){ $form .= qq(\n　|　検索対象：); }
	elsif($type =~ /Mobile-view/){ $form .= qq(\n<br$main::xclose>); }

	$form .= qq(<input type="radio" name="target" value="recentry" id="past_target_recentry"$checked_target_recentry$main::xclose>);
$form .= qq(<label for="past_target_recentry">最近</label>\n);
$form .= qq($all_index{'input_radio'}\n);
$form .= qq(<input type="radio" name="target" value="all" id="past_target_all"$checked_target_all$main::xclose>);
$form .= qq(<label for="past_target_all">全て</label>\n);

$form .= qq(</div>\n);
$form .= qq(</form>\n);

	# 区切り線
	if($type =~ /Mobile-view/){
		$form .= qq(<hr>\n);
	}

return($form);

}

#-----------------------------------------------------------
# 溢れた各記事を過去ログ化
#-----------------------------------------------------------
sub BePastThread{

# 局所化
my($type,$realmoto,$thread_number) = @_;
my(%renew,$yearf,$monthf,$plustype_bepast_multi);

# 汚染チェック
if($realmoto =~ /\W/){ return(); }
if($thread_number =~ /\D/){ return(); }

# キーを設定
$renew{'key'} = 3;
$renew{'Concept_plus'} = " Be-pasted";

# 記事を確認
my($thread) = Mebius::BBS::thread({ TypeGetHashDetail => 1 , ReturnReference => 1 },$realmoto,$thread_number);

	# 記事が存在しない場合はリターン
	if(!$thread->{'f'}){ return(); }

	# 削除された記事は過去ログ化しない
	if($thread->{'deleted_flag'}){ return(); }

	# 旧過去ログ記事を、新過去ログに変換する場合
	if($type =~ /Old-thread/){

			# 既にいちど過去ログ化している場合
			if($thread->{'bepast_time'} =~ /^(\d{9,})$/){ $renew{'bepast_time'} = $thread->{'bepast_time'}; }

			# 過去ログ化日付がない場合は、ファイルの最終更新日を使う
			else{ $renew{'bepast_time'} = $thread->{'stat_last_modified'}; }

			#if($main::alocal_mode){ $renew{'bepast_time'} = $main::time - 3*365*24*60*60 }
		$plustype_bepast_multi .= qq( Old-thread);
	}
	# 普通に新規投稿から過去ログ化する場合
	else{
		$renew{'bepast_time'} = time;
	}

	# 過去ログ化の日付が指定できなかった場合、リターン
	if(!$renew{'bepast_time'}){ return(); }

	# 過去ログ化日付から年月を取得
	my(%bepast_time) = Mebius::Getdate("Get-hash",$renew{'bepast_time'});

# 記事を更新
my($renewed_thread) = Mebius::BBS::thread({ TypeRenew => 1 , ReturnReference => 1 , SelectRenew => \%renew },$realmoto,$thread_number);

# 過去ログファイル３種類を更新
Mebius::BBS::PastIndexMulti("Renew New-line $plustype_bepast_multi",$realmoto,$bepast_time{'yearf'},$bepast_time{'monthf'},$renewed_thread);

}

#-----------------------------------------------------------
# 過去ログインデックスを操作 ( 全般 )
#-----------------------------------------------------------
sub PastIndexMulti{

# 宣言
my($type,$realmoto,$yearf,$monthf,$thread) = @_;
my($plustype);

# 引き渡す処理タイプを定義
if($type =~ /Renew/){ $plustype .= qq( Renew); }
if($type =~ /New-line/){ $plustype .= qq( New-line); }
if($type =~ /Delete-thread/){ $plustype .= qq( Delete-thread); }
if($type =~ /Repair-thread/){ $plustype .= qq( Repair-thread); }
if($type =~ /Admin-mode/){ $plustype .= qq( Admin-mode); }
if($type =~ /Old-thread/){ $plustype .= qq( Old-thread); }

# 新過去ログのインデックスを更新 ( 最近のログ )
Mebius::BBS::PastIndex("Recentry-file $plustype",$realmoto,undef,undef,$thread);

# 新過去ログのインデックスを更新 ( 年別のログ )
Mebius::BBS::PastIndex("Year-file $plustype",$realmoto,$yearf,$monthf,$thread);

}

use Mebius::PostData;

#-----------------------------------------------------------
# 最近 / 年別の過去ログ
#-----------------------------------------------------------
sub PastIndex{

# 宣言
my($type,$realmoto,$yearf,$monthf) = @_;
my(undef,undef,undef,undef,$maxview_index,$start_page,$search_keyword) = @_ if($type =~ /Get-index/);
my(undef,undef,undef,undef,$thread) = @_ if($type =~ /(New-line|Delete-thread|Repair-thread)/);
my($i,$file,$maxline_index,%data,$maxview_index_strong);
my($index_line,@index_line,$pagelinks_line,$max_pagelinks,$i_reverse,@files,$file_split);
my($line_num_all,$pagelinks_number,$search_keyword_encoded,%postbuf,%data);

	# 汚染チェック１
	if($realmoto =~ /^$|\W/){ return(); }

	# 汚染チェック２
	if($type =~ /Renew/){
			if($thread->{'number'} =~ /^$|\D/){ return(); }
	}

	# 新規登録時のチェック
	if($type =~ /New-line/){
			if(!$thread){ return(); }
			if(!$thread->{'bepast_time'}){ return(); }
	}

	# 年別ファイルん調整
	if($type =~ /Year-file/){
			if($yearf =~ /^$|[^\w,]/){ return(); }
			if($type =~ /New-line/ && $monthf =~ /^$|\D/){ return(); }

	}

	# 最近のファイル調整
	if($type =~ /Recentry-file/){
			if($type =~ /Get-index/ && !$maxview_index){
					if($type =~ /Desktop-view/){ $maxview_index = 10; }
					elsif($type =~ /Mobile-view/){ $maxview_index = 5; }
			}
	}


	# 検索設定
	if($type =~ /Search-index/){

		# キーワードをエンコード
		($search_keyword_encoded) = Mebius::Encode(undef,$search_keyword);

		# ポストバッファを削除して定義
		(%postbuf) = Mebius::PostBuf("Delete-key",$main::postbuf,"page","moto");

			# 検索オプションが指定されていない場合、基本値を設定
			if($type !~ /(Subject-search|Handle-search)/){
				$type .= qq( Subject-search); 
				$type .= qq( Handle-search); 
			}
	}

	# 表示最大数 / ページめくり単位を定義
	if($type =~ /Get-index/ && !$maxview_index){
			if($type =~ /Desktop-view/){ $maxview_index = 100; }
			elsif($type =~ /Mobile-view/){ $maxview_index = 20; }
	}


	# ページリンクを、それぞれ左右に何個まで表示するか
	if($type =~ /Desktop-view/){ $max_pagelinks = 9; }
	elsif($type =~ /Mobile-view/){ $max_pagelinks = 9; }


# ディレクトリ定義
my $directory1 = "${main::int_dir}_bbs_index/";
my $directory2 = "${directory1}_${realmoto}_index/";

	# ファイル定義
	if($type =~ /Year-file/){
		@files = split(/,/,$yearf);
		#if($main::alocal_mode){ @files = ("2010","2011","2012"); }
	}
	elsif($type =~ /Recentry-file/){
		$maxline_index = 5000;
		$maxview_index_strong = 50;
		@files = ("recentry");
	}

	# 処理最大数
	if(!$maxview_index_strong){ $maxview_index_strong = 30000; }
	if(!$maxline_index){ $maxline_index = 30000; }

	# ●全ファイルを展開
	foreach $file_split (@files){

		# 局所化
		my($file,@renew_index,$past_index_handler,%months,$thread_num);

		# ファイル定義
		if($file_split =~ /^(\w+)$/){ $file = "${directory2}${realmoto}_${file_split}_past.log"; } else { next; }

		# ファイルを開く
		open($past_index_handler,"<",$file);

			# ファイルロック
			if($type =~ /Renew/){ flock($past_index_handler,1); }

		# トップデータを分解
		chomp(my $top1 = <$past_index_handler>);
		($data{'key'},$data{'thread_num'},$data{'line_num'},$data{'months'}) = split(/<>/,$top1);

		# 複数展開用の調整処理
		$line_num_all += $data{'line_num'};

			# ハッシュだけ返す場合
			if($type =~ /Get-hash-only/){
				close($past_index_handler);
				return(%data);
			}


		# ラウンドカウンタを初期定義
		my $i_reverse1 = $data{'line_num'} + 1;

				# ファイルを展開する
				while(<$past_index_handler>){

					# 局所化
					my($hit,$i_search,$keyword_split,$hit_point2);

					# 行を分解
					chomp;
					my($key2,$monthf2,$subject2,$posthandle2,$resnum2,$thread_number2,$bepasttime2,$posttime2) = split(/<>/);

						# 月別表示の場合 ( インデックス取得 )
						if($type =~ /Get-index/){
								if($type =~ /Month-view/ && $monthf2 ne $monthf){ next; }
						}

					# ラウンドカウンタ
					$i++;
					$i_reverse1--;

						# 処理最大行数に達した場合、強制終了 ( 高負荷を防ぐ予備処理 )
						if($i > $maxline_index && $maxline_index){ last; }

						# 表示最大行数 ( 強制 ) に達した場合、強制終了 ( 高負荷を防ぐ予備処理 )
						if($i > $maxview_index_strong && $maxview_index_strong){ last; }

						# ●削除用
						if($type =~ /Delete-thread/){
								if($thread_number2 eq $thread->{'number'} && $key2 !~ /Deleted/){
									$key2 .= qq( Deleted);
								}
						}

						# ●復活用
						elsif($type =~ /Repair-thread/){
								if($thread_number2 eq $thread->{'number'} && $key2 =~ /Deleted/){
									$key2 =~ s/(\s?)Deleted//g;
								}
						}

						# このファイルの記事数 ( 削除された記事はのぞく )
						if($key2 !~ /Deleted/){
							# 全記事数
							$thread_num++;
							# 月別記事数
							$months{"$monthf2"}++;
						}

						# ●インデックス取得用
						if($type =~ /Get-index/){

								# ▼キーワード検索する場合
								if($type =~ /Search-index/){

										# キーワードをスペース区切りで展開
										foreach $keyword_split (split(/ |　/,$search_keyword)){

											# 局所化
											my($plustype_similar);

											# ラウンドカウンタ
											$i_search++;

												# 題名を検索
												if($type =~ /Subject-search/){
														if($type =~ /Strict-search/){ $plustype_similar .= qq( Strict-search); }
													my($hit_buffer) = Mebius::Text::SimilarJudge("Cut-keyword $plustype_similar",$subject2,$keyword_split);
														if($hit_buffer){ $hit++; }
													$hit_point2 += $hit_buffer;
												}

												# 作成者の筆名を検索
												if($type =~ /Handle-search/){
													my($hit_buffer) = Mebius::Text::SimilarJudge("Strict-search",$posthandle2,$keyword_split);
														if($hit_buffer){ $hit++; }
													$hit_point2 += $hit_buffer;
												}
										}

										# ヒットしなければ次回処理へ ( AND検索 )
										if($hit < $i_search){ next; }

								}
							
								# インデックス配列を追加
					push(@index_line,"$hit_point2<>$i_reverse1<>$key2<>$monthf2<>$subject2<>$posthandle2<>$resnum2<>$thread_number2<>$bepasttime2<>$posttime2<>\n");

						}

						# ●ファイル更新用
						if($type =~ /Renew/){

								# 同じ記事は重複して追加しない
								if($type =~ /New-line/){
										if($thread->{'number'} eq $thread_number2){ next; }
								}
								
							# 行を追加
							push(@renew_index,"$key2<>$monthf2<>$subject2<>$posthandle2<>$resnum2<>$thread_number2<>$bepasttime2<>$posttime2<>\n");

						}

				}

		# ファイルを閉じる
		close($past_index_handler);

			# ●ファイルを更新する
			if($type =~ /Renew/){

					# 局所化
					my(@months,$newkey);

					# ▼新しい行を追加する場合
					if($type =~ /New-line/){

						# 記事数カウンタを増やす
						$thread_num++;
						$months{$monthf}++;

						# ラウンドカウンタを増やす
						$i++;

						# キー指定
						if($type =~ /Old-thread/){
							$newkey .= qq( Old-thread);
						}

					# 新しく追加する行
					unshift(@renew_index,"$newkey<>$monthf<>$thread->{'subject'}<>$thread->{'posthandle'}<>$thread->{'res'}<>$thread->{'number'}<>$thread->{'bepast_time'}<>$thread->{'posttime'}<>\n");

						# 過去ログ化した日付でソート
						@renew_index = sort { (split(/<>/,$b))[6] <=> (split(/<>/,$a))[6] } @renew_index;

							# 全過去ログファイルを更新
							if($type =~ /Year-file/){
								Mebius::BBS::PastIndexAll("Renew New-line",$realmoto,$yearf,undef,$thread_num);
							}

					}

					# ▼行を削除 / 復活した場合
					if($type =~ /(Delete-thread|Repair-thread)/){
							Mebius::BBS::PastIndexAll("Renew",$realmoto,$yearf,undef,$thread_num);
					}

				# ディレクトリ作成
				Mebius::Mkdir(undef,$directory1);
				Mebius::Mkdir(undef,$directory2);

					# 月カウントを展開する
					if(%months){
							foreach(keys %months){
								push(@months,"$_=$months{$_}");
							}
						@months = sort { (split(/=/,$b))[0] <=> (split(/=/,$a))[0] } @months;
						$data{'months'} = "@months";
					}

				# トップデータを追加
				unshift(@renew_index,"$data{'key'}<>$thread_num<>$i<>$data{'months'}<>\n");

				# ファイル更新
				Mebius::Fileout(undef,$file,@renew_index);

			}

	}

	# ●インデックスの再展開
	if($type =~ /Get-index/){

		# 局所化
		my($first_page_number,$lastroupe_monthf);
		my $i_reverse_foreach = $i + 1;

		# ページめくり数の指定がない場合は代入
		if(!$start_page){
			$type .= qq( First-page);
				if($type =~ /Normal-view/){
					$start_page = $i;
				}
				if($type =~ /Search-index/){
					$start_page = 1;
				}
		}

			# 配列をソートする場合
			if($type =~ /Search-index/){
				@index_line = sort { (split(/<>/,$b))[0] <=> (split(/<>/,$a))[0] } @index_line;
			}

			# 配列を展開
			foreach(@index_line){

				# 局所化
				my($mark2);

					# ラウンドカウンタ
					$data{'i'}++;
					$i_reverse_foreach--;

					# 行を分解
					chomp;
					my($hit_point2,$i2,$key2,$monthf2,$subject2,$posthandle2,$resnum2,$thread_number2,$bepasttime2,$posttime2) = split(/<>/);

						# ●ページめくり用のリンクを定義 ( 一般 )
						if($type =~ /Normal-view/){

								# ▼条件１ - 区切りの良い数字で
								if($i_reverse_foreach % $maxview_index == 0 
								# ▼条件２ - まだ表示する行が残っており
								&& $i_reverse_foreach >= 1){
									my($page) = int($i_reverse_foreach / $maxview_index); 
										# 自分ページの場合
										if($i_reverse_foreach == $start_page){
											$pagelinks_line .= qq(<span style="color:#f00;">$page</span>\n);
										}
										# 自分ページではないが、自分ページ周辺のリンクの場合
										elsif($type =~ /Desktop-view/
										|| 	($i_reverse_foreach <= $start_page + ($maxview_index*$max_pagelinks)
										&& $i_reverse_foreach >= $start_page - ($maxview_index*$max_pagelinks))){
											$pagelinks_line .= qq(<a href="past-year-$yearf-$monthf-$i_reverse_foreach.html#LIST">$page</a>\n);
										}
										# 最初のページは必ず表示する
										elsif($i_reverse_foreach == $maxview_index){
											$pagelinks_line .= qq( .. <a href="past-year-$yearf-$monthf-$i_reverse_foreach.html#LIST">$page</a>\n);
										}
								}
						}

						# ●ページめくり用のリンクを定義 ( 検索 )
						if($type =~ /Search-index/){

								# ▼条件１ - 区切りの良い数字で
								if(($data{'i'} - 1) % $maxview_index == 0){

									# ページ数の表示をループごとに増やす
									$pagelinks_number++;

										# 自分ページの場合
										if($data{'i'} == $start_page){
											$pagelinks_line .= qq(<span style="color:#f00;">$pagelinks_number</span>\n);
										}
										# 自分ページではないが、自分ページ周辺のリンクの場合、もしくは最初のページの場合
										elsif($data{'i'} == 1
										|| ($data{'i'} <= $start_page + ($maxview_index*$max_pagelinks)
										&& $data{'i'} >= $start_page - ($maxview_index*$max_pagelinks))){
											$pagelinks_line .= qq(<a href="./?mode=pastindex&amp;$postbuf{'body'}&amp;page=$data{'i'}#LIST">$pagelinks_number</a>\n);
										}

								}

						}


						# 行が削除済みの場合
						if($key2 =~ /Deleted/){
								if($type !~ /Admin-mode/){ next; }
							$mark2 .= qq( <span style="color:#f00;">[ 削除済み ]</span>);
						}

						# 旧形式の過去ログから記録した場合
						if($key2 =~ /Old-thread/ && $type =~ /Admin-mode/){
							$mark2 .= qq( <span style="color:#f00">[ 旧形式から記録 ]</span>);
						}

					# ヒットカウンタ
					$data{'hit'}++;

					# 月別ヒットカウンタ
					$data{"thread_num_month$monthf2"}++;

						# ●ページめくり処理 ( 普通 )
						if($start_page && $type =~ /Normal-view/){
								# 前めくり
								if($i_reverse_foreach > $start_page){ next; }
								# 後めくり
								if($i_reverse_foreach <= $start_page - $maxview_index){
									$data{'flow_index'}++;
									next; 
								}
								# ２ページ目で、初期ページと重複する記事は表示しない
								if($type !~ /First-page/ && $i_reverse_foreach > $line_num_all - $maxview_index){
									next;
								}
						}

						# ●ページめくり処理 ( 検索 )
						if($start_page && $type =~ /Search-index/){
								# 前めくり
								if($data{'i'} < $start_page){ next; }
								# 後めくり
								if($data{'i'} >= $start_page + $maxview_index){
									$data{'flow_index'}++;
									next; 
								}
						}


					# グリニッジ時刻から日付を換算
					my(%time_bepast) = Mebius::Getdate("Get-hash-detail",$bepasttime2);
					my(%time_postthread) = Mebius::Getdate("Get-hash-detail",$posttime2);
					my($gyap_time2) = Mebius::SplitTime("Get-top-unit",$bepasttime2 - $posttime2);

						# デスクトップ版の表示
						if($type =~ /Desktop-view/){

								# 月別の見出し表示
								if($monthf2 ne $lastroupe_monthf && $type !~ /(Search-index|Month-view)/){
									$index_line .= qq(<tr>);
									$index_line .= qq(<td class="past">);
									$index_line .= qq(<a href="past-year-$yearf-$monthf2.html"><strong class="month">$yearf年$monthf2月</strong></a>);
									$index_line .= qq(</td>);
									$index_line .= qq(</tr>\n);
								}

							# 記事を表示
							$index_line .= qq(<tr>);
							#$index_line .= qq(<td class="past">);
							#$index_line .= qq($i2);
							#$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq(<a href="$thread_number2.html">$subject2</a>$mark2);
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($posthandle2);
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($resnum2回);
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($time_bepast{'date_forward_day'});
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($time_postthread{'date_forward_day'});
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($gyap_time2);
							$index_line .= qq(</td>);
							$index_line .= qq(</tr>\n);
						}

						# 携帯版の表示
						elsif($type =~ /Mobile-view/){

							# 背景色
							my $background_style_in = qq(background:#eee;) if($data{'hit'} % 2 == 1);

							# 表示内容
							$index_line .= qq(<div style="$background_style_in$main::ktextalign_center_in">);
							$index_line .= qq(<a href="$thread_number2.html">$subject2</a> $mark2);
							$index_line .= qq(<br$main::xclose>$resnum2レス $posthandle2);
							$index_line .= qq(</div>\n);
						}

				# 前ループの”月”を覚えておく
				$lastroupe_monthf = $monthf2;

			}

	}
	
	# ●ページめくり用リンクの整形
	if($type =~ /Get-index/ && $pagelinks_line && $data{'line_num'} > $maxview_index){
		$data{'pagelinks_line'} .= qq(<div class="pagelinks_pastindex line-height">\n);
		$data{'pagelinks_line'} .= qq(ページ： \n);
			if($type =~ /Normal-view/){
					if($type =~ /First-page/){ $data{'pagelinks_line'} .= qq(<span style="color:#f00;">新</span>\n); }
					else{ $data{'pagelinks_line'} .= qq(<a href="past-year-$yearf-all.html">新</a>\n); }
			}
		$data{'pagelinks_line'} .= qq($pagelinks_line\n);
		$data{'pagelinks_line'} .= qq(</div>\n);
	}

	# ●検索でヒットしなかった場合
	if($type =~ /Search-index/ && (!$index_line || $search_keyword eq "")) {
		$data{'index_line'} = qq(<h2$main::kstyle_h2>”$main::in{'word'}”の検索結果 (0件)</h2>\nヒットしませんでした。キーワードを変えて検索してください。\n);
	}

	# ●インデックスの整形
	elsif($type =~ /Get-index/){

			# 表示行がある場合は整形
			if($index_line){

					# 見出しを付ける場合
					if($type =~ /Addtion-Hx/){
							if($type =~ /Search-index/){
								$data{'index_line'} .= qq(<h2$main::kstyle_h2>”$main::in{'word'}”の検索結果 ($data{'hit'}件)</h2>\n);
							}
							elsif($type =~ /Month-view/){
								$data{'index_line'} .= qq(<h2$main::kstyle_h2>$yearf年$monthf月 ( $data{'i'}記事 )</h2>\n);
							}
							elsif($type =~ /Year-file/){
								$data{'index_line'} .= qq(<h2$main::kstyle_h2>$yearf年 ( $data{'i'}記事 )</h2>\n);
							}
							elsif($type =~ /Recentry/){
								$data{'index_line'} .= qq(<h2$main::kstyle_h2>最近の過去ログ</h2>\n);
							}
					}

				# データ部分
				if($type =~ /Desktop-view/){
					$data{'index_line'} .= qq(<table summary="過去ログ一覧" class="past_index">\n);
					#$data{'index_line'} .= qq(<th>連番</th>);
					$data{'index_line'} .= qq(<tr>);
					$data{'index_line'} .= qq(<th>題名</th><th>作成者</th><th>レス</th><th>過去ログ化</th><th>作成日</th><th>期間</th>\n);
					$data{'index_line'} .= qq(</tr>);
					$data{'index_line'} .= qq($index_line);
					$data{'index_line'} .= qq(</table>\n);
				}

				# データ部分
				elsif($type =~ /Mobile-view/){
					$data{'index_line'} .= qq(<div>\n);
					$data{'index_line'} .= qq($index_line);
					$data{'index_line'} .= qq(</div>\n);
				}

			}
	}



return(%data);

}


#-----------------------------------------------------------
# １掲示板あたりの全年メニュー
#-----------------------------------------------------------
sub PastIndexAll{

# 宣言
my($type,$realmoto,$yearf,$monthf) = @_;
my(undef,undef,undef,undef,$new_thread_num) = @_ if($type =~ /New-line|Year-delete/);
my($i,@renew_index,$index_line,$thread_num_all,%years,%self,$last_roupe_yearf);

	# 汚染チェック
	if($realmoto =~ /^$|\W/){ return(); }
	if($type =~ /Renew/ && $yearf =~ /\D/){ return(); }

# ファイル定義
my $directory1 = "${main::int_dir}_bbs_index/";
my $directory2 = "${directory1}_${realmoto}_index/";
my $file = "${directory2}${realmoto}_allindex.log";

	# ファイルを開く
	my($past_allindex_handler,$read_write) = Mebius::File::read_write($type,$file,$directory1,$directory2);
		if($read_write->{'f'}){ %self = (%self,%$read_write); } else{ return(%self); }

# トップデータを分解
chomp(my $top1 = <$past_allindex_handler>);
($self{'key'},$self{'yearfile_num'},$self{'thread_num'},$self{'years'}) = split(/<>/,$top1);

	# ハッシュだけ返す場合
	if($type =~ /Get-hash-only/){
		close($past_allindex_handler);
		return(%self);
	}

	# ファイルを展開する
	while(<$past_allindex_handler>){

		# ラウンドカウンタ
		$i++;

		# 行を分解
		chomp;
		my($key2,$yearf2,$thread_num2,$months2) = split(/<>/);

		# 年別記事数
		$years{"$yearf2"} = $thread_num2;

		# 全記事数を数える
		$thread_num_all += $thread_num2;

			# ●インデックス取得用
			if($type =~ /Get-index/){

				if($months2 eq ""){ $self{'please_fix_renew_flag'} = 1; }

				# 年別ファイルのトップデータを取得
				#my(%year_index) = Mebius::BBS::PastIndex("Get-hash-only Year-file",$realmoto,$yearf2);

					# 年別ファイルに記事数がない場合は、エスケープ
					#if($year_index{'thread_num'} <= 0){ next; }

					# 移動リンク定義
					if(!$yearf || $yearf eq $yearf2){

							# 年ページへのリンクを定義
							if($yearf2 eq $yearf && $monthf eq "all"){
								$index_line .= qq(<h2 style="color:#f00;">$yearf2年 ( $thread_num2記事 )</h2>);
							}
							else{
								$index_line .= qq(<h2><a href="past-year-$yearf2-all.html">$yearf2年 ( $thread_num2記事 )</a></h2>);
							}


							# 月ページへのリンクを定義
							if($type =~ /Months-link/){
									# 月データを展開
									foreach(split(/\s/,$months2)){
										my($monthf3,$thread_num3) = split(/=/);
											if($monthf3 eq $monthf && $yearf2 eq $yearf){
												$index_line .= qq( <span style="color:#f00;">$monthf3月</span>\n);
												#( $thread_num3記事 )
											}
											else{
												$index_line .=  qq( <a href="past-year-$yearf2-$monthf3.html">$monthf3月</a>\n);
												# ( $thread_num3記事 )
											}
									}
							}
	
						$index_line .= qq(<br$main::xclose>\n);

					}

					# 全ての年を記憶
					if($self{'all_years'}){ $self{'all_years'} .= qq(,$yearf2); }
					else{ $self{'all_years'} = qq($yearf2); }

					# サーチボックスのラジオボタンをs定義
					my($checked_yearf) = $main::parts{'checked'} if($yearf eq $yearf2);
					$self{'input_radio'} .= qq(<input type="radio" name="target" value="$yearf2" id="past_search_year_$yearf2"$checked_yearf$main::xclose>\n);
					$self{'input_radio'} .= qq(<label for="past_search_year_$yearf2">$yearf2年</label>\n);

			}

			# ●ファイル更新用
			if($type =~ /Renew/){

				# 年別ファイルのトップデータを取得
				my(%year_index) = Mebius::BBS::PastIndex("Get-hash-only Year-file",$realmoto,$yearf2);

					# 尽き記録
					if($year_index{'months'}){ $months2 = $year_index{'months'}; }
					if($year_index{'thread_num'} ne ""){ $thread_num2 = $year_index{'thread_num'}; }

					# ログ行が欠けている場合
					if($last_roupe_yearf && $last_roupe_yearf - 1 > $yearf2){
						my $push_year = $last_roupe_yearf - 1;
						push(@renew_index,"<>$push_year<><>\n");
					}

				# ログ復帰のために、行の年度を覚えておく
				$last_roupe_yearf = $yearf2;

					# 既に当年の登録がある場合
					if($type =~ /New-line/ && $yearf2 eq $yearf){ next; }

				# 更新行を追加
				push(@renew_index,"$key2<>$yearf2<>$thread_num2<>$months2<>\n");

			}

	}

	# ●インデックスを整形
	if($type =~ /Get-index/ && $index_line){
		$self{'index_line'} .= qq();
		$self{'index_line'} .= qq($index_line);
		$self{'index_line'} .= qq();
	}

	# ●ファイルを更新する
	if($type =~ /Renew/){

		# 宣言
		my(@years);

			# ▼新しい行を追加する場合
			if($type =~ /New-line/){

				# 年別ファイルのトップデータを取得
				my(%year_index) = Mebius::BBS::PastIndex("Get-hash-only Year-file",$realmoto,$yearf);

				# 新しい行を追加する
				unshift(@renew_index,"<>$yearf<>$new_thread_num<>$year_index{'months'}<>\n");

				# ラウンドカウンタ / 全記事数などを増やす
				$i++;
				$thread_num_all += 1;
				$years{"$yearf"} += 1;

			}

		# 年別にソート
		@renew_index = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_index;

			# トップデータ調整
			if($thread_num_all){ $self{'thread_num'} = $thread_num_all; }

			# 年カウントを展開する
			if(%years){
					foreach(keys %years){
						push(@years,"$_=$years{$_}");
					}
				@years = sort { (split(/=/,$b))[0] <=> (split(/=/,$a))[0] } @years;
				$self{'years'} = "@years";
			}

		# トップデータを追加
		unshift(@renew_index,"$self{'key'}<>$i<>$self{'thread_num'}<>$self{'years'}<>\n");

		# ファイル更新
		Mebius::File::truncate_print($past_allindex_handler,@renew_index);

	}

close($past_allindex_handler);

	# パーミッション変更
	if($type =~ /Renew/){	Mebius::Chmod(undef,$file); }

	# 全掲示板の一覧を更新
	if($type =~ /Renew/){
		Mebius::BBS::PastIndexAllBBS("Renew New-line",$realmoto,$main::title,$self{'thread_num'},$self{'years'});
	}


# リターン
return(%self);

}

#-----------------------------------------------------------
# 全掲示板のリスト
#-----------------------------------------------------------
sub PastIndexAllBBS{

# 宣言
my($type,$realmoto) = @_;
my(undef,undef,$title,$thread_num) = @_ if($type =~ /New-line/);
my($allbbs_index_handler,%data,@renew_index,$thread_num_all,$index_line);

	# 汚染チェック
	if($type =~ /Renew/ && $realmoto =~ /^$|\W/){ return(); }
	
	# 各種リターン
	if($realmoto =~ /^(sc|sub)/){ return(); }

# ファイル定義
my $directory1 = "${main::int_dir}_bbs_index/";
my $file = "${directory1}allbbs_index.log";

# ファイルを開く
open($allbbs_index_handler,"<$file");

	# ファイルロック
	if($type =~ /Renew/){ flock($allbbs_index_handler,1); }

#トップデータを分解
chomp(my $top1 = <$allbbs_index_handler>);
($data{'key'},$data{'lasttime'},$data{'thread_num'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$allbbs_index_handler>){

		# 局所化
		my($all_split);

		# 行を分解
		chomp;
		my($key2,$realmoto2,$title2,$thread_num2,$lasttime2) = split(/<>/);

			# 記事数カウンタ
			$thread_num_all += $thread_num2;

			# インデックス取得用
			if($type =~ /Get-index/){

				# 年別ファイルのハッシュを取得
				my(%all_index) = Mebius::BBS::PastIndexAll("Get-hash-only",$realmoto2);

				# 基本リンク
				$index_line .= qq(<a href="/_$realmoto2/past.html">$title2</a> ( $thread_num2 )\n);
				$index_line .= qq( - );

					# 年別リンク
					foreach $all_split (split(/\s/,$all_index{'years'})){
						my($yearf3,$thread_num3) = split(/=/,$all_split);
						$index_line .= qq(<a href="/_$realmoto2/past-year-$yearf3-all.html">$yearf3年</a> ( $thread_num3 )\n);
					}

				$index_line .= qq(<br$main::xclose>\n);

			}

			# ●ファイル更新用
			if($type =~ /Renew/){

					# 重複した掲示板の場合
					if($realmoto2 eq $realmoto){
						next;
					}

				# 更新行を追加
				push(@renew_index,"$key2<>$realmoto2<>$title2<>$thread_num2<>$lasttime2<>\n");

			}

	}

close($allbbs_index_handler);

	# ●ファイル更新用
	if($type =~ /Renew/){

		# ディレクトリを作成
		Mebius::Mkdir(undef,$directory1);

			# 新しい行を追加
			if($type =~ /New-line/){
				unshift(@renew_index,"<>$realmoto<>$title<>$thread_num<>$main::time<>\n");
				$thread_num_all++;
			}

		# 更新行をソート
		@renew_index = sort { (split(/<>/,$b))[3] <=> (split(/<>/,$a))[3] } @renew_index;

		# トップデータを追加
		unshift(@renew_index,"$data{'key'}<>$main::time<>$thread_num_all<>\n");

		# ファイルを更新
		Mebius::Fileout(undef,$file,@renew_index);

	}

	# ●インデックス取得用
	if($type =~ /Get-index/){

			# インデックスを整形
			if($index_line){

					if($type =~ /Addtion-Hx/){
						$data{'index_line'} .= qq(<h2$main::kstyle_h2>メニュー ( 全 $data{'thread_num'}記事 )</h2>\n);
					}

				$data{'index_line'} .= qq(<div class="line-height">\n);
				$data{'index_line'} .= qq($index_line\n);
				$data{'index_line'} .= qq(</div>\n);
				$data{'index_line'} .= qq(\n);
			}

	}


return(%data);

}



1;
