
use strict;
package Mebius::Switch;

# CGI.pm を積極的に使うかどうか
#sub UseCGI{ return(0); }

# 軽量動作モード
sub light{ return(); }

sub thread_light{ return(); }

# $cnumber を暗号化するかどうか
sub CnumberHash{ return(1); }

# Near State を利用するかどうか
# 【重要！ オフにすると負荷量が何百倍にもなる可能性あり】
sub NearState{ return(1); }

# HTMLページを shift_jis で出力するかどうか
sub shift_jis{ return(1); }

# 「最新のレス」を使うかどうか
sub dbi_new_res_history{ return(1); }

sub use_memory_table{ return(0); }

sub sns_admin_off{ return(0); }

# 掲示板の投稿停止
sub stop_bbs{

my($bbs) = Mebius::BBS::init_bbs_parmanent_auto();

		#if($ENV{'SERVER_ADDR'} eq "112.78.200.216" && time > 1367983542 + 12.5*60*60){
		#	return(1);
		#} els
		if($bbs->{'concept'} =~ /Stop-mode/){ # |Souko-mode
			return(1);
		} elsif(stop_all_regist()){
			return(1);
		} else {
			return();
		}
}

sub stop_all_regist{ return(); }

sub stop_user_report{ 
	#if($ENV{'SERVER_ADDR'} eq "112.78.200.216" && time > 1367983542 + 12.5*60*60){
	#	return(1);
	#} else {
		return();
	#}
}



1;
