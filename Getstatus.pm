
use strict;

package Mebius::GetPage;

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
sub get_status{

my $self = shift;
Mebius::Getstatus(undef,@_);
}


package Mebius;

#-----------------------------------------------------------
# ステータスコードを取得
#-----------------------------------------------------------
sub Getstatus{

# 宣言
my($type,$url) = @_;
my($notfound_flag);

# 禁止するＵＲＬ
if($url =~ /pagead/){ return(); }

	# 無限ループを禁止
	if($type !~ /Command/){
		if($main::agent =~ /libwww-perl/ || $main::agent eq ""){ return(); }
	}

# URLをデスケープ
($url) = Mebius::Descape("",$url);

use LWP::UserAgent;
my $ua = new LWP::UserAgent();
if($main::alocal_mode){ $ua->parse_head(0); }
my $head = $ua->head($url);

my $code = $head->code();
my $message = $head->message();

# 記録
main::access_log("GETSTATUS","GetUrl : $url / Status: $code - $message");

# NotFound系の場合、フラグを立てる
if($code eq "404" || $code eq "403" || $code eq "410" || $code eq ""){ $notfound_flag = 1; }

	if(wantarray){
		return($code,$message,$notfound_flag);
	} else {
		return($code);
	}


}

1;
