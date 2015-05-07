

use strict;
package Mebius::Ads;
use Mebius::HTML;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new{

my $class = shift;
bless {} ,$class;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adsense_code_to_label{

my $self = shift;
my $adsense_code = shift;
my($width);

	if($adsense_code =~ /width:([0-9]+)px/){
		$width = $1;
	} else {
		return();
	}

my $print = $self->label($width);


$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub label{

my $self = shift;
my $width = shift || return();
my $html = new Mebius::HTML;
my($my_use_device) = Mebius::my_use_device();
my($print);

$print .= $html->tag("div","スポンサーリンク",{ style => "width:${width}px;background:#ebebeb;color:#666;font-size:70%;text-align:center;" });

$print;

}

#-----------------------------------------------------------
# コードのコア部分
#-----------------------------------------------------------
sub code_core{

my $class = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $select = shift;
my($self,$slot_number_smart,$comment_out_smart);

my $option =  {
	big_bunner => {
		slot_number => 7385702374 , comment_out => "general" , type => "big_bunner"
	} , 
	mobile_bunner => {
		slot_number => 6357659744 , comment_out => "general smart" , type => "mobile_bunner" 
	} , 

};

my $slot_number = $option->{$select}->{'slot_number'};
my $comment_out = $option->{$select}->{'comment_out'};
my $ad_type = $option->{$select}->{'type'};

	if(!$slot_number || !$comment_out || !$ad_type){
		die("Perl Die! Can't decide slot_number or comment_out_text or ad_type.");
	}

	{
		my($width,$height);

			if($ad_type eq "big_bunner"){
				$width = 728;
				$height = 90;
			} elsif($ad_type eq "mobile_bunner") {
				$width = 320;
				$height = 50;
			} else {
				die("Perl Die! Ad type is not in justy list. $ad_type");
			}

		$self .= qq(\n);
		$self .= qq(<script type="text/javascript"><!--\n);
		$self .= qq(google_ad_client = "ca-pub-7808967024392082";\n);
		$self .= qq(/* ).e($comment_out).qq( */\n);
		$self .= qq(google_ad_slot = ").e($slot_number).qq(";\n);
		$self .= qq(google_ad_width = ).e($width).qq(;\n);
		$self .= qq(google_ad_height = ).e($height).qq(;\n);
		$self .= qq(//-->\n);
		$self .= qq(</script>\n);
		$self .= qq(<script type="text/javascript"\n);
		$self .= qq(src="http://pagead2.googlesyndication.com/pagead/show_ads.js">\n);
		$self .= qq(</script>\n);

	}

$self;

}

#-----------------------------------------------------------
# 汎用バナー
#-----------------------------------------------------------
sub bunner{

my $class = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($my_use_device) = Mebius::my_use_device();
my($self);

	if(Mebius::alocal_judge()){
		($self) = big_bunner_dammy()
	} else {
			if($my_use_device->{'smart_flag'}){
				$self = code_core(undef,"mobile_bunner");
			} else {
				$self = code_core(undef,"big_bunner");
			}
	}

$self;

}
#-----------------------------------------------------------
# ビッグバナー ( ダミー )
#-----------------------------------------------------------
sub big_bunner_dammy{

my($my_use_device) = Mebius::my_use_device();
my($self);

	if($my_use_device->{'smart_flag'}){
		$self .= qq(<div style="width:320px;height:50px;border:solid 1px #000;margin:auto;">Ads</div>);
	} else {
		$self .= qq(<div style="width:728px;height:90px;border:solid 1px #000;margin:auto;">Ads</div>);

	}

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub big_bunner_for_pc{

my $self = shift;

my $ads = q(
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- PCレクタングル -->
<ins class="adsbygoogle"
     style="display:inline-block;width:336px;height:280px"
     data-ad-client="ca-pub-7808967024392082"
     data-ad-slot="5360237328"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
);

$ads;

}


#-----------------------------------------------------------
# 楽天のスマフォ用バナー
#-----------------------------------------------------------
sub rakuten_smart_phone_widget{

my $self = shift;

	if(!$self->rakuten_use_switch()){ return(); }

my $ads = q(
<!-- Rakuten Widget FROM HERE --><script type="text/javascript">rakuten_design="slide";rakuten_affiliateId="1186506d.de78e630.1186506e.6d663e1e";rakuten_items="ctsmatch";rakuten_genreId=0;rakuten_size="320x48";rakuten_target="_blank";rakuten_theme="gray";rakuten_border="off";rakuten_auto_mode="off";rakuten_genre_title="off";rakuten_recommend="on";</script><script type="text/javascript" src="http://xml.affiliate.rakuten.co.jp/widget/js/rakuten_widget.js"></script><!-- Rakuten Widget TO HERE -->);

$ads;

}

#-----------------------------------------------------------
# 楽天の縦長広告
#-----------------------------------------------------------
sub rakuten_vertical_widget{
my $self = shift;

	if(!$self->rakuten_use_switch()){ return(); }

my $ads = q(<!-- Rakuten Widget FROM HERE --><script type="text/javascript">rakuten_design="slide";rakuten_affiliateId="1186506d.de78e630.1186506e.6d663e1e";rakuten_items="ctsmatch";rakuten_genreId=0;rakuten_size="148x600";rakuten_target="_blank";rakuten_theme="gray";rakuten_border="off";rakuten_auto_mode="off";rakuten_genre_title="off";rakuten_recommend="on";</script><script type="text/javascript" src="http://xml.affiliate.rakuten.co.jp/widget/js/rakuten_widget.js"></script><!-- Rakuten Widget TO HERE -->);

$ads;

}


#-----------------------------------------------------------
# 楽天のほぼ正方形広告
#-----------------------------------------------------------
sub rakuten_basic_widget{
my $self = shift;

	if(!$self->rakuten_use_switch()){ return(); }

my $ads = q(<!-- Rakuten Widget FROM HERE --><script type="text/javascript">rakuten_design="slide";rakuten_affiliateId="1186506d.de78e630.1186506e.6d663e1e";rakuten_items="ctsmatch";rakuten_genreId=0;rakuten_size="300x250";rakuten_target="_blank";rakuten_theme="gray";rakuten_border="off";rakuten_auto_mode="off";rakuten_genre_title="off";rakuten_recommend="on";</script><script type="text/javascript" src="http://xml.affiliate.rakuten.co.jp/widget/js/rakuten_widget.js"></script><!-- Rakuten Widget TO HERE -->);

$ads;

}

#-----------------------------------------------------------
# Amazon の縦長広告
#-----------------------------------------------------------
sub amazon_vertical_widget{

my $self = shift;

	if(!$self->amazon_use_switch()){
		return();
	}

my $ads = q(
<script type="text/javascript"><!--
amazon_ad_tag = "diaryofmebius-22"; amazon_ad_width = "160"; amazon_ad_height = "600"; amazon_ad_border = "hide";//--></script>
<script type="text/javascript" src="http://ir-jp.amazon-adsystem.com/s/ads.js"></script>
);

$ads;

}



#-----------------------------------------------------------
# 楽天ウィジェットを使うかどうかのスイッチ
#-----------------------------------------------------------
sub rakuten_use_switch{
my $self = shift;
0;
}
#-----------------------------------------------------------
# 楽天ウィジェットを使うかどうかのスイッチ
#-----------------------------------------------------------
sub amazon_use_switch{
my $self = shift;
0;
}


1;
