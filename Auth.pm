
use strict;
use Mebius::History;
use Mebius::Referer;
use Mebius::Login;
use Mebius::SNS;
package Mebius;

#-----------------------------------------------------------
# �����̃A�J�E���g�f�[�^
#-----------------------------------------------------------
sub my_account{

# �錾
my($use) = @_;
my(%myaccount,$NotGetAccountFlag);
my($basic_init) = Mebius::basic_init();

# ���O���`
my $HereName1 = "my_account";

# Near State �i�Ăяo���j 2.10
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereName1);
	if(defined $state){ return($state); }

# ���[�v�\�h
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereName1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereName1); }

# Cookie���擾
my($mycookie) = Mebius::my_cookie_main();

	# �K�{�f�[�^ ( Sreturn ���Ă��܂��� State �l���ۑ��ł��Ȃ��̂ŁA�t���O�𗧂ĂăT�u���[�`���̍Ō�܂ŏ��������� )
	if(!$mycookie->{'account'}){ $NotGetAccountFlag = 1; }
	if(!$mycookie->{'hashed_password'}){ $NotGetAccountFlag = 1; }

	# �A�J�E���g������ ( ���� Auth::File �ł��G���[���o���Ă��邯�ǁA�O�̂��߂����ł��`�F�b�N)
	# Auth::File �̓����Ń��^�[��������G���[���o�����肷��Ə������ώG�Ȃ̂ŁA�����Łu�A�J�E���g�f�[�^���擾���Ȃ��v�Ƃ������������Ă���
	if(Mebius::Auth::AccountName(undef,$mycookie->{'account'})){ $NotGetAccountFlag = 1; }

	# �������̃A�J�E���g�f�[�^���擾
	if(!$NotGetAccountFlag){

		# �A�J�E���g�f�[�^���擾 ( Flock2 ���O���Ȃ��I )
		(%myaccount) = Mebius::Auth::File("Get-my-account Not-file-check Flock2 Option Block-rooping",$mycookie->{'account'},$mycookie->{'hashed_password'});

			#if(Mebius::alocal_judge()){ $myaccount{'admin_flag'} = $myaccount{'master_flag'} = 0; }

			# ���C��
			#if($ENV{'REQUEST_METHOD'} eq "GET"){

					# ��Debug ( ���݂����Ȃ��H)
					#if($myaccount{'login_flag'} && $myaccount{'cookie_regist_count'} <= 20 && $myaccount{'concept'} !~ /Low-gold-fixed-2012-03-11/ && $myaccount{'firsttime'} < (1354851067 - 9*30*24*60*60)){

					#	my %renew_account;

					#		my($save_old) = Mebius::save_data({ FileType => "Account" },$myaccount{'file'});

					#			foreach(keys %$save_old){
					#					if($_ =~ /^cookie_/){ $renew_account{$_} = $save_old->{$_}; }
					#			}

					#			if($save_old->{'f'} && $save_old->{'cookie_regist_count'} > $myaccount{'cookie_regist_count'}){
					#				Mebius::AccessLog(undef,"Gold-low-account-and-save","�A�J�E���g: $myaccount{'file'} / $save_old->{'cookie_regist_count'} > $myaccount{'cookie_regist_count'} / ���� $save_old->{'cookie_gold'} > $myaccount{'cookie_gold'} ");
					#			}
					#			else{
					#				Mebius::AccessLog(undef,"Gold-not-low-account-and-save","�A�J�E���g: $myaccount{'file'} / $save_old->{'cookie_regist_count'} > $myaccount{'cookie_regist_count'} / ���� $save_old->{'cookie_gold'} > $myaccount{'cookie_gold'} ");
					#			}

						# �X�V
					#	$renew_account{'.'}{'concept'} .= " Low-gold-fixed-2012-03-11";
					#	Mebius::Auth::File("Renew Block-rooping",$myaccount{'file'},\%renew_account);

					#}

					# ���Z�[�u�f�[�^�������C�� 2012/2/28 (��)
					#if($myaccount{'login_flag'} && $myaccount{'concept'} !~ /Old-save-data-tranced/ && $myaccount{'firsttime'} < (1354851067 - 8*30*24*60*60)){

					#	my %renew_account;

					#	my($save_old) = Mebius::save_data({ FileType => "Account" },$myaccount{'file'});
					#		foreach(keys %$save_old){
					#				if($_ =~ /^cookie_/){ $renew_account{$_} = $save_old->{$_}; }
					#		}

					#		if($save_old->{'f'}){
					#			Mebius::AccessLog(undef,"Save-data-to-account","�A�J�E���g : $myaccount{'file'}");
					#		}
					#		else{
					#			Mebius::AccessLog(undef,"Save-data-not-found","�A�J�E���g : $myaccount{'file'}");
					#		}

						# �X�V
					#	$renew_account{'.'}{'concept'} .= " Old-save-data-tranced";
					#	Mebius::Auth::File("Renew Block-rooping",$myaccount{'file'},\%renew_account);

					#}

					# �� aurasoul.mb2.jp �̋��݂� mb2.jp �Ɉ����p�� 2012/12/7 (��)
					#elsif($myaccount{'login_flag'} && $myaccount{'concept'} !~ /Gold-join-with-old-server-2013.01.18/ && $myaccount{'firsttime'} < 1354851067 && Mebius::Server::bbs_server_judge()){

					#	my(%renew_account);

					#	my(%old_server_account) = Mebius::Auth::File("Block-rooping Old-server-file File-check-return",$myaccount{'file'});

					#	$renew_account{'cookie_gold_old_server'} = $old_server_account{'cookie_gold'};
					#	$renew_account{'cookie_regist_all_length_old_server'} = $old_server_account{'cookie_regist_all_length'};
					#	$renew_account{'cookie_regist_count_old_server'} = $old_server_account{'cookie_regist_count'};

					#	$renew_account{'+'}{'cookie_gold'} = $old_server_account{'cookie_gold'};
					#	$renew_account{'+'}{'cookie_regist_all_length'} = $old_server_account{'cookie_regist_all_length'};
					#	$renew_account{'+'}{'cookie_regist_count'} = $old_server_account{'cookie_regist_count'};

					#	$renew_account{'cookie_gold_save_original'} = $myaccount{'cookie_gold'};
					#	$renew_account{'cookie_regist_all_length_save_original'} = $myaccount{'cookie_regist_all_length'};
					#	$renew_account{'cookie_regist_count_save_original'} = $myaccount{'cookie_regist_count'};

					#	$renew_account{'.'}{'concept'} .= " Gold-join-with-old-server-2013.01.18";
					#	Mebius::Auth::File("Renew Block-rooping File-check-return",$myaccount{'file'},\%renew_account);

					#	Mebius::AccessLog(undef,"Gold-move-from-old-server-2013-01-18","�A�J�E���g : $myaccount{'file'} / �ړ��������� : $old_server_account{'cookie_gold'}��");

					#}

			#}

	}

	#if(Mebius::alocal_judge()){ $myaccount{'admin_flag'} = 0; }
	# ���e�����t�@�C���̃f�[�^���X�V
	#Mebius::HistoryAll("RENEW My-file "); #=> roop �G���[��

	# ���[�v������\�h ( ��� ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereName1); }

	# Near State �i�ۑ��j 2.10
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$HereName1,\%myaccount); }

return(\%myaccount);

}

package Mebius::Auth;

#-----------------------------------------------------------
# �p�X
#-----------------------------------------------------------
sub account_path{

my(%self);
my($use) = shift if(ref $_[0] eq "HASH");
my($account) = @_;
#my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();	

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){
		die("Perl Die!  Can't decide account data directory.");
	}

my($account_first_word) = substr($account,0,1);
my($account_second_word) = substr($account,1,1);

	# �Â��`���̃f�B���N�g��
	if(exists $use->{'OldDirectory'}){ 
		$self{'root_directory'} = "${share_directory}_id/$account/";
	# �V�����`���̃f�B���N�g��
	} else{
		$self{'first_word_directory'} = "${share_directory}_account/${account_first_word}/";
		$self{'second_word_directory'} = "$self{'first_word_directory'}${account_second_word}/",
		$self{'root_directory'} = "$self{'second_word_directory'}$account/",
	}


\%self;


}


