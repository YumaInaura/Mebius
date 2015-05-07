
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# ログイン
#-----------------------------------------------------------
sub Login{

# 局所化
my($init) = &Init();
my($init_login) = init_login();
my($hit,$ltime,$vtime,$mtime,$special_line);
my($monster_line,$yado_line);
my($head_javascript,$view_jsredirect,$battle_line,$class_disabled,$status_line,$monster_disabled,$battle_disabled,$special_disabled,$yado_disabled);
my($monster_select_disabled,$print);
my($parts) = Mebius::Parts::HTML();

# データをコピー 
my($advmy) = &my_data();
my $adv = $advmy;


	# ステータス表示部分を取得
	if($adv->{'f'}){
		require Mebius::Adventure::Charactor;
		($status_line) = &CharaStatus({ TypeMyStatus => 1 },$adv);
		$status_line = qq(<h2><a href="$init->{'adv_url'}?mode=status&amp;id=$adv->{'id'}">あなたのステータス</a></h2>\n$status_line);
	}
	# ログインしていない場合
	else{
		$yado_disabled = $parts->{'disabled'};
		$special_disabled = $parts->{'disabled'};
		$battle_disabled = $parts->{'disabled'};
		$monster_disabled = $parts->{'disabled'};
		$monster_select_disabled = $parts->{'disabled'};
		$adv->{'name'} = "$init->{'title'}";

	}

	# 待ち時間中は ボタンを disabled に
	if($adv->{'wait_disabled'}){
		$monster_disabled = $parts->{'disabled'};
		$battle_disabled = $parts->{'disabled'};
		$special_disabled = $parts->{'disabled'};
	}

	# テストプレイヤーの場合は特殊行動 / チャンプ戦ができないように
	if($adv->{'test_player_flag'}){
		$battle_disabled = $parts->{'disabled'};
		$special_disabled = $parts->{'disabled'};
	}

# 全キャラの行動記録を取得
my($situation) = &SituationFile({ TypeGetIndex => 1 , MaxViewLine => 5 });

# 全キャラの戦況を取得
#my($alllog_line) = &viewlog("ALL","3");
#<h2><a href="$init->{'script'}?mode=log#RECORD">チャンプ履歴</a></h2>
#$alllog_line

# 設定変更フォームを取得
my($form_line);
	if($adv->{'f'}){
		require Mebius::Adventure::Charactor;
		($form_line) = &CharaForm(undef,$adv);
		$form_line = qq(<h2>設定変更</h2>$form_line);
	}

# モンスターと戦う
$monster_line .= qq(
<form action="$init->{'script'}" method="post" class="zero aselect"$main::sikibetu>
<div class="inline">
<input type="hidden" name="mode" value="monster">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="char" value="$adv->{'char'}">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
<input type="submit" value="モンスターと戦う" id="monster_battle" class="monster $class_disabled"$monster_disabled>
);


# 敵のセレクト
$monster_line .= qq(<select name="m_type"$monster_select_disabled>);
if($main::alocal_mode){ $monster_line .= qq(<option value="99">テストレベル</option>\n); }

	# 展開
	for(0...12){

		# レベル制限
		if(Mebius::alocal_judge()){ $monster_line .= qq(<option value="$_" style="background:#fcc;">レベル$_</option>\n); }
		if($_ >= 1 && $adv->{'top_monster_level'} < $_){ next; }

		if($adv->{'last_select_monster_rank'} == $_){ $monster_line .= qq(<option value="$_"$parts->{'selected'}>レベル$_</option>\n); }
		else{ $monster_line .= qq(<option value="$_">レベル$_</option>\n); }

	}

$monster_line .= qq(</select></div></form>);

# チャンプファイルを取得
my($champ) = &ChampFile(undef,undef,$adv);

# チャンプに挑戦
my($battle_submit) = qq(<input type="submit" value="チャンプ ( $champ->{'name'} ) に挑戦" class="battle $class_disabled" id="champ_battle"$battle_disabled>);
	if($adv->{'id'} eq $champ->{'id'} && !Mebius::alocal_judge()){
		$battle_submit = qq(<input type="submit" value="チャンプ ( $champ->{'name'} ) はあなたです" class="disabled2"$parts->{'disabled'}>\n);
	}

$battle_line = qq(
<form action="$init->{'script'}" method="post" class="zero aselect"$main::sikibetu>
<div class="inline">
<input type="hidden" name="mode" value="battle">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="char" value="$adv->{'char'}">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
$battle_submit
</div>
</form>
);


# 宿
#require Mebius::Adventure::Yado;
require Mebius::Adventure::Yado;

my($yado_gold) = yado_gold($adv,$champ->{'mychamp_flag'});
my($adv_gold_comma,$yado_gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$adv->{'gold'},$yado_gold]);
my($yado_submit) = qq(<input type="submit" value="宿に泊まる ( $yado_gold_comma\G / $adv_gold_comma\G )" class="yado"$yado_disabled>);
	if($adv->{'hp'} >= $adv->{'maxhp'} && $adv->{'sp'} >= 15 && !Mebius::alocal_judge()){
		$yado_submit = qq(<input type="submit" value="宿に泊まる ( HPが満タンです )" class="disabled2"$parts->{'disabled'}>);
	}
	if($adv->{'gold'} < $yado_gold){
		$yado_submit = qq(<input type="submit" value="宿に泊まる ( $yado_goldＧ / $adv_gold_commaＧ )" class="disabled2"$parts->{'disabled'}>);
	}

