
use strict;
package Mebius::Stamp;
use Mebius::Export;

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub init{
{ max_regist_num => 3 };
}

#-----------------------------------------------------------
# スタンプの種類 (ベーシック)
#-----------------------------------------------------------
sub liblary_array{

my $category = shift;
my(@self);

# Near State （呼び出し） 2.30
my $HereName1 = "liblary_array";
my $StateKey1 = "normal";
my($state) = Mebius::State::call_parmanent(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$StateKey1); }

# ベーシック
push(@self,{
	name => "basic" ,
	title => "基本" ,
	author => "ゆうま",
	kind => [
		{ name => "smile2" , title => "笑顔2" },
		{ name => "twinkle1" , title => "キラーン" },
		{ name => "sweat1" , title => "汗" },
		{ name => "cheeks1" , title => "ぽっ" },
		{ name => "sad2" , title => "悲しい" },
		{ name => "crying1" , title => "大泣き" },
		{ name => "shock1" , title => "ショック" },
		{ name => "exclamation1" , title => "驚き" },
		{ name => "question1" , title => "はてな" },
		{ name => "strange1" , title => "変顔" },
		{ name => "strange2" , title => "変顔(ぷーっ)" },
		{ name => "tongue1" , title => "べーっ" },
		{ name => "thinking1" , title => "モクモク" },
		{ name => "discontent1" , title => "不満" },
		{ name => "swet1" , title => "汗" , DenyNewUse => 1 },
		{ name => "kira1" , title => "キラーン" , DenyNewUse => 1 },
		{ name => "smile1" , title => "笑顔1" , DenyNewUse => 1 },
		{ name => "shine1" , title => "キラーン" , DenyNewUse => 1 },
		{ name => "sad1" , title => "悲しい"  , DenyNewUse => 1 },
	]
});

# かえぴょん
push(@self,{
	name => "kaepyon",
	title => "かえぴょん",
	author => "SWAY",
	kind => [
		{ name => "smile1" },
		{ name => "smile2" },
		{ name => "tongue1" },
		{ name => "cheeks1" },
		{ name => "cheeks2" },
		{ name => "love1" },
		{ name => "sing1" },
		{ name => "lamp1" },
		{ name => "question1" },
		{ name => "sleep1" },
		{ name => "thinking1" },
		{ name => "sad1" },
		{ name => "crying1" },
		{ name => "lose1" },
		{ name => "oops1" },
		{ name => "sick1" },
		{ name => "sick2" },
		{ name => "sick3" },
		{ name => "angry1" },
		{ name => "angry2" }
	]
});


# グミ
#push(@self,{
#	name => "gumi",
#	title => "グミ",
#	kind => [
#		{ name => "gumi1" , title => "緑"}
#	]
#});

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::save_parmanent(__PACKAGE__,$HereName1,$StateKey1,\@self); }

\@self;

}


#-----------------------------------------------------------
# スタンプの種類
#-----------------------------------------------------------
sub liblary_hash{

my(%self);

# Near State （呼び出し） 2.30
my $HereName1 = "liblary_hash";
my $StateKey1 = "normal";
my($state) = Mebius::State::call_parmanent(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$StateKey1); }

	# 種類を取得
	my($all_category) = liblary_array();

	# スタンプの種類
	foreach my $category (@$all_category){
			foreach my $kind (@{$category->{'kind'}}){
				#my $kind = ${_}->{'name'};
				$self{$category->{'name'}}{$kind->{'name'}} = $kind;
				#$self{$kind->{'name'}}->{'name'} = $category->{'name'};
				#$self{$kind->{'name'}}->{'directory'} = $category->{'directory'};
			}
	}

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::save_parmanent(__PACKAGE__,$HereName1,$StateKey1,\%self); }

\%self;


}

