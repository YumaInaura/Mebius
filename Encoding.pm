
use strict;
use Encode::Guess;
use Mebius::BasicInit;
use Mebius::Encode;
package Mebius::Encoding;

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
sub encode{

my $self = shift;
my $text = shift;
my $encoded = Mebius::encode_text($text);

$encoded;

}


#-----------------------------------------------------------
# URLをエンコード
#-----------------------------------------------------------
sub encode_url{

my $self = shift;
my $url = shift;
my $encoded_text = Mebius::encode_text($url);

# 未予約語
$encoded_text =~ s/%2a/*/ig;
$encoded_text =~ s/%2e/./ig;
$encoded_text =~ s/%27/'/ig;
$encoded_text =~ s/%28/(/ig;
$encoded_text =~ s/%29/)/ig;
$encoded_text =~ s/%5e/^/ig;
$encoded_text =~ s/%21/!/ig;
$encoded_text =~ s/%20/+/ig;

# 不明
#$encoded_text =~ s/%5b/[/ig;
#$encoded_text =~ s/%5d/]/ig;

# 予約語
$encoded_text =~ s/%40/@/ig;
#$encoded_text =~ s/%2c/,/ig;
#$encoded_text =~ s/%3a/:/ig;
#$encoded_text =~ s/%3b/;/ig;
#$encoded_text =~ s/%24/\$/ig;

#$encoded_text =~ s/%25/%/ig;
#$encoded_text =~ s/%5c/\\/ig;



$encoded_text;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub eucjp_to_utf8{

my $self = shift;

	foreach(@_){

			if($_ eq ""){ next; }


		Encode::from_to($_, 'euc-jp' , 'utf8');

	}

wantarray ? @_ : $_[0];

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub utf8_to_eucjp{

my $self = shift;

	foreach(@_){

			if($_ eq "" || ref $_){ next; }

		Encode::from_to($_, 'utf8' , 'euc-jp');

	}

wantarray ? @_ : $_[0];

}

#-----------------------------------------------------------
# ハッシュをUTF8に
#-----------------------------------------------------------
sub hash_to_utf8{

my($hash) = @_;
my(%self);

	foreach( keys %$hash ){

			if(!defined $hash->{$_}){
				next;
			# リファレンスの場合は何も処理しない
			} elsif(ref $hash->{$_}){
				$self{$_} = $hash->{$_};
				next;
			# 英数字の場合は変換しない
			} elsif($hash->{$_} =~ /^\w+$/){ 
				$self{$_} = $hash->{$_};
				next;
			}

		($self{$_}) = shift_jis_to_utf8_return($hash->{$_});
	}

\%self;

}

#-----------------------------------------------------------
# ハッシュをUTF8に
#-----------------------------------------------------------
sub hash_to_shift_jis{

my($hash) = @_;
my(%self);

	foreach( keys %$hash ){

			if(!defined $hash->{$_}){ next; }

			# 英数字の場合は変換しない
			elsif($hash->{$_} =~ /^\w+$/){ 
				$self{$_} = $hash->{$_};
				next;
			}

		($self{$_}) = utf8_to_shift_jis_return($hash->{$_});
	}

\%self;

}

#-----------------------------------------------------------
# Shift JIS から UTF8へ
#-----------------------------------------------------------
sub sjis_to_utf8{

	foreach(@_){

			if($_ eq ""){ next; }

		Encode::from_to($_, 'cp932', 'utf8');

	}


wantarray ? @_ : $_[0];

}

#-----------------------------------------------------------
# UTF8 から Shift JISへ
#-----------------------------------------------------------
sub shift_jis_to_utf8_return{

my(@text) = @_;

sjis_to_utf8(@text);

}


#-----------------------------------------------------------
# Shift JIS から UTF8へ ( 引数文字コードを判定 )
#-----------------------------------------------------------
sub guess_and_utf8{

my($guess) = guess("@_");

	if($guess eq "shiftjis"){
		sjis_to_utf8(@_);
	}

}


#-----------------------------------------------------------
# Shift JIS から UTF8へ ( クエリの文字コードを判定 )
#-----------------------------------------------------------
sub guess_query_and_utf8{

my($guess) = all_queries_guess();

	if($guess ne "utf8"){
		sjis_to_utf8(@_);
	}

}

#-----------------------------------------------------------
# UTF8 から Shift JISへ( 引数文字コードを判定 )
#-----------------------------------------------------------
sub guess_and_shift_jis{

my($guess) = guess("@_");

	if($guess eq "utf8"){
		utf8_to_sjis(@_);
	}

$guess;

}






#-----------------------------------------------------------
# UTF8 から Shift JISへ
#-----------------------------------------------------------
sub utf8_to_sjis{

	foreach(@_){

			if($_ eq ""){ next; }

		Encode::from_to($_, 'utf8' , 'cp932');

	}

wantarray ? @_ : $_[0];

}

#-----------------------------------------------------------
# UTF8 から Shift JISへ
#-----------------------------------------------------------
sub utf8_to_shift_jis_return{

my(@text) = @_;

utf8_to_sjis(@text);


}

#-----------------------------------------------------------
# 文字コードを判定して SHIFT_JIS に
#-----------------------------------------------------------
sub guess_query_and_sjis{

my($guess) = all_queries_guess();

	if($guess ne "shiftjis"){
		utf8_to_sjis(@_);
	}

}


#-----------------------------------------------------------
# 文字コード変換
#-----------------------------------------------------------
sub from_to{

# 先頭がハッシュリファレンスの場合
my $use = shift if(ref $_[0] eq "HASH");

# 定義
my $from_encoding = shift;
my $to_encoding = shift;

	# 必須値のチェック
	if(ref $_[0] ne ""){ return($_[0]); }

	if(!$from_encoding){ die("Perl Die!  From encoding is empty."); }
	if(!$to_encoding){ die("Perl Die!  To encoding is empty."); }

	# 文字コードの整形
	$from_encoding = lc $from_encoding;
	$to_encoding = lc $to_encoding;

		# 値を揃える
		if($from_encoding =~ /^(s)(hift)(_)?(jis)$/i){ $from_encoding = "shiftjis"; }
		if($to_encoding =~ /^(s)(hift)(_)?(jis)$/i){ $to_encoding = "shiftjis"; }

	# 同じ文字コード同士はエンコードしない
	if($from_encoding eq $to_encoding){
			#warn("Same encoding setinng. <$from_encoding> to <$to_encoding>");
			return();
	}

	# From Encoding を自動判定する場合
	if($from_encoding =~ /^Guess$/i){
		($from_encoding) = Mebius::Encoding::guess(@_);
	}

	# 同じ文字コード同士はエンコードしない ( もしかして Encode::from_to の中に同じ処理がある？ => どうやらない模様 )
	if($from_encoding eq $to_encoding){ return(); }

	# 文字コード変換
	if($from_encoding){
			foreach(@_){
				Encode::from_to($_,$from_encoding,$to_encoding);
			}
	}

wantarray ? @_ : $_[0];



}

#-----------------------------------------------------------
# 文字コードを判定
#-----------------------------------------------------------
sub guess{

my($text) = @_;
my($convert_from);

	if(!$text){ return(); }

# 判定
my $encode_judge = Encode::Guess::guess_encoding($text, qw/euc-jp shift_jis/); # utf8は何も指定しなくても、デフォルトの判定候補に含まれる

	# 文字コードが１種類に絞れた場合にだけフラグを立てる
	if(ref $encode_judge){
		$convert_from = $encode_judge->name;
	}

$convert_from;

}

#-----------------------------------------------------------
# 全てのクエリから、文字コードを判定
#-----------------------------------------------------------
sub all_queries_guess{

my($q) = Mebius::query_state();
my(@queries);

# Near State （呼び出し） 2.30
my $HereName1 = "all_query_guess";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$StateKey1); }

	foreach($q->param()){
		push(@queries,$q->param($_));
	}

my($self) = Mebius::Encoding::guess("@queries");

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$self); }

$self;

}

1;
