
use strict;
use Mebius::Time;
package Mebius;
use Mebius::Export;

#-----------------------------------------------------------
# イベントHTML
#-----------------------------------------------------------
sub ivent_html{

my($self,$message);

	# メビウスリングの誕生日
	if(mebius_ring_birthday_judge()){
		my($how_aniversary) = how_aniversary_mebius_ring();
		$message = qq(今日はメビウスリングの <strong class="red">).e($how_aniversary).qq(回目</strong> の誕生日です。);
	}

	# 整形
	if($message){
		$self = qq(<div class="message-yellow center clear" style="margin:0em;border-bottom:none;">$message</div>);
	}

$self;

}

#-----------------------------------------------------------
# 今日がメビウスリングの誕生日かどうかを判定
#-----------------------------------------------------------
sub mebius_ring_birthday_judge{

my($self);
my($date) = Mebius::now_date_multi();

	if("$date->{'month'}-$date->{'day'}" eq "10-11"){
		$self = 1;
	}

$self;

}

#-----------------------------------------------------------
# 誕生日の場合、メビウスリングが何周年かを計算
#-----------------------------------------------------------
sub how_aniversary_mebius_ring{

my($self);
my($date) = Mebius::now_date_multi();

$self = $date->{'year'} - 2004;

$self;

}


1;