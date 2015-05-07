
use strict;
package Mebius::BBS::AllRegistHistory;

#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
"bbs_all_regist_history";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub insert_new_record{

my($regist_data) = @_;
my($bbs_kind,$thread_number,$res_number,$handle) = @$regist_data;
my($dbh) = Mebius::DBI::connect();
my($table_name) = main_table_name() || die("Can't decide main table name.");
my $time = time;

	# 汚染チェック
	if($bbs_kind =~ /\W/){ return(); }
	if($thread_number =~ /\D/){ return(); }
	if($res_number =~ /\D/){ return(); }


	#if(Mebius::AlocalJudge()){ Mebius::Debug::Error(qq()); }

# エスケープ
Mebius::DBI::escape_sql($bbs_kind,$thread_number,$res_number,$handle);

$dbh->do("
	INSERT INTO `$table_name`
	(unique_target,bbs_kind,thread_number,res_number,regist_time,last_update_time)
	VALUES
	('${bbs_kind}-${thread_number}-${res_number}','$bbs_kind','$thread_number','$res_number',$time,$time)
;
");

#$bbs_kind-$thread_number-$res_number

}


#-----------------------------------------------------------
# テーブル作成
#-----------------------------------------------------------
sub create_main_table{

my($dbh) = Mebius::DBI::connect();
my($table_name) = main_table_name() || die("Can't decide main table name.");

$dbh->do("

CREATE TABLE IF NOT EXISTS `$table_name` 
	(
		`unique_target` char(100) NOT NULL PRIMARY KEY ,
		`bbs_kind` char(100) default NULL ,
		`thread_number` int default NULL ,
		`res_number` int default NULL ,
		`regist_time` int default NULL ,
		`last_update_time` int default NULL 
	)
ENGINE=MEMORY
;
");

#`account` char(100) default NULL ,
#`subject` char(100) default NULL ,
#`handle` char(100) default NULL ,

#	INDEX ${table_name}_bbs_kind(bbs_kind) , 
#	INDEX ${table_name}_thread_number(thread_number) , 
#	INDEX ${table_name}_res_number(res_number) 

}



1;
