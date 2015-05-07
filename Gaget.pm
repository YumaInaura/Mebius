
# 宣言
use strict;
package Mebius::Gaget;
use Mebius::URL;
use Mebius::Export;

#-----------------------------------------------------------
# Bless
#-----------------------------------------------------------
sub new{
my $class = shift;
bless {} , $class;
}

#-----------------------------------------------------------
# メビリンSNSの日記ボタン
#-----------------------------------------------------------
sub mebius_diary_button{

# 宣言
my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $comment = shift;
my $subject = shift;
my $comment_encoded = Mebius::Encode(undef,$comment);
my $subject_encoded = Mebius::Encode(undef,$subject);
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
#my($request_url_encoded) = Mebius::request_url_encoded();
my $self;

$self = qq(<a href=").e($basic_init->{'auth_url'}).qq(?mode=fdiary&amp;subject=).e($subject_encoded).qq(&amp;comment=).e($comment_encoded).qq(&amp;account=).e($my_account->{'id'}).qq(">日記</a>);

$self;


}

#-----------------------------------------------------------
# ツイートボタン
#-----------------------------------------------------------
sub tweet_button{

# 宣言
my $self = shift;
my $use = shift;
my($botton,$data_size,$data_count,$data_url,$data_text,$data_via,$data_related);

	# ボタンのサイズ
	if($use->{'Large'}){
		$data_size = qq( data-size="large");
	}

	# ツイート数を表示するかどうか
	if(!$use->{'DataCount'}){
		$data_count = qq( data-count="none");
	}

	# URL指定
	if($use->{'url'}){
		$data_url = qq( data-url=").e($use->{'url'}).qq(");
	}

	# URL指定
	if($use->{'text'}){
		$data_text = qq( data-text=").e($use->{'text'}).qq(");
	}

	if( my $account = $use->{'twitter_account'}){
		$data_related = qq( data-related="mb2jp");
		$data_via = qq( data-via="mb2jp");
	}

my $link = qq(<a href="#" class="twitter-share-button" data-lang="ja" ${data_related}${data_via}${data_size}${data_count}${data_url}${data_text}></a>);
$botton .= qq(<script>document.write('$link');</script>);


return($botton);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub twitter_javascript{

"
<script>
(function() {
	var po = document.createElement('script');
	po.type = 'text/javascript';
	po.async = true;
	po.src = 'http://platform.twitter.com/widgets.js';
	var s = document.getElementsByTagName('script')[0];
	s.parentNode.insertBefore(po, s);
	})();
</script>
";

}

#-----------------------------------------------------------
# LINE で送る
#-----------------------------------------------------------
sub line_button{

my $self = shift;

my($my_use_device) = Mebius::my_use_device();

my $print = qq(
<script type="text/javascript" src="http://media.line.naver.jp/js/line-button.js?v=20131101" ></script>
<script type="text/javascript">
new jp.naver.line.media.LineButton({"pc":false,"lang":"ja","type":"b"});
</script>
);

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub line_javascript{

my $self = shift;
my $javascript = qq(<script type="text/javascript" src="http://media.line.naver.jp/js/line-button.js" ></script>);
$javascript;
"";
}

#-----------------------------------------------------------
# Google +1 ボタン
#-----------------------------------------------------------
sub google_plusone_button{

my $self = shift;

return();

# 宣言
my($type) = @_;
my($botton);

	if($ENV{'HTTP_USER_AGENT'} =~ /MSIE (5|6|7|8)/){ return(); }

$botton = qq( <g:plusone size="medium" annotation="none"></g:plusone>);

return($botton);

}

#-----------------------------------------------------------
# Google +1 ボタン
#-----------------------------------------------------------
sub google_plusone_script{

my $self = shift;

return();


	if($ENV{'HTTP_USER_AGENT'} =~ /MSIE (5|6|7|8)/){ return(); }

my $script = qq(
<script type="text/javascript">
  window.___gcfg = {lang: 'ja'};
  (function() {
    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
    po.src = 'https://apis.google.com/js/plusone.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
  })();
</script>
);


$script;

}


#-----------------------------------------------------------
# Google +1 ボタン 補完コード？
#-----------------------------------------------------------
sub google_plusone_fotter_code{

my $self = shift;

return();


my $line;

	if($ENV{'HTTP_USER_AGENT'} =~ /MSIE (5|6|7|8)/){ return(); }

	# ソーシャルボタン用
	# Google +1 ボタン用 (非同期コード)

$line .= qq(\n<script type="text/javascript">\n);
$line .= qq(<!--\n);
$line .= qq(gapi.plusone.go();\n);
$line .= qq(// -->\n);
$line .= qq(</script>\n);


}

#-----------------------------------------------------------
# Google Analytics
#-----------------------------------------------------------

sub google_analytics{

my $self = shift;

return();

my $code = q(
<script type="text/javascript" src="/skin/google_analytics.js"></script>
);

$code;

}


#-----------------------------------------------------------
# Google カスタム検索ボックス
#-----------------------------------------------------------
sub google_search_box{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($my_use_device) = Mebius::my_use_device();
my($google_search_box);

	if($my_use_device->{'smart_flag'}){

			if($use->{'source'} eq "utf8"){

				$google_search_box = qq(
				<form action="http://www.google.co.jp/cse" id="cse-search-box">
				  <div>
				    <input type="hidden" name="cx" value="partner-pub-7808967024392082:8601881322" />
				    <input type="hidden" name="ie" value="UTF-8" />
				    <input type="text" name="q" size="30" />
				    <input type="submit" name="sa" value="検索" />
				  </div>
				</form>

				<script type="text/javascript" src="http://www.google.co.jp/coop/cse/brand?form=cse-search-box&amp;lang=ja"></script>
				);

			} else {
				$google_search_box = qq(
				<form action="http://www.google.co.jp/cse" id="cse-search-box">
				  <div>
				    <input type="hidden" name="cx" value="partner-pub-7808967024392082:3089660928">
				    <input type="hidden" name="ie" value="Shift_JIS">
				    <input type="text" name="q" size="30">
				    <input type="submit" name="sa" value="検索">
				  </div>
				</form>

				<script type="text/javascript" src="http://www.google.co.jp/coop/cse/brand?form=cse-search-box&amp;lang=ja"></script>
				);

			}

	} else {

			if($use->{'source'} eq "utf8"){
				$google_search_box = qq(
					<form action="http://www.google.co.jp/cse" id="cse-search-box">
					  <div>
					    <input type="hidden" name="cx" value="partner-pub-7808967024392082:1416691729" />
					    <input type="hidden" name="ie" value="UTF-8" />
					    <input type="text" name="q" size="55" />
					    <input type="submit" name="sa" value="検索" />
					  </div>
					</form>

					<script type="text/javascript" src="http://www.google.co.jp/coop/cse/brand?form=cse-search-box&amp;lang=ja"></script>
				);
			} else {
				$google_search_box = qq(
				<form action="http://www.google.co.jp/cse" id="cse-search-box">
				  <div>
				    <input type="hidden" name="cx" value="partner-pub-7808967024392082:1612927722" />
				    <input type="hidden" name="ie" value="Shift_JIS" />
				    <input type="text" name="q" size="55" />
				    <input type="submit" name="sa" value="検索" />
				  </div>
				</form>

				<script type="text/javascript" src="http://www.google.co.jp/coop/cse/brand?form=cse-search-box&amp;lang=ja"></script>
				);
			}

	}

$google_search_box =~ s/\t//g;

$google_search_box;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub facebook_button{

my $self = shift;
my $url = new Mebius::URL;
my $target_url = Mebius::request_url();

my $print .= qq(<div class="fb-like" data-href=").e($target_url).qq(" data-layout="button_count" data-action="like" data-show-faces="true" data-share="true"></div>);
$print;
}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub facebook_javascript{

qq(
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/ja_JP/all.js#xfbml=1";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
);

}


1;
