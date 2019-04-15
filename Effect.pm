
use strict;
package Mebius::Effect;

#-----------------------------------------------------------
# すべての効果
#-----------------------------------------------------------
sub all{

# 宣言
my $use = shift if(ref $_[0] eq "HASH");
my($text) = @_;
my($return_text,$i,$stamp_num,@error);

	#文章を展開
	foreach(split(/<br>/,$text,-1)){

		# 局所化
		my($effect);
		my $text2 = $_;

			# ラウンドカウンタ
			$i++;

			# ２ラウンド目以降は改行
			if($i >= 2){ $return_text .= qq(<br>); }

			# 引用 ( 単独 )
			if($text2 =~ /^(&gt;|＞)(.)/){
				$text2 = qq(<blockquote class="default">$text2</blockquote> );
			}

			# レス番はじまりの行
			#if($text2 =~ /^(\s+)?No\.([0-9])([0-9\-,]+)?$/){
			#	$effect .= qq( number_indent);
			#}

			# エフェクトを付与
			#if($effect){
			#	$text2 = qq(<span class="$effect">$text2</span>);
			#}

			# スタンプ
			($text2) = Mebius::Stamp::effect($text2);

		$return_text .= qq($text2);

	}




return($return_text);


}

1;
