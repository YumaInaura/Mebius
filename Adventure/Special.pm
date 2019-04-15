
package Mebius::Adventure;
use Mebius::Adventure::Adjust;
use strict;

#-----------------------------------------------------------
# ����s��
#-----------------------------------------------------------
sub SpecialAction{

# �Ǐ���
my($message,$makelog,%renew,%renew_target);
my($init) = &Init();
my($init_login) = init_login();
my($advmy) = my_data();
my($target);

# �A�N�Z�X����
main::axscheck("Post-only ACCOUNT");

	# �e��G���[
	if($main::in{'target_id'} eq ""){ main::error("�����I�����Ă��������B"); }
	if($main::in{'target_id'} =~ /\W/){ main::error("�L����ID���ςł��B"); }

# ���b�N�J�n
Mebius::lock("Adventure-action-$advmy->{'id'}");

# �����̃t�@�C�����J��
my($adv) = &File("Password-check Flock",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} , TypeCharCheck => 1 , TypeChargeTimeCheckError => 1 });

# CCC �s��`�F�b�N
#if(Mebius::alocal_judge()){ sleep(3); }

	# ����L�����N�^�[��I������ꍇ
	if($main::in{'target_id'} ne "id_none"){
		($target) = &File("File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $main::in{'target_id'} , FormalPlayerCheckAndError => 1 });
	}

	# �s���\���ǂ����𔻒�A�s���ł��Ȃ��ꍇ�̓G���[��\������
	&SpecialJudge({ TypeErrorView => 1 },$adv,$target);

	# �m��
	if($advmy->{'jobname'} eq "�m��"){
		if(rand(1) < 1){
			my($up);
				if($adv->{'level'} >= 5000){ $up = 32; }
				elsif($adv->{'level'} >= 2000){ $up = 16; }
				elsif($adv->{'level'} >= 1000){ $up = 14; }
				elsif($adv->{'level'} >= 500){ $up = 12; }
				elsif($adv->{'level'} >= 250){ $up = 10; }
				elsif($adv->{'level'} >= 100){ $up = 8; }
				elsif($adv->{'level'} >= 50){ $up = 6; }
				elsif($adv->{'level'} >= 25){ $up = 4; }
				elsif($adv->{'level'} >= 10){ $up = 2; }
				else{ $up = 1; }
				$up *= $init->{'game_speed'};
			$message = qq(�F��܂����I $target->{'chara_link'} ��HP���S�񕜂��A�ő�HP�� $up �A�b�v���܂����I);
			$makelog = qq($adv->{'chara_link'} ��->$target->{'chara_link'} ���񕜂����A <span class="red">�ő�HP</span> ���グ�܂����B);
			$renew_target{'+'}{'maxhp'} = $up;
			$renew_target{'='}{'hp'} = "maxhp";
		}
		else{
			$message = qq(�F��܂����I);
		}
	}

	# ����
	elsif($advmy->{'jobname'} eq "����"){

		my($steel_gold_comma);

				my $steel_gold = int rand($adv->{'level'}*80);					# ��{�z
				#require Mebius::Adventure::Adjust;
				(undef,$steel_gold) = &ExpGold("STEEL","",$steel_gold,$adv);	# ��������
			if($steel_gold > $target->{'gold'}){ $steel_gold = $target->{'gold'}; }	# ����̏�������葽���͓��߂Ȃ�
			if($target->{'gold'} < 0){ $steel_gold = 0; }							# ����̏��������}�C�i�X�̏ꍇ��0G�������߂Ȃ��i�������B�΍�j
			if($target->{'jobname'} eq '���\�͎�' && rand(3) < 1 && $adv->{'gold'} >= -10000){
				$steel_gold *= -5;
				($steel_gold_comma) = Mebius::japanese_comma($steel_gold);
				$message = qq(���ǂ܂ꂽ�I $target->{'chara_link'}��$steel_gold_comma\G��D���܂����B);
			}
			else{
				($steel_gold_comma) = Mebius::japanese_comma($steel_gold);
				$message = qq($target->{'chara_link'}����$steel_gold_comma\G�𓐂݂܂����I);
				$makelog = qq($adv->{'chara_link'} ��->$target->{'chara_link'} ���� <span class="goldcolor">$steel_gold_comma\G</span> �𓐂݂܂����B);
			}
		$renew{'+'}{'gold'} = $steel_gold;
		$renew_target{'-'}{'gold'} = $steel_gold;
	}

	# �x��q
	elsif($advmy->{'jobname'} eq "�x��q"){
		my $rand = 4;
		if($target->{'charm'} >= 5000){ $rand *= 2.0; }
		elsif($target->{'charm'} >= 2500){ $rand *= 1.5; }
		elsif($target->{'charm'} >= 1000){ $rand *= 1.25; }

		if(rand($rand) < 1){
			$renew_target{'+'}{'charm'} = (1*$init->{'game_speed'});
			$message = qq(�ؗ�ɗx��܂����I $target->{'chara_link'} �� ���͂� 1 �A�b�v���܂����I);
			$makelog = qq($adv->{'chara_link'} ��->$target->{'chara_link'} �� <span class="red">����</span> �ɖ����������܂����B);
		}
		else{
			$message = qq(�ؗ�ɗx��܂����I);
		}
	}

	# �B���p�t
	elsif($advmy->{'jobname'} eq "�B���p�t"){
			#if($target->{'item_damage_plus'} > $target->{'item_damage'}*1.5
			#			&& $target->{'item_damage_plus'} > $target->{'item_damage'} + 100){ main::error("�������̕���͋����o���܂���B"); }
			if($target->{'item_damage_plus'} >= $target->{'item_damage'}*0.5 && $target->{'item_damage_plus'} >= 100){ main::error("�������̕���͋����o���܂���B"); }
		my $rand = 10 - ($adv->{'level'}*0.01);
			if($rand < 1.0){ $rand = 1.0; }
			if(rand($rand) < 1){
				my $up = int(1*$init->{'game_speed'});
					if($adv->{'level'} >= 10000){ $up += 5; }
					elsif($adv->{'level'} >= 5000){ $up += 4; }
					elsif($adv->{'level'} >= 1000){ $up += 3; }
					elsif($adv->{'level'} >= 500){ $up += 2; }
					elsif($adv->{'level'} >= 100){ $up += 1; }
				$message = qq(�����ɂ��A����̈З͂� $up �|�C���g �㏸�����܂����I);
				$makelog = qq($adv->{'chara_link'} ��->$target->{'chara_link'} �� <span class="red">����̈З�</span> ���グ�܂����B);
				$renew_target{'+'}{'item_damage_plus'} = $up;
			}
			else{ $message = qq(����̌����͎��s�ł��B); } 
	}

	# �i��
	elsif($advmy->{'jobname'} eq "�i��"){

		my $rand = 10 - ($adv->{'level'}/500);
			if($rand < 3){ $rand = 3; }
			if(rand($rand) < 1 ){
		my $up = 1*$init->{'game_speed'};
		$message = qq(���O����J���}�𔃎����A $target->{'chara_link'} �ɗ^���܂����I);
		$makelog = qq($adv->{'chara_link'} ��->$target->{'chara_link'} �� <span class="red">�J���}</span> �����߂܂����B);
		$renew_target{'+'}{'karman'} = $up;
	}
		else{ $message = qq(�J���}�����߂�̂Ɏ��s���܂����B); }
	}

	# �N��
	elsif($advmy->{'jobname'} eq "�N��"){

				my $steel_gold = int rand($adv->{'level'}*180);					# ��{�z
				#require Mebius::Adventure::Adjust;
				(undef,$steel_gold) = &ExpGold("STEEL","",$steel_gold,$adv);	# ��������
			if($steel_gold > $target->{'gold'}){ $steel_gold = $target->{'gold'}; }	# ����̏�������葽���͓��߂Ȃ�
			if($target->{'gold'} < 0){ $steel_gold = 0; }							# ����̏��������}�C�i�X�̏ꍇ��0G�������߂Ȃ��i�������B�΍�j

		my($steel_gold_comma) = Mebius::japanese_comma($steel_gold);
		$message = qq($target->{'chara_link'}����$steel_gold_comma\G��v�����܂����I);
		$makelog = qq($adv->{'chara_link'} ��->$target->{'chara_link'} ���� <span class="goldcolor">$steel_gold_comma\G</span> ��v�����܂����B);
		$renew{'+'}{'gold'} = $steel_gold;
		$renew_target{'-'}{'gold'} = $steel_gold;
	}

	# ��
	elsif($advmy->{'jobname'} eq "��"){

		if($target->{'jobname'} eq '���\�͎�' && rand(5) >= 1){ $message = "���ǂ܂ꂽ! ������a��܂���ł����B"; }
		elsif(rand(1) < 1){
				my $damage_percent = 10 + int($adv->{'level'}*0.05*$init->{'game_speed'});
			if($damage_percent > 50){ $damage_percent = 50; }
				my $left_hp = int($target->{'hp'}*$damage_percent*0.01);
				$renew_target{'-'}{'hp'} = $left_hp;
				$message = qq($target->{'chara_link'}���a�����I<br> HP�� $damage_percent �� ���܂����B<span class="hpcolor">�i HP $target->{'hp'} �� HP $left_hp �j</span>);
				$makelog = qq($adv->{'chara_link'} ��->$target->{'chara_link'} �� <span class="red">�a��</span> �܂����B);
			}
			else{
				$message = qq(�����؂�܂���ł����B); 
			}
	}

