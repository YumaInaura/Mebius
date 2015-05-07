
package Mebius::Adventure;
use strict;

#-----------------------------------------------------------
# 経験値と獲得ゴールドを調整
#-----------------------------------------------------------
sub ExpGold{

# 宣言
my($type,$exp,$gold,$adv) = @_;
my($init) = &Init();
my($bank);

	# 金持ち効果
	if($adv->{'item_concept'} =~ /Getgold-boost-([0-9\.]+)/){ $gold *= $1; }

	# EXP増幅効果
	if($adv->{'item_concept'} =~ /Getexp-boost-([0-9\.]+)/){ $exp *= $1; }

	# カルマによる経験値など倍増
	if($adv->{'karman'} >= 1){
			if($exp >= 1){ $exp = $exp + int($exp * $adv->{'karman'} * 0.025) + rand($adv->{'karman'}*5); }
			if($gold >= 1){ $gold = $gold + int($gold * $adv->{'karman'} * 0.025) + rand($adv->{'karman'}*5); }
	}

	# ゲームスピードで倍加
	if($exp >= 1){ $exp *= $init->{'game_speed'}; }
	if($gold >= 1){ $gold *= $init->{'game_speed'}; }

# 自動振替の差し引きのない金額
my $pure_gold = int($gold);

	# 銀行への自動振替
	if($adv->{'autobank'} >= 1 && $gold >= 1 && $type =~ /Auto-bank/){
		$gold = int($pure_gold*(1-($adv->{'autobank'}*0.01)));
		$bank = int($pure_gold*($adv->{'autobank'}*0.01*0.80));
	}

# 整数にする
$exp = int $exp;
$gold = int $gold;
$pure_gold = int $pure_gold;
$bank = int $bank;

# リターン
return($exp,$gold,$bank,$pure_gold);

}

#-----------------------------------------------------------
# 戦闘後の処理 ( HP 回復など )
#-----------------------------------------------------------
sub RepairHP{

# 宣言
my($use,$adv,$renew) = @_;
my($comment2,$repaired_flag);

	# ＨＰがゼロ以下になった場合
	if($adv->{'hp'} <= 0) {

			# 勝った場合
			if($use->{'WinFlag'}){ $renew->{'hp'} = 1; }

			# 自分がチャンプの場合
			elsif($use->{'ChampFlag'}){ $renew->{'hp'} = 1; } 

			# 普通の回復
			elsif($adv->{'maxhp'} >= 5000){ $renew->{'hp'} = int($adv->{'maxhp'}*0.1); }
			elsif($adv->{'maxhp'} >= 2500){ $renew->{'hp'} = int($adv->{'maxhp'}*0.25); }
			elsif($adv->{'maxhp'} >= 1000){ $renew->{'hp'} = int($adv->{'maxhp'}*0.5); }
			else{ $renew->{'hp'} = $adv->{'maxhp'};	 }
	
		$repaired_flag = 1;

	}

	# HPが最大HPを超えない、下回らないように
	if($renew->{'hp'} > $adv->{'maxhp'}) { $renew->{'='}->{'hp'} = "maxhp"; }
	if($renew->{'hp'} <= 0) { $renew->{'hp'} = 1; }

	# コメント
	if($repaired_flag){
		$comment2 .= qq(<br>HPが <strong class="hpcolor">$renew->{'hp'}</strong> まで回復した。);
	}

	# カルマによるＨＰ調整
	#if($adv->{'hp'} < $adv->{'maxhp'} && $adv->{'karman'} >= 1){
	#	$lp_hpbonus = int(rand($adv->{'karman'}*3));
	#	$renew->{'+'}{'hp'} = $lp_hpbonus;
	#		if($lp_hpbonus >= 1){ $comment2 .= qq(<br>カルマボーナス！ HPが<strong class="hpcolor">$lp_hpbonus</strong>回復した。);  }
	#}

return($comment2,$adv,$renew);

}

#-----------------------------------------------------------
# ブーストに応じてレベルアップ
#-----------------------------------------------------------
sub levelup_round{

my($adv2,$renew) = @_;
my($levelup_comment_line,$levelup_comment);
my($max_level_up);

	if(time < $adv2->{'effect_levelup_boost_time'} && $adv2->{'effect_levelup_boost'} >= 2){ $max_level_up = $adv2->{'effect_levelup_boost'}; }
	else{ $max_level_up = 1; }

	for(1..$max_level_up){
		($levelup_comment,$adv2,$renew) = &levelup(undef,$adv2,$renew);
			if($levelup_comment){ $levelup_comment_line .= qq(<div class="levelup">$levelup_comment</div>); }
	}

return($levelup_comment_line,$adv2,$renew);

}


