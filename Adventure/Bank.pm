
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# 銀行の基本設定
#-----------------------------------------------------------
sub InitBank{

# 局所化
my($use,$adv) = @_;
my(%init_bank);
my($advmy) = my_data();
our($charge,$take_charge,$gamble_minlate,$max_loan) = (undef);

$main::sub_title = "銀行 | $main::title";

# 手数料のパーセンテージ
$charge = 5;

	# 借金の限度額
	if($max_loan > 5000000){ $max_loan = 5000000; }
	else{ $max_loan = 5000 + ($advmy->{'level'}*2000); }

	# 手数料の割増、割引
	if($advmy->{'jobname'} eq "レンジャー"){ $charge = 0; }
	elsif($advmy->{'jobname'} eq "司教"){ $charge = 0; }
	#elsif($advmy->{'jobname'} eq "君主"){ $charge = 3; }
	elsif($advmy->{'jobname'} eq "僧侶"){ $charge = 3; }
	elsif($advmy->{'jobname'} eq "魔法使い"){ $charge = 10; }
	elsif($advmy->{'jobname'} eq "超能\力者"){ $charge = 10; }
	elsif($advmy->{'jobname'} eq "錬金術師"){ $charge = 10; }
$take_charge = $charge*3;

# 賭けの最低レート
$gamble_minlate = $advmy->{'level'} * 10;

$init_bank{'head_title'} = "銀行";
$init_bank{'head_title_link'} = qq(<a href="?mode=bank">銀行</a>);

return(\%init_bank);

}

#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------
sub Bank{

	if($main::in{'type'} eq "deposit"){ &BankDeposit(); }
	elsif($main::in{'type'} eq "autobank"){ &BankDeposit(); }
	elsif($main::in{'type'} eq "charity"){ &BankCharity(); }
	elsif($main::in{'type'} eq "lot"){ &BankLot(); }
	elsif($main::in{'type'} eq ""){ &ViewBank(); }

	else{ main::error("ページが存在しません。[ADBK]"); }
}


#-----------------------------------------------------------
# 銀行ページ表示
#-----------------------------------------------------------
sub ViewBank{

# 局所化
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($charity,$message,$form,$charge_gold,$charity_line,$i,$message2);
our($advmy,$charge,$max_loan,$take_charge,$gamble_minlate);

# CSS定義
$main::css_text .= qq(
form{margin:1em 0em;}
table{width:100%;}
.now_gold{width:17em;display:inline;width:200px;} 
.keep_gold{width:30em;display:inline;width:200px;}
th{text-align:center;}
th.charity_rank{width:3.5em;}
);

# カンマを付ける
my($advcharity_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$advmy->{'charity'}]);

	# 募金ランキングを取得
	if($main::in{'old_data'}){
		($charity) = &CharityFile({ FileType => "Old" , TypeGetIndex => 1 });
	}
	else{
		my $MaxViewIndex = 10;
			if($main::in{'view_all'}){ $MaxViewIndex = "All"; }
		($charity) = &CharityFile({ TypeGetIndex => 1 , TypeGetIndex => 1 , MaxViewIndex => $MaxViewIndex });
	}

# 募金ランキングを整形
$charity_line = qq(
<table summary="募金額リスト" style="width:60%;" class="adventure" id="CHARITY">
<tr><th class="charity_rank">ご順位</th><th>お名前</th><th>募金額</th></tr>
$charity->{'index_line'}
</table>
);

	# 続き表示リンク
	if($charity->{'flow_flag'}){
		$charity_line .= qq( <a href="$init->{'script'}?mode=bank&amp;view_all=1#CHARITY">→全て見る</a>);
	}

	# 旧データへのリンク ( 2011/12/31 (土) )
	if(!$main::in{'old_data'}){
		$charity_line .= qq( <a href="$init->{'script'}?mode=bank&amp;old_data=1#CHARITY">→旧募金ランキング</a>);
	}

