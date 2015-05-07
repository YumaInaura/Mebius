
package Mebius::Mixi::Ivent;

use strict;

use Mebius::Mixi::Basic;
use Mebius::Mixi::Community;
use Mebius::Mixi::Account;
use Mebius::Mixi::Navitomo;
use Mebius::Mixi::SubmitIvent;
use Mebius::View;
use Mebius::Form;

use Mebius::Query;
use Mebius::Move;
use Mebius::Time;

use Mebius::Export;
use base qw(Mebius::Base::DBI Mebius::Base::Data);

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
"ivent";

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
"mixi_ivent";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();

	if($param->{'mode'} eq "submit_ivent"){
		$self->self_view();
		1;
	} elsif($param->{'mode'} eq "submit_ivent_do"){
		$self->submit_ivent();
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
navitomo_ivent_id1 => { } , 
navitomo_ivent_id2 => { } , 
navitomo_ivent_id3 => { } , 
title => { text => 1 } , 
start_year => { int => 1 },
start_month => { int => 1 },
start_day => { int => 1 },
start_hour => { int => 1 },
start_minute => { int => 1 },
start_time => { INDEX => 1 , int => 1 } , 
end_hour => { int => 1 } ,
end_minute => { int => 1 } ,
end_time => { int => 1 } , 
weekday => { } , 
deadline_year => { int => 1 },
deadline_month => { int => 1 },
deadline_day => { int => 1 },
deadline_time => { int => 1 } ,
bbs_body => { text => 1 } , 
location_pref_id => { int => 1 } , 
location_note => { } , 
create_time => { int => 1 } ,
last_modified => { int => 1 } ,
high_age => { int => 1 } ,
low_age => { int => 1 } , 
man_charge => { int => 1 } ,
lady_charge => { int => 1 } ,
deleted_flag => { int => 1 } ,
ivent_auto_submit_flag => { int => 1 } ,
topic_auto_submit_flag => { int => 1 } ,

sex_target => { } , 
ivent_kind => { } , 

ivent_kinds => { } , 

edit_decide_time => { int => 1 } , 

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
my $submit_ivent = new Mebius::Mixi::SubmitIvent;
my $query = new Mebius::Query;
my $param  = $query->param();
my $view = new Mebius::View;
my($print,$data,$target,$data_group);

my $site_url = $basic->site_url();

my @links = (
{ url => "${site_url}?mode=submit_ivent" , title => "今後のイベント" } , 
{ url => "${site_url}?mode=submit_ivent&view=old" , title => "古いイベント" } , 
);

$print .= $view->on_off_links(\@links);


	if( $target = $param->{'target'} ){
		$data = $self->fetchrow_main_table({ target => $target })->[0];
	}

	if($param->{'view'} eq "old"){
		$data_group = $self->fetchrow_main_table({ start_time => ["<",time] });
	} else {
		$data_group = $self->fetchrow_main_table({ start_time => [">",time] });
	}

my @sorted_data_group = sort { $b->{'start_time'} <=> $a->{'start_time'} } @{$data_group};

$print .= $html->tag("h2","一覧");
my $list = $self->data_group_to_list(\@sorted_data_group);
$print .= $self->around_control_form($list);

my $page_title = "イベントの管理";
my $title = $self->effect_title($data->{'title'},$data);

$print .= $basic->error_to_message($error);

	if($param->{'target'}){
		$print .= $html->tag("h2","$title - の編集",{ style => "color:green;" , id => "EDIT_FORM" });
	} else {
		$print .= $html->tag("h2","新規登録");
	}

$print .= $self->submit_ivent_form($data);

	if($data && (my $data_group = $submit_ivent->fetchrow_main_table({ ivent_target => $target , submit_type => "post" }))){
		$print .= $html->tag("h2","登録履歴");
		$print .= $submit_ivent->data_group_to_list($data_group);
	}


#).e($mixi_url).q(add_event.pl

$basic->print_html($print,{ title => $page_title , h1 => $page_title , change_encode => "euc-jp" });

exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_ivent_form{

my $self = shift;
my $data = shift;
my $query = new Mebius::Query;
my $community = new Mebius::Mixi::Community;
my $navitomo = new Mebius::Mixi::Navitomo;
my $submit_ivent = new Mebius::Mixi::SubmitIvent;
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my $form = new Mebius::Form;
my $param  = $query->param();

my($print);

my $submit_button = qq(<div style="margin:1em 0em;">);

$submit_button .= qq(<input type="submit" style="font-size:100%;" value="イベントを記録する">\n);

	if($data && $submit_ivent->fetchrow_main_table({ ivent_target => $data->{'target'} })->[0]){
		$submit_button .= $html->input("submit","out_sites_edit","イベントを記録してmixiも更新する",{ style => "font-size:100%;	" });
	}

	if($data){
		$submit_button .= qq(<input type="submit" name="new_ivent" style="font-size:100%;" value="新しいイベントとして記録する">\n);
	}

$submit_button .= qq(</div>);

$print .= q(<form name="bbs_form" action="#EDIT_FORM" method="post" enctype="multipart/form-data">);

$print .= $submit_button;


$print .= q(<input type="hidden" name="mode" value="submit_ivent_do">);

$print .= qq(<div>);
$print .= $html->input("checkbox","ivent_auto_submit_flag",1,{ checked => $data->{'ivent_auto_submit_flag'} , text => "イベントの登録対象にする" });
$print .= $html->input("checkbox","topic_auto_submit_flag",1,{ checked => $data->{'topic_auto_submit_flag'} , text => "トピックの登録対象にする" });

$print .= qq(</div>);

$print .= qq(<div>);
$print .= $html->input("checkbox","edit_decide_time",1,{ checked => $data->{'edit_decide_time'} , text => "編集対象にする" });
$print .= qq(</div>);

$print .= $html->input("hidden","target",$data->{'target'},{ style => "width:5em;" });

	if($data->{'navitomo_ivent_id'}){
		#$data = $navitomo->id_to_get_html_ivent_data($data->{'navitomo_ivent_id'});
	}


$print .= qq(<div>);

	for(1..3){

		$print .= qq(なびともID$_ );
		$print .= $html->input("number","navitomo_ivent_id$_",$data->{"navitomo_ivent_id$_"},{ style => "width:4em;" });

		if( my $id = $data->{"navitomo_ivent_id$_"}){
			my $url = $navitomo->saint_ivent_url($id);
			$print .= "　[" . $html->href($url,"SAINTで見る",{ target => "_blank" }) . "]\n";
			my $url = $navitomo->navitomo_ivent_url($id);
			$print .= "　[" . $html->href($url,"なびともで見る",{ target => "_blank" }) . "]\n";

		}

		$print .= qq(<br>);

	}


$print .= qq(</div>);

$print .= qq(<div>);
$print .= qq(タイトル );
$print .= $html->input("text","title",$data->{'title'},{ style => "width:90em;" });
$print .= qq(</div>);


$print .= qq(<div>);
$print .= qq(●開催日時);
$print .= $html->input("number","start_year",$data->{'start_year'} || $times->this_year() ,{ style => "width:5em;" })."年";
$print .= $html->input("number","start_month",$data->{'start_month'},{ style => "width:3em;" })."月";
$print .= $html->input("number","start_day",$data->{'start_day'},{ style => "width:3em;" })."日";

	if($data->{'start_time'}){
		$print .= " (" . $times->weekday_japanese($data->{'start_time'}) . ") ";
	}

$print .= $html->input("time","start_hour_and_minute",sprintf("%02d",$data->{'start_hour'}).":".sprintf("%02d",$data->{'start_minute'}),{  });
$print .= "～";
$print .= $html->input("time","end_hour_and_minute",sprintf("%02d",$data->{'end_hour'}).":".sprintf("%02d",$data->{'end_minute'}),{  });
$print .= qq(</div>);


	if($data->{'start_time'}){
		$print .= qq(<div>);
		$print .= "●募集期限";
		$print .= $html->input("number","deadline_year",$data->{'deadline_year'},{ style => "width:5em;" })."年";
		$print .= $html->input("number","deadline_month",$data->{'deadline_month'},{ style => "width:3em;" })."月";
		$print .= $html->input("number","deadline_day",$data->{'deadline_day'},{ style => "width:3em;" })."日";
		$print .= qq(</div>);
	}


$print .= qq(<div>);
$print .= qq(<span style="color:blue;">男性</span> );
$print .= $html->input("number","man_charge",$data->{'man_charge'},{ style => "width:4em;" }) . "円 ";

$print .= qq(<span style="color:red;">女性</span> );
$print .= $html->input("number","lady_charge",$data->{'lady_charge'},{ style => "width:4em;" }) . "円";
$print .= qq(</div>);

$print .= qq(<div>);
$print .= qq(●イベントの種類 );
$print .= $self->ivent_kinds_check_box("ivent_kinds",$data->{'ivent_kinds'});
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


$print .= qq(<textarea cols="75" rows="15" name="bbs_body" style="width:80%;height:30em;">).e($data->{'bbs_body'}).qq(</textarea>);

$print .= $submit_button;

$print .= qq(</div></form>);

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
			if($key =~ /^mixi_community_ivent_control_([0-9a-zA-Z]+)$/){
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
sub submit_ivent{

my $self = shift;
my $query = new Mebius::Query;
my $community = new Mebius::Mixi::Community;
my $submit_ivent = new Mebius::Mixi::SubmitIvent;
my $move = new Mebius::Move;
my $times = new Mebius::Time;
my $basic = $self->basic_object();
my $param  = $query->param();
my(%insert,$data,$target);


	if( $target = $param->{'target'} ){
		$data = $self->fetchrow_main_table({ target => $target })->[0];
	}


$insert{'title'} = $param->{'title'} || $self->self_view("タイトルを入力してください。");
$insert{'bbs_body'} = $param->{'bbs_body'};

$insert{'ivent_auto_submit_flag'} = $param->{'ivent_auto_submit_flag'};
$insert{'topic_auto_submit_flag'} = $param->{'topic_auto_submit_flag'};

$insert{'location_pref_id'} = $param->{'location_pref_id'};
$insert{'location_note'} = $param->{'location_note'};

	for(1..3){
		if($param->{"navitomo_ivent_id$_"} =~ /^([0-9a-zA-Z]+)$|^$/){
			$insert{"navitomo_ivent_id$_"} = $param->{"navitomo_ivent_id$_"};
		}
	}

	$insert{'location_note'} = $param->{'location_note'};

$insert{'man_charge'} = $param->{'man_charge'};
$insert{'lady_charge'} = $param->{'lady_charge'};

$insert{'ivent_kinds'} = $param->{'ivent_kinds'};
$insert{'sex_target'} = $param->{'sex_target'};

$insert{'start_year'} = $param->{'start_year'};
$insert{'start_month'} = $param->{'start_month'};
$insert{'start_day'} = $param->{'start_day'};

	if($param->{'edit_decide_time'}){
		$insert{'edit_decide_time'} = time;
	}elsif($param->{'edit_decide_time'} eq ""){
		$insert{'edit_decide_time'} = "";
	}

$insert{'start_hour'} = $times->time_value_to_hour($param->{'start_hour_and_minute'});
$insert{'start_minute'} = $times->time_value_to_minute($param->{'start_hour_and_minute'});

$insert{'end_hour'} = $times->time_value_to_hour($param->{'end_hour_and_minute'});
$insert{'end_minute'} = $times->time_value_to_minute($param->{'end_hour_and_minute'});

$insert{'start_time'} = $times->date_to_localtime($param->{'start_year'},$param->{'start_month'},$param->{'start_day'},$insert{'start_hour'},$insert{'start_minute'});
$insert{'end_time'} = $times->date_to_localtime($param->{'start_year'},$param->{'start_month'},$param->{'start_day'},$insert{'end_hour'},$insert{'end_minute'});

$insert{'weekday'} = $times->weekday_or_holiday($insert{'start_time'});

$insert{'deadline_year'} = $param->{'deadline_year'} || $param->{'start_year'};
$insert{'deadline_month'} = $param->{'deadline_month'} || $param->{'start_month'};
$insert{'deadline_day'} = $param->{'deadline_day'} || $param->{'start_day'};

$insert{'high_age'} = $community->param_value_to_high_age($param->{'target_old'});
$insert{'low_age'} = $community->param_value_to_low_age($param->{'target_old'});

$insert{'last_modified'} = time;


	if($data && !$param->{'new_ivent'}){
		$insert{'target'} = $target;
		$self->update_main_table(\%insert);
	} else {
		$insert{'target'} = $self->new_target();
		$self->insert_main_table(\%insert);
	}

	if($data && $param->{'out_sites_edit'}){
		$submit_ivent->ivent_data_to_edit_out_sites(\%insert);
	}

my $ivent_url = $self->data_to_url(\%insert);
$move->redirect($ivent_url);

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
my($print);


$print .= qq(<li>);
$print .= $self->data_to_link($data);
$print .= $self->data_to_control_parts($data,{ Simple => 1 } );

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
my $url = "${site_url}?mode=submit_ivent&target=$data->{'target'}";

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub effect_title{

my $self = shift;
my $title = shift;
my $ivent_data = shift || die;
my $time = new Mebius::Time;

my $weekday = $time->weekday_japanese($ivent_data->{'start_time'});

my $date = e($ivent_data->{'start_month'}) . "/" . e($ivent_data->{'start_day'}) . "(" . e($weekday) . ")";
#my $age = 1;

$title =~ s!\[date\]!$date!gi;
#$title =~ s!\[age\]!$age!gi;
$title =~ s!\[mark\]!$self->random_mark()!gie;
$title =~ s!\[face\]!$self->random_face_mark()!gie;

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
my $ivent_data = shift || die;
my(@fixed_text,$print);

$all_of_text =~ s/\r//g;

my @text = split(/[\n]/,$all_of_text);

	foreach my $text (@text){
		chomp $text;
		$text = $self->effect_title($text,$ivent_data);
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
sub ivent_kinds{

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
sub ivent_kinds_check_box{

my $self = shift;
my $input_name = shift || die;
my $present_ivent_kinds = shift;
my $form = new Mebius::Form;

my @kinds = $self->ivent_kinds();
my $print = $form->checkbox_parts(\@kinds,$input_name,$present_ivent_kinds);

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


1;
