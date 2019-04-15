
use strict;
package Mebius::Base::View;


#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 月別の表示
#-----------------------------------------------------------
sub index_per_month_view{

my $self = shift;
my $year = shift || die;
my $month = shift || die;
my $times = new Mebius::Time;
my $basic = $self->basic_object();
my($line);

my $start_border_time = $times->year_and_month_to_localtime($year,$month);
my $end_border_time = $times->year_and_month_to_localtime_end($year,$month);

my $data_group = $self->fetchrow_main_table([ ["create_time",">=",$start_border_time] , ["create_time","<",$end_border_time] ] , { ORDER_BY => ["create_time DESC"] });

	if($data_group->[0] eq ""){
		$basic->error("ログがありません。");
	}

$line = $self->data_group_to_list($data_group);

my $title = "${year}年${month}月のログ";

$self->print_html($line,{ Title => $title , h1 => $title , BCL => [$title] });

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub index_per_month_url{

my $self = shift;
my $year = shift || return();
my $month = shift || return();
my $basic = $self->basic_object();

my $limited_package_name = $self->limited_package_name();
my $site_url = $basic->site_url();

my $url = "${site_url}?mode=index&type=${limited_package_name}&year=${year}&month=${month}";
my $url = "${site_url}index_${limited_package_name}_${year}_${month}";


$url

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_submited_list_view{

my $self = shift;
my $basic = $self->basic_object();
my($print);

	if($self->push_good_mode()){
		$self->my_submited_relation_view();
	}

my $page_title = "履歴";

$print .= $self->my_submited_core("list");


$basic->print_html($print,{ h1 => $page_title , Title => $page_title , BCL => [$page_title] });

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_submited_line_view{

my $self = shift;
my $basic = $self->basic_object();
my($print);

my $page_title = "履歴";

$print .= $self->my_submited_core("line");


$basic->print_html($print,{ h1 => $page_title , Title => $page_title , BCL => [$page_title] });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_submited_relation_view{

my $self = shift;
my $relation = $self->relation_object() || die;
my $basic = $self->basic_object();
my($print);

my $page_title = "いいね履歴";

my $data_group = $self->my_submited_data_group();
my @target = map { $_ = $_->{'relation_target'} } @{$data_group};

my $relation_data_group = $relation->fetchrow_main_table({ target => ["IN",\@target] });

$print .= $relation->data_group_to_list($relation_data_group);

$basic->print_html($print,{ h1 => $page_title , Title => $page_title , BCL => [$page_title] });

exit;



}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_submited_core{

my $self = shift;
my $type = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($print,$data_group);

	if( my $target = $my_account->{'id'} ){
		$data_group = $self->fetchrow_main_table({ account => $target });
	} elsif( my $target = $my_cookie->{'char'} ){
		$data_group = $self->fetchrow_main_table({ cnumber => $target });
	}

	if($type eq "list"){
		$print .= $self->data_group_to_list($data_group);
	} elsif($type eq "line"){
		$print .= $self->data_group_to_line($data_group);
	}

$print;

}


#-----------------------------------------------------------
# 月別の質問
#-----------------------------------------------------------
sub index_map_per_month_view{

my $self = shift;
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my $basic = $self->basic_object();
my $init = $self->init();
my($line);

my $page_title  = "月別ログ";

my $service_start_localtime = $init->{'service_start_localtime'} || $self->service_start_localtime() || die;

my $year_and_months = $times->foreach_year_and_month_with_localtime($service_start_localtime,time);
	foreach my $hash (@{$year_and_months}){
			if(my $url = $self->index_per_month_url($hash->{'year'},$hash->{'month'})){
				$line .= qq(<li>);
				$line .= $html->href($url,"$hash->{'year'}年$hash->{'month'}月");
				$line .= qq(</li>);
			}
	}

$line = qq(<ul>$line</ul>);

$basic->print_html($line,{ Title => $page_title , h1 => $page_title , BCL => [$page_title] });
exit;

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub error_to_message{

my $self = shift;
my $error = shift;
my($print);

	if(ref $error eq "ARRAY"){
		my(@list);
			foreach my $message (@{$error}){
				push @list , "<li>" . $message . "</li>";
			}
		my $message = join "" , @list;
		$print = qq(<div style="color:red;"><ul>$message</ul></div>);
	} elsif($error){
		$print = qq(<div style="color:red;">).($error).qq(</div>);
	}


$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub service_start_localtime{
"1410499729";
}



1;