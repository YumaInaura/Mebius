
# パッケージ宣言
package Mebius::Goldcenter;
use strict;
use warnings;

# -------------------------------------------
# 基本設定
# -------------------------------------------
sub init_start_gold{

# 全変数をリセット
reset 'a-z';

# メイン設定
$main::head_link1 = 0;
$main::head_link1 = qq(&gt; <a href="$main::base_url">メビウスリング</a> );

# タイトル設定
$main::sub_title = qq(金貨センター);

# CSS定義
$main::css_text .= qq(
h2{background:#ffc;border:solid 1px #cc0;padding:0.35em 0.7em;font-size:100%;}
h3{font-size:100%;}
);

# 検索ボックスで自分を検索しない
$main::nosearch_mode = 1;

# ローカル設定
if($main::alocal_mode){
$main::ip_dir = "./ip/";
$main::bkup_dir = "./_backup_home/";
}


}

#-----------------------------------------------------------
# パッケージの基本設定
#-----------------------------------------------------------
sub init{

# 設定
my $script_mode = "";	# "TEST" でテストモード
my $gold_url = "/_gold/";	# 金貨センターのURL
my $title = "金貨センター";	# タイトル

# テストモードの制限
if($main::myadmin_flag < 5 && !$main::alocal_mode){ $script_mode = undef; }

# リターン
return($script_mode,$gold_url,$title);

}

#-----------------------------------------------------------
# 必要な金貨量の設定
#-----------------------------------------------------------
sub get_price{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my(%price);

# 各サービスに必要な金貨を定義
%price = (
"cancel_newwait" => 100, # 新規待ち時間をなくす
);

# リターン
return(%price);

}


#-------------------------------------------------
# スタート - スクリプト
#-------------------------------------------------
sub start_gold{

# 宣言
my($script_mode,$gold_url,$title) = &init();

# モード振り分け
if($main::mode eq ""){ &index(); }
elsif($main::mode eq "cancel_newwait"){ &cancel_newwait(); }
else{ &main::error("ページが存在しません。"); }

exit;

}

#-----------------------------------------------------------
# インデックス
#-----------------------------------------------------------
sub index{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($line_guide,$line_cancel_newwait,$line_record_spend);

# CSS定義
$main::css_text .= qq(
div.guide{line-height:1.4;}
);

# タイトル定義
$main::head_link2 = qq(&gt; $title);

# 説明
$line_guide = qq(<li>アカウントにログインしていたり、一部の携帯電話では、金貨センターが利用できます。</li>);
	if($main::callsave_flag){ $line_guide .= qq(<li>いまのあなたは、金貨センターを<strong class="red">利用できます。</strong></li>); }
	else{ $line_guide .= qq(<li>いまのあなたは、金貨センターを<strong class="red">利用できません。</strong><a href="$main::auth_url?backurl=http://$main::server_domain$gold_url">アカウント</a>にログイン(または新規登録)してください。</li>); }
	if($main::callsave_flag){
$line_guide .= qq(<li>金貨はサーバーごとに記録されます。いまのサーバーは <a href="http://$main::server_domain/">$main::server_domain</a> です。</li>);
	}
$line_guide .= qq(<li class="red">注意！　サイト内でのルール違反があった場合（文字数稼ぎ、文字の羅列など）、<strong>「金貨の消失」「投稿制限」などのペナルティを加えさせていただく場合があります。</strong></li>);

# 説明の整形
$line_guide = qq(
<h2>説明</h2>
<div class="guide">
<ul>$line_guide</ul>
</div>
);


# 新規待ち時間をなくすフォーム
($line_cancel_newwait) = &form_cancel_newwait();

# 金貨の使用記録をゲット
	if($main::in{'viewall'}){ ($line_record_spend) = &record_spend("VIEW",""); }
	else{ ($line_record_spend) = &record_spend("VIEW","",5); }

# ヘッダ
&main::header();

# HTML
print qq(
<div class="body1">
<h1>$title</h1>
あなたの金貨 : 現在 <strong class="red">$main::cgold枚</strong> <img src="/pct/icon/gold1.gif" alt="金貨"> ( <a href="http://$main::server_domain/">$main::server_domain</a> )
$line_guide
<h2>金貨を使う</h2>
$line_cancel_newwait
$line_record_spend
<h2>金貨ランキング</h2>
<a href="${main::main_url}rankgold-p-1.html">→金貨ランキングはこちらです。</a>
</div>
);

# フッタ
&main::footer();

exit;

}

#-----------------------------------------------------------
# 新規投稿の待ち時間をなくすフォーム
#-----------------------------------------------------------
sub form_cancel_newwait{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($line,$newwait_flag,$newwait_hour,$disabled,$alert);

# 新規投稿の待ち時間を取得
($newwait_flag,$newwait_hour) = &main::sum_newwait();

# HTML部分を定義
$line .= qq(
<h3>新規投稿の待ち時間をなくす</h3>
<form action="./" method="post">
<div>
<ul>
<li>必要な金貨: $price{'cancel_newwait'}枚 / $main::cgold 枚</li>
<li>現在の待ち時間： $newwait_hour</li>
</ul><br$main::xclose>
<input type="hidden" name="mode" value="cancel_newwait">);

	# 実行できない環境の場合
	if(!$main::callsave_flag){ $alert = qq(※この環境では実行できません。); }
	# 新規待ち時間がない場合
	elsif($main::cgold < $price{'cancel_newwait'}){ $alert = qq(※金貨が足りません。); }
	# 金貨が足りない場合
	elsif(!$newwait_flag){ $alert = qq(※待ち時間がありません。); }
	#アラート分の整形
	if($alert && $script_mode !~ /TEST/){ $alert = qq(<span class="alert">$alert</span>); $disabled = $main::disabled; }

# 整形
$line .= qq(
<input type="submit" value="実行する"$disabled>
$alert
</div>
</form>
);

# リターン
return($line);

}

#-----------------------------------------------------------
# 新規投稿の待ち時間をなくす
#-----------------------------------------------------------
sub cancel_newwait{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($successed);

# 金貨枚数をチェック
&cash_check("","$price{cancel_newwait}");

# 新規投稿の待ち時間をなくす 
($successed) = &main::sum_newwait("UNLINK");

# 成功した場合、金貨を減して、Cookieをセットする
if($successed == 1 ||  $script_mode =~ /TEST/){
$main::cnew_time = undef;
$main::cgold -= $price{cancel_newwait};
&main::set_cookie();
&record_spend("RENEW","新規待ち時間を減らしました。");
}

# 失敗した場合、エラーを表示する
else{
&main::error("新規投稿の待ち時間がありません。");
}

# ページジャンプ
&Mebius::Jump("","$gold_url","1","新規投稿の待ち時間を減らしました。");

# 終了
exit;

}



#-----------------------------------------------------------
# 金貨の使用記録を 更新 / 表示
#-----------------------------------------------------------
sub record_spend{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my($type,$message,$maxview_line) = @_;
my(@line,$file,$viewline,$i,$newhandle);
my($maxline) = (100);

# ファイルを定義
$file = "${main::bkup_dir}gold_spend.log";

# 記録する筆名
	if($type =~ /RENEW/){
$newhandle = $main::chandle;
		if($main::pmname){ $newhandle = $main::pmname; }
		if($newhandle eq ""){ $newhandle = qq(名無し); }
	}

# 追加する行
	if($type =~ /RENEW/){
push(@line,"1<>$newhandle<>$message<>$main::pmfile<>$main::host<>$main::agent<>$main::date<>$main::time<>\n");
	}

# ファイルを開く
open(GOLD_RECORD_IN,"< $file");
	#if($type =~ /RENEW/){ flock(GOLD_RECORD_IN,1); }
while(<GOLD_RECORD_IN>){
chomp;
my($key2,$handle2,$message2,$account2,$host2,$agent2,$date2,$time2) = split(/<>/);
$i++;
	if($i > $maxline){ next; }
	if($type =~ /RENEW/){ push(@line,"$_\n"); }
	if($type =~ /VIEW/ && ($i <= $maxview_line || !$maxview_line)){
		if($account2){ $handle2 = qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>); }
	$viewline .= qq(<li>$handle2 さんが $message2 ( $date2 )</li>\n);
	}
}
close(GOLD_RECORD_IN);

# 閲覧のみの場合、リターン
	if($type =~ /VIEW/){
		if($viewline){ $viewline = qq(<h2>金貨の使用記録</h2>\n<ul>$viewline</ul>); }
return($viewline);
	}

# ファイルを更新する
	if($type =~ /RENEW/){
open(GOLD_RECORD_OUT,"+> $file");
flock(GOLD_RECORD_OUT,2);
truncate(GOLD_RECORD_OUT,0);
seek(GOLD_RECORD_OUT,0,0);
print GOLD_RECORD_OUT @line;
close(GOLD_RECORD_OUT);
chmod($main::logpms,$file);
	}

# リターン
return();

}

#-----------------------------------------------------------
# 金貨を計算
#-----------------------------------------------------------
sub cash_check{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my($type,$price) = @_;

# アローカル
if($script_mode =~ /TEST/){ return; }

# エラー
if(!$main::callsave_flag){ &main::error("この環境では実行できません。アカウントにログインしてください。"); }

# 値段の計算
if($main::cgold < $price){ &main::error("金貨が足りないため、実行できません。 $main::cgold枚 / $price枚"); }

# リターン
return();

}

1;

