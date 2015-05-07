
use strict;
use Mebius::Text;
package Mebius::Adventure;

#-----------------------------------------------------------
# �����X�^�[�g
#-----------------------------------------------------------
sub start_adv{

# ���̃p�b�P�[�W�̑S�ϐ������Z�b�g
reset 'a-z';

# �ϐ��̃��Z�b�g
our($advmy) = (undef);

# �ݒ��荞��
my($init) = &Init();

	# �����e���̏ꍇ
	if($init->{'mente_mode'} && !$main::myaccount{'master_flag'}) { main::error("���݃����e�i���X���ł��B���΂炭���҂����������B",503); }

# CSS
push(@main::css_files,"adventure");

# ���W���[���ǂݍ���
require Mebius::Adventure::Item;
require Mebius::Adventure::Data;
require Mebius::Adventure::Situation;
require Mebius::Adventure::NewCharactor;

# �^�C�g����`
$main::sub_title = $init->{'title'};
$main::head_link2 = qq( &gt; <a href="$init->{'script'}">$init->{'title'}</a>);

# ���f�[�^��ǂݍ���
($advmy) = &my_data();

	# �����m�F��ʂ��o���ꍇ
	if($advmy->{'strange_flag'}){

		require Mebius::Adventure::BreakChar;
		&BreakCharView(undef,$advmy->{'break_char'},$advmy->{'break_missed'});
	}

# �G���[���̒ǉ��\����
$main::fook_error = qq($init->{'continue_button'});

#<a href="$init->{'script'}?mode=monster_list">�����X�^�[</a> / 

	# ���[�h�U�蕪��
	if($main::mode eq 'log_in') { require Mebius::Adventure::Login; &Login(); }
	elsif($main::mode eq 'chara_make') { require Mebius::Adventure::NewForm; &NewForm(); }
	elsif($main::mode eq 'make_end') { require Mebius::Adventure::NewForm; &NewCharaMake(); }
	elsif($main::mode eq 'regist') { require Mebius::Adventure::Data; &do_regist(); }
	elsif($main::mode eq 'battle') { require Mebius::Adventure::Battle; &Battle(); }
	elsif($main::mode eq 'jobchange') { require Mebius::Adventure::Job; &JobChange(); }
	elsif($main::mode eq 'joblist') { require Mebius::Adventure::Job; &ViewJob(); }
	elsif($main::mode eq 'bank') { require Mebius::Adventure::Bank; &Bank(); }
	elsif($main::mode eq 'room') { require Mebius::Adventure::Room; &Room(); }
	elsif($main::mode eq 'monster') { require Mebius::Adventure::Battle; &Battle(); }
	elsif($main::mode eq 'ranking') { require Mebius::Adventure::Ranking; &ViewRanking(); }
	elsif($main::mode eq 'yado') { require Mebius::Adventure::Yado; &Yado(); }
	elsif($main::mode eq 'trance') { require Mebius::Adventure::Trance; &Trance(); }
	elsif($main::mode eq 'item_shop') { require Mebius::Adventure::Item; &ViewItem(); }
	elsif($main::mode eq 'special') { require Mebius::Adventure::Special; &SpecialAction(); }
	elsif($main::mode eq 'item_buy') { require Mebius::Adventure::Item; &BuyWepon(); }
	elsif($main::mode eq 'edit') { require Mebius::Adventure::Edit; &EditStatus(); }
	elsif($main::mode eq 'log') { require Mebius::Adventure::Situation; &ViewSituation(); }
	elsif($main::mode eq 'chara') { require Mebius::Adventure::Charactor; &CharaView("Old-file",$main::in{'chara_id'}); }
	elsif($main::mode eq 'status') { require Mebius::Adventure::Charactor; &CharaView(undef,$main::in{'id'}); }
	elsif($main::mode eq 'record') { require Mebius::Adventure::Record; &ViewRecord(); }
	elsif($main::mode eq "") { require Mebius::Adventure::TopPage; &Top(); }
	else{ main::error("���̃y�[�W�͑��݂��܂���B"); }

}

