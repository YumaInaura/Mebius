
use strict;
#use Mebius::Basic;
use Mebius::Admin;
use Mebius::Server;
package Mebius;

#-----------------------------------------------------------
# �S�Ă̊�{�ƂȂ�ݒ�/���O�f�B���N�g�����`
#-----------------------------------------------------------
sub var_directory{

	# ���[�J���T�[�o�[
	if(Mebius::alocal_judge()){
		return("C:/");
	}
	# ���A���T�[�o�[
	else{
		return("/var/");
	}

}

#-----------------------------------------------------------
# �S�Ă̊�{�ƂȂ�ݒ�/���O�f�B���N�g�����`
#-----------------------------------------------------------
sub www_directory{

my($var_directory) = Mebius::var_directory();

	# ���[�J���T�[�o�[
	if(Mebius::alocal_judge()){
		return("${var_directory}Apache2.2/");
	}
	# ���A���T�[�o�[
	else{
		return("${var_directory}www/");
	}

}


#-----------------------------------------------------------
# �S�Ă̊�{�ƂȂ�ݒ�/���O�f�B���N�g�����`
# �T�u���[�`������ BasicInit�͐錾���Ȃ��A�������[�v�֎~�A�O�̂���
#-----------------------------------------------------------
sub base_init_directory{ BaseInitDirectory(@_); }
sub BaseInitDirectory{

my($www_directory) = Mebius::www_directory();
my($directory);

	# ���[�J���T�[�o�[
	if(Mebius::alocal_judge()){
		$directory = "${www_directory}web_data/";
	}
	# ���A���T�[�o�[
	else{
		$directory = "${www_directory}web_data/";
	}


$directory;

}

#-----------------------------------------------------------
# �S�Ă̊�{�ƂȂ�ݒ�/���O�f�B���N�g�����`
# �T�u���[�`������ BasicInit�͐錾���Ȃ��A�������[�v�֎~�A�O�̂���
#-----------------------------------------------------------
sub share_directory_path{

my($www_directory) = Mebius::www_directory();
my($directory);

	# ���[�J���T�[�o�[
	if(Mebius::alocal_judge()){
		$directory = "${www_directory}web_data/";
	}
	# ���A���T�[�o�[
	else{
		$directory = "/share/";
	}

$directory;

}


