
use strict;
package Mebius::Video;
use Mebius::Video::Post;
use Mebius::Video::Video;
use Mebius::Video::Chapter;
use Mebius::Video::PushGoodPost;
use Mebius::Video::Tag;
use Mebius::Video::TagList;

use Mebius::Video::Tag;
use Mebius::Getpage;
use base qw(Mebius::Base::Basic);
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
sub database_objects{

my $self = shift;
my(@object);

push @object , new Mebius::Video::Post;
push @object , new Mebius::Video::Video;
push @object , new Mebius::Video::Tag;
push @object , new Mebius::Video::TagList;
push @object , new Mebius::Video::Chapter;
push @object , new Mebius::Video::PushGoodPost;

@object;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_limited_package_name{
"video";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my($print);
my $post = new Mebius::Video::Post;
my $tag = new Mebius::Video::Tag;
my $tag_list = new Mebius::Video::TagList;
my $push_good_post = new Mebius::Video::PushGoodPost;
my $report = new Mebius::Report;

my($param) = Mebius::query_single_param();

	# 違反報告
	if($param->{'mode'} eq "robots" && $param->{'tail'} eq "txt"){
		$self->robots_text_view($post);
	}elsif($report->report_mode_junction()){
		1;
	} elsif($push_good_post->query_to_control()){
		1;
	} elsif($post->query_to_junction()){
		1;
	} elsif($tag->query_to_junction()){
		1;
	} elsif($push_good_post->query_to_junction()){
		1;
	} elsif($tag_list->query_to_junction()){
		1;
	} elsif($param->{'mode'} eq "create"){
		$post->junction();
	} elsif($param->{'v'}){
		$post->self_view();
	} elsif($param->{'tag'}){
		$tag->self_view();
	} elsif($param->{'mode'} eq "") {
		$self->top_page_view();
	} else {
		$self->error("ページが存在しません。");
	}

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub top_page_view{

my $self = shift;
my $post = new Mebius::Video::Post;
my $html = new Mebius::HTML;
my $tag_list = new Mebius::Video::TagList;
my $tag = new Mebius::Video::Tag;
my($print);

my $site_title  = $self->site_title();

$print .= $html->tag("h2","新着","",{ href => "recently_list_post" });
$print .= $post->recently_list({ max_view => 10 });

$self->print_html($print,{ h1 => $site_title });

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub video_url_to_embed_tag{

my $self = shift;
my $video_url = shift || return();

my $video_id = $self->video_url_to_video_id($video_url);
my $start_time = $self->video_url_to_start_time($video_url);
my $embed_tag = $self->video_id_to_embed_tag($video_id,$start_time);

$video_id;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub video_url_to_video_id{

my $self = shift;
my $video_url = shift || return();
my $video_url_format = $self->video_url_format();
my $video_id;

	if($video_url =~ m!^$video_url_format!){
			$video_id = $1;	
	}
$video_id;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub video_url_to_start_time{

my $self = shift;
my $video_url = shift || return();
my $video_url_format = $self->video_url_format();
my($start_time);

	if($video_url =~ m!t=([0-9]+)m([0-9]+)s!){
		my $minute = $1;
		my $second = $2;
		$start_time = $minute*60+$second;
	}


$start_time;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub video_id_to_video_url{

my $self = shift;
my $video_id = shift || return();
my $start_time = shift;
my($video_url);


$video_url = "https://www.youtube.com/watch?v=".e($video_id);

	if(my $minute_with_second = $self->start_time_to_minute_with_second_parameter($start_time)){
		$video_url .= e($minute_with_second);
	}

$video_url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub start_time_to_minute_with_second_parameter{

my $self = shift;
my $start_time = shift || return();

	if($start_time !~ /^[0-9]+$/){
		return();
	}

my $minute = int($start_time/60);
my $second = $start_time % 60;

"&t=${minute}m${second}s";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub video_id_to_embed_tag{

my $self = shift;
my $video_id = shift || return();
my $start_time = shift;
my($parameter);

	if($start_time && $start_time =~ /^([0-9]+)$/){
		$parameter = "?start=$start_time";
	} elsif($start_time) {
		die;
	}

my $embed_tag = qq(<iframe width="560" height="315" src="//www.youtube.com/embed/).e($video_id).e($parameter).qq(" frameborder="0" allowfullscreen></iframe>\n);

$embed_tag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub navigation_link_group{

my $self = shift;
my $site_url = $self->site_url();

my @links = (
{ url => "${site_url}" , title => "トップ" },
{ url => "${site_url}recently_list_post" , title => "新着" },
{ url => "${site_url}recently_list_tag" , title => "タグ" },
{ url => "${site_url}index_map_month_post" , title => "ログ" },
{ url => "${site_url}my_list_post" , title => "履歴" },
{ url => "${site_url}my_list_pushgoodpost" , title => "いいね" },
{ url => "${site_url}create" , title => "新規登録" },
);


\@links;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub video_url_format{

my $self = shift;
my $url_format = "https?://(?:www\\.)?(?:m\\.)?(?:youtube\\.com|youtu\\.be)/(?:watch\\?v=)?([a-zA-Z0-9_\-]+)(?:(?:\\?|&)t=([0-9]+m[0-9]+s))?";
$url_format;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub objects_for_report{

my $self = shift;
my(@array);

push @array , new Mebius::Video::Post;
push @array , new Mebius::Video::TagList;

@array;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub video_id_to_api_url{

my $self = shift;
my $youtube_id = shift || return();
my($url);

my $api_key = $self->youtube_api_key();
$url = "https://www.googleapis.com/youtube/v3/videos?id=$youtube_id&key=$api_key&part=snippet,contentDetails,statistics,status";

$url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub video_id_to_api_data_on_cache{

my $self = shift;
my $video_id = shift || die;
my $video = new Mebius::Video::Video;
my $get_page = new Mebius::Getpage;
my($data);

	# Cache Exists
	if( $data = $video->fetchrow_main_table({ video_id => $video_id })->[0] ){

			if($data->{'last_modified'} < time -24*60*60){

				my(%insert);

				my $api_data = $self->video_id_to_api_data($video_id);
				$insert{'last_modified'} = time;

				%insert = (%{$data},%{$api_data},%insert);

				$video->update_main_table(\%insert);
			} else {
				1;
			}

	# Cache not exists
	} else {

		my(%insert);

		my $api_data = $data = $self->video_id_to_api_data($video_id);

		$insert{'last_modified'} = time;
		$insert{'target'} = $video->new_target_char();
		$insert{'video_id'} = $video_id;

		%insert = (%{$api_data},%insert);

		$video->insert_main_table(\%insert);

	}

$data;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub video_id_to_api_data{

my $self = shift;
my $video_id = shift;
my $get_page = new Mebius::Getpage;

my $api_url = $self->video_id_to_api_url($video_id);
my $api_html = $get_page->get_page($api_url);

my $data = $self->youtube_api_html_to_data($api_html);

$data;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub youtube_api_html_to_data{

my $self = shift;
my $html = shift;
my(%data);

	foreach my $line (split(/\n|\r/,$html)){
		if($line =~ /"title": "(.+?)",/){
			$data{'title'} = $1;
		}
	}


\%data;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub html_body_side_bar{

my $self = shift;
my($print);
my $html = new Mebius::HTML;
my $tag_list = new Mebius::Video::TagList;
my $tag = new Mebius::Video::Tag;
my($my_use_device) = Mebius::my_use_device();
my($style);

my $tag_list_data_group = $tag_list->fetchrow_main_table();
my @tag_list_sorted = sort { $b->{'last_modified'} <=> $a->{'last_modified'} } @{$tag_list_data_group};

#$print .= qq(<div style="line-height:1.4em;">);
		if($my_use_device->{'smart_phone_flag'}){
			
		} else{
			$style = "margin-top:0em;";
		}

$print .= $html->tag("h2","タグ",{ style => $style },{ href => "recently_list_tag" });

$print .= qq(<div style="line-height:1.8em;">);
$print .= $tag->data_group_to_flat_list(\@tag_list_sorted);
$print .= qq(</div>);
#$print .= qq(</div>);

$print;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub youtube_api_key{
"AIzaSyCUzSsjEXCtr1MChvM_nMD-1Ngl2M1mTmQ";

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_title{
"Youtubeまとめ";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_domain{
"video.mb2.jp";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub service_start_year{
"2014";
}





1;

