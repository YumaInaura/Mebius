
use strict;
use Mebius::History;
use Mebius::Referer;
use Mebius::Login;
use Mebius::SNS;
package Mebius;

#-----------------------------------------------------------
# 自分のアカウントデータ
#-----------------------------------------------------------
sub my_account{

# 宣言
my($use) = @_;
my(%myaccount,$NotGetAccountFlag);
my($basic_init) = Mebius::basic_init();

# 名前を定義
my $HereName1 = "my_account";

# Near State （呼び出し） 2.10
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereName1);
	if(defined $state){ return($state); }

# ループ予防
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereName1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereName1); }

# Cookieを取得
my($mycookie) = Mebius::my_cookie_main();

	# 必須データ ( Sreturn してしまうと State 値が保存できないので、フラグを立ててサブルーチンの最後まで処理させる )
	if(!$mycookie->{'account'}){ $NotGetAccountFlag = 1; }
	if(!$mycookie->{'hashed_password'}){ $NotGetAccountFlag = 1; }

	# アカウント名判定 ( 次の Auth::File でもエラーを出しているけど、念のためここでもチェック)
	# Auth::File の内部でリターンしたりエラーを出したりすると処理が煩雑なので、ここで「アカウントデータを取得しない」という処理をしておく
	if(Mebius::Auth::AccountName(undef,$mycookie->{'account'})){ $NotGetAccountFlag = 1; }

	# ●自分のアカウントデータを取得
	if(!$NotGetAccountFlag){

		# アカウントデータを取得 ( Flock2 を外さない！ )
		(%myaccount) = Mebius::Auth::File("Get-my-account Not-file-check Flock2 Option Block-rooping",$mycookie->{'account'},$mycookie->{'hashed_password'});

			#if(Mebius::alocal_judge()){ $myaccount{'admin_flag'} = $myaccount{'master_flag'} = 0; }

			# ●修正
			#if($ENV{'REQUEST_METHOD'} eq "GET"){

					# ▼Debug ( 金貨が少ない？)
					#if($myaccount{'login_flag'} && $myaccount{'cookie_regist_count'} <= 20 && $myaccount{'concept'} !~ /Low-gold-fixed-2012-03-11/ && $myaccount{'firsttime'} < (1354851067 - 9*30*24*60*60)){

					#	my %renew_account;

					#		my($save_old) = Mebius::save_data({ FileType => "Account" },$myaccount{'file'});

					#			foreach(keys %$save_old){
					#					if($_ =~ /^cookie_/){ $renew_account{$_} = $save_old->{$_}; }
					#			}

					#			if($save_old->{'f'} && $save_old->{'cookie_regist_count'} > $myaccount{'cookie_regist_count'}){
					#				Mebius::AccessLog(undef,"Gold-low-account-and-save","アカウント: $myaccount{'file'} / $save_old->{'cookie_regist_count'} > $myaccount{'cookie_regist_count'} / 金貨 $save_old->{'cookie_gold'} > $myaccount{'cookie_gold'} ");
					#			}
					#			else{
					#				Mebius::AccessLog(undef,"Gold-not-low-account-and-save","アカウント: $myaccount{'file'} / $save_old->{'cookie_regist_count'} > $myaccount{'cookie_regist_count'} / 金貨 $save_old->{'cookie_gold'} > $myaccount{'cookie_gold'} ");
					#			}

						# 更新
					#	$renew_account{'.'}{'concept'} .= " Low-gold-fixed-2012-03-11";
					#	Mebius::Auth::File("Renew Block-rooping",$myaccount{'file'},\%renew_account);

					#}

					# ▼セーブデータを自動修復 2012/2/28 (火)
					#if($myaccount{'login_flag'} && $myaccount{'concept'} !~ /Old-save-data-tranced/ && $myaccount{'firsttime'} < (1354851067 - 8*30*24*60*60)){

					#	my %renew_account;

					#	my($save_old) = Mebius::save_data({ FileType => "Account" },$myaccount{'file'});
					#		foreach(keys %$save_old){
					#				if($_ =~ /^cookie_/){ $renew_account{$_} = $save_old->{$_}; }
					#		}

					#		if($save_old->{'f'}){
					#			Mebius::AccessLog(undef,"Save-data-to-account","アカウント : $myaccount{'file'}");
					#		}
					#		else{
					#			Mebius::AccessLog(undef,"Save-data-not-found","アカウント : $myaccount{'file'}");
					#		}

						# 更新
					#	$renew_account{'.'}{'concept'} .= " Old-save-data-tranced";
					#	Mebius::Auth::File("Renew Block-rooping",$myaccount{'file'},\%renew_account);

					#}

					# ▼ aurasoul.mb2.jp の金貨を mb2.jp に引き継ぎ 2012/12/7 (金)
					#elsif($myaccount{'login_flag'} && $myaccount{'concept'} !~ /Gold-join-with-old-server-2013.01.18/ && $myaccount{'firsttime'} < 1354851067 && Mebius::Server::bbs_server_judge()){

					#	my(%renew_account);

					#	my(%old_server_account) = Mebius::Auth::File("Block-rooping Old-server-file File-check-return",$myaccount{'file'});

					#	$renew_account{'cookie_gold_old_server'} = $old_server_account{'cookie_gold'};
					#	$renew_account{'cookie_regist_all_length_old_server'} = $old_server_account{'cookie_regist_all_length'};
					#	$renew_account{'cookie_regist_count_old_server'} = $old_server_account{'cookie_regist_count'};

					#	$renew_account{'+'}{'cookie_gold'} = $old_server_account{'cookie_gold'};
					#	$renew_account{'+'}{'cookie_regist_all_length'} = $old_server_account{'cookie_regist_all_length'};
					#	$renew_account{'+'}{'cookie_regist_count'} = $old_server_account{'cookie_regist_count'};

					#	$renew_account{'cookie_gold_save_original'} = $myaccount{'cookie_gold'};
					#	$renew_account{'cookie_regist_all_length_save_original'} = $myaccount{'cookie_regist_all_length'};
					#	$renew_account{'cookie_regist_count_save_original'} = $myaccount{'cookie_regist_count'};

					#	$renew_account{'.'}{'concept'} .= " Gold-join-with-old-server-2013.01.18";
					#	Mebius::Auth::File("Renew Block-rooping File-check-return",$myaccount{'file'},\%renew_account);

					#	Mebius::AccessLog(undef,"Gold-move-from-old-server-2013-01-18","アカウント : $myaccount{'file'} / 移動した金貨 : $old_server_account{'cookie_gold'}枚");

					#}

			#}

	}

	#if(Mebius::alocal_judge()){ $myaccount{'admin_flag'} = 0; }
	# 投稿履歴ファイルのデータを更新
	#Mebius::HistoryAll("RENEW My-file "); #=> roop エラーに

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereName1); }

	# Near State （保存） 2.10
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$HereName1,\%myaccount); }

return(\%myaccount);

}

package Mebius::Auth;

#-----------------------------------------------------------
# パス
#-----------------------------------------------------------
sub account_path{

my(%self);
my($use) = shift if(ref $_[0] eq "HASH");
my($account) = @_;
#my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();	

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){
		die("Perl Die!  Can't decide account data directory.");
	}

my($account_first_word) = substr($account,0,1);
my($account_second_word) = substr($account,1,1);

	# 古い形式のディレクトリ
	if(exists $use->{'OldDirectory'}){ 
		$self{'root_directory'} = "${share_directory}_id/$account/";
	# 新しい形式のディレクトリ
	} else{
		$self{'first_word_directory'} = "${share_directory}_account/${account_first_word}/";
		$self{'second_word_directory'} = "$self{'first_word_directory'}${account_second_word}/",
		$self{'root_directory'} = "$self{'second_word_directory'}$account/",
	}


\%self;


}


