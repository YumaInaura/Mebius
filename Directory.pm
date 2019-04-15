
use strict;
use File::Path;
package Mebius;


#-----------------------------------------------------------
# �f�B���N�g���쐬
#-----------------------------------------------------------
sub mkdir{

my($self) = Mkdir(undef,@_);

}
#-----------------------------------------------------------
# �f�B�e�N�g���쐬
#-----------------------------------------------------------
sub Mkdir{

# �錾
my($type,$directory,$dirpms) = @_;

	# �p�[�~�b�V�����w�肪�Ȃ��ꍇ
	#if($dirpms eq ""){ $dirpms = $main::dirpms; }
	if($dirpms eq ""){ $dirpms = 0707; }

# ���݂�umask ���L��
#my $umask = umask();

# umask��ύX
#umask(0);

# �f�B���N�g�����쐬
my $mkdir_flag = mkdir($directory,$dirpms);

	# umask �����ɖ߂�
	#if($umask){ umask($umask); }
	#else{ umask(18); }
	#else{ umask(0070); }

# ���^�[��
return($mkdir_flag);

}

#-----------------------------------------------------------
# ���_�C���N�g����
#-----------------------------------------------------------
sub mkpath{

# �錾
my($directory,$dirpms) = @_;

	# �p�[�~�b�V�����w�肪�Ȃ��ꍇ
	#if($dirpms eq ""){ $dirpms = $main::dirpms; }
	if($dirpms eq ""){ $dirpms = 0707; }

# ���݂�umask ���L��
#my $umask = umask();

# umask��ύX
#umask(0);

# �f�B���N�g�����쐬
my $success_num = File::Path::mkpath($directory,0,$dirpms);

	# umask �����ɖ߂�
	#if($umask){ umask($umask); }
	#else{ umask(18); }

$success_num;

}




#-----------------------------------------------------------
# IP�A�h���X�V�t�H�[�}�b�g
#-----------------------------------------------------------
sub GetDirectory{

# �錾
my($type,$directory) = @_;
my(undef,undef,$how_before_time_file_delete) = @_ if($type =~ /Delete-all-file/);
my($directory_handler);

# �f�B���N�g�����J��
opendir($directory_handler,$directory);
my @directory = grep(!/^\./,readdir($directory_handler));
close ($directory_handler);

	# ���� �戵���ӂ̏����I�I ����

	# ���� �f�B���N�g�����̃t�@�C����S�폜 ����
	if($type =~ /Delete-all-file/){

		# �Ǐ���
		my($file_name_foreach);

			# �W�J
			foreach $file_name_foreach (@directory){

					# ����̊g���q�ȊO�͍폜���Ȃ��悤��
					if($file_name_foreach !~ /\.(cgi|dat|log)$/){ next; }

				# �t�@�C���f�[�^���擾
				my($stat) = Mebius::file_stat("Get-stat","$directory/$file_name_foreach");

					# �폜����
					if(time > $stat->{'last_modified'} + $how_before_time_file_delete){ unlink("$directory/$file_name_foreach"); }

			}
	}

# ���^�[��
return(@directory);

}

package Mebius::Directory;

#-----------------------------------------------------------
# �f�B���N�g�����e���Q�b�g
#-----------------------------------------------------------
sub get_directory{

my(@self) = Mebius::GetDirectory(undef,@_);

}

#-----------------------------------------------------------
# �X���b�V�����Ō�ɕt���Ă��Ȃ��p�X�ɃX���b�V����t����
#-----------------------------------------------------------
sub adjust_slash{


	foreach(@_){
			if($_ !~ m!\$!){
				$_ = "$_/";
			}
	}

}
1;
