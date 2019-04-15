
use strict;

package Mebius::GetPage;

#-----------------------------------------------------------
# �I�u�W�F�N�g�֘A�t��
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_status{

my $self = shift;
Mebius::Getstatus(undef,@_);
}


package Mebius;

#-----------------------------------------------------------
# �X�e�[�^�X�R�[�h���擾
#-----------------------------------------------------------
sub Getstatus{

# �錾
my($type,$url) = @_;
my($notfound_flag);

# �֎~����t�q�k
if($url =~ /pagead/){ return(); }

	# �������[�v���֎~
	if($type !~ /Command/){
		if($main::agent =~ /libwww-perl/ || $main::agent eq ""){ return(); }
	}

# URL���f�X�P�[�v
($url) = Mebius::Descape("",$url);

use LWP::UserAgent;
my $ua = new LWP::UserAgent();
if($main::alocal_mode){ $ua->parse_head(0); }
my $head = $ua->head($url);

my $code = $head->code();
my $message = $head->message();

# �L�^
main::access_log("GETSTATUS","GetUrl : $url / Status: $code - $message");

# NotFound�n�̏ꍇ�A�t���O�𗧂Ă�
if($code eq "404" || $code eq "403" || $code eq "410" || $code eq ""){ $notfound_flag = 1; }

	if(wantarray){
		return($code,$message,$notfound_flag);
	} else {
		return($code);
	}


}

1;