#-----------------------------------------------------------
# �A�J�E���g���̊�{�f�[�^�f�B���N�g��
#-----------------------------------------------------------
sub account_directory{

my($use) = shift if(ref $_[0] eq "HASH");
my($account) = @_;
my($account_path);

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){
		Mebius::AccessLog(undef,"Cant-decicde-account-directory");
		return();
	}

	if($use){
		($account_path) = Mebius::Auth::account_path($use,$account);
	}
	else{
		($account_path) = Mebius::Auth::account_path($account);
	}

	if($account_path->{'root_directory'}){
		return($account_path->{'root_directory'});
	}
	else{
		die("Perl Die! Can't decide account directory.");
	}



}


#-------------------------------------------------
# �A�J�E���g��{�t�@�C�����J��
#-------------------------------------------------
sub File{

# �錾
my($type,$file,%other_account) = @_;
my($select_renew);
my(undef,undef,$password) = @_ if($type =~ /Get-my-account/);
my(undef,undef,%select_renew) = @_ if($type =~ /Renew/ && ref $_[2] eq ""); # �C�ӂ̍X�V�l���A�n�b�V���̃��t�@�����X�ł��󂯎���悤�� 
$select_renew = \%select_renew if($type =~ /Renew/ && ref $_[2] eq ""); # ��
(undef,undef,$select_renew) = @_ if($type =~ /Renew/ && ref $_[2] eq "HASH");	# ��
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account() if($type !~ /Get-my-account|Block-rooping/); # ���������[�v�ɒ��ӁI�I
my($nowdate) = Mebius::now_date_multi();
my($FILE1,%account,$error_text);
my($renewline,$profile_handler,$profile_file,$accountfile,$renewline_profile,$mylink,@multi_salt,@renew_line,%self_renew,%data_format,$renew,$move_from_file);

# �t�@�C����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){
		Mebius::AccessLog(undef,"Cant-decide-account-directory","\@_ : @_");
		die("Perl Die! Account directory setting is empty. @_ ");
	} else {
			# ���ݓ����p
			if($type =~ /Old-server-file/){
				$account_directory =~ s!/_account/!/_account_move_from/!g;
			} elsif($type =~ /Move-from-file/){
				$account_directory =~ s!/_account/!/_account_move_from2/!g;
			}
		$account{'directory_path'} = $account_directory;
		$accountfile = $account{'file_path'} = "${account_directory}$file.cgi";
	}


	# �}�C���r�ꗗ�t�@�C�������Ă���ꍇ�ȂǂɑΉ�
	if($file eq "" && $type =~ /Not-file-check/){ return(); }

	# �A�J�E���g���̃`�F�b�N
	# return �ł͂Ȃ��ċ��炭 error ���������͂� ( �����̃f�[�^���J���ꍇ�́A����ȑO�̏����� return ���Ă��� )
	my($account_name_error) = Mebius::Auth::AccountName(undef,$file);
		if($account_name_error){
			Mebius::AccessLog(undef,"Account-name-error","$account_name_error");
			main::error($account_name_error);
	}
	if(Mebius::FileNamePolution([$file])){ main::error("�t�@�C�����̎w�肪�ςł��B"); }

	# �d���쐬���֎~����ꍇ # �K�� open �ł͂Ȃ��t�@�C���`�F�b�N���邱��
	if($type =~ /New-account/ && -f $accountfile){
		main::error("���̃A�J�E���g�͊��ɑ��݂��܂��B");
	}

# �A�J�E���g�t�@�C�����J��
	if($type =~ /File-check-error/){

		$account{'f'} = open($FILE1,"+<",$accountfile) || main::error("�t�@�C�������݂��܂���B");
	} else{

		# �t�@�C�����J��
		$account{'f'} = open($FILE1,"+<",$accountfile);

			# ���t�@�C�������݂��Ȃ��ꍇ
			if(!$account{'f'}){

					# �t�@�C�������݂��Ȃ��Ă��G���[���o���Ȃ��ꍇ ( �����������Ƀ��^�[������ )
					if($type =~ /Not-file-check|File-check-return/){
						close($FILE1);
						return(%account);
					}

					# �t�@�C����V�K�쐬����ꍇ
					elsif($type =~ /Renew/){
							# �d�v�F ���݂��Ȃ��t�@�C���́A�ʏ�͍쐬�ł��Ȃ��悤�ɂ��Ă���
							# �u�A�J�E���g�̐V�K�쐬�v�u�Ǘ��҂ɂ�鋭���쐬�v�̂Ƃ��������s����
							if($type =~ /New-account|Admin-renew/){
								#Mebius::Mkdir(undef,$account{'directory1'});
								Mebius::Fileout("Allow-empty",$accountfile);
								$account{'new_file_flag'} = 1;
								$account{'f'} = open($FILE1,"+<",$accountfile);
							}
							else{
								main::error("���̃A�J�E���g $file �͑��݂��܂���B");
							}
					}

					# ���̑��̏ꍇ�́h�K���h�G���[���o��
					else{
						main::error("���̃A�J�E���g $file �͑��݂��܂���B");

					}

			}

	}

	# �t�@�C�����b�N ( �d�v�I Flock2 ���Ȃ��ƃt�@�C���S�����̋��ꂠ��I )
	# Option �w��ł��t�@�C���X�V�̂��߁A�ꎞ�I�� flock2 ����
	if($type =~ /Renew|Get-my-account|Flock2|Option/){ flock($FILE1,2); $account{'flock2_flag'} = 1; } else { flock($FILE1,1); $account{'flock1_flag'} = 1; }

