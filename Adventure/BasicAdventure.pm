
use strict;
use Mebius::Text;
package Mebius::Adventure;

#-----------------------------------------------------------
# 処理スタート
#-----------------------------------------------------------
sub start_adv{

# このパッケージの全変数をリセット
reset 'a-z';

# 変数のリセット
our($advmy) = (undef);

# 設定取り込み
my($init) = &Init();

	# メンテ中の場合
	if($init->{'mente_mode'} && !$main::myaccount{'master_flag'}) { main::error("現在メンテナンス中です。しばらくお待ちください。",503); }

# CSS
push(@main::css_files,"adventure");

# モジュール読み込み
require Mebius::Adventure::Item;
require Mebius::Adventure::Data;
require Mebius::Adventure::Situation;
require Mebius::Adventure::NewCharactor;

# タイトル定義
$main::sub_title = $init->{'title'};
$main::head_link2 = qq( &gt; <a href="$init->{'script'}">$init->{'title'}</a>);

# 自データを読み込み
($advmy) = &my_data();

	# 数字確認画面を出す場合
	if($advmy->{'strange_flag'}){

		require Mebius::Adventure::BreakChar;
		&BreakCharView(undef,$advmy->{'break_char'},$advmy->{'break_missed'});
	}

# エラー時の追加表示部
$main::fook_error = qq($init->{'continue_button'});

#<a href="$init->{'script'}?mode=monster_list">モンスター</a> / 

	# モード振り分け
	if($main::mode eq 'log_in') { require Mebius::Adventure::Login; &Login(); }
	elsif($main::mode eq 'chara_make') { require Mebius::Adventure::NewForm; &NewForm(); }
	elsif($main::mode eq 'make_end') { require Mebius::Adventure::NewForm; &NewCharaMake(); }
	elsif($main::mode eq 'regist') { require Mebius::Adventure::Data; &do_regist(); }
	elsif($main::mode eq 'battle') { require Mebius::Adventure::Battle; &Battle(); }
	elsif($main::mode eq 'jobchange') { require Mebius::Adventure::Job; &JobChange(); }
	elsif($main::mode eq 'joblist') { require Mebius::Adventure::Job; &ViewJob(); }
	elsif($main::mode eq 'bank') { require Mebius::Adventure::Bank; &Bank(); }
	elsif($main::mode eq 'room') { require Mebius::Adventure::Room; &Room(); }
	elsif($main::mode eq 'monster') { require Mebius::Adventure::Battle; &Battle(); }
	elsif($main::mode eq 'ranking') { require Mebius::Adventure::Ranking; &ViewRanking(); }
	elsif($main::mode eq 'yado') { require Mebius::Adventure::Yado; &Yado(); }
	elsif($main::mode eq 'trance') { require Mebius::Adventure::Trance; &Trance(); }
	elsif($main::mode eq 'item_shop') { require Mebius::Adventure::Item; &ViewItem(); }
	elsif($main::mode eq 'special') { require Mebius::Adventure::Special; &SpecialAction(); }
	elsif($main::mode eq 'item_buy') { require Mebius::Adventure::Item; &BuyWepon(); }
	elsif($main::mode eq 'edit') { require Mebius::Adventure::Edit; &EditStatus(); }
	elsif($main::mode eq 'log') { require Mebius::Adventure::Situation; &ViewSituation(); }
	elsif($main::mode eq 'chara') { require Mebius::Adventure::Charactor; &CharaView("Old-file",$main::in{'chara_id'}); }
	elsif($main::mode eq 'status') { require Mebius::Adventure::Charactor; &CharaView(undef,$main::in{'id'}); }
	elsif($main::mode eq 'record') { require Mebius::Adventure::Record; &ViewRecord(); }
	elsif($main::mode eq "") { require Mebius::Adventure::TopPage; &Top(); }
	else{ main::error("このページは存在しません。"); }

}

