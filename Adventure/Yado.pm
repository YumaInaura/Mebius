
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# 宿に泊まる
#-----------------------------------------------------------
sub Yado{

# 局所化
my($init) = Init();
my($init_login) = init_login();
my($advmy) = my_data();
my($hit,$date,$yado_gold,$message,$repair_hp,$repair_gold,$results,$first_hp,$first_gold,$last_hp);
my(@yado_new,%renew,$print);

# キャラファイルを開く
my($adv) = File("Password-check Char-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} });

# チャンプファイルを取得
my($champ) = ChampFile(undef,undef,$adv);

# 宿代の調整
my($yado_gold) = yado_gold($adv,$champ->{'mychamp_flag'});
	if($adv->{'gold'} < $yado_gold) { main::error("お金が足りません！　叩き出されました。"); }

	# 各種処理
	if($adv->{'hp'} >= $adv->{'maxhp'} && $adv->{'sp'} >= 15 && !Mebius::alocal_judge()){
		main::error("そんなに眠れません。");
	}

	# イベント（１）
	if(rand(40) < 1){ $yado_gold *= -1; $results = qq(<li>親切な親方がタダで泊めてくれた上に、利益還元祭でキャッシュバックをくれました。); }
	elsif(rand(20) < 1){ $yado_gold = 0; $results = qq(<li>親切な親方がタダで泊めてくれました。); }
	elsif(rand(20) < 1){ $yado_gold *= 2; $results .= qq(<li>飲めや歌えやで、いつもより多くお金を使いました。); }
	elsif(rand(40) < 1){ $yado_gold *= 4; $results .= qq(<li>今日は貸し切りだ、気分が良い！、いつもより多くお金を使いました。); }

	# ●最大HPのアップ
	{
		# 局所化
		my($plus_maxhp);

			# イベント抽選
			if(rand(1_000_000) < 1){ $plus_maxhp = 10000; }
			elsif(rand(100_000) < 1){ $plus_maxhp = 5000; }
			elsif(rand(10_000) < 1){ $plus_maxhp = 1000; }
			elsif(rand(1_000) < 1){ $plus_maxhp = 500; }
			elsif(rand(100) < 1){ $plus_maxhp = 100; }
			elsif(rand(50) < 1){ $plus_maxhp = 10; }

			# イベントが発生した場合
			if($plus_maxhp){
				$renew{'+'}{'maxhp'} = $plus_maxhp;
				$renew{'+'}{'hp'} = $plus_maxhp;
				$results .= qq(<li>たくさん寝て最大ＨＰが <strong class="hpcolor">$plus_maxhp</strong> 増えました。);
			}
	}

	# ●レベルアップブースト
	if($adv->{'exp'} >= 1 && time >= $adv->{'last_yado_time'} + 15){

		my $exp_gyap = $adv->{'exp'} / $adv->{'next_exp'} if($adv->{'next_exp'} >= 1);

			if($exp_gyap >= 50){

				my($levelup_boost,$person,$odds);

					# 確率を増やす
					if($exp_gyap >= 100_000){ $odds = 2.0; }
					elsif($exp_gyap >= 10_000){ $odds = 1.75; }
					elsif($exp_gyap >= 1_000){ $odds = 1.5; }
					else{ $odds = 1.0; }

					# 発動判定
					if(rand(100_000/$odds) < 1){ $levelup_boost = 10; $person = '永谷園の鮭茶漬け'; }
					elsif(rand(50_000/$odds) < 1){ $levelup_boost = 7; $person = '鉄人の特製目玉焼き'; }
					elsif(rand(10_000/$odds) < 1){ $levelup_boost = 6; $person = '一流シェフの特製ビーフステーキ'; }
					elsif(rand(5_000/$odds) < 1){ $levelup_boost = 5; $person = 'ばあやの特製うめぼしおにぎり'; }
					elsif(rand(1_000/$odds) < 1){ $levelup_boost = 4; $person = 'おふくろの特製ごぼうバーガー'; }
					elsif(rand(500/$odds) < 1){ $levelup_boost = 3; $person = 'お姉さんの特製カレーライス'; }
					elsif(rand(250/$odds) < 1){ $levelup_boost = 2; $person = '親父の特製シチュー'; }

					# 効果が発動した場合
					if($levelup_boost){

							# 効果が終わっていない場合には追加発動
							if(time < $adv->{'effect_levelup_boost_time'}){
								$renew{'+'}{'effect_levelup_boost'} = $levelup_boost;
								$renew{'+'}{'effect_levelup_boost_time'} = 30*60;
							# 普通の発動
							} else {
								$renew{'effect_levelup_boost'} = $levelup_boost;
								$renew{'effect_levelup_boost_time'} = time + 30*60;
							}
						$results .= qq(<li class="red">「${person}」が激ウマ！ しばらくの間、レベルが <strong>${levelup_boost}倍</strong> 上がりやすくなりました。);
					}

			}

	}

# キャラファイルの値を定義
$renew{'hp'} = $adv->{'maxhp'};
$renew{'-'}{'gold'} = $yado_gold;
$renew{'sp'} = $init->{'kiso_sp'};
$renew{'last_yado_time'} = time;

# カウント
$renew{'+'}{'yado_count'} = 1;

# キャラファイルを更新
my($renewed) = &File("Password-check Mydata Renew",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} },\%renew);

# カンマを付ける
my($left_gold_comma) = Mebius::japanese_comma($renewed->{'gold'});

# 結果表示を追加
if($champ->{'mychamp_flag'}){ $results .= qq(<li>チャンプなので豪華なホテルに泊まりました。); }
#$results .= qq(<li>HP $adv->{'hp'}  → HP $repair_hp );
$results .= qq(<li>残り所持金 <span class="goldcolor">$left_gold_comma G</span>); # $adv->{'gold'} G → 
$results .= qq(<li>HPとSP が回復しました。);


	if($yado_gold >= 1){ $print .= qq(<h1>${yado_gold}Gで宿泊しました</h1>); }
	else{ $print .= qq(<h1>タダで宿泊しました</h1>); }

$print .= qq(
$init_login->{'link_line'}
<div class="line-height-large">
<ul>
$results
</ul>
</div>
$init->{'continue_button'}
<hr>

);

Mebius::Template::gzip_and_print_all({ RefreshURL => $init->{'login_url'} , RefreshSecond => 10  },$print);

exit;

}

#-----------------------------------------------------------
# 宿代の計算
#-----------------------------------------------------------
sub yado_gold{

my($adv,$my_champ_flag) = @_;
my($level,$maxhp,$job) = ($adv->{'level'},$adv->{'maxhp'},$adv->{'job'});
my($yado_gold,$yado_dai);

	# 宿の基本倍数
	if($level >= 10000){ $yado_dai = 25.0; }
	elsif($level >= 5000){ $yado_dai = 20.0; }
	elsif($level >= 1000){ $yado_dai = 17.5; }
	elsif($level >= 500){ $yado_dai = 15.0; }
	elsif($level >= 100){ $yado_dai = 12.5; }
	elsif($level >= 50){ $yado_dai = 10; }
	else{ $yado_dai = 5; }

# レベルから計算
$yado_gold = $yado_dai * $level;

	# チャンプの場合
	if($my_champ_flag){ $yado_gold *= 3;  }

	# レベルアップ強化中
	if($adv->{'effect_levelup_boost'} >= 5 && $adv->{'effect_levelup_boost_time'} > time){
		$yado_gold *= ($adv->{'effect_levelup_boost'}/2);
	}

# 整数にする
$yado_gold = int $yado_gold;

return($yado_gold);

}


1;
