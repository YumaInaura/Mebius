
use strict;
use Mebius::RenewStatus;
package Mebius::Auth;

#-----------------------------------------------------------
# SNSの個別の日記を開く
#-----------------------------------------------------------
sub diary{

# 宣言
my($type,$account,$diary_number) = @_;
my(undef,undef,undef,$renew) = @_ if($type =~ /Renew/);
my($diary_handler,%diary,$i,@renew_line);

	# 汚染チェック
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }
	if($diary_number =~ /\D/ || $diary_number eq ""){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
my $file = "${account_directory}diary/${account}_diary_${diary_number}.cgi";

	# 日記ファイルを開く
	if($type =~ /File-check-error|Level-check-error/){ open($diary_handler,"<$file") || main::error("この日記は存在しません。"); }
	else{ open($diary_handler,"<$file") || ($diary{'nothing_flag'} = 1); }

	# ファイルロック
	if($type =~ /Renew/){ flock(1,$diary_handler); }

chomp(my $top1 = <$diary_handler>);
chomp(my $top2 = <$diary_handler>);

# データを分解
($diary{'key'},$diary{'number'},$diary{'subject'},$diary{'res'},$diary{'postdates'},$diary{'posttime'},$diary{'lastrestime'},$diary{'control_datas'},$diary{'last_account'},$diary{'last_handle'},$diary{'owner_lastres_time'},$diary{'owner_lastres_number'},$diary{'concept'}) = split(/<>/,$top1);
($diary{'year'},$diary{'month'},$diary{'day'},$diary{'hour'},$diary{'min'},$diary{'sec'}) = split(/,/,$diary{'postdates'});
(undef,undef,$diary{'account'},$diary{'handle'},$diary{'id'},$diary{'trip'},$diary{'comment'},$diary{'dates'},$diary{'color'},$diary{'xip'},$diary{'controler_file'},$diary{'control_date'}) = split(/<>/,$top2);

	# ハッシュ調整
	if(!$diary{'nothing_flag'}){ $diary{'f'} = 1; }
	if(($diary{'key'} eq "2" || $diary{'key'} eq "4") && $diary{'concept'} !~ /Deleted/){ $diary{'concept'} .= qq( Deleted); }
	if($diary{'concept'} =~ /Deleted/){ $diary{'deleted_flag'} = 1; }

	# 拍手判定
	if($type =~ /Crap-check/){
			if($diary{'concept'} =~ /Not-ranking-crap/){ $diary{'not_crap_ranking_flag'} = 1; }
			if($diary{'concept'} =~ /Not-crap/){ $diary{'not_crap_flag'} = 1; }
			if($diary{'subject'} =~ /拍手/){ $diary{'not_crap_ranking_flag'} = 1; }
			if($diary{'comment'} =~ /拍手/){ $diary{'not_crap_ranking_flag'} = 1; }
	}

	# ●日記ファイルを展開 ( 限定 )
	if($type =~ /Renew/){

			# ファイルを展開
			while(<$diary_handler>){
		
				# ラウンドカウンタ
				$i++;
		
				chomp;
				my($key2,$res_number2,$account2,$handle2,$id2,$trip2,$comment2,$dates2,$color2,$xip2,$controler_account2,$control_date2) = split(/<>/);
		
				# 更新行を追加
	push(@renew_line,"$key2<>$res_number2<>$account2<>$handle2<>$id2<>$trip2<>$comment2<>$dates2<>$color2<>$xip2<>$controler_account2<>$control_date2\n");
		
			}


	}

close($diary_handler);

	# レベルチェック
	if($type =~ /Level-check-error/){
			if($diary{'deleted_flag'}){ main::error("この日記は存在しないか、削除済みです。"); }
	}

	# ファイル更新
	if($type =~ /Renew/){

		# ２行目データを追加
		unshift(@renew_line,"$top2\n");

			# トップデータを一斉更新
			foreach(keys %$renew){
				$diary{$_} = $renew->{$_};
			}

		# トップデータを追加
	unshift(@renew_line,"$diary{'key'}<>$diary{'number'}<>$diary{'subject'}<>$diary{'res'}<>$diary{'postdates'}<>$diary{'posttime'}<>$diary{'lastrestime'}<>$diary{'control_datas'}<>$diary{'last_account'}<>$diary{'last_handle'}<>$diary{'owner_lastres_time'}<>$diary{'owner_lastres_number'}<>$diary{'concept'}<>\n");
		Mebius::Fileout(undef,$file,@renew_line);
	}
	

return(\%diary);

}

