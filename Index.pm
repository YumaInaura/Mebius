
use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# �C���f�b�N�X���X�V - strict
#-----------------------------------------------------------
sub index_file{

# �錾
my($type,$moto,$thread_number) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my(undef,undef,undef,$res_number,$new_handle,$new_bbs_title) = @_ if($type{'Regist-res'} || $type{'Regist-memo'});
my(undef,undef,undef,$new_key) = @_ if($type{'Thread-status-edit'});
my($hit_flag,$newline,@renew_line,@pin,$index_handler,$file_broken_flag,%self,$directory);
my $time = time;
	
	# �����`�F�b�N
	if($moto eq "" || $moto =~ /\W/){ return(); }
	if($thread_number =~ /\D/){ return(); }

# �t�@�C����`
my($bbs_path) = Mebius::BBS::path($moto);
	if($bbs_path->{'index_directory'}){ $directory = $bbs_path->{'index_directory'}; }
	else{ main::error("���j���[��ݒ�ł��܂���B"); }

	if($type =~ /Sub-index/){
			if($bbs_path->{'sub_index_file'}){ $self{'file'} = $bbs_path->{'sub_index_file'}; }
			else{ main::error("���j���[��ݒ�ł��܂���B"); }

	} else {
			if($bbs_path->{'index_file'}){ $self{'file'} = $bbs_path->{'index_file'}; }
			else{ main::error("���j���[��ݒ�ł��܂���B"); }
	}

# �t�@�C����ǂݍ���
my($index_handler,$read_write) = Mebius::File::read_write($type,$self{'file'},$directory,$bbs_path->{'index_directory'});
	if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }	

chomp(my $top = <$index_handler>);
my($no2,$last_res_time2,$time2,$last_resed_postnumber,$bbs_title) = split(/<>/,$top);

	# �V�K�쐬�����ꍇ
	if($read_write->{'file_touch_flag'}){
		$no2 = "0";
		$time2 = time;
	}

	# �t�@�C������
	if($no2 eq ""){ $file_broken_flag = 1; }

	# �G���[�΍�
	if($type{'Renew'} && ($no2 eq "" || $time2 eq "") && !$read_write->{'file_touch_flag'}) {
		$self{'file_broken_flag'} = 1;
		close($index_handler);
		main::error("�C���f�b�N�X�f�[�^���ǂݍ��߂Ȃ����߁A�������߂܂���B������x�����Ă��������B");
	}

	# �C���f�b�N�X��W�J
	while (<$index_handler>) {

		# �Ƃ𕪉�
		chomp;
		my($thread_number2,$thread_subject2,$res_number2,$post_handle2,$restime,$lasthandle,$key2) = split(/<>/);

		### �����p
		if($type =~ /Repair-sub-index/){
			my($sub_thread) = Mebius::BBS::thread({ ReturnRef => 1 },"sub$moto",$thread_number2);
			$self{'repair_line'} .= "$thread_number2<>$thread_subject2<>$sub_thread->{'res'}<><>$sub_thread->{'lastrestime'}<>$sub_thread->{'lasthandle'}<>1<>\n";
		}

			# �n�b�V�����`
			$self{'thread'}{$thread_number2}{'subject'} = $thread_subject2;
			$self{'thread'}{$thread_number2}{'res_number'} = $res_number2;
			$self{'thread'}{$thread_number2}{'last_regist_handle'} = $lasthandle;
			$self{'thread'}{$thread_number2}{'last_modified'} = $restime;

			# �X�V�����L��
			if($thread_number == $thread_number2) { 

				# �q�b�g�����ꍇ
				$hit_flag = 1;

					# �s���X�V����ꍇ
					if($type{'Regist-res'} && !$type{'Sub-thread'}){
						$res_number2 = $res_number;
						$restime = time;
						$lasthandle = $new_handle;
							# �������b�N�����ɔ�������
							if($key2 eq "0"){ $key2 = 1; }
					}

					# �����X�V��
					if($type{'Regist-memo'}){
						$lasthandle = $new_handle;
					}

					# �X�e�[�^�X�X�V
					if($type{'Thread-status-edit'}){
						$key2 = $new_key;
					}

				# �������ލs���`
				$newline = qq($thread_number<>$thread_subject2<>$res_number2<>$post_handle2<>$restime<>$lasthandle<>$key2<>\n);

					# �\�[�g���Ȃ��ꍇ�́A���̂܂܍s���X�V
					if(!$type{'Sort-on'}){ push(@renew_line,$newline); }

			}

			# �s���~�ߋL��
			elsif($key2 == 2) { push(@pin,"$_\n"); }

			# ���̑��̋L��
			else{ push(@renew_line,"$_\n"); }
	}

	# �L�������s���O�ɂȂ��ꍇ�A�C��
	if(!$hit_flag) {
			if(($type{'Regist-res'} && !$type{'Sub-thread'}) || $type{'Thread-status-edit'}){
				# ���L�����擾
				my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$moto,$thread_number);
				# �C������n���h���l�[��
				my $repair_handle = $new_handle;
					if($repair_handle eq ""){ $repair_handle = $thread->{'lasthandle'}; }
				# �C������L�[
				my $repair_key = $new_key;
					if($repair_key eq ""){ $repair_key = 1; }
				unshift(@renew_line,"$thread_number<>$thread->{'subject'}<>$thread->{'res'}<>$thread->{'posthandle'}<>$time<>$repair_handle<>1<>\n");
			}
		#&regist_error("�����̋L���͉ߋ����O�ɂ��邩�A�C���f�b�N�X�ɑ��݂��܂���B<br>");
	}

	# �V�����s��ǉ� ( �\�[�g����̏ꍇ )
	if($type{'Sort-on'}){ unshift(@renew_line,$newline); }

	# �s���~�ߋL����ǉ�
	if(@pin > 0){ unshift(@renew_line,@pin); }

	# �ŏI���X�̂������L���ԍ����X�V (�g�b�v�f�[�^��)
	if($type{'Regist-res'} && $type{'Sort-on'}){
		$last_resed_postnumber = $thread_number;
	}

	# �g�b�v�f�[�^���X�V
	if($type{'Regist-res'}){
		$last_res_time2 = time;
			if($new_bbs_title){ $bbs_title = $new_bbs_title; }
	}

# �g�b�v�f�[�^��ǉ�
unshift(@renew_line,"$no2<>$last_res_time2<>$time2<>$last_resed_postnumber<>$bbs_title<>\n");

	# �t�@�C���X�V
	if($type{'Renew'} && !$file_broken_flag){
		seek($index_handler,0,0);
		truncate($index_handler,tell($index_handler));
		print $index_handler @renew_line;
	}

# �t�@�C�������
close($index_handler);

	# �p�[�~�b�V�����ύX
	if($type{'Renew'}){ Mebius::Chmod(undef,$self{'file'}); }

	# ���m���Ńo�b�N�A�b�v (�V)
	if($type{'Renew'} && !$file_broken_flag && (rand(25) < 1 || Mebius::AlocalJudge())){
		Mebius::make_backup($self{'file'});
	}

\%self;

}

1;

