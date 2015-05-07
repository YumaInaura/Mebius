
package Mebius::Query;

use strict;

use Mebius::Device;

use Mebius::Export;

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
sub param{
Mebius::Query->single_param();
}
#-----------------------------------------------------------
# POST メソッドなら
#-----------------------------------------------------------
sub post_method{ my $self = shift; $self->post_method_judge(@_); }
sub post_method_judge{

my $self = shift;

	if($ENV{'REQUEST_METHOD'} eq "POST"){
		1;
	} else {
		0;
	}

}



#-----------------------------------------------------------
# POST メソッドなら
#-----------------------------------------------------------
sub get_method{ my $self = shift; $self->get_method_judge(@_); }
sub get_method_judge{

my $self = shift;

	if($ENV{'REQUEST_METHOD'} eq "GET"){
		1;
	} else {
		0;
	}

}

#-----------------------------------------------------------
# POSTメソッドだけを許可し、それ以外はエラーを出す
#-----------------------------------------------------------
sub post_method_or_error{

my $self = shift;

	if($ENV{'REQUEST_METHOD'} ne "POST"){
		my $print = "送信方法が変です。";
		Mebius::Template::gzip_and_print_all({ source => "utf8" ,  BCL => ["エラー"] },$print);
		exit;
	}

}

#-----------------------------------------------------------
# パラメータを取得
#-----------------------------------------------------------
sub single_param{

my $self = shift;

# Near State （呼び出し） 2.30
my $HereName1 = "query_hash_ref";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

my($q) = Mebius::query_state();
my(%self);

	foreach($q->param()){
		my @param = $q->param($_);
		$self{$_} .= "@param";
		#$self{$_} .= $q->param($_);
	}

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,\%self); }


