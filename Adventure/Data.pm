
use strict;
use Mebius::Login;
package Mebius::Adventure;

#-----------------------------------------------------------
# キャラファイルを開く
#-----------------------------------------------------------
sub File{

# 宣言
my($myaccount) = Mebius::my_account();
my($init) = &Init();
my($type,$use) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # 処理タイプを展開
my(%select_renew,%adv,$login_mode,%select_renew,@renew_line,$file_type);
my(undef,undef,$select_renew) = @_ if($type =~ /Renew/);
my($saveline,$id,$certyfied_id,$renew,$StateName1,%self_renew,$broken_file_flag,%data_format);

# IDを定義
$id = $use->{'id'};
$certyfied_id = $use->{'my_id'};


	# モードからファイルタイプを定義
	if($use->{'FileType'} eq "Account"){ $file_type = "Account"; }
	elsif($use->{'FileType'} eq "Cookie"){ $file_type = "Cookie"; }
	elsif($use->{'FileType'} eq "OldId"){ $file_type = "OldId"; }

	# クエリからファイルタイプを定義
	elsif($use->{'InputFileType'} eq "account"){ $file_type = "Account"; }
	elsif($use->{'InputFileType'} eq "cookie"){ $file_type = "Cookie"; }
	elsif($use->{'InputFileType'} eq "old_id"){ $file_type = "OldId"; }
	else{ main::error("アカウントの種類を選択して下さい。"); }

	# ID未入力の場合など 
	#！★ここでちゃんとエラーを出すかリターンしないと、ハッシュが変な箇所に漏れる可能性があるため注意★！ 

	# ●テストプレイヤー ( Cookie )
	if($file_type eq "Cookie"){

			# ★汚染チェック
			if($id =~ /[^a-zA-Z0-9]/){
				main::error("キャラIDが変です。");
			}

		$adv{'FileType'} = $use->{'FileType'};
		$adv{'input_file_type'} = "cookie";
		$adv{'file_type'} = $file_type;
		$adv{'base_directory'} = "$init->{'adv_dir'}_id_testplayer_adv/";
		$adv{'directory'} = "$adv{'base_directory'}${id}_adv/";
		$adv{'file'} = "$adv{'directory'}${id}_adv.dat";
		#$adv{'backup_file'} = "$adv{'directory'}${id}_backup_adv.dat";
		$adv{'test_player_flag'} = 1;
	}

	# ●アカウントプレイヤー
	elsif($file_type eq "Account"){

			# IDが指定されていない場合、不正な場合
			if($id && Mebius::Auth::AccountName(undef,$id)){

					# テストプレイヤー用の特殊アカウント ( test ) を使う場合
					#if($use->{'Multi-test-player'}){
					#	$adv{'test_player_flag'} = 1;
					#	$id = "test";
					#	$certyfied_id = "test";
					#}
					# エラーを表示する場合
					#else{
					#if(!&Mebius::alocal_judge()){
							main::error("アカウント名が変です。");
					#}
					#}
			}
			# IDが正しい場合
			else{

				$adv{'FileType'} = $use->{'FileType'};
				$adv{'input_file_type'} = "account";
				$adv{'file_type'} = $file_type;
				$adv{'base_directory'} = "$init->{'adv_dir'}_id_adv/";
				$adv{'directory'} = "$adv{'base_directory'}${id}_adv/";
				$adv{'file'} = "$adv{'directory'}${id}_adv.dat";
				$adv{'backup_file'} = "$adv{'directory'}${id}_backup_adv.dat";
				$adv{'overwrite_file'} = "$adv{'directory'}${id}_overwrite_adv.dat";
				$adv{'formal_player_flag'} = 1;

			}
	}

	# ●旧IDファイル
	elsif($file_type eq "OldId"){

			# ★汚染チェック
			if($id =~ /[^a-zA-Z0-9]/){
				main::error("キャラIDが変です。");
			}

		$adv{'FileType'} = $use->{'FileType'};
		$adv{'input_file_type'} = "old_id";
		$adv{'file_type'} = $file_type;
		$adv{'directory'} = "$init->{'adv_dir'}_charadata_adv/";
		$adv{'file'} = "$adv{'directory'}${id}_adv.cgi";
		$adv{'old_player_flag'} = 1;
	}

	# その他
	else{
		main::error("アカウントの種類を選択して下さい。");
	}

	# 正式なプレイヤーでないとエラーにする場合
	if($use->{'FormalPlayerCheckAndError'} && !$adv{'formal_player_flag'}){
		&main::error("アカウント登録されているプレイヤーでないと、この操作は実行できません。");
	}

	# ★IDが無指定の場合 ( ファイル名などの情報は返すように、ファイル名定義が終わった位置 )
	if($id eq ""){ 
			if($type{'Allow-empty-id'}){ return(\%adv); }
			else{ main::error("IDを指定してください。"); }
	}

	# 新規登録の場合
	if($type =~ /New-character/ || $use->{'TypeTrance'}){
			if(-f $adv{'file'}){ main::error("このIDのキャラクタは既に存在します。"); }
			else{
				Mebius::Mkdir(undef,$adv{'base_directory'});
				my($mkdir_success) = Mebius::Mkdir(undef,$adv{'directory'});
					if(!$mkdir_success){ main::error("キャラクタを作成できませんでした。既に同じアカウント名のキャラクタが存在するか、キャラクタ数が上限を超えている可\能\性があります。"); }
			}
	}
	# 自分かどうかをチェック
	if($type{'Password-check'}){
		my($advmy) = my_data(); # ループに注意
			if(!$id){ main::error("IDを指定してください。"); }
			if(!$certyfied_id){ main::error("ログインしていません。"); }
			#if(!$adv{'formal_player_flag'}){ &main::error(""); }
			if($certyfied_id ne $id){
				Mebius::AccessLog(undef,"Adventure-strange-login-action","$certyfied_id ne $id");
				main::error("自分のデータではありません。");
			}
			if($certyfied_id ne $advmy->{'id'}){ main::error("自分のデータではありません。"); }
			if($advmy->{'file_type'} ne $adv{'file_type'}){ main::error("自分のデータではありません。"); }
			# && !$myaccount->{'master_flag'}
	}
	
	# テストプレイヤーの実行を禁止する場合
	if($use->{'TypeDenyTestPlayer'} && $adv{'test_player_flag'}){
		main::error("テストプレイ中は実行できません。");
	}

	# タイプ追加
	if($type{'Password-check'}){ $type .= qq( File-check-error); }
	if($type !~ /New-character/ && !$use->{'TypeTrance'}){ $type .= qq( Deny-touch-file); }


	if($type =~ /Base-mydata/){
		$type .= " Flock2";
	}

# ファイルを開く
my($FILE1,$read_write) = Mebius::File::read_write($type,$adv{'file'},[$adv{'directory'}]);
	if($read_write->{'f'}){ %adv = (%adv,%$read_write); } else { return(\%adv); }	

# 任意のキャラデータを認識
$adv{'id'} = $id;

$data_format{'1'} = [('pass','name','sex','pr','comment','url','waza','hashed_password','salt','concept')];
$data_format{'2'} = [('level','hp','maxhp','exp','gold','karman','total','win','job','jobname','jobrank','spatack','spodds','bank','charity','autobank')];
$data_format{'3'} = [('power','brain','believe','vital','tec','speed','charm')];
$data_format{'4'} = [('item_number','item_name','item_damage','item_job','item_damage_plus','item_concept')];
$data_format{'5'} = [('mons','host','lasttime','agent','number','encid','account','charge_end_time')];
$data_format{'6'} = [('lastwinid','sp','char','draw','allaction')];
$data_format{'7'} = [('top_monster_level','jobmatch','jobconcept','lastmodified','today_action','today_action_date')];
# 変な行動対策のための値
$data_format{'8'} = [('break_missed','break_char','today_action_buffer',undef,'block_time')];
# 行動の種類を記憶している部分 
$data_format{'9'} = [('last_select_monster_rank','last_select_special_id')];
# 初期データ
$data_format{'10'} = [('first_time','first_host','first_agent')];
# データ移行履歴
$data_format{'11'} = [('trance_to_account','trance_to_time','trance_from_account','trance_from_time')];
# カウント系 ( モンスターとの戦闘 )
$data_format{'12'} = [('monster_battle_count','monster_battle_win_count','monster_battle_lose_count','monster_battle_draw_count')];
# カウント系 ( 対人戦、実力下の相手と戦ったか、実力上の相手と戦ったか )
$data_format{'13'} = [('human_battle_win_champ_count','human_battle_stay_champ_count','human_battle_dog_count','human_battle_chicken_count','human_battle_keep_count')];
# 新ステータス
$data_format{'14'} = [('all_level','brave')];
# 各種履歴カウント (簡素系)
$data_format{'15'} = [('yado_count','last_yado_time')];
# 各種履歴カウント (人生系)
$data_format{'16'} = [('job_change_count','name_change_count','sex_change_count')];
# ギャンブル関係?
$data_format{'17'} = [('last_gamble_time','last_gamble_lot_gold','last_gamble_win_gold','last_gamble_result')];

# 効果系
$data_format{'31'} = [('effect_levelup_boost')];
$data_format{'32'} = [('effect_levelup_boost_time')];


	# トップデータを読み込み
	my($split_data) = Mebius::file_handle_to_hash(\%data_format,$FILE1);
	%adv = (%adv,%$split_data);

		# 2012/3/8 (木)
		if($adv{'effect_levelup_boost_time'} > time + 3*60*60){
			$adv{'effect_levelup_boost_time'} = time + 30*60;
		}

		# 2012/3/9 (金)
		if($adv{'all_level'} < $adv{'level'}){
			$adv{'all_level'} = $adv{'level'} * 1.5;
		}

	# チャージ時間が終わってない場合のエラー
	# 多重処理を狙った不正行為を防止するため、必ずこのサブルーチンの中で実行しておく
	if($use->{'TypeChargeTimeCheckError'} && time < $adv{'charge_end_time'}){
		close($FILE1);
		main::error("まだチャージ時間が終わっていません。");
	}

	# 名前がないとデータが壊れているかもしれないと判定してエラーに
	if(!$adv{'file_touch_flag'} && ($adv{'name'} eq "" || $adv{'level'} eq "")){
		$broken_file_flag = 1;
	}

	# ログインチェック
	if($type =~ /Base-mydata/){


			# ループを禁止
			if($type =~ /Password-check/){ die("Perl Die! Careful for rooping."); }

			# 成功
			if($id && $certyfied_id && $id eq $certyfied_id){
				$adv{'login_flag'} = 1;
			}
			# 失敗
			else{
				close($FILE1);
				return();
			}
	}



	# ●今日の行動回数が多い場合、フラグを立てる
	if($adv{'today_action'} >= 5*60){
		# 行動回数が多い場合に、表示/処理方法を変えるためのフラグを立てる
		$adv{'over_action_flag'} = 1;
			# アクセスログの記録
			if($type =~ /Charge-time/){
				Mebius::AccessLog(undef,"Adventure-today-action-over","キャラID：$adv{'id'} / 今日の行動回数： $adv{'today_action'}回");
			}
	}

	# ●一定期間の利用禁止
	if($type =~ /Password-check/){
				if($adv{'block_time'} && time < $adv{'block_time'}){
					my($left_date) = Mebius::SplitTime("Get-top-unit",$adv{'block_time'} - $main::time); 
					close($FILE1);
					main::error("このキャラクター ( $adv{'id'} ) はしばらく利用できません。(残り$left_date)");
				}
	}

	# ●行動回数が多い場合、一定間隔で数字入力画面を出す
	if($type =~ /Base-mydata/ && $adv{'today_action_buffer'} >= $init->{'break_interval'}){

		# アクセスログへの記録内容
		my $record_accesslog = qq(キャラID： $adv{'id'} /  確認番号：$adv{'break_char'} / 入力番号： $main::in{'break_char'} / 行動回数： $adv{'today_action_buffer'} / 失敗回数 $adv{'break_missed'} / URL： http://aurasoul.mb2.jp/gap/ff/ff.cgi?mode=chara&chara_id=$adv{'id'} );

		# フラグを立てる
		$adv{'strange_flag'} = 1;

			# 入力番号の全角を半角に
			my($break_char_input) = Mebius::Number(undef,$main::in{'break_char'});
			$break_char_input =~ s/(^\s|\s$)//g;


			# 認証に成功した場合、カウンタをリセットする
			if($break_char_input eq $adv{'break_char'}){

				# ここで %renew を代入しないと、全てのデータが消えてしまうので注意！！
				#%renew = %adv;
				$type{'Renew'} = 1;

				# 値の操作
				$self_renew{'break_missed'} = 0;
				$self_renew{'today_action_buffer'} = 0;
				$self_renew{'strange_flag'} = 0;	# この値を更新するわけではないけど、最後にハッシュとして %renew を返すため、このように書く
				Mebius::AccessLog(undef,"Adventure-successed-break","$record_accesslog");

			}

			# 認証に失敗した場合、確認番号を変更し、失敗カウンタを増やす
			else{

				# ここで %renew を代入しないと、全てのデータが消えてしまうので注意！！
				#%renew = %adv;
				$type{'Renew'} = 1;

				# 値の操作
				$self_renew{'break_missed'} = $adv{'break_missed'} + 1;
				$self_renew{'break_char'} = int rand(9999);
				Mebius::AccessLog(undef,"Adventure-missed-break","$record_accesslog");

					# 失敗回数がオーバーした場合、一定期間、キャラデータの利用を制限する
					if($self_renew{'break_missed'} >= 10 + 1){
						$self_renew{'today_action_buffer'} = 0;
						$self_renew{'break_missed'} = 0;
						$self_renew{'block_time'} = time + 7*24*60*60;
						$self_renew{'strange_flag'} = 0;
						Mebius::AccessLog(undef,"Adventure-deny-break","$record_accesslog");
					}
			}

	}

	# 日付が変わった場合、今日の行動回数をリセット ( Strange フラグ立っていない場合 )
	elsif("$main::thisyearf-$main::thismonthf-$main::todayf" ne $adv{'today_action_date'}){

		$self_renew{'today_action'} = 0;
		$self_renew{'today_action_buffer'} = 0;
	}

	# まったく同じ内容のポストを禁止
	if($type =~ /Char-check/ || exists $use->{'input_char'}){
			# 前回更新から一定時間内のみ判定
			if($adv{'char'} && time < $adv{'lasttime'} + 30*60*60 && !$myaccount->{'master_flag'}){ 
					if($use->{'input_char'} eq ""){
						close($FILE1);
						main::error("何か変な送信です。TOPページに戻ってやり直してください。");
					}
					if($adv{'char'} ne $use->{'input_char'}){
						close($FILE1);
						main::error(qq(続けて２回以上、同じ内容を送信することは出来ません。ブラウザの「画面更新」や「戻る」ボタンを使うと、この現象が起こる場合があります。うまく行かない場合は<a href="$init->{'script'}">トップページ</a>からアクセスしなおしてください。));
					}
			}
	}

# 経験値
$adv{'next_exp'} = $adv{'level'} * $init->{'lv_up'};
	if($adv{'jobname'} =~ /^(忍者|修行僧)$/){ $adv{'next_exp'} *= 1.30; }
	elsif($adv{'jobname'} =~ /^(司教|踊り子|君主|\Qヴァルキリー\E|侍)$/){ $adv{'next_exp'} *= 1.15; }
	elsif($adv{'jobname'} =~ /^(戦士)$/){ $adv{'next_exp'} *= 0.85; }
	if($adv{'level'} >= 100000){ $adv{'next_exp'} *= 1.35; }
	elsif($adv{'level'} >= 50000){ $adv{'next_exp'} *= 1.30; }
	elsif($adv{'level'} >= 25000){ $adv{'next_exp'} *= 1.25; }
	elsif($adv{'level'} >= 10000){ $adv{'next_exp'} *= 1.20; }
	elsif($adv{'level'} >= 5000){ $adv{'next_exp'} *= 1.10; }
	elsif($adv{'level'} >= 1000){ $adv{'next_exp'} *= 1.05; }
$adv{'next_exp'} = int $adv{'next_exp'};

	# ●ハッシュ値を元にフラグを立てる
	{

			# 待ち時間
			if($adv{'charge_end_time'} && time < $adv{'charge_end_time'}) {
				$adv{'wait_disabled'} = $main::disabled;
				$adv{'still_charge_flag'} = 1;
				$adv{'waitsec'} = $adv{'charge_end_time'} - time;
			}

		# ハッシュを設定（特殊）
		if($adv{'jobname'} eq '踊り子'){ $adv{'redun'} = int($init->{'redun'} * 0.83);  } else{ $adv{'redun'} = $init->{'redun'};  }

		$adv{'item_damage_all'} = $adv{'item_damage'} + $adv{'item_damage_plus'}; 
			if($file_type eq "OldId"){
				$adv{'chara_url'} = "$init->{'script'}?mode=chara&amp;chara_id=$adv{'id'}";
			}
			elsif($file_type eq "Account"){
				$adv{'chara_url'} = "$init->{'script'}?mode=status&amp;id=$adv{'id'}";
			}

		$adv{'chara_link'} = qq(<a href="$adv{'chara_url'}">$adv{'name'}</a> ( Lv$adv{'level'} $adv{'jobname'} ) );

		my $buf = $adv{'total'}-$adv{'draw'};
			if($buf){ $adv{'winodds'} = int( ( $adv{'win'} / $buf ) * 100 ); }
			else{ $adv{'winodds'} = 0; }

			$adv{'lose'} = $adv{'total'} - $adv{'win'} - $adv{'draw'};

			# アイテム
			if($adv{'sex'} eq "1"){ $adv{'sextype'} = "男"; } else { $adv{'sextype'} = "女"; }

	}

	# ●ファイル更新
	if($type{'Renew'}){

			# ●自分のデータの場合、IPなどのデータを更新
			if($type =~ /(MYDATA|Mydata)/ && $adv{'id'} eq $use->{'my_id'}){

				# 各種接続データを取得
				($self_renew{'host'}) = Mebius::GetHostWithFile();
				$self_renew{'number'} = $main::cnumber;
				($self_renew{'encid'}) = main::id();
				$self_renew{'agent'} = $main::agent;
				$self_renew{'account'} = $main::pmfile;
				$self_renew{'break_char'} = int rand(9999);

				# データ修正
				if($adv{'all_level'} eq ""){ $self_renew{'all_level'} = int($adv{'total'}*2); }
				#$self_renew{'autobank'} =~ s/^(0+)//g;	# CCC 2012/1/8 (日)

				# 行動用のCharを設定
				$self_renew{'char'} = Mebius::Crypt::char(undef,50);

					# ▼今日の行動回数 / 次回のチャージ時間を記録
					if($type =~ /Charge-time/){

						# チャージ時間
						my($wait_second_by);
						$self_renew{'charge_end_time'} = time + $adv{'redun'};

						# 他のデータ
						$self_renew{'lasttime'} = time;
						$self_renew{'today_action_date'} = qq($main::thisyearf-$main::thismonthf-$main::todayf);
						$self_renew{'+'}{'today_action'} = 1;
						$self_renew{'+'}{'today_action_buffer'} = 1;
					}

			}

			($renew) = Mebius::Hash::control(\%adv,\%self_renew,$select_renew);

			# キャラ固体ファイルを更新
			if(!$broken_file_flag){
				Mebius::File::data_format_to_truncate_print(\%data_format,$FILE1,$renew);
			}

	}



close($FILE1);



	# キャラファイルのパーミッション変更
	if($type{'Renew'} && !$broken_file_flag){
		#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($adv{'today_action_buffer'} / $renew->{'today_action_buffer'})); }
		Mebius::Chmod(undef,$adv{'file'});
	}

	# ファイル復元
	if($broken_file_flag){

		# 復元を実行
		my($flag) = Mebius::return_backup($adv{'file'});
			# 復元に成功
			if($flag == 1){ main::error(" $id のデータ消失により、キャラデータをバックアップから復元しました。画面を更新してください。"); }
			# 復元に失敗
			else{
				Mebius::AccessLog(undef,"Adventure-broken-account-file","アカウント： $id 名前 : $adv{'name'} / $flag");
				main::error("$id のキャラデータが消失している可\能\性があります。");
			}

	# バックアップ
	} elsif($type{'Renew'} && (rand(100) < 1 || Mebius::alocal_judge())){
		Mebius::make_backup($adv{'file'});
	}

	# ▼ランキングファイルを更新
	if($type{'Renew'} && $file_type eq "Account"){
		require Mebius::Adventure::Ranking;
		&RankingFile({ TypeRenew => 1 , TypeNewStatus => 1 },{},$renew);
	}

	# リターン
	if($type{'Renew'}){
		return($renew);
	}
	else{
		return(\%adv);
	}

}



1;

