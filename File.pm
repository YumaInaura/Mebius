
use utf8;
use strict;
package Mebius;
use Mebius::Directory;
use Mebius::Export;

#-----------------------------------------------------------
# 配列を
#-----------------------------------------------------------
sub add_line_for_file{

my $use = shift if(ref $_[0] eq "HASH");
my($datas,$split_mark) = @_;
my($self);

	# 型
	if(defined $datas && ref $datas ne "ARRAY"){
		die("Perl Die! $datas ref is not ARRAY.");
	}

	# 区切りマークを定義
	if($split_mark eq ""){
		$split_mark = "<>";
	}

	# 配列を展開してデータ型に整形する
	{
			foreach my $data (@$datas){
					if($use->{'Format'}){
						($data) = Mebius::format_data_for_file_use_array($data);
					}
				$self .= qq($data$split_mark);
			}
		$self .= qq(\n);
	}

$self;

}

#-----------------------------------------------------------
# 配列を追加してデータ用にフォーマット
#-----------------------------------------------------------
sub add_line_for_file_and_format{

my($self) =	add_line_for_file({ Format => 1 },@_);


}

#-----------------------------------------------------------
# ファイル書き込み
#-----------------------------------------------------------
sub Fileout{

# 宣言
my($type,$file,@line) = @_;
my($filehandle1,$filehandle2,$filehandle3,$file_f_flag);

	# パーミッション
	#if($type =~ /Permission-(0700)/){ $logpms = 0700; }

	# リターン
	if($type !~ /NEWMAKE/ && $type !~ /New-file/ && $type !~ /(Can-Zero|Allow-empty)/){
			if(@line <= 0){
				Mebius::AccessLog(undef,"Fileout-empty-error","$file");
				main::error("write body is empty.");
			}
	}

	# 追記してリターンする場合
	if($type =~ /Plusfile/){
		$file_f_flag = open($filehandle3,">>",$file);
		print $filehandle3 @line;
		close($filehandle3);
		Mebius::Chmod(undef,$file);
		return($file_f_flag);
	}

	# 新規ファイルのみを作ってリターンする場合
	if($type =~ /(NEWMAKE|New-file)/){ return(1); }

	# 書き込み内容がある場合、ファイルを更新
	if(@line >= 1 || $type =~ /(Can-Zero|Allow-empty)/){

		# ファイルを開く
		$file_f_flag = open($filehandle1,"+<",$file);

			# ●ファイルが既に存在する場合
			if($file_f_flag){

					# ファイルの二重書き込みを禁止する場合
					if($type =~ /Deny-f-file-return/){
						close($filehandle1);
						return();
					}
					# 既に存在するファイルに書き込み
					else{
						flock($filehandle1,2);
						seek($filehandle1,0,0);
						truncate($filehandle1,tell($filehandle1));
						print $filehandle1 @line;
						close($filehandle1);
							if(rand(25) < 1){ Mebius::Chmod(undef,$file); }
					}

			}

			# ●ファイルを新規作成する場合
			else{

				# ファイルハンドルを閉じる ( 必要? )
				close($filehandle1);

				# ファイル書き込み
				$file_f_flag = open($filehandle2,">",$file);
				print $filehandle2 @line;
				close($filehandle2);

				# 必ず chmod
				Mebius::Chmod(undef,$file);

			}


	}

# リターン
return($file_f_flag);

}

#-----------------------------------------------------------
# パーミッション変更
#-----------------------------------------------------------
sub Chmod{

# umask によってパーミッションを最大許可しているのでリターンする
return();

# 宣言
my($type,$file,$permission) = @_;

	if($file eq ""){
		warn("Perl warn! File name is empty.");
		Mebius::AccessLog(undef,"chmod-filename-is-empty");
		return();
	}

	# パーミッションが無指定の場合
	if(!defined $permission){ $permission = 0606; }

	# 値のチェック
	unless($permission =~ /^(\d{3,4})$/){ return(); }

my $flag = chmod($permission,$file);

return($flag);

}

