
use strict;
package Mebius::Tags::Follow;
use base qw(Mebius::Base::DBI Mebius::Base::Data Mebius::Tags);
#use Mebius::Export;

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
"tags_follow";
}


#-----------------------------------------------------------
# テーブルのカラム設定
#-----------------------------------------------------------
sub main_table_column{

my $column = {

target => { PRIMARY => 1 } , 
tag_target => {} , 
tag_title => {} ,
label => {} , 

access_target => { INDEX => 1 } ,
access_target_type => { INDEX => 1 } ,

create_time => { int => 1 , INDEX => 1 } , 

};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_to_follow{

my $self = shift;
my $query_name = shift || return();

my $main_limited_package_name = $self->main_limited_package_name();
my $limited_package_name = $self->limited_package_name();

	if($query_name =~ /^${main_limited_package_name}_${limited_package_name}_follow_([^_]+)$/){
		my $tag_target = $1;
		$self->create_follow($tag_target);
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_follow{

my $self = shift;
my $tag_target = shift || (warn && return());
my $use = shift;
my $tag = $self->tag_object();
my $crypt = new Mebius::Crypt;
my $device = new Mebius::Device;
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my(%insert,$tag_data);

	if(!$self->allow_follow()){
		return();
	}

	if($use->{'UseTagTitle'}){
		$tag_data = $tag->fetchrow_main_table({ title => $tag_target })->[0];
		$insert{'tag_target'} = $tag_data->{'target'};
		$insert{'tag_title'} = $tag_target;
	} else {
		$tag_data = $tag->fetchrow_main_table({ target => $tag_target })->[0];
		$insert{'tag_target'} = $tag_target;
		$insert{'tag_title'} = $tag_data->{'title'};
	}

my %where = %insert = $device->add_hash_with_access_target(\%insert);

	if( my $still_follow = $self->fetchrow_main_table(\%where)->[0]){
		return();
	}

$insert{'target'} = $crypt->char(30);


my $adjusted_insert = $device->add_hash_with_my_connection(\%insert);

$self->insert_main_table($adjusted_insert);

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_to_unfollow{

my $self = shift;
my $query_name = shift || return();

my $main_limited_package_name = $self->main_limited_package_name();
my $limited_package_name = $self->limited_package_name();

	if($query_name =~ /^${main_limited_package_name}_${limited_package_name}_unfollow_([^_]+)$/){
		my $tag_target = $1;
		$self->unfollow($tag_target);
	}

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub follow_or_unfollow_button{

my $self = shift;
my $tag_data = shift || warn;
my $device = new Mebius::Device;
my($my_account) = Mebius::my_account();
my(%where,$button);

$where{'tag_target'} = $tag_data->{'target'};
%where = $device->add_hash_with_access_target(\%where);

my $data = $self->fetchrow_main_table(\%where)->[0];

	if($data){
		$button = $self->unfollow_button($tag_data);
	} else {
		$button = $self->follow_button($tag_data);
	}

$button;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub unfollow{

my $self = shift;
my $tag_target = shift || (warn && return());
my $device = new Mebius::Device;
#my($my_cookie) = Mebius::my_cookie_main();
my($my_account) = Mebius::my_account();
my $tag = $self->tag_object();
my(%where);

	if(!$my_account->{'login_flag'}){
	#	return();
	}

#my $tag_data = $tag->fetchrow_main_table({ target => $tag_target , account => $my_account->{'id'} })->[0];

	if(%where = $device->add_hash_with_access_target({})){
		$where{'tag_target'} = $tag_target;
	} else {
		return();
	}

$self->delete_record_from_main_table(\%where);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub follow_button{

my $self = shift;
my $tag_data = shift;
my $html = new Mebius::HTML;
my($my_account) = Mebius::my_account();
my($button,%class);

#my $label_param = $self->label_param();
	if($self->allow_follow()){
		$class{'style'} = "background:#77f;border:solid 1px #00f;font-weight:bold;color:#fff;border-radius: 4px;padding:0.3em 0.8em;";
	} else {
		$class{'disabled'} = 1;
	}

$button = $html->input("submit","tags_follow_follow_$tag_data->{'target'}","このタグをフォローする",\%class);

$button;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub unfollow_button{

my $self = shift;
my $tag_data = shift;
my $html = new Mebius::HTML;
my($button,%class);

#my $label_param = $self->label_param();
$class{'style'} = "background:#f77;border:solid 1px #f00;font-weight:bold;color:#fff;border-radius: 4px;padding:0.3em 0.8em;";

$button = $html->input("submit","tags_follow_unfollow_$tag_data->{'target'}","フォローを解除する",\%class);

$button;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_follow_tag_kinds{

my $self = shift;
my($my_account) = Mebius::my_account();
my(%target);

	if(!$self->allow_follow()){
		return();
	}

my $my_follow_data_group = $self->my_follow_data_group();

	foreach my $data (@{$my_follow_data_group}){
		$target{$data->{'tag_title'}} = 1;
	}

\%target;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_follow_tag_links{

my $self = shift;
my $sns = new Mebius::SNS;
my $html = new Mebius::HTML;
my $data_group = $self->my_follow_data_group_state();
my $tag = $self->tag_object();
my($my_account) = Mebius::my_account();
my($print);

	#if($my_account->{'login_flag'}){
		$print = $tag->data_group_to_list($data_group);
	#} else {
	#	$print = "フォローの一覧を使うには". $sns->please_login_link();
	#}

	if(!$my_account->{'login_flag'} && $print){
		$print .= $html->start_tag("div",{ class => "size90 green" });
		$print .= qq(*履歴はCookieに保存しています。永久保存するには );
		$print .= $sns->please_login_link();
		$print .= $html->close_tag("div");
	}

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($data_group->[0]->{'tag_title'})); }


$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_follow_data_group_state{

my $self = shift;

my $HereName1 = "my_follow_data_group_state";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1);
	if(defined $state){ return($state); }

my $data_group = $self->my_follow_data_group();

	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,"",$data_group); }

$data_group;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_follow_data_group{

my $self = shift;
my $device = new Mebius::Device;
my($my_follow_data_group,%where);

	if( %where = $device->add_hash_with_access_target({})){
		$my_follow_data_group = $self->fetchrow_main_table(\%where);
	} else {
		return();
	}


$my_follow_data_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_account_tag_links{


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"follow";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub allow_follow{
"1";
}



1;
