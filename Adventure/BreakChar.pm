
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# �����m�F
#-----------------------------------------------------------
sub BreakCharView{

my($type,$char_text,$missed) = @_;
my($init) = &Init();
my($view_line,$form,$i);

# �m�F�����񂪎w�肳��Ă��Ȃ��ꍇ
if($char_text eq ""){ return(); }

	# �����t�H�[�J�X
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

# �t�H�[��
$form .= qq(<form action="$init->{'script'}" method="post" name="break_char_form"$main::sikibetu>\n);
$form .= qq(<div>\n);
$form .= qq(�Q�[���𑱂���ɂ́A���̃{�b�N�X�Ɋm�F�����@<strong style="color:#080;">$blanked_char_text</strong>�@�����đ��M���Ă��������B\n);

	# ���M�p�����[�^���t�H�[���`���ɂ��đg�ݍ���
	foreach(split(/&/,$main::postbuf)){
		my($key2,$value2) = split(/=/);
			if($key2 ne "break_char"){
				$form .= qq(<input type="hidden" name="$key2" value="$value2"$main::xclose>);
			}
	}

$form .= qq(<input type="text" name="break_char" value=""$main::xclose>\n);
$form .= qq(<input type="submit" value="���M����"$main::xclose>\n);
	if($missed){ $form .= qq( ( $missed��� )\n); }
$form .= qq(<br$main::xclose><br$main::xclose><div style="color:#f00;">�����s����������ƁA�L�����f�[�^�����p�ł��Ȃ��Ȃ�܂��B</div>\n);

$form .= qq(</div>\n);
$form .= qq(</form>\n);


my $print  = qq($form);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



1;