#-----------------------------------------------------------
# アカウント毎の基本データディレクトリ
#-----------------------------------------------------------
sub account_directory{

my($use) = shift if(ref $_[0] eq "HASH");
my($account) = @_;
my($account_path);

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){
		Mebius::AccessLog(undef,"Cant-decicde-account-directory");
		return();
	}

	if($use){
		($account_path) = Mebius::Auth::account_path($use,$account);
	}
	else{
		($account_path) = Mebius::Auth::account_path($account);
	}

	if($account_path->{'root_directory'}){
		return($account_path->{'root_directory'});
	}
	else{
		die("Perl Die! Can't decide account directory.");
	}



}


#-------------------------------------------------
# アカウント基本ファイルを開く
#-------------------------------------------------
sub File{

# 宣言
my($type,$file,%other_account) = @_;
my($select_renew);
my(undef,undef,$password) = @_ if($type =~ /Get-my-account/);
my(undef,undef,%select_renew) = @_ if($type =~ /Renew/ && ref $_[2] eq ""); # 任意の更新値を、ハッシュのリファレンスでも受け取れるように 
$select_renew = \%select_renew if($type =~ /Renew/ && ref $_[2] eq ""); # 同
(undef,undef,$select_renew) = @_ if($type =~ /Renew/ && ref $_[2] eq "HASH");	# 同
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account() if($type !~ /Get-my-account|Block-rooping/); # ●無限ループに注意！！
my($nowdate) = Mebius::now_date_multi();
my($FILE1,%account,$error_text);
my($renewline,$profile_handler,$profile_file,$accountfile,$renewline_profile,$mylink,@multi_salt,@renew_line,%self_renew,%data_format,$renew,$move_from_file);

# ファイル定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){
		Mebius::AccessLog(undef,"Cant-decide-account-directory","\@_ : @_");
		die("Perl Die! Account directory setting is empty. @_ ");
	} else {
			# 金貨統合用
			if($type =~ /Old-server-file/){
				$account_directory =~ s!/_account/!/_account_move_from/!g;
			} elsif($type =~ /Move-from-file/){
				$account_directory =~ s!/_account/!/_account_move_from2/!g;
			}
		$account{'directory_path'} = $account_directory;
		$accountfile = $account{'file_path'} = "${account_directory}$file.cgi";
	}


	# マイメビ一覧ファイルが壊れている場合などに対応
	if($file eq "" && $type =~ /Not-file-check/){ return(); }

	# アカウント名のチェック
	# return ではなくて恐らく error が正しいはず ( 自分のデータを開く場合は、これ以前の処理で return している )
	my($account_name_error) = Mebius::Auth::AccountName(undef,$file);
		if($account_name_error){
			Mebius::AccessLog(undef,"Account-name-error","$account_name_error");
			main::error($account_name_error);
	}
	if(Mebius::FileNamePolution([$file])){ main::error("ファイル名の指定が変です。"); }

	# 重複作成を禁止する場合 # 必ず open ではなくファイルチェックすること
	if($type =~ /New-account/ && -f $accountfile){
		main::error("このアカウントは既に存在します。");
	}

# アカウントファイルを開く
	if($type =~ /File-check-error/){

		$account{'f'} = open($FILE1,"+<",$accountfile) || main::error("ファイルが存在しません。");
	} else{

		# ファイルを開く
		$account{'f'} = open($FILE1,"+<",$accountfile);

			# ▼ファイルが存在しない場合
			if(!$account{'f'}){

					# ファイルが存在しなくてもエラーを出さない場合 ( ただしすぐにリターンする )
					if($type =~ /Not-file-check|File-check-return/){
						close($FILE1);
						return(%account);
					}

					# ファイルを新規作成する場合
					elsif($type =~ /Renew/){
							# 重要： 存在しないファイルは、通常は作成できないようにしておく
							# 「アカウントの新規作成」「管理者による強制作成」のときだけ実行する
							if($type =~ /New-account|Admin-renew/){
								#Mebius::Mkdir(undef,$account{'directory1'});
								Mebius::Fileout("Allow-empty",$accountfile);
								$account{'new_file_flag'} = 1;
								$account{'f'} = open($FILE1,"+<",$accountfile);
							}
							else{
								main::error("このアカウント $file は存在しません。");
							}
					}

					# その他の場合は”必ず”エラーを出す
					else{
						main::error("このアカウント $file は存在しません。");

					}

			}

	}

	# ファイルロック ( 重要！ Flock2 しないとファイル全消失の恐れあり！ )
	# Option 指定でもファイル更新のため、一時的に flock2 する
	if($type =~ /Renew|Get-my-account|Flock2|Option/){ flock($FILE1,2); $account{'flock2_flag'} = 1; } else { flock($FILE1,1); $account{'flock1_flag'} = 1; }

