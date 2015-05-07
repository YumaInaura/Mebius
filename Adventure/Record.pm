
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# �A���L�^�t�@�C��
#-----------------------------------------------------------
sub Record{

# �錾
my($type,$maxview,$newhandle,$newcount,$new_id) = @_;
my($init) = &Init();
my($filehandle_winner,$logfile,$index_line,$top1,$i,$renew_hitflag,@renew_line);
my($topwinner_handle,$topwinner_count,$do_renew_flag);

	# �����`�F�b�N�ƃ��^�[��
	if($type =~ /Renew/){
		$newcount =~ s/\D//g;
			if($newcount eq ""){ return(); }
			if($newhandle eq ""){ return(); }
	}

	# �C���f�b�N�X�̍ő�擾�s����ݒ�
	if(!$maxview){ $maxview = 10; }

# �t�@�C����`
$logfile = "$init->{'adv_dir'}_log_adv/winner_record.log";

# �t�@�C���������ꍇ�͍��
if($type =~ /Renew/ && !-f $logfile){ Mebius::Fileout("NEWMAKE",$logfile); }

# ���A���L�^�t�@�C�����J��
open($filehandle_winner,"+<$logfile");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($filehandle_winner,2); }

# �g�b�v�f�[�^�𕪉�
$top1 = <$filehandle_winner>; chomp $top1;
($topwinner_handle,$topwinner_count) = split(/<>/,$top1);

	# �ō��A���L�^���C���f�b�N�X�ɒǉ�
	$index_line .= qq(<li>$topwinner_handle �F $topwinner_count�A�� ( �ō��L�^ )</li>);

	# �t�@�C����W�J����
	while(<$filehandle_winner>){
	
	# ���[�v�J�E���^
	$i++;

	# �e�s�𕪉�����
	chomp;
	my($handle2,$count2,$year2,$month2,$id2) = split(/<>/);

		# ���t�@�C�����X�V����ꍇ
		if($type =~ /Renew/){
				if($year2 eq $main::thisyear && $month2 eq $main::thismonth){
					$renew_hitflag = 1;
						if($newcount > $count2){
							$handle2 = $newhandle;
							$count2 = $newcount;
							$id2 = $new_id;
							$do_renew_flag = 1;
						}
				}
			push(@renew_line,"$handle2<>$count2<>$year2<>$month2<>$id2<>\n");
		}

		# ���C���f�b�N�X���擾
		if($type =~ /Index/){
			my $id_link;
				if($id2){ $id_link = qq( ( <a href="$init->{'script'}?mode=status&amp;id=$id2">$id2</a> ) ); }
				if($i >= $maxview){ last; }
			$index_line .= qq(<li>$handle2 $id_link �F $count2�A�� ( $year2�N$month2�� )</li>);
		}

		# ���P�s���擾
		#if($type =~ /Oneline/){
		#	if($i >= $maxview){ last; }
		#$index_line .= qq($handle2 �F $count2�A�� ($year2�N$month2��));
		#}

	}

	# �t�@�C�����X�V����ꍇ�A�g�b�v�f�[�^�A�Z�J���h�f�[�^��ǉ�
	if($type =~ /Renew/){

		# �����̃f�[�^���Ȃ��ꍇ�́A���̂܂܋L�^����
		if(!$renew_hitflag){
			unshift(@renew_line,"$newhandle<>$newcount<>$main::thisyear<>$main::thismonth<>$new_id<>\n");
			$do_renew_flag = 1;
		}
	
		# �ō��̘A���L�^���X�V���ꂽ�ꍇ
		if($newcount > $topwinner_count){
			$topwinner_count = $newcount;
			$topwinner_handle = $newhandle;
			$do_renew_flag = 1;
		}

	# �g�b�v�f�[�^��ǉ�
	unshift(@renew_line,"$topwinner_handle<>$topwinner_count<>\n");

	}

	# �t�@�C�����X�V
	if($type =~ /Renew/ && $do_renew_flag){
		seek($filehandle_winner,0,0);
		truncate($filehandle_winner,tell($filehandle_winner));
		print $filehandle_winner @renew_line;
	}

# �t�@�C�������
close($filehandle_winner);

	# �p�[�~�b�V������ύX
	if($type =~ /Renew/){ Mebius::Chmod(undef,$logfile); }

	# �e�탊�^�[��
	if($type =~ /Index/){
			if($index_line){ $index_line = qq(<ul>$index_line</ul>); }
		return($index_line);
	}

	# �g�b�v�A���҂����^�[��
	if($type =~ /Topwinner/){ return($topwinner_handle,$topwinner_count); }
	
	# �X�V�����ꍇ�̃��^�[��
	if($type =~ /Renew/){ return(1); }

}


#-----------------------------------------------------------
# �A���L�^�̃C���f�b�N�X
#-----------------------------------------------------------
sub ViewRecord{

# �錾
my($index_line);
my($init) = &Init();
my($init_login) = init_login();

# �A���L�^���擾
($index_line) = &Record("Index",200);


# HTML
my $print  =qq(
<h1>�A���L�^</h1>
$init_login->{'link_line'}
<h2>���X�g</h2>
$index_line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}


1;

