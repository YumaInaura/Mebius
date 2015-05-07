
use Mebius::Emoji;
use Mebius::Parts;
package main;
use strict;

#-----------------------------------------------------------
# �g��Adsense���擾
#-----------------------------------------------------------
sub kadsense{

# �錾
my($type) = @_;
my($line1,$line2,$prace_view);

	# �d���������֎~
	if($main::done{'kadsense_get'}){ return(); }

	# �L����\�����Ȃ��ꍇ
	if($main::noads_mode){ return(); }

	# ���[�J���̏ꍇ
	elsif($main::alocal_mode){ $line1 = $line2 = qq(�L�� $type); }

	# �L����\������ꍇ
	else{

			# PC->�Ǘ��҂̏ꍇ�́A�L���̏��݂�����킷�\�����ǉ�
			if($main::myadmin_flag >= 5){ $prace_view = qq(�L�� $type); }

		require "${main::int_dir}k_adsense.pl";
		my($ads1,$ads2) = main::do_kadsense($type);

			if($ads1){ $line1 = qq($prace_view$ads1); }
			if($ads2){ $line2 = qq($prace_view$ads2); }

	}

# �d�������֎~�t���O�𗧂Ă�
$main::done{'kadsense_get'} = 1;

return($line1,$line2);

}

#-----------------------------------------------------------
# �g�є� �����N����
#-----------------------------------------------------------
sub kauto_link{

# �錾
my($type,$comment,$thread_number,$res_number) = @_;
my($comment_split,$return_comment,$maxline_omit,$maxlength_omit,$comment_length_half,$omit_flag);
my($round,$omited_length,$omit_move,$omited_comment,$not_omited_length,$not_omited_comment,$omited_length_while,$return_omitlink);
our($concept,$realmoto);

	# �����`�F�b�N
	$thread_number =~ s/\D//g;
	$res_number =~ s/\D//g;

	# �{���ȗ����̐ݒ�
	$maxline_omit = 15;		# �ő�s��
	$maxlength_omit = 250;	# �ő啶����(�S�p)

	# �N�b�L�[�ݒ肪����ꍇ�A�{���̏ȗ�臒l��ύX
	if($type !~ /Preview/ && $main::ccut ne "0" && $main::ccut){

		$maxline_omit *= $main::ccut;
		$maxlength_omit *= $main::ccut;
	}


	# �]�v�ȉ��s���폜
	if($type =~ /Loose/){ $comment =~ s/(<br>){5,}/<br><br><br><br><br>/g; }
	else{ $comment =~ s/(<br>){3,}/<br><br><br>/g; }

# �����A�����̉��s���폜
$comment =~ s/^(<br>)+//g;
$comment =~ s/(<br>)+$//g;

	# �^�O������ꍇ�A�{�����ȗ����Ȃ��i�^�O����h���j
	if($comment =~ /<strong>/){ $type .= qq( Not-omit); }

	# ���s�^�O���g�їp��
	if($type !~ /Fix/){
		$comment =~ s/<br>/<br$main::xclose>/g;
	}

	# ���{�����P�s���W�J
	foreach $comment_split (split(/<br$main::xclose>/,$comment)){

		# ���E���h�J�E���^
		$round++;

		# �]�v�ȑS�p�X�y�[�X���폜
		$comment_split =~ s/^(�@|\s){2,}/�@�@/g;
		$comment_split =~ s/(�@|\s){2,}/�@�@/g;

		# �{���̕��������v�Z
		$comment_length_half += length $comment_split;

			# �摜�ɕ����O��ǉ�
			if($type !~ /Fix/){
					if($main::bbs{'concept'} =~ /Upload-mode/){ $comment_split =~ s/<img (.+?)>/<img $1$main::xclose>/g;
			}

		# HTTP �����N��ϊ�
		($comment_split) = Mebius::auto_link($comment_split);
			# ���X�ԃ����N
			if($thread_number){
				if($concept =~ /MODE-DELETE/){ $comment_split =~ s/No\.([0-9]+)(([,-])([0-9,]+)||$)/<span style="color:#f00;">#$1$2<\/span>/g; }
				else{ $comment_split =~ s/No\.([0-9]+)(([,-])([0-9,]+)||$)/<a href=\"$thread_number.html-$1$2#RES\">#$1$2<\/a>/g; }
			}

			# ���[���A�h���X�������N
			if($main::allowaddress_mode){
				$comment_split =~ s/([0-9a-z]+)\@([0-9a-z]+)\.([0-9a-z\.]+)/<a href=\"mailto:$1\@$2\.$3\">$1\@$2\.$3<\/a>/g; }
			}


			# ���̑��̏C��
			if($type =~ /Fix/){
				$comment_split =~ s/\?mode=my/\?mode=my&amp;k=1/g;
			}

			# ���y�t�@�C��
			if($realmoto =~ /^(ams|asx)$/){
				$comment_split =~ s/\/msc\/([a-z0-9_\-]+)\.mp3/\/_main\/?mode=msc-play&amp;file=$1&amp;k=1/g;
			}

			# ���s�A�������Ń��X�ȗ�
			if($type =~ /Omit/){

					# �O���[�v�ŕ\���ő�l�𒴂��Ă����ꍇ�A���̍s�͏ȗ��s�Ƃ��Ĉ���
					if($omit_flag){
						$omited_length += int(length($comment_split)/2);
						$omited_comment .= qq(<br$main::xclose>$comment_split);	
						$omit_flag = 2;
						next;
					}

					# �O���[�v�ŕ\���ő�l���z���Ă��Ȃ��ꍇ�A�{���[�v������
					else{

							# �ő���s�ɒB�����ꍇ�A���t���O�𗧂Ă�
							if($round > $maxline_omit){
								$omit_flag = 1; 
								$omit_move = qq(#R$round);
							}
							

							# �ő啶���ɒB�����ꍇ�A���t���O�𗧂Ă�
							if($comment_length_half >= $maxlength_omit*2){
								$omit_flag = 1; 
								$omit_move = qq(#R$round);

							}

							# �{���i�ȗ��Ȃ��j�ɉ��s��ǉ�
							if($round >= 2){ $return_comment .= qq(<br$main::xclose>); }

							# �����܂Œ�������
							# �����͑S�̂��������I�[�o�[���Ă��āA�Ȃ������̂P�s�������ꍇ�A�P�s������ɍׂ����������� 
							if($comment_length_half >= $maxlength_omit*2 && length($comment_split) >= $maxlength_omit*2*0.5){

								# �Ǐ���
								my($comment_length_while_half,$round_while,$not_split_comment_while);
								my $comment_split_while = $comment_split;
								my $comment_length_prev_half = $comment_length_half - length($comment_split);	# �O��܂ł̍��v���������v�Z

									# ���̂P�s����蕶���ŕ���
									while($comment_split_while =~ /(.+?)(�A|�B|�@)+?/g){

										# ���E���h�J�E���^�Q�A�������v�Z
										$round_while++;
										$comment_length_while_half += length($&);

											# �ȗ�����ꍇ ( ���̂P�s�̕������{���̋�؂蕶�͂̕����������l���z�����ꍇ )
											if($comment_length_while_half + $comment_length_prev_half >= $maxlength_omit*2*1.25 && $round_while >= 2){
												$omited_comment .= qq($1$2);
												$omit_flag = 2;
												$omited_length += int(length($&) / 2);
											}

											# �ȗ����Ȃ��ꍇ
											else{
												$return_comment .= qq($1$2);
											}

										# ��؂�Ȃ��������L��
										$not_split_comment_while = $';
									}

									# �P����������Ȃ������ꍇ�A���̍s�����̂܂܎g��
									if($round_while <= 0){ $return_comment .= qq($comment_split_while); }

									# ��؂�Ȃ����������𖖔��ɒǉ�
									elsif($omit_flag == 2){
										$omited_comment .= qq($not_split_comment_while);
										$omited_length += int(length($') / 2);
									}
									else{
										$return_comment .= qq($not_split_comment_while);
									}

							}

							# ���ʂɖ{����ǉ�����ꍇ
							else{
								$return_comment .= qq($comment_split);
							}
					}
			}
	
			# ���^�[���{����ǉ� ( ���Ƃ��Əȗ����Ȃ����[�h�̏ꍇ )
			else{
					if($round >= 2){ $return_comment .= qq(<br$main::xclose>); }
					if($type =~ /Resone/){ $return_comment .= qq(\n<a id="R$round"></a>); }
				$return_comment .= qq($comment_split);
			}

	}

	# ���{�����ȗ�����ꍇ
	if($type =~ /Omit/ && $omit_flag == 2){

		# �ȗ��������̒���
		$omited_length += $omited_length_while;

		# ���������N��ǉ�
		$return_comment =~ s/<br$main::xclose>$//g;
			if($res_number ne "" && $type =~ /Thread/){
				$return_omitlink = qq(<a href="$thread_number.html-$res_number$omit_move" id="C$main::no">��$omited_length</a>);
			}

		# �v���r���[�̏ꍇ�A�ǂ�����ȗ�����邩�𕪂���悤��
		if($type =~ /Omit/ && $type =~ /Preview/){
			$return_comment .= qq(<br$main::xclose><br$main::xclose>
				<em>����ȏ�͏ȗ��\\������܂� \($maxline_omit�s�ȏ� or $maxlength_omit�����ȏ�\)</em><br$main::xclose>$omited_comment);
		}

	}

	# �s���̉��s���폜
	$return_comment =~ s/(<br$main::xclose>+)$//g;

# ���^�[��
return($return_comment,$omit_flag,$return_omitlink);

}

1;