#-----------------------------------------------------------
# ファイル情報を取得
#-----------------------------------------------------------
sub file_stat{

# 宣言
my($type,$file) = @_;
my(%file,$FILE1);

# 汚染チェック ( 取得のみ、管理用のみなので、汚染チェックしない？ 
#【ファイル更新処理】を追加するときは注意！ )
#if($file =~ m!(^/|../)!){ return(); }

	# ファイル指定がカラの場合
	if($file eq ""){ return(); }

# ●ファイル情報を取得
	#$file{'f'} = open($FILE1,"<",$file);

	($file{'device_number'},$file{'inode_number'},$file{'mode'},$file{'hardlink_num'},$file{'user_id'},$file{'group_id'},$file{'r_device'},$file{'size'},$file{'last_access_time'},$file{'last_modified'},$file{'last_node_time'},$file{'block_size'},$file{'block_num'})= lstat $file;

$file{'e'} = -e _;

	if($file{'e'}){

		$file{'f'} = -f _;

		local $^T = time;
		$file{'C'} = $file{'create_time'} = -C _;
		$file{'M'} = $file{'modified_time'} = -M _;

			if($file{'create_time'}){
					$file{'create_second'} = $file{'create_time'} * 24*60*60;
			}

	}

#close($FILE1);

#$file{'f'} = open($FILE1,"<",$file);

#flock($FILE1,1);
#($file{'device_number'},$file{'inode_number'},$file{'mode'},$file{'hardlink_num'},$file{'user_id'},$file{'group_id'},$file{'r_device'},$file{'size'},$file{'last_access_time'},$file{'last_modified'},$file{'last_node_time'},$file{'block_size'},$file{'block_num'})= stat($FILE1);
#close($FILE1);

# device_number と r_device の内容が異なる？
#($file{'device_number'},$file{'inode_number'},$file{'mode'},$file{'hardlink_num'},$file{'user_id'},$file{'group_id'},$file{'r_device'},$file{'size'},$file{'last_access_time'},$file{'last_modified'},$file{'last_node_time'},$file{'block_size'},$file{'block_num'})= stat($file);
#if(-f _){ $file{'f'} = 1; }

		# タイムゾーンを調整
		#if($ENV{'TZ'} =~ /\-(\d+)$/){
		#	$file{'last_modified'} += $1*60*60;
		#}
		#elsif($ENV{'TZ'} =~ /\+(\d+)$/){
		#	$file{'last_modified'} -= $1*60*60;
		#}

# 全スタットデータのテキストを定義

$file{'all_stat'} .= qq(device_number : $file{'device_number'}<br>);
$file{'all_stat'} .= qq(inode_number : $file{'inode_number'}<br>);
$file{'all_stat'} .= qq(mode : $file{'mode'}<br>);
$file{'all_stat'} .= qq(hardlink_num : $file{'hardlink_num'}<br>);
$file{'all_stat'} .= qq(user_id : $file{'user_id'}<br>);
$file{'all_stat'} .= qq(group_id : $file{'group_id'}<br>);
$file{'all_stat'} .= qq(r_device : $file{'r_device'}<br>);
$file{'all_stat'} .= qq(size : $file{'size'}<br>);
$file{'all_stat'} .= qq(last_accesss_time : $file{'last_access_time'}<br>);
$file{'all_stat'} .= qq(last_modified : $file{'last_modified'}<br>);
$file{'all_stat'} .= qq(last_node_time : $file{'last_node_time'}<br>);
$file{'all_stat'} .= qq(block_size : $file{'block_size'}<br>);
$file{'all_stat'} .= qq(block_num : $file{'block_num'}<br>);


return(\%file);

}

#-----------------------------------------------------------
# ファイル名の汚染チェック
#-----------------------------------------------------------
sub FileNamePolution{

my($filenames) = @_;
my($error_flag);

	foreach(@$filenames){
			if($_ =~ m!   ../   |   ^/   |   \n   |   \r   |   \0    !x){ $error_flag = 1; }
	}

return($error_flag);

}



package Mebius::File;

