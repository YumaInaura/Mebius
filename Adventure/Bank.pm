
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# ��s�̊�{�ݒ�
#-----------------------------------------------------------
sub InitBank{

# �Ǐ���
my($use,$adv) = @_;
my(%init_bank);
my($advmy) = my_data();
our($charge,$take_charge,$gamble_minlate,$max_loan) = (undef);

$main::sub_title = "��s | $main::title";

# �萔���̃p�[�Z���e�[�W
$charge = 5;

	# �؋��̌��x�z
	if($max_loan > 5000000){ $max_loan = 5000000; }
	else{ $max_loan = 5000 + ($advmy->{'level'}*2000); }

	# �萔���̊����A����
	if($advmy->{'jobname'} eq "�����W���["){ $charge = 0; }
	elsif($advmy->{'jobname'} eq "�i��"){ $charge = 0; }
	#elsif($advmy->{'jobname'} eq "�N��"){ $charge = 3; }
	elsif($advmy->{'jobname'} eq "�m��"){ $charge = 3; }
	elsif($advmy->{'jobname'} eq "���@�g��"){ $charge = 10; }
	elsif($advmy->{'jobname'} eq "���\\�͎�"){ $charge = 10; }
	elsif($advmy->{'jobname'} eq "�B���p�t"){ $charge = 10; }
$take_charge = $charge*3;

# �q���̍Œ჌�[�g
$gamble_minlate = $advmy->{'level'} * 10;

$init_bank{'head_title'} = "��s";
$init_bank{'head_title_link'} = qq(<a href="?mode=bank">��s</a>);

return(\%init_bank);

}

#-----------------------------------------------------------
# ���[�h�U�蕪��
#-----------------------------------------------------------
sub Bank{

	if($main::in{'type'} eq "deposit"){ &BankDeposit(); }
	elsif($main::in{'type'} eq "autobank"){ &BankDeposit(); }
	elsif($main::in{'type'} eq "charity"){ &BankCharity(); }
	elsif($main::in{'type'} eq "lot"){ &BankLot(); }
	elsif($main::in{'type'} eq ""){ &ViewBank(); }

	else{ main::error("�y�[�W�����݂��܂���B[ADBK]"); }
}


#-----------------------------------------------------------
# ��s�y�[�W�\��
#-----------------------------------------------------------
sub ViewBank{

# �Ǐ���
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($charity,$message,$form,$charge_gold,$charity_line,$i,$message2);
our($advmy,$charge,$max_loan,$take_charge,$gamble_minlate);

# CSS��`
$main::css_text .= qq(
form{margin:1em 0em;}
table{width:100%;}
.now_gold{width:17em;display:inline;width:200px;} 
.keep_gold{width:30em;display:inline;width:200px;}
th{text-align:center;}
th.charity_rank{width:3.5em;}
);

# �J���}��t����
my($advcharity_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$advmy->{'charity'}]);

	# ��������L���O���擾
	if($main::in{'old_data'}){
		($charity) = &CharityFile({ FileType => "Old" , TypeGetIndex => 1 });
	}
	else{
		my $MaxViewIndex = 10;
			if($main::in{'view_all'}){ $MaxViewIndex = "All"; }
		($charity) = &CharityFile({ TypeGetIndex => 1 , TypeGetIndex => 1 , MaxViewIndex => $MaxViewIndex });
	}

# ��������L���O�𐮌`
$charity_line = qq(
<table summary="����z���X�g" style="width:60%;" class="adventure" id="CHARITY">
<tr><th class="charity_rank">������</th><th>�����O</th><th>����z</th></tr>
$charity->{'index_line'}
</table>
);

	# �����\�������N
	if($charity->{'flow_flag'}){
		$charity_line .= qq( <a href="$init->{'script'}?mode=bank&amp;view_all=1#CHARITY">���S�Č���</a>);
	}

	# ���f�[�^�ւ̃����N ( 2011/12/31 (�y) )
	if(!$main::in{'old_data'}){
		$charity_line .= qq( <a href="$init->{'script'}?mode=bank&amp;old_data=1#CHARITY">������������L���O</a>);
	}

# �萔��
$charge_gold = int $advmy->{'gold'} * $charge*0.01;

