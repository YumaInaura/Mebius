
# �錾
use Mebius::BBS;
use Mebius::BBS::Past;
use Mebius::BBS::Index;
use Mebius::Echeck;
use Mebius::Paint;
use Mebius::Utility;
use Mebius::Admin;
use Mebius::Basic;
use Mebius::BBS;
use Mebius::Host;
use Mebius::Adfix;
use Mebius::Directory;
use Mebius::Reason;
use Mebius::HTML;
use Mebius::Move;

use File::Basename;
package main;
use Mebius::Export;

# ���閧�̊Ǘ��Ґݒ�------------------------------------------------

#-----------------------------------------------------------
# �^�C�v�U�蕪��
#-----------------------------------------------------------
sub junction_bbs_special_init_file{

if(!$secret_mode){ &error("���̌f���ł͐ݒ�ł��܂���B"); }

if($in{'action'}){ action_bbs_special_init_file(); }
else{ form_bbs_special_init_file(); }

}

#-----------------------------------------------------------
# �ݒ�t�H�[��
#-----------------------------------------------------------
sub form_bbs_special_init_file{

# CSS��`
$css_text .= qq(
table,tr,th,td{border-style:none;}
table{width:60%;margin:1em 0em;}
body{line-height:1.4;}
input.text{width:12em;}
input.size{width:3em;}
input.setumei{width:25em;}
);

# �t�H�[�����擾
my($form) = &get_form;


# �ύX���܂���
my($actioned_text);
if($in{'actioned'}){ $actioned_text = qq(<strong class="red">�ύX���܂����B</strong>); }

my $print = qq(
<h1><a href="$script">$title</a>�̐ݒ�ύX</h1>
<span class="alert">���D���Ȑݒ�ɂ��邱�Ƃ��o���܂��B�����͔��p�������g���Ă��������B</span><br>
<span class="alert">�����X�̈ꗥ�҂����Ԃ��g��Ȃ��ꍇ�́A�󗓂ɂ��Ă��������B</span><br>
<span class="alert">���f�����A�Ǘ��҂̃��[���A�h���X�͕K�����͂��Ă��������B</span>
$form
$actioned_text
);

Mebius::Template::gzip_and_print_all({},$print);


exit;
}

#-----------------------------------------------------------
# �t�H�[�����擾
#-----------------------------------------------------------

sub get_form{

$form .= qq(
<form action="$script" method="post"><div>
<input type="hidden" name="mode" value="init">
<table>
);

# �^�C�g��
$form .= qq(<tr><td>�f���^�C�g��</td><td><input type="text" name="title" value="$title" class="text"></td></tr>);

# �Ǘ��҂̃��[���A�h���X
$form .= qq(<tr><td>�Ǘ��҂̃��[���A�h���X</td><td><input type="text" name="scad_email" value="$scad_email" class="text"></td></tr>);

# ���X�̑҂�����
$form .= qq(<tr><td>���X�̑҂����� (�ꗥ) </td><td><input type="text" name="norank_wait" value="$norank_wait" class="size"> �� <span class="guide"> ( �����_�� )</span></td></tr>);

# �f���̐�����
$form .= qq(<tr><td>�f���̐�����</td><td><input type="text" name="setumei" value="$setumei" class="setumei"></td></tr>);

# �b�r�r
{
$form .= qq(<tr><td>�f���̐F</td><td><select name="style">);
my @styles = ("blue1","blue2","green","orange","pink","gray","purple");
	foreach(@styles){
			if($style =~ /$_.css$/ || $style eq $_){ $form .= qq(<option value="$_" selected>$_); }
			else{ $form .= qq(<option value="$_">$_); }
	}
$form .= qq(</select></tr>);

}

# ����폜
{
my($checked1,$checked0);
if($candel_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>���[�U�[�ɂ�鎩��폜</td><td>);
$form .= qq(<input type="radio" name="candel_mode" value="1"$checked1> ��);
$form .= qq(<input type="radio" name="candel_mode" value="0"$checked0> �s��);
$form .= qq(</td></tr>);
}


# �O���t�q�k�̏�������
{
my($checked1,$checked0);
if($allowurl_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>�O���t�q�k�̏�������</td><td>);
$form .= qq(<input type="radio" name="allowurl_mode" value="1"$checked1> ��);
$form .= qq(<input type="radio" name="allowurl_mode" value="0"$checked0> �s��);
$form .= qq(</td></tr>);
}

# ���[���A�h���X�̏�������
{
my($checked1,$checked0);
if($allowaddress_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>���[���A�h���X�̏�������</td><td>);
$form .= qq(<input type="radio" name="allowaddress_mode" value="1"$checked1> ��);
$form .= qq(<input type="radio" name="allowaddress_mode" value="0"$checked0> �s��);
$form .= qq(</td></tr>);
}

# �V�K���e�̉�
{
my($checked1,$checked0);
if($no_rgt){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>�V�K���e�̉�</td><td>);
$form .= qq(<input type="radio" name="no_rgt" value="0"$checked0> �N�ł���);
$form .= qq(<input type="radio" name="no_rgt" value="1"$checked1> �Ǘ��҂̂݉�);
$form .= qq(</td></tr>);
}


# �V�K���e�̑҂�����
{
my($checked1,$checked0);
if($freepost_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>�V�K���e�̑҂�����</td><td>);
$form .= qq(<input type="radio" name="freepost_mode" value="1"$checked1> �Ȃ�);
$form .= qq(<input type="radio" name="freepost_mode" value="0"$checked0> ����);
$form .= qq(</td></tr>);
}

# ���񂽂�V�K���e
{
my($checked1,$checked0);
if($fastpost_mode){ $checked1 = " checked"; } else { $checked0 = " checked"; }
$form .= qq(<tr><td>�V�K���e�O�̊m�F�t�H�[��</td><td>);
$form .= qq(<input type="radio" name="fastpost_mode" value="1"$checked1> �Ȃ�);
$form .= qq(<input type="radio" name="fastpost_mode" value="0"$checked0> ����);
$form .= qq(</td></tr>);
}

$form .= qq(</table>);

$form .= qq(<input type="hidden" name="moto" value="$moto">);

$form .= qq(<input type="submit" name="action" value="���̓��e�Őݒ�ύX����">);
$form .= qq(</div></form>);

$form;

}



#-----------------------------------------------------------
# �ݒ��ύX 
#-----------------------------------------------------------
sub action_bbs_special_init_file{

# �Ǐ���
my($line);

# ���b�N�J�n
&lock("$moto");

# �ݒ�l�̃G���[
if($in{'title'} eq ""){ &error("�f���^�C�g���͕K�{�ł��B"); }
if($in{'scad_email'} eq ""){ &error("�Ǘ��҂̃��[���A�h���X�͕K�{�ł��B"); }

# �ݒ�l�̒�`
if($in{'title'} ne ""){ $title = $in{'title'}; }
$in{'norank_wait'} =~ s/[^0-9\.]//g;
if($in{'norank_wait'} ne ""){ $norank_wait = $in{'norank_wait'}; } else { $norank_wait = ""; }
$scad_email = $in{'scad_email'};
$scad_name = $admy_name;
$in{'style'} =~ s/\W//g;
$style = $in{'style'};
$setumei = $in{'setumei'};
if($in{'allowurl_mode'} eq "1"){ $allowurl_mode = 1; } else { $allowurl_mode = 0; }
if($in{'allowaddress_mode'} eq "1"){ $allowaddress_mode = 1; } else { $allowaddress_mode = 0; }
if($in{'freepost_mode'} eq "1"){ $freepost_mode = 1; } else { $freepost_mode = 0; }
if($in{'fastpost_mode'} eq "1"){ $fastpost_mode = 1; } else { $fastpost_mode = 0; }
if($in{'candel_mode'} eq "1"){ $candel_mode = 1; } else { $candel_mode = 0; }
if($in{'fastpost_mode'} eq "1"){ $fastpost_mode = 1; } else { $fastpost_mode = 0; }
if($in{'no_rgt'} eq "1"){ $no_rgt = 1; } else { $no_rgt = 0; }

# �X�V���e
$line = qq($title<>$allowurl_mode<>$allowaddress_mode<>$fastpost_mode<>$freepost_mode<>$candel_mode<>$no_rgt<>
$norank_wait<>$style<>$setumei<>
$scad_email<>$scad_name<>
);

# �ݒ�t�@�C������������
open(FILE_OUT,">${int_dir}_invite/init_${secret_mode}.cgi");
print FILE_OUT $line;
close(FILE_OUT);
chmod($logpms,"${int_dir}_invite/init_${secret_mode}.cgi");

# ���b�N����
&unlock("$moto");

# ���_�C���N�g
Mebius::Redirect("","$script?mode=init&actioned=1");


exit;

}

#�� �Ǘ��җp�̃}�C�ݒ�-----------------------------------------------------------


#-----------------------------------------------------------
# �}�C�ݒ�
#-----------------------------------------------------------
sub admin_mydata{

# �錾
my($domain_links);
my(%renew_mydata);

	# ���e��A�W�����v����
	if($in{'action'}){ $jump_head ="<meta http-equiv=\"refresh\" content=\"0;url=./${script}?mode=mydata\">"; }

$main::sub_title = "�}�C�ݒ� - $main::server_domain";

	# �}�C�f�[�^��ύX
	if($in{'action'}){
		&change_mydata_admin();
	}


	foreach(@domains){
			if($main::server_domain eq $_){ $domain_links .= qq($_\n); }
			else{ $domain_links .= qq(<a href="https://$_/jak/index.cgi?mode=mydata">$_</a>\n); }
	}

my $print .= <<"EOM";
<a href="$home">�s�n�o</a>
<a href="JavaScript:history.go(-1)">�O�̉�ʂɖ߂�</a><hr>
<strong>$my_name</strong>�̊Ǘ��Ґݒ�i�}�C�ݒ�j���o���܂��B<br><br>

<strong style="color:#f00;">�ݒ�l���h�󗓁h�ɕύX����ƁA�����ݒ�ɂȂ�܂��B</strong>(�����ςɂȂ�����󗓐ݒ��)<br>
<strong style="color:#f00;">���l�͔��p�����Őݒ肵�Ă��������B</strong><br><br>

<div>
�T�[�o�[�F $domain_links
</div>
<hr>
EOM

# ���ύX���\���p�t�H�[����\��
$print .= mydata_form();

# �f�[�^���e�L�X�g�Ŋm�F

	if($admy{'rank'} >= $master_rank){
		$print .= "���f�[�^�̏�ԁi�m�F�p�j<br>";

		open(MYDATA_IN,"<","_mydata/${admy_file}.cgi");
		while(<MYDATA_IN>){ $print .= "$_<br>";}
		close(MYDATA_IN);

	}

# �t�b�^
$print .= <<"EOM";
<hr>
<a href="$home">�s�n�o</a>
<a href="JavaScript:history.go(-1)">�O�̉�ʂɖ߂�</a>
EOM


Mebius::Template::gzip_and_print_all({},$print);

exit;

}


use strict;

# --------------------------------------------
# �}�C�ݒ�̕ύX
# --------------------------------------------
sub change_mydata_admin{

# �錾
my($basic_init) = Mebius::basic_init();
my(%renew_mydata);

	# �����̐ݒ�t�@�C�����ǂ������`�F�b�N
	if($main::in{'file'} ne $main::admy{'id'} && $main::admy{'rank'} < $main::master_rank){
		main::error("�����̃t�@�C���ł͂���܂���B");
	}

	# ���[���A�h���X�̏�������
	if($main::in{'mobile_email'}){ Mebius::Email::mail_format("Error-view",$main::in{'mobile_email'}); }
	if($main::in{'email'}){ Mebius::Email::mail_format("Error-view",$main::in{'email'}); }

# �ύX���`
$renew_mydata{'deleted_text'} = $main::in{'deleted_text'};
$renew_mydata{'email'} = $main::in{'email'};
$renew_mydata{'mobile_email'} = $main::in{'mobile_email'};
$renew_mydata{'res_template'} = $main::in{'res_template'};

# �A�J�E���g�̃����N
	my($myaccount) = Mebius::my_account();
	if($main::in{'account'} && $myaccount->{'file'}){ $renew_mydata{'account'} = $myaccount->{'file'}; }
	elsif($main::in{'account_delete'}){ $renew_mydata{'account'} = ""; }

	if($main::in{'use_mailform'}){ $renew_mydata{'use_mailform'} = 1; } else { $renew_mydata{'use_mailform'} = 0; }

	# �A�J�E���g����
	if($main::in{'close_account'} && $main::in{'close_account_check'}){
		$renew_mydata{'concept'} = qq( Close-account);
	}

# �X�V
my(%member) = Mebius::Admin::MemberFile("Edit-mydata Renew Allow-empty-password Use-renew-hash",$main::in{'file'},undef,%renew_mydata);

Mebius::Redirect("","$basic_init->{'admin_http'}://$main::server_domain/jak/index.cgi?mode=mydata&file=$main::in{'file'}");

}

no strict;

# --------------------------------------------
# �f�[�^�\�������M�p�t�H�[������
# --------------------------------------------

sub mydata_form{

# �J��ID
my $id = $main::in{'file'};

	# �J��ID���`
	if($main::in{'file'}){
		$id = $main::in{'file'};
	}
	else{
		$id = $main::admy{'id'};
	}

	# �����̐ݒ�t�@�C�����ǂ������`�F�b�N
	if($id ne $main::admy{'id'} && $main::admy{'rank'} < $main::master_rank){
		main::error("�����̃t�@�C���ł͂���܂���B");
	}

# �\������
my(%admy) = Mebius::Admin::MemberFile("Get-hash Allow-empty-password",$id);

$pri_myd_template = $myd_template;
$pri_myd_template =~ s/<br>/\r/g;

$pri_myd_formlink = $myd_formlink;
$pri_myd_formlink =~ s/<br>/\r/g;

if($admy{'use_mailform'}){ $checked_use_mailform = $main::checked; }

# HTML

my $print .= <<"EOM";
<form action="$script" method="POST">
<input type="submit" value="���̓��e�Ń}�C�f�[�^��ύX����" class="isubmit">
<br><br>
<input type="hidden" name="mode" value="mydata">
<input type="hidden" name="action" value="1">

<div>
<h3>�����[���A�h���X</h3>
<p>
PC�F <input type="text" name="email" value="$admy{'email'}" class="input">
<span class="alert">���e��A���[�g�ȂǂɎg���܂��B</span>
<input type="checkbox" name="use_mailform" value="1" id="use_mailform"$checked_use_mailform> <label for="use_mailform">���[���t�H�[�����g��</label>
</p>
<p>
�g�сF <input type="text" name="mobile_email" value="$admy{'mobile_email'}" class="input">
<span class="alert">���e��A���[�g�ȂǂɎg���܂��B</span>
</p>

</div>

EOM

$print .= qq(
<div>
<h3>���A�J�E���g</h3>
���݂̐ݒ�F $admy{'account'}
<br$main::xclose>
<label><input type="checkbox" name="account" value="1"> <a href="${main::auth_url}$main::myaccount{'file'}/">$main::myaccount{'file'}</a> ���Ǘ��p�A�J�E���g�ɐݒ肷��</label>
<label><input type="checkbox" name="account_delete" value="1"> �A�J�E���g�̃����N����������</label>
</div>
);


$print .= <<"EOM";
<h3>�f���̐ݒ�</h3>
���ԐM���e���폜�����Ƃ��̃R�����g
�i��F���̓��e�͍폜����܂����`�Ȃǁj<br>
<input type="text" name="deleted_text" value="$admy{'deleted_text'}" class="input">
<br><br>
EOM

my $none = qq(
���e�L���P�y�[�W������A�����̕ԐM��\\�����邩�B<br>
�i�ԐM���������Ƃɋ�؂邩�j
�i��F100 50 20 �Ȃǁj<br>
<input type="text" name="th_page" value="$myd_th_page" class="input">
<br><br>

���ԐM���e�P������A�`�s�ȏゾ�Əȗ�����B<br>
�i�Ǘ��ғ��e�͏ȗ�����܂���j
�i��F50 20 5�Ȃǁj<br>
<input type="text" name="ryaku" value="$myd_ryaku" class="input">
<br><br>

���e�L���h���h�Ō��������Ƃ��ɁA�\\������ő哊�e���i�g�h�s���j�B<br>
�i���Ȃ�����ƁA�\\�����y���Ȃ�܂��j
�i��F50 20 5�Ȃǁj<br>
<input type="text" name="oyasearch" value="$myd_oyasearch" class="input">
<br><br>

�����e�t�H�[���̃���<br>
);

my($textarea_res_template) = Mebius::Descape(undef,$main::admy{'res_template'});
#$print .= qq(<textarea name="res_template" style="width:100%;height:5em;">) . &Escape::HTML([$textarea_res_template]) . qq(</textarea><br><br>);

# ���X�e���v���[�g

$print .= <<"EOM";
<br>
<input type="hidden" name="file" value="$id">

<div style="margin-top:1em;">
<input type="submit" value="���̓��e�Ń}�C�f�[�^��ύX����" class="isubmit">
</div>


<div style="background:#fdd;padding:0.5em 1em;margin:1em 0em;">
<h3>���A�J�E���g�̓���</h3>
<input type="checkbox" name="close_account" value="1" id="close_account"><label for="close_account">�A�J�E���g�𓀌�����</label>
<input type="checkbox" name="close_account_check" value="1" id="close_account_check"><label for="close_account_check">�A�J�E���g�𓀌�����i�m�F�j</label>

<p class="red">���A�J�E���g���s�����p����Ă��鋰�ꂪ����ꍇ�ȂǁA���̃A�J�E���g�𓀌����A���O�C�����֎~���܂��B
�����ǃA�J�E���g�𓀌�����ƁA�����ł͍ĊJ���邱�Ƃ��o���Ȃ����ߒ��ӂ��Ă��������B</p>
</div>
</form>
EOM


$print;

}


no strict;

# �� �f���̊Ǘ�------------------------------------------------


#-----------------------------------------------------------
# �}�C�f�[�^�Ȃǂ̐ݒ�
#-----------------------------------------------------------

sub ad_settei{

# �폜���܂����A�̃e�L�X�g�����߂�

	# �}�C�f�[�^����ꍇ
	if($main::admy{'deleted_text'}){ $del_text = qq(�y $main::admy{'deleted_text'} (<a href="${guide_url}">?</a>) �z);}

	# �����ꍇ
	else{ $del_text = qq(�y �Ǘ��ҍ폜 (<a href="${guide_url}">?</a>) �z); }

$del_text2 ='�y�폜�ρz';

}



#-------------------------------------------------
#  �Ǘ��ҋ@�\
#-------------------------------------------------
sub admin {

require Mebius::BBS;
&init_start_bbs("Admin-mode");

local($subject,$log,$top,$itop,$sub,$res,$nam,$em,$com,$da,$ho,$pw,$re,$sb,$na2,$key,$last_nam,$last_dat,$del,@new,@new2,@sort,@file,@del,@top);

	# ���j���[����̏���
	if ($in{'job'} eq "menu") {
		foreach ( keys(%in) ) {
			if (/^past(\d+)/) {
				$in{'past'} = $1;
				last;
			}
		}
	}

	# �����`�F�b�N
	$in{'no'} =~ s/[^0-9\0]//g;

	# index��`
	if ($in{'past'} == 3 && $authkey) {
		&member_mente;
	} elsif ($in{'past'} == 2) {
		&filesize;
	} elsif ($in{'past'} == 1) {
		$log = $pastfile;
		$subject = "�ߋ����O";
	} else {
		$log = $nowfile;
		$subject = "���s���O";
	}


# �C�����s
if($in{'action'} eq "edit_kiji") { &edit_log("admin"); }

#-------------------------------------------------
# �X���b�h����
#-------------------------------------------------
elsif($in{'thread_control'}) {

Mebius::Admin::bbs_thread_control_multi_from_query();

Mebius::redirect_to_back_url();

#admin_after_action("�L���̏�Ԃ�؂�ւ��܂����B");

exit;

}

#-----------------------------------------------------------
# ��������
#-----------------------------------------------------------

elsif($in{'action'} eq "view" && $in{'no'} ne "") {

my($my_admin) = Mebius::my_admin();

	# �����Ȃǂ̔���
	if ($my_admin->{'rank'} < 1) { &error("�폜����������܂���"); }
	if ($in{'del_type'} == 3 && !$my_admin->{'master_flag'}) { &error("�폜����������܂���"); }
	if ($in{'del_type'} == 3 && $in{'no2'} =~ /\b0\b/) { &error("�e�L���̍폜�͂ł��܂���"); }
	if ($in{'del_type'} == 5 && $my_rank < 10) { &error("��������������܂���"); }


	# ���X����
	if($in{'job'} eq "del" && ($in{'no2'} || $in{'control_type'})) {

		my($multi_control) = Mebius::Admin::bbs_thread_control_multi_from_query();

		my($controled_res_numbers) = Mebius::join_array_with_mark(",",$multi_control->{'last_control_thread'}->{'controled_res_numbers'});

			if(Mebius::redirect_to_back_url()){

			} else {
				Mebius::redirect("?mode=view&no=$multi_control->{'last_control_thread'}->{'number'}&No=$controled_res_numbers#S$multi_control->{'last_control_thread'}->{'controled_res_numbers'}->[0]");
			}

	}

	# ���X�C��

	elsif ($in{'job'} eq "edit" && $in{'res'} ne "") {
		($in{'res'}) = split(/\0/, $in{'res'});
		&edit_log("admin");
	}

#-----------------------------------------------------------
# �������͂����Ƀ��X��������s
#-----------------------------------------------------------

&error("���s�^�C�v��I��ł��������B"); 

}


&error("���s�^�C�v��I��ł��������B");

exit;

}

use Mebius::Handle;
use strict;

no strict;


#-----------------------------------------------------------
# �g�уA�N�Z�X�𔻒�
#-----------------------------------------------------------
sub check_kaccess{

my($host,$age) = @_;
my($kaccess_one);

if($host eq "" || $age eq ""){ return; }

# �g�є���
if($host =~ /docomo\.ne\.jp$/){
if($age =~ /^DoCoMo([a-zA-Z0-9 ;\(\/\.]+?)ser([0-9a-z]+)/){ $kaccess_one = $2; }
}
elsif($host =~ /ezweb\.ne\.jp$/){
if($age =~ /^([0-9]+)_([a-z]+)\.ezweb\.ne\.jp$/){ $kaccess_one = $1; }
}
elsif($host =~ /(softbank\.ne\.jp$|vodafone\.ne\.jp$|jp-([dnrtcknsq]+)\.ne\.jp$)/){
if($age =~ /SN([0-9]+)/){ $kaccess_one = $1; }
}

return($kaccess_one);

}



#-------------------------------------------------
#  ���ӓ��e����폜
#-------------------------------------------------

sub delete_rcevil{

# �Ǐ���
my($type,@resnumbers);
my(@line);

# �t�@�C�����J��
open(IN,"<","${int_dir}_sinnchaku/rcevil.log");
	while(<IN>){
		chomp;
		my($key,$typename,$title,$url,$sub,$handle,$comment,$resnumber,$lasttime,$dat,$category,undef,$echeck_oneline) = split(/<>/);

		foreach(@resnumbers){
		if($url =~ /^http:\/\/$server_domain\/_$moto\/$in{'no'}.html-$_/){ $key = "2"; }
		}

		push(@line,"$key<>$typename<>$title<>$url<>$sub<>$handle<>$comment<>$resnumber<>$lasttime<>$dat<>$category<><>$echeck_oneline\n");
	}
close(IN);

# �t�@�C���������o��
Mebius::Fileout(undef,"${int_dir}_sinnchaku/rcevil.log",@line);


}

#-------------------------------------------------
#  �L������������ꍇ�A�폜�ς݃C���f�b�N�X����s�폜
#-------------------------------------------------
sub deleted_index_delete{

# �����������݂̂̋Ǐ���
my($top,$no,$no2,$line,$lock);

	# �폜�ς݃C���f�b�N�X���J���A�Y���s���폜
	foreach $no (@lock) {

		open(DELETED_INDEX_IN,"<","${int_dir}_deleted/${moto}_deleted.cgi");

			while(<DELETED_INDEX_IN>){
				($no2) = split (/<>/,$_);
					if($no ne "$no2"){ $line .= $_; }
			}

		close(DELETED_INDEX_IN);

		# �폜�ς݃C���f�b�N�X�̏����o��
		Mebius::Fileout(undef,"${int_dir}_deleted/${moto}_deleted.cgi",$line);

		}
	}

use strict;

#-------------------------------------------------
#  ���胆�[�U�[�Ɂy�V�K���e�z�̑҂����Ԃ����
#-------------------------------------------------

sub delete_wait{

# �Ǐ���
my($file,$oktime,$no) = @_;
my $time = time;
my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();
our($moto);

# �����`�F�b�N�Ȃ�
$file = Mebius::Encode("",$file);
if($file eq ""){ return; }
$no =~ s/\D//g;

my $print_oktime = $time + $oktime . "<>_$moto<>$no<>\n";

Mebius::Fileout(undef,"${share_directory}_ip/_ip_delnew/$file.cgi",$print_oktime);


}


no strict;

#�� �f���̃��j���[�y�[�W ------------------------------------------------



#-----------------------------------------------------------
# �Ǘ����[�h �f�����j���[
#-----------------------------------------------------------

sub admin_indexview{

my($basic_init) = Mebius::basic_init();

# BODY Javascript ��`
$body_javascript = qq( onload="document.SEARCH.word.focus()");

# �T�u�L�����[�h�̏ꍇ�A���C���Ƀ��_�C���N�g
if($subtopic_mode){ print "location:$moto.cgi\n\n"; exit; }

local($num,$sub,$res,$nam,$date,$na2,$key,$alarm,$i,$data,$top,$count);


# CSS��`
if($subtopic_link){
$css_text .= qq(
.subres{color:#080;}
.subres2{color:#080;font-size:80%;}
);
}



my $print = <<"EOM";
<div align="center">
<div class="div6"><br>

<a href="/_$moto/" class="title">$title (�Ǘ����[�h)</a>
<span class="size0"><br><br></span>
$my_name�@�i�Ǘ������F$my_rank�j
$setumei<br><br>
<span class="size4">
<a href="$home" accesskey="0">�s�n�o</a>&nbsp;
<a href="$script?mode=form" accesskey="1">�V�K</a>&nbsp;
<a href="$basic_init->{'admin_report_bbs_url'}">�폜��</a>&nbsp;
$adroom_link&nbsp;
<a href="${base_url}jak/chat/comchat.cgi" style="color:#f00;">�`���b�g</a>
<a href="$main::main_url?mode=mydata" style="color:#f00;">�}�C�ݒ�</a>
<a href="/wiki/guid/">�K�C�h</a>

<a href="$script?mode=logoff">off</a>
</span></div>
<br>
<form action="$script" name="SEARCH" class="margin">
<div>
<input type="hidden" name="mode" value="find">
<input type="text" name="word" size="38" value="">
<input type="submit" value="�L������">
</div>
</form>
EOM

$print .= <<"EOM";
<a name="up"></a><table summary="�y�[�W�ꗗ"><tr><td class="page"><a href="#dw" accesskey="3">Page</a>
EOM

$page = $i_max / $menu1;
$mile = 1;
	while ($mile < $page + 1){
		$mine = ($mile - 1) * $menu1;
			if($main::in{'p'} == $mine){ $print .= qq($mile\n); }
			else{ $print .= "<a href=\"$script?p=$mine\">$mile</a>\n"; }
		$mile++;
	}

#���j���[�㕔�����N

$print .= <<"EOM";
<span class="size3">
<a href="$script?mode=past">�ߋ�</a>
</span>
<hr>
<span class="size3">
<a href="$main::main_url?mode=mydata" style="color:#f00;"><strong>�}�C�ݒ��ύX</strong></a> / 
EOM


if($in{'lock'}){print"���b�N ";}
else{print"<a href=\"$script?lock=1\">���b�N���̋L����\\��</a> / ";}


#<a href="${category}.cgi?mode=view&no=${moto}&r=0">�V�K���e���ꂽ�L��</a> / 
#<a href="${category}.cgi?mode=view&no=${moto}&r=1">�V���ԐM</a>

$print .= <<"EOM";
</span>
</td></tr></table><br>
<table cellpadding="3" summary="�L���ꗗ"><tr><td class="td0">No</td><td class="td1">
EOM


# �X���b�h�\��

if ($main::in{'p'} eq "") { $main::in{'p'}=0; }
$i=0;
open(IN,"$nowfile");

$top = <IN>;
($big_num,$big_nothing2,$big_nothing3,$big_nothing4) = split(/<>/, $top);

if($my_rank >= $master_rank){
$cordlink = qq(
 / <a href="$script?mode=init_edit">�ݒ�</a>
 / <a href="$script?mode=cord&amp;file=init">���</a>
 / <a href="$script?mode=cord&amp;file=idx">���s</a>
 / <a href="$script?mode=cord&amp;file=pst">�ߋ�</a>
 / <a href="http://aurasoul.mb2.jp/pmlink/pmlink.cgi?mode=adapply" class="red">����</a>
 / <a href="http://mb2.jp/_auth/spform.html" class="red">SP���</a>

);

}

# �V�[�N���b�g�̐ݒ�
if($secret_mode && ( $secret_mode eq $admy_file || $admy_rank >= $master_rank ) ){
$cordlink .= qq( / <a href="$script?mode=init" class="red">�f���̊�{�ݒ�</a>);
$cordlink .= qq( / <a href="$mainscript?mode=member&amp;adfile=$secret_mode" class="red">�����o�[�Ǘ�</a>);
}

$print .= qq(
�薼</td><td class="td2">���O</td><td class="td3">�ŏI</td><td class="td4"><a name="go"></a>�ԐM</td></tr>
<tr><td>0</td><td>
<a href="/_$moto/rule.html">��$title�̃��[��</a>
 / <a href="$script?mode=view&amp;no=$big_num">�ŐV�L��</a>);

$print .= qq( / <a href="/_$main::realmoto/all-deleted.html#M">�폜�ς�(�ʏ��)</a>);

$print .= qq($cordlink
</td><td>�ʑ���</td><td>�J���Ă�������</td><td>0��</td></tr>
);


	while (<IN>) {
		$i++;

		if(!$in{'lock'}){
		next if ($i < $main::in{'p'} + 1);
		next if ($i > $main::in{'p'} + $menu1);
		}

		my($num,$sub,$res,$nam,$date,$na2,$key) = split(/<>/);


		# �V���L���`�F�b�N
		my($mark,$stopic);

		if($key eq "0"){$mark = "�~";}
		elsif($key == 2){$mark = "��";}
		elsif($key == 5){$mark = "�D";}
		elsif($key == 9){$mark = "18";}
		elsif($key == 8){$mark = "15";}
		elsif($date > $time - 60*60*3){ $mark = "��"; }
		elsif($date > $time - 60*60*24){ $mark = "��"; }
		elsif($date > $time - 60*60*24*7){ $mark = "��"; }
		else{$mark = "-";}

		if($key ne "0"){
		$mark = qq(<a href="$script?mode=view&amp;no=${num}#S${res}">$mark</a>);
		}

			# �T�u�L���擾
			if($subtopic_link){
			my($submark);
			my($res,$restime,$reser) = &get_subres_admin($num);
			if($reser =~ /�T�u�L��/){ $reser = ""; }
			if($restime > $time -  60*60*24){ $submark = qq( <a href="sub$moto.cgi?mode=view&amp;no=$num#S$res" class="subres2">��$reser</a> ); }
			if($res){ $stopic = qq(&nbsp; ( <a href="sub$moto.cgi?mode=view&amp;no=$num" class="subres">Re:$res</a> $submark ) ); }
			}


			# �A�C�R����`

			if($in{'lock'} && $key ne "0"){ next; } else {
			$print .= "<tr><td>$mark</td><td>";

			if (!$key) { $print .= "[<span style=\"color:#FF0000;\">�~</span>] "; }
			elsif ($key == 2) { $print .= "[<span style=\"color:#FF0000;\">�s��</span>] ";}
			elsif ($key == 5) { $print .= "[<span style=\"color:#FF0000;\">�D</span>] "; }

			$print .= "<a href=\"$script?mode=view&amp;no=$num\">$sub</a>$stopic";

			$print .= "</td><td>$nam</td><td>$na2</td><td>$res��</td></tr>";

			}
	}
	close(IN);

$print .= "</table><br><a name=\"dw\"></a>
<table summary=\"�y�[�W�ꗗ\"><tr><td class=\"page\"><a href=\"#up\" accesskey=\"4\">Page</a>\n";

# �y�[�W�ړ��{�^���\��
$page = $i_max / $menu1;
$mile = 1;
	while ($mile < $page + 1){
		$mine = ($mile - 1) * $menu1;
			if($main::in{'p'} == $mine){ $print .= qq($mile\n); }
			else{ $print .= "<a href=\"$script?p=$mine\">$mile</a>\n"; }
		$mile++;
	}

$print .= <<"EOM";
<a href="$script?mode=past" class="size3">�ߋ����O</a>
</td></tr></table>
</div>
EOM

# �C�����[�h�փ����N
if($my_rank >= 100){
if($in{'repair'}){
#print"<a href=\"$script\">�߂�</a><br>"; require 'part_adrepair.cgi'; &part_repair;
}
else{
$print .= qq(<br><a href="$script?repair=1&end=$big_num">�C��</a>\n);
$print .= qq(<a href="$script?mode=findkey">�S������</a>\n);
$print .= qq(<a href="$script?mode=keycheck">�L�[�`�F�b�N</a>\n);
$print .= qq(<a href="$script?mode=url">�t�q�k�ϊ�</a>\n);

}
}

Mebius::Template::gzip_and_print_all({ Title => $title },$print);


exit;

}


#-----------------------------------------------------------
# �T�u�L���̃��X�����擾
#-----------------------------------------------------------
sub get_subres_admin{
my($file) = @_;

open(SUB_IN,"${int_dir}sub${moto}_log/$file.cgi");
my $top = <SUB_IN>;
my($none,$reser,$res,$none,$none,$restime) = split(/<>/,$top);
close(SUB_IN);

return($res,$restime,$reser);

}



# �� ���[�U�[�Ǘ� -----------------------------------------------------


#-----------------------------------------------------------
# �Ǘ��ԍ��̑�����
#-----------------------------------------------------------
sub admin_cdl{

	# ���[�h�U�蕪��
	if($in{'file'} eq ""){ SelectView(); }
	elsif($in{'type'} eq "control_all_res_from_history"){ control_all_res_from_history(); }
	else{ view_user_data(); }

# �����I��
exit;

}

use strict;

#-----------------------------------------------------------
# �t�@�C����I�Ԃ��߂̃y�[�W
#-----------------------------------------------------------
sub SelectView{

my($view_line,$dos_flow_directory,$files);

	# ���_�C���N�g
	if($main::in{'select_file'}){
		my($file) = $main::in{'select_file'};
		$file =~ s/^(\s|�@)+//g;
		$file =~ s/(\s|�@)+$//g;
			if($main::in{'filetype'} eq "isp"){ ($file) = Mebius::Isp(undef,$file); }
			elsif($main::in{'filetype'} eq "second-domain"){ (undef,$file) = Mebius::Isp(undef,$file); }
			else{ $file = $file; }
		my($file_encoded) = Mebius::Encode(undef,$file);
		Mebius::Redirect(undef,"${main::main_url}?mode=cdl&file=$file_encoded&filetype=$main::in{'filetype'}");
	}


my $file_encoded = Mebius::Encode(undef,$main::in{'select_file'});

$view_line .= qq(<h2>�C�ӂ̊Ǘ��t�@�C���Ɉړ�</h2>\n);
$view_line .= qq(<div style="">\n);
$view_line .= qq(<form action="" style="margin:1em 1em;">\n);
$view_line .= qq(<input type="hidden" name="mode" value="cdl">\n);
$view_line .= qq(<input type="text" name="select_file" style="width:20em;font-size:110%;" value="$main::in{'select_file'}"><br><br> \n);

$view_line .= qq(<input type="submit" name="filetype" value="number">\n);
$view_line .= qq(<input type="submit" name="filetype" value="account">\n);
$view_line .= qq(<input type="submit" name="filetype" value="host">\n);
$view_line .= qq(<input type="submit" name="filetype" value="isp">\n);
$view_line .= qq(<input type="submit" name="filetype" value="second-domain">\n);
$view_line .= qq(<input type="submit" name="filetype" value="addr">\n);
$view_line .= qq(<input type="submit" name="filetype" value="agent">\n);
$view_line .= qq(<input type="submit" name="filetype" value="handle">\n);

#$view_line .= qq(<input type="submit" value="���s����">\n);
$view_line .= qq(</form>\n);
$view_line .= qq(</div>\n);

# DOS����f�B���N�g�����擾
opendir($dos_flow_directory,"${main::int_dir}_dos/_dos_flow/");
my @dos_flow_files = grep(!/^\./,readdir($dos_flow_directory));
close $dos_flow_directory;

	# ��DOS���肳�ꂽ�t�@�C����\������ꍇ ( �}�X�^�[�̂� )
	if($main::admy_rank >= $main::master_rank){

		# ���`
		$view_line .= qq(<h2>DOS����t�@�C�� ( �Ǘ�����$main::master_rank )</h2>\n);

			# DOS����f�B���N�g���W�J
			foreach $files (@dos_flow_files){

				# �Ǐ���
				my($addr,$host);

				# �t�@�C�����𕪉�
				my($host_or_addr) = split(/_/,$files);

				# �z�X�g����IP�A�h���X���𔻒�
				my($file_type) = Mebius::Format::HostAddr(undef,$host_or_addr);

				# DOS����t�@�C���Q����擾
				#my(%dos_flow) = Mebius::Dos::FlowFile("Get-hash",$host_or_addr);
				#my(%dos) = Mebius::Dos::AccessFile("Get-hash",$dos_flow{'addr'});

				# �\���s�̒�`
				$view_line .= qq(<a href="${main::main_url}?mode=cdl&amp;file=$host_or_addr&amp;filetype=$file_type">$host_or_addr</a>\n);
					#if($dos{'dos_count'}){ $view_line .= qq(($dos{'dos_count'})\n); }
				$view_line .= qq(<br$main::xclose>\n);

			}
	}


Mebius::Template::gzip_and_print_all({},$view_line);

exit;


}


#-----------------------------------------------------------
# ��{���������s
#-----------------------------------------------------------
sub view_user_data{

# �錾
my($basic_init) = Mebius::basic_init();
my($server_domain) = Mebius::server_domain();
my($parts) = Mebius::Parts::HTML();
my($type) = @_;
my($invited_flag,$invite_input,$okaddr_link,$select_dir,$file_enc,$file2,$adevice_mark,$disabled_reset);
my($none,$reshistory_line,$login_hisory_line,$plustype_adevice,$option_deny_select,$input_revety,$action_date,$dos_line,$date_unblock);
my($whois_line,$account_link,%history,$input_block,$other_history_line,$file,$left_penalty_date,$domain_links);
my $html = new Mebius::HTML;
our(%in,@domains,$postbuf,$master_rank,$leader_rank,$admy_rank,$home,$admy_file,$script,$mainscript);

# CSS��`
our $css_text .= qq(
table,th,tr,td{border-style:none;}
table{margin-top:0.5em;padding:1em;}
h1{line-height:1.3;font-size:170%;}
td{padding:0.3em 0.2em;}
li{line-height:1.6;}
div.before_deleted{background-color:#ff9;padding:1em;margin:1em 0em;}
div.nodata{margin:1em 0em;padding:1em;background-color:#ccc;}
div.block_data{background-color:#cee;}
div.penalty_data{background-color:#fdb;}
th{display:none;}
.domain_links{color:#080;font-size:140%;margin:1em 0em;font-style:oblique;}
.block{padding:0em 1.0em;}
div.savedata{background:#dee;padding:1em;margin:1em 0em;}
div.block_select{margin:1em 0em;}
div.block_bbs{margin:1em 0em;}
div.reshistory{background:#fe9;padding:1.0em;}
div.other_history{padding:0.3em 1.0em;border:1px solid #b9f;}
td.left{width:8em;}
hr{border-color:#000;}
div.deleted_history{padding:1em 0.5em;}
);

# �^�C�g����`
$main::sub_title = qq(���[�U�[�Ǘ� - $in{'file'});

	# �t�@�C���^�C�v�̒�`
	if($in{'filetype'} eq "account"){ $plustype_adevice .= qq( Account); }
	elsif($in{'filetype'} eq "number" || $in{'filetype'} eq "cnumber"){ $plustype_adevice .= qq( Cnumber); }
	elsif($in{'filetype'} eq "agent"){ $plustype_adevice .= qq( Agent); }
	elsif($in{'filetype'} eq "host"){ $plustype_adevice .= qq( Host); }
	elsif($in{'filetype'} eq "addr"){ $plustype_adevice .= qq( Addr); }
	elsif($in{'filetype'} eq "handle"){ $plustype_adevice .= qq( Handle); }
	elsif($in{'filetype'} eq "second-domain"){ $plustype_adevice .= qq( Second-domain); }
	elsif($in{'filetype'} eq "isp"){
		$type .= qq( Isp-view);
		$plustype_adevice .= qq( Isp);
	}

my($adevice_type,$select_dir,$k_access,$kaccess_one) = &adevice("$plustype_adevice",$in{'file'});

	# �Ǘ��҂̏ꍇ
	if($in{'file'} eq "�Ǘ���"){ &error("�Ǘ��҂ł��A��������J�l�ł��I"); }

	# �t�@�C���A�f�B���N�g����`
	if($adevice_type eq "kaccess_one"){
		$file = "${kaccess_one}_${k_access}";
		$adevice_mark = qq(<span style="font-size:90%;color:#080;">( �ő̎��ʁF ${kaccess_one}_${k_access} )</span>);
	}
	else{
		$file = $in{'file'};
		$adevice_mark = qq(<span style="font-size:90%;color:#080;">( $adevice_type )</span>);
	}

# ���^�[��
if($file eq "" || $adevice_type eq ""){ return; }

# ���X�҂����Ԃ̑���
if($in{'change'}){ &change(undef,$plustype_adevice); }

# �t�@�C�����J��
my(%penalty) = Mebius::penalty_file("Get-hash Get-deleted-index Get-flag $plustype_adevice",$main::in{'file'});

# �������R���擾
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_delreason.pl";
my($select) = shift_jis(Mebius::Reason::get_select_reason($penalty{'block_reason'},"ACCOUNT"));
my $reason = &delreason($penalty{'block_reason'},"SUBJECT");
if($reason){ $reason = qq($reason); }

	# ���e�����̌�����t���v�Z
	if($penalty{'block_decide_time'}){
		($action_date) = Mebius::Getdate(undef,$penalty{'block_decide_time'});
	}

# ���e�������̏ꍇ�A�G���A�ɐԐF������
if($penalty{'block_time_flag'}){ $css_text .= qq(div.block_data{background-color:#fbb;}); }
if($penalty{'block_time_flag'} && $penalty{'block'} eq "3"){ $css_text .= qq(div.block_data{background-color:#9d9;}); }

	# �҂����Ԃ��v�Z
	if($penalty{'penalty_time'} > time){
		($left_penalty_date) = Mebius::SplitTime(undef,$penalty{'penalty_time'}-$main::time);
	}

	# �h���C���؂�ւ������N
	{
		my($i);
			foreach(@domains){
			$i++;
				if($i >= 2){ $domain_links .= qq( - ); }
				if($_ eq $server_domain){ $domain_links .= qq( $_ ); }
				else{ $domain_links .= qq( <a href="$basic_init->{'admin_http'}://$_/jak/index.cgi?$postbuf">$_</a> ); }
			}
		$domain_links = qq(<div class="domain_links">�h���C���F $domain_links</div>);
	}
	#mode=cdl&amp;file=$file

# �������Ԃ̃Z���N�g�{�b�N�X���`
my $d_unblock = 1+int(($penalty{'block_time'} - $main::time)/(60*60*24)) if($penalty{'block_time'});
my(%date_unblock) = Mebius::Getdate("Get-hash",$penalty{'block_time'}) if($penalty{'block_time'});

	# �������̑I��
	if($penalty{'Flag'}->{'some_indefinite_block'}){
		$date_unblock = "������";
		$input_revety = qq(<option value="not_change"$main::selected>������ $date_unblock</option>);
	}
	elsif($penalty{'block_time'}){
	$date_unblock = "$date_unblock{'yearf'}/$date_unblock{'monthf'}/$date_unblock{'dayf'}";
		$input_revety = qq(<option value="not_change"$main::selected>������ $date_unblock</option>);
	}
	else{
		$input_revety = qq(<option value=""$main::selected>�Ȃ�</option>);
	}

my $view_unblock = qq($d_unblock����) if($d_unblock);

	# part_delreason.pl ����A�������Ԃ̃p�^�[�����擾
	if($admy_rank >= $master_rank){ ($option_deny_select) = shift_jis(Mebius::Reason::get_select_denyperiod("")); }
	else{ ($option_deny_select) = shift_jis(Mebius::Reason::get_select_denyperiod("Limited")); }

# �������̑I���{�b�N�X
my $select_blocktime .= qq(<select name="block_time" style="background:#dee;">);
$select_blocktime .= qq($input_revety);
	if($admy_rank >= $master_rank){ $select_blocktime .= qq(<option value="forever">������</option>); }
$select_blocktime .= qq($option_deny_select);
$select_blocktime .= qq(</select><span style="color:#080;font-size:90%;">*��{1�T�ԁ`2�����قǁB</span>);

	# �����e�����̃R���g���[��
	if($admy_rank >= $leader_rank){

		# �Ǐ���
		my($allow_host_line,$exclusion_line,$user_agent_match_line,$block_report_line);

			# �A�h���X�������N
			if($in{'file'} =~ /^([0-9\.]+)(-MebiHost|\.mb2)(\.jp)?$/ && $admy_rank >= $master_rank){
				$okaddr_link = qq( <a href="$mainscript?mode=cda&amp;file=$1">��IP�A�h���X�̊Ǘ�</a> / );
			}

		# �ʐ����R���g���[��
		my($block_bbs_input);

		$block_bbs_input = qq(
		<div class="block_bbs">�ʐ����F <input type="text" name="block_bbs" value="$penalty{'block_bbs'}">
		<span class="guide">���T�C�g�S�̂̓��e�����Ƃ́h�ʂɁh�A�e�f���𐧌����܂��B���Ƃ��Ύ��R�f���Ɠ��L���e��𐧌�����ꍇ�́uztd nikki�v�Ɠ��͂��܂��B</span>
</div>); 

			# ISP�̏ꍇ�A�x��
			if($type =~ /Isp-view/){
				$input_block .= qq(<div style="color:#fff;padding:0.3em;background:#f00;text-align:center;"><strong>�� �� �c ISP�Ǘ��ł��I ( �L�� - $in{'file'} - �ɐ�����������܂� ) </strong></div>);
			}

		# ���e�����̉���`�F�b�N

		# �����`�F�b�N
		my $checked_block1 = $main::checked , my $class_block1 = qq( class="red bold") if($penalty{'block'} eq "1");
		my $checked_block2 = $main::checked , my $class_block2 = qq( class="red bold") if($penalty{'block'} eq "2");
		my $checked_block3 = $main::checked , my $class_block3 = qq( class="red bold") if($penalty{'block'} eq "3");
		my $checked_block0 = $main::checked , my $class_block0 = qq( class="blue") if($penalty{'block'} eq "" || $penalty{'block'} eq "0");

		# �z�X�g���̋���
		if($main::admy_rank >= $main::master_rank && $plustype_adevice =~ /Host|Isp|Second-domain/){
			my($checked_allow,$checked_allow_default);
				if($penalty{'allow_host_flag'}){ ($checked_allow) = $main::checked ; }
				else{ $checked_allow_default = $main::checked; }
			$allow_host_line .= qq(<div>\n);
			$allow_host_line .= qq(<input type="radio" name="allow_host" id="allow_host_none" value=""$checked_allow_default>\n);
			$allow_host_line .= qq(<label for="allow_host_none">���ݒ�</label>\n);
			$allow_host_line .= qq(<input type="radio" name="allow_host" id="allow_host" value="Allow"$checked_allow>\n);
			$allow_host_line .= qq(<label for="allow_host">.jp �h���C���ȊO�ł����e�ł���悤�� </label>\n);
			$allow_host_line .= qq(</div>\n);
		}

		# �e����s�{�^��
		$input_block .= qq(
		<div class="block">
		<div class="block_select">
		<strong>���e�����F</strong> 
		<input type="radio" name="block" value="0" id="block0"$checked_block0> <label for="block0"$class_block0>�Ȃ�(����)</label>
		<input type="radio" name="block" value="3" id="block3"$checked_block3> <label for="block3"$class_block3>�A�J�E���g�֘A</label>
		<input type="radio" name="block" value="1" id="block1"$checked_block1> <label for="block1"$class_block1>�S�R���e���c</label>);

			if($penalty{'block'} eq "1" || $penalty{'block'} eq "2" || $main::admy_rank >= $main::master_rank){
				$input_block .= qq(
				<input type="radio" name="block" value="2" id="block2"$checked_block2> <label for="block2"$class_block2>�S�R���e���c�i�����/�폜���܂ށj</label>
				);
			}

		# �������
		my($checked_exclusion_block,$class_exclusion_block);
			if($penalty{'exclusion_block'}){
				$checked_exclusion_block = $main::checked;
				$class_exclusion_block .= qq( blue bold);
		}

	$exclusion_line .= $html->input("checkbox","must_compare_xip_flag",1,{ checked => $penalty{'must_compare_xip_flag'} , text => "IP��K���Q�Ƃ���" });


		if($type !~ /Isp-view/){
			$exclusion_line .= qq(<input type="checkbox" name="exclusion_block" id="exclusion_block" value="1"$checked_exclusion_block> <label for="exclusion_block" class="$class_exclusion_block">���e�������������</label>);
		}



		# �A�J�E���g�쐬�̂ݐ���
		my($checked_block_make_account,$class_block_make_account);
			if($penalty{'concept'} =~ /Block-make-account/){
				$checked_block_make_account = $main::checked;
				$class_block_make_account .= qq( red bold);
			}
		$exclusion_line .= qq(<input type="checkbox" name="block_make_account" id="block_make_account" value="1"$checked_block_make_account> <label for="block_make_account" class="$class_block_make_account">�A�J�E���g�̍쐬�𐧌�</label>);

		my $checked_block_report = $parts->{'checked'} if $penalty{'block_report'};
		my $block_report_time = time + 3*24*60*60;
		$block_report_line .= qq(<label><input type="checkbox" name="block_report_time" value="$block_report_time">�ᔽ�񍐂����΂炭�֎~</label>);
			if(time < $penalty{'block_report_time'}){
				$block_report_line .= qq(<label><input type="checkbox" name="block_report_time" value="0">�ᔽ�񍐋֎~������</label>);
			}

		if($main::admy{'master_flag'}){
				$user_agent_match_line .= qq( UA�}�b�` <input type="text" name="user_agent_match_for_block_push" value=""> );
				$user_agent_match_line .= qq( <label>(<input type="checkbox" name="user_agent_match_for_block_delete" value="1">�폜)</label> (�ЂƂł��w�肵���ꍇ�AUA���}�b�`���Ȃ��ꍇ�͓��e��������܂���)�@);
		}

		$input_block .= qq(
		�@
		<select name="reason" style="background:#ff0;">$select</select>
		$select_blocktime
		</div>
		$block_bbs_input
		$user_agent_match_line
		$exclusion_line
		$block_report_line
		$allow_host_line
		<div>
		�@<input type="submit" value="���̓��e�Ŏ��s����">);

			# ���񂽂񓊍e����
			if($main::admy_rank >= $main::master_rank){
				$input_block .= qq(�@�@<input type="submit" name="3_month_block" value="3������ ���e����" style="background:#fcc;">);
			}


		$input_block .= qq(</div><span class="guide">$okaddr_link</div>);



	}


#		<input type="checkbox" name="redirect" value="1" id="other_server_same" checked>
#		<label for="other_server_same">���̃T�[�o�[�ł����l�ɐݒ�</label>

# �t�@�C�����ŃR�[�h
my $dec_file = $in{'file'};

# �\������
my $view_blocker = qq( ($penalty{'block_decide_man'}) ) if($penalty{'block_decide_man'});

# �f�[�^���e���`
# $lefttime ?
my $text .= qq(
<div class="penalty_data">
<table style="width:auto";>
<tr><td class="left">�y�i���e�B</td><td> <strong class="red">$left_penalty_date</strong> </td></tr>
<tr><td>�폜��</td><td><strong class="red">�ŋ� $penalty{'count'}�� / �S�� $penalty{'allcount'}��</strong></td></tr>
</table>
</div>
);

$text .= qq(<div class="block_data">);
$text .= qq(<table style="width:auto";>);
$text .= qq(<tr><td class="left">���e����</td>);
$text .= qq(<td><strong class="red">);
	if($penalty{'block'} eq "1"){ $text .= qq(�T�C�g�S��); }
	if($penalty{'block'} eq "2"){ $text .= qq(�T�C�g�S�́i���j); }
	if($penalty{'block'} eq "3"){ $text .= qq(�A�J�E���g); }
$text .= qq(</strong>);
	if($penalty{'block_count'}){ $text .= qq( \($penalty{'block_count'}���\)); }
$text .= qq(</td>);
$text .= qq(</tr>\n);

# ���[�J������
$text .= qq(<tr><td>�ʐ���</td>);
	if($penalty{'block_bbs'} && $penalty{'Flag'}->{'some_block'}){ $text .= qq(<td><strong class="red" style="background:#fff;padding:0.2em 0.3em;border:solid 1px #f00;">$penalty{'block_bbs'}</strong></td>); }
	else{ $text .= qq(<td>�Ȃ�</td>); }
$text .= qq(</tr>);


$text .= qq(<tr><td>�����̌����</td><td> <strong class="red">$action_date $view_blocker</strong></td></tr>);

$text .= qq(<tr><td>������</td><td><strong class="red">$date_unblock);
	if($view_unblock){ $text .= qq( \($view_unblock\) ); }
$text .= qq(</strong></td></tr>);

$text .= qq(<tr><td>�������R</td><td><strong class="red">$reason</strong></td></tr>);

$text .= qq(<tr><td>UA�}�b�`</td><td>);
	foreach(@{$penalty{'user_agent_match_for_block'}}){
		$text .= qq(<strong class="green">$_</strong> / );
	}
$text .= qq(</td></tr>);

	if($penalty{'block_report_time'} >= time){
		my($howlong) = shift_jis(Mebius::second_to_howlong($penalty{'block_report_time'} - time));
		$text .= qq(<tr><td>�ᔽ�񍐂̐���</td><td> <strong class="red">).e($howlong).qq(</strong></td></tr>);
	}

$text .= qq(</table></div>);

	# ���O��̍폜���e
	if($penalty{'index_line'}){
		my($deleted_hitory) = Mebius::Fixurl("Normal-to-admin",$penalty{'index_line'});
		$text .= qq(<div class="before_deleted"><h3>�폜����</h3>$deleted_hitory</div>);
	}


# �t�@�C�����Ȃ��ꍇ
if($penalty{'file_nothing_flag'}){ $text = qq(<div class="nodata">�Ǘ������͂���܂���B</div>); }

# �Z�[�u�f�[�^���擾
#my($savedata_line) = &get_savedata($in{'file'});
my($savedata_line);

	# �\���𒲐�
	if($in{'filetype'} eq "account"){
		# ���O�C���������擾
		require "${init_directory}part_idcheck.pl";
			($login_hisory_line) = Mebius::Login->login_history("Index Admin",$file);
	}

	# �����e�������擾
	($none,$none,$reshistory_line,undef,%history) = Mebius::history({ Type => "Admin INDEX Get-hash THREAD Open-view Not-renew-status" , FileTypeQuery => $in{'filetype'} },$in{'file'});


	# ���e�����̐��`
	if($history{'f'}){

		# �Ǐ���
		my($how_block_make_account,$first_time,$make_accounts_line,$form);

		# �Ǘ��p��URL���C��
		($reshistory_line) = Mebius::Adfix("Url",$reshistory_line);

		# �t�H�[��
		if($main::admy{'master_flag'}){
			$form .= qq(<form action="" method="post" style="margin:1em 0em;padding:0.5em 1em;background:#5d5;"><div>);
			$form .= qq(<input type="hidden" name="mode" value="cdl">);
			$form .= qq(<input type="hidden" name="type" value="control_all_res_from_history">);
			$form .= qq(<input type="hidden" name="filetype" value="$main::in{'filetype'}">);
			$form .= qq(<input type="hidden" name="file" value="$main::in{'file'}">);
			$form .= qq(<p>�{���F );
			$form .= qq(<label><input type="radio" name="comment_control_type" value="">���I��</label>);
			$form .= qq(<label><input type="radio" name="comment_control_type" value="delete">�폜</label>);
			$form .= qq(<label class="blue"><input type="radio" name="comment_control_type" value="revive">����</label>);
			$form .= qq(<label class="red"><input type="checkbox" name="penalty" value="1">�y�i���e�B</label>);
			$form .= qq(<p>�M���F );
			$form .= qq(<label><input type="radio" name="handle_control_type" value="">���I��</label>);
			$form .= qq(<label><input type="radio" name="handle_control_type" value="delete">�폜</label>);
			$form .= qq(<label class="blue"><input type="radio" name="handle_control_type" value="revive">����</label>);
			$form .= qq(<p><input type="submit" value="���̓��e�����̂��ׂẴ��X�𑀍�">);
			$form .= qq(</div></form>);
		}

			# �A�J�E���g�쐬�\����
			if($history{'make_account_blocktime'}){
				($how_block_make_account) = Mebius::SplitTime(undef,$history{'make_account_blocktime'} - $main::time);
				$how_block_make_account = qq( �� ����̃A�J�E���g�쐬��\�\\���ԁF $how_block_make_account \($history{'make_account_blocktime'}\) );
			}

			my($how_before_renew_status) = Mebius::SplitTime(undef,$main::time - $history{'last_renew_status_time'});
			$how_before_renew_status = qq( �� �O��̏󋵍X�V�F $how_before_renew_status);

			# �A�J�E���g�쐬����
			if($history{'make_accounts'}){
					foreach(split/\s/,$history{'make_accounts'}){
						$make_accounts_line .= qq(<a href="${main::auth_url}$_/">$_</a>);
					}
					$make_accounts_line = qq( �� �쐬�A�J�E���g $make_accounts_line);
			}

		my(%first_time) = Mebius::Getdate("Get-hash",$history{'firsttime'});

		# ���L�^����
		my($first_date) = Mebius::Getdate(undef,$history{'first_time'}) if($history{'first_time'});
		$reshistory_line = qq(<div class="reshistory"><h2 id="HISTORY" style="display:inline;">���e����</h2>)
		. qq( <strong>( $first_date �L�^�J�n )</strong><br>$reshistory_line <div>���L�^�F $first_date $make_accounts_line $how_block_make_account $how_before_renew_status</div></div>);

		# ���e��������̍폜�t�H�[��
		$reshistory_line .= qq($form);

		# �폜�����N�I��
		require Mebius::Reason;
	#	my($reason_select_line) = shift_jis(Mebius::Reason::res_control_box_full_set({},$main::in{'comment_control'}));
	#	$reshistory_line .= qq(<form action="">);
	#	$reshistory_line .= qq(<input type="hidden" name="mode" value="$main::mode"$main::xclose>);
	#	$reshistory_line .= qq(<input type="hidden" name="file" value="$main::in{'file'}"$main::xclose>);
	#	$reshistory_line .= qq(<input type="hidden" name="filetype" value="$main::in{'filetype'}"$main::xclose>);
	#	$reshistory_line .= qq($main::backurl_input);
	#	$reshistory_line .= qq(<div>$reason_select_line</div>);
	#	$reshistory_line .= qq(<input type="submit" value="�u���e�񐔁v�̃����N��Ɉړ��������̍폜���R��I��"$main::xclose>);
	#	$reshistory_line .= qq(</form>);
	}

$other_history_line .= &histories_return_cdl_admin("Cookie-history",$history{'cnumbers'},$file);
$other_history_line .= &histories_return_cdl_admin("Host-history",$history{'hosts'},$file);
$other_history_line .= &histories_return_cdl_admin("Account-history",$history{'accounts'},$file);
	if($main::admy_rank >= $main::master_rank){
		$other_history_line .= &histories_return_cdl_admin("Agent-history",$history{'agents'},$file);
	}

# �M���L�^�̃g���b�v���\���ɂ���
my($handles);
	foreach(split(/\s/,$history{'names'})){
		my($name_decoded) = Mebius::Decode(undef,$_);
		my($handle,$trip_material) = split(/#/,$name_decoded);
		$handles .= qq( $handle);
	}
$other_history_line .= histories_return_cdl_admin("Handle-history",$handles,$file);

	# �M��
	if($history{'names'}){
		$other_history_line .= qq(�@���M�� �F );
		foreach my $foreach (split(/\s/,$history{'names'})){
			my($file_decoded) = Mebius::Decode(undef,$foreach);
			my($handle2) = split(/#/,$file_decoded);
			$other_history_line .= qq( $handle2);
		}
	}

	# ID
	if($history{'encids'}){
		$other_history_line .= qq(�@��ID �F );
		foreach my $foreach (split(/\s/,$history{'encids'})){
			my($file_encoded) = Mebius::Encode(undef,$foreach);
			if($foreach eq $file){ $other_history_line .= qq( ��$foreach); }
			else{ $other_history_line .= qq(<i>��$foreach</i>); }
		}
	}

	# �S�̂̕\�����`
	if($other_history_line){
		$other_history_line = qq(<div class="other_history">$other_history_line</div>);
	}

	# DOS����t�@�C�����擾
	if($in{'filetype'} =~ /^(addr|host)$/ && $main::admy_rank >= $main::master_rank){

		# DOS����t�@�C���Q����擾
		my(%dos_flow) = Mebius::Dos::FlowFile("Get-hash Get-alert",$file);
		my(%dos) = Mebius::Dos::AccessFile("Get-hash",$dos_flow{'addr'});

			# DOS����t�@�C�������݂���ꍇ
			if($dos_flow{'f'}){
				$dos_line .= qq(<h2>DOS����</h2>);
				$dos_line .= qq(<div style="background:ddd;margin:1em 0em;padding:0.5em;">);
				$dos_line .= qq(DOS����F $dos{'dos_count'}<br$main::xclose>);
				$dos_line .= qq(Dos-Key: [ $dos{'key'} ]<br$main::xclose>);
				$dos_line .= qq(<input type="checkbox" name="dos_file_delete" value="1" id="dos_file_delete">\n);
				$dos_line .= qq(<label for="dos_file_delete">DOS�t�@�C�����폜</label><br$main::xclose>\n);

				$dos_line .= qq(<input type="hidden" name="dos_host_or_addr" value="$file">\n);
				$dos_line .= qq(<input type="hidden" name="dos_addr" value="$dos_flow{'addr'}">\n);
				#$dos_line .= qq(Alert $dos{'dos_alert_flag'} CGI-Error $dos{'dos_flow_flag'} \n);
				$dos_line .= qq(\n);
				$dos_line .= qq(<pre style="word-wrap:break-word;">$dos_flow{'access_log'}</pre>\n);
				$dos_line .= qq(\n);
				$dos_line .= qq(</div>);
			}
	}

	# Who is �t���[��
	if($main::in{'filetype'} eq "addr"){
		$whois_line = qq(<h2 id="WHOIS">Who is ���</h2><div><iframe src="http://whois.nic.ad.jp/cgi-bin/whois_gw?type=&key=$main::in{'file'}&lang=" style="width:80%;height:400px;" frameborder="0"></iframe></div>);
	}


my($allreset_button);
if($admy_rank >= $master_rank){ $allreset_button = qq(<input type="submit" value="���̃����o�[�́u���ׂĂ̍폜�񐔁v���Ȃ���" name="allreset"$disabled_reset>); }

	# �A�J�E���g�ւ̃����N
	if($main::in{'filetype'} eq "account"){
		$account_link = qq(<div>�A�J�E���g�F <a href="${main::auth_url}$main::in{'file'}/">$main::in{'file'}</a></div>);
	}

# HTML
my $print .= qq(<a href="$home">�s�n�o�ɖ߂�</a>);
# $print .= qq($back_bbs $back_page);
$print .= qq(
<h1>�Ǘ��ԍ� <span class="red">$dec_file</span> <span style="color:#080;">( $plustype_adevice )</span> - $server_domain $account_link</h1>
<form action="" method="post">
<div style="line-height:1.4em">
$input_block
$domain_links
$other_history_line
$text
<br><span style="color:#f00;font-size:90%;">�����X�̐������Ԃ́A���̃����o�[�����ɓ��e�����^�C�~���O�ŉ��Z����܂��B</span><br>
<span style="color:#f00;font-size:90%;">���Ԉ���ăy�i���e�B��^���Ă��܂����Ƃ��Ȃǂɂ́A���̃{�^���������Ă��������B</span><br><br>
<input type="submit" value="���̃����o�[�́u�҂����ԁv�u�ŋ߂̍폜�񐔁v���Ȃ���" name="reset"$disabled_reset>
$allreset_button
<input type="hidden" name="change" value="1">
<input type="hidden" name="mode" value="cdl">);

$print .= qq(<input type="hidden" name="adfile" value=") . Escape::HTML([$admy_file]) . qq(">\n);
$print .= qq(<input type="hidden" name="filetype" value=") . Escape::HTML([$main::in{'filetype'}]) . qq(">\n);
$print .= qq(<input type="hidden" name="file" value=") . Escape::HTML([$main::in{'file'}]) . qq(">\n);
#$print .= qq(<input type="hidden" name="referer" value=") . &Escape::HTML([$referer_link]) . qq(">\n);

	# �폜�񐔂̕ύX
	if($main::admy{'master_flag'}){
		$print .= qq(<br><br>�ŋ߂̍폜�񐔁F <input type="text" name="count" value=") . Escape::HTML([$penalty{'count'}]) . qq(">);
		$print .= qq(<br>���ׂĂ̍폜�񐔁F <input type="text" name="allcount" value=") . Escape::HTML([$penalty{'allcount'}]) . qq(">);
		$print .= qq(<br> <input type="submit" name="count_change" value="�w��̉񐔂ɂ���">);
	}


$print .= qq(
</div>
</form>

$savedata_line
$reshistory_line
<h2>�A�N�Z�X����</h2>
$login_hisory_line
$dos_line
$whois_line
);

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# ���e��������S�Ẵ��X���폜����
#-----------------------------------------------------------
sub control_all_res_from_history{

# �錾
my($use) = @_;
my($history,$line,$res_control_reason,$comment_control_type,$handle_control_type,$penalty_flag);
my $move = new Mebius::Move;
our($del_text,$admy_name);

# �A�N�Z�X����
main::axscheck("Post-only");

# �����`�F�b�N
	if(!$main::admy{'master_flag'}){ main::error("����������܂���B"); }

# ��`
my $query = \%main::in;
my $query_escaped = \%main::in;

	# �폜���R
	if($query->{'delete_reason'}){
		$res_control_reason = $query->{'control_reason'};
	}

	# ���s�^�C�v ( �{���̑��� )
	if($query->{'comment_control_type'} =~ /^(delete|revive)$/){
		$comment_control_type = $1;
	}

	# ���s�^�C�v (�M���̑��� )
	if($query->{'handle_control_type'} =~ /^(delete|revive)$/){
		$handle_control_type = $1;
	}

	# �y�i���e�B
	if($query->{'penalty'}){
		$penalty_flag = 1;
	}

# ���e��������f�[�^���擾
my($history) = Mebius::history({ Type => "GetAllThreadAndRes GetReference" , FileTypeQuery => $query_escaped->{'filetype'} },$query_escaped->{'file'});

	# ���e�����̑S�f���� ��W�J
	foreach my $bbs_name ( keys %{$history->{'AllRegist'}} ){

			# �S�L����W�J
			foreach my $thread_number ( keys %{$history->{'AllRegist'}{$bbs_name}} ){

				# �Ǐ���
				my(%res_control,@res_numbers);

					# �S���X��W�J
					foreach my $res_number ( keys %{$history->{'AllRegist'}{$bbs_name}{$thread_number}} ){

						$res_control{$res_number}{'comment'}{'reason'} = $res_control_reason;
						$res_control{$res_number}{'comment'}{'type'} = $comment_control_type;
						$res_control{$res_number}{'handle'}{'type'} = $handle_control_type;
						$res_control{$res_number}{'penalty_flag'} = $penalty_flag;
						push(@res_numbers,$res_number);
					}
					
				# �S���X�𑀍� ( �폜�╜�������s )
				my($control_successed_flag) = Mebius::Admin::thread_control_core({ control => \%res_control , MyDeletedMessage => $del_text , MyHandle => $admy_name },$bbs_name,$thread_number);
				my $res_numbers_join = join "-" , @res_numbers;
					if($control_successed_flag){
						$line .= qq( $bbs_name - $thread_number - $res_numbers_join �𑀍�(�폜�╜��)���܂����B<br>);
					}
					else{
						$line .= qq( $bbs_name - $thread_number - $res_numbers_join �͑��삵�܂���ł����B<br>);
					}
			}
	}

$move->redirect_to_self_url();
exit;

main::error("$line");
#main::error("$history->{'first_time'}");
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub histories_return_cdl_admin{

# �錾
my($type,$histories,$file) = @_;
my($line,$foreach,$plustype_get_history,$filetype);
my $query = new CGI;

	# ���^�[��
	if(!$histories){ return(); }

	# Cookie�̏ꍇ
	if($type =~ /Cookie-history/){
		$line .= qq(�N�b�L�[ �F );
		$plustype_get_history .= qq( CNUMBER);
		$filetype = "number";
	}
	elsif($type =~ /Host-history/){
		$line .= qq(�@�� �z�X�g �F );
		$plustype_get_history .= qq( HOST);
		$filetype = "host";
	}
	elsif($type =~ /Agent-history/){
		$line .= qq(�@�� UA �F );
		$plustype_get_history .= qq( KACCESS_ONE);
		$filetype = "agent";
	}
	elsif($type =~ /Handle-history/){
		$line .= qq(�@�� �M�� �F );
		$plustype_get_history .= qq( HANDLE);
		$filetype = "handle";
	}
	elsif($type =~ /Account-history/){
		$line .= qq(�@�� �A�J�E���g �F );
		$plustype_get_history .= qq( ACCOUNT);
		$filetype = "account";
	}

	# �W�J
	foreach $foreach (split(/\s/,$histories)){

		# �Ǐ���
		my($file_encoded,%history2);

			# UA�̏ꍇ�́A�ŏ�����G���R�[�h����Ă���
			if($type =~ /Agent-history/){
				$file_encoded = $foreach;
				($foreach) = Mebius::Decode(undef,$foreach);
					if($query->param('view_detail')){
						(%history2) = &get_reshistory("Admin KACCESS_ONE Get-hash-detail",$foreach);
					}
			}

			# �M��
			elsif($type =~ /Handle-history/){
				$file_encoded = $foreach;
					if($query->param('view_detail')){
						(%history2) = &get_reshistory("Admin Get-hash-detail $plustype_get_history",$foreach);
					}
				($foreach) = Mebius::Decode(undef,$foreach);
			}

			# UA�ȊO�̏ꍇ
			else{
				($file_encoded) = Mebius::Encode(undef,$foreach);
					if($query->param('view_detail')){
						(%history2) = &get_reshistory("Admin Get-hash-detail $plustype_get_history",$foreach);
					}
			}

			# �z�X�g���Í�������ꍇ ( ���[�_�[�ȉ� )
			if($type =~ /Host-history/ && $main::admy_rank < $main::master_rank){
				my($file_crypted) = Mebius::Crypt::crypt_text("MD5",$foreach,"Dl");
				$line .= qq( <span class="red">$file_crypted</span>);
			}
			elsif($foreach eq $file){ $line .= qq( $foreach); }
			# �����N��\��
			else{
				$line .= qq( <a href="${main::main_url}?mode=cdl&amp;file=$file_encoded&amp;filetype=$filetype" class="manage">$foreach);
					if($history2{'other_counts'}){ $line .= qq(($history2{'other_counts'})); }
				$line .= qq(</a> );
			}
	}

return($line);

}

no strict;

use CGI;

#-----------------------------------------------------------
# ���e�����A���X�������Ԃ̑���
#-----------------------------------------------------------
sub change{

# �Ǐ���
my($basic_init) = Mebius::basic_init();
my($type,$plustype_penalty) = @_;
my($top,$line,@d_invite,%renew);
my($my_admin) = Mebius::my_admin();
my($param) = Mebius::query_single_param();
my $query = new CGI;

	# �����`�F�b�N
	if($in{'reason'} =~ /\D/){ main::error("�w�肪�ςł��B"); }
	if($in{'block_time'} =~ /[^\w\-]/){ main::error("�w�肪�ςł��B"); }
	if($in{'count'} =~ /[^\d\-]/){ main::error("�w�肪�ςł��B"); }
	if($in{'allcount'} =~ /[^\d\-]/){ main::error("�w�肪�ςł��B"); }

	# �����t�@�C�����擾
	my(%penalty) = Mebius::penalty_file("Get-hash $plustype_penalty",$main::in{'file'});

	# �R���Z�v�g�L�[
	$renew{'concept'} = $penalty{'concept'};

	# �폜�J�E���g�ƃy�i���e�B���Ԃ̃��Z�b�g
	if($in{'reset'}){
		$renew{'count'} = 0;
		$renew{'penalty_time'} = 0;
	}

	# �폜�J�E���g�ƑS�폜�J�E���g�ƃy�i���e�B���Ԃ̃��Z�b�g
	if($in{'allreset'} && $my_admin->{'master_flag'}){
		$renew{'count'} = 0;
		$renew{'allcount'} = 0;
		$renew{'penalty_time'} = 0;
	}

	# �����e��������������
	if($in{'block'} eq "0" && $my_admin->{'leader_flag'}){
		$renew{'block_time'} = undef;
		$renew{'block'} = 0;
		$redirect = 1;
	}

	# �����e������������
	if(($in{'block'} || $in{'block_bbs'}) && $my_admin->{'leader_flag'}){

		# �Ǐ���
		my($blocktime);

			# �e��G���[
			if(!$in{'reason'}){ main::error("�������R��I��ł��������B"); }
			if($in{'block'} !~ /^\d$/){ main::error("�����^�C�v��I��ł��������B"); }

			# �����f�[�^
			$renew{'block'} = $in{'block'};
			$renew{'block_decide_man'} = $main::admy_name;
			$renew{'block_reason'} = $in{'reason'};

				# ������
				if($in{'block_time'} eq "forever"){ $renew{'block_time'} = ""; }
				elsif($in{'block_time'} eq "not_change"){ $renew{'block_time'} = $penalty{'block_time'}; }
				elsif($in{'block_time'} =~ /^([0-9]+)$/){ $renew{'block_time'} = $in{'block_time'}; }
				else{ main::error("���������w�肵�Ă��������B"); }

		$redirect = 1;
	}

	# �� �ᔽ�񍐂̋֎~
	if($param->{'block_report_time'} =~ /^[0-9]+$/){
			$renew{'block_report_time'} = $param->{'block_report_time'};
			$redirect = 1;
	}

	# ���񂽂񓊍e����
	if($my_admin->{'leader_flag'}){


			if($main::in{'3_month_block'}){

				$renew{'block_time'} = time + (90*24*60*60);
				$renew{'block'} = 1;
				$renew{'block_reason'} = 7;
				$renew{'block_decide_man'} = $main::admy_name;

			}

		$redirect = 1;

	}


	# �V���������̏ꍇ�́A��������/�����񐔃J�E���g��ύX����
	if($renew{'block'} && !$penalty{'block_time_flag'}){
		$renew{'block_decide_time'} = $main::time;
		$renew{'+'}{'block_count'} = 1;
	}


	# �z�X�g���̋���
	if($my_admin->{'master_flag'} && exists $main::in{'allow_host'}){
		$renew{'allow_host'} = $main::in{'allow_host'};
	}

	# ���ʌf���̐���
	if($my_admin->{'leader_flag'}){
		$in{'block_bbs'} =~ s/�@/ /g;
			if($in{'block_bbs'} =~ /([^a-zA-Z0-9 ])/){ &error("�ʐ����̗��Ɏg���Ȃ������񂪎g���Ă��܂��B"); }
		$renew{'block_bbs'} = $in{'block_bbs'};
		$redirect = 1;
	}

	# ���e�����̉��
	if($my_admin->{'leader_flag'}){
			if($in{'exclusion_block'}){ $renew{'exclusion_block'} = "1"; }
			else{ $renew{'exclusion_block'} = ""; }
			if($in{'must_compare_xip_flag'}){ $renew{'must_compare_xip_flag'} = "1"; }
			else{ $renew{'must_compare_xip_flag'} = ""; }
	}



	# �A�J�E���g�쐬�̐���
	if($my_admin->{'leader_flag'}){

		$renew{'concept'} =~ s/(\s)?Block-make-account//g;
			if($in{'block_make_account'}){ $renew{'concept'} .= qq( Block-make-account); }
	}


	# �폜�񐔂��A�w��̉񐔂ɕύX
	if($in{'count_change'}){
		$count = $in{'count'};
		$allcount = $in{'allcount'};
		$redirect = 0;
	}

	# UA�}�b�`
	if($in{'user_agent_match_for_block_delete'}){
		$renew{'user_agent_match_for_block'} = [];
	}
	elsif(exists $in{'user_agent_match_for_block_push'}){
		$renew{'push'}{'user_agent_match_for_block'} = $in{'user_agent_match_for_block_push'};
	}

	# Debug
	if(Mebius::alocal_judge() && 1 == 0){

		#$renew{'push:user_agent_match_for_block'} = ["FireFox","Chrome"];
		$renew{'user_agent_match_for_block'} = [1,2,3];
		$renew{'push'}{'user_agent_match_for_block'} = "b";
		$renew{'unshift'}{'user_agent_match_for_block'} = "a";

		#$renew{'shift'}{'user_agent_match_for_block'} = 2;
		#$renew{'pop'}{'user_agent_match_for_block'} = 2;

		#$renew{'user_agent_match_for_block'}{'push'} = "d";
		$renew{'.'}{'concept'} = " ABC";
		$renew{'s/g'}{'concept'} = " ABC";
		$renew{'count'} = "13";

		#$renew{'+'}{'concept'} = "ABC";

		#$renew{'s///g'}{'concept'} = "ABC";
	
		#$renew{'push:user_agent_match_for_block'} = "IE";
		$renew{'unshift'}{'user_agent_match_for_block'} = "Chrome\n";
		$renew{'user_agent_match_for_block'}[4] = "Yes\n";
		#$renew{'user_agent_match_for_block'}[0] = "";
	}


	# �t�@�C�����X�V

	Mebius::penalty_file("Renew-hash $plustype_penalty Test",$main::in{'file'},%renew);

	# DOS�t�@�C���̍폜
	if($my_admin->{'master_flag'} && $main::in{'dos_file_delete'}){

			# DOS����t�@�C�����擾
			if($in{'filetype'} =~ /^(addr|host)$/){

				# DOS�֘A�t�@�C�����폜
				Mebius::Dos::FlowFile("Delete-file",$main::in{'dos_host_or_addr'});
				Mebius::Dos::AccessFile("Delete-file",$main::in{'dos_addr'});
				Mebius::Dos::HtaccessFile("Delete-addr Renew",$main::in{'dos_addr'});

			}

	}

	# ���_�C���N�g��̃h���C��
	my($domain);
	if($server_domain eq "aurasoul.mb2.jp"){ $domain = "mb2.jp"; }
	else{ $domain = "aurasoul.mb2.jp"; }

# �t�@�C�����G���R�[�h
my($file_encoded) = Mebius::Encode(undef,$in{'file'});

	# ���̃T�[�o�[�փ��_�C���N�g(�P)
	#if($redirect && $in{'redirect'} && !$in{'redirected'} && !Mebius::alocal_judge()){
	#	Mebius::Redirect("","$basic_init->{'admin_http'}://$domain/jak/$script?$postbuf&redirected=1");
	#}
	# ���T�[�o�[�ւ̃��_�C���N�g
	#else{
	#		if(Mebius::alocal_judge()){
	#			Mebius::Redirect("","$script?mode=cdl&file=$file_encoded&filetype=$in{'filetype'}&referer=$encref_link"); 
	#		}
	#		else{
	#	Mebius::Redirect("","$basic_init->{'admin_http'}://$domain/jak/$script?mode=cdl&file=$file_encoded&filetype=$in{'filetype'}&referer=$encref_link");
	#		}
	#}

Mebius::redirect("$script?mode=cdl&file=$file_encoded&filetype=$in{'filetype'}&referer=$encref_link");
exit;

}

#-----------------------------------------------------------
# �Z�[�u�f�[�^�̓��e���擾�A�ύX
#-----------------------------------------------------------
sub get_savedata{

# �Ǐ���
my($init_directory) = Mebius::BaseInitDirectory();
my($line,$type,$flag);

# ���^�[��
if($admy_rank < $leader_rank){ return; }

# �t�@�C����`
my($file) = @_;
$file =~ s/\.\.//g;
$file =~ s/^([\/]+)//g;

	# �A�J�E���g�̏ꍇ
	if($file =~ /^([0-9a-z]+)$/ && $in{'filetype'} =~ /ACCOUNT/i){
		$file = $file;
		$type = "ACCOUNT";
		$k_access = "";
		$flag = 1;
	}

	# �g�ђ[���̏ꍇ
	my($adevice_type,$select_dir,$k_access,$kaccess_one) = &adevice("",$file);
	if($adevice_type eq "kaccess_one"){
		$file = $kaccess_one;
		$type = "MOBILE";
		$k_access = $k_access;
		$flag = 1;
	}

# ���^�[��
if(!$flag){ return; }


# �Z�[�u�f�[�^����荞��
require "${init_directory}part_idcheck.pl";

my($top,$nam,$gold,$soutoukou,$soumoji,$email,$follow,$up,$pre,$color,$old,$posted,$news,$fontsize,$cut,$secret,$account,$pass) = Mebius::save_data($file,$type,$k_access);
my($handle) = split(/#/,$nam);


# �t�@�C�����Ȃ��ꍇ
if($top eq ""){ return; }

# HTML
$line = qq(
<form action="$mainscript">
<div class="savedata">
�Z�[�u�f�[�^ ( $type ) �F<br><br>
<input type="hidden" name="mode" value="cdl">
<input type="hidden" name="file" value="$in{'file'}">
<input type="hidden" name="filetype" value="$type">
<input type="hidden" name="type" value="push_savedata">
�M���F $handle<br>
���݁F <input type="text" name="gold" value="$gold"><br>
���e�񐔁F <input type="text" name="soutoukou" value="$soutoukou"><br>
���������F <input type="text" name="soumoji" value="$soumoji"><br>
);

# �ڂ����f�[�^
if($admy_rank >= $master_rank){ $line .= qq(<br>$top<br><br>); }

	# �A�J�E���g�ւ̃����N
	if($type eq "ACCOUNT"){
		$line .= qq(�A�J�E���g�F <a href="${auth_url}$file/">$file</a><br>);
	}
	if($type eq "MOBILE" && $account){
		$line .= qq(�A�J�E���g�F <a href="${auth_url}$account/">$account</a> <a href="$mainscript?mode=cdl&amp;file=$account&amp;filetype=account">�f�[�^</a><br>);
	}

$line .= qq(
<input type="submit" value="���̓��e�ŕύX����">
</form></div>);


	# ���e�̕ύX����
	if($in{'type'} eq "push_savedata"){
		$gold = $in{'gold'};
		$soutoukou = $in{'soutoukou'};
		$soumoji = $in{'soumoji'};
		$gold =~ s/[^0-9\-]//g;
		$soutoukou =~ s/\D//g;
		$soumoji =~ s/\D//g;
		my($file_encoded) = Mebius::Encode(undef,$in{'file'});
	&push_savedata($file,$type,$k_access,$nam,$posted,$pwd,$color,$up,$pre,$new_time,$res_time,$gold,$soumoji,$soutoukou,$fontsize,$follow,$view,$number,$rireki,$cut,$memo_time,$account,$pass,$delres,$news,$old,$email,$secret);
		Mebius::Redirect("","$mainscript?mode=cdl&file=$file_encoded&filetype=$type");
	}

# ���^�[��
return($line);

}


#�� IP�A�h���X�̊Ǘ�-----------------------------------------------------------


#-----------------------------------------------------------
# ���[�h�U�蕪���ƃt�@�C����`
#-----------------------------------------------------------
sub start_admin_control_ip{


# �Ǐ���
my($file,$top,$none_flag,$line);

# ���[�h�G���[
if($admy_rank < $master_rank){ &error("�ݒ茠��������܂���B"); }

# �t�@�C����`
$file = $in{'file'};
$file =~ s/-MebiHost//g;
#$file =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
#$file =~ tr/ /+/;
if($file eq ""){ &error("�\\���ł��܂���B"); }

# ���[�h�U�蕪��
if($in{'type'} eq "edit"){ admin_control_ip_change($file); }
else{ admin_control_ip_view(); }

# �����I��
exit;

}

#-----------------------------------------------------------
# �\�����
#-----------------------------------------------------------

sub admin_control_ip_view{

# �Ǐ���
my($invited_flag,$how_before_gethostbyaddr);

# CSS��`
$css_text .= qq(
table,th,tr,td{border-style:none;}
table{width:60%;margin-top:0.5em;padding:1em;}
h1{line-height:1.3;}
td{padding:0.3em 0.2em;}
li{line-height:1.6;}
div.before_deleted{background-color:#ff9;padding:1em;margin:1em 0em;}
div.nodata{margin:1em 0em;padding:1em;background-color:#ccc;}
table.datas{background-color:#cee;}
td.left{width:20em;}
th{display:none;}
.domain_links{color:#080;font-size:140%;margin:1em 0em;font-style:oblique;}
.block{padding:0em 1.0em;}
);

# �{������
if(!$main::admy{'master_flag'}){ main::error("�{������������܂���B"); }

# �f�[�^���Ȃ��ꍇ
my($addr) = Mebius::Host::select_addr_data_from_main_table($in{'file'});
#my($addr) = Mebius::AddrFile(undef,$in{'file'});

#if(!$addr->{'f'}){ $none_flag = 1; }

# �߂胊���N
$referer_link = $referer;
if($in{'referer'}){ $referer_link = $in{'referer'}; }

$encref_link = $referer_link;
$encref_link =~ s/&amp;/&/g;
$encref_link =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
$encref_link =~ tr/ /+/;

	if($addr->{'allow_flag'} eq "0"){
		$css_text .= qq(
		table.datas{background-color:#fdd;}
		);
	}

# �h���C���؂�ւ������N
{ my($i);
foreach(@domains){
$i++;
if($i >= 2){ $domain_links .= qq( - ); }
if($_ eq $server_domain){ $domain_links .= qq( $_ ); }
else{ $domain_links .= qq( <a href="http://$_/jak/index.cgi?mode=cda&amp;file=$file&amp;referer=$encref_link">$_</a> ); }
}
$domain_links = qq(<div class="domain_links">�h���C���F $domain_links</div>);
}

# �����N���`
my $baseurl = "http://mb2.jp/jak/" if(!$alocal_mode);

$input_block = qq(
<div class="block">
<input type="submit" name="unblock" value="������">
<input type="submit" name="block" value="���ۂ���">
<input type="checkbox" name="redirect" value="1" checked> ���_�C���N�g�i ���̃T�[�o�[�ł����l�ɐݒ� �j
</div>
);


# �t�@�C�����ŃR�[�h
my $dec_file = $in{'file'};

# �߂�惊���N
my $referer_bbs = $referer_link;
$referer_bbs =~ s/\?(.+)//g;
my $back_bbs = qq(<a href="$referer_bbs">�R���e���c�s�n�o��</a>) if($referer_link);
my $back_page = qq(<a href="$referer_link">���y�[�W�ɖ߂�</a>) if($referer_link);

	# �O��� Who is �擾���t
	if($addr->{'last_get_whois_time'}){
		($get_whois_date) = Mebius::get_date($addr->{'last_get_whois_time'});
		($how_before_get_whois) = Mebius::SplitTime("Get-top-unit Plus-text-�O",time - $addr->{'last_get_whois_time'});
	}
	# �O��� gethostbyaddr
	if($addr->{'last_gethostbyaddr_time'}){
		($gethostbyaddr_date) = Mebius::get_date($addr->{'last_gethostbyaddr_time'});
		($how_before_gethostbyaddr) = Mebius::SplitTime("Get-top-unit Plus-text-�O",time - $addr->{'last_gethostbyaddr_time'});
	}


# �t����
my($gethostbyaddr_realtime) = Mebius::GetHostByAddr({ Addr => $main::in{'file'} });

# �t�����ƋL�^�����s
#Mebius::GetHostSelect({ TypeWithFile = 1 , Addr => $main::in{'file'});

# �f�[�^���e���`
my $text = qq(
<table class="datas">
<tr><th>����</th><th>���l</th></tr>
<tr><td class="left">�蓮����</td><td>$addr->{'allow_key'}</td></tr>
<tr><td class="left">�O��� Who is �擾</td><td>$how_before_get_whois ( $get_whois_date->{'date_till_minute'} )</td></tr>
<tr><td class="left">�O��� �t����</td><td>$how_before_gethostbyaddr ( $gethostbyaddr_date->{'date_till_minute'} )</td></tr>
<tr><td class="left">�L�^���ꂽ REMOTE_HOST ( gethostbyaddr )</td><td>$addr->{'gethostbyaddr'}</td></tr>
<tr><td class="left">�L�^���ꂽ gethostbyname</td><td>$addr->{'gethostbyname'}</td></tr>
<tr><td class="left">���݂� REMOTE_HOST ( gethostbyaddr )</td><td>$gethostbyaddr_realtime</td></tr>
</table>
);

# �t�@�C�����Ȃ��ꍇ
if($none_flag){ $text = qq(<div class="nodata">�Ǘ������͂���܂���B</div>); }



# HTML
my $print = <<"EOM";
<a href="$home">�s�n�o�ɖ߂�</a>
$back_bbs
$back_page

<h1>IP�A�h���X�Ǘ� <span class="red">$dec_file</span> - $server_domain</h1>

<form action="$script" method="POST">
<div style="line-height:1.4em">
$input_block
$domain_links
$text
<input type="hidden" name="type" value="edit">
<input type="hidden" name="mode" value="cda">
<input type="hidden" name="file" value="$in{'file'}">
<input type="hidden" name="referer" value="$referer_link">
</div>
</form>

<br><br>
<a href="http://whois.nic.ad.jp/cgi-bin/whois_gw?type=&key=$in{'file'}&lang=">Whois</a>
EOM

Mebius::Template::gzip_and_print_all({},$print);

#<iframe src="http://whois.nic.ad.jp/cgi-bin/whois_gw?type=&key=$in{'file'}&lang=" style="width:80%;height:400px;" frameborder="0"></iframe>

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub admin_control_ip_change{

# �t�@�C����`
my($basic_init) = Mebius::basic_init();
my($file) = @_;
my($top,$line,$newkey,%renew);

# �L�[��`
if($in{'block'}){ $renew{'allow_key'} = 0; }
if($in{'unblock'}){ $renew{'allow_key'} = 1; }


$renew{'addr'} = $file;

# �t�@�C���X�V
#Mebius::AddrFile({ TypeRenew => 1 },$main::in{'file'},\%renew);
Mebius::Host::update_or_insert_main_table(\%renew);

# ���_�C���N�g��̃h���C��
my($domain);
if($server_domain eq "aurasoul.mb2.jp"){ $domain = "mb2.jp"; }
else{ $domain = "aurasoul.mb2.jp"; }

# ���̃T�[�o�[�փ��_�C���N�g
my($file_encoded) = Mebius::Encode(undef,$in{'file'});
#if($in{'redirect'} && !$in{'redirected'} && !Mebius::alocal_judge()){
#Mebius::Redirect("","$basic_init->{'admin_http'}://$domain/jak/$script?$postbuf&redirected=1");
#}
#else{
	if(Mebius::alocal_judge()){ Mebius::Redirect("","$script?mode=cda&file=$file_encoded"); }
	else{ Mebius::Redirect("","$basic_init->{'admin_http'}://$domain/jak/$script?mode=cda&file=$file_encoded"); }
#}

}


#-----------------------------------------------------------
# �L���C��
#-----------------------------------------------------------

sub edit_log{

local($myjob) = @_;

# �����`�F�b�N
$in{'res'}  =~ s/\D//g;
$in{'no'} =~ s/\D//g;

# �����^�C�v
if($in{'job'} eq "edit2") { &edit_action; }
else{ &editform; }

exit;

}

use strict;


#-----------------------------------------------------------
# �C�����s
#-----------------------------------------------------------
sub edit_action{

# �Ǐ���
my($before_comment,$after_comment,@new,@index);
our(%in,$i_nam,$pass,$i_nam,$nowfile,$postflag,$admy_rank,$leader_rank);
our($script,$admin_flag,$master_rank,$realmoto,$moto);

	# �����`�F�b�N(�X���b�h�C��)
	if($admy_rank < $leader_rank){ &error("���s����������܂���B"); }
	if($in{'res'} && $admy_rank < $master_rank){ &error("���s����������܂���B"); }

# �e��G���[
if(!$postflag){ &error("GET���M�͏o���܂���B"); }

	# �p�X���[�h�`�F�b�N�Ȃ�
	#if ($in{'pass'} ne "") {
	#	$admin_flag=1;
	#		if ($in{'pass'} ne $pass) { &error("�p�X���[�h���Ⴂ�܂�"); }
	#}
	#elsif ($in{'pwd'} ne "") { $admin_flag = 0; }
	#else{ &error("�s���ȃA�N�Z�X�ł�"); }

	# �^�O�I���̏ꍇ
	if($in{'tag'}){
		($in{'comment'}) = Mebius::Descape("Not-br Deny-diamond",$in{'comment'});
		Mebius::DangerTag("Error-view",$in{'comment'});
	}
	else{
		$in{'comment'} =~ s/&amp;/&/g;
	}

# URL���`
($in{'comment'}) = Mebius::Fixurl("Admin-to-normal",$in{'comment'});

# ���b�N�J�n
&lock($moto);

# �L�����J��
my(%renew_thread,%res_edit);
	if($in{'res'} eq "" || $in{'res'} eq "0") { $renew_thread{'sub'} = $in{'sub'}; }
$res_edit{$in{'res'}}{'comment'} = $in{'comment'};
$res_edit{$in{'res'}}{'handle'} = $in{'name'};
my($thread_renewed) = Mebius::BBS::thread({ ReturnRef => 1 , FileCheckError => 1 , Renew => 1 , select_renew => \%renew_thread , res_edit => \%res_edit },$realmoto,$in{'no'});


# �ŏI���e�Җ�
#my($last_nam) = (split(/<>/, $new[$#new]))[2];
#if($res2 == 0 && !$in{'res'}) { $last_nam = $i_nam; }

# �C���f�b�N�X��W�J
#if(!$in{'res'}){
#open(IN,"$nowfile") || &error("�C���f�b�N�X���J���܂���B");
#my $top2 = <IN>;
#push(@index,$top2);
#	while (<IN>) {
#		chomp;
#		my($no,$sub,$res,$nam,$da,$na2,$key2) = split(/<>/);
#			if($in{'no'} == $no) {
#				if($last_nam){ ($na2) = ($last_nam); }
#					if(!$in{'res'}){ ($sub,$nam) = ($in{'sub'},$in{'name'}); }
#			}
#		push(@index,"$no<>$sub<>$res<>$nam<>$da<>$na2<>$key2<>\n");
#	}
#close(IN);
#}

	# �C���f�b�N�X�X�V
	#if(!$in{'res'}){
	#	Mebius::Fileout(undef,$nowfile,@index);
	#}

# ���b�N����
&unlock($moto);

# ���_�C���N�g
if($in{'res'}){ Mebius::Redirect("","$script?mode=view&no=$in{'no'}#S$in{'res'}"); }
else{ Mebius::Redirect("","$script?mode=view&no=$in{'no'}"); }

exit;
}

no strict;

#-----------------------------------------------------------
# �ҏW�t�H�[����\��
#-----------------------------------------------------------
sub editform{

# �Y�����O�`�F�b�N
$flag=0;

our($realmoto,%in);

if($in{'res'} < 0){ main::error("���X�Ԃ̎w�肪�ςł��B"); }

my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , GetAllLine => 1 },$realmoto,$in{'no'});

my($num,$sub,$res2,$key) = split(/<>/, $thread->{'all_line'}->[0]);
my($no,$resnum,$nam,$eml,$com,$dat,$hos,$pw,$url,$mvw) = split(/<>/,$thread->{'all_line'}->[$in{'res'}+1]);


# �e�L�X�g�G���A���`
$nam =~ s/"/&quot;/g;
$nam =~ s/</&lt;/g;
$nam =~ s/>/&gt;/g;

$sub =~ s/"/&quot;/g;
$sub =~ s/</&lt;/g;
$sub =~ s/>/&gt;/g;

my $textarea = $com;
$textarea =~ s/<br>/\n/g;
($textarea) = Mebius::escape("Not-br",$textarea);

my $print .= qq(
<a href="javascript:history.back()">�O�̉�ʂɖ߂�</a>
<h1>$sub > $in{'res'} �̏C��</h1>
<form action="$script" method="post" name="myFORM">
<input type="hidden" name="mode" value="edit_log">
<input type="hidden" name="moto" value="$in{'moto'}">
<input type="hidden" name="job" value="edit2">
<input type="hidden" name="no" value="$in{'no'}">
<input type="hidden" name="res" value="$in{'res'}">
<input type="hidden" name="pass" value="$in{'pass'}">
<table>
);

if($in{'res'} eq "" || $in{'res'} eq "0"){
$print .= qq(
<tr><td>�薼</td>
<td><input type="text" name="sub" size="80" value="$sub"></td>
</tr>
);
}

$print .= qq(
<tr><td>�M��</td>
<td><input type="text" name="name" size="80" value="$nam"></td></tr>
</tr>
);

$print .= qq(
<tr><td>�{��</td>
<td><textarea name="comment" cols="71" rows="20" style="width:100%;height:400px;">$textarea</textarea></td></tr>
<tr><td><br></td><td><input type="submit" value="���̓��e�ŕύX����">
<input type="checkbox" name="tag" value="1" id="tag_on" checked><label for="tag_on">�^�O</label>
</td>
</tr></table>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

}

no strict;

#���ʖ�-----------------------------------------------------------

#-----------------------------------------------------------
# �ʖ�
#-----------------------------------------------------------

sub do_allregistcheck{
Mebius::Echeck::Start("",%in);
}

# �� �� bas_adindex.cgi �̃��[�h�U���� -----------------------------------------------------------


#-----------------------------------------------------------
# ���[�h�U�蕪��
#-----------------------------------------------------------
sub script_start_admin_index{

#require 'jcode.pl';

$script = "index.cgi";
$mode = $in{'mode'};

	#if($submode1 eq "pallet"){ require "${int_dir}main_pallet.pl"; Mebius::Pallet::Start(); }
	#els
	#if($mode eq "echeck"){ require "admin_echeck.cgi"; }
	if($mode eq "cdl"){ admin_cdl(); }
	elsif($mode eq "make_password"){ require Mebius::Admin::Password; Mebius::Admin::Password::make_password_form_for_admin(); }
	elsif($mode eq "bbs_status"){ require Mebius::BBS::Status; $bbs_status = new Mebius::BBS::Status; $bbs_status->junction(); }
	elsif($mode eq "cda"){ start_admin_control_ip(); }
	#elsif($mode eq "vlogined"){ require "admin_vlogined.cgi"; }
	elsif($mode eq "vadhistory"){ view_admin_login_histor(); }
	#elsif($mode eq "member"){ require "admin_member.pl"; &do_member; }
	elsif($mode eq "mydata"){ admin_mydata(); }
	#elsif($submode1 eq "past"){ require "${int_dir}part_pastindex.pl"; Mebius::BBS::PastIndexView("All-BBS-view Admin-mode"); }
	elsif($submode1 eq "allregistcheck"){ &do_allregistcheck(@_); }
	elsif($mode eq "" || $mode eq "index" ){ require "${main::int_dir}admin_index.pl"; }
	# �ʏ탂�[�h�Ƃ̋��ʏ���
	else {

		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}bas_main.pl";
		start_main();
	}

exit;

}

# �� URL�ϊ��t�H�[��-----------------------------------------------------------


sub admin_url_change_form{

$title="�t�q�k�ϊ�/�Ǘ����[�h";

$admin_bas_url = 'http://mb2.jp/jak/index.cgi';

$title="�t�q�k�ϊ�/�Ǘ����[�h";

&url_hyouji();

}

#-------------------------------------------------
# �t�q�k�\��
#-------------------------------------------------

sub url_hyouji {

my($basic_init) = Mebius::basic_init();

my $print .= <<"EOM";
<a href="$home">�s�n�o�y�[�W</a>
<a href="javascript:history.go(-1)">�O�̉�ʂ�</a>
<a href="$kannriroom_url">�Ǘ����[��</a>
<a href="$base_url">��ʃ��r�E�X�����O</a><br><br>

��ʂ̂t�q�k����A�Ǘ����[�h�̂t�q�k�֕ϊ����܂��B<br>
�t�q�k�i�܂��͂t�q�k���܂܂ꂽ�e�L�X�g�j����͂��A�u���̓��e�ŕϊ�����v�������ĉ������B<br>
�����N�́u�r�g�h�e�s�{�N���b�N�v�ŕʑ��ŊJ�����Ƃ��o���܂��B<br><br>
EOM

# �`�F�b�N
my($delete_checked,$guard);
if($in{'delete_checked'} eq "heavy"){ $delete_checked = qq(&amp;delete_checked=heavy); }
if($in{'delete_checked'} eq "light"){ $delete_checked = qq(&amp;delete_checked=light); }
if($in{'delete_checked'} eq "lock"){ $delete_checked = qq(&amp;delete_checked=lock); }
if($in{'guard'} eq "0"){ $guard = qq(&amp;guard=0); }
if($in{'reason'}){ $reason = qq(&amp;reason=$in{'reason'}); }


if($in{'comment'}){

$url_submit="$in{'comment'}";

print"<hr>�ϊ���̂t�q�k<br>";

foreach(split(/<br>/, $url_submit)) {


$_ =~ s/�P/1/g;
$_ =~ s/�Q/2/g;
$_ =~ s/�R/3/g;
$_ =~ s/�S/4/g;
$_ =~ s/�T/5/g;
$_ =~ s/�U/6/g;
$_ =~ s/�V/7/g;
$_ =~ s/�W/8/g;
$_ =~ s/�X/9/g;
$_ =~ s/�O/0/g;
$_ =~ s/no\./,/ig;

$_ =~ s/�C/,/g;
$_ =~ s/�A/,/g;

# �����ȂǏ���
$_ =~ s/#a//g;


$_ =~ s/_([0-9a-z]+)_([0-9a-z]+)\//_$1\//g;
$_ =~ s/_([0-9a-z]+)\/k/_$1\//g;
$_ =~ s/_([0-9a-z]+)\/m([0-9]+)\.html/$1.cgi?p=$2/g;

# �e���X
$_ =~ s/_([0-9a-z]+)\/([0-9]+)\.html-([a-z0-9_\-]+)/jak\/$1.cgi?mode=view&amp;no=$2&amp;No=$3#RES/g;

# �ʋL��
$_ =~ s/_([0-9a-z]+)\/([0-9]+)\.html/jak\/$1.cgi?mode=view&no=$2/g;
$_ =~ s/_([0-9a-z]+)\/([0-9]+)_([0-9]+)\.html/jak\/$1.cgi?mode=view&no=$2&r=$3#S$3/g;

$_ =~ s/\/_([0-9a-z]+)\//\/$1\.cgi/g;

$_ =~ s/http(\:\/\/[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%\,]+)/<a href=\"$basic_init->{'admin_http'}$1$delete_checked$guard$reason\">$basic_init->{'admin_http'}$1$delete_checked$guard$reason<\/a>/g;

print"$_<br>";

}
print"<hr>";


}

# �폜���R���擾
require "${int_dir}part_delreason.pl";
my($reason_selects) = Mebius::Reason::get_select_reason("$in{'reason'}","");

# ���M�{�^��
my $submit = qq(
<input type="submit" value="���̓��e�ŕϊ�����"> �������́F 
<input type="radio" name="delete_checked" value="heavy" id="delete_soon"> <label for="delete_soon">�����폜</label>
<input type="radio" name="delete_checked" value="light" id="delete_after"> <label for="delete_after">���Ƃō폜</label>
<input type="radio" name="delete_checked" value="lock" id="delete_lock"> <label for="delete_lock">���b�N</label>
<input type="checkbox" name="guard" value="0" id="delete_nogurard"> <label for="delete_nogurard">�폜�K�[�h�Ȃ�</label>

<select name="reason">
<option value="">�폜���R
$reason_selects
</select>
);

$in{'comment'} =~ s/<br>/\r/g;



$print .= <<"EOM";
<form action="$script" method="post">
<input type="hidden" name="mode" value="url">
$submit
<br>
<textarea cols="71" rows="20" name="comment" class="infrm" accesskey="3">$in{'comment'}</textarea>
<br>

</form>
EOM


$print .= <<"EOM";
<hr>
���T�C�g�������ŋ֑����e�𔭌��@���@�t�q�k�ϊ��@���@�Ǘ�����<br><br>

���̃t�H�[���i�f���������������j�ɃL�[���[�h�i�r�炵���[�h�Ȃǁj�����Č������A<br>
�������ʂ̃y�[�W���ۂ��ƃR�s�[���y�[�X�g���āA�ϊ����Ă��������B<br><br>

<form method=get action="http://www.google.co.jp/search" target="_blank">
<table bgcolor="#FFFFFF"><tr valign=top><td>
<a href="http://www.google.co.jp/">
<img src="http://www.google.com/logos/Logo_40wht.gif" 
border="0" alt="Google" align="absmiddle"></a>
</td>
<td>
<input type=text name=q size=31 maxlength=255 value="">
<input type=hidden name=ie value=Shift_JIS>
<input type=hidden name=oe value=Shift_JIS>
<input type=hidden name=hl value="ja">
<input type=submit name=btnG value="Google ����">
<font size=-1>
<input type=hidden name=domains value="YOURSITE.CO.JP"><br>
<input type=radio name=sitesearch value=""> WWW ������ 
<input type=radio name=sitesearch value="mb2.jp" checked> ���r�E�X�����O ������
</font>
</td></tr></table>
</form>
</center>
<!-- SiteSearch Google -->

�E�f���������������ɂ́A�o�^����Ă��Ȃ��y�[�W���������݂��܂��B<br>
�E�����y�[�W�̍X�V��Ԃ̓��A���^�C���ł͂���܂���B�i�P�T�Ԉȏ�O�̂��̂������ł��j<br>
�E������́u�����I�v�V�����v�Łu�P�O�O������\�\\���v�Ȃǂ�I�ԂƁA�g���₷���Ǝv���܂��B<br><br>



<!-- Begin Yahoo Search Form -->
<div style="margin:0;padding:0;font-size:14pt;border:none;background-color:#FFF;">
<form action="http://search.yahoo.co.jp/search" method="get" target="_blank" style="margin:0;padding:0;">
<p style="margin:0;padding:0;"><a href="http://search.yahoo.co.jp/" target="_blank"><img src="http://i.yimg.jp/images/search/guide/searchbox/ysearch_logo_110_22.gif" alt="Yahoo!����" style="border:none;vertical-align:middle;padding:0;border:0;"></a><input type="text" name="p" size="28" style="margin:0 3px;width:50%;"><input type="hidden" name="fr" value="yssw" style="display:none;"><input type="hidden" name="ei" value="Shift_JIS" style="display:none;"><input type="submit" value="����" style="margin:0;"></p>
<ul style="margin:2px 0 0 0;padding:0;font-size:10pt;list-style:none;">
<li style="display:inline;"><input name="vs" type="radio" value="">�E�F�u�S�̂�����</li>
<li style="display:inline;"><input name="vs" type="radio" value="mb2.jp" checked>���̃T�C�g��������</li>
</ul>
</form>
</div>
<!-- End Yahoo! Search Form -->
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

# �� �f���S�̂̓��� -----------------------------------------------------------

	
#-------------------------------------------------
#  �t�H�[���f�R�[�h
#-------------------------------------------------
sub start_script_bbs_admin {

require Mebius::BBS;
&init_start_bbs("Admin-mode");

	# ���T�[�o�[���烊�_�C���N�g
	my($server_domain) = Mebius::server_domain();
	if($server_domain eq "aurasoul.mb2.jp"){
		Mebius::redirect("https://mb2.jp$ENV{'REQUEST_URI'}");
	}

# �e���v���[�g��荞��
my($init_directory) = Mebius::BaseInitDirectory();

require "${init_directory}part_template_call.pl";
($res_template) .= &get_calltemplate();


#���[�h�ؑ�
if($mode eq "form") { require "${init_directory}part_newform.pl"; bbs_last_newform(); }
elsif($mode eq "find"||$mode eq "kfind") { bbs_find_thread_admin(); }
elsif($mode eq "view" || $mode eq "vf") {

if($in{'r'} eq "data"){ require "${init_directory}part_data.pl"; &bbs_view_data(); }
elsif($in{'r'} eq "memo"){ require "${init_directory}part_memo.pl"; &bbs_memo("Admin-mode"); }
else{ &ad_view(); }
}
elsif($mode eq "past") { bbs_view_past_threads_admin(); }
elsif($mode eq "enter_disp") { &enter_disp(); }
elsif($mode eq "logoff") { &logoff(); }
#elsif($mode eq "settei") { require'part_adsettei.cgi'; &part_settei(); }
#elsif($mode eq "findkey") { require'admin_findkey.cgi'; }
elsif($mode eq "rule") { &part_rule(); }
#elsif($mode eq "hint"){ require'admin_hint.cgi'; &admin_hint();  }
#elsif($mode eq "msg"){ require'admin_msg.cgi'; &admin_msg(); }
elsif($mode eq "url"){ admin_url_change_form();  }
#elsif($mode eq "autotext"){ require'admin_autotext.cgi'; }
#elsif($mode eq "cord"){ require'admin_cord.pl' }
#elsif($mode eq "keycheck"){ require 'admin_keycheck.cgi'; }
#elsif($mode eq "Nojump"){ require 'admin_resjump.pl'; }
elsif($mode eq "init"){ junction_bbs_special_init_file(); }
#elsif($mode eq "member"){ require "admin_member.pl"; }
elsif($mode eq "memo"){ require "${init_directory}part_memo.pl"; &bbs_memo("Admin-mode"); }
elsif($submode1 eq "past"){ require "${init_directory}part_pastindex.pl"; Mebius::BBS::PastIndexView("Select-BBS-view Admin-mode"); }

	# �Ǘ�����
	elsif($mode eq "admin"){
			#if($in{'pass'} eq "") { &enter(); }
			#elsif ($in{'pass'} ne $pass) { &error("�F�؃G���[�ł��B"); }
		#require "bas_adm.pl";
		&ad_settei();
		&admin();
	}
	# ���e����
	elsif($mode eq "regist"){
		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}part_regist.pl";
		bbs_regist();
		#require "admin_regist.pl";
		#&admin_regist();
	}
	# �L�����X�C��
	elsif($mode eq "edit_log"){
		#require "admin_edit.pl";
		&edit_log(@_);
	}
	# �L���\�[�X�C��
	#elsif($mode eq "edit_source"){
	#	require "admin_source.pl";
	#	&change_source();
	#}
	# �I�[�g�����N�{��
	#elsif($mode eq "autolink_view"){
	#	require "admin_regist.pl";
	#	&autolink_view();
	#}
	# �ݒ�t�@�C���̕ύX
	elsif($mode eq "init_edit"){
		use Mebius::Admin::InitEdit;
		Mebius::Admin::InitEdit::Start();
	}

admin_indexview();

exit;

}


#-------------------------------------------------
# �L���{��
#-------------------------------------------------
sub ad_view { my($init_directory) = Mebius::BaseInitDirectory(); require "${init_directory}part_view.pl"; bbs_view_thread(); }

#-------------------------------------------------
#  ���O�I�t
#-------------------------------------------------
sub logoff {

my($admin_basic_init) = Mebius::Admin::basic_init();

	unlink("$admin_basic_init->{'sesdir'}/$admy_session.cgi");

	print "Set-Cookie: $ENV{'SERVER_ADDR'}=; path=/; \n";
	&enter_disp();

}



#-------------------------------------------------
# URL�G���R�[�h
#-------------------------------------------------
sub url_enc {
local($_) = @_;

s/(\W)/'%' . unpack('H2', $1)/eg;
s/\s/+/g;
$_;
}

#-------------------------------------------------
# �ߋ����O�{��
#-------------------------------------------------
sub bbs_view_past_threads_admin {
local($i,$no,$sub,$res,$name,$date,$na2);

my($basic_init) = Mebius::basic_init();
# �L���{��
if ($in{'no'}) { &ad_view("past"); }

my $print .= <<"EOM";
<div align="center">

<div class="div6"><br>

<a href="#go" class="title">$title �ߋ����O�i�Ǘ����[�h�j</a>
<span class="size0"><br><br></span>
$my_name�i$my_rank�j
$setumei<br><br>
<span class="size4">
<a href="$home" accesskey="0">�s�n�o�y�[�W</a>&nbsp;
<a href="$script?mode=form" accesskey="1">�V�K���e</a>&nbsp;
<a href="$basic_init->{'admin_report_bbs_url'}">�폜�˗��f����</a>&nbsp;
<a href="$script?mode=find" accesskey="2">�L������</a>&nbsp;
<a href="$script?mode=logoff">���O�I�t</a>
</span></div>

<form class="forma" action="$script" method="POST">
<input type=hidden name=mode value="find">
<input type=hidden name=op value="AND">
<input type=hidden name=log value="0">
<input type=hidden name=s value="1">
<input type=hidden name=n value="1">
<input type=hidden name=saishuu value="1">
<input type=hidden name=vw value="100">
<input type=text name=word size=38 value=""><input type=submit value="����"></form>
EOM

# �y�[�W�ړ��{�^���\��

$i=0;
open(IN,"$pastfile") || &error("$pastfile���J���܂���");
while (<IN>) { $i++; }

$print .= <<"EOM";
<table summary="�y�[�W�ړ�"><tr><td class="page">
<a href="$script" class="size3">���s���O</a>
EOM

if ($main::in{'p'} - $menu2 >= 0 || $main::in{'p'} + $menu2 < $i) {
local($x,$y) = (1,0);

while ($i > 0) {

if ($main::in{'p'} == $y) { $print .= "<b class=\"pink\">$x</b>\n"; }
else { $print .= "<a href=\"$script?mode=past&amp;p=$y\">$x</a>\n"; }
$x++;
$y += $menu2;
$i -= $menu2;
}
}

$print .= "</td></tr></table><br>\n";

$print .= <<"EOM";
<table cellpadding="3" summary="�L���ꗗ"><tr><td class="td0">No</td><td class="td1">
�薼</td><td class="td2">���O</td><td class="td3">�ŏI</td><td class="td4">�ԐM</td></tr>
EOM

# �X���b�h�W�J
$i=0;
if ($main::in{'p'} eq "") { $p=0; }
open(IN,"$pastfile") || &error("$pastfile���J���܂���");
while (<IN>) {
$i++;
next if ($i < $main::in{'p'} + 1);
next if ($i > $main::in{'p'} + $menu2);

($no,$sub,$res,$name,$date,$na2) = split(/<>/);

$print .= "<tr><td>$i</td><td>
<a href=\"$script?mode=view&amp;no=$no\">$sub</a></td><td>$name</td><td>$na2</td><td>$res��</td></tr>\n";

}
close(IN);

$print .= <<"EOM";
</table><br>
<table summary="�y�[�W�ړ�"><tr><td class="page">
<a href="$script" class="size3">���s���O</a>
EOM

# �y�[�W�ړ��{�^���\��
if ($main::in{'p'} - $menu2 >= 0 || $main::in{'p'} + $menu2 < $i) {
local($x,$y) = (1,0);

while ($i > 0) {
$print .= "<a href=\"$script?mode=past&amp;p=$y\">$x</a>\n";
$x++;
$y += $menu2;
$i -= $menu2;
}}

$print .= "</td></tr></table><br>$hyouji</div>\n";

Mebius::Template::gzip_and_print_all({},$print);

exit;
}

#-------------------------------------------------
# �L������
#-------------------------------------------------
sub bbs_find_thread_admin {
local($no,$sub,$res,$nam,$date,$na2,$key,$target,
$alarm,$next,$back,$enwd,@log1,@log2,@log3,@wd);

# �����I�v�V�����f�[�^�������Ă����
if(!$op){$op = "AND";}
if(!$vw){$vw = 100;}
if(!$s){$s = 1;}
if(!$n){$n = 1;}
if(!$saishuu){$saishuu = 1;}

# �t�q�k�p�ɃG���R�[�h
$enwd = &url_enc($in{'word'});

my $print .= <<"EOM";

<a href="$home">�s�n�o�y�[�W</a>
<a href="$script">�f���s�n�o</a><br><br>

<strong>�L������</strong><br><br>

<form action="$script" method="GET">
<input type=hidden name=mode value="find">
�L�[���[�h <input type=text name=word size=38 value="$in{'word'}"><input type=submit value="����">&nbsp;

EOM


if ($in{'log'} eq "") { $in{'log'} = 0; }
@log1 = ($nowfile, $pastfile);
@log2 = ("���s���O", "�ߋ�");
@log3 = ("view", "past");
foreach (0,1) {
if ($in{'log'} == $_) {
$print .= "<input type=radio name=log value=\"$_\" checked>$log2[$_]";
} else {
$print .= "<input type=radio name=log value=\"$_\">$log2[$_]";
}
}

$print .= <<"EOM";
</form>

EOM

# ���ʂ̌f������t�q�k�����p�����Ƃ��́A������[

if($in{'s'} eq ""){$in{'s'}=1;}
if($in{'n'} eq ""){$in{'n'}=1;}
if($in{'saishuu'} eq ""){$in{'saishuu'}=1;}
if($in{'vw'} eq ""){$in{'vw'}=100;}

#�������s
if ($in{'word'} && ($in{'s'} || $in{'n'}||$in{'saishuu'})) {

$print .= <<EOM;
<table cellpadding="3" summary="�L���ꗗ"><tr><td class="td0">No</td><td class="td1">
EOM


$print .= <<EOM;
�薼</td><td class="td2">���O</td><td class="td3">�ŏI</td><td class="td4">�ԐM</td></tr>
EOM

$in{'word'} =~ s/\x81\x40/ /g;
@wd = split(/\s+/, $in{'word'});

$i=0;
open(IN,"$log1[$in{'log'}]") || &error("$log1[$in{'log'}]���J���܂���");
$top = <IN> if (!$in{'log'});
while (<IN>) {
$target='';
($no,$sub,$res,$nam,$date,$na2,$key) = split(/<>/);
$target .= $sub if ($in{'s'});
$target .= $nam if ($in{'n'});
$target .= $na2 if ($in{'saishuu'});
$flag=0;
foreach $wd (@wd) {
if (index($target,$wd) >= 0) {
$flag=1;
if ($in{'op'} eq 'OR') { last; }
} else {
if ($in{'op'} eq 'AND') { $flag=0; last; }
}
}
if ($flag) {
$i++;
if ($i < $main::in{'p'} + 1) { next; }
if ($i > $main::in{'p'} + $in{'vw'}) { next; }


$print .= "<tr><td>$i</td><td>";


		if ($key eq "0") {
			$print .= "[<span style=\"color:#FF0000;\">���b�N</span>] ";
		} elsif ($key == 2) {
			$print .= "[<span style=\"color:#FF0000;\">�Ǘ���</span>] ";
		}



$print .= "<a href=\"$script?mode=$log3[$in{'log'}]&amp;no=$no\">$sub</a></td><td>$nam</td><td>$na2</td><td>$res��</td></tr>\n";
}
}
close(IN);

$print .= "</table>\n";

$print .= "<br>[��������&nbsp;$i��]&nbsp;&nbsp;";

$next = $main::in{'p'} + $in{'vw'};
$back = $main::in{'p'} - $in{'vw'};
$enwd = &url_enc($in{'word'});

$print .= "
<input type=\"hidden\" name=\"find_back\" value=\"$script?mode=find&amp;p=0&amp;word=$enwd&amp;vw=$in{'vw'}&amp;op=$in{'op'}&amp;log=$in{'log'}&amp;s=$in{'s'}&amp;n=$in{'n'}\">
";

if ($back >= 0) {
$print .= "<a href=\"$script?mode=find&amp;p=$back&amp;word=$enwd&amp;vw=$in{'vw'}&amp;op=$in{'op'}&amp;log=$in{'log'}&amp;s=$in{'s'}&amp;n=$in{'n'}\">�O��$in{'vw'}��</a>\n";
}
if ($next < $i) {
$print .= "<a href=\"$script?mode=find&amp;p=$next&amp;word=$enwd&amp;vw=$in{'vw'}&amp;op=$in{'op'}&amp;log=$in{'log'}&amp;s=$in{'s'}&amp;n=$in{'n'}\">����$in{'vw'}��</a>\n";
}


}

Mebius::Template::gzip_and_print_all({},$print);

exit;
}

#-------------------------------------------------------------------------------------
# �^�C�g���C��
#-------------------------------------------------------------------------------------

sub part_rule{

	if($main::admy{'master_flag'}){
		Mebius::Redirect(undef,"${main::jak_url}$main::moto.cgi?mode=init_edit#RULE");
	}


my $print .= "<strong><a href=\"$script\">$title</a>�̃��[��</strong><br><br>";

$rule_text =~ s/[\n]/<br>/g;

$print .= "$rule_text";

Mebius::Template::gzip_and_print_all({},$print);

exit;

}




#-------------------------------------------------
# �󏈗�
#-------------------------------------------------
sub ad_text{}


# �� bas_adbase.cgi �ɂ��������� -----------------------------------------------------------

use File::Basename;

#-------------------------------------------------
# �t�H�[���f�R�[�h
#-------------------------------------------------
sub before_start{

my($admin_basic_init) = Mebius::Admin::basic_init();
my($param) = Mebius::query_single_param();

# �Ǘ��t���O�𗧂Ă�
Mebius::Admin::ridge_admin_flag();

	# �����[�g���[�U�[���w�肳��Ă��Ȃ��ꍇ�̓G���[��
	if(!Mebius::alocal_judge() && $ENV{'REMOTE_USER'} eq "" && $ENV{'REDIRECT_REMOTE_USER'}){ main::error("���Ï؂��������Ă��܂���B"); }

	# SSL�łȂ��ꍇ�̓G���[��
#	if(!Mebius::alocal_judge() && $ENV{'SERVER_PORT'} ne "443"){ main::error("SSL�ŃA�N�Z�X���Ă��������B"); }

my($basic_init) = Mebius::basic_init();

$master_rank = $admin_basic_init->{'master_rank'};
$leader_rank = $admin_basic_init->{'leaders_rank'};

# �X�N���v�g��
my $bbs_object = Mebius::BBS->new();
($moto) = $bbs_object->root_bbs_kind();
($realmoto) = $bbs_object->true_bbs_kind();
	if($realmoto){
		$script = "$realmoto.cgi";
	} else {
		$script = basename($ENV{'SCRIPT_NAME'});	
	}

# �߂菈���Ɏg�����M�{�^���̒l
$backurl_submitvalue = "��";

# �y�[�W�̕\��
$pfirst_page = 50;

# �Ǘ����[�h
$admin_mode = 1;
$mainscript = "index.cgi";
$main_url = "${jak_url}index.cgi";

# ��{�p�X���[�h
$guide_id = "GiiuSper";
$guide_pass = "dk5hasgf";

#�Ǘ���`�F�b�N
	if($alocal_mode){ $home = "index.cgi"; }
	else{ $home = "https://mb2.jp/jak/index.cgi"; }

$after_folder_adm = ".";
$rand_check_adm_n = 100;

# �e��t�q�k
$guide_url_base = $guide_url;
$bas_domein='mb2.jp';
$base_url = "$basic_init->{'admin_http'}://mb2.jp/";
$kannriroom_url="$basic_init->{'admin_http'}://mb2.jp/jak/fjs.cgi";
$adroom_url = "$basic_init->{'admin_http'}://mb2.jp/jak/fjs.cgi?mode=view&amp;no=54&amp;jump=newres";
$adroom_link = qq(<a href="$basic_init->{'admin_http'}://mb2.jp/jak/fjs.cgi">�Ǘ����[��</a> \(<a href="$basic_init->{'admin_http'}://mb2.jp/jak/fjs.cgi?mode=view&amp;no=54#NEW_RES">��</a>\));
$adroom_link .= qq( <a href="https://mb2.jp/jak/index.cgi?mode=report_view">�ᔽ��</a> );
$adroom_link_utf8 = utf8_return($adroom_link);

$admin_url = "/jak/";
#$jak_url = "/jak/";
$cdl_url = "${admin_url}index.cgi?mode=cdl&amp;file=";

# �Ǘ������̍ő�ۑ���
$adfile_max = 1000;

# �e��ݒ�
$no_par = 1;
$p_page = 100;

$memfile = 'mem1.cgi';
$memfile2 = 'mem2.cgi';

$copydir = 'copy';

$adtext = '';

$url = 'bbs';

$site_url = 'http://mb2.jp/';

#$hyouji = <<"EOM";
#<a href="${base_url}jak/fjs.cgi?mode=url">�t�q�k�ϊ�</a>��<a href="${base_url}wiki/guid/%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">�֑�</a>��<a href="${base_url}wiki/guid/?action=LIST">�K�C�h�ꗗ</a>��<a href="$basic_init->{'admin_report_bbs_url'}">�폜�˗���</a>��<a href="index.cgi?mode=vlogined">���O�C������</a>��<a href="$main_url?mode=cdl">�Ǘ��ԍ�</a>��$adroom_link
#EOM

$pass = '5klGs94a';
$pass2 = '5klGs94a';

$trip_key = 'x6';

# �A�����e�̋֎~���ԁi�b�j
$wait = 0;

# �R�����g���͕������i�S�p���Z�j
$max_msg = 50000;

$admin_css = "/jak/admin.css";
if($alocal_mode){ $admin_css = "/style/admin.css"; }

# �Ǘ���{�t�@�C���A�T�[�o�[�h���C���Ȃǂ��擾
#require "admin.ini";
#&admin_init_option();

# �}�X�^�[���[�h
my $adaddr = $ENV{'REMOTE_ADDR'};
$host = $ENV{'REMOTE_HOST'};

	# �z�X�g����
	if (($host eq "" || $host eq "$addr")) { $host = gethostbyaddr(pack("C4", split(/\./, $adaddr)), 2); }
	# if(length($host) < 6){ main::error("���O�C���o���܂���B"); }

	# �N�b�L�[�擾
	($cnam,$ceml,$cpwd,$curl,$cmvw,$csort,$delce,$csnslink) = get_cookie_admin();

# �֐���`
$i_sub = $in{'sub'};
$i_com = $in{'comment'};

# �Ǘ��҂̃��O�C���`�F�b�N
logincheck_admin();

# �A�N�Z�X���L�^
Mebius::Admin::AccessDataCheck("New-access Renew",$admy_file,$host,$main::agent);

# �߂��
&backurl("NOREFERER","$in{'backurl'}");

			# �N�G��������ꍇ�A���_�C���N�g
			if($main::mode eq "login" && $main::postflag && $in{'mode'} ne "logoff"){
				Mebius::redirect_to_back_url();
			#		if($main::in{'query'} && $main::in{'query'} !~ /logoff/){
			#			my $query = $main::in{'query'};
			#			$query =~ s/&amp;/&/g;
			#			Mebius::Redirect("","$main::script?$query");
			#		}
			#		else{ 
			#			Mebius::Redirect("","$main::script");
			#		}
			}

}


use strict;
package Mebius::Admin;

#-----------------------------------------------------------
# �S�ẴA�N�Z�X�������`�F�b�N ( �z�X�g���ɏd�����Ȃ��ꍇ�ɁA�V�����s���L�^ )
#-----------------------------------------------------------
sub AccessDataCheck{

# �錾
my($type,$user_name,$host,$agent) = @_;
my($file_handler,$i,%top,@renew_line,$still_host_flag,$not_renew_flag);
my($file);

my($init_directory) = Mebius::BaseInitDirectory();

	# �t�@�C����`
$file = "${init_directory}_admin/_log_admin/member_access.log";

# �A�N�Z�X�����擾
my($access) = Mebius::my_access();

# �t�@�C�����J��
open($file_handler,"<",$file);

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($top{'key'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# ���E���h�J�E���^
		$i++;
		
			# �G�X�P�[�v
			if($i >= 50){ next; }

		# ���̍s�𕪉�
		chomp;
		my($key2,$user_name2,$host2,$time2,$date2,$agent2) = split(/<>/);

			# ���Ƀ��[�U�[�G�[�W�F���g���L�^����Ă���ꍇ
			if($agent eq $agent2 && $access->{'mobile_flag'}){
				$still_host_flag = 1;
			}

			# ���Ƀz�X�g�����L�^����Ă���ꍇ
			if($host eq $host2 && !$access->{'mobile_flag'}){
				$still_host_flag = 1;
			}

			# �s��ǉ�
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$user_name2<>$host2<>$time2<>$date2<>$agent2<>\n");
			}

	}

close($file_handler);

	# �V�����A�N�Z�X
	if($type =~ /New-access/){
			# ���Ƀz�X�g�����L�^����Ă���ꍇ
			if($still_host_flag){
				$not_renew_flag = 1;
			}
			# ���߂ċL�^����z�X�g���̏ꍇ
			else{
				unshift(@renew_line,"<>$user_name<>$host<>$main::time<>$main::date<>$agent<>\n");
				Mebius::Admin::AlertMail(undef,"�Ǘ����[�h �F �V�����ڑ���",undef,%main::admy);
			}
	}

	# �t�@�C���X�V
	if($type =~ /Renew/ && !$not_renew_flag){
		unshift(@renew_line,"$top{'key'}<>\n");
		Mebius::Fileout(undef,$file,@renew_line);
	}
	


}



package main;

#-------------------------------------------------
#  �Ǘ��҂̃��O�C���`�F�b�N
#-------------------------------------------------
sub logincheck_admin{

my($admy) = Mebius::my_admin();
our %admy = %$admy;

	# �Ǘ��L�^���X�V
	if($ENV{'REQUEST_METHOD'} eq "POST"){
		&renew_myhistory();
	}


}

no strict;

# --------------------------------------------
# �}�C�f�[�^��ύX
# --------------------------------------------
sub MyData{

# �錾
my($type,$id) = @_;
my($mydata_makebody,%data);
our(%in,$script);

# �����`�F�b�N
if($id =~ /\W/){ main::error("�}�C�ݒ���J���Ǘ���ID���s���ł��B"); }

	# �����`�F�b�N
	if($type =~ /Edit-mydata/){
			if($in{'ryaku'} =~ /\D/){ main::error("���X�ȗ����͔��p�����Ŏw�肵�Ă��������B"); }
			if($in{'ryaku'} =~ /\D/){ main::error("���X�ȗ����͔��p�����Ŏw�肵�Ă��������B"); }
			if($in{'sakujo'} =~ /<br>/){ main::error("�폜���ɉ��s�͎g���܂���B"); }
	}

# �}�C�f�[�^���J��
open(MY_DATA,"<_mydata/$id.cgi");
chomp(my $my_data1 = <MY_DATA>);
chomp(my $my_data2 = <MY_DATA>);
($data{'deleted_text'},$data{'per_page_thread'},$data{'omit_thread_res'},$data{'oya_search'}) = split (/<>/,$my_data1);
($data{'res_template'}) = split (/<>/,$my_data2);
#($myd_sakujo,$myd_th_page,$myd_ryaku,$myd_oyasearch) = split (/<>/,$my_data1);
#($myd_template,$myd_formlink) = split (/<>/,$my_data2);
close(MY_DATA);

	# �O���[�o���ϐ���ݒ�

	# �t�@�C���X�V
	if($type =~ /Renew/){

		my %renew_data = %data;

		# �ݒ�l�����i���s�Ȃǁj
		$mydata_makebody .= "$in{'sakujo'}<>$in{'th_page'}<>$in{'ryaku'}<>$in{'oyasearch'}<><>\n";
		$mydata_makebody .= "$in{'template'}<>$in{'formlink'}<><><><>\n";

		Mebius::Fileout(undef,"_mydata/${id}.cgi",$mydata_makebody);

	}


return(%data);

}

no strict;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# ���O�C���������X�V
#-----------------------------------------------------------
sub renew_logined{

my($line,$i,$file_handler,@renew_line);

my($init_directory) = Mebius::BaseInitDirectory();

# �t�@�C����`
my $file = "${init_directory}_admin/_log_admin/login_history_admin.log";

# ���O�C���������J��
open($file_handler,"<",$file);
flock($file_handler,1);
	while(<$file_handler>){
		$i++;
			if($i < 500){ push(@renew_line,$_); }
	}
close($file_handler);

# �ǉ�����s
unshift(@renew_line,"$main::time<>$main::date<><>$main::admy_name<>$main::host<>$main::addr<>$main::agent<>\n");

# ���O�C���������X�V
Mebius::Fileout(undef,$file,@renew_line);

}


#-------------------------------------------------
#  ���O�C���������
#-------------------------------------------------
sub enter_disp {

# �錾
my($basic_init) = Mebius::basic_init();
my($type,$message) = @_;

# �N�G�����p��
my $query = $ENV{'QUERY_STRING'};

# ���O�C���t�H�[���㕔
my $print .= qq(
<br><div align="center">
<a href="$home">�s�n�o�y�[�W�ɖ߂�</a><br><br>
<div class="div2"><div class="div4">
<div align="center">
<div>
<br><br>
������������؂��Ă����܂��傤!!<br>
���h�c�A�p�X���[�h�͈ËL���Ă����܂��傤�B<br>
<span class="red">���}�X�^�[�⑼�̊Ǘ��҂��A���Ȃ���ID��p�X���[�h�𕷂����Ƃ͂���܂���B�M���ł�����@�i�Ǘ����[����A�m���ɊǗ��҂̂��̂��ƕ������Ă��郁�[���A�h���X�j�ŘA���������Ȃ��Ă��������B</span>
</div>
);

if($message){ $print .= qq(<div class="message-red">$message</div>); }

my $back_url_input_hidden = Mebius::back_url_input_hidden();

$print .= qq(
<br>
<br>

<form action="index.cgi" method="post">
<input type=hidden name=mode value="login">
$back_url_input_hidden
���O�C���h�c <input type=text name=id value="" style="width:10em;"><br>
�p�X���[�h <input type=password name=pw value="" style="width:10em;" autofocus>
<input type="hidden" name="query" value="$query">
<br><br>
<input type=submit value=" ���O�C��">
</form>
</div>

<div style="border:1px solid #000;padding:1em;margin:1em;">
�����܂����O�C���ł��Ȃ��ꍇ<br><br>


�E��ʉE���Ȃǂ́A�o�b�̎����ݒ肪�ςɂȂ��Ă��Ȃ����m�F���Ă݂Ă��������B<br>
�E���O�I�t�A���O�C�������x���J��Ԃ��Ă݂Ă��������B<br>
�E���O�C����ʂ�A���O�C���ł��Ȃ��t�q�k�ŁA��ʍX�V�����x���J��Ԃ��Ă݂Ă��������B<br>
�E�o�b���ċN�������Ă݂Ă��������B<br>
�E�u���E�U�́u�c�[���v���u�C���^�[�l�b�g�I�v�V�����v���u�v���C�o�V�[�v�̐ݒ�ȂǂŁA�N�b�L�[���L�����ǂ����m���߂Ă��������B<br>
�E�u���E�U�́u�c�[���v���u�C���^�[�l�b�g�I�v�V�����v���uCookie�̍폜�v�ȂǂŁA�N�b�L�[��S�폜���Ă݂Ă��������B<br>
�E�ʂ̃u���E�U���_�E�����[�h���Ă݂Ă��������B<a href="http://jp.opera.com/">Opera</a>
<a href="http://www.mozilla-japan.org/products/firefox/">FireFox</a>
<a href="http://www.google.co.jp/chrome/intl/ja/landing_ch.html">Google Chrome</a>
<br>
�E�q����Ȃ��ꍇ�̘A����@<a href="mailto:$basic_init->{'admin_email'}">$basic_init->{'admin_email'}</a>�@�i�}�X�^�[�j
</div>

</div></div></div>$in{'comment'}
);

Mebius::Template::gzip_and_print_all({ NotAdminNavigation => 1 },$print);


exit;

}



#-------------------------------------------------
#  �G���[����
#-------------------------------------------------
sub error {

	if ($lockflag) { &unlock($lockflag); }

my $error = shift;
g_shift_jis($error);
my($package, $file, $line) = caller; 

my $print .= <<"EOM";
<div align="center"><div style="border:1px #000 solid;padding:20px;margin:15% auto;width:60%;">
<strong style="color:#f00;" class="line-height-large">�G���[�F <br$main::xclose>$error</strong><br><br>
$in{'comment'}
w<a href="JavaScript:history.go(-1)">�O�̉�ʂɖ߂�</a><br><br>
<a href="$script">�f���ɖ߂�</a><br><br>
<a href="$home">�s�n�o�y�[�W�ɖ߂�</a></span>
$pr2
</div></div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-------------------------------------------------
# �N�b�L�[���s
#-------------------------------------------------
sub set_cookie_admin {

	local(@cook) = @_;
	local($gmt, $cook, @t, @m, @w);

	@t = gmtime(time + 60*24*60*60);
	@m = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
	@w = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

	# ���ەW�������`
	$gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
	$w[$t[6]], $t[3], $m[$t[4]], $t[5]+1900, $t[2], $t[1], $t[0]);

	# �ۑ��f�[�^��URL�G���R�[�h
	foreach (@cook) {
		s/(\W)/sprintf("%%%02X", unpack("C", $1))/eg;
		$cook .= "$_<>";
	}

	# �i�[
	if($alocal_mode){ print "Set-Cookie: mebiusu_admin=$cook; expires=$gmt; path=/;\n"; }
	else{ print "Set-Cookie: mebiusu_admin=$cook; expires=$gmt; domain=mb2.jp; path=/;\n" };

}



#-------------------------------------------------
# �N�b�L�[�擾
#-------------------------------------------------
sub get_cookie_admin {
local($key, $val, *cook);

# �N�b�L�[���擾
$cook = $ENV{'HTTP_COOKIE'};

# �Y��ID�����o��
foreach ( split(/;/, $cook) ) {
($key, $val) = split(/=/);
$key =~ s/\s//g;
$cook{$key} = $val;
}

# �f�[�^��URL�f�R�[�h���ĕ���
foreach ( split(/<>/, $cook{'mebiusu_admin'}) ) {
s/%([0-9A-Fa-f][0-9A-Fa-f])/pack("H2", $1)/eg;

push(@cook,$_);
}
return (@cook);
}



use Mebius::Page;
no strict;


#-------------------------------------------------
# ���������N
#-------------------------------------------------
sub ad_auto_link {

# �Ǐ���
my($msg,$thread_number,$bbs_kind) = @_;
my($param) = Mebius::query_single_param();
#local($reporter_href);

# ��ʗp���Ǘ��p�ւ̏C��
($msg) = Mebius::Fixurl("Normal-to-admin",$msg);

	# ���G�����y�[�W
	#if($concept =~ /SUPERLINK/ && !$param->{'superlink_off'}){ 
	#	my $url_back_enc_paint = Mebius::Encode("","http://$server_domain/jak/$moto.cgi?mode=view&no=$thread_number#S$no");
	#	$msg =~ s!http://([a-z0-9\.]+)${main::main_url}\?mode=pallet-viewer-([0-9a-z]+)-([0-9]+)-([0-9]+)!<a href="$&\&amp;backurl=$url_back_enc_paint" class="sred">$&</a>!g;
	#}

# �X�^���v
($msg) = Mebius::Effect::all($msg);

# ���������N
($msg) = Mebius::auto_link($msg);

# ttp �����N
$msg =~ s/([^=^\"h]|^)(ttps?\:\/\/[\w\.\,\~\!\-\/\?\&\+\=\:\@\%\;\#\%\*]+)/$1<a href=\"h$2\">$2<\/a>/g;


	# �񍐎҂̃A�N�Z�X���
	#if($concept =~ /SUPERLINK/ && !$param->{'superlink_off'}){

			# ID
	#		if($line->{'id'} =~ /^([\w\.\/=\-]+)$/){
	#			my($id_encoded) = Mebius::Encode(undef,$line->{'id'});
	#			$reporter_href .= qq(&amp;reporter_id=$id_encoded);
	#		}
			
			# �z�X�g
	#		if($line->{'host'} && $main::admy{'rank'} >= $main::master_rank){
	#			my($host_encoded) = Mebius::Encode(undef,$line->{'host'});
	#			$reporter_href .= qq(&amp;reporter_host=$host_encoded);
	#		}

			# �A�J�E���g
	#		if($account){
	#			$reporter_href .= qq(&amp;reporter_account=$account);
	#		}

			# �g���b�v
	#		if($trip){
	#			my($trip_encoded) = Mebius::Encode(undef,$trip);
	#			$reporter_href .= qq(&amp;reporter_trip=$trip_encoded);
	#		}

			# ���[�U�[�G�[�W�F���g
	#		if($line->{'user_agent'} && $main::admy{'rank'} >= $main::master_rank){
	#			my($agent_encoded) = Mebius::Encode(undef,$line->{'user_agent'});
	#			$reporter_href .= qq(&amp;reporter_agent=$agent_encoded);
	#		}

			# �N�b�L�[
	#		if($line->{'cookie_char'}){
	#			my($cnumber_encoded) = Mebius::Encode(undef,$line->{'cookie_char'});
	#			$reporter_href .= qq(&amp;reporter_cnumber=$cnumber_encoded);
	#		}

	#}

	# �X�[�p�[�����N�̖߂��
	#if($concept =~ /SUPERLINK/ && !$param->{'superlink_off'}){
	#	$msg =~ s/<a href="https?:\/\/([a-z0-9\.]+?)\/jak\/([0-9a-z]+?)\.cgi\?mode=view&amp;no=([0-9]+?)(&amp;.+?)?(#[a-zA-Z0-9]+)?">(h)?ttps?:\/\/(.+?)<\/a>/&push_backurl($1,$2,$3,$4,$5,$6,$7);/eg;
	#}

	# �X�[�p�[�����N
	#if($concept =~ /SUPERLINK/ && !$param->{'superlink_off'}){ 

			# �Ή����̃��X
			if($res_concept =~ /Admin-regist/) { $msg =~ s/^(��|No\.|&gt;&gt;)?([0-9]{1,5})$/<a href="#S$2">&gt;&gt;$2<\/a>/g; }

		# ���X�Ԃ���{�C��
	#	($msg) = basefix_resnumber($msg);

		# �͈͎w����J���}�w���
		#$msg =~ s/(,|No\.|&gt;&gt;)([0-9]+)\-( |�@)?(No\.|&gt;&gt;)?([0-9]+)/&becommma_resnumber($1,$2,$3,$4,$5);/eg;

		# ���X�Ԃ��Ȃ���
		#$msg =~ s/(No\.|&gt;&gt;)([0-9]+)([ �@\-,]+?)([Nogt;0-9,\.\&�A �@]+)/&bridge_resnumber($1,$2,$3,$4);/eg;
		#$msg =~ s/(No\.|&gt;&gt;)([0-9]+)([ �@\-,]+?)([Nogt;0-9,\.\&�A ]+)/&bridge_resnumber($1,$2,$3,$4);/eg;

			# �폜��̖߂��l
	#		if($url_back_enc){

				# ���X��
	#			$msg =~ s/(No\.|&gt;&gt;)([0-9,-]+)/<a href="$superlink&amp;No=$2$reporter_href&amp;backurl=$url_back_enc#RESNUMBER" class="sred">&gt;&gt;$2<\/a>/g;

	#		}

		
	#}

	# ���ʂ̃��X�ԃ����N
	#if($concept !~ /SUPERLINK/){
	my($bbs_thread_url) = Mebius::BBS::thread_url_admin($thread_number,$bbs_kind);
		$msg =~ s/No\.([0-9,-]+)/<a href=\"$bbs_thread_url?mode=view&amp;no=$thread_number&amp;No=$1$backurl_query_enc#RESNUMBER\">&gt;&gt;$1<\/a>/g;
	#}



return($msg);

}

#-----------------------------------------------------------
# ���X�Ԃ���{�C�� �i ���s�܂� �j
#-----------------------------------------------------------
sub basefix_url_all{

my($msg) = @_;

#$msg =~ s/No\.([0-9,\-]+)([ �@]+)/No\.$1�@/g;
$msg =~ s/�@/ /g;
	$msg =~ s/��/No./g;
#$msg =~ s/No\.([0-9,\-]+)([ ]+)/No\.$1/g;


return($msg);

}


#-------------------------------------------------
# �`�F�b�N���[�h
#-------------------------------------------------
sub check{
if($header_flag) { print"Content-type:text/html\n\n"; }
$print .= $_[0];
exit;
}

#-----------------------------------------------------------
# �G���R�[�h
#-----------------------------------------------------------
sub enc{
my($check) = @_;
if($check eq ""){ return; }
$check =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
$check =~ tr/ /+/;
return($check);
}

#-----------------------------------------------------------
# �f�R�[�h
#-----------------------------------------------------------
sub dec{
my($check) = @_;
$check =~ tr/+/ /;
$check =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("H2", $1)/eg;
return($check);
}

#-----------------------------------------------------------
# �G�X�P�[�v���� 
#-----------------------------------------------------------
sub escape{
my($type,$val) = @_;
if($type !~ /NOTAND/){ $val =~ s/&/&amp;/g; }
$val =~ s/"/&quot;/g;
$val =~ s/</&lt;/g;
$val =~ s/>/&gt;/g;
$val =~ s/(\r\n|\r|\n)/<br>/g;
$val =~ s/\0//g;
$val =~ s/^([\|]+)//g;
return($val);
}


#-----------------------------------------------------------
# ��荞�ݏ���
#-----------------------------------------------------------
#sub adurl{ require "admin_adurl.cgi"; &do_adurl(@_); }
sub renew_myhistory{ &do_renew_myhistory(@_); }
sub trip{ return("",$admy_name); }
sub redun{ return; }
sub kget_items{ return; }
sub md5{ return; }
sub backurl{ require "${int_dir}part_backurl.pl"; &get_backurl(@_); }
sub adevice{ Mebius::Checkdevice_fromagent(@_); }

sub trip{ return; }
sub access_log{}
sub bbs_init_category{ }

# �� �Ǘ��҂̏o�ȕ�A���� -----------------------------------------------------------


#-----------------------------------------------------------
# ���[�h����
#-----------------------------------------------------------
sub admin_login_history_junction{

# �Ǐ���
my($file,$top,$none_flag,$line);

# �t�@�C�����`
$file = $in{'file'};
if($in{'file'} eq "my"){ $file = $admy_file; }
$file =~ s/\W//g;
if($file eq ""){ &error("�\\���ł��܂���B"); }

# ���s
view_admin_login_history();

# �����I��
exit;

}

#-----------------------------------------------------------
# ��{���������s
#-----------------------------------------------------------

sub view_admin_login_history{

# �Ǐ���
my($line,$flag,$fook_name);

# CSS��`
$css_text .= qq(
table,th,tr,td{border-style:none;}
table{padding:0em 1em;}
td{padding:0.3em 0.2em;}
li{line-height:1.6;}
.domain_links{color:#080;font-size:140%;margin:1em 0em;font-style:oblique;}
.blue{color:#00f;}
div.member{word-spacing:0.5em;line-height:1.4;}
);



my($member_line) = Mebius::Admin::MemberList("Get-line-admin-record");


	# �h���C���؂�ւ������N
	{ my($i);
		foreach(@domains){
		$i++;
		if($i >= 2){ $domain_links .= qq( - ); }
		if($_ eq $server_domain){ $domain_links .= qq( $_ ); }
		else{ $domain_links .= qq( <a href="http://$_/jak/index.cgi?mode=vadhistory&amp;file=$file">$_</a> ); }
		}
		$domain_links = qq(<div class="domain_links">�h���C���F $domain_links</div>);
	}

# ���݂�
my(%admin_member_fook) = Mebius::Admin::MemberFookFile("File-check-error",$main::in{'file'});

my(%admin_member) = Mebius::Admin::MemberFile("File-check-error",$admin_member_fook{'id'});

# �Ǘ��L�^���擾
&get_base_admin_login_history();

# �o�ȕ���擾
&get_attend_admin_login_history();

# ���X�������擾
&get_restory_admin_login_history();

# �^�C�g����`
$sub_title = qq($admin_member{'name'} : �Ǘ��L�^);

# HTML
my $print =  qq(
<h1>$admin_member{'name'}�̋L�^</h1>
$domain_links
$member_line
$base_line
$restory_line
$attend_line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# �폜���R�[�h���擾
#-----------------------------------------------------------

sub get_base_admin_login_history{

# ���^�[��
if($in{'type'} eq "attend" || $in{'type'} eq "restory"){ return; }

open(IN,"_adhistory/${file}_adhistory.cgi");
my $top = <IN>; chomp $top;
my($lasttime,$ymd,$delcount,$res) = split(/<>/,$top);
close(IN);

$base_line = qq(
<h2>���R�[�h</h2>
<ul>
<li>�폜���s <strong class="red">$delcount��</strong>
<li>���X�� <strong class="red">$res��</strong>
<li>�ŏI�Ǘ� $ymd
</ul>
);

}

#-----------------------------------------------------------
# �o�ȕ���擾
#-----------------------------------------------------------
sub get_attend_admin_login_history{

# �Ǐ���
my($i,$hit,$redo,$saveym,$nowtime);

# ���^�[��
if($in{'type'} eq "restory"){ return; }

# �j��
my @wdays = ("��","��","��","��","��","��","�y");

# ���ݎ���
$nowtime = $time;

# �o�ȃt�@�C�����J��
open(IN,"_adhistory/${file}_attend.cgi");
while(<IN>){
$i++;
if($i > 5 && $in{'type'} ne "attend"){ last; }
if($i >= 2){ $nowtime -= 24*60*60; }
my($day,$month,$year,$wday) = (localtime($nowtime))[3..6];
$year += 1900; $month += 1;
$wday = $wdays[$wday];

my($dyear,$dmonth,$dday,$dwday) = split(/<>/);
my($vwday);


if($in{'type'} eq "attend" && "$year-$month" ne $saveym){
$saveym = "$year-$month";
$attend_line .= qq(<h3>$year�N$month��</h3>);
}

if($wday eq "��"){ $vwday = qq(<span class="red">($wday)</span>); }
elsif($wday eq "�y"){ $vwday = qq(<span class="blue">($wday)</span>); }
else{ $vwday = qq(($wday)); }

if("$year-$month-$day" ne "$dyear-$dmonth-$dday" && $redo < 100){
$attend_line .= qq(<li><strike>$year/$month/$day $vwday</strike>);
$redo++;
redo;
}



$attend_line .= qq(<li>$year/$month/$day $vwday);

$hit++;

}
close(IN);

$attend_line = qq(
<h2><a href="$script?mode=vadhistory&amp;file=$file&amp;type=attend">�o�ȕ�</a></h2>
<span class="guide">���Ǘ����[�h�ɃA�N�Z�X����ƋL�^����܂��i�T�[�o�[���j�B</span>
<ul>$attend_line</ul>
);

}

#-----------------------------------------------------------
# ���X�������擾
#-----------------------------------------------------------
sub get_restory_admin_login_history{

# �Ǐ���
my($i);

# ���^�[��
if($in{'type'} eq "attend"){ return; }

open(IN,"_adhistory/${file}_restory.cgi");
while(<IN>){
$i++;
if($i > 20 && $in{'type'} ne "restory"){ last; }
chomp;
my($key,$title,$sub,$moto,$no,$res,$time,$date,$category) = split(/<>/,$_);
$restory_line .= qq(<tr><td><a href="$moto.cgi?mode=view&amp;no=$no">��</a> <a href="$moto.cgi?mode=view&amp;no=$no#S$res">$sub</a> &gt; <a href="$moto.cgi?mode=view&amp;no=$no&amp;No=$res#S$res">No.$res</a></td><td><a href="$moto.cgi">$title</a></td><td>$date</td></tr>);
}
close(IN);
$restory_line = qq(<h2><a href="$script?mode=vadhistory&amp;file=$file&amp;type=restory">���X����</a></h2><table>$restory_line</table>);

}



#-----------------------------------------------------------
#-----------------------------------------------------------

sub do_renew_myhistory{

# �Ǐ���
my($plus_delcount,$plus_res) = @_;
my($flag);

# �t���O�𗧂Ă�
if(@_){ $flag = 1; }

# �L�^�t�@�C�����J��
open(IN,"<","./_adhistory/${admy_file}_adhistory.cgi");
flock(IN,1);
my $top = <IN>; chomp $top;
my($lasttime,$ymd,$delcount,$res) = split(/<>/,$top);
close(IN);

# �f�[�^�ύX
$delcount += $plus_delcount;
$res += $plus_res;

	# �o�ȕ������
	if($ymd ne "$thisyear-$thismonth-$today"){ $flag = 1; &renew_attend(); }

# �ǉ�����s
$line = qq($time<>$thisyear-$thismonth-$today<>$delcount<>$res<>\n);

	# �L�^�t�@�C�����X�V����
	if($flag){
		Mebius::Fileout(undef,"_adhistory/${admy_file}_adhistory.cgi",$line);
	}


}

#-----------------------------------------------------------
# �o�ȕ������
#-----------------------------------------------------------
sub renew_attend{

my($now_date_mulit) = Mebius::now_date_multi();

# �ǉ�����s
my $line .= qq($thisyear<>$thismonth<>$today<>$now_date_multi->{'weekday'}<>\n);

# �o�ȃt�@�C�����J��
open(IN,"<","_adhistory/${admy_file}_attend.cgi");
while(<IN>){ $line .= $_; }
close(IN);

# �o�ȃt�@�C�����X�V����
open(OUT,">","_adhistory/${admy_file}_attend.cgi");
print OUT $line;
close(OUT);
chmod($logpms,"_adhistory/${admy_file}_attend.cgi");


}

#-----------------------------------------------------------
# �Ăт����e���v��
#-----------------------------------------------------------

sub get_calltemplate{

# �Ǐ���
my($line);

# CSS��`
$css_text .= qq(
div.template1{background-color:#fff;text-indent:0.5em;}
div.template2{background-color:#ccc;text-indent:0.5em;}
div.template3{background-color:#f9e;text-indent:0.5em;}
div.template4{background-color:#9ff;text-indent:0.5em;}
div.template5{background-color:#ff3;text-indent:0.5em;}
div.template6{background-color:#f99;text-indent:0.5em;}
div.template7{background-color:#4f4;text-indent:0.5em;}
td.template{border:dashed 1px #0a0;padding:0.5em;line-height:1.7;word-spacing:1.1em;font-size:80%;color:#f00;}
);

# �e���v���[�g���Q�b�g
($line) .= &get_templatetext;
$line .= $redcard;

# �e���v���[�g�̒���
$line =~ s/%/%25/g;
$line =~ s/\[br\]/\r/g;
$line =~ s/>>/&gt;/g;
$line =~ s/\n//g;
$line =~ s/\r/\\n/g;

return($line);

}

#-----------------------------------------------------------
# �e���v���[�g���擾
#-----------------------------------------------------------
sub get_templatetext{

# �Ǐ���
my($line);

#-----------------------------------------------------------
# ��{
#-----------------------------------------------------------
$line .= '

<div class="template1">
<strong>��{</strong> 
<a href="javascript:template(\'\r
�������܂����A�ꕔ���e���폜�����Ă��������܂����B\r
\r\')">�폜</a> 

<a href="javascript:template(\'\r
���r�E�X�����O�̃K�C�h���A���߂Ă��m�F���������B\r
http://mb2.jp/wiki/guid/\r
\r\')">�K�C�h</a> 

<a href="javascript:template(\'\r
���e�~�X���폜�����Ă��������܂����B�i���e��̊ԈႦ�A��d���e�A���������Ȃǁj\r
\r\')">�~�X</a> 

<a href="javascript:template(\'\r
�{�l�l����̈˗����󂯁A�폜�����Ă��������܂����B\r
\r\')">�{�l</a> 

<a href="javascript:template(\'\r
��ϐ\���󂠂�܂��񂪁A\r
�i���Ƃ��ΊO���T�C�g�Ȃǂ���j�����l�ł��z���ɂȂ�A��Ăɏ������ލs�ׂ͂�������������\r\r
���Ɏ��̂悤�ȍs�ׂ͋֎~�����Ă��������܂��B\r\r
�E�L���Ɋ֌W�̂Ȃ���������\r
�E�����[�U�[�l�̔����������s��\r
�E�`�`�̏������݁A���΂Ȍ��t�̏�������\r\r
�����[�U�[�l�̖��f�ɂȂ�Ɣ��f�������e�ɂ��ẮA�Ǘ��҂̔��f�ō폜�����Ă��������ꍇ���������܂��B\r
\r\')">���K</a> 

<a href="javascript:template(\'\r
���S�̂��߂ɁA�K�����̂��Ƃ����H���Ă��������B\r
�u�������T�C�g�ɍs���Ȃ��v�u�������R�}���h�����s���Ȃ��v�Ȃǁc�c�B\r
��������Ȃ��ƁA���Ȃ��̃p�\�R����A���Ȃ����g�Ɋ댯�ɂȂ邱�Ƃ�����܂��B\r
http://mb2.jp/wiki/guid/%A5%C8%A5%E9%A5%C3%A5%D7%B2%F3%C8%F2%CB%A1\r
\r\')">�g���b�v</a> 

<a href="javascript:template(\'\r
�Ǘ��҂̔��f�ɂ��A����폜�������Ȃ킹�Ă��������܂����B\r\r
�폜���R�F\r
\r\')">����폜</a> 

<strong>�^��</strong> 

<a href="javascript:template(\'\r
������ɂ悭���鎿�₪�܂Ƃ߂��Ă��܂��B\r
��ς��萔�ł����A���Ў��̃K�C�h���������������B\r\r
���폜�p���` - �폜�ɂ��Ă̂p���`�ł��B\r
\r\')">�폜�p���`</a> 

<a href="javascript:template(\'\r
��������̊Ǘ��ɂ��Ă��A��������܂��ꍇ�́A\r
��ς��萔�ł����A������̋L���܂ŏ������݂����肢���܂��B\r
https://mb2.jp/jak/qst.cgi?mode=view&no=1973\r
\r\')">�^��A��</a> 

<a href="javascript:template(\'\r
���ɋ������܂����A�Ǘ��҂���񓚂����񑩂ł��Ȃ��P�[�X���������܂��B\r
��ς��萔�ł͂������܂����u�Ǘ��҉񓚁v�̃K�C�h���������������B\r
\r\')">�Ǘ��҉�</a> 


</div>
';


#-----------------------------------------------------------
# ����
#-----------------------------------------------------------
$line .= '
<div class="template2">
<strong>����</strong> 

<a href="javascript:template(\'\r
�������܂����A���t�����Ⓤ�e�}�i�[�ɂ͏[�������ӂ��������B\r
�{�T�C�g�̗��p�ɂ������āA�K�C�h�̍Ċm�F�����肢�������܂��B\r
\r
���K�C�h�̊m�F - �}�i�[�ᔽ / �}�i�[�p���`�@\r
\r\')">�}�i�[</a> 

<a href="javascript:template(\'\r
���F�l\r\r
���[���ᔽ�ɔ�������ƁA�t���ʂɂȂ��Ă��܂��ꍇ������܂��B\r
���i�̏������݂𑱂�����A�폜�˗����o�����ƂőΏ������肢�������܂��B\r
\r
���K�C�h�̊m�F - ���[���ᔽ�ւ̑Ώ�\r
\r\')">�ߏ蔽��</a> 

<a href="javascript:template(\'\r
���萔�ł����A���̕���s���ɂ�����e�Ȃǂ́A�Ȃ�ׂ������Ĉ��p�����肢���܂��B\r
�i���p���̒��̕\���ɂ��A�폜�����Ă��������ꍇ������܂��j\r
\r\')">���p����</a> 

<strong>����</strong> 

<a href="javascript:template(\'\r
�u�Z���v�u�{���v�u�d�b�ԍ��v�Ȃǌl����A\r
�v���C�x�[�g�ȏ����������񂾂�A�l�ɋ��߂��肵�Ȃ��ł��������B\r
��ő傫�Ȗ��ɂȂ邱�Ƃ�����܂��B\r
\r\')" class="red">�l���</a> 

<a href="javascript:template(\'\r
�ꕔ�Łu���ʁv�u�{���v�u�d�b�v�u���[���v�Ȃǂ̂��b������܂������A\r
�{�T�C�g�Łu�l���̌����E�f�ځv���Ȃ����܂���ł������H\r
�������̏ꍇ�́A���萔�ł��������g�ō폜�˗������肢�������܂��B\r
http://aurasoul.mb2.jp/_delete/\r\r
�܂��A�����v���C�x�[�g�ȏ������݂͖�肪�N���₷�����߁A�Ǘ��҂̔��f�ō폜�����Ă��������ꍇ������܂��B\r
\r\')" class="red">�l���H</a> 

<a href="javascript:template(\'\r
���r�E�X�����O�ɂ͂h�c�V�X�e��������A\r
�M����ς��ď������񂾏ꍇ���A����̂h�c���\������܂��B\r\r
�ς��Ȃ��}�[�N������ꍇ�́u�g���b�v�v�������p���������B\r
http://aurasoul.mb2.jp/wiki/guid/%A5%C8%A5%EA%A5%C3%A5%D7\r
\r\')">����/�g���b�v</a> 


</div>
';


#-----------------------------------------------------------
# ���f
#-----------------------------------------------------------
$line .= '
<div class="template1">
<strong>���f</strong>  

<a href="javascript:template(\'\r
���݂܂��񂪁A���̕��̖��f�ƂȂ鏑�����݂͂��������������B\r
�Ǘ��҂̔��f�ŁA���e���폜�����Ă��������ꍇ������܂��B\r
\r\')">���f(�S��)</a> 

<a href="javascript:template(\'\r
�������܂����A�{�T�C�g�ł͎��̂悤�ȓ��e�͂��������������B\r
\r
���u�}���`�|�X�g�v�u��`�s�ׁv�u�`�F�[�����e�v�u�s�K�؂ȃ����N�v�ȂǁA���̕��̖��f�ƂȂ���́B\r
���u�`�`�v�u�L���̗���v�u�ߏ�ȃf�R���[�V�����v�u�������҂��v�u���Ӗ��ȕ��͂̓��e�v�u���s�̂������v�u���f�]�ځv�ȂǁA�{�T�C�g�̕��̓��[���ɔ�������́B\r
\r
��L�̂��̂́A�Ǘ��҂��폜�����Ă��������ꍇ���������܂��B\r
\r\')">���f(�`�F�[��,�`�`,����,�}���`,��`��)</a> 

<strong>�G�k/�J�e</strong> 

<a href="javascript:template(\'\r
����ł����A�ꕔ���u�G�k���v���Ă��܂��Ă���悤�ɂ����󂯂��܂��B\r
\r
�J�e�S���Ɗ֌W�̂Ȃ��b�i���Ƃ��΁u��Ђ̘b�v�u�w�Z�̘b�v�Ȃǁj�́A\r
��ς��萔�ł����A���R�f���ȂǂɈړ������肢���܂��B\r
http://mb2.jp/_ztd/\r\r

���K�C�h�̊m�F - �G�k��\r
\r\')">�G�k��</a> 

<a href="javascript:template(\'\r
����ł����A�ꕔ���u�`���b�g���v���Ă���悤�ɂ����󂯂��܂��B\r
�u�`���b�g���v���N����Ɓu�f���v�̗ǂ��������Ă��܂����Ƃ�����܂��B\r
\r
�\���󂠂�܂��񂪁u�P�s���X�v�u���A�����̏������݁v�u�����񍐁v�Ȃǂ͍T���A\r
�u�f���v�Ƃ��Ďg���Ă��������悤�A�����͂����肢�������܂��B\r\r
���K�C�h�̊m�F - �`���b�g��\r
\r\')">�`���b�g��</a> 

<a href="javascript:template(\'\r
����ł����A�ꕔ�̓��e���A�L���{���̖ړI���炻��Ă���悤�ɂ����󂯂��܂��B\r
���萔�ł����A�f���̃��[����e�[�}�����m�F�̏�A \r
�����@�\�����p���A�ӂ��킵���L����I��ŏ�������ł��������B\r
\r\')">�J�e�Ⴂ(���X)</a> 

<a href="javascript:template(\'\r
����ł����ꕔ�̓��e���A�L���̃e�[�}������Ă���悤�ɂ����󂯂��܂��B\r\r
�T�C�g���p�}�i�[�ɂ��Ă��b�������ꍇ�́A\r
�������܂����u���r�E�X�����O����^�c�v�ւ̈ړ������肢�������܂��B\r
http://aurasoul.mb2.jp/_qst/2403.html\r
\r\')">�J�e�Ⴂ(�}�i�[)</a> 

</div>
';



#-----------------------------------------------------------
# �i���p
#-----------------------------------------------------------
$line .= '
<div class="template3">
<strong>�o��</strong> 

<a href="javascript:template(\'\r
�������܂����A���[���A�h���X�̓��e�͍폜�ΏۂƂȂ�܂��B\r
���[���A�h���X���������񂾂�A�l�ɕ������肷��s�ׂ͂��������������B\r
\r\')">�����A�h</a> 

<a href="javascript:template(\'\r
�������܂����{�T�C�g�ł́A
�u�����F��W�v�u���ʑ����W�v�Ȃǂ̕�W��A\r
�u���l��W�v�u�J�b�v�����v�u��񑩁v�u�o�[�`�����f�[�g�v�Ȃǂ̍s�ׂ͂��������������Ă���܂��B\r
�ߓx��ۂ��Ă̗��p�����肢�������܂��B\r
\r\')">�o��n</a> 

<strong>���I</strong> 

<a href="javascript:template(\'\r
�������܂����A�{�T�C�g�ł͎��̂悤�ȓ��e�͋֎~�ƂȂ��Ă��܂��B\r
\r
�E�i���k�A�c�_�ȊO�ł́j���I�ȓ��e\r
�E�t�H���[�̂Ȃ��u���̕񍐁v�u���̎���v\r
�E���̑��k�ŁA�z���̂Ȃ���������\r
\r
��L�̂悤�Ȃ��̂́A�Ǘ��҂̔��f�ō폜�����Ă��������ꍇ������܂��B\r
\r\')">���I</a> 
</div>';


#-----------------------------------------------------------
# �n��
#-----------------------------------------------------------
$line .= '
<div class="template4">
<strong>�n��</strong> 

<a href="javascript:template(\'\r
���萔�ł����u���I�\���̃��[���v�̍ă`�F�b�N�����肢�������܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%C0%AD%C5%AA%A4%CA%C9%BD%B8%BD\r
\r\')">���I-�n</a> 

<a href="javascript:template(\'\r
���萔�ł����u�V���b�L���O�ȕ\���̃��[���v�̍ă`�F�b�N�����肢�������܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%CB%BD%CE%CF%C5%AA%A4%CA%C9%BD%B8%BD\r
\r\')">�V���b�N-�n</a> 

<a href="javascript:template(\'\r
�u�n��薼�̃��[���v�������m�ł����B\r
���̃y�[�W���悭�ǂ݁A�n��I�ȕ��͋C�ɂ��Ĕz�������肢�������܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%C1%CF%BA%EE%A4%CE%C2%EA%CC%BE\r
\r\')">�薼-�n</a> 

<a href="javascript:template(\'\r
���݂܂��񂪑n��̏�ł́A�߂����G�k�͂��������������B\r
�����ɁA�𗬐�p�̌f���������p���������B\r
���K�C�h�̊m�F - �G�k��\r
\r\')">�G�k-�n</a> 

<a href="javascript:template(\'\r
���̍�i�Ɂu�͕�E����E�񎟑n��v�Ȃǂ̗��R�ō폜�˗����o����܂����B\r
���萔�ł����Ahttp://aurasoul.mb2.jp/_delete/155.html�@�܂ŘA�������肢�ł��Ȃ��ł��傤��\r
\r\')">����-�n</a> 

<a href="javascript:template(\'\r
����E�͕�Ȃǂɂ��ċc�_�������ꍇ�́A\r
���萔�ł����A�}�i�[�f���Ɉړ������肢���܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%C5%F0%BA%EE%A1%A2%CC%CF%CA%EF%A4%CE%CF%C3%A4%B7%B9%E7%A4%A4\r
\r\')">����c�_-�n</a> 

<a href="javascript:template(\'\r
���f�ŁA���̐l�̍�i�𑱂���s�ׂ͂��������������B\r
�����̍�i�������ꍇ�́A�L���̐V�K���e�����肢���܂��B\r
\r\')">����-�n</a> 

<a href="javascript:template(\'\r
���萔�ł�����i��]�ɂ������āA������̃K�C�h���������������B\r
http://aurasoul.mb2.jp/wiki/guid/%BA%EE%C9%CA%C8%E3%C9%BE\r
\r\')">��]-�n</a> 

<a href="javascript:template(\'\r
���݂܂��񂪃��r�E�X�����O�ł́A�񎟑n��͋֎~�ƂȂ��Ă��܂��B\r
\r\')">��-�n</a> 

<a href="javascript:template(\'\r
�����������Ƃ��́A���M���Ȃǂɍ��킹�āA�ꏊ�������߂��������B\r
���Ƃ��Ώ����n�߂ĂP�N�����ł���΁u���S�҂̂��߂̏������e��v���������߂ł��B\r
http://aurasoul.mb2.jp/_sst/\r
\r\')">���S-�n</a> 

<a href="javascript:template(\'\r
�g���������������Ƃ��́u�g�����������e��v���������߂ł��B\r
http://aurasoul.mb2.jp/_tog/\r
\r\')">�g��-�n</a> 

<a href="javascript:template(\'\r
�u�N��ݒ�v���U���āA�����̂���L�����{�����邱�Ƃ͂��������������B\r
\r\')">�N��U</a> 

<a href="javascript:template(\'\r
���萔�ł����A�����ւ̃R�����g�E���z�̓T�u�L���������p���������B\r
\r\')">�T�u</a> 
</div>
';


#-----------------------------------------------------------
# �L��
#-----------------------------------------------------------
$line .= '
<div class="template7">
<strong>�L��</strong> 

<a href="javascript:template(\'\r
�����f���ɁA�����e�[�}�̋L���͂ЂƂ܂łł��B\r
���萔�ł����A�����@�\�Ȃǂ��g���ē���̋L����T���A������������p���������B\r
\r\')">�d��</a> 

<a href="javascript:template(\'\r
���̋L���́A�W����������������Ă��܂���B\r
�L���͂��܂��W�������������Ă�������悤���肢�������܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%A5%B8%A5%E3%A5%F3%A5%EB%CA%AC%A4%B1\r
\r\')">�W����������</a> 

<a href="javascript:template(\'\r
���萔�ł����A�f���̃e�[�}����O�ꂽ�L���͈ړ������肢���܂��B\r
�f���̃��[����A��|���悭�����̏�A \r
�ӂ��킵���ꏊ��I��ŏ�������ł��������B\r
\r\')">�J�e�Ⴂ(�L��)</a> 

<a href="javascript:template(\'\r
���݂܂��񂪁A�{�T�C�g�ł͎��̂悤�ȋL������邱�Ƃ͏o���܂���B\r
\r
�E�u�N��^�w�N�^���ʁ^���Z�n�v�ŎQ���҂����߂��L��\r
�E�u���Ƙb�����v�u�`����Ƃa����̘b����v�ȂǁA�l�I�ȋL��\r
�E�e�[�}��������������A�薼��e�[�}���s���ĂȋL����A�P���L��\r
\r
���萔�ł����A�V�K���e�̃��[���ɂ��킹�āA�L���̍�蒼�������肢���܂��B\r
\r\')">�e�[�}/����/�l�I</a> 

<strong>�C��</strong> 

<a href="javascript:template(\'\r
����ɂ��A&gt;&gt;0 �̓��e�i�܂��͑薼�j��ύX�����Ă��������܂����B\r
\r\')">��E���e�C��</a> 


</div>
';


#-----------------------------------------------------------
# �J�e�S��
#-----------------------------------------------------------
$line .= '
<div class="template5">
<strong>�J�e</strong> 

<a href="javascript:template(\'\r
���萔�ł����񓚂ɂ������āu���k�v�̃K�C�h������񂭂������B\r
\r\')">���k(��)</a> 

<a href="javascript:template(\'\r
�c�_�ɂ������āA������̃K�C�h���Ċm�F���肢�������܂��B\r
�قƂ�ǂ̏ꍇ�A���ƂȂ�̂́u�ӌ��̓��e�v�ł͂Ȃ��u���e�}�i�[�v�ł��B\r
http://aurasoul.mb2.jp/wiki/guid/%B5%C4%CF%C0\r
http://aurasoul.mb2.jp/wiki/guid/%B7%FA%C0%DF%C5%AA%A4%CA%B5%C4%CF%C0\r
\r\')">�c�_</a> 


<a href="javascript:template(\'\r
�������܂����u�Ȃ肫��̃N�I���e�B�v�̃K�C�h�͂������������܂������B\r
http://aurasoul.mb2.jp/wiki/guid/%A4%CA%A4%EA%A4%AD%A4%EA%A4%CE%A5%AF%A5%AA%A5%EA%A5%C6%A5%A3\r\r
���Ƃ��Ύ��̂悤�ȂȂ肫��́A��ɖ����Ȃ����̂Ƃ��č폜�A���b�N�Ȃǂ����Ă��������ꍇ������܂��B\r\r
�E���[�����i�`�ʂ��Ȃ��A�قƂ�ǁu�L�����̑䎌�̂݁v�ŉ���Ă���L���B\r
�E�`���b�g���̂悤�ɁA�R�O�`�T�O�������x�̃��X���قƂ�ǂ��߂�L���B\r
�E�j���̎Q���l�������߂Ă̗����L���i�J�b�v�����O�j�̋L���B\r\r

���[�����K�L���͂�����ł��F\r
http://mb2.jp/_nmn/?mode=find&word=%97%FB%8FK\r
\r\')">�Ȃ�N�I</a> 

<a href="javascript:template(\'\r
�Ȃ肫��f���ł́u���A���G�k�v�͋֎~�ł��B\r
���A���G�k������ꍇ�́A��p�Ɉړ������肢���܂��B\r
http://mb2.jp/_nzz/\r
\r\')">�Ȃ胊�A�G�k</a> 

<a href="javascript:template(\'\r
�Ȃ肫��J�e�S���̐�����A\r
�u�{�̉�b�v�݂̂̏������݂́A�ɗ͍T���Ă��������B\r
\r\')">�{�̉�b</a> 

<a href="javascript:template(\'\r
�u�ʐM�v�u�ΐ�҂����킹�v�Ȃǂ̘b�̓J�e�S���Ⴂ�ł��B\r
�Q�[���f���i�ʐM�E�����j�Ɉړ����Ă��������B \r
http://mb2.jp/_gko/\r
\r\')">�Q�[���ʐM</a>

</div>
';


#-----------------------------------------------------------
# �x��
#-----------------------------------------------------------
$line .= '
<div class="template6">
<strong>�x��</strong> 

<a href="javascript:template(\'\r
���[�����ӂ̌Ăт������������������܂������H\r
�T�C�g���p�ɂ������ẮA���r�E�X�����O�̃��[�����悭���m�F���������B\r
http://aurasoul.mb2.jp/wiki/guid/\r
\r\')">�U��</a> 

<a href="javascript:template(\'\r
���[�����ӂ̌Ăт������������������܂������H\r
�{�T�C�g�̃��[��������肢�������Ȃ��ꍇ�A\r
���݂܂��񂪁A����̗��p�����f�肳���Ă��������ꍇ������܂��B\r
\r\')">�����U��</a> 

<a href="javascript:template(\'\r
�{�T�C�g�̃��[�������炨�肢�������܂��B\r
�ᔽ�������ꍇ�A����u���e�����v�u�v���o�C�_�A���v�Ȃǂ̏��u����点�Ă��������ꍇ������܂��B\r
\r\')">��ʒʍ�</a> 

<a href="javascript:template(\'\r
���r�E�X�����O�ւ̑S�Ă̓��e�́A���Ȃ��̐ڑ����ƈꏏ�ɕۑ�����Ă��܂��B\r
�����ȓ��e���������ꍇ�A�v���o�C�_�i�l�b�g��ЁE�g�щ�Ёj�֘A�������ƁA\r
���Ȃ��̖{�l�̐g��������o����A�l�b�g�ڑ���~�A�މ���Ȃǂ̑Ή����Ȃ����ꍇ������܂��B\r
�{�T�C�g�A�Ȃ�тɖ{�T�C�g���[�U�[�l�ւ̖��f�s�ׂ͂����������悤���肢�������܂��B\r
\r\')">�Ō�ʍ�</a> 


<a href="javascript:template(\'\r
�Ӑ}�I�ȍr�炵�͂��������������B���e�����A�v���o�C�_�A���Ȃǂ̑ΏۂƂ����Ă��������ꍇ������܂��B\r
\r\')">�Ӑ}�I</a> 

<a href="javascript:template(\'\r
�ƍ߂ɂȂ��鏑�����݂�A\r
����������铊�e�����Ȃ��ł��������B\r
�ٔ����A�x�@�Ȃǂ���A�����������ꍇ�A\r
�{�T�C�g�̐ڑ��f�[�^���o�����Ă��������ꍇ������܂��B\r
\r\')">�ƍ�</a> 

</div>
';

return($line);

}


1;

1;




