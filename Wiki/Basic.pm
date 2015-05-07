
use strict;
use Mebius::Wiki::Post;
use Mebius::Wiki::Site;
use Mebius::Wiki::Category;

use Mebius::Gaget;
use Mebius::Ads;
package Mebius::Wiki;
use base qw(Mebius::Base::Basic);
use Mebius::Export;

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my $post = new Mebius::Wiki::Post;
my $site = new Mebius::Wiki::Site;
my $category = new Mebius::Wiki::Category;

	if($self->edit_site_mode() && !$self->allow_edit()){
		$self->error404();
	}

	if($self->master_site_mode()){

			if($param->{'mode'} eq ""){
				$self->edit_site_mode_top_page_view();
			} elsif($param->{'mode'} eq "site_control_view"){
				$site->site_control_view();
			} elsif($param->{'mode'} eq "site_control"){
				$site->site_control();
			} else {
				$self->edit_site_mode_top_page_view();
			}

	} elsif($param->{'tail'} eq "xml"){

			if($param->{'mode'} eq "sitemap"){
				$post->sitemap_view();
			} else {
				$self->error404();
			}

	} else {

			if($param->{'mode'} eq "edit_or_create"){
				$post->edit_or_create_page();
			} elsif($param->{'mode'} eq "create"){
				$post->new_page_form_view();
			} elsif($param->{'mode'} eq "category_edit"){
				$category->edit_view();
			} elsif($param->{'mode'} eq "change_category_name"){
				$category->change_category_name();
			} elsif($param->{'mode'} eq "dbi_control_all_post_to_create_category"){
				$category->dbi_control_all_post_to_create_category();
			} elsif($param->{'mode'} eq "recently"){
				$post->recently_list_view();
			} elsif($param->{'mode'} eq ""){

					if( my $title = $param->{'title'}){
						$post->self_view($title);
					} else {
						$self->top_page_view();
					}

			} else {
				$self->error404();
			}

	}

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub top_page_view{

my $self = shift;
my $post = new Mebius::Wiki::Post;
my($print);

my $top_page_name = $self->top_page_name();

$post->self_view($top_page_name);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_site_mode_top_page_view{

my $self = shift;
my $basic = new Mebius::Wiki;
my $site = new Mebius::Wiki::Site;
my $html = new Mebius::HTML;
my($param) = Mebius::query_single_param();
my($print,$all_active_domain);

	if($param->{'mode'} eq "refresh_database"){
		$site->site_setting_script_to_dbi();
	}

$print .= $html->tag("h1","作業TOP");

$print .= $html->href("?mode=refresh_database","データベース更新") . "\n";
#$print .= $html->href("?mode=site_control_view","サイトの管理") . "\n";

$print .= $html->tag("h2","月別");
$print .= $self->all_site_post_num_per_month();

$print .= $html->tag("h2","日別");
$print .= $self->all_site_recently_post_per_day();

my $all_active_domain = $site->all_active_domain();
$print .= join "<br>" , @{$all_active_domain} ;

$basic->print_html($print,{ Title => "作業TOP" });

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_base_url{

my $self = shift;
my $site_domain = shift || $self->site_domain();
my $basic = new Mebius::Wiki;
my($url);


	if(Mebius::alocal_judge()){
		$url = "/-wiki/$site_domain/";
		#$url = "http://$ENV{'HTTP_HOST'}/-wiki/$site_domain/";
	} elsif($basic->edit_site_mode()){
		$url = "/$site_domain/";
		#$url = "http://$ENV{'HTTP_HOST'}/$site_domain/";
	} else {

			if($ENV{'HTTP_HOST'} eq $site_domain && $site_domain){
				$url = "/";
			} else {
				$url = "http://$site_domain/";
			}

	}


$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_data{

my $self = shift;
my $site_domain = shift || $self->site_domain();
my $site = new Mebius::Wiki::Site;

my $site_setting = $site->site_setting();

my $this_site_setting = $site_setting->{$site_domain};

$this_site_setting;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_category{

my $self = shift;

my $this_site_title = $self->site_data(@_);

$this_site_title->{'category'};

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_title{

my $self = shift;

my $this_site_title = $self->site_data(@_);

$this_site_title->{'title'};

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_domain{

my $self = shift;
my($domain);
my($param) = Mebius::query_single_param();

	if(Mebius::alocal_judge() || $self->edit_site_mode()){
		$domain = $param->{'domain'};
	} else {
		$domain = $ENV{'HTTP_HOST'};
	}

	if($domain && $domain !~ /^([0-9a-zA-Z\.\-]+)$/){
		die();
	}

$domain = Mebius::decode_text($domain);

$domain;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub master_site_mode{

my $self = shift;

	if($self->site_domain() eq "" && $self->allow_edit()){
		1;
	} else {

	}

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_site_mode{

my $self = shift;
my($flag);

	if($ENV{'HTTP_HOST'} eq "wiki.mb2.jp"){
		$flag = 1;
	} elsif(Mebius::alocal_judge()){

		$flag = 1;
	}



$flag;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_site_post_num_per_month{

my $self = shift;
my $post = new Mebius::Wiki::Post;
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my($print,%month);

my $table_switch = 0;

my $data_group = $post->fetchrow_main_table();


	foreach my $data (@{$data_group}){
			if($post->data_to_escape_list_judge($data)){ next; }
		my $create_year_month = $times->yearf($data->{'create_time'}) . $times->monthf($data->{'create_time'});
		push @{$month{$create_year_month}} , $data;
	}

	foreach my $create_year_month ( sort { $b <=> $a } keys %month ){

		my $data_group = $month{$create_year_month};
		my $create_num = @{$data_group};
		my $total_character_num = $self->data_group_to_total_character_num($data_group);

		$create_year_month	=~ s!(.{4})!$1/!;

			if($table_switch){
				$print .= qq(<tr>);
				$print .= $html->tag("td",${create_year_month});
				$print .= $html->tag("td","${create_num}");
				$print .= $html->tag("td","${total_character_num}");
				$print .= qq(</tr>);
			} else {
				$print .= $html->tag("h3","${create_year_month} - ${create_num}個 \(${total_character_num}文字\)");
			}

		#$print .= $html->start_tag("ul");
		#$print .= $post->data_group_to_list($data_group,{ SiteTitle => 1 });
		#$print .= $html->close_tag("ul");


	}

	if($table_switch){
		$print = qq(<table style="border-color;1px;text-align:right;" border="1"><th>時期</th><th>記事数</th><th>文字数</th>$print</table>);
	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_site_recently_post_per_day{

my $self = shift;
my $post = new Mebius::Wiki::Post;
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my(%day,$print);

#my $how_back_days = 30;
my $how_back_days = 365;

my $border_time = time - ($how_back_days*24*60*60);

my $data_group = $post->fetchrow_main_table({ create_time => [">=",$border_time] });

	foreach my $data (@{$data_group}){
		if($post->data_to_escape_list_judge($data)){ next; }
		my $create_day = $times->monthf($data->{'create_time'}) . $times->dayf( $data->{'create_time'} );
		push @{$day{$create_day}} , $data;
	}

	foreach my $create_month_and_day ( sort { $b <=> $a } keys %day ){

		my $data_group = $day{$create_month_and_day};
		my $create_num = @{$data_group};
		my @sorted_data_group = sort { $b->{'last_modified'} <=> $a->{'last_modified'} } @{$data_group};

		$create_month_and_day	=~ s!(.{2})!$1/!;

		my $total_character_num = $self->data_group_to_total_character_num(\@sorted_data_group);

		$print .= $html->tag("h3","${create_month_and_day} - ${create_num}個 \( ${total_character_num}文字 \)" );

		$print .= $html->start_tag("ul");
		$print .= $post->data_group_to_list(\@sorted_data_group,{ CharacterNum => 1});
		$print .= $html->close_tag("ul");


	}

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_total_character_num{

my $self = shift;
my $data_group = shift || [];
my $text = new Mebius::Text;
my $post = new Mebius::Wiki::Post;
my($total_character_num);

	foreach my $data (@{$data_group}) {
			if($post->data_to_escape_list_judge($data)){ next; }
		$total_character_num += $text->character_num_with_comma($data->{'text'});
	}

$total_character_num;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_html{

my $self = shift;
my $print_body = shift;
my $use = shift || {};
my($my_use_device) = Mebius::my_use_device();
my $template = new Mebius::Template;
my($print,$css_text);


$css_text .= "p,div,li{line-height:1.6;}\n";
$css_text .= "ul{padding-left:1.5em;}\n";
$css_text .= "body{font-family:'メイリオ','ヒラギノ角ゴ ProN W3';word-wrap:break-word;word-break:break-all;}\n";
	if($my_use_device->{'smart_phone_flag'}){
		$css_text .= qq(body{margin:0em 0.3em;});
		$css_text .= qq(.side-margin{margin-left:0.3em;margin-right:0.3em;});
	}
$css_text .= "h1,h2,h3,h4,h5,h6{margin:0em 0em 0em 0em;}\n";
$css_text .= qq(input[type="text"]:focus,input[type="password"]:focus,input[type="search"]:focus,textarea:focus{background: #ffd;});
$css_text .= qq(blockquote{background:#ffd;border:1px #f00 solid;padding:0.5em;margin-left:1em;});
$css_text .= qq(.red{color:red;});
$css_text .= qq(strong{color:red;});
$css_text .= qq(strong a:link,strong a:visited{color:#f55;});

#$css_text .= qq(blockquote{quotes: '"' '"';} blockquote:before{content: open-quote;} blockquote:after{content: close-quote;});
my %adjusted_use = (%{$use},( source => "utf8" , NoTemplateHeader => 1 , NoTemplateFooter => 1 , Simple => 1 , css_text => $css_text ));

# ヘッダ部分を定義
$print .= $self->header(\%adjusted_use);

$print .= $print_body;

$print .= $self->footer(\%adjusted_use);

Mebius::Template::gzip_and_print_all(\%adjusted_use,$print);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sorcial_button_super_set{

my $self = shift;
my $gadget = new Mebius::Gaget;
my $html = new Mebius::HTML;
my $url = new Mebius::URL;
my($print);

my $request_url = Mebius::request_url();

$print .= $html->start_tag("div",{ style => "margin-top:0.5em;word-spacing:0.25em;height:30px;" });
$print .= $gadget->tweet_button({ DataCount => 1 , url => $request_url }) . "\n";
$print .= $gadget->facebook_button() . "\n";
$print .= $html->close_tag("div");

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub navigation_links{

my $self = shift;
my($print);
my $html = new Mebius::HTML;
my $view = new Mebius::View;
my $category = new Mebius::Wiki::Category;

	#if(!$self->allow_t()){ return(); }

my $site_top_url = $self->site_base_url();
my $site_title = $self->site_title();

my @links = (
{ url => "${site_top_url}" , title => $site_title || "TOP" } , 
{ url => "${site_top_url}recently" , title => "新着" } ,
);

	if($self->allow_edit() && $self->site_domain()){
		push @links , { url => "${site_top_url}create" , title => "新規" } ;		push @links , { url => $category->edit_category_url() , title => "カテゴリ" } ;
	}

$print .= $html->start_tag("div",{ style => "word-spacing:0.25em;" });
$print .= $view->on_off_links(\@links);
$print .= $html->close_tag("div");

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub allow_edit{

my $self = shift;
my($flag);
my($my_account) = Mebius::my_account();

	if($my_account->{'master_flag'} || Mebius::alocal_judge()){
		$flag = 1;
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub header{

my $self = shift;
my $use = shift;
my $site = new Mebius::Wiki::Site;
my $mebius = new Mebius;
my $html = new Mebius::HTML;
my($param) = Mebius::query_single_param();
my($my_use_device) = Mebius::my_use_device();
my($print);

	if($self->allow_edit()){
		$use->{'Jquery'} = 1;
	}

$print .= qq(<!DOCTYPE html>\n);
$print .= qq(<html lang="ja">\n);
$print .= $mebius->between_head_tag($use);
$print .= qq(<body>\n);

	if(Mebius::alocal_judge()){
		$print .= $html->tag("div","ローカル",{ style => "text-align:center;font-size:90%;color:white;background:green;margin-bottom:1em;" });
	}

	if($self->allow_edit()){
		$print .= qq(<div style="word-spacing:0.5em;padding-bottom:0.3em;margin-bottom:0.3em;border-bottom:1px solid #000;">);
		$print .= $html->start_tag("div");
		$print .= $html->href($self->edit_mode_top_page_url(),"作業TOP") . "\n";
		$print .= $self->site_control_view_link() . "\n";

			if($self->edit_site_mode()){
				my $title_url = "$param->{'title'}/" if($param->{'title'});
				$print .= $html->href("http://$param->{'domain'}/$title_url","実ページ",{ target => "_blank" }) . "\n";
				$print .= $html->href("https://www.google.co.jp/#q=site:$param->{'domain'}","インデックス状況",{ target => "_blank" }) . "\n";

			}

		$print .= $html->close_tag("div");


		$print .= $html->start_tag("div");
		$print .= "サイト: ";
		$print .= $site->all_site_links({ LiveSitesOnly => 1 });
		$print .= $html->close_tag("div");

		#$print .= $html->start_tag("div");
		#$print .= $site->all_site_links({ HiddenSitesOnly => 1 });
		#$print .= $html->close_tag("div");

		$print .= qq(</div>);
	}

$print .= $self->navigation_links();

	if(!$self->edit_site_mode() && !$my_use_device->{'smart_phone_flag'}){
		$print .= $self->sorcial_button_super_set();
	}


$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub footer{

my $self = shift;
my $site = new Mebius::Wiki::Site;
my $html = new Mebius::HTML;
my $javascript = new Mebius::Javascript;
my($my_account) = Mebius::my_account();
my($print);

my $site_category = $self->site_category();

	if(!$self->edit_site_mode()){
		$print .= $self->sorcial_button_super_set();
	}

$print .= $self->navigation_links();

$print .= qq(<hr>);

$print .= qq(<div style="word-spacing:0.5em;">);
	if($site_category){
		$print .= $site->all_site_links({ LiveSitesOnly => 1 , RealURL => 1 , category => $site_category });
	}
$print .= qq(</div>);

	if(!$self->edit_site_mode()){
		$print .= $self->sorcial_footer_javascript_super_set();
	}


$print .= $html->start_tag("div",{ style => "text-align:center;font-size:80%;" });
$print .= $html->href("http://cyber-takoyaki.com/","CyberTakoyaki");
$print .= " | ";
#$print .= $html->href("http://cyber-takoyaki.com/%E3%81%94%E9%80%A3%E7%B5%A1/","ご連絡");
#$print .= " | ";
$print .= $html->href("http://cyber-takoyaki.com/%E3%83%97%E3%83%A9%E3%82%A4%E3%83%90%E3%82%B7%E3%83%BC%E3%83%9D%E3%83%AA%E3%82%B7%E3%83%BC/","プライバシーポリシー");
$print .= $html->close_tag("div");

	# ●管理者のみにアクセスデータを表示
	if($my_account->{'master_flag'} || Mebius::alocal_judge()){
		$print .= main::access_data_on_html();
	}

$print .= $javascript->before_unload_use_form();

$print .= q(
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-55185760-1', 'auto');
  ga('send', 'pageview');
</script>
);

$print .= qq(</body>\n);
$print .= qq(</html>\n);

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub this_category_site_links{

#$print .= $site->all_site_links({ RealURL => 1 , category => $site_category });


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sorcial_footer_javascript_super_set{

my $self = shift;
my $gaget = new Mebius::Gaget;
my($print);

$print .= $gaget->twitter_javascript();
$print .= $gaget->facebook_javascript();

$print;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adsense_bunner{

my $self = shift;
my($my_use_device) = Mebius::my_use_device();
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my $ads = new Mebius::Ads;
my($print,$adsense_code);

	if($basic->edit_site_mode()){
		return();
	}

	if($my_use_device->{'smart_phone_flag'}){
		$adsense_code = $self->adsense_bunner_for_smart_phone();
	} else {
		$adsense_code = $self->adsense_bunner_for_pc();
	}


$print .= $ads->adsense_code_to_label($adsense_code);
$print .= $html->start_tag("div",{ style => "margin:0em 0em;" });
$print .= $adsense_code;
$print .= $html->close_tag("div");

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adsense_box{

my $self = shift;
my $use = shift;
my($print);
my($my_use_device) = Mebius::my_use_device();
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my $ads = new Mebius::Ads;
my($adsense_code);

	if($basic->edit_site_mode()){
		return();
	}

	if($my_use_device->{'smart_phone_flag'}){
		$adsense_code = $self->adsense_tangle_for_smart_phone();
	} else {
		$adsense_code = $self->adsense_tangle_for_pc();
	}

	if($use->{'Label'}){
		$print .= $html->start_tag("div",{ style => "margin:1.0em 0em;" });
		$print .= $ads->adsense_code_to_label($adsense_code);
	} else {
		$print .= $html->start_tag("div",{ style => "margin:1.5em 0em 0.5em 0em;" });
	}

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($print)); }

$print .= $adsense_code;
$print .= $html->close_tag("div");

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adsense_tangle_for_smart_phone{

qq(
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- Wiki スマフォ -->
<ins class="adsbygoogle"
     style="display:inline-block;width:300px;height:250px"
     data-ad-client="ca-pub-7808967024392082"
     data-ad-slot="3471074921"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adsense_tangle_for_pc{

qq(
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- Wiki -->
<ins class="adsbygoogle"
     style="display:inline-block;width:336px;height:280px"
     data-ad-client="ca-pub-7808967024392082"
     data-ad-slot="5087408925"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adsense_bunner_for_smart_phone{

qq(<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- Wiki モバイルバナー -->
<ins class="adsbygoogle"
     style="display:inline-block;width:320px;height:50px"
     data-ad-client="ca-pub-7808967024392082"
     data-ad-slot="6865193323"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
);
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adsense_bunner_for_pc{

qq(
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- Wiki ビッグバナー -->
<ins class="adsbygoogle"
     style="display:inline-block;width:728px;height:90px"
     data-ad-client="ca-pub-7808967024392082"
     data-ad-slot="5388460124"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
);

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit_mode_top_page_url{

my $self = shift;
my($url);

	if(Mebius::alocal_judge()){
		$url = "/-wiki/";
	}	else {
		$url = "http://wiki.mb2.jp/";
	}

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_control_view_url{

my $self = shift;
my $base_url = $self->edit_mode_top_page_url();

my $url = $base_url . "?mode=site_control_view";

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_control_view_link{

my $self = shift;
my $html = new Mebius::HTML;

my $url = $self->site_control_view_url();

my $link = $html->href($url,"サイトの管理");

$link;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub top_page_name{
"TopPage";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub top_page_name_judge{

my $self = shift;
my $page_name = shift;
my($flag);

my $top_page_name = $self->top_page_name() || die;

	if($page_name eq $top_page_name){
		$flag = 1;
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub side_bar_name{
"SideBar";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic_author_name{
"上原淳介";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub error404{

my $self = shift;
print "Status: 404 NotFound\n";
print "Content-type:text/html\n\n";
print "404 Not Found.";
exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub error{

my $self = shift;
my $message = shift;
my $html = new Mebius::HTML;
print "Content-type:text/html\n\n";
print $html->tag("div",$message);
exit;

}


1;
