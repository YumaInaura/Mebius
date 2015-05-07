
use strict;
use Mebius::RenewStatus;
package Mebius::Auth;
use Mebius::Export;

#──────────────────────────────
# マイメビの一覧
#──────────────────────────────
sub FriendIndex{

# 局所化
my($type,$account) = @_;
my(undef,undef,%my_friend) = @_ if($type =~ /Get-index/);
my(undef,undef,$other_friend_account) = @_ if($type =~ /Tell-new-friend|Tell-cancel-friend/);
my(undef,undef,%renew) = @_ if($type =~ /Renew/);
my(undef,undef,@relay_diary) = @_ if($type =~ /New-diary|Delete-diary/);
my($FILE1,$index_line,$i_index,$hit_index,@index_line,@renew_line,$friend_num,%other_friend);
my(%account,$hit_all_index,$flow_flag,%self,@log_line,%self,%renew_self,$renew);
my($my_account) = Mebius::my_account();
my $time = time;

	# 汚染チェック
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

	if($type =~ /Renew/ && %renew && (Mebius::Auth::AccountName(undef,$renew{'account'}))){ return(); }

	# 自分と新しいマイメビの情報を取得
	if($type =~ /Tell-new-friend|Tell-cancel-friend/){
		(%account) = Mebius::Auth::File("Get-hash",$account);
		(%other_friend) = Mebius::Auth::File("Get-hash",$other_friend_account);
	}

# ファイル定義
# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

my $file = "${account_directory}${account}_friend.cgi";

	# 読み書きタイプを追加
	if($type =~ /Allow-renew-status/){ $type .= qq( Flock2); }

# マイメビリストを取得する
my($FILE1,$read_write) = Mebius::File::read_write($type,$file);
	if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }

	# 全て配列に格納しておく
	while(<$FILE1>){ push(@log_line,$_); }

	# トップデータの補完
	if($log_line[0] =~ /^TopDataPushed<>/){
		chomp ( $self{'top1'} = shift @log_line);
	}

	# トップデータの分解 ( トップデータを認識していてもしていなくても、後の更新処理のため、この位置に置く )
	# ( そもそも定義されていないハッシュは、Hash::control で更新されない )
	($self{'mark'},$self{'last_renew_status_time'}) = split(/<>/,$self{'top1'});

	# マイメビのステータス更新判定
	if($type =~ /Allow-renew-status/ && time >= $self{'last_renew_status_time'} + 5*60){
		$type .= qq( Renew);
		$renew_self{'last_renew_status_time'} = time;
	}

	# ファイルを展開
	foreach (@log_line) {

		# 局所化
		my($mylink2,$last_access_time2,%account2);

		# この行を分解
		chomp;
		my($key2,$account2,$handle2,$intro2,$befriend_time2,$edit_time2,$last_edit_time2,$be_introductioned_comment2,$last_access_time2,$last_get_account_data_time2,$account2_friend_num2,$be_introductioned_time2) = split(/<>/);
		push @{$self{'accounts'}} , $account2;

			# 壊れているデータ行は無視する（ファイル更新時には行を削除してしまう）
			if(Mebius::Auth::AccountName(undef,$account2)){
					if($type =~ /Renew/){	Mebius::AccessLog(undef,"Account-name-broken-file-fixed","アカウント名： $account2 データ行： $_ "); }
				next;
			}

		# ラウンドカウンタ
		$i_index++;

		# マイメビ数をカウント
		$friend_num++;

			# ●プロフィールなどで、全データをゲット
			if($type =~ /Get-all-index/){

				$hit_all_index++;

					if($hit_all_index > 10){ $flow_flag = 1; next; }

					if($intro2 ne ""){ $intro2 =~ s/<br>/ /g; $intro2 = qq( - $intro2); }
				$self{'topics_line'} .= qq(<a href="${main::auth_url}$account2/">$handle2</a> );
	
					# インデックス行
					if($hit_all_index <= 7){
						$self{'index_line'} .= qq(<div><a href="${main::auth_url}$account2/">$handle2 - $account2</a>$intro2);
							if($account{'myprof_flag'} || $main::myadmin_flag){
								$self{'index_line'} .= qq( - <a href="../?mode=befriend&amp;decide=edit&amp;account=$account2&amp;myaccount=$account">編集</a>);
							}

						$be_introductioned_comment2 =~ s/<br>/ /g;
						$self{'index_line'} .= qq(</div>\n);

					}

			}

			# マイメビハッシュ
			if($type =~ /Get-friend-hash/){
				$self{"my_friend_$account2"} = 1;
			}

			# 「～さんは～さんとマイメビになりました」のお知らせ用
			if($type =~ /Tell-new-friend/){
				Mebius::Auth::FriendsFriendIndex("New-allow Renew",$account2,$account{'file'},$other_friend{'file'},$account{'handle'},$other_friend{'handle'});
				Mebius::Auth::News("Renew Hidden-from-index Log-type-befriend",$account2,undef,undef,qq(<a href="${main::auth_url}$account{'file'}/">$account{'handle'}</a> さんと <a href="${main::auth_url}$other_friend{'file'}/">$other_friend{'handle'}</a>さんが$main::friend_tagに));
			}
			# 解除用
			if($type =~ /Tell-cancel-friend/){
				Mebius::Auth::FriendsFriendIndex("New-cancel Renew",$account2,$account{'file'},$other_friend{'file'});
			}

			# ●ファイル更新用
			if($type =~ /Renew/){

					my($allow_renew_line_flag) = Mebius::RenewStatus::allow_judge_for_get_file($last_get_account_data_time2,$last_access_time2) if($type =~ /Allow-renew-status/);

					# ▼アカウント単体ファイルから情報を取得して代入する
					if($allow_renew_line_flag){

						# アカウントデータを取得
						my(%account2) = Mebius::Auth::File("Hash Option Not-file-check",$account2);

						# 単体ファイルデータ取得時間
						$last_get_account_data_time2 = time;

							# 筆名を代入
							if($account2{'name'}){ $handle2 = $account2{'name'}; }

							# キー
							if($account2{'allow_view_last_access'} eq "Not-open"){
								$key2 =~ s/(\s)?Access-time-not-open//g;
								$key2 .= qq( Access-time-not-open);
							}
							else{
								$key2 =~ s/Access-time-not-open//g;
							}

							# 各マイメビの最終ログイン時間を代入
							if($account2{'last_access_time'}){
								$last_access_time2 = $account2{'last_access_time'};
							}

							# マイメビのマイメビ数
							if($account2{'friend_num'}){
								$account2_friend_num2 = $account2{'friend_num'};
							}

							# キーがない場合は次回処理へ
							if(!$account2{'key'}){ next; }

					}

					# マイメビになった日付が分からない場合は、フレンド状態取得処理から、stat で取得する
					if(!$befriend_time2){
						my(%friend) = Mebius::Auth::FriendStatus("Get-hash Get-stat",$account,$account2);
						$befriend_time2 = $friend{'last_time'};
					}

					# ▼紹介文の変更
					if($type =~ /Change-introduction/){
							if($account2 eq $renew{'account'}){
								$intro2 = $renew{'intro'};
								$edit_time2 = time;
								$last_edit_time2 = time;
								$self{'still_friend_flag'} = 1;
							}
					}

					# ▼紹介文の変更
					if($type =~ /Change-be-introductioned/){
							if($account2 eq $renew{'account'}){
								$be_introductioned_comment2 = $renew{'be_intro'};
								$be_introductioned_time2 = time;
							}
					}

					# ▼マイメビの削除
					if($type =~ /Delete-friend/){
							if($account2 eq $renew{'account'}){
								$friend_num--;
								$self{'still_friend_flag'} = 1;
								next;
							}
					}

					# ▼マイメビを新規追加
					if($type =~ /New-friend/){
							if($account2 eq $renew{'account'}){
								$self{'still_friend_flag'} = 1;
								next;
							}
					}

					# 更新行を追加する
					push(@renew_line,"$key2<>$account2<>$handle2<>$intro2<>$befriend_time2<>$edit_time2<>$last_edit_time2<>$be_introductioned_comment2<>$last_access_time2<>$last_get_account_data_time2<>$account2_friend_num2<>$be_introductioned_time2<>\n");
			}

			# ● インデックス取得用
			if($type =~ /Get-index/){

					my($relay_last_access_time2);

					# アカウントデータを取得
					#if($type =~ /Get-friend-status/){

							# データが壊れている場合など、アカウントファイルを取得しようとしてしまうとエラーが出るため対応
					#		if(!$account2){ next; }

					#	(%account2) = Mebius::Auth::File("Hash Not-file-check Option",$account2);
						#(%option2) = Mebius::Auth::Optionfile("Get-hash",$account2);
							#if($account2{'name'}){ $handle2 = $account2{'name'}; }

							# 各マイメビの最終ログイン時間を代入
							#if($option2{'last_access_time'} && $account2{'allow_view_last_access'} ne "Not-open"){
							#	$last_access_time2 = $option2{'last_access_time'};
							#}

							# 各マイメビの最終ログイン時間を代入
						#	if($account2{'last_access_time'} && $account2{'allow_view_last_access'} ne "Not-open"){
						#		$last_access_time2 = $account2{'last_access_time'};
						#	}

						# キーがない場合は次回処理へ
						#if(!$account2{'key'}){ next; }

					#}

				# インデックス配列を追加
				# push(@index_line,"$key2<>$account2<>$handle2<>$intro2<>$last_access_time2<>$befriend_time2<>$account2{'myurl'}<>$option2{'friend_num'}<>\n");

					if($key2 =~ /Access-time-not-open/){ 
						$relay_last_access_time2 = "";
					}
					else{
						$relay_last_access_time2 = $last_access_time2;
					}

				push(@index_line,"$key2<>$account2<>$handle2<>$intro2<>$relay_last_access_time2<>$befriend_time2<>$account2{'myurl'}<>$account2_friend_num2<>\n");

			}

			# ●マイメビの新着日記を一斉更新する ( 追加 )
			if($type =~ /New-diary/){
				Mebius::Auth::FriendDiaryIndex("New-diary Renew",$account2,$account,@relay_diary);
			}

			# ●マイメビの新着日記を一斉更新する ( 削除 )
			if($type =~ /Delete-diary/){
				Mebius::Auth::FriendDiaryIndex("Delete-diary Renew",$account2,$account,@relay_diary);
			}


	}

	# ●インデックスを再展開
	if($type =~ /Get-index/){

			# 最終ログイン時間順にソート
			if($type =~ /Get-friend-status/){
				@index_line = sort { (split(/<>/,$b))[4] <=> (split(/<>/,$a))[4] } @index_line;
			}
		
			# マイメビになった日付順にソート
			else{
				@index_line = sort { (split(/<>/,$b))[5] <=> (split(/<>/,$a))[5] } @index_line;
			}

			# ▼配列を展開
			foreach(@index_line){

				my($class,$mark);

				# 行を分解
				chomp;
				my($key2,$account2,$handle2,$intro2,$last_access_time2,$befriend_time2,$myurl2,$friend_num2) = split(/<>/);

					# 整形
					if($intro2){ $intro2 =~ s/<br>/ /g; }

				# ヒットカウンタ
				$hit_index++;

					# 自分や、自分の共通のマイメビの場合
					if($account2 eq $my_account->{'id'}){
						$mark = qq( <span class="red size80">※あなたです。</span>);
						$class .= qq( me);
					}
					elsif($my_friend{"my_friend_$account2"}){
						$mark = qq( <span class="green size80">※共通の${main::friend_tag}です。</span>);
						$class .= qq( my_friend);
					}

				# インデックス表示を定義
				$index_line .= qq(<div class="lim$class" id="F_$account2">);
				$index_line .= qq(<a href="$main::adir${account2}/">$handle2 - $account2</a>);
					
					# マイメビ人数
					if($friend_num2){
						$index_line .= qq( ( <a href="${main::adir}$account2/aview-friend">$friend_num2</a> ));
					}
					else{
						$index_line .= qq( ( <a href="${main::adir}$account2/aview-friend">$main::friend_tag</a> ));
					}

					# ▼自分のマイメビページでだけ表示する状況
					if($type =~ /Get-friend-status/ || $my_account->{'master_flag'}){

							# 最終ログイン時間
							if($last_access_time2){
								my($time_splited2) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-前",time - $last_access_time2);
									if($time_splited2){ $index_line .= qq( - ログイン： $time_splited2 ); }
							}

							# マイメビになった日付
							if($befriend_time2){
								my($time_splited2) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-前",time - $befriend_time2);
									if($time_splited2){ $index_line .= qq( - マイメビ： $time_splited2 ); }
							}
					}

					# マイＵＲＬ
					if($myurl2){ $index_line .= qq( - <a href="$myurl2" title="$myurl2">ＵＲＬ</a>); }

					# 紹介文
					if($intro2){ $index_line .= qq( - $intro2); }

					# 編集リンク ( 主アカウントの状態を判定 )
					if($type =~ /Get-friend-status/ || $main::myaccount{'admin_flag'}){
						$index_line .= qq( (<a href="$main::script?mode=befriend&amp;decide=edit&amp;account=$account2&amp;myaccount=$account">→編集</a>));
					}


				$index_line .= qq($mark</div>);

			}

			# ▼整形
			if($index_line){
				$self{'index_line'} = qq(<h2 id="MYMEBI"$main::kstyle_h2>$main::friend_tag ($hit_index人)</h2><div class="line-height-large friend_index">$index_line</div>);
					if($type =~ /Get-friend-status/ && $self{'last_renew_status_time'}){
						my($how_long) = shift_jis(Mebius::second_to_howlong({ GetLevel => "top" , ColorView => 1 , HowBefore => 1 },time - $self{'last_renew_status_time'}));
						$self{'index_line'} .= qq(<div class="right">更新 : $how_long</div>);
					}
			}

	}

	# ●ファイルを更新
	if($type =~ /Renew/){

		# 局所化
		my(%renew_option);

			# ●新しいマイメビを追加する
			if($type =~ /New-friend/){
					if(!$self{'still_friend_flag'}){ $friend_num++; }
				unshift(@renew_line,"<>$renew{'account'}<>$renew{'handle'}<><>$time<>$time<>$time<>\n");
			}

		# 編集時間順にソート?
		#@renew_line = sort { (split(/<>/,$b))[6] <=> (split(/<>/,$a))[6] } @renew_line;

		# 任意の更新とリファレンス化
		($renew) = Mebius::Hash::control(\%self,\%renew_self);

		# トップデータを追加
		unshift(@renew_line,"TopDataPushed<>$renew->{'last_renew_status_time'}<>\n");

		# ファイル更新
		Mebius::File::truncate_print($FILE1,@renew_line);

		# オプションファイルのマイメビ人数を更新
		#$renew_option{'friend_num'} = $friend_num;
		#Mebius::Auth::Optionfile("Renew",$account,%renew_option);

			# オプションファイルのマイメビ人数を更新
			if($type !~ /Allow-renew-status/){
				$renew_option{'friend_num'} = $friend_num;
				Mebius::Auth::File("Renew Option",$account,\%renew_option);
			}
	}

