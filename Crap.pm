
use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# 拍手ファイル
#-----------------------------------------------------------
sub crap_file{

return();

my $use = shift if(ref $_[0] eq "HASH");
my($target_bbs,$thread_number) = @_;
my($FILE1,%self,$renew,@renew_line,%data_format);
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($target_bbs);
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($my_access) = Mebius::my_access();

	if($target_bbs =~ /\W/ || $target_bbs eq ""){ return(); }
	if($thread_number =~ /\D/ || $thread_number eq ""){ return(); }

# ファイル定義
if(!$init_bbs->{'data_directory'}){ die("Perl Die! Can't decide data directory."); }
	my $directory = "$init_bbs->{'data_directory'}_crap_count_${target_bbs}/";
	my $counter_file = "${directory}${thread_number}_cnt.cgi";

	# ファイルを開く （必要な場合はファイルロック）
	my($FILE1,$read_write) = Mebius::File::read_write($use,$counter_file,$directory);
		if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }

# データ構造を定義
$data_format{'1'} = [('count','last_time','xips','cnumbers','res')];
$data_format{'2'} = [('old_count','old_reason')];

	# トップデータを読み込み
	my($split_data) = Mebius::file_handle_to_hash(\%data_format,$FILE1);
	%self = (%self,%$split_data);

	while(<$FILE1>){

		my($done_flag);

		chomp;
		my($key2,$handle2,$id2,$trip2,$comment2,$account2,$host2,$cnumber2,$age2,$lasttime2,$date2,$res2,$deleter2,$addr2) = split(/<>/);

			# フラグ
			if(time < $lasttime2 + 24*60*60){
					if($my_account->{'id'} eq $account2 && $account2){ $done_flag = 1; }
					if($my_cookie->{'char'} eq $cnumber2 && $cnumber2){ $done_flag = 1; }
					if($my_access->{'mobile_uid'} && $my_access->{'multi_user_agent'} eq $age2 && $age2){ $done_flag = 1; }
					if($ENV{'REMOTE_ADDR'} eq $addr2 && $addr2){ $done_flag = 1; }
					if($done_flag){
						$self{'done_flag'} = 1;
							if($comment2){ $self{'comment_done_flag'} = 1; }
					}
			}

			if($use->{'Renew'}){

					# 一定時間以上経過しているコメントなしのデータ行は削除する
					if($key2 eq "" && time > $lasttime2 + 7*24*60*60){
						0;	
					} else {
						push(@renew_line,"$key2<>$handle2<>$id2<>$trip2<>$comment2<>$account2<>$host2<>$cnumber2<>$age2<>$lasttime2<>$date2<>$res2<>$deleter2<>\n");
					}
			}

	}

	# 更新禁止フラグを立てる
	# 連続して新しい拍手は出来ないように
	if($use->{'NewCrap'} && $self{'done_flag'} && !Mebius::AlocalJudge()){
		$self{'not_renew_flag'} = 1;
	}
	# コメントする場合、以前に拍手していないとコメントできないように
	elsif($use->{'NewComment'} && !$self{'done_flag'}){
		$self{'not_renew_flag'} = 1;
	}

	# ファイル更新
	if($use->{'Renew'} && !$self{'not_renew_flag'}){

			# 新しい行を追加
			if($use->{'new_line'}){
				unshift(@renew_line,$use->{'new_line'});
			}


		# 任意の更新とリファレンス化
		($renew) = Mebius::Hash::control(\%self,$use->{'select_renew'});

		# データフォーマットからファイル更新
		Mebius::File::data_format_to_truncate_print(\%data_format,$FILE1,$renew,\@renew_line);

	}

close($FILE1);

	if($use->{'Renew'} && $renew){
		return($renew);
	} else{
		return(\%self);
	}

}


#-----------------------------------------------------------
# レス拍手を取得 ( 未使用 )
#-----------------------------------------------------------
sub ResCrap{

# 宣言
my($type,$realmoto,$thread_number) = @_;
my($i,@renew_line,%data,$file_handler,%res_crap);

	# 汚染チェック
	if($realmoto eq "" || $realmoto =~ /\W/){ return(); }
	if($thread_number eq "" || $thread_number =~ /\D/){ return(); }

# ファイル定義
my $directory1 = "${main::int_dir}_res_crap/";
my $directory2 = "${directory1}_${realmoto}_res_crap/";
my $file1 = "${directory2}${thread_number}_res_crap.log";

# ファイルを開く
open($file_handler,"<$file1");

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# 局所化
		my($mycrap_flag);

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($key2,$res_number2,$crap_count2,$accounts2) = split(/<>/);

			# アカウントを展開
			foreach(split(/\s/,$accounts2)){
				if($_ eq $main::myaccount{'file'}){ $mycrap_flag = 1; }
			}


			# 元記事との拍手数照合用
			if($type =~ /Get-crap/){
				$res_crap{"crap_count_$res_number2"} = $crap_count2;
				$res_crap{"craped_flag_$res_number2"} = $mycrap_flag;
			}


			# 行を追加
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$res_number2<>$crap_count2<>$accounts2<>\n");
			}

	}

close($file_handler);

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);
		Mebius::Mkdir(undef,$directory2);

		# ファイル更新
		unshift(@renew_line,"$data{'key'}<>\n");
		Mebius::Fileout(undef,$file1,@renew_line);

	}

# ハッシュを返す
if($type =~ /Get-crap/){ return(%res_crap); }
else{ return(%data); }


}


1;

1;
