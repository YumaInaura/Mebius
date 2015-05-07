
use strict;

# �p�b�P�[�W�錾
package Mebius;

#-----------------------------------------------------------
# �G���R�[�h �ʖ�
#-----------------------------------------------------------
sub encode_text{
Encode(undef,@_);
}


#-----------------------------------------------------------
# �G���R�[�h 
#-----------------------------------------------------------
sub Encode{

# �錾
my($type,@text) = @_;
my(@text_encoded);

	# ���^�[��
	if(!@text){ return; }

	# �W�J
	foreach(@text){

		# ��`
		my $check = $_;

		# �X���b�V���������
		if($type =~ /Escape-slash/){
			$check =~ s/\//!/g;
			$check =~ s/\./~/g;
		}

		# �G���R�[�h
		$check =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
		$check =~ tr/ /+/;
			
		push(@text_encoded,$check);
	}

	# ���^�[��
	if(wantarray){
		return(@text_encoded);
	}
	else{
		return($text_encoded[0]);
	}

}

#-----------------------------------------------------------
# �G���R�[�h 
#-----------------------------------------------------------
sub decode_text{
 Decode(undef,@_);

}

#-----------------------------------------------------------
# �G���R�[�h 
#-----------------------------------------------------------
sub Decode{

# �錾
my($type,@text) = @_;
my(@text_decoded);

	# ���^�[��
	if(!@text){ return; }

	# �W�J
	foreach(@text){

		# ��`
		my $check = $_;

		# �f�R�[�h
		$check =~ tr/+/ /;
		$check =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("H2", $1)/eg;
		push(@text_decoded,$check);
	}


	# ���^�[��
	if(wantarray){
		return(@text_decoded);
	}
	else{
		return($text_decoded[0]);
	}

}

#-----------------------------------------------------------
# �G�X�P�[�v���� 
#-----------------------------------------------------------
sub escape{

# �錾
my($type,$val) = @_;

	# URL/���[���A�h���X�̋�؂蕶�����G�X�P�[�v����ꍇ
	if($type =~ /Space/){
		$val =~ s/(<br>|\s|�@|��|��)//g;
		return($val);
	}

# �^�C�v
#if($type !~ /NOTAND/ && $type !~ /Not-amp/){ $val =~ s/&/&amp;/g; }

# ��d�G�X�P�[�v��h�~
$val =~ s/&amp;/&/g;

# �G�X�P�[�v����
$val =~ s/&/&amp;/g; 
$val =~ s/"/&quot;/g;
$val =~ s/'/&#039;/g;
$val =~ s/</&lt;/g;
$val =~ s/>/&gt;/g;
$val =~ s/\r\n/<br>/g;
	if($type !~ /Not-br/){ $val =~ s/(\r|\n)/<br>/g; }
$val =~ s/\0//g;

# ���^�[��
return($val);

}


#-----------------------------------------------------------
# �f�X�P�[�v
#-----------------------------------------------------------
sub Descape{

# �錾
my($type,$value) = @_;

# �G�X�P�[�v����
$value =~ s/&quot;/"/g;
$value =~ s/&#0?39;/'/g;
$value =~ s/&apos;/'/g;
$value =~ s/&lt;/</g;
$value =~ s/&gt;/>/g;
	if($type !~ /Not-br/){ $value =~ s/<br>/\n/g; }

# �^�C�v
if($type !~ /Not-and/){ $value =~ s/&amp;/&/g; }

# �_�C�������ɖ߂�
if($type =~ /Deny-diamond/){ $value =~ s/<>//g; }

# ���^�[��
return($value);

}





1;
