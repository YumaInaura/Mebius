
use strict;
#use warnings;
package Mebius;

#-----------------------------------------------------------
# �f�[�^�𕪉����ăn�b�V���Ɗ֘A�t��
#-----------------------------------------------------------
sub file_handle_to_hash{

my($data_format,$FILE1) = @_;
my(%hash,$max_line_num,%kind,@all_line,@data_line);

	# �K�{�l�̃`�F�b�N
	if(ref $data_format ne "HASH"){ die("Perl Die! $data_format is not HASH reference"); }
	if(ref $FILE1 ne "GLOB"){ die("Perl Die! $FILE1 is not GLOB"); }

# �f�[�^�t�H�[�}�b�g�̍s���𐔂���
$hash{'line_num'} = keys %$data_format;

	# �O������w�肳�ꂽ�s�ԍ����o���o���̏ꍇ�́A�ő吔�ɍ��킹��
	for(keys %$data_format){
			if($_ > $hash{'line_num'}){
					$hash{'line_num'} = $_;
			}
	}

	# �f�[�^�̃`�F�b�N
	if($hash{'line_num'} <= 0){ die("Perl Die! Format line is none $hash{'line_num'}"); }

	# �g�b�v�f�[�^��W�J
	for my $for (1..$hash{'line_num'}){

		# �Ǐ���
		my($i);

		# �f�[�^���󂯎���Ĕz��ɑ��
		$hash{"top$for"} = <$FILE1>;
		push(@all_line,$hash{"top$for"});
		chomp $hash{"top$for"};

		# ����
		my @top_array = split (/<>/,$hash{"top$for"});
		$hash{'data_line'}{$for-1} = \@top_array;
		push(@data_line,\@top_array);

			# �z����g���ăn�b�V���Ɋ֘A�t��
			for my $KEY ( @ { $data_format->{$for} } ){
				$hash{$KEY} = $top_array[$i];
					if($KEY && $kind{$KEY}++){ close($FILE1); die("Hash '$KEY' is dupilicated "); }
				$i++;
			}

	}

$hash{'data_line_array'} = \@data_line;
$hash{'all_line'} = \@all_line;


\%hash,$FILE1;


}

#-----------------------------------------------------------
# �t�H�[�}�b�g�f�[�^����X�V�s���`
#-----------------------------------------------------------
sub data_format_to_renew_line{

my($data_format,$renew) = @_;
my(@renew_line);

	# �K�{�l�̃`�F�b�N	
	if(ref $data_format ne "HASH"){ die("Perl Die! $data_format is not HASH reference"); }
	if(ref $renew ne "HASH"){ die("Perl Die! $renew is not HASH reference"); }

# �f�[�^�t�H�[�}�b�g�̍s���𐔂���
my $line_num = keys %{$data_format};

	# �O������w�肳�ꂽ�s�ԍ����o���o���̏ꍇ�́A�ő吔�ɍ��킹��
	for(keys %$data_format){
			if($_ > $line_num){	$line_num = $_; }
	}

	# �f�[�^�̃`�F�b�N
	if($line_num <= 0){ die("Perl Die! Format line is none $line_num"); }

	# �t�H�[�}�b�g�̓W�J
	for my $for (1..$line_num){

		# �Ǐ���
		my($renew_line);

			# �z����g���ăn�b�V���Ɋ֘A�t��
			for my $hash_key (@ { $data_format->{$for} }){
				$renew_line .= qq($renew->{$hash_key}<>);
			}

			# �X�V�s������ꍇ
			if($renew_line){
				push(@renew_line,"$renew_line\n");
			}

			# �X�V�s���Ȃ��ꍇ�́A�����ɋ�؂蕶����ǉ�
			else{
				push(@renew_line,"$renew_line<>\n");
			}


	}


@renew_line;

}



