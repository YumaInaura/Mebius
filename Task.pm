	
package Mebius::Mixi::Task;

use strict;
use Mebius::Time;

use Mebius::Export;
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
sub main_table_name{
"mixi_task";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {
target => { PRIMARY => 1 } ,
create_time => { int => 1 } , 
task_type => { } , 
next_time => { int => 1 } , 
lock_time => { int => 1 } ,
};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub allow_task_judge{

my $self = shift;
my $task_name = shift || die;
my $console = new Mebius::Console;
my($allow_flag);

my $data = my $data_exists = $self->fetchrow_main_table({ task_type => $task_name })->[0];
my $left_time = $data->{'next_time'} - time;
my $lock_left_time = $data->{'lock_time'}+30*60 - time;

	if($console->option("--no-interval")){
		console "Task: No interval mode.";
		$allow_flag = 1

	} elsif($lock_left_time >= 1){

		$allow_flag = 0;
		console "Task: $task_name is locked. $lock_left_time time wait please.";

	} elsif(time >= $data->{'next_time'}){

		$allow_flag = 1;
		console "Task: $task_name is allowed to start.";
		console "I locked this task while doing.";

	} else {
		$allow_flag = 0;
		console "Task: Please wait $left_time seconds for $task_name.";
	}

	if($allow_flag){
			if($data_exists){
				$self->update_main_table_where({ lock_time => time },{ task_type => $task_name });
			} else {
				$self->insert_main_table({ task_type => $task_name , lock_time => time });
			}
	}

$allow_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub unlock{

my $self = shift;
my $task_type = shift || die;

$self->update_main_table_where({ lock_time => 0 },{ task_type => $task_type });
console "Task: Unlock $task_type. ";

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub wait_time{

my $self = shift;
my $task_name = shift || die;

my $data = $self->fetchrow_main_table({ task_type => $task_name })->[0];

my $left_time = $data->{'next_time'} - time if($data->{'next_time'});

	if($left_time >= 1){
		console "Task: For $task_name wait $left_time seconds.	";
	} else {
		$left_time = 0;
	}

$left_time;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_next_time_tremor{

my $self = shift;
my $task_name = shift || die;
my $interval_second = shift || die;
my $times = new Mebius::Time;

my $tremor_interval_second = $times->tremor($interval_second);
my $next_time = time + $tremor_interval_second;

my $data = $self->fetchrow_main_table({ task_type => $task_name })->[0];

console "Task: $task_name was finished. Next interval is $tremor_interval_second seconds.	";

	if($data){
		$self->update_main_table({ target => $data->{'target'} , task_type => $task_name  , next_time => $next_time , lock_time => 0 });

	} else {
		$self->insert_main_table({ task_type => $task_name , next_time => $next_time });
	}


}


1;