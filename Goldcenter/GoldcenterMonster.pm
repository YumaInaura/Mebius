
# �p�b�P�[�W�錾
package Mebius::Goldcenter;
use strict;

#-----------------------------------------------------------
# �����X�^�[�t�@�C�g
#-----------------------------------------------------------
sub monster{

# �ݒ�
$main::head_link3 = qq( &gt; �����X�^�[�t�@�C�g);

# ���[�h�U�蕪��
if($main::submode2 eq ""){ &monster_index(); }
elsif($main::submode2 eq "fight"){ &monster_fight(); }
else{ &main::error("�y�[�W�����݂��܂���B"); }

exit;

}

#-----------------------------------------------------------
# �C���f�b�N�X
#-----------------------------------------------------------
sub monster_index{

# �錾
my($script_mode,$gold_url,$title) = &init();

&main::header();

# HTML
print qq(
<div class="body1">
<h1>�����X�^�[�t�@�C�g�I - $title</h1>
<form action="./" method="post">
<div>
<input type="hidden" name="mode" value="monster-fight">
<input type="submit" value="�키">
</div>
</form>
</div>
);

&main::footer();

exit;

}

#-----------------------------------------------------------
# �키
#-----------------------------------------------------------
sub monster_fight{

# �錾
my($script_mode,$gold_url,$title) = &init();
my(@line,$file);

# ���ݖ������`�F�b�N
&cash_check("","1");

# �t�@�C����`
$file = "${main::int_dir}_goldcenter/_monster_goldcenter/monster_status.log";

# �t�@�C�����J��
open(MONSTER_IN,"< $file");
flock(MONSTER_IN,1);
my $top1 = <MONSTER_IN>;
close(MONSTER_IN);

# �t�@�C���𕪉�
my($monster_hp) = split(/<>/,$top1);

# �X�e�[�^�X��ύX
$monster_hp--;

# �ǉ�����s
push(@line,"$monster_hp<>\n");

# �t�@�C�����X�V����
open(MONSTER_OUT,"+< $file") || &main::error("�t�@�C�����J���܂���B") ;
flock(MONSTER_OUT,2);
seek(MONSTER_OUT,0,0);
truncate(MONSTER_OUT,tell(MONSTER_OUT));
print MONSTER_OUT @line;
close(MONSTER_OUT);
chmod($main::logpms,"$file");

$main::cgold--;

# �N�b�L�[���Z�b�g
&main::set_cookie();

# �y�[�W�W�����v
&Mebius::Jump("","${gold_url}monster.html","1","�����X�^�[�Ɛ킢�܂����B");

# �I��
exit;

}


1;

