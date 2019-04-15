
use strict;

use Mebius::Query;

package Mebius::Mixi::Message;
use Mebius::Mixi::Message::Log;
use Mebius::Mixi::Message::Task;
use Mebius::Mixi::Message::Send;
use Mebius::Mixi::Message::Page;

use Mebius::Query;

use base qw(Mebius::Base::DBI Mebius::Base::Data);

use Mebius::Export;

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $query = new Mebius::Query;
my $param  = $query->param();
my $send = new Mebius::Mixi::Message::Send;
my $task = new Mebius::Mixi::Message::Task;
my($flag);

	if($ARGV[0] eq "send_message"){
		$send->doing();
	} elsif($param->{'mode'} ne "message"){
		return;
	}

 if($param->{'type'} eq "task"){
		$flag = 1;
		$task->per_page();
	} elsif($param->{'type'} eq "create_task"){
		$flag = 1;
		$task->create();
	} else {
		$flag = 1;
		$task->page();
	}

return $flag;

}


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
sub basic_object{

my $self = shift;
my $object = new Mebius::Mixi;

$object;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {
target => { PRIMARY => 1 } ,
create_time => { int => 1 } ,
account => { INDEX => 1 } ,
email => { } , 
result => { } , 

};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
return "mixi_message";
}

1;

