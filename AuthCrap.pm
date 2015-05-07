
use strict;
package Mebius::Auth;

#-----------------------------------------------------------
# ���肷��
#-----------------------------------------------------------
sub Crap{

# �錾
my($type,$account,$file_number,$target_account) = @_;
my($i,@renew_line,%data,$file_handler,$directory2,$directory3,$file1,$topics_line,$index_line);

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

	# �t�@�C��������
	if($file_number eq "" || $file_number =~ /\D/){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
my $directory1 = $account_directory;

	# �t�@�C���I��
	if($type =~ /Diary-file/){
		$directory2 = "${directory1}crap_diary/";
		#$directory3 = "${directory2}diary_crap/";
		$file1 = "${directory2}${file_number}_dcrap.dat";
	}
	else{
		return();
	}

# �t�@�C�����J��
open($file_handler,"<$file1");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($data{'key'},$data{'count'},$data{'last_crap_time'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($key2,$lasttime2,$account2,$handle2) = split(/<>/);

			# �g�s�b�N�X���擾
			if($type =~ /Get-topics/ && $i <= 10){
				$topics_line .= qq(<a href="${main::auth_url}$account2/">$handle2</a>\n);

					# �폜�p�����N
					if($main::myaccount{'file'} eq $account2 || $main::myaccount{'file'} eq $account || $main::myadmin_flag >= 1){
						$topics_line .= qq( (<a href="${main::auth_url}$account/?mode=crap&amp;mode=crap&amp;action=delete_crap&amp;target=diary&amp;diary_number=$file_number&target_account=$account2&amp;account_char=$main::myaccount{'char'}">�폜</a>)\n);
					}
			}

			# �C���f�b�N�X���擾
			#if($type =~ /Get-index/){
			#	$index_line .= qq();
			#}

			# �V�K����
			if($type =~ /New-crap|Get-topics/){
					if($account2 eq $main::myaccount{'file'}){ $data{'craped_flag'} = 1; }
			}

			# �폜
			if($type =~ /Delete-crap/){
					if($account2 eq $target_account){ next; }
			}

			# �s��ǉ�
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$lasttime2<>$account2<>$handle2<>\n");
			}

	}

close($file_handler);

	# �n�b�V������
	if(!$data{'count'}){ $data{'count'} = 0; }

# ����
$data{'index_line'} = $index_line;
$data{'topics_line'} = $topics_line;

	# �V�K����
	if($type =~ /New-crap/){

			# �d������̏ꍇ
			if($data{'craped_flag'} && !$main::alocal_mode){ main::error("���ɔ��肵�Ă��܂��B"); }

		# �V�����s��ǉ�
		unshift(@renew_line,"<>$main::time<>$main::myaccount{'file'}<>$main::myaccount{'name'}<>\n");

		# �g�b�v�f�[�^��ύX
		$data{'count'}++;
		$data{'last_crap_time'} = $main::time;
	}

	# �폜
	if($type =~ /Delete-crap/){
		$data{'count'}--;
	}


	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory2);
		#Mebius::Mkdir(undef,$directory3);

		# �t�@�C���X�V
		unshift(@renew_line,"$data{'key'}<>$data{'count'}<>$data{'last_crap_time'}<>\n");
		Mebius::Fileout(undef,$file1,@renew_line);

	}


return(%data);

}

