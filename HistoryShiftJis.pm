
use strict;
package Mebius;


#-----------------------------------------------------------
# 投稿履歴の一斉更新
#-----------------------------------------------------------
sub HistoryAll{

# 宣言
my($type,$account,$host,$agent,$cnumber,$isp,%renew) = @_;
my($plustype);
my(%history_account,%history_cnumber,%history_kaccess_one,%history_host,%history_isp);

# 取り込み処理
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_history.pl";

# 設定を一斉オフ出来るようにするための局所化
my($alocal_mode) = Mebius::alocal_judge();
$alocal_mode = 0;

	# 引き継ぎタイプ定義
	if($type =~ /(My-file)/){ $plustype .= qq( $1); }
	if($type =~ /(RENEW)/i){ $plustype .= qq( $1); }
	if($type =~ /(Make-account)/){ $plustype .= qq( $1); }
	if($type =~ /(Use-renew-hash)/){ $plustype .= qq( $1); }
	
	# 投稿履歴を記録（アカウント）
	if($type !~ /Without-account/){
		(%history_account) = main::get_reshistory("ACCOUNT Get-hash $plustype",$account,undef,%renew);
	}

		if($type =~ /Check-make-account-error/ && $history_account{'make_account_blocktime'} > time && !$alocal_mode){
			my($how_next) = Mebius::SplitTime(undef,$history_account{'make_account_blocktime'} - time);
			Mebius::AccessLog(undef,"Make-account-error","アカウントはまだ作れません (アカウント判定) ");
			main::error("アカウントはまだ作れません。あと $how_next [A]");
		}

	# 投稿履歴を記録（ホスト名） - ファイル直接操作で、携帯のホスト名の場合は、記録しない
	my($host_type) = Mebius::HostType({ Host => $host });
	if($host_type->{'type'} eq "Mobile" || $host_type->{'type'} eq "MobileProxy"){
		0;
	} elsif($type =~ /My-file/){


		(%history_host) = main::get_reshistory("HOST Get-hash $plustype Debug",$host,undef,%renew);

			if($type =~ /Check-make-account-error/ && $history_host{'make_account_blocktime'} > time && !$alocal_mode){
				my($how_next) = Mebius::SplitTime(undef,$history_host{'make_account_blocktime'} - time);
				Mebius::AccessLog(undef,"Make-account-error","アカウントはまだ作れません (ホスト名判定) ");
				main::error("アカウントはまだ作れません。あと $how_next [B]");
			}
	}


	# 投稿履歴を記録（ISP）
	if($type !~ /Not-isp/){
		(%history_isp) = main::get_reshistory("ISP Get-hash $plustype",$isp,undef,%renew);
	}

	# 投稿履歴を記録（個体識別番号）
	# 携帯ホスト
	(%history_kaccess_one) = main::get_reshistory("KACCESS_ONE Get-hash $plustype",$agent,undef,%renew);
		if($type =~ /Check-make-account-error/ && $history_kaccess_one{'make_account_blocktime'} > time && !$alocal_mode){
			my($how_next) = Mebius::SplitTime(undef,$history_kaccess_one{'make_account_blocktime'} - time);
			Mebius::AccessLog(undef,"Make-account-error","アカウントはまだ作れません (個体識別番号判定) ");
			main::error("アカウントはまだ作れません。あと $how_next [C]");
		}

	# 投稿履歴を記録（管理番号）
	(%history_cnumber) = main::get_reshistory("CNUMBER Get-hash $plustype",$cnumber,undef,%renew);
		if($type =~ /Check-make-account-error/ && $history_cnumber{'make_account_blocktime'} > time && !$alocal_mode){
			my($how_next) = Mebius::SplitTime(undef,$history_cnumber{'make_account_blocktime'} - time);
			Mebius::AccessLog(undef,"Make-account-error","アカウントはまだ作れません (Cookie判定) ");
			main::error("アカウントはまだ作れません。あと $how_next [D]");
		}


}





1;