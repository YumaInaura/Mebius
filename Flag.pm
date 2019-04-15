
use strict;
package Mebius;

#-----------------------------------------------------------
# BBSスクリプトであるフラグを立てる
#-----------------------------------------------------------
sub bbs_server_judge{

	if(Mebius::AlocalJudge() || $ENV{'SERVER_ADDR'} eq "112.78.200.216"){ 1; } else { 0; }

}

1;