# データ構造を定義
$data_format{'1'} = [('key','account','pass','salt','firsttime','blocktime','lasttime','adlasttime','concept','pass_crypt','salt_crypt')];
$data_format{'2'} = [('name','mtrip','color1','color2','prof','edittime','last_profile_edit_time','comment_font_color')];
$data_format{'3'} = [('ocomment','odiary','obbs','osdiary','osbbs','orireki','ohistory','okr','allow_vote','allow_message','allow_view_last_access','allow_crap_diary','use_bbs')];
$data_format{'4'} = [('encid','enctrip')];
$data_format{'5'} = [('level','level2','surl','admin','chat','reason','last_locked_period','all_locked_period','alert_end_time','alert_count','alert_decide_time')];
$data_format{'6'} = [('email','mlpass','myurl','myurltitle','remain_email')];
$data_format{'7'} = [('birthday_concept','birthday_year','birthday_month','birthday_day','birthday_time')];
$data_format{'8'} = [('none','all_renew_count','account_locked_count')];
$data_format{'9'} = [('catch_mail_message','catch_mail_resdiary','catch_mail_comment','catch_mail_etc')];
$data_format{'10'} = [('first_email','first_host','first_agent')];
$data_format{'11'} = [('set_cookie_count','cookie_name','cookie_refresh_second','cookie_font_color','cookie_thread_up','cookie_gold','cookie_regist_all_length','cookie_regist_count','cookie_font_size','cookie_follow','cookie_last_view_thread','cookie_use_history','cookie_omit_text','cookie_bbs_news','cookie_age','cookie_email','cookie_secret','cookie_account_link','cookie_id_fillter','cookie_account_fillter','cookie_use_id_history')];
$data_format{'12'} = [('optionkey','last_action_time','addr','agent','cnumber')];
$data_format{'13'} = [('todaypresentgold','lastpresentgold')];
$data_format{'14'} = [('votepoint','todayvotepoint','lastvote')];
$data_format{'15'} = [('last_send_message_yearmonthday','today_send_message_num','unread_message_num')];
$data_format{'16'} = [('deny_count','denied_count','friend_num')];
$data_format{'17'} = [('last_access_time','last_access_addr','last_access_multi_user_agent','last_access_cookie_char')];
$data_format{'18'} = [('last_apply_friend_time','last_comment_time')];
$data_format{'19'} = [('next_diary_post_time','next_comment_time')];
$data_format{'20'} = [('penalty_time')];
$data_format{'21'} = [('char')];
$data_format{'22'} = [('option_to_account_time')];
$data_format{'23'} = [('new_applied_num','last_applied_time')];
$data_format{'24'} = [('cookie_gold_old_server','cookie_regist_all_length_old_server','cookie_regist_count_old_server','cookie_gold_save_original','cookie_regist_all_length_save_original','cookie_regist_count_save_original')];
$data_format{'25'} = [('question_last_post_time','quesiton_last_post_time','question_last_response_time')];
$data_format{'26'} = [('friend_accounts','deny_accounts')];

	# トップデータを読み込み
	my($split_data) = Mebius::file_handle_to_hash(\%data_format,$FILE1);
	%account = (%account,%$split_data);

	# ログが壊れている場合
	if($account{'account'} eq "" && !$account{'new_file_flag'}){ $account{'broken_flag'} = 1; }

	# オプションファイルを取得してハッシュに追加
	#if($type =~ /Option/){
		#(%option) = &Optionfile("",$file);
		#%account = (%account,%option);
	#}

	# ▼オプションファイルの値を、メインファイルに復元 (一時的な処理)
	# ▼ 2012/2/29 (水)
	if($type =~ /Option/ && !$account{'option_to_account_time'} && $account{'first_time'} < 1355471111 - (9*30*24*60*60)){
		my(%option) = &Optionfile("",$file);
			if($option{'f'}){ %account = (%account,%option); }
		$self_renew{'option_to_account_time'} = time;
		$type .= qq( Renew); # ファイル消失に注意！ かならずこれ以前に flock2 すること！
			Mebius::AccessLog(undef,"Option-file-to-account-file","アカウント : $file");
	}

	# マイメビ状態のチェックをおこなう場合
	if($type =~ /Get-friend-status/ && %other_account){
			($account{'friend_status_to'}) = Mebius::Auth::FriendStatus(undef,$file,$other_account{'file'});
			($account{'friend_status_from'}) = Mebius::Auth::FriendStatus(undef,$other_account{'file'},$file);
	}

	# キーチェック
	if($type =~ /Key-check-error/ && $account{'key'} !~ /^(1|2)$/){
		close($FILE1);
		main::error("このアカウント ( $file ) は利用されていません。");
	}

	# 筆名、プロフがない場合
	if($account{'name'} eq "" || $account{'name'} eq "名無し"){
		$account{'birdflag'} = 1;
		$account{'name'} = "名無し";
	}
	# 同じ値にするもの
	$account{'handle'} = $account{'name'};

	# ▼URL・リンク
	$account{'name_link'} = qq(<a href="$basic_init->{'auth_url'}$file/">$account{'name'} - $file</a>);
	$account{'profile_url'} = "$basic_init->{'auth_url'}$file/";

	# ●ハッシュの調整
	# 日にちが更新されている場合、投票ポイントを満タンにする
	if($account{'lastvote'} ne $nowdate->{'ymdf'}){
			if(Mebius::alocal_judge()){ $account{'todayvotepoint'} = 10; }
			else{ $account{'todayvotepoint'} = 3; }
	}

	# 日にちが更新されている場合、今日のメッセージの送信回数をリセットする
	if($account{'last_send_message_yearmonthday'} ne $nowdate->{'ymdf'}){
		$account{'today_send_message_num'} = 0;
	}

	# 同一送信者チェック
	if($account{'agent'} && $account{'agent'} eq $main::agent && $main::k_access){ $account{'sameaccess_flag'} = 1; }
	if($account{'addr'} && $account{'addr'} eq $main::addr && !$main::k_access){ $account{'sameaccess_flag'} = 1; }
	if($account{'cnumber'} && $account{'cnumber'} eq $main::cnumber){ $account{'sameaccess_flag'} = 1; }

	# マイメビの最大登録数
	if($account{'level2'} >= 1){ $account{'max_friend'} = 200; } else { $account{'max_friend'} = 100; }
	if($account{'friend_num'} >= $account{'max_friend'}){
		$account{'max_friend_flag'} = qq($account{'name_link'}さんのマイメビは、既に最大数に達しています。 ( $account{'friend_num'} 人 / $account{'max_friend'}人 ) );
	}

	# ● 一連の処理
	{
			# アカウントへの警告 ( A )
			if($account{'key'} eq "1" && $account{'reason'} && time < $account{'alert_end_time'}){
					if(time > $account{'alert_decide_time'} + 24*60*60){
						$account{'alert_flag'} = 1;
						$account{'allow_next_alert_flag'} = 1;
					} else {
						$account{'alert_flag'} = 1;
					}
			} else {
				$account{'allow_next_alert_flag'} = 1;
			}

			# アカウントロックの解除日 ( B )
			if($account{'key'} eq "2" && $account{'blocktime'} && time >$account{'blocktime'}){ $account{'key'} = 1; }

			# 正しく過ごした日数 ( C )
			if($account{'key'} eq "1" && !$account{'alert_flag'}){
					if($account{'firsttime'}){
						$account{'justy_days'} = int( (time - $account{'firsttime'}) / (24*60*60) );
					} else {
						$account{'justy_days'} = 365; # 必要なデータがない場合、便宜的に１年分を代入
					}
			}

			# ロック状態のチェック ( C )
			if($type =~ /Lock-check-error/ && $account{'key'} eq "2"){
				$account{'error_message'} .= qq(このアカウント ( $file ) はロック中です。);
					if(!$main::myadmin_flag){
						close($FILE1);
						main::error($account{'error_message'});
					}
			}

	}

	# アカウント名 ( ログイン失敗の場合は、あとでハッシュを渡さずリターンするので問題なし )
	$account{'file'} = $account{'id'} = $file;

	# アカウントを登録してからの月数を計算
	if($account{'firsttime'}){ $account{'past_month'} = int((time - $account{'firsttime'}) / (30.43*24*60*60)); }
	else{ $account{'past_month'} = 100; }


	# 年齢
	if($account{'birthday_time'}){
		$account{'age'} = int((time - $account{'birthday_time'}) / (365.24*24*60*60));
	}

	# メッセージの最大送信可能数
	if($account{'key'} eq "1"){
		$account{'maxsend_message'} = int($account{'past_month'} - 11);
		#$account{'maxsend_message'} += int($option{'friend_num'}/3);
		#	if($option{'denied_count'} >= 1){ $account{'maxsend_message'} -= $option{'denied_count'}; }
		$account{'maxsend_message'} += int($account{'friend_num'}/3);
			if($account{'denied_count'} >= 1){ $account{'maxsend_message'} -= $account{'denied_count'}; }

			if($account{'maxsend_message'} >= 100){ $account{'maxsend_message'} = 100; }
			if($account{'maxsend_message'} < 0){ $account{'maxsend_message'} = 0; }
			if($account{'admin'} >= 1){ $account{'maxsend_message'} += 100; }
		$account{'today_left_message_num'} = $account{'maxsend_message'} - $account{'today_send_message_num'};
	}

	# メール利用可能フラグ
	#if($account{'maxsend_message'} >= 1 && ($account{'past_month'} >= 6 && $option{'friend_num'} >= 3)){
	if($account{'maxsend_message'} >= 1 && ($account{'past_month'} >= 6 && $account{'friend_num'} >= 3)){
		$account{'allow_message_status'} = 1;
			# 自分で利用禁止/強制利用禁止されている場合以外は、本当にメッセージフォームを使えるように
			if($account{'allow_message'} !~ /^(Deny-use|Not-use)$/){ $account{'allow_message_flag'} = 1; }
	}

	# 許可状態
	if($account{'allow_crap_diary'} ne "Deny"){ $account{'allow_crap_diary_flag'} = 1; }

	# メッセージ無条件利用可能フラグ
	#if($account{'key'} eq "1" && ($account{'past_month'} >= 3*12 || $account{'admin'} >= 1)){
	#	$account{'all_allow_message_flag'} = 1;
	#}


	# 管理者は全機能を使えるように
	#if($account{'admin'}){ $account{'allow_message_flag'} = 1; }

	# 誕生日
	if($account{'birthday_year'} || $account{'birthday_month'} || $account{'birthday_day'}){
			if($account{'birthday_year'}){ $account{'birthday'} .= qq($account{'birthday_year'}年); }
			if($account{'birthday_month'}){ $account{'birthday'} .= qq($account{'birthday_month'}月); }
			if($account{'birthday_day'}){ $account{'birthday'} .= qq($account{'birthday_day'}日); }
			if($account{'age'}){ $account{'birthday'} .= qq( ( 現$account{'age'}才 )); }
	}

	# キー判定
	if($account{'key'} eq "1"){
		$account{'justy_flag'} = 1;
	}

	# ● 自分のデータを取得する場合 ( パスワード照合 )
	if($type =~ /Get-my-account/){

		# 局所化
		my($gethost);
		my($my_access) = Mebius::my_access();
		my($my_cookie) = Mebius::my_cookie_main();

		# ログイン失敗履歴を取得
		my($login) = Mebius::Login::TryFile("Get-hash Auth-file By-cookie",$main::xip);

			# ( 今日の失敗回数が多い場合は、ログイン判定 ( パスワード照合 ) 自体をおこなわずにリターン
			if($login->{'error_flag'}){
				Mebius::AccessLog(undef,"Login-missed-cookie-many","ログイン失敗の回数(全期間)： $login->{'all_missed_count'}回");
				close($FILE1);
				return();
			}

			# キーがない場合
			if($account{'key'} ne "1" && $account{'key'} ne "2"){
					close($FILE1);
					return();
			}

			# パスワード判定 
			# ★重要！失敗回数を記録してリターンする ( ここで return しないと、パスワードが間違っていてもログイン出来てしまう )
			# LoginTry ファイルで id & pass の重複チェックを行なっているので、 set_cookie してログアウトさせる必要はなし
			if($account{'pass'} ne $password || $password eq "" || $account{'pass'} eq ""){
				Mebius::Login::TryFile("Renew Login-missed Auth-file By-cookie",$main::xip,$file,$password);
				close($FILE1);
				return();
			}

			# アカウント名 / ハッシュ化されたパスワードの照合が成功した場合 ( 念のためさらに条件分岐で囲っておく )
			# => 重要な処理なので、上のパスワード判定から else で条件分岐させたりせず、こちらでも二重に条件判定をおこなう
			if($account{'pass'} eq $password && $password && $account{'pass'}){

				# 自分を定義
				$account{'idcheck'} = 1;
				$account{'login_flag'} = 1;

				# グローバル変数を設定
				$main::idcheck = 1;
				$main::pmfile = $file;
				#$main::pmkey = $account{'key'};
				$main::pmname = $account{'name'};

					if($account{'birdflag'}){ $main::birdflag  = qq(<a href="$basic_init->{'auth_url'}$file/edit#EDIT">あなたの筆名を設定</a>してください。); }

					# 管理者の場合、ホスト名をチェックする
					if($account{'admin'}){

						($gethost) = Mebius::get_host_state();
							if(length($gethost) >= 5 && !Mebius::Switch::sns_admin_off()){ $account{'admin_flag'} = $account{'admin'}; }

					}

					# 管理権限が２以上の場合、環境変数を判定する
					if($account{'admin'} >= 2 && !Mebius::alocal_judge()){

						my($allow_flag);
							foreach(@main::master_hosts){
									if($gethost =~ /$_$/){ $allow_flag = 1; }
							}
							if($allow_flag){ $account{'master_flag'} = 1; }
							else{ $account{'admin_flag'} = 0; }
					}


				# ▼SNS内のURLへのアクセスの場合、ログイン履歴を更新
					my($REQUEST_URL) = Mebius::request_url();
					if(time > $account{'last_access_time'}+(10*60)){
					# && ($REQUEST_URL =~ m!^$basic_init->{'auth_url'}! || $ENV{'SCRIPT_NAME'} =~ m!/ff\.cgi$!)

						#my(%option) = Mebius::Auth::Optionfile("Renew Renew-access-time",$account{'file'});
						$type .= qq( Renew); # これ以前の処理で Flock しておく
						$self_renew{'last_access_time'} = time;

							# 投稿履歴ファイルのデータを更新
							#if(rand(100) < 1){ Mebius::HistoryAll("RENEW My-file"); }

					}

					# ▼一定時間ごとにログインの詳細ファイルを更新
					{
	
						my($renew_login_flag);

							if($my_access->{'mobile_id'}){
									if($my_access->{'multi_user_agent_escaped'} ne $account{'last_access_multi_user_agent'}){
										$renew_login_flag = 1;
									}
							}
							else{
									if($ENV{'REMOTE_ADDR'} ne $account{'last_access_addr'}){
										$renew_login_flag = 1;
									}
							}

							if($my_cookie->{'char_escaped'} && $my_cookie->{'char_escaped'} ne $account{'last_access_cookie_char'}){ $renew_login_flag = 1; }

							if($renew_login_flag){
								
								Mebius::Login->login_history("Renew",$account{'file'});
								$self_renew{'last_access_addr'} = $ENV{'REMOTE_ADDR'};
								$self_renew{'last_access_multi_user_agent'} = $my_access->{'multi_user_agent_escaped'};
								$self_renew{'last_access_cookie_char'} = $my_cookie->{'char_escaped'};
								$type .= qq( Renew);


							}
					}

					# URLの引数によっては、管理者権限をなくす
					if($main::in{'admin'} eq "0"){ $account{'admin_flag'} = 0; }

				# グローバル変数に代入
				$main::myadmin_flag = $account{'admin_flag'};

			}

	}

	# CCC 2010/11/28
	# オプションファイルにマイメビ数が無い場合、オプションファイルを更新
	#if($option{'friend_num'} eq "" && $type =~ /Option/){
	#	my(%renew_option);
	#	my(%friend_index) = Mebius::Auth::FriendIndex("Get-hash",$account{'file'});
	#	$renew_option{'friend_num'} = $friend_index{'friend_num'};
	#		if($renew_option{'friend_num'} eq ""){ $renew_option{'friend_num'} = 0; }
	#	Mebius::Auth::Optionfile("Renew",$account{'file'},%renew_option);
	#	Mebius::AccessLog(undef,"Auth-friend-num-fixed");
	#}

	# 旧プロフィール内容を取得
	#if($account{'prof'} eq "" && $account{'lasttime'} <= 1329443400){
	#	my $profile_file = "${account_directory}${file}_prof.cgi";
	#	Mebius::AccessLog(undef,"Open-profile-file","$file");
	#	open($profile_handler,"<",$profile_file);
	#	chomp(my $top_profile = <$profile_handler>);
	#	($account{'prof'}) = split(/<>/,$top_profile);
	#	close($profile_handler);
	#}

	# キーチェック
	if($type =~ /(Not-keycheck|Not-file-check|Get-my-account)/){}
	else{
			if($account{'key'} eq "0"){
					if($main::myadmin_flag){ $error_text = qq(このアカウントは削除済みです。); }
					else{
						close($FILE1);
						main::error("このアカウントは削除済みです。","410 Gone");
					}
			}
			if($account{'key'} eq "2"){
					if($type =~ /Lock-check/ && !$main::myadmin_flag){
						close($FILE1);
						main::error("このアカウントはロック中です。");
					}
			}
	}

	# 編集権限を定義
	if($other_account{'file'} eq $file || $my_account->{'id'} eq $file){ $account{'myprof_flag'} = 1; }
	if($main::myadmin_flag || $account{'myprof_flag'}){ $account{'editor_flag'} = 1; }

	# メルアド配信設定の場合
	if($account{'email'} ne "" && $account{'mlpass'} ne ""){ $account{'sendmail_flag'} = 1; }

	# 履歴の使用状態
	if($account{'orireki'} eq "0" && $account{'ohistory'} =~ /^use-close$/ && !$main::myadmin_flag){ }
	elsif($account{'birdflag'}){ }
	else{ $account{'rireki_flag'} = 1; }

	# あいまい関連の使用状態
	if($account{'okr'} =~ /^not-use$/){ } else { $account{'kr_flag'} = 1; }

	# おすすめＵＲＬの整形
	if($account{'myurl'} && $account{'myurl'} =~ m!^http://([a-zA-Z0-9\.]+)/!){
		if($account{'myurltitle'}){ $mylink = qq(<a href="$account{'myurl'}">$account{'myurltitle'}</a>); }
		else{ $mylink = qq(<a href="$account{'myurl'}" title="$account{'myurl'}">URL</a>); }
	}

	# 最終編集からの時刻で、放置状態を判定する ( ６月以降から始動させる )
	#if($type =~ /Option/ && $main::time > $option{'last_action_time'} + 90*24*60*60){
	#	my $sleep_days = int( ($main::time - $option{'last_action_time'}) / (24*60*60) );
	#	if($sleep_days >= 14000){ $sleep_days = qq(??); }
	#	$account{'let_flag'} = qq(このアカウントは休眠中です ($sleep_days日) 。$account{'name_link'}さんが活動を始めれば解除されます。);
	#}

	# 最終編集からの時刻で、放置状態を判定する
	if(time > $account{'last_action_time'} + 90*24*60*60){
		my $sleep_days = int( (time - $account{'last_action_time'}) / (24*60*60) );
		if($sleep_days >= 14000){ $sleep_days = qq(??); }
		$account{'let_flag'} = qq(このアカウントは休眠中です ($sleep_days日) 。$account{'name_link'}さんが活動を始めれば解除されます。);
	}

	# あいまい関連の取得
	#if($account{'kr_flag'}){
	#	require "${main::int_dir}part_kr.pl";
	#	($account{'kr_oneline'},$account{'kr_flow_flag'}) = main::kr_thread("Oneline Account",$file,undef,5);
	#}

	# 関連記事がある場合
	#if($account{'kr_oneline'}){
	#	my $kr_nextlink;
	#		if($account{'editor_flag'}){ $kr_nextlink = qq( (<a href="./kr-view">→編集</a>)); }
	#		if($account{'kr_flow_flag'}){ $kr_nextlink = qq( (<a href="./kr-view">→続き</a>)); }
	#	$account{'kr_oneline'} = qq(<div class="account_kr"$main::kfontsize_small>関連リンク ( 掲示板 )： $account{'kr_oneline'} $kr_nextlink</div>);
	#	$main::css_text .= qq(div.account_kr{margin:2.0em 0em 1em 0em;font-size:90%;padding:0.5em 1.0em;background:#dee;word-spacing:0.25em;line-height:1.6;});
	#}

	# ●アカウント編集する場合
	if($type =~ /Renew/){

			# 更新する内容（自分のアカウントの場合）
			if($account{'myprof_flag'}){
				($self_renew{'encid'}) = main::id();
				$self_renew{'lasttime'} = time;
				$self_renew{'addr'} = $main::addr;
				$self_renew{'agent'} = $main::agent;
				$self_renew{'cnumber'} = $main::cnumber;
				$self_renew{'last_action_time'} = time;
					if($type =~ /Option/ && $type !~ /Get-my-account/){	$self_renew{'last_action_time'} = time; }
			}

			# 空白値などを補完
			if($account{'char'} eq ""){ $self_renew{'char'} = Mebius::Crypt::char(undef,30); }

		# 全更新回数を増加
		$self_renew{'+'}{'all_renew_count'} = 1;
		$self_renew{'account'} = $file;

		# 任意の更新とリファレンス化
		($renew) = Mebius::Hash::control(\%account,$select_renew,\%self_renew);

			# データフォーマットからファイル更新
			if(!$account{'broken_flag'}){
				Mebius::File::data_format_to_truncate_print(\%data_format,$FILE1,$renew);
			}

		my $renew_utf8 = Mebius::Encoding::hash_to_utf8($renew);
		$renew_utf8->{'account'} = $file;
		Mebius::SNS::Account->update_or_insert_main_table($renew_utf8);

	}