#-----------------------------------------------------------
# ���胉���L���O�i�����j
#-----------------------------------------------------------
sub CrapRankingDay{

# �錾
my($type,$yearf,$monthf,$dayf) = @_;
my(undef,undef,undef,undef,$max_view) = @_ if($type =~ /Get-topics/);
my(undef,undef,undef,undef,$crap_count,$account,$diary_number,$diary_subject) = @_ if($type =~ /New-crap|Delete-crap|Delete-diary/);
my($i,@renew_line,%data,$file_handler,$max_line,$rank_in_flag,$topics_line,$delete_crap_hit_flag);

# �ő�s��
my $max_line = 10;

# ������L�^����ŏ��|�C���g
my $crap_count_border = 2;

	# �ő�\���s��
	if(!$max_view){ $max_view = 10; }

	# ���^�[��
	if($yearf =~ /\D/ || $yearf eq ""){ return(); }
	if($monthf =~ /\D/ || $monthf eq ""){ return(); }
	if($dayf =~ /\D/ || $dayf eq ""){ return(); }

# �t�@�C����`
my $directory1 = "${main::int_dir}_authlog/_crap_ranking_diary/";
my $file1 = "${directory1}${yearf}_${monthf}_${dayf}_crap_ranking_diary.log";

	# �t�@�C�����J��
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		open($file_handler,"<$file1");
	}

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($data{'key'},$data{'wday'},$data{'lasttime'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# �Ǐ���
		my($not_push_flag);

		# ���E���h�J�E���^
		$i++;

		# ���̍s�𕪉�
		chomp;
		my($key2,$crap_count2,$account2,$diary_number2,$diary_subject2) = split(/<>/);

			# �g�s�b�N�X�擾�p
			if($type =~ /Get-topics/ && $i <= $max_view){
				$topics_line .= qq(<a href="${main::auth_url}$account2/d-$diary_number2">$diary_subject2</a> ($crap_count2)\n);
			}


			# �V�K����p
			if($type =~ /New-crap/){

					# �����̔��萔�𒴂��āA�����N�C���������ǂ����𔻒�
					if($crap_count > $crap_count2){
						$rank_in_flag = 1;
					}

					# �d�����𔻒�
					if("$account2-$diary_number2" eq "$account-$diary_number"){
						$not_push_flag = 1;
					}

			}


			# ������폜�����ꍇ
			if($type =~ /Delete-crap/){

					# �d�����𔻒�
					if("$account2-$diary_number2" eq "$account-$diary_number"){
						$delete_crap_hit_flag = 1;
						$not_push_flag = 1;
					}

			}

			# �s���폜����ꍇ
			if($type =~ /Delete-diary/){

					# �d�����𔻒�
					if("$account2-$diary_number2" eq "$account-$diary_number"){
						$not_push_flag = 1;
					}

			}

			# �s��ǉ�
			if($type =~ /Renew/ && $i <= $max_line && !$not_push_flag){
				push(@renew_line,"$key2<>$crap_count2<>$account2<>$diary_number2<>$diary_subject2<>\n");
			}

	}

close($file_handler);


	# �g�s�b�N�X�擾�p
	if($type =~ /Get-topics/){
			if($topics_line){ 
				$data{'topics_line'} = qq($topics_line);
			}
	}

	# ������폜�����ꍇ
	if($type =~ /Delete-crap/){
			# �����̃����L���O���������ꍇ
			if($delete_crap_hit_flag && $crap_count >= 3){
				# �V�����s��ǉ�
				unshift(@renew_line,"<>$crap_count<>$account<>$diary_number<>$diary_subject<>\n");
			}
			else{
				$data{'not_renew_flag'}	= 1;
			}
	}

	# �V�K����������L���O�o�^
	if($type =~ /New-crap/){

			# �����N�C�������ꍇ
			if(($i < $max_line || $rank_in_flag) && $crap_count >= $crap_count_border){
				Mebius::Auth::CrapRankingMonth("Renew New-ranking-in",$yearf,$monthf,$dayf);
			}
			# �����N�C�����Ȃ������ꍇ
			else{
				$data{'not_renew_flag'} = 1;
			}

		# �V�����s��ǉ�
		unshift(@renew_line,"<>$crap_count<>$account<>$diary_number<>$diary_subject<>\n");

	}

	# �t�@�C���X�V
	if($type =~ /Renew/ && !$data{'not_renew_flag'}){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);
		#Mebius::Mkdir(undef,$directory2);
		
		# �z����\�[�g
		@renew_line = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_line;

		# �j�����v�Z
		if($data{'wday'} eq ""){
			my(%date) = Mebius::TimeLocalDate(undef,$yearf,$monthf,$dayf);
			$data{'wday'} = $date{'wday'};
		}

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$data{'key'}<>$data{'wday'}<>$data{'lasttime'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file1,@renew_line);

	}


return(%data);

}

#-----------------------------------------------------------
# ���胉���L���O�i�����A�S�́j
#-----------------------------------------------------------
sub CrapRankingMonth{

# �錾
my($type,$yearf,$monthf,$dayf) = @_;
my($i,@renew_line,%data,$file_handler,$dayf_still_flag,$not_renew_flag,$index_line);

	# ���^�[��
	if($yearf =~ /\D/ || $yearf eq ""){ return(); }
	if($monthf =~ /\D/ || $monthf eq ""){ return(); }
	if($type =~ /New-ranking-in/){
			if($dayf =~ /\D/ || $dayf eq ""){ return(); }
	}

# �t�@�C����`
my $directory1 = "${main::int_dir}_authlog/_crap_ranking_diary/";
my $file1 = "${directory1}${yearf}_${monthf}_crap_ranking_diary.log";

	# �t�@�C�����J��
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		open($file_handler,"<$file1");
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
		my($key2,$dayf2) = split(/<>/);

			# �C���f�b�N�X�擾�p
			if($type =~ /Get-index/){	
	
				# �����̔��胉���L���O���擾
				my(%crap_ranking2) = Mebius::Auth::CrapRankingDay("Diary-file Get-topics",$yearf,$monthf,$dayf2,10);

				$index_line .= qq(<h3$main::kstyle_h3>$monthf/$dayf2 ($crap_ranking2{'wday'})</h3>\n);
				$index_line .= qq(<div class="line-height">$crap_ranking2{'topics_line'}</div>\n);
			}

			# ��������̏ꍇ
			if($dayf eq $dayf2){
				$dayf_still_flag = 1;
			}

			# �s��ǉ�
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$dayf2<>\n");
			}

	}

close($file_handler);

	# �C���f�b�N�X�擾�p
	if($type =~ /Get-index/){
			if($index_line){
				$data{'index_line'} = $index_line;
			}
	}

	# �V�K����
	if($type =~ /New-ranking-in/){
		# ���ɓ��ɂ����o�^����Ă���ꍇ
		if($dayf_still_flag){ $not_renew_flag = 1; }
		# �܂����ɂ����o�^����Ă��Ȃ��ꍇ
		else{ unshift(@renew_line,"<>$dayf<>\n"); }

	}


	# �t�@�C���X�V
	if($type =~ /Renew/ && !$not_renew_flag){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);

		# �z����\�[�g
		@renew_line = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_line;

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$data{'key'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);

}

1;