#-----------------------------------------------------------
# スタンプの自動入力フォーム
#-----------------------------------------------------------
sub form{

my $use = shift if(ref $_[0] eq "HASH");
my($form);
my($liblary_array) = liblary_array();

	# 使用権限の判定
	if(!allow_use_stamp_judge()){ return(); }

# スタンプカテゴリ選択エリア

	# スタンプ展開ボタンを定義
	{
		my($class_switch,$class_switch_hidden);
		my $javascript_inner = qq(vblock('stamp_form_all');vnone('stamp_switch');vinline('stamp_switch_hidden');stamp_select('$liblary_array->[0]->{'name'}');stamp_category_inner(););

			# すぐに展開させる場合
			if($use->{'DefaultOpen'}){
				$form .= qq(<script>window.onload = function(){${javascript_inner};}</script>);
			}

		$form .= qq(<span id="stamp_switch"><a href="#" onclick="vblock('stamp_form_all');vnone('stamp_switch');vinline('stamp_switch_hidden');${javascript_inner}return false;" class="fold">▼スタンプ</a></span>);
		$form .= qq(<span id="stamp_switch_hidden" class="none"><a href="#" onclick="vnone('stamp_form_all','stamp_switch_hidden');vinline('stamp_switch');return false;" class="fold">▲スタンプ</a></span>);
	}

	if($use->{'FromEncoding'} eq "sjis"){
		Mebius::Encoding::utf8_to_sjis($form);
	}

$form;

}

#-----------------------------------------------------------
# スタンプフォームを展開する場所
#-----------------------------------------------------------
sub stamp_list_area{

my $use = shift if(ref $_[0] eq "HASH");
my($self,$option_line);
my($init) = init();
my($my_use_device) = Mebius::my_use_device();
my($stamp_category) = liblary_array();

	my $css_none = qq(none) if(!$use->{'NaturalParts'});

$self .= qq(<div id="stamp_form_all" class="$css_none">);

	foreach my $category (@$stamp_category){
		$self .= qq(<div id="stamp_form_$category->{'name'}" class="flick"></div>);
			# Jquery 設定
			if(flick_judge() || Mebius::alocal_judge()){
				$self .= qq(<script>\$\('#stamp_list_).e($category->{'name'}).qq('\).flickSimple();</script>);
				#lock: true 
			}

	}


# オプションエリア
$option_line .= qq(<div class="right clear" id="stamp_form_option">);
	$option_line .= qq(<span class="guide">);
	if($my_use_device->{'smart_flag'}){
		$option_line .= qq(※1回$init->{'max_regist_num'}個まで);
	} else {
		$option_line .= qq(※スタンプはいちどに $init->{'max_regist_num'}個 まで使えます);
	}
$option_line .= qq(</span>);
$option_line .= qq(<span id="stamp_author"></span>);
$option_line .= qq( 　<a href="javascript:vinline('stamp_switch');vnone('stamp_form_all','stamp_switch_hidden');" class="size90 fold">×閉じる</a>);
$option_line .= qq(</div>);

# スタンプカテゴリ選択ボタン
$self .= qq(<div class="clear" id="stamp_category">);
$self .= qq(</div>);

$self .= $option_line;
$self .= qq(</div>);

	#if(Mebius::alocal_judge()){
	#	$self .= qq(<div><a href="#" onclick="javascript:vblock('stamp_javascript_code');return false;">スタンプ用のJavascriptコードを確認</a></div>);
	#	$self .= qq(<div id="stamp_javascript_code" class="none">);
	#	($self) .= Mebius::escape(undef,select_kind_javascript_code());
	#	($self) .= Mebius::escape(undef,select_category_javascript_code());
	#	$self .= qq(</div>);
	#}

$self .= qq(\n\n);
$self .= qq(<script>\n);
($self) .= select_kind_javascript_code() . "\n\n";
#($self) .= select_category_javascript_code() . "\n\n";
$self .= qq(</script>\n\n);

	if($use->{'FromEncoding'} eq "sjis"){
		Mebius::Encoding::utf8_to_sjis($self);
	}

$self;

}

