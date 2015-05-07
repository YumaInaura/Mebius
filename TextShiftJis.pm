

use strict;
package Mebius;

#-----------------------------------------------------------
# スペースなどを削除
#-----------------------------------------------------------
sub delete_all_space{

my($self) = @_;

$self =~ s/( |　|\0|\s|\n|\r)//ig;

$self;

}

#-----------------------------------------------------------
# 文字数計算
#-----------------------------------------------------------
sub GetLength{

# 宣言
my($type,$text) = @_;
my($length);

	$text =~ s/<br>//g;

	$length = int(length($text)/2);

# リターン
return($length);

}

package Mebius::Text;


#-----------------------------------------------------------
# スペースの除去
#-----------------------------------------------------------
sub DeleteSpace{

my($type,$text) = @_;

$text =~ s/(★|☆|\s|　|<br>)//g;

return($text);

}


#-----------------------------------------------------------
# 文章の類似度を判定 ( １行 )
#-----------------------------------------------------------
sub SimilarJudge{

# 宣言
my($type,$text,$keyword) = @_;
my($hit_point);

# キーワードを定義
my $judge_text = $text;
my $judge_keyword = $keyword;

# shift_jisの文字列をeucに変換
#$judge_text = &jcode::euc($judge_text, 'sjis');
#$judge_keyword = &jcode::euc($judge_keyword, 'sjis');

# キーワード中の大文字を小文字に
($judge_text) = Mebius::Text::KeywordAdjust(undef,$judge_text);
($judge_keyword) = Mebius::Text::KeywordAdjust(undef,$judge_keyword);

	# ローカル用の変換チェック
	#if($main::alocal_mode && $judge_text =~ /男子/){ main::error("$judge_text / $judge_keyword"); }

# テキスト/キーワードが存在しない場合はリターン
if($judge_text eq ""){ return(); }
if($judge_keyword eq ""){ return(); }

# 単純検索でポイントを増やす
if($judge_text =~ /\Q$judge_keyword\E/i){ $hit_point += 15; }
if($judge_keyword =~ /\Q$judge_text\E/i){ $hit_point += 5; }

	# 除外するキーワード
	if($type =~ /Cut-keyword/){
		$judge_text =~ 		s/(について|掲示板|総合|スレ|好きな|です)//g;
		$judge_keyword =~	s/(について|掲示板|総合|スレ|好きな|です)//g;
	}

	# 類似判定を行わない場合
	if($type =~ /Strict-search/){ return($hit_point); }

# 判定する最小バイト数
my $min_length = 4;
if(length($judge_text) < $min_length || length($judge_keyword) < $min_length){ return($hit_point); }

	# キーワードを展開(正)
	for($min_length .. length($judge_keyword)){
		my $keyword2 = substr($judge_keyword,$_-$min_length,$_);
			if($keyword2 && $judge_text =~ /\Q$keyword2\E/){
				$hit_point++;
			}
	}

	# キーワードを展開(逆)
	for($min_length .. length($judge_text)){
		my $text2 = substr($judge_text,$_-$min_length,$_);
			if($text2 && $judge_keyword =~ /\Q$text2\E/){
				$hit_point++;
			}
	}

return($hit_point);

}

#-----------------------------------------------------------
# キーワード検索用の共通キーワード整形
#-----------------------------------------------------------
sub KeywordAdjust{

# 宣言
my($type,$text) = @_;

($text) = Mebius::Number(undef,$text);
($text) = Mebius::Text::Alfabet("All-to-half",$text);
($text) = Mebius::Text::HiraKanaAdjust(undef,$text);
$text = lc $text;

return($text);

}

package Mebius::Text;

#-----------------------------------------------------------
# タイトルをスマフォ対応に
#-----------------------------------------------------------
sub SmartTitle{

# 宣言
my($subject) = @_;

# 置き換え
$subject =~ s/^(\s|　)+//g;
$subject =~ s/(\s|　)+$//g;

return($subject);

}


#-----------------------------------------------------------
# 行頭の改行を削除
#-----------------------------------------------------------
sub DeleteHeadSpace{

# 宣言
my($type,$text) = @_;
my($return_text,$text_foreach);

	# １行ずつ展開
	foreach $text_foreach (split/<br$main::xclose>/,$text,-1){

			# 余計な全角スペースを削除
			$text_foreach =~ s/\s+/ /g;
			$text_foreach =~ s/^(　|\s){2,}/　/g;
			$text_foreach =~ s/(　|\s){2,}/　/g;
			$return_text .= qq($text_foreach<br$main::xclose>);
	}

return($return_text);


}


