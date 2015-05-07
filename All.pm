
use strict;
use Mebius::Basic;
use Mebius::Directory;
use File::Copy::Recursive qw(rcopy);

package Mebius::BBS;

#-----------------------------------------------------------
# �S�Ă̌f����
#-----------------------------------------------------------
sub AllBBS{

# �錾
my($type) = @_;
my($directory_foreach,$line);

# �ݒ�f�B���N�g�����`
my $get_directory = "${main::int_dir}_init_bbs/";

# �R�s�[�� / �R�s�[�� �f�B���N�g��
#my @copy_directory = 
#(
#"${main::int_dir}<moto>_cnt->${main::int_dir}_bbs_data/_<moto>_bbs_data/->_crap_count_<moto>",
#"",
#"",
#""
#);

#"${main::int_dir}_thread_tag/<moto>_tag->${main::int_dir}_bbs_data/_<moto>_bbs_data/->_thread_tag_<moto>",

#../bsj/${moto}_log/
#../bsj/${moto}_cnt/
#../bsj/_sendmail/${moto}/
#../bsj/_kr/${moto}_kr/
#../bsj/_thread_tag/${moto}_tag/
#../bsj/${moto}_idx.log
#../bsj/${moto}_pst.log
#../bsj/_kr/$moto/
#../bsj/_handle/_${moto}_handle/
#../bsj/_bbs_index/_${moto}_index/ ( �R�s�[ )


# �f�B���N�g�����擾
my(@directory) = Mebius::GetDirectory(undef,$get_directory);

	# �f�B���N�g����W�J
	foreach $directory_foreach (@directory){

		# �Ǐ���
		my($copy_foreach);

		# �g���q�ƃt�@�C�����𕪉�
		my($moto2,$tail2) = split(/\./,$directory_foreach);

				# �������������ꍇ
				if($tail2 ne "ini"){ next; }
				if($moto2 =~ /\W/){ next; }

			# �\���p
			$line .= qq(\n<br$main::xclose>$moto2);

				# �f�B���N�g��������ĕύX����ꍇ
				if($type =~ /Rename-directory/){

					# �f�B���N�g���쐬 (��{)
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/");
					
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_pv_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_thread_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_kr_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_sendmail_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_handle_${moto2}");


# �f�B���N�g������ύX (PV)
#{
#	my $from_directory = "${main::int_dir}_pv/_${moto2}_pv/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_pv_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# �f�B���N�g������ύX (�L���f�[�^�̕ҏW����)
#{
#	my $from_directory = "${main::int_dir}_thread_edit_history/_${moto2}_thread_edit/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_thread_edit_history_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# �f�B���N�g������ύX (�M�������L���O)
#{
#	my $from_directory = "${main::int_dir}_handle/_bbs_ranking_handle/_${moto2}_ranking_handle/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_handle_ranking_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# �f�B���N�g������ύX (�L���^�O)
#{
#	my $from_directory = "${main::int_dir}_thread_tag/_${moto2}_tag/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_tag_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# �f�B���N�g������ύX (���m�点���[��)
#{
#	my $from_directory = "${main::int_dir}_sendmail/${moto2}/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_sendmail_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# �f�B���N�g������ύX (�֘A�L��)
#{
#	my $from_directory = "${main::int_dir}_kr/${moto2}/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_kr_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# �t�@�C���R�s�[ (�ߋ����O�C���f�b�N�X)
#my $copy_from_file = "${main::int_dir}${moto2}_pst.log";
#my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/${moto2}_pst.log";
#unlink($copy_to_file);
#&File::Copy::copy($copy_from_file,$copy_to_file);
#chmod($main::logpms,$copy_to_file);

# �t�@�C���R�s�[ (�ߋ����O�C���f�b�N�X)
for(1..10){
	my $copy_from_file = "${main::int_dir}${moto2}_pst${_}.log";
	my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/${moto2}_pst${_}.log";
	unlink($copy_to_file);
	&File::Copy::copy($copy_from_file,$copy_to_file);
	chmod($main::logpms,$copy_to_file);
}

# �t�@�C���R�s�[ (�f���C���f�b�N�X)
#my $copy_from_file = "${main::int_dir}${moto2}_idx.log";
#my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/index_${moto2}.log";
#unlink($copy_to_file);
#&File::Copy::copy($copy_from_file,$copy_to_file);
#chmod($main::logpms,$copy_to_file);

# �t�@�C���R�s�[ (PV�����L���O�t�@�C��)
#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_other_${moto2}");
#my $copy_from_file = "${main::int_dir}_pv_ranking/${moto2}_pvall.log";
#my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/pvall_${moto2}.log";
#my $unlink_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_other_${moto2}/pvall_${moto2}.log";
#unlink($copy_to_file);
#unlink($unlink_file);
#&File::Copy::copy($copy_from_file,$copy_to_file);
#chmod($main::logpms,$copy_to_file);

					#rmdir("${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}");


						# �R�s�[��/�R�s�[��̃f�B���N�g�����`
						#foreach $copy_foreach (@copy_directory){

							# ����
							#my($from_directory,$to_directory1,$to_directory2) = split(/->/,$copy_foreach);

								# ����
							#	$from_directory =~ s/<moto>/$moto2/g;
							#	$to_directory1 =~ s/<moto>/$moto2/g;
							#	$to_directory2 =~ s/<moto>/$moto2/g;
							#	my $to_directory_all = "$to_directory1$to_directory2";

								# �f�B���N�g���쐬
							#	Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/");
							#	Mebius::Mkdir(undef,$to_directory1);
								#Mebius::Mkdir(undef,$to_directory_all);

								# �f�B���N�g������ύX
							#	if(rename($from_directory,$to_directory_all)){
							#		$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory_all);
							#	}

								# �f�B���N�g������"���A"
								#if(rename($to_directory_all,$from_directory)){
								#	$line .= qq(\n<br$main::xclose>rename $to_directory_all -&gt; $from_directory);
								#}

								#rename($to_directory_all,$from_directory);

								# �f�B���N�g�����ċA�I�ɃR�s�[
								#if($from_directory && $to_directory){
								#	&File::Copy::Recursive::rcopy($from_directory, $to_directory_all);
								#	$line .= qq(\n<br$main::xclose>copy $from_directory -&gt; $to_directory);
								#}

						#}
				}

	}

print qq(Content-type:text/html\n\n$line);exit;

}



1;
