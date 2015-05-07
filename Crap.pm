
use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# ����t�@�C��
#-----------------------------------------------------------
sub crap_file{

return();

my $use = shift if(ref $_[0] eq "HASH");
my($target_bbs,$thread_number) = @_;
my($FILE1,%self,$renew,@renew_line,%data_format);
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($target_bbs);
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($my_access) = Mebius::my_access();

	if($target_bbs =~ /\W/ || $target_bbs eq ""){ return(); }
	if($thread_number =~ /\D/ || $thread_number eq ""){ return(); }

# �t�@�C����`
if(!$init_bbs->{'data_directory'}){ die("Perl Die! Can't decide data directory."); }
	my $directory = "$init_bbs->{'data_directory'}_crap_count_${target_bbs}/";
	my $counter_file = "${directory}${thread_number}_cnt.cgi";

	# �t�@�C�����J�� �i�K�v�ȏꍇ�̓t�@�C�����b�N�j
	my($FILE1,$read_write) = Mebius::File::read_write($use,$counter_file,$directory);
		if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }

# �f�[�^�\�����`
$data_format{'1'} = [('count','last_time','xips','cnumbers','res')];
$data_format{'2'} = [('old_count','old_reason')];

	# �g�b�v�f�[�^��ǂݍ���
	my($split_data) = Mebius::file_handle_to_hash(\%data_format,$FILE1);
	%self = (%self,%$split_data);

	while(<$FILE1>){

		my($done_flag);

		chomp;
		my($key2,$handle2,$id2,$trip2,$comment2,$account2,$host2,$cnumber2,$age2,$lasttime2,$date2,$res2,$deleter2,$addr2) = split(/<>/);

			# �t���O
			if(time < $lasttime2 + 24*60*60){
					if($my_account->{'id'} eq $account2 && $account2){ $done_flag = 1; }
					if($my_cookie->{'char'} eq $cnumber2 && $cnumber2){ $done_flag = 1; }
					if($my_access->{'mobile_uid'} && $my_access->{'multi_user_agent'} eq $age2 && $age2){ $done_flag = 1; }
					if($ENV{'REMOTE_ADDR'} eq $addr2 && $addr2){ $done_flag = 1; }
					if($done_flag){
						$self{'done_flag'} = 1;
							if($comment2){ $self{'comment_done_flag'} = 1; }
					}
			}

			if($use->{'Renew'}){

					# ��莞�Ԉȏ�o�߂��Ă���R�����g�Ȃ��̃f�[�^�s�͍폜����
					if($key2 eq "" && time > $lasttime2 + 7*24*60*60){
						0;	
					} else {
						push(@renew_line,"$key2<>$handle2<>$id2<>$trip2<>$comment2<>$account2<>$host2<>$cnumber2<>$age2<>$lasttime2<>$date2<>$res2<>$deleter2<>\n");
					}
			}

	}

	# �X�V�֎~�t���O�𗧂Ă�
	# �A�����ĐV��������͏o���Ȃ��悤��
	if($use->{'NewCrap'} && $self{'done_flag'} && !Mebius::AlocalJudge()){
		$self{'not_renew_flag'} = 1;
	}
	# �R�����g����ꍇ�A�ȑO�ɔ��肵�Ă��Ȃ��ƃR�����g�ł��Ȃ��悤��
	elsif($use->{'NewComment'} && !$self{'done_flag'}){
		$self{'not_renew_flag'} = 1;
	}

	# �t�@�C���X�V
	if($use->{'Renew'} && !$self{'not_renew_flag'}){

			# �V�����s��ǉ�
			if($use->{'new_line'}){
				unshift(@renew_line,$use->{'new_line'});
			}


		# �C�ӂ̍X�V�ƃ��t�@�����X��
		($renew) = Mebius::Hash::control(\%self,$use->{'select_renew'});

		# �f�[�^�t�H�[�}�b�g����t�@�C���X�V
		Mebius::File::data_format_to_truncate_print(\%data_format,$FILE1,$renew,\@renew_line);

	}

close($FILE1);

	if($use->{'Renew'} && $renew){
		return($renew);
	} else{
		return(\%self);
	}

}


#-----------------------------------------------------------
# ���X������擾 ( ���g�p )
#-----------------------------------------------------------
sub ResCrap{

# �錾
my($type,$realmoto,$thread_number) = @_;
my($i,@renew_line,%data,$file_handler,%res_crap);

	# �����`�F�b�N
	if($realmoto eq "" || $realmoto =~ /\W/){ return(); }
	if($thread_number eq "" || $thread_number =~ /\D/){ return(); }

# �t�@�C����`
my $directory1 = "${main::int_dir}_res_crap/";
my $directory2 = "${directory1}_${realmoto}_res_crap/";
my $file1 = "${directory2}${thread_number}_res_crap.log";

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
		my($mycrap_flag);

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($key2,$res_number2,$crap_count2,$accounts2) = split(/<>/);

			# �A�J�E���g��W�J
			foreach(split(/\s/,$accounts2)){
				if($_ eq $main::myaccount{'file'}){ $mycrap_flag = 1; }
			}


			# ���L���Ƃ̔��萔�ƍ��p
			if($type =~ /Get-crap/){
				$res_crap{"crap_count_$res_number2"} = $crap_count2;
				$res_crap{"craped_flag_$res_number2"} = $mycrap_flag;
			}


			# �s��ǉ�
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$res_number2<>$crap_count2<>$accounts2<>\n");
			}

	}

close($file_handler);

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);
		Mebius::Mkdir(undef,$directory2);

		# �t�@�C���X�V
		unshift(@renew_line,"$data{'key'}<>\n");
		Mebius::Fileout(undef,$file1,@renew_line);

	}

# �n�b�V����Ԃ�
if($type =~ /Get-crap/){ return(%res_crap); }
else{ return(%data); }


}


1;

1;