close($FILE1);

	# パーミッション変更
	if($type =~ /Renew/ && !$account{'broken_flag'}){ Mebius::Chmod(undef,$accountfile); }

	# 壊れている場合はデータを復活
	if($account{'broken_flag'}){
		#Mebius::return_backup($accountfile);
	}
	# バックアップを取る
	#elsif($type =~ /Renew/ && !$account{'broken_flag'} && rand(10) < 1){ Mebius::make_backup($accountfile); }


	# ●リファラから、アカウントの関連記事を登録する
	#if($type =~ /Kr-submit/ && $main::referer && !$account{'myprof_flag'}){
	#		if(rand(1) < 1 || $main::alocal_mode){
	#			my($referer_type,$referer_domain,$referer_moto,$referer_number) = Mebius::Referer("Type",$main::referer);
	#				if($referer_type =~ /bbs-thread/){
	#					require "${main::int_dir}part_kr.pl";
	#					main::kr_thread("Renew Account",$file,undef,$referer_domain,$referer_moto,$referer_number);
	#				}
	#		}
	#}

	# リターン
	if($type =~ /Renew/ && %$renew){
			if($type =~ /ReturnRef/){
				return(\%$renew);
			} else{
				return(%$renew);
			}
	}
	else{
			if($type =~ /ReturnRef/){
				return(\%account);
			} else{
				return(%account);
			}

	}

}

