
# パッケージ宣言
use strict;
package Mebius;

#-----------------------------------------------------------
# ジャンプ
#-----------------------------------------------------------
sub jump{

# 宣言
my($type,$url,$sec,$message) = @_;

# 調整
	if($url eq ""){ return; }
	if($sec =~ /[^0-9]/){ return; }
	if($sec eq ""){ $sec = 1; }

# HTML
my $print = qq(
$message
$sec秒後にジャンプします。(<a href="$url">→進む</a>)
);

Mebius::Template::gzip_and_print_all({ RefreshSecond => $sec , RefreshURL => $url , source => "utf8" },$print);


exit;

}

1;
