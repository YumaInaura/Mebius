
# パッケージ宣言
use strict;
use Mebius::Dos;
use Mebius::Encode;
package Mebius;

#-----------------------------------------------------------
# リダイレクト ( 別名 )
#-----------------------------------------------------------
sub redirect{
Redirect("Not-exit",@_);
}

#-----------------------------------------------------------
# リダイレクト処理
#-----------------------------------------------------------
sub Redirect{

# 宣言
my($type,$redirect_url,$code) = @_;
my($use) = @_ if(ref $type eq "HASH");

	# リダイレクト先が指定されていない場合
	if($redirect_url eq ""){ die('Perl Die! Redirect URL is empty'); }

	# リダイレクトを禁止するＵＲＬ
	if($redirect_url =~ /pagead/){ die('Redirect URL is Denied'); }

# 自サーバードメイン等を取得
my($REQUEST_URL) = Mebius::request_url();

	# http:// から始まっていない場合、自サーバードメインを補足
	if($redirect_url =~ m|^/|){
		my($server_url) = Mebius::server_url();
		$redirect_url = qq($server_url$redirect_url);
	}

# &amp; をデスケープ
($redirect_url) = Mebius::Descape("",$redirect_url);

	# 汚染チェック
	if($redirect_url =~ /(\n|\r|\0)/){ die("Perl Die!  Redirect URL has Bad shintax ."); }

	# ダブルスラッシュを禁止 ( http:// の // は除く )
	if($redirect_url =~ m!([^:])(/){2,}!){ die("Perl Die!  Redirect URL has Double Slash => $redirect_url ."); }

# シャープのつかない正規のURLを定義
my $redirect_url_justy = $redirect_url;
$redirect_url_justy =~ s/#([a-zA-Z0-9]+)?$//g;

	# 特定の端末で、ＵＲＬ末尾の # 以降を削除
	if($ENV{'HTTP_USER_AGENT'} =~ /^KDDI|bingbot/ || $main::bot_access){ $redirect_url = $redirect_url_justy; }

	# リダイレクトループを防ぐ
	if($ENV{'REQUEST_METHOD'} ne "POST" && $REQUEST_URL eq $redirect_url_justy){
		#Mebius::AccessLog(undef,"Redirect-roop","$REQUEST_URL → $redirect_url $code");
		die("Perl Die!  Redirect is Rooping. '$REQUEST_URL' to '$redirect_url'");
	}

	# 原則として自ドメインのみへのリダイレクトを許可
	if(!$use->{'AllowOtherSite'} && $redirect_url =~ m!^https?://! && $redirect_url !~ m!^https?://$ENV{'HTTP_HOST'}/!){
		my($justy_domain_flag) = Mebius::Init::AllDomains({ TypeJustyCheck => 1 , URL => $redirect_url } );
			if(!$justy_domain_flag){
				Mebius::AccessLog(undef,"Redirect-to-other-site-url");
					die("Perl Die!  Redirect to Other Site's URL => $redirect_url .");
			}
	}

	# リダイレクトを記録
	if(rand(10) < 1){
			if($main::bot_access){
				#Mebius::AccessLog(undef,"Redirect-bot","$REQUEST_URL→ $redirect_url $code");
			}
			else{
				#Mebius::AccessLog(undef,"Redirect-user","$REQUEST_URL → $redirect_url $code");
			}
	}


# DOS判定を減らす
#Mebius::Dos::AccessFile("Redirect-url Renew",$ENV{'REMOTE_ADDR'});

print "Pragma: no-cache\n";

	# 恒久的なリダイレクト
	if($code eq "301" || $type =~ /301/){
		print "Status: 301 Moved Permanently\n";
		print "Location: $redirect_url\n";
		print "\n";

			if($type !~ /Not-exit/){
				exit;
			}

	}
	# 一時的なリダイレクト
	else{
		print "Location: $redirect_url\n";
		print "\n";

			if($type !~ /Not-exit/){
				exit;
			}

	}

# リターン
return();

}

1;
