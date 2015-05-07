
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# 数字確認
#-----------------------------------------------------------
sub BreakCharView{

my($type,$char_text,$missed) = @_;
my($init) = &Init();
my($view_line,$form,$i);

# 確認文字列が指定されていない場合
if($char_text eq ""){ return(); }

	# 自動フォーカス
	if($missed <= 3){
		$main::body_javascript = qq( onload="document.break_char_form.break_char.focus()");
	}

my $blanked_char_text;
	foreach(split(//,$char_text)){
		my $rand = int rand(9999);
		$i++;
		$blanked_char_text .= qq( $_);
			if($main::device{'real_type'} ne "Mobile"){
				$blanked_char_text .= qq( <span style="display:none;">-&gt;$rand</span>);
			}
	}

# フォーム
$form .= qq(<form action="$init->{'script'}" method="post" name="break_char_form"$main::sikibetu>\n);
$form .= qq(<div>\n);
$form .= qq(ゲームを続けるには、次のボックスに確認数字　<strong style="color:#080;">$blanked_char_text</strong>　を入れて送信してください。\n);

	# 送信パラメータをフォーム形式にして組み込み
	foreach(split(/&/,$main::postbuf)){
		my($key2,$value2) = split(/=/);
			if($key2 ne "break_char"){
				$form .= qq(<input type="hidden" name="$key2" value="$value2"$main::xclose>);
			}
	}

$form .= qq(<input type="text" name="break_char" value=""$main::xclose>\n);
$form .= qq(<input type="submit" value="送信する"$main::xclose>\n);
	if($missed){ $form .= qq( ( $missed回目 )\n); }
$form .= qq(<br$main::xclose><br$main::xclose><div style="color:#f00;">※失敗が多すぎると、キャラデータが利用できなくなります。</div>\n);

$form .= qq(</div>\n);
$form .= qq(</form>\n);


my $print  = qq($form);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



1;
