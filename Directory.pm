
use strict;
use File::Path;
package Mebius;


#-----------------------------------------------------------
# ディレクトリ作成
#-----------------------------------------------------------
sub mkdir{

my($self) = Mkdir(undef,@_);

}
#-----------------------------------------------------------
# ディテクトリ作成
#-----------------------------------------------------------
sub Mkdir{

# 宣言
my($type,$directory,$dirpms) = @_;

	# パーミッション指定がない場合
	#if($dirpms eq ""){ $dirpms = $main::dirpms; }
	if($dirpms eq ""){ $dirpms = 0707; }

# 現在のumask を記憶
#my $umask = umask();

# umaskを変更
#umask(0);

# ディレクトリを作成
my $mkdir_flag = mkdir($directory,$dirpms);

	# umask を元に戻す
	#if($umask){ umask($umask); }
	#else{ umask(18); }
	#else{ umask(0070); }

# リターン
return($mkdir_flag);

}

#-----------------------------------------------------------
# リダイレクト処理
#-----------------------------------------------------------
sub mkpath{

# 宣言
my($directory,$dirpms) = @_;

	# パーミッション指定がない場合
	#if($dirpms eq ""){ $dirpms = $main::dirpms; }
	if($dirpms eq ""){ $dirpms = 0707; }

# 現在のumask を記憶
#my $umask = umask();

# umaskを変更
#umask(0);

# ディレクトリを作成
my $success_num = File::Path::mkpath($directory,0,$dirpms);

	# umask を元に戻す
	#if($umask){ umask($umask); }
	#else{ umask(18); }

$success_num;

}




#-----------------------------------------------------------
# IPアドレス之フォーマット
#-----------------------------------------------------------
sub GetDirectory{

# 宣言
my($type,$directory) = @_;
my(undef,undef,$how_before_time_file_delete) = @_ if($type =~ /Delete-all-file/);
my($directory_handler);

# ディレクトリを開く
opendir($directory_handler,$directory);
my @directory = grep(!/^\./,readdir($directory_handler));
close ($directory_handler);

	# ★★ 取扱注意の処理！！ ★★

	# ★★ ディレクトリ内のファイルを全削除 ★★
	if($type =~ /Delete-all-file/){

		# 局所化
		my($file_name_foreach);

			# 展開
			foreach $file_name_foreach (@directory){

					# 特定の拡張子以外は削除しないように
					if($file_name_foreach !~ /\.(cgi|dat|log)$/){ next; }

				# ファイルデータを取得
				my($stat) = Mebius::file_stat("Get-stat","$directory/$file_name_foreach");

					# 削除する
					if(time > $stat->{'last_modified'} + $how_before_time_file_delete){ unlink("$directory/$file_name_foreach"); }

			}
	}

# リターン
return(@directory);

}

package Mebius::Directory;

#-----------------------------------------------------------
# ディレクトリ内容をゲット
#-----------------------------------------------------------
sub get_directory{

my(@self) = Mebius::GetDirectory(undef,@_);

}

#-----------------------------------------------------------
# スラッシュが最後に付いていないパスにスラッシュを付ける
#-----------------------------------------------------------
sub adjust_slash{


	foreach(@_){
			if($_ !~ m!\$!){
				$_ = "$_/";
			}
	}

}
1;
