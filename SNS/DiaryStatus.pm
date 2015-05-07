
use strict;
package Mebius::SNS::DiaryStatus;

#-----------------------------------------------------------
# テーブル名を定義
#-----------------------------------------------------------
sub main_table_name{
"sns_diary_status";
}



#-----------------------------------------------------------
# レコードの追加 / 更新
#-----------------------------------------------------------
sub update{

my($use) = @_;
my $update = $use->{'update'} || die;
my($dbh) = Mebius::DBI::connect();
my($table_name) = main_table_name() || die("Can't decide main table name.");
my $time = time;

	# 汚染チェック
	if($update->{'account'} =~ /\W/){ return(); }
	if($update->{'diary_number'} =~ /\D/){ return(); }
	if($update->{'res_number'} =~ /\D/){ return(); }

# 定義
my $unique_target = "$update->{'account'}-$update->{'diary_number'}";
my $unique_target_quoted = $dbh->quote($unique_target);

# データを取得
my($data,$result) = Mebius::DBI::fetchrow_hashref_on_arrayref_head("SELECT unique_target from `$table_name` WHERE unique_target=$unique_target_quoted");

	# ●更新
	{	
		my $update = {
			unique_target => $unique_target ,
			bbs_kind => $update->{'bbs_kind'} ,
			thread_number => $update->{'thread_number'} ,
			res_number => $update->{'res_number'} ,
			regist_time => $update->{'regist_time'} ,
			last_update_time => $time , 
			handle => $update->{'handle'} , 
			subject => $update->{'subject'}
		};
 
			# ▼更新
			if($result >= 1){
				Mebius::DBI::update(undef,$table_name,$update,"WHERE unique_target=$unique_target_quoted");
			# ▼追加
			} else {
				Mebius::DBI::insert(undef,$table_name,$update);

			}
	}

}

#-----------------------------------------------------------
# テーブルを作成
#-----------------------------------------------------------
sub create_main_table{

my($dbh) = Mebius::DBI::connect();
my($table_name) = main_table_name() || die("Can't decide main table name.");

$dbh->do("
CREATE TABLE IF NOT EXISTS `$table_name`
	(
		`unique_key` char(100) NOT NULL PRIMARY KEY ,
		`account` char(100) NOT NULL ,
		`diary_number` int NOT NULL ,
		`last_res_number` int NOT NULL ,
		`last_modified_time` int NOT NULL ,
		`last_handle` char(100) NOT NULL ,
		`last_account` char(100) NOT NULL ,
		`last_update_time` int NOT NULL
	)
ENGINE=MEMORY
");

}



1;
