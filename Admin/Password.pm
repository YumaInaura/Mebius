
use strict;
package Mebius::Admin::Password;
use Mebius::Export;

#-----------------------------------------------------------
# 管理者用の第二パスワード生成フォーム
#-----------------------------------------------------------
sub make_password_form_for_admin{

my($my_admin) = Mebius::my_admin();
my($param) = Mebius::query_single_param();

	# マスターのみが使えるように
	if(!$my_admin->{'master_flag'}){ main::error("ページが存在しません。"); }

# クエリから暗号化
my($encpass,$salt) = encrypt_for_admin($param->{'pass'}) if($param->{'pass'});

my $print = qq(
<form action="">
<input type="hidden" name="mode" value="make_password">
<input type="password" name="pass" value=").e($param->{'pass'}).qq(">
<input type="submit" name="パスワードを作る">
<div style="margin-top:1em;">
結果： Pass: ).e($param->{'pass'}).qq( / Crypt: ).e($encpass).qq( / Salt: ).e($salt).qq(
</div>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-------------------------------------------------
#  crypt暗号
#-------------------------------------------------
sub encrypt_for_admin {

	my($inpw) = @_;
	my($salt, $encrypt, @char);

	# 文字列定義
	@char = ('a'..'z', 'A'..'Z', '0'..'9', '.', '/');

	# 乱数で種を生成
	srand;
	$salt = $char[int(rand(@char))] . $char[int(rand(@char))];

	# 暗号化
	$encrypt = crypt($inpw, $salt) || crypt ($inpw, '$1$' . $salt);

$encrypt,$salt;

}


1;
