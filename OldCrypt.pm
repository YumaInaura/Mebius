
use strict;
package Mebius;

#-----------------------------------------------------------
# MD5 �Í���
#-----------------------------------------------------------
sub OldCrypt{

# �錾
my($type,$text,$salt,$maxlength) = @_;
my($pass,$original_hash,$md5_flag,$crypt_flag,@salts);

	# �Í����^�C�v���`
	if($main::alocal_mode){ $crypt_flag = 1; }
	if($type =~ /MD5/){ $md5_flag = 1; }
	elsif($type =~ /Crypt/){ $crypt_flag = 1; }

	# �^�C�v��`���Ȃ��ꍇ�A�p�X���[�h�i���e�L�X�g�j�̒�������Í����^�C�v���`
	else{
		if(length($text) > 8){ $md5_flag = 1; }
		else{ $crypt_flag = 1; }
	}

	# �킪�Ȃ��ꍇ�̓����_���ɐ�������
	srand(time ^ ($$ + ($$ << 15)));
	if(!$salt){
		@salts = ( "A".."Z", "a".."z", "0".."9", ".", "/" );
		$salt = $salts[int(rand(64))] . $salts[int(rand(64))];
	}

	# �Í���
	if($crypt_flag){ $pass = crypt($text,$salt); }
	else{ $pass = crypt($text, '$1$' . $salt); }

# �I���W�i���̃n�b�V�����L��
$original_hash = $pass;

	# �擪�f�[�^���폜
	if($crypt_flag){ $pass =~ s/^..//; }
	else{ $pass =~ s/^......//; }

	# ����L�� [ / . = ]���폜����
	if($type =~ /Not-special-charactor/){
		$pass =~ s/[^0-9a-zA-Z]//g;
	}

	# �n�b�V����؂���
	if($maxlength){ $pass = substr($pass,0,$maxlength); }


return($pass,$salt,$original_hash);
}

#-----------------------------------------------------------
# �����_���ȕ�����𐶐�����
#-----------------------------------------------------------
sub Char{

# �錾
my($type,$length) = @_;
my(@charpass,$char);

	# �r������
	if(!$length){ $length = 10; }
	if($length > 1000){ $length = 1000; }

# �����_���e�L�X�g�̑f
@charpass = ('a'..'z', 'A'..'Z', '0'..'9');

	# �Ǘ��ԍ�������U��
	for(1..$length){
		$char .= $charpass[int(rand(@charpass))];
	}

# ���^�[��
return($char);

}



#if($type =~ /Account/ && $main::master_addr eq $main::addr){ main::error("text $text / encpass $pass / salt $salt / md5 $md5_flag / crypt $crypt_flag"); }

1;