#-----------------------------------------------------------
# オプション ・アカウントファイル
#-----------------------------------------------------------
sub Optionfile{

# 宣言
my($nowdate) = Mebius::now_date_multi();
my($type,$file,%renew) = @_;
my($optionfile,$renew_line,%self,$FILE1);

# アカウント名判定
if(Mebius::Auth::AccountName(undef,$file)){ return(); }

# ファイル定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

$self{'file1'} = "${account_directory}${file}_option.log";

	# ファイルを開く
	if($type =~ /File-check-error/){
		$self{'f'} = open($FILE1,"+<$self{'file1'}") || main::error("ファイルが存在しません。");
	}
	else{

		$self{'f'} = open($FILE1,"+<$self{'file1'}");

			# ファイルが存在しない場合
			if(!$self{'f'}){
					# 新規作成
					if($type =~ /Renew/){
						#Mebius::Mkdir(undef,$self{'directory1'});
						Mebius::Fileout("Allow-empty",$self{'file1'});
						$self{'f'} = open($FILE1,"+<$self{'file1'}");
					}
					else{
						return(\%self);
					}
			}

	}

	# ファイルロック
	if($type =~ /Renew|Flock/){ flock($FILE1,2); }

	# トップデータを展開
	for(1..10){
		chomp($self{"top$_"} = <$FILE1>);
	}

# データを分解
# 基本データ
($self{'optionkey'},$self{'last_action_time'},$self{'addr'},$self{'agent'},$self{'cnumber'}) = split (/<>/,$self{'top1'});
# 金貨
($self{'todaypresentgold'},$self{'lastpresentgold'}) = split (/<>/,$self{'top2'});
# 猫
($self{'votepoint'},$self{'todayvotepoint'},$self{'lastvote'}) = split (/<>/,$self{'top3'});
# メっセージ
($self{'last_send_message_yearmonthday'},$self{'today_send_message_num'}) = split (/<>/,$self{'top4'});
# マイメビなど
($self{'deny_count'},$self{'denied_count'},$self{'friend_num'}) = split (/<>/,$self{'top5'});
# 自動更新のログイン時間
($self{'last_access_time'},$self{'last_access_ymdf'},$self{'use_day'},$self{'last_access_yearmonth'},$self{'use_month'}) = split (/<>/,$self{'top6'});
# 各種記録時間
($self{'last_apply_friend_time'},$self{'last_comment_time'}) = split (/<>/,$self{'top7'});
# 投稿時間系
($self{'next_diary_post_time'},$self{'next_comment_time'}) = split (/<>/,$self{'top8'});
# ペナルティ系
($self{'penalty_time'}) = split (/<>/,$self{'top9'});
# Char系
($self{'char'}) = split (/<>/,$self{'top10'});

	# ●最終アクセス時刻を更新する場合
	if($type =~ /Renew-access-time/){
			# 前回の記録より一定時間以内の場合は、リターン
			if(time < $self{'last_access_time'} + (10*60)){
				close($FILE1);
				return();
			}
			# 最終アクセス時刻を更新する場合
			else{ $self{'last_access_time'} = time; }
	}

	# ●ハッシュの調整

	# 数の整形
	if($self{'denied_count'} < 0){ $self{'denied_count'} = 0; }

	# 日にちが更新されている場合、投票ポイントを満タンにする
	if($self{'lastvote'} ne $nowdate->{'ymdf'}){
			if(Mebius::alocal_judge()){ $self{'todayvotepoint'} = 10; }
			else{ $self{'todayvotepoint'} = 3; }
	}

	# 日にちが更新されている場合、今日のメッセージの送信回数をリセットする
	if($self{'last_send_message_yearmonthday'} ne $nowdate->{'ymdf'}){
		$self{'today_send_message_num'} = 0;
	}

	# 同一送信者チェック
	if($self{'agent'} && $self{'agent'} eq $main::agent && $main::k_access){ $self{'sameaccess_flag'} = 1; }
	if($self{'addr'} && $self{'addr'} eq $main::addr && !$main::k_access){ $self{'sameaccess_flag'} = 1; }
	if($self{'cnumber'} && $self{'cnumber'} eq $main::cnumber){ $self{'sameaccess_flag'} = 1; }

	# ●ファイルを更新する場合
	if($type =~ /Renew/){

			# 引継ぎ値に応じてデータを更新する
			foreach(keys %renew){
					if(defined($renew{$_})){ $self{$_} = $renew{$_}; }
					if($_ =~ /^plus->(\w+)$/){ $self{$1} += $renew{$_}; }
			}

			# 自分であれば最終行動日時などを更新
			if($file eq $main::pmfile){
				$self{'last_action_time'} = time;
				$self{'addr'} = $main::addr;
				$self{'agent'} = $main::agent;
				$self{'cnumber'} = $main::cnumber;
			}

			# 空白値などを補完
			if($self{'char'} eq ""){ $self{'char'} = Mebius::Crypt::char(undef,20); }

		# 更新行を定義
		$renew_line .= qq($self{'optionkey'}<>$self{'last_action_time'}<>$self{'addr'}<>$self{'agent'}<>$self{'cnumber'}<>\n);
		$renew_line .= qq($self{'todaypresentgold'}<>$self{'lastpresentgold'}<>\n);
		$renew_line .= qq($self{'votepoint'}<>$self{'todayvotepoint'}<>$self{'lastvote'}<>\n);
		$renew_line .= qq($self{'last_send_message_yearmonthday'}<>$self{'today_send_message_num'}<>\n);
		$renew_line .= qq($self{'deny_count'}<>$self{'denied_count'}<>$self{'friend_num'}<>\n);
		$renew_line .= qq($self{'last_access_time'}<>$self{'last_access_ymdf'}<>$self{'use_day'}<>$self{'last_access_yearmonth'}<>$self{'use_month'}<>\n);
		$renew_line .= qq($self{'last_apply_friend_time'}<>$self{'last_comment_time'}<>$self{'last_getnews_time'}<>\n);
		$renew_line .= qq($self{'next_diary_post_time'}<>$self{'next_comment_time'}<>\n);
		$renew_line .= qq($self{'penalty_time'}<>\n);
		$renew_line .= qq($self{'char'}<>\n);

		# 更新フラグを立てる
		$self{'renewed_flag'} = 1;

		# ファイル更新
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 $renew_line;

	}

close($FILE1);

	# パーミッション変更
	if($type =~ /Renew/){
		Mebius::Chmod(undef,$self{'file1'});
	}



return(%self);

}



