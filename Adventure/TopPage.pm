
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# メビアド トップページを表示
#-----------------------------------------------------------
sub Top{

# 宣言
my($init) = &Init();
my($init_login) = init_login();
my($charaview);

# チャンプファイルを読み込む
my($champ) = &ChampFile();

	# 現在のチャンピオンを取得
	if($champ->{'id'} eq ""){
		$charaview = qq(現在、チャンピオンはいません。玉座でペリカン大王が遊んでいます。);
	}
	else{
		require Mebius::Adventure::Charactor;
		my($champ) = &File(undef,{ FileType => "Account" , id => $champ->{'id'} });
		($charaview) = &CharaStatus({ TypeChampStatus => 1 },$champ);
	}

require Mebius::Adventure::Record;
my($winner_record_line) = &Record("Index",5);
#<strong>最高記録：</strong> <span class="red">$winner_name ( $winner_count連勝 )</span>

# ランキングを取得
require Mebius::Adventure::Ranking;
my($menber_list) = &RankingFile({ TypeGetIndex => 1 , MaxViewIndex => 10 });

# CSS定義
$main::css_text .= qq(
ul.alert{font-size:85%;color:#f00;margin:1em 0em;padding:1em 2.5em;border:solid 1px #f00;}
);
$main::head_link2 = qq( &gt; メビリン・アドベンチャー );

my $print .= qq(
<h1>$init->{'title'}</h1>
$init_login->{'link_line'}
$init->{'ads1_formated'}
<ul class="alert">
<li>プレイ前に必ず <a href="${main::guide_url}%A5%E1%A5%D3%A5%EA%A5%F3%A1%A6%A5%A2%A5%C9%A5%D9%A5%F3%A5%C1%A5%E3%A1%BC">ゲームの趣旨</a> をご確認ください。</li>
<li>本ゲームではキャラデータ、仕様などについて一切の保証、お約束はいたしかねます。</li>
<li>連続更新、ボタン連打などサーバーに負担をかける行為は禁止です。(あなたのキャラデータが消失する場合があります)</li>
<li>「○○したら（ゲーム上の）お金を盗むよ」などの脅し行為は禁止です。</li>
<li>戦闘結果を日記等に大量コピーする行為はご遠慮ください。</li>
</ul>
);




# 連勝記録のトップを取得する

$print .= qq(
<h2>現在のチャンピオン ( $champ->{'win_count'}連勝中 ) </h2>
$charaview
<h2><a href="$init->{'script'}?mode=record">連勝記録</a></h2>
$winner_record_line
<h2><a href="$init->{'script'}?mode=ranking">メンバー</a></h2>
$menber_list
);

# 連勝記録

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;