# 手数料
$charge_gold = int $advmy->{'gold'} * $charge*0.01;

# メッセージ
if($advmy->{'name'}){ $message .= qq($advmy->{'name'} 様、いらっしゃいませ。<br>); }
#if($advbank >= 1){ $message .= qq(現在 <strong class="goldcolor">${advbank}G</strong> お預かりしております。); }
#else{ $message .= qq(現在お預かりしているお金はございません。); }
#$message .= qq(（ 所持金： <strong class="goldcolor">${advgold}G</strong> ）);

	# フォーム
	if($advmy->{'login_flag'}){}
	else{}

# 初期入力金額
my $keepgold_value = $advmy->{'gold'};
my $charitygold_value = int($advmy->{'gold'}*0.1);
my $takegold_value = $advmy->{'bank'};
	if($advmy->{'bank'} < 0){ $takegold_value = 0; }

# カンマを付ける
my($bank_commma,$gold_comma,$keepgold_comma,$takegold_comma,$charitygold_value_comma,$gamble_gold_comma) =
		 Mebius::MultiComma({ Language => $init->{'comma_language'} },[$advmy->{'bank'},$advmy->{'gold'},$keepgold_value,$takegold_value,$charitygold_value,$advmy->{'last_gamble_win_gold'}]);

# 初期入力
my($first_input_take_bank);
	if(Mebius::alocal_judge()){ $first_input_take_bank = $advmy->{'bank'}; }
	else{ $first_input_take_bank = 0; }

# フォーム
$form .= qq(
<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="deposit">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
<div class="now_gold">所持金 <strong class="goldcolor">$gold_comma\G</strong> のうち</div>
<div class="keep_gold"><input type="text" name="keep_gold" value="$gold_comma"> G を <input type="submit" name="deposit_type" value="預ける"></div>
</div>
</form>

<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="deposit">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
<div class="now_gold">預金 <strong class="goldcolor">$bank_commma\G</strong> のうち</div>
<div class="keep_gold"><input type="text" name="take_gold" value="$first_input_take_bank"> G を <input type="submit" name="deposit_type" value="引き出す"></div>
</div>
</form>
);

	# 手数料の割引
	if($charge == 0){
		$form .= qq(<p>──これはこれは <span class="red">$advmy->{'jobname'}様！</span> 　もちろん手数料はいただきません。</p>);
	}
	else{
		$form .= qq(<span class="guide">※お預かりの際は $chargeパーセント、ご融資の際は $take_charge パーセント の手数料を申\し受けます。</span>); 
	}
		$form .= qq(<br><span class="guide">※預金額以上に引き出すと、ご融資となります。お客様の限度額は $max_loan\G です。</span>); 

# 自動振替
$form .= qq(
<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
今後、獲得ゴールドのうち 
<input type="text" name="autobank_gold" value="$advmy->{'autobank'}"> ％ を 
<input type="submit" name="deposit_type" value="自動振替する">
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="autobank">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
</div>
</form>
);
$form .= qq(<span class="guide">※戦闘でゴールドを獲得なさった場合、お客様の口座に自動積み立ていたします。手数料はお預かり金額の20%です。</span>);

if($advmy->{'charity'} >= 1){ $message2 .= qq(あなたの募金額： <strong class="goldcolor">$advcharity_comma\G</strong>); }