#-----------------------------------------------------------
# SNS独自の行動履歴
#-----------------------------------------------------------
sub History{

# 宣言
my($type,$file) = @_;
my(undef,undef,$tofile,$newcomment) = @_ if($type =~ /Renew/);
my($history_handler,$logfile,@renewline,$index_line,$i,$maxrenew);

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ return(); }
$logfile = "${account_directory}${file}_history_auth.log";

	# 相手アカウントの定義
	if($type =~ /Renew/){
		$tofile =~ s/[^0-9a-z]//g;
			if($tofile eq ""){ return(); }
	}

# 最大更新行数
$maxrenew = 100;

# ファイルを開く
open($history_handler,"<$logfile");
if($type =~ /Renew/){ flock($history_handler,1); }

	# ファイルを展開する
	while(<$history_handler>){

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2,$type2,$comment2,$account2,$lasttime2,$date2) = split(/<>/);

				# ●インデックス取得用の処理
				if($type =~ /Index/){
					my(%account) = Mebius::Auth::File("Not-file-check",$account2);
					$index_line .= qq(<div>);
					$index_line .= qq(<a href="$main::auth_url$account2/">$account{'name'} - $account2</a> $comment2);
					$index_line .= qq(</div>);
				}

				# ●ファイル更新用の処理
				if($type =~ /Renew/){
			
					# 最大行を越えた場合
					if($i > $maxrenew){ next; }

					# 更新行を追加
					push(@renewline,"$key2<>$type2<>$comment2<>$account2<>$lasttime2<>$date2<>\n");

				}

	}

close($history_handler);

	# ファイル更新の後処理
	if($type =~ /Renew/){

		# 新しい行を追加
		unshift(@renewline,"1<><>$newcomment<>$tofile<>$main::time<>$main::date<>\n");
	
		# ファイル更新
		Mebius::Fileout("",$logfile,@renewline);
	}

	# インデックス取得の後処理
	elsif($type =~ /Index/){
		return($index_line);

	}


}


