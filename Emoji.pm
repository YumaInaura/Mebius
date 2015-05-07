use strict;
package Mebius;

#-----------------------------------------------------------
# 端末ごとに絵文字を振り分け
#-----------------------------------------------------------

sub Emoji{

# 宣言
my($type,$device_id) = @_;
my(%emoji);

	# Docomo
	if($device_id eq "DOCOMO"){

		# 第一種バイナリデータ
		$emoji{'write'} = '';
		$emoji{'exclamation'} = '';
		$emoji{'new'} = '';
		$emoji{'up'} = '';
		$emoji{'mail'} = '';
		$emoji{'heart1'} = '';
		$emoji{'heart2'} = '';
		$emoji{'heart3'} = '';
		$emoji{'home'} = '';
		$emoji{'smile'} = '';
		$emoji{'sad'} = '';
		$emoji{'search'} = '';
		$emoji{'alert'} = '';
		$emoji{'night'} = '';
		$emoji{'sun'} = '';
		$emoji{'panic'} = '';
		$emoji{'wrench'} = '';
		$emoji{'mobile'} = '';
		$emoji{'hat'} = '';
		$emoji{'number1'} = '';
		$emoji{'number2'} = '';
		$emoji{'number3'} = '';
		$emoji{'number4'} = '';
		$emoji{'number5'} = '';
		$emoji{'number6'} = '';
		$emoji{'number7'} = '';
		$emoji{'number8'} = '';
		$emoji{'number9'} = '';
		$emoji{'number0'} = '';
	}

	# AU
	elsif($device_id eq "AU"){

		# Shift-jisコード
		$emoji{'write'} = "&#xF7DA;";
		$emoji{'exclamation'} = "&#xF65A;";
		$emoji{'new'} = '&#xF7E5;';
		$emoji{'up'} = '&#xF6E8;';
		$emoji{'mail'} = '&#xF6FA;';
		$emoji{'heart1'} = '';
		$emoji{'heart2'} = '';
		$emoji{'heart3'} = '';
		$emoji{'home'} = '&#xF7E0;';
		$emoji{'smile'} = '';
		$emoji{'sad'} = '';
		$emoji{'search'} = '';
		$emoji{'alert'} = '';
		$emoji{'night'} = '';
		$emoji{'sun'} = '';
		$emoji{'panic'} = '';
		$emoji{'hat'} = '&#xF3C9;';
		$emoji{'mobile'} = '&#xF7A5;';
		$emoji{'wrench'} = '&#xF7A4;';
		$emoji{'number1'} = "&#xF6FB;";
		$emoji{'number2'} = "&#xF6FC;";
		$emoji{'number3'} = "&#xF740;";
		$emoji{'number4'} = "&#xF741;";
		$emoji{'number5'} = "&#xF742;";
		$emoji{'number6'} = "&#xF743;";
		$emoji{'number7'} = "&#xF744;";
		$emoji{'number8'} = "&#xF745;";
		$emoji{'number9'} = "&#xF746;";
		$emoji{'number0'} = "&#xF7C9;";

	}

	# Softbank
	elsif($device_id eq "SOFTBANK"){

		# バイナリデータ(Webコード)
		$emoji{'write'} = '$O!';
		$emoji{'exclamation'} = '$GA';
		$emoji{'new'} = '$F2';
		$emoji{'up'} = '$F3';
		$emoji{'mail'} = '$E#';
		$emoji{'mobile'} = '$E$';
		$emoji{'heart1'} = '';
		$emoji{'heart2'} = '';
		$emoji{'heart3'} = '';
		$emoji{'home'} = '$GV';
		$emoji{'smile'} = '';
		$emoji{'sad'} = '';
		$emoji{'search'} = '$E4';
		$emoji{'alert'} = '$Fr';
		$emoji{'night'} = '';
		$emoji{'sun'} = '';
		$emoji{'panic'} = '';
		$emoji{'hat'} = '$Q#';
		$emoji{'wrench'} = '$E6';
		$emoji{'number1'} = '$F<';
		$emoji{'number2'} = '$F=';
		$emoji{'number3'} = '$F>';
		$emoji{'number4'} = '$F?';
		$emoji{'number5'} = '$F@';
		$emoji{'number6'} = '$FA';
		$emoji{'number7'} = '$FB';
		$emoji{'number8'} = '$FC';
		$emoji{'number9'} = '$FD';
		$emoji{'number0'} = '$FE';

	}

	# その他
	else{
		$emoji{'home'} = "Top";
		$emoji{'exclamation'} = "！";
		$emoji{'alert'} = "!!";
		$emoji{'new'} = "New";
		$emoji{'up'} = "Up";
		$emoji{'wrench'} = "設定";
		$emoji{'number1'} = "①";
		$emoji{'number2'} = "②";
		$emoji{'number3'} = "③";
		$emoji{'number4'} = "④";
		$emoji{'number5'} = "⑤";
		$emoji{'number6'} = "⑥";
		$emoji{'number7'} = "⑦";
		$emoji{'number8'} = "⑧";
		$emoji{'number9'} = "⑨";
		$emoji{'number0'} = "(0)";
	}

return(%emoji);

}

#-----------------------------------------------------------
# 絵文字の別表現 ( 保存用 )
#-----------------------------------------------------------
sub Emoji_second{

# 宣言
my(%emoji);

		# Docomo -コード
		$emoji{'write'} = "&#xE6AE;";
		$emoji{'exclamation'} = "&#xE702;";
		$emoji{'number1'} = "&#xE6E2;";
		$emoji{'number2'} = "&#xE6E3;";
		$emoji{'number3'} = "&#xE6E4;";
		$emoji{'number4'} = "&#xE6E5;";
		$emoji{'number5'} = "&#xE6E6;";
		$emoji{'number6'} = "&#xE6E7;";
		$emoji{'number7'} = "&#xE6E8;";
		$emoji{'number8'} = "&#xE6E9;";
		$emoji{'number9'} = "&#xE6Ea;";
		$emoji{'number0'} = "&#xE6Eb;";

		# AU -タグ
		$emoji{'write'} = qq(<img localsrc="508" />);
		$emoji{'exclamation'} = qq(<img localsrc="2" />);
		$emoji{'number1'} = qq(<img localsrc="180" />);
		$emoji{'number2'} = qq(<img localsrc="181" />);
		$emoji{'number3'} = qq(<img localsrc="182" />);
		$emoji{'number4'} = qq(<img localsrc="183" />);
		$emoji{'number5'} = qq(<img localsrc="184" />);
		$emoji{'number6'} = qq(<img localsrc="185" />);
		$emoji{'number7'} = qq(<img localsrc="186" />);
		$emoji{'number8'} = qq(<img localsrc="187" />);
		$emoji{'number9'} = qq(<img localsrc="188" />);
		$emoji{'number0'} = qq(<img localsrc="325" />);

		# Softbank- Unicode
		$emoji{'write'} = "&#xE301;";
		$emoji{'exclamation'} = "&#xE021";
		$emoji{'number1'} = "&#xE21C;";
		$emoji{'number2'} = "&#xE21D;";
		$emoji{'number3'} = "&#xE21E;";
		$emoji{'number4'} = "&#xE21F;";
		$emoji{'number5'} = "&#xE220;";
		$emoji{'number6'} = "&#xE221;";
		$emoji{'number7'} = "&#xE222;";
		$emoji{'number8'} = "&#xE223;";
		$emoji{'number9'} = "&#xE224;";
		$emoji{'number0'} = "&#xE225;";

}


1;
