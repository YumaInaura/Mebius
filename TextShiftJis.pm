

use strict;
package Mebius;

#-----------------------------------------------------------
# �X�y�[�X�Ȃǂ��폜
#-----------------------------------------------------------
sub delete_all_space{

my($self) = @_;

$self =~ s/( |�@|\0|\s|\n|\r)//ig;

$self;

}

#-----------------------------------------------------------
# �������v�Z
#-----------------------------------------------------------
sub GetLength{

# �錾
my($type,$text) = @_;
my($length);

	$text =~ s/<br>//g;

	$length = int(length($text)/2);

# ���^�[��
return($length);

}

package Mebius::Text;


#-----------------------------------------------------------
# �X�y�[�X�̏���
#-----------------------------------------------------------
sub DeleteSpace{

my($type,$text) = @_;

$text =~ s/(��|��|\s|�@|<br>)//g;

return($text);

}


#-----------------------------------------------------------
# ���̗͂ގ��x�𔻒� ( �P�s )
#-----------------------------------------------------------
sub SimilarJudge{

# �錾
my($type,$text,$keyword) = @_;
my($hit_point);

# �L�[���[�h���`
my $judge_text = $text;
my $judge_keyword = $keyword;

# shift_jis�̕������euc�ɕϊ�
#$judge_text = &jcode::euc($judge_text, 'sjis');
#$judge_keyword = &jcode::euc($judge_keyword, 'sjis');

# �L�[���[�h���̑啶������������
($judge_text) = Mebius::Text::KeywordAdjust(undef,$judge_text);
($judge_keyword) = Mebius::Text::KeywordAdjust(undef,$judge_keyword);

	# ���[�J���p�̕ϊ��`�F�b�N
	#if($main::alocal_mode && $judge_text =~ /�j�q/){ main::error("$judge_text / $judge_keyword"); }

# �e�L�X�g/�L�[���[�h�����݂��Ȃ��ꍇ�̓��^�[��
if($judge_text eq ""){ return(); }
if($judge_keyword eq ""){ return(); }

# �P�������Ń|�C���g�𑝂₷
if($judge_text =~ /\Q$judge_keyword\E/i){ $hit_point += 15; }
if($judge_keyword =~ /\Q$judge_text\E/i){ $hit_point += 5; }

	# ���O����L�[���[�h
	if($type =~ /Cut-keyword/){
		$judge_text =~ 		s/(�ɂ���|�f����|����|�X��|�D����|�ł�)//g;
		$judge_keyword =~	s/(�ɂ���|�f����|����|�X��|�D����|�ł�)//g;
	}

	# �ގ�������s��Ȃ��ꍇ
	if($type =~ /Strict-search/){ return($hit_point); }

# ���肷��ŏ��o�C�g��
my $min_length = 4;
if(length($judge_text) < $min_length || length($judge_keyword) < $min_length){ return($hit_point); }

	# �L�[���[�h��W�J(��)
	for($min_length .. length($judge_keyword)){
		my $keyword2 = substr($judge_keyword,$_-$min_length,$_);
			if($keyword2 && $judge_text =~ /\Q$keyword2\E/){
				$hit_point++;
			}
	}

	# �L�[���[�h��W�J(�t)
	for($min_length .. length($judge_text)){
		my $text2 = substr($judge_text,$_-$min_length,$_);
			if($text2 && $judge_keyword =~ /\Q$text2\E/){
				$hit_point++;
			}
	}

return($hit_point);

}

#-----------------------------------------------------------
# �L�[���[�h�����p�̋��ʃL�[���[�h���`
#-----------------------------------------------------------
sub KeywordAdjust{

# �錾
my($type,$text) = @_;

($text) = Mebius::Number(undef,$text);
($text) = Mebius::Text::Alfabet("All-to-half",$text);
($text) = Mebius::Text::HiraKanaAdjust(undef,$text);
$text = lc $text;

return($text);

}

package Mebius::Text;