#-----------------------------------------------------------
# 読み書き時のファイル読み込み （ ファイルがなければ作成 ）
#-----------------------------------------------------------
sub read_write{

my $type = shift if(ref $_[0] eq "");
my $use  = shift if(ref $_[0] eq "HASH");
my $file1 = shift;
my $directory = shift;
my($FILE1,$RENEW_FLAG,$FLOCK1_FLAG,$FLOCK2_FLAG,%self);

	# 必須値のチェック
	if(!$file1){ die("Perl Die! File name is empty."); }
	if($directory && ref $directory ne "ARRAY"){ die("Perl Die! $directory is not ARRAY Ref."); }

	# フラグを立てる
	if($use->{'Renew'} || $use->{'TypeRenew'} || $type =~ /RENEW|Renew/){ $RENEW_FLAG = 1; }
	elsif($use->{'Flock2'} || $use->{'TypeFlock2'} || $type =~ /FLOCK2|Flock2/){ $FLOCK2_FLAG = 1; }
	elsif($use->{'Flock'} || $use->{'TypeFlock'} || $type =~ /FLOCK|Flock/){ $FLOCK1_FLAG = 1; }

	# ●ファイルを開く ( 開けない場合はすぐエラーに  )
	if($use->{'FileCheckError'} || $type =~ /File-check-error/){
		$self{'f'} = open($FILE1,"+<",$file1) || main::error("File is not here.");
	}

	# ●ファイルを開く ( 開けない場合は他の処理をおこなう )
	else{

		$self{'f'} = open($FILE1,"+<",$file1);

			# ファイルが存在しない場合
			if(!$self{'f'}){

					# ▼新規作成する場合
					if($RENEW_FLAG && !$use->{'DenyTouchFile'} && $type !~ /Deny-touch-file/){

							# ディレクトリを全て作成
							foreach(@$directory){
								Mebius::Mkdir(undef,$_);
							}

						# 空のファイルを作成
						Mebius::Fileout("Allow-empty",$file1);

						$self{'file_touch_flag'} = 1;

						$self{'f'} = open($FILE1,"+<",$file1);

					}
			}

	}

	# ●ファイルが開けた場合の追加処理
	if($self{'f'}){
			# ファイルロック
			if($RENEW_FLAG || $FLOCK2_FLAG){ if(flock$FILE1,2){ $self{'flock_flag'} = $self{'flock2_flag'} = 1; $self{'flock_type'} = 2; } }
			elsif($FLOCK1_FLAG){ if(flock$FILE1,1){ $self{'flock_flag'} = $self{'flock1_flag'} = 1; $self{'flock_type'} = 1; } }
	}

	#if(!$self{'f'}){ warn("Perl warn! Can't open file '$file1'"); }

return($FILE1,\%self);

}

#-----------------------------------------------------------
# フォーマットデータを受け取ってファイルを書き込む
#-----------------------------------------------------------
sub data_format_to_truncate_print{

my $data_format = shift;
my $FILE1 = shift;
my $renew = shift;
my $renew_line = shift;
my(@renew_line);

	if(@_ >= 1){ close($FILE1); die("Perl Die! Too many value was relayed. @_ "); }

	# 必須値のチェック	
	if(ref $data_format ne "HASH"){ close($FILE1); die("Perl Die! $data_format is not HASH reference"); }
	if(ref $FILE1 ne "GLOB"){ close($FILE1); die("Perl Die! $FILE1 is not GLOB"); }
	if(defined $renew && ref $renew ne "HASH"){ close($FILE1); die("Perl Die! $renew is not HASH reference"); }
	if(defined $renew_line && ref $renew_line ne "ARRAY"){ close($FILE1); die("Perl Die! $renew_line is not HASH reference"); }

	# Flock2 されているかどうかの任意のチェック
	if(!$renew->{'flock2_flag'}){ close($FILE1); die("Perl Die! Flock2 was not done."); }

# 汚染チェック
my($renew_formated) = Mebius::format_data_for_file($renew);

	# 2012/8/29 (水) に if で囲う
	if(defined $renew && defined $data_format){
		(@renew_line) = Mebius::data_format_to_renew_line($data_format,$renew_formated);
	}

	# 複数ログ行を一気に追加
	if(ref $renew_line eq "ARRAY"){
		push(@renew_line,@$renew_line)
	}

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq(<pre>$renew->{'votepoint'}</pre>)); }

