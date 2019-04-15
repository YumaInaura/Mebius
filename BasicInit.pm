
use strict;
#use Mebius::Basic;
use Mebius::Admin;
use Mebius::Server;
package Mebius;

#-----------------------------------------------------------
# 全ての基本となる設定/ログディレクトリを定義
#-----------------------------------------------------------
sub var_directory{

	# ローカルサーバー
	if(Mebius::alocal_judge()){
		return("C:/");
	}
	# リアルサーバー
	else{
		return("/var/");
	}

}

#-----------------------------------------------------------
# 全ての基本となる設定/ログディレクトリを定義
#-----------------------------------------------------------
sub www_directory{

my($var_directory) = Mebius::var_directory();

	# ローカルサーバー
	if(Mebius::alocal_judge()){
		return("${var_directory}Apache2.2/");
	}
	# リアルサーバー
	else{
		return("${var_directory}www/");
	}

}


#-----------------------------------------------------------
# 全ての基本となる設定/ログディレクトリを定義
# サブルーチン内で BasicInitは宣言しない、無限ループ禁止、念のため
#-----------------------------------------------------------
sub base_init_directory{ BaseInitDirectory(@_); }
sub BaseInitDirectory{

my($www_directory) = Mebius::www_directory();
my($directory);

	# ローカルサーバー
	if(Mebius::alocal_judge()){
		$directory = "${www_directory}web_data/";
	}
	# リアルサーバー
	else{
		$directory = "${www_directory}web_data/";
	}


$directory;

}

#-----------------------------------------------------------
# 全ての基本となる設定/ログディレクトリを定義
# サブルーチン内で BasicInitは宣言しない、無限ループ禁止、念のため
#-----------------------------------------------------------
sub share_directory_path{

my($www_directory) = Mebius::www_directory();
my($directory);

	# ローカルサーバー
	if(Mebius::alocal_judge()){
		$directory = "${www_directory}web_data/";
	}
	# リアルサーバー
	else{
		$directory = "/share/";
	}

$directory;

}


