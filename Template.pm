
use strict;
package Mebius::Template;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 全て出力する
#-----------------------------------------------------------
sub gzip_and_print_all{

my $use = shift if(ref $_[0] eq "HASH");
my $line = shift;
my($my_real_device) = Mebius::my_real_device();
my($my_use_device) = Mebius::my_use_device();
my($html_header,$html_footer);


$use->{'BodyPrint'} = 1;
$use->{'NotPrint'} = 1;

# 出力内容をまとめる
my $http_header = http_header($use);

	if(!$use->{'NoTemplateHeader'}){
		$html_header = main::header($use);
	}

	if(!$use->{'NoTemplateFooter'}){
		$html_footer = main::footer($use);
	}

	# 文字コード変換
	if($use->{'source'} eq "utf8"){

			if($my_real_device->{'mobile_flag'} || $my_use_device->{'mobile_flag'}){
				shift_jis($line,$http_header,$html_header,$html_footer);
			} else {

			}

	} else {
		shift_jis($http_header,$html_header,$html_footer);
	}

my $print_body = $html_header.$line.$html_footer;

my($gzip_type) = Mebius::Device::accept_gzip_type();

	# 圧縮可能端末の場合
	if($gzip_type){
		my $gzip = Compress::Zlib::memGzip( $print_body );
		print "Vary: Accept-Encoding\n";
		print "Content-Encoding: $gzip_type\n";
		print $use->{'http_header'};
		print $http_header;
		print $gzip;

	# 圧縮不可端末の場合
	} else {
		print "Vary: Accept-Encoding\n";
		print $http_header;
		print $use->{'http_header'};
		print $print_body;
	}

}


#-----------------------------------------------------------
# HTTP ヘッダを定義
#-----------------------------------------------------------
sub http_header{

my $use = shift if(ref $_[0] eq "HASH");
my($my_use_device) = Mebius::my_use_device();
my($my_real_device) = Mebius::my_real_device();
my($header);

	# 文書宣言
	# 携帯版
	if($my_use_device->{'mobile_flag'}){
			if($my_real_device->{'mobile_flag'} && (!Mebius::alocal_judge())){
				$header .= "Content-type: application/xhtml+xml; charset=shift_jis\n";
			}
			else{
				$header .="Content-type: text/html; charset=shift_jis\n";
			}
	# デスクトップ版 / スマフォ版
	} else {
			if($use->{'source'} eq "utf8" && !$my_real_device->{'mobile_flag'}){
				$header .= "Content-type: text/html; charset=utf-8\n";
			} else {
				$header .= "Content-type: text/html; charset=shift_jis\n";
			}
	}

$header .= "Vary: User-Agent\n";
	if(!$ENV{'REQUEST_METHOD'} ne "POST"){
		$header .= "Pragma: no-cache\n";
		$header .= "Cache-Control: no-cache\n";
	}
$header .= "\n";

$header;

}

1;
