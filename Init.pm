
use strict;
package Mebius::Init;

#-----------------------------------------------------------
# ‘S‚Ä‚ÌƒhƒƒCƒ“
#-----------------------------------------------------------
sub AllDomains{

# éŒ¾
my($use) = @_;

# ‘SƒhƒƒCƒ“
my(@all_domains) = Mebius::all_domains(); 


	# ³‹Kƒ`ƒFƒbƒN
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
# •¶šF
#-----------------------------------------------------------
sub Color{

# éŒ¾
my($use) = $_[0] if(ref $_[0] eq "HASH");
my($type) = $_[0] if(ref $_[0] eq "");
my $select_color = $_[1];
my($input_tags);


my @color = (
"•‹à=#000",
"‰_‚P=#333","‰_‚Q=#555",
"‰Ô‚P=#f06","‰Ô‚Q=#e17",
"‰Î‚P=#d04","‰Î‚Q=#f00","‰Î‚R=#e00",
"X‚P=#043","X‚Q=#050","X‚R=#070",
"ŠC‚P=#155","ŠC‚Q=#048","ŠC‚R=#074",
"ò‚P=#008","ò‚Q=#22b","ò‚R=#00f",
"—‹‚P=#616","—‹‚Q=#909","—‹‚R=#70d",
"–Ø‚P=#600","–Ø‚Q=#822","–Ø‚R=#b20",
"Œõ–¾=#d41",
"‰©‹à=#750"
);


#2012/9/19 (…) 
#"‰Ô‚R=#f08", ”p~
# —‹‚Q=#a0a" ¨ #909‚É

my @color_old1 = (
"•‹à=#000",
"‰_‚P=#333","‰_‚Q=#555",
"‰Ô‚P=#f06","‰Ô‚Q=#f18","‰Ô‚R=#f0a",
"‰Î‚P=#d04","‰Î‚Q=#f00","‰Î‚R=#f30","‰Î‚S=#f33",
"X‚P=#044","X‚Q=#060","X‚R=#080",
"ŠC‚P=#166","ŠC‚Q=#068","ŠC‚R=#084",
"ò‚P=#008","ò‚Q=#00f","ò‚R=#33c","ò‚S=#05e","ò‚T=#06a",
"—‹‚P=#616","—‹‚Q=#a0a","—‹‚R=#b08","—‹‚S=#90e","—‹‚T=#b2b",
"–Ø‚P=#700","–Ø‚Q=#933",
"Œõ‚P=#b41","Œõ‚Q=#d50",
"‰©‹à=#750"
);

my @color_old2 = (
"•‹à=#000",
"‰_‚P=#333","‰_‚Q=#555",
"‰Ô‚P=#f06","‰Ô‚Q=#f18","‰Ô‚R=#f0a",
"‰Î‚P=#d04","‰Î‚Q=#f00","‰Î‚R=#f30","‰Î‚S=#f44",
"X‚P=#044","X‚Q=#060","X‚R=#080",
"ŠC‚P=#166","ŠC‚Q=#068","ŠC‚R=#084",
"ò‚P=#008","ò‚Q=#00f","ò‚R=#33c","ò‚S=#05e","ò‚T=#06a",
"—‹‚P=#616","—‹‚Q=#a0a","—‹‚R=#b08","—‹‚S=#90e","—‹‚T=#b2b",
"–Ø‚P=#700","–Ø‚Q=#933",
"Œõ‚P=#b41","Œõ‚Q=#d60",
"‰©‹à=#750"
);

	# “ü—Í‚³‚ê‚½•¶šF‚Ì
	if($use->{'JustyCheck'}){
		my($justy_flag);
			foreach(@color){
				my($color_name2,$color_code2) = split(/=/,$_);
					if($color_code2 eq $select_color || $color_code2 eq "#$select_color"){ $justy_flag = 1; }
			}
		return $justy_flag;
	}


	# ƒZƒŒƒNƒgƒ{ƒbƒNƒX‚ğ’è‹`
	if($type =~ /Get-select-tags/){
			foreach(@color){
				my($selected);
				my($color_name2,$color_code2) = split(/=/,$_);
					if($select_color eq $color_code2){ $selected = $main::parts{'selected'}; }
				$input_tags .= qq(<option value="$color_code2" style="color:$color_code2;"$selected>$color_name2</option>);
			}

		return($input_tags);
	}

	# •’Ê‚ÉƒŠƒ^[ƒ“
	else{
		return(@color);
	}

}

#-----------------------------------------------------------
# ‰pš ( –¢g—p ? )
#-----------------------------------------------------------
sub Alfabet{

# éŒ¾
my($type) = @_;
my(@alfabet);

# ƒAƒ‹ƒtƒ@ƒxƒbƒg
push(@alfabet,"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
push(@alfabet,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z");

return(@alfabet);

}




1;