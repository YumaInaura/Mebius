
use strict;

package Mebius::LikePHP;

use Exporter;

our @ISA = qw(Exporter);
# エクスポートする関数を記述
our @EXPORT = qw(in_array);


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub in_array($@){

my $target = shift;
my @array = @_;
my($flag);

	foreach my $value (@array){
			if($target eq $value && $value ne ''){
				$flag = 1;
			}
	}

$flag;

}

1;

