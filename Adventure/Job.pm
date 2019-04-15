
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# �E�ƈꗗ
#-----------------------------------------------------------
sub ViewJob{

# �Ǐ���
my($init) = &Init();
my($init_login) = init_login();
my($line,$form,$selects,$guard_gold,$print);
our($advmy);

# ���L�����̃X�e�[�^�X
my($jobflag,$jobline,$job_select,$job_list) = &SelectJob("",$advmy->{'job'},$advmy);

# ����̈��p���ɂ����邨��
my $guard_gold = $advmy->{'level'}*$init->{'itemguard_gold'};

# �J���}
my($guard_gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$guard_gold]);

$print .= qq(<h1>�E�ƃ��X�g</h1>);
$print .= qq($init_login->{'link_line'});

	# �]�E�t�H�[��
	if($advmy->{'login_flag'}){

			my($adv_gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$advmy->{'gold'}]);

		$print .= qq(
		<h2>�]�E����</h2>
		<div class="line_height">
		�]�E����ƑS�ẴX�e�[�^�X����b�l ( <span style="color:#f00;">$init->{'kiso_status'}</span> ) �ɖ߂�A���x���P����̃X�^�[�g�ɂȂ�܂��B<br$main::xclose>
		�������u�ő�HP�v�u�J���}�v�u�������v�u�a���z�v�u���݂̌o���l�v�͂��̂܂܈����p����܂��B<br><br>
		</div>
		<form action="$init->{'script'}" method="post" class="zero">
		<div>
		���E�F $advmy->{'jobname'} / ���܂ł̓]�E��: $advmy->{'job_change_count'}�� <br><br>
		$job_select
		<input type="submit" value="���̐E�Ƃɓ]�E����">
		<span class="alert">���]�E�ɂ� $guard_gold_comma\G �̏Љ��������܂��B ( ���݂̏����� $adv_gold_comma G )</span>
		<input type="hidden" name="id" value="$advmy->{'id'}">
		<input type="hidden" name="char" value="$advmy->{'char'}">
		<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
		<input type="hidden" name="mode" value="jobchange">
		</div>
		</form>
		);
	}

# �E�ƃ��X�g
$print .= qq(
<h2>�]�E�ɕK�v�ȃp�����[�^</h2>
$job_list
);

$print .= qq(</div>);


Mebius::Template::gzip_and_print_all({ BodyPrint => 1 ,BCL => ["�E��"] },$print);


exit;

}


