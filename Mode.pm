
use strict;
package Mebius::Mode;

#-----------------------------------------------------------
# サブモードを判定
#-----------------------------------------------------------
sub submode{

my($param) = Mebius::query_single_param();
my(%self,$i);

	foreach(split(/-/,$param->{'mode'})){
		$i++;
		$self{$i} = $_;
	}

\%self;

}

1;