# ギャンブル
$form .= qq(
<h2 id="GAMBLE">ギャンブル</h2>
あなたのお金を２倍にしませんか？
<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="lot">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
所持金： <strong class="goldcolor">$gold_comma\G</strong> のうち <input type="text" name="lot_gold" value="$gold_comma"> G を
<input type="submit" value="賭ける">);

	# 前回の賭けの結果
	if(time <= $advmy->{'last_gamble_time'} + 3*60){
				# カンマ
				my($lot_gold_comma,$win_gold_comma) = Mebius::MultiComma({ Language => "Japanese" } , [$advmy->{'last_gamble_lot_gold'},$advmy->{'last_gamble_win_gold'}]);
				# 賭けた時間
				my($how_before) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-前",time - $advmy->{'last_gamble_time'});

			# 勝っていた場合
			if($advmy->{'last_gamble_result'} eq "Win"){

				$form .= qq!<p><span class="message-yellow">賭けは当たりました！ ( $lot_gold_comma\G → $win_gold_comma\G )　 $how_before</span></p>!;
			}

			# 負けていた場合
			elsif($advmy->{'last_gamble_result'} eq "Lose"){
				my($how_before) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-前",time - $advmy->{'last_gamble_time'});
				$form .= qq!<p><span class="message-blue">賭けは外れました。 ( $lot_gold_comma\G → 没収 )　 $how_before</span></p>!;
			}
	}

$form .= qq(</div><br>
<span class="guide">
※$advmy->{'name'}様の最低掛け金は$gamble_minlate\Gです。<br>
※サーバーに負担をかける行為（ 確率確認のための連続賭けなど ）はご遠慮ください。
</span>
</form>
);

# 募金
$form .= qq(
<h2 id="CHARITY">募金</h2>
恵まれないモンスターの子供たちに、どうぞ愛の手を。<br><br>
$message2
<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="charity">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
所持金： <strong class="goldcolor">$gold_comma\G</strong> のうち <input type="text" name="charity_gold" value="$charitygold_value_comma"> G を
<input type="submit" value="募金する">
</div>
</form>
<h3>いままでに募金いただいた皆様 (上位)</h3>
$charity_line
);




my $print  = qq(
<h1>銀行</h1>
$init_login->{'link_line'}
<h2>窓口</h2>
$message
$form
);

Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , BCL => [$init_bank->{'head_title'}] },$print);

exit;

}