#-----------------------------------------------------------
# 自分のファイルを開く
#-----------------------------------------------------------
sub my_data{

# 宣言
my($use) = @_;
my($advmy);

# Near State （呼び出し）
my $StateName1 = "my_data";
my $StateKey1 = "Normal";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

# デバイスを取得
my($real_device) = Mebius::my_real_device();

	# アカウントデータを使う
	if($main::myaccount{'file'}){
		($advmy) = &File("Base-mydata Allow-empty-id",{ FileType => "Account" , id => $main::myaccount{'file'} , my_id => $main::myaccount{'file'} });
	}

	# Cookieでテストプレイ
	if(!$advmy->{'login_flag'} && $main::cnumber){
		my($use_id) = Mebius::my_hashed_cookie_char();
		($advmy) = &File("Base-mydata Allow-empty-id",{ FileType => "Cookie" , id => $use_id , my_id => $use_id });

			# データがない場合は新規作成
			if(!$advmy->{'f'} && !$real_device->{'bot_flag'}){
					($advmy) = &NewCharacterMake(undef,{ FileType => "Cookie" , id => $use_id });
			}

	}

	# Near State （保存）
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,$advmy); }

return($advmy);

}

#-----------------------------------------------------------
# チャンピオンファイル
#-----------------------------------------------------------
sub ChampFile{

# 宣言
my($init) = &Init();
my($use,$select_renew,$adv) = @_;
my($i,@renew_line,%data,$file_handle1,%renew,$renew);

	# ファイル定義
	if(Mebius::alocal_judge()){
		$data{'file1'} = "$init->{'adv_dir'}_log_adv/winner_alocal.log";
	}
	else{
		$data{'file1'} = "$init->{'adv_dir'}_log_adv/winner.log";
	}

	# ファイルを開く
	if($use->{'FileCheckError'}){
		$data{'f'} = open($file_handle1,"+<$data{'file1'}") || main::error("ファイルが存在しません。");
	}
	else{

		$data{'f'} = open($file_handle1,"+<$data{'file1'}");

			# ファイルが存在しない場合
			if(!$data{'f'}){
					# 新規作成
					if($use->{'TypeRenew'}){
						Mebius::Mkdir(undef,$data{'directory1'});
						Mebius::Fileout("Allow-empty",$data{'file1'});
						$data{'f'} = open($file_handle1,"+<$data{'file1'}");
					}
					else{
						return(\%data);
					}
			}

	}

	# ファイルロック
	if($use->{'TypeRenew'} || $use->{'TypeRenew'}){ flock($file_handle1,2); }

	# トップデータを分解
	for(1..1){
		chomp($data{"top$_"} = <$file_handle1>);
	}

# トップデータを分解
($data{'id'},$data{'name'},$data{'win_count'},$data{'hp'}) = split(/<>/,$data{'top1'});

	# 更新用に内容を記憶
	if($use->{'TypeRenew'}){ %renew = %data; }

	# ファイル更新
	if($use->{'TypeRenew'}){

			# 任意の更新とリファレンス化
			($renew) = Mebius::Hash::control(\%renew,$select_renew);

		# トップデータを追加
		unshift(@renew_line,"$renew->{'id'}<>$renew->{'name'}<>$renew->{'win_count'}<>$renew->{'hp'}<>\n");

		# ファイル更新
		seek($file_handle1,0,0);
		truncate($file_handle1,tell($file_handle1));
		print $file_handle1 @renew_line;

	}

close($file_handle1);

	# パーミッション変更
	if($use->{'TypeRenew'}){
		Mebius::Chmod(undef,$data{'file1'});
	}

	# ハッシュ調整
	if($data{'id'} && $adv->{'id'} eq $data{'id'}){
		$data{'mychamp_flag'} = 1;
	}

	# リターン
	if($use->{'TypeRenew'}){
		return($renew);
	}
	else{
		return(\%data);
	}

}



