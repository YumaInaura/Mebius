
use strict;
package Mebius::Wiki::Post;
use Mebius::Upload;
use Mebius::Wiki::Category;
use Mebius::Wiki::Site;
use base qw(Mebius::Base::Data Mebius::Base::DBI);
use File::Copy 'copy';
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
sub main_table_name{
"wiki_post";
}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub main_table_column{

my $column = {

target => { PRIMARY => 1 } ,
number => { int => 1 } ,

domain => { INDEX => 1 } ,

category => { INDEX => 1 } ,
category2 => { INDEX => 1 } ,
category3 => { INDEX => 1 } ,

title => { INDEX => 1 } ,
deleted_flag => { int => 1 } ,

text => { text => 1 } ,

last_modified => { int => 1 , INDEX => 1 } ,
create_time => { int => 1 , INDEX => 1 } ,

keyword_flag => { int => 1 , INDEX => 1 } ,
redirect_title => { } ,

};

$column;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub self_view{

my $self = shift;
my $target_title = shift;
my $html = new Mebius::HTML;
my $basic = new Mebius::Wiki;
my $times = new Mebius::Time;
my $category = new Mebius::Wiki::Category;
my($my_account) = Mebius::my_account();
my($my_use_device) = Mebius::my_use_device();
my($param) = Mebius::query_single_param();
my($print,$title,$h1,@data_times,$ads_flag,$top_page_flag,$page_core,$on_category_flag,$redirect_link,$h1_href);

my $site_domain = $basic->site_domain();
my $site_title = $basic->site_title();
my $top_page_name = $basic->top_page_name();
my $category_hash_data = $category->fetchrow_on_hash_main_table({},"title");

my $data = $self->fetchrow_main_table({ domain => $site_domain , title => $target_title })->[0];

	if($data->{'redirect_title'}){
		my $redirect_url = $self->data_to_url({ title => $data->{'redirect_title'} , domain => $site_domain });

			if($basic->edit_site_mode()){
				$redirect_link = $self->data_to_link({ title => $data->{'redirect_title'} , domain => $site_domain });
			} else {
				Mebius::redirect($redirect_url,301);
				exit;
			}
	}

	if($target_title && (exists $category_hash_data->{$target_title} || $target_title eq $self->other_category_name())){
		$on_category_flag = 1;
	}

	if($top_page_name eq $target_title){
		$top_page_flag = 1;
	}

	if(length $data->{'text'} >= 100){
		$ads_flag = 1;
	}

	if($top_page_flag){
		$h1 = $site_title || $top_page_name;
		$title = $site_title || $top_page_name;
	} elsif($param->{'chapter'}) {
		$h1 = $target_title;
		$title = "$param->{'chapter'} | $target_title | $site_title";
		$h1_href = $self->data_to_url($data);
	} else {
		$h1 = $target_title;
		$title = "$target_title | $site_title";
	}

	if(!$data->{'text'} && !$basic->allow_edit() && !$on_category_flag){
		$basic->error404("ページが存在しません。[W1]");
	}

$page_core .= $html->tag("h1",$h1,undef,{ href => $h1_href }) . "\n";


	if($top_page_flag){
		$page_core .= "全記事数: " . $self->all_post_num_per_domain($site_domain) . "個";
	}


	if($redirect_link){
		$page_core .= $html->start_tag("div");
		$page_core .= qq(→$redirect_link に転送済み。);
		$page_core .= $html->close_tag("div");

	}

	if($ads_flag && $my_use_device->{'smart_phone_flag'} && !$top_page_flag){
		#$page_core .= $basic->adsense_bunner();
	}

$page_core .= $html->start_tag("div",{ class => "side-margin"  });
$page_core .= $self->adjust_text_body($data);

	if($on_category_flag && !$top_page_flag){
		my $line .= $self->data_to_on_category_line($target_title);
			if($line || $data->{'text'}){
				1;
			} else {
				#$basic->error404("ページが存在しません。");
			}
		$page_core .= $line;
	}

push @data_times , qq(By ) . $basic->basic_author_name();


	#if( my $number = $data->{'number'}){
	#	push @data_times , e("No.$number");
		#$h1 = "$number.$h1";
	#}


	if( my $time = $data->{'create_time'} ){
		my $create_date = $times->get_date_till_minute($time);
		push @data_times , "$create_date "; # . "( " . $times->how_before($time) . " )";
	}

	if( my $time = $data->{'last_modified'} ){
			if($time != $data->{'create_time'}){
				push @data_times , "更新 " . $times->how_before($time);
			}
	}


	if(@data_times){
		$page_core .= $html->start_tag("div",{ style => "" });
		$page_core .= join " - " , @data_times;
		$page_core .= $html->close_tag("div");
	}

	if($ads_flag){
		$page_core .= $basic->adsense_box();
	}

	if(!$on_category_flag && !$top_page_flag){
		$page_core .= $self->data_to_relation_category_line($data);
	}


$page_core .= $html->close_tag("div");

	if($basic->allow_edit()){

			if($self->float_edit_form_switch()){
				$print .= $html->start_tag("div",{ style => "float:left;width:40%;" });
				$print .= $self->page_edit_form($data);
				$print .= $html->close_tag("div");

				$print .= $html->start_tag("div",{ style => "float:right;width:60%;" });
				$print .= $page_core;
				$print .= $html->close_tag("div");

				$print .= $html->tag("div","",{ style => "clear:both;" });
			} else {
				$print .= $page_core;
				$print .= $self->page_edit_form($data);

			}


			#if($top_page_flag){
			#	$print .= $self->page_edit_form({},{ New => 1 });
			#}

	} else {
		$print .= $page_core;
	}



$basic->print_html($print,{ Title => $title });

exit;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub all_post_num_per_domain{

my $self = shift;
my $domain = shift || return();
my($count);

my $data_group = $self->fetchrow_main_table({ domain => $domain });

	foreach my $data (@{$data_group}){
			if($data->{'text'}){
				$count++;
			}
	}


$count;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_on_category_line{

my $self = shift;
my $category = shift;
my $use = shift;
my $html = new Mebius::HTML;
my($page_core);

	if($category eq $self->other_category_name()){
		$category = "";
	}

	if( my $line = $self->category_list($category)){
		$page_core .= $html->tag("h2","メニュー");
		$page_core .= $line;
	}

$page_core;


}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_relation_category_line{

my $self = shift;
my $data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my($page_core);

	if( my $line = $self->category_list($data->{'category'},$data->{'title'})){
		$page_core .= $html->tag("h2","同じカテゴリのページ");
		$page_core .= $line;
	}

$page_core;


}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub new_page_form_view{

my $self = shift;
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my $category = new Mebius::Wiki::Category;
my($print);

my $site_title = $basic->site_title();
my $title = "新規ページ &lt; $site_title &gt;";

my @all_category = @{$category->all_category_name()};

$print .= $html->tag("h1",$title);
$print .= $self->page_edit_form(undef,{ New => 1 });
$print .= "[カテゴリ] ";
$print .= join " / " , @all_category;

$basic->print_html($print,{ Title => $title });

exit;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub category_list{

my $self = shift;
my $category = shift;
my $this_title = shift;
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my($print,$data_group,%fetch);

$category =~ s/[\n\r]//g;

my $site_domain = $basic->site_domain();

$fetch{'domain'} = $site_domain;

	if($this_title){
		$fetch{'title'} = ["<>",$this_title];
	}

	if($category){
		$fetch{'category'} = $category;
	} else {
		$fetch{'category'} = ["IS","NULL"]
	}

$data_group = $self->fetchrow_main_table(\%fetch,{ ORDER_BY => ["last_modified DESC"] , Debug => 0 });

	if( my $line = $self->data_group_to_list($data_group,{})){
		$print .= qq(<ul>$line</ul>);
	}

$print;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub recently_list{

my $self = shift;
my $max_view = shift;
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my($print,%per_category);

my $top_page_name = $basic->top_page_name();
my $site_domain = $basic->site_domain();
my $data_group = $self->fetchrow_main_table({ domain => $site_domain , text => ["IS","NOT NULL"] , title => ["<>",$top_page_name] },{ ORDER_BY => ["create_time DESC"] });

my $print .= $self->data_group_to_list($data_group,{ max_view => $max_view });

$print;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub recently_list_per_category{

my $self = shift;
my $max_view = shift;
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my($print,%per_category);

my $top_page_name = $basic->top_page_name();
my $site_domain = $basic->site_domain();

my $data_group = $self->fetchrow_main_table({ domain => $site_domain , title => ["<>",$top_page_name] },{ ORDER_BY => ["create_time DESC"] });
my $per_category = $self->data_group_to_category_hash($data_group) || {};

	foreach my $category ( keys %{$per_category} ){

		my $category_name = $category || $self->other_category_name();

		my $category_url = $self->data_to_url({ domain => $site_domain , title => $category_name });
		my $category_link = $html->href($category_url,$category_name);
		my @data_group = @{$per_category->{$category}};
		my @sorted_data_group = sort { $b->{'last_modified'} <=> $a->{'last_modified'} } @data_group;

			if($category_name eq "category"){
				next;
			}

			if( my $line = $self->data_group_to_list(\@sorted_data_group,{ max_view => $max_view })  ){
				$print .= $html->tag("h3",$category_link,{ NotEscape => 1 });
				$print .= qq(<ul>$line</ul>);
			}

	}

	#if( my $line = $self->data_group_to_list($data_group,{ max_view => $max_view }) ){
	#	$print .= qq(<ul>$line</ul>);
	#}

$print;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_group_to_list{

my $self = shift;
my $data_group = shift || [];
my $use = shift;
my $html = new Mebius::HTML;
my $text = new Mebius::Text;
my($line);

	foreach my $data (@{$data_group}){

			if($self->data_to_escape_list_judge($data)){
				next;
			}

		my $character_num = $text->character_num_with_comma($data->{'text'});

		$line .= qq(<li>);
		$line .= $self->data_to_link($data);

			if($use->{'CharacterNum'}){
				#$line .= " - "  . e($character_num) . "文字";
				$line .= " ("  . e($character_num) . "文字)";

			}

		$line .= qq(</li>);

	}

$line;


}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_escape_list_judge{

my $self = shift;
my $data = shift;
my $basic = new Mebius::Wiki;
my($flag);

	if($basic->top_page_name_judge($data->{'title'}) || $data->{'deleted_flag'} || $data->{'redirect_title'} || $data->{'text'} eq ""){
		$flag = 1;
	} else {
		$flag = 0;
	}

$flag;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_group_to_category_hash{

my $self = shift;
my $data_group = shift;
my(%per_category);

	foreach my $data ( @{$data_group} ){
			if($data->{'deleted_flag'} || !$data->{'text'}){
				next;
			} else {
				push @{$per_category{$data->{'category'}}} , $data;
			}
	}

\%per_category;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub recently_list_view{

my $self = shift;
my $basic = new Mebius::Wiki;

my $print = $self->recently_list(@_);
$basic->print_html($print,{ h1 => "最近の更新" , Title => "最近の更新" });

exit;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub adjust_text_body{

my $self = shift;
my $data = shift;
my $all_text = $data->{'text'};
my $basic = new Mebius::Wiki;
my $site = new Mebius::Wiki::Site;
my $html = new Mebius::HTML;
my($my_use_device) = Mebius::my_use_device();
my(@adjusted,%start_flag,$p_start_flag,$i,$keep_mark,$keep_tag,$allow_br_flag,$hit,$ads_count,$ads_hit_border,@auto_link_keywords_for_search);

my $site_domain = $basic->site_domain();
my($param) = Mebius::query_single_param();
my @deep_tags = @{$self->deep_tags()};
my @one_line_tags = @{$self->one_line_tags()};
my @simple_tags = @{$self->between_tags()};

my $auto_link_keyword = $self->data_to_autolink_keywords($data);

$all_text =~ s/\r//g;
my @all_text = split(/\n/,$all_text);
push @all_text,undef; # テキスト末尾の終了タグのために必要

	if($my_use_device->{'smart_phone_flag'}){
		$ads_hit_border = 2;
	} else {
		$ads_hit_border = 2;
	}

my @all_text_with_all_code = @{$self->add_another_code_to_text(\@all_text)};

	if( my $chapter = $param->{'chapter'}){
		@all_text_with_all_code = $self->chapter_limited($chapter,@all_text_with_all_code);

			if(@all_text_with_all_code <= 0){
				$basic->error("章が見当たりません。");
			}

	}

	foreach my $splited_text (@all_text_with_all_code){

		my($special_line_flag,$one_line_flag,@parts);

			if($splited_text !~ /^!/ && $auto_link_keyword){
					if($splited_text =~ s/(?<!\[)($auto_link_keyword)(?!\])/[$1]/g){ 1; }
			}

		my $adjusted_text = e($splited_text);

		my $next_text = $all_text[$i+1];

		$i++;

			if($adjusted_text =~ m!^//|\#|^(:|：)!){
				next;
			}

			if($splited_text){
				$hit++;
			}

			if($keep_mark && $adjusted_text !~ /^\Q$keep_mark\E/){
				push @parts , qq(</$keep_tag>);
				$start_flag{$keep_tag} = 0;
				$keep_tag = $keep_mark = "";
			}

			foreach my $hash ( @deep_tags ){

				my $mark = $hash->{'mark'};
				my $tag = $hash->{'tag'};

					if($adjusted_text =~ s/^\Q$mark\E//){

							if(!$start_flag{$tag}){
								push @parts , qq(<$tag>);
								$start_flag{$tag} = 1;
								$keep_mark = $mark;
								$keep_tag = $tag;
							}

							if( my $inline_tag = $hash->{'inline_tag'} ){
								$adjusted_text = qq(<$inline_tag>$adjusted_text</$inline_tag>);
							}

							if($hash->{'allow_br_flag'}){
								$adjusted_text .= qq(<br>);
							}

						$special_line_flag = 1;

					}

			}

			foreach my $hash (@one_line_tags){

				my $mark = $hash->{'mark'};
				my $tag = $hash->{'tag'};
				my $count += ($adjusted_text =~ s!^$mark(.+)!<$tag>$1</$tag>!g);

					if($hash->{'chapter_link_flag'} && !$param->{'chapter'} && $param->{'title'}){
							my $chapter = $1;
							my $chapter_url = $self->data_to_chapter_url($chapter,$data);
							$adjusted_text =~ s!(<$tag>)(.+?)(</$tag>)!$1<a href="$chapter_url">$2</a>$3!;
					}

					if($count){
						$special_line_flag += $count;
						$one_line_flag += $count;
					}

			}

			foreach my $hash (@simple_tags){
				my $mark = $hash->{'mark'};
				my $tag = $hash->{'tag'};
				$adjusted_text =~ s!\Q$mark\E(.+?)\Q$mark\E!<$tag>$1</$tag>!g;
			}


			if($adjusted_text =~ s!\[\[(.+?)(\|(.+))?\]\]!$html->href($1,$3)!eg){ 1; }
			if($adjusted_text =~ s!\[(.+?)(\|.+)?\]!$self->text_to_inside_site_link($1,$2)!eg){ 1; }
			#if($adjusted_text =~ s!\[+http://([^\w\./\-]+)\]!$self->text_to_inside_site_link($1,$2)!eg){ 1; }
			if($adjusted_text =~ s!\{ads\}!$basic->adsense_box({ Label => 1 })!eg){ $special_line_flag = 1; }
			if($adjusted_text =~ s!\{recently\s?([0-9]+)?\}!$self->recently_list_per_category($1)!eg){ $special_line_flag = 1; }
			if($adjusted_text =~ s!\{allsites}!$site->all_site_links({ List => 1 , LiveSitesOnly => 1 })!eg){ $special_line_flag = 1; }


			if($ads_count <= 0 && $hit >= $ads_hit_border && $splited_text =~ /^!/){
				unshift @parts , $basic->adsense_box({ Label => 1});
				$ads_count++;
			}

			if($adjusted_text =~ s!^\+(([a-zA-Z0-9\-_]+)\.(gif|jpg|jpeg|png|bmp))!$self->image_tag($1);!gei){ $special_line_flag = 1; }

			if(!$special_line_flag && !$p_start_flag && $splited_text){
				push @parts , "<p>";
				$p_start_flag = 1;
			}

			if($p_start_flag && ($special_line_flag || $splited_text eq "")){
				unshift @parts , "</p>";
				$p_start_flag = 0;
			}

			if($p_start_flag){
				$adjusted_text = $adjusted_text . "<br>";
			}



		push @parts , $adjusted_text;
		push @adjusted , @parts;

	}


my $adjusted_all_text = join "\n" , @adjusted;

$adjusted_all_text;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_autolink_keywords{

my $self = shift;
my $data = shift;
my(@adjusted);
#my $search = new Mebius::Search;

my $keywords = $self->fetchrow_main_table({ domain => $data->{'domain'} , keyword_flag => 1 }) || [] ;

my @auto_link_keywords = sort { (split(/<>/,$b->{'title'}))[0] cmp (split(/<>/,$a->{'title'}))[0] } @{$keywords};

	foreach my $keyword_data (@auto_link_keywords){
			if($data->{'title'} eq $keyword_data->{'title'}){ next; }
		push @adjusted , $keyword_data->{'title'};
	}

my $auto_link_keyword = "(" . ( join "|" , @adjusted ) . ")" if(@adjusted);

$auto_link_keyword;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_next{

my $self = shift;
my $data = shift;
my($next_flag);

	if(!$data->{'text'}){
		$next_flag = 1;
	}

$next_flag;

}




#-----------------------------------------------------------
#
#-----------------------------------------------------------
#sub one_line_tag_judge{

#my $self = shift;
#my $text = shift;


#			foreach my $hash (@one_line_tags){

#				my $mark = $hash->{'mark'};
#				my $tag = $hash->{'tag'};
#				my $count += ($adjusted_text =~ s!^$mark(.+)!<$tag>$1</$tag>!g);

#			}

#}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub chapter_limited{

my $self = shift;
my $chapter = shift || return(@_);
my @text = @_;
my(@limited_text,$chapter_flag);


	foreach my $text (@text){
			if($chapter_flag && $text =~ /^![^!]/){
				last;
			}	elsif($text =~ /^!\Q$chapter\E/){ # ( | ) などのテキストが正規表現として扱われないように
				$chapter_flag = 1;
			}

			if($chapter_flag){
				push @limited_text , $text;
			} else {
				next;
			}

	}

@limited_text;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub image_tag{

my $self = shift;
my $file_name = shift;
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my($my_use_device) = Mebius::my_use_device();
my($print,$src,$pc_style);

my $site_domain = $basic->site_domain();

	if(Mebius::alocal_judge()){
		$src = "/picture/$site_domain/$file_name";
	} else {
		$src = "/$site_domain/$file_name";
	}

	if($my_use_device->{'smart_phone_flag'}){

	} else {
		$pc_style = "width:400px;";
	}

$print = $html->start_tag("img" , { src => $src , style => "display:block;max-width:90%;margin:1.0em 0em;$pc_style" });

$print;


}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub hit_deep_tags{

my $self = shift;
my $splited_text = shift;
my($hit_flag);

my @deep_tags = @{$self->deep_tags()};

	foreach my $hash ( @deep_tags ){

		my $mark = $hash->{'mark'};
		my $tag = $hash->{'tag'};

	}

$hit_flag;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub deep_tags{

my @tags =
(
{ mark => "*" , tag => "ul" , inline_tag => "li" } ,
{ mark => "/" , tag => "blockquote" ,  allow_br_flag => 1  } ,
{ mark => ">" , tag => "blockquote" ,  allow_br_flag => 1  } ,
{ mark => "{p}" , tag => "p" , allow_br_flag => 1  } ,

);

\@tags;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub one_line_tags{

my @tags = (
{ mark => "!!!" , tag => "h4" } ,
{ mark => "!!" , tag => "h3" } ,
{ mark => "!" , tag => "h2" , chapter_link_flag => 1 } ,
);

\@tags;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub between_tags{

my @tags =
(
{ mark => '@' , tag => "strong" } ,
{ mark => '＠' , tag => "strong" } ,
);

\@tags;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub add_another_code_to_text{

my $self = shift;
my $text = shift;
my(@added_text);

	foreach my $splited_text (@{$text}){
		push @added_text  , $splited_text;
	}

\@added_text;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub text_to_auto_keyword_tag{

my $self = shift;
my $before_text = shift;
my $title = shift;
my($return_text);

	if($before_text =~ /\[(.+?)\]/){
			$return_text = $before_text . "[$title]";
	} elsif($before_text =~ /\[/){
			$return_text = "$before_text$title";
	} else {
			$return_text = $before_text . "[$title]";
	}

$return_text;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub text_to_inside_site_link{

my $self = shift;
my $page_title = shift;
my $select_title = shift;
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my $escape = new Mebius::Escape;

$page_title = $escape->decode_html($page_title);

my $use_page_title = $select_title || $page_title;
my $site_domain = $basic->site_domain();

my $url = $self->data_to_url({ title => $page_title , domain => $site_domain });

my $text = $html->href($url,$use_page_title);

$text;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub page_edit_form{

my $self = shift;
my $data = shift;
my $use = shift;
my $basic = new Mebius::Wiki;
my $query = new Mebius::Query;
my $javascript = new Mebius::Javascript;
my $param_utf8 = $query->single_param_utf8_judged_device();
my($my_account) = Mebius::my_account();
my($my_use_device) = Mebius::my_use_device();
my $html = new Mebius::HTML;
my($print,$title,$textarea_font_size,$new_flag,$edit_flag,$autofocus,$disabled,$keyword_checked);

my $site_domain = $basic->site_domain();
my $top_page_name = $basic->top_page_name();

my $textarea = $self->data_to_textarea($data);

	if(!$basic->allow_edit()){
		return();
	}

	if($data->{'redirect_title'}){
		$disabled = 1;
	}

	if($use->{'New'}){
		$new_flag = 1;
		$title = "";
		$autofocus = 1;
	} else {
		$title = $data->{'title'} || $param_utf8->{'title'} || $top_page_name;
		$edit_flag = 1;
	}

my @all_text = split(/\n/,$data->{'text'});
my $textarea_height = @all_text + 10;
	if($textarea_height < 30){
		$textarea_height = 30;
	}

	#if($my_use_device->{'pc_flag'}){
	#	$textarea_font_size = "110%";
	#} else {
		$textarea_font_size = "110%";
	#}

$print .= $html->start_tag("form",{ method => "post" , enctype => "multipart/form-data" ,  style => "margin:1.5em 0em;" });
$print .= $html->input("hidden","mode","edit_or_create");

	if(my $category = $data->{'category'}){
		my $category_link = $self->data_to_link({ title => $category , domain => $data->{'domain'} });
		$print .= $html->start_tag("div");
		$print .= qq(カテゴリ: );
		$print .= $category_link;

		$print .= $html->close_tag("div");

	}

	if($edit_flag){
		$print .= $html->input("text","title",$title,{ style => "width:90%;font-size:160%;" });
	}

#autofocus => $autofocus ,
$print .= $html->textarea("text",$textarea,{ style => "width:98%;height:${textarea_height}em;font-size:${textarea_font_size};" , disabled => $disabled , tabindex => 1 });
$print .= $html->input("hidden","target",$data->{'target'});
$print .= $html->input("hidden","domain",$site_domain);

$print .= $html->input("submit","","送信する",{ style => "font-size:120%;margin-top:0.5em;"  , tabindex => 2 });

	if($data->{'keyword_flag'} || $new_flag){
		$keyword_checked = 1;
	}
$print .= $html->input("checkbox","keyword_flag",1,{ checked => $keyword_checked , text => "キーワード" });
$print .= " - リダイレクト先のタイトル " . $html->input("text","redirect_title",$data->{'redirect_title'});

$print .= $html->start_tag("div",{ style => "margin:1em;" });
	for my $number (1..6){
		$print .= $html->input("file","upload${number}");
	}
$print .= $html->close_tag("div");

$print .= $html->close_tag("form");

#$print .= $javascript->before_unload_use_form();

$print;



}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_textarea{

my $self = shift;
my $data = shift;

my $textarea = $self->text_to_textarea($data->{'text'},$data->{'category'});

$textarea;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub text_to_textarea{

my $self = shift;
my $text = shift;
my $category = shift;
my(@fixed_textarea);

my @textarea = split /\n/ , $text;

	foreach my $text (@textarea) {
		chomp;
			if($text =~ /^:/){
				next;
			}
		push @fixed_textarea , $text;
	}


	if($category){
		push @fixed_textarea , ":$category";
	}

my $textarea = join "\n" , @fixed_textarea;

$textarea;

#my $num = @fixed_textarea;
#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq(\n\n$num \n---\n $data->{'text'} \n---\n @fixed_textarea \n---\n $textarea)); }

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq(@fixed_textarea)); }


}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub edit_or_create_page{

my $self = shift;
my $query = new Mebius::Query;
my $basic = new Mebius::Wiki;
my $crypt = new Mebius::Crypt;
my $mebius = new Mebius;
my $upload = new Mebius::Upload;
my $category = new Mebius::Wiki::Category;
my $site = new Mebius::Wiki::Site;
my $param_utf8 = $query->single_param_utf8_judged_device();
my($new_page_title,%insert,$target,%insert_only,$data,$redirect_data_flag,@all_text_fixed);

	if(!$basic->allow_edit()){
		die("編集権限がありません。");
	}

my $use_all_text = $param_utf8->{'text'};
$use_all_text =~ s/^[\n\r\t\s]+//gi;

my $redirect_title = $param_utf8->{'redirect_title'};
my $site_domain = $basic->site_domain();
my @all_text = split(/\n/,$use_all_text);

	if( $new_page_title = $param_utf8->{'title'} ){
	} else {
		$new_page_title = shift @all_text;
		$new_page_title =~ s/^(\!|！)//g;
	}

$new_page_title =~ s/^[\n\r\s]|[\n\r\s]$//g;;


	# Edit Page
	if( $target = $param_utf8->{'target'} ){

			$data = $self->fetchrow_main_table({ target => $target })->[0];

			if($data->{'title'} && $data->{'title'} ne $new_page_title){
					$redirect_data_flag = 1;
						my $redirect_to_data = $self->fetchrow_main_table({ title => $new_page_title })->[0];
							if($redirect_to_data){
								$self->delete_record_from_main_table({ title => $new_page_title });
							}
			}

	# New Page
	} else {

		$target = $param_utf8->{'target'} || $crypt->char(30);
			if( my $still_data = $self->fetchrow_main_table({ domain => $site_domain , title => $new_page_title })->[0]){
				$basic->error("$new_page_title is still exists;");
			}
	}



	foreach my $splited_text (@all_text){
			if($splited_text =~ /^(:|：)([^\n\r]+)/){
				$insert{'category'} = $2;
			} else {
				push @all_text_fixed , $splited_text;
			}
	}

my $content_text = join "\n" , @all_text_fixed;


$insert{'category'} ||= "";

$category->update_or_create_category($site_domain,$insert{'category'});

my @uploaded = $self->query_to_upload();
	foreach my $file_name (@uploaded){
		$content_text = "+$file_name\n" . $content_text;
	}


$insert_only{'number'} = $self->new_number();

$insert{'title'} = $new_page_title || die("Page title is empty.");
$insert{'text'} = $content_text;
$insert{'target'} = $target;
$insert{'redirect_title'} = $redirect_title || "";

$insert{'domain'} = $site_domain || die("Domain is empty.");
$insert{'last_modified'} = time;

	if($param_utf8->{'keyword_flag'}){
		$insert{'keyword_flag'} = 1;
	} else {
		$insert{'keyword_flag'} = 0;
	}

	if($content_text eq "" || $redirect_title){
		$insert{'deleted_flag'} = 1;
	} else {
		$insert{'deleted_flag'} = 0;
	}


$self->update_or_insert_main_table(\%insert,"",{ insert_only => \%insert_only });
#	if(Mebius::alocal_judge()){ Mebius::Debug::print_hash(\%insert); }

	if($insert{'category'}){
		$self->category_keyword_page_ridge_flag($insert{'category'});
	}

	if($redirect_data_flag){
			$self->redirect_data($data,\%insert);
	}

$site->update_main_table({ domain => $site_domain , last_regist_time => time });

my $url = $self->data_to_url(\%insert);

Mebius::redirect($url);

exit;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub redirect_data{

my $self = shift;
my $data = shift;
my $post_data = shift;
my $basic = new Mebius::Wiki;
my $crypt = new Mebius::Crypt;
my $site_domain = $basic->site_domain();
my(%update);

my $redirect_to_data = $self->fetchrow_main_table({ title => $data->{'title'} });

$update{'target'} = $crypt->char(30);
$update{'domain'} = $site_domain;
$update{'title'} = $data->{'title'};
#$update{'text'} = $data->{'text'};
$update{'redirect_title'} = $post_data->{'title'};

$self->insert_main_table(\%update);

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub category_keyword_page_ridge_flag{

my $self = shift;
my $title = shift || return();
my(%insert,%insert_only);
my $basic = new Mebius::Wiki;
my $crypt = new Mebius::Crypt;

my $data = $self->fetchrow_main_table({ title => $title })->[0];

	if($data){
		return();
	}

$insert{'title'} = $title;
$insert{'number'} = $self->new_number();
$insert{'target'} = $crypt->char(30);
$insert{'keyword_flag'} = 1;
$insert{'category'} = "category";
$insert{'domain'} = $basic->site_domain();
#$insert{'last_modified'} = time;

$self->insert_main_table(\%insert,{ WHERE => { title => $title } });

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub new_number{

my $self = shift;
my $basic = new Mebius::Wiki;
my($new_number,$i);

my $site_domain = $basic->site_domain();

my $data_group = $self->fetchrow_main_table({ domain => $site_domain });

	foreach my $data (@{$data_group}){
		my $number = $data->{'number'};
			if($number > $new_number){
				$new_number = $number;
			}
		$i++;
	}

	if($new_number < $i){
		$new_number = $i;
	}

$new_number++;

$new_number;

}



#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub query_to_upload{

my $self = shift;
my $upload = new Mebius::Upload;
my($param) = Mebius::query_single_param();
my $crypt = new Mebius::Crypt;
my $basic = new Mebius::Wiki;
my $image = new Mebius::Image;
my $q = new CGI;
my($picture_folder,@file_name);

my $site_domain = $basic->site_domain() || return();

	if(Mebius::alocal_judge()){
		$picture_folder = "C:/Apache2.2/htdocs/picture/$site_domain/";
	} else {
		$picture_folder = "/var/www/wiki.mb2.jp/public_html/$site_domain/";
	}

Mebius::mkdir($picture_folder);

	foreach my $key ( keys %{$param}){

			if($key =~ /^upload([0-9]+)$/ && $param->{$key}){

				my $char = time . "_" . $crypt->char(10);
				my $original_file_name = $param->{$key};
				my($original_file,$tail) = split(/\./,$original_file_name);

				$tail = lc $tail;
				my $file_name = "$char.$tail";
				my $full_file_name = $picture_folder . $file_name;
				my $original_full_file_name = "$picture_folder${char}_original.$tail";

				my $file_handle = $q->param($key);

				$upload->upload($full_file_name , $file_handle);
				File::Copy::copy($full_file_name,$original_full_file_name);

				$image->auto_orient($full_file_name);
				$image->fix_max_size($full_file_name);
				$image->strip($full_file_name);

				$image->auto_orient($original_full_file_name);
				$image->strip($original_full_file_name);

				push @file_name , $file_name;

			}

	}

@file_name;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_link{

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;

my $url = $self->data_to_url($data);

my $link = $html->href($url,$data->{'title'});

$link;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $data = shift;
my $basic = new Mebius::Wiki;
my $encoding = new Mebius::Encoding;
my($url);

#my $site_domain = $basic->site_domain();
my $top_page_name = $basic->top_page_name();
my $site_url = $basic->site_base_url($data->{'domain'});
my $encoded_page_title = $encoding->encode_url($data->{'title'}) || return();

	if($top_page_name eq $data->{'title'}){
		$url = $site_url;
	} elsif(Mebius::alocal_judge() || $basic->edit_site_mode()){
		$url = "$site_url?title=$encoded_page_title";
	} else {
		$url = "$site_url$encoded_page_title/";
	}

$url;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub data_to_chapter_url{

my $self = shift;
my $chapter = shift || return();
my $data = shift || return();
my $basic = new Mebius::Wiki;
my $encoding = new Mebius::Encoding;

my($chapter_url);
my($url);

my $encoded_chapter = $encoding->encode_url($chapter) || return();
my $page_url = $self->data_to_url($data);

	if(Mebius::alocal_judge() || $basic->edit_site_mode()){
		$chapter_url = "$page_url&chapter=$encoded_chapter"
	} else {
		$chapter_url = "$page_url?chapter=$encoded_chapter"
	}

$chapter_url;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub sitemap_view{

my $self = shift;
my $basic = new Mebius::Wiki;
my $sitemap = new Mebius::Sitemap;
my(@sitemap);

my $site_domain = $basic->site_domain();
my $top_page_name = $basic->top_page_name() || die;
my $side_bar_name = $basic->side_bar_name() || die;

my $data_group = $self->fetchrow_main_table({ domain => $site_domain },{ ORDER_BY => ["last_modified DESC"] });

	foreach my $data (@{$data_group} ) {

		my $url = $self->data_to_url($data);

			if(!$data->{'text'} || $data->{'title'} =~ /^($top_page_name|$side_bar_name)$/){
				next;
			}

		push @sitemap , { url => $url , lastmod => $data->{'last_modified'} } ;
	}

$sitemap->print_sitemap(\@sitemap);

exit;

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub float_edit_form_switch{
0;
}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub other_category_name{
"その他";
}



1;
