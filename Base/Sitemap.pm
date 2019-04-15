
use strict;
package Mebius::Base::Sitemap;
use Mebius::Export;


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub query_to_sitemap_index_view{

my $self = shift;
my($param) = Mebius::query_single_param();
my $limited_package_name = $self->limited_package_name();

	if($param->{'tail'} eq "xml" && $param->{'mode'} =~ /^sitemap_index_${limited_package_name}$/){
		$self->sitemap_index_view();
	} else {
		0;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub query_to_sitemap_view{

my $self = shift;
my($param) = Mebius::query_single_param();
my $limited_package_name = $self->limited_package_name();

	if($param->{'tail'} eq "xml" && $param->{'mode'} =~ /^sitemap_${limited_package_name}_([0-9]+)$/){
		my $year = $1;
		$self->sitemap_view_per_year($year);
	} else {
		0;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sitemap_index_url{

my $self = shift;

my $basic = $self->basic_object();
my $site_url = $basic->absolute_site_url();
my $limited_package_name = $self->limited_package_name();

my $sitemap_index_url = "${site_url}sitemap_index_${limited_package_name}.xml";

$sitemap_index_url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sitemap_url{

my $self = shift;
my $year = shift;
my $init = $self->init();
my $basic = $self->basic_object();
my $limited_package_name = $self->limited_package_name();

my $site_url = $init->{'base_url'} || $basic->absolute_site_url();
my $url = "${site_url}sitemap_${limited_package_name}_${year}.xml";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sitemap_index_view{

my $self = shift;
my $basic = $self->basic_object();
my $service_start_year = shift || $self->init()->{'service_start_year'} || $basic->service_start_year() || die("Please setting service start year.");
my $sitemap = new Mebius::Sitemap;
my $times = new Mebius::Time;
my $this_year = $times->year(time);
my(@sitemap);

	for my $year ( $service_start_year ..  $this_year ) {
		push @sitemap , { url => $self->sitemap_url($year) } ;
	}


$sitemap->print_sitemap_index(\@sitemap);

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sitemap_view_per_year{

my $times = new Mebius::Time;
my $self = shift;
my $year = shift || (warn && return());
my $year_start_time = $times->year_to_localtime_start($year);
my $year_end_time = $times->year_to_localtime_end($year); 
my $data_group = shift || $self->fetchrow_main_table([ ["deleted_flag","<>",1] , ["create_time",">=",$year_start_time] , ["create_time","<=",$year_end_time]  ],{ Debug => 0 });
		my $mebius = new Mebius;
my $sitemap = new Mebius::Sitemap;
my(@sitemap);

my $this_year = $times->year(time);
	if($year > $this_year){
		$mebius->error("まだ訪れていない年度です。");
	} elsif($year <= 2000){
		$mebius->error("本サイトが作られる前の年度は指定できません。。");
	}

	foreach my $data ( @{$data_group} ) {

		my $title = $data->{'title'};

			if(Mebius::Fillter::heavy_fillter($title)){
				next;
			}

		my $url = $self->data_to_url($data);
		push @sitemap , { lastmod => $data->{'last_modified'} || $data->{'create_time'} , url => $url } ; 
	}

$sitemap->print_sitemap(\@sitemap);

exit;

}



1;