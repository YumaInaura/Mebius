
use strict;
use Time::Local qw();
use Time::HiRes qw();
package Mebius::Time;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new{
my $class = shift;
bless {} , $class;
}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub datetime_to_localtime{

my $self = shift;
my $datetime = shift;

my($date_group,$time_group) = split(/T/,$datetime);

my($year,$month,$day) = split(/-/,$date_group);
my($hour,$minute,$second) = split(/:/,$time_group);

my $localtime = $self->date_to_localtime($year,$month,$day,$hour,$minute,$second);

$localtime;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub ymd{

my $self = shift;
my $time = shift || (warn && return());

my $year = $self->yearf($time);
my $month = $self->monthf($time);
my $day = $self->dayf($time);

my $ymd = "$year-$month-${day}";

$ymd;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub his{
my $self = shift;
$self->hms(@_);
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hms{

my $self = shift;
my $time = shift || (warn && return());

my $hour = $self->hourf($time);
my $minute = $self->minutef($time);
my $second = $self->secondf($time);

my $hms = "$hour:$minute:$second";

$hms;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub datetime{

my $self = shift;
my $time = shift || (warn && return());
my $split_mark = shift || "T";

my $ymd = $self->ymd($time);
my $hms = $self->hms($time);

my $datetime = "${ymd}$split_mark${hms}";

$datetime;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tremor{

my $self = shift;
my $second = shift;

my @tremor_by = qw(1.00 1.05 1.10 1.15 1.20 1.25);

my $tremor_second = $second * $tremor_by[int rand(@tremor_by)];

	if($tremor_second <= 0){
		$tremor_second = 1;
	}

$tremor_second;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub micro_time{

my $self = shift;

my $micro_second = $self->micro_second();

my $micro_time = time . $micro_second;

$micro_time;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub micro_second{

my $self = shift;
my ($epocsec, $micro_second) = Time::HiRes::gettimeofday();

$micro_second = sprintf("%06d",$micro_second);

$micro_second;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub time_value_to_hour{

my $self = shift;
my $value = shift || return();
my($hour);

	if($value =~ /^([0-9]{1,2}):([0-9]{1,2})$/){
		$hour = sprintf("%02d",$1);
	}

$hour;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub time_value_to_minute{

my $self = shift;
my $value = shift || return();
my($minute);

	if($value =~ /^([0-9]{1,2}):([0-9]{1,2})$/){
		$minute = sprintf("%02d",$2);
	}

$minute;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub today_weekday_or_holiday{

my $self = shift;
$self->weekday_or_holiday(time);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub weekday_or_holiday{

my $self = shift;
my $weekday = $self->weekday(@_);
my($result);
	if($weekday =~ /^(1|2|3|4|5)$/){
		$result = "weekday";
	} elsif($weekday =~ /^(0|6)$/){
		$result = "holiday";
	}
$result;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub weekday{

my $self = shift;
my $local_time = shift;

my $weekday = (localtime($local_time))[6];

$weekday;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub this_weekday{

my $self = shift;

$self->weekday(time);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub weekday_japanese{

my $self = shift;

my $weekday = $self->weekday(@_);

my @kind = ("日","月","火","水","木","金","土");

my $weekday_japanese = $kind[$weekday];

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub this_weekday_japanese{

my $self = shift;
$self->weekday_japanese(time);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub date_to_localtime{

my $self = shift;
my($time_local) = Mebius::TimeLocal("",@_);

$time_local;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_date{

my $self = shift;
my $time = shift;

my $date_hash = Mebius::get_date($time);

$date_hash->{'date'};

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_date_till_minute{

my $self = shift;
my $time = shift;

my $date_hash = Mebius::get_date($time);

$date_hash->{'date_till_minute'};

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub localtime_to_calender{

my $self = shift;
my $localtime = shift;
my(%date);

($date{'second'},$date{'minute'},$date{'hour'},$date{'day'},$date{'pre_month'},$date{'pre_year'},$date{'pre_weekday'}) = (localtime($localtime))[0..6];

$date{'month'} = $date{'pre_month'} + 1;
$date{'year'} = $date{'pre_year'} + 1900;

# 桁を揃える
$date{'yearf'} = $date{'year'};
($date{'monthf'}) = sprintf("%02d",$date{'month'});
($date{'dayf'}) = sprintf("%02d",$date{'day'});
($date{'hourf'}) = sprintf("%02d",$date{'hour'});
($date{'minutef'}) = sprintf("%02d",$date{'minute'});
($date{'secondf'}) = sprintf("%02d",$date{'second'});

\%date;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub this_month{

my $self = shift;
$self->month(time);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub this_monthf{

my $self = shift;
$self->monthf(time);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub month{

my $self = shift;
my $localtime = shift;
my $month = (localtime($localtime))[4] + 1;

$month

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub monthf{

my $self = shift;
my $month = $self->month(@_);
my $monthf = sprintf("%02d",$month);

$monthf;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub this_year{

my $self = shift;
$self->year(time);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub year{

my $self = shift;
my $localtime = shift;

my $year = (localtime($localtime))[5] + 1900;

$year;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub yearf{

my $self = shift;
$self->year(@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub today{
my $self = shift;
$self->day(time);
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub todayf{
my $self = shift;
$self->dayf(time);
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub day{

my $self = shift;
my $localtime = shift;

my $day = (localtime($localtime))[3];

$day;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub dayf{

my $self = shift;
my $day = $self->day(@_);
my $dayf = sprintf("%02d",$day);

$dayf;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hour{

my $self = shift;
my $localtime = shift;

my $day = (localtime($localtime))[2];

$day;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hourf{

my $self = shift;
my $hour = $self->hour(@_);
my $hourf = sprintf("%02d",$hour);

$hourf;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub minute{

my $self = shift;
my $localtime = shift;

my $minute = (localtime($localtime))[1];

$minute;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub minutef{

my $self = shift;
my $minute = $self->minute(@_);
my $minutef = sprintf("%02d",$minute);

$minutef;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub second{

my $self = shift;
my $localtime = shift;

my $second = (localtime($localtime))[0];

$second;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub secondf{

my $self = shift;
my $second = $self->second(@_);
my $secondf = sprintf("%02d",$second);

$secondf;

}

#-----------------------------------------------------------
# どれぐらい先の投稿か
#-----------------------------------------------------------
sub how_after{

my $self = shift;
my $border_time = shift;
my $link = shift;
my $use = shift if(ref $_[0] eq "HASH");

my($how_before) = Mebius::second_to_howlong({ TopUnit => 1 ,  HowAfter => 1  },$border_time-time);

$how_before;

}
#-----------------------------------------------------------
# どれぐらい前の投稿か
#-----------------------------------------------------------
sub how_before{

my $self = shift;
my $border_time = shift;
my $link = shift;
my $use = shift if(ref $_[0] eq "HASH");

my($how_before) = Mebius::second_to_howlong({ TopUnit => 1 , ColorView => 1 , HowBefore => 1 , link => $link },time - $border_time);

$how_before;

}


#-----------------------------------------------------------
# 特定の”時”から特定の”時”までを配列にする
#-----------------------------------------------------------
sub foreach_hours{

my $self = shift;
my $start_hour = shift;
my $end_hour = shift;
my(@hours,$hour,$i);

	if($start_hour !~ /^[0-9]+$/){ warn("$start_hour is not number."); return(); }
	if($end_hour !~ /^[0-9]+$/){ warn("$end_hour is not number.");  return(); }

my $start_hour_adjusted = $self->adjust_hour($start_hour);
my $end_hour_adjusted = $self->adjust_hour($end_hour);

	for($start_hour_adjusted .. $start_hour_adjusted+23){
		$hour = $self->adjust_hour($_);
		push @hours , $hour;
			if($hour == $end_hour_adjusted){ last; }
	}

\@hours;

}


#-----------------------------------------------------------
# 時刻を修正
#-----------------------------------------------------------
sub adjust_hour{

my $self = shift;
my $hour = shift;

	if($hour !~ /^[0-9]+$/){ warn("$hour is not number."); return(); }

	if($hour >= 24){
		$hour = $hour % 24;
	}

$hour;


}


#-----------------------------------------------------------
# 指定月から指定月まで展開する ( 渡し値には localtime を使う )
#-----------------------------------------------------------
sub foreach_year_and_month_with_localtime{

my $self = shift;
my $start_localtime = shift;
my $end_localtime = shift;

my($start_date) = Mebius::get_date($start_localtime);
my($end_date) = Mebius::get_date($end_localtime);

$self->foreach_year_and_month($start_date->{'year'},$start_date->{'month'},$end_date->{'year'},$end_date->{'month'});

}

#-----------------------------------------------------------
# 指定月から指定月まで展開する
#-----------------------------------------------------------
sub foreach_year_and_month{

my $self = shift;
my $start_year = shift;
my $start_month = shift;
my $end_year = shift;
my $end_month = shift;
my(@array);

# 整形 
$end_year =  $self->fix_year($end_year,$end_month);
$end_month =  $self->fix_month($end_year,$end_month);
my $year =  $self->fix_year($start_year,$start_month);
my $month =  $self->fix_month($start_year,$start_month);

		# 渡し値のチェック
		if($self->year_and_month_to_localtime($start_year,$start_month) > $self->year_and_month_to_localtime($end_year,$end_month)){
			die(" start localtime is bigger ( or equall ) than end localtime .");
		}

	# 一定回数を限度としてループ処理
	for(1..10000){

		my $localtime_start = $self->year_and_month_to_localtime($year,$month);
		my $localtime_end = $self->year_and_month_to_localtime_end($year,$month);

		push @array , { year => $year , month => sprintf("%02d",$month) , localtime_start => $localtime_start , localtime_end => $localtime_end } ;
		#print "$year-$month $localtime_start - $localtime_end \n";

			if($year == $end_year && $month == $end_month){
				last;
			}

		$month++;
		$year =  $self->fix_year($year,$month);
		$month =  $self->fix_month($year,$month);

	}

\@array;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub year_to_localtime_start{

my $self = shift;
my $year = shift || die;

my $time = Time::Local::timelocal(0,0,0,1,0,$year);

$time;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub year_to_localtime_end{

my $self = shift;
my $year = shift || die;

my $next_year = $year+1;

my $time = Time::Local::timelocal(0,0,0,1,0,$next_year) - 1;

$time;

}

#-----------------------------------------------------------
# 月初めの localtime を調べる
#-----------------------------------------------------------
sub year_and_month_to_localtime{

my $self = shift;
my $year = shift;
my $month = shift;

	if(!$year){ die; }
	if(!$month){ die; }

$year =  $self->fix_year($year,$month);
$month =  $self->fix_month($year,$month);

my $time = Time::Local::timelocal(0,0,0,1,$month-1,$year);

}

#-----------------------------------------------------------
# 月終わりの localtime を調べる
#-----------------------------------------------------------
sub year_and_month_to_localtime_end{

my $self = shift;
my $year = shift;
my $month = shift;

	if(!$year){ die; }
	if(!$month){ die; }

# 来月分にする
$month += 1;

$year =  $self->fix_year($year,$month);
$month =  $self->fix_month($year,$month);

my $time = Time::Local::timelocal(0,0,0,1,$month-1,$year) - 1;

}


#-----------------------------------------------------------
# 年の整形 ( 13月など、既定値を超えた値が与えられた場合 )
#-----------------------------------------------------------
sub fix_year{

my $self = shift;
my $year = shift;
my $month = shift;

	if(!$year){ die; }
	if(!$month){ die; }

	if($month >= 13){
		$year += int(($month-1)/12);
	}

$year;

}

#-----------------------------------------------------------
# 月の整形 ( 13月など、既定値を超えた値が与えられた場合 )
#-----------------------------------------------------------
sub fix_month{

my $self = shift;
my $year = shift;
my $month = shift;

	if(!$year){ die; }
	if(!$month){ die; }

	if($month >= 13){
		$month = $month % 12 || 12;
	}

$month;

}

#-----------------------------------------------------------
# ローカルタイムをフィード等用のGMTに
#-----------------------------------------------------------
sub localtime_to_gmt_date{

my $self = shift;
my $localtime = shift;

	if(!$localtime){
		warn("Please hand localtime. $localtime is not.");
		return();
	}

# 時刻を定義
my($sec,$min,$hour,$day,$mon,$year,$wday) = (localtime($localtime))[0..6];
$mon = $mon+1;
$year = $year+1900;

my($date) = sprintf("%04d-%02d-%02dT%02d:%02d:%02d+09:00", $year,$mon,$day,$hour,$min);

$date;

}


package Mebius;
use Mebius::Export;

#-----------------------------------------------------------
# 現在の時刻を取得
#-----------------------------------------------------------
sub now_date{

# 現在の時刻を取得
my($date_multi) = Mebius::now_date_multi();
my $date = $date_multi->{'date_till_minute'};

return($date);

}

#-----------------------------------------------------------
# 現在の時刻を取得
#-----------------------------------------------------------
sub now_date_multi{

# 現在の時刻を取得
my($date_multi) = Mebius::get_date(time);

return($date_multi);

}



#-----------------------------------------------------------
# 時刻を取得
#-----------------------------------------------------------
sub get_date{

# 宣言
my($time) = @_;
my(%self);
my $times = new Mebius::Time;

	# 不要値のチェック
	if(defined $_[1]){ die("Perl Die! Time is must set at First value"); }

# タイムゾーンを設定
$ENV{'TZ'} = "JST-9";

	# 自動的に現在のミリ秒を使う場合
	if($time eq "HiRes"){	$time = Time::HiRes::time; }

	# ミリ秒まで指定されている場合
	if($time =~ /^(\d+)\.(\d+)$/){
		$time = $1;
		$self{'micro_seconds'} = $2;
	}

	# リターン
	if($time eq "" || !defined $time || $time !~ /^(\d+)$/){ return(); }

my $calender = $times->localtime_to_calender($time);
my %self = (%self,%{$calender});

my @week = ("日","月","火","水","木","金","土");
shift_jis(@week);
$self{'weekday'} = $week[$self{'pre_weekday'}];

	# 日付を定義 ( ミリ秒まで )
	if($self{'micro_seconds'}){
		$self{'micro_second_omited'} = substr($self{'micro_seconds'},0,2);
		$self{'date_till_micro_second'} = sprintf("%04d/%02d/%02d %02d:%02d:%02d.%02d", $self{'year'},$self{'month'},$self{'day'},$self{'hour'},$self{'minute'},$self{'second'},$self{'micro_second_omited'});
	}

# 日付を定義 ( 秒まで )
$self{'date'} = $self{'date_till_second'} = sprintf("%04d/%02d/%02d %02d:%02d:%02d", $self{'year'},$self{'month'},$self{'day'},$self{'hour'},$self{'minute'},$self{'second'});
 
# 日付を定義 ( 分まで )
($self{'date_till_minute'}) = sprintf("%04d/%02d/%02d %02d:%02d", $self{'year'},$self{'month'},$self{'day'},$self{'hour'},$self{'minute'});

# 日付を定義 ( 日まで )
($self{'date_till_day'}) = sprintf("%04d/%02d/%02d", $self{'year'},$self{'month'},$self{'day'});



# ユース変数
$self{'ymdf'} = "$self{'yearf'}-$self{'monthf'}-$self{'dayf'}";
$self{'yearf_omited'} = $self{'yearf'};
$self{'yearf_omited'} =~ s/^..//;

return(\%self);

}

#-------------------------------------------------
#  時間取得 (旧)
# SSS => 全て新しい処理 Date に置き換えたい
#-------------------------------------------------
sub Getdate{

# 宣言
my($type,$checktime) = @_;
my(@wdays);
my($time,$thissec,$thismin,$thishour,$today,$mon,$year,$wday,$pfcdate,$thismonth,$thisyear,$thiswday);
my($thisyearf,$thismonthf,$todayf,$thishourf,$thisminf,$thissecf,%time);

# タイムゾーンを定義
$ENV{'TZ'} = "JST-9";
$time = time;

	# リターンなど
	if($type =~ /Now-time/ && !$checktime){ $checktime = time; }
	if(!$checktime){ return(); }

($thissec,$thismin,$thishour,$today,$mon,$year,$wday) = (localtime($checktime))[0..6];

@wdays = ("日","月","火","水","木","金","土");
shift_jis(@wdays);

$thiswday = $wdays[$wday];

# グローバル関数化
$thismonth = $mon+1;
$thisyear = $year+1900;

# sprinft
$thisyearf = $thisyear;
($thismonthf) = sprintf("%02d",$thismonth);
($todayf) = sprintf("%02d",$today);
($thishourf) = sprintf("%02d",$thishour);
($thisminf) = sprintf("%02d",$thismin);
($thissecf) = sprintf("%02d",$thissec);

$time{'ymdf'} = "$thisyearf-$thismonthf-$todayf";

	# 日時のフォーマット
	if($type =~ /Get-second/){
		($time{'date'}) = sprintf("%04d/%02d/%02d %02d:%02d:%02d", $thisyear,$thismonth,$today,$thishour,$thismin,$thissec);
	}
	else{
		($time{'date'}) = sprintf("%04d/%02d/%02d %02d:%02d", $thisyear,$thismonth,$today,$thishour,$thismin);
	}

	# ハッシュで返す場合
	if($type =~ /Get-hash/){

		# 基本的なハッシュを定義
		$time{'year'} = $thisyearf;
		$time{'month'} = $thismonth;
		$time{'day'} = $today;
		$time{'hour'} = $thishour;
		$time{'min'} = $thismin;
		$time{'sec'} = $thissec;
		$time{'yearf'} = $thisyear;
		$time{'monthf'} = $thismonthf;
		$time{'dayf'} = $todayf;
		$time{'hourf'} = $thishourf;
		$time{'minf'} = $thisminf;
		$time{'secf'} = $thissecf;
		$time{'wday'} = $thiswday;
		$time{'yearf_omited'} = $time{'yearf'};
		$time{'yearf_omited'} =~ s/^..//;

			# 色々なフォーマットの日付を取得
			if($type =~ /Get-hash/){
				($time{'date_forward_day'}) = sprintf("%04d/%02d/%02d", $thisyear,$thismonth,$today);
			}

		return(%time);
	}

# リターン
return($time{'date'},$time,$thisyear,$thismonth,$today,$thishour,$thismin,$thissec,$thiswday,$thismonthf,$todayf,$thishourf,$thisminf,$thissecf,$time{'ymdf'});

}


#-----------------------------------------------------------
# まだ中間処理として扱っているが、メイン関数にしたい
#-----------------------------------------------------------
sub second_to_howlong{

# 宣言
my($use) = shift if(ref $_[0] eq "HASH");
my $lefttime = shift;
my($my_use_device) = Mebius::my_use_device();
my($split_text,$leftyear_text,$leftmonth_text,$leftday_text,$lefthour_text,$leftminute_text,$leftsecond_text,$title_tag_inline,$title_tag,$title_tag_inline);
my $html = new Mebius::HTML;

	# リターン
	if($lefttime eq ""){ return(0); }
	if($lefttime =~ /\D/){ return(0); }
	if($lefttime >= time && $use->{'HowBefore'}){ return("-"); }

# 年計算
my $one_year_unit = (365*24*60*60)+(5*60*60)+(48*60)+(1*46);	# うるう年などを含めた時間を定義
my $leftyear = int($lefttime / $one_year_unit);
my $leftyear_second = $leftyear * $one_year_unit;

# 月計算 ( 年時間は除く )
my $one_month_unit = 30.43685*24*60*60;
my $leftmonth = int(($lefttime - $leftyear_second) / $one_month_unit);
my $leftmonth_second = $leftmonth * $one_month_unit;

# 日計算 ( 年月時間は除く )
my $one_day_unit = 24*60*60;
my $leftday = int(($lefttime - $leftyear_second - $leftmonth_second) / $one_day_unit);
my $leftday_second = $leftday * $one_day_unit;

# 時計算 ( 年月日時間は除く )
my $one_hour_unit = 60*60;
my $lefthour = int(($lefttime - $leftyear_second - $leftmonth_second - $leftday_second) / $one_hour_unit);
my $lefthour_second = $lefthour * $one_hour_unit;

# 分計算 ( 年月日時時間は除く )
my $one_minute_unit = 60;
my $leftminute = int(($lefttime - $leftyear_second - $leftmonth_second - $leftday_second - $lefthour_second) / $one_minute_unit);
my $leftminute_second = $leftminute * $one_minute_unit;

# 秒計算 ( 割り切り )
my $leftsecond = int($lefttime % 60);

	# 年の表示
	if($leftyear){
			if($use->{'OmitTopTime'}){ $leftyear += 1; }
		$leftyear_text = qq($leftyear年);
	}

	# 月の表示
	if($leftmonth){
			if($use->{'OmitTopTime'}){ $leftmonth += 1; }
		$leftmonth_text = qq($leftmonthヶ月);
	}

	# 日の表示
	if($use->{'not_get_level'} ne "day"){
		if($leftmonth || $leftday){
				if($use->{'OmitTopTime'}){ $leftday += 1; }
			$leftday_text = qq($leftday日);
		}
	}

	# ▼日までだけ取得するのでなければ、時分秒を取得
	if($use->{'GetLevel'} ne "day"){

			# 時間の表示
			if($use->{'not_get_level'} ne "hour"){
				if($leftmonth || $leftday || $lefthour){
						if($use->{'OmitTopTime'}){ $lefthour += 1; }
					$lefthour_text = qq($lefthour時間);
				}
			}

			# ▼時までだけ取得するのでなければ、分秒を取得
			if($use->{'GetLevel'} ne "hour"){

					# 分の表示
					if($use->{'not_get_level'} ne "minute"){
							if($leftmonth || $leftday || $lefthour || $leftminute){
									if($use->{'OmitTopTime'}){ $leftminute += 1; }
								$leftminute_text = qq($leftminute分);
							}
					}

					# ▼分までだけ取得するのでなければ、秒を取得
					if($use->{'GetLevel'} ne "minute"){
							# 秒の表示
							if($use->{'not_get_level'} ne "second"){
									if($use->{'OmitTopTime'}){ $leftsecond += 1; }
								$leftsecond_text = qq($leftsecond秒);
							}
					}

			}

	}

	# 最上位の単位のみを取得する場合
	if($use->{'TopUnit'} || $use->{'GetLevel'} eq "top"){
			if($leftyear){ $split_text = $leftyear_text; }
			elsif($leftmonth){ $split_text = $leftmonth_text; }
			elsif($leftday){ $split_text = $leftday_text; }
			elsif($lefthour){ $split_text = $lefthour_text; }
			elsif($leftminute){ $split_text = $leftminute_text; }
			else{ $split_text = $leftsecond_text; }
	}
	else{
		$split_text = qq($leftyear_text$leftmonth_text$leftday_text$lefthour_text$leftminute_text$leftsecond_text);
	}

	# ちょっとした空白表示
	if($use->{'BlankView'}){
		$split_text =~ s/(日|時間|分|秒)/ $1/g;
	}

	# テキスト整形
	if($use->{'HowBefore'}){
		$split_text .= qq(前);
	}	elsif($use->{'HowAfter'}){
		$split_text .= qq(後);
	}


	# 色付け
	if($use->{'ColorView'}){

		my($style,$class);

			if($lefttime < 1*60*60){
					if($my_use_device->{'mobile_flag'}){
						$style = "color:#f00;";
					} else {
						$class = "red";
					}
			} elsif($lefttime < 24*60*60){
					if($my_use_device->{'mobile_flag'}){
						$style = "color:#080;";
					} else {
						$class = "gre";
					}

			} elsif($lefttime < 7*24*60*60){
				$class = "blk";
			} else{
				$style = "color:#555;";
			}

			if($use->{'HowBefore'}){
				my($date) = Mebius::get_date(time - $lefttime);
				$title_tag_inline = "$date->{'date_till_minute'}";
				$title_tag = qq( title="$title_tag_inline");
			}


			if($use->{'link'}){
				($split_text) = $html->href($use->{'link'} , $split_text , { style => $style , class => $class , no_follow_flag => $use->{'link_nofollow_flag'} , title => $title_tag_inline });
			} else {
				($split_text) = $html->span($split_text,{ style => $style , class => $class , no_follow_flag => $use->{'link_nofollow_flag'} , title => $title_tag_inline });
			}

	}

$split_text;

}



#-----------------------------------------------------------
# 秒数を日/時間/分/秒に変換
#-----------------------------------------------------------
sub SplitTime{

# 宣言
my($type,$lefttime) = @_;
my(%relay_use);

	if($type =~ /Color-view/){ $relay_use{'ColorView'} = 1; }
	if($type =~ /Blank-view/){ $relay_use{'BlankView'} = 1; }
	if($type =~ /Omit-top-time/){ $relay_use{'OmitTopTime'} = 1; }
	if($type =~ /Plus-text-/){ $relay_use{'HowBefore'} = 1;  }
	if($type =~ /Not-get-([a-z]+)/){ $relay_use{'not_get_level'} = $1; }
	if($type =~ /Get-top-unit/){ $relay_use{'TopUnit'} = 1; }
	elsif($type =~ /Get-till-([a-z]+)/){ $relay_use{'GetLevel'} = $1; }

my($howlong) = second_to_howlong(\%relay_use,$lefttime);
shift_jis($howlong);

$howlong;


}

#-----------------------------------------------------------
# 掲示板の日付を分解
#-----------------------------------------------------------
sub SplitMebiDate{

# 宣言
my($type,$date) = @_;
my(%date);

	# 汚染チェック
	if($date eq ""){ return(); }

# 分解
($date{'year_month_day'},$date{'hour_min_sec'}) = split(/\s/,$date);
($date{'year'},$date{'month'},$date{'day'}) = split(/\//,$date{'year_month_day'});
($date{'hour'},$date{'min'},$date{'sec'}) = split(/:/,$date{'hour_min_sec'});

	# 各種補完
	if($date{'month'} eq ""){ $date{'month'} = 1; }
	if($date{'sec'} eq ""){ $date{'sec'} = 00; }

	# グリニッジ標準時を取得
	if($date{'year'} && $date{'month'} && $date{'day'}){
		($date{'time'}) = Time::Local::timelocal($date{'sec'},$date{'min'},$date{'hour'},$date{'day'},$date{'month'}-1,$date{'year'});
	}

return(%date);

}

#-----------------------------------------------------------
# 時刻
#-----------------------------------------------------------
sub TimeLocal{

my($type,$year,$month,$day,$hour,$minute,$second) = @_;
	if($type =~ /Relay-reverse/){ (undef,$second,$minute,$hour,$day,$month,$year) = @_; }
my($time,$pure_year);

# タイムゾーンを定義
$ENV{'TZ'} = "JST-9";

	# 汚染チェック
	if($year =~ /\D/){ return(undef,"年に半角数字以外が指定されています。"); }
	if($month =~ /\D/){ return(undef,"月に半角数字以外が指定されています。"); }
	if($day =~ /\D/){ return(undef,"日に半角数字以外が指定されています。"); }
	if($hour =~ /\D/){ return(undef,"時間に半角数字以外が指定されています。"); }
	if($minute =~ /\D/){ return(undef,"分に半角数字以外が指定されています。"); }
	if($second =~ /\D/){ return(undef,"秒に半角数字以外が指定されています。"); }

	# 指定がない場合の代入
	if(!$year){ return(undef,"年は必ず指定してください。"); }
	if(!$month){ $month = "01"; }
	if(!$day){ $day = "01"; }

	# 日のチェック
	if($day > 31){ return(undef,"日に指定できるのは３１日までです。"); }

	# ●月のチェック
	if($month){

			# 妙な月指定は除外する
			if($month > 12){ return(undef,"$month月という月はありません。"); }

			# 30日までしかない月のチェック
			if($month =~ /^(4|6|9|11)$/ && $day && $day > 30){
				return(undef,"$month月は30日までしかありません。");
			}

			# ２月のチェック
			if($month =~ /^(2)$/ && $day && $day > 28 && $year && $year % 4 != 0){
				return(undef,"$year年の$month月は28日までしかありません。");
			}

			# ２月のチェック
			if($month =~ /^(2)$/ && $day && $day > 29){
				return(undef,"$year年の$month月は29日までしかありません。");
			}

	}

	# ●1970年以前の場合
	if($year < 1970){
		$pure_year = $year;
		$year = 1970;
	}

# グリニッジ標準時を取得
$time = Time::Local::timelocal($second,$minute,$hour,$day,$month-1,$year);

	# 1970年以前の場合
	if($pure_year){
		$time -= int ( (1970 - $pure_year) * 365.24219*24*60*60 );
	}

return($time);

}

#-----------------------------------------------------------
# 日付からグリニッジ標準時を計算し、さらに日付を計算する (曜日の補完)
#-----------------------------------------------------------
sub TimeLocalDate{

my($type,$year,$month,$day,$hour,$minute,$second) = @_;

my($time_local) = Mebius::TimeLocal(undef,$year,$month,$day,$hour,$minute,$second);

my(%date) = Mebius::Getdate("Get-hash",$time_local);

return(%date);

}


1;

