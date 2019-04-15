
use strict;
package Mebius;

#-----------------------------------------------------------
# MD5 暗号化
#-----------------------------------------------------------
sub OldCrypt{

# 宣言
my($type,$text,$salt,$maxlength) = @_;
my($pass,$original_hash,$md5_flag,$crypt_flag,@salts);

	# 暗号化タイプを定義
	if($main::alocal_mode){ $crypt_flag = 1; }
	if($type =~ /MD5/){ $md5_flag = 1; }
	elsif($type =~ /Crypt/){ $crypt_flag = 1; }

	# タイプ定義がない場合、パスワード（元テキスト）の長さから暗号化タイプを定義
	else{
		if(length($text) > 8){ $md5_flag = 1; }
		else{ $crypt_flag = 1; }
	}

	# 種がない場合はランダムに生成する
	srand(time ^ ($$ + ($$ << 15)));
	if(!$salt){
		@salts = ( "A".."Z", "a".."z", "0".."9", ".", "/" );
		$salt = $salts[int(rand(64))] . $salts[int(rand(64))];
	}

	# 暗号化
	if($crypt_flag){ $pass = crypt($text,$salt); }
	else{ $pass = crypt($text, '$1$' . $salt); }

# オリジナルのハッシュを記憶
$original_hash = $pass;

	# 先頭データを削除
	if($crypt_flag){ $pass =~ s/^..//; }
	else{ $pass =~ s/^......//; }

	# 特殊記号 [ / . = ]を削除する
	if($type =~ /Not-special-charactor/){
		$pass =~ s/[^0-9a-zA-Z]//g;
	}

	# ハッシュを切り取る
	if($maxlength){ $pass = substr($pass,0,$maxlength); }


return($pass,$salt,$original_hash);
}

#-----------------------------------------------------------
# ランダムな文字列を生成する
#-----------------------------------------------------------
sub Char{

# 宣言
my($type,$length) = @_;
my(@charpass,$char);

	# 排他処理
	if(!$length){ $length = 10; }
	if($length > 1000){ $length = 1000; }

# ランダムテキストの素
@charpass = ('a'..'z', 'A'..'Z', '0'..'9');

	# 管理番号を割り振る
	for(1..$length){
		$char .= $charpass[int(rand(@charpass))];
	}

# リターン
return($char);

}



#if($type =~ /Account/ && $main::master_addr eq $main::addr){ main::error("text $text / encpass $pass / salt $salt / md5 $md5_flag / crypt $crypt_flag"); }

1;
