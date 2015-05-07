
use strict;
package Mebius::BBS::Posted;
use Mebius::Export;

#-----------------------------------------------------------
# 自分の最後に書き込んだレスを表示
#-----------------------------------------------------------
sub last_regist_seal{

my($bbs_kind,$thread_number,$res_number) = @_;
my($return);
my($bbs_cookie) = Mebius::Cookie::get("bbs");
my($basic_init) = Mebius::basic_init();
my($my_use_device) = Mebius::my_use_device();

	# 前回の投稿から一定時間が経過している場合は、無条件にリターン
	if(time > $bbs_cookie->{'last_regist_time'} + 30){ return(); }

	# 自分の最後に投稿したレスでなければリターン
	if("$bbs_kind-$thread_number-$res_number" ne "$bbs_cookie->{'last_regist_bbs_kind'}-$bbs_cookie->{'last_regist_thread_number'}-$bbs_cookie->{'last_regist_res_number'}"){ return(); }

my($class);

	if($my_use_device->{'mobile_flag'}){
		$return .= qq(<div style="background:#ff8;padding:0.5em;">);
	} else {
		$return .= qq(<div class="message-yellow black size100 line-height-large">);
	}

$return .= qq(<p>);

	# 時刻表示する場合
	if(time >= $bbs_cookie->{'last_regist_time'} + 5){
		my($how_before) = Mebius::second_to_howlong({ TopUnit => 1 , HowBefore => 1 } , time - $bbs_cookie->{'last_regist_time'});
		$return .= e($how_before).qq(に);
	}

$return .= qq(投稿しました。);
$return .= qq(</p>);

$return .= q(<p> \( ).e($bbs_cookie->{'last_regist_words_length'}).q(文字 / ).q(獲得金貨 );
$return .= q(<a href=").e($basic_init->{'main_url'}).q(rankgold-p-1.html">).q(</a>);

	# 獲得金貨がプラスの場合の色づけ
	if($bbs_cookie->{'last_get_gold_num'} >= 1){
		$class = "red";
	# 獲得金貨がマイナスの場合の色づけ
	} elsif($bbs_cookie->{'last_get_gold_num'} <= -1) {
		$class = "blue";
	}

$return .= q(<strong class=").e($class).q(">).e($bbs_cookie->{'last_get_gold_num'}).q(枚</strong> <img src="/pct/icon/gold2.gif" alt="金貨" title="金貨" class="noborder"> \) </p></div>);


$return;


}


1;
