
use strict;
package Mebius;
use Mebius::Getstatus;

#-----------------------------------------------------------
# Not Found �G���[�y�[�W - strict
#-----------------------------------------------------------
sub ServerAlive{

# �錾
my($server_access_flag,$success_flag,$use_mode);
my($server_domain,$result_line);

# ���[�h�؂�ւ� ( �R�}���h���C�� / HTTP )
$use_mode = "command";

my($all_server_addrs) = Mebius::Server::all_server_addrs();

	# ���T�[�o�[����̃A�N�Z�X�̂݋��e
	foreach(@$all_server_addrs){
			if($main::addr eq $_){ $server_access_flag = 1; }
	}
	if(!$server_access_flag && $main::addr && !$main::alocal_mode && !$main::myadmin_flag){ main::error("���̋@\�\\�͎g���܂���B $main::addr"); }


	# ���z�X�g�����`
	if($use_mode eq "command"){
		$server_domain = $ARGV[0];
	}
	else{
		$server_domain = $ENV{'SERVER_NAME'};
	}
	if($server_domain eq ""){ main::error("���T�[�o�[�z�X�g������`�ł��܂���B"); }

	# �h���C����W�J
	foreach(@main::domains){

		# �Ǐ���
		my($success_flag,$get_status_url,@status);

		# �������g�͒��ׂȂ�
		if($_ eq $server_domain){ next; }

		# �擾����URL���`
		$get_status_url = "http://$_/";

		# �X�e�[�^�X���Q�b�g
		for(1..5){

			# �X�e�[�^�X���Q�b�g
			my($status) = Mebius::Getstatus("Command",$get_status_url);
			push(@status,$status);

			# ����
			if($status eq "200"){ $success_flag = 1; last; }
			else{ sleep(60); }

		}

		$result_line .= qq( / URL: $get_status_url Status: @status);

		# 200 OK ����x���Ԃ�Ȃ������ꍇ�A���[���𑗐M
		if(!$success_flag){
			Mebius::Email::send_email("To-master-mobile",undef,"$_ �T�[�o�[�ڑ��s��","$_ �̃T�[�o�[�ɏ�肭�q����Ȃ������悤�ł��B $main::date ");
		}

		# ���������ꍇ
		else{
			Mebius::Email::send_email("To-master",undef,"$_ �T�[�o�[�ڑ���","$_ �̃T�[�o�[�ɏ�肭�q�������悤�ł��B");
		}

		# ���O���L�^
		Mebius::AccessLog(undef,"Server-Alive","$result_line");

	}


	# HTML
	if($use_mode ne "command"){ print "Content-type:text/html\n\n"; }

	# �o��
	print qq(Server alive check was done $result_line);

exit;

}

1;
