
# �錾
use strict;
use Mebius::Getpage;
use Mebius::Server;
package Mebius::Host;

#-----------------------------------------------------------
# �I�u�W�F�N�g�֘A�t��
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_isp{

my $self = shift;
my $host = Mebius::get_host_state();
my $isp = Mebius::Isp(undef,$host);


	if(Mebius::alocal_judge()){
		$isp = "localhost.jp";
	}

$isp;

}

package Mebius;


#-----------------------------------------------------------
# �z�X�g���̎擾
#-----------------------------------------------------------
sub get_host{

my $server = new Mebius::Server;
my($host);

	if($server->local_machine_lan_judge()){
		$host = $server->local_machine_lan_addr();
	} else {
		$host = gethostbyaddr(pack("C4", split(/\./, $ENV{'REMOTE_ADDR'})), 2);
	}


$host;

}

#-----------------------------------------------------------
# �z�X�g���̎擾
#-----------------------------------------------------------
sub get_host_state{


# Near State �i�Ăяo���j 2.30
my $HereName1 = "gethostbyaddr_state";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

my ($host) = Mebius::get_host(@_);

	# Near State �i�ۑ��j 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$host); }

$host;

}

#-----------------------------------------------------------
# IP�A�h���X����z�X�g�����擾���� 
#-----------------------------------------------------------
sub GetHostByAddr{

# �錾
my($use) = @_;
my($Addr,$gethostbyaddr);

	# �����U�蕪��
	# �C�ӂ�IP�A�h���X���w�肷��ꍇ
	if(exists $use->{'Addr'}){
			if(defined $use->{'Addr'}){
				$Addr = $use->{'Addr'};
			}
			else{
				die("Perl Die!  Addr is empty.");
			}
	}
	# ������IP�A�h���X���g���ꍇ
	else{
		$Addr = $ENV{'REMOTE_ADDR'};
	}

# Near State ( �Ăяo�� ) 
my $StateName1 = "GetHostByAddr";
my $StateKey1 = $Addr; # IP�A�h���X�ɂ���ăL�[��ς���
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }

	# IP�A�h���X�̃t�H�[�}�b�g����������΁A�t���������s
	if(Mebius::AddrFormat({ Addr => $Addr })){
		$gethostbyaddr = Mebius::get_host_state($Addr);
	}

	# ���[�J���ł̓z�X�g������������
	if(Mebius::alocal_judge() && $gethostbyaddr =~ /^([\w\-]+)$/){ $gethostbyaddr = "localhost"; }

	# Near State ( �ۑ� )
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,$gethostbyaddr); }

return($gethostbyaddr);

}


#-----------------------------------------------------------
# �z�X�g������IP�A�h���X���h���h����
#-----------------------------------------------------------
sub GetHostByName{

# �錾
my($use) = @_;
my($addr_gethostbyname,$host);

	# ��������z�X�g�����w�肷��ꍇ
	if(exists $use->{'Host'}){ $host = $use->{'Host'}; }
	# �����̃A�N�Z�X��������擾����ꍇ
	else{ ($host) = Mebius::GetHostByAddr(); }

	# �K�{���ڂ��`�F�b�N
	if(!defined $host){ return(); }

# Near State �i�Ăяo���j 2.20
my $StateName1 = "GetHostByName";
my $StateKey1 = $host;
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

	# �z�X�g�����琳����
	if(Mebius::HostFormat({ Host => $host })){
		$addr_gethostbyname = join(".",unpack C4=>(gethostbyname $host)[4]);
	}
	else{
		$addr_gethostbyname = "";
	}

	# Near State �i�ۑ��j 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,$addr_gethostbyname); }

return($addr_gethostbyname);

}




#-----------------------------------------------------------
# �z�X�g�����擾 ( �L�^�t�@�C���̒l�͑�����Ȃ����ǁA�Q�l�ɂ��� )
#-----------------------------------------------------------
sub GetHostWithFile{

# Near State �i�Ăяo���j
my $StateName1 = "GetHostWithFile";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

my($host) = &GetHostSelect({ Addr => $ENV{'REMOTE_ADDR'} , "REMOTE_HOST" => $ENV{'REMOTE_HOST'} , TypeWithFile => 1 });

	# Near State �i�ۑ��j
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,$host); }

return($host);

}

#-----------------------------------------------------------
# �z�X�g�����擾 ( �L�^�t�@�C����D��I�Ɏg�� )
#-----------------------------------------------------------
sub GetHostByFile{

# Near State �i�Ăяo���j
my $StateName1 = "GetHostByFile";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

my($host) = &GetHostSelect({ Addr => $ENV{'REMOTE_ADDR'} , Host => $ENV{'REMOTE_HOST'} , TypeByFile => 1 , Debug => 1 });

	# Near State �i�ۑ��j
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,$host); }

return($host);

}

