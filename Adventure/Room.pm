
use strict;
package Mebius::Adventure;
use Mebius::Export;

#-----------------------------------------------------------
# �l�i
#-----------------------------------------------------------
sub PriceRoom{

# �錾
my($use,$adv) = @_;
my(%data);

$data{'sex_change_price'} = (10000000 + ($adv->{'level'}*2500)) * $adv->{'sex_change_count'};
$data{'name_change_price'} = (10000000 + ($adv->{'level'}*2500)) * $adv->{'name_change_count'};

return($data{'sex_change_price'},$data{'name_change_price'});

#return(\%data);

}


#-----------------------------------------------------------
# ���[�h�U�蕪��
#-----------------------------------------------------------
sub Room{
$main::sub_title = "�s���� | $main::title";
		if($main::in{'type'} eq "changename" || $main::in{'type'} eq "changesex"){ &ChangeStatus(); }
		elsif($main::in{'type'} eq ""){ &ViewRoom(); }
		else{ main::error("�y�[�W�����݂��܂���B"); }
}


#-----------------------------------------------------------
# �s�����y�[�W�\��
#-----------------------------------------------------------
sub ViewRoom{

# �Ǐ���
my($init) = &Init();
my($init_login) = init_login();
my($message,$form,$charge_gold,$charity_line,$i,$message2,$submit1,$submit2,$change_name_line,$change_sex_line);
our($advmy);

# CSS��`
$main::css_text .= qq(
form{margin:1em 0em;}
table{width:100%;}
.now_gold{width:17em;display:inline;width:200px;}
.keep_gold{width:30em;display:inline;width:200px;}
);

# �L�����f�[�^��ǂݍ���
my($adv) = &File("Mydata Allow-empty-id",{ FileType => $advmy->{'FileType'} , id => $advmy->{'id'} } );

# �s�����̐ݒ��ǂݍ���
my($changesex_gold,$changename_gold) = &PriceRoom({},$adv);

# �J���}��t����
my($changesex_gold_comma,$changename_gold_comma,$kgold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$changesex_gold,$changename_gold,$adv->{'gold'}]);

	# �������̕\��
	if($adv->{'gold'}){ 
		$form .= qq(���Ȃ��̏������F <strong class="goldcolor">$kgold_comma G</strong>);
	}


	# ���O�ύX�t�H�[��
	$change_name_line .= qq(<h2>���O�̕ύX</h2>);
	if($advmy->{'login_flag'}){
		$change_name_line .= qq(
		<span class="goldcolor">$changename_gold_comma\G </span>�ł��Ȃ��̖��O��ύX���܂��B
		<form action="$init->{'script'}" method="post"$main::sikibetu>
		<div>
		���݂̖��O�F $adv->{'name'}<br><br>
		�V�������O�F <input type="text" name="name" value="">
		<input type="hidden" name="mode" value="room">
		<input type="hidden" name="type" value="changename">
		<input type="hidden" name="id" value="$adv->{'id'}">
		<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
		<input type="hidden" name="char" value="$adv->{'char'}">
		<input type="submit" value="���O��ύX����">
		</div>
		</form>
		);
	}
	else{
		$change_name_line .= qq($init->{'please_login_text'});
	}

	# ���ʕύX�t�H�[��
	$change_sex_line .= qq(<h2>���ʂ̕ύX</h2>);
	if($advmy->{'login_flag'}){
		$change_sex_line .= qq(
		<span class="goldcolor">$changesex_gold_comma\G</span> �ł��Ȃ��̐��ʂ�o�L��A�ύX���܂��B
		<form action="$init->{'script'}" method="post"$main::sikibetu>
		<div>
		<input type="hidden" name="mode" value="room">
		<input type="hidden" name="type" value="changesex">
		<input type="hidden" name="id" value="$adv->{'id'}">
		<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
		<input type="hidden" name="char" value="$adv->{'char'}">
		<input type="submit" value="���ʂ�ύX����">
		</div>
		</form>
		);
	}
	else{
		$change_sex_line .= qq($init->{'please_login_text'});
	}

my $print = qq(
<h1>�s����</h1>
$init_login->{'link_line'}
$message
$form
$change_name_line
$change_sex_line
);

Mebius::Template::gzip_and_print_all({ BCL => ["�s����"] },$print);

exit;

}

#-----------------------------------------------------------
# �o�^�̕ύX
#-----------------------------------------------------------
sub ChangeStatus{

# �Ǐ���
my($init) = &Init();
my($init_login) = init_login();
my($deposit_gold,%renew);
our($advmy);

# �A�N�Z�X����
main::axscheck("Post-only ACCOUNT");

# �L�����f�[�^��ǂݍ���
my($adv) = &File("Mydata Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} });

# �s�����̐ݒ��ǂݍ���
my($changesex_gold,$changename_gold) = &PriceRoom({},$adv);

	# ���O�̕ύX
	if($main::in{'type'} eq "changename"){
		my($base_directory) = Mebius::BaseInitDirectory();
		require "${base_directory}regist_allcheck.pl";
		my($new_name) = shift_jis(Mebius::Regist::name_check($main::in{'name'}));
		main::error_view();
			if($adv->{'gold'} < $changename_gold){ main::error("����������܂���B $adv->{'gold'}\G / $changename_gold\G"); }
		$renew{'name'} = $new_name;
		$renew{'-'}{'gold'} = $changename_gold;
		$renew{'+'}{'name_change_count'} = 1;
	}

	# ���ʂ̕ύX
	if($main::in{'type'} eq "changesex"){
			if($adv->{'gold'} < $changesex_gold){ main::error("����������܂���B $adv->{'gold'}\G / $changename_gold\G"); }
			if($adv->{'sex'} == 1){ $renew{'sex'} = 0; }
			else{ $renew{'sex'} = 1; }
		$renew{'-'}{'gold'} = $changesex_gold;
		$renew{'+'}{'sex_change_count'} = 1;
	}

# �L�����f�[�^���X�V
my($renewed) = &File("Mydata Renew Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

# �W�����v
$main::jump_url = $init->{'login_url'};
$main::jump_sec = 1;

my $print = qq(
<h1>�s����</h1>
$init_login->{'link_line'}
�o�^��ύX���܂����I<br>
$init->{'continue_button'}
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}




1;
