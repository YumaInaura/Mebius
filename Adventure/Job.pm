
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# 職業一覧
#-----------------------------------------------------------
sub ViewJob{

# 局所化
my($init) = &Init();
my($init_login) = init_login();
my($line,$form,$selects,$guard_gold,$print);
our($advmy);

# 自キャラのステータス
my($jobflag,$jobline,$job_select,$job_list) = &SelectJob("",$advmy->{'job'},$advmy);

# 武器の引継ぎにかかるお金
my $guard_gold = $advmy->{'level'}*$init->{'itemguard_gold'};

# カンマ
my($guard_gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$guard_gold]);

$print .= qq(<h1>職業リスト</h1>);
$print .= qq($init_login->{'link_line'});

	# 転職フォーム
	if($advmy->{'login_flag'}){

			my($adv_gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$advmy->{'gold'}]);

		$print .= qq(
		<h2>転職する</h2>
		<div class="line_height">
		転職すると全てのステータスが基礎値 ( <span style="color:#f00;">$init->{'kiso_status'}</span> ) に戻り、レベル１からのスタートになります。<br$main::xclose>
		ただし「最大HP」「カルマ」「所持金」「預金額」「現在の経験値」はそのまま引き継がれます。<br><br>
		</div>
		<form action="$init->{'script'}" method="post" class="zero">
		<div>
		現職： $advmy->{'jobname'} / 今までの転職回数: $advmy->{'job_change_count'}回 <br><br>
		$job_select
		<input type="submit" value="この職業に転職する">
		<span class="alert">※転職には $guard_gold_comma\G の紹介料がかかります。 ( 現在の所持金 $adv_gold_comma G )</span>
		<input type="hidden" name="id" value="$advmy->{'id'}">
		<input type="hidden" name="char" value="$advmy->{'char'}">
		<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
		<input type="hidden" name="mode" value="jobchange">
		</div>
		</form>
		);
	}

# 職業リスト
$print .= qq(
<h2>転職に必要なパラメータ</h2>
$job_list
);

$print .= qq(</div>);


Mebius::Template::gzip_and_print_all({ BodyPrint => 1 ,BCL => ["職業"] },$print);


exit;

}


