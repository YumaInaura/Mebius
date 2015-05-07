
package Mebius::Adventure;
use strict;

#-----------------------------------------------------------
# �o���l�Ɗl���S�[���h�𒲐�
#-----------------------------------------------------------
sub ExpGold{

# �錾
my($type,$exp,$gold,$adv) = @_;
my($init) = &Init();
my($bank);

	# ����������
	if($adv->{'item_concept'} =~ /Getgold-boost-([0-9\.]+)/){ $gold *= $1; }

	# EXP��������
	if($adv->{'item_concept'} =~ /Getexp-boost-([0-9\.]+)/){ $exp *= $1; }

	# �J���}�ɂ��o���l�Ȃǔ{��
	if($adv->{'karman'} >= 1){
			if($exp >= 1){ $exp = $exp + int($exp * $adv->{'karman'} * 0.025) + rand($adv->{'karman'}*5); }
			if($gold >= 1){ $gold = $gold + int($gold * $adv->{'karman'} * 0.025) + rand($adv->{'karman'}*5); }
	}

	# �Q�[���X�s�[�h�Ŕ{��
	if($exp >= 1){ $exp *= $init->{'game_speed'}; }
	if($gold >= 1){ $gold *= $init->{'game_speed'}; }

# �����U�ւ̍��������̂Ȃ����z
my $pure_gold = int($gold);

	# ��s�ւ̎����U��
	if($adv->{'autobank'} >= 1 && $gold >= 1 && $type =~ /Auto-bank/){
		$gold = int($pure_gold*(1-($adv->{'autobank'}*0.01)));
		$bank = int($pure_gold*($adv->{'autobank'}*0.01*0.80));
	}

# �����ɂ���
$exp = int $exp;
$gold = int $gold;
$pure_gold = int $pure_gold;
$bank = int $bank;

# ���^�[��
return($exp,$gold,$bank,$pure_gold);

}

#-----------------------------------------------------------
# �퓬��̏��� ( HP �񕜂Ȃ� )
#-----------------------------------------------------------
sub RepairHP{

# �錾
my($use,$adv,$renew) = @_;
my($comment2,$repaired_flag);

	# �g�o���[���ȉ��ɂȂ����ꍇ
	if($adv->{'hp'} <= 0) {

			# �������ꍇ
			if($use->{'WinFlag'}){ $renew->{'hp'} = 1; }

			# �������`�����v�̏ꍇ
			elsif($use->{'ChampFlag'}){ $renew->{'hp'} = 1; } 

			# ���ʂ̉�
			elsif($adv->{'maxhp'} >= 5000){ $renew->{'hp'} = int($adv->{'maxhp'}*0.1); }
			elsif($adv->{'maxhp'} >= 2500){ $renew->{'hp'} = int($adv->{'maxhp'}*0.25); }
			elsif($adv->{'maxhp'} >= 1000){ $renew->{'hp'} = int($adv->{'maxhp'}*0.5); }
			else{ $renew->{'hp'} = $adv->{'maxhp'};	 }
	
		$repaired_flag = 1;

	}

	# HP���ő�HP�𒴂��Ȃ��A�����Ȃ��悤��
	if($renew->{'hp'} > $adv->{'maxhp'}) { $renew->{'='}->{'hp'} = "maxhp"; }
	if($renew->{'hp'} <= 0) { $renew->{'hp'} = 1; }

	# �R�����g
	if($repaired_flag){
		$comment2 .= qq(<br>HP�� <strong class="hpcolor">$renew->{'hp'}</strong> �܂ŉ񕜂����B);
	}

	# �J���}�ɂ��g�o����
	#if($adv->{'hp'} < $adv->{'maxhp'} && $adv->{'karman'} >= 1){
	#	$lp_hpbonus = int(rand($adv->{'karman'}*3));
	#	$renew->{'+'}{'hp'} = $lp_hpbonus;
	#		if($lp_hpbonus >= 1){ $comment2 .= qq(<br>�J���}�{�[�i�X�I HP��<strong class="hpcolor">$lp_hpbonus</strong>�񕜂����B);  }
	#}

return($comment2,$adv,$renew);

}