close($FILE1);

	# パーミッション変更
	if($type =~ /Renew/){ Mebius::Chmod(undef,$file); }

	# バックアップ
	if($type =~ /Renew/ && (rand(25) < 1 || Mebius::alocal_judge())){
		Mebius::make_backup($file);
	}

	# ●登録がないのに変更しようとした場合
	#if($type =~ /Change-introduction/ && !$still_friend_flag){
	#	main::error("一覧に存在しない$main::friend_tag ( $renew{'account'} ) は変更できません。");
	#}

	# ハッシュ調整
	if(!$self{'friend_num'}){ $self{'friend_num'} = 0; }

	# リターン
	if($type =~ /Renew/ && %$renew){
		return(%$renew);
	}
	else{
		return(%self);
	}

}

#-----------------------------------------------------------
# マイメビ申請ファイル
#-----------------------------------------------------------
sub ApplyFriendIndex{

# 宣言
my($type,$account,$target_account) = @_;
my(undef,undef,undef,$handle,$apply_comment) = @_ if($type =~ /New-apply/);
my(%apply,$apply_index_handler,@renew_index,$index_line,$i,$hit_index,$most_new_applied_time);
my $time = time;

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }
	if($target_account && Mebius::Auth::AccountName(undef,$target_account)){ return(); }

