
use strict;
use Mebius::RenewStatus;
package Mebius::Auth;
use Mebius::Export;

#������������������������������������������������������������
# �}�C���r�̈ꗗ
#������������������������������������������������������������
sub FriendIndex{

# �Ǐ���
my($type,$account) = @_;
my(undef,undef,%my_friend) = @_ if($type =~ /Get-index/);
my(undef,undef,$other_friend_account) = @_ if($type =~ /Tell-new-friend|Tell-cancel-friend/);
my(undef,undef,%renew) = @_ if($type =~ /Renew/);
my(undef,undef,@relay_diary) = @_ if($type =~ /New-diary|Delete-diary/);
my($FILE1,$index_line,$i_index,$hit_index,@index_line,@renew_line,$friend_num,%other_friend);
my(%account,$hit_all_index,$flow_flag,%self,@log_line,%self,%renew_self,$renew);
my($my_account) = Mebius::my_account();
my $time = time;

	# �����`�F�b�N
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

	if($type =~ /Renew/ && %renew && (Mebius::Auth::AccountName(undef,$renew{'account'}))){ return(); }

	# �����ƐV�����}�C���r�̏����擾
	if($type =~ /Tell-new-friend|Tell-cancel-friend/){
		(%account) = Mebius::Auth::File("Get-hash",$account);
		(%other_friend) = Mebius::Auth::File("Get-hash",$other_friend_account);
	}

# �t�@�C����`
# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

my $file = "${account_directory}${account}_friend.cgi";

	# �ǂݏ����^�C�v��ǉ�
	if($type =~ /Allow-renew-status/){ $type .= qq( Flock2); }

# �}�C���r���X�g���擾����
my($FILE1,$read_write) = Mebius::File::read_write($type,$file);
	if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }

	# �S�Ĕz��Ɋi�[���Ă���
	while(<$FILE1>){ push(@log_line,$_); }

	# �g�b�v�f�[�^�̕⊮
	if($log_line[0] =~ /^TopDataPushed<>/){
		chomp ( $self{'top1'} = shift @log_line);
	}

	# �g�b�v�f�[�^�̕��� ( �g�b�v�f�[�^��F�����Ă��Ă����Ă��Ȃ��Ă��A��̍X�V�����̂��߁A���̈ʒu�ɒu�� )
	# ( ����������`����Ă��Ȃ��n�b�V���́AHash::control �ōX�V����Ȃ� )
	($self{'mark'},$self{'last_renew_status_time'}) = split(/<>/,$self{'top1'});

	# �}�C���r�̃X�e�[�^�X�X�V����
	if($type =~ /Allow-renew-status/ && time >= $self{'last_renew_status_time'} + 5*60){
		$type .= qq( Renew);
		$renew_self{'last_renew_status_time'} = time;
	}

	# �t�@�C����W�J
	foreach (@log_line) {

		# �Ǐ���
		my($mylink2,$last_access_time2,%account2);

		# ���̍s�𕪉�
		chomp;
		my($key2,$account2,$handle2,$intro2,$befriend_time2,$edit_time2,$last_edit_time2,$be_introductioned_comment2,$last_access_time2,$last_get_account_data_time2,$account2_friend_num2,$be_introductioned_time2) = split(/<>/);
		push @{$self{'accounts'}} , $account2;

			# ���Ă���f�[�^�s�͖�������i�t�@�C���X�V���ɂ͍s���폜���Ă��܂��j
			if(Mebius::Auth::AccountName(undef,$account2)){
					if($type =~ /Renew/){	Mebius::AccessLog(undef,"Account-name-broken-file-fixed","�A�J�E���g���F $account2 �f�[�^�s�F $_ "); }
				next;
			}

		# ���E���h�J�E���^
		$i_index++;

		# �}�C���r�����J�E���g
		$friend_num++;

			# ���v���t�B�[���ȂǂŁA�S�f�[�^���Q�b�g
			if($type =~ /Get-all-index/){

				$hit_all_index++;

					if($hit_all_index > 10){ $flow_flag = 1; next; }

					if($intro2 ne ""){ $intro2 =~ s/<br>/ /g; $intro2 = qq( - $intro2); }
				$self{'topics_line'} .= qq(<a href="${main::auth_url}$account2/">$handle2</a> );
	
					# �C���f�b�N�X�s
					if($hit_all_index <= 7){
						$self{'index_line'} .= qq(<div><a href="${main::auth_url}$account2/">$handle2 - $account2</a>$intro2);
							if($account{'myprof_flag'} || $main::myadmin_flag){
								$self{'index_line'} .= qq( - <a href="../?mode=befriend&amp;decide=edit&amp;account=$account2&amp;myaccount=$account">�ҏW</a>);
							}

						$be_introductioned_comment2 =~ s/<br>/ /g;
						$self{'index_line'} .= qq(</div>\n);

					}

			}

			# �}�C���r�n�b�V��
			if($type =~ /Get-friend-hash/){
				$self{"my_friend_$account2"} = 1;
			}

			# �u�`����́`����ƃ}�C���r�ɂȂ�܂����v�̂��m�点�p
			if($type =~ /Tell-new-friend/){
				Mebius::Auth::FriendsFriendIndex("New-allow Renew",$account2,$account{'file'},$other_friend{'file'},$account{'handle'},$other_friend{'handle'});
				Mebius::Auth::News("Renew Hidden-from-index Log-type-befriend",$account2,undef,undef,qq(<a href="${main::auth_url}$account{'file'}/">$account{'handle'}</a> ����� <a href="${main::auth_url}$other_friend{'file'}/">$other_friend{'handle'}</a>����$main::friend_tag��));
			}
			# �����p
			if($type =~ /Tell-cancel-friend/){
				Mebius::Auth::FriendsFriendIndex("New-cancel Renew",$account2,$account{'file'},$other_friend{'file'});
			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){

					my($allow_renew_line_flag) = Mebius::RenewStatus::allow_judge_for_get_file($last_get_account_data_time2,$last_access_time2) if($type =~ /Allow-renew-status/);

					# ���A�J�E���g�P�̃t�@�C����������擾���đ������
					if($allow_renew_line_flag){

						# �A�J�E���g�f�[�^���擾
						my(%account2) = Mebius::Auth::File("Hash Option Not-file-check",$account2);

						# �P�̃t�@�C���f�[�^�擾����
						$last_get_account_data_time2 = time;

							# �M������
							if($account2{'name'}){ $handle2 = $account2{'name'}; }

							# �L�[
							if($account2{'allow_view_last_access'} eq "Not-open"){
								$key2 =~ s/(\s)?Access-time-not-open//g;
								$key2 .= qq( Access-time-not-open);
							}
							else{
								$key2 =~ s/Access-time-not-open//g;
							}

							# �e�}�C���r�̍ŏI���O�C�����Ԃ���
							if($account2{'last_access_time'}){
								$last_access_time2 = $account2{'last_access_time'};
							}

							# �}�C���r�̃}�C���r��
							if($account2{'friend_num'}){
								$account2_friend_num2 = $account2{'friend_num'};
							}

							# �L�[���Ȃ��ꍇ�͎��񏈗���
							if(!$account2{'key'}){ next; }

					}

					# �}�C���r�ɂȂ������t��������Ȃ��ꍇ�́A�t�����h��Ԏ擾��������Astat �Ŏ擾����
					if(!$befriend_time2){
						my(%friend) = Mebius::Auth::FriendStatus("Get-hash Get-stat",$account,$account2);
						$befriend_time2 = $friend{'last_time'};
					}

					# ���Љ�̕ύX
					if($type =~ /Change-introduction/){
							if($account2 eq $renew{'account'}){
								$intro2 = $renew{'intro'};
								$edit_time2 = time;
								$last_edit_time2 = time;
								$self{'still_friend_flag'} = 1;
							}
					}

					# ���Љ�̕ύX
					if($type =~ /Change-be-introductioned/){
							if($account2 eq $renew{'account'}){
								$be_introductioned_comment2 = $renew{'be_intro'};
								$be_introductioned_time2 = time;
							}
					}

					# ���}�C���r�̍폜
					if($type =~ /Delete-friend/){
							if($account2 eq $renew{'account'}){
								$friend_num--;
								$self{'still_friend_flag'} = 1;
								next;
							}
					}

					# ���}�C���r��V�K�ǉ�
					if($type =~ /New-friend/){
							if($account2 eq $renew{'account'}){
								$self{'still_friend_flag'} = 1;
								next;
							}
					}

					# �X�V�s��ǉ�����
					push(@renew_line,"$key2<>$account2<>$handle2<>$intro2<>$befriend_time2<>$edit_time2<>$last_edit_time2<>$be_introductioned_comment2<>$last_access_time2<>$last_get_account_data_time2<>$account2_friend_num2<>$be_introductioned_time2<>\n");
			}

			# �� �C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

					my($relay_last_access_time2);

					# �A�J�E���g�f�[�^���擾
					#if($type =~ /Get-friend-status/){

							# �f�[�^�����Ă���ꍇ�ȂǁA�A�J�E���g�t�@�C�����擾���悤�Ƃ��Ă��܂��ƃG���[���o�邽�ߑΉ�
					#		if(!$account2){ next; }

					#	(%account2) = Mebius::Auth::File("Hash Not-file-check Option",$account2);
						#(%option2) = Mebius::Auth::Optionfile("Get-hash",$account2);
							#if($account2{'name'}){ $handle2 = $account2{'name'}; }

							# �e�}�C���r�̍ŏI���O�C�����Ԃ���
							#if($option2{'last_access_time'} && $account2{'allow_view_last_access'} ne "Not-open"){
							#	$last_access_time2 = $option2{'last_access_time'};
							#}

							# �e�}�C���r�̍ŏI���O�C�����Ԃ���
						#	if($account2{'last_access_time'} && $account2{'allow_view_last_access'} ne "Not-open"){
						#		$last_access_time2 = $account2{'last_access_time'};
						#	}

						# �L�[���Ȃ��ꍇ�͎��񏈗���
						#if(!$account2{'key'}){ next; }

					#}

				# �C���f�b�N�X�z���ǉ�
				# push(@index_line,"$key2<>$account2<>$handle2<>$intro2<>$last_access_time2<>$befriend_time2<>$account2{'myurl'}<>$option2{'friend_num'}<>\n");

					if($key2 =~ /Access-time-not-open/){ 
						$relay_last_access_time2 = "";
					}
					else{
						$relay_last_access_time2 = $last_access_time2;
					}

				push(@index_line,"$key2<>$account2<>$handle2<>$intro2<>$relay_last_access_time2<>$befriend_time2<>$account2{'myurl'}<>$account2_friend_num2<>\n");

			}

			# ���}�C���r�̐V�����L����čX�V���� ( �ǉ� )
			if($type =~ /New-diary/){
				Mebius::Auth::FriendDiaryIndex("New-diary Renew",$account2,$account,@relay_diary);
			}

			# ���}�C���r�̐V�����L����čX�V���� ( �폜 )
			if($type =~ /Delete-diary/){
				Mebius::Auth::FriendDiaryIndex("Delete-diary Renew",$account2,$account,@relay_diary);
			}


	}

	# ���C���f�b�N�X���ēW�J
	if($type =~ /Get-index/){

			# �ŏI���O�C�����ԏ��Ƀ\�[�g
			if($type =~ /Get-friend-status/){
				@index_line = sort { (split(/<>/,$b))[4] <=> (split(/<>/,$a))[4] } @index_line;
			}
		
			# �}�C���r�ɂȂ������t���Ƀ\�[�g
			else{
				@index_line = sort { (split(/<>/,$b))[5] <=> (split(/<>/,$a))[5] } @index_line;
			}

			# ���z���W�J
			foreach(@index_line){

				my($class,$mark);

				# �s�𕪉�
				chomp;
				my($key2,$account2,$handle2,$intro2,$last_access_time2,$befriend_time2,$myurl2,$friend_num2) = split(/<>/);

					# ���`
					if($intro2){ $intro2 =~ s/<br>/ /g; }

				# �q�b�g�J�E���^
				$hit_index++;

					# ������A�����̋��ʂ̃}�C���r�̏ꍇ
					if($account2 eq $my_account->{'id'}){
						$mark = qq( <span class="red size80">�����Ȃ��ł��B</span>);
						$class .= qq( me);
					}
					elsif($my_friend{"my_friend_$account2"}){
						$mark = qq( <span class="green size80">�����ʂ�${main::friend_tag}�ł��B</span>);
						$class .= qq( my_friend);
					}

				# �C���f�b�N�X�\�����`
				$index_line .= qq(<div class="lim$class" id="F_$account2">);
				$index_line .= qq(<a href="$main::adir${account2}/">$handle2 - $account2</a>);
					
					# �}�C���r�l��
					if($friend_num2){
						$index_line .= qq( ( <a href="${main::adir}$account2/aview-friend">$friend_num2</a> ));
					}
					else{
						$index_line .= qq( ( <a href="${main::adir}$account2/aview-friend">$main::friend_tag</a> ));
					}

					# �������̃}�C���r�y�[�W�ł����\�������
					if($type =~ /Get-friend-status/ || $my_account->{'master_flag'}){

							# �ŏI���O�C������
							if($last_access_time2){
								my($time_splited2) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-�O",time - $last_access_time2);
									if($time_splited2){ $index_line .= qq( - ���O�C���F $time_splited2 ); }
							}

							# �}�C���r�ɂȂ������t
							if($befriend_time2){
								my($time_splited2) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-�O",time - $befriend_time2);
									if($time_splited2){ $index_line .= qq( - �}�C���r�F $time_splited2 ); }
							}
					}

					# �}�C�t�q�k
					if($myurl2){ $index_line .= qq( - <a href="$myurl2" title="$myurl2">�t�q�k</a>); }

					# �Љ
					if($intro2){ $index_line .= qq( - $intro2); }

					# �ҏW�����N ( ��A�J�E���g�̏�Ԃ𔻒� )
					if($type =~ /Get-friend-status/ || $main::myaccount{'admin_flag'}){
						$index_line .= qq( (<a href="$main::script?mode=befriend&amp;decide=edit&amp;account=$account2&amp;myaccount=$account">���ҏW</a>));
					}


				$index_line .= qq($mark</div>);

			}

			# �����`
			if($index_line){
				$self{'index_line'} = qq(<h2 id="MYMEBI"$main::kstyle_h2>$main::friend_tag ($hit_index�l)</h2><div class="line-height-large friend_index">$index_line</div>);
					if($type =~ /Get-friend-status/ && $self{'last_renew_status_time'}){
						my($how_long) = shift_jis(Mebius::second_to_howlong({ GetLevel => "top" , ColorView => 1 , HowBefore => 1 },time - $self{'last_renew_status_time'}));
						$self{'index_line'} .= qq(<div class="right">�X�V : $how_long</div>);
					}
			}

	}

	# ���t�@�C�����X�V
	if($type =~ /Renew/){

		# �Ǐ���
		my(%renew_option);

			# ���V�����}�C���r��ǉ�����
			if($type =~ /New-friend/){
					if(!$self{'still_friend_flag'}){ $friend_num++; }
				unshift(@renew_line,"<>$renew{'account'}<>$renew{'handle'}<><>$time<>$time<>$time<>\n");
			}

		# �ҏW���ԏ��Ƀ\�[�g?
		#@renew_line = sort { (split(/<>/,$b))[6] <=> (split(/<>/,$a))[6] } @renew_line;

		# �C�ӂ̍X�V�ƃ��t�@�����X��
		($renew) = Mebius::Hash::control(\%self,\%renew_self);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"TopDataPushed<>$renew->{'last_renew_status_time'}<>\n");

		# �t�@�C���X�V
		Mebius::File::truncate_print($FILE1,@renew_line);

		# �I�v�V�����t�@�C���̃}�C���r�l�����X�V
		#$renew_option{'friend_num'} = $friend_num;
		#Mebius::Auth::Optionfile("Renew",$account,%renew_option);

			# �I�v�V�����t�@�C���̃}�C���r�l�����X�V
			if($type !~ /Allow-renew-status/){
				$renew_option{'friend_num'} = $friend_num;
				Mebius::Auth::File("Renew Option",$account,\%renew_option);
			}
	}