#-----------------------------------------------------------
# Javascript外部ファイルのコードを動的に生成 (コピペ用) - 種類
#-----------------------------------------------------------
sub select_kind_javascript_code{

my($stamp_category) = liblary_array();
my($self);

# 領域
	# Javascriptの配列を生成
	{
		my($i);

		$self .= qq(var ALL_STAMP = [\n);

			# スタンプのカテゴリを展開
			foreach my $category (@$stamp_category){

				my($i_kind);

					if($i++){ $self .= qq(,); }
					$self .= qq([\n);

					# スタンプの種類を展開
					$self .= qq([\n);
					foreach my $kind (@{$category->{'kind'}}){
							if($kind->{'DenyNewUse'}){ next; }
							if($i_kind++){ $self .= qq(,); }
						#$self .= qq(['$kind->{'name'}','$kind->{'title'}']\n);
						$self .= qq(['$kind->{'name'}']\n);

					}
					$self .= qq(]\n);

				# カテゴリ毎の予備情報
				$self .= qq(,'$category->{'name'}');
				$self .= qq(,'$category->{'title'}');
				$self .= qq(,'$category->{'author'}');

				$self .= qq(]\n);

			}

		$self .= qq(];\n);
	}

$self .= qq(var done_stamp = new Array;\n);
$self .= qq(function stamp_select(SELECT){\n);

$self .= qq(var HTML='';\n);
$self .= qq(var SELECT_ID = 'stamp_form_' + SELECT;\n);



# Javascript

$self .= qq(
for (var i = 0; i < ALL_STAMP.length; i++){

	var CATE = ALL_STAMP[i];
	var CATE_NAME = CATE[1];
	var ID = 'stamp_form_' + CATE_NAME;
	var KINDS = CATE[0];

		if(CATE_NAME === SELECT){

			vblock(ID);

			vinner('stamp_author',CATE[3]);

			HTML += '<ul class="no-point stamp_form" id="stamp_list_'+SELECT+'">';
				for (var i2 = 0; i2 < KINDS.length; i2++){
					var KIND = KINDS[i2];
					var NAME = KIND[0];
					HTML += '<li><a href="#" onclick="atx(\\'comment\\',\\'\\\\n[stamp:'+SELECT+':'+NAME+']\\\\n\\');return false;"><img src="/stamp/'+SELECT+'/'+NAME+'.png"></a></li>';
				}
			HTML += '<\\/ul>';

		} else{
			vnone(ID);
		}


}
);

$self .= qq(if(done_stamp[SELECT]){return;});
$self .= qq(done_stamp[SELECT] = 1;);


# 領域
$self .= qq(vinner(SELECT_ID,HTML););
$self .= qq(});

$self .= qq(function stamp_category_inner(){var HTML = '';for (var i = 0; i < ALL_STAMP.length; i++){var CATE = ALL_STAMP[i];HTML += '<a href="#" onclick="stamp_select(\\''+CATE[1]+'\\');return false;"><img src="/stamp/'+CATE[1]+'/'+CATE[0][0][0]+'.png"></a>';}vinner('stamp_category',HTML);});

$self =~ s/[\n\r\t]//g;
$self .= qq(\n);

# スタンプカテゴリ選択エリア

$self;

}

#-----------------------------------------------------------
# Javascript外部ファイルのコードを動的に生成 (コピペ用) ： カテゴリ
#-----------------------------------------------------------
sub select_category_javascript_code{

my($stamp_category) = liblary_array();
my($self,$code);

# コード
$self .= qq(
function stamp_category_inner(){
var HTML = '';
for (var i = 0; i < ALL_STAMP.length; i++){
var CATE = ALL_STAMP[i];
HTML += '<a href="#" onclick="stamp_select(\\''+CATE[1]+'\\');return false;"><img src="/stamp/'+CATE[1]+'/'+CATE[0][0][0]+'.png"></a>';
}
vinner('stamp_category',HTML);
}
);

$self =~ s/[\t\n\r]//g;

#($self) .= Escape::javascript($code);

$self;

}
#-----------------------------------------------------------
# スタンプタグを削除
#-----------------------------------------------------------
sub erase_code{

my $text = shift;

($text) = effect({ EraseCode => 1 },$text);

$text;

}


