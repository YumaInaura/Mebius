
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# �h�ɔ��܂�
#-----------------------------------------------------------
sub Yado{

# �Ǐ���
my($init) = Init();
my($init_login) = init_login();
my($advmy) = my_data();
my($hit,$date,$yado_gold,$message,$repair_hp,$repair_gold,$results,$first_hp,$first_gold,$last_hp);
my(@yado_new,%renew,$print);

# �L�����t�@�C�����J��
my($adv) = File("Password-check Char-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} });

# �`�����v�t�@�C�����擾
my($champ) = ChampFile(undef,undef,$adv);

# �h��̒���
my($yado_gold) = yado_gold($adv,$champ->{'mychamp_flag'});
	if($adv->{'gold'} < $yado_gold) { main::error("����������܂���I�@�@���o����܂����B"); }

	# �e�폈��
	if($adv->{'hp'} >= $adv->{'maxhp'} && $adv->{'sp'} >= 15 && !Mebius::alocal_judge()){
		main::error("����Ȃɖ���܂���B");
	}

	# �C�x���g�i�P�j
	if(rand(40) < 1){ $yado_gold *= -1; $results = qq(<li>�e�؂Ȑe�����^�_�Ŕ��߂Ă��ꂽ��ɁA���v�Ҍ��ՂŃL���b�V���o�b�N������܂����B); }
	elsif(rand(20) < 1){ $yado_gold = 0; $results = qq(<li>�e�؂Ȑe�����^�_�Ŕ��߂Ă���܂����B); }
	elsif(rand(20) < 1){ $yado_gold *= 2; $results .= qq(<li>���߂�̂���ŁA������葽���������g���܂����B); }
	elsif(rand(40) < 1){ $yado_gold *= 4; $results .= qq(<li>�����݂͑��؂肾�A�C�����ǂ��I�A������葽���������g���܂����B); }

	# ���ő�HP�̃A�b�v
	{
		# �Ǐ���
		my($plus_maxhp);

			# �C�x���g���I
			if(rand(1_000_000) < 1){ $plus_maxhp = 10000; }
			elsif(rand(100_000) < 1){ $plus_maxhp = 5000; }
			elsif(rand(10_000) < 1){ $plus_maxhp = 1000; }
			elsif(rand(1_000) < 1){ $plus_maxhp = 500; }
			elsif(rand(100) < 1){ $plus_maxhp = 100; }
			elsif(rand(50) < 1){ $plus_maxhp = 10; }

			# �C�x���g�����������ꍇ
			if($plus_maxhp){
				$renew{'+'}{'maxhp'} = $plus_maxhp;
				$renew{'+'}{'hp'} = $plus_maxhp;
				$results .= qq(<li>��������Q�čő�g�o�� <strong class="hpcolor">$plus_maxhp</strong> �����܂����B);
			}
	}

	# �����x���A�b�v�u�[�X�g
	if($adv->{'exp'} >= 1 && time >= $adv->{'last_yado_time'} + 15){

		my $exp_gyap = $adv->{'exp'} / $adv->{'next_exp'} if($adv->{'next_exp'} >= 1);

			if($exp_gyap >= 50){

				my($levelup_boost,$person,$odds);

					# �m���𑝂₷
					if($exp_gyap >= 100_000){ $odds = 2.0; }
					elsif($exp_gyap >= 10_000){ $odds = 1.75; }
					elsif($exp_gyap >= 1_000){ $odds = 1.5; }
					else{ $odds = 1.0; }

					# ��������
					if(rand(100_000/$odds) < 1){ $levelup_boost = 10; $person = '�i�J���̍����Ђ�'; }
					elsif(rand(50_000/$odds) < 1){ $levelup_boost = 7; $person = '�S�l�̓����ڋʏĂ�'; }
					elsif(rand(10_000/$odds) < 1){ $levelup_boost = 6; $person = '�ꗬ�V�F�t�̓����r�[�t�X�e�[�L'; }
					elsif(rand(5_000/$odds) < 1){ $levelup_boost = 5; $person = '�΂���̓������߂ڂ����ɂ���'; }
					elsif(rand(1_000/$odds) < 1){ $levelup_boost = 4; $person = '���ӂ���̓������ڂ��o�[�K�['; }
					elsif(rand(500/$odds) < 1){ $levelup_boost = 3; $person = '���o����̓����J���[���C�X'; }
					elsif(rand(250/$odds) < 1){ $levelup_boost = 2; $person = '�e���̓����V�`���['; }

					# ���ʂ����������ꍇ
					if($levelup_boost){

							# ���ʂ��I����Ă��Ȃ��ꍇ�ɂ͒ǉ�����
							if(time < $adv->{'effect_levelup_boost_time'}){
								$renew{'+'}{'effect_levelup_boost'} = $levelup_boost;
								$renew{'+'}{'effect_levelup_boost_time'} = 30*60;
							# ���ʂ̔���
							} else {
								$renew{'effect_levelup_boost'} = $levelup_boost;
								$renew{'effect_levelup_boost_time'} = time + 30*60;
							}
						$results .= qq(<li class="red">�u${person}�v�����E�}�I ���΂炭�̊ԁA���x���� <strong>${levelup_boost}�{</strong> �オ��₷���Ȃ�܂����B);
					}

			}

	}

# �L�����t�@�C���̒l���`
$renew{'hp'} = $adv->{'maxhp'};
$renew{'-'}{'gold'} = $yado_gold;
$renew{'sp'} = $init->{'kiso_sp'};
$renew{'last_yado_time'} = time;

# �J�E���g
$renew{'+'}{'yado_count'} = 1;

# �L�����t�@�C�����X�V
my($renewed) = &File("Password-check Mydata Renew",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} },\%renew);

