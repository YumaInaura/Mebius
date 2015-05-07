
use strict;
package Mebius::Mixi::Account::Useful;
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
sub random_limited_account_email{

my $self = shift;
$self->random_limited_account_data()->{'email'};

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub random_limited_account_data{

my $self = shift;

my $data_group = $self->fetchrow_main_table({ account_type => "limited" , nickname => ["IS","NOT NULL"]  ,status => ["IS","NULL"]  }); #, name => ["IS","NOT NULL"]

my @shuffled = List::Util::shuffle @{$data_group};

my $random_account = $shuffled[0];

$random_account;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_useful_account_data_group{

my $self = shift;
my $mixi_account = new Mebius::Mixi::Account;

my %fetch = (
account_type => "main" , 
account => ["IS","NOT NULL"] , 
friend_num => [">=",1] , 
last_action_time => ["<",time-24*60*60] , 
status => ["IS","NULL"] , 
last_login_missed_time => 0 , 
try_time => ["<",time-1*60*60] ,
owner => "Navitomo" , 
);


 

my $data_group = $mixi_account->fetchrow_main_table_asc(\%fetch,"last_action_time");

$data_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_account_and_try{

my $mixi_account = new Mebius::Mixi::Account;

my $self = shift;
my $account_data = $self->main_useful_account_data();

$mixi_account->update_main_table({ target => $account_data->{'target'} , try_time => time });

return $account_data;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_useful_account_data{

my $self = shift;
my $data_group = $self->main_useful_account_data_group(@_);

$data_group->[0];

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub random_main_account_data{

my $self = shift;

my $data_group = $self->fetchrow_main_table({ account_type => "main" });

my $data = $data_group->[int rand(@{$data_group})];

$data;

}





#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub forview_account_data_group{

my $self = shift;
my $basic = $self->basic_object();
my $mixi_account = new Mebius::Mixi::Account;

my $data_group = $mixi_account->fetchrow_main_table({
account_type => "view" ,
deleted_flag => 0 ,
status => ["IS","NULL"]
});

$data_group;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub forview_account_data{

my $self = shift;

my $data_group = $self->forview_account_data_group();

my $data = $data_group->[int rand(@{$data_group})];

$data;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_account_data_group{

my $self = shift;
my $free_fetch = shift || {};
my $basic = $self->basic_object();
my $mixi_account = new Mebius::Mixi::Account;

my %fetch = (
account_type => "limited" , 
deleted_flag => 0 ,
nickname => ["IS","NOT NULL"] , 
status => ["IS","NULL"] , 
keep_job => ["IS","NULL"] ,
last_action_time => ["<",time-14*24*60*60] , 
last_failed_time => ["<",time-1*60*60] , 
temporary_block_time => ["<",time-30*24*60*60] ,
try_time => ["<",time-1*60*60] ,
owner => "Navitomo" , 
);

#last_action_time => ["<",time-30*24*60*60] , 

%fetch = (%fetch,%{$free_fetch});

#friend_num => [">=",1] , 

my $data_group = $mixi_account->fetchrow_main_table_asc(\%fetch ,"last_action_time") || [];

	if(@{$data_group} <= 0){
		my $message = "No useful accounts found.";
		$basic->failed_log("",$message);
		#$basic->print_html($message);
	}


my $num = @{$data_group};
console "$num USEFUL ACCOUNTS FOUND.";

$data_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_account_judge{

my $self = shift;
my $data = shift;
my($useful_flag);

	if(ref $data ne "HASH"){
		die("Please hand account_data on hash reference.");
	}

	if($data->{'status'}){
		$useful_flag = 0;
	} elsif($data->{'account_type'} ne "limited"){
		$useful_flag = 0;
	} elsif(time < $data->{'last_action_time'} + 1*24*60*60){
		$useful_flag = 0;
	} elsif(time < $data->{'temporary_block_time'} + 7*24*60*60){
		$useful_flag = 0;
	} else {
		$useful_flag = 1;
	}

$useful_flag;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_account_data{

my $self = shift;
my $data_group = $self->useful_account_data_group();

#my $data = $data_group->[0];
my $data = $data_group->[int rand(@{$data_group})];

$data;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_account_data_and_try{

my $mixi_account = new Mebius::Mixi::Account;

my $self = shift;
my $account_data = $self->useful_account_data();

$mixi_account->update_main_table({ target => $account_data->{'target'} , try_time => time });

return $account_data;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_account_data_random{

my $self = shift;
my $data_group = $self->useful_account_data_group();

my $data = $data_group->[int rand @{$data_group}];

$data;

}


1;