
package Mebius::Adventure;
use Mebius::Adventure::Adjust;
use CGI;
use strict;

#-----------------------------------------------------------
# �퓬
#-----------------------------------------------------------
sub Battle{

# �錾
my($init) = &Init();
my($init_login) = init_login();
my($advmy) = Mebius::Adventure::my_data();
my($i,$j,$ltime,$win,$lose,$enemy_win,$enemy_lose,$h1,$skill2dmg1,$skilldmg1,$exp,$gold);
my($monster_exp,$champwin_exp,$winlose_text,$bank);
my($turn_results,$enemy,$comment,$battle_start_message,$print);
my($enemy_id,$draw_flag,$monster_rank);
my($select_battle_mode,$champ_battle_flag,$save_khp_comma,$save_whp_comma,$kmaxhp_comma,$wmaxhp_comma,$sametime_down_flag);
my($pure_gold,$champ_change_flag,$mychamp_flag);
my($levelup_comment_line,$comment_hp_line,$BattleMode);
my($alocal_mode) = Mebius::alocal_judge();

# �A�N�Z�X����
main::axscheck("Post-only ACCOUNT");

#  �^�C�g����`
$main::sub_title = qq(�퓬 | $main::title);
$main::head_link3 = qq(&gt; �퓬);

# CSS��`
$main::css_text .= qq(
table,tr,th,td{border:solid 1px #272;}
h2{background:#fcc;padding:0.3em 0.5em;text-align:center;font-size:120%;font-weight:normal;clear:both;}
strong.spatack{font-size:120%;color:#f00;}
div.turn{clear:both;}
div.atack_left{word-wrap:break-word;word-break:break-all;float:left;width:49%;margin-bottom:0.1em;}
div.atack_right{word-wrap:break-word;word-break:break-all;float:right;width:49%;margin-bottom:0.1em;}
div.result_comment{line-height:2.0;}
div.comment_atack{line-height:2.0;}
h3{margin-top:0em;font-size:140%;}
.clitical{color:#f00;font-size:130%;}
.bluefire{font-size:140%;color:#00f;}
.damage{color:#f00;}
.special{color:#080;}
);
if($main::mode eq "monster"){ $main::css_text .= qq(h2{background:#cdf;}\n); } 

if(Mebius::alocal_judge()){
#$main::css_text .= qq(div.comment_atack{background:#ff0;});
}

# �`�����v�ɏ��� �`�{�̌o���l���l��
$champwin_exp = 10;

# ���b�N�J�n
Mebius::lock("Adventure-action-$advmy->{'id'}");

	# �����̃t�@�C�����J��
	my($adv) = &File("Action Flock Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1 , input_char => $main::in{'char'} , TypeChargeTimeCheckError => 1 });

# ���d�����e�X�g
#if(Mebius::alocal_judge()){ sleep(5); }

# �`�����v�t�@�C����ǂݍ���
my($champ) = &ChampFile();

	# �������`�����v�̏ꍇ�̓t���O�𗧂Ă� ( �ΐl�� / �����X�^�[�����Ȃ� )
	if($champ->{'id'} eq $adv->{'id'}){ $mychamp_flag = 1; }

	# ���L�����N�^�[�Ƃ̐퓬 
	if($main::mode eq "battle"){

		# �����X�^�[�Ƃ̐퓬����������ꍇ
		if($adv->{'human_battle_keep_count'} >= 3) { main::error("��x�����X�^�[�Ɠ����Ă�������"); }

		# �o�g�����[�h
		$BattleMode = "Human";

			# �D���ȑ����I��Ő퓬
			if($main::in{'target_id'} && $main::in{'target_id'} ne $champ->{'id'}){
				$enemy_id = $main::in{'target_id'};
				$select_battle_mode = 1;

				# ����t�@�C�����J��
				($enemy) = &File("File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $enemy_id , FormalPlayerCheckAndError => 1 });

			}

			# �`�����s�I���Ɛ퓬
			else{

				$enemy_id = $champ->{'id'};
				$champ_battle_flag = 1;

				# ����t�@�C�����J��
				($enemy) = &File("Allow-empty-id",{ InputFileType => $main::in{'file_type'} , id => $enemy_id , FormalPlayerCheckAndError => 1});

					# �`�����s�I���s�݂̏ꍇ�A���̂܂܏��Ђ�
					if($enemy->{'id'} eq ""){

						# �t�@�C���X�V
						my(%renew_champ);
						$renew_champ{'id'} = $adv->{'id'};
						$renew_champ{'name'} = $adv->{'name'};
						$renew_champ{'win_count'} = 1;
						&ChampFile({ TypeRenew => 1 },\%renew_champ);
			
						# HTML��\��
						$print = qq(�y���J���剤�����肼���A���Ȃ����`�����s�I���ɂȂ�܂����I $init->{'continue_button'});
						Mebius::Template::gzip_and_print_all({},$print);

						exit;

					}

			}

			# �E�Ɠ��m�̑����𔻒�i�����ɗL���ȏꍇ�j
			foreach(split(/,/,$adv->{'jobmatch'})){
					if($_ eq $enemy->{'jobname'}){
						$enemy->{'buffer_jobmatch'} = 1;
						$battle_start_message .= qq(�u$enemy->{'jobname'}�v�Ƃ�<strong style="color:#f00;">���₷��</strong>�E�Ƃ��c�c�I<br$main::xclose>);
					}
			}

			# �E�Ɠ��m�̑����𔻒�i����ɗL���ȏꍇ�j
			foreach(split(/,/,$enemy->{'jobmatch'})){
					if($_ eq $adv->{'jobname'}){
						$adv->{'buffer_jobmatch'} = 1;
						$battle_start_message .= qq(�u$enemy->{'jobname'}�v�Ƃ�<strong style="color:#00f;">�苭��</strong>�E�Ƃ��c�c�I<br$main::xclose>);
					}
			}

			if($enemy_id eq $adv->{'id'} && !Mebius::alocal_judge()){ main::error("�����Ƃ͐킦�܂���B"); }

			# ���x��������
			if($select_battle_mode){
					#if($adv->{'maxhp'} > $enemy->{'maxhp'}*$init->{'select_battle_gyap'} && !$alocal_mode){ main::error("�ő�HP���Ⴂ�����鑊��Ƃ͐킦�܂���B"); }
					if(time > $enemy->{'lasttime'}+$init->{'charaon_day'}*24*60*60){ main::error("���΂炭���O�C�����Ă��Ȃ�����Ƃ͐킦�܂���B"); }
					if($enemy_id eq $adv->{'lastwinid'} && !Mebius::alocal_judge()){ main::error("�O��|�����L�����N�^�[�Ƃ͘A�����Đ킦�܂���B"); }
			}

	}

	# �������X�^�[�Ƃ̐퓬
	if($main::mode eq "monster"){

		# �Ǐ���
		my(@monster,$monster_handler);

		# �o�g�����[�h
		$BattleMode = "Monster";

		# �����`�F�b�N
		$monster_rank = $main::in{'m_type'};
			if($monster_rank =~ /\D/){ main::error("�����X�^�[�̎w�肪�ςł��B"); }

		# �����X�^�[�̃p�����[�^
		$enemy->{'rank'} = $monster_rank;
		$enemy->{'brave'} = ($monster_rank*5);

		# �O���x���̃����X�^�[�ɂ܂������Ă��Ȃ��ꍇ
		if($monster_rank >= 1 && $adv->{'top_monster_level'} < $monster_rank && !Mebius::alocal_judge()){
				main::error("���̃��x���̃����X�^�[�Ƃ͂܂��킦�܂���B");
		}

		# �����X�^�[�Ƃ̐퓬����������ꍇ
		if(!$adv->{'mons'} && !Mebius::alocal_judge()) { main::error("��x�L�����N�^�[�Ɠ����Ă�������"); }

		# �t�@�C�����J��
		open($monster_handler,"<","$init->{'adv_dir'}_monster_data_adventure/monster$monster_rank.dat") || main::error("�����X�^�[�t�@�C�����J���܂���B");
			while(<$monster_handler>){
				push(@monster,$_);
			}
		close($monster_handler);
		
		# �����X�^�[�������_���őI��
		my $random = int(rand(@monster));
		my($mname,$mex,$mhp,$mdmg,$mskill,$mspecial) = split(/<>/,$monster[$random]);
		
		# �b��g�o���`
		$enemy->{'hp'} = $enemy->{'maxhp'} = int($mhp*0.5) + int(rand($mhp*0.6));

		# �����X�^�[�̋�������
		$monster_exp = int( ($mex * 0.7) + rand($mex*0.3*2) );
		$enemy->{'name'} = $mname;
		$enemy->{'buffer_monster_damage'} = $mdmg;
		$enemy->{'buffer_monster_skill'} = $mskill;
		$enemy->{'waza'} = $mspecial;
			if($enemy->{'waza'} eq ""){ $enemy->{'waza'} = qq(�S�H�H�H�H�I); }
		$enemy->{'spodds'} = 7;
		$enemy->{'spatack'} = "�K�E�Z";
		$enemy->{'buffer_monster_flag'} = 1;

		# �����X�^�[���x�����`
		$enemy->{'level'} = $monster_rank*$monster_rank*$monster_rank*25;

		# ������g��Ȃ��ꍇ
		#if($adv->{'jobconcept'} =~ /Magician-job/){
		#	$battle_start_message .= qq(���_�W���̂��߁A����͎g��Ȃ����Ƃɂ���B<br$main::xclose>);
		#	$adv->{'buffer_wepon_notuse'} = 1;
		#}

	}

	# ���L�����N�^�[��/�����X�^�[��ŋ��ʂ̔���

	# �����̐E�Ƃɍ���������͈З͂𔭊�
	if($adv->{'jobconcept'} =~ /Fighter-job/){
		foreach(split(/,/,$adv->{'item_job'})){
			if($adv->{'jobname'} eq $_){
				$adv->{'buffer_good_wepon'} = 1;
				$battle_start_message .= qq(��͂莩���ɍ���������͎g���₷���B<br$main::xclose>);
			}
		}
	}

	# ����̐E�Ƃɍ���������͈З͂𔭊�
	if($enemy->{'jobconcept'} =~ /Fighter-job/){
		foreach(split(/,/,$enemy->{'item_job'})){
			if($enemy->{'jobname'} eq $_){
				$enemy->{'buffer_good_wepon'} = 1;
			}
		}
	}

# �^�[����`
$i = 1;

	# �퓬�^�[����W�J
	foreach(1..20) {

		# �Ǐ���
		my($dmg1,$dmg2,$com1,$com2,$repair1,$repair2);

		# �����̍U�� ( ����̃_���[�W�v�Z )
		($dmg1,$repair1,$com1) = &DamageBattle({ BattleMode => $BattleMode , ChampBattleFlag => $champ_battle_flag , TypeOffence => 1 , turn => $i },$adv,$enemy);

		# �G�̍U�� ( �����̃_���[�W�v�Z )
		($dmg2,$repair2,$com2) = &DamageBattle({ BattleMode => $BattleMode , ChampBattleFlag => $champ_battle_flag , TypeDefence => 1 , turn => $i },$enemy,$adv);

		# �J���}��t����
		($kmaxhp_comma,$wmaxhp_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$adv->{'maxhp'},$enemy->{'maxhp'}]);

		# �^�[�����ʕ\���̒ǉ�
		($save_khp_comma,$save_whp_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$adv->{'hp'},$enemy->{'hp'}]);

		$turn_results .= qq(<div class="turn"><h2>�^�[��$i</h2>);

		$turn_results .= qq(<div class="atack_left">);
		$turn_results .= qq(<h3><strong class="hpcolor">HP $save_khp_comma / $kmaxhp_comma</strong></h3>);
		$turn_results .= qq(
		<div class="comment_atack">
		$com1
		</div>
		<br>
		</div>
		);

		$turn_results .= qq(<div class="atack_right">);
		$turn_results .= qq(<h3><strong class="hpcolor">HP $save_whp_comma / $wmaxhp_comma</strong></h3>);
		$turn_results .= qq(
		<div class="comment_atack">
		$com2
		</div>
		<br>
		</div>
		);

		$turn_results .= qq(</div>);

		# �b��g�o�̌v�Z
		$adv->{'hp'} = $adv->{'hp'} - $dmg2 + $repair1;
		$enemy->{'hp'} = $enemy->{'hp'} - $dmg1 + $repair2;
			if($adv->{'hp'} >= $adv->{'maxhp'}){ $adv->{'hp'} = $adv->{'maxhp'}; }
			if($enemy->{'hp'} >= $enemy->{'maxhp'}){ $enemy->{'hp'} = $enemy->{'maxhp'}; }
			if($adv->{'hp'} <= 0){ $adv->{'hp'} = 0; }
			if($enemy->{'hp'} <= 0){ $enemy->{'hp'} = 0; }

		# HP�Čv�Z
		($save_khp_comma,$save_whp_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$adv->{'hp'},$enemy->{'hp'}]);

			# �ǂ��炩���������ꍇ�A�^�[���I��
			if($adv->{'hp'} <= 0 && $enemy->{'hp'} <= 0){
				$sametime_down_flag = 1;
					# �E�C�Ŕ���
					if(rand($adv->{'brave'}+75) >= rand($enemy->{'brave'}+50)){ $win = 1; }
					else{ $lose = 1; }
				last;
			}
			# ����҂̏���
			elsif($enemy->{'hp'} <= 0) { $win = 1; last; }
			# ����̏���
			elsif($adv->{'hp'} <= 0) { $lose = 1; last; }

		$i++;
	}

	# ���s�̒���
	if($win){
		$enemy_lose = 1;
	}
	elsif($lose){
		$enemy_win = 1;
	}
	else{
		$draw_flag = 1;
	}

# �A���s�����֎~
Mebius::Redun(undef,"ADV_ACTION",$adv->{'redun'});

	# �`�����v�t�@�C���̍X�V �i����҂̏����j
	if($win && $main::mode eq "battle" && $champ_battle_flag){
		$champ_change_flag = 1;

		# �t�@�C���X�V
		my(%renew_champ);
		$renew_champ{'id'} = $adv->{'id'};
		$renew_champ{'name'} = $adv->{'name'};
		$renew_champ{'win_count'} = 1;
		&ChampFile({ TypeRenew => 1 },\%renew_champ);

	}

	# �`�����v�t�@�C���̍X�V �i�`�����v�̏����j
	if($enemy_win && $main::mode eq "battle" && $champ_battle_flag){

		# �t�@�C���X�V
		my(%renew_champ);
		$renew_champ{'id'} = $enemy->{'id'};
		$renew_champ{'name'} = $enemy->{'name'};
		$renew_champ{'+'}{'win_count'} = 1;
		my($renewed_champ) = &ChampFile({ TypeRenew => 1 },\%renew_champ);

			# �틵���L�^
			if($renewed_champ->{'win_count'} % 10 == 0 && $renewed_champ->{'win_count'} >= 10 && !$adv->{'test_player_flag'}){
				my $NewComment1 = qq($enemy->{'chara_link'} ��);
				my $NewComment2 = qq(<span class="red">$renewed_champ->{'win_count'}�A��</span> ��B�����܂����B);
				&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
			}

		# �A���L�^�t�@�C���̍X�V
		require Mebius::Adventure::Record;
		&Record("Renew","",$enemy->{'name'},$renewed_champ->{'win_count'},$enemy->{'id'});

	}

	# �s���L�^
	if($win){ $winlose_text = qq(�킢�𒧂�� <span class="red">����</span> ���܂����B); }
	else{ $winlose_text = qq(�킢�𒧂݂܂����B); }  
	if($champ_battle_flag){ $enemy->{'chara_link'} = qq($enemy->{'chara_link'} - <span class="red">�`�����v</span> ); }

	# �틵���L�^
	if($main::mode eq "battle" && !$adv->{'test_player_flag'}){
		my $NewComment1 = qq($adv->{'chara_link'} ��);
		my $NewComment2 = qq($enemy->{'chara_link'} ��$winlose_text);
		&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
	}

	# �������ꍇ �i�ΐl��j
	if($win && $main::mode eq "battle") {

		$exp = int($enemy->{'level'}*$init->{'kiso_exp'}*0.8) + int($enemy->{'maxhp'}*0.2);
			if($champ_battle_flag){ $exp *= $champwin_exp; }
		$gold = $enemy->{'level'} * 7 + int(rand($enemy->{'level'} * 6));

			# �틵���L�^
			if($champ_battle_flag && !$adv->{'test_player_flag'}){
				my $NewComment1 = qq($adv->{'chara_link'}��);
				my $NewComment2 = qq(�V�`�����s�I���ɂȂ�܂����B);
				&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
			}

	}

	# �������ꍇ �i�`�����v��j
	elsif($enemy_win && $main::mode eq "battle"){
		$exp = int( ($adv->{'level'} * $init->{'kiso_exp'}) * 0.75 );
	}

	# �������ꍇ�i�����X�^�[��j
	if($win && $main::mode eq "monster"){
		$exp = $monster_exp*0.9;
		$gold = $adv->{'level'} * 7 + int(rand($adv->{'level'} * 6));
	}

	# �������ꍇ�i�����X�^�[��j
	if($enemy_win && $main::mode eq "monster"){
		$exp = 0;
		if($adv->{'gold'} >= 1) { $gold = int($adv->{'gold'} * 0.35) * -1; }
	}

	# ���������̏ꍇ �i�����X�^�[��j
	elsif($main::mode eq "monster"){ }

# �o���l�A�l���S�[���h�̋��ʒ���
#require Mebius::Adventure::Adjust;
($exp,$gold,$bank,$pure_gold) = &ExpGold("Auto-bank",$exp,$gold,$adv);

	# �������̃L�����f�[�^���X�V �i���ʏ����j
	{

		# �錾
		my($renew,$levelup_comment,$comment_hp);

		# �t�@�C�����J��
		my($adv2) = &File("Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1 , input_char => $main::in{'char'} , TypeChargeTimeCheckError => 1 } );

				# ���E�C�̑���
				if($main::mode eq "battle"){

						# �`�����v��
						if($champ_battle_flag){

								# ���������ꍇ
								if($win && rand(3) < 1){ $renew->{'+'}{'brave'} = 1; }
								# �s�k�����ꍇ
								elsif(rand(30) < 1){ $renew->{'+'}{'brave'} = 1; }

						}
						# ���ʂ̑ΐl�� (���������)
						elsif($enemy->{'all_level'} && $adv->{'all_level'}){

								# ��������Ɛ�����ꍇ
								if($enemy->{'all_level'} >= $adv->{'all_level'}*1.25){

									# ��������Ɛ�����񐔂��J�E���g
									$renew->{'+'}{'human_battle_dog_count'} = 1;

										# ��������ΗE�C�𑝂₷
										if($win && rand(5) < 1){
											$renew->{'+'}{'brave'} = 1;
										}

								}
								# �ア����Ɛ�����ꍇ
								elsif($adv->{'all_level'} >= $enemy->{'all_level'}*1.25){

									# �ア����Ɛ�����񐔂��J�E���g
									$renew->{'+'}{'human_battle_chicken_count'} = 1;

										# ����������ŗE�C�����炷
										if(rand(2) < 1){
											$renew->{'-'}{'brave'} = 1;
										}
								}
						}

				}

			# ����Ɖ������`
			$renew->{'>='}{'brave'} = 0;
			$renew->{'<='}{'brave'} = 100;

				# ���s���̕ύX
				if($main::mode eq "battle"){
					$renew->{'+'}{'total'} = 1;
						if($win){ $renew->{'+'}{'win'} = 1; }
						elsif($draw_flag){ $renew->{'+'}{'draw'} = 1; }
						if($win && $champ_battle_flag){ $renew->{'+'}{'human_battle_win_champ_count'} = 1; }
				}

				# ���s���̕ύX ( �����X�^�[ )
				elsif($main::mode eq "monster"){
					$renew->{'+'}{'monster_battle_count'} = 1;
						if($win){ $renew->{'+'}{'monster_battle_win_count'} = 1; }
						elsif($lose){ $renew->{'+'}{'monstet_battle_lose_count'} = 1; }
						elsif($draw_flag){ $renew->{'+'}{'monster_battle_draw_count'} = 1; }
				}

			# ��_���[�W
			$renew->{'hp'} = $adv->{'hp'};
			$adv2->{'hp'} = $adv->{'hp'};

			# �l�������l
			$renew->{'+'}{'exp'} = $exp;
			$adv2->{'exp'} += $exp;
			$renew->{'+'}{'gold'} = $gold;
			$adv->{'gold'} += $gold;
			$renew->{'+'}{'bank'} = $bank;
			$adv->{'bank'} += $bank;

			# �_���[�W��
			#$plustype_levelup
			#my $plustype_levelup = qq(Battle-win) if($win);
			#$comment_hp_line = $comment_hp_line;
			#($levelup_comment,$adv2,$renew) = &DamageRepair(undef,$adv2,$renew);
		# �_���[�W��
		($comment_hp,$adv2,$renew) = &RepairHP({ WinFlag => $win , ChampFlag => $mychamp_flag },$adv2,$renew);
			if($comment_hp){ $comment_hp_line = qq($comment_hp); }

		# ���x���A�b�v����
		($levelup_comment_line,$adv2,$renew) = levelup_round($adv2,$renew);

				# �����ǃL�����Ɛ�����ꍇ�́A�܂������X�^�[�Ɛ킦��悤��
				if($main::mode eq "battle"){
					$adv2->{'mons'} = $init->{'sentou_limit'};
					$renew->{'mons'} = $init->{'sentou_limit'};
					$renew->{'+'}{'human_battle_keep_count'} = 1;
				}

				# �Ō�ɏ����������ID���L��
				if($select_battle_mode && $win){
					$renew->{'lastwinid'} = $enemy->{'id'};
					$adv2->{'lastwinid'} = $enemy->{'id'};
				}

				# �Ō�ɐ���������X�^�[�̃��x�����L��
				if($main::mode eq "monster"){ $renew->{'last_select_monster_rank'} = $monster_rank; }

				# ���̃��x���ŏ��������ꍇ�A���Ƀ`�������W�ł��郂���X�^�[���x�����������
				if($main::mode eq "monster"){
						if($win && (!$adv2->{'top_monster_level'} || $monster_rank >= $adv2->{'top_monster_level'})){
							$renew->{'top_monster_level'} = $monster_rank + 1;
						}
					$renew->{'-'}{'mons'} = 1;
					$renew->{'human_battle_keep_count'} = 0;
				}


		# �t�@�C���X�V
		&File("Renew Mydata Charge-time Password-check",{  InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1 , input_char => $main::in{'char'} , TypeChargeTimeCheckError => 1  } ,$renew);
	}

	# ������̃L�����f�[�^���X�V
	if($main::mode eq "battle"){
		my(%renew,$enemy2);

			# �t�@�C�����J��
			if($champ_battle_flag){
				($enemy2) = &File("File-check-error",{ FileType => "Account" , id => $enemy_id , FormalPlayerCheckAndError => 1});
			}
			else{
				($enemy2) = &File("File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $enemy_id , FormalPlayerCheckAndError => 1});
			}

		# �퓬��
		$renew{'+'}{'total'} = 1;

			# ����
			if($enemy_win){
				$renew{'+'}{'win'} = 1;
				$renew{'+'}{'exp'} = int($adv->{'level'} * $init->{'kiso_exp'} * $init->{'game_speed'});
			}
			# �s�k
			elsif($enemy_lose){
				$renew{'+'}{'exp'} = int($enemy->{'level'} * $init->{'kiso_exp'}  * $init->{'game_speed'});
				$renew{'champ'} = 0;
			}
			# �h���[
			elsif($draw_flag){
				$renew{'+'}{'draw'} = 1;
			}

		$renew{'hp'} = $enemy->{'hp'};

			# HP���ő�HP�ȏ�ɂȂ�Ȃ��悤��
			if($renew{'hp'} > $enemy2->{'maxhp'}) { $renew{'hp'} = $enemy2->{'maxhp'}; }

			# HP���[���ɂȂ����ꍇ�͊��S��
			if($renew{'hp'} <= 0) { $renew{'hp'} = $enemy2->{'maxhp'}; }

			# �t�@�C�����X�V
			if($champ_battle_flag){
				&File("Renew File-check-error",{ FileType => "Account" , id => $enemy_id , FormalPlayerCheckAndError => 1 },\%renew);
			}
			else{
				&File("Renew File-check-error",{ InputFileType => $main::in{'target_file_type'} , id => $enemy_id , FormalPlayerCheckAndError => 1 },\%renew);
			}

	}

# ���b�N����
Mebius::unlock("Adventure-action-$advmy->{'id'}");

# �����W�����v�A�c��b���\��
my($head_javascript,$view_jsredirect);
($head_javascript,$view_jsredirect) = &get_jsredirect({ TypeAllowPost => 1 },$adv->{'redun'});
$main::head_javascript = $head_javascript;

	# H1�^�C�g��
	if($main::mode eq "battle" && $champ_battle_flag){ $h1 = qq(�`�����v - $enemy->{'name'} ( ���x��$enemy->{'level'} $enemy->{'jobname'} ) �ɐ킢�𒧂񂾁I�I); }
	if($main::mode eq "battle" && $select_battle_mode){ $h1 = qq($enemy->{'name'} ( ���x��$enemy->{'level'} $enemy->{'jobname'} ) �ɐ킢�𒧂񂾁I�I); }
	if($main::mode eq "monster"){ $h1 = qq($enemy->{'name'} �����ꂽ�I�I); }

my $view_getgold = $pure_gold;
my $view_bank = int($view_getgold * $adv->{'autobank'}*0.01);

# �J���}��t����
my($getexp_comma,$getgold_comma,$gold_comma,$bank_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$exp,$view_getgold,$gold,$view_bank]);

	# ����/�s�k�R�����g
	if($sametime_down_flag){ $comment .= qq(�Ȃ�Ɨ��ғ����ɓ|�ꂽ�c�c�B<br$main::xclose>); }
	if($win){ $comment .= qq(<b><font size="5">$advmy->{'name'}�́A�퓬�ɏ��������I�I</font></b>); }
	if($win && $champ_battle_flag){ $comment .= qq(<br>���߂łƂ��������܂��A<strong class="red">���Ȃ����`�����s�I���ł��I</strong>); }
	if($enemy_win){ $comment .= qq(<b><font size="5">$advmy->{'name'}�́A�퓬�ɕ������c�c�B</font></b>); }
	if(!$win && !$lose){ $comment .= qq(<b>�^�[���I�[�o�[�A���������܂���ł����B</b>); }
	if($win && $champ_battle_flag){ $comment .= qq(<br>$champwin_exp�{�̌o���l���l���I); }
	if($exp >= 1){ $comment .= qq(<br><b class="expcolor">$getexp_comma</b> �̌o���l����ɓ��ꂽ�B); }
	if($view_getgold >= 0){
		$comment .= qq(<br><b class="goldcolor">$getgold_comma \G</b> ����ɓ��ꂽ�B);
			if($bank >= 1){ $comment .= qq(���̂��� $adv->{'autobank'}\�� ( <b class="goldcolor">$bank_comma\G</b> ) ����s�Ɏ����U�ւ����B); }
	}
	if($view_getgold < 0){ $comment .= qq(<br>�������������� �i<b>$gold_comma</b>G�j�B); }

# HTML
$print .= qq(
<h1>$h1</h1>
$init_login->{'link_line'});

$print .= qq($view_jsredirect\n);

$print .= qq($battle_start_message
$turn_results
<h2>����</h2>
<div class="turn">
<div class="atack_left">
<h3><strong class="hp hpcolor">HP $save_khp_comma / $kmaxhp_comma</strong></h3>
</div>

<div class="atack_right">
<h3><strong class="hp hpcolor">HP $save_whp_comma / $wmaxhp_comma</strong></h3>
</div>

<div class="clear result_comment">
$comment
$comment_hp_line
$levelup_comment_line
</div>
);


$print .= qq($init->{'continue_button'}</div>);


Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# �E�Ƃ��Ƃ̃_���[�W�v�Z
#-----------------------------------------------------------
sub DamageBattle{

# ����
# $use->{'TypeDefence'} �� �h�q���ł́u�U���v������ۂɎg�p����t���O

# �Ǐ���
my($init) = &Init();
my($use,$adv,$enemy) = @_;
my($damage,$skilldmg1,$skilldmg2,$com,$repair,$critical_odds,$bluefire_flag,$atack_comment,$damage_comma,$rand_spatack);
my($item_damage_point,$job_atack_block_flag,$repair_line,$damage_line,$not_view_damage_flag,$wepon_use_line,$job_atack_line);
my($critical_line,$special_atack_line,$guard_line);
my($bluefire_block_flag,$critical_block_flag,$special_atack_block_flag,$special_guard_block_flag);
my $turn = $use->{'turn'};

	# ���x���ɂ��_���[�W�v�Z �i �ΐl�� �j
	if($use->{'BattleMode'} eq "Human"){ $damage = $adv->{'level'} * (int(rand(3)) + 1); }

	# ���x���ɂ��_���[�W�v�Z ( �����X�^�[ )
	elsif($use->{'BattleMode'} eq "Monster"){ $damage = $adv->{'level'} * (int(rand(5)) + 1); }

	# ���̑�
	else{
		main::error("�ΐ탂�[�h���w�肳��Ă��܂���B");
	}

	# �E�ƕʂ̃_���[�W�v�Z
	if($adv->{'jobname'} eq "��m"){
		$skilldmg1 = int(rand($adv->{'power'}));
		$atack_comment = qq(���Ő؂�����I);
	}
	elsif($adv->{'jobname'} eq "���@�g��"){
		$skilldmg1 = int(rand($adv->{'brain'}));
		$atack_comment = qq(���@���������I);
	}
	elsif($adv->{'jobname'} eq "�m��"){
		$skilldmg1 = int(rand($adv->{'believe'}));
		$atack_comment = qq(���@���������I);
	}
	elsif($adv->{'jobname'} eq "����"){
		$skilldmg1 = int(rand($adv->{'tec'}*0.5)+rand($adv->{'speed'}*0.5));
		$atack_comment = qq(���p����؂�����I);
	}
	elsif($adv->{'jobname'} eq "�x��q"){
		$skilldmg1 = int(rand($adv->{'charm'}));
		$skilldmg2 = int(rand($adv->{'speed'}));
		$atack_comment = qq(�ؗ�ɓ��݂����I);
	}
	elsif($adv->{'jobname'} eq "�����W���["){
		$skilldmg1 = int(rand($adv->{'vital'}));
		$skilldmg2 = int(rand($adv->{'power'}));
		$atack_comment = qq(����˂��I);
	}
	elsif($adv->{'jobname'} eq "�B���p�t"){
		$skilldmg1 = int(rand($adv->{'brain'}));
		$skilldmg2 = int(rand($adv->{'tec'}));
		$atack_comment = qq(�_�𓊂������I);
	}
	elsif($adv->{'jobname'} eq "��V���l"){
		$skilldmg1 = int(rand($adv->{'charm'}));
		$skilldmg2 = int(rand($adv->{'tec'}));
		$atack_comment = qq(�􂢂̉̂����񂾁I);
	}
	elsif($adv->{'jobname'} eq '���\�͎�'){
		$skilldmg1 = int(rand($adv->{'brain'}));
		$skilldmg2 = int(rand($adv->{'vital'}));
		$atack_comment = qq(���\\�͂��g�����I);
	}
	elsif($adv->{'jobname'} eq "���@���L���["){
		$skilldmg1 = int(rand($adv->{'believe'}));
		$skilldmg2 = int(rand($adv->{'brain'}));
		$atack_comment = qq(���얂�@���������I);
	}
	elsif($adv->{'jobname'} eq "�i��"){
		$skilldmg1 = int(rand($adv->{'charm'}));
		$skilldmg2 = int(rand($adv->{'believe'}));
		$atack_comment = qq(�ق��̋F���������I);
	}
	elsif($adv->{'jobname'} eq "�N��"){
		$skilldmg1 = int(rand($adv->{'power'}));
		$skilldmg2 = int(rand($adv->{'believe'}));
		$atack_comment = qq(�_���ȗ͂Ő؂�����I);
	}
	elsif($adv->{'jobname'} eq "��"){
		$skilldmg1 = int(rand($adv->{'tec'}));
		$skilldmg2 = int(rand($adv->{'speed'}));
		$atack_comment = qq(������M�����I);
	}
	elsif($adv->{'jobname'} eq "�C�s�m"){
		$skilldmg1 = int(rand($adv->{'power'}));
		$skilldmg2 = int(rand($adv->{'believe'}));
		$atack_comment = qq(�������I);
	}
	elsif($adv->{'jobname'} eq "�E��"){
		$skilldmg1 = int(rand($adv->{'speed'}));
		$skilldmg2 = int(rand($adv->{'power'}));
		$atack_comment = qq(�E�ъ�����I);
	}

	# ���ΐl��A�_���[�W�␳ (�L�����N�^�[)
	if($use->{'BattleMode'} eq "Human"){

			# ��m�^�C�v
			if($adv->{'jobconcept'} =~ /Fighter-job/){
				$damage += ($skilldmg1 + $skilldmg2);
			}
			
			# ���@�^�C�v
			elsif($adv->{'jobconcept'} =~ /Magician-job/){
				$damage += ($skilldmg1 + $skilldmg2) * 1.5;
			}

	}

	# �������X�^�[��A�_���[�W�␳ (�L�����N�^�[)
	elsif($use->{'BattleMode'} eq "Monster"){

			# �����X�^�[���^����_���[�W
			if($adv->{'buffer_monster_flag'}){
				$damage = (int(rand($adv->{'buffer_monster_damage'})) + 1) + $adv->{'buffer_monster_damage'};
				$atack_comment = qq(�P�����������I�I);
			}

			# �E�Ɛ�m�̃_���[�W�v�Z
			elsif($adv->{'jobname'} eq "��m"){
				$damage += ($skilldmg1 + $skilldmg2);
			}

			# ��m�^�C�v�̃_���[�W�v�Z
			elsif($adv->{'jobconcept'} =~ /Fighter-job/){
				$damage *= ($skilldmg1 * 0.80) + ($skilldmg2 * 0.60);
			}

			# ���@�^�C�v�̃_���[�W�v�Z
			elsif($adv->{'jobconcept'} =~ /Magician-job/){
				$damage *= ($skilldmg1 * 1.00) + ($skilldmg2 * 0.80);
			}

	}

	# �����̋��ȐE�Ƃ�����̏ꍇ�́A�_���[�W�ʂ����炷
	if($adv->{'buffer_jobmatch'}){
		$damage *= 0.8;
	}

# ��{�U�����b�Z�[�W
$com .= qq($adv->{'name'}��$atack_comment);

	# �����X�^�[�A�[��̃p���[�A�b�v
	if($use->{'TypeDefence'} && $adv->{'buffer_monster_flag'} && $main::thishour >= 0 && $main::thishour <= 4){
		$damage *= 1.5;
		$com .= qq(<br><span class="special">�����ł��p���[�𑝕�������I</span>);
	}

	# �����X�^�[�A�����̃p���[�_�E��
	if($use->{'TypeDefence'} && $adv->{'buffer_monster_flag'} && ($main::thishour >= 6 && $main::thishour <= 7)){
		$damage *= 0.6;	
		$com .= qq(<br><span class="special">���������׈��ȗ͂���߂Ă���I</span>);
	}

	# �����X�^�[��F ��m�́u���肪�����x���v�{�[�i�X
	if($use->{'BattleMode'} eq "Monster" && $adv->{'level'} >= 100){
			if($adv->{'jobname'} eq '��m' && $enemy->{'rank'} >= 9){
				$com .= qq(<br>�育�킢����ɐS���x��I);
				$damage *= 50;
			}
	}

	# ������̎g�p
	if($adv->{'item_number'}){

		# �Ǐ���
		my($item_boost_damege);

			# ����m�^�C�v�̃_���[�W�v�Z
			if($adv->{'jobconcept'} =~ /Fighter-job/){

					# �����X�^�[��
					if($use->{'BattleMode'} eq "Monster"){
							if($enemy->{'rank'} >= 6){
								$item_damage_point += $adv->{'item_damage_all'} * ($enemy->{'rank'}**4);
							}
							else{
								$item_damage_point += $adv->{'item_damage_all'}*4.5;
							}
					}
					# �ΐl��
					elsif($use->{'BattleMode'} eq "Human"){
						$item_damage_point = $adv->{'item_damage_all'}*2;
					}

			}

			# �����@�^�C�v�̃_���[�W�v�Z
			elsif($adv->{'jobconcept'} =~ /Magician-job/){

					# �����X�^�[��
					if($use->{'BattleMode'} eq "Monster"){
							if($enemy->{'rank'} >= 6){
								$item_damage_point += $adv->{'item_damage_all'} * ($enemy->{'rank'}**3);
							}
							else{
								$item_damage_point += $adv->{'item_damage_all'}*1.5;
							}
					}
					# �ΐl��
					elsif($use->{'BattleMode'} eq "Human"){
						$item_damage_point = $adv->{'item_damage_all'}*1;
					}

			}

			# �����̐E�Ƃɍ���������͈З͂�����
			if($adv->{'buffer_good_wepon'}){
				$item_damage_point *= 1.5;
			}
				
		# �����_���[�W�ɒǉ�
		$damage += $item_damage_point;

			# �������肭�g���Ȃ��E��
			if($adv->{'jobname'} eq "�E��" && $adv->{'item_name'} !~ /�E��/){
				$damage *= 0.4;
				$wepon_use_line .= qq(<br>$adv->{'item_name'}���ז��ɂȂ�B);
			}
			# ����𕁒ʂɎg��
			else{
				$wepon_use_line .= qq(<br>���������$adv->{'item_name'}�ōU�������I);
			}
	}

	# ������ (�L�����퓬���̂�)
	if($use->{'BattleMode'} eq "Human" && $enemy->{'maxhp'} >= $adv->{'maxhp'}*2.5 && $turn == 1 && rand(2.0) < 1) {

			# ����
			if($adv->{'maxhp'} >= 1){

				# �Ǐ���
				my($plus_damage);

				# ������HP�Ƒ����HP�����ƂɃ_���[�W���v�Z
				$plus_damage = ($adv->{'hp'} * 0.50);

						# �`�����v��̈З�
						if($use->{'ChampBattleFlag'}){
							$plus_damage + ($enemy->{'hp'} * 0.05);
						}

					# ����
					if($plus_damage >= $damage){

						# ����
						$com .= qq(<br><strong class="bluefire">���|�I�Ȏ��͍��ɁA�������N���オ��c�c�B</strong>);

							# ������
							if($enemy->{'jobname'} eq "�B���p�t"){
								$com .= qq(<br>��������������͔���������Ă���I�@����Ăĉ΂��������B);
							}
							# ����
							else{
								$damage += $plus_damage;
								$critical_block_flag = 1;
								$special_atack_block_flag = 1;
								$job_atack_block_flag = 1;
							}
					}
			}
	}

	# ���G�̓���\�͕��E  -------------------------
	if(($enemy->{'jobname'} eq "�m��" && rand(1.7) < 1) || ($enemy->{'buffer_monster_skill'} =~ /���ꖳ����/ && rand(2.5) < 1)){
			$guard_line .= qq(<br><span class="red">��������U���͖W����ꂽ�B</span>);
			$job_atack_block_flag = 1;
			$critical_block_flag = 1;
			$special_atack_block_flag = 1;
	}

	# ���K�E�Z
	if(!$special_atack_block_flag){

			# ��������m��
			if($adv->{'buffer_monster_flag'}){ $rand_spatack = 80; }
			else{ $rand_spatack = 25; }

			# ����̕���ɂ���ẮA�K�E�Z���o�₷��
			if($enemy->{'item_concept'} =~ /Getexp-boost/){ $rand_spatack /= 2.00; }

			# �m���v�Z
			if(rand($rand_spatack) < 1 && $adv->{'waza'} && $adv->{'spatack'} && $adv->{'spodds'} && !$bluefire_flag) {
				$special_atack_line = qq(�u<b>$adv->{'waza'}</b>�v\n);
				$special_atack_line .= qq(<br><font size="4">$adv->{'name'}��<strong class="spatack">$adv->{'spatack'}</strong>��������I</font>);
				$damage = $damage * $adv->{'spodds'};
			}
	}

	# ���N���e�B�J���U��
	if(!$critical_block_flag){

			# ��������m��
			if($adv->{'jobname'} eq "��"){
				my $rand = 12 - ($adv->{'level'}*0.005);
				if($rand < 2){ $rand = 2; }
				$critical_odds = $rand;
			}
			elsif($adv->{'buffer_monster_flag'}){ $critical_odds = 20; }	# �����X�^�[�̃N���e�B�J����
			else{ $critical_odds = 15; }								# �L�����N�^�[�̃N���e�B�J����
			if($enemy->{'item_concept'} =~ /Getexp-boost/){ $critical_odds /= 2.00; }	# ����̕���ɂ���ẮA�N���e�B�J�����o�₷��

			# �N���e�B�J���U��
			if(rand($critical_odds) < 1 && !$bluefire_flag) {
				$critical_line .= qq(<br><strong class="clitical">�����ꌂ�I</strong>);
				$damage *= 3;
			}
	}

	# �������̐E�Ɠ��L�U��  -------------------------
	if(!$job_atack_block_flag){

			# ��m�̃A�C�e�����ʑ���
			if($adv->{'jobname'} eq "��m" && rand(2.5) < 1 && $adv->{'level'} >= 100){
					if($use->{'BattleMode'} eq "Monster"){ $damage += $adv->{'item_damage_all'}*5; }
					elsif($use->{'BattleMode'} eq "Human"){ $damage += $adv->{'item_damage_all'}*3.0; }
				$wepon_use_line .= qq(<br><span class="special">��������̗͂��ő���ɔ��������B</span>);
			}

			# �E�҂ƏC�s�m�̃_���[�W�u�[�X�g
			if($adv->{'jobname'} eq "�E��" && $use->{'BattleMode'} eq "Monster"){ 
				my $damage_boost = 0.5 + ($adv->{'level'} * 0.001);
				if($damage_boost > 20){ $damage_boost = 20; }
				$damage *= $damage_boost;
			}
			if($adv->{'jobname'} eq "�C�s�m" && $use->{'BattleMode'} eq "Monster"){
				my $damage_boost = 0.5 + ($adv->{'level'} * 0.001);
				if($damage_boost > 10){ $damage_boost = 10; }
				$damage *= $damage_boost;
			}
			if($adv->{'jobname'} eq "�E��" && $use->{'BattleMode'} eq "Human"){ 
				my $damage_boost = 0.75 + ($adv->{'level'} * 0.00025);
				if($damage_boost > 3.0){ $damage_boost = 3; }
				$damage *= $damage_boost;
			}
			if($adv->{'jobname'} eq "�C�s�m" && $use->{'BattleMode'} eq "Human"){
				my $damage_boost = 0.75 + ($adv->{'level'} * 0.00025);
				if($damage_boost > 1.5){ $damage_boost = 1.5; }
				$damage *= $damage_boost;
			}

			# �u�����x�������E�v�̃{�[�i�X ( ����ł����X�_���[�W�͔����Ƃ������Ƃɗ��� )
			if($adv->{'jobconcept'} =~ /Amateur-job/){
					if($adv->{'level'} >= 10000){ $damage *= 3.5; }
					elsif($adv->{'level'} >= 7500){ $damage *= 3.0; }
					elsif($adv->{'level'} >= 5000){ $damage *= 2.5; }
					elsif($adv->{'level'} >= 2500){ $damage *= 2.0; }
					elsif($adv->{'level'} >= 1000){ $damage *= 1.5; }
			}

			# ���@�g���̎􂢂̗�
			if($adv->{'jobname'} eq "���@�g��" && $use->{'BattleMode'} eq "Human" && $use->{'TypeDefence'} && $adv->{'level'} >= 100){
				$damage *= 1.5;
				$job_atack_line .= qq(<br><span class="red">�����􂢂̗͂ŕԂ蓢���ɁI</span>);
			}

			# �^�[����ǂ����ƂɍU���͂�����
			if(($adv->{'jobname'} eq '�N��' || $adv->{'jobname'} eq '�����W���[') && $adv->{'level'} >= 100){

					# �Ǐ���
					my($turn_damage);

						# �_���[�W�ʂ��`
						if($use->{'BattleMode'} eq "Monster"){ $turn_damage = (2**($turn+3)); }
						elsif($use->{'BattleMode'} eq "Human"){ $turn_damage = (2**($turn)); }

						# �_���[�W���v���X�̏ꍇ�͑����_���[�W�ɒǉ�
						if($turn_damage >= 1){
							$damage += $turn_damage;
							#$job_atack_line .= qq(<br><span class="special">����$adv->{'jobname'}�͎��Ԃ��o�قǋ����Ȃ�I</span>);
								if(Mebius::alocal_judge()){ $job_atack_line .= qq( (+$turn_damage)); }
						}

			}

			# ���\�͎҂̋N����
			if($adv->{'jobname'} eq '���\�͎�' && $adv->{'hp'} < $adv->{'maxhp'} * 0.075){
				$job_atack_line .= qq(<br><span class="special">�����N���񐶂̍U���I</span>);
					if($adv->{'hp'} < $adv->{'maxhp'} * 0.005){ $damage *= 300; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.01){ $damage *= 100; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.02){ $damage *= 50; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.03){ $damage *= 25; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.04){ $damage *= 10; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.05){ $damage *= 5; }
					elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.075){ $damage *= 2; }
			}

			# �i���̑ΐl�U��
			if($adv->{'jobname'} eq "�i��" && $use->{'BattleMode'} eq "Human"){
					if($adv->{'level'} >= 15000){ $damage *= 2.80; }
					elsif($adv->{'level'} >= 10000){ $damage *= 2.60; }
					elsif($adv->{'level'} >= 7500){ $damage *= 2.40; }
					elsif($adv->{'level'} >= 5000){ $damage *= 2.20; }
					elsif($adv->{'level'} >= 2500){ $damage *= 2.00; }
					elsif($adv->{'level'} >= 1000){ $damage *= 1.80; }
					else{ $damage *= 1.60; }
				$job_atack_line .= qq(<br><span class="special">��������Ȍ��͂̑O�ɁA$enemy->{'name'}�͋�����Ȃ��Ă���B</span>);
			}

			# ��V���l�̑΃����X�^�[�U��
			if($adv->{'jobname'} eq "��V���l" && $use->{'BattleMode'} eq "Monster"){
					if($adv->{'level'} >= 10000){ $damage *= 16.0; }
					elsif($adv->{'level'} >= 7500){ $damage *= 13.0; }
					elsif($adv->{'level'} >= 5000){ $damage *= 10.0; }
					elsif($adv->{'level'} >= 2500){ $damage *= 7.0; }
					elsif($adv->{'level'} >= 1000){ $damage *= 4.0; }
					else{ $damage *= 2.0; }
				$job_atack_line .= qq(<br><span class="special">�������m�̃����f�B�[�ɁA$enemy->{'name'}�͗͂����߂Ă���B</span>);
			}


			# �����@�g���̃G�i�W�[�h���C��
			if($adv->{'jobname'} eq "���@�g��" && rand(8) < 1 && $adv->{'level'} >= 100){
				$repair += $damage*0.5;
				$job_atack_line .= qq(<br><span class="special">�����G�i�W�[�h���C���I �����HP���z���グ���B</span>);
			}

			# �E�҂̈ÎE
			if(($adv->{'jobname'} eq "�E��" || $adv->{'buffer_monster_skill'} =~ /�ÎE����/) && $adv->{'level'}*1.5 >= $enemy->{'level'} && $adv->{'level'} >= 100){
				my $rand = 135 - ($adv->{'level'}/50);
						if($rand < 35){ $rand = 35; }	# �ō������m�� ( 1 / x )
						if($use->{'BattleMode'} eq "Monster"){ $rand += 15; }
						if($adv->{'buffer_monster_flag'}){ $rand = 100; }	# �����X�^�[���d�|����m��
						# �ÎE����
						if(rand($rand) < 1){
							$job_atack_line .= qq(<span class="special">);
							$job_atack_line .= qq(����$adv->{'name'}��<strong class="red">�ÎE</strong>���d�|�����I);
								if($enemy->{'item_concept'} =~ /Anti-assassin/ || $enemy->{'jobname'} eq "�N��" || $enemy->{'buffer_monster_skill'} =~ /�ÎE������/){ 
									$job_atack_line .= qq(�@�������e���Ԃ��ꂽ�B);
								}
								else{
									$damage = 999999999999999;
									$job_atack_line .= qq(<br$main::xclose>$enemy->{'name'}�͑��̍����~�߂��B</span>);
									$not_view_damage_flag = 1;
									$special_guard_block_flag = 1;
								}
							$job_atack_line .= qq(</span>);
						}
			}


	}

	# ���񕜌n�̓���Z�\
	{

			# �C�s�m�̒���
			if($adv->{'jobname'} eq "�C�s�m" || $adv->{'buffer_monster_skill'} =~ /����/){
				my $rand = 135 - ($adv->{'level'}/100);
					if($rand < 35){ $rand = 35; }			# �ō������m�� ( 1 / x )
					if($use->{'BattleMode'} eq "Monster"){ $rand += 35; }
					if($use->{'TypeDefence'}){ $rand *= 10; }	# �h�䑤�̏ꍇ�A�����m�������炷
					if($adv->{'buffer_monster_flag'}){ $rand = 100; }	# �����X�^�[���d�|����m��
					# ���񕜔���
					if(rand($rand) < 1){
						my($text);
							if($adv->{'level'} >= 20000){ $repair = int($adv->{'maxhp'}); $text = "���ׂ�"; }
							elsif($adv->{'level'} >= 10000){ $repair = int($adv->{'maxhp'}/2); $text = "1/2"; }
							elsif($adv->{'level'} >= 2500){ $repair = int($adv->{'maxhp'}/3); $text = "1/3"; }
							else{ $repair = int($adv->{'maxhp'}/4); $text = "1/4"; }
						$repair_line .= qq(<br><span class="special">����$adv->{'name'}���ґz�����I HP��<strong class="hpcolor">$text����</strong>�����B</span>);
					}
			}

			# �N��A�i���̃_���[�W��
			if($adv->{'jobname'} eq "�N��" || $adv->{'jobname'} eq "�i��"){
					if($use->{'BattleMode'} eq "Human"){ $repair = int rand($adv->{'level'}/2); }
					elsif($use->{'BattleMode'} eq "Monster"){ $repair = int rand($adv->{'level'}); }
					if($repair >= 10000){ $repair = 10000; }
					if($repair >= 1){
						$repair_line .= qq(<br><span class="special">�����_���ȗ͂� HP �� <strong class="hpcolor">$repair</strong> �񕜂����B</span>);
					}
			}

	}

	# [�G]�̓���h�� -------------------
	if(!$special_guard_block_flag){

			# ���@���L���[�̍U���z��
			if($enemy->{'jobname'} eq "���@���L���["){
					if(rand(10) < 1){
						$damage *= -1;
						$guard_line .= qq(<br><span class="red">�������@���L���[�̍U���z���I</span>);
					}
			}

			# �G�̎���Ń_���[�W�ʂ�����
			elsif($enemy->{'jobname'} eq "�����W���["){
				my($percent);
					if($enemy->{'level'} >= 10000){ $percent = 90; }
					elsif($enemy->{'level'} >= 5000){ $percent = 80 }
					elsif($enemy->{'level'} >= 1000){ $percent = 70; }
					elsif($enemy->{'level'} >= 500){ $percent = 60; }
					elsif($enemy->{'level'} >= 100){ $percent = 40; }
					else{ $percent = 20; }
					if(rand(100) < $percent){
						$damage *= 0.5;
						$guard_line .= qq(<br><span class="red">��������͐g���ł߂Ă���B</span>);
					}
			}
	}

	# ���_���[�W�\��
	if(!$not_view_damage_flag){

		$damage = int($damage);
		($damage_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$damage]);

			# �v���X�U�� ( ����Ƀ_���[�W )
			if($damage >= 0){
				if(Mebius::alocal_judge() && $item_damage_point){
					my($item_damage_point_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$item_damage_point]);
					$damage_line .= qq(<br>$enemy->{'name'}�� <b class="damage">$damage_comma ($item_damage_point_comma)</b> �̃_���[�W�B);
				}
				else{
					$damage_line .= qq(<br>$enemy->{'name'}�� <b class="damage">$damage_comma</b> �̃_���[�W�B);
				}
			}
			# �}�C�i�X�U���i����HP�̉񕜁j
			else{
				my $repair_damage_comma = $damage_comma;
				$repair_damage_comma =~ s/^\-//g;
				$damage_line .= qq(<br>$enemy->{'name'}�� <span class="dmg"><b style="color:#00f;">$repair_damage_comma</b></span> �񕜂����Ă��܂����B);
			}

	}

	# �񕜗�
	$repair = int $repair;

# ���`
$com = qq(
$com
$wepon_use_line
$guard_line
$job_atack_line
$critical_line
$special_atack_line
$damage_line
$repair_line
);

# ���^�[��
return($damage,$repair,$com);

}




1;
