
use strict;

use DBI;

use Mebius::Dos;
use Mebius::UserData;
use Mebius::Operate;

package Mebius::DBI;

my($set_database);

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new{
my $class = shift;
bless {} , $class;
}

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub default_engine{
my $self = shift;
"InnoDB";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub set_database{

my $self = shift;
my $database_name = shift || (warn("") && return());

$set_database = $database_name;

return $set_database;

}

#-----------------------------------------------------------
# データベースに接続
#-----------------------------------------------------------
sub connect{

my $self = shift;
my $database_name = shift || 'mebius';
my($dbh,%option);
my $password = "Zettaini-subarasii-7";

	if($set_database){
		$database_name = $set_database;
			if($database_name ne "mebius"){
				$option{'mysql_enable_utf8'} = 1;
			}
	}

	# メインデータベース
	if($ENV{'SCRIPT_ADDR'} eq "133.242.12.79" || $ENV{'SERVER_ADDR'} eq "133.242.12.79" || Mebius::alocal_judge()){
		$dbh = DBI->connect("DBI:mysql:${database_name}", 'admin', $password,\%option);
	} else {
		$dbh = DBI->connect("DBI:mysql:${database_name}:10.0.0.2", 'admin', \%option);
	}

$dbh->{'ShowErrorStatement'} = 1;
#$dbh->{'PrintWarn'} = 0;
#$dbh->{'PrintError'} = 0;

#$dbh->{RaiseError} = 1;

$dbh;

}

#-----------------------------------------------------------
# テーブル ( 中のレコード ) が存在するかどうかをチェックする
#-----------------------------------------------------------
sub table_records_exists{

my $self = shift;
my($database_name,$table_name) = @_;
my($dbh) = $self->connect($database_name);
my($exists,$not_exists);

	# テーブル名の汚染チェック
	if($self->table_name_format_error($table_name)){
		die;
	}	

my(undef,$result) = $self->fetchrow("SELECT * FROM `$table_name` LIMIT 0,1;");

$result;

}


#-----------------------------------------------------------
# SELECT からハッシュを返す
#-----------------------------------------------------------
sub fetchrow_on_hash{

my $self = shift;
my($dbi_query,$select_key,$use) = @_;
$use ||= {};
my(%hash);

my $priority_key = $use->{'priority_key'};

my($data_group) = $self->fetchrow($dbi_query,$use);


	foreach my $data (@$data_group){

			if(exists $data->{$select_key}){

#if($priority_key && $hash{$data->{$select_key}}){
#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($data->{$priority_key} / $hash{$data->{$select_key}}{$priority_key})); }
#}
					if($priority_key && $data->{$priority_key} < $hash{$data->{$select_key}}{$priority_key}){
						next;
					} else {
						$hash{$data->{$select_key}} = $data;
					}
			} else {
				die("'$select_key' is not exists in this table comunn.");
			}
	}

\%hash;

}

#-----------------------------------------------------------
# 配列を WHERE 文に
#-----------------------------------------------------------
sub array_to_where{

my $self = shift;
my $dbi_query = shift;
my $use = shift if(ref $_[0] eq "HASH");
my(@query,$formated_query,$dbi_query_do,@all_elements);

	# すべての要素を展開
	foreach my $value ( @{$dbi_query} ){

		my($query,$elements);

			if(ref $value eq "HASH"){
				my(%use_for_hash);
					if($use->{'OR'} && !$use->{'AND'}){
						%use_for_hash = (%{$use},( AND => 1 ));
					} else {
						%use_for_hash = (%{$use},( OR => 1 ));
					}
				($query,$elements) = $self->hash_to_where($value,\%use_for_hash);
			} elsif(ref $value eq "ARRAY"){
				($query,$elements) = $self->to_where($value->[0],$value->[1],$value->[2],$use);
			}

		push @query , $query;
		push @all_elements , @{$elements} if(ref $elements eq "ARRAY");
	}

	if($use->{'OR'} && !$use->{'AND'}){
		$formated_query = join " OR ", @query;
	} else {
		$formated_query = join " AND ", @query;
	}

$dbi_query_do .= " ($formated_query)" if($formated_query);

	if(wantarray && $use->{'Bind'}){
		return ($dbi_query_do,\@all_elements);
	} else {
		return $dbi_query_do;
	}

}
#-----------------------------------------------------------
# ハッシュを WHERE 文に
#-----------------------------------------------------------
sub hash_to_where{

my $self = shift;
my $dbi_query = shift;
my $use = shift if(ref $_[0] eq "HASH");
my(@query,$formated_query);
my($dbi_query_do,@all_elements);

	# すべての要素を展開
	foreach my $column_name ( keys %{$dbi_query} ){

		my($where_target,$mark);
		my $value = $dbi_query->{$column_name};

			if(ref $value eq "ARRAY"){
				$mark = $value->[0];
				$where_target = $value->[1];
			} else {
				$mark = "=";
				$where_target = $value;
			}

		my ( $query,$elements) = $self->to_where($column_name,$mark,$where_target,$use);
		push @query , $query;
		push @all_elements , @{$elements} if(ref $elements eq "ARRAY");

	}

	if($use->{'OR'} && !$use->{'AND'}){
		$formated_query = join " OR ", @query;
	} else {
		$formated_query = join " AND ", @query;
	}

$dbi_query_do .= " ($formated_query)" if($formated_query);

	if(wantarray && $use->{'Bind'}){
		return ($dbi_query_do,\@all_elements);
	} else {
		return $dbi_query_do;
	}

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hash_or_array_to_where{

my $self = shift;
my $hash_or_array = shift;
my($where);

	if(ref $hash_or_array eq "HASH"){
		$self->hash_to_where($hash_or_array,@_);
	} elsif(ref $hash_or_array eq "ARRAY"){
		$self->array_to_where($hash_or_array,@_);
	} else {
		0;
	}


}

#-----------------------------------------------------------
# WEHRE のためのクエリに
#-----------------------------------------------------------
sub to_where{

my $self = shift;
my $column_name = shift;
my $mark = shift;
my $value = shift;
my $use = shift;
my($target,@element,$place_holder_flag);

	if($self->column_name_format_error($column_name)){ return(); }

	if($use->{'Bind'}){
		$place_holder_flag = 1;
	}

$mark ||= "=";

	if($mark eq "IN" || $mark eq "NOT IN" || ref $value eq "ARRAY"){

		my @query;
		$mark ||= "IN";

			foreach my $value_in (@{$value}){

					if($place_holder_flag){
						push @element , $value_in;
						push @query , "?";
					} else {
						push @query , $self->escape_and_quote($value_in);
					}
			}

		$target = join "," , @query;
		$target = "( $target )";
	

	} elsif($value eq "" && $mark eq "="){

		$mark = "IS";
		$target = "NULL";

	} elsif($mark =~ /^(IS NOT NULL)$/){

	} elsif($mark =~ /^(IS)$/i){

		$target = $self->escape($value);

	# 許可するコマンド
	} elsif($mark =~ /^(>|<|>=|<=|=|<>|LIKE)$/i){

			if($place_holder_flag){
				$target = "?";
				push @element , $value;
			} else {
				$target = $self->escape_and_quote($value);
			}

	# その他は許可しない
	} else {
		warn("command '$mark' is strange. in $self");
		return();
	}


my $return_query = " $column_name $mark $target";

	if(wantarray && $use->{'Bind'}){
		return($return_query,\@element);
	} else {
		return $return_query;
	}

}

#-----------------------------------------------------------
# ORDER BY のクエリを生成
#-----------------------------------------------------------
sub order_by{

my $self = shift;
my $order_by = shift;
my(@order_by_query,$dbi_query_do);

	if($order_by eq ""){
		return();
	} elsif(ref $order_by ne "ARRAY"){
		warn("$order_by is not ARRAY ref.");
		return();
	}

	foreach my $value (@{$order_by}){

			# フォーマットが正しい場合
			if($value =~ /^([0-9a-zA-Z_,]+)(\s(DESC|ASC))?/){
				push @order_by_query , $value;
			} else {
				next;
			}

	}

	if(@order_by_query >= 1){
		$dbi_query_do = qq( ORDER BY $dbi_query_do) . join "," , @order_by_query;
	} else {
		0;
	}

$dbi_query_do;


}

#-----------------------------------------------------------
# 別名
#-----------------------------------------------------------
sub fetchrow{

my $self = shift;
my $dbi_query = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($dbh) = $self->connect();
my(@return,$dbi_query_do,@dbi_query,$place_holder_elements);

$dbi_query ||= {};

my($query,$place_holder_elements) = $self->hash_or_array_to_where($dbi_query,$use);

	# 与えられたのがハッシュの場合、エスケープしながらクエリを整形する
	if($query){
		$dbi_query_do = "WHERE " . $query;
	# 検索クエリを直接指定する場合
	} elsif(ref $dbi_query eq "") {
		$dbi_query_do = $dbi_query;
	}

	# テーブル名を指定する場合
	if($use->{'table_name'}){
			if($self->table_name_format_error($use->{'table_name'})){
				die();
			} else {
				$dbi_query_do = "SELECT * FROM `$use->{'table_name'}` $dbi_query_do";
			}
	}

	$dbi_query_do .= $self->order_by($use->{'ORDER_BY'}) if($use->{'ORDER_BY'});
	$dbi_query_do .= $use->{'add_query'};

	if($use->{'LIMIT'} =~ /^([0-9]+(,[0-9]+)?)$/){
		$dbi_query_do .= qq( LIMIT $1);
	}

	if($use->{'Debug'}){ Mebius::Debug::Error(qq($dbi_query_do)); }

	if( $use->{'table_name'} eq "status"){
		#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($dbi_query_do)); }
	}

my $sth = $dbh->prepare($dbi_query_do);
my $result = $sth->execute(@{$place_holder_elements});

	if($result >= 1){
			while ( my $hash_ref = $sth->fetchrow_hashref ){
				push @return,$hash_ref;
			}

	}

	if($use->{'SpecialDebug'}){ Mebius::Debug::Error(qq(result $result)); }

	if(wantarray){
		\@return,$result;
	}	else{
		\@return;
	}

}

#-----------------------------------------------------------
# SELECT から ハッシュリファレンスの配列を返す
#-----------------------------------------------------------
sub fetchrow_hashref_on_arrayref_head{

my $self = shift;

my($data,$result) = $self->fetchrow(@_);

$data->[0],$result;

}



#-----------------------------------------------------------
# SQL文を用意して実行する
#-----------------------------------------------------------
sub query{

my $self = shift;
my $dbh = shift;
my $sql_query = shift;
my $place_holder_array = shift;

my $sth = $dbh->prepare($sql_query);
my $result = $sth->execute();

	if($result eq "0E0"){ $result = -1; }


$sth,$result;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub escape_and_quote{

my $self = shift;
my $query = shift;
my($quoted_query);

my $escaped_query = $self->escape($query);

	if($escaped_query =~ /^[0-9]+$/){
		#$quoted_query = $escaped_query;
		$quoted_query = qq('$escaped_query');
	} else {
		$quoted_query = qq('$escaped_query');
	}

$quoted_query;

}

#-----------------------------------------------------------
# SQLクエリのエスケープ
#-----------------------------------------------------------
sub escape{

my $self = shift;
my($query) = @_;

$query =~ s/\\/\\\\/g;
$query =~ s/'/\\'/g;

$query;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_record{

my $self = shift;
my $database_name = shift;
my $table_name = shift;
my $where_hash_or_array = shift;
my $use = shift;
my $dbh = $self->connect();

	# テーブル名の汚染チェック
	if($self->table_name_format_error($table_name)){
		die;
	}

my $where = $self->hash_or_array_to_where($where_hash_or_array,$use);
my $query = "DELETE FROM `$table_name`";
	$query .= " WHERE $where" if($where);

	if($use->{'Debug'}){ Mebius::Debug::Error(qq($query)); }

my $count = $dbh->do($query);

$count;

}

#-----------------------------------------------------------
# 古いレコードを削除
#-----------------------------------------------------------
sub delete_old_records{

my $self = shift;
my($database_name,$table_name,$border_time) = @_;
my($dbh) = $self->($database_name);

	# テーブル名の汚染チェック
	if($self->table_name_format_error($table_name)){
		die;
	}

	# 汚染チェック
	if($border_time =~ /\D/){
		return();
	}

# エスケープ
$self->escape($table_name,$border_time);

$dbh->do("DELETE FROM `$table_name` WHERE last_update_time < $border_time;");

}



#-----------------------------------------------------------
# 一定確率でバックアップを取る
#-----------------------------------------------------------
sub backup_table_with_random{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($database_name,$table_name) = @_;
my($dbh) = $self->connect($database_name);

# 何回に一回程度、バックアップを取るかを確率で定義 ( 1 / $odds )
my $odds = $use->{'odds'} || 500;

	# テーブル名の汚染チェック
	if($self->table_name_format_error($table_name)){
		die;
	}

	# 一定確率でバックアップを取るため、ランダムにリターン
	if(rand($odds) > 1 && !Mebius::alocal_judge()){
		return();
	} else {
		# テーブルをコピー
		$self->memory_table_to_file_table($database_name,$table_name,"${table_name}_backup");
	}

}

#-----------------------------------------------------------
# メモリテーブルをバックアップテーブルに
#-----------------------------------------------------------
sub memory_table_to_file_table{

my $self = shift;
my($database_name,$table_name) = @_;
my($default_engine) = $self->default_engine() || die;
my($dbh) = $self->connect($database_name);

	# テーブル名の汚染チェック
	if($self->table_name_format_error($table_name)){
		die;
	}

my $backup_table_name = $table_name."_backup";

# ファイルテーブルを作成、カラムをコピー	
$dbh->do("CREATE TABLE IF NOT EXISTS $backup_table_name LIKE $table_name;");

# メモリテーブルをファイルテーブルに変更
$dbh->do("ALTER TABLE $backup_table_name ENGINE $default_engine;");

# 全レコードをコピー
$dbh->do("REPLACE INTO $backup_table_name SELECT * FROM $table_name;");

}


#-----------------------------------------------------------
# テーブルをコピーする ( テーブルが既に存在する場合に、全レコードをコピー )
#-----------------------------------------------------------
sub copy_table_insert_only{

my $self = shift;
my($database_name,$copy_from_table_name,$copy_to_table_name) = @_;
my($dbh) = $self->connect($database_name);

	# テーブル名の汚染チェック
	if($self->table_name_format_error($copy_from_table_name) || $self->table_name_format_error($copy_to_table_name)){
		die;
	}

$dbh->do("REPLACE INTO $copy_to_table_name SELECT * FROM $copy_from_table_name;");

}

#-----------------------------------------------------------
# ファイルテーブル、メモリテーブルを作成し、
#-----------------------------------------------------------
sub create_table_with_memory{

my $self = shift;
my($database_name,$table_name,$set) = @_;

	# テーブル名の汚染チェック
	if($self->table_name_format_error($table_name)){
		die;
	}

# ファイルテーブルを作成
$self->create_table($database_name,$table_name,$set);

# ファイルテーブルをメモリテーブルにコピー
$self->file_table_to_memory_table($database_name,$table_name,$set);

}

#-----------------------------------------------------------
# ファイルテーブルをメモリテーブルにコピーする
#-----------------------------------------------------------
sub file_table_to_memory_table{

my $self = shift;
my($database_name,$table_name,$set) = @_;
my($dbh) = $self->connect();

	# テーブル名の汚染チェック
	if($self->table_name_format_error($table_name)){
		die;
	}

# テーブル名を定義
my($memory_table_name) = $self->table_name_to_memory_table_name($table_name);

# メモリテーブルを削除
$self->drop_table($database_name,$memory_table_name);

$dbh->do("CREATE TABLE `$memory_table_name` LIKE `$table_name`;");
$dbh->do("ALTER TABLE `$memory_table_name` ENGINE=MEMORY;");
$dbh->do("INSERT INTO `$memory_table_name` SELECT * FROM `$table_name`;");


}


#-----------------------------------------------------------
# メモリーテーブルとバックアップテーブルを同時に作る
#-----------------------------------------------------------
sub create_memory_table_and_backup{

my $self = shift;
my($database_name,$table_name,$set) = @_;

	# テーブル名の汚染チェック
	if($self->table_name_format_error($table_name)){
		die;
	}

# バックアップ用のテーブル名を定義
my $backup_table_name = $table_name . "_backup";

# テーブルレコードの存在有無を確かめる
my($memory_table_exists) = $self->table_records_exists($database_name,$table_name);
my($backup_table_exists) =$self->table_records_exists($database_name,$backup_table_name);

	# ● メモリテーブルが消えてる場合
	if($backup_table_exists >= $memory_table_exists*2){

		# テーブルを削除
		$self->drop_table($database_name,$table_name);

		# メモリーテーブルを作成
		$self->create_memory_table($database_name,$table_name,$set);

		# バックアップテーブルからメモリテーブルに復元
		$self->copy_table_insert_only($database_name,$backup_table_name,$table_name);

	# ●メモリテーブルにレコードが存在しない場合、バックアップから復元
	} elsif(!$memory_table_exists && $backup_table_exists) {

		# メモリーテーブルを作成
		$self->create_memory_table($database_name,$table_name,$set);

		# バックアップテーブルからメモリテーブルに復元
		$self->copy_table_insert_only($database_name,$backup_table_name,$table_name);

	# ●それ以外の場合、バックアップ用とメモリテーブルの両方を作成する
	} else {

		# メモリーテーブルを作成
		$self->create_memory_table($database_name,$table_name,$set);

		# バックアップ用テーブルを作成
		$self->create_table($database_name,$backup_table_name,$set);

	}

}


#-----------------------------------------------------------
# メモリテーブルを作る
#-----------------------------------------------------------
sub create_memory_table{

# 宣言
my $self = shift;
my($database_name,$table_name,$create) = @_;

	# 名前チェック
	if($self->table_name_format_error($table_name)){
		die;
	}

# メモリテーブルを作成
$self->create_table({ MEMORY => 1 , Dynamic => 1 },$database_name,$table_name,$create);


}


#-----------------------------------------------------------
# テーブルの作成
#-----------------------------------------------------------
sub create_table{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($database_name,$table_name,$create) = @_;
my($dbh) = $self->connect($database_name);
my($ENGINE,@create,@alter,$primary_flag,$ROW_FORMAT);

	# エラーチェック
	if($self->table_name_format_error($table_name)){
		die;
	}

	# 使用するデータエンジン
	if($use->{'MEMORY'}){
		$ENGINE = " ENGINE=MEMORY"
	} else {
		my($default_engine) = $self->default_engine();
		$ENGINE = " ENGINE=$default_engine";
	}

	if($use->{'Dynamic'}){
		#$ROW_FORMAT = " ROW_FORMAT=DYNAMIC MEMORY FORMAT=DYNAMIC";
	}

	# 展開
	foreach my $column_name ( keys %$create ){

		push @create,$self->column_setting_to_query($column_name,$create->{$column_name}) ;

	}


# 命令文をカンマで区切る
my($create) = Mebius::join_array_with_mark(",",@create);
my $do = "CREATE TABLE IF NOT EXISTS `$table_name` ($create) $ENGINE $ROW_FORMAT;";

	if($table_name eq "question"){
		#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($do)); }
	}

# テーブル作成を実行
$dbh->do($do);

	# 変更
	if(Mebius::alocal_judge()){
		my($alter_add) = Mebius::join_array_with_mark(",",@alter);
		$dbh->do("ALTER TABLE `$table_name` $alter_add;");
	}


}


#-----------------------------------------------------------
# カラム設定から クエリに
#-----------------------------------------------------------
sub column_setting_to_query{

my $self = shift;
my $column_name = shift;
my $create = shift;
my($dbi_command,$primary_flag);

	if(ref $create ne "HASH"){
		die("$self");
	}

	# カラム名を定義
	if($self->column_name_format_error($column_name)){
		die("column name $column_name is strange.");
	} else {
		$dbi_command .= "`$column_name`";
	}

	# レコードのデータ型定義
	if($create->{'int'} || $create->{'INT'}){
		$dbi_command .= " int";
	} elsif($create->{'date'}){
		$dbi_command .= " date";
	} elsif($create->{'time'}){
		$dbi_command .= " time";
	} elsif($create->{'bigint'} || $create->{'BIGINT'}){
		$dbi_command .= " bigint";
	} elsif($create->{'text'}){
		$dbi_command .= " text";
	} elsif($create->{'data_type'} =~ /^[\w\(\)]+$/){
		$dbi_command .= $create->{'data_type'};
	} else {
			if($create->{'PRIMARY'} || $create->{'INDEX'}){
				$dbi_command .= " varchar(255)";
			} else {
				#$dbi_command .= " varchar(255)";
				$dbi_command .= " varchar(255)";
			}
	}

	# レコードの初期値を設定
	if(exists $create->{'default'}){
		$dbi_command .= " default $create->{'default'}";
	} elsif($create->{'NOT_NULL'} || $create->{'PRIMARY'}){
		$dbi_command .= " NOT NULL";
	} elsif($create->{'int'}){
		$dbi_command .= " default 0";
	}else {
		$dbi_command .= " default NULL";
	}

	# プライマリーキーにする場合
	if($create->{'PRIMARY'}){
			if($primary_flag){ die("Plese use one only PRIMARY KEY . not over two."); } # PRIMARY KEY はひとつだけ
		$dbi_command .= " PRIMARY KEY";
		$primary_flag = 1;
	# インデックスを付ける場合
	} elsif($create->{'INDEX'}){
		my $index_name = uc $column_name;
		$dbi_command .= " , INDEX $index_name ($column_name)";
	}

$dbi_command;

}


#-----------------------------------------------------------
# 汎用的な INSERT
#-----------------------------------------------------------
sub insert{

my $self = shift;
my($database_name,$table_name,$insert,$use) = @_;
my($sql,@set_values,$names,$question_marks,@insert,$column_names,%set_number,@names,$column_num,$i_hash);

	# 不正チェック
	if($self->table_name_format_error($table_name)){ die; }

# データベースに接続
my($dbh) = $self->connect($database_name);

	# 単一のレコードを insert する場合 ( 通常はこちら )
	if(ref $insert eq "HASH"){
		push @insert , $insert;
	# 復数のレコードを 一斉に insert する場合
	} elsif( ref $insert eq "ARRAY"){
		@insert = @{$insert};
	} else {
		die;
	}


	# ●事前準備
	{

			# 最初の SET 内容を展開して、カラム名等を決める
			foreach my $column_name ( keys %{$insert[0]} ){

					# カラム名の不正チェック
					if($self->column_name_format_error($column_name)){ die; }
					if($column_name =~ /^char$/){ next; }

				$column_num++;

				push(@names,$column_name);
				$set_number{$column_name} = $column_num - 1; # 配列とハッシュの順序を同期させるための処理 ( 配列なので [0] から始まる )

			}

		# カラム名を , で区切る
		$column_names = join ",",@names;

		# カラム数分のクエスチョンマーク ? を用意する
		($question_marks) = $self->question_mark_for_bind($insert[0]);

	}


	# ● insert する全てのレコードを展開
	foreach my $record (@insert){

		$i_hash++;

		my(@values,$column_hit);

			# SQL文を調整 ( 順序が大事なため、ハッシュからの配列化は必須 )
			foreach my $column_name ( keys %$record ){

					# カラム名の不正チェック
					if($self->column_name_format_error($column_name)){ die; }

				$column_hit++;

				# 配列に追加
				$values[$set_number{$column_name}] = $record->{$column_name};

			}

			# 必要なカラム数と相違がある場合はエラーに
			if($column_num != $column_hit){
				#die "must column num is $column_num . but here is $column_hit. ( round $i_hash )";
			}
	
		push @set_values , \@values;

	}


# SQL文を用意する ( バインド )
my $sql = qq(
	INSERT INTO `$table_name`
	($column_names)
	VALUES ($question_marks);
);

	if($use->{'Debug'}){
			if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($sql / @{$set_values[0]})); }
	}

	#if(Mebius::alocal_judge() && $table_name eq "question"){ Mebius::Debug::Error(qq($sql)); }

my $sth = $dbh->prepare($sql);

	# SQL を実行する
	foreach my $query (@set_values){
		#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq(@{$query})); }
		$sth->execute(@{$query});
	}

	if(Mebius::alocal_judge()){
		#Mebius::Debug::Error(qq($sql));
	}

}

#-----------------------------------------------------------
# ファイルテーブルとメモリテーブルに一斉にインサート
#-----------------------------------------------------------
sub insert_with_memory_table{

my $self = shift;
my($database_name,$table_name,$insert) = @_;
my($memory_table) = $self->table_name_to_memory_table_name($table_name);

$self->insert($database_name,$table_name,$insert);
$self->insert($database_name,$memory_table,$insert);

}


#-----------------------------------------------------------
# 汎用的な更新
#-----------------------------------------------------------
sub update{

my $self = shift;
my($database_name,$table_name,$set,$sql_query,$use) = @_;
my(@set_for_bind,$done);

	# 不正チェック
	if($self->table_name_format_error($table_name)){ die; }
	if(ref $set ne "HASH"){ die; }

# データベースに接続
my($dbh) = $self->connect($database_name);

# 配列をSET文に
my($set_sql,$set_value_for_bind) = $self->join_hash_to_set_scalar($set);

	# 更新を実行
	if($set_sql){

		# SQL 文を用意
		my $sql = "
			UPDATE `$table_name`
			SET $set_sql
			$sql_query
			;
			";

			if($use->{'Debug'}){
					if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($sql <br><br> @$set_value_for_bind )); }
			}

		my $sth = $dbh->prepare($sql);

		# バインドで実行
		$done = $sth->execute(@$set_value_for_bind);

	}

	if($done eq "0E0"){
		$done = -1;
	}

$done;

}

