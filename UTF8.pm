
use strict;
use Encode;
package Mebius::UTF8;

#-----------------------------------------------------------
# Shift JIS ‚©‚ç UTF8‚Ö
#-----------------------------------------------------------
sub shift_jis_to_utf8{

my $use = shift;

	foreach(@_){
			if($use->{'Encode'} =~ /^s(hift)?(_)?jis$/i){
				Encode::from_to($_, 'shift_jis', 'utf8');
			}
	}

}



1;
