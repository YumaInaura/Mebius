
package Mebius;

#-----------------------------------------------------------
# URLを修正
#-----------------------------------------------------------

sub Fixurl{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$url) = @_;

my $jak_directory = "/jak/";

	# ●管理用から普通用へ (投稿時)
	if($type =~ /Admin-to-normal/){

		# シャープ以降を削除
		$url =~ s/#S([0-9]+)//g;
		$url =~ s/#(RES|RESNUMBER)//g;

		# レス番
		$url =~ s/&gt;&gt;([0-9]+)/No\.$1/g;

		# 無駄な引数をなくす
		$url =~ s/&amp;(wdhost|wdage|wdac|all)=([0-9])//g;
		#$url =~ s/&amp;backurl=(.+?)($| |(<br>)|#|&amp;)/$2/g;
		$url =~ s/(\?|&amp;)backurl=([\w\%]+)//g;

		# 削除依頼掲示板での、レポーター用の引数を削除
		$url =~ s/(\?|&amp;)reporter_(id|host|trip|account|agent|cnumber)=([\w\%]+)//g;

		# レス表示
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9]+)&amp;No=([0-9\-]+)/\/_$1\/$2\.html-$3/g;

		# 各レス
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9]+)&amp;r=([0-9a-z\-]+)/\/_${1}\/${2}_${3}.html/g;
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9]+)&amp;No=([0-9\-]+)#S([0-9]+)/\/_$1\/$2\.html-$3/g;

		# 携帯版をＰＣ版へ
		$url =~ s/\/_([a-z0-9\_]+)\/k([0-9_])\.html/\/_$1\/$2\.html/g;

		# 記事内検索
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9]+)&amp;word=(.+)/\/_$1\/?mode=view&amp;no=$2&amp;word=$3/g;

		# 個別記事
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9a-z]+)/\/_$1\/$2\.html/g;

		# 記事検索結果
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=find&amp;([a-zA-Z0-9\%\&\=]+)/\/_$1\/?mode=find&amp;$2/g;

		# お絵かきページ
		$url =~ s!${main::main_url}\?mode=pallet-viewer-([a-z0-9]+)-([0-9]+)-([0-9]+)!/_main/pallet-viewer-$1-$2-$3.html!g;

		# 掲示板ＴＯＰ
		$url =~ s!${jak_directory}([a-z0-9]+).cgi($|[^\?])!/_$1/$2!g;

		# CGI汎用
		$url =~ s!${jak_directory}(\w+?).cgi\?mode=([\w-]+)!/_$1/$2.html!g;

		# 「jak」「～.cgi」をなくす
		$url =~ s/${jak_directory}/\//g;
		$url =~ s/([\w]+)\.cgi//g;

		# 自動入力文、エスケープ
		$url =~ s/\[%\]/%/g;

			# 書き込み時のオートリンク
			if($main::in{'auto_link'}){
				foreach(@main::auto_link_tag){
				my($ch_txt,$ch_url)= split(/=/,$_);
					$url =~ s/\Q$ch_txt\E/<a href=\"${main::guide_url}$ch_url\">$1$ch_txt\<\/a>/g;
				}
			}

			# ドメインを展開
			foreach(@main::all_domains){
				# https を http に
				$url =~ s!https://$_/!http://$_/!g;
			}
	}


	# ●普通用から管理用へ
	if($type =~ /Normal-to-admin/){
		
		# MOVEリンク消去
		$url  =~ s/([0-9a-z\-]+)#a/$1/g;
		$url  =~ s/([0-9a-z\-]+)#c/$1/g;

		# 旧、多重ディレクトリ
		$url  =~ s/_([0-9a-z]+)_([0-9a-z]+)\//_$1\//g;

		# 携帯版ＵＲＬをＰＣ版ＵＲＬに
		#$url =~ s/_([0-9a-z]+)\/km0.html/_$1\//g;
		#$url =~ s/_([0-9a-z]+)\/k([0-9a-z]+)\.html/_$1\/$2\.html/g;
		#$url =~ s/_([0-9a-z]+)\/k([0-9]+)/_$1\/$2/g;

		# 個別レスＵＲＬ
		$url =~ s/_([a-z0-9]+)\/([0-9]+)\.html-([0-9,\-]+)/jak\/$1\.cgi?mode=view&amp;no=$2&amp;No=$3#RESNUMBER/g;
		$url =~ s/#RESNUMBER#S([0-9]+)/#S$1/g;
		$url =~ s/#RESNUMBER#RESNUMBER//g;

		# 記事ＵＲＬ
		$url =~ s/_([a-z0-9]+)\/([0-9]+)\.html/jak\/$1\.cgi?mode=view&amp;no=$2/g;

		if($type =~ /Multi-fix/){
			$url =~ s/(\w+)-(\w+)-(\w+)-(\w+).html/$main::realmoto\.cgi?mode=$1-$2-$3-$4/g;
			$url =~ s/(\w+)-(\w+)-(\w+).html/$main::realmoto\.cgi?mode=$1-$2-$3/g;
			$url =~ s/(\w+)-(\w+).html/$main::realmoto\.cgi?mode=$1-$2/g;
			$url =~ s/(\.\/)?([0-9]+)\.html/$1$main::realmoto\.cgi?mode=view&amp;no=$2/g;
			$url =~ s/(\w+).html/$main::realmoto\.cgi?mode=$1	/g;
		}

		# 記事ページめくりのＵＲＬ
		$url =~ s/_([a-z0-9]+)\/([0-9]+)_([0-9a-z]+)\.html/jak\/$1\.cgi?mode=view&amp;no=$2&amp;r=$3/g;

		# 掲示板インデックスＵＲＬ
		$url =~ s/_([a-z0-9]+)\/([^0-9a-z])/jak\/$1\.cgi$2/g;

		# ルールページ
		$url =~ s/rule.html/?mode=rule/g;

		# お絵かきページ
		#$url =~ s!/_main/pallet-viewer-([a-z0-9]+)-([0-9]+)-([0-9]+)\.html!${main::main_url}?mode=pallet-viewer-$1-$2-$3!g;

		# 汎用URL ◯-◯-◯-.html
		$url =~ s!/_(main)/(.+)(\-[.]+)?(\-[.]+)?(\-[.]+)?\.html!/jak/$1.cgi?mode=$2$3$4!g;

		# CGI汎用
		#$url =~ s!/_(\w+)/([\w-]+).html!/jak/$1.cgi\?mode=$2!g;

		# SNS
		$url =~ s/jak\/auth.cgi/_auth\//g;

		# SSL
		$url =~ s!h?ttp://([a-zA-Z0-9\.]+)/jak/!$basic_init->{'admin_http'}://$1/jak/!g

	}

return($url);

}

1;

