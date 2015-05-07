
use strict;
use Mebius::Vine::Post;
use Mebius::Vine::Comment;
package Mebius::Vine;
use base qw(Mebius::Base::Basic);

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
sub main_limited_package_name{
"vine";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub objects_for_report{

my $self = shift;
my(@object);

push @object , new Mebius::Vine::Post;
push @object , new Mebius::Vine::Comment;

@object;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_all_objects{

my $self = shift;
my(%object);

$object{'post'} = new Mebius::Vine::Post;

\%object;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub init{

my $self = shift;
my(%init);

	if(Mebius::alocal_judge()){
		$init{'base_url'} = "http://localhost/-vine/";
	} else {
		$init{'base_url'} = "http://vine.mb2.jp/";
	}

$init{'title'} = "Vineファン -6秒動画案内-";
$init{'short_title'} = "Vineファン";

$init{'service_start_year'} = 2013;

\%init;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my($param) = Mebius::query_single_param();
my $post = new Mebius::Vine::Post;
my $comment = new Mebius::Vine::Comment;
my $mode = $param->{'mode'};

	if($post->limited_junction()){
		1;
	} elsif($mode eq "control"){
		$self->query_to_control_and_redirect();
	} elsif($mode eq "create_post"){
		$post->create_post();
	} elsif($mode eq "create_post_preview"){
		$post->create_post_preview();
	} elsif($mode eq "comment"){
		$comment->create_comment();
	} elsif($mode eq "") {
			if( my $vine_target = $param->{'vine_target'} ){
				$post->self_view($vine_target);
			} else {
				$self->top_page_view();
			}
	} else {
		main::error("モードを選択して下さい。");
	}

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub query_to_control{

my $self = shift;
my($param) = Mebius::query_single_param();
my $post = new Mebius::Vine::Post;
my $comment = new Mebius::Vine::Comment;

	foreach my $key ( %{$param} ) {

			if($post->param_to_control($key)){
				1;
			} elsif($comment->param_to_some_action($key)){
				last;
			} elsif($post->param_to_push_good($key)){
				last;
			}

	}


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub top_page_view{

my $self = shift;
my $html = new Mebius::HTML;
my $post = new Mebius::Vine::Post;
my $init = $self->init();
my($print);

$print .= qq(<strong class="red">テスト稼働中。</strong>);
#$print .= $html->tag("h2","動画の追加");
$print .= $post->create_form();;


my $recently_create_line = $post->recently_create_line();
$print .= $post->around_control_form($recently_create_line);


$print .= $post->recently_list();

$print .= $html->tag("h2","検索");
$print .= $post->search_form();

$self->print_html($print,{ h1 => $init->{'site_title'} , ContentsTopPage => 1 , Title => $init->{'site_title'} });

exit;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub embed_tag{

my $self = shift;
my $vine_target = shift || ( warn("vine target is empty.") && return());
my $use = shift;
my $html = new Mebius::HTML;
my $device = new Mebius::Device;
my($my_use_device) = Mebius::my_use_device();
my($tag,$width,$height,$url,$audio);

	#if(!$use->{'AudioOff'}){
	#	$audio = 1;
	#}

$url = "https://vine.co/v/$vine_target/embed/simple?audio=$audio";
	
	if($my_use_device->{'smart_phone_flag'}){
		$width = $height = "300";
	} else {
		$width = $height = "400";
	}

$tag = $html->tag("iframe",undef,{ class => "vine-embed" , width => $width , height => $height , framborder => "0" , src => $url });
$tag .= qq(<script async src="//platform.vine.co/static/scripts/embed.js" charset="utf-8"></script>);

$tag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub vine_url_to_vine_target{

my $self = shift;
my $url = shift;
my($flag,$vine_target);

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($url)); }

	if($url =~ m!^(?:https?://)?vine\.co/v/([a-zA-Z0-9]+)!){
		$vine_target = $1;
	} else {
		return();
	}


$vine_target;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub vine_target_to_vine_url{

my $self = shift;
my $target = shift;
my($url);

	if($self->vine_target_invalid($target)){
		warn;
		return();
	} else {
		$url = "https://vine.co/v/$target";
	}


$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub vine_target_invalid{

my $self = shift;
my $target = shift;
my($invalid_flag);

	if($target =~ /^[a-zA-Z0-9]+$/){
		0;
	} else {
		$invalid_flag = 1;
	}

$invalid_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub vine_url_to_status_code{

my $self = shift;


}




1;

