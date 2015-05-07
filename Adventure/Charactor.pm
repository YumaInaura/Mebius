 
use strict;
package Mebius::Adventure;
use Mebius::Export;

#-----------------------------------------------------------
# キャラデータの表示
#-----------------------------------------------------------
sub CharaStatus{

# 局所化
my($use,$adv) = @_;
my($init) = &Init();
my($basic_init) = Mebius::basic_init();
my($parts) = Mebius::Parts::HTML();
my($my_account) = Mebius::my_account();
my($line,$view_url,$select_battle_button,$view_pdmg,$block_line);
my($effect_line);

# マイデータを取得
my($advmy) = &my_data();

# CSS追加
$main::css_text .= qq(
table.charadata{font-size:110%;}
th.charaname{background:#cdf;padding:0.5em 0.7em;text-align:left;font-weight:bold;}
span.charaname{font-size:130%;}
td.status{word-spacing:0.3em;}
td.charadata{padding:0.4em 0.5em;}
td{line-height:1.4;}
.purple{color:purple;}
span.effect{color:#fff;font-weight:bold;background:#5d5;padding:0.3em 0.5em;line-height:1.8;font-size:90%;}
);

	# ファイルが存在しない場合
	if(!$adv->{'f'}){
			if($use->{'TypeChampStatus'}){ return; }
			else{ main::error("このキャラクタ ( $adv->{'id'} ) は存在しません。"); }
	}

	# 瀕死の場合
	if($adv->{'hp'} < $adv->{'maxhp'} * 0.2){
		$main::css_text .= qq(
		table.charadata,table.charadata td,table.charadata th{background:#fee;border-color:#f77;}
		);
	}
	# 瀕死の場合
	elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.5){
		$main::css_text .= qq(
		table.charadata,table.charadata td,table.charadata th{background:#efe;border-color:#070;}
		);
	}

	# アイテム
	if($adv->{'item_damage_plus'} >= 1){ $view_pdmg = qq( + $adv->{'item_damage_plus'} ); }

	# キャラブロック
	if($adv->{'block_time'} >= $main::time){
		my($how_block) = Mebius::SplitTime("",$adv->{'block_time'} - time);
		$block_line = qq(<strong class="red">不適切行為、認証の連続失敗などにより、キャラロック中です。(あと$how_block)</strong>);
	}

$line .= qq($block_line);

	# ▼特殊効果の表示
	if($adv->{'id'} eq $advmy->{'id'} || $my_account->{'admin_flag'}){
		my $effect; 
			my($how_long) = shift_jis(Mebius::second_to_howlong({ GetLevel => "minute" } ,$adv->{'effect_levelup_boost_time'} - time));
			if($adv->{'effect_levelup_boost_time'} >= time){
				$effect .= qq(<span class="effect">レベルアップ$adv->{'effect_levelup_boost'}倍 (あと$how_long)</span>);
			}
			if($effect){ $effect_line = qq(<div class="effect">$effect</div>); }
	}


$line .= qq(<table class="adventure charadata">
<tr>
<th colspan="2" class="charaname">
<span class="charaname">$adv->{'name'}</span>　
レベル： $adv->{'level'}　
職業： $adv->{'jobname'}　
クラス： $adv->{'jobrank'}　
武器： $adv->{'item_name'} ( $adv->{'item_damage'}$view_pdmg )　
性別： $adv->{'sextype'}
</th>
</tr>
);

# カンマを付ける
my($hp_comma,$maxhp_comma,$ex_comma,$next_exp_comma,$gold_comma,$bank_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$adv->{'hp'},$adv->{'maxhp'},$adv->{'exp'},$adv->{'next_exp'},$adv->{'gold'},$adv->{'bank'}]);

$line .= qq(
<tr>
<td class="charadata">状態</td>
<td class="charadata">
<div>
<span class="hpcolor">HP $hp_comma / $maxhp_comma</span>　|　
<span class="goldcolor">所持金 $gold_comma\G</span>
<span class="goldcolor"> ( 預金 $bank_comma\G )</span>　|　
SP $adv->{'sp'}
</div>
<div>
<span class="expcolor">経験値 $ex_comma / $next_exp_comma</span>　|　
戦績 $adv->{'win'}勝 $adv->{'lose'}敗 $adv->{'draw'}分 ( 勝率 $adv->{'winodds'}％ )
</div>
$effect_line
</td>
</tr>
);

$line .= qq(
<tr>
<td class="charadata">ステータス</td>
<td class="status charadata">
力 $adv->{'power'} | 
知力 $adv->{'brain'} | 
信仰心 $adv->{'believe'} | 
生命力 $adv->{'vital'} | 
器用さ $adv->{'tec'} | 
速さ $adv->{'speed'} | 
魅力 $adv->{'charm'} | 
カルマ $adv->{'karman'} |
勇気 $adv->{'brave'}
</td>
</tr>
);

	# 管理者にのみ表示する詳細行
	if($my_account->{'master_flag'}){
		$line .= qq(
		<tr>
		<td class="charadata red">管理者表\示</td>
		<td class="status charadata">
		自動振替 $adv->{'autobank'}％ / 
		通算レベルアップ数 / $adv->{'all_level'}
		必殺技 $adv->{'spatack'} ( 威力$adv->{'spodds'}倍 )
		行動回数 $adv->{'today_action_buffer'}
		Trance-from : $adv->{'trance_from_account'} / Trance-to : $adv->{'trance_to_account'}
		</td>
		</tr>
		);
	}


	# このキャラと戦うボタン
	if($advmy->{'login_flag'} && $adv->{'id'} ne $advmy->{'id'} && !$use->{'TypeNotGetForm'} && $adv->{'formal_player_flag'}){

			if($advmy->{'test_player_flag'}){
				$select_battle_button .= qq(
				<input type="submit" value="このキャラと戦う" class="battle"$parts->{'disabled'}>
				<span class="alert">※テストプレイ中はキャラクターとは戦えません。</span>
				);
			}
			elsif($main::time > $adv->{'lasttime'}+$init->{'charaon_day'}*24*60*60){
				$select_battle_button .= qq(
				<input type="submit" value="このキャラと戦う" class="battle"$parts->{'disabled'}>
				<span class="alert">※しばらくログインしていない相手とは戦えません。</span>
				);
				}
			#elsif($advmy->{'maxhp'} < $adv->{'maxhp'}*$init->{'select_battle_gyap'}){
			#	$select_battle_button .= qq(
			#	<input type="submit" value="このキャラと戦う" class="battle"$parts->{'disabled'}>
			#	<span class="alert">※実力差がありすぎる相手とは戦えません。</span>
			#	);
			#}
			else{
				$select_battle_button .= qq(
				<form action="$init->{'script'}" method="post" class="nomargin inline"$main::sikibetu>
				<div class="inline">
				<input type="hidden" name="mode" value="battle">
				<input type="hidden" name="id" value="$advmy->{'id'}">
				<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
				<input type="hidden" name="char" value="$advmy->{'char'}">
				<input type="hidden" name="target_id" value="$adv->{'id'}">
				<input type="hidden" name="target_file_type" value="$adv->{'input_file_type'}">
				<input type="submit" value="このキャラと戦う" class="battle">
				</div>
				</form>
				);

			}
	}



# コメントなど
my($view_url) = Mebius::auto_link($adv->{'url'});

$line .= qq(<tr><td class="charadata">データ</td><td class="charadata">);
#$line .= qq($adv->{'comment'});
#$line .= qq($view_url);

	# アカウントへのリンク
	if($adv->{'formal_player_flag'}){
			#  │ 
			$line .= qq(SNSアカウント ： <a href="$basic_init->{'auth_url'}$adv->{'id'}">\@$adv->{'id'}</a>\n);
	}
$line .= qq(</td></tr>);

	# 自分のステータスでなければ
	if($advmy->{'login_flag'} && !$use->{'TypeNotGetForm'}){

		$line .= qq(<tr><td>アクション</td><td>);

		# 戦闘ボタン
		$line .= qq($select_battle_button);

		# 特殊行動ボタン
		require Mebius::Adventure::Special;
		my($special) = &SpecialJudge(undef,$advmy,$adv);
			if($special->{'justy_flag'}){ 
					$line .= qq( $special->{'form'});
			}
			else{
					$line .= qq( $special->{'form'} $special->{'error_flag'});
			}

		$line .= qq(</td></tr>);
	}


$line .= qq(</table>);



return($line)

}

#-----------------------------------------------------------
# キャラ表示ページ
#-----------------------------------------------------------
sub CharaView{

# 局所化
my($type,$id) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # 処理タイプを展開
my($init) = &Init();
my($init_login) = init_login();
my($hit,$ltime,$vtime,$mtime,$editform);
my($status_line,$adv,$not_submit_flag,$print);
our($advmy);

	# ステータス表示部分を取得

	# ●旧キャラファイル ( 記述は削除しない - 過去のステータスを閲覧できるよう、ずっと残す )
	if($type{'Old-file'}){

			# 古いURLをリダイレクト
			if($main::in{'id'}){
				Mebius::Redirect(undef,"$init->{'base_url'}?mode=chara&chara_id=$main::in{'id'}",301);
			}

		($adv) = &File("",{ FileType => "OldId" , id => $id , "Old-file" => 1 });
		($status_line) = &CharaStatus({ FileType => "OldId" },$adv);
	}

	# ●アカウントファイル
	else{
		($adv) = &File("",{ FileType => "Account" , id => $id });
		($status_line) = &CharaStatus(undef,$adv);
	}

	# 設定フォームを取得
	if($main::myaccount{'master_flag'}){
		($editform) = &CharaForm(undef,$adv); 
		$editform = qq(<h2>設定変更(管理者権限)</h2>$editform);
	}

# タイトル定義
$main::sub_title = "$adv->{'name'} | $main::title";


# HTML
$print .= <<"EOM";
<h1>$adv->{'name'} \@$adv->{'id'}</h1>
$init_login->{'link_line'}
EOM

# 広告フィルタ
my($fillter_flag) = Mebius::Fillter::Ads({ Encode => "shit_jis" },$adv->{'name'},$adv->{'comment'});

	# 広告表示
	if(!$fillter_flag){
		$print .= qq($init->{'ads1_formated'});
	}

my($tweet_button) = Mebius::Gaget::tweet_button();

# ＨＴＭＬを表示
$print .= qq(
<div><h2 class="inline">ステータス</h2>　 $tweet_button</div>
$status_line
$editform
);

# フッタ
Mebius::Template::gzip_and_print_all({ BCL => [{ url => "?mode=ranking" , title => " ランキング" },$adv->{'name'}] },$print);


exit;

}



#-----------------------------------------------------------
# パラメータ表示、設定変更フォーム
#-----------------------------------------------------------
sub CharaForm{

my($type,$adv) = @_;
my($init) = &Init();
my($line);
my($my_account) = Mebius::my_account();

$line .= qq(
<form action="$init->{'script'}" method="post" style="margin:0em;"$main::sikibetu>
<div>
<table class="adventure">);

	if($my_account->{'admin_flag'}){
		$line .= qq(
		<tr>
		<td>キャラ名</td>
		<td><input type="text" name="name" value="$adv->{'name'}" size="50" maxlength="50"></td>
		</tr>
		);
	}

$line .= qq(
<tr>
<td>必殺の雄たけび</td>
<td><input type="text" name="advwaza" value="$adv->{'waza'}" size="50" maxlength="50"></td>
</tr>
);

$line .= qq(
<tr>
<td>コメント</td>
<td><input type="text" name="advcomment" value="$adv->{'comment'}" size="50" maxlength="50"> <span class="alert">※コメント機能\が荒れ気味のため、現在、反映を停止中です。</span></td>
</tr>
);

$line .= qq(
<tr>
<td>ＵＲＬ（メビウスリング内）</td>
<td><input type="text" name="advurl" value="$adv->{'url'}" size="50" maxlength="50"> <span class="alert">※現在、反映を停止中です。</span></td>
</tr>
);


	# 管理者設定
	if($main::myaccount{'master_flag'} && $main::mode eq "chara" || $main::mode eq "status"){ 
		my $example_block_time = time + (7*24*60*60);
		$line .= qq(
		<tr>
		<td>ゴールド</td>
		<td><input type="text" name="advgold" value="$adv->{'gold'}"></td>
		</tr>
		<tr>
		<td>預金</td>
		<td><input type="text" name="advbank" value="$adv->{'bank'}"></td>
		</tr>
		<tr>
		<td>経験値</td>
		<td><input type="text" name="advex" value="$adv->{'exp'}"></td>
		</tr>
		<td>ブロック</td>
		<td><input type="text" name="block_time" value="$adv->{'block_time'}"> 例： $example_block_time</td>
		</tr>
		);
	}



$line .= qq(</table>);


$line .= qq(
<input type="submit" value="この内容で設定変更する">
<br><br>
<span class="alert">※「挑発」「悪口」など不適切な内容を登録しないでください。
違反には「登録削除」「投稿制限」などをさせていただく場合があります(<a href="${main::guide_url}">ガイド</a>)。
</span>
<input type="hidden" name="mode" value="edit">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
<input type="hidden" name="char" value="$adv->{'char'}">
</div>
</form>
);

return($line);

}


1;
