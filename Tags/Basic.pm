
use strict;
use Mebius::Tags::Tag;
use Mebius::Tags::Comment;
use Mebius::Tags::Follow;
use Mebius::View;
use Mebius::Report;
package Mebius::Tags;
use base qw(Mebius::Base::Data Mebius::Base::Basic);

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
sub init{

my $self = shift;
my(%init);

$init{'title'} = "タグえもん";
$init{'title_rubi'} = "たぐえもん";
$init{'tag_max_character_num'} = 30;
$init{'max_tags_num_per_comment'} = 3;
$init{'service_start_year'} = 2013;

	if(Mebius::alocal_judge()){
		$init{'base_url'} = "http://localhost/-tags/";
	} else {
		$init{'base_url'} = "http://tags.mb2.jp/";
	}

\%init;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_all_objects{

my $self = shift;
my(%object);

$object{'tag'} = new Mebius::Tags::Tag;

\%object;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my($param) = Mebius::query_single_param();
my $tag = $self->tag_object();
my $comment = $self->comment_object();

	if($comment->query_to_sitemap_view()){
		1;	} elsif($comment->query_to_sitemap_index_view()){
		1;
	} elsif($tag->limited_junction()){
		1;
	} elsif($comment->limited_junction()){
		1;
	} elsif($param->{'tail'} eq ""){

			if( $param->{'mode'} eq "tag" ){

				my $tag_name = $param->{'directory1'};
				my $label_name = $param->{'directory2'};
				my($flag);

					foreach my $key_and_value ( split(/&/,$ENV{'QUERY_STRING'}) ){
						my($key,$value) = split(/=/,$key_and_value);

							if($key eq "directory1"){
								$flag = 1;
							}

							if($value eq "" && $key !~ /^directory([0-9]+)$/){
								$tag_name .= "&$key";
							}
					}

				$tag->tag_view($tag_name,$label_name);

			} elsif( my $comment_target = $param->{'comment'} && $ENV{'REQUEST_METHOD'} eq "GET"){
				$comment->one_comment_view($comment_target);
			} elsif($param->{'mode'} eq "follow"){
				$self->top_page_view({ FollowPage => 1 });
			} elsif($param->{'mode'} eq "my_history"){
				$comment->my_history_view({ });
			} elsif($param->{'mode'} eq ""){
				$self->top_page_view();
			} elsif($param->{'mode'} eq "my_friends"){
				$self->my_friends_comment_view();
			} elsif($param->{'mode'} eq "control"){
				$self->query_to_control_and_redirect();
			} elsif($param->{'mode'} eq "recently"){
				$comment->recently_line_view();
			} elsif($param->{'mode'} eq "create_tag"){
				$tag->create_view();
			} elsif($param->{'mode'} eq "create_tag_submit"){
				$tag->create_tag();
			} elsif($param->{'mode'} eq "search"){
				$tag->search_view();
			} elsif($param->{'mode'} eq "comment"){
				$comment->create_comment();
			} else {
				$self->error("モードを選択して下さい。");
			}


	} else {
		$self->error("モードを選択して下さい。");
	}


exit;

#Mebius::Template::gzip_and_print_all({},"");

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub query_to_control{

my $self = shift;
my($param) = Mebius::query_single_param();
my $tag = $self->tag_object();
my $comment = $self->comment_object();
my $follow = $self->follow_object();

	foreach my $name ( %{$param} ){

			if($tag->param_to_control($name)){
				1;
			} elsif($comment->param_to_control($name)){
				1;
			} elsif($comment->param_to_report_preview($name)){
				last;
			} elsif($comment->param_to_push_good($name)){
				last;
			} elsif($tag->param_to_report_preview($name)){
				last;
			} elsif($follow->param_to_follow($name)){
				last;
			} elsif($follow->param_to_unfollow($name)){
				last;
			}

	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub top_page_view{

my $self = shift;
my $use = shift;
my $device = new Mebius::Device;
my $init = $self->init();
my $tag = $self->tag_object();
my $comment = $self->comment_object();
my $html = new Mebius::HTML;
my($print,$time_line);
my $title = $init->{'title'};

my $tags_cookie = Mebius::Cookie::get("tags");

my $create_tag_url = $tag->create_tag_url();

$print .= $comment->form();

	if( my $error = $use->{'comment_form_error'}){
		$print .= $html->tag("div",$error,{ class => "message-red cleart" });
	}

	if($self->priority_on_recently_switch() && !$use->{'FollowPage'}){
		$time_line = $comment->recently_line({ max_view => 10 , AddAccountHandle => 1 });
	} else {
		$time_line = $comment->time_line();
	}

#if(Mebius::alocal_judge()){ $print .= $comment->my_history(); }

$print .= $html->start_tag("div",{ class => "clear" });
$print .= $comment->around_control_form($time_line);
$print .= $html->close_tag("div");

$print .= $comment->push_good_javascript();

	if(Mebius->common_admin_judge()){
		$print .= $html->tag("h2","違反報告");
		$print .= $self->report_line();
	}
$self->print_html($print,{ ContentsTopPage => 1 , h1 => $title });

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub search_form{

my $self = shift;
my $html = new Mebius::HTML;
my $init = $self->init();
my $query = new Mebius::Query;
my $param_utf8 = $query->param_utf8_judged_query();
my($form);

$form .= $html->start_tag("form");

$form .= $html->input("hidden","mode","search");
$form .= $html->input("search","keyword",$param_utf8->{'keyword'});
$form .= $html->input("submit","","$init->{'title'}から検索");
$form .= $query->input_hidden_encode_shift_jis_only();

$form .= $html->close_tag("form");

$form;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_html{

my $self = shift;
my $html_body = shift;
my $use = shift;
my $init = $self->init();
my $html = new Mebius::HTML;
my $javascript = new Mebius::Javascript;
my $device = new Mebius::Device;
my($my_use_device) = Mebius::my_use_device();
my $tag = $self->tag_object();
my $follow = $self->follow_object();
my($print,$navigation_line,$time_line_line,$h1);

my $id = "tags_contents_body";

my $adjusted_use = $self->adjust_header_use($use,$init);
$adjusted_use->{'Jquery'} = 1;

	if($use->{'h1'}){
		$h1 = $html->tag("h1",$use->{'h1'});
	}

my $horizon_navigation_line = $self->horizon_navigation_line();

$navigation_line .= $html->start_tag("div",{ style => "line-height:2.0;word-spacing:0.4em;" }); # position:fixed;

#$navigation_line .= $html->start_tag("div",{ style => "position:fixed;" });

$navigation_line .= $html->start_tag("div",{ class => "margin-bottom" });
$navigation_line .= $html->tag("h2","フォロー",{ style => "margin-top:0em;margin-bottom:0.5em;" });
$navigation_line .= $follow->my_follow_tag_links();
$navigation_line .= $html->close_tag("div");

$navigation_line .= $html->tag("h2","タグ一覧",{ style => "margin-top:0em;" });
$navigation_line .= $self->search_form();
$navigation_line .= $html->start_tag("div",{ class => "margin-top" });
$navigation_line .= $tag->recently_create_line();
$navigation_line .= $html->close_tag("div");


#$navigation_line .= $html->close_tag("div");
$navigation_line .= $html->close_tag("div");


	if($my_use_device->{'smart_phone_flag'}){

		$print .= $h1;

		$print .= $html->start_tag("div",{ class => "margin-bottom" , id => $id  });
		$print .= $horizon_navigation_line;
		$print .= $html->close_tag("div");

		$print .= $html->start_tag("div",{ id => "tags_navigation" , class => "none margin-bottom margin-top padding" , style => "background:#eef;"  });
		$print .= $navigation_line;
		$print .= $html->close_tag("div");

		$print .= $html_body;

	} else {

		$print .= $html->start_tag("div",{ class => "float-left" , style => "width:70%;" , id => $id });
		$print .= $h1;
		$print .= $horizon_navigation_line;
		$print .= $html_body;
		$print .= $html->close_tag("div");

		$print .= $html->start_tag("div",{ class => "float-right" , style => "width:29%;" });
		$print .= $navigation_line;
		$print .= $html->close_tag("div");

	}


$print .= $html->tag("div",undef,{ class => "clear" });

$print .= $javascript->onload("$init->{'base_url'}recently_comment_core","ajax_test","tags_contents_body");

	if($use->{'ReturnLimitedPrint'}){
		return $print;
	}

	#if(Mebius::alocal_judge()){ Mebius::Debug::print_hash($adjusted_use); }

Mebius::Template::gzip_and_print_all($adjusted_use,$print);

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_html_contents_body{


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub priority_on_recently_switch{
1;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub horizon_navigation_line{

my $self = shift;
my($print);
my $html = new Mebius::HTML;
my $view = new Mebius::View;
my($my_use_device) = Mebius::my_use_device();
my $init = $self->init();
my(@links);

	if($self->priority_on_recently_switch()){
		@links = (
		{ url => "$init->{'base_url'}" , title => "最近" } , 
		{ url => "$init->{'base_url'}follow" , title => "フォロー" } , 
		);
	} else {
		@links = (
		{ url => "$init->{'base_url'}" , title => "フォロー" } , 
		{ url => "$init->{'base_url'}recently" , title => "最近" } , 
		);
	}

push @links ,	{ url => "$init->{'base_url'}my_history" , title => "自分" } ;

$print .= $html->start_tag("div",{ class => "margin-bottom"  });
$print .= $view->on_off_links(\@links);

	if($my_use_device->{'smart_phone_flag'}){
		$print .= " " . $html->href("#","ナビゲーション",{ onclick => "vswitch('tags_navigation','block');return false;" });
	}

$print .= " " . $html->href("#","AJAXテスト",{ id => "ajax_test" , onclick => "return false;"  });

$print .= $html->close_tag("div");

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub fix_tag_name{

my $self = shift;
my $tag_name = shift;
my $text = new Mebius::Text;

my $fixed_tag_name = $text->fix_title($tag_name);
$fixed_tag_name = $text->fullsize_to_halfsize($fixed_tag_name);

$fixed_tag_name;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tag_auto_link{

my $self = shift;
my $comment_body = my $comment_original = shift;
my $tag = $self->tag_object();
my $label_split_mark = $self->label_split_mark();
my($line);

$comment_body =~ s/　/ /g;
$comment_body =~ s/(?<!&)#([^\s${label_split_mark}]+)(${label_split_mark}([^\s${label_split_mark}]+))?/$tag->data_to_link({ title => $1 , label => $3 })/eg;

$comment_body;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tag_object{
my $self = shift;
my $tag = new Mebius::Tags::Tag;
$tag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub comment_object{
my $self = shift;
my $comment = new Mebius::Tags::Comment;
$comment;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub follow_object{
my $self = shift;
my $follow = new Mebius::Tags::Follow;
$follow;
}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub error{
my $self = shift;
Mebius->error(@_);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_limited_package_name{
"tags";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub max_tags_num{
my $self = shift;
my $init = $self->init();

my $max_tags_num = $self->max_tags_num_per_comment() || die;

$max_tags_num;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub max_tags_num_per_comment{
3;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub label_split_mark{
"/";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tag_mark{
"#";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tag_param{

my $self = shift;
my($param) = Mebius::query_single_param();
$param->{'directory1'};
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub label_param{
my $self = shift;
my($param) = Mebius::query_single_param();
$param->{'directory2'};
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_line{

my $self = shift;
my $tag = $self->tag_object();
my $comment = $self->comment_object();
my $report = new Mebius::Report;
my($line,%adjusted_report,$i_debug);

my $report_data_group = $self->no_reactioned_report_data_group();

	foreach my $report_data (@{$report_data_group}){
		push @{$adjusted_report{$report_data->{'targetA'}}{$report_data->{'target_unique_number'}}} , $report_data;
		#push @{$adjusted_report{"test"}{"test"}} , $report_data;

	}

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($adjusted_report{"test"}{"test"})); }

#Mebius::Debug::print_hash(\%adjusted_report);

	foreach my $target_type ( keys %adjusted_report ){

			foreach my $target ( keys %{$adjusted_report{$target_type}}){

				$i_debug++;

				my $report_data_group = $adjusted_report{$target_type}{$target};


				#if($i_debug == 2){
				#		if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($report_data_group / ?)); }
				#		Mebius::Debug::print_hash($report_data_group->[0]);
				#}


					if($target_type eq "tag"){
						$line .= $tag->target_to_data_line_with_report($target,$report_data_group);
					} elsif ($target_type eq "comment"){
						$line .= $comment->target_to_data_line_with_report($target,$report_data_group);
					}

			}

	}


	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($i_debug)); }


$line;

}

1;

