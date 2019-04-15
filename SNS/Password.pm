
use strict;
use Mebius::Crypt;
package Mebius::Auth;

#-----------------------------------------------------------
# �p�X���[�h�ƍ�
#-----------------------------------------------------------
sub Password{

# �錾
my($type,$input_password) = @_;
my(undef,undef,@relay_salt) = @_ if($type =~ /New-password/);
my(undef,undef,$salt,$collation_crypted_password) = @_ if($type =~ /Collation-password/);
my($successed_flag,$crypted_pasword_return);
my($new_salt,$check_line,$collation_type);

	# ���^�[��
	if($type =~ /Collation-password/){
			if($input_password eq ""){ return(); }
			if($salt eq ""){ return(); }
			if($collation_crypted_password eq ""){ return(); }
	}

	# �p�X���[�h�쐬
	if($type =~ /New-password/){

		# �Ǐ���
		my($i_salts,$relay_salt,$renew_account_salt,@use_salt);

				# �\���g���w�肳��Ă���ꍇ�͂�����g��
				if($type =~ /Relay-salt/){
					@use_salt = @relay_salt;
				}
				# �\���g���Ȃ��ꍇ�̓����_���ɐ���
				else{
					for(1..10){ push(@use_salt,"Random"); }
				}

			# �Ǝ��̃\���g�ő��d�Í���
			my($crypted_password,@new_salt) = Mebius::Crypt::crypt_text("Digest-base64 Use-array-salt",$input_password,\@use_salt);

			# �����ł���ɑ��d�Í���
			($crypted_password) = Mebius::Crypt::crypt_text("Digest-base64",$crypted_password,"sreif6guj3CI,bTLMos5ykbnh,bgvTZLpsfM3x,4nuFb94cuZOW,xK4eG6t6omhj");

			# ���^�[��
			return($crypted_password,@new_salt);
	}

	# Crypt��MD5�A4��ނ̕����Ńp�X���[�h���ƍ�
	elsif($type =~ /Collation-password/){

		# �Ǐ���
		my(@relay_salt);
		
		# �����̃\���g�𕪉�
		foreach(split(/,/,$salt,-1)){
			push(@relay_salt,$_);
		}


		# �p�X���[�h�̏ƍ�
		my($crypted_password1) = Mebius::Crypt::crypt_text("Crypt",$input_password,$relay_salt[0]);
		# 2010/05/21 �Ɏ��� �H => http://aurasoul.mb2.jp/_amb/815.html
		my($crypted_password2) = Mebius::Crypt::crypt_text("MD5",$input_password,$relay_salt[0]);
		# 2011/10/24 �Ɏ��� ?
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

		# �����t���O�ƈÍ������ꂽ�p�X���[�h�����^�[��
		return($successed_flag,$crypted_pasword_return,$collation_type);
	}



}


#-----------------------------------------------------------
# �p�X���[�h�Đݒ胁�[���̂��߂̋L����
#-----------------------------------------------------------
sub ResetPasswordChar{

# �錾
my($type,$password) = @_;
my($char,$i);

	# ���^�[��
	if($password eq ""){ return(); }

	# �p�X���[�h�̑��d�Í���
	($char) = Mebius::Crypt::crypt_text("MD5",$password,"Dy,8D,bs,ac,fh,jr,dg,a5,6J,Bs");

	# ���݂̓��t���擾
	my(%today) = Mebius::Getdate("Get-hash",time);
	my(%yesterday) = Mebius::Getdate("Get-hash",time-(24*60*60));
	my(%tomorrow) = Mebius::Getdate("Get-hash",time+(24*60*60));

	# ���t�ňÍ��� (����)
	my($char_today) = Mebius::Crypt::crypt_text("MD5",$char,$today{'yearf_omited'});
	($char_today) = Mebius::Crypt::crypt_text("MD5",$char_today,$today{'monthf'});
	($char_today) = Mebius::Crypt::crypt_text("MD5 Not-special-charactor",$char_today,$today{'dayf'});

	# ���t�ňÍ��� (���)
	my($char_yesterday) = Mebius::Crypt::crypt_text("MD5",$char,$yesterday{'yearf_omited'});
	($char_yesterday) = Mebius::Crypt::crypt_text("MD5",$char_yesterday,$yesterday{'monthf'});
	($char_yesterday) = Mebius::Crypt::crypt_text("MD5 Not-special-charactor",$char_yesterday,$yesterday{'dayf'});

	# ���t�ňÍ��� (����)
	my($char_tomorrow) = Mebius::Crypt::crypt_text("MD5",$char,$tomorrow{'yearf_omited'});
	($char_tomorrow) = Mebius::Crypt::crypt_text("MD5",$char_tomorrow,$tomorrow{'monthf'});
	($char_tomorrow) = Mebius::Crypt::crypt_text("MD5 Not-special-charactor",$char_tomorrow,$tomorrow{'dayf'});

return($char_today,$char_yesterday,$char_tomorrow);

}



#-----------------------------------------------------------
# ���[�����s
#-----------------------------------------------------------
sub PasswordMemoEmail{

# �錾
my($type,$email,$account,$password) = @_;
my($mail_body,$mail_subject);

	# ����
	if($type =~ /New-account/){
		$mail_subject = qq(�y$main::title�ւ̓o�^���������܂����z);
	}
	elsif($type =~ /Reset-password/){
		$mail_subject = qq(�y�p�X���[�h���Đݒ肵�܂��� - $main::title�z);
	}
	else{
		return();
	}

# ����

$mail_body .= qq(�A�J�E���g���F $account\n);
#$mail_body .= qq(�p�X���[�h�F $password\n);
#$mail_body .= qq(�p�X���[�h�F *******\n);

$mail_body .= qq(\n���O�C���F $main::auth_url\n);

# ���[�����M
Mebius::Email::send_email(undef,$email,$mail_subject,$mail_body);


}

#-----------------------------------------------------------
# �V�����\���g��W�J
#-----------------------------------------------------------
sub NewSaltForeach{

# �錾
my($type,@new_salt) = @_;
my($renew_account_salt,$relay_salt,$i_salts);

	# �����̃\���g��W�J
	foreach(@new_salt){
		$i_salts++;
			# �A�J�E���g�ɋL�^������e
			if($renew_account_salt){ $renew_account_salt .= qq(,$_); } 
			else{ $renew_account_salt .= qq($_); }
			# ���_�C���N�g������e
			if($relay_salt){ $relay_salt .= qq(,$_); }
			else{ $relay_salt .= qq($_); }
	}

return($renew_account_salt,$relay_salt);

}


1;