#-----------------------------------------------------------
# �f�[�^�t�@�C���̃t�H�[�}�b�g ( �g���Ȃ��f�[�^���폜 )
#-----------------------------------------------------------
sub format_data_for_file {

my($hash) = @_;
my(%formated);

	if(ref $hash ne "HASH"){ die("Perl Die! Please relay HASH reference"); }
	if(!$hash){ die("Perl Die! Hash is empty."); }

	foreach(keys %$hash){
		my $KEY = $_;
			if(ref $hash->{$KEY} eq "ARRAY"){
				my @array;
					foreach my $value (@{$hash->{$KEY}}){
							($value) = Mebius::data_format_for_file_core($value);
							push(@array,$value);
						}
					$formated{$KEY} = \@array;
			}

			elsif(ref $hash->{$KEY} eq "HASH"){
				my(%hash);
					while( my($key,$value) = each(%{$hash->{$KEY}}) ){
							($hash{$KEY}{$key}) = Mebius::data_format_for_file_core($value);
					}
				$hash->{$KEY} = \%hash;
			}
			else{
				($formated{$KEY}) = Mebius::data_format_for_file_core($hash->{$KEY});
			}

	}

return(\%formated);

}

#-----------------------------------------------------------
# �����f�[�^�̍폜
#-----------------------------------------------------------
sub data_format_for_file_core{

my($value) = @_;

$value =~ s/<>|\r|\n|\0|\t//g;
$value =~ s/(<.*?>)/Mebius::delete_tag_exclution($1)/eg;

$value;

}

#-----------------------------------------------------------
# �ꕔ�������ă^�O���폜
#-----------------------------------------------------------
sub delete_tag_exclution{

my($text) = @_;

		if($text =~ /^<(br)>$/){ return $text; }

return();

}

package Mebius::Hash;

