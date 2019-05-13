
# 宣言
use Mebius::BBS;
use Mebius::BBS::Past;
use Mebius::BBS::Index;
use Mebius::Echeck;
use Mebius::Paint;
use Mebius::Utility;
use Mebius::Admin;
use Mebius::Basic;
use Mebius::BBS;
use Mebius::Host;
use Mebius::Adfix;
use Mebius::Directory;
use Mebius::Reason;
use Mebius::HTML;
use Mebius::Move;

use File::Basename;
package main;
use Mebius::Export;

# ●秘密板の管理者設定------------------------------------------------

#-----------------------------------------------------------
# タイプ振り分け
#-----------------------------------------------------------
sub junction_bbs_special_init_file{

if(!$secret_mode){ &error("この掲示板では設定できません。"); }

if($in{'action'}){ action_bbs_special_init_file(); }
else{ form_bbs_special_init_file(); }

}

#-----------------------------------------------------------
# 設定フォーム
#-----------------------------------------------------------
sub form_bbs_special_init_file{

# CSS定義
$css_text .= qq(
table,tr,th,td{border-style:none;}
table{width:60%;margin:1em 0em;}
body{line-height:1.4;}
input.text{width:12em;}
input.size{width:3em;}
input.setumei{width:25em;}
);

# フォームを取得
my($form) = &get_form;


# 変更しました
my($actioned_text);
if($in{'actioned'}){ $actioned_text = qq(<strong class="red">変更しました。</strong>); }

my $print = qq(
<h1><a href="$script">$title</a>の設定変更</h1>
<span class="alert">※好きな設定にすることが出来ます。数字は半角文字を使ってください。</span><br>
<span class="alert">※レスの一律待ち時間を使わない場合は、空欄にしてください。</span><br>
<span class="alert">※掲示板名、管理者のメールアドレスは必ず入力してください。</span>
$form
$actioned_text
);

Mebius::Template::gzip_and_print_all({},$print);


exit;
}

#-----------------------------------------------------------
# フォームを取得
#-----------------------------------------------------------

sub get_form{

$form .= qq(
<form action="$script" method="post"><div>
<input type="hidden" name="mode" value="init">
<table>
);

# タイトル
$form .= qq(<tr><td>掲示板タイトル</td><td><input type="text" name="title" value="$title" class="text"></td></tr>);

# 管理者のメールアドレス
$form .= qq(<tr><td>管理者のメールアドレス</td><td><input type="text" name="scad_email" value="$scad_email" class="text"></td></tr>);

# レスの待ち時間
$form .= qq(<tr><td>レスの待ち時間 (一律) </td><td><input type="text" name="norank_wait" value="$norank_wait" class="size"> 分 <span class="guide"> ( 小数点可 )</span></td></tr>);

# 掲示板の説明文
$form .= qq(<tr><td>掲示板の説明文</td><td><input type="text" name="setumei" value="$setumei" class="setumei"></td></tr>);

# ＣＳＳ
{
$form .= qq(<tr><td>掲示板の色</td><td><select name="style">);
my @styles = ("blue1","blue2","green","orange","pink","gray","purple");
	foreach(@styles){
			if($style =~ /$_.css$/ || $style eq $_){ $form .= qq(<option value="$_" selected>$_); }
			else{ $form .= qq(<option value="$_">$_); }
	}
$form .= qq(</select></tr>);

}

# 自主削除
{
my($checked1,$checked0);
if($candel_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>ユーザーによる自主削除</td><td>);
$form .= qq(<input type="radio" name="candel_mode" value="1"$checked1> 可);
$form .= qq(<input type="radio" name="candel_mode" value="0"$checked0> 不可);
$form .= qq(</td></tr>);
}


# 外部ＵＲＬの書き込み
{
my($checked1,$checked0);
if($allowurl_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>外部ＵＲＬの書き込み</td><td>);
$form .= qq(<input type="radio" name="allowurl_mode" value="1"$checked1> 可);
$form .= qq(<input type="radio" name="allowurl_mode" value="0"$checked0> 不可);
$form .= qq(</td></tr>);
}

# メールアドレスの書き込み
{
my($checked1,$checked0);
if($allowaddress_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>メールアドレスの書き込み</td><td>);
$form .= qq(<input type="radio" name="allowaddress_mode" value="1"$checked1> 可);
$form .= qq(<input type="radio" name="allowaddress_mode" value="0"$checked0> 不可);
$form .= qq(</td></tr>);
}

# 新規投稿の可否
{
my($checked1,$checked0);
if($no_rgt){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>新規投稿の可否</td><td>);
$form .= qq(<input type="radio" name="no_rgt" value="0"$checked0> 誰でも可);
$form .= qq(<input type="radio" name="no_rgt" value="1"$checked1> 管理者のみ可);
$form .= qq(</td></tr>);
}


# 新規投稿の待ち時間
{
my($checked1,$checked0);
if($freepost_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>新規投稿の待ち時間</td><td>);
$form .= qq(<input type="radio" name="freepost_mode" value="1"$checked1> なし);
$form .= qq(<input type="radio" name="freepost_mode" value="0"$checked0> あり);
$form .= qq(</td></tr>);
}

# かんたん新規投稿
{
my($checked1,$checked0);
if($fastpost_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>新規投稿前の確認フォーム</td><td>);
$form .= qq(<input type="radio" name="fastpost_mode" value="1"$checked1> なし);
$form .= qq(<input type="radio" name="fastpost_mode" value="0"$checked0> あり);
$form .= qq(</td></tr>);
}

$form .= qq(</table>);

$form .= qq(<input type="hidden" name="moto" value="$moto">);

$form .= qq(<input type="submit" name="action" value="この内容で設定変更する">);
$form .= qq(</div></form>);

$form;

}



#-----------------------------------------------------------
# 設定を変更 
#-----------------------------------------------------------
sub action_bbs_special_init_file{

# 局所化
my($line);

# ロック開始
&lock("$moto");

# 設定値のエラー
if($in{'title'} eq ""){ &error("掲示板タイトルは必須です。"); }
if($in{'scad_email'} eq ""){ &error("管理者のメールアドレスは必須です。"); }

# 設定値の定義
if($in{'title'} ne ""){ $title = $in{'title'}; }
$in{'norank_wait'} =~ s/[^0-9\.]//g;
if($in{'norank_wait'} ne ""){ $norank_wait = $in{'norank_wait'}; } else { $norank_wait = ""; }
$scad_email = $in{'scad_email'};
$scad_name = $admy_name;
$in{'style'} =~ s/\W//g;
$style = $in{'style'};
$setumei = $in{'setumei'};
if($in{'allowurl_mode'} eq "1"){ $allowurl_mode = 1; } else { $allowurl_mode = 0; }
if($in{'allowaddress_mode'} eq "1"){ $allowaddress_mode = 1; } else { $allowaddress_mode = 0; }
if($in{'freepost_mode'} eq "1"){ $freepost_mode = 1; } else { $freepost_mode = 0; }
if($in{'fastpost_mode'} eq "1"){ $fastpost_mode = 1; } else { $fastpost_mode = 0; }
if($in{'candel_mode'} eq "1"){ $candel_mode = 1; } else { $candel_mode = 0; }
if($in{'fastpost_mode'} eq "1"){ $fastpost_mode = 1; } else { $fastpost_mode = 0; }
if($in{'no_rgt'} eq "1"){ $no_rgt = 1; } else { $no_rgt = 0; }

# 更新内容
$line = qq($title<>$allowurl_mode<>$allowaddress_mode<>$fastpost_mode<>$freepost_mode<>$candel_mode<>$no_rgt<>
$norank_wait<>$style<>$setumei<>
$scad_email<>$scad_name<>
);

# 設定ファイルを書き込む
open(FILE_OUT,">${int_dir}_invite/init_${secret_mode}.cgi");
print FILE_OUT $line;
close(FILE_OUT);
chmod($logpms,"${int_dir}_invite/init_${secret_mode}.cgi");

# ロック解除
&unlock("$moto");

# リダイレクト
Mebius::Redirect("","$script?mode=init&actioned=1");


exit;

}

#● 管理者用のマイ設定-----------------------------------------------------------


#-----------------------------------------------------------
# マイ設定
#-----------------------------------------------------------
sub admin_mydata{

# 宣言
my($domain_links);
my(%renew_mydata);

	# 投稿後、ジャンプする
	if($in{'action'}){ $jump_head ="<meta http-equiv=\"refresh\" content=\"0;url=./${script}?mode=mydata\">"; }

$main::sub_title = "マイ設定 - $main::server_domain";

	# マイデータを変更
	if($in{'action'}){
		&change_mydata_admin();
	}


	foreach(@domains){
			if($main::server_domain eq $_){ $domain_links .= qq($_\n); }
			else{ $domain_links .= qq(<a href="https://$_/jak/index.cgi?mode=mydata">$_</a>\n); }
	}

my $print .= <<"EOM";
<a href="$home">ＴＯＰ</a>
<a href="JavaScript:history.go(-1)">前の画面に戻る</a><hr>
<strong>$my_name</strong>の管理者設定（マイ設定）が出来ます。<br><br>

<strong style="color:#f00;">設定値を”空欄”に変更すると、初期設定になります。</strong>(何か変になったら空欄設定を)<br>
<strong style="color:#f00;">数値は半角数字で設定してください。</strong><br><br>

<div>
サーバー： $domain_links
</div>
<hr>
EOM

# 情報変更＆表示用フォームを表示
$print .= mydata_form();

# データをテキストで確認

	if($admy{'rank'} >= $master_rank){
		$print .= "▼データの状態（確認用）<br>";

		open(MYDATA_IN,"<","_mydata/${admy_file}.cgi");
		while(<MYDATA_IN>){ $print .= "$_<br>";}
		close(MYDATA_IN);

	}

# フッタ
$print .= <<"EOM";
<hr>
<a href="$home">ＴＯＰ</a>
<a href="JavaScript:history.go(-1)">前の画面に戻る</a>
EOM


Mebius::Template::gzip_and_print_all({},$print);

exit;

}


use strict;

# --------------------------------------------
# マイ設定の変更
# --------------------------------------------
sub change_mydata_admin{

# 宣言
my($basic_init) = Mebius::basic_init();
my(%renew_mydata);

	# 自分の設定ファイルかどうかをチェック
	if($main::in{'file'} ne $main::admy{'id'} && $main::admy{'rank'} < $main::master_rank){
		main::error("自分のファイルではありません。");
	}

	# メールアドレスの書式判定
	if($main::in{'mobile_email'}){ Mebius::Email::mail_format("Error-view",$main::in{'mobile_email'}); }
	if($main::in{'email'}){ Mebius::Email::mail_format("Error-view",$main::in{'email'}); }

# 変更を定義
$renew_mydata{'deleted_text'} = $main::in{'deleted_text'};
$renew_mydata{'email'} = $main::in{'email'};
$renew_mydata{'mobile_email'} = $main::in{'mobile_email'};
$renew_mydata{'res_template'} = $main::in{'res_template'};

# アカウントのリンク
	my($myaccount) = Mebius::my_account();
	if($main::in{'account'} && $myaccount->{'file'}){ $renew_mydata{'account'} = $myaccount->{'file'}; }
	elsif($main::in{'account_delete'}){ $renew_mydata{'account'} = ""; }

	if($main::in{'use_mailform'}){ $renew_mydata{'use_mailform'} = 1; } else { $renew_mydata{'use_mailform'} = 0; }

	# アカウント凍結
	if($main::in{'close_account'} && $main::in{'close_account_check'}){
		$renew_mydata{'concept'} = qq( Close-account);
	}

# 更新
my(%member) = Mebius::Admin::MemberFile("Edit-mydata Renew Allow-empty-password Use-renew-hash",$main::in{'file'},undef,%renew_mydata);

Mebius::Redirect("","$basic_init->{'admin_http'}://$main::server_domain/jak/index.cgi?mode=mydata&file=$main::in{'file'}");

}

no strict;

# --------------------------------------------
# データ表示＆送信用フォーム部分
# --------------------------------------------

sub mydata_form{

# 開くID
my $id = $main::in{'file'};

	# 開くIDを定義
	if($main::in{'file'}){
		$id = $main::in{'file'};
	}
	else{
		$id = $main::admy{'id'};
	}

	# 自分の設定ファイルかどうかをチェック
	if($id ne $main::admy{'id'} && $main::admy{'rank'} < $main::master_rank){
		main::error("自分のファイルではありません。");
	}

# 表示調整
my(%admy) = Mebius::Admin::MemberFile("Get-hash Allow-empty-password",$id);

$pri_myd_template = $myd_template;
$pri_myd_template =~ s/<br>/\r/g;

$pri_myd_formlink = $myd_formlink;
$pri_myd_formlink =~ s/<br>/\r/g;

if($admy{'use_mailform'}){ $checked_use_mailform = $main::checked; }

# HTML

my $print .= <<"EOM";
<form action="$script" method="POST">
<input type="submit" value="この内容でマイデータを変更する" class="isubmit">
<br><br>
<input type="hidden" name="mode" value="mydata">
<input type="hidden" name="action" value="1">

<div>
<h3>▼メールアドレス</h3>
<p>
PC： <input type="text" name="email" value="$admy{'email'}" class="input">
<span class="alert">※各種アラートなどに使われます。</span>
<input type="checkbox" name="use_mailform" value="1" id="use_mailform"$checked_use_mailform> <label for="use_mailform">メールフォームを使う</label>
</p>
<p>
携帯： <input type="text" name="mobile_email" value="$admy{'mobile_email'}" class="input">
<span class="alert">※各種アラートなどに使われます。</span>
</p>

</div>

EOM

$print .= qq(
<div>
<h3>▼アカウント</h3>
現在の設定： $admy{'account'}
<br$main::xclose>
<label><input type="checkbox" name="account" value="1"> <a href="${main::auth_url}$main::myaccount{'file'}/">$main::myaccount{'file'}</a> を管理用アカウントに設定する</label>
<label><input type="checkbox" name="account_delete" value="1"> アカウントのリンクを解除する</label>
</div>
);


$print .= <<"EOM";
<h3>掲示板の設定</h3>
▼返信投稿を削除したときのコメント
（例：この投稿は削除されました～など）<br>
<input type="text" name="deleted_text" value="$admy{'deleted_text'}" class="input">
<br><br>
EOM

my $none = qq(
▼各記事１ページあたり、いくつの返信を表\示するか。<br>
（返信を何件ごとに区切るか）
（例：100 50 20 など）<br>
<input type="text" name="th_page" value="$myd_th_page" class="input">
<br><br>

▼返信投稿１個あたり、～行以上だと省略する。<br>
（管理者投稿は省略されません）
（例：50 20 5など）<br>
<input type="text" name="ryaku" value="$myd_ryaku" class="input">
<br><br>

▼親記事”内”で検索したときに、表\示する最大投稿数（ＨＩＴ数）。<br>
（少なくすると、表\示が軽くなります）
（例：50 20 5など）<br>
<input type="text" name="oyasearch" value="$myd_oyasearch" class="input">
<br><br>

▼投稿フォームのメモ<br>
);

my($textarea_res_template) = Mebius::Descape(undef,$main::admy{'res_template'});
#$print .= qq(<textarea name="res_template" style="width:100%;height:5em;">) . &Escape::HTML([$textarea_res_template]) . qq(</textarea><br><br>);

# レステンプレート

$print .= <<"EOM";
<br>
<input type="hidden" name="file" value="$id">

<div style="margin-top:1em;">
<input type="submit" value="この内容でマイデータを変更する" class="isubmit">
</div>


<div style="background:#fdd;padding:0.5em 1em;margin:1em 0em;">
<h3>▼アカウントの凍結</h3>
<input type="checkbox" name="close_account" value="1" id="close_account"><label for="close_account">アカウントを凍結する</label>
<input type="checkbox" name="close_account_check" value="1" id="close_account_check"><label for="close_account_check">アカウントを凍結する（確認）</label>

<p class="red">※アカウントが不正利用されている恐れがある場合など、このアカウントを凍結し、ログインを禁止します。
いちどアカウントを凍結すると、自分では再開することが出来ないため注意してください。</p>
</div>
</form>
EOM


$print;

}


no strict;

# ● 掲示板の管理------------------------------------------------


#-----------------------------------------------------------
# マイデータなどの設定
#-----------------------------------------------------------

sub ad_settei{

# 削除しました、のテキストを決める

	# マイデータある場合
	if($main::admy{'deleted_text'}){ $del_text = qq(【 $main::admy{'deleted_text'} (<a href="${guide_url}">?</a>) 】);}

	# 無い場合
	else{ $del_text = qq(【 管理者削除 (<a href="${guide_url}">?</a>) 】); }

$del_text2 ='【削除済】';

}



#-------------------------------------------------
#  管理者機能
#-------------------------------------------------
sub admin {

require Mebius::BBS;
&init_start_bbs("Admin-mode");

local($subject,$log,$top,$itop,$sub,$res,$nam,$em,$com,$da,$ho,$pw,$re,$sb,$na2,$key,$last_nam,$last_dat,$del,@new,@new2,@sort,@file,@del,@top);

	# メニューからの処理
	if ($in{'job'} eq "menu") {
		foreach ( keys(%in) ) {
			if (/^past(\d+)/) {
				$in{'past'} = $1;
				last;
			}
		}
	}

	# 汚染チェック
	$in{'no'} =~ s/[^0-9\0]//g;

	# index定義
	if ($in{'past'} == 3 && $authkey) {
		&member_mente;
	} elsif ($in{'past'} == 2) {
		&filesize;
	} elsif ($in{'past'} == 1) {
		$log = $pastfile;
		$subject = "過去ログ";
	} else {
		$log = $nowfile;
		$subject = "現行ログ";
	}


# 修正実行
if($in{'action'} eq "edit_kiji") { &edit_log("admin"); }

#-------------------------------------------------
# スレッド操作
#-------------------------------------------------
elsif($in{'thread_control'}) {

Mebius::Admin::bbs_thread_control_multi_from_query();

Mebius::redirect_to_back_url();

#admin_after_action("記事の状態を切り替えました。");

exit;

}

#-----------------------------------------------------------
# 処理分岐
#-----------------------------------------------------------

elsif($in{'action'} eq "view" && $in{'no'} ne "") {

my($my_admin) = Mebius::my_admin();

	# 権限などの判定
	if ($my_admin->{'rank'} < 1) { &error("削除権限がありません"); }
	if ($in{'del_type'} == 3 && !$my_admin->{'master_flag'}) { &error("削除権限がありません"); }
	if ($in{'del_type'} == 3 && $in{'no2'} =~ /\b0\b/) { &error("親記事の削除はできません"); }
	if ($in{'del_type'} == 5 && $my_rank < 10) { &error("復活権限がありません"); }


	# レス操作
	if($in{'job'} eq "del" && ($in{'no2'} || $in{'control_type'})) {

		my($multi_control) = Mebius::Admin::bbs_thread_control_multi_from_query();

		my($controled_res_numbers) = Mebius::join_array_with_mark(",",$multi_control->{'last_control_thread'}->{'controled_res_numbers'});

			if(Mebius::redirect_to_back_url()){

			} else {
				Mebius::redirect("?mode=view&no=$multi_control->{'last_control_thread'}->{'number'}&No=$controled_res_numbers#S$multi_control->{'last_control_thread'}->{'controled_res_numbers'}->[0]");
			}

	}

	# レス修正

	elsif ($in{'job'} eq "edit" && $in{'res'} ne "") {
		($in{'res'}) = split(/\0/, $in{'res'});
		&edit_log("admin");
	}

#-----------------------------------------------------------
# 何も入力せずにレス操作を実行
#-----------------------------------------------------------

&error("実行タイプを選んでください。"); 

}


&error("実行タイプを選んでください。");

exit;

}

use Mebius::Handle;
use strict;

no strict;


