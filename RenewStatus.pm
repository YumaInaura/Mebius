
use strict;
package Mebius::RenewStatus;

#-----------------------------------------------------------
# ファイル取得の間隔
#-----------------------------------------------------------
sub allow_judge_for_get_file{

my $use = shift if(ref $_[0] eq "HASH");
my $last_getfile_localtime = shift;
my $last_modified_localtime = shift;
my($allow_flag,$interval_second);

	if(@_ >= 1){ die("Perl Die! Too Many Value was relayed. @_"); }

	# 前回の取得がない場合は、無条件に取得
	if(!$last_getfile_localtime || !$last_modified_localtime){ return(1); }

# 前回ファイルを見に行った時「元のスレッドが更新されていなかった秒数」を計算
my $gyap_time = $last_getfile_localtime - $last_modified_localtime;

	# スレッドが更新されていなかった秒数を元に、そこを起点とした次回の取得間隔を定義
	if($gyap_time >= 365*24*60*60){ $interval_second = (24*60*60); }	# １年 更新されていない場合
	elsif($gyap_time >= 6*30*24*60*60){ $interval_second = (12*60*60); }	# ６ヶ月 ...
	elsif($gyap_time >= 30*24*60*60){ $interval_second = (6*60*60); }	# １ヶ月 ...
	elsif($gyap_time >= 7*24*60*60){ $interval_second = (3*60*60); }	# １週間 ...
	elsif($gyap_time >= 3*24*60*60){ $interval_second = (1*60*60); }	# ３日 ...
	elsif($gyap_time >= 1*24*60*60){ $interval_second = (*60); }	# １日 ...
	elsif($gyap_time >= 6*60*60){ $interval_second = (15*60); }	# ６時間 ...
	elsif($gyap_time >= 1*60*60){ $interval_second = (10*60); }	# １時間 ...
	else{
			if(exists $use->{'UnderIntervalSecond'} && $use->{'UnderIntervalSecond'} < 5*60){ $interval_second = $use->{'UnderIntervalSecond'}; }
			else{ $interval_second = 5*60; }
	}	# それ以外


	# 最低インターバル秒数より取得間隔が短くならないように
	if(exists $use->{'UnderIntervalSecond'} && $use->{'UnderIntervalSecond'} > $interval_second){
		$interval_second = $use->{'UnderIntervalSecond'};
	}

# 「次回の取得許可時間」を定義
my $next_allow_getfile_localtime = $last_getfile_localtime + $interval_second;

	# 許可判定
	# 「前回の取得時間」と「スレッドの最終更新日時」を比較して、取得時間を変化させる（しばらく更新がないスレッドは次回の取得を遅らせる）
	if(time >= $next_allow_getfile_localtime){ $allow_flag = 1; }

return($allow_flag);

}


1;