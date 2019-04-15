
use strict;
use Mebius::HTML;
use Time::HiRes;
package Mebius::Dos;

#-----------------------------------------------------------
# DOS�U�����L�^
#-----------------------------------------------------------
sub AccessFile{

# �錾
my($type,$addr) = @_;
my($REQUEST_URL) = Mebius::request_url();
my($now_date) = Mebius::now_date_multi();
my($dos_handler,%dos,%dos_flow,@renew_line,$multi_host,$allow_error_flag);
my($time) = time;

	# ���^�[��
	#if($addr eq "" || $addr =~ /[^0-9\.]/){ return(); }

# IP���擾
my $addr_encoded = Mebius::Encode(undef,$addr);

# ���b�ɉ���A�N�Z�X������΁ADOS�A�^�b�N�Ƃ��ċL�^���邩�H
my $dos_count_border = 20;	# �A�N�Z�X��
my $dos_second_border = 10;	# �b

# DOS�U���̐ݒ�
my $dos_alert_border = 3;
my $dos_htaccess_border = 10;
my $verify_max = 3;

# �P��������̍ő呍�A�N�Z�X���̐ݒ�
my $all_access_htaccess_border = 3*60*60;
my $all_access_alert_border = $all_access_htaccess_border * 0.90;

# �A�����N�G�X�g�̐ݒ�
my $redun_request_htaccess_border = 180;
my $redun_request_alert_border = $redun_request_htaccess_border * 0.90;

	# ���[�J���ݒ�
	if(Mebius::alocal_judge() && 1 == 0){
		$dos_count_border = 1;
		$dos_second_border = 1;
		$all_access_htaccess_border = 20;
		$all_access_alert_border = 10;
		$redun_request_htaccess_border = 6;
		$redun_request_alert_border = 3;
	}

	if(Mebius::alocal_judge() && 1 == 0){
		$all_access_alert_border = 3;
		$all_access_htaccess_border = 6;
	}

# �f�B���N�g����`
my($init_directory) = Mebius::BaseInitDirectory();
my $directory1 = "${init_directory}_dos/";
my $directory2 = "${directory1}_dos_buffer/";
my $file = "${directory2}${addr_encoded}_dos.log";

	# �f�B���N�g���쐬
	if($type =~ /Renew/ && (rand(500) <= 1 || Mebius::alocal_judge())){ Mebius::Mkdir(undef,$directory2); }

	# �t�@�C�����J��
	open($dos_handler,"+<$file") || ($dos{'file_nothing_flag'} = 1);

	# �t�@�C�����Ȃ��ꍇ�͐V�K�쐬
	if($type =~ /Renew/ && $dos{'file_nothing_flag'}){
		Mebius::Fileout("Allow-empty",$file);
		$dos{'file_touch_flag'} = 1;
		open($dos_handler,"+<",$file);
	}

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($dos_handler,2); }

	# �g�b�v�f�[�^�𕪉� (1)
	chomp(my $top1 = <$dos_handler>);
	chomp(my $top2 = <$dos_handler>);
	chomp(my $top3 = <$dos_handler>);
	chomp(my $top4 = <$dos_handler>);
	chomp(my $top5 = <$dos_handler>);
	chomp(my $top6 = <$dos_handler>);

	# �g�b�v�f�[�^�𕪉� (2)
	($dos{'key'},$dos{'last_access_time'}) = split(/<>/,$top1);
	($dos{'access_count'},$dos{'access_start_time'},$dos{'last_access_url'},$dos{'last_post_buf'}) = split(/<>/,$top2);
	($dos{'all_access_count'},$dos{'all_access_ymdf'}) = split(/<>/,$top3);
	($dos{'dos_count'},$dos{'last_dos_count_time'},$dos{'dos_all_count'}) = split(/<>/,$top4);
	($dos{'verify_count'},$dos{'verify_time'},$dos{'verify_char'}) = split(/<>/,$top5);
	($dos{'redun_request_count'},$dos{'all_redun_request_count'},$dos{'last_redun_time'}) = split(/<>/,$top6);

	# �ꎞ�Z�[�u�̂��߂̑��
	my(%dos_pure) = (%dos);

	# �t�@�C�������݂���ꍇ
	if(!$dos{'file_nothing_flag'}){ $dos{'f'} = 1; }

	# �O���DOS�J�E���g�����莞�Ԍo�߂��Ă���ꍇ�i�܂�A���΂炭�ߏ�ȃA�N�Z�X���Ȃ������ꍇ�j��DOS�J�E���^�����Z�b�g���� (A-1)
	if($time > $dos{'last_dos_count_time'} + 6*60*60){
		$dos{'dos_count'} = 0;
	}

	# �K��ɓ��ӂ����ꍇ (A-2)
	if($type =~ /New-access/ && $main::in{'dos_verify'} eq "verify" && $main::in{'verify_char'} eq $dos{'verify_char'} && $dos{'verify_char'}){
		$dos{'verify_count'}++;
		$dos{'verify_time'} = time;
		$dos{'verify_char'} = "";
		$dos{'access_start_time'} = time;
		$dos{'access_count'} = 1;
		$dos{'sendmail_flag'} = 1;
		$dos{'redun_request_count'} = 0;
		$dos{'deny_type'} = qq( �A�N�Z�X�U���̋K��ɓ��ӂ��܂���);
	}

	# ��DOS����A�x������ (A-3)
	if($dos{'dos_count'} >= $dos_alert_border && $dos{'last_dos_count_time'} >= $dos{'verify_time'}){
		$dos{'dos_alert_flag'} = 1;
	}

	# ��DOS����A.htaccess�ł̐������� (A-3)
	if($dos{'dos_count'} >= $dos_htaccess_border){
		$dos{'deny_htaccess_flag'} .= qq( Dos);
	}

	# ���A�����N�G�X�g����(�x��)
	if($dos{'redun_request_count'} >= $redun_request_alert_border && $dos{'last_redun_time'} >= $dos{'verify_time'}){
		$dos{'redun_request_alert_flag'} = 1;
	}

	# ���A�����N�G�X�g����(����)
	if($dos{'redun_request_count'} >= $redun_request_htaccess_border){
		$dos{'deny_htaccess_flag'} .= qq( Redun-request);
	}

	# ���S�A�N�Z�X�J�E���^�����Z�b�g����ꍇ (B-1)
	if($dos{'all_access_ymdf'} ne $now_date->{'ymdf'}){
		$dos{'all_access_count'} = 0;
		$dos{'all_access_ymdf'} = qq($now_date->{'ymdf'});
	}

	# ���S�A�N�Z�X�񐔁A�x������ (B-2)
	if($dos{'all_access_count'} >= $all_access_alert_border){
		$dos{'all_access_alert_flag'} = 1;
	}

	# ���S�A�N�Z�X�񐔁A.htaccess�ł̐������� (B-2)
	if($dos{'all_access_count'} >= $all_access_htaccess_border){
		$dos{'deny_htaccess_flag'} .= qq( All-access);
	}

	# ���J�E���g�����炷
	if($type =~ /Redirect-url/){
		$dos{'access_count'} -= 0.5;
		$dos{'all_access_count'} -= 0.5;
	}
	
	# ���V�����A�N�Z�X
	if($type =~ /New-access/){

			# �z�X�g�����擾���A�ڍׂȃA�N�Z�X�f�[�^���L�^����ꍇ
			#	�i ���炩���߃��O����邽�߂ɁA���ۂ̌x�����E��菭�Ȃ߂̒l��ݒ肷�� �j
			if($dos{'dos_all_count'} >= $dos_alert_border -1 || $dos{'all_access_count'} >= $all_access_alert_border * 0.8 || $dos{'all_redun_request_count'} >= $redun_request_alert_border * 0.8){

				# �z�X�g�����擾
				($multi_host) = Mebius::GetHostByFileMulti();
				my($access) = Mebius::my_access();

				# IP�A�h���X/�z�X�g���̐U�蕪��
				my $host_or_addr = $addr;
					if($multi_host->{'host'}){ $host_or_addr = $multi_host->{'host'}; }

					# ����ΏۊO�̊��̏ꍇ
					if($multi_host->{'host_type'} eq "Bot" || ($access->{'bot_flag'} && ($multi_host->{'host'} eq "" || $multi_host->{'addr_to_host_flag'})) || $multi_host->{'myserver_addr_flag'} || $main::k_access){

					}
					# ���ʂɏڍ׃f�[�^���L�^����ꍇ
					else{
						(%dos_flow) = Mebius::Dos::FlowFile("New-access Get-alert Renew",$host_or_addr,$multi_host->{'host'},$addr);
						$allow_error_flag = 1;
					}

			}

			# ���A�N�Z�X���Ԃ��L�^
			$dos{'last_access_time'} = Time::HiRes::time;

			# ���O��̊J�n���Ԃ����莞�Ԍo�߂��Ă���ꍇ�A�A�N�Z�X�J�E���^�����Z�b�gw
			if($time > $dos{'access_start_time'} + $dos_second_border){
				$dos{'access_count'} = 0;
				$dos{'access_start_time'} = $time;
			}

			# ���A�N�Z�X�J�E���^�𑝂₷

			if($REQUEST_URL eq $dos{'last_access_url'} && $main::postbuf eq $dos{'last_post_buf'}){
				$dos{'access_count'} += 2;
				$dos{'redun_request_count'} += 1;
				$dos{'all_redun_request_count'} += 1;
				$dos{'last_redun_time'} = time;

					# ���߂ĘA�����N�G�X�g����Ōx�����󂯂��ꍇ
					if($dos{'redun_request_count'} == $redun_request_alert_border && $allow_error_flag){
						# ���[���t���O�𗧂Ă�
						$dos{'sendmail_flag'} = 1;
						$dos{'deny_type'} = qq( �A�����N�G�X�g�̌x����\\�����܂���);
					}

			}
			else{
				$dos{'access_count'} += 1;
				$dos{'redun_request_count'} = 0;
			}

		# ���S�A�N�Z�X�J�E���g�𑝂₷
		$dos{'all_access_count'} += 1;

			# �����A�N�Z�X�񐔂��x���񐔂ɒB�����ꍇ
			if($dos{'all_access_count'} == $all_access_alert_border && $allow_error_flag){
				# ���[���t���O�𗧂Ă�
				$dos{'sendmail_flag'} = 1;
				$dos{'deny_type'} = qq( ���A�N�Z�X���̌x����\\�����܂���);
			}

			# �����A�N�Z�X�񐔂��L���ԂɒB�����ꍇ
			if($dos{'all_access_count'} >= 1000 && $dos{'all_access_count'} % 1000 == 0 && $allow_error_flag){
				# ���[���t���O�𗧂Ă�
				$dos{'sendmail_flag'} = 1;
				$dos{'deny_type'} = qq( ���A�N�Z�X���� $dos{'all_access_count'} �ɒB���܂���);
			}

			# �� �ꎞ�J�E���^����ꂽ�ꍇ�ADOS�J�E���^�𑝂₷
			if($dos{'access_count'} >= $dos_count_border){

				# DOS�J�E���^�𑝂₷
				$dos{'dos_count'} += 1;
				$dos{'dos_all_count'} += 1;

				# DOS�J�E���^�𑝂₵���ŏI�������L�^
				$dos{'last_dos_count_time'} = $time;

				# �ꎞ�A�N�Z�X�f�[�^�����Z�b�g
				$dos{'access_count'} = 0;
				$dos{'access_start_time'} = $time;

					# ���߂�DOS����Ōx�����ꂽ�ꍇ
					if($dos{'dos_count'} == $dos_alert_border && $allow_error_flag){
							# �L�[�ǉ�	
							if($dos{'key'} !~ /Alert-done/){ $dos{'key'} .= qq( Alert-done); }
						# ���[���t���O�𗧂Ă�
						$dos{'sendmail_flag'} = 1;
						$dos{'deny_type'} = qq( �A�N�Z�X�U���̌x����\\�����܂���);
					}


			}

			# ��DOS����񐔁A�������͑S�A�N�Z�X�񐔂����߂��Ă���ꍇ�A
			#	 .htaccess�t�@�C����ҏW���āA�����I�ɃA�N�Z�X�������ۂ� ( ���x���R )
			if($dos{'deny_htaccess_flag'} && $allow_error_flag){

					# �L�[�ǉ�
					if($dos{'key'} !~ /Htaccess-done/){ $dos{'key'} .= qq( Htaccess-done); }

				# .htacess ��ҏW
				Mebius::Dos::HtaccessFile("New-deny Renew",$addr,$multi_host->{'host'});

				$dos{'all_access_count'} = 0;
				$dos{'dos_count'} = 0;
				$dos{'redun_request_count'} = 0;
				$dos{'sendmail_flag'} = 1;
				$dos{'deny_type'} = qq( .htaccess �ŃA�N�Z�X�����������Ȃ��܂���);

			}

		# �ŏI�A�N�Z�XURL�Ȃ�
		$dos{'last_access_url'} = $REQUEST_URL;
		$dos{'last_post_buf'} = $main::postbuf;

			# �F�ؗp�̃L�[
			if($dos{'verify_char'} eq ""){ $dos{'verify_char'} = int(rand(9999)); }

	}



	# ���t�@�C�����X�V
	if($type =~ /Renew/){

		# �Ǐ���
		my(@renew_line_top);

			# ���n�b�V���𒲐�
			# �f�[�^�����Ă���ꍇ
			{
				my $strange_data_flag;
					if($dos{'dos_count'} && $dos{'dos_count'} =~ /[^\d\.]/){ $strange_data_flag = 1; $dos{'dos_count'} = 0; }
					if($dos{'all_access_count'} && $dos{'all_access_count'} =~ /[^\d\.]/){ $strange_data_flag = 2; $dos{'all_access_count'} = 0; }
					if($dos{'redun_request_count'} && $dos{'redun_request_count'} =~ /[^\d\.]/){ $strange_data_flag = 3; $dos{'redun_request_count'} = 0; }
					if($strange_data_flag){ Mebius::AccessLog(undef,"Dos-strange-data","���� : $strange_data_flag\n$top1\n$top2\n$top4\n$top4\n$top5\n$top6\n"); }
			}

		# �g�b�v�f�[�^��ǉ�
		push(@renew_line_top,"$dos{'key'}<>$dos{'last_access_time'}<>\n");
		push(@renew_line_top,"$dos{'access_count'}<>$dos{'access_start_time'}<>$dos{'last_access_url'}<>$dos{'last_post_buf'}<>\n");
		push(@renew_line_top,"$dos{'all_access_count'}<>$dos{'all_access_ymdf'}<>\n");
		push(@renew_line_top,"$dos{'dos_count'}<>$dos{'last_dos_count_time'}<>$dos{'dos_all_count'}<>\n");
		push(@renew_line_top,"$dos{'verify_count'}<>$dos{'verify_time'}<>$dos{'verify_char'}<>\n");
		push(@renew_line_top,"$dos{'redun_request_count'}<>$dos{'all_redun_request_count'}<>$dos{'last_redun_time'}<>\n");
		unshift(@renew_line,@renew_line_top);

		# �t�@�C���X�V
		seek($dos_handler,0,0);
		truncate($dos_handler,tell($dos_handler));
		print $dos_handler @renew_line;

	}

