
package Mebius::Mixi::Community;

use strict;

use Mebius::Mixi::Basic;
use Mebius::Mixi::Account;
use Mebius::Mixi::Event;
use Mebius::Mixi::Submit;

use Mebius::Encoding;
use Mebius::Query;
use Mebius::Move;
use Mebius::Export;
use Mebius::Operate;
use Mebius::Form;

use LWP::Simple qw();

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
sub main_table_name{
"mixi_community";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $column = {
target => { PRIMARY => 1 } , 
create_time => { int => 1 } ,
id => { INDEX => 1 , int => 1 } , 
deleted_flag => { INDEX => 1 , int => 1 } ,
block_flag => { INDEX => 1 , int => 1 } ,
use_flag => { INDEX => 1 , int => 1 } , 
title => { INDEX => 1 } ,
place => {} ,
location_pref_id => { int => 1 } , 
high_age => { int => 1 } ,
low_age => { int => 1 } ,
sex => { } , 
weekday => {} ,
memo => { text => 1 } ,
total_member_num => { INDEX => 1 , int => 1 } , 
deny_create_topic_flag => { int => 1 } , 
last_modified => { int => 1 } ,
category_id => { int => 1 } ,
comment_topic_event_id => {  } ,
event_kinds => { } , 
sex_target => { } , 
allow_submit_topic_flag => { int => 1 } , 

};

$column;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my $query = new Mebius::Query;
my $param = $query->param();


	if($param->{'type'} eq "search"){
		$self->self_view();
	} elsif($param->{'type'} eq "edit"){
		$self->edit();
	} elsif($param->{'mode'} eq "refresh_all_used_community_data"){
		$self->refresh_all_used_community_data();
	} elsif($param->{'mode'} eq "submit_community"){
		$self->self_view();
	}

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic_object{
my $object = new Mebius::Mixi;
}



#-----------------------------------------------------------
# イベント一覧の HTML を取得して、イベントIDを配列として返す
#-----------------------------------------------------------
sub event_topic_list_ids{

my $self = shift;
my $community_id = shift || die;
my $email = shift || die;
my $type = shift || die;
my $basic = $self->basic_object();
my(@event_id,$list_url);

	if($type eq "event"){
		$list_url = $self->event_list_url($community_id);
	} elsif($type eq "topic"){
		$list_url = $self->topic_list_url($community_id);
	} else {
		die;
	}

my $list_html = $basic->get($list_url,$email);

	if($list_html){
		$basic->succeed_log($email,"Get $type list.",$list_html);
	} else {
		$basic->failed_log($email,"Can not get $type list.",$list_html);
		return();
	}

	if($type eq "event"){

			while($list_html =~ s!<a href="http://mixi\.jp/view_event\.pl\?comm_id=(?:[0-9]+)&id=([0-9]+)">[0-9]+</a>!!){
				push @event_id , $1;
			}
	} elsif($type eq "topic"){
			while($list_html =~ s!<a href="http://mixi\.jp/view_bbs.pl\?comm_id=(?:[0-9]+)&id=([0-9]+)">[0-9]+</a>!!){
				push @event_id , $1;
			}

	}
	
console "This event ids are ...";
console "@event_id";

@event_id;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_order_at_list{

my $self = shift;
my $community_id = shift;
my $event_id = shift;
my $email = shift;
my $type = shift || die;
my($count,$order);

my @event_topic_list = $self->event_topic_list_ids($community_id,$email,$type);

	foreach my $event_id_per (@event_topic_list){
		$count++;
			if($event_id eq $event_id_per && $event_id_per){
				$order = $count;
			}
	}

$order ||= 0;

console "Event order is $order";
$order;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_list_url{

my $self = shift;
my $community_id = shift || (warn && return());

my $url = "http://mixi.jp/list_bbs.pl?type=event&id=$community_id";

$url;


}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topic_list_url{

my $self = shift;
my $community_id = shift || (warn && return());

my $url = "http://mixi.jp/list_bbs.pl?type=bbs&id=$community_id";

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_event_or_topic{

my $self = shift;
my $email = shift || (warn && return());
my $community_id = shift || (warn && return());
my $event_id = shift || (warn && return());
my $topic_type = shift || (warn && return());
my $basic = $self->basic_object();
my(%input_for_preview,$succeed_flag);

$input_for_preview{'comm_id'} = $community_id;
$input_for_preview{'id'} = $event_id;

my $event_topic_url = $self->event_url($community_id,$event_id);
my $event_topic_html = $basic->get($event_topic_url,$email);

	if($event_topic_html =~ m!<p class="messageAlert">データがありません!){
		$basic->failed_log($email,"This event topic is still deleted . $event_topic_url ",$event_topic_html);
		return 1;
	} elsif($event_topic_html){
		$basic->succeed_log($email,"View event topic. $event_topic_url ",$event_topic_html);
	} else {
		$basic->failed_log($email,"Can not view event topic. $event_topic_url ",$event_topic_html);
		return();
	}

$basic->rest_sleep();

my $preview_url = "http://mixi.jp/delete_event.pl?id=$event_id&comm_id=$community_id";
my $preview_html = $basic->post($preview_url,$email,\%input_for_preview,{ referer => $event_topic_url });

my $post_key = $basic->html_to_post_key($preview_html,$email);

	if($post_key){
		$basic->succeed_log($email,"Preview for delete event topic. $event_topic_url ",$preview_html);
	} else {
		$basic->failed_log($email,"Can not preview for delete event topic. $event_topic_url",$preview_html);
		return();
	}

$basic->preview_sleep();

my %input_for_submit = %input_for_preview;
$input_for_submit{'submit'} = "confirm";
$input_for_submit{'post_key'} = $post_key || die;

my $submit_url = $preview_url;
my $submited_html = $basic->post($submit_url,$email,\%input_for_submit,{ referer => $preview_url });

	if($submited_html =~ m!<title>302 Moved</title>!){
		$basic->finished_log($email,"Delete event topic $event_topic_url .",$submited_html);
		$succeed_flag = 1;
	} else {
		$basic->failed_log($email,"Can not delete event topic $event_topic_url .",$submited_html);
		$succeed_flag = 0;
	}

$basic->rest_sleep();

$succeed_flag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_all_comments_on_event_or_topic{

my $submit_event = new Mebius::Mixi::Submit;

my $self = shift;
my $email = shift || return();
my $community_id = shift || return();
my $event_id = shift || return();
my $topic_type = shift || die;
my $submit_data = shift;
my $basic = $self->basic_object();
my($event_url);

my $topic_type_big = uc $topic_type;

	if($topic_type eq "event"){
		$event_url = $self->event_url($community_id,$event_id);
	} elsif($topic_type eq "topic"){
		$event_url = $self->topic_url($community_id,$event_id);
	} else {
		die;
	}

$basic->try_log($email,"DELETE ALL COMMENTS ON $topic_type_big $event_url");

my $event_topic_html = $basic->get($event_url,$email,{ referer => $event_url });
my @data_group_for_delete = $self->html_to_delete_mode_data_group($event_topic_html,$topic_type);
my $delete_try_num = @data_group_for_delete;

	if(!$delete_try_num && $submit_data){
		$submit_event->update_main_table_where({ comment_deleted_flag => 1 },{ target => $submit_data->{'target'} });
	}

$basic->try_log($email,"Try to $delete_try_num comments delete.");

	foreach my $hash (@data_group_for_delete){
		my $succeed_flag = $self->delete_comment_on_event_or_topic($email,$hash->{'community_id'},$hash->{'event_id'},$hash->{'comment_id'},$topic_type);
	}

$basic->logout($email);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub html_to_delete_mode_data_group{

my $self = shift;
my $html = shift || return();
my $topic_type = shift || die;
my(@url,@array);

	while($html =~ s!href="(delete_bbs_comment\.pl\?comment_id=([0-9]+)&comm_id=([0-9]+)&id=([0-9]+))"!!){
		push @url , "http://mixi.jp/$1";
		push @array , { comment_id => $2 , community_id => $3 , event_id => $4 };
	}


@array;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_comment_on_event_or_topic{


my $self = shift;
my $email = shift || return();
my $community_id = shift || return();
my $event_id = shift || return();
my $comment_id = shift || return();
my $topic_type = shift || die;
my $submit_event = new Mebius::Mixi::Submit;
my $basic = $self->basic_object();
my(%input,$flag,$event_url,$preview_url);

	if($topic_type eq "event"){
		$event_url = $self->event_url($community_id,$event_id);
		$preview_url = "http://mixi.jp/delete_bbs_comment.pl?comment_id=$comment_id&comm_id=$community_id&id=$event_id";
	} elsif($topic_type eq "topic"){
		$event_url = $self->topic_url($community_id,$event_id);
		$preview_url = "http://mixi.jp/delete_bbs_comment.pl?comment_id=$comment_id&comm_id=$community_id&id=$event_id";
	} else {
		die;
	}


my $preview_html = $basic->get($preview_url,$email,{ referer => $event_url });

my $post_key = $basic->html_to_post_key($preview_html,$email);

	if($post_key){
		$basic->succeed_log($email,"Get posy key for delete comment.",$preview_html);
	} else {
		$basic->failed_log($email,"Can not get posy key for delete comment..",$preview_html);
		return();
	}

#$input{'post_key'} = $post_key || die;
#$input{'submit'} = "confirm";
#$input{'comment_id'} = $comment_id;
#$input{'submit'} = "confirm";

$input{'post_key'} = $post_key || die;
$input{'comment_id'} = $comment_id;
$input{'mode'} = 'commit';
$input{'comm_id'} = $community_id;
$input{'id'} = $event_id;


$basic->preview_sleep();

#my $url_for_submit = "http://mixi.jp/delete_bbs_comment.pl?comm_id=$community_id&id=$event_id";
my $url_for_submit = "http://mixi.jp/delete_bbs_comment.pl";
my $submited_html = $basic->post($url_for_submit,$email,\%input,{ referer => $preview_url });

	if($submited_html =~ m!<title>302 (Moved|Found)</title>!){
		$flag = 1;
		$basic->finished_log($email,"Deleted comment.",$submited_html);
		$submit_event->update_main_table_where({ comment_deleted_flag => 1 },{ email => $email , submit_type => "comment" , mixi_community_id => $community_id , mixi_event_id => $event_id });
	} else {
		$flag = 0;
		$basic->failed_log($email,"Can not delete comment.",$submited_html);
	}

$basic->rest_sleep();

$flag;

}

#----------------------------------------------------------
# 
#-----------------------------------------------------------
sub search_result_url{


my $self = shift;
my $keyword = shift || return();
my $basic = $self->basic_object();
my $mixi_url = $basic->mixi_url() || die;
my $encoding = new Mebius::Encoding;

my $euc_jp_keyword = $encoding->utf8_to_eucjp($keyword);
my $encoded_keyword = $encoding->encode($keyword);
my $url = "${mixi_url}search_community.pl?keyword=$encoded_keyword";

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub community_url_to_id{

my $self = shift;
my $text = shift;
my($id);

	if($text =~ m!^http://mixi\.jp/view_community\.pl?id=([0-9]+)!){
		$id = $1;
	}

$id;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub search_result_html_to_ids{

my $self = shift;
my(@id);

my @hash_group = $self->search_result_html_to_community_data_group(@_);

	foreach my $data (@hash_group){
		push @id , $data->{'id'} || die;
	}

@id;


}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub search_result_html_to_community_data_group{

my $self = shift;
my $page_body = shift || return();
my(@data);

	while($page_body =~ s!<a href="http://mixi\.jp/view_community\.pl\?id=([0-9]+)(?:&[^<>]+)?">([^<>]+?)</a>!!){

		my $id = $1;
		my $title = $2;

		push @data , { id => $id , title => $title };
	}

@data;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_table_block{

my $self = shift;
my $data_group = shift || return();
my $use = shift || {};
my $html = new Mebius::HTML;
my $event = new Mebius::Mixi::Event;
my $basic = $self->basic_object();
my $form = new Mebius::Form;

my($print,$hit);


	foreach my $data (@{$data_group}){

		my($tr_style);

		my $target = $data->{'target'};
		$hit++;

		if($data->{'block_flag'}){
			$tr_style .= "background:#fcc;"; 
		} elsif($data->{'deleted_flag'}){
			$tr_style .= "background:#ccc;"; 
		} elsif(!$data->{'use_flag'}){
			$tr_style .= "background:#ffb;"; 
		}

		$print .= $html->start_tag("tr",{ style => $tr_style });

		$print .= qq(<td>).e($hit).qq(</td>);
		$print .= qq(<td>).e($data->{'id'}).qq(</td>);


		my $link = $self->community_data_to_link($data);
		$print .= qq(<td>) . $link . qq(</td>);


		$print .= qq(<td>);

		my $input_name = "mixi_community_control_$target";
		$print .= $html->input("radio",$input_name,"none",{ text => "未選択" });
		$print .= $html->input("radio",$input_name,"use",{ checked => $data->{'use_flag'} , text => "使用" });
		$print .= $html->input("radio",$input_name,"delete",{ checked => $data->{'deleted_flag'} , text => "削除" });
		$print .= $html->input("radio",$input_name,"block",{ checked => $data->{'block_flag'} , text => "ブロック" });

		$print .= qq(</td>);

		$print .= qq(<td>);
		my $name = "mixi_community_allow_submit_topic_flag_$data->{'target'}";
		my @select = ({ title => "未選択" , name => 0  },{ title =>"トピック許可" , name => 1 },{ title =>"トピック不許可" , name => 2 });
		$print .= $form->select_parts(\@select,$name,$data->{'allow_submit_topic_flag'});

		#$print .= $html->input("checkbox","",1,{ checked => $data->{'allow_submit_topic_flag'} , text => "トピック" });
		$print .= qq(</td>);

		$print .= qq(<td>);
		$print .= $html->input("text","mixi_community_control_comment_topic_event_id_$target",$data->{'comment_topic_event_id'},{ placeholder => "例)232" , style => "width:3em;" , min => "0" });
		$print .= qq(</td>);

		$print .= qq(<td>);

			if($data->{'use_flag'}){
				$print .= $self->target_old_select_parts($data);
			} else {
				$print .= $self->target_old_select_parts_automatic($data);
			}

			if($data->{'use_flag'}){
				$print .= $self->weekday_select_parts($data);
			} else {
				$print .= $self->weekday_select_parts_automatic($data);
			}

			if($data->{'use_flag'}){
					$print .= $basic->data_to_todoufuken_select_parts($data);
			} else {
				$print .= $basic->data_to_todoufuken_select_parts_automatic($data);
			}

			my @event_kinds = $event->event_kinds();
			$print .= $form->select_parts(\@event_kinds,"mixi_community_event_kinds_$data->{'target'}",$data->{'event_kinds'});

			my @sex_target = $event->sex_target();
			$print .= $form->select_parts(\@sex_target,"mixi_community_sex_target_$data->{'target'}",$data->{'sex_target'});

		$print .= qq(</td>);

		$print .= qq(<td> );

			if( exists $use->{'inputed_title'}->{$data->{'title'}}){
				$print .= $html->tag("strong"," [HIT]",{ style => "color:red;" });
			}

			if($data->{'block_flag'}){
				$print .= $html->tag("strong"," [ブロック中]",{ style => "color:red;" });
			} elsif($data->{'deleted_flag'}){
				$print .= $html->tag("strong"," [削除済み]",{ style => "color:red;" });
			}

			if($data->{'deny_create_topic_flag'}){
				$print .= $html->tag("span"," [管理人のみ作成できる]",{ style => "color:red;" });
			}

		$print .= qq(</td>);

		$print .= qq(<td>);
		$print .= $html->input("text","mixi_community_total_member_num_$data->{'target'}",$data->{'total_member_num'},{ style => "width:4em;text-align:right;" }) . "人";
		$print .= qq(</td>);

		$print .= qq(</tr>);
	}



$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub weekday_select_parts_automatic{

my $self = shift;
my $data = shift || return();
my %new_data = %{$data};

	if($new_data{'title'} =~ /平日/){
		$new_data{'weekday'} = "weekday";
	}

$self->weekday_parts_core("select",\%new_data,@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub weekday_select_parts{

my $self = shift;
$self->weekday_parts_core("select",@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub weekday_parts_core{

my $self = shift;
my $type = shift || die;
my $data = shift || return();
my $input_name = shift;
my($print);
my $html = new Mebius::HTML;
my($detault_checked,$target);

$target = $data->{'target'};

my @target_old = $self->weekday_kinds();

	if(!$data->{'weekday'}){
		$detault_checked = 1;
	}

	if(!$input_name && $target){
		$input_name = "mixi_community_target_weekday_$target";
	}

$print .= $html->start_tag("select",{ name => $input_name });
$print .= $html->tag("option","全ての日", { value => "all" , selected => $detault_checked });

	foreach my $hash (@target_old){

		my($checked);

			if($data->{'weekday'} eq $hash->{'weekday'}){
				$checked = 1;
			}

			if($type eq "radio"){
				$print .= $html->input("radio",$input_name,$hash->{'weekday'},{ checked => $checked , text => $hash->{'title'} });
			} elsif($type eq "select"){
				$print .= $html->tag("option",$hash->{'title'},{ name => $input_name , value => $hash->{'weekday'} , selected => $checked });
			}

	}

if($type eq "select"){
		$print .= $html->close_tag("select");
	}

$print;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub weekday_kinds{

my $self = shift;
my(@array);


push @array , { weekday => "holiday" , title => "休日のみ" };
push @array , { weekday => "weekday" , title => "平日のみ" };
#push @array , { weekday => "monday" , title => "月曜" };
#push @array , { weekday => "tuesday" , title => "火曜" };
#push @array , { weekday => "wednesday" , title => "水曜" };
#push @array , { weekday => "thursday" , title => "木曜" };
#push @array , { weekday => "friday" , title => "金曜" };
#push @array , { weekday => "saturday" , title => "土曜" };
#push @array , { weekday => "sunday" , title => "日曜" };


@array;

}


#-----------------------------------------------------------
# Writing order is important
#-----------------------------------------------------------
sub title_to_low_and_high_age{

my $self = shift;
my $title = shift;
my($low_age,$high_age);

	if($title !~ /才|歳|代/){
		return();
	}

	#if($title =~ /(([23456]|２|３|４|５|６)[0|０])(才|歳|代)?(?:(、|～))([23456][0|０])(才|歳|代)/){

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($title)); }

	#}


	if($title =~ /(2[0-5]|２(０|１|２|３|４|５))(才|歳|代)/){
		$low_age = 20;
		$high_age = 29;
	}

	if($title =~ /(3[0-5]|３(０|１|２|３|４|５))(才|歳|代)/){
		$low_age ||= 30;
		$high_age = 39;
	}

	if($title =~ /(4[0-5]|４(０|１|２|３|４|５))(才|歳|代)/){
		$low_age ||= 40;
		$high_age = 49;
	}

	if($title =~ /(5[0-5]|５(０|１|２|３|４|５))(才|歳|代)/){
		$low_age ||= 50;
		$high_age = 59;
	}

	if($title =~ /(6[0-5]|６(０|１|２|３|４|５))(才|歳|代)/){
		$low_age ||= 60;
		$high_age = 69;
	}

	if(!wantarray){
		die("Wantarray.");
	}

$low_age,$high_age;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub target_old_kinds{

my $self = shift;
my(@array);


push @array , { low_age => 20 , high_age => 29 , title => "20代" };
push @array , { low_age => 20 , high_age => 39 , title => "20代&30代" };
push @array , { low_age => 30 , high_age => 39 , title => "30代" };
push @array , { low_age => 30 , high_age => 49 , title => "30代&40代" };
push @array , { low_age => 40 , high_age => 49 , title => "40代" };
push @array , { low_age => 40 , high_age => 59 , title => "40代&50代" };
push @array , { low_age => 50 , high_age => 59 , title => "50代" };
push @array , { low_age => 20 , high_age => 49 , title => "20代&30代&40代" };
push @array , { low_age => 30 , high_age => 59 , title => "30代&40代&50代" };

#push @array , { low_age => 25 , high_age => 35 , title => "アラサー" };
#push @array , { low_age => 35 , high_age => 45 , title => "アラフォー" };
#push @array , { low_age => 45 , high_age => 55 , title => "アラフィフ" };

@array;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub target_old_select_parts{

my $self = shift;
$self->target_old_parts_core("select",@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub target_old_select_parts_automatic{

my $self = shift;
my $data = shift || return();

my($low_age,$high_age) = $self->title_to_low_and_high_age($data->{'title'});

$self->target_old_parts_core("select",{ low_age => $low_age , high_age => $high_age },$data);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub target_old_radio_parts{

my $self = shift;
$self->target_old_parts_core("radio",@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub target_old_parts_core{

my $self = shift;
my $type = shift || die;
my $data = shift || return();
my $input_name = shift;
my($print);
my $html = new Mebius::HTML;
my($detault_checked,$target);

$target = $data->{'target'};

my @target_old = $self->target_old_kinds();

	if(!$data->{'low_age'} && !$data->{'high_age'}){
		$detault_checked = 1;
	}

	if(!$input_name && $target){
		$input_name = "mixi_community_target_old_$target";
	}

	if($type eq "radio"){
		$print .= $html->input("radio",$input_name,"all",{ checked => $detault_checked , text => "全年代" });
	} elsif($type eq "select"){
		$print .= $html->start_tag("select",{ name => $input_name });
		$print .= $html->tag("option","全年代", { value => "all" , selected => $detault_checked });
	}

	foreach my $hash (@target_old){

		my($checked);
		my $low_to_high_age = "$hash->{'low_age'}-$hash->{'high_age'}";
			if($data->{'low_age'} eq $hash->{'low_age'} && $data->{'high_age'} eq $hash->{'high_age'}){
				$checked = 1;
			}
			if($type eq "radio"){
				$print .= $html->input("radio",$input_name,$low_to_high_age,{ checked => $checked , text => $hash->{'title'} });
			} elsif($type eq "select"){
				$print .= $html->tag("option",$hash->{'title'},{ name => $input_name , value => $low_to_high_age , selected => $checked });
			}

	}

if($type eq "select"){
		$print .= $html->close_tag("select");
	}

$print;


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub community_data_to_link{

my $self = shift;
my $data = shift || return();
my $html = new Mebius::HTML;

my $url = $self->community_data_to_url($data);
my $link = $html->href($url,$data->{'title'});

$link;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_community_html_data{

my $self = shift;
my $id = shift || return();
my $basic = $self->basic_object();

my $url = $self->id_to_community_url($id);
my $html = $basic->random_account_get($url);

$self->community_html_to_data($html);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub community_html_to_data{

my $self = shift;
my $html = shift || return();
my(%hash);

#<dl class="communityInfolistMiddle clearfix categoryName">
#<dt>カテゴリ</dt>
#<dd><a href="search_community.pl?category_id=19&from=info_cat&mode=main">その他</a></dd>

	if($html =~ m!<title>\[mixi\] (.+?)</title>!){
		$hash{'title'} = $1;
	} elsif($html =~ m!<title>(.+?)\| mixiコミュニティ</title>!){
		$hash{'title'} = $1;
	}

$hash{'title'} = $self->delete_spece_from_community_title($hash{'title'});


#管理人の承認が必要(公開)

	if($html =~ m!<dl(?:[^<>]+?)>(.+?)(管理人のみ作成できる)(.+?)</dl>!s){ 
		$hash{'deny_create_topic_flag'} = 1;
	}

	if($html =~ m!<dl(?:[^<>]+?)>(?:.+?)([0-9]+)人(?:.+?)</dl>!s){
		$hash{'total_member_num'} = $1;
	}

$hash{'html'} = $html;

\%hash;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_spece_from_community_title{


my $self = shift;
my $title = shift || return();

	while($title =~ s/(^[\s\t]+)|([\s\t]+$)|(^(　)+)|((　)+$)//g){
		1;
	}

$title;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub community_data_to_url{

my $self = shift;
my $data = shift || return();

my $url = $self->id_to_community_url($data->{'id'});
$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_url{

my $self = shift;
my $community_id = shift || return();
my $event_id = shift || return();

my $url = "http://mixi.jp/view_event.pl?id=$event_id&comm_id=$community_id";

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topic_url{

my $self = shift;
my $community_id = shift || return();
my $event_id = shift || return();

my $url = "http://mixi.jp/view_bbs.pl?id=$event_id&comm_id=$community_id";

$url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub event_topic_link{

my $self = shift;
my $community_id = shift || (warn && return());
my $event_id = shift || (warn && return());
my $title = shift || (warn && return());
my $html = new Mebius::HTML;

my $url = $self->event_url($community_id,$event_id);
my $link = $html->href($url,$title);

$link;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub id_to_community_url{

my $self = shift;
my $id = shift || return();
my $basic = $self->basic_object();

my $mixi_url = $basic->mixi_url();
my $url = "${mixi_url}view_community.pl?id=$id";

$url;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub search_result_link{

my $self = shift;
my $text = shift || return();
my $html = new Mebius::HTML;
my($link);

my $url = $self->search_result_url($text);
my $link = $html->href($url,$text);

$link;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub self_view{

my $self = shift;
my $query = new Mebius::Query;
my $html = new Mebius::HTML;
my $basic = $self->basic_object();	
my($param) = $query->param();
my($print);

my $page_title = "コミュニティの管理";

my $search_result_line = $self->text_to_submit_community($param->{'text'},{ get_data => $param->{'get_data'} } );

	if($ENV{'REQUEST_METHOD'} eq "POST"){
		$self->edit();
	}

$print .= $self->refresh_all_used_community_data_form();

$print .= $html->tag("h2","管理");
$print .= $self->edit_form();

$print .= $html->tag("h2","検索",{ id => "search" });
$print .= $self->search_form();

	if( $search_result_line ){
		$print .= $search_result_line;
		$print .= $html->tag("h2","結果");
	}

$basic->print_html($print,{ Title => $page_title , h1 => $page_title });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub refresh_all_used_community_data_form{

my $self = shift;
my $html = new Mebius::HTML;
my($print);

$print .= $html->start_tag("form",{ method => "post" });
$print .= $html->input("hidden","mode","refresh_all_used_community_data");
$print .= $html->input("submit","","使用中のコミュニティデータを更新する");
$print .= $html->close_tag("form");

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub search_form{

my $self = shift;
my $html = new Mebius::HTML;
my($print);

my $this_mode_key = $self->community_mode_param_key();

$print .= qq(<form action="#search" method="POST">);
$print .= $html->input("hidden","mode",$this_mode_key);
$print .= qq(コミュニティデータを取得する(mixiの制限回避のため、1キーワードあたり1秒かかります)： );
#$print .= $html->input("radio","get_data",0,{ text => "なし" });
$print .= $html->input("radio","get_data","all",{ text => "すべての結果"});
$print .= $html->input("radio","get_data","limited",{ text => "1位の結果のみ" , checked => 1});
$print .= $html->textarea("text","",{ style => "display:block;max-width:60em;width:100%;height:20em;" });
$print .= $html->input("submit","","この内容で検索する");
$print .= qq(</form>);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_form{

my $self = shift;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $param = $query->param();
my($print);

my $use_data_group = $self->fetchrow_main_table_desc({ use_flag => 1 , deleted_flag => 0 , block_flag => 0 },"total_member_num");
my $pre_data_group = $self->fetchrow_main_table_desc({ use_flag => 0 , deleted_flag => 0 , block_flag => 0 , deny_create_topic_flag => 0 },"total_member_num");
my $deleted_data_group = $self->fetchrow_main_table_desc({ block_flag => 0 , deleted_flag => 1 },"total_member_num");
my $blocked_data_group = $self->fetchrow_main_table_desc({ block_flag => 1 },"total_member_num");

$print .= $html->tag("h3","使用中");
$print .= qq(<table>);
$print .= $self->data_group_to_table_block($use_data_group);
$print .= qq(</table>);

$print .= $html->tag("h3","未登録");
$print .= qq(<table>);
$print .= $self->data_group_to_table_block($pre_data_group);
$print .= qq(</table>);

	if($param->{'view_all'}){
		$print .= $html->tag("h3","削除済み");
		$print .= qq(<table>);
		$print .= $self->data_group_to_table_block($deleted_data_group);
		$print .= qq(</table>);
	}

	if($param->{'view_all'}){
		$print .= $html->tag("h3","ブロック中");
		$print .= qq(<table>);
		$print .= $self->data_group_to_table_block($blocked_data_group);
		$print .= qq(</table>);
	}

$print = $self->around_edit_form($print);

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub around_edit_form{

my $self = shift;
my $html_body = shift || return();
my $this_mode_key = $self->community_mode_param_key();
my $html = new Mebius::HTML;
my($print);

$print .= $html->start_tag("form",{ method => "post" });

$print .= $html->input("submit","","この内容で編集する");

$print .= $html->input("hidden","mode",$this_mode_key);

$print .= $html_body;

$print .= $html->input("submit","","この内容で登録する");
$print .= $html->close_tag("form");

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub refresh_all_used_community_data{

my $self = shift;
my $data_group = $self->fetchrow_main_table({ use_flag => 1 });

	foreach my $data ( @{$data_group} ){
		my $html_data = $self->get_community_html_data($data->{'id'}) || {};

		my %update = (%{$data},%{$html_data});
		$self->update_main_table(\%update);
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit{

my $self = shift;
my $query = new Mebius::Query;
my $param = $query->param();
my(%target);

my $data_hash = $self->fetchrow_on_hash_main_table({},"target");

	foreach my $key ( keys %{$param} ){

		my $value = $param->{$key};
		my(%update);

			# CONTROL
			if($key =~ /^mixi_community_control_([0-9a-zA-Z]+)$/){

				$update{'target'} = $1;

					if($value eq "delete"){
						$update{'deleted_flag'} = 1;
						$update{'use_flag'} = 0;
					} elsif($value eq "block"){
						$update{'block_flag'} = 1;
						$update{'deleted_flag'} = 1;
						$update{'use_flag'} = 0;
					} elsif($value eq "use") {
						$update{'create_time'} = time;
						$update{'use_flag'} = 1;
						$update{'block_flag'} = 0;
						$update{'deleted_flag'} = 0;
					}

			# TARGET OLD
			} elsif($key =~ /^mixi_community_target_old_([0-9a-zA-Z]+)$/){

				$update{'target'} = $1;

					if($value =~ /^([0-9]+)-([0-9]+)$/){
						$update{'low_age'} = $1;
						$update{'high_age'} = $2;
					} elsif($value eq "all"){
						$update{'low_age'} = 0;
						$update{'high_age'} = 0;
					}

			# TARGET WEEKDAY
			} elsif($key =~ /^mixi_community_target_weekday_([0-9a-zA-Z]+)$/){

				$update{'target'} = $1;

					if($value =~ /^([a-z]+)$/){
						$update{'weekday'} = $value;
					}

			# TODOUFUKEN
			} elsif($key =~ /^mixi_community_location_pref_id_([0-9a-zA-Z]+)$/){

				$update{'target'} = $1;

					if($value =~ /^([0-9]+)$/){
						$update{'location_pref_id'} = $value;
					}

			} elsif($key =~ /^mixi_community_event_kinds_([0-9a-zA-Z]+)$/){

				$update{'target'} = $1;

					if($value =~ /^([0-9a-zA-Z\s]+)$|^$/){
						$update{'event_kinds'} = $value;
					}

			} elsif($key =~ /^mixi_community_sex_target_([0-9a-zA-Z]+)$/){

				$update{'target'} = $1;

					if($value =~ /^(male|female)$|^$/){
						$update{'sex_target'} = $value;
					}

			} elsif($key =~ /^mixi_community_total_member_num_([0-9a-zA-Z]+)$/){

				$update{'target'} = $1;
					if($value =~ /^([0-9]+)$|^$/){
						$update{'total_member_num'} = $value;
					}

			} elsif($key =~ /^mixi_community_allow_submit_topic_flag_([0-9a-zA-Z]+)$/){

				$update{'target'} = $1;

					if($value =~ /^([0-9]+)$/){
						$update{'allow_submit_topic_flag'} = $1;
					} else {
						$update{'allow_submit_topic_flag'} = 0;
					}

			} elsif($key =~ /^mixi_community_control_comment_topic_event_id_([0-9a-zA-Z]+)$/){

				$update{'target'} = $1;

					if($value =~ /^([0-9]+)$/){
						$update{'comment_topic_event_id'} = $1;
					} else {
						$update{'comment_topic_event_id'} = 0;
					}

			}


			if(%update){

				my $target = $update{'target'};
				my %data = %{$data_hash->{$target}};
				$self->eq_or_update(\%data,\%update,undef,['create_time']);

			}

	}

my $move = new Mebius::Move;
$move->redirect_to_self_url();

exit;


}





#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_value_to_low_age{

my $self = shift;
my $value = shift || return();
my($old);

	if($value =~ /^([0-9]+)-([0-9]+)$/){
		$old = $1;
	} elsif($value){
		$old = 0;
	}

$old;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_value_to_high_age{

my $self = shift;
my $value = shift || return();
my($old);

	if($value =~ /^([0-9]+)-([0-9]+)$/){
		$old = $2;
	} elsif($value){
		$old = 0;
	}

$old;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_submit_community{

my $self = shift;
my $all_of_texts = shift || return();
my $use = shift || {};
my $basic = $self->basic_object();
my $html = new Mebius::HTML;
my $move = new Mebius::Move;
my $mixi_account = new Mebius::Mixi::Account;
my $operate = new Mebius::Operate;
my($print,$hit,@id,@link,@all_community_id,%inputed_title,$hit_search_results,$hit_submit_community,@no_hit_title);

my $max_hit = 50;

my $email = $mixi_account->random_limited_account_email();

my @text = split(/\n|\r/,$all_of_texts);

	foreach my $text (@text){

		$text = $self->delete_spece_from_community_title($text);
		$text =~ s/×//g;

			if($inputed_title{$text}++){
				next:
			}

			if(!$use->{'get_data'} || $hit > $max_hit){ next; }
			if($text eq ""){ next; }

		$hit++;

			if($text =~ m!http://mixi\.jp/view_community\.pl\?id=([0-9]+)!){

				push @all_community_id , $1;

			} elsif($text =~ /^([0-9]+)$/){

				push @all_community_id , $1;

			} else {

					if($use->{'get_data'} eq "limited"){

							if( my $data = $self->fetchrow_main_table({ title => $text })->[0] ){
								push @all_community_id , $data->{'id'};
								next;
							}

					}

				$hit_search_results++;

				my $search_result_url = $self->search_result_url($text);

				my $search_result_html = $basic->get("$search_result_url&search_mode=title",$email);

				$basic->rest_sleep();
				
				my @community_id = $self->search_result_html_to_ids($search_result_html);

					if(@community_id >= 1){
							if($use->{'get_data'} eq "limited"){
								push @all_community_id , $community_id[0];
							} else {
								push @all_community_id , @community_id;
							}
					} else {
						push @no_hit_title , $text;
					}
			}

	}


	foreach my $id (@all_community_id){
		my($succeed_flag,$data) = $self->submit_community($id);
			if($succeed_flag eq "1"){
				$hit_submit_community++;
			}
	}


my $data_group = $self->fetchrow_main_table_desc({ id => ["IN",\@all_community_id] },"total_member_num");



$print .= qq(<div>);
$print .= qq(検索行数: ).e($hit || 0);
$print .= qq(</div>);

$print .= qq(<div>);
$print .= qq(mixiでの検索回数: ).e($hit_search_results || 0);
$print .= qq(</div>);

	if(my @redun_array_keys = $operate->redun_array_values(\@all_community_id)){
		$print .= qq(<div>);
		$print .= qq(IDの重複: ).e("@redun_array_keys");
		$print .= qq(</div>);

	}

$print .= qq(<div>);
$print .= qq(mixiでのコミュニティデータ取得回数: ).e($hit_submit_community || 0);
$print .= qq(</div>);

	if(@no_hit_title){

		@no_hit_title = map { qq(<li>).$_.qq(</li>); } @no_hit_title;
		$print .= qq(<div>);
		$print .= qq(ヒットしなかったコミュニティ: );
		$print .= qq(<ul>);
		$print .= join "" , 	@no_hit_title;
		$print .= qq(</ul>);
		$print .= qq(</div>);

	}


my $table .= qq(<table>);
$table .= $self->data_group_to_table_block($data_group,{ inputed_title => \%inputed_title } );
$table .= qq(</table>);

$print .= $self->around_edit_form($table);

$print .= $html->tag("h2","検索",{ id => "search" });
$print .= $self->search_form();




$basic->print_html($print,{ Title => "コミュニティの取得" });
exit;

#my $move = new Mebius::Move;
#$move->redirect_to_self_url();
#exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_community{

my $self = shift;
my $id = shift || return();
my $basic = $self->basic_object();
my(%insert,$succeed_flag);

my $data = my $data_exists_flag = $self->fetchrow_main_table({ id => $id })->[0];

$insert{'id'} = $id;


	if($data->{'title'} && $data->{'total_member_num'}){
			if(wantarray){
				return 0,$data;
			} else {
				return $data;
			}
	}

my $html_data = $self->get_community_html_data($id);
%insert = (%{$html_data},%insert);

$succeed_flag = 1;

$basic->rest_sleep();

$insert{'last_modified'} = time;

	if($data_exists_flag){

		$insert{'target'} = $data->{'target'};
		$self->update_main_table(\%insert,{ WHERE => { id => $id } });

	} else {

		$insert{'target'} = $self->new_target_char();
		$self->insert_main_table(\%insert,{ WHERE => { id => $id } });

	}

	if(wantarray){
		$succeed_flag,\%insert;
	} else {
		\%insert;
	}

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub community_mode_param_key{
"submit_community";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_input_list{

my $self = shift;
my $data_group = shift || return();
my $html = new Mebius::HTML;
my($print);

	foreach my $data (@{$data_group}){
		my $title = $data->{'title'} || next;
		my $url = $self->community_data_to_url($data);
		$print .= qq(<li>);
		$print .= $html->input("checkbox","mixi_community_id_$data->{'id'}","auto_submit_event",{ text => $title , checked => 1 }) . "\n";
		$print .= $html->href($url,"[URL]",{ target => "_blank" });
		$print .= qq(</li>);

	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_radio_parts{

my $self = shift;
my $data_group = shift || return();
my $html = new Mebius::HTML;
my($print);

	foreach my $data (@{$data_group}){
		my $title = $data->{'title'} || next;
		my $url = $self->community_data_to_url($data);
		$print .= $html->input("radio","id",$data->{'id'},{ text => $title }) . "\n";
		$print .= $html->href($url,"★",{ target => "_blank" });
	}

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub join_community{

my $self = shift;
my $community_id = shift;
my $email = shift || die;
my $basic = $self->basic_object();
my(%input,$print,$succeed_flag,$post_key);

my $mixi_url = $basic->mixi_url();

my $community_data = $self->fetchrow_main_table({ id => $community_id })->[0];

my $community_line_for_message = "community [$community_id] "; #$community_data->{'title'}
$basic->try_log($email,"Access to $community_line_for_message .");

my $community_top_url = $self->id_to_community_url($community_id);
my $community_top_html = $basic->get($community_top_url,$email);

$basic->preview_sleep();


	if($community_top_html =~ m/href="leave_community\.pl/){
		$basic->succeed_log($email,"Still joined to $community_line_for_message.",$community_top_html);
		return 1;
	} elsif( $post_key = $basic->html_to_post_key($community_top_html,$email) ){
		$basic->succeed_log($email,"Accessed to $community_line_for_message.",$community_top_html);
	} else {
		$basic->failed_log($email,"Can not get post key of $community_line_for_message.",$community_top_html);
		return();
	}

$basic->try_log($email,"Join to community $community_line_for_message.");

$input{'confirm'} = 1;
$input{'post_key'} = $post_key || die;
$input{'id'} = $community_id;
$input{'referer'} = "view_community.pl?id=$community_id";

my $join_url = "${mixi_url}join_community.pl";
my $submited_html = $basic->post($join_url,$email,\%input,{ referer => $community_top_url });

	if($submited_html eq ""){
		$basic->failed_log($email,"Can not post to $community_line_for_message .",$submited_html);
		return();

	} elsif($submited_html =~ m!<title>302 Found</title>! && $submited_html =~ m!<a href="view_community\.pl\?id=$community_id">!){

		$succeed_flag = 1;
		$basic->finished_log($email,"Join community to $community_line_for_message .",$submited_html);

	} elsif($submited_html =~ m!<p class="messageAlert">既にこのコミュニティに参加しています。</p>!){		$succeed_flag = 1;

		$basic->succeed_log($email,"Already joined to $community_line_for_message .",$submited_html);
		return 1;

	} else {

		$basic->failed_log($email,"Can not join to $community_line_for_message .",$submited_html);
		return();

	}
	
my $moved_url = $community_top_url;
my $moved_html = $basic->get($community_top_url,$email,{ referer => $community_top_url });

	if($moved_html){
		$basic->succeed_log($email,"Succeed move page after joyning $community_line_for_message .",$moved_html);
	} else {
		$basic->failed_log($email,"Can not move page after joyning $community_line_for_message .",$moved_html);
		return();
	}

$basic->rest_sleep();

$succeed_flag;

}


1;
