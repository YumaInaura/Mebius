
use strict;
package Mebius;


#-----------------------------------------------------------
# ���e�����̈�čX�V
#-----------------------------------------------------------
sub HistoryAll{

# �錾
my($type,$account,$host,$agent,$cnumber,$isp,%renew) = @_;
my($plustype);
my(%history_account,%history_cnumber,%history_kaccess_one,%history_host,%history_isp);

# ��荞�ݏ���
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_history.pl";

# �ݒ����ăI�t�o����悤�ɂ��邽�߂̋Ǐ���
my($alocal_mode) = Mebius::alocal_judge();
$alocal_mode = 0;

	# �����p���^�C�v��`
	if($type =~ /(My-file)/){ $plustype .= qq( $1); }
	if($type =~ /(RENEW)/i){ $plustype .= qq( $1); }
	if($type =~ /(Make-account)/){ $plustype .= qq( $1); }
	if($type =~ /(Use-renew-hash)/){ $plustype .= qq( $1); }
	
	# ���e�������L�^�i�A�J�E���g�j
	if($type !~ /Without-account/){
		(%history_account) = main::get_reshistory("ACCOUNT Get-hash $plustype",$account,undef,%renew);
	}

		if($type =~ /Check-make-account-error/ && $history_account{'make_account_blocktime'} > time && !$alocal_mode){
			my($how_next) = Mebius::SplitTime(undef,$history_account{'make_account_blocktime'} - time);
			Mebius::AccessLog(undef,"Make-account-error","�A�J�E���g�͂܂����܂��� (�A�J�E���g����) ");
			main::error("�A�J�E���g�͂܂����܂���B���� $how_next [A]");
		}

	# ���e�������L�^�i�z�X�g���j - �t�@�C�����ڑ���ŁA�g�т̃z�X�g���̏ꍇ�́A�L�^���Ȃ�
	my($host_type) = Mebius::HostType({ Host => $host });
	if($host_type->{'type'} eq "Mobile" || $host_type->{'type'} eq "MobileProxy"){
		0;
	} elsif($type =~ /My-file/){


		(%history_host) = main::get_reshistory("HOST Get-hash $plustype Debug",$host,undef,%renew);

			if($type =~ /Check-make-account-error/ && $history_host{'make_account_blocktime'} > time && !$alocal_mode){
				my($how_next) = Mebius::SplitTime(undef,$history_host{'make_account_blocktime'} - time);
				Mebius::AccessLog(undef,"Make-account-error","�A�J�E���g�͂܂����܂��� (�z�X�g������) ");
				main::error("�A�J�E���g�͂܂����܂���B���� $how_next [B]");
			}
	}


	# ���e�������L�^�iISP�j
	if($type !~ /Not-isp/){
		(%history_isp) = main::get_reshistory("ISP Get-hash $plustype",$isp,undef,%renew);
	}

	# ���e�������L�^�i�̎��ʔԍ��j
	# �g�уz�X�g
	(%history_kaccess_one) = main::get_reshistory("KACCESS_ONE Get-hash $plustype",$agent,undef,%renew);
		if($type =~ /Check-make-account-error/ && $history_kaccess_one{'make_account_blocktime'} > time && !$alocal_mode){
			my($how_next) = Mebius::SplitTime(undef,$history_kaccess_one{'make_account_blocktime'} - time);
			Mebius::AccessLog(undef,"Make-account-error","�A�J�E���g�͂܂����܂��� (�̎��ʔԍ�����) ");
			main::error("�A�J�E���g�͂܂����܂���B���� $how_next [C]");
		}

	# ���e�������L�^�i�Ǘ��ԍ��j
	(%history_cnumber) = main::get_reshistory("CNUMBER Get-hash $plustype",$cnumber,undef,%renew);
		if($type =~ /Check-make-account-error/ && $history_cnumber{'make_account_blocktime'} > time && !$alocal_mode){
			my($how_next) = Mebius::SplitTime(undef,$history_cnumber{'make_account_blocktime'} - time);
			Mebius::AccessLog(undef,"Make-account-error","�A�J�E���g�͂܂����܂��� (Cookie����) ");
			main::error("�A�J�E���g�͂܂����܂���B���� $how_next [D]");
		}


}





1;