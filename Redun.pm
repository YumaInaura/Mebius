
package Mebius;
use strict;

#-----------------------------------------------------------
# 連続送信チェック
#-----------------------------------------------------------
sub Redun{

# 局所化
my($type,$file,$block_second,$maxline,$routin) = @_;
my($error_subroutin);
my($block_flag,$i,$next_time,$next_second,@line,$redun_handle);

# エラーサブルーチンを定義
if($routin){ $error_subroutin = $routin; } else { $error_subroutin = "main::error"; }

# ファイル定義
$file =~ s/[^0-9a-zA-Z\-_]//g;
if($file eq ""){ return; }

# 保存する行数を定義
if(!$maxline){ $maxline = 50; }

# 連続送信を禁止する秒
#if($main::alocal_mode){ $block_second = 5; }

# 待ち時間が指定されていない場合は、自動挿入
if(!$block_second){ $block_second = 5*60; }
if($main::alocal_mode){ $block_second = 5; }

my $directory = "${main::int_dir}_backup/_redun/";

# ファイルを開く
open($redun_handle,"${directory}${file}_redun.log");
	while(<$redun_handle>){
		chomp;
		my($lasttime,$date2,$addr2,$age2,$number2,$account2) = split(/<>/);
		my($flag);
			if($main::time < $lasttime + $block_second){
				if($addr2 && $addr2 eq $main::addr){ $flag = 1; }
				if($age2 && $age2 eq $main::agent && ($main::kaccess_one || $main::k_access)){ $flag = 2; }
				if($number2 && $number2 eq $main::cnumber){ $flag = 3; }
				if($account2 && $account2 eq $main::pmfile){ $flag = 4; }
				if($flag){
					$next_second = $lasttime + $block_second - $main::time;
					$block_flag = qq(連続送信は出来ません。あと $next_second秒 ほど後で送信してください。[ $flag ]);
				}
			}
		$i++;
		if($i < $maxline){ push(@line,"$_\n"); }
	}
close($redun_handle);

	# 残り秒数を計算
	if($next_second){
		if($next_second >= 1*60){ $next_time = int($next_second/60)+1 . qq(分); }
		else{ $next_time = $next_second . qq(秒); }
	}

	# データ取得のみで帰る場合
	if($type =~ /Get-only|Read-only/){ return($block_flag); }

	# エラーを表示する
	if($block_flag && $type !~ /Renew-only/){
		eval "&$error_subroutin($block_flag)";
	}

# 追加する行
unshift(@line,"$main::time<>$main::date<>$main::addr<>$main::agent<>$main::cnumber<>$main::pmfile<>\n");

# ファイルを更新
Mebius::Mkdir(undef,$directory);
Mebius::Fileout("","${main::int_dir}_backup/_redun/${file}_redun.log",@line);

# リターン
return($block_flag);

}

1;
