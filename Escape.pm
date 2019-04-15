
use strict;
package Mebius::Escape;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {

my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 別名
#-----------------------------------------------------------
sub e{
my(@results) = Escape::HTML(@_);
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub decode_html{

my $self = shift;
my $text = shift;
my $use = shift;

# 多重エスケープを予防
$text =~ s/&amp;/&/g;
$text =~ s/&lt;/</g;
$text =~ s/&gt;/>/g;

	if(!$use->{'NotValue'} && !$use->{'Javascript'}){
		$text =~ s/&#0?39;/'/g;
	}

	# タグ内の属性エスケープ
	if(!$use->{'NotValue'}){
		$text =~ s/&quot;/"/g;
	}

$text;

}

# パッケージ宣言
package Escape;

#-----------------------------------------------------------
# HTMLエスケープ
#-----------------------------------------------------------
sub HTML{

# 宣言
my($html,$use) = @_;
my $escape = new Mebius::Escape;
my(@escaped_html,$count_escaped);

	# 要素を展開
	foreach(@$html){

		# 定義
		my $html_foreach = $_;

		# 汚染チェック
		$html_foreach =~ s/[\0]//g;
		$html_foreach = $escape->decode_html($html_foreach);

		#$html_foreach =~ s/[\n\r]//g;

		# タグ変換
		$count_escaped += ($html_foreach =~ s/&/&amp;/g);

		$count_escaped += ($html_foreach =~ s/</&lt;/g);
		$count_escaped += ($html_foreach =~ s/>/&gt;/g);

			if(!$use->{'NotValue'} && !$use->{'Javascript'}){
				$count_escaped += ($html_foreach =~ s/'/&#039;/g);
			}

			# タグ内の属性エスケープ
			if(!$use->{'NotValue'}){
				$count_escaped += ($html_foreach =~ s/"/&quot;/g);
			}


		# 配列に追加
		push(@escaped_html,$html_foreach);

	}

	# リターン
	if(@escaped_html <= 1){
		return($escaped_html[0]);
	}
	else{
		return(@escaped_html);
	}

}

#-----------------------------------------------------------
# Javascript
#-----------------------------------------------------------
sub javascript{

my $text = shift;
my $self = javascript_multi($text);

}

#-----------------------------------------------------------
# Javascript
#-----------------------------------------------------------
sub javascript_high{

my $text = shift;
my $self = javascript_multi({ High => 1 },$text);

}


#-----------------------------------------------------------
# Javascript
#-----------------------------------------------------------
sub javascript_multi{

my $use = shift if(ref $_[0] eq "HASH");
my $text = shift;

	if($use->{'High'}){
		$text =~ s/[\n\r]/\\\\n/g;
		$text =~ s/"/&quot;/g;
		$text =~ s/</&lt;/g;
		$text =~ s/>/&gt;/g;
	} else {
		$text =~ s/[\n\r]/\\\\n/g;
	}

$text =~ s/'/\\'/g;
$text =~ s/"/\\"/g;
$text =~ s!/!\\/!g;

$text =~ s/[\r\n]//g;

$text;

}






1;