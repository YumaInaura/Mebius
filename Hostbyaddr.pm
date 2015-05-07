
use strict;
package Mebius::Host;
use base qw(Mebius::Base::DBI);

#-----------------------------------------------------------
# メインテーブル名
#-----------------------------------------------------------
sub main_table_name{
"addr";
}

#-----------------------------------------------------------
# メモリテーブル名
#-----------------------------------------------------------
sub main_memory_table_name{

my($table_name) = main_table_name() || die("Can't decide main table name.");
my($memory_table_name) = Mebius::DBI->table_name_to_memory_table_name($table_name);

$memory_table_name;

}

#-----------------------------------------------------------
# 自分のリモートIPアドレスから、キャッシュされたホスト名情報を返す。データベースにレコードが存在しない場合は登録する。
#-----------------------------------------------------------
sub gethostbyaddr_cache{

my($main_table_name) = main_table_name() || die;
my($main_memory_table_name) = main_table_name() || die;
my($self);
my $package = __PACKAGE__;

	# IPアドレスが変な場合
	if(addr_format_error($ENV{'REMOTE_ADDR'})){
		return();
	}

# DBIからデータを取得
my $data = $package->fetchrow_main_table({ addr => $ENV{'REMOTE_ADDR'} })->[0];

	# ●レコードが存在しない場合
	#if($result < 0){
	if(!$data){

		# 逆引き
		($self) = Mebius::get_host();

		my $insert = { addr => $ENV{'REMOTE_ADDR'} , host => $self , last_gethostbyaddr_time => time , last_update_time => time };

		# データベースに登録
		Mebius::DBI->insert_with_memory_table(undef,$main_table_name,$insert,"addr");

	# ●前回の逆引きから一定時間経過している or 前回逆引きできずに、さらに一定時間経過している場合は、レコードを更新
	} elsif(time > $data->{'last_gethostbyaddr_time'} + 7*24*60*60 || ($data->{'host'} eq "" && $data->{'last_gethostbyaddr_time'} + 1*24*60*60)){

		# 逆引き
		($self) = Mebius::get_host();

		my $insert = { addr => $ENV{'REMOTE_ADDR'} , host => $self , last_gethostbyaddr_time => time , last_update_time => time };

		Mebius::DBI->update_with_memory_table(undef,$main_table_name,$insert,"WHERE addr='$ENV{'REMOTE_ADDR'}'");

	# ●逆引きせずにキャッシュ（データベースの値）を使う場合
	} else {

		$self = $data->{'host'};
	}

$self;

}

#-----------------------------------------------------------
# マルチにデータを取得
#-----------------------------------------------------------
sub gethostbyaddr_cache_multi{
my($multi_host) = Mebius::GetHostMulti({ TypeByCache => 1 });
}


#-----------------------------------------------------------
# メインテーブルのカラム名
#-----------------------------------------------------------
sub main_table_column{

my $self = {
addr => { PRIMARY => 1 } , 
host => {} , 
last_gethostbyaddr_time => { int => 1 } , 
gethostbyname => {} , 
allow_key => {} , 
last_deny_allow_time => { int => 1 } , 
last_get_whois_time => { int => 1 } , 
last_gethostbyaddr_time => { int => 1 } , 
whois_allowed_time => { int => 1 } , 
last_get_whois_but_mente_time => { int => 1 } , 
last_update_time => { int => 1 }
};


}

#-----------------------------------------------------------
# テーブル作成
#-----------------------------------------------------------
sub create_main_table{


my($dbh) = Mebius::DBI->connect();
my($table_name) = main_table_name() || die("Can't decide main table name.");

my($columns) = main_table_column();

Mebius::DBI->create_table_with_memory(undef,$table_name,$columns);

}

#-----------------------------------------------------------
# 更新
#-----------------------------------------------------------
sub update_or_insert_main_table{

my($set) = @_;

my($table_name) = main_table_name() || die("Can't decide main table name.");
my($columns) = main_table_column();
my($adjusted_set) = Mebius::DBI->adjust_set($set,$columns);

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($adjusted_set->{'allow_key'} $adjusted_set->{'addr'})); }

Mebius::DBI->update_or_insert_with_memory_table(undef,$table_name,$adjusted_set,"addr");

}

#-----------------------------------------------------------
# データを選ぶ
#-----------------------------------------------------------
sub select_addr_data_from_main_table{

my($addr) = @_;
my($memory_table_name) = main_memory_table_name() || die("Can't decide main table name.");

	# IPアドレスが変な場合
	if(addr_format_error($addr)){
		return();
	}

my($data,$result) = Mebius::DBI->fetchrow_hashref_on_arrayref_head("SELECT * from `$memory_table_name` WHERE addr='$addr'");


$data;

}

#-----------------------------------------------------------
# ホスト情報から、ホストの信頼性のフラグを取得する
#-----------------------------------------------------------
sub get_flag{

# フラグ
my($data) = @_;
my(%flag);

# Who is 許可のキープ期間
my $whois_keep_allow_term = 30*24*60*60;

	# ▼ホスト名が逆引きできない場合も、投稿を許可するフラグ (A-1)
	# => 管理者が手動で許可している場合
	if($data->{'key'} eq "1"){ $flag{'special_allow'} = 1; }
	# => 前回 Who is で逆引きして、成功判定がされている場合
	elsif($data->{'whois_allowed_time'} && time < $data->{'whois_allowed_time'} + $whois_keep_allow_term){ $flag{'special_allow'} = 1; }

	# ▼今回のWho is 検索を許可するフラグ (A-2)
	# => 管理者によって禁止されていない、なおかつ現在は許可期限内ではないことが最低条件 ( 負荷軽減のため )
	if($data->{'key'} ne "0" && !$flag{'special_allow'}){
			# 前回がメンテナンス中などで先送りした場合、比較的短い時間で再検索する
			if($data->{'last_get_whois_but_mente_time'} && time >= $data->{'last_get_whois_but_mente_time'} + (6*24*24)){ $flag{'allow_get_whois'} = 1; }
			# 前回のWhois検索から一定時間が経過している場合
			elsif(!$data->{'last_get_whois_time'} || time > $data->{'last_get_whois_time'} + $whois_keep_allow_term){
				$flag{'allow_get_whois'} = 1;
			}
	}

	# IPアドレス照合
	if($data->{'gethostbyname'} && $data->{'host'} && $data->{'addr'} eq $data->{'gethostbyname'} && Mebius::HostFormat({ Host => $data->{'host'} }) ){ $flag{'trusted_host'} = 1; }

\%flag;

}


#-----------------------------------------------------------
# IPアドレスの形式チェック
#-----------------------------------------------------------
sub addr_format_error{

my($addr) = @_;

	my($error) = Mebius::AddrFormat({ TypeReturnErrorFlag => 1 , Addr => $addr } );

$error;

}


1;

