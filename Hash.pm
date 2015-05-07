
use strict;
#use warnings;
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
	if($hash{'line_num'} <= 0){ die("Perl Die! Format line is none $hash{'line_num'}"); }

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
	if($line_num <= 0){ die("Perl Die! Format line is none $line_num"); }

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
# 汚染データの削除
#-----------------------------------------------------------
sub data_format_for_file_core{

my($value) = @_;

$value =~ s/<>|\r|\n|\0|\t//g;
$value =~ s/(<.*?>)/Mebius::delete_tag_exclution($1)/eg;

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
	if(!defined @select_renew || @select_renew <= 0){ return($renew); } # 必ず $renew を返すこと、さもなくばデータ内容が全て消去されてしまう
	if(!defined $renew || !$renew){
		Mebius::AccessLog(undef,"Renew-hash-is-empty");
		die("Perl Die! Renew hash is empty.");
	}
	if(ref $renew ne "HASH"){ die("Perl Die! Please hand HASH Refernce."); }

# ●予備代入 ( 重要！ ここで代入しないと戻り値が全て空になり、データが消失してしまうので注意！ )
my %self = %$renew;

	# ●任意個のハッシュリファレンスを展開
	foreach my $select_renew (@select_renew){

			# ハッシュリファレンスを判定 ( )
			if(ref $select_renew ne "HASH"){
					if($select_renew eq ""){ next; }
					else{ die("Perl Die! $select_renew is not HASH reference and some value is here."); }
			}

			# $renew に存在しないキーが $select_renew に存在しないかどうかをチェック
			foreach my $KEY ( keys %$select_renew ){
					#if(ref $select_renew->{$KEY} eq "" && !exists $renew->{$KEY} && Mebius::AlocalJudge()){ warn("Perl warn! '$KEY' is justy hash key?"); }
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


1;
