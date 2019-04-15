
use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# �M���P�ʂ̃t�@�C��
#-----------------------------------------------------------
sub Handle{

# �錾
my($type,$handle,$trip,$year,$monthf,$moto,$realmoto,$thread_number,$res_number,$thread_subject) = @_;
my($handle_handler,@renew_line,$still_flag,$foreach1,$thisbbs_count,$thismonth_count);

# �l�̃`�F�b�N
if($handle eq ""){ return(); }
if($moto eq "" || $moto =~ /\W/){ return(); }

# �l�̐��`
$handle =~ s/(^\s+|\s+$)//g;

# �G���R�[�h
my($handle_encoded) = Mebius::Encode(undef,$handle);
my($trip_encoded) = Mebius::Encode(undef,$trip);

# �t�@�C����`
my $base_directory = "${main::int_dir}_handle/";
my $directory = "${base_directory}_filedata_handle/";
my $file = "${directory}${handle_encoded}_${trip_encoded}.dat";

# �t�@�C�����J��
open($handle_handler,"<$file");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($handle_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$handle_handler>);
my($tconcept,$thandle,$ttrip,$tallcount,$tfirst_time,$tlast_time) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$handle_handler>){

		# �s�𕪉�
		chomp;
		my($moto2,$count2,$year2,$monthf2,$thismonth_count2) = split(/<>/);

			# �������f���̏ꍇ
			if($moto2 eq $moto){

				# ���̌f���̃J�E���g��
				$thisbbs_count = $count2;

					# ���V�K�J�E���g�p�̏���
					if($type =~ /New-count/){
						$count2++;
						$still_flag = 1;
							# �����̏ꍇ�A�����J�E���g�𑝂₷
							if("$year2-$monthf2" eq "$year-$monthf"){
								$thismonth_count2++;
							}
							# �����łȂ��ꍇ�A�����f�[�^�ɍX�V
							else{
								$thismonth_count2 = 0;
								$year2 = $year;
								$monthf2 = $monthf;
							}

					}

					# �����̃J�E���g�����L��
					if("$year2-$monthf2" eq "$year-$monthf"){
						$thismonth_count = $thismonth_count2;
					}

			}

			# ���t�@�C���X�V�p 
			if($type =~ /Renew/){
				push(@renew_line,"$moto2<>$count2<>$year2<>$monthf2<>$thismonth_count2<>\n");
			}

	}


close($handle_handler);

	# ���V�����J�E���g����ꍇ
	if($type =~ /New-count/){
		$thisbbs_count++;
		$thismonth_count++;
			# ���̌f���̋L�^���Ȃ��ꍇ�A�V�����ǉ�����
			if(!$still_flag){
				unshift(@renew_line,"$moto<>$thisbbs_count<>$year<>$monthf<>$thismonth_count<>\n");
			}
		$tallcount++;
	}

	# ���t�@�C���X�V
	if($type =~ /Renew/){

			# �f�B���N�g���쐬
			if(!$top1){
				Mebius::Mkdir(undef,$base_directory);
				Mebius::Mkdir(undef,$directory);
			}

			# �g�b�v�f�[�^�ɑ���Ȃ��v�f��ǉ�
			if($tconcept eq ""){ $tconcept = "Ok"; }
			if($thandle eq ""){ $thandle = $handle; }
			if($ttrip eq ""){ $ttrip = $trip; }
			if($tfirst_time eq ""){ $tfirst_time = $main::time; }

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$tconcept<>$thandle<>$ttrip<>$tallcount<>$tfirst_time<>$main::time<>\n");

		# �X�V
		Mebius::Fileout(undef,$file,@renew_line);

			# �f�����̃����L���O�ɓo�^����
			if($type =~ /New-count/ && $tconcept !~ /Deny-ranking/){
				Mebius::BBS::HandleRankingBBS("Renew New-count All-file",$handle,$trip,$thisbbs_count,$year,$monthf,$moto,$realmoto,$thread_number,$res_number,$thread_subject);
				Mebius::BBS::HandleRankingBBS("Renew New-count News-file",$handle,$trip,$thismonth_count,$year,$monthf,$moto,$realmoto,$thread_number,$res_number,$thread_subject);
				Mebius::BBS::HandleRankingBBS("Renew New-count Month-file",$handle,$trip,$thismonth_count,$year,$monthf,$moto,$realmoto);
			}

			# �f�����̃����L���O����폜����
			if($type =~ /Delete-handle/){
				Mebius::BBS::HandleRankingBBS("Renew Delete-handle All-file",$handle,$trip,undef,$year,$monthf,$moto);
				Mebius::BBS::HandleRankingBBS("Renew Delete-handle News-file",$handle,$trip,undef,$year,$monthf,$moto);
				Mebius::BBS::HandleRankingBBS("Renew Delete-handle Month-file",$handle,$trip,undef,$year,$monthf,$moto);
			}

	}


}