#-----------------------------------------------------------
# �����̃t�@�C�����J��
#-----------------------------------------------------------
sub my_data{

# �錾
my($use) = @_;
my($advmy);

# Near State �i�Ăяo���j
my $StateName1 = "my_data";
my $StateKey1 = "Normal";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

# �f�o�C�X���擾
my($real_device) = Mebius::my_real_device();

	# �A�J�E���g�f�[�^���g��
	if($main::myaccount{'file'}){
		($advmy) = &File("Base-mydata Allow-empty-id",{ FileType => "Account" , id => $main::myaccount{'file'} , my_id => $main::myaccount{'file'} });
	}

	# Cookie�Ńe�X�g�v���C
	if(!$advmy->{'login_flag'} && $main::cnumber){
		my($use_id) = Mebius::my_hashed_cookie_char();
		($advmy) = &File("Base-mydata Allow-empty-id",{ FileType => "Cookie" , id => $use_id , my_id => $use_id });

			# �f�[�^���Ȃ��ꍇ�͐V�K�쐬
			if(!$advmy->{'f'} && !$real_device->{'bot_flag'}){
					($advmy) = &NewCharacterMake(undef,{ FileType => "Cookie" , id => $use_id });
			}

	}

	# Near State �i�ۑ��j
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,$advmy); }

return($advmy);

}

#-----------------------------------------------------------
# �`�����s�I���t�@�C��
#-----------------------------------------------------------
sub ChampFile{

# �錾
my($init) = &Init();
my($use,$select_renew,$adv) = @_;
my($i,@renew_line,%data,$file_handle1,%renew,$renew);

	# �t�@�C����`
	if(Mebius::alocal_judge()){
		$data{'file1'} = "$init->{'adv_dir'}_log_adv/winner_alocal.log";
	}
	else{
		$data{'file1'} = "$init->{'adv_dir'}_log_adv/winner.log";
	}

	# �t�@�C�����J��
	if($use->{'FileCheckError'}){
		$data{'f'} = open($file_handle1,"+<$data{'file1'}") || main::error("�t�@�C�������݂��܂���B");
	}
	else{

		$data{'f'} = open($file_handle1,"+<$data{'file1'}");

			# �t�@�C�������݂��Ȃ��ꍇ
			if(!$data{'f'}){
					# �V�K�쐬
					if($use->{'TypeRenew'}){
						Mebius::Mkdir(undef,$data{'directory1'});
						Mebius::Fileout("Allow-empty",$data{'file1'});
						$data{'f'} = open($file_handle1,"+<$data{'file1'}");
					}
					else{
						return(\%data);
					}
			}

	}

	# �t�@�C�����b�N
	if($use->{'TypeRenew'} || $use->{'TypeRenew'}){ flock($file_handle1,2); }

	# �g�b�v�f�[�^�𕪉�
	for(1..1){
		chomp($data{"top$_"} = <$file_handle1>);
	}

# �g�b�v�f�[�^�𕪉�
($data{'id'},$data{'name'},$data{'win_count'},$data{'hp'}) = split(/<>/,$data{'top1'});

	# �X�V�p�ɓ��e���L��
	if($use->{'TypeRenew'}){ %renew = %data; }

	# �t�@�C���X�V
	if($use->{'TypeRenew'}){

			# �C�ӂ̍X�V�ƃ��t�@�����X��
			($renew) = Mebius::Hash::control(\%renew,$select_renew);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$renew->{'id'}<>$renew->{'name'}<>$renew->{'win_count'}<>$renew->{'hp'}<>\n");

		# �t�@�C���X�V
		seek($file_handle1,0,0);
		truncate($file_handle1,tell($file_handle1));
		print $file_handle1 @renew_line;

	}

close($file_handle1);

	# �p�[�~�b�V�����ύX
	if($use->{'TypeRenew'}){
		Mebius::Chmod(undef,$data{'file1'});
	}

	# �n�b�V������
	if($data{'id'} && $adv->{'id'} eq $data{'id'}){
		$data{'mychamp_flag'} = 1;
	}

	# ���^�[��
	if($use->{'TypeRenew'}){
		return($renew);
	}
	else{
		return(\%data);
	}

}



