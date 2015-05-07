
use strict;
use Mebius::Encoding;
package Mebius::BBS::Form;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new{

my $class = shift;
my $self = {};
bless $self ,$class;
}

#-----------------------------------------------------------
# 記事アップ
#-----------------------------------------------------------
sub thread_up{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($my_cookie) = Mebius::my_cookie_main_logined();
my($my_account) = Mebius::my_account();
my $html = new Mebius::HTML;
my $history = new Mebius::History;
my($return,$checked);

	if($use->{'Hidden'}){

		$return .= qq(<input type="hidden" name="thread_up" value=") . esc($my_cookie->{'thread_up'}) . qq(">);

	} else{

		my $accesskey =  qq(accesskey="7") if(!$use->{'MobileView'});
		my($query) = Mebius::query_state();
		my($parts) = Mebius::Parts::HTML();

			if($ENV{'REQUEST_METHOD'} eq "POST"){
					if($query->param('thread_up') eq "1"){
						$checked = $parts->{'checked'};
					}
			} else {
					if($my_cookie->{'thread_up'} ne "2"){
						$checked = $parts->{'checked'};
					}
			}



			# パーツを最終定義
			{
					if(!$use->{'MobileView'}){ $return .= qq(<label>); }
				$return .= qq(<input type="checkbox" name="thread_up" value="1") . esc($checked) . esc($accesskey) . esc($checked) . qq(>);
					if($use->{'MobileView'}){
						$return .= qq(ｱｯﾌﾟ);
					} else {
						$return .= qq(<span>アップ</span>);
					}
					if(!$use->{'MobileView'}){ $return .= qq(</label>); }


				$return .= " " . $history->tell_my_friends_input_tag();

					if($use->{'from_encoding'}){
						Mebius::Encoding::from_to("utf8",$use->{'from_encoding'},$return);
					}
			}

	}


$return;

}

#-----------------------------------------------------------
# ID履歴
#-----------------------------------------------------------
sub history{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $return;

my($id_history_judge) =  Mebius::BBS::id_history_level_judge();

my $return = $id_history_judge->{'input'};


	if($use->{'from_encoding'}){
		Mebius::Encoding::from_to("utf8",$use->{'from_encoding'},$return);
	}

$return;

}

#-----------------------------------------------------------
# アカウント表示
#-----------------------------------------------------------
sub account_link{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($parts) = Mebius::Parts::HTML();
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main_logined();
my($query) = Mebius::query_state();
my($return);


	if($my_cookie->{'account_link'} ne "2"){ return(qq(<input type="hidden" name="account_link" value="1" id="account_link">\n)); }

	if($my_account->{'login_flag'}){

			my($checked);

			if($ENV{'REQUEST_METHOD'} eq "POST"){
					if($query->param('account_link')){
						$checked = $parts->{'checked'};
					}
			}	else {
					if($my_cookie->{'account_link'} ne "2"){
						$checked = $parts->{'checked'};
					}
			}

			$return .= qq( <input type="checkbox" name="account_link" value="1" id="account_link"$checked>\n);

				if($use->{'MobileView'}){
					$return .= qq(ｱｶｳﾝﾄ);
				} else {
					$return .= qq(<label for="account_link" title="筆名をアカウント ( $my_account->{'id'} ) にリンクさせます">);
					$return .= qq(アカウント表\示);
					$return .= qq(</label>\n);
				}
	}

	if($use->{'from_encoding'}){
		Mebius::Encoding::from_to("utf8",$use->{'from_encoding'},$return);
	}


$return;

}

#-----------------------------------------------------------
# お知らせ
#-----------------------------------------------------------
sub news{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($basic_init) = Mebius::basic_init();
my $return;

	if(time > 1332743538+7*24*60*60){ return(); }

$return = qq(<div class="message-red red" style="color:#f00;">※お知らせ … 投稿フォームの<a href="$basic_init->{'guide_url'}2012.03.27+%B7%C7%BC%A8%C8%C4%A5%D5%A5%A9%A1%BC%A5%E0%BB%C5%CD%CD%CA%D1%B9%B9%A4%CE%A4%AA%C3%CE%A4%E9%A4%BB" target="_blank" class="blank">仕様変更</a> があります。 ID履歴/トリップ履歴に関する変更もありますのでご確認ください。</div>);

	if($use->{'from_encoding'}){
		Mebius::Encoding::from_to("utf8",$use->{'from_encoding'},$return);
	}

$return;

}

1;