#-----------------------------------------------------------
# �z�X�g���ɉ����� ISP ���O�Ȃǂ𓯎��Ɏ擾 ( �t�������� )
#-----------------------------------------------------------
sub GetHostWithFileMulti{

# �錾
my($use) = @_;
my($multi_host);

# Near State �i�Ăяo���j 2.10
my $StateName1 = " GetHostWithFileMulti";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# �z�X�g�����擾
($multi_host) = Mebius::GetHostMulti({ TypeWithFile => 1 });

	# Near State �i�ۑ��j 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,$multi_host); }

return($multi_host);

}


#-----------------------------------------------------------
# �z�X�g���ɉ����� ISP ���O�Ȃǂ𓯎��Ɏ擾 ( �t�@�C������D�� )
#-----------------------------------------------------------
sub GetHostByFileMulti{

# �錾
my($use) = @_;
my($multi_host);

# Near State �i�Ăяo���j 2.10
my $StateName1 = "GetHostByFileMulti";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# �z�X�g�����擾
($multi_host) = Mebius::GetHostMulti({ TypeByFile => 1 });

	# Near State �i�ۑ��j 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,$multi_host); }

return($multi_host);

}


#-----------------------------------------------------------
# �z�X�g���ɉ����� ISP ���O�Ȃǂ𓯎��Ɏ擾
#-----------------------------------------------------------
sub GetHostMulti{

# �錾
my($use) = @_;
my(%multi_host,$StateName1);

	# �z�X�g�����擾���ăn�b�V���ɑ��
	if($use->{'TypeWithFile'}){

			# IP�A�h���X���w��
			if(exists $use->{'Addr'}){ ($multi_host{'host'}) = Mebius::GetHostSelect({ TypeWithFile => 1 , Addr => $use->{'Addr'} }); }
			# �����̃A�N�Z�X	# &GetHostSelect �ɂ��Ă��܂��ƁAState�������Ȃ��H
			else{ ($multi_host{'host'}) = Mebius::GetHostWithFile(); }

	}
	# �z�X�g�����擾���ăn�b�V���ɑ��
	elsif($use->{'TypeByFile'}){

			# IP�A�h���X���w��
			if(exists $use->{'Addr'}){ ($multi_host{'host'}) = Mebius::GetHostSelect({ TypeByFile => 1 , Addr => $use->{'Addr'} }); }
			# �����̃A�N�Z�X
			else{ ($multi_host{'host'}) = Mebius::GetHostByFile(); }

	}
	# �z�X�g�����擾���ăn�b�V���ɑ��
	elsif($use->{'TypeByCache'}){

		if(exists $use->{'Addr'}){
			die;
		} else{
			($multi_host{'host'}) = Mebius::Host::gethostbyaddr_cache();
		}

	}

	else{
		die("Perl Die!  Type is empty.");
	}

	# �z�X�g����ISP�𒊏o
	($multi_host{'isp'},$multi_host{'second_domain'},$multi_host{'first_domain'}) = Mebius::Isp("",$multi_host{'host'});

	# �z�X�g���̃^�C�v�𔻒�
	my($host_type) = Mebius::HostType({ Host => $multi_host{'host'} });
	$multi_host{'host_type'} = $host_type->{'type'};
	$multi_host{'mobile_id'} = $host_type->{'mobile_id'};

	# �t�����o���Ȃ���������� Who is �������ŋ������z�X�g�̏ꍇ
	if($multi_host{'host'} =~ /\.mb2.jp$/){ $multi_host{'addr_to_host_flag'} = 1; }

	# ���T�[�o�[���ǂ����𔻒� # FIXFIX
	foreach(@main::server_addrs){
		if($_ eq $ENV{'REMOTE_ADDR'}){ $multi_host{'myserver_addr_flag'} = 1; }
	}

return(\%multi_host);

}


#-----------------------------------------------------------
# �z�X�g�̎擾 ( �����̃A�N�Z�X�p )
#-----------------------------------------------------------
sub GetHostSelect{

# �錾
my($use) = @_;
my($basic_init) = Mebius::basic_init();
my($filehandle1,$host);
my($error_message,$plustype_hostcheck);
my($REMOTE_ADDR,$REMOTE_HOST,%data,$ADDR_FILE_RENEW_FLAG,$GETHOSTBYNAME_STRANGE_FLAG,$addr_gethostbyname);

	# �K�{���ڂ��`�F�b�N
	if(!exists $use->{'Addr'}){ die("Perl Die!  Addr is empty."); }

# ���[�v������\�h (�u���b�N�ƃZ�b�g) 1.1
my $HereName = "GetHostSelect";
my $HereKey = $use->{'Addr'};
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName,$HereKey);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName,$HereKey); }

	# �^�C�v�w��𔻒�
	if($use->{'TypeWithFile'}){ }
	elsif($use->{'TypeByFile'}){ }
	else{ die('Type is empty'); }

	# �C�ӂ�IP�A�h���X���w�肷��ꍇ
	if(!exists $use->{'Addr'}){ die("Perl Die!  Addr is empty value."); }

	# IP�A�h���X�̃t�H�[�}�b�g���m�F
	if(Mebius::AddrFormat({ Addr => $use->{'Addr'} })){ $REMOTE_ADDR = $use->{'Addr'}; }
	else{ die("Perl Die!  Addr Format '$use->{'Addr'}' is wrong."); }

