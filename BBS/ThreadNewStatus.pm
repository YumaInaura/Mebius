
use strict;
package Mebius::BBS::ThreadNewStatus;
use Mebius::Export;

#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
"bbs_thread_new_status";
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
# レコードの追加 / 更新
#-----------------------------------------------------------
sub update{

my($use) = @_;
my $update = $use->{'update'} || die;
my($dbh) = Mebius::DBI->connect();
my($table_name) = main_table_name() || die("Can't decide main table name.");
my $time = time;

	# 汚染チェック
	if($update->{'bbs_kind'} =~ /\W/){ return(); }
	if($update->{'thread_number'} =~ /\D/){ return(); }
	if($update->{'res_number'} =~ /\D/){ return(); }

# 定義
$update->{'unique_target'} = "$update->{'bbs_kind'}-$update->{'thread_number'}" if($update->{'unique_target'} eq "");

my($column) = main_column();
my($update_adjusted) = Mebius::DBI->adjust_set($update,$column);

Mebius::DBI->update_or_insert_with_memory_table(undef,$table_name,$update_adjusted,"unique_target");




}

#-----------------------------------------------------------
# カラムの設定
#-----------------------------------------------------------
sub main_column{

# データ定義
my $column = {
unique_target => { PRIMARY => 1 , NOT_NULL => 1 } , 
bbs_kind => {  } , 
thread_number => { int => 1 } , 
res_number => { int => 1 } ,
regist_time => { int => 1 } ,
last_update_time => { int => 1 } ,
handle => { } ,
subject => { } ,
};

#access_count => { int => 1 } , 
#access_count_from_search_engine => { int => 1  } ,  

$column;

}

#-----------------------------------------------------------
# テーブル作成
#-----------------------------------------------------------
sub create_main_table{

my($table_name) = main_table_name() || die("Can't decide main table name.");

# データ定義
my($set) = main_column();

Mebius::DBI->create_table_with_memory(undef,$table_name,$set);

}

#-----------------------------------------------------------
# 新着レスをいくつか取得する ( SNSフィード用 )
#-----------------------------------------------------------
sub new_res_list{

my $use = shift if(ref $_[0] eq "HASH");
my($dbh) = Mebius::DBI->connect();
my($memory_table_name) = main_memory_table_name() || die("Can't decide main table name.");
my($self,$i,$border_time);

	if(Mebius::alocal_judge()){
		$border_time = 365*24*60*60;
	} else {
		$border_time = time - 24*60*60;
	}

# データを取得
my($data,$result) = Mebius::DBI->fetchrow("SELECT * from `$memory_table_name` WHERE regist_time > $border_time;");

my @data = @$data;

# 配列をソート
@data = sort { (split(/<>/,$b->{'regist_time'}))[0] <=> (split(/<>/,$a->{'regist_time'}))[0] } @data;

$self .= q(<ul class="no-pointer">);

	foreach( @data ){

			if($_->{'bbs_kind'} =~ /^sc/){ next; }
			if($_->{'bbs_kind'} =~ /^(ztd|cnr|ccu|csh|chats)$/){ next; }
			if(Mebius::Fillter::light_fillter($_->{'subject'})){ next; }
			if(Mebius::Fillter::subject_fillter(undef,$_->{'subject'})){ next; }

		$i++;

			if(exists $use->{'max_view'} && $i > $use->{'max_view'}){
				last;
			}

			my($thread_url) = Mebius::BBS::thread_url($_->{'thread_number'},$_->{'bbs_kind'});
			my($how_before) = Mebius::second_to_howlong({ TopUnit => 1 , HowBefore => 1 } , time - $_->{'regist_time'});
		$self .= q(<li><a href=").e.($thread_url).q(">).e($_->{'subject'}).q(</a> - ).e($how_before).q(</li>);
			
	}

$self .= q(</ul>);


$self;

}



1;