#-----------------------------------------------------------
# 日記へのコメント履歴
#-----------------------------------------------------------
sub ResDiaryHistory{
# 宣言
my($type,$account) = @_;
my(undef,undef,$new_account,$new_diary_number,$new_res_number) = @_;
my($FILE1,%self,$i,@renew_line,@index_line,$hit_topics,$under_interval,$hit_renew_status_flag,$renew_file_flag);

# 汚染チェック
if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# トピックスの最大表示行数
my $max_view_topics = 4;

	# 最低取得間隔
	if(Mebius::AlocalJudge()){ $under_interval = 10; }
	else{ $under_interval = 15*60; }

# ファイル定義
my $file1 = "${account_directory}resdiary_history.log";

# ファイルを開く
	if($type =~ /File-check-error/){
		$self{'f'} = open($FILE1,"+<",$file1) || &main::error("ファイルが存在しません。");
	}
	else{

		$self{'f'} = open($FILE1,"+<",$file1);

			# ファイルが存在しない場合
			if(!$self{'f'}){
					# 新規作成
					if($type =~ /Renew/){
						Mebius::Fileout("Allow-empty",$file1);
						$self{'f'} = open($FILE1,"+<",$file1);
					}
					else{
						return(\%self);
					}
			}

	}

	# ファイルロック
	if($type =~ /Renew|Renew-news|Flock/){ flock(2,$FILE1); }
	
# トップデータを分解
chomp(my $top1 = <$FILE1>);
($self{'concept'},$self{'last_get_news_time'}) = split(/<>/,$top1);

	# しばらく更新されていない場合 (A-1)
	if($type =~ /(Allow-renew-news)/ && time > $self{'last_get_news_time'} + ($under_interval)){
		$type .= qq( Renew-news);
	}

	# ●ファイルを展開(A-2)
	while(<$FILE1>){

		# この行を分割
		chomp;
my($key2,$account2,$diary_number2,$res_number2,$regist_time2,$regist_date2,$subject2,$last_modified2,$res2,$owner_handle2,$last_account2,$last_handle2,$owner_lastres_time2,$owner_lastres_number2,$last_get_diary_time2) = split(/<>/);

			# ▼新着データ更新用
			if($type =~ /Renew-news/){

				# 更新間隔を定義
				my($allow_get_file_flag) = Mebius::RenewStatus::allow_judge_for_get_file({ UnderIntervalSecond => $under_interval },$last_get_diary_time2,$last_modified2);

					# 日記データを取得 ( データ行が消えてしまうため、判定が偽の場合も next しない )
					if($allow_get_file_flag){

						my($diary) = Mebius::Auth::diary("Get-hash",$account2,$diary_number2);
						$last_get_diary_time2 = time;
						$renew_file_flag = 1;

							# キー判定
							if(!$diary->{'f'}){ next; }
							if($diary->{'concept'} =~ /Deleted/){ next; }

							# データ更新
							if($diary->{'subject'}){
								$subject2 = $diary->{'subject'};
								$last_modified2 = $diary->{'lastrestime'};
								$res2 = $diary->{'res'};
								$owner_handle2 = $diary->{'handle'};
								$last_account2 = $diary->{'last_account'};
								$last_handle2 = $diary->{'last_handle'};
								$owner_lastres_time2= $diary->{'owner_lastres_time'};
								$owner_lastres_number2 = $diary->{'owner_lastres_number'};
							}

					}

			}

		# インデックス行に追加 (更新行では”ない”ため注意) 
	push(@index_line,"$key2<>$account2<>$diary_number2<>$res_number2<>$regist_time2<>$regist_date2<>$subject2<>$last_modified2<>$res2<>$owner_handle2<>$last_account2<>$last_handle2<>$owner_lastres_time2<>$owner_lastres_number2<>$last_get_diary_time2<>\n");

	} 

	# ファイルがない場合はこのままリターン
	if($type =~ /Get-index|Get-topics/ && !$self{'f'}){
		close($FILE1);
		return();
	}

	# ●配列をソート
	if($type =~ /Get-topics/){
		@index_line = sort { (split(/<>/,$b))[7] <=> (split(/<>/,$a))[7] } @index_line;
	}

	# ●ファイルを再展開
	foreach(@index_line){

		# ラウンドカウンタ
		$i++;

		# この行を分割
		chomp;
my($key2,$account2,$diary_number2,$res_number2,$regist_time2,$regist_date2,$subject2,$last_modified2,$res2,$owner_handle2,$last_account2,$last_handle2,$owner_lastres_time2,$owner_lastres_number2,$last_get_diary_time2) = split(/<>/);

			# ▼トピックス取得用
			if($type =~ /Get-topics/ && $hit_topics < $max_view_topics){
				$self{'topics_line'} .= qq(<div>);
				$self{'topics_line'} .= qq(<a href="${main::auth_url}$account2/d-$diary_number2">$subject2</a>);
				$self{'topics_line'} .= qq( (<a href="${main::auth_url}$account2/d-$diary_number2#S$res2">$res2</a>));
				$self{'topics_line'} .= qq(　 $last_handle2);

					#if($last_modified2 > $regist_time2 && $main::time < $last_modified2 + (1*24*60*60)){
						my($blank_time) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-前",time - $last_modified2);
						$self{'topics_line'} .= qq(　 $blank_time);
					#}

				$self{'topics_line'} .= qq(</div>\n);
				$hit_topics++;
			}

			# ▼インデックス取得用
			if($type =~ /Get-index/){

					# 最大表示行数
					if($i > 20){ next; }

				my($regist_time_before2) = Mebius::SplitTime("Plus-text-前 Get-top-unit",time - $regist_time2);

					$self{'index_line'} .= qq(<tr>);
					$self{'index_line'} .= qq(<td><a href="${main::auth_url}$account2/d-$diary_number2">$subject2</a>);

					$self{'index_line'} .= qq( (<a href="${main::auth_url}$account2/d-$diary_number2#S$res_number2">$res2</a>)</td>);

					$self{'index_line'} .= qq(<td><a href="${main::auth_url}$account2/">$owner_handle2 - $account2</a></td>);

					$self{'index_line'} .= qq(<td>);

						# アカウント主の新着レスがある場合
						if($owner_lastres_time2 > $regist_time2 && time < $owner_lastres_time2 + (3*24*60*60)){
							my($newres_time_before2) = Mebius::SplitTime("Plus-text-前 Get-top-unit Color-view",$main::time - $owner_lastres_time2);
								$self{'index_line'} .= qq( $owner_handle2さん(アカウント主)が $newres_time_before2 に更新しました。);
						}

						# 新着レスがある場合
						if($last_modified2 > $regist_time2 && time < $last_modified2 + (3*24*60*60) && $regist_time2 != $owner_lastres_time2){
							my($newres_time_before2) = Mebius::SplitTime("Plus-text-前 Get-top-unit Color-view",$main::time - $last_modified2);
								$self{'index_line'} .= qq( $last_handle2さんが $newres_time_before2 に更新しました。);
						}

						# 新着レスがない場合
						if($account eq $last_account2){
							my($newres_time_before2) = Mebius::SplitTime("Plus-text-前 Get-top-unit",$main::time - $regist_time2);
							$self{'index_line'} .= qq( <span style="color:#999;">あなたが最後に更新しました。</span>);
						}



					$self{'index_line'} .= qq(</td>);

					$self{'index_line'} .= qq(</tr>\n);

			}

			# ▼ファイル更新用
			if($type =~ /Renew/ || $renew_file_flag){ 

					# 最大記録行数を超えた場合
					if($i >= 50){ next; }

					# 同じ記事の場合
					if("$account2-$diary_number2" eq "$new_account-$new_diary_number"){
						next;
					}

				# 更新行を追加
	push(@renew_line,"$key2<>$account2<>$diary_number2<>$res_number2<>$regist_time2<>$regist_date2<>$subject2<>$last_modified2<>$res2<>$owner_handle2<>$last_account2<>$last_handle2<>$owner_lastres_time2<>$owner_lastres_number2<>$last_get_diary_time2<>\n");

			}

	}

	# ●ファイル更新用
	if($type =~ /Renew($|[^-])/ || $renew_file_flag){

			# ▼新着情報をゲットした場合
			if($type =~ /Renew-news/){
				$self{'last_get_news_time'} = time;
			}

			# ▼新しくレスをする場合
			if($type =~ /New-res/){

				# 日記データを取得
				my($diary) = Mebius::Auth::diary("Get-hash",$new_account,$new_diary_number);
				unshift(@renew_line,"<>$new_account<>$new_diary_number<>$new_res_number<>$main::time<>$main::date<>$diary->{'subject'}<>$main::time<>$new_res_number<>$diary->{'handle'}<>$account<>$main::myaccount{'name'}<>$diary->{'owner_lastres_time'}<>$diary->{'owner_lastres_number'}<>\n");
			}

		# トップデータを追加
		unshift(@renew_line,"$self{'concept'}<>$self{'last_get_news_time'}<>\n");

		# ファイル更新
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renew_line;


	}

close($FILE1);

	# パーミッション変更
	if($type =~ /Renew($|[^-])/ || $renew_file_flag){ Mebius::Chmod(undef,$file1); }

	# ●トピックスを取得する場合
	if($type =~ /Get-topics/){
			if(!$self{'topics_line'}){
				$self{'topics_line'} = qq(履歴はありません。);
			}
			my($how_before_renew) =Mebius::SplitTime("Get-top-unit Plus-text-前",$main::time - $self{'last_get_news_time'});
		$self{'topics_line'} = qq(<h3$main::kstyle_h3>\n<a href="./aview-history#DIARY">あなたのコメント履歴</a> </h3><div class="line-height-large">$self{'topics_line'}</div>\n);
			if($hit_topics >= $max_view_topics){
				$self{'topics_line'} .= qq(<div class="right">更新： $how_before_renew　<a href="./aview-history#DIARY">→続きを見る</a>　</div>);
			}
	}

	# ●インデックス取得する場合
	if($type =~ /Get-index/){
		$self{'index_line'} = qq(<table summary="日記へのコメント" class="width100">$self{'index_line'}</table>);
	}

return(%self);

}





1;