# ファイル更新
Mebius::File::truncate_print($FILE1,@renew_line);

$renew_formated;

}


#-----------------------------------------------------------
# Truncate して書き込む
#-----------------------------------------------------------
sub truncate_print {

my($FILE,@renew_line) = @_;

	# 念のため判定
	if(ref $FILE ne "GLOB"){ close($FILE); die("Perl Die! Try to print file , but value is not GLOB. <$FILE>"); }
	if("@renew_line" eq ""){ close($FILE); die("Perl Die! Try to print file , but body is empty.");  }
	if(@renew_line <= 0){ close($FILE); die("Perl Die! Trt to print file , but body is empty.");  }

seek($FILE,0,0);
truncate($FILE,tell($FILE));
print $FILE @renew_line;


}


#-----------------------------------------------------------
#-----------------------------------------------------------
sub multi_open{
my $self = multi_open_core(@_);
}

#-----------------------------------------------------------
# 未使用
#-----------------------------------------------------------
sub multi_open_core{

my $use = shift if(ref $_[0] eq "HASH");
my($file,$data_line_array,$top_data_array) = @_;
my(%self,$FILE1);

$self{'file'} = $file;

# コメントを開く
open($FILE1,"<",$file) || return();

	# トップデータの扱い
	if(ref $top_data_array eq "ARRAY"){
		my($i_top);
		chomp(my $top = <$FILE1>);
			foreach(split(<>,$top)){
				$self{$top_data_array->[$i_top]} = $_;
				$i_top++;
			}
	}

	# ●ファイルを展開してハッシュに代入
	while(<$FILE1>){

		chomp;
		my(@data) = split(/<>/,$_);
		my($i,%data);

			foreach(@data){
				$data{$data_line_array->[$i]} = $_;
				$i++;
			}

			push @{$self{'data_line'}} , \%data ;

	}

\%self;

}

#● ここから、元々 Hash.pm にあった分 -----------------------------------------------------------

package Mebius;

#-----------------------------------------------------------
# データを分解してハッシュと関連付け
#-----------------------------------------------------------
sub file_handle_to_hash{

my($data_format,$FILE1) = @_;
my(%hash,$max_line_num,%kind,@all_line,@data_line);

	# 必須値のチェック
	if(ref $data_format ne "HASH"){ die("Perl Die! $data_format is not HASH reference"); }
	if(ref $FILE1 ne "GLOB"){ die("Perl Die! $FILE1 is not GLOB"); }

# データフォーマットの行数を数える
$hash{'line_num'} = keys %$data_format;

	# 外部から指定された行番号がバラバラの場合は、最大数に合わせる
	for(keys %$data_format){
			if($_ > $hash{'line_num'}){
					$hash{'line_num'} = $_;
			}
	}

	# データのチェック
	if($hash{'line_num'} <= 0){
			if(Mebius::alocal_judge()){
				warn("Perl Warn! Format line is none $hash{'line_num'}");
			}
		return(\%hash,$FILE1);
	}

	# トップデータを展開
	for my $for (1..$hash{'line_num'}){

		# 局所化
		my($i);

		# データを受け取って配列に代入
		$hash{"top$for"} = <$FILE1>;
		push(@all_line,$hash{"top$for"});
		chomp $hash{"top$for"};

		# 分解
		my @top_array = split (/<>/,$hash{"top$for"});
		$hash{'data_line'}{$for-1} = \@top_array;
		push(@data_line,\@top_array);

			# 配列を使ってハッシュに関連付け
			for my $KEY ( @ { $data_format->{$for} } ){
				$hash{$KEY} = $top_array[$i];
					if($KEY && $kind{$KEY}++){ close($FILE1); die("Hash '$KEY' is dupilicated "); }
				$i++;
			}

	}

$hash{'data_line_array'} = \@data_line;
$hash{'all_line'} = \@all_line;


\%hash,$FILE1;


}

