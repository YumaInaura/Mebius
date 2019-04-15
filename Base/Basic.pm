
use strict;
use Mebius::PageBack;
use Mebius::Text;
use Mebius::HTML;
use Mebius::Report;
package Mebius::Base::Basic;

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
sub param_to_report_data_all_objects{

my $self = shift;
my $key = shift || return();
my($report_data);

my @objects_for_report = $self->objects_for_report();

	foreach my $object ( @objects_for_report ){
			if($report_data = $object->param_to_report_data($key)){
				last;
			}
	}

$report_data;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_all_tables{

my $self = shift;
my @objects = $self->database_objects();

	foreach my $object (@objects){
		$object->create_main_table();
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub refresh_all_tables{

my $self = shift;
my @objects = $self->database_objects();
	
	foreach my $object (@objects){
		$object->refresh_main_table();
	}

}
sub database_objects{}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub access_judge{

my $self = shift;
my $main_limited_package_name = $self->main_limited_package_name();
my($flag);

	if($ENV{'SCRIPT_NAME'} =~ m!/${main_limited_package_name}\.cgi!){
		$flag = 1;
	} else {
		0;
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_to_some_report_data{

my $self = shift;
my $key = shift;
my @objects = $self->objects_for_report();
my($report_data,$i);

	foreach my $object ( @objects ){

		$i++;

			if( $report_data = $object->param_to_report_data($key)){
				last;
			}

	}

$report_data;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub multi_data_to_each_url{

my $self = shift;
my $data = shift;
my $relay_use = shift;
my $use = shift;
my $link;
my $all_objects = $self->limited_all_objects();
my $main_limited_package_name = $self->main_limited_package_name();

	if($data->{'content_typeA'} ne $main_limited_package_name){
		return();
	}

	foreach my $object_name ( keys %{$all_objects} ){

		my $object = $all_objects->{$object_name};

			if(!$object->content_type_is_on_this_package($data)){
				next;
			}

		my $adjusted_data = $object->content_target_to_normal_data($data);

			if($use->{'Move'} || $use->{'WithMove'}){

					if( $link = $object->data_to_url_with_move($adjusted_data,$relay_use)){
						last;
					} else {
						0;
					}

			} elsif($use->{'History'}){

					if( $link = $object->data_to_url_with_response_history($adjusted_data,$relay_use)){

						last;
					} else {
						0;
					}


			} else {

					if( $link = $object->data_to_url($adjusted_data,$relay_use)){
						last;
					} else {
						0;
					}

			}
	}


$link;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub multi_data_to_each_url_with_move{

my $self = shift;
my $data = shift;
my $relay_use = shift;

$self->multi_data_to_each_url($data,$relay_use,{ WithMove => 1 });

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub multi_data_to_each_url_with_response_history{

my $self = shift;
my $data = shift;
my $relay_use = shift;

$self->multi_data_to_each_url($data,$relay_use,{ History => 1 });

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_html{

my $self = shift;
my $html_body = shift;
my $use = shift;
my $init = $self->init();
my $template = new Mebius::Template;
my $html = new Mebius::HTML;
my($my_use_device) = Mebius::my_use_device();
my($print,%overwrite_use,$h1,$navigation_links);

my $adjusted_use = $self->adjust_header_use($use,$init);

	if( my $navigation_links = $self->navigation_links_top()){
		$print .= $navigation_links;
	}

	if($use->{'h1'}){
		$h1 = $html->tag("h1",$use->{'h1'},{ Debug => 0 });
	}

	#if( my $navigation_links = $self->navigation_links_under_title()){
	#	$print .= $navigation_links;
	#}


	if( my $side_bar_line = $self->html_body_side_bar()){

			if($my_use_device->{'smart_phone_flag'}){
				$print .= $html->start_tag("div");
			} else{
				$print .= $html->start_tag("div",{ class => "float-left" , style => "width:70%;" });
			}

		$print .= $h1;
		$print .= $html_body;
		$print .= $html->close_tag("div");

			if($my_use_device->{'smart_phone_flag'}){
				$print .= $html->start_tag("div");
			} else{
				$print .= $html->start_tag("div",{ class => "float-right" , style => "width:28%;margin-left:1%;" });
			}

		$print .= $side_bar_line;
		$print .= $html->close_tag("div");
		$print .= $html->tag("div","",{ class => "clear" });
	} else {
		$print .= $h1;
		$print .= $html_body;
	}

	if( my $navigation_links = $self->navigation_links_top()){
		$print .= qq(<div style="margin-top:1em;">);
		$print .= $navigation_links;
		$print .= qq(</div>);
	}


my %final_use = (%{$adjusted_use},%overwrite_use);

$self->print_html_core(\%final_use,$print);

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_html_core{

my $self = shift;
Mebius::Template::gzip_and_print_all(@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub html_body_side_bar{ }


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_header_use{

my $self = shift;
my $use = shift;
my $init = shift;
my $html = new Mebius::HTML;
my $text = new Mebius::Text;
my($print,@BCL);

my $site_title = $init->{'title'} || $init->{'site_title'} || $self->site_title();
my $bcl_title = $init->{'short_title'} || $site_title || $self->site_title();
my $site_url = $init->{'base_url'} || $self->site_url();
my $site_kind = $self->site_kind();

	if($use->{'ContentsTopPage'} || $ENV{'REQUEST_URI'} eq "/" || (Mebius::alocal_judge() && $ENV{'REQUEST_URI'} eq "/-$site_kind/")){
		push @BCL , $bcl_title;
	} else {
		push @BCL , { url => $site_url , title => $bcl_title } ;
	}

push @BCL , @{$use->{'BCL'}} if(ref $use->{'BCL'} eq "ARRAY");
my $relay_use = Mebius::Operate->overwrite_hash($use,{ source => "utf8" , BCL => \@BCL });

	if($relay_use->{'Title'}){
		$relay_use->{'Title'} = $relay_use->{'Title'} . qq( | $site_title);
	} else {
		$relay_use->{'Title'} = $site_title;
	}


	if( my $search_domain = $self->site_domain() ){
		$relay_use->{'search_domain'} = $search_domain;
	}

	if( my $site_title = $self->site_title() ){
		$relay_use->{'site_title'} = $site_title;
	}


$relay_use;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub query_to_control_and_redirect{

my $self = shift;
my $page_back = new Mebius::PageBack;

$self->query_to_control();

$page_back->redirect() || $self->print_html("実行しました。");

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub top_page_link{

my $self = shift;
my $init = $self->init();
my $html = new Mebius::HTML;

my $url = $init->{'base_url'} || $init->{'site_url'} || $self->site_url() || return();
my $title = $init->{'short_title'} || $init->{'title'} || $init->{'site_title'} || $self->site_title() || return();

my $link = $html->href($url,$title);

$link;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_kind{

my $self = shift;
my $site_domain = $self->site_domain() || return();
my($site_kind);

	if($site_domain =~ /^([a-zA-Z0-9_\-]+)/){
		$site_kind = $1;
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub relative_site_url{

my $self = shift;
my $url = $self->site_url({ Relative => 1 });

$url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub absolute_site_url{

my $self = shift;
my $url = $self->site_url({ Absolute => 1 });

$url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_url{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($site_url);

my $site_domain = $self->site_domain() || return();
my $site_kind = $self->site_kind() || return();

	if(Mebius::alocal_judge()){
			if($use->{'Relative'} || ($ENV{'HTTP_HOST'} eq $site_domain && !$use->{'Absolute'})){
				$site_url = "/-$site_kind/";
			} else {
				$site_url = "http://$ENV{'SERVER_ADDR'}/-$site_kind/";
			}

	} else {
			if($use->{'Relative'} || ($ENV{'HTTP_HOST'} eq $site_domain && !$use->{'Absolute'})){
				$site_url = "/";
			} else {
				$site_url = "http://$site_domain/";
			}
	}

$site_url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub navigation_links_top{

my $self = shift;
my $link_group = $self->navigation_link_group() || return();
my $html = new Mebius::HTML;
my $view = new Mebius::View;
my($print);

$print .= $html->start_tag("div",{ style => "margin-bottom:1.75em;padding:0.5em 1em;background:#eee;border:1px solid #999;word-spacing:0.5em;" });
$print .= $view->on_off_links($link_group);
$print .= $html->close_tag("div");

$print;

}

#-----------------------------------------------------------
# エラー
#-----------------------------------------------------------
sub error{

my $self = shift;
Mebius->error(@_);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_line{

my $self = shift;
my $report = new Mebius::Report;
my $html = new Mebius::HTML;
my($print,%report);

my $main_limited_package_name = $self->main_limited_package_name();
my $site_title = $self->site_title();

my @objects_for_report = $self->objects_for_report();

$print .= $html->tag("h2",$site_title);

	foreach my $object ( @objects_for_report ){

		my $limited_package_name = $object->limited_package_name();
		my $report_data_group = $report->fetchrow_main_table({ content_type => $main_limited_package_name , targetA => $limited_package_name , answer_time => "0" });

			foreach my $report_data (@{$report_data_group}){
					push @{$report{$report_data->{'target_unique_number'}}} , $report_data;
			}

			foreach my $target ( keys %report ){

					my $reports = $report{$target};
					my $data = $object->target_to_data($target);
					my $line = $object->data_to_line($data,{ view_report_mode => 1 }); 
					$print .= $report->place_by_the_side($line,$reports,{ Thread => 1 , access_data => $data });
			}
	}

$print;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub control{

my $self = shift;

my @objects_for_report = $self->objects_for_report();

	foreach my $object ( @objects_for_report ){
		$object->query_to_control();
	}

}
sub objects_for_report{}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub robots_text_view{

my $self = shift;
my @objects = @_;

print "Content-type:text/css\n\n";

	foreach my $object (@objects){
			if( my $url = $object->sitemap_index_url()){
				print "Sitemap: " . $url . "\n";
			}
	}


exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_title{}
sub site_domain{}
sub navigation_link_group{}
sub init{}



1;
