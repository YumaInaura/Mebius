
use strict;
use Mebius::TextShiftJis;
package Mebius::Text;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 数字にカンマを付ける
#-----------------------------------------------------------
sub comma{

# 宣言
my $self = shift;
my $check = shift;

	# カンマを付ける
#$check =~ s/(\d{1,3})(?=(?:\d{3})+(?!\d))/$1,/g;

# リターン
$check;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_for_judge{

my $self = shift;
my $text = shift;

$text =~ s/[\.\s\/\@:;,_]//gm;
$text =~ s/　//gm;

$text;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub number_to_alfabet{

my $self = shift;
my $number = shift;

my $alfabet = $number;

$alfabet =~ tr/[1-9]/[A-Z]/;

$alfabet;

}

#-----------------------------------------------------------
# 空白や特殊記法 ( 改行など ) を一斉に調整
#-----------------------------------------------------------
sub fix_title{

my $self = shift;
my $text = shift;

$text = $self->fix_space($text);
$text = $self->delete_special_marks($text);

$text;

}


#-----------------------------------------------------------
# 余計な空白 ( 文頭・文末・連続 )を削除
#-----------------------------------------------------------
sub fix_space{

my $self = shift;
my $text = shift;

$text =~ s/　/ /g;
$text =~ s/^(\s)+//g;
$text =~ s/^(\s)+$//g;
$text =~ s/\s+/ /g;

$text;

}


#-----------------------------------------------------------
# 記号を削除
#-----------------------------------------------------------
sub delete_marks{

my $self = shift;
my $text_body = shift;

$text_body =~ s/[\/\s\n\r\t\0\-_\*\.,;]//gs;
$text_body =~ s/(　)//gs;

$text_body;

}


#-----------------------------------------------------------
# 改行、タブなど特殊なものを削除する
#-----------------------------------------------------------
sub delete_special_marks{

my $self = shift;
my $text = shift;

$text =~ s/[\n\r\t\0]//g;

$text;


}


#-----------------------------------------------------------
# 文字数を数える ( Byte ではなく )
#-----------------------------------------------------------
sub character_num{

my $self = shift;
my $text = shift;
$text =~ s/[\r\n\s　]//sig;
my $length = length(Encode::decode('utf-8', $text));

$length;

}

#-----------------------------------------------------------
# 文字数を数える ( Byte ではなく )
#-----------------------------------------------------------
sub character_num_with_comma{

my $self = shift;
my $text = shift;

my $character_num = $self->character_num($text);
my $character_num_with_comma = $self->comma($character_num);

$character_num_with_comma;

}


#-----------------------------------------------------------
# 文字数を数える ( Byte ではなく )
#-----------------------------------------------------------
sub character_num_pure{

my $self = shift;
my $text = shift;
my $length = length(Encode::decode('utf-8', $text));

$length;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub character_num_error_message{

my $self = shift;
my $text = shift;
my $min_length = shift;
my $max_length = shift;
my $target_name_for_guide = shift || "内容";
my($error);

my $character_num_short = $self->character_num($text);
my $character_num_long = $self->character_num_pure($text);

	if($character_num_short < $min_length){
		$error = e($target_name_for_guide) . "が短すぎます。".e($min_length).qq(文字以上で送信してください。);
	} elsif($character_num_long > $max_length){
		$error = e($target_name_for_guide) . "が長すぎます。".e($max_length).qq(文字以内で送信してください。);
	}

$error;

}



#-----------------------------------------------------------
# 文字数を数える ( Byte ではなく )
#-----------------------------------------------------------
sub substr_character{

my $self = shift;
my $text = shift;
my $substr_start = shift;
my $substr_end = shift;

$text =~ s/[\r\n]//sig;

	if($substr_start =~ /[^0-9]/){ warn("$substr_start is not numbert."); return(); }
	if($substr_end =~ /[^0-9]/){ warn("$substr_end is not numbert."); return(); }

my $utf8_text = Encode::decode('utf-8', $text);
my $substred_utf8_text = substr($utf8_text,$substr_start,$substr_end);

my $utf8_text_decoded = Encode::encode('utf-8', $substred_utf8_text);

$utf8_text_decoded;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub omit{

my $self = shift;
$self->omit_character(@_);

}

#-----------------------------------------------------------
# 文字数を数える ( Byte ではなく )
#-----------------------------------------------------------
sub omit_character{

my $self = shift;
my $text = shift;
my $substr_length = shift;
my($substred_text);

# 元のテキストの長さを数える
my $charactor_num = $self->character_num($text);

	# 規定の文字数を1文字だけ超えている場合 ( 省略語の文字数を合わせる )
	if($charactor_num > $substr_length){
		$substred_text = $self->substr_character($text,0,$substr_length-1) . "…";
	# 省略しない場合
	} else {
		$substred_text = $text;
	}

$substred_text;

}


#-----------------------------------------------------------
# 全てのアルファベット
#-----------------------------------------------------------
sub all_alfabets_list_for_adjust{

my $self = shift;

my @alfabets = (
['Ａ','A','ａ','a'] , 
['Ｂ','B','ｂ','b'] , 
['Ｃ','C','ｃ','c'] , 
['Ｄ','D','ｄ','d'] , 
['Ｅ','E','ｅ','e'] , 
['Ｆ','F','ｆ','f'] , 
['Ｇ','G','ｇ','g'] , 
['Ｈ','H','ｈ','h'] , 
['Ｉ','I','ｉ','i'] , 
['Ｊ','J','ｊ','j'] , 
['Ｋ','K','ｋ','k'] , 
['Ｌ','L','ｌ','l'] , 
['Ｍ','M','ｍ','m'] , 
['Ｎ','N','ｎ','n'] , 
['Ｏ','O','ｏ','o'] , 
['Ｐ','P','ｐ','p'] , 
['Ｑ','Q','ｑ','q'] , 
['Ｒ','R','ｒ','r'] , 
['Ｓ','S','ｓ','s'] , 
['Ｔ','T','ｔ','t'] , 
['Ｕ','U','ｕ','u'] , 
['Ｖ','V','ｖ','v'] , 
['Ｗ','W','ｗ','w'] , 
['Ｘ','X','ｘ','x'] , 
['Ｙ','Y','ｙ','y'] , 
['Ｚ','Z','ｚ','z'] , 
);

@alfabets;

}


#-----------------------------------------------------------
# すべての数字
#-----------------------------------------------------------
sub all_numbers_list_for_adjust{

my $self = shift;

my @numbers = (

['０','0'] , 
['１','1'] , 
['２','2'] , 
['３','3'] , 
['４','4'] , 
['５','5'] , 
['６','6'] , 
['７','7'] , 
['８','8'] , 
['９','9'] ,
);

@numbers;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_marks_list_for_adjust{

my @marks = (
['！','!'],
['？','?'],
['：',':'],
['；',';'],
['．','.'],
['，',','],
['＿','_'],
['＠','@'],
['＆','&'],
['｜','|'],
['％','%'],
['＞','>'],
['＃','#'],
['＄','$'],
['＜','<'],
['＝','='],
['’',"'"],
['＋','+'],
['＊','*'],
['／','/'],
['｛','{'],
['｝','}'],
['（','('],
['）',')'],
);

@marks;

}


#-----------------------------------------------------------
# 全角文字を半角文字に ( アルファベットと数字、一部の記号 )
#-----------------------------------------------------------
sub fullsize_to_halfsize{

my $self = shift;
my $text = shift;
my(@array);

push @array , $self->all_numbers_list_for_adjust();
push @array , $self->all_alfabets_list_for_adjust();
push @array , $self->all_marks_list_for_adjust();

	foreach my $list (@array){

			if($list->[0] && $list->[1]){
				$text =~ s/$list->[0]/$list->[1]/g;
			}

			if($list->[2] && $list->[3]){
				$text =~ s/$list->[2]/$list->[3]/g;
			}

	}



$text;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub dupulication{

my $self = shift;
my $text1 = shift || return();
my $text2 = shift || return();
my($duplication_flag,$text1_split,$text2_split,$same_hit,$i_text1,$i_text2);
my($text_lines,$max_like_percent);

# 数字や文字羅列を削除する ( 正常に動く？ )
(my $text1_strange_deleted = $text1) =~ s/(^[\w\s\r\n]+|[\w\s\r\n]+$)//ig;
(my $text2_strange_deleted = $text2) =~ s/(^[\w\s\r\n]+|[\w\s\r\n]+$)//ig;

# 判定のための記号削除
(my $text1_space_deleted = $text1) =~ s/\s|\r|\n|　|<br>//ig;
(my $text2_space_deleted = $text2) =~ s/\s|\r|\n|　|<br>//ig;

	# 文章が全く同じ場合
	if($text1_space_deleted eq $text2_space_deleted && length($text1_space_deleted) >= 10 && length($text1_space_deleted) >= 10) {
		$duplication_flag = "他の場所に書き込まれた文章と、内容が同じです。 [1]";
	}

	# 文章が全く同じ場合 ( 英数字を削除後のマッチ )
	elsif($text1_strange_deleted eq $text2_strange_deleted && length($text1_strange_deleted) >= 10 && length($text1_strange_deleted) >= 10) {
		$duplication_flag = "他の場所に書き込まれた文章と、内容が同じです。 [2]";
	}

	# 類似重複チェック
	#elsif (length($text1) >= 2*100 && length($text2) >= 2*100) {
	#		if($text1_space_deleted =~ /$text2_space_deleted/ || $text2_space_deleted =~ /$text1_space_deleted/){
	#			$duplication_flag = "他の場所に書き込まれた文章と、内容が非常に似ています。";
	#		}
	#}

	# １行ずつの類似チェック
	if(!$duplication_flag){

			# 文章その１を展開
			foreach $text1_split (split(/<br>/,$text1)){
					if(length($text1_split) < 5*2){ next; }
				$i_text1++;

					# 文章その２を展開
					foreach $text2_split (split(/<br>/,$text2)){
							if(length($text2_split) < 5*2){ next; }
							if($text1_split eq $text2_split){ $same_hit++; last; }
					}
			}

			# 文章その２の行数を計算
			foreach $text2_split (split(/<br>/,$text2)){
					if(length($text2_split) < 3*2){ next; }
				$i_text2++;
			}

		# 判定
		# 元文章の行数（二つのうちで少ない方）を定義
		$text_lines = $i_text1;
			if($i_text2 <= $text_lines){ $text_lines = $i_text2; }
			# 文章内の一定行数以上が同じである場合
		$max_like_percent = 0.75;
			if($same_hit >= 5 && ($same_hit >= $i_text1 * $max_like_percent)){ $duplication_flag = "line - $same_hit/$i_text1 - type1"; }
			if($same_hit >= 5 && ($same_hit >= $i_text2 * $max_like_percent)){ $duplication_flag = "line - $same_hit/$i_text2 - type2"; }

	}

return($duplication_flag);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub match_shift_jis{

my $self = shift;
my $shift_jis_text = shift;
my $shift_jis_from = shift;
my($match);

my $text = utf8_return($shift_jis_text);
my $from = utf8_return($shift_jis_from);

	if($text =~ /$from/){
		$match = 1;
	}

$match;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub replace_shift_jis{

my $self = shift;
my $shift_jis_text = shift;
my $shift_jis_from = shift;
my $shift_jis_to = shift;

my $text = utf8_return($shift_jis_text);
my $from = utf8_return($shift_jis_from);
my $to = utf8_return($shift_jis_to);

$text =~ s/$from/$to/g;

shift_jis($text);

$text;

}



1;

