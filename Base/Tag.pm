
use strict;
package Mebius::Base::Tag;
use Mebius::Base::TagList;
use Mebius::Operate;
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
"tag";
}

#-----------------------------------------------------------
# カラム名
#-----------------------------------------------------------
sub main_table_column{

my $column = {

target => { PRIMARY => 1  } ,
relation_target => { INDEX => 1 } , 
title => { INDEX => 1 } ,
account => { INDEX => 1 } ,
handle => { } ,
addr => { } ,
host => { text => 1 } , 
create_time => { int => 1 } , 
};

$column;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub self_view{

my $self = shift;
my($param) = Mebius::query_single_param();
my $basic = $self->basic_object();
my $tag_list = $self->tag_list_object() || die("Please set tag_list opject, on original module file.");
my $relation_object = $self->relation_object() || die("Please set relation opject, on original module file.");
my($print,%relation,@relation_target);

my $tag_name = $param->{'tag'};
my $page_title = "#" . $param->{'tag'};

my $tag_data_group = $self->fetchrow_main_table({ title => $tag_name });

my $tag_list_data = $tag_list->fetchrow_main_table({ title => $tag_name })->[0];
$print .= $self->data_to_page_error($tag_list_data);
$print .= $tag_list->data_to_line($tag_list_data);


	foreach my $data (@{$tag_data_group}){
		my $relation_target = $data->{'relation_target'};

			if($relation{$relation_target}++){
				next;
			} else {
				push @relation_target , $relation_target;
			}
	}

my $relation_data_group = $relation_object->fetchrow_main_table({ target => ["IN",\@relation_target] });
$print .= $relation_object->data_group_to_list($relation_data_group);

$print = $tag_list->around_control_form($print);

#$print .= $self->data_to_control_parts($data);


$basic->print_html($print,{ h1 => $page_title , Title => $page_title , BCL => [$page_title]  });

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub relation_data_to_list{

my $self = shift;
my $data = shift || return();
my $html = new Mebius::HTML;
my $operate = new Mebius::Operate;
my $tag_list = $self->tag_list_object() || die;
my($print);

my $data_group = $self->fetchrow_main_table({ relation_target => $data->{'target'} });

my @tag = $operate->hash_in_array_ref_to_array($data_group,"title");
my $tag_list_data_group = $tag_list->fetchrow_main_table({ title => ["IN",\@tag] , deleted_flag => 0 });

	foreach my $data (@{$tag_list_data_group}){
		$print .= $self->data_to_link($data) . "\n";
	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{


my $self = shift;
my $data = shift || return();
my $encoding = new Mebius::Encoding;
my $basic = $self->basic_object();
my $site_url = $basic->site_url();
my($url);

my $site_url = $basic->site_url();
my $super_encoded_tag_name = $encoding->encode_url($data->{'title'}) || return();

$url = "${site_url}?tag=$super_encoded_tag_name";

$url;


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_submit_tags{

my $self = shift;
my $text = shift || die;

my @new_tag = $self->text_to_tags($text);

$self->text_to_submit_tags_core(\@new_tag,@_);
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_splited_space_to_submit_tags{

my $self = shift;
my $text = shift || die;

my @new_tag = $self->text_splited_space_to_tags($text);

$self->text_to_submit_tags_core(\@new_tag,@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_submit_tags_core{

my $self = shift;
my $new_tag = shift || return();
my $post_data = shift || die;
my $tag_list = $self->taglist_object();
my(@all_insert);


	foreach my $tag (@{$new_tag}){

			if(length $tag > 255){ next; }
		my(%insert);
		$insert{'target'} = $self->new_target_char();
		$insert{'relation_target'} = $post_data->{'target'} || die;
		$insert{'title'} = $tag;
		push @all_insert , \%insert;
	}

$self->insert_main_table(\@all_insert);

$tag_list->tag_names_to_update_or_insert($new_tag);


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_tags{

my $self = shift;
my $text = shift;
my(@tag,%kind);

	while($text =~ s/(?:＃|#)([^\s\n\r#]+)//){
		my $tag = $1;
		$tag =~ s/　//g;
			if($kind{$tag}++){
				next;
			}
		push @tag , $tag;
	}

@tag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_splited_space_to_tags{

my $self = shift;
my $text = shift;
my(@tag,%kind);

$text =~ s/\r//g;

	foreach my $tag (split(/,|　|\s|\n/,$text)){
		$tag =~ s/　|[\s\r\0\t]//g;
			if(!$tag){ next; }
			if($kind{$tag}++){
				next;
			}
		push @tag , $tag;
	}

@tag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_tags_with_marks{

my $self = shift;
my $text = shift;

my @tag = $self->text_to_tags($text);

@tag = map { $_ = "#$_"; } @tag;

my $print = join " " , @tag;

$print;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift || return();
my $use = shift || {};
my $html = new Mebius::HTML;
my($my_account) = Mebius::my_account();
my($line,$style);

my $url = $self->data_to_url($data);
my $full_title = $data->{'title'} || return();
$full_title = "#" . $full_title;
my $tag_num = $data->{'tag_num'};

	if($tag_num >= 5){
		$style = "font-size:125%;";
	} elsif($tag_num >= 10){
		$style = "font-size:150%;";
	} elsif($tag_num >= 15){
		$style = "font-size:175%;";
	} elsif($tag_num >= 20){
		$style = "font-size:200%;";
	}

$line .= $html->href($url,$full_title,{ style => $style });

	if($data->{'deleted_flag'}){
		$line .= " " . $html->tag("span","[削除]",{ class => "red" });
	}

$line .= "\n";

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub japanese_label{
"タグ";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub relation_object{}
sub tag_list_object{}


1;