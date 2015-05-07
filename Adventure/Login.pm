
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# ���O�C��
#-----------------------------------------------------------
sub Login{

# �Ǐ���
my($init) = &Init();
my($init_login) = init_login();
my($hit,$ltime,$vtime,$mtime,$special_line);
my($monster_line,$yado_line);
my($head_javascript,$view_jsredirect,$battle_line,$class_disabled,$status_line,$monster_disabled,$battle_disabled,$special_disabled,$yado_disabled);
my($monster_select_disabled,$print);
my($parts) = Mebius::Parts::HTML();

# �f�[�^���R�s�[ 
my($advmy) = &my_data();
my $adv = $advmy;


	# �X�e�[�^�X�\���������擾
	if($adv->{'f'}){
		require Mebius::Adventure::Charactor;
		($status_line) = &CharaStatus({ TypeMyStatus => 1 },$adv);
		$status_line = qq(<h2><a href="$init->{'adv_url'}?mode=status&amp;id=$adv->{'id'}">���Ȃ��̃X�e�[�^�X</a></h2>\n$status_line);
	}
	# ���O�C�����Ă��Ȃ��ꍇ
	else{
		$yado_disabled = $parts->{'disabled'};
		$special_disabled = $parts->{'disabled'};
		$battle_disabled = $parts->{'disabled'};
		$monster_disabled = $parts->{'disabled'};
		$monster_select_disabled = $parts->{'disabled'};
		$adv->{'name'} = "$init->{'title'}";

	}

	# �҂����Ԓ��� �{�^���� disabled ��
	if($adv->{'wait_disabled'}){
		$monster_disabled = $parts->{'disabled'};
		$battle_disabled = $parts->{'disabled'};
		$special_disabled = $parts->{'disabled'};
	}

	# �e�X�g�v���C���[�̏ꍇ�͓���s�� / �`�����v�킪�ł��Ȃ��悤��
	if($adv->{'test_player_flag'}){
		$battle_disabled = $parts->{'disabled'};
		$special_disabled = $parts->{'disabled'};
	}

# �S�L�����̍s���L�^���擾
my($situation) = &SituationFile({ TypeGetIndex => 1 , MaxViewLine => 5 });

# �S�L�����̐틵���擾
#my($alllog_line) = &viewlog("ALL","3");
#<h2><a href="$init->{'script'}?mode=log#RECORD">�`�����v����</a></h2>
#$alllog_line

# �ݒ�ύX�t�H�[�����擾
my($form_line);
	if($adv->{'f'}){
		require Mebius::Adventure::Charactor;
		($form_line) = &CharaForm(undef,$adv);
		$form_line = qq(<h2>�ݒ�ύX</h2>$form_line);
	}

# �����X�^�[�Ɛ키
$monster_line .= qq(
<form action="$init->{'script'}" method="post" class="zero aselect"$main::sikibetu>
<div class="inline">
<input type="hidden" name="mode" value="monster">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="char" value="$adv->{'char'}">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
<input type="submit" value="�����X�^�[�Ɛ키" id="monster_battle" class="monster $class_disabled"$monster_disabled>
);


# �G�̃Z���N�g
$monster_line .= qq(<select name="m_type"$monster_select_disabled>);
if($main::alocal_mode){ $monster_line .= qq(<option value="99">�e�X�g���x��</option>\n); }

	# �W�J
	for(0...12){

		# ���x������
		if(Mebius::alocal_judge()){ $monster_line .= qq(<option value="$_" style="background:#fcc;">���x��$_</option>\n); }
		if($_ >= 1 && $adv->{'top_monster_level'} < $_){ next; }

		if($adv->{'last_select_monster_rank'} == $_){ $monster_line .= qq(<option value="$_"$parts->{'selected'}>���x��$_</option>\n); }
		else{ $monster_line .= qq(<option value="$_">���x��$_</option>\n); }

	}

$monster_line .= qq(</select></div></form>);

# �`�����v�t�@�C�����擾
my($champ) = &ChampFile(undef,undef,$adv);

# �`�����v�ɒ���
my($battle_submit) = qq(<input type="submit" value="�`�����v ( $champ->{'name'} ) �ɒ���" class="battle $class_disabled" id="champ_battle"$battle_disabled>);
	if($adv->{'id'} eq $champ->{'id'} && !Mebius::alocal_judge()){
		$battle_submit = qq(<input type="submit" value="�`�����v ( $champ->{'name'} ) �͂��Ȃ��ł�" class="disabled2"$parts->{'disabled'}>\n);
	}

$battle_line = qq(
<form action="$init->{'script'}" method="post" class="zero aselect"$main::sikibetu>
<div class="inline">
<input type="hidden" name="mode" value="battle">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="char" value="$adv->{'char'}">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
$battle_submit
</div>
</form>
);


# �h
#require Mebius::Adventure::Yado;
require Mebius::Adventure::Yado;

my($yado_gold) = yado_gold($adv,$champ->{'mychamp_flag'});
my($adv_gold_comma,$yado_gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$adv->{'gold'},$yado_gold]);
my($yado_submit) = qq(<input type="submit" value="�h�ɔ��܂� ( $yado_gold_comma\G / $adv_gold_comma\G )" class="yado"$yado_disabled>);
	if($adv->{'hp'} >= $adv->{'maxhp'} && $adv->{'sp'} >= 15 && !Mebius::alocal_judge()){
		$yado_submit = qq(<input type="submit" value="�h�ɔ��܂� ( HP�����^���ł� )" class="disabled2"$parts->{'disabled'}>);
	}
	if($adv->{'gold'} < $yado_gold){
		$yado_submit = qq(<input type="submit" value="�h�ɔ��܂� ( $yado_gold�f / $adv_gold_comma�f )" class="disabled2"$parts->{'disabled'}>);
	}

$yado_line = qq(
<form action="$init->{'script'}" method="post" class="zero aselect"$main::sikibetu>
<div class="inline">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="mode" value="yado">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
<input type="hidden" name="char" value="$adv->{'char'}">
$yado_submit
</div>
</form>
);

# ����s��
($special_line) = &get_special("",$adv->{'jobname'},$adv,$special_disabled);

# �L������I��Ő키
#($select_fight_line) = &get_select_fight("");

# �^�C�g����`
$main::head_link3 = qq( &gt; �}�C�L���� );