#-----------------------------------------------------------
# 預金の預かり、引き出し
#-----------------------------------------------------------
sub BankDeposit{

# 局所化
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($deposit_gold,%renew);
our($take_charge,$max_loan,$charge,$advmy);

# GET送信を禁止
main::axscheck("Post-only ACCOUNT");

	# 汚染チェック
	if($main::in{'deposit_type'} eq "預ける"){ $deposit_gold = $main::in{'keep_gold'}; }
	elsif($main::in{'deposit_type'} eq "引き出す"){ $deposit_gold = $main::in{'take_gold'}; }
	elsif($main::in{'deposit_type'} =~ /(自動振替)/){ $deposit_gold = $main::in{'autobank_gold'}; }
	else{ main::error("処理タイプを選んでください。"); }

# 整形
require "${main::int_dir}regist_allcheck.pl";
($deposit_gold) = main::bigsmall_number($deposit_gold);
($deposit_gold) = Mebius::MultiComma({ TypeDecodeComma => 1 , Language => $init->{'comma_language'} },[$deposit_gold]);
$deposit_gold =~ s/,//g;

	if($deposit_gold =~ /\D/){ main::error("値は数字で指定してください。"); }
	if($main::in{'deposit_type'} ne "自動振替する" && ($deposit_gold eq "" || $deposit_gold eq "0")){ main::error("お客様、金額をご入力ください。"); }
	if($main::in{'deposit_type'} eq "自動振替する" && ($deposit_gold > 100 || $deposit_gold < 0 || length($deposit_gold) > 3)){ main::error("1%～100%の間で設定してください。"); }

# キャラデータを読み込む
my($adv) = &File("Password-check Char-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} });

	# ●預かり
	if($main::in{'deposit_type'} eq "預ける"){
			if($deposit_gold > $adv->{'gold'}){ main::error("お客様、所持金が足りません。"); }
			if($deposit_gold < 0){ main::error("お客様、マイナスの預金は出来ません。"); }

		$renew{'-'}{'gold'} = $deposit_gold;
		$renew{'+'}{'bank'} = int($deposit_gold*(1-($charge*0.01)));

	}

	# ●引き出し
	elsif($main::in{'deposit_type'} eq "引き出す"){
		my($do_take_charge);
		my $loan = ($deposit_gold - $adv->{'bank'});
			# 融資する場合
			if($loan >= 1){
				my $nowbank = $adv->{'bank'};
					if($nowbank <= 1){ $nowbank = 0; }
				$do_take_charge = int(($deposit_gold-$nowbank)*$take_charge*0.01);
					if($loan > $max_loan){ main::error("お客様の融資枠は $max_loan\G までです。"); }
			}
		$renew{'+'}{'gold'} = $deposit_gold;
		$renew{'-'}{'bank'} = ($deposit_gold+$do_take_charge);
	}

	# 自動振替の開始、停止
	elsif($main::in{'deposit_type'} =~ /自動振替する/){ $renew{'autobank'} = $deposit_gold; }

# キャラデータを更新
&File("Password-check Mydata Renew",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

# リダイレクト
Mebius::Redirect("","$init->{'script'}?mode=bank");

exit;

}


#-----------------------------------------------------------
# ギャンブルを実行
#-----------------------------------------------------------
sub BankLot{

# 局所化
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($message1,$plus_gold,$result);
my(%renew);
our($advmy,$gamble_minlate);

# アクセス制限
main::axscheck("Post-only ACCOUNT");

# キャラデータを読み込む
my($adv) = &File("Mydata Password-check Char-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'}});

# 各種エラー
require "${main::int_dir}regist_allcheck.pl";
($main::in{'lot_gold'}) = main::bigsmall_number($main::in{'lot_gold'});
($main::in{'lot_gold'}) = Mebius::MultiComma({ TypeDecodeComma => 1 , Language => $init->{'comma_language'} },[$main::in{'lot_gold'}]);
$main::in{'lot_gold'} =~ s/,//g;
$main::in{'lot_gold'} =~ s/^(0+)//g;
	if($main::in{'lot_gold'} =~ /^-/){ main::error("ふてえ野郎だ！"); }
	if($main::in{'lot_gold'} =~ /\D/){ main::error("金額は半角数字で入力してください。"); }
	if($main::in{'lot_gold'} eq "" || $main::in{'lot_gold'} == 0){ main::error("金額を入力してください。"); }
	if($main::in{'lot_gold'} > $adv->{'gold'}){ main::error("お金が足りません。"); }
	if($main::in{'lot_gold'} < $gamble_minlate){ main::error("$adv->{'name'}様の最低掛け金は$gamble_minlate\Gでございます。"); }

# 連続制限
main::redun("ADV_GAMBLE",3,5);

# 賭け金
my $use_gold = $main::in{'lot_gold'};

# クジを引く
my $percent = 210;

	if($adv->{'jobname'} eq '超能力者'){ $percent = 195; $message1 .= qq($adv->{'name'} は超能\力で、ほんのわずかに当たる確率を高めた！<br>); }
	if(rand($percent) < 100){
		$renew{'+'}{'gold'} = $use_gold;
		$plus_gold = int($use_gold*2);
		$message1 .= qq(賭けが当たり、掛け金が２倍になりました！);
		$result = "+$use_gold";
		$renew{'last_gamble_win_gold'} = $plus_gold;
		$renew{'last_gamble_result'} = "Win";

			# 戦況を記録
			if(!$adv->{'test_player_flag'}){
				my $NewComment1 = qq($adv->{'chara_link'} が);
				my $NewComment2 = qq(<a href="$init->{'script'}?mode=bank#GAMBLE">ギャンブル</a>で $main::in{'lot_gold'}G を <span class="goldcolor">$plus_gold\G</span> に増やしました。</span>);
				&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
			}

	}
	else{
		$renew{'+'}{'gold'} -= $use_gold;
		$message1 .= qq(賭けは外れました。);
		$result = "-$main::in{'lot_gold'}";
		$renew{'last_gamble_result'} = "Lose";
	}

# 共通の更新内容
$renew{'last_gamble_lot_gold'} = $use_gold;
$renew{'last_gamble_time'} = time;

# キャラデータを更新
&File("Mydata Renew Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

# リダイレクト
Mebius::Redirect(undef,"$init->{'base_url'}?mode=bank#GAMBLE");

# ジャンプ
$main::jump_url = "$init->{'script'}?mode=bank";
$main::jump_sec = 5;


my $print = qq(
<h1>銀行</h1>
$init_login->{'link_line'}
<div class="results">
$message1
(<a href="$main::jump_url">→銀行に戻る</a>)
</div>
$init->{'continue_button'}
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# 募金
#-----------------------------------------------------------
sub BankCharity{

# 局所化
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($flag,$hit,@charity_list,$i,$message,$charity_handler,@line,%renew);
our($advmy);

# アクセス制限
main::axscheck("Post-only ACCOUNT");

# キャラデータを読み込む
my($adv) = &File("Mydata Password-check Char-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} });

# 各種エラー
require "${main::int_dir}regist_allcheck.pl";
($main::in{'charity_gold'}) = main::bigsmall_number($main::in{'charity_gold'});
($main::in{'charity_gold'}) = Mebius::MultiComma({ TypeDecodeComma => 1 , Language => $init->{'comma_language'} },[$main::in{'charity_gold'}]);
$main::in{'charity_gold'} =~ s/,//g;
	if($main::in{'charity_gold'} =~ /^-/){ main::error("この募金箱は誰にも渡しません！"); }
	if($main::in{'charity_gold'} =~ /\D/){ main::error("金額は半角数字で入力してください。"); }
	if($main::in{'charity_gold'} eq "" || $main::in{'charity_gold'} == 0){ main::error("金額を入力してください。"); }
$main::in{'charity_gold'} = int($main::in{'charity_gold'});

# 募金額
if($main::in{'charity_gold'} > $adv->{'gold'}){ main::error("お気持ちはありがたいのですが、お金が足りません！"); }
$renew{'-'}{'gold'} = $main::in{'charity_gold'};
$renew{'+'}{'charity'} = $main::in{'charity_gold'};

# 自分のキャラデータを更新
my($renewed) = &File("Mydata Renew Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

# 募金ランキングを更新
&CharityFile({ TypeRenew => 1 , TypeNewLine => 1 },$renewed);

	# 行動記録
	if(!$adv->{'test_player_flag'}){
		my $NewComment1 = qq($adv->{'chara_link'} が);
		my $NewComment2 = qq(<a href="$init->{'script'}?mode=bank#CHARITY">募金</a> に <span class="goldcolor">$main::in{'charity_gold'}G</span> の協力をしました。);
		&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
	}

# ジャンプ
$main::jump_url = "$init->{'script'}?mode=bank";
$main::jump_sec = 2;

	# メッセージ追加
	if($main::in{'charity_gold'} > 100000){ $message = qq(<br>これで殺されていったモンスターたちも報われることでしょう。); }


my $print = qq(
<h1>銀行</h1>
$init_login->{'link_line'}
<div class="results">
ありがとうございます！<br>
募金として確かに $main::in{'charity_gold'}G をお預かりしました。(<a href="$init->{'script'}?mode=bank">→銀行に戻る</a>)
$message
</div>
$init->{'continue_button'}
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# 募金ファイル
#-----------------------------------------------------------
sub CharityFile{

# 宣言
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($use,$adv) = @_;
my($i,@renew_line,%data,$file_handle1,$renew,$select_renew,$index_line,%renew,$hit,$hit);

# ディレクトリ定義
$data{'directory'} = "$init->{'adv_dir'}_log_adv/";

	# ファイル定義
	if($use->{'FileType'} eq "Old"){
		$data{'file'} = "$data{'directory'}charity_adv.cgi";
	}
	else{
		$data{'file'} = "$data{'directory'}charity_adv.log";
	}

# 最大行を定義
my $max_line = 100;

	# ディレクトリ作成
	if($use->{'TypeRenew'}){
		Mebius::Mkdir(undef,$data{'directory'});
	}

	# ファイルを開く
	if($use->{'FileCheckError'}){
		$data{'f'} = open($file_handle1,"+<$data{'file'}") || main::error("ファイルが存在しません。");
	}
	else{
		$data{'f'} = open($file_handle1,"+<$data{'file'}");

			# ファイルが存在しない場合は新規作成
			if(!$data{'f'}){
					if($use->{'TypeRenew'}){
						Mebius::Fileout("Allow-empty",$data{'file'});
						$data{'f'} = open($file_handle1,"+<$data{'file'}");
					}
					else{
						return(\%data);
					}
			}

	}

	# ファイルロック
	if($use->{'TypeRenew'} || $use->{'Flock'}){ flock($file_handle1,2); }

# トップデータを分解
chomp($data{'top1'} = <$file_handle1>);
($data{'key'}) = split(/<>/,$data{'top1'});

	# 更新用に内容を記憶
	#if($use->{'TypeRenew'}){ %renew = %data; }

	# ファイルを展開
	while(<$file_handle1>){

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($id,$name,$gold) = split(/<>/);

		$hit++;

			# 最大表示行数
			if($use->{'MaxViewIndex'} && $use->{'MaxViewIndex'} ne "All" && $hit > $use->{'MaxViewIndex'}){
				$data{'flow_flag'} = 1;
				next;
			}

			# インデックスを取得
			if($use->{'TypeGetIndex'}){
				$data{'hit_index'}++;
				my($gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$gold]);
				$data{'index_line'} .= qq(<tr><td>$data{'hit_index'}位</td><td>);
					if($use->{'FileType'} eq "Old"){
							$data{'index_line'} .= qq(<a href="$init->{'script'}?mode=chara&amp;chara_id=$id">$name</a>);
					}
					else{
						$data{'index_line'} .= qq(<a href="$init->{'script'}?mode=status&amp;id=$id">$name</a>\n);
					}
				$data{'index_line'} .= qq(</td><td style="text-align:right;">$gold_comma\G</td></tr>\n);
			}

			# 新規募金
			if($id eq $adv->{'id'}){
				next;
			}

			# 更新用
			if($use->{'TypeRenew'}){

					# 最大行数に達した場合
					if($i > $max_line){ next; }

				# 行を追加
				push(@renew_line,"$id<>$name<>$gold<>\n");

			}

	}

	# 新しい行を追加
	if($use->{'TypeNewLine'}){

		# 行を追加
		unshift(@renew_line,"$adv->{'id'}<>$adv->{'name'}<>$adv->{'charity'}<>\n");

		# 募金ランキングを並べ替え
		@renew_line = sort { (split(/<>/,$b))[2] <=> (split(/<>/,$a))[2] } @renew_line;

	}

	# ファイル更新
	if($use->{'TypeRenew'}){

		# 任意の更新
		($renew) = Mebius::Hash::control(\%data,$select_renew);

		# トップデータを追加
		unshift(@renew_line,"$renew->{'key'}<>\n");

		# ファイル更新
		seek($file_handle1,0,0);
		truncate($file_handle1,tell($file_handle1));
		print $file_handle1 @renew_line;

	}


close($file_handle1);

	# パーミッション変更
	if($use->{'TypeRenew'}){
		Mebius::Chmod(undef,$data{'file'});
	}

	# リターン
	if($use->{'TypeRenew'}){
		return($renew);
	}
	else{
		return(\%data);
	}

}


1;
