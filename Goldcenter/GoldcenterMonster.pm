
# パッケージ宣言
package Mebius::Goldcenter;
use strict;

#-----------------------------------------------------------
# モンスターファイト
#-----------------------------------------------------------
sub monster{

# 設定
$main::head_link3 = qq( &gt; モンスターファイト);

# モード振り分け
if($main::submode2 eq ""){ &monster_index(); }
elsif($main::submode2 eq "fight"){ &monster_fight(); }
else{ &main::error("ページが存在しません。"); }

exit;

}

#-----------------------------------------------------------
# インデックス
#-----------------------------------------------------------
sub monster_index{

# 宣言
my($script_mode,$gold_url,$title) = &init();

&main::header();

# HTML
print qq(
<div class="body1">
<h1>モンスターファイト！ - $title</h1>
<form action="./" method="post">
<div>
<input type="hidden" name="mode" value="monster-fight">
<input type="submit" value="戦う">
</div>
</form>
</div>
);

&main::footer();

exit;

}

#-----------------------------------------------------------
# 戦う
#-----------------------------------------------------------
sub monster_fight{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my(@line,$file);

# 金貨枚数をチェック
&cash_check("","1");

# ファイル定義
$file = "${main::int_dir}_goldcenter/_monster_goldcenter/monster_status.log";

# ファイルを開く
open(MONSTER_IN,"< $file");
flock(MONSTER_IN,1);
my $top1 = <MONSTER_IN>;
close(MONSTER_IN);

# ファイルを分解
my($monster_hp) = split(/<>/,$top1);

# ステータスを変更
$monster_hp--;

# 追加する行
push(@line,"$monster_hp<>\n");

# ファイルを更新する
open(MONSTER_OUT,"+< $file") || &main::error("ファイルが開けません。") ;
flock(MONSTER_OUT,2);
seek(MONSTER_OUT,0,0);
truncate(MONSTER_OUT,tell(MONSTER_OUT));
print MONSTER_OUT @line;
close(MONSTER_OUT);
chmod($main::logpms,"$file");

$main::cgold--;

# クッキーをセット
&main::set_cookie();

# ページジャンプ
&Mebius::Jump("","${gold_url}monster.html","1","モンスターと戦いました。");

# 終了
exit;

}


1;