# �A���s�����֎~
Mebius::Redun(undef,"ADV_ACTION",$adv->{'redun'});

	# �����̃L�����t�@�C�����X�V ( A - 1 )
	# => �����Ō����ȃ`���[�W���ԃ`�F�b�N�������Ȃ��Ă��邽�߁A�K���e��t�@�C���X�V�̍ŏ��ɏ������� => �����G���[������Α��̏��������s����Ȃ�
	{
		$renew{'last_select_special_id'} = $target->{'id'};
		$renew{'-'}{'sp'} = 1;
		&File("Renew Charge-time Mydata Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} , TypeCharCheck => 1 , TypeChargeTimeCheckError => 1  , FormalPlayerCheckAndError => 1 },\%renew);
	}

	# ����̃t�@�C����ǂݍ��݁A�X�V
	if($main::in{'target_id'}){
		&File("Renew File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $main::in{'target_id'} , FormalPlayerCheckAndError => 1 },\%renew_target);
	}

	# �S�L�����N�^�[�̍s���L�^���X�V
	if($makelog && !$adv->{'test_player_flag'}){
		my($NewComment1,$NewComment2) = split(/->/,$makelog);
		&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
	}


# ���b�N����
Mebius::unlock("Adventure-action-$advmy->{'id'}");


$message .= qq(<br>SP������܂����B);


# HTML
my $print = qq(
<h1>����s��</h1>
$init_login->{'link_line'}
<div class="results">$message</div>
$init->{'continue_button'}
);


Mebius::Template::gzip_and_print_all({ BodyPrint => 1 ,RefreshURL => $init->{'login_url'} , RefreshSecond => 2 },$print);

exit;

}


#-----------------------------------------------------------
# ����s���\���ǂ����𔻒�
#-----------------------------------------------------------
sub SpecialJudge{

# �錾
my($use,$adv,$target) = @_;
my($init) = &Init();
my(%self);

	# ���肩�����������ȃv���C���[�ł͂Ȃ��ꍇ
	if(!$target->{'formal_player_flag'}){ $self{'error_flag'} = qq(�A�J�E���g��o�^���Ă��Ȃ��L�����N�^�[�ɂ́A����s���͏o���܂���B); }
	if(!$adv->{'formal_player_flag'}){ $self{'error_flag'} = qq(�A�J�E���g�o�^������ƁA����s�����o���܂��B); }

	# �`���[�W���Ԕ���
	if($adv->{'still_charge_flag'}) {
		$self{'error_flag'} = qq(�܂��`���[�W���Ԃ��I����Ă��܂���B);
	}

	# SP�؂�̏ꍇ
	if($adv->{'sp'} <= 0){
		Mebius::AccessLog("Not-unlink-file","Adventure-redun-special","�A������s�������B �L����ID: $adv->{'id'}");
		$self{'error_flag'} = qq(SP (��F�|�b�v�R�[��) ������܂���B�h���ɔ��܂��Ă��������B);
	}

	# ����̃��O�C�����Ԃ𔻒�
	if(time > $target->{'lasttime'}+($init->{'charaon_day'}*24*60*60) && !Mebius::alocal_judge()){
		$self{'error_flag'} = qq($init->{'charaon_day'}���ȏネ�O�C�����Ă��Ȃ�����͑I�ׂ܂���B);
	}

	# ���E�Ƃ��Ƃ̔���
	{

		# ����
		if($adv->{'jobname'} eq "����"){
			$self{'name'} = "���݂𓭂�";
			if($adv->{'maxhp'} > $target->{'maxhp'}*$init->{'special_battle_gyap'}){ $self{'error_flag'} = qq(���͍��̂��肷���鑊��͑I�ׂ܂���B); }
		}

		# �m��
		elsif($adv->{'jobname'} eq "�m��"){
			$self{'name'} = "�F��";
		}

		# �x��q
		elsif($adv->{'jobname'} eq "�x��q"){
			$self{'name'} = "�x��";
		}

		# �B���p�t
		elsif($adv->{'jobname'} eq "�B���p�t"){
			$self{'name'} = "�������������";
				#if($target->{'item_damage_plus'} > $target->{'item_damage'}*1.5
				#			&& $target->{'item_damage_plus'} > $target->{'item_damage'} + 100){ $self{'error_flag'} = qq(�������̕���͋����o���܂���B); }
				if($target->{'item_damage_plus'} >= $target->{'item_damage'}*0.5 && $target->{'item_damage_plus'} >= 100){ $self{'error_flag'} = qq(�������̕���͋����o���܂���B); }
		}

		# �i��
		elsif($adv->{'jobname'} eq "�i��"){
			$self{'name'} = "�J���}�����߂�";
			if($target->{'karman'} >= 50){ $self{'error_flag'} = qq(�J���}�͖��^���ł��B); }
		}

		# �N��
		elsif($adv->{'jobname'} eq "�N��"){
			$self{'name'} = "�v������";
				if($adv->{'maxhp'} > $target->{'maxhp'}*$init->{'special_battle_gyap'}){ $self{'error_flag'} = qq(���͍��̂��肷���鑊��͑I�ׂ܂���B); }
				if($target->{'jobname'} ne "����"){ $self{'error_flag'} = qq(�����ȊO�͑I�ׂ܂���B); }

		}

		# ��
		elsif($adv->{'jobname'} eq "��"){
			$self{'name'} = "�a��";
				if($adv->{'maxhp'} > $target->{'maxhp'}*$init->{'special_battle_gyap'}){ $self{'error_flag'} = qq(���͍��̂��肷���鑊��͑I�ׂ܂���B); }
		}

		# ����s�����Ȃ��E�Ƃ̏ꍇ
		else{
			$self{'name'} = "����s��";
			$self{'error_flag'} = "���Ȃ��̐E�Ƃł͓���s���͏o���܂���B";
		}

	}

	# �G���[���Ȃ���Ή\�t���O�𗧂Ă�
	if($self{'error_flag'}){
		$self{'disabled'} = " disabled";
		$self{'justy_flag'} = 1;
	}

# �s���{�^��
$self{'form'} .= qq(�@<form action="$init->{'script'}" method="post" class="inline">\n);
$self{'form'} .= qq(<div class="inline">\n);
$self{'form'} .= qq(<input type="hidden" name="mode" value="special">\n);
$self{'form'} .= qq(<input type="hidden" name="id" value="$adv->{'id'}">\n);
$self{'form'} .= qq(<input type="hidden" name="char" value="$adv->{'char'}">\n);
$self{'form'} .= qq(<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">\n);
$self{'form'} .= qq(<input type="hidden" name="target_file_type" value="account">\n);
$self{'form'} .= qq(<input type="submit" value="$self{'name'}" class="special"$self{'disabled'}>\n);
$self{'form'} .= qq(<input type="hidden" name="target_id" value="$target->{'id'}">\n);
$self{'form'} .= qq($self{'error_flag'});
$self{'form'} .= qq(</div>\n);
$self{'form'} .= qq(</form>\n);

	# ���G���[�𑦎��\������ꍇ
	if($use->{'TypeErrorView'} && $self{'error_flag'}){
		main::error($self{'error_flag'});
	}

return(\%self);

}

1;