#-----------------------------------------------------------
# �ݒ�̎�荞��
#-----------------------------------------------------------
sub Init{

# �錾
my($use) = @_;
my(%init);

# Near State ( �Ăяo�� )
my $StateName1 = "Init";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# �T�[�o�[URL���擾
my($server_url) = Mebius::server_url();

	# ���URL���擾
	if(Mebius::alocal_judge()){ $init{'base_url'} = "${server_url}/cgi-bin/ff.cgi"; }
	else{ $init{'base_url'} = "${server_url}/gap/ff/ff.cgi"; }

# �f�o�C�X�����擾
my($use_device) = Mebius::my_use_device();

# ���C���L�� �c Amazon�̃K�W�F�b�g��\��
$init{'ads1'} = "";

$init{'ads1_empty'} = qq(<div style="border:solid 1px #000;width:728px;height:90px;"></div>);

# ���C���X�N���v�g��
$init{'script'} = "./ff.cgi";

# �����e���[�h
$init{'mente_mode'} = 0;

#<a href="http://aurasoul.mb2.jp/_qst/2586.html">����^�c</a> /

# �^�C�g��
$main::title = $init{'title'} = '���r�����E�A�h�x���`���[' ;

# ���x���A�b�v�܂ł̌o���l�̐ݒ�
# ���x���~�l($lv_up)�����̃��x���܂ł̌o���l
$init{'lv_up'} = 1000;

# ����s���A�I��퓬�Ȃǂ�L���ɂ��郍�O�C������
$init{'charaon_day'} = 7;

# �I��퓬���o����ő�HP�� ( �������ő�HP�� �`�{�Ⴂ����܂Ő킦�� )
$init{'select_battle_gyap'} = 1.5;
$init{'special_battle_gyap'} = 2;

# �L�����N�^�[���\���ɂ���܂ł̊���(��)
$init{'reset_limit'} = 7;

# �A�C�e���������p���̂ɂ����邨�� ( ���x�� x G )
$init{'itemguard_gold'} = 1000;

# �A���Ń����X�^�[�Ɠ������
$init{'sentou_limit'} = 30;

# ��bHP
$init{'kiso_hp'} = 20;

# ��b�o���l(�����Őݒ肵�����~����̃��x��)
$init{'kiso_exp'} = 18;

# �Q�[�����x
$init{'game_speed'} = 2;

# �A���s���֎~
$init{'redun'} = 30*$init{'game_speed'};

# ��b�\�͒l(�ύX�s��)
$init{'status'} = ["power","brain","believe","vital","tec","speed","charm"];
$init{'status_name'} = { power => "��" , brain => "�m��" , believe => "�M�S" , vital => "������" , tec => "��p��" , speed => "����" , charm => "����" };
#$init{'status_name_array'} = ['��','�m��','�M�S','������','��p��','����','����'];

$init{'kiso_status'} = 8;
$init{'kiso_sp'} = 15;

my($init_directory) = Mebius::BaseInitDirectory();
$init{'adv_dir'} = "${init_directory}_adventure/";

	# �A���[�J���ݒ� 
	if(Mebius::alocal_judge()){
		$init{'redun'} = 4;
		$init{'lv_up'} = 20;
		$init{'kiso_status'} = 20;
		$init{'ads1'} = $init{'ads1_empty'};
		$init{'ads_link_unit1'} = $init{'ads1_empty'};
	}
	elsif($main::myadmin_flag >= 5){
		$init{'redun'}  = 5;
		$init{'ads1'} = $init{'ads1_empty'};
		$init{'ads_link_unit1'} = $init{'ads1_empty'};
	}

# �L�����` => ���T�u���[�`���̕ʂ̈ʒu�ɒu������
$init{'ads1_formated'} = qq(<div class="adventure_ads1"><hr>$init{'ads1'}<hr></div>);
#$init{'ads1_formated'} = qq(<div class="adventure_ads1">$init{'ads_link_unit1'}</div>);

# ���_�C���N�g�p�̃��O�C����t�q�k
$init{'login_url'} = "$init{'script'}?mode=log_in";

$init{'continue_button'} = qq(<div style="margin:1em 0em;background:#ff9;border:solid 1px #f00;font-size:120%;" class="padding"><a href="$init{'login_url'}">���Q�[���𑱂���i�}�C�L�����N�^�[��ʂցj</a></div>);

# ���`�s�����ƂɁA�m�F��ʂ��o��
$init{'break_interval'} = 60*5;

	# ���[�J���ݒ�
	if(Mebius::alocal_judge() && 1 == 0){ 
		$init{'break_interval'} = 1;
	}

	# ���O�C�����ĂȂ����A���O�C���𑣂������N
	my($request_url) = Mebius::request_url({ TypeEncode => 1 });
	$init{'please_login_text'} = qq(�Q�[��������ɂ�<a href="${main::auth_url}?backurl=$request_url">���O�C�� (�܂��͐V�K�o�^)</a>���Ă��������B);

# �J���}�̋�؂���@
$init{'comma_language'} = "Japanese";

	# Near State �i�ۑ��j
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,\%init); }

return(\%init);


}

