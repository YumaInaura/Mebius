
use strict;
use Mebius::HTML;
package Mebius;

#-----------------------------------------------------------
# プロクシ判定 ( テスト中 )
#-----------------------------------------------------------
sub ProxyJudge{

# 宣言
my($type) = @_;
my($proxy_flag);

	if($ENV{'HTTP_ACCEPT'}){}
	if($ENV{'HTTP_ACCEPT_LANGUAGE'}){}
	if($ENV{'HTTP_ACCEPT_CHARSET'}){}
	if($ENV{'HTTP_ACCEPT_ENCODING'}){} #gzip,deflate,sdch

return($proxy_flag);

}

#-----------------------------------------------------------
# 自分自身かどうかを判定する
#-----------------------------------------------------------
sub MyAccessCheck{

# 宣言
my($type,$account,$host,$cnumber,$agent) = @_;
my($my_access_flag);

	# 判定
	if($account && $account eq $main::myaccount{'file'}){ $my_access_flag = 1; }
	if($host && $host eq $main::host){ $my_access_flag = 1; }
	if($cnumber && $cnumber eq $main::cnumber){ $my_access_flag = 1; }
	if($agent && $agent eq $main::agent){ $my_access_flag = 1; }

return($my_access_flag);

}


#-----------------------------------------------------------
# ログインチェック
#-----------------------------------------------------------
sub LoginedCheck{

# 宣言
my($type) = @_;
my($message);

	# ログインしていない場合
	if(!$main::myaccount{'file'}){
			if($main::postflag){
				$message = qq(この操作を実行するには、アカウントに<a href="${main::auth_url}">ログイン</a>してください。);
			}
			else{
				$message = qq(このページを利用するには、アカウントに<a href="${main::auth_url}?backurl=$main::selfurl_enc">ログイン</a>してください。);
			}
	}

	# エラーをすぐ出す場合
	if($type =~ /Error-view/ && $message){
		main::error("$message");
	}

return($message);

}


#-----------------------------------------------------------
# 環境変数を取得
#-----------------------------------------------------------
sub Env{

# 宣言
my($type) = @_;
my(%env);

	# プロクシ関連のデータを取得
	if($type =~ /Get-proxy/){

		$env{'forwarded_for'} = $ENV{'FORWARDED_FOR'};			#	squidなどのCacheサーバーを使ってる場合に…
		#$env{'http_cache_control'} = $ENV{'HTTP_CACHE_CONTROL'};		#	キャッシュする最長時間など
		$env{'http_cache_info'} = $ENV{'HTTP_CACHE_INFO'};		#	キャッシュの情報
		$env{'client_ip'} = $ENV{'HTTP_CLIENT_IP'};	#	接続元のIPアドレス
		#$env{'connection'} = $ENV{'HTTP_CONNECTION'};		#keep-alive;	接続の状態
		$env{'http_forwarded'} = $ENV{'HTTP_FORWARDED'};			#	プロキシまたはクライアントの場所
		#$env{'http_pragma'} = $ENV{'HTTP_PRAGMA'};			#	プロキシのキャッシュに関する動作方式
		$env{'http_proxy_connection'} = $ENV{'HTTP_PROXY_CONNECTION'};	#	プロキシの接続形態
		$env{'http_sp_host'} = $ENV{'HTTP_SP_HOST'};		#	接続元のIPアドレス
		$env{'http_te'} = $ENV{'HTTP_TE'};			#	プロキシ等がサポートするTransfer-Encodings
		$env{'http_via'} = $ENV{'HTTP_VIA'};			#	プロキシの情報（プロキシの種類，バージョン等）
		$env{'proxy_connection'} = $ENV{'PROXY_CONNECTION'};		#	プロキシの効果などを表示
		$env{'http_x_forwarded_for'} = $ENV{'HTTP_X_FORWARDED_FOR'};		#

	}

	# 普通の環境変数を取得 (未定義)
	#if($type =~ /Get-env/ && $type !~ /Get-proxy-only/){
	#
	#}

	# ハッシュを展開
	foreach ( keys %env ){
		if($env{$_} eq ""){ next; }
		$env{'all_data'} .= qq($_ => $env{$_} ; );
		$env{'num'}++;
	}

return(%env);

}

#-----------------------------------------------------------
# 外部サイトからの訪問
#-----------------------------------------------------------
sub FromOtherSite{

# 宣言
my($type) = @_;
my(%other_site,$other_handler,@renew_line);
my($share_directory) = Mebius::share_directory_path();

my $directory1 = "${share_directory}_ip/";
my $file = "${directory1}from_other_site.log";

# ファイルを開く
open($other_handler,"<$file");

	# ファイルロック
	if($type =~ /Renew/){ flock($other_handler,1); }

# トップデータを分解
chomp(my $top1 = <$other_handler>);
chomp(my $top2 = <$other_handler>);
($other_site{'key'}) = split(/<>/,$top1);
($other_site{'regist_count'},$other_site{'regist_count_ymd'}) = split(/<>/,$top2);

	# ハッシュ調整

	# 日が変わっている場合、
	if($other_site{'regist_count_ymd'} ne "$main::thisyearf-$main::thismonthf-$main::todayf"){
		$other_site{'regist_count'} = 0;
	}

	# 今日の外部経由の書き込みが多すぎる場合
	if($other_site{'regist_count'} >= 500){
		$other_site{'error_flag'} = qq(今日はもう書き込めません。);
	}

close($other_handler);

	# 外部経由のユーザーが、何らかの更新をおこなった場合
	if($type =~ /New-regist/){

		$other_site{'regist_count'} += 1;
		$other_site{'regist_count_ymd'} = "$main::thisyearf-$main::thismonthf-$main::todayf";

			# 管理者にメール
			if($other_site{'regist_count'} % 25 == 0){
				Mebius::Email::send_email("To-admin",undef,"外部経由の投稿が $other_site{'regist_count'} に達しました。");
			}

			# 管理者携帯にメール
			#if($other_site{'regist_count'} % 50 == 0){
			#	Mebius::Email::send_email("To-admin-mobile",undef,"外部経由の投稿が $other_site{'regist_count'} に達しました。");
			#}

	}

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

		# 局所化
		my(@top_data);

		# トップデータを追加
		push(@top_data,"$other_site{'key'}<>\n");
		push(@top_data,"$other_site{'regist_count'}<>$other_site{'regist_count_ymd'}<>\n");
		unshift(@renew_line,@top_data);

		Mebius::Fileout(undef,$file,@renew_line);
	}
	

return(%other_site);

}



1;