#-----------------------------------------------------------
# 新着コメントを取得
#-----------------------------------------------------------
sub News{

# 宣言
my($type,$file,$maxview) = @_;
my(undef,undef,$myfile,$new_handle,$newcomment,$newcommenthidden) = @_ if($type =~ /Renew/);
my($line,$i,$newcomment_handle,$index_line,$flow_flag,$h3,$logfile,@renewline,$i_comment,$log_type,%log_type,$hit_topics);
my($basic_init) = Mebius::basic_init();

	# ログタイプ判定
	if($type =~ /Log-type-(\w+)/){
		$log_type = $1;
	}

	# ファイル定義
	if($file =~ /\W/ || $file eq ""){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
$logfile = "${account_directory}${file}_news.log";

	# 汚染チェック
	if($type =~ /Renew/){

		# アカウント名判定
		if(Mebius::Auth::AccountName(undef,$file)){ return(); }

	}

# ファイルを開く
open($newcomment_handle,"<",$logfile);

	# ファイルロック
	if($type =~ /Renew/){ flock($newcomment_handle,1); }

	# ファイルを展開する
	while(<$newcomment_handle>){

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2,$account2,$handle2,$lasttime2,$date2,$comment2,$commenthidden2,$log_type2) = split(/<>/,$_);

		# ●ファイル更新用の処理
		if($type =~ /Renew/){

				# 最大行数を越えた場合
				if($i >= 50){ last; }

				# ログタイプが同じの場合
				#if($log_type && $log_type2 eq $log_type){ next; }

			# 更新行を追加
			push(@renewline,"$key2<>$account2<>$handle2<>$lasttime2<>$date2<>$comment2<>$commenthidden2<>$log_type2<>\n");

		}

		# ●表示行を定義
		if($type =~ /Get-topics/){

				# 最大行を超過した場合
				if($maxview && $hit_topics >= $maxview){ $flow_flag = 1; last; }
	
				# 同種の情報はエスケープ
				if($log_type2 && $log_type{$log_type2}){ next; }

			# 同種のログタイプをフック
			$log_type{$log_type2} = 1;	

			# ヒットカウンタ
			$hit_topics++;

			my($how_before2) = Mebius::SplitTime("Color-view Get-top-unit Plus-text-前",time - $lasttime2);

			# 整形
			$index_line .= qq(<div>);

			# インデックス行
			$index_line .= qq($comment2);
				if($account2){
					$index_line .= qq( - <a href="$main::auth_url$account2/">$handle2</a>);
				}

			# 整形
			$index_line .= qq(　\ $how_before2</div>\n);

		}

		# ●表示行を定義
		if($type =~ /Index/){

				# 最大行を超過した場合
				if($maxview && $i > $maxview){ $flow_flag = 1; last; }

				# 隠し行の場合
				if($key2 =~ /Hidden-from-index/){ next; }

			my($how_before2) = Mebius::SplitTime("Color-view Get-top-unit Plus-text-前",$main::time - $lasttime2);

			# 整形
			$index_line .= qq(<tr>);

			# インデックス行
			$index_line .= qq(<td>$comment2</td>);
			$index_line .= qq(<td>);
				if($account2){ $index_line .= qq(<a href="$main::auth_url$account2/">$handle2 - $account2</a>); }
			$index_line .= qq(</td>);

				# 時刻
				if($type =~ /All/ && $date2){
					$index_line .= qq(<td>$how_before2</td>);
					$index_line .= qq(<td>$date2</td>);
						if($commenthidden2){ $index_line .= qq(<td>$commenthidden2</td>); }
				}

			# 整形
			$index_line .= qq(</tr>\n);

		}

	}
close($newcomment_handle);

	# ▼ファイルを更新
	if($type =~ /Renew/){

		my($new_key);

			# インデックスから隠す行
			if($type =~ /Hidden-from-index/){ $new_key .= qq( Hidden-from-index); }

		# 新しい行を追加する
		unshift(@renewline,"$new_key<>$myfile<>$new_handle<>$main::time<>$main::date<>$newcomment<>$newcommenthidden<>$log_type<>\n");

		# ファイルを更新
		Mebius::Fileout("",$logfile,@renewline);

	}


	# ▼インデック取得の後処理
	if($type =~ /Get-topics/){


			# 見出しの整形
			if($index_line){
				$h3 = qq(<h3$main::kstyle_h3><a href="$basic_init->{'auth_url'}/$file/news">ニュース</a></h3>\n);
			}
			else{
				$h3 = qq(<h3$main::kstyle_h3>ニュース</h3>\n);
			}

			# 本データの整形
			if($index_line){ $index_line = qq($h3\n<div class="news_list line-height-large">$index_line</div>); }
			else{ $index_line = qq($h3\n<div class="news_list line-height-large">まだありません。</div>); }

			# 続きリンク
			if($index_line){
				$index_line .= qq(<div class="right"><a href="$basic_init->{'auth_url'}/$file/news">→続きを見る</a></div>);
			}

			
		# リターン
		return($index_line);

	}

	# ▼インデック取得の後処理
	if($type =~ /Index/){

			# 見出しの整形
			if($type =~ /All/){ $h3 = qq(<h2$main::kstyle_h2>ニュース</h2>\n); }
			elsif($flow_flag){ $h3 = qq(<h3$main::kstyle_h3><a href="./news">ニュース</a></h3>\n); }
			else{ $h3 = qq(<h3$main::kstyle_h3>ニュース</h3>\n); }

			# 本データの整形
			if($index_line){ $index_line = qq($h3\n<table class="news_list">$index_line</table>); }
			else{ $index_line = qq($h3\n<table class="news_list">まだありません。</table>); }
		
		# リターン
		return($index_line);

	}


}


