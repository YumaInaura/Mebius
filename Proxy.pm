
package Mebius::Proxy;

use strict;

use Mebius::Query;
use Mebius::HTML;
use Mebius::Move;
use Mebius::Time;
use Mebius::LWP;
use Mebius::Encoding;
use Mebius::Time;

use Mebius::Export;

use base qw(Mebius::Base::DBI Mebius::Base::Basic Mebius::Base::Data);

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
"proxy";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_limited_package_name{
"proxy";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;
my $column = {
target => { PRIMARY => 1 } ,
type => { } , 
proxy => { } , 
addr => { } ,
speed => { int => 1 ,INDEX => 1 } ,
port => { int => 1 } ,
deleted_flag => { int => 1 } , 
create_time => { int => 1 } , 
country => { } ,
rank => { } ,  
last_modified => { int => 1 } , 
use_count => { int => 1 } , 

succeed_count => { int => 1 , INDEX => 1  } , 
failed_count => { int => 1 , INDEX => 1 } , 

last_check_time => { int => 1 } , 

};


$column;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;

my $query = new Mebius::Query;
my $param  = $query->param();
my $mode = $param->{'mode'} || $ARGV[0];

	if($mode eq "edit"){
		$self->edit();
	} elsif($mode eq "submit_proxy_doing"){
		$self->submit_proxy_doing();
	} elsif($mode eq "all_new_proxy"){
		$self->all_new_proxy();
	} elsif($mode eq "get_cyber_syndrome_view"){
		$self->get_cyber_syndrome_view();
	} elsif($mode eq "get_cyber_syndrome_fast_view"){
		$self->get_cyber_syndrome_fast_view();
	} elsif($mode eq "check_proxy"){
		$self->check_proxy();
	} else {
		$self->self_view();
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub navigation_link_group{

my $self = shift;
my $site_url = $self->site_url();

my @links = (
{ url => "${site_url}" , title => "トップ" },
{ url => "${site_url}?mode=check_proxy" , title => "性能チェック" },
{ url => "${site_url}?mode=get_cyber_syndrome_view" , title => "自動取得1" },
{ url => "${site_url}?mode=get_cyber_syndrome_fast_view" , title => "自動取得2" },

{ url => "http://www.cybersyndrome.net/plr.html" , title => "CyberSyndrome" } ,  
);

\@links;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_url{

my $self = shift;
my $site_url = "http://127.0.0.1/cgi-bin/proxy.cgi";
$site_url;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub form{

my $self = shift;
my $data = shift || {};
my $html = new Mebius::HTML;
my($print);

$print .= qq(<form action="" method="post">);
$print .= $html->input("text","proxy","",{ autofocus => 1 , placeholder => "例\) 127.0.0.0:80"});
$print .= $html->input("hidden","mode","submit_proxy_doing");
$print .= $html->input("submit","","新しいプロクシを追加する");

$print .= qq(</form>);

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub edit{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();
my $move = new Mebius::Move;

	foreach my $key ( keys %{$param} ){
		my $value = $param->{$key};
			if($self->param_to_control($key)){
				next;
			}
	}

$move->redirect_to_self_url();
exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub html_to_failed_flag{

my $self = shift;
my $html = shift;
my($failed_flag);

	if(!$html){
		console "Proxy is strange? HTML is empty. ";
		$failed_flag = 1;
	} elsif($html =~ /^read timeout at/){
		console "Proxy read timeout .";
		$failed_flag = 1;
	} elsif($html =~ m!^Can't connect to |^establishing SSL tunnel failed|^Maximum number of open connections reached|^500!){
		console "Proxy can't connect ";
		$failed_flag = 1;
	} elsif($html =~ m!<title>ERROR: The requested URL could not be retrieved</title>!){
		console "Proxy can't connect. This service's original error?";
		$failed_flag = 1;
	}

$failed_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_proxy_doing{

my $self = shift;
my $new_proxy = shift;
my $speed = shift;
my $query = new Mebius::Query;
my $param  = $query->param();

$new_proxy ||= $param->{'proxy'};

my $move = new Mebius::Move;

$self->submit_proxy($new_proxy);

	if(!console){
		$move->redirect_to_self_url();
		exit;
	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_proxy{

my $self = shift;
my $insert = shift;
my $rank = shift;
my $country = shift;
my %new_insert = %{$insert};

my $proxy = $new_insert{'proxy'};
my($addr,$port) = split(/:/,$proxy);

$new_insert{'addr'} = $addr;
$new_insert{'port'} = $port;
$new_insert{'last_modified'} = time;
$new_insert{'deleted_flag'} = 0;

	if($addr eq "" || $port eq ""){
		die("addr $addr or port $port is empty.");
	}

my $data = my $data_exists = $self->fetchrow_main_table({ proxy => $proxy })->[0];

	if($data_exists){
		$new_insert{'target'} = $data->{'target'};
		$self->update_main_table(\%new_insert);
	} else {
		my $target = $self->new_target();
		$self->insert_main_table(\%new_insert);
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub self_view{

my $self = shift;
my $html = new Mebius::HTML;
my($print);

my $page_title = "プロクシ設定";

my $random_proxy = $self->random_proxy();

my $data_group = $self->fetchrow_main_table_asc({ deleted_flag => 0 },"speed");
my $deleted_data_group = $self->fetchrow_main_table_asc({ deleted_flag => ["<>",0] },"speed");

$print .= $self->form();
$print .= $self->check_form();

$print .= $html->tag("h2","ランダム");
$print .= e($random_proxy);


$print .= qq(<form action="" method="post">);
$print .= $html->input("hidden","mode","edit");;

my $useful_data_group = $self->useful_proxy_data_group();

$print .= $html->tag("h2","使用");
$print .= qq(<div style="margin:1em 0em;word-wrap:break-word;">ポート: );
$print .= $self->data_group_to_port_list($useful_data_group);
$print .= qq(</div>);

$print .= qq(<table>);
$print .= $self->data_group_to_list($useful_data_group);
$print .= qq(</table>);

#$print .= $html->tag("h2","リスト");
$print .= qq(<div style="margin:1em 0em;word-wrap:break-word;">ポート: );
$print .= $self->data_group_to_port_list($data_group);
$print .= qq(</div>);

#$print .= qq(<table>);
#$print .= $self->data_group_to_list($data_group);
#$print .= qq(</table>);

$print .= $html->tag("h2","削除済み");
$print .= qq(<table>);
$print .= $self->data_group_to_list($deleted_data_group);
$print .= qq(</table>);

$print .= $html->input("submit","","この内容で編集する");;

$print .= qq(</form>);

$print .= $html->tag("h2","ポートの種類 ( iptables記述用 )");
$print .= $self->data_group_to_iptables_text($data_group);


$self->print_html($print,{ Title => $page_title , h1 => $page_title });


exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_iptables_text{

my $self = shift;
my $data_group = shift;
my($print,$count,@port_kind,%port_kind);

$print .= qq(#PROXY<br>);

	foreach my $data (@{$data_group}){
		$port_kind{$data->{'port'}} = 1;
	}

	foreach my $key ( keys %port_kind ){
		$count++;
		push @port_kind , $key;
			if($count % 10 == 0){
				$print .= $self->port_list_to_iptables_text(\@port_kind);
				@port_kind = ();
			}
	}

	if(@port_kind){
		$print .= $self->port_list_to_iptables_text(\@port_kind);
	}

my $port_list = $self->data_group_to_port_list($data_group);

# PROXY

$print;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub port_list_to_iptables_text{

my $self = shift;
my $port_list = shift;
my($print);

my $list .= e(join "," , @{$port_list});


$print .= qq(-A INPUT -m multiport -p tcp --dport ).e($list).qq( -j ACCEPT<br>);
$print .= qq(-A INPUT -m multiport -p tcp --sport ).e($list).qq( -j ACCEPT<br>);
$print .= qq(-A OUTPUT -m multiport -p tcp --dport ).e($list).qq( -j ACCEPT<br>);
$print .= qq(-A OUTPUT -m multiport -p tcp --sport ).e($list).qq( -j ACCEPT<br>);

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_port_list{

my $self = shift;
my $data_group = shift;
my($print,@port_kind,%port_kind);

	foreach my $data (@{$data_group}){
		$port_kind{$data->{'port'}} = 1;
	}
	foreach my $key ( keys %port_kind ){
		push @port_kind , $key;
	}

$print .= e(join "," , @port_kind);

$print;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_cyber_syndrome_fast{

my $self = shift;
my $lwp = new Mebius::LWP;
my(@data_group);

my $get_url = "http://www.cybersyndrome.net/plr.html";
my $list_html = $lwp->get($get_url);

	while($list_html =~ s!<td>(([0-9]{1,4}.[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}):([0-9]{2,4}))</td><td><br></td><td class="(A|B|C|D|E)">(A|B|C|D|E)</td><td>([A-Z]+)</td>!!){

		my $addr_and_port = $1;
		my $addr = $2;
		my $port = $3;
		my $rank = $4;
		my $country = $6;

			if($rank !~ /(A|B|C)/){
				next;
			}

		push @data_group , { country => $country , rank => $rank , addr => $addr , port => $port , proxy => $addr_and_port , flag =>  };

	}

@data_group;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_cyber_syndrome_fast_view{

my $self = shift;

my $html = new Mebius::HTML;
my($print);

my $page_title = "プロクシの自動取得";

my @data_group = $self->get_cyber_syndrome_fast();


$print .= $html->tag("h2","一覧");
$print .= qq(<table>);
$print .= $self->data_group_to_list(\@data_group);
$print .= qq(</table>);

$self->print_html($print);
exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_new_proxy{

my $self = shift;
my(@proxy_group,$count);

push @proxy_group , $self->get_cyber_syndrome_fast();
push @proxy_group , $self->get_cyber_syndrome();

my $data_num = @proxy_group;

	foreach my $hash (@proxy_group){

		my($border_time);

		$count++;

		console "$count / $data_num";

			if($hash->{'rank'} !~ /^A|B$/){ next; }

		my $data = my $data_exists = $self->fetchrow_main_table({ proxy => $hash->{'proxy'} } )->[0];


			if($data->{'speed'} >= 10000){
				$border_time = 30*24*60*60;
			} elsif($data->{'speed'} >= 1000){
				$border_time = 7*24*60*60;
			} else {
				$border_time = 3*24*60*60;
			}

			if($data->{'deleted_flag'}){
				console "$hash->{'proxy'} is deleted alredy.";
				next;
			} elsif($data->{'last_check_time'} > time - $border_time){
				console "$hash->{'proxy'} is still exists in database.";
				next;
			}

		my $speed = $self->check_proxy($hash->{'proxy'}) || 10000;


		my %insert = %{$hash};
		$insert{'speed'} = $speed;
		$insert{'last_check_time'} = time;
		$insert{'failed_count'} = 0;

			if($speed <= 1000){
				$self->submit_proxy(\%insert);
				console "Submit.";
			} else {
				$self->submit_proxy(\%insert);
				console "Not submit.";
			}

	}


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_cyber_syndrome{

my $self = shift;
my $mebius_lwp = new Mebius::LWP;
my(@data_group,@proxy);

my $get_url = "http://www.cybersyndrome.net/pla.html";
my $list_html = $mebius_lwp->get($get_url);

	while($list_html =~ s!<a title="([A-Z]+)" (?:[^><]+) class="(A|B|C|D)">(([0-9]{1,4}.[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}):([0-9]{2,4}))</a>!!){

		my ($flag);
		my $country = $1;
		my $rank = $2;
		my $addr_and_port = $3;
		my $addr = $4;
		my $port = $5;

			if($rank eq "A" && $port eq "80" && $country =~ /^(US|KR|FR|JP)$/){

				#$self->submit_proxy($addr,$port,$rank,$country);
				$flag = 1;
				push @proxy , $addr_and_port;
			}

		push @data_group , { country => $country , rank => $rank , addr => $addr , port => $port , proxy => $addr_and_port , flag => $flag };

	}

@data_group;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_cyber_syndrome_view{

my $self = shift;
my $lwp = new Mebius::LWP;
my $html = new Mebius::HTML;
my($print);

my $page_title = "プロクシの自動取得";

my @proxy_group = $self->get_cyber_syndrome();

#$print .= $html->href($get_url) . " から取得" ;

$print .= $html->tag("h2","一覧");
$print .= qq(<table>);
$print .= $self->data_group_to_list(\@proxy_group);
$print .= qq(</table>);

$print .= qq(<hr>);

$self->print_html($print,{ Title => $page_title , h1 => $page_title });

exit;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift || (warn && return());
my $use = shift || {};
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my($print);

$print .= qq(<tr>);

$print .= qq(<td>);
$print .= e($use->{'hit'}+1);
$print .= qq(</td>);

$print .= qq(<td>);
$print .= $html->input("text","proxy_addr_$data->{'target'}","$data->{'addr'}:$data->{'port'}");
#$print .= e($data->{'addr'}).":".e($data->{'port'});
$print .= qq(</td>);

$print .= qq(<td>);
$print .= e($data->{'rank'});
$print .= qq(</td>);

$print .= qq(<td>);
$print .= e($data->{'country'});
$print .= qq(</td>);

$print .= qq(<td>);
	if($data->{'flag'}){
		$print .= qq(★);
	}
$print .= qq(</td>);

$print .= qq(<td>);
	if( my $last_mofified = $data->{'last_modified'} ){
		$print .= $times->how_before($last_mofified);
	}
$print .= qq(</td>);

$print .= qq(<td style="text-align:right;">);
$print .= e($data->{'speed'});
$print .= qq(</td>);

$print .= qq(<td style="text-align:right;">);
$print .= e($data->{'failed_count'});
$print .= " / ";
$print .= e($data->{'succeed_count'});
$print .= qq(</td>);

$print .= qq(<td>);
$print .= $self->data_to_control_parts($data,{ Simple => 1 , ForcedView => 1  });
#$print .= $html->radio("checkbox","proxy_addr_control_$data->{'target'}","deleted",{ text => "削除" });
$print .= qq(</td>);

$print .= qq(</tr>);

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub check_proxy{

my $self = shift;
my $proxy = shift;
my $encoding = new Mebius::Encoding;
my $lwp = new Mebius::LWP;
my $query = new Mebius::Query;
my $param  = $query->param();
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my($print,$domain,$ok_flag);

$proxy ||= $param->{'proxy'} || $ARGV[1];

my $url = "http://www.cman.jp/network/support/go_access.cgi";
my $ssl_url = "https://www.cman.jp/network/support/go_access.cgi";

$print .= $self->check_form();

	if($url =~ m!https?://([0-9a-zA-Z\.]+)/!){
		$domain = $1;
	} else {
		die("Domain is empty.");
	}


	if(!$proxy){ die; }

console "Proxy check: $proxy ";

my $start_micro_time = $times->micro_time();
my $get = $lwp->post($url,{ submit => 1 } ,{ cookie_file => "proxy_test_${domain}_cookie.txt" , AutoReferer => 1 , proxy => $proxy });
my $get = $lwp->post($ssl_url,{ submit => 1 } ,{ cookie_file => "proxy_test_${domain}_cookie.txt" , AutoReferer => 1 , proxy => $proxy });

	if($get =~ /あなたが現在インターネットに接続しているグローバルIPアドレス確認/){
		console "OK";
		$ok_flag = 1;
	} else {
		console "Not OK.";
		print $get;
		return();
	}

my $end_micro_time = $times->micro_time();
my $speed = int( ($end_micro_time - $start_micro_time) / 10000 );

console "Speed: $speed";
$print .= "Speed : " . e($speed);



$print .= $get;
#$print .= $encoding->eucjp_to_utf8($get);


$print .= $html->tag("h2","あなたの環境");

	foreach my $key ( keys %ENV ){
		my $value = $ENV{$key};
		$print .= qq($key : $value<br>);
	}


	if(!console){
		$self->print_html($print);
		exit;
	}

$speed;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub check_form{

my $self = shift;
my $data = shift || {};
my $html = new Mebius::HTML;
my($print);

$print .= qq(<form action="" method="post">);
$print .= $html->input("text","proxy","",{ autofocus => 1 , placeholder => "例\) 127.0.0.0:80" });
$print .= $html->input("hidden","mode","check_proxy");
$print .= $html->input("submit","","このプロクシをチェックする");
$print .= qq(</form>);

$print;

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
sub main_table_name{
"proxy";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub database_objects{
my $self = shift;
$self;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub ssl_random_proxy{
my $self = shift;

my @proxy_list = $self->ssl_proxy_list();

my $proxy_addr_and_port = $proxy_list[int rand(@proxy_list)];

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_proxy_data_group{

my $self = shift;
my(@useful);

my $data_group = $self->fetchrow_main_table_asc({ deleted_flag => 0 , speed => ["<=",1500] },"speed",{ Debug => 0 });

#country => ["NOT IN",["CN"]] ,

	foreach my $data (@{$data_group}){
			if($data->{'failed_count'} >= 10 && $data->{'failed_count'}*1.5 > $data->{'succeed_count'}){
				next;
			#} elsif($data->{'speed'} > 1500){
			#	next;
			} else {
				push @useful , $data;
			}
	}

\@useful;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub useful_proxy_judge{

my $self = shift;
my $judge_proxy = shift;
my($flag);

my $useful_proxies = $self->useful_proxy_data_group();

	foreach my $proxy_data (@{$useful_proxies}){
			if($proxy_data->{'proxy'} eq $judge_proxy){
				$flag = 1;
			}
	}

$flag;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub proxy_list{

my $self = shift;

my $data_group = $self->useful_proxy_data_group();
my @list = map { $_->{'proxy'}; } @{$data_group};

@list;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub random_proxy{

my $self = shift;

my @proxy_list = $self->proxy_list();

my $proxy_addr_and_port = $proxy_list[int rand(@proxy_list)]; # || die("No useful proxy.")


$proxy_addr_and_port;

}


#-----------------------------------------------------------
# 外部サイトからプロクシの一覧を取得して、制限をかける
#-----------------------------------------------------------
sub GetListCyberSyndrome{

# 局所化
my($i_host,$i_addr,$line,$addr_line,$host_line,$source);

	# 解析対象となるソースを取得
	if($main::alocal_mode){ 
		open(IN,"<./_proxy_alocal/cybersyndrome.log");
			while(<IN>){
				$source .= qq($_);
			}
		close(IN);
	}
	else{
		($source) = Mebius::getpage("Source","http://www.cybersyndrome.net/pla5.html");
	}

	# ホスト名に一斉制限を課す
	while($source =~ s/(([a-zA-Z0-9\-\.]{1,500})\.([a-z]{2,4})):(\d{1,5})//){

		# 局所化
		my(%renew);

		# 制限用ファイルを取得
		my(%penalty) = Mebius::penalty_file("Get-hash Host",$1,%renew);

		$i_host++;
		$host_line .= qq($1<br>\n);

		# 更新内容
		$renew{'block'} = 1;
		$renew{'block_time'} = time + 31*24*60*60;
		$renew{'block_decide_man'} = "自動";
		$renew{'block_decide_time'} = time;
		$renew{'block_reason'} = 98;

			if($penalty{'block_time'} > $renew{'block_time'}){ next; }

		# 制限用ファイルを更新
		Mebius::penalty_file("Renew-hash Host",$1,%renew);

	}

	# IPアドレスに一斉制限を課す
	while($source =~ s/(\d{1,4}\.\d{1,4}\.\d{1,4}\.\d{1,4}):(\d{1,5})//){

		# 局所化
		my(%renew);

		# 制限用ファイルを取得
		my(%penalty) = Mebius::penalty_file("Get-hash Addr",$1,%renew);

		$i_addr++;
		$addr_line .= qq($1<br>\n);

		# 更新内容
		$renew{'block'} = 1;
		$renew{'block_time'} = $main::time + 31*24*60*60;
		$renew{'block_decide_man'} = "自動";
		$renew{'block_decide_time'} = $main::time;
		$renew{'block_reason'} = 98;

			if($penalty{'block_time'} > $renew{'block_time'}){ next; }

		# 制限用ファイルを更新
		Mebius::penalty_file("Renew-hash Addr",$1,%renew);

	}



# 見出し
my $h2_addr = qq(<h2>IPアドレス($i_addr)</h2>);
my $h2_host .= qq(<h2>ホスト名($i_host)</h2>);

$line = qq(
$h2_addr
$addr_line
$h2_host
$host_line
);


my $print = qq($line);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_html_core{

my $self = shift;
my $use = shift || {};
my $body = shift;
my $html = new Mebius::HTML;
my(%new_use);

#$new_use{'inline_css'} .= qq(
#body{line-height:1.6em;}
#input:checked + label , input:checked + span , input:checked + strong{background:yellow !important;}
#input + span:hover{background:orange;}
#input[type="text"]:focus,input[type="password"]:focus,input[type="search"]:focus{background: #ffa;}
#textarea:focus{background: #ffb;}
#);

%new_use = (%{$use},%new_use);

$html->simple_print($body,\%new_use);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub site_title{
"Proxy管理";
}

1;
