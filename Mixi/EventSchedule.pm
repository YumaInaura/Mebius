
package Mebius::Mixi::EventSchedule;

use strict;

use Mebius::HTML;
use Mebius::Time;
use Mebius::Query;

#use Time::Piece;

use base qw(Mebius::Base::DBI Mebius::Base::Data);
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"mixi_event_schedule";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {
target => { PRIMARY => 1 } , 
event_target => { } ,
event_date => { date => 1 } , 
start_time_strong => { time => 1 } ,
end_time_strong => { time => 1 } , 
deadline_time_strong => { time => 1 } , 
reception_time_strong => { time => 1  } ,
deleted_flag => { int => 1 } , 

};

$column;

}

#-----------------------------------------------------------
# スケジュールを登録する
#-----------------------------------------------------------
sub submit_schedule{

my $self = shift;
my $target = shift;
my $event_date = shift;
my $start_time = shift;
my $end_time = shift;
my $deadline_time = shift;
my $event_target = shift;
my $type = shift;
my $times = new Mebius::Time;
my($data,%update,$data_exists);

	if($target){
		$update{'target'} = $target;
		$data = $data_exists = $self->fetchrow_main_table({ target => $target });
	}

my $start_localtime = $times->datetime_to_localtime("${event_date}T${start_time}");
#my $end_localtime = $times->datetime_to_localtime("${event_date}T${end_time}");
#my $deadline_localtime = $times->datetime_to_localtime("${event_date}T${deadline_time}");

$update{'event_date'} = $event_date;
$update{'start_time_strong'} = $start_time;

	if($end_time =~ /^[0-9]+$/){
		$update{'end_time_strong'} = $times->hms($start_localtime+(2*60*60));
	} else {
		$update{'end_time_strong'} = $end_time;
	}

	if($deadline_time =~ /^[0-9]+$/){
		$update{'deadline_time_strong'} = $times->hms($start_localtime-(1*60*60));
	} else {
		$update{'deadline_time_strong'} = $deadline_time;
	}

$update{'event_target'} = $event_target;

	#if(Mebius::alocal_judge() && $type eq 'create'){
		#Mebius::Debug::Error(qq($update{'start_time_strong'} / $update{'end_time_strong'} / $update{'deadline_time_strong'}));
	#}

	if($data_exists){
		$self->update_main_table(\%update);
	} else {
		$self->insert_main_table(\%update,{ Debug => 0	 });
	}



}