#-----------------------------------------------------------
# 基本設定 ( ハッシュリファレンス )
# SSS => 全ての処理でグローバル変数ではなく、こちらの処理を使うようにしたい
# SSS => ループ禁止処理を追加したい
#-----------------------------------------------------------
sub basic_init{

# 宣言
my(%self);
my($init_directory) = Mebius::BaseInitDirectory();
my $server = new Mebius::Server;

# Near State （呼び出し） 2.30
my $StateName1 = "BasicInit";
my $StateKey1 = "Normal";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

# 各種情報を取得
my($server_domain) = Mebius::server_domain();
my($server_url) = Mebius::server_url();
my($procotol_type) = Mebius::ProcotolType();

# サーバードメイン
$self{'server_domain'} = $server_domain;

# 基本ディレクトリ
$self{'init_directory'} = Mebius::BaseInitDirectory();

	if(Mebius::alocal_judge()){
		$self{'top_level_domain'} = $self{'top_domain'} = $server->http_host(); 
		$self{'bbs_domain'} = $server->http_host();
	} else {
		$self{'top_level_domain'} = $self{'top_domain'} = "mb2.jp"; 
		$self{'bbs_domain'} = "mb2.jp";
	}

$self{'top_domain_url'} = "http://$self{'top_domain'}/";

my($procotol) = Mebius::procotol_type();
$self{'css_and_js_file_url'} = "${procotol}://mb2.jp/";

	# 大ドメイン再定義
	if($server_domain eq "sns.mb2.jp"){ $self{'base_server_domain'} = "aurasoul.mb2.jp"; }
	else{ $self{'base_server_domain'} = $server_domain; }

# 共通メインスクリプトのURL
$self{'main_url'} = $self{'this_server_main_script_url'} = "$server_url/_main/";

# サーバーの数 ( 主にリダイレクトに使う )
$self{'number_of_servers'} = 2;

# ドメインの数 ( 主にリダイレクトに使う )
$self{'number_of_domains'} = 3;

# 管理者のアドレス
$self{'admin_email'} = 'souji.kuzunoha@gmail.com';
$self{'admin_email_mobile'} = 'souji.kuzunoha@gmail.com';

# ● 固定URL系

# メールフォームへのリンク
$self{'mailform_url'} = "${procotol_type}://aurasoul.mb2.jp/_main/mailform.html";
$self{'mailform_link'} = qq(<a href="$self{'mailform_url'}">メールフォーム</a>);

# SNSのURL
#$self{'auth_url'} = "${procotol_type}://sns.mb2.jp/"; => SSL対応が出来てからにする
$self{'auth_url'} = "http://sns.mb2.jp/";
$self{'auth_relative_url'} = "/";
$self{'guide_url'} = "http://aurasoul.mb2.jp/wiki/guid/";
$self{'report_bbs_url'} = "http://aurasoul.mb2.jp/_delete/";

# 管理モードのSSL切り替え
($self{'admin_http'}) = Mebius::Admin::http_kind();

	# ローカルでの一斉設定
	if(Mebius::alocal_judge()){
		$self{'auth_url'} = "${procotol_type}://$ENV{'SERVER_ADDR'}/_auth/";
	}

# 管理モードURL
($self{'admin_url'}) = Mebius::Admin::basic_url();
$self{'admin_main_url'} = "$self{'admin_url'}index.cgi";
$self{'admin_report_bbs_url'} = "$self{'admin_http'}://mb2.jp/jak/delete.cgi";

# 管理者のIPアドレス
$self{'master_addr'} = "119.239.41.215";
	if($self{'master_addr'} eq $ENV{'REMOTE_ADDR'}){ $self{'master_addr_flag'} = 1; }

# 禁止系統
$self{'deny_words'} = ['pagead','/jak/','partner-pub'];

# 許可URL
# 許可URLを定義
$self{'allow_url'} = [
{ url => "(([a-z0-9]+)\.)?mb2\.jp" , Free => 1 , MyWebsite => 1 },
{ url => "mb2\.jp" , title=>"メビウスリング" , Free => 1 , MyWebsite => 1 },
{ url => "mb2\.jp" , Free => 1 , MyWebsite => 1  },
{ url => "google\.co\.jp" , title => "Googleの検索結果" },
{ url => "google\.com" },
{ url => "dic\.(search\.)?yahoo\.co\.jp" , title => "Yahoo! 辞書" },
{ url => "(search\.)?yahoo\.co\.jp" , title => "Yahoo! Japan" },
{ url => "bing\.com" , title => "Bing" },
{ url => "twitter\.com" , title => "Twitter" , Free => 1 },
{ url => "twtr\.jp" },
{ url => "line\.me" } ,
{ url => "(ja\.)?wikipedia\.org" , title => "Wikipedia" },
{ url => "youtube\.com" , title => "YouTube" },
{ url => "apple\.com",title => "Apple" },
{ url => "www\.nhk\.or\.jp" , title => "NHKオンライン" },
{ url => "nintendo\.co\.jp" },
{ url => "sony\.co\.jp" },
{ url => "sony\.jp" },
{ url => "konami\.jp" },
{ url => "namco\.co\.jp" },
];

$self{'paint_dir'} = "/var/www/$server_domain/public_html/paint/";
$self{'jak_directory'} = "/var/www/$server_domain/public_html/jak/";

	# ローカルでの設定
	if(Mebius::alocal_judge()){
		$self{'css_and_js_file_url'} = "${procotol}://$ENV{'SERVER_ADDR'}/";
		push(@{$self{'allow_url'}},{ url => "localhost" });
		$self{'auth_relative_url'} = "/_auth/";
		$self{'paint_dir'} = "${init_directory}../htdocs/paint/";
		$self{'bbs_domain'} = $self{'top_level_domain'} =  "$ENV{'SERVER_ADDR'}";
		$self{'jak_directory'} = "${init_directory}../jak/";
	}

	# Near State （保存） 2.30
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,\%self); }

return(\%self);

}

#-----------------------------------------------------------
# 現在のサーバーのドメイン名を取得する
#-----------------------------------------------------------
sub server_domain{

# 宣言
my($type) = @_;
my($server_domain);

# ENVから定義
#$server_domain = $ENV{'HTTP_HOST'};
$server_domain = $ENV{'SERVER_NAME'};

# 念のために、ポート番号部分を削除
$server_domain =~ s/:(\d+)//g;

# 念のため、全て小文字にしておく
$server_domain = lc $server_domain;

	# ホスト名の書式チェック
	if(Mebius::alocal_judge()){
		#if($server_domain !~ /^(localhost)$/){ return(); }
	}
	else{
		if($server_domain !~ /^([a-z0-9\.\-]+)\.([a-z]{2,4})$/){ return(); }
	}


return($server_domain);

}



#-----------------------------------------------------------
# ローカル判定
#-----------------------------------------------------------
sub alocal_judge{

	# 1 または 0 だけを返す、二つ以上の変数を返さない
	#if($ENV{'SERVER_ADDR'} eq "127.0.0.1" && $ENV{'DOCUMENT_ROOT'} =~ /^C:/){ return(1); }
	if(($ENV{'SERVER_ADDR'} eq "127.0.0.1" || $ENV{'SERVER_ADDR'} =~ /^192\.168\.0\.[0-9]+$/ || $ENV{'HTTP_HOST'} eq "localhost") && $ENV{'DOCUMENT_ROOT'} =~ /^C:/){ return(1); }
	elsif($ENV{'SESSIONNAME'} eq "Console" && $ENV{'SYSTEMDRIVE'} eq "C:"){ return(1); }
	else{ return(); }

}

1;
