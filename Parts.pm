
use strict;
package Mebius::Parts;

#-----------------------------------------------------------
# ベーシックなパーツ
#-----------------------------------------------------------
sub HTML{

# 宣言
my($use,$device) = @_;
my(%parts);

# デバイスを取得
#my($use_device) = Mebius::my_use_device();
#my($real_device) = Mebius::my_real_device();

	# HTML5 の場合
	if($use->{'TypeHTML4'}){
		$parts{'input_type_email'} = "text";
		$parts{'input_type_search'} = "text";
	}
	# それ以外の場合
	else{
		$parts{'input_type_email'} = "email";
		$parts{'input_type_search'} = "search";
	}

	# Mobile-HTMLの場合
	if($use->{'TypeMobile'}){
		$parts{'selected'} = qq( selected="selected");
		$parts{'checked'} = qq( checked="checked");
		$parts{'disabled'} = qq( disabled="disabled");
	}
	# それ以外の場合
	else{
		$parts{'selected'} = " selected";
		$parts{'checked'} = " checked";
		$parts{'disabled'} = " disabled";
	}

return(\%parts);

}


1;
