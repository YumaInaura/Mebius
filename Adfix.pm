
# パッケージ宣言
package Mebius;
use strict;

#-----------------------------------------------------------
# リダイレクト処理
#-----------------------------------------------------------
sub Adfix{

# 宣言
my($type,$line) = @_;
my($fixed_line);

	# ラインを展開して、管理用に整形
	if($type =~ /Url/){
		foreach(split(/(<br>|\r|\n)/,$line)){
		$_ =~ s!/_([a-z0-9]+)/([0-9]+).html!$main::admin_url$1.cgi?mode=view&amp;no=$2!g;
		$_ =~ s!/_main/!$main::admin_url!g;
		$_ =~ s!([a-z0-9]+)-([a-z0-9]+)-([a-z0-9]+).html!$main::script?mode=$1-$2-$3!g;
		$_ =~ s!/_([a-z0-9]+)/!/jak/$1.cgi!g;
		$fixed_line .= $_;
		}
	}

# リターン
return($fixed_line);

}

1;
