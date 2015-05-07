
package Mebius::Base::DBI;

use strict;

use Mebius::DBI;
use Mebius::Time;
use Mebius::Operate;

use Mebius::Export;

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub eq_or_update{

my $self = shift;
my $data = shift;
my $update = shift;
my $where = shift;
my $exclution = shift;
my $operate = new Mebius::Operate;
my($data);

	if(!$update){
		warn("Update data is empty, for eq_or_update ");
		return();
	}

	if($data){
		1;
	} elsif($update->{'target'}){
		$data = $self->fetchrow_main_table({ target => $update->{'target'} })->[0];
	} elsif($where) {
		$data = $self->fetchrow_main_table($where)->[0];
	}


	if(!$data){
		warn("Data is empty, for eq_or_update ");
		return();
	}

	my %check = (%{$data},%{$update});

		if($operate->hash_eq(\%check,$data,$exclution)){

		} else {
			$self->update_main_table($update);
			#our $hit++;
			#warn($hit);
		}


}

#-----------------------------------------------------------
# 継承用 - レコードの更新
#-----------------------------------------------------------
sub update_main_table_where{

my $self = shift;
my $update = shift;
my $where = shift;
my $use = shift || {};

my %new_use = (%{$use},( WHERE => $where ));

$self->update_main_table($update,\%new_use);

}