#-----------------------------------------------------------
# フォーマットデータから更新行を定義
#-----------------------------------------------------------
sub data_format_to_renew_line{

my($data_format,$renew) = @_;
my(@renew_line);

	# 必須値のチェック	
	if(ref $data_format ne "HASH"){ die("Perl Die! $data_format is not HASH reference"); }
	if(ref $renew ne "HASH"){ die("Perl Die! $renew is not HASH reference"); }

# データフォーマットの行数を数える
my $line_num = keys %{$data_format};

	# 外部から指定された行番号がバラバラの場合は、最大数に合わせる
	for(keys %$data_format){
			if($_ > $line_num){	$line_num = $_; }
	}

	# データのチェック
	if($line_num <= 0){
			if(Mebius::alocal_judge()){
				warn("Perl Warn! Format line is none $line_num");
			}
		return();
	}

	# フォーマットの展開
	for my $for (1..$line_num){

		# 局所化
		my($renew_line);

			# 配列を使ってハッシュに関連付け
			for my $hash_key (@ { $data_format->{$for} }){
				$renew_line .= qq($renew->{$hash_key}<>);
			}

			# 更新行がある場合
			if($renew_line){
				push(@renew_line,"$renew_line\n");
			}

			# 更新行がない場合は、末尾に区切り文字を追加
			else{
				push(@renew_line,"$renew_line<>\n");
			}


	}


@renew_line;

}




#-----------------------------------------------------------
# データファイルのフォーマット ( 使えないデータを削除 )
#-----------------------------------------------------------
sub format_data_for_file {

my($hash) = @_;
my(%formated);

	if(ref $hash ne "HASH"){ die("Perl Die! Please relay HASH reference"); }
	if(!$hash){ die("Perl Die! Hash is empty."); }

	foreach(keys %$hash){
		my $KEY = $_;
			if(ref $hash->{$KEY} eq "ARRAY"){
				my @array;
					foreach my $value (@{$hash->{$KEY}}){
							($value) = Mebius::data_format_for_file_core($value);
							push(@array,$value);
						}
					$formated{$KEY} = \@array;
			}

			elsif(ref $hash->{$KEY} eq "HASH"){
				my(%hash);
					while( my($key,$value) = each(%{$hash->{$KEY}}) ){
							($hash{$KEY}{$key}) = Mebius::data_format_for_file_core($value);
					}
				$hash->{$KEY} = \%hash;
			}
			else{
				($formated{$KEY}) = Mebius::data_format_for_file_core($hash->{$KEY});
			}

	}

return(\%formated);

}

#-----------------------------------------------------------
# データファイル用のデータフォーマット ( 配列で渡す場合 )
#-----------------------------------------------------------
sub format_data_for_file_use_array{

my(@self);
my(@data) = @_;

	foreach my $data (@data){
		push(@self,data_format_for_file_core($data));
	}

@self;

}

#-----------------------------------------------------------
# 汚染データの削除
#-----------------------------------------------------------
sub data_format_for_file_core{

my($value) = @_;

$value =~ s/[\r\n]//sg;
$value =~ s/[\0\t]//sg;
$value =~ s/<>//sg;
$value =~ s/(<.*?>)/Mebius::delete_tag_exclution($1)/seg;

$value;

}



#-----------------------------------------------------------
# 一部を除いてタグを削除
#-----------------------------------------------------------
sub delete_tag_exclution{

my($text) = @_;

		if($text =~ /^<(br)>$/){ return $text; }

return();

}



package Mebius::Hash;