#-----------------------------------------------------------
# �^�C�g�����X�}�t�H�Ή���
#-----------------------------------------------------------
sub SmartTitle{

# �錾
my($subject) = @_;

# �u������
$subject =~ s/^(\s|�@)+//g;
$subject =~ s/(\s|�@)+$//g;

return($subject);

}


#-----------------------------------------------------------
# �s���̉��s���폜
#-----------------------------------------------------------
sub DeleteHeadSpace{

# �錾
my($type,$text) = @_;
my($return_text,$text_foreach);

	# �P�s���W�J
	foreach $text_foreach (split/<br$main::xclose>/,$text,-1){

			# �]�v�ȑS�p�X�y�[�X���폜
			$text_foreach =~ s/\s+/ /g;
			$text_foreach =~ s/^(�@|\s){2,}/�@/g;
			$text_foreach =~ s/(�@|\s){2,}/�@/g;
			$return_text .= qq($text_foreach<br$main::xclose>);
	}

return($return_text);


}


#-----------------------------------------------------------
# �S�p�����𔼊p������
#-----------------------------------------------------------
sub OneByte{

# �錾
my($type,$text) = @_;

($text) = Mebius::Number(undef,$text);
($text) = Mebius::Text::Alfabet("All-to-half",$text);

return($text);


}

#-----------------------------------------------------------
# �S�p�J�i/���p�J�i/�Ђ炪�Ȃ����ʉ�
#-----------------------------------------------------------
sub HiraKanaAdjust{

# �錾
my($type,$text) = @_;

# �Ђ炪�Ȃ���J�^�J�i��
$text =~ s/��/�A/g;
$text =~ s/��/�C/g;
$text =~ s/��/�E/g;
$text =~ s/��/�G/g;
$text =~ s/��/�I/g;
$text =~ s/��/�J/g;
$text =~ s/��/�L/g;
$text =~ s/��/�N/g;
$text =~ s/��/�P/g;
$text =~ s/��/�R/g;
$text =~ s/��/�T/g;
$text =~ s/��/�V/g;
$text =~ s/��/�X/g;
$text =~ s/��/�Z/g;
$text =~ s/��/�\\/g;
$text =~ s/��/�^/g;
$text =~ s/��/�`/g;
$text =~ s/��/�c/g;
$text =~ s/��/�e/g;
$text =~ s/��/�g/g;
$text =~ s/��/�i/g;
$text =~ s/��/�j/g;
$text =~ s/��/�k/g;
$text =~ s/��/�l/g;
$text =~ s/��/�m/g;
$text =~ s/��/�n/g;
$text =~ s/��/�q/g;
$text =~ s/��/�t/g;
$text =~ s/��/�w/g;
$text =~ s/��/�z/g;
$text =~ s/��/�}/g;
$text =~ s/��/�~/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/�K/g;
$text =~ s/��/�M/g;
$text =~ s/��/�O/g;
$text =~ s/��/�Q/g;
$text =~ s/��/�S/g;
$text =~ s/��/�U/g;
$text =~ s/��/�W/g;
$text =~ s/��/�Y/g;
$text =~ s/��/�[/g;
$text =~ s/��/�]/g;
$text =~ s/��/�_/g;
$text =~ s/��/�a/g;
$text =~ s/��/�d/g;
$text =~ s/��/�f/g;
$text =~ s/��/�h/g;
$text =~ s/��/�o/g;
$text =~ s/��/�r/g;
$text =~ s/��/�u/g;
$text =~ s/��/�x/g;
$text =~ s/��/�{/g;
$text =~ s/��/�p/g;
$text =~ s/��/�s/g;
$text =~ s/��/�v/g;
$text =~ s/��/�y/g;
$text =~ s/��/�|/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/��/g;
$text =~ s/��/�@/g;
$text =~ s/��/�B/g;
$text =~ s/��/�D/g;
$text =~ s/��/�F/g;
$text =~ s/��/�H/g;
$text =~ s/��/�b/g;
$text =~ s/��/��/g;

# ���p�J�i����S�p�J�i��
$text =~ s/��/�K/g;
$text =~ s/��/�M/g;
$text =~ s/��/�O/g;
$text =~ s/��/�Q/g;
$text =~ s/��/�S/g;
$text =~ s/��/�U/g;
$text =~ s/��/�W/g;
$text =~ s/��/�Y/g;
$text =~ s/��/�[/g;
$text =~ s/��/�]/g;
$text =~ s/��/�_/g;
$text =~ s/��/�a/g;
$text =~ s/��/�d/g;
$text =~ s/��/�f/g;
$text =~ s/��/�h/g;
$text =~ s/��/�o/g;
$text =~ s/��/�r/g;
$text =~ s/��/�u/g;
$text =~ s/��/�x/g;
$text =~ s/��/�{/g;
$text =~ s/��/�p/g;
$text =~ s/��/�s/g;
$text =~ s/��/�v/g;
$text =~ s/��/�y/g;
$text =~ s/��/�|/g;


$text =~ s/�/�A/g;
$text =~ s/�/�C/g;
$text =~ s/�/�E/g;
$text =~ s/�/�G/g;
$text =~ s/�/�I/g;
$text =~ s/�/�J/g;
$text =~ s/�/�L/g;
$text =~ s/�/�N/g;
$text =~ s/�/�P/g;
$text =~ s/�/�R/g;
$text =~ s/�/�T/g;
$text =~ s/�/�V/g;
$text =~ s/�/�X/g;
$text =~ s/�/�Z/g;
$text =~ s/�/�\\/g;
$text =~ s/�/�^/g;
$text =~ s/�/�`/g;
$text =~ s/�/�c/g;
$text =~ s/�/�e/g;
$text =~ s/�/�g/g;
$text =~ s/�/�i/g;
$text =~ s/�/�j/g;
$text =~ s/�/�k/g;
$text =~ s/�/�l/g;
$text =~ s/�/�m/g;
$text =~ s/�/�n/g;
$text =~ s/�/�q/g;
$text =~ s/�/�t/g;
$text =~ s/�/�w/g;
$text =~ s/�/�z/g;
$text =~ s/�/�}/g;
$text =~ s/�/�~/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/��/g;
$text =~ s/�/�@/g;
$text =~ s/�/�B/g;
$text =~ s/�/�D/g;
$text =~ s/�/�F/g;
$text =~ s/�/�H/g;
$text =~ s/�/�b/g;

