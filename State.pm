
use strict;
package Mebius::State;

#-----------------------------------------------------------
# Near State 変数をコール => 速度優先 ?
#-----------------------------------------------------------
sub Call{

	# スイッチ => 少しでも高速化するため、コメントアウトしておこうか
	#if(!Mebius::Switch::NearState()){ return(); }

# 宣言
my($PackageName,$MethodName,$StateKey) = @_;
our(%state);

	# リターン
	# exists 判定なしで単純に return($_); してしまうと、値が 0 の場合に対応できないため、必ず exists 判定する
	if(exists $state{$PackageName}{$MethodName}{$StateKey}){
		return($state{$PackageName}{$MethodName}{$StateKey});
	}
	else{
		return();
	}

}

#-----------------------------------------------------------
# Near State 変数をセーブ=> 速度優先 ?
#-----------------------------------------------------------
sub Save{

	# スイッチ => 少しでも高速化するため、コメントアウトしておこうか
	#if(!Mebius::Switch::NearState()){ return(); }

# 宣言
my($PackageName,$MethodName,$StateKey,$SaveValue) = @_;
our(%state);

	# 必須項目をチェック
	# $SaveValue は undef の場合でも有効に処理させたいので、if(!defined){} 判定をおこなわない
	if(!defined $PackageName){ die("Perl Die!  PackageName is not defined."); }
	if(!defined $MethodName){ die("Perl Die! StateName is not defined."); }
	#if(!defined $StateKey){ die("Perl Die! StateKey is not defined."); }

	# 変数が既にセットされている場合はプログラムバグなのでエラーを出す
	if(exists $state{$PackageName}{$MethodName}{$StateKey}){
		die("Perl Die!  Same State Package , State Name , and State Key is selected. ( $PackageName => $MethodName => $StateKey : $SaveValue ) ");
	}

	# 変数をセットする
	else{
			# Save内容がある場合はそのままセット
			if(defined $SaveValue){
				$state{$PackageName}{$MethodName}{$StateKey} = $SaveValue;
			}
			# セーブ値が undef の場合にも対応 ( 重要 ： 必ず null 値をセットすること )
			# ここで undef をセットしてしまうと、&Call 呼び出し後に値を取得できないので注意
			else{
				$state{$PackageName}{$MethodName}{$StateKey} = "";
			}
	}


}


#-----------------------------------------------------------
# Call Stateされなかった回数をカウント ( State の記述にミスがあると、ここでカウンタが膨大な数になる )
#-----------------------------------------------------------
sub ElseCount{

# 宣言
my($PackageName,$MethodName,$StateKey) = @_;

	# ローカルでカウント
	#if(Mebius::alocal_judge()){

		# 局所化
		our(%state_count);

			# 例外処理
			if(!defined $PackageName){ die("Perl Die!  PackageName is not defined"); }
			if(!defined $MethodName){ die("Perl Die!  StateName is not defined"); }
			if(!defined $StateKey){ die("Perl Die!  StateKey is not defined"); }

			if(Mebius::alocal_judge()){  
				$state_count{$PackageName}{$MethodName}{$StateKey}++;
			}
		our $state_else_count++;


	#}

	# リアルサーバーでは何もしない
	#else{
	#	return();
	#}

}

#-----------------------------------------------------------
# 例外カウンタを取得
#-----------------------------------------------------------
sub GetElseCountMulti{
our %state_count;
return(\%state_count);
}


#-----------------------------------------------------------
# 例外カウンタを取得
#-----------------------------------------------------------
sub GetElseCount{
our $state_else_count;
return($state_else_count);
}


#-----------------------------------------------------------
# 変数を削除
#-----------------------------------------------------------
sub AllReset{

	# スイッチ => 少しでも高速化するため、コメントアウトしておこうか
	#if(!Mebius::Switch::NearState()){ return(); }

undef(our %state);
#undef(our %state_count);
undef(our $state_else_count);


}

#-----------------------------------------------------------
# Near State 変数をコール
#-----------------------------------------------------------
sub call_parmanent{

	# スイッチ => 少しでも高速化するため、コメントアウトしておこうか
	#if(!Mebius::Switch::NearState()){ return(); }

# 宣言
my $use = shift if(ref $_[0] eq "HASH"); # 先頭がリファレンスであれば、以降の引数を一個ずつずらして受け取る
my($PackageName,$MethodName,$StateKey) = @_;
our(%state_parmanent,%counter_parmanent);

	# リターン
	# exists 判定なしで単純に return($_); してしまうと、値が 0 の場合に対応できないため、必ず exists 判定する
	if(exists $state_parmanent{$PackageName}{$MethodName}{$StateKey}){

			# 最大呼び出し回数を超えてリセットする場合
			if($use->{'MaxCall'} && $use->{'MaxCall'} >= $counter_parmanent{$PackageName}{$MethodName}{$StateKey}){
				$counter_parmanent{$PackageName}{$MethodName}{$StateKey} = 0;
			}
			# 呼び出しカウンタを増やす
			else{
				$counter_parmanent{$PackageName}{$MethodName}{$StateKey}++;
			}

		return($state_parmanent{$PackageName}{$MethodName}{$StateKey});
	}
	else{
		return();
	}

}

#-----------------------------------------------------------
# Near State 変数をセーブ
#-----------------------------------------------------------
sub save_parmanent{

	# スイッチ => 少しでも高速化するため、コメントアウトしておこうか
	#if(!Mebius::Switch::NearState()){ return(); }

# 宣言
my($PackageName,$MethodName,$StateKey,$SaveValue) = @_;
our(%state_parmanent);

	# 必須項目をチェック
	# $SaveValue は undef の場合でも有効に処理させたいので、if(!defined){} 判定をおこなわない
	if(!defined $PackageName){ die("Perl Die!  PackageName is not defined."); }
	if(!defined $MethodName){ die("Perl Die! StateName is not defined."); }
	if(!defined $StateKey){ die("Perl Die! StateKey is not defined."); }

	# 変数が既にセットされている場合はプログラムバグなのでエラーを出す
	if(exists $state_parmanent{$PackageName}{$MethodName}{$StateKey}){
		die("Perl Die!  Same State Package , State Name , and State Key is selected. ( $PackageName => $MethodName => $StateKey : $SaveValue ) ");
	}

	# 変数をセットする
	else{
			# Save内容がある場合はそのままセット
			if(defined $SaveValue){
				$state_parmanent{$PackageName}{$MethodName}{$StateKey} = $SaveValue;
			}
			# セーブ値が undef の場合にも対応 ( 重要 ： 必ず null 値をセットすること )
			# ここで undef をセットしてしまうと、&Call 呼び出し後に値を取得できないので注意
			else{
				$state_parmanent{$PackageName}{$MethodName}{$StateKey} = "";
			}
	}


}

1;

