
use strict;
package Mebius::Search;
use Mebius::Export;


#-----------------------------------------------------------
# 改行
#-----------------------------------------------------------
sub high_light_include_br_tag{

my $text = shift;
my $search_keyword_all = shift;
my $use = shift if(ref $_[0] eq "HASH");
my %relay_use = %$use;
my($return_text,$hit,%hit_kind_all);

	# 本文の長さ上限
	if(length $text > 10000 || $text eq ""){ return(); }

# オプションを定義
$relay_use{'OR'} = 1;

	# 改行タグごとに展開する
	foreach my $splited_text (split /(<br>)/ , $text) {

		my($high_lighted_text,$hit_splited,$hit_kind) = Mebius::Search::high_light($splited_text,$search_keyword_all,\%relay_use);
		%hit_kind_all = (%hit_kind_all,%{$hit_kind}) if(ref $hit_kind eq "HASH");

			# ヒットした行がある場合は、ヒットカウンタを増やす
			if($high_lighted_text){
				$return_text .= $high_lighted_text;
				$hit += $hit_splited;
			} else {
				$return_text .= $splited_text;
			}
		$return_text .= qq(<br>);
	}

my $hit_kind_num = keys %hit_kind_all;

$return_text,$hit_kind_num;

}

#-----------------------------------------------------------
# キーワードをハイライトする
#-----------------------------------------------------------
sub high_light{

my $text = shift;
my $search_keyword_all = shift;
my $use = shift if(ref $_[0] eq "HASH");
my(@search_keyword,%hit_kind,$i_keyword);

	# 本文の長さ上限
	if(length $text > 10000 || $text eq ""){ return(); }

	if($search_keyword_all eq ""){
		return();
	}

	# 入力が SHIFT_JIS の場合
	if($use->{'SJIS'}){
		utf8($text);
		utf8($search_keyword_all);
	}

# タグを削除
$text =~ s/<.+?>//gs;

	# スペースごとにキーワードを分解する
	foreach my $search_keyword (split(/\s|　/,$search_keyword_all)){

		$i_keyword++;

			# 同じキーワードが二回以上検索されている場合は処理しない
			if($hit_kind{$search_keyword}){ next; }

			# 検索キーワードの長さの上限
			if(length $search_keyword > 100){ next; }

			# 検索キーワードの個数の上限
			if($use->{'max_keyword_num'} && $i_keyword > $use->{'max_keyword_num'}){ last; }

		my($adjusted_search_keyword) = all_adjust_search_keyword($search_keyword);

			# あらかじめ検索をおこなっておき、検索語ごとのHIT数を数える
			if($text =~ /($adjusted_search_keyword)/s){
				$hit_kind{$search_keyword} = 1;
				push @search_keyword , $adjusted_search_keyword;
			} else {
				# AND 検索の場合、条件を成立させるため、毎回 HIT を判定する。一回でもHITしなかった場合はすぐ return する
				if(!$use->{'OR'}){ return(); }
			}

	}

# さらに検索語全体を検索式の形にして、ハイライトをおこなう (  )
my $search_keyword_joined = join "|" , @search_keyword;
my $changed_num += ($text =~ s!($search_keyword_joined)!<strong class="hit">$1</strong>!gs) if $search_keyword_joined;
my $hit_num = keys %hit_kind;

	if($use->{'SJIS'}){
		shift_jis($text);
	}

	if($hit_num >= 1){
		return $text,$hit_num,\%hit_kind;
	} else {
		return();
	}

}


