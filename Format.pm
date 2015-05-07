
use strict;
package Mebius::Format;

#-----------------------------------------------------------
# IPアドレス之フォーマット
#-----------------------------------------------------------
sub HostAddr{

# 宣言
my($type,$text) = @_;
my($file_type);

	# IPアドレス判定
	if($text =~ /^(\d{1,4}\.\d{1,4}\.\d{1,4}\.\d{1,4})$/){
		$file_type = "addr";
	}
	elsif($text =~ /^([a-zA-Z0-9\-\.]+)\.([a-zA-Z]{2,4})$/){
		$file_type = "host";
	}

# リターン
return($file_type);

}

1;
