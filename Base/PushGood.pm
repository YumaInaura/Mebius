
use strict;
package Mebius::Base::PushGood;
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
sub main_limited_package_name{
"video";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"post";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub push_good{

my $self = shift;
my $target = shift || die;
my $use = shift;
my $data = $self->target_to_data($target);
my $operate = new Mebius::Operate;
my $debug = new Mebius::Debug;
my $query = new Mebius::Query;
my $device = new Mebius::Device;
my $mebius = new Mebius;
my $basic = $self->basic_object();
my($still_flag,%insert);

$mebius->axs_check();
$query->post_method_or_error();

	if(!$self->allow_push_good_judge()){
		$self->error("投票できない環境です。");
	}

my $data_group = $self->fetchrow_main_table({ relation_target => $target });
my $still_flag = $self->data_group_to_still_pushed_judge($data_group,$target);

	if($still_flag){
		$basic->error("既に投票しています。");
	}

$insert{'relation_target'} = $target;
$insert{'target'} = $self->new_target_char();

my $insert_with_connection = $device->add_hash_with_my_connection(\%insert);
$self->insert_main_table($insert_with_connection);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub cancel_good{

my $self = shift;
my $target = shift || die;
my $use = shift;
my $data = $self->target_to_data($target);
my $query = new Mebius::Query;
my $mebius = new Mebius;
my $device = new Mebius::Device;
my($my_account) = Mebius::my_account();
my $basic = $self->basic_object();
my($still_flag,%where);

$mebius->axs_check();
$query->post_method_or_error();

	if(!$self->allow_push_good_judge()){
		$self->error("投票できない環境です。");
	}

my $data_group = $self->fetchrow_main_table({ relation_target => $target });
my $still_flag = $self->data_group_to_still_pushed_judge($data_group,$target);

my %where = $device->my_user_target_on_hash();

	if(!$still_flag){
		$basic->error("投票していないのでキャンセルできません。");
	}

	if(%where){
		$self->delete_record_from_main_table(\%where ,{ OR => 1 });
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_still_pushed_judge{

my $self = shift;
my $data_group = shift || return();
my $target = shift || return();
my $device = new Mebius::Device;
my($still_flag);

	foreach my $data (@{$data_group}){

			if($data->{'relation_target'} ne $target){
				next;
			} elsif($device->data_to_myself_check($data)){
				$still_flag = 1;
				last;
			}
	}

$still_flag;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {

target => { PRIMARY => 1 }  ,
relation_target => { INDEX => 1 } , 
account => { INDEX => 1 } , 
cnumber => { INDEX => 1 } , 
host => { } , 
addr => { } , 
mobile_uid => { text => 1 } , 
create_time => { int => 1 } , 

};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub allow_push_good_judge{

my $self = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($allow_flag);

	if($my_account->{'id'}){
		$allow_flag = 1;
	} elsif($my_cookie->{'char'} && !$self->push_good_account_only()){
		$allow_flag = 1;
	}

$allow_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub push_good_mode{
1;
}

1;
