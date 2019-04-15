
use strict;
package Mebius::Video::Chapter;
use Mebius::Video::Basic;
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
"chapter";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {

target => { PRIMARY => 1 }  ,
service_kind => { } ,
video_id => {  INDEX => 1  } , 
start_time => { int => 1 } , 
relation_target => { } , 
title => { } ,
text => { text => 1 } , 
number_per_post => { int => 1 } ,

};

$column;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic_object{
my $basic = new Mebius::Video;
$basic;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $data = shift || return();
my $basic = $self->basic_object();
my($param) = Mebius::query_single_param();
my $html = new Mebius::HTML;
my($print);

	if($data->{'title'}){
		my($url);
			if($param->{'chapter'} ne $data->{'target'}){
				$url = $self->data_to_url($data);
				$print .= $html->tag("h2","$data->{'title'}","",{ href => $url });
			} else {
				$print .= $html->tag("h2","$data->{'title'}");	
			}
	}
	if($data->{'text'}){
		$print .= $html->tag("div",$data->{'text'},{ style => "margin-bottom:1em;" });
	}

$print .= $basic->video_id_to_embed_tag($data->{'video_id'},$data->{'start_time'});
$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $video_data = shift;
my $basic = $self->basic_object();
my $post = new Mebius::Video::Post;
my($url);

my $post_url = $post->data_to_url({ target => $video_data->{'relation_target'} });
$url = $post_url . "&chapter=$video_data->{'target'}";

$url;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"video_chapter";
}

1;

