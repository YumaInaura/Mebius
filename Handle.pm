
use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# 筆名単位のファイル
#-----------------------------------------------------------
sub Handle{

# 宣言
my($type,$handle,$trip,$year,$monthf,$moto,$realmoto,$thread_number,$res_number,$thread_subject) = @_;
my($handle_handler,@renew_line,$still_flag,$foreach1,$thisbbs_count,$thismonth_count);

# 値のチェック
if($handle eq ""){ return(); }
if($moto eq "" || $moto =~ /\W/){ return(); }

# 値の整形
$handle =~ s/(^\s+|\s+$)//g;

# エンコード
my($handle_encoded) = Mebius::Encode(undef,$handle);
my($trip_encoded) = Mebius::Encode(undef,$trip);

# ファイル定義
my $base_directory = "${main::int_dir}_handle/";
my $directory = "${base_directory}_filedata_handle/";
my $file = "${directory}${handle_encoded}_${trip_encoded}.dat";

# ファイルを開く
open($handle_handler,"<$file");

	# ファイルロック
	if($type =~ /Renew/){ flock($handle_handler,1); }

# トップデータを分解
chomp(my $top1 = <$handle_handler>);
my($tconcept,$thandle,$ttrip,$tallcount,$tfirst_time,$tlast_time) = split(/<>/,$top1);

	# ファイルを展開
	while(<$handle_handler>){

		# 行を分解
		chomp;
		my($moto2,$count2,$year2,$monthf2,$thismonth_count2) = split(/<>/);

			# ●同じ掲示板の場合
			if($moto2 eq $moto){

				# この掲示板のカウント数
				$thisbbs_count = $count2;

					# ●新規カウント用の処理
					if($type =~ /New-count/){
						$count2++;
						$still_flag = 1;
							# 当月の場合、当月カウントを増やす
							if("$year2-$monthf2" eq "$year-$monthf"){
								$thismonth_count2++;
							}
							# 当月でない場合、次月データに更新
							else{
								$thismonth_count2 = 0;
								$year2 = $year;
								$monthf2 = $monthf;
							}

					}

					# 当月のカウント数を記憶
					if("$year2-$monthf2" eq "$year-$monthf"){
						$thismonth_count = $thismonth_count2;
					}

			}

			# ●ファイル更新用 
			if($type =~ /Renew/){
				push(@renew_line,"$moto2<>$count2<>$year2<>$monthf2<>$thismonth_count2<>\n");
			}

	}


close($handle_handler);

	# ▼新しくカウントする場合
	if($type =~ /New-count/){
		$thisbbs_count++;
		$thismonth_count++;
			# この掲示板の記録がない場合、新しく追加する
			if(!$still_flag){
				unshift(@renew_line,"$moto<>$thisbbs_count<>$year<>$monthf<>$thismonth_count<>\n");
			}
		$tallcount++;
	}

	# ●ファイル更新
	if($type =~ /Renew/){

			# ディレクトリ作成
			if(!$top1){
				Mebius::Mkdir(undef,$base_directory);
				Mebius::Mkdir(undef,$directory);
			}

			# トップデータに足りない要素を追加
			if($tconcept eq ""){ $tconcept = "Ok"; }
			if($thandle eq ""){ $thandle = $handle; }
			if($ttrip eq ""){ $ttrip = $trip; }
			if($tfirst_time eq ""){ $tfirst_time = $main::time; }

		# トップデータを追加
		unshift(@renew_line,"$tconcept<>$thandle<>$ttrip<>$tallcount<>$tfirst_time<>$main::time<>\n");

		# 更新
		Mebius::Fileout(undef,$file,@renew_line);

			# 掲示板毎のランキングに登録する
			if($type =~ /New-count/ && $tconcept !~ /Deny-ranking/){
				Mebius::BBS::HandleRankingBBS("Renew New-count All-file",$handle,$trip,$thisbbs_count,$year,$monthf,$moto,$realmoto,$thread_number,$res_number,$thread_subject);
				Mebius::BBS::HandleRankingBBS("Renew New-count News-file",$handle,$trip,$thismonth_count,$year,$monthf,$moto,$realmoto,$thread_number,$res_number,$thread_subject);
				Mebius::BBS::HandleRankingBBS("Renew New-count Month-file",$handle,$trip,$thismonth_count,$year,$monthf,$moto,$realmoto);
			}

			# 掲示板毎のランキングから削除する
			if($type =~ /Delete-handle/){
				Mebius::BBS::HandleRankingBBS("Renew Delete-handle All-file",$handle,$trip,undef,$year,$monthf,$moto);
				Mebius::BBS::HandleRankingBBS("Renew Delete-handle News-file",$handle,$trip,undef,$year,$monthf,$moto);
				Mebius::BBS::HandleRankingBBS("Renew Delete-handle Month-file",$handle,$trip,undef,$year,$monthf,$moto);
			}

	}


}