#-----------------------------------------------------------
# ハッシュの書き換え
#-----------------------------------------------------------
sub control{

my($renew,@select_renew) = @_;
my(%self,$debug_array_count,$debug_normal_count);

	# 任意の更新がない場合、そのままハッシュをリターン
	if(!@select_renew || @select_renew <= 0){ return($renew); } # 必ず $renew を返すこと、さもなくばデータ内容が全て消去されてしまう
	if(!defined $renew || !$renew){
		Mebius::AccessLog(undef,"Renew-hash-is-empty");
		die("Perl Die! Renew hash is empty.");
	}
	if(ref $renew ne "HASH"){ die("Perl Die! Please hand HASH Refernce."); }

# ●予備代入 ( 重要！ ここで代入しないと戻り値が全て空になり、データが消失してしまうので注意！ )
my %self = %$renew;

# 元のハッシュを参照できるように
#$self{'before_renew'} = \%self;

	# ●任意個のハッシュリファレンスを展開
	foreach my $select_renew (@select_renew){

			# ハッシュリファレンスを判定 ( )
			if(ref $select_renew ne "HASH"){
					if($select_renew eq ""){ next; }
					else{ die("Perl Die! $select_renew is not HASH reference and some value is here."); }
			}

			# $renew に存在しないキーが $select_renew に存在しないかどうかをチェック
			foreach my $KEY ( keys %$select_renew ){
					#if(ref $select_renew->{$KEY} eq "" && !exists $renew->{$KEY} && Mebius::alocal_judge()){ warn("Perl warn! '$KEY' is justy hash key?"); }
			}

			# ▼元データのハッシュを全て展開します。
			# ここで空白の値を代入すると、元のデータが全て削除されてしまうので注意！
			foreach my $KEY ( keys %$renew ){

					# ●配列の操作
					if(ref $self{$KEY} eq "ARRAY"){

						# デバッグ用のカウンタ
						$debug_array_count++;

							# ▼配列全体の上書き
							if(defined $select_renew->{$KEY}){
									if(ref $select_renew->{$KEY} eq "ARRAY"){
										@{$self{$KEY}} = @{$select_renew->{$KEY}};
									}
							}

							# ▼要素の追加 ( Push )
							if(defined $select_renew->{"push"}->{$KEY}){
									if(ref $select_renew->{"push"}->{$KEY} eq "ARRAY"){
											foreach my $value (@{$select_renew->{"push"}->{$KEY}}){
												push(@{$self{$KEY}},$value);
											}
									}
									else{
										push(@{$self{$KEY}},$select_renew->{"push"}->{$KEY});
									}
							}

							# ▼要素の追加 ( Unshit )
							if(defined $select_renew->{"unshift"}->{$KEY}){
									if(ref $select_renew->{"unshift"}->{$KEY} eq "ARRAY"){
											foreach my $value (@{$select_renew->{"unshift"}->{$KEY}}){
												unshift(@{$self{$KEY}},$value);
											}
									}
									else{
										unshift(@{$self{$KEY}},$select_renew->{"unshift"}->{$KEY});
									}
							}


							# ▼要素の削除 ( Pop )
							if(defined $select_renew->{"pop"}->{$KEY}){
									for(1 .. $select_renew->{"pop"}->{$KEY}){
										pop(@{$self{$KEY}});
									}
							}

							# ▼要素の削除 ( Shift )
							if(defined $select_renew->{"shift"}->{$KEY}){
									for(1 .. $select_renew->{"shift"}->{$KEY}){ 
										shift(@{$self{$KEY}});
									}
							}

							# ▼任意の要素に代入
							if(ref $select_renew->{'select'}->{$KEY} eq "ARRAY"){
									#for(0 .. @{$select_renew->{$key}}){
											#if(defined $select_renew->{$key}[$KEY]){ $self{$key}[$KEY] = $select_renew->{$key}[$KEY]; }
									#}
							}

					}

					# ●スカラの操作 ( 値はリファレンスではない )
					else{

						# デバッグ用のカウンタ
						$debug_normal_count++;

							# ▼上書き
							if(defined $select_renew->{$KEY}){
								$self{$KEY} = $select_renew->{$KEY};
							}

							# ▼加算
							if(defined $select_renew->{"+"}->{$KEY}){
									if(ref $select_renew->{"+"}->{$KEY} eq "HASH"){
											while( my($key,$value) = each(%{$select_renew->{"+"}->{$KEY}}) ){
												$self{$KEY} += $select_renew->{"+"}->{$KEY};
											}
									}
									else{
										$self{$KEY} += $select_renew->{"+"}->{$KEY};
									}
							}

							# ▼減算
							if(defined $select_renew->{"-"}->{$KEY}){
									if(ref $select_renew->{"-"}->{$KEY} eq "HASH"){
											while( my($key,$value) = each(%{$select_renew->{"-"}->{$KEY}}) ){
												$self{$KEY} -= $select_renew->{"-"}->{$KEY};
											}
									}
									else{
										$self{$KEY} -= $select_renew->{"-"}->{$KEY};
									}
							}

							# ▼乗算
							if(defined $select_renew->{"*"}->{$KEY}){
								$self{$KEY} *= $select_renew->{"*"}->{$KEY};
							}

							# ▼除算
							if(defined $select_renew->{"/"}->{$KEY}){
									# 0では割らないように
									if($select_renew->{"/"}->{$KEY} == 0){
									}
									else{
										$self{$KEY} /= $select_renew->{"/"}->{$KEY};
									}
							}

							# ▼数値がこれより小さくならないように
							if(defined $select_renew->{">="}->{$KEY}){
									if($self{$KEY} < $select_renew->{">="}->{$KEY}){ $self{$KEY} = $select_renew->{">="}->{$KEY}; }
							}


							# ▼数値がこれより大きくならないように
							if(defined $select_renew->{"<="}->{$KEY}){
									if($self{$KEY} > $select_renew->{"<="}->{$KEY}){ $self{$KEY} = $select_renew->{"<="}->{$KEY}; }
							}


							# ▼テキストの削除
							if(defined $select_renew->{"s/g"}->{$KEY}){
									if(ref $select_renew->{"s/g"}->{$KEY} eq "HASH"){
											while( my($key,$value) = each(%{$select_renew->{"s/g"}->{$KEY} }) ){
												$self{$KEY} =~ s/(\s)?$value//g;
											}
									}
									else{
										$self{$KEY} =~ s!(\s)?$select_renew->{"s/g"}->{$KEY}!!g;
									}
							}


							# ▼テキストの追加 ( 新 )
							if(defined $select_renew->{"."}->{$KEY}){
									if(ref $select_renew->{"."}->{$KEY} eq "HASH"){
											while( my($key,$value) = each(%{$select_renew->{"."}->{$KEY} }) ){
												#$self{$KEY} =~ s/(\s)?$value//g;
												$self{$KEY} .= qq($value);
											}
									}
									else{
										#$self{$KEY} =~ s/(\s)?$select_renew->{"."}->{$KEY}//g;
										$self{$KEY} .= qq($select_renew->{"."}->{$KEY});
									}
							}


					}

			}

			# 元データのハッシュを全て展開します。
			# ここで空白の値を代入 ( $self{$KEY} = undef; )すると、元のデータが全て削除されてしまうので注意！
			# %renew ではなくて %return から展開すること、そうでないとこれ以前の処理で変更されたハッシュに合わせることが出来ないので
			foreach my $KEY ( keys %self ){

					# 別のハッシュを代入
					if(defined $select_renew->{"="}->{$KEY}){
						my $hash = $select_renew->{"="}->{$KEY};
						$self{$KEY} = $self{$hash};
					}

			}

	}


return(\%self);

}