#-----------------------------------------------------------
# 全角文字を半角文字に
#-----------------------------------------------------------
sub OneByte{

# 宣言
my($type,$text) = @_;

($text) = Mebius::Number(undef,$text);
($text) = Mebius::Text::Alfabet("All-to-half",$text);

return($text);


}

#-----------------------------------------------------------
# 全角カナ/半角カナ/ひらがなを共通化
#-----------------------------------------------------------
sub HiraKanaAdjust{

# 宣言
my($type,$text) = @_;

# ひらがなからカタカナへ
$text =~ s/あ/ア/g;
$text =~ s/い/イ/g;
$text =~ s/う/ウ/g;
$text =~ s/え/エ/g;
$text =~ s/お/オ/g;
$text =~ s/か/カ/g;
$text =~ s/き/キ/g;
$text =~ s/く/ク/g;
$text =~ s/け/ケ/g;
$text =~ s/こ/コ/g;
$text =~ s/さ/サ/g;
$text =~ s/し/シ/g;
$text =~ s/す/ス/g;
$text =~ s/せ/セ/g;
$text =~ s/そ/ソ\/g;
$text =~ s/た/タ/g;
$text =~ s/ち/チ/g;
$text =~ s/つ/ツ/g;
$text =~ s/て/テ/g;
$text =~ s/と/ト/g;
$text =~ s/な/ナ/g;
$text =~ s/に/ニ/g;
$text =~ s/ぬ/ヌ/g;
$text =~ s/ね/ネ/g;
$text =~ s/の/ノ/g;
$text =~ s/は/ハ/g;
$text =~ s/ひ/ヒ/g;
$text =~ s/ふ/フ/g;
$text =~ s/へ/ヘ/g;
$text =~ s/ほ/ホ/g;
$text =~ s/ま/マ/g;
$text =~ s/み/ミ/g;
$text =~ s/む/ム/g;
$text =~ s/め/メ/g;
$text =~ s/も/モ/g;
$text =~ s/や/ヤ/g;
$text =~ s/ゆ/ユ/g;
$text =~ s/よ/ヨ/g;
$text =~ s/ら/ラ/g;
$text =~ s/り/リ/g;
$text =~ s/る/ル/g;
$text =~ s/れ/レ/g;
$text =~ s/ろ/ロ/g;
$text =~ s/わ/ワ/g;
$text =~ s/を/ヲ/g;
$text =~ s/ん/ン/g;
$text =~ s/が/ガ/g;
$text =~ s/ぎ/ギ/g;
$text =~ s/ぐ/グ/g;
$text =~ s/げ/ゲ/g;
$text =~ s/ご/ゴ/g;
$text =~ s/ざ/ザ/g;
$text =~ s/じ/ジ/g;
$text =~ s/ず/ズ/g;
$text =~ s/ぜ/ゼ/g;
$text =~ s/ぞ/ゾ/g;
$text =~ s/だ/ダ/g;
$text =~ s/ぢ/ヂ/g;
$text =~ s/づ/ヅ/g;
$text =~ s/で/デ/g;
$text =~ s/ど/ド/g;
$text =~ s/ば/バ/g;
$text =~ s/び/ビ/g;
$text =~ s/ぶ/ブ/g;
$text =~ s/べ/ベ/g;
$text =~ s/ぼ/ボ/g;
$text =~ s/ぱ/パ/g;
$text =~ s/ぴ/ピ/g;
$text =~ s/ぷ/プ/g;
$text =~ s/ぺ/ペ/g;
$text =~ s/ぽ/ポ/g;
$text =~ s/ゃ/ャ/g;
$text =~ s/ゅ/ュ/g;
$text =~ s/ょ/ョ/g;
$text =~ s/ぁ/ァ/g;
$text =~ s/ぃ/ィ/g;
$text =~ s/ぅ/ゥ/g;
$text =~ s/ぇ/ェ/g;
$text =~ s/ぉ/ォ/g;
$text =~ s/っ/ッ/g;
$text =~ s/ゎ/ヮ/g;

# 半角カナから全角カナへ
$text =~ s/ｶﾞ/ガ/g;
$text =~ s/ｷﾞ/ギ/g;
$text =~ s/ｸﾞ/グ/g;
$text =~ s/ｹﾞ/ゲ/g;
$text =~ s/ｺﾞ/ゴ/g;
$text =~ s/ｻﾞ/ザ/g;
$text =~ s/ｼﾞ/ジ/g;
$text =~ s/ｽﾞ/ズ/g;
$text =~ s/ｾﾞ/ゼ/g;
$text =~ s/ｿﾞ/ゾ/g;
$text =~ s/ﾀﾞ/ダ/g;
$text =~ s/ﾁﾞ/ヂ/g;
$text =~ s/ﾂﾞ/ヅ/g;
$text =~ s/ﾃﾞ/デ/g;
$text =~ s/ﾄﾞ/ド/g;
$text =~ s/ﾊﾞ/バ/g;
$text =~ s/ﾋﾞ/ビ/g;
$text =~ s/ﾌﾞ/ブ/g;
$text =~ s/ﾍﾞ/ベ/g;
$text =~ s/ﾎﾞ/ボ/g;
$text =~ s/ﾊﾟ/パ/g;
$text =~ s/ﾋﾟ/ピ/g;
$text =~ s/ﾌﾟ/プ/g;
$text =~ s/ﾍﾟ/ペ/g;
$text =~ s/ﾎﾟ/ポ/g;


$text =~ s/ｱ/ア/g;
$text =~ s/ｲ/イ/g;
$text =~ s/ｳ/ウ/g;
$text =~ s/ｴ/エ/g;
$text =~ s/ｵ/オ/g;
$text =~ s/ｶ/カ/g;
$text =~ s/ｷ/キ/g;
$text =~ s/ｸ/ク/g;
$text =~ s/ｹ/ケ/g;
$text =~ s/ｺ/コ/g;
$text =~ s/ｻ/サ/g;
$text =~ s/ｼ/シ/g;
$text =~ s/ｽ/ス/g;
$text =~ s/ｾ/セ/g;
$text =~ s/ｿ/ソ\/g;
$text =~ s/ﾀ/タ/g;
$text =~ s/ﾁ/チ/g;
$text =~ s/ﾂ/ツ/g;
$text =~ s/ﾃ/テ/g;
$text =~ s/ﾄ/ト/g;
$text =~ s/ﾅ/ナ/g;
$text =~ s/ﾆ/ニ/g;
$text =~ s/ﾇ/ヌ/g;
$text =~ s/ﾈ/ネ/g;
$text =~ s/ﾉ/ノ/g;
$text =~ s/ﾊ/ハ/g;
$text =~ s/ﾋ/ヒ/g;
$text =~ s/ﾌ/フ/g;
$text =~ s/ﾍ/ヘ/g;
$text =~ s/ﾎ/ホ/g;
$text =~ s/ﾏ/マ/g;
$text =~ s/ﾐ/ミ/g;
$text =~ s/ﾑ/ム/g;
$text =~ s/ﾒ/メ/g;
$text =~ s/ﾓ/モ/g;
$text =~ s/ﾔ/ヤ/g;
$text =~ s/ﾕ/ユ/g;
$text =~ s/ﾖ/ヨ/g;
$text =~ s/ﾗ/ラ/g;
$text =~ s/ﾘ/リ/g;
$text =~ s/ﾙ/ル/g;
$text =~ s/ﾚ/レ/g;
$text =~ s/ﾛ/ロ/g;
$text =~ s/ﾜ/ワ/g;
$text =~ s/ｦ/ヲ/g;
$text =~ s/ﾝ/ン/g;
$text =~ s/ｬ/ャ/g;
$text =~ s/ｭ/ュ/g;
$text =~ s/ｮ/ョ/g;
$text =~ s/ｧ/ァ/g;
$text =~ s/ｨ/ィ/g;
$text =~ s/ｩ/ゥ/g;
$text =~ s/ｪ/ェ/g;
$text =~ s/ｫ/ォ/g;
$text =~ s/ｯ/ッ/g;

# 記号の変換
$text =~ s/！/!/g;
$text =~ s/？/\?/g;
$text =~ s/　/\s/g;
$text =~ s/\Qー\E/-/g;

# リターン
return($text);

}

