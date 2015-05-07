
use strict;
use Mebius::HTML;
package Mebius::ENV;

#-----------------------------------------------------------
# �G���[���o���ꍇ�́A�K�� Dos �J�E���g������������
#-----------------------------------------------------------
sub WrongCheck{

# �錾
my($maxData,$env_length,$env_cookie_length);

	# �ő勖�e�o�C�g�����`
	if($ENV{'CONTENT_TYPE'} =~ /^multipart\/form-data;/){ $maxData = 1*1000*1000; }
	else{	$maxData = 1*1000*1000; }

	# STDIN ��ǂݍ��ޑO�Ƀo�C�g���`�F�b�N
	if($ENV{'CONTENT_LENGTH'} > $maxData) {
		Mebius::AccessLog(undef,"Max-data-post","�o�C�g���F $ENV{'CONTENT_LENGTH'}");
		#Mebius::Dos::AccessFile("New-access Renew",$ENV{'REMOTE_ADDR'});
		Mebius::Dos::access();
		Mebius::SimpleHTML({  FromEncoding => "sjis" , Message => "���e�ʂ��傫�����܂��B $ENV{'CONTENT_LENGTH'} byte" });
	}

	# ENV�̒������`�F�b�N
	foreach(%ENV){

			# Cookie �̏ꍇ�͕ʌv�Z
			if($_ =~ /^(HTTP_)(COOKIE|REFERER)$/){
				$env_cookie_length += length($ENV{$_});
			}

			# ���[�U�[���ϐ��̂�
			elsif($_ =~ /^HTTP_/){
				$env_length += length($ENV{$_});
			}

	}

	# �G���[
	if($env_length >= 2*1000 || $env_cookie_length >= 20*1000){
		Mebius::AccessLog(undef,"ENV-data-size-over","�o�C�g���F $env_length");
		#Mebius::Dos::AccessFile("New-access Renew",$ENV{'REMOTE_ADDR'});
		Mebius::Dos::access();
			if(Mebius::alocal_judge()){
				Mebius::SimpleHTML({  FromEncoding => "sjis" , Message => "�ςȑ��M�ł��B$env_length / $env_cookie_length" });
			}
			else{
				Mebius::SimpleHTML({  FromEncoding => "sjis" , Message => "�ςȑ��M�ł��B" });
			}

	}

}


1;