	
sub monster_list{


# CSS定義
$css_text .= qq(
th.name{width:24%;}
th.hp{width:24%;}
th.exp{width:24%;}
th.atack{width:24%;}
);

# 局所化
my($line);

# モンスターファイルを開く
for(0...5){

my($line2);

# 整形
$line .= qq(
<h2>レベル${_}</h2>
<table summary="モンスターデータ" class="adventure">
<tr><th class="name">名前</th><th class="hp">HP(予\測)</th><th class="exp">経験値(予\測)</th><th class="atack">攻撃力</th></tr>
);

# データ追加
$monster_file = "m${_}.ini";
$monster_file2 = "monster${_}.cgi";
open(MONSTER_IN,"$monster_file") || &error("モンスターファイルが開けません。");
while(<MONSTER_IN>){
chomp;
my($mname,$mex,$mhp,$msp,$mdmg) = split(/<>/);
my($hp,$hp2);
$hp = $mhp + $msp;
$hp2 = int($msp + $mhp);
$line .= qq(<tr><td>$mname</td><td>$hp</td><td>$mex</td><td>$mdmg</td></tr>);
$line2 .= qq($mname<>$mex<>$hp2<>$mdmg<>\n);
}
close(MONSTER_IN);

# ファイルを更新
if($alocal_mode){
open(FILE_OUT,">$monster_file2");
print FILE_OUT $line2;
close(FILE_OUT);
chmod($logpms,"$monster_file2");
}

# 整形
$line .= qq(</table>);

}


main::header();

print qq(
<div class="body1">
<h1>モンスター</h1>
$link_line
$line

</div>);

&footer;

exit;

}

1;

