
use strict;
package Mebius::Crypt;
use Digest::MD5;

#-----------------------------------------------------------
# MD5 暗号化
#-----------------------------------------------------------
sub crypt_text{

# 宣言
my($type,$text,$salt,$maxlength) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # 処理タイプを展開
my($pass,$original_hash,$md5_flag,$crypt_flag,@salts,$salt_foreach,$return_salt,$digest_hex_flag,$digest_base64_flag);

	# 暗号化タイプを定義
	if($main::alocal_mode && $type !~ /Digest/){ $crypt_flag = 1; }
	if($type{'MD5'}){ $md5_flag = 1; }
	elsif($type{'Crypt'}){ $crypt_flag = 1; }
	elsif($type{'Digest-hex'}){ $digest_hex_flag = 1; }
	elsif($type{'Digest-base64'}){ $digest_base64_flag = 1; }

	# タイプ定義がない場合、パスワード（元テキスト）の長さから暗号化タイプを定義
	else{
		if(length($text) > 8){ $md5_flag = 1; }
		else{ $crypt_flag = 1; }
	}

	# ソルトがない場合はランダムに生成する
	if(!$salt){
		$salt = "Random";
	}

	# ソルトを配列化 ( リファレンス渡し )
	if($type{'Use-array-salt'} || ref $salt eq "ARRAY"){
		@salts = @$salt;
	}
	# ソルトを配列化 ( 変数渡し )
	else{
			foreach(split(/,|=>/,$salt,-1)){
				push(@salts,$_);
			}
	}

	# ソルトの個数だけ暗号化
	foreach $salt_foreach (@salts){

			# ソルトをランダムに生成する場合
			if($salt_foreach eq "Random" || $salt_foreach eq ""){


					# ソルトの長さ ( ここで @salts の内容も書き換わる )
					if($crypt_flag){ ($salt_foreach) = Mebius::Crypt::char(undef,2); }
					else{ ($salt_foreach) = Mebius::Crypt::char(undef,30); }

			}

			# Crypt
			if($crypt_flag){
				$text = crypt($text,$salt_foreach);
				$original_hash = $text;
				$text =~ s/^..//;
			}

			# Digest MD5
			elsif($digest_hex_flag){
				($text) = Digest::MD5::md5_hex($text,$salt_foreach);
			}
			# Digest MD5
			elsif($digest_base64_flag){
				($text) = Digest::MD5::md5_base64($text,$salt_foreach);
			}

			# MD5 ( サーバー依存 )
			else{
				$text = crypt($text, '$1$' . $salt_foreach);
				$original_hash = $text;
				$text =~ s/^......//;
			}

			# ソルトをすべて返すための処理
			if($return_salt){ $return_salt .= qq(,$salt_foreach); }
			else{ $return_salt .= $salt_foreach; }

	}




	# 重要
	$pass = $text;

	# 特殊記号を削除する
	if($type =~ /Not-special-charactor/){
		$pass =~ s/[^0-9a-zA-Z]//g;
	}

	# ハッシュを切り取る
	if($maxlength){ $pass = substr($pass,0,$maxlength); }

# リターン
return($pass,@salts);

}

#-----------------------------------------------------------
# ダイジェストハッシュ化
#-----------------------------------------------------------
sub digest{

my($text,$salts) = @_;

my(@relay) = Mebius::Crypt::crypt_text("Digest-base64",$text,$salts);

@relay;

}

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 別名
#-----------------------------------------------------------
sub char{

my $self = shift;
my $length = shift;
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

$char;

}




1;
