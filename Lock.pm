
package Mebius;
use strict;

#-----------------------------------------------------------
# ロック開始 - strict
#-----------------------------------------------------------
sub lock{

# 宣言
my($init_directory) = Mebius::BaseInitDirectory();
my($lock) = @_;
my($lockfile,$retry,$auto_delete_second);

	# ロックファイル定義
	if($lock eq "") { die("Perl Die! Lock name is empty."); }

	# 汚染チェック
	if($lock =~ /([^\w\-\%])/){
		Mebius::AccessLog(undef,"Lockfile-strange-name","Lock $lock");
		return();
	}

# ファイル定義
$lockfile = "${init_directory}_lock/${lock}.lock";

	# 前回のロックファイルが残っている場合、自動削除する秒数 ( ファイル作成時刻から数える)
	if(Mebius::alocal_judge()){ $auto_delete_second = 5; } else{ $auto_delete_second = 15; }

# 古いロックは削除
my($stat) = Mebius::file_stat(undef,$lockfile);
	if($stat->{'e'}){
		my $time = time;
			if($stat->{'create_second'} >= $auto_delete_second) { unlink($lockfile); }
			else{ warn("Perl warn! lock is busy. create_second is $stat->{'create_second'} , create_time is $stat->{'create_time'}  . all stat is $stat->{'all_stat'}"); }
	}

# トライ回数を定義 ( 1 に設定するとリトライしない )
my $retry = 3;

	# ローカル環境でロック
	if(Mebius::alocal_judge()){
			if(-e "$lockfile"){ main::error("処理が混雑しています。画面を更新するか、もういちど送信してください。"); }
		open(LOCK_OUT,">",$lockfile);
		print LOCK_OUT "1";
		close(LOCK_OUT);
	}

	# symlink関数式ロック
	else {
			while (!symlink(".", $lockfile)) {
					if(--$retry <= 0){ main::error("処理が混雑しています。画面を更新するか、もういちど送信してください。"); }
				sleep(1);
			}
	}


# フラグオン
$main::lockflag = $lock;

}

#-----------------------------------------------------------
# ロック解除 - strict
#-----------------------------------------------------------
sub unlock{

# 宣言
my($init_directory) = Mebius::BaseInitDirectory();
my($lock) = @_;
my($lockfile);

	# ロックファイル定義
	if($lock eq "") { die("Perl Die! Unlock name is empty."); }

	# 汚染チェック
	if($lock =~ /([^\w\-\%])/){
		Mebius::AccesLog(undef,"Lockfile-strange-name","Unlock : $lock");
		return();
	}

# ファイル定義
$lockfile = "${init_directory}_lock/${lock}.lock";

# ロック削除
unlink($lockfile);

# フラグオフ
$main::lockflag = 0;

}


1;