#-----------------------------------------------------------
# �ݒ�̎�荞�� (���O�C�����肠��)
#-----------------------------------------------------------
sub init_login{

# �錾
my($init) = &Init();
my(%init_login);

# Near State �i�Ăяo���j
my $StateName1 = "lnit_login";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# ���O�C���f�[�^���擾
my($advmy) = &my_data();

	# �Ǘ��җp�̕\��
	if($init->{'mente_mode'}){
		$init_login{'link_line'} .= qq(<div class="message-red">);
		$init_login{'link_line'} .= qq(�������܃����e�i���X���ł��B�������܂����I���܂ł��҂����������B);
		$init_login{'link_line'} .= qq(</div>);
	}

	# �����e���̕\��

# ���ʃ����N
$init_login{'link_line'} .= qq(<div class="link_line">);

# �i�r
my @navigation = ("=>�Q�[���s�n�o","log_in=>�}�C�L����","RequestURL=>�X�V","ranking=>�����L���O","log=>�틵","item_shop=>�A�C�e��","joblist=>�E��","bank=>��s","room=>�s����","chara_make=>�V�K�o�^");

#,"trance=>���f�[�^���p��"

	# �W�J
	foreach(@navigation){
		my($value,$text) = split(/=>/,$_);
		my($mode_href);
	
			# �X�V�{�^��
			if($value eq "RequestURL"){
					if(!$advmy->{'login_flag'}){ next; }
					if($ENV{'REQUEST_METHOD'} eq "GET"){
						my($request_url) = Mebius::request_url({ TypeEscape => 1});
						$init_login{'link_line'} .= qq(<a href="$request_url" class="green">$text</a> / );
					}
					else{
						$init_login{'link_line'} .= qq($text / );
					}
				next;
			}

			# ���[�J���p
			if($value eq "chara_make"){
				if(!Mebius::alocal_judge()){ next; }
			}

			# ���ʂ̃����N
			if($value){ $mode_href = "?mode=$value"; }
			if($main::in{'mode'} eq $value){ $init_login{'link_line'} .= qq($text / ); }
			else{ $init_login{'link_line'} .= qq(<a href="$init->{'script'}$mode_href">$text</a> / ); }
	}

$init_login{'link_line'} .= qq(
<a href="http://aurasoul.mb2.jp/wiki/ring/%A5%E1%A5%D3%A5%EA%A5%F3%A5%A2%A5%C9%A5%D9%A5%F3%A5%C1%A5%E3%A1%BC">Wiki</a> / 
<a href="${main::guide_url}%A5%E1%A5%D3%A5%EA%A5%F3%A1%A6%A5%A2%A5%C9%A5%D9%A5%F3%A5%C1%A5%E3%A1%BC" class="red">�Q�[���̎�|</a>
</div>
);

	# �e�X�g�v���C��
	if($advmy->{'test_player_flag'}){

			# ���r�����A�J�E���g�������Ă���ꍇ
			if($main::myaccount{'file'}){
				$init_login{'link_line'} .= qq(<div class="message-purple">���̂܂� <a href="$init->{'script'}?mode=log_in">�e�X�g�v���C</a> �o���܂��B�����Ƀv���C����ꍇ�́A<a href="$init->{'script'}?mode=chara_make">�L�����N�^�[��V�K�쐬</a>���Ă��������B</div>);
			}

			# ���r�����A�J�E���g�������Ă��Ȃ��ꍇ
			else{
				#my($request_url) = Mebius::request_url({ TypeEncode => 1 });
				my($backurl_encoded) = Mebius::Encode(undef,"$init->{'base_url'}?mode=chara_make");
				$init_login{'link_line'} .= qq(<div class="message-purple">);
				$init_login{'link_line'} .= qq(���̂܂� <a href="$init->{'script'}?mode=log_in">�e�X�g�v���C</a> �o���܂��B�����Ƀv���C����ꍇ�́A���r�����A�J�E���g��<a href="${main::auth_url}?backurl=$backurl_encoded">���O�C��</a>);
				$init_login{'link_line'} .= qq(�i�܂���<a href="${main::auth_url}?&amp;mode=aview-newform&amp;backurl=$backurl_encoded">�V�K�o�^</a>�j���Ă��������B);
				$init_login{'link_line'} .= qq(</div>);
		}

	}

	# Cookie�����݂��Ȃ��ꍇ
	if(!$ENV{'HTTP_COOKIE'}){
		$init_login{'link_line'} .= qq(<div class="message-purple">Cookie��L���ɂ���A�������͂����ǉ�ʂ��X�V���邱�ƂŃe�X�g�v���C�ł��܂��B</div>);
	}
# Cookie���Q�b�g
my($cookie) = Mebius::get_cookie("MEBI_ADV");
my($cookie_id) = @$cookie;

	if($cookie_id && !$advmy->{'trance_from_time'}){
		$init_login{'link_line'} .= qq(<div class="message-yellow">);
		$init_login{'link_line'} .= qq(���m�点�F ���O�C�����@���ς��܂����B��ID���������̕��́A���萔�ł���<a href="$init->{'script'}?mode=trance">�f�[�^�̈����p��</a>�������Ȃ��Ă��������B);
		$init_login{'link_line'} .= qq(</div>);
	}

	# 
	#if($advmy->{'login_flag'} && $advmy->{'formal_player_flag'}){
	#	$init_login{'link_line'} .= qq(<div class="message-red">);
	#	$init_login{'link_line'} .= qq(���m�点 �c ���̃^�C�~���O�ōL����Ɉړ����Ă��܂��Ƃ��� <a href="http://aurasoul.mb2.jp/_qst/2723.html-177#a">���m�F�̕s�</a> ���񍐂���Ă��܂��B�������l�̖�肪�N����ꍇ�� <a href="http://aurasoul.mb2.jp/_main/mailform.html">���[���t�H�[��</a>��肨�m�点����������΍K���ł��B);
	#	$init_login{'link_line'} .= qq(</div>);
	#}

	# �c��b���\��
	if($advmy->{'login_flag'}){
		my($head_javascript,$view_jsredirect) = &get_jsredirect(undef,$advmy->{'waitsec'});
			$init_login{'link_line'} .= qq($view_jsredirect);
				if($head_javascript){ $main::head_javascript .= qq($head_javascript); }
	}

	# Near State �i�ۑ��j
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,\%init_login); }

return(\%init_login);

}

#-----------------------------------------------------------
# ��{�ݒ� ( �O���[�o���ϐ� )
#-----------------------------------------------------------
sub init_start_adv{

# ���X�N���v�g�ւ̃����N
$main::original_maker = qq(<a href="http://webooo.csidenet.com/asvyweb/">�z�z���FFFADV�����ψ���</a>��<a href="http://aurasoul.mb2.jp/">Edit-���r�E�X�����O</a>);

}

#-----------------------------------------------------------
# Javascript �̎c�莞�ԕ\���A���_�C���N�g
#-----------------------------------------------------------
sub get_jsredirect{

# �錾
my($use,$second) = @_;
my($init) = &Init();
my($line,$form);

	# ���^�[��
	if($ENV{'REQUEST_METHOD'} eq "POST" && !$use->{'TypeAllowPost'}){ return(); }

# �\���b�������������x�点��
my $javascript_second = $second + 1;

# �����X�V
$line = qq(
<script type="text/javascript">
<!--
var start=new Date();
start=Date.parse(start)/1000;
var counts=$javascript_second;

	function CountDown(){
		var now=new Date();
		now=Date.parse(now)/1000;
		var x=parseInt(counts-(now-start),10);
			if(document.form1){ document.form1.clock.value = x; }
			if(x>0){
				timerID=setTimeout("CountDown()", 100)
			}
			else{
				display('none','left_charge_adv');
				display('inline','charge_finished_adv');
				display('enable','monster_battle','champ_battle','special_action');
				display('background','tranceparent','monster_battle','champ_battle','special_action');
			}
	}

window.setTimeout('CountDown()',100);
-->
</script>
);

#push(@main::javascript_files,"adventure");

	my $continue_text;
	if($main::in{'mode'} eq "log_in"){ $continue_text = qq(���R�}���h�H); }
	else{ $continue_text = qq(<a href="$init->{'login_url'}">���R�}���h�H</a>); }

	# �`���[�W���Ԃ��Ȃ��ꍇ
	if($second <= 0){
		$form = qq(
		<form name="form1" class="adv_clock">
		<span>
		�`���[�W�͏I�����Ă��܂��B�@ $continue_text
		</span>
		</form>
		);

	}

	# �`���[�W���Ԃ�����ꍇ
	else{
		$form = qq(
		<form name="form1" class="adv_clock">
		<span id="left_charge_adv">
		�`���[�W�� �c��<input type="text" name="clock" value="$second" class="adv_clock">�b�ł��B
		</span>
		<span id="charge_finished_adv" class="display-none">
		�`���[�W�͏I�����Ă��܂��B�@ $continue_text
		</span>
		</form>
		);

		# JAvascript�p�̃^�O�G�X�P�[�v
		$form =~ s/\n//g;
		$form =~ s!/!\\/!g;

		$form = qq(
		<script type="text/javascript">
		<!--
		document.write('$form');
		-->
		</script>
		);

		$form .= qq(<noscript>�`���[�W�� �c��$second�b�ł��B ���Ԃ��I�������A��ʂ��X�V���Ă��������B</noscript>);

	}

return($line,$form);


}


1;
