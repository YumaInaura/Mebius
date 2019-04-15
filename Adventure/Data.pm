
use strict;
use Mebius::Login;
package Mebius::Adventure;

#-----------------------------------------------------------
# �L�����t�@�C�����J��
#-----------------------------------------------------------
sub File{

# �錾
my($myaccount) = Mebius::my_account();
my($init) = &Init();
my($type,$use) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my(%select_renew,%adv,$login_mode,%select_renew,@renew_line,$file_type);
my(undef,undef,$select_renew) = @_ if($type =~ /Renew/);
my($saveline,$id,$certyfied_id,$renew,$StateName1,%self_renew,$broken_file_flag,%data_format);

# ID���`
$id = $use->{'id'};
$certyfied_id = $use->{'my_id'};


	# ���[�h����t�@�C���^�C�v���`
	if($use->{'FileType'} eq "Account"){ $file_type = "Account"; }
	elsif($use->{'FileType'} eq "Cookie"){ $file_type = "Cookie"; }
	elsif($use->{'FileType'} eq "OldId"){ $file_type = "OldId"; }

	# �N�G������t�@�C���^�C�v���`
	elsif($use->{'InputFileType'} eq "account"){ $file_type = "Account"; }
	elsif($use->{'InputFileType'} eq "cookie"){ $file_type = "Cookie"; }
	elsif($use->{'InputFileType'} eq "old_id"){ $file_type = "OldId"; }
	else{ main::error("�A�J�E���g�̎�ނ�I�����ĉ������B"); }

	# ID�����͂̏ꍇ�Ȃ� 
	#�I�������ł����ƃG���[���o�������^�[�����Ȃ��ƁA�n�b�V�����ςȉӏ��ɘR���\�������邽�ߒ��Ӂ��I 

	# ���e�X�g�v���C���[ ( Cookie )
	if($file_type eq "Cookie"){

			# �������`�F�b�N
			if($id =~ /[^a-zA-Z0-9]/){
				main::error("�L����ID���ςł��B");
			}

		$adv{'FileType'} = $use->{'FileType'};
		$adv{'input_file_type'} = "cookie";
		$adv{'file_type'} = $file_type;
		$adv{'base_directory'} = "$init->{'adv_dir'}_id_testplayer_adv/";
		$adv{'directory'} = "$adv{'base_directory'}${id}_adv/";
		$adv{'file'} = "$adv{'directory'}${id}_adv.dat";
		#$adv{'backup_file'} = "$adv{'directory'}${id}_backup_adv.dat";
		$adv{'test_player_flag'} = 1;
	}

	# ���A�J�E���g�v���C���[
	elsif($file_type eq "Account"){

			# ID���w�肳��Ă��Ȃ��ꍇ�A�s���ȏꍇ
			if($id && Mebius::Auth::AccountName(undef,$id)){

					# �e�X�g�v���C���[�p�̓���A�J�E���g ( test ) ���g���ꍇ
					#if($use->{'Multi-test-player'}){
					#	$adv{'test_player_flag'} = 1;
					#	$id = "test";
					#	$certyfied_id = "test";
					#}
					# �G���[��\������ꍇ
					#else{
					#if(!&Mebius::alocal_judge()){
							main::error("�A�J�E���g�����ςł��B");
					#}
					#}
			}
			# ID���������ꍇ
			else{

				$adv{'FileType'} = $use->{'FileType'};
				$adv{'input_file_type'} = "account";
				$adv{'file_type'} = $file_type;
				$adv{'base_directory'} = "$init->{'adv_dir'}_id_adv/";
				$adv{'directory'} = "$adv{'base_directory'}${id}_adv/";
				$adv{'file'} = "$adv{'directory'}${id}_adv.dat";
				$adv{'backup_file'} = "$adv{'directory'}${id}_backup_adv.dat";
				$adv{'overwrite_file'} = "$adv{'directory'}${id}_overwrite_adv.dat";
				$adv{'formal_player_flag'} = 1;

			}
	}

	# ����ID�t�@�C��
	elsif($file_type eq "OldId"){

			# �������`�F�b�N
			if($id =~ /[^a-zA-Z0-9]/){
				main::error("�L����ID���ςł��B");
			}

		$adv{'FileType'} = $use->{'FileType'};
		$adv{'input_file_type'} = "old_id";
		$adv{'file_type'} = $file_type;
		$adv{'directory'} = "$init->{'adv_dir'}_charadata_adv/";
		$adv{'file'} = "$adv{'directory'}${id}_adv.cgi";
		$adv{'old_player_flag'} = 1;
	}

	# ���̑�
	else{
		main::error("�A�J�E���g�̎�ނ�I�����ĉ������B");
	}

	# �����ȃv���C���[�łȂ��ƃG���[�ɂ���ꍇ
	if($use->{'FormalPlayerCheckAndError'} && !$adv{'formal_player_flag'}){
		&main::error("�A�J�E���g�o�^����Ă���v���C���[�łȂ��ƁA���̑���͎��s�ł��܂���B");
	}

	# ��ID�����w��̏ꍇ ( �t�@�C�����Ȃǂ̏��͕Ԃ��悤�ɁA�t�@�C������`���I������ʒu )
	if($id eq ""){ 
			if($type{'Allow-empty-id'}){ return(\%adv); }
			else{ main::error("ID���w�肵�Ă��������B"); }
	}

	# �V�K�o�^�̏ꍇ
	if($type =~ /New-character/ || $use->{'TypeTrance'}){
			if(-f $adv{'file'}){ main::error("����ID�̃L�����N�^�͊��ɑ��݂��܂��B"); }
			else{
				Mebius::Mkdir(undef,$adv{'base_directory'});
				my($mkdir_success) = Mebius::Mkdir(undef,$adv{'directory'});
					if(!$mkdir_success){ main::error("�L�����N�^���쐬�ł��܂���ł����B���ɓ����A�J�E���g���̃L�����N�^�����݂��邩�A�L�����N�^��������𒴂��Ă����\�\\��������܂��B"); }
			}
	}
	# �������ǂ������`�F�b�N
	if($type{'Password-check'}){
		my($advmy) = my_data(); # ���[�v�ɒ���
			if(!$id){ main::error("ID���w�肵�Ă��������B"); }
			if(!$certyfied_id){ main::error("���O�C�����Ă��܂���B"); }
			#if(!$adv{'formal_player_flag'}){ &main::error(""); }
			if($certyfied_id ne $id){
				Mebius::AccessLog(undef,"Adventure-strange-login-action","$certyfied_id ne $id");
				main::error("�����̃f�[�^�ł͂���܂���B");
			}
			if($certyfied_id ne $advmy->{'id'}){ main::error("�����̃f�[�^�ł͂���܂���B"); }
			if($advmy->{'file_type'} ne $adv{'file_type'}){ main::error("�����̃f�[�^�ł͂���܂���B"); }
			# && !$myaccount->{'master_flag'}
	}
	
	# �e�X�g�v���C���[�̎��s���֎~����ꍇ
	if($use->{'TypeDenyTestPlayer'} && $adv{'test_player_flag'}){
		main::error("�e�X�g�v���C���͎��s�ł��܂���B");
	}

	# �^�C�v�ǉ�
	if($type{'Password-check'}){ $type .= qq( File-check-error); }
	if($type !~ /New-character/ && !$use->{'TypeTrance'}){ $type .= qq( Deny-touch-file); }


	if($type =~ /Base-mydata/){
		$type .= " Flock2";
	}

# �t�@�C�����J��
my($FILE1,$read_write) = Mebius::File::read_write($type,$adv{'file'},[$adv{'directory'}]);
	if($read_write->{'f'}){ %adv = (%adv,%$read_write); } else { return(\%adv); }	

# �C�ӂ̃L�����f�[�^��F��
$adv{'id'} = $id;

$data_format{'1'} = [('pass','name','sex','pr','comment','url','waza','hashed_password','salt','concept')];
$data_format{'2'} = [('level','hp','maxhp','exp','gold','karman','total','win','job','jobname','jobrank','spatack','spodds','bank','charity','autobank')];
$data_format{'3'} = [('power','brain','believe','vital','tec','speed','charm')];
$data_format{'4'} = [('item_number','item_name','item_damage','item_job','item_damage_plus','item_concept')];
$data_format{'5'} = [('mons','host','lasttime','agent','number','encid','account','charge_end_time')];
$data_format{'6'} = [('lastwinid','sp','char','draw','allaction')];
$data_format{'7'} = [('top_monster_level','jobmatch','jobconcept','lastmodified','today_action','today_action_date')];
# �ςȍs���΍�̂��߂̒l
$data_format{'8'} = [('break_missed','break_char','today_action_buffer',undef,'block_time')];
# �s���̎�ނ��L�����Ă��镔�� 
$data_format{'9'} = [('last_select_monster_rank','last_select_special_id')];
# �����f�[�^
$data_format{'10'} = [('first_time','first_host','first_agent')];
# �f�[�^�ڍs����
$data_format{'11'} = [('trance_to_account','trance_to_time','trance_from_account','trance_from_time')];
# �J�E���g�n ( �����X�^�[�Ƃ̐퓬 )
$data_format{'12'} = [('monster_battle_count','monster_battle_win_count','monster_battle_lose_count','monster_battle_draw_count')];
# �J�E���g�n ( �ΐl��A���͉��̑���Ɛ�������A���͏�̑���Ɛ������ )
$data_format{'13'} = [('human_battle_win_champ_count','human_battle_stay_champ_count','human_battle_dog_count','human_battle_chicken_count','human_battle_keep_count')];
# �V�X�e�[�^�X
$data_format{'14'} = [('all_level','brave')];
# �e�헚���J�E���g (�ȑf�n)
$data_format{'15'} = [('yado_count','last_yado_time')];
# �e�헚���J�E���g (�l���n)
$data_format{'16'} = [('job_change_count','name_change_count','sex_change_count')];
# �M�����u���֌W?
$data_format{'17'} = [('last_gamble_time','last_gamble_lot_gold','last_gamble_win_gold','last_gamble_result')];

# ���ʌn
$data_format{'31'} = [('effect_levelup_boost')];
$data_format{'32'} = [('effect_levelup_boost_time')];


	# �g�b�v�f�[�^��ǂݍ���
	my($split_data) = Mebius::file_handle_to_hash(\%data_format,$FILE1);
	%adv = (%adv,%$split_data);

		# 2012/3/8 (��)
		if($adv{'effect_levelup_boost_time'} > time + 3*60*60){
			$adv{'effect_levelup_boost_time'} = time + 30*60;
		}

		# 2012/3/9 (��)
		if($adv{'all_level'} < $adv{'level'}){
			$adv{'all_level'} = $adv{'level'} * 1.5;
		}

	# �`���[�W���Ԃ��I����ĂȂ��ꍇ�̃G���[
	# ���d������_�����s���s�ׂ�h�~���邽�߁A�K�����̃T�u���[�`���̒��Ŏ��s���Ă���
	if($use->{'TypeChargeTimeCheckError'} && time < $adv{'charge_end_time'}){
		close($FILE1);
		main::error("�܂��`���[�W���Ԃ��I����Ă��܂���B");
	}

	# ���O���Ȃ��ƃf�[�^�����Ă��邩������Ȃ��Ɣ��肵�ăG���[��
	if(!$adv{'file_touch_flag'} && ($adv{'name'} eq "" || $adv{'level'} eq "")){
		$broken_file_flag = 1;
	}

	# ���O�C���`�F�b�N
	if($type =~ /Base-mydata/){


			# ���[�v���֎~
			if($type =~ /Password-check/){ die("Perl Die! Careful for rooping."); }

			# ����
			if($id && $certyfied_id && $id eq $certyfied_id){
				$adv{'login_flag'} = 1;
			}
			# ���s
			else{
				close($FILE1);
				return();
			}
	}



	# �������̍s���񐔂������ꍇ�A�t���O�𗧂Ă�
	if($adv{'today_action'} >= 5*60){
		# �s���񐔂������ꍇ�ɁA�\��/�������@��ς��邽�߂̃t���O�𗧂Ă�
		$adv{'over_action_flag'} = 1;
			# �A�N�Z�X���O�̋L�^
			if($type =~ /Charge-time/){
				Mebius::AccessLog(undef,"Adventure-today-action-over","�L����ID�F$adv{'id'} / �����̍s���񐔁F $adv{'today_action'}��");
			}
	}

	# �������Ԃ̗��p�֎~
	if($type =~ /Password-check/){
				if($adv{'block_time'} && time < $adv{'block_time'}){
					my($left_date) = Mebius::SplitTime("Get-top-unit",$adv{'block_time'} - $main::time); 
					close($FILE1);
					main::error("���̃L�����N�^�[ ( $adv{'id'} ) �͂��΂炭���p�ł��܂���B(�c��$left_date)");
				}
	}

	# ���s���񐔂������ꍇ�A���Ԋu�Ő������͉�ʂ��o��
	if($type =~ /Base-mydata/ && $adv{'today_action_buffer'} >= $init->{'break_interval'}){

		# �A�N�Z�X���O�ւ̋L�^���e
		my $record_accesslog = qq(�L����ID�F $adv{'id'} /  �m�F�ԍ��F$adv{'break_char'} / ���͔ԍ��F $main::in{'break_char'} / �s���񐔁F $adv{'today_action_buffer'} / ���s�� $adv{'break_missed'} / URL�F http://aurasoul.mb2.jp/gap/ff/ff.cgi?mode=chara&chara_id=$adv{'id'} );

		# �t���O�𗧂Ă�
		$adv{'strange_flag'} = 1;

			# ���͔ԍ��̑S�p�𔼊p��
			my($break_char_input) = Mebius::Number(undef,$main::in{'break_char'});
			$break_char_input =~ s/(^\s|\s$)//g;


			# �F�؂ɐ��������ꍇ�A�J�E���^�����Z�b�g����
			if($break_char_input eq $adv{'break_char'}){

				# ������ %renew �������Ȃ��ƁA�S�Ẵf�[�^�������Ă��܂��̂Œ��ӁI�I
				#%renew = %adv;
				$type{'Renew'} = 1;

				# �l�̑���
				$self_renew{'break_missed'} = 0;
				$self_renew{'today_action_buffer'} = 0;
				$self_renew{'strange_flag'} = 0;	# ���̒l���X�V����킯�ł͂Ȃ����ǁA�Ō�Ƀn�b�V���Ƃ��� %renew ��Ԃ����߁A���̂悤�ɏ���
				Mebius::AccessLog(undef,"Adventure-successed-break","$record_accesslog");

			}

			# �F�؂Ɏ��s�����ꍇ�A�m�F�ԍ���ύX���A���s�J�E���^�𑝂₷
			else{

				# ������ %renew �������Ȃ��ƁA�S�Ẵf�[�^�������Ă��܂��̂Œ��ӁI�I
				#%renew = %adv;
				$type{'Renew'} = 1;

				# �l�̑���
				$self_renew{'break_missed'} = $adv{'break_missed'} + 1;
				$self_renew{'break_char'} = int rand(9999);
				Mebius::AccessLog(undef,"Adventure-missed-break","$record_accesslog");

					# ���s�񐔂��I�[�o�[�����ꍇ�A�����ԁA�L�����f�[�^�̗��p�𐧌�����
					if($self_renew{'break_missed'} >= 10 + 1){
						$self_renew{'today_action_buffer'} = 0;
						$self_renew{'break_missed'} = 0;
						$self_renew{'block_time'} = time + 7*24*60*60;
						$self_renew{'strange_flag'} = 0;
						Mebius::AccessLog(undef,"Adventure-deny-break","$record_accesslog");
					}
			}

	}

	# ���t���ς�����ꍇ�A�����̍s���񐔂����Z�b�g ( Strange �t���O�����Ă��Ȃ��ꍇ )
	elsif("$main::thisyearf-$main::thismonthf-$main::todayf" ne $adv{'today_action_date'}){

		$self_renew{'today_action'} = 0;
		$self_renew{'today_action_buffer'} = 0;
	}

	# �܂������������e�̃|�X�g���֎~
	if($type =~ /Char-check/ || exists $use->{'input_char'}){
			# �O��X�V�����莞�ԓ��̂ݔ���
			if($adv{'char'} && time < $adv{'lasttime'} + 30*60*60 && !$myaccount->{'master_flag'}){ 
					if($use->{'input_char'} eq ""){
						close($FILE1);
						main::error("�����ςȑ��M�ł��BTOP�y�[�W�ɖ߂��Ă�蒼���Ă��������B");
					}
					if($adv{'char'} ne $use->{'input_char'}){
						close($FILE1);
						main::error(qq(�����ĂQ��ȏ�A�������e�𑗐M���邱�Ƃ͏o���܂���B�u���E�U�́u��ʍX�V�v��u�߂�v�{�^�����g���ƁA���̌��ۂ��N����ꍇ������܂��B���܂��s���Ȃ��ꍇ��<a href="$init->{'script'}">�g�b�v�y�[�W</a>����A�N�Z�X���Ȃ����Ă��������B));
					}
			}
	}

# �o���l
$adv{'next_exp'} = $adv{'level'} * $init->{'lv_up'};
	if($adv{'jobname'} =~ /^(�E��|�C�s�m)$/){ $adv{'next_exp'} *= 1.30; }
	elsif($adv{'jobname'} =~ /^(�i��|�x��q|�N��|\Q���@���L���[\E|��)$/){ $adv{'next_exp'} *= 1.15; }
	elsif($adv{'jobname'} =~ /^(��m)$/){ $adv{'next_exp'} *= 0.85; }
	if($adv{'level'} >= 100000){ $adv{'next_exp'} *= 1.35; }
	elsif($adv{'level'} >= 50000){ $adv{'next_exp'} *= 1.30; }
	elsif($adv{'level'} >= 25000){ $adv{'next_exp'} *= 1.25; }
	elsif($adv{'level'} >= 10000){ $adv{'next_exp'} *= 1.20; }
	elsif($adv{'level'} >= 5000){ $adv{'next_exp'} *= 1.10; }
	elsif($adv{'level'} >= 1000){ $adv{'next_exp'} *= 1.05; }
$adv{'next_exp'} = int $adv{'next_exp'};

	# ���n�b�V���l�����Ƀt���O�𗧂Ă�
	{

			# �҂�����
			if($adv{'charge_end_time'} && time < $adv{'charge_end_time'}) {
				$adv{'wait_disabled'} = $main::disabled;
				$adv{'still_charge_flag'} = 1;
				$adv{'waitsec'} = $adv{'charge_end_time'} - time;
			}

		# �n�b�V����ݒ�i����j
		if($adv{'jobname'} eq '�x��q'){ $adv{'redun'} = int($init->{'redun'} * 0.83);  } else{ $adv{'redun'} = $init->{'redun'};  }

		$adv{'item_damage_all'} = $adv{'item_damage'} + $adv{'item_damage_plus'}; 
			if($file_type eq "OldId"){
				$adv{'chara_url'} = "$init->{'script'}?mode=chara&amp;chara_id=$adv{'id'}";
			}
			elsif($file_type eq "Account"){
				$adv{'chara_url'} = "$init->{'script'}?mode=status&amp;id=$adv{'id'}";
			}

		$adv{'chara_link'} = qq(<a href="$adv{'chara_url'}">$adv{'name'}</a> ( Lv$adv{'level'} $adv{'jobname'} ) );

		my $buf = $adv{'total'}-$adv{'draw'};
			if($buf){ $adv{'winodds'} = int( ( $adv{'win'} / $buf ) * 100 ); }
			else{ $adv{'winodds'} = 0; }

			$adv{'lose'} = $adv{'total'} - $adv{'win'} - $adv{'draw'};

			# �A�C�e��
			if($adv{'sex'} eq "1"){ $adv{'sextype'} = "�j"; } else { $adv{'sextype'} = "��"; }

	}

	# ���t�@�C���X�V
	if($type{'Renew'}){

			# �������̃f�[�^�̏ꍇ�AIP�Ȃǂ̃f�[�^���X�V
			if($type =~ /(MYDATA|Mydata)/ && $adv{'id'} eq $use->{'my_id'}){

				# �e��ڑ��f�[�^���擾
				($self_renew{'host'}) = Mebius::GetHostWithFile();
				$self_renew{'number'} = $main::cnumber;
				($self_renew{'encid'}) = main::id();
				$self_renew{'agent'} = $main::agent;
				$self_renew{'account'} = $main::pmfile;
				$self_renew{'break_char'} = int rand(9999);

				# �f�[�^�C��
				if($adv{'all_level'} eq ""){ $self_renew{'all_level'} = int($adv{'total'}*2); }
				#$self_renew{'autobank'} =~ s/^(0+)//g;	# CCC 2012/1/8 (��)

				# �s���p��Char��ݒ�
				$self_renew{'char'} = Mebius::Crypt::char(undef,50);

					# �������̍s���� / ����̃`���[�W���Ԃ��L�^
					if($type =~ /Charge-time/){

						# �`���[�W����
						my($wait_second_by);
						$self_renew{'charge_end_time'} = time + $adv{'redun'};

						# ���̃f�[�^
						$self_renew{'lasttime'} = time;
						$self_renew{'today_action_date'} = qq($main::thisyearf-$main::thismonthf-$main::todayf);
						$self_renew{'+'}{'today_action'} = 1;
						$self_renew{'+'}{'today_action_buffer'} = 1;
					}

			}

			($renew) = Mebius::Hash::control(\%adv,\%self_renew,$select_renew);

			# �L�����ő̃t�@�C�����X�V
			if(!$broken_file_flag){
				Mebius::File::data_format_to_truncate_print(\%data_format,$FILE1,$renew);
			}

	}



close($FILE1);



	# �L�����t�@�C���̃p�[�~�b�V�����ύX
	if($type{'Renew'} && !$broken_file_flag){
		#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($adv{'today_action_buffer'} / $renew->{'today_action_buffer'})); }
		Mebius::Chmod(undef,$adv{'file'});
	}

	# �t�@�C������
	if($broken_file_flag){

		# ���������s
		my($flag) = Mebius::return_backup($adv{'file'});
			# �����ɐ���
			if($flag == 1){ main::error(" $id �̃f�[�^�����ɂ��A�L�����f�[�^���o�b�N�A�b�v���畜�����܂����B��ʂ��X�V���Ă��������B"); }
			# �����Ɏ��s
			else{
				Mebius::AccessLog(undef,"Adventure-broken-account-file","�A�J�E���g�F $id ���O : $adv{'name'} / $flag");
				main::error("$id �̃L�����f�[�^���������Ă����\�\\��������܂��B");
			}

	# �o�b�N�A�b�v
	} elsif($type{'Renew'} && (rand(100) < 1 || Mebius::alocal_judge())){
		Mebius::make_backup($adv{'file'});
	}

	# �������L���O�t�@�C�����X�V
	if($type{'Renew'} && $file_type eq "Account"){
		require Mebius::Adventure::Ranking;
		&RankingFile({ TypeRenew => 1 , TypeNewStatus => 1 },{},$renew);
	}

	# ���^�[��
	if($type{'Renew'}){
		return($renew);
	}
	else{
		return(\%adv);
	}

}



1;