close($FILE1);

	# �p�[�~�b�V�����ύX
	if($type =~ /Renew/){ Mebius::Chmod(undef,$file); }

	# �o�b�N�A�b�v
	if($type =~ /Renew/ && (rand(25) < 1 || Mebius::alocal_judge())){
		Mebius::make_backup($file);
	}

	# ���o�^���Ȃ��̂ɕύX���悤�Ƃ����ꍇ
	#if($type =~ /Change-introduction/ && !$still_friend_flag){
	#	main::error("�ꗗ�ɑ��݂��Ȃ�$main::friend_tag ( $renew{'account'} ) �͕ύX�ł��܂���B");
	#}

	# �n�b�V������
	if(!$self{'friend_num'}){ $self{'friend_num'} = 0; }

	# ���^�[��
	if($type =~ /Renew/ && %$renew){
		return(%$renew);
	}
	else{
		return(%self);
	}

}

#-----------------------------------------------------------
# �}�C���r�\���t�@�C��
#-----------------------------------------------------------
sub ApplyFriendIndex{

# �錾
my($type,$account,$target_account) = @_;
my(undef,undef,undef,$handle,$apply_comment) = @_ if($type =~ /New-apply/);
my(%apply,$apply_index_handler,@renew_index,$index_line,$i,$hit_index,$most_new_applied_time);
my $time = time;

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }
	if($target_account && Mebius::Auth::AccountName(undef,$target_account)){ return(); }