# CSS��`
$main::css_text .= qq(
div.aselect{line-height:2.5;}
form.aselect{display:inline;margin:1em 2.0em 0em 0em;}
.inline{display:inline;}
input.yado{background:#9f9;border-color:#9f9;}
input.disabled2{background:#ddd !important;border-color:#ddd !important;}
);


# HTML

	# �匩�o��
	if($adv->{'test_player_flag'} || !$adv->{'id'}){
		$print .= qq(<h1>$adv->{'name'}</h1>);
	}
	else{
		$print .= qq(<h1>$adv->{'name'} <span class="green">\@$adv->{'id'}</span></h1>);
	}
$print .= qq($init_login->{'link_line'});
#$print .= qq($view_jsredirect);
$print .= qq($init->{'ads1_formated'});

	# �����c�[������
	if($adv->{'over_action_flag'}){
		$print .= qq(<br><br>);
	}

# �g�s�l�k��\��
$print .= qq(
<div class="aselect">
$monster_line
$battle_line
$yado_line
$special_line
</div>
$status_line
<h2><a href="$init->{'script'}?mode=log#FIGHT">�S�L�����̐틵</a></h2>
$situation->{'index_line'}
$form_line
);

$print .= qq(</div>);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ����s��
#-----------------------------------------------------------
sub get_special{

# �Ǐ���
my($type,$jobname,$adv,$class_disabled) = @_;
my($init) = &Init();
my($line,$getid_flag,$submit,$type2,$job_select,$selects);
my($TypeViewHP,$TypeViewGold,$TypeJudgeLevel,$TargetJobName);
our($advmy);

	# �E��
	if($jobname eq "�B���p�t"){ $submit = qq(�������������); $getid_flag = 1; }
	elsif($jobname eq "�x��q"){ $submit = qq(�x��); $getid_flag = 1; }
	elsif($jobname eq "�i��"){ $submit = qq(�J���}�����߂�); $getid_flag = 1; }
	elsif($jobname eq "�N��"){ $submit = qq(�v������); $getid_flag = 1;  $TypeViewHP = 1; $TypeViewGold = 1; $TargetJobName = "����"; }
	elsif($jobname eq "��"){ $submit = qq(�a��); $getid_flag = 1; $TypeViewHP = 1; $TypeJudgeLevel = 1; }
	elsif($jobname eq "����"){ $submit = qq(���݂𓭂�); $getid_flag = 1; $TypeViewGold = 1; $TypeJudgeLevel = 1; }
	elsif($jobname eq "�m��"){ $submit = qq(�F��); $getid_flag = 1; }
	else{ return; }

# ���M�{�^��
my($submit) = qq(<input type="submit" value="$submit" class="special" id="special_action"$class_disabled>);

	# �S�L�����̂h�c���擾
	if($getid_flag){
		require Mebius::Adventure::Ranking;
		(undef,$selects) = &RankingFile({ TypeGetSelectOption => 1 , TargetJobName => $TargetJobName , TypeViewGold => $TypeViewGold , TypeViewHP => $TypeViewHP , TypeJudgeLevel => $TypeJudgeLevel  },undef,$adv);
		#$selects = $ranking->{'select_option_line'};
	}
	else{
		($selects) = qq(<input type="hidden" name="target_id" value="id_none">);
	}

# �t�H�[��
$line = qq(
<br>
<form action="$init->{'script'}" method="post" class="zero aselect $class_disabled"$main::sikibetu>
<div class="inline">
<input type="hidden" name="mode" value="special">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="char" value="$adv->{'char'}">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
<input type="hidden" name="target_file_type" value="account">
$submit
<select name="target_id">
<option value="">�Ȃ�</option>
$selects
</select>
</div>
</form>
);


# ���^�[��
return($line);

}


1;