# �f�[�^�\�����`
$data_format{'1'} = [('key','account','pass','salt','firsttime','blocktime','lasttime','adlasttime','concept','pass_crypt','salt_crypt')];
$data_format{'2'} = [('name','mtrip','color1','color2','prof','edittime','last_profile_edit_time','comment_font_color')];
$data_format{'3'} = [('ocomment','odiary','obbs','osdiary','osbbs','orireki','ohistory','okr','allow_vote','allow_message','allow_view_last_access','allow_crap_diary','use_bbs')];
$data_format{'4'} = [('encid','enctrip')];
$data_format{'5'} = [('level','level2','surl','admin','chat','reason','last_locked_period','all_locked_period','alert_end_time','alert_count','alert_decide_time')];
$data_format{'6'} = [('email','mlpass','myurl','myurltitle','remain_email')];
$data_format{'7'} = [('birthday_concept','birthday_year','birthday_month','birthday_day','birthday_time')];
$data_format{'8'} = [('none','all_renew_count','account_locked_count')];
$data_format{'9'} = [('catch_mail_message','catch_mail_resdiary','catch_mail_comment','catch_mail_etc')];
$data_format{'10'} = [('first_email','first_host','first_agent')];
$data_format{'11'} = [('set_cookie_count','cookie_name','cookie_refresh_second','cookie_font_color','cookie_thread_up','cookie_gold','cookie_regist_all_length','cookie_regist_count','cookie_font_size','cookie_follow','cookie_last_view_thread','cookie_use_history','cookie_omit_text','cookie_bbs_news','cookie_age','cookie_email','cookie_secret','cookie_account_link','cookie_id_fillter','cookie_account_fillter','cookie_use_id_history')];
$data_format{'12'} = [('optionkey','last_action_time','addr','agent','cnumber')];
$data_format{'13'} = [('todaypresentgold','lastpresentgold')];
$data_format{'14'} = [('votepoint','todayvotepoint','lastvote')];
$data_format{'15'} = [('last_send_message_yearmonthday','today_send_message_num','unread_message_num')];
$data_format{'16'} = [('deny_count','denied_count','friend_num')];
$data_format{'17'} = [('last_access_time','last_access_addr','last_access_multi_user_agent','last_access_cookie_char')];
$data_format{'18'} = [('last_apply_friend_time','last_comment_time')];
$data_format{'19'} = [('next_diary_post_time','next_comment_time')];
$data_format{'20'} = [('penalty_time')];
$data_format{'21'} = [('char')];
$data_format{'22'} = [('option_to_account_time')];
$data_format{'23'} = [('new_applied_num','last_applied_time')];
$data_format{'24'} = [('cookie_gold_old_server','cookie_regist_all_length_old_server','cookie_regist_count_old_server','cookie_gold_save_original','cookie_regist_all_length_save_original','cookie_regist_count_save_original')];
$data_format{'25'} = [('question_last_post_time','quesiton_last_post_time','question_last_response_time')];
$data_format{'26'} = [('friend_accounts','deny_accounts')];

	# �g�b�v�f�[�^��ǂݍ���
	my($split_data) = Mebius::file_handle_to_hash(\%data_format,$FILE1);
	%account = (%account,%$split_data);

	# ���O�����Ă���ꍇ
	if($account{'account'} eq "" && !$account{'new_file_flag'}){ $account{'broken_flag'} = 1; }

	# �I�v�V�����t�@�C�����擾���ăn�b�V���ɒǉ�
	#if($type =~ /Option/){
		#(%option) = &Optionfile("",$file);
		#%account = (%account,%option);
	#}

	# ���I�v�V�����t�@�C���̒l���A���C���t�@�C���ɕ��� (�ꎞ�I�ȏ���)
	# �� 2012/2/29 (��)
	if($type =~ /Option/ && !$account{'option_to_account_time'} && $account{'first_time'} < 1355471111 - (9*30*24*60*60)){
		my(%option) = &Optionfile("",$file);
			if($option{'f'}){ %account = (%account,%option); }
		$self_renew{'option_to_account_time'} = time;
		$type .= qq( Renew); # �t�@�C�������ɒ��ӁI ���Ȃ炸����ȑO�� flock2 ���邱�ƁI
			Mebius::AccessLog(undef,"Option-file-to-account-file","�A�J�E���g : $file");
	}

	# �}�C���r��Ԃ̃`�F�b�N�������Ȃ��ꍇ
	if($type =~ /Get-friend-status/ && %other_account){
			($account{'friend_status_to'}) = Mebius::Auth::FriendStatus(undef,$file,$other_account{'file'});
			($account{'friend_status_from'}) = Mebius::Auth::FriendStatus(undef,$other_account{'file'},$file);
	}

	# �L�[�`�F�b�N
	if($type =~ /Key-check-error/ && $account{'key'} !~ /^(1|2)$/){
		close($FILE1);
		main::error("���̃A�J�E���g ( $file ) �͗��p����Ă��܂���B");
	}

	# �M���A�v���t���Ȃ��ꍇ
	if($account{'name'} eq "" || $account{'name'} eq "������"){
		$account{'birdflag'} = 1;
		$account{'name'} = "������";
	}
	# �����l�ɂ������
	$account{'handle'} = $account{'name'};

	# ��URL�E�����N
	$account{'name_link'} = qq(<a href="$basic_init->{'auth_url'}$file/">$account{'name'} - $file</a>);
	$account{'profile_url'} = "$basic_init->{'auth_url'}$file/";

	# ���n�b�V���̒���
	# ���ɂ����X�V����Ă���ꍇ�A���[�|�C���g�𖞃^���ɂ���
	if($account{'lastvote'} ne $nowdate->{'ymdf'}){
			if(Mebius::alocal_judge()){ $account{'todayvotepoint'} = 10; }
			else{ $account{'todayvotepoint'} = 3; }
	}

	# ���ɂ����X�V����Ă���ꍇ�A�����̃��b�Z�[�W�̑��M�񐔂����Z�b�g����
	if($account{'last_send_message_yearmonthday'} ne $nowdate->{'ymdf'}){
		$account{'today_send_message_num'} = 0;
	}

	# ���ꑗ�M�҃`�F�b�N
	if($account{'agent'} && $account{'agent'} eq $main::agent && $main::k_access){ $account{'sameaccess_flag'} = 1; }
	if($account{'addr'} && $account{'addr'} eq $main::addr && !$main::k_access){ $account{'sameaccess_flag'} = 1; }
	if($account{'cnumber'} && $account{'cnumber'} eq $main::cnumber){ $account{'sameaccess_flag'} = 1; }

	# �}�C���r�̍ő�o�^��
	if($account{'level2'} >= 1){ $account{'max_friend'} = 200; } else { $account{'max_friend'} = 100; }
	if($account{'friend_num'} >= $account{'max_friend'}){
		$account{'max_friend_flag'} = qq($account{'name_link'}����̃}�C���r�́A���ɍő吔�ɒB���Ă��܂��B ( $account{'friend_num'} �l / $account{'max_friend'}�l ) );
	}

	# �� ��A�̏���
	{
			# �A�J�E���g�ւ̌x�� ( A )
			if($account{'key'} eq "1" && $account{'reason'} && time < $account{'alert_end_time'}){
					if(time > $account{'alert_decide_time'} + 24*60*60){
						$account{'alert_flag'} = 1;
						$account{'allow_next_alert_flag'} = 1;
					} else {
						$account{'alert_flag'} = 1;
					}
			} else {
				$account{'allow_next_alert_flag'} = 1;
			}

			# �A�J�E���g���b�N�̉����� ( B )
			if($account{'key'} eq "2" && $account{'blocktime'} && time >$account{'blocktime'}){ $account{'key'} = 1; }

			# �������߂��������� ( C )
			if($account{'key'} eq "1" && !$account{'alert_flag'}){
					if($account{'firsttime'}){
						$account{'justy_days'} = int( (time - $account{'firsttime'}) / (24*60*60) );
					} else {
						$account{'justy_days'} = 365; # �K�v�ȃf�[�^���Ȃ��ꍇ�A�֋X�I�ɂP�N������
					}
			}

			# ���b�N��Ԃ̃`�F�b�N ( C )
			if($type =~ /Lock-check-error/ && $account{'key'} eq "2"){
				$account{'error_message'} .= qq(���̃A�J�E���g ( $file ) �̓��b�N���ł��B);
					if(!$main::myadmin_flag){
						close($FILE1);
						main::error($account{'error_message'});
					}
			}

	}

	# �A�J�E���g�� ( ���O�C�����s�̏ꍇ�́A���ƂŃn�b�V����n�������^�[������̂Ŗ��Ȃ� )
	$account{'file'} = $account{'id'} = $file;

	# �A�J�E���g��o�^���Ă���̌������v�Z
	if($account{'firsttime'}){ $account{'past_month'} = int((time - $account{'firsttime'}) / (30.43*24*60*60)); }
	else{ $account{'past_month'} = 100; }


	# �N��
	if($account{'birthday_time'}){
		$account{'age'} = int((time - $account{'birthday_time'}) / (365.24*24*60*60));
	}

	# ���b�Z�[�W�̍ő呗�M�\��
	if($account{'key'} eq "1"){
		$account{'maxsend_message'} = int($account{'past_month'} - 11);
		#$account{'maxsend_message'} += int($option{'friend_num'}/3);
		#	if($option{'denied_count'} >= 1){ $account{'maxsend_message'} -= $option{'denied_count'}; }
		$account{'maxsend_message'} += int($account{'friend_num'}/3);
			if($account{'denied_count'} >= 1){ $account{'maxsend_message'} -= $account{'denied_count'}; }

			if($account{'maxsend_message'} >= 100){ $account{'maxsend_message'} = 100; }
			if($account{'maxsend_message'} < 0){ $account{'maxsend_message'} = 0; }
			if($account{'admin'} >= 1){ $account{'maxsend_message'} += 100; }
		$account{'today_left_message_num'} = $account{'maxsend_message'} - $account{'today_send_message_num'};
	}

	# ���[�����p�\�t���O
	#if($account{'maxsend_message'} >= 1 && ($account{'past_month'} >= 6 && $option{'friend_num'} >= 3)){
	if($account{'maxsend_message'} >= 1 && ($account{'past_month'} >= 6 && $account{'friend_num'} >= 3)){
		$account{'allow_message_status'} = 1;
			# �����ŗ��p�֎~/�������p�֎~����Ă���ꍇ�ȊO�́A�{���Ƀ��b�Z�[�W�t�H�[�����g����悤��
			if($account{'allow_message'} !~ /^(Deny-use|Not-use)$/){ $account{'allow_message_flag'} = 1; }
	}

	# �����
	if($account{'allow_crap_diary'} ne "Deny"){ $account{'allow_crap_diary_flag'} = 1; }

	# ���b�Z�[�W���������p�\�t���O
	#if($account{'key'} eq "1" && ($account{'past_month'} >= 3*12 || $account{'admin'} >= 1)){
	#	$account{'all_allow_message_flag'} = 1;
	#}


	# �Ǘ��҂͑S�@�\���g����悤��
	#if($account{'admin'}){ $account{'allow_message_flag'} = 1; }

	# �a����
	if($account{'birthday_year'} || $account{'birthday_month'} || $account{'birthday_day'}){
			if($account{'birthday_year'}){ $account{'birthday'} .= qq($account{'birthday_year'}�N); }
			if($account{'birthday_month'}){ $account{'birthday'} .= qq($account{'birthday_month'}��); }
			if($account{'birthday_day'}){ $account{'birthday'} .= qq($account{'birthday_day'}��); }
			if($account{'age'}){ $account{'birthday'} .= qq( ( ��$account{'age'}�� )); }
	}

	# �L�[����
	if($account{'key'} eq "1"){
		$account{'justy_flag'} = 1;
	}

	# �� �����̃f�[�^���擾����ꍇ ( �p�X���[�h�ƍ� )
	if($type =~ /Get-my-account/){

		# �Ǐ���
		my($gethost);
		my($my_access) = Mebius::my_access();
		my($my_cookie) = Mebius::my_cookie_main();

		# ���O�C�����s�������擾
		my($login) = Mebius::Login::TryFile("Get-hash Auth-file By-cookie",$main::xip);

			# ( �����̎��s�񐔂������ꍇ�́A���O�C������ ( �p�X���[�h�ƍ� ) ���̂������Ȃ킸�Ƀ��^�[��
			if($login->{'error_flag'}){
				Mebius::AccessLog(undef,"Login-missed-cookie-many","���O�C�����s�̉�(�S����)�F $login->{'all_missed_count'}��");
				close($FILE1);
				return();
			}

			# �L�[���Ȃ��ꍇ
			if($account{'key'} ne "1" && $account{'key'} ne "2"){
					close($FILE1);
					return();
			}

			# �p�X���[�h���� 
			# ���d�v�I���s�񐔂��L�^���ă��^�[������ ( ������ return ���Ȃ��ƁA�p�X���[�h���Ԉ���Ă��Ă����O�C���o���Ă��܂� )
			# LoginTry �t�@�C���� id & pass �̏d���`�F�b�N���s�Ȃ��Ă���̂ŁA set_cookie ���ă��O�A�E�g������K�v�͂Ȃ�
			if($account{'pass'} ne $password || $password eq "" || $account{'pass'} eq ""){
				Mebius::Login::TryFile("Renew Login-missed Auth-file By-cookie",$main::xip,$file,$password);
				close($FILE1);
				return();
			}

			# �A�J�E���g�� / �n�b�V�������ꂽ�p�X���[�h�̏ƍ������������ꍇ ( �O�̂��߂���ɏ�������ň͂��Ă��� )
			# => �d�v�ȏ����Ȃ̂ŁA��̃p�X���[�h���肩�� else �ŏ������򂳂����肹���A������ł���d�ɏ�������������Ȃ�
			if($account{'pass'} eq $password && $password && $account{'pass'}){

				# �������`
				$account{'idcheck'} = 1;
				$account{'login_flag'} = 1;

				# �O���[�o���ϐ���ݒ�
				$main::idcheck = 1;
				$main::pmfile = $file;
				#$main::pmkey = $account{'key'};
				$main::pmname = $account{'name'};

					if($account{'birdflag'}){ $main::birdflag  = qq(<a href="$basic_init->{'auth_url'}$file/edit#EDIT">���Ȃ��̕M����ݒ�</a>���Ă��������B); }

					# �Ǘ��҂̏ꍇ�A�z�X�g�����`�F�b�N����
					if($account{'admin'}){

						($gethost) = Mebius::get_host_state();
							if(length($gethost) >= 5 && !Mebius::Switch::sns_admin_off()){ $account{'admin_flag'} = $account{'admin'}; }

					}

					# �Ǘ��������Q�ȏ�̏ꍇ�A���ϐ��𔻒肷��
					if($account{'admin'} >= 2 && !Mebius::alocal_judge()){

						my($allow_flag);
							foreach(@main::master_hosts){
									if($gethost =~ /$_$/){ $allow_flag = 1; }
							}
							if($allow_flag){ $account{'master_flag'} = 1; }
							else{ $account{'admin_flag'} = 0; }
					}


				# ��SNS����URL�ւ̃A�N�Z�X�̏ꍇ�A���O�C���������X�V
					my($REQUEST_URL) = Mebius::request_url();
					if(time > $account{'last_access_time'}+(10*60)){
					# && ($REQUEST_URL =~ m!^$basic_init->{'auth_url'}! || $ENV{'SCRIPT_NAME'} =~ m!/ff\.cgi$!)

						#my(%option) = Mebius::Auth::Optionfile("Renew Renew-access-time",$account{'file'});
						$type .= qq( Renew); # ����ȑO�̏����� Flock ���Ă���
						$self_renew{'last_access_time'} = time;

							# ���e�����t�@�C���̃f�[�^���X�V
							#if(rand(100) < 1){ Mebius::HistoryAll("RENEW My-file"); }

					}

					# ����莞�Ԃ��ƂɃ��O�C���̏ڍ׃t�@�C�����X�V
					{
	
						my($renew_login_flag);

							if($my_access->{'mobile_id'}){
									if($my_access->{'multi_user_agent_escaped'} ne $account{'last_access_multi_user_agent'}){
										$renew_login_flag = 1;
									}
							}
							else{
									if($ENV{'REMOTE_ADDR'} ne $account{'last_access_addr'}){
										$renew_login_flag = 1;
									}
							}

							if($my_cookie->{'char_escaped'} && $my_cookie->{'char_escaped'} ne $account{'last_access_cookie_char'}){ $renew_login_flag = 1; }

							if($renew_login_flag){
								
								Mebius::Login->login_history("Renew",$account{'file'});
								$self_renew{'last_access_addr'} = $ENV{'REMOTE_ADDR'};
								$self_renew{'last_access_multi_user_agent'} = $my_access->{'multi_user_agent_escaped'};
								$self_renew{'last_access_cookie_char'} = $my_cookie->{'char_escaped'};
								$type .= qq( Renew);


							}
					}

					# URL�̈����ɂ���ẮA�Ǘ��Ҍ������Ȃ���
					if($main::in{'admin'} eq "0"){ $account{'admin_flag'} = 0; }

				# �O���[�o���ϐ��ɑ��
				$main::myadmin_flag = $account{'admin_flag'};

			}

	}

	# CCC 2010/11/28
	# �I�v�V�����t�@�C���Ƀ}�C���r���������ꍇ�A�I�v�V�����t�@�C�����X�V
	#if($option{'friend_num'} eq "" && $type =~ /Option/){
	#	my(%renew_option);
	#	my(%friend_index) = Mebius::Auth::FriendIndex("Get-hash",$account{'file'});
	#	$renew_option{'friend_num'} = $friend_index{'friend_num'};
	#		if($renew_option{'friend_num'} eq ""){ $renew_option{'friend_num'} = 0; }
	#	Mebius::Auth::Optionfile("Renew",$account{'file'},%renew_option);
	#	Mebius::AccessLog(undef,"Auth-friend-num-fixed");
	#}

	# ���v���t�B�[�����e���擾
	#if($account{'prof'} eq "" && $account{'lasttime'} <= 1329443400){
	#	my $profile_file = "${account_directory}${file}_prof.cgi";
	#	Mebius::AccessLog(undef,"Open-profile-file","$file");
	#	open($profile_handler,"<",$profile_file);
	#	chomp(my $top_profile = <$profile_handler>);
	#	($account{'prof'}) = split(/<>/,$top_profile);
	#	close($profile_handler);
	#}

	# �L�[�`�F�b�N
	if($type =~ /(Not-keycheck|Not-file-check|Get-my-account)/){}
	else{
			if($account{'key'} eq "0"){
					if($main::myadmin_flag){ $error_text = qq(���̃A�J�E���g�͍폜�ς݂ł��B); }
					else{
						close($FILE1);
						main::error("���̃A�J�E���g�͍폜�ς݂ł��B","410 Gone");
					}
			}
			if($account{'key'} eq "2"){
					if($type =~ /Lock-check/ && !$main::myadmin_flag){
						close($FILE1);
						main::error("���̃A�J�E���g�̓��b�N���ł��B");
					}
			}
	}

	# �ҏW�������`
	if($other_account{'file'} eq $file || $my_account->{'id'} eq $file){ $account{'myprof_flag'} = 1; }
	if($main::myadmin_flag || $account{'myprof_flag'}){ $account{'editor_flag'} = 1; }

	# �����A�h�z�M�ݒ�̏ꍇ
	if($account{'email'} ne "" && $account{'mlpass'} ne ""){ $account{'sendmail_flag'} = 1; }

	# �����̎g�p���
	if($account{'orireki'} eq "0" && $account{'ohistory'} =~ /^use-close$/ && !$main::myadmin_flag){ }
	elsif($account{'birdflag'}){ }
	else{ $account{'rireki_flag'} = 1; }

	# �����܂��֘A�̎g�p���
	if($account{'okr'} =~ /^not-use$/){ } else { $account{'kr_flag'} = 1; }

	# �������߂t�q�k�̐��`
	if($account{'myurl'} && $account{'myurl'} =~ m!^http://([a-zA-Z0-9\.]+)/!){
		if($account{'myurltitle'}){ $mylink = qq(<a href="$account{'myurl'}">$account{'myurltitle'}</a>); }
		else{ $mylink = qq(<a href="$account{'myurl'}" title="$account{'myurl'}">URL</a>); }
	}

	# �ŏI�ҏW����̎����ŁA���u��Ԃ𔻒肷�� ( �U���ȍ~����n�������� )
	#if($type =~ /Option/ && $main::time > $option{'last_action_time'} + 90*24*60*60){
	#	my $sleep_days = int( ($main::time - $option{'last_action_time'}) / (24*60*60) );
	#	if($sleep_days >= 14000){ $sleep_days = qq(??); }
	#	$account{'let_flag'} = qq(���̃A�J�E���g�͋x�����ł� ($sleep_days��) �B$account{'name_link'}���񂪊������n�߂�Ή�������܂��B);
	#}

	# �ŏI�ҏW����̎����ŁA���u��Ԃ𔻒肷��
	if(time > $account{'last_action_time'} + 90*24*60*60){
		my $sleep_days = int( (time - $account{'last_action_time'}) / (24*60*60) );
		if($sleep_days >= 14000){ $sleep_days = qq(??); }
		$account{'let_flag'} = qq(���̃A�J�E���g�͋x�����ł� ($sleep_days��) �B$account{'name_link'}���񂪊������n�߂�Ή�������܂��B);
	}

	# �����܂��֘A�̎擾
	#if($account{'kr_flag'}){
	#	require "${main::int_dir}part_kr.pl";
	#	($account{'kr_oneline'},$account{'kr_flow_flag'}) = main::kr_thread("Oneline Account",$file,undef,5);
	#}

	# �֘A�L��������ꍇ
	#if($account{'kr_oneline'}){
	#	my $kr_nextlink;
	#		if($account{'editor_flag'}){ $kr_nextlink = qq( (<a href="./kr-view">���ҏW</a>)); }
	#		if($account{'kr_flow_flag'}){ $kr_nextlink = qq( (<a href="./kr-view">������</a>)); }
	#	$account{'kr_oneline'} = qq(<div class="account_kr"$main::kfontsize_small>�֘A�����N ( �f���� )�F $account{'kr_oneline'} $kr_nextlink</div>);
	#	$main::css_text .= qq(div.account_kr{margin:2.0em 0em 1em 0em;font-size:90%;padding:0.5em 1.0em;background:#dee;word-spacing:0.25em;line-height:1.6;});
	#}

	# ���A�J�E���g�ҏW����ꍇ
	if($type =~ /Renew/){

			# �X�V������e�i�����̃A�J�E���g�̏ꍇ�j
			if($account{'myprof_flag'}){
				($self_renew{'encid'}) = main::id();
				$self_renew{'lasttime'} = time;
				$self_renew{'addr'} = $main::addr;
				$self_renew{'agent'} = $main::agent;
				$self_renew{'cnumber'} = $main::cnumber;
				$self_renew{'last_action_time'} = time;
					if($type =~ /Option/ && $type !~ /Get-my-account/){	$self_renew{'last_action_time'} = time; }
			}

			# �󔒒l�Ȃǂ�⊮
			if($account{'char'} eq ""){ $self_renew{'char'} = Mebius::Crypt::char(undef,30); }

		# �S�X�V�񐔂𑝉�
		$self_renew{'+'}{'all_renew_count'} = 1;
		$self_renew{'account'} = $file;

		# �C�ӂ̍X�V�ƃ��t�@�����X��
		($renew) = Mebius::Hash::control(\%account,$select_renew,\%self_renew);

			# �f�[�^�t�H�[�}�b�g����t�@�C���X�V
			if(!$account{'broken_flag'}){
				Mebius::File::data_format_to_truncate_print(\%data_format,$FILE1,$renew);
			}

		my $renew_utf8 = Mebius::Encoding::hash_to_utf8($renew);
		$renew_utf8->{'account'} = $file;
		Mebius::SNS::Account->update_or_insert_main_table($renew_utf8);

	}