# �t�@�C����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

my $file = "${account_directory}${account}_befriend.cgi";

# �t�@�C�����J��
open($apply_index_handler,"<",$file);

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($apply_index_handler,1); }

	# �t�@�C����W�J
	while(<$apply_index_handler>){

		# ���E���h�J�E���^
		$i++;

		# �s�𕪉�
		chomp;
		my($account2,$handle2,$apply_time2,$apply_comment2) = split(/<>/);

			# �\���ς݂��ǂ����A�A�J�E���g�d���������邩�ǂ������`�F�b�N
			if($account2 eq $target_account){
				$apply{'still_apply_flag'} = 1;
			} else {
				# �\�����𐔂���
				$apply{'num'}++;
			}

			# �� �C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

				# �\������
				my(%apply_time) = Mebius::Getdate("Get-hash",$apply_time2); 

				# �q�b�g�J�E���^
				$hit_index++;

					# ������
					if($hit_index >= 2){ $index_line .= qq(<hr$main::xclose>); }

				$index_line .= qq(<div class="line-height">);
				$index_line .= qq(<a href="${main::auth_url}$account2/">$handle2 - ${account2}</a>);
				$index_line .= qq( - <a href="$main::script?mode=befriend&amp;decide=ok&amp;account=${account2}">������</a> / );
				$index_line .= qq(<a href="$main::script?mode=befriend&amp;decide=no&amp;account=${account2}">���ۂ���</a>);
					if($apply_time{'date'}){ $index_line .= qq( ( $apply_time{'date'} ) ); }
					if($apply_comment2){ $index_line .= qq(<div>$apply_comment2</div>); }
				$index_line .= qq(</div>);
			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){ 

					# �A�J�E���g�d���𔻒�
					if($account2 eq $target_account && $type =~ /(New-apply|Delete-apply|Allow-apply)/){
						next;

					} else{

						# �}�C���r���ۂ����ꍇ�́A���_�\���҂̍ŏI�\���������L�����Ă���
						if($apply_time2 > $most_new_applied_time){ $most_new_applied_time = $apply_time2; }

						# �X�V�s��ǉ�
						push(@renew_index,"$account2<>$handle2<>$apply_time2<>$apply_comment2<>\n")
					}
			}

	}