#-----------------------------------------------------------
# 設定の取り込み
#-----------------------------------------------------------
sub Init{

# 宣言
my($use) = @_;
my(%init);

# Near State ( 呼び出し )
my $StateName1 = "Init";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# サーバーURLを取得
my($server_url) = Mebius::server_url();

	# 絶対URLを取得
	if(Mebius::alocal_judge()){ $init{'base_url'} = "${server_url}/cgi-bin/ff.cgi"; }
	else{ $init{'base_url'} = "${server_url}/gap/ff/ff.cgi"; }

# デバイス情報を取得
my($use_device) = Mebius::my_use_device();

# メイン広告 … Amazonのガジェットを予定
$init{'ads1'} = "";

$init{'ads1_empty'} = qq(<div style="border:solid 1px #000;width:728px;height:90px;"></div>);

# メインスクリプト名
$init{'script'} = "./ff.cgi";

# メンテモード
$init{'mente_mode'} = 0;

#<a href="http://aurasoul.mb2.jp/_qst/2586.html">質問運営</a> /

# タイトル
$main::title = $init{'title'} = 'メビリン・アドベンチャー' ;

# レベルアップまでの経験値の設定
# レベル×値($lv_up)＝次のレベルまでの経験値
$init{'lv_up'} = 1000;

# 特殊行動、選択戦闘などを有効にするログイン日数
$init{'charaon_day'} = 7;

# 選択戦闘が出来る最大HP差 ( 自分より最大HPが ～倍低い相手まで戦える )
$init{'select_battle_gyap'} = 1.5;
$init{'special_battle_gyap'} = 2;

# キャラクターを非表示にするまでの期間(日)
$init{'reset_limit'} = 7;

# アイテムを引き継ぐのにかかるお金 ( レベル x G )
$init{'itemguard_gold'} = 1000;

# 連続でモンスターと闘える回数
$init{'sentou_limit'} = 30;

# 基礎HP
$init{'kiso_hp'} = 20;

# 基礎経験値(ここで設定した数×相手のレベル)
$init{'kiso_exp'} = 18;

# ゲーム速度
$init{'game_speed'} = 2;

# 連続行動禁止
$init{'redun'} = 30*$init{'game_speed'};

# 基礎能力値(変更不可)
$init{'status'} = ["power","brain","believe","vital","tec","speed","charm"];
$init{'status_name'} = { power => "力" , brain => "知力" , believe => "信仰心" , vital => "生命力" , tec => "器用さ" , speed => "速さ" , charm => "魅力" };
#$init{'status_name_array'} = ['力','知力','信仰心','生命力','器用さ','速さ','魅力'];

$init{'kiso_status'} = 8;
$init{'kiso_sp'} = 15;

my($init_directory) = Mebius::BaseInitDirectory();
$init{'adv_dir'} = "${init_directory}_adventure/";

	# アローカル設定 
	if(Mebius::alocal_judge()){
		$init{'redun'} = 4;
		$init{'lv_up'} = 20;
		$init{'kiso_status'} = 20;
		$init{'ads1'} = $init{'ads1_empty'};
		$init{'ads_link_unit1'} = $init{'ads1_empty'};
	}
	elsif($main::myadmin_flag >= 5){
		$init{'redun'}  = 5;
		$init{'ads1'} = $init{'ads1_empty'};
		$init{'ads_link_unit1'} = $init{'ads1_empty'};
	}

# 広告整形 => 同サブルーチンの別の位置に置きたい
$init{'ads1_formated'} = qq(<div class="adventure_ads1"><hr>$init{'ads1'}<hr></div>);
#$init{'ads1_formated'} = qq(<div class="adventure_ads1">$init{'ads_link_unit1'}</div>);

# リダイレクト用のログイン先ＵＲＬ
$init{'login_url'} = "$init{'script'}?mode=log_in";

$init{'continue_button'} = qq(<div style="margin:1em 0em;background:#ff9;border:solid 1px #f00;font-size:120%;" class="padding"><a href="$init{'login_url'}">→ゲームを続ける（マイキャラクター画面へ）</a></div>);

# ◯～行動ごとに、確認画面を出す
$init{'break_interval'} = 60*5;

	# ローカル設定
	if(Mebius::alocal_judge() && 1 == 0){ 
		$init{'break_interval'} = 1;
	}

	# ログインしてない時、ログインを促すリンク
	my($request_url) = Mebius::request_url({ TypeEncode => 1 });
	$init{'please_login_text'} = qq(ゲームをするには<a href="${main::auth_url}?backurl=$request_url">ログイン (または新規登録)</a>してください。);

# カンマの区切り方法
$init{'comma_language'} = "Japanese";

	# Near State （保存）
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,\%init); }

return(\%init);


}