# ファイル定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

my $file = "${account_directory}${account}_befriend.cgi";

# ファイルを開く
open($apply_index_handler,"<",$file);

	# ファイルロック
	if($type =~ /Renew/){ flock($apply_index_handler,1); }

	# ファイルを展開
	while(<$apply_index_handler>){

		# ラウンドカウンタ
		$i++;

		# 行を分解
		chomp;
		my($account2,$handle2,$apply_time2,$apply_comment2) = split(/<>/);

			# 申請済みかどうか、アカウント重複分があるかどうかをチェック
			if($account2 eq $target_account){
				$apply{'still_apply_flag'} = 1;
			} else {
				# 申請数を数える
				$apply{'num'}++;
			}

			# ● インデックス取得用
			if($type =~ /Get-index/){

				# 申請時間
				my(%apply_time) = Mebius::Getdate("Get-hash",$apply_time2); 

				# ヒットカウンタ
				$hit_index++;

					# 水平線
					if($hit_index >= 2){ $index_line .= qq(<hr$main::xclose>); }

				$index_line .= qq(<div class="line-height">);
				$index_line .= qq(<a href="${main::auth_url}$account2/">$handle2 - ${account2}</a>);
				$index_line .= qq( - <a href="$main::script?mode=befriend&amp;decide=ok&amp;account=${account2}">許可する</a> / );
				$index_line .= qq(<a href="$main::script?mode=befriend&amp;decide=no&amp;account=${account2}">拒否する</a>);
					if($apply_time{'date'}){ $index_line .= qq( ( $apply_time{'date'} ) ); }
					if($apply_comment2){ $index_line .= qq(<div>$apply_comment2</div>); }
				$index_line .= qq(</div>);
			}

			# ●ファイル更新用
			if($type =~ /Renew/){ 

					# アカウント重複を判定
					if($account2 eq $target_account && $type =~ /(New-apply|Delete-apply|Allow-apply)/){
						next;

					} else{

						# マイメビ拒否した場合の、次点申請者の最終申請時刻を記憶しておく
						if($apply_time2 > $most_new_applied_time){ $most_new_applied_time = $apply_time2; }

						# 更新行を追加
						push(@renew_index,"$account2<>$handle2<>$apply_time2<>$apply_comment2<>\n")
					}
			}

	}
