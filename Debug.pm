
use strict;
package Mebius::Debug;

#-----------------------------------------------------------
# ENV を書き換える
#-----------------------------------------------------------
sub OverWriteENV{

# 宣言
my($use) = @_;
my($DeviceType,$overwrite_flag);

	# ローカル判定
	# 重要！ リアルサーバーではここでリターンしないと、大変なことに 
	if(!Mebius::alocal_judge()){ return(); }

	# 設定 ( 管理モードではデバッグモードを実行しない )
	if($ENV{'REQUEST_URI'} !~ m!^/jak/!){
		#$DeviceType = "DOCOMO";
		#$DeviceType = "AU";

		#$ENV{'REMOTE_HOST'} = "ibis.ne.jp";
		#$ENV{'REMOTE_ADDR'} = "59.106.88.246";
		#$ENV{'HTTP_USER_AGENT'} = "Opera/9.50 (Nintendo DSi; Opera/507; U; ja)";
		#$ENV{'HTTP_COOKIE'} = "";
		#$ENV{'HTTP_COOKIE'} = 'PPL=id:005574,ps:1111; Sum=love_me_aura%3DCvwtMXEhvegcegCCCMzNDw<>; love_me_aura=PJ<><>ycalgefmy5Gnkb%2FL7VtJUQ<>%23750<>1<>84<><>1330974364<>0<>39<>1<><><><>5OsCzIKuNGNkV1em7tXF<><><><>tero<>f2J9GrS8obQpQe582yQlxg<><>1<><><><>105<><>1331034098<><><>On<><>1330973750<>';
	}


	# 携帯偽装
	if($DeviceType =~ /^(FAKE-MOBILE)$/i){
		$ENV{'HTTP_USER_AGENT'} = "DoCoMo123;ser000000000000001;";
		$ENV{'REMOTE_HOST'} = "proxy-f-202.docomo.ne.jp";
		$ENV{'REMOTE_ADDR'} = "210.153.87.34";

		$ENV{'HTTP_COOKIE'} = undef;
		$overwrite_flag = 1;
	}

	elsif($DeviceType =~ /^BIGLOBE$/i){
		$ENV{'REMOTE_ADDR'} = "119.239.41.215";
		$ENV{'REMOTE_HOST'} = "fl1-119-239-41-215.osk.mesh.ad.jp";
	}

	# ドコモ
	elsif($DeviceType =~ /^(DOCOMO)$/i){
		$ENV{'HTTP_USER_AGENT'} = "DoCoMo123;ser000000000000001;";
		$ENV{'REMOTE_HOST'} = "proxy-f-202.docomo.ne.jp";
		$ENV{'REMOTE_ADDR'} = "210.153.87.34";

		$ENV{'HTTP_COOKIE'} = undef;
		$overwrite_flag = 1;
	}

	#elsif($DeviceType =~ /^(OPERA)$/i){
		#Mozilla/5.0 Opera/9.5 (KDDI-KC3R; BREW; Opera Mobi; U; ja) Presto/2.2.1
		#pv51proxy05.ezweb.ne.jp
	#}

	elsif($DeviceType =~ /^(AU)$/i){
		$ENV{'HTTP_USER_AGENT'} = "KDDI-SH37 UP.Browser/6.2_7.2.7.1.K.2.232 (GUI) MMP/2.0 "; 
		$ENV{'HTTP_X_UP_SUBNO'} = "0000000_aa.ezweb.ne.jp";
		$ENV{'REMOTE_HOST'} = "wb75proxy10.ezweb.ne.jp";
		$ENV{'REMOTE_ADDR'} = "111.86.142.12";
		$overwrite_flag = 1;
	}


	elsif($DeviceType =~ /^(SOFTBANK)$/i){
#w61.jp-t.ne.jp
#SoftBank/1.0/740SC/SCJ001/SN354715038451105 Browser/NetFront/3.3
#123.108.237.4

		$ENV{'HTTP_USER_AGENT'} = "SoftBank(SN0000001)"; 
		$ENV{'REMOTE_HOST'} = "localhost.softbank.ne.jp";
		$overwrite_flag = 1;
	}
	elsif($DeviceType =~ /^(WILLCOM)$/i){
		$ENV{'HTTP_USER_AGENT'} = "WILLCOM"; 
		$ENV{'REMOTE_HOST'} = "localhost.ppp.prin.ne.jp";
		$overwrite_flag = 1;
	}

	elsif($DeviceType =~ /^(EMOBILE)$/i){
		$ENV{'HTTP_USER_AGENT'} = "emobile"; 
		$ENV{'REMOTE_HOST'} = "localhost.e-mobile.ad.jp";
		$ENV{'HTTP_X_EM_UID'} = "u000000001";
		$overwrite_flag = 1;
	}

	elsif($DeviceType =~ /^(JCOM)$/i){
		$ENV{'REMOTE_HOST'} = "";
		$ENV{'REMOTE_ADDR'} = "116.64.240.98";
		$overwrite_flag = 1;
	}


	# ボット
	elsif($DeviceType =~ /^(Bot)$/i){
		$ENV{'HTTP_USER_AGENT'} = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)  ";
		$ENV{'REMOTE_HOST'} = "crawl-66-249-69-119.googlebot.com";
		$ENV{'REMOTE_ADDR'} = "66.249.69.119";
		$ENV{'HTTP_COOKIE'} = undef;
		$overwrite_flag = 1;
	}

	# Cookieがない環境
	elsif($DeviceType =~ /^(CookieEmpty)$/i){
		$ENV{'HTTP_COOKIE'} = undef;
		$overwrite_flag = 1;
	}

	elsif($DeviceType =~ /^(3DS)$/i){
		$ENV{'HTTP_USER_AGENT'} = "Mozilla/5.0 (Nintendo 3DS; U; ; ja) Version/1.7455.JP";
		$overwrite_flag = 1;
	}

	elsif($DeviceType =~ /^(iPad)$/i){
	$ENV{'HTTP_USER_AGENT'} = "Mozilla/5.0 (iPad; CPU OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3";
	}

	# Who is 情報を取得する接続元
	elsif($DeviceType =~ /^(WhoisGet)$/i){
		$ENV{'REMOTE_ADDR'} = "61.127.191.3";
		$ENV{'REMOTE_HOST'} = "";
	}

	# 正引きの結果がカラ
	elsif($DeviceType =~ /^(emptyname)$/i){
			$ENV{'REMOTE_ADDR'} = "221.186.85.208";
			$ENV{'REMOTE_HOST'} = "";
	}


	# 正引きの結果がカラ ( AU-NET )
	elsif($DeviceType =~ /^(aunet)$/i){
		$ENV{'REMOTE_ADDR'} = "182.248.112.135"; # sp01proxy07.au-net.ne.jp
		$ENV{'HTTP_USER_AGENT'} = "Mozilla/5.0 (Linux; U; Android 2.3.3; ja-jp; IS11SH Build/S9081) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1  
		";
	}


	# 公開プロクシ
	elsif($DeviceType =~ /^(Forward)$/i){
		$ENV{'HTTP_X_FORWARDED_FOR'} = "1.1.1.1,1.2.3.4,5.5.5.5";
	}

