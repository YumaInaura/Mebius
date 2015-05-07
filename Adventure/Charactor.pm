 
use strict;
package Mebius::Adventure;
use Mebius::Export;

#-----------------------------------------------------------
# �L�����f�[�^�̕\��
#-----------------------------------------------------------
sub CharaStatus{

# �Ǐ���
my($use,$adv) = @_;
my($init) = &Init();
my($basic_init) = Mebius::basic_init();
my($parts) = Mebius::Parts::HTML();
my($my_account) = Mebius::my_account();
my($line,$view_url,$select_battle_button,$view_pdmg,$block_line);
my($effect_line);

# �}�C�f�[�^���擾
my($advmy) = &my_data();

# CSS�ǉ�
$main::css_text .= qq(
table.charadata{font-size:110%;}
th.charaname{background:#cdf;padding:0.5em 0.7em;text-align:left;font-weight:bold;}
span.charaname{font-size:130%;}
td.status{word-spacing:0.3em;}
td.charadata{padding:0.4em 0.5em;}
td{line-height:1.4;}
.purple{color:purple;}
span.effect{color:#fff;font-weight:bold;background:#5d5;padding:0.3em 0.5em;line-height:1.8;font-size:90%;}
);

	# �t�@�C�������݂��Ȃ��ꍇ
	if(!$adv->{'f'}){
			if($use->{'TypeChampStatus'}){ return; }
			else{ main::error("���̃L�����N�^ ( $adv->{'id'} ) �͑��݂��܂���B"); }
	}

	# �m���̏ꍇ
	if($adv->{'hp'} < $adv->{'maxhp'} * 0.2){
		$main::css_text .= qq(
		table.charadata,table.charadata td,table.charadata th{background:#fee;border-color:#f77;}
		);
	}
	# �m���̏ꍇ
	elsif($adv->{'hp'} < $adv->{'maxhp'} * 0.5){
		$main::css_text .= qq(
		table.charadata,table.charadata td,table.charadata th{background:#efe;border-color:#070;}
		);
	}

	# �A�C�e��
	if($adv->{'item_damage_plus'} >= 1){ $view_pdmg = qq( + $adv->{'item_damage_plus'} ); }

	# �L�����u���b�N
	if($adv->{'block_time'} >= $main::time){
		my($how_block) = Mebius::SplitTime("",$adv->{'block_time'} - time);
		$block_line = qq(<strong class="red">�s�K�؍s�ׁA�F�؂̘A�����s�Ȃǂɂ��A�L�������b�N���ł��B(����$how_block)</strong>);
	}

$line .= qq($block_line);

	# ��������ʂ̕\��
	if($adv->{'id'} eq $advmy->{'id'} || $my_account->{'admin_flag'}){
		my $effect; 
			my($how_long) = shift_jis(Mebius::second_to_howlong({ GetLevel => "minute" } ,$adv->{'effect_levelup_boost_time'} - time));
			if($adv->{'effect_levelup_boost_time'} >= time){
				$effect .= qq(<span class="effect">���x���A�b�v$adv->{'effect_levelup_boost'}�{ (����$how_long)</span>);
			}
			if($effect){ $effect_line = qq(<div class="effect">$effect</div>); }
	}


$line .= qq(<table class="adventure charadata">
<tr>
<th colspan="2" class="charaname">
<span class="charaname">$adv->{'name'}</span>�@
���x���F $adv->{'level'}�@
�E�ƁF $adv->{'jobname'}�@
�N���X�F $adv->{'jobrank'}�@
����F $adv->{'item_name'} ( $adv->{'item_damage'}$view_pdmg )�@
���ʁF $adv->{'sextype'}
</th>
</tr>
);

# �J���}��t����
my($hp_comma,$maxhp_comma,$ex_comma,$next_exp_comma,$gold_comma,$bank_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$adv->{'hp'},$adv->{'maxhp'},$adv->{'exp'},$adv->{'next_exp'},$adv->{'gold'},$adv->{'bank'}]);

$line .= qq(
<tr>
<td class="charadata">���</td>
<td class="charadata">
<div>
<span class="hpcolor">HP $hp_comma / $maxhp_comma</span>�@|�@
<span class="goldcolor">������ $gold_comma\G</span>
<span class="goldcolor"> ( �a�� $bank_comma\G )</span>�@|�@
SP $adv->{'sp'}
</div>
<div>
<span class="expcolor">�o���l $ex_comma / $next_exp_comma</span>�@|�@
��� $adv->{'win'}�� $adv->{'lose'}�s $adv->{'draw'}�� ( ���� $adv->{'winodds'}�� )
</div>
$effect_line
</td>
</tr>
);

$line .= qq(
<tr>
<td class="charadata">�X�e�[�^�X</td>
<td class="status charadata">
�� $adv->{'power'} | 
�m�� $adv->{'brain'} | 
�M�S $adv->{'believe'} | 
������ $adv->{'vital'} | 
��p�� $adv->{'tec'} | 
���� $adv->{'speed'} | 
���� $adv->{'charm'} | 
�J���} $adv->{'karman'} |
�E�C $adv->{'brave'}
</td>
</tr>
);

	# �Ǘ��҂ɂ̂ݕ\������ڍ׍s
	if($my_account->{'master_flag'}){
		$line .= qq(
		<tr>
		<td class="charadata red">�Ǘ��ҕ\\��</td>
		<td class="status charadata">
		�����U�� $adv->{'autobank'}�� / 
		�ʎZ���x���A�b�v�� / $adv->{'all_level'}
		�K�E�Z $adv->{'spatack'} ( �З�$adv->{'spodds'}�{ )
		�s���� $adv->{'today_action_buffer'}
		Trance-from : $adv->{'trance_from_account'} / Trance-to : $adv->{'trance_to_account'}
		</td>
		</tr>
		);
	}


	# ���̃L�����Ɛ키�{�^��
	if($advmy->{'login_flag'} && $adv->{'id'} ne $advmy->{'id'} && !$use->{'TypeNotGetForm'} && $adv->{'formal_player_flag'}){

			if($advmy->{'test_player_flag'}){
				$select_battle_button .= qq(
				<input type="submit" value="���̃L�����Ɛ키" class="battle"$parts->{'disabled'}>
				<span class="alert">���e�X�g�v���C���̓L�����N�^�[�Ƃ͐킦�܂���B</span>
				);
			}
			elsif($main::time > $adv->{'lasttime'}+$init->{'charaon_day'}*24*60*60){
				$select_battle_button .= qq(
				<input type="submit" value="���̃L�����Ɛ키" class="battle"$parts->{'disabled'}>
				<span class="alert">�����΂炭���O�C�����Ă��Ȃ�����Ƃ͐킦�܂���B</span>
				);
				}
			#elsif($advmy->{'maxhp'} < $adv->{'maxhp'}*$init->{'select_battle_gyap'}){
			#	$select_battle_button .= qq(
			#	<input type="submit" value="���̃L�����Ɛ키" class="battle"$parts->{'disabled'}>
			#	<span class="alert">�����͍������肷���鑊��Ƃ͐킦�܂���B</span>
			#	);
			#}
			else{
				$select_battle_button .= qq(
				<form action="$init->{'script'}" method="post" class="nomargin inline"$main::sikibetu>
				<div class="inline">
				<input type="hidden" name="mode" value="battle">
				<input type="hidden" name="id" value="$advmy->{'id'}">
				<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
				<input type="hidden" name="char" value="$advmy->{'char'}">
				<input type="hidden" name="target_id" value="$adv->{'id'}">
				<input type="hidden" name="target_file_type" value="$adv->{'input_file_type'}">
				<input type="submit" value="���̃L�����Ɛ키" class="battle">
				</div>
				</form>
				);

			}
	}



# �R�����g�Ȃ�
my($view_url) = Mebius::auto_link($adv->{'url'});

$line .= qq(<tr><td class="charadata">�f�[�^</td><td class="charadata">);
#$line .= qq($adv->{'comment'});
#$line .= qq($view_url);

	# �A�J�E���g�ւ̃����N
	if($adv->{'formal_player_flag'}){
			#  �� 
			$line .= qq(SNS�A�J�E���g �F <a href="$basic_init->{'auth_url'}$adv->{'id'}">\@$adv->{'id'}</a>\n);
	}
$line .= qq(</td></tr>);

	# �����̃X�e�[�^�X�łȂ����
	if($advmy->{'login_flag'} && !$use->{'TypeNotGetForm'}){

		$line .= qq(<tr><td>�A�N�V����</td><td>);

		# �퓬�{�^��
		$line .= qq($select_battle_button);

		# ����s���{�^��
		require Mebius::Adventure::Special;
		my($special) = &SpecialJudge(undef,$advmy,$adv);
			if($special->{'justy_flag'}){ 
					$line .= qq( $special->{'form'});
			}
			else{
					$line .= qq( $special->{'form'} $special->{'error_flag'});
			}

		$line .= qq(</td></tr>);
	}


$line .= qq(</table>);



return($line)

}

#-----------------------------------------------------------
# �L�����\���y�[�W
#-----------------------------------------------------------
sub CharaView{

# �Ǐ���
my($type,$id) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my($init) = &Init();
my($init_login) = init_login();
my($hit,$ltime,$vtime,$mtime,$editform);
my($status_line,$adv,$not_submit_flag,$print);
our($advmy);

	# �X�e�[�^�X�\���������擾

	# �����L�����t�@�C�� ( �L�q�͍폜���Ȃ� - �ߋ��̃X�e�[�^�X���{���ł���悤�A�����Ǝc�� )
	if($type{'Old-file'}){

			# �Â�URL�����_�C���N�g
			if($main::in{'id'}){
				Mebius::Redirect(undef,"$init->{'base_url'}?mode=chara&chara_id=$main::in{'id'}",301);
			}

		($adv) = &File("",{ FileType => "OldId" , id => $id , "Old-file" => 1 });
		($status_line) = &CharaStatus({ FileType => "OldId" },$adv);
	}

	# ���A�J�E���g�t�@�C��
	else{
		($adv) = &File("",{ FileType => "Account" , id => $id });
		($status_line) = &CharaStatus(undef,$adv);
	}

	# �ݒ�t�H�[�����擾
	if($main::myaccount{'master_flag'}){
		($editform) = &CharaForm(undef,$adv); 
		$editform = qq(<h2>�ݒ�ύX(�Ǘ��Ҍ���)</h2>$editform);
	}

# �^�C�g����`
$main::sub_title = "$adv->{'name'} | $main::title";


# HTML
$print .= <<"EOM";
<h1>$adv->{'name'} \@$adv->{'id'}</h1>
$init_login->{'link_line'}
EOM

# �L���t�B���^
my($fillter_flag) = Mebius::Fillter::Ads({ Encode => "shit_jis" },$adv->{'name'},$adv->{'comment'});

	# �L���\��
	if(!$fillter_flag){
		$print .= qq($init->{'ads1_formated'});
	}

my($tweet_button) = Mebius::Gaget::tweet_button();

# �g�s�l�k��\��
$print .= qq(
<div><h2 class="inline">�X�e�[�^�X</h2>�@ $tweet_button</div>
$status_line
$editform
);

# �t�b�^
Mebius::Template::gzip_and_print_all({ BCL => [{ url => "?mode=ranking" , title => " �����L���O" },$adv->{'name'}] },$print);


exit;

}



#-----------------------------------------------------------
# �p�����[�^�\���A�ݒ�ύX�t�H�[��
#-----------------------------------------------------------
sub CharaForm{

my($type,$adv) = @_;
my($init) = &Init();
my($line);
my($my_account) = Mebius::my_account();

$line .= qq(
<form action="$init->{'script'}" method="post" style="margin:0em;"$main::sikibetu>
<div>
<table class="adventure">);

	if($my_account->{'admin_flag'}){
		$line .= qq(
		<tr>
		<td>�L������</td>
		<td><input type="text" name="name" value="$adv->{'name'}" size="50" maxlength="50"></td>
		</tr>
		);
	}

$line .= qq(
<tr>
<td>�K�E�̗Y������</td>
<td><input type="text" name="advwaza" value="$adv->{'waza'}" size="50" maxlength="50"></td>
</tr>
);

$line .= qq(
<tr>
<td>�R�����g</td>
<td><input type="text" name="advcomment" value="$adv->{'comment'}" size="50" maxlength="50"> <span class="alert">���R�����g�@�\\���r��C���̂��߁A���݁A���f���~���ł��B</span></td>
</tr>
);

$line .= qq(
<tr>
<td>�t�q�k�i���r�E�X�����O���j</td>
<td><input type="text" name="advurl" value="$adv->{'url'}" size="50" maxlength="50"> <span class="alert">�����݁A���f���~���ł��B</span></td>
</tr>
);


	# �Ǘ��Ґݒ�
	if($main::myaccount{'master_flag'} && $main::mode eq "chara" || $main::mode eq "status"){ 
		my $example_block_time = time + (7*24*60*60);
		$line .= qq(
		<tr>
		<td>�S�[���h</td>
		<td><input type="text" name="advgold" value="$adv->{'gold'}"></td>
		</tr>
		<tr>
		<td>�a��</td>
		<td><input type="text" name="advbank" value="$adv->{'bank'}"></td>
		</tr>
		<tr>
		<td>�o���l</td>
		<td><input type="text" name="advex" value="$adv->{'exp'}"></td>
		</tr>
		<td>�u���b�N</td>
		<td><input type="text" name="block_time" value="$adv->{'block_time'}"> ��F $example_block_time</td>
		</tr>
		);
	}



$line .= qq(</table>);


$line .= qq(
<input type="submit" value="���̓��e�Őݒ�ύX����">
<br><br>
<span class="alert">���u�����v�u�����v�ȂǕs�K�؂ȓ��e��o�^���Ȃ��ł��������B
�ᔽ�ɂ́u�o�^�폜�v�u���e�����v�Ȃǂ������Ă��������ꍇ������܂�(<a href="${main::guide_url}">�K�C�h</a>)�B
</span>
<input type="hidden" name="mode" value="edit">
<input type="hidden" name="id" value="$adv->{'id'}">
<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
<input type="hidden" name="char" value="$adv->{'char'}">
</div>
</form>
);

return($line);

}


1;
