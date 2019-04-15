
use strict;
use Mebius::Crypt;
package Mebius::Auth;

#-----------------------------------------------------------
# パスワード照合
#-----------------------------------------------------------
sub Password{

# 宣言
my($type,$input_password) = @_;
my(undef,undef,@relay_salt) = @_ if($type =~ /New-password/);
my(undef,undef,$salt,$collation_crypted_password) = @_ if($type =~ /Collation-password/);
my($successed_flag,$crypted_pasword_return);
my($new_salt,$check_line,$collation_type);

	# リターン
	if($type =~ /Collation-password/){
			if($input_password eq ""){ return(); }
			if($salt eq ""){ return(); }
			if($collation_crypted_password eq ""){ return(); }
	}

	# パスワード作成
	if($type =~ /New-password/){

		# 局所化
		my($i_salts,$relay_salt,$renew_account_salt,@use_salt);

				# ソルトが指定されている場合はそれを使う
				if($type =~ /Relay-salt/){
					@use_salt = @relay_salt;
				}
				# ソルトがない場合はランダムに生成
				else{
					for(1..10){ push(@use_salt,"Random"); }
				}

			# 独自のソルトで多重暗号化
			my($crypted_password,@new_salt) = Mebius::Crypt::crypt_text("Digest-base64 Use-array-salt",$input_password,\@use_salt);

			# 内部でさらに多重暗号化
			($crypted_password) = Mebius::Crypt::crypt_text("Digest-base64",$crypted_password,"sreif6guj3CI,bTLMos5ykbnh,bgvTZLpsfM3x,4nuFb94cuZOW,xK4eG6t6omhj");

			# リターン
			return($crypted_password,@new_salt);
	}

	# CryptとMD5、4種類の方式でパスワードを照合
	elsif($type =~ /Collation-password/){

		# 局所化
		my(@relay_salt);
		
		# 複数のソルトを分解
		foreach(split(/,/,$salt,-1)){
			push(@relay_salt,$_);
		}


		# パスワードの照合
		my($crypted_password1) = Mebius::Crypt::crypt_text("Crypt",$input_password,$relay_salt[0]);
		# 2010/05/21 に実装 ？ => http://aurasoul.mb2.jp/_amb/815.html
		my($crypted_password2) = Mebius::Crypt::crypt_text("MD5",$input_password,$relay_salt[0]);
		# 2011/10/24 に実装 ?
		my($crypted_password3) = Mebius::Crypt::crypt_text("MD5",$input_password,"$relay_salt[0],Dy,8D,bs,ac,fh,jr,dg,a5,6J,Bs");
		my($crypted_password4) = Mebius::Crypt::crypt_text("Digest-base64 Use-array-salt",$input_password,\@relay_salt);
		($crypted_password4) = Mebius::Crypt::crypt_text("Digest-base64",$crypted_password4,"sreif6guj3CI,bTLMos5ykbnh,bgvTZLpsfM3x,4nuFb94cuZOW,xK4eG6t6omhj");

			# CRYPT
			if($crypted_password1 eq $collation_crypted_password){
				$successed_flag = 1;
				$crypted_pasword_return = $crypted_password1;
				$collation_type = "Crypt";
			}
			# MD5
			elsif($crypted_password2 eq $collation_crypted_password){
				$successed_flag = 1;
				$crypted_pasword_return = $crypted_password2;
				$collation_type = "MD5";
			}
			# MD5 x 10
			elsif($crypted_password3 eq $collation_crypted_password){
				$successed_flag = 1;
				$crypted_pasword_return = $crypted_password3;
				$collation_type = "MD5-Mutli";
			}
			# MD5 x Multi
			elsif($crypted_password4 eq $collation_crypted_password){
				$successed_flag = 1;
				$crypted_pasword_return = $crypted_password4;
				$collation_type = "Digest-base64-multi";
			}

		# 成功フラグと暗号化されたパスワードをリターン
		return($successed_flag,$crypted_pasword_return,$collation_type);
	}



}


#-----------------------------------------------------------
# パスワード再設定メールのための記号化
#-----------------------------------------------------------
sub ResetPasswordChar{

# 宣言
my($type,$password) = @_;
my($char,$i);

	# リターン
	if($password eq ""){ return(); }

	# パスワードの多重暗号化
	($char) = Mebius::Crypt::crypt_text("MD5",$password,"Dy,8D,bs,ac,fh,jr,dg,a5,6J,Bs");

	# 現在の日付を取得
	my(%today) = Mebius::Getdate("Get-hash",time);
	my(%yesterday) = Mebius::Getdate("Get-hash",time-(24*60*60));
	my(%tomorrow) = Mebius::Getdate("Get-hash",time+(24*60*60));

	# 日付で暗号化 (今日)
	my($char_today) = Mebius::Crypt::crypt_text("MD5",$char,$today{'yearf_omited'});
	($char_today) = Mebius::Crypt::crypt_text("MD5",$char_today,$today{'monthf'});
	($char_today) = Mebius::Crypt::crypt_text("MD5 Not-special-charactor",$char_today,$today{'dayf'});

	# 日付で暗号化 (昨日)
	my($char_yesterday) = Mebius::Crypt::crypt_text("MD5",$char,$yesterday{'yearf_omited'});
	($char_yesterday) = Mebius::Crypt::crypt_text("MD5",$char_yesterday,$yesterday{'monthf'});
	($char_yesterday) = Mebius::Crypt::crypt_text("MD5 Not-special-charactor",$char_yesterday,$yesterday{'dayf'});

	# 日付で暗号化 (明日)
	my($char_tomorrow) = Mebius::Crypt::crypt_text("MD5",$char,$tomorrow{'yearf_omited'});
	($char_tomorrow) = Mebius::Crypt::crypt_text("MD5",$char_tomorrow,$tomorrow{'monthf'});
	($char_tomorrow) = Mebius::Crypt::crypt_text("MD5 Not-special-charactor",$char_tomorrow,$tomorrow{'dayf'});

return($char_today,$char_yesterday,$char_tomorrow);

}



#-----------------------------------------------------------
# メール発行
#-----------------------------------------------------------
sub PasswordMemoEmail{

# 宣言
my($type,$email,$account,$password) = @_;
my($mail_body,$mail_subject);

	# 件名
	if($type =~ /New-account/){
		$mail_subject = qq(【$main::titleへの登録が完了しました】);
	}
	elsif($type =~ /Reset-password/){
		$mail_subject = qq(【パスワードを再設定しました - $main::title】);
	}
	else{
		return();
	}

# 文章

$mail_body .= qq(アカウント名： $account\n);
#$mail_body .= qq(パスワード： $password\n);
#$mail_body .= qq(パスワード： *******\n);

$mail_body .= qq(\nログイン： $main::auth_url\n);

# メール送信
Mebius::Email::send_email(undef,$email,$mail_subject,$mail_body);


}

#-----------------------------------------------------------
# 新しいソルトを展開
#-----------------------------------------------------------
sub NewSaltForeach{

# 宣言
my($type,@new_salt) = @_;
my($renew_account_salt,$relay_salt,$i_salts);

	# 複数のソルトを展開
	foreach(@new_salt){
		$i_salts++;
			# アカウントに記録する内容
			if($renew_account_salt){ $renew_account_salt .= qq(,$_); } 
			else{ $renew_account_salt .= qq($_); }
			# リダイレクトする内容
			if($relay_salt){ $relay_salt .= qq(,$_); }
			else{ $relay_salt .= qq($_); }
	}

return($renew_account_salt,$relay_salt);

}


1;
