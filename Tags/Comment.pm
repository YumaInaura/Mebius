
use strict;
package Mebius::Tags::Comment;
use base qw(Mebius::Base::DBI Mebius::Tags Mebius::Base::Comment Mebius::Base::Data);
use Mebius::SNS::Account;
use Mebius::Form;
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
sub delete_to_update_relation_data{

my $self = shift;
my $data = shift;
my $init = $self->init();
my $relation_object = $self->relation_object();
my $max_tags_num = $init->{'max_tags_num_per_comment'} || die;

	for my $number (1..$max_tags_num) {
		my $tag_title = $data->{"tag$number"};
		$relation_object->update_main_table({ title => $tag_title , deleted_comment_num => ["+",1] });
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub revive_to_update_relation_data{

my $self = shift;
my $data = shift;
my $init = $self->init();
my $relation_object = $self->relation_object();
my $max_tags_num = $init->{'max_tags_num_per_comment'} || die;

	for my $number (1..$max_tags_num) {
		my $tag_title = $data->{"tag$number"};
		$relation_object->update_main_table({ title => $tag_title , deleted_comment_num => ["-",1] });
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub relation_object{

my $self = shift;
my $object = new Mebius::Tags::Tag;
$object;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"tags_comment";
}


#-----------------------------------------------------------
# テーブルのカラム設定
#-----------------------------------------------------------
sub main_table_column{

my $column = {

target => { PRIMARY => 1 } , 
text => { text => 1 } , 

tag1 => { INDEX => 1 } , 
tag2 => { INDEX => 1 } , 
tag3 => { INDEX => 1 } , 

label1 => {} , 
label2 => {} , 
label3 => {} , 

font_color => { } ,
handle => { } , 
account => { INDEX => 1 } , 
addr => { } , 
host => { } , 
cnumber => { INDEX => 1 } , 
mobile_uid => { } , 
user_id => {} , 

good_num => { int => 1 } , 
good_accounts => { text => 1 } ,
good_cnumbers => { text => 1 } ,
good_addrs => { text => 1 } ,

deleted_flag => { int => 1 } ,
penalty_flag => { int => 1 } , 

create_time => { int => 1 ,  INDEX => 1  } , 
last_update_time => { int => 1 } ,

};

$column;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub one_comment_view{

my $self = shift;
my $target = shift;
my($print);

my $data = $self->target_to_data($target);

my($subject_fillter_error) = Mebius::Fillter::fillter_and_error($data->{'title'});

$print = $self->data_to_line($data);

$self->print_html($print);

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub 	w{

my $self = shift;
my($print);

my $title = "自分の更新";

$print .= $self->my_history_line({ max_view => 50 });
$print = $self->around_control_form($print);
$print .= $self->push_good_javascript();

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($print)); }

$self->print_html($print,{ Title => $title , h1 => $title , BCL => [$title] });

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_history_line{

my $self = shift;
my($my_account) = Mebius::my_account();
my $device = new Mebius::Device;
my $sns_account = new Mebius::SNS::Account;
my(%where);

	if(%where = $device->my_user_target_on_hash_only({})){

	} else {
		return();
	}

my $data_group = $self->fetchrow_main_table(\%where,{ Debug => 0 });
my $data_group_with_account_handle = $sns_account->add_handle_to_data_group($data_group);
my @sorted_data_group = sort { $b->{'create_time'} <=> $a->{'create_time'} } @{$data_group_with_account_handle};

my $print = $self->data_group_to_line(\@sorted_data_group,{ max_view => 50	 });


$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub time_line{

my $self = shift;
my $sns_account = new Mebius::SNS::Account;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my $tag = $self->tag_object();
my $follow = $self->follow_object();
my $init = $self->init();
my($line,%target,@query,$my_commented_data_group,$hit,%select);

my $max_tags_num = $init->{'max_tags_num_per_comment'} || die;
my $my_follow_tag_kinds = $follow->my_follow_tag_kinds() || {};

	for my $number (1..$max_tags_num) {

		my(@IN);

			foreach my $tag_name ( keys %{$my_follow_tag_kinds} ){
				push @IN , $tag_name;
			}

			if(@IN){
				$select{"tag$number"} = ["IN",\@IN];
			}
	}

	if(!%select){
		return();
	}

my $border_time = time - 30*24*60*60;

my $time_line_comment_data_group = $self->fetchrow_main_table([\%select,{ create_time => [">",$border_time] } ],{ Debug => 0  });
my $data_group_with_account_handle = $sns_account->add_handle_to_data_group($time_line_comment_data_group);

my @sorted_data_group = sort { $b->{'create_time'} <=> $a->{'create_time'} } @{$data_group_with_account_handle};

$line = $self->data_group_to_line(\@sorted_data_group,{ max_view => 50 });

$line;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub form{

my $self = shift;
my $tag_data = shift;
my $use = shift;
my $form = new Mebius::Form;
my $html = new Mebius::HTML;
my $page_back = new Mebius::PageBack;
my $query = new Mebius::Query;
my($my_cookie) = Mebius::my_cookie_main_utf8();
my($my_account) = Mebius::my_account();
my $param_utf8 = $query->single_param_utf8_judged_device();
my($textarea_inputed,$print);

my $tags_cookie = Mebius::Cookie::get("tags");
my $color_selects = $form->color_select_box();

	if($tag_data->{'lock_flag'}){
		return();
	}

	if($tag_data->{'title'}){
			if( my $label_param = $self->label_param()){
				$textarea_inputed = "#$tag_data->{'title'}/$label_param ";
			} else {
				$textarea_inputed = "#$tag_data->{'title'} ";
			}
	} elsif($tags_cookie){

		my @tags;
			foreach my $tag_name (split(/\s/,$tags_cookie->{'last_commented_tag'})){
				push @tags , "#$tag_name";
			}
		$textarea_inputed = join " " , @tags;
		$textarea_inputed .= " ";
	}

$print .= $html->start_tag("div",{ style => "width:100%;max-width:20em;"  });

$print .= $html->start_tag("form",{ method => "post" });

$print .= $html->input("hidden","mode","comment");
$print .= $html->input("hidden","tag_name",$param_utf8->{'directory1'});

	#if( my $tag_title = $tag_data->{'title'}){
	#	$print .= $html->input("hidden","tag_name",$tag_title);
	#}

	if(!$my_account->{'login_flag'}){
		$print .= $html->input("text","name",$my_cookie->{'name'},{ placeholder => "ハンドルネーム" , style => "width:100%;" });
	}

$print .= qq(<br>);
$print .= $html->textarea("comment",$textarea_inputed,{ placeholder => "タグをつけてコメントしてください　例) #ドラマ " , style => "width:100%;height:8em;" });

$print .= qq(<br>);
#$print .= $html->input("text","tag","#$tag_data->{'title'}",{ placeholder => "タグ" , style => "width:100%;" });

$print .= $page_back->input_hidden();

$print .= $html->start_tag("div",{ class => "right" });

$print .= $html->input("submit","","コメントする",{ class => "isubmit" });
$print .= $color_selects;

$print .= $html->close_tag("div");

$print .= $html->close_tag("form");


$print .= $html->close_tag("div");

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_line{

my $self = shift;
my $data_group = shift;
my $use = shift;
my $init = $self->init();
my $max_tags_num = $self->max_tags_num();
my($line,$hit);

	foreach my $data (@{$data_group}) {

		if( my $label_name = $use->{'label'}){
			my($flag);
				for my $number (1..$max_tags_num){
						if($data->{"label$number"} eq $label_name){
							$flag = 1;
						}
				}

				if(!$flag){
					next;
				}
		}

		if($use->{'max_view'} && $hit >= $use->{'max_view'}){
			last;
		} elsif( my $data_line .= $self->data_to_line($data,{ hit => $hit })){
			$hit++;
			$line .= $data_line;
		}
	}

$line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_label_kind{

my $self = shift;
my $data_group = shift;
my $init = $self->init();
my(@label,%label);

	foreach my $data (@{$data_group}) {

			for my $number (1..$init->{'max_tags_num_per_comment'}){

				my $label_name = $data->{"label$number"};

					if($label{$label_name}){
						next;
					} elsif($label_name){
						$label{$label_name} = 1;
						push @label , { label => $label_name , tag => $data->{"tag$number"} } ;
					} else {
						0;
					}


			}

	}

\@label;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_label_links{

my $self = shift;
my $data_group = shift;
my $html = new Mebius::HTML;
my $tag = $self->tag_object();
my($param) = Mebius::query_single_param();
my $label_kind = $self->data_group_to_label_kind($data_group);
my $label_split_mark = $self->label_split_mark();
my($print);

	foreach my $label_data (@{$label_kind}){
		my $label_name = $label_data->{'label'};
		my $label_url = $tag->label_url($label_data->{'tag'},$label_name);
			if($param->{'directory2'} eq $label_name){
				$print .= $html->tag("span","$label_split_mark$label_name") . " ";	
			} else {
				$print .= $html->href($label_url,"$label_split_mark$label_name") . " ";	
			}
	}

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub comment_effect{

my $self = shift;
my $comment = shift;
my $comment_text = $self->tag_auto_link($comment);
$comment_text;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_comment{

my $self = shift;
my $tag = $self->tag_object();
my $follow = $self->follow_object();
my $query = new Mebius::Query;
my $device = new Mebius::Device;
my $crypt = new Mebius::Crypt;
my $text = new Mebius::Text;
my $cookie = new Mebius::Cookie;
my $page_back = new Mebius::PageBack;
my $text = new Mebius::Text;
my $regist = new Mebius::Regist;
my $mebius  = new Mebius;
my $cookie = new Mebius::Cookie;
my($my_account) = Mebius::my_account();
my $param_utf8 = $query->single_param_utf8_judged_device();
my $init = $self->init();
my(%insert,$tags,$tags_num,$hit,%update_tags);
my $max_tags_num = $init->{'max_tags_num_per_comment'} || die("Init is not enough. please setting max tags num.");

$mebius->axs_check();

my $new_comment = $text->fullsize_to_halfsize($param_utf8->{'comment'});
$new_comment =~ s/＃/#/g;
my $new_target = $insert{'target'} = $crypt->char(30);

$self->create_comment_common_error();

my $new_handle = $insert{'handle'} = $self->new_handle($param_utf8->{'name'});

my $comment_withour_tags = $self->delete_tags_and_labels($new_comment);
	if($text->character_num($comment_withour_tags) < 3){
		$self->regist_error("文字数が少ないです。タグ以外にもコメントをつけてください。");
	} elsif($text->character_num($new_comment) > 2000){
		$self->regist_error("文字数が多すぎます。");
	}

	if($tags = $self->to_tags_and_labels($new_comment)){

		$tags_num = keys %{$tags};

	} else {

			#$new_comment = "$new_comment #タグなし";
			#$tags = $self->to_tags_and_labels($new_comment);
			#$tags_num = keys %{$tags};

		$self->regist_error("1個以上のタグを付けてコメントして下さい。 # の後に文字を続けるとタグになります。 例) #メビウスリング ");
	}

	if( $tags_num > $max_tags_num){
		$self->regist_error("タグの数が多すぎます [${tags_num}個/${max_tags_num}個]");
	}

	foreach my $tag_name ( keys %{$tags} ){

		$hit++;

		$insert{"tag$hit"} = $tag_name;
		$insert{"label$hit"} = $tags->{$tag_name}->{'label'};

		my $tag_data = ($tag->fetchrow_main_table({ title => $tag_name },{ Debug => 0 }))->[0];
		my $tag_exists = $tag_data;

			if($tag_exists && $tag_data->{'deleted_flag'}){

				$self->regist_error(e("#$tag_name").qq( は削除済みのため、タグとして使えません。));

			} elsif($tag_exists){

				$update_tags{$tag_name} = 1;

			} else {

					if(my $error = $tag->create_tag_error_message($tag_name)){
						$self->regist_error($error);
					} else {

						$tag->create_tag($tag_name);

					}

			}

		$follow->create_follow($tag_name,{ UseTagTitle => 1 });

		my %insert_for_history = ( content_targetA => $tag_name , last_response_target => $new_target , last_response_num =>  $tag_data->{'comment_num'}+1 , subject => "#$tag_name" , last_account => $my_account->{'id'} , last_handle => $new_handle );

			if($tag_exists){
				$tag->create_common_history_on_comment(\%insert_for_history);
			} else {
				$tag->create_common_history_on_post(\%insert_for_history);
			}

	}

	foreach my $tag_name (keys %update_tags){
		$tag->update_main_table({ title => $tag_name , last_modified => time , comment_num => ["+",1] });
	}

$insert{'text'} = $new_comment;
$insert{'font_color'} = $regist->param_to_font_color();

my $adjusted_insert = $device->add_hash_with_my_connection(\%insert);

$self->insert_main_table($adjusted_insert);

$cookie->param_to_set_cookie_main();

my $tags_array =	$self->to_tags_and_labels($new_comment,{ ReturnArray => 1 }) || [];

Mebius::Cookie::set("tags",{ last_commented_tag => "@{$tags_array}" } );

$page_back->redirect() || $self->print_html("実行しました。");

exit;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub to_tags_and_labels{

my $self = shift;
my $comment = shift;
my $use = shift;
my(%tags,@tags_array);
my $label_split_mark = $self->label_split_mark();

$comment =~ s/　/ /g;

	while($comment =~ s/(?<!&)#([^\s${label_split_mark}]+)(${label_split_mark}([^\s${label_split_mark}]+))?//){
		my $tag = $1;
		my $label = $3 if($3);

			if($label){
				$tags{$tag}{'label'} = $label;
			}

			if(!$tags{$tag}{'exists'}++){
				push @tags_array , $tag;
			}

	}

	if($use->{'ReturnComment'}){
		return $comment;
	} elsif($use->{'ReturnArray'}){
		return \@tags_array;
	} elsif(%tags){
		\%tags;
	} else {
		return;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_tags_and_labels{

my $self = shift;
my $comment = shift;

my $tag_deleted_comment = $self->to_tags_and_labels($comment,{ ReturnComment => 1 });

$tag_deleted_comment;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"comment";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub japanese_label{
"コメント";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub regist_error{

my $self = shift;
my $error = shift;
my($param) = Mebius::query_single_param();
my $tag = $self->tag_object();

	if( my $tag_title = $param->{'tag_name'}){
			$tag->tag_view($tag_title,undef,{ form_error => $error });
	} else {
		$self->top_page_view({ comment_form_error => $error });
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
#sub add_report_data{

#my $self = shift;
#my $target = shift;
#my $tag = $self->tag_object();
#my(%report);

#my $data = $self->target_to_data($target);
#my $tag_data = $tag->target_to_data($data->{'tag_target'});

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($data->{'tag_target'})); }

#$report{'targetB'} = $tag_data->{'target'};
#$report{'targetC'} = $target;

#\%report;

#}

1;