close($apply_index_handler);

	# ●インデックス取得用
	if($type =~ /Get-index/){
			if($index_line eq ""){ $index_line = qq(現在、申\請はありません。); }
		$apply{'index_line'} = qq(<div>$index_line</div>);
	}

	# ●マイメビ許可用
	if($type =~ /Allow-apply/){
			if(!$apply{'still_apply_flag'}){ main::error("申\請されていないメンバー ( $target_account ) は許可できません。"); }
	}

	# ● 新しく申請用
	if($type =~ /New-apply/){
		$apply{'num'}++;
		unshift(@renew_index,"$target_account<>$handle<>$time<>$apply_comment<>\n");
	}

	# ●ファイルを更新用
	if($type =~ /Renew/){
		Mebius::Fileout("Allow-empty",$file,@renew_index);
	}

	# 本体ファイルを更新 ( フィード表示用 )
	if($type =~ /Renew/){

		my(%renew_account);

		# 未処理の申請数 
			if(!defined $apply{'num'}){ $apply{'num'} = 0; } # 更新に必要
		$renew_account{'new_applied_num'} = $apply{'num'};

			# 一番新しい申請の時刻
			if($type =~ /New-apply/){
				$renew_account{'last_applied_time'} = time;
			} else {
				$renew_account{'last_applied_time'} = $most_new_applied_time;
			}

		# 更新
		Mebius::Auth::File("Renew Option",$account,\%renew_account);

	}


