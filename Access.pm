
use strict;
use Mebius::HTML;
package Mebius;

#-----------------------------------------------------------
# �v���N�V���� ( �e�X�g�� )
#-----------------------------------------------------------
sub ProxyJudge{

# �錾
my($type) = @_;
my($proxy_flag);

	if($ENV{'HTTP_ACCEPT'}){}
	if($ENV{'HTTP_ACCEPT_LANGUAGE'}){}
	if($ENV{'HTTP_ACCEPT_CHARSET'}){}
	if($ENV{'HTTP_ACCEPT_ENCODING'}){} #gzip,deflate,sdch

return($proxy_flag);

}

#-----------------------------------------------------------
# �������g���ǂ����𔻒肷��
#-----------------------------------------------------------
sub MyAccessCheck{

# �錾
my($type,$account,$host,$cnumber,$agent) = @_;
my($my_access_flag);

	# ����
	if($account && $account eq $main::myaccount{'file'}){ $my_access_flag = 1; }
	if($host && $host eq $main::host){ $my_access_flag = 1; }
	if($cnumber && $cnumber eq $main::cnumber){ $my_access_flag = 1; }
	if($agent && $agent eq $main::agent){ $my_access_flag = 1; }

return($my_access_flag);

}


#-----------------------------------------------------------
# ���O�C���`�F�b�N
#-----------------------------------------------------------
sub LoginedCheck{

# �錾
my($type) = @_;
my($message);

	# ���O�C�����Ă��Ȃ��ꍇ
	if(!$main::myaccount{'file'}){
			if($main::postflag){
				$message = qq(���̑�������s����ɂ́A�A�J�E���g��<a href="${main::auth_url}">���O�C��</a>���Ă��������B);
			}
			else{
				$message = qq(���̃y�[�W�𗘗p����ɂ́A�A�J�E���g��<a href="${main::auth_url}?backurl=$main::selfurl_enc">���O�C��</a>���Ă��������B);
			}
	}

	# �G���[�������o���ꍇ
	if($type =~ /Error-view/ && $message){
		main::error("$message");
	}

return($message);

}


#-----------------------------------------------------------
# ���ϐ����擾
#-----------------------------------------------------------
sub Env{

# �錾
my($type) = @_;
my(%env);

	# �v���N�V�֘A�̃f�[�^���擾
	if($type =~ /Get-proxy/){

		$env{'forwarded_for'} = $ENV{'FORWARDED_FOR'};			#	squid�Ȃǂ�Cache�T�[�o�[���g���Ă�ꍇ�Ɂc
		#$env{'http_cache_control'} = $ENV{'HTTP_CACHE_CONTROL'};		#	�L���b�V������Œ����ԂȂ�
		$env{'http_cache_info'} = $ENV{'HTTP_CACHE_INFO'};		#	�L���b�V���̏��
		$env{'client_ip'} = $ENV{'HTTP_CLIENT_IP'};	#	�ڑ�����IP�A�h���X
		#$env{'connection'} = $ENV{'HTTP_CONNECTION'};		#keep-alive;	�ڑ��̏��
		$env{'http_forwarded'} = $ENV{'HTTP_FORWARDED'};			#	�v���L�V�܂��̓N���C�A���g�̏ꏊ
		#$env{'http_pragma'} = $ENV{'HTTP_PRAGMA'};			#	�v���L�V�̃L���b�V���Ɋւ��铮�����
		$env{'http_proxy_connection'} = $ENV{'HTTP_PROXY_CONNECTION'};	#	�v���L�V�̐ڑ��`��
		$env{'http_sp_host'} = $ENV{'HTTP_SP_HOST'};		#	�ڑ�����IP�A�h���X
		$env{'http_te'} = $ENV{'HTTP_TE'};			#	�v���L�V�����T�|�[�g����Transfer-Encodings
		$env{'http_via'} = $ENV{'HTTP_VIA'};			#	�v���L�V�̏��i�v���L�V�̎�ށC�o�[�W�������j
		$env{'proxy_connection'} = $ENV{'PROXY_CONNECTION'};		#	�v���L�V�̌��ʂȂǂ�\��
		$env{'http_x_forwarded_for'} = $ENV{'HTTP_X_FORWARDED_FOR'};		#

	}

	# ���ʂ̊��ϐ����擾 (����`)
	#if($type =~ /Get-env/ && $type !~ /Get-proxy-only/){
	#
	#}

	# �n�b�V����W�J
	foreach ( keys %env ){
		if($env{$_} eq ""){ next; }
		$env{'all_data'} .= qq($_ => $env{$_} ; );
		$env{'num'}++;
	}

return(%env);

}

#-----------------------------------------------------------
# �O���T�C�g����̖K��
#-----------------------------------------------------------
sub FromOtherSite{

# �錾
my($type) = @_;
my(%other_site,$other_handler,@renew_line);
my($share_directory) = Mebius::share_directory_path();

my $directory1 = "${share_directory}_ip/";
my $file = "${directory1}from_other_site.log";

# �t�@�C�����J��
open($other_handler,"<$file");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($other_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$other_handler>);
chomp(my $top2 = <$other_handler>);
($other_site{'key'}) = split(/<>/,$top1);
($other_site{'regist_count'},$other_site{'regist_count_ymd'}) = split(/<>/,$top2);

	# �n�b�V������

	# �����ς���Ă���ꍇ�A
	if($other_site{'regist_count_ymd'} ne "$main::thisyearf-$main::thismonthf-$main::todayf"){
		$other_site{'regist_count'} = 0;
	}

	# �����̊O���o�R�̏������݂���������ꍇ
	if($other_site{'regist_count'} >= 500){
		$other_site{'error_flag'} = qq(�����͂����������߂܂���B);
	}

close($other_handler);

	# �O���o�R�̃��[�U�[���A���炩�̍X�V�������Ȃ����ꍇ
	if($type =~ /New-regist/){

		$other_site{'regist_count'} += 1;
		$other_site{'regist_count_ymd'} = "$main::thisyearf-$main::thismonthf-$main::todayf";

			# �Ǘ��҂Ƀ��[��
			if($other_site{'regist_count'} % 25 == 0){
				Mebius::Email::send_email("To-admin",undef,"�O���o�R�̓��e�� $other_site{'regist_count'} �ɒB���܂����B");
			}

			# �Ǘ��Ҍg�тɃ��[��
			#if($other_site{'regist_count'} % 50 == 0){
			#	Mebius::Email::send_email("To-admin-mobile",undef,"�O���o�R�̓��e�� $other_site{'regist_count'} �ɒB���܂����B");
			#}

	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);

		# �Ǐ���
		my(@top_data);

		# �g�b�v�f�[�^��ǉ�
		push(@top_data,"$other_site{'key'}<>\n");
		push(@top_data,"$other_site{'regist_count'}<>$other_site{'regist_count_ymd'}<>\n");
		unshift(@renew_line,@top_data);

		Mebius::Fileout(undef,$file,@renew_line);
	}
	

return(%other_site);

}



1;

