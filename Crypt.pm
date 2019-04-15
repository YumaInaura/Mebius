
use strict;
package Mebius::Crypt;
use Digest::MD5;

#-----------------------------------------------------------
# MD5 �Í���
#-----------------------------------------------------------
sub crypt_text{

# �錾
my($type,$text,$salt,$maxlength) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my($pass,$original_hash,$md5_flag,$crypt_flag,@salts,$salt_foreach,$return_salt,$digest_hex_flag,$digest_base64_flag);

	# �Í����^�C�v���`
	if($main::alocal_mode && $type !~ /Digest/){ $crypt_flag = 1; }
	if($type{'MD5'}){ $md5_flag = 1; }
	elsif($type{'Crypt'}){ $crypt_flag = 1; }
	elsif($type{'Digest-hex'}){ $digest_hex_flag = 1; }
	elsif($type{'Digest-base64'}){ $digest_base64_flag = 1; }

	# �^�C�v��`���Ȃ��ꍇ�A�p�X���[�h�i���e�L�X�g�j�̒�������Í����^�C�v���`
	else{
		if(length($text) > 8){ $md5_flag = 1; }
		else{ $crypt_flag = 1; }
	}

	# �\���g���Ȃ��ꍇ�̓����_���ɐ�������
	if(!$salt){
		$salt = "Random";
	}

	# �\���g��z�� ( ���t�@�����X�n�� )
	if($type{'Use-array-salt'} || ref $salt eq "ARRAY"){
		@salts = @$salt;
	}
	# �\���g��z�� ( �ϐ��n�� )
	else{
			foreach(split(/,|=>/,$salt,-1)){
				push(@salts,$_);
			}
	}

	# �\���g�̌������Í���
	foreach $salt_foreach (@salts){

			# �\���g�������_���ɐ�������ꍇ
			if($salt_foreach eq "Random" || $salt_foreach eq ""){


					# �\���g�̒��� ( ������ @salts �̓��e����������� )
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

			# MD5 ( �T�[�o�[�ˑ� )
			else{
				$text = crypt($text, '$1$' . $salt_foreach);
				$original_hash = $text;
				$text =~ s/^......//;
			}

			# �\���g�����ׂĕԂ����߂̏���
			if($return_salt){ $return_salt .= qq(,$salt_foreach); }
			else{ $return_salt .= $salt_foreach; }

	}




	# �d�v
	$pass = $text;

	# ����L�����폜����
	if($type =~ /Not-special-charactor/){
		$pass =~ s/[^0-9a-zA-Z]//g;
	}

	# �n�b�V����؂���
	if($maxlength){ $pass = substr($pass,0,$maxlength); }

# ���^�[��
return($pass,@salts);

}

#-----------------------------------------------------------
# �_�C�W�F�X�g�n�b�V����
#-----------------------------------------------------------
sub digest{

my($text,$salts) = @_;

my(@relay) = Mebius::Crypt::crypt_text("Digest-base64",$text,$salts);

@relay;

}

#-----------------------------------------------------------
# �I�u�W�F�N�g�֘A�t��
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# �ʖ�
#-----------------------------------------------------------
sub char{

my $self = shift;
my $length = shift;
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

$char;

}




1;