return(\%apply);

}

#-----------------------------------------------------------
# 「マイメビ新着日記」のインデックス ( アカウント毎 )
#-----------------------------------------------------------
sub FriendDiaryIndex{

# 局所化
my($type,$account) = @_;
my(undef,undef,$max_view_topics) = @_ if($type =~ /Get-topics/);
my(undef,undef,$diary_account,$diary_number,$diary_subject,$diary_handle) = @_ if($type =~ /New-diary|Delete-diary/);
my($i,$friend_diary_index,@renew_line,$topics_index,$topics_line,$hit_topics,$index_line,$topics_flow_flag,%data);
my $time = time;

	# 汚染チェック
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }
	if(!$max_view_topics){ $max_view_topics = 5; }

# ファイル定義
# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
my $file = "${account_directory}${account}_dnewlist_friend.cgi";

# 新着一覧の最大数
my $max_line = 25;

	# 新しい日記を投稿した場合
	if($type =~ /New-diary/){
		unshift(@renew_line,"<>$diary_account<>$diary_handle<>$diary_number<>$diary_subject<>$main::time<>$main::date<>\n");
		$i++;
	}

# フィイルを開く
open($friend_diary_index,"+<",$file) && ($data{'f'} = 1);

	# ファイルが存在しない場合
	if(!$data{'f'}){
		close($friend_diary_index);
		Mebius::Fileout("Allow-empty",$file);
		open($friend_diary_index,"+<$file") && ($data{'f'} = 1);
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($friend_diary_index,2); }

	# ファイルを展開
	while(<$friend_diary_index>){

		# ラウンドカウンタ
		$i++;

		# 行を分解する
		chomp;
		my($key2,$account2,$handle2,$diary_number2,$subject2,$posttime2,$postdate2) = split(/<>/);

			# ●プロフィール用
			if($type =~ /Get-topics/){

				my($post_before2) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-前",$main::time - $posttime2);

					# 削除済みの場合
					if($key2 =~ /Deleted/){ next; }

					if($hit_topics >= $max_view_topics){ $topics_flow_flag = 1; last; }

				my $link = qq($main::adir$account2/);
				my $link2 = qq($main::adir$account2/d-$diary_number2);
					if($main::aurl_mode){ ($link) = main::aurl($link); ($link2) = main::aurl($link2); }
					$topics_line .= qq(<div><a href="$link2">$subject2</a> - <a href="$link">$handle2</a>　 $post_before2</div>);
				$hit_topics++;
			}

			# ●インデックス取得用
			if($type =~ /Get-index/){

					# 削除済みの場合
					if($key2 =~ /Deleted/){ next; }

				my($post_before2) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-前",$main::time - $posttime2);
				$index_line .= qq(<tr>\n);
				$index_line .= qq(<td>\n);
				$index_line .= qq(<a href="${main::auth_url}$account2/d-$diary_number2">$subject2</a>\n);
				$index_line .= qq(</td>\n);
				$index_line .= qq(<td>\n);
				$index_line .= qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>\n);
				$index_line .= qq(</td>\n);
				$index_line .= qq(<td>\n);
				$index_line .= qq($post_before2\n);
				$index_line .= qq(</td>\n);
				$index_line .= qq(</tr>\n);
			}

			# ●ファイル更新用
			if($type =~ /Renew/){

					# 処理最大行数に達した場合
					if($i >= $max_line){ last; }

					# ▼一覧から削除する場合
					if($type =~ /Delete-diary/){
							if($account2 eq $diary_account && $diary_number2 eq $diary_number){
								if($key2 !~ /Deleted/){ $key2 .= qq( Deleted); }
							}
					}


				# 更新行を追加する
				push(@renew_line,"$key2<>$account2<>$handle2<>$diary_number2<>$subject2<>$posttime2<>$postdate2<>\n");
			
			}

	}

	# ファイルを書き込む
	if($type =~ /Renew/){
		seek($friend_diary_index,0,0);
		truncate($friend_diary_index,tell($friend_diary_index));
		print $friend_diary_index @renew_line;
		close($friend_diary_index);
		Mebius::Chmod(undef,$file);
	}