#-----------------------------------------------------------
# 携帯アクセスを判定
#-----------------------------------------------------------
sub check_kaccess{

my($host,$age) = @_;
my($kaccess_one);

if($host eq "" || $age eq ""){ return; }

# 携帯判定
if($host =~ /docomo\.ne\.jp$/){
if($age =~ /^DoCoMo([a-zA-Z0-9 ;\(\/\.]+?)ser([0-9a-z]+)/){ $kaccess_one = $2; }
}
elsif($host =~ /ezweb\.ne\.jp$/){
if($age =~ /^([0-9]+)_([a-z]+)\.ezweb\.ne\.jp$/){ $kaccess_one = $1; }
}
elsif($host =~ /(softbank\.ne\.jp$|vodafone\.ne\.jp$|jp-([dnrtcknsq]+)\.ne\.jp$)/){
if($age =~ /SN([0-9]+)/){ $kaccess_one = $1; }
}

return($kaccess_one);

}



#-------------------------------------------------
#  注意投稿から削除
#-------------------------------------------------

sub delete_rcevil{

# 局所化
my($type,@resnumbers);
my(@line);

# ファイルを開く
open(IN,"<","${int_dir}_sinnchaku/rcevil.log");
	while(<IN>){
		chomp;
		my($key,$typename,$title,$url,$sub,$handle,$comment,$resnumber,$lasttime,$dat,$category,undef,$echeck_oneline) = split(/<>/);

		foreach(@resnumbers){
		if($url =~ /^http:\/\/$server_domain\/_$moto\/$in{'no'}.html-$_/){ $key = "2"; }
		}

		push(@line,"$key<>$typename<>$title<>$url<>$sub<>$handle<>$comment<>$resnumber<>$lasttime<>$dat<>$category<><>$echeck_oneline\n");
	}
close(IN);

# ファイルを書き出す
Mebius::Fileout(undef,"${int_dir}_sinnchaku/rcevil.log",@line);


}

#-------------------------------------------------
#  記事復活させる場合、削除済みインデックスから行削除
#-------------------------------------------------
sub deleted_index_delete{

# 復活処理内のみの局所化
my($top,$no,$no2,$line,$lock);

	# 削除済みインデックスを開き、該当行を削除
	foreach $no (@lock) {

		open(DELETED_INDEX_IN,"<","${int_dir}_deleted/${moto}_deleted.cgi");

			while(<DELETED_INDEX_IN>){
				($no2) = split (/<>/,$_);
					if($no ne "$no2"){ $line .= $_; }
			}

		close(DELETED_INDEX_IN);

		# 削除済みインデックスの書き出し
		Mebius::Fileout(undef,"${int_dir}_deleted/${moto}_deleted.cgi",$line);

		}
	}

use strict;

#-------------------------------------------------
#  特定ユーザーに【新規投稿】の待ち時間を作る
#-------------------------------------------------

sub delete_wait{

# 局所化
my($file,$oktime,$no) = @_;
my $time = time;
my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();
our($moto);

# 汚染チェックなど
$file = Mebius::Encode("",$file);
if($file eq ""){ return; }
$no =~ s/\D//g;

my $print_oktime = $time + $oktime . "<>_$moto<>$no<>\n";

Mebius::Fileout(undef,"${share_directory}_ip/_ip_delnew/$file.cgi",$print_oktime);


}


no strict;

#● 掲示板のメニューページ ------------------------------------------------



#-----------------------------------------------------------
# 管理モード 掲示板メニュー
#-----------------------------------------------------------

sub admin_indexview{

my($basic_init) = Mebius::basic_init();

# BODY Javascript 定義
$body_javascript = qq( onload="document.SEARCH.word.focus()");

# サブ記事モードの場合、メインにリダイレクト
if($subtopic_mode){ print "location:$moto.cgi\n\n"; exit; }

local($num,$sub,$res,$nam,$date,$na2,$key,$alarm,$i,$data,$top,$count);


# CSS定義
if($subtopic_link){
$css_text .= qq(
.subres{color:#080;}
.subres2{color:#080;font-size:80%;}
);
}



my $print = <<"EOM";
<div align="center">
<div class="div6"><br>

<a href="/_$moto/" class="title">$title (管理モード)</a>
<span class="size0"><br><br></span>
$my_name　（管理権限：$my_rank）
$setumei<br><br>
<span class="size4">
<a href="$home" accesskey="0">ＴＯＰ</a>&nbsp;
<a href="$script?mode=form" accesskey="1">新規</a>&nbsp;
<a href="$basic_init->{'admin_report_bbs_url'}">削除板</a>&nbsp;
$adroom_link&nbsp;
<a href="${base_url}jak/chat/comchat.cgi" style="color:#f00;">チャット</a>
<a href="$main::main_url?mode=mydata" style="color:#f00;">マイ設定</a>
<a href="/wiki/guid/">ガイド</a>

<a href="$script?mode=logoff">off</a>
</span></div>
<br>
<form action="$script" name="SEARCH" class="margin">
<div>
<input type="hidden" name="mode" value="find">
<input type="text" name="word" size="38" value="">
<input type="submit" value="記事検索">
</div>
</form>
EOM

$print .= <<"EOM";
<a name="up"></a><table summary="ページ一覧"><tr><td class="page"><a href="#dw" accesskey="3">Page</a>
EOM

$page = $i_max / $menu1;
$mile = 1;
	while ($mile < $page + 1){
		$mine = ($mile - 1) * $menu1;
			if($main::in{'p'} == $mine){ $print .= qq($mile\n); }
			else{ $print .= "<a href=\"$script?p=$mine\">$mile</a>\n"; }
		$mile++;
	}

#メニュー上部リンク

$print .= <<"EOM";
<span class="size3">
<a href="$script?mode=past">過去</a>
</span>
<hr>
<span class="size3">
<a href="$main::main_url?mode=mydata" style="color:#f00;"><strong>マイ設定を変更</strong></a> / 
EOM


if($in{'lock'}){print"ロック ";}
else{print"<a href=\"$script?lock=1\">ロック中の記事を表\示</a> / ";}


#<a href="${category}.cgi?mode=view&no=${moto}&r=0">新規投稿された記事</a> / 
#<a href="${category}.cgi?mode=view&no=${moto}&r=1">新着返信</a>

$print .= <<"EOM";
</span>
</td></tr></table><br>
<table cellpadding="3" summary="記事一覧"><tr><td class="td0">No</td><td class="td1">
EOM


# スレッド表示

if ($main::in{'p'} eq "") { $main::in{'p'}=0; }
$i=0;
open(IN,"$nowfile");

$top = <IN>;
($big_num,$big_nothing2,$big_nothing3,$big_nothing4) = split(/<>/, $top);

if($my_rank >= $master_rank){
$cordlink = qq(
 / <a href="$script?mode=init_edit">設定</a>
 / <a href="$script?mode=cord&amp;file=init">ｿｰｽ</a>
 / <a href="$script?mode=cord&amp;file=idx">現行</a>
 / <a href="$script?mode=cord&amp;file=pst">過去</a>
 / <a href="http://aurasoul.mb2.jp/pmlink/pmlink.cgi?mode=adapply" class="red">相互</a>
 / <a href="http://mb2.jp/_auth/spform.html" class="red">SP会員</a>

);

}

# シークレット板の設定
if($secret_mode && ( $secret_mode eq $admy_file || $admy_rank >= $master_rank ) ){
$cordlink .= qq( / <a href="$script?mode=init" class="red">掲示板の基本設定</a>);
$cordlink .= qq( / <a href="$mainscript?mode=member&amp;adfile=$secret_mode" class="red">メンバー管理</a>);
}

$print .= qq(
題名</td><td class="td2">名前</td><td class="td3">最終</td><td class="td4"><a name="go"></a>返信</td></tr>
<tr><td>0</td><td>
<a href="/_$moto/rule.html">★$titleのルール</a>
 / <a href="$script?mode=view&amp;no=$big_num">最新記事</a>);

$print .= qq( / <a href="/_$main::realmoto/all-deleted.html#M">削除済み(通常版)</a>);

$print .= qq($cordlink
</td><td>別窓で</td><td>開いてください</td><td>0回</td></tr>
);


	while (<IN>) {
		$i++;

		if(!$in{'lock'}){
		next if ($i < $main::in{'p'} + 1);
		next if ($i > $main::in{'p'} + $menu1);
		}

		my($num,$sub,$res,$nam,$date,$na2,$key) = split(/<>/);


		# 新着記事チェック
		my($mark,$stopic);

		if($key eq "0"){$mark = "止";}
		elsif($key == 2){$mark = "＠";}
		elsif($key == 5){$mark = "優";}
		elsif($key == 9){$mark = "18";}
		elsif($key == 8){$mark = "15";}
		elsif($date > $time - 60*60*3){ $mark = "★"; }
		elsif($date > $time - 60*60*24){ $mark = "☆"; }
		elsif($date > $time - 60*60*24*7){ $mark = "∴"; }
		else{$mark = "-";}

		if($key ne "0"){
		$mark = qq(<a href="$script?mode=view&amp;no=${num}#S${res}">$mark</a>);
		}

			# サブ記事取得
			if($subtopic_link){
			my($submark);
			my($res,$restime,$reser) = &get_subres_admin($num);
			if($reser =~ /サブ記事/){ $reser = ""; }
			if($restime > $time -  60*60*24){ $submark = qq( <a href="sub$moto.cgi?mode=view&amp;no=$num#S$res" class="subres2">▼$reser</a> ); }
			if($res){ $stopic = qq(&nbsp; ( <a href="sub$moto.cgi?mode=view&amp;no=$num" class="subres">Re:$res</a> $submark ) ); }
			}


			# アイコン定義

			if($in{'lock'} && $key ne "0"){ next; } else {
			$print .= "<tr><td>$mark</td><td>";

			if (!$key) { $print .= "[<span style=\"color:#FF0000;\">止</span>] "; }
			elsif ($key == 2) { $print .= "[<span style=\"color:#FF0000;\">ピン</span>] ";}
			elsif ($key == 5) { $print .= "[<span style=\"color:#FF0000;\">優</span>] "; }

			$print .= "<a href=\"$script?mode=view&amp;no=$num\">$sub</a>$stopic";

			$print .= "</td><td>$nam</td><td>$na2</td><td>$res回</td></tr>";

			}
	}
	close(IN);

$print .= "</table><br><a name=\"dw\"></a>
<table summary=\"ページ一覧\"><tr><td class=\"page\"><a href=\"#up\" accesskey=\"4\">Page</a>\n";

# ページ移動ボタン表示
$page = $i_max / $menu1;
$mile = 1;
	while ($mile < $page + 1){
		$mine = ($mile - 1) * $menu1;
			if($main::in{'p'} == $mine){ $print .= qq($mile\n); }
			else{ $print .= "<a href=\"$script?p=$mine\">$mile</a>\n"; }
		$mile++;
	}

$print .= <<"EOM";
<a href="$script?mode=past" class="size3">過去ログ</a>
</td></tr></table>
</div>
EOM

# 修復モードへリンク
if($my_rank >= 100){
if($in{'repair'}){
#print"<a href=\"$script\">戻る</a><br>"; require 'part_adrepair.cgi'; &part_repair;
}
else{
$print .= qq(<br><a href="$script?repair=1&end=$big_num">修復</a>\n);
$print .= qq(<a href="$script?mode=findkey">全文検索</a>\n);
$print .= qq(<a href="$script?mode=keycheck">キーチェック</a>\n);
$print .= qq(<a href="$script?mode=url">ＵＲＬ変換</a>\n);

}
}

Mebius::Template::gzip_and_print_all({ Title => $title },$print);


exit;

}


#-----------------------------------------------------------
# サブ記事のレス数を取得
#-----------------------------------------------------------
sub get_subres_admin{
my($file) = @_;

open(SUB_IN,"${int_dir}sub${moto}_log/$file.cgi");
my $top = <SUB_IN>;
my($none,$reser,$res,$none,$none,$restime) = split(/<>/,$top);
close(SUB_IN);

return($res,$restime,$reser);

}



# ● ユーザー管理 -----------------------------------------------------


#-----------------------------------------------------------
# 管理番号の操作画面
#-----------------------------------------------------------
sub admin_cdl{

	# モード振り分け
	if($in{'file'} eq ""){ SelectView(); }
	elsif($in{'type'} eq "control_all_res_from_history"){ control_all_res_from_history(); }
	else{ view_user_data(); }

# 処理終了
exit;

}

use strict;

#-----------------------------------------------------------
# ファイルを選ぶためのページ
#-----------------------------------------------------------
sub SelectView{

my($view_line,$dos_flow_directory,$files);

	# リダイレクト
	if($main::in{'select_file'}){
		my($file) = $main::in{'select_file'};
		$file =~ s/^(\s|　)+//g;
		$file =~ s/(\s|　)+$//g;
			if($main::in{'filetype'} eq "isp"){ ($file) = Mebius::Isp(undef,$file); }
			elsif($main::in{'filetype'} eq "second-domain"){ (undef,$file) = Mebius::Isp(undef,$file); }
			else{ $file = $file; }
		my($file_encoded) = Mebius::Encode(undef,$file);
		Mebius::Redirect(undef,"${main::main_url}?mode=cdl&file=$file_encoded&filetype=$main::in{'filetype'}");
	}


my $file_encoded = Mebius::Encode(undef,$main::in{'select_file'});

$view_line .= qq(<h2>任意の管理ファイルに移動</h2>\n);
$view_line .= qq(<div style="">\n);
$view_line .= qq(<form action="" style="margin:1em 1em;">\n);
$view_line .= qq(<input type="hidden" name="mode" value="cdl">\n);
$view_line .= qq(<input type="text" name="select_file" style="width:20em;font-size:110%;" value="$main::in{'select_file'}"><br><br> \n);

$view_line .= qq(<input type="submit" name="filetype" value="number">\n);
$view_line .= qq(<input type="submit" name="filetype" value="account">\n);
$view_line .= qq(<input type="submit" name="filetype" value="host">\n);
$view_line .= qq(<input type="submit" name="filetype" value="isp">\n);
$view_line .= qq(<input type="submit" name="filetype" value="second-domain">\n);
$view_line .= qq(<input type="submit" name="filetype" value="addr">\n);
$view_line .= qq(<input type="submit" name="filetype" value="agent">\n);
$view_line .= qq(<input type="submit" name="filetype" value="handle">\n);

#$view_line .= qq(<input type="submit" value="実行する">\n);
$view_line .= qq(</form>\n);
$view_line .= qq(</div>\n);

# DOS判定ディレクトリを取得
opendir($dos_flow_directory,"${main::int_dir}_dos/_dos_flow/");
my @dos_flow_files = grep(!/^\./,readdir($dos_flow_directory));
close $dos_flow_directory;

	# ●DOS判定されたファイルを表示する場合 ( マスターのみ )
	if($main::admy_rank >= $main::master_rank){

		# 整形
		$view_line .= qq(<h2>DOS判定ファイル ( 管理権限$main::master_rank )</h2>\n);

			# DOS判定ディレクトリ展開
			foreach $files (@dos_flow_files){

				# 局所化
				my($addr,$host);

				# ファイル名を分解
				my($host_or_addr) = split(/_/,$files);

				# ホスト名かIPアドレスかを判定
				my($file_type) = Mebius::Format::HostAddr(undef,$host_or_addr);

				# DOS判定ファイル２種を取得
				#my(%dos_flow) = Mebius::Dos::FlowFile("Get-hash",$host_or_addr);
				#my(%dos) = Mebius::Dos::AccessFile("Get-hash",$dos_flow{'addr'});

				# 表示行の定義
				$view_line .= qq(<a href="${main::main_url}?mode=cdl&amp;file=$host_or_addr&amp;filetype=$file_type">$host_or_addr</a>\n);
					#if($dos{'dos_count'}){ $view_line .= qq(($dos{'dos_count'})\n); }
				$view_line .= qq(<br$main::xclose>\n);

			}
	}


Mebius::Template::gzip_and_print_all({},$view_line);

exit;


}


#-----------------------------------------------------------
# 基本処理を実行
#-----------------------------------------------------------
sub view_user_data{

# 宣言
my($basic_init) = Mebius::basic_init();
my($server_domain) = Mebius::server_domain();
my($parts) = Mebius::Parts::HTML();
my($type) = @_;
my($invited_flag,$invite_input,$okaddr_link,$select_dir,$file_enc,$file2,$adevice_mark,$disabled_reset);
my($none,$reshistory_line,$login_hisory_line,$plustype_adevice,$option_deny_select,$input_revety,$action_date,$dos_line,$date_unblock);
my($whois_line,$account_link,%history,$input_block,$other_history_line,$file,$left_penalty_date,$domain_links);
my $html = new Mebius::HTML;
our(%in,@domains,$postbuf,$master_rank,$leader_rank,$admy_rank,$home,$admy_file,$script,$mainscript);

# CSS定義
our $css_text .= qq(
table,th,tr,td{border-style:none;}
table{margin-top:0.5em;padding:1em;}
h1{line-height:1.3;font-size:170%;}
td{padding:0.3em 0.2em;}
li{line-height:1.6;}
div.before_deleted{background-color:#ff9;padding:1em;margin:1em 0em;}
div.nodata{margin:1em 0em;padding:1em;background-color:#ccc;}
div.block_data{background-color:#cee;}
div.penalty_data{background-color:#fdb;}
th{display:none;}
.domain_links{color:#080;font-size:140%;margin:1em 0em;font-style:oblique;}
.block{padding:0em 1.0em;}
div.savedata{background:#dee;padding:1em;margin:1em 0em;}
div.block_select{margin:1em 0em;}
div.block_bbs{margin:1em 0em;}
div.reshistory{background:#fe9;padding:1.0em;}
div.other_history{padding:0.3em 1.0em;border:1px solid #b9f;}
td.left{width:8em;}
hr{border-color:#000;}
div.deleted_history{padding:1em 0.5em;}
);

# タイトル定義
$main::sub_title = qq(ユーザー管理 - $in{'file'});

	# ファイルタイプの定義
	if($in{'filetype'} eq "account"){ $plustype_adevice .= qq( Account); }
	elsif($in{'filetype'} eq "number" || $in{'filetype'} eq "cnumber"){ $plustype_adevice .= qq( Cnumber); }
	elsif($in{'filetype'} eq "agent"){ $plustype_adevice .= qq( Agent); }
	elsif($in{'filetype'} eq "host"){ $plustype_adevice .= qq( Host); }
	elsif($in{'filetype'} eq "addr"){ $plustype_adevice .= qq( Addr); }
	elsif($in{'filetype'} eq "handle"){ $plustype_adevice .= qq( Handle); }
	elsif($in{'filetype'} eq "second-domain"){ $plustype_adevice .= qq( Second-domain); }
	elsif($in{'filetype'} eq "isp"){
		$type .= qq( Isp-view);
		$plustype_adevice .= qq( Isp);
	}

my($adevice_type,$select_dir,$k_access,$kaccess_one) = &adevice("$plustype_adevice",$in{'file'});

	# 管理者の場合
	if($in{'file'} eq "管理者"){ &error("管理者です、いつもご苦労様です！"); }

	# ファイル、ディレクトリ定義
	if($adevice_type eq "kaccess_one"){
		$file = "${kaccess_one}_${k_access}";
		$adevice_mark = qq(<span style="font-size:90%;color:#080;">( 固体識別： ${kaccess_one}_${k_access} )</span>);
	}
	else{
		$file = $in{'file'};
		$adevice_mark = qq(<span style="font-size:90%;color:#080;">( $adevice_type )</span>);
	}

# リターン
if($file eq "" || $adevice_type eq ""){ return; }

# レス待ち時間の操作
if($in{'change'}){ &change(undef,$plustype_adevice); }

# ファイルを開く
my(%penalty) = Mebius::penalty_file("Get-hash Get-deleted-index Get-flag $plustype_adevice",$main::in{'file'});

# 制限理由を取得
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_delreason.pl";
my($select) = shift_jis(Mebius::Reason::get_select_reason($penalty{'block_reason'},"ACCOUNT"));
my $reason = &delreason($penalty{'block_reason'},"SUBJECT");
if($reason){ $reason = qq($reason); }

	# 投稿制限の決定日付を計算
	if($penalty{'block_decide_time'}){
		($action_date) = Mebius::Getdate(undef,$penalty{'block_decide_time'});
	}

# 投稿制限中の場合、エリアに赤色をつける
if($penalty{'block_time_flag'}){ $css_text .= qq(div.block_data{background-color:#fbb;}); }
if($penalty{'block_time_flag'} && $penalty{'block'} eq "3"){ $css_text .= qq(div.block_data{background-color:#9d9;}); }

	# 待ち時間を計算
	if($penalty{'penalty_time'} > time){
		($left_penalty_date) = Mebius::SplitTime(undef,$penalty{'penalty_time'}-$main::time);
	}

	# ドメイン切り替えリンク
	{
		my($i);
			foreach(@domains){
			$i++;
				if($i >= 2){ $domain_links .= qq( - ); }
				if($_ eq $server_domain){ $domain_links .= qq( $_ ); }
				else{ $domain_links .= qq( <a href="$basic_init->{'admin_http'}://$_/jak/index.cgi?$postbuf">$_</a> ); }
			}
		$domain_links = qq(<div class="domain_links">ドメイン： $domain_links</div>);
	}
	#mode=cdl&amp;file=$file

# 制限時間のセレクトボックスを定義
my $d_unblock = 1+int(($penalty{'block_time'} - $main::time)/(60*60*24)) if($penalty{'block_time'});
my(%date_unblock) = Mebius::Getdate("Get-hash",$penalty{'block_time'}) if($penalty{'block_time'});

	# 解除日の選択
	if($penalty{'Flag'}->{'some_indefinite_block'}){
		$date_unblock = "無期限";
		$input_revety = qq(<option value="not_change"$main::selected>解除日 $date_unblock</option>);
	}
	elsif($penalty{'block_time'}){
	$date_unblock = "$date_unblock{'yearf'}/$date_unblock{'monthf'}/$date_unblock{'dayf'}";
		$input_revety = qq(<option value="not_change"$main::selected>解除日 $date_unblock</option>);
	}
	else{
		$input_revety = qq(<option value=""$main::selected>なし</option>);
	}

my $view_unblock = qq($d_unblock日後) if($d_unblock);

	# part_delreason.pl から、制限期間のパターンを取得
	if($admy_rank >= $master_rank){ ($option_deny_select) = shift_jis(Mebius::Reason::get_select_denyperiod("")); }
	else{ ($option_deny_select) = shift_jis(Mebius::Reason::get_select_denyperiod("Limited")); }

# 解除日の選択ボックス
my $select_blocktime .= qq(<select name="block_time" style="background:#dee;">);
$select_blocktime .= qq($input_revety);
	if($admy_rank >= $master_rank){ $select_blocktime .= qq(<option value="forever">無期限</option>); }
$select_blocktime .= qq($option_deny_select);
$select_blocktime .= qq(</select><span style="color:#080;font-size:90%;">*基本1週間～2ヶ月ほど。</span>);

	# ●投稿制限のコントロール
	if($admy_rank >= $leader_rank){

		# 局所化
		my($allow_host_line,$exclusion_line,$user_agent_match_line,$block_report_line);

			# アドレス許可リンク
			if($in{'file'} =~ /^([0-9\.]+)(-MebiHost|\.mb2)(\.jp)?$/ && $admy_rank >= $master_rank){
				$okaddr_link = qq( <a href="$mainscript?mode=cda&amp;file=$1">→IPアドレスの管理</a> / );
			}

		# 個別制限コントロール
		my($block_bbs_input);

		$block_bbs_input = qq(
		<div class="block_bbs">個別制限： <input type="text" name="block_bbs" value="$penalty{'block_bbs'}">
		<span class="guide">※サイト全体の投稿制限とは”別に”、各掲示板を制限します。たとえば自由掲示板と日記投稿城を制限する場合は「ztd nikki」と入力します。</span>
</div>); 

			# ISPの場合、警告
			if($type =~ /Isp-view/){
				$input_block .= qq(<div style="color:#fff;padding:0.3em;background:#f00;text-align:center;"><strong>※ 注 … ISP管理です！ ( 広域 - $in{'file'} - に制限がかかります ) </strong></div>);
			}

		# 投稿制限の回避チェック

		# 初期チェック
		my $checked_block1 = $main::checked , my $class_block1 = qq( class="red bold") if($penalty{'block'} eq "1");
		my $checked_block2 = $main::checked , my $class_block2 = qq( class="red bold") if($penalty{'block'} eq "2");
		my $checked_block3 = $main::checked , my $class_block3 = qq( class="red bold") if($penalty{'block'} eq "3");
		my $checked_block0 = $main::checked , my $class_block0 = qq( class="blue") if($penalty{'block'} eq "" || $penalty{'block'} eq "0");

		# ホスト名の許可
		if($main::admy_rank >= $main::master_rank && $plustype_adevice =~ /Host|Isp|Second-domain/){
			my($checked_allow,$checked_allow_default);
				if($penalty{'allow_host_flag'}){ ($checked_allow) = $main::checked ; }
				else{ $checked_allow_default = $main::checked; }
			$allow_host_line .= qq(<div>\n);
			$allow_host_line .= qq(<input type="radio" name="allow_host" id="allow_host_none" value=""$checked_allow_default>\n);
			$allow_host_line .= qq(<label for="allow_host_none">無設定</label>\n);
			$allow_host_line .= qq(<input type="radio" name="allow_host" id="allow_host" value="Allow"$checked_allow>\n);
			$allow_host_line .= qq(<label for="allow_host">.jp ドメイン以外でも投稿できるように </label>\n);
			$allow_host_line .= qq(</div>\n);
		}

		# 各種実行ボタン
		$input_block .= qq(
		<div class="block">
		<div class="block_select">
		<strong>投稿制限：</strong> 
		<input type="radio" name="block" value="0" id="block0"$checked_block0> <label for="block0"$class_block0>なし(解除)</label>
		<input type="radio" name="block" value="3" id="block3"$checked_block3> <label for="block3"$class_block3>アカウント関連</label>
		<input type="radio" name="block" value="1" id="block1"$checked_block1> <label for="block1"$class_block1>全コンテンツ</label>);

			if($penalty{'block'} eq "1" || $penalty{'block'} eq "2" || $main::admy_rank >= $main::master_rank){
				$input_block .= qq(
				<input type="radio" name="block" value="2" id="block2"$checked_block2> <label for="block2"$class_block2>全コンテンツ（質問板/削除板を含む）</label>
				);
			}

		# 制限回避
		my($checked_exclusion_block,$class_exclusion_block);
			if($penalty{'exclusion_block'}){
				$checked_exclusion_block = $main::checked;
				$class_exclusion_block .= qq( blue bold);
		}

	$exclusion_line .= $html->input("checkbox","must_compare_xip_flag",1,{ checked => $penalty{'must_compare_xip_flag'} , text => "IPを必ず参照する" });


		if($type !~ /Isp-view/){
			$exclusion_line .= qq(<input type="checkbox" name="exclusion_block" id="exclusion_block" value="1"$checked_exclusion_block> <label for="exclusion_block" class="$class_exclusion_block">投稿制限を回避する</label>);
		}



		# アカウント作成のみ制限
		my($checked_block_make_account,$class_block_make_account);
			if($penalty{'concept'} =~ /Block-make-account/){
				$checked_block_make_account = $main::checked;
				$class_block_make_account .= qq( red bold);
			}
		$exclusion_line .= qq(<input type="checkbox" name="block_make_account" id="block_make_account" value="1"$checked_block_make_account> <label for="block_make_account" class="$class_block_make_account">アカウントの作成を制限</label>);

		my $checked_block_report = $parts->{'checked'} if $penalty{'block_report'};
		my $block_report_time = time + 3*24*60*60;
		$block_report_line .= qq(<label><input type="checkbox" name="block_report_time" value="$block_report_time">違反報告をしばらく禁止</label>);
			if(time < $penalty{'block_report_time'}){
				$block_report_line .= qq(<label><input type="checkbox" name="block_report_time" value="0">違反報告禁止を解除</label>);
			}

		if($main::admy{'master_flag'}){
				$user_agent_match_line .= qq( UAマッチ <input type="text" name="user_agent_match_for_block_push" value=""> );
				$user_agent_match_line .= qq( <label>(<input type="checkbox" name="user_agent_match_for_block_delete" value="1">削除)</label> (ひとつでも指定した場合、UAがマッチしない場合は投稿制限されません)　);
		}

		$input_block .= qq(
		　
		<select name="reason" style="background:#ff0;">$select</select>
		$select_blocktime
		</div>
		$block_bbs_input
		$user_agent_match_line
		$exclusion_line
		$block_report_line
		$allow_host_line
		<div>
		　<input type="submit" value="この内容で実行する">);

			# かんたん投稿制限
			if($main::admy_rank >= $main::master_rank){
				$input_block .= qq(　　<input type="submit" name="3_month_block" value="3ヶ月間 投稿制限" style="background:#fcc;">);
			}


		$input_block .= qq(</div><span class="guide">$okaddr_link</div>);



	}


#		<input type="checkbox" name="redirect" value="1" id="other_server_same" checked>
#		<label for="other_server_same">他のサーバーでも同様に設定</label>

# ファイル名でコード
my $dec_file = $in{'file'};

# 表示調整
my $view_blocker = qq( ($penalty{'block_decide_man'}) ) if($penalty{'block_decide_man'});

# データ内容を定義
# $lefttime ?
my $text .= qq(
<div class="penalty_data">
<table style="width:auto";>
<tr><td class="left">ペナルティ</td><td> <strong class="red">$left_penalty_date</strong> </td></tr>
<tr><td>削除回数</td><td><strong class="red">最近 $penalty{'count'}回 / 全体 $penalty{'allcount'}回</strong></td></tr>
</table>
</div>
);

$text .= qq(<div class="block_data">);
$text .= qq(<table style="width:auto";>);
$text .= qq(<tr><td class="left">投稿制限</td>);
$text .= qq(<td><strong class="red">);
	if($penalty{'block'} eq "1"){ $text .= qq(サイト全体); }
	if($penalty{'block'} eq "2"){ $text .= qq(サイト全体（強）); }
	if($penalty{'block'} eq "3"){ $text .= qq(アカウント); }
$text .= qq(</strong>);
	if($penalty{'block_count'}){ $text .= qq( \($penalty{'block_count'}回目\)); }
$text .= qq(</td>);
$text .= qq(</tr>\n);

# ローカル制限
$text .= qq(<tr><td>個別制限</td>);
	if($penalty{'block_bbs'} && $penalty{'Flag'}->{'some_block'}){ $text .= qq(<td><strong class="red" style="background:#fff;padding:0.2em 0.3em;border:solid 1px #f00;">$penalty{'block_bbs'}</strong></td>); }
	else{ $text .= qq(<td>なし</td>); }
$text .= qq(</tr>);


$text .= qq(<tr><td>制限の決定日</td><td> <strong class="red">$action_date $view_blocker</strong></td></tr>);

$text .= qq(<tr><td>解除日</td><td><strong class="red">$date_unblock);
	if($view_unblock){ $text .= qq( \($view_unblock\) ); }
$text .= qq(</strong></td></tr>);

$text .= qq(<tr><td>制限理由</td><td><strong class="red">$reason</strong></td></tr>);

$text .= qq(<tr><td>UAマッチ</td><td>);
	foreach(@{$penalty{'user_agent_match_for_block'}}){
		$text .= qq(<strong class="green">$_</strong> / );
	}
$text .= qq(</td></tr>);

	if($penalty{'block_report_time'} >= time){
		my($howlong) = shift_jis(Mebius::second_to_howlong($penalty{'block_report_time'} - time));
		$text .= qq(<tr><td>違反報告の制限</td><td> <strong class="red">).e($howlong).qq(</strong></td></tr>);
	}

$text .= qq(</table></div>);

	# ●前回の削除内容
	if($penalty{'index_line'}){
		my($deleted_hitory) = Mebius::Fixurl("Normal-to-admin",$penalty{'index_line'});
		$text .= qq(<div class="before_deleted"><h3>削除履歴</h3>$deleted_hitory</div>);
	}


# ファイルがない場合
if($penalty{'file_nothing_flag'}){ $text = qq(<div class="nodata">管理履歴はありません。</div>); }

# セーブデータを取得
#my($savedata_line) = &get_savedata($in{'file'});
my($savedata_line);

	# 表示を調整
	if($in{'filetype'} eq "account"){
		# ログイン履歴を取得
		require "${init_directory}part_idcheck.pl";
			($login_hisory_line) = Mebius::Login->login_history("Index Admin",$file);
	}

	# ●投稿履歴を取得
	($none,$none,$reshistory_line,undef,%history) = Mebius::history({ Type => "Admin INDEX Get-hash THREAD Open-view Not-renew-status" , FileTypeQuery => $in{'filetype'} },$in{'file'});


	# 投稿履歴の整形
	if($history{'f'}){

		# 局所化
		my($how_block_make_account,$first_time,$make_accounts_line,$form);

		# 管理用にURLを修正
		($reshistory_line) = Mebius::Adfix("Url",$reshistory_line);

		# フォーム
		if($main::admy{'master_flag'}){
			$form .= qq(<form action="" method="post" style="margin:1em 0em;padding:0.5em 1em;background:#5d5;"><div>);
			$form .= qq(<input type="hidden" name="mode" value="cdl">);
			$form .= qq(<input type="hidden" name="type" value="control_all_res_from_history">);
			$form .= qq(<input type="hidden" name="filetype" value="$main::in{'filetype'}">);
			$form .= qq(<input type="hidden" name="file" value="$main::in{'file'}">);
			$form .= qq(<p>本文： );
			$form .= qq(<label><input type="radio" name="comment_control_type" value="">未選択</label>);
			$form .= qq(<label><input type="radio" name="comment_control_type" value="delete">削除</label>);
			$form .= qq(<label class="blue"><input type="radio" name="comment_control_type" value="revive">復活</label>);
			$form .= qq(<label class="red"><input type="checkbox" name="penalty" value="1">ペナルティ</label>);
			$form .= qq(<p>筆名： );
			$form .= qq(<label><input type="radio" name="handle_control_type" value="">未選択</label>);
			$form .= qq(<label><input type="radio" name="handle_control_type" value="delete">削除</label>);
			$form .= qq(<label class="blue"><input type="radio" name="handle_control_type" value="revive">復活</label>);
			$form .= qq(<p><input type="submit" value="この投稿履歴のすべてのレスを操作">);
			$form .= qq(</div></form>);
		}

			# アカウント作成可能時間
			if($history{'make_account_blocktime'}){
				($how_block_make_account) = Mebius::SplitTime(undef,$history{'make_account_blocktime'} - $main::time);
				$how_block_make_account = qq( ┃ 次回のアカウント作成可\能\時間： $how_block_make_account \($history{'make_account_blocktime'}\) );
			}

			my($how_before_renew_status) = Mebius::SplitTime(undef,$main::time - $history{'last_renew_status_time'});
			$how_before_renew_status = qq( ┃ 前回の状況更新： $how_before_renew_status);

			# アカウント作成履歴
			if($history{'make_accounts'}){
					foreach(split/\s/,$history{'make_accounts'}){
						$make_accounts_line .= qq(<a href="${main::auth_url}$_/">$_</a>);
					}
					$make_accounts_line = qq( ┃ 作成アカウント $make_accounts_line);
			}

		my(%first_time) = Mebius::Getdate("Get-hash",$history{'firsttime'});

		# 初記録日時
		my($first_date) = Mebius::Getdate(undef,$history{'first_time'}) if($history{'first_time'});
		$reshistory_line = qq(<div class="reshistory"><h2 id="HISTORY" style="display:inline;">投稿履歴</h2>)
		. qq( <strong>( $first_date 記録開始 )</strong><br>$reshistory_line <div>初記録： $first_date $make_accounts_line $how_block_make_account $how_before_renew_status</div></div>);

		# 投稿履歴からの削除フォーム
		$reshistory_line .= qq($form);

		# 削除リンク選択
		require Mebius::Reason;
	#	my($reason_select_line) = shift_jis(Mebius::Reason::res_control_box_full_set({},$main::in{'comment_control'}));
	#	$reshistory_line .= qq(<form action="">);
	#	$reshistory_line .= qq(<input type="hidden" name="mode" value="$main::mode"$main::xclose>);
	#	$reshistory_line .= qq(<input type="hidden" name="file" value="$main::in{'file'}"$main::xclose>);
	#	$reshistory_line .= qq(<input type="hidden" name="filetype" value="$main::in{'filetype'}"$main::xclose>);
	#	$reshistory_line .= qq($main::backurl_input);
	#	$reshistory_line .= qq(<div>$reason_select_line</div>);
	#	$reshistory_line .= qq(<input type="submit" value="「投稿回数」のリンク先に移動した時の削除理由を選択"$main::xclose>);
	#	$reshistory_line .= qq(</form>);
	}

$other_history_line .= &histories_return_cdl_admin("Cookie-history",$history{'cnumbers'},$file);
$other_history_line .= &histories_return_cdl_admin("Host-history",$history{'hosts'},$file);
$other_history_line .= &histories_return_cdl_admin("Account-history",$history{'accounts'},$file);
	if($main::admy_rank >= $main::master_rank){
		$other_history_line .= &histories_return_cdl_admin("Agent-history",$history{'agents'},$file);
	}

# 筆名記録のトリップを非表示にする
my($handles);
	foreach(split(/\s/,$history{'names'})){
		my($name_decoded) = Mebius::Decode(undef,$_);
		my($handle,$trip_material) = split(/#/,$name_decoded);
		$handles .= qq( $handle);
	}
$other_history_line .= histories_return_cdl_admin("Handle-history",$handles,$file);

	# 筆名
	if($history{'names'}){
		$other_history_line .= qq(　┃筆名 ： );
		foreach my $foreach (split(/\s/,$history{'names'})){
			my($file_decoded) = Mebius::Decode(undef,$foreach);
			my($handle2) = split(/#/,$file_decoded);
			$other_history_line .= qq( $handle2);
		}
	}

	# ID
	if($history{'encids'}){
		$other_history_line .= qq(　┃ID ： );
		foreach my $foreach (split(/\s/,$history{'encids'})){
			my($file_encoded) = Mebius::Encode(undef,$foreach);
			if($foreach eq $file){ $other_history_line .= qq( ★$foreach); }
			else{ $other_history_line .= qq(<i>★$foreach</i>); }
		}
	}

	# 全体の表示整形
	if($other_history_line){
		$other_history_line = qq(<div class="other_history">$other_history_line</div>);
	}

	# DOS判定ファイルを取得
	if($in{'filetype'} =~ /^(addr|host)$/ && $main::admy_rank >= $main::master_rank){

		# DOS判定ファイル２種を取得
		my(%dos_flow) = Mebius::Dos::FlowFile("Get-hash Get-alert",$file);
		my(%dos) = Mebius::Dos::AccessFile("Get-hash",$dos_flow{'addr'});

			# DOS判定ファイルが存在する場合
			if($dos_flow{'f'}){
				$dos_line .= qq(<h2>DOS判定</h2>);
				$dos_line .= qq(<div style="background:ddd;margin:1em 0em;padding:0.5em;">);
				$dos_line .= qq(DOS判定： $dos{'dos_count'}<br$main::xclose>);
				$dos_line .= qq(Dos-Key: [ $dos{'key'} ]<br$main::xclose>);
				$dos_line .= qq(<input type="checkbox" name="dos_file_delete" value="1" id="dos_file_delete">\n);
				$dos_line .= qq(<label for="dos_file_delete">DOSファイルを削除</label><br$main::xclose>\n);

				$dos_line .= qq(<input type="hidden" name="dos_host_or_addr" value="$file">\n);
				$dos_line .= qq(<input type="hidden" name="dos_addr" value="$dos_flow{'addr'}">\n);
				#$dos_line .= qq(Alert $dos{'dos_alert_flag'} CGI-Error $dos{'dos_flow_flag'} \n);
				$dos_line .= qq(\n);
				$dos_line .= qq(<pre style="word-wrap:break-word;">$dos_flow{'access_log'}</pre>\n);
				$dos_line .= qq(\n);
				$dos_line .= qq(</div>);
			}
	}

	# Who is フレーム
	if($main::in{'filetype'} eq "addr"){
		$whois_line = qq(<h2 id="WHOIS">Who is 情報</h2><div><iframe src="http://whois.nic.ad.jp/cgi-bin/whois_gw?type=&key=$main::in{'file'}&lang=" style="width:80%;height:400px;" frameborder="0"></iframe></div>);
	}


my($allreset_button);
if($admy_rank >= $master_rank){ $allreset_button = qq(<input type="submit" value="このメンバーの「すべての削除回数」をなくす" name="allreset"$disabled_reset>); }

	# アカウントへのリンク
	if($main::in{'filetype'} eq "account"){
		$account_link = qq(<div>アカウント： <a href="${main::auth_url}$main::in{'file'}/">$main::in{'file'}</a></div>);
	}

# HTML
my $print .= qq(<a href="$home">ＴＯＰに戻る</a>);
# $print .= qq($back_bbs $back_page);
$print .= qq(
<h1>管理番号 <span class="red">$dec_file</span> <span style="color:#080;">( $plustype_adevice )</span> - $server_domain $account_link</h1>
<form action="" method="post">
<div style="line-height:1.4em">
$input_block
$domain_links
$other_history_line
$text
<br><span style="color:#f00;font-size:90%;">＊レスの制限時間は、このメンバーが次に投稿したタイミングで加算されます。</span><br>
<span style="color:#f00;font-size:90%;">＊間違ってペナルティを与えてしまったときなどには、次のボタンを押してください。</span><br><br>
<input type="submit" value="このメンバーの「待ち時間」「最近の削除回数」をなくす" name="reset"$disabled_reset>
$allreset_button
<input type="hidden" name="change" value="1">
<input type="hidden" name="mode" value="cdl">);

$print .= qq(<input type="hidden" name="adfile" value=") . Escape::HTML([$admy_file]) . qq(">\n);
$print .= qq(<input type="hidden" name="filetype" value=") . Escape::HTML([$main::in{'filetype'}]) . qq(">\n);
$print .= qq(<input type="hidden" name="file" value=") . Escape::HTML([$main::in{'file'}]) . qq(">\n);
#$print .= qq(<input type="hidden" name="referer" value=") . &Escape::HTML([$referer_link]) . qq(">\n);

	# 削除回数の変更
	if($main::admy{'master_flag'}){
		$print .= qq(<br><br>最近の削除回数： <input type="text" name="count" value=") . Escape::HTML([$penalty{'count'}]) . qq(">);
		$print .= qq(<br>すべての削除回数： <input type="text" name="allcount" value=") . Escape::HTML([$penalty{'allcount'}]) . qq(">);
		$print .= qq(<br> <input type="submit" name="count_change" value="指定の回数にする">);
	}


$print .= qq(
</div>
</form>

$savedata_line
$reshistory_line
<h2>アクセス履歴</h2>
$login_hisory_line
$dos_line
$whois_line
);

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# 投稿履歴から全てのレスを削除する
#-----------------------------------------------------------
sub control_all_res_from_history{

# 宣言
my($use) = @_;
my($history,$line,$res_control_reason,$comment_control_type,$handle_control_type,$penalty_flag);
my $move = new Mebius::Move;
our($del_text,$admy_name);

# アクセス制限
main::axscheck("Post-only");

# 権限チェック
	if(!$main::admy{'master_flag'}){ main::error("権限がありません。"); }

# 定義
my $query = \%main::in;
my $query_escaped = \%main::in;

	# 削除理由
	if($query->{'delete_reason'}){
		$res_control_reason = $query->{'control_reason'};
	}

	# 実行タイプ ( 本文の操作 )
	if($query->{'comment_control_type'} =~ /^(delete|revive)$/){
		$comment_control_type = $1;
	}

	# 実行タイプ (筆名の操作 )
	if($query->{'handle_control_type'} =~ /^(delete|revive)$/){
		$handle_control_type = $1;
	}

	# ペナルティ
	if($query->{'penalty'}){
		$penalty_flag = 1;
	}

# 投稿履歴からデータを取得
my($history) = Mebius::history({ Type => "GetAllThreadAndRes GetReference" , FileTypeQuery => $query_escaped->{'filetype'} },$query_escaped->{'file'});

	# 投稿履歴の全掲示板 を展開
	foreach my $bbs_name ( keys %{$history->{'AllRegist'}} ){

			# 全記事を展開
			foreach my $thread_number ( keys %{$history->{'AllRegist'}{$bbs_name}} ){

				# 局所化
				my(%res_control,@res_numbers);

					# 全レスを展開
					foreach my $res_number ( keys %{$history->{'AllRegist'}{$bbs_name}{$thread_number}} ){

						$res_control{$res_number}{'comment'}{'reason'} = $res_control_reason;
						$res_control{$res_number}{'comment'}{'type'} = $comment_control_type;
						$res_control{$res_number}{'handle'}{'type'} = $handle_control_type;
						$res_control{$res_number}{'penalty_flag'} = $penalty_flag;
						push(@res_numbers,$res_number);
					}
					
				# 全レスを操作 ( 削除や復活を実行 )
				my($control_successed_flag) = Mebius::Admin::thread_control_core({ control => \%res_control , MyDeletedMessage => $del_text , MyHandle => $admy_name },$bbs_name,$thread_number);
				my $res_numbers_join = join "-" , @res_numbers;
					if($control_successed_flag){
						$line .= qq( $bbs_name - $thread_number - $res_numbers_join を操作(削除や復活)しました。<br>);
					}
					else{
						$line .= qq( $bbs_name - $thread_number - $res_numbers_join は操作しませんでした。<br>);
					}
			}
	}

$move->redirect_to_self_url();
exit;

main::error("$line");
#main::error("$history->{'first_time'}");
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub histories_return_cdl_admin{

# 宣言
my($type,$histories,$file) = @_;
my($line,$foreach,$plustype_get_history,$filetype);
my $query = new CGI;

	# リターン
	if(!$histories){ return(); }

	# Cookieの場合
	if($type =~ /Cookie-history/){
		$line .= qq(クッキー ： );
		$plustype_get_history .= qq( CNUMBER);
		$filetype = "number";
	}
	elsif($type =~ /Host-history/){
		$line .= qq(　┃ ホスト ： );
		$plustype_get_history .= qq( HOST);
		$filetype = "host";
	}
	elsif($type =~ /Agent-history/){
		$line .= qq(　┃ UA ： );
		$plustype_get_history .= qq( KACCESS_ONE);
		$filetype = "agent";
	}
	elsif($type =~ /Handle-history/){
		$line .= qq(　┃ 筆名 ： );
		$plustype_get_history .= qq( HANDLE);
		$filetype = "handle";
	}
	elsif($type =~ /Account-history/){
		$line .= qq(　┃ アカウント ： );
		$plustype_get_history .= qq( ACCOUNT);
		$filetype = "account";
	}

	# 展開
	foreach $foreach (split(/\s/,$histories)){

		# 局所化
		my($file_encoded,%history2);

			# UAの場合は、最初からエンコードされている
			if($type =~ /Agent-history/){
				$file_encoded = $foreach;
				($foreach) = Mebius::Decode(undef,$foreach);
					if($query->param('view_detail')){
						(%history2) = &get_reshistory("Admin KACCESS_ONE Get-hash-detail",$foreach);
					}
			}

			# 筆名
			elsif($type =~ /Handle-history/){
				$file_encoded = $foreach;
					if($query->param('view_detail')){
						(%history2) = &get_reshistory("Admin Get-hash-detail $plustype_get_history",$foreach);
					}
				($foreach) = Mebius::Decode(undef,$foreach);
			}

			# UA以外の場合
			else{
				($file_encoded) = Mebius::Encode(undef,$foreach);
					if($query->param('view_detail')){
						(%history2) = &get_reshistory("Admin Get-hash-detail $plustype_get_history",$foreach);
					}
			}

			# ホストを暗号化する場合 ( リーダー以下 )
			if($type =~ /Host-history/ && $main::admy_rank < $main::master_rank){
				my($file_crypted) = Mebius::Crypt::crypt_text("MD5",$foreach,"Dl");
				$line .= qq( <span class="red">$file_crypted</span>);
			}
			elsif($foreach eq $file){ $line .= qq( $foreach); }
			# リンクを表示
			else{
				$line .= qq( <a href="${main::main_url}?mode=cdl&amp;file=$file_encoded&amp;filetype=$filetype" class="manage">$foreach);
					if($history2{'other_counts'}){ $line .= qq(($history2{'other_counts'})); }
				$line .= qq(</a> );
			}
	}

return($line);

}

no strict;

use CGI;

#-----------------------------------------------------------
# 投稿制限、レス制限時間の操作
#-----------------------------------------------------------
sub change{

# 局所化
my($basic_init) = Mebius::basic_init();
my($type,$plustype_penalty) = @_;
my($top,$line,@d_invite,%renew);
my($my_admin) = Mebius::my_admin();
my($param) = Mebius::query_single_param();
my $query = new CGI;

	# 汚染チェック
	if($in{'reason'} =~ /\D/){ main::error("指定が変です。"); }
	if($in{'block_time'} =~ /[^\w\-]/){ main::error("指定が変です。"); }
	if($in{'count'} =~ /[^\d\-]/){ main::error("指定が変です。"); }
	if($in{'allcount'} =~ /[^\d\-]/){ main::error("指定が変です。"); }

	# 制限ファイルを取得
	my(%penalty) = Mebius::penalty_file("Get-hash $plustype_penalty",$main::in{'file'});

	# コンセプトキー
	$renew{'concept'} = $penalty{'concept'};

	# 削除カウントとペナルティ時間のリセット
	if($in{'reset'}){
		$renew{'count'} = 0;
		$renew{'penalty_time'} = 0;
	}

	# 削除カウントと全削除カウントとペナルティ時間のリセット
	if($in{'allreset'} && $my_admin->{'master_flag'}){
		$renew{'count'} = 0;
		$renew{'allcount'} = 0;
		$renew{'penalty_time'} = 0;
	}

	# ●投稿制限を解除する
	if($in{'block'} eq "0" && $my_admin->{'leader_flag'}){
		$renew{'block_time'} = undef;
		$renew{'block'} = 0;
		$redirect = 1;
	}

	# ●投稿制限を加える
	if(($in{'block'} || $in{'block_bbs'}) && $my_admin->{'leader_flag'}){

		# 局所化
		my($blocktime);

			# 各種エラー
			if(!$in{'reason'}){ main::error("制限理由を選んでください。"); }
			if($in{'block'} !~ /^\d$/){ main::error("制限タイプを選んでください。"); }

			# 制限データ
			$renew{'block'} = $in{'block'};
			$renew{'block_decide_man'} = $main::admy_name;
			$renew{'block_reason'} = $in{'reason'};

				# 解除日
				if($in{'block_time'} eq "forever"){ $renew{'block_time'} = ""; }
				elsif($in{'block_time'} eq "not_change"){ $renew{'block_time'} = $penalty{'block_time'}; }
				elsif($in{'block_time'} =~ /^([0-9]+)$/){ $renew{'block_time'} = $in{'block_time'}; }
				else{ main::error("解除日を指定してください。"); }

		$redirect = 1;
	}

	# ● 違反報告の禁止
	if($param->{'block_report_time'} =~ /^[0-9]+$/){
			$renew{'block_report_time'} = $param->{'block_report_time'};
			$redirect = 1;
	}

	# かんたん投稿制限
	if($my_admin->{'leader_flag'}){


			if($main::in{'3_month_block'}){

				$renew{'block_time'} = time + (90*24*60*60);
				$renew{'block'} = 1;
				$renew{'block_reason'} = 7;
				$renew{'block_decide_man'} = $main::admy_name;

			}

		$redirect = 1;

	}


	# 新しい制限の場合は、制限時間/制限回数カウントを変更する
	if($renew{'block'} && !$penalty{'block_time_flag'}){
		$renew{'block_decide_time'} = $main::time;
		$renew{'+'}{'block_count'} = 1;
	}


	# ホスト名の許可
	if($my_admin->{'master_flag'} && exists $main::in{'allow_host'}){
		$renew{'allow_host'} = $main::in{'allow_host'};
	}

	# ●個別掲示板の制限
	if($my_admin->{'leader_flag'}){
		$in{'block_bbs'} =~ s/　/ /g;
			if($in{'block_bbs'} =~ /([^a-zA-Z0-9 ])/){ &error("個別制限の欄に使えない文字列が使われています。"); }
		$renew{'block_bbs'} = $in{'block_bbs'};
		$redirect = 1;
	}

	# 投稿制限の回避
	if($my_admin->{'leader_flag'}){
			if($in{'exclusion_block'}){ $renew{'exclusion_block'} = "1"; }
			else{ $renew{'exclusion_block'} = ""; }
			if($in{'must_compare_xip_flag'}){ $renew{'must_compare_xip_flag'} = "1"; }
			else{ $renew{'must_compare_xip_flag'} = ""; }
	}



	# アカウント作成の制限
	if($my_admin->{'leader_flag'}){

		$renew{'concept'} =~ s/(\s)?Block-make-account//g;
			if($in{'block_make_account'}){ $renew{'concept'} .= qq( Block-make-account); }
	}


	# 削除回数を、指定の回数に変更
	if($in{'count_change'}){
		$count = $in{'count'};
		$allcount = $in{'allcount'};
		$redirect = 0;
	}

	# UAマッチ
	if($in{'user_agent_match_for_block_delete'}){
		$renew{'user_agent_match_for_block'} = [];
	}
	elsif(exists $in{'user_agent_match_for_block_push'}){
		$renew{'push'}{'user_agent_match_for_block'} = $in{'user_agent_match_for_block_push'};
	}

	# Debug
	if(Mebius::alocal_judge() && 1 == 0){

		#$renew{'push:user_agent_match_for_block'} = ["FireFox","Chrome"];
		$renew{'user_agent_match_for_block'} = [1,2,3];
		$renew{'push'}{'user_agent_match_for_block'} = "b";
		$renew{'unshift'}{'user_agent_match_for_block'} = "a";

		#$renew{'shift'}{'user_agent_match_for_block'} = 2;
		#$renew{'pop'}{'user_agent_match_for_block'} = 2;

		#$renew{'user_agent_match_for_block'}{'push'} = "d";
		$renew{'.'}{'concept'} = " ABC";
		$renew{'s/g'}{'concept'} = " ABC";
		$renew{'count'} = "13";

		#$renew{'+'}{'concept'} = "ABC";

		#$renew{'s///g'}{'concept'} = "ABC";
	
		#$renew{'push:user_agent_match_for_block'} = "IE";
		$renew{'unshift'}{'user_agent_match_for_block'} = "Chrome\n";
		$renew{'user_agent_match_for_block'}[4] = "Yes\n";
		#$renew{'user_agent_match_for_block'}[0] = "";
	}


	# ファイルを更新

	Mebius::penalty_file("Renew-hash $plustype_penalty Test",$main::in{'file'},%renew);

	# DOSファイルの削除
	if($my_admin->{'master_flag'} && $main::in{'dos_file_delete'}){

			# DOS判定ファイルを取得
			if($in{'filetype'} =~ /^(addr|host)$/){

				# DOS関連ファイルを削除
				Mebius::Dos::FlowFile("Delete-file",$main::in{'dos_host_or_addr'});
				Mebius::Dos::AccessFile("Delete-file",$main::in{'dos_addr'});
				Mebius::Dos::HtaccessFile("Delete-addr Renew",$main::in{'dos_addr'});

			}

	}

	# リダイレクト先のドメイン
	my($domain);
	if($server_domain eq "aurasoul.mb2.jp"){ $domain = "mb2.jp"; }
	else{ $domain = "aurasoul.mb2.jp"; }

# ファイル名エンコード
my($file_encoded) = Mebius::Encode(undef,$in{'file'});

	# 他のサーバーへリダイレクト(１)
	#if($redirect && $in{'redirect'} && !$in{'redirected'} && !Mebius::alocal_judge()){
	#	Mebius::Redirect("","$basic_init->{'admin_http'}://$domain/jak/$script?$postbuf&redirected=1");
	#}
	# 元サーバーへのリダイレクト
	#else{
	#		if(Mebius::alocal_judge()){
	#			Mebius::Redirect("","$script?mode=cdl&file=$file_encoded&filetype=$in{'filetype'}&referer=$encref_link"); 
	#		}
	#		else{
	#	Mebius::Redirect("","$basic_init->{'admin_http'}://$domain/jak/$script?mode=cdl&file=$file_encoded&filetype=$in{'filetype'}&referer=$encref_link");
	#		}
	#}

Mebius::redirect("$script?mode=cdl&file=$file_encoded&filetype=$in{'filetype'}&referer=$encref_link");
exit;

}

#-----------------------------------------------------------
# セーブデータの内容を取得、変更
#-----------------------------------------------------------
sub get_savedata{

# 局所化
my($init_directory) = Mebius::BaseInitDirectory();
my($line,$type,$flag);

# リターン
if($admy_rank < $leader_rank){ return; }

# ファイル定義
my($file) = @_;
$file =~ s/\.\.//g;
$file =~ s/^([\/]+)//g;

	# アカウントの場合
	if($file =~ /^([0-9a-z]+)$/ && $in{'filetype'} =~ /ACCOUNT/i){
		$file = $file;
		$type = "ACCOUNT";
		$k_access = "";
		$flag = 1;
	}

	# 携帯端末の場合
	my($adevice_type,$select_dir,$k_access,$kaccess_one) = &adevice("",$file);
	if($adevice_type eq "kaccess_one"){
		$file = $kaccess_one;
		$type = "MOBILE";
		$k_access = $k_access;
		$flag = 1;
	}

# リターン
if(!$flag){ return; }


# セーブデータを取り込み
require "${init_directory}part_idcheck.pl";

my($top,$nam,$gold,$soutoukou,$soumoji,$email,$follow,$up,$pre,$color,$old,$posted,$news,$fontsize,$cut,$secret,$account,$pass) = Mebius::save_data($file,$type,$k_access);
my($handle) = split(/#/,$nam);


# ファイルがない場合
if($top eq ""){ return; }

# HTML
$line = qq(
<form action="$mainscript">
<div class="savedata">
セーブデータ ( $type ) ：<br><br>
<input type="hidden" name="mode" value="cdl">
<input type="hidden" name="file" value="$in{'file'}">
<input type="hidden" name="filetype" value="$type">
<input type="hidden" name="type" value="push_savedata">
筆名： $handle<br>
金貨： <input type="text" name="gold" value="$gold"><br>
投稿回数： <input type="text" name="soutoukou" value="$soutoukou"><br>
総文字数： <input type="text" name="soumoji" value="$soumoji"><br>
);

# 詳しいデータ
if($admy_rank >= $master_rank){ $line .= qq(<br>$top<br><br>); }

	# アカウントへのリンク
	if($type eq "ACCOUNT"){
		$line .= qq(アカウント： <a href="${auth_url}$file/">$file</a><br>);
	}
	if($type eq "MOBILE" && $account){
		$line .= qq(アカウント： <a href="${auth_url}$account/">$account</a> <a href="$mainscript?mode=cdl&amp;file=$account&amp;filetype=account">データ</a><br>);
	}

$line .= qq(
<input type="submit" value="この内容で変更する">
</form></div>);


	# 内容の変更処理
	if($in{'type'} eq "push_savedata"){
		$gold = $in{'gold'};
		$soutoukou = $in{'soutoukou'};
		$soumoji = $in{'soumoji'};
		$gold =~ s/[^0-9\-]//g;
		$soutoukou =~ s/\D//g;
		$soumoji =~ s/\D//g;
		my($file_encoded) = Mebius::Encode(undef,$in{'file'});
	&push_savedata($file,$type,$k_access,$nam,$posted,$pwd,$color,$up,$pre,$new_time,$res_time,$gold,$soumoji,$soutoukou,$fontsize,$follow,$view,$number,$rireki,$cut,$memo_time,$account,$pass,$delres,$news,$old,$email,$secret);
		Mebius::Redirect("","$mainscript?mode=cdl&file=$file_encoded&filetype=$type");
	}

# リターン
return($line);

}


#● IPアドレスの管理-----------------------------------------------------------


#-----------------------------------------------------------
# モード振り分けとファイル定義
#-----------------------------------------------------------
sub start_admin_control_ip{


# 局所化
my($file,$top,$none_flag,$line);

# モードエラー
if($admy_rank < $master_rank){ &error("設定権限がありません。"); }

# ファイル定義
$file = $in{'file'};
$file =~ s/-MebiHost//g;
#$file =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
#$file =~ tr/ /+/;
if($file eq ""){ &error("表\示できません。"); }

# モード振り分け
if($in{'type'} eq "edit"){ admin_control_ip_change($file); }
else{ admin_control_ip_view(); }

# 処理終了
exit;

}

#-----------------------------------------------------------
# 表示画面
#-----------------------------------------------------------

sub admin_control_ip_view{

# 局所化
my($invited_flag,$how_before_gethostbyaddr);

# CSS定義
$css_text .= qq(
table,th,tr,td{border-style:none;}
table{width:60%;margin-top:0.5em;padding:1em;}
h1{line-height:1.3;}
td{padding:0.3em 0.2em;}
li{line-height:1.6;}
div.before_deleted{background-color:#ff9;padding:1em;margin:1em 0em;}
div.nodata{margin:1em 0em;padding:1em;background-color:#ccc;}
table.datas{background-color:#cee;}
td.left{width:20em;}
th{display:none;}
.domain_links{color:#080;font-size:140%;margin:1em 0em;font-style:oblique;}
.block{padding:0em 1.0em;}
);

# 閲覧権限
if(!$main::admy{'master_flag'}){ main::error("閲覧権限がありません。"); }

# データがない場合
my($addr) = Mebius::Host::select_addr_data_from_main_table($in{'file'});
#my($addr) = Mebius::AddrFile(undef,$in{'file'});

#if(!$addr->{'f'}){ $none_flag = 1; }

# 戻りリンク
$referer_link = $referer;
if($in{'referer'}){ $referer_link = $in{'referer'}; }

$encref_link = $referer_link;
$encref_link =~ s/&amp;/&/g;
$encref_link =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
$encref_link =~ tr/ /+/;

	if($addr->{'allow_flag'} eq "0"){
		$css_text .= qq(
		table.datas{background-color:#fdd;}
		);
	}

# ドメイン切り替えリンク
{ my($i);
foreach(@domains){
$i++;
if($i >= 2){ $domain_links .= qq( - ); }
if($_ eq $server_domain){ $domain_links .= qq( $_ ); }
else{ $domain_links .= qq( <a href="http://$_/jak/index.cgi?mode=cda&amp;file=$file&amp;referer=$encref_link">$_</a> ); }
}
$domain_links = qq(<div class="domain_links">ドメイン： $domain_links</div>);
}

# リンク先定義
my $baseurl = "http://mb2.jp/jak/" if(!$alocal_mode);

$input_block = qq(
<div class="block">
<input type="submit" name="unblock" value="許可する">
<input type="submit" name="block" value="拒否する">
<input type="checkbox" name="redirect" value="1" checked> リダイレクト（ 他のサーバーでも同様に設定 ）
</div>
);


# ファイル名でコード
my $dec_file = $in{'file'};

# 戻り先リンク
my $referer_bbs = $referer_link;
$referer_bbs =~ s/\?(.+)//g;
my $back_bbs = qq(<a href="$referer_bbs">コンテンツＴＯＰへ</a>) if($referer_link);
my $back_page = qq(<a href="$referer_link">元ページに戻る</a>) if($referer_link);

	# 前回の Who is 取得日付
	if($addr->{'last_get_whois_time'}){
		($get_whois_date) = Mebius::get_date($addr->{'last_get_whois_time'});
		($how_before_get_whois) = Mebius::SplitTime("Get-top-unit Plus-text-前",time - $addr->{'last_get_whois_time'});
	}
	# 前回の gethostbyaddr
	if($addr->{'last_gethostbyaddr_time'}){
		($gethostbyaddr_date) = Mebius::get_date($addr->{'last_gethostbyaddr_time'});
		($how_before_gethostbyaddr) = Mebius::SplitTime("Get-top-unit Plus-text-前",time - $addr->{'last_gethostbyaddr_time'});
	}


# 逆引き
my($gethostbyaddr_realtime) = Mebius::GetHostByAddr({ Addr => $main::in{'file'} });

# 逆引きと記録を実行
#Mebius::GetHostSelect({ TypeWithFile = 1 , Addr => $main::in{'file'});

# データ内容を定義
my $text = qq(
<table class="datas">
<tr><th>項目</th><th>数値</th></tr>
<tr><td class="left">手動許可</td><td>$addr->{'allow_key'}</td></tr>
<tr><td class="left">前回の Who is 取得</td><td>$how_before_get_whois ( $get_whois_date->{'date_till_minute'} )</td></tr>
<tr><td class="left">前回の 逆引き</td><td>$how_before_gethostbyaddr ( $gethostbyaddr_date->{'date_till_minute'} )</td></tr>
<tr><td class="left">記録された REMOTE_HOST ( gethostbyaddr )</td><td>$addr->{'gethostbyaddr'}</td></tr>
<tr><td class="left">記録された gethostbyname</td><td>$addr->{'gethostbyname'}</td></tr>
<tr><td class="left">現在の REMOTE_HOST ( gethostbyaddr )</td><td>$gethostbyaddr_realtime</td></tr>
</table>
);

# ファイルがない場合
if($none_flag){ $text = qq(<div class="nodata">管理履歴はありません。</div>); }



# HTML
my $print = <<"EOM";
<a href="$home">ＴＯＰに戻る</a>
$back_bbs
$back_page

<h1>IPアドレス管理 <span class="red">$dec_file</span> - $server_domain</h1>

<form action="$script" method="POST">
<div style="line-height:1.4em">
$input_block
$domain_links
$text
<input type="hidden" name="type" value="edit">
<input type="hidden" name="mode" value="cda">
<input type="hidden" name="file" value="$in{'file'}">
<input type="hidden" name="referer" value="$referer_link">
</div>
</form>

<br><br>
<a href="http://whois.nic.ad.jp/cgi-bin/whois_gw?type=&key=$in{'file'}&lang=">Whois</a>
EOM

Mebius::Template::gzip_and_print_all({},$print);

#<iframe src="http://whois.nic.ad.jp/cgi-bin/whois_gw?type=&key=$in{'file'}&lang=" style="width:80%;height:400px;" frameborder="0"></iframe>

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub admin_control_ip_change{

# ファイル定義
my($basic_init) = Mebius::basic_init();
my($file) = @_;
my($top,$line,$newkey,%renew);

# キー定義
if($in{'block'}){ $renew{'allow_key'} = 0; }
if($in{'unblock'}){ $renew{'allow_key'} = 1; }


$renew{'addr'} = $file;

# ファイル更新
#Mebius::AddrFile({ TypeRenew => 1 },$main::in{'file'},\%renew);
Mebius::Host::update_or_insert_main_table(\%renew);

# リダイレクト先のドメイン
my($domain);
if($server_domain eq "aurasoul.mb2.jp"){ $domain = "mb2.jp"; }
else{ $domain = "aurasoul.mb2.jp"; }

# 他のサーバーへリダイレクト
my($file_encoded) = Mebius::Encode(undef,$in{'file'});
#if($in{'redirect'} && !$in{'redirected'} && !Mebius::alocal_judge()){
#Mebius::Redirect("","$basic_init->{'admin_http'}://$domain/jak/$script?$postbuf&redirected=1");
#}
#else{
	if(Mebius::alocal_judge()){ Mebius::Redirect("","$script?mode=cda&file=$file_encoded"); }
	else{ Mebius::Redirect("","$basic_init->{'admin_http'}://$domain/jak/$script?mode=cda&file=$file_encoded"); }
#}

}


#-----------------------------------------------------------
# 記事修正
#-----------------------------------------------------------

sub edit_log{

local($myjob) = @_;

# 汚染チェック
$in{'res'}  =~ s/\D//g;
$in{'no'} =~ s/\D//g;

# 処理タイプ
if($in{'job'} eq "edit2") { &edit_action; }
else{ &editform; }

exit;

}

use strict;


#-----------------------------------------------------------
# 修正実行
#-----------------------------------------------------------
sub edit_action{

# 局所化
my($before_comment,$after_comment,@new,@index);
our(%in,$i_nam,$pass,$i_nam,$nowfile,$postflag,$admy_rank,$leader_rank);
our($script,$admin_flag,$master_rank,$realmoto,$moto);

	# 権限チェック(スレッド修正)
	if($admy_rank < $leader_rank){ &error("実行権限がありません。"); }
	if($in{'res'} && $admy_rank < $master_rank){ &error("実行権限がありません。"); }

# 各種エラー
if(!$postflag){ &error("GET送信は出来ません。"); }

	# パスワードチェックなど
	#if ($in{'pass'} ne "") {
	#	$admin_flag=1;
	#		if ($in{'pass'} ne $pass) { &error("パスワードが違います"); }
	#}
	#elsif ($in{'pwd'} ne "") { $admin_flag = 0; }
	#else{ &error("不正なアクセスです"); }

	# タグオンの場合
	if($in{'tag'}){
		($in{'comment'}) = Mebius::Descape("Not-br Deny-diamond",$in{'comment'});
		Mebius::DangerTag("Error-view",$in{'comment'});
	}
	else{
		$in{'comment'} =~ s/&amp;/&/g;
	}

# URL整形
($in{'comment'}) = Mebius::Fixurl("Admin-to-normal",$in{'comment'});

# ロック開始
&lock($moto);

# 記事を開く
my(%renew_thread,%res_edit);
	if($in{'res'} eq "" || $in{'res'} eq "0") { $renew_thread{'sub'} = $in{'sub'}; }
$res_edit{$in{'res'}}{'comment'} = $in{'comment'};
$res_edit{$in{'res'}}{'handle'} = $in{'name'};
my($thread_renewed) = Mebius::BBS::thread({ ReturnRef => 1 , FileCheckError => 1 , Renew => 1 , select_renew => \%renew_thread , res_edit => \%res_edit },$realmoto,$in{'no'});


# 最終投稿者名
#my($last_nam) = (split(/<>/, $new[$#new]))[2];
#if($res2 == 0 && !$in{'res'}) { $last_nam = $i_nam; }

# インデックスを展開
#if(!$in{'res'}){
#open(IN,"$nowfile") || &error("インデックスが開けません。");
#my $top2 = <IN>;
#push(@index,$top2);
#	while (<IN>) {
#		chomp;
#		my($no,$sub,$res,$nam,$da,$na2,$key2) = split(/<>/);
#			if($in{'no'} == $no) {
#				if($last_nam){ ($na2) = ($last_nam); }
#					if(!$in{'res'}){ ($sub,$nam) = ($in{'sub'},$in{'name'}); }
#			}
#		push(@index,"$no<>$sub<>$res<>$nam<>$da<>$na2<>$key2<>\n");
#	}
#close(IN);
#}

	# インデックス更新
	#if(!$in{'res'}){
	#	Mebius::Fileout(undef,$nowfile,@index);
	#}

# ロック解除
&unlock($moto);

# リダイレクト
if($in{'res'}){ Mebius::Redirect("","$script?mode=view&no=$in{'no'}#S$in{'res'}"); }
else{ Mebius::Redirect("","$script?mode=view&no=$in{'no'}"); }

exit;
}

no strict;

#-----------------------------------------------------------
# 編集フォームを表示
#-----------------------------------------------------------
sub editform{

# 該当ログチェック
$flag=0;

our($realmoto,%in);

if($in{'res'} < 0){ main::error("レス番の指定が変です。"); }

my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , GetAllLine => 1 },$realmoto,$in{'no'});

my($num,$sub,$res2,$key) = split(/<>/, $thread->{'all_line'}->[0]);
my($no,$resnum,$nam,$eml,$com,$dat,$hos,$pw,$url,$mvw) = split(/<>/,$thread->{'all_line'}->[$in{'res'}+1]);


# テキストエリア整形
$nam =~ s/"/&quot;/g;
$nam =~ s/</&lt;/g;
$nam =~ s/>/&gt;/g;

$sub =~ s/"/&quot;/g;
$sub =~ s/</&lt;/g;
$sub =~ s/>/&gt;/g;

my $textarea = $com;
$textarea =~ s/<br>/\n/g;
($textarea) = Mebius::escape("Not-br",$textarea);

my $print .= qq(
<a href="javascript:history.back()">前の画面に戻る</a>
<h1>$sub > $in{'res'} の修正</h1>
<form action="$script" method="post" name="myFORM">
<input type="hidden" name="mode" value="edit_log">
<input type="hidden" name="moto" value="$in{'moto'}">
<input type="hidden" name="job" value="edit2">
<input type="hidden" name="no" value="$in{'no'}">
<input type="hidden" name="res" value="$in{'res'}">
<input type="hidden" name="pass" value="$in{'pass'}">
<table>
);

if($in{'res'} eq "" || $in{'res'} eq "0"){
$print .= qq(
<tr><td>題名</td>
<td><input type="text" name="sub" size="80" value="$sub"></td>
</tr>
);
}

$print .= qq(
<tr><td>筆名</td>
<td><input type="text" name="name" size="80" value="$nam"></td></tr>
</tr>
);

$print .= qq(
<tr><td>本文</td>
<td><textarea name="comment" cols="71" rows="20" style="width:100%;height:400px;">$textarea</textarea></td></tr>
<tr><td><br></td><td><input type="submit" value="この内容で変更する">
<input type="checkbox" name="tag" value="1" id="tag_on" checked><label for="tag_on">タグ</label>
</td>
</tr></table>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

}

no strict;

#●別名-----------------------------------------------------------

#-----------------------------------------------------------
# 別名
#-----------------------------------------------------------

sub do_allregistcheck{
Mebius::Echeck::Start("",%in);
}

# ● 元 bas_adindex.cgi のモード振分け -----------------------------------------------------------


#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------
sub script_start_admin_index{

#require 'jcode.pl';

$script = "index.cgi";
$mode = $in{'mode'};

	#if($submode1 eq "pallet"){ require "${int_dir}main_pallet.pl"; Mebius::Pallet::Start(); }
	#els
	#if($mode eq "echeck"){ require "admin_echeck.cgi"; }
	if($mode eq "cdl"){ admin_cdl(); }
	elsif($mode eq "make_password"){ require Mebius::Admin::Password; Mebius::Admin::Password::make_password_form_for_admin(); }
	elsif($mode eq "bbs_status"){ require Mebius::BBS::Status; $bbs_status = new Mebius::BBS::Status; $bbs_status->junction(); }
	elsif($mode eq "cda"){ start_admin_control_ip(); }
	#elsif($mode eq "vlogined"){ require "admin_vlogined.cgi"; }
	elsif($mode eq "vadhistory"){ view_admin_login_histor(); }
	#elsif($mode eq "member"){ require "admin_member.pl"; &do_member; }
	elsif($mode eq "mydata"){ admin_mydata(); }
	#elsif($submode1 eq "past"){ require "${int_dir}part_pastindex.pl"; Mebius::BBS::PastIndexView("All-BBS-view Admin-mode"); }
	elsif($submode1 eq "allregistcheck"){ &do_allregistcheck(@_); }
	elsif($mode eq "" || $mode eq "index" ){ require "${main::int_dir}admin_index.pl"; }
	# 通常モードとの共通処理
	else {

		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}bas_main.pl";
		start_main();
	}

exit;

}

# ● URL変換フォーム-----------------------------------------------------------


sub admin_url_change_form{

$title="ＵＲＬ変換/管理モード";

$admin_bas_url = 'http://mb2.jp/jak/index.cgi';

$title="ＵＲＬ変換/管理モード";

&url_hyouji();

}

#-------------------------------------------------
# ＵＲＬ表示
#-------------------------------------------------

sub url_hyouji {

my($basic_init) = Mebius::basic_init();

my $print .= <<"EOM";
<a href="$home">ＴＯＰページ</a>
<a href="javascript:history.go(-1)">前の画面へ</a>
<a href="$kannriroom_url">管理ルーム</a>
<a href="$base_url">一般メビウスリング</a><br><br>

一般のＵＲＬから、管理モードのＵＲＬへ変換します。<br>
ＵＲＬ（またはＵＲＬが含まれたテキスト）を入力し、「この内容で変換する」を押して下さい。<br>
リンクは「ＳＨＩＦＴ＋クリック」で別窓で開くことが出来ます。<br><br>
EOM

# チェック
my($delete_checked,$guard);
if($in{'delete_checked'} eq "heavy"){ $delete_checked = qq(&amp;delete_checked=heavy); }
if($in{'delete_checked'} eq "light"){ $delete_checked = qq(&amp;delete_checked=light); }
if($in{'delete_checked'} eq "lock"){ $delete_checked = qq(&amp;delete_checked=lock); }
if($in{'guard'} eq "0"){ $guard = qq(&amp;guard=0); }
if($in{'reason'}){ $reason = qq(&amp;reason=$in{'reason'}); }


if($in{'comment'}){

$url_submit="$in{'comment'}";

print"<hr>変換後のＵＲＬ<br>";

foreach(split(/<br>/, $url_submit)) {


$_ =~ s/１/1/g;
$_ =~ s/２/2/g;
$_ =~ s/３/3/g;
$_ =~ s/４/4/g;
$_ =~ s/５/5/g;
$_ =~ s/６/6/g;
$_ =~ s/７/7/g;
$_ =~ s/８/8/g;
$_ =~ s/９/9/g;
$_ =~ s/０/0/g;
$_ =~ s/no\./,/ig;

$_ =~ s/，/,/g;
$_ =~ s/、/,/g;

# 引数など処理
$_ =~ s/#a//g;


$_ =~ s/_([0-9a-z]+)_([0-9a-z]+)\//_$1\//g;
$_ =~ s/_([0-9a-z]+)\/k/_$1\//g;
$_ =~ s/_([0-9a-z]+)\/m([0-9]+)\.html/$1.cgi?p=$2/g;

# 各レス
$_ =~ s/_([0-9a-z]+)\/([0-9]+)\.html-([a-z0-9_\-]+)/jak\/$1.cgi?mode=view&amp;no=$2&amp;No=$3#RES/g;

# 個別記事
$_ =~ s/_([0-9a-z]+)\/([0-9]+)\.html/jak\/$1.cgi?mode=view&no=$2/g;
$_ =~ s/_([0-9a-z]+)\/([0-9]+)_([0-9]+)\.html/jak\/$1.cgi?mode=view&no=$2&r=$3#S$3/g;

$_ =~ s/\/_([0-9a-z]+)\//\/$1\.cgi/g;

$_ =~ s/http(\:\/\/[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%\,]+)/<a href=\"$basic_init->{'admin_http'}$1$delete_checked$guard$reason\">$basic_init->{'admin_http'}$1$delete_checked$guard$reason<\/a>/g;

print"$_<br>";

}
print"<hr>";


}

# 削除理由を取得
require "${int_dir}part_delreason.pl";
my($reason_selects) = Mebius::Reason::get_select_reason("$in{'reason'}","");

# 送信ボタン
my $submit = qq(
<input type="submit" value="この内容で変換する"> 初期入力： 
<input type="radio" name="delete_checked" value="heavy" id="delete_soon"> <label for="delete_soon">すぐ削除</label>
<input type="radio" name="delete_checked" value="light" id="delete_after"> <label for="delete_after">あとで削除</label>
<input type="radio" name="delete_checked" value="lock" id="delete_lock"> <label for="delete_lock">ロック</label>
<input type="checkbox" name="guard" value="0" id="delete_nogurard"> <label for="delete_nogurard">削除ガードなし</label>

<select name="reason">
<option value="">削除理由
$reason_selects
</select>
);

$in{'comment'} =~ s/<br>/\r/g;



$print .= <<"EOM";
<form action="$script" method="post">
<input type="hidden" name="mode" value="url">
$submit
<br>
<textarea cols="71" rows="20" name="comment" class="infrm" accesskey="3">$in{'comment'}</textarea>
<br>

</form>
EOM


$print .= <<"EOM";
<hr>
◎サイト内検索で禁則投稿を発見　→　ＵＲＬ変換　→　管理する<br><br>

下のフォーム（Ｇｏｏｇｌｅ検索）にキーワード（荒らしワードなど）を入れて検索し、<br>
検索結果のページを丸ごとコピー＆ペーストして、変換してください。<br><br>

<form method=get action="http://www.google.co.jp/search" target="_blank">
<table bgcolor="#FFFFFF"><tr valign=top><td>
<a href="http://www.google.co.jp/">
<img src="http://www.google.com/logos/Logo_40wht.gif" 
border="0" alt="Google" align="absmiddle"></a>
</td>
<td>
<input type=text name=q size=31 maxlength=255 value="">
<input type=hidden name=ie value=Shift_JIS>
<input type=hidden name=oe value=Shift_JIS>
<input type=hidden name=hl value="ja">
<input type=submit name=btnG value="Google 検索">
<font size=-1>
<input type=hidden name=domains value="YOURSITE.CO.JP"><br>
<input type=radio name=sitesearch value=""> WWW を検索 
<input type=radio name=sitesearch value="mb2.jp" checked> メビウスリング を検索
</font>
</td></tr></table>
</form>
</center>
<!-- SiteSearch Google -->

・Ｇｏｏｇｌｅ検索には、登録されていないページも多く存在します。<br>
・検索ページの更新状態はリアルタイムではありません。（１週間以上前のものが多いです）<br>
・検索先の「検索オプション」で「１００件ずつ\表\示」などを選ぶと、使いやすいと思います。<br><br>



<!-- Begin Yahoo Search Form -->
<div style="margin:0;padding:0;font-size:14pt;border:none;background-color:#FFF;">
<form action="http://search.yahoo.co.jp/search" method="get" target="_blank" style="margin:0;padding:0;">
<p style="margin:0;padding:0;"><a href="http://search.yahoo.co.jp/" target="_blank"><img src="http://i.yimg.jp/images/search/guide/searchbox/ysearch_logo_110_22.gif" alt="Yahoo!検索" style="border:none;vertical-align:middle;padding:0;border:0;"></a><input type="text" name="p" size="28" style="margin:0 3px;width:50%;"><input type="hidden" name="fr" value="yssw" style="display:none;"><input type="hidden" name="ei" value="Shift_JIS" style="display:none;"><input type="submit" value="検索" style="margin:0;"></p>
<ul style="margin:2px 0 0 0;padding:0;font-size:10pt;list-style:none;">
<li style="display:inline;"><input name="vs" type="radio" value="">ウェブ全体を検索</li>
<li style="display:inline;"><input name="vs" type="radio" value="mb2.jp" checked>このサイト内を検索</li>
</ul>
</form>
</div>
<!-- End Yahoo! Search Form -->
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

# ● 掲示板全体の動作 -----------------------------------------------------------

	
#-------------------------------------------------
#  フォームデコード
#-------------------------------------------------
sub start_script_bbs_admin {

require Mebius::BBS;
&init_start_bbs("Admin-mode");

	# 旧サーバーからリダイレクト
	my($server_domain) = Mebius::server_domain();
	if($server_domain eq "aurasoul.mb2.jp"){
		Mebius::redirect("https://mb2.jp$ENV{'REQUEST_URI'}");
	}

# テンプレート取り込み
my($init_directory) = Mebius::BaseInitDirectory();

require "${init_directory}part_template_call.pl";
($res_template) .= &get_calltemplate();


#モード切替
if($mode eq "form") { require "${init_directory}part_newform.pl"; bbs_last_newform(); }
elsif($mode eq "find"||$mode eq "kfind") { bbs_find_thread_admin(); }
elsif($mode eq "view" || $mode eq "vf") {

if($in{'r'} eq "data"){ require "${init_directory}part_data.pl"; &bbs_view_data(); }
elsif($in{'r'} eq "memo"){ require "${init_directory}part_memo.pl"; &bbs_memo("Admin-mode"); }
else{ &ad_view(); }
}
elsif($mode eq "past") { bbs_view_past_threads_admin(); }
elsif($mode eq "enter_disp") { &enter_disp(); }
elsif($mode eq "logoff") { &logoff(); }
#elsif($mode eq "settei") { require'part_adsettei.cgi'; &part_settei(); }
#elsif($mode eq "findkey") { require'admin_findkey.cgi'; }
elsif($mode eq "rule") { &part_rule(); }
#elsif($mode eq "hint"){ require'admin_hint.cgi'; &admin_hint();  }
#elsif($mode eq "msg"){ require'admin_msg.cgi'; &admin_msg(); }
elsif($mode eq "url"){ admin_url_change_form();  }
#elsif($mode eq "autotext"){ require'admin_autotext.cgi'; }
#elsif($mode eq "cord"){ require'admin_cord.pl' }
#elsif($mode eq "keycheck"){ require 'admin_keycheck.cgi'; }
#elsif($mode eq "Nojump"){ require 'admin_resjump.pl'; }
elsif($mode eq "init"){ junction_bbs_special_init_file(); }
#elsif($mode eq "member"){ require "admin_member.pl"; }
elsif($mode eq "memo"){ require "${init_directory}part_memo.pl"; &bbs_memo("Admin-mode"); }
elsif($submode1 eq "past"){ require "${init_directory}part_pastindex.pl"; Mebius::BBS::PastIndexView("Select-BBS-view Admin-mode"); }

	# 管理処理
	elsif($mode eq "admin"){
			#if($in{'pass'} eq "") { &enter(); }
			#elsif ($in{'pass'} ne $pass) { &error("認証エラーです。"); }
		#require "bas_adm.pl";
		&ad_settei();
		&admin();
	}
	# 投稿処理
	elsif($mode eq "regist"){
		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}part_regist.pl";
		bbs_regist();
		#require "admin_regist.pl";
		#&admin_regist();
	}
	# 記事レス修正
	elsif($mode eq "edit_log"){
		#require "admin_edit.pl";
		&edit_log(@_);
	}
	# 記事ソース修正
	#elsif($mode eq "edit_source"){
	#	require "admin_source.pl";
	#	&change_source();
	#}
	# オートリンク閲覧
	#elsif($mode eq "autolink_view"){
	#	require "admin_regist.pl";
	#	&autolink_view();
	#}
	# 設定ファイルの変更
	elsif($mode eq "init_edit"){
		use Mebius::Admin::InitEdit;
		Mebius::Admin::InitEdit::Start();
	}

admin_indexview();

exit;

}


#-------------------------------------------------
# 記事閲覧
#-------------------------------------------------
sub ad_view { my($init_directory) = Mebius::BaseInitDirectory(); require "${init_directory}part_view.pl"; bbs_view_thread(); }

#-------------------------------------------------
#  ログオフ
#-------------------------------------------------
sub logoff {

my($admin_basic_init) = Mebius::Admin::basic_init();

	unlink("$admin_basic_init->{'sesdir'}/$admy_session.cgi");

	print "Set-Cookie: $ENV{'SERVER_ADDR'}=; path=/; \n";
	&enter_disp();

}



#-------------------------------------------------
# URLエンコード
#-------------------------------------------------
sub url_enc {
local($_) = @_;

s/(\W)/'%' . unpack('H2', $1)/eg;
s/\s/+/g;
$_;
}

#-------------------------------------------------
# 過去ログ閲覧
#-------------------------------------------------
sub bbs_view_past_threads_admin {
local($i,$no,$sub,$res,$name,$date,$na2);

my($basic_init) = Mebius::basic_init();
# 記事閲覧
if ($in{'no'}) { &ad_view("past"); }

my $print .= <<"EOM";
<div align="center">

<div class="div6"><br>

<a href="#go" class="title">$title 過去ログ（管理モード）</a>
<span class="size0"><br><br></span>
$my_name（$my_rank）
$setumei<br><br>
<span class="size4">
<a href="$home" accesskey="0">ＴＯＰページ</a>&nbsp;
<a href="$script?mode=form" accesskey="1">新規投稿</a>&nbsp;
<a href="$basic_init->{'admin_report_bbs_url'}">削除依頼掲示板</a>&nbsp;
<a href="$script?mode=find" accesskey="2">記事検索</a>&nbsp;
<a href="$script?mode=logoff">ログオフ</a>
</span></div>

<form class="forma" action="$script" method="POST">
<input type=hidden name=mode value="find">
<input type=hidden name=op value="AND">
<input type=hidden name=log value="0">
<input type=hidden name=s value="1">
<input type=hidden name=n value="1">
<input type=hidden name=saishuu value="1">
<input type=hidden name=vw value="100">
<input type=text name=word size=38 value=""><input type=submit value="検索"></form>
EOM

# ページ移動ボタン表示

$i=0;
open(IN,"$pastfile") || &error("$pastfileが開けません");
while (<IN>) { $i++; }

$print .= <<"EOM";
<table summary="ページ移動"><tr><td class="page">
<a href="$script" class="size3">現行ログ</a>
EOM

if ($main::in{'p'} - $menu2 >= 0 || $main::in{'p'} + $menu2 < $i) {
local($x,$y) = (1,0);

while ($i > 0) {

if ($main::in{'p'} == $y) { $print .= "<b class=\"pink\">$x</b>\n"; }
else { $print .= "<a href=\"$script?mode=past&amp;p=$y\">$x</a>\n"; }
$x++;
$y += $menu2;
$i -= $menu2;
}
}

$print .= "</td></tr></table><br>\n";

$print .= <<"EOM";
<table cellpadding="3" summary="記事一覧"><tr><td class="td0">No</td><td class="td1">
題名</td><td class="td2">名前</td><td class="td3">最終</td><td class="td4">返信</td></tr>
EOM

# スレッド展開
$i=0;
if ($main::in{'p'} eq "") { $p=0; }
open(IN,"$pastfile") || &error("$pastfileが開けません");
while (<IN>) {
$i++;
next if ($i < $main::in{'p'} + 1);
next if ($i > $main::in{'p'} + $menu2);

($no,$sub,$res,$name,$date,$na2) = split(/<>/);

$print .= "<tr><td>$i</td><td>
<a href=\"$script?mode=view&amp;no=$no\">$sub</a></td><td>$name</td><td>$na2</td><td>$res回</td></tr>\n";

}
close(IN);

$print .= <<"EOM";
</table><br>
<table summary="ページ移動"><tr><td class="page">
<a href="$script" class="size3">現行ログ</a>
EOM

# ページ移動ボタン表示
if ($main::in{'p'} - $menu2 >= 0 || $main::in{'p'} + $menu2 < $i) {
local($x,$y) = (1,0);

while ($i > 0) {
$print .= "<a href=\"$script?mode=past&amp;p=$y\">$x</a>\n";
$x++;
$y += $menu2;
$i -= $menu2;
}}

$print .= "</td></tr></table><br>$hyouji</div>\n";

Mebius::Template::gzip_and_print_all({},$print);

exit;
}

#-------------------------------------------------
# 記事検索
#-------------------------------------------------
sub bbs_find_thread_admin {
local($no,$sub,$res,$nam,$date,$na2,$key,$target,
$alarm,$next,$back,$enwd,@log1,@log2,@log3,@wd);

# 検索オプションデータが無くても代入
if(!$op){$op = "AND";}
if(!$vw){$vw = 100;}
if(!$s){$s = 1;}
if(!$n){$n = 1;}
if(!$saishuu){$saishuu = 1;}

# ＵＲＬ用にエンコード
$enwd = &url_enc($in{'word'});

my $print .= <<"EOM";

<a href="$home">ＴＯＰページ</a>
<a href="$script">掲示板ＴＯＰ</a><br><br>

<strong>記事検索</strong><br><br>

<form action="$script" method="GET">
<input type=hidden name=mode value="find">
キーワード <input type=text name=word size=38 value="$in{'word'}"><input type=submit value="検索">&nbsp;

EOM


if ($in{'log'} eq "") { $in{'log'} = 0; }
@log1 = ($nowfile, $pastfile);
@log2 = ("現行ログ", "過去");
@log3 = ("view", "past");
foreach (0,1) {
if ($in{'log'} == $_) {
$print .= "<input type=radio name=log value=\"$_\" checked>$log2[$_]";
} else {
$print .= "<input type=radio name=log value=\"$_\">$log2[$_]";
}
}

$print .= <<"EOM";
</form>

EOM

# 普通の掲示板からＵＲＬを引用したときの、引数補充

if($in{'s'} eq ""){$in{'s'}=1;}
if($in{'n'} eq ""){$in{'n'}=1;}
if($in{'saishuu'} eq ""){$in{'saishuu'}=1;}
if($in{'vw'} eq ""){$in{'vw'}=100;}

#検索実行
if ($in{'word'} && ($in{'s'} || $in{'n'}||$in{'saishuu'})) {

$print .= <<EOM;
<table cellpadding="3" summary="記事一覧"><tr><td class="td0">No</td><td class="td1">
EOM


$print .= <<EOM;
題名</td><td class="td2">名前</td><td class="td3">最終</td><td class="td4">返信</td></tr>
EOM

$in{'word'} =~ s/\x81\x40/ /g;
@wd = split(/\s+/, $in{'word'});

$i=0;
open(IN,"$log1[$in{'log'}]") || &error("$log1[$in{'log'}]が開けません");
$top = <IN> if (!$in{'log'});
while (<IN>) {
$target='';
($no,$sub,$res,$nam,$date,$na2,$key) = split(/<>/);
$target .= $sub if ($in{'s'});
$target .= $nam if ($in{'n'});
$target .= $na2 if ($in{'saishuu'});
$flag=0;
foreach $wd (@wd) {
if (index($target,$wd) >= 0) {
$flag=1;
if ($in{'op'} eq 'OR') { last; }
} else {
if ($in{'op'} eq 'AND') { $flag=0; last; }
}
}
if ($flag) {
$i++;
if ($i < $main::in{'p'} + 1) { next; }
if ($i > $main::in{'p'} + $in{'vw'}) { next; }


$print .= "<tr><td>$i</td><td>";


		if ($key eq "0") {
			$print .= "[<span style=\"color:#FF0000;\">ロック</span>] ";
		} elsif ($key == 2) {
			$print .= "[<span style=\"color:#FF0000;\">管理者</span>] ";
		}



$print .= "<a href=\"$script?mode=$log3[$in{'log'}]&amp;no=$no\">$sub</a></td><td>$nam</td><td>$na2</td><td>$res回</td></tr>\n";
}
}
close(IN);

$print .= "</table>\n";

$print .= "<br>[検索結果&nbsp;$i件]&nbsp;&nbsp;";

$next = $main::in{'p'} + $in{'vw'};
$back = $main::in{'p'} - $in{'vw'};
$enwd = &url_enc($in{'word'});

$print .= "
<input type=\"hidden\" name=\"find_back\" value=\"$script?mode=find&amp;p=0&amp;word=$enwd&amp;vw=$in{'vw'}&amp;op=$in{'op'}&amp;log=$in{'log'}&amp;s=$in{'s'}&amp;n=$in{'n'}\">
";

if ($back >= 0) {
$print .= "<a href=\"$script?mode=find&amp;p=$back&amp;word=$enwd&amp;vw=$in{'vw'}&amp;op=$in{'op'}&amp;log=$in{'log'}&amp;s=$in{'s'}&amp;n=$in{'n'}\">前の$in{'vw'}件</a>\n";
}
if ($next < $i) {
$print .= "<a href=\"$script?mode=find&amp;p=$next&amp;word=$enwd&amp;vw=$in{'vw'}&amp;op=$in{'op'}&amp;log=$in{'log'}&amp;s=$in{'s'}&amp;n=$in{'n'}\">次の$in{'vw'}件</a>\n";
}


}

Mebius::Template::gzip_and_print_all({},$print);

exit;
}

#-------------------------------------------------------------------------------------
# タイトル修復
#-------------------------------------------------------------------------------------

sub part_rule{

	if($main::admy{'master_flag'}){
		Mebius::Redirect(undef,"${main::jak_url}$main::moto.cgi?mode=init_edit#RULE");
	}


my $print .= "<strong><a href=\"$script\">$title</a>のルール</strong><br><br>";

$rule_text =~ s/[\n]/<br>/g;

$print .= "$rule_text";

Mebius::Template::gzip_and_print_all({},$print);

exit;

}




#-------------------------------------------------
# 空処理
#-------------------------------------------------
sub ad_text{}


# ● bas_adbase.cgi にあった処理 -----------------------------------------------------------

use File::Basename;

#-------------------------------------------------
# フォームデコード
#-------------------------------------------------
sub before_start{

my($admin_basic_init) = Mebius::Admin::basic_init();
my($param) = Mebius::query_single_param();

# 管理フラグを立てる
Mebius::Admin::ridge_admin_flag();

	# リモートユーザーが指定されていない場合はエラーに
	if(!Mebius::alocal_judge() && $ENV{'REMOTE_USER'} eq "" && $ENV{'REDIRECT_REMOTE_USER'}){ main::error("第一暗証がかかっていません。"); }

	# SSLでない場合はエラーに
#	if(!Mebius::alocal_judge() && $ENV{'SERVER_PORT'} ne "443"){ main::error("SSLでアクセスしてください。"); }

my($basic_init) = Mebius::basic_init();

$master_rank = $admin_basic_init->{'master_rank'};
$leader_rank = $admin_basic_init->{'leaders_rank'};

# スクリプト名
my $bbs_object = Mebius::BBS->new();
($moto) = $bbs_object->root_bbs_kind();
($realmoto) = $bbs_object->true_bbs_kind();
	if($realmoto){
		$script = "$realmoto.cgi";
	} else {
		$script = basename($ENV{'SCRIPT_NAME'});	
	}

# 戻り処理に使う送信ボタンの値
$backurl_submitvalue = "戻";

# ページの表示
$pfirst_page = 50;

# 管理モード
$admin_mode = 1;
$mainscript = "index.cgi";
$main_url = "${jak_url}index.cgi";

# 基本パスワード
$guide_id = "GiiuSper";
$guide_pass = "dk5hasgf";

#管理後チェック
	if($alocal_mode){ $home = "index.cgi"; }
	else{ $home = "https://mb2.jp/jak/index.cgi"; }

$after_folder_adm = ".";
$rand_check_adm_n = 100;

# 各種ＵＲＬ
$guide_url_base = $guide_url;
$bas_domein='mb2.jp';
$base_url = "$basic_init->{'admin_http'}://mb2.jp/";
$kannriroom_url="$basic_init->{'admin_http'}://mb2.jp/jak/fjs.cgi";
$adroom_url = "$basic_init->{'admin_http'}://mb2.jp/jak/fjs.cgi?mode=view&amp;no=54&amp;jump=newres";
$adroom_link = qq(<a href="$basic_init->{'admin_http'}://mb2.jp/jak/fjs.cgi">管理ルーム</a> \(<a href="$basic_init->{'admin_http'}://mb2.jp/jak/fjs.cgi?mode=view&amp;no=54#NEW_RES">▼</a>\));
$adroom_link .= qq( <a href="https://mb2.jp/jak/index.cgi?mode=report_view">違反報告</a> );
$adroom_link_utf8 = utf8_return($adroom_link);

$admin_url = "/jak/";
#$jak_url = "/jak/";
$cdl_url = "${admin_url}index.cgi?mode=cdl&amp;file=";

# 管理履歴の最大保存数
$adfile_max = 1000;

# 各種設定
$no_par = 1;
$p_page = 100;

$memfile = 'mem1.cgi';
$memfile2 = 'mem2.cgi';

$copydir = 'copy';

$adtext = '';

$url = 'bbs';

$site_url = 'http://mb2.jp/';

#$hyouji = <<"EOM";
#<a href="${base_url}jak/fjs.cgi?mode=url">ＵＲＬ変換</a>┃<a href="${base_url}wiki/guid/%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">禁則</a>┃<a href="${base_url}wiki/guid/?action=LIST">ガイド一覧</a>┃<a href="$basic_init->{'admin_report_bbs_url'}">削除依頼板</a>┃<a href="index.cgi?mode=vlogined">ログイン履歴</a>┃<a href="$main_url?mode=cdl">管理番号</a>┃$adroom_link
#EOM

$pass = '5klGs94a';
$pass2 = '5klGs94a';

$trip_key = 'x6';

# 連続投稿の禁止時間（秒）
$wait = 0;

# コメント入力文字数（全角換算）
$max_msg = 50000;

$admin_css = "/jak/admin.css";
if($alocal_mode){ $admin_css = "/style/admin.css"; }

# 管理基本ファイル、サーバードメインなどを取得
#require "admin.ini";
#&admin_init_option();

# マスターモード
my $adaddr = $ENV{'REMOTE_ADDR'};
$host = $ENV{'REMOTE_HOST'};

	# ホスト判定
	if (($host eq "" || $host eq "$addr")) { $host = gethostbyaddr(pack("C4", split(/\./, $adaddr)), 2); }
	# if(length($host) < 6){ main::error("ログイン出来ません。"); }

	# クッキー取得
	($cnam,$ceml,$cpwd,$curl,$cmvw,$csort,$delce,$csnslink) = get_cookie_admin();

# 関数定義
$i_sub = $in{'sub'};
$i_com = $in{'comment'};

# 管理者のログインチェック
logincheck_admin();

# アクセスを記録
Mebius::Admin::AccessDataCheck("New-access Renew",$admy_file,$host,$main::agent);

# 戻り先
&backurl("NOREFERER","$in{'backurl'}");

			# クエリがある場合、リダイレクト
			if($main::mode eq "login" && $main::postflag && $in{'mode'} ne "logoff"){
				Mebius::redirect_to_back_url();
			#		if($main::in{'query'} && $main::in{'query'} !~ /logoff/){
			#			my $query = $main::in{'query'};
			#			$query =~ s/&amp;/&/g;
			#			Mebius::Redirect("","$main::script?$query");
			#		}
			#		else{ 
			#			Mebius::Redirect("","$main::script");
			#		}
			}

}


use strict;
package Mebius::Admin;

#-----------------------------------------------------------
# 全てのアクセス履歴をチェック ( ホスト名に重複がない場合に、新しい行を記録 )
#-----------------------------------------------------------
sub AccessDataCheck{

# 宣言
my($type,$user_name,$host,$agent) = @_;
my($file_handler,$i,%top,@renew_line,$still_host_flag,$not_renew_flag);
my($file);

my($init_directory) = Mebius::BaseInitDirectory();

	# ファイル定義
$file = "${init_directory}_admin/_log_admin/member_access.log";

# アクセス情報を取得
my($access) = Mebius::my_access();

# ファイルを開く
open($file_handler,"<",$file);

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($top{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# ラウンドカウンタ
		$i++;
		
			# エスケープ
			if($i >= 50){ next; }

		# この行を分解
		chomp;
		my($key2,$user_name2,$host2,$time2,$date2,$agent2) = split(/<>/);

			# 既にユーザーエージェントが記録されている場合
			if($agent eq $agent2 && $access->{'mobile_flag'}){
				$still_host_flag = 1;
			}

			# 既にホスト名が記録されている場合
			if($host eq $host2 && !$access->{'mobile_flag'}){
				$still_host_flag = 1;
			}

			# 行を追加
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$user_name2<>$host2<>$time2<>$date2<>$agent2<>\n");
			}

	}

close($file_handler);

	# 新しいアクセス
	if($type =~ /New-access/){
			# 既にホスト名が記録されている場合
			if($still_host_flag){
				$not_renew_flag = 1;
			}
			# 初めて記録するホスト名の場合
			else{
				unshift(@renew_line,"<>$user_name<>$host<>$main::time<>$main::date<>$agent<>\n");
				Mebius::Admin::AlertMail(undef,"管理モード ： 新しい接続元",undef,%main::admy);
			}
	}

	# ファイル更新
	if($type =~ /Renew/ && !$not_renew_flag){
		unshift(@renew_line,"$top{'key'}<>\n");
		Mebius::Fileout(undef,$file,@renew_line);
	}
	


}



package main;

#-------------------------------------------------
#  管理者のログインチェック
#-------------------------------------------------
sub logincheck_admin{

my($admy) = Mebius::my_admin();
our %admy = %$admy;

	# 管理記録を更新
	if($ENV{'REQUEST_METHOD'} eq "POST"){
		&renew_myhistory();
	}


}

no strict;

# --------------------------------------------
# マイデータを変更
# --------------------------------------------
sub MyData{

# 宣言
my($type,$id) = @_;
my($mydata_makebody,%data);
our(%in,$script);

# 汚染チェック
if($id =~ /\W/){ main::error("マイ設定を開く管理者IDが不正です。"); }

	# 汚染チェック
	if($type =~ /Edit-mydata/){
			if($in{'ryaku'} =~ /\D/){ main::error("レス省略数は半角数字で指定してください。"); }
			if($in{'ryaku'} =~ /\D/){ main::error("レス省略数は半角数字で指定してください。"); }
			if($in{'sakujo'} =~ /<br>/){ main::error("削除文に改行は使えません。"); }
	}

# マイデータを開く
open(MY_DATA,"<_mydata/$id.cgi");
chomp(my $my_data1 = <MY_DATA>);
chomp(my $my_data2 = <MY_DATA>);
($data{'deleted_text'},$data{'per_page_thread'},$data{'omit_thread_res'},$data{'oya_search'}) = split (/<>/,$my_data1);
($data{'res_template'}) = split (/<>/,$my_data2);
#($myd_sakujo,$myd_th_page,$myd_ryaku,$myd_oyasearch) = split (/<>/,$my_data1);
#($myd_template,$myd_formlink) = split (/<>/,$my_data2);
close(MY_DATA);

	# グローバル変数を設定

	# ファイル更新
	if($type =~ /Renew/){

		my %renew_data = %data;

		# 設定値調整（改行など）
		$mydata_makebody .= "$in{'sakujo'}<>$in{'th_page'}<>$in{'ryaku'}<>$in{'oyasearch'}<><>\n";
		$mydata_makebody .= "$in{'template'}<>$in{'formlink'}<><><><>\n";

		Mebius::Fileout(undef,"_mydata/${id}.cgi",$mydata_makebody);

	}


return(%data);

}

no strict;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# ログイン履歴を更新
#-----------------------------------------------------------
sub renew_logined{

my($line,$i,$file_handler,@renew_line);

my($init_directory) = Mebius::BaseInitDirectory();

# ファイル定義
my $file = "${init_directory}_admin/_log_admin/login_history_admin.log";

# ログイン履歴を開く
open($file_handler,"<",$file);
flock($file_handler,1);
	while(<$file_handler>){
		$i++;
			if($i < 500){ push(@renew_line,$_); }
	}
close($file_handler);

# 追加する行
unshift(@renew_line,"$main::time<>$main::date<><>$main::admy_name<>$main::host<>$main::addr<>$main::agent<>\n");

# ログイン履歴を更新
Mebius::Fileout(undef,$file,@renew_line);

}


#-------------------------------------------------
#  ログイン初期画面
#-------------------------------------------------
sub enter_disp {

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$message) = @_;

# クエリ引継ぎ
my $query = $ENV{'QUERY_STRING'};

# ログインフォーム上部
my $print .= qq(
<br><div align="center">
<a href="$home">ＴＯＰページに戻る</a><br><br>
<div class="div2"><div class="div4">
<div align="center">
<div>
<br><br>
☆今日も張り切っていきましょう!!<br>
☆ＩＤ、パスワードは暗記しておきましょう。<br>
<span class="red">☆マスターや他の管理者が、あなたのIDやパスワードを聞くことはありません。信頼できる方法（管理ルームや、確実に管理者のものだと分かっているメールアドレス）で連絡をおこなってください。</span>
</div>
);

if($message){ $print .= qq(<div class="message-red">$message</div>); }

my $back_url_input_hidden = Mebius::back_url_input_hidden();

$print .= qq(
<br>
<br>

<form action="index.cgi" method="post">
<input type=hidden name=mode value="login">
$back_url_input_hidden
ログインＩＤ <input type=text name=id value="" style="width:10em;"><br>
パスワード <input type=password name=pw value="" style="width:10em;" autofocus>
<input type="hidden" name="query" value="$query">
<br><br>
<input type=submit value=" ログイン">
</form>
</div>

<div style="border:1px solid #000;padding:1em;margin:1em;">
■うまくログインできない場合<br><br>


・画面右下などの、ＰＣの時刻設定が変になっていないか確認してみてください。<br>
・ログオフ、ログインを何度か繰り返してみてください。<br>
・ログイン画面や、ログインできないＵＲＬで、画面更新を何度か繰り返してみてください。<br>
・ＰＣを再起動させてみてください。<br>
・ブラウザの「ツール」→「インターネットオプション」→「プライバシー」の設定などで、クッキーが有効かどうか確かめてください。<br>
・ブラウザの「ツール」→「インターネットオプション」→「Cookieの削除」などで、クッキーを全削除してみてください。<br>
・別のブラウザをダウンロードしてみてください。<a href="http://jp.opera.com/">Opera</a>
<a href="http://www.mozilla-japan.org/products/firefox/">FireFox</a>
<a href="http://www.google.co.jp/chrome/intl/ja/landing_ch.html">Google Chrome</a>
<br>
・繋がらない場合の連絡先　<a href="mailto:$basic_init->{'admin_email'}">$basic_init->{'admin_email'}</a>　（マスター）
</div>

</div></div></div>$in{'comment'}
);

Mebius::Template::gzip_and_print_all({ NotAdminNavigation => 1 },$print);


exit;

}



#-------------------------------------------------
#  エラー処理
#-------------------------------------------------
sub error {

	if ($lockflag) { &unlock($lockflag); }

my $error = shift;
g_shift_jis($error);
my($package, $file, $line) = caller; 

my $print .= <<"EOM";
<div align="center"><div style="border:1px #000 solid;padding:20px;margin:15% auto;width:60%;">
<strong style="color:#f00;" class="line-height-large">エラー： <br$main::xclose>$error</strong><br><br>
$in{'comment'}
w<a href="JavaScript:history.go(-1)">前の画面に戻る</a><br><br>
<a href="$script">掲示板に戻る</a><br><br>
<a href="$home">ＴＯＰページに戻る</a></span>
$pr2
</div></div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-------------------------------------------------
# クッキー発行
#-------------------------------------------------
sub set_cookie_admin {

	local(@cook) = @_;
	local($gmt, $cook, @t, @m, @w);

	@t = gmtime(time + 60*24*60*60);
	@m = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
	@w = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

	# 国際標準時を定義
	$gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
	$w[$t[6]], $t[3], $m[$t[4]], $t[5]+1900, $t[2], $t[1], $t[0]);

	# 保存データをURLエンコード
	foreach (@cook) {
		s/(\W)/sprintf("%%%02X", unpack("C", $1))/eg;
		$cook .= "$_<>";
	}

	# 格納
	if($alocal_mode){ print "Set-Cookie: mebiusu_admin=$cook; expires=$gmt; path=/;\n"; }
	else{ print "Set-Cookie: mebiusu_admin=$cook; expires=$gmt; domain=mb2.jp; path=/;\n" };

}



#-------------------------------------------------
# クッキー取得
#-------------------------------------------------
sub get_cookie_admin {
local($key, $val, *cook);

# クッキーを取得
$cook = $ENV{'HTTP_COOKIE'};

# 該当IDを取り出す
foreach ( split(/;/, $cook) ) {
($key, $val) = split(/=/);
$key =~ s/\s//g;
$cook{$key} = $val;
}

# データをURLデコードして復元
foreach ( split(/<>/, $cook{'mebiusu_admin'}) ) {
s/%([0-9A-Fa-f][0-9A-Fa-f])/pack("H2", $1)/eg;

push(@cook,$_);
}
return (@cook);
}



use Mebius::Page;
no strict;


#-------------------------------------------------
# 自動リンク
#-------------------------------------------------
sub ad_auto_link {

# 局所化
my($msg,$thread_number,$bbs_kind) = @_;
my($param) = Mebius::query_single_param();
#local($reporter_href);

# 一般用→管理用への修正
($msg) = Mebius::Fixurl("Normal-to-admin",$msg);

	# お絵かきページ
	#if($concept =~ /SUPERLINK/ && !$param->{'superlink_off'}){ 
	#	my $url_back_enc_paint = Mebius::Encode("","http://$server_domain/jak/$moto.cgi?mode=view&no=$thread_number#S$no");
	#	$msg =~ s!http://([a-z0-9\.]+)${main::main_url}\?mode=pallet-viewer-([0-9a-z]+)-([0-9]+)-([0-9]+)!<a href="$&\&amp;backurl=$url_back_enc_paint" class="sred">$&</a>!g;
	#}

# スタンプ
($msg) = Mebius::Effect::all($msg);

# 自動リンク
($msg) = Mebius::auto_link($msg);

# ttp リンク
$msg =~ s/([^=^\"h]|^)(ttps?\:\/\/[\w\.\,\~\!\-\/\?\&\+\=\:\@\%\;\#\%\*]+)/$1<a href=\"h$2\">$2<\/a>/g;


	# 報告者のアクセス情報
	#if($concept =~ /SUPERLINK/ && !$param->{'superlink_off'}){

			# ID
	#		if($line->{'id'} =~ /^([\w\.\/=\-]+)$/){
	#			my($id_encoded) = Mebius::Encode(undef,$line->{'id'});
	#			$reporter_href .= qq(&amp;reporter_id=$id_encoded);
	#		}
			
			# ホスト
	#		if($line->{'host'} && $main::admy{'rank'} >= $main::master_rank){
	#			my($host_encoded) = Mebius::Encode(undef,$line->{'host'});
	#			$reporter_href .= qq(&amp;reporter_host=$host_encoded);
	#		}

			# アカウント
	#		if($account){
	#			$reporter_href .= qq(&amp;reporter_account=$account);
	#		}

			# トリップ
	#		if($trip){
	#			my($trip_encoded) = Mebius::Encode(undef,$trip);
	#			$reporter_href .= qq(&amp;reporter_trip=$trip_encoded);
	#		}

			# ユーザーエージェント
	#		if($line->{'user_agent'} && $main::admy{'rank'} >= $main::master_rank){
	#			my($agent_encoded) = Mebius::Encode(undef,$line->{'user_agent'});
	#			$reporter_href .= qq(&amp;reporter_agent=$agent_encoded);
	#		}

			# クッキー
	#		if($line->{'cookie_char'}){
	#			my($cnumber_encoded) = Mebius::Encode(undef,$line->{'cookie_char'});
	#			$reporter_href .= qq(&amp;reporter_cnumber=$cnumber_encoded);
	#		}

	#}

	# スーパーリンクの戻り先
	#if($concept =~ /SUPERLINK/ && !$param->{'superlink_off'}){
	#	$msg =~ s/<a href="https?:\/\/([a-z0-9\.]+?)\/jak\/([0-9a-z]+?)\.cgi\?mode=view&amp;no=([0-9]+?)(&amp;.+?)?(#[a-zA-Z0-9]+)?">(h)?ttps?:\/\/(.+?)<\/a>/&push_backurl($1,$2,$3,$4,$5,$6,$7);/eg;
	#}

	# スーパーリンク
	#if($concept =~ /SUPERLINK/ && !$param->{'superlink_off'}){ 

			# 対応中のレス
			if($res_concept =~ /Admin-regist/) { $msg =~ s/^(△|No\.|&gt;&gt;)?([0-9]{1,5})$/<a href="#S$2">&gt;&gt;$2<\/a>/g; }

		# レス番を基本修正
	#	($msg) = basefix_resnumber($msg);

		# 範囲指定をカンマ指定に
		#$msg =~ s/(,|No\.|&gt;&gt;)([0-9]+)\-( |　)?(No\.|&gt;&gt;)?([0-9]+)/&becommma_resnumber($1,$2,$3,$4,$5);/eg;

		# レス番をつなげる
		#$msg =~ s/(No\.|&gt;&gt;)([0-9]+)([ 　\-,]+?)([Nogt;0-9,\.\&、 　]+)/&bridge_resnumber($1,$2,$3,$4);/eg;
		#$msg =~ s/(No\.|&gt;&gt;)([0-9]+)([ 　\-,]+?)([Nogt;0-9,\.\&、 ]+)/&bridge_resnumber($1,$2,$3,$4);/eg;

			# 削除後の戻り先値
	#		if($url_back_enc){

				# レス番
	#			$msg =~ s/(No\.|&gt;&gt;)([0-9,-]+)/<a href="$superlink&amp;No=$2$reporter_href&amp;backurl=$url_back_enc#RESNUMBER" class="sred">&gt;&gt;$2<\/a>/g;

	#		}

		
	#}

	# 普通のレス番リンク
	#if($concept !~ /SUPERLINK/){
	my($bbs_thread_url) = Mebius::BBS::thread_url_admin($thread_number,$bbs_kind);
		$msg =~ s/No\.([0-9,-]+)/<a href=\"$bbs_thread_url?mode=view&amp;no=$thread_number&amp;No=$1$backurl_query_enc#RESNUMBER\">&gt;&gt;$1<\/a>/g;
	#}



return($msg);

}

#-----------------------------------------------------------
# レス番を基本修正 （ 改行含む ）
#-----------------------------------------------------------
sub basefix_url_all{

my($msg) = @_;

#$msg =~ s/No\.([0-9,\-]+)([ 　]+)/No\.$1　/g;
$msg =~ s/　/ /g;
	$msg =~ s/≫/No./g;
#$msg =~ s/No\.([0-9,\-]+)([ ]+)/No\.$1/g;


return($msg);

}


#-------------------------------------------------
# チェックモード
#-------------------------------------------------
sub check{
if($header_flag) { print"Content-type:text/html\n\n"; }
$print .= $_[0];
exit;
}

#-----------------------------------------------------------
# エンコード
#-----------------------------------------------------------
sub enc{
my($check) = @_;
if($check eq ""){ return; }
$check =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
$check =~ tr/ /+/;
return($check);
}

#-----------------------------------------------------------
# デコード
#-----------------------------------------------------------
sub dec{
my($check) = @_;
$check =~ tr/+/ /;
$check =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("H2", $1)/eg;
return($check);
}

#-----------------------------------------------------------
# エスケープ処理 
#-----------------------------------------------------------
sub escape{
my($type,$val) = @_;
if($type !~ /NOTAND/){ $val =~ s/&/&amp;/g; }
$val =~ s/"/&quot;/g;
$val =~ s/</&lt;/g;
$val =~ s/>/&gt;/g;
$val =~ s/(\r\n|\r|\n)/<br>/g;
$val =~ s/\0//g;
$val =~ s/^([\|]+)//g;
return($val);
}


#-----------------------------------------------------------
# 取り込み処理
#-----------------------------------------------------------
#sub adurl{ require "admin_adurl.cgi"; &do_adurl(@_); }
sub renew_myhistory{ &do_renew_myhistory(@_); }
sub trip{ return("",$admy_name); }
sub redun{ return; }
sub kget_items{ return; }
sub md5{ return; }
sub backurl{ require "${int_dir}part_backurl.pl"; &get_backurl(@_); }
sub adevice{ Mebius::Checkdevice_fromagent(@_); }

sub trip{ return; }
sub access_log{}
sub bbs_init_category{ }

# ● 管理者の出席簿、履歴 -----------------------------------------------------------


#-----------------------------------------------------------
# モード分岐
#-----------------------------------------------------------
sub admin_login_history_junction{

# 局所化
my($file,$top,$none_flag,$line);

# ファイルを定義
$file = $in{'file'};
if($in{'file'} eq "my"){ $file = $admy_file; }
$file =~ s/\W//g;
if($file eq ""){ &error("表\示できません。"); }

# 実行
view_admin_login_history();

# 処理終了
exit;

}

#-----------------------------------------------------------
# 基本処理を実行
#-----------------------------------------------------------

sub view_admin_login_history{

# 局所化
my($line,$flag,$fook_name);

# CSS定義
$css_text .= qq(
table,th,tr,td{border-style:none;}
table{padding:0em 1em;}
td{padding:0.3em 0.2em;}
li{line-height:1.6;}
.domain_links{color:#080;font-size:140%;margin:1em 0em;font-style:oblique;}
.blue{color:#00f;}
div.member{word-spacing:0.5em;line-height:1.4;}
);



my($member_line) = Mebius::Admin::MemberList("Get-line-admin-record");


	# ドメイン切り替えリンク
	{ my($i);
		foreach(@domains){
		$i++;
		if($i >= 2){ $domain_links .= qq( - ); }
		if($_ eq $server_domain){ $domain_links .= qq( $_ ); }
		else{ $domain_links .= qq( <a href="http://$_/jak/index.cgi?mode=vadhistory&amp;file=$file">$_</a> ); }
		}
		$domain_links = qq(<div class="domain_links">ドメイン： $domain_links</div>);
	}

# 存在を
my(%admin_member_fook) = Mebius::Admin::MemberFookFile("File-check-error",$main::in{'file'});

my(%admin_member) = Mebius::Admin::MemberFile("File-check-error",$admin_member_fook{'id'});

# 管理記録を取得
&get_base_admin_login_history();

# 出席簿を取得
&get_attend_admin_login_history();

# レス履歴を取得
&get_restory_admin_login_history();

# タイトル定義
$sub_title = qq($admin_member{'name'} : 管理記録);

# HTML
my $print =  qq(
<h1>$admin_member{'name'}の記録</h1>
$domain_links
$member_line
$base_line
$restory_line
$attend_line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# 削除レコードを取得
#-----------------------------------------------------------

sub get_base_admin_login_history{

# リターン
if($in{'type'} eq "attend" || $in{'type'} eq "restory"){ return; }

open(IN,"_adhistory/${file}_adhistory.cgi");
my $top = <IN>; chomp $top;
my($lasttime,$ymd,$delcount,$res) = split(/<>/,$top);
close(IN);

$base_line = qq(
<h2>レコード</h2>
<ul>
<li>削除実行 <strong class="red">$delcount回</strong>
<li>レス回数 <strong class="red">$res回</strong>
<li>最終管理 $ymd
</ul>
);

}

#-----------------------------------------------------------
# 出席簿を取得
#-----------------------------------------------------------
sub get_attend_admin_login_history{

# 局所化
my($i,$hit,$redo,$saveym,$nowtime);

# リターン
if($in{'type'} eq "restory"){ return; }

# 曜日
my @wdays = ("日","月","火","水","木","金","土");

# 現在時刻
$nowtime = $time;

# 出席ファイルを開く
open(IN,"_adhistory/${file}_attend.cgi");
while(<IN>){
$i++;
if($i > 5 && $in{'type'} ne "attend"){ last; }
if($i >= 2){ $nowtime -= 24*60*60; }
my($day,$month,$year,$wday) = (localtime($nowtime))[3..6];
$year += 1900; $month += 1;
$wday = $wdays[$wday];

my($dyear,$dmonth,$dday,$dwday) = split(/<>/);
my($vwday);


if($in{'type'} eq "attend" && "$year-$month" ne $saveym){
$saveym = "$year-$month";
$attend_line .= qq(<h3>$year年$month月</h3>);
}

if($wday eq "日"){ $vwday = qq(<span class="red">($wday)</span>); }
elsif($wday eq "土"){ $vwday = qq(<span class="blue">($wday)</span>); }
else{ $vwday = qq(($wday)); }

if("$year-$month-$day" ne "$dyear-$dmonth-$dday" && $redo < 100){
$attend_line .= qq(<li><strike>$year/$month/$day $vwday</strike>);
$redo++;
redo;
}



$attend_line .= qq(<li>$year/$month/$day $vwday);

$hit++;

}
close(IN);

$attend_line = qq(
<h2><a href="$script?mode=vadhistory&amp;file=$file&amp;type=attend">出席簿</a></h2>
<span class="guide">※管理モードにアクセスすると記録されます（サーバー毎）。</span>
<ul>$attend_line</ul>
);

}

#-----------------------------------------------------------
# レス履歴を取得
#-----------------------------------------------------------
sub get_restory_admin_login_history{

# 局所化
my($i);

# リターン
if($in{'type'} eq "attend"){ return; }

open(IN,"_adhistory/${file}_restory.cgi");
while(<IN>){
$i++;
if($i > 20 && $in{'type'} ne "restory"){ last; }
chomp;
my($key,$title,$sub,$moto,$no,$res,$time,$date,$category) = split(/<>/,$_);
$restory_line .= qq(<tr><td><a href="$moto.cgi?mode=view&amp;no=$no">＠</a> <a href="$moto.cgi?mode=view&amp;no=$no#S$res">$sub</a> &gt; <a href="$moto.cgi?mode=view&amp;no=$no&amp;No=$res#S$res">No.$res</a></td><td><a href="$moto.cgi">$title</a></td><td>$date</td></tr>);
}
close(IN);
$restory_line = qq(<h2><a href="$script?mode=vadhistory&amp;file=$file&amp;type=restory">レス履歴</a></h2><table>$restory_line</table>);

}



#-----------------------------------------------------------
#-----------------------------------------------------------

sub do_renew_myhistory{

# 局所化
my($plus_delcount,$plus_res) = @_;
my($flag);

# フラグを立てる
if(@_){ $flag = 1; }

# 記録ファイルを開く
open(IN,"<","./_adhistory/${admy_file}_adhistory.cgi");
flock(IN,1);
my $top = <IN>; chomp $top;
my($lasttime,$ymd,$delcount,$res) = split(/<>/,$top);
close(IN);

# データ変更
$delcount += $plus_delcount;
$res += $plus_res;

	# 出席簿をつける
	if($ymd ne "$thisyear-$thismonth-$today"){ $flag = 1; &renew_attend(); }

# 追加する行
$line = qq($time<>$thisyear-$thismonth-$today<>$delcount<>$res<>\n);

	# 記録ファイルを更新する
	if($flag){
		Mebius::Fileout(undef,"_adhistory/${admy_file}_adhistory.cgi",$line);
	}


}

#-----------------------------------------------------------
# 出席簿をつける
#-----------------------------------------------------------
sub renew_attend{

my($now_date_mulit) = Mebius::now_date_multi();

# 追加する行
my $line .= qq($thisyear<>$thismonth<>$today<>$now_date_multi->{'weekday'}<>\n);

# 出席ファイルを開く
open(IN,"<","_adhistory/${admy_file}_attend.cgi");
while(<IN>){ $line .= $_; }
close(IN);

# 出席ファイルを更新する
open(OUT,">","_adhistory/${admy_file}_attend.cgi");
print OUT $line;
close(OUT);
chmod($logpms,"_adhistory/${admy_file}_attend.cgi");


}

#-----------------------------------------------------------
# 呼びかけテンプレ
#-----------------------------------------------------------

sub get_calltemplate{

# 局所化
my($line);

# CSS定義
$css_text .= qq(
div.template1{background-color:#fff;text-indent:0.5em;}
div.template2{background-color:#ccc;text-indent:0.5em;}
div.template3{background-color:#f9e;text-indent:0.5em;}
div.template4{background-color:#9ff;text-indent:0.5em;}
div.template5{background-color:#ff3;text-indent:0.5em;}
div.template6{background-color:#f99;text-indent:0.5em;}
div.template7{background-color:#4f4;text-indent:0.5em;}
td.template{border:dashed 1px #0a0;padding:0.5em;line-height:1.7;word-spacing:1.1em;font-size:80%;color:#f00;}
);

# テンプレートをゲット
($line) .= &get_templatetext;
$line .= $redcard;

# テンプレートの調整
$line =~ s/%/%25/g;
$line =~ s/\[br\]/\r/g;
$line =~ s/>>/&gt;/g;
$line =~ s/\n//g;
$line =~ s/\r/\\n/g;

return($line);

}

#-----------------------------------------------------------
# テンプレートを取得
#-----------------------------------------------------------
sub get_templatetext{

# 局所化
my($line);

#-----------------------------------------------------------
# 基本
#-----------------------------------------------------------
$line .= '

<div class="template1">
<strong>基本</strong> 
<a href="javascript:template(\'\r
恐れ入りますが、一部投稿を削除させていただきました。\r
\r\')">削除</a> 

<a href="javascript:template(\'\r
メビウスリングのガイドを、改めてご確認ください。\r
http://mb2.jp/wiki/guid/\r
\r\')">ガイド</a> 

<a href="javascript:template(\'\r
投稿ミスを削除させていただきました。（投稿先の間違え、二重投稿、文字化けなど）\r
\r\')">ミス</a> 

<a href="javascript:template(\'\r
本人様からの依頼を受け、削除させていただきました。\r
\r\')">本人</a> 

<a href="javascript:template(\'\r
大変申し訳ありませんが、\r
（たとえば外部サイトなどから）複数人でお越しになり、一斉に書き込む行為はご遠慮ください\r\r
特に次のような行為は禁止させていただきます。\r\r
・記事に関係のない書き込み\r
・他ユーザー様の反応を試す行為\r
・ＡＡの書き込み、卑猥な言葉の書き込み\r\r
他ユーザー様の迷惑になると判断した投稿については、管理者の判断で削除させていただく場合がございます。\r
\r\')">来訪</a> 

<a href="javascript:template(\'\r
安全のために、必ず次のことを実践してください。\r
「怪しいサイトに行かない」「怪しいコマンドを実行しない」など……。\r
これを守らないと、あなたのパソコンや、あなた自身に危険になることがあります。\r
http://mb2.jp/wiki/guid/%A5%C8%A5%E9%A5%C3%A5%D7%B2%F3%C8%F2%CB%A1\r
\r\')">トラップ</a> 

<a href="javascript:template(\'\r
管理者の判断により、特例削除をおこなわせていただきました。\r\r
削除理由：\r
\r\')">特例削除</a> 

<strong>疑問</strong> 

<a href="javascript:template(\'\r
こちらによくある質問がまとめられています。\r
大変お手数ですが、ぜひ次のガイドをご覧ください。\r\r
●削除Ｑ＆Ａ - 削除についてのＱ＆Ａです。\r
\r\')">削除Ｑ＆Ａ</a> 

<a href="javascript:template(\'\r
もし今回の管理についてご連絡があります場合は、\r
大変お手数ですが、こちらの記事まで書き込みをお願いします。\r
https://mb2.jp/jak/qst.cgi?mode=view&no=1973\r
\r\')">疑問連絡</a> 

<a href="javascript:template(\'\r
誠に恐れ入りますが、管理者から回答がお約束できないケースがございます。\r
大変お手数ではございますが「管理者回答」のガイドをご覧ください。\r
\r\')">管理者回答</a> 


</div>
';


#-----------------------------------------------------------
# 発言
#-----------------------------------------------------------
$line .= '
<div class="template2">
<strong>発言</strong> 

<a href="javascript:template(\'\r
恐れ入りますが、言葉遣いや投稿マナーには充分ご注意ください。\r
本サイトの利用にあたって、ガイドの再確認をお願いいたします。\r
\r
●ガイドの確認 - マナー違反 / マナーＱ＆Ａ　\r
\r\')">マナー</a> 

<a href="javascript:template(\'\r
＠皆様\r\r
ルール違反に反応すると、逆効果になってしまう場合があります。\r
普段の書き込みを続けたり、削除依頼を出すことで対処をお願いいたします。\r
\r
●ガイドの確認 - ルール違反への対処\r
\r\')">過剰反応</a> 

<a href="javascript:template(\'\r
お手数ですが、他の方を不快にする内容などは、なるべく伏せて引用をお願いします。\r
（引用文の中の表現により、削除させていただく場合があります）\r
\r\')">引用部分</a> 

<strong>其他</strong> 

<a href="javascript:template(\'\r
「住所」「本名」「電話番号」など個人情報や、\r
プライベートな情報を書き込んだり、人に求めたりしないでください。\r
後で大きな問題になることがあります。\r
\r\')" class="red">個人情報</a> 

<a href="javascript:template(\'\r
一部で「文通」「本名」「電話」「メール」などのお話がありましたが、\r
本サイトで「個人情報の交換・掲載」をなさいませんでしたか？\r
もしその場合は、お手数ですがご自身で削除依頼をお願いいたします。\r
http://aurasoul.mb2.jp/_delete/\r\r
また、ごくプライベートな書き込みは問題が起きやすいため、管理者の判断で削除させていただく場合があります。\r
\r\')" class="red">個人情報？</a> 

<a href="javascript:template(\'\r
メビウスリングにはＩＤシステムがあり、\r
筆名を変えて書き込んだ場合も、同一のＩＤが表示されます。\r\r
変わらないマークをつける場合は「トリップ」をご利用ください。\r
http://aurasoul.mb2.jp/wiki/guid/%A5%C8%A5%EA%A5%C3%A5%D7\r
\r\')">自演/トリップ</a> 


</div>
';


#-----------------------------------------------------------
# 迷惑
#-----------------------------------------------------------
$line .= '
<div class="template1">
<strong>迷惑</strong>  

<a href="javascript:template(\'\r
すみませんが、他の方の迷惑となる書き込みはご遠慮ください。\r
管理者の判断で、投稿を削除させていただく場合があります。\r
\r\')">迷惑(全般)</a> 

<a href="javascript:template(\'\r
恐れ入りますが、本サイトでは次のような投稿はご遠慮ください。\r
\r
◆「マルチポスト」「宣伝行為」「チェーン投稿」「不適切なリンク」など、他の方の迷惑となるもの。\r
◆「ＡＡ」「記号の羅列」「過剰なデコレーション」「文字数稼ぎ」「無意味な文章の投稿」「改行のしすぎ」「無断転載」など、本サイトの文章ルールに反するもの。\r
\r
上記のものは、管理者が削除させていただく場合がございます。\r
\r\')">迷惑(チェーン,ＡＡ,羅列,マルチ,宣伝等)</a> 

<strong>雑談/カテ</strong> 

<a href="javascript:template(\'\r
失礼ですが、一部が「雑談化」してしまっているようにお見受けします。\r
\r
カテゴリと関係のない話（たとえば「会社の話」「学校の話」など）は、\r
大変お手数ですが、自由掲示板などに移動をお願いします。\r
http://mb2.jp/_ztd/\r\r

●ガイドの確認 - 雑談化\r
\r\')">雑談化</a> 

<a href="javascript:template(\'\r
失礼ですが、一部が「チャット化」しているようにお見受けします。\r
「チャット化」が起こると「掲示板」の良さが失われてしまうことがあります。\r
\r
申し訳ありませんが「１行レス」「挨拶だけの書き込み」「落ち報告」などは控え、\r
「掲示板」として使っていただくよう、ご協力をお願いいたします。\r\r
●ガイドの確認 - チャット化\r
\r\')">チャット化</a> 

<a href="javascript:template(\'\r
失礼ですが、一部の投稿が、記事本来の目的からそれているようにお見受けします。\r
お手数ですが、掲示板のルールやテーマをご確認の上、 \r
検索機能を活用し、ふさわしい記事を選んで書き込んでください。\r
\r\')">カテ違い(レス)</a> 

<a href="javascript:template(\'\r
失礼ですが一部の投稿が、記事のテーマから逸れているようにお見受けします。\r\r
サイト利用マナーについてお話が続く場合は、\r
恐れ入りますが「メビウスリング質問運営」への移動をお願いいたします。\r
http://aurasoul.mb2.jp/_qst/2403.html\r
\r\')">カテ違い(マナー)</a> 

</div>
';



#-----------------------------------------------------------
# ナンパ
#-----------------------------------------------------------
$line .= '
<div class="template3">
<strong>出会</strong> 

<a href="javascript:template(\'\r
恐れ入りますが、メールアドレスの投稿は削除対象となります。\r
メールアドレスを書き込んだり、人に聞いたりする行為はご遠慮ください。\r
\r\')">メルアド</a> 

<a href="javascript:template(\'\r
恐れ入りますが本サイトでは、
「メル友募集」「文通相手募集」などの募集や、\r
「恋人募集」「カップル作り」「会う約束」「バーチャルデート」などの行為はご遠慮いただいております。\r
節度を保っての利用をお願いいたします。\r
\r\')">出会い系</a> 

<strong>性的</strong> 

<a href="javascript:template(\'\r
恐れ入りますが、本サイトでは次のような投稿は禁止となっています。\r
\r
・（相談、議論以外での）性的な投稿\r
・フォローのない「性の報告」「性の質問」\r
・性の相談で、配慮のない書き込み\r
\r
上記のようなものは、管理者の判断で削除させていただく場合があります。\r
\r\')">性的</a> 
</div>';


#-----------------------------------------------------------
# 創作
#-----------------------------------------------------------
$line .= '
<div class="template4">
<strong>創作</strong> 

<a href="javascript:template(\'\r
お手数ですが「性的表現のルール」の再チェックをお願いいたします。\r
http://aurasoul.mb2.jp/wiki/guid/%C0%AD%C5%AA%A4%CA%C9%BD%B8%BD\r
\r\')">性的-創</a> 

<a href="javascript:template(\'\r
お手数ですが「ショッキングな表現のルール」の再チェックをお願いいたします。\r
http://aurasoul.mb2.jp/wiki/guid/%CB%BD%CE%CF%C5%AA%A4%CA%C9%BD%B8%BD\r
\r\')">ショック-創</a> 

<a href="javascript:template(\'\r
「創作題名のルール」をご存知ですか。\r
次のページをよく読み、創作的な雰囲気について配慮をお願いいたします。\r
http://aurasoul.mb2.jp/wiki/guid/%C1%CF%BA%EE%A4%CE%C2%EA%CC%BE\r
\r\')">題名-創</a> 

<a href="javascript:template(\'\r
すみませんが創作の場では、過ぎた雑談はご遠慮ください。\r
かわりに、交流専用の掲示板をご利用ください。\r
●ガイドの確認 - 雑談化\r
\r\')">雑談-創</a> 

<a href="javascript:template(\'\r
この作品に「模倣・盗作・二次創作」などの理由で削除依頼が出されました。\r
お手数ですが、http://aurasoul.mb2.jp/_delete/155.html　まで連絡をお願いできないでしょうか\r
\r\')">盗作-創</a> 

<a href="javascript:template(\'\r
盗作・模倣などについて議論が続く場合は、\r
お手数ですが、マナー掲示板に移動をお願いします。\r
http://aurasoul.mb2.jp/wiki/guid/%C5%F0%BA%EE%A1%A2%CC%CF%CA%EF%A4%CE%CF%C3%A4%B7%B9%E7%A4%A4\r
\r\')">盗作議論-創</a> 

<a href="javascript:template(\'\r
無断で、他の人の作品を続ける行為はご遠慮ください。\r
自分の作品を書く場合は、記事の新規投稿をお願いします。\r
\r\')">勝手-創</a> 

<a href="javascript:template(\'\r
お手数ですが作品批評にあたって、こちらのガイドをご覧ください。\r
http://aurasoul.mb2.jp/wiki/guid/%BA%EE%C9%CA%C8%E3%C9%BE\r
\r\')">批評-創</a> 

<a href="javascript:template(\'\r
すみませんがメビウスリングでは、二次創作は禁止となっています。\r
\r\')">二次-創</a> 

<a href="javascript:template(\'\r
小説を書くときは、執筆歴などに合わせて、場所をお決めください。\r
たとえば書き始めて１年未満であれば「初心者のための小説投稿城」がおすすめです。\r
http://aurasoul.mb2.jp/_sst/\r
\r\')">初心-創</a> 

<a href="javascript:template(\'\r
ト書き小説を書くときは「ト書き小説投稿城」がおすすめです。\r
http://aurasoul.mb2.jp/_tog/\r
\r\')">ト書-創</a> 

<a href="javascript:template(\'\r
「年齢設定」を偽って、制限のある記事を閲覧することはご遠慮ください。\r
\r\')">年齢偽</a> 

<a href="javascript:template(\'\r
お手数ですが、小説へのコメント・感想はサブ記事をご利用ください。\r
\r\')">サブ</a> 
</div>
';


#-----------------------------------------------------------
# 記事
#-----------------------------------------------------------
$line .= '
<div class="template7">
<strong>記事</strong> 

<a href="javascript:template(\'\r
同じ掲示板に、同じテーマの記事はひとつまでです。\r
お手数ですが、検索機能などを使って同種の記事を探し、そちらをご利用ください。\r
\r\')">重複</a> 

<a href="javascript:template(\'\r
この記事は、ジャンル分けがされていません。\r
記事はうまくジャンル分けしてくださるようお願いいたします。\r
http://aurasoul.mb2.jp/wiki/guid/%A5%B8%A5%E3%A5%F3%A5%EB%CA%AC%A4%B1\r
\r\')">ジャンル分け</a> 

<a href="javascript:template(\'\r
お手数ですが、掲示板のテーマから外れた記事は移動をお願いします。\r
掲示板のルールや、趣旨をよくご覧の上、 \r
ふさわしい場所を選んで書き込んでください。\r
\r\')">カテ違い(記事)</a> 

<a href="javascript:template(\'\r
すみませんが、本サイトでは次のような記事を作ることは出来ません。\r
\r
・「年齢／学年／性別／居住地」で参加者を決めた記事\r
・「私と話そう」「ＡさんとＢさんの話し場」など、個人的な記事\r
・テーマが複数あったり、題名やテーマが不明瞭な記事や、単発記事\r
\r
お手数ですが、新規投稿のルールにあわせて、記事の作り直しをお願いします。\r
\r\')">テーマ/限定/個人的</a> 

<strong>修正</strong> 

<a href="javascript:template(\'\r
事情により、&gt;&gt;0 の内容（または題名）を変更させていただきました。\r
\r\')">題・内容修正</a> 


</div>
';


#-----------------------------------------------------------
# カテゴリ
#-----------------------------------------------------------
$line .= '
<div class="template5">
<strong>カテ</strong> 

<a href="javascript:template(\'\r
お手数ですが回答にあたって「相談」のガイドをごらんください。\r
\r\')">相談(答)</a> 

<a href="javascript:template(\'\r
議論にあたって、こちらのガイドを再確認お願いいたします。\r
ほとんどの場合、問題となるのは「意見の内容」ではなく「投稿マナー」です。\r
http://aurasoul.mb2.jp/wiki/guid/%B5%C4%CF%C0\r
http://aurasoul.mb2.jp/wiki/guid/%B7%FA%C0%DF%C5%AA%A4%CA%B5%C4%CF%C0\r
\r\')">議論</a> 


<a href="javascript:template(\'\r
恐れ入りますが「なりきりのクオリティ」のガイドはご覧いただけましたか。\r
http://aurasoul.mb2.jp/wiki/guid/%A4%CA%A4%EA%A4%AD%A4%EA%A4%CE%A5%AF%A5%AA%A5%EA%A5%C6%A5%A3\r\r
たとえば次のようななりきりは、基準に満たないものとして削除、ロックなどさせていただく場合があります。\r\r
・ロールや情景描写がなく、ほとんど「キャラの台詞のみ」で回っている記事。\r
・チャット化のように、３０～５０文字程度のレスがほとんどを占める記事。\r
・男女の参加人数を決めての恋愛記事（カップリング）の記事。\r\r

ロール練習記事はこちらです：\r
http://mb2.jp/_nmn/?mode=find&word=%97%FB%8FK\r
\r\')">なりクオ</a> 

<a href="javascript:template(\'\r
なりきり掲示板では「リアル雑談」は禁止です。\r
リアル雑談をする場合は、専用板に移動をお願いします。\r
http://mb2.jp/_nzz/\r
\r\')">なりリア雑談</a> 

<a href="javascript:template(\'\r
なりきりカテゴリの性質上、\r
「本体会話」のみの書き込みは、極力控えてください。\r
\r\')">本体会話</a> 

<a href="javascript:template(\'\r
「通信」「対戦待ち合わせ」などの話はカテゴリ違いです。\r
ゲーム掲示板（通信・交換）に移動してください。 \r
http://mb2.jp/_gko/\r
\r\')">ゲーム通信</a>

</div>
';


#-----------------------------------------------------------
# 警告
#-----------------------------------------------------------
$line .= '
<div class="template6">
<strong>警告</strong> 

<a href="javascript:template(\'\r
ルール注意の呼びかけをご覧いただけましたか？\r
サイト利用にあたっては、メビウスリングのルールをよくご確認ください。\r
http://aurasoul.mb2.jp/wiki/guid/\r
\r\')">誘導</a> 

<a href="javascript:template(\'\r
ルール注意の呼びかけをご覧いただけましたか？\r
本サイトのルールをお守りいただけない場合、\r
すみませんが、今後の利用をお断りさせていただく場合があります。\r
\r\')">強い誘導</a> 

<a href="javascript:template(\'\r
本サイトのルールを遵守お願いいたします。\r
違反が続く場合、今後「投稿制限」「プロバイダ連絡」などの処置を取らせていただく場合があります。\r
\r\')">一般通告</a> 

<a href="javascript:template(\'\r
メビウスリングへの全ての投稿は、あなたの接続情報と一緒に保存されています。\r
悪質な投稿があった場合、プロバイダ（ネット会社・携帯会社）へ連絡を取ると、\r
あなたの本人の身元が割り出され、ネット接続停止、退会処分などの対応がなされる場合があります。\r
本サイト、ならびに本サイトユーザー様への迷惑行為はご遠慮頂くようお願いいたします。\r
\r\')">最後通告</a> 


<a href="javascript:template(\'\r
意図的な荒らしはご遠慮ください。投稿制限、プロバイダ連絡などの対象とさせていただく場合があります。\r
\r\')">意図的</a> 

<a href="javascript:template(\'\r
犯罪につながる書き込みや、\r
それをあおる投稿をしないでください。\r
裁判所、警察などから連絡があった場合、\r
本サイトの接続データを提出させていただく場合があります。\r
\r\')">犯罪</a> 

</div>
';

return($line);

}


1;

1;