# �L���̕ϊ�
$text =~ s/�I/!/g;
$text =~ s/�H/\?/g;
$text =~ s/�@/\s/g;
$text =~ s/\Q�[\E/-/g;

# ���^�[��
return($text);

}

package Mebius;

#-----------------------------------------------------------
# �S�p�����𔼊p������
#-----------------------------------------------------------
sub Number{

my($type,$check) = @_;

$check =~ s/�P/1/g;
$check =~ s/�Q/2/g;
$check =~ s/�R/3/g;
$check =~ s/�S/4/g;
$check =~ s/�T/5/g;
$check =~ s/�U/6/g;
$check =~ s/�V/7/g;
$check =~ s/�W/8/g;
$check =~ s/�X/9/g;
$check =~ s/�O/0/g;

$check =~ s/��/1/g;
$check =~ s/�j/2/g;
$check =~ s/�O/3/g;
$check =~ s/�l/4/g;
$check =~ s/��/5/g;
$check =~ s/�Z/6/g;
$check =~ s/��/7/g;
$check =~ s/��/8/g;
$check =~ s/��/9/g;
$check =~ s/�\\/10/g;
$check =~ s/�S/100/g;
$check =~ s/��/1000/g;
$check =~ s/��/10000/g;

return($check);

}

#-----------------------------------------------------------
# �����ɃJ���}��t����
#-----------------------------------------------------------
sub Comma{

# �錾
my($type,@check) = @_;

	# �J���}��t����
	foreach(@check){
		while($_ =~ s/(.*\d)(\d\d\d)/$1,$2/){};
	}

# ���^�[��
return(@check);

}

