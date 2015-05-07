
package Mebius::Mixi::Event;

use strict;

use Mebius::Mixi::Basic;
use Mebius::Mixi::Community;
use Mebius::Mixi::Account;
use Mebius::Mixi::Navitomo;
use Mebius::Mixi::Submit;
use Mebius::Mixi::EventSchedule;

use Mebius::View;
use Mebius::Form;

use Mebius::Query;
use Mebius::Move;
use Mebius::Time;

use Mebius::Export;
use base qw(Mebius::Base::DBI Mebius::Base::Data);

our $order;

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
sub limited_package_name{
"event";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic_object{
my $object = new Mebius::Mixi;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"mixi_event";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub set_order{

my $self = shift;
my $event_data = shift;
my $count = shift;

our $order = $event_data->{'last_order'}+1;

	if( $order > $count ){
		$order = 1;
	}

return $order;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub order{
return our $order;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------

sub view_order_title_and_body{

my $self = shift;
my $data = shift;
my($print);

my($order_title,$order_bbs_body) = $self->order_title_and_body($data);

$print .= qq(<div>);
$print .= qq(<h3> ランダムタイトル ).e($order_title).qq(</h3>);
$print .= qq(ランダム文章 ).e($order_bbs_body);
$print .= qq(</div>);

$print;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub order_title_and_body{

my $self = shift;
my $event_data = shift;
my($count);

	for my $num (1..$self->max_kinds()){

			if($event_data->{"title$num"} && $event_data->{"bbs_body$num"}){
				$count++;
			} else {
				0;
			}
	}

my $rand = $self->set_order($event_data,$count);

my $title = $self->effect($event_data->{"title$rand"},$event_data);
my $bbs_body = $self->effect($event_data->{"bbs_body$rand"},$event_data);

return($title,$bbs_body);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();

	if($param->{'mode'} eq "submit_event"){
		$self->self_view();
		1;
	} elsif($param->{'mode'} eq "submit_event_do"){
		$self->submit();
		1;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {
target => { PRIMARY => 1 } ,
series_target => { } , 

navitomo_event_id1 => { } , 
navitomo_event_id2 => { } , 
navitomo_event_id3 => { } , 

title => { text => 1 } ,
title1 => { text => 1 } ,
title2 => { text => 1 } ,
title3 => { text => 1 } ,
title4 => { text => 1 } ,
title5 => { text => 1 } ,

bbs_body => { text => 1 } , 
bbs_body1 => { text => 1 } , 
bbs_body2 => { text => 1 } , 
bbs_body3 => { text => 1 } , 
bbs_body4 => { text => 1 } , 
bbs_body5 => { text => 1 } , 

comment_body => { text => 1 } , 

schedule_body => { text => 1 } , 

contact_account => { } , 

start_time => { INDEX => 1 , int => 1 } , 
end_time => { int => 1 } , 

start_year => { int => 1 },
start_month => { int => 1 },
start_day => { int => 1 },
start_hour => { int => 1 },
start_minute => { int => 1 },

end_hour => { int => 1 } ,
end_minute => { int => 1 } ,
deadline_time => { int => 1 } ,

weekday => { } , 

location_pref_id => { int => 1 } , 
location_note => { } , 
create_time => { int => 1 } ,
last_modified => { int => 1 } ,
high_age => { int => 1 } ,
low_age => { int => 1 } , 
man_charge => { int => 1 } ,
lady_charge => { int => 1 } ,
deleted_flag => { int => 1 } ,
forced_deleted_flag => { int => 1 } , 

event_auto_submit_flag => { int => 1 } ,
topic_auto_submit_flag => { int => 1 } ,
submit_doing_flag => { int => 1 } ,

topic_type => { },

sex_target => { } , 
event_kind => { } , 

event_kinds => { } , 

edit_decide_time => { int => 1 } , 
schedule_target => { } , 

last_order => { } , 

photo1 => { } ,
photo2 => { } ,
photo3 => { } ,


};

$column;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub self_view{

my $self = shift;
my $error = shift;
my $basic = $self->basic_object();
my $mixi_url = $basic->mixi_url();
my $html = new Mebius::HTML;
my $community = new Mebius::Mixi::Community;
my $submit_event = new Mebius::Mixi::Submit;
my $query = new Mebius::Query;
my $param  = $query->param();
my $view = new Mebius::View;
my $schedule = new Mebius::Mixi::EventSchedule;
my($print,$data,$target,$topic_data_group,$event_data_group,$list);

my $site_url = $basic->site_url();

my @links = (
{ url => "${site_url}?mode=submit_event" , title => "今後のイベント" } , 
{ url => "${site_url}?mode=submit_event&view=old" , title => "古いイベント" } , 
);

$print .= $view->on_off_links(\@links);


my $schedule_data = $schedule->most_latley_data($param->{'target'});

	if( $target = $param->{'target'} ){

		$data = $self->useful_event_data_with_refresh($target);
	}


	if($param->{'view'} eq "old"){
		$topic_data_group = $self->fetchrow_main_table_desc({ end_time => ["<",time] , deleted_flag => 0 , topic_auto_submit_flag => 1 },'start_time');
		$event_data_group = $self->fetchrow_main_table_desc({ end_time => ["<",time] , deleted_flag => 0 , event_auto_submit_flag => 1 },'start_time');
	} else {
		$topic_data_group = $self->fetchrow_main_table_desc({ end_time => [">=",time] , deleted_flag => 0 , topic_auto_submit_flag => 1 },'start_time');
		$event_data_group = $self->fetchrow_main_table_desc({ end_time => [">=",time] , deleted_flag => 0 , event_auto_submit_flag => 1 },'start_time');
	}

$list .= $html->tag("h2","トピック");
$list .= $self->data_group_to_list($topic_data_group);
$list .= $html->tag("h2","イベント");
$list .= $self->data_group_to_list($event_data_group);

$print .= $self->around_control_form($list);

my $page_title = "イベントの管理";
my $title = $self->effect($data->{'title'},$data);

$print .= $basic->error_to_message($error);

	if($param->{'target'}){
		$print .= $html->tag("h2","$title - の編集",{ style => "color:green;" , id => "EDIT_FORM" });
	} else {
		$print .= $html->tag("h2","新規登録");
	}

$print .= $self->submit_event_form($data);

	if( $target && $data && (my $data_group = $submit_event->fetchrow_main_table_desc({ event_target => $target , submit_type => "post" },"create_time"))){
		$print .= $html->tag("h2","新規登録");
		$print .= $submit_event->data_group_to_list($data_group);
	}

	if( $target && $data && (my $data_group = $submit_event->fetchrow_main_table_desc({ event_target => $target , submit_type => "comment" },"create_time"))){
		$print .= $html->tag("h2","コメント");
		$print .= $submit_event->data_group_to_list($data_group);
	}


#).e($mixi_url).q(add_event.pl

$basic->print_html($print,{ title => $page_title , h1 => $page_title , change_encode => "euc-jp" });

exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_data_group{

my $self = shift;
my $topic_type = shift;

my $fetch = $self->useful_sql($topic_type);
my $data_group = $self->fetchrow_main_table_asc($fetch,"start_time",{ Debug => 0 });

$data_group;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_sql{

my $self = shift;
my $topic_type = shift;
my $console = new Mebius::Console;
my(%fetch);

$fetch{'deleted_flag'} = 0;

	if($topic_type eq "topic"){
		$fetch{'end_time'} = [">",time];
		$fetch{'topic_auto_submit_flag'} = 1;

	} elsif($topic_type eq "out_comment"){
		$fetch{'end_time'} = [">",time];
		$fetch{'event_auto_submit_flag'} = 1;

	} elsif($topic_type eq "event"){
		$fetch{'event_auto_submit_flag'} = 1;

	}

	if($console->option("-preview")){
		$fetch{'submit_doing_flag'} = 1;
	}

\%fetch;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_event_data_with_refresh{

my $self = shift;
my $data_or_target = shift || (warn("Event data is empty.") && return());
my $schedule = new Mebius::Mixi::EventSchedule;
my($data,$target);

	if(ref $data_or_target eq "HASH"){
		$data = $data_or_target;
	} else {
		$data = $self->fetchrow_main_table({ target => $data_or_target })->[0];
	}

my $target = $data->{'target'};

		if($schedule->update_event_data_with_useful_schedule($data)){
			$data = $self->fetchrow_main_table({ target => $target })->[0];
		}

$data;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_event_form{

my $self = shift;
my $data = my $data_exists = shift;
my $query = new Mebius::Query;
my $community = new Mebius::Mixi::Community;
my $navitomo = new Mebius::Mixi::Navitomo;
my $submit_event = new Mebius::Mixi::Submit;
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my $form = new Mebius::Form;
my $param  = $query->param();
my $schedule = new Mebius::Mixi::EventSchedule;
my($print,$event_flag,$topic_flag);

	if($data->{'topic_auto_submit_flag'}){
		$topic_flag = 1;
	}	
	
	if($data->{'event_auto_submit_flag'}){
		$event_flag = 1;
	}

my $submit_button = qq(<div style="margin:1em 0em;">);

$submit_button .= qq(<input type="submit" style="font-size:100%;" value="イベントを記録する">\n);

	if($data && $submit_event->fetchrow_main_table({ event_target => $data->{'target'} })->[0]){
		#$submit_button .= $html->input("submit","out_sites_edit","イベントを記録してmixiも更新する",{ style => "font-size:100%;	" });
	}

$submit_button .= qq(</div>);

$print .= q(<form name="bbs_form" action="#EDIT_FORM" method="post" enctype="multipart/form-data" style="line-height:2em;">);

$print .= $submit_button;

$print .= qq(<div>);
#$print .= qq(全体のタイトル);
$print .= $html->input("text","title",$data->{'title'},{ style => "width:30em;font-size:140%;" });

$print .= qq(</div>);

$print .= q(<input type="hidden" name="mode" value="submit_event_do">);

$print .= qq(<div>);

$print .= $html->input("checkbox","topic_auto_submit_flag",1,{ checked => $data->{"topic_auto_submit_flag"} , text => "トピックへの投稿" });
$print .= $html->input("checkbox","event_auto_submit_flag",1,{ checked => $data->{"event_auto_submit_flag"} , text => "イベントへの投稿" });
$print .= $html->input("checkbox","submit_doing_flag",1,{ checked => $data->{"submit_doing_flag"} , text => "自動登録の対象にする" });

	if($event_flag)	{
		$print .= $html->input("checkbox","edit_decide_time",1,{ checked => $data->{'edit_decide_time'} , text => "編集対象にする" });
	}

	if($data_exists){
		$print .= $html->input("checkbox","new_event",1,{ text => "新しいイベントとして記録する" });
	}
$print .= $html->input("checkbox","deleted_flag",1,{ checked => $data->{"deleted_flag"} , text => "削除する" });


$print .= qq(</div>);


$print .= qq(<div>);
$print .= $self->datetime_parts($data);
$print .= qq(</div>);

$print .= $html->input("hidden","target",$data->{'target'});

	if($data->{'navitomo_event_id'}){
		#$data = $navitomo->id_to_get_html_event_data($data->{'navitomo_event_id'});
	}

	if($event_flag){
		$print .= qq(<div>);
		$print .= $schedule->event_data_to_date_select_parts($data);
		$print .= qq(</div>);
	}


$print .= qq(<div>);




$print .= qq(<div>);
$print .= qq(●イベントの種類 );
$print .= $self->event_kinds_check_box("event_kinds",$data->{'event_kinds'});
$print .= qq(</div>);



$print .= qq(<div>);
$print .= qq(●対象の性別 );
my @sex_target= $self->sex_target();
$print .= $form->radio_parts(\@sex_target,"sex_target",$data->{'sex_target'});
$print .= qq(</div>);

$print .= qq(<div>);
$print .= qq(●対象年齢 );
$print .= $community->target_old_radio_parts($data,"target_old");
$print .= qq(</div>);

$print .= qq(<div>);
$print .= qq(●開催場所 );
#$print .= qq(<select name="location_pref_id">);

$print .= $self->todoufuken_radio_parts($data->{'location_pref_id'});

#$print .= qq(</select>);
$print .= qq(\補足：<input name="location_note" value="" size="30" /> </div>);

$print .= qq(<div>);
$print .= qq(<h3>スケジュール</h3>);
$print .= qq(<textarea cols="75" rows="15" name="schedule_body" style="width:60%;height:30em;" placeholder="スケジュール">).e($data->{"schedule_body"}).qq(</textarea>);
$print .= qq(</div>);

	if(Mebius::alocal_judge()){
		$print .= $self->view_order_title_and_body($data);
	}

	for my $num (1..$self->max_kinds()){

		$print .= qq(<div>);
		#$print .= qq(<p>文章).e($num).qq(</p>);
		$print .= qq(<h3>[).e($num).qq(]</h3>);

		$print .= $html->input("text","title$num",$data->{"title$num"},{ style => "width:30em;font-size:140%;" });
		$print .= qq(<textarea cols="75" rows="15" name="bbs_body).e($num).qq(" style="width:60%;height:40em;" placeholder="新規投稿">).e($data->{"bbs_body$num"}).qq(</textarea>);
		$print .= qq(</div>);
	}

$print .= qq(<div>);
$print .= qq(<h3>コメント</h3>);
$print .= qq(<textarea cols="75" rows="15" name="comment_body" style="width:60%;height:20em;" placeholder="コメント">).e($data->{"comment_body"}).qq(</textarea>);
$print .= qq(</div>);

$print .= $submit_button;

	if( my $bbs_body = $data->{"bbs_body"}){
		$bbs_body = e($bbs_body);
		$bbs_body = $self->effect($bbs_body,$data);
		$bbs_body =~ s/\n/<br>/g;
		$print .= qq(<div>);
		$print .= $bbs_body;
		$print .= qq(</div>);
		$print .= $submit_button;
	}


$print .= qq(</div></form>);

$print;


}



#-----------------------------------------------------------
# 日付の選択欄
#-----------------------------------------------------------
sub max_kinds{
5;
}

#-----------------------------------------------------------
# 日付の選択欄
#-----------------------------------------------------------
sub datetime_parts{

my $self = shift;
my $data = shift;
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my($print);

my $start_datetime = $times->datetime($data->{'start_time'});
my $end_datetime = $times->datetime($data->{'end_time'});
$print .= $html->input("datetime-local","start_datetime",$start_datetime,{ step => 15*60 , style => "width:15em;" });

	if($data->{'start_time'}){
		$print .= " (" . $times->weekday_japanese($data->{'start_time'}) . ") ";
	}

$print .= qq( - );
$print .= $html->input("datetime-local","end_datetime",$end_datetime,{ step => 15*60 , style => "width:15em;" });
	if($data->{'end_time'}){
		$print .= " (" . $times->weekday_japanese($data->{'end_time'}) . ") ";
	}

my $deadline_datetime = $times->datetime($data->{'deadline_time'});
$print .= $html->input("datetime-local","deadline_datetime",$deadline_datetime,{ step => 5*60 , style => "width:15em;" });

$print .= $html->input("text","schedule_target",$data->{'schedule_target'},{ placeholder => "スケジュールターゲット" });

$print .= $self->contact_accounts_select_box($data);

	if( my $contact_account = $data->{'contact_account'}){
		$print .= $html->href("http://mixi.jp/show_friend.pl?id=$contact_account","[mixi]");
	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub contact_accounts_select_box{

my $self = shift;
my $event_data = shift;

my($print);

my $account = new Mebius::Mixi::Account;
my $account_data_group = $account->fetchrow_main_table({ account_type => "special" });

$print .= '<select name="contact_account">'."\n";
$print .= '<option value="">受付用アカウント</option>'."\n";

	foreach my $account_data (@{$account_data_group}){

		my($selected);
		my $name = $account_data->{'nickname'} || $account_data->{'account'} || next;

			if(!$account_data->{'account'}){
				next;
			}

			if($event_data->{'contact_account'} eq $account_data->{'account'}){
				$selected = ' selected';
			}

		$print .= '<option value="'.h($account_data->{'account'}).'"'.h($selected).'>';
		$print .= h($name)."\n";
		$print .= '</option>'."\n";
	}

$print .= '</select>'."\n";

#$print .= $html->input("number","contact_account",$data->{'contact_account'} || "" ,{ min => "0" ,  style => "width:10em;"  , placeholder => "受付アカウント" });

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub control{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();

	foreach my $key ( keys %{$param} ){
		my $value = $param->{$key};
			if($key =~ /^mixi_community_event_control_([0-9a-zA-Z]+)$/){
				my $target = $1;
					if($value eq "delete"){
						$self->update_main_table({ target => $target , deleted_flag => 1 });
					}
			}
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit{

my $self = shift;
my $query = new Mebius::Query;
my $community = new Mebius::Mixi::Community;
my $submit_event = new Mebius::Mixi::Submit;
my $move = new Mebius::Move;
my $times = new Mebius::Time;
my $schedule = new Mebius::Mixi::EventSchedule;
my $basic = $self->basic_object();
my $param  = $query->param();
my(%insert,$data,$target);

	if( $target = $param->{'target'} ){
		$data = $self->fetchrow_main_table({ target => $target })->[0];
	}

$insert{'title'} = $param->{'title'} || $self->self_view("タイトルを入力してください。");
$insert{'bbs_body'} = $param->{'bbs_body'};

	for my $num (1..$self->max_kinds()){
		$insert{"title$num"} = $param->{"title$num"};
		$insert{"bbs_body$num"} = $param->{"bbs_body$num"};
	}

$insert{'comment_body'} = $param->{'comment_body'};

$insert{'schedule_body'} = $param->{'schedule_body'};
$insert{'contact_account'} = $param->{'contact_account'};

$insert{'event_auto_submit_flag'} = $param->{'event_auto_submit_flag'};
$insert{'topic_auto_submit_flag'} = $param->{'topic_auto_submit_flag'};
$insert{'submit_doing_flag'} = $param->{'submit_doing_flag'};
$insert{'deleted_flag'} = $param->{'deleted_flag'};
$insert{'schedule_target'} = $param->{'schedule_target'};

$insert{'location_pref_id'} = $param->{'location_pref_id'};
$insert{'location_note'} = $param->{'location_note'};

	for(1..3){
		if($param->{"navitomo_event_id$_"} =~ /^([0-9a-zA-Z]+)$|^$/){
			$insert{"navitomo_event_id$_"} = $param->{"navitomo_event_id$_"};
		}
	}

	$insert{'location_note'} = $param->{'location_note'};

$insert{'series_target'} = $param->{'series_target'};

$insert{'man_charge'} = $param->{'man_charge'};
$insert{'lady_charge'} = $param->{'lady_charge'};

$insert{'event_kinds'} = $param->{'event_kinds'};
$insert{'sex_target'} = $param->{'sex_target'};

#$insert{'start_year'} = $param->{'start_year'};
#$insert{'start_month'} = $param->{'start_month'};
#$insert{'start_day'} = $param->{'start_day'};

	if($param->{'edit_decide_time'}){
		$insert{'edit_decide_time'} = time;
	}elsif($param->{'edit_decide_time'} eq ""){
		$insert{'edit_decide_time'} = "";
	}


#$insert{'start_hour'} = $times->time_value_to_hour($param->{'start_hour_and_minute'});
#$insert{'start_minute'} = $times->time_value_to_minute($param->{'start_hour_and_minute'});

#$insert{'end_hour'} = $times->time_value_to_hour($param->{'end_hour_and_minute'});
#$insert{'end_minute'} = $times->time_value_to_minute($param->{'end_hour_and_minute'});

$insert{'start_time'} = $times->datetime_to_localtime($param->{'start_datetime'});
$insert{'end_time'} = $times->datetime_to_localtime($param->{'end_datetime'});
$insert{'deadline_time'} = $times->datetime_to_localtime($param->{'deadline_datetime'});

	if($insert{'end_time'} < $insert{'start_time'} || !$insert{'end_time'}){
		$insert{'end_time'} = $insert{'start_time'} + 2*60*60;
	}

	if($insert{'deadline_time'} > $insert{'start_time'} || !$insert{'deadline_time'}){
		$insert{'deadline_time'} = $insert{'start_time'};
	} elsif($insert{'deadline_time'} < $insert{'start_time'} - 3*24*60*60){
		$insert{'deadline_time'} = $insert{'start_time'} - 1*60*60;
	}


$insert{'weekday'} = $times->weekday_or_holiday($insert{'start_time'});

#$insert{'deadline_year'} = $param->{'deadline_year'} || $param->{'start_year'};
#$insert{'deadline_month'} = $param->{'deadline_month'} || $param->{'start_month'};
#$insert{'deadline_day'} = $param->{'deadline_day'} || $param->{'start_day'};

$insert{'high_age'} = $community->param_value_to_high_age($param->{'target_old'});
$insert{'low_age'} = $community->param_value_to_low_age($param->{'target_old'});


$insert{'last_modified'} = time;


	if($data && !$param->{'new_event'}){
		$insert{'target'} = $target;
		$self->update_main_table(\%insert);
	} else {
		$insert{'target'} = $self->new_target();
		$self->insert_main_table(\%insert);
	}


$schedule->query_to_submit_schedule();

	if($data && $param->{'out_sites_edit'}){
		$submit_event->event_data_to_edit_out_sites(\%insert);
	}

my $event_url = $self->data_to_url(\%insert);

$move->redirect($event_url);

#$move->redirect_to_self_url();

exit;



}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $param  = $query->param();
my($print);


$print .= qq(<li>);
	if($param->{'target'} eq $data->{'target'}){
		my $title = e($data->{'title'});
		$print .= $self->effect($title,$data);
	} else {
		$print .= $self->data_to_link($data);
	}

	if($data->{'topic_auto_submit_flag'}){
		$print .= $html->span(" [トピック]",{ style => "color:green;" });
	}
	if($data->{'event_auto_submit_flag'}){
		$print .= $html->span(" [イベント]",{ style => "color:red;" });
	}
	if($data->{'submit_doing_flag'}){
		$print .= $html->span(" [登録]",{ style => "font-weight:bold;color:red;" });
	}



#$print .= $self->data_to_control_parts($data,{ Simple => 1 } );

$print .= qq(</li>);

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $data = shift || return();
my $basic = $self->basic_object();

my $site_url = $basic->site_url();
my $url = "${site_url}?mode=submit_event&target=$data->{'target'}";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_link{

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;

my $url = $self->data_to_url($data);

my $title = $self->effect($data->{'title'},$data);

$html->href($url,$title);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub effect{

my $self = shift;
my $title = shift;
my $event_data = shift || die;
my $event_kind_number = shift;
my $times = new Mebius::Time;
my($mixi_account_url);

my $weekday = $times->weekday_japanese($event_data->{'start_time'});

my $start_year = $times->year($event_data->{'start_time'});
my $start_month = $times->month($event_data->{'start_time'});
my $start_day = $times->day($event_data->{'start_time'});

my $end_year = $times->year($event_data->{'end_time'});
my $end_month = $times->month($event_data->{'end_time'});
my $end_day = $times->day($event_data->{'end_time'});
my $end_weekday = $times->weekday_japanese($event_data->{'end_time'});

my $date = e($start_month) . "/" . e($start_day) . "(" . e($weekday) . ")";

	if("$start_year-$start_month-$start_day" ne "$end_year-$end_month-$end_day"){
		$date .= '-'.e($end_month) . "/" . e($end_day) . "(" . e($end_weekday) . ")";
	}

#my $age = 1;

$title =~ s!\[date\]!$date!gi;
#$title =~ s!\[age\]!$age!gi;
$title =~ s!\[mark\]!$self->random_mark()!gie;
$title =~ s!\[face\]!$self->random_face_mark()!gie;
$title =~ s!\[schedule\]!$event_data->{'schedule_body'}!gie;

	if( my $mixi_account_number = $event_data->{"contact_account"} ){
		$mixi_account_url = "http://mixi.jp/show_friend.pl?id=$mixi_account_number";
	} else {
		$mixi_account_url = "";
	}

$title =~ s!\[(mixi_contact|contact_account|contact)\]!$mixi_account_url!gie;

#		$title =~ s!\[(mixi_contact|contact_account|contact)\]!CCCCC!gie;

$title;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub random_mark{

my $self = shift;
my @mark = qw(★ ☆ ♪ ＠ ◆ □ ■ ○ ●);

my $mark = $mark[int rand(@mark)];

$mark;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub random_face_mark{

my $self = shift;

my @mark = (
'ヾ(￣∇￣=',
'Ｏ(≧∇≦)Ｏ',
'( ^ω^ )',
'＼(^o^)／',
'ヽ(･∀･)ﾉ',
'ヾ(＠⌒ー⌒＠)ノ',
'(´・ω・`)b',
'（≧▽≦)',
'(*^_^*)',
'(*^^)v',
);

my $mark = $mark[int rand(@mark)];

$mark;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_bbs_body{

my $self = shift;
my $all_of_text = shift || return();
my $event_data = shift || die;
my $event_kind_number = shift;
my(@fixed_text,$print);

$all_of_text =~ s/\r//g;

my @text = split(/[\n]/,$all_of_text);

	foreach my $text (@text){
		chomp $text;
		$text = $self->effect($text,$event_data,$event_kind_number);
			if($text =~ m!^//!){
				next;
			} else {
				push @fixed_text , $text;
			}
	}

$print = join "\n" , @fixed_text ;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub todoufuken_radio_parts{

my $self = shift;
my $selected_id = shift;
my $basic = $self->basic_object();

my $html = new Mebius::HTML;
my($print);

my @todoufuken = $basic->todoufuken();

	foreach my $data (@todoufuken){
		my $checked = 1 if($selected_id && $selected_id eq $data->{'id'});
		$print .= $html->input("radio","location_pref_id",$data->{'id'},{ text => $data->{'title'}  , checked => $checked });
	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_kinds{

my $self = shift;
my(@kind);

push @kind , { name => "" , title => "すべて" };
push @kind , { name => "drink" , title => "飲み会" };
push @kind , { name => "bbq" , title => "BBQ"  };
push @kind , { name => "cafe" , title => "カフェ会"  };

@kind;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_kinds_check_box{

my $self = shift;
my $input_name = shift || die;
my $present_event_kinds = shift;
my $form = new Mebius::Form;

my @kinds = $self->event_kinds();
my $print = $form->checkbox_parts(\@kinds,$input_name,$present_event_kinds);

$print;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sex_target{

my $self = shift;
my(@kind);

push @kind , { name => "" , title => "男女両方"  };
push @kind , { name => "female" , title => "女性のみ"  };
push @kind , { name => "male" , title => "男性のみ"  };

@kind;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_kind_numbers{

my $self = shift;
my $event_data = shift || die "Please relay event_data on hash.";
my(@num);

	for my $num (1..$self->max_event_kind()){

			if(!$event_data->{"bbs_body$num"}){
				next;
			}

			if(!$event_data->{"title$num"}){
				next;
			}

		push @num , $num;
	}

	if(@num <= 0){
		die "Can not decide event kind number by random.";
	}

#my $event_kind_num = $num[int rand(@num)];
#console "Event kind num is $event_kind_num.";
console "Found event kind numbers is ... @num";

@num;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub max_event_kind{
1;
}


1;