#-----------------------------------------------------------
# ファイルテーブルとメモリテーブルを一斉に更新
#-----------------------------------------------------------
sub update_with_memory_table{

my $self = shift;
my($database_name,$table_name,$set,$sql) = @_;
my($memory_table) = $self->table_name_to_memory_table_name($table_name);

$self->update($database_name,$table_name,$set,$sql);
$self->update($database_name,$memory_table,$set,$sql);

}


#-----------------------------------------------------------
# レコードがある場合は UPDATE 、ない場合は INSERt
#-----------------------------------------------------------
sub update_or_insert{

my $self = shift;
my($database_name,$table_name,$insert,$unique_key_name,$use) = @_;
my(%fetch);

	# 不正チェック
	if($self->table_name_format_error($table_name)){ die; }
	if($self->column_name_format_error($unique_key_name)){ die; }
	if(ref $insert ne "HASH"){ die; }

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($table_name / $use)); }

	if($use->{'WHERE'} && ref $use->{'WHERE'} eq "HASH"){

		%fetch = %{$use->{'WHERE'}};
	} else {
		%fetch = ( $unique_key_name => $insert->{$unique_key_name} );
	}

# データを取得
my $data = $self->fetchrow(\%fetch,{ table_name => $table_name , Bind => 1 })->[0];

	# ▼更新
	if($data){

		my $update_query = "WHERE " . $self->hash_to_where(\%fetch);

		$self->update(undef,$table_name,$insert,$update_query);

	# ▼追加
	} else {

		my %insert_adjusted;

			if($use->{'insert_only'}){
				%insert_adjusted = (%{$insert},%{$use->{'insert_only'}});
			} else {
				%insert_adjusted = %{$insert};
			}

	#if(Mebius::alocal_judge()){ Mebius::Debug::print_hash(\%insert_adjusted); }

		$self->insert(undef,$table_name,\%insert_adjusted);
	}

}

