
use strict;
use Mebius::Auth;
use CGI;
package Mebius::BBS;

#-----------------------------------------------------------
# SNSプロフィール
#-----------------------------------------------------------
sub sns_profile_for_iframe{

my($query) = Mebius::query_state();
#my($my_account) = Mebius::my_account();

my($account) = Mebius::Auth::File("ReturnRef",$query->param('account'));

my $profile = $account->{'prof'};
($profile) = Mebius::auto_link({ TopWindow => 1 },$profile);
Mebius::Encoding::sjis_to_utf8($profile);

# 整形
$profile =~ s/(<br>){2,}/<br>/g;
$profile =~ s/<br>/ … /g;
$profile = qq(<div style="line-height:1.8;">$profile</div>);
	#if(Mebius::alocal_judge()){ $profile .= qq( $my_account->{'id'}); }

Mebius::SimpleHTML($profile);

}


1;
