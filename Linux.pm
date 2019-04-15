
use strict;
package Mebius;

#-----------------------------------------------------------
#-----------------------------------------------------------
sub allow_user_name_error{

my(@allow_user) = @_;
my($flag,$self);

chomp(my $user_name = `whoami`);

	foreach(@allow_user){
		if($user_name eq $_){
			$flag = 1;
		}
	}

	if(!$flag){
		$self = "Please action on admin user. '$user_name' is not.";
	}

$self;

}

1;