#-----------------------------------------------------------
# ファイルテーブルとメモリテーブルの両方を update_or_insert 
#-----------------------------------------------------------
sub update_or_insert_with_memory_table{

my $self = shift;
my($database_name,$table_name,$insert,$unique_key_name) = @_;
my($memory_table_name) = $self->table_name_to_memory_table_name($table_name);

$self->update_or_insert($database_name,$table_name,$insert,$unique_key_name);
$self->update_or_insert($database_name,$memory_table_name,$insert,$unique_key_name);

}


#-----------------------------------------------------------
# HASH を結合して JOIN文にする ( UPDATE用 )
#-----------------------------------------------------------
sub join_hash_to_set_scalar{

my $self = shift;
my($hash) = @_;
my($return,@set_column_name);
my($dbh) = $self->connect();
my(@set_value_for_bind);

	# UPDATE の SET用ハッシュを展開する
	foreach	my $column_name (keys %$hash ){

		my $value = $hash->{$column_name};

		# カラム名の汚染チェック
		if($self->column_name_format_error($column_name)){ next; }

			# ▼ハッシュによる制御 ( 文字連結 )
			#if(ref $hash->{$column_name} eq "HASH"){

					# 文字連結
			#		if($column_name eq "."){
			#				foreach my $column_name_concat ( keys %{$hash->{$column_name}} ){
								#push(@set_column_name,"$column_name_concat=concat($hash->{'.'}->{$column_name},?)");
								#push(@set_value_for_bind,$hash->{'.'}->{$column_name});
			#				}
			#		}

			# ▼式の場合
			#} elsif($value =~ /^
			#		([\+\-\*\/]) # 四則演算記号
			#		(\d+) # 数字 ( 整数)
			#		(\.\d+)? # 小数点
			#	$/x){

				# 例えば access=access+? のような文にする ( $1 は 四則演算記号 )
			#	push(@set_column_name,"$column_name=$column_name$1?");

				# 数値のみを VALUES として渡す ( $2$3 は数字部分 )
			#	push(@set_value_for_bind,"$2$3");

			# ●コマンドで指定する場合
			if(ref $value eq "ARRAY"){

				my $command = $value->[0];
				my $value_array = $value->[1];

					# ▼四則演算の場合
					if($command =~ /^([\+\-\*\/])$/){

						my $mark = $1;

						# 例えば access=access+? のような文にする ( $1 は 四則演算記号 )
						push(@set_column_name,"$column_name=(IFNULL($column_name,0))$mark?");
						push(@set_value_for_bind,$value_array);

					# ▼文字列連結
					} elsif($command eq "." || $command eq "concat"){

						push @set_column_name,"$column_name=concat(IFNULL($column_name,' '),?)";
						push @set_value_for_bind,$value_array;

					# ▼文字列連結
					} elsif($command eq "unshift"){

						push @set_column_name,"$column_name=concat(?,IFNULL($column_name,' '))";
						push @set_value_for_bind,$value_array;

					}

			# ●それ以外の場合、そのまま SQL 文を作る
			} else {
				push(@set_column_name,"$column_name=?");
				push(@set_value_for_bind,$hash->{$column_name});
			}

	}



# SET 文を , で区切る
($return) = Mebius::join_array_with_mark(",",@set_column_name);

$return,\@set_value_for_bind;

}

