
use strict;

use Encode::Guess;
use Encode qw();

use Time::Local;
use File::Copy;
use Digest::MD5;
use CGI;
use Apache::DBI;

use Mebius::Basic;
use Mebius::BBS;
use Mebius::FsWikiBasic; # server1‚Ì‚Ý
use Mebius::Base::DBI;

Mebius::DBI->create_all_tables();

#Mebius::SNS::Account->all_account_handle();


1;