close($FILE1);

	# �p�[�~�b�V�����ύX
	if($type =~ /Renew/ && !$account{'broken_flag'}){ Mebius::Chmod(undef,$accountfile); }

	# ���Ă���ꍇ�̓f�[�^�𕜊�
	if($account{'broken_flag'}){
		#Mebius::return_backup($accountfile);
	}
	# �o�b�N�A�b�v�����
	#elsif($type =~ /Renew/ && !$account{'broken_flag'} && rand(10) < 1){ Mebius::make_backup($accountfile); }


	# �����t�@������A�A�J�E���g�̊֘A�L����o�^����
	#if($type =~ /Kr-submit/ && $main::referer && !$account{'myprof_flag'}){
	#		if(rand(1) < 1 || $main::alocal_mode){
	#			my($referer_type,$referer_domain,$referer_moto,$referer_number) = Mebius::Referer("Type",$main::referer);
	#				if($referer_type =~ /bbs-thread/){
	#					require "${main::int_dir}part_kr.pl";
	#					main::kr_thread("Renew Account",$file,undef,$referer_domain,$referer_moto,$referer_number);
	#				}
	#		}
	#}

	# ���^�[��
	if($type =~ /Renew/ && %$renew){
			if($type =~ /ReturnRef/){
				return(\%$renew);
			} else{
				return(%$renew);
			}
	}
	else{
			if($type =~ /ReturnRef/){
				return(\%account);
			} else{
				return(%account);
			}

	}

}

