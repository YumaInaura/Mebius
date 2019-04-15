
use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# インデックスを更新 - strict
#-----------------------------------------------------------
sub index_file{

# 宣言
my($type,$moto,$thread_number) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # 処理タイプを展開
my(undef,undef,undef,$res_number,$new_handle,$new_bbs_title) = @_ if($type{'Regist-res'} || $type{'Regist-memo'});
my(undef,undef,undef,$new_key) = @_ if($type{'Thread-status-edit'});
my($hit_flag,$newline,@renew_line,@pin,$index_handler,$file_broken_flag,%self,$directory);
my $time = time;
	
	# 汚染チェック
	if($moto eq "" || $moto =~ /\W/){ return(); }
	if($thread_number =~ /\D/){ return(); }

# ファイル定義
my($bbs_path) = Mebius::BBS::path($moto);
	if($bbs_path->{'index_directory'}){ $directory = $bbs_path->{'index_directory'}; }
	else{ main::error("メニューを設定できません。"); }

	if($type =~ /Sub-index/){
			if($bbs_path->{'sub_index_file'}){ $self{'file'} = $bbs_path->{'sub_index_file'}; }
			else{ main::error("メニューを設定できません。"); }

	} else {
			if($bbs_path->{'index_file'}){ $self{'file'} = $bbs_path->{'index_file'}; }
			else{ main::error("メニューを設定できません。"); }
	}

# ファイルを読み込み
my($index_handler,$read_write) = Mebius::File::read_write($type,$self{'file'},$directory,$bbs_path->{'index_directory'});
	if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }	

chomp(my $top = <$index_handler>);
my($no2,$last_res_time2,$time2,$last_resed_postnumber,$bbs_title) = split(/<>/,$top);

	# 新規作成した場合
	if($read_write->{'file_touch_flag'}){
		$no2 = "0";
		$time2 = time;
	}

	# ファイル消失
	if($no2 eq ""){ $file_broken_flag = 1; }

	# エラー対策
	if($type{'Renew'} && ($no2 eq "" || $time2 eq "") && !$read_write->{'file_touch_flag'}) {
		$self{'file_broken_flag'} = 1;
		close($index_handler);
		main::error("インデックスデータが読み込めないため、書き込めません。もう一度試してください。");
	}

	# インデックスを展開
	while (<$index_handler>) {

		# 業を分解
		chomp;
		my($thread_number2,$thread_subject2,$res_number2,$post_handle2,$restime,$lasthandle,$key2) = split(/<>/);

		### 復元用
		if($type =~ /Repair-sub-index/){
			my($sub_thread) = Mebius::BBS::thread({ ReturnRef => 1 },"sub$moto",$thread_number2);
			$self{'repair_line'} .= "$thread_number2<>$thread_subject2<>$sub_thread->{'res'}<><>$sub_thread->{'lastrestime'}<>$sub_thread->{'lasthandle'}<>1<>\n";
		}

			# ハッシュを定義
			$self{'thread'}{$thread_number2}{'subject'} = $thread_subject2;
			$self{'thread'}{$thread_number2}{'res_number'} = $res_number2;
			$self{'thread'}{$thread_number2}{'last_regist_handle'} = $lasthandle;
			$self{'thread'}{$thread_number2}{'last_modified'} = $restime;

			# 更新した記事
			if($thread_number == $thread_number2) { 

				# ヒットした場合
				$hit_flag = 1;

					# 行を更新する場合
					if($type{'Regist-res'} && !$type{'Sub-thread'}){
						$res_number2 = $res_number;
						$restime = time;
						$lasthandle = $new_handle;
							# 自動ロック解除に伴う処理
							if($key2 eq "0"){ $key2 = 1; }
					}

					# メモ更新時
					if($type{'Regist-memo'}){
						$lasthandle = $new_handle;
					}

					# ステータス更新
					if($type{'Thread-status-edit'}){
						$key2 = $new_key;
					}

				# 書きこむ行を定義
				$newline = qq($thread_number<>$thread_subject2<>$res_number2<>$post_handle2<>$restime<>$lasthandle<>$key2<>\n);

					# ソートしない場合は、このまま行を更新
					if(!$type{'Sort-on'}){ push(@renew_line,$newline); }

			}

			# ピン止め記事
			elsif($key2 == 2) { push(@pin,"$_\n"); }

			# その他の記事
			else{ push(@renew_line,"$_\n"); }
	}

	# 記事が現行ログにない場合、修復
	if(!$hit_flag) {
			if(($type{'Regist-res'} && !$type{'Sub-thread'}) || $type{'Thread-status-edit'}){
				# 元記事を取得
				my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$moto,$thread_number);
				# 修復するハンドルネーム
				my $repair_handle = $new_handle;
					if($repair_handle eq ""){ $repair_handle = $thread->{'lasthandle'}; }
				# 修復するキー
				my $repair_key = $new_key;
					if($repair_key eq ""){ $repair_key = 1; }
				unshift(@renew_line,"$thread_number<>$thread->{'subject'}<>$thread->{'res'}<>$thread->{'posthandle'}<>$time<>$repair_handle<>1<>\n");
			}
		#&regist_error("▼この記事は過去ログにあるか、インデックスに存在しません。<br>");
	}

	# 新しい行を追加 ( ソートありの場合 )
	if($type{'Sort-on'}){ unshift(@renew_line,$newline); }

	# ピン止め記事を追加
	if(@pin > 0){ unshift(@renew_line,@pin); }

	# 最終レスのあった記事番号を更新 (トップデータ内)
	if($type{'Regist-res'} && $type{'Sort-on'}){
		$last_resed_postnumber = $thread_number;
	}

	# トップデータを更新
	if($type{'Regist-res'}){
		$last_res_time2 = time;
			if($new_bbs_title){ $bbs_title = $new_bbs_title; }
	}

# トップデータを追加
unshift(@renew_line,"$no2<>$last_res_time2<>$time2<>$last_resed_postnumber<>$bbs_title<>\n");

	# ファイル更新
	if($type{'Renew'} && !$file_broken_flag){
		seek($index_handler,0,0);
		truncate($index_handler,tell($index_handler));
		print $index_handler @renew_line;
	}

# ファイルを閉じる
close($index_handler);

	# パーミッション変更
	if($type{'Renew'}){ Mebius::Chmod(undef,$self{'file'}); }

	# 一定確率でバックアップ (新)
	if($type{'Renew'} && !$file_broken_flag && (rand(25) < 1 || Mebius::AlocalJudge())){
		Mebius::make_backup($self{'file'});
	}

\%self;

}

1;