#-----------------------------------------------------------
# ハッシュを展開
#-----------------------------------------------------------
sub Foreach{

my($use,$hash) = @_;
my(%data);

	# ハッシュを展開
	foreach my $key ( sort keys %$hash){

			# カウンタ
			if(exists $hash->{$key}){ $data{'cont'}++; }

					# HTMLを取得
					if($use->{'TypeGetHTML'}){

							if($use->{'HTMLType'} eq "List"){ $data{'html'} .= qq(<li>); }
						$data{'html'} .= qq(<strong>$key </strong>: $hash->{$key});
							if($use->{'HTMLType'} eq "List"){ $data{'html'} .= qq(</li>); }
							else{ $data{'html'} .= qq( / ); }
							$data{'html'} .= qq(\n);

			}

	}

	#if($use->{'TypeRooping'}){
	#	return(\$data);
	#}

	# 整形
	if($use->{'TypeGetHTML'}){
				if($use->{'HTMLType'} eq "List"){ $data{'html'} = qq(<ol>$data{'html'}</ol>); }
	}

return(\%data);

}


#-----------------------------------------------------------
# ハッシュを展開
#-----------------------------------------------------------
sub ForeachHTML{

my($use,$hash) = @_;
$use->{'TypeGetHTML'} = 1; 

my($hash_foreach) = Mebius::Hash::Foreach($use,$hash);
return($hash_foreach->{'html'});
}