close($dos_handler);

	# �p�[�~�b�V�����ύX
	if($type =~ /Renew/ && ($dos{'file_touch_flag'} || rand(25) < 1)){ Mebius::Chmod(undef,$file); }

	# ���}�X�^�[�Ƀ��[���𑗐M����
	if($dos{'sendmail_flag'}){

		# �Ǐ���
		my($access_log_line);

		# ���M���e���`
		$access_log_line .= qq(IP�A�h���X�F $addr\n);
		$access_log_line .= qq(�z�X�g���F $multi_host->{'host'}\n);
		$access_log_line .= qq(Dos�����: $dos_pure{'dos_count'} (?)\n);
		$access_log_line .= qq(���A�N�Z�X��: $dos_pure{'all_access_count'} (?)\n);
		$access_log_line .= qq(���y�[�W�ւ̘A���A�N�Z�X��: $dos_pure{'redun_request_count'} / $dos_pure{'all_redun_request_count'} (?)\n);
		$access_log_line .= qq(����^�C�v�F $dos{'deny_type'}\n);
		$access_log_line .= qq(�z�X�g�^�C�v: $multi_host->{'type'}\n);
		$access_log_line .= qq(\n���O�F\n);
		$access_log_line .= qq($dos_flow{'access_log'}\n\n);

		# �e��f�[�^�擾
		my($server_domain) = Mebius::server_domain();

		# ���[�����M
		Mebius::Email::send_email("To-master Access-data-view",undef,"$dos{'deny_type'} - $multi_host->{'host'} - $server_domain",$access_log_line);

		# �A�N�Z�X���O���L�^
		Mebius::AccessLog(undef,"Dos-email-send");

	}

	# �����A�N�Z�X�����߂̌x����\������ꍇ
	if($type =~ /New-access/ && $dos{'all_access_alert_flag'} && $allow_error_flag){

		# �Ǐ���
		my($error_line);

		# ���O�����
		Mebius::AccessLog(undef,"Dos-all-access-error");

		$error_line .= qq(<div style="color:red;line-height:1.4;">\n);
		$error_line .= qq(�����̑��A�N�Z�X�����������܂��B����ւ��ăA�N�Z�X���Ȃ����Ă��������B<br$main::xclose>);
		$error_line .= qq(���̂܂܃A�N�Z�X�𑱂���ƁA���p�����������Ȃ���ꍇ������܂��B);
		$error_line .= qq(</div>\n);

		# HTML���o��
		Mebius::SimpleHTML({ FromEncoding => "sjis" , Message => $error_line });
	}


	# ��DOS����/���N�G�X�g����̌x����\������ꍇ
	elsif($type =~ /New-access/ && ($dos{'dos_alert_flag'} || $dos{'redun_request_alert_flag'}) && $allow_error_flag){

		# �Ǐ���
		my($error_line);

		# ���O�����
		Mebius::AccessLog(undef,"Dos-cgi-error");

		$error_line .= qq(<div style="color:red;line-height:1.4;">�ߏ�ȃA�N�Z�X�A�A��������ʍX�V��A�����t�q�k�ɃA�N�Z�X�������邱�Ƃ͂������������B<br>);
		$error_line .= qq(�S�ẴA�N�Z�X���O�͋L�^����Ă��܂��B<br>);
		$error_line .= qq(�T�[�o�[�ɕ��S��������s�ׂ������ꍇ�A���S�ȃA�N�Z�X������A<strong>���Ȃ��̃T�[�r�X�v���o�C�_�ւ̘A��</strong>�������Ă��������ꍇ������܂��B<br>);

		# ���x���P�F�x���̏ꍇ
		$error_line .= qq(<form action="/" method="post">\n);
		$error_line .= qq(<div>\n);
			foreach(keys %main::in){
				my $key = $_;
				my $value = $main::in{$_};
					if($key =~ /^(verify_char|dos_verify)$/){ next; }
				$error_line .= qq(<input type="hidden" name="$key" value="$value">\n);
			}
		$error_line .= qq(<input type="hidden" name="mode" value="index">\n);
		$error_line .= qq(<input type="hidden" name="dos_verify" value="verify">\n);
		$error_line .= qq(<input type="hidden" name="verify_char" value="$dos{'verify_char'}">\n);
		$error_line .= qq(<input type="submit" value="���ӂ��đ�����">\n);
		$error_line .= qq(</div>\n);
		$error_line .= qq(</form>\n);

		$error_line .= qq(</div>);
		#$error_line .= qq(<div style="line-height:1.4;margin:1em;">�����Ȃ��̍ŋ߂̃A�N�Z�X��<br>$dos_flow{'alert_index_line'}</div>);

		# HTML���o��
		Mebius::SimpleHTML({ FromEncoding => "sjis" ,  Message => $error_line });
	}



	# �t�@�C�����폜����ꍇ
	if($type =~ /Delete-file/){ unlink($file); }


return(%dos);

}

#-----------------------------------------------------------
# DOS�U�����L�^
#-----------------------------------------------------------
sub FlowFile{

# �錾
my($type,$host_or_addr,$host,$addr) = @_;
my($REQUEST_URL) = Mebius::request_url();
my($my_access) = Mebius::my_access();
my($now_date) = Mebius::get_date("HiRes");
my($dos_handler,%dos,@renew_line,$i,$host,$file);
my($time) = time;

# �f�B���N�g����`
my($init_directory) = Mebius::BaseInitDirectory();
my $directory1 = "${init_directory}_dos/";
my $directory2 = "${directory1}_dos_flow/";

# IP�A�h���X���z�X�g�����𔻒�
($dos{'file_type'}) = Mebius::Format::HostAddr(undef,$host_or_addr);

# �����`�F�b�N
if($host_or_addr eq "" || $host_or_addr =~ m!\.\./|^/!){ return(); }
$file = "$directory2${host_or_addr}_dos_flow.log";

	# �f�B���N�g���쐬
	if($type =~ /Renew/ && (rand(500) <= 1 || Mebius::alocal_judge())){ Mebius::Mkdir(undef,$directory2); }

	# �t�@�C�����J��
	open($dos_handler,"+<$file") || ($dos{'file_nothing_flag'} = 1);

	# �t�@�C�����Ȃ��ꍇ�͐V�K�쐬
	if($type =~ /Renew/ && $dos{'file_nothing_flag'}){
		Mebius::Fileout("Allow-empty",$file);
		open($dos_handler,"+<$file");
	}

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($dos_handler,2); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$dos_handler>);
($dos{'key'},$dos{'last_access_time'},$dos{'addr'},$dos{'host'},$dos{'account'},$dos{'cnumber'},$dos{'agent'}) = split(/<>/,$top1);

# �n�b�V���𒲐�
if(!$dos{'file_nothing_flag'}){ $dos{'f'} = 1; }

	# ���t�@�C����W�J
	while(<$dos_handler>){

		# ���E���h�J�E���^
		$i++;

		# �s��ǉ�
		chomp;
		my($time2,$date2,$url2,$agent2) = split(/\t/);

			# ���A���[�g�\���p
			if($type =~ /Get-alert/){
				#$dos{'alert_index_line'} .= qq($date2);
				#$dos{'alert_index_line'} .= qq(<br>\n);
					if($i <= 100){ $dos{'access_log'} .= qq($date2	$url2	$agent2	$addr\n); }
			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){

					# �ő�s���ɒB�����ꍇ
					if($i >= 100){ last; }

				# �X�V�s��ǉ�
				push(@renew_line,"$time2\t$date2\t$url2\t$agent2\n");
			}

	}

	# ���V�K�A�N�Z�X�̏ꍇ
	if($type =~ /New-access/){

		# �V�����ǉ�����s
		unshift(@renew_line,"$time\t$now_date->{'date_till_micro_second'}\t$REQUEST_URL\t$my_access->{'multi_user_agent'}\n");

		# �g�b�v�f�[�^�̏�������
		$dos{'host'} = $host;
		$dos{'account'} = $main::myaccount{'file'};
		$dos{'cnumber'} = $main::cnumber;
		$dos{'agent'} = $my_access->{'multi_user_agent'};
		$dos{'addr'} = $addr;
		$dos{'last_access_time'} = Time::HiRes::time;
		#$dos{'last_access_time'} = $time;
	}

	# ���t�@�C���X�V
	if($type =~ /Renew/){

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$dos{'key'}<>$dos{'last_access_time'}<>$dos{'addr'}<>$dos{'host'}<>$dos{'account'}<>$dos{'cnumber'}<>$dos{'agent'}<>\n");

		# �t�@�C���X�V
		seek($dos_handler,0,0);
		truncate($dos_handler,tell($dos_handler));
		print $dos_handler @renew_line;
		close($dos_handler);

	}

close($dos_handler);

	# �p�[�~�b�V�����ύX
	if($type =~ /Renew/){ Mebius::Chmod(undef,$file); }

	# �t�@�C�����폜����ꍇ
	if($type =~ /Delete-file/){ unlink($file); }

return(%dos);


}

#-----------------------------------------------------------
# Apache�̃A�N�Z�X�����p�t�@�C��
#-----------------------------------------------------------
sub HtaccessFile{


# �錾
my($type,$addr,$host) = @_;
my($deny_handler,$i,$log_file,@renew_line,$rebety_time,$new_deny_time,%deny,$htaccess_file);
my($htaccess_handler,@renew_htaccess_line,$directory,%self);
my($time) = (time);

# �A�N�Z�X�𐧌��������
$new_deny_time = 1*24*60*60;

	# �����`�F�b�N
	if($addr eq "" || $addr =~ /[^0-9\.]/){ return(); }

# �f�B���N�g��
my($init_directory) = Mebius::BaseInitDirectory();
my($server_domain) = Mebius::server_domain();
my($now_date) = Mebius::now_date();

	# �t�@�C����` (���[�J��)
	if(Mebius::alocal_judge()){
		$directory = "${init_directory}_htaccess/";
		$log_file = "${directory}htaccess.log";
		$htaccess_file = "${init_directory}../cgi-bin/.htaccess";
	}
	# �t�@�C����` (�T�[�o�[)
	else{
		$directory = "${init_directory}_htaccess/";
		$log_file = "${directory}htaccess.log";
		$htaccess_file = "/var/www/$server_domain/public_html/.htaccess";
	}


# �t�@�C�����J��
	# �t�@�C�����J��
	my($deny_handler,$read_write) = Mebius::File::read_write($type,$log_file,[$directory]);
		if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }

	# ���t�@�C����W�J
	while(<$deny_handler>){

		# �Ǐ���
		my($line_flag,$addr2,$data_line);

		# ���E���h�J�E���^
		$i++;

		# �f�[�^�s�𕪉�
		chomp;
		my($key2,$addr2,$host2,$deny_time2,$deny_date2) = split(/<>/);

			# ���V���������p
			if($type =~ /New-deny/){

					# ����IP�A�h���X�̏ꍇ
					if($addr2 eq $addr){ next; }

					# �������Ԃ��߂��Ă���ꍇ
					if($time > $deny_time2){ next; }

			}

			# ����A�h���X�̍폜
			if($type =~ /Delete-addr/){

					if($addr2 eq $addr){ next; }

			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){

					# �ő�L�^�s���ɒB�����ꍇ
					if($i >= 500){ last; }

					# �X�V�s��ǉ�����
					push(@renew_line,"$key2<>$addr2<>$host2<>$deny_time2<>$deny_date2<>\n");
			}

			# �� .htaccess �p�̍s��`
			push(@renew_htaccess_line,"# $host2 $deny_date2\n");
			push(@renew_htaccess_line,"Deny from $addr2\n");

	}


	# ���V��������
	if($type =~ /New-deny/){

		# �����I������
		my($rebety_time);
		my $rebety_time = $time + $new_deny_time;
		my (%rebety_time) = Mebius::Getdate("Get-hash",$rebety_time);

		# �V�����ǉ�����s
		unshift(@renew_line,"<>$addr<>$host<>$rebety_time<>$rebety_time{'date'}<>\n");

		# �� .htaccess �p�̍s��`
		unshift(@renew_htaccess_line,"Deny from $addr\n");
		unshift(@renew_htaccess_line,"# $host $now_date\n");

	}

	# ���t�@�C���X�V ( ���O�t�@�C�� )
	if($type =~ /Renew/){	Mebius::File::truncate_print($deny_handler,@renew_line); }

close($deny_handler);

	# �p�[�~�b�V�����ύX
	if($type =~ /Renew/){ Mebius::Chmod(undef,$log_file); }

	# �� .htaccess �t�@�C�������ۂɏ�������
	if($type =~ /Renew/){ 

		unshift(@renew_htaccess_line,qq(Allow from all\n));
		unshift(@renew_htaccess_line,qq(Order allow,deny\n));

		# �t�@�C���X�V
		Mebius::Fileout(undef,$htaccess_file,@renew_htaccess_line);
	}

}

1;
