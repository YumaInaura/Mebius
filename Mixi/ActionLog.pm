
package Mebius::Mixi::ActionLog;

use strict;

use Mebius::Mixi::Basic;
use Mebius::Query;
use Mebius::Time;
use Mebius::HTML;
use Mebius::Encoding;

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
sub main_table_column{

my $column = {
target => { PRIMARY => 1 } , 
account => { } , 
email => { INDEX => 1 } ,
result => { INDEX => 1 } , 
action_type => { } ,
message => { INDEX => 1 } ,
create_time => { int => 1 } , 
create_micro_time => { bigint => 1 , INDEX => 1 } ,
html => { text => 1 } ,
proxy => { } , 
};

$column;

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
sub self_view{

my $self = shift;
my $basic = $self->basic_object();
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $param  = $query->param();
my($print,$max_view,%fetchrow_option);

my $dbi = new Mebius::DBI;

my $page_title = "アクションログ";

$print .= $self->search_form();

	if($param->{'word'}){
		$max_view = $fetchrow_option{'LIMIT'} = 10000;
	} else {
		$max_view = $fetchrow_option{'LIMIT'} = 500;
	}

my $data_group_all = $self->fetchrow_main_table_desc({ },"create_micro_time",\%fetchrow_option);
$print .= qq(<table>);
$print .= $self->data_group_to_list($data_group_all,{ max_view => $max_view });
$print .= qq(</table>);

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($data_group_all->[0]->{'create_micro_time'})); }

#$print .= $html->tag("h2","失敗");
#$print .= qq(<ul>);
#$print .= $self->data_group_to_list($data_group_failed);
#$print .= qq(</ul>);

#$print .= $html->tag("h2","成功");
#$print .= qq(<ul>);
#$print .= $self->data_group_to_list($data_group_succeed);
#$print .= qq(</ul>);

#$print .= $html->tag("h2","試行");
#$print .= qq(<ul>);
#$print .= $self->data_group_to_list($data_group_try);
#$print .= qq(</ul>);

$basic->print_html($print,{ Title => $page_title , h1 => $page_title });


exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub action_log_html_view{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();
my $basic = $self->basic_object();
my $html = new Mebius::HTML;
my $encoding = new Mebius::Encoding;
my($print);


my $page_title = "ログ HTMLの確認";

my $data = $self->fetchrow_main_table({ target => $param->{'target'} })->[0];

#$print .= $html->tag("h2","HTMLを表示");

	if( my $page = $data->{'html'} ){
		$page =~ s/http-equiv="refresh"/http-equiv="refresh-none"/g;
		$page =~ s!<meta http-equiv="Content-Type" content="text/html; charset=euc-jp"  />!!;
		#$page = $encoding->eucjp_to_utf8($page);
		$print .= $page;
	}

#$basic->print_html($print,{ Title => $page_title , h1 => $page_title});

print "Content-type:text/html;charset-utf8;\n\n";
print $print;

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_name{
"mixi_action";

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub action_and_update_core{

my $self = shift;
my $type = shift || die;
my $email = shift;
my $message = shift || die("Please decide message.");
my $html_source = shift; 
my $basic = $self->basic_object();
my $mixi_account = new Mebius::Mixi::Account;
my($addr);

my $new_target = $self->new_target();

my $acocunt_data = $mixi_account->fetchrow_main_table({ email => $email })->[0];

	if($basic->use_proxy_switch()){
		$addr = $acocunt_data->{'proxy'};
	} else {
		$addr = $ENV{'SCRIPT_ADDR'} || $ENV{'SERVER_ADDR'} || $ENV{'HOSTNAME'}; # It's not a proxy
	}


$self->insert_main_table({ email => $email , account => $acocunt_data->{'acocunt'} , target => $new_target , result => $type , action_type => "" , message => $message , html => $html_source , proxy => $addr });

console("$type : $message $email");

	if($type eq "failed"){
		$mixi_account->update_main_table_where({ last_failed_time => time , failed_count => ["+",1] } , { email => $email });
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub search_form{

my $self = shift;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $param  = $query->param();
my($print);

$print .= $html->start_tag("form");
$print .= $html->input("hidden","mode","action_log");
$print .= $html->input("text","word",$param->{'word'});
$print .= $html->input("submit","","検索する");
$print .= $html->close_tag("form");


$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift || return("-");
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my $basic = $self->basic_object();
my $query = new Mebius::Query;
my $param  = $query->param();
my($print,$message_style);

	if($param->{'word'} ne "" && $data->{'html'} !~ /$param->{'word'}/ && $data->{'message'} !~ /$param->{'word'}/){
		return();
	}

my $site_url = $basic->site_url();

	if($data->{'result'} eq "failed"){
		$message_style = "color:red;";
	} elsif($data->{'result'} eq "succeed"){
		$message_style = "color:green;font-weight:bold;";
	}	elsif($data->{'result'} eq "finished"){
		$message_style = "color:green;font-weight:bold;background:#9f9;";
	}


$print .= $html->start_tag("tr",{ style => $message_style });
#$print .= e($data->{'create_micro_time'}) . " \n";

$print .= qq(<td>);
	if($data->{'email'}){
		$print .= $html->href("?mode=per_account_view&type=email&target=$data->{'email'}",$data->{'email'}) . "\n";
	} else {
		$print .= e($data->{'email'}) . " \n";
	}
$print .= qq(</td>);

$print .= qq(<td>);
$print .= e($data->{'proxy'}) . " \n";
$print .= qq(</td>);

#$print .= qq(<td>);
#$print .= e($data->{'account'}) . " \n";
#$print .= qq(</td>);

#$print .= qq(<td>);
#$print .= e($data->{'action_type'}) . " \n";
#$print .= qq(</td>);


$print .= qq(<td>);
$print .= $html->tag("span",$data->{'message'},{ style => $message_style }) . " \n";
$print .= qq(</td>);

$print .= qq(<td>);
$print .= $times->how_before($data->{'create_time'}) . " \n";
$print .= qq(</td>);

$print .= qq(<td>);
	if($data->{'html'}){
		$print .= "" . $html->href("${site_url}?mode=action_log_html_view&target=$data->{'target'}","HTMLを確認") . "\n";
	}
$print .= qq(</td>);


$print .= $html->close_tag("tr");

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();

	if($param->{'mode'} eq "action_log"){
		$self->self_view();
	} elsif($param->{'mode'} eq "action_log_html_view"){
		$self->action_log_html_view();
	}

}

1;