close($apply_index_handler);

	# ���C���f�b�N�X�擾�p
	if($type =~ /Get-index/){
			if($index_line eq ""){ $index_line = qq(���݁A�\\���͂���܂���B); }
		$apply{'index_line'} = qq(<div>$index_line</div>);
	}

	# ���}�C���r���p
	if($type =~ /Allow-apply/){
			if(!$apply{'still_apply_flag'}){ main::error("�\\������Ă��Ȃ������o�[ ( $target_account ) �͋��ł��܂���B"); }
	}

	# �� �V�����\���p
	if($type =~ /New-apply/){
		$apply{'num'}++;
		unshift(@renew_index,"$target_account<>$handle<>$time<>$apply_comment<>\n");
	}

	# ���t�@�C�����X�V�p
	if($type =~ /Renew/){
		Mebius::Fileout("Allow-empty",$file,@renew_index);
	}

	# �{�̃t�@�C�����X�V ( �t�B�[�h�\���p )
	if($type =~ /Renew/){

		my(%renew_account);

		# �������̐\���� 
			if(!defined $apply{'num'}){ $apply{'num'} = 0; } # �X�V�ɕK�v
		$renew_account{'new_applied_num'} = $apply{'num'};

			# ��ԐV�����\���̎���
			if($type =~ /New-apply/){
				$renew_account{'last_applied_time'} = time;
			} else {
				$renew_account{'last_applied_time'} = $most_new_applied_time;
			}

		# �X�V
		Mebius::Auth::File("Renew Option",$account,\%renew_account);

	}