\%self;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub single_param_utf8{

my $self = shift;
my $single_param = $self->single_param();
my($single_param_utf8);

	if($self->selected_encode_is_shift_jis() || $self->selected_encode_is_none()){
		$single_param = Mebius::Encoding::hash_to_utf8($single_param);
	} else {
		$single_param;
	}

$single_param;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub param_utf8_judged_query{

my $self = shift;
my $single_param = $self->single_param();
my($single_param_utf8);

	if($self->selected_encode_is_utf8() || $self->selected_encode_is_none()){
		$single_param;
	} else {
		$single_param = Mebius::Encoding::hash_to_utf8($single_param);
	}

$single_param;

}

#-----------------------------------------------------------
# 端末を判定して UTF8のクエリを返す
#-----------------------------------------------------------
sub single_param_utf8_judged_device{

my $self = shift;
my $single_param = $self->single_param();
my $device = new Mebius::Device;
my($single_param_utf8);

	if($device->use_device_is_mobile()){
		$single_param = Mebius::Encoding::hash_to_utf8($single_param);
	} else {
		$single_param;
	}

$single_param;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub single_param_shift_jis{

my $self = shift;
my $single_param = $self->single_param();
my($single_param_sjis);

	if($self->selected_encode_is_utf8()){
		$single_param_sjis = Mebius::Encoding::hash_to_utf8($single_param);
	} else {
		$single_param_sjis;
	}

$single_param_sjis;

}

#-----------------------------------------------------------
# query によるエンコード判定
#-----------------------------------------------------------
sub selected_encode_is_utf8{

my $self = shift;
my($param) = Mebius::query_single_param();
my($utf8_flag);

	if($param->{'encode'} =~ /^(utf-?8)$/i){
		$utf8_flag = 1;
	} else {
		0;
	}

$utf8_flag;

}

#-----------------------------------------------------------
# query によるエンコード判定
#-----------------------------------------------------------
sub selected_encode_is_shift_jis{

my $self = shift;
my($param) = Mebius::query_single_param();
my($shift_jis_flag);

	if($param->{'encode'} =~ /^(shift_jis)$/i){
		$shift_jis_flag = 1;
	} else {
		0;
	}

$shift_jis_flag;

}
#-----------------------------------------------------------
# query によるエンコード判定
#-----------------------------------------------------------
sub selected_encode_is_none{

my $self = shift;
my($param) = Mebius::query_single_param();
my($none_flag);

	if($param->{'encode'} eq ""){
		$none_flag = 1;
	} else {
		0;
	}

$none_flag;

}

#-----------------------------------------------------------
# エンコードを指定する input タグ
#-----------------------------------------------------------
sub input_hidden_encode_shift_jis_only{

my $self = shift;
my($input);

	if($self->default_encode_is_shift_jis()){
		$input = $self->input_hidden_enconde_is_shift_jis();
	}

$input;

}


#-----------------------------------------------------------
# エンコードを指定する input タグ
#-----------------------------------------------------------
sub input_hidden_encode{

my $self = shift;
my($input);

	if($self->default_encode_is_shift_jis()){
		$input = $self->input_hidden_enconde_is_shift_jis();
	} else {
		$input = $self->input_hidden_enconde_is_utf8();
	}

$input;

}

#-----------------------------------------------------------
# Shift-JISを出力するデバイスの場合
#-----------------------------------------------------------
sub default_encode_is_shift_jis{

my $device = new Mebius::Device;

my $self = shift;
my($flag);

	if($device->use_device_is_mobile()) {
		$flag = 1;
	} else {
		0;
	}	

$flag;

}

#-----------------------------------------------------------
# エンコードを指定する input タグ ( UTF8 )
#-----------------------------------------------------------
sub input_hidden_enconde_is_utf8{
qq(<input type="hidden" name="encode" value="utf-8">);
}


#-----------------------------------------------------------
#  エンコードを指定する input タグ ( SHIFT_JIS )
#-----------------------------------------------------------
sub input_hidden_enconde_is_shift_jis{
qq(<input type="hidden" name="encode" value="shift_jis">);
}


package Mebius;
use Mebius::Export;
# use utf8;

#-----------------------------------------------------------
# $postbuf を展開
# 返す結果は &Escape していないので注意、そのままデータに書き込まないように
#-----------------------------------------------------------
sub ForeachQuery{

# 宣言
my($type,$query,$exclusion_names) = @_;
#my(@exclusion_name) = $@exclusion_names;
my($return_query,$query_foreach,%exclusion);
my($encoded_query,$natural_query,$hit_query,@query,%natural_query,%encoded_query,%query);

	# 除外する引数をハッシュ化
	foreach(split(/,/,$exclusion_names)){
		$exclusion{$_} = 1;
	}

	# クエリを展開
	foreach(keys %main::in){

		my $name = $_;
		my $value = $main::in{$_};

			# 除外する引数
			if($exclusion{$name}){ next; }

		# ヒットカウンタ
		$hit_query++;

		# クエリをエスケープ
		if($type =~ /Escape-query/){
			($value) = Mebius::escape(undef,$value);
		}

		# ナチュラルクエリを追加
		if($type =~ /Get-natural-query/){
				if($hit_query >=2){
					$natural_query .= "&";
				}
			$natural_query .= qq($name=$value);
			$natural_query{$_} = $value;
		}

		# クエリをエンコード
		my($value_encoded2) = Mebius::Encode(undef,$value);

			# クエリを追加
			if($hit_query >=2){
				$encoded_query .= "&";
			}
		$encoded_query .= qq($name=$value_encoded2);
		$encoded_query{$_} = $value_encoded2;

	}

	# タイプに応じてリターン
	if($type =~ /Get-natural-query/){
		return($natural_query);
	}
	else{
		return($encoded_query);
	}

}

#-----------------------------------------------------------
# クエリを展開して、inout hidden のタグを取得 ( 上の処理と一部重複しているけど、新しい処理を作る )
#-----------------------------------------------------------
sub foreach_query_and_get_input_hidden_tag{

my $use = shift if(ref $_[0] eq "HASH");
my($self);
my($q) = Mebius::query_state();

	# すべてのクエリを展開
	foreach my $name ($q->param()){

		my $value = $q->param($name);

			# 特定のパラメータを除外
			if(ref $use->{'exclusion'} eq "ARRAY"){
				my($exclusion_flag);
					foreach my $exclution (@{$use->{'exclusion'}}){
							if($name eq $exclution){ $exclusion_flag = 1; }
					}
					if($exclusion_flag){ next; }
			}

			# 許可したパラメータだけ展開
			elsif(ref $use->{'limited'} eq "ARRAY"){
				my($limited_flag);
					foreach my $limited (@{$use->{'limited'}}){
							if($name =~ /^$limited$/s){
								$limited_flag = 1;
							}	elsif(Mebius::Search->search_with_wild_card($name,$limited)){
								$limited_flag = 1;
							}
					}
					if(!$limited_flag){ next; }
			}

		$self .= qq(<input type="hidden" name=").e($name).qq(" value=").e($value).qq(">\n);
	}

$self;

}




#-----------------------------------------------------------
# クエリをハッシュリファレンスとして扱う
#-----------------------------------------------------------
sub query_single_param{
Mebius::Query->single_param();
}

#-----------------------------------------------------------
# クエリを覚えておく
#-----------------------------------------------------------
sub query_state{

# Near State （呼び出し） 2.30
my $HereName1 = "query_state";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$StateKey1); }

my $q = new CGI;
#my $q = CGI->new();

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$q); }

$q;

}



1;
