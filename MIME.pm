
package MIME;

#-----------------------------------------------------------
# メール文字のエンコード
#-----------------------------------------------------------

sub mimew_init{

$main'mimew_version = "2.02";

$often_use_kanji = 'SJIS'; # or 'EUC'

$jis_in  = "\x1b\$B"; # ESC-$-B ( or ESC-$-@ )
$jis_out = "\x1b\(B"; # ESC-(-B ( or ESC-(-J )


## MIME base64 アルファベットテーブル（RFC2045より）
%mime = (
"000000", "A",  "000001", "B",  "000010", "C",  "000011", "D",
"000100", "E",  "000101", "F",  "000110", "G",  "000111", "H",
"001000", "I",  "001001", "J",  "001010", "K",  "001011", "L",
"001100", "M",  "001101", "N",  "001110", "O",  "001111", "P",
"010000", "Q",  "010001", "R",  "010010", "S",  "010011", "T",
"010100", "U",  "010101", "V",  "010110", "W",  "010111", "X",
"011000", "Y",  "011001", "Z",  "011010", "a",  "011011", "b",
"011100", "c",  "011101", "d",  "011110", "e",  "011111", "f",
"100000", "g",  "100001", "h",  "100010", "i",  "100011", "j",
"100100", "k",  "100101", "l",  "100110", "m",  "100111", "n",
"101000", "o",  "101001", "p",  "101010", "q",  "101011", "r",
"101100", "s",  "101101", "t",  "101110", "u",  "101111", "v",
"110000", "w",  "110001", "x",  "110010", "y",  "110011", "z",
"110100", "0",  "110101", "1",  "110110", "2",  "110111", "3",
"111000", "4",  "111001", "5",  "111010", "6",  "111011", "7",
"111100", "8",  "111101", "9",  "111110", "+",  "111111", "/",
);

## JISコード(byte数)→encoded-word の文字数対応
%mimelen = (
 8,30, 10,34, 12,34, 14,38, 16,42,
18,42, 20,46, 22,50, 24,50, 26,54,
28,58, 30,58, 32,62, 34,66, 36,66,
38,70, 40,74, 42,74,
);

## ヘッダエンコード時の行の長さの制限
$limit=74; ## ＊注意＊ $limitを75より大きい数字に設定してはいけない。

## ボディbase64エンコード時の行の長さの制限
$foldcol=72; ## ＊注意＊ $foldcolは76以下の4の倍数に設定すること。

## ボディQuoted-Printableエンコード時の行の長さの制限
$qfoldcol=75; ## ＊注意＊ $foldcolは76以下に設定すること。

## null bitの挿入と pad文字の挿入のためのテーブル
@zero = ( "", "00000", "0000", "000", "00", "0" );
@pad  = ( "", "===",   "==",   "=" );

## ASCII, 7bit JIS, Shift-JIS 及び EUC の各々にマッチするパターン
$match_ascii = '\x1b\([BHJ]([\t\x20-\x7e]*)';
$match_jis = '\x1b\$[@B](([\x21-\x7e]{2})*)';
$match_sjis = '([\x81-\x9f\xe0-\xfc][\x40-\x7e\x80-\xfc])+';
$match_euc  = '([\xa1-\xfe]{2})+';

## MIME Part 2(charset=`ISO-2022-JP',encoding=`B') の head と tail
$mime_head = '=?ISO-2022-JP?B?';
$mime_tail = '?=';

## &bodyencode が使う処理残しデータ用バッファ
$benbuf = "";

## &bodyencode の処理単位（バイト）
$bensize = int($foldcol/4)*3;

}