# �J���}��t����
my($left_gold_comma) = Mebius::japanese_comma($renewed->{'gold'});

# ���ʕ\����ǉ�
if($champ->{'mychamp_flag'}){ $results .= qq(<li>�`�����v�Ȃ̂ō��؂ȃz�e���ɔ��܂�܂����B); }
#$results .= qq(<li>HP $adv->{'hp'}  �� HP $repair_hp );
$results .= qq(<li>�c�菊���� <span class="goldcolor">$left_gold_comma G</span>); # $adv->{'gold'} G �� 
$results .= qq(<li>HP��SP ���񕜂��܂����B);


	if($yado_gold >= 1){ $print .= qq(<h1>${yado_gold}G�ŏh�����܂���</h1>); }
	else{ $print .= qq(<h1>�^�_�ŏh�����܂���</h1>); }

$print .= qq(
$init_login->{'link_line'}
<div class="line-height-large">
<ul>
$results
</ul>
</div>
$init->{'continue_button'}
<hr>

);

Mebius::Template::gzip_and_print_all({ RefreshURL => $init->{'login_url'} , RefreshSecond => 10  },$print);

exit;

}

#-----------------------------------------------------------
# �h��̌v�Z
#-----------------------------------------------------------
sub yado_gold{

my($adv,$my_champ_flag) = @_;
my($level,$maxhp,$job) = ($adv->{'level'},$adv->{'maxhp'},$adv->{'job'});
my($yado_gold,$yado_dai);

	# �h�̊�{�{��
	if($level >= 10000){ $yado_dai = 25.0; }
	elsif($level >= 5000){ $yado_dai = 20.0; }
	elsif($level >= 1000){ $yado_dai = 17.5; }
	elsif($level >= 500){ $yado_dai = 15.0; }
	elsif($level >= 100){ $yado_dai = 12.5; }
	elsif($level >= 50){ $yado_dai = 10; }
	else{ $yado_dai = 5; }

# ���x������v�Z
$yado_gold = $yado_dai * $level;

	# �`�����v�̏ꍇ
	if($my_champ_flag){ $yado_gold *= 3;  }

	# ���x���A�b�v������
	if($adv->{'effect_levelup_boost'} >= 5 && $adv->{'effect_levelup_boost_time'} > time){
		$yado_gold *= ($adv->{'effect_levelup_boost'}/2);
	}

# �����ɂ���
$yado_gold = int $yado_gold;

return($yado_gold);

}


1;
