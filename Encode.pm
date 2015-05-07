
use strict;

# パッケージ宣言
package Mebius;

#-----------------------------------------------------------
# エンコード 別名
#-----------------------------------------------------------
sub encode_text{
Encode(undef,@_);
}


#-----------------------------------------------------------
# エンコード 
#-----------------------------------------------------------
sub Encode{

# 宣言
my($type,@text) = @_;
my(@text_encoded);

	# リターン
	if(!@text){ return; }

	# 展開
	foreach(@text){

		# 定義
		my $check = $_;

		# スラッシュ等を回避
		if($type =~ /Escape-slash/){
			$check =~ s/\//!/g;
			$check =~ s/\./~/g;
		}

		# エンコード
		$check =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
		$check =~ tr/ /+/;
			
		push(@text_encoded,$check);
	}

	# リターン
	if(wantarray){
		return(@text_encoded);
	}
	else{
		return($text_encoded[0]);
	}

}

#-----------------------------------------------------------
# エンコード 
#-----------------------------------------------------------
sub decode_text{
 Decode(undef,@_);

}

#-----------------------------------------------------------
# エンコード 
#-----------------------------------------------------------
sub Decode{

# 宣言
my($type,@text) = @_;
my(@text_decoded);

	# リターン
	if(!@text){ return; }

	# 展開
	foreach(@text){

		# 定義
		my $check = $_;

		# デコード
		$check =~ tr/+/ /;
		$check =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("H2", $1)/eg;
		push(@text_decoded,$check);
	}


	# リターン
	if(wantarray){
		return(@text_decoded);
	}
	else{
		return($text_decoded[0]);
	}

}

#-----------------------------------------------------------
# エスケープ処理 
#-----------------------------------------------------------
sub escape{

# 宣言
my($type,$val) = @_;

	# URL/メールアドレスの区切り文字をエスケープする場合
	if($type =~ /Space/){
		$val =~ s/(<br>|\s|　|★|☆)//g;
		return($val);
	}

# タイプ
#if($type !~ /NOTAND/ && $type !~ /Not-amp/){ $val =~ s/&/&amp;/g; }

# 二重エスケープを防止
$val =~ s/&amp;/&/g;

# エスケープする
$val =~ s/&/&amp;/g; 
$val =~ s/"/&quot;/g;
$val =~ s/'/&#039;/g;
$val =~ s/</&lt;/g;
$val =~ s/>/&gt;/g;
$val =~ s/\r\n/<br>/g;
	if($type !~ /Not-br/){ $val =~ s/(\r|\n)/<br>/g; }
$val =~ s/\0//g;

# リターン
return($val);

}


#-----------------------------------------------------------
# デスケープ
#-----------------------------------------------------------
sub Descape{

# 宣言
my($type,$value) = @_;

# エスケープする
$value =~ s/&quot;/"/g;
$value =~ s/&#0?39;/'/g;
$value =~ s/&apos;/'/g;
$value =~ s/&lt;/</g;
$value =~ s/&gt;/>/g;
	if($type !~ /Not-br/){ $value =~ s/<br>/\n/g; }

# タイプ
if($type !~ /Not-and/){ $value =~ s/&amp;/&/g; }

# ダイヤを元に戻す
if($type =~ /Deny-diamond/){ $value =~ s/<>//g; }

# リターン
return($value);

}





1;