# �A�h���X�t�@�C������f�[�^���擾
my($addr) = Mebius::Host::select_addr_data_from_main_table($REMOTE_ADDR);
my($flag) = Mebius::Host::get_flag($addr);

#my($addr) = Mebius::AddrFile({ TypeGetFlag => 1 },$REMOTE_ADDR);
#	if(!$addr->{'Flag'}){ die("Perl Die!  Addr File's Flag is not got. Please fix script."); }

	# ���t�@�C������D��I�Ɏ擾����ꍇ�ŁA�z�X�g�������ɋL�^����Ă���ꍇ�́A���̒l�������ɑ��
	if($use->{'TypeByFile'} && $flag->{'trusted_host'} && Mebius::HostFormat({ Host => $addr->{'host'} })){
			$host = $addr->{'host'};
	}

	# $ENV{'REMOTE_HOST'} ���T�u���[�`���̊O����w�肵�Ă���ꍇ ( �����̃A�N�Z�X�p )
	if(!defined $host){
			if(exists $use->{'REMOTE_HOST'} && Mebius::HostFormat({ Host => $use->{'REMOTE_HOST'} })){
				$REMOTE_HOST = $use->{'REMOTE_HOST'};
			}
		$ADDR_FILE_RENEW_FLAG = 1;
	}


	# ���z�X�g���擾�ł��Ȃ������ꍇ�AIP�A�h���X����t���� A-1
	# �O��̋t�������ʂ���̏ꍇ�́A��莞�ԋt�������Ȃ�
	if(($use->{'TypeWithFile'} && !defined $host && (time > $addr->{'last_gethostbyaddr_time'} + (1*24*60*60) || $addr->{'host'}) )
		# �t�@�C������擾����ꍇ�́A��莞�Ԍo�߂��Ă��Ȃ��ƁA�t�������̂��s��Ȃ�
		|| ($use->{'TypeByFile'} && !defined $host && time > $addr->{'last_gethostbyaddr_time'} + (1*24*60*60))){

		# �t���������s
		($REMOTE_HOST) = Mebius::GetHostByAddr({ Addr => $use->{'Addr'} });
		$ADDR_FILE_RENEW_FLAG = 1;
	}

	# ��IP�A�h���X�𐳈������� A-2
	if($REMOTE_HOST && Mebius::HostFormat({ Host => $REMOTE_HOST })){

		# �z�X�g�^�C�v�𔻒�
		my($host_type) = Mebius::HostType({ Host => $REMOTE_HOST });

		# "������" �擾�����z�X�g������IP�A�h���X���h�������h���āA����`�F�b�N�������Ȃ�
		($addr_gethostbyname) = Mebius::GetHostByName({ Host => $REMOTE_HOST });

			# �������ɋ�����z�X�g���̏ꍇ ( �g�т̃t���u���E�U�Ȃ� )
			if($host_type->{'special_allow_gethostbyname_flag'}){
				$host = $REMOTE_HOST;
			}
			# �������ɐ���
			elsif($addr_gethostbyname && $addr_gethostbyname eq $REMOTE_ADDR){
				$host = $REMOTE_HOST; # �����ŏ��߂ăz�X�g���𐳎��ɒ�`
			}			# �������̌��ʂ��J���̏ꍇ ( �ȍ~�̏����𑱍s )
			elsif($addr_gethostbyname eq ""){

			}
			# ���s
			else{
				Mebius::AccessLog(undef,"Gethostbyname-wrong","REMOTE_ADDR �F $REMOTE_ADDR => �z�X�g�� : $REMOTE_HOST => GetHostByName �F $addr_gethostbyname");
				$host = ""; # null �̒l�Ńz�X�g�����`���Ă��܂��A�ȍ~�̏����Ńz�X�g���̒�`�����������Ȃ�Ȃ��悤��
				$GETHOSTBYNAME_STRANGE_FLAG = 1;	# �O�̂��߃t���O�����ĂĂ���
			}

	}

	# ���O��� gethostbyaddr �����莞�Ԉȏオ�o�߂��Ă���ꍇ��IP�A�h���X�t�@�C�����X�V A-3
	if($ADDR_FILE_RENEW_FLAG && time > $addr->{'last_gethostbyaddr_time'} + (1*24*60*60)){
			my(%renew);
			$renew{'addr'} = $REMOTE_ADDR;
			$renew{'host'} = $host;
			$renew{'gethostbyname'} = $addr_gethostbyname;
			$renew{'last_gethostbyaddr_time'} = time;

			#Mebius::AddrFile({ TypeRenew => 1 },$REMOTE_ADDR,\%renew);
			Mebius::Host::update_or_insert_main_table(\%renew);

	}


	# ������Ȑڑ����ɂ����āA�z�X�g�����擾�ł��Ȃ������ꍇ�A�t�@�C���������ē��e��������
	# => Who is ���� �� �Ǘ��҂̎蓮�����Ȃ��Ă��A�ȑO�Ƀz�X�g���̋L�^�����邾���œ��e����
	if(!defined $host && $flag->{'trusted_host'} && !$GETHOSTBYNAME_STRANGE_FLAG){

		# �z�X�g�^�C�v�𔻒�
		my($host_type) = Mebius::HostType({ Host => $addr->{'host'} });

			# �z�X�g�����擾�ł��Ȃ��Ă��A�ȑO�Ƀz�X�g���L�^����Ă����ꍇ�́A���e�ł���悤��
			if($use->{'TypeWithFile'}){

					# �t�@�C���ɋL�^����Ă���̂��g�ђ[���̏ꍇ
					if($host_type->{'type'} eq "Mobile"){
						$host = "$REMOTE_ADDR.mobile.mb2.jp";
					}
					# �����łȂ��ꍇ
					else{
						$host = "$REMOTE_ADDR.mb2.jp";
					}

			}

	}

	# ���t�����ł��Ȃ��ꍇ���A�Ǘ��҂������Ă�����AWho is ���狖���Ă���ꍇ�́AIP�A�h���X���z�X�g���Ɍ��������ē��e����
	if(!defined $host && $flag->{'special_allow'} && !$GETHOSTBYNAME_STRANGE_FLAG){ $host = "$REMOTE_ADDR.mb2.jp"; }

	# ������ł��z�X�g�����擾�ł��Ȃ��ꍇ�AWho is ���猟��
	# => ���ɋ�����Ă���ꍇ�͎��s���Ȃ�
	# => �Ǘ��҂�IP�A�h���X���֎~���Ă���ꍇ�͎��s���Ȃ�
	# => �O���Who is �������玞�Ԃ��o���Ă��Ȃ��ꍇ�͎��s���Ȃ�
	# => IP�A�h���X�̐������ŋU�����肳�ꂽ�ꍇ�͎��s���Ȃ�
	if(!defined $host && $flag->{'allow_get_whois'} && !$GETHOSTBYNAME_STRANGE_FLAG){

		# Who is ���猟��
		my($whois) = Mebius::whois_nic({ Addr => $REMOTE_ADDR });

		# �}�X�^�[�Ƀ��[��������e
		my $mail_body .= qq($basic_init->{'admin_url'}index.cgi?mode=cda&file=$REMOTE_ADDR \n\n);
		$mail_body .= qq($whois->{'source'});
		$mail_body .= qq(�����^�C�v�F \$use->{'TypeWithFile'} : $use->{'TypeWithFile'} / \$use->{'TypeByFile'} : $use->{'TypeByFile'} \n\n);

			# Whois �T�C�g�������e���������ꍇ
			if($whois->{'mente_flag'}){

				# IP�t�@�C�����X�V
				my(%renew);
				$renew{'addr'} = $REMOTE_ADDR;
				$renew{'last_get_whois_time'} = time;
				$renew{'last_get_whois_but_mente_time'} = time;
				#Mebius::AddrFile({ TypeRenew => 1 },$REMOTE_ADDR,\%renew);
				Mebius::Host::update_or_insert_main_table(\%renew);

				# �L�^�p
				Mebius::AccessLog(undef,"Whois-get-but-now-mente",$mail_body);

				# �}�X�^�[�Ƀ��[������
				Mebius::Email::send_email("To-master BlockRoopingGetHost",undef,"Who is �T�C�g�������e�i���X���ł����B - $REMOTE_ADDR",$mail_body);

			}

			# Whois�ŋ����ꂽ�ꍇ
			elsif($whois->{'allow_flag'}){

				# IP�t�@�C�����X�V
				my(%renew);
				$renew{'addr'} = $REMOTE_ADDR;
				$renew{'last_deny_allow_time'} = time;
				$renew{'last_get_whois_time'} = time;
				$renew{'whois_allowed_time'} = time;
				$renew{'last_get_whois_but_mente_time'} = "";
				#Mebius::AddrFile({ TypeRenew => 1 },$REMOTE_ADDR,\%renew);
				Mebius::Host::update_or_insert_main_table(\%renew);

				# �L�^�p
				Mebius::AccessLog(undef,"Whois-get-allow",$mail_body);

				# �}�X�^�[�Ƀ��[������
				Mebius::Email::send_email("To-master BlockRoopingGetHost",undef,"IP�A�h���X������������܂����B - $REMOTE_ADDR",$mail_body);

				# �z�X�g����
				$host = "$REMOTE_ADDR.mb2.jp";

			}
			# Whois�ŋ�����Ȃ������ꍇ
			else{

				# IP�t�@�C�����X�V
				my(%renew);
				$renew{'addr'} = $REMOTE_ADDR;
				$renew{'last_get_whois_time'} = time;
				$renew{'last_get_whois_but_mente_time'} = "";
				#Mebius::AddrFile({ TypeRenew => 1 },$REMOTE_ADDR,\%renew);
				Mebius::Host::update_or_insert_main_table(\%renew);

				# �L�^�p
				Mebius::AccessLog(undef,"Who-is-get-not-allow",$mail_body);
				# �}�X�^�[�Ƀ��[������
				Mebius::Email::send_email("To-master BlockRoopingGetHost",undef,"IP�A�h���X������������܂���ł����B - $REMOTE_ADDR ",$mail_body);

			}

	}

	# ���[�J���ł̃z�X�g����������
	if(Mebius::alocal_judge()){ # && $host =~ /^(localhost)$/
		$host = "local.localhost.jp";
	}

	# ���[�v������\�h ( ��� ) 1.1
	if($HereName){ Mebius::Roop::relese(__PACKAGE__,$HereName,$HereKey); }

