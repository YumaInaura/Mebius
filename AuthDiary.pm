
use strict;
use Mebius::RenewStatus;
package Mebius::Auth;

#-----------------------------------------------------------
# SNS�̌ʂ̓��L���J��
#-----------------------------------------------------------
sub diary{

# �錾
my($type,$account,$diary_number) = @_;
my(undef,undef,undef,$renew) = @_ if($type =~ /Renew/);
my($diary_handler,%diary,$i,@renew_line);

	# �����`�F�b�N
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }
	if($diary_number =~ /\D/ || $diary_number eq ""){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
my $file = "${account_directory}diary/${account}_diary_${diary_number}.cgi";

	# ���L�t�@�C�����J��
	if($type =~ /File-check-error|Level-check-error/){ open($diary_handler,"<$file") || main::error("���̓��L�͑��݂��܂���B"); }
	else{ open($diary_handler,"<$file") || ($diary{'nothing_flag'} = 1); }

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock(1,$diary_handler); }

chomp(my $top1 = <$diary_handler>);
chomp(my $top2 = <$diary_handler>);

# �f�[�^�𕪉�
($diary{'key'},$diary{'number'},$diary{'subject'},$diary{'res'},$diary{'postdates'},$diary{'posttime'},$diary{'lastrestime'},$diary{'control_datas'},$diary{'last_account'},$diary{'last_handle'},$diary{'owner_lastres_time'},$diary{'owner_lastres_number'},$diary{'concept'}) = split(/<>/,$top1);
($diary{'year'},$diary{'month'},$diary{'day'},$diary{'hour'},$diary{'min'},$diary{'sec'}) = split(/,/,$diary{'postdates'});
(undef,undef,$diary{'account'},$diary{'handle'},$diary{'id'},$diary{'trip'},$diary{'comment'},$diary{'dates'},$diary{'color'},$diary{'xip'},$diary{'controler_file'},$diary{'control_date'}) = split(/<>/,$top2);

	# �n�b�V������
	if(!$diary{'nothing_flag'}){ $diary{'f'} = 1; }
	if(($diary{'key'} eq "2" || $diary{'key'} eq "4") && $diary{'concept'} !~ /Deleted/){ $diary{'concept'} .= qq( Deleted); }
	if($diary{'concept'} =~ /Deleted/){ $diary{'deleted_flag'} = 1; }

	# ���蔻��
	if($type =~ /Crap-check/){
			if($diary{'concept'} =~ /Not-ranking-crap/){ $diary{'not_crap_ranking_flag'} = 1; }
			if($diary{'concept'} =~ /Not-crap/){ $diary{'not_crap_flag'} = 1; }
			if($diary{'subject'} =~ /����/){ $diary{'not_crap_ranking_flag'} = 1; }
			if($diary{'comment'} =~ /����/){ $diary{'not_crap_ranking_flag'} = 1; }
	}

	# �����L�t�@�C����W�J ( ���� )
	if($type =~ /Renew/){

			# �t�@�C����W�J
			while(<$diary_handler>){
		
				# ���E���h�J�E���^
				$i++;
		
				chomp;
				my($key2,$res_number2,$account2,$handle2,$id2,$trip2,$comment2,$dates2,$color2,$xip2,$controler_account2,$control_date2) = split(/<>/);
		
				# �X�V�s��ǉ�
	push(@renew_line,"$key2<>$res_number2<>$account2<>$handle2<>$id2<>$trip2<>$comment2<>$dates2<>$color2<>$xip2<>$controler_account2<>$control_date2\n");
		
			}


	}