#-----------------------------------------------------------
# スタンプタグを削除
#-----------------------------------------------------------
sub erase_invalid_code{

my $text = shift;

	if(allow_use_stamp_judge()){
		($text) = effect({ EraseInvalidCode => 1 },$text);
	} else {
		($text) = effect({ EraseCode => 1 },$text);
	}

$text;

}

#-----------------------------------------------------------
# コードをスタンプ表示に変換
#-----------------------------------------------------------
sub effect{

my $use = shift if(ref $_[0] eq "HASH");
my $text = shift;
my($stamp_num);

$stamp_num += ($text =~ s!(\[stamp(:([0-9a-z]+?))?:([0-9a-z]+?)\])!liblary_judge($use,$1,$3,$4)!eg);

	if($use->{'GetStampNum'}){
		return $stamp_num;
	} else {
		return $text;
	}

}

#-----------------------------------------------------------
# 判定部分
#-----------------------------------------------------------
sub liblary_judge{

my($self,$justy_flag);
my($liblary) = liblary_hash();
my($liblary_array) = liblary_array();
my $use = shift;
my $all_text = shift;
my $category = shift;
my $kind = shift;

	# 指定ディレクトリがない場合はベーシックスタンプとして扱う
	if(!$category){ $category = $liblary_array->[0]->{'name'}; }

	# 汚染チェック
	if($kind =~ /[^0-9a-z]/){ return(); }
	if($category =~ /[^0-9a-z]/){ return(); }

	# このスタンプが存在するかどうかを判定
	if($liblary->{$category}->{$kind}){
		$justy_flag = 1;
	}

	if($use->{'EraseCode'}){
		$self = "";
	} elsif($use->{'EraseInvalidCode'}){
			if($justy_flag && !$liblary->{$kind}->{'DenyNewUse'}){
				$self = $all_text;
			} else { 
				$self = "";
			}
	} elsif($justy_flag){
		my $alt = $liblary->{$kind}->{'title'};
		Mebius::Encoding::utf8_to_sjis($alt);
		$self = qq(<img src="/stamp/).e($category).qq(/).e($kind).qq(.png" class="stamp" alt=").e($alt).qq(">);
	} else {
		$self = $all_text;
	}

$self;

}

#-----------------------------------------------------------
# スタンプを使った投稿かどうかを判定
#-----------------------------------------------------------
sub use_stamp_judge{

my($self);
my $query_name = shift;

my($q) = Mebius::query_state();
my $text = $q->param($query_name);

	if(!$text){ return(); }

my($stamp_num) = effect({ GetStampNum => 1 },$text);

	if($stamp_num >= 1){
		$self = 1;
	}

$self;


}

#-----------------------------------------------------------
# 投稿エラー判定
#-----------------------------------------------------------
sub regist_error{

my $use = shift if(ref $_[0] eq "HASH");
my $query_name = shift;
my($init) = init();
my(@error);

my($q) = Mebius::query_state();
my $text = $q->param($query_name);

my($stamp_num) = effect({ GetStampNum => 1 },$text);

	# エラー
	if($stamp_num > $init->{'max_regist_num'}){
		push(@error,"スタンプの数が多すぎます。(${stamp_num}個 / 3個) ");
	}

	if($use->{'FromEncoding'} eq "sjis"){
			foreach(@error){
				Mebius::Encoding::utf8_to_sjis($_);
			}
	}

\@error;

}

#-----------------------------------------------------------
# スタンプを使う権限を判定
#-----------------------------------------------------------
sub allow_use_stamp_judge{

my($my_account) = Mebius::my_account();
my($self);

	if($my_account->{'login_flag'}){
		$self = 1;
	} else {
		$self = 1;
	}

$self;

}

#-----------------------------------------------------------
# フリックさせるかどうかを判定
#-----------------------------------------------------------
sub flick_judge{

my($my_use_device) = Mebius::my_use_device();

	if($my_use_device->{'smart_flag'}){
		1;
	}	else {
		0;
	}

}

1;