#-----------------------------------------------------------
# 継承用 - レコードの更新
#-----------------------------------------------------------
sub update_main_table{

my $self = shift;
my $update = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $dbi = new Mebius::DBI;
my($table_name) = $self->main_table_name() || die("Can't decide main table name.");
my($where,$debug_flag);

	#if(Mebius::alocal_judge() && $table_name eq "history"){
	#	$debug_flag = 1;
		#Mebius::Debug::print_hash($update);
	#}

my($columns) = $self->main_table_column();
my($adjusted_set) = $dbi->adjust_set($update,$columns,{ Debug => $debug_flag });

	#if(Mebius::alocal_judge() && $table_name eq "history"){ Mebius::Debug::print_hash($adjusted_set); }

my $primary_key = $self->get_primary_key_from_main_table();

	if($primary_key && $dbi->column_name_format_error($primary_key)){ die(""); }

	if(ref $use->{'WHERE'} eq "HASH"){
		$where = "WHERE " . $dbi->hash_to_where($use->{'WHERE'},$use);
	} elsif($primary_key) {
		$where = qq(WHERE $primary_key=').$dbi->escape($update->{$primary_key}).q(');
	} else {
		die("Please decide key for update on DBI.");
	}

	if($use->{'WITH_MEMORY_TABLE'}){
		$dbi->update_with_memory_table(undef,$table_name,$adjusted_set,$where,$use);
	} else {
		$dbi->update(undef,$table_name,$adjusted_set,$where,$use);
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_record_from_main_table{

my $self = shift;
my $where = shift;
my $use = shift;
my $dbi = new Mebius::DBI;
my $table_name = $self->main_table_name() || die;

$dbi->delete_record(undef,$table_name,$where,$use);

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_old_records_from_main_table{

my $self = shift;
my $border_time = shift;
my $dbi = new Mebius::DBI;

my $table_name = $self->main_table_name();
$dbi->delete_old_records(undef,$table_name,$border_time);

}

#-----------------------------------------------------------
# 継承用 - メモリテーブル名の取得
#-----------------------------------------------------------
sub main_memory_table_name{

my $self = shift;
my $dbi = new Mebius::DBI;

my($table_name) = $self->main_table_name() || die("Can't decide main table name.");
my($memory_table_name) = $dbi->table_name_to_memory_table_name($table_name);

$memory_table_name;

}


#-----------------------------------------------------------
# 継承用 - テーブル作成
#-----------------------------------------------------------
sub create_main_table_with_memory{

my $self = shift;
$self->create_main_table({ WITH_MEMORY_TABLE => 1 });

}



#-----------------------------------------------------------
# 継承用  - ファイルテーブルからのレコードの取得
#-----------------------------------------------------------
sub fetchrow_main_table{

my $self = shift;
my $dbi_query = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $dbi = new Mebius::DBI;

my $table_name = $self->main_table_name();
my $main_table_column = $self->main_table_column();
my $relay_use = Mebius::Operate->overwrite_hash($use,{ table_name => $table_name , table_column => $main_table_column , Bind => 1 });

$dbi->fetchrow($dbi_query,$relay_use);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub fetchrow_main_table_desc_point{

my $self = shift;
my $fetch = shift;
my $record_key = shift || die("Please tell me recorde key name for desc.");

my $data_group = $self->fetchrow_main_table_desc($fetch);

my $record = $data_group->[0]->{$record_key};

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub fetchrow_main_table_desc{

my $self = shift;
my $fetch = shift;
my $record_key_or_array = shift || die("Please tell me recorde key name for desc.");
my $use = shift || {};
my(%new_use);

	if(ref $record_key_or_array eq "ARRAY"){
		%new_use = (%{$use},( ORDER_BY => $record_key_or_array ));
	} else {
		%new_use = (%{$use},( ORDER_BY => ["$record_key_or_array DESC"] ));
	}

my $data_group = $self->fetchrow_main_table($fetch,\%new_use);
#my $point = $data->{$record_key};
#$point;

$data_group;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub fetchrow_main_table_asc_point{

my $self = shift;
my $fetch = shift;
my $record_key = shift || die("Please tell me recorde key name for asc.");

my $data_group = $self->fetchrow_main_table_asc($fetch);

my $record = $data_group->[0]->{$record_key};

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub fetchrow_main_table_asc{

my $self = shift;
my $fetch = shift;
my $record_key = shift || die("Please tell me recorde key name for asc.");
my $use = shift || {};
my %new_use = (%{$use},( ORDER_BY => ["$record_key ASC"] ));

my $data_group = $self->fetchrow_main_table($fetch,\%new_use);
#my $point = $data->{$record_key};

#$point;

$data_group;

}


#-----------------------------------------------------------
# 継承用  - ファイルテーブルからのレコードの取得
#-----------------------------------------------------------
sub fetchrow_on_hash_main_memory_table{

my $self = shift;
my $dbi_query = shift;
my $unique_key = shift;
my $use = shift;
my $operate = new Mebius::Operate;
my $dbi = new Mebius::DBI;

my $hand_use = $operate->overwrite_hash($use,{ MEMORY_TABLE => 1 });
$dbi->fetchrow_on_hash_main_table($dbi_query,$unique_key,$hand_use);

}



#-----------------------------------------------------------
# 継承用  - ファイルテーブルからのレコードの取得
#-----------------------------------------------------------
sub fetchrow_on_hash_main_table{

my $self = shift;
my $dbi_query = shift;
my $unique_key = shift;
my $use = shift;
my $dbi = new Mebius::DBI;
my($table_name);

	# テーブル名を定義
	if($use->{'MEMORY_TABLE'}){
		$table_name = $self->main_memory_table_name() || die("Can't decide main table name.");
	} else {
		$table_name = $self->main_table_name() || die("Can't decide main table name.");
	}

	if($dbi->table_name_format_error($table_name)){ die; }

	# ユニークキーが指定されていない場合は、プライマリーキーをキーに ( 主にこちらの処理をメインに使っているはず )
	if($unique_key eq ""){
		$unique_key = $self->get_primary_key_from_main_table();
	}


my %adjusted_use = (%{$use},( table_name => $table_name , Bind => 1 ) );

$dbi->fetchrow_on_hash($dbi_query,$unique_key,\%adjusted_use);

}

#-----------------------------------------------------------
# 継承用 - テーブル作成
#-----------------------------------------------------------
sub create_main_table{

my $self = shift;
my $use = shift || {};
my $dbi = new Mebius::DBI;

my($table_name) = $self->main_table_name() || die("Can't decide main table name.");

# データ定義
my($set) = $self->main_table_column();
my $main_table_init = $self->main_table_init();
my $table_use = Mebius::Operate->overwrite_hash($use,$main_table_init);

	if($use->{'WITH_MEMORY_TABLE'}){
		$dbi->create_table_with_memory(undef,$table_name,$set);
	} else {
		$dbi->create_table($table_use,undef,$table_name,$set);
	}

}

#-----------------------------------------------------------
# 継承用 - レコードの更新
#-----------------------------------------------------------
sub update_or_insert_main_table_with_memory{
my $self = shift;
my $update = shift;
$self->update_or_insert_main_table($update,{ WITH_MEMORY_TABLE => 1 });
}

#-----------------------------------------------------------
# 継承用 - レコードの挿入または更新 
#-----------------------------------------------------------
sub update_or_insert_main_table{

my $self = shift;
my $update = shift;
my $use = shift || {} ;
my $where = shift;
my $dbi = new Mebius::DBI;
my $times = new Mebius::Time;
my($table_name) = $self->main_table_name() || die("Can't decide main table name.");
my(%insert_only);

my %hand_use = %{$use};

my($columns) = $self->main_table_column();
my($adjusted_set) = $dbi->adjust_set($update,$columns);

my $micro_time = $times->micro_time();

my %insert_only = %{$dbi->adjust_set({ create_time => time , create_micro_time => $micro_time } , $columns)};

	if( my $add_hash = $use->{'insert_only'} ){
		%insert_only = (%insert_only,%{$add_hash});
	}

$hand_use{'insert_only'} = \%insert_only;
	if($where){
		$hand_use{'WHERE'} = $where;
	}

my $primary_key = $self->get_primary_key_from_main_table();

	if($dbi->column_name_format_error($primary_key)){ die(""); }

	if($use->{'WITH_MEMORY_TABLE'}){
		$dbi->update_or_insert_with_memory_table(undef,$table_name,$adjusted_set,$primary_key);
	} else {
		$dbi->update_or_insert(undef,$table_name,$adjusted_set,$primary_key,\%hand_use);
	}

$adjusted_set;

}

#-----------------------------------------------------------
# 継承用 - レコードの更新
#-----------------------------------------------------------
sub insert_main_table{

my $self = shift;
my $insert = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $dbi = new Mebius::DBI;
my $times = new Mebius::Time;
my($table_name) = $self->main_table_name() || die("Can't decide main table name.");
my($adjusted_set);

my($columns) = $self->main_table_column();

	if(ref $insert eq "HASH"){

		my $new_insert = $self->make_good_insert_records($insert);
		($adjusted_set) = $dbi->adjust_set($new_insert,$columns);
	} elsif(ref $insert eq "ARRAY"){
		my(@array);
			foreach my $insert_per (@{$insert}){

				my $new_insert = $self->automatic_insert_record($insert_per);

				my($adjusted_set_per) = $dbi->adjust_set($new_insert,$columns);
				push @array , $adjusted_set_per;
			}
		$adjusted_set = \@array;

	} else {
		$adjusted_set = $insert;
	}

	if($use->{'WITH_MEMORY_TABLE'}){
		$dbi->insert_with_memory_table(undef,$table_name,$adjusted_set,$use);
	} else {
		$dbi->insert(undef,$table_name,$adjusted_set,$use);
	}

$adjusted_set;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub make_good_insert_records{

my $self = shift;
my $insert = shift || die;

my $times = new Mebius::Time;
my $micro_time = $times->micro_time();

my %new_insert = %{$insert};

$new_insert{'create_time'} = time;
$new_insert{'create_micro_time'} = $micro_time;

my $column = $self->main_table_column();

	if($column->{'target'} && !$new_insert{'target'}){
		$new_insert{'target'} = $self->new_target_char();
	}
	
\%new_insert;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub refresh_main_table{
my $self = shift;
$self->refresh_all_column_from_main_table(@_);
}


#-----------------------------------------------------------
# テーブルのすべての設定を更新する
#-----------------------------------------------------------
sub refresh_all_column_from_main_table{

my $self = shift;
my $dbi = new Mebius::DBI;
my $column = $self->main_table_column();
my($dbh) = $dbi->connect();
my $main_table_name = $self->main_table_name();

	foreach my $column_name ( keys %{$column} ){

		my $setting = $column->{$column_name};

		my $column_setting_query =  $dbi->column_setting_to_query($column_name,$setting);

		# カラムの追加
		my $add_query = "ALTER TABLE `$main_table_name` ADD ($column_setting_query)";
		$dbh->do($add_query);

		# カラム設定の変更
		my $modify_query = "ALTER TABLE `$main_table_name` MODIFY $column_setting_query";
		$dbh->do($modify_query);

		# インデックスを貼る
		if($setting->{'INDEX'}){
			my $index_name = $dbi->column_name_to_index_name($column_name);
			my $index_query = "ALTER TABLE `$main_table_name` ADD INDEX $index_name($column_name)";
			$dbh->do($index_query);
		}

	}

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_relation_key_from_main_table{

my $self = shift;
my $dbi = new Mebius::DBI;

my $main_table_column = $self->main_table_column();

my $primary_key = $dbi->get_some_key_from_column_setting($main_table_column,"Relation");

$primary_key;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_primary_key_from_main_table{

my $self = shift;
my $dbi = new Mebius::DBI;

my $main_table_column = $self->main_table_column();

my $primary_key = $dbi->get_some_key_from_column_setting($main_table_column,"PRIMARY");

$primary_key;

}

#-----------------------------------------------------------
# 継承用
#-----------------------------------------------------------
sub main_table_init{ {}; }

1;
