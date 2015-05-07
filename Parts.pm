
use strict;
package Mebius::Parts;

#-----------------------------------------------------------
# �x�[�V�b�N�ȃp�[�c
#-----------------------------------------------------------
sub HTML{

# �錾
my($use,$device) = @_;
my(%parts);

# �f�o�C�X���擾
#my($use_device) = Mebius::my_use_device();
#my($real_device) = Mebius::my_real_device();

	# HTML5 �̏ꍇ
	if($use->{'TypeHTML4'}){
		$parts{'input_type_email'} = "text";
		$parts{'input_type_search'} = "text";
	}
	# ����ȊO�̏ꍇ
	else{
		$parts{'input_type_email'} = "email";
		$parts{'input_type_search'} = "search";
	}

	# Mobile-HTML�̏ꍇ
	if($use->{'TypeMobile'}){
		$parts{'selected'} = qq( selected="selected");
		$parts{'checked'} = qq( checked="checked");
		$parts{'disabled'} = qq( disabled="disabled");
	}
	# ����ȊO�̏ꍇ
	else{
		$parts{'selected'} = " selected";
		$parts{'checked'} = " checked";
		$parts{'disabled'} = " disabled";
	}

return(\%parts);

}


1;
