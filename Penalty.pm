
use strict;
use Mebius::PenaltyUTF8;
use Mebius::Export;
package Mebius;


#-----------------------------------------------------------
# �y�i���e�B�t�@�C��������
#-----------------------------------------------------------
sub penalty_file{

# �錾�P
my($basic_init) = Mebius::basic_init();
my($type,$file,$newsubject,$newcomment,$newurl,$new_penalty_count,$newpenalty_reason) = @_;
my(undef,$select_file_direct) = @_ if($type =~ /Select-file-direct/);
my(undef,undef,$nowaccess_type) = @_ if($type =~ /Axscheck/);
my(undef,undef,%renew) = @_ if($type =~ /Renew-hash|Use-renew-hash/);
my(%penalty);	# ( A )
(undef,undef,undef,%penalty) = @_ if($type =~ /Relay-hash/); # ( B )
my($file2,$filehandle1,$logfile,$encfile,@renew_line);
my($denymin,$directory,@top_line,$i,%flag);
my($share_directory) = Mebius::share_directory_path();
my($init_directory) = Mebius::BaseInitDirectory();

# �y�i���e�B�̍ō��b�� ( ���ݓ�T�� )
my $max_long_penalty_second = 2*7*24*60*60;

# �ő�L�^�s��
my $max_line = 25;

	if($type =~ /UTF8/){
		shift_jis($newpenalty_reason);
	}

	# �y�i���e�B�������
	if(!$new_penalty_count){ $new_penalty_count = 1; }

	# �t�@�C����`���Ȃ��ꍇ�A�����I�ɑ��
	if($type =~ /Select-auto-file/ && $type !~ /(Account|Cnumber|Host|Isp|Agent|Addr|Second-domain)/){
		#my($my_account) = Mebius::my_account();
		#my($get_host) = Mebius::GetHostWithFile();
		#my($access) = Mebius::my_access();
			if($main::kaccess_one){
				$file = $main::agent;
				$type .= qq( Agent);
			}
			elsif($main::myaccount{'file'}){
				$file = $main::myaccount{'file'};
				$type .= qq( Account);
			}
			elsif($main::cnumber){
				$file = $main::cnumber;
				$type .= qq( Cnumber);
			}
			elsif($main::host){
				$file = $main::host;
				$type .= qq( Host);
			}
	}

	# ���^�[��
	if($file eq ""){ return(%penalty); }

# ��{�t�@�C������`
($encfile) = Mebius::Encode("",$file);

	# ���n�b�V���������[����ꍇ�A����̂��̈ȊO�͂��ׂč폜
	if($type =~ /Relay-hash/){
			foreach(keys %penalty){
				if($_ !~ /^(Block|Penalty|Hash)->/){ $penalty{$_} = undef; }
			}
	}

	# ���t�@�C����`
	# �A�J�E���g
	if($type =~ /Account/){
		$penalty{'file_type'} = "Account";
		$directory = "${share_directory}_ip/_data_account/";
		$logfile = "${directory}$encfile.cgi";
	}
	# �N�b�L�[
	elsif($type =~ /Cnumber/){
		$penalty{'file_type'} = "Cnumber";
		$directory = "${share_directory}_ip/_data_number/";
		$logfile = "${directory}$encfile.cgi";
	}
	# IP�A�h���X
	elsif($type =~ /Addr/){
		$penalty{'file_type'} = "Addr";
		$directory = "${share_directory}_ip/_data_addr/";
		$logfile = "${directory}$encfile.cgi";
	}
	# �z�X�g��
	elsif($type =~ /Host/){

		# �g�уz�X�g�̏ꍇ�̓��^�[��
		my($host_type) = Mebius::HostType({ Host => $file });
			if($host_type->{'type'} eq "Mobile"){ return(%penalty); }

		$penalty{'file_type'} = "Host";
		$directory = "${share_directory}_ip/_data_host/";
		$logfile = "${directory}$encfile.cgi";
	}
	# ISP
	elsif($type =~ /Isp/){
		$penalty{'file_type'} = "Isp";
		$directory = "${share_directory}_ip/_data_isp/";
		$logfile = "${directory}$encfile.cgi";
	}
	# ���x���Q�h���C��
	elsif($type =~ /Second-domain/){
		$penalty{'file_type'} = "Second-domain";
		$directory = "${share_directory}_ip/_data_second_domain/";
		$logfile = "${directory}$encfile.cgi";
	}
	# ���[�U�[�G�[�W�F���g / �̎��ʔԍ�
	elsif($type =~ /Agent/){

		# �g�шȊO�̃��[�U�[�G�[�W�F���g�̏ꍇ�̓��^�[��
		my($real_device) = Mebius::device({ UserAgent => $file });
			if($real_device->{'mobile_uid'}){
				$penalty{'file_type'} = "Kaccess_one";
				$directory = "${share_directory}_ip/_data_kaccess_one/";
				($encfile) = Mebius::Encode("","$real_device->{'mobile_uid'}_$real_device->{'mobile_id'}");
				$logfile = "${directory}$encfile.cgi";
			}
			elsif($real_device->{'mobile_id'}){
				$penalty{'file_type'} = "Kaccess";
				$directory = "${share_directory}_ip/_data_agent/";
				($encfile) = Mebius::Encode("",$file);
				$logfile = "${directory}$encfile.cgi";
			}
			else{ return(%penalty); }
	}

	# �t�@�C���𒼐ڎw�肷��ꍇ
	elsif($type =~ /Select-file-direct/){
		$logfile = $select_file_direct;
	}

	# �^�C�v��`���Ȃ��ꍇ
	else{ return(%penalty); }

# �t�@�C���J��
open($filehandle1,"<",$logfile) || ($penalty{'file_nothing_flag'} = 1);

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($filehandle1,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$filehandle1>);
chomp(my $top2 = <$filehandle1>);
chomp(my $top3 = <$filehandle1>);
chomp(my $top4 = <$filehandle1>);
chomp(my $top5 = <$filehandle1>);
chomp(my $top6 = <$filehandle1>);
chomp(my $top7 = <$filehandle1>);
chomp(my $top8 = <$filehandle1>);
chomp(my $top9 = <$filehandle1>);
chomp(my $top10 = <$filehandle1>);

($penalty{'count'},$penalty{'allcount'},$penalty{'lasttime'},$penalty{'penalty_time'},$penalty{'deleted_subject'},undef,$penalty{'deleted_url'},undef,$penalty{'deleted_comment'},undef,undef,undef,undef,$penalty{'deleted_reason'}) = split(/<>/,$top1);
($penalty{'block'},$penalty{'block_time'},$penalty{'block_reason'},$penalty{'block_decide_man'},$penalty{'block_decide_time'},$penalty{'block_count'},$penalty{'block_bbs'}) = split(/<>/,$top2);
($penalty{'allow_host'},$penalty{'from_other_site_time'},$penalty{'from_other_site_url'}) = split(/<>/,$top3);
($penalty{'concept'}) = split(/<>/,$top4);
($penalty{'exclusion_block'}) = split(/<>/,$top5);
my @user_agent_match_for_block = split(/<>/,$top6); # ��O������ -1 �ɂ́h���Ȃ��h�ł��� ( �S�Ă���l�̏ꍇ���z��������܂�Ă��܂��Ajoin�����܂��쓮���Ȃ� )
$penalty{'user_agent_match_for_block'} = \@user_agent_match_for_block;
($penalty{'block_report_time'},$penalty{'must_compare_xip_flag'}) = split(/<>/,$top7);

	# �t�@�C����W�J
	while(<$filehandle1>){

		# ���E���h�J�E���^
		$i++;

		# �s�𕪉�
		chomp;
		my($key2,$handle2,$url2,$comment2,$subject2,$deleted_time2) = split(/<>/,$_);

			# �C���f�b�N�X���擾
			if($type =~ /Get-deleted-index/){

					if($i >= 2){
						$penalty{'index_line'} .= qq(<hr$main::xclose>);
					}
					my($date_deleted) = Mebius::get_date($deleted_time2);
					my($how_before_deleted) = shift_jis(Mebius::second_to_howlong({ ColorView => 1 , GetLevel => "top" , HowBefore => 1 } , time - $deleted_time2));

				$penalty{'index_line'} .= qq(<div class="deleted_history"><a href="$url2">$url2</a> ( $subject2 )�@ �폜���� : $how_before_deleted �@ ( $date_deleted->{'date'} ) <br$main::xclose> <br$main::xclose> $comment2 </div>);
			}

			# �X�V�s��ǉ�
			if($type =~ /Renew|Check-penalty/){

					# �ő�s���ɒB�����ꍇ
					if($i > $max_line){ last; }

				# �X�V�s��ǉ�
				push(@renew_line,"$key2<>$handle2<>$url2<>$comment2<>$subject2<>$deleted_time2<>\n");
			}
	}

close($filehandle1);

# ��񕪉� ( ���e�����f�[�^�𕪉� )
#($penalty{'block_reason'},$penalty{'block_time'},$penalty{'block_decide_man'}) = split(/>/,$penalty{'blockdata'});

	# ���n�b�V������
	# �t�@�C����
	$penalty{'logfile'} = $logfile;

	# ���Ԃ��u���b�N���̏ꍇ
	if($penalty{'block'} && ($penalty{'block_time'} >= time || !$penalty{'block_time'})){ $penalty{'block_time_flag'} = 1; }
	# �y�i���e�B���̏ꍇ
	if($penalty{'penalty_time'} > time){ $penalty{'penalty_flag'} = 1; }
	# �y�i���e�B�͂��Ă��Ȃ����A�Ǘ��ҍ폜��m�点��ꍇ
	if($penalty{'lasttime'} && time < $penalty{'lasttime'} + 24*60*60){ $penalty{'tell_flag'} = 1; }
	# �z�X�g���̋���
	if($penalty{'allow_host'} eq "Allow"){ $penalty{'allow_host_flag'} = 1; }
	# �O���o�R��Ԃ̎��Ԕ���
	if(time < $penalty{'from_other_site_time'} + (3*24*60*60)){
		$penalty{'from_other_site_flag'} = 1;
	}

	# �폜�ꏊ�����N
	$penalty{'deleted_link'} = qq(<a href="$penalty{'deleted_url'}">$penalty{'deleted_subject'}</a>);
	# �ΏۂƂȂ����ԍ����Ȃ�
	$penalty{'file'} = $file;


	# �����ʃn�b�V���̑���A��`
	if($type =~ /Relay-hash/){
			if($penalty{'from_other_site_time'} > $penalty{'Hash->from_other_site_time'}){
				$penalty{'Hash->from_other_site_time'} = $penalty{'from_other_site_time'};
				$penalty{'Hash->from_other_site_url'} = $penalty{'from_other_site_url'};
				$penalty{'Hash->from_other_site_file_type'} = $penalty{'file_type'};
				$penalty{'Hash->from_other_site_flag'} = $penalty{'from_other_site_flag'};
			}
	}

	# �����[�U�[���e���A�N�Z�X�����̔���
	if($type =~ /Axscheck/){

			# �e��f�[�^���擾
			my($access) = Mebius::my_access();

			# �����e�����̔���

			# �����̉��
			if($penalty{'exclusion_block'} && $type !~ /(Isp)/){
				$penalty{'Block->exclusion_block_flag'} = 1;
			}

			# �ʐ����𔻒�
			if($penalty{'block_bbs'} && $main::moto){
					foreach(split(/ /,$penalty{'block_bbs'})){
							if($_ eq $main::moto){
									$penalty{'block_bbs_flag'} = 1;
									$penalty{'block_flag'} = 1;
									$penalty{'block_type_text'} = qq(�ꕔ�̃R���e���c);
								}
					}
			}

			# ���͂ȓ��e����
			if($penalty{'block'} eq "2"){
				$penalty{'block_flag'} = 1;
				$penalty{'block_type_text'} = qq(���ׂĂ̏ꏊ);
			}
			# ���ʂ̓��e����
			elsif($penalty{'block'} eq "1" && $nowaccess_type !~ /User-report-send/){
				$penalty{'block_flag'} = 1;
				$penalty{'block_type_text'} = qq(���ׂĂ̏ꏊ ( �����/�폜�˗����̂��� ));
			}
			# �A�J�E���g�݂̂̐���
			elsif($penalty{'block'} eq "3" && $nowaccess_type =~ /ACCOUNT/){
				$penalty{'block_flag'} = 1;
				$penalty{'block_type_text'} = qq(�A�J�E���g�֘A);
			}

			# �A�J�E���g�쐬�̐���
			elsif($penalty{'concept'} =~ /Block-make-account/ && $nowaccess_type =~ /Make-account/){
				$penalty{"Block->block_make_account_flag"} = 1;
			}

			# �����������߂��Ă���ꍇ
			if($penalty{'block_time'} && time >= $penalty{'block_time'}){
				$penalty{'block_flag'} = 0;
			}

			# UA�������ݒ肳��Ă���A�}�b�`���Ȃ��ꍇ�͓��e���������
			if(@user_agent_match_for_block >= 1){
				my($match_flag);
					foreach (@user_agent_match_for_block){
						my($select_user_agent_decoded) =  Mebius::Decode(undef,$_);
							if($access->{'multi_user_agent'} =~ /\Q$select_user_agent_decoded\E/){ $match_flag = 1 ; }
					}
					if(!$match_flag){ $penalty{'block_flag'} = 0; }
			}

			# ���ᔽ�񍐂̑��M����
			if($penalty{'block_report_time'} && time < $penalty{'block_report_time'} && $nowaccess_type =~ /User-report-send/){
				my($howlong) = shift_jis(Mebius::second_to_howlong({ TopUnit => 1 } , $penalty{'block_report_time'} - time));
				$penalty{'block_flag'} = 1;
				$penalty{'block_type_text'} = qq(�ᔽ�񍐂̑��M);
				$penalty{'block_message'} = qq(�s�K�؂ȕ񍐂��������߁A���΂炭���M�ł��܂���B[ ����).e($howlong).qq( ] );
			}

			# �����e�������̏ꍇ�A�G���[���b�Z�[�W���`
			elsif($penalty{'block_flag'}){

				# �Ǐ���
				my($block_message);

				# �������̕\��
				my($left_date) = Mebius::SplitTime("Get-till-day",$penalty{'block_time'} - time + (24*60*60));

				# �����^�C�v
				$penalty{'block_file_type'} = $penalty{'file_type'};

				# �ŏ��̕���
				$block_message .= qq(��<a href="${main::guide_url}%C5%EA%B9%C6%C0%A9%B8%C2">�\\���󂠂�܂��񂪁A���e�������̂��ߑ��M�ł��܂���B</a><br>);
				$block_message .= qq(�@�ΏہF [ $penalty{'block_type_text'} ]<br>);
					if($main::myadmin_flag >= 5){ $block_message .= qq(�@�����^�C�v�F [ $penalty{'file_type'} ] ( �Ǘ��җp�̕\\�� )<br$main::xclose>); }

					# ���e�����̗��R������ꍇ
					if($penalty{'block_reason'}){
						require "${init_directory}part_delreason.pl";
						my($block_reason_text) = main::delreason($penalty{'block_reason'},"SUBJECT");
						$block_message .= qq(�@�������R�F [ $block_reason_text ]<br>);
					}

					# ��������������ꍇ
					if($penalty{'block_time'}){
						$block_message .= qq(�@�������F [ $left_date�� ]<br>);
						$block_message .= qq(�@�@�������ȉ������܂ł́A�����Ȃ���@�ł� [ $penalty{'block_type_text'} ] �ւ̏������݂͂��������������B<br>);
					}
					# �����������Ȃ��ꍇ
					else{
						$block_message .= qq(�@�������F [ ������ ] <br>);
						$block_message .= qq(�@�@�������Ȃ���@�ł� [ $penalty{'block_type_text'} ] �ւ̏������݂͂��������������B<br>);
					}

					# �L�搧���̏ꍇ�̃��b�Z�[�W
					if($type =~ /Isp/){
							$block_message .= qq(�@�L�搧�� �c �{�T�C�g�ł͍r�炵�A���f�s�זh�~�̂��߁A�L���͈͂ł̐����������Ȃ킹�Ă��������ꍇ������܂��B);
							$block_message .= qq(�@���̏ꍇ�A���p���ɂ���ẮA���̃��[�U�[�l�ƈꏏ�ɐ������������Ă��܂����ꍇ������܂��B);
							$block_message .= qq(�@���������Y���Ő������������Ă���Ǝv����ꍇ�́A���萔�ł��� $basic_init->{'mailform_link'} ��育�A���������B<br>);
					}

				# �x������
				$block_message .= qq(�@�@<strong style="color:#f00;">���ᔽ�s�ׂ������ꍇ��d��ȏꍇ�́A���Ȃ���<a href="${main::guide_url}%A5%D7%A5%ED%A5%D0%A5%A4%A5%C0%CF%A2%CD%ED">�v���o�C�_</a> $main::host ��ʂ��Ă�������ЁA�w�Z�ȂǂɘA�������Ă��������ꍇ������܂��B</strong><br>);

					# ���O����̃A�N�Z�X�̏ꍇ
					unless($main::host =~ /\.jp$/ || $main::host =~ /\.bbtec\.net$/){
						$block_message .= qq(�@���O����̃A�N�Z�X�ł��A�����ł��B<br>);
					}

					# Google���o�C������ && �������̏ꍇ�A�G�X�P�[�v�y�[�W��\��
					if($main::k_access eq "MOBILE"){
						$block_message .= qq(��[ �ꗥ���� ] Google����/Yahoo������ʂ��ăA�N�Z�X���Ă��邽�߁A���M�ł��܂���B http://$main::server_domain/ �̂t�q�k���g�тŒ��ړ��͂��邩�A<a href="mailto:?subject=MEBI-URL&body=http://$main::server_domain/">�������Ƀ��[�����M</a>���ă��[����ʂ���A�N�Z�X���Ȃ����Ă��������B<br>);
					}


				$penalty{'block_message'} = $block_message;

			}


			# ���S�Ă̎�ނ̃t�@�C���̒��ŁA�ő吧�����ԂȂǂ��o���Ă���
			if($type =~ /Relay-hash/ && $penalty{'block_flag'} && ($penalty{'block_time'} > $penalty{'Block->block_time'} || !$penalty{'block_time'} || $penalty{'block_bbs_flag'})){
					foreach(keys %penalty){
							if($_ !~ /^(Block|Penalty)->/){ $penalty{"Block->$_"} = $penalty{$_}; }
					}
			}
	}

	# ���y�i���e�B�[����
	if($type =~ /Check-penalty/){

			# ���S�^�C�v�̃y�i���e�B���`�F�b�N����ꍇ
			if($main::bbs{'concept'} =~ /Strong-penalty/){
				$penalty{'strong_check_flag'} .= qq( �f���̋��������[�h);
			}
			if($penalty{'pure_cookie_penalty_flag'}){
				$penalty{'strong_check_flag'} .= qq( PureCookie�̒l);
			}
			elsif($penalty{'Penalty->penalty_flag'}){
				$penalty{'strong_check_flag'} .= qq( ���̃t�@�C�� ( $penalty{'Penalty->penalty_file_type'} ) �Ńy�i���e�B��);
			}
			if($penalty{'block_flag'} || $penalty{'Penalty->block_flag'}){
				$penalty{'strong_check_flag'} .= qq( ���e���� ( $penalty{'Penalty->block_file_type'} ) �ƈꏏ��);
			}

			# ��Cnumber�̓��e�����t�@�C�������݂��邩�ǂ����𒲂ׂ�
			if($type =~ /Cnumber/){
				require "${main::int_dir}part_history.pl";
				my(%history_cnumber) = main::get_reshistory("Get-hash CNUMBER",$file);
					if($history_cnumber{'f'}){ $penalty{'Penalty->cnumber_f_flag'} = 1; }
			}

			# ���z�X�g����̃y�i���e�B�\�����������ꍇ �i �y�i���e�B�t�^���̂́A��ɂ����Ȃ� �j 
			if($type =~ /Host/){
					# �N�b�L�[�Ǘ��ԍ��ł̓��e�����t�@�C�������݂��Ȃ��ꍇ�́A�z�X�g�����`�F�b�N����
					if(!$penalty{'Penalty->cnumber_f_flag'}){
						$penalty{'strong_check_flag'} .= qq( Cnumber���e�����t�@�C�������݂��Ȃ�);
					}
					# �N�b�L�[�Ǘ��ԍ��ł̓��e�����t�@�C�������݂���ꍇ�́A�z�X�g���Ń`�F�b�N���Ȃ�
					if(!$penalty{'strong_check_flag'}){
						$penalty{'escape_flag'} = 1;
					}
			}

#if($type =~ /Account/){ main::error("$top");
# }

			# ���ŋ߂̍폜�񐔂�����ꍇ�A�y�i���e�B��ǉ�
			if($penalty{'count'} >= 1){

				# �t�@�C���X�V�t���O�𗧂Ă�
				$type .= qq( Renew);

				# �V�����X�V���L������
				$penalty{'Penalty->new_penalty_flag'} = 1;

					# �P�폜������A�t�^����y�i���e�B���Ԃ��v�Z
					if($penalty{'allcount'} >= 20){ $denymin = 3*24*60; }
					elsif($penalty{'allcount'} >= 10){ $denymin = 2*24*60; }
					elsif($penalty{'allcount'} >= 5){ $denymin = 1*24*60; }
					else{ $denymin = 12*60; }

					# ���Ƀy�i���e�B���̏ꍇ�A�y�i���e�B���Ԃ����Z����
					if($penalty{'penalty_flag'}){
						$penalty{'penalty_time'} += $denymin*60 * $penalty{'count'};
					}
					# �y�i���e�B���łȂ��ꍇ�A�V�����y�i���e�B���Ԃ�ݒ肷��
					else{
						$penalty{'penalty_time'} = time + ($denymin*60 * $penalty{'count'});
					}

					# �P�񂠂���̃y�i���e�B���Ԃ̏�����`
					if($penalty{'penalty_time'} > time + $max_long_penalty_second){
						$penalty{'penalty_time'} = time + $max_long_penalty_second;
					}

					# �ŋ߂̍폜�񐔂��[���ɂ���
					$penalty{'count'} = 0;

			}

			# ��Cookie�݂̂Ő�������ꍇ
			if($type =~ /Cnumber/ && $main::cdelres > $penalty{'penalty_time'} && !Mebius::alocal_judge() && !$main::myadmin_flag && time >= 1367038772 + 2*7*24*60*60){
				$penalty{'penalty_time'} = $main::cdelres - 1;
				$penalty{'file_type'} = "Cookie-pure";
			}

			# ���t�@�C���̃y�i���e�B���Ԃōő�̂��̂��A�N�b�L�[�Z�b�g�̒l�Ƃ��Ē�`
			elsif($penalty{'penalty_time'} >= $penalty{'Penalty->set_cdelres_time'}){
				$penalty{'Penalty->set_cdelres_time'} = $penalty{'penalty_time'};
			}

			# �����ʓI�ɁA�y�i���e�B���̏ꍇ
			if($penalty{'penalty_time'} > time && !$penalty{'escape_flag'}){

				# �y�i���e�B���t���O���Ē�`
				$penalty{'penalty_flag'} = 1;
				$penalty{'penalty_file_type'} = $penalty{'file_type'};

				# �Ǘ��җp�̃��b�Z�[�W���`
				$penalty{'check_message'} .= qq( - $penalty{'penalty_file_type'} ( $file ));
				$penalty{'check_message'} .= qq( $penalty{'strong_check_flag'} );

					# ���S�Ă̎�ނ̃t�@�C���̒��ŁA�ő�y�i���e�B���Ԃ��o���Ă���
					if($type =~ /Relay-hash/ && $penalty{'penalty_time'} > $penalty{'Penalty->penalty_time'}){
							foreach(keys %penalty){
									if($_ !~ /^(Block|Penalty)->/){ $penalty{"Penalty->$_"} = $penalty{$_}; }
							}
					}

			}


	}

	# ���Ǘ��ҍ폜���y�i���e�B�ǉ��p
	if($type =~ /(Penalty|Repair|New-delete)/ && $type =~ /Renew/){

			# �����e�����Ńy�i���e�B�����炷
			if($type =~ /Repair/){
				$penalty{'count'} -= $new_penalty_count;
				$penalty{'allcount'} -= $new_penalty_count;
			}

			# �����e�폜�Ńy�i���e�B�𑝂₷
			elsif($type =~ /Penalty/){
				$penalty{'count'} += $new_penalty_count;
				$penalty{'allcount'} += $new_penalty_count;
			}

			# ���y�i���e�B�Ȃ��A���ʂ̍폜�̏ꍇ
			else{
					# �ŋ߂̍폜�񐔂���������A���Ƀy�i���e�B���́A�폜�������ւ��Ȃ� ( ���̂܂܃��^�[�� )
					if($penalty{'count'} >= 1){ $type =~ s/(\s)?Renew//g; }
					if($penalty{'penalty_time'} && time < $penalty{'penalty_time'}){ $type =~ s/(\s)?Renew//g; }
			}

			# �폜�J�E���g�𒲐� ( �}�C�i�X�l�ɂȂ�Ȃ��悤�� )
			if($penalty{'allcount'} < 0){ $penalty{'allcount'} = 0; }

			# ���p���l���Ȃ��ꍇ�́A�L�����Ȃǂ�ύX���Ȃ�
			if($newsubject eq ""){ $newsubject = $penalty{'deleted_subject'}; }
			if($newurl eq ""){ $newurl = $penalty{'deleted_url'}; }

		# �X�V����l
		$penalty{'lasttime'} = time;
		$penalty{'deleted_subject'} = $newsubject;
		$penalty{'deleted_url'} = $newurl;
		$penalty{'deleted_comment'} = $newcomment;
		$penalty{'deleted_reason'} = $newpenalty_reason;

	}

	# �폜������ǉ�
	if($type =~ /Penalty/){

		# �X�V�s��ǉ�
		unshift(@renew_line,"<><>$newurl<>$newcomment<>$newsubject<>$main::time<>\n");

	}

	# ���t�@�C�����X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,${directory});

			# �n�b�V������čX�V
		my($renew) = Mebius::Hash::control(\%penalty,\%renew);

		# �s���ȕ������폜
		($renew) = Mebius::format_data_for_file($renew);

		# �X�V����s
		push(@top_line,"$renew->{'count'}<>$renew->{'allcount'}<>$renew->{'lasttime'}<>$renew->{'penalty_time'}<>$renew->{'deleted_subject'}<><>$renew->{'deleted_url'}<><>$renew->{'deleted_comment'}<><><><><>$renew->{'deleted_reason'}<>\n");
		push(@top_line,"$renew->{'block'}<>$renew->{'block_time'}<>$renew->{'block_reason'}<>$renew->{'block_decide_man'}<>$renew->{'block_decide_time'}<>$renew->{'block_count'}<>$renew->{'block_bbs'}<>\n");
		push(@top_line,"$renew->{'allow_host'}<>$renew->{'from_other_site_time'}<>$renew->{'from_other_site_url'}<>\n");
		push(@top_line,"$renew->{'concept'}<>\n");
		push(@top_line,"$renew->{'exclusion_block'}<>\n");

			{
				my $push = join "<>" , @{$renew->{'user_agent_match_for_block'}};
				push(@top_line,"$push<>\n");
			}

		# �ȉ��̍s���������ׂāA�폜�֎~
		push(@top_line,"$renew->{'block_report_time'}<>$renew->{'must_compare_xip_flag'}<>\n");
		push(@top_line,"<>\n");
		push(@top_line,"<>\n");
		push(@top_line,"<>\n");

		# �g�b�v�f�[�^��{�f�[�^�Ɍ���
		unshift(@renew_line,@top_line);

		# �t�@�C���X�V
		Mebius::Fileout("",$logfile,@renew_line);
	}

	# �t���O�𗧂Ă�
	if($type =~ /Get-flag/){

			if($penalty{'block'} || $penalty{'block_bbs'} =~ /\w/){
						# ���炩�̌`�Ŗ������̓��e�������̏ꍇ
						if($penalty{'block_time'} eq ""){
								$flag{'some_block'} = 1;
							$flag{'some_indefinite_block'} = 1;
						}
						# ���炩�̌`�œ��e�������̏ꍇ
						if($penalty{'block_time'} && $penalty{'block_time'} && time < $penalty{'block_time'}){
							$flag{'some_block'} = 1;
						}
					
			}

			$penalty{'Flag'} = \%flag;
	}

# ���^�[��
return(%penalty); 

}

#-----------------------------------------------------------
# �t�`���画�� ( ���݂͖����p? )
#-----------------------------------------------------------
sub Checkdevice_fromagent{

# �Ǐ���
my($type,$file) = @_;
my($adevice_type,$select_dir,$k_access,$kaccess_one);

# �t�`���� $k_access �𔻒�
if($file =~ /(^DoCoMo)/){ $k_access = "DOCOMO"; }
if($file =~ /(^KDDI|^UP\.Browser)/){ $k_access = "AU"; }
if($file =~ /(^SoftBank|^Vodafone|^J-PHONE)/){ $k_access = "SOFTBANK"; }

# KACCESS_ONE
if($file =~ /^DoCoMo([a-zA-Z0-9 ;\(\/\.]+?);ser([0-9a-z]{15});/){
$k_access = "DOCOMO";
$kaccess_one = $2;
}

if($file =~ /^([0-9]+)_([a-z]+)\.ezweb\.ne\.jp$/){
$kaccess_one = "${1}_${2}";
$k_access="AU";
}

if($file =~ /\/SN([0-9]+)/){
$kaccess_one = $1;
$k_access="SOFTBANK";
}

if($type =~ /Account/){ $adevice_type = "account"; $select_dir = "_data_account/"; }
elsif($type =~ /Isp/){ $adevice_type = "isp"; $select_dir = "_data_isp/"; }
elsif($kaccess_one){ $adevice_type = "kaccess_one"; $select_dir = "_data_kaccess_one/"; }
elsif($file =~ /^([a-zA-Z0-9\.\-]+)\.([a-z]{2,3})$/ || $file eq "localhost"){ $adevice_type = "host"; $select_dir = "_data_host/"; }
elsif($file =~ /^([a-zA-Z0-9]+)$/){ $adevice_type = "number"; $select_dir = "_data_number/"; }
else{ $adevice_type = "agent"; $select_dir = "_data_agent/"; }

return($adevice_type,$select_dir,$k_access,$kaccess_one);

}


#-----------------------------------------------------------
# SNS�̃y�i���e�B�쐬
#-----------------------------------------------------------
sub Authpenalty{

# �錾
my($type,$account,$comment,$subject,$url) = @_;
my(%onedata,$plustype_penalty);
my($init_directory) = Mebius::BaseInitDirectory();

# �����`�F�b�N
$account =~ s/[^0-9a-z]//g;
if($account eq ""){ return(); }

	# �^�C�v��`
	if($type =~ /Penalty/){
		$plustype_penalty .= qq( Penalty);
	}
	elsif($type =~ /Repair/){
		$plustype_penalty .= qq( Repair);
	}
	else{
		return();
	}

# ��荞�ݏ���
require "${init_directory}part_idcheck.pl";

	# �A�J�E���g�̃A�N�Z�X�������擾
	(%onedata) = Mebius::Login->login_history("Onedata",$account);

	# �y�i���e�B�쐬
	if($account){
		Mebius::penalty_file("Account Renew $plustype_penalty",$account,$subject,$comment,$url);
	}

	# �y�i���e�B�쐬
	if($onedata{'host'}){
		Mebius::penalty_file("Host Renew $plustype_penalty",$onedata{'host'},$subject,$comment,$url);
	}

	# �y�i���e�B�쐬
	if($onedata{'agent'}){
		Mebius::penalty_file("Agent Renew $plustype_penalty",$onedata{'agent'},$subject,$comment,$url);
	}

	# �y�i���e�B�쐬
	if($onedata{'cnumber'}){
		Mebius::penalty_file("Cnumber Renew $plustype_penalty",$onedata{'cnumber'},$subject,$comment,$url);
	}

}

#-----------------------------------------------------------
# �S�y�i���e�B
#-----------------------------------------------------------
sub PenaltyAll{

# �錾
my($type,$relay_type,$account,$host,$agent,$cnumber,%renew) = @_;

	# �t�@�C������
	if($account){
		Mebius::penalty_file("Account $relay_type",$account,%renew);
	}

	# �t�@�C������
	if($host){
		Mebius::penalty_file("Host Renew $relay_type",$host,%renew);
	}

	# �t�@�C������
	if($agent){
		Mebius::penalty_file("Agent Renew $relay_type",$agent,%renew);
	}

	# �t�@�C������
	if($cnumber){
		Mebius::penalty_file("Cnumber Renew $relay_type",$cnumber,%renew);
	}



}

#-----------------------------------------------------------
# �܂Ƃ߂ăy�i���e�B��^����
#-----------------------------------------------------------
sub add_penalty_all{

my $use = shift if(ref $_[0] eq "HASH");
my($relay_type,$host,$cookie_char,$user_agent,$account,@other) = @_;

	if($cookie_char){

		Mebius::penalty_file("Cnumber $relay_type",$cookie_char,@other);
	}
	if($host){
		Mebius::penalty_file("Host $relay_type",$host,@other);
	}
	if($user_agent){
		Mebius::penalty_file("Agent $relay_type",$user_agent,,@other);
	}
	if($account){
		Mebius::penalty_file("Account $relay_type",$account,@other);
	}

}



#-----------------------------------------------------------
# �A�J�E���g�{�̂Ƀy�i���e�B��^����
#-----------------------------------------------------------
sub AuthPenaltyOption{

my($type,$account,$penalty_plus_time) = @_;
my(%renew_account);

# �A�J�E���g�f�[�^���擾
my(%account) = Mebius::Auth::File("Get-hash Option",$account);

	# ���y�i���e�B��^����
	if($penalty_plus_time >= 1){

			# �܂��y�i���e�B���̏ꍇ�A���Ԃ����Z
			if($account{'penalty_time'} > time){
				$renew_account{'penalty_time'} = $account{'penalty_time'} + $penalty_plus_time;
			}
			# �y�i���e�B���Ȃ��ꍇ�A���ʂɎ��Ԃ����Z
			else{
				$renew_account{'penalty_time'} = time + $penalty_plus_time;
			}
	}

	# ���y�i���e�B�����炷�A��������
	elsif($penalty_plus_time <= -1){
			$renew_account{'penalty_time'} = $account{'penalty_time'} + $penalty_plus_time;
	}

	# �I�v�V�����t�@�C�����X�V
	#Mebius::Auth::Optionfile("Renew",$account{'file'},%renew_account);

	# �A�J�E���g���X�V
	Mebius::Auth::File("Renew Option",$account{'file'},\%renew_account);

}

#-----------------------------------------------------------
# �폜���m�点�y�[�W
#-----------------------------------------------------------
sub TellPenaltyView{

# �錾
my($type,$penalty) = @_;
my($top,$line,$denymin,$text,$text2,$deleted_text);
my($type,$host);
my($file,$file2,$file3,$select_dir,$pri_com);
my($count,$allcount,$btime,$oktime,$d_sub,$d_no,$d_res,$d_com,$textarea,$move);

# �^�C�g��
$main::sub_title = "�y�i���e�B�̂��m�点";
$main::head_link3 = " &gt; �y�i���e�B�̂��m�点";

# CSS��`
$main::css_text .= qq(
.deleted{padding:1em;border:1px solid #000;}
.comarea{width:95%;height:100px;}
.big{font-size:140%;}
h1{font-size:150%;color:#f00;}
li{line-height:1.4;}
div.about{line-height:1.4;}
ul.delguide{border:solid 1px #f00;padding:1em 2em;font-size:90%;color:#f00;margin: 1em 0em;}
);

# �g�єł̏ꍇ
if($main::in{'k'}){ main::kget_items(); }

	# �y�i���e�B�������ꍇ
	#if(!$penalty->{'max_penalty_flag'}){ main::error("���݁A�y�i���e�B�͂���܂���B"); }

	# �폜���R
	if($penalty->{'Penalty->penalty_reason'}){
		$deleted_text .= qq(<strong style="color:#f00;">�폜���R�F</strong><br$main::xclose><br$main::xclose>);
		$deleted_text .= qq(�@ $penalty->{'Penalty->penalty_reason'}<br$main::xclose><br$main::xclose>);
	}

	# �폜�y�[�W�̑薼�\�����`
	if($penalty->{'Penalty->deleted_link'}){
		$deleted_text .= qq(<strong style="color:#f00;">�폜�ꏊ�F</strong><br$main::xclose><br$main::xclose>);
		$deleted_text .= qq(�@ $penalty->{'Penalty->deleted_link'}<br$main::xclose><br$main::xclose>);
	}


	# �폜���ꂽ���͂��`
	if($penalty->{'Penalty->deleted_comment'}){
		$pri_com = $penalty->{'Penalty->deleted_comment'};
		$deleted_text .= qq(<strong style="color:#f00;">�폜���ꂽ���́F</strong>);
	}

	# �c�莞�Ԃ��`
	my($lefttime_split) = Mebius::SplitTime(undef,($penalty->{'Penalty->penalty_time'}-time));

	# ���O�����
	Mebius::AccessLog(undef,"Penalty","�c�莞�ԁF$lefttime_split / �^�C�v�F $penalty->{'Penalty->check_message'} ");

	# URL����
	if($penalty->{'url'} !~ /(^http|^\/)/){ $penalty->{'url'} = qq(/$penalty->{'url'}); }
	if($pri_com){ $deleted_text .= qq(<br$main::xclose><br$main::xclose>$pri_com); }

	# ���e���e������ꍇ
	if($main::in{'comment'} || $main::in{'prof'}){
		my $com = $main::in{'comment'};
			if($com eq ""){ $com = $main::in{'prof'}; }
		$com =~ s/<br>/\n/g;
		$textarea = qq(<h2>���M���e�i�������܂�Ă��܂���j</h2><textarea class="comarea" cols="25" rows="5">$com</textarea><br$main::xclose>);

	}

my $view_filetype = qq( $penalty->{'Penalty->check_message'} ) if($main::myadmin_flag || $main::alocal_mode);
my $h1 = qq(<h1$main::kstyle_h1>�G���[�F ���M�ł��܂���ł��� $view_filetype</h1>);

# �\�����镶�͂��`
$text .= qq(
$h1
<h2 id="TELL"$main::kstyle_h2>�y�i���e�B�ɂ���</h2>
<div class="about line-height">
�Ǘ��ҍ폜�i �܂��͊Ǘ��҂̐ݒ� �j�ɂ��A���΂炭���M�ł��܂���B$move<br$main::xclose>
�\\���󂠂�܂��񂪁A���܂� <strong class="red">$lefttime_split</strong> �قǂ��҂����������B

<div class="deleted margin">
$deleted_text
</div>

<ul class="delguide">
<li>�폜�񐔂������ƁA�y�i���e�B���d���Ȃ�����A���e�������������Ă��܂��ꍇ������܂��B</li>
<li>�ڂ�����<a href="${main::guide_url}%BA%EF%BD%FC%A5%DA%A5%CA%A5%EB%A5%C6%A5%A3%A3%D1%A1%F5%A3%C1">�폜�y�i���e�B�p���`</a>���������������B</li>
</ul>
</div>

$textarea
<br$main::xclose>
);


Mebius::Template::gzip_and_print_all({},$text);

exit;

}



1;