#-----------------------------------------------------------
# バインドで使う ?,?,? のような部分を作成
#-----------------------------------------------------------
sub question_mark_for_bind{

my $self = shift;
my($value) = @_;
my(@question_marks,$return);

	# ハッシュリファレンスの場合
	if(ref $value eq "HASH"){
			foreach(keys %$value ){
				push(@question_marks,"?");
			}
	# 配列のリファレンスの場合
	} elsif(ref $value eq "ARRAY"){
			foreach(@$value){
				push(@question_marks,"?");
			}
	# スカラ、配列直接渡しの場合
	} else {
			foreach(@_){
				push(@question_marks,"?");
			}
	}

my($return) = Mebius::join_array_with_mark(",",@question_marks);

}

#-----------------------------------------------------------
# テーブル名の不正チェック
#-----------------------------------------------------------
sub table_name_format_error{

my $self = shift;
my($table_name) = @_;
my($return);

	if($self->sql_reserved_name_check($table_name)){
		warn("SQL : Table name '$table_name' is reserved name. can't use.");
	}	elsif($table_name =~ /^[a-zA-Z0-9_\-\+]+$/){
		0;
	} else {
		die("SQL : Table name '$table_name' is invalid.");
		$return = 1;
	}

$return;

}

#-----------------------------------------------------------
# カラム名の不正チェック
#-----------------------------------------------------------
sub column_name_format_error{

my $self = shift;
my $column_name = shift;

	# 予約語をカラム名として使えないように ( 'KEY' だけ未処理 )
	if($self->sql_reserved_name_check($column_name)){
		warn("SQL : Column name '$column_name' is reserved name. can't use.");
	} elsif($column_name =~ /^[a-zA-Z0-9_\-+\(\)]+$|^[\.\+\-\*\/]$/){
		0;
	} else {
		die("SQL : Column name '$column_name' is invalid. $self");
		return 1;
	}


}