#-----------------------------------------------------------
# �]�E�����s
#-----------------------------------------------------------
sub JobChange{

# �Ǐ���
my($init) = &Init();
my($init_login) = init_login();
my($jobline,$firstlv,$flag,%renew);
our($advmy);

# CSS��`
$main::css_text .= qq(
div.message{line-height:1.4;}
form.{margin-top:1em;}
);

	# �e��G���[
	if($main::in{'job'} eq 'no') { main::error("�E�Ƃ�I�����Ă��������B"); }

my $job = $main::in{'job'};
my $id = $main::in{'id'};

# �L�����t�@�C�����J��
my($adv) = &File("Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} });

# �Љ
my $jobchange_price = $adv->{'level'}*$init->{'itemguard_gold'};
	if($adv->{'gold'} - $jobchange_price < 0 && !Mebius::alocal_judge()){ main::error("�]�E�̂��߂̏Љ������܂���B $adv->{'gold'}G / ${jobchange_price}G"); }

# ���Ɠ����E�Ƃ�I�񂾏ꍇ
if($main::in{'job'} eq $adv->{'job'} && !$main::alocal_mode){ main::error("���ɂ��̐E�Ƃł��B"); }

# �p�����[�^������Ȃ��ꍇ
my($jobflag,$jobline) = &SelectJob("",$main::in{'job'},$adv);
if(!$jobflag){ main::error("�]�E����ɂ̓p�����[�^������܂���B"); }

# �E���A�K�E�Z�Ȃǂ��擾
my($newjobname,$newjobrank,$newspatack,$newspodds,$newjobmatch,$newjobconcept) = &JobRank($main::in{'job'},1);

	# �E�Ə�񂪂Ȃ��ꍇ

$renew{'-'}{'gold'} = $jobchange_price;
$renew{'jobname'} = $newjobname;
$renew{'jobrank'} = $newjobrank;
$renew{'jobmatch'} = $newjobmatch;
$renew{'jobconcept'} = $newjobconcept;
$renew{'spatack'} = $newspatack;
$renew{'spodds'} = $newspodds;
$renew{'='}{'hp'} = "maxhp";

# �e��ݒ�
$renew{'job'} = $job;

# ���x���Ȃǂ��P�ɖ߂�
$renew{'level'} = 1;
$renew{'top_monster_level'} = 0;

# ��b�p�����[�^�ɖ߂�
$renew{'power'} = $init->{'kiso_status'};
$renew{'brain'} = $init->{'kiso_status'};
$renew{'believe'} = $init->{'kiso_status'};
$renew{'vital'} = $init->{'kiso_status'};
$renew{'tec'} = $init->{'kiso_status'};
$renew{'speed'} = $init->{'kiso_status'};
$renew{'charm'} = $init->{'kiso_status'};

# �J�E���^�𑝂₷
$renew{'+'}{'job_change_count'} = 1;

# �L�����t�@�C���X�V
&File("Renew Mydata Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

my $print = qq(
<h1>$renew{'jobname'}�ɓ]�E���܂����I</h1>
$init_login->{'link_line'}
���ꂩ��V�����l�����n�܂�܂��B
$init->{'continue_button'}
);

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# ���̐E�ƂɂȂ�邩�ǂ������`�F�b�N
#-----------------------------------------------------------
sub SelectJob{

# �Ǐ���
my($type,$select_job,$adv) = @_;
my($init) = &Init();
my($flag,$jobline,$job_select,$job_list,$class1,$my_skills,$onskill_flag);
my($job_handler,@jobnames);

# CSS��`
$main::css_text .= qq(
.gray{background:#ddd;}
.myjob{background:#ff9;}
.jobguide{font-size:90%;line-height:1.4;}
);

# �\�͂�Δ䂷��ꍇ
if($adv->{'power'} || $adv->{'brain'} || $adv->{'believe'} || $adv->{'vital'} || $adv->{'tec'} || $adv->{'speed'} || $adv->{'charm'}){ $onskill_flag = 1; }

# �E�ƃt�@�C�����J��
open($job_handler,"<$init->{'adv_dir'}_job_data_adventure/job1.dat") || die("Perl Die! Job Data File is not here.");

	# �t�@�C����W�J
	while(<$job_handler>){

		# ���̍s�𕪉�
		chomp;
		my($class1,$status_full_flag);
		my($jobnumber,$jobname2,$power,$brain,$believe,$vital,$tec,$speed,$charm,$spatack,$spodds,$sex2,$jobguide,$jobmatch,$jobconcept2) = split(/<>/);

			# �E�Ɩ��݂̂��擾����ꍇ
			if($type =~ /Get-jobname/){
				push(@jobnames,$jobname2);
				next;
			}

			# �Y���E�Ƃ̃f�[�^���擾����ꍇ
			if($select_job eq $jobnumber){ $jobline = $_; }

			# �]�E/�A�E�ł��邩�ǂ������`�F�b�N
			if($adv->{'power'} >= $power && $adv->{'brain'} >= $brain && $adv->{'believe'} >= $believe && $adv->{'vital'} >= $vital && $adv->{'tec'} >= $tec && $adv->{'speed'} >= $speed && $adv->{'charm'} >= $charm){
				$status_full_flag = 1;
			}
 
			if($status_full_flag && 
				(
				(!$sex2)
				|| ($sex2 eq "male" && $adv->{'sex'} eq "1")
				|| ($sex2 eq "female" && $adv->{'sex'} eq "0")
				)

			){	
					if($select_job eq $jobnumber){ $flag = 1; $jobline = $_; }
					else{ $job_select .= qq(<option value="$jobnumber">$jobname2</option>\n); }
			}
				elsif($onskill_flag){ $class1 = qq( class="gray"); }
			$job_list .= qq(<tr$class1><td>$jobname2</td><td>$power</td><td>$brain</td><td>$believe</td><td>$vital</td><td>$tec</td><td>$speed</td><td>$charm</td><td class="jobguide">$jobguide</td></tr>\n);
	}
close($job_handler);

	# ���^�[��
	if($type =~ /Get-jobname/){
		return(@jobnames);
	}

$job_select = qq(
<select name="job">
<option value="no">�E��</option>
$job_select
</select>
);

	# �����̔\�͂�\��
	if($adv->{'power'}){
		$my_skills .= qq(<tr class="me">);
		$my_skills .= qq(<td>���Ȃ��̔\\��</td>);
		$my_skills .= qq(<td>$adv->{'power'}</td><td>$adv->{'brain'}</td><td>$adv->{'believe'}</td><td>$adv->{'vital'}</td>);
		$my_skills .= qq(<td>$adv->{'tec'}</td><td>$adv->{'speed'}</td><td>$adv->{'charm'}</td><td></td></tr>\n);
	}

$job_list = qq(
<table summary="�E�ƃ��X�g" class="adventure">
<tr><th>�E��</th><th>��</th><th>�m\�\\</th><th>�M�S</th><th>������</th><th>��p��</th><th>����</th><th>����</th><th class="jobguide">����</th></tr>
$my_skills
$job_list
</table>
);



return($flag,$jobline,$job_select,$job_list);

}


#-----------------------------------------------------------
# �E�ƃ����N���擾
#-----------------------------------------------------------
sub JobRank{

# �Ǐ���
my($job,$level) = @_;
my($jobrank,$class,@jobranks);

# �E�ƕʂ̃N���X
if($job == 0){ @jobranks = ('���܂˂�','�ɂ񂶂�','���Ⴊ����','���̗p�S�_','���p�J��','�n���̖Ҏ�','�P�O�O�l�a��','��R����','�q�[���[','���O�̗��؂�','���q�[���['); } # ��m
elsif($job == 1){ @jobranks = ('��i�t','�����p�}�j�A','�n�����̎�����','�閧��m���','���݌������','�Ђ��������炷��','�Í��̋~����','�`���̖����t','�`���̑喂���t','�΂��Ԃ�','�`���̗������t'); } # ���@�g��
elsif($job == 2){ @jobranks = ('�����v���[���g','�M�S�ȐM��','����̃s�A�j�X�g','�s��̃q�[���[','�Ў�Ԗq�t','�����}�X�^�[','�l�C�q�t','�傢�Ȃ�\��','�_�̎g��','�_�̉�','�_�̒�'); } # �m��
elsif($job == 3){ @jobranks = ('���K�D�_','�X��','�D�_�E�̌W��','�D�_��̒��ԊǗ��E','�D�_����','�`��','���p���P�P��','�P���ΐ�܉E�q��','�`���̑�D�_','����','�`���̗��D�_'); } # ����
elsif($job == 4){ @jobranks = ('���l�悵','�l�����̃v��','��̂��C�ɓ���','�������W���[','�΃����W���[','�����W���[','�������W���[','�ԃ����W���[','����Ɨ�','���Ȕj�Y','�`�F�[���X�I�[�i�['); } # �����W���[
elsif($job == 5){ @jobranks = ('�˂�˂�ˁ[���','���g�}�X������','�A�~�m�_����','���w����','����������','�l�̎���','������','������','�_�̎x�z��','�⍇��','������'); } # �B���p�t
elsif($job == 6){ @jobranks = ('�������\���O','�H�ド�C�u','���ςݎ���','���ڂ̃f�r���[','�q�b�g���C�J�[','�~���I���Z���[','�v���`�i���R�[�h','�O���~�[��','�`���̃|�b�v�X�^�[','����グ�X�����v','���̃r�[�g���Y'); } # ��V���l
elsif($job == 7){ @jobranks = ('����','�X�|','�ڊo��','��Y','���]','��]','����','����','���','���','���'); } # 
elsif($job == 8){ @jobranks = ('�����ȗd��','�S�̗��l','����������','�C�f�A�̔j��','���̌���','�_�b�َ̑�','���Ȃ鐺','���_�̉��g','���[�O�i�[�̗��l','�o�b�n�̈��l','�x�[�g�[�x���̍�'); } # �����L���[��
elsif($job == 9){ @jobranks = ('�f�p�Ȓ����','�삯�o���̐M��','���f�̓`����','���d�̓n���M','�l�S�����̎�','�̑�Ȃ鍼�\�t','�N���̓V��','���̖@��','�����̎x�z��','�_���N���X�̌�','�j�Ő��O'); } # �i��
elsif($job == 10){ @jobranks = ('�܂܂��ƃ��[�h','���̖��̂����','�R�m�̒[����','���ʂ̋R�m','�R�m���̋�','���̋߉q��','����������','���̎�','�`���̌N��','�`���̒��N��','�`���̗��N��'); } # �N��
elsif($job == 11){ @jobranks = ('�����΂炲����','�����񂲂��ނ炢','�|���m��','�ؓ��m��','����','�����Ȗl','�E�ς̋�','���ʂ��Ƃƌ�������','�`���̕��m','�݂˂����ŎE��','�{�{�������n�G�̂悤��'); }
elsif($job == 12){ @jobranks = ('�ւȂ��傱�p���`','�L�ȂŃp���`','�W���u','���t�b�N','�E�X�g���[�g','�J�~�\���A�b�p�[','�_�u���p���`','�g���v���p���`','�[���`���b�v','�����L�b�N','�Ђ悱�T�u��'); } # �����N
elsif($job == 13){ @jobranks = ('�����̂т�����','�݂Ȃ炢�ɂ񂶂�','���E','���E','��E','�E�ғ�','�Ö􎞑�','�ꍑ�̌��J��','�`���̔E��','�a100�l�E��','�D�c�M���̈ÎE��'); } # �E��
elsif($job == 14){ @jobranks = ('�悿�悿�_���X','�݂��񔠃_���T�[','�H��̃_���T�[','����m��','�o�b�N�_���T�[','���C���_���T�[','������q�_���T�[','�`���̃_���T�[','���[���E�H�[�N','�A���E�h�D�E�g����'); } # �x��q

	# �E�ƃN���X����
	if($level >= 100000) { $class = $jobranks[10]; }
	elsif($level >= 50000) { $class = $jobranks[9]; }
	elsif($level >= 10000) { $class = $jobranks[8]; }
	elsif($level >= 5000) { $class = $jobranks[7]; }
	elsif($level >= 1000) { $class = $jobranks[6]; }
	elsif($level >= 500){ $class = $jobranks[5]; }
	elsif($level >= 250){ $class = $jobranks[4]; }
	elsif($level >= 100){ $class = $jobranks[3]; }
	elsif($level >= 50){ $class = $jobranks[2]; }
	elsif($level >= 20){ $class = $jobranks[1]; }
	else{ $class = $jobranks[0]; }

	# �E���Ȃǂ��擾
	my($jobname,$jobline) = &SelectJob("",$job);
	my($advjobnumber,$advjobname,$advpower,$advbrain,$advbelieve,$advvital,$advtec,$advspeed,$advcharm,$advspatack,$advspodds,$advjobsex,$advjobguide,$advjobmatch,$advjobconcept) = split(/<>/,$jobline);

# ���l���ŏI��`
$jobrank = $class;

# ���^�[��
return($advjobname,$jobrank,$advspatack,$advspodds,$advjobmatch,$advjobconcept);

}


1;



1;
