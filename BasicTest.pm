
# �錾
use Mebius::Utility;
use Mebius::Auth;
use Mebius::Parts;
use CGI;
package main;

#-----------------------------------------------------------
# �f�R�[�h�����E��{�������� - strict
#-----------------------------------------------------------
sub decode{

# �S�ϐ��̏�����
reset 'a-z';

# �錾
my($type,$init_directory,$init,$init2,$server_domain2,$base_server_domain2) = @_;
my($init_start,$start);
our($alocal_mode,$secret_mode,$mobile_test_mode,$getaccess_mode,$lockkey,$server_domain);
our($moto,$int_dir,$category,$myadmin_flag,$pmfile,$kflag,$thisyear,%in);
our($mode,$submode1,$submode2,$submode3,$submode4,$submode5) = undef;
our($age,$agent,$realagent,$cookie,$addr,$referer,$requri,$scriptname,$device_type) = undef;
our($k_access,$kaccess_one,$bot_access,$bot_access2) = undef;
our($cnam,$cposted,$cpwd,$ccolor,$cup,$ccount,$cnew_time,$cres_time,$cgold,$csoumoji,$csoutoukou,$cfontsize,$cfollow,$cview,$cnumber,$crireki,$ccut,$cmemo_time,$caccount,$cpass,$cdelres,$cnews,$cage,$cemail,$csecret) = undef;
our($chandle,$cmtrip,$base_server_domain) = undef;
our($topics_line_reshistory,$one_line_reshistory,$follow_line) = undef;
if($init){ $init_start = "init_start_${init}"; $start = "start_$init"; }
if($init2){ $init_start = "${init2}::init_start_${init}"; $start = "${init2}::start_$init"; }

	# �h���C����`
	if($server_domain2){ $server_domain = $server_domain2; }
	$base_server_domain = $base_server_domain2;

# �����e�Ȃ�
$mobile_test_mode = 0;

	# ��ݒ�f�B���N�g�����`
	if($init_directory){
		$int_dir = $init_directory;
	}
	else{
		($int_dir) = &Mebius::BaseInitDirectory("$type",$server_domain2);
	}

	# �����^�C�v���`
	if($type =~ /ALOCAL|Alocal-mode/){ $alocal_mode = 1; }


# �S�Ă̋��ʐݒ����荞��
our(%basic) = &init_defult($type);

# �������擾
our($date,$time,$thisyear,$thismonth,$today,$thishour,$thismin,$thissec,$thiswday,$thismonthf,$todayf,$thishourf,$thisminf,$thissecf
,$ymdf) = &Mebius::Getdate("Now-time");
our $thisyearf = $thisyear;

# ���ϐ��Ȃǂ��擾
our($moto,$realmoto,$addr,$agent,$cookie,$realcookie,$referer,$requri,$scriptname,$scriptdir,$selfurl,$selfurl_enc,%env) = &get_env_decode(undef,$type);
$realagent = $age = $agent;

# �N�b�L�[�Q�b�g�i�S�́j
our($cnam,$cposted,$cpwd,$ccolor,$cup,$ccount,$cnew_time,$cres_time,$cgold,$csoumoji,$csoutoukou,$cfontsize,$cfollow,$cview,$cnumber,$crireki,$ccut,$cmemo_time,$caccount,$cpass,$cdelres,$cnews,$cage,$cemail,$csecret,$cres_waitsecond,$caccount_link,$cimage_link,$cfillter_id,$cfillter_account,$chistory_open,$cdevice_type) = &get_cookie("Get-global");
our($chowold) = undef;

# �A�N�Z�X�^�C�v����
our($k_access,$kaccess_one,$bot_access,$device_type,$sikibetu,$agent,%device) = &Mebius::DeviceJudge("My-access");

# HTML�p�[�c���擾
our(%parts) = &Mebius::Parts::HTML("Get-parts HTML5",\%device);
our($checked,$selected,$disabled) = undef;
our $checked = $parts{'checked'};
our $selected = $parts{'selected'};
our $disabled = $parts{'disabled'};

# XIP���擾 ( ���ϐ��擾�̂��� )
our($xip,$xip_enc,$no_xip_action) = &get_xip($addr,$agent,$k_access);

# �f�R�[�h����
if($type !~ /Not-indecode/){ &indecode(); }

	# �A�J�E���g���A�Z�[�u�f�[�^���擾 ( ���o�C�� )
	if($kaccess_one){
		require "${int_dir}part_idcheck.pl";
		&call_savedata($kaccess_one,"MOBILE MYDATA",$k_access);
	}

	# �A�J�E���g���A�Z�[�u�f�[�^���擾 �i �A�J�E���g �j
	if($main::alocal_mode && $main::realagent =~ /Do|Emu/){ $main::cookie = 1; $caccount = "aaaa"; $cpass = "%2E01Szsln5xc"; }
	if($caccount && $cpass){
		require "${int_dir}part_idcheck.pl";
		my($plustype_account);
			if($type =~ /SNS-mode/){ $plustype_account .= qq( SNS-mode); }
		our(%myaccount) = &Mebius::Auth::File("Get-my-global Not-filecheck Option $plustype_account",$caccount,$cpass);
		&call_savedata($pmfile,"ACCOUNT MYDATA","");
	}

	# �N�b�L�[�̒��� ( �A�J�E���g�f�[�^�擾�̂��� )
	($chandle,$cmtrip) = split(/#/,$cnam);
	if($csecret eq "1" || $csecret eq "2"){ $csecret = undef; }
	$cnumber =~ s/\W//g;
	if(length($crireki) >= 5){ $crireki = undef; }
	if($crireki eq "2"){ $crireki = "off"; }
	if($k_access && !$cookie){ $chowold = 18; }
	elsif($cage){ $chowold = $thisyear - $cage; }

	# �߂��URL���擾
	if($referer || $in{'backurl'}){
		require "${int_dir}part_backurl.pl";
		&get_backurl("",$in{'backurl'});
	}


	# �v���O�����^�C�v���Ƃ̊�{�ݒ����荞��
	if($type !~ /Not-init-start/){
		if($init){ &$init_start(); } elsif(defined(&init_start)) { &init_start(); }
	}


	# �e��⑫�ݒ�
	if($ENV{'CONTENT_TYPE'} =~ /^multipart\/form-data;/ && $main::bbs{'concept'} !~ /Upload-mode/){ &error("���̃R���e���c�ł̓A�b�v���[�h�ł��܂���B"); }
	if($myadmin_flag >= 5 && $device_type eq "desktop" && !$mobile_test_mode){ $device_type = "both"; }
	if($device_type eq "mobile"){ $main::kflag = 1; }

	# ���[���F�؍ς݂��ۂ�
	if($cemail){ 
		my(%address) = &Mebius::MailAddress("Get-hash-detail",$cemail);
			if($address{'myaddress_flag'}){ our(%myaddress) = (%address); }
	}


# ���[�h��`
$mode = $in{'mode'};
($submode1,$submode2,$submode3,$submode4,$submode5) = split(/-/,$mode);

	# ���[�h��W�J
	foreach(split(/-/,$mode,-1)){
		$main::submode_num++;
	}

	# DOS�U�����`�F�b�N
	our(%mydos) = &Mebius::Dos::AccessFile("New-access Renew",$addr);

	# �X���b�V���Q�ȏ��URL�͐��K��
	if($main::requri =~ /\/\// && !$main::postflag){
		my $redirect_url = $main::requri;
		$redirect_url =~ s!/{2,}!/!g;
			if($main::bot_access){ &Mebius::AccessLog(undef,"Slash-url-bot"); }
			else{ &Mebius::AccessLog(undef,"Slash-url"); }
		&Mebius::Redirect("301","http://$main::server_domain$redirect_url");
	}


	# ����O���T�C�g����̖K��
	if($referer =~ /^http:\/\/(www\.)?(ime\.nu|ime\.st|xxx\.sameha\.info)\//){ require "${int_dir}part_enemysite.pl"; &from_enemysite(undef,$referer); }
	#if($main::alocal_mode){  require "${int_dir}part_enemysite.pl"; &from_enemysite(undef,"http://docalhost.jp/");  }

	# �X�^�[�g�O�̏���
	if(defined(&before_start)){ &before_start(); }

	# �����X�^�[�g
	if($init){ &$start(); } elsif(defined(&start)) { &start(); }

}

use strict;


#-----------------------------------------------------------
# ���ʂ̏����ݒ�
#-----------------------------------------------------------
sub init_defult{

# �錾
my($type) = @_;
my(%basic);
our($otherserver_link,$canonical,$body_javascript,$head_javascript);
our($backurl,$maxData,$no_headerset);
our($error_done,$headflag,$base_domain);
our($moto,$lock_dir,$k_access,$kaccess_one,$mente_mode,$alocal_mode,$int_dir,$server_domain);
our($script,%backup_directory);

# �o�b�N�A�b�v
our @backup_directory_number = ("1","15");
	foreach(@backup_directory_number){
			$backup_directory{$_} = "/var/www-backup$_/web_data/";
	}

# �����e / �e�X�g���[�h
$mente_mode = 0;
if($mente_mode){ require "${int_dir}part_mente.pl"; &all_mente(); } 
our $getaccess_mode = 0;

# ���e�X�g�b�v���[�h
our $stop_mode = "";

# �O���Ȃ������ݒ�
our $dirpms = 0707;
our $logpms = 0606;

	# �Ǘ����[�h��SSL�؂�ւ�
	if($type =~ /Admin-mode/ || $ENV{'REQUEST_URI'} =~ m!^/jak/!){
			if($server_domain eq ""){ $server_domain = "$ENV{'SERVER_NAME'}"; }
			if($ENV{'SERVER_PORT'} eq "80"){ $basic{'admin_http'} = "http"; }
			else{ $basic{'admin_http'} = "https"; }
	}
	else{
			if($server_domain eq ""){ our $server_domain = "aurasoul.mb2.jp"; }
			if($main::alocal_mode){ $basic{'admin_http'} = "http"; }
			else{ $basic{'admin_http'} = "https"; }
	}



our @server_addrs = ("112.78.200.216","112.78.200.218");

our $lock_dir = "${int_dir}_lock/";
our $jak_dir = "/var/www/$main::server_domain/public_html/jak/";

our $pct_dir = "/pct/";


if($script eq ""){ $script = "./"; }
our $lockkey = 1;

$basic{'base_domain'} = $base_domain = "mb2.jp";
our $home = "http://aurasoul.mb2.jp/";
$basic{'mailform'} = our $mailform = qq(<a href="http://aurasoul.mb2.jp/_main/mailform.html">���[���t�H�[��</a>);
$basic{'auth_url'} = our $auth_url = "http://sns.mb2.jp/";
our $paint_url = "/paint/";
our $paint_dir = "/var/www/$main::server_domain/public_html/paint/";

our $admin_mail = 'yuma@kvd.biglobe.ne.jp';
$basic{'admin_mail'} = $admin_mail;
$basic{'admin_mail_mobile'} = 'yuma-ice-cream@willcom.com';
our $mainscript = "/_main/";
our $gold_url = "/_gold/";

our @domains = ("aurasoul.mb2.jp","mb2.jp");
our @all_domains = ("aurasoul.mb2.jp","mb2.jp","sns.mb2.jp");

our $goraku_url = 'http://mb2.jp/';

	# ��h���C���Ē�`
	if($main::base_server_domain eq ""){
		$main::base_server_domain = $main::server_domain;
	}

	# ���C��URL�̕⑫
	if($main::server_domain eq $main::base_server_domain){
		$main::main_url = "http://$main::base_server_domain/_main/";
	}
	else{
		$main::main_url = "http://$main::base_server_domain/_main/";
	}

our $jak_url = "$basic{'admin_http'}://$main::base_server_domain/jak/";
our $jak_paint_url = "${jak_url}paint/";
	
our $door_url = "http://mb2.jp/_main/";
our $base_url = 'http://aurasoul.mb2.jp/';
our $home = $base_url;
our $guide_url = 'http://aurasoul.mb2.jp/wiki/guid/';
our $hometitle = "���r�E�X�����O�f����";

our @deny_words = ('pagead2','pub-','/jak/');

our $qst_url = "http://aurasoul.mb2.jp/_qst/";
our $delete_url = "http://aurasoul.mb2.jp/_delete/";

our $original_maker = qq(<a href="http://www.kent-web.com/" rel="nofollow">�z�z-WebPatio</a>);

# �Ǘ���(�}�X�^�[)��IP/�z�X�g��
#our $master_addr = "119.239.40.136";
our $master_addr = "119.238.251.29";
	if($master_addr eq $ENV{'REMOTE_ADDR'}){ $basic{'master_addr_flag'} = 1; }
our(@master_hosts);
push(@master_hosts,".osk.mesh.ad.jp");
push(@master_hosts,".rev.home.ne.jp");

	# ���[�J���ݒ�
	if($alocal_mode){
		$paint_dir = "${int_dir}../../htdocs/paint/";
		$lock_dir = "${int_dir}_lock/";
		#$jak_url = "/cgi-bin/patio/admin/";
		$jak_dir = "${int_dir}admin/";
		$jak_paint_url = "/paint/";
		$auth_url = "http://localhost/_auth/";
		$server_domain = "localhost";
		$jak_url = "$basic{'admin_http'}://$server_domain/jak/";
		push(@domains,"localhost");
		push(@all_domains,"localhost");
		$master_addr = "127.0.0.1";
		push(@master_hosts,"localhost",".localhost.jp","YUMA-PC");
			foreach(@backup_directory_number){
				$backup_directory{$_} = "${int_dir}bkup$_/";
			}

	}

# �T�[�o�[�̑S�̐�
$basic{'number_of_servers'} = 2;
$basic{'number_of_domains'} = 3;

return(%basic);


}

#-----------------------------------------------------------
# ���ϐ��̃`�F�b�N - strict
#-----------------------------------------------------------
sub get_env_decode{

# �錾
my($type,$basic_type) = @_;
my($moto,$realmoto,$addr,$agent,$cookie,$realcookie,$referer,$requri,$scriptname,$scriptdir,$selfurl,$selfurl_enc);
our($k_access,$mobile_test_mode,$host,$server_domain);

# ���ϐ����擾
$agent = $ENV{'HTTP_USER_AGENT'};
$cookie = $realcookie = $ENV{'HTTP_COOKIE'};
$addr = $ENV{'REMOTE_ADDR'};
$requri = $ENV{'REQUEST_URI'};
$referer = $ENV{'HTTP_REFERER'};
$scriptname = $scriptdir = $ENV{'SCRIPT_NAME'};

# ���ϐ��𐮌`
$scriptname =~ s/(.+?)([a-zA-Z0-9_]+)\.([a-zA-Z]{2,3})$/$2\.$3/g;
$scriptname =~ s/(\.\.|\/)//g;
if($moto eq ""){ $moto = $scriptname; $moto =~ s/(_|\.)([a-zA-Z0-9]+)//g; $realmoto = $moto; $moto =~ s/^sub//; }

if($referer){ ($referer) = ($referer); }
if($agent){ ($agent) = &Mebius::Escape("",$agent); }
($addr) = &Mebius::Escape("",$addr);
if($requri){ ($requri) = &Mebius::Escape("NOTAND",$requri); }

my(%env) = &Mebius::Env("Get-proxy-only");

	# �s���Ȃt�q�k���֎~
	if($requri =~ /(actbbs)/ && $basic_type !~ /Allow-natural-url/){ &Mebius::AccessLog(undef,"Actbbs-access"); &error("���̃y�[�W�͑��݂��܂���B"); }

	# ���T�[�o�[����̃A�N�Z�X���L�^
	foreach(@main::server_addrs){
		if($addr eq $_){ &Mebius::AccessLog(undef,"Server-self"); }
	}

	# ALOCAL_MODE �g�ђ[���̊��Ńe�X�g
	if($mobile_test_mode && ($main::alocal_mode || $main::bbs{'concept'} =~ /Local-mode/) ){
		$host = "proxy1105.docomo.ne.jp";
		$agent = "DoCoMo/2.0 F905i(c100;TB;W25555H17;ser000000000000001;icc8981100010362972847f)";
		$cookie = "";
	}

	# ���݂̂t�q�k���`
	if($server_domain && $requri){
		$selfurl = "http://$server_domain$requri";
		$selfurl_enc = &Mebius::Encode("",$selfurl);
	}

# ���^�[��
return($moto,$realmoto,$addr,$agent,$cookie,$realcookie,$referer,$requri,$scriptname,$scriptdir,$selfurl,$selfurl_enc,%env);

}


#-----------------------------------------------------------
# �f�R�[�h���� - strict
#-----------------------------------------------------------
sub indecode{

# �錾
my($buf,$new_query,@query,%query,$multi_part_flag);
our($maxData,$postbuf,$postbuf_query,$no_headerset);
our($postflag,$postbuf_query_esc,$upload_flag,$decpostbuf) = undef; #������
our(%in,%ch,%query_not_escaped) = undef; #������

# CGI.pm ���g�����ǂ���
my $UseCGI = 0;

	# �A�b�v���[�h�y���̏ꍇ
	if($ENV{'CONTENT_TYPE'} =~ /^multipart\/form-data;/){
		$multi_part_flag = 1;
		$UseCGI = 1;
	}

# CGI.pm �ɂ���ď����Ă��܂����e���t�b�N
our $content_length = $ENV{'CONTENT_LENGTH'};
our $query_string = $ENV{'QUERY_STRING'};

	# �f�[�^�ő�ʂ�ݒ�
	if($multi_part_flag){ $maxData = 5000000; }
	elsif($maxData <= 0){ $maxData = 150000; }

	# �f�[�^�󂯎��
	if($UseCGI){
		require "${main::int_dir}part_upload.pl";
		$new_query = new CGI;
	}

	# �f�[�^�󂯎��
	if($ENV{'REQUEST_METHOD'} eq "POST") {
			if(!$UseCGI){ read(STDIN, $new_query, $ENV{'CONTENT_LENGTH'}); }
		$postflag = 1;
			if($ENV{'CONTENT_LENGTH'} > $maxData) {
				$no_headerset = 1;
				&Mebius::Dos::AccessFile("New-access Renew",$ENV{'REMOTE_ADDR'});
				&error("���e�ʂ��傫�����܂��B $ENV{'CONTENT_LENGTH'} byte");
			}
	}
	else{
			if(!$UseCGI){ $new_query = $ENV{'QUERY_STRING'}; }
	}

	# CGI.pm ���g���ꍇ
	if($UseCGI){
			foreach($new_query->param()){
				$query{$_}= $new_query->param($_);
			}
	}
	# CGI.pm ���g��Ȃ��ꍇ
	else{
			foreach(split(/&/,$new_query)){
				my($key,$value) = split(/=/,$_);
				($query{$key}) = &Mebius::Decode(undef,$value);
			}

	}

	# �N�G���W�J
	foreach(keys %query){

		# �Ǐ���
		my $key = $_;
		my $val = $query{$_};

			# �A�b�v���[�h�t�@�C��������ꍇ
			if($multi_part_flag){
				if($key eq "upfile" && $val){ $upload_flag = 1; next; }
			}

		# �R�[�h�ϊ�
		&jcode::convert(*val, 'sjis');

			# ���� $postbuf
			if($decpostbuf){ $decpostbuf .= "&$key=" . $val; }
			else{ $decpostbuf .= "$key=" . $val; }

		# �G�X�P�[�v�O�̃N�G�����L������
		$query_not_escaped{$key} = $val;

		# �G�X�P�[�v
		my($value_escaped) = &Mebius::Escape("",$val);

		# �l���`
		#$in{$key} .= "\0" if (defined($in{$key}));
		$in{$key} .= $value_escaped;
		$ch{$key} = 1;
			if($postbuf){ $postbuf .= "&$key=" . (&Mebius::Encode("",$value_escaped)); }
			else{ $postbuf = "$key=" . (&Mebius::Encode("",$value_escaped)); }

	}

	# �N�G���S�̂̃G�X�P�[�v�l���` 
	$postbuf_query_esc = &Mebius::Escape("",$postbuf);

}

#-------------------------------------------------
#  HTML�w�b�_ - strict
#-------------------------------------------------
sub header{

# �錾
my($type,$intitle) = @_;
my($cssfile,$link_media_handheld,$css_fontsize,$now_url_box,$length,$meta_jump,$help_area,$google_header_form,$linkprof,%js_count,%css_count);
my($google_selected1,$bbs_google_find,$head_message1,$head_message2,$javascript_files,$css_files);
my($google_search_submit_title,$sorcial_line,$meta_tag_free);
our($backurl,$css_text,$thisis_bbstop,$agent,$scriptname,$home_title);
our($kflag,$headflag,$server_domain,$postflag,$google_oe,$now_url,$thisis_toppage,%in);
our($title,$mode,$time,$cookie,$cfollow,$ccount,$cfontsize,$csecret,$follow_line,$alocal_mode);
our($nosearch_mode,$no_headerset,$canonical,$referer,$sub_title,$idcheck,$pmfile,$myadmin_flag);
our($otherserver_link,$canonical,$body_javascript,$head_javascript,$meta_robots,$noindex_flag,$divide_url);
our($head_link0_25,$head_link0_5,$head_link1,$head_link1_25,$head_link1_5,$head_link2,$head_link2_5,$head_link3,$head_link4,$head_link5);
our($k_access,$postbuf,$k_access,$jump_url,$jump_sec,$device_type,$style);
our($thismonth,$thishour,$today,$meta_nocache,$main_mode,$int_dir,$moto,$requri,$concept,$auth_url,$bot_aceess);
our($guide_url,$door_url,$hometitle,$home,$topics_line_reshistory,$one_line_reshistory,$bot_access,@javascript_files,@css_files,$cnumber);

# �g�у��[�h�̏ꍇ
if($kflag || $device_type eq "mobile"){ &kheader(@_); return; }

	# �X�}�t�H�U�蕪��
	if($main::device{'smart_flag'}){
		$google_search_submit_title = qq(����);
	}
	else{
		$google_search_submit_title = qq(Google ����);
	}


# �^�C�g����`
if($intitle eq ""){ $intitle = $sub_title; }

# �w�b�_�̏d���������֎~
if($headflag){ return; }
$headflag = 1;

# ���e�������擾
require "${int_dir}part_history.pl";
($topics_line_reshistory,$one_line_reshistory) = &get_reshistory("TOPICS ONELINE My-file","","","","",10);

	# �t�H���[���擾
	if($cookie && ($cfollow || $ccount >= 2) ){
		require "${int_dir}part_follow.pl";
		($follow_line) = &get_follow("HEADER");
	}

# �T�[�o�[�؂�ւ������N
if($server_domain eq "mb2.jp"){ $otherserver_link = qq(<a href="http://aurasoul.mb2.jp/">�ʏ��</a>); }
else{ $otherserver_link = qq(<a href="http://mb2.jp/">��y��</a>); }

# �X�e�[�^�X�R�[�h���o��
if($type =~ /Status404/){ print "Status: 404 NotFound\n"; }

	# �N�b�L�[�������ꍇ��A����ꍇ�����m���ŁA�{�������ŃN�b�L�[���Z�b�g
	if((!$cookie || rand(5) < 1 || $alocal_mode) && !$no_headerset && !$postflag) {
			#if($cnumber eq ""){ ($cnumber) = &Mebius::Char(undef,10); }
		&main::set_cookie();
	}


# �����o���w�b�_
print "Content-type: text/html; charset=shift_jis\n";
if(!$postflag){
print "Pragma: no-cache\n";
print "Cache-Control: no-cache\n";
}
print "\n";

	# Canonical����
	if($canonical){ $canonical = qq(<link rel="canonical" href="$canonical">\n); }

	# �g�єő���
	if($divide_url){
		my($url);
		$url = $divide_url;
		$url =~ s/&/&amp;/g;
		$link_media_handheld = qq(<link rel="alternate" media="handheld" type="text/html" href="$url">\n);
	}

	# META ���{�b�g�^�O
	if($meta_robots eq ""){
			if($noindex_flag){ $meta_robots = qq(<meta name="robots" content="noindex,nofollow">\n); }
			else{ $meta_robots = qq(<meta name="robots" content="noarchive">\n); }
	}

	# �C�ӂ̃��^�^�O
	if($main::meta_tag_free){
		$meta_tag_free = $main::meta_tag_free;
	}

	# �X�}�t�H�U�蕪��
	if($main::device{'type'} eq "Smart-phone"){
		#$meta_tag_free .= qq(<meta name="viewport" content="width=320, initial-scale=1.0, user-scalable=yes, maximum-scale=2.0, minimum-scale=1.0, ">\n);
		$meta_tag_free .= qq(<meta name="viewport" content="width=device-width"$main::xclose>\n);
		$meta_tag_free .= qq(<meta name="format-detection" content="telephone=no"$main::xclose>\n);
	}
	# �^�u���b�gPC����
	elsif($main::device{'type'} eq "Tablet-pc"){
		$meta_tag_free .= qq(<meta name="viewport" content="width=device-width"$main::xclose>\n);
	}

	# �W�����v����ꍇ
	if($jump_url){
			if(!$jump_sec) { $jump_sec = "0"; }
		$meta_jump = qq(<meta http-equiv="refresh" content="${jump_sec};url=${jump_url}">\n);
	}

	# ��CSS�̒�`
	{
		# ��{�X�^�C��
		unshift(@css_files,"bas");

			# ��CSS���`
			if($style){
				$style =~ s!(\.\.)?/style/!!g;
				my($file,$tail) = split(/\./,$style);
				push(@css_files,$file);
			}

		# �X�}�t�H�����X�^�C��
		if($main::device{'smart_css_flag'}){ push(@css_files,"smart_phone"); }
		elsif($main::device{'type'} =~ /^(Tablet-pc|Portable-game-player)$/){ push(@css_files,"tablet"); }

		# �d������O��CSS�t�@�C�����폜 ( ���Ԃ�����ւ��? )
		#@css_files = grep( !$css_count{$_}++, @css_files ) ;

		# �O��CSS�t�@�C����W�J
		my $css_count;
		@css_files = grep( !$css_count{$_}++, @css_files );
			foreach(@css_files){
				$css_files .= qq(<link rel="stylesheet" href="/style/$_.css" type="text/css">\n);
			}

	}

	# �d������O��Javascript�t�@�C�����폜
	@javascript_files = grep( !$js_count{$_}++, @javascript_files ) ;

	# �O��Javascript�t�@�C����W�J
	foreach(@javascript_files){
		$javascript_files .= qq(<script type="text/javascript" src="/skin/$_.js"></script>\n);
	}

#<!DOCTYPE html>
#<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

#<meta http-equiv="content-style-type" content="text/css">
#<meta http-equiv="content-script-type" content="text/javascript">

print <<"EOM";
<!DOCTYPE html>
<html lang="ja">
<head>
<meta http-equiv="content-type" content="text/html; charset=shift_jis">
<title>$intitle</title>
$meta_robots$canonical$meta_jump$meta_nocache$meta_tag_free$link_media_handheld
$css_files
<script type="text/javascript" src="https://apis.google.com/js/plusone.js">
<!--
  {lang: 'ja', parsetags: 'explicit'}
//-->
</script>
$javascript_files
$head_javascript
EOM


	# COOKIE ����}�C�ݒ���擾
	if($cfontsize){ $css_fontsize = qq(body{font-size:$cfontsize%;}\n); }

	# IE6�ȑO�΍�
	#if($agent =~ /MSIE (7|6|5)/){
	#	$css_text .= qq(div.google_bar{float:left;padding:0em 0.2em 0.1em 0.5em;font-size:90%;background-color:#ccc;});
	#}

	# IE8 �Ή�
	if($agent =~ /MSIE 8/){
		$css_text .= qq(textarea.wide{width:750px;}\n);
		$css_text .= qq(.table1{margin-left:auto;margin-right:auto;}\n);
	}

	# Firefox CSS�Ή�
	if($agent =~ /Firefox/){
		$css_text .= qq(.body1{overflow:visible;});
	}


	# �C�ӂ̂b�r�r
	if($css_text || $cfontsize){
		$css_text =~ s/(\n{2,})/\n/g;
		$css_text =~ s/\t//g;
		print qq(<style type="text/css">\n);
		print qq(<!--\n);
		print qq($css_fontsize$css_text\n);
		print qq(-->\n);
		print qq(</style>\n);
	}


	# �C�ӂ�Javascript
	if($main::javascript_text){
		print qq(<script type="text/javascript">\n);
		print qq(<!--\n);
		print qq($main::javascript_text\n);
		print qq(-->\n);
		print qq(</script>\n);
	}

# BODY �����J�n
print qq(</head><body$body_javascript id="BODY_TOP">);

	# �Ǘ��҂ւ̕\�����e
	if($alocal_mode || ($main::bbs{'concept'} =~ /Local-mode/ && $myadmin_flag >= 5)){
		print qq(<div style="line-height:1.4;word-spacing:0.2em;">Time�F $time | Scriptname�F $scriptname);
		print qq(<br>Backurl�F $backurl | Referer�F $referer</div>);
	}

	# ���_�C���N�g��
	if($divide_url && $myadmin_flag >= 5){
		my $url = $divide_url;
		$url =~ s/&/&amp;/g;
		print qq(<div>Divide-Mobile�F <a href="$url">$url</a></div>);
	}


	# �f�����̌����Z���N�g�����A�����`�F�b�N������
	if($thisis_toppage || $nosearch_mode || $type =~ /Not-search-me/){ $google_selected1 = " selected"; }
	else{
		my($domain,$search_title);
			if($main::device{'smart_flag'}){ $search_title = "�R���e���c"; }
			else{ $search_title = $main::title; }
			if($server_domain eq "aurasoul.mb2.jp"){ $domain = "aurasoul.mb2.jp";}
			else{ $domain = "mb2.jp";}
		$bbs_google_find = qq(<option value="$domain/_$moto" selected>$search_title</option>);
	}

	# ������ւ̃����N
	if($csecret =~ /[a-z0-9]/){
		my($i);
			foreach(split(/ /,$csecret)){
					if($_ !~ /^([a-z0-9]{2,})$/){ next }
				$i++;
				my $title = qq($_);
					if($i < 2){ $title = qq(����� ( $_ )); } 
				$linkprof .= qq(<a href="http://aurasoul.mb2.jp/_sc$_/">$title</a> - );
			}
	}

	# �L�^
	if($csecret){
		&Mebius::AccessLog(undef,"CSECRET","�閧��Cookie �F $main::csecret");
	}

	# �}�C�y�[�W�ւ̃����N
	if($cookie){
			if($mode eq "my"){ $linkprof .= qq(�}�C�y�[�W - ); }
			else{ $linkprof .= qq(<a href="${main::main_url}?mode=my">�}�C�y�[�W</a> - ); }
		#\( <a href="${main::main_url}?mode=my#EDIT">�ݒ�</a> \)
	}

	# �}�C�A�J�E���g�ւ̃����N
	if($cookie){
			if($idcheck){ $linkprof .= qq(<a href="${auth_url}${pmfile}/">�A�J�E���g</a> - ); }
			else{ $linkprof .= qq(<a href="${auth_url}">���O�C��</a> - ); }
	}


	# �V�`���b�g��ւ̃����N
	if($idcheck && $time > $main::myaccount{'firsttime'} + 60*24*60*60){
		$linkprof .= qq(<a href="http://aurasoul.mb2.jp/chat/tmb3/mebichat.cgi">�`���b�g</a> - ); 
	}

# ��y�ŁA�ʏ�ł̐؂�ւ�
$linkprof .=  qq($otherserver_link - );

	# �Ǘ����[�h�ւ̃����N
	if($myadmin_flag >= 1){
		my($buf);
			if($postbuf && !$postflag){ $buf = "?$postbuf"; $buf =~ s/(&)?moto=([a-z0-9]+)//g; $buf =~ s/\?(&)/?/g; $buf =~ s/\?$//g; $buf =~ s/&/&amp;/g;  }
		$linkprof .= qq(<a href="$main::jak_url$moto.cgi$buf" class="red">�Ǘ�</a> - );
	}

# �ŏI�����N
$help_area = qq($linkprof<a href="$guide_url">�K�C�h</a>);

# Google������
$google_oe = qq(<input type="hidden" name="oe" value="Shift_JIS">);
	if($agent =~ /Firefox/){ $google_oe = undef; }



$google_header_form .= qq(
<form method="get" action="http://www.google.co.jp/search" class="nomargin">
<div class="google_bar">
<a href="http://www.google.co.jp/" rel="nofollow">
<img src="http://www.google.co.jp/logos/Logo_25wht.gif" class="google_img" alt="Google"></a>
<span class="vmiddle">
<select name="sitesearch" class="site_select">);

	# �X�}�t�H�U�蕪��
	if($main::device{'smart_flag'}){
		$google_header_form .= qq(<option value="mb2.jp"${google_selected1}>�T�C�g�S��</option>\n);
	}
	else{
		$google_header_form .= qq(<option value="mb2.jp"${google_selected1}>���r�E�X�����O</option>\n);
	}

$google_header_form .= qq(
$bbs_google_find
<option value="">�E�F�u�S��</option>
</select>
<input type="$main::parts{'input_type_search'}" name="q" size="31" maxlength="255" value="" class="ginp">
<input type="submit" name="btnG" value="$google_search_submit_title">
<input type="hidden" name="ie" value="Shift_JIS">
$google_oe
<input type="hidden" name="hl" value="ja">
<input type="hidden" name="domains" value="mb2.jp">
</span></div>
<div class="help_block">$help_area</div>
</form>
);




	# �w�b�_�����N���`
	{

			#if($backurl){ $head_link0_25 = qq(<a href="$backurl">�߂�</a> &gt; ); }

			# �����N�O
			if(!$head_link0_5){ $head_link0_5 = qq(<a href="$door_url">��</a>); }

			# �����N�P
			if($head_link1 eq "0"){ $head_link1 = ""; }
			elsif($head_link1 eq ""){ $head_link1 = qq(&gt; <a href="$home">$hometitle</a>); }

			# �����N�Q
			if($head_link2 eq "0"){ $head_link2 = ""; }
				elsif($head_link2 eq ""){
				if($thisis_bbstop){ $head_link2 = "&gt; $title"; }
				else{ $head_link2 = "&gt; <a href=\"http://$server_domain/_$moto/\">$title</a>"; }
			}

			# �t�q�k�\�����`
			if($requri || $now_url ne "" || $thisis_toppage){
				my($url);
					if($now_url){ $url = "http://${server_domain}/$now_url"; }
					elsif(length($requri) <= 20 || $requri !~ /&/){ $url = "http://${server_domain}$requri"; }
				$length = int(length($url)/2);
				if($length > 50){ $length = 50; }
				$now_url_box = qq(<input size="50" class="nowurl" style="width:${length}em;" type="text" value="$url" onclick="select()">);
			}
			else{ $now_url_box = qq(&nbsp;); }

			# ���e��������g�s�b�N�X��\��
			if($topics_line_reshistory && $type !~ /Simple-source/){
				$head_message2 .= qq(<div class="topics_line">$topics_line_reshistory</div>);
			}
			else{
				$head_message2 .= qq(<div class="topics_line_empty"></div>);
			}

			# �����̑��N������
			if($cookie || $k_access){
					if($thishour >= 5 && $thishour  <= 8){
				$head_message2 .= qq(<div style="text-align:center;width:85%;margin:0.5em auto 1.0em auto;font-size:90%;"><a href="http://aurasoul.mb2.jp/_early/">�`$thismonth��$today���A���N���ł����H�`</a></div>);
					}
			}


		#if(!$bot_access){
		#$head_message2 .= qq(<div style="text-align:center;width:85%;margin:0.5em auto 1.0em auto;clear:both;"><a href="https://gienkin.jrc.or.jp/">�`�����𑗂�\(���{��\�\\��\)</a></div>);
	#}

			# �\�[�V�����{�^��
			if($ENV{'REQUEST_METHOD'} eq "GET" && !$main::secret_mode && $type !~ /Not-sorcial-button/){
				# Twitter
				$sorcial_line .= qq(<a href="https://twitter.com/share" class="twitter-share-button" data-count="none" data-lang="ja">�c�C�[�g</a><script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>);
					# Google +1 �{�^��
					if(!$main::device{'smart_flag'}){
						#$sorcial_line .= qq(�@<g:plusone size="medium" count="false"></g:plusone>);
					}
			}
			else{
				$sorcial_line .= qq(<div class="url_box">$now_url_box</div>);
			}

		# �E�F�u�y�[�W�w�b�_�̈�̏o��
		print qq(<div class="bar">);
			# �f�X�N�g�b�v��
			if($main::device{'smart_flag'}){
				print qq(<div class="help_block">$help_area</div>);
			}
			else{
				print qq($google_header_form$follow_line);
			}
		print qq(
		<div class="head_bar">
		<div class="link_box"><nav>$head_link0_25 $head_link0_5 $head_link1 $head_link1_25 $head_link1_5 $head_link2 $head_link2_5 $head_link3 $head_link4 $head_link5</nav></div>
		<div class="url_box">$sorcial_line</div>
		</div>
		$head_message1
		);
		print qq(</div>$head_message2);

	}

	# ���`�p��DIV�^�O�������o��
	if($type =~ /Body-print/){ print qq(<div class="body1">); }

}

#-------------------------------------------------
#  HTML�t�b�^ - strict
#-------------------------------------------------
sub footer{

# �錾
my($type) = @_;
my($line,$allsearch_form);
our($original_maker,$footer_plus,$secret_mode,$kflag,$cgold,$csilver,$one_line_reshistory,$device_type);
our($myadmin_flag,$postbuf,$cookie,$alocal_mode);

	# �g�єł̏ꍇ
	if($kflag || $device_type eq "mobile"){ &kfooter(@_); return; }

	# ���`�p��DIV�^�O�������o��
	if($type =~ /Body-print/){ print qq(</div>); }

$line .= qq(<div class="footerlink clear">);
if($original_maker){ $line .= qq($original_maker��); }
$line .= qq(<a href="http://aurasoul.mb2.jp/">����-$main::base_domain</a>��);
$line .= qq(<a href="http://aurasoul.mb2.jp/wiki/guid/%A5%D7%A5%E9%A5%A4%A5%D0%A5%B7%A1%BC%A5%DD%A5%EA%A5%B7%A1%BC">�v���C�o�V�[�|���V�[</a>��);
	if(!$main::sns{'flag'}){ $line .= qq(<a href="${main::main_url}past.html">�ߋ����O</a>��); }
if(!$secret_mode){ $line .= qq(<a href="http://aurasoul.mb2.jp/_delete/">�폜�˗�</a>��); }
$line .= qq(<a href="http://aurasoul.mb2.jp/etc/amail.html">���₢���킹</a>);

	# ���݂̕\��
	if($cgold ne ""){
		$line .= qq(��<img src="/pct/icon/gold1.gif" alt="����" title="����" class="noborder">);
			if($cgold >= 0){ $line .= qq( $cgold); }
			else{ $line .= qq( <span class="blue">$cgold</span>); }
		$line .= qq( \( $main::server_domain \) );
	}


	# ��݂̕\��
	#if($csilver ne ""){
	#		if($csilver >= 0){ $line .= qq(��<a href="${main::main_url}ranksilver-p-1.html"><img src="/pct/icon/silver1.gif" alt="���" title="���" class="noborder"></a> $csilver); }
	#		else{ $line .= qq(��<a href="${main::main_url}ranksilver-p-1.html"><img src="/pct/icon/silver1.gif" alt="���" title="���" class="noborder"></a> <span class="blue">$csilver (�؋�)</span>); }
	#}

$line .= qq(\n</div>);


# �ǉ����郉�C��
if($footer_plus){ $line .= qq(<div class="footerlink clear">$footer_plus</div>); }


# �S�����{�b�N�X���擾
require "${main::int_dir}part_newlist.pl";
($allsearch_form) = &Mebius::Newlist::allsearch_form("FOTTER",$main::in{'word'},"","","FOOTER");
$line .= qq(<div class="allsearch_form_footer allwidth">$allsearch_form</div>);


	# ���e������\��
	if($one_line_reshistory){
		$line .= qq(
		<div class="footer_res_history">$one_line_reshistory</div>
		);
	}

	# �Ǘ��҂݂̂̕\��
	if($myadmin_flag >= 5 || $alocal_mode){

		$line .= qq(<div class="line-height-large">);
		$line .= qq(Postbuf: ) . &Mebius::Escape("",$postbuf);
		$line .= qq(<br><br>);

		# Cookie��\��
		$line .= qq(<div class="line-height">Cookie:<br$main::xclose>);
			foreach(split(/;/,$cookie)){
				my($escaped_line) = &Mebius::Escape(undef,$_);
				my($cookie_name,$cookie_body) = split(/=/,$escaped_line);
				$line .= qq(<span class="red">$cookie_name</span>=<span class="green">$cookie_body</span>;<br$main::xclose>);
			}
		$line .= qq(</div>);

			# ���t�@����\��
			if($main::referer){
				my $referer_escaped = &Mebius::Escape(undef,$main::referer);
				$line .= qq(<div style="margin-top:1em;color:purple;">Referer: <a href="$referer_escaped">$referer_escaped</a></div>);
			}

		# ENV��\��
		#$line .= qq(<div>);
		#my $i_env;
		#	foreach(keys %ENV){
		#		$i_env++;

		#			if($i_env % 2 == 0){ $line .= qq(<div style="background:#eee;">); }
		#			else{ $line .= qq(<div>); }

		#			if($_ =~ /^(HTTP_COOKIE)$/){ $line .= qq(<span class="red">$_</span>); }
		#			else{ $line .= qq($_); }

		#		my($escaped_line) = &Mebius::Escape(undef,$ENV{$_});
		#		$line .= qq( : $escaped_line);

		#			$line .= qq(</div>);
		#	}
		#$line .= qq(</div>);

		$line .= qq(</div>);

	}

	# �X�}�t�H�p
	if($main::device{'smart_flag'}){
		$line .= qq(<div class="align-right padding"><a href="#BODY_TOP">���y�[�W�ŏ㕔��</a></div>);
	}

	# �[���؂�ւ������N
	if($main::cookie && $main::device{'real_type'} =~ /^(Portable-game-player|Full-mobile-browser|Smart-phone)$/){
		$line .= qq(<div class="align-right padding"><a href="${main::main_url}?mode=my#EDIT">�}�C�y�[�W</a>�́u��ʃ^�C�v�v�̍��ڂŁA�\\�����[�h��؂�ւ����܂��B</div>);
	}

	# �\�[�V�����{�^���p

	# Google +1 �{�^���p
	#if(!$main::device{'smart_flag'}){
	#	$line .= qq(<script type="text/javascript">\n);
	#	$line .= qq(<!--\n);
	#	$line .= qq(gapi.plusone.go();\n);
	#	$line .= qq(// -->\n);
	#	$line .= qq(</script>\n);
	#}


# HTML �̏I��
$line .= qq(</body></html>);

if($type !~ /GET/){ print qq($line); }

# ���^�[��
return($line);

}

#-----------------------------------------------------------
# XIP ���擾 - strict
#-----------------------------------------------------------
sub get_xip{

# �錾
my($addr,$agent,$k_access) = @_;
my($xip,$xip_enc,$no_xip_action);

# �U�蕪��
if($k_access eq "DOCOMO" || $k_access eq "AU"){ $xip = $agent; }
elsif($k_access){ $no_xip_action = 1; $xip = $agent; }
else{ $xip = $addr; }

# �G���R�[�h
($xip_enc) = &Mebius::Encode("",$xip);

# ���^�[��
return($xip,$xip_enc,$no_xip_action);

}

#-----------------------------------------------------------
# �N�b�L�[�擾 - strict
#-----------------------------------------------------------
sub get_cookie{

# �錾
my($type,$cookie_name) = @_;
my(@cook,%cook);

	# �擾����N�b�L�[��I�ԁi�S�́����J�e�S���j
	if(!$cookie_name) { $cookie_name = "love_me_aura"; }

	# �Y��ID�����o��
	foreach( split(/;/,$ENV{'HTTP_COOKIE'}) ) {
		my($key,$val) = split(/=/);
		$key =~ s/\s//g;
		$cook{$key} = $val;
	}

	# �f�[�^��URL�f�R�[�h���ĕ���
	foreach ( split(/<>/, $cook{"$cookie_name"}) ) {
		s/%([0-9A-Fa-f][0-9A-Fa-f])/pack("H2", $1)/eg;
		($_) = &Mebius::Escape("NOTAND",$_);
		push(@cook,$_);
	}

# ���^�[������
return(@cook);

}


#-----------------------------------------------------------
# ��荞�ݏ��� ( ���̃T�u���[�`�����̏������s���鎞�́A���� $int_dir �̒l�͐ݒ肳��Ă��� )
#-----------------------------------------------------------
our($int_dir);	
sub repairform{ require "${int_dir}main_repairurl.pl"; &get_repairform(@_); }
sub error{ require "${int_dir}part_error.pl"; &do_error(@_); }
sub set_cookie{ require "${int_dir}part_setcookie.pl"; &part_setcookie(@_); }
sub redun{ require "${int_dir}part_redun.pl"; &do_redun(@_); }
sub divide{ require "${int_dir}part_divide.pl"; &do_divide(@_); }
sub get_status{ require "${int_dir}part_getstatus.pl"; &do_get_status(@_); }
sub kget_items{ require "${int_dir}k_header.pl"; &do_kget_items(@_); }
sub access_log{ require "${int_dir}part_accesslog.pl"; &do_access_log(@_); }
sub access_log2{ require "${int_dir}part_accesslog2.cgi"; &do_access_log2(@_); }
sub kerror { require "${int_dir}k_error.pl"; &do_kerror(@_); }
sub kheader{ require "${int_dir}k_header.pl"; &do_kheader(@_); }
sub kfooter{ require "${int_dir}k_header.pl"; &do_kfooter(@_); }
sub http404{ require "${int_dir}part_404.cgi"; &do_404(@_); }
sub axscheck{ require "${int_dir}part_axscheck.pl"; &do_axscheck(@_); }
sub id{ require "${int_dir}part_axscheck.pl"; &get_id(@_); }
sub trip{ require "${int_dir}part_axscheck.pl"; &get_trip(@_); }
sub lock{ require "${int_dir}part_axscheck.pl"; &do_lock(@_); }
sub unlock{ require "${int_dir}part_axscheck.pl"; &do_unlock(@_); }
sub backurl{ require "${int_dir}part_backurl.pl"; &get_backurl(@_); }
sub mail{ require "${int_dir}part_email.cgi"; &email(@_); }
sub oldremove{ require "${int_dir}part_files.pl"; &do_oldremove(@_); }
sub minsec{ require "${int_dir}part_timer.pl"; &do_minsec(@_); }


1;
