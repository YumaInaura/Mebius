
# use strict;

use strict;
package Mebius::Getpage;
use LWP::Simple;

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
sub get_page{

my $self = shift;
my $url = shift;
my $html = LWP::Simple::get($url);

$html;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_on_array{

my $self = shift;
my $url = shift;
my @html = Mebius::getpage("Array",$url);

@html;
}




package Mebius;
use Socket;

#-----------------------------------------------------------
# 外部ページを取得
#-----------------------------------------------------------
sub getpage{

# 宣言
my($type,$get_url) = @_;
my($port0,$ipaddr,$domain,$sock_addr,$header,$html,@html);
my($domain,$get,$title,$request_uri,$http);

	# 禁止するＵＲＬ
	if($get_url =~ /pagead/){ return(); }

	# URLチェック
	if($get_url =~ /(https?):\/\/([a-zA-Z0-9\.]+)(.*)/){ ($http,$domain,$get) = ($1,$2,$3); } else { return(); }

	# ログを取る
	#if($main::int_dir){ main::access_log("Get-page","type : $type / Get-url : http://$domain$get"); }

$port0 = getservbyname("$http", "tcp");
$ipaddr = &Socket::inet_aton($domain) or return("ホスト名検出エラー（$domain）<br>\n");
$sock_addr = &Socket::pack_sockaddr_in($port0, $ipaddr);
socket(SOCK, PF_INET, SOCK_STREAM, 0) or return("ソケット作成エラー（ $domain / $get / $ipaddr / $port0 ）<br>\n");
connect(SOCK, $sock_addr) or return("サーバー接続エラー（ $domain / $get / $ipaddr / $port0 ）<br>\n");

select(SOCK);
$|=1;
select(STDOUT);

# リクエスト内容（改行を消さない）
print SOCK << "END_OF_DOC";
GET $get HTTP/1.0
Host:$domain
QUERY_STRING: 
Connection:close

END_OF_DOC


	# ヘッダを分離
	while(<SOCK>){
		$header .= $_;
			if(m/^\r\n$/){ last; }
	}

	# HTML置換え
	while(<SOCK>){

		push @html , $_;

		# ページタイトルを取得
		if($_ =~ m!<title>(.+)</title>!){ $title = $1; }

		while(s/</&lt;/is){ };
		while(s/>/&gt;/is){ };

		#&jcode::convert(\$_, 'sjis');
		#  while(s/\r\n|\r|\n/<br>/is){ };

		$html .= qq($_<br>);
	}

close SOCK;

	# 整形処理
	if($type =~ /Html/){
		$html =~ s/(.+)&lt;body&gt;//;
		$html =~ s/&lt;\/body&gt;(.+)//m;
	}

	# タイトル
	if($type =~ /Title/){ 
			if($type =~ /Fix-title/){
				($title) = split(/ \| /,$title);
				$title =~ s/(\r|\n|\s+$)//g;
			}
		return($title); 
	}

	# 成功ログを取る
	if($main::int_dir){ main::access_log("Get-page-successed","type : $type / Get-url : http://$domain$get / \n\n$header"); }

	if($type =~ /Header/){ return($header); }
	elsif($type =~ /Array/){ return(@html); }
	else{ return($html); }

return($header,$html,$title);

}


1;

