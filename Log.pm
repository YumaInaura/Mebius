
use strict;
package Mebius;

#-----------------------------------------------------------
# アクセスログの記録
#-----------------------------------------------------------
sub AccessLog{

# 局所化
my($type,$filename,$comment,$unlink_rand) = @_;
my($line,$view_host,$file,$accesslog_handler);
my $logpms = 0606;

	# 値のチェック
	if($unlink_rand =~ /\D/){ die("Perl Die! Can't use not number in unlink rand value . \@_ is @_ "); }

# 汚染チェック
$filename =~ s/[^\w\-]//g;
if($filename eq ""){ return; }

# 時刻をセット
my $time = time;

# プロクシ関係の環境変数を取得
my(%env) = Mebius::Env("Get-proxy-only");

# 環境変数を取得
my $addr = $ENV{'REMOTE_ADDR'};
my $agent = $ENV{'HTTP_USER_AGENT'};
my $host2 = $ENV{'REMOTE_HOST'};
my $requri = $ENV{'REQUEST_URI'};
my $referer = $ENV{'HTTP_REFERER'};
my $cookie = $ENV{'HTTP_COOKIE'};
my $query = $main::postbuf;
my($REQUES_URL) = Mebius::request_url();

	# パスワードは記録しないように
	$query =~ s/(pass|password|passwd|hamdle)(\d)?=([^&]+)/$1$2=****/g;

$view_host = $main::host;
if($view_host eq ""){ $view_host = $host2; }

# 各種データを取得
my($nowdate_multi) = Mebius::now_date_multi();

# 書き込み内容を定義
$line .= qq($time	$nowdate_multi->{'date'}	$view_host	$addr $query \n);
$line .= qq($agent $ENV{'HTTP_X_UP_SUBNO'} $ENV{'HTTP_X_EM_UID'}\n);

	# クッキーを記録
	if($cookie){
		#$line .= qq(Cookie-natural : $ENV{'HTTP_COOKIE'}\n);
		my($cookie_dec) = Mebius::Decode("",$cookie);
		$line .= qq(Cookie-decoded : $cookie_dec\n);
	}

	# リファラを記録
	if($referer){ $line .= qq(Referer: $referer\n); }

	# ハッシュを展開
	if($env{'all_data'}){ $line .= qq($env{'all_data'}\n); }

# $ENV系
$line .= qq(\$ENV{'REQUEST_METHOD'} : $ENV{'REQUEST_METHOD'});
$line .= qq( / RequestURL : $REQUES_URL);
$line .= qq(\n);

	if($comment){ $line .= qq($comment\n); }

$line .= qq(\n);

# ファイル定義
my($init_directory) = Mebius::BaseInitDirectory(); 
$file = "${init_directory}_accesslog/${filename}_accesslog.log";

# ファイルを更新
open($accesslog_handler,">>",$file);
print $accesslog_handler $line;
close($accesslog_handler);
Mebius::Chmod(undef,"$file");

	# 一定確率でファイルを削除
	if($type !~ /Not-unlink-file/){
			if(!$unlink_rand){ $unlink_rand = 500; } 
			if(rand($unlink_rand) < 1){ unlink("$file"); }
	}

}

#-----------------------------------------------------------
# ログを記録して Die する
#-----------------------------------------------------------
#sub Die{

#my($message,$use) = @_;

# ログを記録
#my $log_name = $message;
#$log_name =~ s/\s/-/g;
#Mebius::AccessLog(undef,"Die-$log_name");

# die する
#die($message);

#}


1;
