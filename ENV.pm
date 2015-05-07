
use strict;
use Mebius::HTML;
package Mebius::ENV;

#-----------------------------------------------------------
# エラーを出す場合は、必ず Dos カウントも増加させる
#-----------------------------------------------------------
sub WrongCheck{

# 宣言
my($maxData,$env_length,$env_cookie_length);

	# 最大許容バイト数を定義
	if($ENV{'CONTENT_TYPE'} =~ /^multipart\/form-data;/){ $maxData = 1*1000*1000; }
	else{	$maxData = 1*1000*1000; }

	# STDIN を読み込む前にバイト数チェック
	if($ENV{'CONTENT_LENGTH'} > $maxData) {
		Mebius::AccessLog(undef,"Max-data-post","バイト数： $ENV{'CONTENT_LENGTH'}");
		#Mebius::Dos::AccessFile("New-access Renew",$ENV{'REMOTE_ADDR'});
		Mebius::Dos::access();
		Mebius::SimpleHTML({  FromEncoding => "sjis" , Message => "投稿量が大きすぎます。 $ENV{'CONTENT_LENGTH'} byte" });
	}

	# ENVの長さをチェック
	foreach(%ENV){

			# Cookie の場合は別計算
			if($_ =~ /^(HTTP_)(COOKIE|REFERER)$/){
				$env_cookie_length += length($ENV{$_});
			}

			# ユーザー環境変数のみ
			elsif($_ =~ /^HTTP_/){
				$env_length += length($ENV{$_});
			}

	}

	# エラー
	if($env_length >= 2*1000 || $env_cookie_length >= 20*1000){
		Mebius::AccessLog(undef,"ENV-data-size-over","バイト数： $env_length");
		#Mebius::Dos::AccessFile("New-access Renew",$ENV{'REMOTE_ADDR'});
		Mebius::Dos::access();
			if(Mebius::alocal_judge()){
				Mebius::SimpleHTML({  FromEncoding => "sjis" , Message => "変な送信です。$env_length / $env_cookie_length" });
			}
			else{
				Mebius::SimpleHTML({  FromEncoding => "sjis" , Message => "変な送信です。" });
			}

	}

}


1;