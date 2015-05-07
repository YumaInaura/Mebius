
use strict;
package Mebius::Admin::Password;
use Mebius::Export;

#-----------------------------------------------------------
# �Ǘ��җp�̑��p�X���[�h�����t�H�[��
#-----------------------------------------------------------
sub make_password_form_for_admin{

my($my_admin) = Mebius::my_admin();
my($param) = Mebius::query_single_param();

	# �}�X�^�[�݂̂��g����悤��
	if(!$my_admin->{'master_flag'}){ main::error("�y�[�W�����݂��܂���B"); }

# �N�G������Í���
my($encpass,$salt) = encrypt_for_admin($param->{'pass'}) if($param->{'pass'});

my $print = qq(
<form action="">
<input type="hidden" name="mode" value="make_password">
<input type="password" name="pass" value=").e($param->{'pass'}).qq(">
<input type="submit" name="�p�X���[�h�����">
<div style="margin-top:1em;">
���ʁF Pass: ).e($param->{'pass'}).qq( / Crypt: ).e($encpass).qq( / Salt: ).e($salt).qq(
</div>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-------------------------------------------------
#  crypt�Í�
#-------------------------------------------------
sub encrypt_for_admin {

	my($inpw) = @_;
	my($salt, $encrypt, @char);

	# �������`
	@char = ('a'..'z', 'A'..'Z', '0'..'9', '.', '/');

	# �����Ŏ�𐶐�
	srand;
	$salt = $char[int(rand(@char))] . $char[int(rand(@char))];

	# �Í���
	$encrypt = crypt($inpw, $salt) || crypt ($inpw, '$1$' . $salt);

$encrypt,$salt;

}


1;
