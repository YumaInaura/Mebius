
use strict;
use Mebius::HTML;
use Mebius::DBI;
package Mebius::Dos;
use base qw(Mebius::Base::DBI);

#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{

my($my_addr) = my_addr();

#$my_addr =~ s/^(\d+)\.(.+?)$/$1/g;
#"dos-$my_addr";

"dos";

}

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub init{

my(%self);

$self{'table_name'} = main_table_name() || die("can't init table name.");

\%self;

}

#-----------------------------------------------------------
# 自分のIPアドレス
#-----------------------------------------------------------
sub my_addr{

my $self;

	if(Mebius::alocal_judge()){ $self = "127.0.0.1"; } else { $self = $ENV{'REMOTE_ADDR'}; }

$self;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_table_column{

my $set = {
	addr => { PRIMARY => 1 } , 
	access_count_temporary => { int => 1 , default => 1 } , 
	access_start_time_temporary => { int => 1 } , 
	access_count_per_term => { int => 1 , default => 1 } , 
	access_count_per_term_start_time => { int => 1 } , 
	dos_count => { int => 1 , default => 0 } , 
	dos_count_start_time => { int => 1 } , 
	last_update_time => { int => 1 }
};

$set;

}

#-----------------------------------------------------------
# DBIテーブルを作成
#-----------------------------------------------------------
sub create_main_table{

my($init) = init();
my($main_table_name) = main_table_name() || die;

my $set = main_table_column();

Mebius::DBI->create_memory_table(undef,$main_table_name,$set);

}


#-----------------------------------------------------------
# ユーザーからのアクセスが発生したときの処理
#-----------------------------------------------------------
sub access{

my $package = __PACKAGE__;
my($dbh) = Mebius::DBI->connect();
my($init) = init();
my($main_table_name) = main_table_name();
my($my_addr) = my_addr();
my $time = time;
my($deny_access_flag);

# 何秒に何回アクセスがあれば、DOSアタックとして記録するか？
my $dos_count_border = 20;	# アクセス数
my $access_count_reset_second = 10;	# 秒

# DOS攻撃の設定
#my $dos_alert_border = 3;
my $dos_count_deny_access_num = 10;
#my $verify_max = 3;

# １日あたりの最大総アクセス数の設定
#my $all_access_htaccess_border = 3*60*60;
#my $all_access_alert_border = $all_access_htaccess_border * 0.90;

# 連続リクエストの設定
#my $redun_request_htaccess_border = 180;
#my $redun_request_alert_border = $redun_request_htaccess_border * 0.90;

	# ローカル設定
	if(Mebius::alocal_judge() && 0){
		#$dos_count_border = 1;
		$access_count_reset_second = 1;
		#$all_access_htaccess_border = 20;
		#$all_access_alert_border = 10;
		#$redun_request_htaccess_border = 6;
		#$redun_request_alert_border = 3;
	}

	if(Mebius::alocal_judge() && 0){
		#$all_access_alert_border = 3;
		#$all_access_htaccess_border = 6;
	}

	# 一定確率で古いレコードを全て削除
	if(rand((3*24*60*60)*10) < 1){
		Mebius::DBI->delete_old_records(undef,$main_table_name,1*30*24*60*60);
	}

	# テーブルを作成
	#if(Mebius::alocal_judge()){ #  || rand(1000) < 1
	#	create_main_table();
	#}

# データを取得
my $data = $package->fetchrow_main_table({ addr => $my_addr })->[0];

	# ●レコードが存在する場合は更新
	if($data){

		my(%set);

			# ▼（初回のDOS判定時刻から）一定時間が経過している場合、DOSカウンタをリセットする
			if($data->{'dos_count_start_time'} && time > $data->{'dos_count_start_time'} + 24*60*60){

				$set{'dos_count'} = 0;
				$set{'dos_count_start_time'} = "NULL";

			# ▼DOS判定が溢れた場合、アクセス制限判定をスル
			} elsif($data->{'dos_count'} >= $dos_count_deny_access_num){

				# カウンタをゼロに
				$set{'dos_count'} = 0;
				(%set) = reset_access_count_on_set(\%set);

					# アクセス制限を除外する条件を判定
					if(excluse_deny_access_judge()){
						0;
					# .htaccess で制限するためのフラグを立てる
					} else {
						$deny_access_flag = 1;
					}

			# ▼一定秒数にある程度のアクセスがない場合は、一時アクセスカウントをリセット
			} elsif(time >= $data->{'access_start_time_temporary'} + $access_count_reset_second){

				(%set) = reset_access_count_on_set(\%set);

			# ▼一時アクセスカウントを増やす
			} else {

				# 一時アクセスカウンタを増やす
				$set{'access_count_temporary'} = ["+",1];

					# DOS判定によってDOSカウンタを増やす
					if($data->{'access_count_temporary'} >= $dos_count_border){

							# はじめて DOSカウンタが上がった時刻を記録する
							if(!$data->{'dos_count'}){
								$set{'dos_count_start_time'} = time;
							}

							$set{'dos_count'} = ["+",1];
							(%set) = reset_access_count_on_set(\%set);
					}

			}

			# ブロックを超えた場合、総アクセス数をリセットする
			if(time >= $data->{'access_count_per_term_start_time'} + 24*60*60){
				$set{'access_count_per_term'} = 1;
				$set{'access_count_per_term_start_time'} = time;
			# 総アクセス数を増やす
			} else {
				$set{'access_count_per_term'} = ["+",1];
			}
			#} else {
			#	$set{'access_count_per_term'} = 1;
			#}


		# レコードの最終更新時刻を記録
		$set{'last_update_time'} = time;

		# 更新
		Mebius::DBI->update(undef,$main_table_name,\%set,"WHERE addr='$my_addr'");

	# ●レコードがない場合は作成
	} else {

		Mebius::DBI->insert(undef,$main_table_name,{ addr => $my_addr , access_start_time_temporary => $time , access_count_per_term_start_time => $time , last_update_time => $time });

	}


	#foreach( keys %{$data}){
	#	print "$_ : $data->{$_} \n";
	#}

	# .htaccess でアクセスを制限
	if($deny_access_flag){
		my($server_domain) = Mebius::server_domain();
		my($gethostbyaddr) = Mebius::get_host_state();
		Mebius::Dos::HtaccessFile("New-deny Renew",$my_addr,$gethostbyaddr);
		Mebius::Email::send_email("To-master Access-data-view",undef,"User deny with .htaccess. - $server_domain","host:$gethostbyaddr addr:$my_addr \n User-agent:$ENV{'HTTP_USER_AGENT'}");
	}


}

#-----------------------------------------------------------
# アクセス時間をリセットするための 共通SET文
#-----------------------------------------------------------
sub reset_access_count_on_set{

my($set_hash_for_sql) = @_;
my %self = %$set_hash_for_sql;
my $time = time;

$self{'access_count_temporary'} = 0;
$self{'access_start_time_temporary'} = $time;

%self;

}

#-----------------------------------------------------------
# アクセス制限を除外する
#-----------------------------------------------------------
sub excluse_deny_access_judge{

# ホスト名を取得
my($multi_host) = Mebius::Host::gethostbyaddr_cache_multi();
my($access) = Mebius::my_access();
my($self,$host_or_addr);

	# IPアドレス/ホスト名の振り分け
	if($multi_host->{'host'}){
		$host_or_addr = $multi_host->{'host'};
	} else {
		($host_or_addr) = my_addr();
	}

	# 判定対象外の環境の場合
	if(
		$multi_host->{'host_type'} eq "Bot" ||
		($ENV{'HTTP_USER_AGENT'} =~ /Googlebot/ && ($multi_host->{'host'} eq "" || $multi_host->{'addr_to_host_flag'})) ||
		$multi_host->{'myserver_addr_flag'} ||
		$access->{'mobile_uid'}
	){
		$self = 1;
	}

$self;

}

1;