#-----------------------------------------------------------
# 筆名ランキング ( 掲示板単位 )
#-----------------------------------------------------------
sub HandleRankingBBS{

# 宣言
my($type,$handle,$trip,$new_count,$year,$monthf,$moto,$realmoto,$thread_number,$res_number,$thread_subject) = @_;
	if($type =~ /(Get-index|Dead-link-check)/){ (undef,$moto,$year,$monthf) = @_; }
my($ranking_handler,@renew_line,$keep_min_count,$i,$new_key,$still_flag,$file,$index_line,$ranking_flag,$max_line,$hit);

# 値のチェック
if($type =~ /(New-count|Delete-handle)/ && $handle eq ""){ return(); }
if($moto eq "" || $moto =~ /\W/){ return(); }

	# 各種リターン
	if($type =~ /New-count/){
			if($new_count <= 0){ return(); }
			#if($main::secret_mode){ return(); }				# 秘密板 → どうせ掲示板内で見るだけなので、隠さなくても良い？
			#if($main::bbs{'concept'} =~ /Not-handle-ranking/){ return(); }	# ( PVの禁止設定をそのまま流用 ) → 内部ではカウントしてても良い
	}

# 掲示板ファイル名を取得
my($bbs_file) = Mebius::BBS::InitFileName(undef,$moto);

# ディレクトリ定義
my $directory = "$bbs_file->{'data_directory'}_handle_ranking_${moto}/";

	# ファイル定義 - 全期間
	if($type =~ /All-file/){
		$file = "${directory}${moto}_ranking_handle.log";
		$ranking_flag = 1;
		$max_line = 100;
	}
	# ファイル定義 - 月毎
	elsif($type =~ /Month-file/){
		if($year eq "" || $year =~ /\D/){ return(); }
		if($monthf eq "" || $monthf =~ /\D/){ return(); }
		$file = "${directory}${moto}_ranking_handle_${year}_${monthf}.log";
		$ranking_flag = 1;
		$max_line = 30;
	}
	# ファイル定義 - 最近
	elsif($type =~ /News-file/){
		$file = "${directory}${moto}_news_handle.log";
		$max_line = 30;
	}
	# ファイル指定がない場合
	else{
		return();
	}


# ファイルを開く
my $open = open($ranking_handler,"<$file");

	# ファイルの有無チェック
	if($type =~ /File-check-return/ && !$open){ return(); }
	if($type =~ /File-check-error/ && !$open){ main::error("このランキングページは存在しません。"); }

	# ファイルロック
	if($type =~ /Renew/){ flock($ranking_handler,1); }

# トップデータを分解
chomp(my $top1 = <$ranking_handler>);
my($tconcept,$tmin_count,$ti,$tlastyear,$tlastmonthf,$tlast_deadlink_checktime) = split(/<>/,$top1);

	# 自動リンク切れチェックで、前回のチェックからまだ時間が経過していない場合
	if($type =~ /Dead-link-check/){
			if($main::time < $tlast_deadlink_checktime + 3*24*60*60){
				close($ranking_handler);
				return();
			}
	}

	# 今までの最小カウント数より新規カウント数が少ない場合など、すぐにリターンして負荷を軽減 ( ランキングモードのみ )
	if($type =~ /New-count/ && $ranking_flag){
			if($ti >= $max_line && $tmin_count >= $new_count){
				close($ranking_handler);
				return();
			}
	}



	# ファイルを展開
	while(<$ranking_handler>){

		# ラウンドカウンタ
		$i++;

			# 最大行数に達した場合
			if($i > $max_line){ last; }
		
		# 行を分解
		chomp;
		my($key2,$count2,$handle2,$trip2,$lasttime2,$lastdate2,$realmoto2,$thread_number2,$res_number2,$thread_subject2) = split(/<>/);

			# 自動リンク切れチェック
			if($type =~ /Dead-link-check/){
					if($key2 !~ /Dead-link/){	
						my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$realmoto2,$thread_number2);
							if($thread->{'keylevel'} < 0){
								$key2 .= qq( Dead-link);
									if($type !~ /Renew/){ $type .= qq( Renew); }
							}
					}
			}

			# ファイル更新時の前処理
			if($type =~ /Renew/){
					# 最小カウント数を記憶する
					if($keep_min_count eq "" || $keep_min_count > $count2){ $keep_min_count = $count2; }
			}

			# ●新しくカウントする場合
			if($type =~ /New-count/){
					# 同じ筆名 / トリップの場合はカウントを増やす
					if("$handle2-$trip2" eq "$handle-$trip"){
						$still_flag = 1;
						$count2 = $new_count;
						$lasttime2 = $main::time;
						$lastdate2 = $main::date;
						$realmoto2 = $realmoto;
						$thread_number2 = $thread_number;
						$res_number2 = $res_number;
						$thread_subject2 = $thread_subject;
						$key2 =~ s/(\s?)Deleted//g;
					}
			}

			# ●行を削除状態にする場合
			if($type =~ /Delete-handle/){
					# 同じ筆名 / トリップの場合はキーを変更
					if("$handle2-$trip2" eq "$handle-$trip" && $key2 !~ /Deleted/){
						$key2 .= qq( Deleted);
					}
			}


			# ●ファイル更新用
			if($type =~ /Renew/){
		# 更新行を追加
		push(@renew_line,"$key2<>$count2<>$handle2<>$trip2<>$lasttime2<>$lastdate2<>$realmoto2<>$thread_number2<>$res_number2<>$thread_subject2<>\n");
			}

			# ●インデックスを取得する場合
			if($type =~ /Get-index/){

					# ヒットカウンタ
					$hit++;

					# 非表示の場合
					if($key2 =~ /Deleted/){ next; }

					# モバイル版の表示
					if($type =~ /Mobile-view/){
						my($style_in);
							if($hit % 2 == 0){ $style_in .= qq(background:#eee;); }
						$index_line .= qq(<div style="$style_in$main::kborder_top_in">);
						$index_line .= qq($handle2);
							if($trip2){ $index_line .= qq(☆$trip2); }
						$index_line .= qq( $count2回);
						$index_line .= qq(<br$main::xclose>);
						$index_line .= qq($lastdate2);
						$index_line .= qq(</div>);
					}

					# デスクトップ版の表示
					elsif($type =~ /Desktop-view/){
						$index_line .= qq(<tr>);
						# 筆名
						$index_line .= qq(<td class="hnd">);
						$index_line .= qq($handle2);
							if($trip2){ $index_line .= qq(☆$trip2); }
						$index_line .= qq(</td>);

						# 投稿先の記事
						$index_line .= qq(<td class="hnd">);
							if($thread_subject2 && $key2 !~ /Dead-link/){
								$index_line .= qq(<a href="/_$realmoto2/$thread_number2.html#S$res_number2">$thread_subject2</a>);
							}
						$index_line .= qq(</td>);
						# 最終日付
						$index_line .= qq(<td class="hnd">);
						$index_line .= qq($lastdate2);
						$index_line .= qq(</td>);
						# 投稿回数
						$index_line .= qq(<td class="hnd right">);
						$index_line .= qq($count2回);
						$index_line .= qq(</td>);
						# セル行終わり
						$index_line .= qq(</tr>\n);
					}
			}



	}

close($ranking_handler);

	# ▼新しくカウントする場合
	if($type =~ /New-count/){

			# 新しく追加する行
			if(!$still_flag){
				$i++;
	unshift(@renew_line,"$new_key<>$new_count<>$handle<>$trip<>$main::time<>$main::date<>$realmoto<>$thread_number<>$res_number<>$thread_subject<>\n");
			}

			# 基本ディレクトリを作成 ( A-1 )
			if(!$top1){
				Mebius::Mkdir(undef,$directory);
			}

			# 新しい月に突入した場合、歴史ファイルを更新する ( 必ず基本ディレクトリ作成”後”に処理 ) ( A-2 )
			if($type =~ /New-count/ && $type =~ /All-file/ && "$tlastyear-$tlastmonthf" ne "$year-$monthf"){
				Mebius::BBS::HandleRankingHistoryBBS("Renew New-month",$moto,$year,$monthf);
			}

		# 最後の記録月を更新 ( A-3 )
		$tlastyear = $main::thisyear;
		$tlastmonthf = $main::thismonthf;

			# カウントが多い順にソート ( 必ずトップデータを追加する”前”に )
			if($ranking_flag){
				@renew_line = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_line;
			}
	}

	# ▼ファイル更新
	if($type =~ /Renew/){
			
			# トップデータを追加 ( 必ず配列をソートした”後”に ) 
			$ti = $i;
			if($keep_min_count){ $tmin_count = $keep_min_count; }
			if($tconcept eq ""){ $tconcept = "Ok"; }
			if($type =~ /Dead-link-check/){ $tlast_deadlink_checktime = $main::time; }
		unshift(@renew_line,"$tconcept<>$tmin_count<>$ti<>$tlastyear<>$tlastmonthf<>$tlast_deadlink_checktime<>\n");
		# 更新
		Mebius::Fileout(undef,$file,@renew_line);

	}


	# ▼インデックスを返す
	if($type =~ /Get-index/){
		my($return_index_line);
			# 整形
			if($index_line){
					# デスクトップ版
					if($type =~ /Desktop-view/){

						# CSS定義
						$main::css_text .= qq(table.handle_ranking{width:100%;}\n);
						$main::css_text .= qq(td.hnd,th.hnd{padding:0.3em 0.5em;}\n);
						$main::css_text .= qq(th.res_count{width:4.5em;}\n);

						# 整形
						$return_index_line .= qq(<table summary="投稿数ランキング" class="handle_ranking bbs">\n);
						$return_index_line .= qq(<tr>);
						$return_index_line .= qq(<th>筆名</th>);
						$return_index_line .= qq(<th>最終投稿</th>);
						$return_index_line .= qq(<th>最終日付</th>);
						$return_index_line .= qq(<th class="res_count">投稿回数</th>);
						$return_index_line .= qq(</tr>);
						$return_index_line .= qq($index_line);
						$return_index_line .= qq(</table>\n);

					}
					# モバイル版
					elsif($type =~ /Mobile-view/){
						$return_index_line = $index_line;
					}
			}
		return($return_index_line);
	}

}

#-----------------------------------------------------------
# 筆名ランキングの月記録ファイル
#-----------------------------------------------------------
sub HandleRankingHistoryBBS{

# 宣言
my($type,$moto,$year,$monthf) = @_;
my($history_handler,@renew_line,$still_flag,$index_line);

# 値のチェック
if($moto eq "" || $moto =~ /\W/){ return(); }
	if($type =~ /Renew/){
		if($year eq "" || $year =~ /\D/){ return(); }
		if($monthf eq "" || $monthf =~ /\D/){ return(); }
	}


# 掲示板ファイル名を取得
my($bbs_file) = Mebius::BBS::InitFileName(undef,$moto);

# ファイル定義
my $directory = "$bbs_file->{'data_directory'}_handle_ranking_${moto}/";
my $file = "${directory}${moto}_history_handle.log";

# ファイルを開く
open($history_handler,"<$file");

	# ファイルロック
	if($type =~ /Renew/){ flock($history_handler,1); }

# トップデータを分解
chomp(my $top1 = <$history_handler>);
my($tconcept) = split(/<>/,$top1);

	# ファイルを展開
	while(<$history_handler>){

		# この行を分解
		chomp;
		my($year2,$monthf2) = split(/<>/);

		# インデックスを取得
		if($type =~ /Get-index/){
				if("$year2-$monthf2" eq "$year-$monthf"){
					$index_line .= qq($year2年$monthf2月\n);
				}
				else{
					$index_line .= qq(<a href="ranking-$year2-$monthf2.html">$year2年$monthf2月</a>\n);
				}

		}

		# 同じ月の登録がある場合
		if("$year2-$monthf2" eq "$year-$monthf"){
			$still_flag = 1;
		}

		# 更新行を追加
		if($type =~ /Renew/){
			push(@renew_line,"$year2<>$monthf2<>\n");
		}

	}

close($history_handler);

	# 新しい月の行を追加する
	if($type =~ /New-month/){
		if($still_flag){ return(); }
		else{ unshift(@renew_line,"$year<>$monthf<>\n"); }
	}


	# ファイルを更新
	if($type =~ /Renew/){
		unshift(@renew_line,"$tconcept<>\n");
		Mebius::Fileout(undef,$file,@renew_line);
	}


	# インデックスを返す
	if($type =~ /Get-index/){
		return($index_line);
	}
}


1;