package Mebius;

#-----------------------------------------------------------
# 全角数字を半角数字に
#-----------------------------------------------------------
sub Number{

my($type,$check) = @_;

$check =~ s/１/1/g;
$check =~ s/２/2/g;
$check =~ s/３/3/g;
$check =~ s/４/4/g;
$check =~ s/５/5/g;
$check =~ s/６/6/g;
$check =~ s/７/7/g;
$check =~ s/８/8/g;
$check =~ s/９/9/g;
$check =~ s/０/0/g;

$check =~ s/一/1/g;
$check =~ s/ニ/2/g;
$check =~ s/三/3/g;
$check =~ s/四/4/g;
$check =~ s/五/5/g;
$check =~ s/六/6/g;
$check =~ s/七/7/g;
$check =~ s/八/8/g;
$check =~ s/九/9/g;
$check =~ s/十\/10/g;
$check =~ s/百/100/g;
$check =~ s/千/1000/g;
$check =~ s/万/10000/g;

return($check);

}

#-----------------------------------------------------------
# 数字にカンマを付ける
#-----------------------------------------------------------
sub Comma{

# 宣言
my($type,@check) = @_;

	# カンマを付ける
	foreach(@check){
		while($_ =~ s/(.*\d)(\d\d\d)/$1,$2/){};
	}

# リターン
return(@check);

}

