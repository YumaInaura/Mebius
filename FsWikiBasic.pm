
use strict;
use Mebius::Basic;

#-----------------------------------------------------------
# BEGIN �u���b�N
#-----------------------------------------------------------
BEGIN {

# Perl ���C�u������ǉ�
my($init_directory) = Mebius::BaseInitDirectory();

	if(Mebius::alocal_judge()){
		push @INC, "C:/Apache2.2/web_data/_fswiki/lib";
	}
	else{
		push @INC, "/var/www/web_data/_fswiki/lib";
	}



}

#-----------------------------------------------------------
# ���W���[���ǂݍ���
#-----------------------------------------------------------

use Cwd;
use Wiki;
use Util;
use Jcode;
use HTML::Template;
use CGI::Session;
package Mebius::FsWiki;

#-----------------------------------------------------------
# ���r�E�X�֌W�̊�{����
#-----------------------------------------------------------
sub Basic{

my($type,$wiki_name) = @_;

	# �J�����g�f�B���N�g����ύX
	#if($ENV{'MOD_PERL'}){
	#	chdir("/var/www/aurasoul.mb2.jp/public_html/wik/$wiki_name");
	#}

my($base_init_directory) = Mebius::BaseInitDirectory();	

# ���r�E�X�p�o�R�[�g
main::decode("Use-CGI.pm Not-indecode",$base_init_directory);

	# ���N�G�X�g���\�b�h�ɂ���ē��e����
	if($ENV{'REQUEST_METHOD'} eq "POST"){
		main::axscheck();
	}

}

#-----------------------------------------------------------
# �X�C�b�`
#-----------------------------------------------------------

package Mebius::FsWiki::Switch;

# �e�y�[�W�ւ̃����N�ɋ���URL����
sub PageName{ return(""); }

# ���r�E�X�ł̊Ǘ��҂̂݃��O�C���o����悤�ɂ��邩�ǂ����iSNS�A�J�E���g�Ŕ���j
sub AdminLoginOnly{ return(1); }

# �����@�\���g�����ǂ��� (���̓����N�\���̗L��������ύX��)
sub UseDiff{ return(1); }

# �y�[�W�̃\�[�X�\���@�\���g�����ǂ��� (���̓����N�\���̗L��������ύX��)
sub UseSource{ return(0); }

package Mebius::FsWiki;