#-----------------------------------------------------------
# 時刻のセレクトエリア
#-----------------------------------------------------------
sub event_data_to_date_select_parts{

my $self = shift;
my $event_data = shift;
my $schedule = new Mebius::Mixi::EventSchedule;
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my($print);

my $schedule_data_group = $self->useful_schedule_data_group($event_data);

	# 決まっているスケジュール
	foreach my $schedule_data (@{$schedule_data_group}){
		$print .= qq(<div>);
		$print .= $self->selects($schedule_data,$event_data);
		$print .= qq(</div>);
	}

	# スケジュールの追加欄
	for my $num (1..3){
		$print .= qq(<div>);
		$print .= $self->selects(undef,$event_data,$num);
		$print .= qq(</div>);

	}

	# 一定期間後までのフォームを作る
	for my $round (1..16){
		$print .= $self->next_interval_form($event_data,$round); # $round * 7day = 1week 
	}

	# 「1週間後」などの登録
	# 現在のスタート時刻より1週間後
	#if(@{$schedule_data_group} <= 0){

	#}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub next_interval_form{

my $self = shift;
my $event_data = shift;
my $round = shift;
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my($print);

my $week = $round*7;

my $datetime = $times->datetime($event_data->{'start_time'}+$week*24*60*60,"T");
my $ymd = $times->ymd($event_data->{'start_time'}+$week*24*60*60);
my $his = $times->his($event_data->{'start_time'}+$week*24*60*60);
my $end_his = $times->his($event_data->{'end_time'}+$week*24*60*60);
my $deadline_his = $times->his($event_data->{'deadline_time'}+$week*24*60*60);

$print .= qq(<div>);
$print .= $html->input("checkbox","event_date_new_10${round}_$event_data->{'target'}",$ymd,{ text => "$ymd" });
$print .= $html->input("time","start_time_strong_new_10${round}_$event_data->{'target'}",$his);
$print .= $html->input("time","end_time_strong_new_10${round}_$event_data->{'target'}",$end_his);
$print .= $html->input("time","deadline_time_strong_new_10${round}_$event_data->{'target'}",$deadline_his);
$print .= qq(</div>);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_schedule_data_group{

my $self = shift;
my $event_data = shift || (warn && return());
my $times = new Mebius::Time;

my $now_ymd = $times->ymd(time);

#my $now_hms = $times->hms(time);
#start_time_strong => [">=",$now_hms]

my $data_group = $self->fetchrow_main_table({
	event_target => $event_data->{'target'} , 
	event_date => [">=",$now_ymd] ,
	deleted_flag => "0"
	}, 
		{ Debug => 0 , ORDER_BY => ["event_date ASC","start_time_strong ASC"] }
);

$data_group;

}


#-----------------------------------------------------------
# スケジュールを更新する
#-----------------------------------------------------------
sub update_event_data_with_useful_schedule{

my $self = shift;
my $event_data = shift;
my $event = new Mebius::Mixi::Event;
my $times = new Mebius::Time;
my(%update,$start_time,$end_time,$deadline_time,$flag);

	if(!$event_data->{'event_auto_submit_flag'}){
		return();
	}

console "Event schedue update with useful schedules";
my $useful_schedule_data = $self->useful_schedule_data_group($event_data)->[0] || (warn("No useful schedules found") && return());

	# 元のイベントが今日以降の場合だけ
	if(time >= $event_data->{'end_time'}){
		$update{'target'} = $event_data->{'target'};
		$update{'start_time'} = $times->datetime_to_localtime("$useful_schedule_data->{'event_date'}T$useful_schedule_data->{'start_time_strong'}");
		$update{'end_time'} = $times->datetime_to_localtime("$useful_schedule_data->{'event_date'}T$useful_schedule_data->{'end_time_strong'}");
		$update{'deadline_time'} = $times->datetime_to_localtime("$useful_schedule_data->{'event_date'}T$useful_schedule_data->{'deadline_time_strong'}");
		$update{'schedule_target'} = $useful_schedule_data->{'target'};

		$event->update_main_table(\%update,{ Debug => 0 });
		$flag = 1;
	}

$flag;

}



#-----------------------------------------------------------
# 最も最近のデータを定義
#-----------------------------------------------------------
sub most_latley_data{

my $self = shift;
my $target = shift || (warn && return());
my $times = new Mebius::Time;

my $border_datetime = $times->datetime(time-2*60*60);

my $border_ymd = $times->ymd(time-2*60*60);
my $border_hms = $times->hms(time-2*60*60);

my $data = $self->fetchrow_main_table_asc({ event_target => $target , "event_date+start_time_strong" => [">=",$border_datetime]  ,  end_time_strong => [">",$border_hms]  },"event_date+start_time_strong",{ Debug => 0 })->[0];

$data;

}


#-----------------------------------------------------------
# 時刻のセレクトボックス
#-----------------------------------------------------------
sub selects{

my $self = shift;
my $data = my $data_exists = shift;
my $event_data = shift;
my $target = shift;
my $use = shift || {};
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my($print,$input_name_plus,$min);

my $event_target = $event_data->{'target'};

	if($data_exists){
		$input_name_plus = "$data->{'target'}";
	} else {
		$input_name_plus = "new_$target";
		#$min = $times->datetime(time);
	}

$print .= qq(日付 );
$print .= $html->input("date","event_date_${input_name_plus}_$event_target",$data->{'event_date'},{ min => $min ,style => "width:10em;" });

$print .= qq( 開始 );
$print .= $html->input("time","start_time_strong_${input_name_plus}_$event_target",$data->{'start_time_strong'},{ min => $min , step => 5*60 , style => "width:5em;" });

$print .= qq( / 終了 );

	if($data->{'end_time_strong'}){
		$print .= $html->input("time","end_time_strong_${input_name_plus}_$event_target",$data->{'end_time_strong'},{ min => $min , step => 5*60 , style => "width:5em;" });
	} else {
		$print .= $html->input("number","end_time_strong_${input_name_plus}_$event_target",2*60,{ min => $min , step => 5 , style => "width:4em;" });
		$print .= "分後";
	}

$print .= qq( / 締切 );
	if($data->{'deadline_time_strong'}){
$print .= $html->input("time","deadline_time_strong_${input_name_plus}_$event_target",$data->{'deadline_time_strong'},{  min => $min , step => 5*60 , style => "width:5em;" });
	} else {
		$print .= $html->input("number","deadline_time_strong_${input_name_plus}_$event_target",1*60,{ min => $min , step => 5 , style => "width:4em;" });
		$print .= "分前";
	}

$print .= " " . e($data->{'target'});

	# 削除のためのチェックボックス
	if($data->{'target'}){
		$print .= " ( " . $html->input("checkbox","event_schecule_control_$data->{'target'}","delete",{ text => "削除" }) . " )";
	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub query_to_submit_schedule{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();

	foreach my $key ( keys %{$param} ){

		my $value = $param->{$key};

			if($key =~ /^event_date_([a-zA-Z0-9]+)_([a-zA-Z0-9]+)$/ && $value){

				my $target = $1;
				my $event_target = $2;
				$self->submit_schedule($target,$param->{"event_date_${target}_${event_target}"},$param->{"start_time_strong_${target}_${event_target}"},$param->{"end_time_strong_${target}_${event_target}"},$param->{"deadline_time_strong_${target}_${event_target}"},$event_target,'update');

			} elsif($key =~ /^event_date_new_([0-9]+)_([a-zA-Z0-9]+)$/ && $value){

				my $target = $1;
				my $event_target = $2;

$self->submit_schedule("",$param->{"event_date_new_${target}_${event_target}"},$param->{"start_time_strong_new_${target}_${event_target}"},$param->{"end_time_strong_new_${target}_${event_target}"},$param->{"deadline_time_strong_new_${target}_${event_target}"},$event_target,'create');

			}	elsif($key =~ /^event_schecule_control_([a-zA-Z0-9]+)$/ && $value){

				my $target = $1;

					if($value eq "delete"){
						$self->update_main_table({ target => $target , deleted_flag => "1" },{ Debug => 0 });
					}

			}

		my $value = $param->{$key};

	}

}




1;