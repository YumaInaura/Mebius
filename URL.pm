
use strict;
package Mebius::URL;

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
sub server_url{
Mebius::server_url(@_);
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub request_url{
Mebius::request_url();
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub auto_link{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $text = shift;
my $plus_type;

my($auto_linked_text) = Mebius::url($use,$text);

$auto_linked_text;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub deny_url_error_message{

my $self = shift;
my $text_body = shift;
my($error);

# 禁止ワードを定義
my @deny_words1 = ('://','：／／','ttp','ｔｔｐ','www\.','Feeling\+Lucky','btnI','\[url','\[a href');

	foreach my $word (@deny_words1){
			if($text_body =~ /$word/) {
				$error = "URLは記入できません。";
			} else {
				0;
			}
	}

$error;

}



#-----------------------------------------------------------
# メインドメインのURL
#-----------------------------------------------------------
sub main_domain_url{

my $self = shift;
my($return);
my($main_server_domain) = Mebius::main_server_domain();
my($procotol) = Mebius::procotol_type();

	if($main_server_domain){
		($return) = "$procotol://$main_server_domain/";
	} else {
		($return) = "/";
	}

$return;

}

#-----------------------------------------------------------
# 相対URLか絶対URL
#-----------------------------------------------------------
sub relative_or_full_url{

my $self = shift;
my $full_url = shift;
my $url = $full_url;

my($server_domain) = Mebius::server_domain();

	if($full_url =~ m!^https?://$server_domain/!){
		$url;
	} else {
		$url =~ s!https?://$server_domain!!g;
	}

$url;

}

package Mebius;

#-----------------------------------------------------------
# オートリンク
#-----------------------------------------------------------
sub auto_link{
Mebius::URL->auto_link(@_);
}

#-----------------------------------------------------------
# オートリンク ( 別窓 )
#-----------------------------------------------------------
sub auto_link_blank{

my($return) = @_;

my($return) = Mebius::url({ BlankWindow => 1 },$return);

$return;

}

#-----------------------------------------------------------
# URLのフォーマットが正しいかどうかを判定
#-----------------------------------------------------------
sub url_format_check{

my($return) = url({ ReturnLinkedNum => 1},$_[0]);

}

#-----------------------------------------------------------
# URLの扱い、オートリンク
#-----------------------------------------------------------
sub url{

# 宣言
my($use,$text) = @_;

# リレータイプを定義 ( 今現在のところ、このサブルーチンの $type をそのまま引き継ぐ )
my $relay_use = $use;

my $autolinked_number = ($text =~ s/([^=^\"]|^)(https?\:\/\/([a-zA-Z0-9\.]{1,50}\.[a-z]{2,4}|localhost)\/)([\w\.\,\~\!\-\/\?\&\+\=\:\@\%\;\\%\*#]{1,1000})?/Mebius::auto_link_core($use,$1,$2,$3,$4)/eg);

	# リンク化された数を数える
	if($use->{'ReturnLinkedNum'}){
		return($autolinked_number);
	}
	else{ 
		return($text,$autolinked_number);
	}

}

#-----------------------------------------------------------
# URLのリンク化など、コアな部分の処理
#-----------------------------------------------------------
sub auto_link_core{

# 宣言
#my($use) = @_ if(ref $_[0] eq "HASH");
my($use,$before_text,$http_text,$domain,$near_uri) = @_;
my($return_text,$blank,$blank_flag,$link_text,$nofollow_flag,$nofollow_tag);
my($my_use_device) = Mebius::my_use_device();
my($my_real_device) = Mebius::my_real_device();
my $html = new Mebius::HTML;

	# 別窓で開くかどうか
	if($domain eq "localhost" || $domain =~ /(^|\.)mb2.jp$/){
		0;
	} else {
		$blank_flag = 1;
		$nofollow_flag = 1;
	}

	# 窓の形式
	if($blank_flag || $use->{'BlankWindow'}){
		$blank = qq( target="_blank" class="blank");
	}

	elsif($use->{'returnWindow'}){
		$blank = qq( target="_return");
	}
	elsif($use->{'TopWindow'}){
		$blank = qq( target="_top");
	}

	# nofollowの形式
	if($nofollow_flag){
		$nofollow_tag = qq( rel="nofollow");
	}

	# URLを消去
	if($use->{'EraseURL'}){
		$return_text = qq();
	}

	# スペースを追加
	elsif($use->{'AddSpace'}){
		$return_text = qq($before_text$http_text$near_uri );
	}

	# 自動リンク化
	elsif(!$use->{'NotAutoLink'}){

		my $max_length_link_text = 50;
		my $url = $http_text . $near_uri;

			if($ENV{'HTTP_COOKIE'} && $my_use_device->{'narrow_flag'} && length $near_uri > $max_length_link_text + 3){
				my $near_uri_omited_before = substr $near_uri , 0 , $max_length_link_text;
				my $near_uri_omited_after = substr $near_uri , $max_length_link_text;
				$link_text = qq($http_text$near_uri_omited_before<span style="font-size:1%;">$near_uri_omited_after</span>);
				$return_text = qq($before_text<a href="$url"$blank$nofollow_tag>$link_text</a>);
			} else {
				$link_text = $url;
				$return_text = qq($before_text<a href="$url"$blank$nofollow_tag>$link_text</a>);
			}


	}

return($return_text);

}

#-----------------------------------------------------------
# 正規のURLをチェック
#-----------------------------------------------------------
sub justy_url_check{

my($url) = @_;
my $justy_url;

# 全ドメインを取得
my($justy_domain_flag) = Mebius::Init::AllDomains({ TypeJustyCheck => 1 , URL => $url });

	if($justy_domain_flag){
		return $url;
	}

}


#-----------------------------------------------------------
# パラメータ(または引数)を元にリダイレクトする
#-----------------------------------------------------------
sub redirect_to_back_url{

my($select_url) = @_;
my($to_back_url,$flag);

	if($select_url){
		$to_back_url = $select_url;
	} else {
		my($q) = Mebius::query_state();
		$to_back_url = $q->param('backurl');
	}

	if(justy_url_check($to_back_url)){
		Mebius::redirect($to_back_url);
		$flag = 1;
	}


$flag;

}



#-----------------------------------------------------------
# 戻り先の hidden フォーム部品を所得
#-----------------------------------------------------------
sub back_url_param{
my($backurl) = back_url_auto();
$backurl->{'url_param'};
}

#-----------------------------------------------------------
# 戻り先の hidden フォーム部品を所得
#-----------------------------------------------------------
sub back_url_input_hidden{
my $self = shift;
my($backurl) = back_url_auto({ TypeRequestURL => 1 });
$backurl->{'input_hidden'};
}


#-----------------------------------------------------------
# 戻り先の hidden フォーム部品を所得
#-----------------------------------------------------------
sub back_url_hidden{
my $self = shift;
my($backurl) = back_url_auto();
$backurl->{'input_hidden'};
}

#-----------------------------------------------------------
# 戻り先の hidden フォーム部品を所得
#-----------------------------------------------------------
sub back_url_href{
my($backurl) = back_url_auto();
$backurl->{'url'};
}


#-----------------------------------------------------------
# 戻り先の hidden フォーム部品を所得
#-----------------------------------------------------------
sub back_url_encoded{
my($backurl) = back_url_auto();
$backurl->{'url_encoded'};
}

#-----------------------------------------------------------
# 現在のURL
#-----------------------------------------------------------
sub back_url_return_page{

my $return;

my($request_url) = Mebius::request_url();
($return) = back_url($request_url);

$return;

}

#-----------------------------------------------------------
# 汎用処理
#-----------------------------------------------------------
sub back_url_auto{

my $return;
my($q) = Mebius::query_state();
my($request_url) = Mebius::request_url();

	if($q->param('backurl')){
		($return) = back_url($q->param('backurl'));
	} else {
		($return) = back_url($request_url);
	}

$return;

}

#-----------------------------------------------------------
# 戻り先
#-----------------------------------------------------------
sub back_url{

# 宣言
my $use = shift if(ref $_[0] eq "HASH");
my $select_url = shift;
my($justy_flag,$url,%backurl);

	# URLを定義
	if($select_url){
		$url = $select_url;
	}elsif($use->{'url'}){
		$url = $use->{'url'};
	} elsif ($use->{'TypeRequestURL'}){
		($url) = Mebius::request_url();
	} else {
		return();
	}

# 全ドメインを取得
($backurl{'justy_flag'}) = Mebius::justy_url_check($url);

	# 正規のドメインだった場合
	if($backurl{'justy_flag'}){

		# URLを定義
		$backurl{'url'} = $url;

		# エンコード
		($backurl{'url_encoded'}) = Mebius::Encode(undef,$backurl{'url'});

		# URL用
		$backurl{'url_param'} = "&amp;backurl=$backurl{'url_encoded'}";
	
		# インプット用
		$backurl{'input_hidden'} = qq(<input type="hidden" name="backurl" value=") . Escape::HTML([$backurl{'url'}]) . qq(">);
		$backurl{'input_hidden_return_page'} = qq(<input type="hidden" name="backurl_return_page" value=") . Escape::HTML([$backurl{'url'}]) . qq(">);

	}


# リターン
\%backurl;

}


#-----------------------------------------------------------
# Canonicalを自動設定
#-----------------------------------------------------------
sub AutoCanonical{

my($use) = @_;
my($canonical);

	# https の URL は http に canonical を設定 
	if($use->{'TypeHttpsToHttp'}){

			# 各種条件を判定
			if($ENV{'SERVER_PORT'} eq "443" && $ENV{'REQUEST_METHOD'} eq "GET"){

					# 現在のURLを取得してエスケープし、 canonical タグを定義
					my($http_request_uri) = Mebius::request_url({ ProcotolSelect => "Http" });
					my($http_request_uri_escaped) = Escape::HTML([$http_request_uri]);
					$canonical = qq(<link rel="canonical" href="$http_request_uri">\n);
			}

	}

return($canonical);


}

#-----------------------------------------------------------
# 現在のURL (エンコード済み)
#-----------------------------------------------------------
#sub request_url_encoded{

#my($return) = requesr_url({ TypeEncode => 1})

#}

#-----------------------------------------------------------
# 現在のURLを取得
#-----------------------------------------------------------
sub request_url{

# 宣言
my($use) = @_;
my($url,$http);

# ドメインを取得
my($server_domain) = Mebius::server_domain();

	# ポートを定義する場合
	if($use->{'ProcotolSelect'} eq "Https"){ $http = "https"; }
	elsif($use->{'ProcotolSelect'} eq "Http"){ $http = "http"; }
	else{ ($http) = Mebius::ProcotolType(); }

	# Procotolが存在する場合
	if($http){
		$url = "${http}://$server_domain$ENV{'REQUEST_URI'}";
	}
	else{
		return();
	}

	# エンコードする場合
	if($use->{'TypeEncode'}){
		($url) = Mebius::Encode(undef,$url);
	}

	# エスケープする場合
	if($use->{'TypeEscape'}){
		($url) = Escape::HTML([$url]);
	}

return($url);

}

#-----------------------------------------------------------
# 現在のURL
#-----------------------------------------------------------

sub request_url_encoded{

my($request_url) = Mebius::request_url();

my($request_url_encoded) = Mebius::Encode(undef,$request_url);

$request_url_encoded;

}


#-----------------------------------------------------------
# エンコード済みの現在URL
#-----------------------------------------------------------
#sub server_url_encoded{

#my($server_url) = Mebius::server_url();

#my($server_url_encoded) = Mebius::Encode(undef,"$server_url/");

#$server_url_encoded;

#}


#-----------------------------------------------------------
# サーバーの絶対URL ( 最後にスラッシュは付かないので注意 )
#-----------------------------------------------------------
sub server_url{

# 宣言
my $self = shift;
my($server_url,$StateName1);

# URLを定義
my($http) = Mebius::ProcotolType();
my($server_domain) = Mebius::server_domain();

	# 絶対URLを定義
	if($http && $server_domain){
			$server_url = "$http://$server_domain";
	}

return($server_url);

}

#-----------------------------------------------------------
# http か https か
#-----------------------------------------------------------
sub procotol_type{

my($use) = @_;
my($procotol);

	# プロコトルを定義
	if($ENV{'SERVER_PORT'} eq "443"){ $procotol = "https"; }
	elsif($ENV{'SERVER_PORT'} eq "80"){ $procotol = "http"; }
	else{ return(); }

return($procotol);


}
#-----------------------------------------------------------
# Http か Https か
#-----------------------------------------------------------
sub ProcotolType{

my($return) = procotol_type(@_);

$return;

}


1;