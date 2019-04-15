	
use strict;
package Mebius::Wiki::Site;
use base qw(Mebius::Base::DBI);

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
"wiki_site";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $column = {
domain => { PRIMARY => 1 } , 
title => { INDEX => 1 } , 
category => { } , 
all_page_num => { int => 1 } , 
hidden_flag => { int => 1 } ,
close_flag => { int => 1 } ,
last_regist_time => { int => 1 } , 
redirect => {} , 
};

$column;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_setting_on_array{

my $self = shift;
our($site_data_group);

#if(Mebius::alocal_judge()){ 
#$self->site_setting_script_to_dbi();
# }

	if($site_data_group){
		return($site_data_group);
	} else {
		$site_data_group = $self->fetchrow_main_table();
	}

$site_data_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_setting_on_script{

my $self = shift;

my @site = (
{ domain => "cyber-takoyaki.com" , title => "サイバー∞タコヤキ" , category => "top" } , 
{ domain => "o-ka-ne.com" , title => "お金情報" , category => "money" } , 
{ domain => "xn--obk6f7cx544a.cc" ,  title => "モテる男プロ" , category => "mote" } , 
{ domain => "mote-lady.net" ,  title => "モテる女プロ" , category => "mote" } , 
{ domain => "health-info-mation.com" , title => "健康情報局" , category => "health" } , 
{ domain => "communi-cation.com" , title => "FLAT - コミュニケーション能力向上術のための会話術・人間術 -" , category => "mote" } , 
{ domain => "nlp-labo.com" , title => "NLPっぽいもの - 人生のヒント - " , category => "mote" } , 
{ domain => "network-business-mlm.com" , title => "ネットワークビジネスの危険" , category => "money" } , 
{ domain => "call-of-duty.net" , title => "Call of duty のコツ" , category => "culture" } , 
{ domain => "fx-investment.info" , title => "初心者のためのFX投資研究" , category => "money" } , 
{ domain => "karaoke-special.com" , title => "カラオケ上達ナビ - ボイトレ方法・発声練習のコツ -" , category => "music" } , 
{ domain => "onepiece.xyz" , title => "ONE PIECE 研究所" , category => "culture" } , 
{ domain => "movie-reviews.info" , title => "映画レビュー" , category => "culture" } , 

{ domain => "mote-goukon.net" , title => "モテる！合コン術" , category => "mote" , hidden_flag => 1 } , 
{ domain => "mote-mail.com" , title => "モテる！LINE&メール術" , category => "mote" , hidden_flag => 1 } , 
{ domain => "pre-onigiri.com" , title => "コンビニおにぎり" , category => "foods" , hidden_flag => 1 } , 
{ domain => "xn--eqr886j.pw" , title => "アニメ・漫画の名言" , category => "heart" , hidden_flag => 1  } , 
{ domain => "pre-hitori.com" , title => "一人暮らしナビ" , category => "life" , hidden_flag => 1  } , 
{ domain => "pre-sinsho.com" , title => "新書まとめ" , category => "knowledge" , hidden_flag => 1  } , 
{ domain => "pre-tv.com" , title => "気になるテレビ" , category => "entertainment" , hidden_flag => 1  } , 
{ domain => "xn--t8ji0guf7hjf5b4p.com" , title => "コンビニおにぎり.net" , category => "food" , hidden_flag => 1  } , 
{ domain => "xn--mckzbuexa5f.net" , title => "ガチャポン・ガチャガチャ記念館" , category => "chara" , hidden_flag => 1  } , 
{ domain => "xn--eqr886j.cc" , title => "勇気が出る名言" , category => "heart" , hidden_flag => 1  } , 
{ domain => "xn--pckwbweube.net" , title => "リラックマ.net" , category => "chara" , hidden_flag => 1  } , 

);

	if(Mebius::alocal_judge()){
		push @site , { domain => "localhost" , title => "テストサイト" , category => "test"  };
	}

\@site;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_setting_script_to_dbi{

my $self = shift;
my $site_settings = $self->site_setting_on_script();

	foreach my $data (@$site_settings){
		$self->insert_main_table($data);
	}

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_active_domain{

my $self = shift;
my $sites = $self->site_setting_on_array();
my(@domain);

	foreach my $data(@{$sites}){
		push @domain , $data->{'domain'};
	}

\@domain;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_setting{

my $self = shift;
my $operate = new Mebius::Operate;

my $setting_on_array = $self->site_setting_on_array();

my %setting = %{$operate->array_to_hash($setting_on_array,"domain")};



\%setting;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"wiki_site";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_site_links{

my $self = shift;
my $use = shift;
my $basic = new Mebius::Wiki;
my $html = new Mebius::HTML;
my($print,@links);

	#if($use->{'PreSites'}){
	#	$sites = $self->pre_site_setting_on_array();
	#} else {
	#	$sites = $self->site_setting_on_array();
	#}

my $sites = $self->site_setting_on_array();
my $site_domain = $basic->site_domain();
my @sites_sorted = sort { $b->{'last_regist_time'} <=> $a->{'last_regist_time'} } @{$sites};

	foreach my $data ( @sites_sorted ){

		if($data->{'close_flag'}){
			next;
		} elsif($use->{'HiddenSitesOnly'} && !$data->{'hidden_flag'}){ 
			next;
		} elsif($use->{'LiveSitesOnly'} && $data->{'hidden_flag'}) {
			next;
		}

		my $domain = $data->{'domain'};
		#my $data = $sites->{$domain};

			if($use->{'category'} && $use->{'category'} ne $data->{'category'}){
				next;
			}

		my $url = $basic->site_base_url($domain);
			if($use->{'RealURL'}){
				push @links , $html->href("http://$domain/",$data->{'title'});
			} elsif($domain eq $site_domain){
				push @links , $html->tag("span",$data->{'title'});
			} else {
				push @links , $html->href($url,$data->{'title'});
			}
	}

	if($use->{'List'}){
		$print .= qq(<ul>);
			foreach(@links){
				$print .= "<li>" . $_ .  "</li>";
			}
		$print .= qq(</ul>);

	} else {
		$print = join "\n" , @links;
	}

$print;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_control{

my $self = shift;
my $basic = new Mebius::Wiki;
my($param) = Mebius::query_single_param();

	if(!$basic->allow_edit()){ die; }

	foreach my $key ( keys %{$param} ){

		my $value = $param->{$key};

			if($key =~ /^domain_([^_]+)$/){

				my(%insert);
				my $domain = $1;

				$insert{'domain'} = $domain;
				$insert{'title'} = $param->{"title_$domain"};
				$insert{'category'} = $param->{"category_$domain"};
				$insert{'redirect'} = $param->{"redirect_$domain"};

				$insert{'hidden_flag'} = $param->{"hidden_flag_$domain"};
				$insert{'close_flag'} = $param->{"close_flag_$domain"};

					if($param->{"delete_$domain"}){

						$self->delete_record_from_main_table({ domain => $domain });
					} else {
						$self->update_or_insert_main_table(\%insert);
					}

			} else {
				next;
			}


	}

	if( my $new_domain = $param->{'new_domain'}){

			if($new_domain !~ /^[0-9a-z\-\.]+$/){
				$basic->error("Domain format is strange");
			}

		my(%insert,$httpd_conf_line);

			if($new_domain =~ /^[a-z\-]+$/){
				$new_domain = "$new_domain.cyber-takoyaki.com"
			}

		$insert{'domain'} = $new_domain;
		$insert{'title'} = $param->{"new_title"};
		$insert{'category'} = $param->{"new_category"};

		$self->update_or_insert_main_table(\%insert);

	}

$self->data_group_to_httpd_config_file();

my $site_control_page_url = $self->site_control_page_url();
Mebius::redirect($site_control_page_url);

exit;

$basic->print_html("完了しました。");

exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_control_page_url{

my $self = shift;
my $basic = new Mebius::Wiki;

my $base_url = $basic->edit_mode_top_page_url();

my $url = "${base_url}?mode=site_control_view";

$url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_control_view{

my $self = shift;
my $html = new Mebius::HTML;
my $basic = new Mebius::Wiki;
my($print);

my $title = "サイトの管理";

	if(!$basic->allow_edit()){ die; }

my $data_group_main_sites = $self->fetchrow_main_table({ hidden_flag => ["<>",1] });
my $data_group_hidden_sites = $self->fetchrow_main_table({ hidden_flag => 1 });

$print .= $html->tag("h1",$title);

$print .= $html->start_tag("form",{ method => "post" });

$print .= my $submit_button = $html->input("submit","","この内容で変更する",{ style => "margin:1em;font-size:100%;" });
$print .= $html->input("hidden","mode","site_control");

$print .= $html->tag("h2","稼働中のサイト");
$print .= $self->data_group_to_control_site_form_inputs($data_group_main_sites);

$print .= $html->tag("h2","非表示のサイト");
$print .= $self->data_group_to_control_site_form_inputs($data_group_hidden_sites);

$print .= $html->start_tag("div");
$print .= $html->tag("h2","新規サイト");
$print .= $html->input("text","new_domain","",{ placeholder => "ドメイン" });
$print .= $html->input("text","new_title","",{ placeholder => "サイト名" });
$print .= $html->input("text","new_category","",{ placeholder => "カテゴリ" });

$print .= $html->close_tag("div");

$print .= $submit_button;
$print .= $html->close_tag("form");

$basic->print_html($print,{ Title => $title });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_control_site_form_inputs{

my $self = shift;
my $data_group = shift;
my $html = new Mebius::HTML;
my($print,$i);

	foreach my $data (@{$data_group}){

		$i++;

		my $domain = $data->{'domain'} || next;

		$print .= $html->start_tag("div");
		$print .= $html->input("text","domain_$domain",$domain,{ style => "font-size:100%;width:15em;" });
		$print .= $html->input("text","title_$domain","$data->{'title'}",{ style => "font-size:100%;width:20em;" });
		$print .= $html->input("text","category_$domain",$data->{'category'},{ style => "font-size:100%;" });
		$print .= $html->input("text","redirect_$domain",$data->{'redirect'},{ style => "font-size:100%;" });

		$print .= $html->input("checkbox","hidden_flag_$domain",1,{ text => "非表示" , checked => $data->{'hidden_flag'} }) ;
		$print .= $html->input("checkbox","close_flag_$domain",1,{ text => "閉鎖" , checked => $data->{'close_flag'}  });
		$print .= $html->input("checkbox","delete_$domain",1,{ text => "削除"  });

		$print .= $html->close_tag("div");

	}


$print;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_httpd_config_file{

my $self = shift;
my $new_domain = shift;
my($httpd_conf_line);

my $httpd_config_file = $self->httpd_conf_file_path();

my $data_group = $self->fetchrow_main_table();


	foreach my $data (@{$data_group}){

		my $domain = $data->{'domain'} || next;
		$httpd_conf_line .= qq(\n);
		$httpd_conf_line .= qq(<VirtualHost *:80>\n);
		$httpd_conf_line .= qq(ServerName $domain\n);
		$httpd_conf_line .= qq(DocumentRoot /var/www/wiki.mb2.jp/public_html\n);
			if($data->{'redirect'}){
				$httpd_conf_line .= qq(Redirect 301 / http://$data->{'redirect'}/\n);
			}
		$httpd_conf_line .= qq(</VirtualHost>\n\n);
	}

Mebius::Fileout("",$httpd_config_file,$httpd_conf_line);


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub httpd_conf_file_path{

my $self = shift;
my($file);
my($init_directory) = Mebius::BaseInitDirectory();

	if(Mebius::alocal_judge()){
		$file = "${init_directory}wiki_sites.conf";
	} else {
		$file = "/etc/httpd/conf/wiki_sites.conf";
	}


}



1;
