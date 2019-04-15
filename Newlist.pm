
use strict;
package Mebius::Newlist;

#-----------------------------------------------------------
# �P���̑����X�����L�^
#-----------------------------------------------------------
sub Daily{

# �錾
my($type) = @_;
my($handler,$directory,$renewline,$logfile);

# �t�@�C����`
$logfile = "${main::int_dir}_sinnchaku/_daily_record/${main::thisyear}_${main::thismonth}_${main::today}_daily_record.log";

# �t�@�C���������ꍇ�͍쐬����
if(!-f $logfile){ Mebius::Fileout("NEWMAKE",$logfile); }

# �t�@�C�����J��
open($handler,"+<$logfile");

# �t�@�C�����b�N
if($type =~ /Renew/){ flock($handler,2); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$handler>);
chomp(my $top2 = <$handler>);

my($tres_bbs) = split(/<>/,$top1);
my($resdiary_auth,$postdiary_auth,$comment_auth) = split(/<>/,$top2);

	# �J�E���g�𑝂₷
	if($type =~ /Renew/){ 
			if($type =~ /Comment-auth/){ $comment_auth++; }
			elsif($type =~ /Resdiary-auth/){ $resdiary_auth++; }
			elsif($type =~ /Postdiary-auth/){ $postdiary_auth++; }
	}

# �X�V����s���`
$renewline .= qq($tres_bbs<>\n);
$renewline .= qq($resdiary_auth<>$postdiary_auth<>$comment_auth<>\n);

	# �t�@�C���X�V
	if($type =~ /Renew/){
		seek($handler,0,0);
		truncate($handler,tell($handler));
		print $handler $renewline;
	}

close($handler);

return();

}

1;
