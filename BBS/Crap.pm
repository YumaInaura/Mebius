
use strict;
package Mebius::BBS;
use File::Copy;

#-----------------------------------------------------------
# いいね！ファイル
#-----------------------------------------------------------
sub crap_file{

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
	my($FILE1,$read_write) = Mebius::File::read_write($use,$counter_file,[$directory]);
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
	# 連続して新しいいいね！は出来ないように
	if($use->{'NewCrap'} && $self{'done_flag'} && !Mebius::alocal_judge()){
		$self{'not_renew_flag'} = 1;
	}
	# コメントする場合、以前にいいね！していないとコメントできないように
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
# いいね！数を取得
#-----------------------------------------------------------
sub get_crap_count{

my $use = shift;
my $use_thread = shift;
my($count,$crap);
my($init_directory) = Mebius::BaseInitDirectory();

	# 記事本体が読み取れない場合
	if(!$use_thread->{'f'}){
			return();
	}

	# いいね！数がある場合
	if($use_thread->{'crap_count'} >= 1){
		$count = $use_thread->{'crap_count'};
	}

	# 2012/3/28 (水) 期限付き いいね！フラグを立てる
	elsif($ENV{'REQUEST_METHOD'} eq "GET" && $use_thread->{'posttime'} < 1334019089 + (24*60*60) && time < 1334019089 + (30*24*60*60)){
		#&& $use_thread->{'concept'} !~ /Crap-not-done/ && $use_thread->{'concept'} !~ /Crap-done/

		($crap) = Mebius::BBS::crap_file($use_thread->{'target_bbs'},$use_thread->{'number'});

		my %renew_thread;

			if($crap->{'f'}){

				$renew_thread{'.'}{'concept'} = " Crap-done";
				$renew_thread{'s/g'}{'concept'} = " Crap-done";
				$renew_thread{'crap_count'} = $crap->{'count'};
				#Mebius::AccessLog(undef,"Crap-flag","記事： $use_thread->{'url'} ");
				#Mebius::Email::send_email({ ToMaster => 1 },undef,"記事にいいね！フラグを立てました。","$use_thread->{'url'}");
				#Mebius::Mkdir(undef,"${init_directory}_save_thread/");

				#copy($use_thread->{'file'},"${init_directory}_save_thread/$use_thread->{'realmoto'}-$use_thread->{'number'}.cgi");

				Mebius::BBS::thread({ Renew => 1 , select_renew => \%renew_thread , relay_thread => $use_thread });
				$count = $crap->{'count'};

			} 

	}

	# いいね！直後はカウントを増やす
	if($use->{'CrapDone'}){
		$count++;
	}


$count = "0" if !$count;

$count;

}


1;
