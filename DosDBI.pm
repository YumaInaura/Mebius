
use strict;
use Mebius::HTML;
use Mebius::DBI;
package Mebius::Dos;
use base qw(Mebius::Base::DBI);

#-----------------------------------------------------------
# �e�[�u����
#-----------------------------------------------------------
sub main_table_name{

my($my_addr) = my_addr();

#$my_addr =~ s/^(\d+)\.(.+?)$/$1/g;
#"dos-$my_addr";

"dos";

}

#-----------------------------------------------------------
# �ݒ�
#-----------------------------------------------------------
sub init{

my(%self);

$self{'table_name'} = main_table_name() || die("can't init table name.");

\%self;

}

#-----------------------------------------------------------
# ������IP�A�h���X
#-----------------------------------------------------------
sub my_addr{

my $self;

	if(Mebius::alocal_judge()){ $self = "127.0.0.1"; } else { $self = $ENV{'REMOTE_ADDR'}; }

$self;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $set = {
	addr => { PRIMARY => 1 } , 
	access_count_temporary => { int => 1 , default => 1 } , 
	access_start_time_temporary => { int => 1 } , 
	access_count_per_term => { int => 1 , default => 1 } , 
	access_count_per_term_start_time => { int => 1 } , 
	dos_count => { int => 1 , default => 0 } , 
	dos_count_start_time => { int => 1 } , 
	last_update_time => { int => 1 }
};

$set;

}

#-----------------------------------------------------------
# DBI�e�[�u�����쐬
#-----------------------------------------------------------
sub create_main_table{

my($init) = init();
my($main_table_name) = main_table_name() || die;

my $set = main_table_column();

Mebius::DBI->create_memory_table(undef,$main_table_name,$set);

}