#-----------------------------------------------------------
# 予約語のチェック
#-----------------------------------------------------------
sub sql_reserved_name_check{

my $self = shift;
my($name) = @_;
my $error_flag;

	if($name =~ /^(ACCESSIBLE|ADD|ALL|ALTER|ANALYZE|AND|AS|ASC|ASENSITIVE|BEFORE|BETWEEN|BIGINT|BINARY|BLOB|BOTH|BY|CALL|CASCADE|CASE|CHANGE|CHAR|CHARACTER|CHECK|COLLATE|COLUMN|CONDITION|CONSTRAINT|CONTINUE|CONVERT|CREATE|CROSS|CURRENT_DATE|CURRENT_TIME|CURRENT_TIMESTAMP|CURRENT_USER|CURSOR|DATABASE|DATABASES|DAY_HOUR|DAY_MICROSECOND|DAY_MINUTE|DAY_SECOND|DEC|DECIMAL|DECLARE|DEFAULT|DELAYED|DELETE|DESC|DESCRIBE|DETERMINISTIC|DISTINCT|DISTINCTROW|DIV|DOUBLE|DROP|DUAL|EACH|ELSE|ELSEIF|ENCLOSED|ESCAPED|EXISTS|EXIT|EXPLAIN|FALSE|FETCH|FLOAT|FLOAT4|FLOAT8|FOR|FORCE|FOREIGN|FROM|FULLTEXT|GRANT|GROUP|HAVING|HIGH_PRIORITY|HOUR_MICROSECOND|HOUR_MINUTE|HOUR_SECOND|IF|IGNORE|IN|INDEX|INFILE|INNER|INOUT|INSENSITIVE|INSERT|INT|INT1|INT2|INT3|INT4|INT8|INTEGER|INTERVAL|INTO|IS|ITERATE|JOIN|KEY|KEYS|KILL|LEADING|LEAVE|LEFT|LIKE|LIMIT|LINEAR|LINES|LOAD|LOCALTIME|LOCALTIMESTAMP|LOCK|LONG|LONGBLOB|LONGTEXT|LOOP|LOW_PRIORITY|MASTER_SSL_VERIFY_SERVER_CERT|MATCH|MEDIUMBLOB|MEDIUMINT|MEDIUMTEXT|MIDDLEINT|MINUTE_MICROSECOND|MINUTE_SECOND|MOD|MODIFIES|NATURAL|NOT|NO_WRITE_TO_BINLOG|NULL|NUMERIC|ON|OPTIMIZE|OPTION|OPTIONALLY|OR|ORDER|OUT|OUTER|OUTFILE|PRECISION|PRIMARY|PROCEDURE|PURGE|RANGE|READ|READS|READ_ONLY|READ_WRITE|REAL|REFERENCES|REGEXP|RELEASE|RENAME|REPEAT|REPLACE|REQUIRE|RESTRICT|RETURN|REVOKE|RIGHT|RLIKE|SCHEMA|SCHEMAS|SECOND_MICROSECOND|SELECT|SENSITIVE|SEPARATOR|SET|SHOW|SMALLINT|SPATIAL|SPECIFIC|SQL|SQLEXCEPTION|SQLSTATE|SQLWARNING|SQL_BIG_RESULT|SQL_CALC_FOUND_ROWS|SQL_SMALL_RESULT|SSL|STARTING|STRAIGHT_JOIN|TABLE|TERMINATED|THEN|TINYBLOB|TINYINT|TINYTEXT|TO|TRAILING|TRIGGER|TRUE|UNDO|UNION|UNIQUE|UNLOCK|UNSIGNED|UPDATE|USAGE|USE|USING|UTC_DATE|UTC_TIME|UTC_TIMESTAMP|VALUES|VARBINARY|VARCHAR|VARCHARACTER|VARYING|WHEN|WHERE|WHILE|WITH|WRITE|XOR|YEAR_MONTH|ZEROFILL)$/i){
		$error_flag = 1;

	}

$error_flag;

}

