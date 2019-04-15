
use strict;

use Mebius::BBS::Basic;
use Mebius::BBS::Data;
use Mebius::BBS::Crap;
use Mebius::BBS::Thread;
use Mebius::BBS::Path;
use Mebius::BBS::Judge;
use Mebius::BBS::Form;
use Mebius::BBS::Index;
use Mebius::BBS::Past;
use Mebius::BBS::Parts;
use Mebius::BBS::Account;
use Mebius::BBS::URL;
use Mebius::BBS::Admin;
use Mebius::BBS::Posted;
use Mebius::BBS::Wait;

use Mebius::BBS::Category;
use Mebius::BBS::ThreadStatus;
use Mebius::Page;
use Mebius::Report;

package Mebius::BBS;


	# コンパイル時に実行、掲示板の設定ファイルから得られる値を、親プロセスのメモリに常駐させる
	# MOD_PERL 判定を外さないように！ CGIモードで実行時の負荷量が非常に高くなります
	if($ENV{'MOD_PERL'}){
			Mebius::BBS::init_bbs_all({ get_init_parmanent => });
			Mebius::BBS::init_category_all({ get_init_parmanent => });
	}

1;
