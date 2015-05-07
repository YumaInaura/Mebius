
package Mebius::Console;
use Time::HiRes;

use strict;

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
sub console{

my $self = shift;
my $message = shift;

my($flag);

	if($self->console_judge()){
		$flag = 1;
	} else {
		return();
	}

	if($message){
		$message = ucfirst $message;

		print $message . "\n";
		Time::HiRes::sleep(0.01);
	}

$flag;

}


#-----------------------------------------------------------
# ARGV に指定されている値 (ひとつでもあれば)
#-----------------------------------------------------------
sub option{

my $self = shift;
my $need_option = shift || (warn && return());
my($flag);

	foreach my $option (@ARGV){
			if($option eq $need_option){
				$flag = 1;
			}
	}

$flag;

}


#-----------------------------------------------------------
# --point 4 のような形で「4」を得る
#-----------------------------------------------------------
sub point_option{

my $self = shift;
my $need_option = shift || (warn && return());
my($flag,$point);

	foreach my $option (@ARGV){

			if($flag){
				$point = $option;
				last;
			}

			if($option eq $need_option){
				$flag = 1;
			}

	}

$point

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub console_exit{

my $self = shift;

$self->console("Console exit.");

	if($self->console_judge()){
		exit;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub count_sleep{

my $self = shift;
my $sleep_second = shift;

	for my $second (1..$sleep_second){

		$self->console("$second / $sleep_second second sleep.");
		sleep 1;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tremor_sleep{

my $self = shift;
my $second = shift;

my @tremor_second = qw(-2 -1 0 1 2 3 5 6 7 8);

my $tremor_second = $second + $tremor_second[int rand(@tremor_second)];

	if($tremor_second <= 0){
		$tremor_second = 1;
	}

$self->count_sleep($tremor_second);


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub tremor_by_sleep{

my $self = shift;
my $second = shift;

my @tremor_by = qw(0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5);

my $tremor_second = $second * $tremor_by[int rand(@tremor_by)];

	if($tremor_second <= 0){
		$tremor_second = 1;
	}

$tremor_second = int $tremor_second;

$self->count_sleep($tremor_second);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub console_judge{

	if($ENV{'REMOTE_ADDR'}){
		0;
	} else {
		1;
	}

}

1;