#-----------------------------------------------------------
# 日本式カンマ
#-----------------------------------------------------------
sub japanese_comma{

my @comma = Mebius::MultiComma({ Language => "Japanese" },\@_);

@comma;

}
#-----------------------------------------------------------
# 桁をつける
#-----------------------------------------------------------
sub MultiComma{

# 宣言
my($use,$check) = @_;
my(@comma,$foreach,%language_reed,$language_flag);

	# 数字を展開
	if($use->{'Language'} eq "Japanese"){
		$language_reed{'4'} = "万";
		$language_reed{'8'} = "億";
		$language_reed{'12'} = "兆";
		$language_reed{'16'} = "京";

			# デコードの場合
			if($use->{'TypeDecodeComma'}){
					$language_reed{'3'} = '千';
					$language_reed{'2'} = '百';
			}

		$language_flag = 1;
	}

	# カンマをデコードする
	if($use->{'TypeDecodeComma'}){

			# カンマ
			if($language_flag){

					# すべての配列を展開
					foreach $foreach (@$check){

						# 局所化
						my($point,$reed_foreach);
						my $number_foreach = $foreach;

						# 普通のカンマを削除
						$number_foreach =~ s/,//g;

							# すべての単位を展開
							foreach $reed_foreach (keys %language_reed){
								
									# 「数字＋桁」を「数字」に変換 ( ハッシュの key と value を逆向きに処理しているので注意 )
									while($number_foreach =~ s/((\-)?([0-9]+)(\.[0-9]+)?)$language_reed{$reed_foreach}//){
										$point += ($1)*(10**$reed_foreach);
									}

							}

							# 残った数字
							if($number_foreach =~ s/((\-)?([0-9]+)(\.[0-9]+)?)//){ $point += $1; }

						push(@comma,$point);

					}


			}

		return(@comma);

	}

	# ●カンマを付ける
	else{

			# 言語カンマにする場合
			if($language_flag){

					# すべての配列を展開
					foreach (@$check){

						# 局所化
						my($i,$line,$split,$tail,$minus);

						# カンマを削除
						( my $foreach = $_) =~ s/,//g;

							# 数字の正規チェック
							if($foreach =~ /^(\-)?([0-9]+)(\.([0-9]+))?$/){
								$minus = $1;
								$foreach = $2;
								$tail = $3;
							}
							# 正規でない場合は処理しない ( next だけすると return @array の値がズレてしまうので、ここでちゃんと push @array しておく )
							else{
								push(@comma,undef);
								next;
							}

						# 一文字ずつ数字を区切る
						my(@split) = split(//,$foreach);

								# 一文字ずつ区切った数字を展開 ( reverse しない方がうまくいきそう？ )
								foreach $split (@split){

										$i++;
										$line .= $split;

										# 現在の桁数
										my $reed = @split - $i;

											if($language_reed{$reed}){ $line .= qq($language_reed{$reed}); }

								}

								# 小数点をもとに戻す
								if($tail){ $line .= "$tail"; }

								# マイナスを元に戻す
								if($minus){ $line = "$minus$line"; }

							# 整形済みのカンマ
							push(@comma,$line);
					}

			}

			# 世界共通カンマ
			else{

					# カンマを付ける
					foreach(@$check){
						while($_ =~ s/(.*\d)(\d\d\d)/$1,$2/){};
						push(@comma,$_);
					}

			}

		return(@comma);

	}

}


#-----------------------------------------------------------
# 整数にする
#-----------------------------------------------------------
sub IntNumber{

# 宣言
my($type,@numbers) = @_;
my(@inited_numbers);

	# 数字を展開
	foreach(@numbers){
		my($inited_number);
			# 数値がカラの場合
			if(!$_){
				push(@inited_numbers,0);
			}
			# 数値の場合
			else{
				$inited_number = int $_;
				push(@inited_numbers,$inited_number);
			}
	}

return(@inited_numbers);

}


#-----------------------------------------------------------
# カラの値にゼロを代入する
#-----------------------------------------------------------
sub DefineNumber{

# 宣言
my($type,@numbers) = @_;
my(@inited_numbers);

	# 数字を展開
	foreach(@numbers){
			# 数値がカラの場合
			if($_ =~ /^([0-9]+)(\.[0-9]+)?$/){
				push(@inited_numbers,$_);
			}
			# 数値の場合
			else{
				push(@inited_numbers,0);
			}
	}

return(@inited_numbers);

}


package Mebius::Text;

#-----------------------------------------------------------
# アルファベットを全角←→半角変換
#-----------------------------------------------------------
sub Alfabet{

# 宣言
my($type,$check) = @_;

	# 全角から半角へ
	if($type =~ /All-to-half/){

		# 大文字
		$check =~ s/Ａ/A/g;
		$check =~ s/Ｂ/B/g;
		$check =~ s/Ｃ/C/g;
		$check =~ s/Ｄ/D/g;
		$check =~ s/Ｅ/E/g;
		$check =~ s/Ｆ/F/g;
		$check =~ s/Ｇ/G/g;
		$check =~ s/Ｈ/H/g;
		$check =~ s/Ｉ/I/g;
		$check =~ s/Ｊ/J/g;
		$check =~ s/Ｋ/K/g;
		$check =~ s/Ｌ/L/g;
		$check =~ s/Ｍ/M/g;
		$check =~ s/Ｎ/N/g;
		$check =~ s/Ｏ/O/g;
		$check =~ s/Ｐ/P/g;
		$check =~ s/Ｑ/Q/g;
		$check =~ s/Ｒ/R/g;
		$check =~ s/Ｓ/S/g;
		$check =~ s/Ｔ/T/g;
		$check =~ s/Ｕ/U/g;
		$check =~ s/Ｖ/V/g;
		$check =~ s/Ｗ/W/g;
		$check =~ s/Ｘ/X/g;
		$check =~ s/Ｙ/Y/g;
		$check =~ s/Ｚ/Z/g;

		# 小文字
		$check =~ s/ａ/a/g;
		$check =~ s/ｂ/b/g;
		$check =~ s/ｃ/c/g;
		$check =~ s/ｄ/d/g;
		$check =~ s/ｅ/e/g;
		$check =~ s/ｆ/f/g;
		$check =~ s/ｇ/g/g;
		$check =~ s/ｈ/h/g;
		$check =~ s/ｉ/i/g;
		$check =~ s/ｊ/j/g;
		$check =~ s/ｋ/k/g;
		$check =~ s/ｌ/l/g;
		$check =~ s/ｍ/m/g;
		$check =~ s/ｎ/n/g;
		$check =~ s/ｏ/o/g;
		$check =~ s/ｐ/p/g;
		$check =~ s/ｑ/q/g;
		$check =~ s/ｒ/r/g;
		$check =~ s/ｓ/s/g;
		$check =~ s/ｔ/t/g;
		$check =~ s/ｕ/u/g;
		$check =~ s/ｖ/v/g;
		$check =~ s/ｗ/w/g;
		$check =~ s/ｘ/x/g;
		$check =~ s/ｙ/y/g;
		$check =~ s/ｚ/z/g;

		# 数字
		($check) = Mebius::Number(undef,$check);

	}

# リターン
return($check);

}


#-----------------------------------------------------------
# 不樽の文章の重複、類似性をチェック
#-----------------------------------------------------------
sub Duplication{

# 宣言
my($type,$text1,$text2) = @_;
my($duplication_flag,$text1_split,$text2_split,$same_hit,$i_text1,$i_text2);
my($text_lines,$max_like_percent);

	# 中身がない場合
	if($text1 eq ""){ return(); }
	if($text2 eq ""){ return(); }

# 数字や文字羅列を削除する ( 正常に動く？ )
(my $text1_strange_deleted = $text1) =~ s/(^[\w\s]+|[\w\s]+$)//ig;
(my $text2_strange_deleted = $text2) =~ s/(^[\w\s]+|[\w\s]+$)//ig;

# 判定のための記号削除
(my $text1_space_deleted = $text1) =~ s/\s|　|<br>//ig;
(my $text2_space_deleted = $text2) =~ s/\s|　|<br>//ig;

	# 文章が全く同じ場合
	if($text1_space_deleted eq $text2_space_deleted) {
		$duplication_flag = "same";
	}

	# 文章が全く同じ場合 ( 英数字を削除後のマッチ )
	elsif($text1_strange_deleted eq $text2_strange_deleted && length($text1_strange_deleted) >= 10 && length($text1_strange_deleted) >= 10) {
		$duplication_flag = "same";
		# CCC
		Mebius::AccessLog(undef,"Dupulication-error-strange-words-deleted-after");
	}

	# 類似重複チェック
	elsif (length($text1) >= 2*100 && length($text2) >= 2*100) {
			if($text1_space_deleted =~ /\Q$text2_space_deleted\E/ || $text2_space_deleted =~ /\Q$text1_space_deleted\E/){
				$duplication_flag = "like";
			}
	}

	# １行ずつの類似チェック
	if(!$duplication_flag && $type !~ /Not-line-check/){

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
			if($type =~ /Light-judge/){ $max_like_percent = 0.85; }
			else{ $max_like_percent = 0.75; }
			if($same_hit >= 5 && ($same_hit >= $i_text1 * $max_like_percent)){ $duplication_flag = "line - $same_hit/$i_text1 - type1"; }
			if($same_hit >= 5 && ($same_hit >= $i_text2 * $max_like_percent)){ $duplication_flag = "line - $same_hit/$i_text2 - type2"; }
			# 無条件に、一定行数以上が同じである場合 (テンプレが使われている場合、完全に弾かれてしまう現象アリ)
			#if($same_hit >= 10){ $duplication_flag = "line - $same_hit/$text_lines"; }
	}

return($duplication_flag);

}

package Mebius;

#-----------------------------------------------------------
# IDを分割
#-----------------------------------------------------------
sub SplitEncid{

my($type,$encid) = @_;

# リターン
if($encid =~ /[^\w\-\.\/\=]/){ return(); }

	# 分割
	if($encid =~ /^(([a-zA-Z0-9]+)?(\-|\=))?([a-zA-Z0-9\.\/]+)((_)([a-zA-Z0-9\.\/]+))?$/){
		my $device_encid = $2;
		my $pure_encid = $4;
		my $option_encid = $7; 
		return($device_encid,$pure_encid,$option_encid);

	}

return();

}


#-----------------------------------------------------------
# 危険なタグを禁止
#-----------------------------------------------------------
sub DangerTag{

# 宣言
my($type,$text) = @_;
my($danger_flag);

#img|

	# タグ判定
	if($text =~ /
				<(\s*)
				(script|iframe|html|body|head|input|xmp|plaintext|meta|isindex|form|object|title|comment|applet|noembed|listing
				|noframes|noscript|style|marquee|textarea)
				/ix){
		$danger_flag = $2;
	}

	# タグ類判定
	if($text =~ /(onload)/i){
		$danger_flag = "埋め込み";
	}


	# そのままエラーにする場合
	if($type =~ /Error-view/ && $danger_flag){
		main::error("危険なタグ ( $danger_flag ) が含まれているため、変更できません。");
	}

return($danger_flag);

}


1;
