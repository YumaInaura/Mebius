
# パッケージ宣言
package Mebius;
use strict;

#-----------------------------------------------------------
# ジャンプ
#-----------------------------------------------------------
sub Fileout{

# 宣言
my($type,$file,@line) = @_;
my($filehandle1,$filehandle2,$filehandle3,$file_f_flag);
my($logpms) = ($main::logpms);

	# パーミッション
	if($type =~ /Permission-(0700)/){ $logpms = 0700; }

	# リターン
	if($type !~ /NEWMAKE/ && $type !~ /New-file/ && $type !~ /(Can-Zero|Allow-empty)/){		# ファイル作成だけであれば、カラの書き込みを許可する
		if(@line <= 0){
			&Mebius::AccessLog(undef,"Fileout-empty-error","$file");
			&main::error("書き込む内容がありません。");
		}
	}

	# 追記してリターンする場合
	if($type =~ /Plusfile/){
		open($filehandle3,">>$file");
		print $filehandle3 @line;
		close($filehandle3);
		&Mebius::Chmod(undef,$file);
		return(1);
	}

	# 新規ファイルのみを作ってリターンする場合
	if($type =~ /(NEWMAKE|New-file)/){ return(1); }

	# 書き込み内容がある場合、ファイルを更新
	if(@line >= 1 || $type =~ /(Can-Zero|Allow-empty)/){

		# ファイルを開く
		open($filehandle1,"+<$file") && ($file_f_flag = 1);

			# ●ファイルが既に存在する場合
			if($file_f_flag){

					# ファイルの二十書き込みを禁止する場合
					if($type =~ /Deny-f-file-return/){
						close($filehandle1);
						return();
					}
					# ファイルを追加書き込み
					else{
						flock($filehandle1,2);
						seek($filehandle1,0,0);
						truncate($filehandle1,tell($filehandle1));
						print $filehandle1 @line;
						close($filehandle1);
						&Mebius::Chmod(undef,$file);
					}

			}

			# ●ファイルをはじめて作る場合
			else{

				# ファイルハンドルを閉じる
				close($filehandle1);

				# ファイル書き込み
				open($filehandle2,">$file");
				print $filehandle2 @line;
				close($filehandle2);
				&Mebius::Chmod(undef,$file);
			}


	}

# リターン
return(1);

}

#-----------------------------------------------------------
# パーミッション変更
#-----------------------------------------------------------
sub Chmod{

# 宣言
my($type,$file,$permission) = @_;

	# パーミッションが無指定の場合
	if(!defined $permission){ $permission = 0606; }

	# 値のチェック
	unless($permission =~ /^(\d{3,4})$/){ return(); }

my $flag = chmod($permission,$file);

return($flag);

}

1;