#-----------------------------------------------------------
# カラムの別名をハッシュとしてセットする
#-----------------------------------------------------------
sub column_other_names_adjust_set{

my $self = shift;
my($set,$column,$use) = @_;
my %adjusted_set = %{$set};

	# 必須値のチェック
	if(ref $set ne "HASH"){ die; }
	if(ref $column ne "HASH"){ die; }

	# 全てのカラム設定を展開
	foreach my $column_name ( keys %{$column} ){

			# メインのカラム名で SET 内容が定義されている場合は何もしない
			if(exists $set->{$column_name}){
				next;
			}

			# カラムの別名が登録されている場合
			if(exists $column->{$column_name}->{'other_names'}){

					# カラムの別名を展開する
					foreach my $other_name ( keys %{$column->{$column_name}->{'other_names'}} ){

							# メインのカラム名と、別名が一緒の場合は、スクリプトの記述ミスなのでエラーを出す
							if(exists $column->{$other_name}){
								die("Main column name '$column_name' and other name '$other_name' is redun.");
							# SET のハッシュの中に、別名のキーがあれば、メインの SET の内容を上書きする
							} elsif(exists $set->{$other_name}){
								$adjusted_set{$column_name} = $set->{$other_name};
							}

					}

			}

	}

\%adjusted_set;

}

