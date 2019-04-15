
use strict;
use Mebius::Export;
use Mebius::MIME;
use Mebius::Time;
package Mebius::Email;
use Mebius::Export;

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
sub send_email_to_master{

my $self = shift;
my $subject = shift;
my $message = shift;
send_email("To-master","",$subject,$message);

}

#-----------------------------------------------------------
# ���[���A�h���X�̌`���`�F�b�N
#-----------------------------------------------------------
sub format_error{

my $self = shift;
my $email = shift;
my($error_flag);

	# �����`�F�b�N
	if($email eq "" || $email =~ /^(\x81\x40|\s)+$/) { $error_flag = qq(���[���A�h���X�����͂���Ă��܂���B); }
	elsif(length($email) > 256) { $error_flag = qq(���[���A�h���X�̕����񂪒������܂��B); }
	elsif($email =~ /example\@ne.jp/){ $error_flag = qq(�T���v���p�̃��[���A�h���X \( ).e($email).qq( \) �͎g���܂���B); }
	elsif($email =~ /(\s|�@|\x81\x40)/) { $error_flag = qq(���[���A�h���X \( ).e($email).qq( \) �ɔ��p�X�y�[�X�A�S�p�X�y�[�X�����ꍞ��ł��܂��B); }
	elsif($email =~ /,/) { $error_flag = qq(���[���A�h���X \( ).e($email).qq( \) �� �J���} ( , ) �����ꍞ��ł��܂��B�h�b�g ( . ) �ł͂���܂��񂩁H); }
	elsif($email =~ /([^\w\-\.\@\+]+)/) { $error_flag = qq(���[���A�h���X \( ).e($email).qq( \) �Ɏg���Ȃ������� ).e($1).qq(�܂܂�Ă��܂��B); }
	elsif($email !~ /^([\w\.\-\+]+)\@([\w\.\-\+]+)\.([a-zA-Z]{2,6})$/) { $error_flag = qq(���[���A�h���X \( ).e($email).qq( \) �̏�����	���Ԉ���Ă��܂��B); }

$error_flag;

}


#-----------------------------------------------------------
# �ʖ�
#-----------------------------------------------------------
sub send{
my $self = shift;
send_email(@_);
}

#-------------------------------------------------
#  ���[�����M 
#	���c Cookie�Z�b�g���������u��v�Ŏ��s����ƁA�G���[���N�����ꍇ���� ( �����O�ɑ��� print �������Ă͂����Ȃ�? )
#-------------------------------------------------
sub send_email{

# �Ǐ���
my($basic_init) = Mebius::basic_init();
my($type,$address,$subject,$tbody,$from_adddress) = @_;
my($email,$subject2,$body,$from,%address,$mail_handler,$use);
my($server_domain) = Mebius::server_domain();
my($main_server_domain) = Mebius::main_server_domain();
	if(ref $type eq "HASH"){ $use = $type; } else { $use = {}; }

	if($use->{'source'} eq "utf8" || $type =~ /UTF8/){
		shift_jis($subject,$tbody);
	}

# ���[���A�h���X���G���R�[�h
my($address_enc) = Mebius::Encode(undef,$address);

	# ���悪��`����Ă��Ȃ��ꍇ
	if($type =~ /To-master-mobile/){ $address = $basic_init->{'admin_email_mobile'}; }
	elsif($type =~ /To-master/ || $use->{'ToMaster'}){ $address = $basic_init->{'admin_email'}; }

	# �����R�[�h
	if($use->{'FromEncoding'}){
		Mebius::Encoding::from_to($use->{'FromEncoding'},"sjis",$subject,$tbody);
	}

	# �A�h���X���w�肳��Ă��Ȃ��ꍇ
	if($address eq ""){ return(); }

	# ��������`����Ă��Ȃ��ꍇ
	if($subject eq ""){ $subject = "���r�E�X�����O���"; }

# E-Mail�����`�F�b�N
my($format_error_flag) = mail_format(undef,$address);
if($format_error_flag){ return($format_error_flag); }

# ���[���A�h���X�P�̃t�@�C������A���M�ۂ��`�F�b�N����ꍇ
(%address) = address_file("Get-hash Renew Send-mail",$address);
	if($address{'deny_flag'} && $type !~ /Not-deny-send|Allow-send-all|To-master/ && !$use->{'ToMaster'}){ return($address{'deny_flag'}); }

# �����擾�i���[���p�j
my($date_mail) = get_date_for_email();

# �ݒ�A��荞��
my $sendmail = '/usr/sbin/sendmail';
MIME::mimew_init();

$email = "apache\@$main_server_domain";

	# �{���ɋ��ۗp��URL��ǉ�
	# $type =~ /Edit-url-plus/ && 
	if($address{'char'}){

		$tbody .= qq(\n\n������������������������������������������������������������\n\n);


			#if($address{'certified_flag'}){
			$tbody .= qq(�����炩�烁�[�����M�̈ꊇ�֎~��A�z�M�����Ԃ̕ύX���ł��܂��B);
					# �{���Ɋe�����ǉ�
					if($address{'allow_hour'}){
						$tbody .= qq( \( ���݂̋����ԁF $address{'allow_hour_start'}��00�� - $address{'allow_hour_end'}��59�� \) );
					}
			$tbody .= qq(\n);
			$tbody .= edit_address_url(__PACKAGE__,$address,$address{'char'});

	}

	# ���{���ɏڍׂȃA�N�Z�X�f�[�^��ǉ� ( ���[�v���Ȃ��ꍇ�̂� )
	if($type =~ /To-master|View-access-data/){

		# �Ǐ���
		my($gethost,$encid);

		my($cookie_decoded) = Mebius::Decode(undef,$ENV{'HTTP_COOKIE'});

			# �z�X�g���֌W
			if($type !~ /BlockRoopingGetHost/){
				($encid) = main::id();
				($gethost) = Mebius::get_host_state();
			}


		$tbody .= qq(\n\n----------------------------------------------------------------------\n\n);
		$tbody .= qq(�M���F $main::cnam\n);

			# ID
			if($encid){
				$tbody .= qq(ID: ��$encid\n\n);
			}

			# �Ǘ��ԍ�
			if($main::cnumber){
				$tbody .= qq(�Ǘ��ԍ�: $main::cnumber \n);
				$tbody .= qq(�@ ${main::jak_url}index.cgi?mode=cdl&file=$main::cnumber&filetype=number\n\n);
			}

			# �A�J�E���g
			if($main::myaccount{'file'}){
				$tbody .= qq(�A�J�E���g�F ${main::auth_url}$main::myaccount{'file'}/ \n);
					if($type =~ /To-master/){ $tbody .= qq(�@ https://mb2.jp/jak/index.cgi?mode=cdl&file=$main::myaccount{'file'}&filetype=account\n\n); }
			}

		$tbody .= qq(IP�A�h���X�F $main::addr \n);
			if($type =~ /To-master/){ $tbody .= qq(�@ https://mb2.jp/jak/index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$main::addr) . qq(&filetype=addr \n\n); }

		# �z�X�g���擾
		# ���[�v���N����₷���̂Œ��ӁI
		if($gethost){

					if($gethost){
						$tbody .= qq(�z�X�g���F $gethost \n);
							if($type =~ /To-master/){ $tbody .= qq(�@ https://mb2.jp/jak/index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$gethost) . qq(&filetype=host \n\n); }
					}

					#if($gethost->{'isp'}){
					#	$tbody .= qq(ISP���F $gethost->{'isp'} \n);
					#		if($type =~ /To-master/){ $tbody .= qq(�@ ${main::jak_url}index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$gethost->{'isp'}) . qq(&filetype=isp \n\n); }
					#}

		}

		$tbody .= qq(\nUA�F\n$main::agent \n);
			if($type =~ /To-master/){ $tbody .= qq(�@ https://mb2.jp/jak/index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$main::agent) . qq(&filetype=agent \n\n); }

		if($main::realagent ne $main::agent){
			$tbody .= qq(\n��UA�F\n$main::realagent \n);
				if($type =~ /To-master/){ $tbody .= qq(�@ https://mb2.jp/jak/index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$main::realagent) . qq(&filetype=agent \n\n); }
		}

		$tbody .= qq(\nCookie�F\n$cookie_decoded \n);
		$tbody .= qq(\nCookie-encoded�F\n$main::cookie \n);
			
		my($gethostbyaddr) = Mebius::GetHostByAddr();
		$tbody .=qq(\nGetHostByAddr : $gethostbyaddr\n);

		my($gethostbyname) = Mebius::GetHostByName({ Host => $gethostbyaddr});
		$tbody .=qq(\nGetHostByName : $gethostbyname\n);

		$tbody .= qq(\nRequest-uri: $ENV{'REQUEST_URI'}\n);
		$tbody .= qq(\nReferer: $ENV{'HTTP_REFERER'}\n);
		$tbody .= qq(\nREQUEST_METHOD : $ENV{'REQUEST_METHOD'} \n);

		$tbody .= qq(\n);
		$tbody .= qq(IP�Ǘ�: ${main::jak_url}index.cgi?mode=cda&file=$main::addr\n);
		$tbody .= qq(IP�Ђ��: http://www.iphiroba.jp/index.php\n);
	}

	# ���[���\�t�g��M���̐U�蕪���p
	if($type =~ /Important-message/){
		$tbody .= qq(\n\nImportant-message\n);
	}

	# ���M�����𖾋L
	if($type !~ /Not-view-send-date/){
		$tbody .= qq(\n\n���M�����F $main::date:$main::thissecf\n);
	}

# URL�ɃX�y�[�X��t����
($tbody) = Mebius::url({ AddSpace => 1 },$tbody);

# Email�p�̃f�R�[�h
($tbody) = decode_for_email("Body",$tbody);
($subject) = decode_for_email("Subject",$subject);

# �L�^�p
my $keep_body = $tbody;
my $keep_subject = $subject;

# �{���G���R�[�h
jcode::convert(\$tbody, 'jis');

# �����G���R�[�h
$subject2 = MIME::mimeencode2($subject);
$from = MIME::mimeencode2("���r�E�X�����O <$email>");

# ���M���e�t�H�[�}�b�g��

$body = "To: $address\n";
$body .= "From: $from\n";

	# From �A�h���X
#	if($from_adddress){ $body .= "Cc: $from_adddress\n"; }

$body .= "Subject: $subject2\n";
$body .= "MIME-Version: 1.0\n";
$body .= "Content-type: text/plain; charset=iso-2022-jp\n";
$body .= "Content-Transfer-Encoding: 7bit\n";
$body .= "Date: $date_mail\n";
	if($address{'char'}){ $body .= qq(Mebius-char: $address{'char'}\n); }
	#elsif($address{'cer_char'}){ $body .= qq(Mebius-char: $address{'cer_char'}\n); }
$body .= "X-Mailer: Mebi-mail\n";
$body .= "\n";
$body .= "$tbody\n";

# ���M
open($mail_handler,"| $sendmail -t -i") || return("���[�������M�ł��܂���ł����B");
print $mail_handler "$body\n";
close($mail_handler);

	# ���[�J���ȂǁA�Q�l���Ƃ��đ��M���e��Ԃ��ꍇ
	if($type =~ /Get-mailbody/){
		$keep_body =~ s/\n/<br$main::xclose>/g;
		return(undef,$keep_body);
	}
	if(Mebius::alocal_judge()){
		Mebius::access_log("Send-mail","$keep_subject\nTo: $address\n From: $from\n$keep_body ");
	}

return(undef);

}

#-----------------------------------------------------------
# ���[���p�f�R�[�h
#-----------------------------------------------------------
sub decode_for_email{

my($type,$text) = @_;

# �{���ϊ�
$text =~ s/&lt;/</g;
$text =~ s/&gt;/>/g;
$text =~ s/&amp;/&/g;
$text =~ s/&quot;/"/g;
$text =~ s/\0/ /g;
$text =~ s/\.\n/\. \n/g;

	# ���s�̏���
	if($type =~ /Body/){
		$text =~ s/(<br>|\r)/\n/g;
		$text =~ s/\r\n/\n/;
	}
	elsif($type =~ /Subject/){
		$text =~ s/(\r|\n|<br>)//g;
	}

# �Y�t�t�@�C������
$text =~ s/Content-Disposition:\s*attachment;.*//ig;
$text =~ s/Content-Transfer-Encoding:.*//ig;
$text =~ s/Content-Type:\s*multipart\/mixed;\s*boundary=.*//ig;

return($text);

}


#-------------------------------------------------
# ���[�����M�p�̎��Ԏ擾
#-------------------------------------------------
sub get_date_for_email{
	$ENV{'TZ'} = "JST-9";
	my ($sec,$min,$hour,$mday,$mon,$year,$wday) = localtime(time);
	my @w = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
	my @m = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

	my $date2 = sprintf("%s, %02d %s %04d %02d:%02d:%02d",
			$w[$wday],$mday,$m[$mon],$year+1900,$hour,$min,$sec) . " +0900";

	return ($date2);

}

#-----------------------------------------------------------
# ��M�������[��������
#-----------------------------------------------------------
sub catch_mail{

# �錾
my $self = shift;
my($type) = @_;
my($line,$line2,$from,$unsend_flag,%to,%mail_body,%mail_header,$mailbody_flag,$keep_char,$toomany_flag);
my(%from,%subject,$undelivered_address);

# ���[���敪�̂��߂̃J�E���^
my $tag = "main";

	# �e�X�g�p
	if($type =~ /Test-mode/){ open(STDIN,"./mail.log"); }

	# ���[�����󂯎��
	while(<STDIN>){

		# �L�^�p
		$line2 .= qq($_);

		# �s�𕪉�
		chomp;

			# ���̃��[���敪�ɓ��B�����ꍇ
			if($_ =~ /^Content-Description: ([\w\s]+)/){ $tag = $1; $mailbody_flag = 0; }

			# �{���ɓ��B�����ꍇ ( ���ɖ{���ɓ��B���Ă���ꍇ�́A��d���s�����̂܂܏������� )
			if($_ eq "" && !$mailbody_flag){ $mailbody_flag = 1; next; }

			# �e�푗�M������
			if($_ =~ /^To: (.+)/){ $to{$tag} = $1; }
			if($_ =~ /^From: (.+)/){ $from{$tag} = $1; }
			if($_ =~ /^Subject: (.+)/){ $subject{$tag} = $1; }

			# ���[���{���̏���
			if($mailbody_flag){
				$mail_body{$tag} .= qq($_\n);
			}
			# ���[���w�b�_�̏���
			else{
				$mail_header{$tag} .= qq($_\n);
			}
	}

	# �e�X�g�p
	if($type =~ /Test-mode/){ close(STDIN); }

	# ��M���[�����e�𖳏����ɋL�^
	$line2 .= qq(������������������������������������������������������������\n\n);
	Mebius::AccessLog(undef,"Catch-mail",$line2);

	# �A�h���X�P�̃t�@�C�����J��
	my(%address) = address_file(undef,$to{'Undelivered Message'});

	# ���[���{���i���̃w�b�_�j�� char ���܂܂�Ă���ꍇ
	if($mail_body{'Undelivered Message'} =~ /Mebius-char: ($address{'char'}|$address{'cer_char'})/){

			# �L�^�p
			$keep_char = $1;

			# ���M���|�[�g��������A�������[�����ǂ����𔻒�
			if($mail_body{'Delivery report'} =~ /Diagnostic-Code: smtp; (421|452)(.+)/){ $toomany_flag = "���M���I�[�o�[�H $1$2"; }
			elsif($mail_body{'Delivery report'} =~ /Diagnostic-Code: (.{1,50})?(bad address syntax|Host or domain name not found)/i){ $unsend_flag = "�e��G���[ $1$2"; }
			elsif($mail_body{'Delivery report'} =~ /Diagnostic-Code: smtp; (550|554)(.+)/){ $unsend_flag = "���� $1$2"; }
			# Recipient's mailbox is full, message returned to sender. (#5.2.2)


	}

	# ���������[���A�h���X�̒P�̃t�@�C�����X�V
	if($toomany_flag){
		address_file("Renew Undelivered-later",$to{'Undelivered Message'});
		$undelivered_address = $to{'Undelivered Message'};
	}

	# ���������[���A�h���X�̒P�̃t�@�C�����X�V
	elsif($unsend_flag){
		address_file("Renew Undelivered",$to{'Undelivered Message'});
		$undelivered_address = $to{'Undelivered Message'};
	}

	# ��EZWEB�ł̖���
	elsif($from{'main'} =~ /^Postmaster\@ezweb\.ne\.jp$/ && ($subject{'main'} =~ /Mail System Error - Returned Mail/i || $type =~ /Test-mode/)){
		$unsend_flag = $&;
			if($mail_body{'main'} =~ /<([\w_\.\-\@]+?)>/){
					my $address = $1;
					my($mail_format_error) = mail_format(undef,$address);
					if(!$mail_format_error){
						address_file("Renew Undelivered",$address);
						$undelivered_address = $address;
					}
			}
	}

	# �m�F�p�̃��O���L�^
	if($undelivered_address){
		$line .= qq(To: $undelivered_address\n);
		$line .= qq(��ԁF $unsend_flag $toomany_flag\n);
		$line .= qq(Char: $keep_char\n);
		$line .= qq(������������������������������������������������������������\n\n);
		Mebius::AccessLog(undef,"Undelivered-mail",$line);
	}

	# �e�X�g�p
	if($type =~ /Test-mode/){
		my $print = qq(OK! / �A�h���X�F $undelivered_address / ��ԁF $unsend_flag);
		Mebius::Template::gzip_and_print_all({},$print);
	}

	# ���b�Z�[�W��Ԃ�
	else{
		print qq($line ok!);
	}

exit;

}


#-----------------------------------------------------------
# �����̃A�h���X�����擾
#-----------------------------------------------------------
sub my_address{

# Near State �i�Ăяo���j 2.30
my $StateName1 = "my_address";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

# �N�b�L�[���擾
#my($my_cookie) = Mebius::my_cookie_main_logined(); # �����炾�Ɩ������[�v�ɁH
my($my_cookie) = Mebius::my_cookie_main();

# �A�h���X���t�@�C�����擾
my(%address) = Mebius::Email::address_file("Get-hash-detail",$my_cookie->{'email'});

	# Near State �i�ۑ��j 2.30
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,\%address); }

	if($address{'myaddress_flag'}){ return(\%address); }
	else{ return(); }

}


#-----------------------------------------------------------
# ���[���A�h���X���̒P�̋L�^�t�@�C��
#-----------------------------------------------------------
sub address_file{

# �錾
my($type,$address,%renew) = @_;
my($address_handler,%address,@renew_line,@top,$i);
#my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();
my($my_account) = Mebius::my_account();
my $times = new Mebius::Time;

# �A�h���X�r���`�F�b�N
$address =~ s/"//g;

# �G���R�[�h
my($address_enc) = Mebius::Encode(undef,$address);

# �t�@�C�����`
my $directory = "${share_directory}_address/${address_enc}/";
my $file = "${directory}address.dat";


	# �t�@�C�����J��
	if($type =~ /File-check/){ 
		open($address_handler,"<",$file) || return();
	}
	else{
		open($address_handler,"<",$file) || ($address{'file_nothing_flag'} = 1);
	}

	if($type =~ /Renew/){ flock($address_handler,1); }

chomp(my $top1 = <$address_handler>);
chomp(my $top2 = <$address_handler>);
chomp(my $top3 = <$address_handler>);
chomp(my $top4 = <$address_handler>);
chomp(my $top5 = <$address_handler>);
close($address_handler);

# �f�[�^�𕪉�
($address{'concept'},$address{'address'},$address{'char'},$address{'firstsend_time'},$address{'lastsend_time'},$address{'block_time'}) = split(/<>/,$top1);
($address{'allsend_count'},$address{'undelivered_count'},$address{'mail_type'},$address{'allow_hour'}) = split(/<>/,$top2);
($address{'addr'},$address{'host'},$address{'cnumber'},$address{'agent'},$address{'account'}) = split(/<>/,$top3);
($address{'cer_lastsend_time'},$address{'cer_char'},$address{'cer_type'},$address{'cer_count'}) = split(/<>/,$top4);
($address{'cer_addr'},$address{'cer_host'},$address{'cer_cnumber'},$address{'cer_agent'},$address{'cer_account'},$address{'xip'}) = split(/<>/,$top5);

# �n�b�V������
if(!$address{'file_nothing_flag'}){ $address{'f'} = 1; }

# ���n�b�V����ǉ���`
	# ���M�֎~
	if($address{'concept'} =~ /Deny-send/){
		$address{'deny_flag'} = $address{'permanent_deny_flag'} = qq(���̃��[���A�h���X ( $address ) �ւ̑��M�͋֎~����Ă��܂��B);
	} elsif($address{'undelivered_count'} >= 5 && $type !~ /Skip-undelivered-count/){
		$address{'deny_flag'} = qq(�������[�����������߁A���̃A�h���X ( $address ) �ւ̃��[�����M�͒�~���ł��B�ĊJ����ɂ́A�}�C�y�[�W�Ŋm�F���[�����đ��M���Ă��������B);
	} elsif(time < $address{'block_time'}){
		my $left_time = $address{'block_time'} - time;
		my($how_long_left) = Mebius::SplitTime(undef,$address{'block_time'} - time);
		$address{'deny_flag'} = qq(���̃��[���A�h���X ( $address ) �ɂ͈ꎞ�I�ɑ��M�ł��܂���B���� $how_long_left ��ɍđ��M���Ă��������B);
	}

	# ���M�֎~����
	if($address{'allow_hour'} =~ /^([0-9]{1,2})-([0-9]{1,2})$/){

		$address{'allow_hour_start'} = $1;
		$address{'allow_hour_end'} = $2;

		my($hour,$allow_flag,$i);

		my $allow_hours = $times->foreach_hours($address{'allow_hour_start'},$address{'allow_hour_end'});
			foreach my $hour (@{$allow_hours}){
				if($hour == $main::thishour){ $allow_flag = 1; }
			}

			if(!$allow_flag){
					if(!$address{'deny_flag'}){
						$address{'deny_flag'} = qq(���̃A�h���X ( $address ) �ɑ��M�ł���̂� $address{'allow_hour_start'}:00-$address{'allow_hour_end'}:59 �̊Ԃ����ł��B);
					}
				$address{'deny_hour_flag'} = 1;
			}
	}

	# �m�F���[���̔z�M��
	if(time < $address{'cer_lastsend_time'} + 24*60*60){ $address{'cer_count'} = 0; }
	if($address{'cer_count'} >= 5){
		$address{'deny_sendcermail_flag'} = qq(�m�F���[����A���ő��肷���ł��B�����ǔF�؂��ς܂��邩�A�P���قǑ҂��Ă��烁�[�����Ĕ��s���Ă��������B);
	}

	if(time < $address{'cer_lastsend_time'} + 1*60 && $main::myadmin_flag < 5){
		$address{'deny_sendcermail_flag'} = qq(�Z���Ԃł̊m�F���[���̘A�����M�͏o���܂���B);
	}

	# �F�؍ς݂��ۂ�
	if($address{'concept'} =~ /Certified/){ $address{'certified_flag'} = 1; }

	# �ڍ׃f�[�^���m�F
	if($type =~ /Get-hash-detail/){
			# �����̔F�؃A�h���X���ǂ������`�F�b�N
			if($address{'addr'} && $address{'addr'} eq $main::addr){ $address{'myaddress_flag'} = 1; }
			if($address{'host'} && $address{'host'} eq $main::host){ $address{'myaddress_flag'} = 1; }
			if($address{'cnumber'} && $address{'cnumber'} eq $main::cnumber){ $address{'myaddress_flag'} = 1; }
			if($main::k_acess && $address{'agent'} && $address{'agent'} eq $main::agent){ $address{'myaddress_flag'} = 1; }
			if($address{'account'} && $address{'account'} eq $main::pmfile){ $address{'myaddress_flag'} = 1; }
			# �����̔F�؃A�h���X���ǂ������`�F�b�N ( �m�F���[���̒i�K )
			if($address{'cer_addr'} && $address{'cer_addr'} eq $main::addr){ $address{'cer_myaddress_flag'} = 1; }
			if($address{'cer_host'} && $address{'cer_host'} eq $main::host){ $address{'cer_myaddress_flag'} = 1; }
			if($address{'cer_cnumber'} && $address{'cer_cnumber'} eq $main::cnumber){ $address{'cer_myaddress_flag'} = 1; }
			if($main::k_acess && $address{'cer_agent'} && $address{'cer_agent'} eq $main::agent){ $address{'cer_myaddress_flag'} = 1; }
			if($address{'cer_account'} && $address{'cer_account'} eq $main::pmfile){ $address{'cer_myaddress_flag'} = 1; }
			if($address{'cer_xip'} && $address{'cer_xip'} eq $main::xip){ $address{'cer_myaddress_flag'} = 1; }
			# �F�ؑ҂����ǂ������`�F�b�N
			if($address{'concept'} =~ /Cer-wait/ && $address{'cer_char'} && time < $address{'cer_lastsend_time'} + 24*60*60){
				$address{'waitcer_flag'} = 1;
			}
	}

	# ���t�@�C�����X�V
	if($type =~ /Renew/){

			# ���R�Ȓl�ōX�V����
			foreach ( keys %renew ){

					if(defined($renew{$_})){ $address{$_} = $renew{$_}; }
			}

			# Char���Ȃ��ꍇ�͎�����`
			if($address{'char'} eq ""){ ($address{'char'}) = Mebius::Crypt->char(30); }

			# ���[���^�C�v��������`����ꍇ
			if($address{'mail_type'} eq ""){
				my(undef,$mail_type) = mail_format(undef,$address);
					if($mail_type eq "mobile"){ $address{'mail_type'} = "mobile"; }
					elsif($mail_type eq "normal"){ $address{'mail_type'} = "normal"; }
			}

			# ���[�����M��������������`����ꍇ
			if($address{'allow_hour'} eq ""){
					if($address{'mail_type'} eq "normal"){ $address{'allow_hour'} = "0-23"; }
					elsif($address{'mail_type'} eq "mobile"){ $address{'allow_hour'} = "8-23"; }
			}

			# ���V�K���M�̏ꍇ
			if($type =~ /Send-mail/){
					if($address{'deny_flag'}){ return(%address); }	# Mebius::DBI->); ���
				if($address{'firstsend_time'} eq ""){ $address{'firstsend_time'} = time; }
				$address{'lastsend_time'} = time;
				$address{'allsend_count'}++;
			}

			# ���������[�����Ԃ��Ă����ꍇ
			if($type =~ /Undelivered/){
					# ���M�����i�t�@�C�����́j���Ȃ��ꍇ�̓��^�[��
					if(!$address{'f'}){ return(); }
					# �O��̑��M���玞�Ԃ��o�߂������Ă���ꍇ�̓��^�[�� ( �U���h�~ )
					if($address{'lastsend_time'} && time > $address{'lastsend_time'} + 5*60){ return(); }
				$address{'undelivered_count'}++;
					#if($address{'undelivered_count'} >= 5){
					#	
					#}
				#$address{'lastsend_time'} = undef;
			}

			# ���������[�����Ԃ��Ă����ꍇ ( Too Many ~ �G���[�ňꎞ�I�ɑ��M���~���� )
			if($type =~ /Undelivered-later/){
				$address{'block_time'} = time + 1*60*60;
			}

			# ����̑��M���֎~����ꍇ
			if($type =~ /Deny-send/ && $address{'concept'} !~ /Deny-send/){
				$address{'concept'} =~ s/ Cer-wait//g;
				$address{'concept'} .= qq( Deny-send);
			}

			# ����̑��M���֎~����ꍇ
			if($type =~ /Allow-send/){
				$address{'concept'} =~ s/ Deny-send//g;
				$address{'undelivered_count'} = 0;
				$address{'block_time'} = 0;
			}

			# �����̐ڑ��f�[�^���L�^����ꍇ
			if($type =~ /(Cer-finished|Renew-myaccess)/){
				$address{'addr'} = $main::addr;
					if($main::host){ $address{'host'} = $main::host; }
					if($main::cnumber){ $address{'cnumber'} = $main::cnumber; }
					if($main::agent){ $address{'agent'} = $main::agent; }
					if($main::pmfile){ $address{'account'}  = $my_account->{'id'}; }
			}

			# �m�F���[����z�M�����ꍇ
			if($type =~ /Send-cermail/){
					if($address{'cer_char'} eq ""){ ($address{'cer_char'}) = Mebius::Crypt::char(undef,30); }
				$address{'cer_addr'} = $main::addr;
				$address{'cer_host'} = $main::host;
				$address{'cer_cnumber'} = $main::cnumber;
				$address{'cer_agent'} = $main::agent;
				$address{'cer_account'}  = $main::pmfile;
				$address{'cer_lastsend_time'} = time;
				$address{'undelivered_count'} = 0;
				$address{'cer_count'}++;
				$address{'block_time'} = undef;
				$address{'concept'} =~ s/ (Cer-wait|Deny-send)//g;
				$address{'concept'} .= " Cer-wait";
			}

			# ���[���F��(�{�l�m�F)�ɐ��������ꍇ
			if($type =~ /Cer-finished/){
				$address{'char'} = $address{'cer_char'};
				$address{'cer_char'} = "";
				$address{'cer_lastsend_time'} = "";
				$address{'cer_type'} = "";
				$address{'cer_count'} = "";
				$address{'cer_addr'} = "";
				$address{'cer_host'} = "";
				$address{'cer_cnumber'} = "";
				$address{'cer_agent'} = "";
				$address{'cer_account'} = "";
				$address{'cer_xip'} = "";
				$address{'concept'} =~ s/ Cer-wait//g;
					if($address{'concept'} !~ /Certified/){ $address{'concept'} .= qq( Certified); }
				$address{'concept'} =~ s/ Deny-send//g;
			}

		# �X�V�s���`
		push(@renew_line,"$address{'concept'}<>$address<>$address{'char'}<>$address{'firstsend_time'}<>$address{'lastsend_time'}<>$address{'block_time'}<>\n");
		push(@renew_line,"$address{'allsend_count'}<>$address{'undelivered_count'}<>$address{'mail_type'}<>$address{'allow_hour'}<>\n");
		push(@renew_line,"$address{'addr'}<>$address{'host'}<>$address{'cnumber'}<>$address{'agent'}<>$address{'account'}<>\n");
		push(@renew_line,"$address{'cer_lastsend_time'}<>$address{'cer_char'}<>$address{'cer_type'}<>$address{'cer_count'}<>\n");
		push(@renew_line,"$address{'cer_addr'}<>$address{'cer_host'}<>$address{'cer_cnumber'}<>$address{'cer_agent'}<>$address{'cer_account'}<>$address{'xip'}<>\n");

		# �X�V�����s
		Mebius::Mkdir(undef,$directory);
		Mebius::Fileout(undef,$file,@renew_line);
	}

	# ���n�b�V�������^�[��
	if($type =~ /Get-hash/){ return(%address); }

# ���^�[��
return(%address);

}


#-----------------------------------------------------------
# ���[���A�h���X�̏������`�F�b�N
#-----------------------------------------------------------
sub mail_format{

# �錾
my($type,$mailto) = @_;
my($error_flag,$mail_type);
my $email_object = new Mebius::Email;
#my $encoding = new Mebius::Encoding;

my $error_flag = $email_object->format_error($mailto);
	if($error_flag){
		#$encoding->shift_jis($error_flag);
	}

	# ���o�C������
	if($mailto =~ /(\@|\.)(docomo|ezweb|softbank|pdx|vodafone|disney|emnet|ido|i\.softbank)(\.ne)?\.jp$/){ $mail_type = "mobile"; }
	elsif($mailto =~ /(\@|\.)(willcom)(\.com)$/){ $mail_type = "mobile"; }
	else{ $mail_type = "normal"; }

	# �����ɃG���[��\������ꍇ
	if($error_flag && $type =~ /(ERROR|Error-view)/){ main::error("$error_flag"); }

return($error_flag,$mail_type);

}

#-----------------------------------------------------------
# �t�H�[�}�b�g�`�F�b�N ( �ʂ̏��������o����悤�� )
#-----------------------------------------------------------
sub email_format_error_check{

my(@self) = mail_format(undef,$_[0]);

}


#-----------------------------------------------------------
# ���[���̑��M�֎~ / �ĊJ �t�H�[��
#-----------------------------------------------------------
sub AllowDenyForm{

# �錾
my($line);

$line .= qq(<form action=""$main::sikibetu>);
$line .= qq(<div>\n);
$line .= qq(<input type="hidden" name="mode" value="mail"$main::xclose>\n);
$line .= qq(<input type="hidden" name="char" value="$main::in{'char'}"$main::xclose>\n);
$line .= qq(<input type="hidden" name="type" value="deny_address"$main::xclose>\n);
$line .= qq(<input type="submit" value="���M���֎~����"$main::xclose>\n);

$line .= qq(</div>\n);
$line .= qq(</form>\n);


#HTML
my $print = $line;

Mebius::Template::gzip_and_print_all({ source => "utf8" },$print);

exit;

}

#-----------------------------------------------------------
# �M���o����A�h���X���ǂ���
#-----------------------------------------------------------
sub confidence_address{

my $self = shift;
my $address = shift;
my $flag;

	if($address =~ /\.(jp|com)$/ && 
		$address !~ /
			(\@|\.)
			(
			(inter7|supermailer|sute)\.jp|
			(deadesu|rtrtr|temp15qm|meltmail|guerrillamailblock|mailmetrash)\.com
			)$
		/x){
		$flag = 1;
	} else {
		0;
	}




$flag;

}

#-----------------------------------------------------------
# ���[���z�M�ݒ�y�[�W��URL
#-----------------------------------------------------------
sub edit_address_url{

my $self = shift;
my $address = shift;
my $char = shift;
my($basic_init) = Mebius::basic_init();

# ���[���A�h���X���G���R�[�h
my($address_enc) = Mebius::Encode(undef,$address);

my $url = qq($basic_init->{'top_domain_url'}_main/?mode=address&type=form_edit_address&char=$char&email=$address_enc);

$url;

}





1;
