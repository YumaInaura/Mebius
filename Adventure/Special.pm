
package Mebius::Adventure;
use Mebius::Adventure::Adjust;
use strict;

#-----------------------------------------------------------
# 特殊行動
#-----------------------------------------------------------
sub SpecialAction{

# 局所化
my($message,$makelog,%renew,%renew_target);
my($init) = &Init();
my($init_login) = init_login();
my($advmy) = my_data();
my($target);

# アクセス制限
main::axscheck("Post-only ACCOUNT");

	# 各種エラー
	if($main::in{'target_id'} eq ""){ main::error("相手を選択してください。"); }
	if($main::in{'target_id'} =~ /\W/){ main::error("キャラIDが変です。"); }

# ロック開始
Mebius::lock("Adventure-action-$advmy->{'id'}");

# 自分のファイルを開く
my($adv) = &File("Password-check Flock",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} , TypeCharCheck => 1 , TypeChargeTimeCheckError => 1 });

# CCC 不具合チェック
#if(Mebius::alocal_judge()){ sleep(3); }

	# 相手キャラクターを選択する場合
	if($main::in{'target_id'} ne "id_none"){
		($target) = &File("File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $main::in{'target_id'} , FormalPlayerCheckAndError => 1 });
	}

	# 行動可能かどうかを判定、行動できない場合はエラーを表示する
	&SpecialJudge({ TypeErrorView => 1 },$adv,$target);

	# 僧侶
	if($advmy->{'jobname'} eq "僧侶"){
		if(rand(1) < 1){
			my($up);
				if($adv->{'level'} >= 5000){ $up = 32; }
				elsif($adv->{'level'} >= 2000){ $up = 16; }
				elsif($adv->{'level'} >= 1000){ $up = 14; }
				elsif($adv->{'level'} >= 500){ $up = 12; }
				elsif($adv->{'level'} >= 250){ $up = 10; }
				elsif($adv->{'level'} >= 100){ $up = 8; }
				elsif($adv->{'level'} >= 50){ $up = 6; }
				elsif($adv->{'level'} >= 25){ $up = 4; }
				elsif($adv->{'level'} >= 10){ $up = 2; }
				else{ $up = 1; }
				$up *= $init->{'game_speed'};
			$message = qq(祈りました！ $target->{'chara_link'} のHPが全回復し、最大HPが $up アップしました！);
			$makelog = qq($adv->{'chara_link'} が->$target->{'chara_link'} を回復させ、 <span class="red">最大HP</span> を上げました。);
			$renew_target{'+'}{'maxhp'} = $up;
			$renew_target{'='}{'hp'} = "maxhp";
		}
		else{
			$message = qq(祈りました！);
		}
	}

	# 盗賊
	elsif($advmy->{'jobname'} eq "盗賊"){

		my($steel_gold_comma);

				my $steel_gold = int rand($adv->{'level'}*80);					# 基本額
				#require Mebius::Adventure::Adjust;
				(undef,$steel_gold) = &ExpGold("STEEL","",$steel_gold,$adv);	# 増幅効果
			if($steel_gold > $target->{'gold'}){ $steel_gold = $target->{'gold'}; }	# 相手の所持金より多くは盗めない
			if($target->{'gold'} < 0){ $steel_gold = 0; }							# 相手の所持金がマイナスの場合は0Gしか盗めない（無限増殖対策）
			if($target->{'jobname'} eq '超能力者' && rand(3) < 1 && $adv->{'gold'} >= -10000){
				$steel_gold *= -5;
				($steel_gold_comma) = Mebius::japanese_comma($steel_gold);
				$message = qq(先を読まれた！ $target->{'chara_link'}に$steel_gold_comma\Gを奪われました。);
			}
			else{
				($steel_gold_comma) = Mebius::japanese_comma($steel_gold);
				$message = qq($target->{'chara_link'}から$steel_gold_comma\Gを盗みました！);
				$makelog = qq($adv->{'chara_link'} が->$target->{'chara_link'} から <span class="goldcolor">$steel_gold_comma\G</span> を盗みました。);
			}
		$renew{'+'}{'gold'} = $steel_gold;
		$renew_target{'-'}{'gold'} = $steel_gold;
	}

	# 踊り子
	elsif($advmy->{'jobname'} eq "踊り子"){
		my $rand = 4;
		if($target->{'charm'} >= 5000){ $rand *= 2.0; }
		elsif($target->{'charm'} >= 2500){ $rand *= 1.5; }
		elsif($target->{'charm'} >= 1000){ $rand *= 1.25; }

		if(rand($rand) < 1){
			$renew_target{'+'}{'charm'} = (1*$init->{'game_speed'});
			$message = qq(華麗に踊りました！ $target->{'chara_link'} の 魅力が 1 アップしました！);
			$makelog = qq($adv->{'chara_link'} が->$target->{'chara_link'} の <span class="red">魅力</span> に磨きをかけました。);
		}
		else{
			$message = qq(華麗に踊りました！);
		}
	}

	# 錬金術師
	elsif($advmy->{'jobname'} eq "錬金術師"){
			#if($target->{'item_damage_plus'} > $target->{'item_damage'}*1.5
			#			&& $target->{'item_damage_plus'} > $target->{'item_damage'} + 100){ main::error("もうこの武器は強く出来ません。"); }
			if($target->{'item_damage_plus'} >= $target->{'item_damage'}*0.5 && $target->{'item_damage_plus'} >= 100){ main::error("もうこの武器は強く出来ません。"); }
		my $rand = 10 - ($adv->{'level'}*0.01);
			if($rand < 1.0){ $rand = 1.0; }
			if(rand($rand) < 1){
				my $up = int(1*$init->{'game_speed'});
					if($adv->{'level'} >= 10000){ $up += 5; }
					elsif($adv->{'level'} >= 5000){ $up += 4; }
					elsif($adv->{'level'} >= 1000){ $up += 3; }
					elsif($adv->{'level'} >= 500){ $up += 2; }
					elsif($adv->{'level'} >= 100){ $up += 1; }
				$message = qq(研究により、武器の威力を $up ポイント 上昇させました！);
				$makelog = qq($adv->{'chara_link'} が->$target->{'chara_link'} の <span class="red">武器の威力</span> を上げました。);
				$renew_target{'+'}{'item_damage_plus'} = $up;
			}
			else{ $message = qq(今回の研究は失敗です。); } 
	}

	# 司教
	elsif($advmy->{'jobname'} eq "司教"){

		my $rand = 10 - ($adv->{'level'}/500);
			if($rand < 3){ $rand = 3; }
			if(rand($rand) < 1 ){
		my $up = 1*$init->{'game_speed'};
		$message = qq(民衆からカルマを買収し、 $target->{'chara_link'} に与えました！);
		$makelog = qq($adv->{'chara_link'} が->$target->{'chara_link'} の <span class="red">カルマ</span> を高めました。);
		$renew_target{'+'}{'karman'} = $up;
	}
		else{ $message = qq(カルマを高めるのに失敗しました。); }
	}

	# 君主
	elsif($advmy->{'jobname'} eq "君主"){

				my $steel_gold = int rand($adv->{'level'}*180);					# 基本額
				#require Mebius::Adventure::Adjust;
				(undef,$steel_gold) = &ExpGold("STEEL","",$steel_gold,$adv);	# 増幅効果
			if($steel_gold > $target->{'gold'}){ $steel_gold = $target->{'gold'}; }	# 相手の所持金より多くは盗めない
			if($target->{'gold'} < 0){ $steel_gold = 0; }							# 相手の所持金がマイナスの場合は0Gしか盗めない（無限増殖対策）

		my($steel_gold_comma) = Mebius::japanese_comma($steel_gold);
		$message = qq($target->{'chara_link'}から$steel_gold_comma\Gを没収しました！);
		$makelog = qq($adv->{'chara_link'} が->$target->{'chara_link'} から <span class="goldcolor">$steel_gold_comma\G</span> を没収しました。);
		$renew{'+'}{'gold'} = $steel_gold;
		$renew_target{'-'}{'gold'} = $steel_gold;
	}

	# 侍
	elsif($advmy->{'jobname'} eq "侍"){

		if($target->{'jobname'} eq '超能力者' && rand(5) >= 1){ $message = "先を読まれた! 相手を斬れませんでした。"; }
		elsif(rand(1) < 1){
				my $damage_percent = 10 + int($adv->{'level'}*0.05*$init->{'game_speed'});
			if($damage_percent > 50){ $damage_percent = 50; }
				my $left_hp = int($target->{'hp'}*$damage_percent*0.01);
				$renew_target{'-'}{'hp'} = $left_hp;
				$message = qq($target->{'chara_link'}を斬った！<br> HPを $damage_percent ％ 削りました。<span class="hpcolor">（ HP $target->{'hp'} → HP $left_hp ）</span>);
				$makelog = qq($adv->{'chara_link'} が->$target->{'chara_link'} を <span class="red">斬り</span> ました。);
			}
			else{
				$message = qq(相手を切れませんでした。); 
			}
	}

# 連続行動を禁止
Mebius::Redun(undef,"ADV_ACTION",$adv->{'redun'});

	# 自分のキャラファイルを更新 ( A - 1 )
	# => ここで厳密なチャージ時間チェックもおこなっているため、必ず各種ファイル更新の最初に処理する => もしエラーがあれば他の処理も実行されない
	{
		$renew{'last_select_special_id'} = $target->{'id'};
		$renew{'-'}{'sp'} = 1;
		&File("Renew Charge-time Mydata Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} , TypeCharCheck => 1 , TypeChargeTimeCheckError => 1  , FormalPlayerCheckAndError => 1 },\%renew);
	}

	# 相手のファイルを読み込み、更新
	if($main::in{'target_id'}){
		&File("Renew File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $main::in{'target_id'} , FormalPlayerCheckAndError => 1 },\%renew_target);
	}

	# 全キャラクターの行動記録を更新
	if($makelog && !$adv->{'test_player_flag'}){
		my($NewComment1,$NewComment2) = split(/->/,$makelog);
		&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
	}


# ロック解除
Mebius::unlock("Adventure-action-$advmy->{'id'}");


$message .= qq(<br>SPを消費しました。);


# HTML
my $print = qq(
<h1>特殊行動</h1>
$init_login->{'link_line'}
<div class="results">$message</div>
$init->{'continue_button'}
);


Mebius::Template::gzip_and_print_all({ BodyPrint => 1 ,RefreshURL => $init->{'login_url'} , RefreshSecond => 2 },$print);

exit;

}


#-----------------------------------------------------------
# 特殊行動可能かどうかを判定
#-----------------------------------------------------------
sub SpecialJudge{

# 宣言
my($use,$adv,$target) = @_;
my($init) = &Init();
my(%self);

	# 相手か自分が正式なプレイヤーではない場合
	if(!$target->{'formal_player_flag'}){ $self{'error_flag'} = qq(アカウントを登録していないキャラクターには、特殊行動は出来ません。); }
	if(!$adv->{'formal_player_flag'}){ $self{'error_flag'} = qq(アカウント登録をすると、特殊行動が出来ます。); }

	# チャージ時間判定
	if($adv->{'still_charge_flag'}) {
		$self{'error_flag'} = qq(まだチャージ時間が終わっていません。);
	}

	# SP切れの場合
	if($adv->{'sp'} <= 0){
		Mebius::AccessLog("Not-unlink-file","Adventure-redun-special","連続特殊行動制限。 キャラID: $adv->{'id'}");
		$self{'error_flag'} = qq(SP (空色ポップコーン) が足りません。宿屋に泊まってください。);
	}

	# 相手のログイン時間を判定
	if(time > $target->{'lasttime'}+($init->{'charaon_day'}*24*60*60) && !Mebius::alocal_judge()){
		$self{'error_flag'} = qq($init->{'charaon_day'}日以上ログインしていない相手は選べません。);
	}

	# ●職業ごとの判定
	{

		# 盗賊
		if($adv->{'jobname'} eq "盗賊"){
			$self{'name'} = "盗みを働く";
			if($adv->{'maxhp'} > $target->{'maxhp'}*$init->{'special_battle_gyap'}){ $self{'error_flag'} = qq(実力差のありすぎる相手は選べません。); }
		}

		# 僧侶
		elsif($adv->{'jobname'} eq "僧侶"){
			$self{'name'} = "祈る";
		}

		# 踊り子
		elsif($adv->{'jobname'} eq "踊り子"){
			$self{'name'} = "踊る";
		}

		# 錬金術師
		elsif($adv->{'jobname'} eq "錬金術師"){
			$self{'name'} = "武器を研究する";
				#if($target->{'item_damage_plus'} > $target->{'item_damage'}*1.5
				#			&& $target->{'item_damage_plus'} > $target->{'item_damage'} + 100){ $self{'error_flag'} = qq(もうこの武器は強く出来ません。); }
				if($target->{'item_damage_plus'} >= $target->{'item_damage'}*0.5 && $target->{'item_damage_plus'} >= 100){ $self{'error_flag'} = qq(もうこの武器は強く出来ません。); }
		}

		# 司教
		elsif($adv->{'jobname'} eq "司教"){
			$self{'name'} = "カルマを高める";
			if($target->{'karman'} >= 50){ $self{'error_flag'} = qq(カルマは満タンです。); }
		}

		# 君主
		elsif($adv->{'jobname'} eq "君主"){
			$self{'name'} = "没収する";
				if($adv->{'maxhp'} > $target->{'maxhp'}*$init->{'special_battle_gyap'}){ $self{'error_flag'} = qq(実力差のありすぎる相手は選べません。); }
				if($target->{'jobname'} ne "盗賊"){ $self{'error_flag'} = qq(盗賊以外は選べません。); }

		}

		# 侍
		elsif($adv->{'jobname'} eq "侍"){
			$self{'name'} = "斬る";
				if($adv->{'maxhp'} > $target->{'maxhp'}*$init->{'special_battle_gyap'}){ $self{'error_flag'} = qq(実力差のありすぎる相手は選べません。); }
		}

		# 特殊行動がない職業の場合
		else{
			$self{'name'} = "特殊行動";
			$self{'error_flag'} = "あなたの職業では特殊行動は出来ません。";
		}

	}

	# エラーがなければ可能フラグを立てる
	if($self{'error_flag'}){
		$self{'disabled'} = " disabled";
		$self{'justy_flag'} = 1;
	}

# 行動ボタン
$self{'form'} .= qq(　<form action="$init->{'script'}" method="post" class="inline">\n);
$self{'form'} .= qq(<div class="inline">\n);
$self{'form'} .= qq(<input type="hidden" name="mode" value="special">\n);
$self{'form'} .= qq(<input type="hidden" name="id" value="$adv->{'id'}">\n);
$self{'form'} .= qq(<input type="hidden" name="char" value="$adv->{'char'}">\n);
$self{'form'} .= qq(<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">\n);
$self{'form'} .= qq(<input type="hidden" name="target_file_type" value="account">\n);
$self{'form'} .= qq(<input type="submit" value="$self{'name'}" class="special"$self{'disabled'}>\n);
$self{'form'} .= qq(<input type="hidden" name="target_id" value="$target->{'id'}">\n);
$self{'form'} .= qq($self{'error_flag'});
$self{'form'} .= qq(</div>\n);
$self{'form'} .= qq(</form>\n);

	# ●エラーを即時表示する場合
	if($use->{'TypeErrorView'} && $self{'error_flag'}){
		main::error($self{'error_flag'});
	}

return(\%self);

}

1;