#-----------------------------------------------------------
# �I�v�V���� �E�A�J�E���g�t�@�C��
#-----------------------------------------------------------
sub Optionfile{

# �錾
my($nowdate) = Mebius::now_date_multi();
my($type,$file,%renew) = @_;
my($optionfile,$renew_line,%self,$FILE1);

# �A�J�E���g������
if(Mebius::Auth::AccountName(undef,$file)){ return(); }

# �t�@�C����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

$self{'file1'} = "${account_directory}${file}_option.log";

	# �t�@�C�����J��
	if($type =~ /File-check-error/){
		$self{'f'} = open($FILE1,"+<$self{'file1'}") || main::error("�t�@�C�������݂��܂���B");
	}
	else{

		$self{'f'} = open($FILE1,"+<$self{'file1'}");

			# �t�@�C�������݂��Ȃ��ꍇ
			if(!$self{'f'}){
					# �V�K�쐬
					if($type =~ /Renew/){
						#Mebius::Mkdir(undef,$self{'directory1'});
						Mebius::Fileout("Allow-empty",$self{'file1'});
						$self{'f'} = open($FILE1,"+<$self{'file1'}");
					}
					else{
						return(\%self);
					}
			}

	}

	# �t�@�C�����b�N
	if($type =~ /Renew|Flock/){ flock($FILE1,2); }

	# �g�b�v�f�[�^��W�J
	for(1..10){
		chomp($self{"top$_"} = <$FILE1>);
	}

# �f�[�^�𕪉�
# ��{�f�[�^
($self{'optionkey'},$self{'last_action_time'},$self{'addr'},$self{'agent'},$self{'cnumber'}) = split (/<>/,$self{'top1'});
# ����
($self{'todaypresentgold'},$self{'lastpresentgold'}) = split (/<>/,$self{'top2'});
# �L
($self{'votepoint'},$self{'todayvotepoint'},$self{'lastvote'}) = split (/<>/,$self{'top3'});
# �����Z�[�W
($self{'last_send_message_yearmonthday'},$self{'today_send_message_num'}) = split (/<>/,$self{'top4'});
# �}�C���r�Ȃ�
($self{'deny_count'},$self{'denied_count'},$self{'friend_num'}) = split (/<>/,$self{'top5'});
# �����X�V�̃��O�C������
($self{'last_access_time'},$self{'last_access_ymdf'},$self{'use_day'},$self{'last_access_yearmonth'},$self{'use_month'}) = split (/<>/,$self{'top6'});
# �e��L�^����
($self{'last_apply_friend_time'},$self{'last_comment_time'}) = split (/<>/,$self{'top7'});
# ���e���Ԍn
($self{'next_diary_post_time'},$self{'next_comment_time'}) = split (/<>/,$self{'top8'});
# �y�i���e�B�n
($self{'penalty_time'}) = split (/<>/,$self{'top9'});
# Char�n
($self{'char'}) = split (/<>/,$self{'top10'});

	# ���ŏI�A�N�Z�X�������X�V����ꍇ
	if($type =~ /Renew-access-time/){
			# �O��̋L�^����莞�Ԉȓ��̏ꍇ�́A���^�[��
			if(time < $self{'last_access_time'} + (10*60)){
				close($FILE1);
				return();
			}
			# �ŏI�A�N�Z�X�������X�V����ꍇ
			else{ $self{'last_access_time'} = time; }
	}

	# ���n�b�V���̒���

	# ���̐��`
	if($self{'denied_count'} < 0){ $self{'denied_count'} = 0; }

	# ���ɂ����X�V����Ă���ꍇ�A���[�|�C���g�𖞃^���ɂ���
	if($self{'lastvote'} ne $nowdate->{'ymdf'}){
			if(Mebius::alocal_judge()){ $self{'todayvotepoint'} = 10; }
			else{ $self{'todayvotepoint'} = 3; }
	}

	# ���ɂ����X�V����Ă���ꍇ�A�����̃��b�Z�[�W�̑��M�񐔂����Z�b�g����
	if($self{'last_send_message_yearmonthday'} ne $nowdate->{'ymdf'}){
		$self{'today_send_message_num'} = 0;
	}

	# ���ꑗ�M�҃`�F�b�N
	if($self{'agent'} && $self{'agent'} eq $main::agent && $main::k_access){ $self{'sameaccess_flag'} = 1; }
	if($self{'addr'} && $self{'addr'} eq $main::addr && !$main::k_access){ $self{'sameaccess_flag'} = 1; }
	if($self{'cnumber'} && $self{'cnumber'} eq $main::cnumber){ $self{'sameaccess_flag'} = 1; }

	# ���t�@�C�����X�V����ꍇ
	if($type =~ /Renew/){

			# ���p���l�ɉ����ăf�[�^���X�V����
			foreach(keys %renew){
					if(defined($renew{$_})){ $self{$_} = $renew{$_}; }
					if($_ =~ /^plus->(\w+)$/){ $self{$1} += $renew{$_}; }
			}

			# �����ł���΍ŏI�s�������Ȃǂ��X�V
			if($file eq $main::pmfile){
				$self{'last_action_time'} = time;
				$self{'addr'} = $main::addr;
				$self{'agent'} = $main::agent;
				$self{'cnumber'} = $main::cnumber;
			}

			# �󔒒l�Ȃǂ�⊮
			if($self{'char'} eq ""){ $self{'char'} = Mebius::Crypt::char(undef,20); }

		# �X�V�s���`
		$renew_line .= qq($self{'optionkey'}<>$self{'last_action_time'}<>$self{'addr'}<>$self{'agent'}<>$self{'cnumber'}<>\n);
		$renew_line .= qq($self{'todaypresentgold'}<>$self{'lastpresentgold'}<>\n);
		$renew_line .= qq($self{'votepoint'}<>$self{'todayvotepoint'}<>$self{'lastvote'}<>\n);
		$renew_line .= qq($self{'last_send_message_yearmonthday'}<>$self{'today_send_message_num'}<>\n);
		$renew_line .= qq($self{'deny_count'}<>$self{'denied_count'}<>$self{'friend_num'}<>\n);
		$renew_line .= qq($self{'last_access_time'}<>$self{'last_access_ymdf'}<>$self{'use_day'}<>$self{'last_access_yearmonth'}<>$self{'use_month'}<>\n);
		$renew_line .= qq($self{'last_apply_friend_time'}<>$self{'last_comment_time'}<>$self{'last_getnews_time'}<>\n);
		$renew_line .= qq($self{'next_diary_post_time'}<>$self{'next_comment_time'}<>\n);
		$renew_line .= qq($self{'penalty_time'}<>\n);
		$renew_line .= qq($self{'char'}<>\n);

		# �X�V�t���O�𗧂Ă�
		$self{'renewed_flag'} = 1;

		# �t�@�C���X�V
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 $renew_line;

	}

close($FILE1);

	# �p�[�~�b�V�����ύX
	if($type =~ /Renew/){
		Mebius::Chmod(undef,$self{'file1'});
	}



return(%self);

}