close($friend_diary_index);

	# トピックス取得用
	if($type =~ /Get-topics/){
			
				if($topics_line eq ""){ $topics_line = qq(データがありません); }

			# 見出しの整形
			$topics_line = qq(<h3$main::kstyle_h3><a href="friend-diary">マイメビの更新</a></h3><div class="mdiary line-height-large">$topics_line</div>);

			# 続きリンク
			if($topics_flow_flag){
				$topics_line .= qq(<div class="right"><a href="friend-diary">→続きを見る</a>　</div>);
			}

		return($topics_line);
	}

	# インデックス取得用
	if($type =~ /Get-index/){
			if($index_line){
				$index_line = qq(<table summary="マイメビの新着日記一覧" class="friend_diary">$index_line</table>);
			}
			else{
				$index_line = qq(<div>何もありません。</div>);
			}
		return($index_line);
	}


}

#-----------------------------------------------------------
# マイメビの新着日記一覧の表示ページ
#-----------------------------------------------------------
sub FriendDiaryIndexView{

# 宣言
my($view_line,$target_account);


# CSS定義
$main::css_text .= qq(table.friend_diary{width:100%;});

	# 開くアカウントを定義
	if($main::in{'account'}){
		$target_account = $main::in{'account'};
	}
	else{
		$target_account = $main::myaccount{'file'};
	}

# 対象のアカウントを開く
my(%account) = Mebius::Auth::File("File-check-error",$target_account);

# 自分のプロフィール、または管理者でなければエラーに
if(!$account{'editor_flag'}){ main::error("あなたのページではありません。"); }

# 対象アカウントのマイメビ新着日記を取得
my($index_line) = Mebius::Auth::FriendDiaryIndex("Get-index",$account{'file'});

# HTMLを定義
$view_line .= qq($main::footer_link);
$view_line .= qq(<h1$main::kstyle_h1>マイメビの新着日記</h1>);
$view_line .= qq(<div class="word-spacing">);
$view_line .= qq( <a href="${main::auth_url}$account{'file'}/">あなたのプロフィール</a>);
$view_line .= qq( マイメビの新着日記);
$view_line .= qq( <a href="${main::auth_url}aview-alldiary.html">全メンバーの新着日記</a>);
$view_line .= qq( <a href="${main::auth_url}?mode=fdiary">新しい日記を書く</a>);
$view_line .= qq(</div>);
$view_line .= qq(<h2$main::kstyle_h2>メニュー</h2>);
$view_line .= qq($index_line);
$view_line .= qq($main::footer_link2);

# タイトル定義
$main::sub_title = qq(マイメビの新着日記 | $account{'name'} - $account{'file'});


# HTMLを表示
my $print = qq($view_line);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# マイメビとマイメビになったメンバー一覧
#-----------------------------------------------------------
sub FriendsFriendIndex{

# 宣言
my($type,$account,$friend_account,$other_account) = @_;
my(undef,undef,undef,undef,$friend_handle,$other_handle) = @_ if($type =~ /New-allow/);
my($i,@renew_line,%data,$file_handler);

# 行数
my $max_line = 10;

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
my $directory1 = $account_directory;
my $file1 = "${directory1}${account}_friends_friend.log";

# ファイルを開く
open($file_handler,"<$file1");

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# 局所化
		my($not_push_flag);

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2,$friend_account2,$other_account2,$friend_handle2,$other_handle2,$befriend_time2) = split(/<>/);

			# インデックスを取得
			if($type =~ /Get-index/){
				$data{'index_line_body'} .= qq(<div class="line-height-large">);
				$data{'index_line_body'} .= qq(<a href="${main::auth_url}$friend_account2/">$friend_handle2</a> さんと );
				$data{'index_line_body'} .= qq(<a href="${main::auth_url}$other_account2/">$other_handle2</a> さんが);
				$data{'index_line_body'} .= qq($main::friend_tagになりました );
					my($befriend_how_before) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-前",time - $befriend_time2);
				$data{'index_line_body'} .= qq( \( $befriend_how_before \));
				$data{'index_line_body'} .= qq(</div>\n);
			}

			# 削除する場合
			if($type =~ /New-cancel/){
					# 指定アカウントがヒットした場合
					if("$friend_account2-$other_account2" eq "$friend_account-$other_account"){ $not_push_flag = 1; }
			}

			# 行を追加
			if($type =~ /Renew/ && $i < $max_line && !$not_push_flag){
				push(@renew_line,"$key2<>$friend_account2<>$other_account2<>$friend_handle2<>$other_handle2<>$befriend_time2<>\n");
			}

	}

close($file_handler);

	# インデックスを整形
	if($type =~ /Get-index/){

			if($data{'index_line_body'}){
					$data{'index_line'} = qq($data{'index_line_body'});
			}
			else{
				$data{'index_line'} = qq(<div>まだデータがありません。</div>);
			}
	}

	# 新規追加
	if($type =~ /New-allow/){
		unshift(@renew_line,"<>$friend_account<>$other_account<>$friend_handle<>$other_handle<>$main::time<>\n");
	}

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

		# ファイル更新
		unshift(@renew_line,"$data{'key'}<>\n");
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);


}


1;