#-----------------------------------------------------------
# ���[�U�[����̃A�N�Z�X�����������Ƃ��̏���
#-----------------------------------------------------------
sub access{

my $package = __PACKAGE__;
my($dbh) = Mebius::DBI->connect();
my($init) = init();
my($main_table_name) = main_table_name();
my($my_addr) = my_addr();
my $time = time;
my($deny_access_flag);

# ���b�ɉ���A�N�Z�X������΁ADOS�A�^�b�N�Ƃ��ċL�^���邩�H
my $dos_count_border = 20;	# �A�N�Z�X��
my $access_count_reset_second = 10;	# �b

# DOS�U���̐ݒ�
#my $dos_alert_border = 3;
my $dos_count_deny_access_num = 10;
#my $verify_max = 3;

# �P��������̍ő呍�A�N�Z�X���̐ݒ�
#my $all_access_htaccess_border = 3*60*60;
#my $all_access_alert_border = $all_access_htaccess_border * 0.90;

# �A�����N�G�X�g�̐ݒ�
#my $redun_request_htaccess_border = 180;
#my $redun_request_alert_border = $redun_request_htaccess_border * 0.90;

	# ���[�J���ݒ�
	if(Mebius::alocal_judge() && 0){
		#$dos_count_border = 1;
		$access_count_reset_second = 1;
		#$all_access_htaccess_border = 20;
		#$all_access_alert_border = 10;
		#$redun_request_htaccess_border = 6;
		#$redun_request_alert_border = 3;
	}

	if(Mebius::alocal_judge() && 0){
		#$all_access_alert_border = 3;
		#$all_access_htaccess_border = 6;
	}

	# ���m���ŌÂ����R�[�h��S�č폜
	if(rand((3*24*60*60)*10) < 1){
		Mebius::DBI->delete_old_records(undef,$main_table_name,1*30*24*60*60);
	}

	# �e�[�u�����쐬
	#if(Mebius::alocal_judge()){ #  || rand(1000) < 1
	#	create_main_table();
	#}

# �f�[�^���擾
my $data = $package->fetchrow_main_table({ addr => $my_addr })->[0];

	# �����R�[�h�����݂���ꍇ�͍X�V
	if($data){

		my(%set);

			# ���i�����DOS���莞������j��莞�Ԃ��o�߂��Ă���ꍇ�ADOS�J�E���^�����Z�b�g����
			if($data->{'dos_count_start_time'} && time > $data->{'dos_count_start_time'} + 24*60*60){

				$set{'dos_count'} = 0;
				$set{'dos_count_start_time'} = "NULL";

			# ��DOS���肪��ꂽ�ꍇ�A�A�N�Z�X����������X��
			} elsif($data->{'dos_count'} >= $dos_count_deny_access_num){

				# �J�E���^���[����
				$set{'dos_count'} = 0;
				(%set) = reset_access_count_on_set(\%set);

					# �A�N�Z�X���������O��������𔻒�
					if(excluse_deny_access_judge()){
						0;
					# .htaccess �Ő������邽�߂̃t���O�𗧂Ă�
					} else {
						$deny_access_flag = 1;
					}

			# �����b���ɂ�����x�̃A�N�Z�X���Ȃ��ꍇ�́A�ꎞ�A�N�Z�X�J�E���g�����Z�b�g
			} elsif(time >= $data->{'access_start_time_temporary'} + $access_count_reset_second){

				(%set) = reset_access_count_on_set(\%set);

			# ���ꎞ�A�N�Z�X�J�E���g�𑝂₷
			} else {

				# �ꎞ�A�N�Z�X�J�E���^�𑝂₷
				$set{'access_count_temporary'} = ["+",1];

					# DOS����ɂ����DOS�J�E���^�𑝂₷
					if($data->{'access_count_temporary'} >= $dos_count_border){

							# �͂��߂� DOS�J�E���^���オ�����������L�^����
							if(!$data->{'dos_count'}){
								$set{'dos_count_start_time'} = time;
							}

							$set{'dos_count'} = ["+",1];
							(%set) = reset_access_count_on_set(\%set);
					}

			}

			# �u���b�N�𒴂����ꍇ�A���A�N�Z�X�������Z�b�g����
			if(time >= $data->{'access_count_per_term_start_time'} + 24*60*60){
				$set{'access_count_per_term'} = 1;
				$set{'access_count_per_term_start_time'} = time;
			# ���A�N�Z�X���𑝂₷
			} else {
				$set{'access_count_per_term'} = ["+",1];
			}
			#} else {
			#	$set{'access_count_per_term'} = 1;
			#}


		# ���R�[�h�̍ŏI�X�V�������L�^
		$set{'last_update_time'} = time;

		# �X�V
		Mebius::DBI->update(undef,$main_table_name,\%set,"WHERE addr='$my_addr'");

	# �����R�[�h���Ȃ��ꍇ�͍쐬
	} else {

		Mebius::DBI->insert(undef,$main_table_name,{ addr => $my_addr , access_start_time_temporary => $time , access_count_per_term_start_time => $time , last_update_time => $time });

	}


	#foreach( keys %{$data}){
	#	print "$_ : $data->{$_} \n";
	#}

	# .htaccess �ŃA�N�Z�X�𐧌�
	if($deny_access_flag){
		my($server_domain) = Mebius::server_domain();
		my($gethostbyaddr) = Mebius::get_host_state();
		Mebius::Dos::HtaccessFile("New-deny Renew",$my_addr,$gethostbyaddr);
		Mebius::Email::send_email("To-master Access-data-view",undef,"User deny with .htaccess. - $server_domain","host:$gethostbyaddr addr:$my_addr \n User-agent:$ENV{'HTTP_USER_AGENT'}");
	}


}

#-----------------------------------------------------------
# �A�N�Z�X���Ԃ����Z�b�g���邽�߂� ����SET��
#-----------------------------------------------------------
sub reset_access_count_on_set{

my($set_hash_for_sql) = @_;
my %self = %$set_hash_for_sql;
my $time = time;

$self{'access_count_temporary'} = 0;
$self{'access_start_time_temporary'} = $time;

%self;

}

#-----------------------------------------------------------
# �A�N�Z�X���������O����
#-----------------------------------------------------------
sub excluse_deny_access_judge{

# �z�X�g�����擾
my($multi_host) = Mebius::Host::gethostbyaddr_cache_multi();
my($access) = Mebius::my_access();
my($self,$host_or_addr);

	# IP�A�h���X/�z�X�g���̐U�蕪��
	if($multi_host->{'host'}){
		$host_or_addr = $multi_host->{'host'};
	} else {
		($host_or_addr) = my_addr();
	}

	# ����ΏۊO�̊��̏ꍇ
	if(
		$multi_host->{'host_type'} eq "Bot" ||
		($ENV{'HTTP_USER_AGENT'} =~ /Googlebot/ && ($multi_host->{'host'} eq "" || $multi_host->{'addr_to_host_flag'})) ||
		$multi_host->{'myserver_addr_flag'} ||
		$access->{'mobile_uid'}
	){
		$self = 1;
	}

$self;

}

1;

