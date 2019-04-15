
use strict;
package Mebius::RenewStatus;

#-----------------------------------------------------------
# �t�@�C���擾�̊Ԋu
#-----------------------------------------------------------
sub allow_judge_for_get_file{

my $use = shift if(ref $_[0] eq "HASH");
my $last_getfile_localtime = shift;
my $last_modified_localtime = shift;
my($allow_flag,$interval_second);

	if(@_ >= 1){ die("Perl Die! Too Many Value was relayed. @_"); }

	# �O��̎擾���Ȃ��ꍇ�́A�������Ɏ擾
	if(!$last_getfile_localtime || !$last_modified_localtime){ return(1); }

# �O��t�@�C�������ɍs�������u���̃X���b�h���X�V����Ă��Ȃ������b���v���v�Z
my $gyap_time = $last_getfile_localtime - $last_modified_localtime;

	# �X���b�h���X�V����Ă��Ȃ������b�������ɁA�������N�_�Ƃ�������̎擾�Ԋu���`
	if($gyap_time >= 365*24*60*60){ $interval_second = (24*60*60); }	# �P�N �X�V����Ă��Ȃ��ꍇ
	elsif($gyap_time >= 6*30*24*60*60){ $interval_second = (12*60*60); }	# �U���� ...
	elsif($gyap_time >= 30*24*60*60){ $interval_second = (6*60*60); }	# �P���� ...
	elsif($gyap_time >= 7*24*60*60){ $interval_second = (3*60*60); }	# �P�T�� ...
	elsif($gyap_time >= 3*24*60*60){ $interval_second = (1*60*60); }	# �R�� ...
	elsif($gyap_time >= 1*24*60*60){ $interval_second = (*60); }	# �P�� ...
	elsif($gyap_time >= 6*60*60){ $interval_second = (15*60); }	# �U���� ...
	elsif($gyap_time >= 1*60*60){ $interval_second = (10*60); }	# �P���� ...
	else{
			if(exists $use->{'UnderIntervalSecond'} && $use->{'UnderIntervalSecond'} < 5*60){ $interval_second = $use->{'UnderIntervalSecond'}; }
			else{ $interval_second = 5*60; }
	}	# ����ȊO


	# �Œ�C���^�[�o���b�����擾�Ԋu���Z���Ȃ�Ȃ��悤��
	if(exists $use->{'UnderIntervalSecond'} && $use->{'UnderIntervalSecond'} > $interval_second){
		$interval_second = $use->{'UnderIntervalSecond'};
	}

# �u����̎擾�����ԁv���`
my $next_allow_getfile_localtime = $last_getfile_localtime + $interval_second;

	# ������
	# �u�O��̎擾���ԁv�Ɓu�X���b�h�̍ŏI�X�V�����v���r���āA�擾���Ԃ�ω�������i���΂炭�X�V���Ȃ��X���b�h�͎���̎擾��x�点��j
	if(time >= $next_allow_getfile_localtime){ $allow_flag = 1; }

return($allow_flag);

}


1;