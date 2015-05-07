
use strict;
package Mebius::Admin;
use Mebius::Export;

#-----------------------------------------------------------
# 管理用リンク (ホスト名)
#-----------------------------------------------------------
sub user_control_link_host{

my $target = shift || return();
my($my_admin) = Mebius::my_admin();
my($my_account) = Mebius::my_account();
my($self);

# 代替えホスト名
my($hashed_target) = Mebius::Crypt::crypt_text("MD5",$target,"Dl");

	if($my_admin->{'master_flag'} || $my_account->{'master_flag'}){
		$self = user_control_link_core($target,"host");
	} else {
		$self = $hashed_target;
	}

$self;

}
#-----------------------------------------------------------
# 管理用リンク (ISP)
#-----------------------------------------------------------
sub user_control_link_isp{

my $target = shift;
my($my_admin) = Mebius::my_admin();
my($self);

# 代替ISP名
my($hashed_target) = Mebius::Crypt::crypt_text("MD5",$target,"Dl");

	if($my_admin->{'master_flag'}){
		$self = user_control_link_core($target,"isp");
	} else {
		$self = $hashed_target;
	}

my $self = user_control_link_core($target,"isp");

}

#-----------------------------------------------------------
# 管理用リンク (ホスト名からISP名を参照)
#-----------------------------------------------------------
sub user_control_link_isp_ref_host{

my @self;
my($host) = @_;

# ホスト名からISP名を取得
my($isp) = Mebius::Isp(undef,$host);

my $self = user_control_link_isp($isp);

}

#-----------------------------------------------------------
# 管理用リンク (Cookie)
#-----------------------------------------------------------
sub user_control_link_cookie{
my $target = shift;
my $self = user_control_link_core($target,"number");
}

#-----------------------------------------------------------
# 管理用リンク (アカウント)
#-----------------------------------------------------------
sub user_control_link_account{
my $target = shift;
my $self = user_control_link_core($target,"account");
}

#-----------------------------------------------------------
# 管理用リンク(ユーザーエージェント・個体識別番号)
#-----------------------------------------------------------
sub user_control_link_user_agent{
my $target = shift;
my $self = user_control_link_core($target,"agent");
}


#-----------------------------------------------------------
# 管理用リンク(マルチ処理)
#-----------------------------------------------------------
sub user_control_link_multi{

my $use = shift if(ref $_[0] eq "HASH");
my %self;

$self{'cookie'} = user_control_link_cookie($use->{'cnumber'} || $use->{'cookie'} || $use->{'cookie_char'});
$self{'account'} = user_control_link_account($use->{'account'});
$self{'user_agent'} = user_control_link_user_agent($use->{'user_agent'});
$self{'host'} = user_control_link_host($use->{'host'});
$self{'isp'} = user_control_link_isp_ref_host($use->{'host'});

\%self;

}


#-----------------------------------------------------------
# 管理用リンク ( コア処理 )
#-----------------------------------------------------------
sub user_control_link_core{

my($target) = shift;
my($target_type) = shift;
my($base_url);

	if(!$target){ return(); }
	if(!$target_type){ return(); }

	if(Mebius::alocal_judge()){
		$base_url = "/jak/index.cgi";
	} else {
		$base_url = "https://mb2.jp/jak/index.cgi";
	}

my($encoded_target_text) = Mebius::encode_text($target);
my $self = qq(<a href="${base_url}?mode=cdl&amp;file=).e($encoded_target_text).qq(&amp;filetype=).e($target_type).qq(" class="manage">).e($target).qq(</a>);

}




1;