#-----------------------------------------------------------
# ���{���J���}
#-----------------------------------------------------------
sub japanese_comma{

my @comma = Mebius::MultiComma({ Language => "Japanese" },\@_);

@comma;

}
#-----------------------------------------------------------
# ��������
#-----------------------------------------------------------
sub MultiComma{

# �錾
my($use,$check) = @_;
my(@comma,$foreach,%language_reed,$language_flag);

	# ������W�J
	if($use->{'Language'} eq "Japanese"){
		$language_reed{'4'} = "��";
		$language_reed{'8'} = "��";
		$language_reed{'12'} = "��";
		$language_reed{'16'} = "��";

			# �f�R�[�h�̏ꍇ
			if($use->{'TypeDecodeComma'}){
					$language_reed{'3'} = '��';
					$language_reed{'2'} = '�S';
			}

		$language_flag = 1;
	}

	# �J���}���f�R�[�h����
	if($use->{'TypeDecodeComma'}){

			# �J���}
			if($language_flag){

					# ���ׂĂ̔z���W�J
					foreach $foreach (@$check){

						# �Ǐ���
						my($point,$reed_foreach);
						my $number_foreach = $foreach;

						# ���ʂ̃J���}���폜
						$number_foreach =~ s/,//g;

							# ���ׂĂ̒P�ʂ�W�J
							foreach $reed_foreach (keys %language_reed){
								
									# �u�����{���v���u�����v�ɕϊ� ( �n�b�V���� key �� value ���t�����ɏ������Ă���̂Œ��� )
									while($number_foreach =~ s/((\-)?([0-9]+)(\.[0-9]+)?)$language_reed{$reed_foreach}//){
										$point += ($1)*(10**$reed_foreach);
									}

							}

							# �c��������
							if($number_foreach =~ s/((\-)?([0-9]+)(\.[0-9]+)?)//){ $point += $1; }

						push(@comma,$point);

					}


			}

		return(@comma);

	}

	# ���J���}��t����
	else{

			# ����J���}�ɂ���ꍇ
			if($language_flag){

					# ���ׂĂ̔z���W�J
					foreach (@$check){

						# �Ǐ���
						my($i,$line,$split,$tail,$minus);

						# �J���}���폜
						( my $foreach = $_) =~ s/,//g;

							# �����̐��K�`�F�b�N
							if($foreach =~ /^(\-)?([0-9]+)(\.([0-9]+))?$/){
								$minus = $1;
								$foreach = $2;
								$tail = $3;
							}
							# ���K�łȂ��ꍇ�͏������Ȃ� ( next ��������� return @array �̒l���Y���Ă��܂��̂ŁA�����ł����� push @array ���Ă��� )
							else{
								push(@comma,undef);
								next;
							}

						# �ꕶ������������؂�
						my(@split) = split(//,$foreach);

								# �ꕶ������؂���������W�J ( reverse ���Ȃ��������܂����������H )
								foreach $split (@split){

										$i++;
										$line .= $split;

										# ���݂̌���
										my $reed = @split - $i;

											if($language_reed{$reed}){ $line .= qq($language_reed{$reed}); }

								}

								# �����_�����Ƃɖ߂�
								if($tail){ $line .= "$tail"; }

								# �}�C�i�X�����ɖ߂�
								if($minus){ $line = "$minus$line"; }

							# ���`�ς݂̃J���}
							push(@comma,$line);
					}

			}

			# ���E���ʃJ���}
			else{

					# �J���}��t����
					foreach(@$check){
						while($_ =~ s/(.*\d)(\d\d\d)/$1,$2/){};
						push(@comma,$_);
					}

			}

		return(@comma);

	}

}


#-----------------------------------------------------------
# �����ɂ���
#-----------------------------------------------------------
sub IntNumber{

# �錾
my($type,@numbers) = @_;
my(@inited_numbers);

	# ������W�J
	foreach(@numbers){
		my($inited_number);
			# ���l���J���̏ꍇ
			if(!$_){
				push(@inited_numbers,0);
			}
			# ���l�̏ꍇ
			else{
				$inited_number = int $_;
				push(@inited_numbers,$inited_number);
			}
	}

return(@inited_numbers);

}


#-----------------------------------------------------------
# �J���̒l�Ƀ[����������
#-----------------------------------------------------------
sub DefineNumber{

# �錾
my($type,@numbers) = @_;
my(@inited_numbers);

	# ������W�J
	foreach(@numbers){
			# ���l���J���̏ꍇ
			if($_ =~ /^([0-9]+)(\.[0-9]+)?$/){
				push(@inited_numbers,$_);
			}
			# ���l�̏ꍇ
			else{
				push(@inited_numbers,0);
			}
	}

return(@inited_numbers);

}


package Mebius::Text;

#-----------------------------------------------------------
# �A���t�@�x�b�g��S�p�������p�ϊ�
#-----------------------------------------------------------
sub Alfabet{

# �錾
my($type,$check) = @_;

	# �S�p���甼�p��
	if($type =~ /All-to-half/){

		# �啶��
		$check =~ s/�`/A/g;
		$check =~ s/�a/B/g;
		$check =~ s/�b/C/g;
		$check =~ s/�c/D/g;
		$check =~ s/�d/E/g;
		$check =~ s/�e/F/g;
		$check =~ s/�f/G/g;
		$check =~ s/�g/H/g;
		$check =~ s/�h/I/g;
		$check =~ s/�i/J/g;
		$check =~ s/�j/K/g;
		$check =~ s/�k/L/g;
		$check =~ s/�l/M/g;
		$check =~ s/�m/N/g;
		$check =~ s/�n/O/g;
		$check =~ s/�o/P/g;
		$check =~ s/�p/Q/g;
		$check =~ s/�q/R/g;
		$check =~ s/�r/S/g;
		$check =~ s/�s/T/g;
		$check =~ s/�t/U/g;
		$check =~ s/�u/V/g;
		$check =~ s/�v/W/g;
		$check =~ s/�w/X/g;
		$check =~ s/�x/Y/g;
		$check =~ s/�y/Z/g;

		# ������
		$check =~ s/��/a/g;
		$check =~ s/��/b/g;
		$check =~ s/��/c/g;
		$check =~ s/��/d/g;
		$check =~ s/��/e/g;
		$check =~ s/��/f/g;
		$check =~ s/��/g/g;
		$check =~ s/��/h/g;
		$check =~ s/��/i/g;
		$check =~ s/��/j/g;
		$check =~ s/��/k/g;
		$check =~ s/��/l/g;
		$check =~ s/��/m/g;
		$check =~ s/��/n/g;
		$check =~ s/��/o/g;
		$check =~ s/��/p/g;
		$check =~ s/��/q/g;
		$check =~ s/��/r/g;
		$check =~ s/��/s/g;
		$check =~ s/��/t/g;
		$check =~ s/��/u/g;
		$check =~ s/��/v/g;
		$check =~ s/��/w/g;
		$check =~ s/��/x/g;
		$check =~ s/��/y/g;
		$check =~ s/��/z/g;

		# ����
		($check) = Mebius::Number(undef,$check);

	}

# ���^�[��
return($check);

}


#-----------------------------------------------------------
# �s�M�̕��͂̏d���A�ގ������`�F�b�N
#-----------------------------------------------------------
sub Duplication{

# �錾
my($type,$text1,$text2) = @_;
my($duplication_flag,$text1_split,$text2_split,$same_hit,$i_text1,$i_text2);
my($text_lines,$max_like_percent);

	# ���g���Ȃ��ꍇ
	if($text1 eq ""){ return(); }
	if($text2 eq ""){ return(); }

# �����╶��������폜���� ( ����ɓ����H )
(my $text1_strange_deleted = $text1) =~ s/(^[\w\s]+|[\w\s]+$)//ig;
(my $text2_strange_deleted = $text2) =~ s/(^[\w\s]+|[\w\s]+$)//ig;

# ����̂��߂̋L���폜
(my $text1_space_deleted = $text1) =~ s/\s|�@|<br>//ig;
(my $text2_space_deleted = $text2) =~ s/\s|�@|<br>//ig;

	# ���͂��S�������ꍇ
	if($text1_space_deleted eq $text2_space_deleted) {
		$duplication_flag = "same";
	}

	# ���͂��S�������ꍇ ( �p�������폜��̃}�b�` )
	elsif($text1_strange_deleted eq $text2_strange_deleted && length($text1_strange_deleted) >= 10 && length($text1_strange_deleted) >= 10) {
		$duplication_flag = "same";
		# CCC
		Mebius::AccessLog(undef,"Dupulication-error-strange-words-deleted-after");
	}

	# �ގ��d���`�F�b�N
	elsif (length($text1) >= 2*100 && length($text2) >= 2*100) {
			if($text1_space_deleted =~ /\Q$text2_space_deleted\E/ || $text2_space_deleted =~ /\Q$text1_space_deleted\E/){
				$duplication_flag = "like";
			}
	}

	# �P�s���̗ގ��`�F�b�N
	if(!$duplication_flag && $type !~ /Not-line-check/){

			# ���͂��̂P��W�J
			foreach $text1_split (split(/<br>/,$text1)){
					if(length($text1_split) < 5*2){ next; }
				$i_text1++;

					# ���͂��̂Q��W�J
					foreach $text2_split (split(/<br>/,$text2)){
							if(length($text2_split) < 5*2){ next; }
							if($text1_split eq $text2_split){ $same_hit++; last; }
					}
			}

			# ���͂��̂Q�̍s�����v�Z
			foreach $text2_split (split(/<br>/,$text2)){
					if(length($text2_split) < 3*2){ next; }
				$i_text2++;
			}

		# ����
		# �����͂̍s���i��̂����ŏ��Ȃ����j���`
		$text_lines = $i_text1;
			if($i_text2 <= $text_lines){ $text_lines = $i_text2; }
			# ���͓��̈��s���ȏオ�����ł���ꍇ
			if($type =~ /Light-judge/){ $max_like_percent = 0.85; }
			else{ $max_like_percent = 0.75; }
			if($same_hit >= 5 && ($same_hit >= $i_text1 * $max_like_percent)){ $duplication_flag = "line - $same_hit/$i_text1 - type1"; }
			if($same_hit >= 5 && ($same_hit >= $i_text2 * $max_like_percent)){ $duplication_flag = "line - $same_hit/$i_text2 - type2"; }
			# �������ɁA���s���ȏオ�����ł���ꍇ (�e���v�����g���Ă���ꍇ�A���S�ɒe����Ă��܂����ۃA��)
			#if($same_hit >= 10){ $duplication_flag = "line - $same_hit/$text_lines"; }
	}

return($duplication_flag);

}

package Mebius;

#-----------------------------------------------------------
# ID�𕪊�
#-----------------------------------------------------------
sub SplitEncid{

my($type,$encid) = @_;

# ���^�[��
if($encid =~ /[^\w\-\.\/\=]/){ return(); }

	# ����
	if($encid =~ /^(([a-zA-Z0-9]+)?(\-|\=))?([a-zA-Z0-9\.\/]+)((_)([a-zA-Z0-9\.\/]+))?$/){
		my $device_encid = $2;
		my $pure_encid = $4;
		my $option_encid = $7; 
		return($device_encid,$pure_encid,$option_encid);

	}

return();

}


#-----------------------------------------------------------
# �댯�ȃ^�O���֎~
#-----------------------------------------------------------
sub DangerTag{

# �錾
my($type,$text) = @_;
my($danger_flag);

#img|

	# �^�O����
	if($text =~ /
				<(\s*)
				(script|iframe|html|body|head|input|xmp|plaintext|meta|isindex|form|object|title|comment|applet|noembed|listing
				|noframes|noscript|style|marquee|textarea)
				/ix){
		$danger_flag = $2;
	}

	# �^�O�ޔ���
	if($text =~ /(onload)/i){
		$danger_flag = "���ߍ���";
	}


	# ���̂܂܃G���[�ɂ���ꍇ
	if($type =~ /Error-view/ && $danger_flag){
		main::error("�댯�ȃ^�O ( $danger_flag ) ���܂܂�Ă��邽�߁A�ύX�ł��܂���B");
	}

return($danger_flag);

}


1;
