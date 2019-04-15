
# �p�b�P�[�W�錾
package Mebius;
use strict;

#-----------------------------------------------------------
# ���_�C���N�g����
#-----------------------------------------------------------

sub Mkdir{

# �錾
my($type,$directory,$dirpms) = @_;

# �p�[�~�b�V�����w�肪�Ȃ��ꍇ
#if($dirpms eq ""){ $dirpms = $main::dirpms; }
if($dirpms eq ""){ $dirpms = 0707; }

	# ���Ƀf�B���N�g�������݂���ꍇ�A���^�[��
	#if(-d $directory){ return(); }
	#if(-e $directory){ return(); }

# �f�B���N�g�����쐬
my $mkdir_flag = mkdir($directory,$dirpms);

	# �p�[�~�b�V������ύX
	if($mkdir_flag){

		# ���݂�umask ���L��
		my $umask = umask();

		# umask��ύX
		umask(0);

		# �p�[�~�b�V�����ύX
		chmod($directory,$dirpms);

		# umask �����ɖ߂�
		if($umask){ umask($umask); }
		else{ umask(18); }

	}


# ���^�[��
return($mkdir_flag);

}

1;