#-----------------------------------------------------------
# �n�b�V���̏�������
#-----------------------------------------------------------
sub control{

my($renew,@select_renew) = @_;
my(%self,$debug_array_count,$debug_normal_count);

	# �C�ӂ̍X�V���Ȃ��ꍇ�A���̂܂܃n�b�V�������^�[��
	if(!defined @select_renew || @select_renew <= 0){ return($renew); } # �K�� $renew ��Ԃ����ƁA�����Ȃ��΃f�[�^���e���S�ď�������Ă��܂�
	if(!defined $renew || !$renew){
		Mebius::AccessLog(undef,"Renew-hash-is-empty");
		die("Perl Die! Renew hash is empty.");
	}
	if(ref $renew ne "HASH"){ die("Perl Die! Please hand HASH Refernce."); }

# ���\����� ( �d�v�I �����ő�����Ȃ��Ɩ߂�l���S�ċ�ɂȂ�A�f�[�^���������Ă��܂��̂Œ��ӁI )
my %self = %$renew;

	# ���C�ӌ̃n�b�V�����t�@�����X��W�J
	foreach my $select_renew (@select_renew){

			# �n�b�V�����t�@�����X�𔻒� ( )
			if(ref $select_renew ne "HASH"){
					if($select_renew eq ""){ next; }
					else{ die("Perl Die! $select_renew is not HASH reference and some value is here."); }
			}

			# $renew �ɑ��݂��Ȃ��L�[�� $select_renew �ɑ��݂��Ȃ����ǂ������`�F�b�N
			foreach my $KEY ( keys %$select_renew ){
					#if(ref $select_renew->{$KEY} eq "" && !exists $renew->{$KEY} && Mebius::AlocalJudge()){ warn("Perl warn! '$KEY' is justy hash key?"); }
			}

			# �����f�[�^�̃n�b�V����S�ēW�J���܂��B
			# �����ŋ󔒂̒l��������ƁA���̃f�[�^���S�č폜����Ă��܂��̂Œ��ӁI
			foreach my $KEY ( keys %$renew ){

					# ���z��̑���
					if(ref $self{$KEY} eq "ARRAY"){

						# �f�o�b�O�p�̃J�E���^
						$debug_array_count++;

							# ���z��S�̂̏㏑��
							if(defined $select_renew->{$KEY}){
									if(ref $select_renew->{$KEY} eq "ARRAY"){
										@{$self{$KEY}} = @{$select_renew->{$KEY}};
									}
							}

							# ���v�f�̒ǉ� ( Push )
							if(defined $select_renew->{"push"}->{$KEY}){
									if(ref $select_renew->{"push"}->{$KEY} eq "ARRAY"){
											foreach my $value (@{$select_renew->{"push"}->{$KEY}}){
												push(@{$self{$KEY}},$value);
											}
									}
									else{
										push(@{$self{$KEY}},$select_renew->{"push"}->{$KEY});
									}
							}

							# ���v�f�̒ǉ� ( Unshit )
							if(defined $select_renew->{"unshift"}->{$KEY}){
									if(ref $select_renew->{"unshift"}->{$KEY} eq "ARRAY"){
											foreach my $value (@{$select_renew->{"unshift"}->{$KEY}}){
												unshift(@{$self{$KEY}},$value);
											}
									}
									else{
										unshift(@{$self{$KEY}},$select_renew->{"unshift"}->{$KEY});
									}
							}


							# ���v�f�̍폜 ( Pop )
							if(defined $select_renew->{"pop"}->{$KEY}){
									for(1 .. $select_renew->{"pop"}->{$KEY}){
										pop(@{$self{$KEY}});
									}
							}

							# ���v�f�̍폜 ( Shift )
							if(defined $select_renew->{"shift"}->{$KEY}){
									for(1 .. $select_renew->{"shift"}->{$KEY}){ 
										shift(@{$self{$KEY}});
									}
							}

							# ���C�ӂ̗v�f�ɑ��
							if(ref $select_renew->{'select'}->{$KEY} eq "ARRAY"){
									#for(0 .. @{$select_renew->{$key}}){
											#if(defined $select_renew->{$key}[$KEY]){ $self{$key}[$KEY] = $select_renew->{$key}[$KEY]; }
									#}
							}

					}

					# ���X�J���̑��� ( �l�̓��t�@�����X�ł͂Ȃ� )
					else{

						# �f�o�b�O�p�̃J�E���^
						$debug_normal_count++;

							# ���㏑��
							if(defined $select_renew->{$KEY}){
								$self{$KEY} = $select_renew->{$KEY};
							}

							# �����Z
							if(defined $select_renew->{"+"}->{$KEY}){
									if(ref $select_renew->{"+"}->{$KEY} eq "HASH"){
											while( my($key,$value) = each(%{$select_renew->{"+"}->{$KEY}}) ){
												$self{$KEY} += $select_renew->{"+"}->{$KEY};
											}
									}
									else{
										$self{$KEY} += $select_renew->{"+"}->{$KEY};
									}
							}

							# �����Z
							if(defined $select_renew->{"-"}->{$KEY}){
									if(ref $select_renew->{"-"}->{$KEY} eq "HASH"){
											while( my($key,$value) = each(%{$select_renew->{"-"}->{$KEY}}) ){
												$self{$KEY} -= $select_renew->{"-"}->{$KEY};
											}
									}
									else{
										$self{$KEY} -= $select_renew->{"-"}->{$KEY};
									}
							}

							# ����Z
							if(defined $select_renew->{"*"}->{$KEY}){
								$self{$KEY} *= $select_renew->{"*"}->{$KEY};
							}

							# �����Z
							if(defined $select_renew->{"/"}->{$KEY}){
									# 0�ł͊���Ȃ��悤��
									if($select_renew->{"/"}->{$KEY} == 0){
									}
									else{
										$self{$KEY} /= $select_renew->{"/"}->{$KEY};
									}
							}

							# �����l�������菬�����Ȃ�Ȃ��悤��
							if(defined $select_renew->{">="}->{$KEY}){
									if($self{$KEY} < $select_renew->{">="}->{$KEY}){ $self{$KEY} = $select_renew->{">="}->{$KEY}; }
							}


							# �����l��������傫���Ȃ�Ȃ��悤��
							if(defined $select_renew->{"<="}->{$KEY}){
									if($self{$KEY} > $select_renew->{"<="}->{$KEY}){ $self{$KEY} = $select_renew->{"<="}->{$KEY}; }
							}


							# ���e�L�X�g�̍폜
							if(defined $select_renew->{"s/g"}->{$KEY}){
									if(ref $select_renew->{"s/g"}->{$KEY} eq "HASH"){
											while( my($key,$value) = each(%{$select_renew->{"s/g"}->{$KEY} }) ){
												$self{$KEY} =~ s/(\s)?$value//g;
											}
									}
									else{
										$self{$KEY} =~ s!(\s)?$select_renew->{"s/g"}->{$KEY}!!g;
									}
							}


							# ���e�L�X�g�̒ǉ� ( �V )
							if(defined $select_renew->{"."}->{$KEY}){
									if(ref $select_renew->{"."}->{$KEY} eq "HASH"){
											while( my($key,$value) = each(%{$select_renew->{"."}->{$KEY} }) ){
												#$self{$KEY} =~ s/(\s)?$value//g;
												$self{$KEY} .= qq($value);
											}
									}
									else{
										#$self{$KEY} =~ s/(\s)?$select_renew->{"."}->{$KEY}//g;
										$self{$KEY} .= qq($select_renew->{"."}->{$KEY});
									}
							}


					}

			}

			# ���f�[�^�̃n�b�V����S�ēW�J���܂��B
			# �����ŋ󔒂̒l���� ( $self{$KEY} = undef; )����ƁA���̃f�[�^���S�č폜����Ă��܂��̂Œ��ӁI
			# %renew �ł͂Ȃ��� %return ����W�J���邱�ƁA�����łȂ��Ƃ���ȑO�̏����ŕύX���ꂽ�n�b�V���ɍ��킹�邱�Ƃ��o���Ȃ��̂�
			foreach my $KEY ( keys %self ){

					# �ʂ̃n�b�V������
					if(defined $select_renew->{"="}->{$KEY}){
						my $hash = $select_renew->{"="}->{$KEY};
						$self{$KEY} = $self{$hash};
					}

			}

	}


return(\%self);

}


