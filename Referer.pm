
package Mebius;
use Mebius::Encode;
use strict;

#-----------------------------------------------------------
# リファラ判定
#-----------------------------------------------------------
sub Referer{

# 宣言
my($type,$referer) = @_;
my($referer_type,$hit,$bbs_type,$domain,$moto,$number,$return_type,@domains);

# リファラをデスケープ
($referer) = Mebius::Descape("",$referer);

# ドメイン
@domains = @main::domains;
push(@domains,"aurasoul.vis.ne.jp");

	# リファラ判定
	foreach(@domains){

		# 自ドメイン判定
		if($referer =~ m!^http://($_)/!){ $return_type .= " mydomain"; }

		# リファラ元が掲示板記事の場合（１）
		if($referer =~ m!^http://($_)/_([a-z0-9]+)/(k)?([0-9]+)(_[0-9]+|_data|_memo|_all)?\.html([0-9\-\,]+)?$!){

			my ($domain,$moto,$kflag,$number,$option,$resnumber) = ($1,$2,$3,$4,$5,$6);
			$resnumber =~ s/^\-//g;

			return("bbs-thread $return_type",$domain,$moto,$number,$resnumber);
		}

	}

# URLかどうかをチェック
if($referer =~ m!^http://([a-z0-9]+)\.([a-zA-Z0-9\.]+)/(.+)/!){ return("url"); }

# リターン
return();

}


1;
