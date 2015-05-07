 
use strict;
package Mebius::History;
use Mebius::Export;
use Mebius::Tags::Basic;
use base qw(Mebius::Base::DBI Mebius::Base::Data);

#-----------------------------------------------------------
# メインテーブル名
#-----------------------------------------------------------
sub main_table_name{
"history";
}

#-----------------------------------------------------------
# メインテーブルのカラム設定
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {

target => { PRIMARY => 1 } ,
status_target => { } ,

history_type => { } , 

content_typeA => { INDEX => 1 } ,
content_typeB => { INDEX => 1 } ,
content_typeC => { INDEX => 1 } ,

content_targetA => { INDEX => 1 } ,
content_targetB => { INDEX => 1 } ,
content_targetC => { INDEX => 1 } , 

content_title => { text => 1 } , 
content_create_time => { int => 1 } ,

access_target_type => { INDEX => 1 } ,
access_target => { INDEX => 1 } , 

regist_time => { int => 1 , INDEX => 1 } , 

response_target_history => { text => 1 } ,

last_handle => { other_names => { handle => 1 } } ,

last_response_target => { } ,
last_response_num => { int => 1 , INDEX => 1 } , 
last_read_time => { int => 1 } , 
last_read_response_num => { int => 1 } ,

hidden_flag => { int => 1 } ,
hidden_from_friends_flag => { int => 1 } ,
deleted_flag => { int => 1 } , 

create_time => { int => 1 } ,
last_update_time => { int => 1 } , 

};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hidden_from_friends_judge_on_param{

my $self = shift;
my($param) = Mebius::query_single_param();
my($flag);

	if($param->{'on_feed'} eq ""){
		$flag = 1;
	}

$flag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topics_max_view_line{

my $self = shift;
my $device = new Mebius::Device;
my($max);

	if($device->use_device_is_mobile()){
		$max = 3;
	} else {
		$max = 10;
	}

$max;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub use_history_objects{

my $self = shift;
my(%object);

$object{'question'} = new Mebius::Question;
$object{'bbs'} = new Mebius::BBS;
$object{'sns'} = new Mebius::SNS;
$object{'vine'} = new Mebius::Vine;
$object{'tags'} = new Mebius::Tags;

\%object;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_new_history{

my $self = shift;
my $where = shift || {};
my $relay_insert = shift || {};
my $use = shift;
my $crypt = new Mebius::Crypt;
my $status = new Mebius::Status;
my $device = new Mebius::Device;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($param) = Mebius::query_single_param();
my %insert = %{$relay_insert};
my(%where,$status_data);

	# If history type is Check
	if($use->{'Check'}){
		$insert{'history_type'} = "check";
		$insert{'history_type'} = "check";
		$insert{'regist_time'} ||= time;
	# If history type is Regist
	} else {
		$insert{'regist_time'} ||= time;
		$insert{'response_target_history'} ||= ["unshift","$insert{'last_response_target'} "]; #半角スペースが大事？
	}

$insert{'last_read_time'} ||= time;
$insert{'last_read_response_num'} ||= $insert{'last_response_num'};

	#if($param->{'tell_my_friends'} eq "0"){
	#	$insert{'hidden_from_friends_flag'} = 1;
	#} else {
	#	$insert{'hidden_from_friends_flag'} = 0;
	#}


%where = $device->add_hash_with_access_target($where);

	if($use->{'Check'}){
		$where{'history_type'} = "check";
	} else {
		$where{'history_type'} = ["IS","NULL"];
	}

	if( my $data = $self->fetchrow_main_table(\%where,{ Debug => 0 })->[0]){ # cnumber への対応を
		delete $insert{'submit_type'};
		$insert{'target'} = $data->{'target'};
		$self->update_main_table(\%insert,{ Debug => 0 });

	} else {
		$insert{'target'} = $crypt->char(30);
		$self->insert_main_table(\%insert);
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
#sub add_hash_with_account_or_cnumber{

#my $self = shift;
#my $relay_hash = shift || die;
#my($my_account) = Mebius::my_account();
#my($my_cookie) = Mebius::my_cookie_main();

#my %where = %{$relay_hash};

#	if( my $target = $my_account->{'id'}){
#		$where{'account'} = $target;
#	} elsif ( my $target = $my_cookie->{'char'}){
#		$where{'cnumber'} = $target;
#	} else {
#		return();
#	}


#%where;

#}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub border_time_for_topics{

my $self = shift;

my $border_time = time - 2*31*24*60*60;

$border_time;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub old_history_file_to_new_dbi{

my $self = shift;
my($init_directory) = Mebius::BaseInitDirectory();
my(@adjusted_data_group);
my $dbi = new Mebius::DBI;
my $bbs_thread = new Mebius::BBS::Thread;
my(@query,%thread_data_exists_on_dbi,$query,$i,$i_repair_for_debug);

require "${init_directory}part_history.pl";

my $history = main::get_reshistory("My-file GetReference Old-file-to-new-dbi");

	if(ref $history->{'res_line_data'} ne "ARRAY"){
		return();
	}

	# SQL クエリを作るためだけに、既存の投稿履歴を展開
	foreach my $data (@{$history->{'res_line_data'}}){

		push @query , $dbi->hash_to_where({ content_typeA => "bbs" , content_typeB => "thread" , content_targetA => $data->{'bbs_kind'} , content_targetB => $data->{'thread_number'} , access_target => $history->{'access_target'} , access_target_type => $history->{'access_target_type'} });

	}

	# 負荷軽減
	if(@query >= 1){
		$query = "WHERE " . join " OR " , @query;
	} else {
		return();
	}

my $history_data_data_group = $self->fetchrow_main_table($query,{ Debug => 0 });

	foreach my $data (@{$history_data_data_group}){
		$thread_data_exists_on_dbi{$data->{'content_targetA'}}{$data->{'content_targetB'}} = 1;
	}

	foreach my $data (@{$history->{'res_line_data'}}){


		my $data_utf8 = hash_to_utf8($data);
		$i++;

			if(!$thread_data_exists_on_dbi{$data->{'bbs_kind'}}{$data->{'thread_number'}}){
		
				my(%hash);


				my $thread = Mebius::BBS::thread_state($data_utf8->{'thread_number'},$data_utf8->{'bbs_kind'});
				my $thread_utf8 = hash_to_utf8($thread);

					if($thread->{'deleted_flag'}){
						next;
					}


				$i_repair_for_debug ++;

				my $my_last_resnumber = (split /\s/,$data->{'res_number_histories'})[0];

				$hash{'last_read_time'} = $data_utf8->{'last_read_thread_time'};
				$hash{'regist_time'} = $data_utf8->{'my_regist_time'};
				$hash{'last_read_response_num'} = $thread_utf8->{'res'} || $data_utf8->{'last_read_res_number'} || $my_last_resnumber;
				$hash{'content_typeA'} = "bbs";
				$hash{'content_typeB'} = "thread";
				$hash{'content_targetA'} = $data_utf8->{'bbs_kind'};
				$hash{'content_targetB'} = $data_utf8->{'thread_number'};
				$hash{'subject'} = $thread_utf8->{'subject'};
				$hash{'last_modified'} = $thread_utf8->{'lastrestime'};
				$hash{'last_handle'} = $thread_utf8->{'lasthandle'};
				$hash{'last_response_target'} = $hash{'last_response_num'} = $my_last_resnumber;
				$hash{'response_target_history'} = $data->{'res_number_histories'};

				my %hash_for_status = %hash;
				$hash_for_status{'last_response_target'} = $hash_for_status{'last_response_num'} = $thread_utf8->{'res'};

				$bbs_thread->create_common_history(\%hash,\%hash_for_status);

			}

	}


\@adjusted_data_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub new_system_topics{

my $self = shift;
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my $device = new Mebius::Device;
my $status = new Mebius::Status;
my($my_use_device) = Mebius::my_use_device();
my($print,@status_fetchrow,$status_data_group,@targets);

	if(time < 1383402886 + 6*30*24*60*60){
		$self->old_history_file_to_new_dbi();
	}

	if($status_data_group = $self->adjusted_status_data_group()){
		1;
	} else {
		return();
	}

my @sorted_data_group = @{$status_data_group};
@sorted_data_group = sort { $b->{'last_modified'} <=> $a->{'last_modified'} } @sorted_data_group;
@sorted_data_group = sort { $b->{'unread_num'} <=> $a->{'unread_num'} } @sorted_data_group;

my $head_line  = $self->topics_head_line(\@sorted_data_group) if(!$device->use_device_is_mobile());
my $history_line .= $self->topics_data_group_to_line(\@sorted_data_group);

$print .= $head_line;

$print .= qq(<div class="none" id="new_topics_hidden">);

$print .= $html->start_tag("div",{ id => "new_topics_headline" });

my $close_javascript = "javascript:vblock('new_topics_headline');vnone('new_topics_hidden');";

$print .= qq(<a href="$close_javascript" class="fold">);
$print .= qq(▼最近の更新);
$print .= qq(</a>&nbsp;);

$print .= $html->close_tag("div");

	if($my_use_device->{'smart_phone_flag'}){
		$print .= qq(<div class="topics_line">);
		$print .= qq($history_line);
		$print .= qq(</div>);
	} else {
		$print .= qq(<table style="margin-left:auto;" class="left topics_line">);
		$print .= qq($history_line);
		$print .= qq(</table>);
	}

$print .= qq(<div class="right">);
$print .= qq(<a href="$close_javascript" class="fold">);
$print .= qq(×閉じる);
$print .= qq(</a>&nbsp;);
$print .= qq(</div>);

$print .= qq(</div>);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_history_index{

my $self = shift;
my($status_data_group,$history_line);

	if($status_data_group = $self->adjusted_status_data_group(time - 365*24*60*60)){

		1;
	} else {
	
		return();
	}

my @sorted_data_group = sort { $b->{'history_hash_data'}->{'regist_time'} <=> $a->{'history_hash_data'}->{'regist_time'} } @{$status_data_group};

$history_line .= qq(<table class="width100">);
#$history_line .= qq(<tr><th></th><th></th><th></th></tr>);
$history_line .= $self->topics_data_group_to_index_line(\@sorted_data_group,{ Index => 1 });
$history_line .= qq(</table>);

$history_line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjusted_status_data_group{

my $self = shift;
my $border_time_for_regist_time = shift;
my $device = new Mebius::Device;
my $status = new Mebius::Status;
my($status_data_group,@adjusted_data_group);

my %where = $device->add_hash_with_access_target({});

	if(!%where){
		return();
	}

my $border_time = $border_time_for_regist_time || $self->border_time_for_topics();
$where{'regist_time'} = [">",$border_time];

my $adjusted_data_group = $self->fetchrow_main_table_with_status_data_group(\%where);

$adjusted_data_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub fetchrow_main_table_with_status_data_group{

my $self = shift;
my $where = shift;
my $use = shift;

my $history_data_hash = $self->fetchrow_on_hash_main_table($where,"status_target",$use);

	#if(Mebius::alocal_judge()){ Mebius::Debug::print_hash($where); }

my $status_data_group = $self->hash_data_group_to_status_data_group($history_data_hash);

my $adjusted_data_group = $self->adjust_status_data_group_with_history_hash_data($status_data_group,$history_data_hash);

$adjusted_data_group;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_status_data_group_with_history_hash_data{

my $self = shift;
my $status_data_group = shift;
my $history_hash_data = shift;
my $mebius = new Mebius;
my(@adjusted_data_group);

	foreach my $data (@{$status_data_group}){

		my $history_data = $data->{'history_hash_data'} = $history_hash_data->{$data->{'target'}};

			if($data->{'deleted_flag'} || $history_data->{'hidden_flag'}){
					$data->{'escape_flag'} = 1;
						if(!$mebius->common_admin_judge()){
							next;
						}
			}

		$data->{'unread_num'} = $data->{'last_response_num'} - $data->{'history_hash_data'}->{'last_read_response_num'};

		push @adjusted_data_group , $data;

	}

\@adjusted_data_group;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hash_data_group_to_status_data_group{

my $self = shift;
my $history_hash_data = shift;
my $border_time = shift;
my $status = new Mebius::Status;
my($status_data_group,%select);

my $status_targets = $self->hash_data_group_to_status_targets($history_hash_data) || return();

#my $add_query_for_status = " AND (last_modified >= $border_time) " if($border_time);
# OR => 1 , add_query => $add_query_for_status , 

	if(@{$status_targets} >= 1){
		$select{'last_modified'} = [">=",$border_time] if($border_time);
		$select{'target'} = ["IN",$status_targets];
		$status_data_group = $status->fetchrow_main_table(\%select,{ Debug => 0 });
	} else {
		return();
	}

$status_data_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hash_data_group_to_status_targets{

my $self = shift;
my $hash_data_group = shift;
my(@targets);

	foreach my $data ( values %{$hash_data_group} ){
		#push @status_fetchrow , ["target","=",$data->{'status_target'}];
		push @targets , $data->{'status_target'};
	}

\@targets;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topics_head_line{

my $self = shift;
my $data_group = shift;
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my($all_of_unread_num,$print,$newest_last_modified);

	foreach my $data (@{$data_group}){

		my $history_data = $data->{'history_hash_data'};
		$all_of_unread_num += $data->{'unread_num'} if($data->{'unread_num'} >= 1);

			if($data->{'last_response_num'} > $history_data->{'last_response_num'}){

					if(!$newest_last_modified || $data->{'last_modified'} > $newest_last_modified){
						$newest_last_modified = $data->{'last_modified'};
					}
			}
	}

$print .= $html->start_tag("div",{ id => "new_topics_headline" });
$print .= qq(<a href="javascript:vblock('new_topics_hidden');vnone('new_topics_headline');" class="fold">);
$print .= qq(▼最近の更新);
$print .= qq(</a>);

	#if($data_group->[0]->{'unread_num'} >= 1){
	#	$print .= $self->topics_data_to_line($data_group->[0]);
	#}

	if($all_of_unread_num >= 1){
		$print .= " | ";
		$print .= " " . $self->data_to_subject_link($data_group->[0]);
		$print .= " ( " . $self->data_to_handle_link($data_group->[0]) . " ) " ;
		$print .= " ". $html->strong($all_of_unread_num,{ class => "new" });
	}

	if($newest_last_modified){
		$print .= " ". $times->how_before($newest_last_modified);
	}

$print .= qq( | <a href="javascript:vblock('new_topics_hidden');vnone('new_topics_headline');" class="fold">);
$print .= qq(…続き);
$print .= qq(</a>&nbsp;);


$print .= $html->close_tag("div");

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topics_data_group_to_index_line{

my $self = shift;
my $data_group = shift;
my $use = shift;
my $operate = new Mebius::Operate;
my($my_use_device) = Mebius::my_use_device();
my($print,$hit);

my $max_view = 100;

	foreach my $data (@{$data_group}){

			if($hit >= $max_view){
				last;
			}

		my $overwrited_use = $operate->overwrite_hash($use,{ control_id => "history_control_$data->{'history_hash_data'}->{'target'}" });

			if( my $line = $self->topics_data_to_line($data,$overwrited_use)){
				$print .= $line;
			}

	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topics_data_group_to_line{

my $self = shift;
my $data_group = shift;
my($print,$hit);
my($my_use_device) = Mebius::my_use_device();
my($topics_line,$my_history_line,$hit_my_history,$hit_news);

my $max_view = $self->topics_max_view_line() || die; 

	foreach my $data (@{$data_group}){

		#if(Mebius::alocal_judge() && $data->{'history_hash_data'}->{'history_type'} eq "check"){ Mebius::Debug::print_hash($data->{'history_hash_data'}->{'history_type'}); }

		if($hit >= $max_view){

			last;
		}


		if( my $line = $self->topics_data_to_line($data)){

				if($data->{'last_response_num'} == $data->{'history_hash_data'}->{'last_response_num'}){
					$hit_my_history++;
					$my_history_line .= $line;
				} else {
					$hit_news++;
					$topics_line .= $line;
				}

			$hit++;
		}

	}

	if($my_use_device->{'smart_phone_flag'}){
		$print .= qq(<div class="topics_topics">更新</div>);
	} else {
		$print .= qq(<tr><td colspan="3" class="topics_topics">更新</td></tr>);
	}

$print .= $topics_line || qq(<tr><td colspan="3">更新はありません。</td></tr>);

	if($my_use_device->{'smart_phone_flag'}){
		$print .= qq(<div class="margin-top topics_res_history">履歴</div>);
	} else {
		$print .= qq(<tr><td colspan="3" class="topics_res_history">履歴</td></tr>);
	}
$print .= $my_history_line  || qq(<tr><td colspan="3">データがありません。</td></tr>);

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topics_data_to_line{

my $self = shift;
my $data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my $view = new Mebius::View;
my $text = new Mebius::Text;
my $mebius = new Mebius;
my($print);

my $history_data = $data->{'history_hash_data'};

my $target = $data->{'target'};
my $history_data = $data->{'history_hash_data'};
my $unread_num = $data->{'unread_num'};

my $handle_link = $self->data_to_handle_link($data);
my $subject_link = $self->data_to_subject_link($data);

	if($data->{'deleted_flag'}){
		$subject_link .= $html->tag("strong"," [本体削除]",{ class => "red" });
	}

	if ($history_data->{'hidden_flag'}){
		$subject_link .= $html->tag("span"," [履歴削除]",{ class => "red" });
	}

	if($use->{'Index'}){
		$print = $self->topics_data_to_index_line($data,$use);
	} else {
		$print = $view->multi_list_table_cell_or_div($subject_link,$handle_link,$data->{'last_modified'},$data,$use);
	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub topics_data_to_index_line{

my $self = shift;
my $data = shift;
my $history_data = $data->{'history_hash_data'};
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my($print);

$print .= qq(<tr>);

$print .= qq(<td>);
$print .= $self->data_to_subject_link($data);
$print .= qq(</td>);

$print .= qq(<td>);
$print .= $self->data_to_handle_link($data);
$print .= qq(</td>);

$print .= qq(<td class="right padding-right">);
$print .= $times->how_before($data->{'last_modified'}) ;
$print .= qq(</td>);

my $my_history_url_with_move = $self->multi_content_url_with_move($history_data,{ }) . "\n";
my $my_response_history_url_with_move = $self->multi_content_url_with_response_history($history_data);

$print .= qq(<td>);
$print .= $html->href($my_history_url_with_move,$history_data->{'last_handle'} || "自分");
$print .= qq(</td>);

$print .= qq(<td class="right">);
$print .= $times->how_before($history_data->{'regist_time'}) ;
$print .= qq(</td>);

my $regist_count = split(/\s/,$history_data->{'response_target_history'});
$print .= qq(<td class="right">);

	if( my $url = $my_response_history_url_with_move ){
		$print .= $html->href($url,"${regist_count}回");
	} else {
		$print .= $regist_count . "回";
	}

	if(!$history_data->{'hidden_flag'}){
		$print .= " " . $html->input("checkbox","history_control_$history_data->{'target'}","delete");
	}

$print .= qq(</td>);

$print .= qq(</tr>);


$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub query_to_control_history{

my $self = shift;
my($param) = Mebius::query_single_param();

	foreach my $name ( %{$param} ){

			if($name =~ /^history_control_([^_]+)$/){
				my $target = $1;
				my $control_type = $param->{$name};
				$self->control_history($target,$control_type);
			} else {
				0;
			}

	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub control_history{

my $self = shift;
my $target = shift;
my $control_type = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my(%update,$my_access_target);

my $data = $self->target_to_data($target);

$update{'target'} = $target;

	if($data->{'access_target_type'} eq "account"){
		$my_access_target = $my_account->{'id'};
	} elsif ($data->{'access_target_type'} eq "cnumber"){
		$my_access_target = $my_cookie->{'char'};
	} else {
		return();
	}

	if($my_access_target && $data->{'access_target'} eq $my_access_target){

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($my_access_target && $data->{'access_target'} eq $my_access_target)); }

		$update{'target'} = $target;

			if($control_type eq "delete"){
				$update{'hidden_flag'} = 1;
			} else {
				return();
			}

		$self->update_main_table(\%update);
	} else {

	}


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_handle_link{

my $self = shift;
my $data = shift;
my $text = new Mebius::Text;
my $html = new Mebius::HTML;

my $url_with_move = $self->multi_content_url_with_move($data,{ }) . "\n";

my $handle = $data->{'last_handle'};
$handle ||= "\@$data->{'last_account'}" if($data->{'last_account'});
$handle ||= "投稿";

my $handle_omited = $text->omit($handle,6);
my $handle_link = $html->href($url_with_move,$handle_omited);

$handle_link;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_subject_link{

my $self = shift;
my $data = shift;
my $text = new Mebius::Text;
my $html = new Mebius::HTML;

my $subject_url = $self->multi_content_url($data,{ }) . "\n";
my $omited_subject = $text->omit_character($data->{'subject'},20);
my $subject_link = $html->href($subject_url,$omited_subject);

$subject_link;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub multi_content_url_core{

my $self = shift;
my $data = shift;
my $relay_use = shift;
my $use = shift;
my $objects = $self->use_history_objects();
my($link);

	foreach my $name ( keys %{$objects} ){

		my $object = $objects->{$name};

			#if(!$object->content_type_is_on_this_package($data)){ next; }

			if($use->{'Move'} && ($link = $object->multi_data_to_each_url_with_move($data,$use)) ){
				last;
			} elsif($use->{'History'} && ($link = $object->multi_data_to_each_url_with_response_history($data,$use)) ){
				last;
			} elsif($link = $object->multi_data_to_each_url($data,$use)) {
				last;
			} else {
				0;
			}


	}


$link;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub multi_content_url{

my $self = shift;
my $data = shift;
my $use = shift;

$self->multi_content_url_core($data,$use);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub multi_content_url_with_move{

my $self = shift;
my $data = shift;
my $use = shift;

$self->multi_content_url_core($data,$use,{ Move => 1 });

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub multi_content_url_with_response_history{

my $self = shift;
my $data = shift;
my $use = shift;

$self->multi_content_url_core($data,$use,{ History => 1 });

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
#sub multi_content_link{

#my $self = shift;
#my $data = shift;
#my $use = shift;
#my $question = new Mebius::Question;
#my $link;

#	if( $link = $question->multi_data_to_each_link($data,$use)){

#	} else {
#		return();
#	}

#$link;

#}

#-----------------------------------------------------------
# トピックスをソート / 整形 ( 旧？ )
#-----------------------------------------------------------
sub topics{

# 宣言
my $self = shift;
my($maxview_topics,@topics) = @_;
my($my_account) = Mebius::my_account();
my($my_use_device) = Mebius::my_use_device();
my($basic_init) = Mebius::basic_init();
my($line,$i,$hidden_line,$rireki_line,$hidden_count,$hit,$return_line,$border_time,$rireki_count,$view_count,$check_line);
my($check_count,$all_other_count,$how_before_most_new,$max_view_line_per_type,$already_read_top_flag,%most_new_topics);

	# リターン
	if(!@topics){ return; }

	# １タイプあたりの最大表示行数
	if($my_use_device->{'wide_flag'}){
		$max_view_line_per_type = 10;
	}
	else{
		$max_view_line_per_type = 5;
	}

	# ～秒前までの更新まで表示する
	if($my_use_device->{'type'} eq "Mobile"){ $border_time = 1*3*60*60; }	# ～時間
	else{ $border_time = 7*24*60*60; }		# ～日

# トピックスを新着順にソート
@topics = sort { (split(/<>/,$b))[2] <=> (split(/<>/,$a))[2] } @topics;

	# トピックスを展開
	foreach(@topics){

		# 局所化
		my($buffer_line,$tr_background_color2);
	
		# 行を分解
		chomp;

		my %data = %$_;

			if(Mebius::Fillter::heavy_fillter($data{'subject_dbi'})){ next; }

		# ラウンドカウンタ
		$i++;


			# 一定時間が過ぎていたり、自分のレスであればパス (携帯版)
			if($my_use_device->{'type'} eq "Mobile"){
					if($hit >= 1){ last; }
					if(time > $data{'last_res_time'} + $border_time){ next; }
					if($data{'my_regist_time'} >= $data{'last_res_time'}){ next; }
			}

		# ヒットカウンタ
		$hit++;

		# レスされてからの経過時間
		my($how_before) = Mebius::second_to_howlong({ ColorView => 1 , TopUnit => 1 , HowBefore => 1 } ,time - $data{'last_res_time'}) if($data{'last_res_time'});

			my($thread_url) = Mebius::BBS::thread_url($data{'thread_number'},$data{'bbs_kind'});
			my($thread_url_move) = Mebius::BBS::thread_url_move($data{'thread_number'},$data{'bbs_kind'},$data{'last_res_number'});
			my $thread_link_move = q(<a href=").e($thread_url_move).q(">).e($data{'last_handle_dbi'}).q(</a>);
			my $thread_link = q(<a href=").e($thread_url).q(">).e($data{'subject_dbi'}).q(</a>);

			# 携帯版
			if($my_use_device->{'type'} eq "Mobile"){
				$buffer_line .= $thread_link;
				$buffer_line .= qq( \( $thread_link_move \) );

			# PC版			
			}	else{

					# 既読/未読
					if($data{'already_read_flag'}){
						$buffer_line .= qq(<tr class="alread">);
					} else {
						$buffer_line .= qq(<tr>); 
					}

				$buffer_line .= qq(<td>);
				$buffer_line .= $thread_link;
				$buffer_line .= qq(</td>);

				$buffer_line .= qq(<td>);
					if($my_use_device->{'wide_flag'}){ $buffer_line .= qq( \( ); }
				$buffer_line .= $thread_link_move;
					if($data{'unread_res_num'}){
						$buffer_line .= qq( <strong class="new">).e($data{'unread_res_num'}).q(</strong>);
					}
					if($my_use_device->{'wide_flag'}){ $buffer_line .= qq( \) ); }
				$buffer_line .= qq(</td>);


				$buffer_line .= qq(<td class="right">$how_before);
				$buffer_line .= qq(</td>);
				$buffer_line .= qq(</tr>\n);
			}

			# ▼【最近のレス】として Javascript で展開せずとも表示する１行 ( ～周目以内 )
			if($view_count < 1 && $data{'last_res_time'} > $data{'my_regist_time'} && !$data{'already_read_flag'}){

						$line .= $thread_link;
						$line .= qq( \( );
						$line .= $thread_link_move;
							if($data{'unread_res_num'}){
								$line .= qq( <strong class="new">).e($data{'unread_res_num'}).q(</strong>);
							}
						$line .= qq( \));
						$line .= qq( $how_before);

					if(!$how_before_most_new){ $how_before_most_new = $how_before; }
				$view_count++;
			}


			# 【最近のレス】として隠す部分 - Javascriptで展開 
			if(time <= $data{'last_res_time'} + $border_time && $data{'my_regist_time'} < $data{'last_res_time'} && !$most_new_topics{$data{'bbs_kind'}}{$data{'thread_number'}}){
				$hidden_line .= $buffer_line;
				$hidden_count++;
				$most_new_topics{$data{'bbs_kind'}}{$data{'thread_number'}} = 1;
			
			# 【その他の履歴】として隠す部分 - Javascriptで隠す
			#if(time > $data{'last_res_time'} + $border_time || $data{'my_regist_time'} >= $data{'last_res_time'}){
			} else {


				# いいね！
					if($data{'history_type'} =~ /^(crap|check)$/){
							if($check_count <= $max_view_line_per_type){ $check_line .= $buffer_line; }
						$check_count++;
					}
					# 投稿履歴
					else{
							if($rireki_count <= $max_view_line_per_type){ $rireki_line .= $buffer_line; }
						$rireki_count++;
					}
			}

	}

	# 整形
	if($line || $hidden_line || $rireki_line || $check_line){

			# 共通の整形
			if(!$hidden_count){ $hidden_count = 0; }
			if(!$rireki_count){ $rireki_count = 0; }
			if(!$check_count){ $check_count = 0; }
		$all_other_count = $rireki_count + $check_count;

			# 携帯版では「最近のレス」の１行だけを返す
			if($my_use_device->{'type'} eq "Mobile"){
				$return_line = $line;
			}

			# デスクトップ版での整形
			else{

				# 局所化
				my($onclick_open_wide,$onclick_close_wide,$class);

					# 既読
					if($already_read_top_flag){
						#$class .= qq( alread);
					}

					# スマフォ版
					if($my_use_device->{'smart_flag'}){
						$return_line .= qq(<div id="bbs_topics"$onclick_open_wide>);
						$return_line .= qq(<span class="$class">);
							if($how_before_most_new){ $return_line .= qq($how_before_most_new ); }
						$return_line .= qq(<a href="javascript:vblock('topics_hidden');vnone('bbs_topics');" class="fold">);
						$return_line .= qq(▼最近のレス(${hidden_count}));
						$return_line .= qq(</a>);
						#$return_line .= qq( | <a href="$basic_init->{'main_url'}?mode=my#RESHISTORY" onclick="vblock('topics_hidden');vnone('bbs_topics');return false;" class="fold">…続き</a>);
						$return_line .= qq(</span>\n);
						$return_line .= qq(</div>\n);

					# デスクトップ版
					} else {
						$return_line .= qq(<div id="bbs_topics"$onclick_open_wide>);
						$return_line .= qq(<span class="$class">);
						$return_line .= qq(<a href="$basic_init->{'main_url'}?mode=my#RESHISTORY" onclick="vblock('topics_hidden');vnone('bbs_topics');return false;" class="fold">▼最近のレス(${hidden_count}件)</a>);
							if($line){ $return_line .= qq( | $line); }
						$return_line .= qq( | <a href="$basic_init->{'main_url'}?mode=my#RESHISTORY" onclick="vblock('topics_hidden');vnone('bbs_topics');return false;" class="fold">…続き</a>);
						$return_line .= qq(</span>\n);
											$return_line .= qq(</div>\n);
					}


					# ●隠れ領域全体の開始 ( IE対策としてテーブルをブロックで囲み、ブロックで表示/非表示を切り替える )

				$return_line .= qq(<div class="display-none" id="topics_hidden"$onclick_close_wide>);

				# 
				# テーブル始まり
				$return_line .= qq(<table class="topics_line">);

				$return_line .= qq(<tr><th colspan="4" class="topics_topics">);
				$return_line .= qq(<div class="fleft"><a href="javascript:vnone('topics_hidden');vblock('bbs_topics');" class="fold">▼最近のレス(${hidden_count}件)</a></div>);
				$return_line .= qq(<div class="fright"> <a href="javascript:vnone('topics_hidden');vblock('bbs_topics');" class="fold">…閉じる</a></div>);
				$return_line .= qq(</th></tr>\n);

					# ▼最近のレス ( 隠れ領域分 )
					if($hidden_line eq ""){
						$return_line .= qq(<tr><td colspan="4">最近のレスはありません。</td></tr>);
					} else {
						#$return_line .= qq(<table class="topics_line">);
						$return_line .= qq($hidden_line);
						#$return_line .= qq(</table>\n);
					}

					# ▼他の投稿履歴
					if($rireki_line eq ""){ $rireki_line = qq(<tr><td colspan="4">履歴はありません。</td></tr>\n); }
					if($rireki_line){
						#$return_line .= qq(<table class="topics_line">);
						$return_line .= qq(<tr><th colspan="4" class="topics_res_history">);
						$return_line .= qq(▼履歴 (${rireki_count}件)\n);
						$return_line .= qq(</th></tr>\n);
						$return_line .= qq($rireki_line\n);
						#$return_line .= qq(</table>\n);
					}

					# ▼チェック履歴
					if($check_line eq ""){ $check_line = qq(<tr><td colspan="4">履歴はありません。</td></tr>\n); }
					if($check_line){
						$return_line .= qq(<tr><th colspan="4" class="no-padding topics_thread_check">);
						$return_line .= qq(▼チェック (${check_count}件)\n);
						$return_line .= qq(</th></tr>\n);
						$return_line .= qq($check_line\n);
					}

				# オプションリンク
				$return_line .= qq( <tr><td colspan="4" class="right">);
				$return_line .= qq( <a href="$basic_init->{'main_url'}?mode=my#RESHISTORY">…もっと詳しく</a>);
					if($my_use_device->{'wide_flag'}){
						$return_line .= qq( | <a href="javascript:vnone('topics_hidden');vblock('bbs_topics');" class="fold">…閉じる</a>\n);
					} else {
						$return_line .= qq( | <a href="#bbs_topics" onclick="vnone('topics_hidden');vblock('bbs_topics');" class="fold">…閉じる</a>\n);
					}
				$return_line .= qq( </td></tr>\n);

				# テーブル終わり
				$return_line .= qq(</table>\n);

				# 隠れ領域全体の終了
				$return_line .= qq(</div>\n);

			}


	}

$return_line .= $self->new_system_topics();


}




#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}



#-----------------------------------------------------------
# 自分の履歴を全て更新する
#-----------------------------------------------------------
sub renew_my_history_all{

my $self = shift;
my $renew = shift;

Mebius::HistoryAll("RENEW",undef,undef,undef,undef,undef,%{$renew});

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tell_my_friends_input_tag{

my($my_account) = Mebius::my_account();
my $self = shift;
my $html = new Mebius::HTML;
my($print);

	if($my_account->{'login_flag'}){
		$print .= $html->input("checkbox","on_feed","1",{ default_checked => 1 , text => "フィード" });
		#$print .= $html->input("radio","tell_my_friends","0",{ text => "教えない" });
	}

$print;

}


package Mebius;
use Mebius::Export;

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


#-----------------------------------------------------------
# 投稿履歴を取得 ( 中間処理 )
#-----------------------------------------------------------
sub history{

# 宣言
my($use,$file) = @_;
my($relay_type,@history);
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_history.pl";

	# 必須値
	if($file eq ""){ die("Perl Die!  File value is empty.") }

# リレータイプ
$relay_type = $use->{'Type'};

	# クエリに応じて開く投稿履歴ファイルの種類を定義
	if(exists $use->{'FileTypeQuery'}){

			# ファイル定義
			if($use->{'FileTypeQuery'} eq "host"){ $relay_type .= qq( HOST); }
			elsif($use->{'FileTypeQuery'} eq "number"){ $relay_type .= qq( CNUMBER); }
			elsif($use->{'FileTypeQuery'} eq "account"){ $relay_type .= qq( ACCOUNT); }
			elsif($use->{'FileTypeQuery'} eq "isp"){ $relay_type .= qq( ISP); }
			elsif($use->{'FileTypeQuery'} eq "trip"){ $relay_type .= qq( TRIP); }
			elsif($use->{'FileTypeQuery'} eq "id"){ $relay_type .= qq( ENCID); }
			elsif($use->{'FileTypeQuery'} eq "handle"){ $relay_type .= qq( HANDLE); }
			elsif($use->{'FileTypeQuery'} eq "agent"){ $relay_type .= qq( KACCESS_ONE); }
			else{ main::error("Please select history type."); }

			# 投稿履歴を取得 / もしくは処理を実行
			(@history) = main::get_reshistory("$relay_type Debug",$file);

	}
	
	#if(exists $use->{'FileTypeQuery'} && $get_history_from_query)

@history;

}

#-----------------------------------------------------------
# 自分の履歴を取得
#-----------------------------------------------------------
sub my_history{

# Near State （呼び出し） 2.10
my $StateName1 = "my_history";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# 取り込み処理
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_history.pl";

# 履歴を取得
my(%myhistory) = main::get_reshistory("TOPDATA My-file");

	# Near State （保存） 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,\%myhistory); }

return(\%myhistory);

}

#-----------------------------------------------------------
# 自分の履歴を取得 ( ホストを含める )
#-----------------------------------------------------------
sub my_history_include_host{

my(%self);

# Near State （呼び出し） 2.10
my $StateName1 = "my_history_include_host";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# 取り込み処理
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_history.pl";

# ホストを含まない投稿履歴を酒盗
my($my_history_normal) = Mebius::my_history();

	# ホスト以外で履歴が取得できている場合は、その値を代入 ( ファイルを開く回数を減らして負荷軽減 )
	if($my_history_normal->{'file_type'}){
		%self = %$my_history_normal;
	}
	# 履歴を取得
	else{
		(%self) = main::get_reshistory("TOPDATA My-file Allow-host");
	}

	# Near State （保存） 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,\%self); }

return(\%self);


}



1;