#-----------------------------------------------------------
# �u�[�X�g�ɉ����ă��x���A�b�v
#-----------------------------------------------------------
sub levelup_round{

my($adv2,$renew) = @_;
my($levelup_comment_line,$levelup_comment);
my($max_level_up);

	if(time < $adv2->{'effect_levelup_boost_time'} && $adv2->{'effect_levelup_boost'} >= 2){ $max_level_up = $adv2->{'effect_levelup_boost'}; }
	else{ $max_level_up = 1; }

	for(1..$max_level_up){
		($levelup_comment,$adv2,$renew) = &levelup(undef,$adv2,$renew);
			if($levelup_comment){ $levelup_comment_line .= qq(<div class="levelup">$levelup_comment</div>); }
	}

return($levelup_comment_line,$adv2,$renew);

}


#-----------------------------------------------------------
# ���x���A�b�v����
#-----------------------------------------------------------
sub levelup{

# �Ǐ���
my($type,$adv,$renew) = @_;
my($init) = &Init();
my($comment,$up_hp,$up_odds_type,$down_odds_type,$comment2,$lp_hpbonus,%most_up,%most_down);

	# ���x���A�b�v�������ǂ����𔻒�
	if($adv->{'exp'} > $adv->{'next_exp'}) {
	}
	# �A�b�v���ĂȂ��ꍇ�͂����Ƀ��^�[��
	else {
		return(undef,$adv,$renew);
	}

# ���x���A�b�v
$renew->{'+'}{'level'} += 1;
$adv->{'level'} += 1;
$renew->{'+'}{'all_level'} += 1;
$adv->{'all_level'} += 1;
$comment .= qq(<strong class="levelup">���x����) . ($adv->{'level'}) . qq(�ɏオ�����I</strong>);

# ���x���A�b�v���̌o���l����������
$renew->{'-'}{'exp'} += $adv->{'next_exp'};
$adv->{'exp'} -= $adv->{'next_exp'};

# �ő�g�o���A�b�v
$up_hp = int(rand($adv->{'vital'})) + 1;
	if($adv->{'jobname'} eq "��m"){
		$up_hp += int(rand($adv->{'vital'}*0.25)) + 5;
	}
	if($up_hp){
		$renew->{'+'}{'maxhp'} += $up_hp;
		$adv->{'maxhp'} += $up_hp;
		$comment .= qq(<br><span class="red">�ő�HP�� $up_hp �オ�����B</span>);
	}


	# ���e�펩���X�V
	if($adv->{'level'} % 10 == 0 || time >= $adv->{'lastmodified'} + 1*24*60*60 || Mebius::alocal_judge()){

		# �E�Ɛݒ���ŐV�̏�Ԃɂ���
		require Mebius::Adventure::Job;
		($renew->{'jobname'},$renew->{'jobrank'},$renew->{'spatack'},$renew->{'spodds'},$renew->{'jobmatch'},$renew->{'jobconcept'}) = &JobRank($adv->{'job'},$adv->{'level'});

			# �A�C�e�����ŐV�̏�Ԃɂ���
			if($adv->{'item_number'}){
				require Mebius::Adventure::Item;
				my($new) = &SelectItem("Get-hash",$adv->{'item_number'},$adv);
				$renew->{'item_name'} = $new->{'item_name'};
				$renew->{'item_damage'} = $new->{'item_damage'};
				$renew->{'item_job'} = $new->{'item_job'};
				$renew->{'item_concept'} = $new->{'item_concept'};
			}
		
		# �ŐV��Ԃ��X�V�������Ԃ��o���Ă���
		$renew->{'lastmodified'} = time;

	}

# �p�����[�^�㏸�E�����̊m�����`
my $up_odds;
my $down_odds = 25;

	# ���݂̃��x���ɉ����āA�p�����[�^�̏オ�����ύX����
	if($adv->{'level'} >= 50){ $up_odds = 7; }
	elsif($adv->{'level'} >= 25){ $up_odds = 6; }
	else{ $up_odds = 5; }

	# �h�c�̒����ɂ���āA�オ��₷���p�����[�^��U�蕪��
	if(length($adv->{'id'}) >= 10){ $most_up{'charm'} = 1; }
	elsif(length($adv->{'id'}) >= 9){ $most_up{'speed'} = 1; }
	elsif(length($adv->{'id'}) >= 8){ $most_up{'tec'} = 1; }
	#elsif(length($adv->{'id'}) >= 7){ $most_up{'vital'} = 1; }
	elsif(length($adv->{'id'}) >= 6){ $most_up{'believe'} = 1; }
	elsif(length($adv->{'id'}) >= 5){ $most_up{'brain'} = 1; }
	else{ $most_up{'power'} = 1; }

# �}�C�X�L���̏オ��₷�� ( ��{�m���� x�{ �̊m�����v���X )
$up_odds_type = $up_odds / 0.35;

	# ���O�̒����ɂ���āA������₷���p�����[�^��U�蕪��
	if(length($adv->{'name'}) >= 8*2){ $most_down{'charm'} = 1; }
	elsif(length($adv->{'name'}) >= 7*2){ $most_down{'speed'} = 1; }
	elsif(length($adv->{'name'}) >= 6*2){ $most_down{'tec'} = 1; }
	#elsif(length($adv->{'name'}) >= 5*2){ $most_down{'vital'} = 1; }
	elsif(length($adv->{'name'}) >= 4*2){ $most_down{'believe'} = 1; }
	else{ $most_down{'brain'} = 1; }


# �}�C�X�L���̉�����₷�� ( ��{�m���� x�{ �̊m�����v���X )
$down_odds_type =  $down_odds / 0.8;

	# ��背�x���܂ł́A�p�����[�^��������ɂ���
	if($adv->{'level'} <= 30){ $down_odds *= 5; }

	# �X�e�[�^�X��W�J
	foreach(@{$init->{"status"}}){
			if(rand($up_odds) < 1 || ($most_up{$_} && rand($up_odds_type) < 1)) {
				$renew->{'+'}{"$_"} += 1;
				$adv->{$_} += 1;
				$comment .= qq(<br><span class="red">$init->{"status_name"}->{$_}��1�オ�����B</span>);
			}
			elsif(rand($down_odds) < 1 || ($most_down{$_} && rand($down_odds_type) < 1)){
				$renew->{'-'}{"$_"} += 1;
				$adv->{$_} -= 1;
				$comment .= qq(<br><span class="blue">$init->{"status_name"}->{$_}��1���������B</span>);
			}
	}

	# �J���}�̑���
	if($adv->{'karman'} < 30 && (rand(20) < 1 || ($adv->{'jobname'} =~ /^(�m��|�i��|�N��)$/ && rand(50) < 1)) ) {
		$renew->{'+'}{'karman'} += 1;
		$adv->{'karman'} += 1;
		$comment .= qq(<br><span class="red">�J���}��1�オ�����B</span>);
	}
	elsif($adv->{'karman'} > 0 && (rand(20) < 1 || ($adv->{'jobname'} =~ /^(����)$/ && rand(30) < 1)) ){
		$renew->{'-'}{'karman'} += 1;
		$adv->{'karman'} -= 1;
		$comment .= qq(<br><span class="blue">�J���}��1���������B</span>);
	}

	# �����_�𐮌`����
	foreach(keys %$renew){
			# ����������ύX���� ( �����ɑ΂��� int ����� �l���ύX����Ă��܂� )
			if($renew->{$_} =~ /^([\d\.]+)$/){ $renew->{$_} = int $renew->{$_}; }
	}

return($comment,$adv,$renew);

}



1;