#-----------------------------------------------------------
# 日本語の調整
#-----------------------------------------------------------
sub adjust_japanese_words{

my($text) = @_;
my $text_obj = new Mebius::Text;

my @init = (

['が','ガ','ｶﾞ'] , 
['ぎ','ギ','ｷﾞ'] , 
['ぐ','グ','ｸﾞ'] , 
['げ','ゲ','ｹﾞ'] , 
['ご','ゴ','ｺﾞ'] , 
['ざ','ザ','ｻﾞ'] , 
['じ','ジ','ｼﾞ'] , 
['ず','ズ','ｽﾞ'] , 
['ぜ','ゼ','ｾﾞ'] , 
['ぞ','ゾ','ｿﾞ'] , 
['だ','ダ','ﾀﾞ'] , 
['ぢ','ヂ','ﾁﾞ'] , 
['づ','ヅ','ﾂﾞ'] , 
['で','デ','ﾃﾞ'] , 
['ど','ド','ﾄﾞ'] , 
['ば','バ','ﾊﾞ'] , 
['び','ビ','ﾋﾞ'] , 
['ぶ','ブ','ﾌﾞ'] , 
['べ','ベ','ﾍﾞ'] , 
['ぼ','ボ','ﾎﾞ'] , 
['ぱ','パ','ﾊﾟ'] , 
['ぴ','ピ','ﾋﾟ'] , 
['ぷ','プ','ﾌﾟ'] , 
['ぺ','ペ','ﾍﾟ'] , 
['ぽ','ポ','ﾎﾟ'] , 

['あ','ア','ｱ'] , 
['い','イ','ｲ'] , 
['う','ウ','ｳ'] , 
['え','エ','ｴ'] , 
['お','オ','ｵ'] , 
['か','カ','ｶ'] , 
['き','キ','ｷ'] , 
['く','ク','ｸ'] , 
['け','ケ','ｹ'] , 
['こ','コ','ｺ'] , 
['さ','サ','ｻ'] , 
['し','シ','ｼ'] , 
['す','ス','ｽ'] , 
['せ','セ','ｾ'] , 
['そ','ソ','ｿ'] , 
['た','タ','ﾀ'] , 
['ち','チ','ﾁ'] , 
['つ','ツ','ﾂ'] , 
['て','テ','ﾃ'] , 
['と','ト','ﾄ'] , 
['な','ナ','ﾅ'] , 
['に','ニ','ﾆ'] , 
['ぬ','ヌ','ﾇ'] , 
['ね','ネ','ﾈ'] , 
['の','ノ','ﾉ'] , 
['は','ハ','ﾊ'] , 
['ひ','ヒ','ﾋ'] , 
['ふ','フ','ﾌ'] , 
['へ','ヘ','ﾍ'] , 
['ほ','ホ','ﾎ'] , 
['ま','マ','ﾏ'] , 
['み','ミ','ﾐ'] , 
['む','ム','ﾑ'] , 
['め','メ','ﾒ'] , 
['も','モ','ﾓ'] , 
['や','ヤ','ﾔ'] , 
['ゆ','ユ','ﾕ'] , 
['よ','ヨ','ﾖ'] , 
['ら','ラ','ﾗ'] , 
['り','リ','ﾘ'] , 
['る','ル','ﾙ'] , 
['れ','レ','ﾚ'] , 
['ろ','ロ','ﾛ'] , 
['わ','ワ','ﾜ'] , 
['を','ヲ','ｦ'] , 
['ん','ン','ﾝ'] , 

['ゃ','ャ'] , 
['ゅ','ュ'] , 
['ょ','ョ'] , 
['ぁ','ァ'] , 
['ぃ','ィ'] , 
['ぅ','ゥ'] , 
['ぇ','ェ'] , 
['ぉ','ォ'] , 
['っ','ッ'] , 
['ゎ','ヮ'] , 


['-','ー','～'] , 

);

push @init , $text_obj->all_alfabets_list_for_adjust();
push @init , $text_obj->all_numbers_list_for_adjust();

	# 検索分を生成する
	foreach ( @init ){
		my $or_search_keyword = join "|", @{$_};
		$text =~ s/($or_search_keyword)/\($or_search_keyword\)/g; # 後方のカッコは式ではなく、単なるテキストとしてのカッコ
	}

$text;

}

#-----------------------------------------------------------
# 検索語中の特殊文字をエスケープする
#-----------------------------------------------------------
sub invalidate_special_charactor{

my $search_keyword = shift;

$search_keyword =~ s/([\$\*\+\.\?\{\}\^\$\|\(\)\[\]\'\`])/\\$1/g;
$search_keyword =~ s/\\([a-zA-Z0-9])//g;

$search_keyword;

}

#-----------------------------------------------------------
# 検索キーワードの調整 ( すべての処理を一斉に )
#-----------------------------------------------------------
sub all_adjust_search_keyword{

my($search_keyword) = @_;

	if($search_keyword eq ""){ return(); }

# Near State （呼び出し） 2.30
my $HereName1 = "all_adjust_search_keyword";
my $StateKey1 = "$search_keyword";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

# ユーザーが入力した特殊語を無効化
my($invalidated_search_keyword) = invalidate_special_charactor($search_keyword);

# 検索語を (あ|ア|ｱ) のような検索式に変換する
my($search_keyword_adjusted) = adjust_japanese_words($invalidated_search_keyword);

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$search_keyword_adjusted); }

$search_keyword_adjusted;

}


#-----------------------------------------------------------
# オブジェクト関連付け ( 未使用 )
#-----------------------------------------------------------
sub new{
my $class = shift;
bless {},$class;
}

#-----------------------------------------------------------
# ワイルドカード検索
#-----------------------------------------------------------
sub search_with_wild_card{

my $self = shift;
my $text = shift;
my $keyword = shift;
my($hit);

	if($keyword !~ /\*/s){
		return();
	} else {
		$keyword =~ s/\*/(.*)/sg;
	}

	if($text =~ /$keyword/s){
		$hit = 1;
	}

$hit;

}

1;

