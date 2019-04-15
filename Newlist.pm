
use strict;
package Mebius::Newlist;

#-----------------------------------------------------------
# １日の総レス数を記録
#-----------------------------------------------------------
sub Daily{

# 宣言
my($type) = @_;
my($handler,$directory,$renewline,$logfile);

# ファイル定義
$logfile = "${main::int_dir}_sinnchaku/_daily_record/${main::thisyear}_${main::thismonth}_${main::today}_daily_record.log";

# ファイルが無い場合は作成する
if(!-f $logfile){ Mebius::Fileout("NEWMAKE",$logfile); }

# ファイルを開く
open($handler,"+<$logfile");

# ファイルロック
if($type =~ /Renew/){ flock($handler,2); }

# トップデータを分解
chomp(my $top1 = <$handler>);
chomp(my $top2 = <$handler>);

my($tres_bbs) = split(/<>/,$top1);
my($resdiary_auth,$postdiary_auth,$comment_auth) = split(/<>/,$top2);

	# カウントを増やす
	if($type =~ /Renew/){ 
			if($type =~ /Comment-auth/){ $comment_auth++; }
			elsif($type =~ /Resdiary-auth/){ $resdiary_auth++; }
			elsif($type =~ /Postdiary-auth/){ $postdiary_auth++; }
	}

# 更新する行を定義
$renewline .= qq($tres_bbs<>\n);
$renewline .= qq($resdiary_auth<>$postdiary_auth<>$comment_auth<>\n);

	# ファイル更新
	if($type =~ /Renew/){
		seek($handler,0,0);
		truncate($handler,tell($handler));
		print $handler $renewline;
	}

close($handler);

return();

}

1;