#-----------------------------------------------------------
# レベルアップ判定
#-----------------------------------------------------------
sub levelup{

# 局所化
my($type,$adv,$renew) = @_;
my($init) = &Init();
my($comment,$up_hp,$up_odds_type,$down_odds_type,$comment2,$lp_hpbonus,%most_up,%most_down);

	# レベルアップしたかどうかを判定
	if($adv->{'exp'} > $adv->{'next_exp'}) {
	}
	# アップしてない場合はすぐにリターン
	else {
		return(undef,$adv,$renew);
	}

# レベルアップ
$renew->{'+'}{'level'} += 1;
$adv->{'level'} += 1;
$renew->{'+'}{'all_level'} += 1;
$adv->{'all_level'} += 1;
$comment .= qq(<strong class="levelup">レベルが) . ($adv->{'level'}) . qq(に上がった！</strong>);

# レベルアップ分の経験値を差し引く
$renew->{'-'}{'exp'} += $adv->{'next_exp'};
$adv->{'exp'} -= $adv->{'next_exp'};

# 最大ＨＰをアップ
$up_hp = int(rand($adv->{'vital'})) + 1;
	if($adv->{'jobname'} eq "戦士"){
		$up_hp += int(rand($adv->{'vital'}*0.25)) + 5;
	}
	if($up_hp){
		$renew->{'+'}{'maxhp'} += $up_hp;
		$adv->{'maxhp'} += $up_hp;
		$comment .= qq(<br><span class="red">最大HPが $up_hp 上がった。</span>);
	}


	# ●各種自動更新
	if($adv->{'level'} % 10 == 0 || time >= $adv->{'lastmodified'} + 1*24*60*60 || Mebius::alocal_judge()){

		# 職業設定を最新の状態にする
		require Mebius::Adventure::Job;
		($renew->{'jobname'},$renew->{'jobrank'},$renew->{'spatack'},$renew->{'spodds'},$renew->{'jobmatch'},$renew->{'jobconcept'}) = &JobRank($adv->{'job'},$adv->{'level'});

			# アイテムを最新の状態にする
			if($adv->{'item_number'}){
				require Mebius::Adventure::Item;
				my($new) = &SelectItem("Get-hash",$adv->{'item_number'},$adv);
				$renew->{'item_name'} = $new->{'item_name'};
				$renew->{'item_damage'} = $new->{'item_damage'};
				$renew->{'item_job'} = $new->{'item_job'};
				$renew->{'item_concept'} = $new->{'item_concept'};
			}
		
		# 最新状態を更新した時間を覚えておく
		$renew->{'lastmodified'} = time;

	}

# パラメータ上昇・下落の確率を定義
my $up_odds;
my $down_odds = 25;

	# 現在のレベルに応じて、パラメータの上がり方を変更する
	if($adv->{'level'} >= 50){ $up_odds = 7; }
	elsif($adv->{'level'} >= 25){ $up_odds = 6; }
	else{ $up_odds = 5; }

	# ＩＤの長さによって、上がりやすいパラメータを振り分け
	if(length($adv->{'id'}) >= 10){ $most_up{'charm'} = 1; }
	elsif(length($adv->{'id'}) >= 9){ $most_up{'speed'} = 1; }
	elsif(length($adv->{'id'}) >= 8){ $most_up{'tec'} = 1; }
	#elsif(length($adv->{'id'}) >= 7){ $most_up{'vital'} = 1; }
	elsif(length($adv->{'id'}) >= 6){ $most_up{'believe'} = 1; }
	elsif(length($adv->{'id'}) >= 5){ $most_up{'brain'} = 1; }
	else{ $most_up{'power'} = 1; }

# マイスキルの上がりやすさ ( 基本確率に x倍 の確率をプラス )
$up_odds_type = $up_odds / 0.35;

	# 名前の長さによって、下がりやすいパラメータを振り分け
	if(length($adv->{'name'}) >= 8*2){ $most_down{'charm'} = 1; }
	elsif(length($adv->{'name'}) >= 7*2){ $most_down{'speed'} = 1; }
	elsif(length($adv->{'name'}) >= 6*2){ $most_down{'tec'} = 1; }
	#elsif(length($adv->{'name'}) >= 5*2){ $most_down{'vital'} = 1; }
	elsif(length($adv->{'name'}) >= 4*2){ $most_down{'believe'} = 1; }
	else{ $most_down{'brain'} = 1; }


# マイスキルの下がりやすさ ( 基本確率に x倍 の確率をプラス )
$down_odds_type =  $down_odds / 0.8;

	# 一定レベルまでは、パラメータが下がりにくく
	if($adv->{'level'} <= 30){ $down_odds *= 5; }

	# ステータスを展開
	foreach(@{$init->{"status"}}){
			if(rand($up_odds) < 1 || ($most_up{$_} && rand($up_odds_type) < 1)) {
				$renew->{'+'}{"$_"} += 1;
				$adv->{$_} += 1;
				$comment .= qq(<br><span class="red">$init->{"status_name"}->{$_}が1上がった。</span>);
			}
			elsif(rand($down_odds) < 1 || ($most_down{$_} && rand($down_odds_type) < 1)){
				$renew->{'-'}{"$_"} += 1;
				$adv->{$_} -= 1;
				$comment .= qq(<br><span class="blue">$init->{"status_name"}->{$_}が1下がった。</span>);
			}
	}

	# カルマの増減
	if($adv->{'karman'} < 30 && (rand(20) < 1 || ($adv->{'jobname'} =~ /^(僧侶|司教|君主)$/ && rand(50) < 1)) ) {
		$renew->{'+'}{'karman'} += 1;
		$adv->{'karman'} += 1;
		$comment .= qq(<br><span class="red">カルマが1上がった。</span>);
	}
	elsif($adv->{'karman'} > 0 && (rand(20) < 1 || ($adv->{'jobname'} =~ /^(盗賊)$/ && rand(30) < 1)) ){
		$renew->{'-'}{'karman'} += 1;
		$adv->{'karman'} -= 1;
		$comment .= qq(<br><span class="blue">カルマが1下がった。</span>);
	}

	# 小数点を整形する
	foreach(keys %$renew){
			# 数字だけを変更する ( 文字に対して int すると 値が変更されてしまう )
			if($renew->{$_} =~ /^([\d\.]+)$/){ $renew->{$_} = int $renew->{$_}; }
	}

return($comment,$adv,$renew);

}



1;