# �ŏI���^�[��
return($host);

}

#-----------------------------------------------------------
# �z�X�g�̎�ނ�
#-----------------------------------------------------------
sub HostType{

my($use) = @_;
my(%self);

	# �K�{�l�̊m�F
	if(!exists $use->{'Host'}){	die("Perl Die!  Host value is empty."); }
	if(!defined $use->{'Host'}){ return(); }

# Near State �i�Ăяo���j 2.20
my $StateName1 = "HostType";
my $StateKey1 = $use->{'Host'};
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

	# �g�т̃z�X�g
	if($use->{'Host'} =~ /\.(docomo\.ne\.jp)/){ $self{'mobile_id'} = "DOCOMO"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(ezweb\.ne\.jp)$/){ $self{'mobile_id'} = "AU"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(softbank\.ne\.jp)$/){ $self{'mobile_id'} = "SOFTBANK"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(vodafone\.ne\.jp)$/){ $self{'mobile_id'} = "SOFTBANK"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(jp-([dnrtcknsq]+)\.ne\.jp)$/){ $self{'mobile_id'} = "SOFTBANK"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(e-mobile\.ad\.jp)$/){ $self{'mobile_id'} = "EMOBILE"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(ppp\.prin\.ne\.jp)$/){ $self{'mobile_id'} = "WILLCOM"; $self{'type'} = "Mobile"; }

	# �����g�уc�[��
	elsif($use->{'Host'} =~ /(\.search\.tnz\.yahoo\.co\.jp$|\.mobile\.ogk\.yahoo\.co\.jp$|-out-f136\.google\.com$)/){
		$self{'mobile_id'} ="MOBILE";
	}

	# �g�т̃t���u���E�U
	#elsif($use->{'Host'} =~ /\.au-net\.ne\.jp$/){ $self{'special_allow_gethostbyname_flag'} = 1; }
	elsif($use->{'Host'} =~ /\.pcsitebrowser\.ne\.jp|\.ppp\.prin\.ne\.jp$/){ $self{'special_allow_gethostbyname_flag'} = 1; $self{'type'} = "MobileFullBrowser"; }

	# Bot �̃z�X�g
	elsif($use->{'Host'} =~ /\.(crawl\.yahoo\.net|googlebot\.com|msn\.com|super-goo\.com)$/){ $self{'type'} = "Bot"; }
	elsif($use->{'Host'} =~ /^(rate-limited-proxy-(\d+)-(\d+)-(\d+)-(\d+)\.google.com$)/){ $self{'type'} = "Bot"; }
	elsif($use->{'Host'} =~ /\.(baidu\.com|baidu\.jp|hinet\.net|naver\.com)$/){ $self{'type'} = "Bot"; }

	# ���ʂ̑S���̃v���N�V
	elsif($use->{'Host'} =~ /\.au-net\.ne\.jp$/){ $self{'type'} = "SmartPhone"; }

	# Near State �i�ۑ��j 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,\%self); }

return(\%self);

}