#-----------------------------------------------------------
# SNS�Ǝ��̍s������
#-----------------------------------------------------------
sub History{

# �錾
my($type,$file) = @_;
my(undef,undef,$tofile,$newcomment) = @_ if($type =~ /Renew/);
my($history_handler,$logfile,@renewline,$index_line,$i,$maxrenew);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ return(); }
$logfile = "${account_directory}${file}_history_auth.log";

	# ����A�J�E���g�̒�`
	if($type =~ /Renew/){
		$tofile =~ s/[^0-9a-z]//g;
			if($tofile eq ""){ return(); }
	}

# �ő�X�V�s��
$maxrenew = 100;

# �t�@�C�����J��
open($history_handler,"<$logfile");
if($type =~ /Renew/){ flock($history_handler,1); }

	# �t�@�C����W�J����
	while(<$history_handler>){

		# ���E���h�J�E���^
		$i++;

		# ���̍s�𕪉�
		chomp;
		my($key2,$type2,$comment2,$account2,$lasttime2,$date2) = split(/<>/);

				# ���C���f�b�N�X�擾�p�̏���
				if($type =~ /Index/){
					my(%account) = Mebius::Auth::File("Not-file-check",$account2);
					$index_line .= qq(<div>);
					$index_line .= qq(<a href="$main::auth_url$account2/">$account{'name'} - $account2</a> $comment2);
					$index_line .= qq(</div>);
				}

				# ���t�@�C���X�V�p�̏���
				if($type =~ /Renew/){
			
					# �ő�s���z�����ꍇ
					if($i > $maxrenew){ next; }

					# �X�V�s��ǉ�
					push(@renewline,"$key2<>$type2<>$comment2<>$account2<>$lasttime2<>$date2<>\n");

				}

	}

close($history_handler);

	# �t�@�C���X�V�̌㏈��
	if($type =~ /Renew/){

		# �V�����s��ǉ�
		unshift(@renewline,"1<><>$newcomment<>$tofile<>$main::time<>$main::date<>\n");
	
		# �t�@�C���X�V
		Mebius::Fileout("",$logfile,@renewline);
	}

	# �C���f�b�N�X�擾�̌㏈��
	elsif($type =~ /Index/){
		return($index_line);

	}


}


