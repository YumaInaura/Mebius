
use strict;
use DBI;
package Mebius;

#-----------------------------------------------------------
# データベースに接続
#-----------------------------------------------------------
sub database_connect{

# Near State （呼び出し） 2.30
my $HereName1 = "database_connect";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

my $self = DBI->connect('DBI:mysql:mebius', 'root', '1234');

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$self); }

}

1;