#-----------------------------------------------------------
# 設定の取り込み (ログイン判定あり)
#-----------------------------------------------------------
sub init_login{

# 宣言
my($init) = &Init();
my(%init_login);

# Near State （呼び出し）
my $StateName1 = "lnit_login";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# ログインデータを取得
my($advmy) = &my_data();

	# 管理者用の表示
	if($init->{'mente_mode'}){
		$init_login{'link_line'} .= qq(<div class="message-red">);
		$init_login{'link_line'} .= qq(ただいまメンテナンス中です。恐れ入りますが終了までお待ちください。);
		$init_login{'link_line'} .= qq(</div>);
	}

	# メンテ中の表示

# 共通リンク
$init_login{'link_line'} .= qq(<div class="link_line">);

# ナビ
my @navigation = ("=>ゲームＴＯＰ","log_in=>マイキャラ","RequestURL=>更新","ranking=>ランキング","log=>戦況","item_shop=>アイテム","joblist=>職業","bank=>銀行","room=>市役所","chara_make=>新規登録");

#,"trance=>旧データ引継ぎ"

	# 展開
	foreach(@navigation){
		my($value,$text) = split(/=>/,$_);
		my($mode_href);
	
			# 更新ボタン
			if($value eq "RequestURL"){
					if(!$advmy->{'login_flag'}){ next; }
					if($ENV{'REQUEST_METHOD'} eq "GET"){
						my($request_url) = Mebius::request_url({ TypeEscape => 1});
						$init_login{'link_line'} .= qq(<a href="$request_url" class="green">$text</a> / );
					}
					else{
						$init_login{'link_line'} .= qq($text / );
					}
				next;
			}

			# ローカル用
			if($value eq "chara_make"){
				if(!Mebius::alocal_judge()){ next; }
			}

			# 普通のリンク
			if($value){ $mode_href = "?mode=$value"; }
			if($main::in{'mode'} eq $value){ $init_login{'link_line'} .= qq($text / ); }
			else{ $init_login{'link_line'} .= qq(<a href="$init->{'script'}$mode_href">$text</a> / ); }
	}

$init_login{'link_line'} .= qq(
<a href="http://aurasoul.mb2.jp/wiki/ring/%A5%E1%A5%D3%A5%EA%A5%F3%A5%A2%A5%C9%A5%D9%A5%F3%A5%C1%A5%E3%A1%BC">Wiki</a> / 
<a href="${main::guide_url}%A5%E1%A5%D3%A5%EA%A5%F3%A1%A6%A5%A2%A5%C9%A5%D9%A5%F3%A5%C1%A5%E3%A1%BC" class="red">ゲームの趣旨</a>
</div>
);

	# テストプレイ中
	if($advmy->{'test_player_flag'}){

			# メビリンアカウントを持っている場合
			if($main::myaccount{'file'}){
				$init_login{'link_line'} .= qq(<div class="message-purple">このまま <a href="$init->{'script'}?mode=log_in">テストプレイ</a> 出来ます。正式にプレイする場合は、<a href="$init->{'script'}?mode=chara_make">キャラクターを新規作成</a>してください。</div>);
			}

			# メビリンアカウントを持っていない場合
			else{
				#my($request_url) = Mebius::request_url({ TypeEncode => 1 });
				my($backurl_encoded) = Mebius::Encode(undef,"$init->{'base_url'}?mode=chara_make");
				$init_login{'link_line'} .= qq(<div class="message-purple">);
				$init_login{'link_line'} .= qq(このまま <a href="$init->{'script'}?mode=log_in">テストプレイ</a> 出来ます。正式にプレイする場合は、メビリンアカウントに<a href="${main::auth_url}?backurl=$backurl_encoded">ログイン</a>);
				$init_login{'link_line'} .= qq(（または<a href="${main::auth_url}?&amp;mode=aview-newform&amp;backurl=$backurl_encoded">新規登録</a>）してください。);
				$init_login{'link_line'} .= qq(</div>);
		}

	}

	# Cookieが存在しない場合
	if(!$ENV{'HTTP_COOKIE'}){
		$init_login{'link_line'} .= qq(<div class="message-purple">Cookieを有効にする、もしくはいちど画面を更新することでテストプレイできます。</div>);
	}
# Cookieをゲット
my($cookie) = Mebius::get_cookie("MEBI_ADV");
my($cookie_id) = @$cookie;

	if($cookie_id && !$advmy->{'trance_from_time'}){
		$init_login{'link_line'} .= qq(<div class="message-yellow">);
		$init_login{'link_line'} .= qq(お知らせ： ログイン方法が変わりました。旧IDをお持ちの方は、お手数ですが<a href="$init->{'script'}?mode=trance">データの引き継ぎ</a>をおこなってください。);
		$init_login{'link_line'} .= qq(</div>);
	}

	# 
	#if($advmy->{'login_flag'} && $advmy->{'formal_player_flag'}){
	#	$init_login{'link_line'} .= qq(<div class="message-red">);
	#	$init_login{'link_line'} .= qq(お知らせ … 一定のタイミングで広告先に移動してしまうという <a href="http://aurasoul.mb2.jp/_qst/2723.html-177#a">未確認の不具合</a> が報告されています。もし同様の問題が起こる場合は <a href="http://aurasoul.mb2.jp/_main/mailform.html">メールフォーム</a>よりお知らせいただければ幸いです。);
	#	$init_login{'link_line'} .= qq(</div>);
	#}

	# 残り秒数表示
	if($advmy->{'login_flag'}){
		my($head_javascript,$view_jsredirect) = &get_jsredirect(undef,$advmy->{'waitsec'});
			$init_login{'link_line'} .= qq($view_jsredirect);
				if($head_javascript){ $main::head_javascript .= qq($head_javascript); }
	}

	# Near State （保存）
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,\%init_login); }