# ���b�Z�[�W
if($advmy->{'name'}){ $message .= qq($advmy->{'name'} �l�A��������Ⴂ�܂��B<br>); }
#if($advbank >= 1){ $message .= qq(���� <strong class="goldcolor">${advbank}G</strong> ���a���肵�Ă���܂��B); }
#else{ $message .= qq(���݂��a���肵�Ă��邨���͂������܂���B); }
#$message .= qq(�i �������F <strong class="goldcolor">${advgold}G</strong> �j);

	# �t�H�[��
	if($advmy->{'login_flag'}){}
	else{}

# �������͋��z
my $keepgold_value = $advmy->{'gold'};
my $charitygold_value = int($advmy->{'gold'}*0.1);
my $takegold_value = $advmy->{'bank'};
	if($advmy->{'bank'} < 0){ $takegold_value = 0; }

# �J���}��t����
my($bank_commma,$gold_comma,$keepgold_comma,$takegold_comma,$charitygold_value_comma,$gamble_gold_comma) =
		 Mebius::MultiComma({ Language => $init->{'comma_language'} },[$advmy->{'bank'},$advmy->{'gold'},$keepgold_value,$takegold_value,$charitygold_value,$advmy->{'last_gamble_win_gold'}]);

# ��������
my($first_input_take_bank);
	if(Mebius::alocal_judge()){ $first_input_take_bank = $advmy->{'bank'}; }
	else{ $first_input_take_bank = 0; }

