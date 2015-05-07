
use strict;
use Mebius::HTML;
use Mebius::SNS::URL;
use Mebius::URL;
package Mebius::View;
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
sub unread_mark{

my $self = shift;
my $unread_num = shift;
my $html = new Mebius::HTML;

	if($unread_num <= 0){
		return();
	}

my $unread_mark = $html->tag("strong",$unread_num,{ class => "new" });

$unread_mark;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub multi_list_table_cell_or_div{

my $self = shift;
my $subject_link = shift;
my $handle_link = shift || "投稿";
my $last_modified = shift;
my $data = shift;
my $use = shift;
my $unread_num = $data->{'unread_num'};
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my($my_use_device) = Mebius::my_use_device();
my($print,$delete_checkbox);

my $how_before = $times->how_before($last_modified);
my $html_class = $use->{'html_class'};

	if($use->{'control_id'}){
		$delete_checkbox = $html->input("checkbox",$use->{'control_id'},"delete");
	}

	if($my_use_device->{'smart_phone_flag'}){

		my $unread_mark = $self->unread_mark($unread_num);

		$print .= $html->start_tag("div",{ class => "$html_class margin-top" });

		$print .= $html->start_tag("div",{ class => "left" });
		$print .= $subject_link;
		$print .= $html->close_tag("div");

		$print .= $html->start_tag("div",{ class => "right" });
		$print .= $how_before . " ";
		$print .= $handle_link . " ";
		$print .= $unread_mark . " ";
		$print .= $delete_checkbox;
		$print .= $html->close_tag("div");

		$print .= $html->close_tag("div");

	} else {

		my $unread_mark = $self->unread_mark($unread_num);

		$print .= $html->start_tag("tr",{ class => $html_class });

		$print .= qq(<td>);
		$print .= $subject_link;
		$print .= qq(</td>);

		$print .= qq(<td>);
		$print .= "( " . $handle_link . " " . $unread_mark . " )" ;
		$print .= qq(</td>);

		$print .= qq(<td class="right">);
		$print .= $how_before;

			if(Mebius::alocal_judge()){
				$print .= " " . e($unread_num);
				#$print .= " " . e($data->{'last_response_num'});
				#$print .= " " . e($data->{'history_hash_data'}->{'last_read_response_num'});

			}

		$print .= " " . $delete_checkbox;
		$print .= qq(</td>);


		$print .= $html->close_tag("tr");;


	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub links{

my $self = shift;
$self->on_off_links(@_);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub on_off_links{

my $self = shift;
my $data_group = shift;
my $html = new Mebius::HTML;
my $url_object = new Mebius::URL;
my(@links);

	foreach my $data (@{$data_group}){

		my($url,$target);

		my $url_and_query = my $url_without_query = $url_object->request_url();
		$url_without_query =~ s/\?.+//g;

			if($data->{'url'} =~ m!^http|^/!){
				$url = $data->{'url'};
			} else {
				$url = $url_without_query . $data->{'url'};
			}
		
			if($data->{'blank'}){
				$target = "_blank";
			}


			if($ENV{'REQUEST_METHOD'} ne "POST" && ($url eq $url_and_query || $data->{'url'} eq $ENV{'REQUEST_URI'})){
				push @links , $html->span($data->{'title'},{ class => "linked" , target => $target });
			} else {
				push @links , $html->href($url,$data->{'title'});
			}
	}

my $print = join " " , @links;

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub navigation_line{
my $self = shift;
"";
}



1;
