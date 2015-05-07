
package Mebius::Adventure;
use Mebius::RegistCheck;
use strict;

#-----------------------------------------------------------
# �ݒ�ύX
#-----------------------------------------------------------
sub EditStatus{

# �Ǐ���
my($init) = &Init();
my($none,%renew);
my($my_account) = Mebius::my_account();
our($advmy);

# �A�N�Z�X����
main::axscheck("Post-only ACCOUNT");

# �L�����t�@�C�����J��
my($adv) = &File("Password-check File-check-error",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1  });

#, input_char => $main::in{'char'}

# ���`
$main::in{'advcomment'} =~ s/(����|ww|��w|w��)//g;
$main::in{'advpr'} =~ s/(����|ww|��w|w��)//g;
$main::in{'advwaza'} =~ s/(����|ww|��w|w��)//g;

# ���s�֎~
$main::in{'advpr'} =~ s/<br>//g;
$main::in{'advcomment'} =~ s/<br>//g;
$main::in{'advwaza'} =~ s/<br>//g;
$main::in{'advurl'} =~ s/<br>//g;

	# �o�^���e�̕ύX
	if(length($main::in{'advpr'}) >= 2*100){ main::error("100�����܂œo�^�ł��܂��B"); }
	if(length($main::in{'advcomment'}) >= 2*100){ main::error("100�����܂œo�^�ł��܂��B"); }
	if(length($main::in{'advwaza'}) >= 2*100){ main::error("100�����܂œo�^�ł��܂��B"); }
	if(length($main::in{'advurl'}) >= 2*100){ main::error("100�����܂œo�^�ł��܂��B"); }

	# URL���֎~
	my($base_directory) = Mebius::BaseInitDirectory();
	require "${base_directory}regist_allcheck.pl";
	main::url_check("",$main::in{'advpr'});
	main::url_check("",$main::in{'advcomment'});
	main::url_check("",$main::in{'advwaza'});
	main::url_check("",$main::in{'advurl'});
	main::error_view();

# �ύX���e���`
$renew{'pr'} = $main::in{'advpr'};
$renew{'comment'} = $main::in{'advcomment'};
$renew{'waza'} = $main::in{'advwaza'};
$renew{'url'} = $main::in{'advurl'};

	# �ύX���e�i�Ǘ��Ҍ����j
	if($my_account->{'master_flag'}){
			if($main::ch{'advex'}){ $renew{'exp'} = $main::in{'advex'}; }
			if($main::ch{'advgold'}){ $renew{'gold'} = $main::in{'advgold'}; }
			if($main::ch{'advbank'}){ $renew{'bank'} = $main::in{'advbank'}; }
			if($main::ch{'block_time'} && $main::in{'block_time'} =~ /^(\d+)$/){ $renew{'block_time'} = $main::in{'block_time'}; }
			if($main::ch{'name'}){ $renew{'name'} = $main::in{'name'}; }
	}

# �L�����t�@�C�����X�V
&File("Password-check Renew Mydata",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1  },\%renew);
#, input_char => $main::in{'char'}

	# �R�����g���e���L�^ ( �Ǘ��҉{���p )
	if($adv->{'comment'} ne $renew{'comment'}){
		my($nowdate) = Mebius::now_date();
		Mebius::Fileout("Plusfile","$init->{'adv_dir'}_log_adv/comment_adventure.log","$nowdate	$adv->{'id'}	$adv->{'name'}	$main::host	$renew{'comment'}\n");
	}

	# �W�����v�ݒ�
	if($main::in{'id'} eq $advmy->{'id'}){
		$main::jump_url = $init->{'login_url'};
	}
	else{
		$main::jump_url = $adv->{'chara_url'};
	}


my $print = qq(<h1>�ݒ��ύX���܂����B</h1>$init->{'continue_button'}\n);

Mebius::Template::gzip_and_print_all({ jump_sec => 3 },$print);

exit;

}


1;