#-----------------------------------------------------------
# �V���R�����g���擾
#-----------------------------------------------------------
sub News{

# �錾
my($type,$file,$maxview) = @_;
my(undef,undef,$myfile,$new_handle,$newcomment,$newcommenthidden) = @_ if($type =~ /Renew/);
my($line,$i,$newcomment_handle,$index_line,$flow_flag,$h3,$logfile,@renewline,$i_comment,$log_type,%log_type,$hit_topics);
my($basic_init) = Mebius::basic_init();

	# ���O�^�C�v����
	if($type =~ /Log-type-(\w+)/){
		$log_type = $1;
	}

	# �t�@�C����`
	if($file =~ /\W/ || $file eq ""){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
$logfile = "${account_directory}${file}_news.log";

	# �����`�F�b�N
	if($type =~ /Renew/){

		# �A�J�E���g������
		if(Mebius::Auth::AccountName(undef,$file)){ return(); }

	}

# �t�@�C�����J��
open($newcomment_handle,"<",$logfile);

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($newcomment_handle,1); }

	# �t�@�C����W�J����
	while(<$newcomment_handle>){

		# ���E���h�J�E���^
		$i++;

		# ���̍s�𕪉�
		chomp;
		my($key2,$account2,$handle2,$lasttime2,$date2,$comment2,$commenthidden2,$log_type2) = split(/<>/,$_);

		# ���t�@�C���X�V�p�̏���
		if($type =~ /Renew/){

				# �ő�s�����z�����ꍇ
				if($i >= 50){ last; }

				# ���O�^�C�v�������̏ꍇ
				#if($log_type && $log_type2 eq $log_type){ next; }

			# �X�V�s��ǉ�
			push(@renewline,"$key2<>$account2<>$handle2<>$lasttime2<>$date2<>$comment2<>$commenthidden2<>$log_type2<>\n");

		}

		# ���\���s���`
		if($type =~ /Get-topics/){

				# �ő�s�𒴉߂����ꍇ
				if($maxview && $hit_topics >= $maxview){ $flow_flag = 1; last; }
	
				# ����̏��̓G�X�P�[�v
				if($log_type2 && $log_type{$log_type2}){ next; }

			# ����̃��O�^�C�v���t�b�N
			$log_type{$log_type2} = 1;	

			# �q�b�g�J�E���^
			$hit_topics++;

			my($how_before2) = Mebius::SplitTime("Color-view Get-top-unit Plus-text-�O",time - $lasttime2);

			# ���`
			$index_line .= qq(<div>);

			# �C���f�b�N�X�s
			$index_line .= qq($comment2);
				if($account2){
					$index_line .= qq( - <a href="$main::auth_url$account2/">$handle2</a>);
				}

			# ���`
			$index_line .= qq(�@\ $how_before2</div>\n);

		}

		# ���\���s���`
		if($type =~ /Index/){

				# �ő�s�𒴉߂����ꍇ
				if($maxview && $i > $maxview){ $flow_flag = 1; last; }

				# �B���s�̏ꍇ
				if($key2 =~ /Hidden-from-index/){ next; }

			my($how_before2) = Mebius::SplitTime("Color-view Get-top-unit Plus-text-�O",$main::time - $lasttime2);

			# ���`
			$index_line .= qq(<tr>);

			# �C���f�b�N�X�s
			$index_line .= qq(<td>$comment2</td>);
			$index_line .= qq(<td>);
				if($account2){ $index_line .= qq(<a href="$main::auth_url$account2/">$handle2 - $account2</a>); }
			$index_line .= qq(</td>);

				# ����
				if($type =~ /All/ && $date2){
					$index_line .= qq(<td>$how_before2</td>);
					$index_line .= qq(<td>$date2</td>);
						if($commenthidden2){ $index_line .= qq(<td>$commenthidden2</td>); }
				}

			# ���`
			$index_line .= qq(</tr>\n);

		}

	}
close($newcomment_handle);

	# ���t�@�C�����X�V
	if($type =~ /Renew/){

		my($new_key);

			# �C���f�b�N�X����B���s
			if($type =~ /Hidden-from-index/){ $new_key .= qq( Hidden-from-index); }

		# �V�����s��ǉ�����
		unshift(@renewline,"$new_key<>$myfile<>$new_handle<>$main::time<>$main::date<>$newcomment<>$newcommenthidden<>$log_type<>\n");

		# �t�@�C�����X�V
		Mebius::Fileout("",$logfile,@renewline);

	}


	# ���C���f�b�N�擾�̌㏈��
	if($type =~ /Get-topics/){


			# ���o���̐��`
			if($index_line){
				$h3 = qq(<h3$main::kstyle_h3><a href="$basic_init->{'auth_url'}/$file/news">�j���[�X</a></h3>\n);
			}
			else{
				$h3 = qq(<h3$main::kstyle_h3>�j���[�X</h3>\n);
			}

			# �{�f�[�^�̐��`
			if($index_line){ $index_line = qq($h3\n<div class="news_list line-height-large">$index_line</div>); }
			else{ $index_line = qq($h3\n<div class="news_list line-height-large">�܂�����܂���B</div>); }

			# ���������N
			if($index_line){
				$index_line .= qq(<div class="right"><a href="$basic_init->{'auth_url'}/$file/news">������������</a></div>);
			}

			
		# ���^�[��
		return($index_line);

	}

	# ���C���f�b�N�擾�̌㏈��
	if($type =~ /Index/){

			# ���o���̐��`
			if($type =~ /All/){ $h3 = qq(<h2$main::kstyle_h2>�j���[�X</h2>\n); }
			elsif($flow_flag){ $h3 = qq(<h3$main::kstyle_h3><a href="./news">�j���[�X</a></h3>\n); }
			else{ $h3 = qq(<h3$main::kstyle_h3>�j���[�X</h3>\n); }

			# �{�f�[�^�̐��`
			if($index_line){ $index_line = qq($h3\n<table class="news_list">$index_line</table>); }
			else{ $index_line = qq($h3\n<table class="news_list">�܂�����܂���B</table>); }
		
		# ���^�[��
		return($index_line);

	}


}


#-------------------------------------------------
# �}�C���r�󋵂��`�F�b�N ( $account1 ���猩�Ă� $account2 �̏�� )
#-------------------------------------------------
sub FriendStatus{

# �Ǐ���
my($type,$account1,$account2) = @_;
my($friend_handler,%friend,@renew_line);

# $account = �֎~�ݒ�����Ă��鑤�̃A�J�E���g
# $account2 = �֎~�ݒ������Ă��鑤�̃A�J�E���g

	# �����`�F�b�N
	if(Mebius::Auth::AccountName(undef,$account1)){ return(); }
	if(Mebius::Auth::AccountName(undef,$account2)){ return(); }

# �f�B���N�g����`
my($account1_directory) = Mebius::Auth::account_directory($account1);
	if(!$account1_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
my $directory1 = "${account1_directory}friend/";
my $file = "${directory1}${account2}_f.cgi"; # $account1 ���́A�� $account2 ��ԃt�@�C��

	# ���O�C�����̂ݏ������s
	# �}�C���r�o�^�ς݂̏ꍇ�A�t���O�𗧂Ă�
	open($friend_handler,"<$file");

		# �t�@�C�����b�N
		if($type =~ /Renew/){ flock($friend_handler,1); }

	# �g�b�v�f�[�^�𕪉�
	chomp(my $top1 = <$friend_handler>);
	($friend{'key'},$friend{'last_time'}) = split(/<>/,$top1);

	close($friend_handler);

	# �}�C���r�ɂȂ������t���Ȃ��ꍇ�Astat �f�[�^����擾����
	if($friend{'key'} eq "1" && !$friend{'last_time'} && $type =~ /Get-stat/){
		my($stat) = Mebius::file_stat("Get-stat",$file);
		$friend{'last_time'} = $stat->{'last_modified'};
	}

	# ���t�@�C�����X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);

			# �}�C���r�\���������ꍇ
			if($type =~ /Apply-friend/){
				$friend{'key'} = 2;
				$friend{'last_time'} = $main::time;
			}

			# �}�C���r�ɂȂ����ꍇ
			if($type =~ /Be-friend/){
				$friend{'key'} = 1;
				$friend{'last_time'} = $main::time;
			}

			# �֎~�ݒ�������ꍇ
			if($type =~ /Deny-friend/){
				$friend{'key'} = 0;
				$friend{'last_time'} = $main::time;
			}

			# �}�C���r���폜�����ꍇ ( ���Ƃ��ƃ}�C���r�łȂ��ꍇ�̓��^�[�� )
			if($type =~ /Delete-friend/){
					if($friend{'key'} eq "1"){
						$friend{'key'} = "";
						$friend{'last_time'} = $main::time;
					}					else{
						return();
					}
			}

			# �}�C���r���ہi�\����Ԃ̍폜�j�������ꍇ ( ���Ƃ��Ɛ\������Ă��Ȃ��ꍇ�̓��^�[�� )
			if($type =~ /Delete-apply/){
					if($friend{'key'} eq "2"){
						$friend{'key'} = "";
						$friend{'last_time'} = $main::time;
					}
					else{
						return();
					}
			}

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$friend{'key'}<>$friend{'last_time'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file,@renew_line);

	}

	# �����̏ꍇ
	if($account1 eq $account2){
		$friend{'status'} = "me";
			if($type =~ /Me-check/){ $friend{'error_message'} = qq(�����ł��B); }
			if($type =~ /Me-check-error/){ main::error("$friend{'error_message'}"); }
	}

	# �\�����̏ꍇ
	elsif($friend{'key'} eq "2"){
		$friend{'status'} = "apply";
			if($type =~ /Still-apply-check/){ $friend{'error_message'} = qq($account1 ����� $account2 ����ɁA���Ƀ}�C���r��\\�����Ă��܂��B); }
			if($type =~ /Still-apply-check-error/){ main::error($friend{'error_message'}); }
	}

	# �}�C���r�̏ꍇ
	elsif($friend{'key'} eq "1"){
		$friend{'status'} = "friend";
			if($type =~ /Yet-friend-check/){ $friend{'error_message'} = qq($account1 ����� $account2 ����͊��Ƀ}�C���r�ł��B); }
			if($type =~ /Yet-friend-check-error/){ main::error($friend{'error_message'}); }
	}

	# �֎~�ݒ肳��Ă���ꍇ
	elsif($friend{'key'} eq "0"){
		$friend{'status'} = "deny";
			if($type =~ /Deny-check/){ $friend{'error_message'} = qq($account1 ����� $account2 ������֎~�ݒ蒆�ł��B); }
			if($type =~ /Deny-check-error/){ main::error($friend{'error_message'}); }
	}

	# �}�C���r�ł͂Ȃ��ꍇ
	if($friend{'key'} ne "1"){
				if($type =~ /Friend-check/){ $friend{'error_message'} = qq($account1 �����$main::friend_tag�ȊO�̑��M�͎󂯕t���Ă��܂���B); }
				if($type =~ /Friend-check-error/){ main::error($friend{'error_message'}); }
	}


	# �n�b�V����Ԃ�
	if($type =~ /Get-hash/){
		return(%friend);
	}

return($friend{'status'},$friend{'error_message'});

}

#-----------------------------------------------------------
# �N��𔻒�
#-----------------------------------------------------------
sub AgeGyap{

# �錾
my($type,$age1,$age2,$allow_gyap) = @_;
my($error_message);

# �N��M���b�v
if(!$allow_gyap){ $allow_gyap = 1; }

	# �傫�����̔N����`
	my $higher_age = $age1;
	my $lower_age = $age2;
		if($age2 > $higher_age){
			$higher_age = $age2;
			$lower_age = $age1;
		}

	# ��������l�̏ꍇ
	if($type =~ /Allow-together-adult/ && $age1 >= 18 && $age2 >= 18){ }
	# �N��� ~ �˖����̏ꍇ
	elsif($higher_age - $lower_age <= $allow_gyap){ }
	# ����ȊO�̏ꍇ
	else{
		$error_message = qq(�N������邽�߁A���M�ł��܂���B);
			if($main::myadmin_flag){ $error_message .= qq( ( * $age1�� / $age2��)); }
	}

	# �G���[
	if($error_message && $type =~ /Error-view/){
		main::error($error_message);
	}

return($error_message);

}

#-----------------------------------------------------------
# ���[���z�M
#-----------------------------------------------------------
sub SendEmail{

my($type,$to_account,$from_account,$mail) = @_;
my($body,$subject,$text1,$length,$comment_omited);
my($basic_init) = Mebius::basic_init();

	# �������g�̏������݂̏ꍇ�A���[���𑗐M���Ȃ�
	if($to_account->{'file'} eq $from_account->{'file'}){ return; }

	# ���[����M�ݒ�̂��߁A���[���𑗐M���Ȃ��ꍇ
	if($type =~ /Type-message/ && $to_account->{'catch_mail_message'} eq "Not-catch"){ return(); }
	elsif($type =~ /Type-res-diary/ && $to_account->{'catch_mail_resdiary'} eq "Not-catch"){ return(); }
	elsif($type =~ /Type-comment/ && $to_account->{'catch_mail_comment'} eq "Not-catch"){ return(); }
	elsif($type =~ /Type-etc/ && $to_account->{'catch_mail_etc'} eq "Not-catch"){ return(); }

	# ���M��A�J�E���g�̃��[���A�h���X�o�^�������ꍇ�A�{�F�؂�����Ă��Ȃ��ꍇ�̓��^�[��
	#if(!$to_account->{'sendmail_flag'}){ return; }

# �����̒�` 
my $to_address = $to_account->{'remain_email'} || $to_account->{'first_email'};
	if(!$to_address && $to_account->{'sendmail_flag'} && $to_account->{'email'}){ $to_address = $to_account->{'email'}; }

	if(!$to_address){ return; }

	# �{���̏ȗ�
	foreach( split(/<br>/,$mail->{'comment'}) ){
			if($length < 50){ $comment_omited .= qq(${_} ); }
		$length += length $_;
	}

	# ���[���������`
	if($mail->{'subject'} eq ""){
		$subject = qq(���r�����r�m�r�ɍX�V������܂���);
	}
	else{
		$subject = $mail->{'subject'};
	}

	# URL�� http:// ����n�܂��Ă��Ȃ��ꍇ�́A�����I��SNS�̃��C��URL��t��
	if($mail->{'url'} && $mail->{'url'} !~ /^http/){ $mail->{'url'} = "${main::auth_url}$mail->{'url'}"; }

# ���[���{��
$body .= qq(�y���r�����r�m�r�z����̂��m�点�ł��B\n\n);

	# �ȗ��R�����g
	if($comment_omited){ $body .= qq(��$comment_omited�c\n\n); }
	# �X�V���������t�q�k
	if($mail->{'url'}){
		$body .= qq(���t�q�k\n);
		$body .= qq($mail->{'url'}\n);
	}

# �z�M���������N
#$body .= qq(
#---------
#
#��SNS�̃��[���z�M����(�P�N���b�N)
# $basic_init->{'auth_url'}?mode=editprof&type=cancel_mail&account=$to_account->{'file'}&char=$to_account->{'mlpass'}
#);


# ���[�����M
#Mebius::Email::send_email("Edit-url-plus",$to_account->{'email'},$subject,$body);
Mebius::Email::send_email("Edit-url-plus $type",$to_address,$subject,$body);

}

#-----------------------------------------------------------
# �A�J�E���g���̃`�F�b�N
#-----------------------------------------------------------
sub account_name_error{

my($error_flag) = AccountName(undef,$_[0]);

$error_flag;

}

#-----------------------------------------------------------
# �A�J�E���g���̃`�F�b�N
#-----------------------------------------------------------
sub AccountName{

# �錾
my($type,$account) = @_;
my($error_flag);

	# �A�J�E���g���`�F�b�N
	if($account eq ""){
		$error_flag .= qq(�A�J�E���g�����w�肳��Ă��܂���B);
	}
	elsif($account =~ /\s|�@/){
		$error_flag .= qq(�A�J�E���g�� ( $account ) �ɔ��p�X�y�[�X�A�S�p�X�y�[�X�����ꍞ��ł��܂��B);
	}

	elsif($account =~ /[^a-z0-9]/){
		$error_flag = qq(�A�J�E���g�� ( $account ) �͏������̔��p�p���� ( 0-9 a-z ) �Ŏw�肵�Ă��������B);
	}

	elsif(length($account) < 3){
		$error_flag = qq(�A�J�E���g�� ( $account ) �Ɏg����̂� 3�����ȏォ��ł��B);
	}

	elsif(length($account) > 10){
		$error_flag = qq(�A�J�E���g�� ( $account ) �Ɏg����̂� 10���� �܂łł��B);
	}

	# ���O�����
	if($error_flag){ 
			if($type =~ /Error-view/){
				#Mebius::AccessLog(undef,"Account-name-format-error-view","�A�J�E���g���F $account");
				main::error("$error_flag");
			}
			else{
				#Mebius::AccessLog(undef,"Account-name-format-error-return","�A�J�E���g���F $account");
			}
	}

# ��ȏ�̕ϐ���Ԃ��Ȃ��悤��
return($error_flag);

}

#-----------------------------------------------------------
# Char�̃`�F�b�N
#-----------------------------------------------------------
sub CharCheck{

# �錾
my($type,$char_data,$char_query) = @_;
my($ok_flag);

	# �����[�l���Ȃ��ꍇ�A�����I�ɑ��
	if($char_data eq "" && $char_query eq ""){
		$char_data = $main::myaccount{'char'};
		$char_query = $main::in{'account_char'};
	}

	# ����
	if($char_data eq "" && $char_query){ $ok_flag = 1; }
	elsif($char_data eq $char_query){ $ok_flag = 1; }


	# �G���[�������\��
	if($type =~ /Error-view/ && !$ok_flag){# && !$main::alocal_mode
		main::error(qq(�Ȃɂ��ςȑ��M�ł��B<a href="$main::auth_url">SNS�̃g�b�v�y�[�W</a>�������Ȃ����Ă��������B));
	}

return($ok_flag);

}

#-----------------------------------------------------------
# �d�v�ȃA�N�V�������L�^����t�@�C��
#-----------------------------------------------------------
sub ImportanceHistoryFile{

# �錾
my($type,$account) = @_;
my(undef,undef,$new_message) = @_ if($type =~ /New-line/);
my($i,@renew_line,%data,$file_handler);

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
my $directory1 = $account_directory;
my $file1 = "${directory1}important_history_${account}.log";

# �ő�s���`
my $max_line = 500;

	# �t�@�C�����J��
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		open($file_handler,"<$file1") && ($data{'f'} = 1);
	}

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($key2,$message2,$cnumber2,$host2,$agent2,$time2) = split(/<>/);

			# �X�V�p
			if($type =~ /Renew/){

					# �ő�s���ɒB�����ꍇ
					if($i > $max_line){ next; }

				# �s��ǉ�
				push(@renew_line,"$key2<>$message2<>$cnumber2<>$host2<>$agent2<>$time2<>\n");

			}


	}

close($file_handler);

	# �V�����s��ǉ�
	if($type =~ /New-line/){
		unshift(@renew_line,"<>$new_message<>$main::cnumber<>$main::host<>$main::agent<>$main::time<>\n");

	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$data{'key'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);


}



1;
