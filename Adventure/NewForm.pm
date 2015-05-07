
use Mebius::RegistCheck;
use strict;
package Mebius::Adventure;
use Mebius::Export;

#-----------------------------------------------------------
# �V�K�o�^�t�H�[��
#-----------------------------------------------------------
sub NewForm{

# �錾
my($init) = &Init();
my($randid,$randpass,$randname,$point);
our($advmy);

# CSS��`
$main::css_text .= qq(
table.select_skill{border-style:none;}
td.select_skill_sub{border-style:none;width:70px;background:#8bf;}
td.select_skill{border-style:none;width:70px;}
table.newmake,td.newmake{border-style:none;}
);

# �^�C�g����`
$main::sub_title = qq(�V�K�o�^ | $main::title);
$main::head_link3 = qq(&gt; �V�K�o�^);

	# �A�J�E���g�Ƀ��O�C�����Ă��Ȃ��ꍇ
	if(!$main::myaccount{'file'}){ main::error("�L�����N�^��V�K�쐬����ɂ́A�A�J�E���g�Ƀ��O�C���i�܂��͐V�K�o�^�j���Ă��������B","401"); }

# �L�����N�^�t�@�C�����擾
my($adv) = &File("",{ FileType => "Account" , id => $main::myaccount{'file'} });

	# ���ɃL�����N�^�[�����݂���ꍇ
	if($adv->{'f'}) {
			if(Mebius::alocal_judge() && 1 == 0){ unlink($adv->{'file'}); }
			else{ 
				Mebius::Redirect(undef,$init->{'base_url'});
				main::error(qq(���Ȃ��͊��ɃL�����N�^���쐬���Ă��܂��B<a href="$init->{'script'}?mode=login">�}�C�L�����N�^�[��</a>));
		}
	}

# �E�ƃ��X�g���擾
require Mebius::Adventure::Job;
my($jobflag,$jobline,$job_select,$job_list) = &SelectJob("");


	# �p�X��������
	if($main::alocal_mode){
		$randname = qq(�e�X�^�[) . int(rand(9999))
	}


my $print .= <<"EOM";
<h1>�L�����N�^�쐬</h1>
<form action="$init->{'script'}" method="post"$main::sikibetu>
<input type="hidden" name="mode" value="make_end">
<table class="newmake">

<tr>
<td class="newmake">�A�J�E���g</td>
<td class="newmake"><a href="${main::auth_url}$main::myaccount{'file'}/" target="_blank" class="blank">$main::myaccount{'file'}</a> </td>
</tr>

<tr>
<td class="newmake">�L�����N�^�[�̖��O</td>
<td class="newmake"><input type="text" name="c_name" size="30" value="$randname"></td>
</tr>


<tr>
<td class="newmake">�L�����N�^�[�̐���</td>
<td class="newmake">
<label><input type="radio" name="sex" value="1"$main::parts{'checked'}>�j</label>
<label><input type="radio" name="sex" value="0">��</label>
</td>
</tr>
EOM


$print .= <<"EOM";
<tr>
<td>�E��</td>
<td>
<label><input type="radio" name="new_job" value="0"$main::parts{'checked'}$main::xclose>��m</label>
<label><input type="radio" name="new_job" value="1"$main::xclose>���@�g��</label>
<label><input type="radio" name="new_job" value="2"$main::xclose>�m��</label>
<label><input type="radio" name="new_job" value="3"$main::xclose>����</label>
</td>
</tr>
<tr>
<td colspan="2" class="newmake"><input type="submit" value="���̓��e�ŃL�����N�^�[���쐬"></td>
</tr>
</table>
<input type="hidden" name=point value="$point">
</form>
EOM

# �E�ƃ��X�g
#print qq(
#<h2>�E�ƃ��X�g</h2>
#$job_list
#);



# �t�b�^�[
Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# �L�����N�^�쐬�A�o�^���� 
#-----------------------------------------------------------
sub NewCharaMake{

# �錾
my($init) = &Init();
my($jobflag,%adv);

# �A�N�Z�X����
main::axscheck("Post-only ACCOUNT");

# �e��G���[
require "${main::int_dir}regist_allcheck.pl";
($main::in{'c_name'}) = shift_jis(Mebius::Regist::name_check($main::in{'c_name'}));
	if($main::in{'c_name'} eq "") { main::error("�L�����N�^�[�̖��O�����L���ł�"); }

$main::in{'c_name'} =~ s/(��|��)//g;
($main::in{'c_name'}) = split(/#/,$main::in{'c_name'});

# �L�����N�^�t�@�C�����쐬
&NewCharacterMake(undef,{ FileType => "Account" , id => $main::myaccount{'file'} , sex => $main::in{'sex'} , job => $main::in{'new_job'} , name => $main::in{'c_name'}  });


my $print = <<"EOM";
<h1>�o�^�������</h1>
<div>�V�K�o�^���������܂����I</div>
$init->{'continue_button'}
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;
}


1;