return(\%init_login);

}

#-----------------------------------------------------------
# 基本設定 ( グローバル変数 )
#-----------------------------------------------------------
sub init_start_adv{

# 元スクリプトへのリンク
$main::original_maker = qq(<a href="http://webooo.csidenet.com/asvyweb/">配布元：FFADV推奨委員会</a>┃<a href="http://aurasoul.mb2.jp/">Edit-メビウスリング</a>);

}

#-----------------------------------------------------------
# Javascript の残り時間表示、リダイレクト
#-----------------------------------------------------------
sub get_jsredirect{

# 宣言
my($use,$second) = @_;
my($init) = &Init();
my($line,$form);

	# リターン
	if($ENV{'REQUEST_METHOD'} eq "POST" && !$use->{'TypeAllowPost'}){ return(); }

# 表示秒数を少しだけ遅らせる
my $javascript_second = $second + 1;

# 自動更新
$line = qq(
<script type="text/javascript">
<!--
var start=new Date();
start=Date.parse(start)/1000;
var counts=$javascript_second;

	function CountDown(){
		var now=new Date();
		now=Date.parse(now)/1000;
		var x=parseInt(counts-(now-start),10);
			if(document.form1){ document.form1.clock.value = x; }
			if(x>0){
				timerID=setTimeout("CountDown()", 100)
			}
			else{
				display('none','left_charge_adv');
				display('inline','charge_finished_adv');
				display('enable','monster_battle','champ_battle','special_action');
				display('background','tranceparent','monster_battle','champ_battle','special_action');
			}
	}

window.setTimeout('CountDown()',100);
-->
</script>
);

#push(@main::javascript_files,"adventure");

	my $continue_text;
	if($main::in{'mode'} eq "log_in"){ $continue_text = qq(─コマンド？); }
	else{ $continue_text = qq(<a href="$init->{'login_url'}">─コマンド？</a>); }

	# チャージ時間がない場合
	if($second <= 0){
		$form = qq(
		<form name="form1" class="adv_clock">
		<span>
		チャージは終了しています。　 $continue_text
		</span>
		</form>
		);

	}

	# チャージ時間がある場合
	else{
		$form = qq(
		<form name="form1" class="adv_clock">
		<span id="left_charge_adv">
		チャージは 残り<input type="text" name="clock" value="$second" class="adv_clock">秒です。
		</span>
		<span id="charge_finished_adv" class="display-none">
		チャージは終了しています。　 $continue_text
		</span>
		</form>
		);

		# JAvascript用のタグエスケープ
		$form =~ s/\n//g;
		$form =~ s!/!\\/!g;

		$form = qq(
		<script type="text/javascript">
		<!--
		document.write('$form');
		-->
		</script>
		);

		$form .= qq(<noscript>チャージは 残り$second秒です。 時間が終わったら、画面を更新してください。</noscript>);

	}

return($line,$form);


}


1;
