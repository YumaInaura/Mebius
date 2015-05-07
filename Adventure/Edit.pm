
package Mebius::Adventure;
use Mebius::RegistCheck;
use strict;

#-----------------------------------------------------------
# 設定変更
#-----------------------------------------------------------
sub EditStatus{

# 局所化
my($init) = &Init();
my($none,%renew);
my($my_account) = Mebius::my_account();
our($advmy);

# アクセス制限
main::axscheck("Post-only ACCOUNT");

# キャラファイルを開く
my($adv) = &File("Password-check File-check-error",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1  });

#, input_char => $main::in{'char'}

# 整形
$main::in{'advcomment'} =~ s/(ｗｗ|ww|ｗw|wｗ)//g;
$main::in{'advpr'} =~ s/(ｗｗ|ww|ｗw|wｗ)//g;
$main::in{'advwaza'} =~ s/(ｗｗ|ww|ｗw|wｗ)//g;

# 改行禁止
$main::in{'advpr'} =~ s/<br>//g;
$main::in{'advcomment'} =~ s/<br>//g;
$main::in{'advwaza'} =~ s/<br>//g;
$main::in{'advurl'} =~ s/<br>//g;

	# 登録内容の変更
	if(length($main::in{'advpr'}) >= 2*100){ main::error("100文字まで登録できます。"); }
	if(length($main::in{'advcomment'}) >= 2*100){ main::error("100文字まで登録できます。"); }
	if(length($main::in{'advwaza'}) >= 2*100){ main::error("100文字まで登録できます。"); }
	if(length($main::in{'advurl'}) >= 2*100){ main::error("100文字まで登録できます。"); }

	# URLを禁止
	my($base_directory) = Mebius::BaseInitDirectory();
	require "${base_directory}regist_allcheck.pl";
	main::url_check("",$main::in{'advpr'});
	main::url_check("",$main::in{'advcomment'});
	main::url_check("",$main::in{'advwaza'});
	main::url_check("",$main::in{'advurl'});
	main::error_view();

# 変更内容を定義
$renew{'pr'} = $main::in{'advpr'};
$renew{'comment'} = $main::in{'advcomment'};
$renew{'waza'} = $main::in{'advwaza'};
$renew{'url'} = $main::in{'advurl'};

	# 変更内容（管理者権限）
	if($my_account->{'master_flag'}){
			if($main::ch{'advex'}){ $renew{'exp'} = $main::in{'advex'}; }
			if($main::ch{'advgold'}){ $renew{'gold'} = $main::in{'advgold'}; }
			if($main::ch{'advbank'}){ $renew{'bank'} = $main::in{'advbank'}; }
			if($main::ch{'block_time'} && $main::in{'block_time'} =~ /^(\d+)$/){ $renew{'block_time'} = $main::in{'block_time'}; }
			if($main::ch{'name'}){ $renew{'name'} = $main::in{'name'}; }
	}

# キャラファイルを更新
&File("Password-check Renew Mydata",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} , TypeCharCheck => 1  },\%renew);
#, input_char => $main::in{'char'}

	# コメント内容を記録 ( 管理者閲覧用 )
	if($adv->{'comment'} ne $renew{'comment'}){
		my($nowdate) = Mebius::now_date();
		Mebius::Fileout("Plusfile","$init->{'adv_dir'}_log_adv/comment_adventure.log","$nowdate	$adv->{'id'}	$adv->{'name'}	$main::host	$renew{'comment'}\n");
	}

	# ジャンプ設定
	if($main::in{'id'} eq $advmy->{'id'}){
		$main::jump_url = $init->{'login_url'};
	}
	else{
		$main::jump_url = $adv->{'chara_url'};
	}


my $print = qq(<h1>設定を変更しました。</h1>$init->{'continue_button'}\n);

Mebius::Template::gzip_and_print_all({ jump_sec => 3 },$print);

exit;

}


1;

