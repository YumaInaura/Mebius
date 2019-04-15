
use strict;
package Mebius;

#-----------------------------------------------------------
# �A�N�Z�X���O�̋L�^
#-----------------------------------------------------------
sub AccessLog{

# �Ǐ���
my($type,$filename,$comment,$unlink_rand) = @_;
my($line,$view_host,$file,$accesslog_handler);
my $logpms = 0606;

	# �l�̃`�F�b�N
	if($unlink_rand =~ /\D/){ die("Perl Die! Can't use not number in unlink rand value . \@_ is @_ "); }

# �����`�F�b�N
$filename =~ s/[^\w\-]//g;
if($filename eq ""){ return; }

# �������Z�b�g
my $time = time;

# �v���N�V�֌W�̊��ϐ����擾
my(%env) = Mebius::Env("Get-proxy-only");

# ���ϐ����擾
my $addr = $ENV{'REMOTE_ADDR'};
my $agent = $ENV{'HTTP_USER_AGENT'};
my $host2 = $ENV{'REMOTE_HOST'};
my $requri = $ENV{'REQUEST_URI'};
my $referer = $ENV{'HTTP_REFERER'};
my $cookie = $ENV{'HTTP_COOKIE'};
my $query = $main::postbuf;
my($REQUES_URL) = Mebius::request_url();

	# �p�X���[�h�͋L�^���Ȃ��悤��
	$query =~ s/(pass|password|passwd|hamdle)(\d)?=([^&]+)/$1$2=****/g;

$view_host = $main::host;
if($view_host eq ""){ $view_host = $host2; }

# �e��f�[�^���擾
my($nowdate_multi) = Mebius::now_date_multi();

# �������ݓ��e���`
$line .= qq($time	$nowdate_multi->{'date'}	$view_host	$addr $query \n);
$line .= qq($agent $ENV{'HTTP_X_UP_SUBNO'} $ENV{'HTTP_X_EM_UID'}\n);

	# �N�b�L�[���L�^
	if($cookie){
		#$line .= qq(Cookie-natural : $ENV{'HTTP_COOKIE'}\n);
		my($cookie_dec) = Mebius::Decode("",$cookie);
		$line .= qq(Cookie-decoded : $cookie_dec\n);
	}

	# ���t�@�����L�^
	if($referer){ $line .= qq(Referer: $referer\n); }

	# �n�b�V����W�J
	if($env{'all_data'}){ $line .= qq($env{'all_data'}\n); }

# $ENV�n
$line .= qq(\$ENV{'REQUEST_METHOD'} : $ENV{'REQUEST_METHOD'});
$line .= qq( / RequestURL : $REQUES_URL);
$line .= qq(\n);

	if($comment){ $line .= qq($comment\n); }

$line .= qq(\n);

# �t�@�C����`
my($init_directory) = Mebius::BaseInitDirectory(); 
$file = "${init_directory}_accesslog/${filename}_accesslog.log";

# �t�@�C�����X�V
open($accesslog_handler,">>",$file);
print $accesslog_handler $line;
close($accesslog_handler);
Mebius::Chmod(undef,"$file");

	# ���m���Ńt�@�C�����폜
	if($type !~ /Not-unlink-file/){
			if(!$unlink_rand){ $unlink_rand = 500; } 
			if(rand($unlink_rand) < 1){ unlink("$file"); }
	}

}

#-----------------------------------------------------------
# ���O���L�^���� Die ����
#-----------------------------------------------------------
#sub Die{

#my($message,$use) = @_;

# ���O���L�^
#my $log_name = $message;
#$log_name =~ s/\s/-/g;
#Mebius::AccessLog(undef,"Die-$log_name");

# die ����
#die($message);

#}


1;
