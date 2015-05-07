
use strict;
package Mebius::Operate;
use Mebius::LikePHP;


#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hash_eq{

my $self = shift;
my $hash1 = shift;
my $hash2 = shift;
my $exclution = shift || {};
my($eq_flag,$ne_flag);

	foreach my $key ( keys %{$hash1} ){
			if(!(in_array($key,@$exclution)) && $hash1->{$key} ne $hash2->{$key}){
				$ne_flag = 1;
			}	
	}

	foreach my $key ( keys %{$hash2} ){
			if(!(in_array($key,@$exclution)) && $hash1->{$key} ne $hash2->{$key}){
				$ne_flag = 1;
			}	
	}

	if(!$ne_flag){
		$eq_flag = 1;
	}

$eq_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub redun_array_values{

my $self = shift;
my $array = shift || return();
my(@redun,%redun);

	foreach my $value (@{$array}){
			if($redun{$value}++){
				push @redun , $value;
			}
	}

@redun;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hash_limited_key_or_delete_key{

my $self = shift;
my $hash = shift || die;
my $use_hash = shift || die;
my(%new_hash);

	foreach my $key ( keys %{$use_hash} ){
		$new_hash{$key} = $hash->{$key};	
	}

\%new_hash;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub array_to_hash{

my $self = shift;
my $array = shift;
my $select_key = shift || die;
my(%hash);

	foreach my $data (@${array}){
			if(exists $data->{$select_key}){
				$hash{$data->{$select_key}} = $data;
			} else {
				die;
			}
	}

\%hash;

}




#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub hash_in_array_ref_to_array{

my $self = shift;
my $array = shift;
my $select_key = shift || die;
my(@array,%kind);

	foreach my $data (@${array}){
			if($kind{$data->{$select_key}}++){
				next;
			} elsif(exists $data->{$select_key}){
				push @array , $data->{$select_key};
			} else {
				die;
			}
	}

@array;

}



#-----------------------------------------------------------
# 配列に追加
#-----------------------------------------------------------
sub push_unique_near_array{

my $self = shift;
my $scalar = shift;
my $new_element = shift;

my @array = $self->delete_element_near_array($scalar,$new_element);

push @array , $new_element;

@array;

}


#-----------------------------------------------------------
# 配列の中に特定の要素があるかどうかを調べる
#-----------------------------------------------------------
sub element_in_array{

my $self = shift;
my $scalar_or_array = shift;
my $select_element = shift;
my($hit_flag);

my @array = $self->to_array($scalar_or_array);

	if(!$select_element){ return(); }

	foreach my $element (@array){
			if($element eq $select_element){
				$hit_flag = 1;
			} else {
				0;
			}
	}

$hit_flag;


}



#-----------------------------------------------------------
# 変数を区切って配列にして、さらに push した値を返す
#-----------------------------------------------------------
sub push_near_array{

my $self = shift;
my $scalar = shift || return();
my $push_scalar = shift;
my $max_num = shift;
my $split_mark = "\\s";

my @array = split(/$split_mark/,$scalar);

push @array , $push_scalar;

@array;

}


#-----------------------------------------------------------
# 配列に
#-----------------------------------------------------------
sub to_array{

my $self = shift;
my $array_or_scalar = shift;
my(@array);

	if(ref $array_or_scalar eq ""){
		@array = split(/\s+/,$array_or_scalar);
	} elsif(ref $array_or_scalar eq "ARRAY"){
		@array = @{$array_or_scalar};
	} else {
		die;
	}

@array;

}


#-----------------------------------------------------------
# 最大個数を付けて push する
#-----------------------------------------------------------
sub push_limited_num{

my $self = shift;
my $array_or_scalar = shift;
my $push_element = shift;
my $max_num = shift;
my($i,@array);

my @array = $self->to_array($array_or_scalar);
push @array , $push_element;

	if($max_num !~ /^[0-9]+$/){ return(@array); }

my $array_num = @array;

	if($array_num > $max_num){
		my $round = $array_num-$max_num;

			for(1 .. $round){
				shift @array;
			}
	}

@array;

}




#-----------------------------------------------------------
# 配列から特定の要素を削除する
#-----------------------------------------------------------
sub delete_element_near_array{

my $self = shift;
my $scalar = shift || return();
my $delete_scalar = shift;
my $split_mark = shift || "\\s";

my @array = split(/$split_mark/,$scalar);

@array = $self->delete_element_from_array(\@array,$delete_scalar);

@array;

}


#-----------------------------------------------------------
# 配列から特定の値を削除する
#-----------------------------------------------------------
sub delete_element_from_array{

my $self = shift;
my $array = shift;
my $delete_scalar = shift;
my @return_array;

	foreach my $element (@{$array}){
			if($delete_scalar eq $element){
					next;
			} else {
					push @return_array , $element;
			}
	}

@return_array;

}




#-----------------------------------------------------------
# ハッシュを上書きする ( しかしリファレンスの中身は壊さない )
#-----------------------------------------------------------
sub overwrite_hash{

my $self = shift;
my $original = shift;
my $overwrite = shift;
my(%hash_copy);

	if(ref $original eq "HASH"){
		%hash_copy = %{$original};
	}

	if(ref $overwrite eq "HASH"){
		%hash_copy = (%hash_copy,%{$overwrite});
	}
 

\%hash_copy;

}


#-----------------------------------------------------------
# 交換
#-----------------------------------------------------------
sub bigger_number_swap{

my $self = shift;

	if($_[0] < $_[1]){
		($_[0],$_[1]) = ($_[1],$_[0]);
	}

}


package Mebius;

#-----------------------------------------------------------
# 配列を任意のマークで区切って、スカラとして返す
#-----------------------------------------------------------
sub join_array_with_mark{

my($mark,@array) = @_;
my($self);

	foreach(@array){
			# 配列のリファレンスの場合
			if(ref $_ eq "ARRAY"){
					foreach(@{$_}){
						join_with_mark($mark,$_,$self);
					}
			# 変数の場合
			} elsif(ref $_ eq "") {
				join_with_mark($mark,$_,$self);
			}

	}

$self;

}

#-----------------------------------------------------------
# マークで結合
#-----------------------------------------------------------
sub join_with_mark{

my($mark,$value,undef) = @_;

	if($_[2] eq ""){
		$_[2] = $value;
	} else {
		$_[2] .= $mark . $value;
	}

}


#-----------------------------------------------------------
# definedなら代入する
#-----------------------------------------------------------
sub if_defined_set{

	if(defined $_[1]){
		$_[0] = $_[1];
	}


}

#-----------------------------------------------------------
# スカラ、配列、ハッシュを問わずに、二つの対象から同一の値があるかどうかを判定する
#-----------------------------------------------------------
sub multi_equal{

my($target1,$target2) = @_;
my($self);

my(%hash1) = multi_hash($target1);
my(%hash2) = multi_hash($target2);

	foreach(keys %hash1){
		if($hash2{$_}){ $self = 1; }
	}

$self;

}

#-----------------------------------------------------------
# スカラも配列もハッシュも、値をハッシュ化する
# ( 値をハッシュにするため、元がハッシュの場合は reverse する )
#-----------------------------------------------------------
sub multi_hash{

my($target) = @_;
my(%self);

	if(ref $target eq ""){
		$self{$target} = 1;
	} elsif(ref $target eq "ARRAY"){
		foreach(@$target){
			$self{$_} = 1;
		}
	} elsif(ref $target eq "HASH"){
		%self = reverse %$target;
	}

%self;

}

#-----------------------------------------------------------
# タブ ( \t ) を削除する
#-----------------------------------------------------------
sub delete_tab{

	foreach(@_){
		s/\t//g;
	}

}

#-----------------------------------------------------------
# 順位を決めて代入する
#-----------------------------------------------------------
sub order{

my(@texts) = @_;

	foreach(@texts){
		if($_ ne ""){ return $_; }
	}


}
#-----------------------------------------------------------
# 同じ値かどうかを調べて、スカラを返す
#-----------------------------------------------------------
sub same_values_check_and_foreach_text{

my(@results) = same_values_check(@_);

my($self) = join_array_with_mark("/",@results);

	if(@results >= 1){
		$self .= " の " . @results . "項目";
	}

}

#-----------------------------------------------------------
# 同じ値かどうかを調べる (配列リファレンスの、ハッシュリファレンスとして渡す)
#-----------------------------------------------------------
sub same_values_check{

my($kinds) = @_;
my($self,@hit,$hit);

	# フォーマットチェック
	if(ref $kinds ne "HASH"){ die("'$kinds' is Not HASH Reference."); }

	# ハッシュを展開
	foreach my $name ( keys %$kinds ){

		# フォーマットチェック
		if(ref $kinds->{$name} ne "ARRAY"){
			die("'$kinds->{$name}' is not ARRAY Reference.");
		}

		# 値が空の場合
		if($kinds->{$name}->[0] eq "" || $kinds->{$name}->[1] eq "") {
			next;
		}

		# 一番目の要素と、二番目の要素を比べる
		if($kinds->{$name}->[0] eq $kinds->{$name}->[1]){
			push(@hit,$name);

		} else {

		}

	}


@hit;

}



1;
