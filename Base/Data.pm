
use strict;
package Mebius::Base::Data;
use Mebius::Export;
use Mebius::Fillter;
use Mebius::PageBack;
use base qw(Mebius::Base::Sitemap Mebius::Base::View);



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_limited_package_name{
my $self = shift;
my $basic = $self->basic_object() || return();

my $main_limited_package_name = $basic->main_limited_package_name();
$main_limited_package_name;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_flat_list{

my $self = shift;
my($print);

#$print .= qq(<div class="line-height-large">);
$print .= $self->data_group_to_core("flat_list",@_);
#$print .= qq(</div>);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_list{

my $self = shift;
my($hit,$line);

$self->data_group_to_core("list",@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub query_to_junction{

my $self = shift;
my($param) = Mebius::query_single_param();
my $basic = $self->basic_object();
my $limited_package_name = $self->limited_package_name();
my $page_back = new Mebius::PageBack;

	if($param->{'tail'}){

			if($param->{'mode'} eq "sitemap_index_$limited_package_name" && $param->{'tail'} eq "xml"){
				$self->sitemap_index_view();
			} elsif($param->{'mode'} =~ /^sitemap_${limited_package_name}_([0-9]{1,5})$/ && $param->{'tail'} eq "xml"){
				$self->sitemap_view_per_year($1);
			} elsif($param->{'mode'} =~ /^sitemap_${limited_package_name}_([0-9]{1,5})_([0-9]{1,2})$/ && $param->{'tail'} eq "xml"){
				my $year = $1;
				my $month = $2;
				$self->sitemap_view($year,$month);
			} else {
				$basic->error("このページは存在しません。");
			}

	} else {

			if($param->{'mode'} eq "recently_list_$limited_package_name"){
				$self->recently_list_view();
			} elsif($param->{'mode'} eq "recently_line_$limited_package_name"){
				$self->recently_line_view();
			} elsif($param->{'mode'} eq "my_list_$limited_package_name"){
				$self->my_submited_list_view();
			} elsif($param->{'mode'} eq "my_line_$limited_package_name"){
				$self->my_submited_line_view();
			} elsif($param->{'mode'} =~ /^index_${limited_package_name}_([0-9]{1,5})_([0-9]{1,2})$/){
				$self->index_per_month_view($1,$2);
			} elsif($param->{'mode'} =~ /^index_map_month_${limited_package_name}$/){
				$self->index_map_per_month_view();
			} elsif($self->query_to_control()){
				$page_back->redirect() || $basic->print_html("実行しました。");
			}
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_line{

my $self = shift;
my($hit,$line);

$self->data_group_to_core("line",@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_core{

my $self = shift;
my $type = shift;
my $data_group = shift;
my $use = shift || {};
my($hit,$line);


	foreach my $data ( @{$data_group} ){

		my($data_line);

			if($self->data_to_next($data)){
				next;
			} elsif($data->{'deleted_flag'} && !Mebius->common_admin_judge()){
				next;
			} elsif($use->{'max_view'} && $hit >= $use->{'max_view'}){
				last;
			}
			
		my %new_use = (%{$use},( hit => $hit ));

			if($type eq "line"){
				$data_line = $self->data_to_line($data,\%new_use);
			} elsif ($type eq "list"){
				$data_line = $self->data_to_list($data,\%new_use);
			} elsif ($type eq "flat_list"){
				$data_line = $self->data_to_flat_list($data,\%new_use);

			} else {
				next;
			}	

			if($data_line){
				$line .= $data_line;
				$hit++;
			}

	}


$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_next{
my $self = shift;
0;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub content_type_is_on_this_package{

my $self = shift;
my $data = shift;
my($flag);

my $main_limited_package_name = $self->main_limited_package_name();
my $limited_package_name = $self->limited_package_name();

	if($data->{'content_typeA'} eq $main_limited_package_name && $data->{'content_typeB'} eq $limited_package_name){
		$flag = 1;
	} else {
		0;
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
#sub multi_data_to_url{

#my $self = shift;
#my $data = shift;
#my $use = shift;
#my $limited_package_name = $self->limited_package_name();
#my $link;

#	if($data->{'content_typeB'} eq $limited_package_name){
#		$link = $self->data_to_url($data,$use);
#	} else {
#		return();
#	}

#$link;

#}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
#sub multi_data_to_url_with_move{

#my $self = shift;
#my $data = shift;
#my $use = shift;
#my $limited_package_name = $self->limited_package_name();
#my $link;

#	if($data->{'content_typeB'} eq $limited_package_name){
#		$link = $self->data_to_url_with_move($data,$use);
#	} else {
#		return();
#	}


#$link;

#}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub multi_data_to_link{

my $self = shift;
my $data = shift;
my $use = shift;
my $link;
my $limited_package_name = $self->limited_package_name();

	if($data->{'content_typeB'} eq $limited_package_name){
		$link = $self->data_to_link($data,$use);
	} else {
		return();
	}

$link;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{ }
sub data_to_url_with_response_history{ }
sub data_to_url_with_move{ }
sub data_to_url{ }


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_link{

my $self = shift;
my $data = shift || return();
my $html = new Mebius::HTML;
my($link,$title);

	if( my $effected_title =  $self->effect_title($data->{'title'},$data)){
		$title = $effected_title;
	} else {
		$title = $data->{'title'};
	}

my $url = $self->data_to_url($data);
$link = $html->href($url,$title);

$link;

}

sub effect_title{}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_h1_link{

my $self = shift;
my $data = shift || return();
my $html = new Mebius::HTML;
my($link);

my $url = $self->data_to_url($data);
$link = $html->tag("h1",$data->{'title'},"",{ href => $url });

$link;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_flat_list{

my $self = shift;
my $data = shift || return();
my $use = shift || {};
my($print);
my %relay_use = (%{$use},( type => "flat" ));

$print .= $self->data_to_list($data,\%relay_use);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift || return();
my $use = shift || {};
my $html = new Mebius::HTML;
my($my_account) = Mebius::my_account();
my($line);

my $url = $self->data_to_url($data);
my $full_title = $data->{'title'} || return();

	if( my $response_num = $data->{'response_num'} ){
		$full_title .= "(" . e($response_num) . ")";
	}

	if($use->{'type'} ne "flat"){
		$line .= $html->start_tag("li");
	}

$line .= $html->href($url,$full_title);
	if($data->{'deleted_flag'}){
		$line .= " " . $html->tag("span","[削除]",{ class => "red" });
	}

	if($use->{'type'} ne "flat"){
		$line .= $html->close_tag("li");
	}

$line .= "\n";

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_option_data_line{

my $self = shift;
my $data = shift;
my $times = new Mebius::Time;
my($line);

$line .= $times->how_before($data->{'create_time'}) . " ";

$line .= $self->report_button($data);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_control_parts{

my $self = shift;
my $data = shift;
my $use = shift || {};
my $html = new Mebius::HTML;
my $control = new Mebius::Control;
my($line);


my $main_limited_package_name = $self->main_limited_package_name();
my $limited_package_name = $self->limited_package_name();
my $label_name = $self->japanese_label();

my $target = $data->{'target'} || $data->{'number'};
my $use_full_delete = $self->use_full_delete();
my %new_use = (%{$use},(use_full_delete => $use_full_delete  ));

	if(Mebius->common_admin_judge() || $use->{'ForcedView'}){
		$line .= qq(<div>); # class="right" style="font-size:120%;"
			if($label_name){
				$line .= $html->tag("strong","${label_name}： ") ;
			}
		$line .= $control->radio_parts("${main_limited_package_name}_${limited_package_name}_control_$target",$data , \%new_use);
		$line .= qq(</div>);

	}

	if(Mebius->common_admin_judge() || $use->{'ForcedView'}){
		$line .= qq(<div class="right margin-top">);
		$line .= $control->user_control_link_series($data);
		$line .= qq(</div>);
	}

$line;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub query_to_control{

my $self = shift;
my $basic = $self->basic_object();
my($param) = Mebius::query_single_param();
my $page_back = new Mebius::PageBack;
my($flag);


	foreach my $key ( %{$param} ) {

		if(!$self->push_good_mode() && $self->param_to_control($key)){
			$flag = 1;
			next;
		} elsif(!$self->push_good_mode() && $self->param_to_report_preview($key)){
			$flag = 1;
			last;
		}	elsif($self->push_good_mode() && $self->param_to_push_good($key)){
			$page_back->redirect() || $basic->print_html("実行しました。");
			$flag = 1;
			last;
		}

	}

$flag;

}
sub push_good_mode{ 0; }


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_html{

my $self = shift;
my $basic = $self->basic_object();

	if(console){
		console "PRINT HTML"
	} else {
		$basic->print_html(@_);
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub control_record{

my $self = shift;
my $target = shift ;
my $control_type = shift || die;
my $penalty = new Mebius::Penalty;
my $report = new Mebius::Report;
my $init = $self->init();
my $basic = $self->basic_object();
my(%update,$delete_flag);

my $limited_package_name = $self->limited_package_name();
my $main_limited_package_name = $self->main_limited_package_name();

$update{'target'} = $target;


	if(!Mebius->common_admin_judge()){
		return();
	}

my $data = $self->fetchrow_main_table({ target => $target })->[0];

	if(!$data){
		return();
	}

	if($control_type eq "delete" && !$data->{'deleted_flag'}){

		$update{'deleted_flag'} = time;
		$delete_flag = 1;

	} elsif($self->use_full_delete() && $control_type eq "full_delete" && !$data->{'full_deleted_flag'}){

		$update{'full_deleted_flag'} = time;
		$update{'deleted_flag'} = time;
		$delete_flag = 1;


	} elsif($control_type eq "penalty" && !$data->{'deleted_flag'} && Mebius->common_admin_judge()){

		$update{'deleted_flag'} = time;
		$update{'penalty_flag'} = time;
		$delete_flag = 1;

		my $penaltied_title = "$data->{'title'} " . " | "  . ($init->{'title'} || $basic->site_title());
		my $url = $self->data_to_url($data);
		$penalty->add($data,{ url => $url , place => $penaltied_title , source => "utf8" }); # 

	} elsif($control_type eq "revive" && $data->{'deleted_flag'} && Mebius->common_admin_judge()){

		$update{'deleted_flag'} = 0;
		$update{'full_deleted_flag'} = 0;

			if($data->{'penalty_flag'}){
				$update{'penalty_flag'} = 0;
				$penalty->cancel($data,{ source => "utf8" });
			}

		$self->revive_to_update_relation_data($data);

	} elsif($control_type eq "no-reaction" && Mebius->common_admin_judge()){
		1;
	} else {
		return();
	}

	if($delete_flag){
		$self->delete_to_update_relation_data($data);
	}


$self->update_main_table(\%update,{ WHERE => { target => $target } },{ Debug => 0 });

$report->update_main_table({ answer_time => time },{ WHERE => { content_type => $main_limited_package_name , target_unique_number => $target } , Debug => 0 });

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub relation_object{
0;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_to_update_relation_data{

my $self = shift;
my $data = shift;

my $relation_object = $self->relation_object() || return();
$relation_object->update_main_table({ target => $data->{'relation_target'} , deleted_response_num => ["+",1] , deleted_comment_num => ["+",1] },{ Debug => 0 });

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub revive_to_update_relation_data{

my $self = shift;
my $data = shift;

my $relation_object = $self->relation_object() || return();
$relation_object->update_main_table({ target => $data->{'relation_target'} , deleted_response_num => ["-",1] ,  deleted_comment_num => ["-",1] },{ Debug => 0 });

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub use_full_delete{
0;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_to_control{

my $self = shift;
my $param_name = shift;
my($param) = Mebius::query_single_param();
my($flag);

my $main_limited_package_name = $self->main_limited_package_name();
my $limited_package_name = $self->limited_package_name();

	if($param->{$param_name} && $param_name =~ /^${main_limited_package_name}_${limited_package_name}_control_([^_]+)$/){

		my $target = $1;

		$self->control_record($target,$param->{$param_name});
		$flag = 1;

	} else {
		0;
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_to_some_action{

my $self = shift;
my $key = shift;
my($done);

	if($self->param_to_control($key)){
		$done = 1;
	} elsif($self->param_to_report_preview($key)){
		$done = 1;
	} elsif($self->param_to_push_good($key)){
		$done = 1;
	}

$done;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_to_push_good{

my $self = shift;
my $param_name = shift;
my($param) = Mebius::query_single_param();

my $limited_full_package_name = $self->limited_full_package_name();

	if($param_name =~ /^${limited_full_package_name}_(push|cancel)_(good|bad)_([^_]+)$/){

		my $push_or_cancel = $1;
		my $good_or_bad = $2;
		my $target = $3;
			if($good_or_bad eq "good"){
					if($push_or_cancel eq "push"){
						$self->push_good($target);
					} elsif($push_or_cancel eq "cancel"){
						$self->cancel_good($target);
					}
			} elsif($self->use_push_bad() && $good_or_bad eq "bad"){
					if($push_or_cancel eq "push"){
						$self->push_bad($target);
					} elsif($push_or_cancel eq "cancel"){
						$self->cancel_bad($target);
					}
			}

	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub around_control_form{

my $self = shift;
my $inline_html = shift;
my $html = new Mebius::HTML;
my($print);

my $main_limited_pacage_name = $self->main_limited_package_name();
my $limited_package_name = $self->limited_package_name();

$print .= $html->start_tag("form",{ method => "post" , id => "${main_limited_pacage_name}_${limited_package_name}_control" , action => "" } );
$print .= $html->input("hidden","mode","control");
$print .= Mebius::back_url_input_hidden();
$print .= $inline_html;

$print .= $html->close_tag("form");

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub good_and_bad_button{

my $self = shift;
my($print);

$print .= $self->good_button(@_);
$print .= $self->bad_button(@_);

$print;

}


#-----------------------------------------------------------
# いいね！ ボタン
#-----------------------------------------------------------
sub good_button{

my $self = shift;
my $data = shift;
$self->good_or_bad_button($data,@_);

}


#-----------------------------------------------------------
# いいね！ ボタン
#-----------------------------------------------------------
sub bad_button{

my $self = shift;
my $data = shift;
$self->good_or_bad_button($data,{ BadButton => 1 });

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub good_or_bad_button{

my $self = shift;
my $data = shift || die;
my $use = shift || {};
my $html = new Mebius::HTML;
my($my_account) = Mebius::my_account();
my($button,$onclick,$id,$disabled,$style,$class,$good_or_bad_num,$type_text,$type);
my $main_limited_package_name = $self->main_limited_package_name();
my $limited_package_name = $self->limited_package_name();
my($push_or_cancel,$still_pushed);

	if($use->{'NewMode'}){
		my $data_group = $self->fetchrow_main_table({ relation_target => $data->{'target'} });
		$still_pushed = $self->data_group_to_still_pushed_judge($data_group,$data->{'target'});

		$good_or_bad_num = @{$data_group} || 0;
	}

	if($use->{'BadButton'}){
		$still_pushed ||= $self->still_push_bad($data);
		$type = "bad";
		$type_text = "いまいち";
		$good_or_bad_num ||= $data->{'bad_num'} || 0;
			if($still_pushed){
				$push_or_cancel = "cancel";
			} else {
				$push_or_cancel = "push";
			}
	} else {
		$still_pushed ||= $self->still_push_good($data);
		$type = "good";
		$type_text = "いいね";
		$good_or_bad_num ||= $data->{'good_num'} || 0;
			if($still_pushed){
				$push_or_cancel = "cancel";
			} else {
				$push_or_cancel = "push";
			}

	}

my $target = $data->{'target'} || $data->{'number'};

	if(!$use->{'Debug'}){

			if($ENV{'HTTP_USER_AGENT'} !~ /MSIE [1-8]\./){
				$onclick = qq(push_good({},this,$good_or_bad_num,1,'$push_or_cancel');return false;);
			}

		$id = "${main_limited_package_name}_${limited_package_name}_${push_or_cancel}_${type}_${target}";


			if($self->push_bad_account_only() && $type eq "bad" && !$my_account->{'login_flag'}){
				$disabled = 1;
			}

			if($self->push_good_account_only() && !$my_account->{'login_flag'}){
				$disabled = 1;
			} elsif($still_pushed){
				$class = "${type}_disabled";
				#$style = "color:#080;";
			} else {
				$class = "good";
			}
	}

$button .= $html->input("submit","${main_limited_package_name}_${limited_package_name}_${push_or_cancel}_${type}_${target}","$type_text($good_or_bad_num)",{ class => $class ,  onclick => $onclick , id => $id ,  disabled => $disabled , style => $style });

	if(Mebius::alocal_judge() || $my_account->{'master_flag'}){
		$button .= $html->input("submit","${main_limited_package_name}_${limited_package_name}_${push_or_cancel}_${type}_${target}","$type_text($good_or_bad_num)",{ class => $class , style => $style });
	}


$button;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub push_good_account_only{
0;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub push_bad_account_only{
1;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub use_push_bad{
0;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub push_bad{

my $self = shift;
my $target = shift;
$self->push_good($target,{ PushBad => 1 });

}

#-----------------------------------------------------------
# いいね！を押す
#-----------------------------------------------------------
sub push_good{

my $self = shift;
my $target = shift;
my $use = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my $operate = new Mebius::Operate;
my $data = $self->target_to_data($target);
my $debug = new Mebius::Debug;
my $query = new Mebius::Query;
my(@update_good_addrs,$dupulicate_flag);
my $mebius = new Mebius;

my $data = $self->target_to_data($target);

	if($data->{'deleted_flag'}){
		$self->error("削除済みです。");
	}

$mebius->axs_check();

$query->post_method_or_error();

	if($use->{'PushBad'} && $self->push_bad_account_only() && !$my_account->{'login_flag'}){
		$self->error("アカウントにログインして下さい。");
	} elsif(($self->still_push_good($data) || $self->still_push_bad($data)) && !$debug->escape_error()){
		$self->error("既に投票しています。");
	} else {

		my $primary_key = $self->get_primary_key_from_main_table();

			# PUSH GOOD
			if($use->{'PushBad'} && $self->use_push_bad()){

				my @bad_addrs = $operate->push_limited_num($data->{'bad_addrs'} , $ENV{'REMOTE_ADDR'} , 50);
				my @bad_cnumbers = $operate->push_limited_num($data->{'bad_cnumbers'} , $my_cookie->{'char'} , 50);
				my @bad_accounts = $operate->push_limited_num($data->{'bad_accounts'} , $my_account->{'id'});

					if(my $redun_flag = Mebius::Redun(undef,"question_push_bad",60)){
						$self->error("連続でいまいちはできません。");
					}

				$self->update_main_table({ $primary_key => $target , bad_num => ["+",1] , bad_addrs => "@bad_addrs" , bad_cnumbers => "@bad_cnumbers" , bad_accounts => "@bad_accounts" }) || $self->error("更新できませんでした。");
			
			# PUSH BAD
			} else {
				my @good_addrs = $operate->push_limited_num($data->{'good_addrs'} , $ENV{'REMOTE_ADDR'} , 50);
				my @good_cnumbers = $operate->push_limited_num($data->{'good_cnumbers'} , $my_cookie->{'char'} , 50);
				my @good_accounts = $operate->push_limited_num($data->{'good_accounts'} , $my_account->{'id'});

				$self->update_main_table({ $primary_key => $target , good_num => ["+",1] , good_addrs => "@good_addrs" , good_cnumbers => "@good_cnumbers" , good_accounts => "@good_accounts" }) || $self->error("更新できませんでした。");
			}
		


	}

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub cancel_bad{

my $self = shift;
my $target = shift;
$self->cancel_good($target,{ CancelBad => 1 });

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub cancel_good{

my $self = shift;
my $target = shift;
my $use = shift;
my $operate = new Mebius::Operate;
my $data = $self->target_to_data($target);
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();

	if($use->{'PushBad'} && $self->push_bad_account_only() && !$my_account->{'login_flag'}){
		$self->error("アカウントにログインして下さい。");
	}


my $primary_key = $self->get_primary_key_from_main_table();

	if($use->{'CancelBad'}){

			if(!$self->still_push_bad($data)){
					$self->error("投票していないのでキャンセルできません。");
			}

		my @bad_addrs =  $operate->delete_element_near_array($data->{'bad_addrs'},$ENV{'REMOTE_ADDR'});
		my @bad_cnumbers =  $operate->delete_element_near_array($data->{'bad_cnumbers'},$my_cookie->{'char'});
		my @bad_accounts =  $operate->delete_element_near_array($data->{'bad_accounts'},$my_account->{'id'});
		$self->update_main_table({ $primary_key => $target , bad_num => ["-",1] , bad_addrs => "@bad_addrs" , bad_cnumbers => "@bad_cnumbers" , bad_accounts => "@bad_accounts" }) || $self->error("更新できませんでした。");

	} else {

			if(!$self->still_push_good($data)){
					$self->error("投票していないのでキャンセルできません。");
			}

		my @good_addrs =  $operate->delete_element_near_array($data->{'good_addrs'},$ENV{'REMOTE_ADDR'});
		my @good_cnumbers =  $operate->delete_element_near_array($data->{'good_cnumbers'},$my_cookie->{'char'});
		my @good_accounts =  $operate->delete_element_near_array($data->{'good_accounts'},$my_account->{'id'});
		$self->update_main_table({ $primary_key => $target , good_num => ["-",1] , good_addrs => "@good_addrs" , good_cnumbers => "@good_cnumbers" , good_accounts => "@good_accounts" }) || $self->error("更新できませんでした。");
	}


}



#-----------------------------------------------------------
# 既にいいねを押している場合
#-----------------------------------------------------------
sub still_push_good{

my $self = shift;
my $data = shift || die;
my $operate = new Mebius::Operate;
my($still_flag);
my($my_cookie) = Mebius::my_cookie_main();
my($my_account) = Mebius::my_account();

	if($operate->element_in_array($data->{'good_addrs'},$ENV{'REMOTE_ADDR'})){
		$still_flag = 1;
	}

	if($operate->element_in_array($data->{'good_accounts'},$my_account->{'id'})){
		$still_flag = 1;
	}

	if($operate->element_in_array($data->{'good_cnumbers'},$my_cookie->{'char'})){
		$still_flag = 1;
	}



$still_flag;

}

#-----------------------------------------------------------
# 既にいいねを押している場合
#-----------------------------------------------------------
sub still_push_bad{

my $self = shift;
my $data = shift || die;
my $operate = new Mebius::Operate;
my($still_flag);
my($my_cookie) = Mebius::my_cookie_main();
my($my_account) = Mebius::my_account();



	if($operate->element_in_array($data->{'bad_addrs'},$ENV{'REMOTE_ADDR'})){
		$still_flag = 1;
	}

	if($operate->element_in_array($data->{'bad_accounts'},$my_account->{'id'})){
		$still_flag = 1;
	}

	if($operate->element_in_array($data->{'bad_cnumbers'},$my_cookie->{'char'})){
		$still_flag = 1;
	}


$still_flag;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub push_good_javascript{

my $self = shift;
my $javascript = new Mebius::Javascript;

my $limited_full_package_name = $self->limited_full_package_name();
my $print = $javascript->push_good("${limited_full_package_name}_control");

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_full_package_name{

my $self = shift;
my $limited_package_name = $self->limited_package_name();
my $main_limited_package_name = $self->main_limited_package_name();

"${main_limited_package_name}_${limited_package_name}";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub target_to_data{

my $self = shift;
my $target = shift || return();

my $primary_key = $self->get_primary_key_from_main_table();
my $data = $self->fetchrow_main_table({ $primary_key => $target },{ Debug => 0 })->[0];

$data;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_button{

my $self = shift;
my $data = shift;
my $limited_full_package_name = $self->limited_full_package_name();
my $html = new Mebius::HTML;
my($disabled,$class,$button);

	if($data->{'deleted_flag'}){
		$disabled = 1;
	} else {
		$class = "report";
	}

$button .= $html->input("submit","${limited_full_package_name}_report_preview_$data->{'target'}","報告",{ class => $class , disabled => $disabled });
$button .= $html->input("hidden","report_mode",1);

$button;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub around_control_or_report_form{

my $self = shift;
my $print = shift || die;
my $data = shift || die;

	if( my $form = $self->report_around_form($print,$data->{'target'})){
		$print = $form;
	} else {
		$print = $self->around_control_form($print);
	}

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_preview_mode{

my $self = shift;
my($param) = Mebius::query_single_param();
my($flag);

	if($param->{'report_mode'}){
		$flag = 1;
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_preview_mode_judge{

my $self = shift;
my $target = shift || die;
my($param) = Mebius::query_single_param();
my($flag);

my $limited_full_package_name = $self->limited_full_package_name();
my $param_key = "${limited_full_package_name}_report_preview_$target";

	if($param->{$param_key}){
		$flag = 1;
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_around_form{

my $self = shift;
my $print = shift || die;
my $target = shift || die;
my($param) = Mebius::query_single_param();

	if(!$self->report_preview_mode_judge($target)){
		return();
	}

my $limited_full_package_name = $self->limited_full_package_name();

($print) = Mebius::Report::report_mode_around_form($print,"${limited_full_package_name}_${target}",{ Thread => 1 , source => "utf8" });

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_to_report_preview{

my $self = shift;
my $param_name = shift;
my($param) = Mebius::query_single_param();

my $limited_full_package_name = $self->limited_full_package_name();

	if($param_name =~ /^${limited_full_package_name}_report_preview_([^_]+)$/){
		my $target = $1;
		$self->report_preview($target);
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_to_report{

my $self = shift;
my $param_name = shift;
my($param) = Mebius::query_single_param();

my $limited_full_package_name = $self->limited_full_package_name();

	if($param_name =~ /^${limited_full_package_name}_report_([^_]+)$/){
		my $target = $1;
		$self->report($target);
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_preview{

my $self = shift;
my $target = shift;
my $html = new Mebius::HTML;
my $report = new Mebius::Report;
my($print);


my $limited_full_package_name = $self->limited_full_package_name();

my $data = $self->fetchrow_main_table({ target => $target , deleted_flag => ["<>",1] })->[0] || $self->error("報告できる対象がありません。");

$report->report_mode_junction({ source => "utf8" });

my $title = "違反報告";

$print .= $self->data_to_line($data);

#$print .= $html->tag("div",$data->{'text'});

$print .= $report->around_form(undef,"report_${limited_full_package_name}_$target",{ });

$self->print_html($print,{ h1 => $title , BCL => [$title] });

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_to_report_data{

my $self = shift;
my $query_name = shift || return();
my($param) = Mebius::query_single_param();
my(%report);

my $main_limited_package_name = $self->main_limited_package_name();
my $limited_package_name = $self->limited_package_name();

	if($query_name =~ /^report_${main_limited_package_name}_${limited_package_name}_([^_]+)$/){
		my $target = $1;
		$report{'target_unique_number'} = $target;
		$report{'content_type'} = $main_limited_package_name;
		$report{'targetA'} = $limited_package_name;
		my $adjusted_report = $self->add_report_data($target);
		%report = (%report,%{$adjusted_report});
		return \%report;
	} else {
		return();
	}

}

#-----------------------------------------------------------
# review /comment - common action
#-----------------------------------------------------------
sub add_report_data{
{};
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub target_to_data_line_with_report{

my $self = shift;
my $target = shift;
my $report_data_group = shift;

my $data = $self->target_to_data($target);

my $line = $self->data_to_line_with_report($data,$report_data_group);

$line;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line_with_report{

my $self = shift;
my $data = shift;
my $report_data_group = shift;
my $report = new Mebius::Report;
my($line);

my $data_line = $self->data_to_line($data);

$line .= $report->place_by_the_side($data_line,$report_data_group,{ access_data => $data });

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub no_reactioned_report_data_group{

my $self = shift;
my $report = new Mebius::Report;

my $main_limited_package_name = $self->main_limited_package_name();

my $report_data_group = $report->fetchrow_main_table({ content_type => $main_limited_package_name , answer_time => 0 });

$report_data_group;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_content_targets{

my $self = shift;
my $data = shift;
my $text = new Mebius::Text;
my(%hash,$i);

my $setting = $self->content_target_setting();

	foreach my $name (@{$setting}){

		$i++;
		my $alfabet = $text->number_to_alfabet($i);
		$hash{"content_target$alfabet"} = $data->{$name};
	}

%hash;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_on_status{
my $self = shift;
$self->control_deleted_flag_on_status("delete",@_);
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub revive_on_status{
my $self = shift;
$self->control_deleted_flag_on_status("revive",@_);
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub control_deleted_flag_on_status{

my $self = shift;
my $type = shift;
my $data = shift;
my $status = new Mebius::Status;
my(%fetchrow,%update);

	if($type eq "revive"){
		$update{'deleted_flag'} = 0;
	} elsif($type eq "delete") {
		$update{'deleted_flag'} = time;
	} else {
		die;
	}


my %content_targets = $self->data_to_content_targets($data);
my %content_types = $self->add_hash_with_content_type();


%fetchrow = (%fetchrow,%content_targets,%content_types);

	#if(Mebius::alocal_judge()){ Mebius::Debug::print_hash(\%update); }
	#if(Mebius::alocal_judge()){ Mebius::Debug::print_hash(\%fetchrow); }

$status->update_main_table(\%update , { WHERE => \%fetchrow ,  Debug => 0 });

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq()); }

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub read_on_history{

my $self = shift;
my $hash = shift;
my $last_read_response_num = $hash->{'res'} || $hash->{'response_num'} || $hash->{'comment_num'};
my $device = new Mebius::Device;
my $history = new Mebius::History;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my(%add_fetch);

my $main_limited_package_name = $self->main_limited_package_name();
my $limited_package_name = $self->limited_package_name();

my $adjusted_hash = $self->limited_adjust_hash_for_multi_data($hash);

$add_fetch{'content_typeA'} = $main_limited_package_name;
$add_fetch{'content_typeB'} = $limited_package_name;

%add_fetch = $device->add_hash_with_access_target(\%add_fetch);

my %fetch_adjusted = (%add_fetch,%{$adjusted_hash});

	foreach my $name ( keys %fetch_adjusted ){
			if($name !~ /^(access_target|access_target_type|content_target[A-Z]|content_type[A-Z])$/){
				delete $fetch_adjusted{$name};
			}
	}

$history->update_main_table({ last_read_time => time , last_read_response_num => $last_read_response_num },{ WHERE => \%fetch_adjusted , Debug => 0 });

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_common_history_on_comment{

my $self = shift;
my $insert = shift;
my($my_account) = Mebius::my_account();
my $account_handle = utf8_return($my_account->{'name'});
my(%adjust,%insert);

$adjust{'handle'} ||= $account_handle;
$adjust{'last_account'} ||= $my_account->{'id'};

my %adjusted_insert = (%{$insert},%adjust);
$self->create_common_history(\%adjusted_insert,@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_common_history_on_post{

my $self = shift;
my $insert = shift;
my($my_account) = Mebius::my_account();
my $account_handle = utf8_return($my_account->{'name'});
my(%adjust,%insert);

$adjust{'handle'} = $insert->{'handle'} || $account_handle;
$adjust{'first_handle'} = $insert->{'handle'} || $account_handle;
$adjust{'first_account'} = $my_account->{'id'};
$adjust{'content_create_time'} = time;

my %adjusted_insert = (%{$insert},%adjust);

$self->create_common_history(\%adjusted_insert,@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_common_history{

my $self = shift;
my $add_insert = shift || {};
my $add_insert_for_status = shift;
my $use = shift;
my $history = new Mebius::History;
my $device = new Mebius::Device;
my $status = new Mebius::Status;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my(%insert,%add_insert,%insert_for_status);

	unless(%insert = $device->add_hash_with_access_target(\%insert)){
		return();
	}

#	if(Mebius::alocal_judge()){ Mebius::Debug::print_hash($use); }

%insert = $self->add_hash_with_content_type(\%insert);

%insert = (%insert,%{$add_insert});

my $insert_with_connection = $device->add_hash_with_my_connection(\%insert);
my $insert_adjusted = $self->adjust_hash_for_multi_data($insert_with_connection);

	if( ref $add_insert_for_status eq "HASH" && %{$add_insert_for_status}){
		%insert_for_status = %{$add_insert_for_status};
	} else {
		%insert_for_status = %{$add_insert};
	}

$insert_adjusted->{'status_target'} = $self->renew_multi_status(\%insert_for_status);

my $where = $self->insert_to_where($insert_adjusted);

$history->create_new_history($where,$insert_adjusted,$use);
#$history->create_new_history($insert_with_connection);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub renew_multi_status{

my $self = shift;
my $add_insert = shift;
my $status = new Mebius::Status;
my %insert = %{$add_insert};

%insert = $self->add_hash_with_content_type(\%insert);

	#if(Mebius::alocal_judge()){ Mebius::Debug::print_hash(\%insert); }

my $insert_adjusted = $self->adjust_hash_for_multi_data(\%insert);

my $where = $self->insert_to_where($insert_adjusted);

$status->renew_status($where,$insert_adjusted);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub add_hash_with_content_type{

my $self = shift;
my $hash = shift || {};
my %hash = %{$hash};

$hash{'content_typeA'} = $self->main_limited_package_name();
$hash{'content_typeB'} = $self->limited_package_name();

%hash;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub insert_to_where{

my $self = shift;
my $insert = shift;
my(%where);

	foreach my $name ( keys %{$insert} ){
			if($name =~ /^(content_target|content_type)([A-Z])$/){
				$where{$name} = $insert->{$name};
			}
	}

\%where;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub content_target_to_normal_data{

my $self = shift;
my $data = shift;
my %hash = %{$data};
my $text = new Mebius::Text;
my $array = $self->content_target_setting();
my($i);

	foreach my $name (@{$array}) {
		$i++;
		my $alfabet = uc $text->number_to_alfabet($i);

			if( my $target = $data->{"content_target$alfabet"} ){
				$hash{$name} = $target;
			}
	}

\%hash;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_setting_for_multi_data{

my $self = shift;
my $array = $self->content_target_setting();
my $text = new Mebius::Text;
my (%hash,$i);

	foreach my $name (@{$array}){
		$i++;
		my $alfabet = uc $text->number_to_alfabet($i);
			push @{$hash{"content_target$alfabet"}} , $name;
	}

\%hash;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_adjust_hash_for_multi_data{

my $self = shift;
my $hash = shift;
my(%adjusted_hash);

my $adjust = $self->adjust_setting_for_multi_data();

	foreach my $key_name ( keys %{$adjust} ){

		$adjusted_hash{$key_name} = $hash->{$key_name};

			foreach my $adjust_name (@{$adjust->{$key_name}}){
				$adjusted_hash{$key_name} ||= $hash->{$adjust_name};
			}

	}

\%adjusted_hash;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_hash_for_multi_data{

my $self = shift;
my $hash = shift;

my $adjusted_hash = $self->limited_adjust_hash_for_multi_data($hash);

my %mixed_hash = (%{$hash},%{$adjusted_hash});

\%mixed_hash;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub recently_line_core{

my $self = shift;
my $type = shift;
my $use = shift;
my $sns_account = new Mebius::SNS::Account;
my($recently_line);

my $border_time = time - 30*24*60*60;

my $data_group = $self->fetchrow_main_table({ create_time => [">=",$border_time] });

my @sorted_data_group = sort { $b->{'create_time'} <=> $a->{'create_time'} } @{$data_group};

	if($use->{'AddAccountHandle'}){
		@sorted_data_group = @{$sns_account->add_handle_to_data_group(\@sorted_data_group)};
	}

	if($type eq "list"){
		$recently_line = $self->data_group_to_list(\@sorted_data_group,$use);
	} elsif($type eq "line"){
		$recently_line = $self->data_group_to_line(\@sorted_data_group,$use);
	}

$recently_line;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub recently_line{

my $self = shift;
my($print);

$self->recently_line_core("line",@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub recently_list{

my $self = shift;
my($print);

$self->recently_line_core("list",@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub recently_list_view{

my $self = shift;
my($print);

my $limited_package_name = $self->limited_package_name();

my $title = $self->japanese_label() || "最近の更新" ;

$print .= qq(<div class="line-height-large">);
$print .= $self->recently_list({ max_view => 100 });
$print .= qq(</div>);

$self->print_html($print,{ Title => $title , h1 => $title , BCL => [$title] });

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub recently_line_view{

my $self = shift;
my($print);

my $title = $self->japanese_label() || "最近の更新" ;

$print .= $self->recently_line({ max_view => 50 });

$self->print_html($print,{ Title => $title , h1 => $title , BCL => [$title] });

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_history_view{

my $self = shift;
my($print);

my $title = "あなたの更新";

$print .= $self->my_history_line({ max_view => 50 });

$print .= $self->push_good_javascript();

$self->print_html($print,{ Title => $title , h1 => $title , BCL => [$title] });

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_history_line{

my $self = shift;
my($my_account) = Mebius::my_account();
my $device = new Mebius::Device;
my(%where);

	if(%where = $device->my_user_target_on_hash_only({})){

	} else {
		return();
	}

my $data_group = $self->fetchrow_main_table(\%where,{ Debug => 0 });
my @sorted_data_group = sort { $b->{'create_time'} <=> $a->{'create_time'} } @{$data_group};

my @sorted_and_adjusted_data_group = $self->add_relation_data_to_data_group(\@sorted_data_group);

my $print = $self->data_group_to_line(\@sorted_and_adjusted_data_group,{ max_view => 50 });

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub add_relation_data_to_data_group{

my $self = shift;
my $data_group = shift;
my($relation_object,@adjusted_data_group);

	if( $relation_object = $self->relation_object() ){
		1;
	} else {
		return();
	}

my $primary_key = $relation_object->get_primary_key_from_main_table();

	if( my $relation_key = $self->get_relation_key_from_main_table()){

		my(%fetchrow);

			foreach my $data (@{$data_group}){
				$fetchrow{$data->{$relation_key}} = 1;
			}

		my @fetchrow = keys %fetchrow;

		my $relation_data_group = $relation_object->fetchrow_on_hash_main_table({ $primary_key => ["IN",\@fetchrow] });

			foreach my $data (@{$data_group}){
				my %adjusted_data = %{$data};
					$adjusted_data{"relation_data"} = $relation_data_group->{$data->{$relation_key}};
				push @adjusted_data_group , \%adjusted_data;
			}

	} else {
		return();
	}


@adjusted_data_group;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_name_line{

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;
my $sns_url = new Mebius::SNS::URL;
my $text = new Mebius::Text
my($my_use_device) = Mebius::my_use_device();
my($line,@line);

$line .= $html->start_tag("span",{ class => "word-spacing" });

	if( my $handle = $data->{'handle'}){

			if($my_use_device->{'smart_phone_flag'}){
				$handle = $text->omit_character($handle,10);
			}
		push @line , $html->tag("b",$handle);
	}

	if($data->{'account'}){
		push @line , $sns_url->account_link($data->{'account'});
	} elsif($data->{'user_id'}){
		push @line , $html->tag("span","★$data->{'user_id'}",{ class => "id" });
	}

$line .= join " " , @line;

$line .= $html->close_tag("span");

$line;

}

#-----------------------------------------------------------
# 検索フォーム
#-----------------------------------------------------------
sub search_form{

my $self = shift;
my $init = $self->init();
my $html = new Mebius::HTML;
my $param_utf8 = Mebius::Query->single_param_utf8_judged_device();
my($line);

my $title = $init->{'short_title'} || $init->{'title'};

$line .= $html->start_tag("form",{ action => $init->{'base_url'} });
$line .= $html->input("hidden","mode","search");
$line .= $html->input("search","keyword",$param_utf8->{'keyword'});
$line .= $html->input("submit","","${title}から検索");

$line .= $html->close_tag("form");
$line;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub search_view{

my $self = shift;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $param_utf8 = $query->single_param_utf8_judged_device();
my($print,$data_group);

my $title = "検索";

	if($param_utf8->{'keyword'}){
		$data_group = $self->fetchrow_main_table({ title => ["LIKE","%$param_utf8->{'keyword'}%"] });
	}

$print .= $self->search_form();

$print .= $html->start_tag("div",{ style => "line-height:2.0;" , class => "margin-top" });
$print .= $self->data_group_to_list($data_group) || "検索結果はありません。";
$print .= $html->close_tag("div");

$self->print_html($print,{ h1 => $title , BCL => ["検索"] });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub new_target{
my $self = shift;
$self->new_target_char(@_);
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub new_target_char{

my $self = shift;
my $char_num = shift || 20;
my $crypt = new Mebius::Crypt;
my($new_target,$target);

	for (1..100){
		$target =  $crypt->char($char_num);
			if(my $data = $self->fetchrow_main_table({ target => $new_target })->[0]){
				next;
			} else {
				last;
			}

	}

$target;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub redun_submit_check{

my $self = shift;
my $border_num = shift || 3;
my $border_hour = shift || 24;
my $basic = $self->basic_object();
my(@error,$count);

my $data_group = $self->my_submited_data_group();

	foreach my $data (@{$data_group}){
			if($data->{'create_time'} < time - 60*60*$border_hour){
				next;
			}
		$count++;
	}

	if($count > $border_num && !Mebius::alocal_judge()){
		push @error , "投稿数の上限を越えています。時間が経てば書き込めます。";
	}

@error;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub deleted_history_check{

my $self = shift;
my $border_day = shift || 7;
my $data_group = $self->my_submited_data_group();
my($most_before_time,@error);

	foreach my $data (@{$data_group}){
			if($data->{'deleted_flag'} && $data->{'deleted_flag'} < $most_before_time){
				$most_before_time = $data->{'deleted_flag'};
			}
	}

	if($most_before_time && $most_before_time > time - $border_day*24*60*60){
		push @error , "投稿が削除されたのでしばらく投稿できません。";
	}

@error;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_submited_data_group{

my $self = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my(%fetchrow);

	if($my_account->{'id'}){
		$fetchrow{'account'} = $my_account->{'id'};
	}

	if($my_cookie->{'char'}){
		$fetchrow{'cnumber'} = $my_cookie->{'char'};
	}


my $data_group = $self->fetchrow_main_table(\%fetchrow,{ OR => 1 });

$data_group;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_allow_edit_judge{

my $self = shift;
my $data = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($allow_flag);

	if($data->{'account'} && $my_account->{'id'} eq $data->{'account'}){
		$allow_flag = 1;
	}

$allow_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub redirect_to_self_page{

my $self = shift;
my $data = shift;

my $url = $self->data_to_url($data);
Mebius::redirect($url);


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_page_error{

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;
my $basic = $self->basic_object();
my($print);

	if(!$data){

			if(Mebius->common_admin_judge()){
				$print .= qq(<div class="message-red"><strong class="red">存在しないページ</strong></div>);
			} else {
				$basic->error("このページは存在しません。");
			}


	} elsif( $print = $self->data_to_deleted_error($data)){
		1;
	} 

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_deleted_error{

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;
my $basic = $self->basic_object();
my($print);

	if($data->{'deleted_flag'}){

			if(Mebius->common_admin_judge()){
				$print .= qq(<div class="message-red"><strong class="red">削除済みページ</strong></div>);
			} else {
				$basic->error("このページは削除済みです。");
			}

	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_ads_fillter{

my $self = shift;
my $data = shift;
my $fillter = new Mebius::Fillter;
my($flag);

	if($fillter->subject_fillter($data->{'subject'})){
		$flag = 1;
	} elsif($fillter->comment_fillter($data->{'text'})){
		$flag;
	}

$flag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub japanese_label{
0;
}
sub service_start_year{}
sub init{ {}; }
sub basic_object{}

1;