## &mimeencode interface ##
sub mimeencode2 {
    local($_) = @_;
    s/$match_jis/$jis_in$1/go;
    s/$match_ascii/$jis_out$1/go;
    $kanji = &checkkanji;
    s/$match_sjis/&s2j($&)/geo if ($kanji eq 'SJIS');
    s/$match_euc/&e2j($&)/geo if ($kanji eq 'EUC');
    s/(\x1b[\$\(][BHJ@])+/$1/g;
    1 while s/(\x1b\$[B@][\x21-\x7e]+)\x1b\$[B@]/$1/;
    1 while s/$match_jis/&mimeencode($&,$`,$')/eo;
    s/$match_ascii/$1/go;
    $_;
}

## &bodyencode interface ##
sub main'bodyencode {
    local($_,$coding) = @_;
    if (!defined($coding) || $coding eq "" || $coding eq "b64"){
	$_ = $benbuf . $_;
	local($cut) = int((length)/$bensize)*$bensize;
	$benbuf = substr($_, $cut+$[);
	$_ = substr($_, $[, $cut);
	$_ = &base64encode($_);
	s/.{$foldcol}/$&\n/g;
    }elsif ($coding eq "qp"){
	# $benbuf が空でなければデータの最初に追加する
	$_ = $benbuf . $_;

	# 改行文字を正規化する
	s/\r\n/\n/g;
	s/\r/\n/g;

	# データを行単位に分割する(最後の改行文字以降を $benbuf に保存する)
	@line = split(/\n/,$_,-1);
	$benbuf = pop(@line);

	local($result) = "";
	foreach (@line){
	    $_ = &qpencode($_);
	    $result .= $_ . "\n";
	}
	$_ = $result;
    }
    $_;
}

## &benflush interface ##
sub main'benflush {
    local($coding) = @_;
    local($ret) = "";
    if ((!defined($coding) || $coding eq "" || $coding eq "b64")
	&& $benbuf ne ""){
        $ret = &base64encode($benbuf) . "\n";
        $benbuf = "";
    }elsif ($coding eq "qp" && $benbuf ne ""){
	$ret = &qpencode($benbuf) . "\n";
	$benbuf = "";
    }
    $ret;
}

## MIME ヘッダエンコーディング
sub mimeencode {
    local($_, $befor, $after) = @_;
    local($back, $forw, $blen, $len, $flen, $str);
    $befor = substr($befor, rindex($befor, "\n")+1);
    $after = substr($after, 0, index($after, "\n")-$[);
    $back = " " unless ($befor eq ""
                     || $befor =~ /[ \t\(]$/);
    $forw = " " unless ($after =~ /^\x1b\([BHJ]$/
                     || $after =~ /^\x1b\([BHJ][ \t\)]/);
    $blen = length($befor);
    $flen = length($forw)+length($&)-3 if ($after =~ /^$match_ascii/o);
    $len = length($_);
    return "" if ($len <= 3);
    if ($len > 39 || $blen + $mimelen{$len+3} > $limit){
        if ($limit-$blen < 30){
            $len = 0;
        }else{
            $len = int(($limit-$blen-26)/4)*2+3;
        }
        if ($len >= 5){
            $str = substr($_, 0, $len).$jis_out;
            $str = &base64encode($str);
            $str = $mime_head.$str.$mime_tail;
            $back.$str."\n ".$jis_in.substr($_, $len);
        }else{
            "\n ".$_;
        }
    }else{
        $_ .= $jis_out;
        $_ = &base64encode($_);
        $_ = $back.$mime_head.$_.$mime_tail;
        if ($blen + (length) + $flen > $limit){
            $_."\n ";
        }else{
            $_.$forw;
        }
    }
}

## MIME base64 エンコーディング
sub base64encode {
    local($_) = @_;
    $_ = unpack("B".((length)<<3), $_);
    $_ .= $zero[(length)%6];
    s/.{6}/$mime{$&}/go;
    $_.$pad[(length)%4];
}

## Quoted-Printable エンコーディング
sub qpencode {
    local($_) = @_;

    # `=' 文字を16進表現に変換する
    s/=/=3D/g;

    # 行末のタブとスペースを16進表現に変換する
    s/\t$/=09/;
    s/ $/=20/;

    # 印字可能文字(`!'～`~')以外の文字を16進表現に変換する
    s/([^!-~ \t])/&qphex($1)/ge;

    # 1行が$qfoldcol文字以下になるようにソフト改行をいれる
    local($folded, $line) = "";
    while (length($_) > $qfoldcol){
	$line = substr($_, 0, $qfoldcol-1);
	if ($line =~ /=$/){
	    $line = substr($_, 0, $qfoldcol-2);
	    $_ = substr($_, $qfoldcol-2);
	}elsif ($line =~ /=[0-9A-Fa-f]$/){
	    $line = substr($_, 0, $qfoldcol-3);
	    $_ = substr($_, $qfoldcol-3);
	}else{
	    $_ = substr($_, $qfoldcol-1);
	}
	$folded .= $line . "=\n";
    }
    $folded . $_;
}

sub qphex {
    local($_) = @_;
    $_ = '=' . unpack("H2", $_);
    tr/a-f/A-F/;
    $_;
}

## Shift-JIS と EUC のどちらの漢字コードが含まれるかをチェック
sub checkkanji {
    local($sjis,$euc);
    $sjis += length($&) while(/$match_sjis/go);
    $euc  += length($&) while(/$match_euc/go);
    return 'NONE' if ($sjis == 0 && $euc == 0);
    return 'SJIS' if ($sjis > $euc);
    return 'EUC'  if ($sjis < $euc);
    $often_use_kanji;
}

## EUC を 7bit JIS に変換
sub e2j {
    local($_) = @_;
    tr/\xa1-\xfe/\x21-\x7e/;
    $jis_in.$_.$jis_out;
}

## Shift-JIS を 7bit JIS に変換
sub s2j {
    local($string);
    local(@ch) = split(//, $_[0]);
    while(($j1,$j2)=unpack("CC",shift(@ch).shift(@ch))){
        if ($j2 > 0x9e){
            $j1 = (($j1>0x9f ? $j1-0xb1 : $j1-0x71)<<1)+2;
            $j2 -= 0x7e;
        }
        else{
            $j1 = (($j1>0x9f ? $j1-0xb1 : $j1-0x71)<<1)+1;
            $j2 -= ($j2>0x7e ? 0x20 : 0x1f);
        }
        $string .= pack("CC", $j1, $j2);
    }
    $jis_in.$string.$jis_out;
}
1;
