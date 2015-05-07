
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# �V�K�L�������쐬����
#-----------------------------------------------------------
sub NewCharacterMake{

# �錾
my($init) = &Init();
my($type,$use) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my($jobflag,%renew,$new_job,$plustype_renew,$id,$FileType);

	# �t�@�C����`
	if($use->{'FileType'} eq "Account"){ $FileType = "Account"; }
	elsif($use->{'FileType'} eq "Cookie"){ $FileType = "Cookie"; }
	else{ main::error("�쐬����A�J�E���g�̎�ނ��s���ł��B"); }

	# ID���`
	if($use->{'id'}){ $id = $use->{'id'}; }
	else{ main::error("ID���w�肵�Ă��������B"); }

	# ���O������
	if($use->{'name'}){
		$renew{'name'} = $use->{'name'};

	}
	else{
		$renew{'name'} = "���������L�����N�^�[";
	}

	# ���ʂ�����
	if($use->{'sex'} =~ /^(0|1)$/){
		$renew{'sex'} = $use->{'sex'};
	}
	else{
			if(rand(2) <= 1){ $renew{'sex'} = 1; } else { $renew{'sex'} = 0; }
	}

$renew{'hp'} = $renew{'maxhp'} = int(($init->{'kiso_status'}) + (rand(20) + 1)) + $init->{'kiso_hp'};

# �e��|�C���g
$renew{'exp'} = 0;
$renew{'level'} = 1;
$renew{'all_level'} = 1;
$renew{'sp'} = $init->{'kiso_sp'};
$renew{'gold'} = 100;
$renew{'mons'} = $init->{'sentou_limit'};

# �����X�e�[�^�X
$renew{'karman'} = int(rand(15));
$renew{'power'} = $init->{'kiso_status'} + int rand(4);
$renew{'brain'} = $init->{'kiso_status'} + int rand(4);
$renew{'believe'} = $init->{'kiso_status'} + int rand(4);
$renew{'vital'} = $init->{'kiso_status'} + int rand(4);
$renew{'tec'} = $init->{'kiso_status'} + int rand(4);
$renew{'speed'} = $init->{'kiso_status'} + int rand(4);
$renew{'charm'} = $init->{'kiso_status'} + int rand(4);

	# �E�Ƃ̎�ނ�����
	if($use->{'job'} =~ /^(0|1|2|3)$/){
		$new_job = $use->{'job'};
	}
	else{
		$new_job = 0;
	}

# �E�ƃf�[�^���擾
require Mebius::Adventure::Job;
my($advjobname,$advjobrank,$advspatack,$advspodds,$advjobmatch,$advjobconcept) = &JobRank($new_job,1);
my($jobflag,$jobline) = &SelectJob("NEWFORM",$new_job,\%renew);
my($jobnumber,$jobname,$a,$b,$c,$d,$e,$f,$g,$advspatack,$advspodds) = split(/<>/,$jobline);

# �E�ƂŁ[�^���`
$renew{'job'} = $new_job;
$renew{'jobname'} = $jobname;
$renew{'jobrank'} = $advjobrank;
$renew{'jobmatch'} = $advjobmatch;
$renew{'jobconcept'} = $advjobconcept;
$renew{'spatack'} = $advspatack;
$renew{'spodds'} = $advspodds;

# 0����n�܂鐔�l
$renew{'win'} = 0;
$renew{'draw'} = 0;
$renew{'gold'} = 0;
$renew{'exp'} = 0;
$renew{'total'} = 0;
$renew{'autobank'} = 0;
$renew{'bank'} = 0;
$renew{'brave'} = 0;
$renew{'job_change_count'} = 0;

# �s���p��Char
($renew{'char'}) = Mebius::Crypt::char(undef,50);

# �����f�[�^
$renew{'first_time'} = time;

($renew{'first_host'}) = Mebius::GetHostWithFile();
#($renew{'first_mobile_id'}) = Mebius::GetMobileId({ host => $renew{'first_host'}});
$renew{'first_agent'} = Mebius::escape(undef,$ENV{'HTTP_USER_AGENT'});

# �L�����N�^�t�@�C�����쐬
&File("New-character Renew $plustype_renew",{ FileType => $FileType , id => $use->{'id'} },\%renew);

# �L�����N�^�[�t�@�C�����ēx�ǂݍ���
my($advmy) = &File("Base-mydata",{ FileType => $FileType , id => $id , my_id => $id });

return($advmy);


}

1;
