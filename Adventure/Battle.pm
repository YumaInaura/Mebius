
package Mebius::Adventure;
use Mebius::Adventure::Adjust;
use CGI;
use strict;

#-----------------------------------------------------------
# 戦闘
#-----------------------------------------------------------
sub Battle{

# 宣言
my($init) = &Init();
my($init_login) = init_login();
my($advmy) = Mebius::Adventure::my_data();
my($i,$j,$ltime,$win,$lose,$enemy_win,$enemy_lose,$h1,$skill2dmg1,$skilldmg1,$exp,$gold);
my($monster_exp,$champwin_exp,$winlose_text,$bank);
my($turn_results,$enemy,$comment,$battle_start_message,$print);
my($enemy_id,$draw_flag,$monster_rank);
my($select_battle_mode,$champ_battle_flag,$save_khp_comma,$save_whp_comma,$kmaxhp_comma,$wmaxhp_comma,$sametime_down_flag);
my($pure_gold,$champ_change_flag,$mychamp_flag);
my($levelup_comment_line,$comment_hp_line,$BattleMode);
my($alocal_mode) = Mebius::alocal_judge();

# アクセス制限
main::axscheck("Post-only ACCOUNT");

#  タイトル定義
$main::sub_title = qq(戦闘 | $main::title);
$main::head_link3 = qq(&gt; 戦闘);

# CSS定義
$main::css_text .= qq(
table,tr,th,td{border:solid 1px #272;}
h2{background:#fcc;padding:0.3em 0.5em;text-align:center;font-size:120%;font-weight:normal;clear:both;}
strong.spatack{font-size:120%;color:#f00;}
div.turn{clear:both;}
div.atack_left{word-wrap:break-word;word-break:break-all;float:left;width:49%;margin-bottom:0.1em;}
div.atack_right{word-wrap:break-word;word-break:break-all;float:right;width:49%;margin-bottom:0.1em;}
div.result_comment{line-height:2.0;}
div.comment_atack{line-height:2.0;}
h3{margin-top:0em;font-size:140%;}
.clitical{color:#f00;font-size:130%;}
.bluefire{font-size:140%;color:#00f;}
.damage{color:#f00;}
.special{color:#080;}
);
if($main::mode eq "monster"){ $main::css_text .= qq(h2{background:#cdf;}\n); } 

if(Mebius::alocal_judge()){
#$main::css_text .= qq(div.comment_atack{background:#ff0;});
}

# チャンプに勝つと ～倍の経験値を獲得
$champwin_exp = 10;

# ロック開始
Mebius::lock("Adventure-action-$advmy->{'id'}");

	# 自分のファイルを開く
	my($adv) = &File("Action Flock Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1 , input_char => $main::in{'char'} , TypeChargeTimeCheckError => 1 });

# 多重処理テスト
#if(Mebius::alocal_judge()){ sleep(5); }

# チャンプファイルを読み込む
my($champ) = &ChampFile();

	# 自分がチャンプの場合はフラグを立てる ( 対人戦 / モンスター戦を問わない )
	if($champ->{'id'} eq $adv->{'id'}){ $mychamp_flag = 1; }

	# ●キャラクターとの戦闘 
	if($main::mode eq "battle"){

		# モンスターとの戦闘が多すぎる場合
		if($adv->{'human_battle_keep_count'} >= 3) { main::error("一度モンスターと闘ってください"); }

		# バトルモード
		$BattleMode = "Human";

			# 好きな相手を選んで戦闘
			if($main::in{'target_id'} && $main::in{'target_id'} ne $champ->{'id'}){
				$enemy_id = $main::in{'target_id'};
				$select_battle_mode = 1;

				# 相手ファイルを開く
				($enemy) = &File("File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $enemy_id , FormalPlayerCheckAndError => 1 });

			}

			# チャンピオンと戦闘
			else{

				$enemy_id = $champ->{'id'};
				$champ_battle_flag = 1;

				# 相手ファイルを開く
				($enemy) = &File("Allow-empty-id",{ InputFileType => $main::in{'file_type'} , id => $enemy_id , FormalPlayerCheckAndError => 1});

					# チャンピオン不在の場合、そのまま商社に
					if($enemy->{'id'} eq ""){

						# ファイル更新
						my(%renew_champ);
						$renew_champ{'id'} = $adv->{'id'};
						$renew_champ{'name'} = $adv->{'name'};
						$renew_champ{'win_count'} = 1;
						&ChampFile({ TypeRenew => 1 },\%renew_champ);
			
						# HTMLを表示
						$print = qq(ペリカン大王をしりぞけ、あなたがチャンピオンになりました！ $init->{'continue_button'});
						Mebius::Template::gzip_and_print_all({},$print);

						exit;

					}

			}

			# 職業同士の相性を判定（自分に有利な場合）
			foreach(split(/,/,$adv->{'jobmatch'})){
					if($_ eq $enemy->{'jobname'}){
						$enemy->{'buffer_jobmatch'} = 1;
						$battle_start_message .= qq(「$enemy->{'jobname'}」とは<strong style="color:#f00;">たやすい</strong>職業だ……！<br$main::xclose>);
					}
			}

			# 職業同士の相性を判定（相手に有利な場合）
			foreach(split(/,/,$enemy->{'jobmatch'})){
					if($_ eq $adv->{'jobname'}){
						$adv->{'buffer_jobmatch'} = 1;
						$battle_start_message .= qq(「$enemy->{'jobname'}」とは<strong style="color:#00f;">手強い</strong>職業だ……！<br$main::xclose>);
					}
			}

			if($enemy_id eq $adv->{'id'} && !Mebius::alocal_judge()){ main::error("自分とは戦えません。"); }

			# レベル差判定
			if($select_battle_mode){
					#if($adv->{'maxhp'} > $enemy->{'maxhp'}*$init->{'select_battle_gyap'} && !$alocal_mode){ main::error("最大HPが違いすぎる相手とは戦えません。"); }
					if(time > $enemy->{'lasttime'}+$init->{'charaon_day'}*24*60*60){ main::error("しばらくログインしていない相手とは戦えません。"); }
					if($enemy_id eq $adv->{'lastwinid'} && !Mebius::alocal_judge()){ main::error("前回倒したキャラクターとは連続して戦えません。"); }
			}

	}

	# ●モンスターとの戦闘
	if($main::mode eq "monster"){

		# 局所化
		my(@monster,$monster_handler);

		# バトルモード
		$BattleMode = "Monster";

		# 汚染チェック
		$monster_rank = $main::in{'m_type'};
			if($monster_rank =~ /\D/){ main::error("モンスターの指定が変です。"); }

		# モンスターのパラメータ
		$enemy->{'rank'} = $monster_rank;
		$enemy->{'brave'} = ($monster_rank*5);

		# 前レベルのモンスターにまだ勝っていない場合
		if($monster_rank >= 1 && $adv->{'top_monster_level'} < $monster_rank && !Mebius::alocal_judge()){
				main::error("このレベルのモンスターとはまだ戦えません。");
		}

		# モンスターとの戦闘が多すぎる場合
		if(!$adv->{'mons'} && !Mebius::alocal_judge()) { main::error("一度キャラクターと闘ってください"); }

		# ファイルを開く
		open($monster_handler,"<","$init->{'adv_dir'}_monster_data_adventure/monster$monster_rank.dat") || main::error("モンスターファイルが開けません。");
			while(<$monster_handler>){
				push(@monster,$_);
			}
		close($monster_handler);
		
		# モンスターをランダムで選ぶ
		my $random = int(rand(@monster));
		my($mname,$mex,$mhp,$mdmg,$mskill,$mspecial) = split(/<>/,$monster[$random]);
		
		# 暫定ＨＰを定義
		$enemy->{'hp'} = $enemy->{'maxhp'} = int($mhp*0.5) + int(rand($mhp*0.6));

		# モンスターの強さを代入
		$monster_exp = int( ($mex * 0.7) + rand($mex*0.3*2) );
		$enemy->{'name'} = $mname;
		$enemy->{'buffer_monster_damage'} = $mdmg;
		$enemy->{'buffer_monster_skill'} = $mskill;
		$enemy->{'waza'} = $mspecial;
			if($enemy->{'waza'} eq ""){ $enemy->{'waza'} = qq(ゴォォォォ！); }
		$enemy->{'spodds'} = 7;
		$enemy->{'spatack'} = "必殺技";
		$enemy->{'buffer_monster_flag'} = 1;

		# モンスターレベルを定義
		$enemy->{'level'} = $monster_rank*$monster_rank*$monster_rank*25;

		# 武器を使わない場合
		#if($adv->{'jobconcept'} =~ /Magician-job/){
		#	$battle_start_message .= qq(精神集中のため、武器は使わないことにする。<br$main::xclose>);
		#	$adv->{'buffer_wepon_notuse'} = 1;
		#}

	}

	# ●キャラクター戦/モンスター戦で共通の判定

	# 自分の職業に合った武器は威力を発揮
	if($adv->{'jobconcept'} =~ /Fighter-job/){
		foreach(split(/,/,$adv->{'item_job'})){
			if($adv->{'jobname'} eq $_){
				$adv->{'buffer_good_wepon'} = 1;
				$battle_start_message .= qq(やはり自分に合った武器は使いやすい。<br$main::xclose>);
			}
		}
	}

	# 相手の職業に合った武器は威力を発揮
	if($enemy->{'jobconcept'} =~ /Fighter-job/){
		foreach(split(/,/,$enemy->{'item_job'})){
			if($enemy->{'jobname'} eq $_){
				$enemy->{'buffer_good_wepon'} = 1;
			}
		}
	}

# ターン定義
$i = 1;

	# 戦闘ターンを展開
	foreach(1..20) {

		# 局所化
		my($dmg1,$dmg2,$com1,$com2,$repair1,$repair2);

		# 自分の攻撃 ( 相手のダメージ計算 )
		($dmg1,$repair1,$com1) = &DamageBattle({ BattleMode => $BattleMode , ChampBattleFlag => $champ_battle_flag , TypeOffence => 1 , turn => $i },$adv,$enemy);

		# 敵の攻撃 ( 自分のダメージ計算 )
		($dmg2,$repair2,$com2) = &DamageBattle({ BattleMode => $BattleMode , ChampBattleFlag => $champ_battle_flag , TypeDefence => 1 , turn => $i },$enemy,$adv);

		# カンマを付ける
		($kmaxhp_comma,$wmaxhp_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$adv->{'maxhp'},$enemy->{'maxhp'}]);

		# ターン結果表示の追加
		($save_khp_comma,$save_whp_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$adv->{'hp'},$enemy->{'hp'}]);

		$turn_results .= qq(<div class="turn"><h2>ターン$i</h2>);

		$turn_results .= qq(<div class="atack_left">);
		$turn_results .= qq(<h3><strong class="hpcolor">HP $save_khp_comma / $kmaxhp_comma</strong></h3>);
		$turn_results .= qq(
		<div class="comment_atack">
		$com1
		</div>
		<br>
		</div>
		);

		$turn_results .= qq(<div class="atack_right">);
		$turn_results .= qq(<h3><strong class="hpcolor">HP $save_whp_comma / $wmaxhp_comma</strong></h3>);
		$turn_results .= qq(
		<div class="comment_atack">
		$com2
		</div>
		<br>
		</div>
		);

		$turn_results .= qq(</div>);

		# 暫定ＨＰの計算
		$adv->{'hp'} = $adv->{'hp'} - $dmg2 + $repair1;
		$enemy->{'hp'} = $enemy->{'hp'} - $dmg1 + $repair2;
			if($adv->{'hp'} >= $adv->{'maxhp'}){ $adv->{'hp'} = $adv->{'maxhp'}; }
			if($enemy->{'hp'} >= $enemy->{'maxhp'}){ $enemy->{'hp'} = $enemy->{'maxhp'}; }
			if($adv->{'hp'} <= 0){ $adv->{'hp'} = 0; }
			if($enemy->{'hp'} <= 0){ $enemy->{'hp'} = 0; }

		# HP再計算
		($save_khp_comma,$save_whp_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$adv->{'hp'},$enemy->{'hp'}]);

			# どちらかが負けた場合、ターン終了
			if($adv->{'hp'} <= 0 && $enemy->{'hp'} <= 0){
				$sametime_down_flag = 1;
					# 勇気で判定
					if(rand($adv->{'brave'}+75) >= rand($enemy->{'brave'}+50)){ $win = 1; }
					else{ $lose = 1; }
				last;
			}
			# 挑戦者の勝ち
			elsif($enemy->{'hp'} <= 0) { $win = 1; last; }
			# 相手の勝ち
			elsif($adv->{'hp'} <= 0) { $lose = 1; last; }

		$i++;
	}

	# 勝敗の調整
	if($win){
		$enemy_lose = 1;
	}
	elsif($lose){
		$enemy_win = 1;
	}
	else{
		$draw_flag = 1;
	}

# 連続行動を禁止
Mebius::Redun(undef,"ADV_ACTION",$adv->{'redun'});

	# チャンプファイルの更新 （挑戦者の勝利）
	if($win && $main::mode eq "battle" && $champ_battle_flag){
		$champ_change_flag = 1;

		# ファイル更新
		my(%renew_champ);
		$renew_champ{'id'} = $adv->{'id'};
		$renew_champ{'name'} = $adv->{'name'};
		$renew_champ{'win_count'} = 1;
		&ChampFile({ TypeRenew => 1 },\%renew_champ);

	}

	# チャンプファイルの更新 （チャンプの勝利）
	if($enemy_win && $main::mode eq "battle" && $champ_battle_flag){

		# ファイル更新
		my(%renew_champ);
		$renew_champ{'id'} = $enemy->{'id'};
		$renew_champ{'name'} = $enemy->{'name'};
		$renew_champ{'+'}{'win_count'} = 1;
		my($renewed_champ) = &ChampFile({ TypeRenew => 1 },\%renew_champ);

			# 戦況を記録
			if($renewed_champ->{'win_count'} % 10 == 0 && $renewed_champ->{'win_count'} >= 10 && !$adv->{'test_player_flag'}){
				my $NewComment1 = qq($enemy->{'chara_link'} が);
				my $NewComment2 = qq(<span class="red">$renewed_champ->{'win_count'}連勝</span> を達成しました。);
				&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
			}

		# 連勝記録ファイルの更新
		require Mebius::Adventure::Record;
		&Record("Renew","",$enemy->{'name'},$renewed_champ->{'win_count'},$enemy->{'id'});

	}

	# 行動記録
	if($win){ $winlose_text = qq(戦いを挑んで <span class="red">勝利</span> しました。); }
	else{ $winlose_text = qq(戦いを挑みました。); }  
	if($champ_battle_flag){ $enemy->{'chara_link'} = qq($enemy->{'chara_link'} - <span class="red">チャンプ</span> ); }

	# 戦況を記録
	if($main::mode eq "battle" && !$adv->{'test_player_flag'}){
		my $NewComment1 = qq($adv->{'chara_link'} が);
		my $NewComment2 = qq($enemy->{'chara_link'} に$winlose_text);
		&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
	}

	# 勝った場合 （対人戦）
	if($win && $main::mode eq "battle") {

		$exp = int($enemy->{'level'}*$init->{'kiso_exp'}*0.8) + int($enemy->{'maxhp'}*0.2);
			if($champ_battle_flag){ $exp *= $champwin_exp; }
		$gold = $enemy->{'level'} * 7 + int(rand($enemy->{'level'} * 6));

			# 戦況を記録
			if($champ_battle_flag && !$adv->{'test_player_flag'}){
				my $NewComment1 = qq($adv->{'chara_link'}が);
				my $NewComment2 = qq(新チャンピオンになりました。);
				&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
			}

	}

	# 負けた場合 （チャンプ戦）
	elsif($enemy_win && $main::mode eq "battle"){
		$exp = int( ($adv->{'level'} * $init->{'kiso_exp'}) * 0.75 );
	}

	# 勝った場合（モンスター戦）
	if($win && $main::mode eq "monster"){
		$exp = $monster_exp*0.9;
		$gold = $adv->{'level'} * 7 + int(rand($adv->{'level'} * 6));
	}

	# 負けた場合（モンスター戦）
	if($enemy_win && $main::mode eq "monster"){
		$exp = 0;
		if($adv->{'gold'} >= 1) { $gold = int($adv->{'gold'} * 0.35) * -1; }
	}

	# 引き分けの場合 （モンスター戦）
	elsif($main::mode eq "monster"){ }

# 経験値、獲得ゴールドの共通調整
#require Mebius::Adventure::Adjust;
($exp,$gold,$bank,$pure_gold) = &ExpGold("Auto-bank",$exp,$gold,$adv);

	# ▼自分のキャラデータを更新 （共通処理）
	{

		# 宣言
		my($renew,$levelup_comment,$comment_hp);

		# ファイルを開く
		my($adv2) = &File("Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1 , input_char => $main::in{'char'} , TypeChargeTimeCheckError => 1 } );

				# ▼勇気の増減
				if($main::mode eq "battle"){

						# チャンプ戦
						if($champ_battle_flag){

								# 勝利した場合
								if($win && rand(3) < 1){ $renew->{'+'}{'brave'} = 1; }
								# 敗北した場合
								elsif(rand(30) < 1){ $renew->{'+'}{'brave'} = 1; }

						}
						# 普通の対人戦 (特定条件下)
						elsif($enemy->{'all_level'} && $adv->{'all_level'}){

								# 強い相手と戦った場合
								if($enemy->{'all_level'} >= $adv->{'all_level'}*1.25){

									# 強い相手と戦った回数をカウント
									$renew->{'+'}{'human_battle_dog_count'} = 1;

										# 勝利すれば勇気を増やす
										if($win && rand(5) < 1){
											$renew->{'+'}{'brave'} = 1;
										}

								}
								# 弱い相手と戦った場合
								elsif($adv->{'all_level'} >= $enemy->{'all_level'}*1.25){

									# 弱い相手と戦った回数をカウント
									$renew->{'+'}{'human_battle_chicken_count'} = 1;

										# 戦っただけで勇気を減らす
										if(rand(2) < 1){
											$renew->{'-'}{'brave'} = 1;
										}
								}
						}

				}

			# 上限と下限を定義
			$renew->{'>='}{'brave'} = 0;
			$renew->{'<='}{'brave'} = 100;

				# 勝敗数の変更
				if($main::mode eq "battle"){
					$renew->{'+'}{'total'} = 1;
						if($win){ $renew->{'+'}{'win'} = 1; }
						elsif($draw_flag){ $renew->{'+'}{'draw'} = 1; }
						if($win && $champ_battle_flag){ $renew->{'+'}{'human_battle_win_champ_count'} = 1; }
				}

				# 勝敗数の変更 ( モンスター )
				elsif($main::mode eq "monster"){
					$renew->{'+'}{'monster_battle_count'} = 1;
						if($win){ $renew->{'+'}{'monster_battle_win_count'} = 1; }
						elsif($lose){ $renew->{'+'}{'monstet_battle_lose_count'} = 1; }
						elsif($draw_flag){ $renew->{'+'}{'monster_battle_draw_count'} = 1; }
				}

			# 被ダメージ
			$renew->{'hp'} = $adv->{'hp'};
			$adv2->{'hp'} = $adv->{'hp'};

			# 獲得した値
			$renew->{'+'}{'exp'} = $exp;
			$adv2->{'exp'} += $exp;
			$renew->{'+'}{'gold'} = $gold;
			$adv->{'gold'} += $gold;
			$renew->{'+'}{'bank'} = $bank;
			$adv->{'bank'} += $bank;

			# ダメージ回復
			#$plustype_levelup
			#my $plustype_levelup = qq(Battle-win) if($win);
			#$comment_hp_line = $comment_hp_line;
			#($levelup_comment,$adv2,$renew) = &DamageRepair(undef,$adv2,$renew);
		# ダメージ回復
		($comment_hp,$adv2,$renew) = &RepairHP({ WinFlag => $win , ChampFlag => $mychamp_flag },$adv2,$renew);
			if($comment_hp){ $comment_hp_line = qq($comment_hp); }

		# レベルアップ判定
		($levelup_comment_line,$adv2,$renew) = levelup_round($adv2,$renew);

				# いちどキャラと戦った場合は、またモンスターと戦えるように
				if($main::mode eq "battle"){
					$adv2->{'mons'} = $init->{'sentou_limit'};
					$renew->{'mons'} = $init->{'sentou_limit'};
					$renew->{'+'}{'human_battle_keep_count'} = 1;
				}

				# 最後に勝った相手のIDを記憶
				if($select_battle_mode && $win){
					$renew->{'lastwinid'} = $enemy->{'id'};
					$adv2->{'lastwinid'} = $enemy->{'id'};
				}

				# 最後に戦ったモンスターのレベルを記憶
				if($main::mode eq "monster"){ $renew->{'last_select_monster_rank'} = $monster_rank; }

				# このレベルで勝利した場合、次にチャレンジできるモンスターレベルを解放する
				if($main::mode eq "monster"){
						if($win && (!$adv2->{'top_monster_level'} || $monster_rank >= $adv2->{'top_monster_level'})){
							$renew->{'top_monster_level'} = $monster_rank + 1;
						}
					$renew->{'-'}{'mons'} = 1;
					$renew->{'human_battle_keep_count'} = 0;
				}


		# ファイル更新
		&File("Renew Mydata Charge-time Password-check",{  InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1 , input_char => $main::in{'char'} , TypeChargeTimeCheckError => 1  } ,$renew);
	}

	# ▼相手のキャラデータを更新
	if($main::mode eq "battle"){
		my(%renew,$enemy2);

			# ファイルを開く
			if($champ_battle_flag){
				($enemy2) = &File("File-check-error",{ FileType => "Account" , id => $enemy_id , FormalPlayerCheckAndError => 1});
			}
			else{
				($enemy2) = &File("File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $enemy_id , FormalPlayerCheckAndError => 1});
			}

		# 戦闘回数
		$renew{'+'}{'total'} = 1;

			# 勝利
			if($enemy_win){
				$renew{'+'}{'win'} = 1;
				$renew{'+'}{'exp'} = int($adv->{'level'} * $init->{'kiso_exp'} * $init->{'game_speed'});
			}
			# 敗北
			elsif($enemy_lose){
				$renew{'+'}{'exp'} = int($enemy->{'level'} * $init->{'kiso_exp'}  * $init->{'game_speed'});
				$renew{'champ'} = 0;
			}
			# ドロー
			elsif($draw_flag){
				$renew{'+'}{'draw'} = 1;
			}

		$renew{'hp'} = $enemy->{'hp'};

			# HPが最大HP以上にならないように
			if($renew{'hp'} > $enemy2->{'maxhp'}) { $renew{'hp'} = $enemy2->{'maxhp'}; }

			# HPがゼロになった場合は完全回復
			if($renew{'hp'} <= 0) { $renew{'hp'} = $enemy2->{'maxhp'}; }

			# ファイルを更新
			if($champ_battle_flag){
				&File("Renew File-check-error",{ FileType => "Account" , id => $enemy_id , FormalPlayerCheckAndError => 1 },\%renew);
			}
			else{
				&File("Renew File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $enemy_id , FormalPlayerCheckAndError => 1 },\%renew);
			}

	}

# ロック解除
Mebius::unlock("Adventure-action-$advmy->{'id'}");

# 自動ジャンプ、残り秒数表示
my($head_javascript,$view_jsredirect);
($head_javascript,$view_jsredirect) = &get_jsredirect({ TypeAllowPost => 1 },$adv->{'redun'});
$main::head_javascript = $head_javascript;

	# H1タイトル
	if($main::mode eq "battle" && $champ_battle_flag){ $h1 = qq(チャンプ - $enemy->{'name'} ( レベル$enemy->{'level'} $enemy->{'jobname'} ) に戦いを挑んだ！！); }
	if($main::mode eq "battle" && $select_battle_mode){ $h1 = qq($enemy->{'name'} ( レベル$enemy->{'level'} $enemy->{'jobname'} ) に戦いを挑んだ！！); }
	if($main::mode eq "monster"){ $h1 = qq($enemy->{'name'} が現れた！！); }

my $view_getgold = $pure_gold;
my $view_bank = int($view_getgold * $adv->{'autobank'}*0.01);

# カンマを付ける
my($getexp_comma,$getgold_comma,$gold_comma,$bank_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$exp,$view_getgold,$gold,$view_bank]);

	# 勝利/敗北コメント
	if($sametime_down_flag){ $comment .= qq(なんと両者同時に倒れた……。<br$main::xclose>); }
	if($win){ $comment .= qq(<b><font size="5">$advmy->{'name'}は、戦闘に勝利した！！</font></b>); }
	if($win && $champ_battle_flag){ $comment .= qq(<br>おめでとうございます、<strong class="red">あなたがチャンピオンです！</strong>); }
	if($enemy_win){ $comment .= qq(<b><font size="5">$advmy->{'name'}は、戦闘に負けた……。</font></b>); }
	if(!$win && !$lose){ $comment .= qq(<b>ターンオーバー、決着がつきませんでした。</b>); }
	if($win && $champ_battle_flag){ $comment .= qq(<br>$champwin_exp倍の経験値を獲得！); }
	if($exp >= 1){ $comment .= qq(<br><b class="expcolor">$getexp_comma</b> の経験値を手に入れた。); }
	if($view_getgold >= 0){
		$comment .= qq(<br><b class="goldcolor">$getgold_comma \G</b> を手に入れた。);
			if($bank >= 1){ $comment .= qq(そのうち $adv->{'autobank'}\％ ( <b class="goldcolor">$bank_comma\G</b> ) を銀行に自動振替した。); }
	}
	if($view_getgold < 0){ $comment .= qq(<br>所持金が減った （<b>$gold_comma</b>G）。); }

# HTML
$print .= qq(
<h1>$h1</h1>
$init_login->{'link_line'});

$print .= qq($view_jsredirect\n);

$print .= qq($battle_start_message
$turn_results
<h2>結果</h2>
<div class="turn">
<div class="atack_left">
<h3><strong class="hp hpcolor">HP $save_khp_comma / $kmaxhp_comma</strong></h3>
</div>

<div class="atack_right">
<h3><strong class="hp hpcolor">HP $save_whp_comma / $wmaxhp_comma</strong></h3>
</div>

<div class="clear result_comment">
$comment
$comment_hp_line
$levelup_comment_line
</div>
);


$print .= qq($init->{'continue_button'}</div>);


Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# 職業ごとのダメージ計算
#-----------------------------------------------------------
sub DamageBattle{

# 説明
# $use->{'TypeDefence'} ＝ 防衛側での「攻撃」をする際に使用するフラグ

# 局所化
my($init) = &Init();
my($use,$adv,$enemy) = @_;
my($damage,$skilldmg1,$skilldmg2,$com,$repair,$critical_odds,$bluefire_flag,$atack_comment,$damage_comma,$rand_spatack);
my($item_damage_point,$job_atack_block_flag,$repair_line,$damage_line,$not_view_damage_flag,$wepon_use_line,$job_atack_line);
my($critical_line,$special_atack_line,$guard_line);
my($bluefire_block_flag,$critical_block_flag,$special_atack_block_flag,$special_guard_block_flag);
my $turn = $use->{'turn'};

	# レベルによるダメージ計算 （ 対人戦 ）
	if($use->{'BattleMode'} eq "Human"){ $damage = $adv->{'level'} * (int(rand(3)) + 1); }

	# レベルによるダメージ計算 ( モンスター )
	elsif($use->{'BattleMode'} eq "Monster"){ $damage = $adv->{'level'} * (int(rand(5)) + 1); }

	# その他
	else{
		main::error("対戦モードが指定されていません。");
	}

	# 職業別のダメージ計算
	if($adv->{'jobname'} eq "戦士"){
		$skilldmg1 = int(rand($adv->{'power'}));
		$atack_comment = qq(剣で切りつけた！);
	}
	elsif($adv->{'jobname'} eq "魔法使い"){
		$skilldmg1 = int(rand($adv->{'brain'}));
		$atack_comment = qq(魔法を唱えた！);
	}
	elsif($adv->{'jobname'} eq "僧侶"){
		$skilldmg1 = int(rand($adv->{'believe'}));
		$atack_comment = qq(魔法を唱えた！);
	}
	elsif($adv->{'jobname'} eq "盗賊"){
		$skilldmg1 = int(rand($adv->{'tec'}*0.5)+rand($adv->{'speed'}*0.5));
		$atack_comment = qq(死角から切りつけた！);
	}
	elsif($adv->{'jobname'} eq "踊り子"){
		$skilldmg1 = int(rand($adv->{'charm'}));
		$skilldmg2 = int(rand($adv->{'speed'}));
		$atack_comment = qq(華麗に踏みつけた！);
	}
	elsif($adv->{'jobname'} eq "レンジャー"){
		$skilldmg1 = int(rand($adv->{'vital'}));
		$skilldmg2 = int(rand($adv->{'power'}));
		$atack_comment = qq(矢を射た！);
	}
	elsif($adv->{'jobname'} eq "錬金術師"){
		$skilldmg1 = int(rand($adv->{'brain'}));
		$skilldmg2 = int(rand($adv->{'tec'}));
		$atack_comment = qq(酸を投げつけた！);
	}
	elsif($adv->{'jobname'} eq "吟遊詩人"){
		$skilldmg1 = int(rand($adv->{'charm'}));
		$skilldmg2 = int(rand($adv->{'tec'}));
		$atack_comment = qq(呪いの歌を叫んだ！);
	}
	elsif($adv->{'jobname'} eq '超能力者'){
		$skilldmg1 = int(rand($adv->{'brain'}));
		$skilldmg2 = int(rand($adv->{'vital'}));
		$atack_comment = qq(超能\力を使った！);
	}
	elsif($adv->{'jobname'} eq "ヴァルキリー"){
		$skilldmg1 = int(rand($adv->{'believe'}));
		$skilldmg2 = int(rand($adv->{'brain'}));
		$atack_comment = qq(精霊魔法を唱えた！);
	}
	elsif($adv->{'jobname'} eq "司教"){
		$skilldmg1 = int(rand($adv->{'charm'}));
		$skilldmg2 = int(rand($adv->{'believe'}));
		$atack_comment = qq(裁きの祈りを捧げた！);
	}
	elsif($adv->{'jobname'} eq "君主"){
		$skilldmg1 = int(rand($adv->{'power'}));
		$skilldmg2 = int(rand($adv->{'believe'}));
		$atack_comment = qq(神聖な力で切りつけた！);
	}
	elsif($adv->{'jobname'} eq "侍"){
		$skilldmg1 = int(rand($adv->{'tec'}));
		$skilldmg2 = int(rand($adv->{'speed'}));
		$atack_comment = qq(刀を一閃した！);
	}
	elsif($adv->{'jobname'} eq "修行僧"){
		$skilldmg1 = int(rand($adv->{'power'}));
		$skilldmg2 = int(rand($adv->{'believe'}));
		$atack_comment = qq(殴った！);
	}
	elsif($adv->{'jobname'} eq "忍者"){
		$skilldmg1 = int(rand($adv->{'speed'}));
		$skilldmg2 = int(rand($adv->{'power'}));
		$atack_comment = qq(忍び寄った！);
	}

	# ●対人戦、ダメージ補正 (キャラクター)
	if($use->{'BattleMode'} eq "Human"){

			# 戦士タイプ
			if($adv->{'jobconcept'} =~ /Fighter-job/){
				$damage += ($skilldmg1 + $skilldmg2);
			}
			
			# 魔法タイプ
			elsif($adv->{'jobconcept'} =~ /Magician-job/){
				$damage += ($skilldmg1 + $skilldmg2) * 1.5;
			}

	}

	# ●モンスター戦、ダメージ補正 (キャラクター)
	elsif($use->{'BattleMode'} eq "Monster"){

			# モンスターが与えるダメージ
			if($adv->{'buffer_monster_flag'}){
				$damage = (int(rand($adv->{'buffer_monster_damage'})) + 1) + $adv->{'buffer_monster_damage'};
				$atack_comment = qq(襲いかかった！！);
			}

			# 職業戦士のダメージ計算
			elsif($adv->{'jobname'} eq "戦士"){
				$damage += ($skilldmg1 + $skilldmg2);
			}

			# 戦士タイプのダメージ計算
			elsif($adv->{'jobconcept'} =~ /Fighter-job/){
				$damage *= ($skilldmg1 * 0.80) + ($skilldmg2 * 0.60);
			}

			# 魔法タイプのダメージ計算
			elsif($adv->{'jobconcept'} =~ /Magician-job/){
				$damage *= ($skilldmg1 * 1.00) + ($skilldmg2 * 0.80);
			}

	}

	# 自分の苦手な職業が相手の場合は、ダメージ量を減らす
	if($adv->{'buffer_jobmatch'}){
		$damage *= 0.8;
	}

# 基本攻撃メッセージ
$com .= qq($adv->{'name'}は$atack_comment);

	# モンスター、深夜のパワーアップ
	if($use->{'TypeDefence'} && $adv->{'buffer_monster_flag'} && $main::thishour >= 0 && $main::thishour <= 4){
		$damage *= 1.5;
		$com .= qq(<br><span class="special">──闇がパワーを増幅させる！</span>);
	}

	# モンスター、早朝のパワーダウン
	if($use->{'TypeDefence'} && $adv->{'buffer_monster_flag'} && ($main::thishour >= 6 && $main::thishour <= 7)){
		$damage *= 0.6;	
		$com .= qq(<br><span class="special">──光が邪悪な力を弱めている！</span>);
	}

	# モンスター戦： 戦士の「相手が高レベル」ボーナス
	if($use->{'BattleMode'} eq "Monster" && $adv->{'level'} >= 100){
			if($adv->{'jobname'} eq '戦士' && $enemy->{'rank'} >= 9){
				$com .= qq(<br>手ごわい相手に心が踊る！);
				$damage *= 50;
			}
	}

	# ●武器の使用
	if($adv->{'item_number'}){

		# 局所化
		my($item_boost_damege);

			# ▼戦士タイプのダメージ計算
			if($adv->{'jobconcept'} =~ /Fighter-job/){

					# モンスター戦
					if($use->{'BattleMode'} eq "Monster"){
							if($enemy->{'rank'} >= 6){
								$item_damage_point += $adv->{'item_damage_all'} * ($enemy->{'rank'}**4);
							}
							else{
								$item_damage_point += $adv->{'item_damage_all'}*4.5;
							}
					}
					# 対人戦
					elsif($use->{'BattleMode'} eq "Human"){
						$item_damage_point = $adv->{'item_damage_all'}*2;
					}

			}

			# ▼魔法タイプのダメージ計算
			elsif($adv->{'jobconcept'} =~ /Magician-job/){

					# モンスター戦
					if($use->{'BattleMode'} eq "Monster"){
							if($enemy->{'rank'} >= 6){
								$item_damage_point += $adv->{'item_damage_all'} * ($enemy->{'rank'}**3);
							}
							else{
								$item_damage_point += $adv->{'item_damage_all'}*1.5;
							}
					}
					# 対人戦
					elsif($use->{'BattleMode'} eq "Human"){
						$item_damage_point = $adv->{'item_damage_all'}*1;
					}

			}

			# 自分の職業に合った武器は威力が増す
			if($adv->{'buffer_good_wepon'}){
				$item_damage_point *= 1.5;
			}
				
		# 総合ダメージに追加
		$damage += $item_damage_point;

			# 武器を上手く使えない職業
			if($adv->{'jobname'} eq "忍者" && $adv->{'item_name'} !~ /忍者/){
				$damage *= 0.4;
				$wepon_use_line .= qq(<br>$adv->{'item_name'}が邪魔になる。);
			}
			# 武器を普通に使う
			else{
				$wepon_use_line .= qq(<br>──さらに$adv->{'item_name'}で攻撃した！);
			}
	}

	# ●青い炎 (キャラ戦闘時のみ)
	if($use->{'BattleMode'} eq "Human" && $enemy->{'maxhp'} >= $adv->{'maxhp'}*2.5 && $turn == 1 && rand(2.0) < 1) {

			# 発動
			if($adv->{'maxhp'} >= 1){

				# 局所化
				my($plus_damage);

				# 自分のHPと相手のHPをもとにダメージを計算
				$plus_damage = ($adv->{'hp'} * 0.50);

						# チャンプ戦の威力
						if($use->{'ChampBattleFlag'}){
							$plus_damage + ($enemy->{'hp'} * 0.05);
						}

					# 判定
					if($plus_damage >= $damage){

						# 発動
						$com .= qq(<br><strong class="bluefire">圧倒的な実力差に、青い炎が湧き上がる……。</strong>);

							# 無効化
							if($enemy->{'jobname'} eq "錬金術師"){
								$com .= qq(<br>──しかし相手は爆薬を持っている！　あわてて火を消した。);
							}
							# 発動
							else{
								$damage += $plus_damage;
								$critical_block_flag = 1;
								$special_atack_block_flag = 1;
								$job_atack_block_flag = 1;
							}
					}
			}
	}

	# ●敵の特殊能力封殺  -------------------------
	if(($enemy->{'jobname'} eq "僧侶" && rand(1.7) < 1) || ($enemy->{'buffer_monster_skill'} =~ /特殊無効化/ && rand(2.5) < 1)){
			$guard_line .= qq(<br><span class="red">＞＞特殊攻撃は妨げられた。</span>);
			$job_atack_block_flag = 1;
			$critical_block_flag = 1;
			$special_atack_block_flag = 1;
	}

	# ●必殺技
	if(!$special_atack_block_flag){

			# 発動する確率
			if($adv->{'buffer_monster_flag'}){ $rand_spatack = 80; }
			else{ $rand_spatack = 25; }

			# 相手の武器によっては、必殺技を出やすく
			if($enemy->{'item_concept'} =~ /Getexp-boost/){ $rand_spatack /= 2.00; }

			# 確率計算
			if(rand($rand_spatack) < 1 && $adv->{'waza'} && $adv->{'spatack'} && $adv->{'spodds'} && !$bluefire_flag) {
				$special_atack_line = qq(「<b>$adv->{'waza'}</b>」\n);
				$special_atack_line .= qq(<br><font size="4">$adv->{'name'}は<strong class="spatack">$adv->{'spatack'}</strong>を放った！</font>);
				$damage = $damage * $adv->{'spodds'};
			}
	}

	# ●クリティカル攻撃
	if(!$critical_block_flag){

			# 発動する確率
			if($adv->{'jobname'} eq "侍"){
				my $rand = 12 - ($adv->{'level'}*0.005);
				if($rand < 2){ $rand = 2; }
				$critical_odds = $rand;
			}
			elsif($adv->{'buffer_monster_flag'}){ $critical_odds = 20; }	# モンスターのクリティカル率
			else{ $critical_odds = 15; }								# キャラクターのクリティカル率
			if($enemy->{'item_concept'} =~ /Getexp-boost/){ $critical_odds /= 2.00; }	# 相手の武器によっては、クリティカルを出やすく

			# クリティカル攻撃
			if(rand($critical_odds) < 1 && !$bluefire_flag) {
				$critical_line .= qq(<br><strong class="clitical">強い一撃！</strong>);
				$damage *= 3;
			}
	}

	# ●自分の職業特有攻撃  -------------------------
	if(!$job_atack_block_flag){

			# 戦士のアイテム効果増幅
			if($adv->{'jobname'} eq "戦士" && rand(2.5) < 1 && $adv->{'level'} >= 100){
					if($use->{'BattleMode'} eq "Monster"){ $damage += $adv->{'item_damage_all'}*5; }
					elsif($use->{'BattleMode'} eq "Human"){ $damage += $adv->{'item_damage_all'}*3.0; }
				$wepon_use_line .= qq(<br><span class="special">──武器の力を最大限に発揮した。</span>);
			}

			# 忍者と修行僧のダメージブースト
			if($adv->{'jobname'} eq "忍者" && $use->{'BattleMode'} eq "Monster"){ 
				my $damage_boost = 0.5 + ($adv->{'level'} * 0.001);
				if($damage_boost > 20){ $damage_boost = 20; }
				$damage *= $damage_boost;
			}
			if($adv->{'jobname'} eq "修行僧" && $use->{'BattleMode'} eq "Monster"){
				my $damage_boost = 0.5 + ($adv->{'level'} * 0.001);
				if($damage_boost > 10){ $damage_boost = 10; }
				$damage *= $damage_boost;
			}
			if($adv->{'jobname'} eq "忍者" && $use->{'BattleMode'} eq "Human"){ 
				my $damage_boost = 0.75 + ($adv->{'level'} * 0.00025);
				if($damage_boost > 3.0){ $damage_boost = 3; }
				$damage *= $damage_boost;
			}
			if($adv->{'jobname'} eq "修行僧" && $use->{'BattleMode'} eq "Human"){
				my $damage_boost = 0.75 + ($adv->{'level'} * 0.00025);
				if($damage_boost > 1.5){ $damage_boost = 1.5; }
				$damage *= $damage_boost;
			}

			# 「高レベル下級職」のボーナス ( それでも元々ダメージは半分ということに留意 )
			if($adv->{'jobconcept'} =~ /Amateur-job/){
					if($adv->{'level'} >= 10000){ $damage *= 3.5; }
					elsif($adv->{'level'} >= 7500){ $damage *= 3.0; }
					elsif($adv->{'level'} >= 5000){ $damage *= 2.5; }
					elsif($adv->{'level'} >= 2500){ $damage *= 2.0; }
					elsif($adv->{'level'} >= 1000){ $damage *= 1.5; }
			}

			# 魔法使いの呪いの力
			if($adv->{'jobname'} eq "魔法使い" && $use->{'BattleMode'} eq "Human" && $use->{'TypeDefence'} && $adv->{'level'} >= 100){
				$damage *= 1.5;
				$job_atack_line .= qq(<br><span class="red">＞＞呪いの力で返り討ちに！</span>);
			}

			# ターンを追うごとに攻撃力が増加
			if(($adv->{'jobname'} eq '君主' || $adv->{'jobname'} eq 'レンジャー') && $adv->{'level'} >= 100){

					# 局所化
					my($turn_damage);

						# ダメージ量を定義
						if($use->{'BattleMode'} eq "Monster"){ $turn_damage = (2**($turn+3)); }
						elsif($use->{'BattleMode'} eq "Human"){ $turn_damage = (2**($turn)); }

						# ダメージがプラスの場合は総合ダメージに追加
						if($turn_damage >= 1){
							$damage += $turn_damage;
							#$job_atack_line .= qq(<br><span class="special">──$adv->{'jobname'}は時間が経つほど強くなる！</span>);
								if(Mebius::alocal_judge()){ $job_atack_line .= qq( (+$turn_damage)); }
						}

			}

			# 超能力者の起死回生
			if($adv->{'jobname'} eq '超能力者' && $adv->{'hp'} < $adv->{'maxhp'} * 0.075){
				$job_atack_line .= qq(<br><span class="special">──起死回生の攻撃！</span>);
					if($adv->{'hp'} < $adv->{'maxhp'} * 0.005){ $damage *= 300; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.01){ $damage *= 100; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.02){ $damage *= 50; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.03){ $damage *= 25; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.04){ $damage *= 10; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.05){ $damage *= 5; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.075){ $damage *= 2; }
			}

			# 司教の対人攻撃
			if($adv->{'jobname'} eq "司教" && $use->{'BattleMode'} eq "Human"){
					if($adv->{'level'} >= 15000){ $damage *= 2.80; }
					elsif($adv->{'level'} >= 10000){ $damage *= 2.60; }
					elsif($adv->{'level'} >= 7500){ $damage *= 2.40; }
					elsif($adv->{'level'} >= 5000){ $damage *= 2.20; }
					elsif($adv->{'level'} >= 2500){ $damage *= 2.00; }
					elsif($adv->{'level'} >= 1000){ $damage *= 1.80; }
					else{ $damage *= 1.60; }
				$job_atack_line .= qq(<br><span class="special">──巨大な権力の前に、$enemy->{'name'}は恐れをなしている。</span>);
			}

			# 吟遊詩人の対モンスター攻撃
			if($adv->{'jobname'} eq "吟遊詩人" && $use->{'BattleMode'} eq "Monster"){
					if($adv->{'level'} >= 10000){ $damage *= 16.0; }
					elsif($adv->{'level'} >= 7500){ $damage *= 13.0; }
					elsif($adv->{'level'} >= 5000){ $damage *= 10.0; }
					elsif($adv->{'level'} >= 2500){ $damage *= 7.0; }
					elsif($adv->{'level'} >= 1000){ $damage *= 4.0; }
					else{ $damage *= 2.0; }
				$job_atack_line .= qq(<br><span class="special">──未知のメロディーに、$enemy->{'name'}は力をゆるめている。</span>);
			}


			# ●魔法使いのエナジードレイン
			if($adv->{'jobname'} eq "魔法使い" && rand(8) < 1 && $adv->{'level'} >= 100){
				$repair += $damage*0.5;
				$job_atack_line .= qq(<br><span class="special">──エナジードレイン！ 相手のHPを吸い上げた。</span>);
			}

			# 忍者の暗殺
			if(($adv->{'jobname'} eq "忍者" || $adv->{'buffer_monster_skill'} =~ /暗殺発動/) && $adv->{'level'}*1.5 >= $enemy->{'level'} && $adv->{'level'} >= 100){
				my $rand = 135 - ($adv->{'level'}/50);
						if($rand < 35){ $rand = 35; }	# 最高発動確率 ( 1 / x )
						if($use->{'BattleMode'} eq "Monster"){ $rand += 15; }
						if($adv->{'buffer_monster_flag'}){ $rand = 100; }	# モンスターが仕掛ける確率
						# 暗殺発動
						if(rand($rand) < 1){
							$job_atack_line .= qq(<span class="special">);
							$job_atack_line .= qq(──$adv->{'name'}は<strong class="red">暗殺</strong>を仕掛けた！);
								if($enemy->{'item_concept'} =~ /Anti-assassin/ || $enemy->{'jobname'} eq "君主" || $enemy->{'buffer_monster_skill'} =~ /暗殺無効化/){ 
									$job_atack_line .= qq(　しかし弾き返された。);
								}
								else{
									$damage = 999999999999999;
									$job_atack_line .= qq(<br$main::xclose>$enemy->{'name'}は息の根を止めた。</span>);
									$not_view_damage_flag = 1;
									$special_guard_block_flag = 1;
								}
							$job_atack_line .= qq(</span>);
						}
			}


	}

	# ●回復系の特殊技能
	{

			# 修行僧の超回復
			if($adv->{'jobname'} eq "修行僧" || $adv->{'buffer_monster_skill'} =~ /超回復/){
				my $rand = 135 - ($adv->{'level'}/100);
					if($rand < 35){ $rand = 35; }			# 最高発動確率 ( 1 / x )
					if($use->{'BattleMode'} eq "Monster"){ $rand += 35; }
					if($use->{'TypeDefence'}){ $rand *= 10; }	# 防御側の場合、発動確率を減らす
					if($adv->{'buffer_monster_flag'}){ $rand = 100; }	# モンスターが仕掛ける確率
					# 超回復発動
					if(rand($rand) < 1){
						my($text);
							if($adv->{'level'} >= 20000){ $repair = int($adv->{'maxhp'}); $text = "すべて"; }
							elsif($adv->{'level'} >= 10000){ $repair = int($adv->{'maxhp'}/2); $text = "1/2"; }
							elsif($adv->{'level'} >= 2500){ $repair = int($adv->{'maxhp'}/3); $text = "1/3"; }
							else{ $repair = int($adv->{'maxhp'}/4); $text = "1/4"; }
						$repair_line .= qq(<br><span class="special">──$adv->{'name'}は瞑想した！ HPが<strong class="hpcolor">$text超回復</strong>した。</span>);
					}
			}

			# 君主、司教のダメージ回復
			if($adv->{'jobname'} eq "君主" || $adv->{'jobname'} eq "司教"){
					if($use->{'BattleMode'} eq "Human"){ $repair = int rand($adv->{'level'}/2); }
					elsif($use->{'BattleMode'} eq "Monster"){ $repair = int rand($adv->{'level'}); }
					if($repair >= 10000){ $repair = 10000; }
					if($repair >= 1){
						$repair_line .= qq(<br><span class="special">──神聖な力で HP が <strong class="hpcolor">$repair</strong> 回復した。</span>);
					}
			}

	}

	# [敵]の特殊防御 -------------------
	if(!$special_guard_block_flag){

			# ヴァルキリーの攻撃吸収
			if($enemy->{'jobname'} eq "ヴァルキリー"){
					if(rand(10) < 1){
						$damage *= -1;
						$guard_line .= qq(<br><span class="red">＞＞ヴァルキリーの攻撃吸収！</span>);
					}
			}

			# 敵の守備でダメージ量が減る
			elsif($enemy->{'jobname'} eq "レンジャー"){
				my($percent);
					if($enemy->{'level'} >= 10000){ $percent = 90; }
					elsif($enemy->{'level'} >= 5000){ $percent = 80 }
					elsif($enemy->{'level'} >= 1000){ $percent = 70; }
					elsif($enemy->{'level'} >= 500){ $percent = 60; }
					elsif($enemy->{'level'} >= 100){ $percent = 40; }
					else{ $percent = 20; }
					if(rand(100) < $percent){
						$damage *= 0.5;
						$guard_line .= qq(<br><span class="red">＞＞相手は身を固めている。</span>);
					}
			}
	}

	# ●ダメージ表示
	if(!$not_view_damage_flag){

		$damage = int($damage);
		($damage_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$damage]);

			# プラス攻撃 ( 相手にダメージ )
			if($damage >= 0){
				if(Mebius::alocal_judge() && $item_damage_point){
					my($item_damage_point_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$item_damage_point]);
					$damage_line .= qq(<br>$enemy->{'name'}に <b class="damage">$damage_comma ($item_damage_point_comma)</b> のダメージ。);
				}
				else{
					$damage_line .= qq(<br>$enemy->{'name'}に <b class="damage">$damage_comma</b> のダメージ。);
				}
			}
			# マイナス攻撃（相手HPの回復）
			else{
				my $repair_damage_comma = $damage_comma;
				$repair_damage_comma =~ s/^\-//g;
				$damage_line .= qq(<br>$enemy->{'name'}を <span class="dmg"><b style="color:#00f;">$repair_damage_comma</b></span> 回復させてしまった。);
			}

	}

	# 回復量
	$repair = int $repair;

# 整形
$com = qq(
$com
$wepon_use_line
$guard_line
$job_atack_line
$critical_line
$special_atack_line
$damage_line
$repair_line
);

# リターン
return($damage,$repair,$com);

}




1;