close($diary_handler);

	# ���x���`�F�b�N
	if($type =~ /Level-check-error/){
			if($diary{'deleted_flag'}){ main::error("���̓��L�͑��݂��Ȃ����A�폜�ς݂ł��B"); }
	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �Q�s�ڃf�[�^��ǉ�
		unshift(@renew_line,"$top2\n");

			# �g�b�v�f�[�^����čX�V
			foreach(keys %$renew){
				$diary{$_} = $renew->{$_};
			}

		# �g�b�v�f�[�^��ǉ�
	unshift(@renew_line,"$diary{'key'}<>$diary{'number'}<>$diary{'subject'}<>$diary{'res'}<>$diary{'postdates'}<>$diary{'posttime'}<>$diary{'lastrestime'}<>$diary{'control_datas'}<>$diary{'last_account'}<>$diary{'last_handle'}<>$diary{'owner_lastres_time'}<>$diary{'owner_lastres_number'}<>$diary{'concept'}<>\n");
		Mebius::Fileout(undef,$file,@renew_line);
	}
	

return(\%diary);

}

#-----------------------------------------------------------
# ���L�ւ̃R�����g����
#-----------------------------------------------------------
sub ResDiaryHistory{
# �錾
my($type,$account) = @_;
my(undef,undef,$new_account,$new_diary_number,$new_res_number) = @_;
my($FILE1,%self,$i,@renew_line,@index_line,$hit_topics,$under_interval,$hit_renew_status_flag,$renew_file_flag);

# �����`�F�b�N
if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �g�s�b�N�X�̍ő�\���s��
my $max_view_topics = 4;

	# �Œ�擾�Ԋu
	if(Mebius::AlocalJudge()){ $under_interval = 10; }
	else{ $under_interval = 15*60; }

# �t�@�C����`
my $file1 = "${account_directory}resdiary_history.log";

# �t�@�C�����J��
	if($type =~ /File-check-error/){
		$self{'f'} = open($FILE1,"+<",$file1) || &main::error("�t�@�C�������݂��܂���B");
	}
	else{

		$self{'f'} = open($FILE1,"+<",$file1);

			# �t�@�C�������݂��Ȃ��ꍇ
			if(!$self{'f'}){
					# �V�K�쐬
					if($type =~ /Renew/){
						Mebius::Fileout("Allow-empty",$file1);
						$self{'f'} = open($FILE1,"+<",$file1);
					}
					else{
						return(\%self);
					}
			}

	}

	# �t�@�C�����b�N
	if($type =~ /Renew|Renew-news|Flock/){ flock(2,$FILE1); }
	
# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$FILE1>);
($self{'concept'},$self{'last_get_news_time'}) = split(/<>/,$top1);

	# ���΂炭�X�V����Ă��Ȃ��ꍇ (A-1)
	if($type =~ /(Allow-renew-news)/ && time > $self{'last_get_news_time'} + ($under_interval)){
		$type .= qq( Renew-news);
	}

	# ���t�@�C����W�J(A-2)
	while(<$FILE1>){

		# ���̍s�𕪊�
		chomp;
my($key2,$account2,$diary_number2,$res_number2,$regist_time2,$regist_date2,$subject2,$last_modified2,$res2,$owner_handle2,$last_account2,$last_handle2,$owner_lastres_time2,$owner_lastres_number2,$last_get_diary_time2) = split(/<>/);

			# ���V���f�[�^�X�V�p
			if($type =~ /Renew-news/){

				# �X�V�Ԋu���`
				my($allow_get_file_flag) = Mebius::RenewStatus::allow_judge_for_get_file({ UnderIntervalSecond => $under_interval },$last_get_diary_time2,$last_modified2);

					# ���L�f�[�^���擾 ( �f�[�^�s�������Ă��܂����߁A���肪�U�̏ꍇ�� next ���Ȃ� )
					if($allow_get_file_flag){

						my($diary) = Mebius::Auth::diary("Get-hash",$account2,$diary_number2);
						$last_get_diary_time2 = time;
						$renew_file_flag = 1;

							# �L�[����
							if(!$diary->{'f'}){ next; }
							if($diary->{'concept'} =~ /Deleted/){ next; }

							# �f�[�^�X�V
							if($diary->{'subject'}){
								$subject2 = $diary->{'subject'};
								$last_modified2 = $diary->{'lastrestime'};
								$res2 = $diary->{'res'};
								$owner_handle2 = $diary->{'handle'};
								$last_account2 = $diary->{'last_account'};
								$last_handle2 = $diary->{'last_handle'};
								$owner_lastres_time2= $diary->{'owner_lastres_time'};
								$owner_lastres_number2 = $diary->{'owner_lastres_number'};
							}

					}

			}

		# �C���f�b�N�X�s�ɒǉ� (�X�V�s�ł́h�Ȃ��h���ߒ���) 
	push(@index_line,"$key2<>$account2<>$diary_number2<>$res_number2<>$regist_time2<>$regist_date2<>$subject2<>$last_modified2<>$res2<>$owner_handle2<>$last_account2<>$last_handle2<>$owner_lastres_time2<>$owner_lastres_number2<>$last_get_diary_time2<>\n");

	} 

	# �t�@�C�����Ȃ��ꍇ�͂��̂܂܃��^�[��
	if($type =~ /Get-index|Get-topics/ && !$self{'f'}){
		close($FILE1);
		return();
	}

	# ���z����\�[�g
	if($type =~ /Get-topics/){
		@index_line = sort { (split(/<>/,$b))[7] <=> (split(/<>/,$a))[7] } @index_line;
	}

	# ���t�@�C�����ēW�J
	foreach(@index_line){

		# ���E���h�J�E���^
		$i++;

		# ���̍s�𕪊�
		chomp;
my($key2,$account2,$diary_number2,$res_number2,$regist_time2,$regist_date2,$subject2,$last_modified2,$res2,$owner_handle2,$last_account2,$last_handle2,$owner_lastres_time2,$owner_lastres_number2,$last_get_diary_time2) = split(/<>/);

			# ���g�s�b�N�X�擾�p
			if($type =~ /Get-topics/ && $hit_topics < $max_view_topics){
				$self{'topics_line'} .= qq(<div>);
				$self{'topics_line'} .= qq(<a href="${main::auth_url}$account2/d-$diary_number2">$subject2</a>);
				$self{'topics_line'} .= qq( (<a href="${main::auth_url}$account2/d-$diary_number2#S$res2">$res2</a>));
				$self{'topics_line'} .= qq(�@ $last_handle2);

					#if($last_modified2 > $regist_time2 && $main::time < $last_modified2 + (1*24*60*60)){
						my($blank_time) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-�O",time - $last_modified2);
						$self{'topics_line'} .= qq(�@ $blank_time);
					#}

				$self{'topics_line'} .= qq(</div>\n);
				$hit_topics++;
			}

			# ���C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

					# �ő�\���s��
					if($i > 20){ next; }

				my($regist_time_before2) = Mebius::SplitTime("Plus-text-�O Get-top-unit",time - $regist_time2);

					$self{'index_line'} .= qq(<tr>);
					$self{'index_line'} .= qq(<td><a href="${main::auth_url}$account2/d-$diary_number2">$subject2</a>);

					$self{'index_line'} .= qq( (<a href="${main::auth_url}$account2/d-$diary_number2#S$res_number2">$res2</a>)</td>);

					$self{'index_line'} .= qq(<td><a href="${main::auth_url}$account2/">$owner_handle2 - $account2</a></td>);

					$self{'index_line'} .= qq(<td>);

						# �A�J�E���g��̐V�����X������ꍇ
						if($owner_lastres_time2 > $regist_time2 && time < $owner_lastres_time2 + (3*24*60*60)){
							my($newres_time_before2) = Mebius::SplitTime("Plus-text-�O Get-top-unit Color-view",$main::time - $owner_lastres_time2);
								$self{'index_line'} .= qq( $owner_handle2����(�A�J�E���g��)�� $newres_time_before2 �ɍX�V���܂����B);
						}

						# �V�����X������ꍇ
						if($last_modified2 > $regist_time2 && time < $last_modified2 + (3*24*60*60) && $regist_time2 != $owner_lastres_time2){
							my($newres_time_before2) = Mebius::SplitTime("Plus-text-�O Get-top-unit Color-view",$main::time - $last_modified2);
								$self{'index_line'} .= qq( $last_handle2���� $newres_time_before2 �ɍX�V���܂����B);
						}

						# �V�����X���Ȃ��ꍇ
						if($account eq $last_account2){
							my($newres_time_before2) = Mebius::SplitTime("Plus-text-�O Get-top-unit",$main::time - $regist_time2);
							$self{'index_line'} .= qq( <span style="color:#999;">���Ȃ����Ō�ɍX�V���܂����B</span>);
						}



					$self{'index_line'} .= qq(</td>);

					$self{'index_line'} .= qq(</tr>\n);

			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/ || $renew_file_flag){ 

					# �ő�L�^�s���𒴂����ꍇ
					if($i >= 50){ next; }

					# �����L���̏ꍇ
					if("$account2-$diary_number2" eq "$new_account-$new_diary_number"){
						next;
					}

				# �X�V�s��ǉ�
	push(@renew_line,"$key2<>$account2<>$diary_number2<>$res_number2<>$regist_time2<>$regist_date2<>$subject2<>$last_modified2<>$res2<>$owner_handle2<>$last_account2<>$last_handle2<>$owner_lastres_time2<>$owner_lastres_number2<>$last_get_diary_time2<>\n");

			}

	}

	# ���t�@�C���X�V�p
	if($type =~ /Renew($|[^-])/ || $renew_file_flag){

			# ���V�������Q�b�g�����ꍇ
			if($type =~ /Renew-news/){
				$self{'last_get_news_time'} = time;
			}

			# ���V�������X������ꍇ
			if($type =~ /New-res/){

				# ���L�f�[�^���擾
				my($diary) = Mebius::Auth::diary("Get-hash",$new_account,$new_diary_number);
				unshift(@renew_line,"<>$new_account<>$new_diary_number<>$new_res_number<>$main::time<>$main::date<>$diary->{'subject'}<>$main::time<>$new_res_number<>$diary->{'handle'}<>$account<>$main::myaccount{'name'}<>$diary->{'owner_lastres_time'}<>$diary->{'owner_lastres_number'}<>\n");
			}

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$self{'concept'}<>$self{'last_get_news_time'}<>\n");

		# �t�@�C���X�V
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renew_line;


	}

close($FILE1);

	# �p�[�~�b�V�����ύX
	if($type =~ /Renew($|[^-])/ || $renew_file_flag){ Mebius::Chmod(undef,$file1); }

	# ���g�s�b�N�X���擾����ꍇ
	if($type =~ /Get-topics/){
			if(!$self{'topics_line'}){
				$self{'topics_line'} = qq(�����͂���܂���B);
			}
			my($how_before_renew) =Mebius::SplitTime("Get-top-unit Plus-text-�O",$main::time - $self{'last_get_news_time'});
		$self{'topics_line'} = qq(<h3$main::kstyle_h3>\n<a href="./aview-history#DIARY">���Ȃ��̃R�����g����</a> </h3><div class="line-height-large">$self{'topics_line'}</div>\n);
			if($hit_topics >= $max_view_topics){
				$self{'topics_line'} .= qq(<div class="right">�X�V�F $how_before_renew�@<a href="./aview-history#DIARY">������������</a>�@</div>);
			}
	}

	# ���C���f�b�N�X�擾����ꍇ
	if($type =~ /Get-index/){
		$self{'index_line'} = qq(<table summary="���L�ւ̃R�����g" class="width100">$self{'index_line'}</table>);
	}

return(%self);

}





1;