#-----------------------------------------------------------
# カラム情報とセット情報を比較して、不適切なものは調整する ( SQL側ではなく、Perl側で警告・エラーを出す )
#-----------------------------------------------------------
sub adjust_set{

my $self = shift;
my($set,$column,$use) = @_;
my %return;

# カラムの別名を指定しても対応できるように
my($set) = $self->column_other_names_adjust_set($set,$column,$use);

$set->{'last_update_time'} ||= time;

	# 全てのSET内容を展開する
	foreach my $column_name ( keys %{$set} ){

		my $value = my $value_for_judge = $set->{$column_name};

			# 式の場合
			if(ref $value eq "ARRAY"){
				$value_for_judge = $value->[1];
			}

			# カラム設定に存在する場合
			# 必ず 全体を exists 判定すること。 if($column->{$column_name}->{'int'}){ } とか判定した時点で exitst = true になってしまう。
			if(exists $column->{$column_name}) {

					# カラムのデータ型が数字なのに、中身が数字じゃない場合
					if($column->{$column_name}->{'int'} && $value_for_judge !~ /^([\+\-\*\/])?(\d+)(\.\d+)?$/){
						#warn "column [$column_name]  data type is int. but $return{$column_name} is not.";
						$return{$column_name} = 0;
					} else {
						$return{$column_name} = $value;
					}

			} elsif($column_name =~ /^(last_update_time|create_time)$/) {
				0;
			} else {
				#warn("'$column_name' isn't named column. so escaped . ok master?");
				0;
			}

	}



\%return;

}

