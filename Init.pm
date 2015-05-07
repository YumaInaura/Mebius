
use strict;
package Mebius::Init;

#-----------------------------------------------------------
# �S�Ẵh���C��
#-----------------------------------------------------------
sub AllDomains{

# �錾
my($use) = @_;

# �S�h���C��
my(@all_domains) = Mebius::all_domains(); 


	# ���K�`�F�b�N
	if($use->{'TypeJustyCheck'}){

			my($justy_domain_flag);
				foreach(@all_domains){
						if($use->{'URL'} =~ m!^https?://([a-zA-Z0-9\.]+\.)?$_/!){ $justy_domain_flag = 1; }
				}
			return($justy_domain_flag);
	}

return(\@all_domains);


}

#-----------------------------------------------------------
# �����F
#-----------------------------------------------------------
sub Color{

# �錾
my($use) = $_[0] if(ref $_[0] eq "HASH");
my($type) = $_[0] if(ref $_[0] eq "");
my $select_color = $_[1];
my($input_tags);


my @color = (
"����=#000",
"�_�P=#333","�_�Q=#555",
"�ԂP=#f06","�ԂQ=#e17",
"�΂P=#d04","�΂Q=#f00","�΂R=#e00",
"�X�P=#043","�X�Q=#050","�X�R=#070",
"�C�P=#155","�C�Q=#048","�C�R=#074",
"��P=#008","��Q=#22b","��R=#00f",
"���P=#616","���Q=#909","���R=#70d",
"�؂P=#600","�؂Q=#822","�؂R=#b20",
"����=#d41",
"����=#750"
);


#2012/9/19 (��) 
#"�ԂR=#f08", �p�~
# ���Q=#a0a" �� #909��

my @color_old1 = (
"����=#000",
"�_�P=#333","�_�Q=#555",
"�ԂP=#f06","�ԂQ=#f18","�ԂR=#f0a",
"�΂P=#d04","�΂Q=#f00","�΂R=#f30","�΂S=#f33",
"�X�P=#044","�X�Q=#060","�X�R=#080",
"�C�P=#166","�C�Q=#068","�C�R=#084",
"��P=#008","��Q=#00f","��R=#33c","��S=#05e","��T=#06a",
"���P=#616","���Q=#a0a","���R=#b08","���S=#90e","���T=#b2b",
"�؂P=#700","�؂Q=#933",
"���P=#b41","���Q=#d50",
"����=#750"
);

my @color_old2 = (
"����=#000",
"�_�P=#333","�_�Q=#555",
"�ԂP=#f06","�ԂQ=#f18","�ԂR=#f0a",
"�΂P=#d04","�΂Q=#f00","�΂R=#f30","�΂S=#f44",
"�X�P=#044","�X�Q=#060","�X�R=#080",
"�C�P=#166","�C�Q=#068","�C�R=#084",
"��P=#008","��Q=#00f","��R=#33c","��S=#05e","��T=#06a",
"���P=#616","���Q=#a0a","���R=#b08","���S=#90e","���T=#b2b",
"�؂P=#700","�؂Q=#933",
"���P=#b41","���Q=#d60",
"����=#750"
);

	# ���͂��ꂽ�����F��
	if($use->{'JustyCheck'}){
		my($justy_flag);
			foreach(@color){
				my($color_name2,$color_code2) = split(/=/,$_);
					if($color_code2 eq $select_color || $color_code2 eq "#$select_color"){ $justy_flag = 1; }
			}
		return $justy_flag;
	}


	# �Z���N�g�{�b�N�X���`
	if($type =~ /Get-select-tags/){
			foreach(@color){
				my($selected);
				my($color_name2,$color_code2) = split(/=/,$_);
					if($select_color eq $color_code2){ $selected = $main::parts{'selected'}; }
				$input_tags .= qq(<option value="$color_code2" style="color:$color_code2;"$selected>$color_name2</option>);
			}

		return($input_tags);
	}

	# ���ʂɃ��^�[��
	else{
		return(@color);
	}

}

#-----------------------------------------------------------
# �p�� ( ���g�p ? )
#-----------------------------------------------------------
sub Alfabet{

# �錾
my($type) = @_;
my(@alfabet);

# �A���t�@�x�b�g
push(@alfabet,"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
push(@alfabet,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z");

return(@alfabet);

}




1;