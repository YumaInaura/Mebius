
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# ���r�A�h �g�b�v�y�[�W��\��
#-----------------------------------------------------------
sub Top{

# �錾
my($init) = &Init();
my($init_login) = init_login();
my($charaview);

# �`�����v�t�@�C����ǂݍ���
my($champ) = &ChampFile();

	# ���݂̃`�����s�I�����擾
	if($champ->{'id'} eq ""){
		$charaview = qq(���݁A�`�����s�I���͂��܂���B�ʍ��Ńy���J���剤���V��ł��܂��B);
	}
	else{
		require Mebius::Adventure::Charactor;
		my($champ) = &File(undef,{ FileType => "Account" , id => $champ->{'id'} });
		($charaview) = &CharaStatus({ TypeChampStatus => 1 },$champ);
	}

require Mebius::Adventure::Record;
my($winner_record_line) = &Record("Index",5);
#<strong>�ō��L�^�F</strong> <span class="red">$winner_name ( $winner_count�A�� )</span>

# �����L���O���擾
require Mebius::Adventure::Ranking;
my($menber_list) = &RankingFile({ TypeGetIndex => 1 , MaxViewIndex => 10 });

# CSS��`
$main::css_text .= qq(
ul.alert{font-size:85%;color:#f00;margin:1em 0em;padding:1em 2.5em;border:solid 1px #f00;}
);
$main::head_link2 = qq( &gt; ���r�����E�A�h�x���`���[ );

my $print .= qq(
<h1>$init->{'title'}</h1>
$init_login->{'link_line'}
$init->{'ads1_formated'}
<ul class="alert">
<li>�v���C�O�ɕK�� <a href="${main::guide_url}%A5%E1%A5%D3%A5%EA%A5%F3%A1%A6%A5%A2%A5%C9%A5%D9%A5%F3%A5%C1%A5%E3%A1%BC">�Q�[���̎�|</a> �����m�F���������B</li>
<li>�{�Q�[���ł̓L�����f�[�^�A�d�l�Ȃǂɂ��Ĉ�؂̕ۏ؁A���񑩂͂��������˂܂��B</li>
<li>�A���X�V�A�{�^���A�łȂǃT�[�o�[�ɕ��S��������s�ׂ͋֎~�ł��B(���Ȃ��̃L�����f�[�^����������ꍇ������܂�)</li>
<li>�u����������i�Q�[����́j�����𓐂ނ�v�Ȃǂ̋����s�ׂ͋֎~�ł��B</li>
<li>�퓬���ʂ���L���ɑ�ʃR�s�[����s�ׂ͂��������������B</li>
</ul>
);




# �A���L�^�̃g�b�v���擾����

$print .= qq(
<h2>���݂̃`�����s�I�� ( $champ->{'win_count'}�A���� ) </h2>
$charaview
<h2><a href="$init->{'script'}?mode=record">�A���L�^</a></h2>
$winner_record_line
<h2><a href="$init->{'script'}?mode=ranking">�����o�[</a></h2>
$menber_list
);

# �A���L�^

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;