# �t�H�[��
$form .= qq(
<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="deposit">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
<div class="now_gold">������ <strong class="goldcolor">$gold_comma\G</strong> �̂���</div>
<div class="keep_gold"><input type="text" name="keep_gold" value="$gold_comma"> G �� <input type="submit" name="deposit_type" value="�a����"></div>
</div>
</form>

<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="deposit">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
<div class="now_gold">�a�� <strong class="goldcolor">$bank_commma\G</strong> �̂���</div>
<div class="keep_gold"><input type="text" name="take_gold" value="$first_input_take_bank"> G �� <input type="submit" name="deposit_type" value="�����o��"></div>
</div>
</form>
);

	# �萔���̊���
	if($charge == 0){
		$form .= qq(<p>��������͂���� <span class="red">$advmy->{'jobname'}�l�I</span> �@�������萔���͂��������܂���B</p>);
	}
	else{
		$form .= qq(<span class="guide">�����a����̍ۂ� $charge�p�[�Z���g�A���Z���̍ۂ� $take_charge �p�[�Z���g �̎萔����\\���󂯂܂��B</span>); 
	}
		$form .= qq(<br><span class="guide">���a���z�ȏ�Ɉ����o���ƁA���Z���ƂȂ�܂��B���q�l�̌��x�z�� $max_loan\G �ł��B</span>); 

# �����U��
$form .= qq(
<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
����A�l���S�[���h�̂��� 
<input type="text" name="autobank_gold" value="$advmy->{'autobank'}"> �� �� 
<input type="submit" name="deposit_type" value="�����U�ւ���">
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="autobank">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
</div>
</form>
);
$form .= qq(<span class="guide">���퓬�ŃS�[���h���l���Ȃ������ꍇ�A���q�l�̌����Ɏ����ςݗ��Ă������܂��B�萔���͂��a������z��20%�ł��B</span>);

if($advmy->{'charity'} >= 1){ $message2 .= qq(���Ȃ��̕���z�F <strong class="goldcolor">$advcharity_comma\G</strong>); }


# �M�����u��
$form .= qq(
<h2 id="GAMBLE">�M�����u��</h2>
���Ȃ��̂������Q�{�ɂ��܂��񂩁H
<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="lot">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
�������F <strong class="goldcolor">$gold_comma\G</strong> �̂��� <input type="text" name="lot_gold" value="$gold_comma"> G ��
<input type="submit" value="�q����">);

	# �O��̓q���̌���
	if(time <= $advmy->{'last_gamble_time'} + 3*60){
				# �J���}
				my($lot_gold_comma,$win_gold_comma) = Mebius::MultiComma({ Language => "Japanese" } , [$advmy->{'last_gamble_lot_gold'},$advmy->{'last_gamble_win_gold'}]);
				# �q��������
				my($how_before) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-�O",time - $advmy->{'last_gamble_time'});

			# �����Ă����ꍇ
			if($advmy->{'last_gamble_result'} eq "Win"){

				$form .= qq!<p><span class="message-yellow">�q���͓�����܂����I ( $lot_gold_comma\G �� $win_gold_comma\G )�@ $how_before</span></p>!;
			}

			# �����Ă����ꍇ
			elsif($advmy->{'last_gamble_result'} eq "Lose"){
				my($how_before) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-�O",time - $advmy->{'last_gamble_time'});
				$form .= qq!<p><span class="message-blue">�q���͊O��܂����B ( $lot_gold_comma\G �� �v�� )�@ $how_before</span></p>!;
			}
	}

$form .= qq(</div><br>
<span class="guide">
��$advmy->{'name'}�l�̍Œ�|������$gamble_minlate\G�ł��B<br>
���T�[�o�[�ɕ��S��������s�ׁi �m���m�F�̂��߂̘A���q���Ȃ� �j�͂��������������B
</span>
</form>
);

# ���
$form .= qq(
<h2 id="CHARITY">���</h2>
�b�܂�Ȃ������X�^�[�̎q�������ɁA�ǂ������̎���B<br><br>
$message2
<form action="$init->{'script'}" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="bank">
<input type="hidden" name="type" value="charity">
<input type="hidden" name="id" value="$advmy->{'id'}">
<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
<input type="hidden" name="char" value="$advmy->{'char'}">
�������F <strong class="goldcolor">$gold_comma\G</strong> �̂��� <input type="text" name="charity_gold" value="$charitygold_value_comma"> G ��
<input type="submit" value="�������">
</div>
</form>
<h3>���܂܂łɕ�������������F�l (���)</h3>
$charity_line
);




my $print  = qq(
<h1>��s</h1>
$init_login->{'link_line'}
<h2>����</h2>
$message
$form
);

Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , BCL => [$init_bank->{'head_title'}] },$print);

exit;

}


#-----------------------------------------------------------
# �a���̗a����A�����o��
#-----------------------------------------------------------
sub BankDeposit{

# �Ǐ���
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($deposit_gold,%renew);
our($take_charge,$max_loan,$charge,$advmy);

# GET���M���֎~
main::axscheck("Post-only ACCOUNT");

	# �����`�F�b�N
	if($main::in{'deposit_type'} eq "�a����"){ $deposit_gold = $main::in{'keep_gold'}; }
	elsif($main::in{'deposit_type'} eq "�����o��"){ $deposit_gold = $main::in{'take_gold'}; }
	elsif($main::in{'deposit_type'} =~ /(�����U��)/){ $deposit_gold = $main::in{'autobank_gold'}; }
	else{ main::error("�����^�C�v��I��ł��������B"); }

# ���`
require "${main::int_dir}regist_allcheck.pl";
($deposit_gold) = main::bigsmall_number($deposit_gold);
($deposit_gold) = Mebius::MultiComma({ TypeDecodeComma => 1 , Language => $init->{'comma_language'} },[$deposit_gold]);
$deposit_gold =~ s/,//g;

	if($deposit_gold =~ /\D/){ main::error("�l�͐����Ŏw�肵�Ă��������B"); }
	if($main::in{'deposit_type'} ne "�����U�ւ���" && ($deposit_gold eq "" || $deposit_gold eq "0")){ main::error("���q�l�A���z�������͂��������B"); }
	if($main::in{'deposit_type'} eq "�����U�ւ���" && ($deposit_gold > 100 || $deposit_gold < 0 || length($deposit_gold) > 3)){ main::error("1%�`100%�̊ԂŐݒ肵�Ă��������B"); }

# �L�����f�[�^��ǂݍ���
my($adv) = &File("Password-check Char-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} });

	# ���a����
	if($main::in{'deposit_type'} eq "�a����"){
			if($deposit_gold > $adv->{'gold'}){ main::error("���q�l�A������������܂���B"); }
			if($deposit_gold < 0){ main::error("���q�l�A�}�C�i�X�̗a���͏o���܂���B"); }

		$renew{'-'}{'gold'} = $deposit_gold;
		$renew{'+'}{'bank'} = int($deposit_gold*(1-($charge*0.01)));

	}

	# �������o��
	elsif($main::in{'deposit_type'} eq "�����o��"){
		my($do_take_charge);
		my $loan = ($deposit_gold - $adv->{'bank'});
			# �Z������ꍇ
			if($loan >= 1){
				my $nowbank = $adv->{'bank'};
					if($nowbank <= 1){ $nowbank = 0; }
				$do_take_charge = int(($deposit_gold-$nowbank)*$take_charge*0.01);
					if($loan > $max_loan){ main::error("���q�l�̗Z���g�� $max_loan\G �܂łł��B"); }
			}
		$renew{'+'}{'gold'} = $deposit_gold;
		$renew{'-'}{'bank'} = ($deposit_gold+$do_take_charge);
	}

	# �����U�ւ̊J�n�A��~
	elsif($main::in{'deposit_type'} =~ /�����U�ւ���/){ $renew{'autobank'} = $deposit_gold; }

# �L�����f�[�^���X�V
&File("Password-check Mydata Renew",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

# ���_�C���N�g
Mebius::Redirect("","$init->{'script'}?mode=bank");

exit;

}


#-----------------------------------------------------------
# �M�����u�������s
#-----------------------------------------------------------
sub BankLot{

# �Ǐ���
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($message1,$plus_gold,$result);
my(%renew);
our($advmy,$gamble_minlate);

# �A�N�Z�X����
main::axscheck("Post-only ACCOUNT");

# �L�����f�[�^��ǂݍ���
my($adv) = &File("Mydata Password-check Char-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'}});

# �e��G���[
require "${main::int_dir}regist_allcheck.pl";
($main::in{'lot_gold'}) = main::bigsmall_number($main::in{'lot_gold'});
($main::in{'lot_gold'}) = Mebius::MultiComma({ TypeDecodeComma => 1 , Language => $init->{'comma_language'} },[$main::in{'lot_gold'}]);
$main::in{'lot_gold'} =~ s/,//g;
$main::in{'lot_gold'} =~ s/^(0+)//g;
	if($main::in{'lot_gold'} =~ /^-/){ main::error("�ӂĂ���Y���I"); }
	if($main::in{'lot_gold'} =~ /\D/){ main::error("���z�͔��p�����œ��͂��Ă��������B"); }
	if($main::in{'lot_gold'} eq "" || $main::in{'lot_gold'} == 0){ main::error("���z����͂��Ă��������B"); }
	if($main::in{'lot_gold'} > $adv->{'gold'}){ main::error("����������܂���B"); }
	if($main::in{'lot_gold'} < $gamble_minlate){ main::error("$adv->{'name'}�l�̍Œ�|������$gamble_minlate\G�ł������܂��B"); }

# �A������
main::redun("ADV_GAMBLE",3,5);

# �q����
my $use_gold = $main::in{'lot_gold'};

# �N�W������
my $percent = 210;

	if($adv->{'jobname'} eq '���\�͎�'){ $percent = 195; $message1 .= qq($adv->{'name'} �͒��\\�͂ŁA�ق�̂킸���ɓ�����m�������߂��I<br>); }
	if(rand($percent) < 100){
		$renew{'+'}{'gold'} = $use_gold;
		$plus_gold = int($use_gold*2);
		$message1 .= qq(�q����������A�|�������Q�{�ɂȂ�܂����I);
		$result = "+$use_gold";
		$renew{'last_gamble_win_gold'} = $plus_gold;
		$renew{'last_gamble_result'} = "Win";

			# �틵���L�^
			if(!$adv->{'test_player_flag'}){
				my $NewComment1 = qq($adv->{'chara_link'} ��);
				my $NewComment2 = qq(<a href="$init->{'script'}?mode=bank#GAMBLE">�M�����u��</a>�� $main::in{'lot_gold'}G �� <span class="goldcolor">$plus_gold\G</span> �ɑ��₵�܂����B</span>);
				&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
			}

	}
	else{
		$renew{'+'}{'gold'} -= $use_gold;
		$message1 .= qq(�q���͊O��܂����B);
		$result = "-$main::in{'lot_gold'}";
		$renew{'last_gamble_result'} = "Lose";
	}

# ���ʂ̍X�V���e
$renew{'last_gamble_lot_gold'} = $use_gold;
$renew{'last_gamble_time'} = time;

# �L�����f�[�^���X�V
&File("Mydata Renew Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

# ���_�C���N�g
Mebius::Redirect(undef,"$init->{'base_url'}?mode=bank#GAMBLE");

# �W�����v
$main::jump_url = "$init->{'script'}?mode=bank";
$main::jump_sec = 5;


my $print = qq(
<h1>��s</h1>
$init_login->{'link_line'}
<div class="results">
$message1
(<a href="$main::jump_url">����s�ɖ߂�</a>)
</div>
$init->{'continue_button'}
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# ���
#-----------------------------------------------------------
sub BankCharity{

# �Ǐ���
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($flag,$hit,@charity_list,$i,$message,$charity_handler,@line,%renew);
our($advmy);

# �A�N�Z�X����
main::axscheck("Post-only ACCOUNT");

# �L�����f�[�^��ǂݍ���
my($adv) = &File("Mydata Password-check Char-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , input_char => $main::in{'char'} });

# �e��G���[
require "${main::int_dir}regist_allcheck.pl";
($main::in{'charity_gold'}) = main::bigsmall_number($main::in{'charity_gold'});
($main::in{'charity_gold'}) = Mebius::MultiComma({ TypeDecodeComma => 1 , Language => $init->{'comma_language'} },[$main::in{'charity_gold'}]);
$main::in{'charity_gold'} =~ s/,//g;
	if($main::in{'charity_gold'} =~ /^-/){ main::error("���̕�����͒N�ɂ��n���܂���I"); }
	if($main::in{'charity_gold'} =~ /\D/){ main::error("���z�͔��p�����œ��͂��Ă��������B"); }
	if($main::in{'charity_gold'} eq "" || $main::in{'charity_gold'} == 0){ main::error("���z����͂��Ă��������B"); }
$main::in{'charity_gold'} = int($main::in{'charity_gold'});

# ����z
if($main::in{'charity_gold'} > $adv->{'gold'}){ main::error("���C�����͂��肪�����̂ł����A����������܂���I"); }
$renew{'-'}{'gold'} = $main::in{'charity_gold'};
$renew{'+'}{'charity'} = $main::in{'charity_gold'};

# �����̃L�����f�[�^���X�V
my($renewed) = &File("Mydata Renew Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

# ��������L���O���X�V
&CharityFile({ TypeRenew => 1 , TypeNewLine => 1 },$renewed);

	# �s���L�^
	if(!$adv->{'test_player_flag'}){
		my $NewComment1 = qq($adv->{'chara_link'} ��);
		my $NewComment2 = qq(<a href="$init->{'script'}?mode=bank#CHARITY">���</a> �� <span class="goldcolor">$main::in{'charity_gold'}G</span> �̋��͂����܂����B);
		&SituationFile({ TypeRenew => 1 , TypeNewLine => 1 , NewComment1 => $NewComment1 , NewComment2 => $NewComment2 });
	}

# �W�����v
$main::jump_url = "$init->{'script'}?mode=bank";
$main::jump_sec = 2;

	# ���b�Z�[�W�ǉ�
	if($main::in{'charity_gold'} > 100000){ $message = qq(<br>����ŎE����Ă����������X�^�[����������邱�Ƃł��傤�B); }


my $print = qq(
<h1>��s</h1>
$init_login->{'link_line'}
<div class="results">
���肪�Ƃ��������܂��I<br>
����Ƃ��Ċm���� $main::in{'charity_gold'}G �����a���肵�܂����B(<a href="$init->{'script'}?mode=bank">����s�ɖ߂�</a>)
$message
</div>
$init->{'continue_button'}
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ����t�@�C��
#-----------------------------------------------------------
sub CharityFile{

# �錾
my($init) = &Init();
my($init_login) = init_login();
my($init_bank) = &InitBank();
my($use,$adv) = @_;
my($i,@renew_line,%data,$file_handle1,$renew,$select_renew,$index_line,%renew,$hit,$hit);

# �f�B���N�g����`
$data{'directory'} = "$init->{'adv_dir'}_log_adv/";

	# �t�@�C����`
	if($use->{'FileType'} eq "Old"){
		$data{'file'} = "$data{'directory'}charity_adv.cgi";
	}
	else{
		$data{'file'} = "$data{'directory'}charity_adv.log";
	}

# �ő�s���`
my $max_line = 100;

	# �f�B���N�g���쐬
	if($use->{'TypeRenew'}){
		Mebius::Mkdir(undef,$data{'directory'});
	}

	# �t�@�C�����J��
	if($use->{'FileCheckError'}){
		$data{'f'} = open($file_handle1,"+<$data{'file'}") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		$data{'f'} = open($file_handle1,"+<$data{'file'}");

			# �t�@�C�������݂��Ȃ��ꍇ�͐V�K�쐬
			if(!$data{'f'}){
					if($use->{'TypeRenew'}){
						Mebius::Fileout("Allow-empty",$data{'file'});
						$data{'f'} = open($file_handle1,"+<$data{'file'}");
					}
					else{
						return(\%data);
					}
			}

	}

	# �t�@�C�����b�N
	if($use->{'TypeRenew'} || $use->{'Flock'}){ flock($file_handle1,2); }

# �g�b�v�f�[�^�𕪉�
chomp($data{'top1'} = <$file_handle1>);
($data{'key'}) = split(/<>/,$data{'top1'});

	# �X�V�p�ɓ��e���L��
	#if($use->{'TypeRenew'}){ %renew = %data; }

	# �t�@�C����W�J
	while(<$file_handle1>){

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($id,$name,$gold) = split(/<>/);

		$hit++;

			# �ő�\���s��
			if($use->{'MaxViewIndex'} && $use->{'MaxViewIndex'} ne "All" && $hit > $use->{'MaxViewIndex'}){
				$data{'flow_flag'} = 1;
				next;
			}

			# �C���f�b�N�X���擾
			if($use->{'TypeGetIndex'}){
				$data{'hit_index'}++;
				my($gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$gold]);
				$data{'index_line'} .= qq(<tr><td>$data{'hit_index'}��</td><td>);
					if($use->{'FileType'} eq "Old"){
							$data{'index_line'} .= qq(<a href="$init->{'script'}?mode=chara&amp;chara_id=$id">$name</a>);
					}
					else{
						$data{'index_line'} .= qq(<a href="$init->{'script'}?mode=status&amp;id=$id">$name</a>\n);
					}
				$data{'index_line'} .= qq(</td><td style="text-align:right;">$gold_comma\G</td></tr>\n);
			}

			# �V�K���
			if($id eq $adv->{'id'}){
				next;
			}

			# �X�V�p
			if($use->{'TypeRenew'}){

					# �ő�s���ɒB�����ꍇ
					if($i > $max_line){ next; }

				# �s��ǉ�
				push(@renew_line,"$id<>$name<>$gold<>\n");

			}

	}

	# �V�����s��ǉ�
	if($use->{'TypeNewLine'}){

		# �s��ǉ�
		unshift(@renew_line,"$adv->{'id'}<>$adv->{'name'}<>$adv->{'charity'}<>\n");

		# ��������L���O����בւ�
		@renew_line = sort { (split(/<>/,$b))[2] <=> (split(/<>/,$a))[2] } @renew_line;

	}

	# �t�@�C���X�V
	if($use->{'TypeRenew'}){

		# �C�ӂ̍X�V
		($renew) = Mebius::Hash::control(\%data,$select_renew);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$renew->{'key'}<>\n");

		# �t�@�C���X�V
		seek($file_handle1,0,0);
		truncate($file_handle1,tell($file_handle1));
		print $file_handle1 @renew_line;

	}


close($file_handle1);

	# �p�[�~�b�V�����ύX
	if($use->{'TypeRenew'}){
		Mebius::Chmod(undef,$data{'file'});
	}

	# ���^�[��
	if($use->{'TypeRenew'}){
		return($renew);
	}
	else{
		return(\%data);
	}

}


1;
