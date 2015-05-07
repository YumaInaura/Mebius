
# �p�b�P�[�W�錾
use strict;
use Mebius::Dos;
use Mebius::Encode;
package Mebius;

#-----------------------------------------------------------
# ���_�C���N�g ( �ʖ� )
#-----------------------------------------------------------
sub redirect{
Redirect("Not-exit",@_);
}

#-----------------------------------------------------------
# ���_�C���N�g����
#-----------------------------------------------------------
sub Redirect{

# �錾
my($type,$redirect_url,$code) = @_;
my($use) = @_ if(ref $type eq "HASH");

	# ���_�C���N�g�悪�w�肳��Ă��Ȃ��ꍇ
	if($redirect_url eq ""){ die('Perl Die! Redirect URL is empty'); }

	# ���_�C���N�g���֎~����t�q�k
	if($redirect_url =~ /pagead/){ die('Redirect URL is Denied'); }

# ���T�[�o�[�h���C�������擾
my($REQUEST_URL) = Mebius::request_url();

	# http:// ����n�܂��Ă��Ȃ��ꍇ�A���T�[�o�[�h���C����⑫
	if($redirect_url =~ m|^/|){
		my($server_url) = Mebius::server_url();
		$redirect_url = qq($server_url$redirect_url);
	}

# &amp; ���f�X�P�[�v
($redirect_url) = Mebius::Descape("",$redirect_url);

	# �����`�F�b�N
	if($redirect_url =~ /(\n|\r|\0)/){ die("Perl Die!  Redirect URL has Bad shintax ."); }

	# �_�u���X���b�V�����֎~ ( http:// �� // �͏��� )
	if($redirect_url =~ m!([^:])(/){2,}!){ die("Perl Die!  Redirect URL has Double Slash => $redirect_url ."); }

# �V���[�v�̂��Ȃ����K��URL���`
my $redirect_url_justy = $redirect_url;
$redirect_url_justy =~ s/#([a-zA-Z0-9]+)?$//g;

	# ����̒[���ŁA�t�q�k������ # �ȍ~���폜
	if($ENV{'HTTP_USER_AGENT'} =~ /^KDDI|bingbot/ || $main::bot_access){ $redirect_url = $redirect_url_justy; }

	# ���_�C���N�g���[�v��h��
	if($ENV{'REQUEST_METHOD'} ne "POST" && $REQUEST_URL eq $redirect_url_justy){
		#Mebius::AccessLog(undef,"Redirect-roop","$REQUEST_URL �� $redirect_url $code");
		die("Perl Die!  Redirect is Rooping. '$REQUEST_URL' to '$redirect_url'");
	}

	# �����Ƃ��Ď��h���C���݂̂ւ̃��_�C���N�g������
	if(!$use->{'AllowOtherSite'} && $redirect_url =~ m!^https?://! && $redirect_url !~ m!^https?://$ENV{'HTTP_HOST'}/!){
		my($justy_domain_flag) = Mebius::Init::AllDomains({ TypeJustyCheck => 1 , URL => $redirect_url } );
			if(!$justy_domain_flag){
				Mebius::AccessLog(undef,"Redirect-to-other-site-url");
					die("Perl Die!  Redirect to Other Site's URL => $redirect_url .");
			}
	}

	# ���_�C���N�g���L�^
	if(rand(10) < 1){
			if($main::bot_access){
				#Mebius::AccessLog(undef,"Redirect-bot","$REQUEST_URL�� $redirect_url $code");
			}
			else{
				#Mebius::AccessLog(undef,"Redirect-user","$REQUEST_URL �� $redirect_url $code");
			}
	}


# DOS��������炷
#Mebius::Dos::AccessFile("Redirect-url Renew",$ENV{'REMOTE_ADDR'});

print "Pragma: no-cache\n";

	# �P�v�I�ȃ��_�C���N�g
	if($code eq "301" || $type =~ /301/){
		print "Status: 301 Moved Permanently\n";
		print "Location: $redirect_url\n";
		print "\n";

			if($type !~ /Not-exit/){
				exit;
			}

	}
	# �ꎞ�I�ȃ��_�C���N�g
	else{
		print "Location: $redirect_url\n";
		print "\n";

			if($type !~ /Not-exit/){
				exit;
			}

	}

# ���^�[��
return();

}

1;