#-----------------------------------------------------------
# テーブルを削除
#-----------------------------------------------------------
sub drop_table{

my $self = shift;
my($database_name,$table_name) = @_;
my($dbh) = $self->connect($database_name);

	if($self->table_name_format_error($table_name)){ return(); }

$dbh->do("DROP TABLE `$table_name`");

}

#-----------------------------------------------------------
# ファイルテーブル名に対しての、メモリテーブル名の定義
#-----------------------------------------------------------
sub table_name_to_memory_table_name{

my $self = shift;
my($table_name) = @_;

	if($table_name =~ /_memory$/){
		die "'$table_name' is memory table name already.";
	}

"${table_name}_memory";

}


#-----------------------------------------------------------
# 全てのカラムを最新の状態に書き換える
#-----------------------------------------------------------
sub alter_table_all_columns{

my $self = shift;
my $database_name = shift;
my $table_name = shift;
my $columns = shift;

}




#-----------------------------------------------------------
# カラム設定の中から、プライマリーキーが設定されているカラム名ひとつを抽出する
#-----------------------------------------------------------
sub get_some_key_from_column_setting{

my $self = shift;
my $columns = shift;
my $select_hash_name = shift;
my($primary_key);

	if(ref $columns ne "HASH"){
		die("$columns is not HASH ref.");
	}

	foreach my $column ( keys %{$columns} ){
			if($columns->{$column}->{$select_hash_name}){
					if($primary_key){
						die("There is two PRIMARY KEY. '$primary_key' and  '$column'");
					} else {
						$primary_key = $column;
					}
			} else {
				0;
			}

	}

$primary_key;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub column_name_to_index_name{

my $self = shift;
my $column_name = shift;

my $index_name = uc $column_name;

$index_name;

}


use Mebius::Saying::Basic;
use Mebius::Tags::Basic;
use Mebius::Status;
use Mebius::Vine::Basic;
use Mebius::Wiki::Basic;
use Mebius::Video::Basic;
use Mebius::Mixi::Basic;
use Mebius::Proxy;

#-----------------------------------------------------------
# 全てのテーブルを作成する
#-----------------------------------------------------------
sub create_all_tables{

my $self = shift;

#Mebius::ActionLog::create_main_table();
Mebius::Dos::create_main_table();
Mebius::Report->create_main_table();
Mebius::BBS::ThreadStatus->create_main_table_with_memory();
Mebius::BBS::Status->create_main_table();
Mebius::BBS::Wait->create_main_table();
Mebius::BBS->create_all_tables();

#Mebius::UserData::create_main_table();
Mebius::Host::create_main_table();

Mebius::History->create_main_table();

Mebius::Status->create_main_table();

#Mebius::SNS::DiaryStatus::create_main_table();
Mebius::SNS::Diary::create_main_table();
Mebius::SNS::Account->create_main_table();
Mebius::SNS::Feed->create_main_table({ MEMORY => 1 });

Mebius::Question::Post->create_main_table();
Mebius::Question::Response->create_main_table();
Mebius::Question::Ranking->create_main_table();

Mebius::CerEmail->create_main_table();

Mebius::Saying::Content->create_main_table();
Mebius::Saying::Saying->create_main_table();
Mebius::Saying::Review->create_main_table();
Mebius::Saying::Comment->create_main_table();

Mebius::Vine::Post->create_main_table();
Mebius::Vine::Comment->create_main_table();

Mebius::AllComments->create_main_table();

Mebius::Tags::Tag->create_main_table();
Mebius::Tags::Comment->create_main_table();
Mebius::Tags::Follow->create_main_table();

Mebius::Wiki::Site->create_main_table();
Mebius::Wiki::Post->create_main_table();
Mebius::Wiki::Category->create_main_table();

Mebius::Video->create_all_tables();

Mebius::BBS->create_all_tables();
Mebius::Mixi->create_all_tables();

Mebius::Proxy->create_all_tables();


}


#-----------------------------------------------------------
# 全てのカラム設定を最新のものに更新する
#-----------------------------------------------------------
sub refresh_all_tables{

Mebius::BBS::Status->refresh_main_table();
Mebius::BBS::Wait->refresh_main_table();

Mebius::Question::Response->refresh_main_table();
Mebius::Question::Post->refresh_main_table();
Mebius::Question::Ranking->refresh_main_table();

Mebius::Report->refresh_main_table();
Mebius::SNS::Feed->refresh_main_table();
Mebius::SNS::Account->refresh_main_table();

Mebius::History->refresh_main_table();

Mebius::Status->refresh_main_table();

Mebius::Saying::Content->refresh_main_table();
Mebius::Saying::Saying->refresh_main_table();
Mebius::Saying::Review->refresh_main_table();
Mebius::Saying::Comment->refresh_main_table();

Mebius::Vine::Post->refresh_main_table();
Mebius::Vine::Comment->refresh_main_table();

Mebius::AllComments->refresh_main_table();

Mebius::Tags::Tag->refresh_main_table();
Mebius::Tags::Comment->refresh_main_table();
Mebius::Tags::Follow->refresh_main_table();

Mebius::Wiki::Site->refresh_main_table();
Mebius::Wiki::Post->refresh_main_table();
Mebius::Wiki::Category->refresh_main_table();


Mebius::Video->refresh_all_tables();
Mebius::Mixi->refresh_all_tables();

Mebius::Proxy->refresh_all_tables();


}


1;