return($overwrite_flag);


}

#-----------------------------------------------------------
# エラーをシンプルに表示
#-----------------------------------------------------------
sub Error{

# 宣言
my($text) = @_;

my $ref = ref $text;

	if(ref $text eq "HASH"){
		print_hash($text);
	}

# HTML用にエスケープ
my($text_escaped) = Escape::HTML([$text]);

# Content-type を書きだす
print "Content-type:text/html;\n\n";

# ヘッダ
print qq(<head>);
print qq(<meta http-equiv="content-type" content="text/html; charset=utf-8">);
print qq(</head>);

# HTMLを表示
print qq(<body>);
print qq(<h3>Error</h3>);
print qq($text);
print qq(<h3>Error ( HTML Escaped )</h3>);
print qq($text_escaped);
print qq(</body>);

# ログを記録
Mebius::AccessLog(undef,"Debug-error-viewed");

# すぐに終了
exit;

}

#-----------------------------------------------------------
# メール送信テスト
#-----------------------------------------------------------
sub test_send_mail{

	if($ENV{'REMOTE_ADDR'} eq "221.171.38.116"){
		Mebius::Email::send_email(undef,'yuma@kvd.biglobe.ne.jp',"test-".time);

		print "Content-type:text/html\n\n";
		print "OK! Send mail.";
		exit;

	} else {
		0;
	}

}

#-----------------------------------------------------------
# ハッシュを出力するためのコア処理
#-----------------------------------------------------------
sub print_hash_core{

my($hash) = @_;
my($self);

$self .= qq(\t<ul>\n);

	# 展開
	foreach my $key (keys %$hash ){
		$self .= qq(\t\t<li>);
			if(ref $hash->{$key} eq "HASH"){
				$self .= qq($key  : $hash->{$key});
				($self) .= print_hash_core($hash->{$key});
			} else {
				$self .= qq($key  : $hash->{$key});
			}

		$self .= qq(</li>);
		$self .= qq(\n);
	}

$self .= qq(\t</ul>\n);

$self;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub dump_hash{

print_hash_core(@_);

}


#-----------------------------------------------------------
# ハッシュを印刷
#-----------------------------------------------------------
sub print_hash{

my($print) = print_hash_core(@_);

print "Content-type:text/html\n\n";
print $print;
exit;


}

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# エラーを回避する場合
#-----------------------------------------------------------
sub escape_error{

my $self = shift;
my($param) = Mebius::query_single_param();
my $escape_error_flag;

	#if(Mebius::alocal_judge() && ($param->{'escape_error'} || $ENV{'REQUEST_METHOD'} eq "GET")){ $escape_error_flag = 1  }
	if(Mebius::alocal_judge() && $param->{'escape_error'}){ $escape_error_flag = 1  }

$escape_error_flag;

}


#-----------------------------------------------------------
# エラー回避のためのチェックボックス
#-----------------------------------------------------------
sub escape_error_checkbox{

my $self = shift;
my $html = new Mebius::HTML;

	if(!Mebius::alocal_judge()){ return(); }

my $checkbox = $html->input("checkbox","escape_error","1",{ text => "特定のエラーを回避" , default_checked => 1 });

$checkbox;

}


1;