#-------------------------------------------------
# マイメビ状況をチェック ( $account1 から見ての $account2 の状態 )
#-------------------------------------------------
sub FriendStatus{

# 局所化
my($type,$account1,$account2) = @_;
my($friend_handler,%friend,@renew_line);

# $account = 禁止設定をしている側のアカウント
# $account2 = 禁止設定をされている側のアカウント

	# 汚染チェック
	if(Mebius::Auth::AccountName(undef,$account1)){ return(); }
	if(Mebius::Auth::AccountName(undef,$account2)){ return(); }

# ディレクトリ定義
my($account1_directory) = Mebius::Auth::account_directory($account1);
	if(!$account1_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
my $directory1 = "${account1_directory}friend/";
my $file = "${directory1}${account2}_f.cgi"; # $account1 内の、対 $account2 状態ファイル

	# ログイン中のみ処理実行
	# マイメビ登録済みの場合、フラグを立てる
	open($friend_handler,"<$file");

		# ファイルロック
		if($type =~ /Renew/){ flock($friend_handler,1); }

	# トップデータを分解
	chomp(my $top1 = <$friend_handler>);
	($friend{'key'},$friend{'last_time'}) = split(/<>/,$top1);

	close($friend_handler);

	# マイメビになった日付がない場合、stat データから取得する
	if($friend{'key'} eq "1" && !$friend{'last_time'} && $type =~ /Get-stat/){
		my($stat) = Mebius::file_stat("Get-stat",$file);
		$friend{'last_time'} = $stat->{'last_modified'};
	}

	# ●ファイルを更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

			# マイメビ申請をした場合
			if($type =~ /Apply-friend/){
				$friend{'key'} = 2;
				$friend{'last_time'} = $main::time;
			}

			# マイメビになった場合
			if($type =~ /Be-friend/){
				$friend{'key'} = 1;
				$friend{'last_time'} = $main::time;
			}

			# 禁止設定をした場合
			if($type =~ /Deny-friend/){
				$friend{'key'} = 0;
				$friend{'last_time'} = $main::time;
			}

			# マイメビを削除した場合 ( もともとマイメビでない場合はリターン )
			if($type =~ /Delete-friend/){
					if($friend{'key'} eq "1"){
						$friend{'key'} = "";
						$friend{'last_time'} = $main::time;
					}					else{
						return();
					}
			}

			# マイメビ拒否（申請状態の削除）をした場合 ( もともと申請されていない場合はリターン )
			if($type =~ /Delete-apply/){
					if($friend{'key'} eq "2"){
						$friend{'key'} = "";
						$friend{'last_time'} = $main::time;
					}
					else{
						return();
					}
			}

		# トップデータを追加
		unshift(@renew_line,"$friend{'key'}<>$friend{'last_time'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file,@renew_line);

	}

	# 自分の場合
	if($account1 eq $account2){
		$friend{'status'} = "me";
			if($type =~ /Me-check/){ $friend{'error_message'} = qq(自分です。); }
			if($type =~ /Me-check-error/){ main::error("$friend{'error_message'}"); }
	}

	# 申請中の場合
	elsif($friend{'key'} eq "2"){
		$friend{'status'} = "apply";
			if($type =~ /Still-apply-check/){ $friend{'error_message'} = qq($account1 さんは $account2 さんに、既にマイメビを申\請しています。); }
			if($type =~ /Still-apply-check-error/){ main::error($friend{'error_message'}); }
	}

	# マイメビの場合
	elsif($friend{'key'} eq "1"){
		$friend{'status'} = "friend";
			if($type =~ /Yet-friend-check/){ $friend{'error_message'} = qq($account1 さんと $account2 さんは既にマイメビです。); }
			if($type =~ /Yet-friend-check-error/){ main::error($friend{'error_message'}); }
	}

	# 禁止設定されている場合
	elsif($friend{'key'} eq "0"){
		$friend{'status'} = "deny";
			if($type =~ /Deny-check/){ $friend{'error_message'} = qq($account1 さんは $account2 さんを禁止設定中です。); }
			if($type =~ /Deny-check-error/){ main::error($friend{'error_message'}); }
	}

	# マイメビではない場合
	if($friend{'key'} ne "1"){
				if($type =~ /Friend-check/){ $friend{'error_message'} = qq($account1 さんは$main::friend_tag以外の送信は受け付けていません。); }
				if($type =~ /Friend-check-error/){ main::error($friend{'error_message'}); }
	}


	# ハッシュを返す
	if($type =~ /Get-hash/){
		return(%friend);
	}

return($friend{'status'},$friend{'error_message'});

}

#-----------------------------------------------------------
# 年齢差を判定
#-----------------------------------------------------------
sub AgeGyap{

# 宣言
my($type,$age1,$age2,$allow_gyap) = @_;
my($error_message);

# 年齢ギャップ
if(!$allow_gyap){ $allow_gyap = 1; }

	# 大きい方の年齢を定義
	my $higher_age = $age1;
	my $lower_age = $age2;
		if($age2 > $higher_age){
			$higher_age = $age2;
			$lower_age = $age1;
		}

	# 両方共大人の場合
	if($type =~ /Allow-together-adult/ && $age1 >= 18 && $age2 >= 18){ }
	# 年齢差が ~ 才未満の場合
	elsif($higher_age - $lower_age <= $allow_gyap){ }
	# それ以外の場合
	else{
		$error_message = qq(年齢差があるため、送信できません。);
			if($main::myadmin_flag){ $error_message .= qq( ( * $age1才 / $age2才)); }
	}

	# エラー
	if($error_message && $type =~ /Error-view/){
		main::error($error_message);
	}

return($error_message);

}

#-----------------------------------------------------------
# メール配信
#-----------------------------------------------------------
sub SendEmail{

my($type,$to_account,$from_account,$mail) = @_;
my($body,$subject,$text1,$length,$comment_omited);
my($basic_init) = Mebius::basic_init();

	# 自分自身の書き込みの場合、メールを送信しない
	if($to_account->{'file'} eq $from_account->{'file'}){ return; }

	# メール受信設定のため、メールを送信しない場合
	if($type =~ /Type-message/ && $to_account->{'catch_mail_message'} eq "Not-catch"){ return(); }
	elsif($type =~ /Type-res-diary/ && $to_account->{'catch_mail_resdiary'} eq "Not-catch"){ return(); }
	elsif($type =~ /Type-comment/ && $to_account->{'catch_mail_comment'} eq "Not-catch"){ return(); }
	elsif($type =~ /Type-etc/ && $to_account->{'catch_mail_etc'} eq "Not-catch"){ return(); }

	# 送信先アカウントのメールアドレス登録が無い場合、本認証がされていない場合はリターン
	#if(!$to_account->{'sendmail_flag'}){ return; }

# 送り先の定義 
my $to_address = $to_account->{'remain_email'} || $to_account->{'first_email'};
	if(!$to_address && $to_account->{'sendmail_flag'} && $to_account->{'email'}){ $to_address = $to_account->{'email'}; }

	if(!$to_address){ return; }

	# 本文の省略
	foreach( split(/<br>/,$mail->{'comment'}) ){
			if($length < 50){ $comment_omited .= qq(${_} ); }
		$length += length $_;
	}

	# メール件名を定義
	if($mail->{'subject'} eq ""){
		$subject = qq(メビリンＳＮＳに更新がありました);
	}
	else{
		$subject = $mail->{'subject'};
	}

	# URLが http:// から始まっていない場合は、自動的にSNSのメインURLを付加
	if($mail->{'url'} && $mail->{'url'} !~ /^http/){ $mail->{'url'} = "${main::auth_url}$mail->{'url'}"; }

# メール本文
$body .= qq(【メビリンＳＮＳ】からのお知らせです。\n\n);

	# 省略コメント
	if($comment_omited){ $body .= qq(▼$comment_omited…\n\n); }
	# 更新があったＵＲＬ
	if($mail->{'url'}){
		$body .= qq(▼ＵＲＬ\n);
		$body .= qq($mail->{'url'}\n);
	}

# 配信解除リンク
#$body .= qq(
#---------
#
#▼SNSのメール配信解除(１クリック)
# $basic_init->{'auth_url'}?mode=editprof&type=cancel_mail&account=$to_account->{'file'}&char=$to_account->{'mlpass'}
#);


# メール送信
#Mebius::Email::send_email("Edit-url-plus",$to_account->{'email'},$subject,$body);
Mebius::Email::send_email("Edit-url-plus $type",$to_address,$subject,$body);

}

#-----------------------------------------------------------
# アカウント名のチェック
#-----------------------------------------------------------
sub account_name_error{

my($error_flag) = AccountName(undef,$_[0]);

$error_flag;

}

#-----------------------------------------------------------
# アカウント名のチェック
#-----------------------------------------------------------
sub AccountName{

# 宣言
my($type,$account) = @_;
my($error_flag);

	# アカウント名チェック
	if($account eq ""){
		$error_flag .= qq(アカウント名が指定されていません。);
	}
	elsif($account =~ /\s|　/){
		$error_flag .= qq(アカウント名 ( $account ) に半角スペース、全角スペースが紛れ込んでいます。);
	}

	elsif($account =~ /[^a-z0-9]/){
		$error_flag = qq(アカウント名 ( $account ) は小文字の半角英数字 ( 0-9 a-z ) で指定してください。);
	}

	elsif(length($account) < 3){
		$error_flag = qq(アカウント名 ( $account ) に使えるのは 3文字以上からです。);
	}

	elsif(length($account) > 10){
		$error_flag = qq(アカウント名 ( $account ) に使えるのは 10文字 までです。);
	}

	# ログを取る
	if($error_flag){ 
			if($type =~ /Error-view/){
				#Mebius::AccessLog(undef,"Account-name-format-error-view","アカウント名： $account");
				main::error("$error_flag");
			}
			else{
				#Mebius::AccessLog(undef,"Account-name-format-error-return","アカウント名： $account");
			}
	}

# 二つ以上の変数を返さないように
return($error_flag);

}

#-----------------------------------------------------------
# Charのチェック
#-----------------------------------------------------------
sub CharCheck{

# 宣言
my($type,$char_data,$char_query) = @_;
my($ok_flag);

	# リレー値がない場合、自動的に代入
	if($char_data eq "" && $char_query eq ""){
		$char_data = $main::myaccount{'char'};
		$char_query = $main::in{'account_char'};
	}

	# 判定
	if($char_data eq "" && $char_query){ $ok_flag = 1; }
	elsif($char_data eq $char_query){ $ok_flag = 1; }


	# エラーをすぐ表示
	if($type =~ /Error-view/ && !$ok_flag){# && !$main::alocal_mode
		main::error(qq(なにか変な送信です。<a href="$main::auth_url">SNSのトップページ</a>から入りなおしてください。));
	}

return($ok_flag);

}

#-----------------------------------------------------------
# 重要なアクションを記録するファイル
#-----------------------------------------------------------
sub ImportanceHistoryFile{

# 宣言
my($type,$account) = @_;
my(undef,undef,$new_message) = @_ if($type =~ /New-line/);
my($i,@renew_line,%data,$file_handler);

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
my $directory1 = $account_directory;
my $file1 = "${directory1}important_history_${account}.log";

# 最大行を定義
my $max_line = 500;

	# ファイルを開く
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("ファイルが存在しません。");
	}
	else{
		open($file_handler,"<$file1") && ($data{'f'} = 1);
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($key2,$message2,$cnumber2,$host2,$agent2,$time2) = split(/<>/);

			# 更新用
			if($type =~ /Renew/){

					# 最大行数に達した場合
					if($i > $max_line){ next; }

				# 行を追加
				push(@renew_line,"$key2<>$message2<>$cnumber2<>$host2<>$agent2<>$time2<>\n");

			}


	}

close($file_handler);

	# 新しい行を追加
	if($type =~ /New-line/){
		unshift(@renew_line,"<>$new_message<>$main::cnumber<>$main::host<>$main::agent<>$main::time<>\n");

	}

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);


}



1;