#-----------------------------------------------------------
# ���W���[���̃C���N���[�h
#-----------------------------------------------------------
sub Start{

#use lib 'C:\Apache2.2\web_data\_fswiki_module\lib';
#use lib "${init_directory}_fswiki/lib";
#push @INC, "${init_directory}_fswiki/lib";

# ModPerl::Registry(Prefork)�ł�@INC������������Ă���ꍇ������
#push @INC, "${init_directory}_fswiki/lib" if(exists $ENV{MOD_PERL});

#die("Perl Die! @INC");
#use CGI::Carp qw(fatalsToBrowser);
#use CGI2;
#use Cwd;
#use Wiki;
#use Util;
#use Jcode;
#use HTML::Template;
#use CGI::Session;

	# ��������Ȃ���Apache::Registory�œ����Ȃ�
	if(exists $ENV{MOD_PERL}){
		eval("use Digest::Perl::MD5;");
		#eval("use Wiki::MD5");
		eval("use plugin::core::Diff;");
		eval("use plugin::pdf::PDFMaker;");
		Jcode::load_module("Jcode::Unicode") unless $Jcode::USE_ENCODE;

	}

#==============================================================================
# CGI��Wiki�̃C���X�^���X��
#==============================================================================
my $wiki = Wiki->new('setup.dat');
my $cgi = $wiki->get_CGI();

Util::override_die();
eval {
	# Session�p�f�B���N�g����Farm�ł����ʂɎg�p����
	$wiki->config('session_dir',$wiki->config('log_dir'));
	
	#==============================================================================
	# Farm�Ƃ��ē��삷��ꍇ
	#==============================================================================
	my $path_info  = $cgi->path_info();
	my $path_count = 0;
	if(length($path_info) > 0){
		# Farm�����邩�m�F����
		unless($path_info =~ m<^(/[A-Za-z0-9]+)*/?$> and -d $wiki->config('data_dir').$path_info){
			CORE::die("Perl Die! Wiki�����݂��܂���B");
		}
		
		# PATH_INFO�̍Ōオ/��������/�Ȃ���URL�ɓ]������
		if($path_info =~ m|/$|) {
			$path_info =~ s|/$||;
			$wiki->redirectURL($cgi->url().$path_info);
		}
		$path_info =~ m</([^/]+)$>;
		$wiki->config('script_name', $1);
		$wiki->config('data_dir'   , $wiki->config('data_dir'  ).$path_info);
		$wiki->config('config_dir' , $wiki->config('config_dir').$path_info);
		$wiki->config('backup_dir' , $wiki->config('backup_dir').$path_info);
		$wiki->config('log_dir'    , $wiki->config('log_dir'   ).$path_info);

		if(!($wiki->config('theme_uri') =~ /^(\/|http:|https:|ftp:)/)){
			my @paths = split(/\//,$path_info);
			$path_count = $#paths;
			for(my $i=0;$i<$path_count;$i++){
				$wiki->config('theme_uri','../'.$wiki->config('theme_uri'));
			}
		}
	}

	#==============================================================================
	# �ݒ�𔽉f�i����������ƃX�}�[�g�ɂ�肽���ˁj
	#==============================================================================
	my $config = &Util::load_config_hash($wiki,$wiki->config('config_file'));
	foreach my $key (keys(%$config)){
		$wiki->config($key,$config->{$key});
	}
	# �ʂɐݒ肪�K�v�Ȃ��̂����㏑��
	$wiki->config('css',
		$wiki->config('theme_uri')."/".$config->{theme}."/".$config->{theme}.".css");
	$wiki->config('site_tmpl',
		$wiki->config('tmpl_dir')."/site/".$config->{site_tmpl_theme}."/".$config->{site_tmpl_theme}.".tmpl");
	$wiki->config('site_handyphone_tmpl',
		$wiki->config('tmpl_dir')."/site/".$config->{site_tmpl_theme}."/".$config->{site_tmpl_theme}."_handyphone.tmpl");

	#==============================================================================
	# �^�C���A�E�g���Ă���Z�b�V������j��
	#==============================================================================
	$cgi->remove_session($wiki);

	#==============================================================================
	# ���[�U���̓ǂݍ���
	#==============================================================================
	my $users = &Util::load_config_hash($wiki,$wiki->config('userdat_file'));
	foreach my $id (keys(%$users)){
		my ($pass,$type) = split(/\t/,$users->{$id});
		$wiki->add_user($id,$pass,$type);
	}

	#==============================================================================
	# �v���O�C���̃C���X�g�[���Ə�����
	#==============================================================================
	my @plugins = split(/\n/,&Util::load_config_text($wiki,$wiki->config('plugin_file')));
	my $plugin_error = '';
	foreach(sort(@plugins)){
		$plugin_error .= $wiki->install_plugin($_);
	}
	# �v���O�C�����Ƃ̏������������N��
	$wiki->do_hook("initialize");

	#==============================================================================
	# �A�N�V�����n���h���̌Ăяo��
	#==============================================================================
	my $action  = $cgi->param("action");
	my $content = $wiki->call_handler($action);

	# �v���O�C���̃C���X�g�[���Ɏ��s�����ꍇ
	$content = $plugin_error . $content if $plugin_error ne '';

	#==============================================================================
	# ���X�|���X
	#==============================================================================
	my $output        = "";
	my $is_handyphone = &Util::handyphone();
	my $template_name = "";

	if ($is_handyphone) {
		$template_name = 'site_handyphone_tmpl';
	} else {
		$template_name = 'site_tmpl';
	}

	# �g�b�v�y�[�W���ǂ����𔻒�
	my $top  = 0;
	if($cgi->param("page") eq $wiki->config("frontpage")){
		$top = 1;
	}

	# �y�[�W�̃^�C�g��������
	my $title = "";
	if($cgi->param('action') eq "" && $wiki->page_exists($cgi->param('page')) && $wiki->is_installed('search')){
		#$title = "<a href=\"".$wiki->create_url({action=>"SEARCH",word=>$wiki->get_title()})."\">".
		#       &Util::escapeHTML($wiki->get_title())."</a>";
		$title = &Util::escapeHTML($wiki->get_title());

	} else {
		$title = &Util::escapeHTML($wiki->get_title());
	}

	#------------------------------------------------------------------------------
	# �w�b�_�̐���
	#------------------------------------------------------------------------------
	my $header_tmpl = HTML::Template->new(filename => $wiki->config('tmpl_dir')."/header.tmpl",
	                                      die_on_bad_params => 0,
	                                      case_sensitive    => 1);
	# ���j���[���擾
	my @menu = ();
	foreach(sort {$b->{weight}<=>$a->{weight}} @{$wiki->{menu}}){
		if($_->{href} ne ""){
			push(@menu,$_);
		}
	}
	$header_tmpl->param(MENU       => \@menu,
	                    FRONT_PAGE => $top);
	my $header = $header_tmpl->output();

	#------------------------------------------------------------------------------
	# �t�b�^�̐���
	#------------------------------------------------------------------------------
	my $footer_tmpl = HTML::Template->new(filename => $wiki->config('tmpl_dir')."/footer.tmpl",
	                                      die_on_bad_params => 0,
	                                      case_sensitive    => 1);

	# �R�s�[���C�g��\�����邩�ǂ���
	my $admin_name = $wiki->config('admin_name');
	my $admin_mail = $wiki->config('admin_mail_pub');
	my $out_copyright  = 1;
	if($admin_name eq ""){ $admin_name = $admin_mail; }
	if($admin_name eq "" && $admin_mail eq ""){ $out_copyright = 0; }

	$footer_tmpl->param(ADMIN_NAME    => $admin_name,
	                    ADMIN_MAIL    => $admin_mail,
	                    OUT_COPYRIGHT => $out_copyright,
	                    FRONT_PAGE    => $top,
	                    VERSION       => Wiki->VERSION,
	                    PERL_VERSION  => $]);

	if(exists $ENV{MOD_PERL}){
		$footer_tmpl->param(MOD_PERL=>$ENV{MOD_PERL});
	}

	my $footer = $footer_tmpl->output();

	#------------------------------------------------------------------------------
	# �T�C�g�e���v���[�g�̏���
	#------------------------------------------------------------------------------
	# �e���v���[�g�̓ǂݍ���
	my $template = HTML::Template->new(filename => $wiki->config($template_name),
	                                   die_on_bad_params => 0,
	                                   case_sensitive    => 1);

	# �Q�ƌ��������邩�ǂ���
	my $can_show = 0;
	if($action ne '' || ($action eq '' && $wiki->can_show($cgi->param('page')))){
		$can_show = 1;
	}

	# head�^�O���ɕ\����������쐬
	my $head_info = "";
	foreach (@{$wiki->{'head_info'}}){
		$head_info .= $_."\n";
	}

	# �e���v���[�g�Ƀp�����[�^���Z�b�g
	$template->param(SITE_TITLE  => &Util::escapeHTML($wiki->get_title()." - ".$wiki->config('site_title')),
	                 MENU        => $header,
	                 TITLE       => $title,
	                 CONTENT     => $content,
	                 FRONT_PAGE  => $top,
	                 FOOTER      => $footer,
	                 EDIT_MODE   => $action,
	                 CAN_SHOW    => $can_show,
	                 HEAD_INFO   => $head_info,
	                 SITE_NAME   => $wiki->config('site_title'));

	my $login = $wiki->get_login_info();
	$template->param(
		IS_ADMIN => defined($login) && $login->{type}==0,
		IS_LOGIN => defined($login)
	);

	if ($is_handyphone) {
		# �g�ѓd�b�p����
		$output = $template->output;
		&Jcode::convert(\$output,"sjis");
	} else {
		# �p�\�R���p����
		my $usercss = &Util::load_config_text($wiki,$wiki->config('usercss_file'));
		
		if($config->{'theme'} eq ''){
			# �e�[�}���g�p����Ă��炸�A�O��CSS���w�肳��Ă���ꍇ�͂�����g�p
			if($config->{'outer_css'} ne ''){
				$wiki->config('css',$config->{'outer_css'});
			# �e�[�}���O��CSS���w�肳��Ă��Ȃ��ꍇ�̓X�^�C���V�[�g���g�p���Ȃ�
			} else {
				$wiki->config('css','');
			}
		}
		# �p�����[�^���Z�b�g
		$template->param(HAVE_USER_CSS => $usercss ne "",
		                 THEME_CSS     => $wiki->config('css'),
		                 USER_CSS      => &Util::escapeHTML($usercss),
		                 THEME_URI     => $wiki->config('theme_uri'));
		
		# �y�[�W����EXIST_PAGE_�y�[�W���Ƃ����p�����[�^�ɃZ�b�g
		# �������A�X���b�V�����܂ރy�[�W���̓Z�b�g���Ȃ�
		my @pagelist = $wiki->get_page_list();
		foreach my $page (@pagelist){
			if(index($page,"/")==-1 && $wiki->can_show($page)){
				$template->param("EXIST_PAGE_".$page=>1);
			}
		}
		
		$output = $template->output;
		
		# �C���N���[�h����
		# <!--FSWIKI_INCLUDE PAGE="�y�[�W��"-->
		# �y�[�W����WikiName���w�肷��B
		my $fswiki_include_tag = '<!--\s*FSWIKI_INCLUDE\s+PAGE\s*=\s*"([^"]*)"\s*-->';
		while($output =~ /$fswiki_include_tag/o){
			if($wiki->page_exists($1) && $wiki->can_show($1)){
				$output =~ s/$fswiki_include_tag/$wiki->process_wiki($wiki->get_page($1))/oe;
			} else {
				$output =~ s/$fswiki_include_tag//o;
			}
		}
	}
	
	#------------------------------------------------------------------------------
	# �o�͏���
	#------------------------------------------------------------------------------
	# �w�b�_�̏o��
	if($is_handyphone){
		print "Content-Type: text/html;charset=Shift_JIS\n";
	} else {
		print "Content-Type: text/html;charset=EUC-JP\n";
	}
	print "Pragma: no-cache\n";
	print "Cache-Control: no-cache\n\n";
	 
	# HTML�̏o��
	print $output;
};

my $msg = $@;
$ENV{'PATH_INFO'} = undef;
$wiki->_process_before_exit();

if($msg && index($msg, 'safe_die')<0){
	$msg = Util::escapeHTML($msg);
	print "Content-Type: text/html\n\n";
	print "<html><head><title>Software Error</title></head>";
	print "<body><h1>Software Error:</h1><p>";
	if(Mebius::alocal_judge()){ print "<strong>Alocal View :</strong> $msg"; }
	print "</p></body></html>";
	Mebius::AccessLog(undef,"Fswiki-software-error",$msg);
}
Util::restore_die();


}




1;
