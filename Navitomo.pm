
package Mebius::Mixi::Navitomo;

use strict;

use Mebius::Mixi::Basic;
use Mebius::Mixi::Community;

use Mebius::Query;
use Mebius::Basic;
use Mebius::HTML;
use Mebius::Export;

use Mebius::Mixi::Account;

use LWP::Simple qw();

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub BEGIN {
our $post_key = undef;
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
my $object = new Mebius::Mixi;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub login_form_view{

my $self = shift;
my($print,@list);
my $basic = $self->basic_object();
my $html = new Mebius::HTML;
my $mixi = new Mebius::Mixi;
my $mixi_account = new Mebius::Mixi::Account;

my $page_title = "ブラウザログイン - mixi";

$print .= $self->post_key_form();

$print .= qq(
<div style="margin-top:1em;">
移動： 
<a href="#list_main">#メインアカウント</a>
<a href="#list_low">#制限アカウント</a>
</div>
);

#$print .= $html->tag("h2","コミュニティ");
#$print .= $self->file_to_community_links("data/community.txt");


#push @list , $self->open_account_file_to_around_form("data/main_account.txt","main","メインアカウント");
#push @list , $self->open_account_file_to_around_form("data/low_account.txt","low","制限アカウント");

my $main_data_group = $mixi_account->fetchrow_main_table({ account_type => "main" });
my $limited_data_group =  $mixi_account->fetchrow_main_table({ account_type => "limited" });

push @list , $self->data_group_to_list($main_data_group);
push @list , $self->data_group_to_list($limited_data_group);

$print .= join qq(<hr style="border:3px dashed #f00;">) , @list;
$print .= $basic->print_html($print,{ title => $page_title , h1 => $page_title });

#Mebius::Fileout("","mix_login.html",$print);

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub post_key_form{

my $self = shift;
my($print);
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my($param) = $query->param();


$print .= qq(<form action="">);
$print .= $html->input("text","post_key",$param->{'post_key'});;
$print .= $html->input("submit","","ログインキーを決める");;
$print .= qq(</form>);

$print .= qq(</form>);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub open_file_to_array{

my $self = shift;
my $file_path = shift || return();
my($FILE,@file);

open($FILE,"<",$file_path) || return("アカウントが書かれたファイルが見つかりません。");
while(<$FILE>){ push @file , $_; }
close($FILE);

@file;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub file_to_community_links{

my $self = shift;
my $file = shift || return();
my @file = $self->open_file_to_array($file);
my $community = new Mebius::Mixi::Community;
my $html = new Mebius::HTML;
my(@link,$print);

	foreach my $community_name (@file){
		$community_name =~ s/^\s+|\s+$//g;
			if($community_name eq ""){ next; }
		my $url = $community->search_result_url($community_name);
		push @link , $html->href($url,$community_name,{ target => "_blank" }) . "\n";
	}

$print .= qq(<div style="word-spacing:0.25em;line-height:1.8em;">);
$print .= join " " , @link;
$print .= qq(</div>);


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
sub data_group_to_list{

my $self = shift;
my $data_group = shift;
my($print,$count);

	foreach my $data (@{$data_group}){
		$count++;
		$print .= $self->form($data,$count);
	}

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub open_account_file_to_around_form{

my $self = shift;
my $file_path = shift || return("ファイルを指定してください。");
my $type = shift;
my $content_name = shift;
my $mixi = new Mebius::Mixi;
my $html = new Mebius::HTML;
my($print,$last_password,$count,@line);

my @file = $self->open_file_to_array($file_path);
#our $post_key = $mixi->get_login_post_key();

	foreach my $this_line (@file){

		my($form);

		$count++;

		chomp $this_line;
		$this_line || next;
		my($account,$password) = split(/\t+/,$this_line);

			if($password eq ""){
				$password = $last_password;
			} else {
				$last_password = $password;
			}

		$form .= $self->form($account,$password,$count,$type);


		push @line , $form;
	}

$print .= $html->tag("h2","$content_name",{ id => "list_$type" } );
$print .= join "<hr>" , @line;

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub mix_navigation_url{

my $self = shift;

my @next_url = (
{ url => "/home.pl" , title => "ホーム" , checked => 1 } , 
{ url => "/list_message.pl" , title => "メッセージ" } ,
{ url => "/edit_profile.pl" , title => "プロフィール編集" } ,
{ url => "/list_self_profile_image.pl" , title => "写真設定" } , 
);

@next_url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub form{

my $self = shift;
my $data = shift || return();
my $account = $data->{'email'} || (warn("Account is empty.") && return());
my $password = $data->{'password'} || (warn("Password is empty.") && return());
my $type = $data->{'account_type'};
my $count = shift;
my $html = new Mebius::HTML;
my $mixi = new Mebius::Mixi;
my $query = new Mebius::Query;
my($param) = $query->param();
my($line);


	if(!$data->{'nickname'}){
		#return();
	}

our $post_key ||= $param->{'post_key'};


	if($account){
		$line .= qq(<h2>).e($count).qq(. ).e($data->{'nickname'} || "無名").qq( . ).e($account).qq(</h2>);
			if($type eq "main"){
				$line = qq(<div style="background:#9F9;">$line</div>);
			}
	}


my @next_url = $self->mix_navigation_url();

$line .= qq(<form action="https://mixi.jp/login.pl?from=login1" method="post" name="login_form" target="_blank">);

	foreach my $hash (@next_url){
		my $checked = qq( checked) if($hash->{'checked'});
		$line .= q(<label>);
		$line .= q(<input type="radio" value=").e($hash->{'url'}).q(" name="next_url").e($checked).q( />);
		$line .= e($hash->{'title'});
		$line .= q(</label>);
	}

$line .= q(<input type="hidden" value=").e($post_key).q(" name="post_key" />);
$line .= q(<input type="hidden" value="" name="postkey" />);
$line .= q(<input type="hidden" value=").e($account).q(" name="email" size="30" tabindex="1" class="inputForm" /></p>);
$line .= q(<input type="hidden" name="password" value=").e($password).q(" size="30" tabindex="2" class="inputForm" /></p>);
$line .= q(<p class="autoLogin"><input type="checkbox" checked="checked" id="auto" name="sticky" tabindex="3" /><label for="auto">次回から自動的にログイン</label>
<p class="loginButton"><input type="image" src="https://img.mixi.net/img/public/pc/button/login002.png" alt="ログイン" tabindex="4" /></p>
</form>
);

$line;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub id_to_get_html_event_data{

my $self = shift;

my $url = $self->navitomo_event_url(@_);
my $html = LWP::Simple::get($url);

my $data = $self->navitomo_event_html_to_event_data($html);

$data;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub navitomo_event_html_to_event_data{

my $self = shift;
my $html = shift || return();
my(%data);

	if($html =~ m!<dd>男性 ([0-9,]+)円、女性 ([0-9,]+)円!){
		$data{'man_charge'} = $1;
		$data{'lady_charge'} = $2;
	}


\%data;


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub navitomo_event_url{

my $self = shift;
my $event_id = shift || return();

my $url = "http://xn--pckl7noc872spqa667csr4ddoyc.com/shosai.html?eventid=$event_id";

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub saint_event_url{

my $self = shift;
my $event_id = shift || return();

my $url = "https://www.saint-corporation.com/admin/event_shosai.php?eventid=$event_id";

$url;

}



1;