#-----------------------------------------------------------
# Who is �ŃA�h���X������
#-----------------------------------------------------------
sub whois_nic{

# �錾
my($use) = @_;
my(%self);

	# �K�{�l�̃`�F�b�N
	if(!exists $use->{'Addr'}){ die("Perl Die!  Addr is empty."); }
	if(!defined $use->{'Addr'}){ return(); }

	# IP�A�h���X���ςȏꍇ
	if(!Mebius::AddrFormat({ Addr => $use->{'Addr'} })){ return(); }

# Who is �̃y�[�W���擾		
my($source) = Mebius::getpage("Source","http://whois.nic.ad.jp/cgi-bin/whois_gw?type=&key=$use->{'Addr'}&lang=");
$self{'source'} = $source;

	# Who is �T�C�g�������e�i���X���̏ꍇ
	# SSS => �{���̓X�e�[�^�X�R�[�h���擾������
	if($source =~ /�����e�i���X��/){
		$self{'mente_flag'} = 1;
	}

	# �ŏI�X�V�������Q�b�g
	# who is �̊Y����񂪂������ꍇ�AIP�A�h���X�������I�ɋ��A�t�@�C�����X�V����A�Ǘ��҂Ƀ��[���𑗐M
	if($source =~ /\Q�l�[���T�[�o\E|�g�D��/ && $source !~ /baidu|Asia|SAKURA\-NET/i){
		$self{'allow_flag'} = 1;
	}

	# �ŏI�X�V�����𔻒�
	if($self{'source'} =~ m! \[�ŏI�X�V]\ ([\s\t]+)? (\d{4})/(\d{2})/(\d{2})!x){
		my $year = $2;
		my $month = $3;
		my $day = $4;
		my($time) = Mebius::TimeLocal(undef,$year,$month,$day);

			# ���܂�̂ɍX�V����Ă���IP�͋����Ȃ�
			if($time < time - (5*365*24*60*60)){
				$self{'allow_flag'} = 0;
			}
	}
	# �ŏI�X�V�������擾�ł��Ȃ��ꍇ�͋����Ȃ�
	else{
		$self{'allow_flag'} = 0;
	}

return(\%self);


}

#-----------------------------------------------------------
# sub Isp �̕ʖ�
#-----------------------------------------------------------
sub get_isp_by_host{
Isp(undef,$_[0]);
}

#-----------------------------------------------------------
# �z�X�g������ISP���擾
#-----------------------------------------------------------
sub Isp{

# �錾
my($type,$host) = @_;
my($isp,@isp,$isp_fook,$i,$hit_flag,$second_domain,$top_level_domain);

	# ���[�J��
	if(Mebius::alocal_judge() && $host eq "YUMA-PC"){ return($host); }

# �z�X�g�����Z���ꍇ�̓��^�[��
if(length($host) < 5){ return(); }

	@isp = (split/\./,$host);

	# xxx.jp �ȂǁA�Z���`���̏ꍇ�́A�z�X�g�������̂܂ܕԂ�
	if(@isp <= 2){ return($host,$host,$isp[-1]); }

	# �z�X�g����W�J
	foreach(@isp){
		$i++;
			if(!$hit_flag){
					if($i == 1){ next; }
					if($_ =~ /^(\d+)$/){ next; }
					if($_ =~ /([0-9]{3,})/){ next; }
			}
		$hit_flag = 1;
		if(defined($isp_fook)){ $isp_fook = join "." , ($isp_fook,$_); }
		else{ $isp_fook = $_; }
	}

	# ISP ���`
	if($isp_fook){
		$isp = $isp_fook;
	}
	else{
		if(@isp >= 2){ $isp = "$isp[-2].$isp[-1]"; }
	}

	# �Z�J���h�h���C�����`
	if($isp[-2] && $isp[-1]){ $second_domain = "$isp[-2].$isp[-1]"; }

	# ��h���C�����`
	if($isp[-1]){ $top_level_domain = "$isp[-1]"; }

	if($type =~ /Print-view/){
		print qq($host<br$main::xclose> > $isp<br$main::xclose><br$main::xclose>);
	}

	if(wantarray){
		return($isp,$second_domain,$top_level_domain);
	} else {
		return $isp;
	}
}

#-----------------------------------------------------------
# �z�X�g�� / IP�A�h���X�̓K���`�F�b�N
#-----------------------------------------------------------
sub HostCheck{

# �錾
my($basic_init) = Mebius::basic_init();
my($type,$host,$addr,$isp,$second_domain) = @_;
my($alert_domain_flag,%isp_data,%second_domain_data);

#if($main::alocal_mode){ $addr = "198.54.202.70"; $host = "cc.dd.pl"; $isp = "dd.pl"; $second_domain = "dd.pl"; }

	# �x���h���C�����ǂ����𔻒�
	if($host && $host !~ /(\.jp)$/){
		(%isp_data) = Mebius::penalty_file("Isp Get-hash",$isp);
		(%second_domain_data) = Mebius::penalty_file("Second-domain Get-hash",$second_domain);
			if(!$isp_data{'allow_host_flag'} && !$second_domain_data{'allow_host_flag'}){
				$alert_domain_flag = 1;
			}
	}

	# IP�A�h���X���ςȏꍇ
	if($addr !~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) {
		$main::e_access .= qq(��IP�A�h���X���擾�ł��܂���B�i $basic_init->{'mailform_link'} �j<br>);
		Mebius::AccessLog(undef,"Deny-axscheck","IP�A�h���X���� : $addr");
		Mebius::AccessLog(undef,"Deny-ip-address","IP�A�h���X�����F $addr");
	}

	# �z�X�g�����擾�ł��Ȃ��ꍇ
	elsif(length($host) < 5 && $type !~ /Not-empty-check/){

		$main::e_access .= qq(���z�X�g�����擾�ł��܂���B�i $basic_init->{'mailform_link'} �j<br>);
		Mebius::AccessLog(undef,"Deny-axscheck","�z�X�g���擾�ł����F IP - $addr / Host - $host");
		Mebius::AccessLog(undef,"Deny-hostname","�z�X�g���擾�ł����F IP - $addr / Host - $host");
	}

	# �z�X�g�����h���C���̌`���łȂ��ꍇ
	elsif($host !~ /\.([a-zA-Z]{2,4})$/ && $host){
		$main::e_access .= qq(���z�X�g�������܂��擾�ł��܂���B�i $basic_init->{'mailform_link'} �j<br>);
		Mebius::AccessLog(undef,"Deny-axscheck","�z�X�g���̌`�����ρF $host");
		Mebius::AccessLog(undef,"Deny-hostname","�z�X�g���̌`�����ρF $host");
	}

	# �z�X�g�����c�[��/�v���N�V���ۂ��ꍇ
	elsif($alert_domain_flag){
			#	&& !$main::k_access && $host =~ /(proxy|^tor|\.tor([0-9+])?|^anony|\.anony|^unknown|\.telenet|\.(arpa|local)$)/
		$main::e_access .= qq(�����̐ڑ����͎g���܂���B�i $basic_init->{'mailform_link'} �j<br>);
		Mebius::AccessLog(undef,"Deny-axscheck","�z�X�g�������F $host");
		Mebius::AccessLog(undef,"Deny-hostname","�z�X�g�������F $host");
		Mebius::AccessLog(undef,"Foreign-post","�C�O�h���C�������F $isp \n �Ǘ��F $basic_init->{'admin_url'}main.cgi?mode=cdl&file=$isp&filetype=isp");
	}

	# �C�O�̃z�X�g���̏ꍇ
	elsif($host =~ /\.(br|cn|de|it|il|in|lu|lv|ru|tw|ua)$/){
		$main::a_com .= qq(���C�O����̏������݂ł����H<br$main::xclose>);
	}

return($alert_domain_flag);

}

#-----------------------------------------------------------
# ������IP�A�h���X
#-----------------------------------------------------------
sub my_addr{

	if(addr_format_error_check($ENV{'REMOTE_ADDR'})){
		;
	} else{
		$ENV{'REMOTE_ADDR'};
	}

}

#-----------------------------------------------------------
# IP�A�h���X�̏����`�F�b�N
#-----------------------------------------------------------
sub addr_format_error_check{

my($error) = AddrFormat({ Addr => $_[0] , TypeReturnErrorFlag => 1 });

$error;

}

#-----------------------------------------------------------
# �z�X�g���̃t�H�[�}�b�g
#-----------------------------------------------------------
sub AddrFormat{

# �錾
my($use) = @_;
my($justy_flag,$error_flag);

	# �K�{�̒l
	if(!exists $use->{'Addr'}){ die("Perl Die!  Addr value is empty."); }

	# ����`�F�b�N
	if(defined $use->{'Addr'}){
			if($use->{'Addr'} =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/){

				$justy_flag = 1;
			}	elsif($use->{'Addr'} =~ /^([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4})$/){
#2401:fa00:4:fd00:9905:4853:bbbd:a3a3

				$justy_flag = 1;
			}


			else{
				$error_flag = 1;
			}
	}
	else{
			$error_flag = 1;
	}

	# ���^�[��
	if($use->{'TypeReturnErrorFlag'}){

		return($error_flag);
	}
	else{
		return($justy_flag);
	}

}



#-----------------------------------------------------------
# IP�A�h���X�̃t�H�[�}�b�g
#-----------------------------------------------------------
sub HostFormat{

# �錾
my($use) = @_;
my($error_flag,$justy_flag);

	# �K�{�̒l
	if(!exists $use->{'Host'}){ die("Perl Die!  Host value is empty."); }

	# ����`�F�b�N
	if(defined $use->{'Host'}){
			# Second Level Domain �� �u�p�����v�Ɓu�n�C�t���v�ō\�������
			if($use->{'Host'} =~ /^([a-zA-Z0-9\.\-]+\.)?([a-zA-Z0-9\-]+?)\.([a-zA-Z]{2,4})$/){
				$justy_flag = 1;
			}
			elsif(Mebius::alocal_judge() && $use->{'Host'} =~ /^([a-zA-Z0-9\-]+)$/){
				$justy_flag = 1;
			}
			else{
				$error_flag = 1;
			}
	}
	else{
			$error_flag = 1;
	}

	# ���^�[��
	if($use->{'TypeReturnErrorFlag'}){
		return($error_flag);
	}
	else{
		return($justy_flag);
	}

}



#-----------------------------------------------------------
# IP �A�h���X�p�t�@�C�� ( �t���O�𗧂Ă鏈���̂��߁A�Ƃ肠�����T�u���[�`�����̓r���ł� return ���Ȃ� )
#-----------------------------------------------------------
sub AddrFile{

# �錾
my($use,$addr,$select_renew) = @_;
my($i,@renew_line,%data,$FILE1,%renew);

	# IP�A�h���X���ςȏꍇ
	if(!Mebius::AddrFormat({ Addr => $addr })){ return(); }

# �G���R�[�h
my($encaddr) = Mebius::Encode(undef,$addr);

# �t�@�C����`
my($init_directory) = Mebius::BaseInitDirectory();
my $directory1 = "${init_directory}_hostname/";
my $file1 = "${directory1}${encaddr}_hostname.log";

	# �f�B���N�g���쐬
	if($use->{'TypeRenew'} && (rand(100) < 1 || Mebius::alocal_judge())){
		Mebius::Mkdir(undef,$directory1);
	}

	# �t�@�C�����J��
	if($use->{'FileCheckError'}){
		$data{'f'} = open($FILE1,"+<",$file1) || main::error("�t�@�C�������݂��܂���B");
	}
	else{

		$data{'f'} = open($FILE1,"+<",$file1);

			# �t�@�C�������݂��Ȃ��ꍇ�͐V�K�쐬
			if(!$data{'f'} && $use->{'TypeRenew'}){
				Mebius::Fileout("Allow-empty",$file1);
				$data{'f'} = open($FILE1,"+<$file1");
			}

	}

	# �t�@�C�����b�N
	if($use->{'TypeRenew'} || $use->{'Flock'}){ flock($FILE1,2); }

# �g�b�v�f�[�^���擾
	# �g�b�v�f�[�^��W�J
	for(1..2){
		chomp($data{"top$_"} = <$FILE1>);
	}

# �g�b�v�f�[�^�𕪉�	( �� empty_key = �g���Ă��Ȃ��L�[ )
($data{'host'},$data{'allow_key'},undef,$data{'last_deny_allow_time'},$data{'last_get_whois_time'},$data{'last_gethostbyaddr_time'}) = split(/<>/,$data{'top1'});
($data{'gethostbyname'},$data{'first_time'},$data{'last_time'},$data{'whois_allowed_time'},$data{'last_get_whois_but_mente_time'}) = split(/<>/,$data{'top2'});

	# �X�V�p�ɓ��e���L�����Ă���
	if($use->{'TypeRenew'}){ %renew = %data; }

	# �t�@�C���X�V
	if($use->{'TypeRenew'}){

		# ���������X�V
			if(!$data{'first_time'}){ $renew{'first_time'} = time; }
		$renew{'last_time'} = time;

			# �w��̃f�[�^���X�V
			my($renew) = Mebius::Hash::control(\%renew,$select_renew);

		# �g�b�v�f�[�^��ǉ�
		push(@renew_line,"$renew->{'host'}<>$renew->{'allow_key'}<><>$renew->{'last_deny_allow_time'}<>$renew->{'last_get_whois_time'}<>$renew->{'last_gethostbyaddr_time'}<>\n");
		push(@renew_line,"$renew->{'gethostbyname'}<>$renew->{'first_time'}<>$renew->{'last_time'}<>$renew->{'whois_allowed_time'}<>$renew->{'last_get_whois_but_mente_time'}<>\n");

		# �t�@�C���X�V
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renew_line;

	}

close($FILE1);

	# �p�[�~�b�V�����ύX
	if($use->{'TypeRenew'}){
		Mebius::Chmod(undef,$file1);
	}

	# ���t���O�𗧂Ă� ( ����ȑO�̏����� return ���Ă��܂��ƕK�v�ȃt���O�����Ă��Ȃ��Ȃ�̂Œ��� )
	if($use->{'TypeGetFlag'}){

		# �t���O
		my(%flag);

		# Who is ���̃L�[�v����
		my $whois_keep_allow_term = 30*24*60*60;

			# ���z�X�g�����t�����ł��Ȃ��ꍇ���A���e��������t���O (A-1)
			# => �Ǘ��҂��蓮�ŋ����Ă���ꍇ
			if($data{'allow_key'} eq "1"){ $flag{'special_allow'} = 1; }
			# => �O�� Who is �ŋt�������āA�������肪����Ă���ꍇ
			elsif($data{'whois_allowed_time'} && time < $data{'whois_allowed_time'} + $whois_keep_allow_term){ $flag{'special_allow'} = 1; }

			# �������Who is ������������t���O (A-2)
			# => �Ǘ��҂ɂ���ċ֎~����Ă��Ȃ��A�Ȃ������݂͋��������ł͂Ȃ����Ƃ��Œ���� ( ���׌y���̂��� )
			if($data{'allow_key'} ne "0" && !$flag{'special_allow'}){
					# �O�񂪃����e�i���X���ȂǂŐ摗�肵���ꍇ�A��r�I�Z�����ԂōČ�������
					if($data{'last_get_whois_but_mente_time'} && time >= $data{'last_get_whois_but_mente_time'} + (6*24*24)){ $flag{'allow_get_whois'} = 1; }
					# �O���Whois���������莞�Ԃ��o�߂��Ă���ꍇ
					elsif(!$data{'last_get_whois_time'} || time > $data{'last_get_whois_time'} + $whois_keep_allow_term){
						$flag{'allow_get_whois'} = 1;
					}
			}

			# IP�A�h���X�ƍ�
			if($data{'gethostbyname'} && $data{'host'} && $addr eq $data{'gethostbyname'} && Mebius::HostFormat({ Host => $data{'host'} }) ){ $flag{'trusted_host'} = 1; }

			# �n�b�V��������
			$data{'Flag'} = \%flag;

	}

return(\%data);

}



1;
