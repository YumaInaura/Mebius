
# パッケージ宣言
package Mebius;
use strict;

#-----------------------------------------------------------
# リダイレクト処理
#-----------------------------------------------------------

sub Mkdir{

# 宣言
my($type,$directory,$dirpms) = @_;

# パーミッション指定がない場合
#if($dirpms eq ""){ $dirpms = $main::dirpms; }
if($dirpms eq ""){ $dirpms = 0707; }

	# 既にディレクトリが存在する場合、リターン
	#if(-d $directory){ return(); }
	#if(-e $directory){ return(); }

# ディレクトリを作成
my $mkdir_flag = mkdir($directory,$dirpms);

	# パーミッションを変更
	if($mkdir_flag){

		# 現在のumask を記憶
		my $umask = umask();

		# umaskを変更
		umask(0);

		# パーミッション変更
		chmod($directory,$dirpms);

		# umask を元に戻す
		if($umask){ umask($umask); }
		else{ umask(18); }

	}


# リターン
return($mkdir_flag);

}

1;