#-----------------------------------------------------------
# ��{�ݒ� ( �n�b�V�����t�@�����X )
# SSS => �S�Ă̏����ŃO���[�o���ϐ��ł͂Ȃ��A������̏������g���悤�ɂ�����
# SSS => ���[�v�֎~������ǉ�������
#-----------------------------------------------------------
sub basic_init{

# �錾
my(%self);
my($init_directory) = Mebius::BaseInitDirectory();
my $server = new Mebius::Server;

# Near State �i�Ăяo���j 2.30
my $StateName1 = "BasicInit";
my $StateKey1 = "Normal";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

# �e������擾
my($server_domain) = Mebius::server_domain();
my($server_url) = Mebius::server_url();
my($procotol_type) = Mebius::ProcotolType();

# �T�[�o�[�h���C��
$self{'server_domain'} = $server_domain;

# ��{�f�B���N�g��
$self{'init_directory'} = Mebius::BaseInitDirectory();

	if(Mebius::alocal_judge()){
		$self{'top_level_domain'} = $self{'top_domain'} = $server->http_host(); 
		$self{'bbs_domain'} = $server->http_host();
	} else {
		$self{'top_level_domain'} = $self{'top_domain'} = "mb2.jp"; 
		$self{'bbs_domain'} = "mb2.jp";
	}

$self{'top_domain_url'} = "http://$self{'top_domain'}/";

my($procotol) = Mebius::procotol_type();
$self{'css_and_js_file_url'} = "${procotol}://mb2.jp/";

	# ��h���C���Ē�`
	if($server_domain eq "sns.mb2.jp"){ $self{'base_server_domain'} = "aurasoul.mb2.jp"; }
	else{ $self{'base_server_domain'} = $server_domain; }

# ���ʃ��C���X�N���v�g��URL
$self{'main_url'} = $self{'this_server_main_script_url'} = "$server_url/_main/";

# �T�[�o�[�̐� ( ��Ƀ��_�C���N�g�Ɏg�� )
$self{'number_of_servers'} = 2;

# �h���C���̐� ( ��Ƀ��_�C���N�g�Ɏg�� )
$self{'number_of_domains'} = 3;

# �Ǘ��҂̃A�h���X
$self{'admin_email'} = 'souji.kuzunoha@gmail.com';
$self{'admin_email_mobile'} = 'souji.kuzunoha@gmail.com';

# �� �Œ�URL�n

# ���[���t�H�[���ւ̃����N
$self{'mailform_url'} = "${procotol_type}://aurasoul.mb2.jp/_main/mailform.html";
$self{'mailform_link'} = qq(<a href="$self{'mailform_url'}">���[���t�H�[��</a>);

# SNS��URL
#$self{'auth_url'} = "${procotol_type}://sns.mb2.jp/"; => SSL�Ή����o���Ă���ɂ���
$self{'auth_url'} = "http://sns.mb2.jp/";
$self{'auth_relative_url'} = "/";
$self{'guide_url'} = "http://aurasoul.mb2.jp/wiki/guid/";
$self{'report_bbs_url'} = "http://aurasoul.mb2.jp/_delete/";

# �Ǘ����[�h��SSL�؂�ւ�
($self{'admin_http'}) = Mebius::Admin::http_kind();

	# ���[�J���ł̈�Đݒ�
	if(Mebius::alocal_judge()){
		$self{'auth_url'} = "${procotol_type}://$ENV{'SERVER_ADDR'}/_auth/";
	}

# �Ǘ����[�hURL
($self{'admin_url'}) = Mebius::Admin::basic_url();
$self{'admin_main_url'} = "$self{'admin_url'}index.cgi";
$self{'admin_report_bbs_url'} = "$self{'admin_http'}://mb2.jp/jak/delete.cgi";

# �Ǘ��҂�IP�A�h���X
$self{'master_addr'} = "119.239.41.215";
	if($self{'master_addr'} eq $ENV{'REMOTE_ADDR'}){ $self{'master_addr_flag'} = 1; }

# �֎~�n��
$self{'deny_words'} = ['pagead','/jak/','partner-pub'];

# ����URL
# ����URL���`
$self{'allow_url'} = [
{ url => "(([a-z0-9]+)\.)?mb2\.jp" , Free => 1 , MyWebsite => 1 },
{ url => "mb2\.jp" , title=>"���r�E�X�����O" , Free => 1 , MyWebsite => 1 },
{ url => "mb2\.jp" , Free => 1 , MyWebsite => 1  },
{ url => "google\.co\.jp" , title => "Google�̌�������" },
{ url => "google\.com" },
{ url => "dic\.(search\.)?yahoo\.co\.jp" , title => "Yahoo! ����" },
{ url => "(search\.)?yahoo\.co\.jp" , title => "Yahoo! Japan" },
{ url => "bing\.com" , title => "Bing" },
{ url => "twitter\.com" , title => "Twitter" , Free => 1 },
{ url => "twtr\.jp" },
{ url => "line\.me" } ,
{ url => "(ja\.)?wikipedia\.org" , title => "Wikipedia" },
{ url => "youtube\.com" , title => "YouTube" },
{ url => "apple\.com",title => "Apple" },
{ url => "www\.nhk\.or\.jp" , title => "NHK�I�����C��" },
{ url => "nintendo\.co\.jp" },
{ url => "sony\.co\.jp" },
{ url => "sony\.jp" },
{ url => "konami\.jp" },
{ url => "namco\.co\.jp" },
];

$self{'paint_dir'} = "/var/www/$server_domain/public_html/paint/";
$self{'jak_directory'} = "/var/www/$server_domain/public_html/jak/";

	# ���[�J���ł̐ݒ�
	if(Mebius::alocal_judge()){
		$self{'css_and_js_file_url'} = "${procotol}://$ENV{'SERVER_ADDR'}/";
		push(@{$self{'allow_url'}},{ url => "localhost" });
		$self{'auth_relative_url'} = "/_auth/";
		$self{'paint_dir'} = "${init_directory}../htdocs/paint/";
		$self{'bbs_domain'} = $self{'top_level_domain'} =  "$ENV{'SERVER_ADDR'}";
		$self{'jak_directory'} = "${init_directory}../jak/";
	}

	# Near State �i�ۑ��j 2.30
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,\%self); }

return(\%self);

}

#-----------------------------------------------------------
# ���݂̃T�[�o�[�̃h���C�������擾����
#-----------------------------------------------------------
sub server_domain{

# �錾
my($type) = @_;
my($server_domain);

# ENV�����`
#$server_domain = $ENV{'HTTP_HOST'};
$server_domain = $ENV{'SERVER_NAME'};

# �O�̂��߂ɁA�|�[�g�ԍ��������폜
$server_domain =~ s/:(\d+)//g;

# �O�̂��߁A�S�ď������ɂ��Ă���
$server_domain = lc $server_domain;

	# �z�X�g���̏����`�F�b�N
	if(Mebius::alocal_judge()){
		#if($server_domain !~ /^(localhost)$/){ return(); }
	}
	else{
		if($server_domain !~ /^([a-z0-9\.\-]+)\.([a-z]{2,4})$/){ return(); }
	}


return($server_domain);

}



#-----------------------------------------------------------
# ���[�J������
#-----------------------------------------------------------
sub alocal_judge{

	# 1 �܂��� 0 ������Ԃ��A��ȏ�̕ϐ���Ԃ��Ȃ�
	#if($ENV{'SERVER_ADDR'} eq "127.0.0.1" && $ENV{'DOCUMENT_ROOT'} =~ /^C:/){ return(1); }
	if(($ENV{'SERVER_ADDR'} eq "127.0.0.1" || $ENV{'SERVER_ADDR'} =~ /^192\.168\.0\.[0-9]+$/ || $ENV{'HTTP_HOST'} eq "localhost") && $ENV{'DOCUMENT_ROOT'} =~ /^C:/){ return(1); }
	elsif($ENV{'SESSIONNAME'} eq "Console" && $ENV{'SYSTEMDRIVE'} eq "C:"){ return(1); }
	else{ return(); }

}

1;