$yado_line = qq(
<form action="$init->{'script'}" method="post" class="zero aselect"$main::sikibetu>
<div class="inline">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="mode" value="yado">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
<input type="hidden" name="char" value="$adv->{'char'}">
$yado_submit
</div>
</form>
);

# 特殊行動
($special_line) = &get_special("",$adv->{'jobname'},$adv,$special_disabled);

# キャラを選んで戦う
#($select_fight_line) = &get_select_fight("");

# タイトル定義
$main::head_link3 = qq( &gt; マイキャラ );

# CSS定義
$main::css_text .= qq(
div.aselect{line-height:2.5;}
form.aselect{display:inline;margin:1em 2.0em 0em 0em;}
.inline{display:inline;}
input.yado{background:#9f9;border-color:#9f9;}
input.disabled2{background:#ddd !important;border-color:#ddd !important;}
);


# HTML

	# 大見出し
	if($adv->{'test_player_flag'} || !$adv->{'id'}){
		$print .= qq(<h1>$adv->{'name'}</h1>);
	}
	else{
		$print .= qq(<h1>$adv->{'name'} <span class="green">\@$adv->{'id'}</span></h1>);
	}
$print .= qq($init_login->{'link_line'});
#$print .= qq($view_jsredirect);
$print .= qq($init->{'ads1_formated'});

	# 自動ツール避け
	if($adv->{'over_action_flag'}){
		$print .= qq(<br><br>);
	}

# ＨＴＭＬを表示
$print .= qq(
<div class="aselect">
$monster_line
$battle_line
$yado_line
$special_line
</div>
$status_line
<h2><a href="$init->{'script'}?mode=log#FIGHT">全キャラの戦況</a></h2>
$situation->{'index_line'}
$form_line
);

$print .= qq(</div>);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# 特殊行動
#-----------------------------------------------------------
sub get_special{

# 局所化
my($type,$jobname,$adv,$class_disabled) = @_;
my($init) = &Init();
my($line,$getid_flag,$submit,$type2,$job_select,$selects);
my($TypeViewHP,$TypeViewGold,$TypeJudgeLevel,$TargetJobName);
our($advmy);

	# 職業
	if($jobname eq "錬金術師"){ $submit = qq(武器を研究する); $getid_flag = 1; }
	elsif($jobname eq "踊り子"){ $submit = qq(踊る); $getid_flag = 1; }
	elsif($jobname eq "司教"){ $submit = qq(カルマを高める); $getid_flag = 1; }
	elsif($jobname eq "君主"){ $submit = qq(没収する); $getid_flag = 1;  $TypeViewHP = 1; $TypeViewGold = 1; $TargetJobName = "盗賊"; }
	elsif($jobname eq "侍"){ $submit = qq(斬る); $getid_flag = 1; $TypeViewHP = 1; $TypeJudgeLevel = 1; }
	elsif($jobname eq "盗賊"){ $submit = qq(盗みを働く); $getid_flag = 1; $TypeViewGold = 1; $TypeJudgeLevel = 1; }
	elsif($jobname eq "僧侶"){ $submit = qq(祈る); $getid_flag = 1; }
	else{ return; }

# 送信ボタン
my($submit) = qq(<input type="submit" value="$submit" class="special" id="special_action"$class_disabled>);

	# 全キャラのＩＤを取得
	if($getid_flag){
		require Mebius::Adventure::Ranking;
		(undef,$selects) = &RankingFile({ TypeGetSelectOption => 1 , TargetJobName => $TargetJobName , TypeViewGold => $TypeViewGold , TypeViewHP => $TypeViewHP , TypeJudgeLevel => $TypeJudgeLevel  },undef,$adv);
		#$selects = $ranking->{'select_option_line'};
	}
	else{
		($selects) = qq(<input type="hidden" name="target_id" value="id_none">);
	}

# フォーム
$line = qq(
<br>
<form action="$init->{'script'}" method="post" class="zero aselect $class_disabled"$main::sikibetu>
<div class="inline">
<input type="hidden" name="mode" value="special">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="char" value="$adv->{'char'}">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
<input type="hidden" name="target_file_type" value="account">
$submit
<select name="target_id">
<option value="">なし</option>
$selects
</select>
</div>
</form>
);


# リターン
return($line);

}


1;
