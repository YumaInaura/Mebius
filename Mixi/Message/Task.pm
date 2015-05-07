
use strict;

use Mebius::Mixi::Message;
package Mebius::Mixi::Message::Task;

use Mebius::HTML;

use base qw(Mebius::Base::DBI Mebius::Base::Data);

use Mebius::Export;

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create{

my $self = shift;
my $basic = $self->basic_object();
my($print,%update);
my $query = new Mebius::Query;
my $param  = $query->param();

$update{'subject'} = $param->{'subject'};
$update{'body'} = $param->{'body'};
$update{'to_account'} = $param->{'to_account'};
$update{'create_time'} = time;

	if($param->{'target'}){
		$update{'target'} = $param->{'target'};
		$update{'deleted_flag'} = $param->{'delete'} ? 1 : 0;
		$self->update_main_table(\%update);
	} else {
		$self->insert_main_table(\%update);
	}
$basic->print_html($print);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete{

my $self = shift;
my $task_target = shift;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub per_page{

my $self = shift;
my $basic = $self->basic_object();
my $query = new Mebius::Query;
my $param  = $query->param();

my($print);

my $task_data = $self->data($param->{'target'});

$print .= $self->form($task_data);

$basic->print_html($print);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data{

my $self = shift;
my $target = shift;

my $data = $self->fetchrow_main_table({ target => $target })->[0];

return $data;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub page{

my $self = shift;
my $basic = $self->basic_object();
my($print);

$print .= qq(<h1>メッセージ</h1>);

$print .= qq(<h2>新規登録</h2>);
$print .= $self->form();

$print .= qq(<h2>一覧</h2>);
$print .= $self->list();

$basic->print_html($print);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub form {

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;
my($print);

$print .= qq(<form method="post">);
$print .= qq(<p>送信先 <input type="text" name="to_account" value="$data->{'to_account'}" autofocus="1"></p>)."\n";
$print .= qq(<p>題名 <input type="text" name="subject" value="$data->{'subject'}"></p>)."\n";
$print .= qq(<textarea name="body" style="max-width:500em;width:100%;height:10em;" autofocus="1">$data->{'body'}</textarea>)."\n";
$print .= qq(<input type="hidden" name="mode" value="message">)."\n";
$print .= qq(<input type="hidden" name="type" value="create_task">)."\n";


$print .= qq(<input type="submit" value="タスクを登録する" style="font-size:110%;">)."\n";

	if($data->{'target'}){
		$print .= $html->input("hidden","target",$data->{'target'})."\n";
		$print .= $html->input("checkbox","delete",1,{ text => "削除" , checked => $data->{'deleted_flag'} })."\n";
	}

$print .= qq(</form>);

return $print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub list{

my $self = shift;
my($print);

my $data_group = $self->fetchrow_main_table({ deleted_flag => "0" },{ ORDER_BY => ["create_time DESC"] });

	foreach my $data (@{$data_group}){
		$print .= $self->data_to_list($data);
	}


return $print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift;
my $html = new Mebius::HTML;
my($print);

$print .= qq(<li>);

$print .= e($data->{'to_account'})." ";

$print .= $html->href("?mode=message&type=task&target=$data->{'target'}",$data->{'subject'} || '無題')." ";
$print .= e($data->{'flag'})."\n";
#$print .= $html->input("checkbox","mixi_message_task_$data->{'target'}","delete",{ text => "削除" })." ";

#$print .= e($data->{'create_time'})." ";
$print .= qq(</li>\n);

return $print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {
target => { PRIMARY => 1 } ,
create_time => { int => 1 } ,
send_time => { int => 1 } , 
to_account => {  } ,
to_accoun_name => { } ,
subject => { } , 
body => { text => 1 } , 

flag => { int => 1 } ,
deleted_flag => { int => 1 } , 
done_flag => { int => 1 } , 

account => { } ,
email => { } ,
};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
return "mixi_message_task";
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
sub send_group{

my $self = shift;

my $task_group = $self->fetchrow_main_table({ deleted_flag => 0 , done_flag => 0  });

return $task_group;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub basic_object{

my $self = shift;
my $object = new Mebius::Mixi;

$object;

}
1;

