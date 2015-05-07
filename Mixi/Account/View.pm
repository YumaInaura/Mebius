
package Mebius::Mixi::Account::View;

use strict;
use Mebius::Export;
use Mebius::Mixi::Account::Useful;

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
my $object = new Mebius::Mixi;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub self_view{

my $self = shift;
my $basic = $self->basic_object();
my $html = new Mebius::HTML;
my $query = new Mebius::Query;	
my $view = new Mebius::View;
my $mixi_account = new Mebius::Mixi::Account;
my $useful_account = new Mebius::Mixi::Account::Useful;
my($print);
my $param  = $query->param();

my $page_name = "アカウント管理";


$print .= $self->links();

	if($param->{'type'} eq "submit"){
		$print .= $html->tag("h2","アカウントの登録");
		$print .= $self->submit_form();
	}

	if($param->{'edit'}){
		$print .= qq(<form method="post" action="">);
		$print .= qq(<input type="submit" value="アカウントを編集する">);
		$print .= qq(<input type="hidden" name="mode" value="edit_accounts">);
	}

	# 最近制限されたアカウント
	if($param->{'account_type'} eq "" || $param->{'account_type'} eq "all"){
		my $recently_denied_data_group = $mixi_account->fetchrow_main_table_desc({ account_type => "limited" , status => ["IS","NOT NULL"] , denied_time => [">=",time-7*24*60*60]  },"denied_time");
		$print .= $mixi_account->data_group_to_table($recently_denied_data_group,"最近停止されたアカウント",{ Password => $param->{'view_password'} });
	}

	# 受付用アカウント
	if($param->{'account_type'} eq "" || $param->{'account_type'} eq "all"){
		my $data_group = $mixi_account->fetchrow_main_table({ account_type => "special" });
		$print .= $mixi_account->data_group_to_table($data_group,"受付アカウント",{ Password => $param->{'view_password'} });
	}

	# メインアカウント
	if($param->{'account_type'} eq "" || $param->{'account_type'} eq "all"){
		my $data_group = $mixi_account->fetchrow_main_table({ account_type => "main" });
		$print .= $mixi_account->data_group_to_table($data_group,"メインアカウント",{ Password => $param->{'view_password'} });
	}

	# 利用可能
	if($param->{'account_type'} eq "useful" || $param->{'account_type'} eq "all"){
		my $data_group = $mixi_account->useful_account_data_group();
		$print .= $mixi_account->data_group_to_table($data_group,"利用可能アカウント",{ Password => $param->{'view_password'} });
	}

	# 利用可能(メイン)
	if($param->{'account_type'} eq "useful_main" || $param->{'account_type'} eq "all"){
		my $data_group = $useful_account->main_useful_account_data_group();
		$print .= $mixi_account->data_group_to_table($data_group,"利用可能なアカウント(メイン)",{ Password => $param->{'view_password'} });
	}

	# 二通制限アカウント
	if($param->{'account_type'} eq "limited" || $param->{'account_type'} eq "all"){
		my $data_group = $mixi_account->fetchrow_main_table({ account_type => "limited" , status => ["IS","NULL"] , nickname => ["IS","NOT NULL"] });
		$print .= $mixi_account->data_group_to_table($data_group,"制限アカウント",{ Password => $param->{'view_password'} });
	}
	# 予備アカウント
	if($param->{'account_type'} eq "reserve" || $param->{'account_type'} eq "all"){
		my $data_group = $mixi_account->fetchrow_main_table({ account_type => "limited" , status => ["IS","NULL"] , nickname => ["IS","NULL"] });
		$print .= $mixi_account->data_group_to_table($data_group,"予備アカウント",{ Password => $param->{'view_password'} });
	}

	# 閲覧用アカウント
	if($param->{'account_type'} eq "" || $param->{'account_type'} eq "all"){
		my $data_group = $mixi_account->fetchrow_main_table({ account_type => "view" , status => ["IS","NULL"]  });
		$print .= $mixi_account->data_group_to_table($data_group,"閲覧用アカウント",{ Password => $param->{'view_password'} });
	}


	# 停止中のアカウント
	if($param->{'account_type'} eq "denied" || $param->{'account_type'} eq "all"){
		my $data_group = $mixi_account->fetchrow_main_table_desc({ account_type => "limited" , status => ["IS","NOT NULL"] },"denied_time");
		$print .= $mixi_account->data_group_to_table($data_group,"停止アカウント",{  Password => $param->{'view_password'} });
	}

	# パスワードが合わなかったアカウント
	if($param->{'account_type'} eq "empty" || $param->{'account_type'} eq "all"){
		my $data_group = $mixi_account->fetchrow_main_table_desc({ status => "empty" },"create_time");
		$print .= $mixi_account->data_group_to_table($data_group,"パスワードが合わないアカウント",{  Password => $param->{'view_password'} });
	}
#$print .= qq(<table border="1">) . $mixi_account->table_th() . $mixi_account->data_group_to_list($data_group2,{ Password => $param->{'view_password'} }) . qq(<table>);

	if($param->{'edit'}){
		$print .= qq(<input type="submit" value="アカウントを編集する">);
		$print .= qq(</form>);
	}


$basic->print_html($print,{ Title => $page_name , h1 => $page_name });


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_table{

my $self = shift;
my $data_group = shift;
my $label = shift;
my $use = shift || {};
my $html = new Mebius::HTML;
my($print);

my $num = @{$data_group};

$print .= $html->tag("h2","${label}($num)");

	if($use->{'view_mode'} ne "none"){
		$print .= qq(<table border="1">) . $self->table_th() . $self->data_group_to_list($data_group,$use) . qq(<table>);
	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_list{

my $self = shift;
my $data = shift;
my $use = shift || {};
my $html = new Mebius::HTML;
my $times = new Mebius::Time;
my $query = new Mebius::Query;
my $param  = $query->param();
my $basic = $self->basic_object();
my($print,$tr_style);

	if($data->{'status'}){
		$tr_style = "background:#fdd;";
	}

$print .= $html->start_tag("tr",{ style => $tr_style });

$print .= qq(<td>);
$print .= e($use->{'hit'}+1);
$print .= qq(</td>);

$print .= qq(<td>);

my $span_title = "$data->{'password'} $data->{'year'}/$data->{'month'}/$data->{'day'}";

	if($param->{'edit'}){
		$print .= $html->input("text","mixi_account_account_$data->{'target'}",$data->{'account'},{ style => "width:6em;" });
	} elsif($data->{'account'}){
		$print .= $html->href("http://mixi.jp/show_friend.pl?id=$data->{'account'}",$data->{'account'},{ title => $span_title });
	} else {
		$print .= $html->tag("span","未設定",{ title => $span_title });
	} 

$print .= qq(</td>);

$print .= qq(<td>);
	if($param->{'edit'}){
		$print .= $html->input("text","mixi_account_nickname_$data->{'target'}",$data->{'nickname'},{ style => "width:4em;" });
	} else {
		$print .= e($data->{'nickname'});
	}
$print .= qq(</td>);

$print .= qq(<td>);
	if($param->{'edit'}){
		$print .= $html->input("text","mixi_account_birthday_$data->{'target'}","$data->{'year'}-$data->{'month'}-$data->{'day'}",{ style => "width:5em;" });
	} else {
		$print .= e("$data->{'year'}/$data->{'month'}/$data->{'day'}");
	}
$print .= qq(</td>);


$print .= qq(<td>);
	if($param->{'edit'}){
		$print .= $html->input("text","mixi_account_email_$data->{'target'}",$data->{'email'},{ style => "width:15em;" });
	} elsif($data->{'email'}) {
		$print .= $html->href("?mode=per_account_view&type=email&target=$data->{'email'}",$data->{'email'});
	} else {
		$print .= 'メルアドなし';
	}

	if($param->{'mode'} eq "per_account_view"){
		$print .= qq(<div>P );
		$print .= e($data->{'password'});
		$print .= qq(</div>);
		$print .= qq(<div>O );
		$print .= e($data->{'old_password'});
		$print .= qq(</div>);
		$print .= qq(<div>T );
		$print .= e($data->{'temporaly_password'});
		$print .= qq(</div>);
	}


$print .= qq(</td>);

$print .= qq(<td>);
$print .= $times->how_before($data->{'last_action_time'});
	if($param->{'edit'}){
		$print .= $html->input("checkbox","mixi_account_last_action_time_refresh_$data->{'target'}",1,{ text => "更新" });
	}
$print .= qq(</td>);

$print .= qq(<td>);
$print .= e($data->{'total_action_count'} || 0) . "回";
$print .= qq(</td>);

$print .= qq(<td>);
	if($data->{'proxy'}){
		$print .= $html->href("?mode=per_account_view&type=proxy&target=$data->{'proxy'}",$data->{'proxy'});
	}
$print .= qq(</td>);

$print .= qq(<td>);
$print .= e($data->{'friend_num'}) . "人";
$print .= qq(</td>);

	if(!$param->{'edit'}){
			$print .= qq(<td>);
			$print .= $self->login_form($data);
			$print .= qq(</td>);
	}

$print .= qq(<td>);
	if($data->{'last_upload_picture_time'}){
		$print .= qq(★);	
	}
$print .= qq(</td>);
$print .= qq(<td>);
	if($data->{'browser_user_agent'}){
		$print .= "＠";
	}
$print .= qq(</td>);


$print .= qq(<td>);
	if($data->{'last_profile_check_time'}){
		$print .= $times->how_before($data->{'last_profile_check_time'});
		#$print .= qq(☆);	
	} else {
		$print .= "-";
	}
$print .= qq(</td>);

$print .= qq(<td>);
$print .= $times->how_before($data->{'create_time'});
$print .= qq(</td>);


$print .= qq(<td>);
	if($data->{'last_login_missed_time'}){
		$print .= qq(<span style="color:red;">);
		$print .= $times->how_before($data->{'last_login_missed_time'});
		$print .= qq(</span>);

	}
$print .= qq(</td>);

$print .= qq(<td>);
$print .= e($data->{'can_not_login_message'});
$print .= qq(</td>);


$print .= qq(<td>);
	if($param->{'edit'}){
		$print .= $html->input("text","mixi_account_status_$data->{'target'}",$data->{'status'},{ style => "width:4em;" });
	} else {
		$print .= e($data->{'status'});
	}

$print .= qq(<td>);
	if($param->{'edit'}){
		$print .= $html->input("text","mixi_account_account_type_$data->{'target'}",$data->{'account_type'},{ style => "width:4em;" });
	} else {
		$print .= e($data->{'account_type'});
	}
$print .= qq(</td>);

$print .= qq(<td>);
$print .= e($data->{'owner'});
$print .= qq(</td>);

	if($param->{'edit'}){
		$print .= qq(<td>);
			if($data->{'account'}){
				$print .= $html->href("http://mixi.jp/show_friend.pl?id=$data->{'account'}",$data->{'account'});
			} else {
				$print .= e($data->{'account'});
			}
		$print .= qq(</td>);
	}


#$print .= qq(<td>);
#$print .= e($data->{'total_action_count'});
#$print .= qq(</td>);

#$print .= qq(<td>);
#$print .= e($data->{'last_action_time'});
#$print .= qq(</td>);

#$print .= qq(<td>);
#$print .= e($data->{'create_time'});
#$print .= qq(</td>);

$print .= qq(</tr>);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub links{

my $view = new Mebius::View;
my $query = new Mebius::Query;
my $param  = $query->param();
my($print);

my @links = (
{ url => "?mode=account" ,  title => "普通" },
{ url => "?mode=account&account_type=useful" ,  title => "利用可能" },
{ url => "?mode=account&account_type=useful_main" ,  title => "利用可能(メイン)" },
{ url => "?mode=account&account_type=limited" ,  title => "二通制限" },
{ url => "?mode=account&account_type=reserve" ,  title => "予備" },
{ url => "?mode=account&account_type=denied" ,  title => "停止" },
{ url => "?mode=account&account_type=empty" ,  title => "空" },
{ url => "?mode=account&account_type=all" ,  title => "全て" },
{ url => "?mode=account&type=submit" ,  title => "登録" },
);


my @control_links = (
{ url => "?mode=account&account_type=$param->{'account_type'}&edit=1" ,  title => "編集" },
);


$print .= qq(<div style="word-spacing:0.5em;">);
$print .= $view->links(\@links);
$print .= ' =&gt; '.$view->links(\@control_links);
$print .= "</div>"."\n";



return $print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub submit_form{

my $self = shift;
my $query = new Mebius::Query;
my $param  = $query->param();
my $html = new Mebius::HTML;
my($print);

$print .= $html->start_tag("form",{ method => "post" });
$print .= $html->input("hidden","mode","submit_account_do");

$print .= $html->input("radio","account_type","special",{ text => "受付アカウント" });
$print .= $html->input("radio","account_type","main",{ text => "メインアカウント" });
$print .= $html->input("radio","account_type","limited",{ text => "制限アカウント" , checked => 1 });
$print .= $html->input("radio","account_type","view",{ text => "閲覧用アカウント"  });

$print .= " / オーナー: ".$html->input("text","owner","",{  });

$print .= $html->textarea("text",$param->{'text'},{ style => "width:100%;height:20em;" });
$print .= $html->input("submit","","この内容で実行する");
$print .= $html->close_tag("form");

$print;

}

1;