
# �p�b�P�[�W�錾
package Mebius::Goldcenter;
use strict;
use warnings;

# -------------------------------------------
# ��{�ݒ�
# -------------------------------------------
sub init_start_gold{

# �S�ϐ������Z�b�g
reset 'a-z';

# ���C���ݒ�
$main::head_link1 = 0;
$main::head_link1 = qq(&gt; <a href="$main::base_url">���r�E�X�����O</a> );

# �^�C�g���ݒ�
$main::sub_title = qq(���݃Z���^�[);

# CSS��`
$main::css_text .= qq(
h2{background:#ffc;border:solid 1px #cc0;padding:0.35em 0.7em;font-size:100%;}
h3{font-size:100%;}
);

# �����{�b�N�X�Ŏ������������Ȃ�
$main::nosearch_mode = 1;

# ���[�J���ݒ�
if($main::alocal_mode){
$main::ip_dir = "./ip/";
$main::bkup_dir = "./_backup_home/";
}


}

#-----------------------------------------------------------
# �p�b�P�[�W�̊�{�ݒ�
#-----------------------------------------------------------
sub init{

# �ݒ�
my $script_mode = "";	# "TEST" �Ńe�X�g���[�h
my $gold_url = "/_gold/";	# ���݃Z���^�[��URL
my $title = "���݃Z���^�[";	# �^�C�g��

# �e�X�g���[�h�̐���
if($main::myadmin_flag < 5 && !$main::alocal_mode){ $script_mode = undef; }

# ���^�[��
return($script_mode,$gold_url,$title);

}

#-----------------------------------------------------------
# �K�v�ȋ��ݗʂ̐ݒ�
#-----------------------------------------------------------
sub get_price{

# �錾
my($script_mode,$gold_url,$title) = &init();
my(%price);

# �e�T�[�r�X�ɕK�v�ȋ��݂��`
%price = (
"cancel_newwait" => 100, # �V�K�҂����Ԃ��Ȃ���
);

# ���^�[��
return(%price);

}


#-------------------------------------------------
# �X�^�[�g - �X�N���v�g
#-------------------------------------------------
sub start_gold{

# �錾
my($script_mode,$gold_url,$title) = &init();

# ���[�h�U�蕪��
if($main::mode eq ""){ &index(); }
elsif($main::mode eq "cancel_newwait"){ &cancel_newwait(); }
else{ &main::error("�y�[�W�����݂��܂���B"); }

exit;

}

#-----------------------------------------------------------
# �C���f�b�N�X
#-----------------------------------------------------------
sub index{

# �錾
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($line_guide,$line_cancel_newwait,$line_record_spend);

# CSS��`
$main::css_text .= qq(
div.guide{line-height:1.4;}
);

# �^�C�g����`
$main::head_link2 = qq(&gt; $title);

# ����
$line_guide = qq(<li>�A�J�E���g�Ƀ��O�C�����Ă�����A�ꕔ�̌g�ѓd�b�ł́A���݃Z���^�[�����p�ł��܂��B</li>);
	if($main::callsave_flag){ $line_guide .= qq(<li>���܂̂��Ȃ��́A���݃Z���^�[��<strong class="red">���p�ł��܂��B</strong></li>); }
	else{ $line_guide .= qq(<li>���܂̂��Ȃ��́A���݃Z���^�[��<strong class="red">���p�ł��܂���B</strong><a href="$main::auth_url?backurl=http://$main::server_domain$gold_url">�A�J�E���g</a>�Ƀ��O�C��(�܂��͐V�K�o�^)���Ă��������B</li>); }
	if($main::callsave_flag){
$line_guide .= qq(<li>���݂̓T�[�o�[���ƂɋL�^����܂��B���܂̃T�[�o�[�� <a href="http://$main::server_domain/">$main::server_domain</a> �ł��B</li>);
	}
$line_guide .= qq(<li class="red">���ӁI�@�T�C�g���ł̃��[���ᔽ���������ꍇ�i�������҂��A�����̗���Ȃǁj�A<strong>�u���݂̏����v�u���e�����v�Ȃǂ̃y�i���e�B�����������Ă��������ꍇ������܂��B</strong></li>);

# �����̐��`
$line_guide = qq(
<h2>����</h2>
<div class="guide">
<ul>$line_guide</ul>
</div>
);


# �V�K�҂����Ԃ��Ȃ����t�H�[��
($line_cancel_newwait) = &form_cancel_newwait();

# ���݂̎g�p�L�^���Q�b�g
	if($main::in{'viewall'}){ ($line_record_spend) = &record_spend("VIEW",""); }
	else{ ($line_record_spend) = &record_spend("VIEW","",5); }

# �w�b�_
&main::header();

# HTML
print qq(
<div class="body1">
<h1>$title</h1>
���Ȃ��̋��� : ���� <strong class="red">$main::cgold��</strong> <img src="/pct/icon/gold1.gif" alt="����"> ( <a href="http://$main::server_domain/">$main::server_domain</a> )
$line_guide
<h2>���݂��g��</h2>
$line_cancel_newwait
$line_record_spend
<h2>���݃����L���O</h2>
<a href="${main::main_url}rankgold-p-1.html">�����݃����L���O�͂�����ł��B</a>
</div>
);

# �t�b�^
&main::footer();

exit;

}

#-----------------------------------------------------------
# �V�K���e�̑҂����Ԃ��Ȃ����t�H�[��
#-----------------------------------------------------------
sub form_cancel_newwait{

# �錾
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($line,$newwait_flag,$newwait_hour,$disabled,$alert);

# �V�K���e�̑҂����Ԃ��擾
($newwait_flag,$newwait_hour) = &main::sum_newwait();

# HTML�������`
$line .= qq(
<h3>�V�K���e�̑҂����Ԃ��Ȃ���</h3>
<form action="./" method="post">
<div>
<ul>
<li>�K�v�ȋ���: $price{'cancel_newwait'}�� / $main::cgold ��</li>
<li>���݂̑҂����ԁF $newwait_hour</li>
</ul><br$main::xclose>
<input type="hidden" name="mode" value="cancel_newwait">);

	# ���s�ł��Ȃ����̏ꍇ
	if(!$main::callsave_flag){ $alert = qq(�����̊��ł͎��s�ł��܂���B); }
	# �V�K�҂����Ԃ��Ȃ��ꍇ
	elsif($main::cgold < $price{'cancel_newwait'}){ $alert = qq(�����݂�����܂���B); }
	# ���݂�����Ȃ��ꍇ
	elsif(!$newwait_flag){ $alert = qq(���҂����Ԃ�����܂���B); }
	#�A���[�g���̐��`
	if($alert && $script_mode !~ /TEST/){ $alert = qq(<span class="alert">$alert</span>); $disabled = $main::disabled; }

# ���`
$line .= qq(
<input type="submit" value="���s����"$disabled>
$alert
</div>
</form>
);

# ���^�[��
return($line);

}

#-----------------------------------------------------------
# �V�K���e�̑҂����Ԃ��Ȃ���
#-----------------------------------------------------------
sub cancel_newwait{

# �錾
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($successed);

# ���ݖ������`�F�b�N
&cash_check("","$price{cancel_newwait}");

# �V�K���e�̑҂����Ԃ��Ȃ��� 
($successed) = &main::sum_newwait("UNLINK");

# ���������ꍇ�A���݂������āACookie���Z�b�g����
if($successed == 1 ||  $script_mode =~ /TEST/){
$main::cnew_time = undef;
$main::cgold -= $price{cancel_newwait};
&main::set_cookie();
&record_spend("RENEW","�V�K�҂����Ԃ����炵�܂����B");
}

# ���s�����ꍇ�A�G���[��\������
else{
&main::error("�V�K���e�̑҂����Ԃ�����܂���B");
}

# �y�[�W�W�����v
&Mebius::Jump("","$gold_url","1","�V�K���e�̑҂����Ԃ����炵�܂����B");

# �I��
exit;

}



#-----------------------------------------------------------
# ���݂̎g�p�L�^�� �X�V / �\��
#-----------------------------------------------------------
sub record_spend{

# �錾
my($script_mode,$gold_url,$title) = &init();
my($type,$message,$maxview_line) = @_;
my(@line,$file,$viewline,$i,$newhandle);
my($maxline) = (100);

# �t�@�C�����`
$file = "${main::bkup_dir}gold_spend.log";

# �L�^����M��
	if($type =~ /RENEW/){
$newhandle = $main::chandle;
		if($main::pmname){ $newhandle = $main::pmname; }
		if($newhandle eq ""){ $newhandle = qq(������); }
	}

# �ǉ�����s
	if($type =~ /RENEW/){
push(@line,"1<>$newhandle<>$message<>$main::pmfile<>$main::host<>$main::agent<>$main::date<>$main::time<>\n");
	}

# �t�@�C�����J��
open(GOLD_RECORD_IN,"< $file");
	#if($type =~ /RENEW/){ flock(GOLD_RECORD_IN,1); }
while(<GOLD_RECORD_IN>){
chomp;
my($key2,$handle2,$message2,$account2,$host2,$agent2,$date2,$time2) = split(/<>/);
$i++;
	if($i > $maxline){ next; }
	if($type =~ /RENEW/){ push(@line,"$_\n"); }
	if($type =~ /VIEW/ && ($i <= $maxview_line || !$maxview_line)){
		if($account2){ $handle2 = qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>); }
	$viewline .= qq(<li>$handle2 ���� $message2 ( $date2 )</li>\n);
	}
}
close(GOLD_RECORD_IN);

# �{���݂̂̏ꍇ�A���^�[��
	if($type =~ /VIEW/){
		if($viewline){ $viewline = qq(<h2>���݂̎g�p�L�^</h2>\n<ul>$viewline</ul>); }
return($viewline);
	}

# �t�@�C�����X�V����
	if($type =~ /RENEW/){
open(GOLD_RECORD_OUT,"+> $file");
flock(GOLD_RECORD_OUT,2);
truncate(GOLD_RECORD_OUT,0);
seek(GOLD_RECORD_OUT,0,0);
print GOLD_RECORD_OUT @line;
close(GOLD_RECORD_OUT);
chmod($main::logpms,$file);
	}

# ���^�[��
return();

}

#-----------------------------------------------------------
# ���݂��v�Z
#-----------------------------------------------------------
sub cash_check{

# �錾
my($script_mode,$gold_url,$title) = &init();
my($type,$price) = @_;

# �A���[�J��
if($script_mode =~ /TEST/){ return; }

# �G���[
if(!$main::callsave_flag){ &main::error("���̊��ł͎��s�ł��܂���B�A�J�E���g�Ƀ��O�C�����Ă��������B"); }

# �l�i�̌v�Z
if($main::cgold < $price){ &main::error("���݂�����Ȃ����߁A���s�ł��܂���B $main::cgold�� / $price��"); }

# ���^�[��
return();

}

1;

