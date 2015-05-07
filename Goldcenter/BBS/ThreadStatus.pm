	
use strict;
package Mebius::BBS::ThreadStatus;
use base qw(Mebius::Base::DBI);
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
my $self = shift;
"bbs_thread";
}

#-----------------------------------------------------------
# カラムの設定
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

# データ定義
my $column = {
unique_target => { PRIMARY => 1 , NOT_NULL => 1 } , 
bbs_kind => {  } , 
thread_number => { int => 1 } , 
res_number => { int => 1 , other_names => { res => }  } ,
regist_time => { int => 1 , other_names => { lastrestime => 1 } } ,
last_update_time => { int => 1 } ,
poster_handle => { other_names => { posthandle => } } , 
handle => { other_names => { lasthandle => } } ,
subject => { other_names => { sub => 1 } } ,
category => { } , 
};

#access_count => { int => 1 } , 
#access_count_from_search_engine => { int => 1  } ,  

$column;

}
#-----------------------------------------------------------
# レコードの追加 / 更新
#-----------------------------------------------------------
sub update_table{

my $self = shift;
my $update = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $time = time;

	# 汚染チェック
	if($update->{'bbs_kind'} =~ /\W/){ return(); }
	if($update->{'thread_number'} =~ /\D/){ return(); }
	if($update->{'res_number'} =~ /\D/){ return(); }

# 定義
my %update = %{$update};
$update{'unique_target'} = "$update{'bbs_kind'}-$update{'thread_number'}" if($update{'unique_target'} eq "");
$update{'category'} = Mebius::BBS::bbs_kind_to_category_kind($update{'bbs_kind'});

# テーブルを更新
$self->update_or_insert_main_table_with_memory(\%update);

}


#-----------------------------------------------------------
# 新着レスをいくつか取得する ( SNSフィード用 )
#-----------------------------------------------------------
sub new_res_list{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($dbh) = Mebius::DBI->connect();
my($memory_table_name) = $self->main_memory_table_name() || die("Can't decide main table name.");
my($self,$i,$border_time,$hit);

	if(Mebius::alocal_judge()){
		$border_time = 365*24*60*60;
	} else {
		$border_time = time - 24*60*60;
	}

# データを取得
#my($data,$result) = Mebius::DBI->fetchrow("SELECT * from `$memory_table_name` WHERE regist_time > $border_time;");
my($data,$result) = Mebius::DBI->fetchrow({ regist_time => [">",$border_time] },{ table_name => $memory_table_name });

my @data = @$data;

# 配列をソート
@data = sort { (split(/<>/,$b->{'regist_time'}))[0] <=> (split(/<>/,$a->{'regist_time'}))[0] } @data;

$self .= q(<ul class="no-pointer">);

	foreach( @data ){

			if($_->{'bbs_kind'} =~ /^sc/){ next; }
			if($_->{'bbs_kind'} =~ /^(ztd|cnr|ccu|csh|chats)$/){ next; }
			if(Mebius::Fillter::light_fillter($_->{'subject'})){ next; }
			if(Mebius::Fillter::subject_fillter(undef,$_->{'subject'})){ next; }

		$hit++;

			if($use->{'max_view'} && $hit > $use->{'max_view'}){ last; }

			my($thread_url) = Mebius::BBS::thread_url($_->{'thread_number'},$_->{'bbs_kind'});
			my($how_before) = Mebius::second_to_howlong({ TopUnit => 1 , HowBefore => 1 } , time - $_->{'regist_time'});
		$self .= q(<li><a href=").e.($thread_url).q(">).e($_->{'subject'}).q(</a> - ).e($how_before).q(</li>);
			
	}

$self .= q(</ul>);


$self;

}



1;
