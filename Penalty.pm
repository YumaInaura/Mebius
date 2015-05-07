
use strict;
use Mebius::PenaltyUTF8;
use Mebius::Export;
package Mebius;


#-----------------------------------------------------------
# ペナルティファイルを処理
#-----------------------------------------------------------
sub penalty_file{

# 宣言１
my($basic_init) = Mebius::basic_init();
my($type,$file,$newsubject,$newcomment,$newurl,$new_penalty_count,$newpenalty_reason) = @_;
my(undef,$select_file_direct) = @_ if($type =~ /Select-file-direct/);
my(undef,undef,$nowaccess_type) = @_ if($type =~ /Axscheck/);
my(undef,undef,%renew) = @_ if($type =~ /Renew-hash|Use-renew-hash/);
my(%penalty);	# ( A )
(undef,undef,undef,%penalty) = @_ if($type =~ /Relay-hash/); # ( B )
my($file2,$filehandle1,$logfile,$encfile,@renew_line);
my($denymin,$directory,@top_line,$i,%flag);
my($share_directory) = Mebius::share_directory_path();
my($init_directory) = Mebius::BaseInitDirectory();

# ペナルティの最高秒数 ( 現在二週間 )
my $max_long_penalty_second = 2*7*24*60*60;

# 最大記録行数
my $max_line = 25;

	if($type =~ /UTF8/){
		shift_jis($newpenalty_reason);
	}

	# ペナルティをつける個数
	if(!$new_penalty_count){ $new_penalty_count = 1; }

	# ファイル定義がない場合、自動的に代入
	if($type =~ /Select-auto-file/ && $type !~ /(Account|Cnumber|Host|Isp|Agent|Addr|Second-domain)/){
		#my($my_account) = Mebius::my_account();
		#my($get_host) = Mebius::GetHostWithFile();
		#my($access) = Mebius::my_access();
			if($main::kaccess_one){
				$file = $main::agent;
				$type .= qq( Agent);
			}
			elsif($main::myaccount{'file'}){
				$file = $main::myaccount{'file'};
				$type .= qq( Account);
			}
			elsif($main::cnumber){
				$file = $main::cnumber;
				$type .= qq( Cnumber);
			}
			elsif($main::host){
				$file = $main::host;
				$type .= qq( Host);
			}
	}

	# リターン
	if($file eq ""){ return(%penalty); }

# 基本ファイル名定義
($encfile) = Mebius::Encode("",$file);

	# ●ハッシュをリレーする場合、特定のもの以外はすべて削除
	if($type =~ /Relay-hash/){
			foreach(keys %penalty){
				if($_ !~ /^(Block|Penalty|Hash)->/){ $penalty{$_} = undef; }
			}
	}

	# ●ファイル定義
	# アカウント
	if($type =~ /Account/){
		$penalty{'file_type'} = "Account";
		$directory = "${share_directory}_ip/_data_account/";
		$logfile = "${directory}$encfile.cgi";
	}
	# クッキー
	elsif($type =~ /Cnumber/){
		$penalty{'file_type'} = "Cnumber";
		$directory = "${share_directory}_ip/_data_number/";
		$logfile = "${directory}$encfile.cgi";
	}
	# IPアドレス
	elsif($type =~ /Addr/){
		$penalty{'file_type'} = "Addr";
		$directory = "${share_directory}_ip/_data_addr/";
		$logfile = "${directory}$encfile.cgi";
	}
	# ホスト名
	elsif($type =~ /Host/){

		# 携帯ホストの場合はリターン
		my($host_type) = Mebius::HostType({ Host => $file });
			if($host_type->{'type'} eq "Mobile"){ return(%penalty); }

		$penalty{'file_type'} = "Host";
		$directory = "${share_directory}_ip/_data_host/";
		$logfile = "${directory}$encfile.cgi";
	}
	# ISP
	elsif($type =~ /Isp/){
		$penalty{'file_type'} = "Isp";
		$directory = "${share_directory}_ip/_data_isp/";
		$logfile = "${directory}$encfile.cgi";
	}
	# レベル２ドメイン
	elsif($type =~ /Second-domain/){
		$penalty{'file_type'} = "Second-domain";
		$directory = "${share_directory}_ip/_data_second_domain/";
		$logfile = "${directory}$encfile.cgi";
	}
	# ユーザーエージェント / 個体識別番号
	elsif($type =~ /Agent/){

		# 携帯以外のユーザーエージェントの場合はリターン
		my($real_device) = Mebius::device({ UserAgent => $file });
			if($real_device->{'mobile_uid'}){
				$penalty{'file_type'} = "Kaccess_one";
				$directory = "${share_directory}_ip/_data_kaccess_one/";
				($encfile) = Mebius::Encode("","$real_device->{'mobile_uid'}_$real_device->{'mobile_id'}");
				$logfile = "${directory}$encfile.cgi";
			}
			elsif($real_device->{'mobile_id'}){
				$penalty{'file_type'} = "Kaccess";
				$directory = "${share_directory}_ip/_data_agent/";
				($encfile) = Mebius::Encode("",$file);
				$logfile = "${directory}$encfile.cgi";
			}
			else{ return(%penalty); }
	}

	# ファイルを直接指定する場合
	elsif($type =~ /Select-file-direct/){
		$logfile = $select_file_direct;
	}

	# タイプ定義がない場合
	else{ return(%penalty); }

# ファイル開く
open($filehandle1,"<",$logfile) || ($penalty{'file_nothing_flag'} = 1);

	# ファイルロック
	if($type =~ /Renew/){ flock($filehandle1,1); }

# トップデータを分解
chomp(my $top1 = <$filehandle1>);
chomp(my $top2 = <$filehandle1>);
chomp(my $top3 = <$filehandle1>);
chomp(my $top4 = <$filehandle1>);
chomp(my $top5 = <$filehandle1>);
chomp(my $top6 = <$filehandle1>);
chomp(my $top7 = <$filehandle1>);
chomp(my $top8 = <$filehandle1>);
chomp(my $top9 = <$filehandle1>);
chomp(my $top10 = <$filehandle1>);

($penalty{'count'},$penalty{'allcount'},$penalty{'lasttime'},$penalty{'penalty_time'},$penalty{'deleted_subject'},undef,$penalty{'deleted_url'},undef,$penalty{'deleted_comment'},undef,undef,undef,undef,$penalty{'deleted_reason'}) = split(/<>/,$top1);
($penalty{'block'},$penalty{'block_time'},$penalty{'block_reason'},$penalty{'block_decide_man'},$penalty{'block_decide_time'},$penalty{'block_count'},$penalty{'block_bbs'}) = split(/<>/,$top2);
($penalty{'allow_host'},$penalty{'from_other_site_time'},$penalty{'from_other_site_url'}) = split(/<>/,$top3);
($penalty{'concept'}) = split(/<>/,$top4);
($penalty{'exclusion_block'}) = split(/<>/,$top5);
my @user_agent_match_for_block = split(/<>/,$top6); # 第三引数を -1 には”しない”でおく ( 全てが空値の場合も配列個数が生まれてしまう、joinがうまく作動しない )
$penalty{'user_agent_match_for_block'} = \@user_agent_match_for_block;
($penalty{'block_report_time'},$penalty{'must_compare_xip_flag'}) = split(/<>/,$top7);

	# ファイルを展開
	while(<$filehandle1>){

		# ラウンドカウンタ
		$i++;

		# 行を分解
		chomp;
		my($key2,$handle2,$url2,$comment2,$subject2,$deleted_time2) = split(/<>/,$_);

			# インデックスを取得
			if($type =~ /Get-deleted-index/){

					if($i >= 2){
						$penalty{'index_line'} .= qq(<hr$main::xclose>);
					}
					my($date_deleted) = Mebius::get_date($deleted_time2);
					my($how_before_deleted) = shift_jis(Mebius::second_to_howlong({ ColorView => 1 , GetLevel => "top" , HowBefore => 1 } , time - $deleted_time2));

				$penalty{'index_line'} .= qq(<div class="deleted_history"><a href="$url2">$url2</a> ( $subject2 )　 削除時間 : $how_before_deleted 　 ( $date_deleted->{'date'} ) <br$main::xclose> <br$main::xclose> $comment2 </div>);
			}

			# 更新行を追加
			if($type =~ /Renew|Check-penalty/){

					# 最大行数に達した場合
					if($i > $max_line){ last; }

				# 更新行を追加
				push(@renew_line,"$key2<>$handle2<>$url2<>$comment2<>$subject2<>$deleted_time2<>\n");
			}
	}

close($filehandle1);

# 第二分解 ( 投稿制限データを分解 )
#($penalty{'block_reason'},$penalty{'block_time'},$penalty{'block_decide_man'}) = split(/>/,$penalty{'blockdata'});

	# ●ハッシュ調整
	# ファイル名
	$penalty{'logfile'} = $logfile;

	# 時間がブロック中の場合
	if($penalty{'block'} && ($penalty{'block_time'} >= time || !$penalty{'block_time'})){ $penalty{'block_time_flag'} = 1; }
	# ペナルティ中の場合
	if($penalty{'penalty_time'} > time){ $penalty{'penalty_flag'} = 1; }
	# ペナルティはついていないが、管理者削除を知らせる場合
	if($penalty{'lasttime'} && time < $penalty{'lasttime'} + 24*60*60){ $penalty{'tell_flag'} = 1; }
	# ホスト名の許可
	if($penalty{'allow_host'} eq "Allow"){ $penalty{'allow_host_flag'} = 1; }
	# 外部経由状態の時間判定
	if(time < $penalty{'from_other_site_time'} + (3*24*60*60)){
		$penalty{'from_other_site_flag'} = 1;
	}

	# 削除場所リンク
	$penalty{'deleted_link'} = qq(<a href="$penalty{'deleted_url'}">$penalty{'deleted_subject'}</a>);
	# 対象となった番号名など
	$penalty{'file'} = $file;


	# ●共通ハッシュの代入、定義
	if($type =~ /Relay-hash/){
			if($penalty{'from_other_site_time'} > $penalty{'Hash->from_other_site_time'}){
				$penalty{'Hash->from_other_site_time'} = $penalty{'from_other_site_time'};
				$penalty{'Hash->from_other_site_url'} = $penalty{'from_other_site_url'};
				$penalty{'Hash->from_other_site_file_type'} = $penalty{'file_type'};
				$penalty{'Hash->from_other_site_flag'} = $penalty{'from_other_site_flag'};
			}
	}

	# ●ユーザー投稿→アクセス制限の判定
	if($type =~ /Axscheck/){

			# 各種データを取得
			my($access) = Mebius::my_access();

			# ●投稿制限の判定

			# 制限の回避
			if($penalty{'exclusion_block'} && $type !~ /(Isp)/){
				$penalty{'Block->exclusion_block_flag'} = 1;
			}

			# 個別制限を判定
			if($penalty{'block_bbs'} && $main::moto){
					foreach(split(/ /,$penalty{'block_bbs'})){
							if($_ eq $main::moto){
									$penalty{'block_bbs_flag'} = 1;
									$penalty{'block_flag'} = 1;
									$penalty{'block_type_text'} = qq(一部のコンテンツ);
								}
					}
			}

			# 強力な投稿制限
			if($penalty{'block'} eq "2"){
				$penalty{'block_flag'} = 1;
				$penalty{'block_type_text'} = qq(すべての場所);
			}
			# 普通の投稿制限
			elsif($penalty{'block'} eq "1" && $nowaccess_type !~ /User-report-send/){
				$penalty{'block_flag'} = 1;
				$penalty{'block_type_text'} = qq(すべての場所 ( 質問板/削除依頼板をのぞく ));
			}
			# アカウントのみの制限
			elsif($penalty{'block'} eq "3" && $nowaccess_type =~ /ACCOUNT/){
				$penalty{'block_flag'} = 1;
				$penalty{'block_type_text'} = qq(アカウント関連);
			}

			# アカウント作成の制限
			elsif($penalty{'concept'} =~ /Block-make-account/ && $nowaccess_type =~ /Make-account/){
				$penalty{"Block->block_make_account_flag"} = 1;
			}

			# 解除期限を過ぎている場合
			if($penalty{'block_time'} && time >= $penalty{'block_time'}){
				$penalty{'block_flag'} = 0;
			}

			# UA条件が設定されており、マッチしない場合は投稿制限を回避
			if(@user_agent_match_for_block >= 1){
				my($match_flag);
					foreach (@user_agent_match_for_block){
						my($select_user_agent_decoded) =  Mebius::Decode(undef,$_);
							if($access->{'multi_user_agent'} =~ /\Q$select_user_agent_decoded\E/){ $match_flag = 1 ; }
					}
					if(!$match_flag){ $penalty{'block_flag'} = 0; }
			}

			# ▼違反報告の送信制限
			if($penalty{'block_report_time'} && time < $penalty{'block_report_time'} && $nowaccess_type =~ /User-report-send/){
				my($howlong) = shift_jis(Mebius::second_to_howlong({ TopUnit => 1 } , $penalty{'block_report_time'} - time));
				$penalty{'block_flag'} = 1;
				$penalty{'block_type_text'} = qq(違反報告の送信);
				$penalty{'block_message'} = qq(不適切な報告が多いため、しばらく送信できません。[ あと).e($howlong).qq( ] );
			}

			# ▼投稿制限中の場合、エラーメッセージを定義
			elsif($penalty{'block_flag'}){

				# 局所化
				my($block_message);

				# 解除日の表示
				my($left_date) = Mebius::SplitTime("Get-till-day",$penalty{'block_time'} - time + (24*60*60));

				# 制限タイプ
				$penalty{'block_file_type'} = $penalty{'file_type'};

				# 最初の文章
				$block_message .= qq(▼<a href="${main::guide_url}%C5%EA%B9%C6%C0%A9%B8%C2">申\し訳ありませんが、投稿制限中のため送信できません。</a><br>);
				$block_message .= qq(　対象： [ $penalty{'block_type_text'} ]<br>);
					if($main::myadmin_flag >= 5){ $block_message .= qq(　制限タイプ： [ $penalty{'file_type'} ] ( 管理者用の表\示 )<br$main::xclose>); }

					# 投稿制限の理由がある場合
					if($penalty{'block_reason'}){
						require "${init_directory}part_delreason.pl";
						my($block_reason_text) = main::delreason($penalty{'block_reason'},"SUBJECT");
						$block_message .= qq(　制限理由： [ $block_reason_text ]<br>);
					}

					# 解除時刻がある場合
					if($penalty{'block_time'}){
						$block_message .= qq(　解除日： [ $left_date後 ]<br>);
						$block_message .= qq(　　※正式な解除日までは、いかなる方法でも [ $penalty{'block_type_text'} ] への書き込みはご遠慮ください。<br>);
					}
					# 解除時刻がない場合
					else{
						$block_message .= qq(　解除日： [ 無期限 ] <br>);
						$block_message .= qq(　　※いかなる方法でも [ $penalty{'block_type_text'} ] への書き込みはご遠慮ください。<br>);
					}

					# 広域制限の場合のメッセージ
					if($type =~ /Isp/){
							$block_message .= qq(　広域制限 … 本サイトでは荒らし、迷惑行為防止のため、広い範囲での制限をおこなわせていただく場合があります。);
							$block_message .= qq(　この場合、利用環境によっては、他のユーザー様と一緒に制限がかかってしまうが場合があります。);
							$block_message .= qq(　もし巻き添えで制限がかかっていると思われる場合は、お手数ですが $basic_init->{'mailform_link'} よりご連絡下さい。<br>);
					}

				# 警告文章
				$block_message .= qq(　　<strong style="color:#f00;">※違反行為が多い場合や重大な場合は、あなたの<a href="${main::guide_url}%A5%D7%A5%ED%A5%D0%A5%A4%A5%C0%CF%A2%CD%ED">プロバイダ</a> $main::host を通してご自宅や会社、学校などに連絡させていただく場合があります。</strong><br>);

					# 国外からのアクセスの場合
					unless($main::host =~ /\.jp$/ || $main::host =~ /\.bbtec\.net$/){
						$block_message .= qq(　国外からのアクセスでも、同じです。<br>);
					}

					# Googleモバイル検索 && 制限中の場合、エスケープページを表示
					if($main::k_access eq "MOBILE"){
						$block_message .= qq(※[ 一律制限 ] Google検索/Yahoo検索を通してアクセスしているため、送信できません。 http://$main::server_domain/ のＵＲＬを携帯で直接入力するか、<a href="mailto:?subject=MEBI-URL&body=http://$main::server_domain/">自分宛にメール送信</a>してメール画面からアクセスしなおしてください。<br>);
					}


				$penalty{'block_message'} = $block_message;

			}


			# ▼全ての種類のファイルの中で、最大制限時間などを覚えておく
			if($type =~ /Relay-hash/ && $penalty{'block_flag'} && ($penalty{'block_time'} > $penalty{'Block->block_time'} || !$penalty{'block_time'} || $penalty{'block_bbs_flag'})){
					foreach(keys %penalty){
							if($_ !~ /^(Block|Penalty)->/){ $penalty{"Block->$_"} = $penalty{$_}; }
					}
			}
	}

	# ●ペナルティー判定
	if($type =~ /Check-penalty/){

			# ▼全タイプのペナルティをチェックする場合
			if($main::bbs{'concept'} =~ /Strong-penalty/){
				$penalty{'strong_check_flag'} .= qq( 掲示板の強制限モード);
			}
			if($penalty{'pure_cookie_penalty_flag'}){
				$penalty{'strong_check_flag'} .= qq( PureCookieの値);
			}
			elsif($penalty{'Penalty->penalty_flag'}){
				$penalty{'strong_check_flag'} .= qq( 他のファイル ( $penalty{'Penalty->penalty_file_type'} ) でペナルティ中);
			}
			if($penalty{'block_flag'} || $penalty{'Penalty->block_flag'}){
				$penalty{'strong_check_flag'} .= qq( 投稿制限 ( $penalty{'Penalty->block_file_type'} ) と一緒に);
			}

			# ▼Cnumberの投稿履歴ファイルが存在するかどうかを調べる
			if($type =~ /Cnumber/){
				require "${main::int_dir}part_history.pl";
				my(%history_cnumber) = main::get_reshistory("Get-hash CNUMBER",$file);
					if($history_cnumber{'f'}){ $penalty{'Penalty->cnumber_f_flag'} = 1; }
			}

			# ▼ホスト判定のペナルティ表示を回避する場合 （ ペナルティ付与自体は、常におこなう ） 
			if($type =~ /Host/){
					# クッキー管理番号での投稿履歴ファイルが存在しない場合は、ホスト名もチェックする
					if(!$penalty{'Penalty->cnumber_f_flag'}){
						$penalty{'strong_check_flag'} .= qq( Cnumber投稿履歴ファイルが存在しない);
					}
					# クッキー管理番号での投稿履歴ファイルが存在する場合は、ホスト名でチェックしない
					if(!$penalty{'strong_check_flag'}){
						$penalty{'escape_flag'} = 1;
					}
			}

#if($type =~ /Account/){ main::error("$top");
# }

			# ▼最近の削除回数がある場合、ペナルティを追加
			if($penalty{'count'} >= 1){

				# ファイル更新フラグを立てる
				$type .= qq( Renew);

				# 新しい更新を記憶する
				$penalty{'Penalty->new_penalty_flag'} = 1;

					# １削除あたり、付与するペナルティ時間を計算
					if($penalty{'allcount'} >= 20){ $denymin = 3*24*60; }
					elsif($penalty{'allcount'} >= 10){ $denymin = 2*24*60; }
					elsif($penalty{'allcount'} >= 5){ $denymin = 1*24*60; }
					else{ $denymin = 12*60; }

					# 既にペナルティ中の場合、ペナルティ時間を加算する
					if($penalty{'penalty_flag'}){
						$penalty{'penalty_time'} += $denymin*60 * $penalty{'count'};
					}
					# ペナルティ中でない場合、新しくペナルティ時間を設定する
					else{
						$penalty{'penalty_time'} = time + ($denymin*60 * $penalty{'count'});
					}

					# １回あたりのペナルティ時間の上限を定義
					if($penalty{'penalty_time'} > time + $max_long_penalty_second){
						$penalty{'penalty_time'} = time + $max_long_penalty_second;
					}

					# 最近の削除回数をゼロにする
					$penalty{'count'} = 0;

			}

			# ▼Cookieのみで制限する場合
			if($type =~ /Cnumber/ && $main::cdelres > $penalty{'penalty_time'} && !Mebius::alocal_judge() && !$main::myadmin_flag && time >= 1367038772 + 2*7*24*60*60){
				$penalty{'penalty_time'} = $main::cdelres - 1;
				$penalty{'file_type'} = "Cookie-pure";
			}

			# ▼ファイルのペナルティ時間で最大のものを、クッキーセットの値として定義
			elsif($penalty{'penalty_time'} >= $penalty{'Penalty->set_cdelres_time'}){
				$penalty{'Penalty->set_cdelres_time'} = $penalty{'penalty_time'};
			}

			# ▼結果的に、ペナルティ中の場合
			if($penalty{'penalty_time'} > time && !$penalty{'escape_flag'}){

				# ペナルティ中フラグを再定義
				$penalty{'penalty_flag'} = 1;
				$penalty{'penalty_file_type'} = $penalty{'file_type'};

				# 管理者用のメッセージを定義
				$penalty{'check_message'} .= qq( - $penalty{'penalty_file_type'} ( $file ));
				$penalty{'check_message'} .= qq( $penalty{'strong_check_flag'} );

					# ▼全ての種類のファイルの中で、最大ペナルティ時間を覚えておく
					if($type =~ /Relay-hash/ && $penalty{'penalty_time'} > $penalty{'Penalty->penalty_time'}){
							foreach(keys %penalty){
									if($_ !~ /^(Block|Penalty)->/){ $penalty{"Penalty->$_"} = $penalty{$_}; }
							}
					}

			}


	}

	# ●管理者削除→ペナルティ追加用
	if($type =~ /(Penalty|Repair|New-delete)/ && $type =~ /Renew/){

			# ▼投稿復活でペナルティを減らす
			if($type =~ /Repair/){
				$penalty{'count'} -= $new_penalty_count;
				$penalty{'allcount'} -= $new_penalty_count;
			}

			# ▼投稿削除でペナルティを増やす
			elsif($type =~ /Penalty/){
				$penalty{'count'} += $new_penalty_count;
				$penalty{'allcount'} += $new_penalty_count;
			}

			# ▼ペナルティなし、普通の削除の場合
			else{
					# 最近の削除回数があったり、既にペナルティ中は、削除情報を入れ替えない ( このままリターン )
					if($penalty{'count'} >= 1){ $type =~ s/(\s)?Renew//g; }
					if($penalty{'penalty_time'} && time < $penalty{'penalty_time'}){ $type =~ s/(\s)?Renew//g; }
			}

			# 削除カウントを調整 ( マイナス値にならないように )
			if($penalty{'allcount'} < 0){ $penalty{'allcount'} = 0; }

			# 引継ぎ値がない場合は、記事名などを変更しない
			if($newsubject eq ""){ $newsubject = $penalty{'deleted_subject'}; }
			if($newurl eq ""){ $newurl = $penalty{'deleted_url'}; }

		# 更新する値
		$penalty{'lasttime'} = time;
		$penalty{'deleted_subject'} = $newsubject;
		$penalty{'deleted_url'} = $newurl;
		$penalty{'deleted_comment'} = $newcomment;
		$penalty{'deleted_reason'} = $newpenalty_reason;

	}

	# 削除履歴を追加
	if($type =~ /Penalty/){

		# 更新行を追加
		unshift(@renew_line,"<><>$newurl<>$newcomment<>$newsubject<>$main::time<>\n");

	}

	# ●ファイルを更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,${directory});

			# ハッシュを一斉更新
		my($renew) = Mebius::Hash::control(\%penalty,\%renew);

		# 不正な文字を削除
		($renew) = Mebius::format_data_for_file($renew);

		# 更新する行
		push(@top_line,"$renew->{'count'}<>$renew->{'allcount'}<>$renew->{'lasttime'}<>$renew->{'penalty_time'}<>$renew->{'deleted_subject'}<><>$renew->{'deleted_url'}<><>$renew->{'deleted_comment'}<><><><><>$renew->{'deleted_reason'}<>\n");
		push(@top_line,"$renew->{'block'}<>$renew->{'block_time'}<>$renew->{'block_reason'}<>$renew->{'block_decide_man'}<>$renew->{'block_decide_time'}<>$renew->{'block_count'}<>$renew->{'block_bbs'}<>\n");
		push(@top_line,"$renew->{'allow_host'}<>$renew->{'from_other_site_time'}<>$renew->{'from_other_site_url'}<>\n");
		push(@top_line,"$renew->{'concept'}<>\n");
		push(@top_line,"$renew->{'exclusion_block'}<>\n");

			{
				my $push = join "<>" , @{$renew->{'user_agent_match_for_block'}};
				push(@top_line,"$push<>\n");
			}

		# 以下の行部分もすべて、削除禁止
		push(@top_line,"$renew->{'block_report_time'}<>$renew->{'must_compare_xip_flag'}<>\n");
		push(@top_line,"<>\n");
		push(@top_line,"<>\n");
		push(@top_line,"<>\n");

		# トップデータを本データに結合
		unshift(@renew_line,@top_line);

		# ファイル更新
		Mebius::Fileout("",$logfile,@renew_line);
	}

	# フラグを立てる
	if($type =~ /Get-flag/){

			if($penalty{'block'} || $penalty{'block_bbs'} =~ /\w/){
						# 何らかの形で無期限の投稿制限中の場合
						if($penalty{'block_time'} eq ""){
								$flag{'some_block'} = 1;
							$flag{'some_indefinite_block'} = 1;
						}
						# 何らかの形で投稿制限中の場合
						if($penalty{'block_time'} && $penalty{'block_time'} && time < $penalty{'block_time'}){
							$flag{'some_block'} = 1;
						}
					
			}

			$penalty{'Flag'} = \%flag;
	}

# リターン
return(%penalty); 

}

#-----------------------------------------------------------
# ＵＡから判定 ( 現在は未利用? )
#-----------------------------------------------------------
sub Checkdevice_fromagent{

# 局所化
my($type,$file) = @_;
my($adevice_type,$select_dir,$k_access,$kaccess_one);

# ＵＡから $k_access を判定
if($file =~ /(^DoCoMo)/){ $k_access = "DOCOMO"; }
if($file =~ /(^KDDI|^UP\.Browser)/){ $k_access = "AU"; }
if($file =~ /(^SoftBank|^Vodafone|^J-PHONE)/){ $k_access = "SOFTBANK"; }

# KACCESS_ONE
if($file =~ /^DoCoMo([a-zA-Z0-9 ;\(\/\.]+?);ser([0-9a-z]{15});/){
$k_access = "DOCOMO";
$kaccess_one = $2;
}

if($file =~ /^([0-9]+)_([a-z]+)\.ezweb\.ne\.jp$/){
$kaccess_one = "${1}_${2}";
$k_access="AU";
}

if($file =~ /\/SN([0-9]+)/){
$kaccess_one = $1;
$k_access="SOFTBANK";
}

if($type =~ /Account/){ $adevice_type = "account"; $select_dir = "_data_account/"; }
elsif($type =~ /Isp/){ $adevice_type = "isp"; $select_dir = "_data_isp/"; }
elsif($kaccess_one){ $adevice_type = "kaccess_one"; $select_dir = "_data_kaccess_one/"; }
elsif($file =~ /^([a-zA-Z0-9\.\-]+)\.([a-z]{2,3})$/ || $file eq "localhost"){ $adevice_type = "host"; $select_dir = "_data_host/"; }
elsif($file =~ /^([a-zA-Z0-9]+)$/){ $adevice_type = "number"; $select_dir = "_data_number/"; }
else{ $adevice_type = "agent"; $select_dir = "_data_agent/"; }

return($adevice_type,$select_dir,$k_access,$kaccess_one);

}


#-----------------------------------------------------------
# SNSのペナルティ作成
#-----------------------------------------------------------
sub Authpenalty{

# 宣言
my($type,$account,$comment,$subject,$url) = @_;
my(%onedata,$plustype_penalty);
my($init_directory) = Mebius::BaseInitDirectory();

# 汚染チェック
$account =~ s/[^0-9a-z]//g;
if($account eq ""){ return(); }

	# タイプ定義
	if($type =~ /Penalty/){
		$plustype_penalty .= qq( Penalty);
	}
	elsif($type =~ /Repair/){
		$plustype_penalty .= qq( Repair);
	}
	else{
		return();
	}

# 取り込み処理
require "${init_directory}part_idcheck.pl";

	# アカウントのアクセス履歴を取得
	(%onedata) = Mebius::Login->login_history("Onedata",$account);

	# ペナルティ作成
	if($account){
		Mebius::penalty_file("Account Renew $plustype_penalty",$account,$subject,$comment,$url);
	}

	# ペナルティ作成
	if($onedata{'host'}){
		Mebius::penalty_file("Host Renew $plustype_penalty",$onedata{'host'},$subject,$comment,$url);
	}

	# ペナルティ作成
	if($onedata{'agent'}){
		Mebius::penalty_file("Agent Renew $plustype_penalty",$onedata{'agent'},$subject,$comment,$url);
	}

	# ペナルティ作成
	if($onedata{'cnumber'}){
		Mebius::penalty_file("Cnumber Renew $plustype_penalty",$onedata{'cnumber'},$subject,$comment,$url);
	}

}

#-----------------------------------------------------------
# 全ペナルティ
#-----------------------------------------------------------
sub PenaltyAll{

# 宣言
my($type,$relay_type,$account,$host,$agent,$cnumber,%renew) = @_;

	# ファイル処理
	if($account){
		Mebius::penalty_file("Account $relay_type",$account,%renew);
	}

	# ファイル処理
	if($host){
		Mebius::penalty_file("Host Renew $relay_type",$host,%renew);
	}

	# ファイル処理
	if($agent){
		Mebius::penalty_file("Agent Renew $relay_type",$agent,%renew);
	}

	# ファイル処理
	if($cnumber){
		Mebius::penalty_file("Cnumber Renew $relay_type",$cnumber,%renew);
	}



}

#-----------------------------------------------------------
# まとめてペナルティを与える
#-----------------------------------------------------------
sub add_penalty_all{

my $use = shift if(ref $_[0] eq "HASH");
my($relay_type,$host,$cookie_char,$user_agent,$account,@other) = @_;

	if($cookie_char){

		Mebius::penalty_file("Cnumber $relay_type",$cookie_char,@other);
	}
	if($host){
		Mebius::penalty_file("Host $relay_type",$host,@other);
	}
	if($user_agent){
		Mebius::penalty_file("Agent $relay_type",$user_agent,,@other);
	}
	if($account){
		Mebius::penalty_file("Account $relay_type",$account,@other);
	}

}



#-----------------------------------------------------------
# アカウント本体にペナルティを与える
#-----------------------------------------------------------
sub AuthPenaltyOption{

my($type,$account,$penalty_plus_time) = @_;
my(%renew_account);

# アカウントデータを取得
my(%account) = Mebius::Auth::File("Get-hash Option",$account);

	# ●ペナルティを与える
	if($penalty_plus_time >= 1){

			# まだペナルティ中の場合、時間を加算
			if($account{'penalty_time'} > time){
				$renew_account{'penalty_time'} = $account{'penalty_time'} + $penalty_plus_time;
			}
			# ペナルティがない場合、普通に時間を加算
			else{
				$renew_account{'penalty_time'} = time + $penalty_plus_time;
			}
	}

	# ●ペナルティを減らす、解除する
	elsif($penalty_plus_time <= -1){
			$renew_account{'penalty_time'} = $account{'penalty_time'} + $penalty_plus_time;
	}

	# オプションファイルを更新
	#Mebius::Auth::Optionfile("Renew",$account{'file'},%renew_account);

	# アカウントを更新
	Mebius::Auth::File("Renew Option",$account{'file'},\%renew_account);

}

#-----------------------------------------------------------
# 削除お知らせページ
#-----------------------------------------------------------
sub TellPenaltyView{

# 宣言
my($type,$penalty) = @_;
my($top,$line,$denymin,$text,$text2,$deleted_text);
my($type,$host);
my($file,$file2,$file3,$select_dir,$pri_com);
my($count,$allcount,$btime,$oktime,$d_sub,$d_no,$d_res,$d_com,$textarea,$move);

# タイトル
$main::sub_title = "ペナルティのお知らせ";
$main::head_link3 = " &gt; ペナルティのお知らせ";

# CSS定義
$main::css_text .= qq(
.deleted{padding:1em;border:1px solid #000;}
.comarea{width:95%;height:100px;}
.big{font-size:140%;}
h1{font-size:150%;color:#f00;}
li{line-height:1.4;}
div.about{line-height:1.4;}
ul.delguide{border:solid 1px #f00;padding:1em 2em;font-size:90%;color:#f00;margin: 1em 0em;}
);

# 携帯版の場合
if($main::in{'k'}){ main::kget_items(); }

	# ペナルティが無い場合
	#if(!$penalty->{'max_penalty_flag'}){ main::error("現在、ペナルティはありません。"); }

	# 削除理由
	if($penalty->{'Penalty->penalty_reason'}){
		$deleted_text .= qq(<strong style="color:#f00;">削除理由：</strong><br$main::xclose><br$main::xclose>);
		$deleted_text .= qq(　 $penalty->{'Penalty->penalty_reason'}<br$main::xclose><br$main::xclose>);
	}

	# 削除ページの題名表示を定義
	if($penalty->{'Penalty->deleted_link'}){
		$deleted_text .= qq(<strong style="color:#f00;">削除場所：</strong><br$main::xclose><br$main::xclose>);
		$deleted_text .= qq(　 $penalty->{'Penalty->deleted_link'}<br$main::xclose><br$main::xclose>);
	}


	# 削除された文章を定義
	if($penalty->{'Penalty->deleted_comment'}){
		$pri_com = $penalty->{'Penalty->deleted_comment'};
		$deleted_text .= qq(<strong style="color:#f00;">削除された文章：</strong>);
	}

	# 残り時間を定義
	my($lefttime_split) = Mebius::SplitTime(undef,($penalty->{'Penalty->penalty_time'}-time));

	# ログを取る
	Mebius::AccessLog(undef,"Penalty","残り時間：$lefttime_split / タイプ： $penalty->{'Penalty->check_message'} ");

	# URL調整
	if($penalty->{'url'} !~ /(^http|^\/)/){ $penalty->{'url'} = qq(/$penalty->{'url'}); }
	if($pri_com){ $deleted_text .= qq(<br$main::xclose><br$main::xclose>$pri_com); }

	# 投稿内容がある場合
	if($main::in{'comment'} || $main::in{'prof'}){
		my $com = $main::in{'comment'};
			if($com eq ""){ $com = $main::in{'prof'}; }
		$com =~ s/<br>/\n/g;
		$textarea = qq(<h2>送信内容（書き込まれていません）</h2><textarea class="comarea" cols="25" rows="5">$com</textarea><br$main::xclose>);

	}

my $view_filetype = qq( $penalty->{'Penalty->check_message'} ) if($main::myadmin_flag || $main::alocal_mode);
my $h1 = qq(<h1$main::kstyle_h1>エラー： 送信できませんでした $view_filetype</h1>);

# 表示する文章を定義
$text .= qq(
$h1
<h2 id="TELL"$main::kstyle_h2>ペナルティについて</h2>
<div class="about line-height">
管理者削除（ または管理者の設定 ）により、しばらく送信できません。$move<br$main::xclose>
申\し訳ありませんが、次まで <strong class="red">$lefttime_split</strong> ほどお待ちください。

<div class="deleted margin">
$deleted_text
</div>

<ul class="delguide">
<li>削除回数が多いと、ペナルティが重くなったり、投稿制限がかかってしまう場合があります。</li>
<li>詳しくは<a href="${main::guide_url}%BA%EF%BD%FC%A5%DA%A5%CA%A5%EB%A5%C6%A5%A3%A3%D1%A1%F5%A3%C1">削除ペナルティＱ＆Ａ</a>をご覧ください。</li>
</ul>
</div>

$textarea
<br$main::xclose>
);


Mebius::Template::gzip_and_print_all({},$text);

exit;

}



1;