return(\%apply);

}

#-----------------------------------------------------------
# �u�}�C���r�V�����L�v�̃C���f�b�N�X ( �A�J�E���g�� )
#-----------------------------------------------------------
sub FriendDiaryIndex{

# �Ǐ���
my($type,$account) = @_;
my(undef,undef,$max_view_topics) = @_ if($type =~ /Get-topics/);
my(undef,undef,$diary_account,$diary_number,$diary_subject,$diary_handle) = @_ if($type =~ /New-diary|Delete-diary/);
my($i,$friend_diary_index,@renew_line,$topics_index,$topics_line,$hit_topics,$index_line,$topics_flow_flag,%data);
my $time = time;

	# �����`�F�b�N
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }
	if(!$max_view_topics){ $max_view_topics = 5; }

# �t�@�C����`
# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
my $file = "${account_directory}${account}_dnewlist_friend.cgi";

# �V���ꗗ�̍ő吔
my $max_line = 25;

	# �V�������L�𓊍e�����ꍇ
	if($type =~ /New-diary/){
		unshift(@renew_line,"<>$diary_account<>$diary_handle<>$diary_number<>$diary_subject<>$main::time<>$main::date<>\n");
		$i++;
	}

# �t�B�C�����J��
open($friend_diary_index,"+<",$file) && ($data{'f'} = 1);

	# �t�@�C�������݂��Ȃ��ꍇ
	if(!$data{'f'}){
		close($friend_diary_index);
		Mebius::Fileout("Allow-empty",$file);
		open($friend_diary_index,"+<$file") && ($data{'f'} = 1);
	}

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($friend_diary_index,2); }

	# �t�@�C����W�J
	while(<$friend_diary_index>){

		# ���E���h�J�E���^
		$i++;

		# �s�𕪉�����
		chomp;
		my($key2,$account2,$handle2,$diary_number2,$subject2,$posttime2,$postdate2) = split(/<>/);

			# ���v���t�B�[���p
			if($type =~ /Get-topics/){

				my($post_before2) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-�O",$main::time - $posttime2);

					# �폜�ς݂̏ꍇ
					if($key2 =~ /Deleted/){ next; }

					if($hit_topics >= $max_view_topics){ $topics_flow_flag = 1; last; }

				my $link = qq($main::adir$account2/);
				my $link2 = qq($main::adir$account2/d-$diary_number2);
					if($main::aurl_mode){ ($link) = main::aurl($link); ($link2) = main::aurl($link2); }
					$topics_line .= qq(<div><a href="$link2">$subject2</a> - <a href="$link">$handle2</a>�@ $post_before2</div>);
				$hit_topics++;
			}

			# ���C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

					# �폜�ς݂̏ꍇ
					if($key2 =~ /Deleted/){ next; }

				my($post_before2) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-�O",$main::time - $posttime2);
				$index_line .= qq(<tr>\n);
				$index_line .= qq(<td>\n);
				$index_line .= qq(<a href="${main::auth_url}$account2/d-$diary_number2">$subject2</a>\n);
				$index_line .= qq(</td>\n);
				$index_line .= qq(<td>\n);
				$index_line .= qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>\n);
				$index_line .= qq(</td>\n);
				$index_line .= qq(<td>\n);
				$index_line .= qq($post_before2\n);
				$index_line .= qq(</td>\n);
				$index_line .= qq(</tr>\n);
			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){

					# �����ő�s���ɒB�����ꍇ
					if($i >= $max_line){ last; }

					# ���ꗗ����폜����ꍇ
					if($type =~ /Delete-diary/){
							if($account2 eq $diary_account && $diary_number2 eq $diary_number){
								if($key2 !~ /Deleted/){ $key2 .= qq( Deleted); }
							}
					}


				# �X�V�s��ǉ�����
				push(@renew_line,"$key2<>$account2<>$handle2<>$diary_number2<>$subject2<>$posttime2<>$postdate2<>\n");
			
			}

	}

	# �t�@�C������������
	if($type =~ /Renew/){
		seek($friend_diary_index,0,0);
		truncate($friend_diary_index,tell($friend_diary_index));
		print $friend_diary_index @renew_line;
		close($friend_diary_index);
		Mebius::Chmod(undef,$file);
	}


