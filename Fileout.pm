
# �p�b�P�[�W�錾
package Mebius;
use strict;

#-----------------------------------------------------------
# �W�����v
#-----------------------------------------------------------
sub Fileout{

# �錾
my($type,$file,@line) = @_;
my($filehandle1,$filehandle2,$filehandle3,$file_f_flag);
my($logpms) = ($main::logpms);

	# �p�[�~�b�V����
	if($type =~ /Permission-(0700)/){ $logpms = 0700; }

	# ���^�[��
	if($type !~ /NEWMAKE/ && $type !~ /New-file/ && $type !~ /(Can-Zero|Allow-empty)/){		# �t�@�C���쐬�����ł���΁A�J���̏������݂�������
		if(@line <= 0){
			&Mebius::AccessLog(undef,"Fileout-empty-error","$file");
			&main::error("�������ޓ��e������܂���B");
		}
	}

	# �ǋL���ă��^�[������ꍇ
	if($type =~ /Plusfile/){
		open($filehandle3,">>$file");
		print $filehandle3 @line;
		close($filehandle3);
		&Mebius::Chmod(undef,$file);
		return(1);
	}

	# �V�K�t�@�C���݂̂�����ă��^�[������ꍇ
	if($type =~ /(NEWMAKE|New-file)/){ return(1); }

	# �������ݓ��e������ꍇ�A�t�@�C�����X�V
	if(@line >= 1 || $type =~ /(Can-Zero|Allow-empty)/){

		# �t�@�C�����J��
		open($filehandle1,"+<$file") && ($file_f_flag = 1);

			# ���t�@�C�������ɑ��݂���ꍇ
			if($file_f_flag){

					# �t�@�C���̓�\�������݂��֎~����ꍇ
					if($type =~ /Deny-f-file-return/){
						close($filehandle1);
						return();
					}
					# �t�@�C����ǉ���������
					else{
						flock($filehandle1,2);
						seek($filehandle1,0,0);
						truncate($filehandle1,tell($filehandle1));
						print $filehandle1 @line;
						close($filehandle1);
						&Mebius::Chmod(undef,$file);
					}

			}

			# ���t�@�C�����͂��߂č��ꍇ
			else{

				# �t�@�C���n���h�������
				close($filehandle1);

				# �t�@�C����������
				open($filehandle2,">$file");
				print $filehandle2 @line;
				close($filehandle2);
				&Mebius::Chmod(undef,$file);
			}


	}

# ���^�[��
return(1);

}

#-----------------------------------------------------------
# �p�[�~�b�V�����ύX
#-----------------------------------------------------------
sub Chmod{

# �錾
my($type,$file,$permission) = @_;

	# �p�[�~�b�V���������w��̏ꍇ
	if(!defined $permission){ $permission = 0606; }

	# �l�̃`�F�b�N
	unless($permission =~ /^(\d{3,4})$/){ return(); }

my $flag = chmod($permission,$file);

return($flag);

}

1;
