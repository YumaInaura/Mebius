	
sub monster_list{


# CSS��`
$css_text .= qq(
th.name{width:24%;}
th.hp{width:24%;}
th.exp{width:24%;}
th.atack{width:24%;}
);

# �Ǐ���
my($line);

# �����X�^�[�t�@�C�����J��
for(0...5){

my($line2);

# ���`
$line .= qq(
<h2>���x��${_}</h2>
<table summary="�����X�^�[�f�[�^" class="adventure">
<tr><th class="name">���O</th><th class="hp">HP(�\\��)</th><th class="exp">�o���l(�\\��)</th><th class="atack">�U����</th></tr>
);

# �f�[�^�ǉ�
$monster_file = "m${_}.ini";
$monster_file2 = "monster${_}.cgi";
open(MONSTER_IN,"$monster_file") || &error("�����X�^�[�t�@�C�����J���܂���B");
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

# �t�@�C�����X�V
if($alocal_mode){
open(FILE_OUT,">$monster_file2");
print FILE_OUT $line2;
close(FILE_OUT);
chmod($logpms,"$monster_file2");
}

# ���`
$line .= qq(</table>);

}


main::header();

print qq(
<div class="body1">
<h1>�����X�^�[</h1>
$link_line
$line

</div>);

&footer;

exit;

}

1;