close($friend_diary_index);

	# �g�s�b�N�X�擾�p
	if($type =~ /Get-topics/){
			
				if($topics_line eq ""){ $topics_line = qq(�f�[�^������܂���); }

			# ���o���̐��`
			$topics_line = qq(<h3$main::kstyle_h3><a href="friend-diary">�}�C���r�̍X�V</a></h3><div class="mdiary line-height-large">$topics_line</div>);

			# ���������N
			if($topics_flow_flag){
				$topics_line .= qq(<div class="right"><a href="friend-diary">������������</a>�@</div>);
			}

		return($topics_line);
	}

	# �C���f�b�N�X�擾�p
	if($type =~ /Get-index/){
			if($index_line){
				$index_line = qq(<table summary="�}�C���r�̐V�����L�ꗗ" class="friend_diary">$index_line</table>);
			}
			else{
				$index_line = qq(<div>��������܂���B</div>);
			}
		return($index_line);
	}


}

#-----------------------------------------------------------
# �}�C���r�̐V�����L�ꗗ�̕\���y�[�W
#-----------------------------------------------------------
sub FriendDiaryIndexView{

# �錾
my($view_line,$target_account);


# CSS��`
$main::css_text .= qq(table.friend_diary{width:100%;});

	# �J���A�J�E���g���`
	if($main::in{'account'}){
		$target_account = $main::in{'account'};
	}
	else{
		$target_account = $main::myaccount{'file'};
	}

# �Ώۂ̃A�J�E���g���J��
my(%account) = Mebius::Auth::File("File-check-error",$target_account);

# �����̃v���t�B�[���A�܂��͊Ǘ��҂łȂ���΃G���[��
if(!$account{'editor_flag'}){ main::error("���Ȃ��̃y�[�W�ł͂���܂���B"); }

# �ΏۃA�J�E���g�̃}�C���r�V�����L���擾
my($index_line) = Mebius::Auth::FriendDiaryIndex("Get-index",$account{'file'});

# HTML���`
$view_line .= qq($main::footer_link);
$view_line .= qq(<h1$main::kstyle_h1>�}�C���r�̐V�����L</h1>);
$view_line .= qq(<div class="word-spacing">);
$view_line .= qq( <a href="${main::auth_url}$account{'file'}/">���Ȃ��̃v���t�B�[��</a>);
$view_line .= qq( �}�C���r�̐V�����L);
$view_line .= qq( <a href="${main::auth_url}aview-alldiary.html">�S�����o�[�̐V�����L</a>);
$view_line .= qq( <a href="${main::auth_url}?mode=fdiary">�V�������L������</a>);
$view_line .= qq(</div>);
$view_line .= qq(<h2$main::kstyle_h2>���j���[</h2>);
$view_line .= qq($index_line);
$view_line .= qq($main::footer_link2);

# �^�C�g����`
$main::sub_title = qq(�}�C���r�̐V�����L | $account{'name'} - $account{'file'});


# HTML��\��
my $print = qq($view_line);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# �}�C���r�ƃ}�C���r�ɂȂ��������o�[�ꗗ
#-----------------------------------------------------------
sub FriendsFriendIndex{

# �錾
my($type,$account,$friend_account,$other_account) = @_;
my(undef,undef,undef,undef,$friend_handle,$other_handle) = @_ if($type =~ /New-allow/);
my($i,@renew_line,%data,$file_handler);

# �s��
my $max_line = 10;

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
my $directory1 = $account_directory;
my $file1 = "${directory1}${account}_friends_friend.log";

# �t�@�C�����J��
open($file_handler,"<$file1");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# �Ǐ���
		my($not_push_flag);

		# ���E���h�J�E���^
		$i++;

		# ���̍s�𕪉�
		chomp;
		my($key2,$friend_account2,$other_account2,$friend_handle2,$other_handle2,$befriend_time2) = split(/<>/);

			# �C���f�b�N�X���擾
			if($type =~ /Get-index/){
				$data{'index_line_body'} .= qq(<div class="line-height-large">);
				$data{'index_line_body'} .= qq(<a href="${main::auth_url}$friend_account2/">$friend_handle2</a> ����� );
				$data{'index_line_body'} .= qq(<a href="${main::auth_url}$other_account2/">$other_handle2</a> ����);
				$data{'index_line_body'} .= qq($main::friend_tag�ɂȂ�܂��� );
					my($befriend_how_before) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-�O",time - $befriend_time2);
				$data{'index_line_body'} .= qq( \( $befriend_how_before \));
				$data{'index_line_body'} .= qq(</div>\n);
			}

			# �폜����ꍇ
			if($type =~ /New-cancel/){
					# �w��A�J�E���g���q�b�g�����ꍇ
					if("$friend_account2-$other_account2" eq "$friend_account-$other_account"){ $not_push_flag = 1; }
			}

			# �s��ǉ�
			if($type =~ /Renew/ && $i < $max_line && !$not_push_flag){
				push(@renew_line,"$key2<>$friend_account2<>$other_account2<>$friend_handle2<>$other_handle2<>$befriend_time2<>\n");
			}

	}

close($file_handler);

	# �C���f�b�N�X�𐮌`
	if($type =~ /Get-index/){

			if($data{'index_line_body'}){
					$data{'index_line'} = qq($data{'index_line_body'});
			}
			else{
				$data{'index_line'} = qq(<div>�܂��f�[�^������܂���B</div>);
			}
	}

	# �V�K�ǉ�
	if($type =~ /New-allow/){
		unshift(@renew_line,"<>$friend_account<>$other_account<>$friend_handle<>$other_handle<>$main::time<>\n");
	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);

		# �t�@�C���X�V
		unshift(@renew_line,"$data{'key'}<>\n");
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);


}


1;