package Mebius;

#-----------------------------------------------------------
# データシリーズを配列として返す
#-----------------------------------------------------------
sub data_seriese_9{

my $use = shift if(ref $_[0] eq "HASH");
my $input_name = shift;
my($my_connection) = Mebius::my_connection();
my($q) = Mebius::query_state();
my($handle) = Mebius::Regist::name_check($input_name);
my($trip) = main::trip(shift_jis($input_name));

# モバイルの個体識別番号
my($mobile_user_agent) = $my_connection->{'user_agent'} if();

# 他スクリプトへの転載用コメントアウト
# $handle2,$trip2,$id2,$cookie_char2,$account2,$addr2,$host2,$user_agetn2,$mobile_uid2

	# ユーザー属性を配列として定義しておく ( 6個 )
	my @self = (
		$handle || undef ,
		$trip || undef ,
		$my_connection->{'id'} || undef ,
		$my_connection->{'cookie'} || undef ,
		$my_connection->{'account'} || undef , 
		$ENV{'REMOTE_ADDR'} || undef ,
		$my_connection->{'host'} || undef ,
		$ENV{'HTTP_USER_AGENT'} || undef ,
		$my_connection->{'mobile_full_uid'} || undef 
	);

@self;

}




#-----------------------------------------------------------
# 二つのディレクトリのファイル内容を結合
#-----------------------------------------------------------
sub join_files_on_directories{

my($add_directory,$main_directory) = @_;

	if(!-d $add_directory){ die("$add_directory is not Directory."); }
	if(!-d $main_directory){ die("$add_directory is not Directory."); }

Mebius::Directory::adjust_slash($add_directory,$main_directory);

my(@add_directory) = Mebius::Directory::get_directory($add_directory);

	foreach my $file (@add_directory){
		join_file_without_top_line("${add_directory}$file","${main_directory}$file","${main_directory}$file");
		print $file;
		print "\n";
	}


}

#-----------------------------------------------------------
# 二つのファイルを結合する ( 1行目を除く )
#-----------------------------------------------------------
sub join_file_without_top_line{

my $use = shift if(ref $_[0] eq "HASH");
my($add_file,$main_file,$out_file) = @_;
my($FILE1,$FILE2);

	# エラーチェック
	if($out_file eq ""){ die(); }
	if($main_file eq ""){ die(); }
	if($add_file eq ""){ die(); }

my($main_line) = get_file_with_array($main_file);
my($add_line) = get_file_with_array($add_file);

	# 両方のファイルとも身がなければ何もしない
	if(!$add_line && !$main_line){ return(); }

	# メインファイルと書き出し先ファイルが同じの場合はエラーに
	if($out_file eq $add_file){ die("Two file name is same. it's strange."); }

my @add_line = @$add_line if($add_line);
my @main_line = @$main_line if($main_line);

	# メインファイルのトップデータが存在する場合は、二番目のファイルのトップデータを削除してから、本体データだけを追加する
	if(@main_line){
		shift(@add_line);
	}

my(@out_line) = (@main_line,@add_line);

Mebius::Fileout(undef,$out_file,@out_line);

}

#-----------------------------------------------------------
# トップ１行以外を配列として取得する
#-----------------------------------------------------------
sub get_file_with_array{

my($file) = @_;
my($FILE,@self);

my $open = open($FILE,"<",$file);
	if(!$open){ return(); }

#chomp(my $top = <$FILE>);

	while(<$FILE>){

		push(@self,$_);
	}

close($FILE);


\@self;

}

1;