#-----------------------------------------------------------
# �M�������L���O ( �f���P�� )
#-----------------------------------------------------------
sub HandleRankingBBS{

# �錾
my($type,$handle,$trip,$new_count,$year,$monthf,$moto,$realmoto,$thread_number,$res_number,$thread_subject) = @_;
	if($type =~ /(Get-index|Dead-link-check)/){ (undef,$moto,$year,$monthf) = @_; }
my($ranking_handler,@renew_line,$keep_min_count,$i,$new_key,$still_flag,$file,$index_line,$ranking_flag,$max_line,$hit);

# �l�̃`�F�b�N
if($type =~ /(New-count|Delete-handle)/ && $handle eq ""){ return(); }
if($moto eq "" || $moto =~ /\W/){ return(); }

	# �e�탊�^�[��
	if($type =~ /New-count/){
			if($new_count <= 0){ return(); }
			#if($main::secret_mode){ return(); }				# �閧�� �� �ǂ����f�����Ō��邾���Ȃ̂ŁA�B���Ȃ��Ă��ǂ��H
			#if($main::bbs{'concept'} =~ /Not-handle-ranking/){ return(); }	# ( PV�̋֎~�ݒ�����̂܂ܗ��p ) �� �����ł̓J�E���g���ĂĂ��ǂ�
	}

# �f���t�@�C�������擾
my($bbs_file) = Mebius::BBS::InitFileName(undef,$moto);

# �f�B���N�g����`
my $directory = "$bbs_file->{'data_directory'}_handle_ranking_${moto}/";

	# �t�@�C����` - �S����
	if($type =~ /All-file/){
		$file = "${directory}${moto}_ranking_handle.log";
		$ranking_flag = 1;
		$max_line = 100;
	}
	# �t�@�C����` - ����
	elsif($type =~ /Month-file/){
		if($year eq "" || $year =~ /\D/){ return(); }
		if($monthf eq "" || $monthf =~ /\D/){ return(); }
		$file = "${directory}${moto}_ranking_handle_${year}_${monthf}.log";
		$ranking_flag = 1;
		$max_line = 30;
	}
	# �t�@�C����` - �ŋ�
	elsif($type =~ /News-file/){
		$file = "${directory}${moto}_news_handle.log";
		$max_line = 30;
	}
	# �t�@�C���w�肪�Ȃ��ꍇ
	else{
		return();
	}


# �t�@�C�����J��
my $open = open($ranking_handler,"<$file");

	# �t�@�C���̗L���`�F�b�N
	if($type =~ /File-check-return/ && !$open){ return(); }
	if($type =~ /File-check-error/ && !$open){ main::error("���̃����L���O�y�[�W�͑��݂��܂���B"); }

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($ranking_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$ranking_handler>);
my($tconcept,$tmin_count,$ti,$tlastyear,$tlastmonthf,$tlast_deadlink_checktime) = split(/<>/,$top1);

	# ���������N�؂�`�F�b�N�ŁA�O��̃`�F�b�N����܂����Ԃ��o�߂��Ă��Ȃ��ꍇ
	if($type =~ /Dead-link-check/){
			if($main::time < $tlast_deadlink_checktime + 3*24*60*60){
				close($ranking_handler);
				return();
			}
	}

	# ���܂ł̍ŏ��J�E���g�����V�K�J�E���g�������Ȃ��ꍇ�ȂǁA�����Ƀ��^�[�����ĕ��ׂ��y�� ( �����L���O���[�h�̂� )
	if($type =~ /New-count/ && $ranking_flag){
			if($ti >= $max_line && $tmin_count >= $new_count){
				close($ranking_handler);
				return();
			}
	}



	# �t�@�C����W�J
	while(<$ranking_handler>){

		# ���E���h�J�E���^
		$i++;

			# �ő�s���ɒB�����ꍇ
			if($i > $max_line){ last; }
		
		# �s�𕪉�
		chomp;
		my($key2,$count2,$handle2,$trip2,$lasttime2,$lastdate2,$realmoto2,$thread_number2,$res_number2,$thread_subject2) = split(/<>/);

			# ���������N�؂�`�F�b�N
			if($type =~ /Dead-link-check/){
					if($key2 !~ /Dead-link/){	
						my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$realmoto2,$thread_number2);
							if($thread->{'keylevel'} < 0){
								$key2 .= qq( Dead-link);
									if($type !~ /Renew/){ $type .= qq( Renew); }
							}
					}
			}

			# �t�@�C���X�V���̑O����
			if($type =~ /Renew/){
					# �ŏ��J�E���g�����L������
					if($keep_min_count eq "" || $keep_min_count > $count2){ $keep_min_count = $count2; }
			}

			# ���V�����J�E���g����ꍇ
			if($type =~ /New-count/){
					# �����M�� / �g���b�v�̏ꍇ�̓J�E���g�𑝂₷
					if("$handle2-$trip2" eq "$handle-$trip"){
						$still_flag = 1;
						$count2 = $new_count;
						$lasttime2 = $main::time;
						$lastdate2 = $main::date;
						$realmoto2 = $realmoto;
						$thread_number2 = $thread_number;
						$res_number2 = $res_number;
						$thread_subject2 = $thread_subject;
						$key2 =~ s/(\s?)Deleted//g;
					}
			}

			# ���s���폜��Ԃɂ���ꍇ
			if($type =~ /Delete-handle/){
					# �����M�� / �g���b�v�̏ꍇ�̓L�[��ύX
					if("$handle2-$trip2" eq "$handle-$trip" && $key2 !~ /Deleted/){
						$key2 .= qq( Deleted);
					}
			}


			# ���t�@�C���X�V�p
			if($type =~ /Renew/){
		# �X�V�s��ǉ�
		push(@renew_line,"$key2<>$count2<>$handle2<>$trip2<>$lasttime2<>$lastdate2<>$realmoto2<>$thread_number2<>$res_number2<>$thread_subject2<>\n");
			}

			# ���C���f�b�N�X���擾����ꍇ
			if($type =~ /Get-index/){

					# �q�b�g�J�E���^
					$hit++;

					# ��\���̏ꍇ
					if($key2 =~ /Deleted/){ next; }

					# ���o�C���ł̕\��
					if($type =~ /Mobile-view/){
						my($style_in);
							if($hit % 2 == 0){ $style_in .= qq(background:#eee;); }
						$index_line .= qq(<div style="$style_in$main::kborder_top_in">);
						$index_line .= qq($handle2);
							if($trip2){ $index_line .= qq(��$trip2); }
						$index_line .= qq( $count2��);
						$index_line .= qq(<br$main::xclose>);
						$index_line .= qq($lastdate2);
						$index_line .= qq(</div>);
					}

					# �f�X�N�g�b�v�ł̕\��
					elsif($type =~ /Desktop-view/){
						$index_line .= qq(<tr>);
						# �M��
						$index_line .= qq(<td class="hnd">);
						$index_line .= qq($handle2);
							if($trip2){ $index_line .= qq(��$trip2); }
						$index_line .= qq(</td>);

						# ���e��̋L��
						$index_line .= qq(<td class="hnd">);
							if($thread_subject2 && $key2 !~ /Dead-link/){
								$index_line .= qq(<a href="/_$realmoto2/$thread_number2.html#S$res_number2">$thread_subject2</a>);
							}
						$index_line .= qq(</td>);
						# �ŏI���t
						$index_line .= qq(<td class="hnd">);
						$index_line .= qq($lastdate2);
						$index_line .= qq(</td>);
						# ���e��
						$index_line .= qq(<td class="hnd right">);
						$index_line .= qq($count2��);
						$index_line .= qq(</td>);
						# �Z���s�I���
						$index_line .= qq(</tr>\n);
					}
			}



	}

close($ranking_handler);

	# ���V�����J�E���g����ꍇ
	if($type =~ /New-count/){

			# �V�����ǉ�����s
			if(!$still_flag){
				$i++;
	unshift(@renew_line,"$new_key<>$new_count<>$handle<>$trip<>$main::time<>$main::date<>$realmoto<>$thread_number<>$res_number<>$thread_subject<>\n");
			}

			# ��{�f�B���N�g�����쐬 ( A-1 )
			if(!$top1){
				Mebius::Mkdir(undef,$directory);
			}

			# �V�������ɓ˓������ꍇ�A���j�t�@�C�����X�V���� ( �K����{�f�B���N�g���쐬�h��h�ɏ��� ) ( A-2 )
			if($type =~ /New-count/ && $type =~ /All-file/ && "$tlastyear-$tlastmonthf" ne "$year-$monthf"){
				Mebius::BBS::HandleRankingHistoryBBS("Renew New-month",$moto,$year,$monthf);
			}

		# �Ō�̋L�^�����X�V ( A-3 )
		$tlastyear = $main::thisyear;
		$tlastmonthf = $main::thismonthf;

			# �J�E���g���������Ƀ\�[�g ( �K���g�b�v�f�[�^��ǉ�����h�O�h�� )
			if($ranking_flag){
				@renew_line = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_line;
			}
	}

	# ���t�@�C���X�V
	if($type =~ /Renew/){
			
			# �g�b�v�f�[�^��ǉ� ( �K���z����\�[�g�����h��h�� ) 
			$ti = $i;
			if($keep_min_count){ $tmin_count = $keep_min_count; }
			if($tconcept eq ""){ $tconcept = "Ok"; }
			if($type =~ /Dead-link-check/){ $tlast_deadlink_checktime = $main::time; }
		unshift(@renew_line,"$tconcept<>$tmin_count<>$ti<>$tlastyear<>$tlastmonthf<>$tlast_deadlink_checktime<>\n");
		# �X�V
		Mebius::Fileout(undef,$file,@renew_line);

	}


	# ���C���f�b�N�X��Ԃ�
	if($type =~ /Get-index/){
		my($return_index_line);
			# ���`
			if($index_line){
					# �f�X�N�g�b�v��
					if($type =~ /Desktop-view/){

						# CSS��`
						$main::css_text .= qq(table.handle_ranking{width:100%;}\n);
						$main::css_text .= qq(td.hnd,th.hnd{padding:0.3em 0.5em;}\n);
						$main::css_text .= qq(th.res_count{width:4.5em;}\n);

						# ���`
						$return_index_line .= qq(<table summary="���e�������L���O" class="handle_ranking bbs">\n);
						$return_index_line .= qq(<tr>);
						$return_index_line .= qq(<th>�M��</th>);
						$return_index_line .= qq(<th>�ŏI���e</th>);
						$return_index_line .= qq(<th>�ŏI���t</th>);
						$return_index_line .= qq(<th class="res_count">���e��</th>);
						$return_index_line .= qq(</tr>);
						$return_index_line .= qq($index_line);
						$return_index_line .= qq(</table>\n);

					}
					# ���o�C����
					elsif($type =~ /Mobile-view/){
						$return_index_line = $index_line;
					}
			}
		return($return_index_line);
	}

}

#-----------------------------------------------------------
# �M�������L���O�̌��L�^�t�@�C��
#-----------------------------------------------------------
sub HandleRankingHistoryBBS{

# �錾
my($type,$moto,$year,$monthf) = @_;
my($history_handler,@renew_line,$still_flag,$index_line);

# �l�̃`�F�b�N
if($moto eq "" || $moto =~ /\W/){ return(); }
	if($type =~ /Renew/){
		if($year eq "" || $year =~ /\D/){ return(); }
		if($monthf eq "" || $monthf =~ /\D/){ return(); }
	}


# �f���t�@�C�������擾
my($bbs_file) = Mebius::BBS::InitFileName(undef,$moto);

# �t�@�C����`
my $directory = "$bbs_file->{'data_directory'}_handle_ranking_${moto}/";
my $file = "${directory}${moto}_history_handle.log";

# �t�@�C�����J��
open($history_handler,"<$file");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($history_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$history_handler>);
my($tconcept) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$history_handler>){

		# ���̍s�𕪉�
		chomp;
		my($year2,$monthf2) = split(/<>/);

		# �C���f�b�N�X���擾
		if($type =~ /Get-index/){
				if("$year2-$monthf2" eq "$year-$monthf"){
					$index_line .= qq($year2�N$monthf2��\n);
				}
				else{
					$index_line .= qq(<a href="ranking-$year2-$monthf2.html">$year2�N$monthf2��</a>\n);
				}

		}

		# �������̓o�^������ꍇ
		if("$year2-$monthf2" eq "$year-$monthf"){
			$still_flag = 1;
		}

		# �X�V�s��ǉ�
		if($type =~ /Renew/){
			push(@renew_line,"$year2<>$monthf2<>\n");
		}

	}

close($history_handler);

	# �V�������̍s��ǉ�����
	if($type =~ /New-month/){
		if($still_flag){ return(); }
		else{ unshift(@renew_line,"$year<>$monthf<>\n"); }
	}


	# �t�@�C�����X�V
	if($type =~ /Renew/){
		unshift(@renew_line,"$tconcept<>\n");
		Mebius::Fileout(undef,$file,@renew_line);
	}


	# �C���f�b�N�X��Ԃ�
	if($type =~ /Get-index/){
		return($index_line);
	}
}


1;