#-----------------------------------------------------------
# �n�b�V����W�J
#-----------------------------------------------------------
sub Foreach{

my($use,$hash) = @_;
my(%data);

	# �n�b�V����W�J
	foreach my $key ( sort keys %$hash){

			# �J�E���^
			if(exists $hash->{$key}){ $data{'cont'}++; }

					# HTML���擾
					if($use->{'TypeGetHTML'}){

							if($use->{'HTMLType'} eq "List"){ $data{'html'} .= qq(<li>); }
						$data{'html'} .= qq(<strong>$key </strong>: $hash->{$key});
							if($use->{'HTMLType'} eq "List"){ $data{'html'} .= qq(</li>); }
							else{ $data{'html'} .= qq( / ); }
							$data{'html'} .= qq(\n);

			}

	}

	#if($use->{'TypeRooping'}){
	#	return(\$data);
	#}

	# ���`
	if($use->{'TypeGetHTML'}){
				if($use->{'HTMLType'} eq "List"){ $data{'html'} = qq(<ol>$data{'html'}</ol>); }
	}

return(\%data);

}


#-----------------------------------------------------------
# �n�b�V����W�J
#-----------------------------------------------------------
sub ForeachHTML{

my($use,$hash) = @_;
$use->{'TypeGetHTML'} = 1; 

my($hash_foreach) = Mebius::Hash::Foreach($use,$hash);
return($hash_foreach->{'html'});
}


1;