#-----------------------------------------------------------
# 転職を実行
#-----------------------------------------------------------
sub JobChange{

# 局所化
my($init) = &Init();
my($init_login) = init_login();
my($jobline,$firstlv,$flag,%renew);
our($advmy);

# CSS定義
$main::css_text .= qq(
div.message{line-height:1.4;}
form.{margin-top:1em;}
);

	# 各種エラー
	if($main::in{'job'} eq 'no') { main::error("職業を選択してください。"); }

my $job = $main::in{'job'};
my $id = $main::in{'id'};

# キャラファイルを開く
my($adv) = &File("Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} });

# 紹介料
my $jobchange_price = $adv->{'level'}*$init->{'itemguard_gold'};
	if($adv->{'gold'} - $jobchange_price < 0 && !Mebius::alocal_judge()){ main::error("転職のための紹介料が足りません。 $adv->{'gold'}G / ${jobchange_price}G"); }

# 今と同じ職業を選んだ場合
if($main::in{'job'} eq $adv->{'job'} && !$main::alocal_mode){ main::error("既にこの職業です。"); }

# パラメータが足りない場合
my($jobflag,$jobline) = &SelectJob("",$main::in{'job'},$adv);
if(!$jobflag){ main::error("転職するにはパラメータが足りません。"); }

# 職名、必殺技などを取得
my($newjobname,$newjobrank,$newspatack,$newspodds,$newjobmatch,$newjobconcept) = &JobRank($main::in{'job'},1);

	# 職業情報がない場合

$renew{'-'}{'gold'} = $jobchange_price;
$renew{'jobname'} = $newjobname;
$renew{'jobrank'} = $newjobrank;
$renew{'jobmatch'} = $newjobmatch;
$renew{'jobconcept'} = $newjobconcept;
$renew{'spatack'} = $newspatack;
$renew{'spodds'} = $newspodds;
$renew{'='}{'hp'} = "maxhp";

# 各種設定
$renew{'job'} = $job;

# レベルなどを１に戻す
$renew{'level'} = 1;
$renew{'top_monster_level'} = 0;

# 基礎パラメータに戻す
$renew{'power'} = $init->{'kiso_status'};
$renew{'brain'} = $init->{'kiso_status'};
$renew{'believe'} = $init->{'kiso_status'};
$renew{'vital'} = $init->{'kiso_status'};
$renew{'tec'} = $init->{'kiso_status'};
$renew{'speed'} = $init->{'kiso_status'};
$renew{'charm'} = $init->{'kiso_status'};

# カウンタを増やす
$renew{'+'}{'job_change_count'} = 1;

# キャラファイル更新
&File("Renew Mydata Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

my $print = qq(
<h1>$renew{'jobname'}に転職しました！</h1>
$init_login->{'link_line'}
これから新しい人生が始まります。
$init->{'continue_button'}
);

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# その職業になれるかどうかをチェック
#-----------------------------------------------------------
sub SelectJob{

# 局所化
my($type,$select_job,$adv) = @_;
my($init) = &Init();
my($flag,$jobline,$job_select,$job_list,$class1,$my_skills,$onskill_flag);
my($job_handler,@jobnames);

# CSS定義
$main::css_text .= qq(
.gray{background:#ddd;}
.myjob{background:#ff9;}
.jobguide{font-size:90%;line-height:1.4;}
);

# 能力を対比する場合
if($adv->{'power'} || $adv->{'brain'} || $adv->{'believe'} || $adv->{'vital'} || $adv->{'tec'} || $adv->{'speed'} || $adv->{'charm'}){ $onskill_flag = 1; }

# 職業ファイルを開く
open($job_handler,"<$init->{'adv_dir'}_job_data_adventure/job1.dat") || die("Perl Die! Job Data File is not here.");

	# ファイルを展開
	while(<$job_handler>){

		# この行を分解
		chomp;
		my($class1,$status_full_flag);
		my($jobnumber,$jobname2,$power,$brain,$believe,$vital,$tec,$speed,$charm,$spatack,$spodds,$sex2,$jobguide,$jobmatch,$jobconcept2) = split(/<>/);

			# 職業名のみを取得する場合
			if($type =~ /Get-jobname/){
				push(@jobnames,$jobname2);
				next;
			}

			# 該当職業のデータを取得する場合
			if($select_job eq $jobnumber){ $jobline = $_; }

			# 転職/就職できるかどうかをチェック
			if($adv->{'power'} >= $power && $adv->{'brain'} >= $brain && $adv->{'believe'} >= $believe && $adv->{'vital'} >= $vital && $adv->{'tec'} >= $tec && $adv->{'speed'} >= $speed && $adv->{'charm'} >= $charm){
				$status_full_flag = 1;
			}
 
			if($status_full_flag && 
				(
				(!$sex2)
				|| ($sex2 eq "male" && $adv->{'sex'} eq "1")
				|| ($sex2 eq "female" && $adv->{'sex'} eq "0")
				)

			){	
					if($select_job eq $jobnumber){ $flag = 1; $jobline = $_; }
					else{ $job_select .= qq(<option value="$jobnumber">$jobname2</option>\n); }
			}
				elsif($onskill_flag){ $class1 = qq( class="gray"); }
			$job_list .= qq(<tr$class1><td>$jobname2</td><td>$power</td><td>$brain</td><td>$believe</td><td>$vital</td><td>$tec</td><td>$speed</td><td>$charm</td><td class="jobguide">$jobguide</td></tr>\n);
	}
close($job_handler);

	# リターン
	if($type =~ /Get-jobname/){
		return(@jobnames);
	}

$job_select = qq(
<select name="job">
<option value="no">職業</option>
$job_select
</select>
);

	# 自分の能力を表示
	if($adv->{'power'}){
		$my_skills .= qq(<tr class="me">);
		$my_skills .= qq(<td>あなたの能\力</td>);
		$my_skills .= qq(<td>$adv->{'power'}</td><td>$adv->{'brain'}</td><td>$adv->{'believe'}</td><td>$adv->{'vital'}</td>);
		$my_skills .= qq(<td>$adv->{'tec'}</td><td>$adv->{'speed'}</td><td>$adv->{'charm'}</td><td></td></tr>\n);
	}

$job_list = qq(
<table summary="職業リスト" class="adventure">
<tr><th>職名</th><th>力</th><th>知\能\</th><th>信仰心</th><th>生命力</th><th>器用さ</th><th>速さ</th><th>魅力</th><th class="jobguide">説明</th></tr>
$my_skills
$job_list
</table>
);



return($flag,$jobline,$job_select,$job_list);

}


#-----------------------------------------------------------
# 職業ランクを取得
#-----------------------------------------------------------
sub JobRank{

# 局所化
my($job,$level) = @_;
my($jobrank,$class,@jobranks);

# 職業別のクラス
if($job == 0){ @jobranks = ('たまねぎ','にんじん','じゃがいも','町の用心棒','剣術開眼','熟練の猛者','１００人斬り','一騎当千','ヒーロー','民衆の裏切り','裏ヒーロー'); } # 戦士
elsif($job == 1){ @jobranks = ('手品師','黒魔術マニア','地下室の実験者','秘密を知る者','忌み嫌われる者','災いをもたらす者','暗黒の救世主','伝説の魔道師','伝説の大魔道師','火あぶり','伝説の裏魔導師'); } # 魔法使い
elsif($job == 2){ @jobranks = ('聖書プレゼント','熱心な信仰者','教会のピアニスト','都会のヒーラー','片手間牧師','聖書マスター','人気牧師','大いなる予感','神の使い','神の甥','神の弟'); } # 僧侶
elsif($job == 3){ @jobranks = ('小銭泥棒','スリ','泥棒界の係長','泥棒会の中間管理職','泥棒部長','義賊','ルパン１１世','襲名石川五右衛門','伝説の大泥棒','投獄','伝説の裏泥棒'); } # 盗賊
elsif($job == 4){ @jobranks = ('お人よし','人助けのプロ','会長のお気に入り','黄レンジャー','緑レンジャー','青レンジャー','黒レンジャー','赤レンジャー','自主独立','自己破産','チェーン店オーナー'); } # レンジャー
elsif($job == 5){ @jobranks = ('ねるねるねーるね','リトマス試験紙','アミノ酸合成','化学合成','爆発物合成','人体実験','爆発王','実験王','酸の支配者','銀合成','金合成'); } # 錬金術師
elsif($job == 6){ @jobranks = ('お部屋ソング','路上ライブ','下積み時代','注目のデビュー','ヒットメイカー','ミリオンセラー','プラチナレコード','グラミー賞','伝説のポップスター','売り上げスランプ','第二のビートルズ'); } # 吟遊詩人
elsif($job == 7){ @jobranks = ('興味','傾倒','目覚め','苦悩','失望','絶望','瓦解','崩壊','奇跡','肥大','銀河'); } # 
elsif($job == 8){ @jobranks = ('小さな妖精','心の恋人','美しき精霊','イデアの破片','魂の欠片','神話の胎児','聖なる声','女神の化身','ワーグナーの恋人','バッハの愛人','ベートーベンの妻'); } # ワルキューレ
elsif($job == 9){ @jobranks = ('素朴な仲介者','駆け出しの信仰者','中庸の伝道者','収賄の渡し舟','人心掌握の時','偉大なる詐欺師','侵略の天才','自称法王','悪徳の支配者','ダモクレスの剣','破滅寸前'); } # 司祭
elsif($job == 10){ @jobranks = ('ままごとロード','あの娘のお守り','騎士の端くれ','普通の騎士','騎士道の鏡','王の近衛兵','次期当主候補','一城の主','伝説の君主','伝説の超君主','伝説の裏君主'); } # 君主
elsif($job == 11){ @jobranks = ('ちゃんばらごっこ','おだんござむらい','竹刀稽古','木刀稽古','元服','忠実な僕','忍耐の鏡','死ぬことと見つけたり','伝説の武士','みねうちで殺す','宮本武蔵がハエのようだ'); }
elsif($job == 12){ @jobranks = ('へなちょこパンチ','猫なでパンチ','ジャブ','左フック','右ストレート','カミソリアッパー','ダブルパンチ','トリプルパンチ','納豆チョップ','豆腐キック','ひよこサブレ'); } # モンク
elsif($job == 13){ @jobranks = ('おしのびごっこ','みならいにんじゃ','下忍','中忍','上忍','忍者頭','暗躍時代','一国の功労者','伝説の忍び','殿100人殺し','織田信長の暗殺者'); } # 忍者
elsif($job == 14){ @jobranks = ('よちよちダンス','みかん箱ダンサー','路上のダンサー','舞台稽古','バックダンサー','メインダンサー','売れっ子ダンサー','伝説のダンサー','ムーンウォーク','アン・ドゥ・トロワ'); } # 踊り子

	# 職業クラス判定
	if($level >= 100000) { $class = $jobranks[10]; }
	elsif($level >= 50000) { $class = $jobranks[9]; }
	elsif($level >= 10000) { $class = $jobranks[8]; }
	elsif($level >= 5000) { $class = $jobranks[7]; }
	elsif($level >= 1000) { $class = $jobranks[6]; }
	elsif($level >= 500){ $class = $jobranks[5]; }
	elsif($level >= 250){ $class = $jobranks[4]; }
	elsif($level >= 100){ $class = $jobranks[3]; }
	elsif($level >= 50){ $class = $jobranks[2]; }
	elsif($level >= 20){ $class = $jobranks[1]; }
	else{ $class = $jobranks[0]; }

	# 職名などを取得
	my($jobname,$jobline) = &SelectJob("",$job);
	my($advjobnumber,$advjobname,$advpower,$advbrain,$advbelieve,$advvital,$advtec,$advspeed,$advcharm,$advspatack,$advspodds,$advjobsex,$advjobguide,$advjobmatch,$advjobconcept) = split(/<>/,$jobline);

# 数値を最終定義
$jobrank = $class;

# リターン
return($advjobname,$jobrank,$advspatack,$advspodds,$advjobmatch,$advjobconcept);

}


1;



1;
